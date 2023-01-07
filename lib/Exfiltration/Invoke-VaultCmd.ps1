<#
.SYNOPSIS
   Manage Windows Password Vault Items

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: VaultSvc, VaultCmd
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.4
   
.DESCRIPTION
   Manage Windows Password Vault Items

.NOTES
   This cmdlet only creates or dumps credentials with
   [Generic passwords] It will not decode DPAPI creds.
   Warning: Parameter 'resource' and 'username' are
   required to delete entrys from Password Vault.

.Parameter Action
   Check, Create, Dumpall, Delete (default: check) 

.Parameter Resource
   Resource or Url (default: https://siliconvalley/Classified.portal)

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
   PS C:\> .\Invoke-VaultCmd.ps1 -action dumpall
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
   [string]$Resource="https://siliconvalley/Classified.portal",
   [string]$UserName="${Env:COMPUTERNAME}\${Env:USERNAME}",
   [string]$Password="r00t3xp10it",
   [string]$Action="check"
)


$Names = @()
$CmdletVersion = "v1.0.4"
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
write-host "`n[vault] Manage Windows Vault Entrys." -ForegroundColor Green
$host.UI.RawUI.WindowTitle = "@Invoke-VaultCmd $CmdletVersion {SSA@RedTeam}"

## Make sure service VaultSvc is running
If((Get-Service -Name "VaultSvc").Status -iNotMatch '^(Running)$')
{
   write-host "`n[vault] Error: Cmdlet requires 'VaultSvc' service running.`n" -ForegroundColor Red
   return
}

## Initializing the PasswordVault Object
[void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
$vault = New-Object Windows.Security.Credentials.PasswordVault

## Build Table Object
$VaultEntrys = New-Object System.Data.DataTable
$VaultEntrys.Columns.Add("Secret")|Out-Null
$VaultEntrys.Columns.Add("Vault Name")|Out-Null
$VaultEntrys.Columns.Add("Resource")|Out-Null

## Print OnScreen vault resources \ schema list
$ListVault = $(VaultCmd /list|Select-String -Pattern "Vault:")
$Schemas = $ListVault -replace '^\s*Vault: ',''
ForEach($Token in $Schemas)
{
   ## List credentials existence with VaultCmd builtin software
   $Names = vaultcmd /listcreds:"$Token" /all | Select-String -Pattern 'Resource' | ForEach-Object {
      $Protection = $(VaultCmd /listproperties:"$Token" | findstr "Current protection method:" | findstr /V "Location") -replace 'Current protection method: ',''
      $Properties = $(VaultCmd /listproperties:"$Token" | findstr "Vault Properties:" | findstr /V "Location") -replace 'Vault Properties: ',''
      $ResourceName = $_ -replace 'Resource: ',''

      ## Add entrys found to Table
      $VaultEntrys.Rows.Add("$Protection","$Properties","$ResourceName")|Out-Null
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
   $VaultEntrys | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 1 | ForEach-Object {
      $stringformat = If($_ -Match '^(Secret)')
      {
         @{ 'ForegroundColor' = 'DarkYellow' }
      }
      Else
      {
         @{ 'ForegroundColor' = 'White' }
      }
      Write-Host @stringformat $_
   }

   ## Check if vault contains any Generic creds
   If(($vault.RetrieveAll()) -ne $null)
   {
      ## Use GUI ??? Or Format-Table outputs?
      # $vault.RetrieveAll() | Out-GridView -title "credentials dump"
      $vault.RetrieveAll() | Select-Object Username,Resource,@{Name='Password Type';Expression={"Hidden::Generic"}} |
         Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1 | ForEach-Object {
            $stringformat = If($_ -Match '^(UserName)')
            {
               @{ 'ForegroundColor' = 'Green' }
            }
            Else
            {
               @{ 'ForegroundColor' = 'White' }
            }
            Write-Host @stringformat $_
         }
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

   ## Make sure resource name
   # does not exist inside vault
   $preventinputerrors = @()
   ForEach($Token in $Schemas)
   {
      ## List credentials existence with VaultCmd builtin software
      $preventinputerrors += (vaultcmd /listcreds:"$Token" /all | Select-String -Pattern 'Resource') -replace 'Resource: ',''
   }

   $limpesadomestica = $Resource -replace '\\','\\'
   If($preventinputerrors -match "$limpesadomestica") ## NEED TO USE MATCH
   {
      ## Print OnScreen existing creds (DPAPI + GENERIC) inside passwordvault
      $VaultEntrys | Format-Table -AutoSize | Out-String -Stream | Select-Object -Skip 1 |
         Select-Object -SkipLast 1 | ForEach-Object {
            $stringformat = If($_ -Match '^(Secret)')
            {
               @{ 'ForegroundColor' = 'DarkYellow' }
            }
            Else
            {
               @{ 'ForegroundColor' = 'White' }
            }
            Write-Host @stringformat $_
         }

      write-host "[vault] Error: " -ForegroundColor Red -NoNewline
      write-host "$Resource" -ForegroundColor DarkYellow -NoNewline
      write-host " already exists.`n" -ForegroundColor Red
      return
   }

   ## Create unique credential ObjectAPI
   $cred = New-Object windows.Security.Credentials.PasswordCredential
   $cred.Resource = "$Resource"
   $cred.UserName = "$UserName"
   $cred.Password = "$Password"
   $vault.Add($cred)

   # ReView credential existance now
   If(($vault.RetrieveAll()) -ieq $null)
   {
      write-host "[vault] Error: fail to create: $Resource.`n" -ForegroundColor Red
   }
   Else
   {
      ## Print OnScreen just the recent created credential info      
      $vault.RetrieveAll() | Where-Object { $_.Resource -iMatch "^($REsource)$" } |
         Select-Object -Property UserName,Resource,@{Name='Password Type';Expression={"Hidden::Generic"}} |
         Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1 | ForEach-Object {
            $stringformat = If($_ -Match '^(UserName)')
            {
               @{ 'ForegroundColor' = 'Green' }
            }
            Else
            {
               @{ 'ForegroundColor' = 'White' }
            }
            Write-Host @stringformat $_
         }
   }

   ## Variable CleanUp
   Remove-Variable cred
}


If($Action -iMatch '^(Dumpall)$')
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
   $VaultEntrys | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 1 | ForEach-Object {
      $stringformat = If($_ -Match '^(Secret)')
      {
         @{ 'ForegroundColor' = 'DarkYellow' }
      }
      Else
      {
         @{ 'ForegroundColor' = 'White' }
      }
      Write-Host @stringformat $_
   }

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
      Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1 | ForEach-Object {
         $stringformat = If($_ -Match '^(UserName)')
         {
            @{ 'ForegroundColor' = 'Green' }
         }
         Else
         {
            @{ 'ForegroundColor' = 'White' }
         }
         Write-Host @stringformat $_
      }
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
   $VaultEntrys | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 1 | ForEach-Object {
      $stringformat = If($_ -Match '^(Secret)')
      {
         @{ 'ForegroundColor' = 'DarkYellow' }
      }
      Else
      {
         @{ 'ForegroundColor' = 'White' }
      }
      Write-Host @stringformat $_
   }


   $preventinputerrors = @()
   ForEach($Token in $Schemas)
   {
      ## List credentials existence with VaultCmd builtin software
      $preventinputerrors += (vaultcmd /listcreds:"$Token" /all | Select-String -Pattern 'Resource') -replace 'Resource: ',''
   }

   $limpesadomestica = $Resource -replace '\\','\\'
   If($preventinputerrors -match "$limpesadomestica") ## NEED TO USE MATCH
   {$treta = $null}
   Else
   {
      write-host "[vault] not found: " -ForegroundColor Red -NoNewline
      write-host "$Resource" -ForegroundColor DarkYellow -NoNewline
      write-host " Resource`n" -ForegroundColor Red
      return
   }


   #Removing Unique Credential API
   $cred = New-Object Windows.Security.Credentials.PasswordCredential
   $cred.Resource = "$Resource"
   $cred.UserName = "$UserName"
   $vault.Remove($cred)


   $CheckDataBase = @()
   Start-Sleep -Seconds 1
   ForEach($Token in $Schemas)
   {
      ## List credentials existence with VaultCmd builtin software
      $CheckDataBase += (vaultcmd /listcreds:"$Token" /all | Select-String -Pattern 'Resource') -replace 'Resource: ',''
   }

   $detergente = $Resource -replace '\\','\\'
   If($CheckDataBase -match "$detergente") ## NEED TO USE MATCH
   {
      write-host "[vault] fail to delete " -ForegroundColor Red -NoNewline
      write-host "$Resource`n" -ForegroundColor DarkYellow -NoNewline

      write-host "[vault] " -ForegroundColor Red -NoNewline
      write-host "review " -NoNewline
      write-host "$Username" -ForegroundColor DarkYellow -NoNewline
      write-host " and " -NoNewline
      write-host "$Resource" -ForegroundColor DarkYellow -NoNewline
      write-host " parameters.`n"
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
      $Results | Out-String -Stream | Select-Object -SkipLast 1 | ForEach-Object {
         $stringformat = If($_ -Match '^(UserName)')
         {
            @{ 'ForegroundColor' = 'Green' }
         }
         ElseIf($_ -Match '(Deleted)$')
         {
            @{ 'ForegroundColor' = 'DarkYellow' }         
         }
         Else
         {
            @{ 'ForegroundColor' = 'White' }
         }
         Write-Host @stringformat $_
      }

   }

   ## Variable CleanUp
   Remove-Variable cred
}