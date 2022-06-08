<#
.SYNOPSIS
   Use GUI to open the sellected directory.
   
.EXAMPLE
   PS C:\> .\Open-Directory.ps1
#>

[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
$OpenDirectoryDialog = New-Object Windows.Forms.FolderBrowserDialog
$OpenDirectoryDialog.ShowDialog()|Out-Null

try{
   $Gui = $OpenDirectoryDialog.SelectedPath
   Invoke-Item -Path "$Gui" -EA SilentlyContinue
}Catch{
   Write-Host "x Error in line:'$($_.InvocationInfo.ScriptLineNumber)' $($Error[0])" -ForeGroundColor Red
}
