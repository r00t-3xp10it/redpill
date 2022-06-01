## Open-Directory.ps1 - Under Develop ( not stable )

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|Open-Directory|Use GUI to open the sellected directory|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/Open-Directory.png)|

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

## msgbox.ps1 - Under Develop ( not stable )

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|msgbox|Example how to spawn a message box in pure powershell|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/Open-Directory.png)|

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

## progressbar.ps1 - Under Develop ( not stable )

|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|progressbar|Example how to spawn a progress bar in pure powershell|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/Open-Directory.png)|

<br />

**Download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/progressbar.ps1" -OutFile "progressbar.ps1"
```

<br />

**execute:**
```powershell
.\progressbar.ps1
```

<br />

## sendkeys.ps1 - Under Develop ( not stable )

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
```
