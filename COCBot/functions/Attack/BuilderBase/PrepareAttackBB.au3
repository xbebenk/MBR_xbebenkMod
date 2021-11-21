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

Func PrepareAttackBB($bCheck = False)
	AutoUpgradeBBCheckBuilder()
	
	If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
		Setlog("Running Challenge is BB Challenge", $COLOR_DEBUG)
		SetLog("Force BB Attack on Clan Games Enabled", $COLOR_DEBUG)
		Click(60,600) ;click attack button
		_Sleep(1500)
		CheckArmyReady()
		CheckLootAvail()
		$g_bBBMachineReady = CheckMachReady()
		Return True
	EndIf
	
	If $g_iChkBBSuggestedUpgradesOTTO and $g_iFreeBuilderCountBB = 0 Then 
		isElixirFullBB()
		isGoldFullBB()
		If $g_bGoldStorageFullBB Then
			Setlog("Gold Storage is nearly full, skip attack", $COLOR_INFO)
			Return False
		EndIf
		If $g_bElixirStorageFullBB Then
			Setlog("Elixir Storage is nearly full, skip attack", $COLOR_INFO)
			Return False
		EndIf
	EndIf
	
	If $g_bChkBBTrophyRange Then
		If ($g_aiCurrentLootBB[$eLootTrophyBB] > $g_iTxtBBTrophyUpperLimit or $g_aiCurrentLootBB[$eLootTrophyBB] < $g_iTxtBBTrophyLowerLimit) Then
			SetLog("Trophies out of range.")
			SetDebugLog("Current Trophies: " & $g_aiCurrentLootBB[$eLootTrophyBB] & " Lower Limit: " & $g_iTxtBBTrophyLowerLimit & " Upper Limit: " & $g_iTxtBBTrophyUpperLimit)
			_Sleep(1500)
			Return False
		EndIf
	EndIf
	
	If Not $g_bRunState Then Return ; Stop Button

	Click(60,600) ;click attack button
	_Sleep(1500)

	If Not CheckArmyReady() Then
		_Sleep(500)
		ClickAway()
		Return False
	EndIf

	If $g_bChkBBAttIfLootAvail Then
		If Not CheckLootAvail() Then
			_Sleep(500)
			ClickAway()
			Return False
		EndIf
	EndIf

	$g_bBBMachineReady = CheckMachReady()
	If $g_bChkBBWaitForMachine And Not $g_bBBMachineReady Then
		SetLog("Battle Machine is not ready.")
		_Sleep(500)
		ClickAway()
		Return False
	EndIf

	Return True ; returns true if all checks succeed
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
	If QuickMIS("BC1", $g_sImgArmyReady, 110, 330, 135, 355, True, False) Then
		$bReady = True
	Else 
		$bReady = False
		If QuickMIS("BC1", $g_sImgArmyNeedTrain, 130, 360, 190, 390, True, False) Then
			$bNeedTrain = True ;need train, so will train cannon cart
		Else
			$bReady = True ;green check mark, not found but no need to train, so Army is Ready
		EndIf
	EndIf
	
	If Not $bReady And $bNeedTrain And $g_bTrainTroopBBCannonnCart Then
		ClickP($aArmyTrainButton, 1, 0, "#0293")
		If _Sleep(1000) Then Return ; wait for window
		Local $sCannonCart
		If QuickMIS("BC1", $g_sImgFillTrain, 40, 440, 820, 550, True, False) Then
			Setlog("Army is not ready, Try to Train to fill BB ArmyCamp", $COLOR_DEBUG)
			Click($g_iQuickMISX + 40, $g_iQuickMISY + 440, 1)
			If _Sleep(500) Then Return
			ClickAway()
			$bReady = True
		Else
			Setlog("Army is not ready, and Cannot Find CannonCart Icon to Train", $COLOR_DEBUG)
			ClickAway()
		EndIf
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
