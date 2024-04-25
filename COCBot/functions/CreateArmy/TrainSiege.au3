; #FUNCTION# ====================================================================================================================
; Name ..........: Train Siege 2018
; Description ...:
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: ProMac(07-2018)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func TrainSiege($bTrainFullSiege = False)

	; Check if is necessary run the routine

	If Not $g_bRunState Then Return

	If $g_bDebugSetlogTrain Then SetLog("-- TrainSiege --", $COLOR_DEBUG)

	If Not OpenSiegeMachinesTab(True, "TrainSiege()") Then Return
	If _Sleep(500) Then Return

	Local $aCheckIsOccupied[4] = [767, 203, 0xE21012, 10]
	Local $aCheckIsFilled[4] = [715, 186, 0xD7AFA9, 10]
	
	Local $aiQueueSiegeMachine[$eSiegeMachineCount] = [0, 0, 0, 0, 0, 0, 0]
	Local $aiTotalSiegeMachine = $g_aiCurrentSiegeMachines
	Local $aCoord[2] = [0, 0]

	; check queueing siege
	If _CheckPixel($aCheckIsFilled, True, Default, "Siege is Filled") Or _CheckPixel($aCheckIsOccupied, True, Default, "Siege is Queued") Then
		Local $aSearchResult = SearchArmy($g_sImgArmyOverviewSiegesQueued, 400, 200, 778, 235, "Queue")
		If $aSearchResult[0][0] <> "" Then
			For $i = 0 To UBound($aSearchResult) - 1
				Local $iSiegeIndex = TroopIndexLookup($aSearchResult[$i][0]) - $eWallW
				$aiQueueSiegeMachine[$iSiegeIndex] += $aSearchResult[$i][3]
				$aiTotalSiegeMachine[$iSiegeIndex] += $aSearchResult[$i][3]
				Setlog("- " & $g_asSiegeMachineNames[$iSiegeIndex] & " x" & $aSearchResult[$i][3] & " Queued.")
			Next
		EndIf
	EndIf

	For $iSiegeIndex = $eSiegeWallWrecker To $eSiegeMachineCount - 1
		If $g_aiArmyCompSiegeMachines[$iSiegeIndex] > 0 Then
			SetLog("[" & $g_asSiegeMachineNames[$iSiegeIndex] & "] " & " SetTrain:" & $g_aiArmyCompSiegeMachines[$iSiegeIndex] & _ 
			", Trained:" & $g_aiCurrentSiegeMachines[$iSiegeIndex] & ", InQueue:" & $aiQueueSiegeMachine[$iSiegeIndex], $COLOR_DEBUG)
		EndIf
	Next
	
	; Refill
	For $iSiegeIndex = $eSiegeWallWrecker To $eSiegeMachineCount - 1
		Local $HowMany = $g_aiArmyCompSiegeMachines[$iSiegeIndex] - $g_aiCurrentSiegeMachines[$iSiegeIndex] - $aiQueueSiegeMachine[$iSiegeIndex]
		
		If $HowMany > 0 Then
			Local $sSiegeName = $HowMany >= 2 ? $g_asSiegeMachineNames[$iSiegeIndex] & "s" : $g_asSiegeMachineNames[$iSiegeIndex] & ""
			Setlog("Build " & $HowMany & " " & $sSiegeName, $COLOR_SUCCESS)
			$aCoord = DragIfNeededSiege($iSiegeIndex)
			If Not $g_bRunState Then Return
			If $aCoord[0] > 0 Then
				ClickP($aCoord, $HowMany)
				$aiTotalSiegeMachine[$iSiegeIndex] += $HowMany
			EndIf
		EndIf
		If _Sleep(250) Then Return
	Next
	
	Local $aSiegeCamp = GetCurrentTroop(95, 163)
	Local $bNeedFill = True
	If $aSiegeCamp[0] = $aSiegeCamp[1] * 2 Then $bNeedFill = False
	
	; build 2nd army
	If ($g_bDoubleTrain Or $bTrainFullSiege) And $bNeedFill Then
		SetLog("2nd Army Siege", $COLOR_DEBUG1)
		For $iSiegeIndex = $eSiegeWallWrecker To $eSiegeMachineCount - 1
			Local $HowMany = $g_aiArmyCompSiegeMachines[$iSiegeIndex] * 2 - $aiTotalSiegeMachine[$iSiegeIndex]
			
			If $HowMany > 0 Then
				Local $sSiegeName = $HowMany >= 2 ? $g_asSiegeMachineNames[$iSiegeIndex] & "s" : $g_asSiegeMachineNames[$iSiegeIndex] & ""
				Setlog("Build " & $HowMany & " " & $sSiegeName, $COLOR_SUCCESS)
				$aCoord = DragIfNeededSiege($iSiegeIndex)
				If Not $g_bRunState Then Return
				If $aCoord[0] > 0 Then
					ClickP($aCoord, $HowMany)
				EndIf
			EndIf
			If _Sleep(250) Then Return
		Next
	EndIf
	If _Sleep(500) Then Return

	; OCR to get remain time - coc-siegeremain
	Local $sSiegeTime = getRemainBuildTimer(715, 165) ; Get time via OCR.
	If $sSiegeTime <> "" Then
		$g_aiTimeTrain[3] = ConvertOCRTime("Siege", $sSiegeTime, False) ; Update global array
		SetLog("Remaining Siege build time: " & StringFormat("%.2f", $g_aiTimeTrain[3]), $COLOR_INFO)
	EndIf
EndFunc   ;==>TrainSiege

Func DragIfNeededSiege($iSiegeIndex = $eSiegeWallWrecker)
	Local $aCoord[2] = [0, 0]
	SetLog("DragIfNeededSiege [" & $iSiegeIndex & "] " & $g_asSiegeMachineNames[$iSiegeIndex], $COLOR_DEBUG1)
	
	If QuickMIS("BFI", $g_sImgTrainSieges & $g_asSiegeMachineShortNames[$iSiegeIndex] & "*", 70, 350, 780, 500) Then 
		SetLog("DragIfNeededSiege [" & $iSiegeIndex & "] " & $g_asSiegeMachineNames[$iSiegeIndex] & " : No Scroll", $COLOR_ACTION)
		$aCoord[0] = $g_iQuickMISX
		$aCoord[1] = $g_iQuickMISY
		If $g_bDebugSetLog Then SetLog("Siege Coord : " & _ArrayToString($aCoord), $COLOR_DEBUG1)
		Return $aCoord
	EndIf
	
	If _PixelSearch(75, 354, 76, 355, Hex(0xD3D3CB, 6), 10, True, "DragIfNeededSiege") Then
		SetLog("DragIfNeededSiege [" & $iSiegeIndex & "] " & $g_asSiegeMachineNames[$iSiegeIndex] & " : Scroll Right", $COLOR_ACTION)
		ClickDrag(750, 435, 220, 435)
		If _Sleep(2000) Then Return
		If QuickMIS("BFI", $g_sImgTrainSieges & $g_asSiegeMachineShortNames[$iSiegeIndex] & "*", 70, 350, 780, 500) Then 
			$aCoord[0] = $g_iQuickMISX
			$aCoord[1] = $g_iQuickMISY
			If $g_bDebugSetLog Then SetLog("Siege Coord : " & _ArrayToString($aCoord), $COLOR_DEBUG1)
			Return $aCoord
		EndIf
	EndIf
	
	If _PixelSearch(776, 354, 777, 355, Hex(0xD3D3CB, 6), 10, True, "DragIfNeededSiege") Then
		SetLog("DragIfNeededSiege [" & $iSiegeIndex & "] " & $g_asSiegeMachineNames[$iSiegeIndex] & " : Scroll Left", $COLOR_ACTION)
		ClickDrag(100, 435, 630, 435)
		If _Sleep(2000) Then Return
		If QuickMIS("BFI", $g_sImgTrainSieges & $g_asSiegeMachineShortNames[$iSiegeIndex] & "*", 70, 350, 780, 500) Then 
			$aCoord[0] = $g_iQuickMISX
			$aCoord[1] = $g_iQuickMISY
			If $g_bDebugSetLog Then SetLog("Siege Coord : " & _ArrayToString($aCoord), $COLOR_DEBUG1)
			Return $aCoord
		EndIf
	EndIf
	If $g_bDebugSetLog Then SetLog("Siege Coord : " & _ArrayToString($aCoord), $COLOR_DEBUG1)
	Return $aCoord
EndFunc
