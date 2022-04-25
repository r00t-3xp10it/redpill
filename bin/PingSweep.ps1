<#
.SYNOPSIS
   Enumerate active IP Address {Local Lan}

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Networkinformation.ping {native}
   Optional Dependencies: Test-NetConnection {native}
   PS cmdlet Dev version: v1.4.14

.DESCRIPTION
   CmdLet to enumerate active IP address on Local Lan for possible Lateral
   movement oportunitys. It reports active Ip address, trys to resolve dns
   hostname and scans for possible open ports if invoked -Action 'portscan'.

.NOTES
   Remark: This module uses ICMP packets (ping) to scan local Lan network.

   The Local Host Ip Addr will show up if invoked -output 'verbose' but
   it will be substracted from further scans \ logs \ final_report_table

   If invoked -output 'table' argument then cmdlet only displays in final
   Table 'Open' ports reports. If invoked -output 'verbose' then cmdlet
   displays in realtime the ip address beeing scanned and in final Table
   it displays the 'closed' and 'open' ports ( elaborated ) report..

   Parameter -addport 'int' can be used to add more than one port number
   to the 'port_to_scan_list'. just split the port numbers using a comma.
   Remark: Extra ports will be added to the end of 'ports_to_scan_list'

   Parameter -timeout 'int' sets the max time in miliseconds to wait for
   the ping reply (cmdlet_default: 500, microsoft_default: 2000) but it
   only works when invoking -action 'enum' (discovery) not in 'portscan'
   Remark: This cmdlet accepts timeouts between 100ms and 2000ms settings

   Remark: PingSweep module migth take a long time to finish depending of
   -iprange 'int' argument setting and if -action 'portscan' its invoked. 

.Parameter Action
   Accepts arguments: Enum and PortScan (default: enum)

.Parameter IpRange
   Accepts the ip address range to scan (default: 1,255)

.Parameter ScanType
   Accepts arguments: bullet, topports, maxports (default: topports)

.Parameter AddPort
   Add extra port number to ports_to_scan? (default: false)

.Parameter TimeOut
   max of milliseconds to wait for ping reply (default: 300)

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
   Enum all addr + open ports (14 ports) + resolve Dns-NameHost!

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -Action PortScan -ScanType bullet
   Enum all addr + open ports (10 ports) + resolve Dns-NameHost!

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -Action PortScan -ScanType maxports -OutPut verbose
   Enum all addr + open ports (25 ports) + resolve Dns-NameHost + verbose outputs!

.EXAMPLE
   PS C:\> .\PingSweep.ps1 -Action PortScan -iprange "192.168.1.72" -OutPut verbose
   Enum single addr + open ports (14 ports) + resolve Dns-NameHost + verbose outputs!

.INPUTS
   None. You cannot pipe objects into PingSweep.ps1

.OUTPUTS
   * Scanning local lan for active devices!

   Name  Status LinkSpeed Action   TimeOut IpRange LogFile
   ----  ------ --------- ------   ------- ------- -------
   Wi-Fi Up     65 Mbps   portscan 500(ms) 64,73   true

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
   http://www.happysysadm.com/2017/02/from-test-connection-to-one-line-long.html
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$ScanType="topports",
   [string]$AddPort="false",
   [string]$logfile="false",
   [string]$IpRange="1,255",
   [string]$OutPut="table",
   [string]$Action="enum",
   [string]$Egg="false",
   [int]$TimeOut="300"
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
If($TimeOut -lt 100 -or $TimeOut -gt 2000)
{
   #Prevent small\big ttl value declarations
   #NOTE: Only works in discovery (not portscan)
   [int]$TimeOut = "500"
}



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
   $DnSRaw = $LocalAddress -replace ".($MyLocalAddress)$","." ## Get the first 3 ip ranges
   If($Action -ieq "enum"){$disaction = "discovery"}Else{$disaction = "$Action"}
   $SingleIpAddrInput = "False" ## Allow only one iprange input

   #Make sure the report log does not exist!
   If(Test-Path -Path "$Env:TMP\iprange.log")
   {
       Remove-Item -Path "$Env:TMP\iprange.log" -Force
   }


   #Store information of active NetAdapter
   $PrincipalInfo = Get-NetAdapter | Select-Object Name,Status,LinkSpeed,
      @{Name='Action';Expression={"$disaction"}},
      @{Name='TimeOut';Expression={"${TimeOut}(ms)"}},
      @{Name='IpRange';Expression={"$IpRange"}},
      @{Name='LogFile';Expression={"$logfile"}} | Where-Object {
         $_.Status -iMatch '^(Up)$'
      } | Format-Table -AutoSize

   #Parse DataTable data OnScreen (NetAdapter)
   $PrincipalInfo | Format-Table -AutoSize | Out-String -Stream | Select-Object -SkipLast 1 | ForEach-Object {
      $stringformat = If($_ -Match '^(Name)')
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
      Write-Host "`nStarting ICMP (ping) scan .." -ForegroundColor DarkMagenta -BackgroundColor DarkCyan
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

      If($OutPut -ieq "verbose")
      {
         $MoreIcmpInfo = Test-NetConnection -ComputerName "$IpRange" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
         $MyTable = $MoreIcmpInfo | Format-List | Out-String -Stream | Select-Object -Skip 2 | Select -SkipLast 4
         echo $MyTable
      }

      $SingleIpAddrInput = "True"
      #$ping.Send($IpRange, $TimeOut) | Where-Object {
      $ping.SendPingAsync($IpRange, $TimeOut) | Where-Object {
         $_.Status -Match 'Success'

            If($_.Status -Match 'Success')
            {
               If($OutPut -ieq "verbose")
               {
                  If($Egg -ieq "false")
                  {
                   Write-Host "StatusCode             : Address_Active" -ForegroundColor Green -BackgroundColor Black
                  }
               }
               Else
               {
                  If($Egg -ieq "false")
                  {
                     Write-Host "`nStatusCode             : Address_Active" -ForegroundColor Green -BackgroundColor Black
                  }
               }
            }
            Else
            {
               #Collect information about why ping failed!
               $StatusCodeInf = (Get-WmiObject Win32_PingStatus -Filter "Address='$IpRange' and Timeout=1500").StatusCode
               If($StatusCodeInf -Match '^(11007)$')
               {
                  $StatusCodeInf = "Bad Option!"         
               }
               ElseIf($StatusCodeInf -Match '^(11011)$')
               {
                  $StatusCodeInf = "Bad Request!"         
               }
               ElseIf($StatusCodeInf -Match '^(11002|11003|11004|11005|11010)$')
               {
                  $StatusCodeInf = "DestinationHostUnreachable?"         
               }
               Else
               {
                  $StatusCodeInf = "Unknown"                 
               }

               Write-Host "StatusCode             : $StatusCodeInf" -ForegroundColor Red -BackgroundColor Black
               Write-Host "`n";exit #Exit @PingSweep
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

      [int]$i = 0
      $StartRange..$EndOfRange | ForEach-Object {
          $ping.Send("${DnSRaw}${_}", $TimeOut) | Where-Object {
              $_.Status -Match 'Success'

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
                 Else
                 {
                    $Counter = $Counter-1
                 }

                 If($OutPut -ieq "verbose")
                 {
                    If($_.Address -NotMatch "$LocalAddress")
                    {
                       If($Egg -ieq "false")
                       {
                          #In verbose - display active ip address in green color
                          Write-Host "_Active_ :" $_.Address.ToString() "- Id:$Counter" -ForegroundColor Green
                       }
                    }
                    Else
                    {
                       If($Egg -ieq "false")
                       {
                          #In verbose - display the Local Host ip address in yellow color, and substract one number to Id ..
                          Write-Host "_Active_ :" $_.Address.ToString() "- Id:" -ForegroundColor Yellow -NoNewline;
                          Write-Host "_LocalHostIpAddr_" -ForegroundColor Red -BackgroundColor Black;
                          Write-Host " |_" -ForegroundColor Yellow -NoNewline;Write-Host "Substract result from database and Id identifier." -ForegroundColor Red -BackgroundColor Black
                          Start-Sleep -Milliseconds 600
                       }
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
              If($OutPut -ieq "verbose" -and $Egg -ieq "false")
              {
                 Write-Host "Inactive : ${DnSRaw}${_}" -ForegroundColor Blue
              }
           }
      }

   }#End of Single|Range scan function


   Start-Sleep -Seconds 2;Write-Host "";
   #Parse DataTable data onscreen (TCP test successed)
   $tcptable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
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
      $StdoutAdpter = $PrincipalInfo | Format-Table -AutoSize|Select -SkipLast 1
      echo "@PingSweep - [$MarkTheDate] - $NetAdapterName" > "$Env:TMP\$Rand.log"
      echo "Domain_Name:$Env:COMPUTERNAME IpAddress:$LocalAddress" >> "$Env:TMP\$Rand.log"
      echo $StdoutAdpter >> "$Env:TMP\$Rand.log"
      echo $StdOutTable >> "$Env:TMP\$Rand.log"

      If($Action -ieq "Enum")
      {
         Write-Host "`n* Logfile:" -ForegroundColor Blue -BackgroundColor Black -NoNewline;
         Write-Host "'$Env:TMP\$Rand.log'" -ForegroundColor Green -BackgroundColor Black;
      }
   }



   If($Action -ieq "PortScan")
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Search for open ports and resolve dns names!

      .NOTES
         Scans for open ports in IP addresses found by previous
         -action 'enum' scans, and resolves ip addr DNS NameHosts.

         Parameter -addport 'int' can be used to add more than one port number
         to the 'port_to_scan_list'. just split the port numbers using a comma.
         Remark: Extra ports will be added to the end of 'ports_to_scan_list'

         If invoked the -output 'table' argument then cmdlet only displays in the
         final Table the 'Open' state ports. If invoked -output 'verbose' then cmdlet
         displays in realtime the ip addresses beeing scanned and in the final Table
         displays the 'Closed' and 'Open' state ports report. (more elaborated report)
      #>

      #Build stdout connections DataTable!
      $Finaltable = New-Object System.Data.DataTable
      $Finaltable.Columns.Add("RemoteHost ")|Out-Null
      $Finaltable.Columns.Add("Status")|Out-Null
      $Finaltable.Columns.Add("Proto")|Out-Null
      $Finaltable.Columns.Add("Port ")|Out-Null
      $Finaltable.Columns.Add("ServiceName")|Out-Null
      $Finaltable.Columns.Add("HostName")|Out-Null

      If($ScanType -ieq "maxports")
      {
         [int]$TotalNumberOfPortsToScan = "25"
         $PortRangerdse = @(#Port numbers to be scanned!
            "20,21,22,23,53,80,107,110,111,135,137,139,443,445",
            "995,989,1080,1433,2049,3128,3306,3389,5222,5900,8080"
         )
      }
      ElseIf($ScanType -ieq "Bullet")
      {
         [int]$TotalNumberOfPortsToScan = "10"
         $PortRangerdse = @(#Port numbers to be scanned!
            "21,22,23,80,110,135,139,443,445,8080"
         )      
      }
      Else
      {
         [int]$TotalNumberOfPortsToScan = "14"
         #Topports sellection { default value }
         $PortRangerdse = @(#Port numbers to be scanned!
            "21,22,23,53,80,110,135,137,139,443,445,3306,5900,8080"
         )
      }

      ## If -addport 'int' parameter its invoked ..
      #Then add all extra ports to ports_to_scan_list!
      If(-not($AddPort) -or $AddPort -ne "false")
      {
         #If -addport 'int' match digits!
         If($AddPort -Match '\d+')
         {
            #If -addport 'int' not match 'ports_to_scan_list' port numbers
            If($PortRangerdse -NotMatch "$AddPort")
            {
               #If -addport 'int' match more than one port number!
               If($AddPort -Match ',')
               {
                  #Split multiple port numbers input!
                  $SpliThisShit = $AddPort.Split(',')
                  ForEach($itemport in $SpliThisShit)
                  {
                     #Add one Id number for each new port number input by user!
                     [int]$TotalNumberOfPortsToScan = [int]$TotalNumberOfPortsToScan+1
                  }
               }
               Else
               {
                  #Add one Id number for the new port number input by user!
                  [int]$TotalNumberOfPortsToScan = [int]$TotalNumberOfPortsToScan+1
               }

               #Add ports to 'ports_to_scan_list'
               $PortRangerdse += "$AddPort"
            }
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
         Write-Host "* Error: none IP Addresses found inside logfile!" -ForegroundColor Red -BackgroundColor Black
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
            Write-Host "`nHostName: $DnsRawName" -ForeGroundColor Yellow
         }
         Else
         {
            $DnsRawName = "* null *"
            Write-Host "`nHostName: " -ForeGroundColor Yellow -NoNewline;
            Write-Host "fail to resolve!" -ForegroundColor Red -BackgroundColor Black;
         }

         #Write OnScreen { console }
         If($FirstBannerDisplay -ieq "True")
         {
            $FirstBannerDisplay = "False"
            Write-Host "Scantype: ${ScanType}[$TotalNumberOfPortsToScan] extraport:$AddPort" -ForeGroundColor Yellow
         }

         #Get some info about ip address from WMI Win32_PingStatus API
         $ReplySizeInfo = (Get-WmiObject Win32_PingStatus -Filter "Address='$Item' and Timeout=800").ReplySize
         $TimeToLiveInf = (Get-WmiObject Win32_PingStatus -Filter "Address='$Item' and Timeout=800").TimeToLive
         $StatusCodeInf = (Get-WmiObject Win32_PingStatus -Filter "Address='$Item' and Timeout=800").StatusCode
         If($StatusCodeInf -Match '^(0)$')
         {
            $StatusCodeInf = "Success"
         }
         ElseIf($StatusCodeInf -Match '^(11010)$')
         {
            $StatusCodeInf = "Timed_Out"         
         }
         ElseIf($StatusCodeInf -Match '^(11002|11003|11004|11005)$')
         {
            $StatusCodeInf = "Unreachable"         
         }
        
         Write-Host "Response: $StatusCodeInf replysize:$ReplySizeInfo ttl:$TimeToLiveInf" -ForeGroundColor Yellow    
         Write-Host "Scanning: $Item for open ports!" -ForegroundColor DarkMagenta -BackgroundColor DarkCyan
         $PortRangerdse -split(',') | Foreach-Object -Process {
             If((Test-NetConnection $Item -Port $_ -WarningAction SilentlyContinue).tcpTestSucceeded -ieq $true)
             {
                If($OutPut -ieq "verbose" -and $Egg -ieq "false")
                {
                   Write-Host "$Item  <Open>   tcp    $_" -ForegroundColor Green  -BackgroundColor Black
                }

                $MhsfsCounter++
                #ServiceName associated with port number
                If($_ -Match '^(20|21)$')
                {
                   $Service = "FTP"
                }
                ElseIf($_ -eq 22)
                {
                   $Service = "SSH"                
                }
                ElseIf($_ -eq 23)
                {
                   $Service = "TELNET"                
                }
                ElseIf($_ -eq 53)
                {
                   $Service = "DNS"                
                }
                ElseIf($_ -eq 80)
                {
                   $Service = "HTTP"                
                }
                ElseIf($_ -eq 107)
                {
                   $Service = "RTELNET"                
                }
                ElseIf($_ -eq 110)
                {
                   $Service = "POP3"                
                }
                ElseIf($_ -eq 111)
                {
                   $Service = "SUN_RPC"                
                }
                ElseIf($_ -eq 135)
                {
                   $Service = "EPMAP"                
                }
                ElseIf($_ -Match '^(137|139)$')
                {
                   $Service = "NETBIOS"                
                }
                ElseIf($_ -eq 443)
                {
                   $Service = "HTTPS"                
                }
                ElseIf($_ -eq 445)
                {
                   $Service = "SMB"                
                }
                ElseIf($_ -eq 995)
                {
                   $Service = "POP3S"                
                }
                ElseIf($_ -eq 989)
                {
                   $Service = "FTP_TLS/SSL"                
                }
                ElseIf($_ -eq 1080)
                {
                   $Service = "SOCKS"                
                }
                ElseIf($_ -eq 1433)
                {
                   $Service = "MSSQL"                
                }
                ElseIf($_ -eq 2049)
                {
                   $Service = "NFS"                
                }
                ElseIf($_ -eq 3128)
                {
                   $Service = "SQUID"                
                }
                ElseIf($_ -eq 3306)
                {
                   $Service = "MySQL"                
                }
                ElseIf($_ -eq 3389)
                {
                   $Service = "RDP"                
                }
                ElseIf($_ -eq 5222)
                {
                   $Service = "XMPP"                
                }
                ElseIf($_ -eq 5900)
                {
                   $Service = "VNC"                
                }
                ElseIf($_ -eq 8080)
                {
                   $Service = "APACHE"                
                }
                Else
                {
                   $Service = "Unknown"                
                }

                #Write results to DataTable
                $Finaltable.Rows.Add("$Item","Open","tcp","$_","$Service","$DnsRawName")|Out-Null

             }
             Else
             {

                #Closed port detected ..
                If($OutPut -ieq "verbose")
                {
                   <#
                   .SYNOPSIS
                      Author: @r00t-3xp10it
                      Helper - Displays Open \ Closed ports if invoked -output 'verbose'
                   #>

                   If($Egg -ieq "false")
                   {
                      Write-Host "$Item  Closed   tcp    $_" -ForegroundColor Red  -BackgroundColor Black
                   }

                   #ServiceName associated with port number
                   If($_ -Match '^(20|21)$')
                   {
                      $Service = "FTP"
                   }
                   ElseIf($_ -eq 22)
                   {
                      $Service = "SSH"                
                   }
                   ElseIf($_ -eq 23)
                   {
                      $Service = "TELNET"                
                   }
                   ElseIf($_ -eq 53)
                   {
                      $Service = "DNS"                
                   }
                   ElseIf($_ -eq 80)
                   {
                      $Service = "HTTP"                
                   }
                   ElseIf($_ -eq 107)
                   {
                      $Service = "RTELNET"                
                   }
                   ElseIf($_ -eq 110)
                   {
                      $Service = "POP3"                
                   }
                   ElseIf($_ -eq 111)
                   {
                      $Service = "SUN_RPC"                
                   }
                   ElseIf($_ -eq 135)
                   {
                      $Service = "EPMAP"                
                   }
                   ElseIf($_ -Match '^(137|139)$')
                   {
                      $Service = "NETBIOS"                
                   }
                   ElseIf($_ -eq 443)
                   {
                      $Service = "HTTPS"                
                   }
                   ElseIf($_ -eq 445)
                   {  
                      $Service = "SMB"                
                   }
                   ElseIf($_ -eq 995)
                   {
                      $Service = "POP3S"                
                   }
                   ElseIf($_ -eq 989)
                   {
                      $Service = "FTP_TLS/SSL"                
                   }
                   ElseIf($_ -eq 1080)
                   {
                      $Service = "SOCKS"                
                   }
                   ElseIf($_ -eq 1433)
                   {
                      $Service = "MSSQL"                
                   }
                   ElseIf($_ -eq 2049)
                   {
                      $Service = "NFS"                
                   }
                   ElseIf($_ -eq 3128)
                   {
                      $Service = "SQUID"                
                   }
                   ElseIf($_ -eq 3306)
                   {
                      $Service = "MySQL"                
                   }
                   ElseIf($_ -eq 3389)
                   {
                      $Service = "RDP"                
                   }
                   ElseIf($_ -eq 5222)
                   {
                      $Service = "XMPP"                
                   }
                   ElseIf($_ -eq 5900)
                   {
                      $Service = "VNC"                
                   }
                   ElseIf($_ -eq 8080)
                   {
                      $Service = "APACHE"                
                   }
                   Else
                   {
                      $Service = "Unknown"                
                   }

                   #Write results to DataTable
                   $Finaltable.Rows.Add("$Item","Closed","tcp","$_","$Service","$DnsRawName")|Out-Null
                }

             }

          }## End of Foreach-Object{}
      }## End of ForEach()


      Clear-Host;
      Start-Sleep -Milliseconds 1458
      #Parse DataTable data onscreen (console)
      Write-Host "`n* Scanning Lan for active devices!" -ForegroundColor DarkMagenta -BackgroundColor DarkCyan;
      $CheckTableRows = $Finaltable | Format-Table #Check if Table contains any data!
      If(-not($CheckTableRows))
      {

         #None Open ports found ..
         $Finaltable.Rows.Add("none open","ports","found","using","the sellected","syntax!")|Out-Null
         $Finaltable | Format-Table -AutoSize | Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1 | ForEach-Object {
            $stringformat = If($_ -Match '^(RemoteHost)')
            {
               @{ 'ForegroundColor' = 'Green' }
            }
            ElseIf($_ -Match 'none')
            {
               @{ 'ForegroundColor' = 'Red'; 'BackGroundColor' = 'Black' }             
            }
            Else
            {
               @{ 'ForegroundColor' = 'White' }
            }
            Write-Host @stringformat $_
         }

      }
      Else
      {

         #Found Open ports
         $Finaltable | Format-Table -AutoSize | Out-String -Stream | Select-Object -Skip 1 | Select-Object -SkipLast 1 | ForEach-Object {
            $stringformat = If($_ -Match '^(RemoteHost)')
            {
               @{ 'ForegroundColor' = 'Green' }
            }
            ElseIf($_ -iMatch 'Open')
            {
               @{ 'ForegroundColor' = 'Green' }             
            }
            Else
            {
               @{ 'ForegroundColor' = 'White' }
            }
            Write-Host @stringformat $_
         }
      }

      #Display OnScreen the total number of open ports found!
      Write-Host "`n* Total of open ports:" -ForegroundColor Blue -BackgroundColor Black -NoNewline;
      Write-Host "$MhsfsCounter" -ForegroundColor Green -BackgroundColor Black;


      If($logfile -ieq "True")
      {
         <#
         .SYNOPSIS
            Author: @r00t-3xp10it
            Helper - Store active ip addreses to logfile!
         #>

         $StdOutTable = $Finaltable | Format-Table -AutoSize
         echo $StdOutTable >> "$Env:TMP\$Rand.log"
         Write-Host "* Logfile:" -ForegroundColor Blue -BackgroundColor Black -NoNewline;
         Write-Host "'$Env:TMP\$Rand.log'" -ForegroundColor Green -BackgroundColor Black;
      }

   }
}


#Internal clock Timmer
$ElapsTime = $(Get-Date) - $ScanStartTimer
If($Action -ieq "Enum"){$ScanType = "discovery"}
$TotalTime = "{0:HH:mm:ss}" -f ([datetime]$ElapsTime.Ticks) #Count the diferense between 'start|end' scan duration!
Write-Host "* ElapsedTime:" -ForegroundColor Blue -BackgroundColor Black -NoNewline;
Write-Host "$TotalTime" -ForegroundColor Green -BackgroundColor Black -NoNewline;
Write-Host " - scantype:" -ForegroundColor Blue -BackgroundColor Black -NoNewline;
Write-Host "$ScanType" -ForegroundColor Green -BackgroundColor Black -NoNewline;

If($logfile -ieq "True")
{
   #Writting the elapsed scan time inside logfile!
   echo "* Total of open ports:$MhsfsCounter" >> "$Env:TMP\$Rand.log"
   echo "* ElapsedTime:$TotalTime - scantype:$ScanType" >> "$Env:TMP\$Rand.log"
}

#Cleanning artifacts left behind!
If(Test-Path -Path "$Env:TMP\iprange.log"){Remove-Item -Path "$Env:TMP\iprange.log" -Force}
exit