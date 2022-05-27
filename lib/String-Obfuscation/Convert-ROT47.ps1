###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Convert-ROT47.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Rotate ascii chars by n places (Caesar cipher)
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
.SYNOPSIS
    Rotate ascii chars by n places (Caesar cipher)

.DESCRIPTION
    Rotate ascii chars by n places (Caesar cipher). You can encrypt with the parameter "-Encrypt"
    or decrypt with the parameter "-Decrypt", depens on what you need. Decryption is selected by default.

.NOTES
    Try the parameter "-UseAllAsciiChars" if you have a string with umlauts which e.g. (German language). 

.EXAMPLE
    .\Convert-ROT47.ps1 -Text "This is an encrypted string!" -Rot 7

    Rot Text
    --- ----
      7 [opz pz hu lujy"w{lk z{ypun(

.EXAMPLE
    .\Convert-ROT47.ps1 -Text '[opz pz hu lujy"w{lk z{ypun(' -Rot (5..10)

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
    .\Convert-ROT47.ps1 -Text "Ehlvslho= Fçvdu0Yhuvfkoÿvvhoxqj 0 Vsudfkh Ghxwvfk$" -Rot (1..4) -UseAllAsciiChars

    Rot Text
    --- ----
      1 Dgkurkgn< Eæuct/Xgtuejnþuugnwpi / Urtcejg Fgwvuej#
      2 Cfjtqjfm; Dåtbs.Wfstdimýttfmvoh . Tqsbdif Efvutdi"
      3 Beispiel: Cäsar-Verschlüsselung - Sprache Deutsch!
      4 Adhrohdk9 Bãr`q,Udqrbgkûrrdktmf , Roq`bgd Cdtsrbg

.EXAMPLE
    .\Convert-ROT47.ps1 -Text "This is an encrypted string!" -rot 4 -encrypt

    Rot Text
    --- ----
      4 Xlmw mw er irgv}txih wxvmrk%

.EXAMPLE
    .\Convert-ROT47.ps1 -Text "Xlmw mw er irgv}txih wxvmrk%" -rot 4 -decrypt

    Rot Text
    --- ----
      4 This is an encrypted string!
      
.LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Script/Convert-ROT47.README.md
#>

[CmdletBinding(DefaultParameterSetName='Decrypt')]
param (
    [Parameter(
        Position=0,
        Mandatory=$true,
        HelpMessage='String which you want to encrypt or decrypt')]    
    [String]$Text,

    [Parameter(
        Position=1,
        HelpMessage='Specify which rotation you want to use (Default=1..47)')]
    [ValidateRange(1,47)]
    [Int32[]]$Rot=1..47,

    [Parameter(
        ParameterSetName='Encrypt',
        Position=2,
        HelpMessage='Encrypt a string')]
    [switch]$Encrypt,
    
    [Parameter(
        ParameterSetName='Decrypt',
        Position=2,
        HelpMessage='Decrypt a string')]
    [switch]$Decrypt,

    [Parameter(
        Position=3,
        HelpMessage='Use complete ascii table 0..255 chars (Default=33..126)')]
    [switch]$UseAllAsciiChars
)

Begin{
    [System.Collections.ArrayList]$AsciiChars = @()
     
    $CharsIndex = 1
    
    $StartAscii = 33
    $EndAscii = 126

    # Use all ascii chars (useful for languages like german)
    if($UseAllAsciiChars)
    {
        $StartAscii = 0
        $EndAscii = 255

        Write-Host "Warning: Parameter -UseAllAsciiChars will use all chars from 0 to 255 in the ascii table. This may not work properly, but could be usefull to encrypt or decrypt languages like german with umlauts!" -ForegroundColor Yellow
    }

    # Add chars from ascii table
    foreach($i in $StartAscii..$EndAscii)
    {
        $Char = [char]$i

        [pscustomobject]$Result = @{
            Index = $CharsIndex
            Char = $Char
        }   

        [void]$AsciiChars.Add($Result)

        $CharsIndex++
    }

    # Default mode is "Decrypt"
    if(($Encrypt -eq $false -and $Decrypt -eq $false) -or ($Decrypt)) 
    {        
        $Mode = "Decrypt"
    }    
    else 
    {
        $Mode = "Encrypt"
    }

    Write-Verbose -Message "Mode is set to: $Mode"
}

Process{
    foreach($Rot2 in $Rot)
    {        
        $ResultText = [String]::Empty

        # Go through each char in string
        foreach($i in 0..($Text.Length -1))
        {
            $CurrentChar = $Text.Substring($i, 1)

            if(($AsciiChars.Char -ccontains $CurrentChar) -and ($CurrentChar -ne " ")) # Upper chars
            {
                if($Mode -eq  "Encrypt")
                {                    
                    [int]$NewIndex = ($AsciiChars | Where-Object {$_.Char -ceq $CurrentChar}).Index + $Rot2 
                    
                    if($NewIndex -gt $AsciiChars.Count)
                    {
                        $NewIndex -= $AsciiChars.Count                     
                    
                        $ResultText +=  ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char
                    }
                    else 
                    {
                        $ResultText += ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char    
                    }
                }
                else 
                {
                    [int]$NewIndex = ($AsciiChars | Where-Object {$_.Char -ceq $CurrentChar}).Index - $Rot2 

                    if($NewIndex -lt 1)
                    {
                        $NewIndex += $AsciiChars.Count                     
                    
                        $ResultText +=  ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char
                    }
                    else 
                    {
                        $ResultText += ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char    
                    }
                }   
            }
            else 
            {
                $ResultText += $CurrentChar  
            }
        } 
    
        [pscustomobject] @{
            Rot = $Rot2
            Text = $ResultText
        }
    }
}

End{

}
        