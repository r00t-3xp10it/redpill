<#
.SYNOPSIS
   List common security processes running!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Get-Process {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.8

.DESCRIPTION
   This cmdlet enumerates common security product processes running
   on target system, By exec 'Get-Process' powershell cmdlet {native}
   to retrieve process 'product name', 'process name' and 'process pid'

.NOTES
   Currentlly this cmdlet query for the most common AV processes,
   AppWhitelisting, Behavioral Analysis, Intrusion Detection, DLP.

.Parameter Action
   Accepts arguments: Enum, Verbose (default: Enum)

.EXAMPLE
   PS C:\> Get-Help .\GetCounterMeasures.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetCounterMeasures.ps1
   List common security product processes running!

.EXAMPLE
   PS C:\> .\GetCounterMeasures.ps1 -Action Verbose
   List common security product processes names, AppWhitelisting,
   Behavioral Analysis, EDR, DLP, Intrusion Detection, Firewall, HIPS.

.INPUTS
   None. You cannot pipe objects to GetCounterMeasures.ps1

.OUTPUTS
   Common security processes running!
   ----------------------------------
   Product      : Windows Defender AV
   Description  : Anti-Virus
   ProcessName  : MsMpEng
   Pid          : 3516

   Product      : CrowdStrike Falcon EDR
   Description  : Behavioral Analysis
   ProcessName  : CSFalcon
   Pid          : 8945

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/D4Vinci/Dr0p1t-Framework/blob/master/resources/killav.py
   https://github.com/rapid7/metasploit-framework/blob/master/scripts/meterpreter/getcountermeasure.rb
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Action="Enum"
)


$ppid = $null
$foundit = "False"
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


   If(($Item.ProcessName -like "*mghtml*") -or 
      ($Item.ProcessName -like "*msssrv*") -or 
      ($Item.ProcessName -like "*mcagent*") -or
      ($Item.ProcessName -like "*oasclnt*") -or 
      ($Item.ProcessName -like "*mpftray*") -or 
      ($Item.ProcessName -like "*mcdetect*") -or 
      ($Item.ProcessName -like "*mscifapp*") -or 
      ($Item.ProcessName -like "*mcshield*"))
   {
      $foundit = "True"
      Write-Host "Product      : McAfee AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "*msmpsvc*") -or 
      ($Item.ProcessName -like "*MSASCui*") -or 
      ($Item.ProcessName -like "*msmpeng*") -or 
      ($Item.ProcessName -like "*windefend*"))
   {
      $foundit = "True"
      Write-Host "Product      : Windows Defender AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "*WRSA*") -or 
      ($Item.ProcessName -like "*WebrootWRSA*"))
   {
      $foundit = "True"
      Write-Host "Product      : WebRoot AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If($Item.ProcessName -like "*swdoctor*")
   {
      $foundit = "True"
      Write-Host "Product      : Spyware Doctor AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "*sbiectrl*") -or 
      ($Item.ProcessName -like "*savservice*"))
   {
      $foundit = "True"
      Write-Host "Product      : Sophos AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "*TMCCSF*") -or 
      ($Item.ProcessName -like "*ofcdog*") -or 
      ($Item.ProcessName -like "*TmListen*") -or 
      ($Item.ProcessName -like "*pcclient*") -or 
      ($Item.ProcessName -like "*NTRtScan*"))
   {
      $foundit = "True"
      Write-Host "Product      : Trend Micro AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "*SMC*") -or 
      ($Item.ProcessName -like "*Rtvscan*") -or 
      ($Item.ProcessName -like "*usrprmpt*") -or 
      ($Item.ProcessName -like "*symlcsvc*") -or 
      ($Item.ProcessName -like "*ccSvcHst*") -or 
      ($Item.ProcessName -like "*SymCorpUI*") -or 
      ($Item.ProcessName -like "*symantec antivirus*"))
   {
      $foundit = "True"
      Write-Host "Product      : Symantec AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "*mbae*") -or 
      ($Item.ProcessName -like "*mbam*"))
   {
      $foundit = "True"
      Write-Host "Product      : MalwareBytes Anti-Exploit" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If($Item.ProcessName -like "adaware")
   {
      $foundit = "True"
      Write-Host "Product      : Adaware AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "drwatson") -or 
      ($Item.ProcessName -like "Drwtsn32"))
   {
      $foundit = "True"
      Write-Host "Product      : DrWatson AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "nod32") -or 
      ($Item.ProcessName -like "nod32krn"))
   {
      $foundit = "True"
      Write-Host "Product      : Nod32 AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "avastUI") -or 
      ($Item.ProcessName -like "ashdisp") -or 
      ($Item.ProcessName -like "ashmaisv") -or 
      ($Item.ProcessName -like "aswupdsv"))
   {
      $foundit = "True"
      Write-Host "Product      : Avast AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "atrack") -or 
      ($Item.ProcessName -like "cfgwiz") -or 
      ($Item.ProcessName -like "navapsvc") -or 
      ($Item.ProcessName -like "bootwarn") -or 
      ($Item.ProcessName -like "nprotect") -or 
      ($Item.ProcessName -like "csinsmnt") -or 
      ($Item.ProcessName -like "NortonSecurity"))
   {
      $foundit = "True"
      Write-Host "Product      : Norton AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "PSUAMain") -or 
      ($Item.ProcessName -like "pavfnsvr"))
   {
      $foundit = "True"
      Write-Host "Product      : Panda Cloud AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "avp") -or 
      ($Item.ProcessName -like "kav") -or 
      ($Item.ProcessName -like "avpm") -or 
      ($Item.ProcessName -like "Kavss") -or 
      ($Item.ProcessName -like "kavsvc"))
   {
      $foundit = "True"
      Write-Host "Product      : Kaspersky AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "avgcc") -or 
      ($Item.ProcessName -like "aavgapi") -or 
      ($Item.ProcessName -like "avgamsvr") -or 
      ($Item.ProcessName -like "avgagent") -or 
      ($Item.ProcessName -like "avgctrl"))
   {
      $foundit = "True"
      Write-Host "Product      : AVG Security AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "aawtray") -or 
      ($Item.ProcessName -like "ad-watch") -or 
      ($Item.ProcessName -like "ad-aware") -or 
      ($Item.ProcessName -like "aawservice"))
   {
      $foundit = "True"
      Write-Host "Product      : Ad-Aware AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "a2cfg") -or
      ($Item.ProcessName -like "a2guard") -or 
      ($Item.ProcessName -like "a2adguard") -or 
      ($Item.ProcessName -like "a2adwizard") -or 
      ($Item.ProcessName -like "a2antidialer"))
   {
      $foundit = "True"
      Write-Host "Product      : A-squared Guard" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "a2scan") -or 
      ($Item.ProcessName -like "a2start") -or 
      ($Item.ProcessName -like "a2service") -or 
      ($Item.ProcessName -like "a2hijackfree"))
   {
      $foundit = "True"
      Write-Host "Product      : Emsisoft AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "sched") -or 
      ($Item.ProcessName -like "avguard") -or
      ($Item.ProcessName -like "savscan"))
   {
      $foundit = "True"
      Write-Host "Product      : Avira AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "bdss") -or 
      ($Item.ProcessName -like "bdmcon") -or 
      ($Item.ProcessName -like "bdagent") -or 
      ($Item.ProcessName -like "bdnagent") -or 
      ($Item.ProcessName -like "livesrv"))
   {
      $foundit = "True"
      Write-Host "Product      : Bitdefender AV" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "clamd") -or 
      ($Item.ProcessName -like "clamtray") -or 
      ($Item.ProcessName -like "clamservice"))
   {
      $foundit = "True"
      Write-Host "Product      : ClamAV security" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Virus"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "sdhelp") -or 
      ($Item.ProcessName -like "teatimer"))
   {
      $foundit = "True"
      Write-Host "Product      : Spybot - Search & Destroy" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Spywear"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }
   If(($Item.ProcessName -like "ssu") -or 
      ($Item.ProcessName -like "spysweeper"))
   {
      $foundit = "True"
      Write-Host "Product      : WebRoot Spy Sweeper" -ForegroundColor Yellow
      Write-Host "Description  : Anti-Spywear"
      Write-Host "ProcessName  : $rawName"
      Write-Host "Pid          : $ppid`n"
   }


   If($Action -ieq "Verbose")
   {

      <#
      .SYNOPSIS
         Helper - List AppWhitelisting, Behavioral Analysis
         Intrusion Detection, Firewall Process, DLP, EDR, HIPS

      .EXAMPLE
         PS C:\> .\GetCounterMeasures.ps1 -Action Verbose
      #>

      #AppWhitelisting
      If($Item.ProcessName -like "*Parity*")
      {
         $foundit = "True"
         Write-Host "Product      : Bit9 application whitelisting" -ForegroundColor DarkYellow
         Write-Host "Description  : AppWhitelisting"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
            
      #Behavioral Analysis
      If($Item.ProcessName -like "*cb*")
      {
         $foundit = "True"
         Write-Host "Product      : Carbon Black behavioral analysis" -ForegroundColor DarkYellow
         Write-Host "Description  : Behavioral Analysis"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "*bds-vision*")
      {
         $foundit = "True"
         Write-Host "Product      : BDS Vision behavioral analysis" -ForegroundColor DarkYellow
         Write-Host "Description  : Behavioral Analysis"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      } 
      If($Item.ProcessName -like "*Triumfant*")
      {
         $foundit = "True"
         Write-Host "Product      : Triumfant behavioral analysis" -ForegroundColor DarkYellow
         Write-Host "Description  : Behavioral Analysis"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "CSFalcon")
      {
         $foundit = "True"
         Write-Host "Product      : CrowdStrike Falcon EDR" -ForegroundColor DarkYellow
         Write-Host "Description  : Behavioral Analysis"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
            
      #Intrusion Detection
      If($Item.ProcessName -like "*ossec*")
      {
         $foundit = "True"
         Write-Host "Product      : OSSEC intrusion detection" -ForegroundColor DarkYellow
         Write-Host "Description  : Intrusion Detection"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If(($Item.ProcessName -like "*defensewall*") -or 
         ($Item.ProcessName -like "*defensewall_serv*"))
      {
         $foundit = "True"
         Write-Host "Product      : DefenseWall intrusion detection" -ForegroundColor DarkYellow
         Write-Host "Description  : Intrusion Detection"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
            
      #Firewall
      If($Item.ProcessName -like "*zlclient*") 
      {
         $foundit = "True"
         Write-Host "Product      : ZoneAlarm Security firewall" -ForegroundColor DarkYellow
         Write-Host "Description  : Firewall"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "*TmPfw*") 
      {
         $foundit = "True"
         Write-Host "Product      : Trend Micro firewall" -ForegroundColor DarkYellow
         Write-Host "Description  : Firewall"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If(($Item.ProcessName -like "*cfp*") -or 
         ($Item.ProcessName -like "*cpf*") -or 
         ($Item.ProcessName -like "*cmdagent*"))
      {
         $foundit = "True"
         Write-Host "Product      : Comodo Security firewall" -ForegroundColor DarkYellow
         Write-Host "Description  : Firewall"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "*msfwsvc*")
      {
         $foundit = "True"
         Write-Host "Product      : OneCare Security firewall" -ForegroundColor DarkYellow
         Write-Host "Description  : Firewall"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "*outpost*")
      {
         $foundit = "True"
         Write-Host "Product      : Agnitum Outpost Firewall" -ForegroundColor DarkYellow
         Write-Host "Description  : Firewall"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "*scfservice*")
      {
         $foundit = "True"
         Write-Host "Product      : Sophos Client Firewall" -ForegroundColor DarkYellow
         Write-Host "Description  : Firewall"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If(($Item.ProcessName -like "*umxcfg*") -or 
         ($Item.ProcessName -like "*umxagent*"))
      {
         $foundit = "True"
         Write-Host "Product      : CA Personal Firewall" -ForegroundColor DarkYellow
         Write-Host "Description  : Firewall"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
            
      #DLP
      If(($Item.ProcessName -like "DgScan") -or 
         ($Item.ProcessName -like "dgagent") -or 
         ($Item.ProcessName -like "DgService"))
      {
         $foundit = "True"
         Write-Host "Product      : Verdasys Digital Guardian DLP" -ForegroundColor DarkYellow
         Write-Host "Description  : DLP"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }   
      If($Item.ProcessName -like "kvoop")
      {
         $foundit = "True"
         Write-Host "Product      : Unknown DLP" -ForegroundColor DarkYellow
         Write-Host "Description  : DLP"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "noads")
      {
         $foundit = "True"
         Write-Host "Product      : NoAds Ad Blocker" -ForegroundColor DarkYellow
         Write-Host "Description  : Ad Blocker"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
      If($Item.ProcessName -like "sadblock")
      {
         $foundit = "True"
         Write-Host "Product      : Super Ad Blocker" -ForegroundColor DarkYellow
         Write-Host "Description  : Ad Blocker"
         Write-Host "ProcessName  : $rawName"
         Write-Host "Pid          : $ppid`n"
      }
   }
}


If($foundit -ieq "False")
{
   Write-Host "[error] none security products found running!" -ForegroundColor Red -BackgroundColor Black
   Write-Host ""
}

Write-Host ""