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
	If $bTest Then $g_iFreeBuilderCount = 1
	If $g_iFreeBuilderCount < 1 Then Return

	If $g_iFreeBuilderCount = 0 Then
		SetLog("No builder available, Upgrade Walls skipped", $COLOR_DEBUG)
		Return
	EndIf

	If $g_iFreeBuilderCount > 0 Then $GoUpgrade = True
	If $g_bChkOnly1Builder And $g_iFreeBuilderCount > 1 Then
		SetLog("Have more than 1 builder, Upgrade Walls skipped", $COLOR_DEBUG)
		Return
	EndIf
	Local $aIsResourceAvail = WallCheckResource($iWallCost, $iWallLevel)
	SetDebugLog(_ArrayToString($aIsResourceAvail))
	If Not $aIsResourceAvail[0] Then Return

	If Not $g_bRunState Then Return
	If $GoUpgrade And $g_bUpgradeLowWall Then
		UpgradeLowLevelWall($bTest)
	EndIf

	If Not $g_bRunState Then Return
	If $GoUpgrade And Not $g_bUpgradeAnyWallLevel Then
		ClickAway()
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
				If $searchcount > 1 Then ExitLoop 2
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
					Case 2 ;Elixir then Gold
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

				ClickAway()
				VillageReport(True, True)
				$MinWallGold = IsGoldEnough($iWallCost)
				$MinWallElixir = IsElixEnough($iWallCost)
				If Not $MinWallGold And $MinWallElixir Then ExitLoop
			Wend
		Next
	EndIf
	CheckMainScreen(False, False, "UpgradeWall")
EndFunc   ;==>UpgradeWall

Func WallCheckResource($Cost = $g_aiWallCost[$g_aUpgradeWall[0]], $iWallLevel = $g_aUpgradeWall[0]+4)
	$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(701, 23) ;get current Gold
	$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(701, 74) ;get current Elixir
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
		Case 2 ;Elixir then Gold
			Local $HaveGold = IsGoldEnough($Cost)
			Local $HaveElix = IsElixEnough($Cost)
			If Number($iWallLevel) > 7 Then
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
	Return $aRet
EndFunc

Func WallUpgradeCheckBuilder($bTest)
	Local $bRet = False
	getBuilderCount(True)
	If $bTest Then
		$bRet = True
	Else
		If $g_iFreeBuilderCount < 1 Then
			$bRet = False
		Else
			$bRet = True
		EndIf
	EndIf
	Return $bRet
EndFunc

Func UpgradeLowLevelWall($bTest = False)
	If Not $g_bRunState Then Return
	SetLog("Upgrade LowLevel Wall using autoupgrade enabled", $COLOR_DEBUG)
	VillageReport(True, True) ;update village resource capacity
	ClickMainBuilder()
	Local $aWallCoord, $Try = 1
	While True
		If Not $g_bRunState Then Return
		If Not WallUpgradeCheckBuilder($bTest) Then Return
		If $Try > 3 Then ExitLoop
		$Try += 1
		SetLog("[" & $Try & "] Search Wall on Builder Menu", $COLOR_INFO)
		$aWallCoord = ClickDragFindWallUpgrade()
		If IsArray($aWallCoord) And UBound($aWallCoord) > 0 Then
			Local $aIsEnoughResource = WallCheckResource($aWallCoord[0][2])
			If Not $aIsEnoughResource[0] Then
				SetDebugLog("01-Not WallCheckResource, Exiting")
				ContinueLoop
			EndIf
			TryUpgradeWall($aWallCoord, $bTest)
		Else
			SetLog("[" & $Try & "] Not Found Wall on Builder Menu", $COLOR_ERROR)
		EndIf
	Wend
	ClickDragAUpgrade("down")
	ClickAway()
	SetDebugLog("Upgrade Wall using autoupgrade EXIT", $COLOR_DEBUG)
EndFunc

Func TryUpgradeWall($aWallCoord, $bTest = False)
	Local $UpgradeToLvl = $g_iLowLevelWall
	For $i = 0 To UBound($aWallCoord) - 1
		If Not $g_bRunState Then Return
		If Not WallUpgradeCheckBuilder($bTest) Then Return
		For $j = 1 To 5
			ClickMainBuilder()
			SetLog("Wall " & "[" & $i & "] : [" & $aWallCoord[$i][0] & "," & $aWallCoord[$i][1] & " Cost = " & $aWallCoord[$i][2] & "]", $COLOR_DEBUG)
			Click($aWallCoord[$i][0], $aWallCoord[$i][1])
			If _Sleep(1000) Then Return
			Local $aWallLevel = BuildingInfo(242, 494)
			If $aWallLevel[0] = "" Then
				SetLog("Cannot read building Info, wrong click...", $COLOR_ERROR)
				ContinueLoop 2
			EndIf
			If $aWallLevel[1] = "Wall" Then
				SetDebugLog("is a Wall...", $COLOR_INFO)
			Else
				SetLog("Not Wall, wrong click...", $COLOR_ERROR)
				ExitLoop 2
			EndIf
			If Not $g_bUpgradeAnyWallLevel And $aWallLevel[2] > $UpgradeToLvl Then
				SetLog("Skip this Wall, searching wall level " & $UpgradeToLvl & " and below", $COLOR_ERROR)
				ContinueLoop 2
			EndIf
			SetLog("BuildingInfo: " & $aWallLevel[1] & " Level: " & $aWallLevel[2], $COLOR_SUCCESS)
			Local $aIsEnoughResource = WallCheckResource($aWallCoord[$i][2], $aWallLevel[2])
			If Not $aIsEnoughResource[0] Then ContinueLoop 2
			If DoLowLevelWallUpgrade($aWallLevel[2], $bTest, $aWallCoord[$i][2]) Then
				If _Sleep(1000) Then Return
				ContinueLoop
			Else
				ExitLoop
			EndIf
		Next
	Next
EndFunc

Func DoLowLevelWallUpgrade($WallLevel = 1, $bTest = False, $iWallCost = 1000)
	Local $UpgradeToLvl = $g_iLowLevelWall
	If Not $g_bRunState Then Return
	If $WallLevel >= $UpgradeToLvl And $g_bUpgradeAnyWallLevel Then
		SetLog("Upgrade Any Wall Level", $COLOR_INFO)
		Local $MinWallGold = IsGoldEnough($iWallCost)
		Local $MinWallElixir = IsElixEnough($iWallCost)
		SetDebugLog("$MinWallGold=" & String($MinWallGold) & " $MinWallElixir=" & String($MinWallElixir), $COLOR_INFO)
		Switch $g_iUpgradeWallLootType
			Case 0 ;Gold
				If $MinWallGold Then
					SetLog("Try Upgrade Wall using Gold", $COLOR_INFO)
					If Not UpgradeWallGold($iWallCost, $bTest) Then
						SetLog("Upgrade with Gold failed", $COLOR_ERROR)
						Return False
					Else
						SetLog("Successfully Upgrade a Wall Level " & $WallLevel & " To lvl " & $WallLevel+1, $COLOR_SUCCESS)
					EndIf
				EndIf
			Case 1 ;Elixir
				If $MinWallElixir Then
					SetLog("Try Upgrade Wall using Elixir", $COLOR_INFO)
					If Not UpgradeWallElixir($iWallCost, $bTest) Then
						SetLog("Upgrade with Elixir failed", $COLOR_ERROR)
						Return False
					Else
						SetLog("Successfully Upgrade a Wall Level " & $WallLevel & " To lvl " & $WallLevel+1, $COLOR_SUCCESS)
					EndIf
				EndIf
			Case 2 ;Elixir then Gold
				If $MinWallElixir Then
					SetLog("Try Upgrade Wall using Elixir", $COLOR_INFO)
					If Not UpgradeWallElixir($iWallCost, $bTest) Then
						SetLog("Upgrade with Elixir failed, attempt to upgrade using Gold", $COLOR_INFO)
					Else
						SetLog("Successfully Upgrade a Wall Level " & $WallLevel & " To lvl " & $WallLevel+1, $COLOR_SUCCESS)
						Return True
					EndIf
				EndIf
				If $MinWallGold Then
					SetLog("Try Upgrade Wall using Gold", $COLOR_INFO)
					If Not UpgradeWallGold($iWallCost, $bTest) Then
						SetLog("Upgrade with Gold failed, skip!", $COLOR_ERROR)
						Return False
					EndIf
				Else
					SetLog("Upgrade with Gold failed, not Enough Gold", $COLOR_INFO)
				EndIf
		EndSwitch
		ClickAway()
		Return True
	EndIf
	If Not $g_bRunState Then Return
	If $WallLevel <= $UpgradeToLvl Then
		For $x = $WallLevel To $UpgradeToLvl
			If Not $g_bRunState Then Return
			Local $aIsEnoughResource = WallCheckResource($iWallCost, $x)
			If Not $aIsEnoughResource[0] Then Return
			Local $UpgradeButtonFound = False
			
			Switch $aIsEnoughResource[1]
				Case "Gold"
					$UpgradeButtonFound = QuickMIS("BC1", $g_sImgWallUpgradeGold, 400, 520, 600, 580)
				Case "Elix"
					$UpgradeButtonFound = QuickMIS("BC1", $g_sImgWallUpgradeElix, 400, 520, 600, 580)
			EndSwitch
			
			If $UpgradeButtonFound Then
				Click($g_iQuickMISX, $g_iQuickMISY)
				For $i = 1 To 10
					If QuickMis("BC1", $g_sImgGeneralCloseButton, 660, 80, 820, 200) Then 
						ExitLoop
					Else
						SetDebugLog("Waiting for Wall Upgrade Page #" & $i)
					EndIf
					_Sleep(200)
				Next
				
				If Not $bTest Then
					Click(420, 500)
				Else
					SetLog("Testing Only!", $COLOR_ERROR)
					ClickAway()
					If _Sleep(250) Then Return
					ClickAway()
					Return False
				EndIf
				If IsGemOpen(True) Then
					SetLog("Not Enough Resource...", $COLOR_ERROR)
					Return False
				Else
					SetLog("Successfully Upgrade a Wall Level " & $x & " To lvl " & $x+1, $COLOR_SUCCESS)
				EndIf
			Else
				SetLog("Not Enough Resource...", $COLOR_ERROR)
				ExitLoop
			EndIf
			If _Sleep(500) Then Return
		Next
		ClickAway()
		Return True
	EndIf
EndFunc

Func ClickDragFindWallUpgrade()
	Local $x = 420, $yUp = 120, $Delay = 800
	Local $YY = 345
	Local $TmpUpgradeCost = 0, $UpgradeCost = 0, $sameCost = 0, $aWallCoord
	For $checkCount = 0 To 9
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(350, 73, True), "fdfefd", 20) Then
			ClickDrag($x, $YY, $x, $yUp, $Delay) ;drag up
			If _Sleep(1000) Then Return

			If QuickMIS("BC1", $g_sImgAUpgradeWall, 180, 80, 300, 369, True) Then
				If _Sleep(2000) Then Return
				$aWallCoord = GetWallPos()
				If IsArray($aWallCoord) And UBound($aWallCoord) > 0 Then
					Return $aWallCoord
				EndIf
			EndIf

			$TmpUpgradeCost = getOcrAndCapture("coc-NewCapacity",350, 335, 150, 30, True)
			SetDebugLog("TmpUpgradeCost = " & $TmpUpgradeCost & " UpgradeCost = " & $UpgradeCost, $COLOR_INFO)
			SetDebugLog("sameCost = " & $sameCost, $COLOR_INFO)
			If $UpgradeCost = $TmpUpgradeCost Then $sameCost += 1
			If $sameCost > 3 Then ExitLoop
			$UpgradeCost = $TmpUpgradeCost
		EndIf
		If _ColorCheck(_GetPixelColor(350, 73, True), "fdfefd", 20) Then ;check upgrade window border
			SetDebugLog("Upgrade Window Exist", $COLOR_INFO)
		Else
			SetDebugLog("Upgrade Window Gone!", $COLOR_DEBUG)
			ClickMainBuilder()
		EndIf
	Next
	Return $aWallCoord
EndFunc ;==>IsUpgradeWindow

Func GetWallPos()
	Local $aTmpWallCoord, $aWallCoord[0][3], $aWall, $TmpUpgradeCost = 0, $UpgradeCost = 0
	$aTmpWallCoord = QuickMIS("CX", $g_sImgAUpgradeWall, 180, 80, 300, 369, True)
	If IsArray($aTmpWallCoord) And UBound($aTmpWallCoord) > 0 Then
		SetDebugLog("Found " & UBound($aTmpWallCoord) & " Image Wall")
		For $j = 0 To UBound($aTmpWallCoord) - 1
			$aWall = StringSplit($aTmpWallCoord[$j], ",", $STR_NOCOUNT)
			$UpgradeCost = getOcrAndCapture("coc-NewCapacity",$aWall[0] + 180 + 110, $aWall[1] + 80 - 8, 150, 20, True)
			If Not $UpgradeCost = "" Then
				SetDebugLog("Wall " & $j & " UpgradeCost=" & $UpgradeCost, $COLOR_INFO)
				If $UpgradeCost = "50" Then
					SetDebugLog("Wall " & $j & " is new wall, skip!", $COLOR_INFO)
					ContinueLoop ;skip New Wall
				EndIf
				_ArrayAdd($aWallCoord, $aWall[0]+180 & "|" & $aWall[1]+80 & "|" & $UpgradeCost, Default, Default, Default, $ARRAYFILL_FORCE_NUMBER)
			Else
				SetDebugLog("Wall " & $j & " not enough resource, skip!", $COLOR_DEBUG)
			EndIf
		Next
		_ArraySort($aWallCoord, 0, 0, 0, 2)
		Return $aWallCoord
	Else
		SetDebugLog("Not Array Wall", $COLOR_DEBUG)
	EndIf
EndFunc

Func UpgradeWallGold($iWallCost = $g_iWallCost, $bTest = False)

	;Check for Gold in right top button corner and click, if present
	Local $FoundGold = decodeSingleCoord(findImage("UpgradeWallGold", $g_sImgUpgradeWallGold, GetDiamondFromRect("200, 530, 670, 600"), 1, True))
	If UBound($FoundGold) > 1 Then
		Click($FoundGold[0], $FoundGold[1])
	Else
		SetLog("No Upgrade Gold Button", $COLOR_ERROR)
		Return False
	EndIf

	If _Sleep($DELAYUPGRADEWALLGOLD2) Then Return

	If WaitforPixel(670, 140, 690, 150, Hex(0xFFFFFF, 6), 6, 2) Then ; wall upgrade window red x
		If Not $bTest Then
			Click(440, 500, 1, 0, "#0317")
		Else
			SetLog("Testing Only!", $COLOR_ERROR)
			ClickAway()
		EndIf
		If _Sleep(1000) Then Return
		If isGemOpen(True) Then
			ClickAway()
			SetLog("Upgrade stopped due no loot", $COLOR_ERROR)
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
EndFunc   ;==>UpgradeWallGold

Func UpgradeWallElixir($iWallCost = $g_iWallCost, $bTest = False)

	;Check for elixircolor in right top button corner and click, if present
	Local $FoundElixir = decodeSingleCoord(findImage("UpgradeWallElixir", $g_sImgUpgradeWallElix, GetDiamondFromRect("200, 530, 670, 600"), 1, True, Default))
	If UBound($FoundElixir) > 1 Then
		Click($FoundElixir[0], $FoundElixir[1])
	Else
		SetLog("No Upgrade Elixir Button", $COLOR_ERROR)
		Return False
	EndIf

	If _Sleep($DELAYUPGRADEWALLELIXIR2) Then Return

	If WaitforPixel(670, 140, 690, 150, Hex(0xFFFFFF, 6), 6, 2) Then ; wall upgrade window red x
		If Not $bTest Then
			Click(440, 500, 1, 0, "#0318")
		Else
			SetLog("Testing Only!", $COLOR_ERROR)
			ClickAway()
		EndIf
		If _Sleep(1000) Then Return
		If isGemOpen(True) Then
			SetLog("Upgrade stopped due to insufficient loot", $COLOR_ERROR)
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
EndFunc   ;==>UpgradeWallElixir

Func IsGoldEnough($iWallCost = $g_aUpgradeWall[0])
	Local $EnoughGold = True
	If ($g_aiCurrentLoot[$eLootGold] - $iWallCost) < $g_iUpgradeWallMinGold Then
		$EnoughGold = False
	EndIf
	If Not $EnoughGold Then
		SetDebugLog("[Insufficient Gold] " & $g_aiCurrentLoot[$eLootGold] & " - " & $iWallCost & " = " & ($g_aiCurrentLoot[$eLootGold] - $iWallCost) & " < " & $g_iUpgradeWallMinGold, $COLOR_INFO)
	EndIf
	Return $EnoughGold
EndFunc

Func IsElixEnough($iWallCost = $g_aUpgradeWall[0])
	Local $EnoughElix = True
	If ($g_aiCurrentLoot[$eLootElixir] - $iWallCost) < $g_iUpgradeWallMinElixir Then
		$EnoughElix = False
	EndIf
	If Not $EnoughElix Then
		SetDebugLog("[Insufficient Elixir] " & $g_aiCurrentLoot[$eLootElixir] & " - " & $iWallCost & " = " & ($g_aiCurrentLoot[$eLootElixir] - $iWallCost) & " < " & $g_iUpgradeWallMinElixir, $COLOR_INFO)
	EndIf
	Return $EnoughElix
EndFunc