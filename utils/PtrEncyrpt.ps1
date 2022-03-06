<#
.SYNOPSIS
   Encrypt or decrypt strings using a secretkey.
    
   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: ConvertTo-SecureString {native}
   Optional Dependencies: Decrypt-String.ps1
   PS cmdlet Dev version: v1.0.8
   
.DESCRIPTION
   This cmdlet allow users to encrypt text\commands\scripts.ps1 with the help
   of ConvertTo-SecureString cmdlet and a secretkey of 113 bytes length, it
   outputs results on console,logfile or builds a decrypt.ps1 script with the
   decrypt function routine to be abble to execute the encrypted string...

.NOTES
   If invoked -RandomByte 'true' then cmdlet random generates the SecretKey.
   But in that ocassion the Decrypt-String.ps1 cmdlet will not work unless the
   comrrespondent secretkey ( the same secretkey used to encrypt ) its invoked.
   Remark: Parameter -secretKey '12,17,254' can be invoked on Decrypt-String
   cmdlet to input the required secretKey used by Encrypt-String.ps1 cmdlet.
   
.Parameter Action
   Accepts arguments: console, autodecrypt, log (default: console)

.Parameter PlainTextString
   The string\text\command to encrypt (default: whoami)

.Parameter InFile
   Get the string to encrypt from txt\ps1 (default: false)

.Parameter OutFile
   Decrypt routine script name (default: decrypt)

.Parameter RandomByte
   Random secretkey generation (default: false)

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
   PS C:\> .\Encrypt-String.ps1 -action "autodecrypt" -infile "test.ps1" -outfile "Obfuscated"
   Encrypt the contents of 'test.ps1' and build auto-decrypt routine function Obfuscated.ps1

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
   https://github.com/r00t-3xp10it/redpill/tree/main/utils/encrypt_decrypt/Encrypt-String.ps1
   https://github.com/r00t-3xp10it/redpill/tree/main/utils/encrypt_decrypt/Decrypt-String.ps1
#>


#CmdLet Global variable declarations!
 [CmdletBinding(PositionalBinding=$false)] param(
   [string]$PlainTextString="whoami",
   [string]$RandomByte="false",
   [string]$OutFile="decrypt",
   [string]$Action="console",
   [string]$InFile="false",
   [string]$Egg="false"
)


$cmdletVersion = "v1.0.8"
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@ptr-chiper $cmdletVersion {SSA@RedTeam}"
If($Egg -ieq "false")
{
   write-host "`n* Powershell Ptr chiper cmdlet." -ForegroundColor Green
}

If($RandomByte -ieq "True")
{
   [byte]$RoolTheDiceAgain = Get-Random -Minimum 250 -Maximum 255
}
Else
{
   [byte]$RoolTheDiceAgain = 253
}

#Encryption key (secretkey 113 bytes)
[Byte[]]$SecretKey = 117,9,103,192,133,20,53,149,82,95,108,34,82,224,226,220,56,68,133,120,139,241,176,239,171,54,231,205,83,57,51,$RoolTheDiceAgain
$DisplaySecret = "117,9,103,192,133,20,53,149,82,95,108,34,82,224,226,220,56,68,133,120,139,241,176,239,171,54,231,205,83,57,51,$RoolTheDiceAgain"
$CountBytes = [System.Text.Encoding]::UTF8.GetByteCount($SecretKey)


If($InFile -ne "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Get sourcecode to convert from script.ps1|.txt

   .NOTES
      This function allow attackers to convert the contents
      of -infile 'path\to\file' to be converted into a string.
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
   echo "$EncryptedString"|Out-File "$pwd\Encrypt-String.log" -encoding ascii -force

   If($Egg -ieq "false")
   {
      write-host "*" -ForegroundColor Green -NoNewline;
      Write-Host " Decrypt routine written to: '" -ForegroundColor DarkGray -NoNewline;
      Write-Host "$pwd\Encrypt-String.log" -ForegroundColor Green -NoNewline;
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

   #Executing encrypted string
   echo `"`$String`"|&((echo `"0i0E0x`") -replace '0','') #Execute DeCrypted string
}
Catch{Throw `$_}")


   $OutFile = "$OutFile"+".ps1" -join ''
   #Write logfile to the sellected directory!
   echo "$PS1DecriptRot"|Out-File "$pwd\$OutFile" -encoding ascii -force

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
   } 

}


If($Egg -ieq "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Print Output OnScreen.
   #>

   $PtrTable = New-Object System.Data.DataTable
   $PtrTable.Columns.Add("OriginalStringChars")|Out-Null
   $PtrTable.Columns.Add("SecretKeyByteLength")|Out-Null
   $PtrTable.Columns.Add("ConvertedStringChars")|Out-Null
   $PtrTable.Columns.Add("PlainTextString")|Out-Null
   If($RandomByte -ieq "True")
   {
      #Print secretkey if invoked -RandomByte 'true'
      $PtrTable.Columns.Add("RawSecretKey")|Out-Null   
   }


   If($RandomByte -ieq "True")
   {
      #Adding values to output DataTable!
      $PtrTable.Rows.Add("$Countlines",       ## Original string chars counter!
                         "$CountBytes",       ## Secret Key Bytes Length!
                         "$Chars",            ## Transformed string chars counter!
                         "$PlainTextString",  ## the original string to transform!
                         "$DisplaySecret"     ## Raw Secret Key!
      )|Out-Null
   }
   Else
   {
      #Adding values to output DataTable!
      $PtrTable.Rows.Add("$Countlines",       ## Original string chars counter!
                         "$CountBytes",       ## Secret Key Bytes Length!
                         "$Chars",            ## Transformed string chars counter!
                         "$PlainTextString"   ## the original string to transform!
      )|Out-Null
   }

   #Diplay output DataTable!
   $PtrTable | Format-List | Out-String -Stream | Select -Skip 1 | Select -SkipLast 3 | ForEach-Object {
   $stringformat = If($_ -Match '^(RawSecretKey)'){
      @{ 'ForegroundColor' = 'Green' }
   }
   Else
   {
      @{ 'ForegroundColor' = 'White' }
   }
   Write-Host @stringformat $_
   }
}
write-host "EncryptedString      : " -ForegroundColor white -NoNewline;
write-host "$EncryptedString`n" -ForegroundColor DarkGray