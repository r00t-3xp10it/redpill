@echo off
title Signning ONE PowerShell Script

echo .
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

:: Get the PS script Absoluct Path
SET /p PSsignPath="Input the PS script absoluct path: "

echo Digitally sign our PS script { cert expires in six months }
echo PSPath: %PSsignPath%
powershell $CertSign = New-SelfSignedCertificate -Subject "My_Code_Signing_Certificate" -FriendlyName "SsaRedTeam" -NotAfter (Get-Date).AddMonths(6) -Type CodeSigningCert -CertStoreLocation cert:\LocalMachine\My;Move-Item -Path $CertSign.PSPath -Destination "Cert:\LocalMachine\Root";Set-AuthenticodeSignature -FilePath %PSsignPath% -Certificate $CertSign
timeout /T 2 >nul