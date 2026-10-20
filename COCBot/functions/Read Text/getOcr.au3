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
	Return getOcrAndCapture("coc-v-g", $x_start, $y_start, 90, 21, True)
EndFunc   ;==>getGoldVillageSearch

Func getRemainTrainTimer($x_start, $y_start, $bNeedCapture = True) ;
	Return getOcrAndCapture("coc-RemainTrain", $x_start, $y_start, 70, 13, True)
EndFunc   ;==>getRemainTrainTimer

Func getRemainBuildTimer($x_start, $y_start, $bNeedCapture = True) ;
	Return getOcrAndCapture("coc-RemainTrain", $x_start, $y_start, 50, 10, True)
EndFunc   ;==>getRemainTrainTimer

Func getElixirVillageSearch($x_start, $y_start) ;48, 69+29 -> Gets complete value of Elixir xxx,xxx, top left,  Getresources.au3
	Return getOcrAndCapture("coc-v-e", $x_start, $y_start, 90, 21, True)
EndFunc   ;==>getElixirVillageSearch

Func getDarkElixirVillageSearch($x_start, $y_start) ;48, 69+57 or 69+69  -> Gets complete value of Dark Elixir xxx,xxx, top left,  Getresources.au3
	Return getOcrAndCapture("coc-v-de", $x_start, $y_start, 75, 21, True)
EndFunc   ;==>getDarkElixirVillageSearch

Func getTrophyVillageSearch($x_start, $y_start) ;48, 69+99 or 69+69 -> Gets complete value of Trophies xxx,xxx , top left, Getresources.au3
	Return getOcrAndCapture("coc-v-t", $x_start, $y_start, 75, 21, True)
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
	Return StringReplace(getOcrAndCapture("coc-ms", $x_start, $y_start, 125, 16, True), "-", "")
EndFunc   ;==>getResourcesMainScreen

Func getTrophyBB($x_start = 70, $y_start = 135) ; -> Gets trophy value BB
	Return StringReplace(getOcrAndCapture("coc-freemagicitems", $x_start, $y_start, 50, 16, True), "-", "")
EndFunc   ;==>getTrophyMainScreen

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
	Return getOcrAndCapture($language, $x_start, $y_start, 310, 17)
EndFunc   ;==>getChatString

Func getBuilders($x_start, $y_start) ;  -> Gets Builders number - main screen --> getBuilders(324,23)  coc-profile
	Return getOcrAndCapture("coc-Builders", $x_start, $y_start, 40, 16, True)
EndFunc   ;==>getBuilders

Func getBuildersOnMenu($x_start = 528, $y_start = 639) ;  -> Gets Builders number - on Builder menu
	Return getOcrAndCapture("coc-totalreq", $x_start, $y_start, 35, 14, True)
EndFunc   ;==>getBuildersOnMenu

Func getPetBuilderOnMenu($x_start = 800, $y_start = 639) ;  -> Gets Builders number - on Builder menu
	Return getOcrAndCapture("coc-totalreq", $x_start, $y_start, 35, 14, True)
EndFunc   ;==>getPetBuilderOnMenu

Func getProfile($x_start, $y_start) ;  -> Gets Attack Win/Defense Win/Donated/Received values - profile screen --> getProfile(160,268)  troops donation
	Return getOcrAndCapture("coc-profile", $x_start, $y_start, 55, 13, True)
EndFunc   ;==>getProfile

Func getTroopCount($x_start, $y_start, $width = 50, $height = 22) ;  -> Gets troop amount on Attack Screen for non-selected troop kind
	Return StringReplace(getOcrAndCapture("coc-troopcount", $x_start, $y_start, $width, $height, True), "-", "")
EndFunc   ;==>getTroopCountSmall

Func getTroopsSpellsLevel($x_start, $y_start) ;  -> Gets spell level on Attack Screen for selected spell kind (could be used for troops too)
	Return getOcrAndCapture("coc-spellslevel", $x_start, $y_start, 30, 18, True)
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

Func getRequestCCCapacity($x_start = 250, $y_start = 148, $width = 90, $height = 22)
	Return StringReplace(getOcrAndCapture("coc-ccgold", $x_start, $y_start, $width, $height, True), "-", "")
EndFunc

Func getMatchRemain($x_start = 395, $y_start = 475) ; Gets complete Tournament Match Remain / Max
	Local $sRet = "", $aRet[0]
	$sRet = getOcrAndCapture("coc-tournament", $x_start, $y_start, 70, 22)
	If $sRet <> "" Then
		$aRet = StringSplit($sRet, "#", $STR_NOCOUNT)
	EndIf
	Return $aRet
EndFunc   ;==>getMatchRemain

Func TestAllOCR($xStart = 0, $yStart = 0, $ilength = 200, $iheight = 50)
	If $xStart = 0 And $yStart = 0 Then
		SetLog("Please set xStart and yStart", $COLOR_DEBUG2)
		Return
	EndIf
	Local $aOCRFile = _FileListToArray(@ScriptDir & "\lib\", "listSymbols_coc-*.xml", $FLTA_FILES)
	If IsArray($aOCRFile) And $aOCRFile[0] > 0 Then
		Local $ocrname = "", $ocrResult = ""
		For $i = 1 To Ubound($aOCRFile)
			$ocrname = StringReplace(StringReplace($aOCRFile[$i], "listSymbols_", ""), ".xml", "")
			SetLog("checking ocrname : " & $ocrname, $COLOR_INFO)
			$ocrResult = getOcrAndCapture($ocrname, $xStart, $yStart, $ilength, $iheight)
			SetLog("Result : " & $ocrResult, $COLOR_DEBUG2)
		Next
	EndIf
EndFunc

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

Func getOcrLanguage($x_start, $y_start) ;  -> Get english language - main screen - "Attack" text on attack button
	Return getOcrAndCapture("coc-ms-testl", $x_start, $y_start, 93, 16, True)
EndFunc   ;==>getOcrLanguage

Func getOcrSpaceCastleDonate($x_start, $y_start) ;  -> Get the number of troops donated/capacity from a request
	Return getOcrAndCapture("coc-totalreq", $x_start, $y_start, 50, 13, True)
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

Func getBuilderLeastUpgradeTime($x_start = 775, $y_start = 66, $length = 55, $height = 14) ;  -> Get least upgradetime on builder menu
	Return getOcrAndCapture("coc-RemainTrain", $x_start, $y_start, $length, $height, True)
EndFunc   ;==>getBuilderLeastUpgradeTime

Func getBuilderMenuCost($x_start, $y_start) ;  -> Get least upgradetime on builder menu
	Return getOcrAndCapture("coc-buildermenu-cost", $x_start, $y_start, 120, 18, True)
EndFunc   ;==>getBuilderBuilderMenuCost

Func getOresValues($x_start, $y_start, $ilength = 60) ;  -> Get least upgradetime on builder menu
	Return StringReplace(getOcrAndCapture("coc-bonus", $x_start, $y_start, $ilength, 20, True), "-", "")
EndFunc   ;==>getOresValues

Func getBuildingName($x_start, $y_start, $length = 180, $height = 15) ;  -> Get BuildingName on builder menu
	Local $BuildingName = "", $Count = 1
	Local $Name = StringReplace(getOcrAndCapture("coc-buildermenu-name", $x_start, $y_start, $length, $height, False), "-", "")
	
	$BuildingName = $Name
	
	Local $aResult[2]
	$aResult[0] = $BuildingName
	$aResult[1] = Number($Count)
	Return $aResult
EndFunc   ;==>getBuildingName

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

Func getOcrMaintenanceTime($x_start, $y_start)
	Local $result = getOcrAndCapture("coc-RemainTrain", $x_start, $y_start, 20, 12, True)
	If Number($result) > 0 Then 
		$result = $result & "m"
	Else
		$result = "soon"
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
	Return getOcrAndCapture("coc-remainhero", $x_start, $y_start, 55, 12, True)
EndFunc   ;==>getRemainTHero

Func getRequestRemainTime($x_start, $y_start, $bNeedCapture = True) ; Get Remain Time To request Troops
	Return getOcrAndCapture("coc-CCremainTime", $x_start, $y_start, 30, 14, False)
EndFunc   ;==>getRequestRemainTime

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

;Func getOcr(ByRef Const $_hHBitmap, $language)
;	Local $result = DllCallMyBot("ocr", "ptr", $_hHBitmap, "str", $language, "int", $g_bDebugOcr ? 1 : 0)
;	If IsArray($result) Then
;		Return $result[0]
;	Else
;		Return ""
;	EndIf
;EndFunc   ;==>getOcr

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

#include <GDIPlus.au3>

Global Const $WM_OCR_TRIGGER = 0x0465
Global Const $OCR_SHM_SIZE   = 4194304
Global $g_hOcrMapFile        = 0
Global $g_pOcrSharedBuf      = 0

Func _GetOcrWorkerHWND()
    ; Cari Window yang memiliki judul sesuai PID instance bot ini
    Local $sTitle = "MBR_OCR_Worker_" & @AutoItPID
    Local $aWnd = DllCall("user32.dll", "hwnd", "FindWindowW", "ptr", 0, "wstr", $sTitle)
    If IsArray($aWnd) And $aWnd[0] <> 0 Then Return $aWnd[0]
    Return 0
EndFunc

Func StartOcrWorkerClient()
    _GDIPlus_Startup()

    ; 1. Buka / Buat Shared Memory unik sesuai PID bot ini
    If $g_pOcrSharedBuf = 0 Then
        Local $sShmName = "MBR_OCR_SHM_" & @AutoItPID
        $g_hOcrMapFile = DllCall("kernel32.dll", "handle", "CreateFileMappingW", _
                "handle", -1, "ptr", 0, "dword", 0x04, "dword", 0, "dword", $OCR_SHM_SIZE, "wstr", $sShmName)[0]
        $g_pOcrSharedBuf = DllCall("kernel32.dll", "ptr", "MapViewOfFile", _
                "handle", $g_hOcrMapFile, "dword", 0xF001F, "dword", 0, "dword", 0, "ulong_ptr", $OCR_SHM_SIZE)[0]
    EndIf

    ; 2. Jalankan ocrworker.exe dengan menyertakan PID instance ini sebagai parameter
    Local $sWorkerExe = @ScriptDir & "\lib\Tesseract\ocrworker.exe"
    Local $sWorkerDir = @ScriptDir & "\lib\Tesseract"

    Local $hWnd = _GetOcrWorkerHWND()
    If $hWnd = 0 Then
        ; Contoh eksekusi: ocrworker.exe 4528
        Run('"' & $sWorkerExe & '" ' & @AutoItPID, $sWorkerDir, @SW_SHOW)
        For $i = 1 To 30
            Sleep(100)
            $hWnd = _GetOcrWorkerHWND()
            If $hWnd <> 0 Then ExitLoop
        Next
    EndIf
    Return $hWnd
EndFunc

; FUNGSI UTAMA (HYBRID)
Func getOcr(ByRef Const $_hHBitmap, $language)
    Local $sRet = ""

    Switch $language
        ; 1. Builders (Tesseract)
        ;Case "coc-Builders"
        ;    $sRet = OcrFromHBitmapDirect($_hHBitmap, "0123456789/", 7, $language)
        ;    Return StringReplace($sRet, "/", "#")
		
        ; 2. Resource Angka Main Screen
        ;Case "coc-ms"
        ;    $sRet = OcrFromHBitmapDirect($_hHBitmap, "0123456789", 7, $language)
        ;    Return $sRet

        ; 3. Builder Menu Name (Gunakan PSM 13 yang sudah terbukti tembus semua nama)
        Case "coc-buildermenu-name"
            $sRet = OcrFromHBitmapDirect($_hHBitmap, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -", 13, $language)
            
            ; Pisahkan kata yang rapat / nempel (misal: 'GoldMine' -> 'Gold Mine', 'GrandWarden' -> 'Grand Warden')
            $sRet = StringRegExpReplace($sRet, "([a-z])([A-Z])", "$1 $2")
            
            ; Koreksi otomatis huruf yang mirip pada font CoC
            $sRet = StringReplace($sRet, "Roval", "Royal")
            $sRet = StringReplace($sRet, "Elixik", "Elixir")
            
            Return StringStripWS($sRet, 3)

        ; 4. Sisanya kembali ke OCR Bawaan MBR
        Case Else
            Local $result = DllCallMyBot("ocr", "ptr", $_hHBitmap, "str", $language, "int", $g_bDebugOcr ? 1 : 0)
            If IsArray($result) Then
                Return $result[0]
            Else
                Return ""
            EndIf
    EndSwitch
EndFunc   ;==>getOcr


Func OcrFromHBitmapDirect(ByRef Const $_hHBitmap, $sWhitelist = "", $iPSM = 7, $sTagName = "ocr")
    Local $hWorkerWnd = _GetOcrWorkerHWND()
    If $hWorkerWnd = 0 Or $g_pOcrSharedBuf = 0 Then
        $hWorkerWnd = StartOcrWorkerClient()
        If $hWorkerWnd = 0 Or $g_pOcrSharedBuf = 0 Then Return ""
    EndIf

    Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($_hHBitmap)
    If @error Or $hBitmap = 0 Then Return ""

    ; Simpan gambar debug jika opsi debug aktif
    If $g_bDebugOcrTS Then
        Local $sDebugDir = @ScriptDir & "\lib\debug\ocr"
        If Not FileExists($sDebugDir) Then DirCreate($sDebugDir)
        
        Local $sTime = @YEAR & @MON & @MDAY & "_" & @HOUR & @MIN & @SEC & "_" & @MSEC
        Local $sImgPath = $sDebugDir & "\" & $sTagName & "_" & $sTime & ".png"
        _GDIPlus_ImageSaveToFile($hBitmap, $sImgPath)
    EndIf

    Local $iW = _GDIPlus_ImageGetWidth($hBitmap)
    Local $iH = _GDIPlus_ImageGetHeight($hBitmap)

    Local $tBitmapData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $iW, $iH, $GDIP_ILMREAD, $GDIP_PXF32ARGB)
    If @error Then
        _GDIPlus_BitmapDispose($hBitmap)
        Return ""
    EndIf

    Local $pScan0 = DllStructGetData($tBitmapData, "Scan0")
    Local $iPixelBytes = $iW * $iH * 4

    If ($iPixelBytes + 256) > $OCR_SHM_SIZE Then
        _GDIPlus_BitmapUnlockBits($hBitmap, $tBitmapData)
        _GDIPlus_BitmapDispose($hBitmap)
        Return ""
    EndIf

    ; Tulis Header
    Local $tHeader = DllStructCreate("int Width;int Height;int PSM;int SaveImg;int WriteLog;char Whitelist[64];char TagName[64]", $g_pOcrSharedBuf)
    DllStructSetData($tHeader, "Width", $iW)
    DllStructSetData($tHeader, "Height", $iH)
    DllStructSetData($tHeader, "PSM", $iPSM)
    DllStructSetData($tHeader, "SaveImg", 0)
    DllStructSetData($tHeader, "WriteLog", ($g_bDebugOcrTS ? 1 : 0))
    DllStructSetData($tHeader, "Whitelist", $sWhitelist)
    DllStructSetData($tHeader, "TagName", $sTagName)

    ; Salin piksel
    DllCall("ntdll.dll", "none", "RtlMoveMemory", "ptr", $g_pOcrSharedBuf + 256, "ptr", $pScan0, "ulong_ptr", $iPixelBytes)

    _GDIPlus_BitmapUnlockBits($hBitmap, $tBitmapData)
    _GDIPlus_BitmapDispose($hBitmap)

    ; Kirim sinyal ke Worker
    DllCall("user32.dll", "lresult", "SendMessageW", _
            "hwnd", $hWorkerWnd, "uint", $WM_OCR_TRIGGER, "wparam", 0, "lparam", 0)

    Local $tResult = DllStructCreate("char[1024]", $g_pOcrSharedBuf)
    Local $sText = StringStripWS(DllStructGetData($tResult, 1), 3)

    If $g_bDebugOcrTS Then SetDebugLog($sTagName & ": " & $sText)
    Return $sText
EndFunc   ;==>OcrFromHBitmapDirect

