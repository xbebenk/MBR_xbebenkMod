; #FUNCTION# ====================================================================================================================
; Name ..........: StarLaboratory
; Description ...:
; Syntax ........: StarLab()
; Parameters ....:
; Return values .: None
; Author ........: TripleM
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $g_iXFindSLabUpgrade = 240

Func CheckIfSLabIdle($bDebug = False)
	Local $aLabInfo, $aGetLab, $bRet = True
	If $bDebug Then Return $bRet

	$aLabInfo = getBuilders(802, 545)
	If StringInStr($aLabInfo, "#") > 0 Then
		$aGetLab = StringSplit($aLabInfo, "#", $STR_NOCOUNT)
		Local $iLab = Number($aGetLab[0]), $iLabMax = Number($aGetLab[1])
		Select
			Case $iLab = 0 And $iLabMax = 1
				SetLog("CheckIfSLabIdle: Lab is Working on Upgrade", $COLOR_SUCCESS)
				$bRet = False
			Case $iLab = 0 And $iLabMax = 2
				SetLog("CheckIfSLabIdle: Lab is Working on Upgrade", $COLOR_SUCCESS)
				$bRet = False
			Case $iLab = 1 And $iLabMax = 2
				SetLog("CheckIfSLabIdle: Lab is Working on Upgrade", $COLOR_SUCCESS)
				$bRet = False
			Case $iLab = 1 And $iLabMax >= 1
				SetLog("CheckIfSLabIdle: Lab is Idle", $COLOR_DEBUG1)
				$bRet = True
		EndSelect
	EndIf
	Return $bRet
EndFunc

Func OpenSLabMenu()
	Local $bRet = False
	If Not $g_bRunState Then Return

	; open the lab menu
	If _ColorCheck(_GetPixelColor(753, 594, True), Hex(0xFCC610, 6), 10, Default, "Orange Build Button") Then
		Click(800, 600, 1, 0, "Click Build Button")
		If WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) Then
			Click(770, 630, 1, 0, "Click SLab Menu")
		EndIf
	EndIf

	If _Sleep(500) Then Return
	If QuickMIS("BC1", $g_sImgLabMenu, 600, 15, 650, 30) Then $bRet = True
	Return $bRet
EndFunc ;==>ClickLabMenu

Func SLabUpgrade($UpgradeName, $x, $y, $bTest)
	Local $bRet = False, $Result

	Click($x, $y)
	If _Sleep(1000) Then Return

	If Not $bTest Then Click(695, 585) ;click Upgrade
	If _Sleep(1000) Then Return ;wait if Gem window open

	If isGemOpen(True) Then ; check for gem window
		SetLog("Oops, Gems required for " & $UpgradeName & " Upgrade, try again.", $COLOR_DEBUG2)
		If _Sleep(1000) Then Return
		Click(133,117) ;click Cancel
		$bRet = False
	Else
		SetLog("Upgrading " & $UpgradeName & " Success!", $COLOR_SUCCESS)
		PushMsg("StarLabSuccess")
		CloseStarLabWindow()
		CloseBuilderMenu()
		$bRet = True
	EndIf

	If _Sleep(500) Then Return
	Return $bRet
EndFunc

Func CloseStarLabWindow()
	If WaitforPixel(804, 75, 805, 75, "D01921", 20, 2) Then
		Click(805, 55, 1, 0, "Click Close StarLabWindow")
		If _Sleep(500) Then Return
	EndIf
EndFunc

Func StarLabUpgrade($bTest = False)
	Local $bNoPriorityUpgrade = True

	If Not $g_bAutoStarLabUpgradeEnable Then Return ; Lab upgrade not enabled.
	SetLog("Checking for Star Laboratory Research", $COLOR_INFO)
	If Not CheckIfSLabIdle() Then Return
	If _Sleep(50) Then Return

	BuilderBaseReport(True, True)
	If Not OpenSLabMenu() Then Return

	Local $Upgrades = FindSLabUpgrade()
	If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
		SetLog("StarLab Upgrade List:", $COLOR_INFO)

		If _ArraySearch($Upgrades, "Priority", 0, 0, 0, 0, 1, 7) >= 0 Then $bNoPriorityUpgrade = False
		If _Sleep(50) Then Return
		For $i = 0 To UBound($Upgrades) - 1
			If $g_bSLabUpgradeOrderEnable And $Upgrades[$i][7] = "Common" Then
				SetLog($Upgrades[$i][3] & " skip, not enabled order setting", $COLOR_DEBUG1)
				ContinueLoop
			EndIf

			If $Upgrades[$i][5] < $g_aiCurrentLootBB[$eLootElixirBB] Then
				SetLog("Going to Upgrade: " & $Upgrades[$i][3], $COLOR_ACTION)
				Return SLabUpgrade($Upgrades[$i][3], $Upgrades[$i][1], $Upgrades[$i][2], $bTest)
			Else
				SetLog("Skip upgrade " & $Upgrades[$i][3] & ", no resources", $COLOR_DEBUG2)
			EndIf
		Next

		If $bNoPriorityUpgrade And $g_bChkUpgradeAnyIfAllOrderMaxed Then
			SetLog("There is no Priority Upgrade listed, lets try upgrade others", $COLOR_INFO)
			For $i = 0 To UBound($Upgrades) - 1
				If $Upgrades[$i][5] < $g_aiCurrentLootBB[$eLootElixirBB] Then
					SetLog("Going to Upgrade: " & $Upgrades[$i][3], $COLOR_ACTION)
					Return SLabUpgrade($Upgrades[$i][3], $Upgrades[$i][1], $Upgrades[$i][2], $bTest)
				Else
					SetLog("Skip upgrade " & $Upgrades[$i][3] & ", no resources", $COLOR_DEBUG2)
				EndIf
			Next
		EndIf
		CloseBuilderMenu()
		If _Sleep(500) Then Return
	Else
		SetLog("No Star Laboratory Upgrade", $COLOR_DEBUG2)
	EndIf
EndFunc

Func NormalizeSLabUpgradeName($sName)
	$sName = StringStripWS($sName, 3)

	Local $aNames[9] = [ _
		"Hog Glider", "Electrofire Wizard", "Night Witch", "Beta Minion", _
		"Baby Dragon", "Sneaky Archer", "Drop Ship", "Raged Barbarian", _
		"Power P E K K A"]

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

Func FindSLabUpgrade()

	Local $aTmpCoord, $aUpgrade[0][8], $sUpgradeName, $tmpcost, $lenght = 180
	Local $aOrder[0][2], $sName = "", $sPriority = "Common", $iScore = 0

	;If $g_bSLabUpgradeOrderEnable Then
	;	For $i = 0 To UBound($g_aCmbSLabUpgradeOrder) - 1
	;		If $g_aCmbSLabUpgradeOrder[$i] = -1 Then ContinueLoop
	;		$sName = $g_avStarLabTroops[$g_aCmbSLabUpgradeOrder[$i] + 1][3]
	;		SetLog("Priority Order [" & $i + 1 & "] " & $sName, $COLOR_DEBUG)
	;		Local $aTmp[1][2] = [[10 - $i, $sName]]
	;		_ArrayAdd($aOrder, $aTmp)
	;	Next
	;EndIf

	$aTmpCoord = QuickMIS("CNX", $g_sImgUpgradeListCorner, 850, 55, 860, 545)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		RemoveDupCNX($aTmpCoord, 2)
		_ArraySort($aTmpCoord, 0, 0, 0, 2)
		For $i = 0 To UBound($aTmpCoord) - 1
			$sUpgradeName = getBuildingName(560, Number($aTmpCoord[$i][2]) + 5, $lenght, 18)
			$sUpgradeName = StringStripWS($sUpgradeName, 3)
			$sUpgradeName = NormalizeSLabUpgradeName($sUpgradeName)
			$tmpcost = getBuilderMenuCost(Number($aTmpCoord[$i][1]) - 120, Number($aTmpCoord[$i][2]) + 25)
			If Number($tmpcost) = 0 Then ContinueLoop

			$sPriority = "Common"

			Local $tmparray[1][8] = [[String("Elix"), Number(700), Number($aTmpCoord[$i][2] + 25), String($sUpgradeName), Number(1), Number($tmpcost), $iScore, $sPriority]]

			_ArrayAdd($aUpgrade, $tmparray)
			If @error Then SetLog("FindUpgrade ComposeArray Err : " & @error, $COLOR_ERROR)
		Next
	EndIf

	If $g_bSLabUpgradeOrderEnable Then
		_ArraySort($aUpgrade, 1, 0, 0, 6) ;sort by score
	Else
		_ArraySort($aUpgrade, 0, 0, 0, 5) ;sort by cost
	EndIf

	For $j = 0 To UBound($aUpgrade) -1
		SetLog("[" & $j & "] " & $aUpgrade[$j][3] & ", Cost:" & $aUpgrade[$j][5] & " Score:" &  $aUpgrade[$j][6] & " Type:" & $aUpgrade[$j][7] & "]", $COLOR_DEBUG)
	Next

	Return $aUpgrade
EndFunc
