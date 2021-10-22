
![wikibanner](https://user-images.githubusercontent.com/23490060/107761196-e0a29880-6d22-11eb-9dfc-35028c9463f6.png)

[![Version](https://img.shields.io/badge/redpill-1.2.6-brightgreen.svg?maxAge=259200)]()
[![Stage](https://img.shields.io/badge/Release-Stable-brightgreen.svg)]()
[![Build](https://img.shields.io/badge/OS-Windows-orange.svg)]()
![licence](https://img.shields.io/badge/license-GPLv3-brightgreen.svg)
![Last Commit](https://img.shields.io/github/last-commit/r00t-3xp10it/redpill)
![isues](https://img.shields.io/github/issues/r00t-3xp10it/redpill)
![Repo Size](https://img.shields.io/github/repo-size/r00t-3xp10it/redpill)
![topLanguages](https://img.shields.io/github/languages/top/r00t-3xp10it/redpill)

<br />

## :octocat: Project Description
The redpill project aims to assist reverse tcp shells in post-exploration tasks. Often, on redteam appointments we<br />
need to use unconventional ways to access the target system, like reverse tcp shells (<b><i>not metasploit</i></b>) in order<br />
to bypass the defenses implemented by the system administrator. After the first step has been successfully completed<br />
we face another type of problem: <b> <i> "I have (shell) access to the target system, and now what can I do with it?" </i> </b> <br />

This project consists of several PowerShell scripts that perform different <b><i> post-exploitation</i> </b> tasks and <br />
The main script <b><i>redpill.ps1</i> </b> whose main job is to download/config/exec the scripts contained in this repository. <br /> 

The goal is to have a similar meterpreter experience in our reverse tcp shell prompt (meterpreter similar options)<br />

<br />

<details>
<summary>CmdLet Parameters syntax\examples</summary>

<br />

     This cmdlet belongs to the structure of venom v1.0.17.8 as a post-exploitation module.
     venom amsi evasion agents automatically uploads this CmdLet to %TMP% directory to be
     easily accessible in our reverse tcp shell ( shell prompt ).

<br />

<i>To List All Parameters Available, execute in powershell prompt:</i>

```powershell
.\redpill.ps1 -Help Parameters
```

<br />

|CmdLet Parameter Name|Parameter Arguments|Description|
|---|---|---|
|-SysInfo| Enum \| Verbose |Quick System Info OR Verbose Enumeration|
|-GetConnections| Enum \| Verbose |Enumerate Remote Host Active TCP Connections|
|-GetDnsCache| Enum \| Clear |Enumerate\Clear remote host DNS cache entrys|
|-GetInstalled| Enum |Enumerate Remote Host Applications Installed|
|-GetProcess| Enum \| Kill \| Tokens |Enumerate OR Kill Remote Host Running Process(s)|
|-GetTasks| Enum \| Create \| Delete |Enumerate\Create\Delete Remote Host Running Tasks|
|-GetLogs| Enum \| Verbose \| Clear |Enumerate eventvwr logs OR Clear All event logs|
|-LiveStream| Bind \| Reverse \| Stop |Nishang script for streaming a target desktop using MJPEG|
|-GetBrowsers| Enum \| Verbose \| Creds |Enumerate Installed Browsers and Versions OR Verbose|
|-GetSkype| Contacts\|DomainUsers |Enumerating and attacking federated Skype|
|-Screenshot| 1 |Capture 1 Desktop Screenshot and Store it on %TMP%|
|-Camera| Enum \| Snap |Enum computer webcams OR capture default webcam snapshot|
|-StartWebServer| Python \| Powershell |Downloads webserver to %TMP% and executes the WebServer|
|-Keylogger| Start \| Stop |Start OR Stop recording remote host keystrokes|
|-MouseLogger| Start |Capture Screenshots of Mouse Clicks for 10 seconds|
|-PhishCreds| Start \| Brute |Promp current user for a valid credential and leak captures|
|-GetPasswords| Enum \| Dump |Enumerate passwords of diferent locations {Store\|Regedit\|Disk}|
|-PasswordSpray| Spray |Password spraying attack against accounts in Active Directory!|
|-WifiPasswords| Dump \| ZipDump |Enum Available SSIDs OR ZipDump All Wifi passwords|
|-EOP| Enum \| Verbose |Find Missing Software Patchs for Privilege Escalation|
|-ADS| Enum \| Create \| Exec \| Clear|Hidde scripts { bat \| ps1 \| exe } on $DATA records (ADS)|
|-BruteZip| $Env:TMP\archive.zip |Brute force sellected Zip archive with the help of 7z.exe|
|-Upload| script.ps1|Upload script.ps1 from attacker apache2 webroot|
|-Persiste| $Env:TMP\Script.ps1 |Persiste script.ps1 on every startup {BeaconHome}|
|-CleanTracks| Clear \| Paranoid |Clean disk artifacts left behind {clean system tracks}|
|-AppLocker| Enum \| WhoAmi \| TestBat |Enumerate AppLocker Directorys with weak permissions|
|-FileMace| $Env:TMP\test.txt |Change File Mace {CreationTime,LastAccessTime,LastWriteTime}|
|-MetaData| $Env:TMP\test.exe |Display files \ applications description (metadata)|
|-psgetsys| Enum \| Auto \| Impersonate | spawn a process under a different parent process!|
|-MsgBox| "Hello World." |Spawns "Hello World." msgBox on local host {wscriptComObject}|
|-SpeakPrank| "Hello World." |Make remote host speak user input sentence {prank}|
|-NetTrace| Enum |Agressive Enumeration with the help of netsh {native}|
|-PingSweep| Enum \| Verbose |Enumerate Active IP Address and open ports on Local Lan|
|-DnsSpoof| Enum \| Redirect \| Clear | Redirect Domain Names to our Phishing IP address|
|-DisableAV| Query \| Start \| Stop | Disable Windows Defender Service (WinDefend)|
|-HiddenUser| Query \| Create \| Delete |  Query \ Create \ Delete Hidden User Accounts|
|-CsOnTheFly| Compile \| Execute | Download \ Compile (to exe) and Execute CS scripts|
|-CookieHijack| Dump\|History | Edge\|Chrome Cookie Hijacking tool|
|-UacMe| Bypass \| Elevate \| Clean | UAC bypass\|EOP by dll reflection! (cmstp.exe)|
|-GetAdmin| check \| exec |Elevate sessions from UserLand to Administrator!|
|-NoAmsi| List \| TestAll \| Bypass |Test AMS1 bypasses or simple execute one bypass|
|-Clipboard| Enum \| Capture \| Prank |Capture clipboard text\file\image\audio contents!|
|-GetCounterMeasures| Enum \| verbose | List common security processes\pid's running!|
|-DumpLsass|lsass\| all| Dump data from lsass/sam/system/security process/reg hives|

<br />

<i>To Display Detailed information about each parameter execute:</i>

```powershell
Syntax : .\redpill.ps1 -Help [ Parameter Name ]
Example: .\redpill.ps1 -Help WifiPasswords
```

![Parametershelp](https://user-images.githubusercontent.com/23490060/107767610-1e0c2380-6d2d-11eb-946e-ce4988087dca.png)

</details>

<br />

<details>
<summary>Instructions how to use the Cmdlet {<b><i>Local tests</i></b>}</summary>

<br />

     This cmdlet belongs to the structure of venom v1.0.17.8 as a post-exploitation module.
     venom amsi evasion agents automatically uploads this CmdLet to %TMP% directory to be
     easily accessible in our reverse tcp shell ( shell ).

     'this section describes how to test this Cmdlet Locally without exploiting target host'

<br />

1º - Download CmdLet from GitHub repository to <b><i>'Local Disk'</i></b>

```powershell
iwr -Uri https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/redpill.ps1 -OutFile redpill.ps1|Unblock-File
```

<br />

2º - Set Powershell Execution Policy to <b><i>'UnRestricted'</i></b>

```powershell
Set-ExecutionPolicy UnRestricted -Scope CurrentUser
```

![ste](https://user-images.githubusercontent.com/23490060/106375669-f2308b80-6385-11eb-8cff-947178c52915.png)

<br />

3º -  Browse to <b><i>'redpill.ps1'</i></b> storage directory

```powershell
cd C:\Users\pedro\Desktop
```

![redpillpath](https://user-images.githubusercontent.com/23490060/107781146-76e4b780-6d3f-11eb-9a41-de1163086c70.png)

<br />

4º - Access CmdLet Help Menu {All Parameters}

```powershell
.\redpill.ps1 -Help Parameters
```

![menu](https://user-images.githubusercontent.com/23490060/107781666-0c804700-6d40-11eb-9fbc-4826705534e5.png)

<br />

5º - Access <b><i>[ -WifiPasswords ]</i></b> Detailed Parameter Help

```powershell
Syntax : .\redpill.ps1 -Help [ Parameter Name ]
Example: .\redpill.ps1 -Help WifiPasswords
```

![Parametershelp](https://user-images.githubusercontent.com/23490060/107767610-1e0c2380-6d2d-11eb-946e-ce4988087dca.png)

<br />

6º - Running <b><i>[ -WifiPasswords ] [ Dump ]</i></b> Module 

```powershell
Syntax : .\redpill.ps1 [ Parameter Name ] [ @argument ]
Example: .\redpill.ps1 -WifiPasswords Dump
```

![wifidump](https://user-images.githubusercontent.com/23490060/107768059-c7531980-6d2d-11eb-9f2a-2e2f2e649f56.png)

<br />

7º - Running <b><i>[ -sysinfo ] [ Enum ]</i></b> Module 

```powershell
Syntax : .\redpill.ps1 [ Parameter Name ] [ @argument ]
Example: .\redpill.ps1 -sysinfo Enum
```

![geolocation](https://user-images.githubusercontent.com/23490060/107866747-c7593380-6e6b-11eb-8e38-9ef3acdb3c01.png)

</details>

<br />

<details>
<summary>Instructions how to use the CmdLet under <b><i>Venon v1.0.17.8</i></b></summary>

<br />

     This cmdlet belongs to the structure of venom v1.0.17.8 as a post-exploitation module.
     venom amsi evasion agents automatically uploads this CmdLet to %TMP% directory to be
     easily accessible in our reverse tcp shell ( shell prompt ).

<br />

1º - execute in reverse tcp shell prompt

```cmd
[SKYNET] C:\Users\pedro\AppData\Local\Temp> powershell -File redpill.ps1 -Help Parameters
```

<br />

![menu](https://user-images.githubusercontent.com/23490060/107781666-0c804700-6d40-11eb-9fbc-4826705534e5.png)

<br />

2º - Access <b><i>[ -WifiPasswords ]</i></b> Detailed Parameter Help

```cmd
[SKYNET] C:\Users\pedro\AppData\Local\Temp> powershell -File redpill.ps1 -Help WifiPasswords
```

![Parametershelp](https://user-images.githubusercontent.com/23490060/107767610-1e0c2380-6d2d-11eb-946e-ce4988087dca.png)

<br />

3º - Running <b><i>[ -WifiPasswords ] [ Dump ]</i></b> Module 

```cmd
[SKYNET] C:\Users\pedro\AppData\Local\Temp> powershell -File redpill.ps1 -WifiPasswords Dump
```

![wifidump](https://user-images.githubusercontent.com/23490060/107768059-c7531980-6d2d-11eb-9f2a-2e2f2e649f56.png)

</details>

<br />

<details>
<summary>To Manual download the CmdLet for Local Tests, execute:</summary><br />

```powershell
iwr -Uri https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/redpill.ps1 -OutFile redpill.ps1|Unblock-File
```

</details>

<br />

## :octocat: Video Tutorials

![Demo](https://user-images.githubusercontent.com/23490060/117714794-5a85d900-b1cf-11eb-8928-b183d6966f3b.gif)<br />
Demonstration - [This tutorial uses: sysinfo, GetPasswords, UacMe modules](https://drive.google.com/file/d/1iryAhz-ryJWMz8-MNqKm1WffLYS6nhT0/view?usp=sharing)<br />
MouseLogger - [Capture Screenshots of 'MouseClicks' with the help of psr.exe](https://drive.google.com/file/d/1k3DrsDEc6nOd7RHm-25nw0q6oD_aGxjg/view?usp=sharing)<br />
PhishCreds - [Phish for login credentials OR Brute Force user account password](https://drive.google.com/file/d/1m1M4rp24QGYftv9JPnp5Kj_zs8YFhz3_/view?usp=sharing)<br />
FileMace - [Change File TimeStamp {CreationTime, LastAccessTime, LastWriteTime}](https://drive.google.com/file/d/10tR3hu_pS9tJiTImJTkraXozEEgAezwx/view?usp=sharing)<br />
CsOnTheFly - [Download (from url), Auto-Compile and Execute CS scripts On-The-Fly!](https://drive.google.com/file/d/1L4Qj0eK4QMbC6yBFlUVJQyi0NEoe25Ug/view?usp=sharing)<br />
EOP - [Find missing software patchs for privilege escalation](https://drive.google.com/file/d/1s6hPm63i4m2CHXEZU4ByRJRA41EOwUGf/view?usp=sharing)

<br /><br />

## :octocat: Acknowledgments

|hax0r|Function|OS Flavor|
|---|---|---|
|<b><i>@youhacker55|For All the help Debugging this cmdlet (Testing BETA version)|Windows 7 x64bits</b>|
|<b><i>@0xyg3n|For All the help Debugging this cmdlet (Testing BETA version)|Windows 10 x64bits</b>|
|<b><i>@Shanty_Damayanti|Debugging this cmdlet (amsi string detection bypasses)|Windows 10 x64bits</b>|
|<b><i>@miltinhoc|Debugging this cmdlet and recording video tutorials|Windows 10 x64bits</b>|

![sysinfo](https://user-images.githubusercontent.com/23490060/128348577-107d7478-8d92-46be-b617-9878f08bb524.png)<br /><br />
![GetConnections](https://user-images.githubusercontent.com/23490060/127775867-3a1d4e60-81df-4982-8c63-4d54fcbd0e8b.png)<br /><br />
![SAM](https://user-images.githubusercontent.com/23490060/128350159-85cf1868-64ff-488d-8bbf-26c614b8cf3f.png)<br /><br />
![brute](https://user-images.githubusercontent.com/23490060/128359506-f9dff4fe-e586-4407-998c-a467875745a9.jpg)<br /><br />
![eop](https://user-images.githubusercontent.com/23490060/128349459-eb129772-6955-4822-8677-fa1878d4ec01.png)<br /><br />
![NoAmsi](https://user-images.githubusercontent.com/23490060/125387813-6429e980-e396-11eb-9ae7-6a488f1647b8.png)<br />

**[Any collaborations Or bugreports are wellcome](https://github.com/r00t-3xp10it/redpill/issues)**

<br />

<p align="center">
  <a href="https://github.com/r00t-3xp10it//github-readme-stats">
    <img
      align="center"
      height="165"
      src="https://github-readme-stats.vercel.app/api?username=r00t-3xp10it&count_private=true&show_icons=true&custom_title=Github%20Status&hide=issues&theme=radical"
    />
  </a>
</p>


<br />


<p align="center">
  <a href="https://github.com/r00t-3xp10it//github-readme-stats">
    <img
      align="center"
      height="295"
      src="https://github-readme-stats.vercel.app/api/top-langs/?username=r00t-3xp10it&langs_count=10&layout=compact&theme=radical"
    />
  </a>
</p>

<p align="center">
 <img src="https://visitor-badge.laobi.icu/badge?page_id=r00t-3xp10it" alt="visitor badge" style="vertical-align:top; margin:4px">
</p>

## SuspiciousShellActivity - RedTeam @2021
