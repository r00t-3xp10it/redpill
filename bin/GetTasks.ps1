<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Enumerate\Create\Delete running tasks

.DESCRIPTION
   This module enumerates remote host running tasks
   Or creates a new task Or deletes existence tasks

.NOTES
   Required Dependencies: cmd|schtasks {native}
   Remark: Module parameters are auto-set {default}
   Remark: Tasks have the default duration of 9 hours.

.Parameter GetTasks
   Accepts Enum, Create and Delete @arguments

.Parameter TaskName
   Accepts the Task Name to query, create or to kill

.Parameter Interval
   Accepts the interval time (in minuts) to start task

.Parameter Exec
   Accepts the cmdline string to be executed by the task

.EXAMPLE
   PS C:\> Get-Help .\GetTasks.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Enum
   Enumerate running tasks

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Create
   Use module default settings to create the demo task

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Delete -TaskName mytask
   Deletes mytask taskname

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Create -TaskName mytask -Interval 10 -Exec "cmd /c start calc.exe"

.OUTPUTS
   TaskName                                 Next Run Time          Status
   --------                                 -------------          ------
   ASUS Smart Gesture Launcher              N/A                    Ready          
   CreateExplorerShellUnelevatedTask        N/A                    Ready          
   OneDrive Standalone Update Task-S-1-5-21 24/01/2021 17:43:44    Ready   
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$TaskName="MyMeterpreter",
   [string]$GetTasks="false",
   [string]$Exec="false",
   [int]$Interval='10'
)


Write-Host ""
$Remote_hostName = hostname
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($GetTasks -ieq "Enum" -or $GetTasks -ieq "Create" -or $GetTasks -ieq "Delete"){

    ## Select the type of module to run
    If($GetTasks -ieq "Enum"){## Enum All running tasks

        Write-Host "$Remote_hostName\$Env:USERNAME Running Tasks" -ForegroundColor Green
        Write-Host "--------------------------`n"
        Start-Sleep -Seconds 1
        Write-Host "TaskName                                 Next Run Time          Status"
        Write-Host "--------                                 -------------          ------"
        cmd.exe /R schtasks|findstr /I "Ready Running"
        Write-Host "";Start-Sleep -Seconds 1

    }ElseIf($GetTasks -ieq "Create"){## Create a new tak

        If($Exec -ieq "false" -or $Exec -ieq $null){
            $Exec = "cmd /c start calc.exe" ## Default Command to Execute
        }

        $Task_duration = "000" + "9" + ":00" ## 9 Hours of Task Duration
        cmd /R schtasks /Create /sc minute /mo "$Interval" /tn "$TaskName" /tr "$Exec" /du "$Task_duration"
        Write-Host "";schtasks /Query /tn "$TaskName" #/v /fo list

    }ElseIf($GetTasks -ieq "Delete"){## Deletes existing task

        cmd /R schtasks /Delete /tn "$TaskName" /f

    }
    Write-Host "`n"
    If(Test-Path -Path "$Env:TMP\schedule.txt"){Remove-Item -Path "$Env:TMP\schedule.txt" -Force}
}