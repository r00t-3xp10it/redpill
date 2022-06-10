<#
.SYNOPSIS
   Get a list of prefetch files (.pf)

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   This cmdlet allow users to list prefetch files that leads
   attackers to have a clear image of what its beeing executed

.Parameter Action
   accepts arguments: enum, del (default: enum)

.Parameter Prefetch
   The Prefetch folder path (default: $Env:WINDIR\Prefetch)

.Parameter Exclude
   Exlude files (default: SVCHOST.EXE|RUNTIMEBROKER.EXE|RUNDLL32.EXE|DLLHOST.EXE)

.OUTPUTS
   [*] Manage Windows Prefetch Files.
       + Prefetch: 'C:\WINDOWS\Prefetch'

       + Deleting: 'C:\WINDOWS\Prefetch\NOTEPAD.EXE-C5670914.pf'
       + Deleting: 'C:\WINDOWS\Prefetch\RUNTIMEBROKER.EXE-B54321.pf'
       + Deleting: 'C:\WINDOWS\Prefetch\RUNTIMEBROKER.EXE-B55987.pf'
       + Deleting: 'C:\WINDOWS\Prefetch\SVCHOST.EXE-K5660073.pf'

   [*] Done, exit Get-PrefetchListing.
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Exclude="SVCHOST.EXE|RUNTIMEBROKER.EXE|RUNDLL32.EXE|DLLHOST.EXE",
   [string]$Prefetch="$Env:WINDIR\Prefetch",
   [string]$Action="Enum"
)


$ErrorActionPreference = "SilentlyContinue"
write-host "`n[*] Manage Windows Prefetch Files." -ForegroundColor Green
Start-Sleep -Milliseconds 500

write-host "    + " -ForegroundColor DarkYellow -NoNewline
write-host "Prefetch: '" -ForegroundColor DarkGray -NoNewline
write-host "$Prefetch" -ForegroundColor DarkYellow -NoNewline
write-host "'" -ForegroundColor DarkGray


If($Action -ieq "Enum")
{

   <#
   .SNOPSIS
      Author: @r00t-3xp10it
      Helper - Enumerate prefetch files
   #>

   #Build Prefetch files list
   $PConf = Get-ChildItem -Path "$Prefetch" | Select-Object * | Where-Object {
      $_.PSIsContainer -iMatch '^(False)$' -and $_.Name -iNotMatch "($Exclude)" -and $_.Name -iMatch '(.pf)$'
   }|Select-Object Name,CreationTimeUtc,LastAccessTimeUtc,LastWriteTimeUtc

   If($PConf)
   {
      #Format output Table displays
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
      write-host "] files found.`n" -ForegroundColor Red
   }

}


If($Action -ieq "Del")
{

   <#
   .SNOPSIS
      Author: @r00t-3xp10it
      Helper - Delete prefetch files
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