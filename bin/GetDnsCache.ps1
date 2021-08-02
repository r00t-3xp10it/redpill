<#
.SYNOPSIS
   Enumerate remote host DNS cache entrys

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.2

.DESCRIPTION
   Module to enumerate dns entrys or to clear dns cache

.Parameter GetDnsCache
   Accepts arguments: Enum, Clear (default: Enum)
      
.EXAMPLE
   PS C:\> Get-Help .\GetDnsCache.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetDnsCache.ps1 -GetDnsCache Enum
   Enumerate remote host DNS cache entrys

.EXAMPLE
   PS C:\> .\GetDnsCache.ps1 -GetDnsCache Clear
   Clear Dns Cache entrys {delete entrys}

.OUTPUTS
   TTL Entry              Name                         Data                              
   --- -----              ----                         ----                              
   158 www.gstatic.com    www.gstatic.com              142.250.184.163                   
   158 www.gstatic.com    ns2.google.com               216.239.34.10
   13  www.facebook.com   www.facebook.com             star-mini.c10r.facebook.com       
   13  www.facebook.com   star-mini.c10r.facebook.com  69.171.250.35                     
   13  www.facebook.com   d.ns.c10r.facebook.com       185.89.219.11
   56  www.messenger.com  a.ns.c10r.facebook.com       129.134.30.11
   225 www.youtube.com    ns1.google.com               2001:4860:4802:32::a    
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$GetDnsCache="false"
)


Write-Host ""
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$mydate = Get-Date -format "dd-MMM-yyyy HH:mm"


If($GetDnsCache -ieq "Enum")
{

   <#
   .SYNOPSIS
      Helper - Enum dns cache entrys!
   #>

   Write-Host "[i] Enumerating $Env:COMPUTERNAME DNS cache [$mydate]" -ForegroundColor Green
   Get-DNSClientCache | Select-Object TTL,Entry,Name,Data | Format-Table -AutoSize > $Env:TMP\fsdgss.log

   $CheckReport = Get-Content -Path "$Env:TMP\fsdgss.log"
   If($CheckReport -ieq $null)
   {
      ## Command fail to retrieve dns cache info
      Write-Host "[error] None DNS entrys found in $Env:COMPUTERNAME\$Env:USERNAME system!" -ForegroundColor Red -BackgroundColor Black
      Remove-Item -Path $Env:TMP\fsdgss.log -Force
   }
   Else
   {
      ## Dns Cache entrys found
      Get-Content -Path $Env:TMP\fsdgss.log
      Remove-Item -Path $Env:TMP\fsdgss.log -Force   
   }

}


If($GetDnsCache -ieq "Clear")
{

   <#
   .SYNOPSIS
      Helper - Clear dns cache entrys!
   #>

   ipconfig /flushdns

}