; #FUNCTION# ====================================================================================================================
; Name ..........: WaitForClouds
; Description ...: Wait loop that checks for clouds to clear screen when searching for base to attack
;					  : Includes ability to extend search time beyond normal 5 minute idle time with randomization of max wait time base on trophy level
; Syntax ........: WaitForClouds()
; Parameters ....:
; Return values .: None
; Author ........: MonkeyHunter (08-2016)
; Modified ......: MonkeyHunter (05-2017) MMHK (07-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func WaitForClouds()
	SetDebugLog("Begin WaitForClouds", $COLOR_DEBUG1)
	$g_bCloudsActive = True
	
	Local $iCount = 0
	Local $bigCount = 0, $iLastTime = 0
	Local $hMinuteTimer, $iSearchTime

	Local $hMinuteTimer = __TimerInit() ; initialize timer for tracking search time
	
	While Not _CheckPixel($aIsAttackPage, True) ; loop to wait for clouds to disappear
		If Not $g_bRunState Then Return
		
		$iCount += 1
		If IsProblemAffect() Then ; check for reload error messages -> restart exitLoop, reset search
			resetAttackSearch()
			ExitLoop
		EndIf
		
		If checkObstacles_Network(False, False) Then ;network error -> restart CoC
			$g_bIsClientSyncError = True
			$g_bRestart = True
			CloseCoC(True)
			ExitLoop
		EndIf
		
		If QuickMIS("BC1", $g_sImgNextButton, 720, 510, 750, 535) Then 
			SetDebugLog("Found Next Button, exitLoop")
			ExitLoop
		EndIf
		
		_GUICtrlStatusBar_SetTextEx($g_hStatusBar, " Status: Loop to clean screen without Clouds, # " & $iCount)
		
		$iSearchTime = __TimerDiff($hMinuteTimer) / 60000 ;get time since minute timer start in minutes
		If $iSearchTime >= $iLastTime + 1 Then
			SetLog("Cloud wait time " & StringFormat("%.1f", $iSearchTime) & " minute(s)", $COLOR_INFO)
			$iLastTime += 1
			If $iSearchTime > 2 Then ;xbebenk prevent bot too long on cloud
				$g_bIsClientSyncError = True
				$g_bRestart = True
				CloseCoC(True)
				ExitLoop
			EndIf
			
			; Check if CoC app restarted without notice (where android restarted app automatically with same PID), and returned to main base
			If _CheckPixel($aIsMain, $g_bCapturePixel) Then
				SetLog("Strange error detected! 'WaitforClouds' returned to main base unexpectedly, OOS restart initiated", $COLOR_ERROR)
				$g_bRestart = True ; Set flag for OOS restart condition
				resetAttackSearch()
				ExitLoop
			EndIf
		EndIf
		If _Sleep(500) Then Return
	WEnd
	If _Sleep(1000) Then Return
	SetDebugLog("End WaitForClouds", $COLOR_DEBUG1)
EndFunc   ;==>WaitForClouds
