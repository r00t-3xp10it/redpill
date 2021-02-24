<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Enumerates remote host basic system info

.NOTES
   System info: IpAddress, OsVersion, OsFlavor, OsArchitecture,
   WorkingDirectory, CurrentShellPrivileges, ListAllDrivesAvailable
   PSCommandLogging, AntiVirusDefinitions, AntiSpywearDefinitions,
   UACsettings, WorkingDirectoryDACL, BehaviorMonitorEnabled, Etc..

.EXAMPLE
   PS C:\> Get-Help .\SysInfo.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\SysInfo.ps1 -SysInfo Enum
   Remote Host Quick Enumeration Module

.EXAMPLE
   PS C:\> .\SysInfo.ps1 -SysInfo Verbose
   Remote Host Detailed Enumeration Module
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$SysInfo="false"
)


$Address = (## Get Local IpAddress
    Get-NetIPConfiguration|Where-Object {
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

    ## Build OutPut Table
    Write-Host "OS: $System " -ForegroundColor Green
    Write-Host "------------------------------";Start-Sleep -Seconds 1
    Write-Host "DomainName        : $NameDomain\$Env:USERNAME"
    Write-Host "ShellPrivs        : $ShellPrivs" -ForegroundColor Yellow
    Write-Host "ConsolePid        : $ConsoleId"
    Write-Host "IsVirtualMachine  : $IsVirtualMachine"
    Write-Host "Architecture      : $Architecture"
    Write-Host "PSVersion         : $PsNumber"
    Write-Host "OSVersion         : $Version"
    Write-Host "IPAddress         : $Address" -ForegroundColor Yellow
    Write-Host "System32          : $SystemDir"
    Write-Host "DefaultWebBrowser : $Parse_Browser_Data (predefined)"
    Write-Host "CmdLetWorkingDir  : $Working_Directory" -ForegroundColor Yellow
    Write-Host "User-Agent        : $UserAgentString`n`n"

    ## Get Public Ip addr GeoLocation
    Write-Host "${NameDomain}\${Env:USERNAME}: GeoLocation" -ForegroundColor Green
    Write-Host "------------------------------";Start-Sleep -Seconds 1
    $PublicAddr = (curl ifconfig.me).Content
    $GeoLocation = (curl "https://ipapi.co/$PublicAddr/json/" -EA SilentlyContinue).RawContent|
        findstr /C:"city" /C:"region" /C:"country_" /C:"latitude" /C:"longitude"|
        findstr /V "iso3 tld calling area population region_code country_code"
    ## Parsing data to build output Table
    $GeoDat = $GeoLocation -replace '"','' -replace ',','' -replace '(^\s+|\s+$)',''
    $hggscd = $GeoDat -replace 'city:','city              :' -replace 'region:','region            :'
    $rsddse = $hggscd -replace 'country_name:','country_name      :' -replace 'latitude:','latitude          :'
    $ParseTcpData = $rsddse -replace 'longitude:','longitude         :' -replace 'country_capital:','country_capital   :'
    If($GeoDat){## Ip Addr Geo Location found
        echo "public_addr       : $PublicAddr" >> $Env:TMP\hsns.log
        echo $ParseTcpData >> $Env:TMP\hsns.log
        Get-Content -Path "$Env:TMP\hsns.log"
        Remove-Item -Path "$Env:TMP\hsns.log" -Force
        Write-Host ""
    }

    ## Get ALL drives available
    Get-PsDrive -PsProvider filesystem|Select-Object Name,Root,CurrentLocation,Used,Free|Format-Table -AutoSize

    ## Get User Accounts
    Get-LocalUser|Select-Object Name,Enabled,PasswordRequired,UserMayChangePassword -EA SilentlyContinue|Format-Table -AutoSize


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
        $BehaviorMonitorEnabled = (Get-MpComputerStatus).BehaviorMonitorEnabled
        $RealTimeProtectionEnabled = (Get-MpComputerStatus).RealTimeProtectionEnabled
        $AllowedApplications = (Get-MpPreference).ControlledFolderAccessAllowedApplications
        $AntivirusSignatureLastUpdated = (Get-MpComputerStatus).AntivirusSignatureLastUpdated
        $AntispywareSignatureLastUpdated = (Get-MpComputerStatus).AntispywareSignatureLastUpdated
        $AntiVirusProduct = (Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct).DisplayName

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

    ## Loop truth $AllowedApplications
    # Make sure the var declaration is not empty
    If(-not($AllowedApplications -ieq $null)){
        ForEach($Token in $AllowedApplications){
            Write-Host "AllowedApplications             : $Token"
        }
    }

    ## Built Output Table
    Write-Host "`n`nAV: Credential Guard Status" -ForegroundColor Green
    Write-Host "------------------------------";Start-Sleep -Seconds 1
    write-host "Name        : Credential Guard"
    write-host "Status      : $Status" -ForegroundColor Yellow
    write-host "Description : $Description"

    ## Enumerate active SMB shares
    Write-Host "`n`nSMB: Enumerating shares" -ForegroundColor Green
    Write-Host "------------------------------";Start-Sleep -Seconds 1
    Get-SmbShare -EA SilentlyContinue|Select-Object Name,Path,Description|Format-Table
    If(-not($?)){## Make sure we have any results back
        Write-Host "[error] None SMB shares found under $Remote_hostName system!" -ForegroundColor Red -BackgroundColor Black
    }

    ## Enumerate NetBIOS Local Names
    Write-Host "`n`nNetBIOS: Names       Type        Status"  -ForegroundColor Green
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

        Write-Host "`n"
        ## Checks for Firewall { -StartWebServer [python] } rule existence
        Get-NetFirewallRule|Where-Object {## Rules to filter {DisplayName|Description}
            $_.DisplayName -ieq "python.exe" -and $_.Description -Match 'venom'
        }|Format-Table Action,Enabled,Profile,Description > $Env:TMP\ksjjhav.log

        $CheckLog = Get-Content -Path "$Env:TMP\ksjjhav.log" -EA SilentlyContinue
        Remove-Item -Path "$Env:TMP\ksjjhav.log" -Force
        If($CheckLog -ne $null){## StartWebServer rule found
            Write-Host "StartWebServer: firewall rule"  -ForegroundColor Green
            Write-Host "-----------------------------"
            echo $CheckLog
        }

        ## @Webserver Working dir ACL Description
        Write-Host "DCALC: CmdLet Working Directory" -ForegroundColor Green
        Write-Host "-------------------------------";Start-Sleep -Seconds 1
        $GetACLDescription = icacls "$Working_Directory"|findstr /V "processing"
        echo $GetACLDescription > $Env:TMP\ACl.log;Get-Content -Path "$Env:TMP\ACL.log"
        Remove-Item -Path "$Env:TMP\ACl.log" -Force

        ## Recently typed "run" commands
        Write-Host "`nRUNMRU: Recently 'run' commands" -ForegroundColor Green
        Write-Host "-------------------------------";Start-Sleep -Seconds 1
        $GETMRUList = reg query HKCU\software\microsoft\windows\currentversion\explorer\runmru|findstr /V "(Default)"|findstr /V "MRUList"
        If(-not($GETMRUList -Match "REG_SZ")){## Make sure $GETMRUList variable its not empty
            Write-Host "[error] None RunMru registry entrys found!" -ForegroundColor Red -BackgroundColor Black
        }Else{## RunMru registry entrys found
            $GETMRUList -replace '\\1','' -replace 'REG_SZ','' -replace 'HKEY_CURRENT_USER\\software\\microsoft\\windows\\currentversion\\explorer\\runmru',''|? {$_.trim() -ne ""}
        }

      ## TobeContinued ..
    }
    Write-Host "";Start-Sleep -Seconds 1
}
