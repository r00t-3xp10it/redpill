<#
.SYNOPSIS
    Rotate ascii chars by nº places (Caesar cipher)

   Author: @r00t-3xp10it
   Addapted from: @BornToBeRoot
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: none
   Optional Dependencies: System.IO.File {native}
   PS cmdlet Dev version: v1.0.8

.DESCRIPTION
    Rotate ascii chars by nº places (Caesar cipher). You can encrypt invoking -Encrypt
    parameter (default) or decrypt invoking parameter -Decrypt. Depends on what you need.

.NOTES
    Remark: When invoking -action 'decryptme' parameter. We need to test if 'decryptme.ps1'
    executes successfuly. If 'NOT' then try to create it invoking a diferent ROT rotation.
    Remark: Try using single quotes ['] in -text 'string' parameter everytime its possible OR
    else its required to escape special chars like: ` $ " on -Text 'string' -Decrypt function.

.EXAMPLE
    .\Convert-ROT47.ps1 -Text 'This is an encrypted string!' -Rot (5..10) -Encrypt

    Rot Text
    --- ----
      5 Ymnx nx fs jshw~uyji xywnsl&
      6 Znoy oy gt ktix!vzkj yzxotm'
      7 [opz pz hu lujy"w{lk z{ypun(
      8 \pq{ q{ iv mvkz#x|ml {|zqvo)
      9 ]qr| r| jw nwl{$y}nm |}{rwp*
     10 ^rs} s} kx oxm|%z~on }~|sxq+

.EXAMPLE
    .\Convert-ROT47.ps1 -Text 'This is an encrypted string!' -rot 4 -Encrypt

    Rot Text
    --- ----
      4 Xlmw mw er irgv}txih wxvmrk%

.EXAMPLE
    .\Convert-ROT47.ps1 -Text 'Xlmw mw er irgv}txih wxvmrk%' -rot 4 -Decrypt

    Rot Text
    --- ----
      4 This is an encrypted string!

.EXAMPLE
    .\Convert-ROT47.ps1 -Text "netstat -ano|findstr 'ESTABLISHED'|findstr /V '['" -Rot '7' -Action 'decryptme' -Encrypt
    Convert text to rot7 and build the decrypt script (decryptme.ps1)

    * ROT rotation       : [7] chars
    * Raw String Length  : [49] chars
    * Text Raw String    : 'netstat -ano|findstr 'ESTABLISHED'|findstr /V '[''
    * Converted String   : 'ul{z{h{ 4huv%mpukz{y .LZ[HISPZOLK.%mpukz{y 6] .b.'
    * Decryption Routine : 'C:\Users\pedro\OneDrive\Ambiente de Trabalho\RedTeam-Library\String-Obfuscation\Decryptme.ps1'

.EXAMPLE
    .\Convert-ROT47.ps1 -Infile "$pwd\payload.ps1" -Rot '8' -Action 'decryptme' -Encrypt
    This function allow attackers to converts the contents of -infile 'path\to\file'
    into a rot string, and builds the PS1 decrypt script that executes the sourcecode.

    * ROT rotation       : [8] chars
    * Raw String Length  : [2538] chars
    * Text Raw String    : 'blablabla'
    * Converted String   : 'blablabla'
    * Decryption Routine : 'C:\Users\pedro\OneDrive\Ambiente de Trabalho\RedTeam-Library\String-Obfuscation\Decryptme.ps1'

.LINK
   https://github.com/r00t-3xp10it/redpill/tree/main/lib/String-Obfuscation#convert-rot47ps1
   https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Script/Convert-ROT47.README.md
#>


[CmdletBinding(DefaultParameterSetName='Encrypt')]
param (
    [Parameter(
        Mandatory=$false,
        HelpMessage='Execute the encrypted string?')]    
        [String]$Action="Normal",

    [Parameter(
        Mandatory=$false,
        HelpMessage='Get sourcecode to convert from TXT\PS1?')]    
        [String]$InFile="false",

    [Parameter(
        Mandatory=$false,
        HelpMessage='String which you want to encrypt or decrypt')]    
        [String]$Text,

    [Parameter(
        HelpMessage='Specify which rotation you want to use (Default=1..47)')]
        [ValidateRange(1,47)]
        [Int32[]]$Rot=1..47,

    [Parameter(
        ParameterSetName='Encrypt',
        HelpMessage='Encrypt a string?')]
        [switch]$Encrypt,
    
    [Parameter(
        ParameterSetName='Decrypt',
        HelpMessage='Decrypt a string?')]
        [switch]$Decrypt
)


Begin{
     
    $CharsIndex = 1    
    $StartAscii = 33
    $EndAscii = 126

    $cmdletVersion = "v1.0.8"
    $host.UI.RawUI.WindowTitle = "@Convert-ROT47 $CmdletVersion {SSA@RedTeam}"
    [System.Collections.ArrayList]$AsciiChars = @()

    If(-not($Text) -and $InFile -ieq "false")
    {
       Write-Host "`nx" -ForegroundColor Red -NoNewline;
       Write-Host " Error: CmdLet requires " -ForegroundColor DarkGray -NoNewline;
       Write-Host "-text 'string'" -ForegroundColor Red -NoNewline;
       Write-Host " OR " -ForegroundColor DarkGray -NoNewline;
       Write-Host "-infile 'file.ps1'" -ForegroundColor Red -NoNewline;
       Write-Host " parameters.`n" -ForegroundColor DarkGray;
       Start-Sleep -Seconds 2
       Get-help .\Convert-ROT47.ps1 -Examples
       exit
    }

    $Banner = @"

    ________  ________  _________    
   |\   __  \|\   __  \|\___   ___\   
   \ \  \|\  \ \  \|\  \|___ \  \_| 
    \ \   _  _\ \  \\\  \   \ \  \
     \ \  \\  \\ \  \\\  \   \ \  \ 
      \ \__\\ _\\ \_______\   \ \__\ 
       \|__|\|__|\|_______|    \|__|47 $cmdletVersion
        Convert-ROT47:'$pwd'

"@;

    Clear-Host
    Write-Host "$Banner`n" -ForegroundColor Blue
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

    #Default mode is "Encrypt"
    If(($Encrypt -eq $false -and $Decrypt -eq $false) -or ($Encrypt)) 
    {        
        $Mode = "Encrypt"
    }    
    Else 
    {
        $Mode = "Decrypt"
    }
    Write-Verbose -Message "Mode is set to: $Mode"

    If($InFile -ne "false")
    {
       <#
       .SYNOPSIS
          Author: @r00t-3xp10it
          Helper - Get sourcecode to convert from TXT\PS1

       .NOTES
          This function allow attackers to converts the contents of -infile 'path\to\file'
          into a rot strings, and builds the PS1 decrypt script that executes sourcecode.
       #>

       #Check for cmdlet dependencies!
       If(-not(Test-Path -Path "$InFile" -EA SilentlyContinue))
       {
          Write-Host "`nx" -ForegroundColor Red -NoNewline;
          Write-Host " Notfound: '" -ForegroundColor DarkGray -NoNewline;
          Write-Host "$InFile" -ForegroundColor Red -NoNewline;
          Write-Host "'`n" -ForegroundColor DarkGray;
          exit
       }
       If($InFile -iNotMatch '(.ps1|.txt)$')
       {
          Write-Host "`nx" -ForegroundColor Red -NoNewline;
          Write-Host " Error: This function only accepts '" -ForegroundColor DarkGray -NoNewline;
          Write-Host ".ps1 OR .txt" -ForegroundColor Red -NoNewline;
          Write-Host "' file formats.`n" -ForegroundColor DarkGray;
          exit
       }

       #ProgressBar settings
       $CurrentItem = 0                   #ProgressBar
       $PercentComplete = 0               #ProgressBar
       $DataBase = Get-content "$InFile"  #ProgressBar
       $TotalItems = $DataBase.Count      #ProgressBar

       write-host "* Reading file contents ..." -ForegroundColor Green
       #Get the cmdline\string to convert to rot from txt\ps1 file!

       ForEach($EachItem in $DataBase)
       {
          $CurrentItem++
          #ProgressBar of query percentage complete ...
          Write-Progress -Activity "String: '$EachItem'" -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
          $PercentComplete = [int](($CurrentItem / $TotalItems) * 100)
          [string]$Text = [System.IO.File]::ReadAllText("$InFile")
       }

    }

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
        $ResultText = $ResultText -replace '\$','`$' -replace '"','`"'

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
    
       Try{#EXECUTE CmdLet
          If(`$ResultText -iMatch '^(iex\(iwr\()'){Powershell -Command `"`$ResultText`"}Else{echo `"`$ResultText`"|&(DIR Alias:/I*X)}
       }Catch{Write-Host `"x Error: deObfuscation execution failed ..`" -ForeGroundColor Red;Start-Sleep -Seconds 2}
    }
}")

           $CharsCount = $Text.Length
           #Write Ps1 script to the sellected directory!
           echo "$PS1DecriptRot"|Out-File "$pwd\Decryptme.ps1" -encoding ascii -force

           Write-Host "*" -ForegroundColor Green -NoNewline;
           Write-Host " ROT rotation       : [" -ForegroundColor DarkGray -NoNewline;
           Write-Host "$Rot2" -NoNewline;
           Write-Host "] chars" -ForegroundColor DarkGray;

           Write-Host "*" -ForegroundColor Green -NoNewline;
           Write-Host " Raw String Length  : [" -ForegroundColor DarkGray -NoNewline;
           Write-Host "$CharsCount" -NoNewline;
           Write-Host "] chars" -ForegroundColor DarkGray;
           Start-Sleep -Milliseconds 700

           Write-Host "*" -ForegroundColor Green -NoNewline;
           Write-Host " Text Raw String    : '" -ForegroundColor DarkGray -NoNewline;
           Write-Host "$Text" -NoNewline;
           Write-Host "'" -ForegroundColor DarkGray;

           Write-Host "*" -ForegroundColor Green -NoNewline;
           Write-Host " Converted String   : '" -ForegroundColor DarkGray -NoNewline;
           Write-Host "$ResultText" -ForegroundColor DarkYellow -NoNewline;
           Write-Host "'" -ForegroundColor DarkGray;
           Start-Sleep -Milliseconds 700

           Write-Host "*" -ForegroundColor Green -NoNewline;
           Write-Host " Decryption Routine : '" -ForegroundColor DarkGray -NoNewline;
           Write-Host "$pwd\Decryptme.ps1" -ForegroundColor Green -NoNewline;
           Write-Host "'" -ForegroundColor DarkGray;

           Write-Host "+" -ForegroundColor DarkYellow -NoNewline;
           Write-Host " Remark: " -ForegroundColor DarkGray -NoNewline;
           Write-Host "If 'decryptme.ps1' fails to execute. Create it with a diferent ROTation.`n"
        }
        Else
        {
           ## Display List format if string
           # its bigger than 100 chars ..
           If(($ResultText.Length) -ge 100)
           {
              $CharsCount = $ResultText.Length
              write-host "Rot    : [" -NoNewline
              write-host "$Rot2" -ForegroundColor Green -NoNewline
              write-host "]"
              Write-Host "Length : [" -NoNewline;
              Write-Host "$CharsCount" -ForegroundColor Green -NoNewline
              Write-Host "] chars"
              Start-Sleep -Milliseconds 700
              write-host "Text   : " -NoNewline
              write-host "$ResultText`n" -ForegroundColor DarkYellow
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
