; #FUNCTION# ====================================================================================================================
; Name ..........: applyConfig.au3
; Description ...: Applies all of the  variable to the GUI
; Syntax ........: applyConfig()
; Parameters ....: $bRedrawAtExit = True, redraws bot window after config was applied
; Return values .: NA
; Author ........: 
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func ApplyConfig_MOD_CustomArmyBB($TypeReadSave)
	; <><><> CustomArmyBB <><><>
	Switch $TypeReadSave
		Case "Read"
			; BB Upgrade Walls - Team AiO MOD++
			GUICtrlSetState($g_hChkBBUpgradeWalls, $g_bChkBBUpgradeWalls ? $GUI_CHECKED : $GUI_UNCHECKED)
			_GUICtrlComboBox_SetCurSel($g_hCmbBBWallLevel, $g_iCmbBBWallLevel)
			GUICtrlSetData($g_hBBWallNumber, $g_iBBWallNumber)
			GUICtrlSetState($g_hChkBBWallRing, $g_bChkBBWallRing = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBUpgWallsGold, $g_bChkBBUpgWallsGold = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBUpgWallsElixir, $g_bChkBBUpgWallsElixir = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			ChkBBWalls()
			cmbBBWall()

			For $i = 0 To UBound($g_hComboTroopBB) - 1
				_GUICtrlComboBox_SetCurSel($g_hComboTroopBB[$i], $g_iCmbCampsBB[$i])
				_GUICtrlSetImage($g_hIcnTroopBB[$i], $g_sLibIconPath, $g_avStarLabTroops[$g_iCmbCampsBB[$i] + 1][4])
			Next

			GUICtrlSetState($g_hChkPlacingNewBuildings, $g_iChkPlacingNewBuildings = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkActivateBBSuggestedUpgrades()
			chkActivateBBSuggestedUpgradesGold()
			chkActivateBBSuggestedUpgradesElixir()
			chkPlacingNewBuildings()
			GUICtrlSetState($g_hChkBuilderAttack, $g_bChkBuilderAttack ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBStopAt3, $g_bChkBBStopAt3 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBTrophiesRange, $g_bChkBBTrophiesRange ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBCustomAttack, $g_bChkBBCustomAttack ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkBuilderAttack()
			PopulateComboScriptsFilesBB()
			For $i = 0 To 2
				Local $tempindex = _GUICtrlComboBox_FindStringExact($g_hCmbBBAttackStyle[$i], $g_sAttackScrScriptNameBB[$i])
				If $tempindex = -1 Then
					$tempindex = 0
					SetLog("Previous saved BB Scripted Attack not found (deleted, renamed?)", $COLOR_ERROR)
					SetLog("Automatically setted a default script, please check your config", $COLOR_ERROR)
				EndIf
				_GUICtrlComboBox_SetCurSel($g_hCmbBBAttackStyle[$i], $tempindex)
			Next
			cmbScriptNameBB()
			GUICtrlSetData($g_hTxtBBDropTrophiesMin, $g_iTxtBBDropTrophiesMin)
			GUICtrlSetData($g_hTxtBBDropTrophiesMax, $g_iTxtBBDropTrophiesMax)
			chkBBtrophiesRange()
			; -- AIO BB
			GUICtrlSetState($g_hChkOnlyBuilderBase, $g_bOnlyBuilderBase ? $GUI_CHECKED : $GUI_UNCHECKED)
			ChkOnlyBuilderBase()
			GUICtrlSetState($g_hChkBBGetFromCSV, $g_bChkBBGetFromCSV ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBGetFromArmy, $g_bChkBBGetFromArmy ? $GUI_CHECKED : $GUI_UNCHECKED)
			_GUICtrlComboBox_SetCurSel($g_hCmbBBAttack, $g_iCmbBBAttack) ; switching between smart and csv attack
			GUICtrlSetData($g_hTxtBBMinAttack, $g_iBBMinAttack)
			GUICtrlSetData($g_hTxtBBMaxAttack, $g_iBBMaxAttack)
			cmbBBAttack()
			ChkBBGetFromArmy()
			ChkBBGetFromCSV()
			ChkBBCustomAttack()
			ChkBBAttackLoops()
			GUICtrlSetState($g_hChkUpgradeMachine, $g_bChkUpgradeMachine ? $GUI_CHECKED : $GUI_UNCHECKED)

		Case "Save"
			; BB Upgrade Walls - Team AiO MOD++
			$g_bChkBBUpgradeWalls = (GUICtrlRead($g_hChkBBUpgradeWalls) = $GUI_CHECKED)
			$g_iCmbBBWallLevel = _GUICtrlComboBox_GetCurSel($g_hCmbBBWallLevel)
			$g_iBBWallNumber = Int(GUICtrlRead($g_hBBWallNumber))
			$g_bChkBBWallRing = (GUICtrlRead($g_hChkBBWallRing) = $GUI_CHECKED)
			$g_bChkBBUpgWallsGold = (GUICtrlRead($g_hChkBBUpgWallsGold) = $GUI_CHECKED)
			$g_bChkBBUpgWallsElixir = (GUICtrlRead($g_hChkBBUpgWallsElixir) = $GUI_CHECKED)

			For $i = 0 To UBound($g_hComboTroopBB) - 1
				$g_iCmbCampsBB[$i] = _GUICtrlComboBox_GetCurSel($g_hComboTroopBB[$i])
			Next

			$g_iChkPlacingNewBuildings = (GUICtrlRead($g_hChkPlacingNewBuildings) = $GUI_CHECKED) ? 1 : 0
			$g_bChkBuilderAttack = (GUICtrlRead($g_hChkBuilderAttack) = $GUI_CHECKED) ? 1 : 0
			$g_bChkBBStopAt3 = (GUICtrlRead($g_hChkBBStopAt3) = $GUI_CHECKED) ? 1 : 0
			$g_bChkBBTrophiesRange = (GUICtrlRead($g_hChkBBTrophiesRange) = $GUI_CHECKED) ? 1 : 0
			$g_bChkBBCustomAttack = (GUICtrlRead($g_hChkBBCustomAttack) = $GUI_CHECKED) ? 1 : 0
			For $i = 0 To 2
				Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[$i])
				Local $scriptname
				_GUICtrlComboBox_GetLBText($g_hCmbBBAttackStyle[$i], $indexofscript, $scriptname)
				$g_sAttackScrScriptNameBB[$i] = $scriptname
				IniWriteS($g_sProfileConfigPath, "BuilderBase", "ScriptBB" & $i, $g_sAttackScrScriptNameBB[$i])
			Next
			$g_iTxtBBDropTrophiesMin = Int(GUICtrlRead($g_hTxtBBDropTrophiesMin))
			$g_iTxtBBDropTrophiesMax = Int(GUICtrlRead($g_hTxtBBDropTrophiesMax))
			; -- AIO BB
			$g_bChkBBGetFromArmy = (GUICtrlRead($g_hChkBBGetFromArmy) = $GUI_CHECKED)
			$g_bChkBBGetFromCSV = (GUICtrlRead($g_hChkBBGetFromCSV) = $GUI_CHECKED)
			$g_iCmbBBAttack = _GUICtrlComboBox_GetCurSel($g_hCmbBBAttack)
			$g_iBBMinAttack = Int(GUICtrlRead($g_hTxtBBMinAttack))
			$g_iBBMaxAttack = Int(GUICtrlRead($g_hTxtBBMaxAttack))
			$g_bOnlyBuilderBase = (GUICtrlRead($g_hChkOnlyBuilderBase) = $GUI_CHECKED)
			$g_bChkUpgradeMachine = (GUICtrlRead($g_hChkUpgradeMachine) = $GUI_CHECKED)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_CustomArmyBB