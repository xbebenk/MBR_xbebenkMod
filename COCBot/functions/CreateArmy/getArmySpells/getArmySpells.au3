; #FUNCTION# ====================================================================================================================
; Name ..........: getArmySpells
; Description ...: Obtain the current brewed Spells
; Syntax ........: getArmySpells()
; Parameters ....:
; Return values .:
; Author ........: Fliegerfaust(11-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func getArmySpells($bOpenArmyWindow = False, $bCloseArmyWindow = False, $bCheckWindow = False, $bSetLog = True, $bNeedCapture = True)

	If $g_bDebugSetlogTrain Then SetLog("getArmySpells():", $COLOR_DEBUG)

	If Not $bOpenArmyWindow Then
		If $bCheckWindow And Not IsTrainPage() Then ; check for train page
			SetError(1)
			Return ; not open, not requested to be open - error.
		EndIf
	ElseIf $bOpenArmyWindow Then
		If Not OpenArmyOverview("getArmySpells()") Then
			SetError(2)
			Return ; not open, requested to be open - error.
		EndIf
		If _Sleep($DELAYCHECKARMYCAMP5) Then Return
	EndIf

	Local $sSpellDiamond = GetDiamondFromRect("77,337,516,394")
	Local $aCurrentSpells = findMultiple(@ScriptDir & "\imgxml\ArmyOverview\Spells", $sSpellDiamond, $sSpellDiamond, 0, 1000, 0, "objectname,objectpoints", $bNeedCapture) ; Returns $aCurrentSpells[index] = $aArray[2] = ["SpellShortName", CordX,CordY]

	Local $aTempSpellArray, $aSpellCoords
	Local $iSpellIndex = -1
	Local $aCurrentSpellsEmpty[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ; Local Copy to reset Spells Array
	
	$g_aiCurrentSpells = $aCurrentSpellsEmpty ; Reset Current Spells Array

	If UBound($aCurrentSpells, 1) >= 1 Then
		For $i = 0 To UBound($aCurrentSpells, 1) - 1 ; Loop through found Spells
			$aTempSpellArray = $aCurrentSpells[$i] ; Declare Array to Temp Array
			$iSpellIndex = TroopIndexLookup($aTempSpellArray[0], "getArmySpells()") - $eLSpell ; Get the Index of the Spell from the ShortName
			If $iSpellIndex < 0 Then ContinueLoop
			$aSpellCoords = StringSplit($aTempSpellArray[1], ",", $STR_NOCOUNT) ; Split the Coordinates where the Spell got found into X and Y
			If UBound($aSpellCoords) < 2  Then ContinueLoop
			$g_aiCurrentSpells[$iSpellIndex] = Number(getBarracksNewTroopQuantity(Slot($aSpellCoords[0], $aSpellCoords[1]), 320, $bNeedCapture)) ; Get The Quantity of the Spell, Slot() Does return the exact spot to read the Number from
		Next
	EndIf
	; Just a good log from left to right
	Local $iCount = 0, $sSpellName = ""
	For $i = 0 To UBound($g_aiCurrentSpells) - 1
		$iCount = $g_aiCurrentSpells[$i]
		$sSpellName = $iCount > 1 ? $g_asSpellNames[$i] & " Spells" : $g_asSpellNames[$i] & " Spell"
		If $iCount > 0 And $bSetLog Then SetLog(" - " & $iCount & " " & $sSpellName & " Brewed", $COLOR_SUCCESS)
	Next

	If $bCloseArmyWindow Then
		ClickAway()
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf
EndFunc   ;==>getArmySpells
