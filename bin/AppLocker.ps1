<#
.SYNOPSIS
   Enumerate Directorys with weak permissions (bypass applocker)

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.5

.DESCRIPTION
   Applocker.ps1 module searchs in pre-defined directorys in %WINDIR%
   location for folders with weak permissions {Modify,Write,FullControl}
   that can be used to bypass system AppLocker binary execution policy.

.NOTES
   AppLocker.ps1 by Default uses 'BUILTIN\Users' Group Name
   to search for directorys with 'Write' access on %WINDIR%
   This module also allow users to sellect a diferent Group
   Name or diferent folder permission rigths to search for.

   Search locations:
   $Env:WINDIR\Tasks
   $Env:WINDIR\tracing
   $Env:SYSTEMDRIVE\Temp
   $Env:SYSTEMDRIVE\Users\Public
   $Env:WINDIR\Registration\CRMLog
   $Env:WINDIR\System32\Tasks_Migrated
   $Env:WINDIR\System32\spool\drivers\color
   $Env:WINDIR\System32\Microsoft\Crypto\RSA\MachineKeys
   $Env:WINDIR\SysWOW64\Tasks\Microsoft\Windows\SyncCenter
   $Env:WINDIR\System32\Tasks\Microsoft\Windows\SyncCenter

.Parameter WhoAmi
   Accepts arguments: Groups (List available Group Names).

.Parameter FolderRigths
   Accepts permissions: Modify, Write, FullControll, etc.

.Parameter GroupName
   Accepts GroupNames: Everyone, BUILTIN\Users, NT AUTHORITY\INTERACTIVE, etc.

.EXAMPLE
   PS C:\> Get-Help .\AppLocker.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\AppLocker.ps1 -WhoAmi Groups
   Enumerate ALL Group Names Available on local machine

.EXAMPLE
   PS C:\> .\AppLocker.ps1 -GroupName "BUILTIN\Users" -FolderRigths "Write"
   Enum directorys owned by 'BUILTIN\Users' GroupName with 'Write' permissions

.EXAMPLE
   PS C:\> .\AppLocker.ps1 -GroupName "Everyone" -FolderRigths "FullControl"
   Enum directorys owned by 'Everyone' GroupName with 'FullControl' permissions

.INPUTS
   None. You cannot pipe objects into AppLocker.ps1

.OUTPUTS
   AppLocker - Weak Directory permissions
   --------------------------------------
   VulnId            : 1::ACL (Mitre T1222)
   FolderPath        : C:\WINDOWS\tracing
   IdentityReference : BUILTIN\Utilizadores
   FileSystemRights  : Write

   VulnId            : 2::ACL (Mitre T1222)
   FolderPath        : C:\WINDOWS\System32\Microsoft\Crypto\RSA\MachineKeys
   IdentityReference : BUILTIN\Utilizadores
   FileSystemRights  : Write
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FolderRigths="Write",
   [string]$GroupName="false",
   [string]$Success="false",
   [string]$WhoAmi="false"
)


## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
## Set default values in case user skip it
If(-not($FolderRigths) -or $FolderRigths -ieq "false"){
    $FolderRigths = "Write"
}


If($WhoAmi -ieq "Groups"){

   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - List ALL Group Names Available

   .EXAMPLE
      PS C:\> .\AppLocker.ps1 -WhoAmi Groups

   .OUTPUTS
      Group Name                                                 Type             SID          Attributes
      ========================================================== ================ ============ ==================================================
      Todos                                                      Well-known group S-1-1-0      Mandatory group, Enabled by default, Enabled group
      NT AUTHORITY\Conta local e membro do grupo Administradores Well-known group S-1-5-114    Group used for deny only
      BUILTIN\Administradores                                    Alias            S-1-5-32-544 Group used for deny only
      BUILTIN\Utilizadores                                       Alias            S-1-5-32-545 Mandatory group, Enabled by default, Enabled group
      BUILTIN\Utilizadores do registo de desempenho              Alias            S-1-5-32-559 Mandatory group, Enabled by default, Enabled group
      NT AUTHORITY\INTERACTIVE                                   Well-known group S-1-5-4      Mandatory group, Enabled by default, Enabled group
      INICIO DE SESSAO NA CONSOLA                                Well-known group S-1-2-1      Mandatory group, Enabled by default, Enabled group
      NT AUTHORITY\Utilizadores Autenticados                     Well-known group S-1-5-11     Mandatory group, Enabled by default, Enabled group
      NT AUTHORITY\Esta organizacao                              Well-known group S-1-5-15     Mandatory group, Enabled by default, Enabled group
      NT AUTHORITY\Conta local                                   Well-known group S-1-5-113    Mandatory group, Enabled by default, Enabled group
      LOCAL                                                      Well-known group S-1-2-0      Mandatory group, Enabled by default, Enabled group
      NT AUTHORITY\Autenticacao NTLM                             Well-known group S-1-5-64-10  Mandatory group, Enabled by default, Enabled group
   #>

   ## Display available Groups
   $ListGroups = whoami /groups|findstr /V "GROUP INFORMATION ----- Label"
   echo $ListGroups > $Env:TMP\Groups.log
   Get-Content -Path "$Env:TMP\Groups.log"
   Remove-Item -Path "$Env:TMP\Groups.log" -Force
   Start-Sleep -Seconds 1;Write-Host ""
   exit ## Exit @AppLocker
}


If($GroupName -ieq "false"){
    ## Get Group Name (BUILTIN\users) in diferent languages
    # NOTE: England, Portugal, France, Germany, Indonesia, Holland, Romania, Croacia
    $FindGroupUser = whoami /groups|findstr /C:"BUILTIN\Users" /C:"BUILTIN\Utilizadores" /C:"BUILTIN\Utilisateurs" /C:"BUILTIN\Benutzer" /C:"BUILTIN\Pengguna" /C:"BUILTIN\Gebruikers" /C:"BUILTIN\Utilizatori" /C:"BUILTIN\Korisnici"|Select-Object -First 1
    $SplitStringUser = $FindGroupUser -split(" ");$GroupNameUsers = $SplitStringUser[0] -replace ' ',''
}

If($GroupName -Match '\\'){
    $RawUserGroup = $GroupName ## BUILTIN\Users
    $GroupName = $GroupName -replace '\\','\\' ## BUILTIN\\Users
}ElseIf($GroupNameUsers -Match '\\'){
    $RawUserGroup = $GroupNameUsers ## BUILTIN\Users
    $GroupName = $GroupNameUsers -replace '\\','\\' ## BUILTIN\\Users
}Else{## Example: Everyone Group Name
    $RawUserGroup = $GroupName ## Everyone
}

 
## Build Output Table
echo "`nAppLocker - Weak Directory permissions" > $Env:TMP\qwerty.log
echo "--------------------------------------" >> $Env:TMP\qwerty.log
Get-Content -Path "$Env:TMP\qwerty.log"
Remove-Item -Path "$Env:TMP\qwerty.log" -Force
Start-Sleep -Seconds 1


[int]$Count = 0
## Bypass AppLocker directorys to search recursive:
$dAtAbAsEList = Get-Item -Path "$Env:WINDIR\System32\spool\drivers\color","$Env:WINDIR\Registration\CRMLog","$Env:WINDIR\Tasks","$Env:WINDIR\tracing","$Env:SYSTEMDRIVE\Temp","$Env:SYSTEMDRIVE\Users\Public","$Env:WINDIR\System32\Tasks_Migrated","$Env:WINDIR\System32\Microsoft\Crypto\RSA\MachineKeys","$Env:WINDIR\SysWOW64\Tasks\Microsoft\Windows\SyncCenter","$Env:WINDIR\System32\Tasks\Microsoft\Windows\SyncCenter" -EA SilentlyContinue|Where-Object { $_.PSIsContainer }|Select-Object -ExpandProperty FullName
ForEach($Token in $dAtAbAsEList){## Loop truth Get-ChildItem Items (Paths)
    (Get-Acl "$Token" -EA SilentlyContinue).Access|Where-Object {
    $CleanOutput = $_.FileSystemRights -Match "$FolderRigths" -and $_.IdentityReference -Match "$GroupName" ## <-- In my system the IdentityReference is: 'Todos'
        If($CleanOutput){$Count++ ##  Write the Table 'IF' found any vulnerable permissions
            Write-Host "`nVulnId            : ${Count}::ACL (Mitre T1222)"
            Write-Host "FolderPath        : $Token" -ForegroundColor Green
            Write-Host "IdentityReference : $RawUserGroup"
            Write-Host "FileSystemRights  : $FolderRigths"
            $Success = $True
        }
    }## End of Get-Acl loop
}## End of ForEach loop


If($Success -ne $True){
    echo "[error] None dir found with: '$FolderRigths' permissions!" > $Env:TMP\werre.log
    Get-Content -Path "$Env:TMP\werre.log"
    Remove-Item -Path "$Env:TMP\werre.log" -Force
}Else{
    Write-Host "`n`n[$Count] Directorys found with weak permissions!" -ForegroundColor Green -BackgroundColor Black
}
Write-Host ""
