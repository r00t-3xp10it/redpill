<#
.SYNOPSIS
   Enumerate/Kill running process\tokens

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.2

.DESCRIPTION
   This CmdLet enumerates 'All' running process if used
   only the 'Enum' @arg IF used the -ProcessName parameter
   then cmdlet 'Kill' or 'Enum' the sellected process Name.

.NOTES
   Remark: Token @argument requires Administrator privs

.Parameter GetProcess
   Accepts arguments: Enum, Kill and Tokens

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

.EXAMPLE
   PC C:\> .\GetProcess.ps1 -GetProcess Tokens
   Enum ALL user process tokens and queries them for details

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
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

If($GetProcess -ieq "Tokens"){
   ## Download Get-OSTokenInformation.ps1 from my GitHub
   If(-not(Test-Path -Path "$Env:TMP\Get-OSTokenInformation.ps1")){## Download Get-OSTokenInformation.ps1 from my GitHub repository
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/modules/Get-OSTokenInformation.ps1 -Destination $Env:TMP\Get-OSTokenInformation.ps1 -ErrorAction SilentlyContinue|Out-Null
      ## Check downloaded file integrity => FileSizeKBytes
      $SizeDump = ((Get-Item -Path "$Env:TMP\Get-OSTokenInformation.ps1" -EA SilentlyContinue).length/1KB)
      If($SizeDump -lt 27){## Corrupted download detected => DefaultFileSize: 27,5166015625/KB
         Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
         If(Test-Path -Path "$Env:TMP\Get-OSTokenInformation.ps1"){Remove-Item -Path "$Env:TMP\Get-OSTokenInformation.ps1" -Force}
         Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @redpill
      }   
   }

   ## Run auxiliary module
   Import-Module -Name "$Env:TMP\Get-OSTokenInformation.ps1" -Force
   Get-OSTokenInformation -Brief -Verbose

   ## Clean Old files left behind
   If(Test-Path -Path "$Env:TMP\Get-OSTokenInformation.ps1"){Remove-Item -Path "$Env:TMP\Get-OSTokenInformation.ps1" -Force}
   exit ## Exit @GetProcess
}

If($GetProcess -ieq "Enum" -or $GetProcess -ieq "Kill"){

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