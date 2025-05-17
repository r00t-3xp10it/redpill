$strMsg="DOWNLOADED and EXECUTED PAYLOAD.PS1 FROM WEBSERVER"
powershell (New-Object -ComObject Wscript.Shell).Popup($strMsg,20,'Payload.PS1',0+48)|Out-Null