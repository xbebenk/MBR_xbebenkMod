; #FUNCTION# ====================================================================================================================
; Name ..........:
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values .:
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBotRun. Copyright 2015-2018
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================
Func AutoUpgrade($bTest = False)
	Local $bWasRunState = $g_bRunState
	$g_bRunState = True
	;Local $Result = _AutoUpgrade()
	Local $Result = SearchUpgrade($bTest)
	$g_bRunState = $bWasRunState
	Return $Result
EndFunc

Func SearchUpgrade($bTest = False)
	
	Local $b_isupgradefound
	Local $i_scrolltime = 0
	ClickAway("Left")
	VillageReport(True, True) ;check if we have available builder
	
	If Not $g_bAutoUpgradeEnabled Then Return
	
	; check if builder head is clickable
	If Not (_ColorCheck(_GetPixelColor(275, 15, True), "F5F5ED", 20) = True) Then
		SetLog("Unable to find the Builder menu button... Exiting Auto Upgrade...", $COLOR_ERROR)
		Return
	EndIf
	If $bTest Then $g_iFreeBuilderCount = 5
	;Check if there is a free builder for Auto Upgrade
	If ($g_iFreeBuilderCount - ($g_bAutoUpgradeWallsEnable And $g_bUpgradeWallSaveBuilder ? 1 : 0)) <= 0 Then
		SetLog("No builder available. Skipping Auto Upgrade!", $COLOR_WARNING)
		Return
	EndIf
	
	; open the builders menu
	Click(295, 30)
	If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return
	ClickDrag(333, 100, 333, 400, 500) ;drag to bottom
	If _Sleep(1000) Then Return
	
	If $g_bScrollFirst Then ;skip first page on builder menu
		Local $Yscroll =  ($g_iTotalBuilderCount - $g_iFreeBuilderCount) * 28
		ClickDrag(333, 120 + $Yscroll, 333, 90, 500)
		If _Sleep(1000) Then Return
	EndIf
	
	While 1
		While $b_isupgradefound = False
			; search for 000 in builders menu, if 000 found, a possible upgrade is available
			If QuickMIS("BC1", $g_sImgAUpgradeZero, 180, 80 + $g_iNextLineOffset, 480, 380) Then
				$g_iCurrentLineOffset = $g_iNextLineOffset + $g_iQuickMISY
				; check in the line of the 000 if we can see "New" or the Gear of the equipment, in this case, will not do the upgrade
				If QuickMIS("NX",$g_sImgAUpgradeObst, 180, 80 + $g_iCurrentLineOffset - 15, 480, 80 + $g_iCurrentLineOffset + 15) <> "none" Then
					SetLog("This is a New Building or an Equipment, looking next...", $COLOR_WARNING)
					$g_iNextLineOffset = $g_iCurrentLineOffset
				Else
					SetLog("Possible upgrade found!", $COLOR_SUCCESS)
					$b_isupgradefound = True
				EndIf
			Else
				If $i_scrolltime > 1 Then
					SetLog("Max Scrool reach!", $COLOR_SUCCESS)
					ExitLoop 2
				EndIf
				SetLog("No upgrade available... Try Scrolling Up!", $COLOR_INFO)
				If $g_iCurrentLineOffset + 80 < 150 Then 
					ClickDrag(333, 80 + $g_iCurrentLineOffset, 333, 80, 500)
				Else
					ClickDrag(333, 350, 333, 80, 500)
				EndIf
				$i_scrolltime += 1
				$g_iNextLineOffset = 0
				$g_iCurrentLineOffset = 0 
				;SetLog("Scroll time: " & $i_scrolltime & ", $g_iNextLineOffset: " & $g_iNextLineOffset & ",$g_iCurrentLineOffset: " & $g_iCurrentLineOffset, $COLOR_SUCCESS)
				ContinueLoop
			EndIf
		Wend
		
		If Not DoUpgrade($bTest) Then 
			$b_isupgradefound = False
			ClickAway("Left")
			If _Sleep(1000) Then Return
			; open the builders menu
			Click(295, 30)
			If _Sleep(1000) Then Return
			ContinueLoop
		Else 
			SetLog("Upgrade Success!", $COLOR_SUCCESS)
			$g_iNextLineOffset = 0
			$g_iCurrentLineOffset = 0 
			ExitLoop
		Endif
	Wend
	$g_iNextLineOffset = 0
	$g_iCurrentLineOffset = 0 
	ClickAway("Left") ;close builder menu
	
EndFunc

Func DoUpgrade($bTest = False)

	; if it's an upgrade, will click on the upgrade, in builders menu
	Click(180 + $g_iQuickMISX, 80 + $g_iCurrentLineOffset)
	If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return

	; check if any wrong click by verifying the presence of the Upgrade button (the hammer)
	Local $aUpgradeButton = findButton("Upgrade", Default, 1, True)
	If Not(IsArray($aUpgradeButton) And UBound($aUpgradeButton, 1) = 2) Then
		SetLog("No upgrade here... Wrong click, looking next...", $COLOR_WARNING)
		;$g_iNextLineOffset = $g_iCurrentLineOffset -> not necessary finally, but in case, I keep lne commented
		$g_iNextLineOffset = $g_iCurrentLineOffset
		Return False
	EndIf

	; get the name and actual level of upgrade selected, if strings are empty, will exit Auto Upgrade, an error happens
	$g_aUpgradeNameLevel = BuildingInfo(242, 490 + $g_iBottomOffsetY)
	If $g_aUpgradeNameLevel[0] = "" Then
		SetLog("Error when trying to get upgrade name and level, looking next...", $COLOR_ERROR)
		$g_iNextLineOffset = $g_iCurrentLineOffset
		Return False
	EndIf

	Local $bMustIgnoreUpgrade = False
	; matchmaking between building name and the ignore list
	If $g_aUpgradeNameLevel[1] = "po al Champion" Then $g_aUpgradeNameLevel[1] = "Royal Champion"
	Switch $g_aUpgradeNameLevel[1]
		Case "Town Hall"
			If $g_aUpgradeNameLevel[2] > 11 Then 
				If $g_iChkUpgradesToIgnore[24] = 1 Then 
					$bMustIgnoreUpgrade = True
				Else
					$aUpgradeButton = findButton("UpgradeWeapon", Default, 1, True)
					If Not(IsArray($aUpgradeButton) And UBound($aUpgradeButton, 1) = 2) Then
						SetLog("No Upgrade Weapon Button here... Wrong click, looking next...", $COLOR_WARNING)
						;$g_iNextLineOffset = $g_iCurrentLineOffset -> not necessary finally, but in case, I keep lne commented
						$g_iNextLineOffset = $g_iCurrentLineOffset
						Return False
					EndIf
				Endif
			Else
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[0] = 1) ? True : False
			EndIf
		Case "Barbarian King"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[1] = 1 Or $g_bUpgradeKingEnable = True) ? True : False ; if upgrade king is selected, will ignore it
		Case "Archer Queen"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[2] = 1 Or $g_bUpgradeQueenEnable = True) ? True : False ; if upgrade queen is selected, will ignore it
		Case "Grand Warden"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[3] = 1 Or $g_bUpgradeWardenEnable = True) ? True : False ; if upgrade warden is selected, will ignore it
		Case "Royal Champion"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[14] = 1 Or $g_bUpgradeChampionEnable = True) ? True : False ; if upgrade champion is selected, will ignore it
		Case "Clan Castle"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[4] = 1) ? True : False
		Case "Laboratory"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[5] = 1) ? True : False
		Case "Wall"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[6] = 1 Or $g_bAutoUpgradeWallsEnable = True) ? True : False ; if wall upgrade enabled, will ignore it
		Case "Barracks"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[7] = 1) ? True : False
		Case "Dark Barracks"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[8] = 1) ? True : False
		Case "Spell Factory"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[9] = 1) ? True : False
		Case "Dark Spell Factory"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[10] = 1) ? True : False
		Case "Gold Mine"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[11] = 1) ? True : False
		Case "Elixir Collector"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[12] = 1) ? True : False
		Case "Dark Elixir Drill"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[13] = 1) ? True : False
		Case "Cannon"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[15] = 1) ? True : False
		Case "Archer Tower"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[16] = 1) ? True : False
		Case "Mortar"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[17] = 1) ? True : False
		Case "Hidden Tesla"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[18] = 1) ? True : False
		Case "Spring Trap"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[19] = 1) ? True : False
		Case "Giant Bomb"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[19] = 1) ? True : False
		Case "Bomb"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[19] = 1) ? True : False
		Case "Seeking Air Mine"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[20] = 1) ? True : False
		Case "Air Bomb"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[20] = 1) ? True : False
		Case "Wizard Tower"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[21] = 1) ? True : False
		Case "Bomb Tower"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[22] = 1) ? True : False
		Case "Air Defense"
			$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[23] = 1) ? True : False
		Case Else
			$bMustIgnoreUpgrade = False
	EndSwitch

	; check if the upgrade name is on the list of upgrades that must be ignored
	If $bMustIgnoreUpgrade = True Then
		SetLog($g_aUpgradeNameLevel[1] & " : This upgrade must be ignored, looking next...", $COLOR_WARNING)
		$g_iNextLineOffset = $g_iCurrentLineOffset
		Return False
	EndIf

	; if upgrade don't have to be ignored, click on the Upgrade button to open Upgrade window
	ClickP($aUpgradeButton)
	If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return

	Switch $g_aUpgradeNameLevel[1]
		Case "Barbarian King", "Archer Queen", "Grand Warden", "Royal Champion"
			$g_aUpgradeResourceCostDuration[0] = QuickMIS("N1", $g_sImgAUpgradeRes, 690, 540, 730, 580) ; get resource
			$g_aUpgradeResourceCostDuration[1] = getResourcesBonus(598, 522 + $g_iMidOffsetY) ; get cost
			$g_aUpgradeResourceCostDuration[2] = getHeroUpgradeTime(578, 465 + $g_iMidOffsetY) ; get duration
		Case Else
			$g_aUpgradeResourceCostDuration[0] = QuickMIS("N1", $g_sImgAUpgradeRes, 460, 510, 500, 550) ; get resource
			$g_aUpgradeResourceCostDuration[1] = getResourcesBonus(366, 487 + $g_iMidOffsetY) ; get cost
			$g_aUpgradeResourceCostDuration[2] = getBldgUpgradeTime(195, 307 + $g_iMidOffsetY) ; get duration
	EndSwitch

	; if one of the value is empty, there is an error, we must exit Auto Upgrade
	For $i = 0 To 2
		;SetLog($g_aUpgradeResourceCostDuration[$i])
		If $g_aUpgradeResourceCostDuration[$i] = "" Then
			SetLog("Error when trying to get upgrade details, looking next...", $COLOR_ERROR)
			;$g_iNextLineOffset = $g_iCurrentLineOffset
			;Return False
		EndIf
	Next

	Local $bMustIgnoreResource = False
	; matchmaking between resource name and the ignore list
	Switch $g_aUpgradeResourceCostDuration[0]
		Case "Gold"
			$bMustIgnoreResource = ($g_iChkResourcesToIgnore[0] = 1) ? True : False
		Case "Elixir"
			$bMustIgnoreResource = ($g_iChkResourcesToIgnore[1] = 1) ? True : False
		Case "Dark Elixir"
			$bMustIgnoreResource = ($g_iChkResourcesToIgnore[2] = 1) ? True : False
		Case Else
			$bMustIgnoreResource = False
	EndSwitch

	; check if the resource of the upgrade must be ignored
	If $bMustIgnoreResource = True Then
		SetLog($g_aUpgradeNameLevel[1] & ": This resource must be ignored, looking next...", $COLOR_WARNING)
		$g_iNextLineOffset = $g_iCurrentLineOffset
		Return False
	EndIf

	; initiate a False boolean, that firstly says that there is no sufficent resource to launch upgrade
	Local $bSufficentResourceToUpgrade = False
	; if Cost of upgrade + Value set in settings to be kept after upgrade > Current village resource, make boolean True and can continue
	Switch $g_aUpgradeResourceCostDuration[0]
		Case "Gold"
			If $g_aiCurrentLoot[$eLootGold] >= ($g_aUpgradeResourceCostDuration[1] + $g_iTxtSmartMinGold) Then $bSufficentResourceToUpgrade = True
		Case "Elixir"
			If $g_aiCurrentLoot[$eLootElixir] >= ($g_aUpgradeResourceCostDuration[1] + $g_iTxtSmartMinElixir) Then $bSufficentResourceToUpgrade = True
		Case "Dark Elixir"
			If $g_aiCurrentLoot[$eLootDarkElixir] >= ($g_aUpgradeResourceCostDuration[1] + $g_iTxtSmartMinDark) Then $bSufficentResourceToUpgrade = True
	EndSwitch
	; if boolean still False, we can't launch upgrade, exiting...
	If Not $bSufficentResourceToUpgrade Then
		SetLog($g_aUpgradeNameLevel[1] & ": Insufficent " & $g_aUpgradeResourceCostDuration[0] & " to launch this upgrade, looking Next...", $COLOR_WARNING)
		$g_iNextLineOffset = $g_iCurrentLineOffset
		Return False
	EndIf

	; final click on upgrade button, click coord is get looking at upgrade type (heroes have a diferent place for Upgrade button)
	If Not $bTest Then 
		Switch $g_aUpgradeNameLevel[1]
			Case "Barbarian King", "Archer Queen", "Grand Warden", "Royal Champion"
				Click(660, 560)
			Case Else
				Click(440, 530)
		EndSwitch
	Else	
		ClickAway("Left")
	Endif

	;Check for 'End Boost?' pop-up
	If _Sleep(1000) Then Return
	Local $aImgAUpgradeEndBoost = decodeSingleCoord(findImage("EndBoost", $g_sImgAUpgradeEndBoost, GetDiamondFromRect("350, 310, 570, 230"), 1, True))
	If UBound($aImgAUpgradeEndBoost) > 1 Then
		SetLog("End Boost? pop-up found", $COLOR_INFO)
		SetLog("Clicking OK", $COLOR_INFO)
		Local $aImgAUpgradeEndBoostOKBtn = decodeSingleCoord(findImage("EndBoostOKBtn", $g_sImgAUpgradeEndBoostOKBtn, GetDiamondFromRect("420, 470, 610, 380"), 1, True))
		If UBound($aImgAUpgradeEndBoostOKBtn) > 1 Then
			Click($aImgAUpgradeEndBoostOKBtn[0], $aImgAUpgradeEndBoostOKBtn[1])
			If _Sleep(1000) Then Return
		Else
			SetLog("Unable to locate OK Button", $COLOR_ERROR)
			If _Sleep(1000) Then Return
			ClickAway("Left")
			Return
		EndIf
	EndIf


	; Upgrade completed, but at the same line there might be more...
	$g_iCurrentLineOffset -= $g_iQuickMISY
	
	; update Logs and History file
	If $g_aUpgradeNameLevel[1] = "Town Hall" And $g_iChkUpgradesToIgnore[23] = 0 Then
		Switch $g_aUpgradeNameLevel[2]
			Case 12
				SetLog("Launched upgrade of Giga Tesla to level " & $g_aUpgradeNameLevel[2] + 1 & " successfully !", $COLOR_SUCCESS)
			Case 13
				SetLog("Launched upgrade of Giga Inferno to level " & $g_aUpgradeNameLevel[2] + 1 & " successfully !", $COLOR_SUCCESS)
			Case 14
				SetLog("Launched upgrade of Giga Inferno to level " & $g_aUpgradeNameLevel[2] + 1 & " successfully !", $COLOR_SUCCESS)
		EndSwitch
	Else
		SetLog("Launched upgrade of " & $g_aUpgradeNameLevel[1] & " to level " & $g_aUpgradeNameLevel[2] + 1 & " successfully !", $COLOR_SUCCESS)
	Endif
	
	
	SetLog(" - Cost : " & _NumberFormat($g_aUpgradeResourceCostDuration[1]) & " " & $g_aUpgradeResourceCostDuration[0], $COLOR_SUCCESS)
	SetLog(" - Duration : " & $g_aUpgradeResourceCostDuration[2], $COLOR_SUCCESS)
	
	 
	Local $txtAcc = $g_iCurAccount
	Local $txtAccName = $g_asProfileName[$g_iCurAccount]
	
	_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, _
			@CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc & "] " & $txtAccName & _
			" - Upgrading " & $g_aUpgradeNameLevel[1] & _
			" to level " & $g_aUpgradeNameLevel[2] + 1 & _
			" for " & _NumberFormat($g_aUpgradeResourceCostDuration[1]) & _
			" " & $g_aUpgradeResourceCostDuration[0] & _
			" - Duration : " & $g_aUpgradeResourceCostDuration[2])

	_FileWriteLog($g_sProfileLogsPath & "\AutoUpgradeHistory.log", " [" & $txtAcc & "] " & $txtAccName & _
			"Upgrading " & $g_aUpgradeNameLevel[1] & _
			" to level " & $g_aUpgradeNameLevel[2] + 1 & _
			" for " & _NumberFormat($g_aUpgradeResourceCostDuration[1]) & _
			" " & $g_aUpgradeResourceCostDuration[0] & _
			" - Duration : " & $g_aUpgradeResourceCostDuration[2])
			
	Return True
EndFunc