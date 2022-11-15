<#
.SYNOPSIS
   Do A Barrel Roll Loop Prank

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.0

.NOTES
   Times examples
   seconds     Minuts
   -------     ------
   60       =  1
   300      =  5
   500      =  10
   800      =  15

.Parameter StartDelay
   Start script after XX seconds (default: 10)

.Parameter LoopRange
   Loop the prank how many times? (default: 10)

.Parameter LoopDelay
   Use XX secs delay before next loop (default: 30)

.Parameter MsgBoxClose
   AutoClose msgbox after XX seconds (default: 25)

.Parameter AutoDel
   AutoDelete cmdlet after execution? (default: ON)

.EXAMPLE
   PS C:\> .\Prank2.ps1 -AutoDel 'OFF'
   CmdLet Demonstration Mode (visible)

.EXAMPLE
   PS C:\> powershell -WindowStyle Hidden -File Prank2.ps1
   Execute the cmdlet in a hidden windows (stealth mode)

.EXAMPLE
   PS C:\> powershell -WindowStyle Hidden -File Prank2.ps1 -LoopRange '3'
   Execute the cmdlet in a hidden windows and execute the prank 3 times

.EXAMPLE
   PS C:\> powershell -WindowStyle Hidden -File Prank2.ps1 -StartDelay '800' -LoopRange '20' -LoopDelay '30'
   Start the Prank after 15 minuts, loop the prank a max of 20 times with 30 seconds delay before next loop

.INPUTS
   None. You cannot pipe objects into Prank2.ps1

.OUTPUTS
   Do A Barrel Roll Loop Prank
   ---------------------------
   Auto Delete  : ON
   Start Delay  : 10
   Loop Range   : 10
   Loop Delay   : 30
   MsgBoxClose  : 25

.LINK
   https://github.com/r00t-3xp10it/meterpeter
#>


## Global Variable declarations
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$AutoDel="ON",     # AutoDelete cmdlet after execution?
   [int]$MsgBoxClose='25',    # AutoClose msgbox after 25 seconds
   [int]$StartDelay='10',     # Start this script after 10 seconds
   [int]$LoopRange='10',      # Loop the prank how many times? (max)
   [int]$LoopDelay='30'       # Use 30 secs delay before next loop
)


## Display cmdlet settings OnScreen
write-host "`nDo A Barrel Roll Loop Prank" -ForegroundColor Green
write-host "---------------------------"
write-host "Auto Delete  : $AutoDel"
write-host "Start Delay  : $StartDelay"
write-host "Loop Range   : $LoopRange"
write-host "Loop Delay   : $LoopDelay"
write-host "MsgBoxClose  : $MsgBoxClose`n"

## Send process PID to logfile
# In case user decides to manual abort cmdlet execution
echo "Stop-Process -Id $pid -Force" > $Env:TMP\PrankPid.log

## Delay time before execute loop
Start-Sleep -Seconds $StartDelay

## Loop prank function
For($i=0; $i -lt $LoopRange; $i++)
{
   ## Google easter egg: Do A Barrel Roll - each XX seconds
   Start "https://www.google.com/search?q=do+a+barrel+roll" -WindowStyle Maximized
   Start-Sleep -Seconds $LoopDelay
}

## Exit Execution Message Box
Powershell (New-Object -ComObject Wscript.Shell).PopUp("BLOCKED ACCESS TO '$Env:COMPUTERNAME' RELATED TO PORNOGRAPHIC`nSURVEYS PERFORMED DURING WORKING HOURS ..`n`n               THE ADMINISTRATOR HAS BEEN NOTIFIED.",$MsgBoxClose,"                              * Microsoft Corporation *",0+0)

## CleanUp cmdlet artifacts function
Remove-Item -Path "$Env:TMP\PrankPid.log" -Force
If($AutoDel -iMatch 'ON')
{
   ## The next command auto-deletes this script
   Remove-Item -Path $MyInvocation.MyCommand.Source
}