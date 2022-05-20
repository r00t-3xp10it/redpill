## :octocat: Database

This repository contains a library of cmdlet's which for one reason or another have NOT been implemented<br />in any of my tools (redpill,meterpeter), and which can be invoked manually to perform post-exploitation tasks.

<br />

## :octocat: Disclamer

This repository contains resources written by me or by external developers.

<br />

## :octocat: Repository Structure
```
Directory Name                                         Resource Description
--------------                                         --------------------
Database
        |_ Ams1-Bypass
                      |_ AMSBP.ps1                     Disable AMSI within current process
                      |_ Disable-Amsi.ps1              Disable AMSI within current process
        |_ Dump-Browser
                      |_ DumpChromePasswords.ps1       Dumps URLs, usernames, and passwords from Chrome
                      |_ HarvestBrowserPasswords.exe   Dumps URLs, usernames, and passwords from major browsers
        |_ Exfiltration
                      |_ DecodeRDPCache.ps1            Reads RDP persistent cache from the cache0001.bin
                      |_ DLLSearch.ps1                 List DLLs loaded by running processes
                      |_ Find-AppLockerLogs.ps1        Look through the AppLocker logs to find processes
                      |_ List-AllMailboxAndPST.ps1     Uses the Outlook COM object to display the data stores 
                      |_ Read-ExcelFile-Using_COM.ps1  Read Outlook excel files using COM object
        |_ Fake-Cmdline
                      |_ Fake-Cmdline.exe              Put any string into the child process Command Line field
        |_ HTTP-Server
                      |_ CaptureServer.ps1             Simple HTTP pure powershell webserver
                      |_ Start-SimpleHTTPServer.ps1    Simple HTTP pure powershell webserver     
                      |_ wget.vbs                      VBScript to download files from Local Lan
        |_ SharpGhosting
                      |_ SharpGhosting.exe             Hidde parent process name from TaskManager displays
```
