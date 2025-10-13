; #FUNCTION# ====================================================================================================================
; Name ..........: VillageReport
; Description ...: This function will report the village free and total builders, gold, elixir, dark elixir and gems.
;                  It will also update the statistics to the GUI.
; Syntax ........: VillageReport()
; Parameters ....: None
; Return values .: None
; Author ........: Hervidero (2015-feb-10)
; Modified ......: Safar46 (2015), Hervidero (2015), KnowJack (June-2015) , ProMac (2015), Sardo 2015-08, MonkeyHunter(6-2106)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func VillageReport($bBypass = False, $bSuppressLog = False)
	If _Sleep($DELAYVILLAGEREPORT1) Then Return
	If _CheckPixel($aIsMainGrayed, $g_bCapturePixel, Default, "VillageReport") Then ClickAway()
	Switch $bBypass
		Case False
			If Not $bSuppressLog Then SetLog("Village Report", $COLOR_INFO)
		Case True
			If Not $bSuppressLog Then SetLog("Updating Village Resource Values", $COLOR_INFO)
		Case Else
			If Not $bSuppressLog Then SetLog("Village Report Error, You have been a BAD programmer!", $COLOR_ERROR)
	EndSwitch
	
	If _Sleep(50) Then Return
	getBuilderCount($bSuppressLog) ; update builder data
	If _Sleep(50) Then Return

	;$g_aiCurrentLoot[$eLootTrophy] = getTrophyMainScreen($aTrophies[0], $aTrophies[1])
	;If Not $bSuppressLog Then SetLog(" [T]: " & _NumberFormat($g_aiCurrentLoot[$eLootTrophy]), $COLOR_SUCCESS)

	If _CheckPixel($aVillageHasDarkElixir, $g_bCapturePixel) Then ; check if the village have a Dark Elixir Storage
		$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(690, 23)
		$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(690, 74)
		$g_aiCurrentLoot[$eLootDarkElixir] = getResourcesMainScreen(690, 123)
		$g_iGemAmount = getResourcesMainScreen(730, 171)
		If Not $bSuppressLog Then SetLog(" [G]: " & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & " [E]: " & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & " [D]: " & _NumberFormat($g_aiCurrentLoot[$eLootDarkElixir]) & " [GEM]: " & _NumberFormat($g_iGemAmount), $COLOR_SUCCESS)
	Else
		$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(690, 23)
		$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(690, 74)
		$g_iGemAmount = getResourcesMainScreen(730, 123)
		If Not $bSuppressLog Then SetLog(" [G]: " & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & " [E]: " & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & " [GEM]: " & _NumberFormat($g_iGemAmount), $COLOR_SUCCESS)
		If ProfileSwitchAccountEnabled() Then $g_aiCurrentLoot[$eLootDarkElixir] = "" ; prevent applying Dark Elixir of previous account to current account
	EndIf
	
	If $bBypass = False Then ; update stats
		UpdateStats()
	EndIf
	
	;If _Sleep(50) Then Return
	;Local $i = 0
	;While _ColorCheck(_GetPixelColor(819, 39, True), Hex(0xF8FCFF, 6), 20) = True ; wait for Builder/shop to close
	;	$i += 1
	;	If _Sleep($DELAYVILLAGEREPORT1) Then Return
	;	If $i >= 20 Then ExitLoop
	;WEnd

EndFunc   ;==>VillageReport
