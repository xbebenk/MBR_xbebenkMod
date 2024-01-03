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
	Local $VillageType = "MainVillage"
	If $bBuilderBase = Default Then $bBuilderBase = isOnBuilderBase()
	If $bBuilderBase Then $VillageType = "BuilderBase"
	If $bSetLog Then
		SetLog("[" & $CalledFrom & "] Check " & $VillageType & " Main Screen", $COLOR_INFO)
	EndIf
	
	If Not CheckAndroidRunning(False) Then Return
	
	Local $i = 0, $iErrorCount = 0, $iLoading = 0, $iCheckBeforeRestartAndroidCount = 5, $bObstacleResult, $bContinue = False, $bLocated = False
	Local $aPixelToCheck = $aIsMain
	If $bBuilderBase Then $aPixelToCheck = $aIsOnBuilderBase
	While Not $bLocated
		$i += 1
		If Not $g_bRunState Then Return
		
		If Mod($i, 10) = 0 Then RestartAndroidCoC() ; Force restart CoC we keep on restarting mainscreen
		
		SetDebugLog("checkMainScreen : " & ($bBuilderBase ? "BuilderBase" : "MainVillage"))
		$bLocated = _checkMainScreenImage($aPixelToCheck)
		If $bLocated Then ExitLoop
		
		If Not $bLocated And GetAndroidProcessPID() = 0 Then OpenCoC()
		If $g_sAndroidEmulator = "Bluestacks5" Then NotifBarDropDownBS5()
		
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
	$bChatTab = checkChatTabPixel()
	$bBuilderInfo = _CheckPixel($aPixelToCheck, True, Default, "_checkMainScreenImage(1)")
	
	$bRet = $bChatTab And $bBuilderInfo
	If Not $bRet And $bChatTab And $g_bStayOnBuilderBase Then
		$aPixelToCheck[0] -= 10
		$bBuilderInfo = _CheckPixel($aPixelToCheck, True, Default, "_checkMainScreenImage(2)")
		If $bBuilderInfo Then $bRet = True
	EndIf
	
	If Not $bRet Then
		If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then
			SwitchToMainVillage()
		EndIf
	EndIf
	
	Return $bRet
EndFunc

Func checkChatTabPixel()
	Local $bRet = False
	
	If _ColorCheck(_GetPixelColor(12, 342, True), Hex(0xC55115, 6), 20, Default, "checkChatTabPixel") Then
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
	Local $aPixelToCheck = $aIsMain
	
	$bRet = _checkMainScreenImage($aPixelToCheck)
	If Not $bRet Then
		SetDebugLog("Using Image to Check if isOnMainVillage")
		If QuickMIS("BC1", $g_sImgInfo, 369, 3, 392, 15) Then $bRet = True
	EndIf
	Return $bRet
EndFunc

Func isOnBuilderBase()
	Local $bRet = False
	Local $aPixelToCheck = $aIsOnBuilderBase
	
	$bRet = _checkMainScreenImage($aPixelToCheck)
	
	If Not $bRet Then ;check again, after attack builder icon shifted left :((
		$bRet = _checkMainScreenImage($aIsOnBuilderBase1)
	EndIf
	
	If Not $bRet Then
		SetDebugLog("Using Image to Check if isOnBuilderBase")
		If QuickMIS("BC1", $g_sImgInfo, 435, 1, 462, 22) Then $bRet = True
	EndIf
	
	Return $bRet
EndFunc

Func NotifBarDropDownBS5()
	If $g_sAndroidEmulator = "Bluestacks5" Then
		If _CheckPixel($aNotifBarBS5_a, True) And _CheckPixel($aNotifBarBS5_b, True) And _CheckPixel($aNotifBarBS5_c, True) Then
			SetLog("Found NotifBar Dropdown, Closing!", $COLOR_INFO)
			Click(777, 34)
			Return
		EndIf
	EndIf
EndFunc
