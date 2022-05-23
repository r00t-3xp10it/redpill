<#
.SYNOPSIS
   Sign a Windows binary with a self-signed certificate

   Author: @r00t-3xp10it (ssa redteam)
   AddaptedFrom: @JeanMaes {Invoke-LazySign}
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: PSVersion 3 {native?}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   This cmdlet allow users to sign windows binarys or scripts
   on windows certificate store without the need of admin privs.

.NOTES
   This cmdlet uses 'Cert:\CurrentUser\My' store to create certs

.Parameter Action
   Accepts arguments: query, sign (default: query)

.Parameter Target
   The Script\PE to sign (default: off)

.Parameter FriendlyName
   Certificate Friendly Name (default: SsaRedTeam)

.Parameter DomainName
   Certificate Domain Name (default: microsoft.com)       

.Parameter Subject
   Certificate subject name (default: LazySign)

.EXAMPLE
   PS C:\> .\Invoke-LazySign.ps1 -Action "query" -Subject "[a-z 0-9]"
   Query for ALL certificates in 'Cert:\CurrentUser\My' Windows Store

.EXAMPLE
   PS C:\> .\Invoke-LazySign.ps1 -Action "query" -Subject "LazySign"
   Query for ALL 'LazySign-????' certs in 'Cert:\CurrentUser\My' Store

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
      CertLocation : Cert:\CurrentUser\My
      Target       : C:\Users\pedro\AppData\Local\Temp\Payload.ps1
      Password     : Passw0rd!

   Thumbprint                                Subject
   ----------                                -------
   6DE90730783ADCA4796F537C203B8A4351C8295B  CN=LazySign-4zrH

   * Exit Invoke-LazySign cmdlet [ok]..

.LINK
   https://github.com/jfmaes/LazySign
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FriendlyName="SsaRedTeam",
   [string]$Domain="microsoft.com",
   [string]$Password="Passw0rd!",
   [string]$Subject="LazySign",
   [string]$Action="query",
   [string]$Target="off"
)


$CmdletVersion = "v1.0.1"
#Global variable declarations
$StoreLocation = "Cert:\CurrentUser\My"
# $ErrorActionPreference = "SilentlyContinue"
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


If($Action -ieq "query")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Query for certificate existance in store.

   .OUTPUTS
      * Manage Windows Store Certificates.
        + Store Location: Cert:\CurrentUser\My

      FriendlyName :
      Subject      : CN=30a40d0a-1b17-4ba5-bf56-999351b0b923
      Issuer       : DC=net + DC=windows + CN=MS-Organization-Access + OU=82dbaca4-3e81-46ca-9c73-0950c1eaca97
      PublicKey    : System.Security.Cryptography.X509Certificates.PublicKey
      PrivateKey   :
      NotAfter     : 21/06/2031 17:54:44
      NotBefore    : 21/06/2021 17:24:44

      * Exit Invoke-LazySign cmdlet [ok]..    
   #>

   write-host "  + " -ForegroundColor DarkYellow -NoNewline
   write-host "Store Location: " -ForegroundColor DarkGray -NoNewline
   write-host "$StoreLocation" -ForegroundColor DarkYellow

   #Query certlm.msc for certificate existance - 30a40d0a
   $checkMe = Get-ChildItem $StoreLocation | Where-Object {
      $_.Issuer -iMatch "$Subject" -or $_.Subject -iMatch "^(CN=$Subject)"
   }| Select-Object FriendlyName,Subject,Issuer,PublicKey,PrivateKey,NotAfter,NotBefore |
   Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 2 | Format-List

   If(-not($checkMe) -or $checkMe -eq $null)
   {
      write-host "`n  x Error: none certificates found that match criteria.`n" -ForegroundColor Red -BackgroundColor Black
      write-host "* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return
   }

   #Output cert info
   echo $checkMe
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
      This function uses 'Cert:\CurrentUser\My' store to create certs

   .OUTPUTS
      * Manage Windows Store Certificates.

        Certificate information
        -----------------------
        FriendlyName : SsaRedTeam
        DomainName   : microsoft.com
        Subject      : LazySign-4zrH
        CertLocation : Cert:\CurrentUser\My
        Target       : auxiliary.ps1
        Password     : Passw0rd!

      Thumbprint                                Subject
      ----------                                -------
      6DE90730783ADCA4796F537C203B8A4351C8295B  CN=LazySign-4zrH

      * Exit Invoke-LazySign cmdlet [ok]..
   #>

   #Local function variable declarations
   $SupportedVersion = ($PSversionTable).PSVersion.Major
   $CertPath = $(Join-Path (Get-Location) "$Domain.pfx")
   $Rand = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 4 |%{[char]$_})
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
   $RandSubject = "$Subject" + "-" + "$Rand" -join ''
   write-host "`n  Certificate information" -ForegroundColor Green
   write-host "  -----------------------"
   write-host "  FriendlyName : $FriendlyName"
   write-host "  DomainName   : $Domain"
   write-host "  Subject      : $RandSubject" -ForegroundColor DarkYellow
   write-host "  CertLocation : $StoreLocation"
   write-host "  Target       : $Target" -ForegroundColor DarkGray
   write-host "  Password     : $Password`n"
   Start-Sleep -Seconds 1


   #Create Self Signed Certificate and PFX file in current directory
   $Certificate = New-SelfSignedCertificate -Subject "$RandSubject" -FriendlyName "$FriendlyName" -CertStoreLocation "$StoreLocation" -DnsName "$Domain" -Type "CodeSigning" -ErrorAction SilentlyContinue  
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

   #Sign our Windows binary\cmdlet with a self-signed certificate
   Set-AuthenticodeSignature -Certificate "$Certificate" -Filepath "$Target" –TimestampServer "http://timestamp.comodoca.com/authenticode"
   If(Test-Path -Path "$CertPath"){Remove-Item -Path "$CertPath" -Force}

   #Display query store settings - 30a40d0a
   Get-ChildItem $StoreLocation | Where-Object {
      $_.Issuer -iMatch "$Subject" -or $_.Subject -iMatch "^(CN=$Subject)"
   }| Select-Object Thumbprint,Subject | Format-Table -AutoSize

}

#CmdLet Exit
write-host "* Exit Invoke-LazySign cmdlet [" -ForegroundColor Green -NoNewline
write-host "ok" -ForegroundColor DarkYellow -NoNewline
write-host "].." -ForegroundColor Green
