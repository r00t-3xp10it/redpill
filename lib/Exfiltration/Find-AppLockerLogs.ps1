function Find-AppLockerLogs
{
<#
.SYNOPSIS
   Look through the AppLocker logs to find processes that get run on the server.
   You can then backdoor these exe's (or figure out what they normally run).

Function: Find-AppLockerLogs
Author: Joe Bialek, Twitter: @JosephBialek
Required Dependencies: None
Optional Dependencies: None

.DESCRIPTION
   Look through the AppLocker logs to find processes that get run on the server.
   You can then backdoor these exe's (or figure out what they normally run).

.EXAMPLE
   Find-AppLockerLogs
   Find process creations from AppLocker logs.

.LINK
   Blog: http://clymb3r.wordpress.com/
   Github repo: https://github.com/clymb3r/PowerShell
#>
    $ReturnInfo = @{}

    $AppLockerLogs = Get-WinEvent -LogName "Microsoft-Windows-AppLocker/EXE and DLL" -ErrorAction SilentlyContinue | Where {$_.Id -eq 8002}

    foreach ($Log in $AppLockerLogs)
    {
        $SID = New-Object System.Security.Principal.SecurityIdentifier($Log.Properties[7].Value)
        $UserName = $SID.Translate( [System.Security.Principal.NTAccount])

        $ExeName = $Log.Properties[10].Value

        $Key = $UserName.ToString() + "::::" + $ExeName

        if (!$ReturnInfo.ContainsKey($Key))
        {
            $Properties = @{
                Exe = $ExeName
                User = $UserName.Value
                Count = 1
                Times = @($Log.TimeCreated)
            }

            $Item = New-Object PSObject -Property $Properties
            $ReturnInfo.Add($Key, $Item)
        }
        else
        {
            $ReturnInfo[$Key].Count++
            $ReturnInfo[$Key].Times += ,$Log.TimeCreated
        }
    }

    return $ReturnInfo
}

Find-AppLockerLogs