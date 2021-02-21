<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Change file mace time {timestamp}

.DESCRIPTION
   This module changes the follow mace propertys:
   CreationTime, LastAccessTime, LastWriteTime

.NOTES
   -Date parameter format: "08 March 1999 19:19:19"
   Remark: Double quotes are mandatory in -Date parameter

.EXAMPLE
   PS C:\> .\FileMace.ps1 -FileMace $Env:TMP\test.txt
   Changes sellected file mace using MyMeterprter default -Date "date-format"

.EXAMPLE
   PS C:\> .\FileMace.ps1 -FileMace $Env:TMP\test.txt -Date "08 March 1999 19:19:19"
   Changes sellected file mace using user inputed -Date "date-format"

.OUTPUTS
   FullName                        Exists CreationTime       
   --------                        ------ ------------       
   C:\Users\pedro\Desktop\test.txt   True 08/03/1999 19:19:19
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FileMace="false",
   [string]$Date="false"
)


Write-Host ""
If($FileMace -ne "false"){
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

    Write-Host "[+] Change File Mace propertys" -ForegroundColor Green
    Start-Sleep -Seconds 1
    ## Make sure that the inputed file exists
    If(-not(Test-Path -Path "$FileMace" -EA SilentlyContinue)){
        Write-Host "[error] File not found: $FileMace!" -ForegroundColor Red -BackgroundColor Black
        Write-Host "";Start-Sleep -Seconds 1;exit ## Exit @FileMace
     }

     ## Make sure user have input the -Date parameter 
     If($Date -ieq "false" -or $Date -ieq $null){
         $Date = "08 March 1999 19:19:19"
     }

     ## Change file mace propertys {timestamp}
     Get-ChildItem $FileMace|% {$_.CreationTime = $Date}
     Get-ChildItem $FileMace|% {$_.lastaccesstime = $Date}
     Get-ChildItem $FileMace|% {$_.LastWriteTime = $Date}
     Get-ChildItem $FileMace|Select-Object FullName,Exists,CreationTime

Write-Host "";Start-Sleep -Seconds 1
}