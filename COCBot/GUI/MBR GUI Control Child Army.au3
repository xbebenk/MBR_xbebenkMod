; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: GkevinOD (2014)
; Modified ......: Hervidero (2015), Boju (11-2016), MR.ViPER (11-2016), CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func SetComboTroopComp()
	Local $bWasRedraw = SetRedrawBotWindow(False, Default, Default, Default, "SetComboTroopComp")
	Local $ArmyCampTemp = 0

	If GUICtrlRead($g_hChkTotalCampForced) = $GUI_CHECKED Then
		$ArmyCampTemp = Floor(GUICtrlRead($g_hTxtTotalCampForced) * GUICtrlRead($g_hTxtFullTroop) / 100)
	Else
		$ArmyCampTemp = Floor($g_iTotalCampSpace * GUICtrlRead($g_hTxtFullTroop) / 100)
	EndIf

	Local $TotalTroopsToTrain = 0

	lblTotalCountTroop1()
	lblTotalCountSpell2()
	lblTotalCountSiege()
	SetRedrawBotWindow($bWasRedraw, Default, Default, Default, "SetComboTroopComp")
EndFunc   ;==>SetComboTroopComp

Func chkTotalCampForced()
	GUICtrlSetState($g_hTxtTotalCampForced, GUICtrlRead($g_hChkTotalCampForced) = $GUI_CHECKED ? $GUI_ENABLE : $GUI_DISABLE)
EndFunc   ;==>chkTotalCampForced

Func lblTotalCountTroop1()
	; Calculate count of troops, set progress bars, colors
	Local $TotalTroopsToTrain = 0
	Local $ArmyCampTemp = 0

	If GUICtrlRead($g_hChkTotalCampForced) = $GUI_CHECKED Then
		$ArmyCampTemp = Floor(GUICtrlRead($g_hTxtTotalCampForced) * GUICtrlRead($g_hTxtFullTroop) / 100)
	Else
		$ArmyCampTemp = Floor($g_iTotalCampSpace * GUICtrlRead($g_hTxtFullTroop) / 100)
	EndIf

	RemoveAllTmpTrain("Troop")
	Local $iTmpTroops = 0
	For $i = 0 To $eTroopCount - 1
		Local $iCount = GUICtrlRead($g_ahTxtTrainArmyTroopCount[$i])
		If $iCount > 0 Then
			$TotalTroopsToTrain += $iCount * $g_aiTroopSpace[$i]
			;Set Troop Train Info
			If $iTmpTroops > UBound($g_ahPicTrainArmyTroopTmp) - 1 Then ContinueLoop
			_GUICtrlSetImage($g_ahPicTrainArmyTroopTmp[$iTmpTroops], $g_sLibIconPath, $g_aTroopsIcon[$i])
			GUICtrlSetState($g_ahPicTrainArmyTroopTmp[$iTmpTroops], $GUI_SHOW)
			GUICtrlSetData($g_ahLblTrainArmyTroopTmp[$iTmpTroops], $iCount)
			GUICtrlSetState($g_ahLblTrainArmyTroopTmp[$iTmpTroops], $GUI_SHOW)
			$iTmpTroops += 1
		EndIf
	Next

	GUICtrlSetData($g_hLblCountTotal, String($TotalTroopsToTrain))

	For $i = 0 To $eTroopCount - 1
		GUICtrlSetBkColor($g_ahTxtTrainArmyTroopCount[$i], $TotalTroopsToTrain <= GUICtrlRead($g_hTxtTotalCampForced) ? $COLOR_WHITE : $COLOR_RED)
	Next

	If GUICtrlRead($g_hChkTotalCampForced) = $GUI_CHECKED And GUICtrlRead($g_hLblCountTotal) = GUICtrlRead($g_hTxtTotalCampForced) Then
		GUICtrlSetBkColor($g_hLblCountTotal, $COLOR_MONEYGREEN)
	ElseIf GUICtrlRead($g_hLblCountTotal) = $ArmyCampTemp Then
		GUICtrlSetBkColor($g_hLblCountTotal, $COLOR_MONEYGREEN)
	ElseIf GUICtrlRead($g_hLblCountTotal) > $ArmyCampTemp / 2 And GUICtrlRead($g_hLblCountTotal) < $ArmyCampTemp Then
		GUICtrlSetBkColor($g_hLblCountTotal, $COLOR_ORANGE)
	Else
		GUICtrlSetBkColor($g_hLblCountTotal, $COLOR_RED)
	EndIf

	Local $fPctOfForced = Floor((GUICtrlRead($g_hLblCountTotal) / GUICtrlRead($g_hTxtTotalCampForced)) * 100)
	Local $fPctOfCalculated = Floor((GUICtrlRead($g_hLblCountTotal) / $ArmyCampTemp) * 100)

	If GUICtrlRead($g_hChkTotalCampForced) = $GUI_CHECKED Then
		GUICtrlSetData($g_hCalTotalTroops, $fPctOfForced < 1 ? (GUICtrlRead($g_hLblCountTotal) > 0 ? 1 : 0) : $fPctOfForced)
	Else
		GUICtrlSetData($g_hCalTotalTroops, $fPctOfCalculated < 1 ? (GUICtrlRead($g_hLblCountTotal) > 0 ? 1 : 0) : $fPctOfCalculated)
	EndIf

	If GUICtrlRead($g_hChkTotalCampForced) = $GUI_CHECKED Then
		If Number(GUICtrlRead($g_hLblCountTotal)) <= Number(GUICtrlRead($g_hTxtTotalCampForced)) Then
			GUICtrlSetState($g_hCalTotalTroops, $GUI_SHOW)
		Else
			GUICtrlSetState($g_hCalTotalTroops, $GUI_HIDE)
		EndIf
	Else
		If Number(GUICtrlRead($g_hLblCountTotal)) >= $ArmyCampTemp Then
			GUICtrlSetState($g_hCalTotalTroops, $GUI_SHOW)
		Else
			GUICtrlSetState($g_hCalTotalTroops, $GUI_HIDE)
		EndIf
	EndIf
EndFunc   ;==>lblTotalCountTroop1

Func lblTotalCountSpell2()
	; calculate total space and time for spell composition
	Local $iTotalTotalTimeSpell = 0
	$g_iTotalTrainSpaceSpell = 0

	RemoveAllTmpTrain("Spell")
	Local $iTmpSpells = 0
	For $i = 0 To $eSpellCount - 1
		Local $iCount = GUICtrlRead($g_ahTxtTrainArmySpellCount[$i])
		If $iCount > 0 Then
			$g_iTotalTrainSpaceSpell += $g_aiArmyCustomSpells[$i] * $g_aiSpellSpace[$i]

			;Set Spell Train Info
			If $iTmpSpells > UBound($g_ahPicTrainArmySpellTmp) - 1 Then ContinueLoop
			_GUICtrlSetImage($g_ahPicTrainArmySpellTmp[$iTmpSpells], $g_sLibIconPath, $g_aSpellsIcon[$i])
			GUICtrlSetState($g_ahPicTrainArmySpellTmp[$iTmpSpells], $GUI_SHOW)
			GUICtrlSetData($g_ahLblTrainArmySpellTmp[$iTmpSpells], $iCount)
			GUICtrlSetState($g_ahLblTrainArmySpellTmp[$iTmpSpells], $GUI_SHOW)
			$iTmpSpells += 1
		EndIf
	Next

	For $i = 0 To $eSpellCount - 1
		GUICtrlSetBkColor($g_ahTxtTrainArmySpellCount[$i], $g_iTotalTrainSpaceSpell <= Number(GUICtrlRead($g_hTxtTotalCountSpell)) ? $COLOR_WHITE : $COLOR_RED)
	Next

	GUICtrlSetBkColor($g_hLblCountTotalSpells, $g_iTotalTrainSpaceSpell <= Number(GUICtrlRead($g_hTxtTotalCountSpell)) ? $COLOR_MONEYGREEN : $COLOR_RED)

	Local $iSpellProgress = Floor(($g_iTotalTrainSpaceSpell / Number(GUICtrlRead($g_hTxtTotalCountSpell))) * 100)
	If $iSpellProgress <= 100 Then
		GUICtrlSetData($g_hCalTotalSpells, $iSpellProgress)
		GUICtrlSetState($g_hCalTotalSpells, $GUI_SHOW)
	Else
		GUICtrlSetState($g_hCalTotalSpells, $GUI_HIDE)
	EndIf

	GUICtrlSetData($g_hLblCountTotalSpells, String($g_iTotalTrainSpaceSpell))
	GUICtrlSetData($g_hLblTotalTimeSpell, CalculTimeTo($iTotalTotalTimeSpell))
EndFunc   ;==>lblTotalCountSpell2

Func lblTotalCountSiege()
	; calculate total space and time for Siege composition
	Local $iTotalTotalTimeSiege = 0, $indexLevel = 0
	$g_iTotalTrainSpaceSiege = 0
	RemoveAllTmpTrain("Siege")
	Local $iTmpSieges = 0
	For $i = 0 To $eSiegeMachineCount - 1

		Local $iCount = GUICtrlRead($g_ahTxtTrainArmySiegeCount[$i])
		If $iCount > 0 Then
			$g_iTotalTrainSpaceSiege += $g_aiArmyCompSiegeMachines[$i] * $g_aiSiegeMachineSpace[$i]

			;Set Siege Train Info
			If $iTmpSieges > UBound($g_ahPicTrainArmySiegeTmp) - 1 Then ContinueLoop
			_GUICtrlSetImage($g_ahPicTrainArmySiegeTmp[$iTmpSieges], $g_sLibIconPath, $g_aSiegesIcon[$i])
			GUICtrlSetState($g_ahPicTrainArmySiegeTmp[$iTmpSieges], $GUI_SHOW)
			GUICtrlSetData($g_ahLblTrainArmySiegeTmp[$iTmpSieges], $iCount)
			GUICtrlSetState($g_ahLblTrainArmySiegeTmp[$iTmpSieges], $GUI_SHOW)
			$iTmpSieges += 1
		EndIf
	Next

	GUICtrlSetData($g_hLblCountTotalSiege, $g_iTotalTrainSpaceSiege)
	GUICtrlSetBkColor($g_hLblCountTotalSiege, $g_iTotalTrainSpaceSiege <= 3 ? $COLOR_MONEYGREEN : $COLOR_RED)
	For $i = 0 To $eSiegeMachineCount - 1
		If ($g_iTotalTrainSpaceSiege <= 3) Then
			GUICtrlSetBkColor($g_ahTxtTrainArmySiegeCount[$i], $COLOR_WHITE)
		Else
			GUICtrlSetBkColor($g_ahTxtTrainArmySiegeCount[$i], $COLOR_RED)
		EndIf
	Next
EndFunc   ;==>lblTotalCountSiege

Func TotalSpellCountClick()
	Local $bWasRedraw = SetRedrawBotWindow(False, Default, Default, Default, "TotalSpellCountClick")
	_GUI_Value_STATE("DISABLE", $groupListSpells)
	$g_iTownHallLevel = Int($g_iTownHallLevel)

	If $g_iTownHallLevel > 4 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupLightning)
	Else
		For $i = 0 To $eSpellCount - 1
			GUICtrlSetData($g_ahTxtTrainArmySpellCount[$i], 0)
		Next
		GUICtrlSetData($g_hTxtTotalCountSpell, 0)
	EndIf

	If $g_iTownHallLevel > 5 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupHeal)
	Else
		For $i = $eSpellRage To $eSpellBat
			GUICtrlSetData($g_ahTxtTrainArmySpellCount[$i], 0)
		Next
	EndIf

	If $g_iTownHallLevel > 6 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupRage)
	Else
		For $i = $eSpellJump To $eSpellBat
			GUICtrlSetData($g_ahTxtTrainArmySpellCount[$i], 0)
		Next
	EndIf

	If $g_iTownHallLevel > 7 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupPoison)
		_GUI_Value_STATE("ENABLE", $groupEarthquake)
	Else
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellJump], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellFreeze], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellClone], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellInvisibility], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellHaste], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellSkeleton], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellBat], 0)
	EndIf

	If $g_iTownHallLevel > 8 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupJump)
		_GUI_Value_STATE("ENABLE", $groupFreeze)
		_GUI_Value_STATE("ENABLE", $groupHaste)
		_GUI_Value_STATE("ENABLE", $groupSkeleton)
	Else
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellClone], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellBat], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellInvisibility], 0)
	EndIf

	If $g_iTownHallLevel > 9 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupClone)
		_GUI_Value_STATE("ENABLE", $groupBat)
	Else
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellInvisibility], 0)
	EndIf

	If $g_iTownHallLevel > 10 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupInvisibility)
	EndIf

	lblTotalCountSpell2()
	SetRedrawBotWindow($bWasRedraw, Default, Default, Default, "TotalSpellCountClick")
EndFunc   ;==>TotalSpellCountClick

Func chkBoostBarracksHoursE1()
	If GUICtrlRead($g_hChkBoostBarracksHoursE1) = $GUI_CHECKED And GUICtrlRead($g_hChkBoostBarracksHours[0]) = $GUI_CHECKED Then
		For $i = 0 To 11
			GUICtrlSetState($g_hChkBoostBarracksHours[$i], $GUI_UNCHECKED)
		Next
	Else
		For $i = 0 To 11
			GUICtrlSetState($g_hChkBoostBarracksHours[$i], $GUI_CHECKED)
		Next
	EndIf
	Sleep(300)
	GUICtrlSetState($g_hChkBoostBarracksHoursE1, $GUI_UNCHECKED)
EndFunc   ;==>chkBoostBarracksHoursE1

Func chkBoostBarracksHoursE2()
	If GUICtrlRead($g_hChkBoostBarracksHoursE2) = $GUI_CHECKED And GUICtrlRead($g_hChkBoostBarracksHours[12]) = $GUI_CHECKED Then
		For $i = 12 To 23
			GUICtrlSetState($g_hChkBoostBarracksHours[$i], $GUI_UNCHECKED)
		Next
	Else
		For $i = 12 To 23
			GUICtrlSetState($g_hChkBoostBarracksHours[$i], $GUI_CHECKED)
		Next
	EndIf
	Sleep(300)
	GUICtrlSetState($g_hChkBoostBarracksHoursE2, $GUI_UNCHECKED)
EndFunc   ;==>chkBoostBarracksHoursE2

Func chkCloseWaitEnable()
	If GUICtrlRead($g_hChkCloseWhileTraining) = $GUI_CHECKED Then
		$g_bCloseWhileTrainingEnable = True
		_GUI_Value_STATE("ENABLE", $groupCloseWhileTraining)
		_GUI_Value_STATE("ENABLE", $g_hLblCloseWaitingTroops & "#" & $g_hCmbMinimumTimeClose & "#" & $g_hLblSymbolWaiting & "#" & $g_hLblWaitingInMinutes)
	Else
		$g_bCloseWhileTrainingEnable = False
		_GUI_Value_STATE("DISABLE", $groupCloseWhileTraining)
		_GUI_Value_STATE("DISABLE", $g_hLblCloseWaitingTroops & "#" & $g_hCmbMinimumTimeClose & "#" & $g_hLblSymbolWaiting & "#" & $g_hLblWaitingInMinutes)
	EndIf
	If GUICtrlRead($g_hChkRandomClose) = $GUI_CHECKED Then
		GUICtrlSetState($g_hChkCloseEmulator, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
		GUICtrlSetState($g_hChkSuspendComputer, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
	Else
		If GUICtrlRead($g_hChkCloseWhileTraining) = $GUI_CHECKED Then
			GUICtrlSetState($g_hChkCloseEmulator, $GUI_ENABLE)
			GUICtrlSetState($g_hChkSuspendComputer, $GUI_ENABLE)
		EndIf
	EndIf
EndFunc   ;==>chkCloseWaitEnable

Func chkCloseWaitTrain()
	$g_bCloseWithoutShield = (GUICtrlRead($g_hChkCloseWithoutShield) = $GUI_CHECKED)
EndFunc   ;==>chkCloseWaitTrain

Func btnCloseWaitStop()
	$g_bCloseEmulator = (GUICtrlRead($g_hChkCloseEmulator) = $GUI_CHECKED)
EndFunc   ;==>btnCloseWaitStop

Func btnCloseWaitSuspendComputer()
	$g_bSuspendComputer = (GUICtrlRead($g_hChkSuspendComputer) = $GUI_CHECKED)
EndFunc   ;==>btnCloseWaitSuspendComputer

Func btnCloseWaitStopRandom()
	If GUICtrlRead($g_hChkRandomClose) = $GUI_CHECKED Then
		$g_bCloseRandom = True
		$g_bCloseEmulator = False
		$g_bSuspendComputer = False
		GUICtrlSetState($g_hChkCloseEmulator, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
		GUICtrlSetState($g_hChkSuspendComputer, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
	Else
		$g_bCloseRandom = False
		If GUICtrlRead($g_hChkCloseWhileTraining) = $GUI_CHECKED Then
			GUICtrlSetState($g_hChkCloseEmulator, $GUI_ENABLE)
			GUICtrlSetState($g_hChkSuspendComputer, $GUI_ENABLE)
		EndIf
	EndIf
EndFunc   ;==>btnCloseWaitStopRandom

Func btnCloseWaitRandom()
	If GUICtrlRead($g_hRdoCloseWaitExact) = $GUI_CHECKED Then
		$g_bCloseExactTime = True
		$g_bCloseRandomTime = False
		GUICtrlSetState($g_hCmbCloseWaitRdmPercent, $GUI_DISABLE)
	ElseIf GUICtrlRead($g_hRdoCloseWaitRandom) = $GUI_CHECKED Then
		$g_bCloseExactTime = False
		$g_bCloseRandomTime = True
		If GUICtrlRead($g_hChkCloseWhileTraining) = $GUI_CHECKED Then GUICtrlSetState($g_hCmbCloseWaitRdmPercent, $GUI_ENABLE)
	Else
		$g_bCloseExactTime = False
		$g_bCloseRandomTime = False
		GUICtrlSetState($g_hCmbCloseWaitRdmPercent, $GUI_DISABLE)
	EndIf
EndFunc   ;==>btnCloseWaitRandom

Func sldTrainITDelay()
	$g_iTrainClickDelay = GUICtrlRead($g_hSldTrainITDelay)
	GUICtrlSetData($g_hLblTrainITDelayTime, $g_iTrainClickDelay & " ms")
EndFunc   ;==>sldTrainITDelay

Func chkTroopOrder2()
	;GUI OnEvent functions cannot have parameters, so below call is used for the default parameter
	chkTroopOrder()
EndFunc   ;==>chkTroopOrder2

Func chkTroopOrder($bSetLog = True)
	If GUICtrlRead($g_hChkCustomTrainOrderEnable) = $GUI_CHECKED Then
		$g_bCustomTrainOrderEnable = True
		GUICtrlSetState($g_hBtnTroopOrderSet, $GUI_ENABLE)
		GUICtrlSetState($g_hBtnRemoveTroops, $GUI_ENABLE)
		For $i = 0 To UBound($g_ahCmbTroopOrder) - 1
			GUICtrlSetState($g_ahCmbTroopOrder[$i], $GUI_ENABLE)
		Next
		If IsUseCustomTroopOrder() = True Then _GUICtrlSetImage($g_ahImgTroopOrderSet, $g_sLibIconPath, $eIcnRedLight)
	Else
		$g_bCustomTrainOrderEnable = False
		GUICtrlSetState($g_hBtnTroopOrderSet, $GUI_DISABLE) ; disable button
		GUICtrlSetState($g_hBtnRemoveTroops, $GUI_DISABLE)
		For $i = 0 To UBound($g_ahCmbTroopOrder) - 1
			GUICtrlSetState($g_ahCmbTroopOrder[$i], $GUI_DISABLE) ; disable combo boxes
		Next
		SetDefaultTroopGroup($bSetLog) ; Reset troopgroup values to default
		If ($bSetLog Or $g_bDebugSetlogTrain) And $g_bCustomTrainOrderEnable Then
			Local $sNewTrainList = ""
			For $i = 0 To $eTroopCount - 1
				$sNewTrainList &= $g_asTroopShortNames[$g_aiTrainOrder[$i]] & ", "
			Next
			$sNewTrainList = StringTrimRight($sNewTrainList, 2)
			SetLog("Current train order= " & $sNewTrainList, $COLOR_INFO)
		EndIf
	EndIf
EndFunc   ;==>chkTroopOrder

Func chkSpellsOrder()
	If GUICtrlRead($g_hChkCustomBrewOrderEnable) = $GUI_CHECKED Then
		$g_bCustomBrewOrderEnable = True
		For $i = 0 To UBound($g_ahCmbSpellsOrder) - 1
			GUICtrlSetState($g_ahCmbSpellsOrder[$i], $GUI_ENABLE)
		Next
		GUICtrlSetState($g_hBtnRemoveSpells, $GUI_ENABLE)
		GUICtrlSetState($g_hBtnSpellsOrderSet, $GUI_ENABLE)
		If IsUseCustomSpellsOrder() = True Then _GUICtrlSetImage($g_ahImgSpellsOrderSet, $g_sLibIconPath, $eIcnRedLight)
	Else
		$g_bCustomBrewOrderEnable = False
		For $i = 0 To UBound($g_ahCmbSpellsOrder) - 1
			GUICtrlSetState($g_ahCmbSpellsOrder[$i], $GUI_DISABLE)
		Next
		GUICtrlSetState($g_hBtnRemoveSpells, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnSpellsOrderSet, $GUI_DISABLE)
		SetDefaultSpellsGroup(False)
	EndIf

EndFunc   ;==>chkSpellsOrder

Func GUISpellsOrder()
	Local $bDuplicate = False
	Local $iGUI_CtrlId = @GUI_CtrlId
	Local $iCtrlIdImage = $iGUI_CtrlId + 1 ; record control ID for $g_ahImgTroopOrder[$z] based on control of combobox that called this function
	Local $iSpellsIndex = _GUICtrlComboBox_GetCurSel($iGUI_CtrlId) + 1 ; find zero based index number of Spell selected in combo box, add one for enum of proper icon

	_GUICtrlSetImage($iCtrlIdImage, $g_sLibIconPath, $g_aiSpellsOrderIcon[$iSpellsIndex]) ; set proper Spell icon

	For $i = 0 To UBound($g_ahCmbSpellsOrder) - 1 ; check for duplicate combobox index and flag problem
		If $iGUI_CtrlId = $g_ahCmbSpellsOrder[$i] Then ContinueLoop
		If _GUICtrlComboBox_GetCurSel($iGUI_CtrlId) = _GUICtrlComboBox_GetCurSel($g_ahCmbSpellsOrder[$i]) Then
			_GUICtrlSetImage($g_ahImgSpellsOrder[$i], $g_sLibIconPath, $eIcnOptions)
			_GUICtrlComboBox_SetCurSel($g_ahCmbSpellsOrder[$i], -1)
			GUISetState()
			$bDuplicate = True
		EndIf
	Next

	If $bDuplicate Then
		GUICtrlSetState($g_hBtnSpellsOrderSet, $GUI_DISABLE) ; enable button to apply new order
		Return
	Else
		GUICtrlSetState($g_hBtnSpellsOrderSet, $GUI_ENABLE) ; enable button to apply new order
		_GUICtrlSetImage($g_ahImgSpellsOrderSet, $g_sLibIconPath, $eIcnRedLight) ; set status indicator to show need to apply new order
	EndIf
EndFunc   ;==>GUISpellsOrder

Func BtnRemoveSpells()
	Local $bWasRedraw = SetRedrawBotWindow(False, Default, Default, Default, "BtnRemoveSpells")
	Local $sComboData = ""
	For $j = 0 To UBound($g_asSpellsOrderList) - 1
		$sComboData &= $g_asSpellsOrderList[$j] & "|"
	Next
	For $i = 0 To $eSpellCount - 1
		$g_aiCmbCustomBrewOrder[$i] = -1
		_GUICtrlComboBox_ResetContent($g_ahCmbSpellsOrder[$i])
		GUICtrlSetData($g_ahCmbSpellsOrder[$i], $sComboData, "")
		_GUICtrlSetImage($g_ahImgSpellsOrder[$i], $g_sLibIconPath, $eIcnOptions)
	Next
	_GUICtrlSetImage($g_ahImgSpellsOrderSet, $g_sLibIconPath, $eIcnSilverStar)
	SetDefaultSpellsGroup(False)
	SetRedrawBotWindow($bWasRedraw, Default, Default, Default, "BtnRemoveSpells")
EndFunc   ;==>BtnRemoveSpells

Func GUITrainOrder()
	Local $bDuplicate = False
	Local $iGUI_CtrlId = @GUI_CtrlId
	Local $iCtrlIdImage = $iGUI_CtrlId + 1 ; record control ID for $g_ahImgTroopOrder[$z] based on control of combobox that called this function
	Local $iTroopIndex = _GUICtrlComboBox_GetCurSel($iGUI_CtrlId) + 1 ; find zero based index number of troop selected in combo box, add one for enum of proper icon

	_GUICtrlSetImage($iCtrlIdImage, $g_sLibIconPath, $g_aiTroopOrderIcon[$iTroopIndex]) ; set proper troop icon

	For $i = 0 To UBound($g_ahCmbTroopOrder) - 1 ; check for duplicate combobox index and flag problem
		If $iGUI_CtrlId = $g_ahCmbTroopOrder[$i] Then ContinueLoop
		If _GUICtrlComboBox_GetCurSel($iGUI_CtrlId) = _GUICtrlComboBox_GetCurSel($g_ahCmbTroopOrder[$i]) Then
			_GUICtrlSetImage($g_ahImgTroopOrder[$i], $g_sLibIconPath, $eIcnOptions)
			_GUICtrlComboBox_SetCurSel($g_ahCmbTroopOrder[$i], -1)
			GUISetState()
			$bDuplicate = True
		EndIf
	Next
	If $bDuplicate Then
		GUICtrlSetState($g_hBtnTroopOrderSet, $GUI_DISABLE) ; enable button to apply new order
		Return
	Else
		GUICtrlSetState($g_hBtnTroopOrderSet, $GUI_ENABLE) ; enable button to apply new order
		_GUICtrlSetImage($g_ahImgTroopOrderSet, $g_sLibIconPath, $eIcnRedLight) ; set status indicator to show need to apply new order
	EndIf
EndFunc   ;==>GUITrainOrder

Func BtnRemoveTroops()
	Local $sComboData = ""
	For $j = 0 To UBound($g_asTroopOrderList) - 1
		$sComboData &= $g_asTroopOrderList[$j] & "|"
	Next
	SetLog("BtnRemoveTroops", $COLOR_INFO)
	For $i = 0 To Ubound($g_ahCmbTroopOrder) - 1
		$g_aiCmbCustomTrainOrder[$i] = -1
		_GUICtrlComboBox_ResetContent($g_ahCmbTroopOrder[$i])
		GUICtrlSetData($g_ahCmbTroopOrder[$i], $sComboData, "")
		_GUICtrlSetImage($g_ahImgTroopOrder[$i], $g_sLibIconPath, $eIcnOptions)
	Next
	_GUICtrlSetImage($g_ahImgTroopOrderSet, $g_sLibIconPath, $eIcnSilverStar)
	SetDefaultTroopGroup(False)
EndFunc   ;==>BtnRemoveTroops

Func BtnTroopOrderSet()
	Local $bReady = True ; Initialize ready to record troop order flag
	Local $sNewTrainList = ""

	Local $aiUsedTroop = $g_aiTrainOrder
	Local $aTmpTrainOrder[0], $iStartShuffle = 0
	
	For $i = 0 To UBound($g_ahCmbTroopOrder) - 1
		Local $iValue = _GUICtrlComboBox_GetCurSel($g_ahCmbTroopOrder[$i])
		If $iValue <> -1 Then
			_ArrayAdd($aTmpTrainOrder, $iValue)
			Local $iEmpty = _ArraySearch($aiUsedTroop, $iValue)
			If $iEmpty > -1 Then $aiUsedTroop[$iEmpty] = -1
		EndIf
	Next
	;_ArrayDisplay($aTmpTrainOrder, "aTmpTrainOrder")
	$iStartShuffle = Ubound($aTmpTrainOrder)
	
	_ArraySort($aiUsedTroop)
	;_ArrayDisplay($aiUsedTroop, "aiUsedTroop")
	
	For $i = 0 To UBound($aTmpTrainOrder) - 1
		If $aiUsedTroop[$i] = -1 Then $aiUsedTroop[$i] = $aTmpTrainOrder[$i]
	Next
	;_ArrayDisplay($aiUsedTroop, "Updated aiUsedTroop")
	
	
	_ArrayShuffle($aiUsedTroop, $iStartShuffle)
	;_ArrayDisplay($aiUsedTroop, "aiUsedTroop")
	
	For $i = 0 To UBound($g_ahCmbTroopOrder) - 1
		_GUICtrlComboBox_SetCurSel($g_ahCmbTroopOrder[$i], $aiUsedTroop[$i])
		_GUICtrlSetImage($g_ahImgTroopOrder[$i], $g_sLibIconPath, $g_aiTroopOrderIcon[$aiUsedTroop[$i] + 1])
	Next
	
	$g_aiCmbCustomTrainOrder = $aiUsedTroop
	If $bReady Then
		ChangeTroopTrainOrder() ; code function to record new training order
		If @error Then
			Switch @error
				Case 1
					SetLog("Code problem, can not continue till fixed!", $COLOR_ERROR)
				Case 2
					SetLog("Bad Combobox selections, please fix!", $COLOR_ERROR)
				Case 3
					SetLog("Unable to Change Troop Train Order due bad change count!", $COLOR_ERROR)
				Case Else
					SetLog("Monkey ate bad banana, something wrong with ChangeTroopTrainOrder() code!", $COLOR_ERROR)
			EndSwitch
			_GUICtrlSetImage($g_ahImgTroopOrderSet, $g_sLibIconPath, $eIcnRedLight)
		Else
			SetLog("Troop training order changed successfully!", $COLOR_SUCCESS)
			For $i = 0 To $eTroopCount - 1
				If $g_bDebugSetlogTrain Then SetLog("i = " & $i & " g_aiTrainOrder = " & $aiUsedTroop[$i])
				$sNewTrainList &= $g_asTroopShortNames[$aiUsedTroop[$i]] & ", "
			Next
			$sNewTrainList = StringTrimRight($sNewTrainList, 2)
			SetLog("Troop train order= " & $sNewTrainList, $COLOR_INFO)
		EndIf
	Else
		SetLog("Must use all troops and No duplicate troop names!", $COLOR_ERROR)
		_GUICtrlSetImage($g_ahImgTroopOrderSet, $g_sLibIconPath, $eIcnRedLight)
	EndIf
EndFunc   ;==>BtnTroopOrderSet

Func ChangeTroopTrainOrder()
	If $g_bDebugSetlog Or $g_bDebugSetlogTrain Then SetLog("Begin Func ChangeTroopTrainOrder()", $COLOR_DEBUG) ;Debug
	Local $iUpdateCount = 0, $aUnique

	If Not IsUseCustomTroopOrder() Then ; check if no custom troop values saved yet.
		SetError(2, 0, False)
		Return
	EndIf
	
	$aUnique = _ArrayUnique($g_aiCmbCustomTrainOrder, 0, 0, 0, 0)
	$iUpdateCount = UBound($aUnique)
	
	If $iUpdateCount = $eTroopCount Then ; safety check that all troops properly assigned to new array.
		$g_aiTrainOrder = $aUnique
		_GUICtrlSetImage($g_ahImgTroopOrderSet, $g_sLibIconPath, $eIcnGreenLight)
	Else
		SetLog($iUpdateCount & "|" & $eTroopCount & " - Error - Bad troop assignment in ChangeTroopTrainOrder()", $COLOR_ERROR)
		SetError(3, 0, False)
		Return
	EndIf

	Return True
EndFunc   ;==>ChangeTroopTrainOrder

Func BtnSpellsOrderSet()

	Local $bWasRedraw = SetRedrawBotWindow(False, Default, Default, Default, "BtnSpellsOrderSet")
	Local $bReady = True ; Initialize ready to record troop order flag
	Local $sNewTrainList = ""

	Local $bMissingTroop = False ; flag for when troops are not assigned by user
	Local $aiBrewOrder[$eSpellCount] = [ _
			$eSpellLightning, $eSpellHeal, $eSpellRage, $eSpellJump, $eSpellFreeze, $eSpellClone, _
			$eSpellInvisibility, $eSpellRecall, $eSpellPoison, $eSpellEarthquake, $eSpellHaste, $eSpellSkeleton, $eSpellBat]

	; check for duplicate combobox index and take action
	For $i = 0 To UBound($g_ahCmbSpellsOrder) - 1
		For $j = 0 To UBound($g_ahCmbSpellsOrder) - 1
			If $i = $j Then ContinueLoop ; skip if index are same
			If _GUICtrlComboBox_GetCurSel($g_ahCmbSpellsOrder[$i]) <> -1 And _
					_GUICtrlComboBox_GetCurSel($g_ahCmbSpellsOrder[$i]) = _GUICtrlComboBox_GetCurSel($g_ahCmbSpellsOrder[$j]) Then
				_GUICtrlComboBox_SetCurSel($g_ahCmbSpellsOrder[$j], -1)
				_GUICtrlSetImage($g_ahImgSpellsOrder[$j], $g_sLibIconPath, $eIcnOptions)
				$bReady = False
			Else
				GUICtrlSetColor($g_ahCmbSpellsOrder[$j], $COLOR_BLACK)
			EndIf
		Next
		; update combo array variable with new value
		$g_aiCmbCustomBrewOrder[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmbSpellsOrder[$i])
		If $g_aiCmbCustomBrewOrder[$i] = -1 Then $bMissingTroop = True ; check if combo box slot that is not assigned a troop
	Next

	; Automatic random fill missing troops
	If $bReady And $bMissingTroop Then
		; 1st update $aiUsedTroop array with troops not used in $g_aiCmbCustomTrainOrder
		For $i = 0 To UBound($g_aiCmbCustomBrewOrder) - 1
			For $j = 0 To UBound($aiBrewOrder) - 1
				If $g_aiCmbCustomBrewOrder[$i] = $j Then
					$aiBrewOrder[$j] = -1 ; if troop is used, replace enum value with -1
					ExitLoop
				EndIf
			Next
		Next
		_ArrayShuffle($aiBrewOrder) ; make missing training order assignment random
		For $i = 0 To UBound($g_aiCmbCustomBrewOrder) - 1
			If $g_aiCmbCustomBrewOrder[$i] = -1 Then ; check if custom order index is not set
				For $j = 0 To UBound($aiBrewOrder) - 1
					If $aiBrewOrder[$j] <> -1 Then ; loop till find a valid troop enum
						$g_aiCmbCustomBrewOrder[$i] = $aiBrewOrder[$j] ; assign unused troop
						_GUICtrlComboBox_SetCurSel($g_ahCmbSpellsOrder[$i], $aiBrewOrder[$j])
						_GUICtrlSetImage($g_ahImgSpellsOrder[$i], $g_sLibIconPath, $g_aiSpellsOrderIcon[$g_aiCmbCustomBrewOrder[$i] + 1])
						$aiBrewOrder[$j] = -1 ; remove unused troop from array
						ExitLoop
					EndIf
				Next
			EndIf
		Next
	EndIf

	If $bReady Then
		ChangeSpellsBrewOrder() ; code function to record new training order
		If @error Then
			Switch @error
				Case 1
					SetLog("Code problem, can not continue till fixed!", $COLOR_ERROR)
				Case 2
					SetLog("Bad Combobox selections, please fix!", $COLOR_ERROR)
				Case 3
					SetLog("Unable to Change Spells Brew Order due bad change count!", $COLOR_ERROR)
				Case Else
					SetLog("Monkey ate bad banana, something wrong with ChangeSpellsBrewOrder() code!", $COLOR_ERROR)
			EndSwitch
			_GUICtrlSetImage($g_ahImgSpellsOrderSet, $g_sLibIconPath, $eIcnRedLight)
		Else
			SetLog("Spells Brew order changed successfully!", $COLOR_SUCCESS)
			For $i = 0 To $eSpellCount - 1
				$sNewTrainList &= $g_asSpellShortNames[$g_aiBrewOrder[$i]] & ", "
			Next
			$sNewTrainList = StringTrimRight($sNewTrainList, 2)
			SetLog("Spells Brew order= " & $sNewTrainList, $COLOR_INFO)
		EndIf
	Else
		SetLog("Must use all Spells and No duplicate troop names!", $COLOR_ERROR)
		_GUICtrlSetImage($g_ahImgSpellsOrderSet, $g_sLibIconPath, $eIcnRedLight)
	EndIf
	;	GUICtrlSetState($g_hBtnTroopOrderSet, $GUI_DISABLE)
	SetRedrawBotWindow($bWasRedraw, Default, Default, Default, "BtnSpellsOrderSet")

EndFunc   ;==>BtnSpellsOrderSet

Func ChangeSpellsBrewOrder()
	If $g_bDebugSetlog Or $g_bDebugSetlogTrain Then SetLog("Begin Func ChangeSpellsBrewOrder()", $COLOR_DEBUG) ;Debug

	Local $NewTroopOrder[$eSpellCount]
	Local $iUpdateCount = 0

	If Not IsUseCustomSpellsOrder() Then ; check if no custom troop values saved yet.
		SetError(2, 0, False)
		Return
	EndIf

	; Look for match of combobox text to troopgroup and create new train order
	For $i = 0 To UBound($g_ahCmbSpellsOrder) - 1
		Local $sComboText = GUICtrlRead($g_ahCmbSpellsOrder[$i])
		For $j = 0 To UBound($g_asSpellsOrderList) - 1
			If $sComboText = $g_asSpellsOrderList[$j] Then
				$NewTroopOrder[$i] = $j - 1
				$iUpdateCount += 1
				ExitLoop
			EndIf
		Next
	Next

	If $iUpdateCount = $eSpellCount Then ; safety check that all troops properly assigned to new array.
		For $i = 0 To $eSpellCount - 1
			$g_aiBrewOrder[$i] = $NewTroopOrder[$i]
		Next
		_GUICtrlSetImage($g_ahImgSpellsOrderSet, $g_sLibIconPath, $eIcnGreenLight)
	Else
		SetLog($iUpdateCount & "|" & $eSpellCount & " - Error - Bad Spells assignment in ChangeSpellsBrewOrder()", $COLOR_ERROR)
		SetError(3, 0, False)
		Return
	EndIf

	Return True

EndFunc   ;==>ChangeSpellsBrewOrder

Func SetDefaultTroopGroup($bSetLog = True)
	For $i = 0 To Ubound($g_aiTrainOrder) - 1
		$g_aiTrainOrder[$i] = $i
	Next
	If ($bSetLog Or $g_bDebugSetlogTrain) And $g_bCustomTrainOrderEnable Then SetLog("Default troop training order set", $COLOR_SUCCESS)
EndFunc   ;==>SetDefaultTroopGroup

Func IsUseCustomTroopOrder()
	For $i = 0 To UBound($g_aiCmbCustomTrainOrder) - 1 ; Check if custom train order has been used, to select log message
		If $g_aiCmbCustomTrainOrder[$i] = -1 Then
			If $g_bDebugSetlogTrain And $g_bCustomTrainOrderEnable Then SetLog("Custom train order not used...", $COLOR_DEBUG) ;Debug
			Return False
		EndIf
	Next
	If $g_bDebugSetlogTrain And $g_bCustomTrainOrderEnable Then SetLog("Custom train order used...", $COLOR_DEBUG) ;Debug
	Return True
EndFunc   ;==>IsUseCustomTroopOrder

Func SetDefaultSpellsGroup($bSetLog = True)
	For $i = 0 To $eSpellCount - 1
		$g_aiBrewOrder[$i] = $i
	Next
	If ($bSetLog Or $g_bDebugSetlogTrain) And $g_bCustomTrainOrderEnable Then SetLog("Default Spells Brew order set", $COLOR_SUCCESS)
EndFunc   ;==>SetDefaultSpellsGroup

Func IsUseCustomSpellsOrder()
	For $i = 0 To UBound($g_aiCmbCustomBrewOrder) - 1 ; Check if custom train order has been used, to select log message
		If $g_aiCmbCustomBrewOrder[$i] = -1 Then
			If $g_bDebugSetlogTrain And $g_bCustomBrewOrderEnable Then SetLog("Custom Spell order not used...", $COLOR_DEBUG) ;Debug
			Return False
		EndIf
	Next
	If $g_bDebugSetlogTrain And $g_bCustomBrewOrderEnable Then SetLog("Custom Spell order used...", $COLOR_DEBUG) ;Debug
	Return True
EndFunc   ;==>IsUseCustomSpellsOrder

Func CalculTimeTo($TotalTotalTime)
	Local $HourToTrain = 0
	Local $MinToTrain = 0
	Local $SecToTrain = 0
	Local $TotalTotalTimeTo
	If $TotalTotalTime >= 3600 Then
		$HourToTrain = Int($TotalTotalTime / 3600)
		$MinToTrain = Int(($TotalTotalTime - $HourToTrain * 3600) / 60)
		$SecToTrain = $TotalTotalTime - $HourToTrain * 3600 - $MinToTrain * 60
		$TotalTotalTimeTo = " " & $HourToTrain & "h " & $MinToTrain & "m " & $SecToTrain & "s"
	ElseIf $TotalTotalTime < 3600 And $TotalTotalTime >= 60 Then
		$MinToTrain = Int(($TotalTotalTime - $HourToTrain * 3600) / 60)
		$SecToTrain = $TotalTotalTime - $HourToTrain * 3600 - $MinToTrain * 60
		$TotalTotalTimeTo = " " & $MinToTrain & "m " & $SecToTrain & "s"
	Else
		$SecToTrain = $TotalTotalTime
		$TotalTotalTimeTo = " " & $SecToTrain & "s"
	EndIf
	Return $TotalTotalTimeTo
EndFunc   ;==>CalculTimeTo

Func Removecamp()
	For $T = 0 To $eTroopCount - 1
		$g_aiArmyCustomTroops[$T] = 0
		GUICtrlSetData($g_ahTxtTrainArmyTroopCount[$T], $g_aiArmyCustomTroops[$T])
		GUICtrlSetBkColor($g_ahTxtTrainArmyTroopCount[$T], $COLOR_WHITE)
	Next
	For $S = 0 To $eSpellCount - 1
		$g_aiArmyCustomSpells[$S] = 0
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$S], $g_aiArmyCustomSpells[$S])
		GUICtrlSetBkColor($g_ahTxtTrainArmyTroopCount[$S], $COLOR_WHITE)
	Next
	For $S = 0 To $eSiegeMachineCount - 1
		$g_aiArmyCompSiegeMachines[$S] = 0
		GUICtrlSetData($g_ahTxtTrainArmySiegeCount[$S], $g_aiArmyCompSiegeMachines[$S])
		GUICtrlSetBkColor($g_ahTxtTrainArmySiegeCount[$S], $COLOR_WHITE)
	Next

	RemoveAllTmpTrain("All")

	GUICtrlSetData($g_hCalTotalTroops, 0)
	GUICtrlSetData($g_hLblTotalTimeCamp, " 0s")
	GUICtrlSetData($g_hLblTotalTimeSpell, " 0s")
	GUICtrlSetData($g_hLblElixirCostCamp, "0")
	GUICtrlSetData($g_hLblDarkCostCamp, "0")
	GUICtrlSetData($g_hLblElixirCostSpell, "0")
	GUICtrlSetData($g_hLblDarkCostSpell, "0")
	GUICtrlSetData($g_hLblCountTotal, 0)
	GUICtrlSetData($g_hLblCountTotalSpells, 0)
	GUICtrlSetData($g_hLblGoldCostSiege, "0")
	GUICtrlSetData($g_hLblCountTotalSiege, 0)
	GUICtrlSetData($g_hLblTotalTimeSiege, " 0s")
	GUICtrlSetBkColor($g_hLblCountTotal, $COLOR_MONEYGREEN)
	GUICtrlSetBkColor($g_hLblCountTotalSiege, $COLOR_MONEYGREEN)
EndFunc   ;==>Removecamp

Func TrainTroopCountEdit()
	For $i = 0 To $eTroopCount - 1
		If @GUI_CtrlId = $g_ahTxtTrainArmyTroopCount[$i] Then
			$g_aiArmyCustomTroops[$i] = GUICtrlRead($g_ahTxtTrainArmyTroopCount[$i])
			lblTotalCountTroop1()
			Return
		EndIf
	Next
EndFunc   ;==>TrainTroopCountEdit

Func TrainSpellCountEdit()
	For $i = 0 To $eSpellCount - 1
		If @GUI_CtrlId = $g_ahTxtTrainArmySpellCount[$i] Then
			$g_aiArmyCustomSpells[$i] = GUICtrlRead($g_ahTxtTrainArmySpellCount[$i])
			lblTotalCountSpell2()
			Return
		EndIf
	Next
EndFunc   ;==>TrainSpellCountEdit

Func TrainSiegeCountEdit()
	For $i = 0 To $eSiegeMachineCount - 1
		If @GUI_CtrlId = $g_ahTxtTrainArmySiegeCount[$i] Then
			$g_aiArmyCompSiegeMachines[$i] = GUICtrlRead($g_ahTxtTrainArmySiegeCount[$i])
			lblTotalCountSiege()
			Return
		EndIf
	Next
EndFunc   ;==>TrainSiegeCountEdit

Func chkAddDelayIdlePhaseEnable()
	$g_bTrainAddRandomDelayEnable = (GUICtrlRead($g_hChkTrainAddRandomDelayEnable) = $GUI_CHECKED)
	For $i = $g_hLblAddDelayIdlePhaseBetween To $g_hLblAddDelayIdlePhaseSec
		GUICtrlSetState($i, $g_bTrainAddRandomDelayEnable ? $GUI_ENABLE : $GUI_DISABLE)
	Next
EndFunc   ;==>chkAddDelayIdlePhaseEnable

Func chkSuperTroops()
	If GUICtrlRead($g_hChkSuperTroops) = $GUI_CHECKED Then
		$g_bSuperTroopsEnable = True
		GUICtrlSetState($g_hChkSkipBoostSuperTroopOnHalt, $GUI_ENABLE)
		GUICtrlSetState($g_hChkUsePotion, $GUI_ENABLE)
		For $i = 0 To $iMaxSupersTroop - 1
			GUICtrlSetState($g_ahLblSuperTroops[$i], $GUI_ENABLE)
			GUICtrlSetState($g_ahCmbSuperTroops[$i], $GUI_ENABLE)
			GUICtrlSetState($g_ahPicSuperTroops[$i], $GUI_SHOW)
			_GUICtrlSetImage($g_ahPicSuperTroops[$i], $g_sLibIconPath, $g_aSuperTroopsIcons[$g_iCmbSuperTroops[$i]])
		Next
	Else
		$g_bSuperTroopsEnable = False
		GUICtrlSetState($g_hChkSkipBoostSuperTroopOnHalt, $GUI_DISABLE)
		GUICtrlSetState($g_hChkUsePotion, $GUI_DISABLE)
		For $i = 0 To $iMaxSupersTroop - 1
			GUICtrlSetState($g_ahLblSuperTroops[$i], $GUI_DISABLE)
			GUICtrlSetState($g_ahCmbSuperTroops[$i], $GUI_DISABLE)
			GUICtrlSetState($g_ahPicSuperTroops[$i], $GUI_HIDE)
			_GUICtrlSetImage($g_ahPicSuperTroops[$i], $g_sLibIconPath, $g_aSuperTroopsIcons[$g_iCmbSuperTroops[$i]])
		Next
	EndIf
	If GUICtrlRead($g_hChkSkipBoostSuperTroopOnHalt) = $GUI_CHECKED Then
		$g_bSkipBoostSuperTroopOnHalt = True
	Else
		$g_bSkipBoostSuperTroopOnHalt = False
	EndIf
	If GUICtrlRead($g_hChkUsePotion) = $GUI_CHECKED Then
		$g_bSuperTroopsBoostUsePotion = True
	Else
		$g_bSuperTroopsBoostUsePotion = False
	EndIf
EndFunc

Func cmbSuperTroops()
	For $i = 0 To $iMaxSupersTroop - 1
		$g_iCmbSuperTroops[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmbSuperTroops[$i])
		_GUICtrlSetImage($g_ahPicSuperTroops[$i], $g_sLibIconPath, $g_aSuperTroopsIcons[$g_iCmbSuperTroops[$i]])
		For $j = 0 To $iMaxSupersTroop - 1
			If $i = $j Then ContinueLoop
			If $g_iCmbSuperTroops[$i] <> 0 And $g_iCmbSuperTroops[$i] = $g_iCmbSuperTroops[$j] Then
				_GUICtrlComboBox_SetCurSel($g_ahCmbSuperTroops[$j], 0)
				_GUICtrlSetImage($g_ahImgTroopOrder[$j], $g_sLibIconPath, $eIcnOptions)
			EndIf
		Next
	Next
 EndFunc

Func ChkPreciseArmy()
	If GUICtrlRead($g_hChkPreciseArmy) = $GUI_CHECKED Then
		$g_bPreciseArmy = True
	Else
		$g_bPreciseArmy = False
	EndIf
EndFunc ;==>ChkPreciseArmy

Func RemoveAllTmpTrain($sWhat = "All")
	If $sWhat = "All" Or $sWhat = "Troop" Then
		For $i = 0 To UBound($g_ahPicTrainArmyTroopTmp) - 1
			GUICtrlSetState($g_ahPicTrainArmyTroopTmp[$i], $GUI_HIDE)
			GUICtrlSetState($g_ahLblTrainArmyTroopTmp[$i], $GUI_HIDE)
		Next
	EndIf

	If $sWhat = "All" Or $sWhat = "Spell" Then
		For $i = 0 To UBound($g_ahPicTrainArmySpellTmp) - 1
			GUICtrlSetState($g_ahPicTrainArmySpellTmp[$i], $GUI_HIDE)
			GUICtrlSetState($g_ahLblTrainArmySpellTmp[$i], $GUI_HIDE)
		Next
	EndIf

	If $sWhat = "All" Or $sWhat = "Siege" Then
		For $i = 0 To UBound($g_ahPicTrainArmySiegeTmp) - 1
			GUICtrlSetState($g_ahPicTrainArmySiegeTmp[$i], $GUI_HIDE)
			GUICtrlSetState($g_ahLblTrainArmySiegeTmp[$i], $GUI_HIDE)
		Next
	EndIf
EndFunc

Func HideAllTroops()
	For $i = $g_ahPicTrainArmyTroop[$eTroopMinion] To $g_ahPicTrainArmyTroop[$eTroopHeadhunter]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopMinion] To $g_ahTxtTrainArmyTroopCount[$eTroopHeadhunter]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahPicTrainArmyTroop[$eTroopBarbarian] To $g_ahPicTrainArmyTroop[$eTroopElectroTitan]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopBarbarian] To $g_ahTxtTrainArmyTroopCount[$eTroopElectroTitan]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahPicTrainArmyTroop[$eTroopSuperBarbarian] To $g_ahPicTrainArmyTroop[$eTroopSuperMiner]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopSuperBarbarian] To $g_ahTxtTrainArmyTroopCount[$eTroopSuperMiner]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahPicTrainArmySpell[$eSpellLightning] To $g_ahPicTrainArmySpell[$eSpellBat]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmySpellCount[$eSpellLightning] To $g_ahTxtTrainArmySpellCount[$eSpellBat]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahPicTrainArmySiege[$eSiegeWallWrecker] To $g_ahPicTrainArmySiege[$eSiegeBattleDrill]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmySiegeCount[$eSiegeWallWrecker] To $g_ahTxtTrainArmySiegeCount[$eSiegeBattleDrill]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahPicTrainArmyTroop[$eTroopGiantSkeleton] To $g_ahPicTrainArmyTroop[$eTroopIceWizard]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopGiantSkeleton] To $g_ahTxtTrainArmyTroopCount[$eTroopIceWizard]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
EndFunc

Func SetBtnSelector($sType = "All")
	For $i = $g_hBtnElixirTroops To $g_hBtnEventTroops
		GUICtrlSetBkColor($i, $COLOR_BLACK)
		GUICtrlSetColor($i, $COLOR_WHITE)
	Next
	Switch $sType
		Case "ElixirTroops"
			GUICtrlSetColor($g_hBtnElixirTroops, $COLOR_YELLOW)
		Case "DarkElixirTroops"
			GUICtrlSetColor($g_hBtnDarkElixirTroops, $COLOR_YELLOW)
		Case "SuperTroops"
			GUICtrlSetColor($g_hBtnSuperTroops, $COLOR_YELLOW)
		Case "Spells"
			GUICtrlSetColor($g_hBtnSpells, $COLOR_YELLOW)
		Case "Sieges"
			GUICtrlSetColor($g_hBtnSieges, $COLOR_YELLOW)
		Case "EventTroops"
			GUICtrlSetColor($g_hBtnEventTroops, $COLOR_YELLOW)
	EndSwitch
EndFunc

Func BtnElixirTroops()
	HideAllTroops()
	For $i = $g_ahPicTrainArmyTroop[$eTroopBarbarian] To $g_ahPicTrainArmyTroop[$eTroopElectroTitan]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopBarbarian] To $g_ahTxtTrainArmyTroopCount[$eTroopElectroTitan]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("ElixirTroops")
EndFunc

Func BtnDarkElixirTroops()
	HideAllTroops()
	For $i = $g_ahPicTrainArmyTroop[$eTroopMinion] To $g_ahPicTrainArmyTroop[$eTroopHeadhunter]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopMinion] To $g_ahTxtTrainArmyTroopCount[$eTroopHeadhunter]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("DarkElixirTroops")
EndFunc

Func BtnSuperTroops()
	HideAllTroops()
	For $i = $g_ahPicTrainArmyTroop[$eTroopSuperBarbarian] To $g_ahPicTrainArmyTroop[$eTroopSuperMiner]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopSuperBarbarian] To $g_ahTxtTrainArmyTroopCount[$eTroopSuperMiner]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("SuperTroops")
EndFunc

Func BtnSpells()
	HideAllTroops()
	For $i = $g_ahPicTrainArmySpell[$eSpellLightning] To $g_ahPicTrainArmySpell[$eSpellBat]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmySpellCount[$eSpellLightning] To $g_ahTxtTrainArmySpellCount[$eSpellBat]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("Spells")
EndFunc

Func BtnSieges()
	HideAllTroops()
	For $i = $g_ahPicTrainArmySiege[$eSiegeWallWrecker] To $g_ahPicTrainArmySiege[$eSiegeBattleDrill]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmySiegeCount[$eSiegeWallWrecker] To $g_ahTxtTrainArmySiegeCount[$eSiegeBattleDrill]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("Sieges")
EndFunc

Func BtnEventTroops()
	HideAllTroops()
	For $i = $g_ahPicTrainArmyTroop[$eTroopGiantSkeleton] To $g_ahPicTrainArmyTroop[$eTroopIceWizard]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopGiantSkeleton] To $g_ahTxtTrainArmyTroopCount[$eTroopIceWizard]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("EventTroops")
EndFunc