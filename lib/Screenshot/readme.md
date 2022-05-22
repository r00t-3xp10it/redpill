## Module Name
   <b><i>screenshot.exe</i></b>

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|screenshot|Capture desktop screenshot (silent)|User Land|Stores screenshots in current directory<br />[Screenshot.exe capture.png screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Screenshot/screenshot.png)<br />[Screenshot.exe Manual_capture.png screenshots](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Screenshot/screenshot_manual.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Screenshot/screenshot.exe" -OutFile "screenshot.exe"
```

```powershell
.\screenshot.exe
```

<br />

**Take screenshots with time intervals (1 second) a max of 4 captures**
```powershell
For($i=1; $i -le 4; $i++){echo "[*] capture: screenshot_$i.png";.\screenshot.exe;Start-Sleep -S 1;Rename-Item screenshot.png screenshot_$i.png -Force}
```

**Silently Capture 4 screenshots with 1 second of interval (No GUI interface)**
```powershell
Start-Process -WindowStyle hidden powershell -ArgumentList "For(`$i=1; `$i -le 4; `$i++){.\screenshot.exe;Start-Sleep -S 1;Rename-Item screenshot.png screenshot_`$i.png -Force}";exit
```
