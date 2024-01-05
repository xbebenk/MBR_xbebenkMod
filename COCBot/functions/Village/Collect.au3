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

Func Collect($bCheckTreasury = True)
	If Not $g_bChkCollect Or Not $g_bRunState Then Return

	ClickAway()

	StartGainCost()
	checkAttackDisable($g_iTaBChkIdle) ; Early Take-A-Break detection
	
	;If $g_bChkCollectCartFirst And ($g_iTxtCollectGold = 0 Or $g_aiCurrentLoot[$eLootGold] < Number($g_iTxtCollectGold) Or $g_iTxtCollectElixir = 0 Or $g_aiCurrentLoot[$eLootElixir] < Number($g_iTxtCollectElixir) Or $g_iTxtCollectDark = 0 Or $g_aiCurrentLoot[$eLootDarkElixir] < Number($g_iTxtCollectDark)) Then CollectLootCart()

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

	If _Sleep($DELAYCOLLECT3) Then Return
	CollectCookieRumble()
	CollectLootCart()
	If $g_bChkTreasuryCollect And $bCheckTreasury Then TreasuryCollect()
	EndGainCost("Collect")
EndFunc   ;==>Collect

Func CollectLootCart()
	ZoomOutHelper("CollectLootCart")

	SetLog("Searching for a Loot Cart", $COLOR_INFO)
	If QuickMIS("BC1", $g_sImgCollectLootCart, 0, 180, 160, 300) Then 
		Click($g_iQuickMISX + 10, $g_iQuickMISY)
		If _Sleep(1000) Then Return
		If ClickB("CollectLootCart") Then
			SetLog("LootCart Collected", $COLOR_SUCCESS)
		Else
			SetLog("Cannot find LootCart Collect Button", $COLOR_ERROR)
		EndIf
	Else
		SetLog("No Loot Cart found on your Village", $COLOR_SUCCESS)
	EndIf
EndFunc   ;==>CollectLootCart

Func CollectCookie()
	If QuickMIS("BC1", $g_sImgCollectCookie & "\Cookie", 245, 45, 360, 100) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		SetLog("Collecting Cookie", $COLOR_ACTION)
		If _Sleep(1000) Then Return
	EndIf
EndFunc

Func CollectCookieRumble()
	CollectCookie()
	
	Local $bWinOpen = False, $bIconCookie = False
	SetLog("Opening Gingerbread Bakery", $COLOR_ACTION)
	If QuickMIS("BC1", $g_sImgCollectCookie, 225, 45, 360, 200) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(1000) Then Return
		For $i = 1 To 5
			If $g_bDebugSetLog Then SetLog("Waiting Gingerbread Bakery Button #" & $i, $COLOR_ACTION)
			If QuickMIS("BC1", $g_sImgCollectCookie, 340, 500, 425, 570) Then 
				If WaitforPixel($g_iQuickMISX + 30, $g_iQuickMISY - 20, $g_iQuickMISX + 32, $g_iQuickMISY - 18, "F61621", 10, 1) Then
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
	Else	
		SetLog("CookieFactory Icon Not Found", $COLOR_ERROR)
	EndIf
	If Not $bIconCookie Then Return
	
	For $i = 1 To 10
		If $g_bDebugSetLog Then SetLog("Waiting Cookie Rumble Window #" & $i, $COLOR_ACTION)
		If IsCookieRumbleWindowOpen() Then 
			$bWinOpen = True
			ExitLoop
		EndIf
		If QuickMIS("BC1", $g_sImgCollectCookie, 390, 552, 475, 600) Then Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(500) Then Return
		Click(570, 90, 1, "Click CookieRumble Window Header")
	Next
	
	If Not $bWinOpen Then Return
	ClaimCookieReward()
	ClickAway()
EndFunc

Func ClaimCookieReward($bGoldPass = False)
	Local $iClaim = 0
	Local $x1 = 10, $y1 = 525, $x2 = 840, $y2 = 580
	If $bGoldPass Then $y1 = 190
	
	For $i = 1 To 5
		If QuickMIS("BC1", $g_sImgCollectCookie, 45, 360, 100, 415) Then 
			Click($g_iQuickMISX, $g_iQuickMISY)
			ExitLoop
			If _Sleep(500) Then Return
		EndIf
	Next
	
	If _Sleep(1000) Then Return
	
	For $i = 1 To 10
		Local $aClaim = QuickMIS("CNX", $g_sImgDailyReward, $x1, $y1, $x2, $y2)
		If Not $g_bRunState Then Return
		If IsArray($aClaim) And UBound($aClaim) > 0 Then
			For $j = 0 To UBound($aClaim) - 1
				If Not $g_bRunState Then Return
				Click($aClaim[$j][1], $aClaim[$j][2])
				If _Sleep(1000) Then Return
				If IsOKCancelPage() Then 
					If $g_bChkSellRewards Then
						Setlog("Selling extra reward for gems", $COLOR_SUCCESS)
						Click($aConfirmSurrender[0], $aConfirmSurrender[1]) ; Click the Okay
						$iClaim += 1
					Else
						SetLog("Cancel. Not selling extra rewards.", $COLOR_SUCCESS)
						Click($aConfirmSurrender[0] - 100, $aConfirmSurrender[1]) ; Click Cancel
					Endif
					If _Sleep(1000) Then Return
				Else
					$iClaim += 1
					If _Sleep(1000) Then Return
				EndIf
			Next
		EndIf
		If WaitforPixel(795, 398, 796, 400, "FFFE68", 10, 1) Then ExitLoop ;thropy color
		If WaitforPixel(799, 390, 801, 394, "CD571E", 10, 1) Then ClickDrag(750, 445, 100, 445, 1000) ;cookie color
	Next
	
	SetLog($iClaim > 0 ? "Claimed " & $iClaim & " reward(s)!" : "Nothing to claim!", $COLOR_SUCCESS)
	If _Sleep(500) Then Return
	If IsCookieRumbleWindowOpen() Then ClickAway()
EndFunc

Func IsCookieRumbleWindowOpen()
	Local $result = False
	$result = WaitforPixel(824, 85, 826, 86, "FFFFFF", 10, 2)
	
	If Not $result Then 
		If QuickMIS("BC1", $g_sImgGeneralCloseButton, 800, 64, 850, 112) Then $result = True
	EndIf
	
	If $result Then
		If $g_bDebugSetlog Then SetLog("Found CookieRumble Window", $COLOR_ACTION)
	EndIf
	Return $result
EndFunc