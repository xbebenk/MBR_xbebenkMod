
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
	If IsProblemAffect() Then Return
	Local $bDebug = $g_bDebugSetlogTrain Or $g_bDebugSetlog

	SetLog(" ====== Double Train ====== ", $COLOR_ACTION)
	
	; Troop
	DoubleTrainTroop($bDebug)
	If IsProblemAffect() Then Return
	; Spell
	DoubleTrainSpell($bDebug)
	If IsProblemAffect() Then Return
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
	
	If Not $bQueue Then RemoveTrainTroop(True) ;remove excess queue troops 
	
	If $g_bIgnoreIncorrectTroopCombo Then
		FillIncorrectTroopCombo("TrainFullTroop")
	EndIf
EndFunc   ;==>TrainFullTroop

Func FillIncorrectTroopCombo($caller = "Unknown")
	If Not $g_bIgnoreIncorrectTroopCombo Then Return
	SetLog("Train to Fill Incorrect Troop Combo", $COLOR_ACTION)
	
	If Not OpenTroopsTab(True, "FillIncorrectTroopCombo()") Then Return
	Local $CampOCR = GetCurrentTroop(95, 163)
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
		If _Sleep(500) Then Return
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
	If _Sleep(500) Then Return

	If Not $bQueue Then RemoveTrainSpell(True) ;remove excess queue Spells 
	
	If $g_bIgnoreIncorrectSpellCombo Then
		FillIncorrectSpellCombo("BrewFullSpell")
	EndIf
EndFunc   ;==>BrewFullSpell

Func FillIncorrectSpellCombo($caller = "Unknown")
	If Not $g_bIgnoreIncorrectSpellCombo Then Return
	SetLog("Train to Fill Incorrect Spell Combo", $COLOR_ACTION)
	
	If Not OpenSpellsTab(True, "FillIncorrectSpellCombo()") Then Return
	Local $SpellOCR = GetCurrentSpell(95, 163)
	If Not $g_bRunState Then Return
	
	If $g_bDebugSetlog Then SetLog("SpellOCR:" & _ArrayToString($SpellOCR) & " Called from : " & $caller)
	
	If $SpellOCR[0] = 0 Then ;no troop trained on 1st army 
		SetLog("no need to fill troop on 1st army", $COLOR_DEBUG1)
		Return
	EndIf
	
	If $SpellOCR[2] = 0 Or $SpellOCR[0] = ($SpellOCR[1] * 2) Then ;no troop trained on 2nd Army
		SetLog("no need to fill troop on 2nd Army", $COLOR_DEBUG1)
		Return
	EndIf
	
	Local $bQueue = $SpellOCR[2] < 0 ? True : False ;SpellOCR[2] read is remain space to train, negative value on 2nd army
	Local $SpellSpace = $bQueue ? (Number($SpellOCR[1]) * 2) - Number($SpellOCR[0]) : Number($SpellOCR[2])
	If $SpellSpace < 0 Then Return
	SetLog("SpellSpace = " & $SpellSpace, $COLOR_DEBUG)
	
	Local $FillSpellIndex = $g_iCmbFillIncorrectSpellCombo
	Local $sSpellName = $g_sCmbFICSpells[$FillSpellIndex][1]
	Local $iSpellIndex = TroopIndexLookup($g_sCmbFICSpells[$FillSpellIndex][0])
	Local $SpellQuantToFill = Floor($SpellSpace/$g_sCmbFICSpells[$FillSpellIndex][2])
	
	If $SpellQuantToFill > 0 Then
		If _Sleep(500) Then Return
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

Func GetCurrentTroop($x_start = 96, $y_start = 165)

	Local $aResult[4] = [0, 0, 0, 0]
	Local $iLenght, $x1, $iTroopCap = 0, $iTroopQuant = 0
	If Not $g_bRunState Then Return $aResult
	
	If QuickMIS("BC1", $g_sImgSlash, $x_start, $y_start, $x_start + 70, $y_start + 15) Then
		$iLenght = $g_iQuickMISX - $x_start
		$x1 = $g_iQuickMISX
	Else
		SetLog("DEBUG | ERROR on GetCurrentTroop Find Slash", $COLOR_ERROR)
		Return $aResult
	EndIf
	
	Local $iTroopCap = getArmyCapacityOnTrainTroops($x1, $y_start)
	
	Local $iTroopQuant = getArmyCapacityOnTrainTroops($x_start, $y_start, $iLenght)
	
	$iTroopQuant = StringReplace($iTroopQuant, "#", "")
	$iTroopCap = StringReplace($iTroopCap, "#", "")
	
	$aResult[0] = Number($iTroopQuant)
	$aResult[1] = Number($iTroopCap) / 2
	$aResult[2] = $aResult[1] - $aResult[0]
	$aResult[3] = Number($iTroopCap)
	
	Return $aResult

EndFunc   ;==>GetCurrentArmy

Func GetCurrentSpell($x_start = 96, $y_start = 165)

	Local $aResult[4] = [0, 0, 0, 0]
	Local $iLenght, $x1, $iSpellCap = 0, $iSpellQuant = 0
	If Not $g_bRunState Then Return $aResult
	
	If QuickMIS("BC1", $g_sImgSlash, $x_start, $y_start, $x_start + 40, $y_start + 15) Then
		$iLenght = $g_iQuickMISX - $x_start
		$x1 = $g_iQuickMISX
	Else
		SetLog("DEBUG | ERROR on GetCurrentSpell Find Slash", $COLOR_ERROR)
		Return $aResult
	EndIf
	
	Local $iSpellCap = getArmyCapacityOnTrainSpell($x1, $y_start)
	Local $iSpellQuant = getArmyCapacityOnTrainSpell($x_start, $y_start, $iLenght)
	
	$iSpellQuant = StringReplace($iSpellQuant, "#", "")
	$iSpellCap = StringReplace($iSpellCap, "#", "")
	
	$aResult[0] = Number($iSpellQuant)
	$aResult[1] = Number($iSpellCap) / 2
	$aResult[2] = $aResult[1] - $aResult[0]
	$aResult[3] = Number($iSpellCap)
	
	Return $aResult
EndFunc   ;==>GetCurrentSpell

Func GetCurrentSiege($x_start = 105, $y_start = 165)

	Local $aResult[4] = [0, 0, 0, 0]
	Local $iLenght, $x1, $iSiegeCap = 0, $iSiegeQuant = 0
	If Not $g_bRunState Then Return $aResult
	
	If QuickMIS("BC1", $g_sImgSlash, $x_start, $y_start, $x_start + 40, $y_start + 15) Then
		$iLenght = $g_iQuickMISX - $x_start
		$x1 = $g_iQuickMISX
	Else
		SetLog("DEBUG | ERROR on GetCurrentSiege Find Slash", $COLOR_ERROR)
		Return $aResult
	EndIf
	
	Local $iSiegeCap = getArmyCapacityOnTrainTroops($x1, $y_start)
	Local $iSiegeQuant = getArmyCapacityOnTrainTroops($x_start, $y_start, $iLenght)
	
	$iSiegeQuant = StringReplace($iSiegeQuant, "#", "")
	$iSiegeCap = StringReplace($iSiegeCap, "#", "")
	
	$aResult[0] = Number($iSiegeQuant)
	$aResult[1] = Number($iSiegeCap) / 2
	$aResult[2] = $aResult[1] - $aResult[0]
	$aResult[3] = Number($iSiegeCap)
	
	Return $aResult
EndFunc   ;==>GetCurrentSpell

Func CheckQueueTroopAndTrainRemain($ArmyCamp = Default) ;GetCurrentTroop(95, 163)
	If Not OpenTroopsTab(True, "CheckQueueTroopAndTrainRemain()") Then Return
	If $ArmyCamp = Default Then $ArmyCamp = GetCurrentTroop(95, 163)
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
	
	Local $aiQueueTroops = CheckQueueTroops(True, True, FindxQueueStart())
	If Not IsArray($aiQueueTroops) Then Return False
	For $i = 0 To UBound($aiQueueTroops) - 1
		If $aiQueueTroops[$i] > 0 Then 
			$iTotalQueue += $aiQueueTroops[$i] * $g_aiTroopSpace[$i]
			SetLog($g_asTroopNames[$i] & " : " & $aiQueueTroops[$i] & "x" & $g_aiTroopSpace[$i] & ", TotalQueue=" & $iTotalQueue, $COLOR_DEBUG1)
		EndIf
	Next
	
	;check wrong camp utilization
	If $ArmyCamp[1] <> $g_iTotalCampSpace Then 
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
		RemoveQueueTroop(0, 1, True)
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
		$ArmyCamp = GetCurrentTroop(95, 163)
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

Func CheckQueueSpellAndTrainRemain($ArmyCamp = Default, $bDebug = False)
	If Not OpenSpellsTab(True, "CheckQueueTroopAndTrainRemain()") Then Return
	If $ArmyCamp = Default Then $ArmyCamp = GetCurrentSpell(95, 163)
	If Not $g_bRunState Then Return
	If $ArmyCamp[0] = $ArmyCamp[1] * 2 And ((ProfileSwitchAccountEnabled() And $g_abAccountNo[$g_iCurAccount] And $g_abDonateOnly[$g_iCurAccount]) Or $g_iCommandStop = 0) Then Return True ; bypass Donate account when full queue
	
	Local $iTotalQueue = 0
	SetLog("Checking spell queue: " & $ArmyCamp[0] & "/" & $ArmyCamp[1] * 2, $COLOR_DEBUG1)
	If $g_bTrainPreviousArmy Then 
		While _ColorCheck(_GetPixelColor(265, 197, True), Hex(0xFFFFFF, 6), 20, Default, "Army Added Message")
			If Not $g_bRunState Then Return
			SetLog("Army Added Message Blocking, Waiting until it's gone", $COLOR_INFO)
			If _Sleep(500) Then Return
		WEnd
	EndIf
	
	;CheckQueueSpells(True, True, FindxQueueStart())
	Local $aiQueueSpells = CheckQueueSpells(True, $bDebug, FindxQueueStart())
	If Not IsArray($aiQueueSpells) Then Return False
	For $i = 0 To UBound($aiQueueSpells) - 1
		If $aiQueueSpells[$i] > 0 Then 
			$iTotalQueue += $aiQueueSpells[$i] * $g_aiSpellSpace[$i]
			SetLog($g_asSpellNames[$i] & " : " & $aiQueueSpells[$i] & "x" & $g_aiSpellSpace[$i] & ", TotalQueue=" & $iTotalQueue, $COLOR_DEBUG1)
		EndIf
	Next
	
	;check wrong camp utilization
	If $ArmyCamp[1] <> $g_iTotalSpellValue Then 
		;SetLog("$ArmyCamp[1] <> $g_iTotalSpellValue", $COLOR_ERROR)
		Local $countSpell = 0
		For $i = 0 To UBound($g_aiArmyCompSpells) - 1
			$countSpell += $g_aiArmyCompSpells[$i]
		Next
		If $countSpell = 1 Then Return False ;only 1 Spell on train setting, user utilizing fill incorrect combo Spell
	EndIf
	
	; Check block troop
	If $ArmyCamp[0] < $ArmyCamp[1] + $iTotalQueue Then
		SetLog("$ArmyCamp[0] = " & $ArmyCamp[0] & " < $ArmyCamp[1] + $iTotalQueue = " & $ArmyCamp[1] + $iTotalQueue)
		SetLog("A big guy blocks our camp")
		RemoveQueueSpell(0, 1, True)
		Return False
	EndIf
	
	; check wrong queue
	Local $iExcessSpell = 0, $bExcessSpell = False
	For $i = 0 To UBound($aiQueueSpells) - 1
		If Not $g_bRunState Then Return
		$iExcessSpell = $aiQueueSpells[$i] - $g_aiArmyCompSpells[$i]
		If $iExcessSpell > 0 Then
			SetLog("  - " & $g_asSpellNames[$i] & " x" & $aiQueueSpells[$i] & ", excess queue : " & $iExcessSpell, $COLOR_ACTION)
			$aiQueueSpells[$i] -= $iExcessSpell
			$bExcessSpell = True
			RemoveQueueSpell($i, $iExcessSpell)
			If _Sleep(500) Then Return
		EndIf
	Next
	
	If $bExcessSpell Then 
		If _Sleep(1500) Then Return
		$ArmyCamp = GetCurrentTroop(95, 163)
		SetLog("After excess troop queue: " & $ArmyCamp[0] & "/" & $ArmyCamp[1] * 2, $COLOR_DEBUG1)
		;Return True
	EndIf
	
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
		Local $NewSpellCamp = GetCurrentTroop(95, 163)
		SetLog("Checking spell tab: " & $NewSpellCamp[0] & "/" & $NewSpellCamp[1] * 2 & ($NewSpellCamp[0] < $ArmyCamp[1] * 2 ? ". Top-up queue failed!" : ""))
		If Not $g_bIgnoreIncorrectSpellCombo Then
			If $NewSpellCamp[0] < $ArmyCamp[1] * 2 Then Return False
		EndIf
	EndIf
	Return True
EndFunc   ;==>CheckQueueSpellAndTrainRemain

Func FindxQueueStart($iSearchWidth = 59)
	Local $xStart = 777, $xQueueStart = 0
	Local $x1 = $xStart - $iSearchWidth
	Local $x2 = $xStart
	
	For $i = 0 To 100
		If $g_bDebugSetlog Then SetLog("[" & $i & "] x1=" & $x1 & ", x2=" & $x2, $COLOR_DEBUG1)
		If $x1 < 120 Then 
			If $g_bDebugSetlog Then SetLog("Pink background not found", $COLOR_ERROR)
			Return $x1
		EndIf
		
		If _PixelSearch($x1 + 2, 185, $x1 + 3, 186, Hex(0xD7AFA9, 6), 20, True, "FindxQueueStart") Then ; first pink background from right to left
			$xQueueStart = $x2
			ExitLoop
		Else
			$x1 -= $iSearchWidth + 1
			$x2 = $x1 + $iSearchWidth
		EndIf
	Next
	If $g_bDebugSetlog Then SetLog("xQueueStart = " & $xQueueStart, $COLOR_DEBUG)
	Return $xQueueStart
EndFunc

Func RemoveQueueTroop($iTroopIndex = 0, $Quantity = 1, $bRightToLeft = False)
	SetLog("RemoveQueueTroop TroopIndex = " & $iTroopIndex & ", Quantity = " & $Quantity, $COLOR_DEBUG1)
	If Not OpenTroopsTab(True, "RemoveQueueTroop") Then Return
	Local $YRemove = 200, $XOffset = 15
	Local $aiQueueTroops = SearchArmy($g_sImgArmyOverviewTroopsQueued, 73, 205, FindxQueueStart(), 243, "Queue")
	
	If Not IsArray($aiQueueTroops) Then Return 
	If $bRightToLeft Then 
		_ArraySort($aiQueueTroops, 1, 0, 0, 1) ;sort by x coord descending
	Else
		_ArraySort($aiQueueTroops, 0, 0, 0, 1) ;sort by x coord ascending
	EndIf
	
	If $g_bDebugSetlog Then SetLog(_ArrayToString($aiQueueTroops))
	If Not $g_bRunState Then Return
	For $i = 0 To UBound($aiQueueTroops) - 1
		If Not $g_bRunState Then Return
		
		Local $iIndex = TroopIndexLookup($aiQueueTroops[$i][0])
		If $bRightToLeft And $i = 0 Then ;only remove one most right spell
			SetLog("Remove Big Guy on queue", $COLOR_DEBUG1)
			SetLog("Found x" & $aiQueueTroops[$i][3] & " " & $g_asTroopNames[$iIndex], $COLOR_DEBUG)
			SetLog("  - Removing x" & $aiQueueTroops[$i][3] & " queued " & $g_asTroopNames[$iIndex], $COLOR_ACTION)
			Click($aiQueueTroops[$i][1] + $XOffset, $YRemove, $aiQueueTroops[$i][3], $g_iTrainClickDelay, "Remove Big Guy on queue")
			Return True
		EndIf
		
		If $iIndex = $iTroopIndex Then 
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

Func RemoveQueueSpell($iSpellIndex = 0, $Quantity = 1, $bRightToLeft = False)
	SetLog("RemoveQueueSpell SpellIndex = " & $iSpellIndex & ", Quantity = " & $Quantity, $COLOR_DEBUG1)
	If Not OpenSpellsTab(True, "RemoveQueueSpell") Then Return
	Local $YRemove = 200, $XOffset = 15
	Local $aiQueueSpells = SearchArmy($g_sImgArmyOverviewSpellsQueued, 73, 205, FindxQueueStart(), 243, "Queue")
	
	If Not IsArray($aiQueueSpells) Then Return 
	If $bRightToLeft Then 
		_ArraySort($aiQueueSpells, 1, 0, 0, 1) ;sort by x coord descending
	Else
		_ArraySort($aiQueueSpells, 0, 0, 0, 1) ;sort by x coord ascending
	EndIf
	
	If $g_bDebugSetlog Then SetLog(_ArrayToString($aiQueueSpells))
	If Not $g_bRunState Then Return
	For $i = 0 To UBound($aiQueueSpells) - 1
		If Not $g_bRunState Then Return
		Local $iIndex = TroopIndexLookup($aiQueueSpells[$i][0]) - $eLSPell
		
		If $bRightToLeft And $i = 0 Then ;only remove one most right spell
			SetLog("Remove Big Guy on queue", $COLOR_DEBUG1)
			SetLog("Found x" & $aiQueueSpells[$i][3] & " " & $g_asSpellNames[$iIndex], $COLOR_DEBUG)
			SetLog("  - Removing x" & $aiQueueSpells[$i][3] & " queued " & $g_asSpellNames[$iIndex], $COLOR_ACTION)
			Click($aiQueueSpells[$i][1] + $XOffset, $YRemove, $aiQueueSpells[$i][3], $g_iTrainClickDelay, "Remove Big Guy on queue")
			Return True
		EndIf
		
		If $iIndex = $iSpellIndex Then 
			If $aiQueueSpells[$i][3] < $Quantity Then
				SetLog("Found x" & $aiQueueSpells[$i][3] & " " & $g_asSpellNames[$iSpellIndex], $COLOR_DEBUG)
				SetLog("  - Removing x" & $aiQueueSpells[$i][3] & " queued " & $g_asSpellNames[$iSpellIndex], $COLOR_ACTION)
				Click($aiQueueSpells[$i][1] + $XOffset, $YRemove, $aiQueueSpells[$i][3], $g_iTrainClickDelay, "Remove wrong queue")
				$Quantity -= $aiQueueSpells[$i][3]
				If _Sleep(1000) Then Return
				ContinueLoop ;Spell quantity on slot less than what to remove
			Else ;Spell quantity on slot same or more than what to remove
				SetLog("Found x" & $aiQueueSpells[$i][3] & " " & $g_asSpellNames[$iSpellIndex], $COLOR_DEBUG)
				SetLog("  - Removing x" & $Quantity & " queued " & $g_asSpellNames[$iSpellIndex], $COLOR_ACTION)
				Click($aiQueueSpells[$i][1] + $XOffset, $YRemove, $Quantity, $g_iTrainClickDelay, "Remove wrong queue")
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
	Local $YRemove = 200, $XOffset = 15, $XQueueStart
	If Not $g_bRunState Then Return
	If $bQueueOnly Then 
		For $i = 1 To 2
			$XQueueStart = FindxQueueStart()
			If $XQueueStart = 777 Then Return ;if we got default value of queue start, just exit. there is no excess train on queue troop
			Local $aiQueueTroops = CheckQueueTroops(True, True, $XQueueStart, True)
			If Not IsArray($aiQueueTroops) Then Return 
			_ArraySort($aiQueueTroops, 0, 0, 0, 2) ;sort by x coord
			If $g_bDebugSetlog Then SetLog(_ArrayToString($aiQueueTroops))
			If Not $g_bRunState Then Return
			For $i = 0 To UBound($aiQueueTroops) - 1
				If Number($aiQueueTroops[$i][1]) = 0 Then ContinueLoop
				If Not $g_bRunState Then Return	
				Local $iIndex = TroopIndexLookup($aiQueueTroops[$i][0])
				SetLog("  - Removing x" & $aiQueueTroops[$i][1] & " queued TrainTroop " & $g_asTroopNames[$iIndex], $COLOR_ACTION)
				Click($aiQueueTroops[$i][2] + $XOffset, $YRemove, $aiQueueTroops[$i][1], $g_iTrainClickDelay, "Remove wrong queue")
				If _Sleep(500) Then Return
			Next
			If _Sleep(500) Then Return
		Next
	Else
		If _PixelSearch(525, 323, 526, 324, Hex(0xC81C1D, 6), 20, True, "RemoveTrainTroop") Then
			Click(525, 320, 1, 0, "RemoveTrainTroop : Trash")
			If _Sleep(1000) Then Return
			If IsOKCancelPage() Then
				Click($aConfirmSurrender[0], $aConfirmSurrender[1])
			EndIf
			If _Sleep(500) Then Return
		EndIf
		
		If _PixelSearch(638, 323, 639, 324, Hex(0xC81C1D, 6), 20, True, "RemoveTrainTroop") Then
			Click(638, 320, 1, 0, "RemoveTrainTroop : Trash")
			If _Sleep(1000) Then Return
			If IsOKCancelPage() Then
				Click($aConfirmSurrender[0], $aConfirmSurrender[1])
			EndIf
			If _Sleep(500) Then Return
		EndIf
	EndIf
EndFunc

;RemoveTrainSpell
;will remove Spells that already trained (not on army camp yet)
;using trash button (to empty Spells and re train remaining)
;bQueueOnly = True (will only remove excess Spell)
;bQueueOnly = False (will use trash button)
Func RemoveTrainSpell($bQueueOnly = False)
	SetLog("RemoveTrainSpell, QueueOnly=" & String($bQueueOnly), $COLOR_DEBUG1)
	Local $aTrashCoord[2] = [525, 322]
	Local $YRemove = 200, $XOffset = 15, $XQueueStart
	If Not $g_bRunState Then Return
	If $bQueueOnly Then 
		For $i = 1 To 2
			$XQueueStart = FindxQueueStart()
			If $XQueueStart = 777 Then Return ;if we got default value of queue start, just exit. there is no excess train on queue Spell
			Local $aiQueueSpells = CheckQueueSpells(True, True, $XQueueStart, True)
			If Not IsArray($aiQueueSpells) Then Return 
			_ArraySort($aiQueueSpells, 0, 0, 0, 2) ;sort by x coord
			If $g_bDebugSetlog Then SetLog(_ArrayToString($aiQueueSpells))
			If Not $g_bRunState Then Return
			For $i = 0 To UBound($aiQueueSpells) - 1
				If Number($aiQueueSpells[$i][1]) = 0 Then ContinueLoop
				If Not $g_bRunState Then Return	
				Local $iIndex = TroopIndexLookup($aiQueueSpells[$i][0])
				SetLog("  - Removing x" & $aiQueueSpells[$i][1] & " queued TrainSpell " & GetTroopName($iIndex, $aiQueueSpells[$i][1]), $COLOR_ACTION)
				Click($aiQueueSpells[$i][2] + $XOffset, $YRemove, $aiQueueSpells[$i][1], $g_iTrainClickDelay, "Remove wrong queue")
				If _Sleep(500) Then Return
			Next
			If _Sleep(500) Then Return
		Next
	Else
		If _PixelSearch(525, 323, 526, 324, Hex(0xC81C1D, 6), 20, True, "RemoveTrainSpell") Then
			Click(525, 320, 1, 0, "RemoveTrainSpell : Trash")
			If _Sleep(1000) Then Return
			If IsOKCancelPage() Then
				Click($aConfirmSurrender[0], $aConfirmSurrender[1])
			EndIf
			If _Sleep(500) Then Return
		EndIf
		
		If _PixelSearch(638, 323, 639, 324, Hex(0xC81C1D, 6), 20, True, "RemoveTrainSpell") Then
			Click(638, 320, 1, 0, "RemoveTrainSpell : Trash")
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
			If $g_bDebugSetlog Then SetLog($g_asTroopNames[$troopIndex] & " : space:" & $g_aiTroopSpace[$troopIndex] & " x compo:" & $g_aiArmyCompTroops[$troopIndex] & " spacetotal = " & $iSpace, $COLOR_DEBUG1)
		EndIf
	Next
	
	If $iSpace < $g_iTotalCampForcedValue Then $bRet = False
	If $g_bDebugSetlog Then SetLog("Space = " & $iSpace & ", ConfigTroopSpace = " & $g_iTotalCampForcedValue & ", bRet = " & String($bRet), $COLOR_DEBUG1)
	SetLog("IsNormalTroopTrain = " & String($bRet), $COLOR_DEBUG1)
	Return $bRet
EndFunc

;return true if forced army capacity = total army space on train config
Func IsNormalSpellTrain()
	Local $bRet = True
	If Not $g_bRunState Then Return
	Local $iSpace = 0
	For $i = 0 To $eSpellCount - 1
		If Not $g_bRunState Then Return
		Local $spellIndex = $g_aiBrewOrder[$i]
		If $g_aiArmyCompSpells[$spellIndex] > 0 Then
			$iSpace += ($g_aiSpellSpace[$spellIndex] * $g_aiArmyCompSpells[$spellIndex])
			If $g_bDebugSetlog Then SetLog($g_asSpellNames[$spellIndex] & " : space:" & $g_aiSpellSpace[$spellIndex] & " x compo:" & $g_aiArmyCompSpells[$spellIndex] & " spacetotal = " & $iSpace, $COLOR_DEBUG1)
		EndIf
	Next
	
	If $iSpace < $g_iTotalSpellValue Then $bRet = False
	If $g_bDebugSetlog Then SetLog("Space = " & $iSpace & ", ConfigSpellSpace = " & $g_iTotalSpellValue & ", bRet = " & String($bRet), $COLOR_DEBUG1)
	SetLog("IsNormalSpellTrain = " & String($bRet), $COLOR_DEBUG1)
	Return $bRet
EndFunc

Func ReTrainForSwitch()
	If Not OpenArmyOverview("ReTrainForSwitch") Then Return
	If Not OpenTroopsTab(False, "ReTrainForSwitch") Then Return
	If _Sleep(250) Then Return
	RemoveTrainTroop()
	If Not $g_bRunState Then Return
	If Not OpenSpellsTab(False, "ReTrainForSwitch") Then Return
	If _Sleep(250) Then Return
	RemoveTrainSpell()
	If Not $g_bRunState Then Return
	TrainCustomArmy()
	If Not $g_bRunState Then Return
	TrainSiege()
	ClickAway()
	If _Sleep(500) Then Return
EndFunc

Func DoubleTrainTroop($bDebug = False)
	
	If Not OpenTroopsTab(False, "DoubleTrain()") Then Return
	If _Sleep(250) Then Return
	
	Local $tmpCamp = 999, $TroopCamp
	
	While 1
		If _Sleep(800) Then Return
		$TroopCamp = GetCurrentTroop(95, 163)
		If IsProblemAffect() Then Return
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
				;If IsNormalTroopTrain() Then
				;	If Not CheckQueueTroopAndTrainRemain() Then ExitLoop
				;EndIf
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
					RemoveExtraTroops($aWhatToTrain) ;check and remove excess trained army
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
					RemoveTrainTroop(True) ;remove queue army
					If Not CheckQueueTroopAndTrainRemain() Then ContinueLoop ;train 2nd Army
					FillIncorrectTroopCombo("2nd Army")
					ExitLoop
				Else
					FillIncorrectTroopCombo("2nd Army") 
				EndIf
		EndSelect
	WEnd
EndFunc

Func DoubleTrainSpell($bDebug = False)
	Local $tmpSpell = 999, $SpellCamp
	If Not OpenSpellsTab(False, "DoubleTrain()") Then Return
	While 1
		If _Sleep(500) Then Return
		$SpellCamp = GetCurrentSpell(95, 163)
		If IsProblemAffect() Then Return
		If _Sleep(50) Then Return
		If Not $g_bRunState Then Return
		
		If $g_bDebugSetlog Then SetDebugLog(_ArrayToString($SpellCamp))
		SetLog("Checking Spell tab: " & $SpellCamp[0] & "/" & $SpellCamp[1] * 2 & " remain space:" & $SpellCamp[2], $COLOR_DEBUG1)
		If $tmpSpell = $SpellCamp[2] Then ExitLoop
		$tmpSpell = $SpellCamp[2]
		Select
			Case $SpellCamp[1] = 0
				SetLog("$SpellCamp[1] = 0", $COLOR_DEBUG1)
				ExitLoop
			Case $SpellCamp[0] = ($SpellCamp[1] * 2)
				SetLog("Cur = Max", $COLOR_DEBUG1)
				If IsNormalSpellTrain() Then
					If Not CheckQueueSpellAndTrainRemain() Then ContinueLoop
				EndIf
			Case $SpellCamp[0] = 0 ; 0/22 (empty spell camp)
				SetLog("SpellCamp[0] = 0", $COLOR_DEBUG1)
				BrewFullSpell() ;train 1st Army
			Case $SpellCamp[2] = 0 ;11/22 (empty spell queue)
				SetLog("SpellCamp[2] = 0", $COLOR_DEBUG1)
				BrewFullSpell(True) ;train 2nd Army
			Case $SpellCamp[2] > 0 ; 5/22 (1st army partially trained)
				SetLog("SpellCamp[2] > 0", $COLOR_DEBUG1)
				If IsNormalSpellTrain() Then
					RemoveTrainSpell()
					Local $aWhatToTrain = WhatToTrain(False, False)
					SetLog("New spell Fill way", $COLOR_DEBUG1)
					BrewUsingWhatToTrain($aWhatToTrain) ;should only train 1st army
					RemoveTrainSpell(True) ;recheck trained army, remove excess queued army (leave only 1st army)
					FillIncorrectSpellCombo("1st Army")
				Else
					FillIncorrectSpellCombo("1st Army")
				EndIf
			Case $SpellCamp[0] = $SpellCamp[1] ;11/22 (1st army fully trained)
				SetLog($SpellCamp[0] & " = " & $SpellCamp[1], $COLOR_DEBUG1)
				BrewFullSpell(True) ;train 2nd Army
			Case $SpellCamp[0] > $SpellCamp[1] ;15/22 (2nd army partially trained)
				SetLog($SpellCamp[0] & " > " & $SpellCamp[1], $COLOR_DEBUG1)
				If IsNormalSpellTrain() Then
					RemoveTrainSpell(True) ;remove queue spell
					If Not CheckQueueSpellAndTrainRemain() Then ContinueLoop
					FillIncorrectSpellCombo("2nd Army")
					ExitLoop
				Else
					FillIncorrectSpellCombo("2nd Army") 
				EndIf
		EndSelect
	WEnd
EndFunc