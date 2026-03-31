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
	
	EndGainCost("Collect")
EndFunc   ;==>Collect

Func CollectLootCart()
	If Not $g_bChkCollectLootCart Then Return
	SetLog("Check for collect lootcart", $COLOR_INFO)
	If isGoldFull(False) And IsElixirFull(False) Then Return
	
	If QuickMIS("BC1", $g_sImgCollectLootCart, 0, 50, 200, 280) Then 
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

Func OpenMiniEvent()
	Local $bRet = False
	
	SetLog("Checking Calendar Event Icon", $COLOR_ACTION)
	If QuickMIS("BC1", $g_sImgCollectCookie, 185, 610, 260, 660) Then
		Click($g_iQuickMISX, $g_iQuickMISY + 20, 1, 0, "Click Calendar Event Icon")
		$bRet = True
		If _Sleep(1000) Then Return
	EndIf
	
	If Not $bRet Then SetLog("No Event Icon found", $COLOR_DEBUG2)
	Return $bRet
EndFunc

Func VerifyClaimButton()
	Local $bRet = False
	For $i = 1 To 3
		SetDebugLog("Waiting Event Claim Button #" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgCollectCookie, 635, 310, 800, 380) Then 
			If _PixelSearch($g_iQuickMISX + 78, $g_iQuickMISY - 23, $g_iQuickMISX + 78, $g_iQuickMISY - 22, Hex(0xF9171F, 6), 40, True, "Claim Button") Then
				SetLog("Claim button verified", $COLOR_DEBUG)
				Click($g_iQuickMISX, $g_iQuickMISY)
				$bRet = True
				ExitLoop
			EndIf
		EndIf
		If _Sleep(500) Then Return
	Next
	
	If QuickMIS("BC1", $g_sImgClanRush, 100, 130, 160, 150) Then
		SetLog("Clan Rush Event", $COLOR_DEBUG)
		If QuickMIS("BC1", $g_sImgClanRush, 635, 310, 800, 380) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(1000) Then Return
			CheckClanRush()
		EndIf
	EndIf
	
	If Not $bRet Then 
		SetLog("Nothing to Claim", $COLOR_DEBUG2)
		ClickAway()
	EndIf
	
	Return $bRet
EndFunc

Func CollectCookie()
	If Not $g_bRunState Then Return
	If Not $g_bChkCollectCookie Then Return
	If $g_iTownHallLevel < 6 Then Return
	Local $bWinOpen = False, $bIconCookie = False
	SetLog("Opening Event Window", $COLOR_ACTION)
	
	If Not OpenMiniEvent() Then Return
	If Not VerifyClaimButton() Then Return
	
	For $i = 1 To 10
		SetLog("Waiting Event Window #" & $i, $COLOR_ACTION)
		If IsEventWindowOpen() Then 
			$bWinOpen = True
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	
	If Not $bWinOpen Then 
		SetLog("Cannot Verify Event Window", $COLOR_DEBUG2)
		ClickAway()
		Return
	EndIf
	
	ClaimCookieReward()
	ClickAway()
EndFunc

Func ClaimCookieReward($bGoldPass = False)
	Local $iClaim = 0, $aClaim, $bEndPage = False
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
	If QuickMIS("BC1", $g_sImgDailyReward, 32, 350, 110, 420) Then 
		Click($g_iQuickMISX, $g_iQuickMISY)
	Else
		SetLog("No Reward CheckMarks", $COLOR_DEBUG2)
		$bEndPage = True
	EndIf
	
	If $bEndPage Then
		For $i = 1 To 5
			If QuickMIS("BC1", $g_sImgDailyReward, 380, 380, 550, 450) Then 
				Click($g_iQuickMISX, $g_iQuickMISY)
				SetLog("[" & $i & "] Claiming Bonus Track Reward", $COLOR_SUCCESS)
				$iClaim += 1
			Else
				ExitLoop
			EndIf
		Next
	EndIf
	
	If _Sleep(1000) Then Return
	Local $tmpxClaim = 0
	For $i = 1 To 10
		$aClaim = QuickMIS("CNX", $g_sImgDailyReward, $x1, $y1, $x2, $y2)
		If Not $g_bRunState Then Return
		If IsArray($aClaim) And UBound($aClaim) > 0 Then
			_ArraySort($aClaim, 0, 0, 0, 1) ;sort x coord ascending
			SetDebugLog("Found " & UBound($aClaim) & " Claim Button")
			SetDebugLog(_ArrayToString($aClaim))
			For $j = 0 To UBound($aClaim) - 1
				If Not $g_bRunState Then Return
				If Abs($aClaim[$j][1] - $tmpxClaim) < 20 Then 
					SetLog("Same Claim Button, skip", $COLOR_DEBUG2)
					ContinueLoop ;same Claim button 
				EndIf
				Click($aClaim[$j][1], $aClaim[$j][2])
				If _Sleep(1000) Then Return
				If IsOKCancelPage() Then 
					If $g_bChkSellRewards Then 
						Setlog("Selling extra reward for gems", $COLOR_SUCCESS)
						Click(530, 420, 1, 0, "Sell For Gems", False) ; Click Sell for Gems
					Else
						SetLog("Cancel. Not selling extra rewards.", $COLOR_INFO)
						Click(325, 420, 1, 0, "Click Cancel")
					EndIf
					If _Sleep(1000) Then Return
				Else
					$iClaim += 1
					SetLog("Claimed " & $iClaim & ($iClaim > 1 ? " rewards" : " reward"), $COLOR_DEBUG1)
				EndIf
				$tmpxClaim = $aClaim[$j][1]
			Next
		EndIf
		If QuickMIS("BC1", $g_sImgDailyReward, 380, 380, 550, 450) Then ExitLoop ;thropy color
		If WaitforPixel(795, 399, 795, 400, "29231F", 10, 1, "End Window Color") Then ExitLoop ;End Window Color
		ClickDrag(750, 445, 200, 445) ;just swipe to right
		If _Sleep(1000) Then Return
	Next
	
	SetLog($iClaim > 0 ? "Claimed " & $iClaim & " reward(s)!" : "Nothing to claim!", $COLOR_SUCCESS)
	If IsEventWindowOpen() Then ClickAway()
	If _Sleep(500) Then Return
EndFunc

Func IsEventWindowOpen()
	Local $bRet = False
	If QuickMIS("BC1", $g_sImgCollectCookie, 170, 70, 230, 120) Then ;check Info Image 
		$bRet = True
	EndIf
	
	If Not $bRet Then 
		If _ColorCheck(_GetPixelColor(815, 89, True), Hex(0xFFFFFF, 6), 20, Default, "IsEventWindowOpen") Then $bRet = True
	EndIf
	
	If QuickMIS("BC1", $g_sImgCollectCookie, 365, 495, 500, 570) Then ;check Continue Button
		Click($g_iQuickMISX, $g_iQuickMISY)
	EndIf
	
	If $bRet Then
		SetLog("EventWindow Opened", $COLOR_DEBUG)
	EndIf
	Return $bRet
EndFunc
