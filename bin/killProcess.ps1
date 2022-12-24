<#
.SYNOPSIS
   Kill remote processes

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Administrator
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.2

.DESCRIPTION
   Auxiliary Module of meterpeter v2.10.13 to kill processes

.Parameter Proc_Name
   The process name to kill (default: mspaint)

.EXAMPLE
   PS C:\> .\killProcess.ps1 -Proc_Name 'calc'
   stop process calc.exe

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
   [string]$Proc_name="mspaint"
)


## Check shell privileges before go any further.
$bool = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
If($bool)
{

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
   write-host "`n   Description   : " -NoNewline
   write-host "$DESCR" -ForegroundColor DarkYellow
   write-host "   Process PID   : $MyPID found running."
   Start-Sleep -Milliseconds 700

   ## Stop process using an orphan process
   Start-Process -WindowStyle Hidden powershell -ArgumentList "Stop-Process -Name `"$Proc_name`" -Force" -Wait
   If((Get-Process -Name $Proc_name -EA SilentlyContinue|Select-Object *).Responding -iNotMatch 'True')
   {
      write-host "   Process State : " -NoNewline
      write-host "$Proc_name successfuly stopped .." -ForegroundColor Green
      write-host "   Process Path  : $PPATH`n"
   }
   Else
   {
      write-host "   Error: Fail to stop process '$Proc_name' ?" -ForegroundColor Red
   }
}
Else
{
   write-host "   Error: Administrator privs required to kill processes." -ForegroundColor Red
}