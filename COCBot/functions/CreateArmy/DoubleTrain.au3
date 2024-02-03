
; #FUNCTION# ====================================================================================================================
; Name ..........: Double Train
; Description ...:
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Demen
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func DoubleTrain()
	If Not $g_bDoubleTrain Then Return
	If isProblemAffect(True) Then Return
	Local $bDebug = $g_bDebugSetlogTrain Or $g_bDebugSetlog

	SetLog(" ====== Double Train ====== ", $COLOR_ACTION)

	Local $bNeedReCheckTroopTab = False, $bNeedReCheckSpellTab = False

	; Troop
	If Not OpenTroopsTab(False, "DoubleTrain()") Then Return
	If _Sleep(250) Then Return
	
	Local $tmpCamp = 999, $TroopCamp
	While 1
		$TroopCamp = GetCurrentArmy(95, 163)
		If IsProblemAffect(True) Then Return
		If _Sleep(50) Then Return
		If Not $g_bRunState Then Return
		
		If $g_bDebugSetlog Then SetDebugLog(_ArrayToString($TroopCamp))
		SetLog("Checking Troop tab: " & $TroopCamp[0] & "/" & $TroopCamp[1] * 2 & " remain space:" & $TroopCamp[2], $COLOR_DEBUG1)
		If $tmpCamp = $TroopCamp[2] Then ExitLoop
		$tmpCamp = $TroopCamp[2]
		Select
			Case $TroopCamp[1] = 0
				SetLog("$TroopCamp[1] = 0", $COLOR_DEBUG1)
				ExitLoop
			Case $TroopCamp[0] = ($TroopCamp[1] * 2)
				SetLog("Cur = Max", $COLOR_DEBUG1)
				If IsNormalTroopTrain() Then
					If Not CheckQueueTroopAndTrainRemain() Then ExitLoop
				EndIf
			Case $TroopCamp[0] = 0 ; 0/600 (empty troop camp)
				SetLog("TroopCamp[0] = 0", $COLOR_DEBUG1)
				TrainFullTroop() ;train 1st Army
			Case $TroopCamp[2] = 0 ;300/600 (empty troop queue)
				SetLog("TroopCamp[2] = 0", $COLOR_DEBUG1)
				TrainFullTroop(True) ;train 2nd Army
			Case $TroopCamp[2] > 0 ; 30/600 (1st army partially trained)
				SetLog("TroopCamp[2] > 0", $COLOR_DEBUG1)
				If IsNormalTroopTrain() Then
					RemoveTrainTroop()
					Local $aWhatToTrain = WhatToTrain(False, False)
					SetLog("New troop Fill way", $COLOR_DEBUG1)
					TrainUsingWhatToTrain($aWhatToTrain) ;should only train 1st army
					RemoveTrainTroop(True) ;recheck trained army, remove excess queued army (leave only 1st army)
					FillIncorrectTroopCombo("1st Army")
				Else
					FillIncorrectTroopCombo("1st Army")
				EndIf
			Case $TroopCamp[0] = $TroopCamp[1] ;300/600 (1st army fully trained)
				SetLog($TroopCamp[0] & " = " & $TroopCamp[1], $COLOR_DEBUG1)
				TrainFullTroop(True) ;train 2nd Army
			Case $TroopCamp[0] > $TroopCamp[1] ;350/600 (2nd army partially trained)
				SetLog($TroopCamp[0] & " > " & $TroopCamp[1], $COLOR_DEBUG1)
				If IsNormalTroopTrain() Then
					CheckQueueTroopAndTrainRemain($TroopCamp, $bDebug) ;train to queue
					FillIncorrectTroopCombo("2nd Army")
					ExitLoop
				Else
					FillIncorrectTroopCombo("2nd Army") 
				EndIf
		EndSelect
		If _Sleep(500) Then Return
	WEnd

	; Spell
	Local $iUnbalancedSpell = 0, $Step = 0
	Local $TotalSpell = _Min(Number(TotalSpellsToBrewInGUI()), Number($g_iTotalSpellValue))
	
	If $g_bIgnoreIncorrectSpellCombo Then $TotalSpell = 1
	If $TotalSpell = 0 Then
		If $bDebug Then SetLog("No spell is required, skip checking spell tab", $COLOR_DEBUG)
	Else
		If Not OpenSpellsTab(False, "DoubleTrain()") Then Return
		If _Sleep(250) Then Return
		$Step = 1
		While 1
			Local $SpellCamp = GetCurrentSpell(95, 163)
			If IsProblemAffect(True) Then Return
			If Not $g_bRunState Then Return
			SetLog("Checking Spell tab: " & $SpellCamp[0] & "/" & $SpellCamp[1] * 2, $COLOR_DEBUG1)
			
			If $SpellCamp[0] = ($SpellCamp[1] * 2) Then
				SetLog("Cur = Max")
				$bNeedReCheckSpellTab = False
				ExitLoop
			EndIf

			If $SpellCamp[1] > $TotalSpell Then
				SetLog("Unbalance Total spell setting vs actual spell capacity: " & $TotalSpell & "/" & $SpellCamp[1] & @CRLF & @TAB & "Double train may not work well", $COLOR_DEBUG)
				$iUnbalancedSpell = $SpellCamp[1] - $TotalSpell
				$SpellCamp[1] = $TotalSpell
			EndIf

			If $SpellCamp[0] < $SpellCamp[1] Then ; 0-10/11
				If $g_bDonationEnabled And $g_bChkDonate And MakingDonatedTroops("Spells") Then
					If $bDebug Then SetLog($Step & ". MakingDonatedTroops('Spells')", $COLOR_DEBUG)
					$Step += 1
					If $Step = 6 Then ExitLoop
					ContinueLoop
				EndIf
				If Not $g_bIgnoreIncorrectSpellCombo Then 
					If Not IsQueueEmpty("Spells", False, False) Then DeleteQueued("Spells")
					If $bDebug Then SetLog($Step & ". DeleteQueued('Spells'). $bNeedReCheckSpellTab: " & $bNeedReCheckSpellTab, $COLOR_DEBUG)
				EndIf
				$bNeedReCheckSpellTab = True
				ExitLoop

			ElseIf $SpellCamp[0] = $SpellCamp[1] Or $SpellCamp[0] <= $SpellCamp[1] + $iUnbalancedSpell Then ; 11/22
				BrewFullSpell(True)
				If $iUnbalancedSpell > 0 Then TopUpUnbalancedSpell($iUnbalancedSpell)
				If $bDebug Then SetLog($Step & ". BrewFullSpell(True) done!", $COLOR_DEBUG)

			Else ; If $SpellCamp[0] <= $SpellCamp[1] * 2 Then ; 12-22/22
				If CheckQueueSpellAndTrainRemain($SpellCamp, $bDebug, $iUnbalancedSpell) Then
					If $SpellCamp[0] < ($SpellCamp[1] + $iUnbalancedSpell) * 2 Then TopUpUnbalancedSpell($iUnbalancedSpell)
					If $bDebug Then SetLog($Step & ". CheckQueueSpellAndTrainRemain() done!", $COLOR_DEBUG)
				Else
					If Not $g_bIgnoreIncorrectSpellCombo Then
						RemoveExtraTroopsQueue()
						If _Sleep(500) Then Return
						If $bDebug Then SetLog($Step & ". RemoveExtraTroopsQueue()", $COLOR_DEBUG)
						$Step += 1
						If $Step = 6 Then ExitLoop
						ContinueLoop
					EndIf
				EndIf
			EndIf
			ExitLoop
		WEnd
	EndIf
	
EndFunc   ;==>DoubleTrain

Func TrainFullTroop($bQueue = False)
	SetLog("Training " & ($bQueue ? "2nd Army..." : "1st Army..."))
	If _Sleep(500) Then Return
	Local $ToReturn[1][2] = [["Arch", 0]]
	For $i = 0 To $eTroopCount - 1
		Local $troopIndex = $g_aiTrainOrder[$i]
		If $g_aiArmyCompTroops[$troopIndex] > 0 Then
			$ToReturn[UBound($ToReturn) - 1][0] = $g_asTroopShortNames[$troopIndex]
			$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompTroops[$troopIndex]
			ReDim $ToReturn[UBound($ToReturn) + 1][2]
		EndIf
	Next
	
	If $ToReturn[0][0] = "Arch" And $ToReturn[0][1] = 0 And Not $g_bIgnoreIncorrectTroopCombo Then Return
	
	TrainUsingWhatToTrain($ToReturn, $bQueue)
	If _Sleep(500) Then Return
	
	If $g_bIgnoreIncorrectTroopCombo Then
		FillIncorrectTroopCombo("TrainFullTroop")
	EndIf
EndFunc   ;==>TrainFullTroop

Func FillIncorrectTroopCombo($caller = "Unknown")
	If Not $g_bIgnoreIncorrectTroopCombo Then Return
	SetLog("Train to Fill Incorrect Troop Combo", $COLOR_ACTION)
	
	If Not OpenTroopsTab(True, "FillIncorrectTroopCombo()") Then Return
	Local $CampOCR = GetCurrentArmy(95, 163)
	If Not $g_bRunState Then Return
	
	If $g_bDebugSetlog Then SetLog("CampOCR:" & _ArrayToString($CampOCR) & " Called from : " & $caller)
	
	If $CampOCR[0] = 0 Then ;no troop trained on 1st army 
		SetLog("no need to fill troop on 1st army", $COLOR_DEBUG1)
		Return
	EndIf
	
	If $CampOCR[2] = 0 Or $CampOCR[0] = ($CampOCR[1] * 2) Then ;no troop trained on 2nd Army
		SetLog("no need to fill troop on 2nd Army", $COLOR_DEBUG1)
		Return
	EndIf
	
	Local $bQueue = $CampOCR[2] < 0 ? True : False ;campOCR[2] read is remain space to train, negative value on 2nd army
	Local $TroopSpace = $bQueue ? (Number($CampOCR[1]) * 2) - Number($CampOCR[0]) : Number($CampOCR[2])
	If $TroopSpace < 0 Then Return
	SetLog("TroopSpace = " & $TroopSpace, $COLOR_DEBUG)
	
	Local $FillTroopIndex = $g_iCmbFillIncorrectTroopCombo
	Local $sTroopName = $g_sCmbFICTroops[$FillTroopIndex][1]
	Local $iTroopIndex = TroopIndexLookup($g_sCmbFICTroops[$FillTroopIndex][0])
	Local $TroopQuantToFill = Floor($TroopSpace/$g_sCmbFICTroops[$FillTroopIndex][2])
	SetLog("TroopQuantToFill = x" & $TroopQuantToFill & " " & $sTroopName, $COLOR_DEBUG)
	
	If $TroopQuantToFill > 0 Then
		If Not DragIfNeeded($g_sCmbFICTroops[$FillTroopIndex][0]) Then Return False
		SetLog("Training " & $TroopQuantToFill & "x " & $sTroopName, $COLOR_SUCCESS)
		TrainIt($iTroopIndex, $TroopQuantToFill, $g_iTrainClickDelay)
	EndIf
EndFunc

Func BrewFullSpell($bQueue = False)
	SetLog("Brewing " & ($bQueue ? "2nd Army..." : "1st Army..."))

	Local $ToReturn[1][2] = [["Arch", 0]]
	For $i = 0 To $eSpellCount - 1
		Local $BrewIndex = $g_aiBrewOrder[$i]
        If $g_aiArmyCompSpells[$BrewIndex] > 0 Then
			$ToReturn[UBound($ToReturn) - 1][0] = $g_asSpellShortNames[$BrewIndex]
			$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompSpells[$BrewIndex]
			ReDim $ToReturn[UBound($ToReturn) + 1][2]
		EndIf
	Next

	If $ToReturn[0][0] = "Arch" And $ToReturn[0][1] = 0 And Not $g_bIgnoreIncorrectSpellCombo Then Return

	BrewUsingWhatToTrain($ToReturn, $bQueue)
	If _Sleep(750) Then Return
	
	If Not OpenSpellsTab(True, "BrewFullSpell()") Then Return
	Local $CampOCR = GetCurrentSpell(95, 163)
	If Not $g_bRunState Then Return
	SetDebugLog("Checking spell tab: " & $CampOCR[0] & "/" & $CampOCR[1] * 2)
	If $g_bIgnoreIncorrectSpellCombo And $g_bDoubleTrain Then
		FillIncorrectSpellCombo($bQueue, $CampOCR)
	EndIf
EndFunc   ;==>BrewFullSpell

Func FillIncorrectSpellCombo($bQueue, $CampOCR)
	If Not $g_bIgnoreIncorrectSpellCombo Then Return
	SetLog("Train to Fill Incorrect Spell Combo", $COLOR_ACTION)
	If Not OpenSpellsTab(True, "FillIncorrectSpellCombo()") Then Return
	Local $SpellSpace = $bQueue ? Number($CampOCR[1]) + Number($CampOCR[2]) : Number($CampOCR[2])
	SetLog("SpellQuantity = " & $CampOCR[0] & "/" & $CampOCR[1], $COLOR_DEBUG1)
	
	Local $FillSpellIndex = $g_iCmbFillIncorrectSpellCombo
	Local $sSpellName = $g_sCmbFICSpells[$FillSpellIndex][1]
	Local $iSpellIndex = TroopIndexLookup($g_sCmbFICSpells[$FillSpellIndex][0])
	Local $SpellQuantToFill = Floor($SpellSpace/$g_sCmbFICSpells[$FillSpellIndex][2])
	
	If $SpellQuantToFill > 0 Then
		If Not DragIfNeeded($g_sCmbFICSpells[$FillSpellIndex][0]) Then Return False
		SetLog("Training " & $SpellQuantToFill & "x " & $sSpellName, $COLOR_SUCCESS)
		TrainIt($iSpellIndex, $SpellQuantToFill, $g_iTrainClickDelay)
	EndIf
EndFunc

Func TopUpUnbalancedSpell($iUnbalancedSpell = 0)

	If $iUnbalancedSpell = 0 Then Return
	Local $iTypeOfSpell = 0, $iSpellIndex
	For $i = 0 To UBound($g_aiArmyCompSpells) - 1
		If $g_aiArmyCompSpells[$i] > 0 Then
			$iSpellIndex = $i
			$iTypeOfSpell += 1
		EndIf
		If $iTypeOfSpell > 1 Then ExitLoop
	Next

	If $iTypeOfSpell = 1 Then
		Local $aSpell[1][2]
		$aSpell[0][0] = $g_asSpellShortNames[$iSpellIndex]
		$aSpell[0][1] = Int($iUnbalancedSpell * 2 / $g_aiSpellSpace[$iSpellIndex])

		If $aSpell[0][1] >= 1 Then
			SetLog("Topping up " & $g_asSpellNames[$iSpellIndex] & " Spell x" & $aSpell[0][1])
			BrewUsingWhatToTrain($aSpell, True)
		EndIf
	EndIf

	If _Sleep(750) Then Return

EndFunc   ;==>IsBrewOnlyOneType

Func GetCurrentArmy($x_start, $y_start)

	Local $aResult[3] = [0, 0, 0]
	If Not $g_bRunState Then Return $aResult

	; [0] = Current Army  | [1] = Total Army Capacity  | [2] = Remain Space for the current Army
	
	If _Sleep(500) Then Return ; wait until number stop changing
	
	Local $iOCRResult = getArmyCapacityOnTrainTroops($x_start, $y_start)

	If StringInStr($iOCRResult, "#") Then
		Local $aTempResult = StringSplit($iOCRResult, "#", $STR_NOCOUNT)
		$aResult[0] = Number($aTempResult[0])
		$aResult[1] = Number($aTempResult[1]) / 2
		$aResult[2] = $aResult[1] - $aResult[0]
	Else
		SetLog("DEBUG | ERROR on GetCurrentArmy", $COLOR_ERROR)
	EndIf

	Return $aResult

EndFunc   ;==>GetCurrentArmy

Func GetCurrentSpell($x_start, $y_start)

	Local $aResult[3] = [0, 0, 0]
	If Not $g_bRunState Then Return $aResult

	; [0] = Current Army  | [1] = Total Army Capacity  | [2] = Remain Space for the current Army
	
	If _Sleep(500) Then Return ; wait until number stop changing
	
	Local $iOCRResult = getArmyCapacityOnTrainSpell($x_start, $y_start)

	If StringInStr($iOCRResult, "#") Then
		Local $aTempResult = StringSplit($iOCRResult, "#", $STR_NOCOUNT)
		$aResult[0] = Number($aTempResult[0])
		$aResult[1] = Number($aTempResult[1]) / 2
		$aResult[2] = $aResult[1] - $aResult[0]
	Else
		SetLog("DEBUG | ERROR on GetCurrentSpell", $COLOR_ERROR)
	EndIf

	Return $aResult

EndFunc   ;==>GetCurrentSpell

Func CheckQueueTroopAndTrainRemain($ArmyCamp = Default, $bDebug = False) ;GetCurrentArmy(95, 163)
	If Not OpenTroopsTab(True, "CheckQueueTroopAndTrainRemain()") Then Return
	If $ArmyCamp = Default Then $ArmyCamp = GetCurrentArmy(95, 163)
	If Not $g_bRunState Then Return
	If $ArmyCamp[0] = $ArmyCamp[1] * 2 And ((ProfileSwitchAccountEnabled() And $g_abAccountNo[$g_iCurAccount] And $g_abDonateOnly[$g_iCurAccount]) Or $g_iCommandStop = 0) Then Return True ; bypass Donate account when full queue
	
	Local $iTotalQueue = 0
	SetLog("Checking troop queue: " & $ArmyCamp[0] & "/" & $ArmyCamp[1] * 2, $COLOR_DEBUG1)
	If $g_bTrainPreviousArmy Then 
		While _ColorCheck(_GetPixelColor(265, 197, True), Hex(0xFFFFFF, 6), 20, Default, "Army Added Message")
			If Not $g_bRunState Then Return
			SetLog("Army Added Message Blocking, Waiting until it's gone", $COLOR_INFO)
			If _Sleep(500) Then Return
		WEnd
	EndIf
	
	Local $XQueueStart = FindxQueueStart()
	Local $aiQueueTroops = CheckQueueTroops(True, $bDebug, $XQueueStart)
	;CheckQueueTroops(True, True, FindxQueueStart())
	If Not IsArray($aiQueueTroops) Then Return False
	For $i = 0 To UBound($aiQueueTroops) - 1
		If $aiQueueTroops[$i] > 0 Then $iTotalQueue += $aiQueueTroops[$i] * $g_aiTroopSpace[$i]
	Next
	
	;check wrong camp utilization
	If $ArmyCamp[1] <> $g_iTotalCampSpace Then 
		;SetLog("$ArmyCamp[1] <> $g_iTotalCampSpace", $COLOR_ERROR)
		Local $countTroop = 0
		For $i = 0 To UBound($g_aiArmyCompTroops) - 1
			$countTroop += $g_aiArmyCompTroops[$i]
		Next
		If $countTroop = 1 Then Return False ;only 1 troop on train setting, user utilizing fill incorrect combo troops
	EndIf
	
	; Check block troop
	If $ArmyCamp[0] < $ArmyCamp[1] + $iTotalQueue Then
		SetLog("$ArmyCamp[0] = " & $ArmyCamp[0] & " < $ArmyCamp[1] + $iTotalQueue = " & $ArmyCamp[1] + $iTotalQueue)
		SetLog("A big guy blocks our camp")
		Return False
	EndIf
	
	; check wrong queue
	Local $iExcessTroop = 0, $bExcessTroop = False
	For $i = 0 To UBound($aiQueueTroops) - 1
		If Not $g_bRunState Then Return
		$iExcessTroop = $aiQueueTroops[$i] - $g_aiArmyCompTroops[$i]
		If $iExcessTroop > 0 Then
			SetLog("  - " & $g_asTroopNames[$i] & " x" & $aiQueueTroops[$i] & ", excess queue : " & $iExcessTroop, $COLOR_ACTION)
			$aiQueueTroops[$i] -= $iExcessTroop
			$bExcessTroop = True
			RemoveQueueTroop($i, $iExcessTroop)
			If _Sleep(500) Then Return
		EndIf
	Next
	
	If $bExcessTroop Then 
		If _Sleep(1500) Then Return
		$ArmyCamp = GetCurrentArmy(95, 163)
		SetLog("After excess troop queue: " & $ArmyCamp[0] & "/" & $ArmyCamp[1] * 2, $COLOR_DEBUG1)
		;Return True
	EndIf
	
	If $ArmyCamp[0] < $ArmyCamp[1] * 2 Then
		; Train remain
		SetLog("TrainRemain troop queue:")
		Local $rWTT[1][2] = [["Arch", 0]] ; what to train
		For $i = 0 To UBound($aiQueueTroops) - 1
			Local $iIndex = $g_aiTrainOrder[$i]
			If $aiQueueTroops[$iIndex] > 0 Then SetLog("  - " & $g_asTroopNames[$iIndex] & ": " & $aiQueueTroops[$iIndex] & "x")
			If $g_aiArmyCompTroops[$iIndex] - $aiQueueTroops[$iIndex] > 0 Then
				$rWTT[UBound($rWTT) - 1][0] = $g_asTroopShortNames[$iIndex]
				$rWTT[UBound($rWTT) - 1][1] = Abs($g_aiArmyCompTroops[$iIndex] - $aiQueueTroops[$iIndex])
				SetLog("    missing: " & $g_asTroopNames[$iIndex] & " x" & $rWTT[UBound($rWTT) - 1][1])
				ReDim $rWTT[UBound($rWTT) + 1][2]
			EndIf
		Next
		TrainUsingWhatToTrain($rWTT, True)
	EndIf
	Return True
EndFunc   ;==>CheckQueueTroopAndTrainRemain

Func CheckQueueSpellAndTrainRemain($ArmyCamp, $bDebug, $iUnbalancedSpell = 0)
	If $ArmyCamp[0] = $ArmyCamp[1] * 2 And ((ProfileSwitchAccountEnabled() And $g_abAccountNo[$g_iCurAccount] And $g_abDonateOnly[$g_iCurAccount]) Or $g_iCommandStop = 0) Then Return True ; bypass Donate account when full queue

	Local $iTotalQueue = 0
	If $bDebug Then SetLog("Checking spell queue: " & $ArmyCamp[0] & "/" & $ArmyCamp[1] * 2, $COLOR_DEBUG)

	Local $XQueueStart = FindxQueueStart()
	Local $aiQueueSpells = CheckQueueSpells(True, $bDebug, $XQueueStart)
	If Not IsArray($aiQueueSpells) Then Return False
	For $i = 0 To UBound($aiQueueSpells) - 1
		If $aiQueueSpells[$i] > 0 Then $iTotalQueue += $aiQueueSpells[$i] * $g_aiSpellSpace[$i]
	Next
	; Check block spell
	If $ArmyCamp[0] < $ArmyCamp[1] + $iTotalQueue Then
		SetLog("A big guy blocks our camp")
		Return False
	EndIf
	; check wrong queue
	Local $iUnbalancedSlot = 0, $iTypeOfSpell = 0
	For $i = 0 To UBound($aiQueueSpells) - 1
		If $aiQueueSpells[$i] > 0 Then $iTypeOfSpell += 1
		If $aiQueueSpells[$i] - $g_aiArmyCompSpells[$i] > 0 Then
			$iUnbalancedSlot += ($aiQueueSpells[$i] - $g_aiArmyCompSpells[$i]) * $g_aiSpellSpace[$i]
			If $iTypeOfSpell > 1 Or $iUnbalancedSlot > $iUnbalancedSpell * 2 Then ; more than 2 spell types
				SetLog("Some wrong spells in queue (" & $g_asSpellNames[$i] & " x" & $aiQueueSpells[$i] & "/" & $g_aiArmyCompSpells[$i] & ")")
				Return False
			EndIf
		EndIf
	Next
	If $ArmyCamp[0] < $ArmyCamp[1] * 2 Then
		; Train remain
		SetLog("Checking spells queue:")
		Local $rWTT[1][2] = [["Arch", 0]] ; what to train
		For $i = 0 To UBound($aiQueueSpells) - 1
			Local $iIndex = $g_aiBrewOrder[$i]
			If $aiQueueSpells[$iIndex] > 0 Then SetLog("  - " & $g_asSpellNames[$iIndex] & ": " & $aiQueueSpells[$iIndex] & "x")
			If $g_aiArmyCompSpells[$iIndex] - $aiQueueSpells[$iIndex] > 0 Then
				$rWTT[UBound($rWTT) - 1][0] = $g_asSpellShortNames[$iIndex]
				$rWTT[UBound($rWTT) - 1][1] = Abs($g_aiArmyCompSpells[$iIndex] - $aiQueueSpells[$iIndex])
				SetLog("    missing: " & $g_asSpellNames[$iIndex] & " x" & $rWTT[UBound($rWTT) - 1][1])
				ReDim $rWTT[UBound($rWTT) + 1][2]
			EndIf
		Next
		BrewUsingWhatToTrain($rWTT, True)

		If _Sleep(1000) Then Return
		Local $NewSpellCamp = GetCurrentArmy(95, 163)
		SetLog("Checking spell tab: " & $NewSpellCamp[0] & "/" & $NewSpellCamp[1] * 2 & ($NewSpellCamp[0] < $ArmyCamp[1] * 2 ? ". Top-up queue failed!" : ""))
		If Not $g_bIgnoreIncorrectSpellCombo Then
			If $NewSpellCamp[0] < $ArmyCamp[1] * 2 Then Return False
		EndIf
	EndIf
	Return True
EndFunc   ;==>CheckQueueSpellAndTrainRemain

Func FindxQueueStart()
	Local $xQueueStart = 777
	For $i = 0 To 10
		If _ColorCheck(_GetPixelColor(777 - $i * 60, 186, True), Hex(0xD7AFA9, 6), 20) Then ; first pink background from right to left
			$XQueueStart -= 60 * $i
			ExitLoop
		EndIf
	Next
	If $g_bDebugSetlog Then SetLog("xQueueStart = " & $xQueueStart, $COLOR_DEBUG)
	Return $xQueueStart
EndFunc

Func RemoveQueueTroop($iTroopIndex = 0, $Quantity = 1)
	SetLog("RemoveQueueTroop TroopIndex = " & $iTroopIndex & ", Quantity = " & $Quantity, $COLOR_DEBUG1)
	Local $YRemove = 200, $XOffset = 15
	Local $XQueueStart = FindxQueueStart()
	Local $Dir = @ScriptDir & "\imgxml\ArmyOverview\TroopsQueued"
	Local $aiQueueTroops = SearchArmy($Dir, 73, 205, $XQueueStart, 243, "Queue")
	;SearchArmy(@ScriptDir & "\imgxml\ArmyOverview\TroopsQueued", 73, 205, FindxQueueStart(), 243, "Queue")
	If Not IsArray($aiQueueTroops) Then Return 
	_ArraySort($aiQueueTroops, 0, 0, 0, 1) ;sort by x coord
	If $g_bDebugSetlog Then SetLog(_ArrayToString($aiQueueTroops))
	If Not $g_bRunState Then Return
	For $i = 0 To UBound($aiQueueTroops) - 1
		If Not $g_bRunState Then Return
		If TroopIndexLookup($aiQueueTroops[$i][0]) = $iTroopIndex Then 
			If $aiQueueTroops[$i][3] < $Quantity Then
				SetLog("Found x" & $aiQueueTroops[$i][3] & " " & $g_asTroopNames[$iTroopIndex], $COLOR_DEBUG)
				SetLog("  - Removing x" & $aiQueueTroops[$i][3] & " queued " & $g_asTroopNames[$iTroopIndex], $COLOR_ACTION)
				Click($aiQueueTroops[$i][1] + $XOffset, $YRemove, $aiQueueTroops[$i][3], $g_iTrainClickDelay, "Remove wrong queue")
				$Quantity -= $aiQueueTroops[$i][3]
				If _Sleep(1000) Then Return
				ContinueLoop ;troop quantity on slot less than what to remove
			Else ;troop quantity on slot same or more than what to remove
				SetLog("Found x" & $aiQueueTroops[$i][3] & " " & $g_asTroopNames[$iTroopIndex], $COLOR_DEBUG)
				SetLog("  - Removing x" & $Quantity & " queued " & $g_asTroopNames[$iTroopIndex], $COLOR_ACTION)
				Click($aiQueueTroops[$i][1] + $XOffset, $YRemove, $Quantity, $g_iTrainClickDelay, "Remove wrong queue")
				$Quantity -= $Quantity
			EndIf
			If $Quantity = 0 Then ExitLoop
		EndIf
	Next
EndFunc

;RemoveTrainTroop
;will remove troops that already trained (not on army camp yet)
;using trash button (to empty troops and re train remaining)
;bQueueOnly = True (will only remove excess troop)
;bQueueOnly = False (will use trash button)
Func RemoveTrainTroop($bQueueOnly = False)
	SetLog("RemoveTrainTroop, QueueOnly=" & String($bQueueOnly), $COLOR_DEBUG1)
	Local $aTrashCoord[2] = [525, 322]
	Local $YRemove = 200, $XOffset = 15, $XQueueStart
	If Not $g_bRunState Then Return
	If $bQueueOnly Then 
		$XQueueStart = FindxQueueStart()
		If $XQueueStart = 777 Then Return ;if we got default value of queue start, just exit. there is no excess train on queue troop
		Local $aiQueueTroops = CheckQueueTroops(True, True, $XQueueStart, True)
		If Not IsArray($aiQueueTroops) Then Return 
		_ArraySort($aiQueueTroops, 0, 0, 0, 2) ;sort by x coord
		If $g_bDebugSetlog Then SetLog(_ArrayToString($aiQueueTroops))
		If Not $g_bRunState Then Return
		For $i = 0 To UBound($aiQueueTroops) - 1
			If Not $g_bRunState Then Return	
			Local $iIndex = TroopIndexLookup($aiQueueTroops[$i][0])
			SetLog("  - Removing x" & $aiQueueTroops[$i][1] & " queued TrainTroop " & $g_asTroopNames[$iIndex], $COLOR_ACTION)
			Click($aiQueueTroops[$i][2] + $XOffset, $YRemove, $aiQueueTroops[$i][1], $g_iTrainClickDelay, "Remove wrong queue")
			If _Sleep(500) Then Return
		Next
	Else
		If _ColorCheck(_GetPixelColor($aTrashCoord[0], $aTrashCoord[1], True), Hex(0xCA1B1D, 6), 10) Then
			ClickP($aTrashCoord)
			If _Sleep(1000) Then Return
			If IsOKCancelPage() Then
				Click($aConfirmSurrender[0], $aConfirmSurrender[1])
			EndIf
			If _Sleep(500) Then Return
		EndIf
	EndIf
EndFunc

;return true if forced army capacity = total army space on train config
Func IsNormalTroopTrain()
	Local $bRet = True
	If Not $g_bRunState Then Return
	Local $iSpace = 0
	For $i = 0 To $eTroopCount - 1
		If Not $g_bRunState Then Return
		Local $troopIndex = $g_aiTrainOrder[$i]
		If $g_aiArmyCompTroops[$troopIndex] > 0 Then
			$iSpace += ($g_aiTroopSpace[$troopIndex] * $g_aiArmyCompTroops[$troopIndex])
		EndIf
	Next
	
	If $iSpace < $g_iTotalCampForcedValue Then $bRet = False
	If $g_bDebugSetlog Then SetLog("Space = " & $iSpace & ", ConfigTroopSpace = " & $g_iTotalCampForcedValue & ", bRet = " & String($bRet), $COLOR_DEBUG1)
	SetLog("IsNormalTroopTrain = " & String($bRet), $COLOR_DEBUG1)
	Return $bRet
EndFunc

Func ReTrainForSwitch()
	If Not OpenArmyOverview("ReTrainForSwitch") Then Return
	If Not OpenTroopsTab(False, "ReTrainForSwitch") Then Return
	If _Sleep(250) Then Return
	RemoveTrainTroop()
	If Not $g_bRunState Then Return
	TrainCustomArmy()
	If Not $g_bRunState Then Return
	TrainSiege()
	ClickAway()
	If _Sleep(500) Then Return
EndFunc