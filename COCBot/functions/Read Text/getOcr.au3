; #FUNCTION# ====================================================================================================================
; Name ..........: OCR
; Description ...: Gets complete value of gold/Elixir/DarkElixir/Trophy/Gem xxx,xxx
; Author ........: Didipe (2015)
; Modified ......: ProMac (2015), Hervidero (2015-12), MMHK (2016-12), MR.ViPER (2017-4)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func getNameBuilding($x_start, $y_start) ; getNameBuilding(242,520) -> Gets complete name and level of the buildings, bottom of screen
	Return getOcrAndCapture("coc-build", $x_start, $y_start, 420, 27)
EndFunc   ;==>getNameBuilding

Func getGoldVillageSearch($x_start, $y_start) ;48, 69 -> Gets complete value of gold xxx,xxx while searching, top left, Getresources.au3
	Return getOcrAndCapture("coc-v-g", $x_start, $y_start, 90, 18, True)
EndFunc   ;==>getGoldVillageSearch

Func getRemainTrainTimer($x_start, $y_start, $bNeedCapture = True) ;
	Return getOcrAndCapture("coc-RemainTrain", $x_start, $y_start, 70, 13, True, False, $bNeedCapture)
EndFunc   ;==>getRemainTrainTimer

Func getRemainBuildTimer($x_start, $y_start, $bNeedCapture = True) ;
	Return getOcrAndCapture("coc-RemainTrain", $x_start, $y_start, 50, 10, True, False, $bNeedCapture)
EndFunc   ;==>getRemainTrainTimer

Func getElixirVillageSearch($x_start, $y_start) ;48, 69+29 -> Gets complete value of Elixir xxx,xxx, top left,  Getresources.au3
	Return getOcrAndCapture("coc-v-e", $x_start, $y_start, 90, 18, True)
EndFunc   ;==>getElixirVillageSearch

Func getDarkElixirVillageSearch($x_start, $y_start) ;48, 69+57 or 69+69  -> Gets complete value of Dark Elixir xxx,xxx, top left,  Getresources.au3
	Return getOcrAndCapture("coc-v-de", $x_start, $y_start, 75, 18, True)
EndFunc   ;==>getDarkElixirVillageSearch

Func getTrophyVillageSearch($x_start, $y_start) ;48, 69+99 or 69+69 -> Gets complete value of Trophies xxx,xxx , top left, Getresources.au3
	Return getOcrAndCapture("coc-v-t", $x_start, $y_start, 75, 18, True)
EndFunc   ;==>getTrophyVillageSearch

Func getTrophyMainScreen($x_start, $y_start) ; -> Gets trophy value, top left of main screen "VillageReport.au3"
	Return StringReplace(getOcrAndCapture("coc-ms", $x_start, $y_start, 50, 16, True), "-", "")
EndFunc   ;==>getTrophyMainScreen

Func getTrophyLossAttackScreen($x_start, $y_start) ; 48,214 or 48,184 WO/DE -> Gets red number of trophy loss from attack screen, top left
	Return getOcrAndCapture("coc-t-p", $x_start, $y_start, 50, 16, True)
EndFunc   ;==>getTrophyLossAttackScreen

Func getUpgradeResource($x_start, $y_start) ; -> Gets complete value of Gold/Elixir xxx,xxx , RED text on green upgrade button."UpgradeBuildings.au3"
	Return getOcrAndCapture("coc-u-r", $x_start, $y_start, 100, 18, True)
EndFunc   ;==>getUpgradeResource

Func getResourcesMainScreen($x_start, $y_start) ; -> Gets complete value of Gold/Elixir/Dark Elixir/Trophies/Gems xxx,xxx "VillageReport.au3"
	Return StringReplace(getOcrAndCapture("coc-ms", $x_start, $y_start, 120, 16, True), "-", "")
EndFunc   ;==>getResourcesMainScreen

Func getResourcesLoot($x_start, $y_start) ; -> Gets complete value of Gold/Elixir after attack xxx,xxx "AttackReport"
	Return getOcrAndCapture("coc-loot", $x_start, $y_start, 160, 22, True)
EndFunc   ;==>getResourcesLoot

;HArchH Needs to be a bit longer.  Was 75, trying 85
Func getResourcesLootDE($x_start, $y_start) ; -> Gets complete value of Dark Elixir after attack xxx,xxx "AttackReport"
	Return getOcrAndCapture("coc-loot", $x_start, $y_start, 85, 22, True)
EndFunc   ;==>getResourcesLootDE

Func getResourcesLootT($x_start, $y_start) ; -> Gets complete value of Trophies after attack. xxx,xxx "AttackReport"
	Return getOcrAndCapture("coc-loot", $x_start, $y_start, 37, 22, True)
EndFunc   ;==>getResourcesLootT

Func getResourcesBonus($x_start, $y_start) ; -> Gets complete value of Gold/Elixir bonus loot in "AttackReport.au3"
	Return getOcrAndCapture("coc-bonus", $x_start, $y_start, 115, 20, True)
EndFunc   ;==>getResourcesBonus

Func getResourcesBonusPerc($x_start, $y_start) ; -> Gets complete value of Bonus % in "AttackReport.au3"
	Return getOcrAndCapture("coc-bonus", $x_start, $y_start, 48, 16, True)
EndFunc   ;==>getResourcesBonusPerc

Func getLabCost($x_start, $y_start) ;normal lab
	Return StringRegExpReplace(getOcrAndCapture("coc-labcost", $x_start, $y_start, 100, 18, True), "[-x]", "")
	;Return StringReplace(getOcrAndCapture("coc-labcost", $x_start, $y_start, 100, 18, True), "-", "")
EndFunc 

Func getSLabCost($x_start, $y_start) ;builderbase lab
	Return StringRegExpReplace(getOcrAndCapture("coc-slabcost", $x_start, $y_start, 100, 18, True), "[-x]", "")
	;Return getOcrAndCapture("coc-slabcost", $x_start, $y_start, 100, 18, True)
EndFunc 

Func getBldgUpgradeTime($x_start, $y_start) ; -> Gets complete remain building upgrade time
	Return getOcrAndCapture("coc-uptime", $x_start, $y_start, 72, 18) ; Was 42. 72 tested as enough : "12d 19h" now
EndFunc   ;==>getBldgUpgradeTime

Func getLabUpgradeTime($x_start, $y_start) ; -> Gets complete remain lab upgrade time V2 for Dec2015 update
	Return StringReplace(getOcrAndCapture("coc-uptime2", $x_start, $y_start, 68, 22), "-", "") ; 40 is enougth xxx : 2 numbers and one letter at max
EndFunc   ;==>getLabUpgradeTime

Func getHeroUpgradeTime($x_start, $y_start) ; -> Gets complete upgrade time for heroes 464, 527
	Return StringReplace(getOcrAndCapture("coc-uptime2", $x_start, $y_start, 78, 20), "-", "") ; 78 is required to days & hours for young hero
EndFunc   ;==>getHeroUpgradeTime

Func getChatString($x_start, $y_start, $language) ; -> Get string chat request - Latin Alphabetic - EN "DonateCC.au3"
	Return getOcrAndCapture($language, $x_start, $y_start, 310, 15)
EndFunc   ;==>getChatString

Func getBuilders($x_start, $y_start) ;  -> Gets Builders number - main screen --> getBuilders(324,23)  coc-profile
	Return getOcrAndCapture("coc-Builders", $x_start, $y_start, 40, 18, True)
EndFunc   ;==>getBuilders

Func getProfile($x_start, $y_start) ;  -> Gets Attack Win/Defense Win/Donated/Received values - profile screen --> getProfile(160,268)  troops donation
	Return getOcrAndCapture("coc-profile", $x_start, $y_start, 55, 13, True)
EndFunc   ;==>getProfile

Func getTroopCount($x_start, $y_start, $width = 60, $height = 22) ;  -> Gets troop amount on Attack Screen for non-selected troop kind
	Return StringReplace(getOcrAndCapture("coc-troopcount", $x_start, $y_start, $width, $height, True), "-", "")
EndFunc   ;==>getTroopCountSmall

Func getTroopsSpellsLevel($x_start, $y_start) ;  -> Gets spell level on Attack Screen for selected spell kind (could be used for troops too)
	Return getOcrAndCapture("coc-spellslevel", $x_start, $y_start, 20, 18, True)
EndFunc   ;==>getTroopsSpellsLevel

Func getArmyCampCap($x_start, $y_start, $bNeedCapture = True) ;  -> Gets army camp capacity on Army Tab (Troops:xx/xx)
	Return StringReplace(getOcrAndCapture("coc-armycap", $x_start, $y_start, 70, 14, True), "-", "")
EndFunc   ;==>getArmyCampCap

Func getArmySiegeCap($x_start, $y_start, $bNeedCapture = True) ;  -> Gets army camp capacity --> train.au3, and used to read CC request time remaining
	Return StringReplace(getOcrAndCapture("coc-armycap", $x_start, $y_start, 46, 17, True), "-", "")
EndFunc   ;==>getArmySiegeCap

Func getCastleDonateCap($x_start, $y_start, $x1 = 35) ;  -> Gets clan castle capacity,  --> donatecc.au3
	Return getOcrAndCapture("coc-army", $x_start, $y_start, $x1, 14, True)
EndFunc   ;==>getCastleDonateCap

Func getBarracksNewTroopQuantity($x_start, $y_start, $bNeedCapture = True) ;  -> Gets quantity of troops in army Window (slot)
	Return StringReplace(getOcrAndCapture("coc-newarmy", $x_start, $y_start, 55, 18, True), "-", "")
EndFunc   ;==>getBarracksNewTroopQuantity

Func getArmyCapacityOnTrainTroops($x_start, $y_start, $x1 = 63) ;  -> Gets quantity of troops in army Window
	Return StringRegExpReplace(getOcrAndCapture("coc-troopcap", $x_start, $y_start, $x1, 14, True), "[-x]", "")
EndFunc   ;==>getArmyCapacityOnTrainTroops

Func getArmyCapacityOnTrainTroops240($x_start, $y_start, $x1 = 63) ;  -> Gets quantity of troops in army Window
	Return StringRegExpReplace(getOcrAndCapture("coc-troopcap240", $x_start, $y_start, $x1, 14, True), "[-x]", "")
EndFunc   ;==>getArmyCapacityOnTrainTroops

Func getMatchRemain($x_start = 414, $y_start = 475) ; Gets complete Tournament Match Remain / Max
	Local $sRet = "", $aRet[0]
	$sRet = getOcrAndCapture("coc-tournament", $x_start, $y_start, 70, 22)
	If $sRet <> "" Then
		$aRet = StringSplit($sRet, "#", $STR_NOCOUNT)
	EndIf
	Return $aRet
EndFunc   ;==>getMatchRemain


;TestOCRTroopCap(0, 320)
Func TestOCRTroopCap($iStart = 0, $iCount = 10, $path = "D:\OCRTool\TestImages\DebugOCR\", $iSleep = 800)
	
	Local $sRet = "", $sRet1 = "", $sRet2 = "", $aRet, $s1 = ""
	If Not OpenTroopsTab() Then Return
	For $i = $iStart To $iCount
		If Not $g_bRunState Then Return
		$aRet = GetCurrentTroop()
		$sRet = $aRet[0]
		$sRet1 = $aRet[3]
		$sRet2 = StringRegExpReplace(getOcrAndCapture("coc-troopcap", 96, 165, 63, 14)," \d+", "")
		
		SetLog($sRet & "/" & $sRet1 & " = " & $sRet2)
		_CaptureRegion2(96, 165, 96 + 63, 165 + 14)
		SaveDebugImageOCR($i & "_" & $sRet, $path)
		
		If $i = $iCount Then ExitLoop
		Click(122, 394)
		If Not $g_bRunState Then Return
		If _Sleep($iSleep) Then Return
	Next
EndFunc

Func getArmyCapacityOnTrainSpell($x_start, $y_start, $x1 = 40) ;  -> Gets quantity of spell in army Window
	Return StringRegExpReplace(getOcrAndCapture("coc-spellcap", $x_start, $y_start, $x1, 13, True), "[-x]", "")
EndFunc   ;==>getArmyCapacityOnTrainSpell

Func getQueueTroopsQuantity($x_start, $y_start) ;  -> Gets quantity of troops in Queue in Train Tab
	Return StringReplace(getOcrAndCapture("coc-qqtroop", $x_start, $y_start, 58, 15, True), "-", "")
EndFunc   ;==>getQueueTroopsQuantity

Func getAttackDisable($x_start, $y_start) ;  -> 346, 182 - Gets red text disabled for early warning of Personal Break
	Return getOcrAndCapture("coc-dis", $x_start, $y_start, 118, 24, True)
EndFunc   ;==>getAttackDisable

Func getOcrLanguage($x_start, $y_start) ;  -> Get english language - main screen - "Attack" text on attack button
	Return getOcrAndCapture("coc-ms-testl", $x_start, $y_start, 93, 16, True)
EndFunc   ;==>getOcrLanguage

Func getOcrSpaceCastleDonate($x_start, $y_start) ;  -> Get the number of troops donated/capacity from a request
	Return getOcrAndCapture("coc-totalreq", $x_start, $y_start, 47, 13, True)
EndFunc   ;==>getOcrSpaceCastleDonate

Func getOcrOverAllDamage($x_start, $y_start) ;  -> Get the Overall Damage %
	Return getOcrAndCapture("coc-overalldamage", $x_start, $y_start, 55, 25, True)
EndFunc   ;==>getOcrOverAllDamage

Func getOcrGuardShield($x_start, $y_start) ;  -> Get the guard/shield time left, middle top of the screen
	Return getOcrAndCapture("coc-guardshield", $x_start, $y_start, 68, 15)
EndFunc   ;==>getOcrGuardShield

Func getOcrPBTtime($x_start, $y_start) ;  -> Get the Time until PBT starts from PBT info window
	Return getOcrAndCapture("coc-pbttime", $x_start, $y_start, 80, 15)
EndFunc   ;==>getOcrPBTtime

Func getBuilderLeastUpgradeTime($x_start, $y_start) ;  -> Get least upgradetime on builder menu
	Return getOcrAndCapture("coc-buildermenu-cost", $x_start, $y_start, 100, 18, True)
EndFunc   ;==>getBuilderLeastUpgradeTime

Func getBuilderMenuCost($x_start, $y_start) ;  -> Get least upgradetime on builder menu
	Return getOcrAndCapture("coc-buildermenu-cost", $x_start, $y_start, 100, 18, True)
EndFunc   ;==>getBuilderBuilderMenuCost

Func getOresValues($x_start, $y_start, $bNeedCapture = True) ;  -> Get least upgradetime on builder menu
	Return getOcrAndCapture("coc-ores", $x_start, $y_start, 149, 16, $bNeedCapture)
EndFunc   ;==>getOresValues

Func getOresValues2($x_start, $y_start, $bNeedCapture = True) ;  -> Get least upgradetime on builder menu
	Return getOcrAndCapture("coc-ores2", $x_start, $y_start, 149, 16, $bNeedCapture)
EndFunc   ;==>getOresValues2

Func getBuildingName($x_start, $y_start, $length = 180, $height = 20) ;  -> Get BuildingName on builder menu
	Local $BuildingName = "", $Count = 1
	Local $Name = StringReplace(getOcrAndCapture("coc-buildermenu-name", $x_start, $y_start, $length, $height, False), "-", "")
	If StringRegExp($Name, "x\d{1,}") Then
		Local $aCount = StringRegExp($Name, "\d{1,}", 1) ;check if we found count of building
		If IsArray($aCount) Then $Count = $aCount[0]
	EndIf
	
	If StringLeft($Name, 2) = "l " Then 
		$BuildingName = StringTrimLeft($Name, 2) ;remove first "l" because sometimes buildermenu border captured as "l"
	Else
		$BuildingName = $Name
	EndIf
	ReplaceQuantityX($BuildingName)
	
	Local $aResult[2]
	$aResult[0] = $BuildingName
	$aResult[1] = Number($Count)
	Return $aResult
EndFunc   ;==>getBuildingName

Func ReplaceQuantityX(ByRef $UpgradeName)
	;If $g_bDebugSetLog Then SetLog("ReplaceQuantityX Before :" & $UpgradeName, $COLOR_INFO)
	If StringRegExp($UpgradeName, "x\d{1,}") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( x\d{1,})", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	If StringRegExp($UpgradeName, " x") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( x)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " l.+") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( l.+)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " l") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( l)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " \d+") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( \d+)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " \d+.+") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( \d+.+)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " \'") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( \')", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " T$") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( T$)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " 1$") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( 1$)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, "^' ") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "(^' )", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	
	;If $g_bDebugSetLog Then SetLog("ReplaceQuantityX After :" & $UpgradeName, $COLOR_SUCCESS)
EndFunc

Func getCCBuildingName($x_start, $y_start) ;  -> Get BuildingName on builder menu
	Local $BuildingName = "", $Count = 1
	Local $Name = getOcrAndCapture("coc-ccbuildermenu-name", $x_start, $y_start, 200, 25, False)
	If StringRegExp($Name, "x\d{1,}") Then
		Local $aCount = StringRegExp($Name, "\d{1,}", 1) ;check if we found count of building
		If IsArray($aCount) Then $Count = $aCount[0]
	EndIf
	
	If StringLeft($Name, 2) = "l " Then 
		$BuildingName = StringTrimLeft($Name, 2) ;remove first "l" because sometimes buildermenu border captured as "l"
	Else
		$BuildingName = $Name
	EndIf
	
	If StringRegExp($BuildingName, "x\d{1,}") Then
		Local $aReplace = StringRegExp($BuildingName, "( x\d{1,})", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($BuildingName, $aReplace[0], "")
			$BuildingName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	Local $aResult[2]
	$aResult[0] = $BuildingName
	$aResult[1] = Number($Count)
	Return $aResult
EndFunc   ;==>getBuildingName

Func getCCBuildingNameBlue($x_start, $y_start) ;  -> Get BuildingName on builder menu
	Local $BuildingName = "", $Count = 1
	Local $Name = getOcrAndCapture("coc-ccbuildermenu-nameblue", $x_start, $y_start, 200, 25, False)
	If StringRegExp($Name, "x\d{1,}") Then
		Local $aCount = StringRegExp($Name, "\d{1,}", 1) ;check if we found count of building
		If IsArray($aCount) Then $Count = $aCount[0]
	EndIf
	
	If StringLeft($Name, 2) = "l " Then 
		$BuildingName = StringTrimLeft($Name, 2) ;remove first "l" because sometimes buildermenu border captured as "l"
	Else
		$BuildingName = $Name
	EndIf
	
	If StringRegExp($BuildingName, "x\d{1,}") Then
		Local $aReplace = StringRegExp($BuildingName, "( x\d{1,})", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($BuildingName, $aReplace[0], "")
			$BuildingName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	Local $aResult[2]
	$aResult[0] = $BuildingName
	$aResult[1] = Number($Count)
	Return $aResult
EndFunc   ;==>getBuildingName

Func getOcrReloadMessage($x_start, $y_start, $sLogText = Default, $LogTextColor = Default, $bSilentSetLog = Default)
	Local $result = getOcrAndCapture("coc-reloadmsg", $x_start, $y_start, 116, 19, True)
	Local $String = ""
	If $sLogText = Default Then
		$String = "getOcrReloadMessage: " & $result
	Else
		$String = $sLogText & " " & $result
	EndIf
	If $g_bDebugSetlog Then ; if enabled generate debug log message
		SetDebugLog($String, $LogTextColor, $bSilentSetLog)
	ElseIf $result <> "" Then ;
		SetDebugLog($String, $LogTextColor, True) ; if result found, add to log file
	EndIf
	Return $result
EndFunc   ;==>getOcrReloadMessage

Func getOcrMaintenanceTime($x_start, $y_start, $sLogText = Default, $LogTextColor = Default, $bSilentSetLog = Default)
	;  -> Get the Text with time till maintenance is over from reload msg(171, 375)
	Local $result = getOcrAndCapture("coc-maintenance", $x_start, $y_start, 70, 20, True)
	Local $String = ""
	If $sLogText = Default Then
		$String = "getOcrMaintenanceTime: " & $result
	Else
		$String = $sLogText & " " & $result
	EndIf
	If $g_bDebugSetlog Then ; if enabled generate debug log message
		SetDebugLog($String, $LogTextColor, $bSilentSetLog)
	ElseIf $result <> "" Then ;
		SetDebugLog($String, $LogTextColor, True) ; if result found, add to log file
	EndIf
	Return $result
EndFunc   ;==>getOcrMaintenanceTime

Func getOcrTimeGameTime($x_start, $y_start) ;  -> Get the guard/shield time left, middle top of the screen
	Return StringReplace(getOcrAndCapture("coc-clangames", $x_start, $y_start, 116, 31, True), "-", "")
EndFunc   ;==>getOcrTimeGameTime

Func getOcrYourCGScore($x_start, $y_start) ; -> Gets CheckValuesCost on Train Window
	Return StringReplace(getOcrAndCapture("coc-cgscores", $x_start, $y_start, 140, 18, True), "-", "")
EndFunc   ;==>getOcrYourScore

Func getOcrEventTime($x_start, $y_start) ; -> Gets CheckValuesCost on Train Window
	Return getOcrAndCapture("coc-cgevents", $x_start, $y_start, 60, 20, True)
EndFunc   ;==>getOcrEventTime

Func getRemainTLaboratory($x_start, $y_start) ; read actual time remaining in Lab for current upgrade (336,260), changed CoC v9.24 282,277
	Return getOcrAndCapture("coc-RemainLaboratory", $x_start, $y_start, 194, 25)
EndFunc   ;==>getRemainTLaboratory

Func getRemainTPetHouse($x_start, $y_start) ; read actual time in PetHouse
	Return getOcrAndCapture("coc-RemainPetHouse", $x_start, $y_start, 204, 25)
EndFunc   ;==>getRemainTPetHouse

Func getRemainTHero($x_start, $y_start, $bNeedCapture = True) ; Get time remaining for hero to be ready for attack from train window, BK:443,504 AQ:504,504 GW:565:504
	Return getOcrAndCapture("coc-remainhero", $x_start, $y_start, 55, 12, True, False, $bNeedCapture)
EndFunc   ;==>getRemainTHero

Func getRequestRemainTime($x_start, $y_start, $bNeedCapture = True) ; Get Remain Time To request Troops
	Return getOcrAndCapture("coc-CCremainTime", $x_start, $y_start, 30, 14, False, False, $bNeedCapture)
EndFunc   ;==>getRequestRemainTime

Func getChatStringChinese($x_start, $y_start) ; -> Get string chat request - Chinese - "DonateCC.au3"
	Local $bUseOcrImgLoc = True
	Return getOcrAndCapture("chinese-bundle", $x_start, $y_start, 160, 15, Default, $bUseOcrImgLoc)
EndFunc   ;==>getChatStringChinese

Func getChatStringKorean($x_start, $y_start) ; -> Get string chat request - Korean - "DonateCC.au3"
	Local $bUseOcrImgLoc = True
	Return getOcrAndCapture("korean-bundle", $x_start, $y_start, 160, 14, Default, $bUseOcrImgLoc)
EndFunc   ;==>getChatStringKorean

Func getChatStringPersian($x_start, $y_start, $bConvert = True) ; -> Get string chat request - Persian - "DonateCC.au3"
	Local $bUseOcrImgLoc = True
	Local $OCRString = getOcrAndCapture("persian-bundle", $x_start, $y_start, 240, 20, Default, $bUseOcrImgLoc, True)
	If $bConvert = True Then
		$OCRString = StringReverse($OCRString)
		$OCRString = StringReplace($OCRString, "A", "ا")
		$OCRString = StringReplace($OCRString, "B", "ب")
		$OCRString = StringReplace($OCRString, "C", "چ")
		$OCRString = StringReplace($OCRString, "D", "د")
		$OCRString = StringReplace($OCRString, "F", "ف")
		$OCRString = StringReplace($OCRString, "G", "گ")
		$OCRString = StringReplace($OCRString, "J", "ج")
		$OCRString = StringReplace($OCRString, "H", "ه")
		$OCRString = StringReplace($OCRString, "R", "ر")
		$OCRString = StringReplace($OCRString, "K", "ک")
		$OCRString = StringReplace($OCRString, "K", "ل")
		$OCRString = StringReplace($OCRString, "M", "م")
		$OCRString = StringReplace($OCRString, "N", "ن")
		$OCRString = StringReplace($OCRString, "P", "پ")
		$OCRString = StringReplace($OCRString, "S", "س")
		$OCRString = StringReplace($OCRString, "T", "ت")
		$OCRString = StringReplace($OCRString, "V", "و")
		$OCRString = StringReplace($OCRString, "Y", "ی")
		$OCRString = StringReplace($OCRString, "L", "ل")
		$OCRString = StringReplace($OCRString, "Z", "ز")
		$OCRString = StringReplace($OCRString, "X", "خ")
		$OCRString = StringReplace($OCRString, "Q", "ق")
		$OCRString = StringReplace($OCRString, ",", ",")
		$OCRString = StringReplace($OCRString, "0", " ")
		$OCRString = StringReplace($OCRString, "1", ".")
		$OCRString = StringReplace($OCRString, "22", "ع")
		$OCRString = StringReplace($OCRString, "44", "ش")
		$OCRString = StringReplace($OCRString, "55", "ح")
		$OCRString = StringReplace($OCRString, "66", "ض")
		$OCRString = StringReplace($OCRString, "77", "ط")
		$OCRString = StringReplace($OCRString, "88", "لا")
		$OCRString = StringReplace($OCRString, "99", "ث")
		$OCRString = StringStripWS($OCRString, 1 + 2)
	EndIf
	Return $OCRString
EndFunc   ;==>getChatStringPersian

Func OcrForceCaptureRegion($bForce = Default)
	If $bForce = Default Then Return $g_bOcrForceCaptureRegion
	Local $wasForce = $g_bOcrForceCaptureRegion
	$g_bOcrForceCaptureRegion = $bForce
	Return $wasForce
EndFunc   ;==>OcrForceCaptureRegion

Func getOcrAndCapture($language, $x_start, $y_start, $width, $height, $removeSpace = Default, $bImgLoc = Default, $bForceCaptureRegion = Default)
	If $removeSpace = Default Then $removeSpace = False
	If $bImgLoc = Default Then $bImgLoc = False
	If $bForceCaptureRegion = Default Then $bForceCaptureRegion = $g_bOcrForceCaptureRegion
	Static $_hHBitmap = 0
	
	Local $result
	
	If $bForceCaptureRegion = True Then
		_CaptureRegion2($x_start, $y_start, $x_start + $width, $y_start + $height)
	Else
		$_hHBitmap = GetHHBitmapArea($g_hHBitmap2, $x_start, $y_start, $x_start + $width, $y_start + $height)
	EndIf
	If $bImgLoc Then
		If $_hHBitmap <> 0 Then
			$result = getOcrImgLoc($_hHBitmap, $language)
		Else
			$result = getOcrImgLoc($g_hHBitmap2, $language)
		EndIf
	Else
		If $_hHBitmap <> 0 Then
			$result = getOcr($_hHBitmap, $language)
		Else
			$result = getOcr($g_hHBitmap2, $language)
		EndIf
	EndIf
	If $_hHBitmap <> 0 Then
		GdiDeleteHBitmap($_hHBitmap)
	EndIf
	$_hHBitmap = 0
	If ($removeSpace) Then
		$result = StringReplace($result, " ", "")
	Else
		$result = StringStripWS($result, BitOR($STR_STRIPLEADING, $STR_STRIPTRAILING, $STR_STRIPSPACES))
	EndIf
	Return $result
EndFunc   ;==>getOcrAndCapture

Func getOcr(ByRef Const $_hHBitmap, $language)
	Local $result = DllCallMyBot("ocr", "ptr", $_hHBitmap, "str", $language, "int", $g_bDebugOcr ? 1 : 0)
	If IsArray($result) Then
		Return $result[0]
	Else
		Return ""
	EndIf
EndFunc   ;==>getOcr

Func getOcrImgLoc(ByRef Const $_hHBitmap, $sLanguage)
	Local $result = DllCallMyBot("DoOCR", "handle", $_hHBitmap, "str", $sLanguage)

	Local $error = @error ; Store error values as they reset at next function call
	Local $extError = @extended
	If $error Then
		_logErrorDLLCall($g_hLibMyBot, $error)
		SetDebugLog(" imgloc DLL Error : " & $error & " --- " & $extError)
		Return SetError(2, $extError, "") ; Set external error code = 2 for DLL error
	EndIf
	If $g_bDebugImageSave Then SaveDebugImage($sLanguage, False)

	If IsArray($result) Then
		Return $result[0]
	Else
		Return ""
	EndIf
EndFunc   ;==>getOcrImgLoc
