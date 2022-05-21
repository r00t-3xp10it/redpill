## Module Name
   <b><i>CarbonCopy.py</i></b>

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|CarbonCopy|A tool which creates a spoofed certificate of any online website<br />and signs an Executable for AV Evasion. Works for both Windows and Linux|User Land|To be executed under Linux|

```shell
wget https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Sign-Executables/CarbonCopy.py -O CarbonCopy.py
```

**prerequisites:**
```shell 
apt-get install osslsigncode
pip3 install pyopenssl
```

```python   
python3 CarbonCopy.py www.microsoft.com 443 prometheus.exe signed-prometheus.exe
```

<br />

## Module Name
   <b><i>sigthief.py</i></b>

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|sigthief|A tool to sign an Executable for AV Evasion.<br />It clones signcheck.exe to sign the new binary|User Land|Dependencies: python3|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Sign-Executables/sigthief.py" -OutFile "sigthief.py"
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Sign-Executables/signcheck.exe" -OutFile "signcheck.exe"
```

```python   
python Sigthief.py -i "sigcheck.exe" -t "prometheus.exe" -o "signed-prometheus.exe"
```
