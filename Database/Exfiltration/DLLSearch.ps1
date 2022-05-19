<#
.SYNOPSIS
   List DLLs loaded by running processes!

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Get-Process {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.3

.DESCRIPTION
   Cmdlet to list all DLLs Loaded by running processes.

.NOTES
   This cmdlet deletes duplicated process names from the
   list to scan, retrieve process path, process PID and
   all DLLs loaded by process name ( running processes )

.Parameter Filter
   The process name to query (default: all)

.Parameter Exclude
   The Process Name to exclude (default: false)

.Parameter MaxProcesses
   Max Process Names to query (default: 200)

.Parameter Verb
   Display DLL absoluct path? (default: false)

.Parameter LogFile
   Store results on logfile? (default: false)

.EXAMPLE
   PS C:\> .\DLLSearch.ps1
   Retrieve dlls loaded by running processes

.EXAMPLE
   PS C:\> .\DLLSearch.ps1 -verb 'true'
   Retrieve dlls loaded by running processes
   and display DLL absoluct path ( verbose )

.EXAMPLE
   PS C:\> .\DLLSearch.ps1 -Filter 'ACMON'
   Retrieve ACMON process dlls loaded

.EXAMPLE
   PS C:\> .\DLLSearch.ps1 -Exclude 'scvhost'
   Retrieve all running processes dlls loaded
   but exclude from scans svchost processname

.EXAMPLE
   PS C:\> .\DLLSearch.ps1 -Exclude 'scvhost|RunTimeBroker' -MaxProcesses '10'
   Retrieve 10 running processes + dlls loaded and exclude 'scvhost|RunTimeBroker'

.EXAMPLE
   PS C:\> .\DLLSearch.ps1 -logfile 'true' -MaxProcesses '10'
   Retrieve 10 running processes + dlls loaded + create logfile

.INPUTS
   None. You cannot pipe objects into DLLSearch.ps1

.OUTPUTS
   * Searching for DLLs loaded by running processes ..

   Process PID      : 5824
   Process Name     : ACMON
   Process Priority : BelowNormal
   StartTime        : 04/05/2022 23:00:13
   Process Path     : C:\Program Files (x86)\ASUS\Splendid\ACMON.exe
   Modules Loaded   : ntdll.dll wow64.dll wow64win.dll wow64cpu.dll ntdll.dll KERNEL32.DLL KERNELBASE.dll msvcrt.dll combase.dll ucrtbase.dll RPCRT4.dll 
                      dxgi.dll win32u.dll gdi32.dll gdi32full.dll msvcp_win.dll USER32.dll IMM32.DLL kernel.appcore.dll bcryptPrimitives.dll clbcatq.dll 
                      ApplicationFrame.dll SHCORE.dll SHLWAPI.dll PROPSYS.dll OLEAUT32.dll twinapi.appcore.dll UxTheme.dll sechost.dll DEVOBJ.dll 
                      bcp47mrm.dll cfgmgr32.dll TWINAPI.dll d2d1.dll dwmapi.dll d3d11.dll OneCoreUAPCommonProxyStub.dll MSCTF.dll advapi32.dll dxcore.dll 
                      dcomp.dll CoreMessaging.dll WS2_32.dll UIAutomationCore.DLL SHELL32.dll windows.storage.dll Wldp.dll profapi.dll 
                      .. SNIP ..

.LINK
   https://github.com/r00t-3xp10it/redpill/blob/main/bin/DLLSearch.ps1
   https://gist.github.com/r00t-3xp10it/80f48b9bd556fb3529aca804539155f3?permalink_comment_id=4155435#gistcomment-4155435
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [int]$MaxProcesses='200',
   [string]$Exclude="false",
   [string]$LogFile="false",
   [string]$Filter="all",
   [string]$Verb="false"
)


$CmdletVersion = "v1.0.3"
#Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@DLLSearch $CmdletVersion {SSA@RedTeam}"
write-host "* Searching for DLLs loaded by running processes .." -ForegroundColor Green


#Build Output DataTable!
$DllTable = New-Object System.Data.DataTable
$DllTable.Columns.Add("Process PID")|Out-Null
$DllTable.Columns.Add("Process Name")|Out-Null
$DllTable.Columns.Add("Process Priority")|Out-Null
$DllTable.Columns.Add("Process StartTime")|Out-Null
$DllTable.Columns.Add("Process Path")|Out-Null
$DllTable.Columns.Add("Modules Loaded")|Out-Null


#Auto-List of running processes
$RunningProcesses = (PS -EA SilentlyContinue | Where-Object {
   $_.Responding -iMatch 'True' -and $_.ProcessName -iNotMatch "^($Exclude)$" -and $_.Modules.ModuleName -iMatch '(.dll)$'
}).ProcessName | Select-Object -First $MaxProcesses

If($Filter -ne "all")
{
   #User input of process name
   $RunningProcesses = $Filter
}
Else
{
   #Delete from auto-list replicated process mames
   $RunningProcesses = $RunningProcesses | sort | get-unique
}


ForEach($Item in $RunningProcesses)
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Loop trough procceses to extract DLL names

   .NOTES
      The Auto-List of processes does not contain any replicated
      process names. It means that processes like scvhost,firefox
      or runtimebroker have many duplicated entrys, but cmdlet
      only scans the Last process name found running because all
      other processes load the same DLLs ...
   #>


   If($Verb -ieq "true")
   {
      #If invoked -verb 'true' then display dll absoluct path
      $DLLModules = (PS $Item -EA SilentlyContinue | Where-Object {
         $_.Responding -iMatch 'True' -and $_.Modules.ModuleName -iMatch '(.dll)$'
      }|Select-Object -ExpandProperty Modules).FileName
   }
   Else
   {
      #If invoked -verb 'false' then just display dll filename
      $DLLModules = (PS $Item -EA SilentlyContinue | Where-Object {
         $_.Responding -iMatch 'True' -and $_.Modules.ModuleName -iMatch '(.dll)$'
      }|Select-Object -ExpandProperty Modules).ModuleName
   }

   #Get Process PID number \ Absoluct Path
   $ProcessFullInfo = (Get-Process -Name $Item|Select-Object -Last 1|Select-Object *)
   $PPID = $ProcessFullInfo.Id
   $PPATH = $ProcessFullInfo.Path
   $Priority = $ProcessFullInfo.PriorityClass
   $StartTime = $ProcessFullInfo.StartTime

   If(-not($PPID) -or $PPID -eq $null){$PPID = "fail to retrieve PID"}
   If(-not($PPATH) -or $PPATH -eq $null){$PPATH = "fail to retrieve Path"}
   If(-not($StartTime) -or $StartTime -eq $null){$StartTime = "fail to retrieve StartTime"}
   If(-not($Priority) -or $Priority -eq $null){$Priority = "fail to retrieve Priority"}

   #Adding values to output DataTable!
   $Parse = $DLLModules|Where-Object { $_ -iNotMatch '(.exe)$' }
   $DllTable.Rows.Add("$PPID","$Item","$Priority","$StartTime","$PPATH","$Parse")|Out-Null
}


#Display output Table OnScreen
$DllTable | Format-List | Out-String -Stream | Select -SkipLast 1 | ForEach-Object {
   $stringformat = If($_ -Match '^(Process PID)')
   {
      @{ 'ForegroundColor' = 'Yellow' }
   }
   ElseIf($_ -iMatch '^(Process Name)')
   {
      @{ 'ForegroundColor' = 'Green' }
   }
   ElseIf($_ -iMatch '^(Process Path   : fail to retrieve)')
   {
      @{ 'ForegroundColor' = 'Red' }
   }
   ElseIf($_ -iMatch '^(Process Path)')
   {
      @{ 'ForegroundColor' = 'DarkGray' }
   }
   Else
   {
      @{ 'ForegroundColor' = 'White' }
   }
   Write-Host @stringformat $_
}


If($LogFile -ieq "true")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - create logfile in current directory

   .EXAMPLE
      PS C:\> .\DLLSearch.ps1 -logfile true -maxprocesses '2'
   #>

   $Rand = -join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_}) # Only Random letters!
   $Rawdata = $DllTable | Format-List | Out-String -Stream | Select -SkipLast 1
   echo $Rawdata|Out-File "${Rand}.log" -Encoding string -Force
   write-host "* " -ForegroundColor Green -NoNewline;
   write-host "Logfile Path: '" -ForegroundColor DarkGray -NoNewline;
   write-host "$pwd\${Rand}.log" -ForegroundColor DarkYellow -NoNewline;
   write-host "'" -ForegroundColor DarkGray

}