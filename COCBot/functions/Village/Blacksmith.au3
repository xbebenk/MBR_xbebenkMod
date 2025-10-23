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

	;Local Static $iLastTimeChecked[8]
	;If $g_bFirstStart Then $iLastTimeChecked[$g_iCurAccount] = ""
	;
	;; Check if is a valid date
	;If _DateIsValid($iLastTimeChecked[$g_iCurAccount]) Then
	;	Local $iLastCheck = _DateDiff('n', $iLastTimeChecked[$g_iCurAccount], _NowCalc()) ; elapse time from last check (minutes)
	;	SetDebugLog("Blacksmith LastCheck: " & $iLastTimeChecked[$g_iCurAccount] & ", Check DateCalc: " & $iLastCheck)
	;	; A check each 6 hours [6*60 = 360] Or when star Bonus Received
	;	If $iLastCheck <= 360 Then Return
	;EndIf

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

	Collect(True)
	
	SetLog("Starting Equipment Auto Upgrade", $COLOR_INFO)
	If Not $g_bRunState Then Return
	
	If $g_aiBlacksmithPos[0] <= 0 Or $g_aiBlacksmithPos[1] <= 0 Then
		SetLog("Blacksmith Location unknown!", $COLOR_WARNING)
		ImgLocateBlacksmith(True) ; Blacksmith location unknown, so find it.
		If $g_aiBlacksmithPos[0] = 0 Or $g_aiBlacksmithPos[1] = 0 Then
			SetLog("Problem locating Blacksmith, re-locate Blacksmith position before proceeding", $COLOR_ERROR)
			Return False
		EndIf
	Else
		;Click Blacksmith
		ClickP($g_aiBlacksmithPos)
		If _Sleep(1000) Then Return
	EndIf

	Local $BuildingInfo = BuildingInfo(242, 477)
	If StringInStr($BuildingInfo[1], "smith") Then
		SetLog("Blacksmith is level " & $BuildingInfo[2])
		$g_iBlacksmithLevel = $BuildingInfo[2]
	Else
		ImgLocateBlacksmith(True)
	EndIf

	If Not OpenBlacksmithWindow() Then Return False ; cant start because we cannot find the Pets button
	If Not $g_bRunState Then Return
	OresReport()
	If _Sleep(1000) Then Return

	For $i = 0 To $eEquipmentCount - 1

		If Not $g_bRunState Then Return

		If $g_bChkCustomEquipmentOrder[$i] = 0 Then ContinueLoop

		SetLog("Try to upgrade " & $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0], $COLOR_SUCCESS)
		If _Sleep(500) Then Return

		;If $g_iBlacksmithLevel < 7 Then
		;	Switch $g_aiCmbCustomEquipmentOrder[$i]
		;		Case 0, 1, 5, 6, 9, 10, 13, 14
		;			SetLog("BlackSmith level 7 needed, looking next", $COLOR_SUCCESS)
		;			ContinueLoop
		;	EndSwitch
		;EndIf

		Local $ToClickOnHero = False
		If $i = 0 Then
			$ToClickOnHero = True
		Else
			If Not IsBlacksmithPage() Then
				SetLog("Blacksmith Window not found", $COLOR_ERROR)
				If $g_bDebugImageSave Then SaveDebugImage("Blacksmith_Window")
				ClickAway()
				If _Sleep(500) Then Return
				ClickAway()
				Return
			EndIf
			If QuickMIS("BC1", $g_sImgHeroEquipement, 100, 310, 275, 360) Then
				If $g_iQuickMISName <> $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][2] Then $ToClickOnHero = True
			Else
				SetLog("No Hero head image found", $COLOR_ERROR)
				If $g_bDebugImageSave Then SaveDebugImage("Blacksmith_HeroHead")
				ClickAway()
				Return
			EndIf
		EndIf

		If $ToClickOnHero Then
			SetDebugLog("Click On " & $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][2] & " [" & $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][3] & ",375]", $COLOR_DEBUG)
			Click($g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][3], 345) ; Click on corresponding Hero
		EndIf

		If Not $g_bRunState Then Return
		If _Sleep(2000) Then Return

		Local $bLoopNew = 0
		While 1
			If Not $g_bRunState Then ExitLoop
			Local $asSearchResult = decodeSingleCoord(FindImageInPlace2("NewEquipment", $g_sImgEquipmentNew, 90, 375, 390, 570, True)) ; Looking for "New" on Equipment
			If IsArray($asSearchResult) And UBound($asSearchResult) = 2 Then
				Click($asSearchResult[0] + 20, $asSearchResult[1] + 40)
				If _Sleep(2000) Then ExitLoop
				Click(600, 380)     ; Click somewhere to get rid of animation
				If _Sleep(2000) Then ExitLoop
				ClickAway()
				If _Sleep(2000) Then ExitLoop
			Else
				ExitLoop
			EndIf
			If _Sleep(150) Then ExitLoop
			$bLoopNew += 1
			If $bLoopNew = 10 Then ExitLoop ; Just in case
		WEnd

		Local $aEquipmentUpgrades = findMultiple($g_sImgEquipmentResearch, $sSearchEquipmentDiamond, $sSearchEquipmentDiamond, 0, 1000, 0, "objectname,objectpoints", True)
		If UBound($aEquipmentUpgrades, 1) >= 1 Then ; if we found any troops
			Local $Exitloop = False
			For $t = 0 To UBound($aEquipmentUpgrades, 1) - 1 ; Loop through found upgrades
				Local $aTempEquipmentArray = $aEquipmentUpgrades[$t] ; Declare Array to Temp Array
				If $aTempEquipmentArray[0] = $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][1] Then ; if this is the file we want
					Local $aCoords = decodeSingleCoord($aTempEquipmentArray[1])
					Local $bLoop = 0, $Updated = False
					ClickP($aCoords) ; click equipment
					If Not $g_bRunState Then Return
					If _Sleep(2000) Then Return
					If Not _ColorCheck(_GetPixelColor(820, 109, True), Hex(0xF02227, 6), 20) Then
						SetDebugLog("Close Button of equipment upgrade not found!", $COLOR_DEBUG)
						If $g_bDebugImageSave Then SaveDebugImage("Blacksmith_EquipmentWindow")
						SetLog($g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0] & " upgrade window not found", $COLOR_ERROR)
						If _Sleep(1500) Then Return
						ClickAway()
						If _Sleep(500) Then Return
						ContinueLoop 2
					EndIf
					If _ColorCheck(_GetPixelColor(690, 566, True), Hex(0xABABAB, 6), 20) Then
						SetDebugLog("Grey Upgrade Button detected!", $COLOR_DEBUG)
						SetLog($g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0] & " upgrade unavailable", $COLOR_DEBUG)
						If _Sleep(1500) Then Return
						ClickAway()
						ContinueLoop 2
					EndIf
					If _ColorCheck(_GetPixelColor(690, 566, True), Hex(0x3F3A38, 6), 15) Then
						SetDebugLog("Dark Grey Upgrade Button detected!", $COLOR_DEBUG)
						SetLog($g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0] & "  has reached max level!", $COLOR_DEBUG)
						If _Sleep(1500) Then Return
						$g_bChkCustomEquipmentOrder[$i] = 0
						GUICtrlSetState($g_hChkCustomEquipmentOrder[$i], $GUI_UNCHECKED)
						ClickAway()
						ContinueLoop 2
					EndIf
					While 1
						If Not $g_bRunState Then Return
						If $bTest Then
							SetLog("Test only : Bot won't click on upgrade button", $COLOR_DEBUG)
							If _Sleep(2000) Then Return
							ClickAway()
							$Exitloop = True
							ExitLoop
						EndIf
						If _ColorCheck(_GetPixelColor(690, 566, True), Hex(0xABABAB, 6), 20) Then
							SetDebugLog("Grey Upgrade Button detected!", $COLOR_DEBUG)
							SetLog($g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0] & " upgrade unavailable", $COLOR_DEBUG)
							If _Sleep(1500) Then Return
							ClickAway()
							$Exitloop = True
							ExitLoop
						EndIf
						If _ColorCheck(_GetPixelColor(690, 566, True), Hex(0x3F3A38, 6), 15) Then
							SetDebugLog("Dark Grey Upgrade Button detected!", $COLOR_DEBUG)
							SetLog($g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0] & "  has reached max level!", $COLOR_DEBUG)
							If _Sleep(1500) Then Return
							$g_bChkCustomEquipmentOrder[$i] = 0
							GUICtrlSetState($g_hChkCustomEquipmentOrder[$i], $GUI_UNCHECKED)
							ClickAway()
							$Exitloop = True
							ExitLoop
						EndIf
						If UBound(decodeSingleCoord(FindImageInPlace2("RedZero", $g_sImgRedZero, 585, 510, 825, 570, True))) > 1 Then
							SetDebugLog("Red zero found in upgrade button", $COLOR_DEBUG)
							SetLog("Not enough resource to upgrade " & $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0], $COLOR_DEBUG2)
							If _Sleep(1500) Then Return
							ClickAway()
							$Exitloop = True
							ExitLoop
						EndIf
						Click(705, 545, 1, 0, "#0299")     ; Click upgrade buttton
						If _Sleep(1500) Then Return
						If Not $g_bRunState Then Return
						If UBound(decodeSingleCoord(FindImageInPlace2("RedZero", $g_sImgRedZero, 585, 510, 825, 570, True))) > 1 Then
							SetDebugLog("Red zero found in confirm button", $COLOR_DEBUG)
							SetLog("Not enough resource to upgrade " & $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0], $COLOR_DEBUG2)
							If _Sleep(1500) Then Return
							ClickAway()
							$Exitloop = True
							ExitLoop
						EndIf
						Click(705, 545, 1, 0, "#0299")     ; Click upgrade buttton (Confirm)
						If isGemOpen(True) Then
							SetDebugLog("Gem Window Detected", $COLOR_DEBUG)
							SetLog("Not enough resource to upgrade " & $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0], $COLOR_DEBUG2)
							If _Sleep(1500) Then Return
							ClickAway()
							$Exitloop = True
							ExitLoop
						EndIf
						SetLog("Equipment successfully upgraded", $COLOR_SUCCESS1)
						$Updated = True

						If _Sleep(2000) Then Return
						If _ColorCheck(_GetPixelColor(800, 385, True), Hex(0x808080, 6), 15) Then
							SetDebugLog("Equipment animation detected", $COLOR_DEBUG)
							Click(600, 380)     ; Click somewhere to get rid of animation
							If _Sleep(2000) Then Return
						EndIf
						If $bLoop = 10 Then
							SetDebugLog("Something wrong happened", $COLOR_DEBUG)
							ClickAway()
							$Exitloop = True
							ExitLoop
						EndIf
						$bLoop += 1
					WEnd
					If $Exitloop Then
						If _Sleep(1500) Then Return
						If $Updated Then
							OresReport()
							If _Sleep(3000) Then Return
						EndIf
						ContinueLoop 2
					EndIf
				EndIf
				If _Sleep(500) Then Return
				If $t = UBound($aEquipmentUpgrades, 1) - 1 Then SetLog($g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0] & " unavailable", $COLOR_WARNING)
			Next
		Else
			SetLog("No Equipment image found", $COLOR_WARNING)
			If $g_bDebugImageSave Then SaveDebugImage("Blacksmith_NoEquipmentFound")
		EndIf
	Next
	ClickAway()
	SetLog("Equipment Auto Upgrade finished", $COLOR_INFO)
	If _Sleep(500) Then Return
EndFunc   ;==>Blacksmith

Func OpenBlacksmithWindow()
	If IsBlacksmithPage(False, 1) Then Return True
	Local $aEquipmentButton = findButton("Equipment", Default, 1, True)
	If IsArray($aEquipmentButton) And UBound($aEquipmentButton, 1) = 2 Then
		ClickP($aEquipmentButton)
		If _Sleep(1000) Then Return ; Wait for window to open
		If IsBlacksmithPage(False, 1) Then Return True
	Else
		SetLog("Cannot find Equipment Button!", $COLOR_ERROR)
		If $g_bDebugImageSave Then SaveDebugImage("EquipmentButton") ; Debug Only
		ClickAway()
		Return False
	EndIf
EndFunc   ;==>OpenBlacksmithWindow

Func OresReport()

	Local $ReadShiny = getOresValues(186, 600)
	Local $aTempReadReadShiny = StringSplit($ReadShiny, "#")
	If IsArray($aTempReadReadShiny) And UBound($aTempReadReadShiny) = 3 Then
		Local $g_ReadCorrect = StringRight($aTempReadReadShiny[2], 3)
		If $aTempReadReadShiny[2] = 0 Or $aTempReadReadShiny[2] = "" Or $aTempReadReadShiny[2] < 10000 Or StringInStr($g_ReadCorrect, 1) Then
			$ReadShiny = getOresValues2(186, 600)
			$aTempReadReadShiny = StringSplit($ReadShiny, "#")
		EndIf
	Else
		$ReadShiny = getOresValues2(186, 600)
		$aTempReadReadShiny = StringSplit($ReadShiny, "#")
	EndIf
	Local $ShinyValueActal = 0, $ShinyValueCap = 0
	If IsArray($aTempReadReadShiny) And UBound($aTempReadReadShiny) = 3 Then
		If $aTempReadReadShiny[0] >= 2 Then
			$ShinyValueActal = $aTempReadReadShiny[1]
			$ShinyValueCap = $aTempReadReadShiny[2]
		EndIf
	EndIf

	Local $ReadGlowy = getOresValues(375, 600)
	Local $aTempReadReadGlowy = StringSplit($ReadGlowy, "#")
	Local $GlowyValueActal = 0, $GlowyValueCap = 0
	If IsArray($aTempReadReadGlowy) And UBound($aTempReadReadGlowy) = 3 Then
		If $aTempReadReadGlowy[0] >= 2 Then
			$GlowyValueActal = $aTempReadReadGlowy[1]
			$GlowyValueCap = $aTempReadReadGlowy[2]
		EndIf
	EndIf

	Local $ReadStarry = getOresValues(567, 600)
	Local $aTempReadReadStarry = StringSplit($ReadStarry, "#")
	Local $StarryValueActal = 0, $StarryValueCap = 0
	If IsArray($aTempReadReadStarry) And UBound($aTempReadReadStarry) = 3 Then
		If $aTempReadReadStarry[0] >= 2 Then
			$StarryValueActal = $aTempReadReadStarry[1]
			$StarryValueCap = $aTempReadReadStarry[2]
		EndIf
	EndIf

	SetLog("Ores Report")
	SetLog("[Shiny]: " & $ShinyValueActal & "/" & $ShinyValueCap, $COLOR_INFO)
	SetLog("[Glowy]: " & $GlowyValueActal & "/" & $GlowyValueCap, $COLOR_DEBUG)
	SetLog("[Starry]: " & $StarryValueActal & "/" & $StarryValueCap, $COLOR_ACTION)

EndFunc   ;==>OresReport
