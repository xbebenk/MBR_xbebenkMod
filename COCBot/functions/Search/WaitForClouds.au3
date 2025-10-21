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
	
	Local $iLoop = 100
	Local $iLastTime = 0
	Local $hMinuteTimer, $iSearchTime

	Local $hMinuteTimer = __TimerInit() ; initialize timer for tracking search time
	If _Sleep(1000) Then Return ;lets wait a bit before checking
	
	For $i = 1 To $iLoop
		If Not $g_bRunState Then Return
		
		SetDebugLog("Wait for Clouds #" & $i, $COLOR_ACTION)
		
		If IsProblemAffect() Then ; check for reload error messages -> restart exitLoop, reset search
			resetAttackSearch()
			ExitLoop
		EndIf
		
		If IsAttackPage() Then 
			SetDebugLog("WaitForClouds : Found Attack Page", $COLOR_DEBUG1)
			ExitLoop
		EndIf
		
		If checkObstacles_Network(False, False) Then ;network error -> restart CoC
			$g_bIsClientSyncError = True
			$g_bRestart = True
			CloseCoC(True)
			ExitLoop
		EndIf
		
		_GUICtrlStatusBar_SetTextEx($g_hStatusBar, " Status: Loop to clean screen without Clouds, # " & $i)
		
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
		
		If QuickMIS("BC1", $g_sImgNextButton, 720, 510, 750, 535) Then 
			SetDebugLog("WaitForClouds : Found Next Button", $COLOR_DEBUG1)
			ExitLoop
		EndIf
		
		If _Sleep(250) Then Return
	Next
	SetDebugLog("End WaitForClouds", $COLOR_DEBUG1)
EndFunc   ;==>WaitForClouds
