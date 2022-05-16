<#
.SYNOPSIS
   Enumerate/Kill running process\tokens

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.6

.DESCRIPTION
   This CmdLet enumerates 'All' running process if used
   only the 'Enum' @arg IF used the -ProcessName parameter
   then cmdlet 'Kill' or 'Enum' the sellected process Name.

.NOTES
   Remark: Token @argument requires Administrator privs

.Parameter GetProcess
   Accepts arguments: Enum, Kill and Tokens

.Parameter ProcessName
   Accepts the Process Name to enumerate or to kill

.Parameter Exclude
   The Process to be excluded from query! (default: true)

.Parameter Verb
   Display process loaded dll's modules! (default: false)

.EXAMPLE
   PS C:\> Get-Help .\GetProcess.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PC C:\> .\GetProcess.ps1 -GetProcess Enum
   Enumerate ALL Remote Host Running Process(s)

.EXAMPLE
   PC C:\> .\GetProcess.ps1 -GetProcess Enum -ProcessName firefox
   Enumerate firefox.exe Process {Id,Name,ProductVersion,StartTime,Description}

.EXAMPLE
   PC C:\> .\GetProcess.ps1 -GetProcess Enum -Exclude "lsass,Idle,svchost,RuntimeBroker"
   Enumerate ALL Remote Host Running Process(s) But exclude from querys -Exclude "<name,name>"

.EXAMPLE
   PC C:\> .\GetProcess.ps1 -GetProcess Kill -ProcessName firefox.exe
   Kill Remote Host firefox.exe Running Process

.EXAMPLE
   PC C:\> .\GetProcess.ps1 -GetProcess Tokens
   Enum ALL user process tokens and queries them for details

.OUTPUTS
   Id Name                  ProductVersion    StartTime            Description
   -- ----                  --------------    ---------            ----------- 
 8524 ACMON                 1, 0, 0, 0        17/07/2021 22:01:19  ACMON                                      
 1724 ApplicationFrameHost  10.0.19041.746    17/07/2021 21:59:30  Application Frame Host                     
 7904 AsusTPLoader          1.0.51.0          17/07/2021 21:59:12  ASUS Smart Gesture Loader
 5092 dllhost               10.0.19041.546    17/07/2021 21:58:53  COM Surrogate
 9300 HxOutlook             16.0.13426.20910  17/07/2021 23:01:51  Microsoft Outlook
 4416 WinStore.App          0.0.0.0           17/07/2021 22:02:51  Store 
 6272 YourPhone             1.21052.124.0     17/07/2021 21:58:36  YourPhone

 .LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/r00t-3xp10it/redpill/blob/main/bin/GetProcess.ps1
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$ProcessName="false",
   [string]$GetProcess="false",
   [string]$Exclude="true",
   [string]$Verb="false"
)


Write-Host ""
$Remote_hostName = $Env:COMPUTERNAME
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null


If($GetProcess -ieq "Tokens")
{

   ## Download Get-OSTokenInformation.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\Get-OSTokenInformation.ps1"))
   {
      ## Download Get-OSTokenInformation.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/modules/Get-OSTokenInformation.ps1 -Destination $Env:TMP\Get-OSTokenInformation.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\Get-OSTokenInformation.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 26)
      {
         ## Corrupted download detected => DefaultFileSize: 26,314453125/KB
         write-host "`nx " -ForegroundColor Red -NoNewline
         Write-Host "Error: Abort, Corrupted download detected" -ForegroundColor DarkGray
         If(Test-Path -Path "$Env:TMP\Get-OSTokenInformation.ps1")
         {
            Remove-Item -Path "$Env:TMP\Get-OSTokenInformation.ps1" -Force
         }
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }


   try{## Run auxiliary module
      Import-Module -Name "$Env:TMP\Get-OSTokenInformation.ps1" -Force
      Get-OSTokenInformation -Brief -Verbose
   }catch{
      write-host "`nx " -ForegroundColor Red -NoNewline
      Write-Host "Error: Importing\Running Get-OSTokenInformation.ps1 cmdlet!" -ForegroundColor DarkGray
      Write-Host "";exit ## Exit @GetProcess
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\Get-OSTokenInformation.ps1")
   {
      Remove-Item -Path "$Env:TMP\Get-OSTokenInformation.ps1" -Force
   }
   exit ## Exit @GetProcess
}


If($GetProcess -ieq "Enum" -or $GetProcess -ieq "Kill"){


    If($Exclude -ieq "true")
    {
       $Exclude = "Idle,svchost,RuntimeBroker"
    }

    $Olddraw = $Exclude
    $Exclude = $Exclude -replace ',','|'
    If($GetProcess -ieq "Enum" -and $ProcessName -ieq "false")
    {

        ## Enumerate ALL running process(s)
        Write-Host "`n* $Remote_hostName Running Processes!" -ForegroundColor Green
        Write-Host "  => Excluding: $Olddraw" -ForegroundColor Yellow
        Write-Host "";Start-Sleep -Seconds 1

        $Regex = "cmd|vbscript|taskhostw|lsass|services|explorer|MsMpEng|smartscreen|powershell|wininit|winlogon"
        Get-Process -EA SilentlyContinue | Select-Object Id,Name,ProductVersion,StartTime,Description |
           Where-Object { $_.Name -iNotMatch "$Exclude" } | Format-Table -AutoSize |
              Out-String -Stream | ForEach-Object {
                 $stringformat = If($_ -iMatch "($Regex)")
                 {
                    @{ 'ForegroundColor' = 'Yellow' }
                 }
                 Else
                 {
                    @{ 'ForegroundColor' = 'white' }
                 }
                 Write-Host @stringformat $_
              }

    }
    ElseIf($GetProcess -ieq "Enum" -and $ProcessName -ne "false")
    {

       If($ProcessName -iMatch "$Exclude")
       {
          write-host "x " -ForegroundColor Red -NoNewline;
          Write-Host "Error: '$ProcessName' by default its excluded from cmdlet querys!" -ForegroundColor DarkGray
          Write-Host "* Invoke: .\GetProcess.ps1 -GetProcess Enum -processname '$ProcessName' -Exclude 'false'`n" -ForegroundColor Yellow
          exit ## Exit @GetProcess
       }

       ## Enumerate User Inpur ProcessName
       Write-Host "`n* '$ProcessName' Process Information!" -ForegroundColor Green

       Start-Sleep -Seconds 1
       $RawProcName = $ProcessName -replace '.exe','' ## Replace .exe in processname to be abble use Get-Process
       Get-Process $RawProcName -EA SilentlyContinue | Select-Object Id,PriorityClass,Name,ProcessName,Description,Product,Company,StartTime,FileVersion,Path,MainWindowTitle,HasExited,Responding |
          Where-Object { $_.Name -iNotMatch "^($Exclude)$" -and $_.PriorityClass -iNotMatch '^(Idle)$' } | Select -Last 1 | Format-List > $Env:TMP\Tbl.log # To be abble to exclude the first line from output later!

       #Colorize output and exclude 1º line
       Get-Content -Path "$Env:TMP\Tbl.log" | 
          Select-Object -Skip 1 | Select-Object -SkipLast 3 | Out-String -Stream | ForEach-Object {
             $stringformat = If($_ -iMatch "^(Id|Description|StartTime|Responding)")
             {
                @{ 'ForegroundColor' = 'Yellow' }
             }
             Else
             {
                @{ 'ForegroundColor' = 'white' }
             }
             Write-Host @stringformat $_
          }

       #Check Process state!
       $CheckProc = (Get-Process $RawProcName).Responding|Select-Object -Last 1
       If(-not($CheckProc -ieq "True"))
       {
          ## User Input => ProcessName NOT found
          write-host "`nx " -ForegroundColor Red -NoNewline
          Write-Host "Error: '" -ForegroundColor DarkGray -NoNewline
          Write-Host "$ProcessName" -ForegroundColor DarkYellow -NoNewline
          Write-Host "' NOT Responding!" -ForegroundColor DarkGray
          Start-Sleep -Seconds 1
       }
       Else
       {

          If($Verb -ieq "True")
          {
             ## Display process loaded dll's { modules }
             $LoadedDlls = (Get-Process -Name "$ProcessName").modules.FileName | Where-Object { $_ -iNotMatch '[.exe]$' }
             Write-Host "DLLs loaded     : $LoadedDlls" -ForegroundColor DarkGray

          }

       }

    }
    ElseIf($GetProcess -ieq "Kill")
    {
       ## Kill User Input => Running Process
       If($ProcessName -ieq $null -or $ProcessName -ieq "false"){## Make sure ProcessName Mandatory argument its set
           Write-Host "[error] -ProcessName Mandatory Parameter Required!" -ForegroundColor Red -BackgroundColor Black
           Write-Host "";Start-Sleep -Seconds 1;exit ## Exit @GetProcess
       }

       ## Make sure ProcessName its running
       $RawProcName = $ProcessName -replace '.exe',''
       $MSPIR = (Get-Process $RawProcName).Responding|Select-Object -Last 1
       If($MSPIR -ieq "True")
       {
          ## ProcessName found => Responding
          If(-not($ProcessName -Match "(.exe)$"))
          {
              ## Add extension required (.exe) by taskkill cmdline
              $ProcessName = "$ProcessName" + ".exe" -join ''
          }
          cmd /R taskkill /F /IM $ProcessName
        }
        Else
        {
           ## ProcessName NOT found responding
           write-host "`nx " -ForegroundColor Red -NoNewline;
           Write-Host "Error: $ProcessName Process name NOT Responding!" -ForegroundColor DarkGray
           Start-Sleep -Seconds 1
        }
    }
    Write-Host ""
    Remove-Item -Path "$Env:TMP\Tbl.log" -Force
}