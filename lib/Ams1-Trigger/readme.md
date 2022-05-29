## amsitrigger_x64.exe

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|amsitrigger_x64|Hunting for Malicious Strings that triggers AMSI detection inside cmdlets|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Trigger/Ams1-Trigger.png)|

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Trigger/amsitrigger_x64.exe" -OutFile "amsitrigger_x64.exe"
```

**execute:**
```powershell
.\AmsiTrigger_x64.exe -h
.\amsitrigger_x64.exe -i=C:\users\pedro\coding\temporarios\Invoke-Mimikatz.ps1 -f=2
.\amsitrigger_x64.exe -i=C:\users\pedro\coding\temporarios\Invoke-Mimikatz.ps1 -f=3
```

