<#
.SYNOPSIS
   List common security processes running!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Get-Process {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.1.10

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
   Pid  ProcessName Product             Description        
   ---  ----------- -------             -----------        
   3512 MsMpEng     Anti-Virus          Windows Defender AV
   4300 TmPfw       Firewall            Trend Micro firewall
   8945 CSFalcon    Behavioral Analysis CrowdStrike Falcon EDR

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
Write-Host "`n`nCommon security processes running!" -ForeGroundColor Green


#Build security processes DataTable!
$mytable = New-Object System.Data.DataTable
$mytable.Columns.Add("Pid")|Out-Null
$mytable.Columns.Add("ProcessName")|Out-Null
$mytable.Columns.Add("Product")|Out-Null
$mytable.Columns.Add("Description")|Out-Null


ForEach($Item in $processnames)
{

   ## Get process PID identifier's from ProcessName's!
   $rawName = $Item -replace '@{ProcessName=','' -replace '}',''
   $ppid = (Get-Process -Name "$rawName" -EA SilentlyContinue).Id


   If($Item.ProcessName -like "*F-PROT*")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$rawName",        ## ProcessName
                        "Anti-Virus",      ## Description
                        "F-Prot AntiVirus" ## Product

      )|Out-Null
   }
   If($Item.ProcessName -like "*nspupsvc*")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",      ## PID
                        "$rawName",   ## ProcessName
                        "Anti-Virus", ## Description
                        "nProtect"    ## Product

      )|Out-Null
   }
   If($Item.ProcessName -like "*SpywareTerminatorShield*")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",            ## PID
                        "$rawName",         ## ProcessName
                        "Anti-Virus",       ## Description
                        "SpywareTerminator" ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "*AVK*") -or 
      ($Item.ProcessName -like "*AVKCl*") -or 
      ($Item.ProcessName -like "*GDScan*") -or 
      ($Item.ProcessName -like "*AVKWCtl*") -or 
      ($Item.ProcessName -like "*AVKBackupService*"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",       ## PID
                        "$rawName",    ## ProcessName
                        "Anti-Virus",  ## Description
                        "GData"        ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "*f-secure*") -or 
      ($Item.ProcessName -like "*fsavgui*"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",       ## PID
                        "$rawName",    ## ProcessName
                        "Anti-Virus",  ## Description
                        "f-secure"     ## Product

      )|Out-Null
   }
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
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",       ## PID
                        "$rawName",    ## ProcessName
                        "Anti-Virus",  ## Description
                        "McAfee AV"    ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "*msmpsvc*") -or 
      ($Item.ProcessName -like "*MSASCui*") -or 
      ($Item.ProcessName -like "*msmpeng*") -or 
      ($Item.ProcessName -like "*windefend*"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",              ## PID
                        "$rawName",           ## ProcessName
                        "Anti-Virus",         ## Description
                        "Windows Defender AV" ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "*WRSA*") -or 
      ($Item.ProcessName -like "*WebrootWRSA*"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",      ## PID
                        "$rawName",   ## ProcessName
                        "Anti-Virus", ## Description
                        "WebRoot AV"  ## Product

      )|Out-Null
   }
   If($Item.ProcessName -like "*swdoctor*")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",             ## PID
                        "$rawName",          ## ProcessName
                        "Anti-Virus",        ## Description
                        "Spyware Doctor AV"  ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "*sbiectrl*") -or 
      ($Item.ProcessName -like "*savservice*"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",       ## PID
                        "$rawName",    ## ProcessName
                        "Anti-Virus",  ## Description
                        "Sophos AV"    ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "*TMCCSF*") -or 
      ($Item.ProcessName -like "*ofcdog*") -or 
      ($Item.ProcessName -like "*TmListen*") -or 
      ($Item.ProcessName -like "*pcclient*") -or 
      ($Item.ProcessName -like "*NTRtScan*"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",         ## PID
                        "$rawName",      ## ProcessName
                        "Anti-Virus",    ## Description
                        "Trend Micro AV" ## Product

      )|Out-Null
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
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",      ## PID
                        "$rawName",   ## ProcessName
                        "Anti-Virus", ## Description
                        "Symantec AV" ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "*mbae*") -or 
      ($Item.ProcessName -like "*mbam*") -or 
      ($Item.ProcessName -like "*mbamtray*"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",                    ## PID
                        "$rawName",                 ## ProcessName
                        "Anti-Virus",               ## Description
                        "MalwareBytes Anti-Exploit" ## Product

      )|Out-Null
   }
   If($Item.ProcessName -like "adaware")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",       ## PID
                        "$rawName",    ## ProcessName
                        "Anti-Virus",  ## Description
                        "Adaware AV"   ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "drwatson") -or 
      ($Item.ProcessName -like "Drwtsn32"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",       ## PID
                        "$rawName",    ## ProcessName
                        "Anti-Virus",  ## Description
                        "DrWatson AV"  ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "nod32") -or 
      ($Item.ProcessName -like "nod32krn"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",      ## PID
                        "$rawName",   ## ProcessName
                        "Anti-Virus", ## Description
                        "Nod32 AV"    ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "avastUI") -or 
      ($Item.ProcessName -like "ashdisp") -or 
      ($Item.ProcessName -like "ashmaisv") -or 
      ($Item.ProcessName -like "aswupdsv"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",      ## PID
                        "$rawName",   ## ProcessName
                        "Anti-Virus", ## Description
                        "Avast AV"    ## Product

      )|Out-Null
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
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",      ## PID
                        "$rawName",   ## ProcessName
                        "Anti-Virus", ## Description
                        "Norton AV"   ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "PSUAMain") -or 
      ($Item.ProcessName -like "pavfnsvr"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",          ## PID
                        "$rawName",       ## ProcessName
                        "Anti-Virus",     ## Description
                        "Panda Cloud AV"  ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "avp") -or 
      ($Item.ProcessName -like "kav") -or 
      ($Item.ProcessName -like "avpm") -or 
      ($Item.ProcessName -like "Kavss") -or 
      ($Item.ProcessName -like "kavsvc"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$rawName",     ## ProcessName
                        "Anti-Virus",   ## Description
                        "Kaspersky AV"  ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "avgcc") -or 
      ($Item.ProcessName -like "aavgapi") -or 
      ($Item.ProcessName -like "avgamsvr") -or 
      ($Item.ProcessName -like "avgagent") -or 
      ($Item.ProcessName -like "avgctrl"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$rawName",        ## ProcessName
                        "Anti-Virus",      ## Description
                        "AVG Security AV"  ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "aawtray") -or 
      ($Item.ProcessName -like "ad-watch") -or 
      ($Item.ProcessName -like "ad-aware") -or 
      ($Item.ProcessName -like "aawservice"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",       ## PID
                        "$rawName",    ## ProcessName
                        "Anti-Virus",  ## Description
                        "Ad-Aware AV"  ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "a2cfg") -or
      ($Item.ProcessName -like "a2guard") -or 
      ($Item.ProcessName -like "a2adguard") -or 
      ($Item.ProcessName -like "a2adwizard") -or 
      ($Item.ProcessName -like "a2antidialer"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$rawName",        ## ProcessName
                        "Anti-Virus",      ## Description
                        "A-squared Guard"  ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "a2scan") -or 
      ($Item.ProcessName -like "a2start") -or 
      ($Item.ProcessName -like "a2service") -or 
      ($Item.ProcessName -like "a2hijackfree"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",       ## PID
                        "$rawName",    ## ProcessName
                        "Anti-Virus",  ## Description
                        "Emsisoft AV"  ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "sched") -or 
      ($Item.ProcessName -like "avguard") -or
      ($Item.ProcessName -like "savscan"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",       ## PID
                        "$rawName",    ## ProcessName
                        "Anti-Virus",  ## Description
                        "Avira AV"     ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "bdss") -or 
      ($Item.ProcessName -like "bdmcon") -or 
      ($Item.ProcessName -like "bdagent") -or 
      ($Item.ProcessName -like "bdnagent") -or 
      ($Item.ProcessName -like "livesrv"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",          ## PID
                        "$rawName",       ## ProcessName
                        "Anti-Virus",     ## Description
                        "Bitdefender AV"  ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "clamd") -or 
      ($Item.ProcessName -like "clamtray") -or 
      ($Item.ProcessName -like "clamservice"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$rawName",        ## ProcessName
                        "Anti-Virus",      ## Description
                        "ClamAV security"  ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "sdhelp") -or 
      ($Item.ProcessName -like "teatimer"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",                     ## PID
                        "$rawName",                  ## ProcessName
                        "Anti-Spywear",              ## Description
                        "Spybot - Search & Destroy"  ## Product

      )|Out-Null
   }
   If(($Item.ProcessName -like "ssu") -or 
      ($Item.ProcessName -like "spysweeper"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",               ## PID
                        "$rawName",            ## ProcessName
                        "Anti-Spywear",        ## Description
                        "WebRoot Spy Sweeper"  ## Product

      )|Out-Null
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
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                         ## PID
                           "$rawName",                      ## ProcessName
                           "AppWhitelisting",               ## Description
                           "Bit9 application whitelisting"  ## Product

         )|Out-Null
      }
            
      #Behavioral Analysis
      If($Item.ProcessName -like "*cb*")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                            ## PID
                           "$rawName",                         ## ProcessName
                           "Behavioral Analysis",              ## Description
                           "Carbon Black behavioral analysis"  ## Product

         )|Out-Null
      }
      If($Item.ProcessName -like "*bds-vision*")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                          ## PID
                           "$rawName",                       ## ProcessName
                           "Behavioral Analysis",            ## Description
                           "BDS Vision behavioral analysis"  ## Product

         )|Out-Null
      } 
      If($Item.ProcessName -like "*Triumfant*")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                         ## PID
                           "$rawName",                      ## ProcessName
                           "Behavioral Analysis",           ## Description
                           "Triumfant behavioral analysis"  ## Product

         )|Out-Null
      }
      If($Item.ProcessName -like "CSFalcon")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                  ## PID
                           "$rawName",               ## ProcessName
                           "Behavioral Analysis",    ## Description
                           "CrowdStrike Falcon EDR"  ## Product

         )|Out-Null
      }
            
      #Intrusion Detection
      If($Item.ProcessName -like "*ossec*")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                     ## PID
                           "$rawName",                  ## ProcessName
                           "Intrusion Detection",       ## Description
                           "OSSEC intrusion detection"  ## Product

         )|Out-Null
      }
      If(($Item.ProcessName -like "*defensewall*") -or 
         ($Item.ProcessName -like "*defensewall_serv*"))
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                           ## PID
                           "$rawName",                        ## ProcessName
                           "Intrusion Detection",             ## Description
                           "DefenseWall intrusion detection"  ## Product

         )|Out-Null
      }
            
      #Firewall
      If(($Item.ProcessName -like "*vsmon*") -or 
         ($Item.ProcessName -like "*zlclient*")) 
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                       ## PID
                           "$rawName",                    ## ProcessName
                           "Firewall",                    ## Description
                           "ZoneAlarm Security firewall"  ## Product

         )|Out-Null
      }
      If($Item.ProcessName -like "*TmPfw*") 
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                ## PID
                           "$rawName",             ## ProcessName
                           "Firewall",             ## Description
                           "Trend Micro firewall"  ## Product

         )|Out-Null
      }
      If(($Item.ProcessName -like "*cfp*") -or 
         ($Item.ProcessName -like "*cpf*") -or 
         ($Item.ProcessName -like "*cmdagent*"))
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                    ## PID
                           "$rawName",                 ## ProcessName
                           "Firewall",                 ## Description
                           "Comodo Security firewall"  ## Product

         )|Out-Null
      }
      If($Item.ProcessName -like "*msfwsvc*")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                     ## PID
                           "$rawName",                  ## ProcessName
                           "Firewall",                  ## Description
                           "OneCare Security firewall"  ## Product

         )|Out-Null
      }
      If($Item.ProcessName -like "*outpost*")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                    ## PID
                           "$rawName",                 ## ProcessName
                           "Firewall",                 ## Description
                           "Agnitum Outpost Firewall"  ## Product

         )|Out-Null
      }
      If($Item.ProcessName -like "*scfservice*")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                  ## PID
                           "$rawName",               ## ProcessName
                           "Firewall",               ## Description
                           "Sophos Client Firewall"  ## Product

         )|Out-Null
      }
      If(($Item.ProcessName -like "*umxcfg*") -or 
         ($Item.ProcessName -like "*umxagent*"))
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                ## PID
                           "$rawName",             ## ProcessName
                           "Firewall",             ## Description
                           "CA Personal Firewall"  ## Product

         )|Out-Null
      }
            
      #DLP
      If(($Item.ProcessName -like "DgScan") -or 
         ($Item.ProcessName -like "dgagent") -or 
         ($Item.ProcessName -like "DgService"))
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                         ## PID
                           "$rawName",                      ## ProcessName
                           "DLP",                           ## Description
                           "Verdasys Digital Guardian DLP"  ## Product

         )|Out-Null
      }   
      If($Item.ProcessName -like "kvoop")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",       ## PID
                           "$rawName",    ## ProcessName
                           "DLP",         ## Description
                           "Unknown DLP"  ## Product

         )|Out-Null
      }
      If($Item.ProcessName -like "noads")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",            ## PID
                           "$rawName",         ## ProcessName
                           "Ad Blocker",       ## Description
                           "NoAds Ad Blocker"  ## Product

         )|Out-Null
      }
      If($Item.ProcessName -like "sadblock")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",            ## PID
                           "$rawName",         ## ProcessName
                           "Ad Blocker",       ## Description
                           "Super Ad Blocker"  ## Product

         )|Out-Null
      }
   }
}


If($foundit -ieq "False")
{
   Write-Host "[error] none security products found running!" -ForegroundColor Red -BackgroundColor Black
   Write-Host ""
}
Else
{

   $mytable | Format-Table -AutoSize > $Env:TMP\tbl.log
   Get-Content -Path "$Env:TMP\tbl.log" | Select -Skip 1 | Out-String -Stream | ForEach-Object {
   $stringformat = If($_ -iMatch '(Ad Blocker|DLP|Firewall|Intrusion Detection|Behavioral Analysis|AppWhitelisting)'){
      @{ 'ForegroundColor' = 'Yellow' } }Else{ @{ 'ForegroundColor' = 'White' } }
   Write-Host @stringformat $_
   }
}

#Delete artifacts left behind!
Remove-Item -path "$Env:TMP\tbl.log" -EA SilentlyContinue -Force
Write-Host ""