; #FUNCTION# ====================================================================================================================
; Name ..........: DailyChallenges()
; Description ...: Daily Challenges
; Author ........: TripleM (04/2019), Demen (07/2019)
; Modified ......:
; Remarks .......: This file is part of MyBot Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: DailyChallenges()
; ===============================================================================================================================
#include-once

Func DailyChallenges()
	If Not $g_bChkCollectRewards Then Return
	If Not $g_bRunState Then Return
	SetLog("Checking DailyChallenges", $COLOR_ACTION)
	If Not _PixelSearch(170, 622, 171, 623, Hex(0xE31528, 6), 10, True, "DailyChallenges") Then
		SetLog("DailyChallenges : No Red Bonus counter!", $COLOR_DEBUG2)
		Return
	EndIf
	
	If Not $g_bChkCollectRewards Then Return
	Local $bGoldPass = _CheckPixel($aPersonalChallengeOpenButton2, $g_bCapturePixel) ; golden badge button at mainscreen
	Local $bRedSignal = _CheckPixel($aPersonalChallengeOpenButton3, $g_bCapturePixel)

	If OpenPersonalChallenges() Then
		CollectDailyRewards($bGoldPass)
		ClosePersonalChallenges()
	EndIf
EndFunc   ;==>DailyChallenges

Func OpenPersonalChallenges()
	SetLog("Opening personal challenges", $COLOR_INFO)
	If _CheckPixel($aPersonalChallengeOpenButton1, $g_bCapturePixel) Then
		ClickP($aPersonalChallengeOpenButton1, 1, 0, "#0666")
	ElseIf _CheckPixel($aPersonalChallengeOpenButton2, $g_bCapturePixel) Then
		ClickP($aPersonalChallengeOpenButton2, 1, 0, "#0666")
	Else
		SetLog("Can't find button", $COLOR_ERROR)
		Return False
	EndIf
	
	Return True
EndFunc   ;==>OpenPersonalChallenges

Func CollectDailyRewards($bGoldPass = False)
	If _Sleep(1000) Then Return
	If Not $g_bChkCollectRewards Or Not _CheckPixel($aPersonalChallengeRewardsAvail, $g_bCapturePixel) Then Return ; no red badge on rewards tab

	SetLog("Collecting Daily Rewards...")

	ClickP($aPersonalChallengeRewardsTab, 1, 0, "Rewards tab") ; Click Rewards tab
	If _Sleep(2000) Then Return

	Local $iClaim = 0
	Local $x1 = 10, $y1 = 530, $x2 = 840, $y2 = 585
	If $bGoldPass Then $y1 = 190
	
	If _CheckPixel($aPersonalChallengeRewardsCheckMark, True) Then
		Click($aPersonalChallengeRewardsCheckMark[0], $aPersonalChallengeRewardsCheckMark[1])
		If _Sleep(1000) Then Return
	EndIf
	
	Local $tmpxClaim = 0
	For $i = 1 To 10		
		Local $aClaim = QuickMIS("CNX", $g_sImgDailyReward, $x1, $y1, $x2, $y2)
		If IsArray($aClaim) And UBound($aClaim) > 0 Then
			_ArraySort($aClaim, 0, 0, 0, 1) ;sort x coord ascending
			For $j = 0 To UBound($aClaim) - 1
				If Not $g_bRunState Then Return
				If Abs($tmpxClaim - $aClaim[$j][1]) < 10 Then ContinueLoop ;same Claim button 
				Click($aClaim[$j][1], $aClaim[$j][2])
				If _Sleep(1000) Then Return
				If IsOKCancelPage() Then 
					If $g_bChkSellRewards Then
						Setlog("Selling extra reward for gems", $COLOR_SUCCESS)
						Click($aConfirmSurrender[0], $aConfirmSurrender[1]) ; Click the Okay
						$iClaim += 1
					Else
						SetLog("Cancel. Not selling extra rewards.", $COLOR_SUCCESS)
						Click($aConfirmSurrender[0] - 200, $aConfirmSurrender[1]) ; Click Cancel
					Endif
					If _Sleep(1000) Then ExitLoop
				Else
					$iClaim += 1
					If _Sleep(100) Then ExitLoop
				EndIf
				$tmpxClaim = $aClaim[$j][1]
			Next
		EndIf
		If WaitforPixel(799, 396, 801, 397, "FDC04F", 10, 1, "TrophyColor") Then ExitLoop ;thropy color
		If WaitforPixel(799, 396, 801, 397, "4BCD1C", 10, 1) Then ClickDrag(750, 445, 100, 445, 1000)
	Next
	
	SetLog($iClaim > 0 ? "Claimed " & $iClaim & " reward(s)!" : "Nothing to claim!", $COLOR_SUCCESS)
	If _Sleep(500) Then Return

EndFunc   ;==>CollectDailyRewards

Func ClosePersonalChallenges()
	If $g_bDebugSetlog Then SetLog("Closing personal challenges", $COLOR_INFO)

	If IsChallengeWindowOpen() Then
		Click(824, 85) ;close window
		Return True
	EndIf
	Return False
EndFunc   ;==>ClosePersonalChallenges
