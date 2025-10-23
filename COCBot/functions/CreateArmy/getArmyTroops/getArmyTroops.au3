; #FUNCTION# ====================================================================================================================
; Name ..........: getArmyTroops
; Description ...: Obtain the current trained Troops
; Syntax ........: getArmyTroops()
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
#include <Array.au3>
#include <MsgBoxConstants.au3>


Func getArmyTroops($bOpenArmyWindow = False, $bCloseArmyWindow = False, $bCheckWindow = False, $bSetLog = True, $bNeedCapture = True)

	If $g_bDebugSetlogTrain Then SetLog("getArmyTroops():", $COLOR_DEBUG)

	If Not $bOpenArmyWindow Then
		If $bCheckWindow And Not IsTrainPage() Then ; check for train page
			SetError(1)
			Return ; not open, not requested to be open - error.
		EndIf
	ElseIf $bOpenArmyWindow Then
		If Not OpenArmyOverview("getArmyTroops()") Then
			SetError(2)
			Return ; not open, requested to be open - error.
		EndIf
		If _Sleep($DELAYCHECKARMYCAMP5) Then Return
	EndIf
	
	CheckReceivedTroops()
	;SearchArmy($g_sImgArmyOverviewTroops, 80, 211, 520, 270, "Troops")
	Local $sTroopDiamond = GetDiamondFromRect("80, 211, 520, 270") ; Contains iXStart, $iYStart, $iXEnd, $iYEnd
	If $g_bDebugFuncTime Then StopWatchStart("findMultiple, \imgxml\ArmyOverview\Troops")
	Local $aCurrentTroops = findMultiple(@ScriptDir & "\imgxml\ArmyOverview\Troops", $sTroopDiamond, $sTroopDiamond, 0, 1000, 0, "objectname,objectpoints", $bNeedCapture) ; Returns $aCurrentTroops[index] = $aArray[2] = ["TroopShortName", CordX,CordY]
	If $g_bDebugFuncTime Then StopWatchStopLog()

	Local $aTempTroopArray, $aTroopCoords
	Local $iTroopIndex = -1, $iDropTrophyIndex = -1
	Local $aCurrentTroopsEmpty[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ; Local Copy to reset Troops Array
	Local $aTroopsForTropyDropEmpty[10][2] = [["Barb", 0], ["SBarb", 0], ["Arch", 0], ["Giant", 0], ["Wall", 0], ["Gobl", 0], ["Mini", 0], ["Ball", 0], ["Wiza", 0], ["SMini", 0]] ; Local Copy to reset Troop Drop Trophy Array
	
	$g_aiCurrentTroops = $aCurrentTroopsEmpty ; Reset Current Troops Array
	$g_avDTtroopsToBeUsed = $aTroopsForTropyDropEmpty ; Reset Drop Trophy Troops Array
	If UBound($aCurrentTroops, 1) >= 1 Then
		For $i = 0 To UBound($aCurrentTroops, 1) - 1 ; Loop through found Troops
			$aTempTroopArray = $aCurrentTroops[$i] ; Declare Array to Temp Array
			$iTroopIndex = TroopIndexLookup($aTempTroopArray[0], "getArmyTroops()") ; Get the Index of the Troop from the ShortName
			$aTroopCoords = StringSplit($aTempTroopArray[1], ",", $STR_NOCOUNT) ; Split the Coordinates where the Troop got found into X and Y
			If $iTroopIndex = -1 Then ContinueLoop
			$g_aiCurrentTroops[$iTroopIndex] = Number(getBarracksNewTroopQuantity(Slot($aTroopCoords[0], $aTroopCoords[1]), 195, $bNeedCapture)) ; Get The Quantity of the Troop, Slot() Does return the exact spot to read the Number from

			$iDropTrophyIndex = _ArraySearch($g_avDTtroopsToBeUsed, $aTempTroopArray[0]) ; Search the Troops ShortName in the Drop Trophy Global to check if it is a Drop Trophy Troop
			If $iDropTrophyIndex <> -1 Then $g_avDTtroopsToBeUsed[$iDropTrophyIndex][1] += $g_aiCurrentTroops[$iTroopIndex] ; If there was a Match in the Array then add the Troop Quantity to it
		Next
	EndIf

	; Just a good log from left to right
	Local $iCount = 0, $sTroopName = ""
	For $i = 0 To UBound($g_aiCurrentTroops) - 1
		$iCount = $g_aiCurrentTroops[$i]
		$sTroopName = $iCount > 1 ? $g_asTroopNamesPlural[$i] : $g_asTroopNames[$g_aiCurrentTroops[$i]]
		If $g_aiCurrentTroops[$i] > 0 And $bSetLog Then SetLog(" - " & $iCount & " " & $sTroopName & " Available", $COLOR_SUCCESS)
	Next

	If $bCloseArmyWindow Then
		ClickAway()
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf
EndFunc   ;==>getArmyTroops