<#
.SYNOPSIS
   Enumerate active IP Address {Local Lan}

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Networkinformation.ping {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.2.7

.DESCRIPTION
   CmdLet to enumerate active IP address on Local Lan for possible Lateral
   movement oportunitys. It reports active Ip address, trys to resolve dns
   hostname and scans for possible open ports if invoked -Action 'portscan'.

.NOTES
   Remark: This module uses ICMP packets (ping) to scan local Lan network.
   Remark: The Local Host Ip Addr will show up if invoked -output 'verbose'
   but it will be substracted from further tests\scans\logs\report_tables.
   Remark: PingSweep module migth take a long time to finish depending of
   -IpRange 'int' argument setting and if -Action 'PortScan' its invoked.

.Parameter Action
   Accepts arguments: Enum and PortScan (default: enum)

.Parameter IpRange
   Accepts the ip address range to scan (default: 1,255)

.Parameter ScanType
   Accepts arguments: bullet, topports, maxports (default: topports)

.Parameter AddPort
   Add extra port number to ports_to_scan? (default: false)

.Parameter OutPut
   Display verbose outputs? (default: table)

.Parameter Logfile
   Write outputs to logfile? (default: false)

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -Action Enum
   Enumerate all active Ip addr on Lan

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -Action Enum -logfile True
   Enumerate all active addr on Lan + create logfile

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -Action Enum -OutPut verbose
   Enumerate all active addresses + verbose outputs

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -Action Enum -IpRange "65,72"
   Enum active addreses within the -IpRange 'int' sellected

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -Action PortScan -IpRange "1,255"
   Enum all addr + open ports (15 ports) + resolve Dns-NameHost!

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -Action PortScan -ScanType bullet
   Enum all addr + open ports (8 ports) + resolve Dns-NameHost!

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -Action PortScan -ScanType maxports -OutPut verbose
   Enum all addr + open ports (25 ports) + resolve Dns-NameHost + verbose outputs!

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -Action PortScan -iprange "192.168.1.72" -OutPut verbose
   Enum single addr + open ports (15 ports) + resolve Dns-NameHost + verbose outputs!

.INPUTS
   None. You cannot pipe objects into PingSweep.ps1

.OUTPUTS
   * Scanning local lan for active devices!

   InterfaceName  Status LinkSpeed IpRange  LogFile
   -------------  ------ --------- -------  -------
   wireless_32768 Up     65 Mbps   64,73    true

      Starting ICMP (ping) scan ..
      Inactive : 192.168.1.64
      _Active_ : 192.168.1.65 - Id:1
      Inactive : 192.168.1.66
      Inactive : 192.168.1.67
      Inactive : 192.168.1.68
      Inactive : 192.168.1.69
      _Active_ : 192.168.1.70 - Id:2
      Inactive : 192.168.1.71
      _Active_ : 192.168.1.72 - Id:_LocalHostIpAddr_
       |_Substract result from DataTable and Id identifier.
      Inactive : 192.168.1.73

   Id NetAdapter Protocol Status  IpAddress  
   -- ---------- -------- ------- -------------
   1  Wi-Fi      TCP      Active  192.168.1.65
   2  Wi-Fi      TCP      Active  192.168.1.70

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/r00t-3xp10it/redpill/blob/main/bin/PingSweep.ps1
   https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/PingSweep.ps1
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$ScanType="topports",
   [string]$AddPort="false",
   [string]$logfile="false",
   [string]$IpRange="1,255",
   [string]$OutPut="table",
   [string]$Action="enum",
   [string]$Egg="false"
)


$LocalAddress = (#Get Local Ip_Address
    Get-NetIPConfiguration | Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.status -ne "Disconnected"
    }
).IPv4Address.IPAddress


Write-Host ""
[int]$Counter = 0
[int]$MhsfsCounter = 0
$ScanStartTimer = (Get-Date)
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$Rand = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 6 |%{[char]$_})
If($Egg -ieq "False")
{
   Write-Host "* Scanning Lan for active devices!" -ForegroundColor Green
}
$NetAdapterName = (Get-NetAdapter | Select-Object * | Where-Object {
   $_.Status -Match '^(Up)$'
}).Name



If($Action -ieq "Enum" -or $Action -ieq "PortScan")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate active ip addresses inside local lan!

   .NOTES
      This function only displays (in console) the results found in
      the end. Unless its invoked the -OutPut 'verbose' parameter that
      shows in realtime the ip addresses beeing currently scanned.
   #>

   #Build stdout connections DataTable!
   $tcptable = New-Object System.Data.DataTable
   $tcptable.Columns.Add("Id")|Out-Null
   $tcptable.Columns.Add("NetAdapter")|Out-Null
   $tcptable.Columns.Add("Proto")|Out-Null
   $tcptable.Columns.Add("Status ")|Out-Null
   $tcptable.Columns.Add("IpAddress    ")|Out-Null


   #Local function variable declarations \ parsing user input data
   $StartRange = $IpRange.Split(',')[0] ## Get first range value from -IpRange param
   $EndOfRange = $IpRange.Split(',')[1] ## Get second range value from -IpRange param
   $MyLocalAddress = $LocalAddress.split('.')[-1] ## Split Last range of Ip address {72}
   $ping = New-Object System.Net.Networkinformation.ping ## Net ping -ComObject
   $DnSRaw = $LocalAddress -replace "$MyLocalAddress","" ## Get the first 3 ranges
   $SingleIpAddrInput = "False" ## Allow only one iprange input

   #Make sure the report log does not exist!
   If(Test-Path -Path "$Env:TMP\iprange.log")
   {
       Remove-Item -Path "$Env:TMP\iprange.log" -Force
   }


   #Store information of active NetAdapter
   $PrincipalInfo = Get-NetAdapter | Select-Object InterfaceName,Status,LinkSpeed,
      @{Name='IpRange';Expression={"$IpRange"}},
      @{Name='LogFile';Expression={"$logfile"}} | Where-Object {
         $_.Status -iMatch '^(Up)$'
      } | Format-Table -AutoSize

   #Parse DataTable data OnScreen (NetAdapter)
   $PrincipalInfo | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 1 | ForEach-Object {
      $stringformat = If($_ -Match '^(InterfaceName)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      Else
      {
         @{ 'ForegroundColor' = 'White' }
      }
      Write-Host @stringformat $_
   }


   If($OutPut -ieq "verbose")
   {
      Write-Host "`n   Starting ICMP (ping) scan .." -ForegroundColor DarkMagenta -BackgroundColor DarkCyan
      Start-Sleep -Milliseconds 600
   }

   If($IpRange -Match '^(\d+\d+\d).(\d+\d+\d).(\d+|\d+\d+).(\d+|\d+\d+|\d+\d+\d+)$')
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Scan single ip adress user input!

      .NOTES
         Parameter -IpRange <'string'> can be used to scan a single ip
         address for active\inactive state or to resolve dns domain name
         and query for top open ports if invoked the -action <'portscan'>.
      #>

      $SingleIpAddrInput = "True"
      $ping.Send("$IpRange") | Where-Object {
         $_.Status -Match 'Success'

            If($_.Status -Match 'Success')
            {
               Write-Host "   _Active_ : $IpRange - Id:1" -ForegroundColor Green
            }
            Else
            {
               Write-Host "   Inactive : $IpRange - Status: DestinationHostUnreachable?" -ForegroundColor Red -BackgroundColor Black
               exit
            }

      }|findstr /C:"Address" >> $Env:TMP\iprange.log
      $tcptable.Rows.Add("1","$NetAdapterName","TCP","Active","$IpRange")|Out-Null

   }
   Else
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Scan ip address by range!
      #>

      $i = 0
      $StartRange..$EndOfRange | ForEach-Object {
          $ping.Send("${DnSRaw}${_}") | Where-Object {
              $_.Status -Match 'Success'

              Write-Progress -Activity 'Port Scanner' -Status 'scanning'$_.Address.ToString() -PercentComplete 25

              If($_.Status -Match 'Success')
              {
                 $Counter++
                 $MarkMe = "True"
                 $IpAddr = $_.Address.ToString()
                 #Adding values to stdout DataTable!
                 If($_.Address -NotMatch "$LocalAddress")
                 {
                    #Do not add value to DataTable if it equals the local host ip address
                    $tcptable.Rows.Add("$Counter","$NetAdapterName","TCP","Active","$IpAddr")|Out-Null
                 }
                 If($OutPut -ieq "verbose")
                 {
                    If($_.Address -NotMatch "$LocalAddress")
                    {
                       #In verbose - display active ip address in green color
                       Write-Host "   _Active_ :" $_.Address.ToString() "- Id:$Counter" -ForegroundColor Green
                    }
                    Else
                    {
                       $Counter = $Counter-1
                       #In verbose - display the Local Host ip address in yellow color, and substract one number to Id ..
                       Write-Host "   _Active_ :" $_.Address.ToString() "- Id:_LocalHostIpAddr_" -ForegroundColor Yellow
                       Write-Host "    |_" -ForegroundColor Yellow -NoNewline;Write-Host "Substract result from DataTable and Id identifier." -ForegroundColor Red
                       Start-Sleep -Milliseconds 600
                    }
                 }
              }
              Else
              {
                 $MarkMe = "False"
              }

           }|findstr /C:"Address" >> $Env:TMP\iprange.log
           If($MarkMe -ieq "False")
           {
              If($OutPut -ieq "verbose")
              {
                 Write-Host "   Inactive : ${DnSRaw}${_}" -ForegroundColor Blue
              }
           }
      }

   }#End of Single|Range scan function


   Start-Sleep -Seconds 2;Write-Host "";
   #Parse DataTable data onscreen (TCP test successed)
   $tcptable | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 1 | ForEach-Object {
      $stringformat = If($_ -Match '^(Id)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      Else
      {
         @{ 'ForegroundColor' = 'White' }
      }
      Write-Host @stringformat $_
   }


   If($logfile -ieq "True")
   {
      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Store active ip addreses to logfile!
      #>

      $MarkTheDate = Date -Format "dd/mm/yyy HH:mm:ss"
      $StdOutTable = $tcptable | Format-Table -AutoSize
      $StdoutAdpter = $PrincipalInfo | Format-Table -AutoSize | Select-Object -SkipLast 1
      echo "@PingSweep - [$MarkTheDate] - $NetAdapterName" > "$Env:TMP\$Rand.log"
      echo "Domain_Name:$Env:COMPUTERNAME IpAddress:$LocalAddress" >> "$Env:TMP\$Rand.log"
      echo $StdoutAdpter >> "$Env:TMP\$Rand.log"
      echo $StdOutTable >> "$Env:TMP\$Rand.log"

      If($Action -ieq "Enum")
      {
         Write-Host "* Logfile: '$Env:TMP\$Rand.log'" -ForegroundColor Red -BackgroundColor Black    
      }
   }
   Write-Host ""



   If($Action -ieq "PortScan")
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Searches for open ports and resolve dns names!

      .NOTES
         Scans for open ports in IP addresses found by previous
         -Action Enum scans, and resolves ip addr DNS NameHost.
      #>

      #Build stdout connections DataTable!
      $Finaltable = New-Object System.Data.DataTable
      $Finaltable.Columns.Add("RemoteHost ")|Out-Null
      $Finaltable.Columns.Add("Status")|Out-Null
      $Finaltable.Columns.Add("Proto")|Out-Null
      $Finaltable.Columns.Add("Port ")|Out-Null
      $Finaltable.Columns.Add("HostName")|Out-Null

      If($ScanType -ieq "maxports")
      {
         $TotalNumberOfPortsToScan = "25"
         $PortRangerdse = @(#Port numbers to be scanned!
            "20,21,22,23,25,53,80,107,110,111,135,137,139,443",
            "445,464,989,993,995,1433,3306,3389,5900,7337,8080"
         )
      }
      ElseIf($ScanType -ieq "Bullet")
      {
         $TotalNumberOfPortsToScan = "8"
         $PortRangerdse = @(#Port numbers to be scanned!
            "21,22,23,25,80,443,445,8080"
         )      
      }
      Else
      {
         $TotalNumberOfPortsToScan = "15"
         #Topports sellection { default value }
         $PortRangerdse = @(#Port numbers to be scanned!
            "21,22,23,25,53,80,110,135,137,139,443,445,3306,5900,8080"
         )
      }

      #Add extra port number to ports_to_scan_list!
      If(-not($AddPort) -or $AddPort -ne "false")
      {
         If($AddPort -Match '^(\d+)$')
         {
            $PortRangerdse += "$AddPort"
         }
      }


      #Loop trough ip address database
      If($SingleIpAddrInput -ieq "True")
      {
         $IpFound = Get-Content -Path "$Env:TMP\iprange.log"|findstr /C:"Address"
      }
      Else
      {
         $IpFound = Get-Content -Path "$Env:TMP\iprange.log"|findstr /C:"Address"|findstr /V /C:"$LocalAddress"
      }
      $DataBase = $IpFound -replace 'Address       : ',''
      $FirstBannerDisplay = "True"

      If($Database -ieq $null)
      {
         #None IP Address found inside logfile!
         Write-Host "* Error: none IP Address found inside logfile!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "";If(Test-Path -Path "$Env:TMP\iprange.log"){Remove-Item -Path "$Env:TMP\iprange.log" -Force}
         Start-Sleep -Seconds 1;exit ## Exit @PingSweep
      }


      ForEach($Item in $DataBase)
      {
         #Resolving Ip addr NameHost (DNS LOOKUP)
         $DnsRawName = (Resolve-DnsName -Name $Item -EA SilentlyContinue).NameHost
         If($DnsRawName)
         {
            #Ip Addr Dns-NameHost found => display NameHost
            Write-Host "HostName: $DnsRawName" -ForeGroundColor Yellow
         }
         Else
         {
            $DnsRawName = "* null *"
            Write-Host "HostName: " -ForeGroundColor Yellow -NoNewline;Write-Host "fail to resolve!" -ForegroundColor Red -BackgroundColor Black
         }

         #Write OnScreen { console }
         If($FirstBannerDisplay -ieq "True")
         {
            $FirstBannerDisplay = "False"
            Write-Host "Scantype: $ScanType [$TotalNumberOfPortsToScan] extraport:$AddPort" -ForeGroundColor Yellow
         }

         Write-Host "Scanning: $Item for open ports!" -ForegroundColor DarkMagenta -BackgroundColor DarkCyan
         $PortRangerdse -split(',') | Foreach-Object -Process {
             If((Test-NetConnection $Item -Port $_ -WarningAction SilentlyContinue).tcpTestSucceeded -eq $true)
             {
                If($OutPut -ieq "verbose")
                {
                   Write-Host "$Item  <Open>   tcp    $_" -ForegroundColor Green  -BackgroundColor Black
                }

                $MhsfsCounter++
                #Write results to DataTable
                $Finaltable.Rows.Add("$Item","Open","tcp","$_","$DnsRawName")|Out-Null
             }
             Else
             {
                #Closed port detected ..
                If($OutPut -ieq "verbose")
                {
                   Write-Host "$Item  Closed   tcp    $_" -ForegroundColor Red  -BackgroundColor Black
                }

                #Write results to DataTable
                $Finaltable.Rows.Add("$Item","closed","tcp","$_","$DnsRawName")|Out-Null
             }

          }## End of Foreach-Object{}
      }## End of ForEach()


      Clear-Host;
      Start-Sleep -Milliseconds 1300
      #Parse DataTable data onscreen (console)
      Write-Host "`n* Scanning Lan for active devices!" -ForegroundColor DarkMagenta -BackgroundColor DarkCyan
      $Finaltable | Format-Table -AutoSize | Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1 | ForEach-Object {
         $stringformat = If($_ -Match '^(RemoteHost)')
         {
            @{ 'ForegroundColor' = 'Green' }
         }
         ElseIf($_ -Match '(Open)')
         {
            @{ 'ForegroundColor' = 'Green' }             
         }
         Else
         {
            @{ 'ForegroundColor' = 'White' }
         }
         Write-Host @stringformat $_
      }

      #Display OnScreen the total number of open ports found!
      Write-Host "`n* Total open ports  : " -ForegroundColor Blue -BackgroundColor Black -NoNewline;
      Write-Host "$MhsfsCounter" -ForegroundColor Green -BackgroundColor Black


      If($logfile -ieq "True")
      {
         <#
         .SYNOPSIS
            Author: @r00t-3xp10it
            Helper - Store active ip addreses to logfile!
         #>

         $StdOutTable = $Finaltable | Format-Table -AutoSize
         echo $StdOutTable >> "$Env:TMP\$Rand.log"
         Write-Host "* Logfile: '$Env:TMP\$Rand.log'" -ForegroundColor Red -BackgroundColor Black
      }

   }
}


#Internal clock Timmer
$ElapsTime = $(Get-Date) - $ScanStartTimer
If($Action -ieq "Enum"){$ScanType = "discovery"}
$TotalTime = "{0:HH:mm:ss}" -f ([datetime]$ElapsTime.Ticks) #Count the diferense between 'start|end' scan duration!
Write-Host "* ElapsedTime: " -ForegroundColor Blue -BackgroundColor Black -NoNewline;
Write-Host "$TotalTime" -ForegroundColor Green -BackgroundColor Black -NoNewline;
Write-Host " - scantype: " -ForegroundColor Blue -BackgroundColor Black -NoNewline;
Write-Host "$ScanType" -ForegroundColor Green -BackgroundColor Black;
If($logfile -ieq "True")
{
   #Writting the elapsed scan time inside logfile!
   echo "* Total open ports  : $MhsfsCounter" >> "$Env:TMP\$Rand.log"
   echo "* ElapsedTime: $TotalTime - scantype: $ScanType" >> "$Env:TMP\$Rand.log"
}

#Cleanning artifacts left behind!
If(Test-Path -Path "$Env:TMP\iprange.log"){Remove-Item -Path "$Env:TMP\iprange.log" -Force}
exit