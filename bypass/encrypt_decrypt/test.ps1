<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Testing 113[bytes] cipher.

.NOTES
   Syntax used to encrypt this cmdlet:
   .\Encrypt-String.ps1 -action "autodecrypt" -infile "test.ps1"
#>

If(Test-Path -Path "$Env:WINDIR\system32\calc.exe")
{
   powershell (New-Object -ComObjEct Wscript.Shell).Popup("Testing 113[bytes] cipher, start calc.exe ...",5,"Decrypt.ps1 cmdlet - 1.0.1",0+64)
   Start-Process calc.exe
}
Else
{
   Start-Process mspaint.exe
}