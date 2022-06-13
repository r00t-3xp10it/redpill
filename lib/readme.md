## :octocat: RedTeam Database

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
        |_ Ams1-Trigger
                      |_ AmsiTrigger_x64.exe           Hunting for Malicious Strings that triggers AMSI detection
        |_ CertSign_PS1
                      |_ PSscriptSigning.bat           Signs one PS1 script ( certlm.msc - certificate )
                      |_ DeletePSscriptSignning.bat    Delete certificate added by previous script from store
                      |_ Invoke-LazySign.ps1           Script that Sign a Windows binary with a self-signed cert
        |_ Dump-Browser
                      |_ DumpChromePasswords.ps1       Dumps URLs, usernames, and passwords from Chrome
                      |_ HarvestBrowserPasswords.exe   Dumps URLs, usernames, and passwords from major browsers
                      |_ ChromePass.exe                Dumps usernames, passwords from chrome (Invoke-Exclusions.ps1)
        |_ ETWpatch
                      |_ EventK.exe                    Suspend thread in svchost.exe related to event logging
                      |_ Get-Logs.ps1                  Enumerate \ Read \ Delete eventvwr logfiles (ETW)
        |_ EnableAllParentPrivileges
                      |_ EnableAllParentPrivileges.exe Enable All Parent Privileges ( whoami /priv )
        |_ Exfiltration
                      |_ DLLSearch.ps1                 List all DLLs loaded by running\sellected processes
                      |_ DecodeRDPCache.ps1            Reads RDP persistent cache from the cache0001.bin
                      |_ Find-AppLockerLogs.ps1        Look through the AppLocker logs to find processes
                      |_ List-AllMailboxAndPST.ps1     Uses the Outlook COM object to display the data stores 
                      |_ Read-ExcelFile-Using_COM.ps1  Read Outlook excel files sheet using COM object
                      |_ WindowsUpdateLog.ps1          Convert ETL logfiles (WindowsUpdate) into readable data
                      |_ Get-PrefetchListing.ps1       Manage (query \ Delete) prefetch files (.pf)
                      |_ Get-ComputerGeoLocation.ps1   Retrieves the Computer's geographical location
        |_ Fake-Cmdline
                      |_ Fake-Cmdline.exe              Put any string into the child process Command Line field
        |_ HTTP-Server
                      |_ CaptureServer.ps1             Captute HTTP credentials on local lan (spawns credential box)
                      |_ Start-SimpleHTTPServer.ps1    Simple HTTP pure powershell webserver     
                      |_ wget.vbs                      VBScript to download files from Local Lan
                      |_ Invoke-ShortUrl.ps1           TinyUrl url generator ( dropper URL link )
        |_ Misc-CmdLets
                      |_ Open-Directory.ps1            Use GUI to open the sellected directory
                      |_ msgbox.ps1                    Example how to spawn a message box in pure powershell
                      |_ progressbar.ps1               Example how to spawn a progress bar in pure powershell
                      |_ sendkeys.ps1                  Example how to send keyboard presses (keys) to processes
        |_ Out-FileFormat
                      |_ Out-shortcut.ps1              Creates an shortcut that accepts cmdline args to execute.
                      |_ SendToPasteBin.ps1            Get filepath contents and paste it to pastebin.
                      |_ SuperHidden.ps1               Query\Create\Delete super hidden system folders
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
                      |_ DigitalSignature-Hijack.ps1   Digitally sign all PS1 scripts on the host as Microsoft
        |_ Stream-TargetDesktop
                      |_ Stream-TargetDesktop.ps1      Sream target desktop live (attacker: firefox with MJPEG)   
        |_ String-Obfuscation
                      |_ enc-rot13.ps1                 Encrypt or decrypt strings using ROT13 cipher.
                      |_ Out-EncodedSpecialCharOnlyCommand.ps1 Generates Special-Character-Only encoded payload
                      |_ obfuscator.bat                Obfuscate batch scripts
                      |_ vbs_obfuscator.vbs            Obfuscate VBS scripts
                      |_ Encrypt-String.ps1            Encrypt commands\scripts using a secret key
                      |_ Convert-ROT47.ps1             Rotate ascii chars by nº places (Caesar cipher - rot)
        |_ WD-Bypass
                      |_ Invoke-Exclusions.ps1         Add exclusions (Set-MpPreferences) + Download\Execute url cmdlet
        |_ WebCam-Capture
                      |_ WebCam.py                     Capture video (AVI) using default target webcam
        |_ winpmem-mini
                      |_ winpmem_mini_x86.exe          Dumps raw image process data to disk
```
