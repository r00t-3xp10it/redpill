' Run batch script in an hidden terminal console
Set objShell = WScript.CreateObject("WScript.Shell")
objShell.Run "cmd /c start %TMP%\Update-KB4524147.bat", 0, True