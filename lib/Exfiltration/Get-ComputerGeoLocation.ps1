<#
.SYNOPSIS
   Retrieves the Computer's geographical location

   Author: @r00t-3xp10it
   Addapted from: @colsw {stackoverflow}
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Device.Location.GeoCoordinateWatcher
   Optional Dependencies: Curl\ipapi.co, Invoke-RestMethod {native}
   PS cmdlet Dev version: v1.1.8

.DESCRIPTION
   Retrieves the Computer Geolocation using 'GeoCoordinateWatcher' Or
   'curl\ipapi.co' API (aprox location) if the 'GeoCoordinateWatcher'
   API fails to retrieve the coordinates from host device. (default)

.NOTES
   GeoCoordinateWatcher API does not require administrator privileges
   to resolve address. But its required if cmdlet needs to create the
   comrrespondent registry hive\keys that 'allow' GeoLocation on host.

   Alternatively -api 'curl' Or -api 'ifconfig' API's can be invoked
   to resolve address location without the need of admin privileges.

.Parameter Api
   accepts arguments: GeoCoordinateWatcher, curl, ifconfig
   The default API to use (default: GeoCoordinateWatcher)

.Parameter PublicAddr
   Display public ip addr? (default: true)

.EXAMPLE
   PS C:\> .\Get-ComputerGeolocation.ps1
   Get the Computer's geographical location
   Remark: GeoCoordinateWatcher or Curl API's

.EXAMPLE
   PS C:\> .\Get-ComputerGeolocation.ps1 -Api 'ifconfig'
   Get the Computer's geographical location (API: ifconfig.me)

.EXAMPLE
   PS C:\> .\Get-ComputerGeolocation.ps1 -Api 'curl'
   Get the Computer's geographical location (API: curl\ipapi.co)

.EXAMPLE
   PS C:\> .\Get-ComputerGeolocation.ps1 -Api 'curl' -PublicAddr 'false'
   Get the Computer's geographical location (API:curl\ipapi.co + hidde public ip)

.INPUTS
   None. You cannot pipe objects into Get-ComputerGeoLocation.ps1

.OUTPUTS
   * Resolving 'SKYNET' Geo Location.
   * Win32API: 'GeoCoordinateWatcher'
   * TimeStamp '14/junho/2022'
                                                                                                                                                                                                                                                Altitude         Latitude         Longitude                                                                             --------         --------         ---------                                                                                    0 38,7133088132117 -9,13080657585403
   HostName Country          Latitude         Longitude
   -------- -------          --------         ---------
   SKYNET   Portugal 38,7130834464767 -9,13077362163375

   * Uri: https://www.google.com/maps/dir/@38.7133088132117,-9.13080657585403

.LINK
   https://docs.microsoft.com/en-us/powershell/module/international/get-winhomelocation
   https://stackoverflow.com/questions/46287792/powershell-getting-gps-coordinates-in-windows-10-using-windows-location-api
#>


#Global cmdlet parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Api="GeoCoordinateWatcher",
   [string]$PublicAddr="true"
)


$CmdletVersion = "v1.1.8"
$TimeStamp = (Date -Format 'dd/MMMM/yyyy')
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@Get-ComputerGeoLocation $CmdletVersion"

write-host "`n* " -ForegroundColor Green -NoNewline
write-host "Resolving '" -ForegroundColor DarkGray -NoNewline
write-host "$Env:COMPUTERNAME" -ForegroundColor Green -NoNewline
write-host "' Geo Location." -ForegroundColor DarkGray
Start-Sleep -Seconds 1


If($Api -ieq "curl")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Retrieve Geo Location [curl\ipappi.co]

   .OUTPUTS
      * Resolving 'SKYNET' Geo Location.
      * Win32API: 'curl\ipapi.co(aprox)'
      * TimeStamp '14/junho/2022'

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
   write-host "'`n" -ForegroundColor DarkGray

   #Download\Execute cmdlet from GitHub
   iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GeoLocation.ps1" -OutFile "GeoLocation.ps1"|Unblock-File

   If($PublicAddr -ieq "false")
   {
      ## My wife PC does not show Table correctly
      # when invoking powershell with -file argument
      .\GeoLocation.ps1 -HiddeMyAss 'true'
   }
   Else
   {
      .\GeoLocation.ps1
   }

   #CleanUp
   Remove-Item -Path "GeoLocation.ps1" -Force
   write-host ""
   exit
}


IF($Api -ieq "ifconfig")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Retrieve Geo Location [ifconfig.me]

   .OUTPUTS
      * Resolving 'SKYNET' Geo Location.
      * Win32API: 'ifconfig.me (aprox)'
      * TimeStamp '14/junho/2022'

      ip       : 8.235.13.07
      loc      : 38.7167,-9.1333
      country  : PT
      city     : Lisbon
      postal   : 1000-001
      timezone : Europe/Lisbon
      hostname : 8.235.13.07.rev.vodafone.pt
      org      : AS14358 Vodafone Portugal - Communicacoes Pessoais S.A.

      * Uri: https://www.google.com/maps/dir/@38.7167,-9.1333
   #>

   write-host "* " -ForegroundColor Green -NoNewline
   write-host "Win32API: '" -ForegroundColor DarkGray -NoNewline
   write-host "ifconfig.me " -ForegroundColor Yellow -NoNewline
   write-host "(aprox)'" -ForegroundColor DarkGray

   write-host "* " -ForegroundColor Green -NoNewline
   write-host "TimeStamp '" -ForegroundColor DarkGray -NoNewline
   write-host "$TimeStamp" -ForegroundColor DarkYellow -NoNewline
   write-host "'" -ForegroundColor DarkGray

   $GeoDateLoc = (Invoke-WebRequest -Uri "http://ipinfo.io").Content | findstr /C:"loc"
   $Coordinates = $GeoDateLoc -replace '"','' -replace 'loc:','' -replace '(,)$','' -replace '(^\s+|\s+$)',''

   Try{
      write-host ""
      Invoke-RestMethod -Uri ('http://ipinfo.ioo/'+(Invoke-WebRequest -uri "http://ifconfig.me/ip").Content) |
         select-Object ip,loc,country,city,postal,timezone,hostname,org | Format-List
   }Catch{
      Write-Host "`nx " -ForegroundColor Red -NoNewline
      Write-Host "Error: " -ForegroundColor DarkGray -NoNewline
      Write-Host "$($Error[0])`n" -ForegroundColor Red
      exit
   }

   write-host "* Uri: " -ForegroundColor Blue -NoNewline
   write-host "https://www.google.com/maps/dir/@$Coordinates`n" -ForegroundColor Green
   write-host ""
   exit
}


#Local function variable declarations
$IsAdmin = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"

#Dependencies Tests {GeoCoordinateWatcher}
If(-not(Test-Path -Path "$RegistryPath") -and ($Api -ne "curl"))
{
   If(-not($IsAdmin))
   {
      write-host "x " -ForegroundColor Red -NoNewline
      write-host "Error: " -ForegroundColor DarkGray -NoNewline
      write-host "Admin privs required to create reg hive .." -ForegroundColor Red
   }
   Else
   {
      write-host "  + " -ForegroundColor DarkYellow -NoNewline
      write-host "Activate: device location in:'" -ForegroundColor DarkGray -NoNewline
      write-host "regedit" -ForegroundColor DarkYellow -NoNewline
      write-host "'" -ForegroundColor DarkGray

      #Create the new registry hive
      New-Item -Path "$RegistryPath" -Force|Out-Null
      Start-Sleep -Milliseconds 1000 #Give extra time for registry refresh
   }
}

If((Get-ItemProperty -Path "$RegistryPath").Value -iNotMatch 'allow' -and ($Api -ne "curl"))
{
   If(-not($IsAdmin))
   {
      write-host "x " -ForegroundColor Red -NoNewline
      write-host "Error: " -ForegroundColor DarkGray -NoNewline
      write-host "Admin privs required to create reg key .." -ForegroundColor Red
   }
   Else
   {
      write-host "  + " -ForegroundColor DarkYellow -NoNewline
      write-host "Activate: device location to:'" -ForegroundColor DarkGray -NoNewline
      write-host "allow" -ForegroundColor DarkYellow -NoNewline
      write-host "'" -ForegroundColor DarkGray

      write-host "  + " -ForegroundColor DarkYellow -NoNewline
      write-host "Registry: '" -ForegroundColor DarkGray -NoNewline
      write-host "$RegistryPath" -ForegroundColor Blue -NoNewline
      write-host "'" -ForegroundColor DarkGray

      #Modify location registry key
      New-ItemProperty -Path "$RegistryPath" -Name "value" -Value "allow" -PropertyType "String" -Force|Out-Null
      Start-Sleep -Milliseconds 1500 #Give extra time for registry refresh
   }
}


#Add assembly
Add-Type -AssemblyName System.Device #Required to access System.Device.Location namespace
$GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher #Create the required object
$GeoWatcher.Start() #Begin resolving current locaton
While(($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied'))
{
    Start-Sleep -Milliseconds 150 #Wait for discovery.
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
      * TimeStamp             : '14/junho/2022'

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
   write-host "'`n`n" -ForegroundColor DarkGray

   #Download\Execute cmdlet from GitHub
   iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GeoLocation.ps1" -OutFile "GeoLocation.ps1"|Unblock-File

   If($PublicAddr -ieq "false")
   {
      ## My wife PC does not show Table correctly
      # when invoking powershell with -file argument
      .\GeoLocation.ps1 -HiddeMyAss 'true'
   }
   Else
   {
      .\GeoLocation.ps1
   }
   
   #CleanUp
   Remove-Item -Path "GeoLocation.ps1" -Force
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
        + Activate: devive location to:'allow'
        + Registry:'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'
      * Win32API: 'GeoCoordinateWatcher'
      * TimeStamp '14/junho/2022'
                                                                                                                                                                                                                                                Altitude         Latitude         Longitude                                                                             --------         --------         ---------                                                                                    0 38,7133088132117 -9,13080657585403
      HostName Country  Latitude         Longitude
      -------- -------  --------         ---------
      SKYNET   Portugal 38,7133088132117 -9,13080657585403

      * Uri: https://www.google.com/maps/dir/@38.7133088132117,-9.13080657585403
   #>   

   write-host "* " -ForegroundColor Green -NoNewline
   write-host "Win32API: '" -ForegroundColor DarkGray -NoNewline
   write-host "GeoCoordinateWatcher" -ForegroundColor Yellow -NoNewline
   write-host "'" -ForegroundColor DarkGray

   write-host "* " -ForegroundColor Green -NoNewline
   write-host "TimeStamp '" -ForegroundColor DarkGray -NoNewline
   write-host "$TimeStamp" -ForegroundColor DarkYellow -NoNewline
   write-host "'`n" -ForegroundColor DarkGray

   $Lati = ($GeoWatcher.Position.Location).Latitude
   $Long = ($GeoWatcher.Position.Location).Longitude
   $HomeLocation = (Get-WinHomeLocation).HomeLocation

   $GeoWatcher.Position.Location |
      Select-Object @{Name='HostName';Expression={"$Env:COMPUTERNAME"}},@{Name='Country';Expression={$HomeLocation}},Latitude,Longitude |
      Format-Table -AutoSize

   write-host "* Uri: " -ForegroundColor Blue -NoNewline
   write-host "https://www.google.com/maps/dir/@$Lati,$Long`n" -ForegroundColor Green
}

$GeoWatcher.Stop()
