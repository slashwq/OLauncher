/*
================================================================
> OLauncher
> Originally created by William Quinn (Hyp5r)
> william@hyp5r.io
> https://github.com/Hyp5r/OLauncher
> Please leave this comment if you decide to modify this script!
================================================================
*/

#NoEnv
#Persistent
#SingleInstance, Force
SendMode, Input
SetWorkingDir, %A_ScriptDir%

; Application Variables
Title                   := "OLauncher"
Version                 := "2.4-r4"
ErrorININotFound        := "This looks to be the first time this has been run, or you didn't pass the four required launch options. An INI has been written to this folder. Please modify it to your needs, then run the app again." ; ExitApp, 1
ErrorOriginNotFound     := "Origin doesn't seem to be installed. Please check your launch arguments or your INI file and try running this again." ; ExitApp, 2
ErrorGameNotFound       := "The game listed doesn't seem to be installed. Please check your launch arguments or your INI file and try running this again." ; ExitApp, 3
ErrorOriginLaunchFailed := "Origin failed to launch correctly. You may want to check and see if Origin will run without using this script." ; ExitApp, 4
ErrorGameLaunchFailed   := "The game failed to launch correctly. You may want to check and see if the game will run without using this script." ; ExitApp, 5
InfoRunningOrigin       := "Origin is not running. Launching Origin now."
InfoGameClosed          := "The game has been closed. Origin will close soon."

; Staging Variables
OriginInstallLocation   := "N/A"
OriginEXE               := "N/A"
GameInstallLocation     := "N/A"
GameEXE                 := "N/A"
RunAsAdmin              := "N/A"
CloseOriginAfter        := "N/A"
Debug                   := "N/A"
Verbose                 := "N/A"

; How should we set up the tray menu?
Menu, Tray, Add, %Title% %Version%, ReturnLabel
Menu, Tray, Add, Running %GameEXE%, ReturnLabel
Menu, Tray, Add
Menu, Tray, Add, Close %Title%, TrayClose
Menu, Tray, Disable, %Title% %Version%
Menu, Tray, Disable, Running %GameEXE%
Menu, Tray, Tip, %Title% %Version%`nRunning %GameEXE%
Menu, Tray, NoStandard

; Check if switches were passed to OLauncher.
If 0 >= 4 ; We need at least 4 switches passed before we even consider looking at them.
{ OriginInstallLocation = %1%
  OriginEXE = %2%
  GameInstallLocation = %3%
  GameEXE = %4%
  RunAsAdmin = %5%
  If RunAsAdmin =
    RunAsAdmin := "0"
	CloseOriginAfter = %6%
	Debug = %7%
	If Debug =
	  Debug := "0"
	Verbose = %8%
	If Verbose =
	  Verbose := "0"
  Menu, Tray, Rename, Running N/A, Running %GameEXE%
  Menu, Tray, Tip, %Title% %Version%`nRunning %GameEXE%
  Gosub, Verify ; We don't need to read an INI file, let's skip it.
  }
Else
{	IfExist, %A_WorkingDir%\%A_ScriptName%.ini ; So, we don't have switches, do we have an INI?
	{ IniRead, OriginInstallLocation, %A_ScriptName%.ini, OLauncher, OriginInstallLocation
	  IniRead, OriginEXE, %A_ScriptName%.ini, OLauncher, OriginEXE
	  IniRead, GameInstallLocation, %A_ScriptName%.ini, OLauncher, GameInstallLocation
	  IniRead, GameEXE, %A_ScriptName%.ini, OLauncher, GameEXE
    IniRead, RunAsAdmin, %A_ScriptName%.ini, OLauncher, RunAsAdmin
		IniRead, CloseOriginAfter, %A_ScriptName%.ini, OLauncher, CloseOriginAfter
	  IniRead, Debug, %A_ScriptName%.ini, Debug, Debug
		IniRead, Verbose, %A_ScriptName%.ini, Debug, Verbose
    Menu, Tray, Rename, Running N/A, Running %GameEXE%
    Menu, Tray, Tip, %Title% %Version%`nRunning %GameEXE%
	  }
	Else ; We don't have an INI, so let's make one and tell the user about it.
	{ FileAppend,
	  (
[OLauncher]
OriginInstallLocation=
OriginEXE=Origin.exe
GameInstallLocation=
GameEXE=
RunAsAdmin=0
CloseOriginAfter=1

[Debug]
; Debug shows message boxes with process IDs. Generally used to help
; troubleshoot why OLauncher isn't launching a program correctly.
Debug=0

; Verbose shows tooltips that show if Origin needs to be launched and when
; OLauncher detects that the game closes. It's not required, but can help
; if Origin is closing in the middle of your game.
Verbose=0
    ), %A_WorkingDir%\%A_ScriptName%.ini
	  MsgBox, 4160, %Title%, %ErrorININotFound%
	  ExitApp, 1
    }
	}

; Let's verify what we read and make sure they exist.
Verify:
IfNotExist, %OriginInstallLocation%\%OriginEXE%
{	MsgBox, 4160, %Title%, %ErrorOriginNotFound%
	ExitApp, 2
	}
IfNotExist,%GameInstallLocation%\%GameEXE%
{	MsgBox, 4160, %Title%, %ErrorGameNotFound%
  ExitApp, 3
	}

; Was RunAsAdmin configured? We may need to reload the entire script.
If RunAsAdmin = 1
{ If Not A_IsAdmin
  { FileDelete, %A_WorkingDir%\%A_ScriptName%.ini
    FileAppend,
	  (
; OLauncher was run as an administrator, so this INI was saved
; automatically at %A_Now%.
[OLauncher]
OriginInstallLocation=%OriginInstallLocation%
OriginEXE=%OriginEXE%
GameInstallLocation=%GameInstallLocation%
GameEXE=%GameEXE%
RunAsAdmin=%RunAsAdmin%
CloseOriginAfter=%CloseOriginAfter%

[Debug]
Debug=%Debug%
Verbose=%Verbose%
    ), %A_WorkingDir%\%A_ScriptName%.ini
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
    }
  }

; Let's see if Origin is running.
Process, Exist, %OriginEXE%
If ErrorLevel = 0
{ If Verbose = 1
	  TrayTip, %Title%, %InfoRunningOrigin%, 10, 2
	Run, %OriginInstallLocation%\%OriginEXE%, %A_Temp%, Min UseErrorLevel, OriginEXE_PID
  If ErrorLevel = ERROR
  { MsgBox, 4160, %Title%, %ErrorOriginLaunchFailed%
    ExitApp, 4
    }
  Process, Wait, %OriginEXE%
	Sleep, 10000 ; Origin needs some extra time to load into the background, otherwise we risk spawning a second Origin.
	If Debug = 1
	  MsgBox, 4160, %Title% - Debug, %OriginEXE% PID is %OriginEXE_PID%.
  }
Else
{	If Debug = 1
	  MsgBox, 4160, %Title% - Debug, %OriginEXE% PID is %ErrorLevel%
	}

; Now that Origin is running, let's run the game.
Run, %GameInstallLocation%\%GameEXE%, , UseErrorLevel, GameEXE_PID
If ErrorLevel = ERROR
{ MsgBox, 4160, %Title%, %ErrorGameLaunchFailed%
  ExitApp, 5
  }
Process, Wait, %GameEXE%
If Debug = 1
  MsgBox, 4160, %Title% - Debug, %GameEXE% PID is %GameEXE_PID%.

; Monitor the %GameEXE% process.
Sleep, 15000 ; We'll start off by sleeping a bit before we really monitor.
Loop
{ Sleep, 15000 ; We only want to check this every 15 seconds.
	Process, Exist, %GameEXE%
	If ErrorLevel = 0
	  Break
  }
If Verbose = 1
  TrayTip, %Title%, %InfoGameClosed%, 10, 1
Sleep, 7500 ; Give Origin 7.5 seconds to sync saves, change game states, etc.

; Check to see if the user wants Origin closed or not.
If CloseOriginAfter = 1
  Process, Close, %OriginEXE%

; Close out of OLauncher.
ExitApp, 0

ReturnLabel:
Return

TrayClose:
ExitApp, 0
