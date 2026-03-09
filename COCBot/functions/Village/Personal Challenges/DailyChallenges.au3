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

Func DailyChallenges($bDebug = False)
	If Not $g_bChkCollectRewards Then Return
	If Not $g_bRunState Then Return
	SetLog("Checking DailyChallenges", $COLOR_INFO)
	Local $aIcnNormal[2] = [160, 635]
	Local $aIcnNew[2] = [160, 625]
	Local $aIcnCheck[2], $bIcnNew = False
	
	If $g_iTownHallLevel < 7 Then 
		$aIcnCheck = $aIcnNormal
	Else
		$aIcnCheck = $aIcnNew
		$bIcnNew = True
	Endif
	
	If Not $bDebug Then  
		If $bIcnNew Then
			SetLog("Searching New DailyChallenges", $COLOR_ACTION)
			If Not _ColorCheck(_GetPixelColor(185, 596, True), Hex(0x6E402B, 6), 10, Default, "Check Brown Pixel") _
				And Not _PixelSearch(196, 599, 196, 600, Hex(0xF71621, 6), 20, True, "Check Red Pixel") Then 
				SetLog("No New Bonus!", $COLOR_DEBUG2)
				Return
			EndIf
		Else
			SetLog("Searching Starter DailyChallenges", $COLOR_ACTION)
			If Not _PixelSearch(177, 615, 177, 616, Hex(0xE31528, 6), 20, True, "Check Red Pixel") Then 
				SetLog("No New Bonus!", $COLOR_DEBUG2)
				Return
			EndIf
		Endif
	EndIf
	
	If OpenPersonalChallenges($aIcnCheck, $bIcnNew) Then
		CollectDailyRewards($bIcnNew)
		ClosePersonalChallenges($bIcnNew)
	Else
		ClosePersonalChallenges($bIcnNew)
	EndIf
EndFunc   ;==>DailyChallenges

Func OpenPersonalChallenges($aIcnCheck, $bIcnNew)
	Local $bRet = False
	SetLog("Opening Personal challenges", $COLOR_INFO)
	Click($aIcnCheck[0], $aIcnCheck[1])
	If _Sleep(1000) Then Return
	
	If $bIcnNew Then 
		For $i = 1 To 10
			If _PixelSearch(115, 594, 116, 594, Hex(0x28AAF7, 6), 20, True, "New Challenges") Then 
				$bRet = True
				ExitLoop
			EndIf
			
			If Not $g_bRunState Then Return
			SetLog("Waiting New Challenges window ready #" & $i, $COLOR_ACTION)
			If _Sleep(1000) Then Return
		Next
	Else 
		For $i = 1 To 2
			If _CheckPixel($aPersonalChallengeRewardsAvail, $g_bCapturePixel) Then 
				$bRet = True
				ExitLoop
			EndIf
			SetLog("Checking New Reward #" & $i, $COLOR_ACTION)
			If _Sleep(500) Then Return
		Next
	EndIf
	
	If Not $bRet Then SetLog("No New rewards", $COLOR_DEBUG2)
	Return $bRet
EndFunc   ;==>OpenPersonalChallenges

Func CollectDailyRewards($bIcnNew = False)
	SetLog("Collecting Daily Rewards...")
	
	If $bIcnNew Then Return CollectNewDailyRewards()
	
	ClickP($aPersonalChallengeRewardsTab, 1, 0, "Rewards tab") ; Click Rewards tab
	If _Sleep(2000) Then Return

	Local $iClaim = 0
	Local $x1 = 10, $y1 = 530, $x2 = 840, $y2 = 585
	
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

Func CollectNewDailyRewards()
	Local $iClaim = 0
	Local $x1 = 240, $y1 = 250, $x2 = 800, $y2 = 390
	Local $xOffset = 50, $yOffset = 30, $bResource = False
	
	SetLog("Checking Reward CheckMarks", $COLOR_ACTION)
	If Not _PixelSearch(115, 594, 116, 594, Hex(0x28AAF7, 6), 20, True, "New Challenges") Then 
		SetLog("New Challenges Window not Found", $COLOR_DEBUG2)
		Return
	EndIf
	
	For $i = 1 To 10
		If QuickMIS("BC1", $g_sImgDailyReward, 275, 270, 310, 300) Then 
			Click($g_iQuickMISX, $g_iQuickMISY)
		Else
			SetLog("No Reward CheckMarks", $COLOR_DEBUG2)
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	
	Local $tmpxClaim = 0
	For $i = 1 To 10	
		If Not $g_bRunState Then Return
		Local $aClaim = QuickMIS("CNX", $g_sImgDailyReward, $x1, $y1, $x2, $y2)
		If IsArray($aClaim) And UBound($aClaim) > 0 Then
			_ArraySort($aClaim, 0, 0, 0, 1) ;sort x coord ascending
			For $j = 0 To UBound($aClaim) - 1
				If Not $g_bRunState Then Return
				If $aClaim[$j][0] = "CheckMark" Then ContinueLoop
				If Abs($tmpxClaim - $aClaim[$j][1]) < 10 Then ContinueLoop ;same Claim button 
				
				If QuickMIS("BC1", $g_sImgDailyRewardItems, $aClaim[$j][1], $aClaim[$j][2] - 30, $aClaim[$j][1] + 100, $aClaim[$j][2] + 50) Then
					Setlog("Claiming Chest", $COLOR_SUCCESS)
					Click($aClaim[$j][1] + $xOffset, $aClaim[$j][2] + $yOffset)
					If _Sleep(2000) Then Return
					RewardChest()
					ContinueLoop
				EndIf
				
				Click($aClaim[$j][1] + $xOffset, $aClaim[$j][2] + $yOffset)
				If _Sleep(2000) Then Return
				
				If QuickMIS("BC1", $g_sImgDailyReward, 330, 66, 385, 95) Then
					Setlog("Selecting Builder Resource", $COLOR_SUCCESS)
					Click(580, 540)
					If _Sleep(1000) Then Return
					$bResource = True
				EndIf
				
				If IsSellForGem() Then 
					If $g_bChkSellRewards Then
						Setlog("Selling extra reward for gems", $COLOR_SUCCESS)
						Click(430, 475, 1, 0, "Sell For Gems", False) ; Click Sell for Gems
						$iClaim += 1
					Else
						SetLog("Cancel. Not selling extra rewards.", $COLOR_SUCCESS)
						Click(697, 153, 1, 0, "Close Sell Window", False)
						If $bResource Then Click(762, 192, 1, 0, "Close Chose Reward Window", False)
						$bResource = False
					Endif
					If _Sleep(1000) Then ExitLoop
				Else
					$iClaim += 1
					If _Sleep(100) Then ExitLoop
				EndIf
				$tmpxClaim = $aClaim[$j][1]
			Next
		EndIf
		
		If WaitforPixel(815, 275, 816, 275, "FFFF83", 10, 1, "TrophyColor") Then ExitLoop ;thropy color
		If WaitforPixel(815, 275, 815, 276, "84FD58", 10, 1, "Card Points") Or WaitforPixel(810, 290, 811, 290, "8ACD33", 10, 1, "CheckMark Points") Then ClickDrag(750, 340, 200, 340)
	Next
	
EndFunc ;==>CollectNewDailyRewards

Func ClosePersonalChallenges($bIcnNew)
	If $g_bDebugSetlog Then SetLog("Closing personal challenges", $COLOR_INFO)
	
	If $bIcnNew Then 
		Click(825, 37)
		If _Sleep(1000) Then Return
		Return True
	EndIf
	
	If IsChallengeWindowOpen() Then
		Click(824, 85) ;close window
		Return True
	EndIf
	Return False
EndFunc   ;==>ClosePersonalChallenges

Func RewardChest($loop = 6)
	If _Sleep(1000) Then Return
	For $i = 1 To $loop
		If _Sleep(1000) Then Return
		ClickP($aReturnHomeChest)
	Next
	
	If _Sleep(8000) Then Return
	
	For $k = 1 To 5
		If _ColorCheck(_GetPixelColor(430, 482, True), Hex(0xBFEA8E, 6), 20, Default, "ChestContinue") Then 
			Click(430, 495)
			SetLog("Click Continue", $COLOR_ACTION)
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	If _Sleep(3000) Then Return
EndFunc

Func IsSellForGem()
	If _ColorCheck(_GetPixelColor(697, 153, True), Hex(0xFFFFFF, 6), 10, Default, "ButtonClose") Then Return True
EndFunc