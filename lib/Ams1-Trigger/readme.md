## amsitrigger_x64.exe

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|amsitrigger_x64|Hunting for Malicious Strings that triggers AMSI detection inside cmdlets|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Trigger/Ams1-Trigger.png)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Trigger/amsitrigger_x64.exe" -OutFile "amsitrigger_x64.exe"
```
<br />

**execute:**
```powershell
.\AmsiTrigger_x64.exe -h
.\amsitrigger_x64.exe -i=C:\users\pedro\coding\temporarios\Invoke-Mimikatz.ps1 -f=2
.\amsitrigger_x64.exe -i=C:\users\pedro\coding\temporarios\Invoke-Mimikatz.ps1 -f=3
```

<br />

## identify_offencive_tools.ps1

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|[identify_offencive_tools](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Ams1-Trigger/identify_offensive_tools.ps1)|Hunting for Malicious Strings that triggers AMSI detection inside cmdlets|User Land|[Screenshot1](https://user-images.githubusercontent.com/23490060/292560377-86b98f67-4f34-4903-9fdb-3e7f282524ea.png)<br />[screenshot2](https://user-images.githubusercontent.com/23490060/292560394-638ac708-e6b6-444b-b37a-710b60712b00.png)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Trigger/identify_offencive_tools.ps1" -OutFile "identify_offencive_tools.ps1"
```
<br />

**execute:**
```powershell
## Hunting for Malicious Strings that triggers AMSI detection
.\identify_offencive_tools.ps1 -filetoscan "$pwd\evil.ps1"

## Send possitive results to logfile
.\identify_offencive_tools.ps1 -filetoscan "$pwd\evil.ps1" -logfile

## Scan script using AMS1 engine also
.\identify_offencive_tools.ps1 -filetoscan "$pwd\evil.ps1" -ams1
```
