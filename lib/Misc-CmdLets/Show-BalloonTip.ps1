<#
.SYNOPSIS
   Show a ballon tip in the notification bar
   
   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: System.Windows.Forms
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.2

.NOTES
   More attractive pop-up messages (balloon tips) may be displayed in Windows 7, 8.1 & 10
   through the Windows Forms API. The following PowerShell code will show a pop-up message
   next to the Windows 10 Notification bar that will automatically disappear in 20 seconds.

.Parameter Title
   The ballontip title

.Parameter Text
   The ballontip text

.Parameter Icon
   The ballontip icon (error|warning)

.Parameter AutoClose
   Close ballontip in (default: 20000)

.EXAMPLE
   PS C:\> .\Show-BallonTip.ps1 -title 'kernel error' -text 'a system error occour' -icon 'error' -autoclose '10000'

.INPUTS
   None. You cannot pipe objects into Show-BallonTip.ps1

.OUTPUTS
   none outputs available

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/r00t-3xp10it/meterpeter
   https://woshub.com/popup-notification-powershell
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Text="A virus has detected in $Env:COMPUTERNAME",
   [string]$Title="Attention $Env:USERNAME",
   [string]$Icon="Warning",
   [int]$AutoClose='20000'
)


## Check Operative system version
If(([System.Environment]::OSVersion.Version.Major) -gt 10)
{
   write-host "`n   > Error: Operative system version not supported!`n" -ForegroundColor Red
   return
}

Try{
   Add-Type -AssemblyName System.Windows.Forms
   $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
   $path = (Get-Process -id $pid).Path

   ## Build ballon box
   $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)

   If($Icon -imatch '^(Error)$')
   {
      $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error   
   }
   Else
   {
      $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
   }

   $balmsg.BalloonTipText = $Text
   $balmsg.BalloonTipTitle = $Title
   $balmsg.Visible = $true
   $balmsg.ShowBalloonTip($AutoClose)

   ## get rid of the following two lines if you don't want the tray-icon to disappear
   # after xxxxx Milliseconds the icon will disappear however as soon as you mouseover it.
   Start-Sleep -Milliseconds $AutoClose
   $balmsg.dispose()
}
Catch
{
   write-host "`n   > Error: $_ `n" -foregroundcolor Red -BackgroundColor Black
}
exit