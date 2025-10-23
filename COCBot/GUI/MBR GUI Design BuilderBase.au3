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
Global $g_hChkCollectBuilderBase = 0, $g_hChkStartClockTowerBoost = 0, $g_hChkCleanBBYard = 0
Global $g_hChkCollectBldGE = 0, $g_hChkCollectBldGems = 0, $g_hChkActivateClockTower = 0
Global $g_hChkAutoUpgradeBB = 0, $g_hChkAutoUpgradeBBIgnoreHall = 0, $g_hChkAutoUpgradeBBIgnoreWall = 0, $g_hChkBOBControl = 0
Global $g_hChkAutoStarLabUpgrades = 0, $g_hCmbStarLaboratory = 0, $g_hLblNextSLUpgrade = 0
Global $g_hChkEnableBBAttack = 0, $g_hChkBBDropTrophy = 0, $g_hChkBBAttIfStarsAvail = 0, $g_hChkSkipBBAttIfStorageFull = 0, $g_hChkBBWaitForMachine = 0, $g_hChkBBDropBMFirst = 0, $g_hChkStopAttackBB6thBuilder = 0
Global $g_hChkDebugAttackBB = 0, $g_hChkBBAttackReport = 0

Global $g_hIcnTroopBB[8]
Global $g_hCmbTroopBB[8]
Global $g_hChkBBCustomArmyEnable = 0, $g_hLblGUIBBCustomArmy = 0, $g_hChk1SideAttack = 0, $g_hCmbSideAttack = 0, $g_hChk2SideAttack = 0, $g_hChkAllSideBBAttack = 0

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

Global $g_hChkSLabUpgradeOrder = 0, $g_hBtnRemoveSLabUpgradeOrder = 0, $g_hBtnSetSLabUpgradeOrder = 0, $g_hChkUpgradeAnyIfAllOrderMaxed = 0

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
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_04", "Collect && Activate"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 70)
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnGoldMineL5, $x + 7, $y - 5, 24, 24)
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixirCollectorL5, $x + 32, $y - 5, 24, 24)
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnGemMine, $x + 57, $y - 5, 24, 24)
		$g_hChkCollectBuilderBase = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollectBuilderBase", "Collect Resources"), $x + 100, $y)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollectBuildersBase_Info_01", "Check this to collect Resources on the Builder Base"))
		$g_hChkCleanBBYard = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCleanBBYard", "Remove Obstacles"), $x + 260, $y)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCleanBBYard_Info_01", "Check this to automatically clear Yard from Trees, Trunks, etc."))
			GUICtrlSetState (-1, $GUI_ENABLE)

	$y += 18
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnClockTower, $x + 32, $y, 24, 24)
		$g_hChkStartClockTowerBoost = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkActivateClockTowerBoost", "Activate Clock Tower Boost"), $x + 100, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkActivateClockTowerBoost_Info_01", "Check this to activate the Clock Tower Boost when it is available.\r\nThis option doesn't use your Gems"))
			GUICtrlSetOnEvent(-1, "chkStartClockTowerBoost")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	Local $x = 15, $y = 165
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_06", "Auto Upgrades"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 90)

		_GUICtrlCreatePic($g_sIcnMBisland, $x , $y , 64, 64)
		$g_hChkAutoUpgradeBB = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgrades", "Auto Upgrades"), $x + 70, $y + 10, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateBBSuggestedUpgrades")
		$g_hChkAutoUpgradeBBIgnoreHall = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgradesIgnore_Hall", "Ignore Builder Hall"), $x + 280, $y, -1, -1)
			GUICtrlSetOnEvent(-1, "ChkBBSuggestedUpgradesIgnoreHall")
			GUICtrlSetState (-1, $GUI_DISABLE)
		$g_hChkAutoUpgradeBBIgnoreWall = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgradesIgnore_Wall", "Ignore Wall"), $x + 280, $y + 20, -1, -1)
			GUICtrlSetOnEvent(-1, "ChkBBSuggestedUpgradesIgnoreWall")
			GUICtrlSetState (-1, $GUI_DISABLE)
		$g_hChkBOBControl = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgradesBOBControl", "Optimize BOB Control"), $x + 280, $y + 20 + 20, -1, -1)
			GUICtrlSetOnEvent(-1, "ChkBOBControl")
			GUICtrlSetState (-1, $GUI_DISABLE)
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
					
	$y += 90
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "Group_02", "Star Laboratory"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 198)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnStarLaboratory, $x, $y, 64, 64)
		$g_hChkAutoStarLabUpgrades = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoStarLabUpgrades", "Enable Star Laboratory Upgrades"), $x + 80, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoStarLabUpgrades_Info_01", "Check box to enable automatically starting Upgrades in star laboratory"))
			GUICtrlSetOnEvent(-1, "chkStarLab")
		$g_hLblNextSLUpgrade = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "LblNextUpgrade", "Next one") & ":", $x + 80, $y + 25, 50, -1)
		$g_hCmbStarLaboratory = GUICtrlCreateCombo("", $x + 135, $y + 23, 140, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
			GUICtrlSetData(-1, $sTxtSLNames, GetTranslatedFileIni("MBR Global GUI Design", "Any", "Any"))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "CmbLaboratory_Info_01", "Select the troop type to upgrade with this pull down menu") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "CmbLaboratory_Info_02", "The troop icon will appear on the right."))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "cmbStarLab")
		
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
		
		$x = 30
		$y += 40
		;Any Upgrade If All Upgrade Order Troops are Maxed
		$g_hChkUpgradeAnyIfAllOrderMaxed = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUpgradeAnyIfAllOrderMaxed", "Upgrade Any Troops If Upgrades Order All Maxed"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoLabUpgrades_Info_05", "Check box to enable Any Troops If Upgrades Order All Maxed"))
			GUICtrlSetOnEvent(-1, "chkSLabUpgradeOrder")
	GUICtrlCreateGroup("", -99, -99, 1, 1)


EndFunc   ;==>CreateBBPlaySubTab

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

Global $g_hChkBBForceCustomArmy = 0

Func CreateBBAttackSubTab()
	Local $x = 15, $y = 25
	Local $iBBAttackGroupSize = 150
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_13", "Builder Base Attacking"), $x - 10,  $y, $g_iSizeWGrpTab2, $iBBAttackGroupSize)
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
			_GUICtrlComboBox_SetCurSel($g_hCmbBBNextTroopDelay, 5) ; start in middle

		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblBBSameTroopDelay", "Same Troop Delay"), $x + 85, $y + 73)
		$g_hCmbBBSameTroopDelay = GUICtrlCreateCombo( "", $x+180, $y + 70, 30, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBBSameTroopDelay_Info_01", "Set the delay between same troops. 1 fastest to 9 slowest."))
			GUICtrlSetOnEvent(-1, "cmbBBSameTroopDelay")
			GUICtrlSetData(-1, "1|2|3|4|5|6|7|8|9")
			GUICtrlSetState(-1, $GUI_DISABLE)
			_GUICtrlComboBox_SetCurSel($g_hCmbBBSameTroopDelay, 5) ; start in middle

		$g_hBtnBBDropOrder = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnBBDropOrder", "Drop Order"), $x + 10, $y + 62, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnBBDropOrder_Info", "Set a custom dropping order for your troops."))
			GUICtrlSetBkColor(-1, $COLOR_RED)
			GUICtrlSetOnEvent(-1, "btnBBDropOrder")
			GUICtrlSetState(-1, $GUI_DISABLE)
		
		$y = 125
		$g_hChkStopAttackBB6thBuilder = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "chkStopAttackBB6thBuilder", "No Attack at 6th Builder"), $x + 20, $y)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "chkStopAttackBB6thBuilder", "Stop Attack If 6th Builder Unlocked"))
			GUICtrlSetOnEvent(-1, "chkStopAttackBB6thBuilder")
		$y += 23
		$g_hChkBBAttackReport = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBAttackReport", "Enable AttackBB Report"), $x + 20, $y)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBAttackReport", "Enable AttackBB Report"))
			GUICtrlSetOnEvent(-1, "ChkBBAttackReport")
			GUICtrlSetState(-1, $GUI_DISABLE)
			
		$x = $x + 240
		$y = 35
		$g_hChkBBDropTrophy = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBDropTrophy", "Drop BB Trophy to "), $x, $y)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBDropTrophy_Info_01", "Do 1 Attack and immediately surrender"))
			GUICtrlSetOnEvent(-1, "chkBBDropTrophy")
			GUICtrlSetState(-1, $GUI_DISABLE)
		
		$g_hTxtBBTrophyLowerLimit = GUICtrlCreateInput($g_iTxtBBTrophyLowerLimit, $x + 115, $y + 3, 40, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtBBTrophyLimit_Info_01", "Set Builder Base Trophy Lower Limit"))
		$y += 23
		$g_hChkBBAttIfStarsAvail = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBAttIfLootAvail", "Only if stars is available"), $x, $y)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBAttIfStarsAvail_Info_01", "Only attack if there is stars available."))
			GUICtrlSetOnEvent(-1, "ChkBBAttIfStarsAvail")
			GUICtrlSetState(-1, $GUI_DISABLE)
		$y += 23
		$g_hChkSkipBBAttIfStorageFull = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSkipBBAttIfStorageFull", "No Attack If Storages Full"), $x, $y)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSkipBBAttIfStorageFull_Info_01", "No Attack If Storage Full and Builder Busy"))
			GUICtrlSetOnEvent(-1, "ChkSkipBBAttIfStorageFull")
			GUICtrlSetState(-1, $GUI_DISABLE)
		$y += 23
		$g_hChkBBWaitForMachine = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBWaitForMachine", "Wait For Battle Machine"), $x, $y)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBWaitForMachine_Info_01", "Makes the bot not attack while Machine is down."))
			GUICtrlSetState(-1, $GUI_DISABLE)
		$y += 23
		$g_hChkBBDropBMFirst = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBDropBMFirst", "Drop Battle Machine First"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBBMDropFirst_01", "Check to drop BM first in battles."))
			GUICtrlSetOnEvent(-1, "ChkDropBMFirst")
			GUICtrlSetState(-1, $GUI_DISABLE)
		$y += 23
		$g_hChkDebugAttackBB = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkDebugAttackBB", "Debug AttackBB"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkDebugAttackBB", "Create Debug Image while BuilderBase Attack"))
			GUICtrlSetOnEvent(-1, "ChkDebugAttackBB")
			GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$x = 15
	$y = 175
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "Group_03", ""), $x - 10,  $y, $g_iSizeWGrpTab2, 180)
	
		$g_hChkBBCustomArmyEnable = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBCustomArmyEnable", "Enable Custom Army"), $x + 5, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BBCustomArmyEnable", "Enable Use Custom Army"))
			GUICtrlSetOnEvent(-1, "ChkBBCustomArmyEnable")
		
		Static $sTroops = ""
		If $sTroops = "" Then
			For $i = 1 To UBound($g_avStarLabTroops) - 1
				$sTroops &= $g_avStarLabTroops[$i][3] & "|"
			Next
		EndIf
		
		$y += 22
		$g_hLblGUIBBCustomArmy = GUICtrlCreateLabel("", $x, $y)
		$g_hCmbTroopBB[0] = GUICtrlCreateCombo("", $x + 5, $y, 62, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
		GUICtrlSetData(-1, $sTroops, "2")
		_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[0], 0)
		GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
		
		$g_hCmbTroopBB[1] = GUICtrlCreateCombo("", $x + 75, $y, 62, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
		GUICtrlSetData(-1, $sTroops, "2")
		_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[1], 0)
		GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
		
		$g_hCmbTroopBB[2] = GUICtrlCreateCombo("", $x + 145, $y, 62, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
		GUICtrlSetData(-1, $sTroops, "4")
		_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[2], 0)
		GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
		
		$g_hCmbTroopBB[3] = GUICtrlCreateCombo("", $x + 215, $y, 62, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
		GUICtrlSetData(-1, $sTroops, "6")
		_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[3], 0)
		GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
		
		$g_hCmbTroopBB[4] = GUICtrlCreateCombo("", $x + 285, $y, 62, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
		GUICtrlSetData(-1, $sTroops, "6")
		_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[4], 0)
		GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
		
		$g_hCmbTroopBB[5] = GUICtrlCreateCombo("", $x + 355, $y, 62, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
		GUICtrlSetData(-1, $sTroops, "6")
		_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[5], 0)
		GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
		
		$y += 25
		$g_hIcnTroopBB[0] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 15, $y, 45, 45)
		$g_hIcnTroopBB[1] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 85, $y, 45, 45)
		$g_hIcnTroopBB[2] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 155, $y, 45, 45)
		$g_hIcnTroopBB[3] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 225, $y, 45, 45)
		$g_hIcnTroopBB[4] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 295, $y, 45, 45)
		$g_hIcnTroopBB[5] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 365, $y, 45, 45)
		
		$y += 50
		;GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "lblBBArmyCamp8", "Army 7"), $x + 5, $y)
		;GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "lblBBArmyCamp8", "Army 8"), $x + 75, $y)
		$g_hCmbTroopBB[6] = GUICtrlCreateCombo("", $x + 5, $y, 62, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
		GUICtrlSetData(-1, $sTroops, "2")
		_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[6], 0)
		GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
		
		$g_hCmbTroopBB[7] = GUICtrlCreateCombo("", $x + 75, $y, 62, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
		GUICtrlSetData(-1, $sTroops, "2")
		_GUICtrlComboBox_SetCurSel($g_hCmbTroopBB[7], 0)
		GUICtrlSetOnEvent(-1, "GUIBBCustomArmy")
		
		$y += 25
		$g_hIcnTroopBB[6] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 15, $y, 45, 45)
		$g_hIcnTroopBB[7] = _GUICtrlCreateIcon($g_sLibIconPath, $g_avStarLabTroops[1][4], $x + 85, $y, 45, 45)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$x = 15
	$y = 360
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Attack", "Group_03", "Attack Side"), $x - 10,  $y, $g_iSizeWGrpTab2, 65)
		$g_hChk1SideAttack = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Chk2SideAttack", "1 Side Attack"), $x, $y + 13, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Chk2SideAttack", "Use 2 Side Attack"))
			GUICtrlSetOnEvent(-1, "Chk1SideAttack")
		$g_hChk2SideAttack = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Chk2SideAttack", "2 Side Attack"), $x + 165, $y + 13, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Chk2SideAttack", "Use 2 Side Attack"))
			GUICtrlSetOnEvent(-1, "Chk2SideAttack")
		$g_hChkAllSideBBAttack = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkAllSideBBAttack", "All Side Attack"), $x + 285, $y + 13, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkAllSideBBAttack", "Use All Side Attack"))
			GUICtrlSetOnEvent(-1, "ChkAllSideBBAttack")
		$g_hCmbSideAttack = GUICtrlCreateCombo("", $x, $y + 35, 100, -1, $CBS_DROPDOWNLIST + $WS_VSCROLL + $CBS_AUTOHSCROLL)
			GUICtrlSetData(-1, "Lava Launcher|Air Bomb|Mega Tesla|Guard Post", "Lava Launcher")
			GUICtrlSetOnEvent(-1, "Chk1SideAttack")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
EndFunc
