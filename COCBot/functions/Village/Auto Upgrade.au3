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

	PlaceBuilder()

	getBuilderCount(True) ;check if we have available builder
	;Check if there is a free builder for Auto Upgrade
	If $g_iFreeBuilderCount > 0 Then $bRet = True;builder available

	Local $iWallReserve = $g_bUpgradeWallSaveBuilder ? 1 : 0
	If $g_iFreeBuilderCount - $iWallReserve - ReservedBuildersForHeroes() < 1 Then ;check builder reserve on wall and hero upgrade
		SetLog("FreeBuilder=" & $g_iFreeBuilderCount & ", Reserved (ForHero=" & $g_iHeroReservedBuilder & " ForWall=" & $iWallReserve & ")", $COLOR_INFO)
		If Not $g_bSkipWallReserve And Not $g_bUpgradeLowCost Then
			SetLog("No builder available. Skipping Auto Upgrade!", $COLOR_WARNING)
			$bRet = False
		EndIf
	EndIf

	If ($g_bSkipWallReserve Or $g_bUpgradeLowCost) And $g_iFreeBuilderCount > 0 Then
		SetLog("CheckBuilder: " & ($g_bUpgradeLowCost ? "Upgrade remain time > 1day, but < 2day" : "Upgrade remain time < 24h"), $COLOR_WARNING)
		$bRet = True
	EndIf

	If $bTest Then ;for testing, bypass
		$g_iFreeBuilderCount = 1
		$bRet = True
	EndIf

	SetDebugLog("AutoUpgradeCheckBuilder() Free Builder : " & $g_iFreeBuilderCount, $COLOR_DEBUG)
	Return $bRet
EndFunc

Func SearchUpgrade($bTest = False)
	SetLog("Check for Auto Upgrade", $COLOR_DEBUG)
	If Not $g_bAutoUpgradeEnabled Then Return
	If Not $g_bRunState Then Return
	$g_bSkipWallReserve = False ;reset first
	$g_bUpgradeLowCost = False ;reset first

	VillageReport(True,True)

	If $g_bUseWallReserveBuilder And $g_bUpgradeWallSaveBuilder And $g_bAutoUpgradeWallsEnable And $g_iFreeBuilderCount = 1 Then
		ClickMainBuilder()
		SetLog("Checking current upgrade", $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgAUpgradeHour, 370, 105, 440, 140) Then
			Local $sUpgradeTime = getBuilderLeastUpgradeTime($g_iQuickMISX - 50, $g_iQuickMISY - 8)
			Local $mUpgradeTime = ConvertOCRTime("Least Upgrade", $sUpgradeTime)
			If $mUpgradeTime > 0 And $mUpgradeTime <= 1440 Then
				SetLog("Upgrade time < 24h, Will Use Wall Reserved Builder", $COLOR_INFO)
				$g_bSkipWallReserve = True
			ElseIf $mUpgradeTime > 1400 And $mUpgradeTime <= 2880 Then
				$g_bUpgradeLowCost = True
				SetLog("Upgrade time > 24h And < 2d, Will Use Wall Reserved Builder", $COLOR_INFO)
			Else
				SetLog("Upgrade time > 24h, Skip Upgrade", $COLOR_INFO)
			EndIf

			; Smart Save Resources for Wall Upgrade
			If $g_aWallSaveMode < 0 Then
				If $mUpgradeTime >= 7200 Then
					SetLog("Long Upgrade Duration > 5d", $COLOR_INFO)
					SetLog("Discounting wall save resources by 50%", $COLOR_INFO)
					$g_aWallSaveMode = 1
				ElseIf $mUpgradeTime >= 4320 Then
					SetLog("Long Upgrade duration > 3d And < 5d", $COLOR_INFO)
					SetLog("Discounting wall save resources by 25%", $COLOR_INFO)
					$g_aWallSaveMode = 2
				Else
					SetLog("Upgrade time < 3d, No Discounts!", $COLOR_INFO)
					$g_aWallSaveMode = 0
				EndIf
			EndIf
		EndIf
	EndIf

	If AutoUpgradeCheckBuilder($bTest) Then ;Check if we have builder
		If $g_bNewBuildingFirst And Not $g_bUpgradeLowCost Then ;skip if will use for lowcost upgrade
			If $g_bPlaceNewBuilding Then AutoUpgradeSearchNewBuilding($bTest) ;search new building
			If Not AutoUpgradeCheckBuilder($bTest) Then ;Check if we still have builder
				ZoomOut()
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
	Clickaway("Right")
	ZoomOut()
	Return False
EndFunc

Func AutoUpgradeSearchExisting($bTest = False)
	If Not $g_bRunState Then Return
	SetLog("Search For Existing Upgrade", $COLOR_DEBUG)
	If Not ClickMainBuilder($bTest) Then Return
	Local $b_BuildingFound = False, $NeedDrag = True, $TmpUpgradeCost, $UpgradeCost, $sameCost = 0
	For $z = 0 To 9 ;for do scroll 10 times
		$TmpUpgradeCost = getMostBottomCost() ;check most bottom upgrade cost

		Local $ExistingBuilding = FindExistingBuilding()
		If IsArray($ExistingBuilding) And UBound($ExistingBuilding) > 0 Then
			If $g_bUpgradeLowCost Then _ArraySort($ExistingBuilding, 0, 0, 0, 5)
			For $i = 0 To UBound($ExistingBuilding) - 1
				SetLog("Building: " & $ExistingBuilding[$i][3] & ", Cost:" & $ExistingBuilding[$i][5] & " " & $ExistingBuilding[$i][0], $COLOR_INFO)
			Next

			For $i = 0 To UBound($ExistingBuilding) - 1
				If $g_bUpgradeLowCost And (StringInStr($ExistingBuilding[$i][3], "Mine") Or StringInStr($ExistingBuilding[$i][3], "Collector") Or StringInStr($ExistingBuilding[$i][3], "Mortar")) Then ContinueLoop
				If CheckResourceForDoUpgrade($ExistingBuilding[$i][3], $ExistingBuilding[$i][5], $ExistingBuilding[$i][0]) Then
					If Not $g_bRunState Then Return
					Click($ExistingBuilding[$i][1], $ExistingBuilding[$i][2])
					If _Sleep(1000) Then Return
					If DoUpgrade($bTest) Then
						$z = 0 ;reset
						$g_bSkipWallReserve = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
						$g_bUpgradeLowCost = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
						If Not AutoUpgradeCheckBuilder($bTest) Then Return
					Endif
					ClickMainBuilder($bTest)
				EndIf
			Next
		Else
			SetLog("No Upgrade found!", $COLOR_INFO)
		EndIf

		If IsTHLevelAchieved() And Not $g_bUpgradeLowCost Then
			SetLog("Search Essential Building on Builder Menu", $COLOR_INFO)
			ClickMainBuilder()
			Local $aResult = FindEssentialBuilding()
			If isArray($aResult) And UBound($aResult) > 0 Then
				For $y = 0 To UBound($aResult) - 1
					SetLog($aResult[$y][3] & ", Cost: " & $aResult[$y][5] & " " & $aResult[$y][0], $COLOR_SUCCESS)
				Next
				For $y = 0 To UBound($aResult) - 1
					If CheckResourceForDoUpgrade($aResult[$y][3], $aResult[$y][5], $aResult[$y][0]) Then
						Click($aResult[$y][1], $aResult[$y][2])
						If _Sleep(1000) Then Return
						If DoUpgrade($bTest) Then
							$z = 0 ;reset
							$g_bSkipWallReserve = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
							$g_bUpgradeLowCost = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
							If Not AutoUpgradeCheckBuilder($bTest) Then Return
						Endif
						ExitLoop ;exit this loop, because successfull upgrade will reset upgrade list on builder menu
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
		If $sameCost > 1 Then $NeedDrag = False
		$UpgradeCost = $TmpUpgradeCost

		If Not $NeedDrag Then
			SetLog("[" & $z & "] Scroll Not Needed!", $COLOR_DEBUG)
			ExitLoop
		EndIf
		If Not $g_bRunState Then Return
		If Not AutoUpgradeCheckBuilder($bTest) Then Return
		ClickDragAUpgrade("up", 328) ;do scroll up
		SetLog("[" & $z & "] SameCost=" & $sameCost & " [" & $UpgradeCost & "]", $COLOR_DEBUG)
		If _Sleep(1500) Then Return
	Next
EndFunc

Func FindExistingBuilding($bTest = False)
	Local $ElixMultiply = 1, $GoldMultiply = 1 ;used for multiply score
	Local $Gold = getResourcesMainScreen(701, 23)
	Local $Elix = getResourcesMainScreen(701, 74)
	If $Gold > $Elix Then $GoldMultiply += 1
	If $Elix > $Gold Then $ElixMultiply += 1
	Local $aTmpCoord, $aBuilding[0][8], $UpgradeCost, $UpgradeName, $bFoundRusTH = False
	Local $aRushTHPriority[7][2] = [["Castle", 15], ["Pet", 15], ["Laboratory", 15], ["Storage", 14], ["Army", 13], ["Giga", 12], ["Town", 10]]
	Local $aRushTH[7][2] = [["Barracks", 8], ["Spell", 9], ["Workshop", 10], ["King", 8], ["Queen", 8], ["Warden", 8], ["Champion", 8]]
	Local $aHeroes[4] = ["King", "Queen", "Warden", "Champion"]
	$aTmpCoord = QuickMIS("CNX", $g_sImgResourceIcon, 310, 80, 450, 390)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			If QuickMIS("BC1",$g_sImgAUpgradeObstGear, $aTmpCoord[$i][1] - 250, $aTmpCoord[$i][2] - 10, $aTmpCoord[$i][1], $aTmpCoord[$i][2] + 10) Then ContinueLoop ;skip geared and new
			$UpgradeName = getBuildingName(200, $aTmpCoord[$i][2] - 12) ;get upgrade name and amount
			If $g_bChkRushTH Then ;if rushth enabled, filter only rushth buildings
				Local $bRusTHFound = False
				For $x = 0 To UBound($aRushTH) - 1
					If StringInStr($UpgradeName[0], $aRushTH[$x][0], 1) Then
						$bRusTHFound = True ;used for add array
						$bFoundRusTH = True ;used for sorting array
						ExitLoop
					EndIf
				Next
				If Not $bRusTHFound Then ; Optimization: no need to check if already found before
					For $x = 0 To UBound($aRushTHPriority) - 1
						If StringInStr($UpgradeName[0], $aRushTHPriority[$x][0], 1) Then
							$bRusTHFound = True ;used for add array
							$bFoundRusTH = True ;used for sorting array
							ExitLoop
						EndIf
					Next
				EndIf
				If $g_bUpgradeLowCost Then
					Local $tmpcost = getOcrAndCapture("coc-buildermenu-cost", $aTmpCoord[$i][1], $aTmpCoord[$i][2] - 10, 120, 30, True)
					If Number($tmpcost) = 0 Then ContinueLoop
					If Number($tmpcost) > 500000 Or $aTmpCoord[$i][0] <> "Gold" Then ContinueLoop
				EndIf

				If Not $bRusTHFound And Not $g_bUpgradeLowCost Then SetDebugLog("Building:" & $UpgradeName[0] & ", not rushTH or rushTH priority")
				If Not $bRusTHFound And Not $g_bUpgradeLowCost Then ContinueLoop ;skip this building, RushTh enabled but this building is not RushTH building
			EndIf
			_ArrayAdd($aBuilding, String($aTmpCoord[$i][0]) & "|" & $aTmpCoord[$i][1] & "|" & Number($aTmpCoord[$i][2]) & "|" & String($UpgradeName[0]) & "|" & Number($UpgradeName[1])) ;compose the array
		Next

		For $j = 0 To UBound($aBuilding) -1
			$UpgradeCost = getOcrAndCapture("coc-buildermenu-cost", $aBuilding[$j][1], $aBuilding[$j][2] - 10, 120, 30, True)
			$aBuilding[$j][5] = Number($UpgradeCost)
			Local $BuildingName = $aBuilding[$j][3]
			If $g_bChkRushTH Then ;set score for RushTHPriority Building
				For $k = 0 To UBound($aRushTHPriority) - 1
					If StringInStr($BuildingName, $aRushTHPriority[$k][0]) Then
						Switch $aBuilding[$j][0]
							Case "Gold"
								$aBuilding[$j][6] = $aRushTHPriority[$k][1] * $GoldMultiply
							Case "Elix"
								$aBuilding[$j][6] = $aRushTHPriority[$k][1] * $ElixMultiply
							Case "DE"
								$aBuilding[$j][6] = $aRushTHPriority[$k][1]
						EndSwitch
						$aBuilding[$j][7] = "Priority"
						If $g_bAutoUpgradeWallsEnable Then setMinSaveWall($aBuilding[$j][0], $aBuilding[$j][5])
					EndIf
				Next
				For $k = 0 To UBound($aRushTH) - 1
					If StringInStr($BuildingName, $aRushTH[$k][0]) Then
						Switch $aBuilding[$j][0]
							Case "Gold"
								$aBuilding[$j][6] = $aRushTH[$k][1] * $GoldMultiply
							Case "Elix"
								$aBuilding[$j][6] = $aRushTH[$k][1] * $ElixMultiply
							Case "DE"
								$aBuilding[$j][6] = $aRushTH[$k][1]
						EndSwitch
						$aBuilding[$j][7] = "RushTH"
						If $g_bAutoUpgradeWallsEnable Then setMinSaveWall($aBuilding[$j][0], $aBuilding[$j][5])
					EndIf
				Next
			EndIf
			If $g_bHeroPriority Then ;set score = 20 for Heroes, so if there is heroes found for upgrade it will attempt first
				For $l = 0 To UBound($aHeroes) - 1
					If StringInStr($BuildingName, $aHeroes[$l]) Then
						SetDebugLog("Enabled HeroPriority = " & String($g_bHeroPriority) & ", Set Hero High Priority")
						$aBuilding[$j][6] = 20
					EndIf
				Next
			EndIf
			SetDebugLog("[" & $j & "] Building: " & $BuildingName & ", Cost=" & $UpgradeCost & " Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG)
		Next
	EndIf

	If ($g_bChkRushTH And $bFoundRusTH) Or $g_bHeroPriority Then
		_ArraySort($aBuilding, 1, 0, 0, 6) ;sort by score
	Else
		_ArraySort($aBuilding, 0, 0, 0, 5) ;sort by cost
	EndIf
	If $g_bUpgradeLowCost Then _ArraySort($aBuilding, 0, 0, 0, 5) ;sort by cost
	Return $aBuilding
EndFunc

Func CheckResourceForDoUpgrade($BuildingName, $Cost, $CostType)
	If Not $g_bRunState Then Return
	$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(701, 23) ;get current Gold
	$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(701, 74) ;get current Elixir
	If _CheckPixel($aVillageHasDarkElixir, True) Then ; check if the village have a Dark Elixir Storage
		$g_aiCurrentLoot[$eLootDarkElixir] = getResourcesMainScreen(728, 123)
	EndIf
	SetDebugLog("Gold:" & $g_aiCurrentLoot[$eLootGold] & " Elix:" & $g_aiCurrentLoot[$eLootElixir] & " DE:" & $g_aiCurrentLoot[$eLootDarkElixir])

	; initiate a False boolean, that firstly says that there is no sufficent resource to launch upgrade
	Local $bSufficentResourceToUpgrade = False
	; if Cost of upgrade + Value set in settings to be kept after upgrade > Current village resource, make boolean True and can continue
	Switch $CostType
		Case "Gold"
			If $g_aiCurrentLoot[$eLootGold] >= ($Cost + $g_iTxtSmartMinGold) Then $bSufficentResourceToUpgrade = True
			If (StringInStr($BuildingName, "Giga") Or StringInStr($BuildingName, "Town")) And $g_aiCurrentLoot[$eLootGold] >= $Cost Then ;bypass save resource for TH and TH weapon
				$bSufficentResourceToUpgrade = True
			EndIf
		Case "Elix"
			If $g_aiCurrentLoot[$eLootElixir] >= ($Cost + $g_iTxtSmartMinElixir) Then $bSufficentResourceToUpgrade = True
		Case "DE"
			If $g_aiCurrentLoot[$eLootDarkElixir] >= ($Cost + $g_iTxtSmartMinDark) Then $bSufficentResourceToUpgrade = True
	EndSwitch
	SetLog("Checking: " & $BuildingName & ", Cost: " & $Cost & " " & $CostType, $COLOR_INFO)
	SetLog("Is Enough " & $CostType & " ? " & String($bSufficentResourceToUpgrade), $bSufficentResourceToUpgrade ? $COLOR_SUCCESS : $COLOR_ERROR)
	Return $bSufficentResourceToUpgrade

EndFunc

Func DoUpgrade($bTest = False)
	If Not $g_bRunState Then Return

	; get the name and actual level of upgrade selected, if strings are empty, will exit Auto Upgrade, an error happens
	$g_aUpgradeNameLevel = BuildingInfo(242, 494)
	If $g_aUpgradeNameLevel[0] = "" Then
		SetLog("Error when trying to get upgrade name and level...", $COLOR_ERROR)
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
	If $bMustIgnoreUpgrade And Not $g_bUpgradeLowCost Then
		SetLog($g_aUpgradeNameLevel[1] & " : This upgrade must be ignored, looking next...", $COLOR_WARNING)
		Return False
	Else
		SetLog("UpgradeName: " & $g_aUpgradeNameLevel[1] & " Level: " & $g_aUpgradeNameLevel[2], $COLOR_DEBUG)
	EndIf

	; if upgrade not to be ignored, click on the Upgrade button to open Upgrade window
	ClickP($aUpgradeButton)
	If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return

	Local $bHeroUpgrade = False
	Switch $g_aUpgradeNameLevel[1]
		Case "Barbarian King", "Archer Queen", "Grand Warden", "Royal Champion", "poyal Champion"
			$g_aUpgradeResourceCostDuration[0] = QuickMIS("N1", $g_sImgAUpgradeRes, 690, 500, 730, 580) ; get resource
			$g_aUpgradeResourceCostDuration[1] = getResourcesBonus(598, 522) ; get cost
			$g_aUpgradeResourceCostDuration[2] = getHeroUpgradeTime(578, 465) ; get duration
			$bHeroUpgrade = True
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
			Clickaway("Right")
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

	; final click on upgrade button, click coord is get looking at upgrade type (heroes have a diferent place for Upgrade button)
	If Not $bTest Then
		Switch $g_aUpgradeNameLevel[1]
			Case "Barbarian King", "Archer Queen", "Grand Warden", "Royal Champion", "poyal Champion"
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
		SetLog("Something is wrong, Gem Window Opened", $COLOR_ERROR)
	Else
		SetLog(" - Cost : " & _NumberFormat($g_aUpgradeResourceCostDuration[1]) & " " & $g_aUpgradeResourceCostDuration[0], $COLOR_SUCCESS)
		SetLog(" - Duration : " & $g_aUpgradeResourceCostDuration[2], $COLOR_SUCCESS)
		AutoUpgradeLog($g_aUpgradeNameLevel, $g_aUpgradeResourceCostDuration)
	EndIf

	If $bHeroUpgrade And $g_bUseHeroBooks Then
		_Sleep(500)
		Local $HeroUpgradeTime = ConvertOCRTime("UseHeroBooks", $g_aUpgradeResourceCostDuration[2], False)
		If $HeroUpgradeTime >= ($g_iHeroMinUpgradeTime * 1440) Then
			SetLog("Hero Upgrade Time minutes: " & $HeroUpgradeTime, $COLOR_DEBUG)
			SetLog("MinUpgradeTime on Setting: " & ($g_iHeroMinUpgradeTime * 1440), $COLOR_DEBUG)
			SetLog("Looking if Hero Books avail")
			Local $HeroBooks = FindButton("HeroBooks")
			If IsArray($HeroBooks) And UBound($HeroBooks) = 2 Then
				SetLog("Use Hero Books to Complete Now this Hero Upgrade", $COLOR_INFO)
				Click($HeroBooks[0], $HeroBooks[1])
				_Sleep(1000)
				If QuickMis("BC1", $g_sImgGeneralCloseButton, 560, 225, 610, 275) Then
					Click(430, 400)
				EndIf
			Else
				SetLog("No Books of Heroes Found", $COLOR_DEBUG)
			EndIf
		EndIf
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

	Click($x, $y); click on upgrade window
	For $i = 1 To 5
		If IsFullScreenWindow() Then
			_Sleep(1000)
			ExitLoop
		EndIf
	Next
	If Not $g_bRunState Then Return
	;Search the arrow
	If QuickMIS("BC1", $g_sImgArrowNewBuilding, 10, 130, 840, 560) Then
		Click($g_iQuickMISX - 50, $g_iQuickMISY + 50)
		If _Sleep(2500) Then Return
		If Not $g_bRunState Then Return
		If $IsWall Then
			Local $aWall[3] = ["2","Wall",1]
			Local $aCostWall[3] = ["Gold", 50, 0]
			If QuickMIS("BC1", $g_sImgGreenCheck, 100, 80, 740, 560) Then
				For $ProMac = 0 To 9
					If Not $g_bRunState Then Return
					Click($g_iQuickMISX, $g_iQuickMISY + 5)
					If _Sleep(500) Then Return
					If IsGemOpen(True) Then
						SetLog("Not Enough resource! Exiting", $COLOR_ERROR)
						ExitLoop
					Endif
					AutoUpgradeLogPlacingWall($aWall, $aCostWall)
				Next
				Click($g_iQuickMISX - 75, $g_iQuickMISY)
				Return True
			EndIf
		EndIf

		; Lets search for the Correct Symbol on field
		SetDebugLog("Looking for GreenCheck Button", $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgGreenCheck, 100, 80, 740, 560) Then
			SetDebugLog("GreenCheck Button Found in [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_INFO)
			If Not $g_bRunState Then Return
			If Not $bTest Then
				Click($g_iQuickMISX, $g_iQuickMISY)
			Else
				SetDebugLog("ONLY for TESTING!!!", $COLOR_ERROR)
				Click($g_iQuickMISX - 75, $g_iQuickMISY)
				Return True
			EndIf
			SetLog("Placed a new Building on Main Village! [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_SUCCESS)
			If _Sleep(500) Then Return
			If AutoUpgradeLog() Then
				Click($g_iQuickMISX - 75, $g_iQuickMISY) ; Just click RedX position, in case its still there
			Else
				Click($g_iQuickMISX, $g_iQuickMISY) ; Just click GreenCheck position, in case its still there
			EndIf
			Return True
		Else
			SetDebugLog("GreenCheck Button NOT Found", $COLOR_ERROR)
			NotifyPushToTelegram($g_sProfileCurrentName & ": Failed to place new building in Main Village.")
			If Not $g_bRunState Then Return
			;Lets check if exist the [x], it should not exist, but to be safe
			If QuickMIS("BC1", $g_sImgRedX, 100, 80, 740, 560) Then
				Click($g_iQuickMISX, $g_iQuickMISY)
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

	If Not ClickMainBuilder($bTest) Then Return False
	If _Sleep(500) Then Return

	If FindTHInUpgradeProgress() Then
		SetLog("TownHall Upgrade in progress, skip search new building!", $COLOR_SUCCESS)
		Return False
	EndIf

	Local $ZoomedIn = False, $isWall = False
	Local $NeedDrag = True, $TmpUpgradeCost, $UpgradeCost, $sameCost = 0
	If Not $g_bRunState Then Return
	For $z = 0 To 10 ;for do scroll 8 times
		If Not $g_bRunState Then Return
		Local $New, $NewCoord, $aCoord[0][3]
		$TmpUpgradeCost = getMostBottomCost() ;check most bottom upgrade cost
		$NewCoord = FindNewBuilding() ;find New Building
		If IsArray($NewCoord) And UBound($NewCoord) > 0 Then
			SetLog("Found " & UBound($NewCoord) & " New Building", $COLOR_INFO)
			For $j = 0 To UBound($NewCoord) - 1
				SetLog("New: " & $NewCoord[$j][4] & ", cost: " & $NewCoord[$j][6] & " " & $NewCoord[$j][0], $COLOR_INFO)
				If $g_bChkRushTH And $g_bAutoUpgradeWallsEnable Then setMinSaveWall($NewCoord[$j][0], Number($NewCoord[$j][6]))
			Next

			$isWall = False ;reset var
			For $j = 0 To UBound($NewCoord) - 1
				If Not $g_bRunState Then Return
				If $NewCoord[$j][0] = "Gem" Then ContinueLoop
				If StringInStr($NewCoord[$j][4], "Wall") Then
					$IsWall = True
					SetLog("New Building: Is Wall, let's try place 10 Wall", $COLOR_INFO)
				EndIf
				If Not $g_bRunState Then Return
				If CheckResourceForDoUpgrade($NewCoord[$j][4], $NewCoord[$j][6], $NewCoord[$j][0]) And $NewCoord[$j][0] <> "Gem" Then
					If Not $ZoomedIn Then
						Clickaway("Right")
						If _Sleep(1000) Then Return ;wait builder menu closed
						If SearchGreenZone() Then
							$ZoomedIn = True
							ClickMainBuilder($bTest)
						Else
							ExitLoop ;zoomin failed, cancel placing newbuilding
						EndIf
					EndIf

					If AUNewBuildings($NewCoord[$j][1], $NewCoord[$j][2], $bTest, $IsWall) Then
						ClickMainBuilder($bTest)
						$z = 0 ;reset
						If Not AutoUpgradeCheckBuilder() Then ExitLoop
						ContinueLoop 2
					Else
						ExitLoop ;Place NewBuilding failed, cancel placing newbuilding
					EndIf
				Else
					SetDebugLog("[" & $j & "] New Building: " & $NewCoord[$j][4] & ", Not Enough Resource", $COLOR_ERROR)
				EndIf
			Next
		Else
			SetLog("New Building Not Found", $COLOR_INFO)
		EndIf

		If $g_bChkRushTH Then ;add RushTH priority TownHall, Giga Tesla, Giga Inferno //skip if will use builder for lowcost
			SetLog("Search RushTHPriority Building on Builder Menu", $COLOR_INFO)
			Local $aResult = FindExistingBuilding()
			If isArray($aResult) And UBound($aResult) > 0 Then
				For $y = 0 To UBound($aResult) - 1
					If $aResult[$y][7] = "Priority" Then
						SetLog("RushTHPriority: " & $aResult[$y][3] & ", Cost: " & $aResult[$y][5], $COLOR_INFO)
					EndIf
				Next
				If Not $g_bRunState Then Return
				For $y = 0 To UBound($aResult) - 1
					If $aResult[$y][7] = "Priority" Then
						If CheckResourceForDoUpgrade($aResult[$y][3], $aResult[$y][5], $aResult[$y][0]) Then ;name, cost, type
							Click($aResult[$y][1], $aResult[$y][2])
							If _Sleep(1000) Then Return
							If DoUpgrade($bTest) Then ExitLoop ;exit this loop, because successfull upgrade will reset upgrade list on builder menu
						Else
							SetDebugLog("Skip this building, not enough resource", $COLOR_WARNING)
						EndIf
					EndIf
				Next
			EndIf
			If Not $g_bRunState Then Return
		EndIf

		SetDebugLog("TmpUpgradeCost = " & $TmpUpgradeCost & " UpgradeCost = " & $UpgradeCost, $COLOR_INFO)
		If $UpgradeCost = $TmpUpgradeCost Then $sameCost += 1
		If Not ($UpgradeCost = $TmpUpgradeCost) Then $sameCost = 0
		If $sameCost > 1 Then $NeedDrag = False
		$UpgradeCost = $TmpUpgradeCost

		If Not $g_bRunState Then Return
		If Not AutoUpgradeCheckBuilder($bTest) Then ExitLoop
		If Not $NeedDrag Then
			SetLog("[" & $z & "] Scroll Not Needed!", $COLOR_DEBUG)
			ExitLoop
		EndIf
		If Not $g_bRunState Then Return
		ClickDragAUpgrade("up", 328);do scroll up
		SetLog("[" & $z & "] SameCost=" & $sameCost & " [" & $UpgradeCost & "]", $COLOR_DEBUG)
		If _Sleep(1000) Then Return
	Next
	SetLog("Exit Find NewBuilding", $COLOR_DEBUG)
EndFunc ;==>AutoUpgradeSearchNewBuilding

Func FindNewBuilding()
	Local $aTmpCoord, $aBuilding[0][7], $UpgradeCost, $aUpgradeName, $UpgradeType = ""
	If QuickMIS("BC1", $g_sImgAUpgradeObstNew, 200, 73, 300, 390) Then
		_Sleep(1000); search for 1 'new' image first, if found, add more delay
	Else
		Return $aBuilding
	EndIf
	$aTmpCoord = QuickMIS("CNX", $g_sImgAUpgradeObstNew, 200, 73, 300, 390)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			If QuickMIS("BC1", $g_sImgResourceIcon, $aTmpCoord[$i][1] + 100 , $aTmpCoord[$i][2] - 12, $aTmpCoord[$i][1] + 250, $aTmpCoord[$i][2] + 12) Then
				$UpgradeType =  $g_iQuickMISName
				_ArrayAdd($aBuilding, $UpgradeType & "|" & $g_iQuickMISX & "|" & $g_iQuickMISY & "|" & $aTmpCoord[$i][1])
			EndIf
		Next

		For $j = 0 To UBound($aBuilding) -1
			$aUpgradeName = getBuildingName($aBuilding[$j][3], $aBuilding[$j][2] - 12) ;get upgrade name and amount
			$UpgradeCost = getOcrAndCapture("coc-buildermenu-cost", $aBuilding[$j][1], $aBuilding[$j][2] - 12, 120, 25, True)
			$aBuilding[$j][4] = $aUpgradeName[0]
			$aBuilding[$j][5] = $aUpgradeName[1]
			$aBuilding[$j][6] = Number($UpgradeCost)
			If $g_bChkRushTH And $g_bAutoUpgradeWallsEnable Then setMinSaveWall($aBuilding[$j][0], $aBuilding[$j][6])
			SetDebugLog("[" & $j & "] Building: " & $aBuilding[$j][4] & ", Cost=" & $aBuilding[$j][6] & " Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG)
		Next
	EndIf
	Return $aBuilding
EndFunc

Func FindEssentialBuilding()
	Local $aTmpCoord, $aBuilding[0][6], $UpgradeCost, $UpgradeName
	Local $aEssentialBuilding[8] = ["X Bow", "Inferno Tower", "Eagle Artillery", "Scattershot", "Wizard Tower", "Bomb Tower", "Air Defense", "Air Sweeper"]
	$aTmpCoord = QuickMIS("CNX", $g_sImgResourceIcon, 310, 80, 450, 390)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			If QuickMIS("BC1",$g_sImgAUpgradeObstGear, $aTmpCoord[$i][1] - 200, $aTmpCoord[$i][2] - 10, $aTmpCoord[$i][1], $aTmpCoord[$i][2] + 10) Then ContinueLoop ;skip geared and new
			$UpgradeName = getBuildingName(200, $aTmpCoord[$i][2] - 12) ;get upgrade name and amount
			For $j = 0 To UBound($g_aichkEssentialUpgrade) - 1
				SetDebugLog($UpgradeName[0] & "|" & $aEssentialBuilding[$j])
				If $g_aichkEssentialUpgrade[$j] > 0 And $UpgradeName[0] = $aEssentialBuilding[$j] Then
					_ArrayAdd($aBuilding, String($aTmpCoord[$i][0]) & "|" & $aTmpCoord[$i][1] & "|" & Number($aTmpCoord[$i][2]) & "|" & String($UpgradeName[0]) & "|" & Number($UpgradeName[1])) ;compose the array
				EndIf
			Next
		Next
		For $j = 0 To UBound($aBuilding) -1
			$UpgradeCost = getOcrAndCapture("coc-buildermenu-cost", $aBuilding[$j][1], $aBuilding[$j][2] - 10, 120, 30, True)
			$aBuilding[$j][5] = Number($UpgradeCost)
			SetDebugLog("[" & $j & "] Building: " & $aBuilding[$j][5] & ", Cost=" & $UpgradeCost & " Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG)
		Next
		_ArraySort($aBuilding, 0, 0, 0, 5) ;sort by cost
		Return $aBuilding
	EndIf
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
	ClickMainBuilder()
	If $YY = Default And $Direction = "up" Then 
		Local $Tmp = QuickMIS("CNX", $g_sImgResourceIcon, 320, 80, 460, 360)
		If IsArray($Tmp) And UBound($Tmp) > 0 Then
			$YY = _ArrayMax($Tmp, 1, 0, -1, 2)
			SetDebugLog("DragUpY = " & $YY)
			If Number($YY) < 300 Then 
				SetLog("No need to dragUp!", $COLOR_INFO)
				Return
			EndIf
		Else
			$YY = 150
		EndIf
	EndIf
	For $checkCount = 0 To 2
		If Not $g_bRunState Then Return
		If IsBuilderMenuOpen() Then ;check upgrade window border
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
		If IsBuilderMenuOpen() Then ;check upgrade window border
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
	If Not _ColorCheck(_GetPixelColor(350,73, True), "FDFEFD", 50) Then
		Click(295, 20)
		If _Sleep(1000) Then Return
	EndIf

	If IsBuilderMenuOpen() Then
		SetDebugLog("Open Upgrade Window, Success", $COLOR_SUCCESS)
		$b_WindowOpened = True
	Else
		For $i = 1 To $Counter
			SetLog("Upgrade Window didn't open, trying again!", $COLOR_DEBUG)
			If IsFullScreenWindow() Then
				Click(825,45)
				If _Sleep(1000) Then Return
			EndIf
			Click(295, 20)
			If _Sleep(1000) Then Return
			If IsBuilderMenuOpen() Then
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
	Clickaway("Right")
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

Func IsTHLevelAchieved()
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
	Return $THLevelAchieved
EndFunc

Func getMostBottomCost()
	Local $TmpUpgradeCost, $TmpName, $ret
	Local $Icon = QuickMIS("CNX", $g_sImgResourceIcon, 300, 300, 450, 360)
	If IsArray($Icon) And UBound($Icon) > 0 Then
		_ArraySort($Icon, 1, 0, 0, 2) ;sort by y coord
		$TmpUpgradeCost = getOcrAndCapture("coc-buildermenu-cost", $Icon[0][1], $Icon[0][2] - 12, 120, 20, True) ;check most bottom upgrade cost
		$TmpName = getBuildingName($Icon[0][1] - 200, $Icon[0][2] - 8)
		$ret = $TmpName[0] & "|" & $TmpUpgradeCost
	EndIf
	Return $ret
EndFunc

Func setMinSaveWall($Type, $cost)
	Switch $Type
		Case "Gold"
			If Number($g_iUpgradeWallMinGold) >= Number($cost) Then Return
			$g_iUpgradeWallMinGold = $cost
			SetLog("Set Save Gold on Wall upgrade = " & $g_iUpgradeWallMinGold, $COLOR_DEBUG)
			applyConfig()
			saveConfig()
		Case "Elix"
			If Number($g_iUpgradeWallMinElixir) >= Number($cost) Then Return
			$g_iUpgradeWallMinElixir = $cost
			SetLog("Set Save Elix on Wall upgrade = " & $g_iUpgradeWallMinElixir, $COLOR_DEBUG)
			applyConfig()
			saveConfig()
	EndSwitch
EndFunc

Func FindTHInUpgradeProgress()
	Local $bRet = False
	Local $Progress = QuickMIS("CNX", $g_sImgAUpgradeHour, 350, 90, 450, 280)
	If IsArray($Progress) And UBound($Progress) > 0 Then
		For $i = 0 To UBound($Progress) - 1
			Local $UpgradeName = getBuildingName(200, $Progress[$i][2] - 5) ;get upgrade name and amount
			If StringInStr($UpgradeName[0], "Town", 1) Then
				$bRet = True
				ExitLoop
			EndIf
		Next
	EndIf
	Return $bRet
EndFunc

Func PlaceBuilder($bTest = False)
	Local $a_Gem = Number($g_iGemAmount)
	Local $a_Builder = Number($g_iTotalBuilderCount)
	If $a_Builder < 5 Then
		If ($a_Builder = 2 And $a_Gem > 499) Or  ($a_Builder = 3 And $a_Gem > 999) Or ($a_Builder = 4 And $a_Gem > 1999 ) Then SearchBuilder($bTest)
	EndIf
EndFunc

Func SearchBuilder($bTest = False)
	If Not $g_bRunState Then Return
	If Not $g_bPlaceNewBuilding Then Return
	SetLog("Search For Place New Builder", $COLOR_DEBUG)

	Local $ZoomedIn = False, $a_Builder = False

	If Not ClickMainBuilder($bTest) Then Return False
	If _Sleep(500) Then Return

	If Not $g_bRunState Then Return
	Local $New, $NewCoord, $aCoord[0][3]
	$NewCoord = FindNewBuilding() ;find New Building
	If IsArray($NewCoord) And UBound($NewCoord) > 0 Then
		SetLog("Found " & UBound($NewCoord) & " New Building", $COLOR_INFO)
		For $j = 0 To UBound($NewCoord) - 1
			If $NewCoord[$j][0] = "Gem" Then
				SetLog("New Builder Found!")
				$a_Builder = True
			EndIf

			If $a_Builder Then
				If Not $ZoomedIn Then
					Clickaway("Right")
					If _Sleep(1000) Then Return ;wait builder menu closed
					If SearchGreenZone() Then
						$ZoomedIn = True
						ClickMainBuilder($bTest)
					Else
						ExitLoop ;zoomin failed, cancel placing newbuilding
					EndIf
				EndIf

				If AUNewBuildings($NewCoord[$j][1], $NewCoord[$j][2], $bTest, False) Then ;False is for IsWall var
					ClickMainBuilder($bTest)
					ExitLoop
				Else
					ExitLoop ;Place NewBuilding failed, cancel placing newbuilding
				EndIf
			EndIf
		Next
	Else
		SetLog("New Building Not Found", $COLOR_INFO)
	EndIf

	Zoomout()
	If _Sleep(1000) Then Return

	SetLog("Exit Find Builder", $COLOR_DEBUG)
EndFunc

Func CCTutorial()
	For $i = 1 To 6
		SetLog("Wait for Arrow For Travel to Clan Capital #" & $i, $COLOR_INFO)
		ClickAway()
		_Sleep(3000)
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 330, 320, 450, 400) Then
			Click(400, 450)
			SetLog("Going to Clan Capital", $COLOR_SUCCESS)
			_Sleep(5000)
			ExitLoop ;arrow clicked now go to next step
		EndIf
		If $i > 1 And Not QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then Return
	Next

	If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then ;tutorial page, with strange person, click until arrow
		For $i = 1 To 5
			SetLog("Wait for Arrow on CC Peak #" & $i, $COLOR_INFO)
			ClickAway()
			_Sleep(3000)
			If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 330, 100, 450, 200) Then ;check clan capital map
				Click($g_iQuickMISX, $g_iQuickMISY) ;click capital peak arrow
				SetLog("Going to Capital Peak", $COLOR_SUCCESS)
				_Sleep(10000)
				ExitLoop ;arrow clicked now go to next step
			EndIf
		Next
	EndIf

	If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then ;tutorial page, with strange person, click until map button
		For $i = 1 To 5
			SetLog("Wait for Map Button #" & $i, $COLOR_INFO)
			ClickAway()
			_Sleep(3000)
			If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 20, 620, 90, 660) Then
				Click($g_iQuickMISX, $g_iQuickMISY) ;click map
				SetLog("Going back to Clan Capital", $COLOR_SUCCESS)
				_Sleep(5000)
				Click($g_iQuickMISX, $g_iQuickMISY) ;click return home
				SetLog("Return Home", $COLOR_SUCCESS)
				_Sleep(5000)
				ExitLoop ;map button clicked now go to next step
			EndIf
		Next
	EndIf

	For $i = 1 To 8
		SetLog("Wait for Arrow on CC Forge #" & $i, $COLOR_INFO)
		ClickAway()
		_Sleep(3000)
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 370, 350, 480, 450) Then ;check arrow on Clan Capital forge
			Click(420, 490) ;click CC Forge
			_Sleep(3000)
			ExitLoop
		EndIf
	Next

	For $i = 1 To 12
		SetLog("Wait for Arrow on CC Forge Window #" & $i, $COLOR_INFO)
		ClickAway()
		_Sleep(3000)
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 370, 350, 480, 450) Then
			Click(420, 490) ;click CC Forge
			_Sleep(3000)
		EndIf
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 125, 270, 225, 360) Then
			Click(180, 375) ;click collect
			_Sleep(3000)
			ExitLoop
		EndIf
	Next

	For $i = 1 To 10
		SetLog("Wait for MainScreen #" & $i, $COLOR_INFO)
		ClickAway()
		If _checkMainScreenImage($aIsMain) Then ExitLoop
		_Sleep(3000)
	Next
	ClickDrag(800, 420, 500, 420, 500)
	ZoomOut()
EndFunc

Func PlaceUnplacedBuilding($bTest = False)
	If SearchUnplacedBuilding() Then
		SetLog("Unplaced Building Found!", $COLOR_SUCCESS)
		If SearchGreenZone() Then
			If SearchUnplacedBuilding() Then
				SetLog("Trying to place Unplaced Bulding!", $COLOR_INFO)

				Click(431,571)
				If _Sleep(1500) Then Return False

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
					ZoomOut()
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
						ZoomOut()
						Return False
					EndIf
				EndIf
			Else
				SetLog("Unplaced Building Window Lost!", $COLOR_ERROR)
				ZoomOut()
			EndIf
		EndIf
	EndIf
EndFunc

Func SearchUnplacedBuilding()
	Local $atmpInfo = getNameBuilding(292, 494)
	If $atmpInfo = "" Then
		SetDebugLog("Search: Unplaced Building Not Found!")
		Return False
	Else
		If StringInStr($atmpInfo, "placed") = 0 Then
			SetDebugLog("Search: Not Unplaced Building Text!", $COLOR_INFO)
			Return False
		Else
			SetDebugLog("Search: Unplaced Building Found!", $COLOR_SUCCESS)
			Return True
		EndIf
	EndIf
EndFunc

Func IsBuilderMenuOpen()
	Local $bRet = False
	Local $aBorder[4] = [350, 73, 0xF7F8F5, 40]
	Local $sTriangle
	If _CheckPixel($aBorder, True) Then 
		SetDebugLog("Found Border Color: " & _GetPixelColor($aBorder[0], $aBorder[1], True), $COLOR_ACTION)
		$bRet = True ;got correct color for border 
	EndIf
	
	If Not $bRet Then ;lets re check if border color check not success
		$sTriangle = getOcrAndCapture("coc-buildermenu-main", 320, 60, 345, 73)
		SetDebugLog("$sTriangle: " & $sTriangle)
		If $sTriangle = "^" Then $bRet = True
	EndIf
	
	Return $bRet
EndFunc