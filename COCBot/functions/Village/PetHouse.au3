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

Func TestPetHouse()
	Local $bWasRunState = $g_bRunState
	Local $bWasUpgradePetsEnable = $g_bUpgradePetsEnable
	$g_bRunState = True
	
	$g_bUpgradePetsEnable = True
	
	Local $Result = PetHouse(True)
	$g_bRunState = $bWasRunState
	$g_bUpgradePetsEnable = $bWasUpgradePetsEnable
	Return $Result
EndFunc

Func PetHouse($test = False)
	
	If $g_iTownHallLevel < 14 Then Return
	VillageReport()
	
	If Number($g_aiCurrentLoot[$eLootDarkElixir]) <= 30000 Then
		SetLog("Current DE: " & $g_aiCurrentLoot[$eLootDarkElixir] & " < Mininum to upgrade Pet, exiting!", $COLOR_INFO)
		If Not $test Then Return
	EndIf

	;If $g_aiPetHousePos[0] <= 0 Or $g_aiPetHousePos[1] <= 0 Then
	;	SetLog("Pet House Location unknown!", $COLOR_WARNING)
	;	Local $bPetHouseLocated = LocatePetHouse() ; Pet House location unknown, so find it.
	;	If $g_aiPetHousePos[0] = 0 Or $g_aiPetHousePos[1] = 0 Then
	;		SetLog("Problem locating Pet House, re-locate Pet House position before proceeding", $COLOR_ERROR)
	;		Return False
	;	EndIf
	;Else
	;	ClickP($g_aiPetHousePos)
	;	If _Sleep(500) Then Return
	;EndIf
	
	;Local $BuildingName = BuildingInfo(242, 479)
	;If StringInStr($BuildingName[1], "Pet") Then
	;	SetLog("Click on PetHouse, Level:" & $BuildingName[2])
	;	$g_iPetHouseLevel = Number($BuildingName[2])
	;Else
	;	SetDebugLog("Wrong Click on PetHouse, its a " & $BuildingName[1])
	;	ClickAway()
	;	If Not LocatePetHouse() Then
	;		SetLog("Cannot Find PetHouse, please locate manually")
	;		Return
	;	EndIf
	;EndIf
	
	;Setup Max Pet Levels according to PetHouse Level
	
	;Reset First
	;Global $g_ePetLevels[$ePetCount] = [10, 10, 10, 10, 10, 10, 10, 10]
	;If Number($BuildingName[2]) >= 5  Then
	;	$g_ePetLevels[$ePetLassi] = 15
	;EndIf
	;
	;If Number($BuildingName[2]) >= 7  Then
	;	$g_ePetLevels[$ePetMightyYak] = 15
	;EndIf
	;
	;If Number($BuildingName[2]) >= 9  Then
	;	$g_ePetLevels[$ePetElectroOwl] = 15
	;EndIf

	;End
	
	;Local $PawFound = False
	;For $i = 1 To 5
	;	If _Sleep(500) Then Return
	;	If FindPetsButton() Then
	;		$PawFound = True
	;		ExitLoop
	;	EndIf
	;	SetLog("Waiting for Pet House Paw Button #" & $i, $COLOR_ACTION)
	;Next
	;If Not $PawFound Then Return
	;
	;For $i = 1 To 5
	;	If _Sleep(500) Then Return
	;	If IsPetHousePage() Then
	;		ExitLoop
	;	Else
	;		SetLog("Waiting for Pet House Window #" & $i, $COLOR_ACTION)
	;	EndIf
	;Next

	If Not OpenPetUpgrade() Then Return
	
	Local $sBuilderInfo = getPetBuilderOnMenu()
	If StringInStr($sBuilderInfo, "#") > 0 Then ; check for valid OCR read
		Local $aGetBuilders = StringSplit($sBuilderInfo, "#", $STR_NOCOUNT) ; Split into free and total builder strings
		If Number($aGetBuilders[0]) < 1 Then
			SetLog("PetHouse already on Upgrade progress", $COLOR_DEBUG1)
			Return False
		EndIf
	EndIf
	
	Local $aPet = GetPetUpgradeList()
	
	If IsArray($aPet) And UBound($aPet) > 0 Then
		Click($aPet[0][1], $aPet[0][2], 1, 0, "Click " & $aPet[0][3])
		If _Sleep(1000) Then Return
		If Not IsUpgradeWindowOpen() Then
			SetLog("Unable to Verify Upgrade Window", $COLOR_DEBUG2)
			If WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) Then
				Click(835, 35, 1, 0, "Click Close Builder Menu")
			EndIf
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
	
	If WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) Then
		Click(835, 35, 1, 0, "Click Close Builder Menu")
	EndIf
	
	Return
EndFunc

Func OpenPetUpgrade()
	If Not $g_bRunState Then Return
	Local $bRet = False
	
	; open the builders menu
	If _ColorCheck(_GetPixelColor(753, 594, True), Hex(0xFCC610, 6), 10, Default, "Orange Build Button") Then
		Click(800, 600, 1, 0, "Click Build Button")
	EndIf
	
	WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) ;check red x upper right corner
	Click(820, 635, 1, 0, "Click Pet Icon")
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
	Local $aTmpCoord, $lenght, $aUpgradeName, $tmpcost, $aUpgrade[0][6]
	
	$aTmpCoord = QuickMIS("CNX", $g_sImgResIcon, 800, 100, 850, 570)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			$lenght = Number($aTmpCoord[$i][1]) - 597
			$aUpgradeName = getBuildingName(597, $aTmpCoord[$i][2] - 22, $lenght - 60) ;get upgrade name and amount
			$tmpcost = getBuilderMenuCost($aTmpCoord[$i][1] - 90, $aTmpCoord[$i][2] - 2)
			SetDebugLog("tmpcost: " & $tmpcost)
			If number($tmpcost) > number($g_aiCurrentLoot[$eLootDarkElixir]) Then 
				SetDebugLog($aUpgradeName[0] & ": cost " & $tmpcost & " > DE:" & $g_aiCurrentLoot[$eLootDarkElixir])
				ContinueLoop
			EndIf
			If Number($tmpcost) = 0 Then ContinueLoop
			
			Local $tmparray[1][6] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1]), Number($aTmpCoord[$i][2]), String($aUpgradeName[0]), Number($aUpgradeName[1]), Number($tmpcost)]]
			_ArrayAdd($aUpgrade, $tmparray)
			If @error Then SetLog("FindUpgrade ComposeArray Err : " & @error, $COLOR_ERROR)
		Next

		For $j = 0 To UBound($aUpgrade) - 1
			SetLog("[" & $j & "] Upgrade: " & $aUpgrade[$j][3] & ", Cost=" & $aUpgrade[$j][5], $COLOR_DEBUG)
		Next
		
		If $g_bChkSortPetUpgrade Then
			Switch $g_iCmbSortPetUpgrade
				Case 0
					_ArraySort($aUpgrade, 1, 0, 0, 5) ;sort by higher cost
				Case 1
					_ArraySort($aUpgrade, 0, 0, 0, 5) ;sort by lower cost
				Case 2
					_ArraySort($aUpgrade, 0, 0, 0, 2) ;sort by assigned
			EndSwitch
		EndIf
		
		Return $aUpgrade
	EndIf
EndFunc

Func PetHouseNextPage()
	ClickDrag(720, 500, 180, 500, 500)
	If _Sleep(1000) Then Return
EndFunc

Func PetHousePrevPage()
	ClickDrag(200, 500, 740, 500, 500)
	If _Sleep(1000) Then Return
EndFunc
