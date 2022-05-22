Get-Service -Name LanmanServer|Select-Object Name,DisplayName,ServiceName,StartType,Status|ogv
start-process calc.exe