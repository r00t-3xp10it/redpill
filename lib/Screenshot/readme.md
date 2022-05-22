## Module Name
   <b><i>screenshot.exe</i></b>

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|screenshot|Capture desktop screenshot (silent)|User Land|Stores screenshots in current directory<br />[Screenshot.exe capture.png screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Screenshot/screenshot.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/screenshot/screenshot.exe" -OutFile "screenshot.exe"
```

```powershell
.\screenshot.exe
```

<br />

**Take screenshots with time intervals (1 second) a max of 10 captures**

```powershell
For($i=0; $i -le 10; $i++){Start-Sleep -S 1;echo "[*] capture: $i";.\screenshot.exe}
```
