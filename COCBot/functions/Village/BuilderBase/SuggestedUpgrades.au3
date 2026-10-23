; #FUNCTION# ====================================================================================================================
; Name ..........: AutoUpgradeBB()
; Description ...: Goes to Builders Island and Upgrades buildings with 'suggested upgrades window'.
; Syntax ........: AutoUpgradeBB()
; Parameters ....:
; Return values .: None
; Author ........: xbebenk (04-2024)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $g_iXFindUpgradeBB = 340

Func AutoUpgradeBB($bTest = False)
	Local $bWasRunState = $g_bRunState
	$g_bRunState = True
	Local $Result = SearchUpgradeBB($bTest)
	$g_bRunState = $bWasRunState
	Return $Result
EndFunc   ;==>MainSuggestedUpgradeCode

Func AutoUpgradeBBCheckResource()

	Local $sBuilderInfo = getBuildersBBOnMenu()
	If StringInStr($sBuilderInfo, "#") > 0 Then ; check for valid OCR read
		Local $aGetBuilders = StringSplit($sBuilderInfo, "#", $STR_NOCOUNT) ; Split into free and total builder strings
		$g_iFreeBuilderCountBB = Int($aGetBuilders[0]) ; update global values
		$g_iTotalBuilderCountBB = Int($aGetBuilders[1])
	Else
		SetLog("Fail to read builder count", $COLOR_DEBUG1)
		Return False
	EndIf

	$g_aiCurrentLootBB[$eLootGoldBB] = getResourcesMainScreen(350, 22)
	$g_aiCurrentLootBB[$eLootElixirBB] = getResourcesMainScreen(350, 59)

	SetLog("[BB Builder]:" & $g_iFreeBuilderCountBB & "/" & $g_iTotalBuilderCountBB, $COLOR_SUCCESS)
	SetLog("[G]:" & _NumberFormat($g_aiCurrentLootBB[$eLootGoldBB]) & " [E]:" & _NumberFormat($g_aiCurrentLootBB[$eLootElixirBB]), $COLOR_SUCCESS)

	Return True

EndFunc

Func AutoUpgradeBBCheckBuilder($bTest = False)
	Local $bRet = False

	AutoUpgradeBBCheckResource()
	;Check if there is a free builder for Auto Upgrade
	If $g_iFreeBuilderCountBB > 0 Then
		$bRet = True
	Else
		$bRet = False
	EndIf
	Return $bRet
EndFunc

Func SearchUpgradeBB($bTest = False)
	$g_bStayOnBuilderBase = True

	If Not $g_bAutoUpgradeBBEnabled Then Return
	If _Sleep(50) Then Return
	SetLog("Check for Auto UpgradeBB", $COLOR_INFO)

	BuilderBaseReport()
	If $bTest Then $g_iFreeBuilderCountBB = 1

	If $g_aiCurrentLootBB[$eLootGoldBB] < 5000 Then
		SetLog("GoldBB < 5000, try again later!", $COLOR_DEBUG2)
		Return False
	EndIf

	OpenBBBuilderMenu()
	;SpendBBGoldOnWall() ;spend BB gold on wall

	If Not $g_bRunState Then Return
	If AutoUpgradeBBCheckBuilder($bTest) Then
		_SearchUpgradeBB($bTest) ;search upgrade for existing building
	EndIf

	ZoomOut(True)
	Return
EndFunc

Func _SearchUpgradeBB($bTest = False)
	Local $ZoomedIn = False, $bNew = False, $bSkipNew = False
	Local $NeedDrag = True, $TmpUpgradeCost = 0, $UpgradeCost = 0, $sameCost
	Local $bForceUseGold = False

	;$bSkipNew = FindBHInUpgradeProgress()

	For $z = 1 To 8 ;do scroll 8 times
		If Not AutoUpgradeBBCheckBuilder($bTest) Then ExitLoop
		$TmpUpgradeCost = getMostBottomCostBB() ;check most bottom upgrade cost
		If Not $g_bRunState Then Return
		If $UpgradeCost = $TmpUpgradeCost Then
			$sameCost += 1
		Else
			$sameCost = 0
			$UpgradeCost = $TmpUpgradeCost
		EndIf
		SetLog("[" & $z & "] SameCost=" & $sameCost & " [" & $TmpUpgradeCost & "]", $COLOR_DEBUG1)

		If $sameCost > 2 Then
			SetLog("Detected SameCost, exit!", $COLOR_DEBUG)
			CloseBuilderMenu()
			Return
		EndIf

		$bNew = False ;reset
		Local $Upgrades = FindUpgradeBB($bTest, $bSkipNew)
		If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
			SetLog("Building List:", $COLOR_INFO)
			If Not $g_bRunState Then Return
			For $i = 0 To UBound($Upgrades) - 1
				SetLog("[" & $Upgrades[$i][7] & "] " & $Upgrades[$i][3] & ", Cost:" & $Upgrades[$i][5] & " " & $Upgrades[$i][0] & ", Score: [" & ($Upgrades[$i][4] = "New" ? $Upgrades[$i][4] : $Upgrades[$i][6]) & "]", $COLOR_DEBUG1)
			Next

			;For $i = 0 To UBound($Upgrades) - 1
			;	If $Upgrades[$i][4] = "New" Then ;new building
			;		If CheckResourceForDoUpgradeBB($Upgrades[$i][3], $Upgrades[$i][5], $Upgrades[$i][0]) Then
			;			If PlaceNewBuildingFromShopBB($Upgrades[$i][3], $ZoomedIn, $Upgrades[$i][5]) Then
			;				$ZoomedIn = True
			;				$sameCost = 0
			;				$bNew = True
			;				If _Sleep(2000) Then Return
			;				If Not AutoUpgradeBBCheckBuilder($bTest) Then ExitLoop 2
			;			Else
			;				If IsFullScreenWindow() Then Click(820, 37) ;close shop window
			;				ExitLoop
			;			EndIf
			;		Else
			;			SetLog("Not Enough " & $Upgrades[$i][0] & " for New Upgrade: " & $Upgrades[$i][3], $COLOR_DEBUG2)
			;			If $Upgrades[$i][0] = "Elix" Then
			;				$bForceUseGold = True
			;			EndIf
			;		EndIf
			;	EndIf
			;Next
			;If $bNew Then ContinueLoop

			SetLog("Existing Builderbase Building")

			If $bForceUseGold Then
				Local $aDel[1] = [0]

				SetDebugLog("Upgrade :" & _ArrayToString($Upgrades))
				For $i = 0 To UBound($Upgrades) - 1
					If $Upgrades[$i][0] = "Elix" Then
						_ArrayAdd($aDel, $i)
						$aDel[0] += 1
					EndIf
				Next
				SetDebugLog("Delete list: " & _ArrayToString($aDel))
				_ArrayDelete($Upgrades, $aDel)

				;_ArraySort($Upgrades, 0, 0, 0, 5)
				SetDebugLog("Upgrade list: " & _ArrayToString($Upgrades))
			EndIf

			For $i = 0 To UBound($Upgrades) - 1
				If $g_bChkBOBControl And $Upgrades[$i][7] = "Common" And Not $bForceUseGold Then
					SetLog("Upgrade : " & $Upgrades[$i][3] & " should skipped, due to BOB Control", $COLOR_DEBUG1)
					ContinueLoop
				EndIf
				If CheckResourceForDoUpgradeBB($Upgrades[$i][3], $Upgrades[$i][5], $Upgrades[$i][0], False) Then ;name, cost, costtype
					SetLog("Going to Upgrade: " & $Upgrades[$i][3], $COLOR_INFO)
					Click($Upgrades[$i][1], $Upgrades[$i][2])
					If _Sleep(1000) Then Return
					If StringInStr($Upgrades[$i][3], "Battle") Then
						If DoUpgradeBBHero($Upgrades[$i][0], $Upgrades[$i][5], $Upgrades[$i][3], $bTest) Then 
							SetLog("Upgrade Success", $COLOR_SUCCESS)
							ExitLoop
						EndIf
					Else
						If DoUpgradeBB($Upgrades[$i][0], $Upgrades[$i][5], $Upgrades[$i][3], $bTest) Then ;costtype, cost, name, debug
							SetLog("Upgrade Success", $COLOR_SUCCESS)
							ExitLoop
						EndIf
					EndIf
				Else
					SetLog("Not Enough " & $Upgrades[$i][0] & " to Upgrade " & $Upgrades[$i][3], $COLOR_INFO)
					If $Upgrades[$i][7] = "Priority" And $Upgrades[$i][0] = "Elix" Then
						SetLog("Priority Elixir, Forced using gold", $COLOR_DEBUG2)
						$bForceUseGold = True
					EndIf
				EndIf
			Next
		EndIf
		If _Sleep(2000) Then Return
		If Not $g_bRunState Then Return
		If Not AutoUpgradeBBCheckBuilder($bTest) Then ExitLoop
		If Not ClickDragAutoUpgradeBB() Then ExitLoop
		SetLog("[" & $z & "] Scroll Up", $COLOR_DEBUG)
	Next
	Return True
EndFunc

Func FindUpgradeBB($bTest = False, $bSkipNew = False)
	Local $ElixMultiply = 1, $GoldMultiply = 1 ;used for multiply score
	Local $Gold = $g_aiCurrentLootBB[$eLootGoldBB]
	Local $Elix = $g_aiCurrentLootBB[$eLootElixirBB]
	If $Gold > $Elix Then $GoldMultiply += 1
	If $Elix > $Gold Then $ElixMultiply += 1

	Local $aBOBControl[3][2] = [["Double Cannon", 10], ["Archer Tower", 10], ["Multi Mortar", 10]]
	Local $aPriority[9][2] = [["Storage", 13], ["Army", 13], ["Barracks", 10], ["Star Lab", 14], ["Machine", 11], ["Copter", 11], ["Hall", 12], ["Gem", 9], ["Clock", 9]]

	Local $aTmpCoord, $aBuilding[0][8], $BuildingName, $UpgradeCost, $sUpgradeName, $tmpcost, $lenght = 150, $skipType = 0, $sCostType = ""
	Local $hTimer = TimerInit()

	;check if we found new building
	;If Not $bSkipNew Then $aTmpCoord = QuickMIS("CNX", $g_sImgAUpgradeObstNew, $g_iXFindUpgradeBB, 73, $g_iXFindUpgradeBB + 150, 400)
	;If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
	;	If Not $g_bRunState Then Return
	;	_ArraySort($aTmpCoord, 0, 0, 0, 2)
	;	For $i = 0 To UBound($aTmpCoord) - 1
	;		If Not $g_bRunState Then Return
	;		If QuickMIS("BC1", $g_sImgBBResourceIcon, $aTmpCoord[$i][1] + 80, $aTmpCoord[$i][2] - 12, $aTmpCoord[$i][1] + 230, $aTmpCoord[$i][2] + 10) Then
	;			$sCostType = $g_sQuickMISName
	;			$lenght = Number($g_iQuickMISX) - $aTmpCoord[$i][1]
	;		Else
	;			SetDebugLog("Fail to detect resource icon, skip..")
	;			ContinueLoop
	;		EndIf
	;
	;		$sUpgradeName = getBuildingName($aTmpCoord[$i][1] + 10, $aTmpCoord[$i][2] - 12, $lenght) ;get upgrade name and amount
	;		$tmpcost = getBuilderMenuCost($g_iQuickMISX + 5, $g_iQuickMISY - 10)
	;		If StringInStr($sUpgradeName, "Wall") Then $sUpgradeName = "Wall"
	;		Local $tmparray[1][8] = [[String($sCostType), $aTmpCoord[$i][1], Number($aTmpCoord[$i][2]), String($sUpgradeName), "New", Number($tmpcost), "New", 0]]
	;		_ArrayAdd($aBuilding, $tmparray)
	;		If @error Then SetLog("FindUpgrade ComposeArray[New] Err : " & @error, $COLOR_ERROR)
	;	Next
	;	;_ArrayDisplay($aBuilding)
	;	;If UBound($aBuilding) > 0 Then
	;	;	_ArraySort($aBuilding, 0, 0, 0, 5) ;sort by cost
	;	;	Return $aBuilding ;return new building array
	;	;EndIf
	;EndIf

	;$aTmpCoord = QuickMIS("CNX", $g_sImgUpgradeListCorner, 845, 50, 860, 535)
	;If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
	;	For $i = 0 To UBound($aTmpCoord) - 1
	;		$sUpgradeName = getBuildingName(597, $aTmpCoord[$i][2] + 6, $lenght) ;get upgrade name and amount
	;		$bNotEnoughOres = _PixelSearch(823, $aTmpCoord[$i][2] + 9, 823, $aTmpCoord[$i][2] + 35, Hex(0xFF7B72, 6), 20, True, "EnoughOres")
	;		If $bNotEnoughOres Then
	;			SetDebugLog($sUpgradeName & ": Not Enough Ores")
	;			ContinueLoop
	;		EndIf
	;		Local $tmparray[1][4] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1] - 50), Number($aTmpCoord[$i][2] + 10), String($sUpgradeName)]]
	;		_ArrayAdd($aUpgrade, $tmparray)
	;		If @error Then SetLog("GetEquipmentUpgradeList ComposeArray Err : " & @error, $COLOR_ERROR)
	;	Next
	;
	;	For $j = 0 To UBound($aUpgrade) - 1
	;		SetLog("[" & $j & "] Equipment: " & $aUpgrade[$j][3], $COLOR_DEBUG)
	;	Next
	;EndIf

	$aTmpCoord = QuickMIS("CNX", $g_sImgBBResourceIcon, 830, 50, 860, 535)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		RemoveDupCNX($aTmpCoord, 2)
		For $i = 0 To UBound($aTmpCoord) - 1
			If Not $g_bRunState Then Return
			;If QuickMIS("BC1",$g_sImgAUpgradeObstGear, $g_iXFindUpgradeBB, $aTmpCoord[$i][2] - 10, $aTmpCoord[$i][1], $aTmpCoord[$i][2] + 10) Then ContinueLoop ;skip new
			$sUpgradeName = getBuildingName(560, $aTmpCoord[$i][2] - 21, $lenght) ;get upgrade name and amount
			$tmpcost = getBuilderMenuCost($aTmpCoord[$i][1] - 140, $aTmpCoord[$i][2] - 3)
			If StringInStr($sUpgradeName, "Wall") Then $sUpgradeName = "Wall"
			If $g_bChkBBSpendGoldOnWall And StringInStr($sUpgradeName, "Wall") And StringInStr($aTmpCoord[$i][0], "Elix") Then ContinueLoop ;skip wall upgrade with elix
			If Number($tmpcost) = 0 Then ContinueLoop

			Local $tmparray[1][8] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1]), Number($aTmpCoord[$i][2]), String($sUpgradeName), 1, Number($tmpcost), 0, "Common"]]
			_ArrayAdd($aBuilding, $tmparray)
			If @error Then SetLog("FindUpgrade ComposeArray Err : " & @error, $COLOR_ERROR)
		Next

		For $j = 0 To UBound($aBuilding) -1
			If Not $g_bRunState Then Return
			Local $BuildingName = $aBuilding[$j][3]
			For $k = 0 To UBound($aBOBControl) - 1
				If StringInStr($BuildingName, $aBOBControl[$k][0]) Then
					Switch $aBuilding[$j][0]
						Case "Gold"
							$aBuilding[$j][6] = $aBOBControl[$k][1] * $GoldMultiply
						Case "Elix"
							$aBuilding[$j][6] = $aBOBControl[$k][1] * $ElixMultiply
					EndSwitch
					$aBuilding[$j][7] = "BOBControl"
				EndIf
			Next

			For $k = 0 To UBound($aPriority) - 1
				If StringInStr($BuildingName, $aPriority[$k][0]) Then
					Switch $aBuilding[$j][0]
						Case "Gold"
							$aBuilding[$j][6] = $aPriority[$k][1] * $GoldMultiply
						Case "Elix"
							$aBuilding[$j][6] = $aPriority[$k][1] * $ElixMultiply
					EndSwitch
					$aBuilding[$j][7] = "Priority"
				EndIf
			Next

			If $g_bDebugSetLog Then SetLog("[" & $j & "] Building: " & $BuildingName & ", Cost=" & $aBuilding[$j][5] & " Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG)
		Next
	EndIf

	_ArraySort($aBuilding, 1, 0, 0, 6) ;sort by score
	Setlog("Benchmark FindUpgradeBB : (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_DEBUG1)
	Return $aBuilding
EndFunc

Func CheckUpgradeBBIgnore($sBuildingName = "")

	;; Check ignore BuilderHall
	If StringInStr($sBuildingName, "Hall") And $g_bChkAutoUpgradeBBIgnoreHall Then
		SetLog("Ups! Builder Hall is not to Upgrade!", $COLOR_DEBUG2)
		Return False
	EndIf

	;; Check ignore Wall
	If StringInStr($sBuildingName, "Wall") And $g_bChkAutoUpgradeBBIgnoreWall Then
		SetLog("Ups! Wall is not to Upgrade!", $COLOR_DEBUG2)
		Return False
	EndIf

	;; Cannot determine level on builder menu now
	;; Check BOB Building
	;If $g_bChkBOBControl Then
	;	Select
	;		Case $sBuildingName = "Archer Tower" And $sBuildingName >= 5
	;			SetLog("Upgrade for " & $sBuildingName & " Level: " & $sBuildingName & " skipped due to BOB Control", $COLOR_SUCCESS)
	;			Return False
	;
	;		Case StringInStr($sBuildingName, "Double") And $sBuildingName >= 5
	;			SetLog("Upgrade for Double Cannon Level: " & $sBuildingName & " skipped due to BOB Control", $COLOR_SUCCESS)
	;			Return False
	;
	;		Case StringInStr($sBuildingName, "Multi") And $sBuildingName >= 8
	;			SetLog("Upgrade for " & $sBuildingName & " Level: " & $sBuildingName & " skipped due to BOB Control", $COLOR_SUCCESS)
	;			Return False
	;	EndSelect
	;EndIf

	Return True

EndFunc   ;==>CheckUpgradeBBIgnore

Func DoUpgradeBB($CostType = "Gold", $Cost = 0, $sBuildingName = "", $bTest = False)
	If Not CheckUpgradeBBIgnore($sBuildingName) Then Return False

	If _Sleep(50) Then Return
	If QuickMIS("BFI", $g_sImgAutoUpgradeBtnBB & $CostType & "*", 470, 500, 530, 565) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(1000) Then Return
		If isGemOpen(True) Then
			SetLog("Upgrade stopped due to insufficient loot", $COLOR_ERROR)
			ClickAway("Left")
			If _Sleep(500) Then Return
			ClickAway("Left")
			Return False
		Else
			SetLog($sBuildingName & " Upgrading!", $COLOR_INFO)
			AutoUpgradeLog(False, "BB " & $sBuildingName, "", $Cost)
			ClickAway("Left")
			Return True
		EndIf
	Else
		SetLog("Cannot Find " & $CostType & " Button", $COLOR_ERROR)
	EndIf

	Return False
EndFunc   ;==>DoUpgradeBB

Func DoUpgradeBBHero($CostType = "Gold", $Cost = 0, $sBuildingName = "", $bTest = False)
	If Not CheckUpgradeBBIgnore($sBuildingName) Then Return False

	If _Sleep(50) Then Return
	If QuickMIS("BFI", $g_sImgAutoUpgradeBtnBB & $CostType & "*", 730, 527, 795, 595) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		SetLog($sBuildingName & " Upgrading!", $COLOR_INFO)
		AutoUpgradeLog(False, "BB " & $sBuildingName, "", $Cost)
		CloseBuilderMenu()
		Return True
	Else
		SetLog("Cannot Find " & $CostType & " Button", $COLOR_ERROR)
	EndIf

	Return False
EndFunc   ;==>DoUpgradeBBHero

Func PlaceNewBuildingFromShopBB($sUpgrade = "", $bZoomedIn = False, $iCost = 0)
	If Not $g_bRunState Then Return
	CloseBuilderMenu()
	If _Sleep(1000) Then Return
	SetLog("PlaceNewBuildingFromShopBB : " & $sUpgrade & "", $COLOR_INFO)
	Local $bRet = False, $sUpgradeType = "", $ImageDir = ""
	$sUpgradeType = GetBuildingTypeBB($sUpgrade)
	SetLog("Opening BB Shop, UpgradeType : " & $sUpgradeType, $COLOR_DEBUG1)
	If $sUpgradeType = "" Then Return
	;search area to place new building
	If Not $bZoomedIn Then
		If Not SearchGreenZoneBB() Then Return $bRet
	EndIf

	;opening shop
	If Not OpenShopBB($sUpgradeType) Then Return
	If _Sleep(2000) Then Return
	Switch $sUpgradeType
		Case "Army"
			$ImageDir = $g_sImgShopArmyBB
		Case "Resources"
			$ImageDir = $g_sImgShopResourcesBB
		Case "Defenses"
			$ImageDir = $g_sImgShopDefensesBB
		Case "Traps"
			$ImageDir = $g_sImgShopTrapsBB
	EndSwitch

	Local $sImgUpgrade = StringStripWS($sUpgrade, $STR_STRIPALL)
	SetLog("ImgUpgrade : " & $sUpgrade & "=" & $sImgUpgrade & "*", $COLOR_INFO)

	If $sUpgradeType = "Army" Then
		If Not QuickMIS("BFI", $ImageDir & $sImgUpgrade & "*", 20, 225, 830, 535) Then
			ClickDrag(700, 330, 200, 330)
		EndIf
	EndIf

	If QuickMIS("BFI", $ImageDir & $sImgUpgrade & "*", 20, 225, 830, 550) Then
		SetLog("Found " & $sImgUpgrade & " on [" & $g_iQuickMISX & "," & $g_iQuickMISY &"]", $COLOR_SUCCESS)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(2500) Then Return
	Else
		Return $bRet
	EndIf

	If StringInStr($sUpgrade, "Wall") Then
		Local $aWall[3] = ["2","Wall",1]
		Local $aCostWall[3] = ["Gold", 50, 0]
		Local $tmpX = 0, $tmpY = 0, $iCount = 0
		Local $bWallGreenCheckFound = False
		For $iGCRetry = 1 To 5
			If Not $g_bRunState Then Return
			If QuickMIS("BFI", $g_sImgGreenCheckBB & "GreenCheck*", 100, 100, 800, 600) Then
				$tmpX = $g_iQuickMISX
				$tmpY = $g_iQuickMISY
				$bWallGreenCheckFound = True
				ExitLoop
			EndIf
			SetLog("[" & $iGCRetry & "] GreenCheck not found yet, retrying...", $COLOR_DEBUG)
			If _Sleep(800) Then Return
		Next
		If Not $bWallGreenCheckFound Then
			SetLog("GreenCheck Not Found", $COLOR_ERROR)
			GoGoblinMap()
			Return False
		EndIf

		For $ProMac = 1 To 5
			If Not $g_bRunState Then Return
			If QuickMIS("BFI", $g_sImgGreenCheckBB & "GreenCheck*", $tmpX - 40, $tmpY - 40, $tmpX + 40, $tmpY + 40) Then
				SetLog("Found GreenCheck on [" & $g_iQuickMISX & "," & $g_iQuickMISY &"]", $COLOR_SUCCESS)
				Click($g_iQuickMISX, $g_iQuickMISY, 2, 200)
				$bRet = True
				SetLog("Placing Wall #" & $ProMac, $COLOR_ACTION)
				If _Sleep(1000) Then Return
				If IsGemOpen(True) Then
					SetLog("Not Enough resource! Exiting", $COLOR_ERROR)
					If _Sleep(1000) Then Return
					ExitLoop
				EndIf
				If _Sleep(500) Then Return
				AutoUpgradeLog(True, "BB Wall")
			EndIf
		Next

		Click($g_iQuickMISX - 80, $g_iQuickMISY) ;click redX
		Click($g_iQuickMISX - 70, $g_iQuickMISY) ;click redX
		Click($g_iQuickMISX - 60, $g_iQuickMISY) ;click redX
		Return $bRet
	EndIf

	SetLog("Looking for GreenCheck Button", $COLOR_INFO)
	Local $bGreenCheckFound = False
	For $iGCRetry = 1 To 5
		If Not $g_bRunState Then Return
		If QuickMIS("BFI", $g_sImgGreenCheckBB & "GreenCheck*", 100, 120, 750, 600) Then
			$bGreenCheckFound = True
			ExitLoop
		EndIf
		SetLog("[" & $iGCRetry & "] GreenCheck not found yet, retrying...", $COLOR_DEBUG)
		If _Sleep(800) Then Return
	Next

	If $bGreenCheckFound Then
		SetLog("GreenCheck Found in [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_SUCCESS)

		If Not GreenCheckLocateBB($g_iQuickMISX, $g_iQuickMISY) Then Return False
		Local $iClickX = $g_iQuickMISX, $iClickY = $g_iQuickMISY
		Click($iClickX, $iClickY)
		If $sUpgradeType = "Traps" Then Click($iClickX, $iClickY)

		; verify the click actually closed the whole placement UI before trusting it
		; require Green AND RedX both gone, twice in a row, to filter out a transient
		; blip from the click just nudging the ghost building instead of confirming it
		Local $bClickVerified = False
		Local $iCleanChecks = 0
		For $iVerify = 1 To 4
			If _Sleep(600) Then Return
			If Not QuickMIS("BFI", $g_sImgGreenCheckBB & "GreenCheck*", 100, 120, 750, 600) And Not QuickMIS("BFI", $g_sImgGreenCheckBB & "RedX*", 100, 120, 750, 600) Then
				$iCleanChecks += 1
				If $iCleanChecks >= 2 Then
					$bClickVerified = True
					ExitLoop
				EndIf
			Else
				$iCleanChecks = 0
			EndIf
		Next
		If Not $bClickVerified Then
			SetLog("Click missed! Placement UI still visible after clicking [" & $iClickX & "," & $iClickY & "], placement failed", $COLOR_ERROR)
			Return False
		EndIf

		SetLog("Placed " & $sUpgrade & " on Main Village! [" & $iClickX & "," & $iClickY & "]", $COLOR_SUCCESS)
		AutoUpgradeLog(True, "BB " & $sUpgrade, 1, $iCost, "New")
		Return True
	ElseIf QuickMIS("BFI", $g_sImgGreenCheckBB & "GreyCheck*") Then
		SetLog("No GreenCheck Found, but Grey", $COLOR_ERROR)
		Click($g_iQuickMISX - 80, $g_iQuickMISY)
		Return False
	ElseIf QuickMIS("BFI", $g_sImgGreenCheckBB & "RedX*") Then
		; Green check unmatchable (e.g. dark scenery: green button on green terrain) — anchor on the RedX.
		; RedX is red, distinct from green terrain, so it matches cleanly; the green check sits +80px to its right.
		Local $iRxClickX = $g_iQuickMISX + 80, $iRxClickY = $g_iQuickMISY
		SetLog("GreenCheck via RedX anchor: RedX[" & $g_iQuickMISX & "," & $g_iQuickMISY & "] -> click [" & $iRxClickX & "," & $iRxClickY & "]", $COLOR_SUCCESS)
		Click($iRxClickX, $iRxClickY)
		If $sUpgradeType = "Traps" Then Click($iRxClickX, $iRxClickY)
		; same verification safety net as the green path: both Green AND RedX gone, twice in a row
		Local $bAnchorVerified = False, $iAnchorClean = 0
		For $iVerify = 1 To 4
			If _Sleep(600) Then Return
			If Not QuickMIS("BFI", $g_sImgGreenCheckBB & "GreenCheck*", 100, 120, 750, 600) And Not QuickMIS("BFI", $g_sImgGreenCheckBB & "RedX*", 100, 120, 750, 600) Then
				$iAnchorClean += 1
				If $iAnchorClean >= 2 Then
					$bAnchorVerified = True
					ExitLoop
				EndIf
			Else
				$iAnchorClean = 0
			EndIf
		Next
		If $bAnchorVerified Then
			SetLog("Placed " & $sUpgrade & " on Main Village via RedX anchor! [" & $iRxClickX & "," & $iRxClickY & "]", $COLOR_SUCCESS)
			AutoUpgradeLog(True, "BB " & $sUpgrade, 1, $iCost, "New")
			Return True
		EndIf
		SetLog("RedX anchor click did not confirm placement", $COLOR_ERROR)
		Return False
	EndIf
	SetLog("GreenCheck exhausted, no Green/Grey/RedX found, giving up on this placement", $COLOR_ERROR)
	Click($g_iQuickMISX + 80, $g_iQuickMISY)
	Return $bRet
EndFunc ;_PlaceNewBuildingFromShopBB

Func GreenCheckLocateBB($x, $y)
	If $x > 120 And $x < 600 And $y > 130 Then Return True

	Local $xDragStart = 430, $yDragStart = 430
	Local $xDrag = $xDragStart, $yDrag = $yDragStart

	If Number($g_iQuickMISX) > $xDragStart Then $xDrag = $xDragStart - Abs($g_iQuickMISX - $xDragStart)
	If Number($g_iQuickMISX) < $xDragStart Then $xDrag = $xDragStart + Abs($g_iQuickMISX - $xDragStart)
	If Number($g_iQuickMISY) > $yDragStart Then $yDrag = $yDragStart - Abs($g_iQuickMISY - $yDragStart)
	If Number($g_iQuickMISY) < $yDragStart Then $yDrag = $yDragStart + Abs($g_iQuickMISY - $yDragStart)

	SetLog("Set GreenCheckBB position for safer click", $COLOR_ACTION)
	If $g_bDebugSetLog Then SetLog("ClickDrag(" & $xDragStart & "," & $yDragStart & "," & $xDrag & "," & $yDrag & ")")
	ClickDrag($xDragStart, $yDragStart, $xDrag, $yDrag)
	If _Sleep(1000) Then Return
	If QuickMIS("BFI", $g_sImgGreenCheckBB & "GreenCheck*", 120, 250, 750, 600) Then Return True
	Return False
EndFunc

Func OpenShopBB($sUpgradeType = "Traps", $bCheckRedCounter = True)
	If Not $g_bRunState Then Return
	Local $bRet = False
	If WaitforPixel(815, 590, 816, 591, "E6F3ED", 10, 1, "OpenShopBB") Then
		Click(815, 590) ;Click Shop Button
		If _Sleep(1000) Then Return
	EndIf

	For $i = 1 To 5
		SetLog("Waiting BB Shop Window #" & $i, $COLOR_ACTION)
		If IsFullScreenWindow() Then
			If QuickMIS("BC1", $g_sImgBuildingAndTraps, 150, 10, 320, 85) Then
				Click($g_iQuickMISX, $g_iQuickMISY) ;click Building and traps Tab
				If $g_sQuickMISName = "BuildActive" Then
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
	Local $aRedPos[4] = [253, 416, 581, 745], $iRedPosY = 157
	If $bCheckRedCounter Then
		Switch $sUpgradeType
			Case "Army"
				If WaitforPixel($aRedPos[0], $iRedPosY, $aRedPos[0] + 1, $iRedPosY + 1, "D7081B", 20, 1, "OpenShopBB-Army") Then
					Click($aRedPos[0], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[0], $iRedPosY, $aRedPos[0] + 1, $iRedPosY + 1, "CD84FE", 20, 1, "OpenShopBB-Army") Then
					$bRet = True
				EndIf
			Case "Resources"
				If WaitforPixel($aRedPos[1], $iRedPosY, $aRedPos[1] + 1, $iRedPosY + 1, "D7081B", 20, 1, "OpenShopBB-Resources") Then
					Click($aRedPos[1], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[1], $iRedPosY, $aRedPos[1] + 1, $iRedPosY + 1, "CD84FE", 20, 1, "OpenShopBB-Resources") Then
					$bRet = True
				EndIf
			Case "Defenses"
				If WaitforPixel($aRedPos[2], $iRedPosY, $aRedPos[2] + 1, $iRedPosY + 1, "D7081B", 20, 1, "OpenShopBB-Defenses") Then
					Click($aRedPos[2], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[2], $iRedPosY, $aRedPos[2] + 1, $iRedPosY + 1, "CD84FE", 20, 1, "OpenShopBB-Defenses") Then
					$bRet = True
				EndIf
			Case "Traps"
				If WaitforPixel($aRedPos[3], $iRedPosY, $aRedPos[3] + 1, $iRedPosY + 1, "D7081B", 20, 1, "OpenShopBB-Traps") Then
					Click($aRedPos[3], $iRedPosY)
					$bRet = True
				EndIf
				Click(615, 170) ;just click the traps tab button
				If WaitforPixel($aRedPos[3], $iRedPosY, $aRedPos[3] + 1, $iRedPosY + 1, "CD84FE", 20, 1, "OpenShopBB-Traps") Then
					$bRet = True
				EndIf
		EndSwitch

		If Not $bRet Then
			SetLog("Fail Verify " & $sUpgradeType & " Tab, exit!", $COLOR_ERROR)
			Click(820, 37) ;close shop window
			Return $bRet
		EndIf
	EndIf
	SetLog("Opening " & $sUpgradeType & " Tab", $COLOR_ACTION)
	Return $bRet
EndFunc ;OpenShop

Func GetBuildingTypeBB($sUpgrades = "")
	If Not $g_bRunState Then Return
	Local $aArmy[5] = ["Camp", "Healing", "Copter", "Machine", "Control"]
	Local $aResource[3] = ["Collector", "Storage", "Mine"]
	Local $aDefense[12] = ["Wall", "Cannon", "Tower", "Mortar", "FireCrackers", "Air Bombs", "Tesla", "Crusher", "Roaster", "Launcher", "Guard", "Bow"]
	Local $aTrap[5] = ["Bomb", "Trap", "Mine", "Giant", "Mega"]
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

	If $sUpgrades = "Air Bombs" Then $sUpgradeType = "Defenses"
	If $sUpgrades = "Gold Mine" Then $sUpgradeType = "Resources"
	If $sUpgrades = "Giant Cannon" Then $sUpgradeType = "Defenses"

	If $g_bDebugSetLog Then SetLog("Found UpgradeType : " & $sUpgradeType, $COLOR_DEBUG1)
	Return $sUpgradeType
EndFunc ;GetBuildingTypeBB

Func SearchGreenZoneBB()
	If Not $g_bRunState Then Return
	SetLog("Search GreenZone for Placing new Building", $COLOR_INFO)
	ZoomOut()

	Local $bSupportedScenery = False
	Local $sSceneryCode[2] = ["BL", "BH"]
	For $sCode In $sSceneryCode
		If $sCode = $g_sSceneryCode Then
			$bSupportedScenery = True
			ExitLoop
		EndIf
	Next

	If Not $bSupportedScenery Then
		SetLog("Detected Scenery : [" & $g_sSceneryCode & " : " & $g_sCurrentScenery & "]", $COLOR_ERROR)
		SetLog("Place New Building Only Supported for Default BB Scenery", $COLOR_ERROR)
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
						$iTop = QuickMIS("Q1", $g_sImgAUpgradeGreenZoneBB, $x - ($Offset/2), $y, $x + ($Offset/2), $y + $Offset)
						SetLog("Count Green Top = " & $iTop, $COLOR_DEBUG1)
						$iCount = Number($iTop)
						$sArea = "Top"
					Case 1
						$iRight = QuickMIS("Q1", $g_sImgAUpgradeGreenZoneBB, $x - $Offset, $y - ($Offset/2), $x, $y + ($Offset/2))
						SetLog("Count Green Right = " & $iRight, $COLOR_DEBUG1)
						If $iCount < Number($iRight) Then
							$iCount = Number($iRight)
							$sArea = "Right"
						EndIf
					Case 2
						$iBottom = QuickMIS("Q1", $g_sImgAUpgradeGreenZoneBB, $x - ($Offset/2), $y - $Offset, $x + ($Offset/2), $y)
						SetLog("Count Green Bottom = " & $iBottom, $COLOR_DEBUG1)
						If $iCount < Number($iBottom) Then
							$iCount = Number($iBottom)
							$sArea = "Bottom"
						EndIf
					Case 3
						$iLeft = QuickMIS("Q1", $g_sImgAUpgradeGreenZoneBB, $x, $y - ($Offset/2), $x + $Offset, $y + ($Offset/2))
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

	If ZoomInBB($sArea) Then
		SetLog("Succeed ZoomInBB", $COLOR_DEBUG)
		Return True
	Else
		SetLog("Failed ZoomInBB", $COLOR_ERROR)
	EndIf

	Return False
EndFunc

Func GoAttackBBAndReturn()
	If Not $g_bRunState Then Return
	SetLog("Going attack, to clear field", $COLOR_DEBUG)
	PrepareAttackBB("CleanYard")
	_AttackBB()
	If Not $g_bRunState Then Return
	ClickAway("Left")
	ZoomOut()
	SetLog("Field should be clear now", $COLOR_DEBUG)
EndFunc

Func ClickDragAutoUpgradeBB()
	If Not $g_bRunState Then Return
	Local $x = 660, $yUp = 150, $yDown = 540, $Delay = 1500, $YY = 0

	ClickDrag(660, 540, 660, 140) ;drag up

EndFunc ;==>ClickDragAUpgrade

Func getMostBottomCostBB()
	Local $TmpUpgradeCost, $ret
	Local $Icon = QuickMIS("CNX", $g_sImgBBResourceIcon, 830, 500, 850, 585)
	If IsArray($Icon) And UBound($Icon) > 0 Then
		_ArraySort($Icon, 1, 0, 0, 2) ;sort by y coord desc
		$TmpUpgradeCost = getBuilderMenuCost($Icon[0][1] - 120, $Icon[0][2] - 2)
		$ret = $TmpUpgradeCost
	EndIf

	Return $ret
EndFunc

Func CheckResourceForDoUpgradeBB($BuildingName, $Cost, $CostType, $bReRead = True)
	If Not $g_bRunState Then Return
	If $bReRead Then BuilderBaseReport(True, False)
	Local $Gold = $g_aiCurrentLootBB[$eLootGoldBB]
	Local $Elix = $g_aiCurrentLootBB[$eLootElixirBB]

	Local $bSafeToUpgrade = False
	Switch $CostType
		Case "Gold"
			If $Gold >= $Cost Then $bSafeToUpgrade = True
		Case "Elix"
			If $Elix >= $Cost Then $bSafeToUpgrade = True
	EndSwitch

	SetLog("Checking: " & $BuildingName & ", Cost: " & $Cost & " " & $CostType, $COLOR_INFO)
	SetLog("Is Enough " & $CostType & " ? " & String($bSafeToUpgrade), $bSafeToUpgrade ? $COLOR_SUCCESS : $COLOR_ERROR)

	Return $bSafeToUpgrade
EndFunc

Func FindBHInUpgradeProgress()
	Local $bRet = False
	Local $Progress = QuickMIS("CNX", $g_sImgAUpgradeHour, 540, 100, 625, 130)
	If IsArray($Progress) And UBound($Progress) > 0 Then
		For $i = 0 To UBound($Progress) - 1
			Local $sUpgradeName = getBuildingName($Progress[$i][1] - 180, $Progress[$i][2] - 5) ;get upgrade name and amount
			If StringInStr($sUpgradeName, "Hall", 1) Then
				$bRet = True
				ExitLoop
			EndIf
		Next
	EndIf
	Return $bRet
EndFunc

Func WaitBBUpgradeWindow()
	Local $bRet = False
	For $i = 1 To 3
		SetLog("Waiting for Upgrade Window #" & $i, $COLOR_ACTION)
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 730, 50, 810, 130) Then
			$bRet = True
			SetLog("** Upgrade Window OK **", $COLOR_ACTION)
			ExitLoop
		EndIf
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 740, 124, 785, 180) Then
			$bRet = True
			SetLog("** Rebuild Window OK **", $COLOR_ACTION)
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	If Not $bRet Then SetLog("Cannot verify Upgrade Window", $COLOR_DEBUG2)
	Return $bRet
EndFunc

Func SpendBBGoldOnWall($iMaxScroll = 5, $bTest = False)
	Local $bRet = False
	Local $aSearchWall, $iWallIndex = -1, $iBOBIndex = -1
	If $g_bChkBBSpendGoldOnWall Then
		;check gold Storage
		isGoldFullBB()
		If $g_bGoldStorageFullBB Or $g_bGoldStorage50BB Or $bTest Then
			SetLog("Enabled to spend Gold on Wall", $COLOR_DEBUG1)
			For $i = 1 To $iMaxScroll
				SetLog("Searching Wall on Builder menu", $COLOR_ACTION)

				BuilderBaseReport(False, False)
				$aSearchWall = FindUpgradeBB($bTest, False)
				If IsArray($aSearchWall) And UBound($aSearchWall) > 0 Then
					For $j = 0 To UBound($aSearchWall) - 1
						If StringInStr($aSearchWall[$j][6], "New") And $aSearchWall[$j][0] = "Gold" Then
							SetLog("Found " & $aSearchWall[$j][3] & " " & $aSearchWall[$j][6] & " " & $aSearchWall[$j][0], $COLOR_DEBUG2)
							SetLog("New Building with gold, skip spend gold on wall", $COLOR_DEBUG2)
							ClickAway()
							If _Sleep(500) Then Return
							Return $bRet
						ElseIf $aSearchWall[$j][3] = "Builder Hall" Then
							SetLog("Found Builder Hall, skip spend gold on wall", $COLOR_DEBUG2)
							If Number($g_aiCurrentLootBB[$eLootGoldBB]) < Number($aSearchWall[$j][5]) Then
								SetDebugLog($g_aiCurrentLootBB[$eLootGoldBB] & " < " & $aSearchWall[$j][5])
								ClickAway()
							EndIf
							Return $bRet
						ElseIf $aSearchWall[$j][3] = "Elixir Storage" And $g_aiCurrentLootBB[$eLootGoldBB] >= $aSearchWall[$j][5] Then
							SetLog("Found Elixir Storage, skip spend gold on wall", $COLOR_DEBUG2)
							Return $bRet
						EndIf
					Next
				EndIf

				If Not $g_bRunState Then Return
				_ArraySort($aSearchWall, 1, 0, 0, 5) ; sort by cost
				$iWallIndex = _ArraySearch($aSearchWall, "Wall", 0, 0, 0, 0, 1, 3)
				If $iWallIndex >= 0 Then
					SetLog("Found Wall, cost : " & $aSearchWall[$iWallIndex][5], $COLOR_ACTION)
					Click($aSearchWall[$iWallIndex][1], $aSearchWall[$iWallIndex][2])
					If _Sleep(500) Then Return
					Local $iCount = Floor(($g_aiCurrentLootBB[$eLootGoldBB]*0.8) / $aSearchWall[$iWallIndex][5])

					SetLog("Can up wall up to : " & $iCount, $COLOR_SUCCESS)
					If $iCount > 10 Then
						If BBUpWallGold($aSearchWall[$iWallIndex][5], $iCount/10, "+10") Then Return True
					ElseIf $iCount < 11 Then
						If BBUpWallGold($aSearchWall[$iWallIndex][5], $iCount, "+1") Then Return True
					ElseIf $iCount < 2 Then
						If QuickMIS("BFI", $g_sImgBBResourceIcon & "\Gold*", 150, 500, 750, 600) Then
							Click($g_iQuickMISX, $g_iQuickMISY)
							If WaitBBUpgradeWindow() Then
								If QuickMIS("BC1", $g_sImgBBUpgradeWindowButton, 340, 400, 800, 600) Then
									Click($g_iQuickMISX - 50, $g_iQuickMISY + 10)
									SetLog("Upgraded wall with BB Gold", $COLOR_SUCCESS)
									$bRet = True
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					SetLog("No Wall found on list", $COLOR_DEBUG2)
				EndIf
				ClickDragAutoUpgradeBB()
				If Not $g_bRunState Then Return
			Next
		EndIf
	EndIf
	Return $bRet
EndFunc

Func BBUpWallGold($iWallCost = 10000, $iCountPlus = 2, $UpType = "+1")
	Local $sDir = "", $bPlusButtonFound = False, $iCount = 1, $iCostUpgrade = 0
	Local $aBtnCoord = [150, 500, 750, 600], $iPlusWall = 1, $iOffset = 0

	If _Sleep(1000) Then Return
	If $iCountPlus > 1 Then
		If QuickMIS("BFI", $g_sImgCheckWallDirUpgradeButton & "\PlusSign*", $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3]) Then
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 50, "Click Up More")
			If _Sleep(500) Then Return
		Else
			SetLog("Cannot find Up more wall button", $COLOR_DEBUG2)
			If QuickMIS("BFI", $g_sImgBBResourceIcon & "\Gold*", 180, 500, 700, 540) Then
				Click($g_iQuickMISX - 30, $g_iQuickMISY + 30)
				If WaitBBUpgradeWindow() Then Click(420, 535, 1, 0, "UpWallGold")
				SetLog("Upgraded a wall with BB Gold", $COLOR_SUCCESS)
				If _Sleep(1000) Then Return
			EndIf
			Return
		EndIf
	EndIf

	Switch $UpType
		Case "+10"
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus10"
			$iPlusWall = 10
		Case "+1"
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus1"
	EndSwitch

	If $UpType = "+10" Then
		If Not QuickMIS("BC1", $sDir, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3]) Then
			SetLog("No " & $UpType & " Button Found", $COLOR_DEBUG)
			SetLog("Change to search +1 instead", $COLOR_DEBUG1)
			$iPlusWall = 1
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus1"
			$UpType = "+1"
			$iCountPlus = 9
		EndIf
	EndIf

	SetLog("Try " & $UpType & " using BB Gold", $COLOR_ACTION)

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
		Switch $UpType
			Case "+10"
				$iOffset = 180
			Case "+1"
				$iOffset = 100
		EndSwitch
		Click($g_iQuickMISX + $iOffset, $g_iQuickMISY)

		SetLog("Upgraded wall with BB Gold: " & $iCount, $COLOR_SUCCESS)
		If _Sleep(1000) Then Return
		If IsOKCancelPage() Then ClickP($aConfirmSurrender) ;click confirm upgrade OK button
		ClickAway()
		Return True
	EndIf
EndFunc

Func OpenBBBuilderMenu($bOpenSLab = False)
	If Not $g_bRunState Then Return
	Local $bRet = False

	; open the builders menu
	If _ColorCheck(_GetPixelColor(753, 594, True), Hex(0xFCC610, 6), 10, Default, "Orange Build Button") Then
		SetLog("opening Builder menu", $COLOR_ACTION)
		Click(800, 600, 1, 0, "Click Builder Button")
	EndIf

	WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) ;check red x upper right corner
	If $bOpenSLab Then
		Click(770, 636, 1, 0, "Click Star Lab icon")
		If _Sleep(500) Then Return
		If QuickMIS("BC1", $g_sImgStarLabMenu, 640, 14, 665, 25) Then $bRet = True
	Else
		If QuickMIS("BC1", $g_sImgBBBuilderMenu, 640, 14, 665, 25) Then $bRet = True
	EndIf

	If $bRet Then SetLog("Successfully opening Builderbase " & ($bOpenSLab = True ? "Star Laboratory" : "BuilderBase Builder") & " menu", $COLOR_SUCCESS)

	Return $bRet
EndFunc