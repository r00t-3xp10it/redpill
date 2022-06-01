<#
.SYNOPSIS
   Send keys to background processes

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   Hackers often need to start background processes detached from the parent
   process (child\orphan) and let them run until a CTRL+C command is invoked
   to abort that same process. The issue resides that we can no longer access
   the background process from our current console using conventional ways .. 

   Lets say we have one cmdlet running in background that requires a CTRL+C
   command to abort the execution and clean artifacts in the end. This cmdlet
   allows its users to start those processes and send a command (CTRL+C) to
   abort the execution of the process at a predefined time (-execdelay 'int')

.NOTES
   This cmdlet as nothing to say untill now ...

.Parameter Program
   The program to start (default: $Env:WINDIR\System32\cmd.exe)

.Parameter Style
   The orphan process windowstyle (default: normal)

.Parameter Arguments
   The process arguments to execute (default: false)

.Parameter SendKey
   The sendkey value to execute (default: whoami+~)

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

.EXAMPLE
   PS C:\> .\sendkeys.ps1 -Program "$Env:WINDIR\System32\cmd.exe" -SendKey "whoami+~" -style "hidden"
   Start 'cmd.exe' program (hidden console) and send 'whoami+~' (WHOAMI+ENTER) key to program

.OUTPUTS
   * Send Keys to running programs
     + Start and capture process info.
     + Success: sending key: '^{c}'
   * Exit sendkeys cmdlet ..
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Program="$Env:Windir\System32\cmd.exe",
   [string]$Arguments="false",
   [string]$SendKey="whoami+~",
   [string]$Style="normal",
   [int]$ExecDelay='4'
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


<#
   TODO: Replace all start-process ''nitched'' inside IF statements by one $cmdline?
#>

#Start and capture process info
write-host "  + Start and capture process info." -ForegroundColor DarkYellow
If($Style -ieq "hidden")
{
   If($Arguments -ne "false")
   {
      #Execute program with arguments in a hidden console
      If(($Program.Split('.')[-1]) -iMatch '^(exe)$')
      {
         $NewProc = Start-Process -WindowStyle Hidden -File "$Program $Arguments" -PassThru
      }
      ElseIf(($Program.Split('.')[-1]) -iMatch '^(py)$')
      {
         $NewProc = Start-Process -WindowStyle Hidden python3 -ArgumentList "$Program $Arguments" -PassThru       
      }
      Else
      {
         $NewProc = Start-Process -WindowStyle Hidden powershell -ArgumentList "-File $Program $Arguments" -PassThru      
      }
   }
   Else
   {
      #Execute program without arguments in a hidden console
      If(($Program.Split('.')[-1]) -iMatch '^(exe)$')
      {
         $NewProc = Start-Process -WindowStyle Hidden -File "$Program" -PassThru
      }
      ElseIf(($Program.Split('.')[-1]) -iMatch '^(py)$')
      {
         $NewProc = Start-Process -WindowStyle Hidden python3 -ArgumentList "$Program" -PassThru       
      }      
      Else
      {
         $NewProc = Start-Process -WindowStyle Hidden powershell -ArgumentList "-File $Program" -PassThru      
      }  
   }
}
Else
{
   #Execute program with arguments in a normal console
   If($Arguments -ne "false")
   {
      If(($Program.Split('.')[-1]) -iMatch '^(exe)$')
      {
         $NewProc = Start-Process -file "$Program $Arguments" -PassThru
      }
      ElseIf(($Program.Split('.')[-1]) -iMatch '^(py)$')
      {
         $NewProc = Start-Process python3 -ArgumentList "$Program $Arguments" -PassThru       
      }      
      Else
      {
         $NewProc = Start-Process powershell -ArgumentList "-File $Program $Arguments" -PassThru      
      }
   }
   Else
   {
      #Execute program without arguments in a normal console
      If(($Program.Split('.')[-1]) -iMatch '^(exe)$')
      {
         $NewProc = Start-Process -file "$Program" -PassThru      
      }
      ElseIf(($Program.Split('.')[-1]) -iMatch '^(py)$')
      {
         $NewProc = Start-Process python3 -ArgumentList "$Program" -PassThru       
      }      
      Else
      {
         $NewProc = Start-Process powershell -ArgumentList "-File $Program" -PassThru         
      }
   
   }
}


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
