; #FUNCTION# ====================================================================================================================
; Name ..........: RequestCC
; Description ...:
; Syntax ........: RequestCC()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......: Sardo(06-2015), KnowJack(10-2015), Sardo (08-2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func RequestCC($sText = "", $bTest = False)

	If Not $g_bRequestTroopsEnable Then Return
	If Not $g_bRunState Then Return
	
	If checkChatTabPixel() Then
		Click($aChatTabClosed[0], $aChatTabClosed[1]) ;Click ClanChatOpen
	EndIf
	
	If _Sleep($DELAYREQUESTCC1) Then Return
	SetLog("Requesting Clan Castle reinforcements", $COLOR_ACTION)
	
	If Not $g_bRunState Then Return
	Local $aRequestButton = QuickMIS("CNX", $g_sImgRequestCCButton, 280, 600, 360, 670)
	If UBound($aRequestButton) < 1 Then
		SetLog("RequestCC: Request button not detected", $COLOR_DEBUG2)
		checkChatTabPixel()
		Return
	EndIf

	If Not $g_bRunState Then Return
	
	Switch $aRequestButton[0][0]
		Case "AlreadyMade"
			SetLog("Clan Castle Request has already been made", $COLOR_DEBUG2)
		Case "Available"
			If _GetPixelColor(333, 654, True) = "ADADAD" Then ContinueCase 
			_makerequest($aRequestButton[0][1], $aRequestButton[0][2], $bTest)
		Case "FullOrUnavail"
			SetLog("Clan Castle is full or not available", $COLOR_DEBUG2)
	EndSwitch
	
	DonateCC(False, False, True)
	checkChatTabPixel()

	;exit from army overview
	If _Sleep($DELAYREQUESTCC1) Then Return

EndFunc   ;==>RequestCC

Func _makerequest($x = 315, $y = 645, $bTest = False)
	
	Local $iCount = 0, $TmpX = 0, $TmpY = 0
	Click($x, $y, 1, 0, "0336") ;click button request troops	
	Local $RequestWindowOpen = False
	For $i = 1 To 10
		SetDebugLog("Wait for Send Request Window #" & $i, $COLOR_ACTION)
		If QuickMis("BC1", $g_sImgSendRequestButton, 500, 400, 580, 560) Then 
			$TmpX = $g_iQuickMISX
			$TmpY = $g_iQuickMISY
			SetDebugLog("_makerequest: Request window open", $COLOR_ACTION)
			$RequestWindowOpen = True
			ExitLoop
		EndIf
		If _Sleep(250) Then Return
	Next
	
	If $RequestWindowOpen Then 
		If $g_sRequestTroopsText <> "" Then
			Click($TmpX - 50, $TmpY - 60) ;click text box 
			If _Sleep(500) Then Return
			If SendText($g_sRequestTroopsText) = 0 Then ;type the request
				ClickAway()
			EndIf
		EndIf
		
		If QuickMis("BC1", $g_sImgSendRequestButton, 500, 400, 580, 560) Then ;lets check again the send button position with taller height
			If Not $bTest Then 
				Click($g_iQuickMISX, $g_iQuickMISY)
			Else
				SetLog("Emulate Click : [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_INFO)
			EndIf
		EndIf
		If _Sleep(500) Then Return
		$g_bCanRequestCC = False
		Return
	Else
		SetDebugLog("Send request button not found", $COLOR_DEBUG)
	EndIf
EndFunc   ;==>_makerequest

Func IsFullClanCastleType($CCType = 0) ; Troops = 0, Spells = 1, Siege Machine = 2
	Local $aCheckCCNotFull[3] = [89, 455, 573], $sLog[3] = ["Troop", "Spell", "Siege Machine"]
	Local $aiRequestCountCC[3] = [Number($g_iRequestCountCCTroop), Number($g_iRequestCountCCSpell), 0]
	Local $bIsCCRequestTypeNotUsed = Not ($g_abRequestType[0] Or $g_abRequestType[1] Or $g_abRequestType[2])
	If $CCType <> 0 And $bIsCCRequestTypeNotUsed Then ; Continue reading CC status if all 3 items are unchecked, but only if not troop
		If $g_bDebugSetlog Then SetLog($sLog[$CCType] & " not cared about, only checking troops.")
		Return True
	Else
		If _ColorCheck(_GetPixelColor($aCheckCCNotFull[$CCType], 440, True), Hex(0xE94E52, 6), 20) Then ; red symbol
			If Not $g_abRequestType[$CCType] And Not $bIsCCRequestTypeNotUsed And $CCType <> 0 Then
				; Don't care about the CC limit configured in setting
				SetDebugLog("Found CC " & $sLog[$CCType] & " not full, but check is disabled")
				Return True
			EndIf
			SetDebugLog("Found CC " & $sLog[$CCType] & " not full")

			; avoid total expected troops / spells is less than expected CC q'ty.
			Local $iTotalExpectedTroop = 0, $iTotalExpectedSpell = 0
			For $i = 0 To $eTroopCount - 1
				$iTotalExpectedTroop += $g_aiCCTroopsExpected[$i] * $g_aiTroopSpace[$i]
				If $i <= $eSpellCount - 1 Then $iTotalExpectedSpell += $g_aiCCSpellsExpected[$i] * $g_aiSpellSpace[$i]
			Next
			If $aiRequestCountCC[0] > $iTotalExpectedTroop And $iTotalExpectedTroop > 0 Then $aiRequestCountCC[0] = $iTotalExpectedTroop
			If $aiRequestCountCC[1] > $iTotalExpectedSpell And $iTotalExpectedSpell > 0 Then $aiRequestCountCC[1] = $iTotalExpectedSpell

			If $aiRequestCountCC[$CCType] = 0 Or $aiRequestCountCC[$CCType] >= 50 - $CCType * 47 Then
				Return False
			Else
				Local $sCCReceived = getOcrAndCapture("coc-ms", 308 + $CCType * 153, 429, 50, 15, True) ; read CC (troops 0/40 and spells 0/2)
				SetDebugLog("Read CC " & $sLog[$CCType] & "s: " & $sCCReceived)
				Local $aCCReceived = StringSplit($sCCReceived, "#", $STR_NOCOUNT) ; split the trained troop number from the total troop number
				If IsArray($aCCReceived) Then
					If $g_bDebugSetlog Then SetLog("Already received " & Number($aCCReceived[0]) & " CC " & $sLog[$CCType] & (Number($aCCReceived[0]) <= 1 ? "." : "s."))
					If Number($aCCReceived[0]) >= $aiRequestCountCC[$CCType] Then
						SetLog("CC " & $sLog[$CCType] & " is sufficient as required (" & Number($aCCReceived[0]) & "/" & $aiRequestCountCC[$CCType] & ")")
						Return True
					EndIf
				EndIf
			EndIf
		Else
			SetLog("CC " & $sLog[$CCType] & " is full" & ($CCType > 0 ? " or not available." : "."))
			Return True
		EndIf
	EndIf
EndFunc   ;==>IsFullClanCastleType

Func IsFullClanCastle()
	Local $bNeedRequest = False
	If Not $g_bRunState Then Return

	If Not $g_abSearchCastleWaitEnable[$DB] And Not $g_abSearchCastleWaitEnable[$LB] Then
		Return True
	EndIf

	If ($g_abAttackTypeEnable[$DB] And $g_abSearchCastleWaitEnable[$DB]) Or ($g_abAttackTypeEnable[$LB] And $g_abSearchCastleWaitEnable[$LB]) Then
		CheckCCArmy()
		For $i = 0 To 2
			If Not IsFullClanCastleType($i) Then
				$bNeedRequest = True
				ExitLoop
			EndIf
		Next
		If $bNeedRequest Then
			$g_bCanRequestCC = True
			RequestCC(False, "IsFullClanCastle")
			Return False
		EndIf
	EndIf
	Return True
EndFunc   ;==>IsFullClanCastle

Func CheckCCArmy()
	If Not $g_bRunState Then Return

	Local $bSkipTroop = Not $g_abRequestType[0] Or _ArrayMin($g_aiClanCastleTroopWaitType) = 0 ; All 3 troop comboboxes are set = "any"
	Local $bSkipSpell = Not $g_abRequestType[1] Or _ArrayMin($g_aiClanCastleSpellWaitType) = 0 ; All 3 spell comboboxes are set = "any"
	Local $bSkipSiege = Not $g_abRequestType[2] Or _ArrayMin($g_aiClanCastleSiegeWaitType) = 0 ; All 2 siege comboboxes are set = "any"

	If $bSkipTroop And $bSkipSpell And $bSkipSiege Then Return

	Local $bNeedRemove = False, $aToRemove[8][2] ; 5 troop slots + 2 spell slots + 1 siege slot [X_Coord, Q'ty]
	Local $aTroopWSlot, $aSpellWSlot

	For $i = 0 To 2
		If $g_aiClanCastleTroopWaitQty[$i] = 0 And $g_aiClanCastleTroopWaitType[$i] > 0 Then $g_aiCCTroopsExpected[$g_aiClanCastleTroopWaitType[$i] - 1] = 40 ; expect troop type only. Do not care about qty
	Next

	SetLog("Getting current army in Clan Castle...")

	If Not $g_bRunState Then Return

	If Not $bSkipTroop Then $aTroopWSlot = getArmyCCTroops(False, False, False, True, True, True) ; X-Coord, Troop name index, Quantity
	If Not $bSkipSpell Then $aSpellWSlot = getArmyCCSpells(False, False, False, True, True, True) ; X-Coord, Spell name index, Quantity
	If Not $bSkipSiege Then getArmyCCSiegeMachines() ; getting value of $g_aiCurrentCCSiegeMachines

	; CC troops
	If IsArray($aTroopWSlot) Then
		For $i = 0 To $eTroopCount - 1
			Local $iUnwanted = $g_aiCurrentCCTroops[$i] - $g_aiCCTroopsExpected[$i]
			If $g_aiCurrentCCTroops[$i] > 0 Then SetDebugLog("Expecting " & $g_asTroopNames[$i] & ": " & $g_aiCCTroopsExpected[$i] & "x. Received: " & $g_aiCurrentCCTroops[$i])
			If $iUnwanted > 0 Then
				If Not $bNeedRemove Then
					SetLog("Removing unexpected CC army:")
					$bNeedRemove = True
				EndIf
				For $j = 0 To UBound($aTroopWSlot) - 1
					If $j > 4 Then ExitLoop
					If $aTroopWSlot[$j][1] = $i Then
						$aToRemove[$j][0] = $aTroopWSlot[$j][0]
						$aToRemove[$j][1] = _Min($aTroopWSlot[$j][2], $iUnwanted)
						$iUnwanted -= $aToRemove[$j][1]
						SetLog(" - " & $aToRemove[$j][1] & "x " & ($aToRemove[$j][1] > 1 ? $g_asTroopNamesPlural[$i] : $g_asTroopNames[$i]) & ($g_bDebugSetlog ? (", at slot " & $j & ", x" & $aToRemove[$j][0] + 35) : ""))
					EndIf
				Next
			EndIf
		Next
	EndIf

	; CC spells
	If IsArray($aSpellWSlot) Then
		For $i = 0 To $eSpellCount - 1
			Local $iUnwanted = $g_aiCurrentCCSpells[$i] - $g_aiCCSpellsExpected[$i]
			If $g_aiCurrentCCSpells[$i] > 0 Then SetDebugLog("Expecting " & $g_asSpellNames[$i] & ": " & $g_aiCCSpellsExpected[$i] & "x. Received: " & $g_aiCurrentCCSpells[$i])
			If $iUnwanted > 0 Then
				If Not $bNeedRemove Then
					SetLog("Removing unexpected CC spells/siege machine:")
					$bNeedRemove = True
				EndIf
				For $j = 0 To UBound($aSpellWSlot) - 1
					If $j > 1 Then ExitLoop
					If $aSpellWSlot[$j][1] = $i Then
						$aToRemove[$j + 5][0] = $aSpellWSlot[$j][0]
						$aToRemove[$j + 5][1] = _Min($aSpellWSlot[$j][2], $iUnwanted)
						$iUnwanted -= $aToRemove[$j + 5][1]
						SetLog(" - " & $aToRemove[$j + 5][1] & "x " & $g_asSpellNames[$i] & ($aToRemove[$j + 5][1] > 1 ? " spells" : " spell") & ($g_bDebugSetlog ? (", at slot " & $j + 5 & ", x" & $aToRemove[$j + 5][0] + 35) : ""))
					EndIf
				Next
			EndIf
		Next
	EndIf

	; CC siege machine
	If Not $bSkipSiege Then
		For $i = 0 To $eSiegeMachineCount - 1
			If $g_aiCurrentCCSiegeMachines[$i] > 0 Then SetDebugLog("Expecting " & $g_asSiegeMachineNames[$i] & ": " & $g_aiCCSiegeExpected[$i] & "x. Received: " & $g_aiCurrentCCSiegeMachines[$i])
			If $g_aiCurrentCCSiegeMachines[$i] > $g_aiCCSiegeExpected[$i] Then
				If Not $bNeedRemove Then
					SetLog("Removing unexpected CC siege machine:")
					$bNeedRemove = True
				EndIf
				$aToRemove[7][1] = 1
				SetLog(" - " & $aToRemove[7][1] & "x " & $g_asSiegeMachineNames[$i])
				ExitLoop
			EndIf
		Next
	EndIf

	; Removing CC Troops, Spells & Siege Machine
	If $bNeedRemove Then
		RemoveCastleArmy($aToRemove)
		If _Sleep(1000) Then Return
	EndIf
EndFunc   ;==>CheckCCArmy

Func RemoveCastleArmy($aToRemove)

	If _ArrayMax($aToRemove, 0, -1, -1, 1) = 0 Then Return

	; Click 'Edit Army'
	If Not _CheckPixel($aBtnEditArmy, True) Then ; If no 'Edit Army' Button found in army tab to edit troops
		SetLog("Cannot find/verify 'Edit Army' Button in Army tab", $COLOR_WARNING)
		Return False ; Exit function
	EndIf

	ClickP($aBtnEditArmy, 1) ; Click Edit Army Button
	If Not $g_bRunState Then Return

	If _Sleep(500) Then Return

	; Click remove Troops & Spells
	Local $aPos[2] = [35, 520]
	For $i = 0 To UBound($aToRemove) - 1
		If $aToRemove[$i][1] > 0 Then
			$aPos[0] = $aToRemove[$i][0] + 35
			If $i = 7 Then $aPos[0] = 650 ; x-coordinate of Siege machine slot
			SetDebugLog(" - Click at slot " & $i & ". (" & $aPos[0] & ") x " & $aToRemove[$i][1])
			ClickRemoveTroop($aPos, $aToRemove[$i][1], $g_iTrainClickDelay) ; Click on Remove button as much as needed
		EndIf
	Next

	If _Sleep(400) Then Return

	; Click Okay & confirm
	Local $counter = 0
	While Not _CheckPixel($aBtnRemOK1, True) ; If no 'Okay' button found in army tab to save changes
		If _Sleep(200) Then Return
		$counter += 1
		If $counter <= 5 Then ContinueLoop
		SetLog("Cannot find/verify 'Okay' Button in Army tab", $COLOR_WARNING)
		ClickAway()
		If _Sleep(400) Then OpenArmyOverview("RemoveCastleSpell()") ; Open Army Window AGAIN
		Return False ; Exit Function
	WEnd

	ClickP($aBtnRemOK1, 1) ; Click on 'Okay' button to save changes

	If _Sleep(400) Then Return

	$counter = 0
	While Not _CheckPixel($aBtnRemOK2, True) ; If no 'Okay' button found to verify that we accept the changes
		If _Sleep(200) Then Return
		$counter += 1
		If $counter <= 5 Then ContinueLoop
		SetLog("Cannot find/verify 'Okay #2' Button in Army tab", $COLOR_WARNING)
		ClickAway()
		Return False ; Exit function
	WEnd

	ClickP($aBtnRemOK2, 1) ; Click on 'Okay' button to Save changes... Last button

	SetLog("Clan Castle army removed", $COLOR_SUCCESS)
	If _Sleep(200) Then Return
	Return True
EndFunc   ;==>RemoveCastleArmy
