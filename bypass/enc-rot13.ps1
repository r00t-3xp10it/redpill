<#
.SYNOPSIS
   Encrypt or decrypt strings using ROT13 cipher.
    
   Author: r00t-3xp10it
   Adapted from: @Markus Fleschut (github)
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.4.9
   
.DESCRIPTION
   ROT13 ("rotate by 13 places") is a simple letter substitution cipher that
   replaces a letter with the 13th letter after it in the alphabet. ROT13 is
   a special case of the Caesar cipher which was developed in ancient Rome.

.NOTES
   This cmdlet allow users to convert simple commands to rot13 string using -text [<command>]
   parameter, and display the converted string on console terminal if set -output [<console>]
   or creates a logfile with the rot13 converted string if set -output [<logfile>] parameter,
   or creates one PS1 script (%TMP%) with rot13 decrypt\exec function if set -output [<ps1>].
   Parameter -infile [<script.ps1|text.txt>] can be used to get the commands to be converted
   to rot13 from an existing file.txt\script.ps1 and create the logfile or decrypt PS1 script.
   Remark: Parameter -output [<ps1>] creates script.ps1 with rot13 decrypt\execute routine.
   Remark: Parameter -infile [<path\to\file>] only accepts [<script.ps1|text.txt>] formats

.Parameter Text
   The text to encode\decode using ROT13 (default: whoami)

.Parameter Output
   Accepts arguments: console, logfile, ps1 (default: console)

.Parameter OutPath
   The absolucte path where to store logfile\ps1 (default: $Env:TMP)

.Parameter InFile
   Get the string to convert to rot13 from text\ps1 file (default: off)

.EXAMPLE
   PS C:\> Get-Help .\enc-rot13.ps1 -full
   Access this cmdlet comment based help!

.EXAMPLE
   PS C:\> .\enc-rot13.ps1 -text "whoami"
   Encode text to rot13 and print onscreen.

.EXAMPLE
   PS C:\> .\enc-rot13.ps1 -text "jubnzv"
   Decode rot13 string to text and print onscreen.

.EXAMPLE
   PS C:\> .\enc-rot13.ps1 -text "whoami" -output logfile
   Encode text to rot13 and store string on %tmp%\logfile.

.EXAMPLE
   PS C:\> .\enc-rot13.ps1 -text "whoami" -output ps1
   Encode text to rot13 and create decrypt\exec ps1 script.
   
.EXAMPLE
   PS C:\> .\enc-rot13.ps1 -text "whoami" -output ps1 -outpath "$Env:TMP"
   Encode text to rot13 and create decrypt\execute ps1 script (TMP).

.EXAMPLE
   PS C:\> .\enc-rot13.ps1 -infile "cmdline.ps1" -output ps1
   Get the source code to convert to rot13 from script.ps1 file,
   and create one PS1 script (TMP) with rot13 decrypt function.

.INPUTS
   None. You cannot pipe objects into enc-rot13.ps1

.OUTPUTS
   convertion: jubnzv

   output  lines chars text   convertion
   ------  ----- ----- ----   ----------
   console 1     6     whoami jubnzv
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   http://practicalcryptography.com/ciphers/rot13-cipher
   https://github.com/fleschutz/PowerShell/blob/master/Scripts
#>


#CmdLet Global variable declarations!
 [CmdletBinding(PositionalBinding=$false)] param(
   [string]$OutPath="$Env:TMP",
   [string]$Output="console",
   [string]$InFile="off",
   [string]$text="whoami"
)


$Result = $null
$Countlines = $null
$cmdletVersion = "v1.4.9"
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@enc-rot13 $cmdletVersion {SSA@RedTeam}"
$RandomMe = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})


#Cmdlet dependencies!
If($InFile -ne "off")
{

   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Get sourcecode to convert from TXT\PS1

   .NOTES
      This function allow attackers to converts the contents of -infile 'path\to\file'
      into a rot13 string, and builds the PS1 decrypt script that executes sourcecode.
   #>

   If(-not(Test-Path -Path "$InFile" -EA SilentlyContinue))
   {
      Write-Host "`n`nERROR: Parameter -infile [< $InFile >], not found.." -ForegroundColor Red -BackgroundColor Black
      Write-Host "";exit #Exit @enc-rot13   
   }

   If($InFile -iMatch '(.ps1|.txt)$')
   {
      #Get the cmdline\string to convert to rot13 from txt\ps1 file!
      [string]$text = ([System.IO.File]::ReadAllText("$InFile")) -replace '\$','`$' -replace '"','`"'
      $Countlines = ($text | measure -line).Lines.ToString()
   }
   Else
   {
      Write-Host "`n`nERROR: Parameter -infile 'string' only accepts .PS1 or .TXT formats." -ForegroundColor Red -BackgroundColor Black
      Write-Host "";exit #Exit @enc-rot13  
   }

}
If($text -eq "" -and $InFile -eq "off")
{
   #Get user to input the cmdline\string!
   $text = Read-Host "Enter text to convert"
}
If(-not(Test-Path -Path "$OutPath" -EA SilentlyContinue))
{
   Write-Host "ERROR: Parameter -outpath [< $OutPath >], not found .." -ForegroundColor Red -BackgroundColor Black
   $OutPath = ($pwd).Path.ToString();Write-Host "       => setting -outpath to: '$OutPath'" -ForegroundColor Blue
   Start-Sleep -Seconds 2
}
$Banner = @"

    ________  ________  _________   _____  ________     
   |\   __  \|\   __  \|\___   ___\/ __  \|\_____  \    
   \ \  \|\  \ \  \|\  \|___ \  \_|\/_|\  \|____|\ /_   
    \ \   _  _\ \  \\\  \   \ \  \\|/ \ \  \    \|\  \  
     \ \  \\  \\ \  \\\  \   \ \  \    \ \  \  __\_\  \ 
      \ \__\\ _\\ \_______\   \ \__\    \ \__\|\_______\
       \|__|\|__|\|_______|    \|__|     \|__|\|_______|$cmdletVersion
        ROT13 Working Dir: '$OutPath'

"@;
Clear-Host
Write-Host "$Banner`n" -ForegroundColor Blue

function ROT13 {

   <#
   .SYNOPSIS
      Author: @Markus Fleschut
      Helper - returns encrypt\decrypt ROT13 strings!
   #>

   param([string]$text)
   
   $text.ToCharArray() | ForEach-Object {
      If((([int] $_ -ge 97) -and ([int] $_ -le 109)) -or (([int] $_ -ge 65) -and ([int] $_ -le 77)))
      {
         $Result += [char] ([int] $_ + 13)
      }
      ElseIf((([int] $_ -ge 110) -and ([int] $_ -le 122)) -or (([int] $_ -ge 78) -and ([int] $_ -le 90)))
      {
         $Result += [char] ([int] $_ - 13);
      }
      Else
      {
         $Result += $_
      }        
   }
   return $Result

}


try{

   $Result = ROT13 $text
   Write-Host "`nconvertion: $Result" -ForegroundColor DarkBlue -BackgroundColor Gray
   
   If($Output -iMatch '^(log|logfile)$')
   {
      #Write logfile to the sellected directory!
      echo "$Result"|Out-File "$OutPath\$RandomMe.log" -encoding ascii -force
      Write-Host "* written to: '$OutPath\$RandomMe.log'`n" -ForegroundColor Green      
   }
   ElseIf($Output -iMatch '^(ps1)$')
   {

#ROT13-Decrypt function data!
$PS1DecriptRot = @("<#
.SYNOPSIS
   Author: r00t-3xp10it
   Adapted from: @Markus Fleschut
   Helper - execute rot13 cipher! 
#>

`$Rotten13 = @(`"$Result`");`$ROTdata = `$null
`$Rotten13.ToCharArray() | ForEach-Object {If((([int] `$_ -ge 97) -and ([int] `$_ -le 109)) -or (([int] `$_ -ge 65) -and ([int] `$_ -le 77))){`$ROTdata += [char] ([int] `$_ + 13)}ElseIf((([int] `$_ -ge 110) -and ([int] `$_ -le 122)) -or (([int] `$_ -ge 78) -and ([int] `$_ -le 90))){`$ROTdata += [char] ([int] `$_ - 13)}Else{`$ROTdata += `$_}}
try{echo `"`$ROTdata`"|Invoke-Expression}catch{Write-Host `"convertion: `$ROTdata`" -ForeGroundColor Green};Start-Sleep -Seconds 2
")

      #Write Ps1 script to the sellected directory!
      echo "$PS1DecriptRot"|Out-File "$OutPath\$RandomMe.ps1" -encoding ascii -force
      Write-Host "* written to: '$OutPath\$RandomMe.ps1'`n" -ForegroundColor Green
   }
  
}catch{
   Write-Host "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])" -ForegroundColor Red -BackgroundColor Black
}


<#
.SYNOPSIS
   Author: r00t-3xp10it
   Helper - Print Output DataTable! (onscreen)
#>

#Count how many chars exist in rot13 transformation string!
$Chars = ($Result|measure -character).Characters.ToString()
If($Countlines -ieq $null)
{
   #Count how many lines does the original string have!
   $Countlines = ($text|measure -line).Lines.ToString()
}
If($Output -iMatch '^(con|console)$')
{
   $Output = "console"
}
ElseIf($Output -iMatch '^(log|logfile)$')
{
   $Output = "logfile"   
}

#Build output DataTable!
$rottable = New-Object System.Data.DataTable
$rottable.Columns.Add("output")|Out-Null
$rottable.Columns.Add("Lines")|Out-Null
$rottable.Columns.Add("chars")|Out-Null
$rottable.Columns.Add("text")|Out-Null
$rottable.Columns.Add("convertion")|Out-Null


#Adding values to output DataTable!
$rottable.Rows.Add("$Output",     ## cmdlet transformation output settings!
                   "$Countlines", ## how many lines does the original string has!   
                   "$Chars",      ## the transformed string chars count!   
                   "$text",       ## the original string to transform!
                   "$Result"      ## the string after transformation!
)|Out-Null


#Diplay output DataTable!
$rottable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
   $stringformat = If($_ -Match '^(output)'){
      @{ 'ForegroundColor' = 'Green' } }Else{ @{} }
   Write-Host @stringformat $_
}