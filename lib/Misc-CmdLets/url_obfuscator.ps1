<#
.SYNOPSIS
   Ip address URL obfuscator [MITRE T1566.002]

   Author: r00t-3xp10it
   Credits: Nick Simonian [@ scheme abuse]
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: [Convert]::ToString()
   Optional Dependencies: Invoke-WebRequest
   PS cmdlet Dev version: v1.1.8

.DESCRIPTION
   Ip address URL obfuscator converts any decimal ip address
   to [octal|hexadecimal] format and appends an extra layer
   of obfucation to python http.server URI [-specialchars]

.NOTES
   Parameter -exec requires python http.server installed
   and http.server port number to be abble to execute URL

   Parameter -specialchars converts special chars representations
   in URL to an '%hexadecimal' format to append extra obfuscation.
   example: http:/\/\0300%2E0250%2E0001%2E0102:8080/

   Parameter -domain invokes 'URL scheme abuse technic' anything before
   the "@" sign its discarded. [everything after "@" sign its executed]

   Invoke -ip 'USEPATH' together with -path 'www.google.com/search?q=linux'
   to be abble to obfuscate normal URL's without using http.server ip+port
   
.Parameter scheme
   The URL link scheme (example: http://)

.Parameter Domain
   The missdirection domain (example: www.gmail.com)

.Parameter ip
   The python http.server ip (example: 192.168.1.66)

.Parameter Port
   The python http.server server port (default: 8080)

.Parameter Convertion
   Convert decimal chars to octal|hexadecimal (default: octal)

.Parameter specialchars
   Switch that appends extra level of obfuscation to URL link

.Parameter Path
   Accepts URL path with parameters (eg: index.html?q=public&shit#)

.Parameter Exec
   Switch that executes the obfuscted url string [http.server]

.Parameter Logfile
   Switch that writes the obfuscated url into URL_obfuscated.log

.EXAMPLE
   PS C:\> .\url_obfuscator.ps1 -convertion 'octal' -port 'off'
   URL: http://0300.0250.0001.0102/

.EXAMPLE
   PS C:\> .\url_obfuscator.ps1 -convertion 'hexadecimal' -port 'off'
   URL: http://0xc0.0xa8.0x1.0x42/

.EXAMPLE
   PS C:\> .\url_obfuscator.ps1 -scheme 'https://' -ip '192.168.13.1' -port 'off'
   URL: https://0300.0250.0015.0001/

.EXAMPLE
   PS C:\> .\url_obfuscator.ps1 -scheme 'https://' -domain 'Gmail.com' -port '8089'
   URL: https://Gmail.com@0300.0250.0001.0102:8089/

.EXAMPLE
   PS C:\> .\url_obfuscator.ps1 -domain 'gmail.Legit.com' -port '8089' -specialchars
   URL: http:\/\/gmail%2ELegit%2Ecom@0300%2E0250%2E0001%2E0102:8089/

.EXAMPLE
   PS C:\> .\url_obfuscator.ps1 -port '8089' -path 'index.html?q=public_html&shit#Page 1' -specialchars
   URL: http:\/\/0300%2E0250%2E0001%2E0102:8089/index%2Ehtml%3Fq%3Dpublic_html%26shit%23Page%201

.EXAMPLE
   PS C:\> .\url_obfuscator.ps1 -ip 'usepath' -path 'www.google.com/search?q=hazbin hotel' -exec
   URL: http://www.google.com/search?q=hazbin hotel

.EXAMPLE
   PS C:\> .\url_obfuscator.ps1 -ip 'usepath' -path 'www.google.com/search?q=hazbin hotel' -specialchars -exec
   URL: http:\/\/%77%77%77%2E%67%6f%6f%67le%2E%63%6f%6d/\se%61%72%63h?q=h%61zb%69n%20h%6f%74el

.EXAMPLE
   PS C:\> .\url_obfuscator.ps1 -logfile
   Output the obfuscated url into logfile

.INPUTS
   None. You cannot pipe objects into url_obfuscator.ps1

.OUTPUTS
   [19:43] uri @scheme abuse - MITRE T1566.002

   scheme    Domain IPadrress    Port
   ------    ------ ---------    ----
   http://   off    192.168.1.66 8080 


   Convertion  1Range 2Range 3Range 4Range Port
   ------      ------ ------ ------ ------ ----
   Decimal     192    168    1      66     8080 

   Convertion 1Range 2Range 3Range 4Range Port
   ------     ------ ------ ------ ------ ----
   Octal      0300   0250   0001   0102   8080 


   Obfuscated URI             
   --------------             
   http://0300.0250.0001.0102:8080/
  
.LINK
   https://github.com/r00t-3xp10it/redpill
   https://attack.mitre.org/techniques/T1566/002
   https://support.trustwave.com/kb/print10537.aspx
   https://www.mandiant.com/resources/blog/url-obfuscation-schema-abuse
   https://powershellcookbook.com/recipe/VoMp/convert-numbers-between-bases
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Convertion="octal",
   [string]$scheme="http://",
   [string]$Domain="off",
   [switch]$specialchars,
   [string]$Port="8080",
   [string]$Path="off",
   [string]$IP="off",
   [switch]$Logfile,
   [switch]$Exec
)


$Cbites = $null
$cmdletver = "v1.1.8"
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "URL_obuscator $cmdletver"

If(-not($Convertion -imatch '^(octal|hexadecimal)$'))
{
   write-host "`n[ERROR] cmdlet only accepts 'octal' or 'hexadecimal' formats.`n" -ForegroundColor Red
   return
}

If(($IP -imatch '^(off)$') -or ($IP -imatch '^(usepath)$'))
{
   $IpAddr = ((ipconfig|findstr [0-9].\.)[0]).Split()[-1]
}

## Cmdlet banner
$URLANATOMY = @"
┌─────────┬───────────────┬───┬──────────────┬────────┬──────────────────────────────────┐
| http:// | www.gmail.com | @ | 192.168.1.66 | :8080/ | index.html?q?=public&Shit#Page 1 |
└─────────┴───────────────┴───┴──────────────┴────────┴──────────────────────────────────┘
     ↑            ↑         ↑        ↑           ↑                    ↑
  scheme    missdirection abuse  http.server  http.port    path with\without parameters
"@;
write-host $URLANATOMY -ForegroundColor Gray

write-host "`n`n[" -NoNewline
write-host "$(Get-Date -Format 'HH:mm')" -ForegroundColor Red -NoNewline
write-host "] " -NoNewline;write-host "uri @scheme abuse - MITRE T1566.002" -ForegroundColor Red


## Create Data Table for output
$mytable = New-Object System.Data.DataTable
$mytable.Columns.Add("scheme")|Out-Null
$mytable.Columns.Add("Domain")|Out-Null
$mytable.Columns.Add("IPadrress")|Out-Null
$mytable.Columns.Add("Port")|Out-Null

## Add values to table
$mytable.Rows.Add("$scheme","$Domain","$IpAddr","$Port")|Out-Null

## Display Data Table
$mytable | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 1 | ForEach-Object {
   $stringformat = If($_ -Match '^(scheme)')
   {
      @{ 'ForegroundColor' = 'Green' }
   }
   ElseIf($_ -Match '---')
   {
      @{ 'ForegroundColor' = 'White' }   
   }
   Else
   {
      @{ 'ForegroundColor' = 'DarkYellow' }
   }
   Write-Host @stringformat $_
}


## Split IP in decimal values
$one = $IpAddr.Split('.')[0]  # 192
$doi = $IpAddr.Split('.')[1]  # 168
$tre = $IpAddr.Split('.')[2]  # 1
$qua = $IpAddr.Split('.')[3]  # 66

## Create Data Table for output
$mytable = New-Object System.Data.DataTable
$mytable.Columns.Add("Convertion")|Out-Null
$mytable.Columns.Add("1Range")|Out-Null
$mytable.Columns.Add("2Range")|Out-Null
$mytable.Columns.Add("3Range")|Out-Null
$mytable.Columns.Add("4Range")|Out-Null
$mytable.Columns.Add("Port")|Out-Null

## Add values to table
$mytable.Rows.Add("Decimal","$one","$doi","$tre","$qua","$Port")|Out-Null

## Display Data Table
$mytable | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 1 | ForEach-Object {
   $stringformat = If($_ -Match '^(Convertion)')
   {
      @{ 'ForegroundColor' = 'Green' }
   }
   ElseIf($_ -Match '---')
   {
      @{ 'ForegroundColor' = 'DarkGray' }   
   }
   Else
   {
      @{ 'ForegroundColor' = 'White' }
   }
   Write-Host @stringformat $_
}

Start-Sleep -Milliseconds 600
## CONVERT to OCTAL <-> HEXADECIMAL
If(-not($Convertion -imatch '^(octal)$'))
{
   $Cbites = 16   #-> 16 bites
}
Else
{
   $Cbites = 8    #-> 8 bites
}

$1 = [Convert]::ToString($one, $Cbites)
$2 = [Convert]::ToString($doi, $Cbites)
$3 = [Convert]::ToString($tre, $Cbites)
$4 = [Convert]::ToString($qua, $Cbites)

If($Cbites -eq 8)
{
   ## OCTAL 8 bites
   If($1.Length -eq 1)
   {
      $1 = "000"+"$1" -join ''
   }
   ElseIf($1.Length -eq 2)
   {
      $1 = "00"+"$1" -join ''
   }
   ElseIf($1.Length -eq 3)
   {
      $1 = "0"+"$1" -join ''
   }

   If($2.Length -eq 1)
   {
      $2 = "000"+"$2" -join ''
   }
   ElseIf($2.Length -eq 2)
   {
      $2 = "00"+"$2" -join ''
   }
   ElseIf($2.Length -eq 3)
   {
      $2 = "0"+"$2" -join ''
   }

   If($3.Length -eq 1)
   {
      $3 = "000"+"$3" -join ''
   }
   ElseIf($3.Length -eq 2)
   {
      $3 = "00"+"$3" -join ''
   }
   ElseIf($3.Length -eq 3)
   {
      $3 = "0"+"$3" -join ''
   }

   If($4.Length -eq 1)
   {
      $4 = "000"+"$4" -join ''
   }
   ElseIf($4.Length -eq 2)
   {
      $4 = "00"+"$4" -join ''
   }
   ElseIf($4.Length -eq 3)
   {
      $4 = "0"+"$4" -join ''
   }
}
Else
{
   ## HEXADECIMAL 16 bites
   $1 = "0x"+"$1" -join ''
   $2 = "0x"+"$2" -join ''
   $3 = "0x"+"$3" -join ''
   $4 = "0x"+"$4" -join ''
}


## Create Data Table for output
$mytable = New-Object System.Data.DataTable
$mytable.Columns.Add("Convertion")|Out-Null
$mytable.Columns.Add("1Range")|Out-Null
$mytable.Columns.Add("2Range")|Out-Null
$mytable.Columns.Add("3Range")|Out-Null
$mytable.Columns.Add("4Range")|Out-Null
$mytable.Columns.Add("Port")|Out-Null

## Add values to table
$mytable.Rows.Add("$Convertion","$1","$2","$3","$4","$Port")|Out-Null

## Display Data Table
$mytable | Format-Table -AutoSize | Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1 | ForEach-Object {
   $stringformat = If($_ -Match '^(Convertion)')
   {
      @{ 'ForegroundColor' = 'Green' }
   }
   ElseIf($_ -Match '---')
   {
      @{ 'ForegroundColor' = 'DarkGray' }   
   }
   Else
   {
      @{ 'ForegroundColor' = 'White' }
   }
   Write-Host @stringformat $_
}


## Final uri
# http:/\/\Gmail%2Ecom@0300%2E0250%2E0001%2E0102:8080/
Start-Sleep -Milliseconds 600
If($Port -imatch '^(off)$')
{
   If($Domain -imatch '^(off)$')
   {
      If($scheme -imatch '^(off)$')
      {
         $FinalUrl = "${1}.${2}.${3}.${4}"      
      }
      Else
      {
         $FinalUrl = "${scheme}${1}.${2}.${3}.${4}"
      }
   }
   Else
   {
      If($scheme -imatch '^(off)$')
      {
         write-host "`n[ERROR] -domain requires -scheme parameter`n" -ForegroundColor Red
         return
      }

      $FinalUrl = "${scheme}${Domain}@${1}.${2}.${3}.${4}"
   }
}
Else
{

   If($scheme -imatch '^(off)$')
   {
      write-host "`n[ERROR] -port requires -scheme parameter`n" -ForegroundColor Red
      return
   }

   If($Domain -imatch '^(off)$')
   {
      $FinalUrl = "${scheme}${1}.${2}.${3}.${4}:${Port}"   
   }
   Else
   {
      $FinalUrl = "${scheme}${Domain}@${1}.${2}.${3}.${4}:${Port}"
   }
}


If($specialchars.IsPresent)
{
   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Obfuscate URL special chars to %hex

   .NOTES
      Invoking -specialchars -path 'root/index.html?=sc&'
      convertes path to: 'root/\index%2Ehtml%3F%3Dsc%26'

      %3a = : | %2f = / | %3D = = | %3F = ?
      %20 = empty space | %3E = > | %3C = <
      %26 = & | %25 = % | %23 = # | %40 = @
      %77 = w

      DOUBLE OBFUSCATION?
      % = %25 (replace % by %25+hex without %)
      %253a = : (%25 = % | %3a = :) -> ItFails

   .OUTPUTS
      [18:26] uri @scheme abuse - MITRE T1566.002

      scheme  Domain              IPadrress    Port
      ------  ------              ---------    ----
      http:// www.gmail.legit.com 192.168.1.66 8080


      Convertion 1Range 2Range 3Range 4Range Port
      ---------- ------ ------ ------ ------ ----
      Decimal    192    168    1      66     8080

      Convertion 1Range 2Range 3Range 4Range Port
      ---------- ------ ------ ------ ------ ----
      Octal      0300   0250   0001   0102   8080


      Obfuscated URI
      --------------
      http:/\/\%77%77%77%2Egmail%2Elegit%2Ecom@0300%2E0250%2E0001%2E0102:8080/
   #>


   If($Domain -match '(www\.)')
   {
      ## Append extra obfucation to -domain entry
      $FinalUrl = $FinalUrl -replace 'www\.','%77%77%77%2E'
   }

   ## Append extra obfucation to URI
   $FinalUrl = $FinalUrl -replace '/','/\'
   $FinalUrl = $FinalUrl -replace '\.','%2E'
    
   If(-not([string]::IsNullOrEmpty($Path)) -and ($Path -notmatch '^(off)$'))
   {
      $Path = $Path -replace 'www\.','%77%77%77%2E'
      ## Append extra obfucation to URI\PATH
      $Path = $Path -replace '/','/\'    ## /
      $Path = $Path -replace '\.','%2E'  ## .
      $Path = $Path -replace '&','%26'   ## &

      $Path = $Path -replace 'a','%61'   ## a   Original: index.html?q=public_html&shit#Page 1
      $Path = $Path -replace 'i','%69'   ## i   Obfuscat: %69ndex%2Eh%74%6dl?q=publ%69%63%5fh%74%6dl%26sh%69%74%23P%61%67e%201
      $Path = $Path -replace 'o','%6f'   ## o
      $Path = $Path -replace 'u','%75'   ## u
      $Path = $Path -replace 't','%74'   ## t
      $Path = $Path -replace 'g','%67'   ## g
      $Path = $Path -replace 'm','%6d'   ## m
      $Path = $Path -replace 'r','%72'   ## r
      $Path = $Path -replace 'c','%63'   ## c
      $Path = $Path -replace '_','%5f'   ## _

      $Path = $Path -replace '#','%23'   ## cardinal
      $Path = $Path -replace ' ','%20'   ## empty pace
   }
}

## Create final URL link
If(-not($scheme -imatch '^(off)$'))
{
   $FinalUrl = "$FinalUrl" + "/" -join ''
}

If(($IP -imatch '^(usepath)$') -and ($Path -notmatch '^(off)$'))
{
   $FinalUrl = "${scheme}" -replace '/','/\'
}

If(-not([string]::IsNullOrEmpty($Path)) -and ($Path -notmatch '^(off)$'))
{
   $FinalUrl = "$FinalUrl" + "$Path" -join ''
}


## Create Data Table for output
$mytable = New-Object System.Data.DataTable
$mytable.Columns.Add("Obfuscated URI")|Out-Null

## Add values to table
$mytable.Rows.Add("$FinalUrl")|Out-Null

## Display Data Table
$mytable | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 1 | ForEach-Object {
   $stringformat = If($_ -Match '^(Obfuscated)')
   {
      @{ 'ForegroundColor' = 'Green' }
   }
   ElseIf($_ -Match '---')
   {
      @{ 'ForegroundColor' = 'White' }   
   }
   Else
   {
      @{ 'ForegroundColor' = 'Red'; 'BackGroundColor' = 'Black' }
   }
   Write-Host @stringformat $_
}


If($Exec.IsPresent)
{
   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - start python http.server [local]

   .OUTPUTS
      [18:26] uri @scheme abuse - MITRE T1566.002

      scheme  Domain          IPadrress    Port
      ------  ------          ---------    ----
      http:// gmail.legit.com 192.168.1.66 8080


      Convertion 1Range 2Range 3Range 4Range Port
      ---------- ------ ------ ------ ------ ----
      Decimal    192    168    1      66     8080

      Convertion 1Range 2Range 3Range 4Range Port
      ---------- ------ ------ ------ ------ ----
      Octal      0300   0250   0001   0102   8080


      Obfuscated URI
      --------------
      http:/\/\gmail%2Elegit%2Ecom@0300%2E0250%2E0001%2E0102:8080/

      Execute http.server                              
      -------------------                               
      &($Env:DRIVERDATA[9,14,35,21,14]-join'') http:/\/\gmail%2Elegit%2Ecom@0300%2E0250%2E0001%2E0102:8080/
   #>

   $CheckMe = (python --version)
   If(-not($CheckMe -imatch '^(Python \d\.\d\.\d{1,2})$'))
   {
      write-host "`n[ERROR] cant execute: python http.server not found`n" -ForegroundColor Red -BackgroundColor Black
      return
   }

   If(($Port -imatch '^(off)$') -and ($IP -notmatch '^(usepath)$'))
   {
      write-host "`n[ERROR] cant execute: missing -port parameter`n" -ForegroundColor Red -BackgroundColor Black
      return
   }

   If($scheme -imatch '^(off)$')
   {
      write-host "`n[ERROR] cant execute: missing -scheme parameter`n" -ForegroundColor Red -BackgroundColor Black
      return   
   }

   ## Create Data Table for output
   $mytable = New-Object System.Data.DataTable
   $mytable.Columns.Add("Execute http.server")|Out-Null
   $ToExecutE = "&(`$Env:DRIVERDATA[9,14,35,21,14]-join'') $FinalUrl"

   ## Add values to table
   $mytable.Rows.Add("$ToExecutE")|Out-Null

   ## Display Data Table
   $mytable | Format-Table -AutoSize | Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1 | ForEach-Object {
      $stringformat = If($_ -Match '^(Execute)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      ElseIf($_ -Match '---')
      {
         @{ 'ForegroundColor' = 'White' }   
      }
      Else
      {
         @{ 'ForegroundColor' = 'Red'; 'BackGroundColor' = 'Black' }
      }
      Write-Host @stringformat $_
   }

   ## http.server terminal console banner
   If(-not(Test-Path -Path "banner.mp"))
   {
      iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/meterpeter/master/mimiRatz/theme/banner.mp" -OutFile "banner.mp"|Unblock-File
   }

   ## Select last python verion
   If($CheckMe -imatch '^(Python 3\.\d)')
   {
      $interpreter = "python3" 
   }
   Else
   {
      $interpreter = "python"
   }

   ## Start http.server [local]
   If(($IP -imatch '^(usepath)$') -or ($scheme -imatch '^(https:)'))
   {}
   Else
   {
      Start-Process powershell.exe -argumentlist "Get-content banner.mp;write-host '[ Press CTRL+C to exit python http.server ]' -foregroundcolor red;$interpreter -m http.server $Port --bind $IpAddr"
      Start-Sleep -Milliseconds 2300
   }

   ## Execute phishing webpage [local]
   &($Env:DRIVERDATA[9,14,35,21,14]-join'') $FinalUrl
   Remove-Item -Path "$pwd\banner.mp" -Force
}

If($Logfile.IsPresent)
{
   write-host "[" -NoNewline
   write-host "logfile" -ForegroundColor Red -NoNewline;write-host "] " -NoNewline
   write-host "$pwd\URL_obfuscated.log`n" -ForegroundColor Red

   If($Exec.IsPresent)
   {
      echo "$ToExecutE"|Out-File -FilePath "$pwd\URL_obfuscated.log" -Encoding string -Force
   }
   Else
   {
      echo $FinalUrl|Out-File -FilePath "$pwd\URL_obfuscated.log" -Encoding string -Force   
   }
}

exit