## Module Name
   DumpChromePasswords

   **Description:**
   <b><i>This cmdlet dumps URLs, usernames, and passwords from Chrome.</i></b>

   **prerequisites:**
``` 
   1. You must have the System.Data.SQLite.dll handy (see below)
   2. Your database must be accessible (close Chrome, or make some copy)
   3. It must by your database. If Chrome cannot open it, the script will probably fail as well.
```
   **Syntax:**
```powershell   
.\DumpChromePasswords.ps1
```

<br />

## Module Name
   HarvestBrowserPasswords

   **Description:**
   <b><i>This cmdlet dumps URLs, usernames, and passwords from major browsers.</i></b>

   **Syntax:**
```powershell      
.\HarvestBrowserPasswords.exe -a, --all
.\HarvestBrowserPasswords.exe -f, --firefox
.\HarvestBrowserPasswords.exe -c, --chrome
```   