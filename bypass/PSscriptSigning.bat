@echo off
title Signning (certlm) ONE powerShell script

echo .
:: Test for shell admin permissions
net session >nul 2>&1
IF %errorLevel% == 0 (
    echo [success]: Administrative permissions confirmed.
) ELSE (
    color 04
    echo [failure]: Current permissions inadequate.
    timeout /T 4 >nul
    exit
)

:: Get the PS script (cmdlet) Absoluct Path
SET /p PSsignPath="Input the PS script absoluct path: "
IF NOT EXIST %PSsignPath% (
    echo [failure]: cmdlet %PSsignPath% not found.
    exit
)

echo [PS1path]: %PSsignPath%
:: Digitally sign our cmdlet in certlm.msc
echo [certlm]: digitally sign our cmdlet { cert expires in six months }
powershell $CertSign = New-SelfSignedCertificate -Subject "My_Code_Signing_Certificate" -FriendlyName "SsaRedTeam" -NotAfter (Get-Date).AddMonths(6) -Type CodeSigningCert -CertStoreLocation cert:\LocalMachine\My;Move-Item -Path $CertSign.PSPath -Destination "Cert:\LocalMachine\Root";Set-AuthenticodeSignature -FilePath %PSsignPath% -Certificate $CertSign
timeout /T 2 >nul
