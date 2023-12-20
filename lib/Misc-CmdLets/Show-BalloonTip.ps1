<#
.SYNOPSIS
   Show a ballon tip in the notification bar
   
   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: System.Windows.Forms
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.4

.NOTES
   More attractive pop-up messages (balloon tips) may be displayed in Windows 7, 8.1 & 10
   through the Windows Forms API. The following PowerShell code will show a pop-up message
   next to the Windows 10 Notification bar that will automatically disappear in 20 seconds.

.Parameter Title
   The ballontip title

.Parameter Text
   The ballontip text

.Parameter IconType
   The ballontip icon (info|error|warning)

.Parameter AutoClose
   Close ballontip in (default: 20000)

.EXAMPLE
   PS C:\> .\Show-BallonTip.ps1 -title 'kernel error' -text 'a system error occour' -icontype 'error' -autoclose '10000'

.INPUTS
   None. You cannot pipe objects into Show-BallonTip.ps1

.OUTPUTS
   * Executing ballontip in notification bar
     Title : 'Attention pedro'
     Text  : 'A virus has detected in SKYNET'
   * Waiting '10000' milliseconds ..
   * BallonTip successfuly executed in SKYNET

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/r00t-3xp10it/meterpeter
   https://woshub.com/popup-notification-powershell
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Text="A virus has detected in $Env:COMPUTERNAME",
   [string]$Title="Attention $Env:USERNAME",
   [string]$IconType="Warning",
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
   $global:BallonBox = New-Object System.Windows.Forms.NotifyIcon
   $MyPath = (Get-Process -id $pid).Path

   ## Display info OnScreen
   write-host "`n   * Executing ballontip in notification bar" -ForegroundColor Green
   write-host "     Title : '$Title'"
   write-host "     Text  : '$Text'"

   ## Build ballon box
   $BallonBox.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($MyPath)
   $BallonBox.BalloonTipIcon = $IconType
   $BallonBox.BalloonTipText = $Text
   $BallonBox.BalloonTipTitle = $Title
   $BallonBox.Visible = $true

   write-host "   * " -ForegroundColor Green -NoNewline
   write-host "Waiting '" -NoNewline
   write-host "$AutoClose" -ForegroundColor Green -NoNewline
   write-host "' milliseconds .."
   $BallonBox.ShowBalloonTip($AutoClose)

   ## Get rid of the following two lines if you don't want the tray-icon to disappear
   # after xxxxx Milliseconds (icon will disappear however as soon as you mouseover it)
   Start-Sleep -Milliseconds $AutoClose
   $BallonBox.dispose()
}
Catch
{
   write-host "`n   > Error: $_.Exception.Message `n" -foregroundcolor Red -BackgroundColor Black
   return
}

write-host "   * BallonTip successfuly executed in $Env:COMPUTERNAME" -ForegroundColor Green
exit