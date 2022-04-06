<#
.SYNOPSIS
   List common security processes running!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Get-Process {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.2.17

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
   Behavioral Analysis, EDR, DLP, Intrusion Detection, Firewall,
   HIPS, Defender Preferences and Hunt for EDR's by driver names.

.INPUTS
   None. You cannot pipe objects to GetCounterMeasures.ps1

.OUTPUTS
   Primary AntiVirus Product
   __CLASS                  : AntiVirusProduct
   displayName              : Windows Defender
   instanceGuid             : {D68DDC3A-831F-4fae-9E44-DA132C1ACF46}
   pathToSignedReportingExe : %ProgramFiles%\Windows Defender\MsMpeng.exe
   timestamp                : Tue, 05 Apr 2022 00:38:14 GMT
   PSComputerName           : SKYNET
   RealTimeEnabled          : True
   AMServiceEnabled         : True
   AntivirusEnabled         : True
   IsTamperProtected        : True
   AntispywareEnabled       : True
   ConstrainedLanguage      : Disabled
   DisableScriptScanning    : False
   BehaviorMonitorEnabled   : True
   DisableArchiveScanning   : False
   DataExecutionPrevention  : Active

   Security processes running!
   Pid  ProcessName Version   Product             EDR             
   ---  ----------- -------   -------             ---             
   3536 MsMpEng     4.18.1909 Anti-Virus          Windows Defender
   4300 cmdguard    10.184.78 Firewall            Comodo Security
   8945 CSFalcon    94.132.1  Behavioral Analysis CrowdStrike Falcon EDR

   Hunting for EDR drivers!
   Driver        Version      EDR             
   ------------- ------------ ---
   cmdguard.sys  10.184.78    Comodo Security             
   WdBoot.sys    4.18.1909.6  Windows Defender
   WdDevFlt.sys  4.18.1909.4  Windows Defender
   WdFilter.sys  4.18.1909.6  Windows Defender
   WdNisDrv.sys  4.18.1909.6  Windows Defender

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/D4Vinci/Dr0p1t-Framework/blob/master/resources/killav.py
   https://github.com/rapid7/metasploit-framework/blob/master/scripts/meterpreter/getcountermeasure.rb
#>


#Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Action="Enum"
)


$ppid = $null
$foundit = "False"
#Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$processnames = (Get-Process * -EA SilentlyContinue | Where-Object {
   $_.Responding -eq $True -and $_.ProcessName -ne $null -and $_.ProcessName -iNotMatch '(svchost|lsass|YourPhone|winlogon|wininit|RuntimeBroker|opera|firefox)'
}).ProcessName


#Primary Anti Virus Product
$wmiQuery = "SELECT * FROM AntiVirusProduct"
Write-Host "`nPrimary AntiVirus Product" -ForeGroundColor Green
$AntivirusProduct = Get-WmiObject -Namespace "root\SecurityCenter2" -Query $wmiQuery|Out-File $Env:TMP\Dav.meterpeter -Force
$PrimaryAV = Get-Content -Path $Env:TMP\Dav.meterpeter|Select-Object -Skip 2|Select-Object -SkipLast 3|findstr /V "__PATH __GENUS __SUPERCLASS __DYNASTY __RELPATH __PROPERTY_COUNT __DERIVATION __SERVER __NAMESPACE productState pathToSignedProductExe"
Remove-Item -Path $Env:TMP\Dav.meterpeter -Force

#Display Primary AV DataTable OnScreen
$PrimaryAV | Out-String -Stream | ForEach-Object {
   $stringformat = If($_ -iMatch '^(displayName)')
   {
      @{ 'ForegroundColor' = 'Yellow' }
   }
   Else
   {
      @{ 'ForegroundColor' = 'White' }
   }
   Write-Host @stringformat $_
}


If($PrimaryAV -iMatch '(Windows Defender)' -and $Action -ieq "verbose")
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display Windows Defender Preferences

   .NOTES
      Function activates if invoked -action 'verbose'

   .OUTPUTS
      RealTimeEnabled          : True
      AMServiceEnabled         : True
      AntivirusEnabled         : True
      IsTamperProtected        : True
      AntispywareEnabled       : True
      ConstrainedLanguage      : Disabled
      DisableScriptScanning    : False
      BehaviorMonitorEnabled   : True
      DisableArchiveScanning   : False
      DataExecutionPrevention  : Active
   #>

   $Constrained = $ExecutionContext.SessionState.LanguageMode
   If($Constrained -ieq "ConstrainedLanguage")
   {
      $ConState = "Enabled"
   }
   Else
   {
      $ConState = "Disabled"
   }

   #Local function variable declarations
   $AMServiceEnabled = (Get-MpComputerStatus).AMServiceEnabled
   $AntivirusEnabled = (Get-MpComputerStatus).AntivirusEnabled
   $IsTamperProtected = (Get-MpComputerStatus).IsTamperProtected
   $AntispywareEnabled = (Get-MpComputerStatus).AntispywareEnabled
   $DisableScriptScanning = (Get-MpPreference).DisableScriptScanning
   $DisableArchiveScanning = (Get-MpPreference).DisableArchiveScanning
   $BehaviorMonitorEnabled = (Get-MpComputerStatus).BehaviorMonitorEnabled
   $RealTimeProtectionEnabled = (Get-MpComputerStatus).RealTimeProtectionEnabled
   $ObFuscation = "DataExecut" + "ionPreventi" + "on_Available" -Join ''
   $DEPSETTINGS = $(wmic OS Get $ObFuscation) -replace 'DataExecutionPrevention_Available',''|? {$_ -ne ''}


   #Display DataTable OnScreen
   If($RealTimeProtectionEnabled -iMatch 'True')
   {
      Write-Host "RealTimeEnabled          : $RealTimeProtectionEnabled" -ForegroundColor Yellow
   }
   Else
   {
      Write-Host "RealTimeEnabled          : $RealTimeProtectionEnabled" -ForegroundColor Green   
   }
   Write-Host "AMServiceEnabled         : $AMServiceEnabled"
   If($AntivirusEnabled -iMatch 'True')
   {
      Write-Host "AntivirusEnabled         : $AntivirusEnabled" -ForegroundColor Yellow
   }
   Else
   {
      Write-Host "AntivirusEnabled         : $AntivirusEnabled" -ForegroundColor Green   
   }
   If($IsTamperProtected -iMatch 'True')
   {
      Write-Host "IsTamperProtected        : $IsTamperProtected"
   }
   Else
   {
      Write-Host "IsTamperProtected        : $IsTamperProtected" -ForegroundColor Green   
   }
   If($AntispywareEnabled -iMatch 'True')
   {
      Write-Host "AntispywareEnabled       : $AntispywareEnabled" -ForegroundColor Yellow
   }
   Else
   {
      Write-Host "AntispywareEnabled       : $AntispywareEnabled" -ForegroundColor Green   
   }
   If($ConState -iMatch 'Enabled')
   {
      Write-Host "ConstrainedLanguage      : $ConState" -ForegroundColor Yellow
   }
   Else
   {
      Write-Host "ConstrainedLanguage      : $ConState" -ForegroundColor Green   
   }
   Write-Host "DisableScriptScanning    : $DisableScriptScanning"
   Write-Host "BehaviorMonitorEnabled   : $BehaviorMonitorEnabled"
   Write-Host "DisableArchiveScanning   : $DisableArchiveScanning"
   If($DEPSETTINGS -iMatch 'True')
   {
      Write-Host "DataExecutionPrevention  : Active" -ForegroundColor Yellow   
   }
   Else
   {
      Write-Host "DataExecutionPrevention  : Disabled" -ForegroundColor Green    
   }
}


#Common security processes DataTable!
Write-Host "`nSecurity processes running!" -ForeGroundColor Green
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
   $FileVersion = (Get-Process -Name "$Item" -EA SilentlyContinue).ProductVersion


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

      .OUTPUTS
         Security processes running!
         Pid  ProcessName Version   Product             EDR             
         ---  ----------- -------   -------             ---
         4300 cmdguard    10.184.78 Firewall            Comodo Security
         8945 CSFalcon    94.132.1  Behavioral Analysis CrowdStrike Falcon EDR
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
                           "Comodo Security"           ## Product

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

   .NOTES
      Drivers common locations
      'C:\Windows\System32\drivers'
      'C:\Windows\System32\drivers\wd'

   .OUTPUTS
      Hunting for EDR drivers!
      Driver        Version      EDR             
      ------------- ------------ ---             
      WdBoot.sys    4.18.1909.6  Windows Defender
      WdDevFlt.sys  4.18.2202.4  Windows Defender
      WdFilter.sys  4.18.1909.6  Windows Defender
      WdNisDrv.sys  4.18.1909.6  Windows Defender
   #>

   #Function Banner
   Write-Host "Hunting for EDR drivers!" -ForeGroundColor Green

   #Build Drivers DataTable!
   $DriversTable = New-Object System.Data.DataTable
   $DriversTable.Columns.Add("Driver       ")|Out-Null
   $DriversTable.Columns.Add("Version     ")|Out-Null
   $DriversTable.Columns.Add("EDR")|Out-Null

   #Local Drivers Default Location (Recursive)
   $DriversPath = "$Env:SYSTEMDRIVE\Windows\System32\drivers"
   $DriversList = ((Get-ChildItem -Path "$DriversPath" -Recurse -Force | Where-Object { 
      $_.Name -iMatch '(.sys)$' -and $_.FullName -iNotMatch '(etc|UMDF|DriverData|ru-RU|pt-PT)' }).Name)

   ## Delete duplicated entrys (driver.sys)
   # In my system Windows Defender puts is drivers
   # inside 'drivers' and 'wd' folders (duplicated)
   $FinalDrivers = $DriversList | Sort | Get-Unique


   #Loop trough all driver names
   ForEach($DriverName in $FinalDrivers)
   {
   
      #Get driver product version (recursive)
      $Dversion = ((Get-ChildItem -Path "$DriversPath\$DriverName" -Recurse -Force | Select *).VersionInfo.ProductVersion | Select -Last 1)

      If($DriverName -iMatch '^(atrsdfw.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",    ## DriverName
                               "$Dversion",       ## FileVersion
                               "Altiris Symantec" ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(avgtpx86.sys|avgtpx64.sys)$')
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
      If($DriverName -iMatch '^(CarbonBlackK.sys|parity.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Carbon Black"      ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(csacentr.sys|csaenh.sys|csareg.sys|csascr.sys|csaav.sys|csaam.sys)$')
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
      If($DriverName -iMatch '^(cfrmd.sys|cmdccav.sys|cmdguard.sys|CmdMnEfs.sys|MyDLPMF.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Comodo Security"   ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(im.sys|CSDeviceControl.sys|csagent.sys)$')
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
      If($DriverName -iMatch '^(CyOptics.sys|CyProtectDrv32.sys|CyProtectDrv64.sys.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Cylance Inc."      ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(groundling32.sys|groundling64.sys)$')
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
      If($DriverName -iMatch '^(edevmon.sys|ehdrv.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "ESET"              ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(FeKern.sys|WFP_MRT.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "FireEye"           ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(xfsgk.sys|fsatp.sys|fshs.sys)$')
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
      If($DriverName -iMatch '^(klifks.sys|klifaa.sys|Klifsm.sys)$')
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
      If($DriverName -iMatch '^(mfeaskm.sys|mfencfilter.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "McAfee"            ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(amm6460.sys|amm8660.sys|amfsm.sys|PSINPROC.sys|PSINFILE.sys)$')
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
      If($DriverName -iMatch '^(sld.sys|savonaccess.sys|SAVOnAccess.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",     ## DriverName
                               "$Dversion",        ## FileVersion
                               "Sophos"            ## EDR name
         )|Out-Null
      }
      If($DriverName -iMatch '^(fencry.sys|pgpfs.sys|VFSEnc.sys|GEFCMP.sys|evmf.sys|SymHsm.sys|symefa64.sys|symefa.sys|symefasi.sys|SymAFR.sys|VirtFile.sys|vxfsrep.sys|symevent.sys|bhdrvx64.sys|bhdrvx86.sys|spbbcdrv.sys|reghook.sys|emxdrv2.sys|ssrfsf.sys|sysMon.sys|diflt.sys|pgpwdefs.sys|GEProtection.sys)$')
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

      ##### --------DEFENDER -------------------
      If($DriverName -iMatch '(WdBoot.sys|WdDevFlt.sys|WdFilter.sys|WdNisDrv.sys|hvsifltr.sys)$')
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
      write-host "x" -ForegroundColor Red -NoNewline;
      write-host " No known EDR drivers found?.." -ForegroundColor DarkGray;
   }
   Else
   {
      #Display Table
      $DriversTable | Format-Table -AutoSize | Out-String -Stream | Select -Skip 1 | Select -SkipLast 2 | ForEach-Object {
         $stringformat = If($_ -Match '^(Driver)')
         {
            @{ 'ForegroundColor' = 'Yellow' }
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