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

Func SwitchBetweenBases($ForcedSwitchTo = Default)
	Local $bIsOnBuilderBase = isOnBuilderBase()
	If $ForcedSwitchTo = Default Then
		If $bIsOnBuilderBase Then 
			$ForcedSwitchTo = "Main"
		Else
			$ForcedSwitchTo = "BB"
		EndIf
	EndIf
	
	If $ForcedSwitchTo = "BB" And IsOnBuilderBase() Then
		SetLog("Already on BuilderBase, Skip SwitchBetweenBases", $COLOR_INFO)
		Return True
	EndIf
	
	If $ForcedSwitchTo = "Main" And isOnMainVillage() Then
		SetLog("Already on MainVillage, Skip SwitchBetweenBases", $COLOR_INFO)
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
	Local $sTile, $x, $y, $x1, $y1, $Dir
	Local $bRet = False
	
	If $To = "Main" Then 
		$sSwitchFrom = "Builder Base"
		$sSwitchTo = "Normal Village"
		$sTile = "BoatBuilderBase"
		$aPixelToCheck = $aIsMain
		$x = 500
		$y = 20
		$x1 = 700
		$y1 = 200
		$Dir = $g_sImgBoatBB
	Else
		$sSwitchFrom = "Normal Village"
		$sSwitchTo = "Builder Base"
		$sTile = "BoatNormalVillage"
		$aPixelToCheck = $aIsOnBuilderBase
		$x = 70
		$y = 400
		$x1 = 350
		$y1 = 600
		$Dir = $g_sImgBoat
	EndIf	
	
	For $i = 1 To 3
		SetLog("[" & $i & "] Trying to Switch to " & $sSwitchTo, $COLOR_INFO)
		If $i > 1 Then ZoomOut() ;zoomout only if 1st try failed
		If QuickMIS("BC1", $Dir, $x, $y, $x1, $y1) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			_Sleep(1000)
			ExitLoop
		Else
			SetLog($sTile & " Not Found, try again...", $COLOR_ERROR)
			SaveDebugImage("SwitchBetweenBases", True)
			ZoomOutHelper("SwitchBetweenBases")
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
	If Not $bRet Then 
		SetLog("SwitchBetweenBases Failed", $COLOR_ERROR)
		CloseCoC(True) ; restart coc
		_SleepStatus(10000) ;give time for coc loading
		checkMainScreen(True, $g_bStayOnBuilderBase, "SwitchBetweenBases")
	EndIf
	Return $bRet
EndFunc

Func TestloopBB()
	While True
		BuilderBase()
	WEnd
EndFunc