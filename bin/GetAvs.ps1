<#
.SYNOPSIS
   Enumerate Anti-Virus processes running!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Get-Process {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.4

.DESCRIPTION
   This cmdlet enumerates common security product processes running
   on target system, By exec 'Get-Process' powershell cmdlet {native}
   to retrieve process 'product name', 'process name' and 'process pid'

.NOTES
   This cmdlet is an aux module of @redpill -sysinfo 'verbose'
   Currentlly this cmdlet query for 14 diferent AV processnames.
   AppWhitelisting, Behavioral Analysis, Intrusion Detection, DLP.

.EXAMPLE
   PS C:\> Get-Help .\GetAvs.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetAvs.ps1
   Lists common security product processes running!

.INPUTS
   None. You cannot pipe objects to GetAvs.ps1

.OUTPUTS
   Common security processes running!
   ----------------------------------
   Product      : Windows Defender AV
   ProcessName  : MsMpEng
   Pid          : 3516

   Product      : CrowdStrike Falcon EDR
   ProcessName  : CSFalcon
   Pid          : 8945
#>


$ppid = $null
$found = "False"
## Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$processnames = Get-Process * -EA SilentlyContinue | Where-Object {
   $_.Responding -eq $True -and $_.ProcessName -ne $null
} | Select-Object ProcessName 


## Build Output Table
Write-Host "`n`nCommon security processes running!"
Write-Host "----------------------------------"

ForEach($Item in $processnames)
{

   ## Get process PID identifier's from ProcessName's!
   $rawName = $Item -replace '@{ProcessName=','' -replace '}',''
   $ppid = (Get-Process -Name "$rawName" -EA SilentlyContinue).Id


   If($Item.ProcessName -like "*mcshield*")
   {
      $found = "True"
      Write-Host "Product      : McAfee AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "*windefend*") -or ($Item.ProcessName -like "*MSASCui*") -or ($Item.ProcessName -like "*msmpeng*") -or ($Item.ProcessName -like "*msmpsvc*"))
   {
      $found = "True"
      Write-Host "Product      : Windows Defender AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If($Item.ProcessName -like "*WRSA*")
   {
      $found = "True"
      Write-Host "Product      : WebRoot AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If($Item.ProcessName -like "*savservice*")
   {
      $found = "True"
      Write-Host "Product      : Sophos AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "*TMCCSF*") -or ($Item.ProcessName -like "*TmListen*") -or ($Item.ProcessName -like "*NTRtScan*"))
   {
      $found = "True"
      Write-Host "Product      : Trend Micro AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "*symantec antivirus*") -or ($Item.ProcessName -like "*SymCorpUI*") -or ($Item.ProcessName -like "*ccSvcHst*") -or ($Item.ProcessName -like "*SMC*")  -or ($Item.ProcessName -like "*Rtvscan*"))
   {
      $found = "True"
      Write-Host "Product      : Symantec AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If($Item.ProcessName -like "*mbae*")
   {
      $found = "True"
      Write-Host "Product      : MalwareBytes Anti-Exploit" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   
            #AppWhitelisting
            If($Item.ProcessName -like "*Parity*")
            {
               $found = "True"
               Write-Host "Product      : Bit9 application whitelisting" -ForegroundColor Yellow
               Write-Host "ProcessName  : $rawName"
               Write-Host "Pid          : $ppid`n"
            }
            
            #Behavioral Analysis
            If($Item.ProcessName -like "*cb*")
            {
               $found = "True"
               Write-Host "Product      : Carbon Black behavioral analysis" -ForegroundColor Yellow
               Write-Host "ProcessName  : $rawName"
               Write-Host "Pid          : $ppid`n"
            }
            If($Item.ProcessName -like "*bds-vision*")
            {
               $found = "True"
               Write-Host "Product      : BDS Vision behavioral analysis" -ForegroundColor Yellow
               Write-Host "ProcessName  : $rawName"
               Write-Host "Pid          : $ppid`n"
            } 
            If($Item.ProcessName -like "*Triumfant*")
            {
               $found = "True"
               Write-Host "Product      : Triumfant behavioral analysis" -ForegroundColor Yellow
               Write-Host "ProcessName  : $rawName"
               Write-Host "Pid          : $ppid`n"
            }
            If($Item.ProcessName -like "CSFalcon")
            {
               $found = "True"
               Write-Host "Product      : CrowdStrike Falcon EDR" -ForegroundColor Yellow
               Write-Host "ProcessName  : $rawName"
               Write-Host "Pid          : $ppid`n"
            }
            
            #Intrusion Detection
            If($Item.ProcessName -like "*ossec*")
            {
               $found = "True"
               Write-Host "Product      : OSSEC intrusion detection" -ForegroundColor Yellow
               Write-Host "ProcessName  : $rawName"
               Write-Host "Pid          : $ppid`n"
            }
            
            #Firewall
            If($Item.ProcessName -like "*TmPfw*")
            {
               $found = "True"
               Write-Host "Product      : Trend Micro firewall" -ForegroundColor Yellow
               Write-Host "ProcessName  : $rawName"
               Write-Host "Pid          : $ppid`n"
            }
            
            #DLP
            If(($Item.ProcessName -like "dgagent") -or ($Item.ProcessName -like "DgService") -or ($Item.ProcessName -like "DgScan"))
            {
               $found = "True"
               Write-Host "Product      : Verdasys Digital Guardian DLP" -ForegroundColor Yellow
               Write-Host "ProcessName  : $rawName"
               Write-Host "Pid          : $ppid`n"
            }   
            If($Item.ProcessName -like "kvoop")
            {
               $found = "True"
               Write-Host "Product      : Unknown DLP" -ForegroundColor Yellow
               Write-Host "ProcessName  : $rawName"
               Write-Host "Pid          : $ppid`n"
            }
            
   #Continue
   If($Item.ProcessName -like "adaware")
   {
      $found = "True"
      Write-Host "Product      : Adaware AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If($Item.ProcessName -like "drwatson")
   {
      $found = "True"
      Write-Host "Product      : DrWatson AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If($Item.ProcessName -like "nod32")
   {
      $found = "True"
      Write-Host "Product      : Nod32 AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If($Item.ProcessName -like "avastUI")
   {
      $found = "True"
      Write-Host "Product      : Avast AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "navapsvc") -or ($Item.ProcessName -like "NortonSecurity"))
   {
      $found = "True"
      Write-Host "Product      : Norton AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If($Item.ProcessName -like "PSUAMain")
   {
      $found = "True"
      Write-Host "Product      : Panda Cloud AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "avp") -or ($Item.ProcessName -like "Kavss"))
   {
      $found = "True"
      Write-Host "Product      : Kaspersky AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }


}


If($found -ieq "False")
{
   Write-Host "[error] none security products found running!" -ForegroundColor Red -BackgroundColor Black
   Write-Host ""
}

Write-Host ""