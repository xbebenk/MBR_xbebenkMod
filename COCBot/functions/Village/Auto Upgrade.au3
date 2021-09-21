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
	
	Local $b_IsUpgradeFound = False
	Local $i_scrolltime = 0
	
	Local $bDebug = $bTest
	Local $bScreencap = True
	
	If Not $g_bAutoUpgradeEnabled Then Return
	If Not $g_bRunState Then Return
	
	If $g_bPlaceNewBuilding Then
		If UpgradeNewBuilding($bTest) Then
			Return True
		EndIf
	EndIf
	
	If Not ClickMainBuilder($bTest, True) Then Return
	If Not $g_bRunState Then Return
	
	Local $UpgradeType[3] = ["Elixir", "Gold", "DE"]
	While $b_IsUpgradeFound = False
		For $z = 0 To 1 ;for do scroll 3 times
			If $g_bRestart Then Exitloop
			Local $x = 330, $y = 80, $x1 = 450, $y1 = 108, $step = 28
			; Check for 8 Icons on Window
			For $i = 0 To 7
				If $g_bRestart Then Exitloop 2
				For $UType In $UpgradeType 
					Local $aResult = GetUpgradeIcon($x, $y, $x1, $y1, $g_sImgAUpgradeIconElixir, $UType, $bScreencap, $bDebug)
					Select
						Case $aResult[2] = "Elixir" Or $aResult[2] = "Gold" Or $aResult[2] = "DE"
							Click($aResult[0], $aResult[1], 1)
							If _Sleep(1000) Then Return
							If DoUpgrade($bTest) Then
								$b_IsUpgradeFound = True
								Return True
							Else
								ClickMainBuilder($bTest)
								If _Sleep(1000) Then Return
							EndIf
						
						Case $aResult[2] = "NoResources"
							SetLog("[" & $i + 1 & "]" & " Not enough " & $UType & ", continuing...", $COLOR_INFO)
							;ExitLoop ; continue as suggested upgrades are not ordered by amount
						Case Else
							SetDebugLog("[" & $i + 1 & "]" & " Unsupport " & $UType & " icon, continuing...", $COLOR_INFO)
					EndSelect
				Next
				$y += $step
				$y1 += $step
			Next
		ClickDrag(333, $y, 333, 75, 800);do scroll down
		If _Sleep(500) Then Return
		Next
		$b_IsUpgradeFound = True
	Wend
	ClickAway("Right")
	ZoomOutByKey()
	Return False
EndFunc

Func DoUpgrade($bTest = False)

	; if it's an upgrade, will click on the upgrade, in builders menu
	;Click(180 + $g_iQuickMISX, 80 + $g_iCurrentLineOffset)
	;If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return
	;If Not $g_bRunState Then Return

	; check if any wrong click by verifying the presence of the Upgrade button (the hammer)
	Local $aUpgradeButton = findButton("Upgrade", Default, 1, True)
	If Not(IsArray($aUpgradeButton) And UBound($aUpgradeButton, 1) = 2) Then
		SetLog("No upgrade here... Wrong click, looking next...", $COLOR_WARNING)
		;$g_iNextLineOffset = $g_iCurrentLineOffset -> not necessary finally, but in case, I keep lne commented
		$g_iNextLineOffset = $g_iCurrentLineOffset
		Click(820, 38, 1) ; exit from Shop
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
					$aUpgradeButton = findButton("THWeapon", Default, 1, True)
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
		;24 is TH weapon
		Case "WorkShop"
			$bMustIgnoreUpgrade = True ;hardcoded temporary
		Case Else
			$bMustIgnoreUpgrade = False
	EndSwitch

	; check if the upgrade name is on the list of upgrades that must be ignored
	If $bMustIgnoreUpgrade = True Then
		SetLog($g_aUpgradeNameLevel[1] & " : This upgrade must be ignored, looking next...", $COLOR_WARNING)
		$g_iNextLineOffset = $g_iCurrentLineOffset
		Return False
	EndIf

	; if upgrade not to be ignored, click on the Upgrade button to open Upgrade window
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
		ClickAway("Right")
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
		ClickAway("Right")
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
			ClickAway("Right")
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
	ClickAway("Right")
	
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

;Open the Upgrade Window and check if is OK
Func ClickMainBuilder($bTest = False, $bFirstOpen = False)

	; Debug Stuff
	Local $sDebugText = ""
	Local Const $Debug = False
	Local Const $Screencap = True
	
	VillageReport(True, True) ;check if we have available builder
	
	; check if builder head is clickable
	If Not (_ColorCheck(_GetPixelColor(275, 15, True), "F5F5ED", 20) = True) Then
		SetLog("Unable to find the Builder menu button... Exiting Auto Upgrade...", $COLOR_ERROR)
		Return
	EndIf
	
	If $bTest Then $g_iFreeBuilderCount = 1
	;Check if there is a free builder for Auto Upgrade
	If ($g_iFreeBuilderCount - ($g_bAutoUpgradeWallsEnable And $g_bUpgradeWallSaveBuilder ? 1 : 0)) <= 0 Then
		SetLog("No builder available. Skipping Auto Upgrade!", $COLOR_WARNING)
		Return False
	EndIf
	
	; open the builders menu
	Click(295, 30)
	If _Sleep(2000) Then Return
	; Let's verify if the Builder Window opened
	If (_ColorCheck(_GetPixelColor(422, 73, True), "fdfefd", 20) = True) Then
		If $g_bScrollFirst And $bFirstOpen Then ;skip first page on builder menu
			Local $Yscroll =  ($g_iTotalBuilderCount - $g_iFreeBuilderCount) * 28
			ClickDrag(333, 100, 333, 400, 500) ;drag to bottom
			If _Sleep(1500) Then Return
			ClickDrag(300, 140 + $Yscroll, 300, 90,500)
			If _Sleep(1500) Then Return
		EndIf
		SetLog("Open Upgrade Window, Success", $COLOR_SUCCESS)
		Return True
	Else
		SetLog("Upgrade Window didn't opened", $COLOR_DEBUG)
	EndIf
	Return False
EndFunc ;==>ClickMainBuilder

Func GetUpgradeIcon($x, $y, $x1, $y1, $directory, $Name = "Elixir", $Screencap = True, $Debug = False)
	SetDebugLog("GetUpgradeIcon(" & $x &"," & $y & "," & $x1 & "," & $y1 & "," & $directory & "," & $Name, $COLOR_ORANGE)
	; [0] = x position , [1] y postion , [2] Gold, Elixir or New
	Local $aResult[3] = [-1, -1, ""]
	Switch $Name
		Case "Elixir"
			$directory = $g_sImgAUpgradeIconElixir
		Case "Gold"
			$directory = $g_sImgAUpgradeIconGold
		Case "DE"
			$directory = $g_sImgAUpgradeIconDE
	EndSwitch
	If QuickMIS("BC1", $directory, $x, $y, $x1, $y1, $Screencap, $Debug) Then
		; Correct positions to Check Green 'New' Building word
		Local $iYoffset = $y + $g_iQuickMISY - 15, $iY1offset = $y + $g_iQuickMISY + 7
		Local $iX = 200, $iX1 = $g_iQuickMISX + $x
		; Store the values
		$aResult[0] = $g_iQuickMISX + $x
		$aResult[1] = $g_iQuickMISY + $y
		$aResult[2] = $Name
		; The pink/salmon color on zeros
		If QuickMIS("BC1", $g_sImgAutoUpgradeNoRes, $aResult[0], $iYoffset, $aResult[0] + 100, $iY1offset, True, $Debug) Then
			; Store new values
			$aResult[2] = "NoResources"
			SetLog("Not Enough Resource for " & $Name & " Building", $COLOR_INFO)
			Return $aResult
		EndIf
		; Proceeds with 'New' detection
		If QuickMIS("BC1", $g_sImgAutoUpgradeNew, $iX, $iYoffset, $iX1, $iY1offset, True, $Debug) Then
			; Store new values
			$aResult[0] = $g_iQuickMISX + $iX + 35
			$aResult[1] = $g_iQuickMISY + $iYoffset
			$aResult[2] = "New"
			SetLog("Found New " & $Name & " Building", $COLOR_INFO)
		EndIf
	EndIf
	SetDebugLog("Result: " & $aResult[0] & "|" & $aResult[1] & "|" & $aResult[2], $COLOR_ORANGE)
	Return $aResult
EndFunc ;==>GetUpgradeIcon

Func AUNewBuildings($x, $y, $bTest = False)

	Local $Screencap = True, $Debug = $bTest
	Click($x, $y, 1)
	If _Sleep(3000) Then Return

	;Search the arrow
	Local $ArrowCoordinates = decodeSingleCoord(findImage("BBNewBuildingArrow", $g_sImgArrowNewBuilding, GetDiamondFromRect("40,200,860,600"), 1, True, Default))
	If UBound($ArrowCoordinates) > 1 Then
		;Check if its wall or not (wall should skip)
		If $g_bSkipWallPlacingOnBB Then
			If QuickMIS("BC1", $g_sImgisWall, $ArrowCoordinates[0] - 150, $ArrowCoordinates[1] - 50, $ArrowCoordinates[0], $ArrowCoordinates[1], $Screencap, $Debug) Then
				SetLog("New Building is Wall!, Cancelling...", $COLOR_INFO)
				Click(820, 38, 1) ; exit from Shop
				If _Sleep(2000) Then Return
				ClickMainBuilder($bTest)
				Return False
			EndIf
		EndIf
		Click($ArrowCoordinates[0] - 50, $ArrowCoordinates[1] + 50)
		If _Sleep(2000) Then Return 
		; Lets search for the Correct Symbol on field
		If QuickMIS("BC1", $g_sImgAUpgradeIconYes, 100, 100, 740, 620, $Screencap, $Debug) Then
			If Not $bTest Then
				Click($g_iQuickMISX + 100, $g_iQuickMISY + 100, 1)
			EndIf
			SetLog("Placed a new Building on Main Village! [" & $g_iQuickMISX + 100 & "," & $g_iQuickMISY + 100 & "]", $COLOR_SUCCESS)
			If _Sleep(1000) Then Return
			If QuickMIS("BC1", $g_sImgAUpgradeIconYes, 100, 100, 740, 620, $Screencap, $Debug) Then
				Click($g_iQuickMISX + 100, $g_iQuickMISY + 100, 1)
			EndIf
			; Lets check if exist the [x] , Some Buildings like Traps when you place one will give other to place automaticly!
			If QuickMIS("BC1", $g_sImgAUpgradeIconNo, 100, 100, 740, 620, $Screencap, $Debug) Then
				Click($g_iQuickMISX + 100, $g_iQuickMISY + 100, 1)
			EndIf
			Return True
		Else
			If QuickMIS("BC1", $g_sImgAUpgradeIconNo, 100, 100, 740, 620, $Screencap, $Debug) Then
				SetLog("Sorry! Wrong place to deploy a new building on Main Village! [" & $g_iQuickMISX + 100 & "," & $g_iQuickMISY + 100 & "]", $COLOR_ERROR)
				Click($g_iQuickMISX + 100, $g_iQuickMISY + 100, 1)
			Else
				SetLog("Error on Undo symbol!", $COLOR_ERROR)
			EndIf
			Return True
		EndIf
	Else
		SetLog("Cannot find Orange Arrow", $COLOR_ERROR)
		Click(820, 38, 1) ; exit from Shop
	EndIf

	Return False
EndFunc ;==>AUNewBuildings

Func UpgradeNewBuilding($bTest = False)
	Local $bDebug = $bTest
	Local $bScreencap = True

	If QuickMIS("BC1", $g_sImgAUpgradeGreenZone, 320, 70, 520, 220) Then ;Top
		SetLog("Found GreenZone, On Top Region", $COLOR_SUCCESS)
		ZoomIn("Top")
	ElseIf QuickMIS("BC1", $g_sImgAUpgradeGreenZone, 130, 270, 280, 390) Then ;Left
		SetLog("Found GreenZone, On Left Region", $COLOR_SUCCESS)
		ZoomIn("Left")
	ElseIf QuickMIS("BC1", $g_sImgAUpgradeGreenZone, 340, 460, 520, 560) Then ;Bottom
		SetLog("Found GreenZone, On Bottom Region", $COLOR_SUCCESS)
		ZoomIn("Bottom")
	ElseIf QuickMIS("BC1", $g_sImgAUpgradeGreenZone, 560, 270, 710, 400) Then ;Right
		SetLog("Found GreenZone, On Right Region", $COLOR_SUCCESS)
		ZoomIn("Bottom")
	Else
		SetLog("GreenZone for Placing new Building Not Found", $COLOR_DEBUG)
	Endif
		
	If Not ClickMainBuilder($bTest, True) Then Return False
	If _Sleep(500) Then Return
	For $z = 0 To 1 ;for do scroll 2 times
		If $g_bRestart Then Return False
		Local $x = 180, $y = 80, $x1 = 450, $y1 = 108, $step = 28
		For $i = 0 To 8
			If $g_bRestart Then Return False
			If QuickMIS("BC1", $g_sImgAUpgradeZero, $x, $y, $x1, $y1) Then
				SetLog("[" & $i & "] Possible upgrade found!", $COLOR_SUCCESS)
				If QuickMIS("NX",$g_sImgAUpgradeObst, $x, $y, $x1, $y1) <> "none" Then
					SetLog("[" & $i & "] New Building found!", $COLOR_SUCCESS)
					If AUNewBuildings($g_iQuickMISX + $x, $g_iQuickMISY + $y, $bTest) Then 
						ZoomOut()
						ClickAway()
						Return True
					EndIf
				EndIf
			Else
				SetLog("[" & $i & "] Not Enough Resource", $COLOR_INFO)
			EndIf
			$y += $step
			$y1 += $step
		Next
		ClickDrag(333, $y, 333, 75, 800);do scroll down
		If _Sleep(500) Then Return
	Next
	ZoomOut()
	ClickAway()
	Return False
EndFunc ;==>FindNewBuilding

