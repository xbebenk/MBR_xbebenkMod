; #FUNCTION# ====================================================================================================================
; Name ..........: MBR Bot
; Description ...: This file contains the initialization and main loop sequences f0r the MBR Bot
; Author ........:  (2014)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; AutoIt pragmas
#NoTrayIcon
#RequireAdmin
#AutoIt3Wrapper_UseX64=7n
;#AutoIt3Wrapper_Res_HiDpi=Y ; HiDpi will be set during run-time!
;#AutoIt3Wrapper_Run_AU3Check=n ; enable when running in folder with umlauts!
#AutoIt3Wrapper_Run_Au3Stripper=n
#Au3Stripper_Parameters=/rsln /MI=3

#include "MyBot.run.version.au3"
#pragma compile(ProductName, My Bot)
#pragma compile(Out, MyBot.run.exe) ; Required

; Enforce variable declarations
Opt("MustDeclareVars", 1)

Global $g_sBotTitle = "" ;~ Don't assign any title here, use Func UpdateBotTitle()
Global $g_hFrmBot = 0 ; The main GUI window

; MBR includes
#include "COCBot\MBR Global Variables.au3"
#include "COCBot\functions\Config\DelayTimes.au3"
#include "COCBot\GUI\MBR GUI Design Splash.au3"
#include "COCBot\functions\Config\ScreenCoordinates.au3"
#include "COCBot\functions\Config\ImageDirectories.au3"
#include "COCBot\functions\Other\ExtMsgBox.au3"
#include "COCBot\functions\Other\MBRFunc.au3"
#include "COCBot\functions\Android\Android.au3"
#include "COCBot\functions\Android\Distributors.au3"
#include "COCBot\MBR GUI Design.au3"
#include "COCBot\MBR GUI Control.au3"
#include "COCBot\MBR Functions.au3"
#include "COCBot\functions\Other\Multilanguage.au3"
; MBR References.au3 must be last include
#include "COCBot\MBR References.au3"

;#include "C:\Test420\Test420.au3"

; Autoit Options
Opt("GUIResizeMode", $GUI_DOCKALL) ; Default resize mode for dock android support
Opt("GUIEventOptions", 1) ; Handle minimize and restore for dock android support
Opt("GUICloseOnESC", 0) ; Don't send the $GUI_EVENT_CLOSE message when ESC is pressed.
Opt("WinTitleMatchMode", 3) ; Window Title exact match mode
Opt("GUIOnEventMode", 1)
Opt("MouseClickDelay", GetClickUpDelay()) ;Default: 10 milliseconds
Opt("MouseClickDownDelay", GetClickDownDelay()) ;Default: 5 milliseconds
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)

; All executable code is in a function block, to detect coding errors, such as variable declaration scope problems
InitializeBot()
; Get All Emulators installed on machine.
getAllEmulators()

; Hand over control to main loop
MainLoop(CheckPrerequisites())

Func UpdateBotTitle()
	Local $sTitle = "My Bot " & $g_sBotVersion
	Local $sConsoleTitle ; Console title has also Android Emulator Name
	If $g_sBotTitle = "" Then
		$g_sBotTitle = $sTitle
		$sConsoleTitle = $sTitle
	Else
		$g_sBotTitle = $sTitle & " (" & ($g_sAndroidInstance <> "" ? $g_sAndroidInstance : $g_sAndroidEmulator) & ")" ;Do not change this. If you do, multiple instances will not work.
		$sConsoleTitle = $sTitle & " " & $g_sAndroidEmulator & " (" & ($g_sAndroidInstance <> "" ? $g_sAndroidInstance : $g_sAndroidEmulator) & ")"
	EndIf
	If $g_hFrmBot <> 0 Then
		; Update Bot Window Title also
		WinSetTitle($g_hFrmBot, "", $g_sBotTitle)
		GUICtrlSetData($g_hLblBotTitle, $g_sBotTitle)
	EndIf
	; Update Console Window (if it exists)
	DllCall("kernel32.dll", "bool", "SetConsoleTitle", "str", "Console " & $sConsoleTitle)
	; Update try icon title
	TraySetToolTip($g_sBotTitle)

	SetDebugLog("Bot title updated to: " & $g_sBotTitle)
EndFunc   ;==>UpdateBotTitle

Func InitializeBot()
	If @OSVersion = "WIN_10" And @OSBuild < 22000 Then ;only supported on win10, using osbuild to filter win11 as autoit v3.3.14.5 doesn't know win11 yet
		_VrtDesktObjCreation() ;virtual desktop object
		Local $NumVD = _GetEnumVirtDskt()
		If $NumVD = 1 Then _CreateNewVirtDskt()
    EndIf

	ProcessCommandLine()

	If FileExists(@ScriptDir & "\EnableMBRDebug.txt") Then ; Set developer mode
		$g_bDevMode = True
		Local $aText = FileReadToArray(@ScriptDir & "\EnableMBRDebug.txt") ; check if special debug flags set inside EnableMBRDebug.txt file
		If Not @error Then
			For $l = 0 To UBound($aText) - 1
				If StringInStr($aText[$l], "DISABLEWATCHDOG", $STR_NOCASESENSEBASIC) <> 0 Then
					$g_bBotLaunchOption_NoWatchdog = True
					SetDebugLog("Watch Dog disabled by Developer Mode File Command", $COLOR_INFO)
				EndIf
			Next
		EndIf
	EndIf

	SetupProfileFolder() ; Setup profile folders

	SetLogCentered(" BOT LOG ") ; Initial text for log

	SetSwitchAccLog(_PadStringCenter(" SwitchAcc LOG ", 25, "="), $COLOR_BLACK, "Lucida Console", 8, False)

	DetectLanguage()
	If $g_iBotLaunchOption_Help Then
		ShowCommandLineHelp()
		Exit
	EndIf

	InitAndroidConfig()

	; early load of config
	Local $bConfigRead = FileExists($g_sProfileConfigPath)
	If $bConfigRead Or FileExists($g_sProfileBuildingPath) Then
		readConfig()
	EndIf

	Local $sAndroidInfo = ""
	
	_ITaskBar_Init(False)
	_Crypt_Startup()
	__GDIPlus_Startup() ; Start GDI+ Engine (incl. a new thread)
	TCPStartup() ; Start the TCP service.

	;InitAndroidConfig()
	CreateMainGUI() ; Just create the main window
	CreateSplashScreen() ; Create splash window

	; Ensure watchdog is launched (requires Bot Window for messaging)
	If Not $g_bBotLaunchOption_NoWatchdog Then LaunchWatchdog()

	InitializeMBR($sAndroidInfo, $bConfigRead)

	; Create GUI
	CreateMainGUIControls() ; Create all GUI Controls
	InitializeMainGUI() ; setup GUI Controls

	; Files/folders
	SetupFilesAndFolders()

	; Show main GUI
	ShowMainGUI()

	If $g_iBotLaunchOption_Dock Then
		If AndroidEmbed(True) And $g_iBotLaunchOption_Dock = 2 And $g_bCustomTitleBarActive Then
			BotShrinkExpandToggle()
		EndIf
	EndIf

	; Some final setup steps and checks
	FinalInitialization($sAndroidInfo)

	;ProcessSetPriority(@AutoItPID, $iBotProcessPriority) ;~ Restore process priority

EndFunc   ;==>InitializeBot

; #FUNCTION# ====================================================================================================================
; Name ..........: ProcessCommandLine
; Description ...: Handle command line parameters
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func ProcessCommandLine()

	; Handle Command Line Launch Options and fill $g_asCmdLine
	If $CmdLine[0] > 0 Then
		For $i = 1 To $CmdLine[0]
			Local $bOptionDetected = True
			Switch $CmdLine[$i]
				; terminate bot if it exists (by window title!)
				Case "/restart", "/r", "-restart", "-r"
					$g_bBotLaunchOption_Restart = True
				Case "/autostart", "/a", "-autostart", "-a"
					$g_bBotLaunchOption_Autostart = True
				Case "/nowatchdog", "/nwd", "-nowatchdog", "-nwd"
					$g_bBotLaunchOption_NoWatchdog = True
				Case "/dpiaware", "/da", "-dpiaware", "-da"
					$g_bBotLaunchOption_ForceDpiAware = True
				Case "/dock1", "/d1", "-dock1", "-d1", "/dock", "/d", "-dock", "-d"
					$g_iBotLaunchOption_Dock = 1
				Case "/dock2", "/d2", "-dock2", "-d2"
					$g_iBotLaunchOption_Dock = 2
				Case "/nobotslot", "/nbs", "-nobotslot", "-nbs"
					$g_bBotLaunchOption_NoBotSlot = True
				Case "/debug", "/debugmode", "/dev", "/dm", "-debug", "-debugmode", "-dev", "-dm"
					$g_bDevMode = True
				Case "/minigui", "/mg", "-minigui", "-mg"
					$g_iGuiMode = 2
				Case "/nogui", "/ng", "-nogui", "-ng"
					$g_iGuiMode = 0
				Case "/hideandroid", "/ha", "-hideandroid", "-ha"
					$g_bBotLaunchOption_HideAndroid = True
				Case "/minimizebot", "/minbot", "/mb", "-minimizebot", "-minbot", "-mb"
					$g_bBotLaunchOption_MinimizeBot = True
				Case "/console", "/c", "-console", "-c"
					$g_iBotLaunchOption_Console = True
					ConsoleWindow()
				Case "/?", "/h", "/help", "-?", "-h", "-help"
					; show command line help and exit
					$g_iBotLaunchOption_Help = True
				Case Else
					If StringInStr($CmdLine[$i], "/guipid=") Then
						Local $guidpid = Int(StringMid($CmdLine[$i], 9))
						If ProcessExists($guidpid) Then
							$g_iGuiPID = $guidpid
						Else
							SetDebugLog("GUI Process doesn't exist: " & $guidpid)
						EndIf
					ElseIf StringInStr($CmdLine[$i], "/profiles=") = 1 Then
						Local $sProfilePath = StringMid($CmdLine[$i], 11)
						If StringInStr(FileGetAttrib($sProfilePath), "D") Then
							$g_sProfilePath = $sProfilePath
						Else
							SetLog("Profiles Path doesn't exist: " & $sProfilePath, $COLOR_ERROR) ;
						EndIf
					Else
						$bOptionDetected = False
						$g_asCmdLine[0] += 1
						ReDim $g_asCmdLine[$g_asCmdLine[0] + 1]
						$g_asCmdLine[$g_asCmdLine[0]] = $CmdLine[$i]
					EndIf
			EndSwitch
			If $bOptionDetected Then SetDebugLog("Command Line Option detected: " & $CmdLine[$i])
		Next
	EndIf

	; Handle Command Line Parameters
	If $g_asCmdLine[0] > 0 Then
		$g_sProfileCurrentName = StringRegExpReplace($g_asCmdLine[1], '[/:*?"<>|]', '_')
	ElseIf FileExists($g_sProfilePath & "\profile.ini") Then
		$g_sProfileCurrentName = StringRegExpReplace(IniRead($g_sProfilePath & "\profile.ini", "general", "defaultprofile", ""), '[/:*?"<>|]', '_')
		If $g_sProfileCurrentName = "" Or Not FileExists($g_sProfilePath & "\" & $g_sProfileCurrentName) Then $g_sProfileCurrentName = "<No Profiles>"
	Else
		$g_sProfileCurrentName = "<No Profiles>"
	EndIf
EndFunc   ;==>ProcessCommandLine

; #FUNCTION# ====================================================================================================================
; Name ..........: InitializeAndroid
; Description ...: Initialize Android
; Syntax ........:
; Parameters ....: $bConfigRead - if config was already read and Android Emulator info loaded
; Return values .: None
; Author ........:
; Modified ......: cosote (Feb-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func InitializeAndroid($bConfigRead)

	Local $s = GetTranslatedFileIni("MBR GUI Design - Loading", "StatusBar_Item_06", "Initializing Android...")
	SplashStep($s)

	If $g_bBotLaunchOption_Restart = False Then
		; Change Android type and update variable
		If $g_asCmdLine[0] > 1 Then
			; initialize Android config
			InitAndroidConfig(True)

			Local $i
			For $i = 0 To UBound($g_avAndroidAppConfig) - 1
				If StringCompare($g_avAndroidAppConfig[$i][0], $g_asCmdLine[2]) = 0 Then
					$g_iAndroidConfig = $i
					SplashStep($s & "(" & $g_avAndroidAppConfig[$i][0] & ")...", False)
					If $g_avAndroidAppConfig[$i][1] <> "" And $g_asCmdLine[0] > 2 Then
						; Use Instance Name
						UpdateAndroidConfig($g_asCmdLine[3])
					Else
						UpdateAndroidConfig()
					EndIf
					SplashStep($s & "(" & $g_avAndroidAppConfig[$i][0] & ")", False)
					ExitLoop
				EndIf
			Next
		EndIf

		SplashStep(GetTranslatedFileIni("MBR GUI Design - Loading", "StatusBar_Item_07", "Detecting Android..."))
		If $g_asCmdLine[0] < 2 And Not $bConfigRead Then
			DetectRunningAndroid()
			If Not $g_bFoundRunningAndroid Then DetectInstalledAndroid()
		EndIf

	Else

		; just increase step
		SplashStep($s)

	EndIf

	CleanSecureFiles()

	GetCOCDistributors() ; load of distributors to prevent rare bot freeze during boot

EndFunc   ;==>InitializeAndroid

; #FUNCTION# ====================================================================================================================
; Name ..........: SetupProfileFolder
; Description ...: Populate profile-related globals
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func SetupProfileFolder()
	SetDebugLog("SetupProfileFolder: " & $g_sProfilePath & "\" & $g_sProfileCurrentName)
	$g_sProfileConfigPath = $g_sProfilePath & "\" & $g_sProfileCurrentName & "\config.ini"
	$g_sProfileBuildingStatsPath = $g_sProfilePath & "\" & $g_sProfileCurrentName & "\stats_buildings.ini"
	$g_sProfileBuildingPath = $g_sProfilePath & "\" & $g_sProfileCurrentName & "\building.ini"
	$g_sProfileLogsPath = $g_sProfilePath & "\" & $g_sProfileCurrentName & "\Logs\"
	$g_sProfileLootsPath = $g_sProfilePath & "\" & $g_sProfileCurrentName & "\Loots\"
	$g_sProfileTempPath = $g_sProfilePath & "\" & $g_sProfileCurrentName & "\Temp\"
	$g_sProfileTempDebugPath = $g_sProfilePath & "\" & $g_sProfileCurrentName & "\Temp\Debug\"
	
EndFunc   ;==>SetupProfileFolder

; #FUNCTION# ====================================================================================================================
; Name ..........: InitializeMBR
; Description ...: MBR setup routine
; Syntax ........:
; Parameters ....: $sAI - populated with AndroidInfo string in this function
;                  $bConfigRead - if config was already read and Android Emulator info loaded
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func InitializeMBR(ByRef $sAI, $bConfigRead)

	; license
	If Not FileExists(@ScriptDir & "\License.txt") Then
		Local $hDownload = InetGet("http://www.gnu.org/licenses/gpl-3.0.txt", @ScriptDir & "\License.txt")

		; Wait for the download to complete by monitoring when the 2nd index value of InetGetInfo returns True.
		Local $i = 0
		Do
			Sleep($DELAYDOWNLOADLICENSE)
			$i += 1
		Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE) Or $i > 25

		InetClose($hDownload)
	EndIf

	; multilanguage
	If Not FileExists(@ScriptDir & "\Languages") Then DirCreate(@ScriptDir & "\Languages")
	;DetectLanguage()
	_ReadFullIni()
	; must be called after language is detected
	TranslateTroopNames()
	InitializeCOCDistributors()

	; check for compiled x64 version
	Local $sMsg = GetTranslatedFileIni("MBR GUI Design - Loading", "Compile_Script", "Don't Run/Compile the Script as (x64)! Try to Run/Compile the Script as (x86) to get the bot to work.\r\n\r\n" & _
			"If this message still appears, try to re-install AutoIt.\r\n")
	If @AutoItX64 = 1 Then
		DestroySplashScreen()
		MsgBox(0, "", $sMsg)
		__GDIPlus_Shutdown()
		Exit
	EndIf

	Local $cmdLineHelp = GetTranslatedFileIni("MBR GUI Design - Loading", "Commandline_multiple_Bots","You can start multiple Bots by using the commandline (or a shortcut) :\r\n\r\n" & _
			"MyBot.run.exe [ProfileName] [EmulatorName] [InstanceName]\r\n\r\n" & _
			"If a profilename contains a {space}, then enclose the profilename in double quotes).\r\n\r\n" & _
			"For second instance of Bot, specify the Emulator and Instance name\r\n\r\n" & _
			"Supported Emulators are MEmu, Nox, BlueStacks5\r\n" & _
			"Examples of command line:\r\n" & _
			"     MyBot.run.exe MyVillage\r\n" & _
			"     MyBot.run.exe MyVillage1 BlueStacks5 Pie64_1\r\n" & _
			"     MyBot.run.au3 ""My Village 2"" BlueStacks5 Pie64_2")

	; Initialize Android emulator
	InitializeAndroid($bConfigRead)

	; Update Bot title
	UpdateBotTitle()
	UpdateSplashTitle($g_sBotTitle & GetTranslatedFileIni("MBR GUI Design - Loading", "Loading_Profile", ", Profile: %s", $g_sProfileCurrentName))

	If $g_bBotLaunchOption_Restart = True Then
		If CloseRunningBot($g_sBotTitle, True) Then
			SplashStep(GetTranslatedFileIni("MBR GUI Design - Loading", "Closing_previous", "Closing previous bot..."), False)
			If CloseRunningBot($g_sBotTitle) = True Then
				; wait for Mutexes to get disposed
				Sleep(3000)
				; check if Android is running
				WinGetAndroidHandle()
				If $g_bBotLaunchOption_Restart Then
					Assign("g_PushedSharedPrefsProfile", $g_sProfileCurrentName)
					SetLog("g_PushedSharedPrefsProfile = " & $g_PushedSharedPrefsProfile)
				EndIf
			EndIf
		EndIf
	EndIf

	$g_hMutex_BotTitle = CreateMutex($g_sBotTitle)
	$sAI = GetTranslatedFileIni("MBR GUI Design - Loading", "Android_instance_01", "%s", $g_sAndroidEmulator)
	Local $sAndroidInfo2 = GetTranslatedFileIni("MBR GUI Design - Loading", "Android_instance_02", "%s (instance %s)", $g_sAndroidEmulator, $g_sAndroidInstance)
	If $g_sAndroidInstance <> "" Then
		$sAI = $sAndroidInfo2
	EndIf

	; Check if we are already running for this instance
	$sMsg = GetTranslatedFileIni("MBR GUI Design - Loading", "Msg_Android_instance_01", "My Bot for %s is already running.\r\n\r\n", $sAI)
	If $g_hMutex_BotTitle = 0 Then
		DestroySplashScreen()
		SetDebugLog($g_sBotTitle & " is already running, exit now")
		;SplashTextOn($g_sBotTitle,  $sMsg & $cmdLineHelp, $g_iSizeWGrpTab1 + 200, $g_iSizeHGrpTab1, Default, Default, BitOR($DLG_TEXTLEFT, $DLG_MOVEABLE), "Lucida Console", 10)
		;Sleep(10000)
		;SplashOff()
		MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION, $MB_TOPMOST), $g_sBotTitle, $sMsg & $cmdLineHelp)
		__GDIPlus_Shutdown()
		Exit
	EndIf

	$sMsg = GetTranslatedFileIni("MBR GUI Design - Loading", "Msg_Android_instance_02", "My Bot with Profile %s is already in use.\r\n\r\n", $g_sProfileCurrentName)
	; Check if we are already running for this profile
	If aquireProfileMutex() = 0 Then
		ReleaseMutex($g_hMutex_BotTitle)
		releaseProfilesMutex(True)
		DestroySplashScreen()
		MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION, $MB_TOPMOST), $g_sBotTitle, $sMsg & $cmdLineHelp)
		__GDIPlus_Shutdown()
		Exit
	EndIf

	; Get mutex
	$g_hMutex_MyBot = CreateMutex("MyBot.run")
	$g_bOnlyInstance = $g_hMutex_MyBot <> 0 ; And False
	SetDebugLog("My Bot is " & ($g_bOnlyInstance ? "" : "not ") & "the only running instance")

EndFunc   ;==>InitializeMBR

; #FUNCTION# ====================================================================================================================
; Name ..........: SetupFilesAndFolders
; Description ...: Checks for presence of needed files and folders, cleans up and creates as required
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func SetupFilesAndFolders()

	;Migrate old shared_prefs locations
	Local $sOldProfiles = @MyDocumentsDir & "\MyBot.run-Profiles"
	If FileExists($sOldProfiles) = 1 And FileExists($g_sPrivateProfilePath) = 0 Then
		SetLog("Moving shared_prefs profiles folder")
		If DirMove($sOldProfiles, $g_sPrivateProfilePath) = 0 Then
			SetLog("Error moving folder " & $sOldProfiles, $COLOR_ERROR)
			SetLog("to new location " & $g_sPrivateProfilePath, $COLOR_ERROR)
			SetLog("Please resolve manually!", $COLOR_ERROR)
		Else
			SetLog("Moved shared_prefs profiles to " & $g_sPrivateProfilePath, $COLOR_SUCCESS)
		EndIf
	EndIf

	;DirCreate($sTemplates)
	DirCreate($g_sProfilePresetPath)
	DirCreate($g_sPrivateProfilePath & "\" & $g_sProfileCurrentName)
	DirCreate($g_sProfilePath & "\" & $g_sProfileCurrentName)
	DirCreate($g_sProfileLogsPath)
	DirCreate($g_sProfileLootsPath)
	DirCreate($g_sProfileTempPath)
	DirCreate($g_sProfileTempDebugPath)

	$g_sProfileDonateCapturePath = $g_sProfilePath & "\" & $g_sProfileCurrentName & '\Donate\'
	$g_sProfileDonateCaptureWhitelistPath = $g_sProfilePath & "\" & $g_sProfileCurrentName & '\Donate\White List\'
	$g_sProfileDonateCaptureBlacklistPath = $g_sProfilePath & "\" & $g_sProfileCurrentName & '\Donate\Black List\'
	DirCreate($g_sProfileDonateCapturePath)
	DirCreate($g_sProfileDonateCaptureWhitelistPath)
	DirCreate($g_sProfileDonateCaptureBlacklistPath)

	;Migrate old bot without profile support to current one
	FileMove(@ScriptDir & "\*.ini", $g_sProfilePath & "\" & $g_sProfileCurrentName, $FC_OVERWRITE + $FC_CREATEPATH)
	DirCopy(@ScriptDir & "\Logs", $g_sProfilePath & "\" & $g_sProfileCurrentName & "\Logs", $FC_OVERWRITE + $FC_CREATEPATH)
	DirCopy(@ScriptDir & "\Loots", $g_sProfilePath & "\" & $g_sProfileCurrentName & "\Loots", $FC_OVERWRITE + $FC_CREATEPATH)
	DirCopy(@ScriptDir & "\Temp", $g_sProfilePath & "\" & $g_sProfileCurrentName & "\Temp", $FC_OVERWRITE + $FC_CREATEPATH)
	DirRemove(@ScriptDir & "\Logs", 1)
	DirRemove(@ScriptDir & "\Loots", 1)
	DirRemove(@ScriptDir & "\Temp", 1)

	;Setup profile if doesn't exist yet
	If FileExists($g_sProfileConfigPath) = 0 Then
		createProfile(True)
		applyConfig()
	EndIf

	If $g_bDeleteLogs Then DeleteFiles($g_sProfileLogsPath, "*.*", $g_iDeleteLogsDays, 0)
	If $g_bDeleteLoots Then DeleteFiles($g_sProfileLootsPath, "*.*", $g_iDeleteLootsDays, 0)
	If $g_bDeleteTemp Then
		DeleteFiles($g_sProfileTempPath, "*.*", $g_iDeleteTempDays, 0)
		DeleteFiles($g_sProfileTempDebugPath, "*.*", $g_iDeleteTempDays, 0, $FLTAR_RECUR)
	EndIf

	SetDebugLog("$g_sProfilePath = " & $g_sProfilePath)
	SetDebugLog("$g_sProfileCurrentName = " & $g_sProfileCurrentName)
	SetDebugLog("$g_sProfileLogsPath = " & $g_sProfileLogsPath)

EndFunc   ;==>SetupFilesAndFolders

; #FUNCTION# ====================================================================================================================
; Name ..........: FinalInitialization
; Description ...: Finalize various setup requirements
; Syntax ........:
; Parameters ....: $sAI: AndroidInfo for displaying in the log
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func FinalInitialization(Const $sAI)
	; check for VC2010, .NET software and MyBot Files and Folders
	Local $bCheckPrerequisitesOK = CheckPrerequisites(True)
	If $bCheckPrerequisitesOK Then
		MBRFunc(True) ; start MyBot.run.dll, after this point .net is initialized and threads popup all the time
		setAndroidPID() ; set Android PID
		SetBotGuiPID() ; set GUI PID
	EndIf

	If $g_bFoundRunningAndroid Then
		SetLog(GetTranslatedFileIni("MBR GUI Design - Loading", "Msg_Android_instance_03", "Found running %s %s", $g_sAndroidEmulator, $g_sAndroidVersion), $COLOR_SUCCESS)
	EndIf
	If $g_bFoundInstalledAndroid Then
		SetLog("Found installed " & $g_sAndroidEmulator & " " & $g_sAndroidVersion, $COLOR_SUCCESS)
	EndIf
	SetLog(GetTranslatedFileIni("MBR GUI Design - Loading", "Msg_Android_instance_04", "Android Emulator: %s", $sAI), $COLOR_SUCCESS)

	; reset GUI to wait for remote GUI in no GUI mode
	$g_iGuiPID = @AutoItPID

	; Remember time in Milliseconds bot launched
	$g_iBotLaunchTime = __TimerDiff($g_hBotLaunchTime)

	; wait for remote GUI to show when no GUI in this process
	If $g_iGuiMode = 0 Then
		SplashStep(GetTranslatedFileIni("MBR GUI Design - Loading", "Waiting_for_Remote_GUI", "Waiting for remote GUI..."))
		SetDebugLog("Wait for GUI Process...")

		Local $timer = __TimerInit()
		While $g_iGuiPID = @AutoItPID And __TimerDiff($timer) < 60000
			; wait for GUI Process updating $g_iGuiPID
			Sleep(50) ; must be Sleep as no run state!
		WEnd
		If $g_iGuiPID = @AutoItPID Then
			SetDebugLog("GUI Process not received, close bot")
			BotClose()
			$bCheckPrerequisitesOK = False
		Else
			SetDebugLog("Linked to GUI Process " & $g_iGuiPID)
		EndIf
	EndIf

	; destroy splash screen here (so we witness the 100% ;)
	DestroySplashScreen(False)
	If $bCheckPrerequisitesOK Then
		; only when bot can run, register with forum
		ForumAuthentication()
	EndIf

	; allow now other bots to launch
	DestroySplashScreen()

	; InitializeVariables();initialize variables used in extrawindows
	CheckVersion() ; check latest version on mybot.run site
	UpdateMultiStats()
	SetDebugLog("Maximum of " & $g_iGlobalActiveBotsAllowed & " bots running at same time configured")
	SetDebugLog("MyBot.run launch time " & Round($g_iBotLaunchTime) & " ms.")

	If $g_bAndroidShieldEnabled = False Then
		SetLog(GetTranslatedFileIni("MBR GUI Design - Loading", "Msg_Android_instance_05", "Android Shield not available for %s", @OSVersion), $COLOR_ACTION)
	EndIf

	DisableProcessWindowsGhosting()

	UpdateMainGUI()

EndFunc   ;==>FinalInitialization

; #FUNCTION# ====================================================================================================================
; Name ..........: MainLoop
; Description ...: Main application loop
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func MainLoop($bCheckPrerequisitesOK = True)
	Local $iStartDelay = 0

	If $bCheckPrerequisitesOK And ($g_bAutoStart Or $g_bRestarted) Then
		Local $iDelay = $g_iAutoStartDelay
		If $g_bRestarted Then $iDelay = 0
		$iStartDelay = $iDelay * 1000
		$g_iBotAction = $eBotStart
		; check if android should be hidden
		If $g_bBotLaunchOption_HideAndroid Then $g_bIsHidden = True
		; check if bot should be minimized
		If $g_bBotLaunchOption_MinimizeBot Then BotMinimizeRequest()
	EndIf

	Local $hStarttime = _Timer_Init()

	; Check the Supported Emulator versions
	CheckEmuNewVersions()

	;Reset Telegram message
	NotifyGetLastMessageFromTelegram()
	$g_iTGLastRemote = $g_sTGLast_UID

	While 1
		_Sleep($DELAYSLEEP, True, False)

		Local $diffhStarttime = _Timer_Diff($hStarttime)
		If Not $g_bRunState And $g_bNotifyTGEnable And $g_bNotifyRemoteEnable And $diffhStarttime > 1000 * 15 Then ; 15seconds
			$hStarttime = _Timer_Init()
			NotifyRemoteControlProcBtnStart()
		EndIf

		Switch $g_iBotAction
			Case $eBotStart
				BotStart($iStartDelay)
				$iStartDelay = 0 ; don't autostart delay in future
				If $g_iBotAction = $eBotStart Then $g_iBotAction = $eBotNoAction
			Case $eBotStop
				BotStop()
				If $g_iBotAction = $eBotStop Then $g_iBotAction = $eBotNoAction
				; Reset Telegram message
				$g_iTGLastRemote = $g_sTGLast_UID
			Case $eBotSearchMode
				BotSearchMode()
				If $g_iBotAction = $eBotSearchMode Then $g_iBotAction = $eBotNoAction
			Case $eBotClose
				BotClose()
		EndSwitch

	WEnd
EndFunc   ;==>MainLoop

Func runBot() ;Bot that runs everything in order
	Local $iWaitTime, $MainLoopTimer

	If $g_bIsHidden Then
		HideAndroidWindow(True, Default, Default, "btnHide")
		updateBtnHideState()
	EndIf

	InitiateSwitchAcc()

	If ProfileSwitchAccountEnabled() And $g_bReMatchAcc Then
		SetLog("Rematching Account [" & $g_iNextAccount + 1 & "] with Profile [" & GUICtrlRead($g_ahCmbProfile[$g_iNextAccount]) & "]")
		SwitchCoCAcc($g_iNextAccount)
	EndIf

	FirstCheck()

	While 1
		If Not $g_bRunState Then Return
		$g_bRestart = False
		;$g_bFullArmy = False
		;$g_bIsFullArmywithHeroesAndSpells = False
		$g_iCommandStop = -1

		If $g_bIsSearchLimit Then SetLog("Search limit hit", $COLOR_INFO)

		chkShieldStatus()
		If CheckAndroidReboot() Then ContinueLoop
		If Not $g_bIsClientSyncError Then
			If Not $g_bRunState Then Return
			If $g_bOutOfGold THen $g_bOutOfGold = False
			$MainLoopTimer = TimerInit()
			SetLogCentered(" Top MainLoop ", "=", $COLOR_DEBUG)
			checkMainScreen(False, $g_bStayOnBuilderBase, "MainLoop")
			VillageReport()

			If BotCommand() Then btnStop()
			If Not $g_bRunState Then Return

			If IsSearchAttackEnabled() Then ;if attack is disabled skip reporting, requesting, donating, training, and boosting
				BoostEverything() ; 1st Check if is to use Training Potion

				Local $aRndFuncList = ['ReplayShare', 'NotifyReport', 'BoostBarracks', 'BoostSpellFactory', 'BoostWorkshop', 'BoostKing', 'BoostQueen', 'BoostWarden', 'BoostChampion']
				For $Index In $aRndFuncList
					If Not $g_bRunState Then Return
					_RunFunction($Index)
					If $g_bRestart Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
					If CheckAndroidReboot() Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
					If _Sleep(50) Then Return
				Next

				If Not $g_bRunState Then Return
				If Unbreakable() Then ContinueLoop
				If $g_bRestart Then ContinueLoop
			EndIf

			AddIdleTime()
			
			CommonRoutine("Idle")

			If IsSearchAttackEnabled() Then
				If $g_bRestart = True Then ContinueLoop
				If $g_iCommandStop <> 0 And $g_iCommandStop <> 3 Then AttackMain()
			Else
				$iWaitTime = Random($DELAYWAITATTACK1, $DELAYWAITATTACK2)
				SetLog("Attacking Not Planned and Skipped, Waiting random " & StringFormat("%0.1f", $iWaitTime / 1000) & " Seconds", $COLOR_WARNING)
				If _SleepStatus($iWaitTime) Then Return False
			EndIf

			If Not $g_bRunState Then Return

			If $g_bFirstStart Then
				SetLog("First loop completed!", $COLOR_DEBUG1)
				SetLogCentered(" MainLoop Done (in " & Round(TimerDiff($MainLoopTimer) / 1000 / 60, 2) & " minutes) ", "=", $COLOR_INFO)
				$g_bFirstStart = False ; already finished first loop since bot started.
				ContinueLoop
			EndIf

		Else ;When error occurs directly goes to attack
			Local $sRestartText = $g_bIsSearchLimit ? " due search limit" : " after Out of Sync Error: Attack Now"
			SetLog("Restarted" & $sRestartText, $COLOR_INFO)
			;Use "CheckDonateOften" setting to run loop on hitting SearchLimit
			If $g_bIsSearchLimit Then
				SetDebugLog("ARCH: Clearing booleans", $COLOR_DEBUG)
				$g_bIsClientSyncError = False
				$g_bRestart = False
			EndIf
			If _Sleep($DELAYRUNBOT3) Then Return
			;  OCR read current Village Trophies when OOS restart maybe due PB or else DropTrophy skips one attack cycle after OOS
			$g_aiCurrentLoot[$eLootTrophy] = Number(getTrophyMainScreen($aTrophies[0], $aTrophies[1]))
			SetDebugLog("Runbot Trophy Count: " & $g_aiCurrentLoot[$eLootTrophy], $COLOR_DEBUG)
			If Not $g_bIsSearchLimit Then AttackMain() ;If Search Limit hit, do main loop.
			SetDebugLog("ARCH: Not case on SearchLimit or CheckDonateOften",$COLOR_DEBUG)
			If Not $g_bRunState Then Return
			$g_bSkipFirstZoomout = False

			If _Sleep($DELAYRUNBOT5) Then Return
			If $g_bRestart = True Then ContinueLoop
		EndIf
	WEnd
EndFunc   ;==>runBot

Func Idle() ;Sequence that runs until Full Army
	$g_bIdleState = True
	Local $Result = _Idle()
	$g_bIdleState = False
	Return $Result
EndFunc   ;==>Idle

Func _Idle() ;Sequence that runs until Full Army

	Local $TimeIdle = 0 ;In Seconds
	While $g_bIsFullArmywithHeroesAndSpells = False

		CheckAndroidReboot()

		;Execute Notify Pending Actions
		NotifyPendingActions()
		If _Sleep($DELAYIDLE1) Then Return

		If $g_iCommandStop = -1 Then SetLog("====== _Idle() ======", $COLOR_SUCCESS)
		Local $hTimer = __TimerInit()
		If _Sleep($DELAYIDLE1) Then ExitLoop
		checkObstacles()

		If $g_bRestart Then ExitLoop
		AddIdleTime()

		If $g_iCommandStop = -1 Then
			DropTrophy()
			If Not $g_bRunState Then Return
			If $g_bRestart Then ExitLoop
			If _Sleep($DELAYIDLE1) Then ExitLoop
		EndIf
		If _Sleep($DELAYIDLE1) Then Return
		If $g_bRestart Then ExitLoop

		$TimeIdle += Round(__TimerDiff($hTimer) / 1000, 2) ;In Seconds
		SetLog("Time Idle: " & StringFormat("%02i", Floor(Floor($TimeIdle / 60) / 60)) & ":" & StringFormat("%02i", Floor(Mod(Floor($TimeIdle / 60), 60))) & ":" & StringFormat("%02i", Floor(Mod($TimeIdle, 60))))

		If $g_iFreeBuilderCount > 0 And $g_abFullStorage[$eLootGold] Then
			UpgradeWall()
		EndIf
		If ($g_iCommandStop = 3 Or $g_iCommandStop = 0) And $g_bTrainEnabled = False Then ExitLoop ; If training is not enabled, run only 1 idle loop

	WEnd
EndFunc   ;==>_Idle

Func AttackMain($bFirstStart = False) ;Main control for attack functions
	If ProfileSwitchAccountEnabled() And $g_abDonateOnly[$g_iCurAccount] Then Return
	ClickAway()
	Local $ZoomOutResult = SearchZoomOut(False, True, "", True)
	If IsArray($ZoomOutResult) And $ZoomOutResult[0] = "" Then
		If checkMainScreen(False, $g_bStayOnBuilderBase, "AttackMain") Then ZoomOut()
	EndIf

	If IsSearchAttackEnabled() Then
		If (IsSearchModeActive($DB) And checkCollectors(True, False)) Or IsSearchModeActive($LB) Then
			If $g_bDropTrophyEnable And Number($g_aiCurrentLoot[$eLootTrophy]) > Number($g_iDropTrophyMax) Then ;If current trophy above max trophy, try drop first
				If Not $bFirstStart Then
					DropTrophy()
					If Not $g_bRunState Then Return
					$g_bIsClientSyncError = False ; reset OOS flag to prevent looping.
					If _Sleep($DELAYATTACKMAIN1) Then Return
					Return ; return to runbot, refill armycamps
				Else
					SetLog("Drop Trophy Enabled, but skipped on FirstStart", $COLOR_DEBUG)
				EndIf
			EndIf
			If Not $g_bRunState Then Return
			;If $g_bUpdateSharedPrefs And $g_bChkSharedPrefs Then PullSharedPrefs()
			PrepareSearch()
			If Not $g_bRunState Then Return
			If $g_bOutOfGold Then Return ; Check flag for enough gold to search
			If $g_bRestart Then Return
			VillageSearch()
			If $g_bOutOfGold Then Return ; Check flag for enough gold to search
			If Not $g_bRunState Then Return
			If $g_bRestart Then Return
			PrepareAttack($g_iMatchMode)
			If Not $g_bRunState Then Return
			If $g_bRestart Then Return
			Attack()
			If Not $g_bRunState Then Return
			If $g_bRestart Then Return
			ReturnHome($g_bTakeLootSnapShot)
			If Not $g_bRunState Then Return
			If _Sleep($DELAYATTACKMAIN2) Then Return
			Return True
		Else
			SetLog("None of search condition match:", $COLOR_WARNING)
			SetLog("Search, Trophy or Army Camp % are out of range in search setting", $COLOR_WARNING)
			$g_bIsSearchLimit = False
			$g_bIsClientSyncError = False
			If ProfileSwitchAccountEnabled() Then checkSwitchAcc()
			SmartWait4Train()
		EndIf
	Else
		SetLog("Attacking Not Planned, Skipped..", $COLOR_WARNING)
		SetDebugLog("AttackMain: Clearing booleans", $COLOR_DEBUG)
		$g_bIsClientSyncError = False
		$g_bRestart = False
	EndIf
	Return True
EndFunc   ;==>AttackMain

Func Attack() ;Selects which algorithm
	$g_bAttackActive = True
	SetLog(" ====== Start Attack ====== ", $COLOR_SUCCESS)
	If ($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1) Then
		SetDebugLog("start scripted attack", $COLOR_ERROR)
		Algorithm_AttackCSV()
	ElseIf $g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 2 Then
		SetDebugLog("start smart farm attack", $COLOR_ERROR)
		; Variable to return : $Return[3]  [0] = To attack InSide  [1] = Quant. Sides  [2] = Name Sides
		Local $Nside = ChkSmartFarm()
		If Not $g_bRunState Then Return
		AttackSmartFarm($Nside[1], $Nside[2])
	Else
		SetDebugLog("start standard attack", $COLOR_ERROR)
		algorithm_AllTroops()
	EndIf
	$g_bAttackActive = False
EndFunc   ;==>Attack

Func _RunFunction($action)
	FuncEnter(_RunFunction)
	; ensure that builder base flag is false
	$g_bStayOnBuilderBase = False
	Local $Result = __RunFunction($action)
	; ensure that builder base flag is false
	$g_bStayOnBuilderBase = False
	Return FuncReturn($Result)
EndFunc   ;==>_RunFunction

Func __RunFunction($action)
	SetDebugLog("_RunFunction: " & $action & " BEGIN", $COLOR_DEBUG2)
	Switch $action
		Case "UseFreeMagic"
			UseFreeMagicItem()
			If _Sleep(50) Then Return
		Case "Collect"
			Collect()
			If _Sleep(50) Then Return
		Case "BlackSmith"
			BlackSmith()
			If _Sleep(50) Then Return
		Case "CheckTombs"
			CheckTombs()
			If _Sleep(50) Then Return
		Case "CleanYard"
			CleanYard()
			If _Sleep(50) Then Return
		Case "ReplayShare"
			ReplayShare($g_bShareAttackEnableNow)
			If _Sleep(50) Then Return
		Case "NotifyReport"
			NotifyReport()
			If _Sleep(50) Then Return
		Case "DonateCC"
			DonateCC()
		Case "BoostBarracks"
			BoostBarracks()
			If _Sleep(50) Then Return
		Case "BoostSpellFactory"
			BoostSpellFactory()
			If _Sleep(50) Then Return
		Case "BoostWorkshop"
			BoostWorkshop()
			If _Sleep(50) Then Return
		Case "BoostKing"
			BoostKing()
			If _Sleep(50) Then Return
		Case "BoostQueen"
			BoostQueen()
			If _Sleep(50) Then Return
		Case "BoostWarden"
			BoostWarden()
			If _Sleep(50) Then Return
		Case "BoostChampion"
			BoostChampion()
			If _Sleep(50) Then Return
		Case "BoostEverything"
			BoostEverything()
			If _Sleep(50) Then Return
		Case "DailyChallenge"
			DailyChallenges()
			If _Sleep(50) Then Return
		Case "RequestCC"
			RequestCC()
			If _Sleep(50) Then Return
		Case "Laboratory"
			LabUpgrade()
			If _Sleep(50) Then Return
		Case "PetHouse"
			PetHouse()
			If _Sleep(50) Then Return
		Case "ForgeClanCapitalGold"
			ForgeClanCapitalGold()
			If _Sleep(50) Then Return
		Case "BoostSuperTroop"
			BoostSuperTroop()
			If _Sleep(50) Then Return
		Case "UpgradeHeroes"
			UpgradeHeroes()
			If _Sleep(50) Then Return
		Case "UpgradeBuilding"
			UpgradeBuilding()
			If _Sleep(50) Then Return
			AutoUpgrade()
			If _Sleep(50) Then Return
		Case "UpgradeLow"
			AutoUpgrade(False, True)
			If _Sleep(50) Then Return
		Case "UpgradeWall"
			UpgradeWall()
			If _Sleep(50) Then Return
		Case "BuilderBase"
			If $g_bChkCollectBuilderBase Or $g_bChkStartClockTowerBoost Or $g_bAutoUpgradeBBEnabled Or $g_bChkEnableBBAttack Then
				BuilderBase()
			EndIf
			If _Sleep(50) Then Return
		Case "CollectAchievements"
			CollectAchievements()
			If _Sleep(50) Then Return
		Case "CollectFreeMagicItems"
			CollectFreeMagicItems()
			If _Sleep(50) Then Return
		Case "SaleMagicItem"
			SaleMagicItem()
			If _Sleep(50) Then Return
		Case "AutoUpgradeCC"
			AutoUpgradeCC()
			If _Sleep(50) Then Return
		Case "CollectCCGold"
			CollectCCGold()
			If _Sleep(50) Then Return
		Case ""
			SetDebugLog("Function call doesn't support empty string, please review array size", $COLOR_ERROR)
		Case Else
			SetLog("Unknown function call: " & $action, $COLOR_ERROR)
	EndSwitch
	SetDebugLog("_RunFunction: " & $action & " END", $COLOR_DEBUG2)
EndFunc   ;==>__RunFunction

Func FirstCheck()
	If Not $g_bRunState Then Return
	SetLogCentered(" FIRSTCHECK ", "=", $COLOR_SUCCESS)
	$g_bFirstStart = True
	
	checkMainScreen(False, $g_bStayOnBuilderBase, "FirstCheck")
	VillageReport(True, True)
	If _Sleep(50) Then Return
	ZoomOut(True)

	If ProfileSwitchAccountEnabled() And $g_abDonateOnly[$g_iCurAccount] Then Return

	$g_bRestart = False
	$g_bFullArmy = False
	$g_iCommandStop = -1

	;Check Town Hall level
	Local $iTownHallLevel = $g_iTownHallLevel
	Local $bLocateTH = False
	SetLog("Detecting Town Hall level", $COLOR_INFO)
	SetLog("Town Hall level is currently saved as " &  $g_iTownHallLevel, $COLOR_INFO)
	Collect(True) ;only collect from mine and collector
	If _Sleep(50) Then Return
	If $g_aiTownHallPos[0] > -1 Then
		ClickP($g_aiTownHallPos)
		If _Sleep(800) Then Return
		Local $BuildingInfo = BuildingInfo(242, 477)
		If $BuildingInfo[1] = "Town Hall" Then
			$g_iTownHallLevel =  $BuildingInfo[2]
			ClickAway()
		Else
			$bLocateTH = True
		EndIf
	EndIf

	If $g_iTownHallLevel = 0 Or $bLocateTH Then
		SearchTH()
	EndIf
	
	If _Sleep(50) Then Return
	SetLog("Detected Town Hall level is " &  $g_iTownHallLevel, $COLOR_INFO)
	If $g_iTownHallLevel = $iTownHallLevel Then
		SetLog("Town Hall level has not changed", $COLOR_INFO)
	Else
		SetLog("Town Hall level has changed!", $COLOR_INFO)
		SetLog("New Town hall level detected as " &  $g_iTownHallLevel, $COLOR_INFO)
		applyConfig()
		saveConfig()
	EndIf
	setupProfile()

	If $g_bAlwaysDropHero Then
		If $g_iTownHallLevel > 12 Then
			GUICtrlSetState($g_hChkABChampionAttack, $GUI_CHECKED)
			GUICtrlSetState($g_hChkDBChampionAttack, $GUI_CHECKED)
		EndIf
		If $g_iTownHallLevel > 10 Then
			GUICtrlSetState($g_hChkABWardenAttack, $GUI_CHECKED)
			GUICtrlSetState($g_hChkDBWardenAttack, $GUI_CHECKED)
		EndIf
		If $g_iTownHallLevel > 8 Then
			GUICtrlSetState($g_hChkABQueenAttack, $GUI_CHECKED)
			GUICtrlSetState($g_hChkDBQueenAttack, $GUI_CHECKED)
		EndIf
		If $g_iTownHallLevel > 6 Then
			GUICtrlSetState($g_hChkABKingAttack, $GUI_CHECKED)
			GUICtrlSetState($g_hChkDBKingAttack, $GUI_CHECKED)
		EndIf
		saveConfig()
	EndIf

	If Not $g_bRunState Then Return
	VillageReport()
	If BotCommand() Then btnStop()
	chkShieldStatus()
	CheckTombs()
	If _Sleep(50) Then Return
	BoostSuperTroop()
	If _Sleep(50) Then Return
	RequestCC()

	If isElixirFull() or isDarkElixirFull() Then
		Laboratory()
		VillageReport(True, True)
	EndIf

	If $g_iFreeBuilderCount > 0 Then
		Setlog("Your Account have FREE BUILDER", $COLOR_INFO)
		If Not $g_bRunState Then Return

		If $g_abFullStorage[$eLootElixir] Or $g_abFullStorage[$eLootGold] And $g_bUpgradeWallSaveBuilder Then
			SetLog("Gold and Elix Full", $COLOR_INFO)
			SetLog("Forced Check Upgrade Wall because save 1 builder for wall", $COLOR_INFO)
			UpgradeWall()
		EndIf

		If Not $g_bRunState Then Return
		If $g_bAutoUpgradeEarly Then
			SetLog("Check Auto Upgrade Early", $COLOR_INFO)
			AutoUpgrade()
		EndIf
		VillageReport()
		If _Sleep(50) Then Return
		ZoomOut(True)
	EndIf

	If T420() Then
		SetLog("Test420 Done!", $COLOR_SUCCESS)
	EndIf

	waitMainScreen() ;check mainscreen and remove any obstacle window/popup
	If BotCommand() Then btnStop()
	If Not $g_bRunState Then Return
	If ProfileSwitchAccountEnabled() And ($g_iCommandStop = 0 Or $g_iCommandStop = 1) Then
		If Not $g_bSkipFirstCheckRoutine Then FirstCheckRoutine()
		If Not $g_bSkipBB Then _RunFunction('BuilderBase')
		If Not $g_bRunState Then Return
		RequestCC()
		checkSwitchAcc()
	Else
		FirstCheckRoutine()
	EndIf
EndFunc   ;==>FirstCheck

Func FirstCheckRoutine()
	Local $sText = ""
	Local $FirstCheckRoutineTimer = TimerInit()
	Local $b_SuccessAttack = False
	SetLog("======== FirstCheckRoutine ========", $COLOR_ACTION)
	
	If _Sleep(50) Then Return
	If Not $g_bRunState Then Return
	
	If $g_iCommandStop <> 3 And $g_iCommandStop <> 0 Then
		; Now the bot can attack
		Setlog("Before any other routine let's attack!", $COLOR_INFO)
		If Not $g_bChkCGBBAttackOnly Then _ClanGames()
		
		FillArmyCamp()
		
		Local $loopcount = 1
		While True
			$g_bRestart = False
			If Not $g_bRunState Then Return
			If AttackMain($g_bSkipDT) Then
				Setlog("[" & $loopcount & "] 1st Attack Loop Success", $COLOR_SUCCESS)
				RequestCC()
				ExitLoop
			Else
				If $g_bForceSwitch Then ExitLoop ;exit here
				$loopcount += 1
				If $loopcount > 10 Then
					Setlog("1st Attack Loop, Already Try 10 times... Exit", $COLOR_ERROR)
					ExitLoop
				Else
					Setlog("[" & $loopcount & "] 1st Attack Loop, Failed", $COLOR_INFO)
					If $g_bForceSwitch Then ExitLoop
				EndIf
				If Not $g_bRunState Then Return
			EndIf
		Wend
	EndIf
	
	If _Sleep(50) Then Return
	If Not $g_bRunState Then Return
	
	If $g_bChkCGBBAttackOnly And ProfileSwitchAccountEnabled() Then
		For $count = 1 to 3
			If Not $g_bRunState Then Return
			If _ClanGames() Then
				If $g_bIsBBevent Then
					SetLog("Forced BB Attack On ClanGames", $COLOR_INFO)
					SetLog("[" & $count & "] Trying to complete BB Challenges", $COLOR_ACTION)
					GotoBBTodoCG()
				Else
					ExitLoop ;should be will never get here, but
				EndIf
			Else
				If $g_bIsCGPointMaxed Then ExitLoop ; If point is max then continue to main loop
				If Not $g_bIsCGEventRunning Then ExitLoop ; No Running Event after calling ClanGames
				If $g_bChkClanGamesStopBeforeReachAndPurge and $g_bIsCGPointAlmostMax Then ExitLoop ; Exit loop if want to purge near max point
			EndIf
			If isOnMainVillage() Then ZoomOut(True)	; Verify is on main village and zoom out
		Next
	EndIf
	
	;Skip switch if Free Builder > 0 Or Storage Fill is Low, when clangames
	Local $bSwitch = True
	VillageReport(False, True)
	If $g_iFreeBuilderCount - ($g_bUpgradeWallSaveBuilder ? 1 : 0) > 0 Then $bSwitch = False
	If $g_abLowStorage[$eLootElixir] Or $g_abLowStorage[$eLootGold] Then $bSwitch = False

	If Not $g_bRunState Then Return
	If ProfileSwitchAccountEnabled() And $g_bForceSwitchifNoCGEvent And Number($g_aiCurrentLoot[$eLootTrophy]) < 4900 And $bSwitch Then
		SetLog("No Event on ClanGames, Forced switch account!", $COLOR_DEBUG)
		RequestCC()
		CommonRoutine("NoClanGamesEvent")
		checkSwitchAcc() ;switch to next account
	EndIf

	If Not $g_bRunState Then Return
	If ProfileSwitchAccountEnabled() And $g_bForceSwitch Then
		SetLog("Forced switch account!!", $COLOR_DEBUG)
		RequestCC()
		CommonRoutine("Switch")
		checkSwitchAcc() ;switch to next account
	EndIf

	CommonRoutine("FirstCheck") ;after first attack, checking some routine
	
	;If not switch:
	If Not ProfileSwitchAccountEnabled() Then 
		SetLog("Switch account not enabled, going to mainloop", $COLOR_DEBUG)
		Return 
	EndIf

	If Not $g_bRunState Then Return
	If ProfileSwitchAccountEnabled() Then ;Allow immediate Second Attack on FastSwitchAcc enabled
		VillageReport()
		SetLog("Check Second Attack", $COLOR_ACTION)
		FillArmyCamp()
		If BotCommand() Then btnStop()
		If Not $g_bRunState Then Return
		If $g_iCommandStop <> 0 And $g_iCommandStop <> 3 Then
			Setlog("Let's attack Again!", $COLOR_INFO)
			$g_bRestart = False ;reset
			Local $loopcount = 1
			While True
				$g_bRestart = False
				If Not $g_bRunState Then Return
				If AttackMain($g_bSkipDT) Then
					Setlog("[" & $loopcount & "] 2nd Attack Loop Success", $COLOR_SUCCESS)
					$b_SuccessAttack = True
					ExitLoop
				Else
					$loopcount += 1
					If $loopcount > 10 Then
						Setlog("2nd Attack Loop, Already Try 10 times... Exit", $COLOR_ERROR)
						ExitLoop
					Else
						Setlog("[" & $loopcount & "] 2nd Attack Loop, Failed", $COLOR_INFO)
						If $g_bForceSwitch Then ExitLoop
					EndIf
					If Not $g_bRunState Then Return
				EndIf
			Wend
		EndIf
	EndIf

	If Not $g_bRunState Then Return
	$sText = Round(TimerDiff($FirstCheckRoutineTimer) / 1000 / 60, 2)
	SetLog(" ")
	SetLogCentered(" FirstCheckRoutine done (" & $sText & " minutes) ", "~", $COLOR_SUCCESS)
	SetLog(" ")

	If ProfileSwitchAccountEnabled() Then
		CommonRoutine("Switch")
		checkSwitchAcc() ;switch to next account
	EndIf
EndFunc

Func CommonRoutine($RoutineType = Default)
	If Not $g_bRunState Then Return
	If $RoutineType = Default Then $RoutineType = "FirstCheck"
	SetLogCentered(" CommonRoutine - " & $RoutineType & " ", "=", $COLOR_INFO)
	Local $CommonRoutineTimer = TimerInit()
	Local $sText = "", $aFuncList[0]
	Switch $RoutineType
		Case "FirstCheck"
			Local $aRndFuncList = ['Collect', 'CleanYard', 'UseFreeMagic', 'PetHouse', 'ForgeClanCapitalGold', 'CollectCCGold', 'AutoUpgradeCC', 'BlackSmith', 'PetHouse', 'Laboratory', 'SaleMagicItem', 'UpgradeWall']
			SetLog($RoutineType & " Func List:", $COLOR_SUCCESS)
			For $i In $aRndFuncList
				SetLog(" --> " & $i, $COLOR_NAVY)
			Next

			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep(50) Then Return
				If $g_bRestart Then Return
			Next

		Case "Switch"
			If Not $g_bisCGPointMaxed Then _ClanGames(False, True) ;Do Only Purge

			Local $aRndFuncList = ['RequestCC', 'DailyChallenge', 'CollectAchievements', 'CollectFreeMagicItems', 'BuilderBase', 'Laboratory', 'UpgradeHeroes', 'UpgradeBuilding', 'UpgradeWall', 'UpgradeLow', 'RequestCC']
			SetLog($RoutineType & " Func List:", $COLOR_SUCCESS)
			For $i In $aRndFuncList
				SetLog(" --> " & $i, $COLOR_NAVY)
			Next

			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep(50) Then Return
				If $g_bRestart Then Return
			Next

		Case "Idle"
			Local $aRndFuncList = ['RequestCC', 'DailyChallenge', 'CollectAchievements', 'CollectFreeMagicItems', 'Laboratory', 'UpgradeHeroes', 'UpgradeBuilding', 'UpgradeWall', 'UpgradeLow', 'BuilderBase']
			SetLog($RoutineType & " Func List:", $COLOR_SUCCESS)
			For $i In $aRndFuncList
				SetLog(" --> " & $i, $COLOR_NAVY)
			Next

			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep(50) Then Return
				If $g_bRestart Then Return
			Next

		Case "NoClanGamesEvent"
			Local $aRndFuncList = ['RequestCC', 'DailyChallenge', 'CollectAchievements', 'CollectFreeMagicItems', 'PetHouse', 'Laboratory', 'CollectCCGold', 'UpgradeHeroes', 'UpgradeBuilding', 'UpgradeWall', 'UpgradeLow']
			SetLog($RoutineType & " Func List:", $COLOR_SUCCESS)
			For $i In $aRndFuncList
				SetLog(" --> " & $i, $COLOR_NAVY)
			Next

			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep(50) Then Return
				If $g_bRestart Then Return
			Next
	EndSwitch
	$sText = Round(TimerDiff($CommonRoutineTimer) / 1000 / 60, 2)
	SetLogCentered(" CommonRoutine " & $RoutineType & " done (" & $sText & " minutes) ", "~", $COLOR_SUCCESS)
	For $i In $aRndFuncList
		SetLog(" --> " & $i, $COLOR_NAVY)
	Next
	SetLog(" ")
EndFunc

Func BuilderBase()
	If Not $g_bRunState Then Return
	If Number($g_iTotalBuilderCount) = 6 Then
		$g_bIs6thBuilderUnlocked = True
		SetLog("Is6thBuilderUnlocked = " & String($g_bIs6thBuilderUnlocked), $COLOR_DEBUG1)
		If $g_bIs6thBuilderUnlocked And $g_bChkSkipBBRoutineOn6thBuilder Then $g_bskipBBroutine = True
	EndIf

	If $g_bskipBBroutine Then
		SetLog("isSkipBBroutine = " & String($g_bskipBBroutine), $COLOR_DEBUG1)
		SetLog("BB Routine Skip!", $COLOR_INFO)
		Return
	EndIf
	If Not $g_bRunState Then Return

	; switch to builderbase and check it is builderbase
	If SwitchBetweenBases("BB") Then
		$g_bStayOnBuilderBase = True
		$g_bBBAttacked = True	; Reset Variable
		Local $StartLabON = False
		
		checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
		CollectBuilderBase()
		BuilderBaseReport(False, False)
		
		If _Sleep(50) Then Return
		CleanBBYard()
		
		If _Sleep(50) Then Return
		If isGoldFullBB() Or isElixirFullBB() Then
			If AutoUpgradeBB() Then
				ZoomOut(True) ;directly zoom
			EndIf
			checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
			$g_bBBAttacked = False
		EndIf
		
		
		If _Sleep(50) Then Return
		If isElixirFullBB() Then
			$StartLabON = StarLabUpgrade()
			checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
			$g_bBBAttacked = False
		EndIf
		
		If _Sleep(50) Then Return
		BBDropTrophy()
		
		If _Sleep(50) Then Return
		If $g_bChkStopAttackBB6thBuilder And $g_bIs6thBuilderUnlocked Then
			SetLog("6th Builder Unlocked, attackBB disabled", $COLOR_DEBUG)
		Else
			SetLog("StopAttackBB6thBuilder: " & String($g_bChkStopAttackBB6thBuilder) & ", Is6thBuilderUnlocked: " & String($g_bIs6thBuilderUnlocked), $COLOR_DEBUG1)
			DoAttackBB()
			If _Sleep(50) Then Return
		EndIf
		
		If _Sleep(50) Then Return
		If $g_bBBAttacked Then
			If AutoUpgradeBB() Then
				ZoomOut(True) ;directly zoom
			EndIf
			checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
		EndIf
		
		If _Sleep(50) Then Return
		If Not $g_bRunState Then Return
		
		If _Sleep(50) Then Return
		If Not $StartLabON Then StarLabUpgrade()
		Local $bUseCTPot = $StartLabON And $g_iFreeBuilderCountBB = 0 And Not ($g_bGoldStorageFullBB Or $g_bElixirStorageFullBB)

		If _Sleep(50) Then Return
		StartClockTowerBoost(False, False, $bUseCTPot)
		
		If _Sleep(50) Then Return
		BuilderBaseReport(False, True)
		
		$g_bStayOnBuilderBase = False
		SwitchBetweenBases("Main")
	EndIf

	If Not $g_bStayOnBuilderBase And IsOnBuilderBase() Then SwitchBetweenBases("Main")
EndFunc

Func GotoBBTodoCG()
	If SwitchBetweenBases("BB") And isOnBuilderBase() Then
		$g_bStayOnBuilderBase = True
		BuilderBaseReport(True, False)
		CollectBuilderBase()
		DoAttackBB(0)
		CollectBBCart()
		; switch back to normal village
		SwitchBetweenBases("Main")
		$g_bStayOnBuilderBase = False
	EndIf
EndFunc

Func FillArmyCamp()
	If $g_bIgnoreIncorrectTroopCombo Or $g_bIgnoreIncorrectSpellCombo Then ;check army or spell to fill
		If OpenArmyOverview() Then 
			If _Sleep(500) Then Return
			If QuickMIS("BC1", $g_sImgArmyOverviewExclam, 320, 210, 480, 230) Then ;check on troops
				SetLog("Your troop need to fill", $COLOR_DEBUG)
				FillIncorrectTroopCombo()
				ClickAway()
				If _Sleep(500) Then Return
			EndIf
			
			If QuickMIS("BC1", $g_sImgArmyOverviewExclam, 320, 320, 480, 345) Then ;check on spells
				SetLog("Your troop need to fill", $COLOR_DEBUG)
				FillIncorrectSpellCombo()
				ClickAway()
				If _Sleep(500) Then Return
			EndIf
			
			If QuickMIS("BC1", $g_sImgArmyOverviewExclam, 380, 270, 800, 295) Then ;check on acivate supertroop
				SetLog("SuperTroop Need to activate", $COLOR_DEBUG)
				ClickAway()
				If _Sleep(500) Then Return
				BoostSuperTroop()
			EndIf
			
			If QuickMIS("BC1", $g_sImgArmyOverviewCastleCake, 650, 450, 725, 485) Then ;check on Castle cake reinforcement
				SetLog("Try Reinforce with Castle Cake", $COLOR_DEBUG)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(500) Then Return
				If QuickMIS("BC1", $g_sImgArmyOverviewCastleCake, 210, 180, 280, 250) Then ;read if text "Tap to Reinforce" exist
					Click($g_iQuickMISX, $g_iQuickMISY)
					If _Sleep(500) Then Return
					Local $aTroops = QuickMIS("CNX", $g_sImgTrainTroops, 120, 260, 740, 460) ;read all troops image 
					If IsArray($aTroops) And UBound($aTroops) > 0 Then
						_ArraySort($aTroops, 0, 0, 0, 1)
						For $i = 0 To UBound($aTroops) - 1
							Switch $aTroops[$i][0]
								Case "Giant", "Ball", "Wiz"
									Click($aTroops[$i][1], $aTroops[$i][2], 5)
								Case "Drag"
									Click($aTroops[$i][1], $aTroops[$i][2], 2)
							EndSwitch
							
							If _ColorCheck(_GetPixelColor(150, 275, True), Hex(0x8F8F8F, 6), 20, Default, "CheckTroopBar") Then 
								Click(450, 530) ;Click Confirm
								If _Sleep(500) Then Return
								ExitLoop ;troops bar greyed
							EndIf
						Next
					EndIf
				EndIf
				
				If QuickMIS("BC1", $g_sImgArmyOverviewCastleCake, 450, 380, 635, 500) then
					Click($g_iQuickMISX, $g_iQuickMISY)
					SetLog("Fill Reinforcement using Castle Cake", $COLOR_ACTION)
				EndIf
				
				ClickAway()
				If _Sleep(500) Then Return
			EndIf
			
			;close Army window
			ClickAway()
			If _Sleep(500) Then Return
		EndIf
	EndIf
EndFunc

Func T420()
	If IsDeclared("g_VariableTest123") = 1 Then
		SetLog("Execute Test420()", $COLOR_INFO)
		If Execute("Test420()") = 1 Then
			SetLog("Executing Test420() again", $COLOR_INFO)
			Return Execute("Test420()")
		EndIf
	EndIf
EndFunc