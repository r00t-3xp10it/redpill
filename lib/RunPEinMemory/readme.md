## RunPEinMemory.exe

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|RunPEinMemory|Run PE (executables) in Memory|User Land|\*\*\*|

<br />

**download RunPEinMemory:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/RunPEinMemory/RunPEinMemory64.exe" -OutFile "RunPEinMemory64.exe"
```

<br />

**run cmdlet:**
```powershell
# Usage: RunPEinMemory64.exe [Exe Path]
.\RunPEinMemory64.exe "$Env:Windir\system32\cmd.exe"
```

<br />

![RunPEinMemory](https://user-images.githubusercontent.com/23490060/219485634-5b594ed8-5223-43d7-9651-b2deea5b8854.png)
