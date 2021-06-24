<#
.SYNOPSIS
   Enumerate Anti-Virus process's running!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Get-Process {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   This cmdlet ....

.NOTES
   Required Dependencies: Get-Process {native}
   This cmdlet its an aux module of @redpill -sysinfo 'verbose'

.EXAMPLE
   PS C:\> Get-Help .\GetAvs.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetAvs.ps1
   Lists common security product processes

.INPUTS
   None. You cannot pipe objects to GetAvs.ps1

.OUTPUTS
   Common security product processes
   ---------------------------------
   Windows Defender AV process ' MsMpEng ' is running.
   OSSEC intrusion detection process ' ossec ' is running.
#>


## Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null


Write-Host "`n`nCommon security product processes"
Write-Host "---------------------------------"
$processnames = Get-Process * -EA SilentlyContinue | Select-Object ProcessName
ForEach($Item in $processnames)
{

   If($Item.ProcessName -like "*mcshield*")
   {
      Write-Host "McAfee AV process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
   }
   If(($Item.ProcessName -like "*windefend*") -or ($Item.ProcessName -like "*MSASCui*") -or ($Item.ProcessName -like "*msmpeng*") -or ($Item.ProcessName -like "*msmpsvc*"))
   {
      Write-Host "Windows Defender AV process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
   }
   If($Item.ProcessName -like "*WRSA*")
   {
      Write-Host "WebRoot AV process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
   }
   If($Item.ProcessName -like "*savservice*")
   {
      Write-Host "Sophos AV process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
   }
   If(($Item.ProcessName -like "*TMCCSF*") -or ($Item.ProcessName -like "*TmListen*") -or ($Item.ProcessName -like "*NTRtScan*"))
   {
      Write-Host "Trend Micro AV process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
   }
   If(($Item.ProcessName -like "*symantec antivirus*") -or ($Item.ProcessName -like "*SymCorpUI*") -or ($Item.ProcessName -like "*ccSvcHst*") -or ($Item.ProcessName -like "*SMC*")  -or ($Item.ProcessName -like "*Rtvscan*"))
   {
      Write-Host "Symantec AV process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
   }
   If($Item.ProcessName -like "*mbae*")
   {
      Write-Host "MalwareBytes Anti-Exploit process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
   }
            #AppWhitelisting
            If($Item.ProcessName -like "*Parity*")
            {
               Write-Host "Bit9 application whitelisting process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
            }
            #Behavioral Analysis
            If($Item.ProcessName -like "*cb*")
            {
               Write-Host "Carbon Black behavioral analysis process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
            }
            If($Item.ProcessName -like "*bds-vision*")
            {
               Write-Host "BDS Vision behavioral analysis process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
            } 
            If($Item.ProcessName -like "*Triumfant*")
            {
               Write-Host "Triumfant behavioral analysis process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
            }
            If($Item.ProcessName -like "CSFalcon")
            {
               Write-Host "CrowdStrike Falcon EDR process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
            }
            #Intrusion Detection
            If($Item.ProcessName -like "*ossec*")
            {
               Write-Host "OSSEC intrusion detection process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
            } 
            #Firewall
            If($Item.ProcessName -like "*TmPfw*")
            {
               Write-Host "Trend Micro firewall process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
            } 
            #DLP
            If(($Item.ProcessName -like "dgagent") -or ($Item.ProcessName -like "DgService") -or ($Item.ProcessName -like "DgScan"))
            {
               Write-Host "Verdasys Digital Guardian DLP process '"$Item.ProcessName"' is running." -ForegroundColor Yellow
            }   
            If($Item.ProcessName -like "kvoop")
            {
               Write-Host "PUnknown DLP process"$ps.ProcessName"is running." -ForegroundColor Yellow
            }                       
}
Write-Host ""