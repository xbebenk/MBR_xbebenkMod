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

Local $AutoItVersion = @AutoItVersion
Local $aAutoItVersion = StringSplit($AutoItVersion, ".", 2)
If Number($aAutoItVersion[2]) > 14 Then
	Local $answer = MsgBox(0x41, @ScriptName , "Unsupported AutoIt Version" & @CRLF & @CRLF & "Your Installed AutoIt Version : " & $AutoItVersion & @CRLF & "Please Download and Install AutoIt Version 3.3.14.5" & @CRLF & "Click OK will open archive download link for lower version of AutoIt")
	Switch $answer
		Case 1
			Run(@ComSpec & " /c " & 'start www.autoitscript.com/autoit3/files/archive/autoit/', "", @SW_HIDE)
			Exit
		Case 2
			Exit
	EndSwitch
EndIf

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

;#include "COCBot\Test420\Test420.au3"

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
	; Disabled process priority tampering as not best practice
	;Local $iBotProcessPriority = _ProcessGetPriority(@AutoItPID)
	;ProcessSetPriority(@AutoItPID, $PROCESS_BELOWNORMAL) ;~ Boost launch time by increasing process priority (will be restored again when finished launching)

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
				Case "/rg", "-rg", "/remgui", "-remgui"
					$g_iRemUnusedGUI = 1
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
		If $g_asCmdLine[0] >= 2 Then
			If StringInStr($g_asCmdLine[2], "BlueStacks3") Or StringInStr($g_asCmdLine[2], "BlueStacks4") Then
				; BlueStacks v3 and v4 use same key as v2
				$g_asCmdLine[2] = "BlueStacks2"
			EndIf
		EndIf
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
	$g_sProfileDonateCapturePath = $g_sProfilePath & "\" & $g_sProfileCurrentName & '\Donate\'
	$g_sProfileDonateCaptureWhitelistPath = $g_sProfilePath & "\" & $g_sProfileCurrentName & '\Donate\White List\'
	$g_sProfileDonateCaptureBlacklistPath = $g_sProfilePath & "\" & $g_sProfileCurrentName & '\Donate\Black List\'
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
	Local $sMsg = GetTranslatedFileIni("MBR GUI Design - Loading", "Compile_Script", "Don't Run/Compile the Script as (x64)! Try to Run/Compile the Script as (x86) to get the bot to work.\r\n" & _
			"If this message still appears, try to re-install AutoIt.")
	If @AutoItX64 = 1 Then
		DestroySplashScreen()
		MsgBox(0, "", $sMsg)
		__GDIPlus_Shutdown()
		Exit
	EndIf

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
			EndIf
		EndIf
	EndIf

	Local $cmdLineHelp = GetTranslatedFileIni("MBR GUI Design - Loading", "Commandline_multiple_Bots", "By using the commandline (or a shortcut) you can start multiple Bots:\r\n" & _
			"     MyBot.run.exe [ProfileName] [EmulatorName] [InstanceName]\r\n\r\n" & _
			"With the first command line parameter, specify the Profilename (you can create profiles on the Bot/Profiles tab, if a " & _
			"profilename contains a {space}, then enclose the profilename in double quotes). " & _
			"With the second, specify the name of the Emulator and with the third, an Android Instance (not for BlueStacks). \r\n" & _
			"Supported Emulators are MEmu, Nox, BlueStacks2, BlueStacks and iTools.\r\n\r\n" & _
			"Examples:\r\n" & _
			"     MyBot.run.exe MyVillage BlueStacks2\r\n" & _
			"     MyBot.run.exe ""My Second Village"" MEmu MEmu_1")

	$g_hMutex_BotTitle = CreateMutex($g_sBotTitle)
	$sAI = GetTranslatedFileIni("MBR GUI Design - Loading", "Android_instance_01", "%s", $g_sAndroidEmulator)
	Local $sAndroidInfo2 = GetTranslatedFileIni("MBR GUI Design - Loading", "Android_instance_02", "%s (instance %s)", $g_sAndroidEmulator, $g_sAndroidInstance)
	If $g_sAndroidInstance <> "" Then
		$sAI = $sAndroidInfo2
	EndIf

	; Check if we are already running for this instance
	$sMsg = GetTranslatedFileIni("MBR GUI Design - Loading", "Msg_Android_instance_01", "My Bot for %s is already running.\r\n\r\n", $sAI)
	If $g_hMutex_BotTitle = 0 Then
		SetDebugLog($g_sBotTitle & " is already running, exit now")
		DestroySplashScreen()
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
	SetLog(GetTranslatedFileIni("MBR GUI Design - Loading", "Msg_Android_instance_04", "Android Emulator Configuration: %s", $sAI), $COLOR_SUCCESS)

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
	If $g_iRemUnusedGUI Then
		SetLog("Warning: SomeGUI removed to allow more instance", $COLOR_ACTION)
		RemControl()
	EndIf
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
	Local $iWaitTime

	Local $ZoomOutResult = SearchZoomOut(False, True, "", True)
	If IsArray($ZoomOutResult) And $ZoomOutResult[0] = "" Then
		If checkMainScreen(False, $g_bStayOnBuilderBase, "MainLoop") Then ZoomOut()
	EndIf

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
		;Restart bot after these seconds
		If $b_iAutoRestartDelay > 0 And __TimerDiff($g_hBotLaunchTime) > $b_iAutoRestartDelay * 1000 Then
			If RestartBot(False) Then Return
		EndIf

		PrepareDonateCC()
		If Not $g_bRunState Then Return
		$g_bRestart = False
		$g_bFullArmy = False
		$g_bIsFullArmywithHeroesAndSpells = False
		$g_iCommandStop = -1
		If _Sleep($DELAYRUNBOT1) Then Return
		If $g_bRestart Then ContinueLoop
		chkShieldStatus()
		If Not $g_bRunState Then Return
		If $g_bRestart Then ContinueLoop

		If CheckAndroidReboot() Then ContinueLoop
		If Not $g_bIsClientSyncError Then ;ARCH:  was " And Not $g_bIsSearchLimit"
			SetLog("ARCH: Top of loop", $COLOR_DEBUG)
			If $g_bIsSearchLimit Then SetLog("Search limit hit", $COLOR_INFO)
			;xbenk
			;checkMainScreen(False)
			If $g_bRestart Then ContinueLoop
			If _Sleep($DELAYRUNBOT3) Then Return
			VillageReport()
			If _Sleep($DELAYRUNBOT2) Then Return
			If BotCommand() Then btnStop()
			If Not $g_bRunState Then Return
			If $g_bOutOfGold And (Number($g_aiCurrentLoot[$eLootGold]) >= Number($g_iTxtRestartGold)) Then ; check if enough gold to begin searching again
				$g_bOutOfGold = False ; reset out of gold flag
				SetLog("Switching back to normal after no gold to search ...", $COLOR_SUCCESS)
				;ContinueLoop ; Restart bot loop to reset $g_iCommandStop & $g_bTrainEnabled + $g_bDonationEnabled via BotCommand()
			EndIf
			If $g_bOutOfElixir And (Number($g_aiCurrentLoot[$eLootElixir]) >= Number($g_iTxtRestartElixir)) And (Number($g_aiCurrentLoot[$eLootDarkElixir]) >= Number($g_iTxtRestartDark)) Then ; check if enough elixir to begin searching again
				$g_bOutOfElixir = False ; reset out of elixir flag
				SetLog("Switching back to normal setting after no elixir to train ...", $COLOR_SUCCESS)
				;ContinueLoop ; Restart bot loop to reset $g_iCommandStop & $g_bTrainEnabled + $g_bDonationEnabled via BotCommand()
			EndIf
			If _Sleep($DELAYRUNBOT5) Then Return
			If $g_bRestart Then ContinueLoop

			checkMainScreen(False, $g_bStayOnBuilderBase, "MainLoop")
			AddIdleTime()
			If Not $g_bRunState Then Return
			If $g_bRestart Then ContinueLoop
			If IsSearchAttackEnabled() Then ; if attack is disabled skip reporting, requesting, donating, training, and boosting
				If $g_bIsSearchLimit Then
					Local $aRndFuncList = ['DonateCC,Train']
				Else
					Local $aRndFuncList = ['ReplayShare', 'NotifyReport', 'DonateCC,Train', 'RequestCC']
				EndIf
				_ArrayShuffle($aRndFuncList)
				For $Index In $aRndFuncList
					If Not $g_bRunState Then Return
					_RunFunction($Index)
					If _Sleep($DELAYRUNBOT5) Then Return
					If $g_bRestart Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
					If CheckAndroidReboot() Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
				Next
				BoostEverything() ; 1st Check if is to use Training Potion
				If $g_bRestart Then ContinueLoop
				Local $aRndFuncList = ['BoostBarracks', 'BoostSpellFactory', 'BoostWorkshop', 'BoostKing', 'BoostQueen', 'BoostWarden', 'BoostChampion']
				_ArrayShuffle($aRndFuncList)
				For $Index In $aRndFuncList
					If Not $g_bRunState Then Return
					_RunFunction($Index)
					If $g_bRestart Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
					If CheckAndroidReboot() Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
				Next

				If Not $g_bRunState Then Return
				If $g_iUnbrkMode >= 1 Then
					If Unbreakable() Then ContinueLoop
				EndIf
				If $g_bRestart Then ContinueLoop
			EndIf
			; Train Donate only - force a donate cc every time
			If ($g_iCommandStop = 3 Or $g_iCommandStop = 0) Then _RunFunction('DonateCC,Train')
			If $g_bRestart Then ContinueLoop
			If $g_bChkFastSwitchAcc Then
				Local $aRndFuncList = ['UpgradeHeroes', 'PetHouse', 'BuilderBase']
			Else
				Local $aRndFuncList = ['Collect', 'CollectAchievements', 'Laboratory', 'UpgradeHeroes', 'UpgradeBuilding', 'UpgradeWall', 'PetHouse', 'BuilderBase']
			EndIf
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep($DELAYRUNBOT5) Then Return
				If $g_bRestart Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
				If CheckAndroidReboot() Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
			Next

			If Not $g_bRunState Then Return
			If $g_bFirstStart Then SetDebugLog("First loop completed!")
			$g_bFirstStart = False ; already finished first loop since bot started.

			If ProfileSwitchAccountEnabled() And ($g_iCommandStop = 0 Or $g_iCommandStop = 3 Or $g_abDonateOnly[$g_iCurAccount] Or $g_bForceSwitch) Then checkSwitchAcc()
			If IsSearchAttackEnabled() Then ; If attack scheduled has attack disabled now, stop wall upgrades, and attack.
				Idle()
				;$g_bFullArmy1 = $g_bFullArmy
				If _Sleep($DELAYRUNBOT3) Then Return
				If $g_bRestart = True Then ContinueLoop

				If $g_iCommandStop <> 0 And $g_iCommandStop <> 3 Then
					AttackMain()
					$g_bSkipFirstZoomout = False
					If $g_bOutOfGold Then
						SetLog("Switching to Halt Attack, Stay Online/Collect mode ...", $COLOR_ERROR)
						ContinueLoop
					EndIf
					If _Sleep($DELAYRUNBOT1) Then Return
					If $g_bRestart = True Then ContinueLoop
				EndIf
			Else
				If ProfileSwitchAccountEnabled() Then
					$g_iCommandStop = 2
					_RunFunction('DonateCC,Train')
					checkSwitchAcc()
				EndIf
				$iWaitTime = Random($DELAYWAITATTACK1, $DELAYWAITATTACK2)
				SetLog("Attacking Not Planned and Skipped, Waiting random " & StringFormat("%0.1f", $iWaitTime / 1000) & " Seconds", $COLOR_WARNING)
				If _SleepStatus($iWaitTime) Then Return False
			EndIf
		Else ;When error occurs directly goes to attack
			Local $sRestartText = $g_bIsSearchLimit ? " due search limit" : " after Out of Sync Error: Attack Now"
			SetLog("Restarted" & $sRestartText, $COLOR_INFO)
			;Use "CheckDonateOften" setting to run loop on hitting SearchLimit
			If $g_bIsSearchLimit and $g_bCheckDonateOften Then
				SetDebugLog("ARCH: Clearing booleans", $COLOR_DEBUG)
				$g_bIsClientSyncError = False
				$g_bRestart = False
			EndIf
			If _Sleep($DELAYRUNBOT3) Then Return
			;  OCR read current Village Trophies when OOS restart maybe due PB or else DropTrophy skips one attack cycle after OOS
			$g_aiCurrentLoot[$eLootTrophy] = Number(getTrophyMainScreen($aTrophies[0], $aTrophies[1]))
			SetDebugLog("Runbot Trophy Count: " & $g_aiCurrentLoot[$eLootTrophy], $COLOR_DEBUG)
			If Not $g_bIsSearchLimit or Not $g_bCheckDonateOften Then AttackMain() ;If Search Limit hit, do main loop.
			SetDebugLog("ARCH: Not case on SearchLimit or CheckDonateOften",$COLOR_DEBUG)
			If Not $g_bRunState Then Return
			$g_bSkipFirstZoomout = False
			If $g_bOutOfGold Then
				SetLog("Switching to Halt Attack, Stay Online/Collect mode ...", $COLOR_ERROR)
				$g_bIsClientSyncError = False ; reset fast restart flag to stop OOS mode and start collecting resources
				ContinueLoop
			EndIf
			If _Sleep($DELAYRUNBOT5) Then Return
			If $g_bRestart = True Then ContinueLoop
		EndIf
		If _Sleep($DELAYRUNBOT1) Then Return
		If $g_bRestart = True Then ContinueLoop
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
	SetDebugLog("Func Idle ", $COLOR_DEBUG)

	While $g_bIsFullArmywithHeroesAndSpells = False

		CheckAndroidReboot()

		;Execute Notify Pending Actions
		NotifyPendingActions()
		If _Sleep($DELAYIDLE1) Then Return

		If $g_iCommandStop = -1 Then SetLog("====== Waiting for full army ======", $COLOR_SUCCESS)
		Local $hTimer = __TimerInit()
		If _Sleep($DELAYIDLE1) Then ExitLoop
		checkObstacles()

		If $g_bRestart Then ExitLoop
		If Random(0, $g_iCollectAtCount - 1, 1) = 0 Then ; This is prevent from collecting all the time which isn't needed anyway, chance to run is 1/$g_iCollectAtCount
			If ProfileSwitchAccountEnabled() And $g_bChkFastSwitchAcc Then
				Local $aRndFuncList = ['CheckTombs', 'CleanYard']
			Else
				Local $aRndFuncList = ['Collect', 'CheckTombs', 'RequestCC', 'DonateCC', 'CleanYard']
			EndIf
			_ArrayShuffle($aRndFuncList)
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If $g_bRestart Then ExitLoop
				If CheckAndroidReboot() Then ContinueLoop 2
			Next
			If Not $g_bRunState Then Return
			If $g_bRestart Then ExitLoop
			If _Sleep($DELAYIDLE1) Or Not $g_bRunState Then ExitLoop
		EndIf

		If $g_bCheckDonateOften Then _RunFunction('DonateCC')
		If $g_bRestart Then ExitLoop

		AddIdleTime()

		If $g_iCommandStop = -1 Then
			If $g_iActualTrainSkip < $g_iMaxTrainSkip Then
				If CheckNeedOpenTrain($g_sTimeBeforeTrain) Then TrainSystem()
				If $g_bRestart = True Then ExitLoop
				If _Sleep($DELAYIDLE1) Then ExitLoop
				$g_iActualTrainSkip = $g_iActualTrainSkip + 1
			Else
				SetLog("Humanize bot, prevent to delete and recreate troops " & $g_iActualTrainSkip + 1 & "/" & $g_iMaxTrainSkip, $color_blue)
				If $g_iActualTrainSkip >= $g_iMaxTrainSkip Then
					$g_iActualTrainSkip = 0
				EndIf
				CheckArmyCamp(True, True)
			EndIf
		EndIf
		If _Sleep($DELAYIDLE1) Then Return
		If $g_iCommandStop = 0 And $g_bTrainEnabled Then
			If Not ($g_bIsFullArmywithHeroesAndSpells) Then
				If $g_iActualTrainSkip < $g_iMaxTrainSkip Then
					If CheckNeedOpenTrain($g_sTimeBeforeTrain) Or (ProfileSwitchAccountEnabled() And $g_iActiveDonate And $g_bChkDonate) Then TrainSystem() ; force check trainsystem after donate and before switch account
					If $g_bRestart Then ExitLoop
					If _Sleep($DELAYIDLE1) Then ExitLoop
					;xbenk
					;checkMainScreen(False)
					If Not $g_bRunState Then Return
					$g_iActualTrainSkip = $g_iActualTrainSkip + 1
				Else
					If $g_iActualTrainSkip >= $g_iMaxTrainSkip Then
						$g_iActualTrainSkip = 0
					EndIf
					CheckArmyCamp(True, True)
					If Not $g_bRunState Then Return
				EndIf
			EndIf
			If $g_bIsFullArmywithHeroesAndSpells And $g_bTrainEnabled Then
				SetLog("Army Camp is full, stop Training", $COLOR_ACTION)
				$g_iCommandStop = 3
			EndIf
		EndIf
		If _Sleep($DELAYIDLE1) Then Return
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
		If $g_bOutOfGold Or $g_bOutOfElixir Then Return ; Halt mode due low resources, only 1 idle loop

		If ProfileSwitchAccountEnabled() Then checkSwitchAcc() ; Forced to switch when in halt attack mode

		If ($g_iCommandStop = 3 Or $g_iCommandStop = 0) And $g_bTrainEnabled = False Then ExitLoop ; If training is not enabled, run only 1 idle loop

		If $g_iCommandStop = -1 Then ; Check if closing bot/emulator while training and not in halt mode
			SmartWait4Train()
			checkObstacles()
			If Not $g_bRunState Then Return
			If $g_bRestart Then ExitLoop ; if smart wait activated, exit to runbot in case user adjusted GUI or left emulator/bot in bad state
		EndIf

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
			;If ProfileSwitchAccountEnabled() And ($g_aiAttackedCountSwitch[$g_iCurAccount] <= $g_aiAttackedCount - 2) Then checkSwitchAcc()
			If $g_bUseCCBalanced Then ;launch profilereport() only if option balance D/R is activated
				ProfileReport()
				If Not $g_bRunState Then Return
				If _Sleep($DELAYATTACKMAIN1) Then Return
				checkMainScreen(False, $g_bStayOnBuilderBase, "AttackMain")
				If $g_bRestart Then Return
			EndIf
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
			If $g_bDebugSetlog Then
				SetDebugLog(_PadStringCenter(" Hero status check" & BitAND($g_aiAttackUseHeroes[$DB], $g_aiSearchHeroWaitEnable[$DB], $g_iHeroAvailable) & "|" & $g_aiSearchHeroWaitEnable[$DB] & "|" & $g_iHeroAvailable, 54, "="), $COLOR_DEBUG)
				SetDebugLog(_PadStringCenter(" Hero status check" & BitAND($g_aiAttackUseHeroes[$LB], $g_aiSearchHeroWaitEnable[$LB], $g_iHeroAvailable) & "|" & $g_aiSearchHeroWaitEnable[$LB] & "|" & $g_iHeroAvailable, 54, "="), $COLOR_DEBUG)
				;SetLog("BullyMode: " & $g_abAttackTypeEnable[$TB] & ", Bully Hero: " & BitAND($g_aiAttackUseHeroes[$g_iAtkTBMode], $g_aiSearchHeroWaitEnable[$g_iAtkTBMode], $g_iHeroAvailable) & "|" & $g_aiSearchHeroWaitEnable[$g_iAtkTBMode] & "|" & $g_iHeroAvailable, $COLOR_DEBUG)
			EndIf
			If Not $g_bRunState Then Return
			_ClanGames(False, $g_bChkForceBBAttackOnClanGames) ;Trying to do this above in the main loop
			;ClickAway()
			;If ProfileSwitchAccountEnabled() And $g_bForceSwitchifNoCGEvent Then
			;	SetLog("No Event on ClanGames, Forced switch account!", $COLOR_SUCCESS)
			;	checkSwitchAcc()
			;EndIf
			If Not $g_bRunState Then Return
			If $g_bUpdateSharedPrefs And $g_bChkSharedPrefs Then PullSharedPrefs()
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
	If $g_bChkOnlyAttack And Not $action = 'BuilderBase' Then
		SetLog($Action & " - Only attack enabled, Skip", $COLOR_ACTION)
		Return
	EndIf

	Switch $action
		Case "Collect"
			Collect()
			_Sleep($DELAYRUNBOT1)
		Case "CheckTombs"
			CheckTombs()
			_Sleep($DELAYRUNBOT3)
		Case "CleanYard"
			CleanYard()
		Case "ReplayShare"
			ReplayShare($g_bShareAttackEnableNow)
			_Sleep($DELAYRUNBOT3)
		Case "NotifyReport"
			NotifyReport()
			_Sleep($DELAYRUNBOT3)
		Case "DonateCC"
			If $g_iActiveDonate And $g_bChkDonate Then
				If (Not SkipDonateNearFullTroops(True) Or $g_iCommandStop = 3 Or $g_iCommandStop = 0) And BalanceDonRec(True) Then DonateCC()
			EndIf
		Case "DonateCC,Train"
			If $g_iActiveDonate And $g_bChkDonate Then
				If $g_bFirstStart Then
					getArmyTroopCapacity(True, False)
					If _Sleep($DELAYRESPOND) Then Return
					getArmySpellCapacity(False, True)
					If _Sleep($DELAYRESPOND) Then Return
				EndIf
				; if in "Halt/Donate" don't skip near full army
				If (Not SkipDonateNearFullTroops(True) Or $g_iCommandStop = 3 Or $g_iCommandStop = 0) And BalanceDonRec(True) Then DonateCC()
			EndIf

			If $g_bTrainEnabled Then ; check for training enabled in halt mode
				If $g_iActualTrainSkip < $g_iMaxTrainSkip Then
					TrainSystem()
					_Sleep($DELAYRUNBOT1)
				Else
					SetLog("Humanize bot, prevent to delete and recreate troops " & $g_iActualTrainSkip + 1 & "/" & $g_iMaxTrainSkip, $color_blue)
					$g_iActualTrainSkip = $g_iActualTrainSkip + 1
					If $g_iActualTrainSkip >= $g_iMaxTrainSkip Then
						$g_iActualTrainSkip = 0
					EndIf
					CheckOverviewFullArmy(True, False) ; use true parameter to open train overview window
					If _Sleep($DELAYRESPOND) Then Return
					getArmySpells()
					If _Sleep($DELAYRESPOND) Then Return
					getArmyHeroCount(False, True)
				EndIf
			Else
				If $g_bDebugSetlogTrain Then SetLog("Halt mode - training disabled", $COLOR_DEBUG)
			EndIf
		Case "BoostBarracks"
			BoostBarracks()
			_Sleep($DELAYRESPOND)
		Case "BoostSpellFactory"
			BoostSpellFactory()
			_Sleep($DELAYRESPOND)
		Case "BoostWorkshop"
			BoostWorkshop()
			_Sleep($DELAYRESPOND)
		Case "BoostKing"
			BoostKing()
			_Sleep($DELAYRESPOND)
		Case "BoostQueen"
			BoostQueen()
			_Sleep($DELAYRESPOND)
		Case "BoostWarden"
			BoostWarden()
			_Sleep($DELAYRESPOND)
		Case "BoostChampion"
			BoostChampion()
			_Sleep($DELAYRESPOND)
		Case "BoostEverything"
			BoostEverything()
			_Sleep($DELAYRESPOND)
		Case "DailyChallenge"
			DailyChallenges()
			_Sleep($DELAYRUNBOT3)
			checkMainScreen(False, $g_bStayOnBuilderBase, "DailyChallenge")
		 Case "RequestCC"
			RequestCC()
			ClickAway()
		Case "Laboratory"
			Laboratory()
			_Sleep($DELAYRUNBOT3)
			checkMainScreen(False, $g_bStayOnBuilderBase, "Laboratory")
		Case "PetHouse"
			PetHouse()
		Case "ForgeClanCapitalGold"
			ForgeClanCapitalGold()
		Case "BoostSuperTroop"
			BoostSuperTroop()
			_Sleep($DELAYRUNBOT3)
		Case "UpgradeHeroes"
			UpgradeHeroes()
			_Sleep($DELAYRUNBOT3)
		Case "UpgradeBuilding"
			UpgradeBuilding()
			If _Sleep($DELAYRUNBOT3) Then Return
			AutoUpgrade()
			ZoomOut()
			_Sleep($DELAYRUNBOT3)
		Case "UpgradeLow"
			AutoUpgrade(False, True)
			ZoomOut()
			_Sleep($DELAYRUNBOT3)
		Case "UpgradeWall"
			$g_iNbrOfWallsUpped = 0
			ClickAway()
			UpgradeWall()
			ZoomOut()
			_Sleep($DELAYRUNBOT3)
		Case "BuilderBase"
			If $g_bChkCollectBuilderBase Or $g_bChkStartClockTowerBoost Or $g_iChkBBSuggestedUpgrades Or $g_bChkEnableBBAttack Then
				BuilderBase()
			EndIf
			_Sleep($DELAYRUNBOT3)
		Case "CollectAchievements"
			CollectAchievements()
			_Sleep($DELAYRUNBOT3)
		Case "CollectFreeMagicItems"
			CollectFreeMagicItems()
			_Sleep($DELAYRUNBOT3)
		Case "SaleMagicItem"
			SaleMagicItem()
			_Sleep($DELAYRUNBOT3)
		Case "AutoUpgradeCC"
			AutoUpgradeCC()
			_Sleep($DELAYRUNBOT3)
		Case "CollectCCGold"
			CollectCCGold()
			_Sleep($DELAYRUNBOT3)
		Case ""
			SetDebugLog("Function call doesn't support empty string, please review array size", $COLOR_ERROR)
		Case Else
			SetLog("Unknown function call: " & $action, $COLOR_ERROR)
	EndSwitch
	SetDebugLog("_RunFunction: " & $action & " END", $COLOR_DEBUG2)
EndFunc   ;==>__RunFunction

Func FirstCheck()
	If Not $g_bRunState Then Return
	SetLog("-- FirstCheck Loop --")
	If _Sleep(50) Then Return
	checkMainScreen(True, $g_bStayOnBuilderBase, "FirstCheck")
	VillageReport(True, True)

	If ProfileSwitchAccountEnabled() And $g_abDonateOnly[$g_iCurAccount] Then Return

	$g_bRestart = False
	$g_bFullArmy = False
	$g_iCommandStop = -1

	;Check Town Hall level
	Local $iTownHallLevel = $g_iTownHallLevel
	Local $bLocateTH = False
	SetLog("Detecting Town Hall level", $COLOR_INFO)
	SetLog("Town Hall level is currently saved as " &  $g_iTownHallLevel, $COLOR_INFO)
	Collect(False) ;only collect from mine and collector
	If $g_aiTownHallPos[0] > -1 Then
		Click($g_aiTownHallPos[0], $g_aiTownHallPos[1])
		If _Sleep(800) Then Return
		Local $BuildingInfo = BuildingInfo(245, 494)
		If $BuildingInfo[1] = "Town Hall" Then
			$g_iTownHallLevel =  $BuildingInfo[2]
		Else
			$bLocateTH = True
		EndIf
	EndIf

	If $g_iTownHallLevel = 0 Or $bLocateTH Then
		imglocTHSearch(False, True, True) ;Sets $g_iTownHallLevel
	EndIf

	SetLog("Detected Town Hall level is " &  $g_iTownHallLevel, $COLOR_INFO)
	If $g_iTownHallLevel = $iTownHallLevel Then
		SetLog("Town Hall level has not changed", $COLOR_INFO)
	Else
		SetLog("Town Hall level has changed!", $COLOR_INFO)
		SetLog("New Town hall level detected as " &  $g_iTownHallLevel, $COLOR_INFO)
		applyConfig()
		saveConfig()
	EndIf

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
	chkShieldStatus()
	If $g_bOutOfGold And (Number($g_aiCurrentLoot[$eLootGold]) >= Number($g_iTxtRestartGold)) Then ; check if enough gold to begin searching again
		$g_bOutOfGold = False ; reset out of gold flag
		SetLog("Switching back to normal after no gold to search ...", $COLOR_SUCCESS)
		Return ; Restart bot loop to reset $g_iCommandStop & $g_bTrainEnabled + $g_bDonationEnabled via BotCommand()
	EndIf

	If $g_bOutOfElixir And (Number($g_aiCurrentLoot[$eLootElixir]) >= Number($g_iTxtRestartElixir)) And (Number($g_aiCurrentLoot[$eLootDarkElixir]) >= Number($g_iTxtRestartDark)) Then ; check if enough elixir to begin searching again
		$g_bOutOfElixir = False ; reset out of gold flag
		SetLog("Switching back to normal setting after no elixir to train ...", $COLOR_SUCCESS)
		Return ; Restart bot loop to reset $g_iCommandStop & $g_bTrainEnabled + $g_bDonationEnabled via BotCommand()
	EndIf

	If isElixirFull() Then
		Laboratory()
		VillageReport(True, True)
	EndIf

	If $g_iFreeBuilderCount > 0 Then
		Setlog("Your Account have FREE BUILDER", $COLOR_INFO)
		If Not $g_bRunState Then Return
		CheckTombs()
		CleanYard()
		_Sleep(8000) ;add wait after clean yard
		If Not $g_bRunState Then Return
		If $g_bUpgradeWallEarly Then
			SetLog("Check Upgrade Wall Early", $COLOR_INFO)
			UpgradeWall()
		EndIf
		If Not $g_bRunState Then Return
		If $g_bAutoUpgradeEarly Then
			SetLog("Check Auto Upgrade Early", $COLOR_INFO)
			checkArmyCamp(True, True) ;need to check reserved builder for heroes
			AutoUpgrade()
		EndIf
		VillageReport()
		ZoomOut()
	EndIf

	If BotCommand() Then btnStop()

	If T420() Then
		SetLog("Test420 Done!", $COLOR_SUCCESS)
	EndIf

	If ProfileSwitchAccountEnabled() And ($g_iCommandStop = 0 Or $g_iCommandStop = 1) Then
		If Not $g_bSkipFirstCheckRoutine Then FirstCheckRoutine()
		If Not $g_bSkipBB Then _RunFunction('BuilderBase')
		If Not $g_bSkipTrain Then TrainSystem()
		checkSwitchAcc()
	Else
		FirstCheckRoutine()
	EndIf
EndFunc   ;==>FirstCheck

Func FirstCheckRoutine()
	Local $b_SuccessAttack = False
	SetLog("======== FirstCheckRoutine ========", $COLOR_ACTION)
	If Not $g_bRunState Then Return
	checkMainScreen(True, $g_bStayOnBuilderBase, "FirstCheckRoutine")
	If $g_bChkCGBBAttackOnly Then
		SetLog("Enabled Do Only BB Challenges", $COLOR_INFO)
		For $count = 1 to 11
			If Not $g_bRunState Then Return
			If $count > 10 Then
				SetLog("Something maybe wrong, exiting to MainLoop!", $COLOR_INFO)
				ExitLoop
			EndIf

			If _ClanGames(False, $g_bChkForceBBAttackOnClanGames) Then
				SetLog("[" & $count & "] Trying to complete BB Challenges", $COLOR_INFO)
				If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
					SetLog("Forced BB Attack On ClanGames", $COLOR_INFO)
					GotoBBTodoCG()
				Else
					ExitLoop ;should be will never get here, but
				EndIf
			Else
				If $g_bIsCGPointMaxed Then ExitLoop ; If point is max then continue to main loop
				If Not $g_bIsCGEventRunning Then ExitLoop ; No Running Event after calling ClanGames
				If $g_bChkClanGamesStopBeforeReachAndPurge and $g_bIsCGPointAlmostMax Then ExitLoop ; Exit loop if want to purge near max point
			EndIf
			If isOnMainVillage() Then ZoomOut()	; Verify is on main village and zoom out
		Next
	Else
		If $g_bCheckCGEarly And $g_bChkClanGamesEnabled Then
			SetLog("Check ClanGames Early", $COLOR_INFO)
			_ClanGames(False, $g_bChkForceBBAttackOnClanGames)
			If Not $g_bRunState Then Return
			If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
				SetLog("Forced BB Attack On ClanGames", $COLOR_INFO)
				GotoBBTodoCG()
			EndIf
		EndIf
	EndIf

	;Skip switch if Free Builder > 0 Or Storage Fill is Low, when clangames
	Local $bSwitch = True
	If $g_iFreeBuilderCount - ($g_bUpgradeWallSaveBuilder ? 1 : 0) > 0 Then $bSwitch = False
	If $g_abLowStorage[$eLootElixir] Or $g_abLowStorage[$eLootGold] Then $bSwitch = False

	If Not $g_bRunState Then Return
	If ProfileSwitchAccountEnabled() And $g_bForceSwitchifNoCGEvent And Number($g_aiCurrentLoot[$eLootTrophy]) < 4900 And $bSwitch Then
		SetLog("No Event on ClanGames, Forced switch account!", $COLOR_SUCCESS)
		PrepareDonateCC()
		DonateCC()
		TrainSystem()
		CommonRoutine("NoClanGamesEvent")
		$g_bForceSwitchifNoCGEvent = True
		checkSwitchAcc() ;switch to next account
	EndIf

	If Not $g_bRunState Then Return
	If $g_iCommandStop <> 3 And $g_iCommandStop <> 0 Then
		; VERIFY THE TROOPS AND ATTACK IF IS FULL
		SetLog("-- FirstCheck on Train --", $COLOR_DEBUG)
		If Not $g_bRunState Then Return
		If $g_bDonateEarly Then
			SetLog("Donate Early Enabled", $COLOR_INFO)
			checkArmyCamp(True, True)
			_Sleep(1000)
			PrepareDonateCC()
			DonateCC()
		EndIf
		TrainSystem()
		SetLog("Are you ready? " & String($g_bIsFullArmywithHeroesAndSpells), $COLOR_INFO)
		If $g_bIsFullArmywithHeroesAndSpells Then
			; Now the bot can attack
			If $g_iCommandStop <> 0 And $g_iCommandStop <> 3 Then
				Setlog("Before any other routine let's attack!", $COLOR_INFO)
				Local $loopcount = 1
				While True
					$g_bRestart = False
					If Not $g_bRunState Then Return
					If AttackMain($g_bSkipDT) Then
						Setlog("[" & $loopcount & "] 1st Attack Loop Success", $COLOR_SUCCESS)
						If checkMainScreen(False, $g_bStayOnBuilderBase, "FirstCheckRoutine") Then ZoomOut()
						ExitLoop
					Else
						If $g_bForceSwitch Then ExitLoop ;exit here
						$loopcount += 1
						If $loopcount > 5 Then
							Setlog("1st Attack Loop, Already Try 5 times... Exit", $COLOR_ERROR)
							ExitLoop
						Else
							Setlog("[" & $loopcount & "] 1st Attack Loop, Failed", $COLOR_INFO)
						EndIf
						If Not $g_bRunState Then Return
					EndIf
				Wend
				If $g_bIsCGEventRunning And $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
					SetLog("Forced BB Attack On ClanGames", $COLOR_INFO)
					SetLog("Because running CG Event is BB Challenges", $COLOR_INFO)
					GotoBBTodoCG() ;force go to bb todo event
				EndIf
				If $g_bOutOfGold Then
					SetLog("Switching to Halt Attack, Stay Online/Collect mode", $COLOR_ERROR)
					$g_bFirstStart = True ; reset First time flag to ensure army balancing when returns to training
					Return
				EndIf
				If _Sleep($DELAYRUNBOT1) Then Return
			EndIf
		EndIf
	EndIf

	If Not $g_bRunState Then Return
	If ProfileSwitchAccountEnabled() And ($g_bIsCGPointAlmostMax Or $g_bIsCGPointMaxed) And $g_bChkForceSwitchifNoCGEvent Then ; forced switch after first attack if cg point is almost max
		SetLog("ClanGames point almost max/maxed, Forced switch account!", $COLOR_SUCCESS)
		TrainSystem()
		CommonRoutine("NoClanGamesEvent")
		$g_bForceSwitchifNoCGEvent = True
		checkSwitchAcc() ;switch to next account
	EndIf

	If Not $g_bRunState Then Return
	If ProfileSwitchAccountEnabled() And $g_bForceSwitch Then
		PrepareDonateCC()
		DonateCC()
		TrainSystem()
		checkSwitchAcc() ;switch to next account
	EndIf

	If Not $g_bRunState Then Return
	If ProfileSwitchAccountEnabled() And $g_bChkFastSwitchAcc Then ;Allow immediate Second Attack on FastSwitchAcc enabled
		If _Sleep($DELAYRUNBOT2) Then Return
		VillageReport()
		If _Sleep($DELAYRUNBOT2) Then Return
		If BotCommand() Then btnStop()
		If Not $g_bRunState Then Return
		If $g_iCommandStop <> 3 And $g_iCommandStop <> 0 Then
			; VERIFY THE TROOPS AND ATTACK IF IS FULL
			SetLog("-- SecondCheck on Train --", $COLOR_DEBUG)
			SetLog("Fast Switch Account Enabled", $COLOR_DEBUG)
			TrainSystem()
			SetLog("Are you ready? " & String($g_bIsFullArmywithHeroesAndSpells), $COLOR_INFO)
			If $g_bIsFullArmywithHeroesAndSpells Then
				If $g_iCommandStop <> 0 And $g_iCommandStop <> 3 Then
					Setlog("Before any other routine let's attack!", $COLOR_INFO)
					$g_bRestart = False ;idk this flag make sometimes bot cannot attack on second time
					Local $loopcount = 1
					While True
						$g_bRestart = False
						If Not $g_bRunState Then Return
						If AttackMain($g_bSkipDT) Then
							Setlog("[" & $loopcount & "] 2nd Attack Loop Success", $COLOR_SUCCESS)
							$b_SuccessAttack = True
							If checkMainScreen(False, $g_bStayOnBuilderBase, "FirstCheckRoutine") Then ZoomOut()
							ExitLoop
						Else
							If $g_bForceSwitch Then ExitLoop ;exit here
							$loopcount += 1
							If $loopcount > 5 Then
								Setlog("2nd Attack Loop, Already Try 5 times... Exit", $COLOR_ERROR)
								ExitLoop
							Else
								Setlog("[" & $loopcount & "] 2nd Attack Loop, Failed", $COLOR_INFO)
							EndIf
							If Not $g_bRunState Then Return
						EndIf
					Wend
					If $g_bIsCGEventRunning And $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
						SetLog("Forced BB Attack On ClanGames", $COLOR_INFO)
						SetLog("Because running CG Event is BB Challenges", $COLOR_INFO)
						GotoBBTodoCG() ;force go to bb todo event
					EndIf
					If $g_bOutOfGold Then
						SetLog("Switching to Halt Attack, Stay Online/Collect mode", $COLOR_ERROR)
						$g_bFirstStart = True ; reset First time flag to ensure army balancing when returns to training
						Return
					EndIf
					If _Sleep($DELAYRUNBOT1) Then Return
				EndIf
			EndIf
		EndIf
	EndIf

	If Not $g_bRunState Then Return
	RequestCC(True)
	checkArmyCamp(True, True)
	PrepareDonateCC()
	_Sleep(1000)
	DonateCC()
	If $b_SuccessAttack Then TrainSystem()
	If Not $g_bRunState Then Return
	CommonRoutine("FirstCheckRoutine")
	If ProfileSwitchAccountEnabled() And ($g_bForceSwitch Or $g_bChkFastSwitchAcc) Then
		CommonRoutine("Switch")
		checkSwitchAcc() ;switch to next account
	EndIf
EndFunc

Func CommonRoutine($RoutineType = Default)
	If $RoutineType = Default Then $RoutineType = "FirstCheckRoutine"
	Switch $RoutineType
		Case "FirstCheckRoutine"
			Local $aRndFuncList = ['Collect', 'DailyChallenge', 'CollectAchievements','CheckTombs', 'CleanYard', "SaleMagicItem", 'Laboratory', 'CollectFreeMagicItems']
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep(500) Then Return
				If $g_bRestart Then Return
			Next
			Local $aRndFuncList = ['PetHouse', 'ForgeClanCapitalGold', 'CollectCCGold', 'AutoUpgradeCC']
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep(500) Then Return
				If $g_bRestart Then Return
			Next

		Case "NoClanGamesEvent"
			Local $aRndFuncList = ['Collect', 'PetHouse', 'Laboratory', 'UpgradeBuilding', 'UpgradeWall', 'BuilderBase', 'CollectCCGold', 'AutoUpgradeCC']
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep(50) Then Return
				If $g_bRestart Then Return
			Next

		Case "Switch"
			Local $aRndFuncList = ['BuilderBase', 'CollectCCGold', 'CollectFreeMagicItems', 'AutoUpgradeCC', 'DonateCC,Train', 'UpgradeHeroes', 'UpgradeBuilding', 'UpgradeWall', 'UpgradeLow']
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep(50) Then Return
				If $g_bRestart Then Return
			Next
	EndSwitch
EndFunc

Func BuilderBase()

	; switch to builderbase and check it is builderbase
	If SwitchBetweenBases("BB") Then
		$g_bStayOnBuilderBase = True
		Local $StartLabON = False
		checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
		ZoomOut()
		$g_iBBAttacked = True	; Reset Variable
		BuilderBaseReport()
		CollectBuilderBase()
		checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")

		CleanBBYard()
		If _Sleep($DELAYRUNBOT1) Then Return
		checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")

		If isGoldFullBB() Or isElixirFullBB() Then
			AutoUpgradeBB()
			$g_iBBAttacked = False
			If _Sleep($DELAYRUNBOT1) Then Return
			checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
			$g_iBBAttacked = False
		EndIf

		If isElixirFullBB() Then
			$StartLabON = StarLaboratory()
			$g_iBBAttacked = False
			If _Sleep($DELAYRUNBOT1) Then Return
			checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
		EndIf

		If Not BBDropTrophy() Then
			If _Sleep($DELAYRUNBOT1) Then Return
			DoAttackBB()
			checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
			If _Sleep($DELAYRUNBOT1) Then Return
		EndIf

		If $g_iBBAttacked Then
			AutoUpgradeBB()
			If _Sleep($DELAYRUNBOT1) Then Return
			checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")

			$StartLabON = StarLaboratory()
			If _Sleep($DELAYRUNBOT1) Then Return
			checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
			ZoomOut(True) ;directly zoom
		EndIf

		Local $bUseCTPot = $StartLabON And $g_iFreeBuilderCountBB = 0 And Not ($g_bGoldStorageFullBB Or $g_bElixirStorageFullBB)
		StartClockTowerBoost(False, False, $bUseCTPot)

		If _Sleep($DELAYRUNBOT3) Then Return
		BuilderBaseReport(False, True, False)
		If _Sleep($DELAYRUNBOT3) Then Return

		$g_bStayOnBuilderBase = False
		SwitchBetweenBases("Main")
	EndIf

	If Not $g_bStayOnBuilderBase And IsOnBuilderBase() Then SwitchBetweenBases("Main")
EndFunc

Func TestBuilderBase()
	Local $bChkCollectBuilderBase = $g_bChkCollectBuilderBase
	Local $bChkStartClockTowerBoost = $g_bChkStartClockTowerBoost
	Local $bChkCTBoostBlderBz = $g_bChkCTBoostBlderBz
	Local $bChkCleanBBYard = $g_bChkCleanBBYard
	Local $bChkEnableBBAttack = $g_bChkEnableBBAttack

	$g_bChkCollectBuilderBase = True
	$g_bChkStartClockTowerBoost = True
	$g_bChkCTBoostBlderBz = True
	$g_bChkCleanBBYard = True
	$g_bChkEnableBBAttack = True

	BuilderBase()

	If _Sleep($DELAYRUNBOT3) Then Return

	$g_bChkCollectBuilderBase = $bChkCollectBuilderBase
	$g_bChkStartClockTowerBoost = $bChkStartClockTowerBoost
	$g_bChkCTBoostBlderBz = $bChkCTBoostBlderBz
	$g_bChkCleanBBYard = $bChkCleanBBYard
	$g_bChkEnableBBAttack = $bChkEnableBBAttack
 EndFunc

 Func SetSAtk($attack = False)

	If $attack = True Then
		$g_bTestSceneryAttack = True
	Else
		$g_bTestSceneryAttack = False
	EndIf

EndFunc

Func GotoBBTodoCG()
	If SwitchBetweenBases("BB") And isOnBuilderBase() Then
		$g_bStayOnBuilderBase = True
		CollectBuilderBase()
		DoAttackBB(0)
		; switch back to normal village
		SwitchBetweenBases("Main")
		$g_bStayOnBuilderBase = False
	EndIf
EndFunc

Func RemControl()
	For $i = $g_hChkCustomTrainOrderEnable To $g_ahImgTroopOrderSet
		GUICtrlDelete($i)
	Next
	For $i = $g_hChkCustomBrewOrderEnable To $g_ahImgSpellsOrderSet
		GUICtrlDelete($i)
	Next
	For $i = $g_ahChkArmy[0] To $g_ahChkArmy[UBound($g_ahChkArmy) - 1]
		GUICtrlDelete($i)
	Next
	For $i = $g_ahChkUseInGameArmy[0] To $g_ahChkUseInGameArmy[UBound($g_ahChkUseInGameArmy) - 1]
		GUICtrlDelete($i)
	Next
	For $i = $g_ahBtnEditArmy[0] To $g_ahBtnEditArmy[UBound($g_ahBtnEditArmy) - 1]
		GUICtrlDelete($i)
	Next
	For $i = $g_ahLblEditArmy[0] To $g_ahLblEditArmy[UBound($g_ahLblEditArmy) - 1]
		GUICtrlDelete($i)
	Next
	For $i = $g_ahLblTotalQTroop[0] To $g_ahLblTotalQTroop[UBound($g_ahLblTotalQTroop) - 1]
		GUICtrlDelete($i)
	Next
	For $i = $g_ahPicTotalQTroop[0] To $g_ahPicTotalQTroop[UBound($g_ahPicTotalQTroop) - 1]
		GUICtrlDelete($i)
	Next
	For $i = $g_ahLblTotalQSpell[0] To $g_ahLblTotalQSpell[UBound($g_ahLblTotalQSpell) - 1]
		GUICtrlDelete($i)
	Next
	For $i = $g_ahPicTotalQSpell[0] To $g_ahPicTotalQSpell[UBound($g_ahPicTotalQSpell) - 1]
		GUICtrlDelete($i)
	Next
	For $i = $g_ahLblQuickTrainNote[0] To $g_ahLblQuickTrainNote[UBound($g_ahLblQuickTrainNote) - 1]
		GUICtrlDelete($i)
	Next
	For $i = $g_ahLblUseInGameArmyNote[0] To $g_ahLblUseInGameArmyNote[UBound($g_ahLblUseInGameArmyNote) - 1]
		GUICtrlDelete($i)
	Next
	For $i = $g_hChkCustomDropOrderEnable To $g_hBtnRemoveDropOrder
		GUICtrlDelete($i)
	Next
EndFunc

Func T420()
	If IsDeclared("g_VariableTest123") = 1 Then
		SetLog("Execute Test420()", $COLOR_INFO)
		Return Execute("Test420()")
	EndIf
EndFunc