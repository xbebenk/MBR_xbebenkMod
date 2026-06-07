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
	Local $iCount = 15, $sLoading = "", $iMaxLoading = 5
	SetLog("Waiting for Main Screen")
	Local $bCheckObs = False, $iCoCPid = 0, $iTmpCoCPid = 0
	Local $bLocated = False
	
	If _Sleep(50) Then Return
	For $i = 1 To $iCount ;30*1000 = 60 seconds (for blackscreen) and plus loading screen
		If Not $g_bRunState Then Return
		If Not WinGetAndroidHandle() Then OpenAndroid(True)
		$iCoCPid = GetAndroidProcessPID() 
		SetDebugLog("Found coc pid : " & $iCoCPid)
		If $iCoCPid = 0 Then OpenCoC()
		$bLocated = checkChatTabPixel()
		If $bLocated Then 
			$g_iMainScreenTimeoutCount = 0
			SetLog("waitMainScreen: MainScreen Located", $COLOR_SUCCESS)
			Return True
		EndIf
		
		If _Sleep(50) Then Return
		
		$bCheckObs = checkObstacles()
		SetLog("[" & $i & "/" & $iCount & "] waitMainScreen CheckObs = " & String($bCheckObs), $COLOR_DEBUG1) ; Debug stuck loop
		If $bLocated And Not $bCheckObs Then Return True
		
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
	
	SetLog("Wait MainScreen Timeout [" & $g_iMainScreenTimeoutCount & "]", $COLOR_DEBUG2)
	SetLog("=========RESTART COC==========", $COLOR_INFO)
	SaveDebugImage("WaitMainScreenTimeout", True) 
	$g_iMainScreenTimeoutCount += 1
	If $g_iMainScreenTimeoutCount > 1 Then 
		SetLog("WaitMainScreen Timeout, restart android", $COLOR_DEBUG2)
		RebootAndroid()
	EndIf
	
	$iTmpCoCPid = $iCoCPid
	CloseCoC(True) ;only close coc
	$iCoCPid = GetAndroidProcessPID()
	If $iTmpCoCPid = $iCoCPid Then 
		SetLog("Coc restart failed", $COLOR_DEBUG2)
		SetLog("Android is not reponding, also restart android", $COLOR_DEBUG2)
		RebootAndroid()
	EndIf
EndFunc   ;==>waitMainScreen

