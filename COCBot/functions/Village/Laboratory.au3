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
Local $sLabWindow = "99,122,760,616", $sLabTroopsSection = "110,340,740,540"
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
	If ChkUpgradeInProgress() Then Return
	If $g_aiLaboratoryPos[0] = 0 Or $g_aiLaboratoryPos[1] = 0 Then
		SetLog("Laboratory Location unknown!", $COLOR_WARNING)
		LocateLab() ; Lab location unknown, so find it.
		If $g_aiLaboratoryPos[0] = 0 Or $g_aiLaboratoryPos[1] = 0 Then
			SetLog("Problem locating Laboratory, re-locate laboratory position before proceeding", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
	
 	; Get updated village elixir and dark elixir values
	VillageReport(True, True)

	If Not FindResearchButton() Then Return False ; cant start becuase we cannot find the research button
	If _Sleep(1500) Then Return
	If ChkLabUpgradeInProgress() Then Return False ; Lab currently running skip going further
	
	; Lab upgrade is not in progress and not upgrading, so we need to start an upgrade.
	Local $iCurPage = 1
	Local $sCostResult
	
		If $g_iCmbLaboratory <> 0 Then
			Local $iPage = Ceiling($g_iCmbLaboratory / $iPicsPerPage) ; page # of user choice
			While($iCurPage < $iPage) ; go directly to the needed page
				LabNextPage($iCurPage, $iPages, $iYMidPoint) ; go to next page of upgrades
				$iCurPage += 1 ; Next page
				If _Sleep(1000) Then Return
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
			
			If $bUpgradeFound Then
				Local $LabZero= decodeSingleCoord(findImage("Zero", $g_sImgLabZero & "LabZero*", GetDiamondFromRect($aCoords[0] - 40 & "," & $aCoords[1] & "," & $aCoords[0] + 40 & "," & $aCoords[1] + 80), 1, True, Default))
				If UBound($LabZero) > 1 Then
					Return LaboratoryUpgrade($g_avLabTroops[$g_iCmbLaboratory][0], $aCoords, $sCostResult, $debug) ; return whether or not we successfully upgraded
				Else
					Local $LabUpgradeRequired = decodeSingleCoord(findImage("LabUpgradeRequired", $g_sImgLabZero & "Required*", GetDiamondFromRect($aCoords[0] - 40 & "," & $aCoords[1] & "," & $aCoords[0] + 40 & "," & $aCoords[1] + 80), 1, True, Default))
					If UBound($LabUpgradeRequired) > 1 Then
						SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Max Level. Choose another upgrade.", $COLOR_INFO)
					Else
						SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Not enough Resources." & @CRLF & "We will try again later.", $COLOR_INFO)
						Return False
					EndIf
				EndIf
			EndIf
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
						SetLog("Try Lab Upgrade :" & $g_avLabTroops[$g_iCmbLaboratory][2], $COLOR_DEBUG)
						Local $iPage = Ceiling($g_iCmbLaboratory / $iPicsPerPage) ; page # of user choice
						While($iCurPage < $iPage) ; go directly to the needed page
							LabNextPage($iCurPage, $iPages, $iYMidPoint) ; go to next page of upgrades
							$iCurPage += 1 ; Next page
							If _Sleep(1000) Then Return
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
							$iCurPage = 1 ;reset current page
						EndIf
			
						If $bUpgradeFound Then
							Local $LabZero= decodeSingleCoord(findImage("Zero", $g_sImgLabZero & "LabZero*", GetDiamondFromRect($aCoords[0] - 40 & "," & $aCoords[1] & "," & $aCoords[0] + 40 & "," & $aCoords[1] + 80), 1, True, Default))
							If UBound($LabZero) > 1 Then
								Return LaboratoryUpgrade($g_avLabTroops[$g_iCmbLaboratory][0], $aCoords, $sCostResult, $debug) ; return whether or not we successfully upgraded
							Else
								Local $LabUpgradeRequired = decodeSingleCoord(findImage("LabUpgradeRequired", $g_sImgLabZero & "Required*", GetDiamondFromRect($aCoords[0] - 40 & "," & $aCoords[1] & "," & $aCoords[0] + 40 & "," & $aCoords[1] + 80), 1, True, Default))
								If UBound($LabUpgradeRequired) > 1 Then
									SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Max Level. Choose another upgrade.", $COLOR_INFO)
									LabFirstPage($iCurPage, $iYMidPoint)
									$iCurPage = 1 ;reset current page
								Else
									SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Not enough Resources." & @CRLF & "We will try again later.", $COLOR_INFO)
									ExitLoop
								EndIf
							EndIf
						EndIf		
					EndIf
				Next ;search next
				findMultiple($g_sImgLabResearch, $sLabTroopsSectionDiam, $sLabTroopsSectionDiam, 0, 1000, 0, "objectname,objectpoints", True)
			Else ; no LabUpgradeOrder
				While($iCurPage <= $iPages)
					local $aPageUpgrades = findMultiple($g_sImgLabResearch, $sLabTroopsSectionDiam, $sLabTroopsSectionDiam, 0, 1000, 0, "objectname,objectpoints", True) ; Returns $aCurrentTroops[index] = $aArray[2] = ["TroopShortName", CordX,CordY]
					If UBound($aPageUpgrades, 1) >= 1 Then ; if we found any troops
						For $i = 0 To UBound($aPageUpgrades, 1) - 1 ; Loop through found upgrades
							Local $aTempTroopArray = $aPageUpgrades[$i] ; Declare Array to Temp Array

							; find image slot that we found so that we can read the cost to see if we can upgrade it... slots read 1-12 top to bottom so barb = 1, arch = 2, giant = 3, etc...
							Local $aCoords = decodeSingleCoord($aTempTroopArray[1])
							Local $LabZero= decodeSingleCoord(findImage("Zero", $g_sImgLabZero & "LabZero*", GetDiamondFromRect($aCoords[0] - 40 & "," & $aCoords[1] & "," & $aCoords[0] + 40 & "," & $aCoords[1] + 80), 1, True, Default))
							If UBound($LabZero) > 1 Then
								Return LaboratoryUpgrade($g_avLabTroops[$g_iCmbLaboratory][0], $aCoords, $sCostResult, $debug) ; return whether or not we successfully upgraded
							Else
								Local $LabUpgradeRequired = decodeSingleCoord(findImage("LabUpgradeRequired", $g_sImgLabZero & "Required*", GetDiamondFromRect($aCoords[0] - 40 & "," & $aCoords[1] & "," & $aCoords[0] + 40 & "," & $aCoords[1] + 80), 1, True, Default))
								If UBound($LabUpgradeRequired) > 1 Then
									SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Max Level. Choose another upgrade.", $COLOR_INFO)
								Else
									SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Not enough Resources." & @CRLF & "We will try again later.", $COLOR_INFO)
									ExitLoop
								EndIf
							EndIf
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
	
	ClickP($aCoords) ; click troop
	If _Sleep(2000) Then Return
	$sCostResult = getResourcesBonus(594, 522) ; get cost
	
	SetLog("Selected upgrade: " & $name & " Cost: " & $sCostResult, $COLOR_INFO)
	
	If $debug = True Then ; if debugging, do not actually click it
		SetLog("[debug mode] - Start Upgrade, Click (" & 660 & "," & 520 & ")", $COLOR_ACTION)
		Click(243, 33)
		Return True ; return true as if we really started an upgrade
	Else
		Click(660, 520, 1, 0, "#0202") ; Everything is good - Click the upgrade button
		If isGemOpen(True) = False Then ; check for gem window
			ChkLabUpgradeInProgress()
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
		If _Sleep(3000) Then Return
	Else
		ClickDrag(720, $iYMidPoint, 85, $iYMidPoint)
		If _Sleep(3000) Then Return
	EndIf
	
EndFunc

Func LabFirstPage($iCurPage, $iYMidPoint)
	For $u = 1 To $iCurPage
		If $iCurPage <= 1 Then Return ; nothing left to scroll
		ClickDrag(130, $iYMidPoint, 780, $iYMidPoint, 500) ;600
		$iCurPage -= 1
		If _Sleep(3000) Then Return
	Next
EndFunc

; check the lab to see if something is upgrading in the lab already
Func ChkLabUpgradeInProgress()
	; check for upgrade in process - look for green in finish upgrade with gems button
	If _Sleep(500) Then Return
	If _ColorCheck(_GetPixelColor(125, 160, True), Hex(0xBDE36B, 6), 20) Or _ColorCheck(_GetPixelColor(722, 278, True), Hex(0xA2CB6C, 6), 20) Then ; Look for light green in upper right corner of lab window.
		SetLog("Laboratory is Running", $COLOR_INFO)
		;==========Hide Red  Show Green Hide Gray===
		GUICtrlSetState($g_hPicLabGray, $GUI_HIDE)
		GUICtrlSetState($g_hPicLabRed, $GUI_HIDE)
		GUICtrlSetState($g_hPicLabGreen, $GUI_SHOW)
		;===========================================
		If _Sleep($DELAYLABORATORY2) Then Return
		Local $sLabTimeOCR = getRemainTLaboratory(270, 227)
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

; Find Research Button
Func FindResearchButton()
	Local $TryLabAutoLocate = False
	Local $LabFound = False
	ClickAway()
	checkMainScreen(False)
	
	;Click Laboratory
	If Int($g_aiLaboratoryPos[0]) < 1 Or Int($g_aiLaboratoryPos[1]) < 1 Then
		$TryLabAutoLocate = True
	Else
		Click($g_aiLaboratoryPos[0], $g_aiLaboratoryPos[1])
		If _Sleep(1000) Then Return
		Local $BuildingInfo = BuildingInfo(260, 494)
		If StringInStr($BuildingInfo[1], "Lab") Then 
			$TryLabAutoLocate = False
			$LabFound = True
		Else
			$TryLabAutoLocate = True
		EndIf
	EndIf
	
	If $TryLabAutoLocate Then 
		SetLog("Try to Auto Locate Laboratory!", $COLOR_INFO)
		ClickAway()
		Local $LabResearch = decodeSingleCoord(findImage("Research", $g_sImgLaboratory & "\Research*", GetDiamondFromRect("77,70(700,510)"), 1, True))
		If IsArray($LabResearch) And UBound($LabResearch) = 2 Then
			Click($LabResearch[0], $LabResearch[1] + 30)
			If _Sleep(1000) Then Return
			Local $BuildingInfo = BuildingInfo(290, 494)
			If StringInStr($BuildingInfo[1], "Lab") Then 
				$g_aiLaboratoryPos[0] = $LabResearch[0] + 5
				$g_aiLaboratoryPos[1] = $LabResearch[1] + 30
				SetLog("Found Laboratory Lvl " & $BuildingInfo[2] & ", save as Lab Coords : " & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1], $COLOR_INFO)
				$LabFound = True
			EndIf
		EndIf
		If Not $LabFound Then 
			Local $Lab = decodeSingleCoord(findImage("Laboratory", $g_sImgLaboratory & "\Laboratory*", GetDiamondFromRect("50,60,800,600"), 1, True))
			If IsArray($Lab) And UBound($Lab) = 2 Then
				Click($Lab[0], $Lab[1])
				If _Sleep(1000) Then Return
				Local $BuildingInfo = BuildingInfo(290, 494)
				If StringInStr($BuildingInfo[1], "Lab") Then 
					$g_aiLaboratoryPos[0] = $Lab[0]
					$g_aiLaboratoryPos[1] = $Lab[1]
					SetLog("Found Laboratory Lvl " & $BuildingInfo[2] & ", save as Lab Coords : " & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1], $COLOR_INFO)
					$LabFound = True
				EndIf
			EndIf
		EndIf
		
		If $LabFound Then
			applyConfig()
			saveConfig()
		Else
			SetLog("TryLabAutoLocate Failed, please locate manually", $COLOR_DEBUG)
			Return
		EndIf
	EndIf
	
	If $LabFound Then
		Local $aBtnCancel = FindButton("cancel")
		If IsArray($aBtnCancel) And UBound($aBtnCancel) > 0 Then
			SetLog("Laboratory is Upgrading!, Cannot start any upgrade", $COLOR_ERROR)
			ClickAway()
			Return False
		Else
			ClickB("Research")
			If _Sleep(1000) Then Return
			Return True
		EndIf
	EndIf
	
EndFunc