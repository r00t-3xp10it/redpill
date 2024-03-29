## PPIDSpoof.ps1

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|PPIDSpoof|Creates a process as a child of a specified process ID.<br />Technique ID: T1134.004 (Access Token Manipulation: Parent PID Spoofing)|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Process-Spoofing/PPIDSpoof.png)|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Process-Spoofing/PPIDSpoof.ps1" -OutFile "PPIDSpoof.ps1"
```

**execute:**
```powershell
Import-Module -Name ".\PPIDSpoof.ps1" -Force

#Spawns a notepad.exe process as a child of the current process.
Start-ATHProcessUnderSpecificParent -ParentId $PID -FilePath notepad.exe

#Spawns a notepad.exe process as a child of the first explorer.exe process.
Get-Process -Name explorer | Select-Object -First 1 | Start-ATHProcessUnderSpecificParent -FilePath notepad.exe

#Creates a notepad.exe process and then spawns a powershell.exe process as a child of it.
Start-Process -FilePath $Env:windir\System32\notepad.exe -PassThru | Start-ATHProcessUnderSpecificParent -FilePath powershell.exe -CommandLine '-Command Write-Host foo'
```

<br />

## SelectMyParent.exe

|Binary name|Description|Privileges|Notes|
|---|---|---|---|
|SelectMyParent|Creates a process as a child of a specified process ID.<br />Technique ID: T1134.004 (Access Token Manipulation: Parent PID Spoofing)|Administrator|\*\*\*|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Process-Spoofing/SelectMyParent.exe" -OutFile "SelectMyParent.exe"
```

**execute:**
```powershell
.\SelectMyParent.exe <process-to-use> <pid-to-spoof>

#Spawn notepad.exe using id 32 (calculator)
.\SelectMyParent.exe notepad 32
```

<br />

## spoof.exe

|Binary name|Description|Privileges|Notes|
|---|---|---|---|
|spoof|Creates a process as a child of a specified process ID.<br />Technique ID: T1134.004 (Access Token Manipulation: Parent PID Spoofing)|Administrator|\*\*\*|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Process-Spoofing/spoof.exe" -OutFile "spoof.exe"
```

**execute:**
```powershell
.\spoof.exe <process-to-use> <pid-to-spoof>
.\spoof.exe pentestlab.exe 1116
```

<br />

## Mitre-T1202.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[Mitre-T1202](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Process-Spoofing/Mitre-T1202.ps1)| MITRE ATT&CK T1202: Indirect Command Execution|User Land|[LOLBINS](https://lolbas-project.github.io)|

<br />

**Download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Process-Spoofing/Mitre-T1202.ps1" -OutFile "Mitre-T1202.ps1"
```

<br />

**prerequesites checks:**
```powershell
[bool](Test-Path -Path "$Env:WINDIR\System32\wlrmdr.exe")
```

<br />

**execute:**
```powershell
#Spawn 'mspaint.exe' with 'wlrmdr.exe' as parent process.
.\Mitre-T1202.ps1 -Binary "mspaint.exe"

#Spawn 'mspaint.exe' (after 1000 milliseconds) with 'wlrmdr.exe' as parent process.
.\Mitre-T1202.ps1 -Binary "mspaint.exe" -DelayExec "1000"
```
