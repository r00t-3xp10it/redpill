<#
.SYNOPSIS
   Enumerate\Read\DeleteAll eventvwr logfiles!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: wevtutil, UacMe.ps1
   PS cmdlet Dev version: v1.5.22

.DESCRIPTION
   This cmdlet allow users to delete ALL eventvwr logfiles or to delete
   all of the logfiles from the sellected categorie { -verb 'event path' }.
   It also enumerates major categories logfiles counter { -GetLogs 'Enum' }
   to help attacker identify if the logs have been successfuly deleted. To
   further forensics investigation we can use the { -GetLogs 'yara' } @arg
   that allow users to display the contents of the sellected logfiles.

.NOTES
   Required Dependencies: wevtutil {native}
   To list multiple Id's then split the numbers by a [,] char!
   Example: .\GetLogs.ps1 -GetLogs Yara -Id "59,60,300,400,8002"
   If none -ID or -VERB paramets are used together with 'YARA' @argument,
   then this cmdlet will start scan pre-defined event paths and ID's numbers!

.Parameter GetLogs
   Accepts arguments: Enum, Verbose, Yara, DeleteAll, Paranoid

.Parameter NewEst
   How many event logs to display int value (default: 3)

.Parameter Id
   List logfiles by is EventID number identifier!

.Parameter Verb
   Accepts 'ONE' Eventvwr path to be scanned\Deleted!

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Enum
   Lists ALL eventvwr categorie entrys

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Verbose
   List newest 3 (default) Powershell\Application\System entrys

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Verbose -NewEst 8
   List newest 8 Powershell\Application\System entrys

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Yara -NewEst 28
   List newest 28 logs using cmdlet default Id's and categories!

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Yara -NewEst 13 -Id 59
   List newest 13 logfiles with Id: 59 using cmdlet default categories!

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Yara -verb "system" -Id 1 -NewEst 10
   List newest 10 logfiles of 'system' categorie with id: 1

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Yara -Verb "Microsoft-Windows-NetworkProfile/Operational" -id 10001
   List newest 3 (default) logfiles of 'NetworkProfile/Operational' categorie with Id: 10001

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs DeleteAll
   Delete ALL eventvwr (categories) logs from snapIn!

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Paranoid
   Delete ALL eventvwr (categories) logs from snapIn (verbose)

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs DeleteAll -Verb "Microsoft-Windows-Powershell/Operational"
   Delete ONLY logfiles from "Microsoft-Windows-Powershell/Operational" eventvwr categorie!

.INPUTS
   None. You cannot pipe objects to GetLogs.ps1

.OUTPUTS
   LogMode  MaximumSizeInBytes RecordCount LogName
   -------  ------------------ ----------- -------
   Circular           15728640        3978 Windows PowerShell
   Circular           20971520        1731 System
   Circular            1052672           0 Internet Explorer
   Circular           20971520        1122 Application
   Circular            1052672        1729 Microsoft-Windows-WMI-Activity/Operational
   Circular            1052672         520 Microsoft-Windows-Windows Defender/Operational
   Circular           15728640         719 Microsoft-Windows-PowerShell/Operational
   Circular            1052672         499 Microsoft-Windows-Bits-Client/Operational
   Circular            1052672           0 Microsoft-Windows-AppLocker/EXE and DLL

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://support.sophos.com/support/s/article/KB-000038860?language=en_US
   https://info.rocketcyber.com/blog/10-windows-security-events-you-need-to-monitor
   https://community.sophos.com/sophos-labs/b/blog/posts/powershell-command-history-forensics
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$GetLogs="Enum",
   [string]$Verb="False",
   [string]$Id="False",
   [int]$NewEst='3'
)


Write-Host ""
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")


If($GetLogs -ieq "Enum")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - List Major eventvwr categorie entrys!

   .DESCRIPTION
      List Major categorie logs and respective number of entrys!

   .Parameter GetLogs
      Accepts argument: Enum

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Enum
      Lists Major eventvwr categorie entrys

   .OUTPUTS
      LogMode  MaximumSizeInBytes RecordCount LogName
      -------  ------------------ ----------- -------
      Circular           15728640          14 Windows PowerShell                            
      Circular           20971520           7 System                                        
      Circular            1052672           0 Internet Explorer                             
      Circular           20971520           0 Application                                   
      Circular            1052672           2 Microsoft-Windows-WMI-Activity/Operational    
      Circular            1052672           0 Microsoft-Windows-Windows Defender/WHC        
      Circular            1052672           0 Microsoft-Windows-Windows Defender/Operational
      Circular            1052672           0 Microsoft-Windows-UAC/Operational             
      Circular           15728640           4 Microsoft-Windows-PowerShell/Operational      
      Circular            1052672           0 Microsoft-Windows-DeviceGuard/Operational     
      Circular            1052672          22 Microsoft-Windows-Bits-Client/Operational     
      Circular            1052672           0 Microsoft-Windows-AppLocker/EXE and DLL
   #>

   Write-Host "`n[+] Please Wait, Scanning Eventvwr registry! .." -ForegroundColor Green;Start-Sleep -Milliseconds 700
   $regex = "system|security|application|windows powershell|Internet Explorer|Microsoft-Windows-UAC/Operational|Microsoft-Windows-WMI-Activity/Operational|Microsoft-Windows-Applocker/EXE and DLL|Microsoft-Windows-PowerShell/Operational|Microsoft-Windows-Bits-Client/Operational|Microsoft-Windows-Windows Defender/Operational|Microsoft-Windows-Windows Defender/WHC|Microsoft-Windows-DeviceGuard/Operational"

   ## List Major event logs categories and the number of entries!
   # [shanty] Deprecated: Get-EventLog -List | Format-Table -AutoSize
   Get-WinEvent -ListLog * -ErrorAction Ignore | Where-Object {
      $_.LogName -iMatch "^($regex)$" } | Format-Table -AutoSize |
         Out-String -Stream | ForEach-Object {
            $stringformat = If($_ -Match '\s+(0|1)+\s'){
               @{ 'ForegroundColor' = 'Green' } }Else{ @{} }
            Write-Host @stringformat $_
         }

}


If($GetLogs -ieq "Verbose")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - List Powershell \ Application \ System entrys verbose!

   .DESCRIPTION
      This function allow users to return a sellected (-NewEst) number
      of logfiles on 'Powershell', 'Applications' and 'system' registry
      categories paths with 'EventID,EntryType,Source,Message' Propertys!

   .Parameter GetLogs
      Accepts argument: Verbose

   .Parameter NewEst
      How many event logs to display int value (default: 3)

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Verbose
      List newest 3 (default) Powershell\Application\System entrys

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Verbose -NewEst 28
      List newest 28 Eventvwr Powershell\Application\System entrys

   .OUTPUTS
      enabled: true
      name: Windows Powershell
      logFileName: %SystemRoot%\System32\Winevt\Logs\Windows Powershell.evtx

      EventID EntryType   Source     Message                                                                                                          
      ------- ---------   ------     -------                                                                                                          
          400 Information PowerShell Provider "WSMan" is Started. ...                                                                                 
          600 Information PowerShell Provider "Certificate" is Started. ...                                                                           
          600 Information PowerShell Engine state is changed from None to Available. ...                                                              
          600 Information PowerShell Provider "Variable" is Started. ...                                                                              
          600 Information PowerShell Provider "Function" is Started. ...                                                                              
          403 Information PowerShell Provider "FileSystem" is Started. ...                                                                            
          600 Information PowerShell Provider "Environment" is Started. ...                                                                           
          600 Information PowerShell Provider "Alias" is Started. ...                                                                                 
          324 Information PowerShell Provider "Registry" is Started. ...                                                                              
          600 Information PowerShell Engine state is changed from Available to Stopped. ... 
   #>

   Write-Host "`n[+] Please Wait, Scanning Eventvwr registry! .." -ForegroundColor Green;Start-Sleep -Milliseconds 700
   $regex = "system|security|application|windows powershell|Internet Explorer|Microsoft-Windows-UAC/Operational|Microsoft-Windows-WMI-Activity/Operational|Microsoft-Windows-Applocker/EXE and DLL|Microsoft-Windows-PowerShell/Operational|Microsoft-Windows-Bits-Client/Operational|Microsoft-Windows-Windows Defender/Operational|Microsoft-Windows-Windows Defender/WHC|Microsoft-Windows-DeviceGuard/Operational"

   ## List Major event logs categories and the number of entries!
   # [shanty] Deprecated: Get-EventLog -List | Format-Table -AutoSize
   Get-WinEvent -ListLog * -ErrorAction Ignore | Where-Object {
      $_.LogName -iMatch "($regex)$" -and $_.LogName -iNotMatch 'Microsoft-Windows-Windows Firewall With Advanced Security/ConnectionSecurity' } | Format-Table -AutoSize |
         Out-String -Stream | ForEach-Object {
            $stringformat = If($_ -iMatch '\s+(Windows PowerShell|application|system|security)\s+'){
               @{ 'ForegroundColor' = 'Yellow' } }Else{ @{} }
            Write-Host @stringformat $_
         }

   Start-Sleep -Seconds 1
   If($NewEst -lt "1" -or $NewEst -gt "80")
   {
      ## Set the max\min number of logfiles to display!
      write-host "x " -ForegroundColor Red -NoNewline
      Write-Host "Error: not optimal -newest '$NewEst', defaulting to [3] .." -ForegroundColor DarkGray
      Start-Sleep -Seconds 1;$NewEst = "3"
   }

   $Categories = @(
      "Windows Powershell",
      "Application",
      "System"
   )

   If($IsClientAdmin)
   {
      ## Add 'security' categorie to categories list
      # if the cmdlet was executed under Admin privs!
      $Categories += "Security"
   }


   ForEach($Item in $Categories)
   {

      ## Local function Variable declarations!
      $SysLogCatg = wevtutil gl "$Item" | findstr /I /C:"name"
      $SysLogCatg = $SysLogCatg | findstr /V "logFileName:"
      $SysLogStat = wevtutil gl "$Item" | findstr /I "enabled"
      $SysLogFile = wevtutil gl "$Item" | findstr /I "logFileName"

      ## Delete Empty spaces in beggining and End of string
      $SysLogFile = $SysLogFile -replace '(^\s+|\s+$)',''

      Write-Host "`n$SysLogStat"
      Write-Host "$SysLogCatg" -ForegroundColor Green
      $Log = Get-WinEvent -LogName "$Item" -EA SilentlyContinue | Select-Object -First 1

      If($? -ieq $False)
      {
         Write-Host "$SysLogFile" ## $LASTEXITCODE return $False => NO logs!
         write-host "x " -ForegroundColor Red -NoNewline
         Write-Host "Error: " -ForegroundColor DarkGray -NoNewline
         Write-Host "None Eventvwr Entries found under $Item!" -ForegroundColor Red
      }
      Else
      {
         ## [shanty] Deprecated: Get-EventLog -List | Format-Table -AutoSize
         Write-Host "$SysLogFile" ## $LASTEXITCODE return $True => Logs present!
         Get-WinEvent -LogName "$Item" -EA SilentlyContinue | Select-Object -First $NewEst |
            Select-Object -Property Id,TimeCreated,ProviderName,ContainerLog,Message | Format-Table -AutoSize
      }
   }

}


If($GetLogs -ieq "Yara")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - List eventvwr logfiles by is Id number!

   .DESCRIPTION
      This function searchs for logfiles by is Id identifier number on
      'Windows Powershell', 'PowerShell/Operational' and 'Bits-Client'
      registry paths with 'Id,ContainerLog,TimeCreated,Message' Propertys!

   .NOTES
      To list multiple Id's then split the numbers by a [,] char!
      Example: .\GetLogs.ps1 -GetLogs Yara -Id "59,60,300,400,8002"
      If none ID or VERB paramets are used together with 'YARA' @argument,
      then this cmdlet will scan pre-defined event paths and ID's numbers!

   .Parameter GetLogs
      Accepts argument: Yara

   .Parameter NewEst
      How many event logs to display int value (default: 3)

   .Parameter Id
      List logfiles by is EventID number!

   .Parameter Verb
      Accepts 'ONE' Eventvwr registry path to be scanned! 

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Yara -NewEst 28
      List newest 28 logs using cmdlet default Id's and categories!

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Yara -NewEst 13 -Id 59
      List newest 13 logfiles with Id: 59 using cmdlet default categories!

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Yara -verb "system" -Id 1 -NewEst 10
      List newest 10 logfiles of 'system' categorie with id: 1

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Yara -Verb "Microsoft-Windows-NetworkProfile/Operational" -id 10001
      List newest 3 (default) logfiles of 'NetworkProfile/Operational' categorie with Id: 10001

   .OUTPUTS
      Id           : 403
      TimeCreated  : 10/05/2021 19:05:29
      ContainerLog : Windows Powershell
      Message      : Engine state is changed from Available to Stopped. 
              
                     Details: 
                   	 NewEngineState=Stopped
              	     PreviousEngineState=Available
              
              	     SequenceNumber=17
              
              	     HostName=ConsoleHost
              	     HostVersion=5.1.19041.906
              	     HostId=1b4fd01f-3d4e-4647-85bc-767e006a3f55
              	     HostApplication=C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -File 
                     C:\Users\pedro\AppData\Local\Temp\sysinfo.ps1 -SysInfo Verbose -HideMyAss false
              	     EngineVersion=5.1.19041.906
              	     RunspaceId=16168df0-b9cb-48b1-9c13-bd7885d30746
              	     PipelineId=
              	     CommandName=
              	     CommandType=
              	     ScriptName=
              	     CommandPath=
              	     CommandLine=
   #>

   ## Local function variable declarations!
   # Set the min number of logs to be displayed!
   If($NewEst -lt "1"){$NewEst = "3"}

   ## Categories list!
   $Categories = @(
      "system",
      "Windows Powershell",
      "Microsoft-Windows-UAC/Operational",
      "Microsoft-Windows-NTLM/Operational",
      "Microsoft-Windows-Windows Defender/WHC",
      "Microsoft-Windows-Applocker/EXE and DLL",
      "Microsoft-Windows-PowerShell/Operational",
      "Microsoft-Windows-Bits-Client/Operational",
      "Microsoft-Windows-WMI-Activity/Operational",
      "Microsoft-Windows-Windows Defender/Operational",
      "Microsoft-Windows-DeviceGuard/Operational"
   )    

   ## User Eventvwr Registry Path Input! (easter egg)
   # If sellected -verb "Microsoft-Windows-NetworkProfile/Operational" (or other path)
   # then the registry path will be appended to the default $Categories List and scanned!
   # WARNING: Some Eventvwr Registry Paths require administrator privileges to list entrys!
   Write-Host "`n[+] Please Wait, Scanning Eventvwr registry! .." -ForegroundColor Green

   Start-Sleep -Milliseconds 700
   If($Verb -ne "False")
   {

      If($Categories -NotContains "$Verb")
      {

         If($Id -eq "False")
         {
            write-host "x " -ForegroundColor Red -NoNewline
            Write-Host "Error: " -ForegroundColor DarkGray -NoNewline
            Write-Host "Missing -id 'int' input, using cmdlet default ID's" -ForegroundColor Red
         }

         Write-Host "[" -ForegroundColor Yellow -NoNewline
         Write-Host "WARNING" -ForegroundColor Red -NoNewline
         Write-Host "]: Some Eventvwr paths migth require admin privs to list entrys!" -ForegroundColor Yellow
         Write-Host "Appending: '" -ForegroundColor DarkYellow -NoNewline
         Write-Host "$Verb" -ForegroundColor DarkGray -NoNewline
         Write-Host "' to GetLogs Scan List!`n" -ForegroundColor DarkYellow
         $Categories += "$Verb" ## <-- Append User entry to GetLogs Default Scan List!
         Write-Host "GetLogs Scan List!" -ForegroundColor Green
         Write-Host "------------------";echo $Categories

      }
      Else
      {
         If($Id -eq "False")
         {
            write-host "x " -ForegroundColor Red -NoNewline
            Write-Host "Error: " -ForegroundColor DarkGray -NoNewline
            Write-Host "Missing -id 'int' input, using cmdlet default ID's" -ForegroundColor Red
         }
                
         ## [error] User Input present in Categories List!
         write-host "x " -ForegroundColor Red -NoNewline
         Write-Host "Error: " -ForegroundColor DarkGray -NoNewline
         Write-Host "-verb '" -ForegroundColor Red -NoNewline
         Write-Host "$verb" -ForegroundColor DarkGray -NoNewline
         Write-Host "' exists in database, using cmdlet default List!" -ForegroundColor Red
         Write-Host "`nGetLogs Scan List!" -ForegroundColor Green
         Write-Host "------------------";echo $Categories
      }
   }


   If($verb -ieq "system" -or $verb -ieq "application" -or $Verb -ieq "security")
   {
   
      If($Verb -ieq "security" -and $IsClientAdmin -eq $False)
      {
         ## Administrator privileges required to list 'security' categorie!
         write-host "x " -ForegroundColor Red -NoNewline
         Write-Host "Error: " -ForegroundColor DarkGray -NoNewline
         Write-Host "Administrator privs required to list 'security' categorie!`n" -ForegroundColor Red
         exit ## Exit @GetLogs
      }


      If($Id -Match ',')
      {
         ## Split Id's separated by [,] char!
         $IdList = $Id.Split(',')
      }
      ElseIf($Id -ieq "false")
      {
         If($verb -ieq "system")
         {
            ## Default Id's to scan! (if none user inputs)
            # ID: 1,19,43,104,1102,4663,7000 -> system
            $RawLit = "1,19,43,104,1102,4663,7000"
            $IdList = $RawLit.Split(',')
         }
         ElseIf($verb -ieq "application")
         {
            ## Default Id's to scan! (if none user inputs)
            # ID: 105,326,333,1000,1001 -> application
            $RawLit = "105,326,333,1000,1001"
            $IdList = $RawLit.Split(',')
         }
         ElseIf($verb -ieq "security")
         {
            ## Default Id's to scan! (if none user inputs)
            # 3,4624,4625,4672,4688  -> security
            $RawLit = "3,4624,4625,4672,4688"
            $IdList = $RawLit.Split(',')
         }

      }
      Else
      {
         ## User input Id (only one ID number)
         $IdList = $Id
      }

      ## Loop trougth all Id numbers!
      ForEach($IdToken in $IdList)
      {

         Get-WinEvent -LogName "$verb" -EA SilentlyContinue | Where-Object {
            $_.Id -eq $IdToken -and $_.Message -iNotMatch '^(Video.UI)' -and
            $_.ProviderName -iNotMatch '(Microsoft-Windows-Power-Troubleshooter|Microsoft-Windows-FilterManager)'
            } | Select-Object -Property Id,TimeCreated,ProviderName,ContainerLog,Message -First $NewEst |
            Format-List | Out-String -Stream | ForEach-Object {
               $stringformat = If($_ -iMatch '^(ContainerLog :)'){
                  @{ 'ForegroundColor' = 'Yellow' } }Else{ @{} }
               Write-Host @stringformat $_
            }

      }

   }
   Else
   {

      If($Id -Match ',')
      {
         ## Split Id's separated by [,] char!
         $IdList = $Id.Split(',')
      }
      ElseIf($Id -ieq "false")
      {

         ## Default Id's to scan! (if none user inputs)
         # ID: 403,4100            -> POWERSHELL/OPERATIONAL
         # ID: 300,403,4104        -> WINDOWS POWERSHELL
         # ID: 59,60               -> BITS
         # ID: 1116,1117,5007      -> Windows Defender
         # ID: 800,8002,8004       -> Applocker/exe and dll
         # ID: 5858,5861           -> WMI
         # ID: 1,104               -> system
         # ID: 8004                -> NTLM/Operational
         $RawLit = "1,59,60,104,300,403,800,1116,1117,4100,4104,5007,5858,5861,8002,8004"
         $IdList = $RawLit.Split(',')

      }
      Else
      {
         ## User input Id (only one ID number)
         $IdList = $Id
      }


      ## Loop trougth all Id numbers!
      ForEach($IdToken in $IdList)
      {

         ## Loop trougth all categories!
         ForEach($CatList in $Categories)
         {

            If($IdToken -eq "5861")
            {
            
               ## sigma_rule_credits: @mattifestation
               # https://twitter.com/mattifestation/status/899646620148539397
               Get-WinEvent -LogName "$CatList" -EA SilentlyContinue | Where-Object {
                  $_.Id -eq $IdToken -and $_.Message -iMatch '(CommandLineTemplate)+\s+(=)' -and
                  $_.LevelDisplayName -iMatch '^(Erro|Error|Aviso|Warning|Informações|Information)$'
                  } | Select-Object -Property Id,TimeCreated,ProviderName,ContainerLog,Message -First $NewEst |
                  Format-List | Out-String -Stream | ForEach-Object {
                     $stringformat = If($_ -iMatch '^(ContainerLog :)'){
                        @{ 'ForegroundColor' = 'Yellow' } }Else{ @{} }
                     Write-Host @stringformat $_
                  }

            }
            Else
            {

               $regex = "Microsoft-Windows-Power-Troubleshooter|Microsoft-Windows-FilterManager|Microsoft-Windows-Diagnostics-Networking"
               Get-WinEvent -LogName "$CatList" -EA SilentlyContinue | Where-Object {
                  $_.Id -eq $IdToken -and $_.Message -iNotMatch '(hardware clock|svchost.exe|.img.|.json.|.png.|.jpg.|^Creating Scriptblock)' -and
                  $_.LevelDisplayName -iMatch '^(Erro|Error|Aviso|Warning|Informações|Information)$' -and $_.ProviderName -iNotMatch "^($regex)$"
               } | Select-Object -Property Id,TimeCreated,ProviderName,ContainerLog,Message -First $NewEst |
               Format-List | Out-String -Stream | ForEach-Object {
                  $stringformat = If($_ -iMatch '^(ContainerLog :)'){
                     @{ 'ForegroundColor' = 'Yellow' } }Else{ @{} }
                  Write-Host @stringformat $_
               }

            }

         }

      }
   
   }

}


If($GetLogs -ieq "DeleteAll" -or $GetLogs -ieq "Paranoid")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Clear 'ALL' eventvwr logfiles!

   .DESCRIPTION
      Loops trougth ALL eventvwr logfiles to delete them!

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs DeleteAll
      Delete ALL logfiles from eventvwr snapIn!

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs DeleteAll -Verb "Microsoft-Windows-Powershell/Operational"
      Delete ONLY logfiles from "Microsoft-Windows-Powershell/Operational" eventvwr categorie!
   #>

   Write-Host "`n[+] Please Wait, Deleting Eventvwr logfiles! .." -ForegroundColor Green
   Start-Sleep -Milliseconds 700
   If(-not($IsClientAdmin))
   {
      write-host "`nx " -ForegroundColor Red -NoNewline
      Write-Host "Error: " -ForegroundColor DarkGray -NoNewline
      Write-Host "Administrator privileges required!`n" -ForegroundColor Red
      exit
   }
   Else
   {

      <#
      .NOTES
         This function only triggers under 'Administrator' privileges!

      .DESCRIPTION
         This function uses wevtutil to delete logs from ALL categories
         or simple to delete all logfiles from user sellected categorie!
      #>

      ## Clear Event Logs
      Write-Host "[i] Shell - Administrator privileges: [" -ForegroundColor Yellow -NoNewline
      Write-Host "True" -ForegroundColor Green -NoNewline
      Write-Host "]" -ForegroundColor Yellow
      Write-Host "[+] Cleaning: '$Env:COMPUTERNAME\$Env:USERNAME' Eventvwr logfiles.." -ForeGroundColor Green

      If($Verb -ne "False")
      {
         $regex = "$Verb"
         wevtutil cl "$Verb"
      }
      Else
      {

         If($GetLogs -ieq "Paranoid")
         {
            Start-Sleep -Seconds 1;write-host ""
            wevtutil el | Where-Object {
               $_ -iNotMatch '^(Microsoft-Windows-LiveId/Analytic|Microsoft-Windows-LiveId/Operational|Microsoft-Windows-USBVideo/Analytic|Windows Networking Vpn Plugin Platform/Operational|Network Isolation Operational|Microsoft-Windows-Wordpad/Admin|Microsoft-Windows-wmbclass/Trace)$'
            } | Foreach-Object { write-host "* " -ForegroundColor Green -NoNewline;write-host "Cleaning" -ForegroundColor DarkGray -NoNewline;write-host ": " -ForegroundColor Red -NoNewline;write-host "$_";wevtutil cl "$_" }
            $regex = "[a-z A-Z]"
         }
         Else
         {
            wevtutil el | Where-Object {
               $_ -iNotMatch '^(Microsoft-Windows-LiveId/Analytic|Microsoft-Windows-LiveId/Operational|Microsoft-Windows-USBVideo/Analytic)$'
            } | Foreach-Object { wevtutil cl "$_" }
            $regex = "^(system|security|application|windows powershell|Internet Explorer|Microsoft-Windows-UAC/Operational|Microsoft-Windows-WMI-Activity/Operational|Microsoft-Windows-Applocker/EXE and DLL|Microsoft-Windows-PowerShell/Operational|Microsoft-Windows-Bits-Client/Operational|Microsoft-Windows-Windows Defender/Operational|Microsoft-Windows-Windows Defender/WHC|Microsoft-Windows-DeviceGuard/Operational)$"         
         }
      }

      write-host "`n+ Done, Quering current eventvwr table .." -ForegroundColor Green
      Start-Sleep -Seconds 2;Clear-Host

      write-host "[*] Current eventvwr entrys .." -ForegroundColor Green
      ## List Major event logs categories and the number of entries!
      # [shanty] Deprecated: Get-EventLog -List | Format-Table -AutoSize
      Get-WinEvent -ListLog * -ErrorAction Ignore | Where-Object {
         $_.LogName -iMatch "$regex" } | Format-Table -AutoSize |
            Out-String -Stream | ForEach-Object {
               $stringformat = If($_ -Match '\s+(0|1)+\s+'){
                  @{ 'ForegroundColor' = 'Green' } }Else{ @{} }
               Write-Host @stringformat $_
            }

   }

}

Write-Host ""