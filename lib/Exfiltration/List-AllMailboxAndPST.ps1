#requires -version 2
<#
.SYNOPSIS  
   This script uses the Outlook COM object
   to display the data stores in the current profile.

   Author: @ALBERT Jean-Marc
   Creation Date: 29/06/2015
   Version: 1.0

.DESCRIPTION  
   This script creates an Outlook object, displays user
   information, and the stores currently attached to the profile.

.EXAMPLE  
   PS C:\> .\List-AllMailboxAndPST.ps1

.INPUTS
   None. You cannot pipe objects into List-AllMailboxAndPST.ps1

.OUTPUTS
   Account Type                     User Name             SMTP Address  
   ------------                     ---------             ------------  
   Jean-Marc.Albert-EXT@domain.com  Jean-Marc.ALBERT-EXT  Jean-Marc.Albert-EXT@domain.com  
      
   Exchange Offile Folder Store:  
   C:\Users\9999912\AppData\Local\Microsoft\Outlook\Jean-Marc.Albert-EXT@domain.com.ost  
     
   PST Files  
   Display Name    File Path   
   ------------    ---------  
   Archive Folders C:\Users\jean-marc.albert\AppData\Local\Microsoft\Outlook\archive.pst  
#>


#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null


#Script Version
$sScriptVersion = "1.0"
#Write script directory path on "ScriptDir" variable
$ScriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
#Log file creation, similar to $ScriptDir\[SCRIPTNAME]_[YYYY_MM_DD].log
$SystemTime = Get-Date -uformat %Hh%Mm%Ss
$SystemDate = Get-Date -uformat %Y.%m.%d
$ScriptLogFile = "$ScriptDir\$([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Definition))" + "_" + $SystemDate + "_" + $SystemTime + ".log"


$tcount = 100
for($i=0;$i -le $tcount; $i++)
{
   #Progress Bar!
   $pcomplete = ($i / $tcount) * 100
   Write-Progress -Activity "Extracting Outlook objects." -Status "Percentage $i%" -PercentComplete $pcomplete
   $i;Start-Sleep -Milliseconds 20
   Clear-Host
}


$Banner = @"

             * Reverse TCP Shell Auxiliary Powershell Module *
     _________ __________ _________ _________  o  ____      ____      
    |    _o___)   /_____/|     O   \    _o___)/ \/   /_____/   /_____ 
    |___|\____\___\%%%%%'|_________/___|%%%%%'\_/\___\_____\___\_____\   
          Author: r00t-3xp10it - SSAredTeam @2021 - Version: 1.2.6
            Help: powershell -File redpill.ps1 -Help Parameters

      
"@;
Write-Host ""
Write-Host "$Banner" -ForegroundColor Blue

function Stop-TranscriptOnLog
{
   Stop-Transcript
   #Add EOL required for Notepad.exe application usage
   [string]::Join("`r`n", (Get-Content $ScriptLogFile)) | Out-File $ScriptLogFile
}


#Start of log completion
Start-Transcript $ScriptLogFile | Out-Null

#Create Outlook object
$Outlook = New-Object -ComObject Outlook.Application  
$stores = $Outlook.Session.Stores
$accounts = $outlook.session.accounts

If(-not($accounts) -or $accounts -ieq $null)
{
   #Check for accounts existence!
   Write-Host "ERROR: none outlook accounts found under $Env:COMPUTERNAME!" -ForegroundColor Red -BackgroundColor Black
   Write-Host "`n";exit #Exit @List-AllMailboxAndPST
}

#Build Output Table!
$dn = @{label = "Account Type"; expression={$_.displayname}}  
$un = @{label = "User Name"; expression = {$_.username}}  
$sm = @{label = "SMTP Address"; expression = {$_.smtpaddress}}

#Display Output Table! {colorize}
$accounts | Format-Table -AutoSize $dn,$un,$sm |
   Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -iMatch 'SMTP'){
         @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
      Write-Host @stringformat $_
}

#Check number of stores > 0  
If($stores.Count -le 0)
{
   Write-Host "No stores found under $Env:COMPUTERNAME!" -ForegroundColor Red -BackgroundColor Black
   return
}
  
#Delete artifacts left behind
If(Test-Path -Path "$ScriptLogFile" -EA Continue)
{
   Remove-Item -Path "$ScriptLogFile" -Force
}
#End Script