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
	Local $sSwitchFrom, $sSwitchTo, $aPixelToCheck
	Local $sTile, $x, $y, $x1, $y1, $Dir
	Local $bRet = False
	
	If $To = "Main" Then 
		$sSwitchFrom = "Builder Base"
		$sSwitchTo = "Normal Village"
		$sTile = "BoatBuilderBase"
		$aPixelToCheck = $aIsMain
		$x = 500
		$y = 0
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

Func BBTutorial($x = 170, $y = 560)
	If _Sleep(1000) Then Return
	If QuickMIS("BC1", $g_sImgArrowNewBuilding, 145, 480, 210, 540) Then 
		Click($x, $y)
		If _Sleep(2000) Then Return
	Else
		SetLog("No Arrow Detected", $COLOR_INFO)
		SetLog("Skip BB Tutorial", $COLOR_INFO)
		Return False
	EndIf
	
	getBuilderCount(True) ;check if we have available builder
	If $g_iFreeBuilderCount < 1 Then
		SetLog("Wait for a free builder first", $COLOR_INFO)
		SetLog("Skip BB Tutorial", $COLOR_INFO)
		ClickAway()
		Return False
	EndIf
	
	Local $RebuildButton
	$RebuildButton = findButton("Upgrade", Default, 1, True)
	If IsArray($RebuildButton) And UBound($RebuildButton) = 2 Then
		SetLog("Rebuilding Boat", $COLOR_SUCCESS)
		Click($RebuildButton[0], $RebuildButton[1])
	Else
		SetLog("No Rebuild Button!", $COLOR_ERROR)
		Return False
	EndIf
	
	Local $RebuildWindowOK = False
	For $i = 1 To 5
		SetDebugLog("Waiting for Rebuild Boat Window #" & $i, $COLOR_ACTION)
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 575, 100, 630, 155) Then
			SetLog("Rebuild Boat Window Opened", $COLOR_INFO)
			Click(430, 505) ;Click Rebuild Button
			If _Sleep(1000) Then Return
			$RebuildWindowOK = True
			ExitLoop
		EndIf
		If _Sleep(600) Then Return
	Next
	If Not $RebuildWindowOK Then Return False
	
	SetLog("Waiting Boat Rebuild", $COLOR_INFO)
	_SleepStatus(12000)
	
	If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		SetLog("Waiting Next Tutorial to Travel", $COLOR_INFO)
		_SleepStatus(20000)
	EndIf
	
	If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then
		SetLog("Click Boat", $COLOR_INFO)
		Click(490, 310) ;Click Boat
		If _Sleep(2000) Then Return
		SetLog("Click Travel Button", $COLOR_INFO)
		Click(475, 575) ;Click Travel
		If _Sleep(2000) Then Return
		_SleepStatus(30000)
	EndIf
	
	For $i = 1 To 10
		SetLog("Waiting Next Tutorial on BuilderBase #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(3000) Then Return
			ExitLoop
		EndIf
		If _Sleep(5000) Then Return
	Next
	
	For $i = 1 To 5
		If QuickMIS("BC1", $g_sImgArrowNewBuilding, 475, 110, 665, 250) Then 
			Click(595, 250) ;Click Broken Builder Hall
			If _Sleep(2000) Then Return
			Local $RebuildButton = findButton("Upgrade", Default, 1, True)
			If IsArray($RebuildButton) And UBound($RebuildButton) = 2 Then
				SetLog("Upgrading Builder Hall", $COLOR_SUCCESS)
				Click($RebuildButton[0], $RebuildButton[1])
				If _Sleep(2000) Then Return
			EndIf
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 660, 125, 715, 170) Then
				SetLog("Upgrade Builder Hall Window Opened", $COLOR_INFO)
				If _Sleep(1000) Then Return
				Click(430, 495) ;Click Gold Button
				If _Sleep(2000) Then Return
				ExitLoop
			EndIf
		EndIf
		If _Sleep(2000) Then Return
	Next
	
	SetLog("Waiting Builder Hall Upgrading", $COLOR_INFO)
	_SleepStatus(12000)
	
	SetLog("Waiting Next Tutorial on BuilderBase", $COLOR_INFO)
	For $i = 1 To 10
		SetLog("Wait Next Tutorial Chat #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then
			SetLog("Found Tutorial Chat", $COLOR_ACTION)
			ClickAway()
			_SleepStatus(10000)
		EndIf
		If WaitforPixel(115, 540, 116, 541, "326C52", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(115, 540) 
			_SleepStatus(10000)
		EndIf
		If WaitforPixel(674, 535, 675, 536, "B35727", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(674, 535) 
			_SleepStatus(10000)
		EndIf
		If WaitforPixel(150, 534, 151, 535, "FFA980", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(150, 534) 
			_SleepStatus(10000)
		EndIf
		If WaitforPixel(710, 560, 711, 561, "885843", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(150, 534) 
			_SleepStatus(10000)
		EndIf
		
		If QuickMIS("BC1", $g_sImgArrowNewBuilding, 430, 100, 550, 230) Then 
			Click(430, 240) ;Click Star Laboratory
			If _Sleep(2000) Then Return
			ExitLoop
		EndIf
		If _Sleep(3000) Then Return
	Next
		
	For $i = 1 To 5
		SetLog("Wait Research Button Tutorial on Star Laboratory #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgArrowNewBuilding, 480, 460, 570, 570) Then 
			Click(470, 570) ;Click Research Button
			If _Sleep(2000) Then Return
			ExitLoop
		EndIf
		If _Sleep(2000) Then Return
	Next
	
	For $i = 1 To 5
		SetLog("Wait Arrow Tutorial on Raged Barbarian #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgArrowNewBuilding, 160, 250, 270, 380) Then 
			Click(155, 390) ;Click Raged Barbarian
			If _Sleep(2000) Then Return
			ExitLoop
		EndIf
		If _Sleep(2000) Then Return
	Next
	
	For $i = 1 To 5
		SetLog("Wait Arrow Tutorial on Upgrade Button #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgArrowNewBuilding, 650, 400, 770, 520) Then 
			Click(645, 530) ;Click Upgrade Button
			If _Sleep(2000) Then Return
			ExitLoop
		EndIf
		If _Sleep(2000) Then Return
	Next
	
	SetLog("Waiting Raged Barbarian upgrade, 30s", $COLOR_INFO)
	_SleepStatus(35000)
	ClickAway()
	_SleepStatus(10000)
	ClickAway()
	_SleepStatus(10000)
	
	SetLog("Going Attack For Tutorial", $COLOR_INFO)
	For $i = 1 To 10
		SetLog("Wait Arrow Tutorial on Attack Button #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgArrowNewBuilding, 6, 460, 110, 590) Then 
			Click(60, 610) ;Click Attack Button
			If _Sleep(3000) Then Return
			ExitLoop
		EndIf
		If _Sleep(5000) Then Return
	Next
	
	For $i = 1 To 10
		SetLog("Wait For Find Now Button #" & $i, $COLOR_ACTION)
		If WaitforPixel(588, 321, 589, 322, "D7540E", 20, 2) Then
			SetDebugLog("Found FindNow Button", $COLOR_ACTION)
			Click(590, 300)
			_SleepStatus(25000) ;wait for clouds and other animations
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	
	For $i = 1 To 10
		SetLog("Wait For AttackBar #" & $i, $COLOR_ACTION)
		Local $AttackBarBB = GetAttackBarBB()
		If IsArray($AttackBarBB) And UBound($AttackBarBB) > 0 And $AttackBarBB[0][0] = "Barbarian" Then
			Click($AttackBarBB[0][1], $AttackBarBB[0][2]) ;Click Raged Barbarian on AttackBar
			_SleepStatus(1000)
			Click(450, 430, 5) ;Deploy Raged Barbarian
			ExitLoop
		EndIf
		_SleepStatus(5000)
	Next
	
	For $i = 1 To 10
		SetLog("Waiting Next Tutorial After Attack #" & $i, $COLOR_INFO)
		If WaitforPixel(115, 540, 116, 541, "326C52", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(115, 540) 
			_SleepStatus(10000)
		EndIf
		If WaitforPixel(674, 535, 675, 536, "B35727", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(674, 535) 
			_SleepStatus(10000)
		EndIf
		If WaitforPixel(150, 534, 151, 535, "FFA980", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(150, 534) 
			_SleepStatus(10000)
		EndIf
		If QuickMIS("BC1", $g_sImgArrowNewBuilding, 75, 480, 200, 600) Then 
			Click(65, 620) ;Click Return Home
			_SleepStatus(5000)
			ExitLoop
		EndIf
		If _Sleep(5000) Then Return
	Next
	
	For $i = 1 To 10
		SetLog("Wait Arrow Tutorial on Builder Menu #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgArrowNewBuilding, 260, 30, 380, 150) Then 
			Click(380, 30) ;Click Builder Menu
			_SleepStatus(10000)
			ExitLoop
		EndIf
		If _Sleep(3000) Then Return
	Next
	
	SetLog("Wait Next Tutorial for Builder Menu", $COLOR_INFO)
	For $i = 1 To 10
		If WaitforPixel(674, 535, 675, 536, "B35727", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(674, 535) 
			_SleepStatus(10000)
		EndIf
		If WaitforPixel(115, 540, 116, 541, "326C52", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(115, 540) 
			_SleepStatus(10000)
		EndIf
		ClickAway()
		getBuilderCount(False, True) ;check masterBuilder
		If Number($g_iFreeBuilderCountBB) = 1 Then ExitLoop
		If _Sleep(3000) Then Return
	Next
	
	BuilderBaseReport()
	If Number($g_iFreeBuilderCountBB) = 1 Then 
		ClickAway()
		If _Sleep(2000) Then Return
		SetLog("CONGRATULATIONS!, Successfully Open BuilderBase", $COLOR_SUCCESS)
		Return True
	EndIf
EndFunc

Func TestloopBB()
	While True
		BuilderBase()
		If Not $g_bRunState Then Return
	WEnd
EndFunc
