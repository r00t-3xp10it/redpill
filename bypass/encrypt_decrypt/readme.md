# * Encrypt\Decrypt strings with powershell using a Secret Key *
![sem](https://user-images.githubusercontent.com/23490060/156955337-0b51d056-f091-465d-893a-d5ceb17ddabf.png)


<br /><br />

## :octocat: Project Description
This cmdlet allow users to encrypt <b><i>'text\commands\scripts.ps1'</i></b> with the help of <b><i>ConvertTo-SecureString</i></b> cmdlet and a secret key of 113<br />bytes length, it outputs results on console, logfile or builds a decrypt.ps1 script with the decrypt function routine to be abble to execute<br />the encrypted string. ( decrypt.ps1 cmdlet will auto-delete itself after execution if <b><i>NOT</i></b> invoked with -deldecrypt 'false' parameter )<br />

This project can be used to exchange encrypted messages between two persons (eg. facebook chat) Where we encrypt the messages<br />at the source with the help of <b><i>Encrypt-String.ps1</i></b> cmdlet and decrypt the messages at destination with the help of <b><i>Decrypt-String.ps1</i></b><br />Remark: If the <b><i>EncryptedString</i></b> length its greater than <b><i>1000 bytes</i></b>, then cmdlet will auto-create one logfile with the encrypted string.

It can also be used to create a <b><i>decryption script (decrypt.ps1)</i></b> that will execute commands or full PS1 (powershell) scripts encrypted.<br />Technic useful for evading Windows Defender amsi string detection engine that searchs for suspicious strings inside our projects.<br />**Example: 'Encrypt-String.ps1 cmdlet can be used to encrypt @Meterpeter C2 client.ps1 agent and auto-decrypt it at runtime'**.
![nosuprisses](https://user-images.githubusercontent.com/23490060/157342560-e89e1de7-e50d-4ff1-903b-46e42e9f794c.png)

## :octocat: Notes
If invoked <b><i>-RandomByte '0'</i></b> param then Encrypt-String.ps1 cmdlet random generates the Secret Key last byte (3 digits). But in that ocassion the <b><i>Decrypt-String</i></b> cmdlet will not work unless the comrrespondent secret key (the same secret key used to encrypt) its invoked to decrypt string.<br /><br />
Remark: Parameter -RandomByte 'byte' (secret key last byte) can be invoked on <b><i>Decrypt-String</i></b> cmdlet to input the required secret Key.<br />
Remark: Parameter -RunElevated 'true' Spawns UAC gui to be abble to run <b><i>decrypt.ps1</i></b> in an elevated context ( administrator token privs )

---

<br /><br />

## :octocat: Encrypt-String cmdlet Parameters

|Parameter Name|Description|Default Value|Optional value Description|
|---|---|---|---|
|Action|Accepts args: console, autodecrypt, log|console|autodecrypt = decrypt\execute \| log = create logfile|
|PlainTextString|The string\text\command to encrypt|whoami|netstat -ano \| findstr ':443' \| findstr /V '['|
|InFile|Get the string to encrypt from txt\ps1|false|true = input script to encrypt path\name|
|OutFile|The decrypt routine script name|decrypt|---|
|RandomByte|0 (random), 253 (default) OR from 240 to 255|253|accepts values from 240 to 255|
|deldecrypt|Auto-delete decrypt.ps1 cmdlet?|true|false = dont del decrypt.ps1|
|RunElevated *|Auto-elevate decrypt.ps1 cmdlet?|false|true = spawn UAC gui to run elevated (admin)|
* Spawn UAC gui to be abble to run decrypt.ps1 in an elevated context ...

<br />

## :octocat: Download cmdlet
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/encrypt_decrypt/Encrypt-String.ps1" -OutFile "Encrypt-String.ps1"
```

<br />

## :octocat: Encrypt-String cmdlet examples

Encrypt 'whoami' command and print encrypted string onscreen
```powershell
.\Encrypt-String.ps1 -action "console" -plaintextstring "whoami"
```

<br />

Encrypt 'whoami' command and store encrypted string in logfile
```powershell
.\Encrypt-String.ps1 -action "log" -plaintextstring "whoami"
```

<br />

Encrypt the contents of 'test.ps1' and print encrypted string onscreen
```powershell
.\Encrypt-String.ps1 -action "console" -infile "test.ps1"
```

<br />

Encrypt 'whoami' command + create 'decrypt.ps1' decrypt script + print encrypted string onscreen
```powershell
.\Encrypt-String.ps1 -action "autodecrypt" -plaintextstring "whoami"
```

<br />

Encrypt the contents of 'test.ps1' + create 'decrypt.ps1' decrypt script + randomize secret key last byte
```powershell
.\Encrypt-String.ps1 -action "autodecrypt" -infile "test.ps1" -randombyte "0"
```

<br />

Encrypt 'powershell.exe' command + create 'decrypt.ps1' decrypt script + randomize secret key last byte + run decrypt.ps1 elevated 
```powershell
.\Encrypt-String.ps1 -action "autodecrypt" -plaintextstring "powershell.exe" -randombyte "0" -runelevated "true"
```
![iamadmin](https://user-images.githubusercontent.com/23490060/156955891-cb3d2d83-772e-40a8-9a60-0e1d686709ef.png)


---

<br /><br />

## :octocat: Decrypt-String cmdlet Parameters

![nice](https://user-images.githubusercontent.com/23490060/156942705-5fce1475-5cb9-4631-adf7-8743e43a7c12.png)

|Parameter Name|Description|Default Value|Optional value Description|
|---|---|---|---|
|Action|Accepts arguments: console, execute|console|execute = decrypt\execute|
|EncryptedString|The string\text\command to be Decrypted by this cmdlet|User_Input|---|
|RandomByte|Encrypt-String SecretKey Last Byte|253|accepts values from 240 to 255|

<br />

## :octocat: Download cmdlet
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/encrypt_decrypt/Decrypt-String.ps1" -OutFile "Decrypt-String.ps1"
```

<br />

## :octocat: Decrypt-String cmdlet examples
**[ wrong secretkey last byte input error ]** - Decrypt string and print results onscreen ( the random byte used to encrypt has 250 )
```powershell
.\Decrypt-String.ps1 -action "console" -EncryptedString "76492d1116743f0423413b16050a5345MgB8ADQAOABrAFUAKwBjAGwAWQB1AFQAdQBQAEEANwBOAG4AZABFAHAAQwBaAFEAPQA9AHwANAAxAGYAZAAyADYAYQA3AGYAOQBkAGEAMQAzADIAZABlAGQAYwBjAGYANgBhADYAYgAzADkAOQA1AGIAMgAwADUAZQAzADcAZgBlADkANAAzAGMAOQA0ADcAOABjAGIAMgBjADcAMAA1ADkAYQBlADkANwAxADAAZAA5ADIAZgBjAGQAZgBmAGYAYwAwADMAZABlADYANgAwAGYANwBhADQAMQBhADAAZQBlADMANgBjAGMAZgAxADUAZgBiADEAZABhADMAZgAwADUAYwBkAGMAMwA0AGQANQAyAGEAZQAzAGMAZgBmAGQAYQAyADkAZABkADgANgA0AGUANQA4AGEAZgA2AGIAZQA4ADMAZgAxADIAMAA1AGIAMABlAGYAMAA5ADgAYwA1AGQAZAA2AGMAOAAwADUAZABhADAAOQA2ADQAZQBmAGQAMQA4ADIANwBmAGQAYwAyAGMAMwBmAGMAZgBlADkAYwBiAGQAYgBkADkANgA0AGEANwAxADUA"
```

<br />

Decrypt string using '250' as secretkey randombyte and execute\print onscreen
```powershell
.\Decrypt-String.ps1 -action "execute" -randombyte "250" -EncryptedString "76492d1116743f0423413b16050a5345MgB8ADQAOABrAFUAKwBjAGwAWQB1AFQAdQBQAEEANwBOAG4AZABFAHAAQwBaAFEAPQA9AHwANAAxAGYAZAAyADYAYQA3AGYAOQBkAGEAMQAzADIAZABlAGQAYwBjAGYANgBhADYAYgAzADkAOQA1AGIAMgAwADUAZQAzADcAZgBlADkANAAzAGMAOQA0ADcAOABjAGIAMgBjADcAMAA1ADkAYQBlADkANwAxADAAZAA5ADIAZgBjAGQAZgBmAGYAYwAwADMAZABlADYANgAwAGYANwBhADQAMQBhADAAZQBlADMANgBjAGMAZgAxADUAZgBiADEAZABhADMAZgAwADUAYwBkAGMAMwA0AGQANQAyAGEAZQAzAGMAZgBmAGQAYQAyADkAZABkADgANgA0AGUANQA4AGEAZgA2AGIAZQA4ADMAZgAxADIAMAA1AGIAMABlAGYAMAA5ADgAYwA1AGQAZAA2AGMAOAAwADUAZABhADAAOQA2ADQAZQBmAGQAMQA4ADIANwBmAGQAYwAyAGMAMwBmAGMAZgBlADkAYwBiAGQAYgBkADkANgA0AGEANwAxADUA"
```

<br />

Decrypt string (test.ps1 cmdlet) and execute\print onscreen
```powershell
.\Decrypt-String.ps1 -action "execute" -EncryptedString "76492d1116743f0423413b16050a5345MgB8ADUAdQB2AFgAUQBMAGsAQQA5AHcANwA0ADIAegBzACsANQB6ADkAWQBQAFEAPQA9AHwANAA2AGIAMgBiAGQANABlADcAOQBmAGEAYQBiADgAZgAxAGMAYwBlADUANwAxAGQAZgBhADgAMgA4AGIAMwA0ADMAZAA4AGQAOQBjADgANAA5AGUAZAA0ADkAYgBlADcANAAxADMAYwAyADYAMQA3ADcAYwBkAGYAYQA3AGUAMQAxADEAYgAwAGUANAA2ADkAMgAzADcAOQAyADcAOAAzADIAZgBjADIAZABiADYANgA2AGIANgBkADEAMgAwADYANABiAGUAMwAxADkANgAyAGMAYgAwAGEAYQA5AGIANwBjAGYAZQA2AGQAYgBmAGMANAA0ADIAZAA1AGIAYwAxADYANwBlADUAMQA3AGQANgAwAGQAZgBmAGUAMQA4ADIAYgA2AGIAZgAwAGYAZAA2ADQANQBmADIANwA1AGQAYwA3ADYAMABjAGYANAA3ADAANABhADYAYwBkADEAMwA3ADAANwAyADEANwBmAGMAMwA4ADMAMAAxADAAMQBjAGEAOQBlAGEAYgBmADgANQBkADEANQBhADYAYQA4AGUAZQA4ADAAZABkAGQAYgBkADUAZgAxADUAYQA5AGEANgA2ADQANAAzADQAMgBiADkAZgBmAGMAOABlADEAOQBhAGEAYQBkAGMAYwA0AGMAZQAwADUANAAyAGIAZgA3AGQAZgAzADgANgAwADEAZgBjADcANABhADkAZAAzADkANwA2AGIANQA5ADkANQBhADAAMwA3AGMAZgA0AGYAZQAyAGYAZQAxAGQAZQA3ADIAOAA2AGYAZgBkADIANABhADkAOQA0ADgAYQBmAGMANQA3ADkAYQBhADAAOQBmAGMAMQBhADQAOQA1ADIAZABhADkAYgBlADQAOQA5ADgAZQAxADUANAAyADkAOAAxAGUAYQBhADMAMAA4AGIAYQAyAGQANAA5ADIANwA2ADAAMgBlADMAOAAwADcAZAA4ADMAZgA2AGMAZQA4AGMAOAA3ADUAYgBjADMAYgA3ADAAYQBhAGQAZAA5ADIAZABhADgANwA1AGEANwAyAGEAZgBhAGIAYQBkADQAZQBlADgAYQAxADUAMABmAGUANQA4AGYAYQAzADAAYQBiADIANwAwADMANQBhADUAYwA1ADUAZgAxAGIAYQA1ADYAOAAzAGUAZQA0ADUAOQBiAGMAOQA1ADUANgA3AGQANgA4AGUAZABkADIAMQA3ADEAOQAzADIAYgA3ADYAYQA2ADgAZAA5ADUAYwA2AGYAZAA0ADQAZABjADUAZABmADYAMgAwADgAZQBhADgAYQBiADEAZQBhADEANABhADAAZQA2ADQANAA5AGYAMQBmADQAMABlADcAYgAxADYAZQBkADEAMgA3AGMAYQAzAGIANQBjAGMAZAA5AGQAYwA5ADkANQA3AGYAOABiADMAOAA2AGIANABmAGYAZgA5ADIAZgAyAGUAMQBlAGUAZQAyAGMAYwA3AGYAOQBmADkAZAAzADcANwAxADMAMwBhADYANgBhADkAMAA1ADMAOABlAGQANAA5ADMAYwAzAGQAMAA4ADYAZgAyADUANQAyADkAMwBlADUAZQA5ADIAZAA1ADgAYgAwADUAOABkAGEAYgBjADUAZgA4AGEANQA4AGUAZQBlADgAYgA5ADMANwA3ADMAOQBmADMAYgAwADIAMwA4ADgAYgA4AGEAMQBiADcAZAAzADQAMAAyAGQAZQA2AGIANwAyAGIAMwA5ADgANgAzADUAZgAxAGIAMwA4ADYAYgA3AGIAMgAwAGUAMABhAGMANQA4ADUAYQA4ADEAMgAwADMAZgBiAGYAZgAzADcAZQA1AGEANQBkADIAMwBhADMAZgBjADEAYQA1ADcAMgA5ADEAZAA1AGIAYQAxADQAMQA2AGQANwBlADYAMQA3AGYAMgAzADIAZQAwADEAMgAzADIAZgA4ADkAZgBjADUAZABlAGMANQAyAGQAYQAyADAAYwAzADYANQAwADYAYgBjADkAZgBhAGQAYQBjAGUAMwAyADgANQA4ADQANgA5ADgAZQA2AGMAZgBmAGMAZAA4ADgANQA4ADkAZAA1ADkAZQA4AGQAYgBlADEANQAyADUAZAAyADgAMAA5ADAANgA2ADAAOAAyADkAZABlADMAMAAxAGUAYwAyADEANgA4ADUANQAyADIAOQAwADUAOQA0AGEAOABhAGMAZgAzAGMAOQA3AGQAYQBlADIANgBkADEAMwAyADQAOQBmADUAMQA0AGQAYwA3ADIAMgAxADcAMQBmAGQANABhADYAMgAyAGQAZABhAGMAYQBmADYAMAA1ADIAYgBkADIAMABmADAAYgAyAGUAOAA1AGEANgA2ADAANwBjAGYAMgAzAGQAMwA3ADIAMgA4ADYANQBkAGQANgBiADEAOABjAGQANABmAGQAOABmAGEAOABmADAAZAAzADMAMQA4ADYAZgA3ADAAYwAwAGUAMQBhADcANABlADkANQA2ADEAZgAwAGMAYwA4ADQAMAA0ADAANAA0AGMAOAAyAGEAMQBlAGIAYgBkAGIAZgAyADQAMQBiAGUAOABlADEAMAA0ADIAZQA1ADgAOAA2AGMANwA2ADMAYQAwAGIAOAAxAGQAMQBlADYAZQBmAGQAMQBkAGYAZQA4AGQAZgAwADAAMABhADAAMAAyAGQAMAAzAGEAZAAxADIAMgA5ADgAYQAzAGUAYgA5AGIAZQBkADAAYgA1ADYAYwA1AGEAOABjADQAZABlAGEAZABkADYAMAAxAGEANAAyADkANgA2ADEANgAwAGYANABhADYAMQA2ADEAZABjAGYAOAA0ADAAZgAwADIAZQA1ADAAOQBjADEANgA1ADkANwBmAGIAZQAwADUANgBiADMAYQBmAGMANgAzAGYAMAAwADcAZQAzADcAMgBmADYAYwA4AGEAMAAyADEAZAAwADIAOAA1AGMAOQBmAGYAOAA2AGMAYgA2ADAANwAxADIAMQA5AGYAZAAyADQAZAA5AGQAYgA4ADMANgBhADkAYgA2ADgAYwA2ADYAMwBmADMAOABjADgAMQBlAGEAYQA1AGEAZgA4AGEAYQBmADIAZQBlAGYAZQAxADQAMQBmADYAYQA4ADEAZgBkADcANgA4ADIAZQA5ADIAYQAwADAAYQBhADEAOQAwADYAZgBkADMANQBmADgAOAA2ADAAMgBlAGMAMwAwAGEAYgA5ADIANwAwADMAOAAzADgANQAwADYAMwBmADEAMgA2ADIAYwAxAGUAMAA2ADMANwBmADcANQAzADAANwBiADMAZABiADMAMABlADUANQAyADQAZgAzADUAMwBlAGYAZABkADQAMgA1AGYAOQA5ADgAZQBmAGIAOAAzAGQAZgBkAGIAYgBmADIAMAA2AGEANgBmADcAZQBhAGYAOQBmAGIAMwBiADQAMwA5ADkAMABiADcAYwAzADAANAA0ADIAOQBjADgAMgBlADAAMQBlADMAMQAwADAAYQA1ADgANgBjADcAMwBjADcAZgBjADkANQBjAGIAZAA5AGQANAA1AGEAMgBlADYAOQBjADEAYwAyAGUAZgBjAGUAYwA2ADUAMQAxADcAMQA0AGIAYgAyAGQAZgA1AGMAMQAxAGUAYwA4AGUANAA2ADIAMABhADMAMgBkADcANwA2ADUANABkADkAZgA3AGYAZQBiADMAMQBkAGYAYwA5ADgAZgAzAGEAYQAzAGQANwBiAGQAMQAwADEAMwBkADIANwBhAGUANgA4ADIAMwBmAGUAMwBlADcAZAAwAGIANQBlADYAYwBlADEANwBiADkANAAwAGUANAAxADcAYgBmADcAMwA5ADMAOAA0ADcANgBmADYAMwAyADkANgBhADYAMAA4ADkAMABiAGUANwA2ADYANAAyAGQANwA3AGIAOAA1ADUAZgBlAGEAZgBiAGMAMgA5ADMAMQA4AGMAYgAyADcAOABmADAAYQAzADEANgA0AGQANAAxADAANwAzAGQAMwA1ADUAZgA1AGQAYwBlAGQANQAxADQAOQA1AGQAYwAzAGMANQBiAGUAYgAzADEAZQBjAGYAMwAyADEAOAA3ADYAOAA1ADIAYgBlAGUAOAAzADkAMgBkAGQAYQBiAGEAYQA5AGMAMQAxADUANwBhAGYANABmAGEAOQAwAGYAMAA4ADUAOQA0ADQAZABkADkAYwA3ADEAOAAxAGMANQA4AGEAMgA2AGUAZQAzADQANgA3ADQAMgA2ADYAZgA3ADcAMgA1ADAAMgAxADEAMwAzADgANAAwAGEAMgA2ADMAMwA5ADkAOABjAGYAMAA1ADAAYQA2AGYANgAzADYAYQBiAGUAMQBlADUAZAAwADkAMwAwADYANQA0AGUANAAwADMAMQBhADgAOQA1ADQAZgA3AGIAOQA1AGEAMQAyAGIANgA5ADIAYgBmADAAZAA0AGMAMQBkADgAMwBkADQANwA2ADAAMwA0ADUAZgBhADQAYQA4ADcAMwA0ADQAOAAzADMAYgA2ADEAMwAzADQAZAAzADQAZQAzAGYAYQAwADEAYQAwAGMANwBiADgAZgA1ADIAZgA4AGYAMQA0ADQAMQAyAGUANABmAGQAMwAxAGEAMAA0ADgAMAA1AGMANgBiADYAYQBjAGIANABkADMAMAA1ADEAOQA2AGMANAA1ADYAZgAwAGEAMgBlADMAOQA2AGQAMwBjAGQAYQBkAGUAZABiAGYAMgBkADQAMAAzADEAMQA1AGUAZgAzAGIANABhADAANAA3AGEAMQAzADgAMgAxADkAMQA4ADQAOABkADcAMwAwADcANAAyAGMANAAwADgANgA2ADAAYwAwADMAOQA2ADAANgA1AGYANwBlAGMAZgAyAGYAMwA2ADQAMAA0AGQANgA1AGQAZAAyAGQAYgA5ADcAMwBiAGQAZQBkAGQAOAA4AGEAOQA4ADgAMgA4ADcAMwBlAGUANQAzADgAYQAzAGQANwAzADcANABkADgAMQA="
```

<br /><br />

## :octocat: Special thanks

|Name|Description|
|---|---|
|@shanty damayanti|Debugging cmdlet|
|@Saâd Ahla|Debugging cmdlet|
|@Daniel_Durnea|Debugging cmdlet|

<br />

**Anatomy of a decrypt script**
![anatomy](https://user-images.githubusercontent.com/23490060/157081056-70bcb061-4015-41c4-a775-f716afdc4696.jpg)


<br />

## :octocat: SSA RedTeam @2022
