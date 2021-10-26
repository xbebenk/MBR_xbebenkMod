; #FUNCTION# ====================================================================================================================
; Name ..........: Globals_xbebenk.au3
; Description ...: 
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: 
; Modified ......: 
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

#Region - Builder Base !!!
Global $g_oTxtBBAtkLogInitText = ObjCreate("Scripting.Dictionary")

; Custom Improve - Team AIO Mod++ (xbebenk)
Global $g_aBBUpgradeNameLevel[3] = ["", "", ""]
Global $g_aBBUpgradeResourceCostDuration[3] = ["", "", ""]
Global $g_iChkBBUpgradesToIgnore[28] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hChkBBUpgradesToIgnore[28] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_bRadioBBUpgradesToIgnore = True, $g_bRadioBBCustomOTTO = False
Global Const $g_sBBUpgradesToIgnore[28] = ["Builder Hall", "Gold Mine", "Elixir Collector", "Gold Storage", _
									 "Elixir Storage", "Gem Mine", "Clock Tower", "Star Laboratory", "Builder Barracks", _
									 "Battle Machine", "Cannon", "Double Cannon", "Archer Tower", "Hidden Tesla", "Firecrackers", _
									 "Crusher", "Guard Post", "Air Bombs", "Multi Mortar", "Roaster", "Giant Cannon", "Mega Tesla", _
									 "Lava Launcher", "Push Trap", "Spring Trap", "Mega Mine", "Mine", "Wall"]
	
; @snorlax x @xbebenk credits.
Global Const $g_sBBOptimizeOTTO[14] = ["Builder Hall", "Gold Mine", "Elixir Collector", "Gold Storage", _
                                     "Elixir Storage", "Gem Mine", "Clock Tower", "Star Laboratory", "Builder Barracks", _
                                     "Battle Machine", "Double Cannon", "Archer Tower", "Multi Mortar", "Mega Tesla"]

; Extra options
Global $g_iBBMinAttack = 1, $g_iBBMaxAttack = 4

; Globals for BB Machine
; X, Y, g_bIsBBMachineD, g_bBBIsFirst
Global Const $g_aMachineBBReset[4] = [-1, -1, False, True]
Global $g_aMachineBB[4] = [-1, -1, False, True]
Global $g_iFurtherFromBBDefault = 3

; Report
Global $g_iAvailableAttacksBB = 0, $g_iLastDamage = 0
Global $g_sTxtRegistrationToken = ""

Global $g_aBuilderHallPos = -1, $g_aAirdefensesPos = -1, $g_aCrusherPos = -1, $g_aCannonPos = -1, $g_aGuardPostPos = -1, _
$g_aAirBombs = -1, $g_aLavaLauncherPos = -1, $g_aRoasterPos = -1, $g_aDeployPoints, $g_aDeployBestPoints

Global $g_aExternalEdges, $g_aBuilderBaseDiamond, $g_aOuterEdges, $g_aBuilderBaseOuterDiamond, $g_aBuilderBaseOuterPolygon, $g_aBuilderBaseAttackPolygon, $g_aFinalOuter[4]

; GUI
Global Enum $g_eBBAttackCSV = 0, $g_eBBAttackSmart = 1
Global $g_iCmbBBAttack = $g_eBBAttackCSV
Global $g_hTabBuilderBase = 0, $g_hTabAttack = 0
Global $g_hCmbBBAttack = 0

; Attack CSV
Global $g_bChkBBCustomAttack = False
Global Const $g_sCSVBBAttacksPath = @ScriptDir & "\CSV\BuilderBase"
Global $g_sAttackScrScriptNameBB[3] = ["", "", ""]
Global $g_iBuilderBaseScript = 0

; Upgrade Troops
Global $g_bChkUpgradeTroops = False, $g_bChkUpgradeMachine = False

; BB Upgrade Walls - Team AiO MOD++
Global Const $g_aWallBBInfoPerLevel[10][4] = [[0, 0, 0, 0], [1, 4000, 20, 2], [2, 10000, 50, 3], [3, 100000, 50, 3], [4, 300000, 75, 4], [5, 800000, 100, 5], [6, 1200000, 120, 6], [7, 2000000, 140, 7], [8, 3000000, 160, 8], [9, 4000000, 180, 9]]
Global $g_bChkBBUpgradeWalls = False, $g_iCmbBBWallLevel, $g_iBBWallNumber = 0, _ 
	   $g_bChkBBUpgWallsGold = True, $g_bChkBBUpgWallsElixir = False, $g_bChkBBWallRing = False

; Troops
Global Enum $eBBTroopBarbarian, $eBBTroopArcher, $eBBTroopGiant, $eBBTroopMinion, $eBBTroopBomber, $eBBTroopBabyDragon, $eBBTroopCannon, $eBBTroopNight, $eBBTroopDrop, $eBBTroopPekka, $eBBTroopHogG, $eBBTroopMachine, $g_iBBTroopCount
Global $g_sIcnBBOrder[$g_iBBTroopCount]
Global Const $g_asAttackBarBB2[$g_iBBTroopCount] = ["Barbarian", "Archer", "BoxerGiant", "Minion", "WallBreaker", "BabyDrag", "CannonCart", "Witch", "DropShip", "SuperPekka", "HogGlider", "Machine"]
Global Const $g_asBBTroopShortNames[$g_iBBTroopCount] = ["Barb", "Arch", "Giant", "Minion", "Breaker", "BabyD", "Cannon", "Witch", "Drop", "Pekka", "HogG", "Machine"]
Global Const $g_sTroopsBBAtk[$g_iBBTroopCount] = ["Raged Barbarian", "Sneaky Archer", "Boxer Giant", "Beta Minion", "Bomber Breaker", "Baby Dragon", "Cannon Cart", "Night Witch", "Drop Ship", "Super Pekka", "Hog Glider", "Battle Machine"]

Global $g_bIsMachinePresent = False
Global $g_iBBMachAbilityLastActivatedTime = -1 ; time between abilities

; BB Drop Order
Global $g_hBtnBBDropOrder = 0
Global $g_hGUI_BBDropOrder = 0
Global $g_hChkBBCustomDropOrderEnable = 0
Global $g_hBtnBBDropOrderSet = 0, $g_hBtnBBRemoveDropOrder = 0, $g_hBtnBBClose = 0
Global $g_bBBDropOrderSet = False
Global $g_aiCmbBBDropOrder[$g_iBBTroopCount] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
Global $g_ahCmbBBDropOrder[$g_iBBTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_iBBNextTroopDelay = 2000,  $g_iBBSameTroopDelay = 300; delay time between different and same troops

Global $g_asAttackBarBB[$g_iBBTroopCount + 1] = ["", "Barbarian", "Archer", "BoxerGiant", "Minion", "WallBreaker", "BabyDrag", "CannonCart", "Witch", "DropShip", "SuperPekka", "HogGlider", "Machine"]

Global $g_sBBDropOrder = _ArrayToString($g_asAttackBarBB)

; Camps
Global $g_aCamps[6] = ["", "", "", "", "", ""]

; General
Global $g_bChkBuilderAttack = False, $g_bChkBBStopAt3 = False, $g_bChkBBTrophiesRange = False, $g_iTxtBBDropTrophiesMin = 0, $g_iTxtBBDropTrophiesMax = 0
Global $g_iCmbBBArmy1 = 0, $g_iCmbBBArmy2 = 0, $g_iCmbBBArmy3 = 0, $g_iCmbBBArmy4 = 0, $g_iCmbBBArmy5 = 0, $g_iCmbBBArmy6 = 0

; Log
Global $g_hBBAttackLogFile = 0

Global $g_bOnlyBuilderBase = False

Global $g_bChkBBGetFromCSV = False, $g_bChkBBGetFromArmy

; CleanYardBBAll
Global $g_bChkCleanYardBBAll = False, $g_hChkCleanYardBBall = 0

; Clock tower mecanics.
Global $g_iCmbStartClockTowerBoost = 0, _
$g_bChkClockTowerPotion = 0, $g_iCmbClockTowerPotion = 0 ; AIO ++

#EndRegion - Builder Base !!!
