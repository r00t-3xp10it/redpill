<#
.SYNOPSIS
   Kill remote processes

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Administrator
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.6

.DESCRIPTION
   Auxiliary Module of meterpeter C2 to kill processes

.NOTES
   Invoke this cmdlet with -proc_name 'process_name' param
   to kill multiple instances of process_name Or just invoke
   -ppid 'process_id' to kill only the sellected process pid.

.Parameter Proc_Name
   The process name to kill (default: mspaint)

.Parameter PPID
   The process ID to kill (default: false)

.EXAMPLE
   PS C:\> .\killProcess.ps1 -Proc_Name 'calc'
   stop process calc.exe (multiple instances)

.EXAMPLE
   PS C:\> .\killProcess.ps1 -ppid '1508'
   stop process by is unique ID identifier

.INPUTS
   None. You cannot pipe objects into killProcess.ps1

.OUTPUTS
   Description   : Paint
   Process PID   : 7530 found running.
                   sending kill command to PID 1
   Process State : mspaint successfuly stopped ..
   Process Path  : C:\WINDOWS\system32\mspaint.exe

.LINK
   https://github.com/r00t-3xp10it/meterpeter
   https://github.com/r00t-3xp10it/redpill/tree/main/bin/killProcess.ps1
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Proc_name="mspaint",
   [string]$PPID="false"
)


$cmdletver = "v1.0.6"
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@KillProcess $cmdletver"
## Check current shell privileges before go any further.
$IsAdmin = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
If($IsAdmin)
{

   If($PPID -NotMatch 'false')
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Kill process by is ID ( PID ) identifier

      .OUTPUTS
         Description   : Paint
         Process PID   : 7530 found running.
                         sending kill command to PID
         Process State : mspaint successfuly stopped ..
         Process Path  : C:\WINDOWS\system32\mspaint.exe
      #>

      ## Make sure input is a valid pid.
      # A valid pid contains only digits.
      If($PPID -NotMatch '^\d+$')
      {
         write-host "   Error: not valid PID '$PPID' input." -ForegroundColor Red
         return
      }

      ## Check if input process ID its running before go any further.
      If([bool](Get-Process -Id "$PPID" -EA SilentlyContinue) -Match 'False')
      {
         write-host "   Error: PID '$PPID' not found running." -ForegroundColor Red
         return
      }

      ## Grab process complementary information
      $DATAB = (Get-Process -Id "$PPID" -EA SilentlyContinue|Select-Object *)
      $DESCR = $DATAB.Description
      $PNAME = $DATAB.ProcessName
      $PPATH = $DATAB.Path

      ## OnScreen displays
      write-host "   Description   : " -NoNewline
      write-host "$DESCR" -ForegroundColor DarkYellow
      write-host "   Process PID   : $PPID found running."
      Start-Sleep -Milliseconds 500

      write-host "                   sending kill command to PID" -ForegroundColor DarkGray
      Start-Process -WindowStyle Hidden Powershell -ArgumentList "Stop-Process -ID `"$PPID`" -Force" -Wait
      If([bool](Get-Process -Id "$PPID" -EA SilentlyContinue) -Match 'False')
      {
         write-host "   Process State : " -NoNewline
         write-host "$PNAME successfuly stopped .." -ForegroundColor Green
         write-host "   Process Path  : $PPATH"
      }
      Else
      {
         write-host "   Process State : " -NoNewline
         write-host "Fail to stop '$PPID' PID ($PNAME) ?" -ForegroundColor Red
      }

   }
   Else
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Kill process by is Process_Name identifier

      .NOTES
         This function will kill multiple instances of
         process name if found more than one running.

      .OUTPUTS
         Description   : Paint
         Process PID   : 7530 8089 found running.
                         sending kill command to PID 1
                         sending kill command to PID 2
         Process State : mspaint successfuly stopped ..
         Process Path  : C:\WINDOWS\system32\mspaint.exe
      #>

      If($Proc_name -iMatch '(.exe)$')
      {
         write-host "   Error: deleting extension from process name." -ForegroundColor Red
         $Proc_name = $Proc_name -replace '.exe',''
      }

      ## Check if input process its running before go any further. 
      If((Get-Process -Name "$Proc_name" -EA SilentlyContinue|Select-Object *).Responding -iNotMatch 'True')
      {
         write-host "   Error: process '$Proc_name' not found running." -ForegroundColor Red
         return
      }

      ## Grab process complementary information
      $DATAB = (Get-Process -Name "$Proc_name" -EA SilentlyContinue|Select-Object *)
      $PLIST = (Get-Process -Name "$Proc_name" -EA SilentlyContinue).ProcessName
      $DESCR = $DATAB.Description|Select-Object -Last 1
      $PPATH = $DATAB.Path|Select-Object -Last 1
      $MYPID = $DATAB.Id
          $i = 0

      ## OnScreen displays
      write-host "   Description   : " -NoNewline
      write-host "$DESCR" -ForegroundColor DarkYellow
      write-host "   Process PID   : $MyPID found running."
      Start-Sleep -Milliseconds 500

      ForEach($Token in $PLIST)
      {
         $i = $i + 1
         write-host "                sending kill command to PID $i" -ForegroundColor DarkGray
         Start-Process -WindowStyle Hidden Powershell -ArgumentList "Stop-Process -Name `"$Token`" -Force" -Wait
      }

      If((Get-Process -Name "$Proc_name" -EA SilentlyContinue|Select-Object *).Responding -iNotMatch 'True')
      {
         write-host "   Process State : " -NoNewline
         write-host "$Proc_name successfuly stopped .." -ForegroundColor Green
         write-host "   Process Path  : $PPATH"
      }
      Else
      {
         write-host "   Process State : " -NoNewline
         write-host "Fail to stop '$Proc_name' process ?" -ForegroundColor Red
      }
   }

}
Else
{
   $iD = [System.Security.Principal.WindowsIdentity]::GetCurrent().Owner.Value
   write-host "   Owner: $iD";write-host "   Error: Administrator privs required to kill processes." -ForegroundColor Red
}