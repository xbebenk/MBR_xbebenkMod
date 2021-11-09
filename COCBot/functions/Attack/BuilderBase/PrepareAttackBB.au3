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
	
	If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
		Setlog("Running Challenge is BB Challenge", $COLOR_DEBUG)
		SetLog("Force BB Attack on Clan Games Enabled", $COLOR_DEBUG)
		If Not ClickAttack() Then Return False
		_Sleep(1500)
		CheckArmyReady()
		CheckLootAvail()
		$g_bBBMachineReady = CheckMachReady()
		Return True
	EndIf
	
	If ($g_bGoldStorageFullBB Or $g_bElixirStorageFullBB) And $g_iChkBBSuggestedUpgradesOTTO Then 
		Setlog("Gold or Elixir is nearly full", $COLOR_DEBUG)
		Return False
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

<<<<<<< HEAD
	If Not ClickAttack() Then Return False
	_Sleep(500)
=======
	Click(60,600) ;click attack button
	_Sleep(1500)
>>>>>>> 07e7786fd0dc8035006cd36150c5ca3cc00e78f7

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

Func ClickAttack()
	local $aColors = [[0xfdd79b, 96, 0], [0xffffff, 20, 50], [0xffffff, 69, 50]] ; coordinates of pixels relative to the 1st pixel
	Local $ButtonPixel = _MultiPixelSearch(8, 640, 120, 755, 1, 1, Hex(0xeac68c, 6), $aColors, 20)
	local $bRet = False

	If Not $g_bRunState Then Return ; Stop Button
	
	If IsArray($ButtonPixel) Then
		SetDebugLog(String($ButtonPixel[0]) & " " & String($ButtonPixel[1]))
		PureClick($ButtonPixel[0] + 25, $ButtonPixel[1] + 25) ; Click fight Button
		$bRet = True
	Else
		SetLog("Can not find button for Builders Base Attack button", $COLOR_ERROR)
	EndIf
	_Sleep(500)
	Return $bRet
EndFunc

Func CheckLootAvail()
	local $bRet = False
<<<<<<< HEAD
	If Not _ColorCheck(_GetPixelColor(621, 666, True), Hex(0xFFFFFF, 6), 1) Then
=======
	If Not _ColorCheck(_GetPixelColor(622, 611, True), Hex(0xFFFFFF, 6), 1) Then
>>>>>>> 07e7786fd0dc8035006cd36150c5ca3cc00e78f7
		SetLog("Loot is Available.")
		$bRet = True
	Else
		SetLog("No loot available.")
	EndIf
	Return $bRet
EndFunc

Func CheckMachReady()
	local $aCoords = decodeSingleCoord(findImage("BBMachReady_bmp", $g_sImgBBMachReady, GetDiamondFromRect("113,388,170,448"), 1, True))
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
	local $sSearchDiamond = GetDiamondFromRect("114,384,190,450") ; start of trained troops bar untill a bit after the 'r' "in Your Troops"

	If _Sleep($DELAYCHECKFULLARMY2) Then Return ; wait for window
	If QuickMIS("BC1", $g_sImgArmyReady, 110, 360, 135, 385, True, False) Then
		$bReady = True
	Else 
		$bReady = False
		If QuickMIS("BC1", $g_sImgArmyNeedTrain, 130, 390, 190, 420, True, False) Then
			$bNeedTrain = True ;need train, so will train cannon cart
		Else
			$bReady = True ;green check mark, not found but no need to train, so Army is Ready
		EndIf
	EndIf
	
	If Not $bReady And $bNeedTrain And $g_bTrainTroopBBCannonnCart Then
		ClickP($aArmyTrainButton, 1, 0, "#0293")
		If _Sleep(1000) Then Return ; wait for window
		Local $sCannonCart
		If QuickMIS("BC1", $g_sImgFillTrain, 40, 470, 820, 580, True, False) Then
			Setlog("Army is not ready, Try to Train to fill BB ArmyCamp", $COLOR_DEBUG)
			Click($g_iQuickMISX + 40, $g_iQuickMISY + 470, 1)
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
