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
		SetLog("Town Hall Level is Below 14, Pet is not available!", $COLOR_ERROR)
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

	$g_aiCurrentLoot[$eLootDarkElixir] = getResourcesMainScreen(728, 123) ;get current DE
	If Number($g_aiCurrentLoot[$eLootDarkElixir]) <= 90000 Then
		SetLog("Current DE: " & $g_aiCurrentLoot[$eLootDarkElixir] & " < Mininum to upgrade Pet, exiting!", $COLOR_INFO)
		Return
	EndIf
	ZoomOut() ;make sure village is zoomout
	ClickAway()

	If Not $test Then
		If PetUpgradeInProgress() Then Return False ; see if we know about an upgrade in progress without checking the Pet House
	EndIf

	If $g_aiPetHousePos[0] <= 0 Or $g_aiPetHousePos[1] <= 0 Then
		SetLog("Pet House Location unknown!", $COLOR_WARNING)
		LocatePetHouse() ; Pet House location unknown, so find it.
		If $g_aiPetHousePos[0] = 0 Or $g_aiPetHousePos[1] = 0 Then
			SetLog("Problem locating Pet House, re-locate Pet House position before proceeding", $COLOR_ERROR)
			Return False
		EndIf
	Else
		PureClickP($g_aiPetHousePos)
		_Sleep(500)
		Local $BuildingName = BuildingInfo(242, 498)
		If StringInStr($BuildingName[1], "House") Then
			SetLog("Click on PetHouse, Level:" & $BuildingName[2])
		Else
			SetDebugLog("Wrong Click on PetHouse, its a " & $BuildingName[1])
			ClickAway()
			If LocatePetHouse() Then
				PureClickP($g_aiPetHousePos)
			Else
				SetLog("Cannot Find PetHouse, please locate manually")
				Return
			EndIf
		EndIf
	EndIf
	
	Local $aBtnCancel = FindButton("cancel")
	If IsArray($aBtnCancel) And UBound($aBtnCancel) > 0 Then
		SetLog("Pet House is upgrading! Cannot start any upgrade.", $COLOR_ERROR)
		$bPetHouseOnUpgrade  = True
	EndIf

	Local $PawFound = False
	For $i = 1 To 5
		_Sleep(500)
		If FindPetsButton() Then
			$PawFound = True
			ExitLoop
		EndIf
		SetLog("Waiting for Pet House Paw Button #" & $i, $COLOR_ACTION)
	Next
	If Not $PawFound Then Return

	For $i = 1 To 5
		_Sleep(500)
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
		If $aPet[$i][3] < $g_ePetLevels Then
			$AllPetMax = False
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
	For $i = 0 to UBound($aPet) - 1
		If $g_bUpgradePetsEnable[$aPet[$i][0]] And $aPet[$i][2] = "True" Then
			SetLog($aPet[$i][1] & " is at level " & $aPet[$i][3])
			If _Sleep($DELAYLABORATORY2) Then Return
			Local $iDarkElixirReq = $aPet[$i][4]
			SetLog("DE Requirement: " & $iDarkElixirReq)

			If Number($g_aiCurrentLoot[$eLootDarkElixir]) > Number($iDarkElixirReq) Then
				SetLog("Will now upgrade " & $aPet[$i][1])
				Click($aPet[$i][5], 465)

			   ; wait for ungrade window to open
				If _Sleep(1500) Then Return

			   ; use image search to find Upgrade Button
				Local $aUpgradePetButton = findButton("UpgradePet", Default, 1, True)

			   ; check button found
			   If IsArray($aUpgradePetButton) And UBound($aUpgradePetButton, 1) = 2 Then
					If $g_bDebugImageSave Then SaveDebugImage("PetHouse") ; Debug Only

					; check if this just a test
					If Not $test Then
						ClickP($aUpgradePetButton) ; click upgrade and window close

						If _Sleep($DELAYLABORATORY1) Then Return ; Wait for window to close

						; Just incase the buy Gem Window pop up!
						If isGemOpen(True) Then
							SetDebugLog("Not enough DE for to upgrade: " & $g_asPetNames[$i], $COLOR_DEBUG)
							ClickAway()
							Return False
						EndIf

						; Update gui
						;==========Hide Red  Show Green Hide Gray===
						GUICtrlSetState($g_hPicPetGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicPetRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicPetGreen, $GUI_SHOW)
						;===========================================
						If _Sleep($DELAYLABORATORY2) Then Return
						Local $sPetTimeOCR = getRemainTLaboratory(274, 256)
						Local $iPetFinishTime = ConvertOCRTime("Lab Time", $sPetTimeOCR, False)
						SetDebugLog("$sPetTimeOCR: " & $sPetTimeOCR & ", $iPetFinishTime = " & $iPetFinishTime & " m")
						If $iPetFinishTime > 0 Then
							$g_sPetUpgradeTime = _DateAdd('n', Ceiling($iPetFinishTime), _NowCalc())
							SetLog("Pet House will finish in " & $sPetTimeOCR & " (" & $g_sPetUpgradeTime & ")")
						EndIf

					Else
						ClickAway() ; close pet upgrade window
					EndIf

					SetLog("Started upgrade for: " & $aPet[$i][1])
					ClickAway() ; close pet house window
					Return True
				Else
					SetLog("Failed to find the Pets button!", $COLOR_ERROR)
					ClickAway()
					Return False
				EndIf
			   SetLog("Failed to find Upgrade button", $COLOR_ERROR)
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
	If $g_bDebugSetlog Then SetLog("_GetPixelColor(730, 200): " & _GetPixelColor(730, 185, True) & ":A2CB6C", $COLOR_DEBUG)
	If _ColorCheck(_GetPixelColor(730, 185, True), Hex(0xA2CB6C, 6), 20) Then
		SetLog("Pet House Upgrade in progress, waiting for completion", $COLOR_INFO)
		If _Sleep($DELAYLABORATORY2) Then Return
		; upgrade in process and time not recorded so update completion time!
		Local $sPetTimeOCR = getRemainTLaboratory(274, 256)
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
	; Pet upgrade is not in progress and not upgrading, so we need to start an upgrade.
	Local $iPetUnlockedxCoord[4] = [190, 345, 500, 655]
	Local $iPetLevelxCoord[4] = [134, 288, 443, 596]
	Local $iDarkElixirReq = 0
	Local $aPet[0][7]
	For $i = 0 to $ePetCount - 1
		If $g_bUpgradePetsEnable[$i] Then ; skip detection for unchecked pets
			Local $Name = $g_asPetNames[$i]
			Local $Unlocked = String(_ColorCheck(_GetPixelColor($iPetUnlockedxCoord[$i], 385, True), Hex(0xc3b6a5, 6), 20))
			Local $iPetLevel = getTroopsSpellsLevel($iPetLevelxCoord[$i], 503)
			$iDarkElixirReq = 0 ;reset value
			If Number($iPetLevel) = $g_ePetLevels Then ;skip read upgrade cost because pet is maxed
				$Unlocked = "MaxLevel"
				ContinueLoop
			Else
				$iDarkElixirReq = getOcrAndCapture("coc-pethouse", $iPetLevelxCoord[$i] + 10, 503, 80, 16, True)
			EndIf
			Local $x = $iPetUnlockedxCoord[$i], $y = $iPetUnlockedxCoord[$i] + 20
			_ArrayAdd($aPet, $i & "|" & $Name & "|" & $Unlocked & "|" & $iPetLevel & "|" & $iDarkElixirReq & "|" & $x & "|" & $y)
		Else
			SetDebugLog("Upgrade for " &  $g_asPetNames[$i] & " is disabled")
		EndIf
	Next
	Return $aPet
EndFunc