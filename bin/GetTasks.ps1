<#
.SYNOPSIS
   Enumerate\Create\Delete running tasks!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: schtasks {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.1.3

.DESCRIPTION
   This module enumerates remote host running tasks
   Or creates a new task Or deletes existence tasks

.NOTES
   Created tasks have the default duration of 9 hours.

.Parameter GetTasks
   Accepts arguments: Enum, Create, Delete (default: Enum)

.Parameter TaskName
   The Task Name to Query, Create or to Kill (default: false)

.Parameter Interval
   The interval time (minuts) to run the task (default: 1 minut)

.Parameter Exec
   The cmdline (cmd|ps) to be executed by the task (default: false)

.Parameter Filter
   The task state to filter when query tasks (default: Ready Running)

.EXAMPLE
   PS C:\> Get-Help .\GetTasks.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Enum
   Enumerate All running\ready schedule tasks!

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Enum -Filter "Ready"
   Enumerate Only ready state schedule tasks!

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Enum -TaskName "CDSSync"
   Enumerate 'CDSSync' task detailed information!

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Create -TaskName "RedPillTask" -Interval 10 -Exec "cmd /c start calc.exe"
   Creates the taskname 'RedPillTask' that executes 'calc.exe' with 10 minuts of interval (loop) until PC restart!

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Delete -TaskName "RedPillTask"
   Delete\Kill 'RedPillTask' taskname

.OUTPUTS
   TaskName                                 Next Run Time          Status
   --------                                 -------------          ------
   ASUS Smart Gesture Launcher              N/A                    Ready          
   CreateExplorerShellUnelevatedTask        N/A                    Ready          
   OneDrive Standalone Update Task-S-1-5-21 24/01/2021 17:43:44    Ready   
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Filter="Ready Running",
   [string]$TaskName="false",
   [string]$GetTasks="false",
   [string]$Exec="false",
   [int]$Interval='1'
)


Write-Host "`n"
$Remote_hostName = hostname
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null


If($GetTasks -ieq "Enum")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate ALL running\ready schedule tasks!
   #>

   If($TaskName -ieq 'false')
   {

      Write-Host "TaskName                                 Next Run Time          Status" -ForegroundColor Green
      Write-Host "--------                                 -------------          ------"
      schtasks | findstr /I "$Filter" |
         Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
            $stringformat = If($_ -Match '(Running|RedPillTask)'){
               @{ 'ForegroundColor' = 'Yellow' } }Else{ @{ } }
            Write-Host @stringformat $_
         }
            Write-Host ""

        }
        Else
        {

           Start-Process -WindowStyle Hidden powershell -ArgumentList "schtasks /Query /tn '$TaskName' /v /fo list > $Env:TMP\tdfr.log" -Wait
           $CheckMe = Get-Content -Path "$Env:TMP\tdfr.log" -EA SilentlyContinue
           If(-not($CheckMe) -or $CheckMe -eq $null)
           {
              write-host "[error] fail to retrieve '$TaskName' Tasks info!" -ForegroundColor Red -BackgroundColor Black
           }
           Else
           {
              echo $checkme | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
                 $stringformat = If($_ -iMatch '^(TaskName:|Next Run Time:|Repeat: Every:|Task To Run:|Repeat: Until: Duration)'){
                    @{ 'ForegroundColor' = 'Yellow' } }Else{ @{ } }
                 Write-Host @stringformat $_
              }
           
           }

   }

   #Delete artifacts left behind!
   Remove-Item -Path "$Env:TMP\tdfr.log" -ErrorAction SilentlyContinue -Force
}


If($GetTasks -ieq "Create")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create one schedule tasks!
   #>

   If($Exec -ieq "false" -or $Exec -ieq $null)
   {
       $Exec = "cmd /c start calc.exe" ## Default Command to Execute
   }

   If($TaskName -ieq 'false'){$TaskName = "RedPillTask"}
   $Task_duration = "000" + "9" + ":00" ## 9 Hours of Task Duration
   schtasks /Create /sc minute /mo "$Interval" /tn "$TaskName" /tr "$Exec" /du "$Task_duration"
   
   $viriato = (schtasks /Query /tn "$TaskName") -replace 'Folder: \\','' #/v /fo list
   echo $viriato > $Env:TMP\vahja.log;Get-Content -Path "$Env:TMP\vahja.log" -EA SilentlyContinue

   #Delete artifacts left behind!
   Remove-Item -Path "$Env:TMP\vahja.log" -EA SilentlyContinue -Force

}


If($GetTasks -ieq "Delete")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Delete one existing schedule tasks!
   #>

   schtasks /Delete /tn "$TaskName" /f

}


Write-Host ""
#Delete artifacts left behind!
If(Test-Path -Path "$Env:TMP\tdfr.log"){Remove-Item -Path "$Env:TMP\tdfr.log" -Force}
If(Test-Path -Path "$Env:TMP\vahja.log"){Remove-Item -Path "$Env:TMP\vahja.log" -Force}
