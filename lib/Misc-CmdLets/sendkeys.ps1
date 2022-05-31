<#
.SYNOPSIS
   Send keys to processes

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   This cmdlet allow users to 

.NOTES
   This cmdlet 

.Parameter Program
   The program to start (default: $Env:WINDIR\System32\cmd.exe)

.Parameter SendKey
   The sendkey value to execute (default: ^{c})

.Parameter ExecDelay
   The delay time (sec) to sendkeys (default: 4)

.EXAMPLE
   PS C:\> .\sendkeys.ps1 -Program "$Env:WINDIR\System32\cmd.exe" -SendKey "^{c}"
   Start 'cmd.exe' program and send '^{c}' (CTRL+C) key to program

.EXAMPLE
   PS C:\> .\sendkeys.ps1 -Program "$Env:WINDIR\System32\cmd.exe" -SendKey "+{TAB}"
   Start 'cmd.exe' program and send '+{TAB}' (SIFT+TAB) key to program

.EXAMPLE
   PS C:\> .\sendkeys.ps1 -Program "$Env:WINDIR\System32\cmd.exe" -SendKey "~"
   Start 'cmd.exe' program and send '~' (ENTER) key to program

.EXAMPLE
   PS C:\> .\sendkeys.ps1 -Program "$Env:WINDIR\System32\cmd.exe" -SendKey "whoami+~"
   Start 'cmd.exe' program and send 'whoami+~' (whoami+ENTER) key to program

.OUTPUTS
   * Send Keys to running programs
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Program="$Env:Windir\System32\cmd.exe",
   [string]$SendKey="^{c}",
   [int]$ExecDelay='2'
)


$ErrorActionPreference = "SilentlyContinue"
#Load windows forms for sending keyboard presses
write-host "`n* Send Keys to running programs" -ForegroundColor Green
$Null = [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

#Add static method for switching window focus
Add-Type -Language CSharp -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class WinAp {
      [DllImport("user32.dll")]
      [return: MarshalAs(UnmanagedType.Bool)]
      public static extern bool SetForegroundWindow(IntPtr hWnd);

      [DllImport("user32.dll")]
      [return: MarshalAs(UnmanagedType.Bool)]
      public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
"@


If(-not(Test-Path -Path "$Program"))
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host " notfound: '" -ForegroundColor DarkGray -NoNewline
   write-host "$Program" -ForegroundColor Red -NoNewline
   write-host "'" -ForegroundColor DarkGray
   return
}

#Start exe and capture process info
write-host "  + Start exe and capture process info" -ForegroundColor DarkYellow
$NewProc = Start-Process -FilePath "$Program" -PassThru


#Switch window focus to exe process
$Null = [WinAp]::SetForegroundWindow($NewProc.MainWindowHandle)
$Null = [WinAp]::ShowWindow($NewProc.MainWindowHandle,3)

## Examples of keyboard presses, see here for key codes:
# https://stackoverflow.com/questions/19824799/how-to-send-ctrl-or-alt-any-other-key

#Sendkey
Start-Sleep -Seconds $ExecDelay #Wait for program to start
[System.Windows.Forms.SendKeys]::SendWait("$SendKey")
If($?)
{
   write-host "  + Success: " -ForegroundColor DarkYellow -NoNewline
   write-host "sending key: '" -ForegroundColor DarkGray -NoNewline
   write-host "$SendKey" -ForegroundColor Green -NoNewline
   write-host "'" -ForegroundColor DarkGray
}
Else
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host " Error: sending key: '" -ForegroundColor DarkGray -NoNewline
   write-host "$SendKey" -ForegroundColor Red -NoNewline
   write-host "'" -ForegroundColor DarkGray
}

write-host "* Exit sendkeys cmdlet ..`n" -ForegroundColor Green
