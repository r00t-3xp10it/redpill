# Load windows forms for sending keyboard presses
$Null = [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

# Add static method for switching window focus
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

# Start exe and capture process info
$NewProc = Start-Process -FilePath "C:\MyProgram.exe" -PassThru

# Wait for program to start
Start-Sleep -Seconds 5

# Switch window focus to exe process
$Null = [WinAp]::SetForegroundWindow($NewProc.MainWindowHandle)
$Null = [WinAp]::ShowWindow($NewProc.MainWindowHandle,3)

# Examples of keyboard presses, see here for key codes: https://stackoverflow.com/questions/19824799/how-to-send-ctrl-or-alt-any-other-key

# Send enter key press
[System.Windows.Forms.SendKeys]::SendWait("~")

# Send shift + tab
[System.Windows.Forms.SendKeys]::SendWait("+{TAB}")

# Send Ctrl + C (abort)
[System.Windows.Forms.SendKeys]::SendWait("^{c}") 
