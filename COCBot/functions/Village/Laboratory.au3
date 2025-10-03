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
; ==============================================================================================================================

Global $aLabMenu[2] = [265, 15]
Global $g_iXFindLabUpgrade = 300

Func Laboratory($bDebug = False)
	If Not $g_bAutoLabUpgradeEnable Then Return ; Lab upgrade not enabled.
	If $bDebug Then $g_sLabUpgradeTime = ""
	If Not CheckIfLabIdle($bDebug) Then Return
	
 	; Get updated village elixir and dark elixir values
	VillageReport(True, True)
	
	If Not FindResearchButton() Then Return False ; cant start becuase we cannot find the research button
	If _Sleep(1500) Then Return
	
	; Lab upgrade is not in progress and not upgrading, so we need to start an upgrade.
	Local $iCurPage = 1, $iLabPicsPerPage = 12, $iLabMaxPages = 5, $iPage = 0
	Local $sCost, $sCostType, $bUpgradeFound = False, $sReseachName = "", $sReseachImage = "", $aUpgrade
	Local $bNoResources = False
	Local $iLab = $g_iCmbLaboratory, $aCoords[2]
	
	If $iLab <> 0 Then ;user selected upgrade
		$iPage = Ceiling($iLab / $iLabPicsPerPage) ; page # of user choice
		$sReseachName = $g_avLabTroops[$iLab][0]
		$sReseachImage = $g_avLabTroops[$iLab][2]
		SetLog("Search " & $sReseachName & ", page:" & $iPage, $COLOR_DEBUG1)
		
		$iCurPage = LabGoToPage($iCurPage, $iPage)
		
		SetLog("FindImage : " & $sReseachName, $COLOR_INFO)
		$aUpgrade = FindLabUpgrade($sReseachImage)
		If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
			For $i = 0 To UBound($aUpgrade) - 1
				If $aUpgrade[$i][5] = $sReseachImage Then
					$aCoords[0] = $aUpgrade[$i][1] - 40
					$aCoords[1] = $aUpgrade[$i][2] - 40 
					$sCost = $aUpgrade[$i][3]
					$sCostType = $aUpgrade[$i][0]
					$sReseachName = $aUpgrade[$i][4]
					If Not IsLabUpgradeResourceEnough($sCost, $sCostType) Then
						$bNoResources = True
						SetLog($sReseachName & " Cost:" & $sCost & " " & $sCostType & ", Not Enough Resource", $COLOR_INFO)
					Else
						SetLog($sReseachName & " Cost:" & $sCost & " " & $sCostType, $COLOR_INFO)
						Return LaboratoryUpgrade($sReseachName, $aCoords, $sCost, $bDebug)
					EndIf
				EndIf
			Next
		Else
			SetLog("FindImage : No Image " & $sReseachName & " Found!", $COLOR_DEBUG1)
		EndIf 
	EndIf
	
	If $iLab = 0 Then
		$iPage = 1
		If $g_bLabUpgradeOrderEnable Then
			Local $iPrio = 0, $iIndex = 0
			For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1 ; list of lab upgrade order
				$iPrio = $z + 1
				$iIndex = $g_aCmbLabUpgradeOrder[$z] + 1
				If $iIndex > 0 Then
					SetLog("Priority order [" & $iPrio & "] : " & $g_avLabTroops[$iIndex][0], $COLOR_SUCCESS)
				EndIf
			Next
			
			For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1 ;try labupgrade based on order
				$iPrio = $z + 1
				$iIndex = $g_aCmbLabUpgradeOrder[$z] + 1
				
				If $iIndex > 0 Then
					Select 
						Case $iIndex < 49 ;Any Normal
							$sReseachName = $g_avLabTroops[$iIndex][0]
							$sReseachImage = $g_avLabTroops[$iIndex][2]
							$iPage = Ceiling($iIndex / $iLabPicsPerPage) ; page # of user choice
							SetLog("Try Lab Upgrade: " & $sReseachName & ", Page:" & $iPage, $COLOR_INFO)
							$iCurPage = LabGoToPage($iCurPage, $iPage)
							
							SetLog("FindImage : " & $sReseachName, $COLOR_DEBUG1)
							$aUpgrade = FindLabUpgrade($sReseachImage)
							If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
								For $i = 0 To UBound($aUpgrade) - 1
									SetLog($aUpgrade[$i][4] & ", Cost:" & $aUpgrade[$i][3] & $aUpgrade[$i][0], $COLOR_INFO)
								Next
								For $i = 0 To UBound($aUpgrade) - 1
									If $aUpgrade[$i][5] = $sReseachImage Then
										$aCoords[0] = $aUpgrade[$i][1] - 40
										$aCoords[1] = $aUpgrade[$i][2] - 40 
										$sCost = $aUpgrade[$i][3]
										If Not IsLabUpgradeResourceEnough($sCost, $aUpgrade[$i][0]) Then
											$bNoResources = True
											SetLog($aUpgrade[$i][4] & " Cost:" & $sCost & " " & $aUpgrade[$i][0] & ", Not Enough Resource", $COLOR_INFO)
										Else
											Return LaboratoryUpgrade($sReseachName, $aCoords, $sCost, $bDebug)
										EndIf
									EndIf
								Next
							Else
								SetLog("FindImage : No Image " & $sReseachName & " Found!", $COLOR_DEBUG1)
							EndIf
											
						Case $iIndex = 49 ;Any Spell
							$sReseachName = $g_avLabTroops[$iIndex][0]
							$sReseachImage = $g_avLabTroops[$iIndex][2]
							$iPage = 2
							SetLog("Try Lab Upgrade: " & $sReseachName & ", Page:" & $iPage, $COLOR_INFO)
							$iCurPage = LabGoToPage($iCurPage, $iPage)
							
							$bUpgradeFound = False
							
							For $page = 1 To 2
								$aUpgrade = FindLabUpgrade($sReseachImage)
								If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
									For $i = 0 To UBound($aUpgrade) - 1
										SetLog($aUpgrade[$i][4] & ", Cost:" & $aUpgrade[$i][3] & $aUpgrade[$i][0], $COLOR_INFO)
									Next
									For $i = 0 To UBound($aUpgrade) - 1
										$aCoords[0] = $aUpgrade[$i][1] - 40
										$aCoords[1] = $aUpgrade[$i][2] - 40 
										$sCost = $aUpgrade[$i][3]
										$sReseachName = $aUpgrade[$i][4]
										If Not IsLabUpgradeResourceEnough($sCost, $aUpgrade[$i][0]) Then
											$bNoResources = True
											SetLog($sReseachName & " Cost:" & $sCost & " " & $aUpgrade[$i][0] & ", Not Enough Resource", $COLOR_INFO)
										Else
											;SetLog($sReseachName & " Cost:" & $sCost & " " & $aUpgrade[$i][0], $COLOR_INFO)
											Return LaboratoryUpgrade($sReseachName, $aCoords, $sCost, $bDebug)
										EndIf
									Next
								Else
									SetLog("FindImage : No Image " & $sReseachName & " Found!", $COLOR_DEBUG1)
									$iCurPage = LabGoToPage($iCurPage, 3)
								EndIf
							Next
							
							If Not $bUpgradeFound Then SetLog("FindImage : " & $sReseachName & " Not Found!", $COLOR_DEBUG1)
												
						Case $iIndex = 50 ;Any Siege
							$sReseachName = $g_avLabTroops[$iIndex][0]
							$sReseachImage = $g_avLabTroops[$iIndex][2]
							$iPage = 4
							SetLog("Try Lab Upgrade: " & $sReseachName & ", Page:" & $iPage, $COLOR_INFO)
							$iCurPage = LabGoToPage($iCurPage, $iPage)
							
							$aUpgrade = FindLabUpgrade($sReseachImage)
							If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
								For $i = 0 To UBound($aUpgrade) - 1
									SetLog($aUpgrade[$i][4] & ", Cost:" & $aUpgrade[$i][3] & $aUpgrade[$i][0], $COLOR_INFO)
								Next
								For $i = 0 To UBound($aUpgrade) - 1
									$aCoords[0] = $aUpgrade[$i][1] - 40
									$aCoords[1] = $aUpgrade[$i][2] - 40 
									$sCost = $aUpgrade[$i][3]
									$sReseachName = $aUpgrade[$i][4]
									If Not IsLabUpgradeResourceEnough($sCost, $aUpgrade[$i][0]) Then
										$bNoResources = True
										SetLog($sReseachName & " Cost:" & $sCost & " " & $aUpgrade[$i][0] & ", Not Enough Resource", $COLOR_INFO)
									Else
										;SetLog($sReseachName & " Cost:" & $sCost & " " & $aUpgrade[$i][0], $COLOR_INFO)
										Return LaboratoryUpgrade($sReseachName, $aCoords, $sCost, $bDebug)
									EndIf
								Next
							Else
								SetLog("FindImage : No Image " & $sReseachName & " Found!", $COLOR_DEBUG1)
							EndIf
							
					EndSelect
				EndIf
			Next
			
			If $bUpgradeFound Then
				Return LaboratoryUpgrade($g_avLabTroops[$iIndex][2], $aCoords, $sCost, $bDebug) ; Return whether or not we successfully upgraded
			Else
				SetLog("Lab Upgrade " & $g_avLabTroops[$iIndex][0] & " - Not available.", $COLOR_INFO)
			EndIf
			
		Else ; no LabUpgradeOrder
			While($iCurPage <= $iLabMaxPages)
				Local $Upgrades = FindLabUpgrade()
				Local $aCoord[2], $sUpgrade
				If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
					For $i = 0 To UBound($Upgrades) - 1
						$sUpgrade = $Upgrades[$i][4]
						$aCoord[0] = $Upgrades[$i][1] - 35
						$aCoord[1] = $Upgrades[$i][2] - 35
						$sCost = $Upgrades[$i][3]
						If $g_bDebugSetLog Then SetLog("LabUpgrade: " & $sUpgrade & " Cost: " & $sCost, $COLOR_INFO)	
						If Not IsLabUpgradeResourceEnough($sCost, $Upgrades[$i][0]) Then
							SetLog($sUpgrade & " Skip, Not Enough Resource", $COLOR_INFO)
						Else
							SetLog("LabUpgrade:" & $sUpgrade & " Cost:" & $sCost, $COLOR_SUCCESS)
							$bUpgradeFound = True
							ExitLoop
						EndIf
					Next
				Else
					SetLog("Not found Any Upgrade here, looking next", $COLOR_INFO)
				EndIf

				If $bUpgradeFound Then
					Return LaboratoryUpgrade($sUpgrade, $aCoord, $sCost, $bDebug) ; Return whether or not we successfully upgraded
				EndIf
				
				$iCurPage = LabGoToPage($iCurPage, $iCurPage + 1) ; go to next page of upgrades
				If _Sleep($DELAYLABORATORY2) Then Return
			WEnd
		EndIf
		; If We got to here without Returning, Then nothing available for upgrade
		SetLog("Nothing available for upgrade at the moment, try again later.")
		SetLog("LabUpgradeOrderEnable=" & String($g_bLabUpgradeOrderEnable) & ", UpgradeAnyTroops=" & String($g_bUpgradeAnyTroops) & ", tmpNoResources=" & String($bNoResources), $COLOR_DEBUG)
		If $g_bLabUpgradeOrderEnable And $g_bUpgradeAnyTroops And Not $bNoResources Then 
			Return UpgradeLabAny($bDebug)
		EndIf
		ClickAway()
	EndIf
	ClickAway()
	
EndFunc

; start a given upgrade
Func LaboratoryUpgrade($name, $aCoords, $sCost, $bDebug = False)
	Local $sUpgradeName = GetUpgradeName($name)
	If $sUpgradeName = "" Then $sUpgradeName = $name
	SetLog("Selected upgrade: " & $sUpgradeName & " Cost: " & $sCost, $COLOR_INFO)
	ClickP($aCoords) ; click troop
	If _Sleep(2000) Then Return
	
	If $bDebug Then ; if debugging, do not actually click it
		SetLog("[debug mode] - Start Upgrade, Click Back Button", $COLOR_ACTION)
		Click(805, 100)
		Return True ; Return True as if we really started an upgrade
	Else
		Click(660, 520, 1, 0, "#0202") ; Everything is good - Click the upgrade button
		If _Sleep(1000) Then Return
		If Not isGemOpen(True) Then ; check for gem window
			; success
			SetLog("Upgrade " & $sUpgradeName & " in your laboratory started with success...", $COLOR_SUCCESS)
			PushMsg("LabSuccess")
			
			If _Sleep($DELAYLABUPGRADE2) Then Return
			ClickAway()
			If _Sleep(1000) Then Return
			ClickAway()
			Return True ; upgrade started
		Else
			SetLog("Oops, Gems required for " & $sUpgradeName & " Upgrade, try again.", $COLOR_ERROR)
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
	SetDebugLog($sTrooopName & " Upgrade Started @ " & $StartTime, $COLOR_SUCCESS)
	If $iLabFinishTime > 0 Then
		$g_sLabUpgradeTime = _DateAdd('n', Ceiling($iLabFinishTime), $StartTime)
		SetLog($sTrooopName & " Upgrade Finishes @ " & $Result & " (" & $g_sLabUpgradeTime & ")", $COLOR_SUCCESS)
	Else
		SetLog("Error processing upgrade time required, try again!", $COLOR_WARNING)
		Return False
	EndIf
	Return True ; success
EndFunc

Func LabGoToPage($iFrom = 1, $iTo = 2, $iLabMaxPages = 4)
	Local $iCurPage = $iFrom
	If $iFrom = $iTo Then Return $iCurPage
	SetLog("LabGoToPage : From " & $iFrom & " To " & $iTo, $COLOR_ACTION)
	Select
		Case $iTo > $iFrom
			For $i = $iFrom To $iTo - 1
				ClickDrag(720, 500, 80, 500)
				If _Sleep(1000) Then Return
				$iCurPage += 1
				SetLog("LabGoToPage : CurPage=" & $iCurPage, $COLOR_DEBUG2)
			Next
		Case $iTo < $iFrom
			For $i = $iFrom To $iTo + 1 Step - 1
				ClickDrag(130, 500, 766, 500)
				If _Sleep(1000) Then Return
				$iCurPage -= 1
				SetLog("LabGoToPage : CurPage=" & $iCurPage, $COLOR_DEBUG2)
			Next
		Case $iTo = $iFrom
	EndSelect
	
	If $iTo = 1 Or $iTo = $iLabMaxPages Then 
		If _Sleep(3000) Then Return
	EndIf
	
	Return $iCurPage
EndFunc

; check the lab to see if something is upgrading in the lab already
Func ChkLabUpgradeInProgress($bDebug = False, $name = "")
	; check for upgrade in process - look for green in finish upgrade with gems button
	If _Sleep(1000) Then Return
	If WaitForPixel(415, 135, 416, 136, Hex(0xA1CA6B, 6), 20, 1, "ChkLabUpgradeInProgress") Then ; Look for light green in upper right corner of lab window.
		SetLog("Laboratory is Running", $COLOR_INFO)
		;==========Hide Red  Show Green Hide Gray===
		GUICtrlSetState($g_hPicLabGray, $GUI_HIDE)
		GUICtrlSetState($g_hPicLabRed, $GUI_HIDE)
		GUICtrlSetState($g_hPicLabGreen, $GUI_SHOW)
		;===========================================
		
		Local $sLabTimeOCR = getRemainTLaboratory(258, 211)
		Local $iLabFinishTime = ConvertOCRTime("Lab Time", $sLabTimeOCR, False)
		If _PixelSearch(785, 140, 786, 141, Hex(0x4A6A0D, 6), 10, 1, "Check Goblin") Then $iLabFinishTime = 60 ;force 1 hour complete time 
		SetDebugLog("$sLabTimeOCR: " & $sLabTimeOCR & ", $iLabFinishTime = " & $iLabFinishTime & " m")
		If $iLabFinishTime > 0 Then
			$g_sLabUpgradeTime = _DateAdd('n', Ceiling($iLabFinishTime), _NowCalc())
			SetLog("Research will finish in " & $sLabTimeOCR & " (" & $g_sLabUpgradeTime & ")")
		EndIf
		If $bDebug Then Return False
		If _Sleep(50) Then Return
		
		Local $bUseBooks = False
		If $name <> "" Then
			Local $iLabFinishTimeDay = ConvertOCRTime("Lab Time (Day)", $sLabTimeOCR, False, "day")
			
			If Not $bUseBooks And $g_bUseBOE And $iLabFinishTimeDay >= $g_iUseBOETime Then
				SetLog("Use Book of Everything Enabled", $COLOR_INFO)
				SetLog("Lab Upgrade time > than " & $g_iUseBOETime & " day", $COLOR_INFO)
				If QuickMIS("BFI", $g_sImgBooks & "BOE*", 650, 230, 730, 290) Then
					Click($g_iQuickMISX, $g_iQuickMISY)
					If _Sleep(1000) Then Return
					If QuickMIS("BC1", $g_sImgBooks, 400, 360, 500, 430) Then
						Click($g_iQuickMISX, $g_iQuickMISY)
						SetLog("Successfully use Book of Spell", $COLOR_SUCCESS)
						$bUseBooks = True
						If _Sleep(1000) Then Return
					EndIf
				Else
					SetLog("Book of Everything Not Found", $COLOR_ERROR)
				EndIf
			EndIf
			
			If StringInStr($name, "Spell") Then 
				If Not $bUseBooks And $g_bUseBOS And $iLabFinishTimeDay >= $g_iUseBOSTime Then
					SetLog("Use Book of Spell Enabled", $COLOR_INFO)
					SetLog("Lab Upgrade time > than " & $g_iUseBOSTime & " day", $COLOR_INFO)
					If QuickMIS("BFI", $g_sImgBooks & "BOS*", 650, 230, 730, 290) Then
						Click($g_iQuickMISX, $g_iQuickMISY)
						If _Sleep(1000) Then Return
						If QuickMIS("BC1", $g_sImgBooks, 400, 360, 500, 430) Then
							Click($g_iQuickMISX, $g_iQuickMISY)
							SetLog("Successfully use Book of Spell", $COLOR_SUCCESS)
							$bUseBooks = True
							If _Sleep(1000) Then Return
						EndIf
					Else
						SetLog("Book of Spell Not Found", $COLOR_ERROR)
					EndIf
				EndIf
			Else
				If Not $bUseBooks And $g_bUseBOF And $iLabFinishTimeDay >= $g_iUseBOFTime Then
					SetLog("Use Book of Fighting Enabled", $COLOR_INFO)
					SetLog("Lab Upgrade time > than " & $g_iUseBOFTime & " day", $COLOR_INFO)
					If QuickMIS("BFI", $g_sImgBooks & "BOF*", 650, 230, 730, 290) Then
						Click($g_iQuickMISX, $g_iQuickMISY)
						If _Sleep(1000) Then Return
						If QuickMIS("BC1", $g_sImgBooks, 400, 360, 500, 430) Then
							Click($g_iQuickMISX, $g_iQuickMISY)
							SetLog("Successfully use Book of Fighting", $COLOR_SUCCESS)
							$bUseBooks = True
							If _Sleep(1000) Then Return
						EndIf
					Else
						SetLog("Book of Fighting Not Found", $COLOR_ERROR)
					EndIf
				EndIf
			EndIf
			
		EndIf
		
		ClickAway()
		If $bUseBooks Then 
			$g_sLabUpgradeTime = "" ;reset lab upgrade time
			;==========Hide Red  Show Green Hide Gray===
			GUICtrlSetState($g_hPicLabGray, $GUI_HIDE)
			GUICtrlSetState($g_hPicLabRed, $GUI_SHOW)
			GUICtrlSetState($g_hPicLabGreen, $GUI_HIDE)
			;===========================================
		EndIf
		
		If $g_bUseLabPotion And $iLabFinishTime > 2880 And Not $bUseBooks Then ; only use potion if lab upgrade time is more than 2 day
			If _Sleep(1000) Then Return
			Local $LabPotion = FindButton("LabPotion")
			If IsArray($LabPotion) And UBound($LabPotion) = 2 Then
				SetLog("Use Laboratory Potion", $COLOR_INFO)
				Local $LabBoosted = FindButton("LabBoosted")
				If IsArray($LabBoosted) And UBound($LabBoosted) = 2 Then ; Lab already boosted skip using potion
					SetLog("Detected Laboratory already boosted", $COLOR_INFO)
					Return True
				EndIf
				Click($LabPotion[0], $LabPotion[1])
				If _Sleep(1000) Then Return
				If ClickB("BoostConfirm") Then
					SetLog("laboratory Research Boosted using potion", $COLOR_SUCCESS)
					$g_sLabUpgradeTime = _DateAdd('n', Ceiling($iLabFinishTime - 1380), _NowCalc())
					SetLog("Recalculate Research time, using potion (" & $g_sLabUpgradeTime & ")")
					ClickAway("Right")
				EndIf
				ClickAway("Right")
			Else
				SetLog("No Laboratory Potion Found", $COLOR_DEBUG)
				ClickAway("Right")
			EndIf
		EndIf
		If ProfileSwitchAccountEnabled() Then SwitchAccountVariablesReload("Save") ; saving $asLabUpgradeTime[$g_iCurAccount] = $g_sLabUpgradeTime for instantly displaying in multi-stats
		Return True
	EndIf
	Return False
EndFunc

Func CheckIfLabIdle($bDebug = False)
	Local $aLabInfo, $aGetLab, $bRet = True
	If $bDebug Then Return $bRet
	
	$aLabInfo = getBuilders(309, 23)
	If StringInStr($aLabInfo, "#") > 0 Then
		$aGetLab = StringSplit($aLabInfo, "#", $STR_NOCOUNT)
		Local $iLab = Number($aGetLab[0]), $iLabMax = Number($aGetLab[1])
		Select 
			Case $iLab = 0 And $iLabMax = 1
				SetLog("CheckIfLabIdle: Lab is Working on Upgrade", $COLOR_DEBUG)
				$bRet = False
			Case $iLab = 1 And $iLabMax = 2
				SetLog("CheckIfLabIdle: Lab is Working on Upgrade", $COLOR_DEBUG)
				$bRet = False
			Case $iLab = 1 And $iLabMax >= 1
				SetLog("CheckIfLabIdle: Lab is Idle", $COLOR_DEBUG)
				$bRet = True
		EndSelect
	EndIf
	
	If $bRet Then ;if Lab is idle, check resource is enough to upgrade
		ClickP($aLabMenu)
		If _Sleep(500) Then Return
		Local $aUpgradeName
		Local $aTmpCoord = QuickMIS("CNX", $g_sImgResourceIcon, 310, 70, 460, 280)
		If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
			_ArraySort($aTmpCoord, 0, 0, 0, 2)
			For $i = 0 To UBound($aTmpCoord) - 1
				If _PixelSearch($aTmpCoord[$i][1] + 10, $aTmpCoord[$i][2], $aTmpCoord[$i][1] + 20, $aTmpCoord[$i][2], Hex(0xFF887F, 6), 10, 1, "Check Red Resource cost") Then
					SetLog("Detected Not Enough Resource for LabUpgrade " & $aTmpCoord[$i][0] & " on : " & $aTmpCoord[$i][1] & "," & $aTmpCoord[$i][2], $COLOR_DEBUG)
					$bRet = False
				ElseIf _PixelSearch($aTmpCoord[$i][1] + 10, $aTmpCoord[$i][2], $aTmpCoord[$i][1] + 20, $aTmpCoord[$i][2], Hex(0xFFFFFF, 6), 10, 1, "Check White Resource cost") Then
					SetLog("Detected possible LabUpgrade " & $aTmpCoord[$i][0] & " on : " & $aTmpCoord[$i][1] & "," & $aTmpCoord[$i][2], $COLOR_DEBUG)
					$bRet = True
				EndIf
				If $aTmpCoord[$i][0] = "Complete" Then
					SetLog("All Upgrade Complete", $COLOR_DEBUG)
					$bRet = False
				EndIf
			Next
		EndIf
		ClickP($aLabMenu)
	EndIf
	
	If Not $bRet Then
		If $g_iTownHallLevel >= 9 Then 
			ClickP($aLabMenu)
			If _Sleep(500) Then Return
			If QuickMIS("BC1", $g_sImgLabAssistant, 170, 130, 320, 170) Then
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(500) Then Return
				If WaitForPixel(830, 130, 831, 131, Hex(0x635550, 6), 10, 2, "LabAssistant") Then
					If QuickMIS("BC1", $g_sImgLabAssistant, 720, 270, 810, 310) Then
						Click($g_iQuickMISX, $g_iQuickMISY)
						If _Sleep(500) Then Return
						If WaitForPixel(430, 525, 431, 526, Hex(0x8BD43A, 6), 10, 2, "LabAssistant") Then
							Click(250, 421, 1, 0, "Click Keep Assign")
							Click(430, 520, 1, 0, "Click Confirm")
							If _Sleep(500) Then Return
							ClickAway()
							If _Sleep(500) Then Return
							ClickAway()
						EndIf
					EndIf
				EndIf
			EndIf
			ClickP($aLabMenu)
		EndIf
	EndIf
	
	Return $bRet
EndFunc

; $sUpgrade = Any, will search all image 
; $sUpgrade = AnySpell, will search all within AnySpell image dir
; $sUpgrade = AnySiege, will search all within AnySiege image dir
; $sUpgrade = sShortName, will search only shortName image
Func FindLabUpgrade($sUpgrade = "Any")
	If $g_bDebugSetLog Then SetLog("FindLabUpgrade : " & $sUpgrade)
	Local $aResult[0][6], $sUpgradeName = "", $sDir = "", $sSearchWay = "BC1", $iSortBy = 0, $iSortDirection = 0
	Local $TmpResult = QuickMIS("CNX", $g_sImgResIcon, 70, 415, 790, 564)
	If IsArray($TmpResult) And UBound($TmpResult) > 0 Then
		For $i = 0 To UBound($TmpResult) - 1
			Local $aTmp[1][6] = [[$TmpResult[$i][0], $TmpResult[$i][1], $TmpResult[$i][2], 0, "", ""]]
			_ArrayAdd($aResult, $aTmp)
		Next
		
		For $i = 0 To UBound($aResult) - 1
			Switch $sUpgrade
				Case "Any"
					$sSearchWay = "BC1"
					$sDir = $g_sImgLabResearch
					$iSortBy = 3
					$iSortDirection = 1
				Case "AnySpell"
					$sSearchWay = "BC1"
					$sDir = $g_sImgAnySpell
				Case "AnySiege"
					$sSearchWay = "BC1"
					$sDir = $g_sImgAnySiege
					$iSortBy = 3
				Case Else
					$sSearchWay = "BFI"
					$sDir = $g_sImgLabResearch & $sUpgrade & "*"
			EndSwitch
				
			If QuickMIS($sSearchWay, $sDir, $aResult[$i][1] - 92, $aResult[$i][2] - 93, $aResult[$i][1] + 17, $aResult[$i][2]) Then
				Local $cost = getLabCost($aResult[$i][1] - 92, $aResult[$i][2] - 10)
				$sUpgradeName = GetTroopName(TroopIndexLookup($sSearchWay = "BC1" ? $g_iQuickMISName : $sUpgrade))
				$aResult[$i][3] = Number($cost)
				$aResult[$i][4] = $sUpgradeName
				$aResult[$i][5] = $sSearchWay = "BC1" ? $g_iQuickMISName : $sUpgrade
			EndIf
		Next
	EndIf
	
	For $i = 0 To UBound($aResult) - 1 
		Local $iIndex = _ArraySearch($aResult, "", 0, 0, 0, 0, 1, 4)
		If $iIndex <> -1 Then _ArrayDelete($aResult, $iIndex)
	Next
	
	_ArraySort($aResult, $iSortDirection, 0, 0, $iSortBy)
	Return $aResult
EndFunc

Func GetUpgradeName($shortName)
	For $i = 0 To UBound($g_avLabTroops) -1
		If $shortName = $g_avLabTroops[$i][2] Then Return $g_avLabTroops[$i][0]
	Next
	Return ""
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

; Find Research Button
Func FindResearchButton()
	Local $TryLabAutoLocate = False
	Local $LabFound = False
	
	If _ColorCheck(_GetPixelColor(288, 36, True), Hex(0xFFFF5E, 6), 20, Default, "Laboratory") Then
		SetLog("Laboratory: Found Goblin Lab!, Return False", $COLOR_DEBUG1)
		Return False
	EndIf
	
	ZoomOut()
	;Click Laboratory
	If Int($g_aiLaboratoryPos[0]) < 1 Or Int($g_aiLaboratoryPos[1]) < 1 Then
		$TryLabAutoLocate = True
	Else
		Click($g_aiLaboratoryPos[0], $g_aiLaboratoryPos[1])
		If _Sleep(1000) Then Return
		Local $BuildingInfo = BuildingInfo(260, 477)
		If StringInStr($BuildingInfo[1], "Lab") Then
			$TryLabAutoLocate = False
			$LabFound = True
		Else
			$TryLabAutoLocate = True
		EndIf
	EndIf

	If $TryLabAutoLocate Then
		$LabFound = AutoLocateLab()
		If $LabFound Then
			applyConfig()
			saveConfig()
		Else
			SetLog("TryLabAutoLocate Failed, please locate manually", $COLOR_DEBUG)
			Return
		EndIf
	EndIf

	If $LabFound Then
		If Not ClickB("Research") Then Return
		If _Sleep(2000) Then Return
		Return True
	EndIf
EndFunc

Func AutoLocateLab()
	Local $LabFound = False
	SetLog("Try to Auto Locate Laboratory!", $COLOR_INFO)
	ClickAway()
	Local $aLabCoord = QuickMIS("CNX", $g_sImgLaboratory)
	If IsArray($aLabCoord) And UBound($aLabCoord) > 0 Then
		_ArraySort($aLabCoord, 1, 0, 0, 3)
		For $i = 0 To UBound($aLabCoord) - 1
			If StringInStr($aLabCoord[$i][0], "Research") Then 
				$aLabCoord[$i][2] += 30
			EndIf
			Click($aLabCoord[$i][1], $aLabCoord[$i][2])
		
			If _Sleep(1000) Then Return
			Local $BuildingInfo = BuildingInfo(242, 477)
			If StringInStr($BuildingInfo[1], "Lab") Then	
				$g_aiLaboratoryPos[0] = $aLabCoord[$i][1]
				$g_aiLaboratoryPos[1] = $aLabCoord[$i][2]
				SetLog("Found Laboratory Lvl " & $BuildingInfo[2] & ", save as Lab Coords : " & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1], $COLOR_INFO)
				$LabFound = True
				ExitLoop
			Else
				SetLog("Not Laboratory, its a " & $BuildingInfo[1], $COLOR_DEBUG1)
				ClickAway()
			EndIf
		Next
		
	EndIf
	Return $LabFound	
EndFunc

Func UpgradeLabAny($bDebug = False)
	;just start from page 1, close and open again lab window
	ClickAway()
	If _Sleep(1000) Then Return
	If Not ClickB("Research") Then Return
	If _Sleep(1000) Then Return
	Local $iCurPage = 1, $bUpgradeFound = False, $sCost = 0, $iLabMaxPages = 4
	While($iCurPage <= $iLabMaxPages)
		Local $Upgrades = FindLabUpgrade()
		Local $aCoord[2], $sUpgrade
		If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
			For $i = 0 To UBound($Upgrades) - 1
				If $g_bDebugSetLog Then SetLog("LabUpgrade:" & $Upgrades[$i][4] & " Cost:" & $Upgrades[$i][3] & " " & $Upgrades[$i][0], $COLOR_DEBUG1)
				$aCoord[0] = $Upgrades[$i][1] - 40 
				$aCoord[1] = $Upgrades[$i][2] - 40
				$sCost = $Upgrades[$i][3]
				$sUpgrade = $Upgrades[$i][4]
				If Not IsLabUpgradeResourceEnough($sCost, $Upgrades[$i][0]) Then
					SetLog("LabUpgrade:" & $sUpgrade & " Skip, Not Enough Resource", $COLOR_INFO)
				Else
					SetLog("LabUpgrade:" & $sUpgrade & " Cost:" & $sCost, $COLOR_SUCCESS)
					$bUpgradeFound = True
					ExitLoop
				EndIf
			Next
		Else
			SetLog("Not found Any Upgrade here, looking next", $COLOR_INFO)
		EndIf
		
		If $bUpgradeFound Then
			Return LaboratoryUpgrade($sUpgrade, $aCoord, $sCost, $bDebug) ; Return whether or not we successfully upgraded
		EndIf
		
		$iCurPage = LabGoToPage($iCurPage, $iCurPage + 1) ; go to next page of upgrades
		If _Sleep($DELAYLABORATORY2) Then Return
	WEnd
	
	ClickAway()
	Return False
EndFunc