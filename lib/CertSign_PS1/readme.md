## Module Name
   <b><i>PSscriptSigning.bat</i></b>

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|PSscriptSigning|Signs one PS1 script (certificate) + Execute it?<br />This allow us to execute our PS1 cmdlet even if set-executionpolicy<br />its set to only run signed cmdlets|Administrator|\*\*\*|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/PSscriptSigning.bat" -OutFile "PSscriptSigning.bat"
```

**prerequesites:**
```powershell
Get-ExecutionPolicy -List
Get-Service -Name LanManServer
```

```powershell
# Execute the next cmdline to auto-execute PS1 after sign it?
Add-Content -Path "PSscriptSigning.bat" -Value "powershell -File %PSsignPath%" -Force
.\PSscriptSigning.bat
```

<br /><br />

**Delete certificate from store**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/DeletePSscriptSignning.bat" -OutFile "DeletePSscriptSignning.bat"
```

```powershell
.\DeletePSscriptSignning.bat
```