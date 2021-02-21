@echo off
title Delete Certs from store


:: Test for shell permissions
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [success]: Administrative permissions confirmed.
) else (
    color 04
    echo [failure]: Current permissions inadequate.
    timeout /T 4 >nul
    exit
)

echo [i] Reverting %userdomain% to Previous State.
timeout /T 3 >nul
echo [i] Deleting 'SsaRedTeam' (FriendlyName) Certificate from Cert Store ..
powershell Get-ChildItem Cert:\LocalMachine\Root ^| Where-Object {$_.Issuer -match 'My_Code_Signing_Certificate'}
powershell Get-ChildItem Cert:\LocalMachine\Root ^| Where-Object {$_.Issuer -match 'My_Code_Signing_Certificate'} ^| Remove-Item