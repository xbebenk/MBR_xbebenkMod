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
	Local $iCount
	SetLog("Waiting for Main Screen")
	$iCount = 1
	For $i = 0 To 10 ;11*2000 = 22 seconds (for blackscreen) and plus loading screen
		If Not $g_bRunState Then Return
		SetDebugLog("waitMainScreen ChkObstl Loop = " & $i & ", ExitLoop = " & $iCount, $COLOR_DEBUG) ; Debug stuck loop
		$iCount += 1
		Local $hWin = $g_hAndroidWindow
		If TestCapture() = False Then
			If WinGetAndroidHandle() = 0 Then
				If $hWin = 0 Then
					OpenAndroid(True)
				Else
					RebootAndroid()
				EndIf
				Return
			EndIf
			getBSPos() ; Update $g_hAndroidWindow and Android Window Positions
		EndIf
		_CaptureRegions() ;force capture screen
		If checkChatTabPixel() Then 
			SetLog("waitMainScreen: MainScreen Located", $COLOR_SUCCESS)
			Return
		EndIf
		
		Local $sLoading = getOcrAndCapture("coc-Loading", 385, 580, 90, 25)
		If $sLoading = "Loading" Then 
			SetLog("Still on Loading Screen...", $COLOR_INFO)
			_Sleep(5000)
		EndIf
		
		Local $sUpdateAvail = getOcrAndCapture("coc-UpdateAvail", 320, 235, 220, 30)
		If $sUpdateAvail = "Update Available" Then 
			SetLog("Chief, we have minor coc Update!", $COLOR_INFO)
			ClickAway()
			_Sleep(1000)
			Return
		EndIf
		
		If Not checkObstacles() And $i = 10 Then ExitLoop ;something wrong with coc screen exit this loop and try to restart coc
	Next

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SetLog("Wait MainScreen Timout", $COLOR_ERROR)
	SetLog("=========RESTART COC==========", $COLOR_INFO)
	SaveDebugImage("WaitMainScreenTimout", True)
	CloseCoC(True) ;only close coc
	;_RestartAndroidCoC(False, False, True, 0, 0, True) ;start coc, not updating shared_prefs
	;_SleepStatus(10000) ;give time for coc loading
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
