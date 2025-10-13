; #FUNCTION# ====================================================================================================================
; Name ..........: StartClockTowerBoost
; Description ...:
; Syntax ........: StartClockTowerBoost($bSwitchToBB = False, $bSwitchToNV = False)
; Parameters ....: $bSwitchToBB: Switch from Normal Village to Builder Base - $bSwitchToNV: Switch back to normal Village after Function ran
; Return values .: None
; Author ........: Fliegerfaust (06-2017), MMHK (07-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func StartClockTowerBoost($bSwitchToBB = False, $bSwitchToNV = False, $bUsePotion = False)

	If Not $g_bChkStartClockTowerBoost Then Return
	If Not $g_bRunState Then Return

	If $bSwitchToBB Then
		ClickAway()
		If Not SwitchBetweenBases("BB") Then Return ; Switching to Builders Base
	EndIf
	
	ZoomOutHelperBB() ;go to BH LowerZone
	
	Local $bCTBoost = True
	If $g_bChkCTBoostBlderBz Then
		getBuilderCount(True, True) ; Update Builder Variables for Builders Base
		If $g_iFreeBuilderCountBB = $g_iTotalBuilderCountBB Then $bCTBoost = False ; Builder is not busy, skip Boost
	EndIf

	If Not $bCTBoost Then
		SetLog("Skip Clock Tower Boost as no Building is currently under Upgrade!", $COLOR_INFO)
	Else ; Start Boosting
		SetLog("Boosting Clock Tower", $COLOR_INFO)
		If _Sleep($DELAYCOLLECT2) Then Return
		
		ClickAway("Left")
		Local $sCTCoords, $aCTCoords, $aCTBoost
		$sCTCoords = findImage("ClockTowerAvailable", $g_sImgStartCTBoost, "FV", 1, True) ; Search for Clock Tower
		If $sCTCoords <> "" Then
			$aCTCoords = StringSplit($sCTCoords, ",", $STR_NOCOUNT)
			ClickP($aCTCoords)
			If _Sleep(1000) Then Return

			$aCTBoost = findButton("BoostCT") ; Search for Start Clock Tower Boost Button
			If IsArray($aCTBoost) Then
				ClickP($aCTBoost)
				If _Sleep(1000) Then Return

				$aCTBoost = findButton("BOOSTBtn") ; Search for Boost Button
				If IsArray($aCTBoost) Then
					ClickP($aCTBoost)
					If _Sleep(500) Then Return
					SetLog("Boosted Clock Tower successfully!", $COLOR_SUCCESS)
				Else
					SetLog("Failed to find the BOOST window button", $COLOR_ERROR)
				EndIf
			Else
				SetLog("Cannot find the Boost Button of Clock Tower", $COLOR_ERROR)
			EndIf
		Else
			SetLog("Clock Tower boost is not available!")
		EndIf
		
		If $bUsePotion Then 
			If _Sleep(1500) Then Return
			Local $click = ClickB("ClockTowerPot") ;click Clock Tower Boost potion Button
			If $click Then
				If _Sleep(500) Then Return
				If ClickB("BoostConfirm") Then
					SetLog("Successfully Boost Builderbase with potion", $COLOR_SUCCESS)
				EndIf
			Else
				SetLog("Boost Builder Base Potion Not Found", $COLOR_DEBUG)
			EndIf
		EndIf
	EndIf
	ClickAway("Left")

	If $bSwitchToNV Then SwitchBetweenBases("Main") ; Switching back to the normal Village if true
EndFunc   ;==>StartClockTowerBoost
