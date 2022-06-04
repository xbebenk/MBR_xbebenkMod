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

Func SwitchBetweenBases($ForcedSwitchTo = "BB")
	Local $bIsOnBuilderBase = isOnBuilderBase()
	If $bIsOnBuilderBase And $ForcedSwitchTo = "BB" Then
		SetLog("Already on BuilderBase, Skip SwitchBetweenBases", $COLOR_ERROR)
		Return True
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
		$x = 550
		$y = 30
		$x1 = 700
		$y1 = 200
	Else
		$sSwitchFrom = "Normal Village"
		$sSwitchTo = "Builder Base"
		$sTile = "BoatNormalVillage"
		$aPixelToCheck = $aIsOnBuilderBase
		$x = 100
		$y = 460
		$x1 = 250
		$y1 = 585
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
			If $g_bDebugClick Or $g_bDebugSetlog Then SaveDebugImage("SwitchBetweenBases", True)
			ZoomOutHelper()
			ContinueLoop
		EndIf
		_Sleep(1000)
	Next
	
	If IsProblemAffect(True) Then Return
	If Not $g_bRunState Then Return
	
	For $i = 1 To 10
		$bRet = _CheckPixel($aPixelToCheck, True, Default, "SwitchBetweenBases")
		If $bRet Then 
			SetLog("Switch From " & $sSwitchFrom & " To " & $sSwitchTo & " Success", $COLOR_SUCCESS)
			ExitLoop
		EndIf
		_Sleep(2000)
	Next
	
	If IsProblemAffect(True) Then Return
	If Not $g_bRunState Then Return
	If Not $bRet Then SetLog("SwitchBetweenBases Failed", $COLOR_ERROR)
	Return $bRet
EndFunc