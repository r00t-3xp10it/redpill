<#
.SYNOPSIS
   Sign a Windows binary with a self-signed certificate

   Author: @r00t-3xp10it (ssa redteam)
   AddaptedFrom: @JeanMaes {Invoke-LazySign}
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: PSVersion 3 {native?}
   Optional Dependencies: Administrator privs
   PS cmdlet Dev version: v1.0.5

.DESCRIPTION
   This cmdlet allow users to sign windows binarys or scripts
   on windows certificate store without the need of admin privs.
   This action allow us to exec cmdlets later, even if powershell
   ExecutionPolicy its set to 'AllSigned,RemoteSigned' restrictions

.NOTES
   This cmdlet uses 'Cert:\CurrentUser\My' store to create certs,
   Unless cmdlet its executed with administrator privileges. In that
   ocassion it exports the certificate to 'Cert:\LocalMachine\Root'.
   Invoking -NotAfter '8' will maintain the fake cert in store for
   the 8 months, and auto-delete it self after limmit time reached.

.Parameter Action
   Accepts arguments: query, sign (default: query)

.Parameter Target
   The Windows binary\Cmdlet to sign (default: off)

.Parameter FriendlyName
   Certificate Friendly Name (default: SsaRedTeam)

.Parameter DomainName
   Certificate Domain Name (default: microsoft.com)       

.Parameter Subject
   Certificate subject name (default: LazySign)

.Parameter NotAfter
   Auto-Delete cert after [?]months (default: 1)

.Parameter Password
   Certificate password (default: Passw0rd!)

.EXAMPLE
   PS C:\> .\Invoke-LazySign.ps1 -Action "query" -Subject "[a-z 0-9]"
   Query for ALL certificates in 'Cert:\CurrentUser\My | Root' Store

.EXAMPLE
   PS C:\> .\Invoke-LazySign.ps1 -Action "query" -Subject "LazySign"
   Query for ALL 'LazySign' certs in 'Cert:\CurrentUser\My | Root' Store

.EXAMPLE
   PS C:\> .\Invoke-LazySign.ps1 -Subject "LazySign" -Target "$pwd\Payload.exe" -Domain "microsoft.com"
   Sign binary (Payload.exe) with crafted certificate (Subject: LazySign-4zrH Domain: microsoft.com)

.EXAMPLE
   PS C:\> .\Invoke-LazySign.ps1 -Subject "LazySignCN" -Target "Payload.exe" -Domain "microsoft.com" -Password "Passw0rd!"
   Sign binary (Payload.exe) with crafted certificate (Subject: LazySign-4zrH Domain: microsoft.com password: Passw0rd!)

.OUTPUTS
   * Manage Windows Store Certificates.

      Certificate information
      -----------------------
      FriendlyName : SsaRedTeam
      DomainName   : microsoft.com
      Subject      : LazySign-4zrH
      ExprireDate  : 24/05/2023 11:48:38
      CertLocation : Cert:\CurrentUser\My
      Target       : C:\Users\pedro\AppData\Local\Temp\Payload.ps1
      Password     : Passw0rd!

   Thumbprint                                Subject
   ----------                                -------
   6DE90730783ADCA4796F537C203B8A4351C8295B  CN=LazySign-4zrH

   * Exit Invoke-LazySign cmdlet [ok]..

.LINK
   https://github.com/jfmaes/LazySign
   http://woshub.com/how-to-create-self-signed-certificate-with-powershell
   https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/working-with-certificates.md
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FriendlyName="SsaRedTeam",
   [string]$Domain="microsoft.com",
   [string]$Password="Passw0rd!",
   [string]$Subject="LazySign",
   [string]$Action="query",
   [string]$Target="off",
   [int]$NotAfter='1'
)


$CmdletVersion = "v1.0.5"
#Global variable declarations
$StoreLocation = "Cert:\CurrentUser\My"
$ErrorActionPreference = "SilentlyContinue"

#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@Invoke-LazySign $CmdletVersion {SSA@RedTeam}"
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
     + Store Location: Cert:\CurrentUser\My
     + Store Location: Cert:\LocalMachine\Root

   FriendlyName : Sectigo (AddTrust)
   Subject      : CN=AddTrust External CA Root, OU=AddTrust External TTP Network, O=AddTrust AB, C=SE
   Issuer       : CN=AddTrust External CA Root, OU=AddTrust External TTP Network, O=AddTrust AB, C=SE
   PSParentPath : Microsoft.PowerShell.Security\Certificate::LocalMachine\Root
   PublicKey    : System.Security.Cryptography.X509Certificates.PublicKey
   NotAfter     : 30/05/2020 11:48:38
   NotBefore    : 30/05/2000 11:48:38

   * Exit Invoke-LazySign cmdlet [ok]..   
   #>

   #Local function variable declarations
   write-host "  + " -ForegroundColor DarkYellow -NoNewline
   write-host "Store Location: " -ForegroundColor DarkGray -NoNewline
   write-host "$StoreLocation" -ForegroundColor DarkYellow
   write-host "  + " -ForegroundColor DarkYellow -NoNewline
   write-host "Store Location: " -ForegroundColor DarkGray -NoNewline
   write-host "Cert:\LocalMachine\Root" -ForegroundColor DarkYellow

   ForEach($SetLocation in $LocationsList)
   {
      ## Query certlm.msc for certificate existance
      # DebugString: Cert:\CurrentUser\My - 30a40d0a
      Get-ChildItem "$SetLocation" | Where-Object {
         $_.Issuer -iMatch "$Subject" -or $_.Subject -iMatch "^(CN=$Subject)"
      }| Select-Object FriendlyName,Subject,Issuer,PSParentPath,PublicKey,NotAfter,NotBefore |
      Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 2 | Format-List >> $Env:TMP\dave.log
   }

   If((Get-Content -Path "$Env:TMP\dave.log") -eq $null)
   {
      Remove-Item -Path "$Env:TMP\dave.log" -Force
      write-host "`n  x Error: none '$Subject' certificates found..`n" -ForegroundColor Red -BackgroundColor Black
      write-host "* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
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
      AddaptedFrom: @JeanMaes {Invoke-LazySign}
      Helper - Sign a Windows binary\script with a self-signed cert.

   .NOTES
      This function requires 'PSVersion 3' or bigger ..
      This function uses 'Cert:\CurrentUser\My' store to create certs,
      Unless cmdlet its executed with administrator privileges. In that
      ocassion it exports the certificate to 'Cert:\LocalMachine\Root'.

   .OUTPUTS
      * Manage Windows Store Certificates.

        Certificate information
        -----------------------
        FriendlyName : SsaRedTeam
        DomainName   : microsoft.com
        Subject      : LazySign-4zrH
        ExprireDate  : 24/05/2023 11:48:38
        CertLocation : Cert:\CurrentUser\My
        Target       : auxiliary.ps1
        Password     : Passw0rd!

      Thumbprint                                Subject
      ----------                                -------
      6DE90730783ADCA4796F537C203B8A4351C8295B  CN=LazySign-4zrH

      * Exit Invoke-LazySign cmdlet [ok]..
   #>

   #Local function variable declarations
   $CertPath = $(Join-Path (Get-Location) "$Domain.pfx")
   $SupportedVersion = ($PSversionTable).PSVersion.Major
   $Rand = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 4 |%{[char]$_})
   $bool = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
   $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force -ErrorAction SilentlyContinue

   If($SupportedVersion -lt 3)
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "error: cmdlet requires '" -ForegroundColor DarkGray -NoNewline
      write-host "PSVersion 3" -ForegroundColor Red -NoNewline
      write-host "' or bigger.." -ForegroundColor DarkGray

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
   write-host "  DomainName   : $Domain"
   write-host "  Subject      : $RandSubject" -ForegroundColor DarkYellow
   write-host "  ExprireDate  : $ExpireTime"
   write-host "  CertLocation : $StoreLocation"
   write-host "  Target       : $Target" -ForegroundColor DarkGray
   write-host "  Password     : $Password`n"
   Start-Sleep -Seconds 1


   #Create Self Signed Certificate and PFX file in current directory
   $Certificate = New-SelfSignedCertificate -Subject "$RandSubject" -FriendlyName "$FriendlyName" -CertStoreLocation "$StoreLocation" -DnsName "$Domain" -NotAfter (Get-Date).AddMonths($NotAfter) -Type "CodeSigning" -ErrorAction SilentlyContinue 
   Export-PfxCertificate -FilePath "$CertPath" -Password "$SecurePassword" -Cert "$Certificate" -ErrorAction SilentlyContinue

   If(-not(Test-Path -Path "$CertPath"))
   {
       write-host "`n   x " -ForegroundColor Red -NoNewline
       write-host "PfxCertificate Creation Failed." -ForegroundColor DarkGray

       write-host "`n* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
       write-host "ok" -ForegroundColor DarkYellow -NoNewline
       write-host "].." -ForegroundColor Green
       return
   }

   If($bool)
   {
      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Move certificate to 'Cert:\LocalMachine\Root'

      .NOTES
         Administrator privileges required to move cert
      #>

      $TestExistence = (Get-ChildItem "Cert:\CurrentUser\My"|?{$_.Issuer -iMatch "$Subject" -or $_.Subject -iMatch "^(CN=$Subject)"}).Subject
      If($TestExistence)
      {
         write-host "   + " -ForegroundColor DarkYellow -NoNewline
         write-host "Moving certificate to '" -ForegroundColor DarkGray -NoNewline
         write-host "Cert:\LocalMachine\Root" -ForegroundColor DarkYellow -NoNewline
         write-host "'" -ForegroundColor DarkGray

         #Move certificate
         Move-Item -Path $Certificate.PSPath -Destination "Cert:\LocalMachine\Root" -Force
      }
   }


   ## Sign our Windows binary\cmdlet with a self-signed certificate
   # needed? : –TimestampServer "http://timestamp.comodoca.com/authenticode" -Force
   Set-AuthenticodeSignature -Certificate "$Certificate" -Filepath "$Target" -Force
   If(Test-Path -Path "$CertPath"){Remove-Item -Path "$CertPath" -Force}


   #Display query store settings - 30a40d0a
   ForEach($SetLocation in $LocationsList)
   {
      Get-ChildItem $SetLocation | Where-Object {
         $_.Subject -iMatch "^(CN=$RandSubject)"
      }| Select-Object Thumbprint,Subject | Format-Table -AutoSize
   }

}

#CmdLet Exit
write-host "* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
write-host "ok" -ForegroundColor DarkYellow -NoNewline
write-host "].." -ForegroundColor Green
