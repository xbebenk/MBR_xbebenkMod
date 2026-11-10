; #FUNCTION# ====================================================================================================================
; Name ..........: Laboratory
; Description ...:
; Syntax ........: Laboratory()
; Parameters ....:
; Return values .: None
; Author ........: xbebenk (10-2026)
; Modified ......: 
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ==============================================================================================================================

Func OpenLabMenu()
	Local $bRet = False
	If Not $g_bRunState Then Return

	; open the lab menu
	If _ColorCheck(_GetPixelColor(753, 594, True), Hex(0xFCC610, 6), 10, Default, "Orange Build Button") Then
		Click(800, 600, 1, 0, "Click Build Button")
		If WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) Then
			Click(630, 630, 1, 0, "Click Lab Menu")
		EndIf
	EndIf
	
	If _Sleep(500) Then Return
	If QuickMIS("BC1", $g_sImgLabMenu, 600, 15, 650, 30) Then $bRet = True
	If Not $bRet Then SetDebugLog("Fail to OpenLabMenu")
	Return $bRet
EndFunc ;==>ClickLabMenu

Func CheckIfLabIdle($bDebug = False)
	Local $aLabInfo, $aGetLab, $bRet = True
	If $bDebug Then Return $bRet
	
	$aLabInfo = getBuilders(802, 545)
	If StringInStr($aLabInfo, "#") > 0 Then
		$aGetLab = StringSplit($aLabInfo, "#", $STR_NOCOUNT)
		Local $iLab = Number($aGetLab[0]), $iLabMax = Number($aGetLab[1])
		Select 
			Case $iLab = 0 And $iLabMax = 1
				SetLog("CheckIfLabIdle: Lab is Working on Upgrade", $COLOR_SUCCESS)
				$bRet = False
			Case $iLab = 0 And $iLabMax = 2
				SetLog("CheckIfLabIdle: Lab is Working on Upgrade", $COLOR_SUCCESS)
				$bRet = False
			Case $iLab = 1 And $iLabMax = 2
				SetLog("CheckIfLabIdle: Lab is Working on Upgrade", $COLOR_SUCCESS)
				$bRet = False
			Case $iLab = 1 And $iLabMax >= 1
				SetLog("CheckIfLabIdle: Lab is Idle", $COLOR_DEBUG1)
				$bRet = True
		EndSelect
	EndIf
	
	If Not $bRet Then
		If $g_iTownHallLevel >= 9 Then
			If Not OpenLabMenu() Then Return $bRet
			CheckLabAssistant()
		EndIf
	EndIf
	
	
	If Not $bRet And $g_bUseLabPotion Then
		SetLog("Checking Use Research potion", $COLOR_INFO)
		If QuickMIS("BFI", $g_sImgAUpgradeHour & "Day*", 776, 65, 830, 80) Then
			SetLog("Upgrade time > 1 day, will use Resource Potion", $COLOR_INFO)
			UseLabPotion()
		Else
			SetLog("Upgrade time < 1 day, cancel using Resource potion", $COLOR_DEBUG2)
		EndIf
	EndIf
	
	If Not $bRet Then CloseBuilderMenu() ;Lab is upgrading
	Return $bRet
EndFunc

Func UseLabPotion()
	Local $bRet = False
	If _Sleep(50) Then Return
	SetLog("Try to use Laboratory potion", $COLOR_INFO)
	If QuickMIS("BC1", $g_sImgResourcePotion, 440, 620, 460, 640) Then
		Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Click Magic Item")
		If _Sleep(1000) Then Return
		If IsMagicItemWindowOpen() Then
			If QuickMIS("BC1", $g_sImgResourcePotion, 180, 225, 670, 380) Then
				Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Click research pot")
				If WaitforPixel(650, 510, 651, 510, "8BD43B", 20, 2) Then
					Click(650, 510, 1, 0, "Click Use Button")
					If WaitforPixel(430, 430, 431, 430, "2E93D0", 20, 2) Then
						Click(430, 430, 1, 0, "Click Confirm use Research pot Button")
						SetLog("Laboratory Research Boosted using potion", $COLOR_SUCCESS)
						$bRet = True
					Else
						SetLog("Fail to verify Confirm Use Button", $COLOR_DEBUG2)
					EndIf
				Else
					SetLog("Fail to verify Use Button", $COLOR_DEBUG2)
				EndIf
			Else
				SetLog("Research potion not found", $COLOR_DEBUG2)
			EndIf
		Else
			SetLog("Fail to verify Magic items Window", $COLOR_DEBUG2)
		EndIf
	Else
		SetLog("Fail to verify Magic items icon", $COLOR_DEBUG2)
	EndIf
	
	ClickAway("Left") ; close MagicItemWindow
	If _Sleep(500) Then Return
	Return $bRet
EndFunc

Func LabUpgrade($bTest = False)
	If Not $g_bAutoLabUpgradeEnable Then Return ; Lab upgrade not enabled.
	
	Local $TmpUpgradeCost = 0, $sameCost = 0, $UpgradeCost = 0, $bEnd = False
	Local $aCoord[2] = [0, 0], $bLockFound = False
	checkMainScreen()
	
	If Not CheckIfLabIdle($bTest) Then Return
	
	If _Sleep(50) Then Return
	SetLog("Checking for Laboratory Research", $COLOR_INFO)
	
	VillageReport(True, True)
	If Not OpenLabMenu() Then Return False
	
	For $i = 1 To 8
		Local $Upgrades = _FindLabUpgrade($bTest)

		If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
			SetLog("Laboratory Upgrade List:", $COLOR_INFO)
			If _Sleep(50) Then Return

			For $j = 0 To UBound($Upgrades) - 1
				If ($g_bLabUpgradeOrderEnable And $Upgrades[$j][7] = "Common") And Not $bEnd Then ;if this is end of page and upgrade any enabled, no scroll, re-read list and upgrade any
					SetLog($Upgrades[$j][3] & " skip, not enabled order setting", $COLOR_DEBUG1)
					ContinueLoop
				EndIf

				If IsLabUpgradeResourceEnough($Upgrades[$j][5], $Upgrades[$j][0]) Then
					SetLog("Going to Upgrade: " & $Upgrades[$j][3], $COLOR_ACTION)
					$aCoord[0] = $Upgrades[$j][1]
					$aCoord[1] = $Upgrades[$j][2]
					Return LaboratoryUpgrade($Upgrades[$j][3], $aCoord, $Upgrades[$j][5], $bTest)
				Else
					SetLog("Skip upgrade " & $Upgrades[$j][3] & ", no resources", $COLOR_DEBUG2)
				EndIf
			Next
			
			SetLog("No affordable upgrade in Laboratory list", $COLOR_DEBUG2)
		Else
			SetLog("No Laboratory Upgrade", $COLOR_DEBUG2)
		EndIf

		$TmpUpgradeCost = getMostBottomCost()
		SetDebugLog("TmpUpgradeCost=" & $TmpUpgradeCost & ", sameCost=" & $sameCost)

		If $UpgradeCost = $TmpUpgradeCost Then
			$sameCost += 1
		Else
			$sameCost = 0
		EndIf

		If $sameCost > 1 Then $bEnd = True
		
		$bLockFound = QuickMIS("BC1", $g_sImgLabMenu, 810, 100, 840, 580)
		If $bLockFound Then
			SetLog("Lab end lock detected", $COLOR_INFO)
			$bEnd = True
		EndIf

		$UpgradeCost = $TmpUpgradeCost

		If $bEnd Then
			If $g_bUpgradeAnyTroops Then
				SetLog("Last page reached, checking Upgrade Any", $COLOR_INFO)
				ContinueLoop
			Else
				ExitLoop
			EndIf
		EndIf

		If Not $bEnd Then ClickDragAUpgrade()
		If $bEnd Then ExitLoop
	Next
	
	CloseBuilderMenu()
	Return False
EndFunc

Func NormalizeLabUpgradeName($sName)
	$sName = StringStripWS($sName, 3)
	
	Switch $sName
        Case "L ghtning Spell"
            Return "Lightning Spell"
        Case "p e k k a", "pekka"
            Return "P.E.K.K.A"
		Case "Hea ling S pe"
			Return "Healing Spell"
		Case "Lai a Hound"
			Return "Lava Hound"
    EndSwitch
	
	Local $aNames[24] = [ _
		"Ice Golem", "Witch", "Wall Wrecker", "Ice Block Spell", _
		"Bat Spell", "Skeleton Spell", "Druid", "Apprentice Warden", _
		"Bowler", "Battle Blimp", "Stone Slammer", "Lava Hound", _
		"Minion", "Hog Rider", "Valkyrie", "Golem", _
		"Lightning Spell", "Healing Spell", "Clone Spell", "Recall Spell", _
		"Goblin", "Jump Spell", "Baby Dragon", "Battle Drill" _
	]

	For $i = 0 To UBound($aNames) - 1
		; Bandingkan tanpa membedakan kapital dan abaikan spasi OCR
		Local $sOCR = StringRegExpReplace($sName, "\s+", "")
		Local $sExpected = StringRegExpReplace($aNames[$i], "\s+", "")

		If StringLower($sOCR) = StringLower($sExpected) Then
			Return $aNames[$i]
		EndIf
	Next

	Return $sName
EndFunc

Func _FindLabUpgrade($bTest = False)
	Local $aTmpCoord, $aUpgrade[0][8]
	Local $sUpgradeName, $sResource, $tmpcost, $lenght
	Local $aOrder[0][2], $sName = "", $iUpgrade = 0
	Local $sNameUpgrade = "", $sPriority = "Common", $iScore = 0

	; Susun urutan prioritas Laboratory
	If $g_bLabUpgradeOrderEnable Then
		Local $iPriorityOrder = 0
		For $i = 0 To UBound($g_aCmbLabUpgradeOrder) - 1
			If $g_aCmbLabUpgradeOrder[$i] = -1 Then ContinueLoop
			$sName = $g_avLabTroops[$g_aCmbLabUpgradeOrder[$i] + 1][2]
			; Skip kategori khusus
			If $sName = "AnySiege" Or $sName = "AnySpell" Then ContinueLoop
			$iUpgrade = TroopIndexLookup($sName)
			If $iUpgrade < 0 Then ContinueLoop
			$sNameUpgrade = GetTroopName($iUpgrade)
			If $sNameUpgrade = "" Then ContinueLoop
			$iPriorityOrder += 1
			Local $iScore = 10 - ($iPriorityOrder - 1)
			SetLog("Priority Order [" & $iPriorityOrder & "] " & $sNameUpgrade & ", Score=" & $iScore, $COLOR_DEBUG)
			Local $iPos = UBound($aOrder)
			ReDim $aOrder[$iPos + 1][2]
			$aOrder[$iPos][0] = $iScore
			$aOrder[$iPos][1] = $sNameUpgrade
		Next
	EndIf

	; Deteksi corner setiap baris upgrade, sama seperti FindUpgrade()
	$aTmpCoord = QuickMIS("CNX", $g_sImgUpgradeListCorner, 850, 55, 860, 545)

	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		If Not $g_bRunState Then Return $aUpgrade

		RemoveDupCNX($aTmpCoord, 2)
		_ArraySort($aTmpCoord, 0, 0, 0, 2)

		For $i = 0 To UBound($aTmpCoord) - 1
			If Not $g_bRunState Then Return $aUpgrade

			; Hitung panjang area OCR dari posisi corner
			$lenght = Number($aTmpCoord[$i][1]) - 560 - 80
			If $lenght <= 0 Then ContinueLoop

			; Baca nama upgrade
			$sUpgradeName = getBuildingName(560, Number($aTmpCoord[$i][2]) + 5, $lenght, 18)
			$sUpgradeName = StringStripWS($sUpgradeName, 3)
			$sUpgradeName = NormalizeLabUpgradeName($sUpgradeName)
			If $sUpgradeName = "" Then ContinueLoop

			; Baca resource dan cost berdasarkan posisi baris
			$sResource = QuickMIS("N1", $g_sImgResourceIcon, 832, Number($aTmpCoord[$i][2]) + 24, 852, Number($aTmpCoord[$i][2]) + 42)
			$tmpcost = getBuilderMenuCost(Number($aTmpCoord[$i][1]) - 120, Number($aTmpCoord[$i][2]) + 25)
			If Number($tmpcost) = 0 Then ContinueLoop

			; Prioritas hanya berdasarkan urutan Laboratory
			$sPriority = "Common"
			$iScore = 0

			If $g_bLabUpgradeOrderEnable And UBound($aOrder) > 0 Then
				For $z = 0 To UBound($aOrder) - 1
					If $sUpgradeName = $aOrder[$z][1] Then 
						$sPriority = "Priority"
						$iScore = $aOrder[$z][0]
						SetLog("Lab Priority: " & $sUpgradeName & ", order=" & $iScore, $COLOR_DEBUG2)
						ExitLoop
					EndIf
				Next
			EndIf

			Local $tmparray[1][8] = [[String($sResource), Number(700), Number($aTmpCoord[$i][2] + 25), String($sUpgradeName), 1, Number($tmpcost), $iScore, $sPriority]]

			_ArrayAdd($aUpgrade, $tmparray)

			If @error Then
				SetLog("_FindLabUpgrade ComposeArray Err: " & @error, $COLOR_ERROR)
			EndIf

			SetLog( _
				"Lab detected: " & $sUpgradeName & _
				", Resource=" & $sResource & _
				", Cost=" & $tmpcost & _
				", Priority=" & $sPriority, _
				$COLOR_DEBUG _
			)
		Next
	EndIf

	; Sorting tetap seperti fungsi sebelumnya
	If $g_bLabUpgradeOrderEnable Then
		_ArraySort($aUpgrade, 1, 0, 0, 6)
	Else
		_ArraySort($aUpgrade, 1, 0, 0, 5)
	EndIf

	Return $aUpgrade
EndFunc

Func IsLabUpgradeResourceEnough($Cost, $CostType)
	Local $bRet = False
	
	Switch $CostType
		Case "Elix"
			If $g_aiCurrentLoot[$eLootElixir] > ($g_iTxtSmartMinElixir + $Cost) Then
				If $g_bDebugSetLog Then SetLog($g_iTxtSmartMinElixir & " + " & $Cost & " = " & $g_iTxtSmartMinElixir + $Cost)
				If $g_bDebugSetLog Then SetLog("Elixir = " & $g_aiCurrentLoot[$eLootElixir])
				$bRet = True
			EndIf
		Case "DE"
			If $g_aiCurrentLoot[$eLootDarkElixir] > ($g_iTxtSmartMinDark + $Cost) Then
				If $g_bDebugSetLog Then SetLog($g_iTxtSmartMinDark & " + " & $Cost & " = " & $g_iTxtSmartMinDark + $Cost)
				If $g_bDebugSetLog Then SetLog("DE = " & $g_aiCurrentLoot[$eLootDarkElixir])
				$bRet = True
			EndIf
	EndSwitch
	
	Return $bRet
EndFunc

Func CheckLabAssistant()
	SetLog("Checking LabAssistant", $COLOR_INFO)
	If QuickMIS("BC1", $g_sImgLabAssistant, 450, 200, 495, 245) Then ; check LabAssistant icon
		If QuickMIS("BC1", $g_sImgBuilderApprentice, 425, 220, 450, 230) Then ; check available text
			SetLog("LabAssistant Available", $COLOR_INFO)
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(500) Then Return
			If WaitForPixel(830, 130, 831, 131, Hex(0x635550, 6), 10, 2, "LabAssistant Window") Then
				If QuickMIS("BC1", $g_sImgLabAssistant, 720, 270, 810, 310) Then
					Click($g_iQuickMISX, $g_iQuickMISY)
					If _Sleep(500) Then Return
					If WaitForPixel(430, 525, 431, 526, Hex(0x8BD43A, 6), 10, 2, "LabAssistant") Then
						Click(250, 421, 1, 0, "Click Keep Assign")
						If _Sleep(500) Then Return
						Click(430, 520, 1, 0, "Click Confirm")
						If _Sleep(1000) Then Return
						ClickAway("Left")
						If _Sleep(1000) Then Return
						SetLog("SpeedUp Upgrade, activating LabAssistant", $COLOR_SUCCESS)
					EndIf
				EndIf
			EndIf
		Else
			SetLog("LabAssistant already used", $COLOR_DEBUG2)
		EndIf
	Else
		SetLog("LabAssistant not Available", $COLOR_DEBUG2)
	EndIf
EndFunc

; start a given upgrade
Func LaboratoryUpgrade($sUpgradeName, $aCoords, $sCost, $bDebug = False)
	
	SetLog("Selected upgrade: " & $sUpgradeName & " Cost: " & $sCost, $COLOR_INFO)
	ClickP($aCoords) ; click troop
	If _Sleep(1000) Then Return
	
	If $bDebug Then ; if debugging, do not actually click it
		SetLog("[debug mode] - Start Upgrade, Click Back Button", $COLOR_ACTION)
		CloseBuilderMenu()
		Return True ; Return True as if we really started an upgrade
	Else
		Click(620, 545, 1, 0, "Upgrade " & $sUpgradeName)
		If _Sleep(1000) Then Return
		If isGemOpen(True) Then
			SetLog("Oops, Gems required for " & $sUpgradeName & " Upgrade, try again.", $COLOR_DEBUG2)
			ClickAway("Right")
			CloseBuilderMenu()
			Return False
		EndIf
		SetLog("Start Upgrade for " & $sUpgradeName & " Success...", $COLOR_SUCCESS)
		PushMsg("LabSuccess")
		If IsUpgradeWindowOpen() Then Click(810, 120, 1, 0, "Close Upgrade Window")
		Return True
	EndIf
EndFunc