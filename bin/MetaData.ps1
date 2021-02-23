<#
.SYNOPSIS
   Display file \ appl description (metadata)

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1
   
.DESCRIPTION
   Display file \ appl description (metadata)

.NOTES
   -Extension [ exe ] parameter its used to recursive search starting in -FilePath
   directory for standalone executables (exe) and display is property descriptions.

.Parameter MetaData
   Accepts the absolute \ relative path of the file \ appl to scan

.Parameter Extension
   Triggers recursive dir search for files with -Extension [ extension ]

.EXAMPLE
   PS C:\> Get-Help .\MetaData.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\MetaData.ps1 -MetaData "$Env:USERPROFILE\Desktop\CommandCam.exe"
   Display CommandCam.exe standalone executable file description (metadata)

.EXAMPLE
   PS C:\> .\MetaData.ps1 -MetaData "$Env:USERPROFILE\Desktop" -Extension ".exe"
   Search for .exe files recursive and display is property descriptions

.INPUTS
   None. You cannot pipe objects into AdsMasquerade.ps1

.OUTPUTS
   FileMetadata
   ------------
   VersionInfo : File:             C:\Users\pedro\Desktop\CommandCam.exe
                 InternalName:     CommandCam.exe
                 OriginalFilename: CommandCam.exe
                 FileVersion:      0.0.2.8
                 FileDescription:  meterpeter WebCamSnap
                 Product:          meterpeter WebCamSnap
                 ProductVersion:   1.0.2.8
                 Debug:            False
                 Patched:          False
                 PreRelease:       False
                 PrivateBuild:     True
                 SpecialBuild:     False
                 Language:         Idioma neutro
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Extension="false",
   [string]$MetaData="false"
)


Write-Host "`n"
## Local variable declarations
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null


If($MetaData -ne "false"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display file \ appl description (metadata)

   .NOTES
      -Extension [ exe ] parameter its used to recursive search starting in -FilePath
      directory for standalone executables (exe) and display is property descriptions.

   .EXAMPLE
      PS C:\> .\MetaData.ps1 -MetaData "$Env:USERPROFILE\Desktop\CommandCam.exe"
      Display CommandCam.exe stand alone executable file description (metadata)

   .EXAMPLE
      PS C:\> .\MetaData.ps1 -MetaData "$Env:USERPROFILE\Desktop" -Extension ".exe"
      Search for .exe files recursive and display is property description

   .OUTPUTS
      FileMetadata
      ------------
      VersionInfo : File:             C:\Users\pedro\Desktop\CommandCam.exe
                    InternalName:     CommandCam.exe
                    OriginalFilename: CommandCam.exe
                    FileVersion:      0.0.2.8
                    FileDescription:  meterpeter WebCamSnap
                    Product:          meterpeter WebCamSnap
                    ProductVersion:   1.0.2.8
                    Debug:            False
                    Patched:          False
                    PreRelease:       False
                    PrivateBuild:     True
                    SpecialBuild:     False
                    Language:         Idioma neutro
   #>

   ## Build Output Table
   echo "FileMetadata" > $Env:TMP\gdfttdo.log 
   echo "------------" >> $Env:TMP\gdfttdo.log
   Start-Sleep -Seconds 1


   ## Make sure $FilePath exists before continue any further
   If(Test-Path -Path "$MetaData" -ErrorAction SilentlyContinue){

       If($Extension -ne "false"){

           ## Read FilePath description
           Get-ChildItem -Path "$MetaData" -Recurse -EA SilentlyContinue |
               Where-Object { $_.VersionInfo.InternalName -Match ".${Extension}" } |
               Format-List -Property VersionInfo >> $Env:TMP\gdfttdo.log

      }Else{

          ## Read FilePath description
          Get-ItemProperty -Path "$MetaData" -EA SilentlyContinue |
              Format-List -Property VersionInfo >> $Env:TMP\gdfttdo.log 

      }

   }Else{
   
       ## Build Output Table
       echo "[error] Not found: $MetaData`n" >> $Env:TMP\gdfttdo.log   
   
   }

   ## Ouput Table
   # Strip Empty Lines from output ( where-object {} )
   Get-Content -Path "$Env:TMP\gdfttdo.log" | Where-Object { $_ -ne "" }
   Remove-Item -Path "$Env:TMP\gdfttdo.log" -Force
}
