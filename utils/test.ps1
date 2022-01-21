If(Test-Path -Path "$Env:WINDIR\system32\calc.exe")
{
   powershell (nEW-ObjeCt -ComObjEct Wscript.Shell).Popup("FileLess downloader\executioner of cmdlet's",4,"@Meterpeter - v2.10.11 Sgitarious A*",0+64)
   Start-Process calc.exe
}
Else
{
   Start-Process mspaint.exe
}
