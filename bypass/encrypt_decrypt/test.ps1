<#
.SYNOPSIS
   Author: @r00t-3xp10it

.DESCRIPTION
   Test Ptr cipher.
#>


If(Test-Path -Path "$Env:WINDIR\system32\calc.exe")
{
   powershell (nEW-ObjeCt -ComObjEct Wscript.Shell).Popup("Testing Ptr cipher, start calc.exe ...",4,"Decrypt.ps1 cmdlet - 1.0.1",0+64)
   Start-Process calc.exe
}
Else
{
   Start-Process mspaint.exe
}