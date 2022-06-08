eventK
author: @SolomonSklash

suspend thread in svchost.exe related to event logging

ETW Bypass
Next up is coverage of Event Tracing for Windows (ETW), how it can rat you out to AV/EDR,
and how to blind it in your local process. ETW is especially relevant when executing .NET
assemblies, such as in Cobalt Strike’s execute-assembly, as it can inform defenders of the
exact assembly name and methods executed. The solution in this case is simple: Patch the
ETWEventWrite function to return early with 0 in the RAX register. Anytime an ETW event
is sent by the process, it will always succeed, without actually sending the message.
Sweet and simple.


admin privs required

https://www.solomonsklash.io/windows-evasion-course-review.html