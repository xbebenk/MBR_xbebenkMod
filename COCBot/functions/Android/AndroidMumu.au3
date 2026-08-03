; #FUNCTION# ====================================================================================================================
; Name ..........: OpenMumu
; Description ...:
; Syntax ........: OpenMumu([$bRestart = False])
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
Global $__Mumu_Device_Path = "", $__Mumu_Path = ""
Global $__Mumu_Manage_Path = "", $__Mumu_ConfigDir = ""
Global $__MuMu_Version = 0

Func GetMumuProgramParameter($bAlternative = False)
	;If $bAlternative Then Return AddSpace("index=") & StringReplace($g_sAndroidInstance, "MuMuPlayerGlobal-12.0-", "")
	Return AddSpace("-v " & StringReplace($g_sAndroidInstance, "MuMuPlayerGlobal-12.0-", ""))
EndFunc   ;==>MumuProgramParameter


Func OpenMumu($bRestart = False)
	SetLog("Starting Mumu", $COLOR_SUCCESS)
	If Not InitAndroid() Then Return False
	Return _OpenMumu($bRestart)
EndFunc   ;==>OpenMumuX

Func _OpenMumu($bRestart = False)
	Local $hTimer, $iCount = 0
	Local $ErrorResult, $connected_to, $process_killed
	Local $Cmd = $__Mumu_Manage_Path & "MuMuManager.exe"
	Local $iInstance = StringReplace($g_sAndroidInstance, "MuMuPlayerGlobal-12.0-", "")
	Local $sCmdParam = " control launch --vmindex " & $iInstance
	
	; always start ADB first to avoid ADB connection problems
	LaunchConsole($g_sAndroidAdbPath, AddSpace($g_sAndroidAdbGlobalOptions) & "start-server", $process_killed)

	If WinGetAndroidHandle() = 0 Then 
		LaunchConsole($Cmd, AddSpace($sCmdParam), $process_killed)
		If _SleepStatus(5000) Then Return
	Else
		SetLog("Mumu Already Loaded")
		Return True
	EndIf
	
	$hTimer = __TimerInit() ; start a timer for tracking BS start up time
	While $g_hAndroidControl = 0
		_StatusUpdateTime($hTimer, $g_sAndroidEmulator & " Starting")
		If __TimerDiff($hTimer) > $g_iAndroidLaunchWaitSec * 1000 Then ; if no BS position returned in 4 minutes, BS/PC has major issue so exit
			SetLog("Serious error has occurred, please restart PC and try again", $COLOR_ERROR)
			SetLog("Mumu refuses to load, waited " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_ERROR)
			SetLog("Unable to continue........", $COLOR_WARNING)
			btnstop()
			SetError(1, 1, -1)
			Return False
		EndIf
		If _Sleep(3000) Then Return
		WinGetAndroidHandle()
	WEnd

	If $g_hAndroidControl Then
		$connected_to = ConnectAndroidAdb(False, 3000) ; small time-out as ADB connection must be available now
		If WaitForAndroidBootCompleted($g_iAndroidLaunchWaitSec - __TimerDiff($hTimer) / 1000, $hTimer) Then Return
		If Not $g_bRunState Then Return
		SetLog("Mumu Loaded, took " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds to begin.", $COLOR_SUCCESS)
		Return True
	EndIf
	Return False
EndFunc   ;==>_OpenMumu

Func GetMumuAdbPath()
	Local $adbPath = @ScriptDir & "\lib\adb\adb.exe"
	Local $sMumuAdbPath = $__Mumu_Device_Path & "adb.exe"
	If FileExists($sMumuAdbPath) Then 
		SetDebugLog("$sMumuAdbPath: " & $sMumuAdbPath)
		Return $sMumuAdbPath
	EndIf
	Return $adbPath
EndFunc   ;==>GetMumuXAdbPath

Func InitMumuX($bCheckOnly = False)
	;Mumu doesn't have registry tree for engine, only installation dir info available on registry
	$__Mumu_Version = RegRead($g_sHKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MuMuPlayerGlobal\", "DisplayVersion")
	$__Mumu_Path = StringReplace(StringReplace(RegRead($g_sHKLM & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MuMuPlayerGlobal\", "UninstallString"), "uninstall.exe", ""), '"', '')
	$__Mumu_Device_Path = $__Mumu_Path & "nx_device\12.0\shell\"
	$__Mumu_Manage_Path = $__Mumu_Path & "nx_main\"
	
	Local $bFileFound = False
	Local $frontend_exe = "MuMuNxDevice.exe"
	SetDebugLog("$__Mumu_Device_Path : " & $__Mumu_Device_Path & $frontend_exe)
	$bFileFound = FileExists($__Mumu_Device_Path & $frontend_exe)
	
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
		$g_sAndroidPath = $__Mumu_Path
		$g_sAndroidProgramPath = $__Mumu_Device_Path & $frontend_exe
		$g_sAndroidAdbPath = $sPreferredADB
		$g_sAndroidVersion = $__Mumu_Version
		ConfigureSharedFolderMumu()
		WinGetAndroidHandle()
	EndIf
	
	Return True
EndFunc   ;==>InitMumu

Func ConfigureSharedFolderMumu($iMode = 0, $bSetLog = Default)
	If $bSetLog = Default Then $bSetLog = True
	Local $bResult = False
	
	Local $iInstance = StringReplace($g_sAndroidInstance, "MuMuPlayerGlobal-12.0-", "")
	Local $__Mumu_ConfigDir = $__Mumu_Path & "vms\MuMuPlayerGlobal-12.0-" & $iInstance
	Local $__Mumu_InstanceConf = FileReadToArray($__Mumu_ConfigDir & "\MuMuPlayerGlobal-12.0-" & $iInstance & ".nemu")
	Local $iLineCount = @extended
	
	For $i = 0 To $iLineCount - 1
		If StringInStr($__Mumu_InstanceConf[$i], "MuMuShared") Then
			Local $aPath = StringRegExp($__Mumu_InstanceConf[$i], 'hostPath="([^"]+)"', $STR_REGEXPARRAYMATCH)
			local $path = $aPath[0] & "\Pictures\"
			$g_sAndroidPicturesHostPath = $path
			$bResult = True
			$g_bAndroidSharedFolderAvailable = True
			$g_sAndroidPicturesPath = "/data/media/0/Pictures/"
			SetDebugLog("$g_sAndroidPicturesHostPath = " & $g_sAndroidPicturesHostPath)
			SetDebugLog("$g_sAndroidPicturesPath = " & $g_sAndroidPicturesPath)
		EndIf
		If StringInStr($__Mumu_InstanceConf[$i], "ADB_PORT_EX") Then
			Local $aAdbDevice = StringRegExp($__Mumu_InstanceConf[$i], 'hostip="(?<ip>.*?)"\s+hostport="(?<port>\d+)"', $STR_REGEXPARRAYMATCH)
			Local $sAdbDevice = $aAdbDevice[0] & ":" & $aAdbDevice[1]
			SetDebugLog("$sAdbDevice : " & $sAdbDevice)
			$g_sAndroidAdbDevice = $sAdbDevice
		EndIf
	Next
	
	Return SetError(0, 0, $bResult)
EndFunc   ;==>ConfigureSharedFolderMumu

Func InitMumu($bCheckOnly = False)
	Local $bInstalled = InitMumuX($bCheckOnly)
	If Not $bInstalled Then
		SetLog("Mumu supported version not found", $COLOR_ERROR)
		SetError(1, @extended, False)
		Return False
	EndIf
	
	If $bInstalled And Not $bCheckOnly Then		
		$g_sAndroidAdbShellOptions = " /system/xbin/su root" 
		GetMumuBackgroundMode()
	EndIf

	Return $bInstalled
EndFunc   ;==>InitMumu

Func GetMumuBackgroundMode()
	$__Mumu_ConfigDir = $__Mumu_Path & "vms\" & $g_sAndroidInstance & "\configs"
	Local $__MumuConf = FileReadToArray($__Mumu_ConfigDir & "\shell_config.json")
	Local $iLineCount = @extended
	
	; check Mumu renderer mode
	Local $GLRenderMode = "dx"
	For $i = 0 To $iLineCount - 1
		If StringInStr($__MumuConf[$i], "platform") Then
			Local $aGLRenderMode = StringRegExp($__MumuConf[$i], '"platform":\s*"(.*?)"', $STR_REGEXPARRAYMATCH)
			$GLRenderMode = $aGLRenderMode[0]
			SetDebugLog("GLRenderMode = " & $GLRenderMode)
		EndIf
	Next
		
	Switch $GLRenderMode
		Case "dx", "vlcn", "dx11", "vk"
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
EndFunc   ;==>GetMumuBackgroundMode

Func CheckScreenMumu($bSetLog = True)
	$__Mumu_ConfigDir = $__Mumu_Path & "vms\" & $g_sAndroidInstance & "\configs"
	Local $__MumuConf = FileReadToArray($__Mumu_ConfigDir & "\shell_config.json")
	Local $iLineCount = @extended

	Local $aiSearch = ['"width": ', '"height": ', '"dpi": ']
	Local $aiMustBe = ['"width": "' & $g_iGAME_WIDTH, '"height": "' & $g_iGAME_HEIGHT, '"dpi": "' & 160]
	
	For $iSearch = 0 To UBound($aiSearch) - 1
		If $g_bDebugSetLog Then SetLog("Search for : " & $aiMustBe[$iSearch], $COLOR_DEBUG)
		For $i = 0 To $iLineCount - 1
			If StringInStr($__MumuConf[$i], $aiSearch[$iSearch]) Then
				If $g_bDebugSetLog Then SetLog("Found: " & $__MumuConf[$i], $COLOR_DEBUG2)
				If StringInStr($__MumuConf[$i], $aiMustBe[$iSearch]) = 0 Then
					If $g_bDebugSetLog Then SetLog("Not Match: " & $__MumuConf[$i] & " <> " & $aiMustBe[$iSearch], $COLOR_DEBUG1)
					If $bSetLog = True Then SetLog("Please wait, Bot will configure your Mumu", $COLOR_ERROR)
					Return False
				Else 
					If $g_bDebugSetLog Then SetLog("Match: " & $aiMustBe[$iSearch], $COLOR_DEBUG2)
				EndIf
			EndIf
		Next
	Next
	
	Return True
EndFunc   ;==>CheckScreenMumu

Func SetScreenMumu()
	Local $Cmd = $__Mumu_Manage_Path & "MuMuManager.exe", $process_killed
	
	Local $iInstance = StringReplace($g_sAndroidInstance, "MuMuPlayerGlobal-12.0-", "")
	Local $sCmdEditConf = "setting --vmindex " & $iInstance & " --key resolution_width.custom --value 860 --key resolution_height.custom --value 676 --key resolution_dpi.custom --value 160"
	Local $sCmdEditName = "rename --vmindex " & $iInstance & " --name MuMu-" & $iInstance
	
	;MuMuManager.exe setting --vmindex 1 --key resolution_width.custom --value 860 --key resolution_height.custom --value 676 --key resolution_dpi.custom --value 160
	;MuMuManager.exe rename --vmindex 1 --name MuMu-1
	LaunchConsole($Cmd, AddSpace($sCmdEditConf), $process_killed)
	LaunchConsole($Cmd, AddSpace($sCmdEditName), $process_killed)
	
EndFunc   ;==>SetScreenMumu

Func ConfigMumuWindowManager()
	If Not $g_bRunState Then Return
	Local $cmdOutput

	; Reset Window Manager size
	$cmdOutput = AndroidAdbSendShellCommand("wm size reset", Default, Default, False)

	; Set expected dpi
	$cmdOutput = AndroidAdbSendShellCommand("wm density 160", Default, Default, False)

	; Set font size to normal
	AndroidSetFontSizeNormal()
EndFunc   ;==>ConfigMumuWindowManager

Func RebootMumuSetScreen($bOpenAndroid = True)
	If Not InitAndroid() Then Return False

	ConfigMumuWindowManager()

	; Close Android
	CloseAndroid("RebootMumuSetScreen")
	If _Sleep(1000) Then Return False

	SetScreenAndroid()
	If Not $g_bRunState Then Return False

	If $bOpenAndroid Then
		; Start Android
		OpenAndroid(True)
	EndIf

	Return True

EndFunc   ;==>RebootMumuSetScreen

Func GetMumuRunningInstance()
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
EndFunc   ;==>MumuRunningInstance

Func GetMumuSvcPid()
	; find process PID
	Local $PID = ProcessExists2("MuMuVMMSVC.exe")
	Return $PID
EndFunc   ;==>GetMumuSvcPid

Func CloseMumu()
	If Not InitAndroid() Then Return
	Local $Cmd = $__Mumu_Manage_Path & "MuMuManager.exe", $process_killed
	
	Local $iInstance = StringReplace($g_sAndroidInstance, "MuMuPlayerGlobal-12.0-", "")
	Local $sCmdClose = "control shutdown --vmindex " & $iInstance
	
	;MuMuManager.exe control shutdown --vmindex 1
	LaunchConsole($Cmd, AddSpace($sCmdClose), $process_killed)
	
	Local $iInstance = StringReplace($g_sAndroidInstance, "MuMuPlayerGlobal-12.0-", "")
	Local $sFile = "MuMuNxDevice.exe"
	Local $bError = False
	Local $PID

	$PID = ProcessExists2($g_sAndroidProgramPath, GetMumuProgramParameter())
	If $PID Then
		ShellExecute(@WindowsDir & "\System32\taskkill.exe", " -f -t -pid " & $PID, "", Default, @SW_HIDE)
		If _Sleep(1000) Then Return ; Give OS time to work
	EndIf
		
	$PID = ProcessExists2($sFile, $g_sAndroidInstance)
	If $PID Then
		SetLog($g_sAndroidEmulator & " failed to kill " & $sFile, $COLOR_ERROR)
	EndIf
	If _Sleep(2000) Then Return ; wait a bit
EndFunc   ;==>CloseMumu

Func CloseUnsupportedMumu()
	Local $WinTitleMatchMode = Opt("WinTitleMatchMode", -3)
	
	If IsArray(ControlGetPos($g_sAndroidTitle, "", "")) Then ; $g_avAndroidAppConfig[1][4]
		Opt("WinTitleMatchMode", $WinTitleMatchMode)
		SetLog("Please let MyBot start " & $g_sAndroidEmulator & " automatically", $COLOR_INFO)
		RebootMumuSetScreen(False)
		Return True
	EndIf
	Opt("WinTitleMatchMode", $WinTitleMatchMode)
	Return False
EndFunc 

Func MumuBotStartEvent()
	Return AndroidCloseSystemBar()
EndFunc  

Func MumuBotStopEvent()
	Return AndroidOpenSystemBar()
EndFunc  

Func MumuAdjustClickCoordinates(ByRef $x, ByRef $y)
	Local $iTmpX = $y, $iTmpY = $x
	Local $iFinalX = $g_iGAME_HEIGHT - $iTmpX
	Local $iFinalY = $iTmpY
	
	$x = $iFinalX
	$y = $iFinalY
EndFunc   ;==>BlueStacksAdjustClickCoordinates