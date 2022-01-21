If(Test-Path -Path "$Env:WINDIR\system32\calc.exe")
{
   powershell (nEW-ObjeCt -ComObjEct Wscript.Shell).Popup("Executing rot13 encrypted script",4,"enc-rot13 - 1.4.9-ROT13 cipher",0+64)
   Start-Process calc.exe
}
Else
{
   Start-Process mspaint.exe
}