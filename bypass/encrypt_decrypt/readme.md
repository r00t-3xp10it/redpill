# EnCrypt\Decrypt strings using a SecretKey 

## :octocat: Project Description
This cmdlet allow users to encrypt text\commands\scripts.ps1 with the help<br />
of ConvertTo-SecureString cmdlet and a secretkey of 113 bytes length, it<br />
outputs results on console,logfile or builds a decrypt.ps1 script with the<br />
decrypt function routine to be abble to execute the encrypted string ..<br />

<br />

## :octocat: Notes
If invoked -RandomByte 'true' then cmdlet random generates SecretKey last<br />
byte. But in that ocassion the Decrypt-String cmdlet will not work unless the<br />
comrrespondent secretkey ( the same secretkey used to encrypt ) its invoked.<br />
Remark: Parameter -RandomByte '254' (secretkey last byte) can be invoked on<br />
Decrypt-String cmdlet to input the required secretKey used by Encrypt-String.<br />

<br />


