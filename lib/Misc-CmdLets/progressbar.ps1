<#
.SYNOPSIS
   Author: @r00t-3xp10it

.DESCRIPTION
   Example how to spawn a PROGRESS BAR in pure powershell

.EXAMPLE
   PS C:\> .\progressbar.ps1 -Action 'Processes'

.EXAMPLE
   PS C:\> .\progressbar.ps1 -Action 'NetAdapters'
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Action="Processes"
)


$CurrentItem = 0      #ProgressBar
$PercentComplete = 0  #ProgressBar

If($Action -ieq "Processes")
{
   $GuiTitle = "Listing Procesess running ..."
   $TerminalDisplay = Get-Process -Name *
}
Else
{
   $GuiTitle = "Listing NetAdapters running ..."
   $TerminalDisplay = Get-NetAdapter -Name * -IncludeHidden | Select-Object Status,Name,LinkSpeed,ifDesc,DriverName,DriverInformation  #* # List Net Adapters
}


$TotalItems = $TerminalDisplay.Count #ProgressBar
ForEach($VM in $TerminalDisplay)
{
   $CurrentItem++
   Write-Progress -Activity "$GuiTitle" -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
   $PercentComplete = [int](($CurrentItem / $TotalItems) * 100)
   Start-Sleep -Milliseconds 50
}


#Display results using GUI
echo $TerminalDisplay|Out-GridView -Title "$GuiTitle"
