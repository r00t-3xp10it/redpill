# * Encrypt\Decrypt strings with powershell using a SecretKey *
![sem](https://user-images.githubusercontent.com/23490060/156955337-0b51d056-f091-465d-893a-d5ceb17ddabf.png)


<br /><br />

## :octocat: Project Description
This cmdlet allow users to encrypt <b><i>'text\commands\scripts.ps1'</i></b> with the help of <b><i>ConvertTo-SecureString</i></b> cmdlet and a secretkey of 113<br />bytes length, it outputs results on console, logfile or builds a decrypt.ps1 script with the decrypt function routine to be abble to execute<br />the encrypted string. ( decrypt.ps1 cmdlet will auto-delete itself after execution if <b><i>NOT</i></b> invoked with -deldecrypt 'false' parameter )<br />

This project can be used as an <b><i>encrypted chat</i></b> where is users encrypt their messages at source with the help of <b><i>Encrypt-String.ps1</i></b><br />cmdlet and decrypt messages at destination with the help of <b><i>Decrypt-String.ps1</i></b> cmdlet ( both users encrypted communication )<br />Remark: If the <b><i>EncryptedString</i></b> length its greater than <b><i>2000 bytes</i></b>, then cmdlet will auto-create one logfile with the encrypted<br />string (oneline) to be easy to copy\paste if required..

It can also be used to create a <b><i>decryption script (decrypt.ps1)</i></b> that will execute commands or full ps1 scripts encrypted.<br />Useful for evading Windows Defender amsi string detection engine that searchs for suspicious strings inside our projects.<br />**Example: Encrypt-String.ps1 cmdlet can be used to encrypt @Meterpeter C2 client.ps1 agent and auto-decrypt it at runtime**.


<br />

## :octocat: Notes
If invoked <b><i>-RandomByte '0'</i></b> then Encrypt-String.ps1 cmdlet random generates the SecretKey last byte (3 digits). But in that ocassion the Decrypt-String cmdlet will not work unless the comrrespondent secretkey ( the same secretkey used to encrypt ) its invoked to decrypt string.<br /><br />
Remark: Parameter -RandomByte '253' (default secretkey last byte) can be invoked on Decrypt-String cmdlet to input the required secretKey.<br />
Remark: Parameter -RunElevated 'true' Spawns UAC gui to be abble to run decrypt.ps1 in an elevated context. ( administrator token privs )

---

<br />

## :octocat: Encrypt-String cmdlet Parameters

|Parameter Name|Description|Default Value|
|---|---|---|
|Action|Accepts arguments: console, autodecrypt, log|console|
|PlainTextString|The string\text\command to encrypt|whoami|
|InFile|Get the string to encrypt from txt\ps1|false|
|OutFile|The decrypt routine script name|decrypt|
|RandomByte|0 (random), 253 (default) OR from 242 to 255|253|
|deldecrypt|Auto-delete decrypt.ps1 cmdlet?|true|
|RunElevated *|Auto-elevate decrypt.ps1 cmdlet?|false|
* Spawn UAC gui to be abble to run decrypt.ps1 in an elevated context ...

<br />

## :octocat: Download cmdlet
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/encrypt_decrypt/Encrypt-String.ps1" -OutFile "Encrypt-String.ps1"
```

<br />

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
.\Encrypt-String.ps1 -action "autodecrypt" -infile "test.ps1" -randombyte "0"
```
```powershell
.\Encrypt-String.ps1 -action "autodecrypt" -plaintextstring "powershell.exe" -randombyte "0" -runelevated "true"
```
![iamadmin](https://user-images.githubusercontent.com/23490060/156955891-cb3d2d83-772e-40a8-9a60-0e1d686709ef.png)


---

<br />

## :octocat: Decrypt-String cmdlet Parameters

![nice](https://user-images.githubusercontent.com/23490060/156942705-5fce1475-5cb9-4631-adf7-8743e43a7c12.png)

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

<br />

## :octocat: Decrypt-String cmdlet examples
```powershell
.\Decrypt-String.ps1 -action "console" -EncryptedString "76492d1116743f0423413b16050a5345MgB8AHIAUAA0AHkAdABMADgAYgBEAFAAdwBLAEkARgBOAHkATABwAEEAcgBUAEEAPQA9AHwAZAA0ADUAZAA1AGEAMgAxAGYAMAAxAGIAMwAxADAAMABkADkAZABiADgAOQAzADgANwAzADMAYwAzADQAYgA0ADEAZgAzAGUAMwBkAGYAYQAwADQAZgA3ADkAMAA4AGUAMAAxAGEAYgA0ADQAMgBmADQAZQA0ADUAYwA4AGUAYwA3AGUANwBiAGEAYwBiADkAMgAyADcANwA3ADMAZAA2AGEAYQA5AGUAYwAxAGQAMQA2AGIANABmAGMANABkADMAYQBmADYAOABiAGMAYQBkADkANQBjADcAMwBkADIAZAAwAGQAMgBhAGUAZQA4ADgAMQBmAGUAYgAwADcAZQA2ADQAMwBkADUAYwAyADUAMgA4ADYAZAA2ADMAZQA5ADAAZgA5AGEAMgA3ADUAOABlADEAMwA4ADYAMgA4ADQAMQAyADIANgA5ADkAOQBhADcAMQA1ADIAYwAyADMANABlADYAOQA5AGYAYQBmADQAMwA3ADUAZgA0ADQAZABmADkA"
```
```powershell
.\Decrypt-String.ps1 -action "execute" -randombyte "250" -EncryptedString "76492d1116743f0423413b16050a5345MgB8AHIAUAA0AHkAdABMADgAYgBEAFAAdwBLAEkARgBOAHkATABwAEEAcgBUAEEAPQA9AHwAZAA0ADUAZAA1AGEAMgAxAGYAMAAxAGIAMwAxADAAMABkADkAZABiADgAOQAzADgANwAzADMAYwAzADQAYgA0ADEAZgAzAGUAMwBkAGYAYQAwADQAZgA3ADkAMAA4AGUAMAAxAGEAYgA0ADQAMgBmADQAZQA0ADUAYwA4AGUAYwA3AGUANwBiAGEAYwBiADkAMgAyADcANwA3ADMAZAA2AGEAYQA5AGUAYwAxAGQAMQA2AGIANABmAGMANABkADMAYQBmADYAOABiAGMAYQBkADkANQBjADcAMwBkADIAZAAwAGQAMgBhAGUAZQA4ADgAMQBmAGUAYgAwADcAZQA2ADQAMwBkADUAYwAyADUAMgA4ADYAZAA2ADMAZQA5ADAAZgA5AGEAMgA3ADUAOABlADEAMwA4ADYAMgA4ADQAMQAyADIANgA5ADkAOQBhADcAMQA1ADIAYwAyADMANABlADYAOQA5AGYAYQBmADQAMwA3ADUAZgA0ADQAZABmADkA"
```
```powershell
.\Decrypt-String.ps1 -action "console" -randombyte "250" -EncryptedString "76492d1116743f0423413b16050a5345MgB8AHIAUAA0AHkAdABMADgAYgBEAFAAdwBLAEkARgBOAHkATABwAEEAcgBUAEEAPQA9AHwAZAA0ADUAZAA1AGEAMgAxAGYAMAAxAGIAMwAxADAAMABkADkAZABiADgAOQAzADgANwAzADMAYwAzADQAYgA0ADEAZgAzAGUAMwBkAGYAYQAwADQAZgA3ADkAMAA4AGUAMAAxAGEAYgA0ADQAMgBmADQAZQA0ADUAYwA4AGUAYwA3AGUANwBiAGEAYwBiADkAMgAyADcANwA3ADMAZAA2AGEAYQA5AGUAYwAxAGQAMQA2AGIANABmAGMANABkADMAYQBmADYAOABiAGMAYQBkADkANQBjADcAMwBkADIAZAAwAGQAMgBhAGUAZQA4ADgAMQBmAGUAYgAwADcAZQA2ADQAMwBkADUAYwAyADUAMgA4ADYAZAA2ADMAZQA5ADAAZgA5AGEAMgA3ADUAOABlADEAMwA4ADYAMgA4ADQAMQAyADIANgA5ADkAOQBhADcAMQA1ADIAYwAyADMANABlADYAOQA5AGYAYQBmADQAMwA3ADUAZgA0ADQAZABmADkA"
```

<br /><br />

## :octocat: Special thanks

|Name|Description|
|---|---|
|@shanty damayanti|Debugging cmdlet|
|@Saâd Ahla|Debugging cmdlet|

<br />

**Anatomy of a decrypt script**
![anatomy](https://user-images.githubusercontent.com/23490060/157081056-70bcb061-4015-41c4-a775-f716afdc4696.jpg)


<br />

## :octocat: SSA RedTeam @2022
