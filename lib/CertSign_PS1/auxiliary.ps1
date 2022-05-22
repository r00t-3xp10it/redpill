<#
.SYNOPSIS
   Auxiliary script of PSscriptSigning.bat

   Author: @r00t-3xp10it (ssa redteam)
   Tested Under: Windows 10 (19043) x64 bits

.DESCRIPTION
   This cmdlet allow users to check if all dependencies required by PSscriptSigning
   batch script are present before running PSscriptSigning.bat. It also enumerates
   the certificate store after PSscriptSigning.bat script execution, and executes
   calc.exe in the end as POC ( that proffs this cmdlet as been executed ) ..
   
.NOTES
   This cmdlet can be signed by PSscriptSigning.bat to serve as POC

.EXAMPLE
   PS C:\> (IEX(IWR -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/CertSign_PS1/auxiliary.ps1"))
   Test if PSscriptSigning.bat dependencies are satisfied

.EXAMPLE
   PS C:\> .\PSscriptSigning.bat
#>


#Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
write-host "`n* Auxiliary script of PSscriptSigning.bat" -ForegroundColor Green
Start-Sleep -Seconds 1


#Check shell privileges
$bool = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544");
If($bool)
{
   write-host "  + shellprivileges: Admin        [correct privileges hold]" -ForegroundColor Green
}
Else
{
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "shellprivileges: " -ForegroundColor DarkGray -NoNewline 
   write-host "User Land" -ForegroundColor Red -NoNewline
   write-host "    [wrong privileges hold]" -ForegroundColor DarkGray 
}


#Check Executionpolicy settings
$GetUserPolicy = Get-ExecutionPolicy -Scope CurrentUser
If($GetUserPolicy -iMatch "(AllSigned|RemoteSigned)")
{
   write-host "  + ExecutionPolicy: $GetUserPolicy [correct policy set]" -ForegroundColor Green
}
Else
{
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "ExecutionPolicy: " -ForegroundColor DarkGray -NoNewline 
   write-host "$GetUserPolicy" -ForegroundColor Red -NoNewline
   write-host " [wrong policy set]" -ForegroundColor DarkGray 
}


Start-Sleep -Seconds 1
#Check if lanmanserver (admin) its running
If((Get-Service -Name LanmanServer).Status -ieq "Running")
{
   write-host "  + service        : LanmanServer [running]" -ForegroundColor Green
}
Else
{
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "service        : " -ForegroundColor DarkGray -NoNewline 
   write-host "LanmanServer" -ForegroundColor Red -NoNewline
   write-host " [not running]" -ForegroundColor DarkGray     
}


Start-Sleep -Seconds 1
#Check if certificate exists
$CheckCert = Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Issuer -match "My_Code_Signing_Certificate"}
If($CheckCert)
{
   write-host "  + certificate    : My_Code_Signing_Certificate [found]`n" -ForegroundColor Green
   echo $CheckCert
   write-host ""

   Start-Sleep -Seconds 1
   #Executes calc as execution POC
   write-host "* Executing: calc.exe as execution POC" -ForegroundColor Green
   Start-Process calc.exe
}
Else
{
   write-host "  x " -ForegroundColor Red -NoNewline
   write-host "certificate    : " -ForegroundColor DarkGray -NoNewline 
   write-host "My_Code_Signing_Certificate" -ForegroundColor Red -NoNewline
   write-host " [not found]" -ForegroundColor DarkGray
   write-host "* Executing: exit cmdlet execution .." -ForegroundColor Green
}
