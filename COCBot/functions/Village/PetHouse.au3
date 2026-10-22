; #FUNCTION# ====================================================================================================================
; Name ..........: PetHouse
; Description ...: Upgrade Pets
; Author ........: GrumpyHog (2021-04)
; Modified ......:
; Remarks .......: This file is part of MyBot Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: Returns True or False
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......:
; ===============================================================================================================================

Func PetHouse($test = False)
	
	If $g_iTownHallLevel < 14 Then Return
	VillageReport()
	
	If Number($g_aiCurrentLoot[$eLootDarkElixir]) <= 30000 Then
		SetLog("Current DE: " & $g_aiCurrentLoot[$eLootDarkElixir] & " < Mininum to upgrade Pet, exiting!", $COLOR_INFO)
		If Not $test Then Return
	EndIf

	If Not OpenPetUpgrade() Then Return
	
	Local $sBuilderInfo = getPetBuilderOnMenu()
	If StringInStr($sBuilderInfo, "#") > 0 Then ; check for valid OCR read
		Local $aGetBuilders = StringSplit($sBuilderInfo, "#", $STR_NOCOUNT) ; Split into free and total builder strings
		If Number($aGetBuilders[0]) < 1 Then
			SetLog("PetHouse already on Upgrade progress", $COLOR_DEBUG1)
			CloseBuilderMenu()
			Return False
		EndIf
	EndIf
	
	Local $aPet = GetPetUpgradeList()
	
	If IsArray($aPet) And UBound($aPet) > 0 Then
		Click($aPet[0][1], $aPet[0][2], 1, 0, "Click " & $aPet[0][3])
		If _Sleep(1000) Then Return
		If Not IsUpgradeWindowOpen() Then
			SetLog("Unable to Verify Upgrade Window", $COLOR_DEBUG2)
			CloseBuilderMenu()
			Return
		Else
			Local $iPetUpgradeTime = getHeroUpgradeTime(730, 546) ; get duration
			Click(625, 545) ;click upgrade button
			SetLog(" - Cost : " & _NumberFormat($aPet[0][5]) & " " & $aPet[0][0], $COLOR_SUCCESS)
			SetLog(" - Duration : " & $iPetUpgradeTime, $COLOR_SUCCESS)
			AutoUpgradeLog(False, $aPet[0][3], "??", $aPet[0][5], $aPet[0][0])
			If IsUpgradeWindowOpen() Then ClickAway("Left")
			If _Sleep(1000) Then Return
		EndIf
	Else
		SetLog("No pets available to upgrade!", $COLOR_SUCCESS)
	EndIf
	
	CloseBuilderMenu()
	Return
EndFunc

Func OpenPetUpgrade()
	If Not $g_bRunState Then Return
	Local $bRet = False
	
	; open the builders menu
	If _ColorCheck(_GetPixelColor(753, 594, True), Hex(0xFCC610, 6), 10, Default, "Orange Build Button") Then
		Click(800, 600, 1, 0, "Click Build Button")
	EndIf
	
	If WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) Then ;check red x upper right corner
		Click(820, 635, 1, 0, "Click Pet Icon")
	EndIf
	
	If _Sleep(1000) Then Return
	If QuickMIS("BC1", $g_sImgPetHouse, 690, 15, 725, 30) Then $bRet = True
	If Not $bRet Then SetLog("Fail to verify Pet Upgrade Menu", $COLOR_DEBUG2)
	Return $bRet
EndFunc

Func FindPetsButton()
	Local $aPetsButton = findButton("Pets", Default, 1, True)
	If IsArray($aPetsButton) And UBound($aPetsButton, 1) = 2 Then
		If $g_bDebugImageSave Then SaveDebugImage("PetHouse") ; Debug Only
		ClickP($aPetsButton)
		If _Sleep($DELAYLABORATORY1) Then Return ; Wait for window to open
		Return True
	Else
		SetLog("Cannot find the Pets Button!", $COLOR_ERROR)
		Return False
	EndIf
EndFunc

Func GetPetUpgradeList()
	Local $aTmpCoord, $x = 560, $lenght = 180, $sUpgradeName, $tmpcost, $aUpgrade[0][6], $bNotEnoughOres = True
	
	$aTmpCoord = QuickMIS("CNX", $g_sImgUpgradeListCorner, 845, 50, 860, 535)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			$sUpgradeName = getBuildingName($x, $aTmpCoord[$i][2] + 6, $lenght) ;get upgrade name and amount
			$bNotEnoughOres = _PixelSearch(823, $aTmpCoord[$i][2] + 9, 823, $aTmpCoord[$i][2] + 35, Hex(0xFF7B72, 6), 20, True, "EnoughOres")
			If $bNotEnoughOres Then
				SetDebugLog($sUpgradeName & ": Not Enough Ores")
				ContinueLoop
			EndIf
			Local $tmparray[1][4] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1] - 50), Number($aTmpCoord[$i][2] + 10), String($sUpgradeName)]]
			_ArrayAdd($aUpgrade, $tmparray)
			If @error Then SetLog("GetPetUpgradeList ComposeArray Err : " & @error, $COLOR_ERROR)
		Next

		For $j = 0 To UBound($aUpgrade) - 1
			SetLog("[" & $j & "] Equipment: " & $aUpgrade[$j][3], $COLOR_DEBUG)
		Next
	EndIf
	
	
	Switch $g_iCmbSortPetUpgrade
		Case 0, 1
			$aTmpCoord = QuickMIS("CNX", $g_sImgUpgradeListCorner, 845, 50, 860, 535)
			If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
				For $i = 0 To UBound($aTmpCoord) - 1
					$sUpgradeName = getBuildingName($x, $aTmpCoord[$i][2] + 6, $lenght) ;get upgrade name and amount
					$bNotEnoughOres = _PixelSearch(823, $aTmpCoord[$i][2] + 9, 823, $aTmpCoord[$i][2] + 35, Hex(0xFF7B72, 6), 20, True, "EnoughOres")
					If $bNotEnoughOres Then
						SetDebugLog($sUpgradeName & ": Not Enough Ores")
						ContinueLoop
					EndIf
					Local $tmparray[1][4] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1] - 50), Number($aTmpCoord[$i][2] + 10), String($sUpgradeName)]]
					_ArrayAdd($aUpgrade, $tmparray)
					If @error Then SetLog("GetPetUpgradeList ComposeArray Err : " & @error, $COLOR_ERROR)
				Next

				For $j = 0 To UBound($aUpgrade) - 1
					SetLog("[" & $j & "] Equipment: " & $aUpgrade[$j][3], $COLOR_DEBUG)
				Next
			EndIf
		Case 2
			$aTmpCoord = QuickMIS("CNX", $g_sImgEquipmentEquipped, 595, 105, 650, 505)
			If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
				For $i = 0 To UBound($aTmpCoord) - 1
					$sUpgradeName = getBuildingName($x, $aTmpCoord[$i][2] - 30, $lenght) ;get upgrade name and amount
					$bNotEnoughOres = _PixelSearch(823, $aTmpCoord[$i][2] - 27, 823, $aTmpCoord[$i][2] + 4, Hex(0xFF7B72, 6), 20, True, "EnoughOres")
					If $bNotEnoughOres Then
						SetDebugLog($sUpgradeName & ": Not Enough Ores")
						ContinueLoop
					EndIf
					Local $tmparray[1][4] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1]), Number($aTmpCoord[$i][2]), String($sUpgradeName)]]
					_ArrayAdd($aUpgrade, $tmparray)
					If @error Then SetLog("GetPetUpgradeList ComposeArray Err : " & @error, $COLOR_ERROR)
				Next

				For $j = 0 To UBound($aUpgrade) - 1
					SetLog("[" & $j & "] Equipment: " & $aUpgrade[$j][3], $COLOR_DEBUG)
				Next
			EndIf
	EndSwitch
	
	If $g_bChkSortPetUpgrade Then
		Switch $g_iCmbSortPetUpgrade
			Case 0
				_ArraySort($aUpgrade, 0, 0, 0, 5) ;sort by lower cost
				SetDebugLog("Sort by lower cost")
			Case 1
				_ArraySort($aUpgrade, 1, 0, 0, 5) ;sort by higher cost
				SetDebugLog("Sort by higher cost")
			Case 2
				_ArraySort($aUpgrade, 0, 0, 0, 5) ;sort by lower cost
				SetDebugLog("Sort by Assigned lower cost")
		EndSwitch
	Else
		_ArraySort($aUpgrade, 0, 0, 0, 2) ;sort by y coord
		SetDebugLog("Sort by y coord")
	EndIf
	
	Return $aUpgrade
EndFunc

Func PetHouseNextPage()
	ClickDrag(720, 500, 180, 500, 500)
	If _Sleep(1000) Then Return
EndFunc

Func PetHousePrevPage()
	ClickDrag(200, 500, 740, 500, 500)
	If _Sleep(1000) Then Return
EndFunc
