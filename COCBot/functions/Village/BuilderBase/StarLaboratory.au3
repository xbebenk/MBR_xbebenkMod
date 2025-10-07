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

Global $g_iXFindSLabUpgrade = 270

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
		ClickSLabMenu()
		If _Sleep(50) Then Return
		Local $aUpgradeName
		Local $aTmpCoord = QuickMIS("CNX", $g_sImgBBResourceIcon, 390, 70, 460, 380)
		If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
			_ArraySort($aTmpCoord, 0, 0, 0, 2)
			For $i = 0 To UBound($aTmpCoord) - 1
				If $aTmpCoord[$i][0] = "Complete" Then
					SetLog("All Upgrade Complete", $COLOR_DEBUG)
					$bRet = False
					ExitLoop
				EndIf
				
				If _PixelSearch($aTmpCoord[$i][1] + 10, $aTmpCoord[$i][2], $aTmpCoord[$i][1] + 20, $aTmpCoord[$i][2], Hex(0xFFFFFF, 6), 10, 1, "Check White Resource cost") Then
					SetLog("Detected possible SLabUpgrade " & $aTmpCoord[$i][0] & " on : " & $aTmpCoord[$i][1] & "," & $aTmpCoord[$i][2], $COLOR_DEBUG)
					$bRet = True
					ExitLoop
				ElseIf _PixelSearch($aTmpCoord[$i][1] + 10, $aTmpCoord[$i][2], $aTmpCoord[$i][1] + 20, $aTmpCoord[$i][2], Hex(0xFF887F, 6), 10, 1, "Check Red Resource cost") Then
					SetLog("Detected Not Enough Resource for SLabUpgrade " & $aTmpCoord[$i][0] & " on : " & $aTmpCoord[$i][1] & "," & $aTmpCoord[$i][2], $COLOR_DEBUG)
					$bRet = False
				EndIf
			Next
		EndIf
	EndIf
	
	Return $bRet
EndFunc

Func IsSLabMenuOpen()
	Local $bRet = False
	
	If _ColorCheck(_GetPixelColor(374, 74, True), Hex(0x8F9590, 6), 40, Default, "IsSLabMenuOpen") Then 
		$bRet = True
	Else
		SetLog("IsSLabMenuOpen Color Not Matched, expexted 8F9590, found : " & _GetPixelColor(374, 74, True), $COLOR_DEBUG2)
	EndIf
	
	Return $bRet
EndFunc ;IsSLabMenuOpen

Func ClickSLabMenu($Counter = 3)
	Local $b_Ret = False
	If Not $g_bRunState Then Return

	; open the Slab menu
	If Not IsSLabMenuOpen() Then
		SetLog("Opening Star Lab Menu", $COLOR_ACTION)
		Click(340, 30)
		If _Sleep(500) Then Return
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
			If _Sleep(500) Then Return
			If IsSLabMenuOpen() Then
				$b_Ret = True
				ExitLoop
			EndIf
		Next
	EndIf

	If Not $b_Ret Then SetLog("Something wrong with Star Lab Menu, already tried 3 times!", $COLOR_DEBUG)
	Return $b_Ret
EndFunc ;==>ClickSLabMenu

Func SLabUpgrade($UpgradeName, $x, $y, $bTest)
	Local $bRet = False, $Result
	
	Click($x, $y)
	If _Sleep(1000) Then Return

	If Not $bTest Then Click(695, 585) ;click Upgrade
	If _Sleep(1000) Then Return ;wait if Gem window open

	If isGemOpen(True) Then ; check for gem window
		SetLog("Oops, Gems required for " & $UpgradeName & " Upgrade, try again.", $COLOR_DEBUG2)
		If _Sleep(1000) Then Return
		Click(133,117) ;click Cancel
		$bRet = False
	Else
		SetLog("Upgrading " & $UpgradeName & " Success!", $COLOR_SUCCESS)
		PushMsg("StarLabSuccess")
		ClickAway()
		$bRet = True
	EndIf
	
	If _Sleep(500) Then Return
	Return $bRet
EndFunc

Func StarLabUpgrade($bTest = False)
	Local $bNoPriorityUpgrade = True
	
	If Not $g_bAutoStarLabUpgradeEnable Then Return ; Lab upgrade not enabled.
	If Not CheckIfSLabIdle() Then Return
	If _Sleep(50) Then Return
	
	BuilderBaseReport(True, True)
	
	Local $Upgrades = FindSLabUpgrade($bTest)
	If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
		SetLog("StarLab Upgrade List:", $COLOR_INFO)
		
		If _ArraySearch($Upgrades, "Priority", 0, 0, 0, 0, 1, 7) >= 0 Then $bNoPriorityUpgrade = False
		If _Sleep(50) Then Return
		For $i = 0 To UBound($Upgrades) - 1
			If $g_bSLabUpgradeOrderEnable And $Upgrades[$i][7] = "Common" Then 
				SetLog($Upgrades[$i][3] & " skip, not enabled order setting", $COLOR_DEBUG1)
				ContinueLoop
			EndIf
			
			If $Upgrades[$i][5] < $g_aiCurrentLootBB[$eLootElixirBB] Then
				SetLog("Going to Upgrade: " & $Upgrades[$i][3], $COLOR_ACTION)
				Return SLabUpgrade($Upgrades[$i][3], $Upgrades[$i][1], $Upgrades[$i][2], $bTest)
			Else
				SetLog("Skip upgrade " & $Upgrades[$i][3] & ", no resources", $COLOR_DEBUG2)
			EndIf
		Next
		
		If $bNoPriorityUpgrade And $g_bChkUpgradeAnyIfAllOrderMaxed Then
			SetLog("There is no Priority Upgrade listed, lets try upgrade others", $COLOR_INFO)
			For $i = 0 To UBound($Upgrades) - 1
				If $Upgrades[$i][5] < $g_aiCurrentLootBB[$eLootElixirBB] Then
					SetLog("Going to Upgrade: " & $Upgrades[$i][3], $COLOR_ACTION)
					Return SLabUpgrade($Upgrades[$i][3], $Upgrades[$i][1], $Upgrades[$i][2], $bTest)
				Else
					SetLog("Skip upgrade " & $Upgrades[$i][3] & ", no resources", $COLOR_DEBUG2)
				EndIf
			Next
		EndIf
	Else
		SetLog("No Star Laboratory Upgrade", $COLOR_DEBUG2)
	EndIf
EndFunc

Func FindSLabUpgrade($bTest = False)
	
	Local $aTmpCoord, $aUpgrade[0][8], $aUpgradeName, $tmpcost, $lenght = 0
	Local $aOrder[0][2], $sName = "", $sPriority = "Common", $iScore = 0

	If $g_bSLabUpgradeOrderEnable Then
		For $i = 0 To UBound($g_aCmbSLabUpgradeOrder) - 1
			If $g_aCmbSLabUpgradeOrder[$i] = -1 Then ContinueLoop
			$sName = $g_avStarLabTroops[$g_aCmbSLabUpgradeOrder[$i] + 1][3]
			SetLog("Priority Order [" & $i + 1 & "] " & $sName, $COLOR_DEBUG)
			Local $aTmp[1][2] = [[10 - $i, $sName]]
			_ArrayAdd($aOrder, $aTmp)
		Next
	EndIf	

	$aTmpCoord = QuickMIS("CNX", $g_sImgBBResourceIcon, 380, 73, 500, 400)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			$lenght = Number($aTmpCoord[$i][1]) - $g_iXFindSLabUpgrade
			$aUpgradeName = getBuildingName($g_iXFindSLabUpgrade, $aTmpCoord[$i][2] - 12, $lenght) ;get upgrade name and amount
			$tmpcost = getBuilderMenuCost($aTmpCoord[$i][1], $aTmpCoord[$i][2] - 10)
			If Number($tmpcost) = 0 Then ContinueLoop
			
			$sPriority = "Common"
			$iScore = 0
			If UBound($aOrder) > 0 Then
				For $z = 0 To UBound($aOrder) - 1
					If String($aUpgradeName[0]) = $aOrder[$z][1] Then 
						$sPriority = "Priority"
						$iScore = $aOrder[$z][0]
						SetLog("Found Priority Upgrade, assign score: " & $iScore & " [" & $aUpgradeName[0] & "]", $COLOR_DEBUG2)
					EndIf
				Next
			EndIf
			
			Local $tmparray[1][8] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1]), Number($aTmpCoord[$i][2]), String($aUpgradeName[0]), Number($aUpgradeName[1]), Number($tmpcost), $iScore, $sPriority]]

			_ArrayAdd($aUpgrade, $tmparray)
			If @error Then SetLog("FindUpgrade ComposeArray Err : " & @error, $COLOR_ERROR)
		Next
	EndIf

	If $g_bSLabUpgradeOrderEnable Then 
		_ArraySort($aUpgrade, 1, 0, 0, 6) ;sort by score
	Else
		_ArraySort($aUpgrade, 0, 0, 0, 5) ;sort by cost 
	EndIf
	
	For $j = 0 To UBound($aUpgrade) -1
		SetLog("[" & $j & "] " & $aUpgrade[$j][3] & ", Cost:" & $aUpgrade[$j][5] & " Score:" &  $aUpgrade[$j][6] & " Type:" & $aUpgrade[$j][7] & "]", $COLOR_DEBUG)
	Next

	Return $aUpgrade
EndFunc

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