; --------------------------------
; BEGINNING VARIABLES
; --------------------------------
#NoEnv
#Persistent
#SingleInstance,Force
SendMode,Input
SetWorkingDir,%A_ScriptDir%

; --------------------------------
; TRAY MENU
; --------------------------------
Menu,Tray,NoStandard
Menu,Tray,Add,Force Close OLauncher,TrayExit

; --------------------------------
; FAILSAFE - OLauncher.ini
; --------------------------------
IfNotExist,%A_ScriptDir%\OLauncher.ini
	{
	FileInstall,OLauncher.example.ini,%A_ScriptDir%\OLauncher.ini,0
	FileInstall,Readme.txt,%A_ScriptDir%\Readme.txt
	MsgBox,4160,OLauncher,OLauncher.ini has been created.  Edit it to your needs, then place OLauncher.exe and OLauncher.ini where you like.
	ExitApp
	}	
	
; --------------------------------
; VARIABLES
; --------------------------------
FileReadLine,oPATH,%A_ScriptDir%\OLauncher.ini,3	;oPATH
oEXE = Origin.exe									;oEXE
FileReadLine,pPATH,%A_ScriptDir%\OLauncher.ini,7	;pPATH
FileReadLine,pEXE,%A_ScriptDir%\OLauncher.ini,11	;pEXE

; --------------------------------
; FAILSAFE - Variables
; --------------------------------
IfNotExist,%oPATH%\%oEXE%
	{
	MsgBox,4160,OLauncher,Error 1`nOrigin not found`n`nPlease check your OLauncher.ini file and try again.
	ExitApp
	}
IfNotExist,%pPATH%\%pEXE%
	{
	MsgBox,4160,OLauncher,Error 2`nApplication not found`n`nPlease check your OLauncher.ini file and try again.
	ExitApp
	}
	
; --------------------------------
; LAUNCH CODE
; --------------------------------
Process,Exist,%oEXE%
if ErrorLevel
	{
	Process,Close,%oEXE%
	TrayTip,OLauncher,Origin was killed since it was already running.,10,2
	Sleep,5000				; Give Windows some time alone after Origin is killed
	}
Run,%oPATH%\%oEXE%
WinWaitActive,Origin
Sleep,30000					; To allow Origin time to launch
Run,%pPATH%\%pEXE%
Sleep,5000					; Give time for the application to open Origin
Process,Wait,%pEXE%			; Verify if the program is running
Process,WaitClose,%pEXE%	; Keep an eye out when the program shuts down
if ErrorLevel = 0
	{
	MsgBox,4132,OLauncher,Would you like Origin to stay running?`n`nIf you use cloud saves, you may want to choose Yes so your saves are synced successfully.
	IfMsgBox,YES
		{
		ExitApp
		}
	else
		{
		Process,Close,%oEXE%
		TrayTip,OLauncher,Origin was killed by the user.,10,1
		Sleep,10000
		ExitApp
		}
	}

TrayExit:
	{
	Critical
		{
		TrayTip,OLauncher,OLauncher will be killed in 10 seconds.
		Sleep,10000
		ExitApp
		}
	}