; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseReport()
; Description ...: Make Resources report of Builders Base
; Syntax ........: BuilderBaseReport()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (05-2017)
; Modified ......: xbebenk (08-2021)
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
	If $g_iChkBBSuggestedUpgradesOTTO Then
		isGoldFullBB()
		isElixirFullBB()
		If isBHMaxed() Then isMegaTeslaMaxed() ;check if Builder Hall and Mega Tesla have Maxed (lvl 9)
	EndIf
	ClickAway()
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

Func isMegaTeslaMaxed()
	ClickAway()
	Local $sMTCoords
	$sMTCoords = findImage("MegaTesla", $g_sImgMegaTesla, "FV", 1, True) ; Search for Clock Tower
	If $sMTCoords <> "" Then
		$sMTCoords = StringSplit($sMTCoords, ",", $STR_NOCOUNT)
		ClickP($sMTCoords)
		Local $aBuildingName = BuildingInfo(245, 490 + $g_iBottomOffsetY)
		If $aBuildingName[0] = 2 Then
			; Verify if is Builder Hall and max level
			If $aBuildingName[1] = "Mega Tesla" Then
				If $aBuildingName[2] = 9 Then
					SetLog("Your Mega Tesla is Maxed!", $COLOR_SUCCESS)
					$g_bisMegaTeslaMaxed = True
					Return True
				Else
					SetLog("Your Mega Tesla Level is : " & $aBuildingName[2], $COLOR_SUCCESS)
				EndIf
			Endif
		EndIf
	Else
		Setlog("isMegaTeslaMaxed(): Cannot Find Mega Tesla", $COLOR_DEBUG)
	EndIf
	Return False
EndFunc

Func isGoldFullBB()
	$g_bGoldStorageFullBB = False
	Local $aIsGoldFullBB[4] = [740, 40 , 0xE7C00D, 10] ; Main Screen Gold Resource bar is Full
	If _CheckPixel($aIsGoldFullBB, True) Then ;Hex if color of gold (orange)
		SetLog("Builder Base Gold Storages are > 50% : " & _NumberFormat($g_aiCurrentLootBB[$eLootGoldBB]), $COLOR_SUCCESS)
		$g_bGoldStorageFullBB = True
	EndIf
	If $g_bDebugClick And Not $g_bGoldStorageFullBB Then
		Local $colorRead = _GetPixelColor($aIsGoldFullBB[0], $aIsGoldFullBB[1], True)
		SetLog("Builder Base Gold Storages are not > 50%", $COLOR_ACTION)
		SetLog("expected in (" & $aIsGoldFullBB[0] & "," & $aIsGoldFullBB[1] & ")  = " & Hex($aIsGoldFullBB[2], 6) & " - Found " & $colorRead, $COLOR_ACTION)
	EndIf
	Return $g_bGoldStorageFullBB
EndFunc   ;==>isGoldFull

Func isElixirFullBB()
	$g_bElixirStorageFullBB = False
	Local $aIsElixirFullBB[4] = [740, 90 , 0x7945C5, 10] ; Main Screen Elixir Resource bar is Full
	If _CheckPixel($aIsElixirFullBB, True) Then ;Hex if color of Elixir (orange)
		SetLog("Builder Base Elixir Storages are > 50% : " & _NumberFormat($g_aiCurrentLootBB[$eLootElixirBB]), $COLOR_SUCCESS)
		$g_bElixirStorageFullBB = True
	EndIf
	If $g_bDebugClick And Not $g_bElixirStorageFullBB Then
		Local $colorRead = _GetPixelColor($aIsElixirFullBB[0], $aIsElixirFullBB[1], True)
		SetLog("Builder Base Elixir Storages are not > 50%", $COLOR_ACTION)
		SetLog("expected in (" & $aIsElixirFullBB[0] & "," & $aIsElixirFullBB[1] & ")  = " & Hex($aIsElixirFullBB[2], 6) & " - Found " & $colorRead, $COLOR_ACTION)
	EndIf
	Return $g_bElixirStorageFullBB
EndFunc   ;==>isElixirFull



