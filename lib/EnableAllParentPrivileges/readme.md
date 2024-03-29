## EnableAllParentPrivileges.exe

|Binary Name|Description|Privileges|Notes|
|---|---|---|---|
|EnableAllParentPrivileges|Enable All Parent Privileges ( whoami /priv )|User Land (limmited) \| Administrator (all privs)|[Screenshot1](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/EnableAllParentPrivileges/EnableAllParentPrivileges_priv.png)<br />[Screenshot2](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/EnableAllParentPrivileges/EnableAllParentPrivileges_action.png)<br />[Screenshot3](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/EnableAllParentPrivileges/EnableAllParentPrivileges_UserLand.png)|

<br />

**download cmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/EnableAllParentPrivileges.exe" -OutFile "EnableAllParentPrivileges.exe"
```
<br />

**prerequesites:**
```powershell

#Administrator privileges required to Enable ALL privileges ..
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

#Privileges information
whoami /priv
```

<br />

**execute:**
```powershell
.\EnableAllParentPrivileges.exe
```

<br />

**Final notes:**
```powershell
[User Land] token will only Enable the follow privileges:

   SeAssignPrimaryTokenPrivilege Substituir um token de nível de processo      Enabled
   SeShutdownPrivilege           Encerrar o sistema                            Enabled
   SeChangeNotifyPrivilege       Ignorar verificação transversal               Enabled
   SeUndockPrivilege             Remover computador da estação de ancoragem    Enabled
   SeIncreaseWorkingSetPrivilege Aumentar um conjunto de trabalho de processos Enabled
   SeTimeZonePrivilege           Alterar o fuso horário                        Enabled
```
