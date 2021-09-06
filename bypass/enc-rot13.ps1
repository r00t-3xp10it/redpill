<#
.SYNOPSIS
   Encrypt or decrypt strings using ROT13 cipher.
    
   Author: r00t-3xp10it
   Adapted from: @Markus Fleschut (github)
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.2.5
   
.DESCRIPTION
   ROT13 ("rotate by 13 places") is a simple letter substitution cipher that
   replaces a letter with the 13th letter after it in the alphabet. ROT13 is
   a special case of the Caesar cipher which was developed in ancient Rome.

.NOTES
   .\enc-rot13.ps1 -text [<text>] -output [<con|log|ps1>] -outpath [<$Env:TMP>]
   Remark: -output [<ps1>] creates ps1 script with rot13 decrypt\exec routine.

.Parameter Text
   The text to encode\decode using ROT13 (default: whoami)

.Parameter Output
   Accepts arguments: console, logfile, ps1 (default: console)

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

   output  chars text   convertion
   ------  ----- ----   ----------
   console 6     whoami jubnzv
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   http://practicalcryptography.com/ciphers/rot13-cipher
   https://github.com/fleschutz/PowerShell/blob/master/Scripts
#>


#CmdLet Global variable declarations!
 [CmdletBinding(PositionalBinding=$false)] param(
   [string]$OutPath="$Env:TMP",
   [string]$Output="console",
   [string]$text="whoami"
)


$Result = $null
$cmdletVersion = "v1.2.5"
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption �HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@enc-rot13 $cmdletVersion {SSA@RedTeam}"
$RandomMe = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})

#Check for cmdlet mandatory dependencies!
If($text -eq ""){$text = Read-Host "Enter text to convert"}
If(-not(Test-Path -Path "$OutPath" -EA SilentlyContinue))
{
   Write-Host "ERROR: -OutPath [<$OutPath>] not found .." -ForegroundColor Red -BackgroundColor Black
   Start-Sleep -Seconds 1;$OutPath = ($pwd).Path.ToString()
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
      Write-Host "Log written to: '$OutPath\$RandomMe.log'`n" -ForegroundColor Green      
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
      Write-Host "PS1 written to: '$OutPath\$RandomMe.ps1'`n" -ForegroundColor Green
   }
  
}catch{
   Write-Host "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])" -ForegroundColor Red -BackgroundColor Black
}


If($Output -iMatch '^(con|console)$')
{

   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Print Output DataTable! (onscreen-console)
   #>

   #Count how many chars exist in rot13 transformation string!
   $Chars = ($Result|measure -character).Characters.ToString()

   #Build output DataTable!
   $rottentable = New-Object System.Data.DataTable
   $rottentable.Columns.Add("output")|Out-Null
   $rottentable.Columns.Add("chars")|Out-Null   
   $rottentable.Columns.Add("text")|Out-Null
   $rottentable.Columns.Add("convertion")|Out-Null

   #Adding values to output DataTable!
   $rottentable.Rows.Add("console", ## cmdlet transformation output settings!
                         "$Chars",  ## the transformed string chars count!   
                         "$text",   ## the original string to transform!
                         "$Result"  ## the string after transformation!
   )|Out-Null

   #Diplay output DataTable!
   $rottentable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -Match '^(output)'){
         @{ 'ForegroundColor' = 'Green' } }Else{ @{} }
      Write-Host @stringformat $_
   }

}
Write-Host ""
