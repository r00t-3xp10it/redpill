## Open-Directory.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[Open-Directory](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Misc-CmdLets/Open-Directory.ps1)|Use GUI to open the sellected directory|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/Open-Directory.png)|

<br />

**Download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/Open-Directory.ps1" -OutFile "Open-Directory.ps1"
```

<br >

**execute:**
```powershell
.\Open-Directory.ps1
```

<br />

## msgbox.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[msgbox](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Misc-CmdLets/msgbox.ps1)|Example how to spawn a message box in pure powershell|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/msgbox.png)|

<br />

**Download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/msgbox.ps1" -OutFile "msgbox.ps1"
```

<br />

**execute:**
```powershell
.\msgbox.ps1 -title "testing" -message "my message"
.\msgbox.ps1 -title "testing" -message "my message" -button "1" -icon "16" -timer "10"
```

<br />

## progressbar.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[progressbar](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Misc-CmdLets/progressbar.ps1)|Example how to spawn a progress bar in pure powershell|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/progressbar.png)|

<br />

**Download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/progressbar.ps1" -OutFile "progressbar.ps1"
```

<br />

**execute:**
```powershell
 .\progressbar.ps1 -Action 'Processes'
 .\progressbar.ps1 -Action 'NetAdapters'
```

<br />

## sendkeys.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[sendkeys](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Misc-CmdLets/sendkeys.ps1)|Example how to send keyboard presses (keys) to processes|User Land|[Screenshot1](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/sendkeys1.png)<br />[screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/sendkeys2.png)|

<br />

**Download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/sendkeys.ps1" -OutFile "sendkeys.ps1"
```

<br />

**execute:**
```powershell
#Start 'cmd.exe' program and send '^{c}' (CTRL+C) key to program
.\sendkeys.ps1 -Program "$Env:WINDIR\System32\cmd.exe" -SendKey "^{c}"

#Start 'cmd.exe' program and send '+{TAB}' (SIFT+TAB) key to program
.\sendkeys.ps1 -Program "$Env:WINDIR\System32\cmd.exe" -SendKey "+{TAB}"

#Start 'cmd.exe' program and send '~' (ENTER) key to program
.\sendkeys.ps1 -Program "$Env:WINDIR\System32\cmd.exe" -SendKey "~"

#Start 'cmd.exe' program and send 'whoami+~' (whoami+ENTER) key to program
.\sendkeys.ps1 -Program "$Env:WINDIR\System32\cmd.exe" -SendKey "whoami+~"

#Start 'cmd.exe' program (hidden console) and send 'whoami+~' (WHOAMI+ENTER) key to program
.\sendkeys.ps1 -Program "$Env:WINDIR\System32\cmd.exe" -SendKey "whoami+~" -style "hidden"
   
#Start 'notepad.exe' program and send 'hello world' keys to program after one second of delay
.\sendkeys.ps1 -Program "$Env:WINDIR\System32\notepad.exe" -SendKey "hello world" -ExecDelay '1'

#Fake windows update prank {Opera GX browser}
.\sendkeys.ps1 -Program "C:\Users\pedro\AppData\Local\Programs\Opera GX\launcher.exe" -SendKey "https://fakeupdate.net/win7/~{F11}"


## Fake windows update prank {All browsers}

# find default web browser name
$DefaultSettingPath = 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice'
$DefaultBrowserName = (Get-Item $DefaultSettingPath | Get-ItemProperty).ProgId

#Create PSDrive to HKEY_CLASSES_ROOT
$null = New-PSDrive -PSProvider registry -Root 'HKEY_CLASSES_ROOT' -Name 'HKCR'

#Get the default browser executable command/path
$DefaultBrowserOpenCommand = (Get-Item "HKCR:\$DefaultBrowserName\shell\open\command" | Get-ItemProperty).'(default)'
$DefaultBrowserPathSanitize = [regex]::Match($DefaultBrowserOpenCommand,'\".+?\"')
Remove-PSDrive -Name 'HKCR'

#Sanitize command
$DefaultBrowserPath = $DefaultBrowserPathSanitize.value -replace '"','

#Execute sendkeys cmdlet to open default browser in fakeupdate.net in full windows mode 
.\sendkeys.ps1 -Program "$DefaultBrowserPath" -SendKey "https://fakeupdate.net/win7/~{F11}"
```



<br />

## Prank2.ps1

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|[Prank2](https://github.com/r00t-3xp10it/redpill/blob/main/lib/Misc-CmdLets/Prank2.ps1)|Do A Barrel Roll Loop Prank|User Land|\*\*\*|

<br />

**Download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/Prank2.ps1" -OutFile "Prank2.ps1"
```

<br />

**execute:**
```powershell
#Access cmdlet help menu
Get-Help .\Prank2.ps1 -Full

#Cmdlet demonstration mode
.\Prank2.ps1 -AutoDel "OFF"

#Execute cmdlet in a hidden windows (stealth mode)
powershell -WindowStyle Hidden -File "Prank2.ps1"

#Start the prank after 3 seconds, exec the prank a max of 5 times with 20 seconds loops
powershell -WindowStyle Hidden -File "Prank2.ps1" -StartDelay "3" -LoopRange "5" -LoopDelay "20"

#Start the prank after 3 secs, exec the prank a max of 10 times, with 20 seconds delay before each loop and auto-close msgbox after 15 secs
powershell -WindowStyle Hidden -File "Prank2.ps1" -StartDelay "3" -LoopRange "10" -LoopDelay "20" -MsgBoxClose "15"

#Start the Prank after 15 minuts, exec the prank a max of 20 times with 30 seconds delay before each loop
powershell -WindowStyle Hidden -File "Prank2.ps1" -StartDelay '800' -LoopRange '20' -LoopDelay '30'
```

