; #FUNCTION# ====================================================================================================================
; Name ..........: OpenBlueStacks5
; Description ...:
; Syntax ........: OpenBlueStacks5([$bRestart = False])
; Parameters ....: $bRestart            - [optional] a boolean value. Default is False.
; Return values .: None
; Author ........: xbebenk (2020)
; Modified ......: 
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func GetBlueStacks5ProgramParameter($bAlternative = False)
	Return DoubleQuote("--instance") & " " & DoubleQuote($g_sAndroidInstance)
EndFunc   ;==>GetBlueStacks2ProgramParameter


Func OpenBlueStacks5($bRestart = False)
	SetLog("Starting BlueStacks5", $COLOR_SUCCESS)
	If Not InitAndroid() Then Return False
	; open newer BlueStacks versions 5
	Return _OpenBlueStacks5($bRestart)
EndFunc   ;==>OpenBlueStacksX

Func _OpenBlueStacks5($bRestart = False)
	Local $hTimer, $iCount = 0, $cmdPar
	Local $PID, $ErrorResult, $connected_to, $process_killed

	; always start ADB first to avoid ADB connection problems
	LaunchConsole($g_sAndroidAdbPath, AddSpace($g_sAndroidAdbGlobalOptions) & "start-server", $process_killed)

	$cmdPar = GetAndroidProgramParameter()
	If WinGetAndroidHandle() = 0 Then 
		$PID = LaunchAndroid($g_sAndroidProgramPath, $cmdPar, $g_sAndroidPath)
		;LaunchAndroid($g_sAndroidProgramPath, GetAndroidProgramParameter(), $g_sAndroidPath)
	Else
		SetLog("BlueStacks5 Already Loaded")
		Return True
	EndIf
	
	
	$hTimer = __TimerInit() ; start a timer for tracking BS start up time
	While $g_hAndroidControl = 0
		_StatusUpdateTime($hTimer, $g_sAndroidEmulator & " Starting")
		If __TimerDiff($hTimer) > $g_iAndroidLaunchWaitSec * 1000 Then ; if no BS position returned in 4 minutes, BS/PC has major issue so exit
			SetLog("Serious error has occurred, please restart PC and try again", $COLOR_ERROR)
			SetLog("BlueStacks refuses to load, waited " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_ERROR)
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
		SetLog("BlueStacks Loaded, took " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds to begin.", $COLOR_SUCCESS)
		Return True
	EndIf
	Return False
EndFunc   ;==>_OpenBlueStacks

Func GetBlueStacks5AdbPath()
	Local $adbPath = $__BlueStacks_Path & "HD-Adb.exe"
	If FileExists($adbPath) Then Return $adbPath
	Return ""
EndFunc   ;==>GetBlueStacksXAdbPath

Func InitBlueStacks5X($bCheckOnly = False, $bAdjustResolution = False, $bLegacyMode = False)
	;Bluestacks5 doesn't have registry tree for engine, only installation dir info available on registry
	$__BlueStacks5_Version = RegRead($g_sHKLM & "\SOFTWARE\BlueStacks_nxt\", "Version")
	$__BlueStacks_Path = RegRead($g_sHKLM & "\SOFTWARE\BlueStacks_nxt\", "InstallDir")
	$__BlueStacks_Path = StringReplace($__BlueStacks_Path, "\\", "\")
	
	Local $frontend_exe = ["HD-Frontend.exe", "HD-Player.exe"]
	Local $i, $aFiles = ["HD-Player.exe", "HD-Adb.exe"] ; first element can be $frontend_exe array!
	
	For $i = 0 To UBound($aFiles) - 1
		Local $File
		Local $bFileFound = False
		Local $aFiles2 = $aFiles[$i]
		If Not IsArray($aFiles2) Then Local $aFiles2 = [$aFiles[$i]]
		For $j = 0 To UBound($aFiles2) - 1
			$File = $__BlueStacks_Path & $aFiles2[$j]
			$bFileFound = FileExists($File)
			If $bFileFound Then
				; check if $frontend_exe is array, then convert
				If $i = 0 And IsArray($frontend_exe) Then $frontend_exe = $aFiles2[$j]
				ExitLoop
			EndIf
		Next
		If Not $bFileFound Then
			If Not $bCheckOnly Then
				SetLog("Serious error has occurred: Cannot find " & $g_sAndroidEmulator & ":", $COLOR_ERROR)
				SetLog($File, $COLOR_ERROR)
				SetError(1, @extended, False)
			EndIf
			Return False
		EndIf
	Next
	Local $sPreferredADB = FindPreferredAdbPath()
	
	If Not $bCheckOnly Then
		; update global variables
		$g_sAndroidPath = $__BlueStacks_Path
		$g_sAndroidProgramPath = $__BlueStacks_Path & $frontend_exe
		$g_sAndroidAdbPath = $sPreferredADB
		$g_sAndroidVersion = $__BlueStacks5_Version
		ConfigureSharedFolderBlueStacks5() ; something like D:\ProgramData\BlueStacks\Engine\UserData\SharedFolder\
		WinGetAndroidHandle()
	EndIf
	
	Return True
EndFunc   ;==>InitBlueStacks5

Func ConfigureSharedFolderBlueStacks5($iMode = 0, $bSetLog = Default)
	If $bSetLog = Default Then $bSetLog = True
	Local $bResult = False
	Local $__BlueStacks5_ProgramData = RegRead($g_sHKLM & "\SOFTWARE\BlueStacks_nxt\", "UserDefinedDir")
	Local $__BlueStacks5_InstanceConf = FileReadToArray($__BlueStacks5_ProgramData & "\Engine\" & $g_sAndroidInstance & "\" & $g_sAndroidInstance & ".bstk")
	Local $iLineCount = @extended
	
	;FileReadToArray(RegRead($g_sHKLM & "\SOFTWARE\BlueStacks_nxt\", "UserDefinedDir") & "\Engine\" & $g_sAndroidInstance & "\" & $g_sAndroidInstance & ".bstk")
	Switch $iMode
		Case 0 ; check that shared folder is configured in VM
			For $i = 0 To $iLineCount - 1
				If StringInStr($__BlueStacks5_InstanceConf[$i], "BstSharedFolder") Then 
					Local $aPath = StringRegExp($__BlueStacks5_InstanceConf[$i], "hostPath=(.+)writable", $STR_REGEXPARRAYMATCH)
					If IsArray($aPath) And Not @error Then 
						Local $path = StringStripWS((StringReplace($aPath[0], '"', '')), $STR_STRIPTRAILING)
						If StringRight($path, 1) <> "\" Then $path &= "\"
						$g_sAndroidPicturesHostPath = $path
						$bResult = True
						$g_bAndroidSharedFolderAvailable = True
						$g_sAndroidPicturesPath = "/mnt/windows/BstSharedFolder/"
						SetDebugLog("g_sAndroidPicturesHostPath = " & $g_sAndroidPicturesHostPath)
						SetDebugLog("g_sAndroidPicturesPath = " & $g_sAndroidPicturesPath)
					EndIf
				EndIf
			Next
			If Not $bResult Then ;set default value
				$g_sAndroidPicturesHostPath = "C:\ProgramData\BlueStacks_nxt\Engine\UserData\SharedFolder\"
				$g_sAndroidPicturesPath = "/mnt/windows/BstSharedFolder/"
				SetDebugLog("g_sAndroidPicturesHostPath = " & $g_sAndroidPicturesHostPath)
				SetDebugLog("g_sAndroidPicturesPath = " & $g_sAndroidPicturesPath)
				$bResult = True
			EndIf
		Case 1 ; create missing shared folder
		Case 2 ; Configure VM and add missing shared folder
			
	EndSwitch

	Return SetError(0, 0, $bResult)
EndFunc   ;==>ConfigureSharedFolderBlueStacks5

Func InitBlueStacks5($bCheckOnly = False)
	Local $bInstalled = InitBlueStacks5X($bCheckOnly, True)
	If $bInstalled And StringInStr($__BlueStacks5_Version, "5.") <> 1 Then
		SetLog("BlueStacks 5 supported version 5.x not found", $COLOR_ERROR)
		SetError(1, @extended, False)
		Return False
	EndIf
	
	Local $__BlueStacks5_ProgramData = RegRead($g_sHKLM & "\SOFTWARE\BlueStacks_nxt\", "UserDefinedDir")
	Local $__Bluestacks5Conf = FileReadToArray($__BlueStacks5_ProgramData & "\bluestacks.conf")
	Local $iLineCount = @extended
	
	For $i = 0 To $iLineCount - 1
		If StringInStr($__Bluestacks5Conf[$i], "bst.instance." & $g_sAndroidInstance & ".") Then 
			Local $propkey = StringReplace($__Bluestacks5Conf[$i], "bst.instance." & $g_sAndroidInstance & ".", "")
			SetDebugLog($propkey)
			Local $aProperty = StringSplit($propkey, "=", $STR_NOCOUNT)
			If IsArray($aProperty) And UBound($aProperty) = 2 Then 
				If StringInStr($aProperty[0], "adb_port") Then 
					Local $port = StringReplace($aProperty[1], '"', '')
					$g_sAndroidAdbDevice = "127.0.0.1:" & $port
				EndIf
			EndIf
		EndIf
	Next
	
	If $bInstalled And Not $bCheckOnly Then
		$__VBoxManage_Path = $__BlueStacks_Path & "BstkVMMgr.exe"
		Local $bsNow = GetVersionNormalized($__BlueStacks5_Version)
		If $bsNow > GetVersionNormalized("5.0") Then
			$g_sAndroidAdbShellOptions = " /data/anr/../../system/xbin/bstk/su root" 
			$g_iAndroidAdbMinitouchMode = 1
		EndIf
		GetBlueStacks5BackgroundMode()
	EndIf

	Return $bInstalled
EndFunc   ;==>InitBlueStacks2

Func GetBlueStacks5BackgroundMode()
	; check if BlueStacks 2 is running in OpenGL mode
	Local $__BlueStacks5_ProgramData = RegRead($g_sHKLM & "\SOFTWARE\BlueStacks_nxt\", "UserDefinedDir")
	Local $__Bluestacks5Conf = FileReadToArray($__BlueStacks5_ProgramData & "\bluestacks.conf")
	Local $iLineCount = @extended
	Local $GLRenderMode = "dx"
	For $i = 0 To $iLineCount - 1
		If StringInStr($__Bluestacks5Conf[$i], "bst.instance." & $g_sAndroidInstance & ".graphics_renderer") Then
			$GLRenderMode = StringRegExp($__Bluestacks5Conf[$i], '=\"(.+)\"', $STR_REGEXPARRAYMATCH)
			ExitLoop
		EndIf
	Next
	
	If IsArray($GLRenderMode) Then
		SetDebugLog("GLRenderMode = " & $GLRenderMode[0])
		Switch $GLRenderMode[0]
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
	EndIf
EndFunc   ;==>GetBlueStacksBackgroundMode

Func CheckScreenBlueStacks5($bSetLog = True)
	Local $__BlueStacks5_ProgramData = RegRead($g_sHKLM & "\SOFTWARE\BlueStacks_nxt\", "UserDefinedDir")
	Local $__Bluestacks5Conf = FileReadToArray($__BlueStacks5_ProgramData & "\bluestacks.conf")
	Local $iLineCount = @extended

	Local $aiSearch = ["bst.instance." & $g_sAndroidInstance & ".fb_width", _
					   "bst.instance." & $g_sAndroidInstance & ".fb_height", _
					   'bst.instance.' & $g_sAndroidInstance & '.dpi="160"', _
					   "bst.instance." & $g_sAndroidInstance & ".gl_win_height", _
					   "bst.instance." & $g_sAndroidInstance & ".display_name"]

	Local $aiMustBe = ['"860"', _
					   '"676"', _
					   '"160"', _
					   '"676"', _
					   '"BS5']

	For $i = 0 To $iLineCount - 1
		For $iSearch = 0 To UBound($aiSearch) - 1
			If StringInStr($__Bluestacks5Conf[$i], $aiSearch[$iSearch]) Then
				SetDebugLog($__Bluestacks5Conf[$i])
				If StringInStr($__Bluestacks5Conf[$i], $aiMustBe[$iSearch]) = 0 Then
					If $bSetLog = True Then SetLog("Please wait, Bot will configure your Bluestacks", $COLOR_ERROR)
					Return False
				EndIf
			EndIf
		Next
	Next
	Return True
EndFunc   ;==>CheckScreenBlueStacks

Func SetScreenBlueStacks5()
	Local $__BlueStacks5_ProgramData = RegRead($g_sHKLM & "\SOFTWARE\BlueStacks_nxt\", "UserDefinedDir")
	Local $__Bluestacks5Conf = FileReadToArray($__BlueStacks5_ProgramData & "\bluestacks.conf")
	Local $iLineCount = @extended

	Local $aiSearch = ["bst.instance." & $g_sAndroidInstance & ".fb_width", _
					   "bst.instance." & $g_sAndroidInstance & ".fb_height", _
					   "bst.instance." & $g_sAndroidInstance & ".dpi", _
					   "bst.instance." & $g_sAndroidInstance & ".gl_win_height", _
					   "bst.instance." & $g_sAndroidInstance & ".show_sidebar", _
					   "bst.instance." & $g_sAndroidInstance & ".display_name", _
					   "bst.instance." & $g_sAndroidInstance & ".enable_fps_display", _
					   "bst.instance." & $g_sAndroidInstance & ".google_login_popup_shown"]

	Local $aiMustBe = ['bst.instance.' & $g_sAndroidInstance & '.fb_width="860"', _
					   'bst.instance.' & $g_sAndroidInstance & '.fb_height="676"', _
					   'bst.instance.' & $g_sAndroidInstance & '.dpi="160"', _
					   'bst.instance.' & $g_sAndroidInstance & '.gl_win_height="676"', _
					   'bst.instance.' & $g_sAndroidInstance & '.show_sidebar="0"', _
					   'bst.instance.' & $g_sAndroidInstance & '.display_name="BS5-' & $g_sAndroidInstance & '"', _
					   'bst.instance.' & $g_sAndroidInstance & '.enable_fps_display="1"', _
					   "bst.instance." & $g_sAndroidInstance & '.google_login_popup_shown="0"']

	For $i = 0 To $iLineCount - 1
		For $iSearch = 0 To UBound($aiSearch) - 1
			If StringInStr($__Bluestacks5Conf[$i], $aiSearch[$iSearch]) Then
				$__Bluestacks5Conf[$i] = $aiMustBe[$iSearch]
			EndIf
		Next
	Next
;~ 	_ArrayDisplay($__Bluestacks5Conf)
	_FileWriteFromArray($__BlueStacks5_ProgramData & "\bluestacks.conf", $__Bluestacks5Conf)
EndFunc   ;==>SetScreenBlueStacks2

Func ConfigBlueStacks5WindowManager()
	If Not $g_bRunState Then Return
	Local $cmdOutput

	; Reset Window Manager size
	$cmdOutput = AndroidAdbSendShellCommand("wm size reset", Default, Default, False)

	; Set expected dpi
	$cmdOutput = AndroidAdbSendShellCommand("wm density 160", Default, Default, False)

	; Set font size to normal
	AndroidSetFontSizeNormal()
EndFunc   ;==>ConfigBlueStacks2WindowManager

Func RebootBlueStacks5SetScreen($bOpenAndroid = True)

	;RebootAndroidSetScreenDefault()

	If Not InitAndroid() Then Return False

	ConfigBlueStacks5WindowManager()

	; Close Android
	CloseAndroid("RebootBlueStacks5SetScreen")
	If _Sleep(1000) Then Return False

	SetScreenAndroid()
	If Not $g_bRunState Then Return False

	If $bOpenAndroid Then
		; Start Android
		OpenAndroid(True)
	EndIf

	Return True

EndFunc   ;==>RebootBlueStacks2SetScreen

Func GetBlueStacks5RunningInstance($bStrictCheck = True)
	WinGetAndroidHandle()
	Local $a[2] = [$g_hAndroidWindow, ""]
	If $g_hAndroidWindow <> 0 Then Return $a
	If $bStrictCheck Then Return False
	Local $WinTitleMatchMode = Opt("WinTitleMatchMode", -3) ; in recent 2.3.x can be also "BlueStacks App Player"
	Local $h = WinGetHandle("Bluestacks App Player", "") ; Need fixing as BS2 Emulator can have that title when configured in registry
	If @error = 0 Then
		$a[0] = $h
	EndIf
	Opt("WinTitleMatchMode", $WinTitleMatchMode)
	Return $a
EndFunc   ;==>GetBlueStacks2RunningInstance

Func GetBlueStacks5SvcPid()
	; find process PID
	Local $PID = ProcessExists2("HD-Service.exe")
	Return $PID
EndFunc   ;==>GetBlueStacksSvcPid

Func CloseBlueStacks5()
	If Not InitAndroid() Then Return

	If GetVersionNormalized($g_sAndroidVersion) > GetVersionNormalized("5.0") Then
		; BlueStacks 3 supports multiple instance
		Local $sFile = "HD-Player.exe"
		Local $bError = False
		Local $PID

		$PID = ProcessExists2($sFile, $g_sAndroidInstance)
		If $PID Then
			ShellExecute(@WindowsDir & "\System32\taskkill.exe", " -f -t -pid " & $PID, "", Default, @SW_HIDE)
			If _Sleep(1000) Then Return ; Give OS time to work
		EndIf
			
		$PID = ProcessExists2($sFile, $g_sAndroidInstance)
		If $PID Then
			SetLog($g_sAndroidEmulator & " failed to kill " & $sFile, $COLOR_ERROR)
		EndIf
	
		; also close vm
		CloseVboxAndroidSvc()
	EndIf

	If _Sleep(2000) Then Return ; wait a bit
EndFunc   ;==>CloseBlueStacks2

Func CloseUnsupportedBlueStacks5()
	Local $WinTitleMatchMode = Opt("WinTitleMatchMode", -3) ; in recent 2.3.x can be also "BlueStacks App Player"
	Local $sPartnerExePath = RegRead($g_sHKLM & "\SOFTWARE\BlueStacks_nxt\Config\", "PartnerExePath")
	If IsArray(ControlGetPos("Bluestacks App Player", "", "")) Or ($sPartnerExePath And ProcessExists2($sPartnerExePath)) Then ; $g_avAndroidAppConfig[1][4]
		Opt("WinTitleMatchMode", $WinTitleMatchMode)
		; Offical "Bluestacks App Player" v2.0 not supported because it changes the Android Screen!!!		
		SetLog("MyBot doesn't work with " & $g_sAndroidEmulator & " App Player", $COLOR_ERROR)
		SetLog("Please let MyBot start " & $g_sAndroidEmulator & " automatically", $COLOR_INFO)
		RebootBlueStacks5SetScreen(False)
		Return True
	EndIf
	Opt("WinTitleMatchMode", $WinTitleMatchMode)
	Return False
EndFunc 

Func BlueStacks5BotStartEvent()
	Return AndroidCloseSystemBar()
EndFunc  

Func BlueStacks5BotStopEvent()
	Return AndroidOpenSystemBar()
EndFunc  

Func BlueStacks5AdjustClickCoordinates(ByRef $x, ByRef $y)
	$x = Round(32767.0 / $g_iAndroidClientWidth * $x)
	$y = Round(32767.0 / $g_iAndroidClientHeight * $y)
EndFunc   ;==>BlueStacksAdjustClickCoordinates