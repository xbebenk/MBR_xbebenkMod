; #FUNCTION# ====================================================================================================================
; Name ..........:
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values .:
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBotRun. Copyright 2015-2018
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================
Func AutoUpgrade($bTest = False)
	Local $bWasRunState = $g_bRunState
	$g_bRunState = True
	Local $Result = SearchUpgrade($bTest)
	$g_bRunState = $bWasRunState
	Return $Result
EndFunc

Func AutoUpgradeCheckBuilder($bTest = False)
	Local $bRet = False
	Local $iWallReserve

	getBuilderCount(True) ;check if we have available builder
	If $bTest Then
		$g_iFreeBuilderCount = 1
		$bRet = True
	EndIf
	
	;Check if there is a free builder for Auto Upgrade
	$iWallReserve = ($g_bAutoUpgradeWallsEnable And $g_bUpgradeWallSaveBuilder ? 1 : 0)
	If $g_iFreeBuilderCount > 0 Then ;builder available
		$bRet = True
	EndIf
	If $g_iFreeBuilderCount - $iWallReserve - $g_iHeroReservedBuilder < 1 Then ;check builder reserve on wall and hero upgrade
		SetLog("FreeBuilder=" & $g_iFreeBuilderCount & ", Reserve ForHero=" & $g_iHeroReservedBuilder & " ForWall=" & $iWallReserve, $COLOR_INFO)
		If Not $g_bSkipWallReserve Then SetLog("No builder available. Skipping Auto Upgrade!", $COLOR_WARNING)
		$bRet = False
	EndIf
	If $g_bSkipWallReserve And $g_iFreeBuilderCount > 0 Then 
		SetLog("Current Upgrade remain time < 24h, Will use wall reserved builder!", $COLOR_WARNING)
		$bRet = True
	EndIf
	If $bTest Then $bRet = True
	SetLog("Free Builder : " & $g_iFreeBuilderCount, $COLOR_DEBUG)
	Return $bRet
EndFunc

Func SearchUpgrade($bTest = False)
	SetLog("Check for Auto Upgrade", $COLOR_DEBUG)
	ClickAway()
	Local $bDebug = $g_bDebugSetlog
	If Not $g_bAutoUpgradeEnabled Then Return
	If Not $g_bRunState Then Return
	$g_bSkipWallReserve = False ;reset first
	
	If $g_bUseWallReserveBuilder And $g_bUpgradeWallSaveBuilder Then
		getBuilderCount(True)
		If $g_iFreeBuilderCount = 1 Then
			ClickMainBuilder()
			SetLog("Checking current upgrade", $COLOR_INFO)
			Local $Hour = QuickMIS("CNX", $g_sImgAUpgradeHour, 375, 105, 440, 135) ;Skip Wall Reserve, detected upgrade remain time on most top list upgrade < 24h
			If IsArray($Hour) And UBound($Hour) > 0 Then 
				For $i = 0 To UBound($Hour) - 1
					If $Hour[$i][0] = "Day" Then
						$g_bSkipWallReserve = False
						ExitLoop
					EndIf
					If $Hour[$i][0] = "Hour" Then
						$g_bSkipWallReserve = True
					EndIf
				Next
				If $g_bSkipWallReserve Then
					SetLog("Current Upgrade remain time < 24h, Will Use Wall Reserved Builder", $COLOR_INFO)
				Else
					SetLog("Current Upgrade remain time > 24h, Skip Upgrade", $COLOR_INFO)
				EndIf
			EndIf
		EndIf
	EndIf
	
	VillageReport(True,True)

	; check if builder head is clickable
	If Not (_ColorCheck(_GetPixelColor(275, 15, True), "F5F5ED", 20) = True) Then
		SetLog("Unable to find the Builder menu button... Exiting Auto Upgrade...", $COLOR_ERROR)
		Return
	EndIf

	If AutoUpgradeCheckBuilder($bTest) Then ;Check if we have builder
		If $g_bNewBuildingFirst Then
			If $g_bPlaceNewBuilding Then AutoUpgradeSearchNewBuilding($bTest) ;search new building
			If Not AutoUpgradeCheckBuilder($bTest) Then ;Check if we still have builder
				Local $ZoomOutResult = SearchZoomOut(False, True, "", True)
				If IsArray($ZoomOutResult) And $ZoomOutResult[0] = "" Then 
					If checkMainScreen(False, $g_bStayOnBuilderBase, "AutoUpgradeCheckBuilder") Then ZoomOut() 
				EndIf
				Return ;no builder, exit
			EndIf
			If ClickMainBuilder($bTest) Then ClickDragAUpgrade("down"); after search reset upgrade window, scroll to top list
		EndIf
	Else
		Return
	EndIf

	If Not $g_bRunState Then Return
	If AutoUpgradeCheckBuilder($bTest) Then 
		AutoUpgradeSearchExisting($bTest) ;search upgrade for existing building
	EndIf

	If AutoUpgradeCheckBuilder($bTest) Then ;Check if we have builder
		If Not $g_bNewBuildingFirst And $g_bPlaceNewBuilding Then ;check for new building after existing
			AutoUpgradeSearchNewBuilding($bTest)
		EndIf
	EndIf
	If Not $g_bRunState Then Return
	ClickAway()
	Local $ZoomOutResult = SearchZoomOut(False, True, "", True)
	If IsArray($ZoomOutResult) And $ZoomOutResult[0] = "" Then 
		If checkMainScreen(False, $g_bStayOnBuilderBase, "AutoUpgradeCheckBuilder") Then ZoomOut() 
	EndIf
	Return False
EndFunc

Func AutoUpgradeSearchExisting($bTest = False)
	If Not $g_bRunState Then Return
	SetLog("Search For Existing Upgrade", $COLOR_DEBUG)
	If Not ClickMainBuilder($bTest) Then Return
	Local $b_BuildingFound = False, $NeedDrag = True, $TmpUpgradeCost, $UpgradeCost, $sameCost = 0
	For $z = 0 To 9 ;for do scroll 10 times
		$TmpUpgradeCost = getOcrAndCapture("coc-NewCapacity",350, 335, 100, 30, True) ;check most bottom upgrade cost
		Local $ExistingBuilding = FindExistingBuilding()
		If IsArray($ExistingBuilding) And UBound($ExistingBuilding) > 0 Then
			;If $g_bChkRushTH Then _ArraySort($ExistingBuilding, 1, 0, 0, 4)
			For $i = 0 To UBound($ExistingBuilding) - 1
				SetLog("Coord [" & $ExistingBuilding[$i][1] & "," & $ExistingBuilding[$i][2] & "], Cost: " & $ExistingBuilding[$i][3] & " UpgradeType: " & $ExistingBuilding[$i][0], $COLOR_INFO)
			Next
			
			If $g_bChkRushTH Then 
				Local $iIndexRushTH = _ArraySearch($ExistingBuilding, "RushTH", 0, 0, 0, 0, 1, 4)
				If Not $iIndexRushTH Then ContinueLoop
			EndIf
			
			For $i = 0 To UBound($ExistingBuilding) - 1
				If $ExistingBuilding[$i][3] = "0" Then ContinueLoop
				Click($ExistingBuilding[$i][1], $ExistingBuilding[$i][2])
				If _Sleep(1000) Then Return
				If DoUpgrade($bTest) Then
					If Not AutoUpgradeCheckBuilder($bTest) Then Return
				Endif
				ClickMainBuilder($bTest)
			Next
		Else
			SetLog("No Upgrade found!", $COLOR_INFO)
		EndIf
		
		SetDebugLog("TmpUpgradeCost = " & $TmpUpgradeCost & " UpgradeCost = " & $UpgradeCost, $COLOR_INFO)
		If $UpgradeCost = $TmpUpgradeCost Then $sameCost += 1
		If Not ($UpgradeCost = $TmpUpgradeCost) Then $sameCost = 0
		SetDebugLog("sameCost = " & $sameCost, $COLOR_INFO)
		If $sameCost > 2 Then $NeedDrag = False
		$UpgradeCost = $TmpUpgradeCost
		
		If Not $NeedDrag Then
			SetLog("[" & $z & "] Scroll Not Needed!", $COLOR_DEBUG)
			ExitLoop
		EndIf
		If Not $g_bRunState Then Return
		If Not AutoUpgradeCheckBuilder($bTest) Then Return
		ClickDragAUpgrade("up", 328) ;do scroll up
		SetLog("[" & $z & "] Scroll Up", $COLOR_DEBUG)
		If _Sleep(1500) Then Return
	Next
EndFunc

Func FindExistingBuilding($bTest = False)
	Local $aTmpCoord, $aBuilding[0][5], $UpgradeCost
	$aTmpCoord = QuickMIS("CNX", $g_sImgResourceIcon, 310, 80, 450, 390) 
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			If QuickMIS("BC1",$g_sImgAUpgradeObstGear, $aTmpCoord[$i][1] - 200, $aTmpCoord[$i][2] - 10, $aTmpCoord[$i][1], $aTmpCoord[$i][2] + 10) Then ContinueLoop ;skip geared and new
			_ArrayAdd($aBuilding, String($aTmpCoord[$i][0]) & "|" & $aTmpCoord[$i][1] & "|" & Number($aTmpCoord[$i][2]))
		Next
		
		For $j = 0 To UBound($aBuilding) -1
			$UpgradeCost = getOcrAndCapture("coc-NewCapacity", $aBuilding[$j][1], $aBuilding[$j][2] - 10, 100, 30, True)
			$aBuilding[$j][3] = Number($UpgradeCost)
			If QuickMIS("BC1", $g_sImgAUpgradeRushTH, $aBuilding[$j][1] - 200, $aBuilding[$j][2] - 10, $aBuilding[$j][1], $aBuilding[$j][2] + 10) Then $aBuilding[$j][4] = "RushTH"
			SetDebugLog("[" & $j & "] Building: " & $aBuilding[$j][0] & ", Cost=" & $aBuilding[$j][3] & " Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG)
		Next
	EndIf
	_ArraySort($aBuilding, 0, 0, 0, 3)
	Return $aBuilding
EndFunc

Func DoUpgrade($bTest = False)

	If Not $g_bRunState Then Return
	$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(701, 23) ;get current Gold
	$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(701, 74) ;get current Elixir
	If _CheckPixel($aVillageHasDarkElixir, True) Then ; check if the village have a Dark Elixir Storage
		$g_aiCurrentLoot[$eLootDarkElixir] = getResourcesMainScreen(728, 123)
	EndIf
	; get the name and actual level of upgrade selected, if strings are empty, will exit Auto Upgrade, an error happens
	$g_aUpgradeNameLevel = BuildingInfo(242, 494)
	If $g_aUpgradeNameLevel[0] = "" Then
		SetLog("Error when trying to get upgrade name and level...", $COLOR_ERROR)
		GoGoblinMap()
		Return False
	EndIf
	
	Local $THLevelAchieved = False
	If $g_bUpgradeOnlyTHLevelAchieve Then
		If $g_iTownHallLevel >= $g_aiCmbRushTHOption[0] + 9 Then ;if option to only upgrade after TH level achieved enabled
			$THLevelAchieved = True
		Else
			$THLevelAchieved = False
		EndIf
	Else ;if option to only upgrade after TH level achieved disabled
		$THLevelAchieved = True ;set true to bypass
	EndIf
	
	Local $bMustIgnoreUpgrade = False, $bUpgradeTHWeapon = False
	; matchmaking between building name and the ignore list
	If $g_aUpgradeNameLevel[1] = "po al Champion" Then $g_aUpgradeNameLevel[1] = "Royal Champion"
	Switch $g_aUpgradeNameLevel[1]
		Case "Town Hall"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[0] = 1) ? True : False
			If $g_aUpgradeNameLevel[2] >= $g_aiCmbRushTHOption[0] + 9 Then ;only upgrade to max level on Setting
				$bMustIgnoreUpgrade = True
				SetLog("RushTH Building: TownHall Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
				SetLog("Setting Upgrade to Level = " & $g_aiCmbRushTHOption[0] + 9 & ", Skip!", $COLOR_INFO)
			EndIf
		Case "Barbarian King"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[1] = 1 Or $g_bUpgradeKingEnable = True) ? True : False
		Case "Archer Queen"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[2] = 1 Or $g_bUpgradeQueenEnable = True) ? True : False
		Case "Grand Warden"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[3] = 1 Or $g_bUpgradeWardenEnable = True) ? True : False
		Case "Royal Champion"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[4] = 1 Or $g_bUpgradeChampionEnable = True) ? True : False
		Case "Clan Castle"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[5] = 1) ? True : False
		Case "Laboratory"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[6] = 1) ? True : False
		Case "Wall"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[7] = 1 Or $g_bAutoUpgradeWallsEnable = True) ? True : False
		Case "Barracks"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[8] = 1) ? True : False
			If $g_aUpgradeNameLevel[2] >= $g_aiCmbRushTHOption[1] + 2 Then ;only upgrade to max level on Setting
				$bMustIgnoreUpgrade =  True
				SetLog("RushTH Building: Barracks Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
				SetLog("Setting Upgrade to Level = " & $g_aiCmbRushTHOption[1] + 2 & ", Skip!", $COLOR_INFO)
			EndIf
		Case "Dark Barracks"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[9] = 1) ? True : False
			If $g_aUpgradeNameLevel[2] >= $g_aiCmbRushTHOption[2] + 2 Then 
				$bMustIgnoreUpgrade =  True
				SetLog("RushTH Building: Dark Barracks Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
				SetLog("Setting Upgrade to Level = " & $g_aiCmbRushTHOption[2] + 2 & ", Skip!", $COLOR_INFO)
			EndIf
		Case "Spell Factory"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[10] = 1) ? True : False
			If $g_aUpgradeNameLevel[2] >= $g_aiCmbRushTHOption[3] + 2 Then 
				$bMustIgnoreUpgrade =  True
				SetLog("RushTH Building: Spell Factory Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
				SetLog("Setting Upgrade to Level = " & $g_aiCmbRushTHOption[3] + 2 & ", Skip!", $COLOR_INFO)
			EndIf
		Case "Dark Spell Factory"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[11] = 1) ? True : False
			If $g_aUpgradeNameLevel[2] >= $g_aiCmbRushTHOption[4] + 2 Then 
				$bMustIgnoreUpgrade = True
				SetLog("RushTH Building: Dark Spell Factory Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
				SetLog("Setting Upgrade to Level = " & $g_aiCmbRushTHOption[4] + 2 & ", Skip!", $COLOR_INFO)
			EndIf
		Case "Gold Mine"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[12] = 1) ? True : False
		Case "Elixir Collector"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[13] = 1) ? True : False
		Case "Dark Elixir Drill"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[14] = 1) ? True : False
		Case "Cannon"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[15] = 1) ? True : False
		Case "Archer Tower"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[16] = 1) ? True : False
		Case "Mortar"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[17] = 1) ? True : False
		Case "Hidden Tesla"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[18] = 1) ? True : False
		Case "Bomb"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[19] = 1) ? True : False
		Case "Spring Trap"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[19] = 1) ? True : False
		Case "Giant Bomb"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[19] = 1) ? True : False
		Case "Air Bomb"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[19] = 1) ? True : False
		Case "Seeking Air Mine"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[19] = 1) ? True : False
		Case "Skeleton Trap"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[19] = 1) ? True : False
		Case "Tornado Trap"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[19] = 1) ? True : False
		Case "Wizard Tower"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[20] = 1) ? True : False
			If $THLevelAchieved Then
				$bMustIgnoreUpgrade = False
			Else
				$bMustIgnoreUpgrade = True
				SetLog("Essential Building: Wizard Tower Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
			EndIf
		Case "Bomb Tower"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[21] = 1) ? True : False
			If $THLevelAchieved Then
				$bMustIgnoreUpgrade = False
			Else
				$bMustIgnoreUpgrade = True
				SetLog("Essential Building: Bomb Tower Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
			EndIf
		Case "Air Defense"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[22] = 1) ? True : False
			If $THLevelAchieved Then
				$bMustIgnoreUpgrade = False
			Else
				$bMustIgnoreUpgrade = True
				SetLog("Essential Building: Air Defense Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
			EndIf
		Case "Air Sweeper"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[23] = 1) ? True : False
			If $THLevelAchieved Then
				$bMustIgnoreUpgrade = False
			Else
				$bMustIgnoreUpgrade = True
				SetLog("Essential Building: Air Sweeper Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
			EndIf
		Case "X Bow"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[24] = 1) ? True : False
			If $THLevelAchieved Then
				$bMustIgnoreUpgrade = False
			Else
				$bMustIgnoreUpgrade = True
				SetLog("Essential Building: X-Bow Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
			EndIf
		Case "Inferno Tower"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[25] = 1) ? True : False
			If $THLevelAchieved Then
				$bMustIgnoreUpgrade = False
			Else
				$bMustIgnoreUpgrade = True
				SetLog("Essential Building: Inferno Tower Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
			EndIf
		Case "Eagle Artillery"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[26] = 1) ? True : False
			If $THLevelAchieved Then
				$bMustIgnoreUpgrade = False
			Else
				$bMustIgnoreUpgrade = True
				SetLog("Essential Building: Eagle Artillery Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
			EndIf
		Case "Scattershot"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[27] = 1) ? True : False
			If $THLevelAchieved Then
				$bMustIgnoreUpgrade = False
			Else
				$bMustIgnoreUpgrade = True
				SetLog("Essential Building: Scattershot Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
			EndIf
		Case "Army Camp"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[28] = 1) ? True : False
		Case "Gold Storage"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[29] = 1) ? True : False
		Case "Elixir Storage"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[30] = 1) ? True : False
		Case "Dark Elixir Storage"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[31] = 1) ? True : False
		Case "Workshop"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[32] = 1) ? True : False
		Case "Pet House"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[33] = 1) ? True : False
		Case "Builder's Hut"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[34] = 1) ? True : False
		Case Else
			$bMustIgnoreUpgrade = False
	EndSwitch

	Local $aUpgradeButton, $aTmpUpgradeButton
	$aUpgradeButton = findButton("Upgrade", Default, 1, True) ;try to find Upgrade Button (hammer)

	If $g_aUpgradeNameLevel[1] = "Town Hall" And $g_aUpgradeNameLevel[2] > 11 And $g_iChkUpgradesToIgnore[35] = 0 Then ;Upgrade THWeapon not Ignored
		$aTmpUpgradeButton = findButton("THWeapon", Default, 1, True) ;try to find UpgradeTHWeapon button (swords)
		If IsArray($aTmpUpgradeButton) And UBound($aTmpUpgradeButton) = 2 Then
			$bMustIgnoreUpgrade = False
			$aUpgradeButton = $aTmpUpgradeButton
		EndIf
	Endif

	If Not(IsArray($aUpgradeButton) And UBound($aUpgradeButton, 1) = 2) Then
		SetLog("No upgrade here... Wrong click, looking next...", $COLOR_WARNING)
		Return False
	EndIf

	; check if the upgrade name is on the list of upgrades that must be ignored
	If $bMustIgnoreUpgrade Then
		SetLog($g_aUpgradeNameLevel[1] & " : This upgrade must be ignored, looking next...", $COLOR_WARNING)
		Return False
	Else
		SetLog("Building Name: " & $g_aUpgradeNameLevel[1] & " Level: " & $g_aUpgradeNameLevel[2], $COLOR_DEBUG)
	EndIf

	; if upgrade not to be ignored, click on the Upgrade button to open Upgrade window
	ClickP($aUpgradeButton)
	If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return

	Switch $g_aUpgradeNameLevel[1]
		Case "Barbarian King", "Archer Queen", "Grand Warden", "Royal Champion"
			$g_aUpgradeResourceCostDuration[0] = QuickMIS("N1", $g_sImgAUpgradeRes, 690, 500, 730, 580) ; get resource
			$g_aUpgradeResourceCostDuration[1] = getResourcesBonus(598, 522) ; get cost
			$g_aUpgradeResourceCostDuration[2] = getHeroUpgradeTime(578, 465) ; get duration
		Case Else
			$g_aUpgradeResourceCostDuration[0] = QuickMIS("N1", $g_sImgAUpgradeRes, 460, 480, 500, 550) ; get resource
			$g_aUpgradeResourceCostDuration[1] = getResourcesBonus(366, 487) ; get cost
			$g_aUpgradeResourceCostDuration[2] = getBldgUpgradeTime(195, 307) ; get duration
	EndSwitch

	; if one of the value is empty, there is an error, we must exit Auto Upgrade
	For $i = 0 To 2
		;SetLog($g_aUpgradeResourceCostDuration[$i])
		If $g_aUpgradeResourceCostDuration[$i] = "" Then
			SetLog("Error at $g_aUpgradeResourceCostDuration, looking next...", $COLOR_ERROR)
			ClickAway()
			Return False
		EndIf
	Next

	Local $bMustIgnoreResource = False
	; matchmaking between resource name and the ignore list
	Switch $g_aUpgradeResourceCostDuration[0]
		Case "Gold"
			$bMustIgnoreResource = ($g_iChkResourcesToIgnore[0] = 1) ? True : False
		Case "Elixir"
			$bMustIgnoreResource = ($g_iChkResourcesToIgnore[1] = 1) ? True : False
		Case "Dark Elixir"
			$bMustIgnoreResource = ($g_iChkResourcesToIgnore[2] = 1) ? True : False
		Case Else
			$bMustIgnoreResource = False
	EndSwitch

	; check if the resource of the upgrade must be ignored
	If $bMustIgnoreResource = True Then
		SetLog($g_aUpgradeNameLevel[1] & ": This resource must be ignored, looking next...", $COLOR_WARNING)
		Return False
	EndIf

	; initiate a False boolean, that firstly says that there is no sufficent resource to launch upgrade
	Local $bSufficentResourceToUpgrade = False
	; if Cost of upgrade + Value set in settings to be kept after upgrade > Current village resource, make boolean True and can continue
	Switch $g_aUpgradeResourceCostDuration[0]
		Case "Gold"
			If $g_aiCurrentLoot[$eLootGold] >= ($g_aUpgradeResourceCostDuration[1] + $g_iTxtSmartMinGold) Then $bSufficentResourceToUpgrade = True
		Case "Elixir"
			If $g_aiCurrentLoot[$eLootElixir] >= ($g_aUpgradeResourceCostDuration[1] + $g_iTxtSmartMinElixir) Then $bSufficentResourceToUpgrade = True
		Case "Dark Elixir"
			If $g_aiCurrentLoot[$eLootDarkElixir] >= ($g_aUpgradeResourceCostDuration[1] + $g_iTxtSmartMinDark) Then $bSufficentResourceToUpgrade = True
	EndSwitch
	; if boolean still False, we can't launch upgrade, exiting...
	If Not $bSufficentResourceToUpgrade Then
		SetLog($g_aUpgradeNameLevel[1] & ": Insufficent " & $g_aUpgradeResourceCostDuration[0] & " to launch this upgrade, looking Next...", $COLOR_WARNING)
		ClickAway("Right")
		If _Sleep(500) Then Return
		Return False
	EndIf

	; final click on upgrade button, click coord is get looking at upgrade type (heroes have a diferent place for Upgrade button)
	If Not $bTest Then
		Switch $g_aUpgradeNameLevel[1]
			Case "Barbarian King", "Archer Queen", "Grand Warden", "Royal Champion"
				Click(660, 560)
			Case Else
				Click(440, 530)
		EndSwitch
	Else
		ClickAway("Right")
	Endif

	;Check for 'End Boost?' pop-up
	If _Sleep(1000) Then Return
	Local $aImgAUpgradeEndBoost = decodeSingleCoord(findImage("EndBoost", $g_sImgAUpgradeEndBoost, GetDiamondFromRect("350, 310, 570, 230"), 1, True))
	If UBound($aImgAUpgradeEndBoost) > 1 Then
		SetLog("End Boost? pop-up found", $COLOR_INFO)
		SetLog("Clicking OK", $COLOR_INFO)
		Local $aImgAUpgradeEndBoostOKBtn = decodeSingleCoord(findImage("EndBoostOKBtn", $g_sImgAUpgradeEndBoostOKBtn, GetDiamondFromRect("420, 470, 610, 380"), 1, True))
		If UBound($aImgAUpgradeEndBoostOKBtn) > 1 Then
			Click($aImgAUpgradeEndBoostOKBtn[0], $aImgAUpgradeEndBoostOKBtn[1])
			If _Sleep(1000) Then Return
		Else
			SetLog("Unable to locate OK Button", $COLOR_ERROR)
			If _Sleep(1000) Then Return
			ClickAway("Right")
			Return
		EndIf
	EndIf

	; update Logs and History file
	If $g_aUpgradeNameLevel[1] = "Town Hall" And $g_iChkUpgradesToIgnore[35] = 0 Then
		Switch $g_aUpgradeNameLevel[2]
			Case 12
				$g_aUpgradeNameLevel[1] = "Giga Tesla"
				SetLog("Launched upgrade of Giga Tesla successfully !", $COLOR_SUCCESS)
			Case 13
				$g_aUpgradeNameLevel[1] = "Giga Inferno"
				SetLog("Launched upgrade of Giga Inferno successfully !", $COLOR_SUCCESS)
			Case 14
				$g_aUpgradeNameLevel[1] = "Giga Inferno"
				SetLog("Launched upgrade of Giga Inferno successfully !", $COLOR_SUCCESS)
		EndSwitch

	Else
		SetLog("Launched upgrade of " & $g_aUpgradeNameLevel[1] & " to level " & $g_aUpgradeNameLevel[2] + 1 & " successfully !", $COLOR_SUCCESS)
	Endif
	If IsGemOpen(True) Then
		ClickAway("Right")
		
		SetLog("Something is wrong, no builder is available?", $COLOR_ERROR)
	Else
		ClickAway("Right")

		SetLog(" - Cost : " & _NumberFormat($g_aUpgradeResourceCostDuration[1]) & " " & $g_aUpgradeResourceCostDuration[0], $COLOR_SUCCESS)
		SetLog(" - Duration : " & $g_aUpgradeResourceCostDuration[2], $COLOR_SUCCESS)

		AutoUpgradeLog($g_aUpgradeNameLevel, $g_aUpgradeResourceCostDuration)
	EndIf
	
	Return True
EndFunc

Func AutoUpgradeLog($aUpgradeNameLevel = Default, $aUpgradeResourceCostDuration = Default)
	Local $txtAcc = $g_iCurAccount
	Local $txtAccName = $g_asProfileName[$g_iCurAccount]
	Local $bRet = True

	If $aUpgradeNameLevel = Default Then
		$aUpgradeNameLevel = BuildingInfo(242, 494)
		If $aUpgradeNameLevel[0] = "" Then
			SetLog("Error at AutoUpgradeLog() to get upgrade name and level", $COLOR_ERROR)
			$aUpgradeNameLevel[1] = "Traps"
			$bRet = False
		EndIf
		_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, _
				@CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - Placing New Building: " & $aUpgradeNameLevel[1])

		_FileWriteLog($g_sProfileLogsPath & "\AutoUpgradeHistory.log", " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - Placing New Building: " & $aUpgradeNameLevel[1])
	Else
		_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, _
				@CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - Upgrading " & $aUpgradeNameLevel[1] & _
				" to level " & $aUpgradeNameLevel[2] + 1 & _
				" for " & _NumberFormat($aUpgradeResourceCostDuration[1]) & _
				" " & $aUpgradeResourceCostDuration[0] & _
				" - Duration : " & $aUpgradeResourceCostDuration[2])

		_FileWriteLog($g_sProfileLogsPath & "\AutoUpgradeHistory.log", " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - Upgrading " & $aUpgradeNameLevel[1] & _
				" to level " & $aUpgradeNameLevel[2] + 1 & _
				" for " & _NumberFormat($aUpgradeResourceCostDuration[1]) & _
				" " & $aUpgradeResourceCostDuration[0] & _
				" - Duration : " & $aUpgradeResourceCostDuration[2])
	EndIf
	Return $bRet
EndFunc

Func AutoUpgradeLogPlacingWall($aUpgradeNameLevel = Default, $aUpgradeResourceCostDuration = Default)
	Local $txtAcc = $g_iCurAccount
	Local $txtAccName = $g_asProfileName[$g_iCurAccount]

	If $aUpgradeNameLevel = Default Then Return
	If $aUpgradeResourceCostDuration = Default Then Return

	_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, _
			@CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc + 1 & "] " & $txtAccName & _
			" - Placing New Building: " & $aUpgradeNameLevel[1] & _
			" - Duration : " & $aUpgradeResourceCostDuration[2])

	_FileWriteLog($g_sProfileLogsPath & "\AutoUpgradeHistory.log", " [" & $txtAcc + 1 & "] " & $txtAccName & _
			" - Placing New Building: " & $aUpgradeNameLevel[1] & _
			" - Duration : " & $aUpgradeResourceCostDuration[2])

	Return True
EndFunc

Func AUNewBuildings($x, $y, $bTest = False, $isWall = False)
	Local $xstart = 50, $ystart = 50, $xend = 800, $yend = 600
	If $isWall Then 
		Click($x, $y + 30)
		_Sleep(1000)
	EndIf
	Click($x, $y); click on upgrade window
	For $i = 1 To 5
		If IsFullScreenWindow() Then 
			_Sleep(1000)
			ExitLoop
		EndIf
	Next
	If Not $g_bRunState Then Return
	;Search the arrow
	Local $ArrowCoordinates = decodeSingleCoord(findImage("BBNewBuildingArrow", $g_sImgArrowNewBuilding, GetDiamondFromRect("40,180,860,600"), 1, True, Default))
	If UBound($ArrowCoordinates) > 1 Then
		If Not $g_bRunState Then Return
		Click($ArrowCoordinates[0] - 100, $ArrowCoordinates[1] + 50) ;click new building on shop
		If _Sleep(2000) Then Return

		If $IsWall Then
			Local $aWall[3] = ["2","Wall",1]
			Local $aCostWall[3] = ["Gold", 50, 0]
			local $aCoords = decodeSingleCoord(findImage("FindGreenCheck", $g_sImgGreenCheck & "\GreenCheck*", "FV", 1, True))
			If IsArray($aCoords) And UBound($aCoords) = 2 Then
				For $ProMac = 0 To 9
					If Not $g_bRunState Then Return
					If Not $g_bRunState Then Return
					Click($aCoords[0], $aCoords[1]+5)
					If _Sleep(500) Then Return
					If IsGemOpen(True) Then
						SetLog("Not Enough resource! Exiting", $COLOR_ERROR)
						ExitLoop
					Endif
					AutoUpgradeLogPlacingWall($aWall, $aCostWall)
				Next
				Click($aCoords[0] - 75, $aCoords[1])
				Return True
			EndIf
		EndIf

		; Lets search for the Correct Symbol on field
		Local $GreenCheckCoords = decodeSingleCoord(findImage("FindGreenCheck", $g_sImgGreenCheck & "\GreenCheck*", "FV", 1, True))
		SetDebugLog("Looking for GreenCheck Button", $COLOR_INFO)
		If IsArray($GreenCheckCoords) And UBound($GreenCheckCoords) = 2 Then
			SetDebugLog("GreenCheck Button Found in [" & $GreenCheckCoords[0] & "," & $GreenCheckCoords[1] & "]", $COLOR_INFO)
			If Not $g_bRunState Then Return
			If Not $bTest Then
				Click($GreenCheckCoords[0], $GreenCheckCoords[1])
			Else
				SetDebugLog("ONLY for TESTING!!!", $COLOR_ERROR)
				Click($GreenCheckCoords[0] - 75, $GreenCheckCoords[1])
				Return True
			EndIf
			SetLog("Placed a new Building on Main Village! [" & $GreenCheckCoords[0] & "," & $GreenCheckCoords[1] & "]", $COLOR_SUCCESS)
			If _Sleep(500) Then Return
			If AutoUpgradeLog() Then
				Click($GreenCheckCoords[0] - 75, $GreenCheckCoords[1]) ; Just click RedX position, in case its still there
			Else
				Click($GreenCheckCoords[0], $GreenCheckCoords[1]) ; Just click GreenCheck position, in case its still there
			EndIf
			Return True
		Else
			SetDebugLog("GreenCheck Button NOT Found", $COLOR_ERROR)
			NotifyPushToTelegram($g_sProfileCurrentName & ": Failed to place new building in Main Village.")
			If Not $g_bRunState Then Return
			;Lets check if exist the [x], it should not exist, but to be safe
			Local $RedXCoords = decodeSingleCoord(findImage("FindRedX", $g_sImgRedX & "\RedX*", "FV", 1, True))
			If IsArray($RedXCoords) And UBound($RedXCoords) = 2 Then
				Click($RedXCoords[0], $RedXCoords[1])
				SetLog("Sorry! Wrong place to deploy a new building on Main Village!", $COLOR_ERROR)
				If _Sleep(500) Then Return
				Return False
			Else
				GoGoblinMap()
				Return False
			EndIf
		EndIf
	Else
		SetLog("Cannot find Orange Arrow", $COLOR_ERROR)
		Click(820, 38, 1) ; exit from Shop
		Return
	EndIf
	Return False
EndFunc ;==>AUNewBuildings

Func AutoUpgradeSearchNewBuilding($bTest = False)
	If Not $g_bRunState Then Return
	If Not $g_bPlaceNewBuilding Then Return
	SetLog("Search For Place New Building", $COLOR_DEBUG)
	Local $bDebug = $g_bDebugSetlog

	If Not ClickMainBuilder($bTest) Then Return False
	If _Sleep(500) Then Return
	
	Local $ZoomedIn = False, $isWall = False 
	Local $NeedDrag = True, $TmpUpgradeCost, $UpgradeCost, $sameCost = 0
	If Not $g_bRunState Then Return
	For $z = 0 To 10 ;for do scroll 8 times
		If Not $g_bRunState Then Return
		Local $New, $NewCoord, $aCoord[0][3]
		Local $x = 180, $y = 80, $x1 = 480, $y1 = 103, $step = 28
		$NewCoord = QuickMIS("CX", $g_sImgAUpgradeObstNew, 180, 73, 280, 370, True) ;find New Building
		If IsArray($NewCoord) And UBound($NewCoord) > 0 Then
			If Not $g_bRunState Then Return
			SetLog("Found " & UBound($NewCoord) & " New Building", $COLOR_INFO)
			For $j = 0 To UBound($NewCoord)-1
				$New = StringSplit($NewCoord[$j], ",", $STR_NOCOUNT)
				$UpgradeCost = getOcrAndCapture("coc-NewCapacity",$New[0] + 180 + 110, $New[1] + 73 - 8, 180, 20, True)
				SetDebugLog("[" & $j & "] New Building: " & $New[0] + 180 & "," & $New[1] + 73 & " UpgradeCost=" & $UpgradeCost, $COLOR_INFO)
				_ArrayAdd($aCoord, $New[0] + 180 & "|" & $New[1] + 73 & "|" & $UpgradeCost, Default, Default, Default, $ARRAYFILL_FORCE_NUMBER)
			Next
			_ArraySort($aCoord, 0, 0, 0, 2)
			$isWall = False ;reset var 
			For $j = 0 To UBound($aCoord) - 1
				If Not $g_bRunState Then Return
				If $aCoord[$j][2] = "50" Then 
					$IsWall = True
					SetLog("New Building: Is Wall, let's try place 10 Wall", $COLOR_INFO)
				EndIf

				If Not $aCoord[$j][2] = "" Then	
					If Not $ZoomedIn Then
						ClickAway()
						If _Sleep(1000) Then Return
						If SearchGreenZone() Then
							$ZoomedIn = True
							ClickMainBuilder($bTest)
						Else
							ExitLoop 2 ;zoomin failed, cancel placing newbuilding
						EndIf
					EndIf
					
					If AUNewBuildings($aCoord[$j][0], $aCoord[$j][1], $bTest, $IsWall) Then
						ClickMainBuilder($bTest)
						$z = 0 ;reset
						$sameCost = 0
						ExitLoop
					Else
						ExitLoop 2 ;Place NewBuilding failed, cancel placing newbuilding
					EndIf
				Else
					SetDebugLog("[" & $j & "] New Building: " & $aCoord[$j][0] & "," & $aCoord[$j][1] & " Not Enough Resource", $COLOR_ERROR)
				EndIf
			Next
		Else
			SetLog("New Building Not Found", $COLOR_INFO)
		EndIf
		
		$TmpUpgradeCost = getOcrAndCapture("coc-NewCapacity",350, 335, 100, 30, True) ;check most bottom upgrade cost
		
		If $g_bChkRushTH Then ;add RushTH priority TownHall, Giga Tesla, Giga Inferno
			SetLog("Search RushTHPriority Building on Builder Menu", $COLOR_INFO)
			Local $aResult = FindRushTHPriority()
			If isArray($aResult) And UBound($aResult) > 0 Then
				_ArraySort($aResult, 0, 0, 0, 3)
				For $y = 0 To UBound($aResult) - 1
					SetDebugLog("RushTHPriority: " & $aResult[$y][0] & ", Cost: " & $aResult[$y][3] & " Coord [" & $aResult[$y][1] & "," & $aResult[$y][2] & "]", $COLOR_INFO)
				Next
				For $y = 0 To UBound($aResult) - 1
					If $aResult[$y][3] > 100 Then ;filter only upgrade with readable upgrade cost
						Click($aResult[$y][1], $aResult[$y][2])
						$sameCost = 0 ;reset here as we found building with cost readable
						If _Sleep(1000) Then Return
						If DoUpgrade($bTest) Then
							$z = 0 ;reset
						Endif
						ExitLoop ;exit this loop, because successfull upgrade will reset upgrade list on builder menu
					Else
						SetDebugLog("Skip this building, Cost not readable", $COLOR_WARNING)
					EndIf
				Next
			Else
				SetLog("RushTHPriority Building Not Found", $COLOR_INFO)
			EndIf
			If Not $g_bRunState Then Return
		EndIf
		
		Local $THLevelAchieved = False
		If $g_bUpgradeOnlyTHLevelAchieve Then
			If $g_iTownHallLevel >= $g_aiCmbRushTHOption[0] + 9 Then ;if option to only upgrade after TH level achieved enabled
				$THLevelAchieved = True
			Else
				$THLevelAchieved = False
			EndIf
		Else ;if option to only upgrade after TH level achieved disabled
			$THLevelAchieved = True ;set true to bypass
		EndIf
		
		If $g_bChkRushTH And $THLevelAchieved Then
			SetLog("Search Essential Building on Builder Menu", $COLOR_INFO)
			ClickMainBuilder()
			Local $aResult = FindEssentialBuilding()
			If isArray($aResult) And UBound($aResult) > 0 Then
				_ArraySort($aResult, 0, 0, 0, 3)
				For $y = 0 To UBound($aResult) - 1
					SetDebugLog("Essential Building: " & $aResult[$y][0] & ", Type: " & $aResult[$y][3] & ", Cost: " & $aResult[$y][4] & " Coord [" & $aResult[$y][1] & "," & $aResult[$y][2] & "]", $COLOR_INFO)
				Next
				For $y = 0 To UBound($aResult) - 1
					If $aResult[$y][4] > 100 Then ;filter only upgrade with readable upgrade cost
						$sameCost = 0 ;reset here as we found building with cost readable
						If $aResult[$y][3] = "Hero" Then
							Local $UpgradeUsing = "DE"
							If $aResult[$y][0] = "GrandWarden" Then $UpgradeUsing = "Elixir"
							If $UpgradeUsing = "DE" Then 
								SetDebugLog($g_iTxtSmartMinDark & " + " & $aResult[$y][4] & " = " & $g_iTxtSmartMinDark + $aResult[$y][4])
								SetDebugLog("DE = " & $g_aiCurrentLoot[$eLootDarkElixir])
								If $g_aiCurrentLoot[$eLootDarkElixir] < ($aResult[$y][4] + $g_iTxtSmartMinDark) Then 
									SetLog($aResult[$y][0] & " Skip Upgrade, Insufficent Resource", $COLOR_WARNING)
									ContinueLoop
								EndIf
							EndIf
							If $UpgradeUsing = "Elixir" Then 
								SetDebugLog($g_iTxtSmartMinElixir & " + " & $aResult[$y][4] & " = " & $g_iTxtSmartMinElixir + $aResult[$y][4])
								SetDebugLog("Elixir = " & $g_aiCurrentLoot[$eLootElixir])
								If $g_aiCurrentLoot[$eLootElixir] < ($aResult[$y][4] + $g_iTxtSmartMinElixir) Then 
									SetLog($aResult[$y][0] & " Skip Upgrade, Insufficent Resource", $COLOR_WARNING)
									ContinueLoop
								EndIf
							EndIf
						EndIf
						Click($aResult[$y][1], $aResult[$y][2])
						If _Sleep(1000) Then Return
						If DoUpgrade($bTest) Then
							$z = 0 ;reset
							$sameCost = 0
						Endif
						ExitLoop ;exit this loop, because successfull upgrade will reset upgrade list on builder menu
					Else
						SetDebugLog("Skip this building, Cost not readable", $COLOR_WARNING)
					EndIf
				Next
			Else
				SetLog("Essential Building Not Found", $COLOR_INFO)
			EndIf
			If Not $g_bRunState Then Return
		Else 
			SetLog("Skip Search Essential Building", $COLOR_INFO)
		EndIf
		
		SetDebugLog("TmpUpgradeCost = " & $TmpUpgradeCost & " UpgradeCost = " & $UpgradeCost, $COLOR_INFO)
		If $UpgradeCost = $TmpUpgradeCost Then $sameCost += 1
		If Not ($UpgradeCost = $TmpUpgradeCost) Then $sameCost = 0
		SetDebugLog("sameCost = " & $sameCost, $COLOR_INFO)
		If $sameCost > 2 Then $NeedDrag = False
		$UpgradeCost = $TmpUpgradeCost
		
		If Not $g_bRunState Then Return
		If Not AutoUpgradeCheckBuilder($bTest) Then ExitLoop
		If Not $NeedDrag Then
			SetLog("[" & $z & "] Scroll Not Needed!", $COLOR_DEBUG)
			ExitLoop
		EndIf
		If Not $g_bRunState Then Return
		ClickDragAUpgrade("up", 328);do scroll up
		SetLog("[" & $z & "] Scroll Up", $COLOR_DEBUG)
		If _Sleep(1000) Then Return
	Next
	SetLog("Exit Find NewBuilding", $COLOR_DEBUG)
EndFunc ;==>FindNewBuilding

Func FindRushTHPriority()
	Local $aTmpTHRushCoord, $aTHRushCoord[0][4], $aRushTH[3], $UpgradeCost
	$aTmpTHRushCoord = QuickMIS("CNX", $g_sImgAUpgradeRushTHPriority, 180, 80, 350, 369, True)
	If IsArray($aTmpTHRushCoord) And UBound($aTmpTHRushCoord) > 0 Then
		SetLog("Found " & UBound($aTmpTHRushCoord) & " Image RushTHPriority", $COLOR_INFO)
		For $j = 0 To UBound($aTmpTHRushCoord) - 1
			If QuickMIS("BC1", $g_sImgAUpgradeObstNew, 180, $aTmpTHRushCoord[$j][2] -10, 260, $aTmpTHRushCoord[$j][2] + 10) Then
				SetDebugLog("Building " & $j & " is new, skip!", $COLOR_ERROR)
				ContinueLoop ;skip New Building
			EndIf
			_ArrayAdd($aTHRushCoord, String($aTmpTHRushCoord[$j][0]) & "|" & $aTmpTHRushCoord[$j][1] & "|" & $aTmpTHRushCoord[$j][2])
		Next
		For $j = 0 To UBound($aTHRushCoord) - 1
			$UpgradeCost = getOcrAndCapture("coc-NewCapacity", 350, $aTHRushCoord[$j][2] - 8, 150, 20, True)
			$aTHRushCoord[$j][3] = Number($UpgradeCost)
			SetDebugLog("[" & $j & "] Building: " & $aTHRushCoord[$j][0] & ", Cost=" & $aTHRushCoord[$j][3] & " Coord [" &  $aTHRushCoord[$j][1] & "," & $aTHRushCoord[$j][2] & "]", $COLOR_DEBUG)
		Next
		_ArraySort($aTHRushCoord, 0, 0, 0, 3)
		Return $aTHRushCoord
	Else
		SetDebugLog("Not Array Building", $COLOR_DEBUG)
	EndIf
	Return $aTHRushCoord
EndFunc

Func FindEssentialBuilding()
	Local $sImagePath = @ScriptDir & "\imgxml\Resources\Auto Upgrade\EssentialBuilding\"
	Local $sTempPath = @TempDir & "\" & $g_sProfileCurrentName & "\EssentialBuilding\"
	Local $BuildingCoord, $aEssentialBuildingCoord[0][5], $aEssentialBuilding, $UpgradeCost
	DirRemove($sTempPath, $DIR_REMOVE)
	EssentialBuildingImageCopy($sImagePath, $sTempPath)
	
	$BuildingCoord = QuickMIS("CNX", $sTempPath, 180, 80, 350, 400, True)
	If IsArray($BuildingCoord) And UBound($BuildingCoord) > 0 Then
		SetLog("Found " & UBound($BuildingCoord) & " Image EssentialBuilding", $COLOR_INFO)
		For $j = 0 To UBound($BuildingCoord) - 1
			If QuickMIS("BC1", $g_sImgAUpgradeObstNew, 180, $BuildingCoord[$j][2] - 10, 260, $BuildingCoord[$j][2] + 10) Then
				SetDebugLog("Building " & $j & " is new, skip!", $COLOR_ERROR)
				ContinueLoop ;skip New Building
			EndIf
			If $BuildingCoord[$j][0] = "BombT" Then
				SetDebugLog("Building " & $j & " Detected as Bomb Tower, lets check if it Bomb or a Bomb Tower", $COLOR_INFO)
				If Not QuickMIS("BC1", $sImagePath & "Tower\", $BuildingCoord[$j][1] + 10, $BuildingCoord[$j][2] - 10, 300, $BuildingCoord[$j][2] + 10) Then
					SetDebugLog("Building " & $j & " is Not Bomb Tower, skip!", $COLOR_ERROR)
					ContinueLoop ;skip Not Bomb Tower
				EndIf				
			EndIf
			Local $Hero[4] = ["ArcherQueen", "BarbarianKing", "GrandWarden", "RoyalChampion"]
			Local $BuildingType = "Building"
			For $z = 0 To UBound($Hero) - 1
				If $BuildingCoord[$j][0] = $Hero[$z] Then $BuildingType = "Hero"
			Next
			_ArrayAdd($aEssentialBuildingCoord, String($BuildingCoord[$j][0]) & "|" & $BuildingCoord[$j][1] & "|" & $BuildingCoord[$j][2] & "|" & $BuildingType)
		Next
		For $j = 0 To UBound($aEssentialBuildingCoord) - 1 
			$UpgradeCost = getOcrAndCapture("coc-NewCapacity", 350, $BuildingCoord[$j][2] - 8, 150, 20, True)
			$aEssentialBuildingCoord[$j][4] = Number($UpgradeCost)
			SetLog("[" & $j & "] Building: " & $aEssentialBuildingCoord[$j][0] & ", Cost=" & $aEssentialBuildingCoord[$j][4], $COLOR_INFO)
		Next
		_ArraySort($aEssentialBuildingCoord, 1, 0, 0, 4)
		Return $aEssentialBuildingCoord
	Else
		SetDebugLog("Not Array Essential Building", $COLOR_DEBUG)
	EndIf
	Return $aEssentialBuildingCoord
EndFunc

Func EssentialBuildingImageCopy($sImagePath = "", $sTempPath = "")
	If $sImagePath = "" Then Return
	If $sTempPath = "" Then Return
	Local $asImageName[8] = ["Xbow", "Inferno", "Eagle", "Scatter", "WizardT", "BombT", "AirD", "AirS"]
	For $i = 0 To UBound($g_aichkEssentialUpgrade) - 1
		If $g_aichkEssentialUpgrade[$i] > 0 Then
			SetDebugLog("[" & $i & "]" & "Essential Building: " & $asImageName[$i], $COLOR_DEBUG)
			FileCopy($sImagePath & "\" & $asImageName[$i] & "*.xml", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
		EndIf
	Next
	Local $asHeroName[4] = ["ArcherQueen", "BarbarianKing", "GrandWarden", "RoyalChampion"]
	For $i = 0 To UBound($asHeroName) - 1
		SetDebugLog("[" & $i & "]" & "Heroes: " & $asHeroName[$i], $COLOR_DEBUG)
		FileCopy($sImagePath & "\" & $asHeroName[$i] & "*.xml", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
	Next
EndFunc

Func SearchGreenZone()
	SetLog("Search GreenZone for Placing new Building", $COLOR_INFO)
	If Not $g_bRunState Then Return
	Local $aTop = QuickMIS("CX", $g_sImgAUpgradeGreenZone, 320, 70, 500, 220) ;top
	Local $aLeft = QuickMIS("CX", $g_sImgAUpgradeGreenZone, 90, 260, 220, 400) ;left
	Local $aBottom = QuickMIS("CX", $g_sImgAUpgradeGreenZone, 300, 450, 500, 600) ;bottom
	Local $aRight = QuickMIS("CX", $g_sImgAUpgradeGreenZone, 600, 250, 740, 400) ;right

	Local $aAll[4][2] = [["Top", UBound($aTop)], ["Left", UBound($aLeft)], ["Bottom", UBound($aBottom)], ["Right", UBound($aRight)]]
	If $g_bDebugClick Then SetLog("Top:" & UBound($aTop) & " Left:" & UBound($aLeft) & " Bottom:" & UBound($aBottom) & " Right:" & UBound($aRight))
	_ArraySort($aAll,1,0,0,1)
	If $g_bDebugClick Then SetLog($aAll[0][0] & ":" & $aAll[0][1] & "|" & $aAll[1][0] & ":" & $aAll[1][1] & "|" & $aAll[2][0] & ":" & $aAll[2][1] & "|" & $aAll[3][0] & ":" & $aAll[3][1] & "|", $COLOR_DEBUG)

	If $aAll[0][1] > 0 Then
		SetLog("Found GreenZone, On " & $aAll[0][0] & " Region", $COLOR_SUCCESS)
		If ZoomIn($aAll[0][0]) Then
			SetLog("Succeed ZoomIn", $COLOR_DEBUG)
			Return True
		Else
			SetLog("Failed ZoomIn", $COLOR_ERROR)
		EndIf
	Else
		SetLog("GreenZone for Placing new Building Not Found", $COLOR_DEBUG)
	EndIf
	NotifyPushToTelegram($g_sProfileCurrentName & ": Failed to place new building in Main Village.") 
	Return False
EndFunc

Func ClickDragAUpgrade($Direction = "up", $YY = Default, $DragCount = 1)
	Local $x = 420, $yUp = 103, $yDown = 800, $Delay = 1000
	Local $Yscroll =  164 + (($g_iTotalBuilderCount - $g_iFreeBuilderCount) * 28)
	If $YY = Default Then $YY = $Yscroll
	For $checkCount = 0 To 2
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(350,73, True), "fdfefd", 20) Then ;check upgrade window border
			Switch $Direction
				Case "Up"
					If $YY < 100 Then $YY = 150
					If $DragCount > 1 Then
						For $i = 1 To $DragCount
							ClickDrag($x, $YY, $x, $yUp, $Delay) ;drag up
						Next
					Else
						ClickDrag($x, $YY, $x, $yUp, $Delay) ;drag up
					EndIf
					If _Sleep(1000) Then Return
				Case "Down"
					ClickDrag($x, $yUp, $x, $yDown, $Delay) ;drag to bottom
					If WaitforPixel(430, 80, 450, 100, "FFFFFF", 10, 1) Then
						ClickDrag($x, $yUp, $x, $yDown, $Delay) ;drag to bottom
					EndIf
					If _Sleep(5000) Then Return
			EndSwitch
		EndIf
		If _ColorCheck(_GetPixelColor(350,73, True), "fdfefd", 20) Then ;check upgrade window border
			SetLog("Upgrade Window Exist", $COLOR_INFO)
			Return True
		Else
			SetLog("Upgrade Window Gone!", $COLOR_DEBUG)
			ClickMainBuilder()
			If _Sleep(1000) Then Return
		EndIf
	Next
	Return False
EndFunc ;==>IsUpgradeWindow

Func ClickMainBuilder($bTest = False, $Counter = 3)
	Local $b_WindowOpened = False
	If Not $g_bRunState Then Return
	; open the builders menu
	If Not _ColorCheck(_GetPixelColor(350,73, True), "FDFEFD", 30) Then
		Click(295, 30)
		If _Sleep(1000) Then Return
	EndIf

	If _ColorCheck(_GetPixelColor(350, 73, True), "FDFEFD", 30) Then
		SetDebugLog("Open Upgrade Window, Success", $COLOR_SUCCESS)
		$b_WindowOpened = True
	Else
		For $i = 1 To $Counter
			SetLog("Upgrade Window didn't open, trying again!", $COLOR_DEBUG)
			If IsFullScreenWindow() Then
				Click(825,45)
				If _Sleep(1000) Then Return
			EndIf
			Click(295, 30)
			If _Sleep(1000) Then Return
			If _ColorCheck(_GetPixelColor(350, 73, True), "FDFEFD", 20) Then
				$b_WindowOpened = True
				ExitLoop
			EndIf
		Next
		If Not $b_WindowOpened Then
			SetLog("Something is wrong with upgrade window, already tried 3 times!", $COLOR_DEBUG)
		EndIf
	EndIf
	Return $b_WindowOpened
EndFunc ;==>ClickMainBuilder

Func GoGoblinMap()
	Local $GoblinFaceCoord, $CircleCoord
	ClickAway()
	ClickP($aAttackButton)
	SetLog("Going to Goblin Map to reset Field", $COLOR_INFO)
	If Not $g_bRunState Then Return
	If _Sleep(2000) Then Return
	Click(140, 360) ;Select Goblin Map
	If _Sleep(1000) Then Return
	$GoblinFaceCoord = decodeSingleCoord(findImage("GoblinFace", $g_sImgGoblin & "\GoblinFace*", "FV", 1, True))
	If IsArray($GoblinFaceCoord) And UBound($GoblinFaceCoord) = 2 Then
		Click($GoblinFaceCoord[0], $GoblinFaceCoord[1] + 50)
	Else ; we not find goblin face, try find circle map button
		$CircleCoord = decodeSingleCoord(findImage("GoblinFace", $g_sImgGoblin & "\OrangeCircle*", "FV", 1, True))
		If IsArray($CircleCoord) And UBound($CircleCoord) = 2 Then
			Click($CircleCoord[0], $CircleCoord[1])
			If _Sleep(500) Then Return
			Click($CircleCoord[0], $CircleCoord[1] + 50)
		Else
			Click(818, 55)
		EndIf
	EndIf
	Local $count = 0
	While Not IsAttackPage()
		$count += 1
		If _Sleep(250) Then Return
		If $count > 50 Then Return
	Wend

	If Not $g_bRunState Then Return

	If IsAttackPage() Then
		Click(66, 540)
	EndIf
	$count = 0
	While Not IsMainPage()
		$count += 1
		If _Sleep(250) Then Return
		If $count > 50 Then Return
	Wend
	SetLog("Field should be clear now", $COLOR_INFO)
EndFunc
