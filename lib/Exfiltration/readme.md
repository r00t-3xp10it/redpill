## Module Name
   <b><i>DLLSearch.ps1</i></b>

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|DLLSearch|List DLLs loaded by running processes!|User Land|\*\*\*|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/DLLSearch.ps1" -OutFile "DLLSearch.ps1"
```

```powershell
.\DLLSearch.ps1 -Verb true
.\DLLSearch.ps1 -Verb true -Exclude 'lsass'
.\DLLSearch.ps1 -Verb true -Filter 'explorer'
.\DLLSearch.ps1 -Verb true -MaxProcesses '10'
```

<br />

## Module Name
   <b><i>DecodeRDPCache.ps1</i></b>

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|DecodeRDPCache|reads RDP persistent cache from the cache0001.bin<br />file and stores cached bitmaps as PNG files|User Land|prerequisites: **cache0001.bin**|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/DecodeRDPCache.ps1" -OutFile "DecodeRDPCache.ps1"
```

```powershell
.\DecodeRDPCache.ps1
```

<br />

## Module Name
   <b><i>Find-AppLockerLogs.ps1</i></b>

|Function Name|Description|Privileges|Notes|
|---|---|---|---|
|Find-AppLockerLogs|Look through the AppLocker logs to find processes that get run on the server|User Land|\*\*\*|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/Find-AppLockerLogs.ps1" -OutFile "Find-AppLockerLogs.ps1"
```

```powershell
Import-Module -Name .\Find-AppLockerLogs.ps1 -Force
Find-AppLockerLogs
```

<br />


## Module Name
   <b><i>List-AllMailboxAndPST.ps1</i></b>

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|List-AllMailboxAndPST|Look through the AppLocker logs to find processes that get run on the server|User Land|\*\*\*|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/List-AllMailboxAndPST.ps1" -OutFile "List-AllMailboxAndPST.ps1"
```

```powershell
.\List-AllMailboxAndPST.ps1
```
