; #FUNCTION# ====================================================================================================================
; Name ..........: Includes_xbebenk.au3
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

; Custom Builder Base - Team AiO MOD++
#include "functions\Mod's\BuilderBase\BuilderBaseMain.au3"
#include "functions\Mod's\BuilderBase\BuilderBaseDebugUI.au3"
#include "functions\Mod's\BuilderBase\Attack\BuilderBaseImageDetection.au3"
#include "functions\Mod's\BuilderBase\Attack\BuilderBaseCSV.au3"
#include "functions\Mod's\BuilderBase\Attack\BuilderBaseAttack.au3"
#include "functions\Mod's\BuilderBase\Village\BuilderBasePolygon.au3"

#include "functions\Mod's\BuilderBase\Village\UpgradeWalls.au3"
#include "functions\Mod's\BuilderBase\Village\BattleMachineUpgrade.au3"

#include "functions\Mod's\BuilderBase\Camps\BuilderBaseCorrectAttackBar.au3"
#include "functions\Mod's\BuilderBase\Camps\BuilderBaseCheckArmy.au3"

; Moved to the end to avoid any global declare issues - Team AiO MOD++
#include "functions\Config\saveConfig.au3"
#include "functions\Config\readConfig.au3"
#include "functions\Config\applyConfig.au3"
