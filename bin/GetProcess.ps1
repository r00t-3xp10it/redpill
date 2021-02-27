<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Enumerate/Kill running process

.DESCRIPTION
   This CmdLet enumerates 'All' running process if used
   only the 'Enum' @arg IF used -ProcessName parameter
   then cmdlet 'kill' or 'enum' the sellected processName.

.Parameter GetProcess
   Accepts Enum and Kill @arguments

.Parameter ProcessName
   Accepts the Process Name to enumerate or to kill

.EXAMPLE
   PS C:\> Get-Help .\GetProcess.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PC C:\> .\GetProcess.ps1 -GetProcess Enum
   Enumerate ALL Remote Host Running Process(s)

.EXAMPLE
   PC C:\> .\GetProcess.ps1 -GetProcess Enum -ProcessName firefox.exe
   Enumerate firefox.exe Process {Id,Name,Path,Company,StartTime,Responding}

.EXAMPLE
   PC C:\> .\GetProcess.ps1 -GetProcess Kill -ProcessName firefox.exe
   Kill Remote Host firefox.exe Running Process

.OUTPUTS
   Id              : 5684
   Name            : powershell
   Description     : Windows PowerShell
   MainWindowTitle : @redpill v1.2.5 {SSA@RedTeam}
   ProductVersion  : 10.0.18362.1
   Path            : C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
   Company         : Microsoft Corporation
   StartTime       : 29/01/2021 20:09:57
   HasExited       : False
   Responding      : True
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$ProcessName="false",
   [string]$GetProcess="false"
)


Write-Host ""
If($GetProcess -ieq "Enum" -or $GetProcess -ieq "Kill"){
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

    ## Syntax Examples
    Write-Host "Syntax Examples" -ForegroundColor Green
    Write-Host "Example: .\redpill.ps1 -GetProcess Enum"
    Write-Host "Example: .\redpill.ps1 -GetProcess Enum -ProcessName notepad.exe"
    Write-Host "Example: .\redpill.ps1 -GetProcess Kill -ProcessName notepad.exe`n"
    Start-Sleep -Seconds 2


    If($GetProcess -ieq "Enum" -and $ProcessName -ieq "false"){## Enumerate ALL running process(s)
        Write-Host "$Remote_hostName Running Process" -ForegroundColor Green
        Write-Host "----------------------";Start-Sleep -Seconds 1
        Get-Process -EA SilentlyContinue|Select-Object Id,Name,Path,Company,FileVersion,mainwindowtitle,StartTime,Responding|Where-Object { $_.Responding -Match "True" -and $_.StartTime -ne $null}
    }ElseIf($GetProcess -ieq "Enum" -and $ProcessName -ne "false"){## Enumerate User Inpur ProcessName
        $RawProcName = $ProcessName -replace '.exe','' ## Replace .exe in processname to be abble use Get-Process
        Write-Host "$Remote_hostName $ProcessName Process" -ForegroundColor Green
        Write-Host "---------------------------";Start-Sleep -Seconds 1

        $CheckProc = Get-Process $RawProcName -EA SilentlyContinue|Select-Object Id,Name,Description,mainwindowtitle,ProductVersion,Path,Company,StartTime,HasExited,Responding
        If(-not($CheckProc)){## User Input => ProcessName NOT found
            Write-Host "[error] $ProcessName NOT found running!" -ForegroundColor Red -BackgroundColor Black
            Start-Sleep -Seconds 1
        }Else{## User Input => ProcessName found report
            echo $CheckProc > $Env:TMP\CheckProc.log
            Get-Content -Path $Env:TMP\CheckProc.log
            Remove-Item -Path $Env:TMP\CheckProc.log -Force
        }

    }ElseIf($GetProcess -ieq "Kill"){## Kill User Input => Running Process
        If($ProcessName -ieq $null -or $ProcessName -ieq "false"){## Make sure ProcessName Mandatory argument its set
            Write-Host "[error] -ProcessName Mandatory Parameter Required!" -ForegroundColor Red -BackgroundColor Black
            Write-Host "";Start-Sleep -Seconds 1;exit ## Exit @GetProcess
        }

        ## Make sure ProcessName its running
        $RawProcName = $ProcessName -replace '.exe',''
        $MSPIR = (Get-Process $RawProcName -EA SilentlyContinue).Responding|Select-Object -First 1
        If($MSPIR -ieq "True"){## ProcessName found => Responding
            If(-not($ProcessName -Match "[.exe]$")){## Add extension required (.exe) by taskkill cmdline
                $ProcessName = "$ProcessName" + ".exe" -join ''
            }
            cmd /R taskkill /F /IM $ProcessName
        }Else{## ProcessName NOT found responding
            Write-Host "[error] $ProcessName Process Name NOT found!" -ForegroundColor Red -BackgroundColor Black
            Start-Sleep -Seconds 1
        }
    }
    Write-Host "";Start-Sleep -Seconds 1
}