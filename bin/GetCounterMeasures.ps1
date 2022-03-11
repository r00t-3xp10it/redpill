<#
.SYNOPSIS
   List common security processes running!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Get-Process {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.1.11

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
$mytable.Columns.Add("Product")|Out-Null
$mytable.Columns.Add("FileVersion")|Out-Null
$mytable.Columns.Add("Description")|Out-Null


ForEach($Item in $processnames)
{
   #write-host "$Item" -ForegroundColor Green -BackgroundColor Black
   ## Get process PID identifier's from ProcessName's!
   $ppid = (Get-Process -Name "$Item" -EA SilentlyContinue).Id
   $FileVersion = (Get-Process -Name "$Item" -EA SilentlyContinue).FileVersion


   If($Item -iMatch "^(F-PROT)$")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$Item",           ## ProcessName
                        "Anti-Virus",      ## Description
                        "$FileVersion",    ## FileVersion
                        "F-Prot AntiVirus" ## Product

      )|Out-Null
   }
   If($Item -iMatch "^(nspupsvc)$")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "nProtect"      ## Product

      )|Out-Null
   }
   If($Item -iMatch "^(SpywareTerminatorShield)$")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",            ## PID
                        "$Item",            ## ProcessName
                        "Anti-Virus",       ## Description
                        "$FileVersion",     ## FileVersion
                        "SpywareTerminator" ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(AVK|AVKCl|GDScan|AVKWCtl|AVKBackupService)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "GData"         ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(f-secure|fsavgui)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "f-secure"      ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(mghtml|msssrv|mcagent|oasclnt|mpftray|mcdetect|mscifapp|mcshield)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "McAfee AV"     ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(msmpsvc|MSASCui|MsMpEng|windefend)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",              ## PID
                        "$Item",              ## ProcessName
                        "Anti-Virus",         ## Description
                        "$FileVersion",       ## FileVersion
                        "Windows Defender AV" ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(WRSA|WebrootWRSA)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "WebRoot AV"    ## Product

      )|Out-Null
   }
   If($Item -iMatch "^(swdoctor)$")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",             ## PID
                        "$Item",             ## ProcessName
                        "Anti-Virus",        ## Description
                        "$FileVersion",      ## FileVersion
                        "Spyware Doctor AV"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(sbiectrl|savservice)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "Sophos AV"     ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(TMCCSF|ofcdog|TmListen|pcclient|NTRtScan)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",         ## PID
                        "$Item",         ## ProcessName
                        "Anti-Virus",    ## Description
                        "$FileVersion",  ## FileVersion
                        "Trend Micro AV" ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(SMC|Rtvscan|usrprmpt|symlcsvc|ccSvcHst|SymCorpUI|symantec antivirus)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "Symantec AV"   ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(mbae|mbam|mbamtray)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",                    ## PID
                        "$Item",                    ## ProcessName
                        "Anti-Virus",               ## Description
                        "$FileVersion",             ## FileVersion
                        "MalwareBytes Anti-Exploit" ## Product

      )|Out-Null
   }
   If($Item -iMatch "^(adaware)$")
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "Adaware AV"    ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(drwatson|Drwtsn32)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",       ## PID
                        "$Item",       ## ProcessName
                        "Anti-Virus",  ## Description
                        "$FileVersion",## FileVersion
                        "DrWatson AV"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(nod32|nod32krn)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "Nod32 AV"      ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(avastUI|ashdisp|ashmaisv|aswupdsv)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "Avast AV"      ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(atrack|cfgwiz|navapsvc|bootwarn|nprotect|csinsmnt|NortonSecurity)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "Norton AV"     ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(PSUAMain|pavfnsvr)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",          ## PID
                        "$Item",          ## ProcessName
                        "Anti-Virus",     ## Description
                        "$FileVersion",   ## FileVersion
                        "Panda Cloud AV"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(avp|kav|avpm|Kavss|kavsvc)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "Kaspersky AV"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(avgcc|aavgapi|avgamsvr|avgagent|avgctrl)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$Item",           ## ProcessName
                        "Anti-Virus",      ## Description
                        "$FileVersion",    ## FileVersion
                        "AVG Security AV"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(aawtray|ad-watch|ad-aware|aawservice)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "Ad-Aware AV"   ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(a2cfg|a2guard|a2adguard|a2adwizard|a2antidialer)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$Item",           ## ProcessName
                        "Anti-Virus",      ## Description
                        "$FileVersion",    ## FileVersion
                        "A-squared Guard"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(a2scan|a2start|a2service|a2hijackfree)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "Emsisoft AV"   ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(sched|avguard|savscan)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",        ## PID
                        "$Item",        ## ProcessName
                        "Anti-Virus",   ## Description
                        "$FileVersion", ## FileVersion
                        "Avira AV"      ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(bdss|bdmcon|bdagent|bdnagent|livesrv)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",          ## PID
                        "$Item",          ## ProcessName
                        "Anti-Virus",     ## Description
                        "$FileVersion",   ## FileVersion
                        "Bitdefender AV"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(clamd|clamtray|clamservice)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",           ## PID
                        "$Item",           ## ProcessName
                        "Anti-Virus",      ## Description
                        "$FileVersion",    ## FileVersion
                        "ClamAV security"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(sdhelp|teatimer)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",                     ## PID
                        "$Item",                     ## ProcessName
                        "Anti-Spywear",              ## Description
                        "$FileVersion",              ## FileVersion
                        "Spybot - Search & Destroy"  ## Product

      )|Out-Null
   }
   If(($Item -iMatch "^(ssu|spysweeper)$"))
   {
      $foundit = "True"
      #Adding values to output DataTable!
      $mytable.Rows.Add("$ppid",               ## PID
                        "$Item",               ## ProcessName
                        "Anti-Spywear",        ## Description
                        "$FileVersion",        ## FileVersion
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
                           "AppWhitelisting",               ## Description
                           "$FileVersion",                  ## FileVersion
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
                           "Behavioral Analysis",              ## Description
                           "$FileVersion",                     ## FileVersion
                           "Carbon Black behavioral analysis"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(bds-vision)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                          ## PID
                           "$Item",                          ## ProcessName
                           "Behavioral Analysis",            ## Description
                           "$FileVersion",                   ## FileVersion
                           "BDS Vision behavioral analysis"  ## Product

         )|Out-Null
      } 
      If($Item -iMatch "^(Triumfant)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                         ## PID
                           "$Item",                         ## ProcessName
                           "Behavioral Analysis",           ## Description
                           "$FileVersion",                  ## FileVersion
                           "Triumfant behavioral analysis"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(CSFalcon)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                  ## PID
                           "$Item",                  ## ProcessName
                           "Behavioral Analysis",    ## Description
                           "$FileVersion",           ## FileVersion
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
                           "Intrusion Detection",       ## Description
                           "$FileVersion",              ## FileVersion
                           "OSSEC intrusion detection"  ## Product

         )|Out-Null
      }
      If(($Item -iMatch "^(defensewall|defensewall_serv)$"))
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                           ## PID
                           "$Item",                           ## ProcessName
                           "Intrusion Detection",             ## Description
                           "$FileVersion",                    ## FileVersion
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
                           "Firewall",                    ## Description
                           "$FileVersion",                ## FileVersion
                           "ZoneAlarm Security firewall"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(TmPfw)$") 
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                ## PID
                           "$Item",               ## ProcessName
                           "Firewall",             ## Description
                           "$FileVersion",         ## FileVersion
                           "Trend Micro firewall"  ## Product

         )|Out-Null
      }
      If(($Item -iMatch "^(cfp|cpf|cmdagent)$"))
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                    ## PID
                           "$Item",                    ## ProcessName
                           "Firewall",                 ## Description
                           "$FileVersion",             ## FileVersion
                           "Comodo Security firewall"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(msfwsvc)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                     ## PID
                           "$Item",                     ## ProcessName
                           "Firewall",                  ## Description
                           "$FileVersion",              ## FileVersion
                           "OneCare Security firewall"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(outpost)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                    ## PID
                           "$Item",                    ## ProcessName
                           "Firewall",                 ## Description
                           "$FileVersion",             ## FileVersion
                           "Agnitum Outpost Firewall"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(scfservice)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                  ## PID
                           "$Item",                 ## ProcessName
                           "Firewall",               ## Description
                           "$FileVersion",           ## FileVersion
                           "Sophos Client Firewall"  ## Product

         )|Out-Null
      }
      If(($Item -iMatch "^(umxcfg|umxagent)$"))
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",                ## PID
                           "$Item",                ## ProcessName
                           "Firewall",             ## Description
                           "$FileVersion",         ## FileVersion
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
                           "DLP",                           ## Description
                           "$FileVersion",                  ## FileVersion
                           "Verdasys Digital Guardian DLP"  ## Product

         )|Out-Null
      }   
      If($Item -iMatch "^(kvoop)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",        ## PID
                           "$Item",        ## ProcessName
                           "DLP",          ## Description
                           "$FileVersion", ## FileVersion
                           "Unknown DLP"   ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(noads)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",            ## PID
                           "$Item",            ## ProcessName
                           "Ad Blocker",       ## Description
                           "$FileVersion",     ## FileVersion
                           "NoAds Ad Blocker"  ## Product

         )|Out-Null
      }
      If($Item -iMatch "^(sadblock)$")
      {
         $foundit = "True"
         #Adding values to output DataTable!
         $mytable.Rows.Add("$ppid",            ## PID
                           "$Item",            ## ProcessName
                           "Ad Blocker",       ## Description
                           "$FileVersion",     ## FileVersion
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
   $stringformat = If($_ -iMatch '(Ad Blocker|DLP|Firewall|Intrusion Detection|Behavioral Analysis|AppWhitelisting)'){
      @{ 'ForegroundColor' = 'Yellow' } }Else{ @{ 'ForegroundColor' = 'White' } }
   Write-Host @stringformat $_
   }
}


If($Action -ieq "verbose")
{

   <#
   .SYNOPSIS
      Author: @BankSecurity
      Helper - Check EDR by driver name existence!
   #>

   Function Obj {#Check driver names
      Param([Parameter(Mandatory=1)][HashTable]$Props)
      Return New-Object PSCustomObject -Property $Props
   }
 
   #Driver Check
   $Result = Switch ((Get-ChildItem $env:SystemDrive\Windows\System32\drivers | Where-Object  Name -Match '(.sys)$').name)
   {
      atrsdfw.sys            {Obj @{Driver=$_;EDR= 'Altiris Symantec'         }}
      avgtpx86.sys           {Obj @{Driver=$_;EDR= 'AVG Technologies'         }}
      avgtpx64.sys           {Obj @{Driver=$_;EDR= 'AVG Technologies'         }}
      naswSP.sys             {Obj @{Driver=$_;EDR= 'Avast'                    }}
      edrsensor.sys          {Obj @{Driver=$_;EDR= 'BitDefender SRL'          }}
      CarbonBlackK.sys       {Obj @{Driver=$_;EDR= 'Carbon Black'             }}
      parity.sys             {Obj @{Driver=$_;ERD= 'Carbon Black'             }}
      csacentr.sys           {Obj @{Driver=$_;EDR= 'Cisco'                    }}
      csaenh.sys             {Obj @{Driver=$_;EDR= 'Cisco'                    }}
      csareg.sys             {Obj @{Driver=$_;EDR= 'Cisco'                    }}
      csascr.sys             {Obj @{Driver=$_;EDR= 'Cisco'                    }}
      csaav.sys              {Obj @{Driver=$_;EDR= 'Cisco'                    }}
      csaam.sys              {Obj @{Driver=$_;EDR= 'Cisco'                    }}
      rvsavd.sys             {Obj @{Driver=$_;EDR= 'CJSC Returnil Software'   }}
      cfrmd.sys              {Obj @{Driver=$_;EDR= 'Comodo Security'          }}
      cmdccav.sys            {Obj @{Driver=$_;EDR= 'Comodo Security'          }}
      cmdguard.sys           {Obj @{Driver=$_;EDR= 'Comodo Security'          }}
      CmdMnEfs.sys           {Obj @{Driver=$_;EDR= 'Comodo Security'          }}
      MyDLPMF.sys            {Obj @{Driver=$_;EDR= 'Comodo Security'          }}
      im.sys                 {Obj @{Driver=$_;EDR= 'CrowdStrike'              }}
      CSDeviceControl.sys    {Obj @{Driver=$_;EDR= 'CrowdStrike'              }}
      csagent.sys            {Obj @{Driver=$_;EDR= 'CrowdStrike'              }}
      CybKernelTracker.sys   {Obj @{Driver=$_;EDR= 'CyberArk Software'        }}
      CRExecPrev.sys         {Obj @{Driver=$_;EDR= 'Cybereason'               }}
      CyOptics.sys           {Obj @{Driver=$_;EDR= 'Cylance Inc.'             }}
      CyProtectDrv32.sys     {Obj @{Driver=$_;EDR= 'Cylance Inc.'             }}
      CyProtectDrv64.sys.sys {Obj @{Driver=$_;EDR= 'Cylance Inc.'             }}
      groundling32.sys       {Obj @{Driver=$_;EDR= 'Dell Secureworks'         }}
      groundling64.sys       {Obj @{Driver=$_;EDR= 'Dell Secureworks'         }}
      esensor.sys            {Obj @{Driver=$_;EDR= 'Endgame'                  }}
      edevmon.sys            {Obj @{Driver=$_;EDR= 'ESET'                     }}
      ehdrv.sys              {Obj @{Driver=$_;EDR= 'ESET'                     }}
      FeKern.sys             {Obj @{Driver=$_;EDR= 'FireEye'                  }}
      WFP_MRT.sys            {Obj @{Driver=$_;EDR= 'FireEye'                  }}
      xfsgk.sys              {Obj @{Driver=$_;EDR= 'F-Secure'                 }}
      fsatp.sys              {Obj @{Driver=$_;EDR= 'F-Secure'                 }}
      fshs.sys               {Obj @{Driver=$_;EDR= 'F-Secure'                 }}
      HexisFSMonitor.sys     {Obj @{Driver=$_;EDR= 'Hexis Cyber Solutions'    }}
      klifks.sys             {Obj @{Driver=$_;EDR= 'Kaspersky'                }}
      klifaa.sys             {Obj @{Driver=$_;EDR= 'Kaspersky'                }}
      Klifsm.sys             {Obj @{Driver=$_;EDR= 'Kaspersky'                }}
      mbamwatchdog.sys       {Obj @{Driver=$_;EDR= 'Malwarebytes'             }}
      mfeaskm.sys            {Obj @{Driver=$_;EDR= 'McAfee'                   }}
      mfencfilter.sys        {Obj @{Driver=$_;EDR= 'McAfee'                   }}
      PSINPROC.SYS           {Obj @{Driver=$_;EDR= 'Panda Security'           }}
      PSINFILE.SYS           {Obj @{Driver=$_;EDR= 'Panda Security'           }}
      amfsm.sys              {Obj @{Driver=$_;EDR= 'Panda Security'           }}
      amm8660.sys            {Obj @{Driver=$_;EDR= 'Panda Security'           }}
      amm6460.sys            {Obj @{Driver=$_;EDR= 'Panda Security'           }}
      eaw.sys                {Obj @{Driver=$_;EDR= 'Raytheon Cyber Solutions' }}
      SAFE-Agent.sys         {Obj @{Driver=$_;EDR= 'SAFE-Cyberdefense'        }}
      SentinelMonitor.sys    {Obj @{Driver=$_;EDR= 'SentinelOne'              }}
      SAVOnAccess.sys        {Obj @{Driver=$_;EDR= 'Sophos'                   }}
      savonaccess.sys        {Obj @{Driver=$_;EDR= 'Sophos'                   }}
      sld.sys                {Obj @{Driver=$_;EDR= 'Sophos'                   }}
      pgpwdefs.sys           {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      GEProtection.sys       {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      diflt.sys              {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      sysMon.sys             {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      ssrfsf.sys             {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      emxdrv2.sys            {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      reghook.sys            {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      spbbcdrv.sys           {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      bhdrvx86.sys           {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      bhdrvx64.sys           {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      SISIPSFileFilter       {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      symevent.sys           {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      vxfsrep.sys            {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      VirtFile.sys           {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      SymAFR.sys             {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      symefasi.sys           {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      symefa.sys             {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      symefa64.sys           {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      SymHsm.sys             {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      evmf.sys               {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      GEFCMP.sys             {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      VFSEnc.sys             {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      pgpfs.sys              {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      fencry.sys             {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      symrg.sys              {Obj @{Driver=$_;EDR= 'Symantec'                 }}
      ndgdmk.sys             {Obj @{Driver=$_;EDR= 'Verdasys Inc'             }}
      ssfmonm.sys            {Obj @{Driver=$_;EDR= 'Webroot Software'         }}
   }

   if(-not($Result))
   {
      write-host "*" -ForegroundColor Red -NoNewline;
      write-host " No known EDR Drivers found..." -ForegroundColor DarkGray;
   }
   Else
   {
      Return $Result
   }
}


#Delete artifacts left behind!
Remove-Item -path "$Env:TMP\tbl.log" -EA SilentlyContinue -Force
Write-Host ""