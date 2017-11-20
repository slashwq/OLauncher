#NoEnv
#Persistent
#SingleInstance, Force
SendMode, Input
SetWorkingDir, %A_ScriptDir%

; Application Variables
Title                   := "OLauncher"
Version                 := "develop"
INI                     := "OLauncher.ini"
ErrorININotFound        := "This looks to be the first time this has been run! An INI has been written to this folder. Please modify it to your needs, then run the app again." ; ExitApp, 1
ErrorOriginNotFound     := "Origin doesn't seem to be installed. Please check your INI file and try running this again." ; ExitApp, 2
ErrorGameNotFound       := "The game listed doesn't seem to be installed. Please check your INI file and try running this again." ; ExitApp, 3
InfoRunningOrigin       := "Origin is not running. Launching Origin now."
InfoGameClosed          := "The game has been closed. Origin will close soon."

; Check for an INI file in the working directory.
IfNotExist, %A_WorkingDir%\%INI%
{	FileAppend,
	(
		[OLauncher]
		OriginInstallLocation=
		OriginEXE=Origin.exe
		GameInstallLocation=
		GameEXE=

		[Debug]
		; Debug shows message boxes with process IDs. Generally used to help
		; troubleshoot why OLauncher isn't launching a program correctly.
		Debug=0

		; Verbose shows tooltips that show if Origin needs to be launched and when
		; OLauncher detects that the game closes. It's not required, but can help
		; if Origin is closing in the middle of your game.
		Verbose=0
	), %A_WorkingDir%\%INI%
	MsgBox, 4160, %Title%, %ErrorININotFound%
	ExitApp, 1
	}

; Let's read this INI.
IniRead, OriginInstallLocation, %ini%, OLauncher, OriginInstallLocation
IniRead, OriginEXE, %ini%, OLauncher, OriginEXE
IniRead, GameInstallLocation, %ini%, OLauncher, GameInstallLocation
IniRead, GameEXE, %ini%, OLauncher, GameEXE
IniRead, Debug, %ini%, Debug, Debug

; How should we set up the tray menu?
If Debug = 0
  Menu, Tray, NoStandard
Menu, Tray, Tip, %Title% for %GameEXE%

; Let's verify what we read and make sure they exist.
IfNotExist, %OriginInstallLocation%\%OriginEXE%
{	MsgBox, 4160, %Title%, %ErrorOriginNotFound%
	ExitApp, 2
	}
IfNotExist,%GameInstallLocation%\%GameEXE%
{	MsgBox, 4160, %Title%, %ErrorGameNotFound%
  ExitApp, 3
	}

; Let's see if Origin is running.
Process, Exist, %OriginEXE%
If ErrorLevel = 0
{ If Verbose = 1
	  TrayTip, %Title%, %InfoRunningOrigin%, 10, 2
	Run, %OriginInstallLocation%\%OriginEXE%, , Min, OriginEXE_PID
  Process, Wait, %OriginEXE%
	Sleep, 5000 ; Origin needs some extra time to load into the background, otherwise we risk spawning a second Origin.
	If Debug = 1
	  MsgBox, 4160, %Title% - Debug, %OriginEXE% PID is %OriginEXE_PID%.
  }
Else
{	If Debug = 1
	  MsgBox, 4160, %Title% - Debug, %OriginEXE% PID is %ErrorLevel%
	}

; Now that Origin is running, let's run the game.
Run, %GameInstallLocation%\%GameEXE%, , , GameEXE_PID
Process, Wait, %GameEXE%
If Debug = 1
  MsgBox, 4160, %Title% - Debug, %GameEXE% PID is %GameEXE_PID%.

; Monitor the %GameEXE% process.
Loop
{ Sleep, 7500 ; We only want to check this every 7.5 seconds.
	Process, Exist, %GameEXE%
	If ErrorLevel = 0
	  Break
}
If Verbose = 1
  TrayTip, %Title%, %InfoGameClosed%, 10, 1
Sleep, 10000 ; Give Origin 10 seconds to sync saves, change game states, etc.
Process, Close, %OriginEXE%

; Delete debug.log, this is spawning after loading ME:A.
Sleep, 5000 ; Give Origin time to properly close, otherwise we can't delete the files below.
FileDelete, debug.log

; Close out of OLauncher.
ExitApp, 0
