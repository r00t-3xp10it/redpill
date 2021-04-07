<#
.SYNOPSIS
   Enumerate eventvwr logs OR Clear All event logs

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.NOTES
   Required Dependencies: wevtutil {native}
   The Clear @argument requires Administrator privs
   on shell to be abble to 'Clear' Eventvwr entrys.

.Parameter GetLogs
   Accepts arguments: Enum, Verbose and Clear

.Parameter NewEst
   Accepts how mutch event logs to display int value

.EXAMPLE
   PS C:\> Get-Help .\GetLogs.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Enum
   Lists ALL eventvwr categorie entrys

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Verbose
   List the newest 10(default) Powershell\Application\System entrys

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Verbose -NewEst 28
   List the newest 28 Eventvwr Powershell\Application\System entrys

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Clear
   Remark: Clear @arg requires Administrator privs on shell

.OUTPUTS
   Max(K) Retain OverflowAction    Entries Log                   
   ------ ------ --------------    ------- ---                            
   20 480      0 OverwriteAsNeeded   1 024 Application           
   20 480      0 OverwriteAsNeeded       0 HardwareEvents                 
   20 480      0 OverwriteAsNeeded      74 System                
   15 360      0 OverwriteAsNeeded      85 Windows PowerShell
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$GetLogs="false",
   [int]$NewEst='10'
)


Write-Host ""
If($GetLogs -ieq "Enum" -or $GetLogs -ieq "Clear" -or $GetLogs -ieq "Verbose"){
If($NewEst -lt "5" -or $NewEst -gt "80"){$NewEst = "10"} ## Set the max\min logs to display
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

    If($GetLogs -ieq "Enum" -or $GetLogs -ieq "Verbose"){## Eventvwr Enumeration
        ## List ALL Event Logs
        Get-EventLog -List|Format-Table -AutoSize

        If($GetLogs -ieq "Verbose"){## verbose @argument function

           ## Local function Variable declarations {Powershell}
           $SysLogCatg = wevtutil gl "Windows Powershell"|findstr /I /C:"name"
           $SysLogCatg = $SysLogCatg|findstr /V "logFileName:"
           $SysLogType = wevtutil gl "Windows Powershell"|findstr /I "type"
           $SysLogStat = wevtutil gl "Windows Powershell"|findstr /I "enabled"
           $SysLogFile = wevtutil gl "Windows Powershell"|findstr /I "logFileName"
           $SysLogFile = $SysLogFile -replace '(^\s+|\s+$)','' ## Delete Empty spaces in beggining and End of string

           ## List last 10 Powershell eventlogs
           Write-Host "`n  $SysLogCatg" -ForegroundColor Green
           Write-Host "  $SysLogType" -ForegroundColor Yellow
           Write-Host "  $SysLogStat" -ForegroundColor Yellow
           $Log = Get-EventLog -LogName "Windows Powershell" -newest $NewEst -EA SilentlyContinue|Select-Object EntryType
           If($? -ieq $False){## $LASTEXITCODE return $False => None Logs present
               Write-Host "  $SysLogFile" -ForegroundColor Yellow
               Write-Host "  [error] None Eventvwr Entries found under Windows Powershell!`n" -ForegroundColor Red -BackgroundColor Black
           }Else{## $LASTEXITCODE return $True => Logs present
               Write-Host "  $SysLogFile`n" -ForegroundColor Yellow
               Get-EventLog -LogName "Windows Powershell" -newest $NewEst -EA SilentlyContinue|Select-Object EntryType,Source,Message|Format-Table -AutoSize
           }


           ## Local function Variable declarations {Application}
           $SysLogCatg = wevtutil gl "Application"|findstr /I /C:"name"
           $SysLogCatg = $SysLogCatg|findstr /V "logFileName:"
           $SysLogType = wevtutil gl "Application"|findstr /I "type"
           $SysLogStat = wevtutil gl "Application"|findstr /I "enabled"
           $SysLogFile = wevtutil gl "Application"|findstr /I "logFileName"
           $SysLogFile = $SysLogFile -replace '(^\s+|\s+$)','' ## Delete Empty spaces in beggining and End of string

           ## List last 10 Application eventlogs
           Write-Host "`n  $SysLogCatg" -ForegroundColor Green
           Write-Host "  $SysLogType" -ForegroundColor Yellow
           Write-Host "  $SysLogStat" -ForegroundColor Yellow
           $Log = Get-EventLog -LogName "Application" -newest $NewEst -EA SilentlyContinue|Select-Object EntryType
           If($? -ieq $False){## $LASTEXITCODE return $False => None Logs present
               Write-Host "  $SysLogFile" -ForegroundColor Yellow
               Write-Host "  [error] None Eventvwr Entries found under Application!`n" -ForegroundColor Red -BackgroundColor Black
           }Else{## $LASTEXITCODE return $True => Logs present
               Write-Host "  $SysLogFile`n" -ForegroundColor Yellow
               Get-EventLog -LogName "Application" -newest $NewEst -EA SilentlyContinue|Select-Object EntryType,Source,Message|Format-Table -AutoSize
           }


           ## Local function Variable declarations {System}
           $SysLogCatg = wevtutil gl System|findstr /I /C:"name"
           $SysLogCatg = $SysLogCatg|findstr /V "logFileName:"
           $SysLogType = wevtutil gl System|findstr /I "type"
           $SysLogStat = wevtutil gl System|findstr /I "enabled"
           $SysLogFile = wevtutil gl System|findstr /I "logFileName"
           $SysLogFile = $SysLogFile -replace '(^\s+|\s+$)','' ## Delete Empty spaces in beggining and End of string

           ## List last 10 System eventlogs
           Write-Host "`n  $SysLogCatg" -ForegroundColor Green
           Write-Host "  $SysLogType" -ForegroundColor Yellow
           Write-Host "  $SysLogStat" -ForegroundColor Yellow
           $Log = Get-EventLog -LogName "System" -newest $NewEst -EA SilentlyContinue|Select-Object EntryType
           If($? -ieq $False){## $LASTEXITCODE return $False => None Logs present
               Write-Host "  $SysLogFile" -ForegroundColor Yellow
               Write-Host "  [error] None Eventvwr Entries found under System!`n" -ForegroundColor Red -BackgroundColor Black
           }Else{## $LASTEXITCODE return $True => Logs present
               Write-Host "  $SysLogFile`n" -ForegroundColor Yellow
               Get-EventLog -LogName "System" -newest $NewEst -EA SilentlyContinue|Select-Object EntryType,Source,Message|Format-Table -AutoSize
           }
        }

    }ElseIf($GetLogs -ieq "Clear"){## Clear ALL Eventvwr Logs
        $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544");
        If(-not($IsClientAdmin)){## wevtutil cl => requires Administrator rigths to run
            Write-Host "[error] This module requires 'Administrator' rigths to run!" -ForegroundColor Red -BackgroundColor Black
            Write-Host "";Start-Sleep -Seconds 1;exit ## Exit @GetLogs
        }

        ## Clear ALL event Logs
        Write-Host "[i] Administrator Privileges: True" -ForegroundColor Yellow
        Write-Host "[+] Cleaning $Env:COMPUTERNAME\$Env:USERNAME Eventvwr logs ...`n" -ForeGroundColor Green
        wevtutil cl "Microsoft-Windows-Powershell/Operational"  ## Clean Powershell logfiles
        wevtutil cl "Microsoft-Windows-Bits-Client/Operational" ## Clean BITS-TRANSFER logfiles
        wevtutil el|Foreach-Object {wevtutil cl "$_"}
    }
    Write-Host "";Start-Sleep -Seconds 1
}