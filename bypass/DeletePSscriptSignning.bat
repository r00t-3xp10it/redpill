@echo off
::   Author:
::      @r00t-3xp10it
::
::   Description:
::      Delete Certificates from store
:: --
title Delete Certs from store


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

echo [ exec  ]: Deleting 'SsaRedTeam' (FriendlyName) Certificate from Cert Store ..
powershell $List = @('Root','My');ForEach($Item in $List){Get-ChildItem Cert:\LocalMachine\$Item ^| Where-Object {$_.Issuer -match 'My_Code_Signing_Certificate'} ^| Remove-Item}
# powershell Get-ChildItem Cert:\LocalMachine\Root ^| Where-Object {$_.Issuer -match 'My_Code_Signing_Certificate'} ^| Remove-Item
