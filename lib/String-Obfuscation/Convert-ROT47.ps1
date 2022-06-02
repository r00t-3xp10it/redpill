<#
.SYNOPSIS
    Rotate ascii chars by n places (Caesar cipher)

   Author: @r00t-3xp10it
   Addapted from: @BornToBeRoot
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
    Rotate ascii chars by n places (Caesar cipher). You can encrypt with the parameter "-Encrypt"
    or decrypt with the parameter "-Decrypt", depens on what you need. Decryption is selected by default.

.NOTES
    Try the parameter "-UseAllAsciiChars" if you have a string with umlauts which e.g. (German language). 

.EXAMPLE
    .\Convert-ROT47.ps1 -Text "This is an encrypted string!" -Rot 7 -Encrypt

    Rot Text
    --- ----
      7 [opz pz hu lujy"w{lk z{ypun(

.EXAMPLE
    .\Convert-ROT47.ps1 -Text '[opz pz hu lujy"w{lk z{ypun(' -Rot (5..10) -Encrypt

    Rot Text
    --- ----
      5 Vjku ku cp gpet{rvgf uvtkpi#
      6 Uijt jt bo fodszqufe tusjoh"
      7 This is an encrypted string!
      8 Sghr hr `m dmbqxosdc rsqhmf~
      9 Rfgq gq _l clapwnrcb qrpgle}
     10 Qefp fp ^k bk`ovmqba pqofkd|

.EXAMPLE
    .\Convert-ROT47.ps1 -Text "Beispiel: Cäsar-Verschlüsselung - Sprache Deutsch!" -Rot 3 -Encrypt -UseAllAsciiChars

    Rot Text
    --- ----
      3 Ehlvslho= Fçvdu0Yhuvfkoÿvvhoxqj 0 Vsudfkh Ghxwvfk$

.EXAMPLE
    .\Convert-ROT47.ps1 -Text "Ehlvslho= Fçvdu0Yhuvfkoÿvvhoxqj 0 Vsudfkh Ghxwvfk$" -Rot (1..4) -Encrypt -UseAllAsciiChars

    Rot Text
    --- ----
      1 Dgkurkgn< Eæuct/Xgtuejnþuugnwpi / Urtcejg Fgwvuej#
      2 Cfjtqjfm; Dåtbs.Wfstdimýttfmvoh . Tqsbdif Efvutdi"
      3 Beispiel: Cäsar-Verschlüsselung - Sprache Deutsch!
      4 Adhrohdk9 Bãr`q,Udqrbgkûrrdktmf , Roq`bgd Cdtsrbg

.EXAMPLE
    .\Convert-ROT47.ps1 -Text "This is an encrypted string!" -rot 4 -Encrypt

    Rot Text
    --- ----
      4 Xlmw mw er irgv}txih wxvmrk%

.EXAMPLE
    .\Convert-ROT47.ps1 -Text "Xlmw mw er irgv}txih wxvmrk%" -rot 4 -Decrypt

    Rot Text
    --- ----
      4 This is an encrypted string!

.EXAMPLE
    .\Convert-ROT47.ps1 -Text "whoami" -Rot "7" -Action "decryptme" -Encrypt
    Convert text to rot7 and build the decrypt script (decryptme.ps1)
      
.LINK
   https://github.com/r00t-3xp10it/redpill/tree/main/lib/String-Obfuscation#convert-rot47ps1
   https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Script/Convert-ROT47.README.md
#>


[CmdletBinding(DefaultParameterSetName='Decrypt')]
param (
    [Parameter(
        Mandatory=$false,
        HelpMessage='Execute the encrypted string?')]    
        [String]$Action="Normal",

    [Parameter(
        Mandatory=$true,
        HelpMessage='String which you want to encrypt or decrypt')]    
        [String]$Text,

    [Parameter(
        HelpMessage='Specify which rotation you want to use (Default=1..10)')]
        [ValidateRange(1,10)]
        [Int32[]]$Rot=1..10,

    [Parameter(
        ParameterSetName='Encrypt',
        HelpMessage='Encrypt a string?')]
        [switch]$Encrypt,
    
    [Parameter(
        ParameterSetName='Decrypt',
        HelpMessage='Decrypt a string?')]
        [switch]$Decrypt,

    [Parameter(
        HelpMessage='Use complete ascii table 0..255 chars (Default=33..126)')]
        [switch]$UseAllAsciiChars
)


Begin{
    [System.Collections.ArrayList]$AsciiChars = @()
     
    $CharsIndex = 1    
    $StartAscii = 33
    $EndAscii = 126
    $cmdletVersion = "v1.0.1"

    $Banner = @"

    ________  ________  _________    
   |\   __  \|\   __  \|\___   ___\   
   \ \  \|\  \ \  \|\  \|___ \  \_| 
    \ \   _  _\ \  \\\  \   \ \  \
     \ \  \\  \\ \  \\\  \   \ \  \ 
      \ \__\\ _\\ \_______\   \ \__\ 
       \|__|\|__|\|_______|    \|__| $cmdletVersion
        Convert-ROT47 Working Dir: '$pwd'

"@;

    Clear-Host
    Write-Host "$Banner`n" -ForegroundColor Blue
    #Use all ascii chars (useful for languages like german)
    if($UseAllAsciiChars)
    {
        $StartAscii = 0
        $EndAscii = 255

        Write-Host "Warning: Parameter -UseAllAsciiChars will use all chars from 0 to 255 in the ascii table. This may not work properly, but could be usefull to encrypt or decrypt languages like german with umlauts!" -ForegroundColor Yellow
    }

    #Add chars from ascii table
    ForEach($i in $StartAscii..$EndAscii)
    {
        $Char = [char]$i
        [pscustomobject]$Result = @{
            Index = $CharsIndex
            Char = $Char
        }   

        [void]$AsciiChars.Add($Result)
        $CharsIndex++
    }

    #Default mode is "Decrypt"
    If(($Encrypt -eq $false -and $Decrypt -eq $false) -or ($Decrypt)) 
    {        
        $Mode = "Decrypt"
    }    
    Else 
    {
        $Mode = "Encrypt"
    }
    Write-Verbose -Message "Mode is set to: $Mode"
}

Process{
    ForEach($Rot2 in $Rot)
    {        
        $ResultText = [String]::Empty
        #Go through each char in string
        ForEach($i in 0..($Text.Length -1))
        {
            $CurrentChar = $Text.Substring($i, 1)
            If(($AsciiChars.Char -ccontains $CurrentChar) -and ($CurrentChar -ne " ")) # Upper chars
            {
                If($Mode -eq "Encrypt")
                {                    
                    [int]$NewIndex = ($AsciiChars | Where-Object {$_.Char -ceq $CurrentChar}).Index + $Rot2
                    If($NewIndex -gt $AsciiChars.Count)
                    {
                        $NewIndex -= $AsciiChars.Count                     
                        $ResultText +=  ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char
                    }
                    Else 
                    {
                        $ResultText += ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char    
                    }
                }
                Else 
                {
                    [int]$NewIndex = ($AsciiChars | Where-Object {$_.Char -ceq $CurrentChar}).Index - $Rot2
                    If($NewIndex -lt 1)
                    {
                        $NewIndex += $AsciiChars.Count
                        $ResultText +=  ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char
                    }
                    Else 
                    {
                        $ResultText += ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char    
                    }
                }   
            }
            Else 
            {
                $ResultText += $CurrentChar  
            }
        } 
    

        If($Action -ieq "decryptme")
        {
        
        #EScaping special chars in obfucated string
        $ResultText = $ResultText -replace '"','`"'

$PS1DecriptRot = @("<#
.SYNOPSIS
   Author: r00t-3xp10it
   Helper - Execute rot$Rot cipher! 
#>

Begin{
    [Int32[]]`$Rot=$Rot
    [string]`$Text=`"$ResultText`"
    [System.Collections.ArrayList]`$AsciiChars = @()
     
    `$CharsIndex = 1
    `$StartAscii = 33
    `$EndAscii = 126
    #Add chars from ascii table
    ForEach(`$i in `$StartAscii..`$EndAscii)
    {
        `$Char = [char]`$i
        [pscustomobject]`$Result = @{
            Index = `$CharsIndex
            Char = `$Char
        }   
        [void]`$AsciiChars.Add(`$Result)
        `$CharsIndex++
    }
}

Process{
    ForEach(`$Rot2 in `$Rot)
    {        
        `$ResultText = [String]::Empty
        #Go through each char in string
        ForEach(`$i in 0..(`$Text.Length -1))
        {
            `$CurrentChar = `$Text.Substring(`$i, 1)
            If((`$AsciiChars.Char -ccontains `$CurrentChar) -and (`$CurrentChar -ne `" `")) # Upper chars
            {
               [int]`$NewIndex = (`$AsciiChars | Where-Object {`$_.Char -ceq `$CurrentChar}).Index - `$Rot2
               If(`$NewIndex -lt 1)
               {
                  `$NewIndex += `$AsciiChars.Count                       
                  `$ResultText +=  (`$AsciiChars | Where-Object {`$_.Index -eq `$NewIndex}).Char
               }
               Else 
               {
                  `$ResultText += (`$AsciiChars | Where-Object {`$_.Index -eq `$NewIndex}).Char    
               }
            }Else{`$ResultText += `$CurrentChar}
        } 
    
       Try{#EXECUTE
          If(`$ResultText -iMatch '^(iex\(iwr\()'){Powershell -Command `"`$ResultText`"}Else{echo `"`$ResultText`"|&(DIR Alias:/I*X)}
       }Catch{Write-Host `"x Error: execution failed ..`" -ForeGroundColor red}
    }
}")

           #Write Ps1 script to the sellected directory!
           echo "$PS1DecriptRot"|Out-File "$pwd\Decryptme.ps1" -encoding ascii -force

           Write-Host "`n*" -ForegroundColor Green -NoNewline;
           Write-Host " Converted String   : '" -ForegroundColor DarkGray -NoNewline;
           Write-Host "$ResultText" -ForegroundColor DarkYellow -NoNewline;
           Write-Host "'" -ForegroundColor DarkGray;

           Write-Host "*" -ForegroundColor Green -NoNewline;
           Write-Host " Decryption Routine : '" -ForegroundColor DarkGray -NoNewline;
           Write-Host "$pwd\Decryptme.ps1" -ForegroundColor Green -NoNewline;
           Write-Host "'`n" -ForegroundColor DarkGray;
        
        }
        Else
        {

           ## Display List format if string
           # its bigger than 100 chars ..
           If(($ResultText.Length) -ge 100)
           {
              write-host "`nRot  : " -NoNewline
              write-host "$Rot" -ForegroundColor DarkGray
              write-host "Text : " -NoNewline
              write-host "$ResultText`n" -ForegroundColor DarkGray
           }
           Else
           {
              ## Display Table if string
              # its smaller than 100 chars
              [pscustomobject] @{
                  Rot = $Rot2
                  Text = $ResultText
              }
           }

        }
    }
}

End{

}
