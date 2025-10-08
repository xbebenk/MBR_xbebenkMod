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

Func SearchUpgradeBB($bTest = False)
	$g_bStayOnBuilderBase = True
	
	If Not $g_bAutoUpgradeBBEnabled Then Return
	If _Sleep(50) Then Return
	SetLog("Check for Auto UpgradeBB", $COLOR_INFO)
	
	If Not $g_bRunState Then Return
	If AutoUpgradeBBCheckBuilder($bTest) Then
		_SearchUpgradeBB($bTest) ;search upgrade for existing building
	EndIf

	ZoomOut()
	Return False
EndFunc

Func _SearchUpgradeBB($bTest = False)
	Local $ZoomedIn = False, $bNew = False, $bSkipNew = False
	Local $NeedDrag = True, $TmpUpgradeCost = 0, $UpgradeCost = 0, $sameCost
	
	For $z = 1 To 8 ;do scroll 8 times
		If Not ClickBBBuilder() Then Return
		If _Sleep(500) Then Return
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
			If IsBBBuilderMenuOpen() Then Click(466, 30)
			ExitLoop
		EndIf
		$bNew = False ;reset
		Local $Upgrades = FindUpgradeBB($bTest, $bSkipNew)
		If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
			SetLog("Building List:", $COLOR_INFO)
			If Not $g_bRunState Then Return
			For $i = 0 To UBound($Upgrades) - 1
				SetLog("[" & $Upgrades[$i][7] & "] " & $Upgrades[$i][3] & ", Cost:" & $Upgrades[$i][5] & " " & $Upgrades[$i][0] & ", Score: [" & ($Upgrades[$i][4] = "New" ? $Upgrades[$i][4] : $Upgrades[$i][6]) & "]", $COLOR_DEBUG1)
			Next
			
			For $i = 0 To UBound($Upgrades) - 1
				If $Upgrades[$i][4] = "New" Then ;new building					
					If CheckResourceForDoUpgradeBB($Upgrades[$i][3], $Upgrades[$i][5], $Upgrades[$i][0]) Then 
						If PlaceNewBuildingFromShopBB($Upgrades[$i][3], $ZoomedIn, $Upgrades[$i][5]) Then
							$ZoomedIn = True
							$sameCost = 0
							$bNew = True
							If _Sleep(2000) Then Return
							If Not AutoUpgradeBBCheckBuilder($bTest) Then ExitLoop 2
						Else
							If IsFullScreenWindow() Then Click(820, 37) ;close shop window
							ExitLoop
						EndIf
					Else
						$bSkipNew = True
					EndIf
				EndIf
			Next
			If $bNew Then ContinueLoop
			
			SetLog("Existing Builderbase Building")
			
			For $i = 0 To UBound($Upgrades) - 1
				If $g_bChkBOBControl And $Upgrades[$i][7] = "Common" Then 
					SetLog("Upgrade : " & $Upgrades[$i][3] & " should skipped, due to BOB Control", $COLOR_DEBUG1)
					ContinueLoop
				EndIf
				If CheckResourceForDoUpgradeBB($Upgrades[$i][3], $Upgrades[$i][5], $Upgrades[$i][0], False) Then ;name, cost, costtype
					If StringInStr($Upgrades[$i][7], "skip") Then 
						SetLog("Upgrade : " & $Upgrades[$i][3] & " should skipped, " & $Upgrades[$i][7], $COLOR_DEBUG1)
						ContinueLoop
					EndIf
					SetLog("Going to Upgrade: " & $Upgrades[$i][3], $COLOR_INFO)
					Click($Upgrades[$i][1], $Upgrades[$i][2])
					If _Sleep(1000) Then Return
					If DoUpgradeBB($Upgrades[$i][0], $Upgrades[$i][5], $bTest) Then ;costtype, cost, debug
						SetLog("Upgrade Success", $COLOR_SUCCESS)
						ExitLoop
					EndIf
				Else
					SetLog("Not Enough " & $Upgrades[$i][0] & " to Upgrade " & $Upgrades[$i][3], $COLOR_INFO)
				EndIf
			Next
		EndIf
		If _Sleep(2000) Then Return
		If Not AutoUpgradeBBCheckBuilder($bTest) Then ExitLoop
		If Not $g_bRunState Then Return
	
		If Not ClickDragAutoUpgradeBB("up") Then ExitLoop
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
	
	Local $aTmpCoord, $aBuilding[0][8], $BuildingName, $UpgradeCost, $aUpgradeName, $tmpcost, $lenght = 0, $skipType = 0, $sCostType = ""
	
	;check if we found new building
	If Not $bSkipNew Then $aTmpCoord = QuickMIS("CNX", $g_sImgAUpgradeObstNew, $g_iXFindUpgradeBB, 73, $g_iXFindUpgradeBB + 150, 400)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		If Not $g_bRunState Then Return
		_ArraySort($aTmpCoord, 0, 0, 0, 2)
		For $i = 0 To UBound($aTmpCoord) - 1
			
			If QuickMIS("BC1", $g_sImgBBResourceIcon, $aTmpCoord[$i][1] + 80, $aTmpCoord[$i][2] - 12, $aTmpCoord[$i][1] + 230, $aTmpCoord[$i][2] + 10) Then
				$sCostType = $g_iQuickMISName
				$lenght = Number($g_iQuickMISX) - $aTmpCoord[$i][1]
			EndIf
			
			$aUpgradeName = getBuildingName($aTmpCoord[$i][1] + 10, $aTmpCoord[$i][2] - 12, $lenght) ;get upgrade name and amount
			$tmpcost = getBuilderMenuCost($g_iQuickMISX + 5, $g_iQuickMISY - 10)
			;For $j = 0 To UBound($aPriority) - 1
			;	If StringInStr($aUpgradeName[0], $aPriority[$j][0]) > 0 Then
			;		If $sCostType = "Elix" And Not CheckResourceForDoUpgradeBB($aUpgradeName[0], Number($tmpcost), $sCostType) Then 
			;			$g_bReserveElixirBB = True
			;			SetLog("Reserved " & $sCostType & " for New Upgrade : " & $aUpgradeName[0], $COLOR_DEBUG1)
			;			ContinueLoop 2
			;		EndIf
			;		If $sCostType = "Gold" And Not CheckResourceForDoUpgradeBB($aUpgradeName[0], Number($tmpcost), $sCostType) Then 
			;			$g_bReserveGoldBB = True
			;			SetLog("Reserved " & $sCostType & " for New Upgrade : " & $aUpgradeName[0], $COLOR_DEBUG1)
			;			ContinueLoop 2
			;		EndIf
			;	EndIf
			;Next
			Local $tmparray[1][8] = [[String($sCostType), $aTmpCoord[$i][1], Number($aTmpCoord[$i][2]), String($aUpgradeName[0]), "New", Number($tmpcost), "New", 0]]
			_ArrayAdd($aBuilding, $tmparray)
			If @error Then SetLog("FindUpgrade ComposeArray[New] Err : " & @error, $COLOR_ERROR)
		Next
		;_ArrayDisplay($aBuilding)
		If UBound($aBuilding) > 0 Then 
			_ArraySort($aBuilding, 0, 0, 0, 5) ;sort by cost
			Return $aBuilding ;return new building array
		EndIf
	EndIf
	
	$aTmpCoord = QuickMIS("CNX", $g_sImgBBResourceIcon, 510, 73, 620, 400)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			If QuickMIS("BC1",$g_sImgAUpgradeObstGear, $g_iXFindUpgradeBB, $aTmpCoord[$i][2] - 10, $aTmpCoord[$i][1], $aTmpCoord[$i][2] + 10) Then ContinueLoop ;skip new
			$lenght = Number($aTmpCoord[$i][1]) - $g_iXFindUpgradeBB
			$aUpgradeName = getBuildingName($g_iXFindUpgradeBB, $aTmpCoord[$i][2] - 12, $lenght) ;get upgrade name and amount
			$tmpcost = getBuilderMenuCost($aTmpCoord[$i][1], $aTmpCoord[$i][2] - 10)
			If Number($tmpcost) = 0 Then ContinueLoop
			
			$sCostType = $aTmpCoord[$i][0]
			;For $j = 0 To UBound($aPriority) - 1
			;	If StringInStr($aUpgradeName[0], $aPriority[$j][0]) > 0 Then
			;		If $sCostType = "Elix" And Not CheckResourceForDoUpgradeBB($aUpgradeName[0], Number($tmpcost), $sCostType) Then 
			;			$g_bReserveElixirBB = True
			;			SetLog("Reserved " & $sCostType & " for Priority Upgrade : " & $aUpgradeName[0], $COLOR_DEBUG1)
			;			ContinueLoop 2
			;		Else
			;			$g_bReserveElixirBB = False
			;		EndIf
			;		If $sCostType = "Gold" And Not CheckResourceForDoUpgradeBB($aUpgradeName[0], Number($tmpcost), $sCostType) Then 
			;			$g_bReserveGoldBB = True
			;			SetLog("Reserved " & $sCostType & " for Priority Upgrade : " & $aUpgradeName[0], $COLOR_DEBUG1)
			;			ContinueLoop 2
			;		Else
			;			$g_bReserveElixirBB = False
			;		EndIf
			;	EndIf
			;Next
			
			Local $tmparray[1][8] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1]), Number($aTmpCoord[$i][2]), String($aUpgradeName[0]), Number($aUpgradeName[1]), Number($tmpcost), 0, "Common"]]
			_ArrayAdd($aBuilding, $tmparray)
			If @error Then SetLog("FindUpgrade ComposeArray Err : " & @error, $COLOR_ERROR)
		Next

		For $j = 0 To UBound($aBuilding) -1
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
			
			;If $aBuilding[$j][0] = "Elix" And $g_bReserveElixirBB Then $aBuilding[$j][7] = "ElixReserved-skip"
			;If $aBuilding[$j][0] = "Gold" And $g_bReserveGoldBB Then $aBuilding[$j][7] = "GoldReserved-skip"
			If $g_bDebugSetLog Then SetLog("[" & $j & "] Building: " & $BuildingName & ", Cost=" & $aBuilding[$j][5] & " Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG)
		Next
	EndIf
	
	_ArraySort($aBuilding, 1, 0, 0, 6) ;sort by score
	Return $aBuilding
EndFunc

Func DoUpgradeBB($CostType = "Gold", $Cost = 0, $bTest = False)
	If _Sleep(1000) Then Return
	For $i = 1 To 3
		Local $aBuildingName = BuildingInfo(242, 479)
		If $aBuildingName[0] = "" Then
			SetLog("[" & $i & "] Trying to get upgrade name and level...", $COLOR_ACTION)
			If _Sleep(1000) Then Return
			ContinueLoop
		Else
			ExitLoop
		EndIf
		If Not $g_bRunState Then Return
		If _Sleep(500) Then Return
	Next
	
	;check ignore BuilderHall
	If StringInStr($aBuildingName[1], "Hall") And $g_bChkAutoUpgradeBBIgnoreHall Then
		SetLog("Ups! Builder Hall is not to Upgrade!", $COLOR_ERROR)
		Return False
	EndIf
	;check ignore Wall
	If StringInStr($aBuildingName[1], "Wall") And $g_bChkAutoUpgradeBBIgnoreWall Then
		SetLog("Ups! Wall is not to Upgrade!", $COLOR_ERROR)
		Return False
	EndIf
	
	;check BOB Building
	Select
		Case $aBuildingName[1] = "Archer Tower" And $aBuildingName[2] >= 6
			SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to BOB Control", $COLOR_SUCCESS)
			Return False
		Case StringInStr($aBuildingName[1], "Double") And $aBuildingName[2] >= 4
			SetLog("Upgrade for Double Cannon Level: " & $aBuildingName[2] & " skipped due to BOB Control", $COLOR_SUCCESS)
			Return False
		Case StringInStr($aBuildingName[1], "Multi") And $aBuildingName[2] >= 8
			SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to BOB Control", $COLOR_SUCCESS)
			Return False
	EndSelect
	
	If Not $g_bRunState Then Return
	If StringInStr($aBuildingName[1], "Gem") And $aBuildingName[2] = "" Then $CostType = "Rebuild" 
	If StringInStr($aBuildingName[1], "Battle") And $aBuildingName[2] = "" Then $CostType = "Rebuild"
	If StringInStr($aBuildingName[1], "Clock") And $aBuildingName[2] = "" Then $CostType = "Rebuild"	
	
	If QuickMIS("BFI", $g_sImgAutoUpgradeBtnBB & $CostType & "*", 240, 480, 650, 580) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		If Not $bTest Then
			If WaitBBUpgradeWindow() Then
				If _Sleep(1000) Then Return
				If QuickMIS("BC1", $g_sImgBBUpgradeWindowButton, 340, 400, 800, 600) Then
					Click($g_iQuickMISX - 50, $g_iQuickMISY + 10)
					If _Sleep(1000) Then Return
					If isGemOpen(True) Then
						SetLog("Upgrade stopped due to insufficient loot", $COLOR_ERROR)
						ClickAway("Left")
						If _Sleep(500) Then Return
						ClickAway("Left")
						Return False
					Else
						SetLog($aBuildingName[1] & " Upgrading!", $COLOR_INFO)
						AutoUpgradeLog(False, $aBuildingName[1], $aBuildingName[2], $Cost)
						If _Sleep(500) Then Return
						ClickAway("Left")
						Return True
					EndIf
				Else
					SetLog("Cannot Find Upgrade Button on Upgrade Window", $COLOR_ERROR)
				EndIf
			EndIf
		Else
			SetLog("Only for Test!", $COLOR_ERROR)
			ClickAway("Left")
			ClickBBBuilder()
			Return True
		EndIf
	Else
		SetLog("Cannot Find " & $CostType & " Button", $COLOR_ERROR)
	EndIf

	Return False
EndFunc   ;==>DoUpgradeBB

Func PlaceNewBuildingFromShopBB($sUpgrade = "", $bZoomedIn = False, $iCost = 0)
	If Not $g_bRunState Then Return
	If IsBBBuilderMenuOpen() Then Click(466, 30)
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
		If QuickMIS("BFI", $g_sImgGreenCheckBB & "GreenCheck*", 100, 100, 800, 600) Then
			$tmpX = $g_iQuickMISX
			$tmpY = $g_iQuickMISY
		Else
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
				AutoUpgradeLog(True, "Wall")
			EndIf
		Next
		
		Click($g_iQuickMISX - 80, $g_iQuickMISY) ;click redX
		Click($g_iQuickMISX - 70, $g_iQuickMISY) ;click redX
		Click($g_iQuickMISX - 60, $g_iQuickMISY) ;click redX
		Return $bRet
	EndIf
	
	SetLog("Looking for GreenCheck Button", $COLOR_INFO)
	If Not $g_bRunState Then Return
	If QuickMIS("BFI", $g_sImgGreenCheckBB & "GreenCheck*", 120, 120, 720, 550) Then
		SetLog("GreenCheck Found in [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_SUCCESS)
		
		If Not GreenCheckLocateBB($g_iQuickMISX, $g_iQuickMISY) Then Return False
		Click($g_iQuickMISX, $g_iQuickMISY)
		If $sUpgradeType = "Traps" Then Click($g_iQuickMISX, $g_iQuickMISY)
		SetLog("Placed " & $sUpgrade & " on Main Village! [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_SUCCESS)
		If _Sleep(1000) Then Return
		AutoUpgradeLog(True, $sUpgrade, 1, $iCost, "New")
		Return True
	ElseIf QuickMIS("BFI", $g_sImgGreenCheckBB & "GreyCheck*") Then
		SetLog("No GreenCheck Found, but Grey", $COLOR_ERROR)
		Click($g_iQuickMISX - 80, $g_iQuickMISY)
		Return False
	ElseIf QuickMIS("BFI", $g_sImgGreenCheckBB & "RedX*") Then
		SetLog("No GreenCheck Found, but RedX", $COLOR_ERROR)
		Click($g_iQuickMISX + 80, $g_iQuickMISY)
		Click($g_iQuickMISX, $g_iQuickMISY)
		Return False
	EndIf
	Click($g_iQuickMISX + 80, $g_iQuickMISY)
	Return $bRet
EndFunc ;_PlaceNewBuildingFromShopBB

Func GreenCheckLocateBB($x, $y)
	If $x > 120 And $x < 600 And $y > 200 Then Return True
	
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
				If WaitforPixel($aRedPos[0], $iRedPosY, $aRedPos[0] + 1, $iRedPosY + 1, "D7081B", 10, 1, "OpenShopBB-Army") Then 
					Click($aRedPos[0], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[0], $iRedPosY, $aRedPos[0] + 1, $iRedPosY + 1, "CD84FE", 10, 1, "OpenShopBB-Army") Then 
					$bRet = True
				EndIf
			Case "Resources"
				If WaitforPixel($aRedPos[1], $iRedPosY, $aRedPos[1] + 1, $iRedPosY + 1, "D7081B", 10, 1, "OpenShopBB-Resources") Then 
					Click($aRedPos[1], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[1], $iRedPosY, $aRedPos[1] + 1, $iRedPosY + 1, "CD84FE", 10, 1, "OpenShopBB-Resources") Then 
					$bRet = True
				EndIf
			Case "Defenses"
				If WaitforPixel($aRedPos[2], $iRedPosY, $aRedPos[2] + 1, $iRedPosY + 1, "D7081B", 10, 1, "OpenShopBB-Defenses") Then 
					Click($aRedPos[2], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[2], $iRedPosY, $aRedPos[2] + 1, $iRedPosY + 1, "CD84FE", 10, 1, "OpenShopBB-Defenses") Then 
					$bRet = True
				EndIf
			Case "Traps"
				If WaitforPixel($aRedPos[3], $iRedPosY, $aRedPos[3] + 1, $iRedPosY + 1, "D7081B", 10, 1, "OpenShopBB-Traps") Then 
					Click($aRedPos[3], $iRedPosY)
					$bRet = True
				EndIf
				Click(615, 170) ;just click the traps tab button
				If WaitforPixel($aRedPos[3], $iRedPosY, $aRedPos[3] + 1, $iRedPosY + 1, "CD84FE", 10, 1, "OpenShopBB-Traps") Then 
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
	Local $aDefense[11] = ["Wall", "Cannon", "Tower", "Mortar", "FireCrackers", "Air Bombs", "Tesla", "Crusher", "Roaster", "Launcher", "Guard"]
	Local $aTrap[7] = ["Bomb", "Trap", "Mine", "Giant", "Mega", "Lava", "Bow"]
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

Func AutoUpgradeBBCheckBuilder($bTest = False)
	Local $bRet = False
	BuilderBaseReport(True, False)
	If $bTest Then $g_iFreeBuilderCountBB = 1
	
	If $g_aiCurrentLootBB[$eLootGoldBB] < 5000 Then 
		SetLog("GoldBB < 5000, try again later!", $COLOR_DEBUG2)
		Return False
	EndIf
	
	;Check if there is a free builder for Auto Upgrade
	If $g_iFreeBuilderCountBB > 0 Then
		$bRet = True
	Else
		SetLog("Master Builder Not Available", $COLOR_DEBUG2)
		$bRet = False
	EndIf
	SetLog("Free Master Builder : " & $g_iFreeBuilderCountBB, $COLOR_DEBUG)
	Return $bRet
EndFunc

Func ClickBBBuilder($Counter = 3)
	Local $b_WindowOpened = False
	If Not $g_bRunState Then Return
	
	; open the builders menu
	If Not IsBBBuilderMenuOpen() Then
		SetLog("Opening BB BuilderMenu", $COLOR_ACTION)
		Click(466, 30)
		If _Sleep(1000) Then Return
	EndIf
	
	;check
	If IsBBBuilderMenuOpen() Then
		SetLog("Check BB BuilderMenu, Opened", $COLOR_SUCCESS)
		$b_WindowOpened = True
	Else
		For $i = 1 To $Counter
			If Not $g_bRunState Then Return
			SetLog("BB BuilderMenu Closed, trying again!", $COLOR_DEBUG)
			Click(466, 30)
			If _Sleep(1000) Then Return
			If IsBBBuilderMenuOpen() Then
				$b_WindowOpened = True
				ExitLoop
			EndIf
		Next
	EndIf
	
	If Not $b_WindowOpened Then SetLog("Something wrong with BB BuilderMenu, already tried 3 times!", $COLOR_DEBUG)
	Return $b_WindowOpened
EndFunc ;==>ClickBBBuilder

Func ClickDragAutoUpgradeBB($Direction = "up", $YY = Default, $DragCount = 1)
	Local $x = 450, $yUp = 125, $yDown = 800, $Delay = 500
	ClickBBBuilder()
	If $YY = Default And $Direction = "up" Then
		Local $Tmp = QuickMIS("CNX", $g_sImgBBResourceIcon, 500, 73, 600, 370)
		If IsArray($Tmp) And UBound($Tmp) > 0 Then
			$YY = _ArrayMax($Tmp, 1, 0, -1, 2)
			SetDebugLog("DragUpY = " & $YY)
			If Number($YY) < 300 Then
				SetLog("No need to dragUp!", $COLOR_INFO)
				Return False
			EndIf
		Else
			$YY = 150
		EndIf
	EndIf
	If Not $g_bRunState Then Return
	For $z = 1 To 2
		If Not $g_bRunState Then Return
		If IsBBBuilderMenuOpen() Then ;check upgrade window border
			Switch $Direction
				Case "Up"
					If $DragCount > 1 Then
						For $i = 1 To $DragCount
							ClickDrag($x, $YY, $x, $yUp, $Delay) ;drag up
						Next
					Else
						ClickDrag($x, $YY, $x, $yUp, $Delay) ;drag up
					EndIf
					If _Sleep(3000) Then Return
				Case "Down"
					ClickDrag($x, $yUp, $x, $yDown, $Delay) ;drag to bottom
					If WaitforPixel(510, 90, 515, 95, "FFFFFF", 10, 2, "ClickDragAutoUpgradeBB") Then
						ClickDrag($x, $yUp, $x, $yDown, $Delay) ;drag to bottom
					EndIf
					If _Sleep(3000) Then Return
			EndSwitch
		EndIf
		If IsBBBuilderMenuOpen() Then ;check upgrade window border
			SetLog("Upgrade Window Exist", $COLOR_INFO)
			Return True
		Else
			SetLog("Upgrade Window Gone!", $COLOR_DEBUG)
			ClickBBBuilder()
			If _Sleep(1000) Then Return
		EndIf
	Next
	Return False
EndFunc

Func IsBBBuilderMenuOpen()
	Local $bRet = False
	Local $aBorder0[4] = [490, 73, 0xFFFFFF, 40]
	Local $aBorder1[4] = [530, 73, 0xFFFFFF, 40]
	
	If _CheckPixel($aBorder0, True) And _CheckPixel($aBorder1, True) Then
		$bRet = True ;got correct color for border
	Else
		If $g_bDebugSetLog Then SetLog("IsBuilderMenuOpen Border0 Color Not Matched: " & _GetPixelColor($aBorder0[0], $aBorder0[1], True), $COLOR_DEBUG1)
		If $g_bDebugSetLog Then SetLog("IsBuilderMenuOpen Border1 Color Not Matched: " & _GetPixelColor($aBorder1[0], $aBorder1[1], True), $COLOR_DEBUG1)
	EndIf

	Return $bRet
EndFunc ;IsBBBuilderMenuOpen

Func getMostBottomCostBB()
	Local $TmpUpgradeCost, $TmpName, $ret
	Local $Icon = QuickMIS("CNX", $g_sImgBBResourceIcon, 500, 130, 630, 380)
	If IsArray($Icon) And UBound($Icon) > 0 Then
		_ArraySort($Icon, 1, 0, 0, 2) ;sort by y coord desc
		$TmpUpgradeCost = getOcrAndCapture("coc-buildermenu-cost", $Icon[0][1], $Icon[0][2] - 12, 120, 20, True) ;check most bottom upgrade cost
		$TmpName = getBuildingName($Icon[0][1] - 180, $Icon[0][2] - 10)
		$ret = $TmpName[0] & "|" & $TmpUpgradeCost
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
			Local $aUpgradeName = getBuildingName($Progress[$i][1] - 180, $Progress[$i][2] - 5) ;get upgrade name and amount
			If StringInStr($aUpgradeName[0], "Hall", 1) Then
				$bRet = True
				ExitLoop
			EndIf
		Next
	EndIf
	Return $bRet
EndFunc

Func WaitBBUpgradeWindow()
	Local $bRet = False
	For $i = 1 To 5
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
	If Not $bRet Then SetLog("Cannot verify Upgrade Window", $COLOR_ERROR)
	Return $bRet
EndFunc
