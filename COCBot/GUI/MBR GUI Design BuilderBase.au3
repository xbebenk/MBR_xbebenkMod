; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "About Us" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: xbebenx x boldina (2021)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_BB = 0, $g_hGUI_BB_TAB = 0, $g_hGUI_BB_TAB_ITEM1 = 0, $g_hGUI_BB_TAB_ITEM2 = 0
Global $g_alblBldBaseStats[4] = ["", "", ""]
Global $g_hChkCollectBuilderBase = 0, $g_hChkStartClockTowerBoost = 0, $g_hChkCTBoostBlderBz = 0, $g_hChkCleanBBYard = 0
Global $g_hChkCollectBldGE = 0, $g_hChkCollectBldGems = 0, $g_hChkActivateClockTower = 0
Global $g_hChkBBSuggestedUpgrades = 0, $g_hChkBBSuggestedUpgradesIgnoreGold = 0 , $g_hChkBBSuggestedUpgradesIgnoreElixir , $g_hChkBBSuggestedUpgradesIgnoreHall = 0
Global $g_hChkPlacingNewBuildings = 0, $g_hChkBBSuggestedUpgradesIgnoreWall = 0, $g_hChkBBSuggestedUpgradesOTTO = 0
Global $g_hChkAutoStarLabUpgrades = 0, $g_hCmbStarLaboratory = 0, $g_hLblNextSLUpgrade = 0, $g_hBtnResetStarLabUpgradeTime = 0, $g_hPicStarLabUpgrade = 0

Global $g_hIcnTroopBB[6]
Global $g_hCmbTroopBB[6]
Global $g_hChkBBCustomArmyEnable = 0, $g_hLblGUIBBCustomArmy = 0

Func CreateBuilderBaseTab()
	$g_hGUI_BB = _GUICreate("", $g_iSizeWGrpTab1, $g_iSizeHGrpTab1, $_GUI_CHILD_LEFT, $_GUI_CHILD_TOP, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hFrmBotEx)
	GUISwitch($g_hGUI_BB)
	$g_hGUI_BB_TAB = GUICtrlCreateTab(0, 0, $g_iSizeWGrpTab1, $g_iSizeHGrpTab1, BitOR($TCS_MULTILINE, $TCS_RIGHTJUSTIFY))
	$g_hGUI_BB_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Builderbase_TAB_ITEM1", "BB Play"))
		CreateBBPlaySubTab()
	$g_hGUI_BB_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Builderbase_TAB_ITEM2", "BB Attack"))
		CreateBBAttackSubTab()
		CreateBBDropOrderGUI()
	GUICtrlCreateTabItem("")
EndFunc 

Func CreateBBPlaySubTab()
	Local $x = 15, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_05", "Builders Base Stats"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 50)

		_GUICtrlCreatePic($g_sIcnBldGold, $x, $y - 2, 24, 24)
		$g_alblBldBaseStats[$eLootGoldBB] = GUICtrlCreateLabel("---", $x + 35, $y + 2, 100, -1)
			GUICtrlSetFont(-1, 9, $FW_BOLD, Default, "Arial", $CLEARTYPE_QUALITY)

		_GUICtrlCreatePic($g_sIcnBldElixir, $x + 140, $y - 2, 24, 24)
		$g_alblBldBaseStats[$eLootElixirBB] = GUICtrlCreateLabel("---", $x + 175, $y + 2, 100, -1)
			GUICtrlSetFont(-1, 9, $FW_BOLD, Default, "Arial", $CLEARTYPE_QUALITY)

		_GUICtrlCreatePic($g_sIcnBldTrophy, $x + 280, $y - 2, 24, 24)
		$g_alblBldBaseStats[$eLootTrophyBB] = GUICtrlCreateLabel("---", $x + 315, $y + 2, 100, -1)
			GUICtrlSetFont(-1, 9, $FW_BOLD, Default, "Arial", $CLEARTYPE_QUALITY)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	Local $x = 15, $y = 95
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_04", "Collect && Activate"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 85)
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnGoldMineL5, $x + 7, $y, 24, 24)
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixirCollectorL5, $x + 32, $y, 24, 24)
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnGemMine, $x + 57, $y, 24, 24)
		$g_hChkCollectBuilderBase = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollectBuilderBase", "Collect Resources"), $x + 100, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollectBuildersBase_Info_01", "Check this to collect Ressources on the Builder Base"))
		$g_hChkCleanBBYard = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCleanBBYard", "Remove Obstacles"), $x + 260, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCleanBBYard_Info_01", "Check this to automatically clear Yard from Trees, Trunks, etc."))
			GUICtrlSetState (-1, $GUI_ENABLE)

	$y += 32
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnClockTower, $x + 32, $y, 24, 24)
		$g_hChkStartClockTowerBoost = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkActivateClockTowerBoost", "Activate Clock Tower Boost"), $x + 100, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkActivateClockTowerBoost_Info_01", "Check this to activate the Clock Tower Boost when it is available.\r\nThis option doesn't use your Gems"))
			GUICtrlSetOnEvent(-1, "chkStartClockTowerBoost")
		$g_hChkCTBoostBlderBz = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCTBoostBlderBz", "only when builder is busy"), $x + 260, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCTBoostBlderBz_Info_01", "boost only when the builder is busy"))
			GUICtrlSetState (-1, $GUI_DISABLE)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	Local $x = 15, $y = 180
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_06", "Suggested Upgrades"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 110)

		_GUICtrlCreatePic($g_sIcnMBisland, $x , $y , 64, 64)
		$g_hChkBBSuggestedUpgrades = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgrades", "Suggested Upgrades"), $x + 70, $y + 25, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateBBSuggestedUpgrades")
		$g_hChkBBSuggestedUpgradesIgnoreGold = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgradesIgnore_01", "Ignore Gold values"), $x + 200, $y, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateBBSuggestedUpgradesGold")
		$g_hChkBBSuggestedUpgradesIgnoreElixir = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgradesIgnore_02", "Ignore Elixir values"), $x + 200, $y + 20, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateBBSuggestedUpgradesElixir")
		$g_hChkBBSuggestedUpgradesIgnoreHall = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgradesIgnore_03", "Ignore Builder Hall"), $x + 315, $y, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateBBSuggestedUpgradesGold")
		$g_hChkBBSuggestedUpgradesIgnoreWall = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgradesIgnore_04", "Ignore Wall"), $x + 315, $y + 20, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateBBSuggestedUpgradesGold")
		$g_hChkBBSuggestedUpgradesOTTO = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgradesIgnore_05", "Optimize O.T.T.O"), $x + 315, $y + 50, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgradesIgnore_05", "Optimize OTTO, will only upgrade suggested on OTTO Upgrade.\r\nSuch: Archer Tower, DoubleCannon, MultiMortar, Mega Tesla and Battle Machine"))
			GUICtrlSetOnEvent(-1, "chkActivateOptimizeOTTO")

	$y = 180
		$g_hChkPlacingNewBuildings = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkPlacingNewBuildings", "Build 'New' tagged buildings"), $x + 70, $y + 60, -1, -1)
			GUICtrlSetOnEvent(-1, "chkPlacingNewBuildings")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	
	Local $sTxtSLNames = GetTranslatedFileIni("MBR Global GUI Design", "Any", "Any") & "|" & _
					   GetTranslatedFileIni("MBR Global GUI Design Names Builderbase Troops", "TxtRagedBarbarian", "Raged Barbarian") & "|" & _
					   GetTranslatedFileIni("MBR Global GUI Design Names Builderbase Troops", "TxtSneakyArcher", "Sneaky Archer") & "|" & _
					   GetTranslatedFileIni("MBR Global GUI Design Names Builderbase Troops", "TxtBoxerGiant", "Boxer Giant") & "|" & _
					   GetTranslatedFileIni("MBR Global GUI Design Names Builderbase Troops", "TxtBetaMinion", "Beta Minion") & "|" & _
					   GetTranslatedFileIni("MBR Global GUI Design Names Builderbase Troops", "TxtBomber", "Bomber") & "|" & _
					   GetTranslatedFileIni("MBR Global GUI Design Names Builderbase Troops", "TxtBabyDragon", "Baby Dragon") & "|" & _
					   GetTranslatedFileIni("MBR Global GUI Design Names Builderbase Troops", "TxtCannonCart", "Cannon Cart") & "|" & _
					   GetTranslatedFileIni("MBR Global GUI Design Names Builderbase Troops", "TxtNightWitch", "Night Witch") & "|" & _
					   GetTranslatedFileIni("MBR Global GUI Design Names Builderbase Troops", "TxtDropShip", "Drop Ship") & "|" & _
					   GetTranslatedFileIni("MBR Global GUI Design Names Builderbase Troops", "TxtSuperPekka", "Super Pekka") & "|" & _
					   GetTranslatedFileIni("MBR Global GUI Design Names Builderbase Troops", "TxtHogGlider", "Hog Glider")
					
	$y += 110
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "Group_02", "Star Laboratory"), $x - 20, $y - 20, $g_iSizeWGrpTab1, 173)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnStarLaboratory, $x, $y, 64, 64)
		$g_hChkAutoStarLabUpgrades = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoStarLabUpgrades", "Auto Star Laboratory Upgrades"), $x + 80, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoStarLabUpgrades_Info_01", "Check box to enable automatically starting Upgrades in star laboratory"))
			GUICtrlSetOnEvent(-1, "chkStarLab")
		$g_hLblNextSLUpgrade = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "LblNextUpgrade", "Next one") & ":", $x + 80, $y + 25, 50, -1)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hCmbStarLaboratory = GUICtrlCreateCombo("", $x + 135, $y + 23, 140, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
			GUICtrlSetData(-1, $sTxtSLNames, GetTranslatedFileIni("MBR Global GUI Design", "Any", "Any"))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "CmbLaboratory_Info_01", "Select the troop type to upgrade with this pull down menu") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "CmbLaboratory_Info_02", "The troop icon will appear on the right."))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "cmbStarLab")
		; Red button, will show on upgrade in progress. Temp unhide here and in Func ChkLab() if GUI needs editing.
		$g_hBtnResetStarLabUpgradeTime = GUICtrlCreateButton("", $x + 120 + 172, $y + 36, 18, 18, BitOR($BS_PUSHLIKE,$BS_DEFPUSHBUTTON))
			GUICtrlSetBkColor(-1, $COLOR_ERROR)
			;_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnRedLight)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "BtnResetLabUpgradeTime_Info_01", "Visible Red button means that laboratory upgrade in process") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "BtnResetLabUpgradeTime_Info_02", "This will automatically disappear when near time for upgrade to be completed.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "BtnResetLabUpgradeTime_Info_03", "If upgrade has been manually finished with gems before normal end time,") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "BtnResetLabUpgradeTime_Info_04", "Click red button to reset internal upgrade timer BEFORE STARTING NEW UPGRADE") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "BtnResetLabUpgradeTime_Info_05", "Caution - Unnecessary timer reset will force constant checks for lab status"))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetState(-1, $GUI_HIDE) ; comment this line out to edit GUI
			GUICtrlSetOnEvent(-1, "ResetStarLabUpgradeTime")
		$g_hPicStarLabUpgrade = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnBlank, $x + 330, $y, 64, 64)
			GUICtrlSetState(-1, $GUI_HIDE)
		
		;Enable StarLab Upgrade Order
		$g_hChkSLabUpgradeOrder = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkSLabUpgradeOrder", "Enable StarLab Upgrades Order"), $x + 80, $y + 50, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoLabUpgrades_Info_04", "Check box to enable Upgrades Order in Star laboratory"))
			GUICtrlSetOnEvent(-1, "chkSLabUpgradeOrder")

		; Create translated list of Troops for combo box
		Local $sSComboData = ""
		$sSComboData = StringTrimLeft($sTxtSLNames, 4); trim "Any," from list

		; Create ComboBox(es) for selection StarLab upgrade order
		$y += 75
		$x += 20
		For $z = 0 To UBound($g_ahCmbSLabUpgradeOrder) - 1
			If $z < 3 Then
				GUICtrlCreateLabel($z + 1 & ":", $x - 16, $y + 2, -1, 18)
				$g_ahCmbSLabUpgradeOrder[$z] = GUICtrlCreateCombo("", $x, $y, 110, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "cmbSLabUpgradeOrder")
				GUICtrlSetData(-1, $sSComboData, "")
				GUICtrlSetState(-1, $GUI_DISABLE)
				$y += 22 ; move down to next combobox location
			ElseIf $z > 2 And $z < 7 Then
				If $z = 3 Then
					$x += 141
					$y -= 66
				EndIf
				GUICtrlCreateLabel($z + 1 & ":", $x - 13, $y + 2, -1, 18)
				$g_ahCmbSLabUpgradeOrder[$z] = GUICtrlCreateCombo("", $x + 4, $y, 110, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "cmbSLabUpgradeOrder")
				GUICtrlSetData(-1, $sSComboData, "")
				GUICtrlSetState(-1, $GUI_DISABLE)
				$y += 22 ; move down to next combobox location
			EndIf
		Next
		
		$x += 140
		$y -= 60
		$g_hBtnRemoveSLabUpgradeOrder = GUICtrlCreateButton("Clear List", $x - 6, $y, 96, 20)
		GUICtrlSetState(-1, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetOnEvent(-1, "btnRemoveSLabUpgradeOrder")

		$y += 25
		$g_hBtnSetSLabUpgradeOrder = GUICtrlCreateButton("Apply Order", $x - 6, $y, 96, 20)
		GUICtrlSetState(-1, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetOnEvent(-1, "btnSetSLabUpgradeOrder")
	GUICtrlCreateGroup("", -99, -99, 1, 1)


EndFunc   ;==>CreateBBPlaySubTab

Global $g_hLblNotesScriptBB[3] = [0, 0, 0], $g_hGrpOptionsBB = 0, $g_hGrpAttackStyleBB = 0, $g_hGrpGuideScriptBB[3] = [0, 0, 0], $g_hIcnBBCSV[4] = [0, 0, 0, 0], $g_hCmbBBAttackStyle[3] = [0, 0, 0]
Global $g_hChkBBForceCustomArmy = 0, $g_hChkBBGetArmyFromCSV = 0, $g_hChkBBCSVAttack = 0, $g_hCmbBBCSVSettings = 0 ; Custom

Func CreateBBAttackSubTab()
	Local $x = 15, $y = 25
	Local $iBBAttackGroupSize = 110
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_13", "Builders Base Attacking"), $x - 10,  $y, $g_iSizeWGrpTab2, $iBBAttackGroupSize)
		$g_hChkEnableBBAttack = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkEnableBBAttack", "Attack"), $x + 20, $y + 30, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkEnableBBAttack_Info_01", "Uses the currently queued army to attack."))
			GUICtrlSetOnEvent(-1, "chkEnableBBAttack")

		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblBBAttackTimes", "Attack Count"), $x + 85, $y + 24)
		$g_hCmbBBAttackCount = GUICtrlCreateCombo( "", $x+175, $y + 20, 35, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblBBAttackTimes_Info_01", "Set how many time Bot will Attack On Builder Base") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblBBAttackTimes_Info_02", "PRO Tips: set 0 will always attack while loot available"))
			GUICtrlSetOnEvent(-1, "cmbBBAttackCount")
			GUICtrlSetData(-1, "0|1|2|3|4|5|6|7|8|9|10","0")
			GUICtrlSetState(-1, $GUI_DISABLE)
			;_GUICtrlComboBox_SetCurSel($g_iBBAttackCount, 0) ;0 for attack until no loot

		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblBBNextTroopDelay", "Next Troop Delay"), $x + 85, $y + 48)
		$g_hCmbBBNextTroopDelay = GUICtrlCreateCombo( "", $x+180, $y + 45, 30, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBBNextTroopDelay_Info_01", "Set the delay between different troops. 1 fastest to 9 slowest."))
			GUICtrlSetOnEvent(-1, "cmbBBNextTroopDelay")
			GUICtrlSetData(-1, "1|2|3|4|5|6|7|8|9")
			GUICtrlSetState(-1, $GUI_DISABLE)
			_GUICtrlComboBox_SetCurSel($g_hCmbBBNextTroopDelay, 4) ; start in middle

		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblBBSameTroopDelay", "Same Troop Delay"), $x + 85, $y + 73)
		$g_hCmbBBSameTroopDelay = GUICtrlCreateCombo( "", $x+180, $y + 70, 30, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBBSameTroopDelay_Info_01", "Set the delay between same troops. 1 fastest to 9 slowest."))
			GUICtrlSetOnEvent(-1, "cmbBBSameTroopDelay")
			GUICtrlSetData(-1, "1|2|3|4|5|6|7|8|9")
			GUICtrlSetState(-1, $GUI_DISABLE)
			_GUICtrlComboBox_SetCurSel($g_hCmbBBSameTroopDelay, 4) ; start in middle

		$g_hBtnBBDropOrder = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnBBDropOrder", "Drop Order"), $x + 10, $y + 62, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnBBDropOrder_Info", "Set a custom dropping order for your troops."))
			GUICtrlSetBkColor(-1, $COLOR_RED)
			GUICtrlSetOnEvent(-1, "btnBBDropOrder")
			GUICtrlSetState(-1, $GUI_DISABLE)
		;HArchH was y+30
		$g_hChkBBTrophyRange = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBTrophyRange", "Trophies"), $x + 240, $y + 10)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBTrophyRange_Info_01", "Enable ability to set a trophy range."))
			GUICtrlSetOnEvent(-1, "chkBBTrophyRange")
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hTxtBBTrophyLowerLimit = GUICtrlCreateInput($g_iTxtBBTrophyLowerLimit, $x + 310, $y + 10, 40, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtBBTrophyLimit_Info_01", "If your trophies go below this number then attacking is stopped."))
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hTxtBBTrophyUpperLimit = GUICtrlCreateInput($g_iTxtBBTrophyUpperLimit, $x + 360, $y + 10, 40, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtBBTrophyLimit_Info_02", "If your trophies go above this number then the bot drops trophies"))
			GUICtrlSetState(-1, $GUI_DISABLE)
		;HArchH was y+55
		$g_hChkBBAttIfLootAvail = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBAttIfLootAvail", "Only if loot is available"), $x + 240, $y + 35)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBAttIfLootAvail_Info_01", "Only attack if there is loot available."))
			GUICtrlSetState(-1, $GUI_DISABLE)
		;HArchH was Y+80
		$g_hChkBBWaitForMachine = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBWaitForMachine", "Wait For Battle Machine"), $x + 240, $y + 60, -1, -1) ;65 is too low.
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBWaitForMachine_Info_01", "Makes the bot not attack while Machine is down."))
			GUICtrlSetState(-1, $GUI_DISABLE)
		;HArchH New box for BM order
		$g_hChkBBDropBMFirst = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBDropBMFirst", "Drop Battle Machine First"), $x + 240, $y + 85, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBBMDropFirst_01", "Check to drop BM first in battles."))
			GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$y = 135

	$g_hGrpAttackStyleBB = GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "Group_03", "Attack Style"), $x - 10,  $y, $g_iSizeWGrpTab2, 100)
	
	$g_hChkBBCustomArmyEnable = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBCustomArmyEnable", "Enable Custom Army"), $x + 5, $y + 13, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBCustomArmyEnable", "Enable Use Custom Army"))
		GUICtrlSetOnEvent(-1, "ChkBBCustomArmyEnable")

	;$g_hChkBBForceCustomArmy = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBForceCustomArmy", "Force"), $x + 5 + 127, $y + 13, -1, -1)
	;
	;$g_hChkBBGetArmyFromCSV = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBGetArmyFromCSV", "Force from CSV"), $x + 5 + 270, $y + 13, -1, -1)

	Static $sTroops = ""
	If $sTroops = "" Then
		For $i = 1 To UBound($g_avStarLabTroops) - 1
			$sTroops &= $g_avStarLabTroops[$i][3] & "|"
		Next
	EndIf
	
	$y = 150
	$g_hLblGUIBBCustomArmy = GUICtrlCreateLabel("", $x, $y)
	GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "lblBBArmyCamp1", "Army Camp 1"), $x + 5, $y + 15)
	$g_hCmbTroopBB[0] = GUICtrlCreateCombo("", $x + 5 + 13, $y + 30, 62 - 13, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
	GUICtrlSetData(-1, $sTroops, "0")
	_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[0], 0)
	GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
	$g_hIcnTroopBB[0] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 15 - 18, $y + 54 - 26, 24, 24)

	GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "lblBBArmyCamp2", "Army Camp 2"), $x + 75, $y + 15)
	$g_hCmbTroopBB[1] = GUICtrlCreateCombo("", $x + 75 + 13, $y + 30, 62 - 13, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
	GUICtrlSetData(-1, $sTroops, "0")
	_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[1], 0)
	GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
	$g_hIcnTroopBB[1] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 85 - 18, $y + 54 - 26, 24, 24)

	GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "lblBBArmyCamp3", "Army Camp 3"), $x + 145, $y + 15)
	$g_hCmbTroopBB[2] = GUICtrlCreateCombo("", $x + 145 + 13, $y + 30, 62 - 13, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
	GUICtrlSetData(-1, $sTroops, "0")
	_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[2], 0)
	GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
	$g_hIcnTroopBB[2] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 155 - 18, $y + 54 - 26, 24, 24)

	GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "lblBBArmyCamp4", "Army Camp 4"), $x + 215, $y + 15)
	$g_hCmbTroopBB[3] = GUICtrlCreateCombo("", $x + 215 + 13, $y + 30, 62 - 13, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
	GUICtrlSetData(-1, $sTroops, "0")
	_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[3], 0)
	GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
	$g_hIcnTroopBB[3] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 225 - 18, $y + 54 - 26, 24, 24)

	GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "lblBBArmyCamp5", "Army Camp 5"), $x + 285, $y + 15)
	$g_hCmbTroopBB[4] = GUICtrlCreateCombo("", $x + 285 + 13, $y + 30, 62 - 13, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
	GUICtrlSetData(-1, $sTroops, "0")
	_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[4], 0)
	GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
	$g_hIcnTroopBB[4] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 295 - 18, $y + 54 - 26, 24, 24)

	GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "lblBBArmyCamp6", "Army Camp 6"), $x + 355, $y + 15)
	$g_hCmbTroopBB[5] = GUICtrlCreateCombo("", $x + 355 + 13, $y + 30, 62 - 13, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
	GUICtrlSetData(-1, $sTroops, "0")
	_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[5], 0)
	GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
	$g_hIcnTroopBB[5] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 365 - 18, $y + 54 - 26, 24, 24)
	
	;$y += 58
	;$x = 15
	;
	;$g_hChkBBCSVAttack = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBCSVAttack", "CSV Attack"), $x + 5,  $y - 5, -1, -1)
	;; GUICtrlSetState(-1, $GUI_DISABLE)
	;
	;Static $sBBCSVSettingsString = GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBCSVSettingsOne", "Only one CSV") & "|" & _
	;							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBCSVSettingsCustom", "CSV by weaknesses") & "|" & _
	;						       GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBCSVSettingsRandom", "Random CSV")
	;
	;$g_hCmbBBCSVSettings = GUICtrlCreateCombo("", $x + 142,  $y - 5, 130, -1, $CBS_DROPDOWNLIST + $CBS_AUTOHSCROLL + $WS_VSCROLL)
	;GUICtrlSetData(-1, $sBBCSVSettingsString, "0")
	;_GUICtrlComboBox_SetCurSel($g_hCmbBBCSVSettings, 0)
	;GUICtrlSetOnEvent(-1, 'CmbBBCSVSettings')
	;
	;$y += 17
	;$g_hGrpGuideScriptBB[0] = GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "GrpGuideScriptBB_Info_01", "CSV For Standard Base"), $x + 5, $y, 134, $g_iSizeHGrpTab4 - 145)
	;GUICtrlSetFont(-1, 7)
	;GUICtrlCreateGroup("", -99, -99, 1, 1)
	;$g_hGrpGuideScriptBB[1] = GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "GrpGuideScriptBB_Info_02", "CSV For Weak Ground Base"), $x + 130 + 10, $y, 134, $g_iSizeHGrpTab4 - 145)
	;GUICtrlSetFont(-1, 7)
	;GUICtrlSetState(-1, $GUI_HIDE)
	;GUICtrlCreateGroup("", -99, -99, 1, 1)
	;$g_hGrpGuideScriptBB[2] = GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "GrpGuideScriptBB_Info_03", "CSV For Weak Air Base"), $x + 130 + 130 + 15, $y, 134, $g_iSizeHGrpTab4 - 145)
	;GUICtrlSetFont(-1, 7)
	;GUICtrlSetState(-1, $GUI_HIDE)
	;GUICtrlCreateGroup("", -99, -99, 1, 1)
	;$y += 15
	;$x = 7 + 10
	;$g_hCmbBBAttackStyle[0] = GUICtrlCreateCombo("", $x + 5, $y, 130, -1, $CBS_DROPDOWNLIST + $CBS_AUTOHSCROLL + $WS_VSCROLL)
	;_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "CmbScriptName", "Choose the script; You can edit/add new scripts located in folder: 'CSV/BuilderBase'"))
	;GUICtrlSetState(-1, $GUI_UNCHECKED)
	;GUICtrlSetOnEvent(-1, "chkBBStyle")
	;
	;$g_hCmbBBAttackStyle[1] = GUICtrlCreateCombo("", $x + 130 + 10, $y, 130, -1, $CBS_DROPDOWNLIST + $CBS_AUTOHSCROLL + $WS_VSCROLL)
	;GUICtrlSetOnEvent(-1, "chkBBStyle")
	;GUICtrlSetState(-1, $GUI_HIDE)
	;$g_hCmbBBAttackStyle[2] = GUICtrlCreateCombo("", $x + 130 + 130 + 15, $y, 130, -1, $CBS_DROPDOWNLIST + $CBS_AUTOHSCROLL + $WS_VSCROLL)
	;GUICtrlSetOnEvent(-1, "chkBBStyle")
	;GUICtrlSetState(-1, $GUI_HIDE)
	;
	;$g_hIcnBBCSV[0] = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnReload, $x + 409, $y + 2, 16, 16)
	;_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "IconReload_Info_01", "Reload Script Files"))
	;GUICtrlSetOnEvent(-1, 'UpdateComboScriptNameBB')         ; Run this function when the secondary GUI [X] is clicked
	;
	;$y += 20
	;$g_hLblNotesScriptBB[0] = GUICtrlCreateLabel("", $x + 5, $y + 5, 130, 155)
	;$g_hLblNotesScriptBB[1] = GUICtrlCreateLabel("", $x + 130 + 10, $y + 5, 130, 155)
	;GUICtrlSetState(-1, $GUI_HIDE)
	;$g_hLblNotesScriptBB[2] = GUICtrlCreateLabel("", $x + 130 + 130 + 15, $y + 5, 130, 155)
	;GUICtrlSetState(-1, $GUI_HIDE)
	;
	;$g_hIcnBBCSV[1] = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnEdit, $x + 409, $y + 2, 16, 16)
	;_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "IconShow-Edit_Info_01", "Show/Edit current Attack Script"))
	;GUICtrlSetOnEvent(-1, "EditScriptBB")
	;
	;$y += 20
	;$g_hIcnBBCSV[2] = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnAddcvs, $x + 409, $y + 2, 16, 16)
	;_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "IconCreate_Info_01", "Create a new Attack Script"))
	;GUICtrlSetOnEvent(-1, "NewScriptBB")
	;
	;$y += 20
	;$g_hIcnBBCSV[3] = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnCopy, $x + 409, $y + 2, 16, 16)
	;_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "IconCopy_Info_01", "Copy current Attack Script to a new name"))
	;GUICtrlSetOnEvent(-1, "DuplicateScriptBB")
	;
	;GUICtrlCreateGroup("", -99, -99, 1, 1)
	;
	;;------------------------------------------------------------------------------------------
	;;----- populate list of script and assign the default value if no exist profile -----------
	;PopulateComboScriptsFilesBB()
	;For $i = 0 To 2
	;	Local $tempindex = _GUICtrlComboBox_FindStringExact($g_hCmbBBAttackStyle[$i], $g_sAttackScrScriptNameBB[$i])
	;	If $tempindex = -1 Then $tempindex = 0
	;	_GUICtrlComboBox_SetCurSel($g_hCmbBBAttackStyle[$i], $tempindex)
	;Next

EndFunc

#region - Control
Func chkBBStyle()
	For $i = 0 To 2
		Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[$i])
		Local $scriptname
		_GUICtrlComboBox_GetLBText($g_hCmbBBAttackStyle[$i], $indexofscript, $scriptname)
		$g_sAttackScrScriptNameBB[$i] = $scriptname
		SetDebugLog($g_sAttackScrScriptNameBB[$i] & " Loaded to use on BB attack!")
	Next
	cmbScriptNameBB()
EndFunc   ;==>chkBBStyle

Func PopulateComboScriptsFilesBB($spacficIndex = "-999") ;Define Impoisble Default Index
	Local $FileSearch, $NewFile
	$FileSearch = FileFindFirstFile($g_sCSVBBAttacksPath & "\*.csv")
	Local $output = ""
	While True
		$NewFile = FileFindNextFile($FileSearch)
		If @error Then ExitLoop
		$output = $output & StringLeft($NewFile, StringLen($NewFile) - 4) & "|"
	WEnd
	FileClose($FileSearch)
	;remove last |
	$output = StringLeft($output, StringLen($output) - 1)
	If $spacficIndex = "-999" Then
		;set 3 combo boxes
		For $i = 0 To 2
			;reset combo box
			_GUICtrlComboBox_ResetContent($g_hCmbBBAttackStyle[$i])
			GUICtrlSetData($g_hCmbBBAttackStyle[$i], $output)
			_GUICtrlComboBox_SetCurSel($g_hCmbBBAttackStyle[$i], _GUICtrlComboBox_FindStringExact($g_hCmbBBAttackStyle[$i], ""))
			GUICtrlSetData($g_hLblNotesScriptBB[$i], "")
		Next
	Else
		;reset combo box For Spacfic Index We Need This Logic For Reload Button
		_GUICtrlComboBox_ResetContent($g_hCmbBBAttackStyle[$spacficIndex])
		GUICtrlSetData($g_hCmbBBAttackStyle[$spacficIndex], $output)
		_GUICtrlComboBox_SetCurSel($g_hCmbBBAttackStyle[$spacficIndex], _GUICtrlComboBox_FindStringExact($g_hCmbBBAttackStyle[$spacficIndex], ""))
		GUICtrlSetData($g_hLblNotesScriptBB[$spacficIndex], "")
	EndIf
EndFunc   ;==>PopulateComboScriptsFilesBB


Func cmbScriptNameBB()
	For $i = 0 To 2
		Local $tempvect1 = _GUICtrlComboBox_GetListArray($g_hCmbBBAttackStyle[$i])
		Local $filename = $tempvect1[_GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[$i]) + 1]
		Local $f, $result = ""
		Local $tempvect, $line, $t

		If FileExists($g_sCSVBBAttacksPath & "\" & $filename & ".csv") Then
			$f = FileOpen($g_sCSVBBAttacksPath & "\" & $filename & ".csv", 0)
			; Read in lines of text until the EOF is reached
			While 1
				$line = FileReadLine($f)
				If @error = -1 Then ExitLoop
				$tempvect = StringSplit($line, "|", 2)
				If UBound($tempvect) >= 2 Then
					If StringStripWS(StringUpper($tempvect[0]), 2) = "NOTE" Then $result &= $tempvect[1] & @CRLF
				EndIf
			WEnd
			FileClose($f)
		EndIf
		GUICtrlSetData($g_hLblNotesScriptBB[$i], $result)
	Next
EndFunc   ;==>cmbScriptNameBB

Func UpdateComboScriptNameBB()
	For $i = 0 To 2
		Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[$i])
		Local $scriptname
		_GUICtrlComboBox_GetLBText($g_hCmbBBAttackStyle[$i], $indexofscript, $scriptname)
		PopulateComboScriptsFilesBB($i)
		_GUICtrlComboBox_SetCurSel($g_hCmbBBAttackStyle[$i], _GUICtrlComboBox_FindStringExact($g_hCmbBBAttackStyle[$i], $scriptname))
	Next
	cmbScriptNameBB()
EndFunc   ;==>UpdateComboScriptNameBB

Func EditScriptBB()
	Local $tempvect1 = _GUICtrlComboBox_GetListArray($g_hCmbBBAttackStyle[0])
	Local $filename = $tempvect1[_GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[0]) + 1]
	Local $f, $result = ""
	Local $tempvect, $line, $t
	If FileExists($g_sCSVBBAttacksPath & "\" & $filename & ".csv") Then
		ShellExecute("notepad.exe", $g_sCSVBBAttacksPath & "\" & $filename & ".csv")
	EndIf
EndFunc   ;==>EditScriptBB

Func NewScriptBB()
	Local $filenameScript = InputBox(GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Create", -1), GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_New_0", -1) & ":")
	If StringLen($filenameScript) > 0 Then
		If FileExists($g_sCSVBBAttacksPath & "\" & $filenameScript & ".csv") Then
			MsgBox("", "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_File-exists", -1))
		Else
			Local $hFileOpen = FileOpen($g_sCSVBBAttacksPath & "\" & $filenameScript & ".csv", $FO_APPEND)
			If $hFileOpen = -1 Then
				MsgBox($MB_SYSTEMMODAL, "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Error", -1))
				Return False
			Else
				FileClose($hFileOpen)
				$g_sAttackScrScriptNameBB[0] = $filenameScript
				UpdateComboScriptNameBB()
			EndIf
		EndIf
	EndIf
EndFunc   ;==>NewScriptBB

Func DuplicateScriptBB()
	Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[0])
	Local $scriptname
	_GUICtrlComboBox_GetLBText($g_hCmbBBAttackStyle[0], $indexofscript, $scriptname)
	$g_sAttackScrScriptNameBB[0] = $scriptname
	Local $filenameScript = InputBox(GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Copy_0", -1), GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Copy_1", -1) & ": <" & $g_sAttackScrScriptNameBB[0] & ">" & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_New_1", -1) & ":")
	If StringLen($filenameScript) > 0 Then
		If FileExists($g_sCSVBBAttacksPath & "\" & $filenameScript & ".csv") Then
			MsgBox("", "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_File-exists", -1))
		Else
			Local $hFileOpen = FileCopy($g_sCSVBBAttacksPath & "\" & $g_sAttackScrScriptNameBB[0] & ".csv", $g_sCSVBBAttacksPath & "\" & $filenameScript & ".csv")

			If $hFileOpen = -1 Then
				MsgBox($MB_SYSTEMMODAL, "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Error", -1))
				Return False
			Else
				FileClose($hFileOpen)
				$g_sAttackScrScriptNameBB[0] = $filenameScript
				UpdateComboScriptNameBB()
			EndIf
		EndIf
	EndIf
EndFunc   ;==>DuplicateScriptBB

Func CmbBBCSVSettings()
	;	0 - BBCSVSettingsOne		Only one CSV
	;	1 - BBCSVSettingsCustom		CSV by weaknesses
	;	2 - BBCSVSettingsRandom		Random CSV

	$g_iBBCSVSettings = _GUICtrlComboBox_GetCurSel($g_hCmbBBCSVSettings)
	
	Switch $g_iBBCSVSettings
		Case 1, 2 ; CSV by weaknesses + Random CSV
			GUICtrlSetState($g_hLblNotesScriptBB[1], $GUI_SHOW)
			GUICtrlSetState($g_hCmbBBAttackStyle[1], $GUI_SHOW)
			GUICtrlSetState($g_hGrpGuideScriptBB[1], $GUI_SHOW)
			GUICtrlSetState($g_hLblNotesScriptBB[2], $GUI_SHOW)
			GUICtrlSetState($g_hCmbBBAttackStyle[2], $GUI_SHOW)
			GUICtrlSetState($g_hGrpGuideScriptBB[2], $GUI_SHOW)
		Case Else ; Only one CSV
			_GUICtrlComboBox_SetCurSel($g_hCmbBBCSVSettings, 0)
			GUICtrlSetState($g_hLblNotesScriptBB[1], $GUI_HIDE)
			GUICtrlSetState($g_hCmbBBAttackStyle[1], $GUI_HIDE)
			GUICtrlSetState($g_hGrpGuideScriptBB[1], $GUI_HIDE)
			GUICtrlSetState($g_hLblNotesScriptBB[2], $GUI_HIDE)
			GUICtrlSetState($g_hCmbBBAttackStyle[2], $GUI_HIDE)
			GUICtrlSetState($g_hGrpGuideScriptBB[2], $GUI_HIDE)
		EndSwitch
EndFunc   ;==>CmbBBCSVSettings
#endregion - Control

; Builder base drop order gui
Func CreateBBDropOrderGUI()
	$g_hGUI_BBDropOrder = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - Misc", "GUI_BBDropOrder", "BB Custom Drop Order"), 322, 313, -1, -1, $WS_BORDER, $WS_EX_CONTROLPARENT)


	Local $x = 25, $y = 25
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBDropOrderGroup", "BB Custom Dropping Order"), $x - 20, $y - 20, 308, 250)
		$x += 10
		$y += 20

		$g_hChkBBCustomDropOrderEnable = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBChkCustomDropOrderEnable", "Enable Custom Dropping Order"), $x - 13, $y - 22, -1, -1)
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBChkCustomDropOrderEnable_Info_01", "Enable to select a custom troops dropping order"))
			GUICtrlSetOnEvent(-1, "chkBBDropOrder")

		$y+=5
		For $i=0 To $g_iBBTroopCount-1
			If $i < 6 Then
				GUICtrlCreateLabel($i + 1 & ":", $x - 19, $y + 3 + 25*$i, -1, 18)
				$g_ahCmbBBDropOrder[$i] = GUICtrlCreateCombo("", $x, $y + 25*$i, 94, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
					GUICtrlSetOnEvent(-1, "GUIBBDropOrder")
					GUICtrlSetData(-1,  $g_sBBDropOrderDefault)
					_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtBBDropOrder", "Enter sequence order for drop of troop #" & $i + 1))
					GUICtrlSetState(-1, $GUI_DISABLE)
			Else
				GUICtrlCreateLabel($i + 1 & ":", $x + 150 - 19, $y + 3 + 25*($i-6), -1, 18)
				$g_ahCmbBBDropOrder[$i] = GUICtrlCreateCombo("", $x+150, $y + 25*($i-6), 94, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
					GUICtrlSetOnEvent(-1, "GUIBBDropOrder")
					GUICtrlSetData(-1,  $g_sBBDropOrderDefault)
					_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtBBDropOrder", "Enter sequence order for drop of troop #" & $i + 1))
					GUICtrlSetState(-1, $GUI_DISABLE)
			EndIf
		Next

		$x = 25
		$y = 225
		; Create push button to set training order once completed
		$g_hBtnBBDropOrderSet = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnBBDropOrderSet", "Apply New Order"), $x, $y, 100, 25)
			GUICtrlSetState(-1, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnBBDropOrderSet_Info_01", "Push button when finished selecting custom troops dropping order") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnBBDropOrderSet_Info_02", "When not all troop slots are filled, will use default order."))
			GUICtrlSetOnEvent(-1, "BtnBBDropOrderSet")

		$x += 150
		$g_hBtnBBRemoveDropOrder = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnBBRemoveDropOrder", "Empty Drop List"), $x, $y, 118, 25)
			GUICtrlSetState(-1, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnBBRemoveDropOrder_Info_01", "Push button to remove all troops from list and start over"))
			GUICtrlSetOnEvent(-1, "BtnBBRemoveDropOrder")

		$g_hBtnBBClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnBBDropOrderClose", "Close"), 229, 258, 85, 25)
			GUICtrlSetOnEvent(-1, "CloseCustomBBDropOrder")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

EndFunc ;==>CreateBBDropOrderGUI