#include-once
Func CollectCCGold($bTest = False)
	If Not $g_bChkEnableCollectCCGold Then Return
	SetLog("Start Collecting Clan Capital Gold", $COLOR_INFO)
	ClickAway()
	ZoomOut() ;ZoomOut first
	If QuickMIS("BC1", $g_sImgCCGoldCollect, 250, 550, 400, 670) Then
		Click($g_iQuickMISX, $g_iQuickMISY + 20)
		For $i = 1 To 5
			SetDebugLog("Waiting for Forge Window #" & $i, $COLOR_ACTION)
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 710, 150, 760, 190) Then
				ExitLoop
			EndIf
			_Sleep(500)
		Next
		Local $aCollect = QuickMIS("CNX", $g_sImgCCGoldCollect, 120, 340, 740, 410)
		If IsArray($aCollect) And UBound($aCollect) > 0 Then
			SetLog("Collecting " & UBound($aCollect) & " Clan Capital Gold", $COLOR_INFO)
			For $i = 0 To UBound($aCollect) - 1
				If Not $bTest Then 
					Click($aCollect[$i][1], $aCollect[$i][2]) ;Click Collect
				Else
					SetLog("Test Only, Should Click on [" & $aCollect[$i][1] & "," & $aCollect[$i][2] & "]")
				EndIf
				_Sleep(500)
			Next
		EndIf
		_Sleep(800)
		Click($g_iQuickMISX, $g_iQuickMISY) ;Click close button
		SetLog("Clan Capital Gold collected successfully!", $COLOR_SUCCESS)
	Else
		SetLog("No available Clan Capital Gold to be collected!", $COLOR_INFO)
		Return
	EndIf
	If _Sleep($DELAYCOLLECT3) Then Return
EndFunc

Func ClanCapitalReport()
	$g_iLootCCGold = getOcrAndCapture("coc-ms", 670, 17, 160, 25)
	$g_iLootCCMedal = getOcrAndCapture("coc-ms", 670, 70, 160, 25)
	GUICtrlSetData($g_lblCapitalGold, $g_iLootCCGold)
	GUICtrlSetData($g_lblCapitalMedal, $g_iLootCCMedal)
EndFunc

Func OpenForgeWindow()
	Local $bRet = False
	If QuickMIS("BC1", $g_sImgForgeHouse, 260, 570, 340, 660) Then 
		Click($g_iQuickMISX + 10, $g_iQuickMISY + 10)
		For $i = 1 To 5
			SetDebugLog("Waiting for Forge Window #" & $i, $COLOR_ACTION)
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 710, 150, 760, 190) Then
				$bRet = True
				ExitLoop
			EndIf
			_Sleep(600)
		Next
	EndIf
	Return $bRet
EndFunc

Func WaitStartCraftWindow()
	Local $bRet = False
	For $i = 1 To 5
		SetDebugLog("Waiting for StartCraft Window #" & $i, $COLOR_ACTION)
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 620, 180, 670, 220) Then
			$bRet = True
			ExitLoop
		EndIf
		_Sleep(600)
	Next
	If Not $bRet Then SetLog("StartCraft Window does not open", $COLOR_ERROR)
	Return $bRet
EndFunc

Func ForgeClanCapitalGold($bTest = False)
	ZoomOut()
	Local $aForgeType[5] = [$g_bChkEnableForgeGold, $g_bChkEnableForgeElix, $g_bChkEnableForgeDE, $g_bChkEnableForgeBBGold, $g_bChkEnableForgeBBElix]
	Local $bForgeEnabled = False
	Local $iBuilderToUse = $g_iCmbForgeBuilder + 1
	For $i In $aForgeType ;check for every option enabled
		If $i = True Then 
			$bForgeEnabled = True
			ExitLoop
		EndIf
	Next
	If Not $bForgeEnabled Then Return
	If Not $g_bRunState Then Return
	SetLog("Checking for Forge ClanCapital Gold", $COLOR_INFO)
	
	getBuilderCount(True) ;check if we have available builder
	Local $iWallReserve = $g_bUpgradeWallSaveBuilder ? 1 : 0
	If $g_iFreeBuilderCount - $iWallReserve - ReservedBuildersForHeroes() < 1 Then ;check builder reserve on wall and hero upgrade
		SetLog("FreeBuilder=" & $g_iFreeBuilderCount & ", Reserved (ForHero=" & $g_iHeroReservedBuilder & " ForWall=" & $iWallReserve & ")", $COLOR_INFO)
		SetLog("Not Have builder, exiting", $COLOR_INFO)
		Return
	EndIf
	
	Local $iCurrentGold = getResourcesMainScreen(701, 23) ;get current Gold
	Local $iCurrentElix = getResourcesMainScreen(701, 74) ;get current Elixir
	Local $iCurrentDE = getResourcesMainScreen(720, 120) ;get current Dark Elixir
	If Not $g_bRunState Then Return
	If Not OpenForgeWindow() Then 
		SetLog("Forge Window not Opened, exiting", $COLOR_ACTION)
		Return
	EndIf
	
	If Not $g_bRunState Then Return
	SetLog("Number of Enabled builder for Forge = " & $iBuilderToUse, $COLOR_ACTION)
	If $iBuilderToUse > 3 Then ClickDrag(720, 315, 600, 315)
	
	Local $iBuilder = 0
	Local $iActiveForge = QuickMIS("CNX", $g_sImgActiveForge, 120, 230, 740, 410) ;check if we have forge in progress
	If IsArray($iActiveForge) And UBound($iActiveForge) > 0 Then
		If UBound($iActiveForge) >= $iBuilderToUse Then
			SetLog("We have All Builder Active for Forge", $COLOR_INFO)
			ClickAway()
			Return
		EndIf
		For $i = 0 To UBound($iActiveForge) - 1
			$iBuilder += 1
		Next
	EndIf
	
	SetLog("Already active builder Forging = " & $iBuilder, $COLOR_ACTION)
	If Not $g_bRunState Then Return
	For $builder = $iBuilder To $iBuilderToUse - 1
		Local $aCraft = QuickMIS("CNX", $g_sImgCCGoldCraft, 120, 230, 740, 410)
		_ArraySort($aCraft)
		Local $aResource[5][2] = [["Gold", 240], ["Elixir", 330], ["Dark Elixir", 425], ["Builder Base Gold", 520], ["Builder Base Elixir", 610]]
		If IsArray($aCraft) And UBound($aCraft) > 0 Then
			Click($aCraft[$i][1], $aCraft[$i][2])
			_Sleep(500)
			If Not WaitStartCraftWindow() Then Return
			For $i = 0 To UBound($aForgeType) -1
				If $aForgeType[$i] = True Then ;check if ForgeType Enabled
					SetLog("Try Forge using " & $aResource[$i][0], $COLOR_INFO)
					Click($aResource[$i][1], 275)
					_Sleep(1000)
					Local $cost = getOcrAndCapture("coc-forge", 240, 350, 160, 25, True)
					Local $gain = getOcrAndCapture("coc-forge", 528, 365, 100, 25, True)
					If $cost = "" Then 
						SetLog("Not enough resource to forge with" & $aResource[$i][0], $COLOR_INFO)
						ContinueLoop
					EndIf
					Local $bSaveToForge = False
					Switch $aResource[$i][0]
						Case "Gold"
							If Number($cost) + 200000 <= $iCurrentGold Then $bSaveToForge = True
						Case "Elixir"
							If Number($cost) + 200000 <= $iCurrentElix Then $bSaveToForge = True
						Case "Dark Elixir"
							If Number($cost) + 200000 <= $iCurrentDE Then $bSaveToForge = True
					EndSwitch
					SetLog("Forge Cost:" & $cost & ", gain Capital Gold:" & $gain, $COLOR_ACTION)
					If Not $bSaveToForge Then 
						SetLog("Not save to forge with" & $aResource[$i][0] & ", not enough resource to save", $COLOR_INFO)
						ContinueLoop
					EndIf
					
					If Not $bTest Then 
						Click(430, 450)
						SetLog("Succes Forge with " & $aResource[$i][0] & ", will gain " & $gain & " Capital Gold", $COLOR_SUCCESS)
					Else
						SetLog("Only Test, should click on [430,450]", $COLOR_INFO)
						ClickAway()
					EndIf
					ContinueLoop 2 ;hit here means, successfully forge, so check if next builder is enabled for forge
				EndIf
				_Sleep(1000)
				If Not $g_bRunState Then Return
			Next
		EndIf
		ClickAway()
	Next
	_Sleep(1000)
	ClickAway()
EndFunc

Func SwitchToClanCapital()
	Local $bRet = False
	If QuickMIS("BC1", $g_sImgAirShip, 200, 520, 400, 660) Then 
		Click($g_iQuickMISX, $g_iQuickMISY)
		For $i = 1 To 10
			SetDebugLog("Waiting for Travel to Clan Capital Map #" & $i, $COLOR_ACTION)
			If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then
				$bRet = True
				ExitLoop
			EndIf
			_Sleep(800)
		Next
	EndIf
	Return $bRet
EndFunc

Func IsCCBuilderMenuOpen()
	Local $bRet = False
	If QuickMIS("BC1", $g_sImgResourceCC, 400, 100, 550, 360) Then $bRet = True
	Return $bRet
EndFunc

Func ClickCCBuilder()
	Local $bRet = False
	If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then 
		Click($g_iQuickMISX, $g_iQuickMISY)
		_Sleep(600)
		If IsCCBuilderMenuOpen() Then $bRet = True
	EndIf
	Return $bRet
EndFunc

Func FindCCExistingUpgrade()
	Local $aResult[0][3], $name[2]
	Local $aIgnore[4] = ["Groove", "Tree", "Forest", "Campsite"]
	Local $aUpgrade = QuickMIS("CNX", $g_sImgResourceCC, 400, 100, 550, 360)
	If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
		For $i = 0 To UBound($aUpgrade) - 1
			$name = getBuildingName($aUpgrade[$i][1] - 200, $aUpgrade[$i][2] - 8)
			If $g_bChkAutoUpgradeCCIgnore Then 
				For $y In $aIgnore
					If StringInStr($name[0], $y) Then 
						SetDebugLog("Upgrade for " & $name[0] & " Ignored, Skip!!", $COLOR_ACTION)
						ContinueLoop 2 ;skip this upgrade, looking next 
					EndIf
				Next
			EndIf
			;Local $name = getOcrAndCapture("coc-buildermenu-name", $aUpgrade[$i][1] - 250, $aUpgrade[$i][2] - 8, 200, 25, True)
			_ArrayAdd($aResult, $name[0] & "|" & $aUpgrade[$i][1] & "|" &  $aUpgrade[$i][2])
		Next
	EndIf
	Return $aResult
EndFunc

Func WaitUpgradeButton()
	Local $aRet[3]
	For $i = 1 To 10
		SetDebugLog("Waiting for Upgrade Button #" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgCCUpgradeButton, 300, 520, 600, 660) Then
			$aRet[0] = True
			$aRet[1] = $g_iQuickMISX
			$aRet[2] = $g_iQuickMISY
			ExitLoop
		EndIf
		_Sleep(800)
	Next
	Return $aRet
EndFunc

Func WaitCCUpgradeWindow()
	Local $bRet = False
	For $i = 1 To 5
		SetDebugLog("Waiting for Upgrade Window #" & $i, $COLOR_ACTION)
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 680, 99, 730, 140) Then
			$bRet = True
			ExitLoop
		EndIf
		_Sleep(600)
	Next
	If Not $bRet Then SetLog("Upgrade Window does not open", $COLOR_ERROR)
	Return $bRet
EndFunc

Func SwitchToMainVillage()
	Local $bRet = False
	For $i = 1 To 10
		If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then
			Click(60, 610) ;Click ReturnHome/Map
			_Sleep(2000)
		EndIf
		_Sleep(800)
		If isOnMainVillage() Then 
			$bRet = True
			ExitLoop
		EndIf
	Next
	ZoomOut()
	Return $bRet
EndFunc

Func AutoUpgradeCC($bTest = False)
	If Not $g_bChkEnableAutoUpgradeCC Then Return
	SetLog("Checking Clan Capital AutoUpgrade", $COLOR_INFO)
	ZoomOut() ;ZoomOut first
	If Not SwitchToClanCapital() Then Return
	_Sleep(1000)
	ClanCapitalReport()
	If Number($g_iLootCCGold) = 0 Then 
		SetLog("No Capital Gold to spend to Contribute", $COLOR_INFO)
		SwitchToMainVillage()
		Return
	EndIf
	If Not $g_bRunState Then Return
	If Not ClickCCBuilder() Then 
		SetLog("Fail to open Builder Menu", $COLOR_ERROR)
		Return
	EndIf
	_Sleep(500)
	Local $aUpgrade = FindCCExistingUpgrade() ;Find on Capital Map, should only find currently on progress building
	If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
		For $i = 0 To UBound($aUpgrade) - 1
			SetLog("Upgrade: " & $aUpgrade[$i][0])
			Click($aUpgrade[$i][1], $aUpgrade[$i][2])
			Local $aRet = WaitUpgradeButton()
			If Not $aRet[0] Then 
				SetLog("Upgrade Button Not Found", $COLOR_ERROR)
				Return
			Else
				Click($aRet[1], $aRet[2])
				If Not WaitCCUpgradeWindow() Then Return
				If Not $bTest Then 
					Click(640, 520) ;Click Contribute
				Else
					SetLog("Only Test, should click on [640, 520]", $COLOR_INFO)
					ClickAway()
					SwitchToMainVillage()
				Return
				EndIf
				_Sleep(500)
				ClickAway()
			EndIf
			ClanCapitalReport()
			If Number($g_iLootCCGold) = 0 Then 
				SwitchToMainVillage()
				Return
			EndIf
		Next
	EndIf
	
	#cs ;not completed yet
	ClanCapitalReport()
	Local $aMapCoord[7][3] = [["Capital Peak", 400, 225], ["Barbarian Camp", 530, 340], ["Wizard Valley", 410, 400], ["Balloon Lagoon", 300, 490], _
								["Builder's Workshop", 490, 525], ["Dragon Cliffs", 630, 465], ["Golem Quarry", 185, 590]]
	
	If Number($g_iLootCCGold) > 0 Then
		SetLog("Upgrade Attempt from Clan Capital Map, not succeed", $COLOR_DEBUG)
		For $i = 0 To UBound($aMapCoord) - 1
			SetLog("Go to " & $aMapCoord[$i][0] & " to Check Upgrades", $COLOR_ACTION)
			Click($aMapCoord[$i][1], $aMapCoord[$i][2])
			If Not WaitForMap($aMapCoord[$i][0]) Then 
				SetLog("Going to " & $aMapCoord[$i][0] & " Failed", $COLOR_ERROR)
				Return
			EndIf
			If Not ClickCCBuilder() Then Return
		Next
	EndIf
	#ce
EndFunc 


Func WaitForMap($sMapName = "Capital Peak")
	Local $bRet
	For $i = 1 To 5
		SetDebugLog("Waiting for " & $sMapName & "#" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then ExitLoop
		_Sleep(800)
	Next
	Local $Text = getOcrAndCapture("coc-mapname", $g_iQuickMISX, $g_iQuickMISY - 8, 230, 25)
	SetDebugLog("$Text: " & $Text)
	If StringInStr($sMapName, $Text) Then 
		SetDebugLog("Match with: " & $sMapName)
		$bRet = True
	EndIf
	Return $bRet
EndFunc