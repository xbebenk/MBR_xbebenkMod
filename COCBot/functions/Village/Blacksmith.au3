; #FUNCTION# ====================================================================================================================
; Name ..........: Blacksmith
; Description ...: Equipment Upgrade V1
; Author ........: 
; Modified ......: 
; Remarks .......: This file is part of MyBot Copyright 2015-2024
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: Returns True or False
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......:
; ===============================================================================================================================

Func Blacksmith($bTest = False)
	If Not $g_bRunState Then Return
	If $g_iTownHallLevel < 8 Then Return

	checkMainScreen()
	SetLog("Starting Equipment Auto Upgrade", $COLOR_INFO)
	If Not OpenBlacksmithMenu() Then Return

	OresReport()
	
	SetLog("Equipment Auto Upgrade finished", $COLOR_INFO)
	
EndFunc   ;==>Blacksmith

Func FindEquipmentUpgrade($bTest = False)
	Local $aTmpCoord, $aUpgrade[0][8], $sPriority = "", $aUpgradeName, $tmpcost, $lenght = 0
	Local $aOrder[0][2], $sName = "", $iUpgrade = 0, $sNameUpgrade = "", $sPriority = "Common", $iScore = 0
	
	$aTmpCoord = QuickMIS("CNX", $g_sImgOresIcon, 830, 100, 850, 570)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		RemoveDupCNX($aTmpCoord, 2)
		For $i = 0 To UBound($aTmpCoord) - 1
			$lenght = Number($aTmpCoord[$i][1]) - 560 - 80
			$aUpgradeName = getBuildingName(560, $aTmpCoord[$i][2] - 18, $lenght, 18) ;get upgrade name and amount
			$tmpcost = getBuilderMenuCost($aTmpCoord[$i][1] - 120, $aTmpCoord[$i][2] - 2)
			If Number($tmpcost) = 0 Then ContinueLoop
			
			$sPriority = "Common"
			$iScore = 0
			If UBound($aOrder) > 0 Then
				For $z = 0 To UBound($aOrder) - 1
					If StringInStr($aUpgradeName[0], $aOrder[$z][1]) > 0 Then 
						$sPriority = "Priority"
						$iScore = $aOrder[$z][0]
						SetLog("Found Priority Upgrade, assign score: " & $iScore & " [" & $aUpgradeName[0] & "]", $COLOR_DEBUG2)
					EndIf
				Next
			EndIf
			
			Local $tmparray[1][8] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1]), Number($aTmpCoord[$i][2]), String($aUpgradeName[0]), Number($aUpgradeName[1]), Number($tmpcost), $iScore, $sPriority]]
			_ArrayAdd($aUpgrade, $tmparray)
			If @error Then SetLog("FindUpgrade ComposeArray Err : " & @error, $COLOR_ERROR)
		Next

		For $j = 0 To UBound($aUpgrade) - 1
			SetLog("[" & $j & "] Upgrade: " & $aUpgrade[$j][3] & ", Cost=" & $aUpgrade[$j][5] & ", priority=" &  $aUpgrade[$j][7], $COLOR_DEBUG)
		Next
	EndIf
	
	If $g_bLabUpgradeOrderEnable Then 
		_ArraySort($aUpgrade, 1, 0, 0, 6) ;sort by score
	Else
		_ArraySort($aUpgrade, 1, 0, 0, 5) ;sort by cost
	EndIf
	
	Return $aUpgrade
EndFunc

Func OpenBlacksmithMenu()
	If Not $g_bRunState Then Return
	Local $bRet = False

	; open the OpenBlacksmithMenu
	If _ColorCheck(_GetPixelColor(753, 594, True), Hex(0xFCC610, 6), 10, Default, "Orange Build Button") Then
		SetLog("Opening Blacksmith Menu", $COLOR_ACTION)
		Click(800, 600, 1, 0, "Click Builder Button")
	EndIf

	WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) ;check red x upper right corner
	Click(725, 630, 1, 0, "Click BlackSmith Menu")
	
	If _Sleep(1000) Then Return
	If QuickMIS("BC1", $g_sImgEquipmentMenu, 650, 13, 680, 30) Then $bRet = True

	Return $bRet
EndFunc   ;==>OpenBlacksmithMenu

Func OresReport()
	
	$g_sShiny = getResourcesMainScreen(350, 22)
	$g_sGlowy = getResourcesMainScreen(350, 59)
	$g_sStarry = getResourcesMainScreen(350, 96)

	SetLog("[Shiny]: " & $g_sShiny, $COLOR_DEBUG)
	SetLog("[Glowy]: " & $g_sGlowy, $COLOR_DEBUG)
	SetLog("[Starry]: " & $g_sStarry, $COLOR_DEBUG)
	
EndFunc   ;==>OresReport
