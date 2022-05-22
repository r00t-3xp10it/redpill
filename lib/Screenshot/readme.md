## Module Name
   <b><i>screenshot.exe</i></b>

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|screenshot|Capture desktop screenshot (silent)|User Land|Stores screenshots in current directory<br />[Screenshot.exe capture.png screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Screenshot/screenshot.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Screenshot/screenshot.exe" -OutFile "screenshot.exe"
```

```powershell
.\screenshot.exe
```

<br />

**Take screenshots with time intervals (1 second) a max of 4 captures**
```powershell
For($i=1; $i -le 4; $i++){Start-Sleep -S 1;echo "[*] capture: screenshot_$i.png";.\screenshot.exe;Rename-Item screenshot.png screenshot_$i.png -Force}
```

**Silently Capture 4 screenshots with 1 second of interval**
```powershell
Start-Process -WindowStyle hidden powershell -ArgumentList "For(`$i=1; `$i -le 4; `$i++){Start-Sleep -S 1;.\screenshot.exe;Rename-Item screenshot.png screenshot_`$i.png -Force}"
```
