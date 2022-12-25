<#
.SYNOPSIS
   Kill remote processes

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Administrator
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.4

.DESCRIPTION
   Auxiliary Module of meterpeter C2 to kill processes

.NOTES
   To kill a process by is ProcessName just invoke -proc_name
   parameter. If you wish to kill a process by is ID ( PID )
   just invoke this cmdlet with the -ppid parameter only.

.Parameter Proc_Name
   The process name to kill (default: mspaint)

.Parameter PPID
   The process ID to kill (default: false)

.EXAMPLE
   PS C:\> .\killProcess.ps1 -Proc_Name 'calc'
   stop process calc.exe by is processname

.EXAMPLE
   PS C:\> .\killProcess.ps1 -ppid '1508'
   stop process by is ID identifier

.INPUTS
   None. You cannot pipe objects into killProcess.ps1

.OUTPUTS
   Description   : Paint
   Process PID   : 7530 found running.
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


## Check shell privileges before go any further.
$bool = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
If($bool)
{

   If($PPID -NotMatch 'false')
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Kill process by is ID ( PID ) identifier
      #>

      ## Make sure input is a valid pid
      If($PPID -NotMatch '^(\d+\d)$')
      {
         write-host "   Error: not valid PID '$PPID' input." -ForegroundColor Red
         return
      }

      ## Check if input process ID its running before go any further.
      If([bool](get-process -Id $PPID -ErrorAction SilentlyContinue) -Match 'False')
      {
         write-host "   Error: PID '$PPID' not found running." -ForegroundColor Red
         return
      }

      ## Grab process complementary information
      $DATAB = (Get-Process -Id "$PPID" -EA SilentlyContinue|Select-Object *)
      $DESCR = $DATAB.Description
      $MYPID = $DATAB.ProcessName
      $PPATH = $DATAB.Path

      ## OnScreen displays
      write-host "   Description   : " -NoNewline
      write-host "$DESCR" -ForegroundColor DarkYellow
      write-host "   Process PID   : $PPID found running."
      Start-Sleep -Milliseconds 600

      ## Stop process using an orphan process
      Start-Process -WindowStyle Hidden powershell -ArgumentList "Stop-Process -ID `"$PPID`" -Force" -Wait
      If([bool](get-process -Id $PPID -ErrorAction SilentlyContinue) -Match 'False')
      {
         write-host "   Process State : " -NoNewline
         write-host "PID $PPID successfuly stopped .." -ForegroundColor Green
         write-host "   Process Path  : $PPATH"
      }
      Else
      {
         write-host "   Process State : " -NoNewline
         write-host "Fail to stop '$PPID' PID ?" -ForegroundColor Red
      }
   }
   Else
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Kill process by ProcessName identifier
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
      $DESCR = $DATAB.Description
      $PPATH = $DATAB.Path
      $MYPID = $DATAB.Id

      ## OnScreen displays
      write-host "   Description   : " -NoNewline
      write-host "$DESCR" -ForegroundColor DarkYellow
      write-host "   Process PID   : $MyPID found running."
      Start-Sleep -Milliseconds 600

      ## Stop process using an orphan process
      Start-Process -WindowStyle Hidden powershell -ArgumentList "Stop-Process -Name `"$Proc_name`" -Force" -Wait
      If((Get-Process -Name $Proc_name -EA SilentlyContinue|Select-Object *).Responding -iNotMatch 'True')
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