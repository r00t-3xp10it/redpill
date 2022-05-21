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
|obfuscator|Encrypt batch scripts|User Land|Dependencies: certutil - [Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/obfuscator.png)|

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
