<#
.SYNOPSIS
   List common security processes running!

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Get-WmiObject, Get-Process {native}
   Optional Dependencies: Get-MpPreference, Get-ChildItem {native}
   PS cmdlet Dev version: v2.3.18

.DESCRIPTION
   This cmdlet enumerates Anti Virus (EDR's) using three different techniques.
   By default it invokes Get-WmiObject cmdlet to find out which is the primary antivirus
   installed, as second technique the Get-Process cmdlet is invoked to search for running
   processes associated with known EDR's names, as third technique the Get-ChildItem cmdlet
   is invoked to recursive search for drivers.sys names associated with known EDR's products.

.NOTES
   Invoking -action 'verbose' triggers cmdlet to hunt for common security processes running,
   AppWhitelisting, Behavioral Analysis, Intrusion Detection Firewall, Defender preferences,
   DEP, DLP, HIPS and Hunt for EDR's by driver name. ( accurate\recomended, but slow scan )

   Invoking -stringsearch 'true' -string 'Defender|antimalware|spyware' arguments, triggers
   cmdlet to recursive search for strings 'Defender|antimalware|spyware' inside drivers file
   description. ( fast scan but less accurate that -action 'verbose' parameter scans )

.Parameter Action
   Accepts arguments: Enum, Verbose (default: Enum)

.Parameter StringSearch
   Accepts arguments: false, true (default: false)
   Remark: Activate string search on file description

.Parameter String
   Strings to search on file description (default: Defender|antimalware)
   Remark: Split diferent strings to search using the PIPE (|) command.

.Parameter Logfile
   Store reports on logfile? (defaut: false)

.EXAMPLE
   PS C:\> Get-Help .\GetCounterMeasures.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetCounterMeasures.ps1
   List security products processes running!

.EXAMPLE
   PS C:\> .\GetCounterMeasures.ps1 -action 'verbose'
   List common security product processes names, AppWhitelisting,
   Behavioral Analysis, EDR, DLP, Intrusion Detection, Firewall,
   HIPS, Defender Preferences and Hunt for EDR's by driver name.

.EXAMPLE
   PS C:\> .\GetCounterMeasures.ps1 -stringsearch 'true'
   Search for 'Defender|antimalware' strings on driver description 

.EXAMPLE
   PS C:\> .\GetCounterMeasures.ps1 -stringsearch 'true' -string 'Defender'
   Search for 'Defender' string on drivers description field

.EXAMPLE
   PS C:\> .\GetCounterMeasures.ps1 -stringsearch 'true' -string 'sandboxing' -logfile 'true'
   Search for 'sandboxing' string on drivers description field and store reports on logfile

.EXAMPLE
   PS C:\> .\GetCounterMeasures.ps1 -action 'verbose' -stringsearch 'true' -string 'Security'
   Trigger cmdlet full scans + string search (security) on drivers description field

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
   Suspicious Driver Module : WdBoot.sys
     Version                : 4.18.1909.6
     EDR                    : Windows Defender
     FileDescription        : Microsoft antimalware boot driver
     ProductName            : Microsoft® Windows® Operating System
     Directory              : C:\Windows\System32\drivers
     CreationTime           : 12/07/2019 00:00:00
     LastAccessTime         : 04/07/2022 00:00:00

   Suspicious Driver Module : WdDevFlt.sys
     Version                : 4.18.2202.4
     EDR                    : Windows Defender
     FileDescription        : Microsoft antimalware device filter driver
     ProductName            : Microsoft® Windows® Operating System
     Directory              : C:\Windows\System32\drivers\wd
     CreationTime           : 03/15/2022 00:00:00
     LastAccessTime         : 04/07/2022 00:00:00

.LINK
   https://www.shouldiremoveit.com/Cybereason-ActiveProbe-182827-program.aspx
   https://github.com/D4Vinci/Dr0p1t-Framework/blob/master/resources/killav.py
   https://github.com/rapid7/metasploit-framework/blob/master/scripts/meterpreter/getcountermeasure.rb
   https://gist.github.com/r00t-3xp10it/470c43d0d44253106706a06589f00bf7?permalink_comment_id=4125575#gistcomment-4125575
#>


#Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$String="Defender|antimalware",
   [string]$StringSearch="false",
   [string]$LogFile="false",
   [string]$Action="Enum"
)


$ppid = $null
$foundit = "False"
$ScanStartTimer = (Get-Date)
#Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$processnames = (Get-Process * -EA SilentlyContinue | Where-Object {
   $_.Responding -eq $True -and $_.ProcessName -ne $null -and $_.ProcessName -iNotMatch '(svchost|lsass|YourPhone|winlogon|wininit|RuntimeBroker|opera|firefox)'
}).ProcessName


#Primary Anti Virus Product Query Function
$wmiQuery = "SELECT * FROM AntiVirusProduct"
Write-Host "`nPrimary AntiVirus Product" -ForeGroundColor Green
$AntivirusProduct = Get-WmiObject -Namespace "root\SecurityCenter2" -Query $wmiQuery|Out-File $Env:TMP\Dav.meterpeter -Force
$PrimaryAV = Get-Content -Path $Env:TMP\Dav.meterpeter|Select-Object -Skip 2|Select-Object -SkipLast 3|findstr /V "__PATH __GENUS __SUPERCLASS __DYNASTY __RELPATH __PROPERTY_COUNT __DERIVATION __SERVER __NAMESPACE productState pathToSignedProductExe"
$Rand = -join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_})
Remove-Item -Path $Env:TMP\Dav.meterpeter -Force

If($LogFile -ieq "true")
{
   #Append data to logfile
   $Finalog = "$Rand" + "_CounterMeasures" + ".log" -join ''
   echo $PrimaryAV | Out-File "$Finalog" -Encoding string -Force
}

#Display Primary AV found settings On Screen
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
      Only triggers if invoked -action 'verbose' and the
      'Primary' Anti Virus detected is 'Windows Defender'

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
   #Append data to logfile
   If($LogFile -ieq "true")
   {
      echo "RealTimeEnabled          : $RealTimeProtectionEnabled" >> $Finalog
   }

   Write-Host "AMServiceEnabled         : $AMServiceEnabled"
   If($LogFile -ieq "true")
   {
      echo "AMServiceEnabled         : $AMServiceEnabled" >> $Finalog
   }

   If($AntivirusEnabled -iMatch 'True')
   {
      Write-Host "AntivirusEnabled         : $AntivirusEnabled" -ForegroundColor Yellow
   }
   Else
   {
      Write-Host "AntivirusEnabled         : $AntivirusEnabled" -ForegroundColor Green   
   }
   #Append data to logfile
   If($LogFile -ieq "true")
   {
      echo "AntivirusEnabled         : $AntivirusEnabled" >> $Finalog
   }

   If($IsTamperProtected -iMatch 'True')
   {
      Write-Host "IsTamperProtected        : $IsTamperProtected"
   }
   Else
   {
      Write-Host "IsTamperProtected        : $IsTamperProtected" -ForegroundColor Green   
   }
   #Append data to logfile
   If($LogFile -ieq "true")
   {
      echo "IsTamperProtected        : $IsTamperProtected" >> $Finalog
   }

   If($AntispywareEnabled -iMatch 'True')
   {
      Write-Host "AntispywareEnabled       : $AntispywareEnabled" -ForegroundColor Yellow
   }
   Else
   {
      Write-Host "AntispywareEnabled       : $AntispywareEnabled" -ForegroundColor Green   
   }
   #Append data to logfile
   If($LogFile -ieq "true")
   {
      echo "AntispywareEnabled       : $AntispywareEnabled" >> $Finalog
   }

   If($ConState -iMatch 'Enabled')
   {
      Write-Host "ConstrainedLanguage      : $ConState" -ForegroundColor Yellow
   }
   Else
   {
      Write-Host "ConstrainedLanguage      : $ConState" -ForegroundColor Green   
   }
   #Append data to logfile
   If($LogFile -ieq "true")
   {
      echo "ConstrainedLanguage      : $ConState" >> $Finalog
   }

   Write-Host "DisableScriptScanning    : $DisableScriptScanning"
   Write-Host "BehaviorMonitorEnabled   : $BehaviorMonitorEnabled"
   Write-Host "DisableArchiveScanning   : $DisableArchiveScanning"
   If($LogFile -ieq "true")
   {
      #Append data to logfile
      echo "DisableScriptScanning    : $DisableScriptScanning" >> $Finalog
      echo "BehaviorMonitorEnabled   : $BehaviorMonitorEnabled" >> $Finalog
      echo "DisableArchiveScanning   : $DisableArchiveScanning" >> $Finalog
   }

   If($DEPSETTINGS -iMatch 'True')
   {
      Write-Host "DataExecutionPrevention  : Active" -ForegroundColor Yellow
      If($LogFile -ieq "true"){echo "DataExecutionPrevention  : Active" >> $Finalog}         
   }
   Else
   {
      Write-Host "DataExecutionPrevention  : Disabled" -ForegroundColor Green
      If($LogFile -ieq "true"){echo "DataExecutionPrevention  : Disabled" >> $Finalog}
   }

}


#Common security processes running DataTable!
Write-Host "`nSecurity processes running!" -ForeGroundColor Green
$mytable = New-Object System.Data.DataTable
$mytable.Columns.Add("Pid")|Out-Null
$mytable.Columns.Add("ProcessName")|Out-Null
$mytable.Columns.Add("Version")|Out-Null
$mytable.Columns.Add("Product")|Out-Null
$mytable.Columns.Add("EDR")|Out-Null


ForEach($Item in $processnames)
{
   #Get process PID identifier's from ProcessName's!
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
   If(($Item -iMatch "^(superantispyware|SSUpdate|SSUpdate64|SASTask)"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "superantispyware" ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(xagt)"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "FireEye Endpoint" ## Product

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
   If(($Item -iMatch "^(DrWeb|Dwnetfilter|dwscancl|dwsysinfo|dwscanner|dwservice|spideragent)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "$FileVersion", ## FileVersion
                        "Anti-Virus",   ## Description
                        "DrWeb AV"      ## Product

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
   If(($Item -iMatch "^(CrAmTray|minionhost|PylumLoader|CrsSvc)"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",                     ## PID
                        "$Item",                     ## ProcessName
                        "$FileVersion",              ## FileVersion
                        "Anti-Virus",                ## Description
                        "Cybereason"                 ## Product

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
         Author: @r00t-3xp10it
         Helper - List AppWhitelisting, Behavioral Analysis
         Intrusion Detection, Firewall Process, DLP, EDR, HIPS

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
      If(($Item -iMatch "^(frwl_notify|frwl_svc)$")) 
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                       ## PID
                           "$Item",                       ## ProcessName
                           "$FileVersion",                ## FileVersion
                           "Firewall",                    ## Description
                           "Dr.Web Firewall"              ## Product

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
   write-host "x" -ForegroundColor Red -NoNewline;
   write-host " none security products found running?.." -ForegroundColor DarkGray;
   Write-Host ""
}
Else
{

   If($LogFile -ieq "true")
   {
      #Append data to logfile
      echo $mytable | Format-Table -AutoSize | Out-String -Stream | Select -SkipLast 1 >> $Finalog
   }

   #Display data table on screen
   $mytable | Format-Table -AutoSize | Out-String -Stream | Select -Skip 1 | Select -SkipLast 1 | ForEach-Object {
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
      Credits: @BankSecurity (research)
      Helper - Check EDR by driver name existence!

   .NOTES
      Drivers common locations
      'C:\Windows\System32\drivers'
      'C:\Windows\System32\drivers\wd'

   .OUTPUTS
      Hunting for EDR drivers!
      Suspicious Driver Module : WdBoot.sys
        Version                : 4.18.1909.6
        EDR                    : Windows Defender
        FileDescription        : Microsoft antimalware boot driver
        ProductName            : Microsoft® Windows® Operating System
        Directory              : C:\Windows\System32\drivers
        CreationTime           : 12/07/2019 00:00:00
        LastAccessTime         : 04/07/2022 00:00:00

      Suspicious Driver Module : WdDevFlt.sys
        Version                : 4.18.2202.4
        EDR                    : Windows Defender
        FileDescription        : Microsoft antimalware device filter driver
        ProductName            : Microsoft® Windows® Operating System
        Directory              : C:\Windows\System32\drivers\wd
        CreationTime           : 03/15/2022 00:00:00
        LastAccessTime         : 04/07/2022 00:00:00
   #>

   #Function Banner
   Write-Host "Hunting for EDR drivers!" -ForeGroundColor Green

   #Build Drivers DataTable!
   $DriversTable = New-Object System.Data.DataTable
   $DriversTable.Columns.Add("Suspicious Driver Module")|Out-Null
   $DriversTable.Columns.Add("  Version")|Out-Null
   $DriversTable.Columns.Add("  EDR")|Out-Null
   $DriversTable.Columns.Add("  FileDescription")|Out-Null
   $DriversTable.Columns.Add("  ProductName")|Out-Null
   $DriversTable.Columns.Add("  Directory")|Out-Null
   $DriversTable.Columns.Add("  CreationTime")|Out-Null
   $DriversTable.Columns.Add("  LastAccessTime")|Out-Null

   #Local Drivers Default Location (Recursive search)
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
      #Get driver metadata
      $AllSettings = ((Get-ChildItem -Path "$DriversPath\$DriverName" -Recurse -Force | Select-Object * | Where-Object {$_ -ne ''}))
      $FileDirectory = $AllSettings.Directory | Select-Object -Last 1                     #Driver directory
      $FileCreationTime = $AllSettings.CreationTime.Date | Select-Object -Last 1          #Driver CreationTime
      $FileProduct = $AllSettings.VersionInfo.ProductName | Select-Object -Last 1         #Driver ProductName
      $Dversion = $AllSettings.VersionInfo.ProductVersion | Select-Object -Last 1         #Driver version
      $FileLastAccessTime = $AllSettings.LastAccessTime.Date | Select-Object -Last 1      #Driver LastAccessTime
      $FileDescription = $AllSettings.VersionInfo.FileDescription | Select-Object -Last 1 #Driver Description

      If($DriverName -iMatch '^(dwdg.sys|spiderg3.sys|A4B1FF85CA.sys|dwprot.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "DrWeb",               ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(tmeyes.sys|TMUMH.sys|tmusa.sys|tmnciesc.sys|TMEBC64.sys|tmeevw.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "TrendMicro Antimalware",  ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(nsWscSvc.sys|SYMEFASI64.sys|SymEvnt.sys|SYMEVENT64x86.sys|SRTSPX64.sys|SRTSP.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Norton Antimalware",  ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(avipbb.sys|avkmgr.sys|avgntflt.sys|avdevprot.sys|avusbflt.sys|avnetflt.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Avira Antimalware",   ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(atrsdfw.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Altiris Symantec",    ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(sasdifsv64.sys|saskutil64.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "SUPERAntiSpyware",    ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(avgtpx86.sys|avgtpx64.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "AVG Technologies",    ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(naswSP.sys|aswArPot.sys|aswbidsdriver.sys|aswbidsh.sys|aswbuniv.sys|aswKbd.sys|aswMonFlt.sys|aswNetHub.sys|aswRdr2.sys|aswSnx.sys|aswSP.sys|aswStm.sys|aswVmm.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Avast",               ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(atc.sys|gemma.sys|edrsensor.sys|bdfndisf6.sys|bdfwfpf.sys|avc3.sys|avckf.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "BitDefender SRL",     ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(CarbonBlackK.sys|parity.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Carbon Black",        ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(csacentr.sys|csaenh.sys|csareg.sys|csascr.sys|csaav.sys|csaam.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Cisco",               ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(rvsavd.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "CJSC Returnil Software", ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(cfrmd.sys|cmdccav.sys|cmdguard.sys|CmdMnEfs.sys|MyDLPMF.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Comodo Security",     ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(im.sys|CSDeviceControl.sys|csagent.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "CrowdStrike",         ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(CybKernelTracker.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "CyberArk Software",   ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(CRExecPrev.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Cybereason",          ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(CyOptics.sys|CyProtectDrv32.sys|CyProtectDrv64.sys.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Cylance Inc.",        ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(groundling32.sys|groundling64.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Dell Secureworks",    ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(esensor.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Endgame",             ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(edevmon.sys|ehdrv.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "ESET",                ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(FeKern.sys|WFP_MRT.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "FireEye",             ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(xfsgk.sys|fsatp.sys|fshs.sys|fsulgk.sys|nif2s64.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "F-Secure",            ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(HexisFSMonitor.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Hexis Cyber Solutions", ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(klifks.sys|klifaa.sys|Klifsm.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Kaspersky",           ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(mwac.sys|mbamswissarmy.sys|mbam.sys|MbamChameleon.sys|farflt.sys|mbamwatchdog.sys|mbae.sys|mbae64.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Malwarebytes",        ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(mfeaskm.sys|mfencfilter.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "McAfee",              ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(amm6460.sys|amm8660.sys|amfsm.sys|PSINPROC.sys|PSINFILE.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Panda Security",      ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(eaw.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Raytheon Cyber Solutions",   ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(SAFE-Agent.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "SAFE-Cyberdefense",   ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(SentinelMonitor.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "SentinelOne",         ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(sld.sys|savonaccess.sys|SAVOnAccess.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Sophos",              ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(fencry.sys|pgpfs.sys|VFSEnc.sys|GEFCMP.sys|evmf.sys|SymHsm.sys|symefa64.sys|symefa.sys|symefasi.sys|SymAFR.sys|VirtFile.sys|vxfsrep.sys|symevent.sys|bhdrvx64.sys|bhdrvx86.sys|spbbcdrv.sys|reghook.sys|emxdrv2.sys|ssrfsf.sys|sysMon.sys|diflt.sys|pgpwdefs.sys|GEProtection.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Symantec",            ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(ndgdmk.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Verdasys Inc",        ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      If($DriverName -iMatch '^(ssfmonm.sys|pwipf6.sys|WRCore.x64.sys|WRkrn.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Webroot Software",    ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
         )|Out-Null
      }
      ##### -------------- DEFENDER -------------------
      If($DriverName -iMatch '(WdBoot.sys|WdDevFlt.sys|WdFilter.sys|WdNisDrv.sys|hvsifltr.sys)$')
      {
         ## Adding values to output DataTable!
         $DriversTable.Rows.Add("$DriverName",         ## Driver Name
                                "$Dversion",           ## File Version
                                "Windows Defender",    ## EDR Name
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
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

      If($LogFile -ieq "true")
      {
         #Append data to logfile
         echo $DriversTable | Format-List | Out-String -Stream | Select -Skip 2 | Select -SkipLast 1 >> $Finalog
      }

      #Display data table on screen
      $DriversTable | Format-List | Out-String -Stream | Select -Skip 2 | Select -SkipLast 1 | ForEach-Object {
         $stringformat = If($_ -Match '^(Suspicious Driver Module)')
         {
            @{ 'ForegroundColor' = 'Yellow' }
         }
         ElseIf($_ -Match '^(  EDR)')
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


If($StringSearch -ieq "true")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Hunt for strings on drivers file description

   .OUTPUTS
      Hunting for suspicious strings!
      Suspicious Driver Module : WdBoot.sys
        Version                : 4.18.1909.6
        EDR                    : Windows Defender
        String                 : Defender|antimalware
        FileDescription        : Microsoft antimalware boot driver
        ProductName            : Microsoft® Windows® Operating System
        Directory              : C:\Windows\System32\drivers
        CreationTime           : 12/07/2019 00:00:00
        LastAccessTime         : 04/07/2022 00:00:00

      Suspicious Driver Module : WdDevFlt.sys
        Version                : 4.18.2202.4
        EDR                    : Windows Defender
        String                 : Defender|antimalware
        FileDescription        : Microsoft antimalware device filter driver
        ProductName            : Microsoft® Windows® Operating System
        Directory              : C:\Windows\System32\drivers\wd
        CreationTime           : 03/15/2022 00:00:00
        LastAccessTime         : 04/07/2022 00:00:00
   #>

   #Function Banner
   Write-Host "Hunting for suspicious strings!" -ForeGroundColor Green
   Start-Sleep -Seconds 1

   #Build Drivers DataTable!
   $SuspiciousTable = New-Object System.Data.DataTable
   $SuspiciousTable.Columns.Add("Suspicious Driver Module")|Out-Null
   $SuspiciousTable.Columns.Add("  Version")|Out-Null
   $SuspiciousTable.Columns.Add("  EDR")|Out-Null
   $SuspiciousTable.Columns.Add("  String")|Out-Null
   $SuspiciousTable.Columns.Add("  FileDescription")|Out-Null
   $SuspiciousTable.Columns.Add("  ProductName")|Out-Null
   $SuspiciousTable.Columns.Add("  Directory")|Out-Null
   $SuspiciousTable.Columns.Add("  CreationTime")|Out-Null
   $SuspiciousTable.Columns.Add("  LastAccessTime")|Out-Null

   If($String -ne "Defender|antimalware")
   {
      $SuspiciousStrings = "$String"
   }
   Else
   {
      $SuspiciousStrings = "Defender|antimalware"
   }

   #Local Drivers Default Location (Recursive search)
   $DriversPath = "$Env:SYSTEMDRIVE\Windows\System32\drivers"
   $DriversList = ((Get-ChildItem -Path "$DriversPath" -Recurse -Force | Where-Object { 
      $_.Name -iMatch '(.sys)$' -and $_.VersionInfo.FileDescription -iMatch "($SuspiciousStrings)" }).Name)

   ## Delete duplicated entrys (driver.sys)
   # In my system Windows Defender puts is drivers
   # inside 'drivers' and 'wd' folders (duplicated)
   $FinalDrivers = $DriversList | Sort | Get-Unique

   ForEach($ItemFound in $FinalDrivers)
   {
      #Get driver metadata
      $AllSettings = ((Get-ChildItem -Path "$DriversPath\$ItemFound" -Recurse -Force | Select-Object * | Where-Object {$_ -ne ''}))
      $FileDirectory = $AllSettings.Directory | Select-Object -Last 1                     #Driver directory
      $FileCreationTime = $AllSettings.CreationTime.Date | Select-Object -Last 1          #Driver CreationTime
      $FileProduct = $AllSettings.VersionInfo.ProductName | Select-Object -Last 1         #Driver ProductName
      $Dversion = $AllSettings.VersionInfo.ProductVersion | Select-Object -Last 1         #Driver version
      $FileLastAccessTime = $AllSettings.LastAccessTime.Date | Select-Object -Last 1      #Driver LastAccessTime
      $FileDescription = $AllSettings.VersionInfo.FileDescription | Select-Object -Last 1 #Driver Description   

      #Define EDR name based on driver name
      If($ItemFound -iMatch '^(atrsdfw.sys)$')
      {
         $EDRreport = "Altiris Symantec"
      }
      ElseIf($ItemFound -iMatch '^(sasdifsv64.sys|saskutil64.sys)$')
      {
         $EDRreport = "SUPERAntiSpyware"      
      }
      ElseIf($ItemFound -iMatch '^(WdBoot.sys|WdDevFlt.sys|WdFilter.sys|WdNisDrv.sys|hvsifltr.sys)$')
      {
         $EDRreport = "Windows Defender"      
      }
      ElseIf($ItemFound -iMatch '^(avgtpx86.sys|avgtpx64.sys)$')
      {
         $EDRreport = "AVG Technologies"      
      }
      ElseIf($ItemFound -iMatch '^(naswSP.sys)$')
      {
         $EDRreport = "Avast"      
      }
      ElseIf($ItemFound -iMatch '^(edrsensor.sys|bdfndisf6.sys|bdfwfpf.sys|avc3.sys|avckf.sys)$')
      {
         $EDRreport = "BitDefender SRL"      
      }
      ElseIf($ItemFound -iMatch '^(CarbonBlackK.sys|parity.sy)$')
      {
         $EDRreport = "Carbon Black"      
      }
      ElseIf($ItemFound -iMatch '^(csacentr.sys|csaenh.sys|csareg.sys|csascr.sys|csaav.sys|csaam.sys)$')
      {
         $EDRreport = "Cisco"      
      }
      ElseIf($ItemFound -iMatch '^(rvsavd.sys)$')
      {
         $EDRreport = "CJSC Returnil Software"      
      }
      ElseIf($ItemFound -iMatch '^(cfrmd.sys|cmdccav.sys|cmdguard.sys|CmdMnEfs.sys|MyDLPMF.sys)$')
      {
         $EDRreport = "Comodo Security"      
      }
      ElseIf($ItemFound -iMatch '^(im.sys|CSDeviceControl.sys|csagent.sys)$')
      {
         $EDRreport = "CrowdStrike"      
      }
      ElseIf($ItemFound -iMatch '^(CybKernelTracker.sys)$')
      {
         $EDRreport = "CyberArk Software"      
      }
      ElseIf($ItemFound -iMatch '^(CRExecPrev.sys)$')
      {
         $EDRreport = "Cybereason"      
      }
      ElseIf($ItemFound -iMatch '^(CyOptics.sys|CyProtectDrv32.sys|CyProtectDrv64.sys.sys)$')
      {
         $EDRreport = "Cylance Inc."      
      }
      ElseIf($ItemFound -iMatch '^(groundling32.sys|groundling64.sys)$')
      {
         $EDRreport = "Dell Secureworks"      
      }
      ElseIf($ItemFound -iMatch '^(esensor.sys)$')
      {
         $EDRreport = "Endgame"      
      }
      ElseIf($ItemFound -iMatch '^(edevmon.sys|ehdrv.sys)$')
      {
         $EDRreport = "ESET"      
      }
      ElseIf($ItemFound -iMatch '^(FeKern.sys|WFP_MRT.sys)$')
      {
         $EDRreport = "FireEye"      
      }
      ElseIf($ItemFound -iMatch '^(xfsgk.sys|fsatp.sys|fshs.sys)$')
      {
         $EDRreport = "F-Secure"      
      }
      ElseIf($ItemFound -iMatch '^(HexisFSMonitor.sys)$')
      {
         $EDRreport = "Hexis Cyber Solutions"      
      }
      ElseIf($ItemFound -iMatch '^(klifks.sys|klifaa.sys|Klifsm.sys)$')
      {
         $EDRreport = "Kaspersky"      
      }
      ElseIf($ItemFound -iMatch '^(mbamwatchdog.sys|mbae.sys|mbae64.sys)$')
      {
         $EDRreport = "Malwarebytes"      
      }
      ElseIf($ItemFound -iMatch '^(mfeaskm.sys|mfencfilter.sys)$')
      {
         $EDRreport = "McAfee"      
      }
      ElseIf($ItemFound -iMatch '^(amm6460.sys|amm8660.sys|amfsm.sys|PSINPROC.sys|PSINFILE.sys)$')
      {
         $EDRreport = "Panda Security"      
      }
      ElseIf($ItemFound -iMatch '^(eaw.sys)$')
      {
         $EDRreport = "Raytheon Cyber Solutions"      
      }
      ElseIf($ItemFound -iMatch '^(SAFE-Agent.sys)$')
      {
         $EDRreport = "SAFE-Cyberdefense"      
      }
      ElseIf($ItemFound -iMatch '^(SentinelMonitor.sys)$')
      {
         $EDRreport = "SentinelOne"      
      }
      ElseIf($ItemFound -iMatch '^(sld.sys|savonaccess.sys|SAVOnAccess.sys)$')
      {
         $EDRreport = "Sophos"      
      }
      ElseIf($ItemFound -iMatch '^(fencry.sys|pgpfs.sys|VFSEnc.sys|GEFCMP.sys|evmf.sys|SymHsm.sys|symefa64.sys|symefa.sys|symefasi.sys|SymAFR.sys|VirtFile.sys|vxfsrep.sys|symevent.sys|bhdrvx64.sys|bhdrvx86.sys|spbbcdrv.sys|reghook.sys|emxdrv2.sys|ssrfsf.sys|sysMon.sys|diflt.sys|pgpwdefs.sys|GEProtection.sys)$')
      {
         $EDRreport = "Symantec"      
      }
      ElseIf($ItemFound -iMatch '^(ndgdmk.sys)$')
      {
         $EDRreport = "Verdasys Inc"      
      }
      ElseIf($ItemFound -iMatch '^(ssfmonm.sys|pwipf6.sys)$')
      {
         $EDRreport = "Webroot Software"      
      }
      Else
      {
         $EDRreport = "Unknow EDR Product"      
      }

      ## Adding values to output DataTable!
      $SuspiciousTable.Rows.Add("$ItemFound",          ## Driver Name
                                "$Dversion",           ## File Version
                                "$EDRreport",          ## EDR name
                                "$SuspiciousStrings",  ## String to search in filedescription
                                "$FileDescription",    ## File Description
                                "$FileProduct",        ## File Product
                                "$FileDirectory",      ## File Directory
                                "$FileCreationTime",   ## File CreationTime
                                "$FileLastAccessTime"  ## File LastAccessTime
      )|Out-Null
   }


   [array]$CheckTableData = $SuspiciousTable
   If(($CheckTableData|Measure-Object).Count -lt 1)
   {
      write-host "x" -ForegroundColor Red -NoNewline;
      write-host " No known EDR drivers found that match search criteria.." -ForegroundColor DarkGray;
   }
   Else
   {

      If($LogFile -ieq "true")
      {
         #Append data to logfile
         echo "Hunting for suspicious strings!" >> $Finalog
         echo $SuspiciousTable | Format-List | Out-String -Stream | Select -Skip 2 >> $Finalog
      }

      #Display data table on screen
      $SuspiciousTable | Format-List | Out-String -Stream | Select -Skip 2 | Select -SkipLast 1 | ForEach-Object {
         $stringformat = If($_ -Match '^(Suspicious Driver Module)')
         {
            @{ 'ForegroundColor' = 'Yellow' }
         }
         ElseIf($_ -Match '^(  FileDescription|  String)')
         {
            @{ 'ForegroundColor' = 'DarkYellow' }         
         }
         ElseIf($_ -Match '(Unknow EDR Product)')
         {
            @{ 'ForegroundColor' = 'Red' }         
         }
         ElseIf($_ -Match '^(  EDR)')
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

#Internal CmdLet Clock Timmer
$ElapsTime = $(Get-Date) - $ScanStartTimer
$TotalTime = "{0:HH:mm:ss}" -f ([datetime]$ElapsTime.Ticks) #Count the diferense between 'start|end' scan duration!
write-host "`n*" -ForegroundColor Yellow -BackgroundColor Black -NoNewline;
Write-Host " ElapsedTime:" -ForegroundColor Blue -BackgroundColor Black -NoNewline;
Write-Host "$TotalTime" -ForegroundColor Green -BackgroundColor Black -NoNewline;
Write-Host " - scantype:" -ForegroundColor Blue -BackgroundColor Black -NoNewline;
If($StringSearch -ieq "true")
{
   Write-Host "StringSearch" -ForegroundColor Green -BackgroundColor Black;
}
Else
{
   Write-Host "$Action" -ForegroundColor Green -BackgroundColor Black;
}

If($LogFile -ieq "true")
{
   write-host "* " -ForegroundColor Green -NoNewline;
   write-host "Logfile storage: '" -ForegroundColor DarkGray -NoNewline;
   write-host "$Finalog" -ForegroundColor Green -NoNewline;
   write-host "'" -ForegroundColor DarkGray;
}