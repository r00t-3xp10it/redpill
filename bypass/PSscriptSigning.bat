@echo off
::
::   Description:
::      Digitally sign (certlm) one cmdlet.
::      Author: @r00t-3xp10it
:: ---
title Signning (certlm) ONE powerShell cmdlet


echo .
:: Test for shell admin permissions
net session >nul 2>&1
IF %errorLevel% == 0 (
    echo [success]: Administrative permissions confirmed.
) ELSE (
    color 04
    echo [failure]: Current permissions inadequate.
    exit
)

:: Get the PS script (cmdlet) Absoluct Path
SET /p PSsignPath="[ input ]: Input cmdlet absoluct path: "
IF NOT EXIST "%PSsignPath%" (
    color 04
    echo [failure]: Cmdlet '%PSsignPath%' not found.
    exit
)

:: Display settings OnScreen
FOR /F "tokens=*" %%g IN ('powershell -C "(Get-Date).AddMonths(6)"') do (SET ExpiresDate=%%g)
echo _
echo            Certificate information
echo            -----------------------
echo            FriendlyName : SsaRedTeam
echo            CertLocation : Cert:\LocalMachine\Root
echo            Subject      : My_Code_Signing_Certificate
echo            PS1path      : %PSsignPath%
echo            ExpiresIn    : %ExpiresDate%
echo _

:: Digitally sign our cmdlet in certlm.msc
echo [cert_lm]: digitally sign our cmdlet {certificate expires in six months}
powershell $CertSign = New-SelfSignedCertificate -Subject "My_Code_Signing_Certificate" -FriendlyName "SsaRedTeam" -NotAfter (Get-Date).AddMonths(6) -Type CodeSigningCert -CertStoreLocation cert:\LocalMachine\My;Move-Item -Path $CertSign.PSPath -Destination "Cert:\LocalMachine\Root";Set-AuthenticodeSignature -FilePath %PSsignPath% -Certificate $CertSign
timeout /T 2 >nul
