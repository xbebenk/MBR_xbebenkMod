; #FUNCTION# ====================================================================================================================
; Name ..........: waitMainScreen
; Description ...: Waits 5 minutes for the pixel of mainscreen to be located, checks for obstacles every 2 seconds.  After five minutes, will try to restart bluestacks.
; Syntax ........: waitMainScreen()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......: KnowJack (08-2015), TheMaster1st (09-2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func waitMainScreen() ;Waits for main screen to popup
	If Not $g_bRunState Then Return
	Local $iCount = 30, $sLoading = "", $iMaxLoading = 5
	SetLog("Waiting for Main Screen")
	Local $bCheckObs = False
	
	For $i = 1 To $iCount ;30*1000 = 60 seconds (for blackscreen) and plus loading screen
		If Not $g_bRunState Then Return
		If Not WinGetAndroidHandle() Then OpenAndroid(True)
		If GetAndroidProcessPID() = 0 Then OpenCoC()
		
		If checkChatTabPixel() Then 
			$g_iMainScreenTimeoutCount = 0
			SetLog("waitMainScreen: MainScreen Located", $COLOR_SUCCESS)
			Return True
		EndIf
		
		$bCheckObs = checkObstacles()
		SetLog("[" & $i & "/" & $iCount & "] waitMainScreen CheckObs = " & String($bCheckObs), $COLOR_DEBUG1) ; Debug stuck loop
		
		$sLoading = getOcrAndCapture("coc-Loading", 385, 580, 90, 25)
		For $iLoading = 1 To $iMaxLoading
			If $sLoading = "Loading" Then
				SetLog("[" & $iLoading & "] Still on Loading Screen, Waiting", $COLOR_INFO)
				If _Sleep(2000) Then Return
			EndIf
			$sLoading = getOcrAndCapture("coc-Loading", 385, 580, 90, 25)
		Next
		If _Sleep(1000) Then Return
	Next
	
	SetLog("Wait MainScreen Timeout [" & $g_iMainScreenTimeoutCount & "]", $COLOR_ERROR)
	SetLog("=========RESTART COC==========", $COLOR_INFO)
	SaveDebugImage("WaitMainScreenTimeout", True) 
	$g_iMainScreenTimeoutCount += 1
	If $g_iMainScreenTimeoutCount > 2 Then CloseAndroid()
	If $g_sAndroidEmulator = "Bluestacks5" Then NotifBarDropDownBS5()
	CloseCoC(True) ;only close coc
	
EndFunc   ;==>waitMainScreen

Func waitMainScreenMini()
	If Not $g_bRunState Then Return
	Local $iCount = 0
	Local $hTimer = __TimerInit()
	SetDebugLog("waitMainScreenMini")
	If TestCapture() = False Then getBSPos() ; Update Android Window Positions
	SetLog("Waiting for Main Screen after " & $g_sAndroidEmulator & "/CoC restart", $COLOR_INFO)
	Local $aPixelToCheck = $g_bStayOnBuilderBase ? $aIsOnBuilderBase : $aIsMain
	For $i = 0 To 60 ;30*2000 = 1 Minutes
		If Not $g_bRunState Then Return
		If Not TestCapture() And WinGetAndroidHandle() = 0 Then ExitLoop ; sets @error to 1
		SetDebugLog("waitMainScreenMini ChkObstl Loop = " & $i & " ExitLoop = " & $iCount, $COLOR_DEBUG) ; Debug stuck loop
		$iCount += 1
		_CaptureRegion()
		If Not _CheckPixel($aPixelToCheck, $g_bNoCapturePixel) Then ;Checks for Main Screen
			If Not TestCapture() And _Sleep(1000) Then Return
			If CheckObstacles() Then $i = 0 ;See if there is anything in the way of mainscreen
		Else
			SetLog("CoC main window took " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_SUCCESS)
			Return
		EndIf
		_StatusUpdateTime($hTimer, "Main Screen")
		If ($i > 60) Or ($iCount > 80) Then ExitLoop ; If CheckObstacles forces reset, limit total time to 6 minute before Force restart BS
		If TestCapture() Then
			Return "Main screen not available"
		EndIf
	Next
	Return SetError(1, 0, -1)
EndFunc   ;==>waitMainScreenMini
