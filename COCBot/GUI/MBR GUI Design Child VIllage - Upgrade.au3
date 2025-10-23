; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "Upgrade" tab under the "Village" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_UPGRADE = 0, $g_hGUI_UPGRADE_TAB = 0, $g_hGUI_UPGRADE_TAB_ITEM1 = 0, $g_hGUI_UPGRADE_TAB_ITEM2 = 0, $g_hGUI_UPGRADE_TAB_ITEM3 = 0, _
	   $g_hGUI_UPGRADE_TAB_ITEM4 = 0, $g_hGUI_UPGRADE_TAB_ITEM5 = 0
; Lab
Global $g_hChkAutoLabUpgrades = 0, $g_hCmbLaboratory = 0, $g_hLblNextUpgrade = 0, $g_hBtnResetLabUpgradeTime = 0, $g_hPicLabUpgrade = 0, $g_hUseLabPotion = 0

; Heroes
Global $g_hChkUpgradeKing = 0, $g_hChkUpgradeQueen = 0, $g_hChkUpgradeWarden = 0, $g_hPicChkKingSleepWait = 0, $g_hPicChkQueenSleepWait = 0, $g_hPicChkWardenSleepWait = 0
Global $g_hCmbHeroReservedBuilder = 0, $g_hLblHeroReservedBuilderTop = 0, $g_hLblHeroReservedBuilderBottom = 0
Global $g_hChkUpgradeChampion = 0, $g_hPicChkChampionSleepWait = 0, $g_hBtnHeroEquipment = 0
Global $g_hGUI_HeroEquipment = 0, $g_hBtnHeroEquipmentClose = 0
Global $g_hChkUpgradePets[$ePetCount], $g_hChkSortPetUpgrade = 0, $g_hCmbSortPetUpgrade = 0, $g_hChkSyncSaveDE = 0

; Buildings
Global $g_hChkUpgrade[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hPicUpgradeStatus[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgradeName[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgradeLevel[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hPicUpgradeType[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgradeValue[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgradeTime[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgradeEndTime[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hChkUpgradeRepeat[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgrMinGold = 0, $g_hTxtUpgrMinElixir = 0, $g_hTxtUpgrMinDark = 0

; Walls
Global $g_hChkWalls = 0, $g_hTxtWallMinGold = 0, $g_hTxtWallMinElixir = 0, $g_hChkUseGold = 0, $g_hChkUseElixir = 0, $g_hChkUseElixirGold = 0
Global $g_hChkSaveWallBldr = 0, $g_hAutoAdjustSaveWall = 0
Global $g_hBtnFindWalls = 0, $g_hChkOnly1Builder = 0
Global $g_hCmbTargetWallLevel = 0, $g_hLblWallCost = 0

; Auto Upgrade
Global $g_hChkAutoUpgrade = 0, $g_hLblAutoUpgrade = 0, $g_hTxtAutoUpgradeLog = 0
Global $g_hTxtSmartMinGold = 0, $g_hTxtSmartMinElixir = 0, $g_hTxtSmartMinDark = 0
Global $g_hChkResourcesToIgnore[3] = [0, 0, 0]
Global $g_hChkUpgradesToIgnore[36] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hChkRushTH = 0, $g_hBtnRushTHOption = 0, $g_hUseWallReserveBuilder = 0, $g_hUseBuilderPotion = 0, $g_hUpgradeOtherDefenses = 0
Global $g_hGUI_RushTHOption = 0, $g_hBtnRushTHOptionClose = 0, $g_ahCmbRushTHOption[5] = [0, 0, 0, 0, 0]
Global $RushTHOption[5] = ["TownHall", "Barracks", "Dark Barracks", "Spell Factory", "Dark Spell Factory"]
Global $g_hchkEssentialUpgrade[8] = [0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hUpgradeOnlyTHLevelAchieve = 0, $g_hHeroPriority = 0
Global $g_hUseHeroBooks = 0, $g_hHeroMinUpgradeTime = 0

Func CreateVillageUpgrade()

	; ensure all language translation are created
	InitTranslatedTextUpgradeTab()

	$g_hGUI_UPGRADE = _GUICreate("", $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, 5, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_VILLAGE)
	;GUISetBkColor($COLOR_WHITE, $g_hGUI_UPGRADE)

	GUISwitch($g_hGUI_UPGRADE)
	$g_hGUI_UPGRADE_TAB = GUICtrlCreateTab(0, 0, $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, BitOR($TCS_MULTILINE, $TCS_RIGHTJUSTIFY))
	$g_hGUI_UPGRADE_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_03_STab_01", "Laboratory"))
		CreateLaboratorySubTab()
	$g_hGUI_UPGRADE_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_03_STab_02", "Heroes"))
		CreateHeroesSubTab()
	$g_hGUI_UPGRADE_TAB_ITEM3 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_03_STab_03", "Buildings"))
		CreateBuildingsSubTab()
	$g_hGUI_UPGRADE_TAB_ITEM5 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_03_STab_05", "Auto Upgrade"))
		CreateAutoUpgradeSubTab()
	$g_hGUI_UPGRADE_TAB_ITEM4 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_03_STab_04", "Walls"))
		CreateWallsSubTab()
		CreateHeroEquipment()
		CreateRushTHOption()
	GUICtrlCreateTabItem("")

EndFunc   ;==>CreateVillageUpgrade

Global $g_hChkLabUpgradeOrder = 0, $g_hBtnRemoveLabUpgradeOrder = 0, $g_hBtnSetLabUpgradeOrder = 0, $g_hUpgradeAnyTroops = 0
Global $g_hUseBOF = 0, $g_hUseBOFTime = 0, $g_hUseBOS = 0, $g_hUseBOSTime = 0, $g_hUseBOE = 0, $g_hUseBOETime = 0

Func CreateLaboratorySubTab()
	Local $sTxtNames = ""
	For $i = 0 To Ubound($g_avLabTroops) - 3
		$sTxtNames &= $g_avLabTroops[$i][0] & "|"
	Next
	
	Local $x = 25, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "Group_01", "Laboratory"), $x - 20, $y - 20, $g_iSizeWGrpTab3 - 2, 330)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnLaboratory, $x, $y, 64, 64)
		$g_hChkAutoLabUpgrades = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoLabUpgrades", "Auto Laboratory Upgrades"), $x + 80, $y , -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoLabUpgrades_Info_01", "Check box to enable automatically starting Upgrades in laboratory"))
			GUICtrlSetOnEvent(-1, "chkLab")
		$g_hLblNextUpgrade = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "LblNextUpgrade", "Next one") & ":", $x + 80, $y + 25, 50, -1)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hCmbLaboratory = GUICtrlCreateCombo("", $x + 135, $y + 23, 140, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
			GUICtrlSetData(-1, $sTxtNames, GetTranslatedFileIni("MBR Global GUI Design", "Any", "Any"))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "CmbLaboratory_Info_01", "Select the troop type to upgrade with this pull down menu") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "CmbLaboratory_Info_02", "The troop icon will appear on the right.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "CmbLaboratory_Info_03", "Any Dark Spell/Troop have priority over Upg Heroes!"))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "cmbLab")
		$g_hPicLabUpgrade = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnBlank, $x + 330, $y, 64, 64)
			GUICtrlSetState(-1, $GUI_HIDE)

		;Enable Lab Upgrade Order
		$g_hChkLabUpgradeOrder = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkLabUpgradeOrder", "Enable Order"), $x + 80, $y + 45, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoLabUpgrades_Info_04", "Check box to enable Upgrades Order in laboratory"))
			GUICtrlSetOnEvent(-1, "chkLabUpgradeOrder")

		; Create translated list of Troops for combo box
		Local $sComboData = ""
		For $i = 1 To Ubound($g_avLabTroops) - 1
			$sComboData &= $g_avLabTroops[$i][0] & "|"
		Next

		; Create ComboBox(es) for selection of troop training order
		$y += 70
		$x += 20
		For $z = 0 To UBound($g_ahCmbLabUpgradeOrder) - 1
			If $z < 5 Then
				GUICtrlCreateLabel($z + 1 & ":", $x - 16, $y + 2, -1, 18)
				$g_ahCmbLabUpgradeOrder[$z] = GUICtrlCreateCombo("", $x, $y, 110, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "cmbLabUpgradeOrder")
				GUICtrlSetData(-1, $sComboData, "")
				GUICtrlSetState(-1, $GUI_DISABLE)
				$y += 22 ; move down to next combobox location
			ElseIf $z > 4 And $z < 10 Then
				If $z = 5 Then
					$x += 141
					$y -= 110
				EndIf
				GUICtrlCreateLabel($z + 1 & ":", $x - 13, $y + 2, -1, 18)
				$g_ahCmbLabUpgradeOrder[$z] = GUICtrlCreateCombo("", $x + 4, $y, 110, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "cmbLabUpgradeOrder")
				GUICtrlSetData(-1, $sComboData, "")
				GUICtrlSetState(-1, $GUI_DISABLE)
				$y += 22 ; move down to next combobox location
			EndIf
		Next

		$x += 140
		$y -= 100
		$g_hBtnRemoveLabUpgradeOrder = GUICtrlCreateButton("Clear List", $x - 6, $y, 96, 20)
		GUICtrlSetState(-1, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetOnEvent(-1, "btnRemoveLabUpgradeOrder")

		$y += 25
		$g_hBtnSetLabUpgradeOrder = GUICtrlCreateButton("Apply Order", $x - 6, $y, 96, 20)
		GUICtrlSetState(-1, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetOnEvent(-1, "btnSetLabUpgradeOrder")

		$y += 25
		$g_hUseLabPotion = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUseLabPotion", "Use Resource Potion"), $x - 10, $y , -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUseLabPotion_Info", "Enable Use of Laboratory Potion, If Upgrade is more than 1 Day"))
		$y += 55
		$x = 25
		$g_hUpgradeAnyTroops = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUpgradeAny", "Upgrade Any Troops/Spells/Sieges If All in Order Cannot be Upgraded"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUpgradeAny_Info", "Enable Upgrade Any after Upgrade Order" & @CRLF & "And all upgrades on list cannot be upgraded"))
		$y += 23
		$g_hUseBOF = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUseBOF", "Use Book Of Fighting, If Lab time is more than:"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUseBOF", "Enable Use Book Of Fighting" & @CRLF & "If Laboratory Upgrade time is more than specified day"))
		$g_hUseBOFTime = GUICtrlCreateInput("7", $x + 245, $y + 2, 25, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		GUICtrlCreateLabel("Days", $x + 275, $y + 3)
		$y += 23
		$g_hUseBOS = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUseBOS", "Use Book Of Spell, If Lab time is more than:"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUseBOF", "Enable Use Book Of Spell" & @CRLF & "If Laboratory Upgrade time is more than specified day"))
		$g_hUseBOSTime = GUICtrlCreateInput("7", $x + 230, $y + 2, 25, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		GUICtrlCreateLabel("Days", $x + 260, $y + 3)
		$y += 23
		$g_hUseBOE = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUseBOE", "Use Book Of Everything, If Lab time is more than:"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUseBOE", "Enable Use Book Of Everything" & @CRLF & "If Laboratory Upgrade time is more than specified day"))
		$g_hUseBOETime = GUICtrlCreateInput("14", $x + 255, $y + 2, 25, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		GUICtrlCreateLabel("Days", $x + 285, $y + 3)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$x = 25
	$y = 250

EndFunc   ;==>CreateLaboratorySubTab

Func CreateHeroesSubTab()
	Local $sTxtTip = ""
	Local $x = 25, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "Group_01", "Heroes Upgrade :"), $x - 20, $y - 20, $g_iSizeWGrpTab3 - 2, 130)

	$g_hChkUpgradeKing = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
		$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeKing_Info_01", "Enable upgrading of your King when you have enough Dark Elixir (Saving Min. Dark Elixir)") & @CRLF & _
				   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeKing_Info_02", "You can manually locate your Kings Altar on Misc Tab") & @CRLF & _
				   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeHeroes_Info_01", "Verify your Resume Bot Dark Elixir value at Misc Tab vs Saving Min. Dark Elixir here!") & @CRLF & _
				   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeKing_Info_04", "Enabled with TownHall 7 and higher")
		_GUICtrlSetTip(-1, $sTxtTip)
		GUICtrlSetOnEvent(-1, "chkUpgradeKing")
	_GUICtrlCreateIcon($g_sLibIconPath, $eIcnKingUpgr, $x + 18, $y, 64, 64)
		_GUICtrlSetTip(-1, $sTxtTip)
	$g_hPicChkKingSleepWait = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnSleepingKing, $x + 18, $y, 64, 64)
		_GUICtrlSetTip(-1, $sTxtTip)
		GUICtrlSetState(-1,$GUI_HIDE)

	$x += 95
	$g_hChkUpgradeQueen = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
		$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeQueen_Info_01", "Enable upgrading of your Queen when you have enough Dark Elixir (Saving Min. Dark Elixir)") & @CRLF & _
				   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeQueen_Info_02", "You can manually locate your Queens Altar on Misc Tab") & @CRLF & _
				   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeHeroes_Info_01", -1) & @CRLF & _
				   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeQueen_Info_03", "Enabled with TownHall 9 and higher")
		_GUICtrlSetTip(-1, $sTxtTip)
		GUICtrlSetOnEvent(-1, "chkUpgradeQueen")
	_GUICtrlCreateIcon($g_sLibIconPath, $eIcnQueenUpgr, $x + 18, $y, 64, 64)
		_GUICtrlSetTip(-1, $sTxtTip)
	$g_hPicChkQueenSleepWait = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnSleepingQueen, $x + 18, $y, 64, 64)
		_GUICtrlSetTip(-1, $sTxtTip)
		GUICtrlSetState(-1,$GUI_HIDE)

	$x += 95
	$g_hChkUpgradeWarden = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
		$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeWarden_Info_01", "Enable upgrading of your Warden when you have enough Elixir (Saving Min. Elixir)") & @CRLF & _
				  GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeWarden_Info_02", "You can manually locate your Wardens Altar on Misc Tab") & @CRLF & _
				  GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeHeroes_Info_01", -1) & @CRLF & _
				  GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeWarden_Info_03", "Enabled with TownHall 11")
		_GUICtrlSetTip(-1, $sTxtTip)
		GUICtrlSetOnEvent(-1, "chkUpgradeWarden")
		GUICtrlSetColor ( -1, $COLOR_ERROR )
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnWardenUpgr, $x + 18, $y, 64, 64)
		_GUICtrlSetTip(-1, $sTxtTip)
	$g_hPicChkWardenSleepWait = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnSleepingWarden, $x + 18, $y, 64, 64)
		_GUICtrlSetTip(-1, $sTxtTip)
		GUICtrlSetState(-1,$GUI_HIDE)

	$x += 95
	$g_hChkUpgradeChampion = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
		$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeChampion_Info_01", "Enable upgrading of your Royal Champion when you have enough Dark Elixir (Saving Min. Dark Elixir)") & @CRLF & _
				   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeChampion_Info_02", "You can manually locate your Royal Champion Altar on Misc Tab") & @CRLF & _
				   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeHeroes_Info_01", -1) & @CRLF & _
				   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeChampion_Info_03", "Enabled with TownHall 13 and higher")
		_GUICtrlSetTip(-1, $sTxtTip)
		GUICtrlSetOnEvent(-1, "chkUpgradeChampion")
		GUICtrlSetColor ( -1, $COLOR_ERROR )
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnChampionUpgr, $x + 18, $y, 64, 64)
		_GUICtrlSetTip(-1, $sTxtTip)
	$g_hPicChkChampionSleepWait = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnSleepingChampion, $x + 18, $y, 64, 64)
		_GUICtrlSetTip(-1, $sTxtTip)
		GUICtrlSetState(-1,$GUI_HIDE)

	$y += 60
	$x = 25
		$g_hLblHeroReservedBuilderTop = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "LblHeroReservedBuilderTop", "Reserve ") , $x, $y + 15, -1, -1)
		$g_hCmbHeroReservedBuilder = GUICtrlCreateCombo("", $x + 50, $y + 15, 35, 21, $CBS_DROPDOWNLIST, $WS_EX_RIGHT)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "CmbHeroReservedBuilder", "At least this many builders have to upgrade heroes, or wait for it."))
			GUICtrlSetData(-1, "|0|1|2|3", "0")
			GUICtrlSetOnEvent(-1, "cmbHeroReservedBuilder")
		$g_hLblHeroReservedBuilderBottom = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "LblHeroReservedBuilderBottom", "builder/s for hero upgrade"), $x + 95, $y + 15, -1, -1)
	
		$g_hBtnHeroEquipment = GUICtrlCreateButton("Hero Equipment", $x + 250, $y + 15, -1, -1)
		GUICtrlSetOnEvent(-1, "BtnHeroEquipment")
	
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
; Pets
	Local $x = 25, $y = 180
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Pets", "LblAutoUpgrading_02", "Pets Upgrade :"), $x - 20, $y -20, $g_iSizeWGrpTab3 - 2, 240)
		$g_hChkUpgradePets[$ePetLassi] = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
			$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeLassi_Info_01", "Enable upgrading of your Pet, Lassi, when you have enough Dark Elixir")
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkUpgradePets")
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnPetLassi, $x + 18, $y, 64, 64)
			_GUICtrlSetTip(-1, $sTxtTip)

	$x += 95
		$g_hChkUpgradePets[$ePetElectroOwl] = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
			$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeElectroOwl_Info_01", "Enable upgrading of your Pet, Electro Owl, when you have enough Dark Elixir")
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkUpgradePets")
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnPetElectroOwl, $x + 18, $y, 64, 64)
			_GUICtrlSetTip(-1, $sTxtTip)

	$x += 95
		$g_hChkUpgradePets[$ePetMightyYak] = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
			$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeMightyYak_Info_01", "Enable upgrading of your Pet, Mighty Yak, when you have enough Dark Elixir")
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkUpgradePets")
			GUICtrlSetColor ( -1, $COLOR_ERROR )
			_GUICtrlCreateIcon($g_sLibIconPath, $eIcnPetMightyYak, $x + 18, $y, 64, 64)
			_GUICtrlSetTip(-1, $sTxtTip)

	$x += 95
		$g_hChkUpgradePets[$ePetUnicorn] = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
			$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeUnicorn_Info_01", "Enable upgrading of your Pet, Unicorn, when you have enough Dark Elixir")
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkUpgradePets")
			GUICtrlSetColor ( -1, $COLOR_ERROR )
			_GUICtrlCreateIcon($g_sLibIconPath, $eIcnPetUnicorn, $x + 18, $y, 64, 64)
			_GUICtrlSetTip(-1, $sTxtTip)
			
	;----------------------------------------------NEW
	$x = 25
	$y += 80
		$g_hChkUpgradePets[$ePetFrosty] = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
			$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeFrosty_Info_01", "Enable upgrading of your Pet, Frosty, when you have enough Dark Elixir")
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkUpgradePets")
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnPetFrosty, $x + 18, $y, 64, 64)
			_GUICtrlSetTip(-1, $sTxtTip)

	$x += 95
		$g_hChkUpgradePets[$ePetDiggy] = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
			$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradeDiggy_Info_01", "Enable upgrading of your Pet, Diggy, when you have enough Dark Elixir")
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkUpgradePets")
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnPetDiggy, $x + 18, $y + 2, 64, 64)
			_GUICtrlSetTip(-1, $sTxtTip)

	$x += 95
		$g_hChkUpgradePets[$ePetPoisonLizard] = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
			$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradePoisonLizard_Info_01", "Enable upgrading of your Pet, Poison Lizard, when you have enough Dark Elixir")
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkUpgradePets")
			GUICtrlSetColor ( -1, $COLOR_ERROR )
			_GUICtrlCreateIcon($g_sLibIconPath, $eIcnPetPoisonLizard, $x + 18, $y, 64, 64)
			_GUICtrlSetTip(-1, $sTxtTip)

	$x += 95
		$g_hChkUpgradePets[$ePetPhoenix] = GUICtrlCreateCheckbox("", $x, $y + 25, 17, 17)
			$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgradePhoenix_Info_01", "Enable upgrading of your Pet, Phoenix, when you have enough Dark Elixir")
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkUpgradePets")
			GUICtrlSetColor ( -1, $COLOR_ERROR )
			_GUICtrlCreateIcon($g_sLibIconPath, $eIcnPetPhoenix, $x + 18, $y, 64, 64)
			_GUICtrlSetTip(-1, $sTxtTip)

	$x = 20
	$y += 75
		$g_hChkSortPetUpgrade = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Pets", "ChkSortPetUpgrade", "Sort Pet Upgrade By:"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "SortPetUpgrade")
		$g_hCmbSortPetUpgrade = GUICtrlCreateCombo("", $x + 120, $y, 120, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		Local $sCmbTxt = "Lower Level|Lower Cost"
		GUICtrlSetData(-1, $sCmbTxt, "Lower Cost")
		GUICtrlSetOnEvent(-1, "SortPetUpgrade")
	$y += 23
		$g_hChkSyncSaveDE = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Pets", "ChkSortPetUpgrade", "Sync Save DE with AutoUpgrade"), $x, $y, -1, -1)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
EndFunc   ;==>CreateHeroesSubTab

Func CreateHeroEquipment()
	Local $x = 60, $y = 5
	$g_hGUI_HeroEquipment = _GUICreate(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "GUI_Equipment", "Hero Equipment"), $_GUI_MAIN_WIDTH - 4, $_GUI_MAIN_HEIGHT - 100, $g_iFrmBotPosX, $g_iFrmBotPosY + 80, $WS_DLGFRAME, -1, $g_hFrmBot)
	
	GUICtrlCreateIcon($g_sLibIconPath, $eIcnBlacksmith, $x + 40, $y + 15, 48, 48)
	$g_hChkCustomEquipmentOrderEnable = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "ChkCustomEquipmentEnable", "Auto Equipment Upgrades"), $x + 100, $y + 30, -1, -1)
	GUICtrlSetState(-1, $GUI_UNCHECKED)
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "ChkCustomEquipmentEnable_Info_01", "Enable to select a custom equipment upgrade order"))
	GUICtrlSetOnEvent(-1, "chkEquipmentOrder")

	Local $sComboData = ""
	For $t = 0 To UBound($g_asEquipmentOrderList) - 1
		$sComboData &= $g_asEquipmentOrderList[$t][0] & "|"
	Next

	Local $txtEquipmentOrder = GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "TxtEquipmentOrder", "Select Equipment To Upgrade In Position ")

	; Create ComboBox(es) for selection of troop training order
	$x = 10
	$y = 90
	For $z = 0 To UBound($g_ahCmbEquipmentOrder) - 1
		If $z < 9 Then
			$g_EquipmentOrderLabel[$z] = GUICtrlCreateLabel($z + 1 & ":", $x, $y + 3)
			$g_hChkCustomEquipmentOrder[$z] = GUICtrlCreateCheckbox("", $x + 15, $y, -1, 20)
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "ChkCustomEquipmentOrder_Info_01", "Enable or disable a custom equipment upgrade"))
			$g_ahCmbEquipmentOrder[$z] = GUICtrlCreateCombo("", $x + 35, $y, 120, 25, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
			GUICtrlSetOnEvent(-1, "GUIRoyalEquipmentOrder")
			GUICtrlSetData(-1, $sComboData, "")
			_GUICtrlSetTip(-1, $txtEquipmentOrder & $z + 1)
			$g_ahImgEquipmentOrder[$z] = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnOptions, $x + 160, $y - 2, 24, 24)
			$g_ahImgEquipmentOrder2[$z] = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnOptions, $x + 190, $y - 2, 24, 24)
			$y += 30 ; move down to next combobox location
		EndIf
		
		If $z = 9 Then
			$x = 240
			$y = 90
		EndIf
		
		If $z >= 9 Then
			$g_EquipmentOrderLabel[$z] = GUICtrlCreateLabel($z + 1 & ":", $x, $y + 3)
			$g_hChkCustomEquipmentOrder[$z] = GUICtrlCreateCheckbox("", $x + 15, $y, -1, 20)
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "ChkCustomEquipmentOrder_Info_01", "Enable or disable a custom equipment upgrade"))
			$g_ahCmbEquipmentOrder[$z] = GUICtrlCreateCombo("", $x + 35, $y, 120, 25, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
			GUICtrlSetOnEvent(-1, "GUIRoyalEquipmentOrder")
			GUICtrlSetData(-1, $sComboData, "")
			_GUICtrlSetTip(-1, $txtEquipmentOrder & $z + 1)
			$g_ahImgEquipmentOrder[$z] = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnOptions, $x + 160, $y - 2, 24, 24)
			$g_ahImgEquipmentOrder2[$z] = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnOptions, $x + 190, $y - 2, 24, 24)
			$y += 30 ; move down to next combobox location
		EndIf
	Next

	$x = 180
	$y = 380
	$g_hBtnRegularOrder = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnRegularOrder", "Sort in Original Order"), $x, $y, 130, 20)
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnRegularOrder_Info_01", "Push button to sort equipment in original order"))
	GUICtrlSetOnEvent(-1, "btnRegularOrder")

	$x = 125
	$y = 470
	$g_hBtnRemoveEquipment = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnRemoveEquipment", "Empty Equipment List"), $x - 6, $y, 130, 20)
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnRemoveEquipment_Info_01", "Push button to remove all equipment from list and start over"))
	GUICtrlSetOnEvent(-1, "btnRemoveEquipment")

	$x += 165
	$g_hBtnEquipmentOrderSet = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnEquipmentOrderSet", "Apply New Order"), $x - 6, $y, 96, 20)
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnEquipmentOrderSet_Info_01", "Push button when finished selecting custom equipment upgrading order") & @CRLF & _
			GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnEquipmentOrderSet_Info_02", "Icon changes color based on status: Red= Not Set, Green = Order Set") & @CRLF & _
			GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnEquipmentOrderSet_Info_03", "When not all equipment slots are filled, will use random equipment order in empty slots!"))
	GUICtrlSetOnEvent(-1, "btnEquipmentOrderSet")
	$g_ahImgEquipmentOrderSet = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnSilverStar, $x + 119, $y, 18, 18)

	$y = 510
	$g_hBtnHeroEquipmentClose = GUICtrlCreateButton("Close", 370, $y, 85, 25)
	GUICtrlSetOnEvent(-1, "CloseHeroEquipment")
EndFunc   ;==>CreateHeroEquipment

Func CreateBuildingsSubTab()
	Local $sTxtShowType = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtShowType", "This shows type of upgrade, click to show location")
	Local $sTxtStatus = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtStatus", "Status: Red=not programmed, Yellow=programmed, not completed, Green=Completed")
	Local $sTxtShowName = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtShowName", "This box is updated with unit name after upgrades are checked")
	Local $sTxtShowLevel = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtShowLevel", "This unit box is updated with unit level after upgrades are checked")
	Local $sTxtShowCost = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtShowCost", "This upgrade cost box is updated after upgrades are checked")
	Local $sTxtShowTime = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtShowTime", "This box is updated with time length of upgrade after upgrades are checked")
	Local $sTxtChkRepeat = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtChkRepeat", "Check box to Enable Upgrade to repeat continuously")
	Local $sTxtShowEndTime = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtShowEndTime", "This box is updated with estimate end time of upgrade after upgrades are checked")
	Local $sTxtCheckBox = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtCheckBox", "Check box to Enable Upgrade")
	Local $sTxtAfterUsing = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtAfterUsing", "after using Locate Upgrades button")

	Local $x = 25, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "Group_01", "Buildings or Heroes"), $x - 20, $y - 20, $g_iSizeWGrpTab3, 30 + ($g_iUpgradeSlots * 22))
	$x -= 7
	; table header
	$y -= 7
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "Table header_01", "Unit Name"), $x + 71, $y, 70, 18)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "Table header_02", "Lvl"), $x + 153, $y, 40, 18)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "Table header_03", "Type"), $x + 173, $y, 50, 18)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "Table header_04", "Cost"), $x + 219, $y, 50, 18)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "Table header_05", "Time"), $x + 270, $y, 50, 18)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "Table header_06", "Rep."), $x + 392, $y, 50, 18)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "Table header_07", "Estimated End"), $x + 315, $y, 75, 18)
	$y += 13

	; Create upgrade GUI slots 0 to $g_iUpgradeSlots
	; Can add more slots with $g_iUpgradeSlots value in Global variables file, 6 is minimum and max limit is 15 before GUI is too long.
	For $i = 0 To $g_iUpgradeSlots - 1
		$g_hPicUpgradeStatus[$i]= _GUICtrlCreateIcon($g_sLibIconPath, $eIcnRedLight, $x - 10, $y + 1, 14, 14)
			_GUICtrlSetTip(-1, $sTxtStatus)
		$g_hChkUpgrade[$i] = GUICtrlCreateCheckbox($i + 1 & ":", $x + 5, $y + 1, 34, 15)
			_GUICtrlSetTip(-1,  $sTxtCheckBox & " #" & $i + 1 & " " & $sTxtAfterUsing)
;			GUICtrlSetFont(-1, 8)
			GUICtrlSetOnEvent(-1, "btnchkbxUpgrade")
		$g_hTxtUpgradeName[$i] = GUICtrlCreateInput("", $x + 40, $y, 107, 17, BitOR($ES_CENTER, $GUI_SS_DEFAULT_INPUT, $ES_READONLY, $ES_NUMBER))
;			GUICtrlSetFont(-1, 8)
			_GUICtrlSetTip(-1, $sTxtShowName)
		$g_hTxtUpgradeLevel[$i] = GUICtrlCreateInput("", $x + 150, $y, 23, 17, BitOR($ES_CENTER, $GUI_SS_DEFAULT_INPUT, $ES_READONLY, $ES_NUMBER))
;			GUICtrlSetFont(-1, 8)
			_GUICtrlSetTip(-1, $sTxtShowLevel)
		$g_hPicUpgradeType[$i]= _GUICtrlCreateIcon($g_sLibIconPath, $eIcnBlank, $x + 178, $y + 1, 15, 15)
			_GUICtrlSetTip(-1, $sTxtShowType)
			GUICtrlSetOnEvent(-1, "picUpgradeTypeLocation")
		$g_hTxtUpgradeValue[$i] = GUICtrlCreateInput("", $x + 197, $y, 65, 17, BitOR($ES_CENTER, $GUI_SS_DEFAULT_INPUT, $ES_READONLY, $ES_NUMBER))
;			GUICtrlSetFont(-1, 8)
			_GUICtrlSetTip(-1, $sTxtShowCost)
		;HArchH was 35 wide.
		$g_hTxtUpgradeTime[$i] = GUICtrlCreateInput("", $x + 266, $y, 45, 17, BitOR($ES_CENTER, $GUI_SS_DEFAULT_INPUT, $ES_READONLY, $ES_NUMBER))
;			GUICtrlSetFont(-1, 8)
			_GUICtrlSetTip(-1, $sTxtShowTime)
		;HArchH was 305 start and 85 wide
		$g_hTxtUpgradeEndTime[$i] = GUICtrlCreateInput("", $x + 315, $y, 75, 17, BitOR($ES_LEFT, $GUI_SS_DEFAULT_INPUT, $ES_READONLY, $ES_NUMBER))
			GUICtrlSetFont(-1, 7)
			_GUICtrlSetTip(-1, $sTxtShowEndTime)
		$g_hChkUpgradeRepeat[$i] = GUICtrlCreateCheckbox("", $x + 395, $y + 1, 15, 15)
;			GUICtrlSetFont(-1, 8)
			_GUICtrlSetTip(-1, $sTxtChkRepeat)
			GUICtrlSetOnEvent(-1, "btnchkbxRepeat")

	$y += 22
	Next
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x += 5
	$y += 8
		_GUICtrlCreateIcon ($g_sLibIconPath, $eIcnGold, $x - 15, $y, 15, 15)
		GUICtrlCreateLabel( GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "LblUpgrMinGold", "Min. Gold") & ":", $x + 5, $y + 3, -1, -1)
		$g_hTxtUpgrMinGold = GUICtrlCreateInput("250000", $x + 55, $y, 61, 17, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtUpgrMinGold_Info_01", "Save this much Gold after the upgrade completes.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtUpgrMinGold_Info_02", "Set this value as needed to save for searching, or wall upgrades."))
			GUICtrlSetLimit(-1, 8)
	$y += 18
		_GUICtrlCreateIcon ($g_sLibIconPath, $eIcnElixir, $x - 15, $y, 15, 15)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "LblUpgrMinElixir", "Min. Elixir") & ":", $x + 5, $y + 3, -1, -1)
		$g_hTxtUpgrMinElixir = GUICtrlCreateInput("250000", $x + 55, $y, 61, 17, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtUpgrMinElixir_Info_01", "Save this much Elixir after the upgrade completes") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtUpgrMinElixir_Info_02", "Set this value as needed to save for making troops or wall upgrades."))
			GUICtrlSetLimit(-1, 8)
	$x -= 15
	$y -= 8
		_GUICtrlCreateIcon ($g_sLibIconPath, $eIcnDark, $x + 140, $y, 15, 15)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "LblUpgrMinDark", "Min. Dark") & ":", $x + 160, $y + 3, -1, -1)
		$g_hTxtUpgrMinDark = GUICtrlCreateInput("3000", $x + 210, $y, 61, 17, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtUpgrMinDark_Info_01", "Save this amount of Dark Elixir after the upgrade completes.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "TxtUpgrMinDark_Info_02", "Set this value higher if you want make war troops."))
			GUICtrlSetLimit(-1, 6)
	$y -= 8

	; Locate/reset buttons
		GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "BtnLocateUpgrades", "Locate Upgrades"), $x + 290, $y - 4, 120, 18, BitOR($BS_MULTILINE, $BS_VCENTER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "BtnLocateUpgrades_Info_01", "Push button to locate and record information on building/Hero upgrades") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "BtnLocateUpgrades_Info_02", "Any upgrades with repeat enabled are skipped and can not be located again"))
			GUICtrlSetOnEvent(-1, "btnLocateUpgrades")
		GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "BtnResetUpgrades", "Reset Upgrades"), $x + 290, $y + 16, 120, 18, BitOR($BS_MULTILINE, $BS_VCENTER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "BtnResetUpgrades_Info_01", "Push button to reset & remove upgrade information") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Buildings", "BtnResetUpgrades_Info_02", "If repeat box is checked, data will not be reset"))
		GUICtrlSetOnEvent(-1, "btnResetUpgrade")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

EndFunc   ;==>CreateBuildingsSubTab

Func CreateWallsSubTab()
	Local $x = 25, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "Group_01", "Walls"), $x - 20, $y - 20, $g_iSizeWGrpTab3, 220)
		$x = 10
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnWall, $x, $y - 6, 32, 32)
		$x = 50
		$g_hChkWalls = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkWalls", "Auto Wall Upgrade"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkWalls_Info_01", "Check this to upgrade Walls if there are enough resources."))
			GUICtrlSetState(-1, $GUI_ENABLE)
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "chkWalls")
		$x += 20
		$y += 20
		$g_hChkUseGold = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseGold", "Use Gold"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseGold_Info_01", "Use only Gold for Walls.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseGold_Info_02", "Available at all Wall levels."))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "chkWalls")
		$y += 20
		$g_hChkUseElixir = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixir", "Use Elixir"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixir_Info_01", "Use only Elixir for Walls.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixir_Info_02", "Available only at Wall levels upgradeable with Elixir."))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "chkWalls")
		$y += 20
		$g_hChkUseElixirGold = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixirGold", "Try Elixir first, Gold second"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixirGold_Info_01", "Try to use Elixir first. If not enough Elixir try to use Gold second for Walls.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixir_Info_02", -1))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "chkWalls")
		
		$y += 30
		$g_hAutoAdjustSaveWall = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "AutoAdjustSaveWall", "Auto Adjust Save Min Gold And Elixir"), $x - 20, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "AutoAdjustSaveWall", "Only work with RushTH enabled") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "AutoAdjustSaveWall", "Bot will adjust save min gold and elixir to make sure you can upgrade TH"))
			GUICtrlSetState(-1, $GUI_ENABLE)
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "chkAutoAdjustSaveMinWall")
			
		$y += 25
		_GUICtrlCreateIcon ($g_sLibIconPath, $eIcnGold, $x - 20, $y, 16, 16)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Goldtosave", "Min. Gold to save"), $x, $y, -1, -1)
		$g_hTxtWallMinGold = GUICtrlCreateInput("250000", $x + 110, $y, 80, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Goldtosave_Info_01", "Save this much Gold after the wall upgrade completes,") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Goldtosave_Info_02", "Set this value to save Gold for other upgrades, or searching."))
			GUICtrlSetLimit(-1, 8)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$y += 20
		_GUICtrlCreateIcon ($g_sLibIconPath, $eIcnElixir, $x - 20, $y, 16, 16)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Elixirtosave", "Min. Elixir to save"), $x, $y, -1, -1)
		$g_hTxtWallMinElixir = GUICtrlCreateInput("250000", $x + 110, $y, 80, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Elixirtosave_Info_01", "Save this much Elixir after the wall upgrade completes,") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Elixirtosave_Info_02", "Set this value to save Elixir for other upgrades or troop making."))
			GUICtrlSetLimit(-1, 8)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$y += 25
		$g_hBtnFindWalls = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "BtnFindWalls", "TEST Wall Detect"), $x - 20, $y, 110, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "BtnFindWalls_Info_01", "Click here to test the Wall Detection."))
		GUICtrlSetOnEvent(-1, "btnWalls")

		$x = 210
		$y = 45
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnBuilder, $x, $y, 32, 32)
		$x += 10
		$g_hChkSaveWallBldr = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkSaveWallBldr", "Save ONE builder for Walls"), $x + 30, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkSaveWallBldr_Info_01", "Check this to reserve 1 builder exclusively for walls and") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkSaveWallBldr_Info_02", "reduce the available builder by 1 for other upgrades"))
			GUICtrlSetState(-1, $GUI_ENABLE)
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "chkSaveWallBldr")
		$y += 20
		$g_hChkOnly1Builder = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkOnly1Builder", "Only Upgrade If Only 1 Builder left"), $x + 30, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkSaveWallBldr_Info_01", "Only Upgrade wall if there is only 1 builder left") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkSaveWallBldr_Info_02", "So If builder stacked, it will priority other upgrade"))
			GUICtrlSetState(-1, $GUI_ENABLE)
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "chkWallOnly1Builder")
		$y += 24
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "TargetWall", "Upgrade Wall Level:"), $x + 30, $y + 3, -1, -1)
		$g_hCmbTargetWallLevel = GUICtrlCreateCombo("", $x + 140, $y, 50, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbTargetWallLevel", "Select Wall Level to Upgrade or select Any for any level wall"))
		GUICtrlSetData(-1, "Any|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17", "Any")
		GUICtrlSetOnEvent(-1, "cmbWallLevel")
		$y += 20
		$g_hLblWallCost = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "WallCost", ""), $x + 20, $y, -1, -1)
		

	GUICtrlCreateGroup("", -99, -99, 1, 1)

EndFunc   ;==>CreateWallsSubTab


Func CreateAutoUpgradeSubTab()

	Local $x = 25, $y = 40
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Group_01", "Auto Upgrade"), $x - 20, $y - 15, $g_iSizeWGrpTab3, 90)

		$g_hChkAutoUpgrade = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "ChkAutoUpgrade", "Enabled"), $x - 5, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "ChkAutoUpgrade_Info_01", "Check box to enable automatically starting Upgrades from builders menu"))
			GUICtrlSetOnEvent(-1, "chkAutoUpgrade")
		$g_hLblAutoUpgrade = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Label_01", "Save"), $x, $y + 27, -1, -1)
		$g_hTxtSmartMinGold = GUICtrlCreateInput("150000", $x + 33, $y + 24, 60, 21, BitOR($ES_CENTER, $ES_NUMBER))
			_GUICtrlCreateIcon($g_sLibIconPath, $eIcnGold, $x + 98, $y + 27, 16, 16)
		$g_hTxtSmartMinElixir = GUICtrlCreateInput("150000", $x + 118, $y + 24, 60, 21, BitOR($ES_CENTER, $ES_NUMBER))
			_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixir, $x + 183, $y + 27, 16, 16)
		$g_hTxtSmartMinDark = GUICtrlCreateInput("1500", $x + 203, $y + 24, 60, 21, BitOR($ES_CENTER, $ES_NUMBER))
			_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDark, $x + 268, $y + 27, 16, 16)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Label_02", "after launching upgrade"), $x + 290, $y + 27, -1, -1)

		$g_hChkResourcesToIgnore[0] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Ignore_01", "Ignore Gold Upgrades"), $x, $y + 50, -1, -1)
			GUICtrlSetOnEvent(-1, "chkResourcesToIgnore")
		$g_hChkResourcesToIgnore[1] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Ignore_02", "Ignore Elixir Upgrades"), $x + 130, $y + 50, -1, -1)
			GUICtrlSetOnEvent(-1, "chkResourcesToIgnore")
		$g_hChkResourcesToIgnore[2] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Ignore_03", "Ignore Dark Elixir Upgrades"), $x + 258, $y + 50, -1, -1)
			GUICtrlSetOnEvent(-1, "chkResourcesToIgnore")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Group_02", "Upgrades to ignore"), $x - 20, $y + 75, $g_iSizeWGrpTab3, 200)
		Local $x = 20, $y = 130
		$g_hChkUpgradesToIgnore[0] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Town Hall", "Town Hall"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[1] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Barbarian King", "Barbarian King"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[2] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Archer Queen", "Archer Queen"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[3] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Grand Warden", "Grand Warden"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x = 20
		$y += 20
		$g_hChkUpgradesToIgnore[4] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Royal Champion", "Royal Champion"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[5] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Clan Castle", "Clan Castle"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[6] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Laboratory", "Laboratory"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[7] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Wall", "Wall"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x = 20
		$y += 20
		$g_hChkUpgradesToIgnore[8] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Barracks", "Barracks"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[9] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Dark Barracks", "Dark Barracks"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[10] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Spell Factory", "Spell Factory"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[11] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Dark Spell Factory", "Dark Spell Factory"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x = 20
		$y += 20
		$g_hChkUpgradesToIgnore[12] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Gold Mine", "Gold Mine"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[13] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Elixir Collector", "Elixir Collector"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[14] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "DE Drill", "DE Drill"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[15] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Cannon", "Cannon"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x = 20
		$y += 20
		$g_hChkUpgradesToIgnore[16] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Archer Tower", "Archer Tower"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[17] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Mortar", "Mortar"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[18] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Hidden Tesla", "Hidden Tesla"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[19] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Traps", "Traps", "Traps"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x = 20
		$y += 20
		$g_hChkUpgradesToIgnore[20] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Wizard Tower", "Wizard Tower"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[21] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Bomb Tower", "Bomb Tower"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[22] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Air Defense", "Air Defense"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[23] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Air Sweeper", "Air Sweeper"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x = 20
		$y += 20
		$g_hChkUpgradesToIgnore[24] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "X-Bow", "X-Bow"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[25] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Inferno Tower", "Inferno Tower"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[26] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Eagle Artillery", "Eagle Artillery"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[27] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Scattershot", "Scattershot"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x = 20
		$y += 20
		$g_hChkUpgradesToIgnore[28] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Army Camp", "Army Camp"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[29] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Gold Storage", "Gold Storage"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[30] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Elixir Storage", "Elixir Storage"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[31] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "DE Storage", "DE Storage"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x = 20
		$y += 20
		$g_hChkUpgradesToIgnore[32] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Workshop", "Workshop"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[33] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Pet House", "Pet House"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[34] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Builder's Hut", "Builder's Hut"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
		$x += 100
		$g_hChkUpgradesToIgnore[35] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Traps", "TH Weapon", "TH Weapon"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUpgradesToIgnore")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$x = 20
	$y += 24
	$g_hChkRushTH = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Traps", "Rush TH", "Rush TH"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkRushTH")
		_GUICtrlSetTip(-1, "Toggle to Make RushTH, Wont Ugrade Defense Or colletor")
	$g_hBtnRushTHOption = GUICtrlCreateButton("Upgrade Setting", $x + 65, $y + 1, -1, 23)
			GUICtrlSetOnEvent(-1, "BtnRushTHOption")
	$x = 180
	$g_hUseWallReserveBuilder = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Traps", "UseWallReserveBuilder", "Use Wall Reserve Builder"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUseWallReserveBuilder")
		_GUICtrlSetTip(-1, "Enable Using Wall Reserve Building for Upgrade" & @CRLF & "Will Only activate if current upgrade time < 24H")
	
	$x = 330
	$g_hUseBuilderPotion = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Traps", "UseBuilderPotion", "Use BuilderPotion"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUseWallReserveBuilder")
		_GUICtrlSetTip(-1, "Enable Using Builder Potion" & @CRLF & "Will Only activate if current upgrade time > 9H")

	$x = 5
		$g_hTxtAutoUpgradeLog = GUICtrlCreateEdit("", $x, 340, $g_iSizeWGrpTab3, 62, BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY))
		GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "TxtAutoUpgradeLog", "------------------------------------------------ AUTO UPGRADE LOG ------------------------------------------------"))

EndFunc   ;==>CreateAutoUpgradeGUI

Func CreateRushTHOption()

	Local $TxtRushTHOptionTH = "Level 9|Level 10|Level 11|Level 12|Level 13|Level 14|Level 15|Rush to Max Level"
	Local $TxtRushTHOptionBarracks = "2 Unlock Archer|3 Unlock Giant|4 Unlock Goblin|5 Unlock Wall Breaker|" & _
									"6 Unlock Balloon|7 Unlock Wizard|8 Unlock Healer|9 Unlock Dragon|" & _
									"10 Unlock Pekka|11 Unlock Baby Dragon|12 Unlock Miner|13 Unlock Electro Dragon|" & _
									"14 Unlock Yeti|15 Unlock Dragon Rider|16 Unlock Electro Titan|" & _
									"17 Unlock Root Rider"
	Local $TxtRushTHOptionDarkBarracks = "2 Unlock Hog Rider|3 Unlock Valkyrie|4 Unlock Golem|5 Unlock Witch|" & _
									"6 Unlock Lava Hound|7 Unlock Bowler|8 Unlock Ice Golem|9 Unlock Headhunter|" & _
									"10 Unlock Appr Warden"
	Local $TxtRushTHOptionSpellF = "2 Unlock Healing Spell|3 Unlock Rage Spell|4 Unlock Jump & Freeze Spell|5 Unlock Clone Spell|" & _
									"6 Unlock Invisibility Spell|7 Unlock Recall Spell"
	Local $TxtRushTHOptionDSpellF = "2 Unlock EarthQuake Spell|3 Unlock Haste Spell|4 Unlock Skeleton Spell|5 Unlock Bat Spell|6 Unlock Overgrowth Spell"

	$g_hGUI_RushTHOption = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - AutoUpgrade", "GUI_RushTHOption", "Optional Settings: Set Max Level to Upgrade"), 330, 430, $g_iFrmBotPosX, $g_iFrmBotPosY + 200, $WS_DLGFRAME, $WS_EX_TOPMOST)
	Local $x = 25, $y = 25
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - AutoUpgrade", "SelectRushTHOption", "Upgrade To Level :"), $x - 20, $y - 20, 320, 160)
	$x += 10
	$y += 5
	For $i = 0 To Ubound($RushTHOption) - 1
		GUICtrlCreateLabel($RushTHOption[$i] & ":", $x - 19, $y + 3 + 25*$i, -1, 18)
		$g_ahCmbRushTHOption[$i] = GUICtrlCreateCombo("", $x + 90, $y + 25*$i, 185, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			Switch $i
				Case 0
					GUICtrlSetData(-1,  $TxtRushTHOptionTH, "Rush to Max Level")
				Case 1
					GUICtrlSetData(-1,  $TxtRushTHOptionBarracks, "17 Unlock Root Rider")
				Case 2
					GUICtrlSetData(-1,  $TxtRushTHOptionDarkBarracks, "10 Unlock Appr Warden")
				Case 3
					GUICtrlSetData(-1,  $TxtRushTHOptionSpellF, "7 Unlock Recall Spell")
				Case 4
					GUICtrlSetData(-1,  $TxtRushTHOptionDSpellF, "6 Unlock Overgrowth Spell")
			EndSwitch
	Next
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = 25
	$y = 190
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - AutoUpgrade", "SelectEssentialBuilding", "Select Essential Building to Upgrade :"), $x - 20, $y - 20, 320, 190)
		$x += 10
		$g_hchkEssentialUpgrade[0] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "X-Bow", "X-Bow"), $x, $y, -1, -1)
		GUICtrlSetState(-1, $GUI_ENABLE)
		$y += 20
		$g_hchkEssentialUpgrade[1] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Inferno Tower", "Inferno Tower"), $x, $y, -1, -1)
		GUICtrlSetState(-1, $GUI_ENABLE)
		$y += 20
		$g_hchkEssentialUpgrade[2] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Eagle Artillery", "Eagle Artillery"), $x, $y, -1, -1)
		GUICtrlSetState(-1, $GUI_ENABLE)
		$y += 20
		$g_hchkEssentialUpgrade[3] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Scattershot", "Scattershot"), $x, $y, -1, -1)
		GUICtrlSetState(-1, $GUI_ENABLE)

		$x += 130
		$y = 190
		$g_hchkEssentialUpgrade[4] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Wizard Tower", "Wizard Tower"), $x, $y, -1, -1)
		$y += 20
		$g_hchkEssentialUpgrade[5] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Bomb Tower", "Bomb Tower"), $x, $y, -1, -1)
		$y += 20
		$g_hchkEssentialUpgrade[6] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Air Defense", "Air Defense"), $x, $y, -1, -1)
		$y += 20
		$g_hchkEssentialUpgrade[7] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Air Sweeper", "Air Sweeper"), $x, $y, -1, -1)

		$x = 15
		$y += 25
		$g_hUpgradeOnlyTHLevelAchieve = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "OnlyUpgradeIfTHLevelAchieve", "Only Upgrade Buildings If TH Level Already Achieved"), $x, $y, -1, -1)
		$y += 20
		$g_hHeroPriority = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "HeroPriority", "Prioritizes Hero Upgrade"), $x, $y, -1, -1)
		$y += 20
		$g_hUseHeroBooks = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "UserHeroBooks", "Use Hero Books, If UpgradeTime is more than"), $x, $y, -1, -1)
		$g_hHeroMinUpgradeTime = GUICtrlCreateInput("5", $x + 240, $y, 25, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		GUICtrlCreateLabel("Days", $x + 270, $y + 3)
		$y += 20
		$g_hUpgradeOtherDefenses = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "UpgradeOtherDefenses", "Upgrades Other Defenses (From Essential Upgrade)"), $x, $y, -1, -1)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$y = 300
	$g_hBtnRushTHOptionClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - AutoUpgrade", "BtnRushTHOptionClose", "Close"), 230, $y + 65, 85, 25)
		GUICtrlSetOnEvent(-1, "CloseRushTHOption")

EndFunc ;==>CreateRushTHOption
