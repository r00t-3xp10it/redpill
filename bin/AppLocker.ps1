<#
.SYNOPSIS
   Enumerate Directorys with weak permissions (bypass applocker)

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.NOTES
   AppLocker.ps1 by default uses 'BUILTIN\Users' Group Name
   to search for directorys with 'Write' access on Disk.

   Search locations:
   $Env:WINDIR\Temp
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

.Parameter FolderRigths
   Accepts permissions: Modify, Write, FullControll, etc

.Parameter UserGroup
   Accepts GroupNames: Everyone, BUILTIN\Users, NT AUTHORITY\INTERACTIVE, etc

.EXAMPLE
   PS C:\> Get-Help .\AppLocker.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\AppLocker.ps1 -UserGroup "BUILTIN\Users" -FolderRigths "Write"
   Enumerate directorys with 'Write' permissions on 'BUILTIN\Users' Group Name

.EXAMPLE
   PS C:\> .\AppLocker.ps1 -UserGroup "Everyone" -FolderRigths "FullControl"
   Enumerate directorys with 'FullControl' permissions on 'Everyone' Group Name

.INPUTS
   None. You cannot pipe objects into AppLocker.ps1

.OUTPUTS
   AppLocker Weak Directory permissions
   ------------------------------------

   VulnId            : 1::ACL (Mitre T1222)
   FolderPath        : C:\WINDOWS\tracing
   FileSystemRights  : Write
   IdentityReference : BUILTIN\Utilizadores

   VulnId            : 2::ACL (Mitre T1222)
   FolderPath        : C:\WINDOWS\System32\Microsoft\Crypto\RSA\MachineKeys
   FileSystemRights  : Write
   IdentityReference : BUILTIN\Utilizadores

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/r00t-3xp10it/redpill/blob/main/bin/AppLocker.ps1
   https://www.hacking-tutorial.com/hacking-tutorial/how-to-bypass-windows-applocker/#sthash.S5HpWGRZ.dpbs
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FolderRigths="Write",
   [string]$UserGroup="false",
   [string]$Success="false"
)


If($UserGroup -ieq "false"){
    ## Get Group Name (BUILTIN\users) in diferent languages
    # NOTE: England, Portugal, France, Germany, Indonesia, Holland, Romania, Croacia
    $FindGroupUser = whoami /groups|findstr /C:"BUILTIN\Users" /C:"BUILTIN\Utilizadores" /C:"BUILTIN\Utilisateurs" /C:"BUILTIN\Benutzer" /C:"BUILTIN\Pengguna" /C:"BUILTIN\Gebruikers" /C:"BUILTIN\Utilizatori" /C:"BUILTIN\Korisnici"|Select-Object -First 1
    $SplitStringUser = $FindGroupUser -split(" ");$GroupNameUsers = $SplitStringUser[0] -replace ' ',''
}

If($UserGroup -Match '\\'){
    $RawUserGroup = $UserGroup ## BUILTIN\Users
    $UserGroup = $UserGroup -replace '\\','\\' ## BUILTIN\\Users
}ElseIf($GroupNameUsers -Match '\\'){
    $RawUserGroup = $GroupNameUsers ## BUILTIN\Users
    $UserGroup = $GroupNameUsers -replace '\\','\\' ## BUILTIN\\Users
}Else{## Example: Everyone Group Name
    $RawUserGroup = $UserGroup ## BUILTIN\Users
}

 
## Build Output Table
echo "`nAppLocker Weak Directory permissions" > $Env:TMP\qwerty.log
echo "------------------------------------" >> $Env:TMP\qwerty.log
Get-Content -Path "$Env:TMP\qwerty.log"
Remove-Item -Path "$Env:TMP\qwerty.log" -Force
Start-Sleep -Seconds 1


## Bypass AppLocker directorys to search recursive:
$dAtAbAsEList = Get-Item -Path "$Env:WINDIR\System32\spool\drivers\color","$Env:WINDIR\Registration\CRMLog","$Env:WINDIR\Temp","$Env:WINDIR\Tasks","$Env:WINDIR\tracing","$Env:SYSTEMDRIVE\Temp","$Env:SYSTEMDRIVE\Users\Public","$Env:WINDIR\System32\Tasks_Migrated","$Env:WINDIR\System32\Microsoft\Crypto\RSA\MachineKeys","$Env:WINDIR\SysWOW64\Tasks\Microsoft\Windows\SyncCenter","$Env:WINDIR\System32\Tasks\Microsoft\Windows\SyncCenter" -EA SilentlyContinue|Where-Object { $_.PSIsContainer }|Select-Object -ExpandProperty FullName
ForEach($Token in $dAtAbAsEList){## Loop truth Get-ChildItem Items (Paths)
    (Get-Acl "$Token" -EA SilentlyContinue).Access|Where-Object {
    $CleanOutput = $_.FileSystemRights -Match "$FolderRigths" -and $_.IdentityReference -Match "$UserGroup" ## <-- In my system the IdentityReference is: 'Todos'
        If($CleanOutput){$Count++ ##  Write the Table 'IF' found any vulnerable permissions
            Write-Host "`nVulnId            : ${Count}::ACL (Mitre T1222)"
            Write-Host "FolderPath        : $Token" -ForegroundColor Green
            Write-Host "FileSystemRights  : $FolderRigths"
            Write-Host "IdentityReference : $RawUserGroup"
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
