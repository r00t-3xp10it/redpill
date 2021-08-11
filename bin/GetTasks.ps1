<#
.SYNOPSIS
   Enumerate\Create\Delete schedule tasks!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: schtasks {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.2.6

.DESCRIPTION
   This module enumerates host ready\running tasks,
   creates new task Or delete existing schedule task.

.NOTES
   Created tasks have the default duration of 12 hours.
   If executed with 'ADMINISTRATOR' privileges then this
   cmdlet will set the created task(s) to run as 'SYSTEM'!
   Remark: Dont leave empty spaces in -TaskName '<string>'
   declaration when creating a new task with this cmdlet.

.Parameter GetTasks
   Accepts arguments: Enum, Create, Delete (default: Enum)

.Parameter TaskName
   The Task Name to Query, Create or to Kill (default: false)

.Parameter Interval
   The interval time (in minuts) to run the task (default: 1)

.Parameter Duration
   The new created task time duration in hours (default: 12)

.Parameter Exec
   The cmdline (cmd|ps) to be executed by the task (default: false)

.Parameter Filter
   Task 'state' to filter when query for tasks (default: Ready Running)

.EXAMPLE
   PS C:\> Get-Help .\GetTasks.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Enum
   Enumerate running\ready schedule tasks!

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Enum -Filter "Ready"
   Enumerate only 'ready' state schedule tasks!

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Enum -TaskName "CDSSync"
   Enumerate only 'CDSSync' task detailed information!

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Create -TaskName "RedPillTask" -Interval 10 -Exec "cmd /c start calc.exe"
   Creates the taskname 'RedPillTask' that executes 'calc.exe' with 10 minuts of interval (loop) until PC restart!

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Delete -TaskName "RedPillTask"
   Delete\Kill 'RedPillTask' task name

.OUTPUTS
   TaskName                                 Next Run Time          Status
   --------                                 -------------          ------
   ASUS Smart Gesture Launcher              N/A                    Ready          
   CreateExplorerShellUnelevatedTask        N/A                    Ready          
   OneDrive Standalone Update Task-S-1-5-21 24/01/2021 17:43:44    Ready
   RedPillTask                              24/01/2021 01:08:46    Running
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Filter="Ready Running",
   [string]$TaskName="false",
   [string]$GetTasks="Enum",
   [string]$Exec="false",
   [int]$Duration='12',
   [int]$Interval='1'
)


Write-Host "`n"
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null


If($GetTasks -ieq "Enum")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate ready\running schedule tasks!
   #>

   If($TaskName -ieq 'false')
   {

      Write-Host "TaskName                                 Next Run Time          Status" -ForegroundColor Green
      Write-Host "--------                                 -------------          ------"
      schtasks | findstr /I "$Filter" |
         Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
            $stringformat = If($_ -iMatch '(Running|RedPillTask)'){
               @{ 'ForegroundColor' = 'Yellow' } }Else{ @{ } }
            Write-Host @stringformat $_
         }
            Write-Host ""

        }
        Else
        {

           #Query only User Sellected Task Name! {detailed}
           Start-Process -WindowStyle Hidden powershell -ArgumentList "schtasks /Query /tn '$TaskName' /v /fo list > $Env:TMP\tdfr.log" -Wait
           $GetRawData = Get-Content -Path "$Env:TMP\tdfr.log" -EA SilentlyContinue
           If(-not($GetRawData) -or $GetRawData -eq $null)
           {
              write-host "ERROR: cmdlet fail to retrieve '$TaskName' Task info!" -ForegroundColor Red -BackgroundColor Black
           }
           Else
           {
              echo $GetRawData | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
                 $stringformat = If($_ -iMatch '^(TaskName:|Next Run Time:|Repeat: Every:|Task To Run:|Repeat: Until: Duration)' -or $_ -iMatch '(SYSTEM)'){
                    @{ 'ForegroundColor' = 'Yellow' } }Else{ @{ } }
                 Write-Host @stringformat $_
              }
           }

   }
   Write-Host ""

}


If($GetTasks -ieq "Create")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create one schedule task!

   .NOTES
      Created tasks have the default duration of 12 hours. 
      If executed with 'ADMINISTRATOR' privileges then this
      cmdlet will set the created task(s) to run as 'SYSTEM'!
      Remark: Dont leave empty spaces in -TaskName '<string>'
      declaration when creating a new task with this cmdlet.
   #>

   #Local function configurations!
   If($Exec -ieq "false" -or $Exec -ieq $null)
   {
       $Exec = "cmd /c start calc.exe" ## Default Command to Execute
   }

   $Task_duration = "00" + "$Duration" + ":00" ## 12 Hours of Task Duration (default)
   If($TaskName -ieq 'false' -or $TaskName -ieq $null -or $TaskName -Match ' ')
   {
      Write-Host "ERROR: Bad -TaskName '$TaskName' input!" -ForegroundColor Red -BackgroundColor Black
      Start-Sleep -Seconds 1;Write-Host "ERROR: Defaulting to 'RedPillTask' Task Name."
      $TaskName = "RedPillTask"
   }


   #Build schedule tasks DataTable!
   $NewTable = New-Object System.Data.DataTable
   $NewTable.Columns.Add("TaskName")|Out-Null
   $NewTable.Columns.Add("Next Run Time")|Out-Null
   $NewTable.Columns.Add("Status")|Out-Null
   $NewTable.Columns.Add("Execute")|Out-Null


   #Elevate schedule task from ADMIN to SYSTEM?
   $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
   If($IsClientAdmin)
   {
      Write-Host "[administrator] Execute schedule task as 'SYSTEM' .." -ForegroundColor Green
      schtasks /Create /ru SYSTEM /sc minute /mo "$Interval" /tn "$TaskName" /tr "$Exec" /du "$Task_duration" /f
   }
   Else
   {
      schtasks /Create /sc minute /mo "$Interval" /tn "$TaskName" /tr "$Exec" /du "$Task_duration" /f
   }
   

   #Parse data to build the output Table!
   $viriato = (schtasks /Query /tn "$TaskName") -replace 'Folder: \\',''
   $DeleteFirst4Lines = $viriato | Select-Object -Skip 4

   #Split List using the empty spaces betuiwn strings!
   $SplitTheList = $DeleteFirst4Lines.split()

   #Delete empty lines from the variable List!
   $RawDataTable = $SplitTheList | ? { $_.trim() -ne "" }

   $TAN = $RawDataTable[0]
   $NRD = $RawDataTable[1]
   $NRT = $RawDataTable[2]
   $SAT = ($RawDataTable[3]) -replace '(\s+)$',''
   $NRF = "$NRD" + " $NRT" -Join ''

   #Adding values to output DataTable!
   $NewTable.Rows.Add("$TAN",  ## Task Name
                      "$NRF",  ## Next Run
                      "$SAT",  ## Status
                      "$Exec"  ## Execute
   )|Out-Null

   #Display Output Table!
   echo $NewTable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -iMatch '(TaskName)'){
         @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
      Write-Host @stringformat $_
   }

}


If($GetTasks -ieq "Delete")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Delete one existing schedule task!
   #>

   If($TaskName -ieq "false" -or $TaskName -ieq $null)
   {
      Write-Host "ERROR: Missing [ -TaskName '<string>' ] argument input!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";Start-Sleep -Seconds 3;Get-Help .\GetTasks.ps1 -detailed;exit ## Exit @GetTasks
   }

   schtasks /Delete /tn "$TaskName" /f
   If(-not($?))
   {
      Write-Host "ERROR: cmdlet fail to find\kill '$TaskName' task name."
   }

   Write-Host ""
}


#Delete artifacts left behind!
If(Test-Path -Path "$Env:TMP\tdfr.log"){Remove-Item -Path "$Env:TMP\tdfr.log" -Force}