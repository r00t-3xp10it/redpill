<#
.SYNOPSIS
   Enumerates installed anti-virus information

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.3

.DESCRIPTION
   AntiVirusDefinitions, AntiSpywearDefinitions, Etc..

.EXAMPLE
   PS C:\> Get-Help .\Get-AVStatus.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\Get-AVStatus.ps1
   Enum installed anti-virus info

.OUTPUTS
   AntiVirus Name             : Windows Defender
   Product Executable         : windowsdefender://
   Product GUID               : {D68DDC3A-831F-4fae-9E44-DA132C1ACF46}
   Executable Path            : %ProgramFiles%\Windows Defender\MsMpeng.exe
   Product Version            : 4.18.2111.5
   ScanScheduleTime           : 02:00:00
   SignatureScheduleTime      : 01:45:00
   DisableScriptScanning      : False
   BehaviorMonitorEnabled     : True
   RealTimeProtectionEnabled  : True
   DisableScanningNetworkFiles: False
   PSConstrainedLanguageMode  : FullLanguage
#>


#Local variable declarations
$computername = $env:computername
$AntiVirusProducts = Get-WmiObject -Namespace "root\SecurityCenter2" -Class AntiVirusProduct  -ComputerName $computername
ForEach($AntiVirusProduct in $AntiVirusProducts)
{
   #Switch to determine the status of antivirus definitions and real-time protection.
   #The values in this switch-statement are retrieved from the following website:
   #http://community.kaseya.com/resources/m/knowexch/1020.aspx
   switch ($AntiVirusProduct.productState)
   {
      "262144" {$defstatus = "Up to date" ;$rtstatus = "Disabled"}
      "262160" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}
      "266240" {$defstatus = "Up to date" ;$rtstatus = "Enabled"}
      "266256" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}
      "393216" {$defstatus = "Up to date" ;$rtstatus = "Disabled"}
      "393232" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}
      "393488" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}
      "397312" {$defstatus = "Up to date" ;$rtstatus = "Enabled"}
      "397328" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}
      "397584" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}
       default {$defstatus = "Unknown" ;$rtstatus = "Unknown"}
   }

   #Build Table Output
   Write-Host "AntiVirus Name             :"$AntiVirusProduct.displayName -ForegroundColor Green
   Write-Host "Product Executable         :"$AntiVirusProduct.pathToSignedProductExe
   Write-Host "Product GUID               :"$AntiVirusProduct.instanceGuid
   Write-Host "Executable Path            :"$AntiVirusProduct.pathToSignedReportingExe -ForegroundColor Yellow

   If($AntiVirusProduct.displayName -iMatch '^(Windows Defender)$')
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Windows Defender extra information.
      #>

      $AMProductVersion = (Get-MpComputerStatus).AMProductVersion
      $DisableScriptScanning = (Get-MpPreference).DisableScriptScanning
      $ScanScheduleTime = (Get-MpPreference).ScanScheduleTime.ToString()
      $ConstrainedLanguageMode = $ExecutionContext.SessionState.LanguageMode
      $BehaviorMonitorEnabled = (Get-MpComputerStatus).BehaviorMonitorEnabled
      $SignatureScheduleTime = (Get-MpPreference).SignatureScheduleTime.ToString()
      $RealTimeProtectionEnabled = (Get-MpComputerStatus).RealTimeProtectionEnabled
      $DisableScanningNetworkFiles = (Get-MpPreference).DisableScanningNetworkFiles

      Write-Host "Product Version            : $AMProductVersion"
      Write-Host "ScanScheduleTime           : $ScanScheduleTime"
      Write-Host "SignatureScheduleTime      : $SignatureScheduleTime"
      Write-Host "DisableScriptScanning      : $DisableScriptScanning"
      Write-Host "BehaviorMonitorEnabled     : $BehaviorMonitorEnabled"
      Write-Host "RealTimeProtectionEnabled  : $RealTimeProtectionEnabled"
      Write-Host "DisableScanningNetworkFiles: $DisableScanningNetworkFiles"
      Write-Host "PSConstrainedLanguageMode  : $ConstrainedLanguageMode"

   }
   Else
   {
      Write-Host "Definition Status          : $defstatus"
      Write-Host "Real-time Protection       : $rtstatus"
   }
}