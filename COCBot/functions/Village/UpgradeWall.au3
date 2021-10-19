; #FUNCTION# ====================================================================================================================
; Name ..........: UpgradeWall
; Description ...: This file checks if enough resources to upgrade walls, and upgrades them
; Syntax ........: UpgradeWall()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (2015), HungLe (2015)
; Modified ......: Sardo (08-2015), KnowJack (08-2015), MonkeyHunter(06-2016) , trlopes (07-2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: checkwall.au3
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func UpgradeWall()
	
	Local $aSelectedWall[3][2]
	For $z = 0 To 2 
		$aSelectedWall[$z][0] = $g_aUpgradeWall[$z]
		$aSelectedWall[$z][1] = $g_aiWallCost[$g_aUpgradeWall[$z]]
	Next
	
	Local $iWallCost = $aSelectedWall[0][1]
	Local $iWallLevel = $aSelectedWall[0][0]
	Local $GoUpgrade = False
	If Not $g_bRunState Then Return
	
	If Not $g_bAutoUpgradeWallsEnable Then Return
	
	SetLog("Checking Upgrade Walls", $COLOR_INFO)
	VillageReport(True, True) ;update village resource capacity
	SetLog("FreeBuilderCount: " & $g_iFreeBuilderCount, $COLOR_DEBUG)
	If $g_iFreeBuilderCount < 1 Then Return
	If Not IsResourceEnough($iWallCost) Then Return
	
	If $g_iFreeBuilderCount = 0 Then
		SetLog("No builder available, Upgrade Walls skipped", $COLOR_DEBUG)
		Return
	EndIf
	
	If $g_iFreeBuilderCount > 0 Then $GoUpgrade = True
	If $g_bChkOnly1Builder And $g_iFreeBuilderCount > 1 Then 
		SetLog("Have more than 1 builder, Upgrade Walls skipped", $COLOR_DEBUG)
		$GoUpgrade = False
	EndIf
	If $g_iFreeBuilderCount > 1 And $g_bUpgradeWallSaveBuilder Then 
		SetLog("Ooops, Chief you are reserve one for wall, sure we will Upgrade Walls", $COLOR_DEBUG)
		$GoUpgrade = True
	EndIf
	
	If $GoUpgrade And $g_bUpgradeLowWall Then 
		UpgradeLowLevelWall()
	EndIf
	
	If $GoUpgrade Then
		ClickAway()
		VillageReport(True, True) ;update village resource capacity
		For $z = 0 To 2
			$iWallCost = $aSelectedWall[$z][1]
			$iWallLevel = $aSelectedWall[$z][0]
			SetLog("[" & $z & "] Try Upgrade WallLevel[" & $iWallLevel + 4 & "] Cost:" & $iWallCost, $COLOR_DEBUG)
			Local $MinWallGold = IsResourceEnough($iWallCost)
			Local $MinWallElixir = IsResourceEnough($iWallCost)
			If Not $MinWallGold And Not $MinWallElixir Then ExitLoop
			
			While $MinWallGold Or $MinWallElixir
				;check for gold wall upgrade
				If $g_iUpgradeWallLootType = 0 Then
					SetLog("Upgrading Wall using Gold", $COLOR_SUCCESS)
					If imglocCheckWall($iWallLevel) Then
						If Not UpgradeWallGold($iWallCost) Then
							SetLog("Upgrade with Gold failed, skipping...", $COLOR_ERROR)
							ExitLoop
						EndIf
					Else
						SetLog("Upgrade with Gold For Wall Level " & $iWallLevel + 4 & " is Failed", $COLOR_ERROR)
						ExitLoop
					EndIf
				EndIf
				
				;check for elixir wall upgrade
				If $g_iUpgradeWallLootType = 1 Then
					SetLog("Upgrading Wall using Elixir", $COLOR_SUCCESS)
					If imglocCheckWall($iWallLevel) Then
						If Not UpgradeWallElixir($iWallCost) Then
							SetLog("Upgrade with Elixir failed, skipping...", $COLOR_ERROR)
							ExitLoop
						EndIf
					Else
						SetLog("Upgrade with Elixir For Wall Level " & $iWallLevel + 4 & " is Failed", $COLOR_ERROR)
						ExitLoop
					EndIf
				EndIf
				
				;check for both gold and elixir wall upgrade
				If $g_iUpgradeWallLootType = 2 Then 
					If $MinWallElixir Then
						SetLog("Upgrading Wall using Elixir", $COLOR_SUCCESS)
						If imglocCheckWall($iWallLevel) Then
							If Not UpgradeWallElixir($iWallCost) Then
								SetLog("Upgrade with Elixir failed, attempt to upgrade using Gold", $COLOR_ERROR)
								If Not UpgradeWallElixir($iWallCost) Then
									SetLog("Upgrade with Elixir failed, skipping...", $COLOR_ERROR)
									ExitLoop
								EndIf
							EndIf
						Else
							SetLog("Upgrade with Elixir For Wall Level " & $iWallLevel + 4 & " is Failed", $COLOR_ERROR)
							ExitLoop
						EndIf
					EndIf
						
					If $MinWallGold Then
						SetLog("Upgrading Wall using Gold", $COLOR_SUCCESS)
						If imglocCheckWall($iWallLevel) Then
							If Not UpgradeWallGold($iWallCost) Then
								SetLog("Upgrade with Gold failed, skipping...", $COLOR_ERROR)
								ExitLoop
							EndIf
						Else
							SetLog("Upgrade with Gold For Wall Level " & $iWallLevel + 4 & " is Failed", $COLOR_ERROR)
							ExitLoop
						EndIf
					Else
						SetLog("Gold is below minimum, Skipping Upgrade", $COLOR_ERROR)
					EndIf
					
				EndIf
			
				; Check Builder/Shop if open by accident
				If _CheckPixel($g_aShopWindowOpen, $g_bCapturePixel, Default, "ChkShopOpen", $COLOR_DEBUG) = True Then
					Click(820, 40, 1, 0, "#0315") ; Close it
				EndIf

				ClickAway()
				VillageReport(True, True)
				If Not IsResourceEnough($iWallCost) Then ExitLoop
				$MinWallGold = Number($g_aiCurrentLoot[$eLootGold] - $iWallCost) > Number($g_iUpgradeWallMinGold) ; Check if enough Gold
				$MinWallElixir = Number($g_aiCurrentLoot[$eLootElixir] - $iWallCost) > Number($g_iUpgradeWallMinElixir) ; Check if enough Elixir
			WEnd
		Next
		
	EndIf
	checkMainScreen(False) ; Check for errors during function

EndFunc   ;==>UpgradeWall

Func UpgradeLowLevelWall()
	VillageReport(True, True) ;update village resource capacity
	ClickMainBuilder()
	Local $aWallCoord, $WallLevel, $Wall
	
	While 1
		If Not $g_bRunState Then Return
		$aWallCoord = ClickDragFindWallUpgrade()
		$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(701, 23) ;get current Gold
		$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(701, 74) ;get current Elixir
		If IsArray($aWallCoord) And UBound($aWallCoord) > 0 Then 
			For $i = 0 To UBound($aWallCoord) - 1
				$Wall = StringSplit($aWallCoord[$i], ",", $STR_NOCOUNT)
				SetLog("Wall " & "[" & $i & "] : [" & $Wall[0] + 180 & "," & $Wall[1] + 80 & "]", $COLOR_DEBUG)
				Click($Wall[0] + 180, $Wall[1] + 80)
				If _Sleep(800) Then Return
				$WallLevel = BuildingInfo(242, 490 + $g_iBottomOffsetY)
				If $WallLevel[0] = "" Then
					SetLog("Error when trying to get upgrade name and level, looking next...", $COLOR_ERROR)
					ContinueLoop
				EndIf
				If $WallLevel[1] = "Wall" And $WallLevel[2] > 4 Then
					SetLog("Wall Level : " & $WallLevel[2], $COLOR_ERROR)
					SetLog("We Only want to upgrade for Low Level Wall, looking next...", $COLOR_ERROR)
					ContinueLoop
				Else
					If $g_aiCurrentLoot[$eLootGold] < $g_iUpgradeWallMinGold Then 
						SetLog("Current Gold: " & $g_aiCurrentLoot[$eLootGold] & ", already below " & $g_iUpgradeWallMinGold, $COLOR_INFO)
						ExitLoop 2
					Else
						SetLog("Wall Level : " & $WallLevel[2], $COLOR_SUCCESS)
						If Not DoLowLevelWallUpgrade($WallLevel[2]) Then ExitLoop 2
					EndIf
				EndIf
				If Not QuickMIS("BC1", $g_sImgAUpgradeWall, 180, 80, 330, 369) Then ExitLoop
			Next
		Else
			ExitLoop
		EndIf
	Wend
	ClickAway()
	CheckMainScreen(False)
EndFunc

Func DoLowLevelWallUpgrade($WallLevel = 1)
	If $WallLevel < 3 Then
		SetLog("Trying Upgrade Wall Level : " & $WallLevel & " Once in a Row", $COLOR_INFO)
		If ClickB("SelectRow") Then
			If _Sleep(1000) Then Return 
			For $x = $WallLevel To 3 ;try to upgrade till lvl 4
				$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(701, 23) ;get current Gold
				$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(701, 74) ;get current Elixir
				If $g_aiCurrentLoot[$eLootGold] < $g_iUpgradeWallMinGold Then 
					SetLog("Current Gold: " & $g_aiCurrentLoot[$eLootGold] & ", already below " & $g_iUpgradeWallMinGold, $COLOR_INFO)
					Return False
				EndIf
				If Not $g_bRunState Then Return
				If QuickMIS("BC1", $g_sImgAUpgradeWhiteZeroWallUpgrade, 400, 550, 530, 640) Then
					Click($g_iQuickMISX + 400, $g_iQuickMISY + 550)
					If _Sleep(1500) Then Return
					If QuickMIS("BC1", $g_sImgAUpgradeWallOK, 400, 400, 600, 470) Then
						Click($g_iQuickMISX + 400, $g_iQuickMISY + 400)
						SetLog("Successfully Upgrade a Row of Wall Level " & $x, $COLOR_SUCCESS)
					EndIf
				Else
					SetLog("Not Enough Resource...", $COLOR_ERROR)
					Return False
				EndIf
				If _Sleep(1000) Then Return
			Next
		Else
			SetLog("Cannot Select Row", $COLOR_INFO)
			For $x = $WallLevel To 3 ;try to upgrade till lvl 4
				$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(701, 23) ;get current Gold
				$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(701, 74) ;get current Elixir
				If $g_aiCurrentLoot[$eLootGold] < $g_iUpgradeWallMinGold Then 
					SetLog("Current Gold: " & $g_aiCurrentLoot[$eLootGold] & ", already below " & $g_iUpgradeWallMinGold, $COLOR_INFO)
					Return False
				EndIf
				If QuickMIS("BC1", $g_sImgAUpgradeWhiteZeroWallUpgrade, 400, 550, 530, 640) Then
					Click($g_iQuickMISX + 400, $g_iQuickMISY + 550)
					If _Sleep(1500) Then Return
					Click(440, 530)
					SetLog("Successfully Upgrade Level " & $x, $COLOR_SUCCESS)
				Else
					SetLog("Not Enough Resource...", $COLOR_ERROR)
					Return False
				EndIf
				If _Sleep(1000) Then Return
			Next
		EndIf
	Else
		SetLog("Skip Upgrade Wall Level : " & $WallLevel, $COLOR_ERROR)
		Return False
	EndIf
	Return True
EndFunc

Func ClickDragFindWallUpgrade()
	Local $x = 330, $yUp = 40, $Delay = 500
	Local $YY = 350
	Local $aWallCoord, $aResult[0]
	For $checkCount = 0 To 4
		If Not $g_bRunState Then Return
		If (_ColorCheck(_GetPixelColor(422, 73, True), "fdfefd", 20) = True) Then
			ClickDrag($x, $YY, $x, $yUp, $Delay) ;drag up
			If _Sleep(2000) Then Return
			$aWallCoord = QuickMIS("CX", $g_sImgAUpgradeWall, 180, 80, 330, 369)
			If IsArray($aWallCoord) And UBound($aWallCoord) > 0 Then
				SetLog("Found " & UBound($aWallCoord) & " Wall", $COLOR_DEBUG)
				ExitLoop
			EndIf
		EndIf
		If (_ColorCheck(_GetPixelColor(422, 73, True), "fdfefd", 20) = True) Then
			SetLog("Upgrade Window Exist", $COLOR_INFO)
		Else
			SetLog("Upgrade Window Gone!", $COLOR_DEBUG)
			Click(295, 30)
			If _Sleep(2000) Then Return
		EndIf
	Next
	If IsArray($aWallCoord) And UBound($aWallCoord) > 0 Then
		_ArraySort($aWallCoord,1,0)
		SetLog(_ArrayToString($aWallCoord), $COLOR_DEBUG)
		$aResult = $aWallCoord
	EndIf
	Return $aResult
EndFunc ;==>IsUpgradeWindow

Func UpgradeWallGold($iWallCost = $g_iWallCost)

	If _Sleep($DELAYRESPOND) Then Return

	Local $aUpgradeButton = findButton("UpgradeWall", Default, 2, True)
	If IsArray($aUpgradeButton) And UBound($aUpgradeButton) > 0 Then
		;Check for Gold in right top button corner and click, if present
		Local $FoundGold = decodeSingleCoord(findImage("UpgradeWallGold", $g_sImgUpgradeWallGold, GetDiamondFromRect("200, 570, 670, 630"), 1, True))
		If UBound($FoundGold) > 1 Then 
			Click($FoundGold[0], $FoundGold[1])
		EndIf
	EndIf

	If _Sleep($DELAYUPGRADEWALLGOLD2) Then Return

	If _ColorCheck(_GetPixelColor(677, 150 + $g_iMidOffsetY, True), Hex(0xE1090E, 6), 20) Then ; wall upgrade window red x
		If isNoUpgradeLoot(False) = True Then
			SetLog("Upgrade stopped due no loot", $COLOR_ERROR)
			Return False
		EndIf
		Click(440, 480 + $g_iMidOffsetY, 1, 0, "#0317")
		If _Sleep(1000) Then Return
		If isGemOpen(True) Then
			ClickAway()
			SetLog("Upgrade stopped due no loot", $COLOR_ERROR)
			Return False
		ElseIf _ColorCheck(_GetPixelColor(677, 150 + $g_iMidOffsetY, True), Hex(0xE1090E, 6), 20) Then ; wall upgrade window red x, didnt closed on upgradeclick, so not able to upgrade
			ClickAway()
			SetLog("unable to upgrade", $COLOR_ERROR)
			Return False
		Else
			If _Sleep($DELAYUPGRADEWALLGOLD3) Then Return
			ClickAway()
			SetLog("Upgrade complete", $COLOR_SUCCESS)
			PushMsg("UpgradeWithGold")
			$g_iNbrOfWallsUppedGold += 1
			$g_iNbrOfWallsUpped += 1
			$g_iCostGoldWall += $iWallCost
			UpdateStats()
			Return True
		EndIf
	EndIf

	ClickAway()
	SetLog("No Upgrade Gold Button", $COLOR_ERROR)
	Pushmsg("NowUpgradeGoldButton")
	Return False

EndFunc   ;==>UpgradeWallGold

Func UpgradeWallElixir($iWallCost = $g_iWallCost)

	If _Sleep($DELAYRESPOND) Then Return

	Local $aUpgradeButton = findButton("UpgradeWall", Default, 2, True)
	If IsArray($aUpgradeButton) And UBound($aUpgradeButton) > 0 Then
		;Check for elixircolor in right top button corner and click, if present
		Local $FoundElixir = decodeSingleCoord(findImage("UpgradeWallElixir", $g_sImgUpgradeWallElix, GetDiamondFromRect("200, 570, 670, 630"), 1, True, Default))
		If UBound($FoundElixir) > 1 Then 
			Click($FoundElixir[0], $FoundElixir[1])		
		EndIf	
	EndIf

	If _Sleep($DELAYUPGRADEWALLELIXIR2) Then Return

	If _ColorCheck(_GetPixelColor(677, 150 + $g_iMidOffsetY, True), Hex(0xE1090E, 6), 20) Then
		If isNoUpgradeLoot(False) = True Then
			SetLog("Upgrade stopped due to insufficient loot", $COLOR_ERROR)
			Return False
		EndIf
		Click(440, 480 + $g_iMidOffsetY, 1, 0, "#0318")
		If _Sleep(1000) Then Return
		If isGemOpen(True) Then
			ClickAway()
			SetLog("Upgrade stopped due to insufficient loot", $COLOR_ERROR)
			Return False
		ElseIf _ColorCheck(_GetPixelColor(677, 150 + $g_iMidOffsetY, True), Hex(0xE1090E, 6), 20) Then ; wall upgrade window red x, didnt closed on upgradeclick, so not able to upgrade
			ClickAway()
			SetLog("unable to upgrade", $COLOR_ERROR)
			Return False
		Else
			If _Sleep($DELAYUPGRADEWALLELIXIR3) Then Return
			ClickAway()
			SetLog("Upgrade complete", $COLOR_SUCCESS)
			PushMsg("UpgradeWithElixir")
			$g_iNbrOfWallsUppedElixir += 1
			$g_iNbrOfWallsUpped += 1
			$g_iCostElixirWall += $iWallCost
			UpdateStats()
			Return True
		EndIf
	EndIf

	ClickAway()
	SetLog("No Upgrade Elixir Button", $COLOR_ERROR)
	Pushmsg("NowUpgradeElixirButton")
	Return False

EndFunc   ;==>UpgradeWallElixir

Func IsResourceEnough($iWallCost = $g_aUpgradeWall[0])
	Local $EnoughGold = True, $EnoughElix = True
	Switch $g_iUpgradeWallLootType
		Case 0 ; Using gold
			If ($g_aiCurrentLoot[$eLootGold] - $iWallCost) < $g_iUpgradeWallMinGold Then
				SetLog("[Using Gold] " & $g_aiCurrentLoot[$eLootGold] & " - " & $iWallCost & " = " & ($g_aiCurrentLoot[$eLootGold] - $iWallCost) & " < " & $g_iUpgradeWallMinGold, $COLOR_INFO)
				SetLog("Skip Wall upgrade - Insufficient Gold", $COLOR_DEBUG)
				Return False
			EndIf
		Case 1 ; Using elixir
			If ($g_aiCurrentLoot[$eLootElixir] - $iWallCost) < $g_iUpgradeWallMinElixir Then
				SetLog("[Using Elixir] " & $g_aiCurrentLoot[$eLootElixir] & " - " & $iWallCost & " = " & ($g_aiCurrentLoot[$eLootElixir] - $iWallCost) & " < " & $g_iUpgradeWallMinElixir, $COLOR_INFO)
				SetLog("Skip Wall upgrade - Insufficient Elixir", $COLOR_DEBUG)
				Return False
			EndIf
		Case 2 ; Using gold and elixir
			If ($g_aiCurrentLoot[$eLootGold] - $iWallCost) < $g_iUpgradeWallMinGold Then
				SetLog("[Using Gold] " & $g_aiCurrentLoot[$eLootGold] & " - " & $iWallCost & " = " & ($g_aiCurrentLoot[$eLootGold] - $iWallCost) & " < " & $g_iUpgradeWallMinGold, $COLOR_INFO)
				$EnoughGold = False
			EndIf
			If ($g_aiCurrentLoot[$eLootElixir] - $iWallCost) < $g_iUpgradeWallMinElixir Then
				SetLog("[Using Elixir] " & $g_aiCurrentLoot[$eLootElixir] & " - " & $iWallCost & " = " & ($g_aiCurrentLoot[$eLootElixir] - $iWallCost) & " < " & $g_iUpgradeWallMinElixir, $COLOR_INFO)
				$EnoughElix = False
			EndIf
			If Not $EnoughGold And Not $EnoughElix Then 
				SetLog("Skip Wall upgrade - Insufficient Gold or Elixir", $COLOR_DEBUG)
				Return False
			EndIf
	EndSwitch
	Return True
EndFunc
