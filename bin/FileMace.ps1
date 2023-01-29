<#
.SYNOPSIS
   Change file mace time {timestamp}

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Get-ChildItem
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.3

.DESCRIPTION
   This module changes the follow mace propertys:
   CreationTime, LastAccessTime, LastWriteTime

.NOTES
   -Date parameter format: "08 March 1999 19:19:19"
   Remark: Double quotes are mandatory in -Date parameter

.Parameter FileMace
   Accepts the absoluct \ relative path of file to modify

.Parameter Date
   Accepts the Data to be changed on FileMace timestomp

.EXAMPLE
   PS C:\> .\FileMace.ps1 -FileMace "$Env:TMP\test.txt"
   Changes file mace using FileMace default -Date "date-format"

.EXAMPLE
   PS C:\> .\FileMace.ps1 -FileMace "test.txt" -Date "08 March 1999 19:19:19"
   Changes sellected file mace using user inputed -Date "date-format"

.OUTPUTS
   State          : before modification
   Attributes     : Archive
   Name           : test.txt
   Directory      : C:\Users\pedro\OneDrive\Ambiente de Trabalho
   CreationTime   : 29/01/2023 22:45:44
   LastAccessTime : 29/01/2023 22:45:44
   LastWriteTime  : 29/01/2023 22:45:44

   State          : after modification
   Attributes     : Archive
   Name           : test.txt
   Directory      : C:\Users\pedro\OneDrive\Ambiente de Trabalho
   CreationTime   : 08/03/1999 19:19:19
   LastAccessTime : 08/03/1999 19:19:19
   LastWriteTime  : 08/03/1999 19:19:19
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FileMace="false",
   [string]$Date="false"
)


$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

If($FileMace -ne "false")
{
    ## Make sure that the inputed file exists
    If(-not(Test-Path -Path "$FileMace" -EA SilentlyContinue))
    {
        Write-Host "`n   [missing]: $FileMace`n" -ForegroundColor Red
        return
     }

     ## Make sure user have input -Date parameter 
     If($Date -ieq "false" -or $Date -ieq $null)
     {
         $Date = "08 March 1999 19:19:19"
     }

     ## Print OLD file TimeStamp
     Get-ChildItem -Path "$FileMace"|Select-Object @{Name='State';Expression={'before modification'}},Attributes,Name,Directory,CreationTime,LastAccessTime,LastWriteTime
     Start-Sleep -Seconds 1

     ## Change file mace propertys {timestamp}
     Get-ChildItem -Path "$FileMace"|% {$_.CreationTime = $Date}
     Get-ChildItem -Path "$FileMace"|% {$_.lastaccesstime = $Date}
     Get-ChildItem -Path "$FileMace"|% {$_.LastWriteTime = $Date}

     ## Display file NEW TimeStamp
     Get-ChildItem -Path "$FileMace"|Select-Object @{Name='State';Expression={'after modification'}},Attributes,Name,Directory,CreationTime,LastAccessTime,LastWriteTime
}