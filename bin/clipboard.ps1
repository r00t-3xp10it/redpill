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
