; #FUNCTION# ====================================================================================================================
; Name ..........: OpenLDPlayer9
; Description ...:
; Syntax ........: OpenLDPlayer9([$bRestart = False])
; Parameters ....: $bRestart            - [optional] a boolean value. Default is False.
; Return values .: None
; Author ........: xbebenk (2025)
; Modified ......: 
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func GetLDPlayer9ProgramParameter($bAlternative = False)
	If $bAlternative Then Return AddSpace("index=") & StringReplace($g_sAndroidInstance, "leidian", "")
	Return AddSpace("index=" & StringReplace($g_sAndroidInstance, "leidian", "") & "|")
EndFunc   ;==>LDPlayer9ProgramParameter


Func OpenLDPlayer9($bRestart = False)
	SetLog("Starting LDPlayer9", $COLOR_SUCCESS)
	If Not InitAndroid() Then Return False
	Return _OpenLDPlayer9($bRestart)
EndFunc   ;==>OpenLDPlayer9X

Func _OpenLDPlayer9($bRestart = False)
	Local $hTimer, $iCount = 0
	Local $ErrorResult, $connected_to, $process_killed
	Local $Cmd = $__LDPlayer9_Path & "ldconsole.exe"
	Local $iInstance = StringReplace($g_sAndroidInstance, "leidian", "")
	Local $sCmdParam = "launch --index " & $iInstance
	
	; always start ADB first to avoid ADB connection problems
	LaunchConsole($g_sAndroidAdbPath, AddSpace($g_sAndroidAdbGlobalOptions) & "start-server", $process_killed)

	If WinGetAndroidHandle() = 0 Then 
		LaunchConsole($Cmd, AddSpace($sCmdParam), $process_killed)
		If _SleepStatus(5000) Then Return
	Else
		SetLog("LDPlayer9 Already Loaded")
		Return True
	EndIf
	
	
	$hTimer = __TimerInit() ; start a timer for tracking BS start up time
	While $g_hAndroidControl = 0
		_StatusUpdateTime($hTimer, $g_sAndroidEmulator & " Starting")
		If __TimerDiff($hTimer) > $g_iAndroidLaunchWaitSec * 1000 Then ; if no BS position returned in 4 minutes, BS/PC has major issue so exit
			SetLog("Serious error has occurred, please restart PC and try again", $COLOR_ERROR)
			SetLog("LDPlayer9 refuses to load, waited " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_ERROR)
			SetLog("Unable to continue........", $COLOR_WARNING)
			btnstop()
			SetError(1, 1, -1)
			Return False
		EndIf
		WinGetAndroidHandle()
	WEnd

	If $g_hAndroidControl Then
		$connected_to = ConnectAndroidAdb(False, 3000) ; small time-out as ADB connection must be available now
		If WaitForAndroidBootCompleted($g_iAndroidLaunchWaitSec - __TimerDiff($hTimer) / 1000, $hTimer) Then Return
		If Not $g_bRunState Then Return
		SetLog("LDPlayer9 Loaded, took " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds to begin.", $COLOR_SUCCESS)
		Return True
	EndIf
	Return False
EndFunc   ;==>_OpenLDPlayer9

Func GetLDPlayer9AdbPath()
	Local $adbPath = @ScriptDir & "\lib\adb\adb.exe"
	If FileExists($adbPath) Then Return $adbPath
	Return ""
EndFunc   ;==>GetLDPlayer9XAdbPath

Func InitLDPlayer9X($bCheckOnly = False)
	;LDPlayer9 doesn't have registry tree for engine, only installation dir info available on registry
	$__LDPlayer9_Version = RegRead($g_sHKLM & "\SOFTWARE" & $g_sWow6432Node & "\Microsoft\Windows\CurrentVersion\Uninstall\LDPlayer9\", "DisplayVersion")
	$__LDPlayer9_Path = RegRead($g_sHKLM & "\SOFTWARE\XuanZhi\LDPlayer9\", "InstallDir")
	
	Local $bFileFound = False
	Local $frontend_exe = "dnplayer.exe"
	$bFileFound = FileExists($__LDPlayer9_Path & $frontend_exe)
	
	If Not $bFileFound Then
		If Not $bCheckOnly Then
			SetLog("Serious error has occurred: Cannot find " & $g_sAndroidEmulator & ":", $COLOR_ERROR)
			SetLog($frontend_exe, $COLOR_ERROR)
			SetError(1, @extended, False)
		EndIf
		Return False
	EndIf
	
	Local $sPreferredADB = FindPreferredAdbPath()
	
	If Not $bCheckOnly Then
		; update global variables
		$g_sAndroidPath = $__LDPlayer9_Path
		$g_sAndroidProgramPath = $__LDPlayer9_Path & $frontend_exe
		$g_sAndroidAdbPath = $sPreferredADB
		$g_sAndroidVersion = $__LDPlayer9_Version
		ConfigureSharedFolderLDPlayer9() ;
		WinGetAndroidHandle()
	EndIf
	
	Return True
EndFunc   ;==>InitLDPlayer9

Func ConfigureSharedFolderLDPlayer9($iMode = 0, $bSetLog = Default)
	If $bSetLog = Default Then $bSetLog = True
	Local $bResult = False
	
	Local $__LDPlayer9_ConfigDir = $__LDPlayer9_Path & "vms\config\"
	Local $__LDPlayer9_InstanceConf = FileReadToArray($__LDPlayer9_ConfigDir & $g_sAndroidInstance & ".config")
	Local $iLineCount = @extended
	
	For $i = 0 To $iLineCount - 1
		If StringInStr($__LDPlayer9_InstanceConf[$i], '"statusSettings.sharedPictures": ') Then 
			Local $path = StringReplace($__LDPlayer9_InstanceConf[$i], '"statusSettings.sharedPictures": ', "")
			$path = StringStripWS(StringReplace(StringReplace(StringReplace($path, "/", "\"), ",", ""), '"', ''), $STR_STRIPALL) & "\"
			SetDebugLog($path)
			$g_sAndroidPicturesHostPath = $path
			$bResult = True
			$g_bAndroidSharedFolderAvailable = True
			$g_sAndroidPicturesPath = "/mnt/shared/Pictures/"
			SetDebugLog("g_sAndroidPicturesHostPath = " & $g_sAndroidPicturesHostPath)
			SetDebugLog("g_sAndroidPicturesPath = " & $g_sAndroidPicturesPath)
		EndIf
	Next
	
	Return SetError(0, 0, $bResult)
EndFunc   ;==>ConfigureSharedFolderLDPlayer9

Func InitLDPlayer9($bCheckOnly = False)
	Local $bInstalled = InitLDPlayer9X($bCheckOnly)
	If $bInstalled And StringInStr($__LDPlayer9_Version, "9.") <> 1 Then
		SetLog("LDPlayer9 supported version 9.x not found", $COLOR_ERROR)
		SetError(1, @extended, False)
		Return False
	EndIf
	
	Local $iAdbPort, $iAdbPortBase = 5555
	Local $iInstance = StringReplace($g_sAndroidInstance, "leidian", "")
	
	$iAdbPort = $iAdbPortBase + $iInstance
	$g_sAndroidAdbDevice = "emulator-" & $iAdbPort
	
	If $bInstalled And Not $bCheckOnly Then		
		$g_sAndroidAdbShellOptions = " /system/xbin/su root" 
		$g_iAndroidAdbMinitouchMode = 1
		GetLDPlayer9BackgroundMode()
	EndIf

	Return $bInstalled
EndFunc   ;==>InitLDPlayer9

Func GetLDPlayer9BackgroundMode()
	; check LDPlayer9 renderer mode
	
	Local $GLRenderMode = "dx"
	
	Switch $GLRenderMode
		Case "dx", "vlcn"
			; DirectX
			$g_iAndroidBackgroundMode = $g_iAndroidBackgroundModeDirectX
			Return $g_iAndroidBackgroundModeDirectX
		Case "gl"
			; OpenGL
			$g_iAndroidBackgroundMode = $g_iAndroidBackgroundModeOpenGL
			Return $g_iAndroidBackgroundModeOpenGL
		Case Else
			SetLog($g_sAndroidEmulator & " unsupported render mode " & $GLRenderMode, $COLOR_WARNING)
			Return 0
	EndSwitch
EndFunc   ;==>GetLDPlayer9BackgroundMode

Func CheckScreenLDPlayer9($bSetLog = True)
	Local $__LDPlayer9_ConfigDir = $__LDPlayer9_Path & "vms\config\"
	Local $__LDPlayer9Conf = FileReadToArray($__LDPlayer9_ConfigDir & $g_sAndroidInstance & ".config")
	Local $iLineCount = @extended

	Local $aiSearch = ['"width": ', '"height": ', '"advancedSettings.resolutionDpi": ', '"statusSettings.playerName": ']

	Local $aiMustBe = ['"width": ' & $g_iGAME_WIDTH, '"height": ' & $g_iGAME_HEIGHT, '"advancedSettings.resolutionDpi": ' & 160, _ 
					   '"statusSettings.playerName": ' & '"LD9-' & StringReplace($g_sAndroidInstance, "leidian", "") & '"']
	
	For $iSearch = 0 To UBound($aiSearch) - 1
		If $g_bDebugSetLog Then SetLog("Search for : " & $aiMustBe[$iSearch], $COLOR_DEBUG)
		For $i = 0 To $iLineCount - 1
			If StringInStr($__LDPlayer9Conf[$i], $aiSearch[$iSearch]) Then
				If $g_bDebugSetLog Then SetLog("Found: " & $__LDPlayer9Conf[$i], $COLOR_DEBUG2)
				If StringInStr($__LDPlayer9Conf[$i], $aiMustBe[$iSearch]) = 0 Then
					If $g_bDebugSetLog Then SetLog("Not Match: " & $__LDPlayer9Conf[$i] & " <> " & $aiMustBe[$iSearch], $COLOR_DEBUG1)
					If $bSetLog = True Then SetLog("Please wait, Bot will configure your LDPlayer9", $COLOR_ERROR)
					Return False
				Else 
					If $g_bDebugSetLog Then SetLog("Match: " & $aiMustBe[$iSearch], $COLOR_DEBUG2)
				EndIf
			EndIf
		Next
	Next
	
	Return True
EndFunc   ;==>CheckScreenLDPlayer9

Func SetScreenLDPlayer9()
	Local $Cmd = $__LDPlayer9_Path & "ldconsole.exe", $process_killed
	Local $iInstance = StringReplace($g_sAndroidInstance, "leidian", "")
	Local $sCmdEditConf = "modify --index " & $iInstance & " --resolution 860,676,160 --root 1"
	Local $sCmdEditName = "rename --index " & $iInstance & " --title LD9-" & $iInstance
	
	LaunchConsole($Cmd, AddSpace($sCmdEditConf), $process_killed)
	LaunchConsole($Cmd, AddSpace($sCmdEditName), $process_killed)
	
EndFunc   ;==>SetScreenLDPlayer9

Func ConfigLDPlayer9WindowManager()
	If Not $g_bRunState Then Return
	Local $cmdOutput

	; Reset Window Manager size
	$cmdOutput = AndroidAdbSendShellCommand("wm size reset", Default, Default, False)

	; Set expected dpi
	$cmdOutput = AndroidAdbSendShellCommand("wm density 160", Default, Default, False)

	; Set font size to normal
	AndroidSetFontSizeNormal()
EndFunc   ;==>ConfigLDPlayer9WindowManager

Func RebootLDPlayer9SetScreen($bOpenAndroid = True)
	If Not InitAndroid() Then Return False

	ConfigLDPlayer9WindowManager()

	; Close Android
	CloseAndroid("RebootLDPlayer9SetScreen")
	If _Sleep(1000) Then Return False

	SetScreenAndroid()
	If Not $g_bRunState Then Return False

	If $bOpenAndroid Then
		; Start Android
		OpenAndroid(True)
	EndIf

	Return True

EndFunc   ;==>RebootLDPlayer9SetScreen

Func GetLDPlayer9RunningInstance()
	WinGetAndroidHandle()
	Local $a[2] = [$g_hAndroidWindow, ""]
	If $g_hAndroidWindow <> 0 Then Return $a
	
	Local $WinTitleMatchMode = Opt("WinTitleMatchMode", -3)
	Local $h = WinGetHandle($g_sAndroidTitle, "")
	If @error = 0 Then
		$a[0] = $h
	EndIf
	Opt("WinTitleMatchMode", $WinTitleMatchMode)
	Return $a
EndFunc   ;==>LDPlayer9RunningInstance

Func GetLDPlayer9SvcPid()
	; find process PID
	Local $PID = ProcessExists2("Ld9BoxSvc.exe")
	Return $PID
EndFunc   ;==>GetLDPlayer9SvcPid

Func CloseLDPlayer9()
	If Not InitAndroid() Then Return
	Local $iInstance = StringReplace($g_sAndroidInstance, "leidian", "")
	Local $sFile = "dnplayer.exe"
	Local $bError = False
	Local $PID

	$PID = ProcessExists2($g_sAndroidProgramPath, GetLDPlayer9ProgramParameter())
	If $PID Then
		ShellExecute(@WindowsDir & "\System32\taskkill.exe", " -f -t -pid " & $PID, "", Default, @SW_HIDE)
		If _Sleep(1000) Then Return ; Give OS time to work
	EndIf
		
	$PID = ProcessExists2($sFile, $g_sAndroidInstance)
	If $PID Then
		SetLog($g_sAndroidEmulator & " failed to kill " & $sFile, $COLOR_ERROR)
	EndIf
	If _Sleep(2000) Then Return ; wait a bit
EndFunc   ;==>CloseLDPlayer9

Func CloseUnsupportedLDPlayer9()
	Local $WinTitleMatchMode = Opt("WinTitleMatchMode", -3)
	
	If IsArray(ControlGetPos($g_sAndroidTitle, "", "")) Then ; $g_avAndroidAppConfig[1][4]
		Opt("WinTitleMatchMode", $WinTitleMatchMode)
		SetLog("Please let MyBot start " & $g_sAndroidEmulator & " automatically", $COLOR_INFO)
		RebootLDPlayer9SetScreen(False)
		Return True
	EndIf
	Opt("WinTitleMatchMode", $WinTitleMatchMode)
	Return False
EndFunc 

Func LDPlayer9BotStartEvent()
	Return AndroidCloseSystemBar()
EndFunc  

Func LDPlayer9BotStopEvent()
	Return AndroidOpenSystemBar()
EndFunc  
