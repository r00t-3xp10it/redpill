@echo off
::
::   Author:
::      @r00t-3xp10it
::
::   Description:
::      Digitally sign (certlm) one cmdlet.
::
::   Output:
::      [success]: Administrative permissions confirmed.
::      [ input ]: Input cmdlet absoluct path: C:\Users\pedro\AppData\Local\Temp\Payload.ps1
::      _
::                 Certificate information
::                 -----------------------
::                 FriendlyName : SsaRedTeam
::                 CertLocation : Cert:\LocalMachine\Root
::                 Subject      : My_Code_Signing_Certificate
::                 PS1path      : C:\Users\pedro\AppData\Local\Temp\Payload.ps1
::                 ExpiresIn    : 23 de novembro de 2022 00:31:20
::      _
::     [cert_lm]: Digitally sign our cmdlet {cert expires in six months}
:: ---
title Signning (certlm) ONE powerShell cmdlet


:: Test for shell permissions
net session >nul 2>&1
IF %errorLevel% == 0 (
    echo [success]: Administrative permissions confirmed.
) ELSE (
    echo [failure]: Current permissions inadequate.
    exit
)

:: Get the PS script (cmdlet) Absoluct Path
SET /p PSsignPath="[ input ]: Input cmdlet absoluct path: "
IF NOT EXIST "%PSsignPath%" (
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
echo [cert_lm]: Digitally sign our cmdlet {certificate expires in six months}
powershell $CertSign = New-SelfSignedCertificate -Subject "My_Code_Signing_Certificate" -FriendlyName "SsaRedTeam" -NotAfter (Get-Date).AddMonths(6) -Type CodeSigningCert -CertStoreLocation cert:\LocalMachine\My;Move-Item -Path $CertSign.PSPath -Destination "Cert:\LocalMachine\Root";Set-AuthenticodeSignature -FilePath %PSsignPath% -Certificate $CertSign
timeout /T 2 >nul
