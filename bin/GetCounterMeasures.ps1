<#
.SYNOPSIS
   List common security processes running!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Get-Process {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.1.12

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
   Pid  ProcessName Product             FileVersion    Description        
   ---  ----------- -------             -----------    -----------    
   3512 MsMpEng     Anti-Virus          1.21121.256.0  Windows Defender AV
   4300 TmPfw       Firewall            1.21121.256.0  Trend Micro firewall
   8945 CSFalcon    Behavioral Analysis 1.21121.256.0  CrowdStrike Falcon EDR

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
$processnames = (Get-Process * -EA SilentlyContinue | Where-Object {
   $_.Responding -eq $True -and $_.ProcessName -ne $null -and $_.ProcessName -iNotMatch '(svchost|lsass|YourPhone|winlogon|wininit|RuntimeBroker|opera|firefox)'
}).ProcessName


## Build Output Table
Write-Host "`n`n* Common security processes running!" -ForeGroundColor Green


#Build security processes DataTable!
$mytable = New-Object System.Data.DataTable
$mytable.Columns.Add("Pid")|Out-Null
$mytable.Columns.Add("ProcessName")|Out-Null
$mytable.Columns.Add("Version")|Out-Null
$mytable.Columns.Add("Product")|Out-Null
$mytable.Columns.Add("EDR")|Out-Null


ForEach($Item in $processnames)
{
   ## Get process PID identifier's from ProcessName's!
   $ppid = (Get-Process -Name "$Item" -EA SilentlyContinue).Id
   $FileVersion = (Get-Process -Name "$Item" -EA SilentlyContinue).FileVersion


   If($Item -iMatch "^(F-PROT)$")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$Item",           ## ProcessName
                        "$FileVersion",    ## FileVersion
                        "Anti-Virus",      ## Description
                        "F-Prot AntiVirus" ## Product

      )|Out-Null
   }
   If($Item -iMatch "^(nspupsvc)$")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "nProtect"      ## Product

      )|Out-Null
   }
   If($Item -iMatch "^(SpywareTerminatorShield)$")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",            ## PID
                        "$Item",            ## ProcessName
                        "$FileVersion",     ## FileVersion
                        "Anti-Virus",       ## Description
                        "SpywareTerminator" ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(AVK|AVKCl|GDScan|AVKWCtl|AVKBackupService)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "GData"         ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(f-secure|fsavgui)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "f-secure"      ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(mghtml|msssrv|mcagent|oasclnt|mpftray|mcdetect|mscifapp|mcshield)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "McAfee AV"     ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(msmpsvc|MSASCui|MsMpEng|windefend)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",              ## PID
                        "$Item",              ## ProcessName
                        "$FileVersion",       ## FileVersion
                        "Anti-Virus",         ## Description
                        "Windows Defender"    ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(WRSA|WebrootWRSA)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "WebRoot AV"    ## Product

      )|Out-Null
   }
   If($Item -iMatch "^(swdoctor)$")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",             ## PID
                        "$Item",             ## ProcessName
                        "$FileVersion",      ## FileVersion
                        "Anti-Virus",        ## Description
                        "Spyware Doctor AV"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(sbiectrl|savservice)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "Sophos AV"     ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(TMCCSF|ofcdog|TmListen|pcclient|NTRtScan)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",         ## PID
                        "$Item",         ## ProcessName
                        "$FileVersion",  ## FileVersion
                        "Anti-Virus",    ## Description
                        "Trend Micro AV" ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(SMC|Rtvscan|usrprmpt|symlcsvc|ccSvcHst|SymCorpUI|symantec antivirus)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "Symantec AV"   ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(mbae|mbam|mbamtray)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",                    ## PID
                        "$Item",                    ## ProcessName
                        "$FileVersion",             ## FileVersion
                        "Anti-Virus",               ## Description
                        "MalwareBytes Anti-Exploit" ## Product

      )|Out-Null
   }
   If($Item -iMatch "^(adaware)$")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "Adaware AV"    ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(drwatson|Drwtsn32)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "DrWatson AV"   ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(nod32|nod32krn)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "Nod32 AV"      ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(avastUI|ashdisp|ashmaisv|aswupdsv)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "Avast AV"      ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(atrack|cfgwiz|navapsvc|bootwarn|nprotect|csinsmnt|NortonSecurity)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "Norton AV"     ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(PSUAMain|pavfnsvr)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",          ## PID
                        "$Item",          ## ProcessName
                        "$FileVersion",   ## FileVersion
                        "Anti-Virus",     ## Description
                        "Panda Cloud AV"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(avp|kav|avpm|Kavss|kavsvc)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "Kaspersky AV"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(avgcc|aavgapi|avgamsvr|avgagent|avgctrl)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$Item",           ## ProcessName
                        "$FileVersion",    ## FileVersion
                        "Anti-Virus",      ## Description
                        "AVG Security AV"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(aawtray|ad-watch|ad-aware|aawservice)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "Ad-Aware AV"   ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(a2cfg|a2guard|a2adguard|a2adwizard|a2antidialer)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$Item",           ## ProcessName
                        "$FileVersion",    ## FileVersion
                        "Anti-Virus",      ## Description
                        "A-squared Guard"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(a2scan|a2start|a2service|a2hijackfree)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "Emsisoft AV"   ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(sched|avguard|savscan)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "Avira AV"      ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(bdss|bdmcon|bdagent|bdnagent|livesrv)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",          ## PID
                        "$Item",          ## ProcessName
                        "$FileVersion",   ## FileVersion
                        "Anti-Virus",     ## Description
                        "Bitdefender AV"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(clamd|clamtray|clamservice)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$Item",           ## ProcessName
                        "$FileVersion",    ## FileVersion
                        "Anti-Virus",      ## Description
                        "ClamAV security"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(sdhelp|teatimer)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",                     ## PID
                        "$Item",                     ## ProcessName
                        "$FileVersion",              ## FileVersion
                        "Anti-Spywear",              ## Description
                        "Spybot - Search & Destroy"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(ssu|spysweeper)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",               ## PID
                        "$Item",               ## ProcessName
                        "$FileVersion",        ## FileVersion
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
      If($Item -iMatch "^(Parity)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                         ## PID
                           "$Item",                         ## ProcessName
                           "$FileVersion",                  ## FileVersion
                           "AppWhitelisting",               ## Description
                           "Bit9 application whitelisting"  ## Product

         )|Out-Null
      }
            
      #Behavioral Analysis
      If($Item -iMatch "^(cb)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                            ## PID
                           "$Item",                            ## ProcessName
                           "$FileVersion",                     ## FileVersion
                           "Behavioral Analysis",              ## Description
                           "Carbon Black behavioral analysis"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(bds-vision)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                          ## PID
                           "$Item",                          ## ProcessName
                           "$FileVersion",                   ## FileVersion
                           "Behavioral Analysis",            ## Description
                           "BDS Vision behavioral analysis"  ## Product

         )|Out-Null
      } 
      If($Item -iMatch "^(Triumfant)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                         ## PID
                           "$Item",                         ## ProcessName
                           "$FileVersion",                  ## FileVersion
                           "Behavioral Analysis",           ## Description
                           "Triumfant behavioral analysis"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(CSFalcon)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                  ## PID
                           "$Item",                  ## ProcessName
                           "$FileVersion",           ## FileVersion
                           "Behavioral Analysis",    ## Description
                           "CrowdStrike Falcon EDR"  ## Product

         )|Out-Null
      }
            
      #Intrusion Detection
      If($Item -iMatch "^(ossec)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                     ## PID
                           "$Item",                     ## ProcessName
                           "$FileVersion",              ## FileVersion
                           "Intrusion Detection",       ## Description
                           "OSSEC intrusion detection"  ## Product

         )|Out-Null
      }
      If(($Item -iMatch "^(defensewall|defensewall_serv)$"))
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                           ## PID
                           "$Item",                           ## ProcessName
                           "$FileVersion",                    ## FileVersion
                           "Intrusion Detection",             ## Description
                           "DefenseWall intrusion detection"  ## Product

         )|Out-Null
      }
            
      #Firewall
      If(($Item -iMatch "^(vsmon|zlclient)$")) 
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                       ## PID
                           "$Item",                       ## ProcessName
                           "$FileVersion",                ## FileVersion
                           "Firewall",                    ## Description
                           "ZoneAlarm Security firewall"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(TmPfw)$") 
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                ## PID
                           "$Item",                ## ProcessName
                           "$FileVersion",         ## FileVersion
                           "Firewall",             ## Description
                           "Trend Micro firewall"  ## Product

         )|Out-Null
      }
      If(($Item -iMatch "^(cfp|cpf|cmdagent)$"))
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                    ## PID
                           "$Item",                    ## ProcessName
                           "$FileVersion",             ## FileVersion
                           "Firewall",                 ## Description
                           "Comodo Security firewall"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(msfwsvc)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                     ## PID
                           "$Item",                     ## ProcessName
                           "$FileVersion",              ## FileVersion
                           "Firewall",                  ## Description
                           "OneCare Security firewall"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(outpost)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                    ## PID
                           "$Item",                    ## ProcessName
                           "$FileVersion",             ## FileVersion
                           "Firewall",                 ## Description
                           "Agnitum Outpost Firewall"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(scfservice)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                  ## PID
                           "$Item",                  ## ProcessName
                           "$FileVersion",           ## FileVersion
                           "Firewall",               ## Description
                           "Sophos Client Firewall"  ## Product

         )|Out-Null
      }
      If(($Item -iMatch "^(umxcfg|umxagent)$"))
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                ## PID
                           "$Item",                ## ProcessName
                           "$FileVersion",         ## FileVersion
                           "Firewall",             ## Description
                           "CA Personal Firewall"  ## Product

         )|Out-Null
      }
            
      #DLP
      If(($Item -iMatch "^(DgScan|dgagent|DgService)$"))
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                         ## PID
                           "$Item",                         ## ProcessName
                           "$FileVersion",                  ## FileVersion
                           "DLP",                           ## Description
                           "Verdasys Digital Guardian DLP"  ## Product

         )|Out-Null
      }   
      If($Item -iMatch "^(kvoop)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",        ## PID
                           "$Item",        ## ProcessName
                           "$FileVersion", ## FileVersion
                           "DLP",          ## Description
                           "Unknown DLP"   ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(noads)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",            ## PID
                           "$Item",            ## ProcessName
                           "$FileVersion",     ## FileVersion
                           "Ad Blocker",       ## Description
                           "NoAds Ad Blocker"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(sadblock)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",            ## PID
                           "$Item",            ## ProcessName
                           "$FileVersion",     ## FileVersion
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
   Get-Content -Path "$Env:TMP\tbl.log" | Out-String -Stream | Select -Skip 1 | Select -SkipLast 1 | ForEach-Object {
      $stringformat = If($_ -iMatch '(Pid)')
      {
         @{ 'ForegroundColor' = 'Yellow' }
      }
      ElseIf($_ -iMatch '(Ad Blocker|DLP|Firewall|Intrusion Detection|Behavioral Analysis|AppWhitelisting)')
      {
         @{ 'ForegroundColor' = 'DarkGray' }      
      } 
      Else
      {
         @{ 'ForegroundColor' = 'White' }
      }
      Write-Host @stringformat $_
   }
}



If($Action -ieq "verbose")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Credits: @BankSecurity
      Helper - Check EDR by driver name existence!
   #>

   #Build Drivers DataTable!
   $DriversTable = New-Object System.Data.DataTable
   $DriversTable.Columns.Add("Driver       ")|Out-Null
   $DriversTable.Columns.Add("Version     ")|Out-Null
   $DriversTable.Columns.Add("EDR")|Out-Null

   #Local function variable declarations
   $DriversPath = "$Env:SystemDrive\Windows\System32\drivers"
   $DriversList = ((Get-ChildItem -Path "$DriversPath" | Where-Object  Name -Match '(.sys)$').name)

   #Loop trough all driver names
   ForEach($DriverName in $DriversList)
   {
      #Get driver product version
      $Dversion = ((Get-ChildItem -Path "$DriversPath\$DriverName" | Select *).VersionInfo.ProductVersion)
      If($DriverName -iMatch '^(atrsdfw.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",       ## FileVersion
                               "Altiris Symantec" ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(avgtpx86.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "AVG Technologies"  ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(avgtpx64.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "AVG Technologies"  ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(naswSP.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Avast"             ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(edrsensor.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "BitDefender SRL"   ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(CarbonBlackK.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Carbon Black"      ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(parity.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Carbon Black"      ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(csacentr.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Cisco"             ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(csaenh.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Cisco"             ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(csareg.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Cisco"             ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(csascr.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Cisco"             ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(csaav.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Cisco"             ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(csaam.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Cisco"             ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(rvsavd.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "CJSC Returnil Software"  ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(cfrmd.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Comodo Security"   ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(cmdccav.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Comodo Security"   ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(cmdguard.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Comodo Security"   ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(CmdMnEfs.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Comodo Security"   ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(MyDLPMF.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Comodo Security"   ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(im.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "CrowdStrike"       ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(CSDeviceControl.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "CrowdStrike"       ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(csagent.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "CrowdStrike"       ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(CybKernelTracker.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "CyberArk Software" ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(CRExecPrev.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Cybereason"        ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(CyOptics.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Cylance Inc."      ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(CyProtectDrv32.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Cylance Inc."      ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(CyProtectDrv64.sys.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Cylance Inc."      ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(groundling32.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Dell Secureworks"  ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(groundling64.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Dell Secureworks"  ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(esensor.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Endgame"           ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(edevmon.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "ESET"              ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(ehdrv.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "ESET"              ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(FeKern.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "FireEye"           ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(WFP_MRT.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "FireEye"           ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(xfsgk.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "F-Secure"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(fsatp.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "F-Secure"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(fshs.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "F-Secure"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(HexisFSMonitor.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Hexis Cyber Solutions" ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(klifks.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Kaspersky"         ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(klifaa.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Kaspersky"         ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(Klifsm.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Kaspersky"         ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(mbamwatchdog.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Malwarebytes"      ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(mfeaskm.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "McAfee"            ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(mfencfilter.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "McAfee"            ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(PSINPROC.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Panda Security"    ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(PSINFILE.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Panda Security"    ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(amfsm.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Panda Security"    ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(amm8660.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Panda Security"    ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(amm6460.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Panda Security"    ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(eaw.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Raytheon Cyber Solutions" ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(SAFE-Agent.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "SAFE-Cyberdefense" ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(SentinelMonitor.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "SentinelOne"       ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(SAVOnAccess.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Sophos"            ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(savonaccess.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Sophos"            ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(sld.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Sophos"            ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(pgpwdefs.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(GEProtection.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(diflt.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(sysMon.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(ssrfsf.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(emxdrv2.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(reghook.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(spbbcdrv.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(bhdrvx86.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(bhdrvx64.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(symevent.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(vxfsrep.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(VirtFile.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(SymAFR.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(symefasi.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(symefa.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(symefa64.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(SymHsm.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(evmf.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(GEFCMP.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(VFSEnc.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(pgpfs.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(fencry.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Symantec"          ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(ndgdmk.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Verdasys Inc"      ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(ssfmonm.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Webroot Software"  ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(WdFilter.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Windows Defender"  ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(WdNisDrv.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Windows Defender"  ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(hvsifltr.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Windows Defender"  ## EDR name
         )|Out-Null
      }
   
   }


   [array]$CheckTableData = $DriversTable
   If(($CheckTableData|Measure-Object).Count -lt 1)
   {
      write-host "*" -ForegroundColor Red -NoNewline;
      write-host " No known EDR Drivers found..." -ForegroundColor DarkGray;
   }
   Else
   {
      #Display Table
      $DriversTable | Format-Table -AutoSize | Out-String -Stream | Select -Skip 1 | Select -SkipLast 2 | ForEach-Object {
         $stringformat = If($_ -Match '^(Driver)')
         {
            @{ 'ForegroundColor' = 'Green' }
         }
         Else
         {
            @{ 'ForegroundColor' = 'White' }
         }
         Write-Host @stringformat $_
      } 
   }

}


#Delete artifacts left behind!
Remove-Item -path "$Env:TMP\tbl.log" -EA SilentlyContinue -Force
Write-Host ""