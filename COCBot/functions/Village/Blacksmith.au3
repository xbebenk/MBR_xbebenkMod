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
	Local $aUpgrade = GetEquipmentUpgradeList()
	If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
		Click($aUpgrade[0][1], $aUpgrade[0][2], 1, 0, "Click Upgrade" & $aUpgrade[0][3])
		If _Sleep(1000) Then Return
		If IsUpgradeWindowOpen() Then 
			Click(700, 540, 1, 0, "Click Upgrade")
			SetLog("Upgrading : " & $aUpgrade[0][3], $COLOR_SUCCESS)
			If _Sleep(2000) Then Return
			Click(795, 460, 1, 0, "Click Upgrade")
			If _Sleep(2000) Then Return
			Click(810, 105, 1, 0, "Click Close Upgrade Window")
		EndIf
		If _Sleep(1000) Then Return
		OresReport()
	Else
		SetLog("No available Equipment to Upgrade", $COLOR_DEBUG2)
	EndIf
	
	CloseBuilderMenu()
EndFunc   ;==>Blacksmith

Func GetEquipmentUpgradeList()
	Local $aTmpCoord, $lenght =  180, $sUpgradeName, $aUpgrade[0][4]
	Local $bNotEnoughOres = False
	Local $iYStart = 50, $iYEnd = 535
	
	Local $bEquippedFound = False, $bUnEquippedFound = False, $aEquip, $iEquipped = $iYStart, $iUnEquipped = $iYEnd
	If $g_bChkSortUpgradeEquipment And $g_iCmbSortUpgradeEquipment = 1 Then 
		SetLog("Checking only Equipped Gear", $COLOR_INFO)
		$aEquip = QuickMIS("CNX", $g_sImgEquipmentEquipped, 630, 48, 730, 400)
		If IsArray($aEquip) And UBound($aEquip) > 0 Then
			_ArraySort($aEquip, 0, 0, 0, 2)
			For $i = 0 To UBound($aEquip) - 1
				If $aEquip[$i][0] = "Equipped" Then 
					$iEquipped = $aEquip[$i][2]
					$bEquippedFound = True
				EndIf
				If $aEquip[$i][0] = "UnEquipped" Then 
					$iUnEquipped = $aEquip[$i][2]
					$bUnEquippedFound = True
				EndIf
			Next
			SetDebugLog("EquippedFound:" & String($bEquippedFound) & "|Equipped:" & $iEquipped & " | UnEquippedFound:" & String($bUnEquippedFound) & "|UnEquipped: " & $iUnEquipped)
		EndIf
	EndIf
	
	$aTmpCoord = QuickMIS("CNX", $g_sImgUpgradeListCorner, 845, $iEquipped, 860, $iUnEquipped)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			$sUpgradeName = getBuildingName(597, $aTmpCoord[$i][2] + 6, $lenght) ;get upgrade name and amount
			$bNotEnoughOres = _PixelSearch(823, $aTmpCoord[$i][2] + 9, 823, $aTmpCoord[$i][2] + 35, Hex(0xFF7B72, 6), 20, True, "EnoughOres")
			If $bNotEnoughOres Then
				SetDebugLog($sUpgradeName & ": Not Enough Ores")
				ContinueLoop
			EndIf
			Local $tmparray[1][4] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1] - 50), Number($aTmpCoord[$i][2] + 10), String($sUpgradeName)]]
			_ArrayAdd($aUpgrade, $tmparray)
			If @error Then SetLog("GetEquipmentUpgradeList ComposeArray Err : " & @error, $COLOR_ERROR)
		Next

		For $j = 0 To UBound($aUpgrade) - 1
			SetLog("[" & $j & "] Equipment: " & $aUpgrade[$j][3], $COLOR_DEBUG)
		Next
		_ArraySort($aUpgrade, 0, 0, 0, 2)
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

	If WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) Then ;check red x upper right corner
		Click(725, 630, 1, 0, "Click BlackSmith Menu")
	EndIf
	
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
