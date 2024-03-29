<#
.SYNOPSIS
   Decrypt strings with an 113 bytes secret key.
    
   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: ConvertTo-SecureString {native}
   Optional Dependencies: Encrypt-String.ps1
   PS cmdlet Dev version: v1.2.6
   
.DESCRIPTION
   This cmdlet allow users to Decrypt text\commands with the help of
   ConvertTo-SecureString cmdlet and a secretkey of 113 bytes length.
   It outputs results on console and executes the Decrypted String if
   invoked -action 'execute' parameter declaration ..

.NOTES
   Remark: Parameter -RandomByte '253' (secret key last byte) can be invoked on
   Decrypt-String cmdlet to input the required secretKey used by Encrypt-String
   
.Parameter Action
   Accepts arguments: console, execute (default: console)

.Parameter EncryptedString
   The string\text\command to be Decrypted by this cmdlet

.Parameter RandomByte
   Encrypt-String SecretKey Last Byte (default: 253)

.EXAMPLE
   PS C:\> Get-Help .\Decrypt-String.ps1 -full
   Access this cmdlet comment based help!

.EXAMPLE
   PS C:\> .\Decrypt-String.ps1 -action "console" -EncryptedString "76492d1116743f0423413b16050a5345MgB8AFMATgBFAG8AeABPAHkAVABUADcAMAAzAEYAagBaADkARgBNAGoASgBPAHcAPQA9AHwAMwAzAGUAMQA1ADcAMwA1ADcAYQBjAGIAOQBmADQAZgBjAGYAMwAyADcAZAA4AGQAYQAwAGMAMwA5ADcAMQBiAA=="
   Decrypt -EncryptedString 'string' command and print results onscreen

.EXAMPLE
   PS C:\> .\Decrypt-String.ps1 -action "console" -randombyte "250" -EncryptedString "76492d1116743f0423413b16050a5345MgB8AEIAVwBNAEIATQBCAHYAbwBGAGUASABqAGYAagA1ADYAbgBXADMAaAAwAEEAPQA9AHwAZABhADIAMQA4ADIANABlADkAYwBkAGMAYwBlAGQAOABkADkAOABmADQAMgAyADQAYgAwADIAOABiAGYAMQA2ADQAZAA3ADcAOQBkAGEAMwAwADgAOQBjADcANwA2ADQANgA0AGQAOQA5ADEANwBjADMAMwAzADcAMQA3ADcAZgBhAGIANQA5ADMAZAAyAGEAOQA2AGEAOQBlADgAYgA3ADkANAA3AGMAYwAzAGUANABiAGMAMQAxADcANAA5ADUAZgA3ADAAMABiAGEAMgAwADMAMgA1AGMANABkADYAYQA0ADQAMQA2AGEAYgA2ADkAMQBmADAANQAzADgANQAxADgAMwBlADcAMgBkADgAZgBkADQAMgBmAGMAMgA3ADIANgA1AGIAZQA0AGUANgA3ADkANQAyAGIAYQBjADIAMwBkAGEAOAA0AGUAYgA4AGIANQA1ADMAMgA1ADcAMAA3ADUAMABiAGEANgBiADcAOQA1ADAAZAA1AGQANAA2ADUA"
   Decrypt -EncryptedString 'string' command ( Using '250' as SecretKey last byte ) + print results onscreen

.EXAMPLE
   PS C:\> .\Decrypt-String.ps1 -action "execute" -randombyte "250" -EncryptedString "76492d1116743f0423413b16050a5345MgB8AEIAVwBNAEIATQBCAHYAbwBGAGUASABqAGYAagA1ADYAbgBXADMAaAAwAEEAPQA9AHwAZABhADIAMQA4ADIANABlADkAYwBkAGMAYwBlAGQAOABkADkAOABmADQAMgAyADQAYgAwADIAOABiAGYAMQA2ADQAZAA3ADcAOQBkAGEAMwAwADgAOQBjADcANwA2ADQANgA0AGQAOQA5ADEANwBjADMAMwAzADcAMQA3ADcAZgBhAGIANQA5ADMAZAAyAGEAOQA2AGEAOQBlADgAYgA3ADkANAA3AGMAYwAzAGUANABiAGMAMQAxADcANAA5ADUAZgA3ADAAMABiAGEAMgAwADMAMgA1AGMANABkADYAYQA0ADQAMQA2AGEAYgA2ADkAMQBmADAANQAzADgANQAxADgAMwBlADcAMgBkADgAZgBkADQAMgBmAGMAMgA3ADIANgA1AGIAZQA0AGUANgA3ADkANQAyAGIAYQBjADIAMwBkAGEAOAA0AGUAYgA4AGIANQA1ADMAMgA1ADcAMAA3ADUAMABiAGEANgBiADcAOQA1ADAAZAA1AGQANAA2ADUA"
   Decrypt -EncryptedString 'string' command ( Using '250' as SecretKey last byte ) + print results onscreen + execute decrypted string

.INPUTS
   None. You cannot pipe objects into Decrypt-String.ps1

.OUTPUTS
   * Powershell 113[bytes] chiper cmdlet.

   OriginalStringChars  : 42
   SecretKeyByteLength  : 113
   ConvertedStringChars : 616
   RawSecretKey         : 117,9,103,192,133,20,53,149,83,95,108,34,82,224,226,220,56,68,133,120,139,241,176,239,171,54,231,205,83,57,51,250
   EncryptedString      : 76492d1116743f0423413b16050a5345MgB8AFAAMABkAFIAUQA0AFEAaQBWAFkAQQBSAEgAaABMAEMAaQBnADYAYgBhAFEAPQA9AHwAZQBiAGQAMQBkADIANgA0AGE
   ANQBiAGYANgAzADUAMAA3AGIAMQA2ADMAZQA4ADAAYgBkADIAZQBmADgAMgA0AGIANABmAGMANAA1ADUAOAAzAGMAMwAzAGQAZQA0ADAAYQAzADgAYwA1ADgAYQAyAGYANwA5ADUAZgAwAGQAMwAzA
   DgAMgA2ADQAOABjADIANgBlADYANwAyADQAYgBkAGIAMgA0AGUAMgBkAGUAMQAxADIAMwAzADkANABiADYAMAAxAGUAYQAzADcAZAAxADcAOQBlAGQAOQA4AGEAZAAzAGYANAA1ADkAOQA3ADMAMQB
   hADMAZgBjADcAOABiADQAYwA3ADEAZQBhAGYAZgAyADgAYQBjADkAMgA2AGUAYQAyADcAYwBiADQAOQA1ADUAZgAzAGQAYwA1ADYANwAzAGIANwA4ADMAOAA1ADEAZgAyADIAMwBhADEAZAAyAGIAY
   wA4AGMANgA3ADMAMAA1ADUAMwBkADUAOAA2AGIA
   PlainTextString      : Netstat -ano|findstr ':443'|findstr /V '['
   
.LINK
   https://github.com/r00t-3xp10it/redpill/tree/main/bypass/encrypt_decrypt/Encrypt-String.ps1
   https://github.com/r00t-3xp10it/redpill/tree/main/bypass/encrypt_decrypt/Decrypt-String.ps1
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$EncryptedString="76492d1116743f0423413b16050a5345MgB8AFMATgBFAG8AeABPAHkAVABUADcAMAAzAEYAagBaADkARgBNAGoASgBPAHcAPQA9AHwAMwAzAGUAMQA1ADcAMwA1ADcAYQBjAGIAOQBmADQAZgBjAGYAMwAyADcAZAA4AGQAYQAwAGMAMwA5ADcAMQBiAA==",
   [string]$Action="console",
   [byte]$RandomByte='253'
)


$cmdletVersion = "v1.2.6"
$ErrorActionPreference = "SilentlyContinue"
$BruteIt = "False" #brute-force-2º-byte (dont change)
$BruteMe = "False" #brute-force-last-byte (dont change)
$Success = "False" #brute-force-last-byte (dont change)
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@Decrypt-String $cmdletVersion {SSA@RedTeam}"
write-host "`n* Powershell 113[bytes] chiper cmdlet." -ForegroundColor Green

If($Action -iNotMatch '^(console|execute)$')
{
   write-host "*" -ForegroundColor Red -BackgroundColor Black -NoNewline;
   write-host " Error: " -ForegroundColor DarkGray -BackgroundColor Black -NoNewline;
   write-host "wrong parameter argument input .." -ForegroundColor Red -BackgroundColor Black;
   Start-Sleep -Seconds 2;Get-Help .\Decrypt-String.ps1 -Full;exit
}


[byte]$Item = 9
## Decryption key (secretkey 113 bytes)
# MANUAL: Auto-brute-force-cmdlet-secret-key-last-byte
# write-host "  => Brute force secret Key last byte." -ForegroundColor Yellow
# [string]$lastbyteranges = @("240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255")
# $Token = $lastbyteranges.Split(',');$BruteMe = "True"
#
# MANUAL: Brute-Force secret key 2º byte range
# [string]$rangetwo = @("7,8,9,10,11,12,13,14,15,16,17")
# $ranges = $rangetwo.Split(',');$BruteIt = "True"
#
# ForEach($RandomByte in $Token) ## secret-key-last-byte
# {
#   ForEach($Item in $ranges)  ## secret-key-2º-byte
#   {
      [Byte[]]$SecretKey = 117,$Item,103,192,133,20,53,149,83,95,108,34,82,224,226,220,56,68,133,120,139,238,176,239,171,54,231,205,83,57,51,$RandomByte
      $DisplaySecret = "117,$Item,103,192,133,20,53,149,83,95,108,34,82,224,226,220,56,68,133,120,139,238,176,239,171,54,231,205,83,57,51,$RandomByte"
      $CountBytes = [System.Text.Encoding]::UTF8.GetByteCount($SecretKey)

      Try{
         $SecureString = ConvertTo-SecureString $EncryptedString -Key $SecretKey
         $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
         [string]$String = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
         [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
         #Auto-brute-force-cmdlet-secret-key-last-byte!
         If($String -and $BruteMe -ieq "True")
         {
            $Success = "True"        #Success
            $bruteId = "$RandomByte" #Last Byte bruted
            $Brutetw = $Item         #SK 2º Byte bruted
         }
      }
      Catch{Throw $_}
#   } ## ForEach() - Brute-force-2º-byte-of-secret-key
#} ## ForEach() - Auto-brute-force-secret-key-last-byte


If(-not($String) -or $String -ieq $null)
{
   [string]$ParseLastByte = $DisplaySecret.Split(',')[-1]                  # Get last byte of secretkey
   [string]$ParseFirsByte = $DisplaySecret -replace "$ParseLastByte",""    # Delete last byte of secretKey

   write-host "*" -ForegroundColor Red -BackgroundColor Black -NoNewline;
   write-host " Fail to Decrypt: " -ForegroundColor DarkGray -BackgroundColor Black -NoNewline;
   write-host "wrong 'EncryptedString' input?" -ForegroundColor Red -BackgroundColor Black;

   write-host "*" -ForegroundColor Red -BackgroundColor Black -NoNewline;
   write-host " Fail to Decrypt: " -ForegroundColor DarkGray -BackgroundColor Black -NoNewline;
   write-host "wrong secretkey last byte [" -ForegroundColor Red -BackgroundColor Black -NoNewline;
   write-host "$ParseLastByte" -ForegroundColor Yellow -BackgroundColor Black -NoNewline;
   write-host "] input?" -ForegroundColor Red -BackgroundColor Black;

   write-host "  => SecretKey: $ParseFirsByte" -ForegroundColor Green -NoNewline;
   write-host "$ParseLastByte`n" -ForegroundColor Yellow;
   exit
}

#Count how man chars does the 'original string' have!
$Countlines = ($String|measure -character).Characters.ToString()

#Count how many chars exist in encryption string!
$Chars = ($EncryptedString|measure -character).Characters.ToString()


If($Action -ieq "console")
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

   If($RandomByte -NotMatch 253)
   {
      ## Print SecretKey if invoked -RandomByte 'true' parameter and
      # colorize the last byte of secretkey to be used in Decrypt-String
      [string]$ParseLastByte = $DisplaySecret.Split(',')[-1]                # Get last byte of secretkey
      [string]$ParseFirsByte = $DisplaySecret -replace "$ParseLastByte",""  # Delete last byte of secretKey

      If($BruteIt -ieq "True")
      {
         #Randomization of secret key 2º byte
         [string]$ParsetwoBytes = $DisplaySecret.Split(',')[1]                 # Get 2º byte of secret key
         [string]$gfttttfttttft = $DisplaySecret -replace "17","$Brutetw"      # Replace the 2º byte of secret Key
         [string]$ParseFirsByte = "$gfttttfttttft"+"," -join ''                # Add , before last byte key
      }

      write-host "RawSecretKey         : $ParseFirsByte" -ForegroundColor Green -NoNewline;

      If($Success -ieq "True")
      {
         write-host "$bruteId" -ForegroundColor Red
      }
      Else
      {
         write-host "$ParseLastByte" -ForegroundColor Yellow
      }
   }

   write-host "EncryptedString      : " -ForegroundColor white -NoNewline;
   write-host "$EncryptedString" -ForegroundColor DarkGray
   write-host "PlainTextString      : " -ForegroundColor white -NoNewline;
   write-host "$String`n" -ForegroundColor DarkYellow

}
Else
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Print Output OnScreen + Execute Decrypted String.
   #>

   write-host ""
   write-host "OriginalStringChars  : $Countlines" -ForegroundColor white
   write-host "SecretKeyByteLength  : $CountBytes" -ForegroundColor white
   write-host "ConvertedStringChars : $Chars" -ForegroundColor white

   If($RandomByte -NotMatch 253)
   {
      ## Print SecretKey if invoked -RandomByte 'true' parameter and
      # colorize the last byte of secretkey to be used in Decrypt-String
      [string]$ParseLastByte = $DisplaySecret.Split(',')[-1]                # Get last byte of secretkey
      [string]$ParseFirsByte = $DisplaySecret -replace "$ParseLastByte",""  # Delete last byte of secretKey

      If($BruteIt -ieq "True")
      {
         #Randomization of secret key 2º byte
         [string]$ParsetwoBytes = $DisplaySecret.Split(',')[1]                 # Get 2º byte of secret key
         [string]$gfttttfttttft = $DisplaySecret -replace "17","$Brutetw"      # Replace the 2º byte of secret Key
         [string]$ParseFirsByte = "$gfttttfttttft"+"," -join ''                # Add , before last byte key
      }

      write-host "RawSecretKey         : $ParseFirsByte" -ForegroundColor Green -NoNewline;

      If($Success -ieq "True")
      {
         write-host "$bruteId" -ForegroundColor Red
      }
      Else
      {
         write-host "$ParseLastByte" -ForegroundColor Yellow
      }
   }

   write-host "EncryptedString      : " -ForegroundColor white -NoNewline;
   write-host "$EncryptedString" -ForegroundColor DarkGray
   write-host "PlainTextString      : " -ForegroundColor white -NoNewline;
   write-host "$String" -ForegroundColor DarkYellow
   write-host "ExecuteEncrypted     : `n" -ForegroundColor white;

   #Execute Decrypted string
   echo "$String"|&((echo "0i0E0x") -replace '0','')
   write-host ""
}