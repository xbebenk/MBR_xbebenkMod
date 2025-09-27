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

Func UpgradeWall($bTest = False)

	If Not $g_bAutoUpgradeWallsEnable Then Return

	Local $aSelectedWall[3][2]
	For $z = 0 To 2
		$aSelectedWall[$z][0] = $g_aUpgradeWall[$z]
		$aSelectedWall[$z][1] = $g_aiWallCost[$g_aUpgradeWall[$z]]
	Next

	Local $iWallCost = $aSelectedWall[0][1]
	Local $iWallLevel = $aSelectedWall[0][0]
	Local $GoUpgrade = False
	If Not $g_bRunState Then Return

	SetLog("Checking Upgrade Walls", $COLOR_INFO)
	checkMainScreen(True, $g_bStayOnBuilderBase, "UpgradeWall")
	VillageReport(True, True) ;update village resource capacity
	If Not WallUpgradeCheckBuilder() And Not $bTest Then
		SetLog("No builder available, Upgrade Walls skipped", $COLOR_DEBUG)
		Return
	EndIf
	If $g_iFreeBuilderCount > 0 Then $GoUpgrade = True
	If $g_bChkOnly1Builder And $g_iFreeBuilderCount > 1 And Not $bTest Then
		SetLog("Have more than 1 builder, Upgrade Walls skipped", $COLOR_DEBUG)
		Return
	EndIf
	If _Sleep(50) Then Return

	;If $g_bChkWallOnlyGEFull Then
	;	Local $tmp_GoldFull = isGoldFull(), $tmp_ElixFull = isElixirFull()
	;
	;	Switch $g_iUpgradeWallLootType
	;		Case 0 ;Gold
	;			If Not $tmp_GoldFull Then
	;				SetLog("Gold is not full, skipping upgrade wall!", $COLOR_INFO)
	;				Return
	;			EndIf
	;		Case 1 ;Elixir
	;			If Not $tmp_ElixFull Then
	;				SetLog("Elixir is not full, skipping upgrade wall!", $COLOR_INFO)
	;				Return
	;			EndIf
	;		Case 2 ;Elixir Then Gold
	;			If Not ($tmp_GoldFull Or $tmp_ElixFull) Then
	;				SetLog("Gold or Elixir is not full! Skipping wall upgrade!", $COLOR_INFO)
	;				Return
	;			EndIf
	;	EndSwitch
	;
	;	If $tmp_GoldFull And $tmp_ElixFull Then
	;		$g_WallGEFull = 2
	;	ElseIf $tmp_GoldFull Then
	;		$g_WallGEFull = 1
	;	Else ;elix full
	;		$g_WallGEFull = 0
	;	EndIf
	;EndIf

	If $GoUpgrade Then 
		If NewUpgradeWall() Then Return NewUpgradeWall()
	EndIf
	VillageReport(True, True)
	Return

	If Not $g_bRunState Then Return
	If $GoUpgrade And $g_bUpgradeLowWall Then
		UpgradeLowLevelWall($bTest)
	EndIf


	Local $aIsResourceAvail = WallCheckResource($iWallCost, $iWallLevel+4) ;WallLevel from combolist, pick array[0], need to add 4 as cmblist start with 4
	SetDebugLog(_ArrayToString($aIsResourceAvail))
	If Not $aIsResourceAvail[0] Then Return

	If Not $g_bRunState Then Return
	If $GoUpgrade And Not $g_bUpgradeAnyWallLevel And Not $g_bUpgradeLowWall Then
		Clickaway("Right")
		VillageReport(True, True) ;update village resource capacity
		If $g_iFreeBuilderCount < 1 Then Return
		For $z = 0 To 2
			Local $searchcount = 0
			$iWallCost = $aSelectedWall[$z][1]
			$iWallLevel = $aSelectedWall[$z][0]
			SetLog("[" & $z & "] Try Upgrade WallLevel[" & $iWallLevel + 4 & "] Cost:" & $iWallCost, $COLOR_INFO)
			Local $MinWallGold = IsGoldEnough($iWallCost)
			Local $MinWallElixir = IsElixEnough($iWallCost)
			If Not $MinWallGold And Not $MinWallElixir Then ExitLoop

			While $MinWallGold Or $MinWallElixir
				If $searchcount > 1 Then ExitLoop
				If Not $g_bRunState Then Return
				$searchcount += 1
				Switch $g_iUpgradeWallLootType
					Case 0 ;Gold
						If $MinWallGold And imglocCheckWall($iWallLevel) Then
							SetLog("Try Upgrade Wall using Gold", $COLOR_INFO)
							If Not UpgradeWallGold($iWallCost, $bTest) Then
								SetLog("Upgrade with Gold failed", $COLOR_ERROR)
								ExitLoop
							EndIf
						EndIf
					Case 1 ;Elixir
						If $MinWallElixir And imglocCheckWall($iWallLevel) Then
							SetLog("Try Upgrade Wall using Elixir", $COLOR_INFO)
							If Not UpgradeWallElixir($iWallCost, $bTest) Then
								SetLog("Upgrade with Elixir failed", $COLOR_ERROR)
								ExitLoop
							EndIf
						EndIf
					Case 2 ;Elixir Then Gold
						If $MinWallElixir And imglocCheckWall($iWallLevel) Then
							SetLog("Try Upgrade Wall using Elixir", $COLOR_INFO)
							If Not UpgradeWallElixir($iWallCost, $bTest) Then
								SetLog("Upgrade with Elixir failed, attempt to upgrade using Gold", $COLOR_INFO)
								ExitLoop
							EndIf
						EndIf
						If $MinWallGold And imglocCheckWall($iWallLevel) Then
							SetLog("Try Upgrade Wall using Gold", $COLOR_INFO)
							If Not UpgradeWallGold($iWallCost, $bTest) Then
								SetLog("Upgrade with Gold failed, skip!", $COLOR_ERROR)
								ExitLoop
							EndIf
						EndIf
				EndSwitch

				Clickaway("Right")
				VillageReport(True, True)
				$MinWallGold = IsGoldEnough($iWallCost)
				$MinWallElixir = IsElixEnough($iWallCost)
				If Not $MinWallGold And $MinWallElixir Then ExitLoop
			Wend
		Next
	EndIf
	CheckMainScreen(False, $g_bStayOnBuilderBase, "UpgradeWall")
EndFunc   ;==>UpgradeWall

Func WallCheckResource($Cost = $g_aiWallCost[$g_aUpgradeWall[0]], $iWallLevel = $g_aUpgradeWall[0]+4)
	If $g_aiCurrentLoot[$eLootGold] < 0 Then $g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(690, 23) ;get current Gold
	If $g_aiCurrentLoot[$eLootElixir] < 0 Then $g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(690, 74) ;get current Elixir
	SetDebugLog("Current Resource, Gold: " & $g_aiCurrentLoot[$eLootGold] & " Elix: " & $g_aiCurrentLoot[$eLootElixir], $COLOR_INFO)
	Local $HaveResource = True
	Local $UpgradeType = "Gold"
	Switch $g_iUpgradeWallLootType
		Case 0 ;Gold
			Local $HaveGold = IsGoldEnough($Cost)
			$HaveResource = $HaveGold
			If $HaveResource Then $UpgradeType = "Gold"
			If Not $HaveResource Then SetLog("- Insufficient Gold", $COLOR_DEBUG)
		Case 1 ;Elixir
			Local $HaveElix = IsElixEnough($Cost)
			$HaveResource = $HaveElix
			If $HaveResource Then $UpgradeType = "Elix"
			If Not $HaveResource Then SetLog("- Insufficient Elixir", $COLOR_DEBUG)
		Case 2 ;Elixir Then Gold
			Local $HaveGold = IsGoldEnough($Cost)
			Local $HaveElix = IsElixEnough($Cost)
			;If $g_aiCurrentLoot[$eLootGold] < $g_iUpgradeWallMinGold And $g_aiCurrentLoot[$eLootElixir] < $g_iUpgradeWallMinElixir Then $HaveResource = False
			If Number($iWallLevel) > 3 Then
				$HaveResource = $HaveElix
				If $HaveResource Then $UpgradeType = "Elix"
				If Not $HaveResource Then
					SetLog("- Insufficient Elixir, attempt to Upgrade with Gold", $COLOR_DEBUG)
					$HaveResource = $HaveGold
					If $HaveResource Then $UpgradeType = "Gold"
					If Not $HaveResource Then SetLog("- Insufficient Gold", $COLOR_DEBUG)
				EndIf
				If Not $HaveResource Then
					SetLog("- Insufficient Elixir & Gold", $COLOR_DEBUG)
				EndIf
			Else
				$HaveResource = $HaveGold
				If $HaveResource Then $UpgradeType = "Gold"
				If Not $HaveResource Then SetLog("- Insufficient Gold", $COLOR_DEBUG)
			EndIf
	EndSwitch
	Local $aRet[2] = [$HaveResource, $UpgradeType]
	SetDebugLog("CheckResource: Ret=" & _ArrayToString($aRet) & " Cost=" & $Cost & " WallLevel=" & $iWallLevel, $COLOR_INFO)
	Return $aRet
EndFunc

Func WallUpgradeCheckBuilder($bTest = False)
	Local $bRet = False
	getBuilderCount(True)
	If $bTest Then
		$bRet = True
	Else
		If $g_iFreeBuilderCount < 1 Then
			$bRet = False
		Else
			If _ColorCheck(_GetPixelColor(413, 43, True), Hex(0xFFAD62, 6), 20, Default, "AutoUpgradeCheckBuilder") Then
				SetLog("WallUpgradeCheckBuilder, Free Builder = 1, Goblin Builder!, Return False", $COLOR_DEBUG1)
				$bRet = False
			Else
				$bRet = True
			EndIf
		EndIf
	EndIf
	Return $bRet
EndFunc

Func UpgradeLowLevelWall($bTest = False)
	If Not $g_bRunState Then Return
	SetLog("Upgrade LowLevel Wall using autoupgrade enabled", $COLOR_DEBUG)
	If Not ClickMainBuilder($bTest) Then Return
	Local $aWallCoord, $Try = 1, $WallNotFound = False, $PrevCost = 0, $ForceScroll = False
	While True
		If Not $g_bRunState Then Return
		If Not WallUpgradeCheckBuilder($bTest) Then Return
		$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(690, 23) ;get current Gold
		$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(690, 74) ;get current Elixir
		If $Try > 4 Then ExitLoop
		If $Try > 2 And $WallNotFound Then ExitLoop ; jump to exit
		SetLog("[" & $Try & "] Search Wall on Builder Menu", $COLOR_INFO)
		$Try += 1
		$aWallCoord = ClickDragFindWallUpgrade($ForceScroll)
		$ForceScroll = False

		If $g_iSaveGoldWall > $g_aiCurrentLoot[$eLootGold] And $g_iSaveElixWall > $g_aiCurrentLoot[$eLootElixir] Then
			SetLog("Upgrade Wall skipped, need to save for RushTH Priority Building", $COLOR_ACTION)
			Return
		EndIf

		If IsArray($aWallCoord) And UBound($aWallCoord) > 0 Then ; found a wall or list of wall
			If $PrevCost <> $aWallCoord[0][2] Then
				SetLog("Found a different wall!", $COLOR_INFO)
				$Try -= 1
			EndIf

			Local $aIsEnoughResource = WallCheckResource($aWallCoord[0][2]) ;check upgrade from lowest to highest price
			$PrevCost = $aWallCoord[0][2]

			If Not $aIsEnoughResource[0] Then
				SetDebugLog("01-Not WallCheckResource, Exiting")
				$ForceScroll = True
				ContinueLoop ; lets check another wall on list
				If $Try > 2 And $WallNotFound Then ExitLoop ; jump to exit
			EndIf

			IF TryUpgradeWall($aWallCoord, $bTest) Then ;select wall on builder menu and do upgrade
				$Try = 1 ;reset as we found a wall
			Else
				$ForceScroll = True
			EndIf
		Else
			SetLog("[" & $Try & "] Not Found Wall on Builder Menu", $COLOR_ERROR)
			$WallNotFound = True
		EndIf
	Wend
	ClickDragAUpgrade("down")
	Clickaway("Right")
	SetDebugLog("Upgrade Wall using autoupgrade EXIT")
EndFunc

Func TryUpgradeWall($aWallCoord, $bTest = False)
	Local $UpgradeToLvl = $g_iLowLevelWall
	For $i = 0 To UBound($aWallCoord) - 1
		If Not $g_bRunState Then Return
		If Not WallUpgradeCheckBuilder($bTest) Then Return
		For $j = 1 To 5
			ClickMainBuilder()
			SetLog("Wall " & "[" & $i & "] : [" & $aWallCoord[$i][0] & "," & $aWallCoord[$i][1] & " Cost = " & $aWallCoord[$i][2] & "]", $COLOR_DEBUG)
			If QuickMIS("BC1", $g_sImgAUpgradeObstGear, $aWallCoord[$i][0] - 50, $aWallCoord[$i][1] - 10, $aWallCoord[$i][0] + 50, $aWallCoord[$i][1] + 10) Then ContinueLoop
			Click($aWallCoord[$i][0], $aWallCoord[$i][1])
			If _Sleep(1000) Then Return
			Local $aWallLevel = BuildingInfo(242, 477)
			If $aWallLevel[0] = "" Then
				SetLog("Cannot read building Info, wrong click...", $COLOR_ERROR)
				If IsFullScreenWindow() Then Click(825,45)
				Return False
			EndIf
			If $aWallLevel[1] = "Wall" Then
				SetDebugLog("is a Wall...", $COLOR_INFO)
			Else
				SetLog("Not Wall, wrong click...", $COLOR_ERROR)
				Return False
			EndIf
			If Not $g_bUpgradeAnyWallLevel And $aWallLevel[2] > $UpgradeToLvl Then
				SetLog("Skip this Wall, searching wall level " & $UpgradeToLvl & " and below", $COLOR_ERROR)
				Return False
			EndIf
			SetLog("BuildingInfo: " & $aWallLevel[1] & " Level: " & $aWallLevel[2], $COLOR_SUCCESS)
			Local $aIsEnoughResource = WallCheckResource($aWallCoord[$i][2], $aWallLevel[2])
			If Not $aIsEnoughResource[0] Then
				SetDebugLog("Not Enough Resource, WallUpgrade cost: " & $aWallCoord[$i][2], $COLOR_ERROR)
				Return False
			EndIf
			If DoLowLevelWallUpgrade($aWallLevel[2], $bTest, $aWallCoord[$i][2]) Then
				If _Sleep(1000) Then Return
			Else
				Return False
			EndIf
		Next
	Next
	Return True
EndFunc

Func DoLowLevelWallUpgrade($WallLevel = 1, $bTest = False, $iWallCost = 1000)
	Local $UpgradeToLvl = $g_iLowLevelWall
	If Not $g_bRunState Then Return
	If $WallLevel >= $UpgradeToLvl And $g_bUpgradeAnyWallLevel Then
		SetLog("Upgrade Any Wall Level", $COLOR_INFO)
		Local $aIsEnoughResource = WallCheckResource($iWallCost, $WallLevel)
		If Not $aIsEnoughResource[0] Then Return
		Local $UpgradeButtonFound = False

		Switch $aIsEnoughResource[1]
			Case "Gold"
				$UpgradeButtonFound = QuickMIS("BC1", $g_sImgWallUpgradeGold, 300, 510, 720, 580)
			Case "Elix"
				$UpgradeButtonFound = QuickMIS("BC1", $g_sImgWallUpgradeElix, 400, 510, 720, 580)
		EndSwitch

		If $UpgradeButtonFound Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(800) Then Return
			For $i = 1 To 10
				SetDebugLog("Waiting for Wall Upgrade Page #" & $i)
				If QuickMis("BC1", $g_sImgGeneralCloseButton, 770, 65, 840, 125) Then ExitLoop
				If _Sleep(50) Then Return
			Next

			If Not $bTest Then
				If _ColorCheck(_GetPixelColor(590, 525, True), Hex(0xE3E3E3, 6), 5) Then ;we got gray button, means upgrade need resource or Higher TH Level
					SetLog("Need More Resource or Higher THLevel", $COLOR_ERROR)
					Click($g_iQuickMISX, $g_iQuickMISY)
					If _Sleep(500) Then Return
					Return False
				EndIf
				Local $CurrentCost = getOcrAndCapture("coc-bonus", 558, 543, 110, 20, True)
				Click(623, 540) ;Final Upgrade Button
				Switch $aIsEnoughResource[1]
					Case "Gold"
						$g_aiCurrentLoot[$eLootGold] -= $CurrentCost
						PushMsg("UpgradeWithGold")
						$g_iNbrOfWallsUppedGold += 1
						$g_iNbrOfWallsUpped += 1
						$g_iCostGoldWall += $CurrentCost
						UpdateStats()
					Case "Elix"
						$g_aiCurrentLoot[$eLootElixir] -= $CurrentCost
						PushMsg("UpgradeWithElixir")
						$g_iNbrOfWallsUppedElixir += 1
						$g_iNbrOfWallsUpped += 1
						$g_iCostElixirWall += $CurrentCost
						UpdateStats()
				EndSwitch
			Else
				SetLog("Testing Only!", $COLOR_ERROR)
				Clickaway("Right")
				If _Sleep(250) Then Return
				Clickaway("Right")
				Return False
			EndIf
			If IsGemOpen(True) Then
				SetLog("Need Gem!", $COLOR_ERROR)
				ClickAway()
				Return False
			Else
				SetLog("Successfully Upgrade a Wall Level " & $WallLevel & " To lvl " & $WallLevel+1, $COLOR_SUCCESS)
			EndIf
		Else
			SetLog("No " & $aIsEnoughResource[1] & " Button Found!", $COLOR_ERROR)
			Return False
		EndIf

		Clickaway("Right")
		Return True
	EndIf
	If Not $g_bRunState Then Return
	If $WallLevel <= $UpgradeToLvl Then
		Local $aWallCost[14] = [1000, 5000, 10000, 20000, 30000, 50000, 75000, 100000, 200000, 500000, 1000000, 3000000, 5000000, 7000000]
		If $WallLevel < 1 Then Return ;prevent further action, Wall level not readed properly
		For $x = $WallLevel To $UpgradeToLvl
			If Not $g_bRunState Then Return
			Local $aIsEnoughResource = WallCheckResource($aWallCost[$x-1], $x)
			If Not $aIsEnoughResource[0] Then Return
			Local $UpgradeButtonFound = False

			Switch $aIsEnoughResource[1]
				Case "Gold"
					For $i = 1 To 10
						SetDebugLog("Waiting Gold Button for Wall Upgrade #" & $i)
						$UpgradeButtonFound = QuickMIS("BC1", $g_sImgWallUpgradeGold, 300, 510, 720, 580)
						If $UpgradeButtonFound Then ExitLoop
						If _Sleep(50) Then Return
					Next
				Case "Elix"
					For $i = 1 To 10
						SetDebugLog("Waiting Elix Button for Wall Upgrade #" & $i)
						$UpgradeButtonFound = QuickMIS("BC1", $g_sImgWallUpgradeElix, 400, 510, 720, 580)
						If $UpgradeButtonFound Then ExitLoop
						If _Sleep(50) Then Return
					Next
			EndSwitch

			If $UpgradeButtonFound Then
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(800) Then Return
				For $i = 1 To 10
					SetDebugLog("Waiting for Wall Upgrade Page #" & $i)
					If QuickMis("BC1", $g_sImgGeneralCloseButton, 770, 65, 840, 125) Then ExitLoop
					If _Sleep(50) Then Return
				Next

				If Not $bTest Then
					If _ColorCheck(_GetPixelColor(590, 525, True), Hex(0xE3E3E3, 6), 5) Then ;we got gray button, means upgrade need resource or Higher TH Level
						SetLog("Need More Resource or Higher THLevel", $COLOR_ERROR)
						Click($g_iQuickMISX, $g_iQuickMISY)
						If _Sleep(500) Then Return
						Return False
					EndIf
					Local $CurrentCost = getOcrAndCapture("coc-bonus", 558, 543, 110, 20, True)
					Click(623, 540) ;Final Upgrade Button
					Switch $aIsEnoughResource[1]
						Case "Gold"
							$g_aiCurrentLoot[$eLootGold] -= $CurrentCost
							PushMsg("UpgradeWithGold")
							$g_iNbrOfWallsUppedGold += 1
							$g_iNbrOfWallsUpped += 1
							$g_iCostGoldWall += $CurrentCost
							UpdateStats()
						Case "Elix"
							$g_aiCurrentLoot[$eLootElixir] -= $CurrentCost
							PushMsg("UpgradeWithElixir")
							$g_iNbrOfWallsUppedElixir += 1
							$g_iNbrOfWallsUpped += 1
							$g_iCostElixirWall += $CurrentCost
							UpdateStats()
					EndSwitch
				Else
					SetLog("Testing Only!", $COLOR_ERROR)
					Clickaway("Right")
					If _Sleep(250) Then Return
					Clickaway("Right")
					Return False
				EndIf
				If IsGemOpen(True) Then
					SetLog("Not Enough Resource...", $COLOR_ERROR)
					Return False
				Else
					SetLog("Successfully Upgrade a Wall Level " & $x & " To lvl " & $x+1, $COLOR_SUCCESS)
				EndIf
			Else
				SetLog("Upgrade Button not Found", $COLOR_ERROR)
				ExitLoop
			EndIf
			If _Sleep(1000) Then Return
		Next
		Clickaway("Right")
		Return True
	EndIf
EndFunc

Func ClickDragFindWallUpgrade($ForceScroll = False)
	Local $x = 420, $yUp = 60, $Delay = 800
	Local $YY = 345
	Local $TmpUpgradeCost = 0, $UpgradeCost = 0, $sameCost = 0, $aWallCoord[0][4], $aTmpWallCoord

	If $ForceScroll And IsBuilderMenuOpen() Then ;check upgrade window border
			SetDebugLog("Upgrade Window Exist", $COLOR_INFO)
			ClickDragAUpgrade()
	EndIf

	For $checkCount = 0 To 9
		If Not $g_bRunState Then Return
		If IsBuilderMenuOpen() Then
			If _Sleep(2000) Then Return
			$aTmpWallCoord = FindWallOnBuilderMenu()
			If IsArray($aTmpWallCoord) And UBound($aTmpWallCoord) > 0 Then
				For $i = 0 To UBound($aTmpWallCoord) - 1
					If StringInStr($aTmpWallCoord[$i][3], "Wall") Then
						_ArrayAdd($aWallCoord, $aTmpWallCoord[$i][1] & "|" & $aTmpWallCoord[$i][2] & "|" & $aTmpWallCoord[$i][5] & "|" & $aTmpWallCoord[$i][0])
					EndIf
				Next
				If UBound($aWallCoord) > 0 Then Return $aWallCoord
			EndIf

			$TmpUpgradeCost = getMostBottomCost()
			SetDebugLog("TmpUpgradeCost = " & $TmpUpgradeCost & " UpgradeCost = " & $UpgradeCost, $COLOR_INFO)
			SetDebugLog("sameCost = " & $sameCost, $COLOR_INFO)
			If $UpgradeCost = $TmpUpgradeCost Then $sameCost += 1
			If $sameCost > 2 Then ExitLoop
			$UpgradeCost = $TmpUpgradeCost
		EndIf
		If _Sleep(1000) Then Return

		If IsBuilderMenuOpen() Then ;check upgrade window border
			SetDebugLog("Upgrade Window Exist", $COLOR_INFO)
			ClickDragAUpgrade()
		Else
			SetDebugLog("Upgrade Window Gone!", $COLOR_DEBUG)
			ClickMainBuilder()
		EndIf
	Next
	Return $aWallCoord
EndFunc ;==>IsUpgradeWindow

Func FindWallOnBuilderMenu()
	Local $aTmpCoord, $aBuilding[0][8], $UpgradeCost, $UpgradeName, $bFoundRusTH = False
	Local $aRushTHPriority[7][2] = [["Castle", 15], ["Pet", 15], ["Laboratory", 15], ["Storage", 14], ["Army", 13], ["Giga", 12], ["Town", 10]]
	Local $aHeroes[4] = ["King", "Queen", "Warden", "Champion"]
	$aTmpCoord = QuickMIS("CNX", $g_sImgResourceIcon, 440, 80, 550, 408)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			If QuickMIS("BC1",$g_sImgAUpgradeObstGear, $aTmpCoord[$i][1] - 250, $aTmpCoord[$i][2] - 10, $aTmpCoord[$i][1], $aTmpCoord[$i][2] + 10) Then ContinueLoop ;skip geared and new
			$UpgradeName = getBuildingName(280, $aTmpCoord[$i][2] - 12) ;get upgrade name and amount
			_ArrayAdd($aBuilding, String($aTmpCoord[$i][0]) & "|" & $aTmpCoord[$i][1] & "|" & Number($aTmpCoord[$i][2]) & "|" & String($UpgradeName[0]) & "|" & Number($UpgradeName[1])) ;compose the array
		Next

		For $j = 0 To UBound($aBuilding) -1
			$UpgradeCost = getOcrAndCapture("coc-buildermenu-cost", $aBuilding[$j][1], $aBuilding[$j][2] - 10, 120, 30, True)
			$aBuilding[$j][5] = Number($UpgradeCost)

			If $aBuilding[$j][5] = "50" Then
				SetDebugLog("Wall " & $j & " is new wall, skip!", $COLOR_INFO)
				ContinueLoop ;skip New Wall
			EndIf

			Local $BuildingName = $aBuilding[$j][3]
			For $k = 0 To UBound($aRushTHPriority) - 1
				If StringInStr($BuildingName, $aRushTHPriority[$k][0]) Then
					Switch $aBuilding[$j][0]
						Case "Gold"
							$aBuilding[$j][6] = $aRushTHPriority[$k][1]
						Case "Elix"
							$aBuilding[$j][6] = $aRushTHPriority[$k][1]
						Case "DE"
							$aBuilding[$j][6] = $aRushTHPriority[$k][1]
					EndSwitch
					$aBuilding[$j][7] = "Priority"
					;If $g_bChkRushTH And ($g_iSaveGoldWall = 0 Or $g_iSaveElixWall = 0) Then setMinSaveWall($aBuilding[$j][0], $aBuilding[$j][5])
					If $g_bChkRushTH Then
						If $aBuilding[$j][0] = "Gold" And StringInStr($aBuilding[$j][3], "Town") Then
							If $g_iTownHallLevel < $g_aiCmbRushTHOption[0] + 9 Then
								setMinSaveWall($aBuilding[$j][0], $aBuilding[$j][5])
							Else
								SetLog("TownHall Level = " & $g_iTownHallLevel & " >= " &$g_aiCmbRushTHOption[0] + 9 & ", should skip this upgrade", $COLOR_ACTION)
							EndIf
						Else
							If ($g_iSaveGoldWall = 0 Or $g_iSaveElixWall = 0) Then setMinSaveWall($aBuilding[$j][0], $aBuilding[$j][5])
						EndIf
					EndIf
				EndIf
			Next
			SetDebugLog("[" & $j & "] Building: " & $BuildingName & ", Cost=" & $UpgradeCost & " Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG)
		Next
	EndIf

	Local $iIndex = _ArraySearch($aBuilding, "0", 0, 0, 0, 0, 0, 5)
	If $iIndex > -1 Then
		SetDebugLog("Failed to read cost, remove!")
		_ArrayDelete($aBuilding, $iIndex)
	EndIf

	_ArraySort($aBuilding, 0, 0, 0, 5) ;sort by cost
	Return $aBuilding
EndFunc

Func setMinSaveWall($Type, $cost)
	Switch $Type
		Case "Gold"
			$g_iSaveGoldWall = $cost
			SetLog("Set Save Gold for RushTH Priority = " & $g_iSaveGoldWall, $COLOR_ACTION)
		Case "Elix"
			$g_iSaveElixWall = $cost
			SetLog("Set Save Elixir for RushTH Priority = " & $g_iSaveElixWall, $COLOR_ACTION)
	EndSwitch
EndFunc

Func UpgradeWallGold($iWallCost = $g_iWallCost, $bTest = False)

	;Check for Gold in right top button corner and click, if present
	Local $FoundGold = decodeSingleCoord(findImage("UpgradeWallGold", $g_sImgUpgradeWallGold, GetDiamondFromRect("200, 505, 670, 532"), 1, True))
	If UBound($FoundGold) > 1 Then
		Click($FoundGold[0], $FoundGold[1])
	Else
		SetLog("No Upgrade Gold Button", $COLOR_ERROR)
		Return False
	EndIf

	If _Sleep($DELAYUPGRADEWALLGOLD2) Then Return

	If WaitforPixel(805, 101, 807, 102, Hex(0xFFFFFF, 6), 6, 2) Then ; wall upgrade window red x
		If Not $bTest Then
			Click(625, 545, 1, 0, "Upgradewall Gold")
		Else
			SetLog("Testing Only!", $COLOR_ERROR)
			Clickaway("Right")
		EndIf
		If _Sleep(1000) Then Return
		If isGemOpen(True) Then
			Clickaway("Right")
			SetLog("Upgrade stopped due no loot", $COLOR_ERROR)
			Return False
		Else
			If _Sleep($DELAYUPGRADEWALLGOLD3) Then Return
			Clickaway("Right")
			SetLog("Upgrade complete", $COLOR_SUCCESS)
			PushMsg("UpgradeWithGold")
			$g_iNbrOfWallsUppedGold += 1
			$g_iNbrOfWallsUpped += 1
			$g_iCostGoldWall += $iWallCost
			UpdateStats()
			Return True
		EndIf
	EndIf
	Clickaway("Right")
EndFunc   ;==>UpgradeWallGold

Func UpgradeWallElixir($iWallCost = $g_iWallCost, $bTest = False)

	;Check for elixircolor in right top button corner and click, if present
	Local $FoundElixir = decodeSingleCoord(findImage("UpgradeWallElixir", $g_sImgUpgradeWallElix, GetDiamondFromRect("200, 505, 670, 532"), 1, True, Default))
	If UBound($FoundElixir) > 1 Then
		Click($FoundElixir[0], $FoundElixir[1])
	Else
		SetLog("No Upgrade Elixir Button", $COLOR_ERROR)
		Return False
	EndIf

	If _Sleep($DELAYUPGRADEWALLELIXIR2) Then Return

	If WaitforPixel(805, 101, 807, 102, Hex(0xFFFFFF, 6), 6, 2) Then ; wall upgrade window red x
		If Not $bTest Then
			Click(625, 545, 1, 0, "UpgradeWall Elixir")
		Else
			SetLog("Testing Only!", $COLOR_ERROR)
			Clickaway("Right")
		EndIf
		If _Sleep(1000) Then Return
		If isGemOpen(True) Then
			SetLog("Upgrade stopped due to insufficient loot", $COLOR_ERROR)
			Return False
		Else
			If _Sleep($DELAYUPGRADEWALLELIXIR3) Then Return
			Clickaway("Right")
			SetLog("Upgrade complete", $COLOR_SUCCESS)
			PushMsg("UpgradeWithElixir")
			$g_iNbrOfWallsUppedElixir += 1
			$g_iNbrOfWallsUpped += 1
			$g_iCostElixirWall += $iWallCost
			UpdateStats()
			Return True
		EndIf
	EndIf
	Clickaway("Right")
EndFunc   ;==>UpgradeWallElixir

Func IsGoldEnough($iWallCost = $g_aUpgradeWall[0])
	If $g_bChkWallOnlyGEFull And Not ($g_WallGEFull = 1 or $g_WallGEFull = 2) Then Return False
	Local $iWallSave = $g_iUpgradeWallMinGold
	If $g_iSaveGoldWall > 0 Then $iWallSave = $g_iSaveGoldWall
	Local $EnoughGold = True
	If ($g_aiCurrentLoot[$eLootGold] - $iWallCost) < $iWallSave Then
		$EnoughGold = False
	EndIf
	If Not $EnoughGold Then
		SetDebugLog("[Insufficient Gold] " & $g_aiCurrentLoot[$eLootGold] & " - " & $iWallCost & " = " & ($g_aiCurrentLoot[$eLootGold] - $iWallCost) & " < " & $iWallSave, $COLOR_INFO)
	EndIf
	Return $EnoughGold
EndFunc

Func IsElixEnough($iWallCost = $g_aUpgradeWall[0])
	If $g_bChkWallOnlyGEFull And Not ($g_WallGEFull = 0 or $g_WallGEFull = 2) Then Return False
	Local $iWallSave = $g_iUpgradeWallMinElixir
	If $g_iSaveElixWall > 0 Then $iWallSave = $g_iSaveElixWall
	Local $EnoughElix = True
	If ($g_aiCurrentLoot[$eLootElixir] - $iWallCost) < $iWallSave Then
		$EnoughElix = False
	EndIf
	If Not $EnoughElix Then
		SetDebugLog("[Insufficient Elixir] " & $g_aiCurrentLoot[$eLootElixir] & " - " & $iWallCost & " = " & ($g_aiCurrentLoot[$eLootElixir] - $iWallCost) & " < " & $iWallSave, $COLOR_INFO)
	EndIf
	Return $EnoughElix
EndFunc

Func NewUpgradeWall()

	ZoomOut()
	Local $bCanUseElix = False, $bCanUseGold = False
	Local $aBtnCoord[4] = [190, 500, 750, 600]
	Local $bRet = True
	
	If $g_bChkRushTH Then
		If $g_iUpgradeWallMinGold < $g_aiTHCost[$g_iTownHallLevel] Then
			SetLog("RushTH Enabled", $COLOR_INFO)
			SetLog("Your TH Level : " & $g_iTownHallLevel, $COLOR_INFO)
			SetLog("You Current MinGoldSave : " & _NumberFormat($g_iUpgradeWallMinGold), $COLOR_INFO)
			SetLog("Adjusting MinGoldSave to : " & _NumberFormat($g_aiTHCost[$g_iTownHallLevel]), $COLOR_INFO)
			$g_iUpgradeWallMinGold = $g_aiTHCost[$g_iTownHallLevel]
			applyConfig()
			saveConfig()
		EndIf
	EndIf
	
	VillageReport(True, True)
	Local $iCanUseGold = $g_aiCurrentLoot[$eLootGold] - $g_iUpgradeWallMinGold
	Local $iCanUseElix = $g_aiCurrentLoot[$eLootElixir] - $g_iUpgradeWallMinElixir
	
	If $iCanUseGold < 1 Then
		SetLog("Skip using Gold, not enough resource", $COLOR_INFO)
	Else
		SetLog("Can use Gold upto : " & _NumberFormat($iCanUseGold), $COLOR_INFO)
		$bCanUseGold = True
	EndIf

	If $iCanUseElix < 1 Then
		SetLog("Skip using Elix, not enough resource", $COLOR_INFO)
	Else
		SetLog("Can use Elix upto : " & _NumberFormat($iCanUseElix), $COLOR_INFO)
		$bCanUseElix = True
	EndIf

	If Not $bCanUseGold And Not $bCanUseElix Then
		SetLog("Both Gold and Elix are low, or not enough to save after upgrade", $COLOR_INFO)
		Return False
	EndIf

	Local $aDel[1] = [0], $x, $y, $bWallFound = False, $aWallLevel, $aButton
	Local $iClickTimesGold = 0, $iClickTimesElix = 0, $iPlus10Gold = 0, $iPlus10Elix = 0, $iPlus1Gold = 0, $iPlus1Elix = 0
	Local $aGoldButton[2], $aElixButton[2], $aPlusButton[2]
	Local $aWall = QuickMIS("CNX", $g_sImgCheckWallDir)
	SetLog("Search Wall on Village", $COLOR_DEBUG)
	If IsArray($aWall) And UBound($aWall) > 0 Then
		For $i = 0 To UBound($aWall) - 1
			If StringInStr($aWall[$i][3], "A") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "A", ""))
			If StringInStr($aWall[$i][3], "B") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "B", ""))
			If StringInStr($aWall[$i][3], "C") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "C", ""))
			If StringInStr($aWall[$i][3], "D") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "D", ""))
		Next
		_ArraySort($aWall, 0, 0, 0, 3) ;short wall level ascending
		SetLog("Found " & UBound($aWall) - 1 & " Wall on Village", $COLOR_DEBUG)
		Local $iWallLevelToDelete = $g_iTownHallLevel
		If $g_iTownHallLevel >= 9 Then $iWallLevelToDelete = $g_iTownHallLevel + 1
		For $i = 0 To UBound($aWall) - 1
			If $aWall[$i][3] >= $iWallLevelToDelete Then _ArrayAdd($aDel, $i) ;wall level >= TH level, should except this
		Next
		$aDel[0] = UBound($aDel) - 1
		;SetLog("Delete " & $aDel[0] & " from wall array", $COLOR_DEBUG)
		_ArrayDelete($aWall, $aDel) ;delete wall level which same or higher than TH level
		_ArraySort($aWall, 1, 0, 0, 3) ;short wall level ascending
		;_ArrayDisplay($aWall)
		SetLog("Your TownHall Level: " & $g_iTownHallLevel & ", Exluding Wall Level >= " & $iWallLevelToDelete, $COLOR_INFO)
		SetLog("Found " & UBound($aWall) - 1 & " records", $COLOR_DEBUG)

		For $i = 0 To UBound($aWall) - 1
			If _Sleep(50) Then Return
			$x = $aWall[$i][1]
			$y = $aWall[$i][2]
			If isInsideDiamondXY($x, $y) Then ;prevent click outside village
				SetLog("Verify Wall, click wall on " & $x & "," & $y, $COLOR_DEBUG)
				Click($x, $y)
				If _Sleep(1000) Then Return
				$aWallLevel = BuildingInfo(242, 477)
				If $aWallLevel[1] = "Wall" And $aWallLevel[2] < $iWallLevelToDelete Then
					$bWallFound = True
					ExitLoop
				EndIf
			EndIf
			SetDebugLog("Wrong wall detected, coord outside diamond:" & $x & "," & $y, $COLOR_DEBUG)
		Next
		
		If Not $bWallFound Then Return
		
		If $bWallFound Then
			SetLog("Wall Level : " & $aWallLevel[2], $COLOR_SUCCESS)
			SetLog("Wall Cost  : " & _NumberFormat($g_aiWallCost[$aWallLevel[2]]), $COLOR_SUCCESS)
			SetLog("Min Gold Save : " & _NumberFormat($g_iUpgradeWallMinGold), $COLOR_INFO)
			SetLog("Min Elix Save : " & _NumberFormat($g_iUpgradeWallMinElixir), $COLOR_INFO)
			
			Local $bPlusSignFound = False
			$aButton = QuickMIS("CNX", $g_sImgCheckWallDirUpgradeButton, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3])
			If IsArray($aButton) And UBound($aButton) > 0 Then
				For $i = 0 To UBound($aButton) - 1
					Select
						Case $aButton[$i][0] = "PlusSign"
							$aPlusButton[0] = $aButton[$i][1]
							$aPlusButton[1] = $aButton[$i][2]
							$bPlusSignFound = True
							SetLog("Found Plus Button on " & _ArrayToString($aPlusButton), $COLOR_DEBUG)
						Case $aButton[$i][0] = "Gold"
							$aGoldButton[0] = $aButton[$i][1] - 25
							$aGoldButton[1] = $aButton[$i][2] + 25
							SetLog("Found Gold Button on " & _ArrayToString($aGoldButton), $COLOR_DEBUG)
						Case $aButton[$i][0] = "Elix"
							$aElixButton[0] = $aButton[$i][1] - 25
							$aElixButton[1] = $aButton[$i][2] + 25
							SetLog("Found Elix Button on " & _ArrayToString($aElixButton), $COLOR_DEBUG)
					EndSelect
				Next
				$bCanUseElix = False
				For $i = 0 To UBound($aButton) - 1
					If $aButton[$i][0] = "Elix" Then $bCanUseElix = True
				Next
			EndIf
			
			Local $iWallCanUpgradeGold = $bCanUseGold ? Floor(($iCanUseGold - $g_aiWallCost[$aWallLevel[2]]) / $g_aiWallCost[$aWallLevel[2]]) : 0
			Local $iWallCanUpgradeElix = $bCanUseElix ? Floor(($iCanUseElix - $g_aiWallCost[$aWallLevel[2]]) / $g_aiWallCost[$aWallLevel[2]]) : 0
			If $iWallCanUpgradeGold < 0 Then $bCanUseGold = False
			If $iWallCanUpgradeElix < 0 Then $bCanUseElix = False
			SetLog("CanUseGold = " & String($bCanUseGold), $COLOR_DEBUG)
			SetLog("CanUseElix = " & String($bCanUseElix), $COLOR_DEBUG)
			If $bCanUseGold Then SetLog("Can upgrade = " & $iWallCanUpgradeGold & " wall Level " & $aWallLevel[2] & " with Gold", $COLOR_INFO)
			If $bCanUseElix Then SetLog("Can upgrade = " & $iWallCanUpgradeElix & " wall Level " & $aWallLevel[2] & " with Elix", $COLOR_INFO)
			
			If $bCanUseGold Or $bCanUseElix Then
				If ($iWallCanUpgradeGold > 1 Or $iWallCanUpgradeElix > 1) And $bPlusSignFound Then
					SetLog("Trying Upgrade 10+ Wall", $COLOR_ACTION)
					ClickP($aPlusButton)
					If _Sleep(1000) Then Return
					
					Switch $g_iUpgradeWallLootType
						Case 0 ;Gold
							If $bCanUseGold Then
								$iClickTimesGold = $iWallCanUpgradeGold / 10 ; can we upgrade 10+ for gold
								$iPlus10Gold = Floor($iClickTimesGold)
								$iPlus1Gold = $iWallCanUpgradeGold
							EndIf
						Case 1 ;Elixir
							If $bCanUseElix Then
								$iClickTimesElix = $iWallCanUpgradeElix / 10 ; can we upgrade 10+ for elix
								$iPlus10Elix = Floor($iClickTimesElix)
								$iPlus1Elix = $iWallCanUpgradeElix
							EndIf
						Case 2 ;Elixir Then Gold
							If $bCanUseElix Then 
								$iClickTimesElix = $iWallCanUpgradeElix / 10 ; can we upgrade 10+ for gold
								$iPlus10Elix = Floor($iClickTimesElix)
								$iPlus1Elix = $iWallCanUpgradeElix
							EndIf
							If $bCanUseGold Then 
								$iClickTimesGold = $iWallCanUpgradeGold / 10 ; can we upgrade 10+ for elix
								$iPlus10Gold = Floor($iClickTimesGold)
								$iPlus1Gold = $iWallCanUpgradeGold
							EndIf
					EndSwitch
					
					SetDebugLog("Plus10Gold : " & $iPlus10Gold & ", Plus10Elix : " & $iPlus10Elix, $COLOR_DEBUG)
					SetDebugLog("Plus1Gold : " & $iPlus1Gold & ", Plus1Elix : " & $iPlus1Elix, $COLOR_DEBUG)
					
					$aButton = QuickMIS("CNX", $g_sImgCheckWallDirUpgradeButton, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3])
					If IsArray($aButton) And UBound($aButton) > 0 Then
						For $i = 0 To UBound($aButton) - 1
							Select
								Case $aButton[$i][0] = "Gold"
									$aGoldButton[0] = $aButton[$i][1] - 25
									$aGoldButton[1] = $aButton[$i][2] + 25
									SetLog("Found Gold Button on " & _ArrayToString($aGoldButton), $COLOR_DEBUG)
								Case $aButton[$i][0] = "Elix"
									$aElixButton[0] = $aButton[$i][1] - 25
									$aElixButton[1] = $aButton[$i][2] + 25
									SetLog("Found Elix Button on " & _ArrayToString($aElixButton), $COLOR_DEBUG)
							EndSelect
						Next
					EndIf
					
					Local $iCountWallUpgrade = 1, $bPlusButtonFound = False
					If $iPlus10Gold > 0 Or $iPlus10Elix > 0 Then
						SetLog("Looking for +10 Button", $COLOR_DEBUG)
						Switch $g_iUpgradeWallLootType
							Case 0 ;Gold
								For $i = 1 To $iPlus10Gold
									If QuickMIS("BC1", $g_sImgCheckWallDirUpgradeButton & "\Plus10") Then
										Click($g_iQuickMISX, $g_iQuickMISY, 1, 500, "Click +10")
										If _Sleep(500) Then Return
										$iCountWallUpgrade += 1
										$bPlusButtonFound = True
									Else
										SetLog("No +10 Button Found", $COLOR_DEBUG)
										If _Sleep(500) Then Return
										ExitLoop
									EndIf
								Next
								;click Upgrade button
								If $bPlusButtonFound Then 
									ClickP($aGoldButton)
									PushMsg("UpgradeWithGold")
									$g_iNbrOfWallsUppedElixir += 10 * $iCountWallUpgrade
									$g_iNbrOfWallsUpped += 10 * $iCountWallUpgrade
									$g_iCostGoldWall += 10 * $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
									SetLog("Upgraded wall with Gold: " & $g_iNbrOfWallsUpped, $COLOR_SUCCESS)
									SetLog("Cost : " & _NumberFormat($g_iCostGoldWall), $COLOR_SUCCESS)
								EndIf
							Case 1 ;Elixir
								SetLog("Try +10 for Elix upgrade", $COLOR_ACTION)
								For $i = 1 To $iPlus10Gold
									If QuickMIS("BC1", $g_sImgCheckWallDirUpgradeButton & "\Plus10") Then
										Click($g_iQuickMISX, $g_iQuickMISY, 1, 500, "Click +10")
										If _Sleep(500) Then Return
										$iCountWallUpgrade += 1
										$bPlusButtonFound = True
									Else
										SetLog("No +10 Button Found", $COLOR_DEBUG)
										If _Sleep(500) Then Return
										ExitLoop
									EndIf
								Next
								;click Upgrade button
								If $bPlusButtonFound Then 
									ClickP($aElixButton)
									PushMsg("UpgradeWithElixir")
									$g_iNbrOfWallsUppedGold += 10 * $iCountWallUpgrade
									$g_iNbrOfWallsUpped += 10 * $iCountWallUpgrade
									$g_iCostGoldWall += 10 * $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
									SetLog("Upgraded wall with Elix: " & $g_iNbrOfWallsUpped, $COLOR_SUCCESS)
									SetLog("Cost : " & _NumberFormat($g_iCostElixirWall), $COLOR_SUCCESS)
								EndIf
							Case 2 ;Elixir Then Gold
								If $bCanUseElix = True And $iPlus10Elix > 0 Then
									SetLog("Try +10 for Elix upgrade", $COLOR_ACTION)
									For $i = 1 To $iPlus10Elix
										If QuickMIS("BC1", $g_sImgCheckWallDirUpgradeButton & "\Plus10") Then
											Click($g_iQuickMISX, $g_iQuickMISY, 1, 500, "Click +10")
											If _Sleep(500) Then Return
											$iCountWallUpgrade += 1
											$bPlusButtonFound = True
										Else
											SetLog("No +10 Button Found", $COLOR_DEBUG)
											If _Sleep(500) Then Return
											ExitLoop
										EndIf
									Next
									;click Upgrade button
									If $bPlusButtonFound Then 
										ClickP($aElixButton)
										PushMsg("UpgradeWithElixir")
										$g_iNbrOfWallsUppedElixir += 10 * $iCountWallUpgrade
										$g_iNbrOfWallsUpped += 10 * $iCountWallUpgrade
										$g_iCostElixirWall += 10 * $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
										SetLog("Upgraded wall with Elix: " & $g_iNbrOfWallsUpped, $COLOR_SUCCESS)
										SetLog("Cost : " & _NumberFormat($g_iCostElixirWall), $COLOR_SUCCESS)
										$bCanUseGold = False ;already upgrade with elixir let restart count resource 
									EndIf
								ElseIf $bCanUseGold = True And $iPlus10Gold > 0 Then
									SetLog("Try +10 for Gold upgrade", $COLOR_ACTION)
									For $i = 1 To $iPlus10Gold
										If QuickMIS("BC1", $g_sImgCheckWallDirUpgradeButton & "\Plus10") Then
											Click($g_iQuickMISX, $g_iQuickMISY, 1, 500, "Click +10")
											If _Sleep(500) Then Return
											$iCountWallUpgrade += 1
											$bPlusButtonFound = True
										Else
											SetLog("No +10 Button Found", $COLOR_DEBUG)
											If _Sleep(500) Then Return
											ExitLoop
										EndIf
									Next
									;click Upgrade button
									If $bPlusButtonFound Then 
										ClickP($aGoldButton)
										PushMsg("UpgradeWithGold")
										$g_iNbrOfWallsUppedElixir += 10 * $iCountWallUpgrade
										$g_iNbrOfWallsUpped += 10 * $iCountWallUpgrade
										$g_iCostGoldWall += 10 * $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
										SetLog("Upgraded wall with Gold: " & $g_iNbrOfWallsUpped, $COLOR_SUCCESS)
										SetLog("Cost : " & _NumberFormat($g_iCostGoldWall), $COLOR_SUCCESS)
									EndIf
								EndIf
						EndSwitch
						If _Sleep(1000) Then Return
						If $bPlusButtonFound Then 
							If isOKCancelPage() Then ClickP($aConfirmSurrender) ;click confirm upgrade OK button
							UpdateStats()
							Return $bRet
						EndIf
					EndIf
					
					If $iPlus1Gold > 0 Or $iPlus1Elix > 0 Then
						SetLog("Looking for +1 Button", $COLOR_DEBUG)
						Switch $g_iUpgradeWallLootType
							Case 0 ;Gold
								SetLog("Try +1 for Gold upgrade", $COLOR_ACTION)
								For $i = 1 To $iPlus1Gold
									If QuickMIS("BC1", $g_sImgCheckWallDirUpgradeButton & "\Plus1") Then
										Click($g_iQuickMISX, $g_iQuickMISY, 1, 500, "Click +1")
										If _Sleep(500) Then Return
										$iCountWallUpgrade += 1
										$bPlusButtonFound = True
									Else
										SetLog("No +1 Button Found", $COLOR_DEBUG)
										If _Sleep(500) Then Return
										ExitLoop
									EndIf
								Next
								;click Upgrade button
								If $bPlusButtonFound Then 
									ClickP($aGoldButton)
									PushMsg("UpgradeWithGold")
									$g_iNbrOfWallsUppedGold += $iCountWallUpgrade
									$g_iNbrOfWallsUpped += $iCountWallUpgrade
									$g_iCostGoldWall += $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
									SetLog("Upgraded wall with Gold: " & $iCountWallUpgrade, $COLOR_SUCCESS)
									SetLog("Cost : " & _NumberFormat($g_iCostGoldWall), $COLOR_SUCCESS)
								EndIf
							Case 1 ;Elix
								SetLog("Try +1 for Elix upgrade", $COLOR_ACTION)
								For $i = 1 To $iPlus1Elix
									If QuickMIS("BC1", $g_sImgCheckWallDirUpgradeButton & "\Plus1") Then
										Click($g_iQuickMISX, $g_iQuickMISY, 1, 500, "Click +1")
										If _Sleep(500) Then Return
										$iCountWallUpgrade += 1
										$bPlusButtonFound = True
									Else
										SetLog("No +1 Button Found", $COLOR_DEBUG)
										If _Sleep(500) Then Return
										ExitLoop
									EndIf
								Next
								;click Upgrade button
								If $bPlusButtonFound Then 
									ClickP($aElixButton)
									PushMsg("UpgradeWithElixir")
									$g_iNbrOfWallsUppedElixir += $iCountWallUpgrade
									$g_iNbrOfWallsUpped += $iCountWallUpgrade
									$g_iCostElixirWall += $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
									SetLog("Upgraded wall with Elixir: " & $iCountWallUpgrade, $COLOR_SUCCESS)
									SetLog("Cost : " & _NumberFormat($g_iCostElixirWall), $COLOR_SUCCESS)
								EndIf
							Case 2 ;Elix Then Gold
								If $bCanUseElix = True And $iPlus1Elix > 0 Then
									SetLog("Try +1 for Elix upgrade", $COLOR_ACTION)
									For $i = 1 To $iPlus1Elix
										If QuickMIS("BC1", $g_sImgCheckWallDirUpgradeButton & "\Plus1") Then
											Click($g_iQuickMISX, $g_iQuickMISY, 1, 500, "Click +1")
											If _Sleep(500) Then Return
											$iCountWallUpgrade += 1
											$bPlusButtonFound = True
										Else
											SetLog("No +1 Button Found", $COLOR_DEBUG)
											If _Sleep(500) Then Return
											ExitLoop
										EndIf
									Next
									;click Upgrade button
									If $bPlusButtonFound Then 
										ClickP($aElixButton)
										PushMsg("UpgradeWithElixir")
										$g_iNbrOfWallsUppedElixir += $iCountWallUpgrade
										$g_iNbrOfWallsUpped += $iCountWallUpgrade
										$g_iCostElixirWall += $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
										SetLog("Upgraded wall with Elixir: " & $iCountWallUpgrade, $COLOR_SUCCESS)
										SetLog("Cost : " & _NumberFormat($g_iCostElixirWall), $COLOR_SUCCESS)
										$bCanUseGold = False ;already upgrade with elixir let restart count resource 
									EndIf
								ElseIf $bCanUseGold = True And $iPlus1Gold > 0 Then
									SetLog("Try +1 for Gold upgrade", $COLOR_ACTION)
									For $i = 1 To $iPlus1Gold
										If QuickMIS("BC1", $g_sImgCheckWallDirUpgradeButton & "\Plus1") Then
											Click($g_iQuickMISX, $g_iQuickMISY, 1, 500, "Click +1")
											If _Sleep(500) Then Return
											$iCountWallUpgrade += 1
											$bPlusButtonFound = True
										Else
											SetLog("No +1 Button Found", $COLOR_DEBUG)
											If _Sleep(1000) Then Return
											ExitLoop
										EndIf
									Next
									;click Upgrade button
									If $bPlusButtonFound Then 
										ClickP($aGoldButton)
										PushMsg("UpgradeWithGold")
										$g_iNbrOfWallsUppedGold += $iCountWallUpgrade
										$g_iNbrOfWallsUpped += $iCountWallUpgrade
										$g_iCostGoldWall += $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
										SetLog("Upgraded wall with Gold: " & $iCountWallUpgrade, $COLOR_SUCCESS)
										SetLog("Cost : " & _NumberFormat($g_iCostGoldWall), $COLOR_SUCCESS)
									EndIf
								EndIf
						EndSwitch
						If _Sleep(1000) Then Return
						If $bPlusButtonFound Then 
							If isOKCancelPage() Then ClickP($aConfirmSurrender) ;click confirm upgrade OK button
							UpdateStats()
							Return $bRet
						EndIf
					EndIf
				Else
					SetLog("Going to Upgrade 1 Wall", $COLOR_DEBUG)
					Switch $g_iUpgradeWallLootType
						Case 0 ;Gold
							SetLog("Upgrading 1 Wall for Gold upgrade", $COLOR_ACTION)
							ClickP($aGoldButton)
							PushMsg("UpgradeWithGold")
							$g_iNbrOfWallsUppedGold += 1
							$g_iNbrOfWallsUpped += 1
							$g_iCostGoldWall += $g_aiWallCost[$aWallLevel[2]]
						Case 1
							SetLog("Upgrading 1 Wall for Elix upgrade", $COLOR_ACTION)
							ClickP($aElixButton)
							PushMsg("UpgradeWithElixir")
							$g_iNbrOfWallsUppedElixir += 1
							$g_iNbrOfWallsUpped += 1
							$g_iCostElixirWall += $g_aiWallCost[$aWallLevel[2]]
						Case 2
							Select 
								Case $bCanUseElix = True And $iWallCanUpgradeElix > 0
									SetLog("Upgrading 1 Wall for Elix upgrade", $COLOR_ACTION)
									ClickP($aElixButton)
									PushMsg("UpgradeWithElixir")
									$g_iNbrOfWallsUppedElixir += 1
									$g_iNbrOfWallsUpped += 1
									$g_iCostElixirWall += $g_aiWallCost[$aWallLevel[2]]
									$bCanUseGold = False
								Case $bCanUseGold = True And $iWallCanUpgradeGold > 0
									SetLog("Upgrading 1 Wall for Gold upgrade", $COLOR_ACTION)
									ClickP($aGoldButton)
									PushMsg("UpgradeWithGold")
									$g_iNbrOfWallsUppedGold += 1
									$g_iNbrOfWallsUpped += 1
									$g_iCostGoldWall += $g_aiWallCost[$aWallLevel[2]]
							EndSelect
					EndSwitch
					If _Sleep(1000) Then Return
					If WaitforPixel(805, 101, 807, 102, Hex(0xFFFFFF, 6), 6, 2) Then
						Click(625, 545, 1, 500, "UpgradeWall")
						ClickAway()
					EndIf
					UpdateStats()
					Return $bRet
				EndIf
			EndIf
		Else
			SetLog("Not a wall, looking next wall", $COLOR_DEBUG)
			ClickAway()
		EndIf
	EndIf
EndFunc

#cs
Func GoUpgradeWall($sType = "Single", $iPlusCount = 1)
	Local $aBtnCoord[4] = [190, 500, 750, 600], $aButton, $aGoldButton[2], $aElixButton[2]
	Local $sImage = $g_sImgCheckWallDirUpgradeButton & "\" & $sType
	Local $iCountWallUpgrade = 0, $bPlusButtonFound = False
	
	$aButton = QuickMIS("CNX", $g_sImgCheckWallDirUpgradeButton, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3])
	If IsArray($aButton) And UBound($aButton) > 0 Then
		For $i = 0 To UBound($aButton) - 1
			Select
				Case $aButton[$i][0] = "Gold"
					$aGoldButton[0] = $aButton[$i][1] - 25
					$aGoldButton[1] = $aButton[$i][2] + 25
					SetLog("Found Gold Button on " & _ArrayToString($aGoldButton), $COLOR_DEBUG)
				Case $aButton[$i][0] = "Elix"
					$aElixButton[0] = $aButton[$i][1] - 25
					$aElixButton[1] = $aButton[$i][2] + 25
					SetLog("Found Elix Button on " & _ArrayToString($aElixButton), $COLOR_DEBUG)
			EndSelect
		Next
	EndIf
	
	Switch $g_iUpgradeWallLootType
		Case 0 ;Gold
			SetLog("Try " & $sType & ", for Gold upgrade", $COLOR_ACTION)
			For $i = 1 To $iPlusCount
				If QuickMIS("BC1", $sImage, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3]) Then
					Click($g_iQuickMISX, $g_iQuickMISY, 1, 100, $sType)
					If _Sleep(1000) Then Return
					$iCountWallUpgrade += 1
					$bPlusButtonFound = True
				Else
					SetLog("No +1 Button Found", $COLOR_DEBUG)
					If _Sleep(1000) Then Return
					ExitLoop
				EndIf
			Next
			;click Upgrade button
			If $bPlusButtonFound Then 
				ClickP($aGoldButton)
				PushMsg("UpgradeWithGold")
				SetLog("Upgraded wall with Gold: " & $iCountWallUpgrade, $COLOR_SUCCESS)
				$g_iNbrOfWallsUppedGold += $iCountWallUpgrade
				$g_iNbrOfWallsUpped += $iCountWallUpgrade
				$g_iCostGoldWall += $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
			EndIf
		Case 1 ;Elix
			SetLog("Try " & $sType & ", for Gold upgrade", $COLOR_ACTION)
			For $i = 1 To $iPlusCount
				If QuickMIS("BC1", $sImage, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3]) Then
					Click($g_iQuickMISX, $g_iQuickMISY, 1, 100, $sType)
					If _Sleep(1000) Then Return
					$iCountWallUpgrade += 1
					$bPlusButtonFound = True
				Else
					SetLog("No +1 Button Found", $COLOR_DEBUG)
					If _Sleep(1000) Then Return
					ExitLoop
				EndIf
			Next
			;click Upgrade button
			If $bPlusButtonFound Then 
				ClickP($aElixButton)
				PushMsg("UpgradeWithElixir")
				SetLog("Upgraded wall with Elixir: " & $iCountWallUpgrade, $COLOR_SUCCESS)
				$g_iNbrOfWallsUppedElixir += $iCountWallUpgrade
				$g_iNbrOfWallsUpped += $iCountWallUpgrade
				$g_iCostElixirWall += $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
			EndIf
		Case 2 ;Elix Then Gold
			Select 
				Case $bCanUseElix = True And $iPlus1Elix > 0
					SetLog("Try " & $sType & ", for Gold upgrade", $COLOR_ACTION)
					For $i = 1 To $iPlusCount
						If QuickMIS("BC1", $sImage, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3]) Then
							Click($g_iQuickMISX, $g_iQuickMISY, 1, 100, $sType)
							If _Sleep(1000) Then Return
							$iCountWallUpgrade += 1
							$bPlusButtonFound = True
						Else
							SetLog("No +1 Button Found", $COLOR_DEBUG)
							If _Sleep(1000) Then Return
							ExitLoop
						EndIf
					Next
					;click Upgrade button
					If $bPlusButtonFound Then 
						ClickP($aElixButton)
						PushMsg("UpgradeWithElixir")
						SetLog("Upgraded wall with Elixir: " & $iCountWallUpgrade, $COLOR_SUCCESS)
						$g_iNbrOfWallsUppedElixir += $iCountWallUpgrade
						$g_iNbrOfWallsUpped += $iCountWallUpgrade
						$g_iCostElixirWall += $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
					EndIf
				Case $bCanUseGold = True And $iPlus1Gold > 0
					SetLog("Try " & $sType & ", for Gold upgrade", $COLOR_ACTION)
					For $i = 1 To $iPlusCount
						If QuickMIS("BC1", $sImage, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3]) Then
							Click($g_iQuickMISX, $g_iQuickMISY, 1, 100, $sType)
							If _Sleep(1000) Then Return
							$iCountWallUpgrade += 1
							$bPlusButtonFound = True
						Else
							SetLog("No +1 Button Found", $COLOR_DEBUG)
							If _Sleep(1000) Then Return
							ExitLoop
						EndIf
					Next
					;click Upgrade button
					If $bPlusButtonFound Then 
						ClickP($aGoldButton)
						PushMsg("UpgradeWithGold")
						SetLog("Upgraded wall with Gold: " & $iCountWallUpgrade, $COLOR_SUCCESS)
						$g_iNbrOfWallsUppedGold += $iCountWallUpgrade
						$g_iNbrOfWallsUpped += $iCountWallUpgrade
						$g_iCostGoldWall += $iCountWallUpgrade * $g_aiWallCost[$aWallLevel[2]]
					EndIf
			EndSelect
	EndSwitch
	
	;If QuickMIS("BC1", $g_sImgCheckWallDirUpgradeButton & "\Plus10") Then
EndFunc
#ce

