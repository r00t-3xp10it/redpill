## winpmem_mini_x86.exe

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|winpmem_mini_x86|Dump processes raw image data to **file.raw**|Administrator|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Winpmem-mini/winpmem_mini.png)|

<br />

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Winpmem-mini/winpmem_mini_x86.exe" -OutFile "winpmem_mini_x86.exe"
```

<br />

**execute:**
```powershell
#Display PE help
.\winpmem_mini_x86.exe -h

#Writes image data to'physmem.raw' using \\Device\PhysicalMemory (x86)
.\winpmem_mini_x86.exe physmem.raw -1

#Writes image data to'physmem.raw' using PTE remaping (AMD64)
.\winpmem_mini_x86.exe physmem.raw -2
```
