## Module Name
   DecodeRDPCache

   **Description:**
   <b><i>reads RDP persistent cache from the cache0001.bin file and stores cached bitmaps as PNG files</i></b>

   **prerequisites:**
``` 
   cache0001.bin
```
   **Syntax:**
```powershell   
.\DecodeRDPCache.ps1
```

<br />

## Module Name
   DLLSearch

   **Description:**
   <b><i>List DLLs loaded by running processes!</i></b>

   **Syntax:**
```powershell      
.\DLLSearch.ps1 -Verb true
.\DLLSearch.ps1 -Verb true -Exclude 'lsass'
.\DLLSearch.ps1 -Verb true -Filter 'explorer'
.\DLLSearch.ps1 -Verb true -MaxProcesses '10'
```

<br />

## Module Name
   Find-AppLockerLogs

   **Description:**
   <b><i>Look through the AppLocker logs to find processes that get run on the server</i></b>

   **Syntax:**
```powershell
Import-Module -Name .\Find-AppLockerLogs.ps1 -Force
Find-AppLockerLogs
```



<br />

## Module Name
   List-AllMailboxAndPST

   **Description:**
   <b><i>displays user information, and the stores currently attached to the profile</i></b>

   **Syntax:**
```powershell
.\List-AllMailboxAndPST.ps1
```
