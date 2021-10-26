; #FUNCTION# ====================================================================================================================
; Name ..........: saveConfig.au3
; Description ...: Saves all of the GUI values to the config.ini and building.ini files
; Syntax ........: saveConfig()
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
;<><><> Xbebenk <><><>
Func SaveConfig_MOD_CustomArmyBB()
	; <><><> CustomArmyBB <><><>
	ApplyConfig_MOD_CustomArmyBB(GetApplyConfigSaveAction())
	;_Ini_Add("BBCustomArmy", "ChkBBCustomArmyEnable", $g_bChkBBCustomArmyEnable)

	For $i = 0 To UBound($g_hComboTroopBB) - 1
		_Ini_Add("BBCustomArmy", "ComboTroopBB" & $i, $g_iCmbCampsBB[$i])
	Next

	; BB Upgrade Walls - Team AiO MOD++
	_Ini_Add("other", "ChkBBUpgradeWalls", $g_bChkBBUpgradeWalls ? 1 : 0)
	_Ini_Add("other", "CmbBBWallLevel", $g_iCmbBBWallLevel)
	_Ini_Add("other", "BBWallNumber", $g_iBBWallNumber)
	_Ini_Add("other", "ChkBBWallRing", $g_bChkBBWallRing ? 1 : 0)
	_Ini_Add("other", "ChkBBUpgWallsGold", $g_bChkBBUpgWallsGold ? 1 : 0)
	_Ini_Add("other", "ChkBBUpgWallsElixir", $g_bChkBBUpgWallsElixir ? 1 : 0)

	For $i = 0 To 2
		_Ini_Add("BuilderBase", "ScriptBB" & $i, $g_sAttackScrScriptNameBB[$i])
	Next

	_Ini_Add("other", "ChkPlacingNewBuildings", $g_iChkPlacingNewBuildings)
	_Ini_Add("BuilderBase", "BuilderAttack", $g_bChkBuilderAttack ? 1 : 0)
	_Ini_Add("BuilderBase", "BBStopAt3", $g_bChkBBStopAt3 ? 1 : 0)
	_Ini_Add("BuilderBase", "BBTrophiesRange", $g_bChkBBTrophiesRange ? 1 : 0)
	_Ini_Add("BuilderBase", "BBRandomAttack", $g_bChkBBCustomAttack ? 1 : 0)

	_Ini_Add("BuilderBase", "BBDropTrophiesMin", $g_iTxtBBDropTrophiesMin)
	_Ini_Add("BuilderBase", "BBDropTrophiesMax", $g_iTxtBBDropTrophiesMax)
	_Ini_Add("BuilderBase", "BBArmy1", $g_iCmbBBArmy1)
	_Ini_Add("BuilderBase", "BBArmy2", $g_iCmbBBArmy2)
	_Ini_Add("BuilderBase", "BBArmy3", $g_iCmbBBArmy3)
	_Ini_Add("BuilderBase", "BBArmy4", $g_iCmbBBArmy4)
	_Ini_Add("BuilderBase", "BBArmy5", $g_iCmbBBArmy5)
	_Ini_Add("BuilderBase", "BBArmy6", $g_iCmbBBArmy6)
	; -- AIO BB
	_Ini_Add("BuilderBase", "ChkUpgradeMachine", $g_bChkUpgradeMachine ? 1 : 0)
	_Ini_Add("BuilderBase", "ChkBBGetFromCSV", $g_bChkBBGetFromCSV)
	_Ini_Add("BuilderBase", "ChkBBGetFromArmy", $g_bChkBBGetFromArmy)
	_Ini_Add("BuilderBase", "CmbBBAttack", $g_iCmbBBAttack)
	_Ini_Add("BuilderBase", "IntBBMinAttack", $g_iBBMinAttack)
	_Ini_Add("BuilderBase", "IntBBMaxAttack", $g_iBBMaxAttack)
	_Ini_Add("general", "PlayBBOnly", $g_bOnlyBuilderBase ? 1 : 0)
EndFunc   ;==>SaveConfig_MOD_CustomArmyBB
