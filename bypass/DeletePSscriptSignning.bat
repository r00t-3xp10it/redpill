@echo off
::   Author:
::      @r00t-3xp10it
::
::   Description:
::      Delete Certificates from store
::
::   Output:
::     [success]: Administrative permissions confirmed.
::     [ exec  ]: Check for certificate existence.
::
::        PSParentPath: Microsoft.PowerShell.Security\Certificate::LocalMachine\Root
::
::     Thumbprint                                Subject
::     ----------                                -------
::     EBE112F56D5FE0BA23289319C89D7784A10CEB61  CN=My_Code_Signing_Certificate 
:: --
title Delete Certificates from store


:: Test for shell permissions
net session >nul 2>&1
IF %errorLevel% == 0 (
    echo [success]: Administrative permissions confirmed.
) else (
    echo [failure]: Current permissions inadequate.
    exit
)

echo [ exec  ]: Check for certificate existence.
powershell $List = @('Root','My');ForEach($Item in $List){Get-ChildItem Cert:\LocalMachine\$Item ^| Where-Object {$_.Issuer -match 'My_Code_Signing_Certificate'}}
timeout /T 3 >nul

echo [ exec  ]: Deleting certificates from cert store ..
powershell $List = @('Root','My');ForEach($Item in $List){Get-ChildItem Cert:\LocalMachine\$Item ^| Where-Object {$_.Issuer -match 'My_Code_Signing_Certificate'} ^| Remove-Item}
:: powershell Get-ChildItem Cert:\LocalMachine\Root ^| Where-Object {$_.Issuer -match 'My_Code_Signing_Certificate'} ^| Remove-Item
