; #FUNCTION# ====================================================================================================================
; Name ..........: SwitchBetweenBases
; Description ...: Switches Between Normal Village and Builder Base
; Syntax ........: SwitchBetweenBases()
; Parameters ....:
; Return values .: True: Successfully switched Bases  -  False: Failed to switch Bases
; Author ........: Fliegerfaust (05-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func SwitchBetweenBases_Old($bCheckMainScreen = True)
	Local $sSwitchFrom, $sSwitchTo, $bIsOnBuilderBase = False, $aButtonCoords
	Local $sTile, $sTileDir, $sRegionToSearch
	Local $bSwitched = False

	If Not $g_bRunState Then Return

	For $i = 0 To 2
		If isOnBuilderBase() Then
			$sSwitchFrom = "Builder Base"
			$sSwitchTo = "Normal Village"
			$bIsOnBuilderBase = True
			$sTile = "BoatBuilderBase"
			$sTileDir = $g_sImgBoatBB
			$sRegionToSearch = "487,44,708,242"
		Else
			$sSwitchFrom = "Normal Village"
			$sSwitchTo = "Builder Base"
			$bIsOnBuilderBase = False
			$sTile = "BoatNormalVillage"
			$sTileDir = $g_sImgBoat
			$sRegionToSearch = "66,432,388,627"
		EndIf

		If _sleep(1000) Then Return
		If Not $g_bRunState Then Return

		ZoomOut() ; ensure boat is visible
		If Not $g_bRunState Then Return

		$aButtonCoords = decodeSingleCoord(findImageInPlace($sTile, $sTileDir, $sRegionToSearch))
		If UBound($aButtonCoords) > 1 Then
			SetLog("[" & $i & "] Going to " & $sSwitchTo, $COLOR_INFO)
			ClickP($aButtonCoords)
			If _Sleep($DELAYSWITCHBASES1) Then Return

			; switch can take up to 2 Seconds, check for 3 additional Seconds...
			For $j = 1 To 5
				If _Sleep(1000) Then Return
				SetDebugLog("[" & $j & "] Waiting for switched to " & $sSwitchTo)
				If IsProblemAffect(True) Then Return
				$bSwitched = isOnBuilderBase() <> $bIsOnBuilderBase
				If $bSwitched Then ExitLoop
			Next
			
			If Not $g_bRunState Then Return
			If IsProblemAffect(True) Then Return
			If $bSwitched Then
				If $bCheckMainScreen Then checkMainScreen(True, Not $bIsOnBuilderBase, "SwitchBetweenBases")
				Return True
			EndIf
			
			If Not $bSwitched Then
				SetLog("Failed to go to the " & $sSwitchTo, $COLOR_ERROR)
				If $i = 1 And ($g_bPlaceNewBuilding Or $g_iChkPlacingNewBuildings) Then
					If $bIsOnBuilderBase Then 
						GoAttackBBAndReturn()
					Else
						GoGoblinMap()
					EndIf
				EndIf
				Return False
			EndIf
		Else
			Setlog("[" & $i & "] SwitchBetweenBases Tile: " & $sTile, $COLOR_ERROR)
			Setlog("[" & $i & "] SwitchBetweenBases isOnBuilderBase: " & isOnBuilderBase(True), $COLOR_ERROR)
			If $bIsOnBuilderBase Then
				SetLog("Cannot find the Boat on the Coast", $COLOR_ERROR)
			Else
				SetLog("Cannot find the Boat on the Coast. Maybe it is still broken or not visible", $COLOR_ERROR)
			EndIf

			If $i >= 1 Then RestartAndroidCoC() ; Need to try to restart CoC
		EndIf
	Next

	Return False
EndFunc   ;==>SwitchBetweenBases


Func SwitchBetweenBases($ForcedSwitchTo = "BB")
	
	Local $bIsOnBuilderBase = isOnBuilderBase()
	If $bIsOnBuilderBase And $ForcedSwitchTo = "BB" Then
		SetLog("Already on BuilderBase, Skip SwitchBetweenBases", $COLOR_ERROR)
		Return
	EndIf
	
	If IsProblemAffect(True) Then Return
	If Not $g_bRunState Then Return
	
	If $g_bStayOnBuilderBase And Not $bIsOnBuilderBase Then
		SetLog("StayOnBuilderBase = " & String($g_bStayOnBuilderBase), $COLOR_INFO)
		SetLog(" --- Are we on BuilderBase ? " & String($bIsOnBuilderBase), $COLOR_INFO)
		SetLog("Switching To BuilderBase")
		Return SwitchTo("BB")
	EndIf
	
	Switch $ForcedSwitchTo
		Case "BB"
			Return SwitchTo("BB")
		Case "Main"
			Return SwitchTo("Main")
	EndSwitch
EndFunc

Func SwitchTo($To = "BB")
	Local $sSwitchFrom, $sSwitchTo, $aPixelToCheck
	Local $sTile, $x, $y, $x1, $y1
	Local $bRet = False
	
	If $To = "Main" Then 
		$sSwitchFrom = "Builder Base"
		$sSwitchTo = "Normal Village"
		$sTile = "BoatBuilderBase"
		$aPixelToCheck = $aIsMain
		$x = 570
		$y = 25
		$x1 = 700
		$y1 = 160
	Else
		$sSwitchFrom = "Normal Village"
		$sSwitchTo = "Builder Base"
		$sTile = "BoatNormalVillage"
		$aPixelToCheck = $aIsOnBuilderBase
		$x = 120
		$y = 475
		$x1 = 250
		$y1 = 575
	EndIf	
	
	For $i = 1 To 3
		SetLog("[" & $i & "] Trying to Switch to " & $sSwitchTo, $COLOR_INFO)
		ZoomOut() ;zoomout first
		SetDebugLog("QuickMIS(BC1, " & $g_sImgBoat & "," & $x & "," & $y & "," &  $x1 & "," & $y1 & ")")
		If QuickMIS("BC1", $g_sImgBoat, $x, $y, $x1, $y1) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			ExitLoop
		Else
			SetLog($sTile & " Not Found, try again...", $COLOR_ERROR)
			ContinueLoop
		EndIf
	Next
	
	If IsProblemAffect(True) Then Return
	If Not $g_bRunState Then Return
	
	For $i = 1 To 10
		$bRet = _CheckPixel($aPixelToCheck, True, Default, "SwitchBetweenBases")
		If $bRet Then 
			SetDebugLog("Switch From " & $sSwitchFrom & " To " & $sSwitchTo & " Success")
			ExitLoop
		EndIf
		_Sleep(500)
	Next
	
	If IsProblemAffect(True) Then Return
	If Not $g_bRunState Then Return
	
	Return $bRet
EndFunc