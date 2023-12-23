<#
.SYNOPSIS
   Identify possible ams1 strings inside scripts

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.6

.DESCRIPTION
   This cmdlet was written to detect suspicious ams1 strings in .ps1 or .psm1
   scripts, helping developers identify which line of the script the malicious
   string is in and to take the necessary steps to prevent further detections.

.NOTES
   When scanning its advice to disable windows defender RealTime Protection.
   All the strings contained in this script were found in diferent web forums
   since microssoft oficial ams1 documentation until free open sources. This
   script it will not make any heuristic\memory scans just a string search.

.Parameter FileToScan
   Script to scan full path

.Parameter LogFile
   Switch that creates report logfile

.Parameter AMS1
   Switch that Scan script with AMS1 engine

.EXAMPLE
   PS C:\> .\identify_offencive_tools.ps1 -filetoscan "$pwd\evil.ps1"

.EXAMPLE
   PS C:\> .\identify_offencive_tools.ps1 -filetoscan "$pwd\evil.ps1" -logfile

.INPUTS
   None. You cannot pipe objects into identify_offencive_tools.ps1

.OUTPUTS
   * Detecting [ams1] malicious strings

   - File size     : 276448
   - Current Time  : 22/12/2023 00:36:32
   - Last access   : 21/12/2023 22:27:06
   - File to scan  : C:\Users\pedro\Coding\meterpeter\meterpeter.ps1

   [SF] Scanning file ...

   Token           : 1
   MaliciousString : IEX
   LineNumber      : 4407

   Token           : 2
   MaliciousString : powershell -version 2
   LineNumber      : 3622 3632 3637 3654 3658 3664

   Token           : 3
   MaliciousString : runas
   LineNumber      : 385 465 542 546 672 676 3343 3363 3458 3916

   Token           : 4
   MaliciousString : SetValue($null,$true)
   LineNumber      : 23

   Token           : 5
   MaliciousString : while($true)
   LineNumber      : 794 978 3103

   [OK] Total of tokens found: [5] off [285] tokens.
   [OK] Of witch [4] results deserves urgent attention.
   [OK] Cmdlet_Total_Scan_Time: [00:00:08]
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   https://www.mdsec.co.uk/2018/06/exploring-powershell-amsi-and-logging-evasion
   https://learn.microsoft.com/en-us/windows/win32/amsi/antimalware-scan-interface-portal
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$FileToScan="C:\Users\pedro\Coding\meterpeter\meterpeter.ps1",
   [switch]$LogFile,
   [switch]$Ams1
)


## Global variable declarations
$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "@Identify_Offensive_Tools (IOT)"
write-host "* Detecting [ams1] malicious strings`n" -ForegroundColor Green

$MaliciousKeywordsList = @(
   "I@E'X",
   "-e@n'c",
   "-n'o@p",
   "am@si",
   "vi'r@us",
   "key@log",
   "tr@ojan",
   "cm'd /@c",
   "mal@ware",
   "payl@oad",
   "revsh@ell",
   "mimi@katz",
   "am@si.dl'l",
   "hashd@ump",
   "Ad@d-Ty'pe",
   "phi@sh@ing",
   "-enc@od'ed",
   "DllI@mport",
   "obfu@sca@te",
   "imp@ers@onate",
   "rever@sesh@ell",
   "Exc@lus'ion@Path",
   "reve@rse sh@ell",
   "re@verse-she@ll",
   "Ams@iSca'n@Bu'ff@er",   
   "in@vok'e-mim@ik'atz",
   "-enco@de'dcom@ma'nd",
   "Excl'us@ionP@roc'ess",
   "In@vo'ke-Exp@ress'ion",
   "re@d team@ing",
   "ams@iu'ti@ls",
   "ams'iIn@itFa'il@ed",
   "keys@troke",
   "keyst@rokes",
   "buff@er ove@rflow",
   "bru@tefo@rce",
   "redte@am",
   "red te@am",
   "she@llcode",
   "file@less",
   "prive@sc",
   "esca@late pri@vileges",
   "passwo@rd guess@ing",
   "gue@ss log@in",
   "crede@ntial du@mp",
   "passw@ord spr@aying",
   "passwo@rd spr@ay",
   "clea@rte@xt pas@swo'rds",
   "rem@ote execut@ion",
   "cre@ds du@mp",
   "cre@denti@als du@mp",
   "pass th@e ha@sh",
   "pa@ss-the-h@ash",
   "gol@den tic@ket",
   "dump@ing the lsa@ss",
   "dumpi@ng lsa@ss",
   "du@mp ls'as@s",
   "cache@d crede@n'tials",
   "l@s'a secr@ets",
   "impe'rso@nat@ing user",
   "imper@so'nate us@er",
   "im@pa'ck@et",
   "ls@as's du@mp",
   "pro@cdu@m'p",
   "obfu@scated",
   "obfu@scat@ion",
   "pw@du@m'p",
   "comm@and a@nd con@t'rol",
   "drop@per",
   "web sh@ell",
   "we@bsh@ell",
   "kerb@er'os re@la'y",
   "spo@ofing",
   "ele@va@te pr'ivi@lege",
   "ab@use ele'va@tion",
   "b@ypas@s u@a'c",
   "ua@c b'ypa@ss",
   "acce@ss tok@en man'ip@ula@ti'on",
   "to@ken imp'ers@onation",
   "tok@en the@ft",
   "ev@ade pro@c@ess-mon@i'to@ring",
   "bypa@ss pa@ss'wo@rd",
   "vi@ctim ip",
   "snif@fing",
   "poi@soning",
   "elev@ate pr'oc@ess pr@ivi'leg@es",
   "ele'v@ate its pr@ivi'leg@es",
   "by@pa'ss us@er acc@ou'nt con'tr@ol",
   "po'we@rsh'ell -e@p 'by@pa@ss",
   "expl@oit",
   "key@log@ger",
   "sn@if@fer",
   "pas@sw'ord cr@ack",
   "pass@wo'rd hac@king",
   "pa@ss'wo@rd bre@ac'h",
   "pa's@swor@d at@ta'ck",
   "pass@wo'rd st@e'al@er",
   "by@pa'ss ant@ivi'rus",
   "b'ru@te fo@r'ce",
   "re@mo'te acc@e'ss",
   "pa'ss@wo'rd ha@sh'ing",
   "co@d'e inje@ction",
   "key@st'ro@ke log@gi'ng",
   "keyl@ogg'ing",
   "pas@swor'd sni@ff'ing",
   "ciph@er",
   "coo@kie steal@ing",
   "pas'sw@ord crac@king",
   "enc@rypt'ion",
   "pr@iv'ile@ge @es'cala@ti'on",
   "k'ey log@gi'ng",
   "pa'ss@word ha@rves@ting",
   "ea've@sdr@oppi@ng",
   "bru@te-fo'rc@ing",
   "coo@ki'e the@ft",
   "ref'lec@tion atta@ck",
   "cr@yp'to atta@ck",
   "smu@rfing",
   "pin@g o'f de@a'th",
   "crede@n'tial @th'eft",
   "ke'yl@ogg'e@r in@stall@at'ion",
   "has@hing",
   "file@le@ss at@ta@ck",
   "imp@er'sonati@on",
   "file@le'ss ma@lwa're",
   "payl'oa@d deliv@ery",
   "an@tivi'rus @ev'as@ion",
   "dat@a obfus@cation",
   "l@da'p in@je'ction",
   "dec@ry'ption",
   "Defi@neD@yn'ami@cAssembly",
   "Defi@ne@Dy'nam@icMo'dule",
   "Def@i'ne@Ty'pe",
   "Def@in'eC@onst'r@uc@tor",
   "Cre@at'eTy@pe",
   "Defi'ne@Lite@ral",
   "Def@in'eE@num",
   "Defin@eF'ie@ld",
   "ILG@en'er@ator",
   "Em'i@t",
   "Unv@e'rifi@abl'eC@ode@Att'rib@ute",
   "Defi@nePI'nvok@eMe'th@od",
   "@Get@Ty'pes",
   "Get@Ass@em'blies",
   "Met@ho'ds",
   "Ge@tCon'stru@ct'or",
   "GetC@ons'tru@cto'rs",
   "Ge'tDef@ault'Me@mb'ers",
   "Ge@tEve@nt",
   "GetE@ve'nts",
   "Get@Fie'ld",
   "Ge@tFie'lds",
   "@Ge@tInt@er'face",
   "GetInt@erf'aceMap",
   "Ge@tIn'terf@aces",
   "GetM@em'be@r",
   "G'etM@emb@ers",
   "Get@Met'ho@d",
   "Get@Met'ho@ds",
   "Ge@tN'es@te'dType",
   "Get@Ne'st@ed@Ty'pes",
   "Ge@tPr'ope@rt'ies",
   "Ge@tPro'pe@rt'y",
   "@In'vok@eMe'mb@er",
   "Ma@k'eAr@ra'yTy@pe",
   "Mak@eB'yR@efT@yp'e",
   "Ma@ke'Ge@ne'ric@Type",
   "Mak'eP@oin'te@rTyp'e",
   "De'cl@ari'ngM@et'hod",
   "Decl'ar@ing@Ty'pe",
   "Ref@lec'ted@Ty'pe",
   "Typ@eHa@nd'le",
   "T@ype'In@iti'al@izer",
   "Un'de@rlyi'ng@Syst'em@Type",
   "In@te'rop@Se@rv'ic@es",
   "All@oc'HG@lo'ba@l",
   "Pt'rT@oSt'ru@ct@u're",
   "St@ru'ct@ur'eToP@t'r",
   "Fr@eeHG'lo@bal",
   "In'tPt@r",
   "Mem@ory'Str'e@am",
   "Def@lat'eSt@r'ea@m",
   "From@Ba'se6@4S'trin@g",
   "Enc'od@e'dCo@mm'and",
   "Byp'a@ss",
   "ToB@a'se6'4S@tri'n@g",
   "Exp@an'dS@tr@ing",
   "GetP'ow@erS'he@ll",
   "Op@enPr'oc@ess",
   "Vi@rtu'alAl@loc",
   "V'ir@tu@alF'r@ee",
   "Writ@ePro'cessMe@mory",
   "Crea@teU'serTh@r'ead",
   "Cl@ose'Ha@n'dle",
   "GetDe@le'g@ateF'orFun'cti@onP'oi@n@ter",
   "ke@rn'el3@2",
   "Cr@eat'eThr@e'ad",
   "me'mc@py",
   "Loa'dL@ib'ra@ry",
   "GetM@od'ul@eHa'nd@le",
   "Ge@tPr'ocA@dd@r'ess",
   "Vir'tu@al@Prot'ec't",
   "Fre@eLib'ra@ry",
   "Re'a@dPr'oc@ess@Mem'ory",
   "Cre'a@teRe'm@ot@eThr'ea@d",
   "Ad@justT'ok@enP@ri@vil'eges",
   "Wri@te@B'yt'e",
   "Wri@teI@nt'32",
   "O'penTh're@adT'ok@en",
   "Pt@rT'oS@tri@ng",
   "Ze@roFr'eeGlob@alA'llo@cU'ni@code",
   "Op@en@Pr'oce'ssT'ok@en",
   "Get@Tok'e@nInf'or@matio'n",
   "Se@tTh're@a'dTo@k'en",
   "Im'per@son'a@teLogg'edO'nUs@er",
   "Rev'er@tT'oSe@lf",
   "Ge@tLo'go'nS@ess@i'o@nData",
   "Crea't@e'Proc@es'sW@ithTo'ke@n",
   "Du'pli@cat'eTok@en'Ex",
   "Op@en@Wi'nd@owSt'ati'o@n",
   "Ope@nDe@s'ktop",
   "@Min'i'Du@mpWr@it'eD'ump",
   "A@dd'Sec@uri'tyPa@ck'age",
   "Enu@me'r@at@eSecu'ri@tyPa'ck@ages",
   "Ge@tPr@oce'ss@Ha'ndle",
   "Dange'ro@usG@etH'an@dle",
   "Get@As'yn@cK'ey@State",
   "'Key@bo'ar@dS'ta@te",
   "G@etFo're@grou@nd'Wi@ndow",
   "Bin'di@ngFl'ag@s",
   "No'n@Pu'bl@ic",
   "Scr'ip@tBl'oc@kLog'gi@ng",
   "Lo'gPi2peli'neEx@e@cuti'onDe@tails",
   "P'rot@ect'edEv@en'tLo@gg'ing",
   "whil'e(`$tr@ue)",
   "pow@ers'hell -@ve'rsi@on '2",
   "Se'tVa@lue(`$nu@ll,`$tru'e)",
   ".Wr'it@e(`$st,0,`$st.Len@gt'h)",
   "sc@ht'ask@s '/cr@eat'e",
   "Se@t-M'pPr@e'fer@en'ce",
   "Alw@ay'sIns@t@al'lEle@vat'ed",
   "ru'n@as",
   "Ad'd-Exf@il'trati@on",
   "Ad@d-Pe'rs@ist'en@ce",
   "@Ad'd-@RegB'ack@do'or",
   "Ad'd-Sc@r'nSav@eBa'ck@doo'r",
   "E@nab'le@d-'Dup@li'cat@eTo'k@en",
   "Ge@t'-Key@strok'e@s",
   "LS'ASe@cr'e@t",
   "Ge't-Pa's@sHa's@h",
   "'G@et-Re@gAl'way@sI'nst@all'Ele'va@t@ed",
   "Ge@t-S'cre@en'shot",
   "G'e@t-Ser@vi'ceUn'qu@oted",
   "Ge't-@Syst'em",
   "Get'-V@@ed'en@tial",
   "In@vo'ke-B@yp'assU'AC"
   "Inv@ok@e-Dl@lI'nj@ecti'o@n",
   "In'vo@ke-M@imi@ki'tt@e'nz",
   "Inv'ok@e-PS'I'nj@ec't",
   "I@nv'ok@e-P'sEx@ec",
   "I@nv@ok@e-'Ru@nA's"
   "In@vo'ke-W@Scr'iptB@yp@as'sU@A'C",
   "O'u@t-@Mini'd@um'p",
   "Am@siB'yp@as's",
   "ni@sh'a@ng",
   "Inv'ok@e-S@he'll@Co'mm@and",
   "@-dum'pc@r",
   "SeI@mp'erso@na'te",
   "SeDe'bu@gPri'vi@leg'e",
   "cra@ck'map@ex'e@c",
   "ls@ad'ump:':s@a'm",
   "SEK'UR@LS'A:@:Pt'h",
   "ke'r@ber'os:':p@tt",
   "k'erb@ero's::go@ld'en",
   "s@eku'rl@sa:':mi@nid'u@mp",
   "sek'u@rls'a:@:log@o'nPas@s'wor@ds",
   "to'ke@n:':el'ev@at'e",
   "in@vok'e-@com'ma@nd",
   "ru'ndl@l3'2@",
   "ce'r@tu'ti@l",
   "m@sh't@a",
   "we'v@tut@il.e'x'e' c@l'",
   "S@hel'lE'xec@ut@e",
   "sc s@to'p @Win@Defe'nd",
   "@Rem'ove-@MpT'h're@at",
   "s@'c s@top 'Se@n'se",
   "a@@ms'i_d'is@ab@l'e",
   "@lsa's'@@'s.e'x'e",
   "we@vtu't@il @c'l'",
   "a'msi@co@@n'text",
   "sy'st@em.@net'.w@ebc@li'e@nt",
   "'Sys@t'em.@Man'age@me'nt.'Au@tom'at@io'n.",
   "@-Di@sa@bleI@OA'V'Pr@ote@c'ti@on @`$tr@ue",
   "-D@isa@bleRe@al'ti@m'ePro'te@cti@o'n `$tru@e",
   "-D@isa@bleRe@al'ti@meM'o'@nito@ri@n'g `$tr'ue",
   "S@ys'tem.Run@tim'e.@Int'er@opSer'vi@ces@.'Ma@rs@ha'l",
   "H@KL'M:\SO'FTW@A'RE\Mi@cr'os@oft\A'MS@I@\Pro'vi@de'rs",
   "M@pCm'dR'u@@n.e'x'e -@Rem'oveD@ef'in@iti'o@ns -'Al@l",
   "'-Dis@abl@eIntr@us'ionP@re've@nt'ionS'y'@ste'm `$tr@ue"
)


$HigthRate = "'-Dis@abl@eIntr@us'ionP@re've@nt'ionS'y'@ste'm `$tr@ue|M@pCm'dR'u@@n.e'x'e -@Rem'oveD@ef'in@iti'o@ns -'Al@l|-D@isa@bleRe@al'ti@meM'o'@nito@ri@n'g `$tr'ue|-D@isa@bleRe@al'ti@m'ePro'te@cti@o'n `$tru@e|@-Di@sa@bleI@OA'V'Pr@ote@c'ti@on @`$tr@ue|a'msi@co@@n'text|a@@ms'i_d'is@ab@l'e|S@hel'lE'xec@ut@e|'I@E'X@|-'e@n'c|-n'o@p|a'ms@i|c'md @/c'|pa@yl'o@ad|mim@ik'at@z|A'dd@-T'y@p'e|-@en'c@od'ed|Ex@clu'sio@nP'at@h|A@ms'iSc'an@Bu@f'fe@r|i'nv@o'ke-@mim'ik@a'tz|-'en@cod'edco@mm'and|Exc@lu'sionPr@oc@e'ss|In@vok'e-'Ex@pres'si@on|am'si@ut'il@s|ams'iI@ni'tFa@il@e'd|ls'a @se'cr@et@s|im'pac'@et|pr@ocd'u@mp|pw'd@um'p|by'pa@s@@s ua'@c|u'a@c by@p'a@ss|po@we'rsh@ell '-e@p by'pa@s's|Defi@neDy'namicAs@se'mbly|De'fi@neDyn'amic@Mo'du@le|De'fi@neT'yp@e|D@efi'neC@on'str@uc'tor|Cr@ea'teT@yp'e|De@fi@neLi'te@ra@l|D'ef@in'eEn@um|D@ef'in@eFi'el@d|I'LGe@ne'ra@tor|E@mi't|De'fi@nePIn@vok'eMet@ho'd|G@etT'yp@e's|Ge'tAs@se'mbli@es|Ge'tCo@nst'ru@c@tor|G@etC'onst'ru@ct'ors|Ge@tE'ven@t|GetEvents|@Ge'tFi@el'd|G'etF@ie'l@ds|GetI'nte@rfa'ceM@ap|G'etIn@ter@f'ace|GetM@et'h@od|'Ge@tMe@tho@ds|G@etN'est@e'dTy@pe|GetN'est@edT'y@pe's|Ma@keA'rr@ayTy'p@e|Ma'keB@yRe'fTy@p'e|@Mak'eG@en'er@ic@T'y@pe|M@ak'ePoin'te@rT@y@pe|Dec@lar'ingMe@t'ho@d|Decl@@ari'ngTy'p@e|T@yp'eHa'nd@le|Typ'eIn@it'ia@li@z'er|Int'er@opSer'vi@c'es|Al'locH@Glo@b'a@l|'Pt@rT'oStr'uc@t'ur@e|St@ruc'tur@eT'oP@t'r|Fre@eH'Gl'ob@al|'I@ntP't@r|Memo'rySt@re'am|De@fla'teSt'r@eam|@Fro'mBa@s'e6@4S't@ri'ng|En'cod@edC'om'm@a@nd|'T@oBa'se6'4@@Str'in@g|Ope'nPro'c@ess|'V@ir't@ualA@ll'oc|Vir't@ualF'r@ee|Wr'it@ePro@ce'ssM'em@o'ry|Cre@at'eUs'erT@hr@e'ad|Clo@seHa'nd@le|ke'rn@el@3'2|GetD@ele'gateF'or@Fu'nct@io'nPo'int@e'r|@C're'a@teTh@r'ead|me'mc@p'y|Ge@tPr'oc@A'dd@@r@es's|Vir@tu@alPr'ot@e'ct|Rea'dPr@oc@essM'em@or'y|Cr@ea'teRe'moteTh@re'ad|@Wr'iteBy@t'e|Adj@us'tTok'en@Pr@ivi'leg@e's|Wr'it@eIn@t3'2@|Ope'nTh@re'adT@ok'en|P@trT'oStr'in@g|Ze@roFr'eeGl@obalA@ll'ocUn@ic'od@e|Op'enPr@oc'essT@o'ke@n|Ge@tTok'enIn@fo'rm@at'i@on|S@etT'hr@ea'dTok'e@n|Im@pe'rs@ona'teLo@gg'edOn@U's@er|@Re've@rtT'oS@e'l@f|Cr@ea'tePro@ce@s'sWi'thT@ok'en@|D'up@lic'ateT'ok@enE'x'|Ope'nWi@ndo'wSta@ti@o'n|Mi'niD@um'pWr@i'teD'um@p@|@G'etPr@oce'ssH@an'dl@e|Ge'tAs'yncK@eyS'ta@t'e|Ge@tKe'ybo@ar@dS@ta'te|@No@nPu'b@li@'c@|Pro'tec@te'dE've@ntL@og@g'in@g«|@wh'ile(`$tr@u'e)|pow'ers@hell @-'ve@rs'ion @@2'|@r@u'n'a@s|Se@tVa'lue(`$n@ull,`$tr'u@e)|.W@ri'te(`$st,0,`$st.Le'ng@t'h)|@sch@ta'sks@ '/@cr@e'at@e|Se@t-@M'pPref'er@e'nc@e|A'lw@ay'sInst@allE'lev'at@ed|Ad@d'-Ex@fil'tra@ti@on|@Ad@d-Pe'rs@is@t'en@ce'|Ad'd-@R'egBa@@ckd'o@o@r|A'dd@-'Sc@rnS'av@eBa'c@kd@oo'r|En'a@bl'ed-Du'plic@a'teTo@ke'n|Ge't-@Ke'yst@ro'k@e's|@LS'ASe@c're@t@|G'et-Pa'ssH@as'h@|Ge't-R@egA'lwa'ysIn@st@allE'lev@a't@e'd|@Get@-Se'rvi@ceU'nq@u'ote@d'|@Ge't-Sy@@s'te@'m|Ge@t-'Vau'ltCr@ede'nt@i'al|I'@nv'ok@e-@By'pa@@s's'U'@A'C@|Inv@o'ke-Dl@lI'nj@ec't@i@@o'n|@In@v'o'ke@-M'im@ik'it@t'e@@n'z|I'nv@oke-@P'SIn@je'c@t'|@'I@n'vo'k@e-Ps@E'x@e@@c|@In@v'ok@'@e-@R'u@nA'@s'@|@In@v'ok@'@e-W'Scr@ip'tBy@@pa's'sU@A'@C'|O'ut-Min'@id'um@p'|@Am'siB@ypa's@s|nish@a'ng|@-du'mp@cr|S@eImp'er@son'a@te@|S@eDe'bugP'r'i@vi@'@leg@e'|cr'a@ckm'ape@x'ec@|l@sad'u@mp:@:s'am'|S'EK@URL'SA:@:Pt'h@|ke@rbe'ro@s:':@pt't@|@kerb'e@ro's:@:go'l@d@@e'n|@sek'url@'@s'a:':min'id@u'm@@p'|se'kur@ls'a:@:@lo'gonPa@'ss@w@o'rds'|@tok@en:':el'ev@a't@e@|in'v@o'ke-@com'm@a'nd@|c'ert@ut@il|m'sh@t'a|sy'st@em'.@net.we'bcl@i'en@t''@|@Sy@st'em.@Man'ag@@e'men@t'.Au@t'oma@t'io@n.'@'|Sy'st@em'.@Ru'n@'@ti@m'e.'Inte@r'opServ@i'ces@.Ma'rsh@a'l'|HK@L'M@:\SO'FT@@WA'R'E\Micr@oso'ft@\A'M@@S'I@\Pro'vi@de'rs@'"


## Internal 
$ScanStartTimer = (Get-Date)
$HigthRate = $HigthRate -replace '(@|'')','' -replace '\\','\\'
$ScriptDescription = (Gci -Path "$FileToScan" -EA SilentlyContinue)
$MaliciousKeywordsList = $MaliciousKeywordsList -replace '(@|'')','' -replace '\\','\\'
If((Get-MpComputerStatus).RealTimeProtectionEnabled -match '^(True)$' -and (-not($Ams1.IsPresent)))
{
   write-host "`n[KO] Its advice to disable windows defender RealTime Protection.`n`n" -ForegroundColor Red
   Start-Sleep -Seconds 1
}

If(-not(Test-Path -Path "$FileToScan" -EA SilentlyContinue))
{
   write-host "`n[KO] Not found: '$FileToScan'`n" -ForegroundColor Red
   return
}

If(-not($FileToScan -imatch '(.ps1|.psm1)$'))
{
   write-host "`n[KO] This cmdlet only accepts [.ps1|.psm1] scripts" -ForegroundColor Red
   write-host "     FileToScan: '" -NoNewline
   write-host "$FileToScan" -ForegroundColor Green -NoNewline
   write-host "'`n"
   return
}


## Disclamer
$MsgBoxTitle = "                                     Identify_Offencive_Tools  (IOT)"
$MsgBoxText = "All the strings contained in this cmdlet list were found in diferent web sites since microssoft oficial documentation until free sources. This script it will not make any complicated scans, but it helps developers to review huge files for suspicious strings [ams1] and act accordingly ."
powershell (New-Object -ComObject Wscript.Shell).Popup("$MsgBoxText",0,"$MsgBoxTitle",0+64)|Out-Null

## Header
$CurrentTime = (Get-Date).ToString()
$Tamanho = $ScriptDescription.Length
$LastAccess = $ScriptDescription.LastAccessTime.ToString()
write-host "- File size     : $Tamanho"
write-host "- Current Time  : $CurrentTime"
write-host "- Last access   : $LastAccess"
write-host "- File to scan  : " -NoNewline
write-host "$FileToScan" -ForegroundColor Green
If($LogFile.IsPresent)
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create logfile header function
   #>

   echo "Computer: $((Get-WmiObject Win32_OperatingSystem).CSName)" > "$pwd\identify_offencive_tools.log"
   echo "$((Get-WmiObject Win32_OperatingSystem).Caption) - $((Get-WmiObject Win32_OperatingSystem).OSArchitecture)" >> "$pwd\identify_offencive_tools.log"
   echo "Identify_Offencive_Tools - $CurrentTime`n" >> "$pwd\identify_offencive_tools.log"

   write-host "- Logfile       : " -NoNewline
   write-host "$pwd\identify_offencive_tools.log" -ForegroundColor DarkYellow
}
write-host "`n[SF] " -ForegroundColor Green -NoNewline
write-host "Scanning file ... "
Start-Sleep -Seconds 2


$Hight = 0 ## Set counter to 0
$Counter = 0 ## Set counter to 0
ForEach($RawStringDetection in $MaliciousKeywordsList)
{
   ## Search for strings or regex inside file
   $MatchedString = (Get-Content -Path "$FileToScan"|Select-String -Pattern "($RawStringDetection)" -EA SilentlyContinue)
   If($MatchedString -iMatch "$RawStringDetection")
   {
      $ColorSet = "DarkYellow"
      If($RawStringDetection -imatch "($HigthRate)")
      {
         $ColorSet = "Red"
         $Hight = $Hight + 1
      }

      ## Get file description
      $Description = (Get-ChildItem -Path "$FileToScan"|Select-Object *)
      $Name = $Description.PSChildName
      $Line = $MatchedString.LineNumber
      $Counter = $Counter + 1

      ## Output results OnScreen
      write-host "`nToken           : $Counter"
      write-host "MaliciousString : " -NoNewline
      write-host "$RawStringDetection" -ForegroundColor $ColorSet
      write-host "LineNumber      : $Line"

      ## Logfile creation
      If($LogFile.IsPresent)
      {
         echo "`nToken           : $Counter" >> "$pwd\identify_offencive_tools.log"
         echo "MaliciousString : $RawStringDetection" >> "$pwd\identify_offencive_tools.log"
         echo "LineNumber      : $Line" >> "$pwd\identify_offencive_tools.log"
         echo "FileToScan      : $FileToScan" >> "$pwd\identify_offencive_tools.log"
      }

   }
}


If($Counter -gt 0)
{
   write-host "`n`n[OK] " -ForegroundColor Green -NoNewline
   write-host "Total of tokens found: [" -NoNewline
   write-host "$Counter" -ForegroundColor Yellow -NoNewline
   write-host "] off [" -NoNewline
   write-host "299" -ForegroundColor Yellow -NoNewline
   write-host "] tokens."

   write-host "[OK] " -ForegroundColor Green -NoNewline
   write-host "Of witch [" -NoNewline
   write-host "$Hight" -ForegroundColor Red -NoNewline
   write-host "] results deserves urgent attention."

   If($LogFile.IsPresent)
   {
      write-host "[OK] " -ForegroundColor Green -NoNewline
      write-host "Logfile: '$pwd\identify_offencive_tools.log'"
   }
}
Else
{
   write-host "[OK] " -ForegroundColor Green -NoNewline
   write-host "congratz, cmdlet didnt find any suspicious strings inside script. "
   Remove-Item -Path "$pwd\identify_offencive_tools.log" -Force
}


If($Ams1.IsPresent)
{
   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Scan file with AMS1 engine

   .NOTES
      If threats were found, you will get a notification from
      Windows Security to click/tap on to see and take actions.
   #>

   ## Make sure AMS1 is running
   If((Get-MpComputerStatus).RealTimeProtectionEnabled -match '^(False)$')
   {
      write-host "`n[KO] Enable windows defender RealTime Protection to run -am`s1.`n" -ForegroundColor Red
      return
   }

   write-host "`n[SF] " -ForegroundColor Green -NoNewline
   write-host "Scanning file with AM`S1"
   Update-MpSignature;Start-MpScan -ScanType CustomScan -ScanPath "$FileToScan"
}


## Internal CmdLet Clock Timmer
$ElapsTime = $(Get-Date) - $ScanStartTimer
$TotalTime = "{0:HH:mm:ss}" -f ([datetime]$ElapsTime.Ticks) ## Count the diferense between 'start|end' scan duration!
## Display information results OnScreen
Write-Host "[OK] " -ForegroundColor Green -NoNewline
Write-Host "Cmdlet_Total_Scan_Time: [" -NoNewline
Write-Host "$TotalTime" -ForegroundColor Yellow -NoNewline
write-host "]`n"