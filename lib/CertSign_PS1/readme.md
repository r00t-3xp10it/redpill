## Module Name
   <b><i>PSscriptSigning.bat</i></b>

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|PSscriptSigning|Signs one PS1 script ( **certlm.msc - certificate** ) + Auto-Execute it ?<br />This allow us to execute our PS1 cmdlet even if set-executionpolicy<br />its set to only run signed cmdlets [( AllSigned, RemoteSigned )](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.2)|Administrator|[PSscriptSigning.bat](https://github.com/r00t-3xp10it/redpill/blob/main/bypass/PSscriptSigning.bat)<br />[DeletePSscriptSignning.bat](https://github.com/r00t-3xp10it/redpill/blob/main/bypass/DeletePSscriptSignning.bat)<br />Dependencies: LanManServer|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/PSscriptSigning.bat" -OutFile "PSscriptSigning.bat"
```

<br />

**prerequesites checks:**
```powershell
Get-ExecutionPolicy -Scope CurrentUser
[bool](Get-Service -Name LanManServer)
```

```powershell
# Execute the next cmdline to: auto-execute the PS1 after PSscriptSigning.bat have sign it ?
[optional] Add-Content -Path "PSscriptSigning.bat" -Value "`npowershell -W 1 -File %PSsignPath%" -Force

# Execute the batch script that signs our PS1 cmdlet
.\PSscriptSigning.bat
```


**check if (Subject: My_Code_Signing_Certificate) certificate exists:**
```powershell
[manual] Certlm.msc
[auto] $List = @("Root","My");ForEach($Item in $List){Get-ChildItem Cert:\LocalMachine\$Item|Where-Object {$_.Issuer -match 'My_Code_Signing_Certificate'}}
```

<br /><br />

**Delete certificate from store**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/DeletePSscriptSignning.bat" -OutFile "DeletePSscriptSignning.bat"
```

```powershell
.\DeletePSscriptSignning.bat
```

**check if (Subject: My_Code_Signing_Certificate) certificate was deleted:**
```powershell
[manual] Certlm.msc
[auto] Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Issuer -match 'My_Code_Signing_Certificate'}
```

<br />

### Final Notes
```
This BATCH script can sign\execute our cmdlet even if Set-ExecutionPolicy its set to 'AllSigned, RemoteSigned'.
Because executing BATCH scripts its NOT affected by 'Set-ExecutionPolicy' target settings, this allow us to
Sign the cmdlet and then auto-execute it bypassing 'Set-ExecutionPolicy AllSigned,RemoteSigned' restrictions.

The PSscriptSigning.bat script can only be used to sign ONE cmdlet at a time, because it uses
the same Subject Name everytime it signs one cmdlet ( Subject: My_Code_Signing_Certificate )

```

Article: https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/working-with-certificates.md

<br /><br />

## Module Name
   <b><i>Invoke-LazySign.ps1</i></b>

|Function Name|Description|Privileges|Notes|
|---|---|---|---|
|[Invoke-LazySign](https://github.com/r00t-3xp10it/redpill/blob/main/lib/CertSign_PS1/Invoke-LazySign.ps1)|Sign a Windows binary\Cmdlet with a self-signed certificate|Administrator|[Screenshot1](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/CertSign_PS1/Invoke-LazySign.png)<br />[Screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/CertSign_PS1/SuperWork.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/CertSign_PS1/Invoke-LazySign.ps1" -OutFile "Invoke-LazySign.ps1"
```

<br />

**prerequesites checks:**
```powershell
#Make sure we have administrator privileges in shell
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

#Make sure all the required modules are present\loaded
[bool]((Get-Module -ListAvailable -Name "PKI").ExportedCmdlets|findstr /C:"New-SelfSignedCertificate")
[bool]((Get-Module -ListAvailable -Name "Microsoft.PowerShell.Security").ExportedCommands|findstr /C:"Set-AuthenticodeSignature")
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

This cmdlet will 'NOT' sign our script.ps1 if 'Set-ExecutionPolicy AllSigned,RemoteSigned' are set.
Because ExecutionPolicy will prevent this cmdlet from running. If you wish to bypass the restrictions
then execute the 'PSscriptSigning.bat' batch module contained in this same repository (the first module)

The PSscriptSigning.bat script can only be used to sign 'ONE' cmdlet at a time, because it uses
the same Subject Name everytime it signs one cmdlet ( Subject: My_Code_Signing_Certificate )
```

Article: https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/working-with-certificates.md
