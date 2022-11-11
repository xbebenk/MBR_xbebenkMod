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
	Local $bDark = ($iIndex >= $eMini And $iIndex <= $eIWiza)

	For $i = 1 To 5 ; Do

		Local $aTrainPos = GetTrainPos($iIndex)
		If IsArray($aTrainPos) And $aTrainPos[0] <> -1 Then
			If _ColorCheck(_GetPixelColor($aTrainPos[0], $aTrainPos[1], $g_bCapturePixel), Hex($aTrainPos[2], 6), $aTrainPos[3]) Then
				Local $FullName = GetFullName($iIndex, $aTrainPos)
				If IsArray($FullName) Then
					Local $RNDName = GetRNDName($iIndex, $aTrainPos)
					If IsArray($RNDName) Then
						TrainClickP($aTrainPos, $iQuantity, $g_iTrainClickDelay, $FullName, "#0266", $RNDName)
						If _Sleep($iSleep) Then Return
						If $g_bOutOfElixir Then
							SetLog("Not enough " & ($bDark ? "Dark " : "") & "Elixir to train position " & GetTroopName($iIndex) & " troops!", $COLOR_ERROR)
							SetLog("Switching to Halt Attack, Stay Online Mode", $COLOR_ERROR)
							If Not $g_bFullArmy Then $g_bRestart = True ;If the army camp is full, If yes then use it to refill storages
							Return ; We are out of Elixir stop training.
						EndIf
						Return True
					Else
						SetLog("TrainIt position " & GetTroopName($iIndex) & " - RNDName did not return array?", $COLOR_ERROR)
						Return False
					EndIf
				Else
					SetLog("TrainIt " & GetTroopName($iIndex) & " - FullName did not return array?", $COLOR_ERROR)
					Return False
				EndIf
			Else
				ForceCaptureRegion()
				Local $sBadPixelColor = _GetPixelColor($aTrainPos[0], $aTrainPos[1], $g_bCapturePixel)
				If $g_bDebugSetlogTrain Then SetLog("Positon X: " & $aTrainPos[0] & "| Y : " & $aTrainPos[1] & " |Color get: " & $sBadPixelColor & " | Need: " & $aTrainPos[2])
				If StringMid($sBadPixelColor, 1, 2) = StringMid($sBadPixelColor, 3, 2) And StringMid($sBadPixelColor, 1, 2) = StringMid($sBadPixelColor, 5, 2) Then
					; Pixel is gray, so queue is full -> nothing to inform the user about
					SetLog("Troop " & GetTroopName($iIndex) & " is not available due to full queue", $COLOR_DEBUG)
				Else
					If Mod($i, 2) = 0 Then ; executed on $i = 2 or 4
						If $g_bDebugSetlogTrain Then SaveDebugImage("BadPixelCheck_" & GetTroopName($iIndex))
						SetLog("Bad pixel check on troop position " & GetTroopName($iIndex), $COLOR_ERROR)
						If $g_bDebugSetlogTrain Then SetLog("Train Pixel Color: " & $sBadPixelColor, $COLOR_DEBUG)
					EndIf
				EndIf
			EndIf
		Else
			If UBound($aTrainPos) > 0 And $aTrainPos[0] = -1 Then
				If $g_bDebugSetlogTrain Then SaveDebugImage("TroopIconNotFound_" & GetTroopName($iIndex))
				SetLog("TrainIt troop position " & GetTroopName($iIndex) & " did not find icon", $COLOR_ERROR)
			Else
				SetLog("Impossible happened? TrainIt troop position " & GetTroopName($iIndex) & " did not return array", $COLOR_ERROR)
			EndIf
		EndIf
	Next ; Until $iErrors = 0
EndFunc   ;==>TrainIt

Func GetTrainPos(Const $iIndex)
	If $g_bDebugSetlogTrain Then SetLog("GetTrainPos($iIndex=" & $iIndex & ")", $COLOR_DEBUG)

	; Get the Image path to search
	If ($iIndex >= $eBarb And $iIndex <= $eIWiza) Then
		Local $sFilter = String($g_asTroopShortNames[$iIndex]) & "*"
		Local $asImageToUse = _FileListToArray($g_sImgTrainTroops, $sFilter, $FLTA_FILES, True)
		If Not @error Then
			If $g_bDebugSetlogTrain Then SetLog("$asImageToUse Troops: " & _ArrayToString($asImageToUse, "|"))
			Return GetVariable($asImageToUse, $iIndex)
		Else
			Return 0
		EndIf
	EndIf

	If $iIndex >= $eLSpell And $iIndex <= $eBtSpell Then
		Local $sFilter = String($g_asSpellShortNames[$iIndex - $eLSpell]) & "*"
		Local $asImageToUse = _FileListToArray($g_sImgTrainSpells, $sFilter, $FLTA_FILES, True)
		If Not @error Then
			If $g_bDebugSetlogTrain Then SetLog("$asImageToUse Spell: " & $asImageToUse[1])
			Return GetVariable($asImageToUse, $iIndex)
		Else
			Return 0
		EndIf
	EndIf

	Return 0
EndFunc   ;==>GetTrainPos

Func GetFullName(Const $iIndex, Const $aTrainPos)
	If $g_bDebugSetlogTrain Then SetLog("GetFullName($iIndex=" & $iIndex & ")", $COLOR_DEBUG)

	If $iIndex >= $eBarb And $iIndex <= $eIWiza Then
		Local $sTroopType = ($iIndex >= $eMini ? "Dark" : "Normal")
		Return GetFullNameSlot($aTrainPos, $sTroopType)
	EndIf

	If $iIndex >= $eLSpell And $iIndex <= $eBtSpell Then
		Return GetFullNameSlot($aTrainPos, "Spell")
	EndIf

	SetLog("Don't know how to find the full name of troop with index " & $iIndex & " yet")

	Local $aTempSlot[4] = [-1, -1, -1, -1]

	Return $aTempSlot
EndFunc   ;==>GetFullName


Func GetRNDName(Const $iIndex, Const $aTrainPos)
	If $g_bDebugSetlogTrain Then SetLog("GetRNDName($iIndex=" & $iIndex & ")", $COLOR_DEBUG)
	Local $aTrainPosRND[4]

	If $iIndex <> -1 Then
		Local $aTempCoord = $aTrainPos
		$aTrainPosRND[0] = $aTempCoord[0] - 5
		$aTrainPosRND[1] = $aTempCoord[1] - 5
		$aTrainPosRND[2] = $aTempCoord[0] + 5
		$aTrainPosRND[3] = $aTempCoord[1] + 5
		Return $aTrainPosRND
	EndIf

	SetLog("Don't know how to find the RND name of troop with index " & $iIndex & " yet!", $COLOR_ERROR)
	Return 0
EndFunc   ;==>GetRNDName

;Func GetVariable(Const $ImageToUse, Const $iIndex)
;   Local $aTrainPos[4] = [-1, -1, -1, -1]
   ; Capture the screen for comparison
;   _CaptureRegion2(25, 375, 840, 548)

;   Local $asResult = DllCallMyBot("FindTile", "handle", $g_hHBitmap2, "str", $ImageToUse, "str", "FV", "int", 1)

;   If @error Then _logErrorDLLCall($g_sLibMyBotPath, @error)

;   If IsArray($asResult) Then
;	  If $asResult[0] = "0" Then
;		 SetLog("No " & GetTroopName($iIndex) & " Icon found!", $COLOR_ERROR)
;	  ElseIf $asResult[0] = "-1" Then
;		 SetLog("TrainIt.au3 GetVariable(): ImgLoc DLL Error Occured!", $COLOR_ERROR)
;	  ElseIf $asResult[0] = "-2" Then
;		 SetLog("TrainIt.au3 GetVariable(): Wrong Resolution used for ImgLoc Search!", $COLOR_ERROR)
;	  Else
;		 If $g_bDebugSetlogTrain Then SetLog("String: " & $asResult[0])
;		 Local $aResult = StringSplit($asResult[0], "|", $STR_NOCOUNT)
;		 If UBound($aResult) > 1 Then
;			Local $aCoordinates = StringSplit($aResult[1], ",", $STR_NOCOUNT)
;			If UBound($aCoordinates) > 1 Then
;			   Local $iButtonX = 25 + Int($aCoordinates[0])
;			   Local $iButtonY = 375 + Int($aCoordinates[1])
;			   Local $sColorToCheck = "0x" & _GetPixelColor($iButtonX, $iButtonY, $g_bCapturePixel)
;			   Local $iTolerance = 40
;			   Local $aTrainPos[4] = [$iButtonX, $iButtonY, $sColorToCheck, $iTolerance]
;			   If $g_bDebugSetlogTrain Then SetLog("Found: [" & $iButtonX & "," & $iButtonY & "]", $COLOR_SUCCESS)
;			   If $g_bDebugSetlogTrain Then SetLog("$sColorToCheck: " & $sColorToCheck, $COLOR_SUCCESS)
;			   If $g_bDebugSetlogTrain Then SetLog("$iTolerance: " & $iTolerance, $COLOR_SUCCESS)
;			   Return $aTrainPos
;			Else
;				  SetLog("Don't know how to train the troop with index " & $iIndex & " yet.")
;			EndIf
;		 Else
;			SetLog("Don't know how to train the troop with index " & $iIndex & " yet..")
;		 EndIf
;	  EndIf
;  Else
;		 SetLog("Don't know how to train the troop with index " & $iIndex & " yet...")
;   EndIf
;   Return $aTrainPos
;EndFunc   ;==>GetVariable

Func GetVariable(Const $asImageToUse, Const $iIndex)
	Local $aTrainPos[5] = [-1, -1, -1, -1, $eBarb]
	; Capture the screen for comparison
	_CaptureRegion2(25, 350, 840, 548)

	Local $iError = ""
	For $i = 1 To $asImageToUse[0]

		Local $asResult = DllCallMyBot("FindTile", "handle", $g_hHBitmap2, "str", $asImageToUse[$i], "str", "FV", "int", 1)

		If @error Then _logErrorDLLCall($g_sLibMyBotPath, @error)

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
						Local $iButtonX = 25 + Int($aCoordinates[0])
						Local $iButtonY = 350 + Int($aCoordinates[1])
						Local $sColorToCheck = "0x" & _GetPixelColor($iButtonX, $iButtonY, $g_bCapturePixel)
						Local $iTolerance = 40
						Local $aTrainPos[5] = [$iButtonX, $iButtonY, $sColorToCheck, $iTolerance, $eBarb]
						If $g_bDebugSetlogTrain Then SetLog("Found: [" & $iButtonX & "," & $iButtonY & "]", $COLOR_SUCCESS)
						If $g_bDebugSetlogTrain Then SetLog("$sColorToCheck: " & $sColorToCheck, $COLOR_SUCCESS)
						If $g_bDebugSetlogTrain Then SetLog("$iTolerance: " & $iTolerance, $COLOR_SUCCESS)
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
		SetLog("TrainIt.au3 GetVariable(): ImgLoc DLL Error Occured!", $COLOR_ERROR)
	ElseIf $iError = -2 Then
		SetLog("TrainIt.au3 GetVariable(): Wrong Resolution used for ImgLoc Search!", $COLOR_ERROR)
	EndIf

	Return $aTrainPos
EndFunc   ;==>GetVariable

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
			Case 0 To 445
				$iSlotV = 358 ; First ROW
			Case 446 To 550 ; Second ROW
				$iSlotV = 459
		EndSwitch

		Local $aSlot[4] = [$iSlotH, $iSlotV, 0xB9B9B9, 20] ; Gray [i] icon
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
				If _ColorCheck(_GetPixelColor($iTrainPos[0], $iTrainPos[1], True), Hex(0xd3d3cb, 6), 5) Then
					SetLog("GetFullNameSlot(): It seems that there is no Slot for an Elixir Troop on: " & $iTrainPos[0] & "," & $iTrainPos[1] & "!", $COLOR_ERROR)
				EndIf
		EndSwitch

		Switch $iTrainPos[1]
			Case 0 To 445
				$iSlotV = 358 ; First ROW
			Case 446 To 550 ; Second ROW
				$iSlotV = 459
		EndSwitch

		Local $aSlot[4] = [$iSlotH, $iSlotV, 0xB9B9B9, 20] ; Gray [i] icon
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
			Case 0 To 445
				$iSlotV = 358 ; First ROW
			Case 446 To 550 ; Second ROW
				$iSlotV = 459
		EndSwitch

		Local $aSlot[4] = [$iSlotH, $iSlotV, 0xB9B9B9, 20] ; Gray [i] icon
		If $g_bDebugSetlogTrain Then SetLog("GetFullNameSlot(): Dark Elixir Troop Icon found on: " & $iSlotH & "," & $iSlotV, $COLOR_DEBUG)
		Return $aSlot
	EndIf

EndFunc   ;==>GetFullNameSlot
