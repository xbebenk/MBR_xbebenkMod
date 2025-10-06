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

Func checkMainScreen($bSetLog = Default, $bBuilderBase = $g_bStayOnBuilderBase, $CalledFrom = "Default") ;Checks if in main screen
	If Not $g_bRunState Then Return
	FuncEnter(checkMainScreen)
	Return FuncReturn(_checkMainScreen($bSetLog, $bBuilderBase, $CalledFrom))
EndFunc   ;==>checkMainScreen

Func _checkMainScreen($bSetLog = Default, $bBuilderBase = $g_bStayOnBuilderBase, $CalledFrom = "Default") ;Checks if in main screen

	If $bSetLog = Default Then $bSetLog = True
	Local $VillageType = "MainVillage"
	If $bBuilderBase Then $VillageType = "BuilderBase"
	If $bSetLog Then SetLog("[" & $CalledFrom & "] Check " & $VillageType & " Main Screen", $COLOR_INFO)
	
	If Not CheckAndroidRunning(False) Then Return
	PlaceUnplacedBuilding()
	Local $i = 0, $iErrorCount = 0, $iLoading = 0, $iCheckBeforeRestartAndroidCount = 5, $bObstacleResult, $bContinue = False, $bLocated = False
	Local $aPixelToCheck = $aIsMain
	$bLocated = $bBuilderBase ? isOnBuilderBase() : isOnMainVillage()
	
	While Not $bLocated
		$i += 1
		If Not $g_bRunState Then Return
		
		If Mod($i, 10) = 0 Then RestartAndroidCoC() ; Force restart CoC we keep on restarting mainscreen
		
		SetDebugLog("checkMainScreen : " & ($bBuilderBase ? "BuilderBase" : "MainVillage"))
		$bLocated = $bBuilderBase ? isOnBuilderBase() : isOnMainVillage()
		If $bLocated Then ExitLoop
		
		If Not $bLocated And GetAndroidProcessPID() = 0 Then OpenCoC()
		
		;mainscreen not located, proceed to check if there is obstacle covering screen
		$bObstacleResult = checkObstacles($bBuilderBase)
		SetDebugLog("CheckObstacles[" & $i & "] Result = " & $bObstacleResult, $COLOR_DEBUG)
		
		$bContinue = False
		If Not $bObstacleResult And $i > 5 Then $bContinue = True ; 5 time no obstacle deteced but mainscreen not located, set continue true to proceed to waitMainScreen
		
		If $bObstacleResult Then ; obstacle found, set g_bRestart = true (go to mainloop)
			$g_bRestart = True
			$bContinue = True
		EndIf
		
		If $bContinue Then 
			If waitMainScreen() Then ExitLoop ; Due to differeneces in PC speed, let waitMainScreen test for CoC restart
		EndIf
		If Not $g_bRunState Then Return
		If _Sleep(1000) Then Return
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
	Local $bRet = False, $bBuilderInfo = False, $bChatTab = False
	If $g_iAndroidBackgroundMode = 2 Then $aPixelToCheck[0] += 1
	$bChatTab = checkChatTabPixel()
	$bBuilderInfo = _CheckPixel($aPixelToCheck, True, Default, "_checkMainScreen")
	
	$bRet = $bChatTab And $bBuilderInfo
	If $g_bDebugSetLog Then SetLog("PixelToCheck = " & $aPixelToCheck[0] & "," & $aPixelToCheck[1] & " exp:" & Hex($aPixelToCheck[2], 6) & ", tolerance:" & $aPixelToCheck[3] , $COLOR_ACTION)
	If $g_bDebugSetLog Then SetLog("PixelCheck result : " & ($bRet ? "succeed" : "failed"), $COLOR_ACTION)
	
	If Not $bRet Then
		If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then
			SwitchToMainVillage()
		EndIf
	EndIf
	
	Return $bRet
EndFunc

Func checkChatTabPixel()
	Local $bRet = False
	
	If _ColorCheck(_GetPixelColor(20, 300, True), Hex(0xF3AA28, 6), 20, Default, "checkChatTabPixel") Then
		If $g_bDebugSetLog Then SetLog("checkChatTabPixel: Found ChatTab", $COLOR_ACTION)
		$bRet = True
	EndIf
	
	If Not $bRet Then 
		If _CheckPixel($aChatTab, True) Then
			SetDebugLog("checkChatTabPixel: Found Chat Tab to close", $COLOR_ACTION)
			PureClickP($aChatTab, 1, 0, "#0136") ;Clicks chat tab
			If _Sleep(1000) Then Return
			$bRet = True
		Else
			SetDebugLog("ChatTabPixel not found", $COLOR_ERROR)
		EndIf
	EndIf
	
	Return $bRet
EndFunc   ;==>checkChatTabPixel

Func isOnMainVillage()
	Local $bRet = False
	$bRet = _checkMainScreenImage($aIsMain)
	Return $bRet
EndFunc

Func isOnBuilderBase()
	Local $bRet = False
	$bRet = _checkMainScreenImage($aIsOnBuilderBase)
	Return $bRet
EndFunc
