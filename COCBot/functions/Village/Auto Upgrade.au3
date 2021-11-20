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
	ElseIf $g_iFreeBuilderCount - $iWallReserve - $g_iHeroReservedBuilder < 1 Then ;check builder reserve on wall and hero upgrade
		If $g_bDebugClick Then SetLog("FreeBuilder=" & $g_iFreeBuilderCount & ", Reserve ForHero=" & $g_iHeroReservedBuilder & " ForWall=" & $iWallReserve, $COLOR_INFO)
		SetLog("No builder available. Skipping Auto Upgrade!", $COLOR_WARNING)
		$bRet = False
	EndIf
	SetLog("Free Builder : " & $g_iFreeBuilderCount, $COLOR_DEBUG)
	Return $bRet
EndFunc

Func SearchUpgrade($bTest = False)
	SetLog("Check for Auto Upgrade", $COLOR_DEBUG)
	Local $bDebug = $g_bDebugSetlog
	If Not $g_bAutoUpgradeEnabled Then Return
	If Not $g_bRunState Then Return
	If Not AutoUpgradeCheckBuilder($bTest) Then Return
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
				ZoomOut() ;no builder, exit
				Return
			EndIf
			ClickDragAUpgrade("down"); after search reset upgrade window, scroll to top list
		EndIf
	EndIf
	
	If Not $g_bRunState Then Return
	If AutoUpgradeCheckBuilder($bTest) Then AutoUpgradeSearchExisting($bTest) ;search upgrade for existing building
	
	If AutoUpgradeCheckBuilder($bTest) Then ;Check if we have builder
		If Not $g_bNewBuildingFirst And $g_bPlaceNewBuilding Then ;check for new building after existing 
			AutoUpgradeSearchNewBuilding($bTest)
		EndIf
	EndIf
	
	ClickAway()
	ZoomOut()
	Return False
EndFunc

Func AutoUpgradeSearchExisting($bTest = False)
	SetLog("Search For Existing Upgrade", $COLOR_DEBUG)
	If Not ClickMainBuilder($bTest) Then Return
	Local $bDebug = $g_bDebugSetlog
	Local $b_BuildingFound = False, $NeedDrag = True, $FoundMostBottomRed = 0
	For $z = 0 To 9 ;for do scroll 10 times
		Local $x = 180, $y = 80, $x1 = 490, $y1 = 103, $step = 28
		For $i = 0 To 9
			If Not $g_bRunState Then Return
			If QuickMIS("BC1", $g_sImgAUpgradeZero, $x, $y-8, $x1, $y1+8) Then
				If QuickMIS("NX",$g_sImgAUpgradeObstGear, $x, $y-8, $x1, $y1+8) <> "none" Then
					SetLog("[" & $i & "] New Building Or GearUp, Skip!", $COLOR_SUCCESS)
					$b_BuildingFound = False
				Else
					If $g_bChkRushTH Then
						If QuickMIS("BC1", $g_sImgAUpgradeRushTH, $x, $y-8, $x1, $y1+8) Then
							SetLog("[" & $i & "] RushTH Building Found!", $COLOR_SUCCESS)
							$b_BuildingFound = True
						Else
							SetLog("[" & $i & "] Not RushTH Building!", $COLOR_SUCCESS)
							$b_BuildingFound = False
						EndIf
					Else
						SetLog("[" & $i & "] Upgrade found!", $COLOR_SUCCESS)
						$b_BuildingFound = True
					EndIf
				EndIf
				
				If $b_BuildingFound Then
					Click($g_iQuickMISX + $x, $g_iQuickMISY + $y)
					If _Sleep(1000) Then Return
					If DoUpgrade($bTest) Then
						$b_BuildingFound = False ;reset
						$z = 0 ;reset
						If Not AutoUpgradeCheckBuilder($bTest) Then ExitLoop 2
						ClickMainBuilder($bTest)
					Endif
				EndIf
			Else
				SetLog("[" & $i & "] No Upgrade found!", $COLOR_INFO)
				If $z > 4 And $i = 9 Then $NeedDrag = False ; sudah 5 kali scroll tapi yang paling bawah masih merah angka nya
			EndIf
			$y += $step
			$y1 += $step
		Next
		
		Local $aZeroWhiteMostBottom = _PixelSearch(430, 345, 450, 360, Hex(0xFFFFFF, 6), 10)
		If $aZeroWhiteMostBottom = 0 Then
			$FoundMostBottomRed += 1
			SetLog("No WhiteZero at most bottom list", $COLOR_DEBUG)
		ElseIf $FoundMostBottomRed > 0 Then
			$FoundMostBottomRed -= 1
			SetLog("Found WhiteZero at most bottom list", $COLOR_DEBUG)
		EndIf
		If $z > 1 And $FoundMostBottomRed > 1 Then $NeedDrag = False
		
		If Not $NeedDrag Then
			SetLog("[" & $z & "] Scroll Not Needed!", $COLOR_DEBUG)
			ExitLoop
		EndIf
		If Not AutoUpgradeCheckBuilder($bTest) Then ExitLoop
		ClickDragAUpgrade("up", $y - $step) ;do scroll up
		SetLog("[" & $z & "] Scroll Up", $COLOR_DEBUG)
		If _Sleep(1500) Then Return
	Next
EndFunc

Func DoUpgrade($bTest = False)

	If Not $g_bRunState Then Return
	
	; get the name and actual level of upgrade selected, if strings are empty, will exit Auto Upgrade, an error happens
	$g_aUpgradeNameLevel = BuildingInfo(242, 494)
	If $g_aUpgradeNameLevel[0] = "" Then
		SetLog("Error when trying to get upgrade name and level...", $COLOR_ERROR)
		GoGoblinMap()
		Return False
	EndIf
	
	Local $aUpgradeButton
	Local $bMustIgnoreUpgrade = False
	; check if any wrong click by verifying the presence of the Upgrade button (the hammer)
	
	If $g_aUpgradeNameLevel[1] = "Town Hall" And $g_aUpgradeNameLevel[2] > 11 Then
		If $g_iChkUpgradesToIgnore[35] = 1 Then ;TH Weapon
			$bMustIgnoreUpgrade = True
		Else
			$aUpgradeButton = findButton("THWeapon", Default, 1, True)
			If Not IsArray($aUpgradeButton) And Not UBound($aUpgradeButton, 1) = 2 Then
				SetLog("No Upgrade Weapon Button here... Wrong click, looking next...", $COLOR_WARNING)
				Return False
			EndIf
		Endif
	Else
		$aUpgradeButton = findButton("Upgrade", Default, 1, True)
		If Not(IsArray($aUpgradeButton) And UBound($aUpgradeButton, 1) = 2) Then
			SetLog("No upgrade here... Wrong click, looking next...", $COLOR_WARNING)
			Return False
		EndIf
		$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[0] = 1) ? True : False
	EndIf

	
	; matchmaking between building name and the ignore list
	If $g_aUpgradeNameLevel[1] = "po al Champion" Then $g_aUpgradeNameLevel[1] = "Royal Champion"
	Switch $g_aUpgradeNameLevel[1]
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
			If $g_bChkRushTH And $g_aUpgradeNameLevel[2] > 8 And $g_iTownHallLevel < 12 Then ;only upgrade to unlock dragon
				$bMustIgnoreUpgrade =  True
				SetLog("RushTH Building: Barracks Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
				SetLog("Skip Upgrade for saving elixir", $COLOR_INFO)
			EndIf			
		Case "Dark Barracks"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[9] = 1) ? True : False
			If $g_bChkRushTH And $g_aUpgradeNameLevel[2] > 3 And $g_iTownHallLevel < 12 Then ;only upgrade to unlock Golem
				$bMustIgnoreUpgrade =  True
				SetLog("RushTH Building: Dark Barracks Lvl " & $g_aUpgradeNameLevel[2], $COLOR_INFO)
				SetLog("Skip Upgrade for saving elixir", $COLOR_INFO)
			EndIf
		Case "Spell Factory"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[10] = 1) ? True : False
		Case "Dark Spell Factory"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[11] = 1) ? True : False
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
		Case "Bomb Tower"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[21] = 1) ? True : False
		Case "Air Defense"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[22] = 1) ? True : False
		Case "Air Sweeper"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[23] = 1) ? True : False
		Case "X Bow"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[24] = 1) ? True : False
		Case "Inferno Tower"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[25] = 1) ? True : False
		Case "Eagle Artillery"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[26] = 1) ? True : False
		Case "Scattershot"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[27] = 1) ? True : False
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
	
	; check if the upgrade name is on the list of upgrades that must be ignored
	If $bMustIgnoreUpgrade Then
		SetLog($g_aUpgradeNameLevel[1] & " : This upgrade must be ignored, looking next...", $COLOR_WARNING)
		Return False
	Else
		SetLog("Building Name: " & $g_aUpgradeNameLevel[1], $COLOR_DEBUG)
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
			SetLog("Error when trying to get upgrade details, looking next...", $COLOR_ERROR)
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
	ClickAway("Right")

	SetLog(" - Cost : " & _NumberFormat($g_aUpgradeResourceCostDuration[1]) & " " & $g_aUpgradeResourceCostDuration[0], $COLOR_SUCCESS)
	SetLog(" - Duration : " & $g_aUpgradeResourceCostDuration[2], $COLOR_SUCCESS)
	
	AutoUpgradeLog($g_aUpgradeNameLevel, $g_aUpgradeResourceCostDuration)
	
	Return True
EndFunc

Func AutoUpgradeLog($aUpgradeNameLevel = Default, $aUpgradeResourceCostDuration = Default)
	Local $txtAcc = $g_iCurAccount
	Local $txtAccName = $g_asProfileName[$g_iCurAccount]
	
	If $aUpgradeNameLevel = Default Then 
		$aUpgradeNameLevel = BuildingInfo(242, 494)
		If $aUpgradeNameLevel[0] = "" Then
			SetLog("Error when trying to get upgrade name and level", $COLOR_ERROR)
			$aUpgradeNameLevel[1] = "Traps"
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
	Return True
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

Func AUNewBuildings($x, $y, $bTest = False)

	Local $Screencap = True, $Debug = $g_bDebugSetlog
	Local $IsWall = False
	Local $xstart = 50, $ystart = 50, $xend = 800, $yend = 600
	Click($x, $y); click on upgrade window
	If _Sleep(5000) Then Return
	
	;Search the arrow
	Local $ArrowCoordinates = decodeSingleCoord(findImage("BBNewBuildingArrow", $g_sImgArrowNewBuilding, GetDiamondFromRect("40,180,860,600"), 1, True, Default))
	If UBound($ArrowCoordinates) > 1 Then
		;Check if its wall ?
		If QuickMIS("BC1", $g_sImgisWall, $ArrowCoordinates[0] - 180, $ArrowCoordinates[1] - 50, $ArrowCoordinates[0], $ArrowCoordinates[1], $Screencap, $Debug) Then
			SetLog("New Building is Wall!, lets try to place 10 Wall", $COLOR_INFO)
			$IsWall = True
		EndIf
		Click($ArrowCoordinates[0] - 50, $ArrowCoordinates[1] + 50) ;click new building on shop
		If _Sleep(2000) Then Return
	
		If $IsWall Then 
			Local $aWall[3] = ["2","Wall",1]
			Local $aCostWall[3] = ["Gold", 50, 0]
			local $aCoords = decodeSingleCoord(findImage("FindGreenCheck", $g_sImgGreenCheck & "\GreenCheck*", "FV", 1, True))
			If IsArray($aCoords) And UBound($aCoords) = 2 Then
				For $ProMac = 0 To 9 
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
		If IsArray($GreenCheckCoords) And UBound($GreenCheckCoords) = 2 Then
			If Not $bTest Then
				Click($GreenCheckCoords[0], $GreenCheckCoords[1])
			Else
				Click($GreenCheckCoords[0] - 75, $GreenCheckCoords[1])
				Return True
			EndIf
			SetLog("Placed a new Building on Main Village! [" & $GreenCheckCoords[0] & "," & $GreenCheckCoords[1] & "]", $COLOR_SUCCESS)
			If _Sleep(500) Then Return
			AutoUpgradeLog()
			Click($GreenCheckCoords[0] - 75, $GreenCheckCoords[1]) ; Just click RedX position, in case its still there
			Return True
		Else 
			;Lets check if exist the [x], it should not exist, but to be safe 
			Local $RedXCoords = decodeSingleCoord(findImage("FindGreenCheck", $g_sImgRedX & "\RedX*", "FV", 1, True))
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
	If Not $g_bPlaceNewBuilding Then Return
	SetLog("Search For Place New Building", $COLOR_DEBUG)
	Local $bDebug = $g_bDebugSetlog
	Local $bScreencap = True
	
	If Not ClickMainBuilder($bTest) Then Return False
	If _Sleep(500) Then Return
	
	Local $ZoomedIn = False
	Local $NeedDrag = True, $FoundMostBottomRed = 0
	If Not $g_bRunState Then Return
	For $z = 0 To 10 ;for do scroll 8 times
		If Not $g_bRunState Then Return
		Local $New, $NewCoord, $aCoord[0][2], $ZeroCoord
		Local $x = 180, $y = 80, $x1 = 480, $y1 = 103, $step = 28
		$NewCoord = QuickMIS("CX", $g_sImgAUpgradeObstNew, 180, 73, 280, 370, True) ;find New Building
		If IsArray($NewCoord) And UBound($NewCoord) > 0 Then 
			If Not $g_bRunState Then Return
			SetLog("Found " & UBound($NewCoord) & " New Building", $COLOR_INFO)
			For $j = 0 To UBound($NewCoord)-1
				$New = StringSplit($NewCoord[$j], ",", $STR_NOCOUNT)
				_ArrayAdd($aCoord, $New[0]+180 & "|" & $New[1]+73)
			Next
			_ArraySort($aCoord, 0, 0, 0, 1)
			For $j = 0 To UBound($aCoord) - 1
				If Not $g_bRunState Then Return
				If QuickMIS("BC1", $g_sImgAUpgradeZero & "\", $aCoord[$j][0] + 150, $aCoord[$j][1] - 8, $aCoord[$j][0] + 300, $aCoord[$j][1] + 8) Then
					SetLog("[" & $j & "] New Building: " & $aCoord[$j][0] & "," & $aCoord[$j][1], $COLOR_INFO)
					ClickAway()
					If _Sleep(1000) Then Return
					If Not $ZoomedIn Then
						If SearchGreenZone() Then 
							$ZoomedIn = True
						Else
							ExitLoop 2 ;zoomin failed, cancel placing newbuilding
						EndIf
					EndIf
					ClickMainBuilder($bTest)
					If AUNewBuildings($aCoord[$j][0], $aCoord[$j][1], $bTest) Then
						ClickMainBuilder($bTest)
						ExitLoop
					Else
						ExitLoop 2 ;Place NewBuilding failed, cancel placing newbuilding
					EndIf
				Else
					SetLog("[" & $j & "] New Building: " & $aCoord[$j][0] & "," & $aCoord[$j][1] & " Not Enough Resource", $COLOR_ERROR)
				EndIf
			Next
			
		EndIf
		
		If $g_bChkRushTH Then ;add RushTH priority TownHall, Giga Tesla, Giga Inferno
			If QuickMIS("BC1", $g_sImgAUpgradeRushTHPriority, 180, 80, 330, 369, True) Then
				SetLog("Found RushTH Priority Building", $COLOR_DEBUG)
				Local $tmpX = $g_iQuickMISX + 180, $tmpY = $g_iQuickMISY + 80
				If QuickMIS("BC1", $g_sImgAUpgradeZero & "\", $tmpX, $tmpY - 10, $tmpX + 200, $tmpY + 10) Then
					Click($g_iQuickMISX + $tmpX, $g_iQuickMISY + $tmpY - 10)
					If _Sleep(1000) Then Return
					If DoUpgrade($bTest) Then
						$FoundMostBottomRed = 0 ;reset
						$z = 0 ;reset
					Endif
				Else
					SetLog("But, No Resource", $COLOR_DEBUG)
				EndIf 
				SetLog("Skip Search NewBuilding, TH Found = No NewBuilding", $COLOR_DEBUG)
				ExitLoop
			EndIf
		EndIf
		
		Local $aZeroWhiteMostBottom = _PixelSearch(430, 345, 450, 360, Hex(0xFFFFFF, 6), 10)
		If $aZeroWhiteMostBottom = 0 Then
			$FoundMostBottomRed += 1
			SetLog("No WhiteZero at most bottom list", $COLOR_DEBUG)
		ElseIf $FoundMostBottomRed > 0 Then
			$FoundMostBottomRed -= 1
			SetLog("Found WhiteZero at most bottom list", $COLOR_DEBUG)
		EndIf
		
		If $z > 1 And $FoundMostBottomRed > 3 Then $NeedDrag = False
		
		If Not AutoUpgradeCheckBuilder($bTest) Then ExitLoop
		If Not $NeedDrag Then
			SetLog("[" & $z & "] Scroll Not Needed! Most Bottom Upgrade Not New Building", $COLOR_DEBUG)
			ExitLoop
		EndIf
		ClickDragAUpgrade("up", 328);do scroll up
		SetLog("[" & $z & "] Scroll Up", $COLOR_DEBUG)
		If _Sleep(1000) Then Return
	Next
	SetLog("Exit Find NewBuilding", $COLOR_DEBUG)
	ZoomOut()
	ClickAway()
EndFunc ;==>FindNewBuilding

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
	Return False
EndFunc

Func ClickDragAUpgrade($Direction = "up", $YY = Default, $DragCount = 1)
	Local $x = 420, $yUp = 103, $yDown = 800, $Delay = 500
	Local $Yscroll =  164 + (($g_iTotalBuilderCount - $g_iFreeBuilderCount) * 28)
	If $YY = Default Then $YY = $Yscroll
	If _Sleep(500) Then Return
	For $checkCount = 0 To 2
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(422, 73, True), "fdfefd", 20) Then ;check upgrade window border
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
		If _ColorCheck(_GetPixelColor(422, 73, True), "fdfefd", 20) Then ;check upgrade window border
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

Func ClickMainBuilder($bTest = False, $Counter = 1)
	Local $b_WindowOpened = False
	If Not $g_bRunState Then Return
	; open the builders menu
	If Not _ColorCheck(_GetPixelColor(422, 73, True), "fdfefd", 20) Then
		Click(295, 30)
		If _Sleep(1000) Then Return
	EndIf
	
	If _ColorCheck(_GetPixelColor(422, 73, True), "fdfefd", 20) Then
		SetLog("Open Upgrade Window, Success", $COLOR_SUCCESS)
		$b_WindowOpened = True
	Else
		If ($Counter < 4) Then
			SetLog("Upgrade Window didn't opened, trying again!", $COLOR_DEBUG)
			If IsFullScreenWindow() Then 
				Click(825,45)
				If _Sleep(1000) Then Return
			EndIf
			ClickMainBuilder(False, $Counter)
			$Counter += 1
		Else
			SetLog("Something is wrong with upgrade window, already tried 3 times!", $COLOR_DEBUG)
			$b_WindowOpened = False
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
	
	While Not IsAttackPage()
		If _Sleep(250) Then Return
	Wend
	
	If Not $g_bRunState Then Return
	
	If IsAttackPage() Then
		Click(66, 540)
	EndIf
	
	While Not IsMainPage()
		If _Sleep(250) Then Return
	Wend
	SetLog("Field should be clear now", $COLOR_INFO)
EndFunc
