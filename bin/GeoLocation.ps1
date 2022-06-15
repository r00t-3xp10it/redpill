<#
.SYNOPSIS
   Resolve local host geo location {Local Lan}

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: curl\ipapi.co {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.3

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


$ErrorActionPreference = "SilentlyContinue"

## Get Public Ip addr GeoLocation
# Build GeoLocation DataTable!
$geotable = New-Object System.Data.DataTable
$geotable.Columns.Add("PublicIP")|Out-Null
$geotable.Columns.Add("city")|Out-Null
$geotable.Columns.Add("region")|Out-Null
$geotable.Columns.Add("country")|Out-Null
$geotable.Columns.Add("capital")|Out-Null
$geotable.Columns.Add("latitude")|Out-Null
$geotable.Columns.Add("longitude")|Out-Null


try{
   $PublicAddr = (curl ifconfig.me).Content
}catch{##Error resolving public ip address
   Write-Host "   => Error: fail to resolve '${Env:COMPUTERNAME}' public IP address!" -ForegroundColor Red -BackgroundColor Black
   exit #Exit @GetLocation
}


If($PublicAddr)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Get the Public IP address from curl\ipapi.co!
   #>

   $GeoLocation = (curl "https://ipapi.co/$PublicAddr/json/" -EA SilentlyContinue).RawContent |
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

   #Parse DataTable data OnScreen
   $geotable | Format-Table -AutoSize

   $Organisation = (curl "https://ipapi.co/json/" -EA SilentlyContinue).RawContent | findstr /C:"org"
   $GeoDate = $Organisation -replace '"','' -replace 'org:','' -replace '(^\s+|\s+$)',''

   #GoogleMaps Location Uri link
   Write-Host "* Org: " -ForegroundColor Blue -BackgroundColor Black -NoNewline
   Write-Host "$GeoDate" -BackgroundColor Black
   Write-Host "* Uri: " -ForegroundColor Blue -BackgroundColor Black -NoNewline
   Write-Host "https://www.google.com/maps/dir/@$lati,$long,15z" -ForegroundColor Green -BackgroundColor Black

}
Else
{
   Write-Host "`n* Error: fail to resolve data from curl\ipapi.co!" -ForegroundColor Red -BackgroundColor Black
}
