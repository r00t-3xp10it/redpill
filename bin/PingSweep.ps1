<#
.SYNOPSIS
   Enumerate active IP Address {Local Lan}

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   Module to enumerate active IP address of Local Lan
   for possible Lateral Movement oportunitys. It reports
   active Ip address in local lan and scans for open ports
   in all active ip address found by -PingSweep Enum @arg.
   Remark: This module uses ICMP packets (ping) to scan..

.NOTES
   Required Dependencies: .Net.Networkinformation.ping {native}
   Remark: Ping Sweep module migth take a long time to finish
   depending of -Range parameter user input sellection or if
   the Verbose @Argument its used to scan for open ports and
   resolve ip addr Dns-NameHost to better identify the device.

.Parameter PingSweep
   Accepts arguments: Enum and Verbose

.Parameter Range
   Accepts the ip address range int value (from 1 to 255)

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -PingSweep Enum
   Enumerate All active IP Address on Local Lan {range 1..255}

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -PingSweep Enum -Range "65,72"
   Enumerate All active IP Address on Local Lan within the Range selected

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -PingSweep Verbose -Range "1,255"
   Enumerate IP addr + open ports + resolve Dns-NameHost in all IP's found

.OUTPUTS
   Range[65..72] Active IP Address on Local Lan
   --------------------------------------------
   Address       : 192.168.1.65
   Address       : 192.168.1.66
   Address       : 192.168.1.70
   Address       : 192.168.1.72
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$PingSweep="false",
   [string]$Range="1,255"
)


$Address = (## Get Local IpAddress
    Get-NetIPConfiguration|Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.status -ne "Disconnected"
    }
).IPv4Address.IPAddress
$Banner = @"

             * Reverse TCP Shell Auxiliary Powershell Module *
     _________ __________ _________ _________  o  ____      ____      
    |    _o___)   /_____/|     O   \    _o___)/ \/   /_____/   /_____ 
    |___|\____\___\%%%%%'|_________/___|%%%%%'\_/\___\_____\___\_____\   
          Author: r00t-3xp10it - SSAredTeam @2021 - Version: v1.2.6
            Help: powershell -File redpill.ps1 -Help Parameters

      
"@;


Write-Host ""
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($PingSweep -ieq "Enum" -or $PingSweep -ieq "Verbose"){
[int]$MhsfsCounter = 0

    ## Local variable declarations
    $StartRange = $Range.Split(',')[0] ## Get first range value from -Range param
    $EndOfRange = $Range.Split(',')[1] ## Get second range value from -Range param
    $MyLocalAddress = $Address.split('.')[-1] ## Split Last range of Ip address {72}
    $ping = New-Object System.Net.Networkinformation.ping ## Ping -ComObject
    $DnSRaw = $Address -replace "$MyLocalAddress",""

    ## Make sure report log does not exist
    If(Test-Path -Path "$Env:TMP\iprange.log"){
        Remove-Item -Path "$Env:TMP\iprange.log" -Force
    }

    If($PingSweep -ieq "Enum" -or $PingSweep -ieq "Verbose")
    {
        ## Loop function {Sellected Range}
        Write-Host "Range[${StartRange}..${EndOfRange}] Scanning Local Lan!" -ForegroundColor Green
        Write-Host "---------------------------------"
        $StartRange..$EndOfRange|ForEach-Object {## Loop truth ip adress(s) ranges
            $ping.Send("${DnSRaw}${_}")|Where-Object {## Send icmp packet
                $_.Status -Match 'Success'
             }|findstr /C:"Address" >> $Env:TMP\iprange.log
             Write-Host "Scanning: ${DnSRaw}${_}" -ForegroundColor Blue
        }


        ## Build Table Output
        Start-Sleep -Seconds 1;Clear-Host;Write-Host "$Banner" -ForegroundColor Blue
        Write-Host "Active IP Address on Local Lan!" -ForegroundColor Green
        Write-Host "-------------------------------"

        If(Test-Path -Path "$Env:TMP\iprange.log"){
            $Database = Get-Content -Path "$Env:TMP\iprange.log"|
            findstr /C:"Address"|findstr /V "$Address"
            If($Database -ne $null){## IP Address found inside logfile
                echo $Database >> $Env:TMP\hvsvss.log
                Get-Content -Path "$Env:TMP\hvsvss.log"
                Remove-Item -Path "$Env:TMP\hvsvss.log" -Force
            }Else{## None IP Address found inside logfile
                Write-Host "[error] None active IP address(s) found!" -ForegroundColor Red -BackgroundColor Black
                Write-Host "";Start-Sleep -Seconds 1
                If(Test-Path -Path "$Env:TMP\iprange.log"){
                    Remove-Item -Path "$Env:TMP\iprange.log" -Force
                }
                exit ## Exit @PingSweep
           }
        }Else{## Error - PingSweep logfile not found in disk
            Write-Host "[error] PingSweep logfile not found in disk!" -ForegroundColor Red -BackgroundColor Black
            Write-Host "";Start-Sleep -Seconds 1
            If(Test-Path -Path "$Env:TMP\iprange.log"){
                Remove-Item -Path "$Env:TMP\iprange.log" -Force
            }
            exit ## Exit @PingSweep
        }
    }## End of Enum @arg funcion


    ## @Verbose - Scans for open ports in IP address
    # found by previous -PingSweep @Enum scans and
    # also trys to resolve ip addr DNS NameHost.
    If($PingSweep -ieq "Verbose"){

        ## Make sure report log does not exist
        If(Test-Path -Path "$Env:TMP\BrowserEnum.log"){
            Remove-Item -Path "$Env:TMP\BrowserEnum.log" -Force
        }

        ## loop truth ip address database {Exclude Local machine from tests}
        $IpFound = Get-Content -Path "$Env:TMP\iprange.log"|findstr /C:"Address"|findstr /V "$Address"
        $DataBase = $IpFound -replace 'Address       : ',''

        If($Database -ieq $null){## None IP Address found inside logfile!
            Write-Host "[error] None IP Address found inside logfile!" -ForegroundColor Red -BackgroundColor Black
            Write-Host "";Start-Sleep -Seconds 1
            If(Test-Path -Path "$Env:TMP\iprange.log"){
                Remove-Item -Path "$Env:TMP\iprange.log" -Force
            }
            exit ## Exit @PingSweep
        }

        $PortRangerdse = "21,22,23,25,80,110,135,137,139,443,445,8080"
        echo "`n`nRemote-Host   Status   Proto  Port" >> $Env:TMP\BrowserEnum.log
        echo "------------- ------   -----  ----" >> $Env:TMP\BrowserEnum.log
        Write-Host ""
        ForEach($Item in $DataBase){## Loop truth all IP addr found

            ## Resolving Ip addr NameHost (DNS LOOKUP)
            $DnsRawName = (Resolve-DnsName -Name $Item -ErrorAction SilentlyContinue).NameHost
            If($DnsRawName){## Ip Addr Dns-NameHost found => display NameHost
                Write-Host "`nHostName: $DnsRawName" -ForeGroundColor Yellow
                echo "Address : $Item => $DnsRawName" >> $Env:TMP\resolvedns.log
            }Else{
                Write-Host "`nHostName: fail to resolve!" -ForeGroundColor Yellow
                echo "Address : $Item" >> $Env:TMP\resolvedns.log
            }

            Write-Host "Scanning: $Item for open ports!" -ForeGroundColor Yellow
            Write-Host "---------------------------------------"
            $PortRangerdse -split(',')|Foreach-Object -Process {
                If((Test-NetConnection $Item -Port $_ -WarningAction SilentlyContinue).tcpTestSucceeded -eq $true){
                    echo "$Item  Open     tcp    $_ *" >> $Env:TMP\BrowserEnum.log
                    Write-Host "$Item  <Open>   tcp    $_ *" -ForegroundColor Green -BackgroundColor Black
                    $MhsfsCounter++
                }Else{## Closed port detected ..
                    echo "$Item  Closed   tcp    $_" >> $Env:TMP\BrowserEnum.log
                    Write-Host "$Item  Closed   tcp    $_" -ForegroundColor Red -BackgroundColor Black
                }
            }## End of ForEach{}
        }## End of ForEach()

        ## Build last Output Tables
        echo "`nTotal open tcp ports found => $MhsfsCounter" >> $Env:TMP\BrowserEnum.log
        Start-Sleep -Milliseconds 500;Clear-Host
        Start-Sleep -Milliseconds 500;Clear-Host
        Write-Host "$Banner" -ForegroundColor Blue
        Write-Host "Active IP Address on Local Lan!" -ForegroundColor Green
        Write-Host "-------------------------------"
        Get-Content -Path "$Env:TMP\resolvedns.log"
        Get-Content -Path "$Env:TMP\BrowserEnum.log"

    }## End of Verbose @arg function

    ## Clean OLD files
    If(Test-Path -Path "$Env:TMP\iprange.log"){Remove-Item -Path "$Env:TMP\iprange.log" -Force}
    If(Test-Path -Path "$Env:TMP\resolvedns.log"){Remove-Item -Path "$Env:TMP\resolvedns.log" -Force}
    If(Test-Path -Path "$Env:TMP\BrowserEnum.log"){Remove-Item -Path "$Env:TMP\BrowserEnum.log" -Force}
    Write-Host "";Start-Sleep -Seconds 1
}