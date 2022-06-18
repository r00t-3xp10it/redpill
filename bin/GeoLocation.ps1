<#
.SYNOPSIS
   Resolve local host geo location {Local Lan}

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: curl\ipapi.co {native}
   Optional Dependencies: Invoke-WebRequest {native}
   PS cmdlet Dev version: v1.0.6

.DESCRIPTION
   CmdLet to resolve local host geo location and public ip addr.

.Parameter HiddeMyAss
   Dont display public ip addr? (default: false)

.EXAMPLE
   PS C:\> .\GeoLocation.ps1 -HiddeMyAss True
   Resolve geo location \ display public ip addr

.EXAMPLE
   PS C:\> .\GeoLocation.ps1 -HiddeMyAss false
   Resolve geo location \ dont display public addr

.INPUTS
   None. You cannot pipe objects into GeoLocation.ps1

.OUTPUTS
   * Scanning local host geo location!

   PublicIP  city   region country  capital latitude longitude
   --------  ----   ------ -------  ------- -------- ---------
   HideMyAss Lisbon Lisbon Portugal Lisbon  38.731   -9.1373 

   * Uri: https://www.google.com/maps/dir/@38.731,-9.1373,15z

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GeoLocation.ps1
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$HiddeMyAss="false"
)


#Build GeoLocation DataTable!
$geotable = New-Object System.Data.DataTable
$geotable.Columns.Add("PublicIP")|Out-Null
$geotable.Columns.Add("city")|Out-Null
$geotable.Columns.Add("region")|Out-Null
$geotable.Columns.Add("country")|Out-Null
$geotable.Columns.Add("capital")|Out-Null
$geotable.Columns.Add("latitude")|Out-Null
$geotable.Columns.Add("longitude")|Out-Null


$ErrorActionPreference = "SilentlyContinue"
$PublicAddr = (Invoke-WebRequest -Uri "http://ifconfig.me/ip").Content
#Make sure '$PublicAddr' have returned one ip addr.
If($PublicAddr -NotMatch '^(\d+\.+\d+\.+\d+\.+\d)')
{
   $PublicAddr = (curl ifconfig.me).Content
}


If($PublicAddr -Match '^(\d+\.+\d+\.+\d+\.+\d)')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Resolve Geo Location [curl\ipapi.co]
   #>

   $GeoLocation = (Invoke-WebRequest -Uri "https://ipapi.co/$PublicAddr/json/").RawContent |
      findstr /C:"city" /C:"region" /C:"country_" /C:"latitude" /C:"longitude" |
      findstr /V "iso3 tld calling area population region_code country_code"
}
Else
{
   $GeoLocation = (Invoke-WebRequest -Uri "https://ipapi.co/json/").RawContent |
      findstr /C:"city" /C:"region" /C:"country_" /C:"latitude" /C:"longitude" |
      findstr /V "iso3 tld calling area population region_code country_code"
}


If($GeoLocation)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Parse curl metadata to human-readable!
   #>

   If($HiddeMyAss -ieq "True"){$PublicAddr = "HideMyAss"}
   $GeoDate = $GeoLocation -replace '"','' -replace ',','' -replace '(^\s+|\s+$)',''
   $Moreati = $Geodate -replace '(city: |region: |country_name: |country_capital: |latitude: |longitude: )',''
       
   $city = $Moreati[0] -join ''   ## city
   $regi = $Moreati[1] -join ''   ## region
   $cnam = $Moreati[2] -join ''   ## country_name
   $ccap = $Moreati[3] -join ''   ## country_capital
   $lati = $Moreati[4] -join ''   ## latitude
   $long = $Moreati[5] -join ''   ## longitude

   #Adding values to DataTable!
   $geotable.Rows.Add("$PublicAddr", ## PublicIP
                      "$city",       ## city
                      "$regi",       ## region
                      "$cnam",       ## country_name
                      "$ccap",       ## country_capital
                      "$lati",       ## latitude
                      "$long"        ## longitude
   )|Out-Null

   #Display Data Table OnScreen
   $geotable | Format-Table -AutoSize

   $Organisation = (Invoke-WebRequest -Uri "https://ipapi.co/json/").RawContent | findstr /C:"org"
   $GeoDate = $Organisation -replace '"','' -replace 'org:','' -replace '(^\s+|\s+$)',''

   Write-Host "* Org: " -ForegroundColor Blue -BackgroundColor Black -NoNewline
   Write-Host "$GeoDate" -BackgroundColor Black

   #GoogleMaps Location Uri link
   Write-Host "* Uri: " -ForegroundColor Blue -BackgroundColor Black -NoNewline
   Write-Host "https://www.google.com/maps/dir/@$lati,$long,15z" -ForegroundColor Green -BackgroundColor Black

}
Else
{
   Write-Host "`nx Error: " -ForegroundColor Red -NoNewline
   Write-Host "fail to resolve data from: '" -ForegroundColor DarkGray -NoNewline
   Write-Host "curl\ipapi.co" -ForegroundColor Red -NoNewline
   Write-Host "'`n" -ForegroundColor DarkGray
}
