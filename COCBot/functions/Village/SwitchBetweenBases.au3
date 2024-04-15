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
Global $FalseDetectionCount = 0

Func SwitchBetweenBases($ForcedSwitchTo = Default)
	Local $bIsOnMainVillage = isOnMainVillage()
	Local $bIsOnBuilderBase = False
	If $ForcedSwitchTo = Default Then
		If $bIsOnMainVillage Then 
			$ForcedSwitchTo = "BB"
		Else
			$ForcedSwitchTo = "Main"
		EndIf
	EndIf
	
	If Not $bIsOnMainVillage Then $bIsOnBuilderBase = isOnBuilderBase()
	
	If $ForcedSwitchTo = "BB" And $bIsOnBuilderBase Then
		SetLog("Already on BuilderBase, Skip SwitchBetweenBases", $COLOR_INFO)
		Return True
	EndIf
	
	If $ForcedSwitchTo = "Main" And $bIsOnMainVillage Then
		SetLog("Already on MainVillage, Skip SwitchBetweenBases", $COLOR_INFO)
		Return True
	EndIf
	
	;we are not on builderbase nor in mainvillage, something need to be check, check obstacles called on checkmainscreen
	If Not $bIsOnBuilderBase And Not $bIsOnMainVillage Then 
		checkMainScreen(True, $g_bStayOnBuilderBase, "SwitchBetweenBases")
		If $g_bStayOnBuilderBase Then $bIsOnBuilderBase = isOnBuilderBase() ;check again if we are on builderbases, after mainscreen located
	EndIf
	
	If IsProblemAffect() Then Return
	If Not $g_bRunState Then Return
	
	If $g_bStayOnBuilderBase And Not $bIsOnBuilderBase Then
		SetLog("StayOnBuilderBase = " & String($g_bStayOnBuilderBase), $COLOR_INFO)
		SetLog(" --- Are we on BuilderBase ? " & String($bIsOnBuilderBase), $COLOR_INFO)
		SetLog("Switching To BuilderBase")
		$FalseDetectionCount += 1
		SetDebugLog("CountFalseDetection: " & $FalseDetectionCount)
		If $FalseDetectionCount > 2 Then 
			SetDebugLog("BuilderBase Detection Maybe Failed, been trying " & $FalseDetectionCount & " times")
			SetDebugLog("Let's assume we are on BuilderBase")
			Return True ;just return true as assumed on BB
		EndIf
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
	Local $sSwitchFrom, $sSwitchTo
	Local $sTile, $x, $y, $x1, $y1, $Dir
	Local $bRet = False
	
	If $To = "Main" Then 
		$sSwitchFrom = "Builder Base"
		$sSwitchTo = "Normal Village"
		$sTile = "BoatBuilderBase"
		$x = 500
		$y = 0
		$x1 = 700
		$y1 = 200
		$Dir = $g_sImgBoatBB
	Else
		$sSwitchFrom = "Normal Village"
		$sSwitchTo = "Builder Base"
		$sTile = "BoatNormalVillage"
		$x = 70
		$y = 400
		$x1 = 350
		$y1 = 600
		$Dir = $g_sImgBoat
	EndIf	
	
	For $i = 1 To 3
		SetLog("[" & $i & "] Trying to Switch to " & $sSwitchTo, $COLOR_INFO)
		
		Local $ZoomOutResult
		If $To = "BB" Then
			If Not QuickMIS("BC1", $Dir, $x, $y, $x1, $y1) Then
				checkChatTabPixel()
				$ZoomOutResult = SearchZoomOut(True, False, "SwitchBetweenBases")
				If IsArray($ZoomOutResult) And $ZoomOutResult[0] = "" Then 
					ZoomOut() 
				EndIf
			EndIf
		EndIf
		
		If $To = "Main" Then ZoomOutHelperBB("SwitchBetweenBases")
		
		If QuickMIS("BC1", $Dir, $x, $y, $x1, $y1) Then
			If $g_iQuickMISName = "BrokenBoat" Then Return BBTutorial($g_iQuickMISX, $g_iQuickMISY)
			If $g_iQuickMISName = "BBBoatBadge" Then $g_iQuickMISY += 10
			If $g_iQuickMISName = "BoatFront" Then 
				$g_iQuickMISX += 10
				$g_iQuickMISY -= 10
			EndIf
			
			If $To = "BB" Then CheckPetHouseTutorial()
			
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(3000) Then Return
			
			Local $sScode = "DS"
			For $j = 1 To 5
				Switch $To
				Case "BB"
					$bRet = isOnBuilderBase()
				Case "Main"
					$bRet = isOnMainVillage()
				EndSwitch
				
				If $bRet Then 
					SetLog("[" & $i & "] Switch From " & $sSwitchFrom & " To " & $sSwitchTo & " Success", $COLOR_SUCCESS)
					$FalseDetectionCount = 0
					If $To = "BB" Then
						$sScode = $g_sSceneryCode
						$g_sSceneryCode = "BB"
					Else
						If $g_bStayOnBuilderBase Then $g_bStayOnBuilderBase = False
						$g_sSceneryCode = $sScode
					EndIf
					ExitLoop 2
				Else
					Click($g_iQuickMISX, $g_iQuickMISY)
				EndIf
				If _Sleep(2000) Then Return
			Next
		Else
			SetLog("[" & $i & "] " & $sTile & " Not Found, try again...", $COLOR_ERROR)
			If $To = "Main" Then CheckBB20Tutor()
			
			If $i = 3 Then 
				$g_iGfxErrorCount += 1
				If $g_iGfxErrorCount > $g_iGfxErrorMax Then 
					SetLog("SwitchBetweenBases stuck, set to Reboot Android Instance", $COLOR_INFO)
					$g_bGfxError = True
					CheckAndroidReboot()
				EndIf
			EndIf
			
		EndIf
		If _Sleep(1000) Then Return
	Next
	
	If IsProblemAffect() Then Return
	If Not $g_bRunState Then Return
	Return $bRet
EndFunc

Func TestloopBB()
	While True
		BuilderBase()
		If Not $g_bRunState Then Return
	WEnd
EndFunc
