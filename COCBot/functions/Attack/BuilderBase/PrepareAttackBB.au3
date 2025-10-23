; #FUNCTION# ====================================================================================================================
; Name ..........: PrepareAttackBB
; Description ...: This file controls attacking preperation of the builders base
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Chilly-Chill (04-2019)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func PrepareAttackBB($Mode = Default)
	If Not $g_bRunState Then Return
	If $g_bChkDebugAttackBB Then SetLog("ForceSwitchifNoCGEvent = " & String($g_bForceSwitchifNoCGEvent), $COLOR_DEBUG)
	If $g_bForceSwitchifNoCGEvent Then 
		SetLog("ForceSwitchifNoCGEvent Enabled, Skip Attack until we have BBEvent", $COLOR_SUCCESS)
		Return False
	EndIf
	
	Local $GoldIsFull = isGoldFullBB()
	Local $ElixIsFull = isElixirFullBB()
	
	If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
		If $g_bChkDebugAttackBB Then SetLog("Running Challenge is BB Challenge", $COLOR_DEBUG)
		If Not ClickBBAttackButton() Then Return False
		If _Sleep(1500) Then Return
		If Not $GoldIsFull And Not $ElixIsFull Then UseBuilderJar()
		CheckArmyReady()
		Return True
	EndIf
	
	If $Mode = "DropTrophy" Then 
		SetLog("Preparing Attack for DropTrophy", $COLOR_ACTION)
		Return True
	EndIf
	
	If $Mode = "CleanYard" Then 
		SetLog("Preparing Attack Clean Yard", $COLOR_ACTION)
		Return True
	EndIf
	
	getBuilderCount(True, True)
	If $g_bChkSkipBBAttIfStorageFull And ($GoldIsFull And $ElixIsFull) And $g_iFreeBuilderCountBB = 0 Then
		SetLog("Skip attack, full resources and busy village!", $COLOR_INFO)
		Return False
	EndIf
	
	If $g_bChkBBAttIfStarsAvail Then
		If Not CheckStarsAvail() Then
			If _Sleep(500) Then Return
			ClickAway("Left")
			Return False
		EndIf
	EndIf

	If Not $g_bRunState Then Return ; Stop Button

	If Not ClickBBAttackButton() Then 
		ClickAway("Left")
		Return False
	EndIf
	
	For $i = 1 To 10
		If $g_bDebugSetlog Then SetLog("Searching Find Now Button #" & $i, $COLOR_ACTION)
		If _ColorCheck(_GetPixelColor(655, 440, True), Hex(0x89D239, 6), 20) Then
			If $g_bDebugSetlog Then SetLog("FindNow Button Found!", $COLOR_DEBUG)
			If _Sleep(500) Then Return
			ExitLoop
		EndIf
		If _Sleep(500) Then Return
	Next
	
	If Not CheckArmyReady() Then
		If _Sleep(500) Then Return
		ClickAway("Left")
		Return False
	EndIf
	
	$g_bBBMachineReady = CheckMachReady()
	If $g_bChkBBWaitForMachine And Not $g_bBBMachineReady Then
		SetLog("Battle Machine is not ready.")
		If _Sleep(500) Then Return
		ClickAway("Left")
		Return False
	EndIf

	Return True ; returns true if all checks succeed
EndFunc

Func ClickBBAttackButton()
	If Not $g_bRunState Then Return
	If QuickMis("BC1", $g_sImgBBAttackButton, 16, 590, 110, 630) Then
		Click(62,615) ;click attack button
		For $i = 1 To 5
			If $g_bDebugSetLog Then SetLog("Waiting for Start Attack Window #" & $i, $COLOR_ACTION)
			If _Sleep(500) Then Return
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 720, 140, 800, 200) Then 
				If $g_bDebugSetLog Then SetLog("Start Attack Window Found", $COLOR_DEBUG)
				ExitLoop
			EndIf
		Next
		Return True
	Else
		SetLog("Could not Locate Attack button", $COLOR_ERROR)
		Return False
	EndIf	
EndFunc

Func CheckStarsAvail()
	If Not $g_bRunState Then Return
	Local $bRet = False, $iRemainStars = 0, $iMaxStars = 0
	Local $sStars = getOcrAndCapture("coc-BBAttackAvail", 40, 572, 50, 20)
	
	If $sStars <> "" And StringInStr($sStars, "#") Then 
		Local $aStars = StringSplit($sStars, "#", $STR_NOCOUNT)
		If IsArray($aStars) Then 
			$iRemainStars = $aStars[0]
			$iMaxStars = $aStars[1]
		EndIf
		If Number($iRemainStars) <= Number($iMaxStars) Then
			SetLog("Remain Stars : " & $iRemainStars & "/" & $iMaxStars, $COLOR_INFO)
			$bRet = True
		Else
			SetLog("All attacks used")
		EndIf
	EndIf
	Return $bRet
EndFunc

Func CheckMachReady()
	If Not $g_bRunState Then Return
	Local $bRet = False
	
	If QuickMis("BC1", $g_sImgBBMachReady, 120, 270, 180, 330) Then 
		$bRet = True
		SetLog("Battle Machine ready.")
	EndIf
	Return $bRet
EndFunc

Func CheckArmyReady()
	If Not $g_bRunState Then Return
	local $i = 0
	local $bReady = True, $bNeedTrain = False, $bTraining = False
	
	If _ColorCheck(_GetPixelColor(133, 250, True), Hex(0xEA5054, 6), 20) Then 
		SetLog("Army is not Ready", $COLOR_DEBUG)
		$bNeedTrain = True ;need train, so will train cannon cart
		$bReady = False
	EndIf
	
	If Not $bReady And $bNeedTrain Then
		SetLog("Train to Fill Army", $COLOR_INFO)
		ClickAway()
		If _Sleep(2000) Then Return
		ClickP($aArmyTrainButton, 1, 0, "BB Train Button")
		
		If _Sleep(1000) Then Return ; wait for window
		For $i = 1 To 5
			SetLog("Waiting for Army Window #" & $i, $COLOR_ACTION)
			If _Sleep(500) Then Return
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 790, 130, 840, 170) Then ExitLoop
		Next
		
		Local $Camp = QuickMIS("CNX", $g_sImgFillCamp, 40, 200, 820, 250)
		For $i = 1 To UBound($Camp)
			If QuickMIS("BC1", $g_sImgFillTrain, 40, 400, 750, 550) Then
				Setlog("Fill ArmyCamp with : " & $g_iQuickMISName, $COLOR_DEBUG)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(500) Then Return
			EndIf
		Next
		
		$Camp = QuickMIS("CNX", $g_sImgFillCamp, 40, 200, 820, 250)
		If UBound($Camp) > 0 Then 
			$bReady = False
		Else
			$bReady = True
		EndIf
		
		ClickAway("Left")
		If _Sleep(1000) Then Return ; wait for window close
		ClickBBAttackButton()
	EndIf

	If Not $bReady Then
		SetLog("Army is not ready.")
	Else
		SetLog("Army is ready.")
	EndIf
	Return $bReady
EndFunc

Func BBDropTrophy($iDropCount = 3)
	If Not $g_bRunState Then Return
	If Not $g_bChkBBDropTrophy Then Return
	If Not $g_bStayOnBuilderBase Then $g_bStayOnBuilderBase = True
	SetLog("ForceSwitchifNoCGEvent = " & String($g_bForceSwitchifNoCGEvent), $COLOR_DEBUG)
	
	If $g_bForceSwitchifNoCGEvent Then 
		SetLog("ForceSwitchifNoCGEvent Enabled, Skip BBDropTrophy", $COLOR_SUCCESS)
		Return False
	EndIf
	
	SetLog("Prepare BB Drop Trophy", $COLOR_INFO)
	
	If CheckStarsAvail() Then 
		SetLog("Stars Available, Skip BB Drop Trophy")
		Return False
	EndIf
	
	Local $iCurrentTrophy = 0
	For $iLoop = 1 To $iDropCount
		$iCurrentTrophy = Number(getTrophyMainScreen(67, 84))
		SetLog("Current BB Trophy:[" & $iCurrentTrophy & "] BBDropTrophy Limit:[" & $g_iTxtBBTrophyLowerLimit & "]", $COLOR_INFO)
		If $iCurrentTrophy <= $g_iTxtBBTrophyLowerLimit Then
			SetLog("Skip BB Drop Trophy", $COLOR_INFO)
			Return False
		EndIf
		
		If Not ClickBBAttackButton() Then 
			ClickAway("Left")
			Return False
		Else
			SetLog("Going to attack for BB Drop Trophy #" & $iLoop, $COLOR_ACTION)
			CheckArmyReady()
			
			If Not ClickFindNowButton() Then Return False
			If Not $g_bRunState Then Return
			If Not WaitCloudsBB() Then Return
			AndroidZoomOut() ;zoomout first before any action
			
			Local $iSide = 1
			Local $aBMPos = GetMachinePos()
			Local $BBDP[4][3] = [[1, 430, 130], [2, 128, 330], [3, 744, 330], [1, 596, 458]] ;dummy deploy point, 4 corner
			;$g_BBDP = GetBBDropPoint()
			
			If IsArray($aBMPos) Then
				Local $isBMDeployed = DeployBM($aBMPos, $iSide, $iSide, $BBDP)
				If $isBMDeployed Then
					If _Sleep(1000) Then Return
					If ReturnHomeDropTrophyBB() Then ContinueLoop
				EndIf
			EndIf
			
			; Get troops on attack bar and their quantities
			$g_BBDP = GetBBDropPoint()
			Local $aBBAttackBar = GetAttackBarBB()
			If IsArray($aBBAttackBar) Then
				For $i = 1 To 10
					If $g_bChkDebugAttackBB Then SetLog("Try Drop Troops #" & $i, $COLOR_ACTION)
					DeployBBTroop($aBBAttackBar[0][0], $aBBAttackBar[0][1], $aBBAttackBar[0][2], 1, 1, 2, $g_BBDP)
					If _Sleep(1000) Then Return
					If IsAttackPage() Then ExitLoop
				Next
			EndIf
			
			If ReturnHomeDropTrophyBB() Then ContinueLoop
		EndIf
	Next
	
	SetLog("BBDropTrophy Completed", $COLOR_SUCCESS)
	CollectBBCart()
	Return False
EndFunc

Func ReturnHomeDropTrophyBB($bOnlySurender = False, $bAttackReport = False, $realDamage = "100")
	If Not $g_bRunState Then Return
	SetLog("Returning Home", $COLOR_SUCCESS)
	
	For $i = 1 To 15
		Select
			Case IsBBAttackPage() = True
				Click(65, 520) ;click surrender
				If $g_bChkDebugAttackBB Then SetLog("Click Surrender/EndBattle", $COLOR_ACTION)
				If _Sleep(1000) Then Return
			Case QuickMIS("BC1", $g_sImgBBReturnHome, 390, 510, 470, 570) = True
				If $bOnlySurender Then 
					If $g_bChkDebugAttackBB Then SetLog("ExitLoop, bOnlySurender = " & String($bOnlySurender), $COLOR_ACTION)
					If $bAttackReport THen BBAttackReport($realDamage)
					Return True
				EndIf
				Click($g_iQuickMISX, $g_iQuickMISY)
				If $g_bChkDebugAttackBB Then SetLog("Click Return Home", $COLOR_ACTION)
				If _Sleep(3000) Then Return
			Case QuickMIS("BC1", $g_sImgBBAttackBonus, 395, 460, 468, 500) = True
				SetLog("Congrats Chief, Stars Bonus Awarded", $COLOR_INFO)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(2000) Then Return
				Return True
			Case isOnBuilderBase() = True
				Return True
			Case IsOKCancelPage() = True
				Click($aConfirmSurrender[0], $aConfirmSurrender[1]); Click Okay to Confirm surrender
				If $g_bChkDebugAttackBB Then SetLog("Click OK", $COLOR_ACTION)
				If _Sleep(1000) Then Return
		EndSelect
		If _Sleep(500) Then Return
	Next
	
	Return True
EndFunc

Func UseBuilderJar()
	If Not $g_bRunState Then Return
	If $g_bChkUseBuilderStarJar then 
		If QuickMIS("BC1", $g_sImgDirUseJar, 120, 460, 210, 510) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(1000) Then Return
			If _ColorCheck(_GetPixelColor(420, 430, True), Hex(0x2F93CF, 6), 20) Then
				Click(420, 430)
				SetLog("Succesfully use BuilderBase Jar", $COLOR_SUCCESS)
				If _Sleep(500) Then Return
			EndIf
		EndIf
	EndIf
EndFunc