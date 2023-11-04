; #FUNCTION# ====================================================================================================================
; Name ..........: StarLaboratory
; Description ...:
; Syntax ........: StarLaboratory()
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

Func TestStarLaboratory()
	Local $bWasRunState = $g_bRunState
	Local $sWasStarLabUpgradeTime = $g_sStarLabUpgradeTime
	Local $bWasStarLabUpgradeEnable = $g_bAutoStarLabUpgradeEnable
	$g_bRunState = True
	$g_bAutoStarLabUpgradeEnable = True
	$g_sStarLabUpgradeTime = ""
	Local $Result = StarLaboratory(True)
	$g_bRunState = $bWasRunState
	$g_sStarLabUpgradeTime = $sWasStarLabUpgradeTime
	$g_bAutoStarLabUpgradeEnable = $bWasStarLabUpgradeEnable
	Return $Result
EndFunc

Func StarLaboratory($bTestRun = False)

	If Not $g_bAutoStarLabUpgradeEnable Then Return ; Lab upgrade not enabled.
	
	;Create local array to hold upgrade values
	Local $iAvailElixir, $sElixirCount, $TimeDiff, $aArray, $Result
	If $g_sStarLabUpgradeTime <> "" Then $TimeDiff = _DateDiff("n", _NowCalc(), $g_sStarLabUpgradeTime) ; what is difference between end time and now in minutes?
	If @error Then _logErrorDateDiff(@error)
	SetDebugLog($g_avStarLabTroops[$g_iCmbStarLaboratory][3] & " Lab end time: " & $g_sStarLabUpgradeTime & ", DIFF= " & $TimeDiff, $COLOR_DEBUG)

	If Not $g_bRunState Then Return
	If $TimeDiff <= 0 Then
		SetLog("Checking Troop Upgrade in Star Laboratory", $COLOR_INFO)
	Else
		SetLog("Star Laboratory Upgrade in progress, waiting for completion", $COLOR_INFO)
		If Not $bTestRun Then Return True
	EndIf

	$sElixirCount = getResourcesMainScreen(705, 74)
	SetLog("Updating village values [E]: " & $sElixirCount, $COLOR_SUCCESS)
	$iAvailElixir = Number($sElixirCount)
	If Not $g_bOptimizeOTTO Then isBattleMachineMaxed()
	ZoomOutHelperBB("SwitchBetweenBases") ;go to BH LowerZone
	
	If Not LocateStarLab() Then Return False
	
	If Not ClickB("Research") Then 
		SetLog("Cannot find the Star Laboratory Research Button!", $COLOR_ERROR)
		ClickAway("Left")
		Return False
	EndIf
	
	Local $bWindowOpened = False
	For $i = 1 To 5
		SetDebugLog("Waiting For Star Laboratory Window #" & $i)
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 760, 40, 820, 80) Then 
			$bWindowOpened = True
			ExitLoop
		EndIf
		_Sleep(1000) ;add delay to wait lab window opened
	Next	
	
	If Not $bWindowOpened Then 
		SetLog("Star Laboratory Window Not Opened", $COLOR_ERROR)
		Return 
	EndIf
	
	If WaitForPixel(795, 122, 796, 124, "A2CB6C", 10, 1) Then
		SetLog("Laboratory Upgrade in progress, waiting for completion", $COLOR_INFO)
		Local $sLabTimeOCR = getRemainTLaboratory(225, 202)
		Local $iLabFinishTime = ConvertOCRTime("Lab Time", $sLabTimeOCR, False)
		SetDebugLog("$sLabTimeOCR: " & $sLabTimeOCR & ", $iLabFinishTime = " & $iLabFinishTime & " m")
		If $iLabFinishTime > 0 Then
			$g_sStarLabUpgradeTime = _DateAdd('n', Ceiling($iLabFinishTime), _NowCalc())
			If @error Then _logErrorDateAdd(@error)
			SetLog("Research will finish in " & $sLabTimeOCR & " (" & $g_sStarLabUpgradeTime & ")")
			ClickAway("Left")
			Return True
		Else
			SetDebugLog("Invalid getRemainTLaboratory OCR", $COLOR_DEBUG)
		EndIf
		If Not $bTestRun Then
			ClickAway("Left")
			Return False
		EndIf
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
					If SLabUpgrade($aTroopUpgrade[$Index][2], $aTroopUpgrade[$Index][3], $aTroopUpgrade[$Index][4], $bTestRun) Then
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
				If SLabUpgrade($aTroopUpgrade[$i][2], $aTroopUpgrade[$i][3], $aTroopUpgrade[$i][4], $bTestRun) Then
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
				If SLabUpgrade($aTroopUpgrade[$Index][2], $aTroopUpgrade[$Index][3], $aTroopUpgrade[$Index][4], $bTestRun) Then
					SetLog("Elixir used = " & $aTroopUpgrade[$Index][5], $COLOR_INFO)
					ClickAway("Left")
					Return True
				EndIf
			Else
				SetLog("Selected Upgrade: " & $g_avStarLabTroops[$g_iCmbStarLaboratory][3] & " Is not Upgradable!", $COLOR_DEBUG)
			EndIf
		EndIf
		
		;any upgrade if all on troops lab order is maxed
		If $g_iCmbStarLaboratory = 0 And $g_bSLabUpgradeOrderEnable And $g_bChkUpgradeAnyIfAllOrderMaxed And $bAnyUpgradeOn And ($g_bisBattleMachineMaxed Or $g_bIs6thBuilderUnlocked) Then
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
				If SLabUpgrade($aTroopUpgrade[$i][2], $aTroopUpgrade[$i][3], $aTroopUpgrade[$i][4], $bTestRun) Then
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
		StarLabStatusGUIUpdate()
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

Func FindSLabTroopsUpgrade()
	Local $aResult[0][6], $UpgradeCost, $aTroop
	Local $aTmp = QuickMIS("CNX", $g_sImgStarLabTroops, 100, 340, 710, 540)
	If IsArray($aTmp) And UBound($aTmp) > 0 Then
		For $i = 0 To UBound($aTmp) -1 
			$aTroop = GetSLabTroopResPos($aTmp[$i][0])
			$UpgradeCost = getSLabCost($aTroop[1], $aTroop[2])
			If $UpgradeCost = 111 Then $UpgradeCost = "MaxLevel"
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

		Local $aResult = BuildingInfo(245, 472) ; Get building name and level with OCR
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
		Local $aResult = BuildingInfo(245, 472) ; Get building name and level with OCR
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

