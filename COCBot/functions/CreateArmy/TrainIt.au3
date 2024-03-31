; #FUNCTION# ====================================================================================================================
; Name ..........: TrainIt
; Description ...: validates and sends click in barrack window to actually train troops
; Syntax ........: TrainIt($iIndex[, $howMuch = 1[, $iSleep = 400]])
; Parameters ....: $iIndex           - index of troop/spell to train from the Global Enum $eBarb, $eArch, ..., $eHaSpell, $eSkSpell
;                  $howMuch          - [optional] how many to train Default is 1.
;                  $iSleep           - [optional] delay value after click. Default is 400.
; Return values .: None
; Author ........:
; Modified ......: KnowJack(07-2015), MonkeyHunter (05-2016), ProMac (01-2018), CodeSlinger69 (01-2018)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: GetTrainPos, GetFullName, GetGemName
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func TrainIt($iIndex, $iQuantity = 1, $iSleep = 400)
	If $g_bDebugSetlogTrain Then SetLog("Func TrainIt $iIndex=" & $iIndex & " $howMuch=" & $iQuantity & " $iSleep=" & $iSleep, $COLOR_DEBUG)
	
	For $i = 1 To 5 ; Do
		If Not $g_bRunState Then Return
		Local $aTrainPos = GetImageToUse($iIndex)
		If IsArray($aTrainPos) And $aTrainPos[0] <> -1 Then
			CorrectYCoord($aTrainPos)
			;SetLog(_ArrayToString($aTrainPos))
			TrainClickP($aTrainPos, $iQuantity, GetTroopName($iIndex))
			If _Sleep($iSleep) Then Return
			Return True
		Else
			If UBound($aTrainPos) > 0 And $aTrainPos[0] = -1 Then
				If $i > 1 Then 
					SetLog("TrainIt troop position " & GetTroopName($iIndex) & " did not find icon", $COLOR_ERROR)
					For $x In $g_iCmbSuperTroops
						If $x = $iIndex Then
							SetLog(GetTroopName($iIndex) & " need boost first", $COLOR_INFO)
							TrainPreviousArmy(False, True)
						EndIf
					Next
				EndIf
			Else
				SetLog("Impossible happened? TrainIt troop position " & GetTroopName($iIndex) & " did not return array", $COLOR_ERROR)
			EndIf
		EndIf
	Next ; Until $iErrors = 0
EndFunc   ;==>TrainIt

Func CorrectYCoord(ByRef $aTrainPos)
	If $aTrainPos[1] > 433 Then $aTrainPos[1] = 488
	If $aTrainPos[1] < 433 Then $aTrainPos[1] = 400
EndFunc

Func GetImageToUse(Const $iIndex)
	If $g_bDebugSetlogTrain Then SetLog("GetImageToUse($iIndex=" & $iIndex & ")", $COLOR_DEBUG)

	; Get the Image path to search
	If ($iIndex >= $eBarb And $iIndex <= $eIWiza) Then
		Local $sFilter = String($g_asTroopShortNames[$iIndex]) & "*"
		Local $asImageToUse = _FileListToArray($g_sImgTrainTroops, $sFilter, $FLTA_FILES, True)
		If Not @error Then
			If $g_bDebugSetlogTrain Then SetLog("$asImageToUse Troops: " & _ArrayToString($asImageToUse, "|"))
			Return GetCoordToUse($asImageToUse, $iIndex)
		Else
			Return 0
		EndIf
	EndIf

	If $iIndex >= $eLSpell And $iIndex <= $eOgSpell Then
		Local $sFilter = String($g_asSpellShortNames[$iIndex - $eLSpell]) & "*"
		Local $asImageToUse = _FileListToArray($g_sImgTrainSpells, $sFilter, $FLTA_FILES, True)
		If Not @error Then
			If $g_bDebugSetlogTrain Then SetLog("$asImageToUse Spell: " & $asImageToUse[1])
			Return GetCoordToUse($asImageToUse, $iIndex)
		Else
			Return 0
		EndIf
	EndIf

	Return 0
EndFunc   ;==>GetTrainPos

Func GetCoordToUse(Const $asImageToUse, Const $iIndex)
	Local $aTrainPos[5] = [-1, -1, -1, -1, $eBarb]
	; Capture the screen for comparison
	_CaptureRegion2(72, 350, 780, 520)

	Local $iError = ""
	For $i = 1 To $asImageToUse[0]

		Local $asResult = DllCallMyBot("FindTile", "handle", $g_hHBitmap2, "str", $asImageToUse[$i], "str", "FV", "int", 1)

		If IsArray($asResult) Then
			If $asResult[0] = "0" Then
				$iError = 0
			ElseIf $asResult[0] = "-1" Then
				$iError = -1
			ElseIf $asResult[0] = "-2" Then
				$iError = -2
			Else
				If $g_bDebugSetlogTrain Then SetLog("String: " & $asResult[0])
				Local $aResult = StringSplit($asResult[0], "|", $STR_NOCOUNT)
				If UBound($aResult) > 1 Then
					Local $aCoordinates = StringSplit($aResult[1], ",", $STR_NOCOUNT)
					If UBound($aCoordinates) > 1 Then
						Local $iButtonX = 72 + Int($aCoordinates[0])
						Local $iButtonY = 350 + Int($aCoordinates[1])
						Local $aTrainPos[2] = [$iButtonX, $iButtonY]
						Return $aTrainPos
					Else
						SetLog("Don't know how to train the troop with index " & $iIndex & " yet.")
					EndIf
				Else
					SetLog("Don't know how to train the troop with index " & $iIndex & " yet")
				EndIf
			EndIf
		Else
			SetLog("Don't know how to train the troop with index " & $iIndex & " yet")
		EndIf
	Next

	If $iError = 0 Then
		SetLog("No " & GetTroopName($iIndex) & " Icon found!", $COLOR_ERROR)
	ElseIf $iError = -1 Then
		SetLog("TrainIt.au3 GetCoordToUse(): ImgLoc DLL Error Occured!", $COLOR_ERROR)
	ElseIf $iError = -2 Then
		SetLog("TrainIt.au3 GetCoordToUse(): Wrong Resolution used for ImgLoc Search!", $COLOR_ERROR)
	EndIf

	Return $aTrainPos
EndFunc   ;==>GetVariable

Func GetFullName(Const $iIndex, Const $aTrainPos)
	If $g_bDebugSetlogTrain Then SetLog("GetFullName($iIndex=" & $iIndex & ")", $COLOR_DEBUG)

	If $iIndex >= $eBarb And $iIndex <= $eIWiza Then
		Local $sTroopType = ($iIndex >= $eMini ? "Dark" : "Normal")
		Return GetFullNameSlot($aTrainPos, $sTroopType)
	EndIf

	If $iIndex >= $eLSpell And $iIndex <= $eOgSpell Then
		Return GetFullNameSlot($aTrainPos, "Spell")
	EndIf

	SetLog("Don't know how to find the full name of troop with index " & $iIndex & " yet")

	Local $aTempSlot[4] = [-1, -1, -1, -1]

	Return $aTempSlot
EndFunc   ;==>GetFullName


Func GetRNDName(Const $iIndex, Const $aTrainPos)
	Local $aTrainPosRND[4]

	If $iIndex <> -1 Then
		Local $aTempCoord = $aTrainPos
		$aTrainPosRND[0] = $aTempCoord[0] - 5
		$aTrainPosRND[1] = $aTempCoord[1] - 5
		$aTrainPosRND[2] = $aTempCoord[0] + 5
		$aTrainPosRND[3] = $aTempCoord[1] + 5
		Return $aTrainPosRND
	EndIf

	Return 0
EndFunc   ;==>GetRNDName

; Function to use on GetFullName() , returns slot and correct [i] symbols position on train window
Func GetFullNameSlot(Const $iTrainPos, Const $sTroopType)

	Local $iSlotH, $iSlotV

	If $sTroopType = "Spell" Then
		Switch $iTrainPos[0]
			Case 0 To 120 ; 1 Column
				$iSlotH = 110
			Case 121 To 220 ; 2 Column
				$iSlotH = 208
			Case 220 To 315 ; 3 Column
				$iSlotH = 306
			Case 320 To 415 ; 4 Column
				$iSlotH = 404
			Case 420 To 520 ; 5 Column
				$iSlotH = 506
			Case 520 To 620 ; 6 Column
				$iSlotH = 605
			Case 621 To 715 ; 7th Column
				$iSlotH = 703
			Case Else
				If _ColorCheck(_GetPixelColor($iTrainPos[0], $iTrainPos[1], True), Hex(0xd3d3cb, 6), 5) Then
					SetLog("GetFullNameSlot(): It seems that there is no Slot for an Spell on: " & $iTrainPos[0] & "," & $iTrainPos[1] & "!", $COLOR_ERROR)
				EndIf
		EndSwitch

		Switch $iTrainPos[1]
			Case 350 To 430
				$iSlotV = 400 ; First ROW
			Case 430 To 500 ; Second ROW
				$iSlotV = 485
		EndSwitch

		Local $aSlot[4] = [$iTrainPos[0], $iSlotV, 0xB9B9B9, 20] ; Gray [i] icon
		If $g_bDebugSetlogTrain Then SetLog("GetFullNameSlot(): Spell Icon found on: " & $iSlotH & "," & $iSlotV, $COLOR_DEBUG)
		Return $aSlot
	EndIf

	If $sTroopType = "Normal" Then
		Switch $iTrainPos[0]
			Case 0 To 101 ; 1 Column
				$iSlotH = 110
			Case 105 To 199 ; 2 Column
				$iSlotH = 208
			Case 200 To 297 ; 3 Column
				$iSlotH = 306
			Case 298 To 395 ; 4 Column
				$iSlotH = 404
			Case 396 To 494 ; 5 Column
				$iSlotH = 503
			Case 495 To 592 ; 6 Column
				$iSlotH = 601
			Case 593 To 690 ; 7 Column
				$iSlotH = 699
			Case 710 To 805 ; 8 Column
				$iSlotH = 797
			Case Else
				If _ColorCheck(_GetPixelColor($iTrainPos[0], $iTrainPos[1], True), Hex(0xD3D3CB, 6), 5) Then
					SetLog("GetFullNameSlot(): It seems that there is no Slot for an Elixir Troop on: " & $iTrainPos[0] & "," & $iTrainPos[1] & "!", $COLOR_ERROR)
				EndIf
		EndSwitch

		Switch $iTrainPos[1]
			Case 350 To 430
				$iSlotV = 400 ; First ROW
			Case 430 To 500 ; Second ROW
				$iSlotV = 485
		EndSwitch

		Local $aSlot[4] = [$iTrainPos[0], $iSlotV, 0xB9B9B9, 20] ; Gray [i] icon
		If $g_bDebugSetlogTrain Then SetLog("GetFullNameSlot(): Elixir Troop Icon found on: " & $iSlotH & "," & $iSlotV, $COLOR_DEBUG)

		Return $aSlot
	EndIf

	If $sTroopType = "Dark" Then
		Switch $iTrainPos[0]
			Case 240 To 339
				$iSlotH = 326
			Case 340 To 439
				$iSlotH = 429
			Case 440 To 539
				$iSlotH = 527
			Case 540 To 635
				$iSlotH = 625
			Case 636 To 734
				$iSlotH = 724
			Case 735 To 833
				$iSlotH = 822
			Case Else
				If _ColorCheck(_GetPixelColor($iTrainPos[0], $iTrainPos[1], True), Hex(0xd3d3cb, 6), 5) Then
					SetLog("GetFullNameSlot(): It seems that there is no Slot for a Dark Elixir Troop on: " & $iTrainPos[0] & "," & $iTrainPos[1] & "!", $COLOR_ERROR)
				EndIf
		EndSwitch

		Switch $iTrainPos[1]
			Case 350 To 430
				$iSlotV = 400 ; First ROW
			Case 430 To 500 ; Second ROW
				$iSlotV = 485
		EndSwitch

		Local $aSlot[4] = [$iTrainPos[0], $iSlotV, 0xB9B9B9, 20] ; Gray [i] icon
		If $g_bDebugSetlogTrain Then SetLog("GetFullNameSlot(): Dark Elixir Troop Icon found on: " & $iSlotH & "," & $iSlotV, $COLOR_DEBUG)
		Return $aSlot
	EndIf

EndFunc   ;==>GetFullNameSlot
