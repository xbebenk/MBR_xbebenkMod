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
	getBuilderCount(True, True) 
	
	If $g_bChkForceBBAttackOnClanGames And $g_bForceSwitchifNoCGEvent Then 
		SetLog("ForceSwitchifNoCGEvent Enabled, Skip Attack until we have BBEvent", $COLOR_SUCCESS)
		Return False
	EndIf
	
	If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
		SetLog("Running Challenge is BB Challenge", $COLOR_DEBUG)
		SetLog("Force BB Attack on Clan Games Enabled", $COLOR_DEBUG)
		If Not ClickBBAttackButton() Then Return False
		If _Sleep(1500) Then Return
		CheckArmyReady()
		Return True
	EndIf
	
	If $g_bChkStopAttackBB6thBuilder And $g_bIs6thBuilderUnlocked Then
		SetLog("6th Builder Unlocked, attackBB disabled", $COLOR_INFO)
		Return False
	EndIf
	
	Local $GoldIsFull = isGoldFullBB()
	Local $ElixIsFull = isElixirFullBB()

	If $g_bOptimizeOTTO And ($GoldIsFull Or $ElixIsFull) And $g_iFreeBuilderCountBB = 0 Then ; And Not $g_sStarLabUpgradeTime = "" Then
		SetLog("Skip attack, full resources and busy village!", $COLOR_INFO)
		Return False
	EndIf
	
	If $g_bChkBBAttIfLootAvail Then
		If Not CheckLootAvail() Then
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
	
	If $Mode = "DropTrophy" Then 
		SetLog("Preparing Attack for DropTrophy", $COLOR_ACTION)
		Return True
	EndIf
	
	If $Mode = "CleanYard" Then 
		SetLog("Preparing Attack Clean Yard", $COLOR_ACTION)
		Return True
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

Func CheckLootAvail()
	Local $bRet = False, $iRemainStars = 0, $iMaxStars = 0
	Local $sStars = getOcrAndCapture("coc-BBAttackAvail", 40, 572, 50, 20)
	
	If $g_bDebugSetLog Then SetLog("Stars: " & $sStars, $COLOR_DEBUG2)
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
	Local $bRet = False
	
	If QuickMis("BC1", $g_sImgBBMachReady, 120, 270, 180, 330) Then 
		$bRet = True
		SetLog("Battle Machine ready.")
	EndIf
	Return $bRet
EndFunc

Func CheckArmyReady()
	local $i = 0
	local $bReady = True, $bNeedTrain = False, $bTraining = False
	
	If _ColorCheck(_GetPixelColor(126, 246, True), Hex(0xE24044, 6), 20) Then 
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
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 750, 130, 800, 190) Then ExitLoop
		Next
		
		Local $Camp = QuickMIS("CNX", $g_sImgFillCamp, 70, 225, 800, 250)
		For $i = 1 To UBound($Camp)
			If QuickMIS("BC1", $g_sImgFillTrain, 75, 390, 800, 530) Then
				Setlog("Fill ArmyCamp with :" & $g_iQuickMISName, $COLOR_DEBUG)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(500) Then Return
			EndIf
		Next
		
		$Camp = QuickMIS("CNX", $g_sImgFillCamp, 70, 225, 800, 250)
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

Func BBDropTrophy()
	If Not $g_bChkBBDropTrophy Then Return
	SetLog("Prepare BB Drop Trophy", $COLOR_INFO)
	
	$g_aiCurrentLootBB[$eLootTrophyBB] = Number(getTrophyMainScreen(67, 84))
	If $g_aiCurrentLootBB[$eLootTrophyBB] <= $g_iTxtBBTrophyLowerLimit Then
		SetLog("Current BB Trophy:[" & $g_aiCurrentLootBB[$eLootTrophyBB] & "] BBDropTrophy Limit:[" & $g_iTxtBBTrophyLowerLimit & "]", $COLOR_INFO)
		SetLog("Skip BB Drop Trophy", $COLOR_INFO)
		Return
	EndIf
	
	If $g_bChkBBAttIfLootAvail Then 
		If CheckLootAvail() Then 
			SetLog("BB Loot Available, Skip BB Drop Trophy")
			ClickAway("Left")
			If _Sleep(1000) Then Return
			Return False
		EndIf
	EndIf
	
	If Not ClickBBAttackButton() Then 
		ClickAway("Left")
		Return False
	Else
		SetLog("Going to attack for BB Drop Trophy", $COLOR_INFO)
		CheckArmyReady()
		
		If Not ClickFindNowButton() Then Return False
		If Not $g_bRunState Then Return
		If Not WaitCloudsBB() Then Return
		
		Local $iSide = True
		Local $aBMPos = GetMachinePos()
		$g_BBDP = GetBBDropPoint()
		
		Local $Return = False
		If IsArray($aBMPos) Then
			SetLog("Deploying BM")
			DeployBM($aBMPos, $iSide, $iSide, $g_BBDP)
			If ReturnHomeDropTrophyBB() Then Return True
		EndIf
		
		If Not $Return Then
			; Get troops on attack bar and their quantities
			local $aBBAttackBar = GetAttackBarBB()
			If IsArray($aBBAttackBar) Then
				For $i = 1 To 10
					SetDebugLog("Try Drop Troops #" & $i, $COLOR_ACTION)
					DeployBBTroop($aBBAttackBar[0][0], $aBBAttackBar[0][1], $aBBAttackBar[0][2], 1, 1, 2, $g_BBDP)
					If _Sleep(1000) Then Return
					If IsAttackPage() Then ExitLoop
				Next
			EndIf
			If ReturnHomeDropTrophyBB() Then Return True
		EndIf
	EndIf
	If _Sleep(1000) Then Return
	Return False
EndFunc

Func ReturnHomeDropTrophyBB($bOnlySurender = False)
	
	For $i = 1 To 5 
		SetDebugLog("Waiting Surrender button #" & $i, $COLOR_ACTION)
		If IsBBAttackPage() Then
			Click(65, 520) ;click surrender
			If _Sleep(1000) Then Return
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	
	For $i = 1 To 5
		SetDebugLog("Waiting OK Cancel Window #" & $i, $COLOR_ACTION)
		If IsOKCancelPage(True) Then
			Click(510, 400); Click Okay to Confirm surrender
			If _Sleep(1000) Then Return
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	
	If $bOnlySurender Then Return True
	
	For $i = 1 To 10
		SetDebugLog("Waiting EndBattle Window #" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgBBReturnHome, 390, 520, 470, 560) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(3000) Then Return
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	
	ClickAway("Left")
	If _Sleep(2000) Then Return
	ZoomOut(True)
	Return True
EndFunc