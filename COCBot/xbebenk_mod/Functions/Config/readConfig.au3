; #FUNCTION# ====================================================================================================================
; Name ..........: readConfig.au3
; Description ...: Reads config file and sets variables
; Syntax ........: readConfig()
; Parameters ....: NA
; Return values .: NA
; Author ........: 
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func ReadConfig_MOD_CustomArmyBB()
	; <><><> CustomArmyBB <><><>
	;IniReadS($g_bChkBBCustomArmyEnable, $g_sProfileConfigPath, "BBCustomArmy", "ChkBBCustomArmyEnable", $g_bChkBBCustomArmyEnable, "Bool")
	
	For $i = 0 To UBound($g_hComboTroopBB) - 1
		IniReadS($g_iCmbCampsBB[$i], $g_sProfileConfigPath, "BBCustomArmy", "ComboTroopBB" & $i, $g_iCmbCampsBB[$i], "Int")
	Next

	; BB Upgrade Walls - Team AiO MOD++
	IniReadS($g_bChkBBUpgradeWalls, $g_sProfileConfigPath, "other", "ChkBBUpgradeWalls", False, "Bool")
	IniReadS($g_iCmbBBWallLevel, $g_sProfileConfigPath, "other", "CmbBBWallLevel", 10, "int")
	IniReadS($g_iBBWallNumber, $g_sProfileConfigPath, "other", "BBWallNumber", 0, "Int")
	IniReadS($g_bChkBBWallRing, $g_sProfileBuildingPath, "other", "ChkBBWallRing", False, "Bool")
	IniReadS($g_bChkBBUpgWallsGold, $g_sProfileBuildingPath, "other", "ChkBBUpgWallsGold", $g_bChkBBUpgWallsGold, "Bool")
	IniReadS($g_bChkBBUpgWallsElixir, $g_sProfileBuildingPath, "other", "ChkBBUpgWallsElixir", False, "Bool")
	
	For $i = 0 To 2
		IniReadS($g_sAttackScrScriptNameBB[$i], $g_sProfileConfigPath, "BuilderBase", "ScriptBB" & $i, "Barch four fingers")
	Next
	
	IniReadS($g_bChkBBStopAt3, $g_sProfileConfigPath, "BuilderBase", "BBStopAt3", False, "Bool")
	IniReadS($g_bChkBuilderAttack, $g_sProfileConfigPath, "BuilderBase", "BuilderAttack", False, "Bool")
	IniReadS($g_bChkBBCustomAttack, $g_sProfileConfigPath, "BuilderBase", "BBRandomAttack", False, "Bool")
	IniReadS($g_bChkBBTrophiesRange, $g_sProfileConfigPath, "BuilderBase", "BBTrophiesRange", False, "Bool")
	
	IniReadS($g_iTxtBBDropTrophiesMin, $g_sProfileConfigPath, "BuilderBase", "BBDropTrophiesMin", 1250, "Int")
	IniReadS($g_iTxtBBDropTrophiesMax, $g_sProfileConfigPath, "BuilderBase", "BBDropTrophiesMax", 2000, "Int")
	; -- AIO BB
	IniReadS($g_bChkUpgradeMachine, $g_sProfileConfigPath, "BuilderBase", "ChkUpgradeMachine", False, "Bool")
	IniReadS($g_bChkBBGetFromCSV, $g_sProfileConfigPath, "BuilderBase", "ChkBBGetFromCSV", False, "Bool")
	IniReadS($g_bChkBBGetFromArmy, $g_sProfileConfigPath, "BuilderBase", "ChkBBGetFromArmy", False, "Bool")
	IniReadS($g_iCmbBBAttack, $g_sProfileConfigPath, "BuilderBase", "CmbBBAttack", $g_iCmbBBAttack, "Int")
	IniReadS($g_iBBMinAttack, $g_sProfileConfigPath, "BuilderBase", "IntBBMinAttack", $g_iBBMinAttack, "Int")
	IniReadS($g_iBBMaxAttack, $g_sProfileConfigPath, "BuilderBase", "IntBBMaxAttack", $g_iBBMaxAttack, "Int")
	IniReadS($g_bOnlyBuilderBase, $g_sProfileConfigPath, "general", "PlayBBOnly", False, "Bool")

EndFunc   ;==>ReadConfig_MOD_CustomArmyBB