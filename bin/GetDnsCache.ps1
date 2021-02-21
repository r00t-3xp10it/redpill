<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Enumerate remote host DNS cache entrys
      
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
   Entry                           Data
   -----                           ----
   example.org                     93.184.216.34
   play.google.com                 216.239.38.10
   www.facebook.com                129.134.30.11
   safebrowsing.googleapis.com     172.217.21.10
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$GetDnsCache="false"
)


Write-Host ""
If($GetDnsCache -ieq "Enum" -or $GetDnsCache -ieq "Clear"){
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

    If($GetDnsCache -ieq "Enum"){## Enum dns cache
        Get-DNSClientCache|Select-Object Entry,Data|Format-Table -AutoSize > $Env:TMP\fsdgss.log
        $CheckReport = Get-Content -Path "$Env:TMP\fsdgss.log" -ErrorAction SilentlyContinue
        If($CheckReport -ieq $null){## Command fail to retrieve dns cache info
            Write-Host "[error] None DNS entrys found in $Remote_hostName\$Env:USERNAME!" -ForegroundColor Red -BackgroundColor Black
            Remove-Item -Path $Env:TMP\fsdgss.log -Force
        }Else{## Dns Cache entrys found
           Get-Content -Path $Env:TMP\fsdgss.log
           Remove-Item -Path $Env:TMP\fsdgss.log -Force   
        }
    }ElseIf($GetDnsCache -ieq "Clear"){## Clear dns cache
        ipconfig /flushdns
    }
    Write-Host "";Start-Sleep -Seconds 1
}