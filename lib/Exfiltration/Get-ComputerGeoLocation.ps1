<#
.SYNOPSIS
   Retrieves the Computer's geographical location

   Author: @r00t-3xp10it
   Addapted from: @colsw {stackoverflow}
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Device.Location.GeoCoordinateWatcher
   Optional Dependencies: Curl\ipapi.co {native}
   PS cmdlet Dev version: v1.1.4

.DESCRIPTION
   Retrieves the Computer Geolocation using 'GeoCoordinateWatcher' Or
   'curl\ipapi.co' API (aprox location) if the 'GeoCoordinateWatcher'
   API fails to retrieve the coordinates from host device. (default)

.NOTES
   GeoCoordinateWatcher API does not require administrator privileges
   to resolve address. But its required if cmdlet needs to create the
   comrrespondent registry hive\keys that 'allow' GeoLocation on host.

.Parameter Api
   The API (default: GeoCoordinateWatcher)

.Parameter PublicAddr
   Display public ip addr? (default: true)

.EXAMPLE
   PS C:\> .\Get-ComputerGeolocation.ps1
   Get the Computer's geographical location

.EXAMPLE
   PS C:\> .\Get-ComputerGeolocation.ps1 -Api 'curl'
   Get the Computer's geographical location (curl\ipapi.co API)

.EXAMPLE
   PS C:\> .\Get-ComputerGeolocation.ps1 -Api 'curl' -PublicAddr 'false'
   Get the Computer's geographical location (API:curl + hidde public ip)

.INPUTS
   None. You cannot pipe objects into Get-ComputerGeoLocation.ps1

.OUTPUTS
   * Resolving 'SKYNET' Geo Location.
   * Win32API: 'GeoCoordinateWatcher'
   * TimeStamp '14:junho:2022'
                                                                                                                                                                                                                                                Altitude         Latitude         Longitude                                                                             --------         --------         ---------                                                                                    0 38,7133088132117 -9,13080657585403
   HostName Altitude Latitude         Longitude
   -------- -------- --------         ---------
   SKYNET          0 38,7133088132117 -9,13080657585403

   * Uri: https://www.google.com/maps/dir/@38.7133088132117,-9.13080657585403

.LINK
   https://stackoverflow.com/questions/46287792/powershell-getting-gps-coordinates-in-windows-10-using-windows-location-api
#>


#Global cmdlet parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Api="GeoCoordinateWatcher",
   [string]$PublicAddr="true"
)


$CmdletVersion = "v1.1.4"
$TimeStamp = (Date -Format 'dd:MMMM:yyyy')
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@Get-ComputerGeoLocation $CmdletVersion"

write-host "`n* " -ForegroundColor Green -NoNewline
write-host "Resolving '" -ForegroundColor DarkGray -NoNewline
write-host "$Env:COMPUTERNAME" -ForegroundColor Green -NoNewline
write-host "' Geo Location." -ForegroundColor DarkGray
Start-Sleep -Seconds 1


IF($Api -ieq "curl")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Force Geo Location [curl\ipappi.co]

   .OUTPUTS
      * Resolving 'SKYNET' Geo Location.
      * Win32API: 'curl\ipapi.co(aprox)'
      * TimeStamp '14:junho:2022'

      PublicIP    city    region country  capital latitude longitude
      --------    ----    ------ -------  ------- -------- ---------
      8.235.13.07 Amadora Lisbon Portugal Lisbon  38.752   -9.2279

      * Uri: https://www.google.com/maps/dir/@38.752,-9.2279,15z
   #>

   write-host "* " -ForegroundColor Green -NoNewline
   write-host "Win32API: '" -ForegroundColor DarkGray -NoNewline
   write-host "curl\ipapi.co" -ForegroundColor Yellow -NoNewline
   write-host "(aprox)'" -ForegroundColor DarkGray

   write-host "* " -ForegroundColor Green -NoNewline
   write-host "TimeStamp '" -ForegroundColor DarkGray -NoNewline
   write-host "$TimeStamp" -ForegroundColor DarkYellow -NoNewline
   write-host "'`n`n" -ForegroundColor DarkGray -NoNewline

   #Download\Execute cmdlet from GitHub
   iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GeoLocation.ps1" -OutFile "$Env:TMP\GeoLocation.ps1"|Unblock-File

   If($PublicAddr -ieq "false")
   {
      powershell -File "$Env:TMP\GeoLocation.ps1" -HiddeMyAss 'true'
   }
   Else
   {
      powershell -File "$Env:TMP\GeoLocation.ps1"
   }

   #cleanUp
   Remove-Item -Path "$Env:TMP\GeoLocation.ps1" -Force
   write-host ""
   exit
}


$IsAdmin = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"

Add-Type -AssemblyName System.Device #Required to access System.Device.Location namespace
$GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher #Create the required object
$GeoWatcher.Start() #Begin resolving current locaton
While(($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied'))
{
    Start-Sleep -Milliseconds 100 #Wait for discovery.
}


If($GeoWatcher.Permission -eq 'Denied')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Retrieve Geo Location [curl\ipappi.co]

   .OUTPUTS
      * Resolving 'SKYNET' Geo Location.
      x Error: Access Denied  : 'GeoCoordinateWatcher' API
      + Resolving GeoLocation : 'curl\ipapi.co(aprox)' API
      * TimeStamp             : '14:junho:2022'

      PublicIP    city    region country  capital latitude longitude
      --------    ----    ------ -------  ------- -------- ---------
      8.235.13.07 Amadora Lisbon Portugal Lisbon  38.752   -9.2279

      * Uri: https://www.google.com/maps/dir/@38.752,-9.2279,15z
   #>

   Write-host "x Error: " -ForegroundColor Red -NoNewline
   write-host "Access Denied  : '" -ForegroundColor DarkGray -NoNewline
   write-host "GeoCoordinateWatcher" -ForegroundColor Red -NoNewline
   write-host "' API" -ForegroundColor DarkGray
   Start-Sleep -Seconds 1

   write-host "+ " -ForegroundColor Yellow -NoNewline
   write-host "Resolving GeoLocation : '" -ForegroundColor DarkGray -NoNewline
   write-host "curl\ipapi.co" -ForegroundColor Yellow -NoNewline
   write-host "(aprox)' API" -ForegroundColor DarkGray

   write-host "* " -ForegroundColor Green -NoNewline
   write-host "TimeStamp             : '" -ForegroundColor DarkGray -NoNewline
   write-host "$TimeStamp" -ForegroundColor DarkYellow -NoNewline
   write-host "'`n`n" -ForegroundColor DarkGray -NoNewline

   #Download\Execute cmdlet from GitHub
   iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GeoLocation.ps1" -OutFile "$Env:TMP\GeoLocation.ps1"|Unblock-File

   If($PublicAddr -ieq "false")
   {
      powershell -File "$Env:TMP\GeoLocation.ps1" -HiddeMyAss 'true'
   }
   Else
   {
      powershell -File "$Env:TMP\GeoLocation.ps1"
   }
   
   #cleanUp
   Remove-Item -Path "$Env:TMP\GeoLocation.ps1" -Force
   write-host ""  

}
Else
{

   <#
   .SYNOPSIS
      Author: @colsw
      Helper - Retrieve Geo Location [GeoCoordinateWatcher]

   .OUTPUTS
      * Resolving 'SKYNET' Geo Location.
      * Win32API: 'GeoCoordinateWatcher'
      * TimeStamp '14:junho:2022'
                                                                                                                                                                                                                                                Altitude         Latitude         Longitude                                                                             --------         --------         ---------                                                                                    0 38,7133088132117 -9,13080657585403
      HostName Altitude Latitude         Longitude
      -------- -------- --------         ---------
      SKYNET          0 38,7133088132117 -9,13080657585403

      * Uri: https://www.google.com/maps/dir/@38.7133088132117,-9.13080657585403
   #>   

   #Tests
   If(-not(Test-Path -Path "$RegistryPath"))
   {
      If(-not($IsAdmin))
      {
         write-host "x " -ForegroundColor Red -NoNewline
         write-host "Error: " -ForegroundColor DarkGray -NoNewline
         write-host "Admin privs required to create hive ..`n" -ForegroundColor Red
         exit
      }

      #Create new registry hive
      New-Item -Path "$RegistryPath" -Force|Out-Null
   }

   If((Get-ItemProperty -Path "$RegistryPath").Value -iNotMatch 'allow')
   {
      If(-not($IsAdmin))
      {
         write-host "x " -ForegroundColor Red -NoNewline
         write-host "Error: " -ForegroundColor DarkGray -NoNewline
         write-host "Admin privs required to create key ..`n" -ForegroundColor Red
         exit
      }

      #Modify registry key
      New-ItemProperty -Path "$RegistryPath" -Name "value" -Value "allow" -PropertyType "String" -Force|Out-Null
      Start-Sleep -Seconds 1 #Give extra time for registry refresh
   }


   write-host "* " -ForegroundColor Green -NoNewline
   write-host "Win32API: '" -ForegroundColor DarkGray -NoNewline
   write-host "GeoCoordinateWatcher" -ForegroundColor DarkYellow -NoNewline
   write-host "'" -ForegroundColor DarkGray

   write-host "* " -ForegroundColor Green -NoNewline
   write-host "TimeStamp '" -ForegroundColor DarkGray -NoNewline
   write-host "$TimeStamp" -ForegroundColor DarkYellow -NoNewline
   write-host "'`n" -ForegroundColor DarkGray

   $Lati = ($GeoWatcher.Position.Location).Latitude
   $Long = ($GeoWatcher.Position.Location).Longitude
   $GeoWatcher.Position.Location | Select-Object @{Name='HostName';Expression={"$Env:COMPUTERNAME"}},Altitude,Latitude,Longitude | Format-Table -AutoSize

   write-host "* Uri: " -ForegroundColor Blue -NoNewline
   write-host "https://www.google.com/maps/dir/@$Lati,$Long`n" -ForegroundColor Green
}

$GeoWatcher.Stop()
