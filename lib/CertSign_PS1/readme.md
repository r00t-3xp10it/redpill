## Module Name
   <b><i>PSscriptSigning.bat</i></b>

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|PSscriptSigning|Signs one PS1 script ( **certlm.msc - certificate** ) + Execute it?<br />This allow us to execute our PS1 cmdlet even if set-executionpolicy<br />its set to only run signed cmdlets [( AllSigned, RemoteSigned )](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.2)|Administrator|[PSscriptSigning.bat](https://github.com/r00t-3xp10it/redpill/blob/main/bypass/PSscriptSigning.bat)<br />[DeletePSscriptSignning.bat](https://github.com/r00t-3xp10it/redpill/blob/main/bypass/DeletePSscriptSignning.bat)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/PSscriptSigning.bat" -OutFile "PSscriptSigning.bat"
```

<br />

**prerequesites checks:**
```powershell
(IEX(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/CertSign_PS1/auxiliary.ps1"))
```

```powershell
# Execute the next cmdline to auto-execute PS1 after sign it?
Add-Content -Path "PSscriptSigning.bat" -Value "`npowershell -File %PSsignPath%" -Force

# Execute the batch script that signs our cmdlet
.\PSscriptSigning.bat
```


**check if (FriendlyName: SsaRedTeam - Subject: My_Code_Signing_Certificate) certificate exists:**
```powershell
[manual] Certlm.msc
[auto] Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Issuer -match 'My_Code_Signing_Certificate'}
```

<br /><br />

**Delete certificate from store**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/DeletePSscriptSignning.bat" -OutFile "DeletePSscriptSignning.bat"
```

```powershell
.\DeletePSscriptSignning.bat
```

**check if (FriendlyName: SsaRedTeam - Subject: My_Code_Signing_Certificate) certificate was deleted:**
```powershell
[manual] Certlm.msc
[auto] Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Issuer -match 'My_Code_Signing_Certificate'}
```

<br /><br />

## Restrictions
```
The PSscriptSigning.bat batch script can only be used to sign one cmdlet at a time...
Because its uses 'SsaRedTeam' as certificate FriendlyName, but... if we execute the
DeletePSscriptSignning.bat script than PSscriptSigning.bat can be invoked again to sign a new cmdlet ..

```

Article: https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/working-with-certificates.md
