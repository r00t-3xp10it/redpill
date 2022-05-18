<#
.SYNOPSIS
   Convert ETL logfiles into readable data

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Get-WindowsUpdateLog {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.1.4

.DESCRIPTION
   Windows Update logs are now generated using ETW (Event Tracing for Windows).
   This cmdlet converts ETW traces into a readable WindowsUpdate.log by invoking
   Get-WindowsUpdateLog cmdlet. Alternatively this cmdlet allows users to filter
   WindowsUpdate logfile report either by matching string or by number of lines.

.NOTES
   ETLPath param declaration accepts the path of ETL directory or .ETL file.
   Filter param declaration accepts the string to search on WindowsUpdate.log
   Invoke -logfile 'true' argument to NOT delete WindowsUpdate.log in the end. 
   
.Parameter Action
   Display hidden or verbose outputs? (default: hidden)

.Parameter ETLPath
   Path of direcory or etl_file (default: $Env:WINDIR\logs\WindowsUpdate)

.Parameter Filter
   The string to search on report logfile (default: any)

.Parameter First
   How many report lines to display? (default: 100)

.Parameter Logfile
   Create WindowsUpdate logfile? (default: false)
  
.EXAMPLE
   PS C:\> .\WindowsUpdateLog.ps1
   Enumerate the first 100 windows update logs

.EXAMPLE
   PS C:\> .\WindowsUpdateLog.ps1 -First '8'
   Enumerate the first 8 windows update logs

.EXAMPLE
   PS C:\> .\WindowsUpdateLog.ps1 -Filter '(Windows Defender)'
   Enumerate the first 100 windows update logs with 'Windows Defender' string

.EXAMPLE
   PS C:\> .\WindowsUpdateLog.ps1 -Filter '(Defender|FAILED|UDP)'
   Enumerate the first 100 windows update logs with '(Defender|FAILED|UDP)' strings

.EXAMPLE
   PS C:\> .\WindowsUpdateLog.ps1 -ETLPath "$Env:SYSTEMDRIVE\ProgramData\USOShared\Logs\System"
   Enumerate the first 100 windows update logs from the sellected directory

.EXAMPLE
   PS C:\> .\WindowsUpdateLog.ps1 -ETLPath "$Env:WINDIR\logs\WindowsUpdate\WindowsUpdate.*.*.??0.2.etl"
   Enumerate the first 100 windows update logs from the sellected .etl file only

.EXAMPLE
   PS C:\> .\WindowsUpdateLog.ps1 -first '30' -logfile 'false'
   Enumerate the first 30 windows update logs and clean all artifacts

.INPUTS
   None. You cannot pipe objects into WindowsUpdateLog.ps1

.OUTPUTS
   * Creating WindowsUpdate Logfile ..
     => ETLPath:'C:\WINDOWS\logs\WindowsUpdate'
   * Parsing WindowsUpdate logfile data ..
     => Filter:[a-z A-Z] First:[6] Logfile:[false]


   TimeStamp                   PID\ID      Component       Description
   ---------                   ----------  ---------       -----------
   2022/05/06 22:56:49.3154992 12580 7564  Agent           WU client version 10.0.19041.1503
   2022/05/06 22:56:49.3167127 12580 7564  Agent           SleepStudyTracker: Machine is non-AOAC. Sleep study tracker disabled.
   2022/05/06 22:56:49.3170825 12580 7564  Agent           Base directory: C:\WINDOWS\SoftwareDistribution
   2022/05/06 22:56:49.3186506 12580 7564  Agent           Datastore directory: C:\WINDOWS\SoftwareDistribution\DataStore\DataStore.edb
   2022/05/06 22:56:49.3209379 12580 7564  DataStore       JetEnableMultiInstance succeeded - applicable param count: 5, applied param count: 5
   2022/05/06 22:56:49.4857845 12580 7564  Shared          UpdateNetworkState Ipv6, cNetworkInterfaces = 1.
   
.LINK
   http://go.microsoft.com/fwlink/?LinkId=518345
   https://github.com/r00t-3xp10it/redpill/blob/main/bin/WindowsUpdateLog.ps1
   https://gist.github.com/r00t-3xp10it/4fa2e656ecf2f191d17edc6bc0511369?permalink_comment_id=4170412#gistcomment-4170412
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$ETLPath="$Env:WINDIR\logs\WindowsUpdate",
   [string]$Logfile="false",
   [string]$Action="hidden",
   [string]$Filter="any",
   [int]$First='100'
)


$CmdLetVersion = "v1.1.4"
#Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@WindowsUpdateLog $CmdLetVersion {SSA RedTeam @2022}"


<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - create WindowsUpdate logfile

.NOTES
   WindowsUpdate.log its created in %TEMP% directory
#>

write-host "`n* Creating WindowsUpdate logfile .." -ForegroundColor Green
#Make sure that all cmdlet depends are set
If(-not(Test-Path -Path "$ETLPath"))
{
   write-host "  x" -ForegroundColor Red -NoNewline;
   write-host " NotFound: " -ForegroundColor DarkGray -NoNewline;
   write-host "$ETLPath" -ForegroundColor Red
   exit #Exit @WindowsUpdateLog
}
Else
{
   write-host "  => " -ForegroundColor DarkYellow -NoNewline;
   write-host "ETLPath:'" -ForegroundColor DarkGray -NoNewline;
   write-host "$ETLPath" -ForegroundColor DarkYellow -NoNewline
   write-host "'" -ForegroundColor DarkGray;
}
If($First -gt 10000)
{
   [int]$First = '100'
   write-host "  x" -ForegroundColor Red -NoNewline;
   write-host " Error: limmit too high, defaulting to:[" -ForegroundColor DarkGray -NoNewLine;
   write-host "$First" -ForegroundColor Green -NoNewline;
   write-host "]" -ForegroundColor DarkGray;
   Start-Sleep -Seconds 1
}


If($Action -ieq 'verbose')
{
   #Display OnScreen what ETL files are being converted into WindowsUpate.log
   Get-WindowsUpdateLog -LogPath $Env:TMP\WindowsUpdate.log -ETLPath $ETLPath -InformationAction SilentlyContinue
}
Else
{
   #Silently create WindowsUpate.log without displaying what ETL files are being converted
   Start-Process -WindowStyle hidden powershell -ArgumentList "Get-WindowsUpdateLog -LogPath $Env:TMP\WindowsUpdate.log -ETLPath $ETLPath -InformationAction SilentlyContinue" -Wait
}


## Read logfile
write-host "* Parsing WindowsUpdate logfile data .." -ForegroundColor Green
If($Filter -iMatch "any")
{
   #Match all characters
   $Filter = "[a-z A-Z]"
}

write-host "  => " -ForegroundColor DarkYellow -NoNewline;
write-host "Filter:" -ForegroundColor DarkGray -NoNewline;
write-host "$Filter" -ForegroundColor DarkYellow -NoNewline;
write-host " First:[" -ForegroundColor DarkGray -NoNewline;
write-host "$First" -ForegroundColor DarkYellow -NoNewline;
write-host "] Logfile:[" -ForegroundColor DarkGray -NoNewline;
write-host "$Logfile" -ForegroundColor DarkYellow -NoNewline;
write-host "]`n" -ForegroundColor DarkGray;


If(-not(Test-Path -Path "$Env:TMP\WindowsUpdate.log"))
{
   write-host "  x" -ForegroundColor Red -NoNewline;
   write-host " NotFound: " -ForegroundColor DarkGray -NoNewline;
   write-host "$Env:TMP\WindowsUpdate.log" -ForegroundColor Red
}
Else
{
   #Report function Banner
   write-host "`nTimeStamp                   PID\ID      Component       Description" -ForegroundColor Green
   write-host "---------                   ----------- ---------       -----------"

   #Parsing logfile raw data
   Get-Content -Path "$Env:TMP\WindowsUpdate.log"|Select-Object -First $First
}


#Cleanning artifacts left behind
If($Logfile -ieq "false")
{
   Remove-Item -Path $Env:TMP\WindowsUpdate.log -Force
}
If(Test-Path -Path "$Env:TMP\WindowsUpdateLog")
{
   Remove-Item -Path "$Env:TMP\WindowsUpdateLog" -Recurse -Force
}
If($Action -iNotMatch "^(verbose)$" -and $Logfile -iNotMatch "^(false)$")
{
   write-host ""
   write-host "*" -ForegroundColor Green -NoNewline
   write-host " Report logfile: '" -ForegroundColor DarkGray -NoNewline
   write-host "$Env:TMP\WindowsUpdate.log" -ForegroundColor Green -NoNewline
   write-host "'" -ForegroundColor DarkGray
}
 write-host ""