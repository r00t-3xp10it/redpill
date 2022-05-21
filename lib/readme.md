## :octocat: Database

This repository contains a library of cmdlet's which for one reason or another have NOT been implemented<br />in any of my tools (redpill,meterpeter), and which can be invoked manually to perform post-exploitation tasks.

<br />

## :octocat: Disclamer

This repository contains resources written by me or by external developers to help in Red Team engagements.

<br />

## :octocat: Repository Structure
```
Directory Name                                         Resource Description
--------------                                         --------------------
Database
        |_ Ams1-Bypass
                      |_ AMSBP.ps1                     Disable AMSI within current process (bxor)
                      |_ Disable-Amsi.ps1              Disable AMSI within current process (un-signed technics)
                      |_ Invoke-Bypass.ps1             Disable AMSI within current process + exec script through bypass
        |_ Dump-Browser
                      |_ DumpChromePasswords.ps1       Dumps URLs, usernames, and passwords from Chrome
                      |_ HarvestBrowserPasswords.exe   Dumps URLs, usernames, and passwords from major browsers
        |_ Exfiltration
                      |_ DLLSearch.ps1                 List all DLLs loaded by running\sellected processes
                      |_ DecodeRDPCache.ps1            Reads RDP persistent cache from the cache0001.bin
                      |_ Find-AppLockerLogs.ps1        Look through the AppLocker logs to find processes
                      |_ List-AllMailboxAndPST.ps1     Uses the Outlook COM object to display the data stores 
                      |_ Read-ExcelFile-Using_COM.ps1  Read Outlook excel files sheet using COM object
        |_ Fake-Cmdline
                      |_ Fake-Cmdline.exe              Put any string into the child process Command Line field
        |_ HTTP-Server
                      |_ CaptureServer.ps1             Captute HTTP credentials on local lan (spawns credential box)
                      |_ Start-SimpleHTTPServer.ps1    Simple HTTP pure powershell webserver     
                      |_ wget.vbs                      VBScript to download files from Local Lan
        |_ Process-Spoofing
                      |_ PPIDSpoof.ps1                 Creates a process as a child of a specified process ID.
                      |_ SelectMyParent.exe            Creates a process as a child of a specified process ID.
                      |_ spoof.exe                     Creates a process as a child of a specified process ID.
        |_ Screenshot
                      |_ Screenshot.exe                Capture desktop screenshot ( silent )
        |_ SharpGhosting
                      |_ SharpGhosting.exe             Hidde parent process name from TaskManager displays
        |_ Sign-Executables
                      |_ CarbonCopy.py                 Creates spoofed certificate of online website to sign PE
                      |_ sigthief.py                   Sign an PE for AV Evasion by cloning other PE certificate
        |_ String-Obfuscation
                      |_ enc-rot13.ps1                 Encrypt or decrypt strings using ROT13 cipher.
                      |_ Out-EncodedSpecialCharOnlyCommand.ps1 Generates Special-Character-Only encoded payload
                      |_ obfuscator.bat                Obfuscate batch scripts
                      |_ vbs_obfuscator.vbs            Obfuscate VBS scripts
                      |_ Encrypt-String.ps1            Encrypt commands\scripts using a secret key
```
