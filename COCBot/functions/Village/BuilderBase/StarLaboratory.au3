; #FUNCTION# ====================================================================================================================
; Name ..........: StarLaboratory
; Description ...:
; Syntax ........: StarLab()
; Parameters ....:
; Return values .: None
; Author ........: TripleM
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func TestStarLab()
	Local $bWasRunState = $g_bRunState
	Local $sWasStarLabUpgradeTime = $g_sStarLabUpgradeTime
	Local $bWasStarLabUpgradeEnable = $g_bAutoStarLabUpgradeEnable
	$g_bRunState = True
	$g_bAutoStarLabUpgradeEnable = True
	$g_sStarLabUpgradeTime = ""
	Local $Result = StarLab(True)
	$g_bRunState = $bWasRunState
	$g_sStarLabUpgradeTime = $sWasStarLabUpgradeTime
	$g_bAutoStarLabUpgradeEnable = $bWasStarLabUpgradeEnable
	Return $Result
EndFunc

Func StarLab($bTest = False)
	If Not $g_bRunState Then Return
	If Not $g_bAutoStarLabUpgradeEnable Then Return ; Lab upgrade not enabled.
	
	If Not CheckIfSLabIdle() Then Return
	
	Local $bElixirFull = False
	If $g_bChkUpgradeAnyIfAllOrderMaxed Then $bElixirFull = isElixirFullBB()
	BuilderBaseReport(True, True)

	
	;Create local array to hold upgrade values
	Local $iAvailElixir, $sElixirCount, $TimeDiff, $aArray, $Result
	
	$iAvailElixir = Number($g_aiCurrentLootBB[$eLootElixirBB])

	ZoomOutHelperBB("SwitchBetweenBases") ;go to BH LowerZone
	If _Sleep(1000) Then Return

	If Not LocateStarLab() Then Return False

	If Not ClickB("Research") Then
		SetLog("Cannot find the Star Laboratory Research Button!", $COLOR_ERROR)
		ClickAway("Left")
		Return False
	EndIf

	Local $bWindowOpened = False
	For $i = 1 To 5
		If $g_bDebugSetLog Then SetLog("Waiting For Star Laboratory Window #" & $i, $COLOR_ACTION)
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 760, 40, 820, 80) Then
			$bWindowOpened = True
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return ;add delay to wait lab window opened
	Next

	If Not $bWindowOpened Then
		SetLog("Star Laboratory Window Not Opened", $COLOR_ERROR)
		Return
	EndIf

	If WaitForPixel(795, 122, 796, 124, "A2CB6C", 10, 1, "StarLab") Then
		SetLog("Laboratory Upgrade in progress, waiting for completion", $COLOR_INFO)
		Local $sLabTimeOCR = getRemainTLaboratory(225, 202)
		Local $iLabFinishTime = ConvertOCRTime("Lab Time", $sLabTimeOCR, False)
		If $g_bDebugSetLog Then SetLog("$sLabTimeOCR: " & $sLabTimeOCR & ", $iLabFinishTime = " & $iLabFinishTime & " m")
		If $iLabFinishTime > 0 Then
			$g_sStarLabUpgradeTime = _DateAdd('n', Ceiling($iLabFinishTime), _NowCalc())
			If @error Then _logErrorDateAdd(@error)
			SetLog("Research will finish in " & $sLabTimeOCR & " (" & $g_sStarLabUpgradeTime & ")")
			ClickAway("Left")
			Return True
		EndIf
		If Not $bTest Then Return False
	EndIf

	Local $bAnyUpgradeOn = True
	Local $aTroopUpgrade = FindSLabTroopsUpgrade()
	If IsArray($aTroopUpgrade) And UBound($aTroopUpgrade) > 0 Then
		For $i = 0 To UBound($aTroopUpgrade) -1
			SetDebugLog("[" & $aTroopUpgrade[$i][0] & "]" & " Coord:[" & $aTroopUpgrade[$i][3] & "," & $aTroopUpgrade[$i][4] & "] Troop: " & $aTroopUpgrade[$i][2] & " Cost: " & $aTroopUpgrade[$i][5])
		Next
		If $g_iCmbStarLaboratory = 0 And $g_bSLabUpgradeOrderEnable Then ;Any Upgrade, enable order
			SetLog("StarLab Upgrade Order Enabled", $COLOR_INFO)
			For $z = 0 To UBound($g_aCmbSLabUpgradeOrder) - 1
				If $g_aCmbSLabUpgradeOrder[$z] = -1 Then ContinueLoop
				SetLog("Priority Upgrade [" & $z + 1 & "]: " & $g_avStarLabTroops[$g_aCmbSLabUpgradeOrder[$z]+1][3])
			Next
			Local $iIndex
			For $z = 0 To UBound($g_aCmbSLabUpgradeOrder) - 1 ; list of lab upgrade order
				If $g_aCmbSLabUpgradeOrder[$z] < 0 Then ContinueLoop
				Local $Index = _ArraySearch($aTroopUpgrade, $g_aCmbSLabUpgradeOrder[$z]+1, 0, 0, 0, 0, 1, 0)
				SetDebugLog("Search for : " & $g_aCmbSLabUpgradeOrder[$z]+1 & " And Found at :" & $Index)
				If Not @error And $Index > -1 Then
					SetLog("Try Upgrade [" & $z + 1 & "]: " & $aTroopUpgrade[$Index][2], $COLOR_ACTION)
					If $aTroopUpgrade[$Index][5] = "MaxLevel" Then
						SetLog("[" & $z + 1 & "]: " & $aTroopUpgrade[$Index][2] & " at Max Level, skip!", $COLOR_INFO)
						ContinueLoop
					EndIf
					If $aTroopUpgrade[$Index][5] = "NeedUpgradeLab" Then
						SetLog("[" & $z + 1 & "]: " & $aTroopUpgrade[$Index][2] & " Higher StarLab Level Required, skip!", $COLOR_INFO)
						$bAnyUpgradeOn = False
						ContinueLoop
					EndIf
					If $iAvailElixir < $aTroopUpgrade[$Index][5] Then
						SetLog("[" & $z + 1 & "]: " & $aTroopUpgrade[$Index][2] & " Insufficient Elixir, skip!", $COLOR_INFO)
						SetLog("Upgrade Cost = " & $aTroopUpgrade[$Index][5] & " Available = " & $iAvailElixir, $COLOR_INFO)
						$bAnyUpgradeOn = False
						ContinueLoop
					EndIf
					If SLabUpgrade($aTroopUpgrade[$Index][2], $aTroopUpgrade[$Index][3], $aTroopUpgrade[$Index][4], $bTest) Then
						SetLog("Elixir used = " & $aTroopUpgrade[$Index][5], $COLOR_INFO)
						ClickAway("Left")
						Return True
					EndIf
				Else
					SetLog("[" & $z + 1 & "] Cannot upgrade " & $g_avStarLabTroops[$g_aCmbSLabUpgradeOrder[$z]+1][3] & " at this moment!", $COLOR_DEBUG)
				EndIf
			Next
		EndIf

		If $g_iCmbStarLaboratory = 0 And Not $g_bSLabUpgradeOrderEnable Then ;any upgrade
			_ArraySort($aTroopUpgrade, 0, 0, 0, 5)
			For $i = 0 To UBound($aTroopUpgrade) - 1
				If $aTroopUpgrade[$i][5] = "MaxLevel" Then ContinueLoop
				If $aTroopUpgrade[$i][5] = "NeedUpgradeLab" Then ContinueLoop
				If $iAvailElixir < $aTroopUpgrade[$i][5] Then
					SetLog("[" & $i + 1 & "]: " & $aTroopUpgrade[$i][2] & " Insufficient Elixir, skip!", $COLOR_INFO)
					SetLog("Upgrade Cost = " & $aTroopUpgrade[$i][5] & " Available = " & $iAvailElixir, $COLOR_INFO)
					ContinueLoop
				EndIf
				SetLog("Try Upgrade " & $aTroopUpgrade[$i][2] & " Cost=" & $aTroopUpgrade[$i][5], $COLOR_ACTION)
				If SLabUpgrade($aTroopUpgrade[$i][2], $aTroopUpgrade[$i][3], $aTroopUpgrade[$i][4], $bTest) Then
					SetLog("Elixir used = " & $aTroopUpgrade[$i][5], $COLOR_INFO)
					ClickAway("Left")
					Return True
				EndIf
			Next
		EndIf

		If $g_iCmbStarLaboratory > 0 Then ;selected upgrade
			Local $Index = _ArraySearch($aTroopUpgrade, $g_iCmbStarLaboratory, 0, 0, 0, 0, 1, 0)
			If Not @error And $Index > -1 Then
				SetDebugLog("Search for : " & $g_iCmbStarLaboratory & " And Found at :" & $Index)
				SetLog("Try Upgrade: " & $aTroopUpgrade[$Index][2])
				If $aTroopUpgrade[$Index][5] = "MaxLevel" Then
					SetLog($aTroopUpgrade[$Index][2] & " at Max Level, skip!", $COLOR_INFO)
					ClickAway("Left")
					Return False
				EndIf
				If $aTroopUpgrade[$Index][5] = "NeedUpgradeLab" Then
					SetLog($aTroopUpgrade[$Index][2] & " Higher StarLab Level Required, skip!", $COLOR_INFO)
					ClickAway("Left")
					Return False
				EndIf
				If $iAvailElixir < $aTroopUpgrade[$Index][5] Then
					SetLog($aTroopUpgrade[$Index][2] & " Insufficient Elixir, skip!", $COLOR_INFO)
					SetLog("Upgrade Cost = " & $aTroopUpgrade[$Index][5] & " Available = " & $iAvailElixir, $COLOR_INFO)
					ClickAway("Left")
					Return False
				EndIf
				If SLabUpgrade($aTroopUpgrade[$Index][2], $aTroopUpgrade[$Index][3], $aTroopUpgrade[$Index][4], $bTest) Then
					SetLog("Elixir used = " & $aTroopUpgrade[$Index][5], $COLOR_INFO)
					ClickAway("Left")
					Return True
				EndIf
			Else
				SetLog("Selected Upgrade: " & $g_avStarLabTroops[$g_iCmbStarLaboratory][3] & " Is not Upgradable!", $COLOR_DEBUG)
			EndIf
		EndIf

		;any upgrade if all on troops lab order is maxed
		If $g_bDebugSetLog Then SetLog("g_iCmbStarLaboratory=" & $g_iCmbStarLaboratory & " g_bSLabUpgradeOrderEnable=" & $g_bSLabUpgradeOrderEnable & " bAnyUpgradeOn=" & $bAnyUpgradeOn & " g_bisBattleMachineMaxed=" & $g_bisBattleMachineMaxed & " g_bIs6thBuilderUnlocked=" & $g_bIs6thBuilderUnlocked & " bElixirFull=" & $bElixirFull, $COLOR_DEBUG)
		If $g_iCmbStarLaboratory = 0 And $g_bSLabUpgradeOrderEnable And $g_bChkUpgradeAnyIfAllOrderMaxed And $bAnyUpgradeOn And ($g_bisBattleMachineMaxed Or $g_bIs6thBuilderUnlocked Or $bElixirFull) Then
			_ArraySort($aTroopUpgrade, 1, 0, 0, 5) ;sort by cost descending
			For $i = 0 To UBound($aTroopUpgrade) - 1
				If $aTroopUpgrade[$i][5] = "MaxLevel" Then ContinueLoop
				If $aTroopUpgrade[$i][5] = "NeedUpgradeLab" Then ExitLoop
				If $iAvailElixir < $aTroopUpgrade[$i][5] Then
					SetLog("[" & $i + 1 & "]: " & $aTroopUpgrade[$i][2] & " Insufficient Elixir, skip!", $COLOR_INFO)
					SetLog("Upgrade Cost = " & $aTroopUpgrade[$i][5] & " Available = " & $iAvailElixir, $COLOR_INFO)
					ContinueLoop
				EndIf
				SetLog("Try Upgrade " & $aTroopUpgrade[$i][2] & " Cost=" & $aTroopUpgrade[$i][5], $COLOR_ACTION)
				If SLabUpgrade($aTroopUpgrade[$i][2], $aTroopUpgrade[$i][3], $aTroopUpgrade[$i][4], $bTest) Then
					SetLog("Elixir used = " & $aTroopUpgrade[$i][5], $COLOR_INFO)
					ClickAway("Left")
					Return True
				EndIf
			Next
		EndIf
	Else
		SetLog("No upgradable troop found!", $COLOR_ERROR)
		ClickAway("Left")
		If _Sleep(1000) Then Return ;wait window closed
		Return False
	EndIf
	ClickAway("Left")
	Return False
EndFunc   ;==>Laboratory

Func SLabUpgrade($UpgradeName, $x, $y, $bTest)
	Local $bRet = False, $Result
	Click($x, $y)
	If _Sleep(1000) Then Return

	$Result = getLabUpgradeTime(590, 493) ; Try to read white text showing time for upgrade
	Local $iLabFinishTime = ConvertOCRTime("Lab Time", $Result, False)
	SetLog($UpgradeName & " Upgrade OCR Time = " & $Result & ", $iLabFinishTime = " & $iLabFinishTime & " m", $COLOR_INFO)

	If Not $bTest Then Click(695, 585) ;click Upgrade
	If _Sleep(1000) Then Return ;wait if Gem window open

	If isGemOpen(True) Then ; check for gem window
		SetLog("Oops, Gems required for " & $UpgradeName & " Upgrade, try again.", $COLOR_ERROR)
		If _Sleep(1000) Then Return
		Click(133,117) ;click Cancel
		$bRet = False
	Else
		SetLog("Upgrade " & $UpgradeName & " in your star laboratory started with success...", $COLOR_SUCCESS)
		PushMsg("StarLabSuccess")
		ClickAway("Left")
		If _Sleep($DELAYLABUPGRADE2) Then Return
		$bRet = True
	EndIf

	If $bRet Then
		Local $StartTime = _NowCalc() ; what is date:time now
		SetDebugLog($UpgradeName & " Upgrade Started @ " & $StartTime, $COLOR_SUCCESS)
		If $iLabFinishTime > 0 Then
			$g_sStarLabUpgradeTime = _DateAdd('n', Ceiling($iLabFinishTime), $StartTime)
			SetLog($UpgradeName & " Upgrade Finishes @ " & $Result & " (" & $g_sStarLabUpgradeTime & ")", $COLOR_SUCCESS)
		EndIf
	EndIf
	If _Sleep(1000) Then Return
	Return $bRet
EndFunc

Func CheckIfSLabIdle($bDebug = False)
	Local $aLabInfo, $aGetLab, $bRet = True
	If $bDebug Then Return $bRet
	
	$aLabInfo = getBuilders(372, 23)
	If StringInStr($aLabInfo, "#") > 0 Then
		$aGetLab = StringSplit($aLabInfo, "#", $STR_NOCOUNT)
		Local $iLab = Number($aGetLab[0]), $iLabMax = Number($aGetLab[1])
		Select 
			Case $iLab = 0 And $iLabMax = 1
				SetLog("CheckIfSLabIdle: SLab is Working on Upgrade", $COLOR_DEBUG)
				$bRet = False
			Case $iLab = 1 And $iLabMax = 2
				SetLog("CheckIfSLabIdle: SLab is Working on Upgrade", $COLOR_DEBUG)
				$bRet = False
			Case $iLab = 1 And $iLabMax >= 1
				SetLog("CheckIfSLabIdle: SLab is Idle", $COLOR_DEBUG)
				$bRet = True
		EndSelect
	EndIf
	
	If $bRet Then ;if Lab is idle, check resource is enough to upgrade
		ClickP($aLabMenu)
		If _Sleep(500) Then Return
		Local $aUpgradeName
		Local $aTmpCoord = QuickMIS("CNX", $g_sImgBBResourceIcon, 390, 70, 460, 380)
		If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
			_ArraySort($aTmpCoord, 0, 0, 0, 2)
			For $i = 0 To UBound($aTmpCoord) - 1
				If _PixelSearch($aTmpCoord[$i][1] + 10, $aTmpCoord[$i][2], $aTmpCoord[$i][1] + 20, $aTmpCoord[$i][2], Hex(0xFF887F, 6), 10, 1, "Check Red Resource cost") Then
					SetLog("Detected Not Enough Resource for LabUpgrade " & $aTmpCoord[$i][0] & " on : " & $aTmpCoord[$i][1] & "," & $aTmpCoord[$i][2], $COLOR_DEBUG)
					$bRet = False
				ElseIf _PixelSearch($aTmpCoord[$i][1] + 10, $aTmpCoord[$i][2], $aTmpCoord[$i][1] + 20, $aTmpCoord[$i][2], Hex(0xFFFFFF, 6), 10, 1, "Check White Resource cost") Then
					SetLog("Detected possible LabUpgrade " & $aTmpCoord[$i][0] & " on : " & $aTmpCoord[$i][1] & "," & $aTmpCoord[$i][2], $COLOR_DEBUG)
					$bRet = True
				EndIf
				If $aTmpCoord[$i][0] = "Complete" Then
					SetLog("All Upgrade Complete", $COLOR_DEBUG)
					$bRet = False
				EndIf
			Next
		EndIf
	EndIf
	
	Return $bRet
EndFunc

Func getMostBottomCostSLab()
	Local $TmpUpgradeCost, $TmpName, $ret
	Local $Icon = QuickMIS("CNX", $g_sImgBBResourceIcon, 380, 130, 500, 380)
	If IsArray($Icon) And UBound($Icon) > 0 Then
		_ArraySort($Icon, 1, 0, 0, 2) ;sort by y coord desc
		$TmpUpgradeCost = getOcrAndCapture("coc-buildermenu-cost", $Icon[0][1], $Icon[0][2] - 12, 120, 20, True) ;check most bottom upgrade cost
		$TmpName = getBuildingName($Icon[0][1] - 180, $Icon[0][2] - 10)
		$ret = $TmpName[0] & "|" & $TmpUpgradeCost
	EndIf
	Return $ret
EndFunc ;getMostBottomCostSLab

Func IsSLabMenuOpen()
	Local $bRet = False
	Local $aBorder0[4] = [374, 74, 0x8F9590, 40]

	If _CheckPixel($aBorder0, True) Then
		$bRet = True ;got correct color for border
	Else
		If $g_bDebugSetLog Then SetLog("IsBuilderMenuOpen Border0 Color Not Matched: " & _GetPixelColor($aBorder0[0], $aBorder0[1], True), $COLOR_DEBUG1)
	EndIf

	Return $bRet
EndFunc ;IsSLabMenuOpen

Func ClickSLabMenu($Counter = 3)
	Local $b_Ret = False
	If Not $g_bRunState Then Return

	; open the builders menu
	If Not IsSLabMenuOpen() Then
		SetLog("Opening Star Lab Menu", $COLOR_ACTION)
		Click(340, 30)
		If _Sleep(1000) Then Return
	EndIf

	;check
	If IsSLabMenuOpen() Then
		SetLog("Check Star Lab Menu, Opened", $COLOR_SUCCESS)
		$b_Ret = True
	Else
		For $i = 1 To $Counter
			If Not $g_bRunState Then Return
			SetLog("Star Lab Closed, trying again!", $COLOR_DEBUG)
			Click(340, 30)
			If _Sleep(1000) Then Return
			If IsSLabMenuOpen() Then
				$b_Ret = True
				ExitLoop
			EndIf
		Next
	EndIf

	If Not $b_Ret Then SetLog("Something wrong with Star Lab Menu, already tried 3 times!", $COLOR_DEBUG)
	Return $b_Ret
EndFunc ;==>ClickSLabMenu

Func _SearchSLabUpgrade($bTest = False)
	Local $ZoomedIn = False, $bNew = False, $bSkipNew = False
	Local $NeedDrag = True, $TmpUpgradeCost = 0, $UpgradeCost = 0, $sameCost

	For $z = 1 To 8 ;do scroll 8 times
		If Not ClickSLabMenu() Then Return
		If _Sleep(500) Then Return
		$TmpUpgradeCost = getMostBottomCostSLab() ;check most bottom upgrade cost
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
			If IsSLabMenuOpen() Then Click(340, 30)
			ExitLoop
		EndIf
		$bNew = False ;reset
		Local $Upgrades = FindSLabUpgrade($bTest)
		If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
			SetLog("SLab Upgrade List:", $COLOR_INFO)
			If Not $g_bRunState Then Return
			If $g_iCmbStarLaboratory = 0 Then
				If $g_bSLabUpgradeOrderEnable Then ;Any Upgrade, enable order
					For $i = 0 To UBound($Upgrades) - 1
						Local $sUpgradeName = $Upgrades[$i][3]
						For $z = 0 To UBound($g_aCmbSLabUpgradeOrder) - 1
							If $g_aCmbSLabUpgradeOrder[$z] = -1 Then ContinueLoop
							SetLog("Priority Upgrade [" & $z + 1 & "]: " & $g_avStarLabTroops[$g_aCmbSLabUpgradeOrder[$z]+1][3])
						Next
					Next
				Else
					;user choice
				EndIf
			EndIf
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

Global $g_iXFindSLabUpgrade = 270

Func FindSLabUpgrade($bTest = False)
	Local $ElixMultiply = 1, $GoldMultiply = 1 ;used for multiply score
	Local $Gold = $g_aiCurrentLootBB[$eLootGoldBB]
	Local $Elix = $g_aiCurrentLootBB[$eLootElixirBB]
	If $Gold > $Elix Then $GoldMultiply += 1
	If $Elix > $Gold Then $ElixMultiply += 1

	Local $aPriority = $g_aCmbSLabUpgradeOrder

	Local $aTmpCoord, $aBuilding[0][8], $BuildingName, $aUpgradeName, $tmpcost, $lenght = 0, $sCostType = ""

	$aTmpCoord = QuickMIS("CNX", $g_sImgBBResourceIcon, 380, 73, 500, 400)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			$lenght = Number($aTmpCoord[$i][1]) - $g_iXFindSLabUpgrade
			$aUpgradeName = getBuildingName($g_iXFindSLabUpgrade, $aTmpCoord[$i][2] - 12, $lenght) ;get upgrade name and amount
			$tmpcost = getBuilderMenuCost($aTmpCoord[$i][1], $aTmpCoord[$i][2] - 10)
			If Number($tmpcost) = 0 Then ContinueLoop
			$sCostType = $aTmpCoord[$i][0]
			Local $tmparray[1][8] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1]), Number($aTmpCoord[$i][2]), String($aUpgradeName[0]), Number($aUpgradeName[1]), Number($tmpcost), 0, "Common"]]

			If $g_iCmbStarLaboratory = 0 And $g_bSLabUpgradeOrderEnable Then ;Any Upgrade, enable order
				For $z = 0 To UBound($aPriority) - 1
					If $aPriority[$z] = -1 Then ContinueLoop
					Local $iIndex = $g_avStarLabTroops[$aPriority[$z]][0]
				Next


				For $j = 0 To UBound($g_avStarLabTroops) - 1
					If String($aUpgradeName[0]) = $g_avStarLabTroops[$j][3] Then
						For $z = 0 To UBound($aPriority) - 1
							;If $aPriority[$z]
							;$tmparray[0][7] = "Priority"
						Next
					EndIf
				Next
			EndIf

			_ArrayAdd($aBuilding, $tmparray)
			If @error Then SetLog("FindUpgrade ComposeArray Err : " & @error, $COLOR_ERROR)
		Next

		For $j = 0 To UBound($aBuilding) -1
			If $g_bDebugSetLog Then SetLog("[" & $j & "] Building: " & $BuildingName & ", Cost=" & $aBuilding[$j][5] & " Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG)
		Next
	EndIf

	_ArraySort($aBuilding, 1, 0, 0, 6) ;sort by score
	Return $aBuilding
EndFunc

Func FindSLabTroopsUpgrade()
	Local $aResult[0][6], $UpgradeCost, $aTroop
	Local $aTmp = QuickMIS("CNX", $g_sImgStarLabTroops, 35, 350, 785, 560)
	If IsArray($aTmp) And UBound($aTmp) > 0 Then
		For $i = 0 To UBound($aTmp) -1
			$aTroop = GetSLabTroopResPos($aTmp[$i][0])
			$UpgradeCost = getSLabCost($aTroop[1], $aTroop[2])
			If (StringInStr($UpgradeCost, "M") Or StringInStr($UpgradeCost, "L") Or $UpgradeCost = "1" Or StringInStr($UpgradeCost, "x")) Then $UpgradeCost = "MaxLevel"
			If $UpgradeCost = "" Then
				If QuickMIS("BC1", $g_sImgStarLabNeedUp, $aTroop[1], $aTroop[2], $aTroop[1] + 100, $aTroop[2] + 20) Then
					$UpgradeCost = "NeedUpgradeLab"
				EndIf
			EndIf
			_ArrayAdd($aResult, Number($aTroop[3]) & "|" & $aTmp[$i][0] & "|" & $aTroop[0] & "|" & $aTmp[$i][1] & "|" & $aTmp[$i][2] & "|" & $UpgradeCost)
		Next
		_ArraySort($aResult)
	EndIf
	Return $aResult
EndFunc

Func GetSLabTroopResPos($Troop)
	Local $aResult[4]
	For $i = 1 To UBound($g_avStarLabTroops) - 1
		If $Troop = $g_avStarLabTroops[$i][5] Then
			$aResult[0] = $g_avStarLabTroops[$i][3]
			$aResult[1] = $g_avStarLabTroops[$i][0]
			$aResult[2] = $g_avStarLabTroops[$i][1]
			$aResult[3] = $i
		EndIf
	Next
	Return $aResult
EndFunc   ;==>FullNametroops

Func LocateStarLab()

	If $g_aiStarLaboratoryPos[0] > 0 And $g_aiStarLaboratoryPos[1] > 0 Then
		ClickP($g_aiStarLaboratoryPos)
		If _Sleep($DELAYLABORATORY1) Then Return ; Wait for description to popup

		Local $aResult = BuildingInfo(242, 477) ; Get building name and level with OCR
		If $aResult[0] = 2 Then ; We found a valid building name
			If StringInStr($aResult[1], "Lab") = True Then ; we found the Star Laboratory
				SetLog("Star Laboratory located.", $COLOR_INFO)
				SetLog("It reads as Level " & $aResult[2] & ".", $COLOR_INFO)
				Return True
			EndIf
		Else
			ClickAway("Left")
			ZoomOutHelperBB("SwitchBetweenBases") ;go to BH LowerZone
			SetDebugLog("Stored Star Laboratory Position is not valid.", $COLOR_ERROR)
			$g_aiStarLaboratoryPos[0] = -1
			$g_aiStarLaboratoryPos[1] = -1
		EndIf
		If _Sleep(1000) Then Return ; Wait for description to popup
	EndIf

	If QuickMis("BC1", $g_sImgStarLaboratory) Then
		Click($g_iQuickMISX + 10, $g_iQuickMISY + 20)
		$g_aiStarLaboratoryPos[0] = $g_iQuickMISX + 10
		$g_aiStarLaboratoryPos[1] = $g_iQuickMISY + 20
		If _Sleep(1000) Then Return
		Local $aResult = BuildingInfo(242, 477) ; Get building name and level with OCR
		If $aResult[0] = 2 Then ; We found a valid building name
			If StringInStr($aResult[1], "Lab") Then ; we found the Star Laboratory
				SetLog("Star Laboratory located.", $COLOR_INFO)
				SetLog("It reads as Level " & $aResult[2] & ".", $COLOR_INFO)
				Return True
			EndIf
		EndIf
	EndIf

	SetLog("Can not find Star Laboratory.", $COLOR_ERROR)
	Return False
EndFunc   ;==>LocateStarLab()

