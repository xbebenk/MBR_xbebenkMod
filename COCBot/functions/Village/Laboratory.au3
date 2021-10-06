; #FUNCTION# ====================================================================================================================
; Name ..........: Laboratory
; Description ...:
; Syntax ........: Laboratory()
; Parameters ....:
; Return values .: None
; Author ........: summoner
; Modified ......: KnowJack (06/2015), Sardo (08/2015), Monkeyhunter(04/2016), MMHK(06/2018), Chilly-Chill (12/2019), xbenk (02/2021)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Local $iSlotWidth = 94, $iDistBetweenSlots = 12, $iYMidPoint = 530; use for logic to upgrade troops.. good for generic-ness
Local $iPicsPerPage = 12, $iPages = 4 ; use to know exactly which page the users choice is on
Local $sLabWindow = "99,122,760,616", $sLabTroopsSection = "115,363,750,577"
Local $sLabWindowDiam = GetDiamondFromRect($sLabWindow), $sLabTroopsSectionDiam = GetDiamondFromRect($sLabTroopsSection) ; easy to change search areas

Func TestLaboratory()
	Local $bWasRunState = $g_bRunState
	Local $sWasLabUpgradeTime = $g_sLabUpgradeTime
	Local $sWasLabUpgradeEnable = $g_bAutoLabUpgradeEnable
	$g_bRunState = True
	$g_bAutoLabUpgradeEnable = True
	$g_sLabUpgradeTime = ""
	Local $Result = Laboratory(True)
	$g_bRunState = $bWasRunState
	$g_sLabUpgradeTime = $sWasLabUpgradeTime
	$g_bAutoLabUpgradeEnable = $sWasLabUpgradeEnable
	Return $Result
EndFunc

Func Laboratory($debug=False)
	If Not $g_bAutoLabUpgradeEnable Then Return ; Lab upgrade not enabled.

	If $g_aiLaboratoryPos[0] = 0 Or $g_aiLaboratoryPos[1] = 0 Then
		SetLog("Laboratory Location unknown!", $COLOR_WARNING)
		LocateLab() ; Lab location unknown, so find it.
		If $g_aiLaboratoryPos[0] = 0 Or $g_aiLaboratoryPos[1] = 0 Then
			SetLog("Problem locating Laboratory, re-locate laboratory position before proceeding", $COLOR_ERROR)
			Return False
		EndIf
	EndIf

 	If ChkUpgradeInProgress() Then Return False ; see if we know about an upgrade in progress without checking the lab

	; Get updated village elixir and dark elixir values
	VillageReport(True, True)

	If Not FindResearchButton() Then Return False ; cant start becuase we cannot find the research button
	If ChkLabUpgradeInProgress() Then Return False ; Lab currently running skip going further
	
	; Lab upgrade is not in progress and not upgrading, so we need to start an upgrade.
	Local $iCurPage = 1
	Local $sCostResult
	
		If $g_iCmbLaboratory <> 0 Then
			Local $iPage = Ceiling($g_iCmbLaboratory / $iPicsPerPage) ; page # of user choice
			While($iCurPage < $iPage) ; go directly to the needed page
				LabNextPage($iCurPage, $iPages, $iYMidPoint) ; go to next page of upgrades
				$iCurPage += 1 ; Next page
				If _Sleep(2000) Then Return
			WEnd

			; Get coords of upgrade the user wants
			local $aPageUpgrades = findMultiple($g_sImgLabResearch, $sLabTroopsSectionDiam, $sLabTroopsSectionDiam, 0, 1000, 0, "objectname,objectpoints", True) ; Returns $aCurrentTroops[index] = $aArray[2] = ["TroopShortName", CordX,CordY]
			Local $aCoords, $bUpgradeFound = False
			If UBound($aPageUpgrades, 1) >= 1 Then ; if we found any troops
				For $i = 0 To UBound($aPageUpgrades, 1) - 1 ; Loop through found upgrades
					Local $aTempTroopArray = $aPageUpgrades[$i] ; Declare Array to Temp Array

					If $aTempTroopArray[0] = $g_avLabTroops[$g_iCmbLaboratory][2] Then ; if this is the file we want
						$aCoords = decodeSingleCoord($aTempTroopArray[1])
						$bUpgradeFound = True
						ExitLoop
					EndIf
					If _Sleep($DELAYLABORATORY2) Then Return
				Next
			EndIf

			If Not $bUpgradeFound Then
				SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Not available.", $COLOR_INFO)
				$g_iCmbLaboratory = 0 ;set lab upgrade to any
				Return False
			EndIf

			If QuickMIS("BC1", $g_sImgLabZero, $aCoords[0] - 40, $aCoords[1], $aCoords[0] + 40, $aCoords[1] + 80, True, False) Then
				Return LaboratoryUpgrade($g_avLabTroops[$g_iCmbLaboratory][0], $aCoords, $sCostResult, $debug) ; return whether or not we successfully upgraded
			Else
				SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Not enough Resources." & @CRLF & "We will try again later.", $COLOR_INFO)
			EndIf
			
			$sCostResult = GetLabCostResult($aCoords) ; get cost of the upgrade
	
			If $sCostResult = "" Then ; not enough resources
				SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Not enough Resources." & @CRLF & "We will try again later.", $COLOR_INFO)
				If $g_bDebugSetlog Then SetDebugLog("Coords: (" & $aCoords[0] & "," & $aCoords[1] & ")")
			ElseIf StringSplit($sCostResult, "1")[0] = StringLen($sCostResult)+1 or StringSplit($sCostResult, "1")[1] = "0" Then ; max level if all ones returned from ocr or if the first letter is a 0.
				SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Max Level. Choose another upgrade.", $COLOR_INFO)
				If $g_bDebugSetlog Then SetDebugLog("Coords: (" & $aCoords[0] & "," & $aCoords[1] & ")")
			Else
				Return LaboratoryUpgrade($g_avLabTroops[$g_iCmbLaboratory][0], $aCoords, $sCostResult, $debug) ; return whether or not we successfully upgraded
			EndIf
			If _Sleep($DELAYLABORATORY2) Then Return
			Click(243, 33)

		Else ; users choice is any upgrade
			If $g_bLabUpgradeOrderEnable Then 
				Local $iPriority = 0
				Local $iTmpTroop = 0 
				For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1 ; list of lab upgrade order
					$iTmpTroop = $g_aCmbLabUpgradeOrder[$z] + 1
					If $iTmpTroop <> 0 Then 
						$iPriority = $z + 1
						SetLog("Priority order " & $iPriority & " : " & $g_avLabTroops[$iTmpTroop][0], $COLOR_SUCCESS)
					Endif
				Next
				For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1 ;try labupgrade based on order
					$g_iCmbLaboratory = $g_aCmbLabUpgradeOrder[$z] + 1
					If $g_iCmbLaboratory <> 0 Then 
						SetLog("Try Lab Upgrade :" & $g_avLabTroops[$g_iCmbLaboratory][0], $COLOR_DEBUG)
						Local $iPage = Ceiling($g_iCmbLaboratory / $iPicsPerPage) ; page # of user choice
						While($iCurPage < $iPage) ; go directly to the needed page
							LabNextPage($iCurPage, $iPages, $iYMidPoint) ; go to next page of upgrades
							$iCurPage += 1 ; Next page
							If _Sleep(2000) Then Return
						WEnd

						; Get coords of upgrade the user wants
						local $aPageUpgrades = findMultiple($g_sImgLabResearch, $sLabTroopsSectionDiam, $sLabTroopsSectionDiam, 0, 1000, 0, "objectname,objectpoints", True) ; Returns $aCurrentTroops[index] = $aArray[2] = ["TroopShortName", CordX,CordY]
						Local $aCoords, $bUpgradeFound = False
						If UBound($aPageUpgrades, 1) >= 1 Then ; if we found any troops
							For $i = 0 To UBound($aPageUpgrades, 1) - 1 ; Loop through found upgrades
								Local $aTempTroopArray = $aPageUpgrades[$i] ; Declare Array to Temp Array

								If $aTempTroopArray[0] = $g_avLabTroops[$g_iCmbLaboratory][2] Then ; if this is the file we want
									$aCoords = decodeSingleCoord($aTempTroopArray[1])
									$bUpgradeFound = True
									ExitLoop
								EndIf
								If _Sleep($DELAYLABORATORY2) Then Return
							Next
						EndIf

						If Not $bUpgradeFound Then
							SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Not available.", $COLOR_INFO)
							LabFirstPage($iCurPage, $iYMidPoint)
							Research()
							$iCurPage = 1 ;reset current page
						EndIf
			
						If $bUpgradeFound Then
							If QuickMIS("BC1", $g_sImgLabZero, $aCoords[0] - 40, $aCoords[1], $aCoords[0] + 40, $aCoords[1] + 80, True, False) Then
								Return LaboratoryUpgrade($g_avLabTroops[$g_iCmbLaboratory][0], $aCoords, $sCostResult, $debug) ; return whether or not we successfully upgraded
							Else
								SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Not enough Resources." & @CRLF & "We will try again later.", $COLOR_INFO)
							EndIf
							
							$sCostResult = GetLabCostResult($aCoords) ; get cost of the upgrade
							
							If $sCostResult = "" Then ; not enough resources
								SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Not enough Resources." & @CRLF & "We will try again later.", $COLOR_INFO)
								If $g_bDebugSetlog Then SetDebugLog("Coords: (" & $aCoords[0] & "," & $aCoords[1] & ")")
								ExitLoop
							ElseIf StringSplit($sCostResult, "1")[0] = StringLen($sCostResult)+1 or StringSplit($sCostResult, "1")[1] = "0" Then ; max level if all ones returned from ocr or if the first letter is a 0.
								SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Max Level. Choose another upgrade.", $COLOR_INFO)
								If $g_bDebugSetlog Then SetDebugLog("Coords: (" & $aCoords[0] & "," & $aCoords[1] & ")")
								Research()
								$iCurPage = 1 ;reset current page
							Else
								Return LaboratoryUpgrade($g_avLabTroops[$g_iCmbLaboratory][0], $aCoords, $sCostResult, $debug) ; return whether or not we successfully upgraded
							EndIf
						EndIf		
					EndIf
				Next ;search next
				
			Else ; no LabUpgradeOrder
				While($iCurPage <= $iPages)
					local $aPageUpgrades = findMultiple($g_sImgLabResearch, $sLabTroopsSectionDiam, $sLabTroopsSectionDiam, 0, 1000, 0, "objectname,objectpoints", True) ; Returns $aCurrentTroops[index] = $aArray[2] = ["TroopShortName", CordX,CordY]
					If UBound($aPageUpgrades, 1) >= 1 Then ; if we found any troops
						For $i = 0 To UBound($aPageUpgrades, 1) - 1 ; Loop through found upgrades
							Local $aTempTroopArray = $aPageUpgrades[$i] ; Declare Array to Temp Array

							; find image slot that we found so that we can read the cost to see if we can upgrade it... slots read 1-12 top to bottom so barb = 1, arch = 2, giant = 3, etc...
							Local $aCoords = decodeSingleCoord($aTempTroopArray[1])
							$sCostResult = GetLabCostResult($aCoords) ; get cost of the current upgrade option

							If $sCostResult = "" Then ; not enough resources
								If $g_bDebugSetlog Then SetDebugLog("Lab Upgrade " & $aTempTroopArray[0] & " - Not enough Resources")
							ElseIf StringSplit($sCostResult, "1")[0] = StringLen($sCostResult)+1 or StringSplit($sCostResult, "1")[1] = "0" Then ; max level if all ones returned from ocr or if the first letter is a 0.
									If $g_bDebugSetlog Then SetDebugLog("Lab Upgrade " & $aTempTroopArray[0] & " - Max Level")
							Else
								Return LaboratoryUpgrade($aTempTroopArray[0], $aCoords, $sCostResult, $debug) ; return whether or not we successfully upgraded
							EndIf
							If _Sleep($DELAYLABORATORY2) Then Return
						Next
					EndIf

					LabNextPage($iCurPage, $iPages, $iYMidPoint) ; go to next page of upgrades
					$iCurPage += 1 ; Next page
					If _Sleep($DELAYLABORATORY2) Then Return
				WEnd
			EndIf
			; If We got to here without returning, then nothing available for upgrade
			SetLog("Nothing available for upgrade at the moment, try again later.")
			Click(243, 33)
		EndIf
	Return False ; No upgrade started
EndFunc

; start a given upgrade
Func LaboratoryUpgrade($name, $aCoords, $sCostResult, $debug = False)
	SetLog("Selected upgrade: " & $name & " Cost: " & $sCostResult, $COLOR_INFO)
	ClickP($aCoords) ; click troop
	If _Sleep(2000) Then Return

	;If Not(SetLabUpgradeTime($name)) Then
	;	Click(243, 33)
	;	Return False ; couldnt set time to upgrade started
	;EndIf
	;If _Sleep($DELAYLABUPGRADE1) Then Return

	LabStatusGUIUpdate()
	If $debug = True Then ; if debugging, do not actually click it
		SetLog("[debug mode] - Start Upgrade, Click (" & 660 & "," & 520 + $g_iMidOffsetY & ")", $COLOR_ACTION)
		Click(243, 33)
		Return True ; return true as if we really started an upgrade
	Else
		Click(660, 520 + $g_iMidOffsetY, 1, 0, "#0202") ; Everything is good - Click the upgrade button
		If isGemOpen(True) = False Then ; check for gem window
			; check for green button to use gems to finish upgrade, checking if upgrade actually started
			If Not (_ColorCheck(_GetPixelColor(625, 218 + $g_iMidOffsetY, True), Hex(0x6fbd1f, 6), 15) Or _ColorCheck(_GetPixelColor(660, 218 + $g_iMidOffsetY, True), Hex(0x6fbd1f, 6), 15)) Then
				SetLog("Something went wrong with " & $name & " Upgrade, try again.", $COLOR_ERROR)
				Click(243, 33)
				Return False
			EndIf

			; success
			SetLog("Upgrade " & $name & " in your laboratory started with success...", $COLOR_SUCCESS)
			PushMsg("LabSuccess")
			If _Sleep($DELAYLABUPGRADE2) Then Return
			Click(243, 33)
			Return True ; upgrade started
		Else
			SetLog("Oops, Gems required for " & $name & " Upgrade, try again.", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
EndFunc

; get the time for the selected upgrade
Func SetLabUpgradeTime($sTrooopName)
	Local $Result = getLabUpgradeTime(581, 495) ; Try to read white text showing time for upgrade
	Local $iLabFinishTime = ConvertOCRTime("Lab Time", $Result, False)
	SetLog($sTrooopName & " Upgrade OCR Time = " & $Result & ", $iLabFinishTime = " & $iLabFinishTime & " m", $COLOR_INFO)
	Local $StartTime = _NowCalc() ; what is date:time now
	If $g_bDebugSetlog Then SetDebugLog($sTrooopName & " Upgrade Started @ " & $StartTime, $COLOR_SUCCESS)
	If $iLabFinishTime > 0 Then
		$g_sLabUpgradeTime = _DateAdd('n', Ceiling($iLabFinishTime), $StartTime)
		SetLog($sTrooopName & " Upgrade Finishes @ " & $Result & " (" & $g_sLabUpgradeTime & ")", $COLOR_SUCCESS)
	Else
		SetLog("Error processing upgrade time required, try again!", $COLOR_WARNING)
		Return False
	EndIf
	Return True ; success
EndFunc

; get the cost of an upgrade based on its coords
; find image slot that we found so that we can read the cost to see if we can upgrade it... slots read 1-12 top to bottom so barb = 1, arch = 2, giant = 3, etc...
Func GetLabCostResult($aCoords)
	Local $iCurSlotOnPage, $iCurSlotsToTheRight, $sCostResult
	$iCurSlotsToTheRight = Ceiling( ( Int($aCoords[0]) - Int(StringSplit($sLabTroopsSection, ",")[1]) ) / ($iSlotWidth + $iDistBetweenSlots) )
	If Int($aCoords[1]) < $iYMidPoint Then ; first row
		$iCurSlotOnPage = 2*$iCurSlotsToTheRight - 1
		$sCostResult = getLabUpgrdResourceWht( Int(StringSplit($sLabTroopsSection, ",")[1]) + 10 + ($iCurSlotsToTheRight-1)*($iSlotWidth + $iDistBetweenSlots),  Int(StringSplit($sLabTroopsSection, ",")[2]) + 76)
	Else; second row
		$iCurSlotOnPage = 2*$iCurSlotsToTheRight
		$sCostResult = getLabUpgrdResourceWht( Int(StringSplit($sLabTroopsSection, ",")[1]) + 10 + ($iCurSlotsToTheRight-1)*($iSlotWidth + $iDistBetweenSlots),  $iYMidPoint + 76)
	EndIf
	Return $sCostResult
EndFunc

; if we are on last page, smaller clickdrag... for future dev: this is whatever is enough distance to move 6 off to the left and have the next page similarily aligned
Func LabNextPage($iCurPage, $iPages, $iYMidPoint)
	If $iCurPage >= $iPages Then Return ; nothing left to scroll
	If $iCurPage = $iPages-1 Then ; last page
		ClickDrag(720, $iYMidPoint, 480, $iYMidPoint) ;600
	Else
		ClickDrag(720, $iYMidPoint, 85, $iYMidPoint)
	EndIf
EndFunc

; if we are on last page, smaller clickdrag... for future dev: this is whatever is enough distance to move 6 off to the left and have the next page similarily aligned
Func LabFirstPage($iCurPage, $iYMidPoint)
	For $u = 1 To $iCurPage
		If $iCurPage <= 1 Then Return ; nothing left to scroll
		ClickDrag(130, $iYMidPoint, 780, $iYMidPoint, 500) ;600
		$iCurPage -= 1
	Next
EndFunc

; check the lab to see if something is upgrading in the lab already
Func ChkLabUpgradeInProgress()
	; check for upgrade in process - look for green in finish upgrade with gems button
	If _ColorCheck(_GetPixelColor(730, 200, True), Hex(0xA2CB6C, 6), 20) Then ; Look for light green in upper right corner of lab window.
		SetLog("Laboratory is Running", $COLOR_INFO)
		;==========Hide Red  Show Green Hide Gray===
		GUICtrlSetState($g_hPicLabGray, $GUI_HIDE)
		GUICtrlSetState($g_hPicLabRed, $GUI_HIDE)
		GUICtrlSetState($g_hPicLabGreen, $GUI_SHOW)
		;===========================================
		If _Sleep($DELAYLABORATORY2) Then Return
		Local $sLabTimeOCR = getRemainTLaboratory(270, 257)
		Local $iLabFinishTime = ConvertOCRTime("Lab Time", $sLabTimeOCR, False)
		SetDebugLog("$sLabTimeOCR: " & $sLabTimeOCR & ", $iLabFinishTime = " & $iLabFinishTime & " m")
		If $iLabFinishTime > 0 Then
			$g_sLabUpgradeTime = _DateAdd('n', Ceiling($iLabFinishTime), _NowCalc())
			SetLog("Research will finish in " & $sLabTimeOCR & " (" & $g_sLabUpgradeTime & ")")
		EndIf
		ClickAway()
		If ProfileSwitchAccountEnabled() Then SwitchAccountVariablesReload("Save") ; saving $asLabUpgradeTime[$g_iCurAccount] = $g_sLabUpgradeTime for instantly displaying in multi-stats
		Return True
	EndIf
	Return False
EndFunc

; checks our global variable to see if we know of something already upgrading
Func ChkUpgradeInProgress()
	Local $TimeDiff ; time remaining on lab upgrade
	If $g_sLabUpgradeTime <> "" Then $TimeDiff = _DateDiff("n", _NowCalc(), $g_sLabUpgradeTime) ; what is difference between end time and now in minutes?
	If @error Then _logErrorDateDiff(@error)
	If $g_bDebugSetlog Then SetDebugLog($g_avLabTroops[$g_iCmbLaboratory][0] & " Lab end time: " & $g_sLabUpgradeTime & ", DIFF= " & $TimeDiff, $COLOR_DEBUG)

	If Not $g_bRunState Then Return
	If $TimeDiff <= 0 Then
		SetLog("Checking Troop Upgrade in Laboratory ...", $COLOR_INFO)
	Else
		SetLog("Laboratory Upgrade in progress, waiting for completion", $COLOR_INFO)
		Return True
	EndIf
	Return False ; we currently do not know of any upgrades in progress
EndFunc

Func Research()
	If _Sleep(2000) Then Return 
EndFunc

; Find Research Button
Func FindResearchButton()
	Local $ResearchButtonFound = False
	CheckMainScreen(False)
	;Click Laboratory
	Click($g_aiLaboratoryPos[0] , $g_aiLaboratoryPos[1])
	If _Sleep(1000) Then Return ; Wait for window to open
	
	Local $aCancelButton = findButton("Cancel")
	If IsArray($aCancelButton) And UBound($aCancelButton, 1) = 2 Then
		SetLog("Laboratory is Upgrading!, Cannot start any upgrade", $COLOR_ERROR)
		ClickAway()
		Return False
	EndIf
	
	Local $aResearchButton = findButton("Research", Default, 1, True)
	If IsArray($aResearchButton) And UBound($aResearchButton, 1) = 2 Then
		If $g_bDebugImageSave Then SaveDebugImage("LabUpgrade") ; Debug Only
		ClickP($aResearchButton)
		$ResearchButtonFound =  True
		If _Sleep($DELAYLABORATORY1) Then Return ; Wait for window to open
		Return True
	Else 
		SetLog("Cannot find the Laboratory Research Button!", $COLOR_INFO)
		ClickAway()
	EndIf
	
	If Not $ResearchButtonFound Then
		SetLog("Try to Locate Laboratory!", $COLOR_INFO)
		ClickAway()
		If ImgLocateLab() Then ;try locate lab again
			SetLog("Laboratory located on coords: " & "[" & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1] &"], Saving Lab Loc for future", $COLOR_INFO)
			Click($g_aiLaboratoryPos[0] , $g_aiLaboratoryPos[1])
			If _Sleep(1000) Then Return
			ClickB("Research")
			Return True
		Else
			SetLog("Laboratory location not found, please locate manually", $COLOR_DEBUG)
			Return False
		EndIf
	EndIf
EndFunc