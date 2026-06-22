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
		Local $aXY[2] = [0, 0]
		Local $aClock = QuickMIS("CNX", $g_sImgStartCTBoost, $g_InnerDiamondLeft, $g_InnerDiamondTop, $g_InnerDiamondRight, $g_InnerDiamondBottom)
		If IsArray($aClock) And UBound($aClock) > 0 Then
			For $i = 0 To UBound($aClock) - 1
				$aXY[0] = $aClock[$i][1]
				$aXY[1] = $aClock[$i][2]
				If Not IsInsideDiamond($aXY) Then ContinueLoop
				SetLog("Found Clock Tower on " & $aXY[0] & "," & $aXY[1], $COLOR_DEBUG)
				ClickP($aXY)
				If _Sleep(1000) Then Return
				If ClickB("BoostCT") Then
					If _Sleep(1000) Then Return
					If ClickB("BOOSTBtn") Then 
						SetLog("Boosted Clock Tower successfully!", $COLOR_SUCCESS)
						ExitLoop
					Else
						SetLog("Failed to find the BOOST window button", $COLOR_ERROR)
					EndIf
				Else
					SetLog("Cannot find the Boost Button of Clock Tower", $COLOR_ERROR)
				EndIf
			Next
		Else
			SetLog("Clock Tower boost is not available!")
		EndIf
		
		If $bUsePotion Then 
			If _Sleep(1000) Then Return
			If ClickB("ClockTowerPot") Then
				If _Sleep(500) Then Return
				If ClickB("BoostConfirm") Then
					SetLog("Successfully Boost Builderbase with potion", $COLOR_SUCCESS)
				EndIf
			Else
				SetLog("Boost Builder Base Potion Not Found", $COLOR_DEBUG)
			EndIf
		EndIf
	EndIf
	ClickAway()
	If _Sleep(500) Then Return
	If $bSwitchToNV Then SwitchBetweenBases("Main") ; Switching back to the normal Village if true
EndFunc   ;==>StartClockTowerBoost
