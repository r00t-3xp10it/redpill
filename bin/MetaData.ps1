<#
.SYNOPSIS
   Display file \ application description (metadata)

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1
   
.DESCRIPTION
   Display file \ application description (metadata)

.NOTES
   -Extension [ exe ] parameter its used to recursive search starting in -MetaData
   directory for standalone executables (exe) and display is property descriptions.

.Parameter MetaData
   Accepts the absolute \ relative path of the file \ appl to scan

.Parameter Extension
   Recursive dir search starting in -MetaData [ dir ] for -Extension [ extension ]

.EXAMPLE
   PS C:\> Get-Help .\MetaData.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\MetaData.ps1 -MetaData "$Env:USERPROFILE\Desktop\CommandCam.exe"
   Display CommandCam.exe standalone executable file description (metadata)

.EXAMPLE
   PS C:\> .\MetaData.ps1 -MetaData "$Env:USERPROFILE\Desktop" -Extension "exe"
   Search for [ .exe ] recursive starting in -MetaData [ dir ] and display descriptions

.INPUTS
   None. You cannot pipe objects into MetaData.ps1

.OUTPUTS
   FileMetadata
   ------------
   Name           : CommandCam.exe
   CreationTime   : 23/02/2021 18:31:55
   LastAccessTime : 23/02/2021 18:31:55
   VersionInfo    : File:             C:\Users\pedro\Desktop\CommandCam.exe
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
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null


If($MetaData -ne "false"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display file \ application description (metadata)

   .NOTES
      -Extension [ exe ] parameter its used to recursive search starting in -MetaData
      directory for standalone executables (exe) and display is property descriptions.

   .EXAMPLE
      PS C:\> .\MetaData.ps1 -MetaData "$Env:USERPROFILE\Desktop\CommandCam.exe"
      Display CommandCam.exe stand alone executable file description (metadata)

   .EXAMPLE
      PS C:\> .\MetaData.ps1 -MetaData "$Env:USERPROFILE\Desktop" -Extension "exe"
      Search for [ .exe ] recursive starting in -MetaData [ dir ] and display descriptions
   #>

   ## Build Output Table
   echo "FileMetadata" > $Env:TMP\gdfttdo.log 
   echo "------------" >> $Env:TMP\gdfttdo.log
   Start-Sleep -Seconds 1


   ## Make sure $MetaData exists before continue any further
   If(Test-Path -Path "$MetaData" -ErrorAction SilentlyContinue){

       If($Extension -ne "false"){

           ## Read $MetaData description
           Get-ChildItem -Path "$MetaData" -Recurse -EA SilentlyContinue |
               Where-Object { $_.PSIsContainer -ieq $False -and $_.Name -Match "(.${Extension})$" } |
               Format-List -Property Name,CreationTime,LastAccessTime,VersionInfo >> $Env:TMP\gdfttdo.log

           $CheckContents = Get-Content -Path "$Env:TMP\gdfttdo.log" -EA SilentlyContinue
           If(-not($CheckContents -Match "(.${Extension})$")){
               echo "[error] None files found under: $MetaData`n" >> $Env:TMP\gdfttdo.log              
           }
           
      }Else{

          ## Read $MetaData description
          Get-ItemProperty -Path "$MetaData" -EA SilentlyContinue |
              Format-List -Property Name,CreationTime,LastAccessTime,VersionInfo >> $Env:TMP\gdfttdo.log 

          $FileExt = $MetaData.Split('.')[-1]
          $CheckContents = Get-Content -Path "$Env:TMP\gdfttdo.log" -EA SilentlyContinue
          If(-not($CheckContents -Match "(.${FileExt})$")){
              echo "[error] None files found under: $MetaData`n" >> $Env:TMP\gdfttdo.log              
          }
          
      }

   }Else{
   
       ## Build Output Table
       echo "[error] Not found: $MetaData`n" >> $Env:TMP\gdfttdo.log   
   
   }

   ## Ouput Table
   # Strip Empty Lines from output ( where-object {} )
   Get-Content -Path "$Env:TMP\gdfttdo.log" | Where-Object { $_ -ne "" }
   Remove-Item -Path "$Env:TMP\gdfttdo.log" -Force
   Write-Host ""
}
