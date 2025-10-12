; #FUNCTION# ====================================================================================================================
; Name ..........: Collect
; Description ...:
; Syntax ........: Collect()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......: Sardo (08/2015), KnowJack(10/2015), kaganus (10/2015), ProMac (04/2016), Codeslinger69 (01/2017), Fliegerfaust (11/2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func Collect($bOnlyCollector = False)
	If Not $g_bChkCollect Or Not $g_bRunState Then Return
	StartGainCost()
	
	SetLog("Collecting Resources", $COLOR_INFO)
	If _Sleep($DELAYCOLLECT2) Then Return

	; Setup arrays, including default return values for $return
	Local $sFileName = ""
	Local $aCollectXY, $t

	Local $aResult = returnMultipleMatchesOwnVillage($g_sImgCollectResources)

	If UBound($aResult) > 1 Then ; we have an array with data of images found
		For $i = 1 To UBound($aResult) - 1 ; loop through array rows
			$sFileName = $aResult[$i][1] ; Filename
			$aCollectXY = $aResult[$i][5] ; Coords
			Switch StringLower($sFileName)
				Case "collectmines"
					If $g_iTxtCollectGold <> 0 And $g_aiCurrentLoot[$eLootGold] >= Number($g_iTxtCollectGold) Then
						SetLog("Gold is high enough, skip collecting", $COLOR_ACTION)
						ContinueLoop
					EndIf
				Case "collectelix"
					If $g_iTxtCollectElixir <> 0 And $g_aiCurrentLoot[$eLootElixir] >= Number($g_iTxtCollectElixir) Then
						SetLog("Elixir is high enough, skip collecting", $COLOR_ACTION)
						ContinueLoop
					EndIf
				Case "collectdelix"
					If $g_iTxtCollectDark <> 0 And $g_aiCurrentLoot[$eLootDarkElixir] >= Number($g_iTxtCollectDark) Then
						SetLog("Dark Elixier is high enough, skip collecting", $COLOR_ACTION)
						ContinueLoop
					EndIf
			EndSwitch
			If IsArray($aCollectXY) Then ; found array of locations
				$t = Random(0, UBound($aCollectXY) - 1, 1) ; SC May 2017 update only need to pick one of each to collect all
				SetDebugLog($sFileName & " found, random pick(" & $aCollectXY[$t][0] & "," & $aCollectXY[$t][1] & ")", $COLOR_GREEN)
				If IsMainPage() Then Click($aCollectXY[$t][0], $aCollectXY[$t][1], 1, 0, "#0430")
				If _Sleep($DELAYCOLLECT2) Then Return
			EndIf
		Next
	EndIf
	
	If $bOnlyCollector Then 
		EndGainCost("Collect")
		Return True
	EndIf
	
	If _Sleep(50) Then Return
	CollectLootCart()
	If _Sleep(50) Then Return
	TreasuryCollect()
	ClickAway()
	If _Sleep(50) Then Return
	CollectCookieRumble()
	If _Sleep(50) Then Return
	;CheckEventStreak($g_bFirstStart)
	;If _Sleep(50) Then Return
	EndGainCost("Collect")
EndFunc   ;==>Collect

Func CollectLootCart()
	SetLog("Check for collect lootcart", $COLOR_INFO)
	If isGoldFull(False) And IsElixirFull(False) Then Return
	ZoomOutHelper("CollectLootCart")
	If QuickMIS("BC1", $g_sImgCollectLootCart, 0, 180, 160, 300) Then 
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(500) Then Return
		For $i = 1 To 5
			If _Sleep(500) Then Return
			SetLog("Collecting LootCart #" & $i, $COLOR_ACTION)
			If ClickB("CollectLootCart") Then
				SetLog("LootCart Collected", $COLOR_SUCCESS)
				Return
			EndIf
		Next
		SetLog("Cannot find LootCart Collect Button", $COLOR_DEBUG2)
	Else
		SetLog("No Loot Cart found on your Village", $COLOR_DEBUG2)
	EndIf
	ZoomOutHelper()
EndFunc   ;==>CollectLootCart

Func CheckEventRewardIcon()
	Local $bRet = False
	For $i = 1 To 5
		SetLog("Checking Reward Event Icon #" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgCollectCookie & "\Cookie", 225, 20, 360, 200) Then
			Click($g_iQuickMISX, $g_iQuickMISY + 20, 1, 0, "Click Event Icon")
			SetLog("Found Even Icon : " & $g_iQuickMISName, $COLOR_DEBUG)
			If $g_iQuickMISName = "Calendar" Then 
				$bRet = True
				ExitLoop
			EndIf
			If _Sleep(1000) Then Return
		EndIf
		If _Sleep(500) Then Return
	Next
	
	If Not $bRet Then SetLog("No Event Icon found", $COLOR_DEBUG2)
	Return $bRet
EndFunc

Func CollectCookieRumble()
	Local $bWinOpen = False, $bIconCookie = False
	SetLog("Opening Event Window", $COLOR_ACTION)
	
	If Not CheckEventRewardIcon() Then Return
	
	For $i = 1 To 5
		SetLog("Waiting Event Button #" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgCollectCookie, 340, 500, 500, 570) Then 
			If WaitforPixel($g_iQuickMISX + 30, $g_iQuickMISY - 20, $g_iQuickMISX + 40, $g_iQuickMISY - 10, "F61621", 40, 1, "CollectCookie") Then
				Click($g_iQuickMISX, $g_iQuickMISY)
				$bIconCookie = True
				ExitLoop
			Else
				SetLog("Nothing to Claim", $COLOR_INFO)
				ClickAway()
				Return
			EndIf
		EndIf
		If _Sleep(250) Then Return
	Next
	
	For $i = 1 To 10
		If $g_bDebugSetLog Then SetLog("Waiting Event Window #" & $i, $COLOR_ACTION)
		If IsCookieRumbleWindowOpen() Then 
			$bWinOpen = True
			ExitLoop
		EndIf
		If QuickMIS("BC1", $g_sImgCollectCookie, 390, 452, 475, 600) Then Click($g_iQuickMISX, $g_iQuickMISY)
		If _ColorCheck(_GetPixelColor(430, 588, True), Hex(0x8BD43A, 6), 20, Default, "ContinueButton") Then Click(430, 588, 1, 0, "Continue")
		If _Sleep(500) Then Return
		Click(570, 90, 1, 0, "Click Event Window Header")
	Next
	
	If Not $bWinOpen Then Return
	ClaimCookieReward()
	ClickAway()
EndFunc

Func ClaimCookieReward($bGoldPass = False)
	Local $iClaim = 0, $aClaim
	Local $x1 = 10, $y1 = 525, $x2 = 840, $y2 = 580
	If $bGoldPass Then $y1 = 190
	
	For $i = 1 To 5
		If QuickMIS("BC1", $g_sImgCollectCookie, 45, 360, 100, 415) Then 
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(500) Then Return
			ExitLoop
		EndIf
	Next
	
	If _Sleep(1000) Then Return
	Local $tmpxClaim = 0
	For $i = 1 To 10
		If $i = 1 And WaitforPixel(795, 398, 796, 400, "FFFE68", 10, 1, "ClaimCookieReward") Then 
			ClickDrag(400, 445, 700, 445)
			If _Sleep(500) Then Return
		EndIf
		
		If QuickMIS("BC1", $g_sImgDailyReward, 380, 380, 550, 450) Then 
			Click($g_iQuickMISX, $g_iQuickMISY)
			SetLog("[" & $i & "] Claiming Bonus Track Reward", $COLOR_SUCCESS)
			$iClaim += 1
		EndIf
		
		$aClaim = QuickMIS("CNX", $g_sImgDailyReward, $x1, $y1, $x2, $y2)
		If Not $g_bRunState Then Return
		If IsArray($aClaim) And UBound($aClaim) > 0 Then
			_ArraySort($aClaim, 0, 0, 0, 1) ;sort x coord ascending
			For $j = 0 To UBound($aClaim) - 1
				If Not $g_bRunState Then Return
				If Abs($tmpxClaim - $aClaim[$j][1]) < 10 Then ContinueLoop ;same Claim button 
				Click($aClaim[$j][1], $aClaim[$j][2])
				If _Sleep(1000) Then Return
				If IsOKCancelPage() Then 					
					SetLog("Cancel. Not selling extra rewards.", $COLOR_INFO)
					Click($aConfirmSurrender[0] - 100, $aConfirmSurrender[1]) ; Click Cancel
				Else
					$iClaim += 1
					SetLog("Claimed " & $iClaim & ($iClaim > 1 ? " rewards" : " reward"), $COLOR_DEBUG1)
				EndIf
				$tmpxClaim = $aClaim[$j][1]
			Next
		EndIf
		If WaitforPixel(795, 398, 796, 400, "FFFE68", 10, 1, "Trophy Color") Then ExitLoop ;thropy color
		If WaitforPixel(795, 398, 796, 400, "29231F", 10, 1, "End Window Color") Then ExitLoop ;End Window Color
		If WaitforPixel(799, 390, 801, 394, "CD571E", 10, 1, "Cookie Color") Then 
			ClickDrag(750, 445, 100, 445) ;cookie color
			ContinueLoop
		EndIf
		If WaitforPixel(797, 378, 798, 379, "DF3430", 10, 1, "Dragon Pinata Color") Then 
			ClickDrag(750, 445, 100, 445) ;Dragon Pinata color
			ContinueLoop
		EndIf
		If WaitforPixel(796, 392, 797, 393, "83E9EE", 10, 1, "Ice Cubes Color") Then 
			ClickDrag(750, 445, 100, 445) ;Ice Cubes color
			ContinueLoop
		EndIf
		ClickDrag(750, 445, 100, 445) ;just swipe to right
	Next
	
	SetLog($iClaim > 0 ? "Claimed " & $iClaim & " reward(s)!" : "Nothing to claim!", $COLOR_SUCCESS)
	If _Sleep(500) Then Return
	If IsCookieRumbleWindowOpen() Then ClickAway()
	If _Sleep(500) Then Return
	ClickAway()
EndFunc

Func IsCookieRumbleWindowOpen()
	Local $bRet = False
	If _ColorCheck(_GetPixelColor(815, 89, True), Hex(0xFFFFFF, 6), 20, Default, "IsCookieRumbleWindowOpen")Then
		$bRet = True
	EndIf
	
	If Not $bRet Then 
		If QuickMIS("BC1", $g_sImgGeneralCloseButton, 793, 70, 840, 110) Then $bRet = True
	EndIf
	
	If $bRet Then
		SetLog("Found Event Window Open", $COLOR_DEBUG)
	EndIf
	Return $bRet
EndFunc

Func CheckEventStreak($bForced = False)
	SetLog("Checking Event Streak", $COLOR_INFO)
	If QuickMIS("BC1", $g_sImgEventStreak, 185, 615, 235, 655) Then
		If WaitforPixel($g_iQuickMISX + 17, $g_iQuickMISY - 9, $g_iQuickMISX + 18, $g_iQuickMISY - 8, Hex(0xE41528, 6), 20, 1, "CheckEventStreak") Then
			Click($g_iQuickMISX, $g_iQuickMISY)
		Else
			SetLog("No Event to Check", $COLOR_INFO)
			If Not $bForced Then Return
			Click($g_iQuickMISX, $g_iQuickMISY)
		EndIf
		If _Sleep(500) Then Return
	EndIf
	
	Local $bEventStreakFound = False
	For $i = 1 To 5
		If _Sleep(500) Then Return
		If IsEventWindowOpen() Then
			$bEventStreakFound = True
			ExitLoop
		Else
			SetLog("Waiting Event Window #" & $i, $COLOR_ACTION)
			ContinueLoop
		EndIf
		If QuickMIS("BC1", $g_sImgEventStreak, 70, 130, 125, 155) Then ;event name eg: cookie, ice, cosmic
			$bEventStreakFound = True
			ExitLoop
		EndIf
	Next
	
	If Not $bEventStreakFound Then Return ;no event Streak active, return
	
	If QuickMIS("BC1", $g_sImgEventStreak, 690, 325, 730, 350) Then ;check claim button exist
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(1000) Then Return
	EndIf
	
	For $i = 1 To 10
		SetLog("Waiting Event Streak Window #" & $i, $COLOR_ACTION)
		If IsEventStreakWindowOpen() Then ExitLoop ; Event Streak Window Cleared, exit loop
		If QuickMIS("BC1", $g_sImgEventStreak, 385, 495, 477, 523) Then Click($g_iQuickMISX, $g_iQuickMISY) ; Click Continue Button
		If _ColorCheck(_GetPixelColor(430, 588, True), Hex(0x8BD43A, 6), 20, Default, "ContinueButton") Then Click(430, 588, 1, 0, "Continue")
		Click(410, 150, 1, 50, "EventStreakWindowHeader") ;Click Event Streak Window Header
		If _Sleep(1000) Then Return
	Next
	
	If _Sleep(1500) Then Return
	Local $aClaim = QuickMIS("CNX", $g_sImgEventStreakClaim, 20, 280, 850, 500)
	If IsArray($aClaim) And UBound($aClaim) > 0 Then
		For $i = 0 To UBound($aClaim) - 1
			If $aClaim[$i][0] = "BrokenStreak" Then
				Click($aClaim[$i][1], $aClaim[$i][2])
				If _Sleep(500) Then Return
				If WaitforPixel(280, 435, 281, 436, Hex(0xD94343, 6), 20, 2, "StartOverButton") Then
					Click(280, 435, 1, 50, "BrokenStreak-StartOver")
					SetLog("Found a Broken Streak, StartOver!", $COLOR_SUCCESS)
					ClickAway()
				EndIf
				ClickAway()
				ClickAway()
				SetLog("Cannot Find StartOver Button, exit!", $COLOR_ERROR)
				Return				
			EndIf
			If $aClaim[$i][0] = "Claim" Then
				Click($aClaim[$i][1], $aClaim[$i][2])
				If _Sleep(500) Then Return
				Setlog("Succesfully Claimed Event Streak Tier", $COLOR_SUCCESS)
				If _Sleep(1000) Then Return
				ClickAway()
			EndIf
		Next
	EndIf
	ClickAway()
	Return True
EndFunc

Func IsEventWindowOpen()
	Local $bRet = False
	If _ColorCheck(_GetPixelColor(808, 54, True), Hex(0xFFFFFF, 6), 20, Default, "IsEventWindowOpen") And _
		_ColorCheck(_GetPixelColor(33, 73, True), Hex(0x423E35, 6), 20, Default, "IsEventWindowOpen") Then
		$bRet = True
	EndIf
	
	If Not $bRet Then 
		If QuickMIS("BC1", $g_sImgGeneralCloseButton, 786, 36, 828, 77) Then $bRet = True
	EndIf
	
	If $bRet Then
		SetLog("EventWindow Opened", $COLOR_DEBUG)
	EndIf
	Return $bRet
EndFunc

Func IsEventStreakWindowOpen()
	Local $bRet = False
	If _ColorCheck(_GetPixelColor(815, 89, True), Hex(0xFFFFFF, 6), 20, Default, "IsEventStreakWindowOpen")Then
		$bRet = True
	EndIf
	
	If Not $bRet Then 
		If QuickMIS("BC1", $g_sImgGeneralCloseButton, 793, 70, 840, 110) Then $bRet = True
	EndIf
	
	If $bRet Then
		SetLog("Found EventStreakWindow Open", $COLOR_DEBUG)
	EndIf
	Return $bRet
EndFunc