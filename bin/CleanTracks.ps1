<#
.SYNOPSIS
   Clean Temp\Logs\Script artifacts left behind

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: cmd.exe {native}
   Optional Dependencies: wevtutil {native}
   PS cmdlet Dev version: v1.0.4

.DESCRIPTION
   Module to clean artifacts that migth lead forensic investigatores to attacker steps.
   It deletes lnk, db, log, tmp files, recent folder, Prefetch, and registry locations.

.NOTES
   The Paranoid arg deletes eventvwr logfiles if the cmdlet its executed with admin privs.

.Parameter CleanTracks
   Accepts arguments: Clear and Paranoid (default: clear)

.EXAMPLE
   PS C:\> Get-Help .\CleanTracks.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\CleanTracks.ps1 -CleanTracks Clear
   Clean Temp\Logs\Script artifacts left behind

.EXAMPLE
   PS C:\> .\CleanTracks.ps1 -CleanTracks Paranoid
   Clean artifacts in paranoid mode (extensive cleanning)

.OUTPUTS
   * Cover activity tracks on SKYNET
     => Token: Administrator privileges.
     => Clear: StartUp directory artifacts.
     => Clear: LogFiles from Eventvwr snapin.

   Module      Date     ItemsDeleted ModifiedRegKeys ScriptsDeleted
   ----------- ----     ------------ --------------- --------------
   CleanTracks 22:17:29 21           4               3
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$CleanTracks="false"
)


Write-Host "`n"
$DateNow = Get-Date -Format 'HH:mm:ss'
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$CleanPSLogging = (Get-PSReadlineOption -EA SilentlyContinue).HistorySavePath
Write-Host "* Cover activity tracks on $Env:COMPUTERNAME" -ForegroundColor Green
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
If($IsClientAdmin -Match '^(True)$')
{
   Write-Host "  => Token: Administrator privileges." -ForegroundColor Blue
}
Else
{
   Write-Host "  => Token: UserLand privileges." -ForegroundColor Yellow
}


If($CleanTracks -ieq "Clear" -or $CleanTracks -ieq "Paranoid")
{

   #Local function variable declarations
   $Count = 0       ## Items to delete counter
   $ModRegKey = 0   ## Reg keys to modify counter
   $MyArtifacts = 0 ## Scripts to delete counter


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
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /ve /t REG_SZ /f'
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
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f',
        'REG DELETE "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /ve /t REG_SZ /f'
     )


   If($IsClientAdmin -Match '^(True)$')
   {
      #Add extra keys to list if cmdlet its executed with administrator privileges
      $ClearList += 'REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR" /f'
      $ClearList += 'REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR" /ve /t REG_SZ /f'
      $ClearList += 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f'
      $ClearList += 'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'
      #Paranoid function list
      $ParanoidList += 'REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR" /f'
      $ParanoidList += 'REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR" /ve /t REG_SZ /f'
      $ParanoidList += 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f'
      $ParanoidList += 'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'
   }
   Else
   {
      #Add to list the 'update desktop' rundll32 api + registry last key accessed
      $ClearList += 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f'
      $ClearList += 'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'
      $ParanoidList += 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f'
      $ParanoidList += 'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'
   }


   ## Loop trougth Array List
   If($CleanTracks -ieq "Clear")
   {
      $ModRegKey = "7"
      ForEach($Item in $ClearList)
      {
         cmd /R $Item|Out-Null
         $Count++
      }
   }
   ElseIf($CleanTracks -ieq "Paranoid")
   {
      $ModRegKey = "8"
      ForEach($Item in $ParanoidList)
      {
         cmd /R $Item|Out-Null
         $Count++
      }
   }


   #Delete all artifacts from %tmp% directory
   Get-ChildItem -Path "$Env:TMP\*" -Include *.exe,*.bat,*.vbs,*.log,*.dll,*.lnk,*.inf,*.png,*.zip -Exclude *.ps1* -EA SilentlyContinue | ForEach-Object {
      Remove-Item -Path $_.FullName -Force|Out-Null
      If($?){$MyArtifacts = $MyArtifacts+1} ## <- Mark how many items are beeing deleted!
   }


   #Clear PS Logging History
   If(-not($CleanPSLogging -ieq $null))
   {
      $Count = $Count+1
      #File 'ConsoleHost_history.txt' found
      echo "null"|Out-File "$CleanPSLogging" -Force
   }


   If($CleanTracks -ieq "Paranoid")
   {

      <#
      .SYNOPSIS 
         Author: @r00t-3xp10it
         Helper - Delete ALL eventvwr logfiles + StartUp folder items.
      #>

      #Delete all artifacts from 'StartUp' directory
      Write-Host "  => Clear: StartUp directory artifacts." -ForegroundColor Blue
      $PersistePath = "$Env:APPDATA\Microsoft\Windows" + "\Start Menu\Programs\" + "Startup\*" -join ''
      Get-ChildItem -Path "$PersistePath" -Include *.exe,*.bat,*.vbs,*.inf,*.hta,*.ps1 -EA SilentlyContinue | ForEach-Object {
         Remove-Item -Path $_.FullName -Force|Out-Null
         If($?){$MyArtifacts = $MyArtifacts+1} ## <- Mark how many items are beeing deleted!
      }


      If($IsClientAdmin)
      {
         #Note: wevtutil cl => requires Administrator rigths to run
         Write-Host "  => Clear: LogFiles from Eventvwr snapin." -ForegroundColor Blue
         wevtutil el | Foreach-Object { $Count = $Count+1;wevtutil cl "$_" }
         Write-Host ""
      }

   }



   #Create Data Table for output onscreen
   $mytable = new-object System.Data.DataTable
   $mytable.Columns.Add("Module") | Out-Null
   $mytable.Columns.Add("Date") | Out-Null
   $mytable.Columns.Add("ItemsDeleted") | Out-Null
   $mytable.Columns.Add("ModifiedRegKeys") | Out-Null
   $mytable.Columns.Add("ScriptsDeleted") | Out-Null
   $mytable.Rows.Add("CleanTracks",
                     "$DateNow",
                     "$Count",
                     "$ModRegKey",
                     "$MyArtifacts") | Out-Null

   #Display Table OnScreen
   $mytable | Format-Table -AutoSize
}