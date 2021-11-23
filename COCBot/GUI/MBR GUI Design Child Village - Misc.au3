; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "Misc" tab under the "Village" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017), Chilly-Chill (2019)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once
Global $g_hGUI_MISC = 0, $g_hGUI_MISC_TAB = 0, $g_hGUI_MISC_TAB_ITEM1 = 0, $g_hGUI_MISC_TAB_ITEM2 = 0, $g_hGUI_MISC_TAB_ITEM3 = 0

Global $g_hChkBotStop = 0, $g_hCmbBotCommand = 0, $g_hCmbBotCond = 0, $g_hCmbHoursStop = 0, $g_hCmbTimeStop = 0
Global $g_LblResumeAttack = 0, $g_ahTxtResumeAttackLoot[$eLootCount] = [0, 0, 0, 0], $g_hCmbResumeTime = 0
Global $g_hChkCollectStarBonus = 0
Global $g_hTxtRestartGold = 0, $g_hTxtRestartElixir = 0, $g_hTxtRestartDark = 0
Global $g_hChkTrap = 1, $g_hChkCollect = 1, $g_hChkTombstones = 1, $g_hChkCleanYard = 0, $g_hChkGemsBox = 0
Global $g_hChkCollectCartFirst = 0, $g_hTxtCollectGold = 0, $g_hTxtCollectElixir = 0, $g_hTxtCollectDark = 0
Global $g_hBtnLocateSpellfactory = 0, $g_hBtnLocateDarkSpellFactory = 0
Global $g_hBtnLocateKingAltar = 0, $g_hBtnLocateQueenAltar = 0, $g_hBtnLocateWardenAltar = 0, $g_hBtnLocateChampionAltar = 0, $g_hBtnLocateLaboratory = 0, $g_hBtnLocatePetHouse = 0, $g_hBtnResetBuilding = 0
Global $g_hChkTreasuryCollect = 0, $g_hTxtTreasuryGold = 0, $g_hTxtTreasuryElixir = 0, $g_hTxtTreasuryDark = 0 , $g_hChkCollectAchievements = 0, $g_hChkFreeMagicItems = 0, $g_hChkCollectRewards = 0, $g_hChkSellRewards = 0

Global $g_hChkClanGamesEnabled = 0 , $g_hChkClanGames60 = 0
Global $g_hChkClanGamesLoot = 0 , $g_hChkClanGamesBattle =0 ,  $g_hChkClanGamesMiscellaneous = 0
Global $g_hChkClanGamesStopBeforeReachAndPurge = 0
Global $g_hTxtClanGamesLog = 0
Global $g_hChkClanGamesDebug = 0
Global $g_hLblRemainTime = 0 , $g_hLblYourScore = 0

;ClanGames Challenges
Global $g_hChkClanGamesDes = 0, $g_hBtnCGDes = 0, $g_hGUI_CGDes = 0, $g_hBtnCGDesSet = 0, $g_hBtnCGDesRemove = 0, $g_hBtnCGDesClose = 0, $g_sTxtCGDes
Global $g_hChkClanGamesAirTroop = 0, $g_hBtnCGAirTroop = 0, $g_hGUI_CGAirTroops = 0, $g_hBtnCGAirTroopsSet = 0, $g_hBtnCGAirTroopsRemove = 0, $g_hBtnCGAirTroopsClose = 0, $g_sTxtCGAirTroop
Global $g_hChkClanGamesGroundTroop = 0, $g_hBtnCGGroundTroop = 0, $g_hGUI_CGGroundTroops = 0, $g_hBtnCGGroundTroopSet = 0, $g_hBtnCGGroundTroopRemove = 0, $g_hBtnCGGroundTroopClose = 0, $g_sTxtCGGroundTroop
Global $g_hChkClanGamesSpell = 0, $g_hBtnCGSpell = 0, $g_hGUI_CGSpells = 0, $g_hBtnCGSpellsSet = 0, $g_hBtnCGSpellsRemove = 0, $g_hBtnCGSpellsClose = 0, $g_sTxtCGSpell
Global $g_hChkClanGamesBBBattle = 0
Global $g_hChkClanGamesBBDes = 0, $g_hBtnCGBBDes = 0, $g_hGUI_CGBBDes = 0, $g_hBtnCGBBDesSet = 0, $g_hBtnCGBBDesRemove = 0, $g_hBtnCGBBDesClose = 0, $g_sTxtCGBBDes
Global $g_hChkClanGamesBBTroops = 0, $g_hBtnCGBBTroop = 0, $g_hGUI_CGBBTroops = 0, $g_hBtnCGBBTroopsSet = 0, $g_hBtnCGBBTroopsRemove = 0, $g_hBtnCGBBTroopsClose = 0, $g_sTxtCGBBTroop
Global $g_hChkForceBBAttackOnClanGames = 0, $g_hChkClanGamesPurgeAny = 0

Func CreateVillageMisc()
	$g_hGUI_MISC = _GUICreate("", $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, 5, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_VILLAGE)

	GUISwitch($g_hGUI_MISC)
		$g_hGUI_MISC_TAB = GUICtrlCreateTab(0, 0, $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, BitOR($TCS_MULTILINE, $TCS_RIGHTJUSTIFY))
		$g_hGUI_MISC_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "MISC_TAB_ITEM1", "Normal Village"))
		CreateMiscNormalVillageSubTab()
		$g_hGUI_MISC_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "MISC_TAB_ITEM2", "Clan Games"))
		CreateMiscClanGamesV3SubTab()
		$g_hGUI_MISC_TAB_ITEM3 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "MISC_TAB_ITEM3", "Misc Mod"))
		CreateMiscModSubTab()
		CreateCGDes()
		CreateClanGamesAirTroops()
		CreateClanGamesGroundTroops()
		CreateClanGamesBBDes()
		CreateClanGamesBBTroops()
		CreateClanGamesSpell()
	GUICtrlCreateTabItem("")

EndFunc   ;==>CreateVillageMisc

Func CreateMiscNormalVillageSubTab()
	Local $sTxtTip = ""
	Local $x = 15, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_01", "Halt Attack"), $x - 10, $y - 20, $g_iSizeWGrpTab3, 145)
		$g_hChkBotStop = GUICtrlCreateCheckbox("", $x, $y, 16, 16)
			$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BotStop_Info_01", "Use these options to set when the bot will stop attacking.")
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkBotStop")

		$g_hCmbBotCommand = GUICtrlCreateCombo("", $x + 20, $y - 3, 95, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCommand_Item_01", "Halt Attack") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCommand_Item_02", "Stop Bot") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCommand_Item_03", "Close Bot") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCommand_Item_04", "Close CoC+Bot") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCommand_Item_05", "Shutdown PC") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCommand_Item_06", "Sleep PC") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCommand_Item_07", "Reboot PC") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCommand_Item_08", "Turn Idle"), GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCommand_Item_01", -1))
			GUICtrlSetOnEvent(-1, "cmbBotCond")
			GUICtrlSetState(-1, $GUI_DISABLE)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblBotCommand", "When..."), $x + 125, $y, 45, 17)

		$g_hCmbBotCond = GUICtrlCreateCombo("", $x + 173, $y - 3, 160, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_01", "G and E Full and Max.Trophy") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_02", "(G and E) Full or Max.Trophy") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_03", "(G or E) Full and Max.Trophy") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_04", "G or E Full or Max.Trophy") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_05", "Gold and Elixir Full") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_06", "Gold or Elixir Full") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_07", "Gold Full and Max.Trophy") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_08", "Elixir Full and Max.Trophy") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_09", "Gold Full or Max.Trophy") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_10", "Elixir Full or Max.Trophy") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_11", "Gold Full") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_12", "Elixir Full") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_13", "Reach Max. Trophy") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_14", "Dark Elixir Full") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_15", "All Storage (G+E+DE) Full") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_16", "Bot running for...") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_17", "Now (Train/Donate Only)") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_18", "Now (Donate Only)") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_19", "Now (Only stay online)") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_20", "W/Shield (Train/Donate Only)") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_21", "W/Shield (Donate Only)") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_22", "W/Shield (Only stay online)") & "|" & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_23", "At certain time in the day"), GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CmbBotCond_Item_17", -1))
			GUICtrlSetOnEvent(-1, "cmbBotCond")
			GUICtrlSetState(-1, $GUI_DISABLE)

		$g_hCmbHoursStop = GUICtrlCreateCombo("", $x + 337, $y - 3, 80, 35, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			_GUICtrlSetTip(-1, $sTxtTip)
			Local $sTxtHours = GetTranslatedFileIni("MBR Global GUI Design", "Hours", "Hours")
			GUICtrlSetData(-1, "-|1 " & GetTranslatedFileIni("MBR Global GUI Design", "Hour", "Hour") & "|2 " & $sTxtHours & "|3 " & $sTxtHours & "|4 " & $sTxtHours & "|5 " & $sTxtHours & "|6 " & _
										$sTxtHours & "|7 " & $sTxtHours & "|8 " & $sTxtHours & "|9 " & $sTxtHours & "|10 " & $sTxtHours & "|11 " & $sTxtHours & "|12 " & _
										$sTxtHours & "|13 " & $sTxtHours & "|14 " & $sTxtHours & "|15 " & $sTxtHours & "|16 " & $sTxtHours & "|17 " & $sTxtHours & "|18 " & _
										$sTxtHours & "|19 " & $sTxtHours & "|20 " & $sTxtHours & "|21 " & $sTxtHours & "|22 " & $sTxtHours & "|23 " & $sTxtHours & "|24 " & $sTxtHours, "-")
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hCmbTimeStop = GUICtrlCreateCombo("", $x + 337, $y - 3, 80, 35, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, "0:00 AM|1:00 AM|2:00 AM|3:00 AM|4:00 AM|5:00 AM|6:00 AM|7:00 AM|8:00 AM|9:00 AM|10:00 AM|11:00 AM" & _
								"|12:00 PM|1:00 PM|2:00 PM|3:00 PM|4:00 PM|5:00 PM|6:00 PM|7:00 PM|8:00 PM|9:00 PM|10:00 PM|11:00 PM", "0:00 AM")
			GUICtrlSetState(-1, $GUI_HIDE)

	$y += 25
		$g_LblResumeAttack = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblResumeAttack", "Resume") & ":", $x, $y + 2, 50, -1)

	$x += 50
		$g_hCmbResumeTime = GUICtrlCreateCombo("", $x + 15, $y - 1, 80, 20, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkResumeAttackTip_01", "After Halt-attack due to time schedule, the Bot will resume attack when the clock turns this time in a day"))
			GUICtrlSetData(-1, "0:00 AM|1:00 AM|2:00 AM|3:00 AM|4:00 AM|5:00 AM|6:00 AM|7:00 AM|8:00 AM|9:00 AM|10:00 AM|11:00 AM" & _
								"|12:00 PM|1:00 PM|2:00 PM|3:00 PM|4:00 PM|5:00 PM|6:00 PM|7:00 PM|8:00 PM|9:00 PM|10:00 PM|11:00 PM", "12:00 PM")
		GUICtrlSetState(-1, $GUI_HIDE)

		$g_ahTxtResumeAttackLoot[$eLootTrophy] = GUICtrlCreateInput("", $x + 5, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkResumeAttackTip_02", "After Halt-attack due to full resource, the Bot will resume attack when one of the resources drops below this minimum"))
		GUICtrlSetLimit(-1, 4)
		GUICtrlCreateLabel("<", $x - 5, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnTrophy, $x + 60, $y, 16, 16)

		$g_hChkCollectStarBonus = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollectStarBonus", "When star bonus available"), $x - 5 , $y + 20, -1, -1)

	;$x += 80
	;	GUICtrlCreateLabel("<", $x , $y + 2, -1, -1)
	;	$g_ahTxtResumeAttackLoot[$eLootGold] = GUICtrlCreateInput("", $x + 10, $y, 70, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	;	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkResumeAttackTip_02", -1))
	;	GUICtrlSetLimit(-1, 8)
	;	_GUICtrlCreateIcon($g_sLibIconPath, $eIcnGold, $x + 80, $y, 16, 16)
	;
	;$x += 100
	;	GUICtrlCreateLabel("<", $x, $y + 2, -1, -1)
	;	$g_ahTxtResumeAttackLoot[$eLootElixir] = GUICtrlCreateInput("", $x + 10, $y, 70, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	;	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkResumeAttackTip_02", -1))
	;	GUICtrlSetLimit(-1, 8)
	;	_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixir, $x + 80, $y, 16, 16)
	;
	;$x += 100
	;	GUICtrlCreateLabel("<", $x, $y + 2, -1, -1)
	;	$g_ahTxtResumeAttackLoot[$eLootDarkElixir] = GUICtrlCreateInput("", $x + 10, $y, 57, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	;	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkResumeAttackTip_02", -1))
	;	GUICtrlSetLimit(-1, 6)
	;	_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDark, $x + 70, $y, 16, 16)
	;
	$x = 15
	$y += 45
        GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblBotWillHaltAutomatically", "The bot will Halt automatically when you run out of Resources. It will resume when reaching these minimal values:"), $x + 20, $y, 400, 25, $BS_MULTILINE)

	$y += 30
	$x += 90
		GUICtrlCreateLabel(ChrW(8805), $x + 89, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnGold, $x + 149, $y, 16, 16)
		$g_hTxtRestartGold = GUICtrlCreateInput("10000", $x + 99, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtRestartGold_Info_01", "Minimum Gold value for the bot to resume attacking after halting because of low gold."))
			GUICtrlSetLimit(-1, 7)

	$x += 80
		GUICtrlCreateLabel(ChrW(8805), $x + 89, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixir, $x + 149, $y, 16, 16)
		$g_hTxtRestartElixir = GUICtrlCreateInput("25000", $x + 99, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtRestartElixir_Info_01", "Minimum Elixir value for the bot to resume attacking after halting because of low elixir."))
			GUICtrlSetLimit(-1, 7)

	$x += 80
		GUICtrlCreateLabel(ChrW(8805), $x + 89, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDark, $x + 149, $y, 16, 16)
		$g_hTxtRestartDark = GUICtrlCreateInput("500", $x + 99, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtRestartDark_Info_01", "Minimum Dark Elixir value for the bot to resume attacking after halting because of low dark elixir."))
			GUICtrlSetLimit(-1, 6)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	Local $x = 15, $y = 192
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_02", "Collect, Clear"), $x -10, $y - 20, $g_iSizeWGrpTab3, 170)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnMine, $x - 5, $y, 24, 24)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnCollector, $x + 20, $y, 24, 24)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDrill, $x + 45, $y, 24, 24)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnLootCart, $x + 70, $y, 24, 24)
		$g_hChkCollect = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollect", "Collect Resources && Loot Cart"), $x + 100, $y - 6, -1, -1, -1)
			GUICtrlSetOnEvent(-1, "ChkCollect")
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollect_Info_01", "Check this to automatically collect the Villages Resources") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollect_Info_02", "from Gold Mines, Elixir Collectors and Dark Elixir Drills.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollect_Info_03", "This will also search for a Loot Cart in your village and collect it."))
			GUICtrlSetState(-1, $GUI_CHECKED)
		$g_hChkCollectCartFirst = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollectCartFirst", "Loot Cart first"), $x + 280, $y - 6, -1, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollectCartFirst_Info_01", "Check this to collect the Loot Cart before Villages Resources."))
			GUICtrlSetState(-1, $GUI_CHECKED)

	$x += 179
	$y += 15
		GUICtrlCreateLabel("<", $x, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnGold, $x + 60, $y, 16, 16)
		$g_hTxtCollectGold = GUICtrlCreateInput("0", $x + 10, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			GUICtrlSetState(-1, $GUI_DISABLE)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectGold_Info_01", "Minimum Gold Storage amount to collect Gold.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectGold_Info_02", "Set same as Resume Attack values to collect when 'out of gold' error") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectGold_Info_03", "happens while searching for attack.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectGold_Info_04", "Set to zero to always collect."))
			GUICtrlSetLimit(-1, 7)

	$x += 80
		GUICtrlCreateLabel("<", $x, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixir, $x + 60, $y, 16, 16)
		$g_hTxtCollectElixir = GUICtrlCreateInput("0", $x + 10, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			GUICtrlSetState(-1, $GUI_DISABLE)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectElixir_Info_01", "Minimum Elixir Storage amount to collect Elixier.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectElixir_Info_02", "Set same as Resume Attack values to collect when 'out of elixir' error") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectElixir_Info_03", "happens during troop training.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectGold_Info_04", -1))
			GUICtrlSetLimit(-1, 7)

	$x += 80
		GUICtrlCreateLabel("<", $x, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDark, $x + 60, $y, 16, 16)
		$g_hTxtCollectDark = GUICtrlCreateInput("0", $x + 10, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			GUICtrlSetState(-1, $GUI_DISABLE)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectDark_Info_01", "Minimum Dark Elixir Storage amount to collect Dark Elixier.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectElixir_Info_02", -1) & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectElixir_Info_03", -1) & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCollectGold_Info_04", -1))
			GUICtrlSetLimit(-1, 6)

	$x = 15
	$y += 22
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnTreasury, $x + 22, $y - 14, 48, 48)
		$g_hChkTreasuryCollect = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTreasuryCollect", "Treasury"), $x + 100, $y - 2, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTreasuryCollect_Info_01", "Check this to automatically collect Treasury when FULL,") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTreasuryCollect_Info_02", "'OR' when Storage values are BELOW minimum values on right,") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTreasuryCollect_Info_03", "Use zero as min values to ONLY collect when Treasury is full") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTreasuryCollect_Info_04", "Large minimum values will collect Treasury loot more often!"))
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "ChkTreasuryCollect")

	$x += 179
		GUICtrlCreateLabel("<", $x, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnGold, $x + 60, $y, 16, 16)
		$g_hTxtTreasuryGold = GUICtrlCreateInput("1000000", $x + 10, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			GUICtrlSetState(-1, $GUI_DISABLE)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryGold_Info_01", "Minimum Gold Storage amount to collect Treasury.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryGold_Info_02", "Set same as Resume Attack values to collect when 'out of gold' error") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryGold_Info_03", "happens while searching for attack") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTreasuryCollect_Info_01", -1))
			GUICtrlSetLimit(-1, 7)

	$x += 80
		GUICtrlCreateLabel("<", $x, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixir, $x + 60, $y, 16, 16)
		$g_hTxtTreasuryElixir = GUICtrlCreateInput("1000000", $x + 10, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			GUICtrlSetState(-1, $GUI_DISABLE)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryElixir_Info_01", "Minimum Elixir Storage amount to collect Treasury.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryElixir_Info_02", "Set same as Resume Attack values to collect when 'out of elixir' error") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryElixir_Info_03", "happens during troop training") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTreasuryCollect_Info_01", -1))
			GUICtrlSetLimit(-1, 7)

	$x += 80
		GUICtrlCreateLabel("<", $x, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDark, $x + 60, $y, 16, 16)
		$g_hTxtTreasuryDark = GUICtrlCreateInput("1000", $x + 10, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			GUICtrlSetState(-1, $GUI_DISABLE)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryDark_Info_01", "Minimum Dark Elixir Storage amount to collect Treasury.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryElixir_Info_02", -1) & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryElixir_Info_03", -1) & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTreasuryCollect_Info_01", -1))
			GUICtrlSetLimit(-1, 6)

	$x = 15
	$y += 21
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnTombstone, $x + 32 , $y, 24, 24)
		$g_hChkTombstones = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTombstones", "Clear Tombstones"), $x + 100, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTombstones_Info_01", "Check this to automatically clear tombstones after enemy attack."))
			GUICtrlSetState(-1, $GUI_CHECKED)

		;_GUICtrlCreateIcon($g_sLibIconPath, $eIcnTree, $x + 230, $y, 24, 24)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnBark, $x + 230, $y, 24, 24)
		$g_hChkCleanYard = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCleanYard", "Remove Obstacles"), $x + 265, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCleanYard_Info_01", "Check this to automatically clear Yard from Trees, Trunks, etc."))
			GUICtrlSetState(-1, $GUI_CHECKED)

    $y += 21
	    _GUICtrlCreateIcon($g_sLibIconPath, $eIcnGembox, $x + 32, $y, 24, 24)
		$g_hChkGemsBox = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkGemsBox", "Remove GemBox"), $x + 100, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkGemsBox_Info_01", "Check this to automatically clear GemBox."))
			GUICtrlSetState(-1, $GUI_CHECKED)

	$y += 21
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnCollectAchievements, $x + 22, $y - 8 , 48, 48)
		$g_hChkCollectAchievements = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollectAchievements", "Collect Achievements"), $x + 100, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollectAchievements_Info", "Check this to automatically collect achievement rewards."))
			GUICtrlSetState(-1, $GUI_CHECKED)

        _GUICtrlCreateIcon($g_sLibIconPath, $eIcnPowerPotion, $x + 230, $y + 1 , 24, 24)
		$g_hChkFreeMagicItems = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkFreeMagicItems", "Collect Free Magic Items"), $x + 265, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkFreeMagicItems_Info", "Check this to automatically collect free magic items.\r\nMust be at least Th8."))
			GUICtrlSetOnEvent(-1, "ChkFreeMagicItems")
			
	$y += 21
		$g_hChkCollectRewards = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollectRewards", "Collect Challenge Rewards"), $x + 100, $y + 4, -1, -1)
		GUICtrlSetState(-1, $GUI_CHECKED)
		$g_hChkSellRewards = GUICtrlCreateCheckBox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSellRewards", "Sell Extras"), $x + 265, $y + 4, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSellExtra_Info_01", "Check to automatically sell all extra magic item rewards for gems."))

	GUICtrlCreateGroup("", -99, -99, 1, 1)

	Local $x = 20, $y = 363
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_03", "Locate Manually"), $x - 15, $y - 20, $g_iSizeWGrpTab3, 60)
		Local $sTxtRelocate = GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtRelocate_Info_01", "Relocate your") & " "
	$x -= 11
	$y -= 2
		GUICtrlCreateButton(GetTranslatedFileIni("MBR Global GUI Design", "LblTownhall", -1), $x, $y, 36, 36, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnTH14, 1)
			_GUICtrlSetTip(-1, $sTxtRelocate & GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnTownhall", "Town Hall"))
			GUICtrlSetOnEvent(-1, "btnLocateTownHall")

	$x += 38
		GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCC", "Clan Castle"), $x, $y, 36, 36, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnCC, 1)
			_GUICtrlSetTip(-1, $sTxtRelocate & GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCC", "Clan Castle"))
			GUICtrlSetOnEvent(-1, "btnLocateClanCastle")

	$x += 38
		$g_hBtnLocateKingAltar = GUICtrlCreateButton(GetTranslatedFileIni("MBR Global GUI Design Names Troops", "King", "King"), $x, $y, 36, 36, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnKingBoostLocate)
			_GUICtrlSetTip(-1, $sTxtRelocate & GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnAltarKing_Info_01", "Barbarian King Altar"))
			GUICtrlSetOnEvent(-1, "btnLocateKingAltar")

	$x += 38
		$g_hBtnLocateQueenAltar = GUICtrlCreateButton(GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Queen", "Queen"), $x, $y, 36, 36, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnQueenBoostLocate)
			_GUICtrlSetTip(-1, $sTxtRelocate & GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnAltarQueen_Info_01", "Archer Queen Altar"))
			GUICtrlSetOnEvent(-1, "btnLocateQueenAltar")

	$x += 38
		$g_hBtnLocateWardenAltar = GUICtrlCreateButton(GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Grand Warden", "Grand Warden"), $x, $y, 36, 36, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnWardenBoostLocate)
			_GUICtrlSetTip(-1, $sTxtRelocate & GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnAltarWarden_Info_01", "Grand Warden Altar"))
			GUICtrlSetOnEvent(-1, "btnLocateWardenAltar")

	$x += 38
		$g_hBtnLocateChampionAltar = GUICtrlCreateButton(GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Royal Champion", "Royal Champion"), $x, $y, 36, 36, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnChampionBoostLocate)
			_GUICtrlSetTip(-1, $sTxtRelocate & GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnAltarChampion_Info_01", "Royal Champion Altar"))
			GUICtrlSetOnEvent(-1, "btnLocateChampionAltar")

	$x += 38
		$g_hBtnLocateLaboratory = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnLocateLaboratory", "Lab."), $x, $y, 36, 36, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnLaboratory)
			_GUICtrlSetTip(-1, $sTxtRelocate & GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnLocateLaboratory_Info_01", "Laboratory"))
			GUICtrlSetOnEvent(-1, "btnLab")

	$x += 38
		$g_hBtnLocatePetHouse = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnLocatePetHouse", "Pet House"), $x, $y, 36, 36, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnPetHouse)
			_GUICtrlSetTip(-1, $sTxtRelocate & GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnLocatePetHouse_Info_01", "PetHouse"))
			GUICtrlSetOnEvent(-1, "btnPet")

	$x += 119
		GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnReset", "Reset."), $x, $y, 36, 36, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnBldgX)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnReset_Info_01", "Click here to reset all building locations,") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnReset_Info_02", "when you have changed your village layout."))
			GUICtrlSetOnEvent(-1, "btnResetBuilding")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

EndFunc   ;==>CreateMiscNormalVillageSubTab

; Clan Games v3
Func CreateMiscClanGamesV3SubTab()

	Local Const $g_sLibIconPathMOD = @ScriptDir & "\images\ClanGames.bmp"

	; GUI SubTab
	Local $x = 15, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_CG", "Clan Games"), $x - 10, $y - 20, $g_iSizeWGrpTab3, 245)
		GUICtrlCreatePic($g_sLibIconPathMOD, $x + 5, $y, 94, 128, $SS_BITMAP)

		GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesTimeRemaining", "Time Remaining"), $x - 5, $y + 135, 110, 40)
			$g_hLblRemainTime = GUICtrlCreateLabel("0d 00h", $x + 15, $y + 135 + 15, 65, 17, $SS_CENTER)
				GUICtrlSetFont(-1, 9.5, $FW_BOLD, $GUI_FONTNORMAL)
		GUICtrlCreateGroup("", -99, -99, 1, 1)

		GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesYourScore", "Your Score"), $x - 5, $y + 158 + 20, 110, 40)
			$g_hLblYourScore = GUICtrlCreateLabel("0/0", $x + 15, $y + 158 + 35, 65, 17, $SS_CENTER)
				GUICtrlSetFont(-1, 9.5, $FW_BOLD, $GUI_FONTNORMAL)
		GUICtrlCreateGroup("", -99, -99, 1, 1)
	$y = 33
	$x = 135
		$g_hChkClanGamesEnabled = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesEnabled", "Enabled"), $x, $y, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateClangames")
		$g_hChkClanGames60 = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGames60", "No 60min Events"), $x + 90 , $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGames60_Info_01", "will not choose 60 minute events"))
		$g_hChkClanGamesDebug = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesDebug", "Debug"), $x + 215, $y, -1, -1)

	$y += 40
		GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_CG_Challenges", "Challenges"), $x - 10, $y - 15, $g_iSizeWGrpTab3 - 125, 205)
			$g_hChkClanGamesLoot = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesLoot", "Loot"), $x, $y, -1, -1)
			$y += 23
			$g_hChkClanGamesBattle = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesBattle", "Battle"), $x, $y, -1, -1)
			$y += 23
			$g_hChkClanGamesDes = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesDestruction", "Destruction"), $x, $y, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateClangames")
			$g_hBtnCGDes = GUICtrlCreateButton("...", $x + 80, $y, 20, 20)
				GUICtrlSetOnEvent(-1, "btnCGDes")
				GUICtrlSetState(-1, $GUI_DISABLE)
			$y += 23
			$g_hChkClanGamesAirTroop = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesAirTroop", "Air Troops"), $x, $y, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateClangames")
			$g_hBtnCGAirTroop = GUICtrlCreateButton("...", $x + 70, $y, 20, 20)
				GUICtrlSetOnEvent(-1, "btnCGAirTroops")
				GUICtrlSetState(-1, $GUI_DISABLE)
			$y += 23
			$g_hChkClanGamesGroundTroop = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesGroundTroop", "Ground Troops"), $x, $y, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateClangames")
			$g_hBtnCGgroundTroop = GUICtrlCreateButton("...", $x + 95, $y, 20, 20)
				GUICtrlSetOnEvent(-1, "btnCGGroundTroops")
				GUICtrlSetState(-1, $GUI_DISABLE)
			$y += 23
			$g_hChkClanGamesMiscellaneous = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesMiscellaneous", "Miscellaneous"), $x, $y, -1, -1)

			$x = 270
			$y -= 115
			$g_hChkClanGamesSpell = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesSpell", "Spell"), $x, $y, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateClangames")
			$g_hBtnCGSpell = GUICtrlCreateButton("...", $x + 50, $y, 20, 20)
				GUICtrlSetOnEvent(-1, "btnCGSpells")
				GUICtrlSetState(-1, $GUI_DISABLE)
			$y += 23
			$g_hChkClanGamesBBBattle = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesBBBattle", "BB Battle"), $x, $y, -1, -1)
				GUICtrlSetOnEvent(-1, "chkClanGamesBB")
			$y += 23
			$g_hChkClanGamesBBDes = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesBBDestruction", "BB Destruction"), $x, $y, -1, -1)
				GUICtrlSetOnEvent(-1, "chkActivateClangames")
			$g_hBtnCGBBDes = GUICtrlCreateButton("...", $x + 90, $y, 20, 20)
				GUICtrlSetOnEvent(-1, "btnCGBBDes")
				GUICtrlSetState(-1, $GUI_DISABLE)
			$y += 23
			$g_hChkClanGamesBBTroops = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesBBTroop", "BB Troops"), $x, $y, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateClangames")
			$g_hBtnCGBBTroop = GUICtrlCreateButton("...", $x + 75, $y, 20, 20)
				GUICtrlSetOnEvent(-1, "BtnCGBBTroops")
				GUICtrlSetState(-1, $GUI_DISABLE)
			$y += 23
			$g_hChkForceBBAttackOnClanGames = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkForceBBAttackOnClanGames", "Force BB Attack"), $x, $y, -1, -1)
				GUICtrlSetOnEvent(-1, "chkClanGamesBB")
				_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGames60_Info_02", "If ClanGames Enabled : Ignore BB Trophy, BB Loot, BB Wait BM"))
			$y += 23
			$g_hChkClanGamesPurgeAny = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesPurgeAny", "Purge Any Event"), $x, $y, -1, -1)
				GUICtrlSetOnEvent(-1, "chkActivateClangames")
				_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGames60_Info_03", "If No Event Found, Purge Any Event"))
			$x = 135
			$y += 23
				$g_hChkClanGamesStopBeforeReachAndPurge = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesStopBeforeReachAndPurge", "Stop before completing your limit and only Purge"), $x, $y, -1, -1)
		GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("", -99, -99, 1, 1)


	$x = 15
	$y = 45
	$g_hTxtClanGamesLog = GUICtrlCreateEdit("", $x - 10, 275, $g_iSizeWGrpTab3, 127, BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY, $ES_AUTOVSCROLL))
	GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtClanGamesLog", _
			"--------------------------------------------------------- Clan Games LOG ------------------------------------------------"))

EndFunc   ;==>CreateMiscClanGamesV3SubTab

Global $g_hChkMMSkipFirstCheckRoutine, $g_hChkMMSkipBB, $g_hChkMMSkipTrain, $g_hChkMMIgnoreIncorrectTroopCombo, $g_hLblFillIncorrectTroopCombo, $g_hCmbFillIncorrectTroopCombo
Global $g_hChkMMIgnoreIncorrectSpellCombo, $g_hLblFillIncorrectSpellCombo, $g_hCmbFillIncorrectSpellCombo, $g_hChkMMTrainPreviousArmy, $g_hRandomArmyComp, $g_hChkMMSkipWallPlacingOnBB, $g_hChkMMCheckCGEarly
Global $g_sCmbFICTroops[5][3] = [ _ 
								["Barb",	"Barbarians",		1], _
								["Arch",	"Archers",			1], _
								["Giant",	"Giants",			5], _
								["Ball",	"Balloons",			5], _
								["SBarb",	"Super Barbarians",	5]]
Global $g_sCmbFICSpells[5][3] = [ _ 
								["LSpell",	"Lightning Spell",	1], _
								["BtSpell",	"Bat Spell",		1], _
								["HaSpell",	"Haste Spell",		1], _
								["FSpell",	"Freeze Spell",		1], _
								["RSpell",	"Rage Spell",		2]]

Func CreateMiscModSubTab()
	Local $x = 15, $y = 40
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_MiscMod", "On Halt Attack Mode"), $x - 10, $y - 15, 210, 80)
		$g_hChkMMSkipFirstCheckRoutine = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSkipFirstCheckRoutine", "Skip First Check Routine"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnHalt_Info_01", "If on Halt-Attack Mode, will skip routine on FirstCheck to save time"))
		GUICtrlSetOnEvent(-1, "chkOnHaltAttack")
	$y += 20	
		$g_hChkMMSkipBB = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSkipBB", "Skip Builder Base"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnHalt_Info_02", "If on Halt-Attack Mode, will skip Going to Builder Base"))
		GUICtrlSetOnEvent(-1, "chkOnHaltAttack")
	$y += 20
		$g_hChkMMSkipTrain = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSkipTrain", "Skip Training"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnHalt_Info_03", "If on Halt-Attack Mode, will skip Train"))
		GUICtrlSetOnEvent(-1, "chkOnHaltAttack")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$y += 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_MiscMod", "On Double Train"), $x - 10, $y - 15, 210, 110)
		$g_hChkMMIgnoreIncorrectTroopCombo = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkIgnoreBadTroopCombo", "Ignore Bad Troop Combo"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnDoubleTrain_Info_01", "If Enabled DoubleTrain, Wont Empty Queued Troop, will Disable Precise Army"))
		GUICtrlSetOnEvent(-1, "chkOnDoubleTrain")
		GUICtrlSetState(-1, $GUI_CHECKED)
	$y += 22
		$g_hLblFillIncorrectTroopCombo = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design - FillIncorrectTroopCombo", "Label_01", "Fill With :"), $x, $y+3, -1, -1)
		GUICtrlSetOnEvent(-1, "chkOnDoubleTrain")
		$g_hCmbFillIncorrectTroopCombo = GUICtrlCreateCombo("", $x + 50, $y, 110, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		Local $sCmbTxt 
		For $z = 0 To UBound($g_sCmbFICTroops) - 1
			$sCmbTxt &= $g_sCmbFICTroops[$z][1] & "|"
		Next
		GUICtrlSetData(-1, $sCmbTxt, "Barbarians")
	$y += 23	
		$g_hChkMMIgnoreIncorrectSpellCombo = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkIgnoreBadSpellCombo", "Ignore Bad Spell Combo"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnDoubleTrain_Info_02", "If Enabled DoubleTrain, Wont Empty Queued Spell, will Disable Precise Army"))
		GUICtrlSetOnEvent(-1, "chkOnDoubleTrain")
		GUICtrlSetState(-1, $GUI_CHECKED)
	$y += 22
		$g_hLblFillIncorrectSpellCombo = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design - FillIncorrectSpellCombo", "Label_01", "Fill With :"), $x, $y+3, -1, -1)
		GUICtrlSetOnEvent(-1, "chkOnDoubleTrain")
		$g_hCmbFillIncorrectSpellCombo = GUICtrlCreateCombo("", $x + 50, $y, 110, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		$sCmbTxt = ""
		For $z = 0 To UBound($g_sCmbFICSpells) - 1
			$sCmbTxt &= $g_sCmbFICSpells[$z][1] & "|"
		Next
		GUICtrlSetData(-1, $sCmbTxt, "Lightning Spell")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
		
	$y += 48
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_MiscMod", "On Train"), $x - 10, $y - 15, 210, 40)
		$g_hChkMMTrainPreviousArmy = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTrainPreviousArmy", "Train Previous Army"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnDoubleTrain_Info_01", "Will Use Train Previous Army"))
		GUICtrlSetOnEvent(-1, "chkTrainPrev")
		GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$y += 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_MiscMod", "On QuickTrain"), $x - 10, $y - 15, 210, 40)
		$g_hRandomArmyComp = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTrainRandomArmyComp", "Random Army Comp"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnDoubleTrain_Info_01", "Will Use Quick Train Army Button (Randomed)"))
		GUICtrlSetOnEvent(-1, "chkRandomQuickTrain")
		GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$y += 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_MiscMod", "On BB AutoUpgrade"), $x - 10, $y - 15, 210, 40)
		$g_hChkMMSkipWallPlacingOnBB = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SkipWallPlacingOnBB", "Skip New Wall Placing On BB"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnBBAutoUpgrade", "Skip New Wall Placing if Enabled BB New Tagged Auto Upgrade"))
		GUICtrlSetOnEvent(-1, "chkSkipWallPlacingOnBB")
		GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$x = 180 + 55
	$y = 40
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_MiscMod", "On FirstCheck"), $x - 10, $y - 15, 210, 40)
		$g_hChkMMCheckCGEarly = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CheckCGEarly", "Check ClanGames Early"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnBBAutoUpgrade", "Enable Check ClanGames on First Start"))
		GUICtrlSetOnEvent(-1, "chkCheckCGEarly")
		GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
EndFunc ;==>CreateMiscModSubTab

Func CreateCGDes()
	Local $CGDesChallenges = ClanGamesChallenges("$DestructionChallenges")
	For $j = 0 To UBound($CGDesChallenges) - 1
		$g_sTxtCGDes &= $CGDesChallenges[$j][1] & "|"
	Next

	$g_hGUI_CGDes = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - Misc", "GUI_CGDes", "Main Village Destruction Challenge"), 322, 315, $g_iFrmBotPosX, -1, $WS_DLGFRAME, $WS_EX_TOPMOST)
	Local $x = 25, $y = 25
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SelectCGDes", "Select Destruction Challenges"), $x - 20, $y - 20, 308, 220)
	$x += 10
	$y += 5
	For $i = 0 To 13
		If $i < 7 Then
			GUICtrlCreateLabel($i + 1 & ":", $x - 19, $y + 3 + 25*$i, -1, 18)
			$g_ahCmbCGDes[$i] = GUICtrlCreateCombo("", $x, $y + 25*$i, 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGDes")
				GUICtrlSetData(-1,  $g_sTxtCGDes)
		Else
			GUICtrlCreateLabel($i + 1 & ":", $x + 150 - 19, $y + 3 + 25*($i-7), -1, 18)
			$g_ahCmbCGDes[$i] = GUICtrlCreateCombo("", $x+150, $y + 25*($i-7), 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGDes")
				GUICtrlSetData(-1,  $g_sTxtCGDes)
		EndIf
	Next
	$y = 215
	$g_hBtnCGDesSet = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGDesSet", "Apply Challenge"), $x - 20, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "btnSetCGDes")
	$g_hBtnCGDesRemove = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGDesRemove", "Empty Challenge List"), $x + 150, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "BtnCGDesRemove")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$g_hBtnCGDesClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGDesClose", "Close"), 230, $y - 5 + 50, 85, 25)
		GUICtrlSetOnEvent(-1, "CloseCGDes")

EndFunc ;==>CreateCGDes

Func CreateClanGamesAirTroops()
	Local $AirTroopsChallenges = ClanGamesChallenges("$AirTroopChallenges")
	For $j = 0 To UBound($AirTroopsChallenges) - 1
		$g_sTxtCGAirTroop &= $AirTroopsChallenges[$j][1] & "|"
	Next

	$g_hGUI_CGAirTroops = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - Misc", "GUI_CGAirTroops", "Air Troops Challenges"), 322, 265, $g_iFrmBotPosX, -1, $WS_DLGFRAME, $WS_EX_TOPMOST)
	Local $x = 25, $y = 25
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SelectCGAirTroops", "Select Air Troops Challenges"), $x - 20, $y - 20, 308, 200)
	$x += 10
	$y += 5
	For $i = 0 To 9
		If $i < 5 Then
			GUICtrlCreateLabel($i + 1 & ":", $x - 19, $y + 3 + 25*$i, -1, 18)
			$g_ahCmbCGAirTroops[$i] = GUICtrlCreateCombo("", $x, $y + 25*$i, 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGAirTroops")
				GUICtrlSetData(-1,  $g_sTxtCGAirTroop)
		Else
			GUICtrlCreateLabel($i + 1 & ":", $x + 150 - 19, $y + 3 + 25*($i-5), -1, 18)
			$g_ahCmbCGAirTroops[$i] = GUICtrlCreateCombo("", $x+150, $y + 25*($i-5), 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGAirTroops")
				GUICtrlSetData(-1,  $g_sTxtCGAirTroop)
		EndIf
	Next
	$y = 165
	$g_hBtnCGAirTroopsSet = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGAirTroopsSet", "Apply Air Troops"), $x - 20, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "btnSetCGAirTroops")
	$g_hBtnCGAirTroopsRemove = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGAirTroopsRemove", "Empty Challenge List"), $x + 150, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "BtnCGAirTroopsRemove")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$g_hBtnCGAirTroopsClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGAirTroopsClose", "Close"), 230, $y - 5 + 50, 85, 25)
		GUICtrlSetOnEvent(-1, "CloseCGAirTroops")

EndFunc ;==>CreateClanGamesAirTroops

Func CreateClanGamesGroundTroops()
	Local $GroundTroopChallenges = ClanGamesChallenges("$GroundTroopChallenges")
	For $j = 0 To UBound($GroundTroopChallenges) - 1
		$g_sTxtCGGroundTroop &= $GroundTroopChallenges[$j][1] & "|"
	Next

	$g_hGUI_CGGroundTroops = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - Misc", "GUI_CGGroundTroop", "Ground Troops Challenges"), 322, 265, $g_iFrmBotPosX, -1, $WS_DLGFRAME, $WS_EX_TOPMOST)
	Local $x = 25, $y = 25
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SelectCGGroundTroop", "Select Ground Troops Challenges"), $x - 20, $y - 20, 308, 200)
	$x += 10
	$y += 5
	For $i = 0 To 9
		If $i < 5 Then
			GUICtrlCreateLabel($i + 1 & ":", $x - 19, $y + 3 + 25*$i, -1, 18)
			$g_ahCmbCGGroundTroops[$i] = GUICtrlCreateCombo("", $x, $y + 25*$i, 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGGroundTroops")
				GUICtrlSetData(-1,  $g_sTxtCGGroundTroop)
		Else
			GUICtrlCreateLabel($i + 1 & ":", $x + 150 - 19, $y + 3 + 25*($i-5), -1, 18)
			$g_ahCmbCGGroundTroops[$i] = GUICtrlCreateCombo("", $x+150, $y + 25*($i-5), 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGGroundTroops")
				GUICtrlSetData(-1,  $g_sTxtCGGroundTroop)
		EndIf
	Next
	$y = 165
	$g_hBtnCGGroundTroopSet = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGGroundTroopSet", "Apply Ground Troops"), $x - 20, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "btnSetCGGroundTroops")
	$g_hBtnCGGroundTroopRemove = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGGroundTroopRemove", "Empty Challenge List"), $x + 150, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "BtnCGGroundTroopsRemove")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$g_hBtnCGGroundTroopClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGGroundTroopClose", "Close"), 230, $y - 5 + 50, 85, 25)
		GUICtrlSetOnEvent(-1, "CloseCGGroundTroops")

EndFunc ;==>CreateClanGamesGroundTroops

Func CreateClanGamesSpell()
	Local $SpellChallenges = ClanGamesChallenges("$SpellChallenges")
	For $j = 0 To UBound($SpellChallenges) - 1
		$g_sTxtCGSpell &= $SpellChallenges[$j][1] & "|"
	Next

	$g_hGUI_CGSpells = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - Misc", "GUI_CGSpells", "Spell Challenges"), 322, 265, $g_iFrmBotPosX, -1, $WS_DLGFRAME, $WS_EX_TOPMOST)
	Local $x = 25, $y = 25
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SelectCGSpells", "Select Spell Challenges"), $x - 20, $y - 20, 308, 200)
	$x += 10
	$y += 5
	For $i = 0 To 9
		If $i < 5 Then
			GUICtrlCreateLabel($i + 1 & ":", $x - 19, $y + 3 + 25*$i, -1, 18)
			$g_ahCmbCGSpells[$i] = GUICtrlCreateCombo("", $x, $y + 25*$i, 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGSpells")
				GUICtrlSetData(-1,  $g_sTxtCGSpell)
		Else
			GUICtrlCreateLabel($i + 1 & ":", $x + 150 - 19, $y + 3 + 25*($i-5), -1, 18)
			$g_ahCmbCGSpells[$i] = GUICtrlCreateCombo("", $x+150, $y + 25*($i-5), 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGSpells")
				GUICtrlSetData(-1,  $g_sTxtCGSpell)
		EndIf
	Next
	$y = 165
	$g_hBtnCGSpellsSet = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGSpellsSet", "Apply Spell Challenge"), $x - 20, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "btnSetCGSpells")
	$g_hBtnCGSpellsRemove = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGSpellsRemove", "Empty Challenge List"), $x + 150, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "BtnCGSpellsRemove")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$g_hBtnCGSpellsClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGSpellsClose", "Close"), 230, $y - 5 + 50, 85, 25)
		GUICtrlSetOnEvent(-1, "CloseCGSpells")

EndFunc ;==>CreateClanGamesSpell

Func CreateClanGamesBBDes()
	Local $BBDesChallenges = ClanGamesChallenges("$BBDestructionChallenges")
	For $j = 0 To UBound($BBDesChallenges) - 1
		$g_sTxtCGBBDes &= $BBDesChallenges[$j][1] & "|"
	Next

	$g_hGUI_CGBBDes = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - Misc", "GUI_CGBBDes", "BB Destruction Challenges"), 322, 265, $g_iFrmBotPosX, -1, $WS_DLGFRAME, $WS_EX_TOPMOST)
	Local $x = 25, $y = 25
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SelectCGBBDes", "Select BB Destruction Challenges"), $x - 20, $y - 20, 308, 200)
	$x += 10
	$y += 5
	For $i = 0 To 9
		If $i < 5 Then
			GUICtrlCreateLabel($i + 1 & ":", $x - 19, $y + 3 + 25*$i, -1, 18)
			$g_ahCmbCGBBDes[$i] = GUICtrlCreateCombo("", $x, $y + 25*$i, 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGBBDes")
				GUICtrlSetData(-1,  $g_sTxtCGBBDes)
		Else
			GUICtrlCreateLabel($i + 1 & ":", $x + 150 - 19, $y + 3 + 25*($i-5), -1, 18)
			$g_ahCmbCGBBDes[$i] = GUICtrlCreateCombo("", $x+150, $y + 25*($i-5), 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGBBDes")
				GUICtrlSetData(-1,  $g_sTxtCGBBDes)
		EndIf
	Next

	$y = 165
	$g_hBtnCGBBDesSet = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGBBDesSet", "Apply BB Destruction"), $x - 20, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "btnSetCGBBDes")
	$g_hBtnCGBBDesRemove = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGBBDesRemove", "Empty Challenge List"), $x + 150, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "BtnCGBBDesRemove")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$g_hBtnCGBBDesClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGBBDesClose", "Close"), 230, $y - 5 + 50, 85, 25)
		GUICtrlSetOnEvent(-1, "CloseCGBBDes")

EndFunc ;==>CreateClanGamesBBDes

Func CreateClanGamesBBTroops()
	Local $BBTroopsChallenges = ClanGamesChallenges("$BBTroopChallenges")
	For $j = 0 To UBound($BBTroopsChallenges) - 1
		$g_sTxtCGBBTroop &= $BBTroopsChallenges[$j][1] & "|"
	Next

	$g_hGUI_CGBBTroops = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - Misc", "GUI_CGBBTroops", "BB Troops Challenges"), 322, 265, $g_iFrmBotPosX, -1, $WS_DLGFRAME, $WS_EX_TOPMOST)
	Local $x = 25, $y = 25
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SelectCGBBTroops", "Select BB Troops Challenges"), $x - 20, $y - 20, 308, 200)
	$x += 10
	$y += 5
	For $i = 0 To 9
		If $i < 5 Then
			GUICtrlCreateLabel($i + 1 & ":", $x - 19, $y + 3 + 25*$i, -1, 18)
			$g_ahCmbCGBBTroops[$i] = GUICtrlCreateCombo("", $x, $y + 25*$i, 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGBBTroops")
				GUICtrlSetData(-1,  $g_sTxtCGBBTroop)
		Else
			GUICtrlCreateLabel($i + 1 & ":", $x + 150 - 19, $y + 3 + 25*($i-5), -1, 18)
			$g_ahCmbCGBBTroops[$i] = GUICtrlCreateCombo("", $x+150, $y + 25*($i-5), 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "GUI_CGBBTroops")
				GUICtrlSetData(-1,  $g_sTxtCGBBTroop)
		EndIf
	Next

	$y = 165
	$g_hBtnCGBBTroopsSet = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGBBTroopsSet", "Apply BB Troops"), $x - 20, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "btnSetCGBBTroops")
	$g_hBtnCGBBTroopsRemove = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGBBTroopsRemove", "Empty Challenge List"), $x + 150, $y, 118, 25)
		GUICtrlSetOnEvent(-1, "BtnCGBBTroopsRemove")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$g_hBtnCGBBTroopsClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGBBTroopsClose", "Close"), 230, $y - 5 + 50, 85, 25)
		GUICtrlSetOnEvent(-1, "CloseCGBBTroops")

EndFunc ;==>CreateClanGamesBBTroops
