<#
.SYNOPSIS
   Get a list of prefetch files (.pf)

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.2

.DESCRIPTION
   This cmdlet allow users to list prefetch files that leads
   attackers to have a clear image of what its beeing executed

.Parameter Action
   accepts arguments: enum, del (default: enum)

.Parameter Prefetch
   The Prefetch folder path (default: $Env:WINDIR\Prefetch)

.Parameter Exclude
   Exlude files (default: SVCHOST.EXE|RUNTIMEBROKER.EXE|RUNDLL32.EXE|DLLHOST.EXE)

.EXAMPLE
   PS C:\> .\Get-PrefetchListing.ps1 -action 'enum'
   Enumerate all prefetch files (.pf)

.EXAMPLE
   PS C:\> .\Get-PrefetchListing.ps1 -action 'enum' -prefetch "$Env:WINDIR\Prefetch"
   Enumerate all prefetch files (.pf) of selected directory

.EXAMPLE
   PS C:\> .\Get-PrefetchListing.ps1 -action 'del'
   Dellete all prefetch files (.pf)

.INPUTS
   None. You cannot pipe objects into Get-PrefetchListing.ps1

.OUTPUTS
   [*] Manage Windows Prefetch Files.
       + Prefetch: 'C:\WINDOWS\prefetch'

   Name                                      CreationTimeUtc     LastAccessTimeUtc   LastWriteTimeUtc
   ----                                      ---------------     -----------------   ----------------
   AM_DELTA_PATCH_1.367.1287.0.E-968E5067.pf 10/06/2022 12:12:03 10/06/2022 17:11:04 10/06/2022 12:12:03
   APPLICATIONFRAMEHOST.EXE-8CE9A1EE.pf      10/06/2022 12:13:22 10/06/2022 17:11:04 10/06/2022 12:13:22
   ATIECLXX.EXE-2583891A.pf                  10/06/2022 05:29:31 10/06/2022 17:11:04 10/06/2022 05:29:31
   AUDIODG.EXE-AB22E9A6.pf                   10/06/2022 12:51:17 10/06/2022 16:41:13 10/06/2022 16:41:13
   BACKGROUNDTASKHOST.EXE-031FF058.pf        10/06/2022 12:09:58 10/06/2022 17:11:04 10/06/2022 12:09:58

.LINK
   https://github.com/r00t-3xp10it/redpill/tree/main/lib/Exfiltration#get-prefetchlistingps1
   https://github.com/r00t-3xp10it/redpill/blob/main/lib/Exfiltration/Get-PrefetchListing.ps1
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Exclude="SVCHOST.EXE|RUNTIMEBROKER.EXE|RUNDLL32.EXE|DLLHOST.EXE",
   [string]$Prefetch="$Env:WINDIR\Prefetch",
   [string]$Action="Enum"
)


$CmdletVersion = "v1.0.2"
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@Get-PrefetchListing $CmdletVersion {SSA@RedTeam}"
write-host "`n[*] Manage Windows Prefetch Files." -ForegroundColor Green
Start-Sleep -Milliseconds 500

If(-not(Test-Path -Path "$Prefetch"))
{
   write-host "`n    x " -ForegroundColor Red -NoNewline
   write-host "Notfound: '" -ForegroundColor DarkGray -NoNewline
   write-host "$Prefetch" -ForegroundColor Red -NoNewline
   write-host "'`n" -ForegroundColor DarkGray
   write-host "[*] Done, exit Get-PrefetchListing." -ForegroundColor Green
   return
}

write-host "    + " -ForegroundColor DarkYellow -NoNewline
write-host "Prefetch: '" -ForegroundColor DarkGray -NoNewline
write-host "$Prefetch" -ForegroundColor DarkYellow -NoNewline
write-host "'" -ForegroundColor DarkGray


If($Action -ieq "Enum")
{

   <#
   .SNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate prefetch (.pf) files

   .OUTPUTS
      [*] Manage Windows Prefetch Files.
          + Prefetch: 'C:\WINDOWS\prefetch'

      Name                                      CreationTimeUtc     LastAccessTimeUtc   LastWriteTimeUtc
      ----                                      ---------------     -----------------   ----------------
      AM_DELTA_PATCH_1.367.1287.0.E-968E5067.pf 10/06/2022 12:12:03 10/06/2022 17:11:04 10/06/2022 12:12:03
      APPLICATIONFRAMEHOST.EXE-8CE9A1EE.pf      10/06/2022 12:13:22 10/06/2022 17:11:04 10/06/2022 12:13:22
      ATIECLXX.EXE-2583891A.pf                  10/06/2022 05:29:31 10/06/2022 17:11:04 10/06/2022 05:29:31
   #>

   #Build Prefetch files List
   $PConf = Get-ChildItem -Path "$Prefetch" | Select-Object * | Where-Object {
      $_.PSIsContainer -iMatch '^(False)$' -and $_.Name -iNotMatch "($Exclude)" -and $_.Name -iMatch '(.pf)$'
   }|Select-Object Name,CreationTimeUtc,LastAccessTimeUtc,LastWriteTimeUtc

   If($PConf)
   {
      #Format the output Table displays
      $PConf | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
         $stringformat = If($_ -Match '^(Name)')
         {
            @{ 'ForegroundColor' = 'Green' }
         }
         Else
         {
            @{ 'ForeGroundColor' = 'white' }
         }
         Write-Host @stringformat $_
      }
   }
   Else
   {
      #None files found
      write-host "`n    x " -ForegroundColor Red -NoNewline
      write-host "Error: " -ForegroundColor DarkGray -NoNewline
      write-host "None objects [" -ForegroundColor Red -NoNewline
      write-host ".pf" -ForegroundColor DarkGray -NoNewline
      write-host "] found.`n" -ForegroundColor Red
   }

}


If($Action -ieq "Del")
{

   <#
   .SNOPSIS
      Author: @r00t-3xp10it
      Helper - Delete prefetch (.pf) files

   .OUTPUTS
      [*] Manage Windows Prefetch Files.
          + Prefetch: 'C:\WINDOWS\Prefetch'

          + Deleting: 'C:\WINDOWS\Prefetch\NOTEPAD.EXE-C5670914.pf'
          + Deleting: 'C:\WINDOWS\Prefetch\RUNTIMEBROKER.EXE-B54321.pf'
          + Deleting: 'C:\WINDOWS\Prefetch\RUNTIMEBROKER.EXE-B55987.pf'
          + Deleting: 'C:\WINDOWS\Prefetch\SVCHOST.EXE-K5660073.pf'

      [*] Done, exit Get-PrefetchListing.
   #>

   #Build 'Prefetch files to delete' list
   $PFDel = (Get-ChildItem -Path "$Prefetch"|Select *|Where-Object {
      $_.PSIsContainer -iMatch '^(False)$' -and $_.Name -iMatch '(.pf)$'
   }).FullName

   If($PFDel)
   {
      write-host ""
      ForEach($Item in $PFDel)
      {
         write-host "    + " -ForegroundColor DarkYellow -NoNewline
         write-host "deleting: '" -ForegroundColor DarkGray -NoNewline
         write-host "$Item" -NoNewline
         write-host "'" -ForegroundColor DarkGray
         Remove-Item -Path "$Item" -Force|Out-Null
      }
      write-host ""
   }
   Else
   {
      #none files found
      write-host "`n    x " -ForegroundColor Red -NoNewline
      write-host "Error: " -ForegroundColor DarkGray -NoNewline
      write-host "None objects [" -ForegroundColor Red -NoNewline
      write-host ".pf" -ForegroundColor DarkGray -NoNewline
      write-host "] files found.`n" -ForegroundColor Red
   }

}

write-host "[*] Done, exit Get-PrefetchListing." -ForegroundColor Green
exit
