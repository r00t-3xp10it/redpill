<#
.SYNOPSIS
   Enumerate common security processes running!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Get-Process {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.5

.DESCRIPTION
   This cmdlet enumerates common security product processes running
   on target system, By exec 'Get-Process' powershell cmdlet {native}
   to retrieve process 'product name', 'process name' and 'process pid'

.NOTES
   This cmdlet is an aux module of @redpill -sysinfo 'verbose'
   Currentlly this cmdlet query for the most common AV processes,
   AppWhitelisting, Behavioral Analysis, Intrusion Detection, DLP.

.Parameter Action
   Accepts arguments: Enum, Verbose (default: Enum)

.EXAMPLE
   PS C:\> Get-Help .\GetAvs.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetAvs.ps1
   List common security product processes running!

.EXAMPLE
   PS C:\> .\GetAvs.ps1 -Action Verbose
   List common security product processes names, AppWhitelisting,
   Behavioral Analysis, EDR, DLP, Intrusion Detection, Firewall, HIPS.

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


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Action="Enum"
)


$ppid = $null
$found = "False"
## Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($Action -ieq "False" -or $Action -eq $null){$Action = "Enum"}
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


   If(($Item.ProcessName -like "*mcshield*") -or ($Item.ProcessName -like "*mcagent*") -or ($Item.ProcessName -like "*mcdetect*") -or ($Item.ProcessName -like "*mghtml*") -or ($Item.ProcessName -like "*mpftray*") -or ($Item.ProcessName -like "*msssrv*"))
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
   If(($Item.ProcessName -like "avastUI") -or ($Item.ProcessName -like "aswupdsv"))
   {
      $found = "True"
      Write-Host "Product      : Avast AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "navapsvc") -or ($Item.ProcessName -like "NortonSecurity") -or ($Item.ProcessName -like "atrack") -or ($Item.ProcessName -like "bootwarn") -or ($Item.ProcessName -like "cfgwiz") -or ($Item.ProcessName -like "csinsmnt"))
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
   If(($Item.ProcessName -like "avp") -or ($Item.ProcessName -like "avpm") -or ($Item.ProcessName -like "kav") -or ($Item.ProcessName -like "Kavss"))
   {
      $found = "True"
      Write-Host "Product      : Kaspersky AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "aavgapi") -or ($Item.ProcessName -like "avgamsvr") -or ($Item.ProcessName -like "avgagent") -or ($Item.ProcessName -like "avgcc") -or ($Item.ProcessName -like "avgctrl"))
   {
      $found = "True"
      Write-Host "Product      : AVG Security AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "aawservice") -or ($Item.ProcessName -like "aawtray") -or ($Item.ProcessName -like "ad-aware"))
   {
      $found = "True"
      Write-Host "Product      : Ad-Aware AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "a2guard") -or ($Item.ProcessName -like "a2adguard") -or ($Item.ProcessName -like "a2adwizard") -or ($Item.ProcessName -like "a2antidialer"))
   {
      $found = "True"
      Write-Host "Product      : A-squared Guard" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If($Item.ProcessName -like "avguard")
   {
      $found = "True"
      Write-Host "Product      : Avira AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "bdagent") -or ($Item.ProcessName -like "bdnagent") -or ($Item.ProcessName -like "bdmcon") -or ($Item.ProcessName -like "bdss"))
   {
      $found = "True"
      Write-Host "Product      : Bitdefender AV" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "clamd") -or ($Item.ProcessName -like "clamservice") -or ($Item.ProcessName -like "clamtray"))
   {
      $found = "True"
      Write-Host "Product      : ClamAV security" -ForegroundColor Yellow
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }


   If($Action -ieq "Verbose")
   {

      <#
      .SYNOPSIS
         Helper - List AppWhitelisting, Behavioral Analysis
         Intrusion Detection, Firewall, DLP, EDR, HIPS ..

      .EXAMPLE
         PS C:\> .\GetAvs.ps1 -Action Verbose
      #>

      #AppWhitelisting
      If($Item.ProcessName -like "*Parity*")
      {
         $found = "True"
         Write-Host "Product      : Bit9 application whitelisting" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
            
      #Behavioral Analysis
      If($Item.ProcessName -like "*cb*")
      {
         $found = "True"
         Write-Host "Product      : Carbon Black behavioral analysis" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "*bds-vision*")
      {
         $found = "True"
         Write-Host "Product      : BDS Vision behavioral analysis" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      } 
      If($Item.ProcessName -like "*Triumfant*")
      {
         $found = "True"
         Write-Host "Product      : Triumfant behavioral analysis" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "CSFalcon")
      {
         $found = "True"
         Write-Host "Product      : CrowdStrike Falcon EDR" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
            
      #Intrusion Detection
      If($Item.ProcessName -like "*ossec*")
      {
         $found = "True"
         Write-Host "Product      : OSSEC intrusion detection" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If(($Item.ProcessName -like "*defensewall*") -or ($Item.ProcessName -like "*defensewall_serv*"))
      {
         $found = "True"
         Write-Host "Product      : DefenseWall intrusion detection" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
            
      #Firewall
      If($Item.ProcessName -like "*TmPfw*") 
      {
         $found = "True"
         Write-Host "Product      : Trend Micro firewall" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If(($Item.ProcessName -like "*cfp*") -or ($Item.ProcessName -like "*cpf*") -or ($Item.ProcessName -like "*cmdagent*"))
      {
         $found = "True"
         Write-Host "Product      : Comodo Security firewall" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "*msfwsvc*")
      {
         $found = "True"
         Write-Host "Product      : OneCare Security firewall" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
            
      #DLP
      If(($Item.ProcessName -like "dgagent") -or ($Item.ProcessName -like "DgService") -or ($Item.ProcessName -like "DgScan"))
      {
         $found = "True"
         Write-Host "Product      : Verdasys Digital Guardian DLP" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }   
      If($Item.ProcessName -like "kvoop")
      {
         $found = "True"
         Write-Host "Product      : Unknown DLP" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "noads")
      {
         $found = "True"
         Write-Host "Product      : NoAds addblocker" -ForegroundColor DarkYellow
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }


   }


}


If($found -ieq "False")
{
   Write-Host "[error] none security products found running!" -ForegroundColor Red -BackgroundColor Black
   Write-Host ""
}

Write-Host ""
