## Module Name
<b><i>FakeCmdLine.exe</i></b>
   
|Function Name|Description|Privileges|Notes|
|---|---|---|---|
|FakeCmdLine|Less-known ( but documented ) behavior of **CreateProcess()** function.<br />Effectively you can put any string into the child process Command Line field.|User Land|[URL](https://github.com/gtworek/PSBits/tree/master/FakeCmdLine)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Fake-Cmdline/FakeCmdLine.exe" -OutFile "FakeCmdLine.exe"
```

```powershell   
.\FakeCmdLine.exe <ExeToLaunch> <cmdline>
``` 
