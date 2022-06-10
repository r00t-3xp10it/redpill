## DLLSearch.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|DLLSearch|List DLLs loaded by running processes!|User Land|\*\*\*|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/DLLSearch.ps1" -OutFile "DLLSearch.ps1"
```

**execute:**
```powershell
.\DLLSearch.ps1 -Verb true
.\DLLSearch.ps1 -Verb true -Exclude 'lsass'
.\DLLSearch.ps1 -Verb true -Filter 'explorer'
.\DLLSearch.ps1 -Verb true -MaxProcesses '10'
```

<br />

## DecodeRDPCache.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|DecodeRDPCache|reads RDP persistent cache from the cache0001.bin<br />file and stores cached bitmaps as PNG files|User Land|prerequisites: **cache0001.bin**|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/DecodeRDPCache.ps1" -OutFile "DecodeRDPCache.ps1"
```

**execute:**
```powershell
.\DecodeRDPCache.ps1
```

<br />

## Find-AppLockerLogs.ps1

|Function Name|Description|Privileges|Notes|
|---|---|---|---|
|Find-AppLockerLogs|Look through the AppLocker logs to find processes that get run on the server|User Land|\*\*\*|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/Find-AppLockerLogs.ps1" -OutFile "Find-AppLockerLogs.ps1"
```

**execute:**
```powershell
Import-Module -Name .\Find-AppLockerLogs.ps1 -Force
Find-AppLockerLogs
```

<br />

## List-AllMailboxAndPST.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|List-AllMailboxAndPST|Look through the AppLocker logs to find processes that get run on the server|User Land|\*\*\*|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/List-AllMailboxAndPST.ps1" -OutFile "List-AllMailboxAndPST.ps1"
```

**execute:**
```powershell
.\List-AllMailboxAndPST.ps1
```

<br />

## WindowsUpdateLog.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[WindowsUpdateLog](https://github.com/r00t-3xp10it/redpill/blob/main/bin/WindowsUpdateLog.ps1)|Convert ETL logfiles (WindowsUpdate) into readable data|User Land|\*\*\*|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/WindowsUpdateLog.ps1" -OutFile "WindowsUpdateLog.ps1"
```

**execute:**
```powershell
Get-Help .\WindowsUpdateLog.ps1 -Full

#Enumerate the first 100 windows update logs
.\WindowsUpdateLog.ps1

#Enumerate the first 8 windows update logs
.\WindowsUpdateLog.ps1 -First '8'

#Enumerate the first 100 windows update logs with '(Defender|FAILED|UDP)' strings
.\WindowsUpdateLog.ps1 -Filter '(Defender|FAILED|UDP)'

#Enumerate the first 100 windows update logs from the sellected directory
.\WindowsUpdateLog.ps1 -ETLPath "$Env:SYSTEMDRIVE\ProgramData\USOShared\Logs\System"

#Enumerate the first 30 windows update logs and create logfile
.\WindowsUpdateLog.ps1 -first '30' -logfile 'true'

```

<br />

## Get-PrefetchListing.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[Get-PrefetchListing](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/Get-PrefetchListing.ps1)|Manage (query \ Delete) prefetch files (.pf)|User Land|\*\*\*|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/Get-PrefetchListing.ps1" -OutFile "Get-PrefetchListing.ps1"
```

**execute:**
```powershell
#Enumerate prefetch files
.\Get-PrefetchListing.ps1 -action "Enum"

#Delete prefetch files
.\Get-PrefetchListing.ps1 -action "del"
```
