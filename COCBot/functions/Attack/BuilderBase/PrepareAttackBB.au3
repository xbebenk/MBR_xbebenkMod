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
		
	If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
		SetLog("Running Challenge is BB Challenge", $COLOR_DEBUG)
		SetLog("Force BB Attack on Clan Games Enabled", $COLOR_DEBUG)
		If Not ClickBBAttackButton() Then Return False
		_Sleep(1500)
		CheckArmyReady()
		Return True
	EndIf
	
	Local $GoldIsFull = isGoldFullBB()
	Local $ElixIsFull = isElixirFullBB()

	If $g_bOptimizeOTTO And ($GoldIsFull Or $ElixIsFull) And $g_iFreeBuilderCountBB = 0 Then ; And Not $g_sStarLabUpgradeTime = "" Then
		SetLog("Skip attack, full resources and busy village!", $COLOR_INFO)
		Return False
	EndIf

	If Not $g_bRunState Then Return ; Stop Button

	If Not ClickBBAttackButton() Then 
		ClickAway("Left")
		Return False
	EndIf
	;_Sleep(1000)
	For $i = 1 To 5
		If WaitforPixel(588, 321, 589, 322, "D7540E", 20, 2) Then
			SetDebugLog("Found FindNow Button", $COLOR_ACTION)
			_Sleep(500)
			ExitLoop
		EndIf
		If WaitforPixel(665, 437, 666, 438, "D9F481", 20, 1) Then
			SetDebugLog("Found Previous Attack Result", $COLOR_ACTION)
			Click(640, 440)
			_Sleep(500)
		EndIf
		_Sleep(1000)
		SetDebugLog("Wait For Find Now Button #" & $i, $COLOR_ACTION)
	Next
	
	If Not CheckArmyReady() Then
		_Sleep(500)
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
	
	If $g_bChkBBAttIfLootAvail Then
		If Not CheckLootAvail() Then
			_Sleep(500)
			ClickAway("Left")
			Return False
		EndIf
	EndIf

	$g_bBBMachineReady = CheckMachReady()
	If $g_bChkBBWaitForMachine And Not $g_bBBMachineReady Then
		SetLog("Battle Machine is not ready.")
		_Sleep(500)
		ClickAway("Left")
		Return False
	EndIf

	Return True ; returns true if all checks succeed
EndFunc

Func ClickBBAttackButton()
	If WaitforPixel(20, 590, 22, 595, "DD9835", 15, 1) Then
		Click(60,600) ;click attack button
		Return True
	Else
		SetLog("Could not locate Attack button", $COLOR_ERROR)
		Return False
	EndIf	
EndFunc

Func CheckLootAvail()
	local $bRet = False
	If Not _ColorCheck(_GetPixelColor(622, 611, True), Hex(0xFFFFFF, 6), 1) Then
		SetLog("Loot is Available.")
		$bRet = True
	Else
		SetLog("No loot available.")
	EndIf
	Return $bRet
EndFunc

Func CheckMachReady()
	local $aCoords = decodeSingleCoord(findImage("BBMachReady_bmp", $g_sImgBBMachReady, GetDiamondFromRect("113,360,170,415"), 1, True))
	local $bRet = False
	
	If IsArray($aCoords) And UBound($aCoords) = 2 Then
		$bRet = True
		SetLog("Battle Machine ready.")
	EndIf
	Return $bRet
EndFunc

Func CheckArmyReady()
	local $i = 0
	local $bReady = True, $bNeedTrain = False, $bTraining = False
	
	If _Sleep($DELAYCHECKFULLARMY2) Then Return ; wait for window
	
	If QuickMIS("BC1", $g_sImgArmyNeedTrain, 130, 360, 190, 390) Then
		$bNeedTrain = True ;need train, so will train cannon cart
		$bReady = False
	EndIf
	
	If Not $bReady And $bNeedTrain Then
		ClickP($aArmyTrainButton, 1, 0, "#0293")
		If _Sleep(1000) Then Return ; wait for window
		Local $Camp = QuickMIS("CNX", $g_sImgFillCamp, 40, 320, 800, 350)
		For $i = 1 To UBound($Camp)
			If QuickMIS("BC1", $g_sImgFillTrain, 40, 440, 820, 550) Then
				Setlog("Army is not ready, fill BB ArmyCamp", $COLOR_DEBUG)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(500) Then Return
			EndIf
		Next
		$Camp = QuickMIS("CNX", $g_sImgFillCamp, 40, 320, 800, 350)
		If UBound($Camp) > 0 Then 
			$bReady = False
		Else
			$bReady = True
		EndIf
		ClickAway("Left")
		If _Sleep(1000) Then Return ; wait for window close
	EndIf

	If Not $bReady Then
		SetLog("Army is not ready.")
		If $bTraining Then SetLog("Troops are training.")
		If $bNeedTrain Then SetLog("Troops need to be trained in the training tab.")
		If $g_bDebugImageSave Then SaveDebugImage("FindIfArmyReadyBB")
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
	
	If ClickBBAttackButton() Then 
		For $i = 1 To 5
			If WaitforPixel(588, 321, 589, 322, "D7540E", 20, 2) Then
				SetDebugLog("Found FindNow Button", $COLOR_ACTION)
				_Sleep(500)
				ExitLoop
			EndIf
			If WaitforPixel(665, 437, 666, 438, "D9F481", 20, 1) Then
				SetDebugLog("Found Previous Attack Result", $COLOR_ACTION)
				Click(640, 440)
				_Sleep(500)
			EndIf
			_Sleep(1000)
			SetDebugLog("Wait For Find Now Button #" & $i, $COLOR_ACTION)
		Next
		
		If CheckLootAvail() Then 
			SetLog("BB Loot Available, Skip BB Drop Trophy")
			ClickAway()
			_Sleep(1000)
			Return False
		Else
			CheckArmyReady()
			SetLog("Going to attack for BB Drop Trophy", $COLOR_INFO)
			local $aBBFindNow = [521, 278, 0xffc246, 30] ; search button
			If _CheckPixel($aBBFindNow, True) Then
				PureClick($aBBFindNow[0], $aBBFindNow[1])
			Else
				SetLog("Could not locate search button to go find an attack.", $COLOR_ERROR)
				ClickAway()
				Return False
			EndIf
			
			If _Sleep(1500) Then Return ; give time for find now button to go away
			If Not $g_bRunState Then Return ; Stop Button
			; wait for the clouds to clear
			SetLog("Searching for Opponent.", $COLOR_BLUE)
			
			Local $count = 1
			While Not WaitforPixel(88, 586, 89, 588, "5095D8", 10, 1) 
				SetDebugLog("Waiting Attack Page #" & $count, $COLOR_ACTION)
				If $count > 20 Then 
					CloseCoC(True)
					Return ;xbebenk, prevent bot to long on cloud?, in fact BB attack should only takes seconds to search
				EndIf
				If isProblemAffect(True) Then Return
				If Not $g_bRunState Then Return ; Stop Button
				$count += 1
				_Sleep(2000)
			WEnd
			
			Local $iSide = True
			Local $aBMPos = GetMachinePos()
			$g_BBDP = GetBBDropPoint()
			
			Local $Return = False
			If IsArray($aBMPos) Then
				SetLog("Deploying BM")
				DeployBM($aBMPos, $iSide)
				If ReturnHomeDropTrophyBB() Then Return True
			EndIf
			
			If Not $Return Then
				; Get troops on attack bar and their quantities
				local $aBBAttackBar = GetAttackBarBB()
				If IsArray($aBBAttackBar) Then
					For $i = 1 To 10
						SetDebugLog("Try Drop Troops #" & $i, $COLOR_ACTION)
						DeployBBTroop($aBBAttackBar[0][0], $aBBAttackBar[0][1], $aBBAttackBar[0][2], 1, 1, 2, $g_BBDP)
						_Sleep(1000)
						If IsAttackPage() Then ExitLoop
					Next
				EndIf
				If ReturnHomeDropTrophyBB() Then Return True
			EndIf
		EndIf
	EndIf
	Return False
EndFunc

Func ReturnHomeDropTrophyBB()
	For $i = 1 To 5 
		SetDebugLog("Waiting Surrender button #" & $i, $COLOR_ACTION)
		If IsAttackPage() Then
			Click(65, 540) ;click surrender
			_Sleep(1000)
			ExitLoop
		EndIf
		_Sleep(1000)
	Next
	
	For $i = 1 To 5
		SetDebugLog("Waiting OK Cancel Window #" & $i, $COLOR_ACTION)
		If IsOKCancelPage(True) Then
			Click(510, 400); Click Okay to Confirm surrender
			_Sleep(1000)
			ExitLoop
		EndIf
		_Sleep(1000)
	Next
	
	For $i = 1 To 10
		SetDebugLog("Waiting EndBattle Window #" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgOkButton, 350, 520, 500, 570) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			_Sleep(3000)
			ExitLoop
		EndIf
		_Sleep(1000)
	Next
	
	For $i = 1 To 10	
		SetDebugLog("Waiting Opponent Attack Window #" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgWatchButton, 520, 280, 570, 370) Then 
			ClickAway("Left")
			ExitLoop
		EndIf
		_Sleep(1000)
	Next
	ClickAway("Left")
	_Sleep(2000)
	ZoomOut()
	Return True
EndFunc