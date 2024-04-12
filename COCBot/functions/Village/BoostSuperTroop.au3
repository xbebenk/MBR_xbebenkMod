; #FUNCTION# ====================================================================================================================
; Name ..........: Boost a troop to super troop
; Description ...:
; Syntax ........: BoostSuperTroop()
; Parameters ....:
; Return values .:
; Author ........: xbebenk (08/2021)
; Modified ......: xbebenk (03/2024)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BoostSuperTroop($bTest = False, $bForced = False)
	If Not $g_bSuperTroopsEnable Then Return False
	If Not $g_bRunState Then Return
	If $g_iCommandStop = 0 Or $g_iCommandStop = 3 Then ;halt attack.. do not boost now
		If $g_bSkipBoostSuperTroopOnHalt Then
			SetLog("BoostSuperTroop() skipped, account on halt attack mode", $COLOR_DEBUG)
			Return False
		EndIf
	EndIf
	
	;assign("g_bSuperTroopBoosted", False)
	If $g_bSuperTroopBoosted And Not $bForced Then 
		SetLog("Troop Already Boosted on last check..., skip boost SuperTroop", $COLOR_SUCCESS)
		Return ;Troop already checked and boosted
	EndIf
	
	If Not $g_bRunState Then Return
	ZoomOut()
	If Not $g_bRunState Then Return
	VillageReport(True, True)
	If Not $g_bRunState Then Return
	
	If Not OpenBarrel($bForced) Then Return False
	
	Local $iPicsPerRow = 4, $picswidth = 160, $picspad = 19
	Local $curRow = 1, $columnStart = 78, $iY = 307, $iY1 = 465
	Local $BoostCost = 0, $BoostDuration = 0
	Local $sTroopName = "", $iRow = 1
	Local $iX = 0, $iX1 = $iX + $picswidth
		
	For $i = 0 To UBound($g_iCmbSuperTroops) - 1
		If Not $g_bRunState Then Return
		If $g_iCmbSuperTroops[$i] > 0 Then
			$sTroopName = $g_asSuperTroopNames[$g_iCmbSuperTroops[$i] - 1]
			SetLog("[" & $i + 1 & "] Trying to boost " & $sTroopName, $COLOR_INFO)
			
			$iX = $columnStart
			$iX1 = $iX + $picswidth
			Select
				Case $g_iCmbSuperTroops[$i] = 2 Or $g_iCmbSuperTroops[$i] = 6 Or $g_iCmbSuperTroops[$i] = 10 Or $g_iCmbSuperTroops[$i] = 14 ;second column
					$iX = $columnStart + (1 * ($picswidth + $picspad))
					$iX1 = $iX + $picswidth
				Case $g_iCmbSuperTroops[$i] = 3 Or $g_iCmbSuperTroops[$i] = 7 Or $g_iCmbSuperTroops[$i] = 11 Or $g_iCmbSuperTroops[$i] = 15  ;third column
					$iX = $columnStart + (2 * ($picswidth + $picspad))
					$iX1 = $iX + $picswidth
				Case $g_iCmbSuperTroops[$i] = 4 Or $g_iCmbSuperTroops[$i] = 8 Or $g_iCmbSuperTroops[$i] = 12 Or $g_iCmbSuperTroops[$i] = 16 ;fourth column
					$iX = $columnStart + (3 * ($picswidth + $picspad))
					$iX1 = $iX + $picswidth
			EndSelect

			$iRow = Ceiling($g_iCmbSuperTroops[$i] / $iPicsPerRow) ; get row Stroop
			If $g_bDebugSetLog Then SetLog("curRow = " & $curRow & ", iRow = " & $iRow, $COLOR_DEBUG1)
			StroopNextPage($curRow, $iRow) ; go directly to the needed Row
			$curRow = $iRow

			If $iRow = 4 Then ; for last row, we cannot scroll it to middle page
				$iY = 403
				$iY1 = 563
			EndIf
			
			If Not $g_bRunState Then Return
			If _Sleep(1000) Then Return
			If QuickMIS("BC1", $g_sImgBoostTroopsClock, $iX, $iY, $iX1, $iY1) Then ;find pics Clock on spesific row / column (if clock found = troops already boosted)
				If $g_bDebugSetLog Then SetLog("Found Clock Image", $COLOR_DEBUG)
				SetLog($sTroopName & ", Troops Already boosted", $COLOR_INFO)
				ContinueLoop
			Else
				If $g_bDebugSetLog Then SetLog("Clock Image Not Found", $COLOR_DEBUG)
			EndIf
			
			If Not $g_bRunState Then Return
			If _Sleep(1000) Then Return
			SetLog("[" & $i + 1 & "]" & $sTroopName & ", Currently is not boosted", $COLOR_INFO)
			If $g_bDebugSetLog Then SetLog('QuickMIS("BFI", $g_sImgBoostTroopsIcons & "' & $g_asSuperTroopShortNames[$g_iCmbSuperTroops[$i] - 1] & '" & "*", ' & $iX  & ", " & $iY & ", " & $iX1 & ", " & $iY1 & ")", $COLOR_DEBUG1)
			If QuickMIS("BFI", $g_sImgBoostTroopsIcons & $g_asSuperTroopShortNames[$g_iCmbSuperTroops[$i] - 1] & "*", $iX, $iY, $iX1, $iY1) Then ;find pics of Stroop on spesific row / column
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(1000) Then Return
				If $g_bForceUseSuperTroopPotion Then
					If BoostWithPotion($sTroopName, $bTest) Then ContinueLoop
				EndIf
				
				Setlog("Using Dark Elixir...", $COLOR_INFO)
				If QuickMIS("BC1", $g_sImgBoostTroopsButtons, 670, 530, 705, 570) Then ;find image of dark elixir button
					;Check Red Value on Dark Elixir cost
					If _PixelSearch(584, 556, 630, 557, Hex(0xFF887F, 6), 10, True, "BoostSuperTroop") Then
						SetLog("Not enough DE for boost, check boost with potion", $COLOR_ACTION)
						If BoostWithPotion($sTroopName, $bTest) Then
							ContinueLoop
						Else
							SetLog("No DE or Super potion for boost, EXIT!", $COLOR_ERROR)
							ExitLoop
						EndIf
					EndIf
					
					Click($g_iQuickMISX, $g_iQuickMISY)
					If _Sleep(1500) Then Return
					If QuickMIS("BC1", $g_sImgGeneralCloseButton, 624, 139, 680, 187) Then ;find image of Close Button
						If $bTest Then
							CancelBoost("Using DE, should click on [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]")
							ContinueLoop
						Else
							Click($g_iQuickMISX - 230, $g_iQuickMISY + 300) ;relative from close button image to boost button
							Setlog("Successfully Boosting " & $sTroopName, $COLOR_SUCCESS)
							ContinueLoop
						EndIf
					Else
						Setlog("Could not verify Boost Confirm Window for final upgrade " & $sTroopName, $COLOR_ERROR)
						ClickAway()
						ContinueLoop
					EndIf
					
				Else
					If Not $bTest Then Setlog("Could not find dark elixir button for upgrade " & $sTroopName, $COLOR_ERROR)
					ClickAway()
					ContinueLoop
				EndIf
			Else
				Setlog("Cannot find " & $sTroopName & ", Troop Not Unlocked yet?", $COLOR_ERROR)
				ClickAway()
				ContinueLoop
			EndIf
		EndIf
		If _Sleep(1000) Then Return
	Next
	
	ClickAway()
	If _Sleep(1000) Then Return
	If QuickMIS("BC1", $g_sImgGeneralCloseButton, 780, 80, 830, 125) Then Click($g_iQuickMISX, $g_iQuickMISY) ;close boost dialog window
	If IsBoostWindowOpened() Then Click(770, 138) ;close boost window
	
	Return $g_bSuperTroopBoosted
EndFunc   ;==>BoostSuperTroop

Func OpenBarrel($bForced = False)
	$g_bForceUseSuperTroopPotion = False
	Local $bOpenBarrel = True
	Local $xBarrel = 0, $yBarrel = 0, $sColorCheckText = ""
	Local $xColorCheck = 0, $y1ColorCheck = 0, $y2ColorCheck = 0
	Local $Color1 = "", $Color2 = "", $bBar1Found = False, $bBar2Found = False
	
	If Not $g_bRunState Then Return
	
	If QuickMIS("BC1", $g_sImgBoostTroopsBarrel, 60, 120, 220, 260) Then
		$xBarrel = $g_iQuickMISX
		$yBarrel = $g_iQuickMISY
		
		; Check if is already boosted.
		Local $EnabledStroop = 0
		For $i = 0 To Ubound($g_iCmbSuperTroops) - 1
			If $g_iCmbSuperTroops[$i] > 0 Then
				$EnabledStroop += 1
			EndIf
		Next
		
		If $g_bDebugSetLog Then SetLog("Barrel Found at [" & $xBarrel & "," & $yBarrel & "]", $COLOR_DEBUG1)
		Local $xColorCheck = $xBarrel - 9
		Local $y1ColorCheck = $yBarrel - 18
		Local $y2ColorCheck = $yBarrel - 30
		
		$Color1 = _GetPixelColor($xColorCheck, $y1ColorCheck, True)
		$Color2 = _GetPixelColor($xColorCheck, $y2ColorCheck, True)
		
		If $g_bDebugSetLog Then SetLog("Check Boost[1] at [" & $xColorCheck & "," & $y1ColorCheck & "] : " & $Color1, $COLOR_DEBUG1)
		If $g_bDebugSetLog Then SetLog("Check Boost[2] at [" & $xColorCheck & "," & $y2ColorCheck & "] : " & $Color2, $COLOR_DEBUG1)
		
		SetLog("Enabled Boost Super Troop count: " & $EnabledStroop, $COLOR_INFO)
		
		$sColorCheckText = "BoostCheck1"
		If _ColorCheck($Color1, Hex(0xF26400, 6), 30, Default, $sColorCheckText) Or _ColorCheck($Color1, Hex(0xF8AA1C, 6), 30, Default, $sColorCheckText) Or _ColorCheck($Color1, Hex(0xFAD128, 6), 30, Default, $sColorCheckText) Then
			SetLog("Boost[1] Detected", $COLOR_SUCCESS)
			$bBar1Found = True
		EndIf
		
		$sColorCheckText = "BoostCheck2"
		If _ColorCheck($Color2, Hex(0xF25D00, 6), 30, Default, $sColorCheckText) Or _ColorCheck($Color2, Hex(0xF47900, 6), 30, Default, $sColorCheckText) Or _ColorCheck($Color2, Hex(0xFAC928, 6), 30, Default, $sColorCheckText) Then
			SetLog("Boost[2] Detected", $COLOR_SUCCESS)
			$bBar2Found = True
		EndIf
		
		If $EnabledStroop = 1 And $bBar1Found Then 
			$bOpenBarrel = False
			$g_bSuperTroopBoosted = True
		EndIf
		
		If $EnabledStroop = 1 And $bBar2Found Then
			For $i = 1 To 10
				SetLog("Enabled Boost SuperTroop : 1, Detected 2 Boost on Barrel", $COLOR_ERROR)
			Next
			SetLog("Be Sure to check your boost if you do 2nd boost manually", $COLOR_INFO)
		EndIf
		
		If $EnabledStroop = 2 And $bBar2Found Then
			$bOpenBarrel = False
			$g_bSuperTroopBoosted = True
		EndIf
		
		If $bForced Then
			SetLog("Forced To Open Barrel", $COLOR_INFO)
			$bOpenBarrel = True
		EndIf		
		
		If $bOpenBarrel Then
			CheckSuperTroopPotion()
			Click($xBarrel, $yBarrel)
			If IsBoostWindowOpened() Then
				Return True
			Else
				SetLog("Couldn't find super troop window", $COLOR_ERROR)
				ClickAway()
			EndIf
		Else
			SetLog("Enabled Boost SuperTroop : " & $EnabledStroop & ", Troop(s) already boosted", $COLOR_SUCCESS)
		EndIf
	Else
		SetLog("Couldn't find super troop barrel", $COLOR_ERROR)
		ClickAway()
	EndIf
	Return False
EndFunc   ;==>OpenBarrel

Func CheckSuperTroopPotion()
	If Not OpenMagicItemWindow() Then Return
	Local $Count = 0, $MaxCount = 0
	SetLog("Checking Super Troop Potion", $COLOR_INFO)
	Local $aSearch = decodeSingleCoord(findImage("Super Troop Potion", $g_sImgTraderWindow & "SuperPot*", GetDiamondFromRect("160, 200, 700, 400")))
	If IsArray($aSearch) And UBound($aSearch) = 2 Then
		Local $sReadItemCount = MagicItemCount($aSearch[0], $aSearch[1])
		Local $asReadItemCount = StringSplit($sReadItemCount, "#", $STR_NOCOUNT)
		If IsArray($asReadItemCount) And UBound($asReadItemCount) = 2 Then
			$Count = $asReadItemCount[0]
			$MaxCount = $asReadItemCount[1]
		EndIf
		
		SetLog("Super Troop Potion Count: " & $Count & "/" & $MaxCount, $COLOR_SUCCESS)
		$g_bHaveSuperTroopPotion = True
		If Number($Count) = Number($MaxCount) Then 
			$g_bForceUseSuperTroopPotion = True
			SetLog("SuperTroop Potion on TH Storage is Full", $COLOR_SUCCESS)
		EndIf
	Else
		SetLog("No SuperTroop Potion on TH Storage", $COLOR_INFO)
		$g_bForceUseSuperTroopPotion = False
		$g_bHaveSuperTroopPotion = False
	EndIf
	
	If Number($g_aiCurrentLoot[$eLootDarkElixir]) < 25000 And Number($Count) > 0 Then
		SetLog("Current DE < than 25000, force use potion", $COLOR_ACTION)
		$g_bForceUseSuperTroopPotion = True
		$g_bHaveSuperTroopPotion = True
	EndIf
	
	ClickAway()
	If _Sleep(1000) Then Return
EndFunc

Func IsBoostWindowOpened()
	Local $aResult
	If _Sleep(500) Then Return
	For $i = 0 To 12 ;wait for about 3 seconds
		If _PixelSearch(770, 138, 771, 139, Hex(0xD1151A, 6), 10, True, "IsBoostWindowOpened") Then ;check red button x
			Return True
		EndIf
		If _Sleep(250) Then Return
	Next
	Return False
EndFunc

Func StroopNextPage($curRow, $iRow)
	Local $iXMidPoint = 425
	SetDebugLog("Goto Row: " & $iRow, $COLOR_DEBUG)
	If _Sleep(1500) Then Return
	For $i = $curRow To $iRow - 1
		ClickDrag($iXMidPoint, 250, $iXMidPoint, 65, 500)
		If _Sleep(1000) Then Return
	Next
EndFunc   ;==>StroopNextPage

Func CancelBoost($aMessage = "")
	SetLog($aMessage, $COLOR_DEBUG1)
	SetLog("Only Testing -- Cancelling", $COLOR_DEBUG1)
	ClickAway()
	If _Sleep(1000) Then Return
EndFunc   ;==>CancelBoost

Func BoostWithPotion($sTroopName = "", $bTest = False)
	SetLog("Forcing use SuperTroop Potion", $COLOR_INFO)
	Setlog("Let's try boosting " & $sTroopName & " with potion", $COLOR_INFO)
	
	If Not $g_bHaveSuperTroopPotion Then 
		SetLog("Not Have Super Troop Potion on TH Storage", $COLOR_ERROR)
		Return False
	EndIf
	
	If QuickMIS("BC1", $g_sImgBoostTroopsPotion, 500, 530, 540, 570) Then ;find image of Super Potion
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(1500) Then Return
		If QuickMIS("BC1", $g_sImgBoostTroopsPotion, 440, 440, 490, 490) Then ;find image of Super Potion again (confirm upgrade)
			;do click boost
			If $bTest Then
				CancelBoost("Using Potion, should click on [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]")
			Else
				Click($g_iQuickMISX, $g_iQuickMISY)
				Setlog("Using Potion, Successfully Boost " & $sTroopName, $COLOR_SUCCESS)
				Return True
			EndIf
		Else
			Setlog("Could not find Potion button for final upgrade " & $sTroopName, $COLOR_ERROR)
			NotifyPushToTelegram($g_sProfileCurrentName & ": Failed to boost SuperTroop using potion.")
			ClickAway()
			Return False
		EndIf
	Else
		Setlog("Could not find Potion button", $COLOR_ERROR)
		If QuickMIS("BC1", $g_sImgGeneralCloseButton, 780, 80, 830, 125) Then Click($g_iQuickMISX, $g_iQuickMISY) ;close boost dialog window
		Return False
	EndIf
EndFunc





