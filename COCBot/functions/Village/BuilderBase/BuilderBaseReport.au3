; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseReport()
; Description ...: Make Resources report of Builders Base
; Syntax ........: BuilderBaseReport()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (05-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BuilderBaseReport($bBypass = False, $bSetLog = True)
	ClickAway()
	If _Sleep($DELAYVILLAGEREPORT1) Then Return

	Switch $bBypass
		Case False
			If $bSetLog Then SetLog("Builder Base Report", $COLOR_INFO)
		Case True
			If $bSetLog Then SetLog("Updating Builder Base Resource Values", $COLOR_INFO)
		Case Else
			If $bSetLog Then SetLog("Builder Base Village Report Error, You have been a BAD programmer!", $COLOR_ERROR)
	EndSwitch

	If Not $bSetLog Then SetLog("Builder Base Village Report", $COLOR_INFO)

	getBuilderCount($bSetLog, True) ; update builder data
	If _Sleep($DELAYRESPOND) Then Return

	$g_aiCurrentLootBB[$eLootTrophyBB] = getTrophyMainScreen(67, 84)
	$g_aiCurrentLootBB[$eLootGoldBB] = getResourcesMainScreen(705, 23)
	$g_aiCurrentLootBB[$eLootElixirBB] = getResourcesMainScreen(705, 72)
	If $bSetLog Then SetLog(" [G]: " & _NumberFormat($g_aiCurrentLootBB[$eLootGoldBB]) & " [E]: " & _NumberFormat($g_aiCurrentLootBB[$eLootElixirBB]) & "[T]: " & _NumberFormat($g_aiCurrentLootBB[$eLootTrophyBB]), $COLOR_SUCCESS)

	If Not $bBypass Then ; update stats
		UpdateStats()
	EndIf

	$g_bisBHMaxed = False
	isBHMaxed() ;check if Builder Hut have Maxed (lvl 9)
	isGoldFullBB() ;check if Builder base Gold is Full

EndFunc   ;==>BuilderBaseReport

Func isBHMaxed()
	ClickAway()
	Local $sBHCoords
	$sBHCoords = findImage("BuilderHall", $g_sImgBuilderHall, "FV", 1, True) ; Search for Clock Tower
	If $sBHCoords <> "" Then
		$sBHCoords = StringSplit($sBHCoords, ",", $STR_NOCOUNT)
		ClickP($sBHCoords)
		Local $aBuildingName = BuildingInfo(245, 490 + $g_iBottomOffsetY)
		If $aBuildingName[0] = 2 Then
			; Verify if is Builder Hall and max level
			If $aBuildingName[1] = "Builder Hall" Then
				If $aBuildingName[2] = 9 Then
					SetLog("Your Builder Hall is Maxed!", $COLOR_SUCCESS)
					$g_bisBHMaxed = True
					Return True
				Else
					SetLog("Your Builder Hall Level is : " & $aBuildingName[2], $COLOR_SUCCESS)
				EndIf
			Endif
		EndIf
	Else
		Setlog("isBHMaxed(): Cannot Find Builder Hall", $COLOR_DEBUG)
	EndIf
	Return False
EndFunc

Func isGoldFullBB()
	$g_bGoldStorageFullBB = False
	Local $aIsGoldFullBB[4] = [695, 25 , 0xf4dc72, 10] ; Main Screen Gold Resource bar is Full
	If _CheckPixel($aIsGoldFullBB, True) Then ;Hex if color of gold (orange)
		SetLog("Builder Base Gold Storages are relatively full : " & $g_aiCurrentLootBB[$eLootGoldBB] , $COLOR_SUCCESS)
		$g_bGoldStorageFullBB = True
	EndIf
	Return $g_bGoldStorageFullBB
EndFunc   ;==>isGoldFull



