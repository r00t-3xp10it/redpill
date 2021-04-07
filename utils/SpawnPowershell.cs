/*
   Author: @r00t-3xp10it
   redpill v1.2.6 - CsOnTheFly Internal Module!
*/

using System.Diagnostics;
namespace Console
{
    class Program
    {
        static void Main(string[] args)
        {
            var spawnmyprompt = new ProcessStartInfo();
            spawnmyprompt.UseShellExecute = true;
            spawnmyprompt.FileName = @"powershell.exe";
            spawnmyprompt.WorkingDirectory = @"C:\Windows\System32\WindowsPowerShell\v1.0";
            Process.Start(spawnmyprompt);
        }
    }
}
