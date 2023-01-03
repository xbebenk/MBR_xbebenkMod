; #FUNCTION# ====================================================================================================================
; Name ..........: checkMainScreen
; Description ...: Checks whether the pixel, located in the eyes of the builder in mainscreen, is available
;						If it is not available, it calls checkObstacles and also waitMainScreen.
; Syntax ........: checkMainScreen([$bSetLog = True], [$bBuilderBase = False])
; Parameters ....: $bCheck: [optional] Sets a Message in Bot Log. Default is True  - $bBuilderBase: [optional] Use CheckMainScreen for Builder Base instead of normal Village. Default is False
; Return values .: None
; Author ........:
; Modified ......: KnowJack (07-2015) , TheMaster1st(2015), Fliegerfaust (06-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: checkObstacles(), waitMainScreen()
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func checkMainScreen($bSetLog = Default, $bBuilderBase = Default, $CalledFrom = "Default") ;Checks if in main screen
	If Not $g_bRunState Then Return
	FuncEnter(checkMainScreen)
	Return FuncReturn(_checkMainScreen($bSetLog, $bBuilderBase, $CalledFrom))
EndFunc   ;==>checkMainScreen

Func _checkMainScreen($bSetLog = Default, $bBuilderBase = $g_bStayOnBuilderBase, $CalledFrom = "Default") ;Checks if in main screen

	If $bSetLog = Default Then $bSetLog = True
	If $bSetLog Then
		SetLog("[" & $CalledFrom & "] Locate Main Screen", $COLOR_INFO)
	EndIf
	
	If Not TestCapture() Then
		If CheckAndroidRunning(False) = False Then Return False
		getBSPos() ; Update $g_hAndroidWindow and Android Window Positions
		WinGetAndroidHandle()
		If Not $g_bChkBackgroundMode And $g_hAndroidWindow <> 0 Then
			; ensure android is top
			AndroidToFront(Default, "checkMainScreen")
		EndIf
		If $g_bAndroidAdbScreencap = False And _WinAPI_IsIconic($g_hAndroidWindow) Then WinSetState($g_hAndroidWindow, "", @SW_RESTORE)
	EndIf
	
	Local $i = 0, $iErrorCount = 0, $iCheckBeforeRestartAndroidCount = 5, $bObstacleResult, $bContinue, $bLocated
	Local $aPixelToCheck = $aIsMain
	If $bBuilderBase Then $aPixelToCheck = $aIsOnBuilderBase
	While True
		$i += 1
		SetDebugLog("checkMainScreen : " & ($bBuilderBase ? "BuilderBase" : "MainVillage"))
		$bLocated = _checkMainScreenImage($aPixelToCheck)
		If Not $bLocated And GetAndroidProcessPID() = 0 Then StartAndroidCoC()
		
		Local $sLoading = getOcrAndCapture("coc-Loading", 385, 580, 90, 25)
		If $sLoading = "Loading" Then 
			SetLog("Still on Loading Screen...", $COLOR_INFO)
			_Sleep(5000)
		EndIf
		
		$bObstacleResult = checkObstacles($bBuilderBase)
		SetDebugLog("CheckObstacles[" & $i & "] Result = " & $bObstacleResult, $COLOR_DEBUG)
		If $bLocated Then ExitLoop
		
		$bContinue = False
		If Not $bObstacleResult Then
			If $g_bMinorObstacle Then $g_bMinorObstacle = False
			If $i > 8 Then $bContinue = True
		Else
			$g_bRestart = True
			$bContinue = True
		EndIf
		If $i > 10 Then ;loop checking, restart coc
			CloseCoc(True)
		EndIf
		If $bContinue Then
			waitMainScreen() ; Due to differeneces in PC speed, let waitMainScreen test for CoC restart
			If Not $g_bRunState Then Return
			If @extended Then Return SetError(1, 1, False)
			If @error Then $iErrorCount += 1
			If $iErrorCount > 2 Then
				SetLog("Unable to fix the window error", $COLOR_ERROR)
				CloseCoC(True)
				ExitLoop
			EndIf
		Else
			If _Sleep($DELAYCHECKMAINSCREEN1) Then Return
		EndIf
	WEnd
	
	If Not $g_bRunState Then Return

	If $bSetLog Then
		If $bLocated Then
			SetLog("[" & $CalledFrom & "] Main Screen located", $COLOR_SUCCESS)
		Else
			SetLog("[" & $CalledFrom & "] Main Screen not located", $COLOR_ERROR)
		EndIf
	EndIf
	
	;After checkscreen dispose windows
	DisposeWindows()

	;Execute Notify Pending Actions
	NotifyPendingActions()

	Return $bLocated
EndFunc   ;==>_checkMainScreen

Func _checkMainScreenImage($aPixelToCheck)
	Local $bRet
	$bRet = _CheckPixel($aPixelToCheck, True, Default, "_checkMainScreenImage") And checkChatTabPixel()
	Return $bRet
EndFunc

Func checkChatTabPixel()
	If _CheckPixel($aChatTab, True) Then
		SetDebugLog("checkChatTabPixel: Found Chat Tab to close")
		PureClickP($aChatTab, 1, 0, "#0136") ;Click Close chat tab
		If _Sleep(2000) Then Return
	EndIf
	
	If WaitforPixel(18, 376, 20, 378, "C55115", 20, 1) Then 
		SetDebugLog("checkChatTabPixel: Found ChatTabPixel", $COLOR_SUCCESS)
		Return True
	Else
		SetDebugLog("ChatTabPixel not found", $COLOR_ERROR)
	EndIf
	Return False
EndFunc   ;==>checkChatTabPixel

Func isOnMainVillage()
	Local $aPixelToCheck = $aIsMain
	Local $bLocated = False
	$bLocated = _checkMainScreenImage($aPixelToCheck)
	Return $bLocated
EndFunc