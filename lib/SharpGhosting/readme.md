## SharpGhosting.exe

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|SharpGhosting|Spawn the **child** process disassosiated from **parent** process<br />And hidde **parent** process name from TaskManager display|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/SharpGhosting/processghosting.png)|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/SharpGhosting/SharpGhosting.exe" -OutFile "SharpGhosting.exe"
```

**Usage:**
```
-real: the exe you want executed [Required]
-fake: path to a file that doesn't exist (parent directory must exist though) [Optional]
```

**execute:**
```powershell
.\SharpGhosting.exe -real 'C:\windows\system32\cmd.exe'
.\SharpGhosting.exe -real 'C:\windows\system32\cmd.exe' -fake 'C:\windows\temp\fakefile'
.\SharpGhosting.exe -real 'C:\windows\system32\cmd.exe' -fake 'C:\windows\temp\fakefile.exe'
```
