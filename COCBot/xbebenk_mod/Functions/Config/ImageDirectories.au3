; #Variables# ====================================================================================================================
; Name ..........: Image Search Directories
; Description ...: Gobal Strings holding Path to Images used for Image Search
; Syntax ........: $g_sImgxxx = @ScriptDir & "\imgxml\xxx\"
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#Region BuilderBaseCustomArmy
Global $g_sImgCustomArmyBB = @ScriptDir & "\COCBot\xbebenk_mod\Images\BuilderBase\Attack\VersusBattle\ChangeTroops\"
Global $aArmyTrainButtonBB = [46, 572, 0xE5A439, 10]
Global Const $g_sImgPathFillArmyCampsWindow = @ScriptDir & "\COCBot\xbebenk_mod\Images\BuilderBase\FillArmyCamps\Window\"
Global Const $g_sImgPathTroopsTrain = @ScriptDir & "\COCBot\xbebenk_mod\Images\BuilderBase\FillArmyCamps\TroopsTrain\"
Global Const $g_sImgPathCamps = @ScriptDir & "\COCBot\xbebenk_mod\Images\BuilderBase\FillArmyCamps\Bundles\Camps\"
#EndRegion BuilderBaseCustomArmy

#Region Builder Base
Global $g_sModImageLocation = @ScriptDir & "\COCBot\xbebenk_mod\Images\Old"

;Machine Upgrade
Global Const $g_sXMLTroopsUpgradeMachine = $g_sModImageLocation & "\BuildersBase\TroopsUpgrade\Machine"

; Builder Base
Global Const $g_sImgPathIsCTBoosted = $g_sModImageLocation & "\BuildersBase\ClockTowerBoosted"
Global Const $g_sImgBBLootAvail = @ScriptDir & "\imgxml\Attack\BuilderBase\LootAvail\"

; Builder Base Attack
Global $g_aOpponentVillageVisible[1][3] = [[0xFED5D4, 0, 1]] ; more ez ; samm0d

Global Const $g_sBundleBuilderHall = $g_sModImageLocation & "\BuildersBase\Bundles\AttackBuildings\BuilderHall"
Global Const $g_sBundleDeployPointsBB = $g_sModImageLocation & "\BuildersBase\Bundles\AttackBuildings\DeployPoints"

Global Const $g_sImgOpponentBuildingsBB = $g_sModImageLocation & "\BuildersBase\Bundles\AttackBuildings\"

Global Const $g_sImgAttackBtnBB = $g_sModImageLocation & "\BuildersBase\Attack\AttackBtn\"
Global Const $g_sImgVersusWindow = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\Window\"
; Global Const $g_sImgCloudSearch = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\Clouds\"

; Report Window : Victory | Draw | Defeat
Global Const $g_sImgReportWaitBB = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\Report\Waiting\"
Global Const $g_sImgReportFinishedBB = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\Report\Thr\"
#EndRegion Builder Base

#Region Builder Base Walls Upgrade
Global Const $g_sBundleWallsBB = $g_sModImageLocation & "\BuildersBase\Bundles\Walls"
;Global Const $g_aBundleWallsBBParms[3] = [0, "0,50,860,732", False] ; [0] Quantity2Match [1] Area2Search [2] ForceArea
#EndRegion Builder Base Walls Upgrade

#Region - DMatchingBundles.au3

; #FUNCTION# ====================================================================================================================
; Name ..........: DMatchingBundles.au3
; Description ...: Dissociable.Matching.dll Bundles
; Author ........: Dissociable (2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Global $g_sBaseDMatchingPathB = @ScriptDir & "\COCBot\xbebenk_mod\Bundles\Image Matching"

; DPBB !
Global Const $g_sBundleDeployPointsBBD = $g_sBaseDMatchingPathB & "\DPBB\"
#EndRegion - DMatchingBundles.au3

; #FUNCTION# ====================================================================================================================
; Name ..........: DOCRBundles.au3
; Description ...: OCR Bundles Paths
; Author ........: Dissociable (2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $g_sBaseDOCRPathB = @ScriptDir & "\COCBot\xbebenk_mod\Bundles\OCR"
