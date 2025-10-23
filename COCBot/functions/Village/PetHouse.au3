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
	Local $sWasPetUpgradeTime = $g_sPetUpgradeTime
	Local $bWasUpgradePetsEnable = $g_bUpgradePetsEnable
	$g_bRunState = True
	For $i = 0 to $ePetCount - 1
		$g_bUpgradePetsEnable[$i] = True
	Next
	$g_sPetUpgradeTime = ""
	Local $Result = PetHouse(True)
	$g_bRunState = $bWasRunState
	$g_sPetUpgradeTime = $sWasPetUpgradeTime
	$g_bUpgradePetsEnable = $bWasUpgradePetsEnable
	Return $Result
EndFunc

Func PetHouse($test = False)
	;==========Hide Red Hide Green Show Gray====
	GUICtrlSetState($g_hPicPetRed, $GUI_HIDE)
	GUICtrlSetState($g_hPicPetGreen, $GUI_HIDE)
	GUICtrlSetState($g_hPicPetGray, $GUI_SHOW)
	;===========================================
	$g_sPetUpgradeTime = ""
	GUICtrlSetData($g_hLbLPetTime, "")
	If $g_iTownHallLevel < 14 Then
		Return
	EndIf

	; Check at least one pet upgrade is enabled
	Local $bUpgradePets = False
	Local $bPetHouseOnUpgrade = False
	For $i = 0 to $ePetCount - 1
		If $g_bUpgradePetsEnable[$i] Then
			$bUpgradePets = True
		EndIf
	Next
	If Not $bUpgradePets Then Return

	ZoomOut() ;make sure village is zoomout
	ClickAway()

	$g_aiCurrentLoot[$eLootDarkElixir] = getResourcesMainScreen(690, 123) ;get current DE
	If Number($g_aiCurrentLoot[$eLootDarkElixir]) <= 90000 Then
		SetLog("Current DE: " & $g_aiCurrentLoot[$eLootDarkElixir] & " < Mininum to upgrade Pet, exiting!", $COLOR_INFO)
		If Not $test Then Return
	EndIf

	If Not $test Then
		If PetUpgradeInProgress() Then Return False ; see if we know about an upgrade in progress without checking the Pet House
	EndIf

	If $g_aiPetHousePos[0] <= 0 Or $g_aiPetHousePos[1] <= 0 Then
		SetLog("Pet House Location unknown!", $COLOR_WARNING)
		Local $bPetHouseLocated = LocatePetHouse() ; Pet House location unknown, so find it.
		If $g_aiPetHousePos[0] = 0 Or $g_aiPetHousePos[1] = 0 Then
			SetLog("Problem locating Pet House, re-locate Pet House position before proceeding", $COLOR_ERROR)
			Return False
		EndIf
	Else
		PureClickP($g_aiPetHousePos)
		If _Sleep(500) Then Return
	EndIf
	
	Local $BuildingName = BuildingInfo(242, 473)
	If StringInStr($BuildingName[1], "Pet") Then
		SetLog("Click on PetHouse, Level:" & $BuildingName[2])
		$g_iPetHouseLevel = Number($BuildingName[2])
	Else
		SetDebugLog("Wrong Click on PetHouse, its a " & $BuildingName[1])
		ClickAway()
		If Not LocatePetHouse() Then
			SetLog("Cannot Find PetHouse, please locate manually")
			Return
		EndIf
	EndIf
	
	;Setup Max Pet Levels according to PetHouse Level
	
	;Reset First
	Global $g_ePetLevels[$ePetCount] = [10, 10, 10, 10, 10, 10, 10, 10]
	If Number($BuildingName[2]) >= 5  Then
		$g_ePetLevels[$ePetLassi] = 15
	EndIf
	
	If Number($BuildingName[2]) >= 7  Then
		$g_ePetLevels[$ePetMightyYak] = 15
	EndIf
	
	If Number($BuildingName[2]) >= 9  Then
		$g_ePetLevels[$ePetElectroOwl] = 15
	EndIf

	;End
	
	Local $PawFound = False
	For $i = 1 To 5
		If _Sleep(500) Then Return
		If FindPetsButton() Then
			$PawFound = True
			ExitLoop
		EndIf
		SetLog("Waiting for Pet House Paw Button #" & $i, $COLOR_ACTION)
	Next
	If Not $PawFound Then Return

	For $i = 1 To 5
		If _Sleep(500) Then Return
		If IsPetHousePage() Then
			ExitLoop
		Else
			SetLog("Waiting for Pet House Window #" & $i, $COLOR_ACTION)
		EndIf
	Next

	If Not $test Then
		If CheckPetUpgrade() Then Return False ; cant start if something upgrading
	EndIf
	
	If $bPetHouseOnUpgrade Then
		ClickAway()
		Return False
	EndIf
	
	Local $aPet = GetPetUpgradeList()
	Local $AllPetMax = True
	SetLog("Current DE: " & $g_aiCurrentLoot[$eLootDarkElixir], $COLOR_INFO)
	For $i = 0 To UBound($aPet) - 1
		If $aPet[$i][3] < $g_ePetLevels[$i] Then
			$AllPetMax = False
		EndIf
		If $aPet[$i][3] = $g_ePetLevels[$i] Then 
			SetLog($aPet[$i][1] & ", MaxLevel", $COLOR_INFO)
			ContinueLoop
		EndIf
		If $g_bChkSyncSaveDE Then ; if sync enabled, add value g_iTxtSmartMinDark to cost for save de
			SetLog("SyncSaveDE Enabled, adding save value to cost", $COLOR_INFO)
			Local $aTmpCost = $aPet[$i][4]
			$aPet[$i][4] += $g_iTxtSmartMinDark
			SetLog($aPet[$i][1] & ": Required: [" & $aTmpCost & "+" & $g_iTxtSmartMinDark & " = " & $aPet[$i][4] & "]", $COLOR_INFO)
		EndIf

		If Number($g_aiCurrentLoot[$eLootDarkElixir]) >= Number($aPet[$i][4]) Then
			SetLog($aPet[$i][1] & ", DE Upgrade Cost: " & $aPet[$i][4], $COLOR_SUCCESS)
			SetLog("Unlocked: " & $aPet[$i][2] & ", Level: " & $aPet[$i][3] & ", Upgrade Enabled: " & $g_bUpgradePetsEnable[$aPet[$i][0]], $COLOR_SUCCESS)
		Else
			SetLog($aPet[$i][1] & ", DE Upgrade Cost: " & $aPet[$i][4], $COLOR_ERROR)
			SetLog("Unlocked: " & $aPet[$i][2] & ", Level: " & $aPet[$i][3] & ", Upgrade Enabled: " & $g_bUpgradePetsEnable[$aPet[$i][0]], $COLOR_ERROR)
		EndIf
	Next

	If $AllPetMax Then
		SetLog("No pets available to upgrade!", $COLOR_SUCCESS)
		ClickAway()
		Return
	EndIf

	If $g_bChkSortPetUpgrade Then
		Switch $g_iCmbSortPetUpgrade
			Case 0
				_ArraySort($aPet, 0, 0, 0, 3) ;sort by level
			Case 1
				_ArraySort($aPet, 0, 0, 0, 4) ;sort by cost
			Case Else
				SetLog("You must be drunk!", $COLOR_ERROR)
		EndSwitch
	EndIf
	
	SetDebugLog(_ArrayToString($aPet))
	Local $bSecondPage = False
	For $i = 0 to UBound($aPet) - 1
		If $g_bUpgradePetsEnable[$aPet[$i][0]] And $aPet[$i][2] = "True" Then
			SetLog($aPet[$i][1] & " is at level " & $aPet[$i][3])
			If $aPet[$i][3] = "MaxLevel" Then ContinueLoop
			If _Sleep($DELAYLABORATORY2) Then Return
			Local $iDarkElixirReq = $aPet[$i][4]
			SetLog("DE Requirement: " & $iDarkElixirReq)

			If Number($g_aiCurrentLoot[$eLootDarkElixir]) > Number($iDarkElixirReq) Then
				SetLog("Will now upgrade " & $aPet[$i][1])
				
				If Not $bSecondPage And $aPet[$i][7] = "True" Then 
					PetHouseNextPage()
					$bSecondPage = True
				EndIf
				If $bSecondPage And $aPet[$i][7] = "False" Then 
					PetHousePrevPage()
					$bSecondPage = False
				EndIf
				
				Click($aPet[$i][5], 465)

			    ;wait for ungrade window to open
				If _Sleep(1500) Then Return
				
				; check if this just a test
				If Not $test Then
					Click(625, 545) ; click upgrade and window close

					If _Sleep(1000) Then Return ; Wait for window to close
					
					; Just incase the buy Gem Window pop up!
					If isGemOpen(True) Then
						SetDebugLog("Not enough DE for to upgrade: " & $g_asPetNames[$i], $COLOR_DEBUG)
						ClickAway()
						Return False
					EndIf
					
					ClickAway() ; close upgrade window
					
					; Update gui
					;==========Hide Red  Show Green Hide Gray===
					GUICtrlSetState($g_hPicPetGray, $GUI_HIDE)
					GUICtrlSetState($g_hPicPetRed, $GUI_HIDE)
					GUICtrlSetState($g_hPicPetGreen, $GUI_SHOW)
					;===========================================
					
					If _Sleep(1000) Then Return
					SetLog("Started upgrade for: " & $aPet[$i][1], $COLOR_SUCCESS)
					Local $sPetTimeOCR = getRemainTPetHouse(274, 244)
					Local $iPetFinishTime = ConvertOCRTime("PetHouse Time", $sPetTimeOCR, False)
					SetDebugLog("$sPetTimeOCR: " & $sPetTimeOCR & ", $iPetFinishTime = " & $iPetFinishTime & " m")
					If $iPetFinishTime > 0 Then
						$g_sPetUpgradeTime = _DateAdd('n', Ceiling($iPetFinishTime), _NowCalc())
						SetLog("Pet House will finish in " & $sPetTimeOCR & " (" & $g_sPetUpgradeTime & ")", $COLOR_SUCCESS)
					EndIf
				Else
					ClickAway() ; close pet upgrade window
				EndIf
				;success close window
				ClickAway()
				Return True
			Else
				SetDebugLog("DE:" & $g_aiCurrentLoot[$eLootDarkElixir] & " - " & $iDarkElixirReq & " = " & $g_aiCurrentLoot[$eLootDarkElixir] - $iDarkElixirReq)
				SetLog("Upgrade Failed - Not enough Dark Elixir", $COLOR_ERROR)
				ClickAway()
				If $g_bChkSortPetUpgrade Then Return False
			EndIf
		EndIf
	Next

	SetLog("Pet upgrade failed, check your settings", $COLOR_ERROR)
	ClickAway() ; close pet upgrade window
	Return
EndFunc

; check the Pet House to see if a Pet is upgrading already
Func CheckPetUpgrade()
	; check for upgrade in process - look for green in finish upgrade with gems button
	If $g_bDebugSetlog Then SetLog("_GetPixelColor(750, 150): " & _GetPixelColor(750, 150, True) & ":BED79B", $COLOR_DEBUG)
	If _ColorCheck(_GetPixelColor(815, 145, True), Hex(0xA2CB6C, 6), 20) Then
		SetLog("Pet House Upgrade in progress, waiting for completion", $COLOR_INFO)
		If _Sleep($DELAYLABORATORY2) Then Return
		; upgrade in process and time not recorded so update completion time!
		Local $sPetTimeOCR = getRemainTPetHouse(240, 244)
		Local $iPetFinishTime = ConvertOCRTime("Lab Time", $sPetTimeOCR, False)
		SetDebugLog("$sPetTimeOCR: " & $sPetTimeOCR & ", $iPetFinishTime = " & $iPetFinishTime & " m")
		If $iPetFinishTime > 0 Then
			$g_sPetUpgradeTime = _DateAdd('n', Ceiling($iPetFinishTime), _NowCalc())
			If @error Then _logErrorDateAdd(@error)
			SetLog("Pet Upgrade will finish in " & $sPetTimeOCR & " (" & $g_sPetUpgradeTime & ")")
			; LabStatusGUIUpdate() ; Update GUI flag
		ElseIf $g_bDebugSetlog Then
			SetLog("PetLabUpgradeInProgress - Invalid getRemainTLaboratory OCR", $COLOR_DEBUG)
		EndIf
		;==========Hide Red  Show Green Hide Gray===
		GUICtrlSetState($g_hPicPetGray, $GUI_HIDE)
		GUICtrlSetState($g_hPicPetRed, $GUI_HIDE)
		GUICtrlSetState($g_hPicPetGreen, $GUI_SHOW)
		;===========================================
		ClickAway()
		Return True
	EndIf
	Return False ; returns False if no upgrade in progress
EndFunc

; checks our global variable to see if we know of something already upgrading
Func PetUpgradeInProgress()
	Local $TimeDiff ; time remaining on lab upgrade
	If $g_sPetUpgradeTime <> "" Then $TimeDiff = _DateDiff("n", _NowCalc(), $g_sPetUpgradeTime) ; what is difference between end time and now in minutes?
	If @error Then _logErrorDateDiff(@error)

	If Not $g_bRunState Then Return
	If $TimeDiff <= 0 Then
		SetLog("Checking Pet House ...", $COLOR_INFO)
	Else
		SetLog("Pet Upgrade in progress, waiting for completion", $COLOR_INFO)
		Return True
	EndIf
	Return False ; we currently do not know of any upgrades in progress
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
	Local $iPetUnlockedxCoord[8] = [125, 315, 495, 677, 180, 365, 545, 735]
	Local $iPetLevelxCoord[8] = [51, 234, 416, 600, 108, 290, 472, 655]
	
	Local $iDarkElixirReq = 0, $iYPetLevel = 545 
	Local $aPet[0][8]
	Local $bSecondPage = False
	
	For $i = $ePetLassi to $ePetPhoenix
		If $i > $ePetUnicorn And Not $bSecondPage And $g_iPetHouseLevel > 4 Then 
			PetHouseNextPage()
			$bSecondPage = True
		EndIf
		If $g_iPetHouseLevel < 5 And $i = $ePetFrosty Then ExitLoop
		Local $Name = $g_asPetNames[$i]
		Local $Unlocked = String(_ColorCheck(_GetPixelColor($iPetUnlockedxCoord[$i], 400, True), Hex(0xc3b6a5, 6), 20))
		Local $iPetLevel = getOcrAndCapture("coc-petslevel", $iPetLevelxCoord[$i], $iYPetLevel, 25, 18, True)
		$iDarkElixirReq = 0 ;reset value
		$iDarkElixirReq = getOcrAndCapture("coc-pethouse", $iPetLevelxCoord[$i] + 30, $iYPetLevel, 100, 18, True)
		If Number($iPetLevel) = $g_ePetLevels[$i] Or StringInStr($iDarkElixirReq, "M") Or StringInStr($iDarkElixirReq, "l") Then 
			$Unlocked = "MaxLevel"
			$iDarkElixirReq = 0
		EndIf
		Local $x = $iPetUnlockedxCoord[$i], $y = $iPetUnlockedxCoord[$i] + 20
		_ArrayAdd($aPet, $i & "|" & $Name & "|" & $Unlocked & "|" & $iPetLevel & "|" & $iDarkElixirReq & "|" & $x & "|" & $y & "|" & $bSecondPage)
	Next
	If $g_iPetHouseLevel > 4 And $bSecondPage Then PetHousePrevPage()
	Return $aPet
EndFunc

Func PetHouseNextPage()
	ClickDrag(720, 500, 180, 500, 500)
	If _Sleep(1000) Then Return
EndFunc

Func PetHousePrevPage()
	ClickDrag(200, 500, 740, 500, 500)
	If _Sleep(1000) Then Return
EndFunc
