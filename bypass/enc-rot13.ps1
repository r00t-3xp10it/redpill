<#
.SYNOPSIS
   Encrypt or decrypt strings using ROT13 cipher.
    
   Author: r00t-3xp10it
   Adapted from: @Markus Fleschut (github)
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.3.8
   
.DESCRIPTION
   ROT13 ("rotate by 13 places") is a simple letter substitution cipher that
   replaces a letter with the 13th letter after it in the alphabet. ROT13 is
   a special case of the Caesar cipher which was developed in ancient Rome.

.NOTES
   .\enc-rot13.ps1 -text [<text>] -output [<con|log|ps1>] -outpath [<$Env:TMP>]
   Remark: -output [<ps1>] creates ps1 script with rot13 decrypt\exec routine.
   Remark: This cmdlet does not accept more than one line to convert to rot13,
   But -infile [<string>] parameter, transforms string new-lines into oneliner.

.Parameter Text
   The text to encode\decode using ROT13 (default: whoami)

.Parameter Output
   Accepts arguments: console, logfile, ps1 (default: console)

.Parameter InFile
   Get string to convert from text file absolucte path (default: off)

.Parameter OutPath
   The absolucte path where to store logfile\ps1 (default: $Env:TMP)

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
   PS C:\> .\enc-rot13.ps1 -infile "cmdline.txt"
   Get the string to convert to rot13 from text file.
   Remark: This function convert new-lines into oneliner.

.EXAMPLE
   PS C:\> .\enc-rot13.ps1 -text "whoami" -output logfile
   Encode text to rot13 and store string on %tmp%\logfile.

.EXAMPLE
   PS C:\> .\enc-rot13.ps1 -text "whoami" -output ps1
   Encode text to rot13 and create decrypt\exec ps1 script.
   
.EXAMPLE
   PS C:\> .\enc-rot13.ps1 -text "whoami" -output ps1 -outpath "$Env:TMP"
   Encode text to rot13 and create decrypt\execute ps1 script (TMP).

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
$cmdletVersion = "v1.3.8"
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
      Helper - Get string to transform from text file!

   .NOTES
      This function allow attackers to transform the contents
      of -infile [<string>] into 'oneliner' cmdline command by
      replacing new-line chars and escaping any double quotes!
      'It means that we can execute several commands sequentially'
   #>

   If(-not(Test-Path -Path "$InFile"))
   {
      Write-Host "`nERROR: -infile [< $InFile >] parameter input, not found .." -ForegroundColor Red -BackgroundColor Black
      Start-Sleep -Seconds 2;exit #Exit @enc-rot13   
   }

   #Get the cmdline\string to transform from text file!
   [string]$Rawtext = [System.IO.File]::ReadAllText("$InFile")
   $Countlines = ($Rawtext | measure -line).Lines.ToString()
   #Replace new-line chars and escape any double quotes found!
   $ParseData = $Rawtext -replace "\r\n",";" -replace '"','`"' ##<- Create oneliner from input file!
   $text = $ParseData|Select-Object -First 1 ##<- Make sure we have only one line of code {oneliner}

}
If($text -eq "" -and $InFile -eq "off")
{
   #Get user to input the cmdline\string!
   $text = Read-Host "Enter text to convert"
}
If(-not(Test-Path -Path "$OutPath" -EA SilentlyContinue))
{
   Write-Host "ERROR: -outpath [< $OutPath >] parameter input, not found .." -ForegroundColor Red -BackgroundColor Black
   Start-Sleep -Seconds 2;$OutPath = ($pwd).Path.ToString()
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
      $PS1DecriptRot = @("      <#
      .SYNOPSIS
         Author: r00t-3xp10it
         Adapted from: @Markus Fleschut
         Helper - execute rot13 cipher! 
      #>
      `$Rotten13 = `"$Result`";`$ROTdata = `$null;
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


Write-Host ""