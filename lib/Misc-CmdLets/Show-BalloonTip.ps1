<#
.SYNOPSIS
   Show a ballon tip in the notification bar
   
   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: System.Windows.Forms
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.NOTES
   More attractive pop-up messages (balloon tips) may be displayed in Windows 7, 8.1 & 10
   through the Windows Forms API. The following PowerShell code will show a pop-up message
   next to the Windows 10 Notification bar that will automatically disappear in 20 seconds.

.Parameter BalloonTipTitle
   The ballontip title

.Parameter BalloonTipText
   The ballontip text

.Parameter BalloonClose
   Close ballontip after (default: 20000)

.LINK
   https://woshub.com/popup-notification-powershell
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$BalloonTipText="A virus has detected in $Env:COMPUTERNAME",
   [string]$BalloonTipTitle="Attention $Env:USERNAME",
   [int]$BalloonClose='20000'
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
   $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
   $balmsg.BalloonTipText = $BalloonTipText
   $balmsg.BalloonTipTitle = $BalloonTipTitle
   $balmsg.Visible = $true
   $balmsg.ShowBalloonTip($BalloonClose)
}
Catch
{
   write-host "`n   > Error: $_ `n" -foregroundcolor Red -BackgroundColor Black
}