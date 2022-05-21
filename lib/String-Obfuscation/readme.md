## Module Name
   <b><i>enc-rot13.ps1</i></b>

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|enc-rot13|Encrypt or decrypt strings using ROT13 cipher.|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/enc-rot13.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/enc-rot13.ps1" -OutFile "enc-rot13.ps1"
```

```powershell
.\enc-rot13.ps1 -text "whoami"
.\enc-rot13.ps1 -text "jubnzv"
.\enc-rot13.ps1 -text "whoami" -output ps1
.\enc-rot13.ps1 -text "whoami" -output logfile
.\enc-rot13.ps1 -infile "payload.ps1" -output ps1
```

<br />

## Module Name
   <b><i>Out-EncodedSpecialCharOnlyCommand.ps1</i></b>

|Function Name|Description|Privileges|Notes|
|---|---|---|---|
|Out-EncodedSpecialCharOnlyCommand|Generates Special-Character-Only encoded payload<br />for a PowerShell command or script.|User Land|[Screenshot1](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/bhoanoon1.png)<br />[Screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/2bhoanoon1.png)<br />[Screenshot3](https://github.com/r00t-3xp10it/redpill/blob/main/lib/String-Obfuscation/output-to-file.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Out-EncodedSpecialCharOnlyCommand.ps1" -OutFile "Out-EncodedSpecialCharOnlyCommand.ps1"
```

```powershell
Import-Module -Name ".\Out-EncodedSpecialCharOnlyCommand.ps1" -Force
Out-EncodedSpecialCharOnlyCommand -ScriptBlock {Write-Host 'Hello World!' -ForegroundColor Green; Write-Host 'Obfuscation Rocks!' -ForegroundColor Green} -NoProfile -NonInteractive -PassThru
```

<br />

## Module Name
   <b><i>obfuscator.bat</i></b>

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|obfuscator|Encrypt batch scripts|User Land|Dependencies: [certutil](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/certutil) - [Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/obfuscator.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/obfuscator.bat" -OutFile "obfuscator.bat"
```

```powershell
.\obfuscator.bat Payload.bat
```

<br />

## Module Name
   <b><i>vbs_obfuscator.vbs</i></b>

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|vbs_obfuscator|Encrypt vbs scripts|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/vbs_obfuscator.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/vbs_obfuscator.vbs" -OutFile "vbs_obfuscator.vbs"
```

**[Manual]**
```vbs
cscript.exe vbs_obfuscator.vbs Payload.vbs
```

**[Automatic]**
```vbs
cscript.exe vbs_obfuscator.vbs Payload.vbs > Buffer.vbs
$parse = Get-Content Buffer.vbs
echo $parse[3] > Buffer.vbs
```

**OR**
```powershell
cscript.exe vbs_obfuscator.vbs Payload.vbs > Buffer.vbs
$parse = Get-Content Buffer.vbs|Select-String -Pattern "Execute chr"
echo $parse > Buffer.vbs
```

<br />

## Module Name
   <b><i>Encrypt-String.ps1</i></b>

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|Encrypt-String|Encrypt commands \| scripts using a secret key of 113 bytes|User Land|[Screenshot1](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Encrypt-String.png)<br />[Screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Encrypt-Decrypt.png) - [Decrypt-String.ps1](https://github.com/r00t-3xp10it/redpill/blob/main/bypass/encrypt_decrypt/Decrypt-String.ps1)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Encrypt-String.ps1" -OutFile "Encrypt-String.ps1"
```

**[Encrypt cmdline OnScreen]**
```powershell
.\Encrypt-String.ps1 -action "console" -plaintextstring "whoami"
```

**[Encrypt PS1 script and build decrypt script]**
```powershell
.\Encrypt-String.ps1 -action "autodecrypt" -infile "Payload.ps1"
```

**[Encrypt 'whoami' command + send encrypted string to the recipient email address]**
```powershell
.\Encrypt-String.ps1 -action "console" -plaintextstring "whoami" -SendTo "pedroubuntu@gmail.com"
```

<br />

```powershell
iwr -uri "[https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/encrypt_decrypt/Decrypt-String.ps1" -OutFile "Decrypt-String.ps1"
```

**[Decrypt cmdline OnScreen (encrypted chat)]**
```powershell
.\Decrypt-String.ps1 -action "console" -EncryptedString "76492d1116743f0423413b16050a5345MgB8AHAARgBNAHgASABTAEIARQA5AEkAWgA5AFIAaQBkAGEAcQBKADkAdwBHAFEAPQA9AHwANQBhAGEANwBhADkAYQBhAGMANgAzADIAOQBmAGQAMwBmADEAMwAwADQAYwBmADgAZAA2AGIAYQBlADUAMABmAA=="
```
