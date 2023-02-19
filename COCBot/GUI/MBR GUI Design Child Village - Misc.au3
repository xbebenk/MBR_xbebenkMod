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
#include <TreeViewConstants.au3>

Global $g_hGUI_MISC = 0, $g_hGUI_MISC_TAB = 0, $g_hGUI_MISC_TAB_ITEM1 = 0, $g_hGUI_MISC_TAB_ITEM2 = 0, $g_hGUI_MISC_TAB_ITEM3 = 0, $g_hGUI_MISC_TAB_ITEM4 = 0

Global $g_hChkBotStop = 0, $g_hCmbBotCommand = 0, $g_hCmbBotCond = 0, $g_hCmbHoursStop = 0, $g_hCmbTimeStop = 0
Global $g_LblResumeAttack = 0, $g_ahTxtResumeAttackLoot[$eLootCount] = [0, 0, 0, 0], $g_hCmbResumeTime = 0
Global $g_hChkCollectStarBonus = 0
Global $g_hTxtRestartGold = 0, $g_hTxtRestartElixir = 0, $g_hTxtRestartDark = 0
Global $g_hChkTrap = 1, $g_hChkCollect = 1, $g_hChkTombstones = 1, $g_hChkCleanYard = 0, $g_hChkGemsBox = 0
Global $g_hGUI_SaleMagicItems, $g_hBtnSellPot = 0, $g_hChkEnableSaleMagicItem = 0
Global $g_hChkSaleBOF = 0, $g_hChkSaleBOB = 0, $g_hChkSaleBOS = 0, $g_hChkSaleBOH = 0, $g_hChkSaleBOE = 0, $g_hChkSaleShovel = 0, $g_hChkSaleWallRing = 0
Global $g_hChkSalePowerPot = 0, $g_hChkSaleResourcePot = 0, $g_hChkSaleTrainingPot = 0, $g_hChkSaleBuilderPot = 0, $g_hChkSaleCTPot = 0
Global $g_hChkSaleHeroPot = 0, $g_hChkSaleResearchPot = 0, $g_hChkSaleSuperPot = 0
Global $g_hChkSaleROG = 0, $g_hChkSaleROE = 0, $g_hChkSaleRODE = 0, $g_hChkSaleROBG = 0, $g_hChkSaleROBE = 0
Global $g_hChkCollectCartFirst = 0, $g_hTxtCollectGold = 0, $g_hTxtCollectElixir = 0, $g_hTxtCollectDark = 0
Global $g_hBtnLocateSpellfactory = 0, $g_hBtnLocateDarkSpellFactory = 0
Global $g_hBtnLocateKingAltar = 0, $g_hBtnLocateQueenAltar = 0, $g_hBtnLocateWardenAltar = 0, $g_hBtnLocateChampionAltar = 0, $g_hBtnLocateLaboratory = 0, $g_hBtnLocatePetHouse = 0, $g_hBtnResetBuilding = 0
Global $g_hChkTreasuryCollect = 0, $g_hTxtTreasuryGold = 0, $g_hTxtTreasuryElixir = 0, $g_hTxtTreasuryDark = 0 , $g_hChkCollectAchievements = 0, $g_hChkFreeMagicItems = 0, $g_hChkCollectRewards = 0, $g_hChkSellRewards = 0

;ClanGames Challenges
Global $g_hChkClanGamesEnabled = 0 , $g_hChkClanGames3H = 0, $g_hChkClanGamesDebug = 0
Global $g_hTxtClanGamesLog = 0, $g_hLblRemainTime = 0 , $g_hLblYourScore = 0
Global $g_hGUI_CGSettings = 0, $g_hBtnCGSettingsOpen = 0, $g_hBtnCGSettingsClose = 0, $g_hChkCollectCGReward = 0
Global $g_hChkForceBBAttackOnClanGames = 0, $g_hChkClanGamesPurgeAny = 0, $g_hChkClanGamesStopBeforeReachAndPurge = 0, $g_hCmbClanGamesPurgeDay
Global $g_hChkClanGamesSort = 0, $g_hCmbClanGamesSort = 0, $g_hChkCGBBAttackOnly = 0
Global $g_hLabelClangamesDesc = 0, $g_hChkCGRootEnabledAll = 0
Global $g_hClanGamesTV = 0, $g_hChkCGMainLoot = 0, $g_hChkCGMainBattle = 0, $g_hChkCGMainDestruction = 0
Global $g_hChkCGMainAir = 0, $g_hChkCGMainGround = 0, $g_hChkCGMainMisc = 0, $g_hChkCGMainSpell = 0
Global $g_hChkCGBBBattle = 0, $g_hChkCGBBDestruction = 0, $g_hChkCGBBTroops = 0
Global $g_ahCGMainLootItem[UBound(ClanGamesChallenges("$LootChallenges"))]
Global $g_ahCGMainBattleItem[Ubound(ClanGamesChallenges("$BattleChallenges"))]
Global $g_ahCGMainDestructionItem[Ubound(ClanGamesChallenges("$DestructionChallenges"))]
Global $g_ahCGMainAirItem[Ubound(ClanGamesChallenges("$AirTroopChallenges"))]
Global $g_ahCGMainGroundItem[Ubound(ClanGamesChallenges("$GroundTroopChallenges"))]
Global $g_ahCGMainMiscItem[Ubound(ClanGamesChallenges("$MiscChallenges"))]
Global $g_ahCGMainSpellItem[Ubound(ClanGamesChallenges("$SpellChallenges"))]
Global $g_ahCGBBBattleItem[Ubound(ClanGamesChallenges("$BBBattleChallenges"))]
Global $g_ahCGBBDestructionItem[Ubound(ClanGamesChallenges("$BBDestructionChallenges"))]
Global $g_ahCGBBTroopsItem[Ubound(ClanGamesChallenges("$BBTroopsChallenges"))]


Func CreateVillageMisc()
	$g_hGUI_MISC = _GUICreate("", $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, 5, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_VILLAGE)

	GUISwitch($g_hGUI_MISC)
		$g_hGUI_MISC_TAB = GUICtrlCreateTab(0, 0, $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, BitOR($TCS_MULTILINE, $TCS_RIGHTJUSTIFY))
		$g_hGUI_MISC_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "MISC_TAB_ITEM1", "Normal Village"))
		CreateMiscNormalVillageSubTab()
		$g_hGUI_MISC_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "MISC_TAB_ITEM2", "Clan Games"))
		CreateMiscClanGamesV3SubTab()
		$g_hGUI_MISC_TAB_ITEM3 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "MISC_TAB_ITEM3", "Clan Capital"))
		CreateClanCapitalTab()
		$g_hGUI_MISC_TAB_ITEM4 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "MISC_TAB_ITEM4", "Misc Mod"))
		CreateMiscModSubTab()
		CreateClanGamesSettings()
		CreateSellMagicSetting()
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

	$x += 80
		GUICtrlCreateLabel("<", $x , $y + 2, -1, -1)
		$g_ahTxtResumeAttackLoot[$eLootGold] = GUICtrlCreateInput("", $x + 10, $y, 70, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkResumeAttackTip_02", -1))
		GUICtrlSetLimit(-1, 8)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnGold, $x + 80, $y, 16, 16)
	
	$x += 100
		GUICtrlCreateLabel("<", $x, $y + 2, -1, -1)
		$g_ahTxtResumeAttackLoot[$eLootElixir] = GUICtrlCreateInput("", $x + 10, $y, 70, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkResumeAttackTip_02", -1))
		GUICtrlSetLimit(-1, 8)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixir, $x + 80, $y, 16, 16)
	
	$x += 100
		GUICtrlCreateLabel("<", $x, $y + 2, -1, -1)
		$g_ahTxtResumeAttackLoot[$eLootDarkElixir] = GUICtrlCreateInput("", $x + 10, $y, 57, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkResumeAttackTip_02", -1))
		GUICtrlSetLimit(-1, 6)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDark, $x + 70, $y, 16, 16)
	
	$x = 15
	$y += 45
        GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblBotWillHaltAutomatically", "The bot will Halt automatically when you run out of Resources. It will resume when reaching these minimal values:"), $x + 20, $y, 400, 25, $BS_MULTILINE)

	$y += 30
	$x += 80
		GUICtrlCreateLabel(ChrW(8805), $x + 89, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnGold, $x + 154, $y, 16, 16)
		$g_hTxtRestartGold = GUICtrlCreateInput("10000", $x + 99, $y, 55, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtRestartGold_Info_01", "Minimum Gold value for the bot to resume attacking after halting because of low gold."))
			GUICtrlSetLimit(-1, 8)

	$x += 85
		GUICtrlCreateLabel(ChrW(8805), $x + 89, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixir, $x + 154, $y, 16, 16)
		$g_hTxtRestartElixir = GUICtrlCreateInput("25000", $x + 99, $y, 55, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtRestartElixir_Info_01", "Minimum Elixir value for the bot to resume attacking after halting because of low elixir."))
			GUICtrlSetLimit(-1, 8)

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
			GUICtrlSetState(-1, $GUI_CHECKED)
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
			GUICtrlSetLimit(-1, 8)

	$x += 80
		GUICtrlCreateLabel("<", $x, $y + 2, -1, -1)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixir, $x + 60, $y, 16, 16)
		$g_hTxtTreasuryElixir = GUICtrlCreateInput("1000000", $x + 10, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			GUICtrlSetState(-1, $GUI_DISABLE)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryElixir_Info_01", "Minimum Elixir Storage amount to collect Treasury.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryElixir_Info_02", "Set same as Resume Attack values to collect when 'out of elixir' error") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtTreasuryElixir_Info_03", "happens during troop training") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTreasuryCollect_Info_01", -1))
			GUICtrlSetLimit(-1, 8)

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
		$g_hChkSellRewards = GUICtrlCreateCheckBox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSellRewards", "Sell Extras"), $x + 265, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSellExtra_Info_01", "Check to automatically sell all extra magic item rewards for gems."))
			
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
		$g_hBtnSellPot = GUICtrlCreateButton("Sale Magic Items", $x - 2 + 265, $y + 4, -1, 20)
		GUICtrlSetOnEvent(-1, "btnOpenSalePotion")
		
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
		$g_hBtnLocateWardenAltar = GUICtrlCreateButton(GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Warden", "Warden"), $x, $y, 36, 36, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnWardenBoostLocate)
			_GUICtrlSetTip(-1, $sTxtRelocate & GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnAltarWarden_Info_01", "Grand Warden Altar"))
			GUICtrlSetOnEvent(-1, "btnLocateWardenAltar")

	$x += 38
		$g_hBtnLocateChampionAltar = GUICtrlCreateButton(GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Champion", "Champion"), $x, $y, 36, 36, $BS_ICON)
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

Func CreateSellMagicSetting()
	$g_hGUI_SaleMagicItems = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - Misc", "GUI_SaleMagicItem", "Sale Magic Items Settings"), $_GUI_MAIN_WIDTH - 20, $_GUI_MAIN_HEIGHT - 370, $g_iFrmBotPosX, $g_iFrmBotPosY + 60, $WS_DLGFRAME, -1, $g_hFrmBot)
	; GUI SubTab
	Local $x = 15, $y = 10
	
	$g_hChkEnableSaleMagicItem = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "EnableSaleMagicItem", "Enable Sale Magic Items"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SaleMagicItem_Info", "Enable option to Sale Magic Items"))
			GUICtrlSetOnEvent(-1, "chkEnableSaleMagicItem")
	
	$y = 55
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_SalePotion", "Sale Magic Items Settings"), $x - 10, $y - 20, $g_iSizeWGrpTab3, 200)
		
		$g_hChkSaleBOF = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBOF", "Book Of Fighting"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBOF_Info", "Enable option to Sale Book Of Fighting"))
		$y += 21
		$g_hChkSaleBOB = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBOB", "Book Of Building"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBOB_Info", "Enable option to Sale Book Of Building"))

		$y += 21
		$g_hChkSaleBOS = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBOS", "Book Of Spell"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBOS_Info", "Enable option to Sale Book Of Spell"))

		$y += 21
		$g_hChkSaleBOH = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBOH", "Book Of Heroes"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBOH_Info", "Enable option to Sale Book Of Heroes"))

		$y += 21
		$g_hChkSaleBOE = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBOE", "Book Of Everything"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBOE_Info", "Enable option to Sale Book Of Everything"))

		$y += 21
		$g_hChkSaleShovel = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleShovel", "Shovel"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleShovel_Info", "Enable option to Sale Shovel"))

		$y += 21
		$g_hChkSaleWallRing = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleWallRing", "Wall Ring"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleWallRing_Info", "Enable option to Sale Wall Ring"))
		
		$x = 150
		$y = 55
		$g_hChkSalePowerPot = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSalePowerPot", "Power Potions"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSalePowerPot_Info", "Enable option to Sale Power Potions"))

		$y += 21
		$g_hChkSaleResourcePot = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSalePowerPot", "Resource Potions"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleResourcePot_Info", "Enable option to Sale Resource Potions"))

		$y += 21
		$g_hChkSaleTrainingPot = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleTrainingPot", "Training Potions"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleTrainingPot_Info", "Enable option to Sale Training Potions"))

		$y += 21
		$g_hChkSaleBuilderPot = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBuilderPot", "Builder Potions"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleBuilderPot_Info", "Enable option to Sale Builder Potions"))

		$y += 21
		$g_hChkSaleCTPot = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleCTPot", "Clock Tower Potions"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleCTPot_Info", "Enable option to Sale Clock Tower Potions"))

		$y += 21
		$g_hChkSaleHeroPot = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleHeroPot", "Hero Potions"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleHeroPot_Info", "Enable option to Sale Hero Potions"))

		$y += 21
		$g_hChkSaleResearchPot = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleResearchPot", "Research Potions"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleResearchPot_Info", "Enable option to Sale Research Potions"))

		$y += 21
		$g_hChkSaleSuperPot = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleSuperPot", "Super Potions"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleSuperPot_Info", "Enable option to Sale Super Potions"))
		
		$x = 300
		$y = 55
		$g_hChkSaleROG = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleROG", "Rune Of Gold"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleROG_Info", "Enable option to Sale Rune Of Gold"))

		$y += 21
		$g_hChkSaleROE = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleROE", "Rune Of Elixir"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleROE_Info", "Enable option to Sale Rune Of Elixir"))

		$y += 21
		$g_hChkSaleRODE = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleRODE", "Rune Of Dark Elixir"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleRODE_Info", "Enable option to Sale Rune Of Dark Elixir"))

		$y += 21
		$g_hChkSaleROBG = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleROBG", "Rune Of Builder Gold"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleROBG_Info", "Enable option to Sale Rune Of Builder Gold"))

		$y += 21
		$g_hChkSaleROBE = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleROBE", "Rune Of Builder Elixir"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkSaleROBE_Info", "Enable option to Sale Rune Of Builder Elixir"))
			
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$g_hBtnCGSettingsClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_SalePotion", "Close"), $_GUI_MAIN_WIDTH - 125, $_GUI_MAIN_HEIGHT - 440, 85, 25)
			GUICtrlSetOnEvent(-1, "btnCloseSalePotion")
EndFunc

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
		$g_hChkClanGames3H = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGames60", "No 3 Hour Events"), $x + 90 , $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGames60_Info_01", "will not choose 3 Hour Events"))
		$g_hChkClanGamesDebug = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesDebug", "Debug"), $x + 215, $y, -1, -1)

	$y += 40
		GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_CG_Challenges", "Challenges"), $x - 10, $y - 15, $g_iSizeWGrpTab3 - 125, 205)
			$y += 23
			$g_hBtnCGSettingsOpen = GUICtrlCreateButton("ClanGames Setting", $x + 90, $y, -1, -1)
			GUICtrlSetOnEvent(-1, "btnCGSettings")
			$y += 50
			$g_hChkCollectCGReward = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCollectCGReward", "Auto Collect ClanGames Reward"), 190, $y, -1, -1)
			GUICtrlSetOnEvent(-1, "chkCollectCGReward")
		GUICtrlCreateGroup("", -99, -99, 1, 1)

	GUICtrlCreateGroup("", -99, -99, 1, 1)


	$x = 15
	$y = 45
	$g_hTxtClanGamesLog = GUICtrlCreateEdit("", $x - 10, 275, $g_iSizeWGrpTab3, 127, BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY, $ES_AUTOVSCROLL))
	GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtClanGamesLog", _
			"--------------------------------------------------------- Clan Games LOG ------------------------------------------------"))

EndFunc   ;==>CreateMiscClanGamesV3SubTab

Global $g_hChkMMSkipFirstCheckRoutine = 0, $g_hChkMMSkipBB = 0, $g_hChkMMSkipTrain = 0, $g_hChkMMIgnoreIncorrectTroopCombo = 0, $g_hLblFillIncorrectTroopCombo = 0
Global $g_hCmbFillIncorrectTroopCombo = 0, $g_hChkMMIgnoreIncorrectSpellCombo = 0, $g_hLblFillIncorrectSpellCombo = 0, $g_hCmbFillIncorrectSpellCombo = 0, $g_hUseQueuedTroopSpell = 0
Global $g_hChkMMTrainPreviousArmy = 0, $g_hChkMMSkipWallPlacingOnBB = 0, $g_hChkMMCheckCGEarly = 0, $g_hUpgradeWallEarly = 0
Global $g_hAutoUpgradeEarly = 0, $g_hChkForceSwitchifNoCGEvent = 0, $g_hDonateEarly = 0, $g_hChkSkipSnowDetection = 0, $g_hChkEnableCCSleep = 0, $g_hChkSkipDT = 0, $g_hChkSkipBBRoutineOn6thBuilder = 0

Global $g_sCmbFICTroops[7][3] = [ _
								["Barb",	"Barbarians",		1], _
								["Arch",	"Archers",			1], _
								["Giant",	"Giants",			5], _
								["Ball",	"Balloons",			5], _
								["Mini",	"Minions",			2], _
								["SBarb",	"Super Barbarians",	5], _
								["SMini",	"Super Minions",	12]]
Global $g_sCmbFICSpells[6][3] = [ _
								["LSpell",	"Lightning Spell",	1], _
								["BtSpell",	"Bat Spell",		1], _
								["HaSpell",	"Haste Spell",		1], _
								["FSpell",	"Freeze Spell",		1], _
								["ESpell",	"Earthquake Spell",	1], _
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
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_MiscMod", "On Double Train"), $x - 10, $y - 15, 210, 115)
		$g_hChkMMIgnoreIncorrectTroopCombo = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkIgnoreBadTroopCombo", "Ignore Bad Troop Combo"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnDoubleTrain_Info_01", "If Enabled DoubleTrain, Wont Empty Queued Troop, will Disable Precise Army"))
		GUICtrlSetOnEvent(-1, "chkOnDoubleTrain")
	$y += 22
		$g_hLblFillIncorrectTroopCombo = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design - FillIncorrectTroopCombo", "Label_01", "Fill With :"), $x, $y+3, -1, -1)
		GUICtrlSetOnEvent(-1, "chkOnDoubleTrain")
		$g_hCmbFillIncorrectTroopCombo = GUICtrlCreateCombo("", $x + 50, $y, 110, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		Local $sCmbTxt
		For $z = 0 To UBound($g_sCmbFICTroops) - 1
			$sCmbTxt &= $g_sCmbFICTroops[$z][1] & "|"
		Next
		GUICtrlSetData(-1, $sCmbTxt, "Barbarians")
		GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 23
		$g_hChkMMIgnoreIncorrectSpellCombo = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkIgnoreBadSpellCombo", "Ignore Bad Spell Combo"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnDoubleTrain_Info_02", "If Enabled DoubleTrain, Wont Empty Queued Spell, will Disable Precise Army"))
		GUICtrlSetOnEvent(-1, "chkOnDoubleTrain")
	$y += 22
		$g_hLblFillIncorrectSpellCombo = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design - FillIncorrectSpellCombo", "Label_01", "Fill With :"), $x, $y+3, -1, -1)
		GUICtrlSetOnEvent(-1, "chkOnDoubleTrain")
		$g_hCmbFillIncorrectSpellCombo = GUICtrlCreateCombo("", $x + 50, $y, 110, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		$sCmbTxt = ""
		For $z = 0 To UBound($g_sCmbFICSpells) - 1
			$sCmbTxt &= $g_sCmbFICSpells[$z][1] & "|"
		Next
		GUICtrlSetData(-1, $sCmbTxt, "Lightning Spell")
		GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$y += 50
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_MiscMod", "On Train"), $x - 10, $y - 15, 210, 40)
		$g_hChkMMTrainPreviousArmy = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkTrainPreviousArmy", "Train Previous Army"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnDoubleTrain_Info_01", "Will Use Train Previous Army"))
		GUICtrlSetOnEvent(-1, "chkTrainPrev")
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
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_MiscMod", "On FirstCheck"), $x - 10, $y - 15, 210, 215)
	$g_hDonateEarly = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CheckDonateEarly", "Check Donate Early"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnFirstCheckDonateEarly", "Enable Check Donate on First Start"))
		GUICtrlSetOnEvent(-1, "chkCheckDonateEarly")

	$y += 22
		$g_hUpgradeWallEarly = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CheckUpgradeWallEarly", "Check UpgradeWall Early"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnFirstCheckUpgradeWall", "Enable Check UpgradeWall on First Start"))
		GUICtrlSetOnEvent(-1, "chkCheckUpgradeWallEarly")

	$y += 22
		$g_hAutoUpgradeEarly = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CheckAutoUpgradeEarly", "Check AutoUpgrade Early"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnFirstCheckAutoUpgrade", "Enable Check AutoUpgrade on First Start"))
		GUICtrlSetOnEvent(-1, "chkCheckAutoUpgradeEarly")

	$y += 22
	$g_hChkMMCheckCGEarly = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CheckCGEarly", "Check ClanGames Early"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnFirstCheckClanGames", "Enable Check ClanGames on First Start"))
		GUICtrlSetOnEvent(-1, "chkCheckCGEarly")

	$y += 22
		$g_hChkForceSwitchifNoCGEvent = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ForcedSwitchIfNoCG", "Forced switch If No Active CG Event"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnFirstCheckNoCG", "Enable Forced switch If No Active CG Event"))
		GUICtrlSetOnEvent(-1, "chkForcedSwitchIfNoCG")

	$y += 22
		$g_hChkSkipSnowDetection = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SkipSnowDetection", "Skip Snow Detection"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "OnFirstCheckSkipSnow", "Enable Skip Snow Detection." & @CRLF & "Latest update of coc : now obstacle and building not covered by snow"))
		GUICtrlSetOnEvent(-1, "chkSkipSnowDetection")

	$y += 22
		$g_hChkEnableCCSleep = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SetCCSleep", "Set Clan Castle to Sleep"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SetCCSleep", "Enable Clan Castle sleep Mode"))
		GUICtrlSetOnEvent(-1, "chkSetCCSleep")

	$y += 22
		$g_hChkSkipDT = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SkipDT", "Skip Drop Trophy on FirstStart"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkSkipDropTrophyOnFirstStart")
		
	$y += 22
		$g_hChkSkipBBRoutineOn6thBuilder = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "SkipBBRoutineOn6thBuilder", "Skip BB Routine on 6th Builder"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "ChkSkipBBRoutineOn6thBuilder")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
EndFunc ;==>CreateMiscModSubTab

Func CreateClanGamesSettings()
	Local $tmpChallenges
	$g_hGUI_CGSettings = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - Misc", "GUI_CGSettings", "ClanGames Challenge Setting"), $_GUI_MAIN_WIDTH - 4, $_GUI_MAIN_HEIGHT - 100, $g_iFrmBotPosX, $g_iFrmBotPosY + 80, $WS_DLGFRAME, -1, $g_hFrmBot)
	Local $x = 25, $y = 25

	$g_hClanGamesTV = GUICtrlCreateTreeView(6, 6, 200, $_GUI_MAIN_HEIGHT - 140, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_CHECKBOXES), $WS_EX_CLIENTEDGE)

	$g_hChkCGMainLoot = GUICtrlCreateTreeViewItem("Loot Challenges", $g_hClanGamesTV)
		GUICtrlSetOnEvent(-1, "CGLootTVRoot")
	$tmpChallenges = ClanGamesChallenges("$LootChallenges")
	For $j = 0 To UBound($tmpChallenges) - 1
		$g_ahCGMainLootItem[$j] = GUICtrlCreateTreeViewItem($tmpChallenges[$j][1], $g_hChkCGMainLoot)
		GUICtrlSetOnEvent(-1, "CGLootTVItem")
	Next

	$g_hChkCGMainBattle = GUICtrlCreateTreeViewItem("Battle Challenges", $g_hClanGamesTV)
		GUICtrlSetOnEvent(-1, "CGMainBattleTVRoot")
	$tmpChallenges = ClanGamesChallenges("$BattleChallenges")
	For $j = 0 To UBound($tmpChallenges) - 1
		$g_ahCGMainBattleItem[$j] = GUICtrlCreateTreeViewItem($tmpChallenges[$j][1], $g_hChkCGMainBattle)
		GUICtrlSetOnEvent(-1, "CGMainBattleTVItem")
	Next

	$g_hChkCGMainDestruction = GUICtrlCreateTreeViewItem("Destruction Challenges", $g_hClanGamesTV)
		GUICtrlSetOnEvent(-1, "CGMainDestructionTVRoot")
	$tmpChallenges = ClanGamesChallenges("$DestructionChallenges")
	For $j = 0 To UBound($tmpChallenges) - 1
		$g_ahCGMainDestructionItem[$j] = GUICtrlCreateTreeViewItem($tmpChallenges[$j][1], $g_hChkCGMainDestruction)
		GUICtrlSetOnEvent(-1, "CGMainDestructionTVItem")
	Next

	$g_hChkCGMainAir = GUICtrlCreateTreeViewItem("AirTroop Challenges", $g_hClanGamesTV)
		GUICtrlSetOnEvent(-1, "CGMainAirTVRoot")
	$tmpChallenges = ClanGamesChallenges("$AirTroopChallenges")
	For $j = 0 To UBound($tmpChallenges) - 1
		$g_ahCGMainAirItem[$j] = GUICtrlCreateTreeViewItem($tmpChallenges[$j][1], $g_hChkCGMainAir)
		GUICtrlSetOnEvent(-1, "CGMainAirTVItem")
	Next

	$g_hChkCGMainGround = GUICtrlCreateTreeViewItem("GroundTroop Challenges", $g_hClanGamesTV)
		GUICtrlSetOnEvent(-1, "CGMainGroundTVRoot")
	$tmpChallenges = ClanGamesChallenges("$GroundTroopChallenges")
	For $j = 0 To UBound($tmpChallenges) - 1
		$g_ahCGMainGroundItem[$j] = GUICtrlCreateTreeViewItem($tmpChallenges[$j][1], $g_hChkCGMainGround)
		GUICtrlSetOnEvent(-1, "CGMainGroundTVItem")
	Next

	$g_hChkCGMainMisc = GUICtrlCreateTreeViewItem("Miscellaneous Challenges", $g_hClanGamesTV)
		GUICtrlSetOnEvent(-1, "CGMainMiscTVRoot")
	$tmpChallenges = ClanGamesChallenges("$MiscChallenges")
	For $j = 0 To UBound($tmpChallenges) - 1
		$g_ahCGMainMiscItem[$j] = GUICtrlCreateTreeViewItem($tmpChallenges[$j][1], $g_hChkCGMainMisc)
		GUICtrlSetOnEvent(-1, "CGMainMiscTVItem")
	Next

	$g_hChkCGMainSpell = GUICtrlCreateTreeViewItem("Spell Challenges", $g_hClanGamesTV)
		GUICtrlSetOnEvent(-1, "CGMainSpellTVRoot")
	$tmpChallenges = ClanGamesChallenges("$SpellChallenges")
	For $j = 0 To UBound($tmpChallenges) - 1
		$g_ahCGMainSpellItem[$j] = GUICtrlCreateTreeViewItem($tmpChallenges[$j][1], $g_hChkCGMainSpell)
		GUICtrlSetOnEvent(-1, "CGMainSpellTVItem")
	Next

	$g_hChkCGBBBattle = GUICtrlCreateTreeViewItem("BB Battle Challenges", $g_hClanGamesTV)
		GUICtrlSetOnEvent(-1, "CGBBBattleTVRoot")
	$tmpChallenges = ClanGamesChallenges("$BBBattleChallenges")
	For $j = 0 To UBound($tmpChallenges) - 1
		$g_ahCGBBBattleItem[$j] = GUICtrlCreateTreeViewItem($tmpChallenges[$j][1], $g_hChkCGBBBattle)
		GUICtrlSetOnEvent(-1, "CGBBBattleTVItem")
	Next

	$g_hChkCGBBDestruction = GUICtrlCreateTreeViewItem("BB Destruction Challenges", $g_hClanGamesTV)
		GUICtrlSetOnEvent(-1, "CGBBDestructionTVRoot")
	$tmpChallenges = ClanGamesChallenges("$BBDestructionChallenges")
	For $j = 0 To UBound($tmpChallenges) - 1
		$g_ahCGBBDestructionItem[$j] = GUICtrlCreateTreeViewItem($tmpChallenges[$j][1], $g_hChkCGBBDestruction)
		GUICtrlSetOnEvent(-1, "CGBBDestructionTVItem")
	Next

	$g_hChkCGBBTroops = GUICtrlCreateTreeViewItem("BB Troops Challenges", $g_hClanGamesTV)
		GUICtrlSetOnEvent(-1, "CGBBTroopsTVRoot")
	$tmpChallenges = ClanGamesChallenges("$BBTroopsChallenges")
	For $j = 0 To UBound($tmpChallenges) - 1
		$g_ahCGBBTroopsItem[$j] = GUICtrlCreateTreeViewItem($tmpChallenges[$j][1], $g_hChkCGBBTroops)
		GUICtrlSetOnEvent(-1, "CGBBTroopsTVItem")
	Next

	$x = 220
	$y -= 23
	$g_hChkForceBBAttackOnClanGames = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkForceBBAttackOnClanGames", "Force BB Attack"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkClanGamesBB")
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGames60_Info_02", "If ClanGames Enabled : Ignore BB Trophy, BB Loot, BB Wait BM"))
	$y += 23
	$g_hChkClanGamesPurgeAny = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesPurgeAny", "Purge Any Event"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkActivateClangames")
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGames60_Info_03", "If No Event Found, Purge Any Event"))
	$y += 23
		$g_hChkClanGamesStopBeforeReachAndPurge = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesStopBeforeReachAndPurge", "Help Purge when point is nearly Maxed"), $x, $y, -1, -1)
	$y += 23
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblPurgeDay1", "Try to complete on last: "), $x + 20, $y + 2, -1, 17)
		$g_hCmbClanGamesPurgeDay = GUICtrlCreateCombo("", $x + 133, $y, 45, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		Local $sCmbPurgeDayTxt = "1|2"
		GUICtrlSetData(-1, $sCmbPurgeDayTxt, "2")
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblPurgeDay2", "day"), $x + 185, $y + 2, -1, 17)
	$y += 23
		$g_hChkClanGamesSort = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkClanGamesSort", "Sort ClanGames By:"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkSortClanGames")
	$y += 23
		$g_hCmbClanGamesSort = GUICtrlCreateCombo("", $x + 20, $y, 120, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		Local $sCmbTxt = "Easier Difficulties|Longest Time|Higher Score"
		GUICtrlSetData(-1, $sCmbTxt, "Easier Difficulties")
	$y += 23
		$g_hChkCGBBAttackOnly = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCGBBAttackOnly", "Forced Only Do BuilderBase Event"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCGBBAttackOnly", "Enable Forced Only Do BuilderBase Event"))
		GUICtrlSetOnEvent(-1, "chkForcedOnlyBBEvent")
	$y += 40
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ClangamesDesc", "Description"), $x - 10, $y - 15, 250, 120)
		$g_hLabelClangamesDesc = GUICtrlCreateLabel("", $x, $y, 230, 100)
			GUICtrlSetFont(-1, 9, $FW_BOLD, $GUI_FONTITALIC)

	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$y += 140
	$g_hChkCGRootEnabledAll = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCGRootEnableAllItem", "Challenges inherit Challenge Category"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkCGRootEnableAllItem", "Enable/Disable this to quickly enable or disable all item per category"))
		GuiCtrlSetState(-1, $GUI_UNCHECKED)
	$g_hBtnCGSettingsClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "BtnCGSettings", "Close"), $_GUI_MAIN_WIDTH - 100, $_GUI_MAIN_HEIGHT - 160, 85, 25)
		GUICtrlSetOnEvent(-1, "CloseCGSettings")
EndFunc

Global $g_lblCapitalGold = 0, $g_lblCapitalMedal = 0, $g_hCmbForgeBuilder = 0, $g_hChkEnableAutoUpgradeCC = 0, $g_hChkAutoUpgradeCCIgnore = 0, $g_hChkAutoUpgradeCCWallIgnore = 0
Global $g_hChkEnableCollectCCGold = 0, $g_hChkStartWeekendRaid = 0, $g_hChkEnableMinGoldAUCC = 0, $g_hTxtMinCCGoldToUpgrade = 0
Global $g_hChkEnableForgeGold = 0, $g_hChkEnableForgeElix = 0, $g_hChkEnableForgeDE = 0, $g_hChkEnableForgeBBGold = 0, $g_hChkEnableForgeBBElix = 0
Global $g_hTxtAutoUpgradeCCLog = 0

Func CreateClanCapitalTab()
	Local $x = 15, $y = 40
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_ClanCapital_Stats", "Stats"), $x - 10, $y - 15, $g_iSizeWGrpTab3 - 3, 70)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnCapitalGold,  $x, $y, 24, 24)
		$g_lblCapitalGold = GUICtrlCreateLabel("---", $x + 35, $y + 5, 100, -1)
			GUICtrlSetFont(-1, 9, $FW_BOLD, Default, "Arial", $CLEARTYPE_QUALITY)

		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnCapitalMedal, $x + 140, $y, 24, 24)
		$g_lblCapitalMedal = GUICtrlCreateLabel("---", $x + 175, $y + 5, 100, -1)
			GUICtrlSetFont(-1, 9, $FW_BOLD, Default, "Arial", $CLEARTYPE_QUALITY)
		$y += 30
		$g_hChkEnableCollectCCGold = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "CollectCCGold", "Collect Clan Capital Gold"), $x, $y, -1, -1)
		$g_hChkStartWeekendRaid = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "StartWeekendRaid", "StartWeekendRaid"), $x + 180, $y, -1, -1)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$y += 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_ClanCapital_Forge", "Forge/Craft Gold"), $x - 10, $y - 15, $g_iSizeWGrpTab3 - 3, 88)
		$g_hChkEnableForgeGold = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "EnableCCGoldForgeGold", "Use Gold"), $x, $y, -1, -1)
	$y += 20
		$g_hChkEnableForgeElix = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "EnableCCGoldForgeElix", "Use Elixir"), $x, $y, -1, -1)
	$x += 100
	$y -= 20
		$g_hChkEnableForgeDE = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "EnableCCGoldForgeDE", "Use Dark Elixir"), $x, $y, -1, -1)
	$y += 20
		$g_hChkEnableForgeBBGold = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "EnableCCGoldForgeBBGold", "Use BuilderBase Gold"), $x, $y, -1, -1)
	$x += 140
	$y -= 20
		$g_hChkEnableForgeBBElix = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "EnableCCGoldForgeBBElix", "Use BuilderBase Elixir"), $x, $y, -1, -1)
	$x = 15
	$y += 48
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblForgeUseBuilder", "Use "), $x, $y + 2, 45, 17)
		$g_hCmbForgeBuilder = GUICtrlCreateCombo("", $x + 23, $y, 40, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		GUICtrlSetData(-1, "1|2|3|4", "1")
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "InputForgeUseBuilder", "Put How many builder to use to Forge"))
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "LblForgeBuilder", "Builder for Forge"), $x + 65, $y + 2, 100, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$y += 47
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Group_ClanCapital_AutoUpgradeCC", "Auto Upgrade Clan Capital"), $x - 10, $y - 15, $g_iSizeWGrpTab3 - 3, 65)
		$g_hChkEnableAutoUpgradeCC = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkEnableAutoUpgradeCC", "Enable"), $x, $y, -1, -1)
	$x += 100	
		$g_hChkAutoUpgradeCCWallIgnore = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkAutoUpgradeCCWallIgnore", "Ignore Wall Upgrade"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Info_ChkAutoUpgradeCCWallIgnore", "Enable Ignore Upgrade for Wall"))
	$x += 125	
	$g_hChkEnableMinGoldAUCC = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkEnableMinGoldAUCC", "Only Upgrade If Gold > "), $x, $y)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBDropTrophy_Info_01", "Do 1 Attack and immediately surrender"))
	$g_hTxtMinCCGoldToUpgrade = GUICtrlCreateInput($g_iMinCCGoldToUpgrade, $x + 135, $y + 3, 45, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "MinCCGoldToUpgrade", "Set Minimum CC Gold to do AutoUpgrade"))
	$x = 15
	$y += 20
		$g_hChkAutoUpgradeCCIgnore = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkAutoUpgradeCCIgnore", "Ignore Decoration Building"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "Info_ChkAutoUpgradeCCIgnore", "Enable Ignore Upgrade for Grove, Tree, Forest, Campsite"))
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$y += 50
	$x = 0
		$g_hTxtAutoUpgradeCCLog = GUICtrlCreateEdit("", $x, $y, $g_iSizeWGrpTab3 + 3, 120, BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY, $ES_AUTOVSCROLL))
		GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "TxtCCLog", "------------------------------------------------ CLAN CAPITAL LOG ------------------------------------------------"))
		
EndFunc

