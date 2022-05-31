<#
.SYNOPSIS
   Example how to spawn a message box in pure powershell

.NOTES
   The messageBox accepts the follow parameters:
   Title, Message, Button, Icon and Timer

.EXAMPLE
   PS C:\> .\msgbox.ps1 -title "testing" -message "my message"

.EXAMPLE
   PS C:\> .\msgbox.ps1 -title "testing" -message "my message" -button "1" -icon "16"
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Title="My message Box",
   [string]$Message="testing message box",
   [int]$Button='3',
   [int]$Icon='64',
   [int]$Timer='5'
)

## Timer
# ,4, = 4 seconds open

## Buttons
# 0 = ok button
# 1 = ok + cancel buttons
# 2 = ok + repeat + ignore buttons
# 3 = yes + no + cancel buttons
# 4 = yes + no buttons
# 5 = repeat + cancel buttons
# 6 = cancel + try again + continue buttons

## Icons
# 0	    None
# 16	Critical
# 32	Question
# 48	Exclamatio
# 64	Information

#Execute msgbox
powershell (New-Object -ComObjEct Wscript.Shell).Popup("$Message",${Timer},"$Title",${button}+${Icon})