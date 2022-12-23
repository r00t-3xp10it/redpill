<#
.SYNOPSIS
   Kill remote process

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Get-Process
   Optional Dependencies: Administrator
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   Auxiliary Module of meterpeter v2.10.13 that kills processes

.Parameter Proc_Name
   The process name (default: mspaint)

.EXAMPLE
   PS C:\> .\killme.ps1 -Proc_Name 'calc'
   stop process calc.exe

.INPUTS
   None. You cannot pipe objects into killme.ps1

.OUTPUTS
   Process Name 'mspaint' successfuly stopped ..

.LINK
   https://github.com/r00t-3xp10it/meterpeter
   https://github.com/r00t-3xp10it/redpill/tree/main/lib/WebCam-Capture
   https://learnopencv.com/read-write-and-display-a-video-using-opencv-cpp-python
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Proc_name="mspaint"
)


## Check shell privileges before go any further.
$bool = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
If($bool)
{

   ## Check if input process its running before go any further. 
   If((Get-Process -Name $Proc_name -EA SilentlyContinue|Select *).Responding -iNotMatch 'True')
   {
      write-host "   x Process $Proc_name not found running." -ForegroundColor Red
      return
   }

   ## Stop process
   Start-Process -WindowStyle Hidden powershell -ArgumentList "Stop-Process -Name $Proc_name -Force" -Wait
   If((Get-Process -Name $Proc_name -EA SilentlyContinue|Select *).Responding -iNotMatch 'True')
   {
      write-host "   Process Name '$Proc_name' successfuly stopped .." -ForegroundColor Green
      return
   }
   Else
   {
      write-host "   x Fail to stop process '$Proc_name'?" -ForegroundColor Red
      return
   }
}
Else
{
   write-host "   Client Admin Privileges Required (run as administrator)" -ForegroundColor Red
}
