<#
.SYNOPSIS
   Use GUI to open the sellected directory
#>

[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
$OpenDirectoryDialog = New-Object Windows.Forms.FolderBrowserDialog
$OpenDirectoryDialog.ShowDialog()|Out-Null

try{
   $Gui = $OpenDirectoryDialog.SelectedPath
   Invoke-Item -Path "$Gui" -EA SilentlyContinue
}catch{
   Write-Warning 'Open Directory Dialog was closed or cancelled without selecting a Directory'
}