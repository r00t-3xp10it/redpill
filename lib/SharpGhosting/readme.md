## Module Name
   <b><i>SharpGhosting.exe</i></b>

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|SharpGhosting|Spawn child process disassosiated from parent<br />And hidde parent process name from taskmanager|User Land|\*\*\*|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/SharpGhosting/SharpGhosting.exe" -OutFile "SharpGhosting.exe"
```

**Usage:**
```
-real: the exe you want executed [Required]
-fake: path to a file that doesn't exist (parent directory must exist though) [Optional]
```

```powershell
.\SharpGhosting.exe -real 'C:\windows\system32\cmd.exe'
.\SharpGhosting.exe -real 'C:\windows\system32\cmd.exe' -fake 'C:\windows\temp\fakefile'
.\SharpGhosting.exe -real 'C:\windows\system32\cmd.exe' -fake 'C:\windows\temp\fakefile.exe'
```