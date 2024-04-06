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

Func Laboratory($bDebug = False)
	If Not $g_bAutoLabUpgradeEnable Then Return ; Lab upgrade not enabled.
	If $bDebug Then $g_sLabUpgradeTime = ""
	If ChkUpgradeInProgress($bDebug) Then Return
	If $g_aiLaboratoryPos[0] < 70 Or $g_aiLaboratoryPos[1] = 0 Then
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
	If ChkLabUpgradeInProgress($bDebug) Then Return False ; Lab currently running skip going further

	; Lab upgrade is not in progress and not upgrading, so we need to start an upgrade.
	Local $iCurPage = 1, $iLabPicsPerPage = 12, $iLabMaxPages = 5, $iPage = 0
	Local $sCostResult, $bUpgradeFound = False, $sReseachName = "", $sReseachImage = ""
	Local $tmpNoResources = False
	Local $sLabTroopsSection = "70,340,790,566"
	Local $sLabTroopsSectionDiam = GetDiamondFromRect($sLabTroopsSection) ; easy to change search areas
	Local $iLab = $g_iCmbLaboratory, $aCoords[2]
	
	If $iLab <> 0 Then ;user selected upgrade
		$iPage = Ceiling($iLab / $iLabPicsPerPage) ; page # of user choice
		$sReseachName = $g_avLabTroops[$iLab][0]
		$sReseachImage = $g_avLabTroops[$iLab][2]
		SetLog("Search " & $sReseachName & ", page:" & $iPage, $COLOR_DEBUG1)
		
		$iCurPage = LabGoToPage($iCurPage, $iPage)
		
		SetLog("FindImage : " & $sReseachName, $COLOR_DEBUG1)
		If QuickMIS("BFI", $g_sImgLabResearch & $sReseachImage & "*", 70, 340, 790, 566) Then ; Get coords of upgrade the user wants
			$aCoords[0] = $g_iQuickMISX
			$aCoords[1] = $g_iQuickMISY
			If QuickMIS("BC1", $g_sImgResIcon, $aCoords[0], $aCoords[1], $aCoords[0] + 60, $aCoords[1] + 70) Then 
				Local $sCostResult = getLabCost($g_iQuickMISX - 75, $g_iQuickMISY - 10)
				Local $level = getTroopsSpellsLevel($g_iQuickMISX - 75, $g_iQuickMISY - 30)
				If $level = "" Then $level = 1
				If Not IsLabUpgradeResourceEnough($sReseachName, $sCostResult) Then
					SetLog($sReseachName & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName & ", Not Enough Resource", $COLOR_INFO)
				Else
					SetLog($sReseachName & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName, $COLOR_INFO)
					$bUpgradeFound = True
				EndIf
			EndIf
		EndIf

		If Not $bUpgradeFound Then
			SetLog("Lab Upgrade " & $sReseachName & " - Not available.", $COLOR_DEBUG1)
		EndIf

		If $bUpgradeFound Then
			Return LaboratoryUpgrade($sReseachName, $aCoords, $sCostResult, $bDebug) ; return whether or not we successfully upgraded
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
				Endif
			Next
			
			For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1 ;try labupgrade based on order
				$iPrio = $z + 1
				$iIndex = $g_aCmbLabUpgradeOrder[$z] + 1
				
				If $iIndex > 0 Then
					Select 
						Case $iIndex < 49 ;Any Normal
							Local $aSiege = ["WallW", "BattleB", "StoneS", "SiegeB", "LogL", "FlameF", "BattleD"]
							$sReseachName = $g_avLabTroops[$iIndex][0]
							$sReseachImage = $g_avLabTroops[$iIndex][2]
							$iPage = Ceiling($iIndex / $iLabPicsPerPage) ; page # of user choice
							SetLog("Try Lab Upgrade: " & $sReseachName & ", Page:" & $iPage, $COLOR_DEBUG1)
							$iCurPage = LabGoToPage($iCurPage, $iPage)
							
							SetLog("FindImage : " & $sReseachName, $COLOR_DEBUG1)
							If QuickMIS("BFI", $g_sImgLabResearch & $sReseachImage & "*", 70, 340, 790, 566) Then
								$aCoords[0] = $g_iQuickMISX
								$aCoords[1] = $g_iQuickMISY 
								If QuickMIS("BC1", $g_sImgResIcon, $aCoords[0], $aCoords[1], $aCoords[0] + 60, $aCoords[1] + 70) Then 
									Local $sCostResult = getLabCost($g_iQuickMISX - 92, $g_iQuickMISY - 10)
									Local $level = getTroopsSpellsLevel($g_iQuickMISX - 79, $g_iQuickMISY - 32)
									If $level = "" Then $level = 1
									If $g_bUpgradeSiegeToLvl2 And $level >= 3 Then
										For $x In $aSiege
											If $g_avLabTroops[$iIndex][2] = $x Then
												SetLog("Skip " & $g_avLabTroops[$iIndex][0] & ", already Level " & $level)
												ContinueLoop 2									
											EndIf
										Next
									EndIf
									If Not IsLabUpgradeResourceEnough($g_avLabTroops[$iIndex][2], $sCostResult) Then
										$tmpNoResources = True
										SetLog(GetUpgradeName($g_avLabTroops[$iIndex][0]) & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName & ", Not Enough Resource", $COLOR_INFO)
									Else
										SetLog(GetUpgradeName($g_avLabTroops[$iIndex][0]) & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName, $COLOR_INFO)
										$bUpgradeFound = True
										ExitLoop
									EndIf
								EndIf
							Else
								SetLog("FindImage : No Image " & $sReseachName & " Found!", $COLOR_DEBUG1)
							EndIf
											
						Case $iIndex = 49 ;Any Spell
							$sReseachName = $g_avLabTroops[$iIndex][0]
							$sReseachImage = $g_avLabTroops[$iIndex][2]
							$iPage = 2
							SetLog("Try Lab Upgrade: " & $sReseachName & ", Page:" & $iPage, $COLOR_DEBUG1)
							$iCurPage = LabGoToPage($iCurPage, $iPage)
							
							$bUpgradeFound = False
							For $page = 1 To 2
								Local $aSpell = QuickMIS("CNX", $g_sImgAnySpell, 110,340,740,540)
								If IsArray($aSpell) And UBound($aSpell) > 0 Then
									For $i = 0 To UBound($aSpell) - 1
										If QuickMIS("BC1", $g_sImgResIcon, $aSpell[$i][1], $aSpell[$i][2], $aSpell[$i][1] + 60, $aSpell[$i][2] + 70) Then 
											Local $sCostResult = getLabCost($g_iQuickMISX - 92, $g_iQuickMISY - 10)
											Local $level = getTroopsSpellsLevel($g_iQuickMISX - 79, $g_iQuickMISY - 32)
											If $level = "" Then $level = 1
											If Not IsLabUpgradeResourceEnough($aSpell[$i][0], $sCostResult) Then
												SetLog(GetUpgradeName($aSpell[$i][0]) & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName & ", Not Enough Resource", $COLOR_INFO)
											Else
												SetLog(GetUpgradeName($aSpell[$i][0]) & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName, $COLOR_INFO)
												$bUpgradeFound = True
												ExitLoop
												;Local $aCoords[2] = [$aSpell[$i][1], $aSpell[$i][2]]
												;If Not $bDebug Then Return LaboratoryUpgrade($aSpell[$i][0], $aCoords, $sCostResult, $bDebug) ; return whether or not we successfully upgraded
											EndIf
										Else
											SetLog("Any Spell - ResIcon Not Found", $COLOR_ERROR)
										EndIf
									Next
								EndIf
								If Not $bUpgradeFound Then 
									$iCurPage = LabGoToPage($iCurPage, 3)
								EndIf
							Next
							If Not $bUpgradeFound Then SetLog("FindImage : " & $sReseachName & " Not Found!", $COLOR_DEBUG1)
												
						Case $iIndex = 50 ;Any Siege
							$sReseachName = $g_avLabTroops[$iIndex][0]
							$sReseachImage = $g_avLabTroops[$iIndex][2]
							$iPage = 4
							SetLog("Try Lab Upgrade: " & $sReseachName & ", Page:" & $iPage, $COLOR_DEBUG1)
							$iCurPage = LabGoToPage($iCurPage, $iPage)
							
							Local $aSiege = QuickMIS("CNX", $g_sImgAnySiege, 110,340,740,540)
							If IsArray($aSiege) And UBound($aSiege) > 0 Then
								For $i = 0 To UBound($aSiege) - 1
									If QuickMIS("BC1", $g_sImgResIcon, $aSiege[$i][1], $aSiege[$i][2], $aSiege[$i][1] + 80, $aSiege[$i][2] + 80) Then 
										Local $sCostResult = getLabCost($g_iQuickMISX - 92, $g_iQuickMISY - 10)
										Local $level = getTroopsSpellsLevel($g_iQuickMISX - 79, $g_iQuickMISY - 32)
										If $level = "" Then $level = 1
										If $g_bUpgradeSiegeToLvl2 And $level >= 3 Then
											SetLog("Skip " & $aSiege[$i][0] & ", already Level " & $level)
											ContinueLoop								
										EndIf
										If Not IsLabUpgradeResourceEnough($aSiege[$i][0], $sCostResult) Then
											SetLog($aSiege[$i][0] & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName & ", Not Enough Resource", $COLOR_INFO)
										Else
											SetLog($aSiege[$i][0] & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName, $COLOR_INFO)
											$bUpgradeFound = True
											ExitLoop
											;Local $aCoords[2] = [$aSiege[$i][1], $aSiege[$i][2]]
											;If Not $bDebug Then Return LaboratoryUpgrade($aSiege[$i][0], $aCoords, $sCostResult, $bDebug) ; return whether or not we successfully upgraded
										EndIf
									Else
										SetLog("Any Siege - ResIcon Not Found", $COLOR_ERROR)
									EndIf
								Next
							Else
								If Not $bUpgradeFound Then SetLog("FindImage : " & $sReseachName & " Not Found!", $COLOR_DEBUG1)
							EndIf
					EndSelect
				EndIf
			Next
			
			If $bUpgradeFound Then
				Return LaboratoryUpgrade($g_avLabTroops[$iIndex][2], $aCoords, $sCostResult, $bDebug) ; return whether or not we successfully upgraded
			Else
				SetLog("Lab Upgrade " & $g_avLabTroops[$iIndex][0] & " - Not available.", $COLOR_INFO)
			EndIf
			
		Else ; no LabUpgradeOrder
			While($iCurPage <= $iLabMaxPages)
				Local $Upgrades = FindLabUpgrade()
				Local $aUpgradeCoord[2], $sUpgrade
				If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
					For $i = 0 To UBound($Upgrades) - 1
						If $Upgrades[$i][0] = "SKIP" Then ContinueLoop
						SetDebugLog("LabUpgrade:" & $Upgrades[$i][4] & " Cost:" & $Upgrades[$i][3], $COLOR_INFO)	
						If Not IsLabUpgradeResourceEnough($Upgrades[$i][4], $Upgrades[$i][3]) Then
							SetDebugLog($Upgrades[$i][4] & " Skip, Not Enough Resource", $COLOR_INFO)
						Else
							SetDebugLog("LabUpgrade:" & $Upgrades[$i][4] & " Cost:" & $Upgrades[$i][3], $COLOR_SUCCESS)
							$bUpgradeFound = True
							$sUpgrade = $Upgrades[$i][4]
							$aUpgradeCoord[0] = $Upgrades[$i][1] - 35
							$aUpgradeCoord[1] = $Upgrades[$i][2] - 35
							$sCostResult = $Upgrades[$i][3]
							ExitLoop
						EndIf
					Next
				Else
					SetLog("Not found Any Upgrade here, looking next", $COLOR_INFO)
				EndIf

				If $bUpgradeFound Then
					Return LaboratoryUpgrade($sUpgrade, $aUpgradeCoord, $sCostResult, $bDebug) ; return whether or not we successfully upgraded
				EndIf
				
				$iCurPage = LabGoToPage($iCurPage, $iCurPage + 1) ; go to next page of upgrades
				If _Sleep($DELAYLABORATORY2) Then Return
			WEnd
		EndIf
		; If We got to here without returning, then nothing available for upgrade
		SetLog("Nothing available for upgrade at the moment, try again later.")
		SetLog("LabUpgradeOrderEnable=" & String($g_bLabUpgradeOrderEnable) & ", UpgradeAnyTroops=" & String($g_bUpgradeAnyTroops) & ", tmpNoResources=" & String($tmpNoResources), $COLOR_DEBUG)
		If $g_bLabUpgradeOrderEnable And $g_bUpgradeAnyTroops And Not $tmpNoResources Then 
			Return UpgradeLabAny($bDebug)
		EndIf
		ClickAway()
	EndIf
	ClickAway()
	
EndFunc

; start a given upgrade
Func LaboratoryUpgrade($name, $aCoords, $sCostResult, $bDebug = False)
	SetLog("Selected upgrade: " & GetUpgradeName($name) & " Cost: " & $sCostResult, $COLOR_INFO)
	ClickP($aCoords) ; click troop
	If _Sleep(2000) Then Return
	
	If $bDebug Then ; if debugging, do not actually click it
		SetLog("[debug mode] - Start Upgrade, Click Back Button", $COLOR_ACTION)
		Click(805, 100)
		Return True ; return true as if we really started an upgrade
	Else
		Click(660, 520, 1, 0, "#0202") ; Everything is good - Click the upgrade button
		If _Sleep(1000) Then Return
		If Not isGemOpen(True) Then ; check for gem window
			ChkLabUpgradeInProgress($bDebug, $name)
			; success
			SetLog("Upgrade " & GetUpgradeName($name) & " in your laboratory started with success...", $COLOR_SUCCESS)
			PushMsg("LabSuccess")
			
			If _Sleep($DELAYLABUPGRADE2) Then Return
			ClickAway()
			If _Sleep(1000) Then Return
			ClickAway()
			Return True ; upgrade started
		Else
			SetLog("Oops, Gems required for " & GetUpgradeName($name) & " Upgrade, try again.", $COLOR_ERROR)
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
	SetLog("LabGoToPage : From " & $iFrom & " To " & $iTo, $COLOR_ACTION)
	Select
		Case $iTo > $iFrom
			For $i = $iFrom To $iTo - 1
				ClickDrag(720, 500, 80, 500)
				If _Sleep(1000) Then Return
				$iCurPage += 1
				If $g_bDebugSetLog Then SetLog("CurPage:" & $iCurPage, $COLOR_DEBUG)
			Next
		Case $iTo < $iFrom
			For $i = $iFrom To $iTo + 1 Step - 1
				ClickDrag(130, 500, 766, 500)
				If _Sleep(1000) Then Return
				$iCurPage -= 1
				If $g_bDebugSetLog Then SetLog("CurPage:" & $iCurPage, $COLOR_DEBUG)
			Next
		Case $iTo = $iFrom
	EndSelect
	
	If $iTo = 1 Or $iTo = $iLabMaxPages Then 
		If _Sleep(3000) Then Return
	EndIf
	
	SetLog("LabGoToPage : CurPage=" & $iCurPage, $COLOR_ACTION)
	Return $iCurPage
EndFunc

; check the lab to see if something is upgrading in the lab already
Func ChkLabUpgradeInProgress($bDebug = False, $name = "")
	; check for upgrade in process - look for green in finish upgrade with gems button
	If _Sleep(500) Then Return
	If _ColorCheck(_GetPixelColor(415, 135, True), Hex(0xA1CA6B, 6), 20) Then ; Look for light green in upper right corner of lab window.
		SetLog("Laboratory is Running", $COLOR_INFO)
		;==========Hide Red  Show Green Hide Gray===
		GUICtrlSetState($g_hPicLabGray, $GUI_HIDE)
		GUICtrlSetState($g_hPicLabRed, $GUI_HIDE)
		GUICtrlSetState($g_hPicLabGreen, $GUI_SHOW)
		;===========================================
		If _Sleep($DELAYLABORATORY2) Then Return
		Local $sLabTimeOCR = getRemainTLaboratory(258, 211)
		Local $iLabFinishTime = ConvertOCRTime("Lab Time", $sLabTimeOCR, False)
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

; checks our global variable to see if we know of something already upgrading
Func ChkUpgradeInProgress($bDebug = False)
	If $bDebug Then Return False
	Local $TimeDiff ; time remaining on lab upgrade
	If $g_sLabUpgradeTime <> "" Then $TimeDiff = _DateDiff("n", _NowCalc(), $g_sLabUpgradeTime) ; what is difference between end time and now in minutes?
	If @error Then _logErrorDateDiff(@error)
	SetDebugLog("Lab Endtime: " & $g_sLabUpgradeTime, $COLOR_DEBUG)

	If Not $g_bRunState Then Return
	If $TimeDiff <= 0 Then
		SetLog("Checking Troop Upgrade in Laboratory ...", $COLOR_INFO)
	Else
		SetLog("Laboratory Upgrade in progress, waiting for completion", $COLOR_INFO)
		Return True
	EndIf
	Return False ; we currently do not know of any upgrades in progress
EndFunc

Func FindLabUpgrade()
	Local $aResult[0][6], $sUpgradeName = ""
	Local $TmpResult = QuickMIS("CNX", $g_sImgResIcon, 70, 415, 790, 564)
	Local $aSiege = ["WallW", "BattleB", "StoneS", "SiegeB", "LogL", "FlameF", "BattleD"]
	If IsArray($TmpResult) And UBound($TmpResult) > 0 Then
		For $i = 0 To UBound($TmpResult) - 1
			Local $aTmp[1][6] = [[$TmpResult[$i][0], $TmpResult[$i][1], $TmpResult[$i][2], 0, 0, 0]]
			_ArrayAdd($aResult, $aTmp)
		Next
		
		For $i = 0 To UBound($aResult) - 1
			If QuickMIS("BC1", $g_sImgLabResearch, $aResult[$i][1] - 92, $aResult[$i][2] - 93, $aResult[$i][1] + 17, $aResult[$i][2]) Then
				Local $cost = getLabCost($aResult[$i][1] - 92, $aResult[$i][2] - 10)
				Local $level = getTroopsSpellsLevel($aResult[$i][1] - 79, $aResult[$i][2] - 32)
				$sUpgradeName = GetTroopName(TroopIndexLookup($g_iQuickMISName))
				If $level = "" Then $level = 1
				$aResult[$i][3] = Number($cost)
				$aResult[$i][4] = $sUpgradeName
				$aResult[$i][5] = Number($level)
			EndIf
			If $g_bUpgradeSiegeToLvl2 And $aResult[$i][5] >= 2 Then
				For $x In $aSiege
					If $aResult[$i][4] = $x Then
						SetLog("Skip " & $aResult[$i][4] & ", already Level " & $aResult[$i][5])
						$aResult[$i][0] = "SKIP"
					EndIf
				Next
			EndIf
		Next
	EndIf
	_ArraySort($aResult, 0, 0, 0, 3)
	Return $aResult
EndFunc

Func GetUpgradeName($shortName)
	For $i = 0 To UBound($g_avLabTroops) -1
		If $shortName = $g_avLabTroops[$i][2] Then Return $g_avLabTroops[$i][0]
	Next
EndFunc

Func IsLabUpgradeResourceEnough($TroopOrSpell, $Cost)
	Local $bRet = False
	Local $aSiege = ["WallW", "BattleB", "StoneS", "SiegeB", "LogL", "FlameF", "BattleD", "BattleD"]
	For $j = 0 To UBound($aSiege) - 1
		If StringInStr($TroopOrSpell, $aSiege[$j]) Then
			If $g_aiCurrentLoot[$eLootElixir] > ($g_iTxtSmartMinElixir + $Cost) Then
				SetDebugLog($g_iTxtSmartMinElixir & " + " & $Cost & " = " & $g_iTxtSmartMinElixir + $Cost)
				SetDebugLog("Elixir = " & $g_aiCurrentLoot[$eLootElixir])
				Return True
			Else
				Return False
			EndIf
		EndIf
	Next
	If StringInStr($TroopOrSpell, "Spell") Then
		If IsDarkSpell($TroopOrSpell) Then ;DE Spell
			If $g_aiCurrentLoot[$eLootDarkElixir] > ($g_iTxtSmartMinDark + $Cost) Then
				SetDebugLog($g_iTxtSmartMinDark & " + " & $Cost & " = " & $g_iTxtSmartMinDark + $Cost)
				SetDebugLog("DE = " & $g_aiCurrentLoot[$eLootDarkElixir])
				$bRet = True
			EndIf
		Else ;Elixir Spell
			If $g_aiCurrentLoot[$eLootElixir] > ($g_iTxtSmartMinElixir + $Cost) Then
				SetDebugLog($g_iTxtSmartMinElixir & " + " & $Cost & " = " & $g_iTxtSmartMinElixir + $Cost)
				SetDebugLog("Elixir = " & $g_aiCurrentLoot[$eLootElixir])
				$bRet = True
			EndIf
		EndIf
	Else
		If IsDarkTroop($TroopOrSpell) Then ;DE Troop
			If $g_aiCurrentLoot[$eLootDarkElixir] > ($g_iTxtSmartMinDark + $Cost) Then
				SetDebugLog($g_iTxtSmartMinDark & " + " & $Cost & " = " & $g_iTxtSmartMinDark + $Cost)
				SetDebugLog("DE = " & $g_aiCurrentLoot[$eLootDarkElixir])
				$bRet = True
			EndIf
		Else ;Elixir Troop
			If $g_aiCurrentLoot[$eLootElixir] > ($g_iTxtSmartMinElixir + $Cost) Then
				SetDebugLog($g_iTxtSmartMinElixir & " + " & $Cost & " = " & $g_iTxtSmartMinElixir + $Cost)
				SetDebugLog("Elixir = " & $g_aiCurrentLoot[$eLootElixir])
				$bRet = True
			EndIf
		EndIf
	EndIf
	Return $bRet
EndFunc

; Find Research Button
Func FindResearchButton()
	Local $TryLabAutoLocate = False
	Local $LabFound = False
	ClickAway()
	CheckMainScreen(False, $g_bStayOnBuilderBase, "FindResearchButton")

	;Click Laboratory
	If Int($g_aiLaboratoryPos[0]) < 1 Or Int($g_aiLaboratoryPos[1]) < 1 Then
		$TryLabAutoLocate = True
	Else
		Click($g_aiLaboratoryPos[0], $g_aiLaboratoryPos[1])
		If _Sleep(1000) Then Return
		Local $BuildingInfo = BuildingInfo(260, 472)
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
		ClickB("Research")
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
			Local $BuildingInfo = BuildingInfo(240, 472)
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
	Local $iCurPage = 1, $bUpgradeFound = False, $sCostResult = 0, $iLabMaxPages = 4
	While($iCurPage <= $iLabMaxPages)
		Local $Upgrades = FindLabUpgrade()
		Local $aUpgradeCoord[2], $sUpgrade
		If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
			For $i = 0 To UBound($Upgrades) - 1
				If $Upgrades[$i][0] = "SKIP" Then ContinueLoop
				SetDebugLog("LabUpgrade:" & $Upgrades[$i][4] & " Cost:" & $Upgrades[$i][3] & " " & $Upgrades[$i][0], $COLOR_INFO)
				If Not IsLabUpgradeResourceEnough($Upgrades[$i][4], $Upgrades[$i][3]) Then
					SetDebugLog("LabUpgrade:" & $Upgrades[$i][4] & " Skip, Not Enough Resource", $COLOR_INFO)
				Else
					SetDebugLog("LabUpgrade:" & $Upgrades[$i][4] & " Cost:" & $Upgrades[$i][3], $COLOR_SUCCESS)
					$bUpgradeFound = True
					$sUpgrade = $Upgrades[$i][4]
					$aUpgradeCoord[0] = $Upgrades[$i][1] - 35 
					$aUpgradeCoord[1] = $Upgrades[$i][2] - 35
					$sCostResult = $Upgrades[$i][3]
					ExitLoop
				EndIf
			Next
		Else
			SetLog("Not found Any Upgrade here, looking next", $COLOR_INFO)
		EndIf
		
		If $bUpgradeFound Then
			Return LaboratoryUpgrade($sUpgrade, $aUpgradeCoord, $sCostResult, $bDebug) ; return whether or not we successfully upgraded
		EndIf
		
		$iCurPage = LabGoToPage($iCurPage, $iCurPage + 1) ; go to next page of upgrades
		If _Sleep($DELAYLABORATORY2) Then Return
	WEnd
	
	ClickAway()
	Return False
EndFunc