<#
.SYNOPSIS
   Kill remote processes

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Administrator
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.8

.DESCRIPTION
   Auxiliary Module of meterpeter C2 to kill processes

.NOTES
   Invoke this cmdlet with -proc_name 'process_name' param
   to kill multiple instances of process_name Or just invoke
   -ppid 'process_id' to kill only the sellected process pid.

   If you wish to kill multiple instances of powershell except
   the current powershell console than invoke -DontKill "$pid"

.Parameter Proc_Name
   The process name to kill (default: mspaint)

.Parameter PPID
   The process ID to kill (default: false)

.Parameter DontKill
   Dont kill this PID id (default: 4)

.EXAMPLE
   PS C:\> .\killProcess.ps1 -proc_name 'calc'
   Kill process calc.exe (multiple instances)

.EXAMPLE
   PS C:\> .\killProcess.ps1 -ppid '1508'
   Kill process by is unique ID identifier

.EXAMPLE
   PS C:\> .\killProcess.ps1 -proc_name 'powershell' -dontkill "$pid"
   Kill all instances of powershell except the current console PID

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
   [string]$DontKill="4",
   [string]$PPID="false"
)


$cmdletver = "v1.0.8"
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

      ## Valid pid contains only digits.
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

      .EXAMPLE
         PS C:\> .\killProcess.ps1 -proc_name 'powershell' -DontKill "$pid"
         Kill all instances of powershell except the current console PID.

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

      If($DontKill -NotMatch '^\d+$')
      {
         $DontKill = $PID
         ## A valid pid contains only digits.
         write-host "   Error: wrong input, default to $DontKill" -ForegroundColor Red
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
         write-host "                   sending kill command to PID $i" -ForegroundColor DarkGray
         Start-Process -WindowStyle Hidden Powershell -ArgumentList "Get-Process -Name `"$Token`"|Where-Object{`$_.Id -ne `"$DontKill`"}|Stop-Process -Force" -Wait   
      }

      If($MYPID -Match "$DontKill")
      {
         write-host "   Process State : " -NoNewline
         write-host "$Proc_name stopped except for PID $DontKill" -ForegroundColor Yellow
         write-host "   Process Path  : $PPATH"
         return      
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
         write-host "Fail to stop '$Proc_name' process?" -ForegroundColor Red
         write-host "   Process Path  : $PPATH"
      }
   }

}
Else
{
   $iD = [System.Security.Principal.WindowsIdentity]::GetCurrent().Owner.Value
   write-host "   Owner: $iD";write-host "   Error: Administrator privs required to kill processes." -ForegroundColor Red
}