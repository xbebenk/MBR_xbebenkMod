; #FUNCTION# ====================================================================================================================
; Name ..........: Blacksmith
; Description ...: Equipment Upgrade V1
; Author ........: Moebius (2023-12)
; Modified ......: xbebenk (Feb 2024)
; Remarks .......: This file is part of MyBot Copyright 2015-2024
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: Returns True or False
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......:
; ===============================================================================================================================
Local $sSearchEquipmentDiamond = GetDiamondFromRect2(90, 375, 390, 570) ; Until 6 Equipment (3 columns)

Func Blacksmith($bTest = False)
	If $g_iTownHallLevel < 8 Then Return
	If Not $g_bChkCustomEquipmentOrderEnable Then Return
	
	For $i = 0 To $eEquipmentCount - 1
		If $g_aiCmbCustomEquipmentOrder[$i] = -1 Then
			SetLog("You didn't pick any Equipment Upgrade order!", $COLOR_ERROR)
			SetLog("Check Hero Equipment Upgrade Settings!", $COLOR_ERROR)
			Return
		EndIf
	Next

	Local $bCheckChecked = 0
	For $i = 0 To $eEquipmentCount - 1
		If $g_bChkCustomEquipmentOrder[$i] = 0 Then $bCheckChecked += 1
	Next

	If $bCheckChecked = $eEquipmentCount Then
		SetLog("You didn't enable any Equipment Upgrade order!", $COLOR_ERROR)
		SetLog("Check Hero Equipment Upgrade Settings!", $COLOR_ERROR)
		Return
	EndIf
	
	checkMainScreen()
	Collect(True)
	
	SetLog("Starting Equipment Auto Upgrade", $COLOR_INFO)
	If Not $g_bRunState Then Return
	
	If $g_aiBlacksmithPos[0] <= 0 Or $g_aiBlacksmithPos[1] <= 0 Then
		SetLog("Blacksmith Location unknown!", $COLOR_WARNING)
		AutoLocateBlacksmith(True) ; Blacksmith location unknown, so find it.
		If $g_aiBlacksmithPos[0] = 0 Or $g_aiBlacksmithPos[1] = 0 Then
			SetLog("Problem locating Blacksmith, re-locate Blacksmith position before proceeding", $COLOR_ERROR)
			Return False
		EndIf
	Else
		;Click Blacksmith
		ClickP($g_aiBlacksmithPos)
		If _Sleep(1000) Then Return
	EndIf

	Local $BuildingInfo = BuildingInfo()
	If StringInStr($BuildingInfo[1], "smith") Then
		SetLog("Blacksmith is level " & $BuildingInfo[2])
		$g_iBlacksmithLevel = $BuildingInfo[2]
	Else
		AutoLocateBlacksmith(True)
	EndIf

	If Not OpenBlacksmithWindow() Then 
		SetLog("Blacksmith Window not open", $COLOR_DEBUG2)
		ClickAway()
		Return False ; cant start because we cannot find Equipment button
	EndIf
	If Not $g_bRunState Then Return
	If _Sleep(1000) Then Return
	
	Local $iShinyOre = OresReport()
	If $g_bChkMinOreUpgrade Then
		If $iShinyOre < $g_sTxtMinOreUpgrade Then
			SetLog("Shiny Ore < " & $g_sTxtMinOreUpgrade, $COLOR_DEBUG2)
			ClickAway()
			If _Sleep(500) Then Return
			ClickAway()
			Return
		EndIf
	EndIf
	
	Local $xHero = 0, $yHero = 360, $TmpHero = ""
	Local $sUpgradeName, $sImageName, $sHeroName
	Local $aUpgradeButton[2] = [700, 540]
	For $i = 0 To UBound($g_bChkCustomEquipmentOrder) - 1
		If Not $g_bRunState Then Return
		If Not $g_bChkCustomEquipmentOrder[$i] Then ContinueLoop
		
		$sUpgradeName = $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0]
		$sImageName = $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][1]
		$sHeroName = $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][2]
		
		Switch $sHeroName
			Case "King"
				$xHero = 95
			Case "Queen"
				$xHero = 120
			Case "Prince"
				$xHero = 145
			Case "Warden"
				$xHero = 170
			Case "Champion"
				$xHero = 195
			Case "Dragon"
				$xHero = 220
		EndSwitch
		
		SetLog("Try to upgrade " & $sUpgradeName, $COLOR_INFO)
		If $TmpHero <> $sHeroName Then
			SetLog("Click Hero " & $sHeroName, $COLOR_ACTION)
			Click($xHero, $yHero)
			$TmpHero = $sHeroName
			If _Sleep(2000) Then Return
		EndIf
		
		If Not $g_bRunState Then Return
		If $g_bDebugSetLog Then SetLog("Searching image : " & $sImageName, $COLOR_ACTION)
		If QuickMIS("BFI", $g_sImgEquipmentResearch & $sImageName & "*", 74, 385, 300, 485) Then
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, $sUpgradeName)
			If _Sleep(2000) Then Return
			
			If $g_bChkMinOreUpgrade And OresReport(False) < $g_sTxtMinOreUpgrade Then
				SetLog("Shiny Ore < " & $g_sTxtMinOreUpgrade, $COLOR_DEBUG2)
				ClickAway()
				If _Sleep(500) Then Return
				ClickAway()
				Return
			EndIf
			
			If _ColorCheck(_GetPixelColor(830, 133, True), Hex(0x635550, 6), 20, Default, "EquipmentWindow") Then
				If _ColorCheck(_GetPixelColor(805, 512, True), Hex(0xDBDBDB, 6), 20, Default, "GrayButton") Then
					SetLog($sUpgradeName & ", Grey Button detected", $COLOR_DEBUG2)
					Click(820, 105, 1, 0, "Close EquipmentWindow")
					If _Sleep(2000) Then Return
					ContinueLoop
				EndIf
				
				If _ColorCheck(_GetPixelColor(824, 548, True), Hex(0xA6D84B, 6), 30, Default, "GreenButton") Then
					If QuickMIS("BC1", $g_sImgEquipmentRedZero, 600, 540, 820, 570) Then 
						SetLog($sUpgradeName & ", Insufficient Resource detected", $COLOR_DEBUG2)
						Click(820, 105, 1, 0, "Close EquipmentWindow")
						If _Sleep(2000) Then Return
						ContinueLoop
					EndIf
					ClickP($aUpgradeButton) ;click upgrade 
					If _Sleep(1000) Then Return
					SetLog("Upgrading " & $sUpgradeName, $COLOR_SUCCESS)
					ClickP($aUpgradeButton) ;click upgrade again (confirm)
					If _Sleep(2000) Then Return
					ClickP($aUpgradeButton) ;click again to dismiss animation
					If _Sleep(2000) Then Return
					Click(820, 105, 1, 0, "Close EquipmentWindow")
					If _Sleep(2000) Then Return
				Else 
					SetLog($sUpgradeName & ", Green Button not detected", $COLOR_DEBUG2)
				EndIf
			Else
				SetLog("Cannot verify Equipment upgrade window", $COLOR_DEBUG2)
				ContinueLoop
			EndIf
		Else
			SetLog("Cannot find " & $sUpgradeName, $COLOR_DEBUG2)
			ContinueLoop
		EndIf
	Next
	ClickAway()
	SetLog("Equipment Auto Upgrade finished", $COLOR_INFO)
	If IsBlacksmithPage() Then ClickAway()
	If _Sleep(500) Then Return
	ClickAway()
EndFunc   ;==>Blacksmith

Func OpenBlacksmithWindow()
	Local $bRet = False
	If IsBlacksmithPage(False, 1) Then Return True
	If ClickB("Equipment") Then
		If _Sleep(1000) Then Return
		If IsBlacksmithPage(False, 1) Then $bRet = True
	Else
		SetLog("Cannot find Equipment Button!", $COLOR_ERROR)
		ClickAway()
	EndIf
	Return $bRet
EndFunc   ;==>OpenBlacksmithWindow

Func OresReport($bOpenEquipmentWindow = True)
	Local $iRetShiny = 0
	
	If $bOpenEquipmentWindow Then Click(110, 310, 1, 0, "Click First Equipment")
	If _Sleep(1000) Then Return
	
	Local $sShiny = getOresValues(480, 460, 60)
	If Number($sShiny) > 0 Then $iRetShiny = Number($sShiny)
	SetLog("[Shiny]: " & $sShiny, $COLOR_DEBUG)
	
	Local $sGlowy = getOresValues(590, 460, 60)
	SetLog("[Glowy]: " & $sGlowy, $COLOR_DEBUG)

	Local $sStarry = getOresValues(700, 460, 50)
	SetLog("[Starry]: " & $sStarry, $COLOR_DEBUG)
	
	If $bOpenEquipmentWindow Then 
		Click(800, 100, 1, 0, "Click Close EquipmentWindow")
		If _Sleep(1000) Then Return
	EndIf
	
	Return $iRetShiny
EndFunc   ;==>OresReport
