; #FUNCTION# ====================================================================================================================
; Name ..........: Collect
; Description ...:
; Syntax ........: CollectBuilderBase()
; Parameters ....:
; Return values .: None
; Author ........: Fliegerfaust (05-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func CollectBuilderBase($bSwitchToBB = False, $bSwitchToNV = False)

	If Not $g_bChkCollectBuilderBase Then Return
	If Not $g_bRunState Then Return

	If $bSwitchToBB Then
		ClickAway()
		If Not SwitchBetweenBases("BB") Then Return ; Switching to Builders Base
	EndIf

	SetLog("Collecting Resources on Builders Base", $COLOR_INFO)
	If _Sleep($DELAYCOLLECT2) Then Return

	; Collect function to Parallel Search , will run all pictures inside the directory
	; Setup arrays, including default return values for $return
	Local $sFilename = ""
	Local $aCollectXY, $t

	Local $aResult = multiMatches($g_sImgCollectResourcesBB, 0, "FV", "FV")

	If UBound($aResult) > 1 Then ; we have an array with data of images found
		For $i = 1 To UBound($aResult) - 1  ; loop through array rows
			$sFilename = $aResult[$i][1] ; Filename
			$aCollectXY = $aResult[$i][5] ; Coords
			If IsArray($aCollectXY) Then ; found array of locations
				$t = Random(0, UBound($aCollectXY) - 1, 1) ; SC May 2017 update only need to pick one of each to collect all
				SetDebugLog($sFilename & " found, random pick(" & $aCollectXY[$t][0] & "," & $aCollectXY[$t][1] & ")", $COLOR_SUCCESS)
				If IsMainPageBuilderBase() Then Click($aCollectXY[$t][0], $aCollectXY[$t][1], 1, 0, "#0430")
				If _Sleep($DELAYCOLLECT2) Then Return
			EndIf
		Next
	EndIf

	If _Sleep($DELAYCOLLECT3) Then Return
	CollectBBCart()
	If _Sleep($DELAYCOLLECT3) Then Return
	If $bSwitchToNV Then SwitchBetweenBases("Main") ; Switching back to the normal Village
EndFunc

Func CollectBBCart()
	If QuickMIS("BC1", $g_sImgBB20 & "ElixCart\", 540, 80, 630, 150) Then ;check ElixCart Image
		Setlog("Found Elix Cart", $COLOR_DEBUG2)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(1000) Then Return
		For $i = 1 To 5
			SetLog("Waiting Cart Window #" & $i, $COLOR_ACTION)
			If QuickMIS("BC1", $g_sImgBB20 & "ElixCart\", 636, 515, 730, 560) Then
				Setlog("Collecting Elixir from BuilderBase Cart", $COLOR_ACTION)
				Click($g_iQuickMISX, $g_iQuickMISY)
				ClickAway()
				If _Sleep(1000) Then Return
				ExitLoop
			EndIf
			If _Sleep(1000) Then Return
		Next
		
	EndIf
EndFunc