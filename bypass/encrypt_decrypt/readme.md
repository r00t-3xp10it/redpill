# Encrypt\Decrypt strings in powershell using a SecretKey
![one](https://user-images.githubusercontent.com/23490060/156936241-192b7b66-564d-40a5-af44-e8f61e8254a3.png)

<br /><br />

## :octocat: Project Description
This cmdlet allow users to encrypt <b><i>'text\commands\scripts.ps1'</i></b> with the help of <b><i>ConvertTo-SecureString</i></b> cmdlet and a secretkey of 113<br />bytes length, it outputs results on console, logfile or builds a decrypt.ps1 script with the decrypt function routine to be abble to execute<br />the encrypted string. ( decrypt.ps1 cmdlet will auto-deletes itself after execution if <b><i>NOT</i></b> invoked -deldecrypt 'false' parameter )<br />

<br />

## :octocat: Notes
If invoked <b><i>-RandomByte 'true'</i></b> then Encrypt-String.ps1 cmdlet random generates the SecretKey last byte.<br />
But in that ocassion the Decrypt-String cmdlet will not work unless the comrrespondent secretkey ( the same secretkey used to encrypt ) its invoked. Remark: Parameter -RandomByte '253' (secretkey last byte) can be invoked on Decrypt-String cmdlet to input the required secretKey used by Encrypt-String cmdlet while encrypting string.<br />

---

<br />

## :octocat: Encrypt-String cmdlet Parameters

|Parameter Name|Description|Default Value|
|---|---|---|
|Action|Accepts arguments: console, autodecrypt, log|console|
|PlainTextString|The string\text\command to encrypt|whoami|
|InFile|Get the string to encrypt from txt\ps1|false|
|OutFile|The decrypt routine script name|decrypt|
|RandomByte|Random secretkey generation|false|
|deldecrypt|Auto-delete decrypt.ps1 cmdlet?|true|

<br />

## :octocat: Download cmdlet
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/encrypt_decrypt/Encrypt-String.ps1" -OutFile "Encrypt-String.ps1"
```

## :octocat: Encrypt-String cmdlet examples
```powershell
.\Encrypt-String.ps1 -action "console" -plaintextstring "whoami"
```
```powershell
.\Encrypt-String.ps1 -action "log" -plaintextstring "whoami"
```
```powershell
.\Encrypt-String.ps1 -action "console" -infile "test.ps1"
```
```powershell
.\Encrypt-String.ps1 -action "autodecrypt" -plaintextstring "whoami"
```
```powershell
.\Encrypt-String.ps1 -action "autodecrypt" -infile "test.ps1" -randombyte "true"
```

---

<br />

## :octocat: Decrypt-String cmdlet Parameters

|Parameter Name|Description|Default Value|
|---|---|---|
|Action|Accepts arguments: console, execute|console|
|EncryptedString|The string\text\command to be Decrypted by this cmdlet|User_Input|
|RandomByte|Encrypt-String SecretKey Last Byte|253|

<br />

## :octocat: Download cmdlet
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/encrypt_decrypt/Decrypt-String.ps1" -OutFile "Decrypt-String.ps1"
```

## :octocat: Decrypt-String cmdlet examples
```powershell
.\Decrypt-String.ps1 -action "console" -EncryptedString "76492d1116743f0423413b16050a5345MgB8AHIAUAA0AHkAdABMADgAYgBEAFAAdwBLAEkARgBOAHkATABwAEEAcgBUAEEAPQA9AHwAZAA0ADUAZAA1AGEAMgAxAGYAMAAxAGIAMwAxADAAMABkADkAZABiADgAOQAzADgANwAzADMAYwAzADQAYgA0ADEAZgAzAGUAMwBkAGYAYQAwADQAZgA3ADkAMAA4AGUAMAAxAGEAYgA0ADQAMgBmADQAZQA0ADUAYwA4AGUAYwA3AGUANwBiAGEAYwBiADkAMgAyADcANwA3ADMAZAA2AGEAYQA5AGUAYwAxAGQAMQA2AGIANABmAGMANABkADMAYQBmADYAOABiAGMAYQBkADkANQBjADcAMwBkADIAZAAwAGQAMgBhAGUAZQA4ADgAMQBmAGUAYgAwADcAZQA2ADQAMwBkADUAYwAyADUAMgA4ADYAZAA2ADMAZQA5ADAAZgA5AGEAMgA3ADUAOABlADEAMwA4ADYAMgA4ADQAMQAyADIANgA5ADkAOQBhADcAMQA1ADIAYwAyADMANABlADYAOQA5AGYAYQBmADQAMwA3ADUAZgA0ADQAZABmADkA"
```
```powershell
.\Decrypt-String.ps1 -action "execute" -EncryptedString "76492d1116743f0423413b16050a5345MgB8AHIAUAA0AHkAdABMADgAYgBEAFAAdwBLAEkARgBOAHkATABwAEEAcgBUAEEAPQA9AHwAZAA0ADUAZAA1AGEAMgAxAGYAMAAxAGIAMwAxADAAMABkADkAZABiADgAOQAzADgANwAzADMAYwAzADQAYgA0ADEAZgAzAGUAMwBkAGYAYQAwADQAZgA3ADkAMAA4AGUAMAAxAGEAYgA0ADQAMgBmADQAZQA0ADUAYwA4AGUAYwA3AGUANwBiAGEAYwBiADkAMgAyADcANwA3ADMAZAA2AGEAYQA5AGUAYwAxAGQAMQA2AGIANABmAGMANABkADMAYQBmADYAOABiAGMAYQBkADkANQBjADcAMwBkADIAZAAwAGQAMgBhAGUAZQA4ADgAMQBmAGUAYgAwADcAZQA2ADQAMwBkADUAYwAyADUAMgA4ADYAZAA2ADMAZQA5ADAAZgA5AGEAMgA3ADUAOABlADEAMwA4ADYAMgA4ADQAMQAyADIANgA5ADkAOQBhADcAMQA1ADIAYwAyADMANABlADYAOQA5AGYAYQBmADQAMwA3ADUAZgA0ADQAZABmADkA"
```
```powershell
.\Decrypt-String.ps1 -action "console" -randombyte "250" -EncryptedString "76492d1116743f0423413b16050a5345MgB8AHIAUAA0AHkAdABMADgAYgBEAFAAdwBLAEkARgBOAHkATABwAEEAcgBUAEEAPQA9AHwAZAA0ADUAZAA1AGEAMgAxAGYAMAAxAGIAMwAxADAAMABkADkAZABiADgAOQAzADgANwAzADMAYwAzADQAYgA0ADEAZgAzAGUAMwBkAGYAYQAwADQAZgA3ADkAMAA4AGUAMAAxAGEAYgA0ADQAMgBmADQAZQA0ADUAYwA4AGUAYwA3AGUANwBiAGEAYwBiADkAMgAyADcANwA3ADMAZAA2AGEAYQA5AGUAYwAxAGQAMQA2AGIANABmAGMANABkADMAYQBmADYAOABiAGMAYQBkADkANQBjADcAMwBkADIAZAAwAGQAMgBhAGUAZQA4ADgAMQBmAGUAYgAwADcAZQA2ADQAMwBkADUAYwAyADUAMgA4ADYAZAA2ADMAZQA5ADAAZgA5AGEAMgA3ADUAOABlADEAMwA4ADYAMgA4ADQAMQAyADIANgA5ADkAOQBhADcAMQA1ADIAYwAyADMANABlADYAOQA5AGYAYQBmADQAMwA3ADUAZgA0ADQAZABmADkA"
```

<br />

## :octocat: SSA RedTeam @2022
