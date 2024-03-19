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

Global $g_iXFindUpgrade = 300

Func AutoUpgrade($bTest = False, $bUpgradeLowCost = False)
	Local $bWasRunState = $g_bRunState
	$g_bRunState = True
	Local $Result = SearchUpgrade($bTest, $bUpgradeLowCost)
	$g_bRunState = $bWasRunState
	Return $Result
EndFunc

Func AutoUpgradeCheckBuilder($bTest = False)
	Local $bRet = False

	;PlaceBuilder()
	VillageReport(False, True) ;check available builder and resource (Gold,Elix,DE)
	
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
		SetLog("CheckBuilder: " & ($g_bUpgradeLowCost ? "Upgrade remain time > 1day" : "Upgrade remain time < 24h"), $COLOR_WARNING)
		$bRet = True
	EndIf

	If $bTest Then ;for testing, bypass
		$g_iFreeBuilderCount = 1
		$bRet = True
	Else
		If $g_iFreeBuilderCount = 1 Then 
			If _ColorCheck(_GetPixelColor(413, 43, True), Hex(0xFFAD62, 6), 20, Default, "AutoUpgradeCheckBuilder") Then 
				SetLog("Goblin Builder Found!", $COLOR_DEBUG1)
				$bRet = False
			EndIf
		EndIf
	EndIf

	If $g_bDebugSetLog Then SetLog("AutoUpgradeCheckBuilder() Free Builder : " & $g_iFreeBuilderCount, $COLOR_DEBUG)
	Return $bRet
EndFunc

Func SearchUpgrade($bTest = False, $bUpgradeLowCost = False)
	SetLog("Check for Auto Upgrade", $COLOR_DEBUG)
	If Not $g_bAutoUpgradeEnabled Then Return
	If Not $g_bRunState Then Return
	$g_bSkipWallReserve = False ;reset first
	$g_bUpgradeLowCost = False ;reset first
	If _Sleep(50) Then Return
	VillageReport(False, True)
	PlaceUnplacedBuilding()
	If $bUpgradeLowCost And $g_bUseWallReserveBuilder And $g_bUpgradeWallSaveBuilder And $g_bAutoUpgradeWallsEnable And $g_iFreeBuilderCount = 1 Then
		ClickMainBuilder()
		SetLog("Checking current upgrade", $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgAUpgradeHour, 480, 110, 555, 125) Then
			Local $sUpgradeTime = getBuilderLeastUpgradeTime($g_iQuickMISX - 50, $g_iQuickMISY - 8)
			SetLog("Least Upgrade time : " & $sUpgradeTime, $COLOR_INFO)
			Local $mUpgradeTime = ConvertOCRTime("OCR Minute", $sUpgradeTime)
			If $mUpgradeTime > 0 And $mUpgradeTime <= 1440 Then
				SetLog("Upgrade time < 24h, Will Use Wall Reserved Builder", $COLOR_INFO)
				$g_bSkipWallReserve = True
			ElseIf $mUpgradeTime > 1440 Then
				$g_bUpgradeLowCost = True
				SetLog("Upgrade time > 24h, will use for upgrade lowcost building", $COLOR_INFO)
			EndIf
		EndIf
	ElseIf $bUpgradeLowCost Then ;Trying LowCost Upgrade but other criterias are not met
		Return False
	EndIf
	
	;skip search new on first page
	Local $bSkip1st = $g_bUpgradeLowCost Or $g_bSkipWallReserve

	If Not $g_bRunState Then Return
	If AutoUpgradeCheckBuilder($bTest) Then
		_SearchUpgrade($bTest, $bSkip1st) ;search upgrade for existing building
		If _Sleep(2000) Then Return
	EndIf

	CheckBuilderPotion()
	If Not $g_bRunState Then Return
	Clickaway("Right")
	If _Sleep(1000) Then Return
	ZoomOut(True)
	Return False
EndFunc

Func _SearchUpgrade($bTest = False, $bSkip1st = False)
	If Not $g_bRunState Then Return
	SetLog("Search For Upgrade", $COLOR_DEBUG)
	If Not ClickMainBuilder($bTest) Then Return
	Local $Upgrades, $ZoomedIn = False, $isWall = False, $bDoScroll = True, $bNew = False, $bSkipNew = False, $bReadResource = False
	Local $b_BuildingFound = False, $TmpUpgradeCost, $UpgradeCost, $sameCost = 0
	Local $iZ = 1
	If $bSkip1st Then $iZ = 2
	For $z = $iZ To 15 ;for do scroll 15 times
		If Not $g_bRunState Then Return
		SetLog("Search For Upgrade #" & $z, $COLOR_ACTION)
		If Not ClickMainBuilder($bTest) Then Return
		If Not $g_bRunState Then Return
		$bNew = False ;reset
		$TmpUpgradeCost = getMostBottomCost() ;check most bottom upgrade cost
		If $UpgradeCost = $TmpUpgradeCost Then 
			$sameCost += 1
		Else
			$sameCost = 0
			$UpgradeCost = $TmpUpgradeCost
		EndIf
		SetLog("[" & $z & "] SameCost=" & $sameCost & " [" & $UpgradeCost & "]", $COLOR_DEBUG1)
		
		If $sameCost > 1 Then
			SetLog("Detected SameCost 3 times, exit!", $COLOR_DEBUG)
			ExitLoop
		EndIf
		
		$Upgrades = FindUpgrade($bTest, $bSkipNew)
		If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
			If $g_bUpgradeLowCost Then 
				_ArraySort($Upgrades, 0, 0, 0, 5)
				SetLog("UpgradeList scoring by : LowCost", $COLOR_INFO)
			ElseIf $g_bSkipWallReserve Then 
				_ArraySort($Upgrades, 1, 0, 0, 5)
				SetLog("UpgradeList scoring by : Highest Cost", $COLOR_INFO)
			Else
				SetLog("UpgradeList scoring by : Highest Priority", $COLOR_INFO)
				_ArraySort($Upgrades, 1, 0, 0, 6)
			EndIf
			
			For $i = 0 To UBound($Upgrades) - 1
				SetLog("[" & $Upgrades[$i][7] & "] " & $Upgrades[$i][3] & ", Cost:" & $Upgrades[$i][5] & " " & $Upgrades[$i][0] & ", Score: [" & ($Upgrades[$i][4] = "New" ? $Upgrades[$i][4] : $Upgrades[$i][6]) & "]", $COLOR_DEBUG1)
			Next
			
			For $i = 0 To UBound($Upgrades) - 1
				If $Upgrades[$i][4] = "New" Then ;new building					
					If CheckResourceForDoUpgrade($Upgrades[$i][3], $Upgrades[$i][5], $Upgrades[$i][0]) Then 
						If PlaceNewBuildingFromShop($Upgrades[$i][3], $ZoomedIn, $Upgrades[$i][5]) Then
							$g_bSkipWallReserve = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
							$g_bUpgradeLowCost = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
							$ZoomedIn = True
							$sameCost = 0
							$bNew = True
							If IsFullScreenWindow() Then Click(820, 37) ;close shop window
							If _Sleep(2000) Then Return
							If Not AutoUpgradeCheckBuilder($bTest) Then ExitLoop 2
						Else
							$ZoomedIn = False
							GoGoblinMap()
							ExitLoop
						EndIf
					EndIf
				EndIf
			Next
			If $bNew Then ContinueLoop
			
			For $i = 0 To UBound($Upgrades) - 1
				If $Upgrades[$i][6] = "Disabled" And $Upgrades[$i][7] = "Essential" Then 
					SetLog("Essential Building : " & $Upgrades[$i][3] & "[" & $Upgrades[$i][5] & "] Disabled, skip!", $COLOR_ACTION)
					ContinueLoop
				EndIf
				
				If CheckResourceForDoUpgrade($Upgrades[$i][3], $Upgrades[$i][5], $Upgrades[$i][0]) Then ;($BuildingName, $Cost, $CostType)
					If Not $g_bRunState Then Return
					Click($Upgrades[$i][1], $Upgrades[$i][2])
					If _Sleep(1000) Then Return
					If DoUpgrade($bTest) Then
						$g_bSkipWallReserve = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
						$g_bUpgradeLowCost = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
						$sameCost = 0
						$bDoScroll = False
						If Not AutoUpgradeCheckBuilder($bTest) Then ExitLoop 2
						ContinueLoop 2
					EndIf
				EndIf
			Next
		Else
			SetLog("No ExistingUpgrade Upgrade found!", $COLOR_INFO)
		EndIf
		
		If Not $g_bRunState Then Return
		If Not AutoUpgradeCheckBuilder($bTest) Then Return
		If $bDoScroll Then ClickDragAUpgrade("up", (($z > 5 And $SameCost = 0) ? 2 : 1)) ;do scroll up
		$bDoScroll = True
		;If _Sleep(1500) Then Return
	Next
EndFunc

Func FindUpgrade($bTest = False, $bSkipNew = False)
	If Not $g_bRunState Then Return
	SetLog("[FindUpgrade] RushTH:" & String($g_bChkRushTH) & ", UpLowCost:" & String($g_bUpgradeLowCost) & ", OtherDef:" & String($g_bUpgradeOtherDefenses), $COLOR_DEBUG1)
	If $g_bChkRushTH And Not IsTHLevelAchieved() Then SetLog("[FindUpgrade] Only Search for RushTH Building", $COLOR_INFO)
	If $bSkipNew Then SetLog("[FindUpgrade] Skip Search for New Building", $COLOR_INFO)
	If $g_bSkipWallReserve Then SetLog("[FindUpgrade] Search for using last Builder", $COLOR_INFO)
	
	If Not ClickMainBuilder($bTest) Then Return
	Local $ElixMultiply = 1, $GoldMultiply = 1 ;used for multiply score
	Local $Gold = $g_aiCurrentLoot[$eLootGold]
	Local $Elix = $g_aiCurrentLoot[$eLootElixir]
	If $Gold > $Elix Then $GoldMultiply += 1
	If $Elix > $Gold Then $ElixMultiply += 1
	Local $aTmpCoord, $aBuilding[0][8], $BuildingName, $UpgradeCost, $aUpgradeName, $tmpcost, $bFoundRushTH = False, $lenght = 0
	Local $aPriority[8][2] = [["Castle", 15], ["Pet", 13], ["Laboratory", 15], ["Storage", 14], ["Army", 13], ["Giga", 12], ["Town", 10], ["Blacksmith", 12]]
	Local $aRushTH[7][2] = [["Barracks", 8], ["Spell", 9], ["Workshop", 10], ["King", 8], ["Queen", 8], ["Warden", 8], ["Champion", 8]]
	Local $aHeroes[4] = ["Barbarian", "Queen", "Warden", "Champion"]
	
	;check if we found new building
	If Not $bSkipNew And Not $g_bUpgradeLowCost Then $aTmpCoord = QuickMIS("CNX", $g_sImgAUpgradeObstNew, $g_iXFindUpgrade, 73, 400, 400)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		If Not $g_bRunState Then Return
		_ArraySort($aTmpCoord, 0, 0, 0, 2)
		For $i = 0 To UBound($aTmpCoord) - 1
			Local $sCostType = ""
			If QuickMIS("BC1", $g_sImgResourceIcon, $aTmpCoord[$i][1] + 80, $aTmpCoord[$i][2] - 12, $aTmpCoord[$i][1] + 230, $aTmpCoord[$i][2] + 10) Then
				$sCostType = $g_iQuickMISName
				$lenght = Number($g_iQuickMISX) - $aTmpCoord[$i][1]
			EndIf
			;SetLog("length = " & $lenght)
			;SetLog("getBuildingName(" & $aTmpCoord[$i][1] + 10 & "," & $aTmpCoord[$i][2] - 12 & "," & $lenght & ")")
			$aUpgradeName = getBuildingName($aTmpCoord[$i][1] + 10, $aTmpCoord[$i][2] - 12, $lenght) ;get upgrade name and amount
			;SetLog(_ArrayToString($aUpgradeName))
			$tmpcost = getBuilderMenuCost($g_iQuickMISX + 5, $g_iQuickMISY - 10)
			Local $tmparray[1][8] = [[String($sCostType), $aTmpCoord[$i][1], Number($aTmpCoord[$i][2]), String($aUpgradeName[0]), "New", Number($tmpcost), "New", 0]]
			_ArrayAdd($aBuilding, $tmparray)
			If @error Then SetLog("FindUpgrade ComposeArray[New] Err : " & @error, $COLOR_ERROR)
			;_ArrayAdd($aBuilding, String($sCostType) & "|" & $aTmpCoord[$i][1] & "|" & Number($aTmpCoord[$i][2]) & "|" & String($aUpgradeName[0]) & "|New|" & $tmpcost) ;compose the array
		Next
		Local $aMultiBuilding[2] = ["Ricochet.+", "Multi.+"]
		For $sName In $aMultiBuilding
			Local $iIndex = _ArraySearch($aBuilding, $sName, 0, 0, 0, 3, 0, 3)
			If $iIndex > -1 Then
				SetLog("Found NewBuilding " & $aBuilding[$iIndex][3] & ", skip!!", $COLOR_ACTION)
				_ArrayDelete($aBuilding, $iIndex)
			EndIf
		Next
		
		If UBound($aBuilding) > 0 Then 
			_ArraySort($aBuilding, 0, 0, 0, 5) ;sort by cost
			Return $aBuilding ;return new building array
		EndIf
	EndIf
	
	If Not $g_bRunState Then Return
	;rest upgrades
	$aTmpCoord = QuickMIS("CNX", $g_sImgResourceIcon, 440, 80, 600, 408)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		If Not $g_bRunState Then Return
		_ArraySort($aTmpCoord, 0, 0, 0, 2)
		For $i = 0 To UBound($aTmpCoord) - 1
			If Not $g_bRunState Then Return
			If QuickMIS("BC1",$g_sImgAUpgradeObstGear, $g_iXFindUpgrade, $aTmpCoord[$i][2] - 10, $aTmpCoord[$i][1], $aTmpCoord[$i][2] + 10) Then
				If $g_iQuickMISName = "Gear" Then
					Local $bRet = DoGearUp($g_iQuickMISX + 20, $g_iQuickMISY)
					SetLog("Do GearUp result : " & String($bRet), $COLOR_INFO)
					ClickMainBuilder()
					If $bRet Then Return $aBuilding
				EndIf
				ContinueLoop ;skip geared and new
			EndIf
			
			$lenght = Number($aTmpCoord[$i][1]) - $g_iXFindUpgrade
			$aUpgradeName = getBuildingName($g_iXFindUpgrade, $aTmpCoord[$i][2] - 12, $lenght) ;get upgrade name and amount
			If $g_bChkRushTH And Not IsTHLevelAchieved() Then ;if rushth enabled, filter only rushth buildings
				Local $bRusTHFound = False
				For $x = 0 To UBound($aRushTH) - 1
					If StringInStr($aUpgradeName[0], $aRushTH[$x][0], 1) Then
						$bRusTHFound = True ;used for add array
						$bFoundRushTH = True ;used for sorting array
						ExitLoop
					EndIf
				Next
				If Not $bRusTHFound Then ; Optimization: no need to check if already found before
					For $x = 0 To UBound($aPriority) - 1
						If StringInStr($aUpgradeName[0], $aPriority[$x][0], 1) Then
							$bRusTHFound = True ;used for add array
							$bFoundRushTH = True ;used for sorting array
							ExitLoop
						EndIf
					Next
				EndIf
				If Not $bRusTHFound And Not $g_bUpgradeLowCost Then ;skip this building, RushTH enabled but this building is not RushTH building
					If $g_bDebugSetLog Then SetLog("Building:" & $aUpgradeName[0] & ", not rushTH or rushTH priority", $COLOR_DEBUG1)
					ContinueLoop 
				EndIf
			EndIf
			
			$tmpcost = getBuilderMenuCost($aTmpCoord[$i][1], $aTmpCoord[$i][2] - 10)
			If Number($tmpcost) = 0 Then ContinueLoop
			If $g_bUpgradeLowCost Then
				If $aTmpCoord[$i][0] = "DE" Then ContinueLoop
				If Number($tmpcost) > 500000 Then 
					SetLog("UpgradeLowCost=" & String($g_bUpgradeLowCost) & ", " & $aUpgradeName[0] & " : " & $tmpcost & " > 500000, skip", $COLOR_DEBUG1)
					ContinueLoop
				EndIf
			EndIf
			If $g_bSkipWallReserve Then 
				If Number($tmpcost) < 500000 And $aTmpCoord[$i][0] <> "DE" Then  
					SetLog("SkipWallReserve=" & String($g_bSkipWallReserve) & ", " & $aUpgradeName[0] & " : " & $tmpcost & " < 500000, skip", $COLOR_DEBUG1)
					ContinueLoop
				EndIf
			EndIf
			If CheckIgnoreUpgrade($aUpgradeName[0], $g_bUpgradeLowCost) Then 
				SetLog("UpgradeLowCost=" & String($g_bUpgradeLowCost) & ", " & $aUpgradeName[0] & " : " & $tmpcost & ", Ignored!", $COLOR_DEBUG1)
				ContinueLoop
			EndIf
			Local $tmparray[1][8] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1]), Number($aTmpCoord[$i][2]), String($aUpgradeName[0]), Number($aUpgradeName[1]), Number($tmpcost), 0, 0]]
			;_ArrayAdd($aBuilding, String($aTmpCoord[$i][0]) & "|" & $aTmpCoord[$i][1] & "|" & Number($aTmpCoord[$i][2]) & "|" & String($aUpgradeName[0]) & "|" & Number($aUpgradeName[1]) & "|" & Number($tmpcost)) ;compose the array
			_ArrayAdd($aBuilding, $tmparray)
			If @error Then SetLog("FindUpgrade ComposeArray Err : " & @error, $COLOR_ERROR)
		Next
		
		For $j = 0 To UBound($aBuilding) -1
			$BuildingName = $aBuilding[$j][3]
			$UpgradeCost = $aBuilding[$j][5]
			$aBuilding[$j][6] = 1
			For $k = 0 To UBound($aPriority) - 1
				If StringInStr($BuildingName, $aPriority[$k][0]) Then
					If $g_bDebugSetLog Then SetLog("[Priority] " & $aPriority[$k][0] & " : " & $BuildingName, $COLOR_DEBUG1)
					Switch $aBuilding[$j][0]
						Case "Gold"
							$aBuilding[$j][6] = $aPriority[$k][1] * $GoldMultiply
						Case "Elix"
							$aBuilding[$j][6] = $aPriority[$k][1] * $ElixMultiply
						Case "DE"
							$aBuilding[$j][6] = $aPriority[$k][1]
					EndSwitch
					$aBuilding[$j][7] = "Priority"
				EndIf
			Next
			
			If Not $g_bUpgradeLowCost Then
				For $k = 0 To UBound($aRushTH) - 1
					If StringInStr($BuildingName, $aRushTH[$k][0]) Then
						If $g_bDebugSetLog Then SetLog("[RushTH] " & $aRushTH[$k][0] & " : " & $BuildingName, $COLOR_DEBUG1)
						Switch $aBuilding[$j][0]
							Case "Gold"
								$aBuilding[$j][6] = $aRushTH[$k][1] * $GoldMultiply
							Case "Elix"
								$aBuilding[$j][6] = $aRushTH[$k][1] * $ElixMultiply
							Case "DE"
								$aBuilding[$j][6] = $aRushTH[$k][1]
						EndSwitch
						$aBuilding[$j][7] = "RushTH"
					EndIf
				Next
				
				For $k = 0 To UBound($g_aichkEssentialUpgrade) - 1
					If $g_bDebugSetLog Then SetDebugLog($BuildingName & "|" & $g_aEssential[$k])
					If StringInStr($BuildingName, $g_aEssential[$k]) Then
						SetLog("[Essential] " & $g_aEssential[$k] & " : " & $BuildingName & ", Enabled : " & String($g_aichkEssentialUpgrade[$k] = 1 ? True : False), $COLOR_DEBUG1)
						If $g_aichkEssentialUpgrade[$k] > 0 Then 
							$aBuilding[$j][6] = 9
							$aBuilding[$j][7] = "Essential"
						Else
							$aBuilding[$j][6] = "Disabled"
						EndIf
					EndIf
				Next
				
				If $g_bUpgradeOtherDefenses Then 
					For $sName In $g_aOtherDefense
						If StringInStr($BuildingName, $sName) Then
							If $g_bDebugSetLog Then SetLog("[OtherDefense] " & $sName & " : " & $BuildingName, $COLOR_DEBUG1)
							$aBuilding[$j][6] = 8
							$aBuilding[$j][7] = "OtherDefense"
						EndIf
					Next
				EndIf
			Else
				$aBuilding[$j][7] = "LowCost"
			EndIf
			
			If $g_bHeroPriority Then ;set score = 20 for Heroes, so if there is heroes found for upgrade it will attempt first
				For $l = 0 To UBound($aHeroes) - 1
					If StringInStr($BuildingName, $aHeroes[$l]) Then
						If $g_bDebugSetLog Then SetLog("[HeroPriority] " & $aHeroes[$l] & " : " & $BuildingName, $COLOR_DEBUG1)
						$aBuilding[$j][6] = 20
						$aBuilding[$j][7] = "HeroPriority"
					EndIf
				Next
			EndIf
			
			;SetLog("[" & $j & "] Building: " & $BuildingName & ", Cost=" & $UpgradeCost & ", score=" & $aBuilding[$j][6] & ", Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG1)
			If $g_bDebugSetLog Then SetLog("Scoring: " & $BuildingName & ", Cost=" & $UpgradeCost & ", Score=" & $aBuilding[$j][6], $COLOR_DEBUG1)
		Next
	EndIf
	
	;search upgrade with ocr read failed
	Local $iIndex = _ArraySearch($aBuilding, "0", 0, 0, 0, 0, 0, 5)
	If $iIndex > -1 Then
		SetLog("Found Building " & $aBuilding[$iIndex][3] & " with Zero cost, skip!!", $COLOR_ACTION)
		_ArrayDelete($aBuilding, $iIndex)
	EndIf
	
	;If ($g_bChkRushTH And $bFoundRushTH) Or $g_bHeroPriority Then
	;	_ArraySort($aBuilding, 1, 0, 0, 6) ;sort by score
	;Else
	;	_ArraySort($aBuilding, 0, 0, 0, 5) ;sort by cost
	;EndIf
	;
	;If Not $g_bChkRushTH And Not $g_bHeroPriority Then _ArraySort($aBuilding, 1, 0, 0, 5) ;sort by cost
	;
	;If $g_bUpgradeLowCost Then _ArraySort($aBuilding, 0, 0, 0, 5) ;sort by cost
	Return $aBuilding
EndFunc

Func CheckResourceForDoUpgrade($BuildingName, $Cost, $CostType)
	If Not $g_bRunState Then Return
	If $g_bDebugSetLog Then SetLog("Gold:" & $g_aiCurrentLoot[$eLootGold] & " Elix:" & $g_aiCurrentLoot[$eLootElixir] & " DE:" & $g_aiCurrentLoot[$eLootDarkElixir], $COLOR_DEBUG1)

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
		Case "Gem"
			If CheckPlaceBuilder() Then $bSufficentResourceToUpgrade = True
	EndSwitch
	SetLog("Checking: " & $BuildingName & ", Cost: " & $Cost & " " & $CostType, $COLOR_INFO)
	SetLog("Is Enough " & $CostType & " ? " & String($bSufficentResourceToUpgrade), $bSufficentResourceToUpgrade ? $COLOR_SUCCESS : $COLOR_ERROR)
	Return $bSufficentResourceToUpgrade
EndFunc

Func CheckIgnoreUpgrade($sUpgradeName = "", $bUpgradeLowCost = False)
	Local $bMustIgnoreUpgrade = False
	Switch $sUpgradeName
		Case "Barbarian King"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[1] = 1) ? True : False
		Case "Archer Queen"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[2] = 1) ? True : False
		Case "Grand Warden"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[3] = 1) ? True : False
		Case "Royal Champion"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[4] = 1) ? True : False
		Case "Clan Castle"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[5] = 1) ? True : False
		Case "Laboratory"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[6] = 1) ? True : False
		Case "Wall"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[7] = 1) ? True : False
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
		Case "Bomb", "Spring Trap", "Giant Bomb", "Air Bomb", "Seeking Air Mine", "Skeleton Trap", "Tornado Trap"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[19] = 1) ? True : False
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
	EndSwitch
	
	If $bUpgradeLowCost Then
		$bMustIgnoreUpgrade = False
		SetLog("[UpgradeLowCost] " & $sUpgradeName & ", CheckIgnoreUpgrade: " & String($bMustIgnoreUpgrade), $COLOR_DEBUG)
	EndIf
	
	If $g_bUpgradeOtherDefenses Then ;bypass for other defense building
		For $sName In $g_aOtherDefense
			If StringInStr($sUpgradeName, $sName) Then
				$bMustIgnoreUpgrade = False
				SetLog("[OtherDefense] " & $sUpgradeName & ", CheckIgnoreUpgrade: " & String($bMustIgnoreUpgrade), $COLOR_DEBUG)
				ExitLoop
			EndIf
		Next
	EndIf
	
	If $g_bDebugSetLog Then SetLog("CheckIgnoreUpgrade: " & $sUpgradeName & ", result=" & String($bMustIgnoreUpgrade), $COLOR_DEBUG)
	Return $bMustIgnoreUpgrade
EndFunc

Func DoUpgrade($bTest = False)
	If Not $g_bRunState Then Return

	; get the name and actual level of upgrade selected, if strings are empty, will exit Auto Upgrade, an error happens
	$g_aUpgradeNameLevel = BuildingInfo(242, 472)
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
	EndIf

	If Not(IsArray($aUpgradeButton) And UBound($aUpgradeButton, 1) = 2) Then
		SetLog("No upgrade here... Wrong click, looking next...", $COLOR_WARNING)
		Return False
	EndIf

	; check if the upgrade name is on the list of upgrades that must be ignored
	If $bMustIgnoreUpgrade Then
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
			$g_aUpgradeResourceCostDuration[0] = QuickMIS("N1", $g_sImgAUpgradeRes, 660, 500, 710, 580) ; get resource
			$g_aUpgradeResourceCostDuration[1] = getOcrAndCapture("coc-bonus", 558, 543, 110, 20, True) ; get cost
			$g_aUpgradeResourceCostDuration[2] = getHeroUpgradeTime(730, 546) ; get duration
			$bHeroUpgrade = True
		Case Else
			$g_aUpgradeResourceCostDuration[0] = QuickMIS("N1", $g_sImgAUpgradeRes, 660, 500, 710, 580) ; get resource
			$g_aUpgradeResourceCostDuration[1] = getOcrAndCapture("coc-bonus", 558, 543, 110, 20, True) ; get cost
			$g_aUpgradeResourceCostDuration[2] = getHeroUpgradeTime(730, 546) ; get duration
	EndSwitch

	If $g_aUpgradeNameLevel[1] = "Clan Castle" And $g_aUpgradeNameLevel[2] = "Broken" Then
		$g_aUpgradeResourceCostDuration[0] = "Gold"
		$g_aUpgradeResourceCostDuration[1] = "10000" ; get cost
		$g_aUpgradeResourceCostDuration[2] = "Instance Upgrade"
	EndIf

	; if one of the value is empty, there is an error, we must exit Auto Upgrade
	;For $i = 0 To 2
	;	;SetLog($g_aUpgradeResourceCostDuration[$i])
	;	If $g_aUpgradeResourceCostDuration[$i] = "" Then
	;		SetLog("Error at $g_aUpgradeResourceCostDuration, looking next...", $COLOR_ERROR)
	;		Clickaway("Right")
	;		Return False
	;	EndIf
	;Next
	;disable cost verify (ocr cannot read) after mei 2023 update

	Local $bMustIgnoreResource = False
	; matchmaking between resource name and the ignore list
	Switch $g_aUpgradeResourceCostDuration[0]
		Case "Gold"
			$bMustIgnoreResource = ($g_iChkResourcesToIgnore[0] = 1) ? True : False
		Case "Elixir"
			$bMustIgnoreResource = ($g_iChkResourcesToIgnore[1] = 1) ? True : False
		Case "DarkElixir"
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
				Click(625, 545)
			Case Else
				Click(625, 545)
		EndSwitch
		;If $g_aUpgradeNameLevel[1] = "Clan Castle" And $g_aUpgradeNameLevel[2] = "Broken" Then Click(600, 460)
	Else
		ClickAway("Right")
		Return False
	EndIf

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
		If _Sleep(2000) Then Return
		If _ColorCheck(_GetPixelColor(340, 510, True), Hex(0xFFCC7F, 6), 20, Default, "AutoUpgrade") And _ColorCheck(_GetPixelColor(510, 510, True), Hex(0xDDF685, 6), 20, Default, "AutoUpgrade") Then
			SetLog("Detected Before you upgrade warning window", $COLOR_INFO)
			Click(510, 525)
			If _Sleep(1000) Then Return
		EndIf
		
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
	EndIf

	If IsGemOpen(True) Then
		ClickAway("Right")
		SetLog("Something is wrong, Gem Window Opened", $COLOR_ERROR)
		ClickAway("Right")
	Else
		SetLog(" - Cost : " & _NumberFormat($g_aUpgradeResourceCostDuration[1]) & " " & $g_aUpgradeResourceCostDuration[0], $COLOR_SUCCESS)
		SetLog(" - Duration : " & $g_aUpgradeResourceCostDuration[2], $COLOR_SUCCESS)
		AutoUpgradeLog(False, $g_aUpgradeNameLevel[1], $g_aUpgradeNameLevel[2], $g_aUpgradeResourceCostDuration[1], $g_aUpgradeResourceCostDuration[2])
	EndIf

	If $bHeroUpgrade And $g_bUseHeroBooks Then
		_Sleep(500)
		Local $HeroUpgradeTime = ConvertOCRTime("UseHeroBooks", $g_aUpgradeResourceCostDuration[2], False)
		If $HeroUpgradeTime >= ($g_iHeroMinUpgradeTime * 1440) Then
			SetLog("Hero Upgrade Time minutes: [" & $HeroUpgradeTime & "] " & $HeroUpgradeTime & " minutes", $COLOR_DEBUG)
			SetLog("MinUpgradeTime on Setting: [" & $g_iHeroMinUpgradeTime & "] " & ($g_iHeroMinUpgradeTime * 1440) & " minutes", $COLOR_DEBUG)
			SetLog("Looking if Hero Books avail")
			UseHeroBooks()
		EndIf
	EndIf

	Return True
EndFunc

Func PlaceNewBuildingFromShop($sUpgrade = "", $bZoomedIn = False, $iCost = 0)
	If Not $g_bRunState Then Return
	ClickAway("Right")
	If _Sleep(1000) Then Return
	SetLog("Place NewBuilding : " & $sUpgrade & "", $COLOR_INFO)
	Local $bRet = False, $sUpgradeType = "", $ImageDir = ""
	$sUpgradeType = GetBuildingType($sUpgrade)
	SetLog("Opening Shop, UpgradeType : " & $sUpgradeType, $COLOR_DEBUG1)
	If $sUpgradeType = "" Then Return
	;search area to place new building
	If Not $bZoomedIn Then 
		If Not SearchGreenZone() Then Return $bRet
	EndIf
	
	;opening shop
	If Not OpenShop($sUpgradeType) Then Return
	If _Sleep(2000) Then Return
	Switch $sUpgradeType
		Case "Army"
			$ImageDir = $g_sImgShopArmy
		Case "Resources"
			$ImageDir = $g_sImgShopResources
		Case "Defenses"
			$ImageDir = $g_sImgShopDefenses
		Case "Traps"
			$ImageDir = $g_sImgShopTraps
	EndSwitch
	
	Local $sImgUpgrade = StringStripWS($sUpgrade, $STR_STRIPALL)
	SetLog("ImgUpgrade : " & $sUpgrade & "=" & $sImgUpgrade & "*", $COLOR_INFO)
	
	If QuickMIS("BFI", $ImageDir & $sImgUpgrade & "*", 20, 225, 830, 535) Then
		If $g_bDebugSetLog Then SetLog("Found " & $g_iQuickMISName & " on [" & $g_iQuickMISX & "," & $g_iQuickMISY &"]", $COLOR_SUCCESS)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(2500) Then Return
	Else
		Return $bRet
	EndIf
	
	If StringInStr($sUpgrade, "Wall") Then
		Local $aWall[3] = ["2","Wall",1]
		Local $aCostWall[3] = ["Gold", 50, 0]
		Local $tmpX = 0, $tmpY = 0, $iCount = 0
		If QuickMIS("BC1", $g_sImgGreenCheck) Then
			$tmpX = $g_iQuickMISX
			$tmpY = $g_iQuickMISY
		Else
			SetLog("GreenCheck Not Found", $COLOR_ERROR)
			GoGoblinMap()
			Return False
		EndIf
		
		For $ProMac = 1 To 20
			If Not $g_bRunState Then Return
			If $ProMac > 5 And $iCount > 2 Then ExitLoop
			If Not $g_bRunState Then Return
			If QuickMIS("BC1", $g_sImgGreenCheck, $tmpX - 40, $tmpY - 40, $tmpX + 40, $tmpY + 40) Then
				SetLog("Found " & $g_iQuickMISName & " on [" & $g_iQuickMISX & "," & $g_iQuickMISY &"]", $COLOR_SUCCESS)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If $g_iQuickMISName = "GreyCheck" Then 
					$iCount += 1
					SetLog("GreyCheck count : " & $iCount, $COLOR_DEBUG1)
				EndIf
				SetLog("Placing Wall #" & $ProMac, $COLOR_ACTION)
				If _Sleep(1000) Then Return
				If $g_aiCurrentLoot[$eLootGold] < 1000 Then
					If IsGemOpen(True) Then
						SetLog("Not Enough resource! Exiting", $COLOR_ERROR)
						ExitLoop
					EndIf
				EndIf
				If _Sleep(500) Then Return
				AutoUpgradeLog(True, "Wall")
			EndIf
		Next
		Click($g_iQuickMISX - 60, $g_iQuickMISY)
		If $iCount > 2 Then 
			$iCount = 0
			Return PlaceNewBuildingFromShop("Wall", True)
		EndIf
		Return True
	EndIf
	
	Local $a10sDuration[5] = ["Cannon", "Gold Mine", "Elixir Collector", "Gold Storage", "Elixir Storage"], $bWait10s = False
	For $sName In $a10sDuration
		If $sUpgrade = $sName Then $bWait10s = True
	Next
	
	SetLog("Looking for GreenCheck Button", $COLOR_INFO)
	If QuickMIS("BC1", $g_sImgGreenCheck) Then
		SetLog($g_iQuickMISName & " Button Found in [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_INFO)
		If Not $g_bRunState Then Return
		If $g_iQuickMISName = "GreyCheck" Then 
			SetLog("GreenCheck Not Found", $COLOR_ERROR)
			Click($g_iQuickMISX - 60, $g_iQuickMISY)
			Return False
		EndIf
		Click($g_iQuickMISX, $g_iQuickMISY)
		If $sUpgradeType = "Traps" Then Click($g_iQuickMISX, $g_iQuickMISY)
		SetLog("Placed " & $sUpgrade & " on Main Village! [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_SUCCESS)
		If _Sleep(1000) Then Return
		If $bWait10s Then _SleepStatus(10000)
		If AutoUpgradeLog(True, $sUpgrade, 1, $iCost, "New") Then
			Click($g_iQuickMISX - 60, $g_iQuickMISY) ; Just click RedX position, in case its still there
		EndIf
		Return True
	EndIf
	
	Return $bRet
EndFunc ;_PlaceNewBuildingFromShop

Func OpenShop($sUpgradeType = "Traps", $bCheckRedCounter = True)
	If Not $g_bRunState Then Return
	Local $bRet = False
	If WaitforPixel(815, 590, 816, 591, "E6F3ED", 10, 1) Then 
		Click(815, 590) ;Click Shop Button
		If _Sleep(1000) Then Return
	EndIf
	
	For $i = 1 To 5
		SetLog("Waiting Shop Window #" & $i, $COLOR_ACTION)
		If IsFullScreenWindow() Then 
			If QuickMIS("BC1", $g_sImgBuildingAndTraps, 150, 10, 320, 85) Then
				Click($g_iQuickMISX, $g_iQuickMISY) ;click Building and traps Tab
				If $g_iQuickMISName = "BuildActive" Then 
					$bRet = True
					ExitLoop
				EndIf
			EndIf
			If _Sleep(1000) Then Return
		EndIf
		If _Sleep(500) Then Return
	Next
	
	If Not $bCheckRedCounter Then Return $bRet
	
	$bRet = False ;reset for checking red counter
	Local $aRedPos[4] = [292, 418, 545, 671], $iRedPosY = 162
	If $bCheckRedCounter Then 
		Switch $sUpgradeType
			Case "Army"
				If WaitforPixel($aRedPos[0], $iRedPosY, $aRedPos[0] + 1, $iRedPosY + 1, "D7081B", 10, 1) Then 
					Click($aRedPos[0], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[0], $iRedPosY, $aRedPos[0] + 1, $iRedPosY + 1, "BBDC9D", 10, 1) Then 
					$bRet = True
				EndIf
			Case "Resources"
				If WaitforPixel($aRedPos[1], $iRedPosY, $aRedPos[1] + 1, $iRedPosY + 1, "D7081B", 10, 1) Then 
					Click($aRedPos[1], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[1], $iRedPosY, $aRedPos[1] + 1, $iRedPosY + 1, "BBDC9D", 10, 1) Then 
					$bRet = True
				EndIf
			Case "Defenses"
				If WaitforPixel($aRedPos[2], $iRedPosY, $aRedPos[2] + 1, $iRedPosY + 1, "D7081B", 10, 1) Then 
					Click($aRedPos[2], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[2], $iRedPosY, $aRedPos[2] + 1, $iRedPosY + 1, "BBDC9D", 10, 1) Then 
					$bRet = True
				EndIf
			Case "Traps"
				If WaitforPixel($aRedPos[3], $iRedPosY, $aRedPos[3] + 1, $iRedPosY + 1, "D7081B", 10, 1) Then 
					Click($aRedPos[3], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[3], $iRedPosY, $aRedPos[3] + 1, $iRedPosY + 1, "BBDC9D", 10, 1) Then 
					$bRet = True
				EndIf
		EndSwitch
	
		If Not $bRet Then SetLog("Fail Verify " & $sUpgradeType & " Tab, exit!", $COLOR_ERROR)
	EndIf
	SetLog("Opening " & $sUpgradeType & " Tab", $COLOR_ACTION)
	Return $bRet
EndFunc ;OpenShop

Func GetBuildingType($sUpgrades = "")
	If Not $g_bRunState Then Return
	Local $aArmy[11] = ["Barbarian", "Queen", "Warden", "Champion", "Camp", "Laboratory", "Barracks", "Factory", "Blacksmith", "Workshop", "Pet"]
	Local $aResource[5] = ["Collector", "Storage", "Mine", "Drill", "Hut"]
	Local $aDefense[12] = ["Wall", "Cannon", "Tower", "Mortar", "Sweeper", "Defense", "Tesla", "Bow", "ferno", "Eagle", "Scatter", "Monol"]
	Local $aTrap[5] = ["Bomb", "Trap", "Mine", "Drill", "Seeking"]
	Local $sUpgradeType = ""
	
	For $sArmy In $aArmy
		If StringInStr($sUpgrades, $sArmy) Then 
			$sUpgradeType = "Army"
		EndIf
	Next
		
	For $sResource In $aResource
		If StringInStr($sUpgrades, $sResource) Then 
			$sUpgradeType = "Resources"
		EndIf
	Next
	
	For $sDefense In $aDefense
		If StringInStr($sUpgrades, $sDefense) Then 
			$sUpgradeType = "Defenses"
		EndIf
	Next
		
	For $sTrap In $aTrap
		If StringInStr($sUpgrades, $sTrap) Then 
			$sUpgradeType = "Traps"
		EndIf
	Next
	
	If $sUpgrades = "Bomb Tower" Then $sUpgradeType = "Defenses"
	If $sUpgrades = "Dark Elixir Drill" Then $sUpgradeType = "Resources"
	If $sUpgrades = "Gold Mine" Then $sUpgradeType = "Resources"
	
	If $g_bDebugSetLog Then SetLog("Found UpgradeType : " & $sUpgradeType, $COLOR_DEBUG1)
	Return $sUpgradeType
EndFunc ;_GetBuildingType

Func SearchGreenZone()
	If Not $g_bRunState Then Return
	SetLog("Search GreenZone for Placing new Building", $COLOR_INFO)
	ZoomOut()
	
	Local $bSupportedScenery = False
	Local $sSceneryCode[3] = ["DS", "JS", "MS"]
	For $sCode In $sSceneryCode
		If $sCode = $g_sSceneryCode Then
			$bSupportedScenery = True
			ExitLoop
		EndIf
	Next
	
	If Not $bSupportedScenery Then
		SetLog("Detected Scenery : [" & $g_sSceneryCode & " : " & $g_sCurrentScenery & "]", $COLOR_ERROR)
		SetLog("Place New Building Only Supported for Default/Jungle/Magic Scenery", $COLOR_ERROR)
		Return False
	EndIf
	
	If Not $g_bRunState Then Return
	Local $x, $y, $Offset = 300, $iCount = 0
	Local $iTop, $iRight, $iBottom, $iLeft, $sArea
	Local $aArea = StringSplit($CocDiamondDCD, "|", $STR_NOCOUNT)
	;426,53|779,318|426,585|73,318
	If IsArray($aArea) And UBound($aArea) > 0 Then
		For $i = 0 TO UBound($aArea) - 1
			Local $aXY = StringSplit($aArea[$i], ",", $STR_NOCOUNT)
			If UBound($aXY) = 2 Then
				$x = $aXY[0]
				$y = $aXY[1]
				Switch $i
					Case 0
						$iTop = QuickMIS("Q1", $g_sImgAUpgradeGreenZone, $x - ($Offset/2), $y, $x + ($Offset/2), $y + $Offset)
						SetLog("Count Green Top = " & $iTop, $COLOR_DEBUG1)
						$iCount = Number($iTop)
						$sArea = "Top"
					Case 1
						$iRight = QuickMIS("Q1", $g_sImgAUpgradeGreenZone, $x - $Offset, $y - ($Offset/2), $x, $y + ($Offset/2))
						SetLog("Count Green Right = " & $iRight, $COLOR_DEBUG1)
						If $iCount < Number($iRight) Then 
							$iCount = Number($iRight)
							$sArea = "Right"
						EndIf
					Case 2
						$iBottom = QuickMIS("Q1", $g_sImgAUpgradeGreenZone, $x - ($Offset/2), $y - $Offset, $x + ($Offset/2), $y)
						SetLog("Count Green Bottom = " & $iBottom, $COLOR_DEBUG1)
						If $iCount < Number($iBottom) Then 
							$iCount = Number($iBottom)
							$sArea = "Bottom"
						EndIf
					Case 3
						$iLeft = QuickMIS("Q1", $g_sImgAUpgradeGreenZone, $x, $y - ($Offset/2), $x + $Offset, $y + ($Offset/2))
						SetLog("Count Green Left = " & $iLeft, $COLOR_DEBUG1)
						If $iCount < Number($iLeft) Then 
							$iCount = Number($iLeft)
							$sArea = "Left"
						EndIf
				EndSwitch
				;SetLog($i & ", Count = " & $iCount, $COLOR_DEBUG1)
			Else
				SetLog("UBound($aXY) != 2", $COLOR_DEBUG1)
			EndIf
		Next
		SetLog("Green Area = " & $sArea & ", count:" & $iCount, $COLOR_DEBUG1)
	Else
		SetLog("aArea Not Array", $COLOR_DEBUG1)
	EndIf
	
	If ZoomIn($sArea) Then
		SetLog("Succeed ZoomIn", $COLOR_DEBUG)
		Return True
	Else
		SetLog("Failed ZoomIn", $COLOR_ERROR)
	EndIf
	
	Return False
EndFunc

Func ClickDragAUpgrade($Direction = "Up", $DragCount = 1)
	If Not $g_bRunState Then Return
	Local $x = 400, $yUp = 130, $yDown = 800, $Delay = 1500, $YY = 0
	ClickMainBuilder()
	If $Direction = "up" Then
		Local $Tmp = QuickMIS("CNX", $g_sImgResourceIcon, 440, 300, 600, 410)
		If IsArray($Tmp) And UBound($Tmp) > 0 Then
			_ArraySort($Tmp, 1, 0, 0, 2)
			$x = $Tmp[0][1]
			$YY = $Tmp[0][2]
			If $YY > 350 Then $YY = 350 ;no over scroll
			If $g_bDebugSetLog Then SetLog("DragUpY = " & $YY)
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
							ClickDrag($x, $YY, $x, $yUp, $Delay, True) ;drag up
						Next
					Else
						ClickDrag($x, $YY, $x, $yUp, $Delay, True) ;drag up
					EndIf
					If _Sleep(1000) Then Return
				Case "Down"
					ClickDrag($x, $yUp, $x, $yDown, $Delay, True) ;drag to bottom
					If WaitforPixel(510, 88, 552, 91, "FFFFFF", 10, 1) Then
						ClickDrag($x, $yUp, $x, $yDown, $Delay, True) ;drag to bottom
					EndIf
					If _Sleep(5000) Then Return
			EndSwitch
			If $g_bDebugSetLog Then SetLog("Buildermenu Drag " & ($Direction = "Up" ? "Up" : "Down"), $COLOR_ACTION) 
		EndIf
		If IsBuilderMenuOpen() Then ;check upgrade window border
			If $g_bDebugSetLog Then SetLog("Upgrade Window Exist", $COLOR_INFO)
			Return True
		Else
			If $g_bDebugSetLog Then SetLog("Upgrade Window Gone!", $COLOR_DEBUG)
			ClickMainBuilder()
			If _Sleep(1000) Then Return
		EndIf
	Next
	Return False
EndFunc ;==>IsUpgradeWindow

Func ClickMainBuilder($bTest = False, $Counter = 3)
	If Not $g_bRunState Then Return
	Local $b_WindowOpened = False
	; open the builders menu
	If Not IsBuilderMenuOpen() Then
		SetLog("Opening BuilderMenu", $COLOR_ACTION)
		Click(400, 28)
		If _Sleep(1000) Then Return
	EndIf

	If IsBuilderMenuOpen() Then
		SetLog("Check BuilderMenu, Opened", $COLOR_SUCCESS)
		$b_WindowOpened = True
	Else
		For $i = 1 To $Counter
			If Not $g_bRunState Then Return
			SetLog("BuilderMenu Closed, trying again!", $COLOR_DEBUG)
			If IsFullScreenWindow() Then
				Click(825,45)
				If _Sleep(1000) Then Return
			EndIf
			Click(400, 28)
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
	If Not $g_bRunState Then Return
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
		If Not $g_bRunState Then Return
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
		If Not $g_bRunState Then Return
		$count += 1
		If _Sleep(250) Then Return
		If $count > 50 Then Return
	Wend
	SetLog("Field should be clear now", $COLOR_INFO)
EndFunc

Func IsTHLevelAchieved()
	Local $THLevelAchieved = True
	If $g_bUpgradeOnlyTHLevelAchieve Then
		If $g_iTownHallLevel >= $g_aiCmbRushTHOption[0] + 9 Then ;if option to only upgrade after TH level achieved enabled
			$THLevelAchieved = True
		Else
			$THLevelAchieved = False
		EndIf
	EndIf
	Return $THLevelAchieved
EndFunc

Func getMostBottomCost()
	If Not $g_bRunState Then Return
	Local $TmpUpgradeCost, $ret
	Local $Icon = QuickMIS("CNX", $g_sImgResourceIcon, 440, 340, 590, 408)
	If IsArray($Icon) And UBound($Icon) > 0 Then
		_ArraySort($Icon, 1, 0, 0, 2) ;sort by y coord, descending
		$TmpUpgradeCost = getOcrAndCapture("coc-buildermenu-cost", $Icon[0][1], $Icon[0][2] - 12, 120, 20, True) ;check most bottom upgrade cost
		$ret = $Icon[0][0] & "|" & $TmpUpgradeCost
	EndIf
	Return $ret
EndFunc

Func FindTHInUpgradeProgress()
	If Not $g_bRunState Then Return
	Local $bRet = False
	
	If QuickMIS("BC1", $g_sImgBuilderMenu, 250, 85, 400, 275) Then
		$g_iXFindUpgrade = $g_iQuickMISX - 30
		If $g_bDebugSetLog Then SetLog("XFindUpgrade = " & $g_iXFindUpgrade, $COLOR_SUCCESS)
	EndIf
	
	Local $Progress = QuickMIS("CNX", $g_sImgAUpgradeHour, 440, 90, 550, 280)
	If IsArray($Progress) And UBound($Progress) > 0 Then
		For $i = 0 To UBound($Progress) - 1
			Local $UpgradeName = getBuildingName($g_iXFindUpgrade, $Progress[$i][2] - 5) ;get upgrade name and amount
			If StringInStr($UpgradeName[0], "Town", 1) Then
				$bRet = True
				ExitLoop
			EndIf
		Next
	EndIf
	If $g_iTownHallLevel >= 12 Then $bRet = False
	If $bRet Then SetLog("TownHall " & $g_iTownHallLevel & " Upgrade in progress, skip search new building!", $COLOR_SUCCESS)
	Return $bRet
EndFunc

Func CheckPlaceBuilder($bTest = False)
	If Not $g_bRunState Then Return
	Local $bRet = False
	Local $a_Gem = Number($g_iGemAmount)
	Local $a_Builder = Number($g_iTotalBuilderCount)
	If $a_Builder < 5 Then
		If ($a_Builder = 2 And $a_Gem > 499) Or  ($a_Builder = 3 And $a_Gem > 999) Or ($a_Builder = 4 And $a_Gem > 1999 ) Then $bRet = True
	EndIf
	Return $bRet
EndFunc

Func CCTutorial()
	If Not $g_bRunState Then Return
	For $i = 1 To 6
		SetLog("Wait for Arrow For Travel to Clan Capital #" & $i, $COLOR_INFO)
		ClickAway("Right")
		_Sleep(3000)
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 330, 320, 450, 400) Then
			Click(400, 450)
			SetLog("Going to Clan Capital", $COLOR_SUCCESS)
			_Sleep(5000)
			ExitLoop ;arrow clicked now go to next step
		EndIf
		If $i > 1 And Not QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then Return
	Next
	
	If Not $g_bRunState Then Return
	If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then ;tutorial page, with strange person, click until arrow
		For $i = 1 To 5
			SetLog("Wait for Arrow on CC Peak #" & $i, $COLOR_INFO)
			ClickAway("Right")
			_Sleep(3000)
			If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 330, 100, 450, 200) Then ;check clan capital map
				Click($g_iQuickMISX, $g_iQuickMISY) ;click capital peak arrow
				SetLog("Going to Capital Peak", $COLOR_SUCCESS)
				_Sleep(10000)
				ExitLoop ;arrow clicked now go to next step
			EndIf
		Next
	EndIf
	
	If Not $g_bRunState Then Return
	If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then ;tutorial page, with strange person, click until map button
		For $i = 1 To 5
			SetLog("Wait for Map Button #" & $i, $COLOR_INFO)
			ClickAway("Right")
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
	
	If Not $g_bRunState Then Return
	For $i = 1 To 8
		SetLog("Wait for Arrow on CC Forge #" & $i, $COLOR_INFO)
		ClickAway("Right")
		_Sleep(3000)
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 370, 350, 480, 450) Then ;check arrow on Clan Capital forge
			Click(420, 490) ;click CC Forge
			_Sleep(3000)
			ExitLoop
		EndIf
	Next

	If Not $g_bRunState Then Return
	For $i = 1 To 12
		SetLog("Wait for Arrow on CC Forge Window #" & $i, $COLOR_INFO)
		ClickAway("Right")
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
	
	If Not $g_bRunState Then Return
	For $i = 1 To 10
		SetLog("Wait for MainScreen #" & $i, $COLOR_INFO)
		ClickAway("Right")
		If _checkMainScreenImage($aIsMain) Then ExitLoop
		_Sleep(3000)
	Next
	ClickDrag(800, 420, 500, 420, 500)
	ZoomOut()
EndFunc

Func AutoUpgradeLog($bNew = False, $aUpgradeName = "Traps", $iUpgradeLevel = 1, $iCost = 0 , $iDuration = 0)
	If Not $g_bRunState Then Return
	Local $txtAcc = $g_iCurAccount + 1
	Local $txtAccName = $g_sProfileCurrentName
	Local $sTxtUpgradeLog = "", $sTxtUpgradeLogToFile = "", $sUpgradeLogFile = $g_sProfileLogsPath & "\AutoUpgradeHistory.log"
	
	$sTxtUpgradeLog = @CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc & "] " & $txtAccName & ($bNew ? " - Placing New Building: " : " - Upgrading ")
	$sTxtUpgradeLogToFile = "[" & $txtAcc & "] " & $txtAccName & ($bNew ? " - Placing New Building: " : " - Upgrading ")
	If $bNew Then
		$sTxtUpgradeLog &= $aUpgradeName
		$sTxtUpgradeLogToFile &= $aUpgradeName
		_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, $sTxtUpgradeLog)
		_FileWriteLog($sUpgradeLogFile, $sTxtUpgradeLogToFile)
	Else
		$sTxtUpgradeLog &= $aUpgradeName & " to level " & $iUpgradeLevel + 1 & " Cost = " & $iCost & " Duration = " & $iDuration
		$sTxtUpgradeLogToFile &= $aUpgradeName & " to level " & $iUpgradeLevel + 1 & " Cost = " & $iCost & " Duration = " & $iDuration
		_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, $sTxtUpgradeLog)
		_FileWriteLog($sUpgradeLogFile, $sTxtUpgradeLogToFile)
	EndIf
	
	;If $aUpgradeNameLevel[1] <> "Traps" Then
	;	$aUpgradeNameLevel = BuildingInfo(242, 472)
	;	If $aUpgradeNameLevel[0] = "" Then
	;		SetLog("Error at AutoUpgradeLog() to get upgrade name and level", $COLOR_ERROR)
	;		$aUpgradeNameLevel[1] = "Traps"
	;		$bRet = False
	;	EndIf
	;
	;	_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, _
	;			@CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc + 1 & "] " & $txtAccName & _
	;			" - Placing New Building: " & $aUpgradeNameLevel[1])
	;
	;	_FileWriteLog($g_sProfileLogsPath & "\AutoUpgradeHistory.log", " [" & $txtAcc + 1 & "] " & $txtAccName & _
	;			" - Placing New Building: " & $aUpgradeNameLevel[1])
	;Else
	;	_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, _
	;			@CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc + 1 & "] " & $txtAccName & _
	;			" - Upgrading " & $aUpgradeNameLevel[1] & _
	;			" to level " & $aUpgradeNameLevel[2] + 1 & _
	;			" for " & _NumberFormat($aUpgradeResourceCostDuration[1]) & _
	;			" " & $aUpgradeResourceCostDuration[0] & _
	;			" - Duration : " & $aUpgradeResourceCostDuration[2])
	;
	;	_FileWriteLog($g_sProfileLogsPath & "\AutoUpgradeHistory.log", " [" & $txtAcc + 1 & "] " & $txtAccName & _
	;			" - Upgrading " & $aUpgradeNameLevel[1] & _
	;			" to level " & $aUpgradeNameLevel[2] + 1 & _
	;			" for " & _NumberFormat($aUpgradeResourceCostDuration[1]) & _
	;			" " & $aUpgradeResourceCostDuration[0] & _
	;			" - Duration : " & $aUpgradeResourceCostDuration[2])
	;EndIf
EndFunc

Func PlaceUnplacedBuilding($bTest = False)
	If Not $g_bRunState Then Return
	If SearchUnplacedBuilding() Then
		SetLog("Found Unplaced Building!", $COLOR_SUCCESS)
		If SearchGreenZone() Then
			SetLog("Trying to place Unplaced Bulding!", $COLOR_INFO)
			Click(431,571)
			If _Sleep(1500) Then Return
			If QuickMIS("BC1", $g_sImgGreenCheck) Then 
				Click($g_iQuickMISX, $g_iQuickMISY)
				SetLog("Unplaced Bulding, Succeed", $COLOR_SUCCESS)
			Else
				ZoomOut()
				GoGoblinMap()
			EndIf
			If _Sleep(1000) Then Return
			ZoomOut()
		Else
			SetLog("Trying to place Unplaced Bulding, Failed", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
EndFunc

Func IsBuilderMenuOpen()
	If Not $g_bRunState Then Return
	Local $bRet = False
	Local $aBorder0[4] = [427, 73, 0xFFFFFF, 20]
	Local $aBorder1[4] = [456, 73, 0xFFFFFF, 20]
	Local $sTriangle
	If _CheckPixel($aBorder0, True) And _CheckPixel($aBorder1, True) Then
		$bRet = True ;got correct color for border
	Else
		If $g_bDebugSetLog Then SetLog("IsBuilderMenuOpen Border0 Color Not Matched: " & _GetPixelColor($aBorder0[0], $aBorder0[1], True), $COLOR_DEBUG1)
		If $g_bDebugSetLog Then SetLog("IsBuilderMenuOpen Border1 Color Not Matched: " & _GetPixelColor($aBorder1[0], $aBorder1[1], True), $COLOR_DEBUG1)
	EndIf
	
	Return $bRet
EndFunc

Func DoGearUp($x, $y)
	If Not $g_bRunState Then Return
	SetLog("Do GearUp for OptimizeOTTO", $COLOR_INFO)
	Click($x, $y)
	If _Sleep(1000) Then Return
	Local $g_aUpgradeNameLevel = BuildingInfo(242, 472)
	If $g_aUpgradeNameLevel[0] = "" Then
		SetLog("Error when trying to get upgrade name and level...", $COLOR_ERROR)
		Return False
	EndIf

	If ClickB("GearUp") Then
		If _Sleep(1000) Then Return
		If QuickMIS("BC1", $g_sImgAUpgradeRes, 350, 410, 560, 500) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(1000) Then Return
			If IsGemOpen(True) Then
				ClickAway("Right")
				SetLog("Something is wrong, Gem Window Opened", $COLOR_ERROR)
				Return False
			Else
				SetLog(" - GearUp : " & $g_aUpgradeNameLevel[1], $COLOR_SUCCESS)
				Return True
			EndIf
		EndIf
	EndIf
EndFunc

Func CheckBuilderPotion()
	If Not $g_bRunState Then Return
	If $g_bUseBuilderPotion And $g_iFreeBuilderCount = 0 Then
		SetLog("Checking for Use Builder Potion", $COLOR_INFO)
		ClickMainBuilder()
		If _Sleep(500) Then Return
		If QuickMIS("BC1", $g_sImgAUpgradeHour, 480, 105, 560, 140) Then
			Local $sUpgradeTime = getBuilderLeastUpgradeTime($g_iQuickMISX - 50, $g_iQuickMISY - 8)
			Local $mUpgradeTime = ConvertOCRTime("Least Upgrade", $sUpgradeTime)
			If $mUpgradeTime > 540 Then
				SetLog("Upgrade time > 9h, will use Builder Potion", $COLOR_INFO)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(1000) Then Return
				If ClickB("BuilderPot") Then
					If _Sleep(1000) Then Return
					If ClickB("BoostConfirm") Then
						SetLog("Builder Boosted using potion", $COLOR_SUCCESS)
						ClickAway("Right")
					EndIf
				Else
					SetLog("BuilderPot Not Found", $COLOR_DEBUG)
					ClickAway("Right")
				EndIf
			Else
				SetLog("Upgrade time < 9h, cancel using builder potion", $COLOR_INFO)
			EndIf
		Else
			SetLog("Failed to read Upgrade time on BuilderMenu", $COLOR_ERROR)
		EndIf
	EndIf
EndFunc

Func UseHeroBooks()
	If Not $g_bRunState Then Return
	Local $HeroBooks = FindButton("HeroBooks")
	If IsArray($HeroBooks) And UBound($HeroBooks) = 2 Then
		SetLog("Use Hero Books to Complete Now this Hero Upgrade", $COLOR_INFO)
		Click($HeroBooks[0], $HeroBooks[1])
		_Sleep(1000)
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 600, 210, 650, 255) Then
			Click(430, 410)
		EndIf
	Else
		SetLog("No Books of Heroes Found", $COLOR_DEBUG)
	EndIf
EndFunc


;------------------------------------------
;old unused func below
;------------------------------------------
Func AutoUpgradeLogPlacingWall($aUpgradeNameLevel = Default, $aUpgradeResourceCostDuration = Default)
	If Not $g_bRunState Then Return
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

Func PlaceNewBuilding($x, $y, $bTest = False, $isWall = False, $BuildingName = "")
	If Not $g_bRunState Then Return
	Local $xstart = 50, $ystart = 50, $xend = 800, $yend = 600
	Local $UpLog[3] = [0, $BuildingName, 1]
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
			If QuickMIS("BC1", $g_sImgGreenCheck) Then
				For $ProMac = 1 To 10
					If Not $g_bRunState Then Return
					If Not $bTest Then
						Click($g_iQuickMISX, $g_iQuickMISY + 3)
						If _Sleep(500) Then Return
						If IsGemOpen(True) Then
							SetLog("Not Enough resource! Exiting", $COLOR_ERROR)
							ExitLoop
						EndIf
						AutoUpgradeLogPlacingWall($aWall, $aCostWall)
					Else
						SetLog("Only Test, should place wall on [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_SUCCESS)
						ExitLoop
					EndIf
				Next
				Click($g_iQuickMISX - 75, $g_iQuickMISY)
				Return True
			EndIf
		EndIf

		; Lets search for the Correct Symbol on field
		SetDebugLog("Looking for GreenCheck Button", $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgGreenCheck) Then
			SetDebugLog("GreenCheck Button Found in [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_INFO)
			If Not $g_bRunState Then Return
			If Not $bTest Then
				Click($g_iQuickMISX, $g_iQuickMISY)
			Else
				SetDebugLog("ONLY for TESTING!!!", $COLOR_ERROR)
				Click($g_iQuickMISX - 75, $g_iQuickMISY)
				Return True
			EndIf
			SetLog("Placed " & ($BuildingName = "" ? "a new Building" : $BuildingName) & " on Main Village! [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_SUCCESS)
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

Func FindNewUpgrade($bTest = False)
	If Not $g_bRunState Then Return
	Local $aTmpCoord, $aBuilding[0][7], $UpgradeCost, $aUpgradeName, $UpgradeType = ""
	If Not ClickMainBuilder($bTest) Then Return
	$aTmpCoord = QuickMIS("CNX", $g_sImgAUpgradeObstNew, $g_iXFindUpgrade, 73, 400, 390)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		If Not $g_bRunState Then Return
		_ArraySort($aTmpCoord, 0, 0, 0, 2)
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
			If $g_bDebugSetLog Then SetLog("[" & $j & "] Building: " & $aBuilding[$j][4] & ", Cost=" & $aBuilding[$j][6] & " Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG)
		Next
	EndIf
	
	Local $iIndex = _ArraySearch($aBuilding, "0", 0, 0, 0, 0, 0, 6)
	If $iIndex > -1 Then
		SetLog("Found NewBuilding with Zero cost, remove it", $COLOR_ACTION)
		_ArrayDelete($aBuilding, $iIndex)
	EndIf
	
	Local $aMultiBuilding[2] = ["Ricochet.+", "Multi-Archer.+"]
	For $sName In $aMultiBuilding
		$iIndex = _ArraySearch($aBuilding, $sName, 0, 0, 0, 3, 0, 4)
		If $iIndex > -1 Then
			SetLog("Found NewBuilding " & $aBuilding[$iIndex][4] & ", skip!!", $COLOR_ACTION)
			_ArrayDelete($aBuilding, $iIndex)
		EndIf
	Next
	
	Return $aBuilding
EndFunc

Func SearchBuilder($bTest = False)
	If Not $g_bRunState Then Return
	SetLog("Search For Place New Builder", $COLOR_ACTION)

	Local $ZoomedIn = False, $a_Builder = False

	If Not ClickMainBuilder($bTest) Then Return False
	If _Sleep(500) Then Return

	If Not $g_bRunState Then Return
	Local $New, $NewCoord, $aCoord[0][3]
	$NewCoord = FindNewUpgrade($bTest) ;find New Building
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

				If PlaceNewBuilding($NewCoord[$j][1], $NewCoord[$j][2], $bTest, False) Then ;False is for IsWall var
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

	Zoomout(True)
	If _Sleep(1000) Then Return

	SetLog("Exit Find Builder", $COLOR_DEBUG)
EndFunc

Func FindEssential()
	Local $aTmpCoord, $aBuilding[0][6], $UpgradeCost, $UpgradeName
	Local $g_aEssentialBuilding[8] = ["X Bow", "Inferno Tower", "Eagle Artillery", "Scattershot", "Wizard Tower", "Bomb Tower", "Air Defense", "Air Sweeper"]
	$aTmpCoord = QuickMIS("CNX", $g_sImgResourceIcon, 440, 80, 600, 408)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			If QuickMIS("BC1",$g_sImgAUpgradeObstGear, $aTmpCoord[$i][1] - 230, $aTmpCoord[$i][2] - 10, $aTmpCoord[$i][1] - 130, $aTmpCoord[$i][2] + 10) Then ContinueLoop ;skip geared and new
			$UpgradeName = getBuildingName(280, $aTmpCoord[$i][2] - 12) ;get upgrade name and amount
			For $j = 0 To UBound($g_aichkEssentialUpgrade) - 1
				SetDebugLog($UpgradeName[0] & "|" & $g_aEssentialBuilding[$j])
				If $g_aichkEssentialUpgrade[$j] > 0 And $UpgradeName[0] = $g_aEssentialBuilding[$j] Then
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

Func AutoUpgradeSearchNewBuilding($bTest = False)
	If Not $g_bRunState Then Return
	SetLog("Search For Place New Building", $COLOR_DEBUG)

	If Not ClickMainBuilder($bTest) Then Return False
	If _Sleep(500) Then Return

	If FindTHInUpgradeProgress() Then
		SetLog("TownHall Upgrade in progress, skip search new building!", $COLOR_SUCCESS)
		Return False
	EndIf

	Local $ZoomedIn = False, $isWall = False
	Local $bEnd = True, $TmpUpgradeCost, $UpgradeCost, $sameCost = 0
	If Not $g_bRunState Then Return
	For $z = 1 To 11 ;for do scroll 10 times
		If Not $g_bRunState Then Return
		Local $New, $NewCoord, $aCoord[0][3]

		$NewCoord = FindNewUpgrade() ;find New Building
		If IsArray($NewCoord) And UBound($NewCoord) > 0 Then
			SetLog("Found " & UBound($NewCoord) & " New Building", $COLOR_INFO)
			For $j = 0 To UBound($NewCoord) - 1
				SetLog("New: " & $NewCoord[$j][4] & ", cost: " & $NewCoord[$j][6] & " " & $NewCoord[$j][0], $COLOR_INFO)
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

					If PlaceNewBuilding($NewCoord[$j][1], $NewCoord[$j][2], $bTest, $IsWall) Then
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

		If Not ClickMainBuilder($bTest) Then Return False
		If $g_bChkRushTH Then ;add RushTH priority TownHall, Giga Tesla, Giga Inferno //skip if will use builder for lowcost
			SetLog("Search RushTHPriority Building on Builder Menu", $COLOR_INFO)
			Local $aResult = FindUpgrade()
			If isArray($aResult) And UBound($aResult) > 0 Then
				For $y = 0 To UBound($aResult) - 1
					If Not $g_bRunState Then Return
					If $aResult[$y][7] = "Priority" Then
						SetLog("RushTHPriority: " & $aResult[$y][3] & ", Cost: " & $aResult[$y][5], $COLOR_INFO)
					EndIf
				Next

				For $y = 0 To UBound($aResult) - 1
					If Not $g_bRunState Then Return
					If $aResult[$y][7] = "Priority" Then
						If CheckResourceForDoUpgrade($aResult[$y][3], $aResult[$y][5], $aResult[$y][0]) Then ;name, cost, type
							Click($aResult[$y][1], $aResult[$y][2])
							If _Sleep(1000) Then Return
							If DoUpgrade($bTest) Then ExitLoop ;exit this loop, because successfull upgrade will reset upgrade list on builder menu
						Else
							SetDebugLog("Skip this building, not enough resource", $COLOR_WARNING)
							If $g_bChkRushTH Then
								If $aResult[$y][0] = "Gold" And StringInStr($aResult[$y][3], "Town") Then
									Click($aResult[$y][1], $aResult[$y][2])
									If _Sleep(1000) Then Return
									Local $Building = BuildingInfo(242, 472)
									If $Building[0] = 2 And $Building[2] < $g_aiCmbRushTHOption[0] + 9 Then
										SetLog("TownHall Level = " & $Building[2] & " < " &$g_aiCmbRushTHOption[0] + 9, $COLOR_ACTION)
										setMinSaveWall($aResult[$y][0], $aResult[$y][5])
									EndIf
									If $Building[0] = 2 And $Building[2] >= $g_aiCmbRushTHOption[0] + 9 Then
										SetLog("TownHall Level = " & $Building[2] & " >= " &$g_aiCmbRushTHOption[0] + 9 & ", should skip this upgrade", $COLOR_ACTION)
										SetLog("Found TownHall, skip Search NewBuilding", $COLOR_INFO)
										ExitLoop 2
									EndIf
								Else
									If ($g_iSaveGoldWall = 0 Or $g_iSaveElixWall = 0) Then setMinSaveWall($aResult[$y][0], $aResult[$y][5])
								EndIf
							EndIf
						EndIf
					EndIf
				Next
			EndIf
			If Not $g_bRunState Then Return
		EndIf

		$TmpUpgradeCost = getMostBottomCost() ;check most bottom upgrade cost
		SetDebugLog("TmpUpgradeCost = " & $TmpUpgradeCost & " UpgradeCost = " & $UpgradeCost, $COLOR_INFO)
		If $UpgradeCost = $TmpUpgradeCost Then $sameCost += 1
		If Not ($UpgradeCost = $TmpUpgradeCost) Then $sameCost = 0
		If $sameCost > 1 Then $bEnd = False
		$UpgradeCost = $TmpUpgradeCost

		If Not $g_bRunState Then Return
		If Not AutoUpgradeCheckBuilder($bTest) Then ExitLoop
		If Not $bEnd Then
			SetLog("[" & $z & "] Scroll Not Needed!", $COLOR_DEBUG)
			ExitLoop
		EndIf
		If Not $g_bRunState Then Return
		ClickDragAUpgrade("up");do scroll up
		SetLog("[" & $z & "] SameCost=" & $sameCost & " [" & $UpgradeCost & "]", $COLOR_DEBUG)
		If _Sleep(1000) Then Return
	Next
	SetLog("Exit Find NewBuilding", $COLOR_DEBUG)
EndFunc ;==>AutoUpgradeSearchNewBuilding

Func FindOtherDefenses()
	Local $aTmpCoord, $aBuilding[0][6], $UpgradeCost, $UpgradeName
	Local $g_aEssentialBuilding[4] = ["Cannon", "Archer Tower", "Mortar", "Hidden Tesla"]
	$aTmpCoord = QuickMIS("CNX", $g_sImgResourceIcon, 440, 80, 600, 408)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			If QuickMIS("BC1",$g_sImgAUpgradeObstGear, $aTmpCoord[$i][1] - 230, $aTmpCoord[$i][2] - 10, $aTmpCoord[$i][1] - 100, $aTmpCoord[$i][2] + 10) Then ContinueLoop ;skip geared and new
			$UpgradeName = getBuildingName(280, $aTmpCoord[$i][2] - 12) ;get upgrade name and amount
			For $j = 0 To UBound($g_aEssentialBuilding) - 1
				SetDebugLog($UpgradeName[0] & "|" & $g_aEssentialBuilding[$j])
				If $UpgradeName[0] = $g_aEssentialBuilding[$j] Then
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

