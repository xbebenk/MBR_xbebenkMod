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
	Local $GoUpgrade = False
	
	SetLog("Checking Upgrade Walls", $COLOR_INFO)
	checkMainScreen(True, $g_bStayOnBuilderBase, "UpgradeWall")
	VillageReport(True, True) ;update village resource capacity
	If Not WallUpgradeCheckBuilder() And Not $bTest Then
		SetLog("No builder available, Upgrade Walls skipped", $COLOR_DEBUG2)
		Return
	EndIf
	If $g_iFreeBuilderCount > 0 Then $GoUpgrade = True
	If $g_bChkOnly1Builder And $g_iFreeBuilderCount > 1 And Not $bTest Then
		SetLog("Have more than 1 builder, Upgrade Walls skipped", $COLOR_DEBUG2)
		Return
	EndIf
	If _Sleep(50) Then Return

	If $GoUpgrade Then 
		Local $iLoop = 1
		If $g_iUpgradeWallLootType = 2 Then $iLoop = 2
		For $i = 1 To $iLoop
			SetDebugLog("$iLoop = " & $i & "/" & $iLoop)
			DoUpgradeWall()
		Next
	EndIf
	
	VillageReport(True, True)
	CheckMainScreen(False, $g_bStayOnBuilderBase, "UpgradeWall")
EndFunc   ;==>UpgradeWall

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


Func DoUpgradeWall()
	If Not $g_bRunState Then Return
	Local $bCanUseElix = False, $bCanUseGold = False
	Local $aBtnCoord[4] = [150, 500, 750, 600]
	Local $bRet = True

	If $g_bChkRushTH And $g_bAutoAdjustSaveWall Then
		SetLog("RushTH Enabled", $COLOR_ACTION)
		If $g_iUpgradeWallMinGold < $g_aiTHCost[$g_iTownHallLevel] And Not IsTHLevelAchieved() Then
			SetLog("Your TH Level : " & $g_iTownHallLevel, $COLOR_INFO)
			SetLog("You Current MinGoldSave : " & _NumberFormat($g_iUpgradeWallMinGold), $COLOR_INFO)
			SetLog("Adjusting MinGoldSave to : " & _NumberFormat($g_aiTHCost[$g_iTownHallLevel]), $COLOR_SUCCESS)
			$g_iUpgradeWallMinGold = $g_aiTHCost[$g_iTownHallLevel]
			applyConfig()
			saveConfig()
		EndIf
		If $g_iTownHallLevel >= 7 Then
			If $g_iUpgradeWallMinElixir < $g_aiHeroHallCost[$g_iTownHallLevel - 7] And Not IsTHLevelAchieved() Then
				SetLog("Your TH Level : " & $g_iTownHallLevel, $COLOR_INFO)
				SetLog("You Current MinElixirSave : " & _NumberFormat($g_iUpgradeWallMinElixir), $COLOR_INFO)
				SetLog("Adjusting MinElixirSave to : " & _NumberFormat($g_aiHeroHallCost[$g_iTownHallLevel - 7]), $COLOR_SUCCESS)
				$g_iUpgradeWallMinElixir = $g_aiHeroHallCost[$g_iTownHallLevel - 7]
				applyConfig()
				saveConfig()
			EndIf
		EndIf
		If IsTHLevelAchieved() Then 
			SetLog("Your TH Level : " & $g_iTownHallLevel, $COLOR_INFO)
			SetLog("Adjusting MinGoldSave to : " & _NumberFormat($g_aiTHCost[$g_iTownHallLevel]/2), $COLOR_SUCCESS)
			SetLog("Adjusting MinElixirSave to : " & _NumberFormat($g_aiHeroHallCost[$g_iTownHallLevel - 7]/2), $COLOR_SUCCESS)
			$g_iUpgradeWallMinGold = $g_aiTHCost[$g_iTownHallLevel]/2
			$g_iUpgradeWallMinElixir = $g_aiHeroHallCost[$g_iTownHallLevel - 7]/2
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
		SetDebugLog("Can use Gold upto : " & _NumberFormat($iCanUseGold), $COLOR_INFO)
		$bCanUseGold = True
	EndIf

	If $iCanUseElix < 1 Then
		SetLog("Skip using Elix, not enough resource", $COLOR_INFO)
	Else
		SetDebugLog("Can use Elix upto : " & _NumberFormat($iCanUseElix), $COLOR_INFO)
		$bCanUseElix = True
	EndIf

	If Not $bCanUseGold And Not $bCanUseElix Then
		SetLog("Both Gold and Elix are low, or not enough to save after upgrade", $COLOR_INFO)
		Return False
	EndIf

	Local $aDel[1] = [0], $x, $y, $bWallFound = False, $aWallLevel, $aButton
	Local $iClickTimesGold = 0, $iClickTimesElix = 0, $iPlus10Gold = 0, $iPlus10Elix = 0, $iPlus1Gold = 0, $iPlus1Elix = 0
	Local $aGoldButton[2], $aElixButton[2], $aPlusButton[2]

	$bWallFound = SearchWall($aWallLevel)
	If Not $bWallFound Then Return
	If _Sleep(50) Then Return

	If $bWallFound Then
		Local $bPlusSignFound = False
		$aButton = QuickMIS("CNX", $g_sImgCheckWallDirUpgradeButton, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3])
		If IsArray($aButton) And UBound($aButton) > 0 Then
			For $i = 0 To UBound($aButton) - 1
				Select
					Case $aButton[$i][0] = "PlusSign"
						$aPlusButton[0] = $aButton[$i][1]
						$aPlusButton[1] = $aButton[$i][2]
						$bPlusSignFound = True
						SetDebugLog("Found Plus Button on " & _ArrayToString($aPlusButton), $COLOR_DEBUG)
					Case $aButton[$i][0] = "Gold"
						$aGoldButton[0] = $aButton[$i][1] - 25
						$aGoldButton[1] = $aButton[$i][2] + 25
						SetDebugLog("Found Gold Button on " & _ArrayToString($aGoldButton), $COLOR_DEBUG)
					Case $aButton[$i][0] = "Elix"
						$aElixButton[0] = $aButton[$i][1] - 25
						$aElixButton[1] = $aButton[$i][2] + 25
						SetDebugLog("Found Elix Button on " & _ArrayToString($aElixButton), $COLOR_DEBUG)
				EndSelect
			Next
			$bCanUseElix = False
			For $i = 0 To UBound($aButton) - 1
				If $aButton[$i][0] = "Elix" Then $bCanUseElix = True
			Next
		EndIf

		If _Sleep(50) Then Return
		Local $iWallCost = $g_aiWallCost[$aWallLevel[2]]
		Local $iWallCanUpgradeGold = ($bCanUseGold ? Floor($iCanUseGold / $iWallCost) : 0)
		Local $iWallCanUpgradeElix = ($bCanUseElix ? Floor($iCanUseElix/ $iWallCost) : 0)
		SetDebugLog("iWallCanUpgradeGold: " & $iWallCanUpgradeGold & ", iWallCanUpgradeElix : " & $iWallCanUpgradeElix)
		If $iWallCanUpgradeGold < 0 Then $bCanUseGold = False
		If $iWallCanUpgradeElix < 0 Then $bCanUseElix = False
		SetLog("CanUseGold = " & String($bCanUseGold), $COLOR_DEBUG)
		SetLog("CanUseElix = " & String($bCanUseElix), $COLOR_DEBUG)
		If $bCanUseGold Then SetLog("Can upgrade = " & $iWallCanUpgradeGold & " wall Level " & $aWallLevel[2] & " with Gold", $COLOR_INFO)
		If $bCanUseElix Then SetLog("Can upgrade = " & $iWallCanUpgradeElix & " wall Level " & $aWallLevel[2] & " with Elix", $COLOR_INFO)
		
		If Not $bCanUseGold And $g_iUpgradeWallLootType = 0 Then 
			SetLog("Cannot use Gold for upgrade wall", $COLOR_DEBUG2)
			ClickAway()
			Return False
		ElseIf Not $bCanUseElix And $g_iUpgradeWallLootType = 1 Then 
			SetLog("Cannot use Elix for upgrade wall", $COLOR_DEBUG2)
			ClickAway()
			Return False
		ElseIf $iWallCanUpgradeGold < 1 And $iWallCanUpgradeElix < 1 Then
			SetLog("Cannot upgrade wall, not enough resource", $COLOR_DEBUG2)
			ClickAway()
			Return False
		EndIf
		
		If $bCanUseGold Or $bCanUseElix Then
			If ($iWallCanUpgradeGold > 1 Or $iWallCanUpgradeElix > 1) And $bPlusSignFound Then
				SetLog("Trying Upgrade More Wall", $COLOR_ACTION)
				ClickP($aPlusButton)
				If _Sleep(1000) Then Return

				If $bCanUseGold Then
					$iClickTimesGold = $iWallCanUpgradeGold / 10 ; can we upgrade 10+ for gold
					$iPlus10Gold = Floor($iClickTimesGold)
					$iPlus1Gold = $iWallCanUpgradeGold
				EndIf
				If $bCanUseElix Then
					$iClickTimesElix = $iWallCanUpgradeElix / 10 ; can we upgrade 10+ for elix
					$iPlus10Elix = Floor($iClickTimesElix)
					$iPlus1Elix = $iWallCanUpgradeElix
				EndIf

				SetDebugLog("Plus10Gold : " & $iPlus10Gold & ", Plus10Elix : " & $iPlus10Elix, $COLOR_DEBUG)
				SetDebugLog("Plus1Gold : " & $iPlus1Gold & ", Plus1Elix : " & $iPlus1Elix, $COLOR_DEBUG)

				$aButton = QuickMIS("CNX", $g_sImgCheckWallDirUpgradeButton, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3])
				If IsArray($aButton) And UBound($aButton) > 0 Then
					For $i = 0 To UBound($aButton) - 1
						Select
							Case $aButton[$i][0] = "Gold"
								$aGoldButton[0] = $aButton[$i][1] - 25
								$aGoldButton[1] = $aButton[$i][2] + 25
								SetDebugLog("Found Gold Button on " & _ArrayToString($aGoldButton), $COLOR_DEBUG)
							Case $aButton[$i][0] = "Elix"
								$aElixButton[0] = $aButton[$i][1] - 25
								$aElixButton[1] = $aButton[$i][2] + 25
								SetDebugLog("Found Elix Button on " & _ArrayToString($aElixButton), $COLOR_DEBUG)
						EndSelect
					Next
				EndIf
				If _Sleep(50) Then Return

				Local $iCount = 1, $bPlusButtonFound = False, $iCostUpgrade = 0
				If $iPlus10Gold > 0 Or $iPlus10Elix > 0 Then
					;UpWallElixir($iWallCost = $g_aiWallCost[$g_iTownHallLevel - 1], $iCountPlus = 1, $UpType = "+10", $aElixButton)
					
					SetLog("Looking for +10 Button", $COLOR_DEBUG)
					Switch $g_iUpgradeWallLootType
						Case 0 ;Gold
							UpWallGold($iWallCost, $iPlus10Gold, "+10", $aGoldButton)
							
						Case 1 ;Elixir
							UpWallElixir($iWallCost, $iPlus10Elix, "+10", $aElixButton)
							
						Case 2 ;Elixir Then Gold
							If $bCanUseElix = True And $iPlus10Elix > 0 Then
								UpWallElixir($iWallCost, $iPlus10Elix, "+10", $aElixButton)
							EndIf
							If $bCanUseGold = True And $iPlus10Gold > 0 Then
								UpWallGold($iWallCost, $iPlus10Gold, "+10", $aGoldButton)
							EndIf
					EndSwitch
				EndIf

				If _Sleep(50) Then Return
				If $iPlus1Gold > 1 Or $iPlus1Elix > 1 Then
					SetLog("Looking for +1 Button", $COLOR_DEBUG)
					Switch $g_iUpgradeWallLootType
						Case 0 ;Gold
							UpWallGold($iWallCost, $iPlus1Gold - 1, "+1", $aGoldButton)
						Case 1 ;Elix
							UpWallElixir($iWallCost, $iPlus1Elix - 1, "+1", $aElixButton)
						Case 2 ;Elix Then Gold
							If $bCanUseElix = True And $iPlus1Elix > 1 Then
								UpWallElixir($iWallCost, $iPlus1Elix - 1, "+1", $aElixButton)
							EndIf
							If $bCanUseGold = True And $iPlus1Gold > 1 Then
								UpWallGold($iWallCost, $iPlus1Gold - 1, "+1", $aGoldButton)
							EndIf
					EndSwitch
				EndIf
			Else
				If Not $g_bRunState Then Return
				SetLog("Going to Upgrade 1 Wall", $COLOR_DEBUG)
				Switch $g_iUpgradeWallLootType
					Case 0 ;Gold
						SetLog("Upgrading 1 Wall for Gold upgrade", $COLOR_ACTION)
						ClickP($aGoldButton)
						PushMsg("UpgradeWithGold")
						$g_iNbrOfWallsUppedGold += 1
						$g_iNbrOfWallsUpped += 1
						$g_iCostGoldWall += $iWallCost
						SetLog("Cost : " & _NumberFormat($iWallCost), $COLOR_SUCCESS)
					Case 1
						SetLog("Upgrading 1 Wall for Elix upgrade", $COLOR_ACTION)
						ClickP($aElixButton)
						PushMsg("UpgradeWithElixir")
						$g_iNbrOfWallsUppedElixir += 1
						$g_iNbrOfWallsUpped += 1
						$g_iCostElixirWall += $iWallCost
						SetLog("Cost : " & _NumberFormat($iWallCost), $COLOR_SUCCESS)
					Case 2
						Select
							Case $bCanUseElix = True And $iWallCanUpgradeElix > 0
								SetLog("Upgrading 1 Wall for Elix upgrade", $COLOR_ACTION)
								ClickP($aElixButton)
								PushMsg("UpgradeWithElixir")
								$g_iNbrOfWallsUppedElixir += 1
								$g_iNbrOfWallsUpped += 1
								$g_iCostElixirWall += $iWallCost
								SetLog("Cost : " & _NumberFormat($iWallCost), $COLOR_SUCCESS)
								$bCanUseGold = False
							Case $bCanUseGold = True And $iWallCanUpgradeGold > 0
								SetLog("Upgrading 1 Wall for Gold upgrade", $COLOR_ACTION)
								ClickP($aGoldButton)
								PushMsg("UpgradeWithGold")
								$g_iNbrOfWallsUppedGold += 1
								$g_iNbrOfWallsUpped += 1
								$g_iCostGoldWall += $iWallCost
								SetLog("Cost : " & _NumberFormat($iWallCost), $COLOR_SUCCESS)
						EndSelect
				EndSwitch
				If _Sleep(1000) Then Return
				If WaitforPixel(805, 101, 807, 102, Hex(0xFFFFFF, 6), 6, 2) Then
					Click(625, 545, 1, 50, "UpgradeWall")
					ClickAway()
				EndIf
			EndIf
		EndIf
	Else
		SetLog("Not a wall, looking Next wall", $COLOR_DEBUG)
		ClickAway()
	EndIf
EndFunc

Func UpWallElixir($iWallCost, $iCountPlus, $UpType, $aButton)
	Local $sDir = "", $bPlusButtonFound = False, $iCount = 1, $iCostUpgrade = 0
	Local $aBtnCoord = [150, 500, 750, 600], $iPlusWall = 1
	
	Switch $UpType 
		Case "+10"
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus10"
			$iPlusWall = 10
		Case "+1"
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus1"
	EndSwitch
	
	SetLog("Try " & $UpType & " for Elix upgrade", $COLOR_ACTION)
	For $i = 1 To $iCountPlus
		If QuickMIS("BC1", $sDir, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3]) Then
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 50, "Click " & $UpType)
			If _Sleep(500) Then Return
			$iCount += $iPlusWall
			$bPlusButtonFound = True
			SetDebugLog("iCount : " & $iCount)
		Else
			SetLog("No " & $UpType & " Button Found", $COLOR_DEBUG)
			ExitLoop
		EndIf
	Next
	;click Upgrade button
	If $bPlusButtonFound Then
		ClickP($aButton)
		PushMsg("UpgradeWithElixir")
		$iCostUpgrade = $iCount * $iWallCost
		$g_iNbrOfWallsUppedElixir += $iCount
		$g_iNbrOfWallsUpped += $iCount
		$g_iCostElixirWall += $iCostUpgrade
		SetLog("Upgraded wall with Elix: " & $iCount, $COLOR_SUCCESS)
		SetLog("Cost : " & _NumberFormat($iCostUpgrade), $COLOR_SUCCESS)
		UpdateStats()
		
		If _Sleep(1000) Then Return
		If IsOKCancelPage() Then ClickP($aConfirmSurrender) ;click confirm upgrade OK button
	EndIf
EndFunc

Func UpWallGold($iWallCost, $iCountPlus, $UpType, $aButton)
	Local $sDir = "", $bPlusButtonFound = False, $iCount = 1, $iCostUpgrade = 0
	Local $aBtnCoord = [150, 500, 750, 600], $iPlusWall = 1
	
	Switch $UpType 
		Case "+10"
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus10"
			$iPlusWall = 10
		Case "+1"
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus1"
	EndSwitch
	
	SetLog("Try " & $UpType & " for Gold upgrade", $COLOR_ACTION)
	For $i = 1 To $iCountPlus
		If QuickMIS("BC1", $sDir, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3]) Then
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 50, "Click " & $UpType)
			If _Sleep(500) Then Return
			$iCount += $iPlusWall
			$bPlusButtonFound = True
			SetDebugLog("iCount : " & $iCount)
		Else
			SetLog("No " & $UpType & " Button Found", $COLOR_DEBUG)
			ExitLoop
		EndIf
	Next
	;click Upgrade button
	If $bPlusButtonFound Then
		ClickP($aButton)
		PushMsg("UpgradeWithGold")
		$iCostUpgrade = $iCount * $iWallCost
		$g_iNbrOfWallsUppedGold += $iCount
		$g_iNbrOfWallsUpped += $iCount
		$g_iCostGoldWall += $iCostUpgrade
		SetLog("Upgraded wall with Gold: " & $iCount, $COLOR_SUCCESS)
		SetLog("Cost : " & _NumberFormat($iCostUpgrade), $COLOR_SUCCESS)
		UpdateStats()
		
		If _Sleep(1000) Then Return
		If IsOKCancelPage() Then ClickP($aConfirmSurrender) ;click confirm upgrade OK button
	EndIf
EndFunc

Func SearchWall(ByRef $aWallLevelFound, $bDisplayArray = False)
	Local $bWallFound = False, $aWallLevel, $iWallLevel
	Local $aWall, $aDel[1] = [0], $x, $y
	Local $iWallLevelToDelete = $g_iTownHallLevel

	SetLog("Search Wall on Village", $COLOR_DEBUG)
	If Not $bDisplayArray Then ZoomOut()
	
	$aWall = QuickMIS("CNX", $g_sImgCheckWallDir)

	If IsArray($aWall) And UBound($aWall) > 0 Then
		For $i = 0 To UBound($aWall) - 1
			If StringInStr($aWall[$i][3], "A") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "A", ""))
			If StringInStr($aWall[$i][3], "B") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "B", ""))
			If StringInStr($aWall[$i][3], "C") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "C", ""))
			If StringInStr($aWall[$i][3], "D") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "D", ""))
		Next

		If $g_iTownHallLevel >= 9 Then $iWallLevelToDelete = $g_iTownHallLevel + 1
		For $i = 0 To UBound($aWall) - 1
			If $aWall[$i][3] >= $iWallLevelToDelete Then 
				_ArrayAdd($aDel, $i) ;wall level >= TH level, should except this
				SetDebugLog("Level " & $aWall[$i][3] & " wall skipped, delete level : " & $iWallLevelToDelete, $COLOR_DEBUG)
			EndIf
			If $g_bUpgradeSpesificWall And $aWall[$i][3] <> $g_iTargetWallLevel Then 
				_ArrayAdd($aDel, $i)
				SetDebugLog("Level " & $aWall[$i][3] & " wall skipped, target level : " & $g_iTargetWallLevel, $COLOR_DEBUG)
			EndIf
		Next
		
		If $bDisplayArray Then _ArrayDisplay($aWall, "$aWall")
		
		$aDel[0] = UBound($aDel) - 1
		If $bDisplayArray Then _ArrayDisplay($aDel, "$sDel")
		If UBound($aWall) > $aDel[0] Then 
			_ArrayDelete($aWall, $aDel) ;delete wall level which same or higher than TH level
		Else
			SetLog("ERR: THLevel: " & $g_iTownHallLevel, $COLOR_DEBUG2)
			SetLog("ERR: Target Wall Level: " & $g_iTargetWallLevel, $COLOR_DEBUG2)
			SetLog("Total Wall Found on map: " & UBound($aWall), $COLOR_DEBUG2)
			SetLog("Total Wall should skip: " & $aDel[0], $COLOR_DEBUG2)
			SetLog("Please Set Right Wall Level", $COLOR_DEBUG2)
			SetLog("or select Any Level on upgrade wall setting", $COLOR_DEBUG2)
			Return False
		EndIf
		_ArraySort($aWall, 1, 0, 0, 3) ;short wall level descending

		SetDebugLog("Your TownHall Level: " & $g_iTownHallLevel & ", Exluding Wall Level >= " & $iWallLevelToDelete, $COLOR_INFO)
		SetDebugLog("Found " & UBound($aWall) - 1 & " Wall on Village", $COLOR_DEBUG)

		If $bDisplayArray Then _ArrayDisplay($aWall)

		For $i = 0 To UBound($aWall) - 1
			If _Sleep(50) Then Return
			$x = $aWall[$i][1]
			$y = $aWall[$i][2]
			$iWallLevel = $aWall[$i][3]
			
			If isInsideDiamondXY($x, $y) Then ;prevent click outside village
				SetLog("Verify Wall Level " & $iWallLevel & ", click wall on " & $x & "," & $y, $COLOR_DEBUG)
				Click($x, $y)
				If _Sleep(1000) Then Return
				$aWallLevel = BuildingInfo(242, 477)
				If $aWallLevel[1] = "Wall" And $aWallLevel[2] < $iWallLevelToDelete Then
					$bWallFound = True
					ExitLoop
				EndIf
				ClickAway()
				If _Sleep(500) Then Return
			EndIf
			SetDebugLog("Wrong wall Level " & $iWallLevel & " detected, coord outside diamond:" & $x & "," & $y, $COLOR_DEBUG)
		Next
	EndIf
	If $bWallFound Then
		SetLog("Your Gold : " & _NumberFormat($g_aiCurrentLoot[$eLootGold]), $COLOR_INFO)
		SetLog("Your Elix : " & _NumberFormat($g_aiCurrentLoot[$eLootElixir]), $COLOR_INFO)
		SetLog("Wall Level : " & $aWallLevel[2], $COLOR_SUCCESS)
		SetLog("Wall Cost  : " & _NumberFormat($g_aiWallCost[$aWallLevel[2]]), $COLOR_SUCCESS)
		SetLog("Min Gold Save : " & _NumberFormat($g_iUpgradeWallMinGold), $COLOR_INFO)
		SetLog("Min Elix Save : " & _NumberFormat($g_iUpgradeWallMinElixir), $COLOR_INFO)
		$aWallLevelFound = $aWallLevel
	EndIf
	Return $bWallFound
EndFunc