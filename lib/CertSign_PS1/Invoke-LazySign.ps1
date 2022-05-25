<#
.SYNOPSIS
   Sign a Windows binary with a self-signed certificate

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Administrator privileges
   Optional Dependencies: New-SelfSignedCertificate
   PS cmdlet Dev version: v1.0.8

.DESCRIPTION
   This cmdlet allow users to sign windows cmdlets or scripts
   in windows certificate store. This action allow us to exec
   cmdlets later, even if powershell ExecutionPolicy its set
   to only run signed cmdlets ( AllSigned, RemoteSigned )

.NOTES
   This cmdlet uses 'Cert:\LocalMachine\My' store to create certs,
   then exports the created certificate to 'Cert:\LocalMachine\Root'.
   Invoking -NotAfter '8' will maintain the fake cert in store for
   8 months before auto-delete itself after the limmit time reached.

.Parameter Action
   Accepts arguments: query, sign, del (default: query)

.Parameter Target
   The windows Cmdlet\Script to sign (default: off)

.Parameter FriendlyName
   Certificate Friendly Name (default: SsaRedTeam)      

.Parameter Subject
   Certificate subject name (default: LazySign)

.Parameter NotAfter
   Auto-Delete cert after [?]months (default: 1)

.EXAMPLE
   PS C:\> .\Invoke-LazySign.ps1 -Action "query" -Subject "[a-z 0-9]"
   Query for ALL certificates in 'Cert:\LocalMachine\My | Root' Store

.EXAMPLE
   PS C:\> .\Invoke-LazySign.ps1 -Action "query" -Subject "LazySign"
   Query for ALL 'LazySign' certs in 'Cert:\LocalMachine\My | Root' Store

.EXAMPLE
   PS C:\> .\Invoke-LazySign.ps1 -Action "sign" -Subject "LazySign" -Target "$pwd\Payload.exe"
   Sign binary (Payload.exe) with crafted certificate (Subject: LazySign-4zrH ExpiresIn: 1 month)

.EXAMPLE
   PS C:\> .\Invoke-LazySign.ps1 -Action "sign" -Subject "LazySign" -Target "Payload.ps1" -NotAfter "12"
   Sign cmdlet (Payload.ps1) with crafted certificate (Subject: LazySign-4zrH ExpiresIn: 12 months)

.EXAMPLE
   PS C:\> .\Invoke-LazySign.ps1 -Action "del" -Subject "LazySign-4zrH"
   Delete the 'LazySign-4zrH' certificate from windows store ..

.OUTPUTS
   * Manage Windows Store Certificates.

      Certificate information
      -----------------------
      FriendlyName : SsaRedTeam
      Subject      : LazySign-4zrH
      ExprireDate  : 24/05/2023 11:48:38
      CertLocation : Cert:\LocalMachine\My
      Target       : C:\Users\pedro\AppData\Local\Temp\Payload.ps1

   Directory: C:\Users\pedro\AppData\Local\Temp\Payload.ps1

   SignerCertificate                         Status                                            Path
   -----------------                         ------                                            ----
   EE350A485751736A3F8785D58E9CDD7CE9EC662D  Valid                                             Payload.ps1

   Thumbprint                                Subject
   ----------                                -------
   6DE90730783ADCA4796F537C203B8A4351C8295B  CN=LazySign-4zrH

   * Exit Invoke-LazySign cmdlet [ok]..

.LINK
   http://woshub.com/how-to-create-self-signed-certificate-with-powershell
   https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/working-with-certificates.md
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FriendlyName="SsaRedTeam",
   [string]$Subject="LazySign",
   [string]$Action="query",
   [string]$Target="off",
   [int]$NotAfter='1'
)


$CmdletVersion = "v1.0.8"
#Global variable declarations
$StoreLocation = "Cert:\LocalMachine\My"
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@Invoke-LazySign $CmdletVersion {SSA@RedTeam}"
$bool = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
write-host "* Manage Windows Store Certificates." -ForegroundColor Green


If(-not(Test-Path -Path "$StoreLocation"))
{
   write-host "`n  x " -ForegroundColor Red -NoNewline
   write-host "Certificate creation dependencies." -ForegroundColor DarkGray

   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "Not found: '" -ForegroundColor DarkGray -NoNewline
   write-host "$StoreLocation" -ForegroundColor Red -NoNewline
   write-host "' Store location." -ForegroundColor DarkGray

   write-host "`n* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
   write-host "ok" -ForegroundColor DarkYellow -NoNewline
   write-host "].." -ForegroundColor Green
   return
}

If($NotAfter -eq 0)
{
   #auto-del limmit
   [int]$NotAfter='1'
}

#Supported stores
$LocationsList = @(
   "Cert:\CurrentUser\My",
   "Cert:\LocalMachine\My",
   "Cert:\LocalMachine\Root"
)


If($Action -ieq "query")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Query for certificate existance in store.

   .OUTPUTS
   * Manage Windows Store Certificates.
     + Store Location: Cert:\LocalMachine\My
     + Store Location: Cert:\LocalMachine\Root

   FriendlyName : Sectigo (AddTrust)
   Subject      : CN=AddTrust External CA Root, OU=AddTrust External TTP Network, O=AddTrust AB, C=SE
   Issuer       : CN=AddTrust External CA Root, OU=AddTrust External TTP Network, O=AddTrust AB, C=SE
   PSParentPath : Microsoft.PowerShell.Security\Certificate::LocalMachine\Root
   NotAfter     : 30/05/2020 11:48:38
   NotBefore    : 30/05/2000 11:48:38

   * Exit Invoke-LazySign cmdlet [ok]..   
   #>

   #Local function variable declarations
   write-host "  + " -ForegroundColor DarkYellow -NoNewline
   write-host "Store Location: " -ForegroundColor DarkGray -NoNewline
   write-host "Cert:\CurrentUser\My" -ForegroundColor DarkYellow
   write-host "  + " -ForegroundColor DarkYellow -NoNewline
   write-host "Store Location: " -ForegroundColor DarkGray -NoNewline
   write-host "$StoreLocation" -ForegroundColor DarkYellow
   write-host "  + " -ForegroundColor DarkYellow -NoNewline
   write-host "Store Location: " -ForegroundColor DarkGray -NoNewline
   write-host "Cert:\LocalMachine\Root" -ForegroundColor DarkYellow

   ForEach($SetLocation in $LocationsList)
   {
      ## Query certlm.msc for certificate existance
      Get-ChildItem "$SetLocation" | Where-Object {
         $_.Issuer -iMatch "$Subject" -or $_.Subject -iMatch "^(CN=$Subject)"
      }| Select-Object FriendlyName,Subject,Issuer,PSParentPath,NotAfter,NotBefore |
      Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 2 | Format-List >> $Env:TMP\dave.log
   }

   If((Get-Content -Path "$Env:TMP\dave.log") -eq $null)
   {
      Remove-Item -Path "$Env:TMP\dave.log" -Force
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: none '" -ForegroundColor DarkGray -NoNewline
      write-host "$Subject" -ForegroundColor Red -NoNewline
      write-host "' certificates found.." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return
   }

   #Output certificate information
   Get-Content -Path "$Env:TMP\dave.log"
   Remove-Item -Path "$Env:TMP\dave.log" -Force
}


If($Action -ieq "Sign")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Sign a Windows binary\script with a self-signed cert.

   .NOTES
      Requires: New-SelfSignedCertificate, Set-AuthenticodeSignature

      This function uses 'Cert:\LocalMachine\My' store to create certs,
      then exports the created certificate to 'Cert:\LocalMachine\Root'.

   .OUTPUTS
      * Manage Windows Store Certificates.

        Certificate information
        -----------------------
        FriendlyName : SsaRedTeam
        Subject      : LazySign-4zrH
        ExprireDate  : 24/05/2023 11:48:38
        CertLocation : Cert:\LocalMachine\My
        Target       : auxiliary.ps1

      Directory: C:\Users\pedro\AppData\Local\Temp\auxiliary.ps1

      SignerCertificate                         Status                                            Path
      -----------------                         ------                                            ----
      EE350A485751736A3F8785D58E9CDD7CE9EC662D  Valid                                             auxiliary.ps1

      Thumbprint                                Subject
      ----------                                -------
      6DE90730783ADCA4796F537C203B8A4351C8295B  CN=LazySign-4zrH

      * Exit Invoke-LazySign cmdlet [ok]..
   #>

   #Local function variable declarations
   $Rand = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 4 |%{[char]$_})

   If(-not($bool))
   {
      write-host "  x " -ForegroundColor Red -NoNewline
      write-host "Error: '" -ForegroundColor DarkGray -NoNewline
      write-host "Administrator" -ForegroundColor Red -NoNewline
      write-host "' privileges required." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return
   }

   #Make sure all cmdlets required by this function are installed\loaded
   If([bool]((Get-Module -ListAvailable -Name "PKI").ExportedCmdlets|findstr /C:"New-SelfSignedCertificate") -iMatch '^(False)$')
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "error: cmdlet requires '" -ForegroundColor DarkGray -NoNewline
      write-host "New-SelfSignedCertificate" -ForegroundColor Red -NoNewline
      write-host "' Module.." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return     
   }

   If([bool]((Get-Module -ListAvailable -Name "Microsoft.PowerShell.Security").ExportedCommands|findstr /C:"Set-AuthenticodeSignature") -iMatch '^(False)$')
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "error: cmdlet requires '" -ForegroundColor DarkGray -NoNewline
      write-host "Set-AuthenticodeSignature" -ForegroundColor Red -NoNewline
      write-host "' Module.." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return     
   }

   If($Target -ieq "off" -or $Target -eq $null)
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "error: missing " -ForegroundColor DarkGray -NoNewline
      write-host "-Target `"C:\Desktop\payload.exe`"" -ForegroundColor Red -NoNewline
      write-host " argument." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return       
   }

   If(-not(Test-Path -Path "$Target"))
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Not Found: '" -ForegroundColor DarkGray -NoNewline
      write-host "$Target" -ForegroundColor Red -NoNewline
      write-host "'" -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return
   }


   #New Certificate Settings Display
   $ExpireTime = (Get-Date).AddMonths($NotAfter)
   $RandSubject = "$Subject" + "-" + "$Rand" -join ''
   write-host "`n  Certificate information" -ForegroundColor Green
   write-host "  -----------------------"
   write-host "  FriendlyName : $FriendlyName"
   write-host "  Subject      : $RandSubject" -ForegroundColor DarkYellow
   write-host "  ExprireDate  : $ExpireTime"
   write-host "  CertLocation : $StoreLocation"
   write-host "  Target       : $Target`n" -ForegroundColor DarkGray
   Start-Sleep -Seconds 1


   #Create the Self-Signed Certificate
   $Certificate = New-SelfSignedCertificate -Subject "$RandSubject" -FriendlyName "$FriendlyName" -NotAfter (Get-Date).AddMonths($NotAfter) -Type CodeSigningCert -CertStoreLocation $StoreLocation

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Move certificate from 'Cert:\LocalMachine\My'
      to 'Cert:\LocalMachine\Root' inside the windows store.

   .NOTES
      Administrator privileges required to move cert
   #>

   $TestExistence = (Get-ChildItem "$StoreLocation"|?{$_.Issuer -iMatch "$Subject" -or $_.Subject -iMatch "^(CN=$Subject)"}).Subject
   If($TestExistence)
   {
      write-host "  + " -ForegroundColor DarkYellow -NoNewline
      write-host "Moving certificate to: '" -ForegroundColor DarkGray -NoNewline
      write-host "Cert:\LocalMachine\Root" -ForegroundColor DarkYellow -NoNewline
      write-host "'" -ForegroundColor DarkGray

      #Move certificate to 'Cert:\LocalMachine\Root'
      Move-Item -Path $Certificate.PSPath -Destination "Cert:\LocalMachine\Root" -Force
   }


   ## Sign our Windows binary\cmdlet with a self-signed certificate
   Set-AuthenticodeSignature -Certificate $Certificate -Filepath "$Target" -Force


   #Display query store settings - 30a40d0a
   ForEach($SetLocation in $LocationsList)
   {
      Get-ChildItem $SetLocation | Where-Object {
         $_.Subject -iMatch "^(CN=$RandSubject)"
      }| Select-Object Thumbprint,Subject | Format-Table -AutoSize
   }

}


If($Action -ieq "del")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Delete certificates from Windows Store
      As a precaution it asks for comfirmation before deleting certs.

   .NOTES
      Warning: Administrator privileges required.
      Warning: This function uses recursive search.
      Warning: It requires strings bigger than 3 chars.
   #>

   write-host "  => Action: delete '$Subject' cert." -ForegroundColor DarkYellow
   #Make sure all dependencies are met
   If(-not($bool))
   {
      write-host "  x " -ForegroundColor Red -NoNewline
      write-host "Error: '" -ForegroundColor DarkGray -NoNewline
      write-host "Administrator" -ForegroundColor Red -NoNewline
      write-host "' privileges required." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return
   }

   If($Subject -Match '\[' -or $Subject.Length -lt 3)
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: '" -ForegroundColor DarkGray -NoNewline
      write-host "Regex search" -ForegroundColor Red -NoNewline
      write-host "' detected, aborting .." -ForegroundColor DarkGray
      write-host "  + Warning: This function uses recursive search." -ForegroundColor DarkYellow
      write-host "  + Warning: It requires strings bigger than 3 chars." -ForegroundColor DarkYellow

      write-host "`n* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return   
   }


   #Make sure certificate to delete exists
   ForEach($SetLocation in $LocationsList)
   {
      Get-ChildItem "$SetLocation" | Where-Object {
         $_.Issuer -iMatch "$Subject" -or $_.Subject -iMatch "^(CN=$Subject)"
      }| Select-Object FriendlyName,Subject,Issuer,PSParentPath,NotAfter,NotBefore |
      Out-String -Stream | Select-Object -SkipLast 2 | Format-List >> $Env:TMP\dave.log
   }

   If((Get-Content -Path "$Env:TMP\dave.log") -eq $null)
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: not found '" -ForegroundColor DarkGray -NoNewline
      write-host "$Subject" -ForegroundColor Red -NoNewline
      write-host "' certificate(s).`n" -ForegroundColor DarkGray

      write-host "* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return
   }

   #Output certificate information
   Get-Content -Path "$Env:TMP\dave.log"
   Remove-Item -Path "$Env:TMP\dave.log" -Force


   Write-Host "`n`n* Delete sellected certificates? [y|n]: " -ForegroundColor Red -NoNewline;
   $DelChoise = Read-Host;
   If($DelChoise -iMatch '^(y|yes)$')
   {
      ForEach($SetLocation in $LocationsList)
      {
          Get-ChildItem -Path "$SetLocation" | Where-Object {$_.Subject -iMatch "$Subject"} | Remove-Item
      }

      write-host "`n  + " -ForegroundColor DarkYellow -NoNewline
      write-host "Success: deleted '" -ForegroundColor DarkGray -NoNewline
      write-host "$Subject" -ForegroundColor DarkYellow -NoNewline
      write-host "' certificate(s).`n" -ForegroundColor DarkGray 
   }
}


#CmdLet Exit
write-host "* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
write-host "ok" -ForegroundColor DarkYellow -NoNewline
write-host "].." -ForegroundColor Green
