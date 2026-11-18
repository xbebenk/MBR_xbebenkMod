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

Func VillageReport($bSuppressLog = False)
	checkmainscreen(True, False, "VillageReport")
	SetLog("Village Report:", $COLOR_INFO)
	getBuilderCount($bSuppressLog) ; update builder data
	
	Local $i = 0
	While IsHeroJourneyPopUp()
		$i += 1
		SetLog("Wait Hero Journey Popup #" & $i, $COLOR_ACTION)
		If _Sleep(1500) Then Return
	Wend
	
	If _CheckPixel($aVillageHasDarkElixir, $g_bCapturePixel) Then ; check if the village have a Dark Elixir Storage
		$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(690, 22)
		$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(690, 59)
		$g_aiCurrentLoot[$eLootDarkElixir] = getResourcesMainScreen(690, 96)
		$g_iGemAmount = getResourcesMainScreen(730, 133)
		If Not $bSuppressLog Then SetLog("[Builder]:" & $g_iFreeBuilderCount & "/" & $g_iTotalBuilderCount, $COLOR_SUCCESS)
		If Not $bSuppressLog Then SetLog("[G]:" & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & " [E]:" & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & " [D]:" & _NumberFormat($g_aiCurrentLoot[$eLootDarkElixir]) & " [GEM]:" & _NumberFormat($g_iGemAmount), $COLOR_SUCCESS)
	Else
		$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(690, 22)
		$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(690, 59)
		$g_iGemAmount = getResourcesMainScreen(730, 85)
		If Not $bSuppressLog Then SetLog("[Builder]:" & $g_iFreeBuilderCount & "/" & $g_iTotalBuilderCount, $COLOR_SUCCESS)
		If Not $bSuppressLog Then SetLog("[G]:" & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & " [E]:" & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & " [GEM]:" & _NumberFormat($g_iGemAmount), $COLOR_SUCCESS)
		If ProfileSwitchAccountEnabled() Then $g_aiCurrentLoot[$eLootDarkElixir] = "" ; prevent applying Dark Elixir of previous account to current account
	EndIf
	
	UpdateStats()
	
EndFunc   ;==>VillageReport

Func IsHeroJourneyPopUp() 
	If _ColorCheck(_GetPixelColor(830, 537, True), Hex(0x6E5D55, 6), 20, Default, "Hero Journey popup") Then Return True
EndFunc
