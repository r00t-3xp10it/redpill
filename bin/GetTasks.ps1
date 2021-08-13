<#
.SYNOPSIS
   Enumerate\Create\Delete schedule tasks!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: schtasks {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.3.9

.DESCRIPTION
   This module enumerates host ready\running tasks,
   creates new task Or delete existing schedule task.

.NOTES
   Created tasks have the default duration of 12 hours.
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
   The cmdline\appl to be executed by the task (default: false)

.Parameter Filter
   Task 'state' to filter when enumerating tasks (default: Ready Running)

.Parameter Persiste
   Execute the created schedule task at startup? (default: false)

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
   Creates the taskname 'RedPillTask' that executes 'calc.exe' with 10 minuts of interval (loop) for 12 hours!
   
.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Create -TaskName "RedPillTask" -Interval 2 -Exec "cmd.exe" -Duration "01"
   Creates the taskname 'RedPillTask' that executes 'cmd.exe' with 2 minuts of interval (loop) for 1 hour!   

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Create -TaskName "myTask" -Exec "cmd.exe" -Interval 2 -Persiste True
   Creates the taskname 'myTask' that executes 'cmd.exe' at startup with 2 minuts of interval! (loop)

.EXAMPLE
   PS C:\> .\GetTasks.ps1 -GetTasks Delete -TaskName "RedPillTask"
   Delete\Kill 'RedPillTask' task name
   
.INPUTS
   None. You cannot pipe objects into GetTasks.ps1

.OUTPUTS
   TaskName                                 Next Run Time          Status
   --------                                 -------------          ------
   ASUS Smart Gesture Launcher              N/A                    Ready          
   CreateExplorerShellUnelevatedTask        N/A                    Ready          
   OneDrive Standalone Update Task-S-1-5-21 24/01/2021 17:43:44    Ready
   RedPillTask                              24/01/2021 01:08:46    Running
   
.LINK
   https://ss64.com/nt/schtasks.html
   https://github.com/r00t-3xp10it/redpill
   https://gist.github.com/r00t-3xp10it/bb1bb83d872120a05fe4f26b710b44a6#gistcomment-3854021
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Filter="Ready Running",
   [string]$Persiste="false",
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
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")

#Build schedule tasks output DataTable!
$NewTable = New-Object System.Data.DataTable
$NewTable.Columns.Add("TaskName")|Out-Null
$NewTable.Columns.Add("Next Run Time")|Out-Null
$NewTable.Columns.Add("Status")|Out-Null
$NewTable.Columns.Add("Execute")|Out-Null


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
              Write-Host "ERROR: cmdlet fail to retrieve '$TaskName' Task info!" -ForegroundColor Red -BackgroundColor Black
              Write-Host ""
           }
           Else
           {
              $GetRawData | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
                 $stringformat = If($_ -iMatch '^(TaskName:|Next Run Time:|Repeat: Every:|Task To Run:|Repeat: Until: Duration)' -or $_ -iMatch '(SYSTEM|At system start up)$'){
                    @{ 'ForegroundColor' = 'Yellow' } }Else{ @{ } }
                 Write-Host @stringformat $_
              }
           }

   }
   Write-Host ""

}


If($GetTasks -ieq "Create" -and $Persiste -ieq "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create one schedule task!

   .NOTES
      Created tasks have the default duration of 12 hours. 
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


   try{#Create schedule task
      schtasks /Create /sc minute /mo "$Interval" /tn "$TaskName" /tr "$Exec" /du "$Task_duration" /f
   }catch{
      Write-Host "ERROR: creating schedule task!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";exit ## Exit @GetTasks
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
   $SAT = ($RawDataTable[-1]) -replace '(\s+)$',''
   $NRF = "$NRD" + " $NRT" -Join ''

   #Adding values to output DataTable!
   $NewTable.Rows.Add("$TAN",  ## Task Name
                      "$NRF",  ## Next Run
                      "$SAT",  ## Status
                      "$Exec"  ## Execute
   )|Out-Null

   #Display Output Table!
   $NewTable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -iMatch '(TaskName)'){
         @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
      Write-Host @stringformat $_
   }

}


If($GetTasks -ieq "Create" -and $Persiste -ieq "True")
{

   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Create schedule task to run at STARTUP!
      
   .NOTES
      schtasks /SC ONSTART requires administrator privileges
      to be abble to run the task at startup and does not allow
      /MO /RI /DU parameters. this function bypasses all of that!    
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


   try{
      <#
      .NOTES
         This function creates 'persisteme.bat' script on startup folder
         with task execution interval (minute) and duration time (hours).
         
         -GetTasks '<Delete>' -TaskName '<string>' parameters can
         then be used to delete the task and script.bat from system!
      #>
      $startpath = "$Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
      $RawBATcript = "@echo off&&schtasks /Create /sc minute /mo `"$Interval`" /tn `"$TaskName`" /tr `"$Exec`" /du `"$Task_duration`" /f"
      echo "$RawBATcript"|Out-File "$startpath\persisteme.bat" -encoding ascii -force
   }catch{
      Write-Host "ERROR: creating persisteme.bat script at startup!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";exit ## Exit @GetTasks
   }


   #Adding values to output DataTable!
   $NewTable.Rows.Add("$TaskName",   ## Task Name
                      "ON_START",    ## Next Run
                      "WAIT_REBOOT", ## Status
                      "$Exec"        ## Execute
   )|Out-Null

   #Display Output Table!
   Write-Host "`nCreated: '$startpath\persisteme.bat'" -ForegroundColor Green
   Write-Host "The task '$TaskName' will be executed on next STARTUP by persisteme.bat" -ForegroundColor DarkCyan
   $NewTable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
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
      Write-Host "ERROR: Missing -TaskName '<string>' argument input!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";Start-Sleep -Seconds 3;Get-Help .\GetTasks.ps1 -detailed;exit ## Exit @GetTasks
   }

   schtasks /Delete /tn "$TaskName" /f
   If(-not($?))
   {
      Write-Host "ERROR: cmdlet fail to find\kill running '$TaskName' task name."
   }

   $startpath = "$Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
   If(Test-Path -Path "$startpath\persisteme.bat")
   {
      Write-Host "DELETED: '$startpath\persisteme.bat'" -ForegroundColor Yellow
      Remove-Item -Path "$startpath\persisteme.bat" -Force
   }
   Write-Host ""

}


#Delete artifacts left behind!
If(Test-Path -Path "$Env:TMP\tdfr.log"){Remove-Item -Path "$Env:TMP\tdfr.log" -Force}