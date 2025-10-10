#include-once
Func CollectCCGold($bTest = False)
	If Not $g_bChkEnableCollectCCGold Then Return
	Local $bWindowOpened = False
	Local $aCollect, $iBuilderToUse = $g_iCmbForgeBuilder + 1
	SetLog("Check for Collecting Clan Capital Gold", $COLOR_INFO)
	ClickAway("Right")
	ZoomOut() ;ZoomOut first
	
	;handle for turtorial
	If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 250, 520, 400, 670) Then
		SetLog("Tutorial Arrow detected, click it!", $COLOR_ACTION)
		Click($g_iQuickMISX, $g_iQuickMISY + 10)
		If _Sleep(8000) Then Return
		For $i = 1 To 3
			SetLog("Waiting Tutorial and Forge window open #" & $i, $COLOR_ACTION)
			If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then
				Click($g_iQuickMISX, $g_iQuickMISY)
			EndIf
			If _Sleep(3000) Then Return
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 710, 160, 760, 205) Then
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(2000) Then Return
				ExitLoop
			EndIf
		Next
		SetLog("Failed doing Clan Capital Tutorial", $COLOR_DEBUG2)
	EndIf

	If QuickMIS("BC1", $g_sImgCCGoldCollect, 250, 550, 400, 670) Then
		Click($g_iQuickMISX, $g_iQuickMISY + 20)
		For $i = 1 To 5
			SetDebugLog("Waiting for Forge Window #" & $i, $COLOR_ACTION)
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 768, 136, 812, 179) Then
				$bWindowOpened = True
				ExitLoop
			EndIf
			If _Sleep(500) Then Return
		Next

		If $bWindowOpened Then
			$aCollect = QuickMIS("CNX", $g_sImgCCGoldCollect, 120, 340, 740, 410)
			If IsArray($aCollect) And UBound($aCollect) > 0 Then
				SetLog("Collecting " & UBound($aCollect) & " Clan Capital Gold", $COLOR_INFO)
				For $i = 0 To UBound($aCollect) - 1
					If Not $bTest Then
						Click($aCollect[$i][1], $aCollect[$i][2]) ;Click Collect
					Else
						SetLog("Test Only, Should Click on [" & $aCollect[$i][1] & "," & $aCollect[$i][2] & "]")
					EndIf
					If _Sleep(500) Then Return
				Next
			EndIf
			If _Sleep(1000) Then Return

			If $iBuilderToUse > 3 Then
				SetLog("Checking 4th Builder forge result", $COLOR_INFO)
				ClickDrag(720, 315, 600, 315, 500)
				$aCollect = QuickMIS("CNX", $g_sImgCCGoldCollect, 500, 350, 780, 420)
				If IsArray($aCollect) And UBound($aCollect) > 0 Then
					SetLog("Collecting " & UBound($aCollect) & " Clan Capital Gold", $COLOR_INFO)
					For $i = 0 To UBound($aCollect) - 1
						If Not $bTest Then
							Click($aCollect[$i][1], $aCollect[$i][2]) ;Click Collect
						Else
							SetLog("Test Only, Should Click on [" & $aCollect[$i][1] & "," & $aCollect[$i][2] & "]")
						EndIf
						If _Sleep(500) Then Return
					Next
				EndIf
			EndIf
			If _Sleep(500) Then Return
			$g_iLootCCGold = ReadCCGold()
			SetLog("CC Gold = " & $g_iLootCCGold, $COLOR_INFO)
			Click($g_iQuickMISX, $g_iQuickMISY) ;Click close button
			SetLog("Clan Capital Gold collected successfully!", $COLOR_SUCCESS)
		EndIf
	Else
		SetLog("No available Clan Capital Gold to be collected!", $COLOR_DEBUG2)
		Return
	EndIf
	ClickAway("Right")
	If _Sleep(500) Then Return
EndFunc

Func ReadCCGold()
	Local $iRet = 0, $aRet
	Local $sCCGold = getOcrAndCapture("coc-ccgold", 285, 472, 160, 25, True)
	$aRet = StringSplit($sCCGold, "#", $STR_NOCOUNT)
	If Ubound($aRet) = 2 Then
		$iRet = $aRet[0]
	EndIf
	Return $iRet
EndFunc

Func ClanCapitalReport($SetLog = True)
	$g_iLootCCGold = StringReplace(getOcrAndCapture("coc-ms", 710, 17, 100, 25, True), "-", "")
	$g_iLootCCMedal = StringReplace(getOcrAndCapture("coc-ms", 710, 70, 95, 25, True), "-", "")
	GUICtrlSetData($g_lblCapitalGold, $g_iLootCCGold)
	GUICtrlSetData($g_lblCapitalMedal, $g_iLootCCMedal)

	If $SetLog Then
		SetLog("Capital Report", $COLOR_INFO)
		SetLog("[Gold]:" & $g_iLootCCGold & " [Medal]:" & $g_iLootCCMedal, $COLOR_SUCCESS)
	EndIf

	Local $sRaidText = getOcrAndCapture("coc-mapname", 773, 613, 50, 30)
	If $sRaidText = "Raid" Then
		If $SetLog Then SetLog("Raid Weekend is Available", $COLOR_INFO)
		Local $iAttack = getOcrAndCapture("coc-mapname", 780, 545, 20, 30)
		If $SetLog Then SetLog("You have " & $iAttack & " available attack", $COLOR_SUCCESS)
		If Number($g_iLootCCGold) > 0 Then
			If _Sleep(8000) Then Return
		EndIf
		If QuickMis("BC1", $g_sImgCCRaid, 360, 450, 500, 500) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(5000) Then Return
			SkipChat()
			SwitchToCapitalMain()
		EndIf
		;If Number($iAttack) > 0 Then NotifyPushToTelegram($g_sProfileCurrentName & " have " & $iAttack & " Available attack on Capital Raid Weekend")
	EndIf

	;If $g_bChkStartWeekendRaid Then StartRaidWeekend()
EndFunc

Func StartRaidWeekend()
	If _ColorCheck(_GetPixelColor(835, 640, True), Hex(0x85B525, 6), 20) Then ;Check Green Color on StartRaid Button
		SetDebugLog("ClanCapital: Found Start Raid Weekend Button")
		Click(800, 620) ;Click start Raid Button
		Local $bWindowOpened = False
		For $i = 1 To 5
			If _Sleep(1000) Then Return
			SetDebugLog("Waiting for Start Raid Window #" & $i, $COLOR_ACTION)
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 645, 255, 700, 310 ) Then
				$bWindowOpened = True
				ExitLoop
			EndIf
		Next
		If Not $bWindowOpened Then
			ClickAway("Right")
			Return
		EndIf
		If $bWindowOpened Then
			If _ColorCheck(_GetPixelColor(433, 543, True), Hex(0xFF8D29, 6), 20) Then ;Check Orange button on StartRaid Window
				SetLog("Starting Raid Weekend", $COLOR_INFO)
				Click(430, 520) ;Click Start Raid Button
				If _Sleep(1000) Then Return
				ClickAway("Right")
				SwitchToMainVillage("Start Weekend Raid")
				SwitchToClanCapital()
			Else
				SetLog("Start Raid Button not Available", $COLOR_ACTION)
				ClickAway("Right")
				Return
			EndIf
		EndIf
	EndIf
EndFunc

Func OpenForgeWindow()
	Local $bRet = False
	If QuickMIS("BC1", $g_sImgForgeHouse, 260, 560, 460, 660) Then
		Click($g_iQuickMISX + 10, $g_iQuickMISY + 10)
		For $i = 1 To 5
			SetDebugLog("Waiting for Forge Window #" & $i, $COLOR_ACTION)
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 715, 160, 760, 200) Then
				$bRet = True
				ExitLoop
			EndIf
			If _Sleep(600) Then Return
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
		If _Sleep(600) Then Return
	Next
	If Not $bRet Then SetLog("StartCraft Window does not open", $COLOR_ERROR)
	Return $bRet
EndFunc

Func RemoveDupCNX(ByRef $arr, $sortBy = 1, $distance = 10)
	Local $atmparray[0][4]
	Local $tmpCoord = 0
	_ArraySort($arr, 0, 0, 0, $sortBy) ;sort by 1 = , 2 = y
	For $i = 0 To UBound($arr) - 1
		SetDebugLog("SortBy:" & $arr[$i][$sortBy])
		SetDebugLog("tmpCoord:" & $tmpCoord)
		If $arr[$i][$sortBy] >= $tmpCoord + $distance Then
			_ArrayAdd($atmparray, $arr[$i][0] & "|" & $arr[$i][1] & "|" & $arr[$i][2] & "|" & $arr[$i][3])
			$tmpCoord = $arr[$i][$sortBy] + $distance
		Else
			SetDebugLog("Skip this dup: " & $arr[$i][$sortBy] & " is near " & $tmpCoord, $COLOR_INFO)
			ContinueLoop
		EndIf
	Next
	$arr = $atmparray
	SetDebugLog(_ArrayToString($arr))
EndFunc

Func ForgeClanCapitalGold($bTest = False)
	
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
	
	SetLog("Checking for Forge ClanCapital Gold", $COLOR_ACTION)
	ClickAway("Right")
	ZoomOut()
	getBuilderCount(True) ;check if we have available builder
	If $bTest Then $g_iFreeBuilderCount = $iBuilderToUse
	Local $iWallReserve = $g_bUpgradeWallSaveBuilder ? 1 : 0
	If $g_iFreeBuilderCount - $iWallReserve - ReservedBuildersForHeroes() < 1 Then ;check builder reserve on wall and hero upgrade
		SetLog("FreeBuilder=" & $g_iFreeBuilderCount & ", Reserved (ForHero=" & $g_iHeroReservedBuilder & " ForWall=" & $iWallReserve & ")", $COLOR_INFO)
		SetLog("Not Have builder, exiting", $COLOR_DEBUG2)
		Return
	EndIf

	Local $iCurrentGold = getResourcesMainScreen(690, 23) ;get current Gold
	Local $iCurrentElix = getResourcesMainScreen(690, 74) ;get current Elixir
	Local $iCurrentDE = getResourcesMainScreen(690, 120) ;get current Dark Elixir
	If Not $g_bRunState Then Return
	If Not OpenForgeWindow() Then
		SetLog("Forge Window not Opened, exiting", $COLOR_DEBUG2)
		Return
	EndIf

	If $iBuilderToUse > 3 Then ClickDrag(720, 315, 600, 315)
	If _Sleep(1000) Then Return

	If Not $g_bRunState Then Return
	SetLog("Number of Enabled builder for Forge = " & $iBuilderToUse, $COLOR_ACTION)
	If ($g_iTownHallLevel = 13 Or $g_iTownHallLevel = 12) And $iBuilderToUse = 4 Then
		SetLog("TH Level Allows 3 Builders For Forge", $COLOR_DEBUG)
		$iBuilderToUse = 3
	ElseIf $g_iTownHallLevel = 11 And $iBuilderToUse > 2 Then
		SetLog("TH Level Allows 2 Builders For Forge", $COLOR_DEBUG)
		$iBuilderToUse = 2
	ElseIf $g_iTownHallLevel < 11 And $iBuilderToUse > 1 Then
		SetLog("TH Level Allows Only 1 Builder For Forge", $COLOR_DEBUG)
		$iBuilderToUse = 1
	EndIf

	Local $iBuilder = 0
	Local $iActiveForge = QuickMIS("CNX", $g_sImgActiveForge, 120, 230, 740, 450) ;check if we have forge in progress
	RemoveDupCNX($iActiveForge)
	If IsArray($iActiveForge) And UBound($iActiveForge) > 0 Then
		_ArraySort($iActiveForge, 0, 0, 0, 1)
		If UBound($iActiveForge) >= $iBuilderToUse Then
			SetLog("We have All Builder Active for Forge", $COLOR_INFO)
			ClickAway("Right")
			Return
		EndIf
		$iBuilder = UBound($iActiveForge)
	EndIf

	SetLog("Already active builder Forging = " & $iBuilder, $COLOR_ACTION)
	If Not $g_bRunState Then Return
	Local $iBuilderToAssign = Number($iBuilderToUse) - Number($iBuilder)
	Local $aResource[5][2] = [["Gold", 240], ["Elixir", 330], ["Dark Elixir", 425], ["Builder Base Gold", 520], ["Builder Base Elixir", 610]]
	Local $aCraft = QuickMIS("CNX", $g_sImgCCGoldCraft, 120, 230, 740, 450)
	_ArraySort($aCraft, 0, 0, 0, 1) ;sort by column 1 (x coord)
	SetDebugLog("Count of Craft Button: " & UBound($aCraft))
	SetLog("Available Builder for forge = " & $iBuilderToAssign, $COLOR_INFO)
	If IsArray($aCraft) And UBound($aCraft) > 0 Then
		For $j = 1 To $iBuilderToAssign
			SetDebugLog("Proceed with builder #" & $j)
			Click($aCraft[$j-1][1], $aCraft[$j-1][2])
			If _Sleep(500) Then Return
			If Not WaitStartCraftWindow() Then
				ClickAway("Right")
				Return
			EndIf
			For $i = 0 To UBound($aForgeType) -1
				If $aForgeType[$i] = True Then ;check if ForgeType Enabled
					SetLog("Try Forge using " & $aResource[$i][0], $COLOR_INFO)
					Click($aResource[$i][1], 275)
					If _Sleep(1000) Then Return
					Local $cost = getOcrAndCapture("coc-forge", 240, 350, 160, 25, True)
					Local $gain = getOcrAndCapture("coc-forge", 528, 365, 100, 25, True)
					If $cost = "" Then
						SetLog("Not enough resource to forge with" & $aResource[$i][0], $COLOR_INFO)
						ContinueLoop
					EndIf
					Local $bSafeToForge = False
					Switch $aResource[$i][0]
						Case "Gold"
							If Number($cost) + 200000 <= $iCurrentGold Then $bSafeToForge = True
						Case "Elixir"
							If Number($cost) + 200000 <= $iCurrentElix Then $bSafeToForge = True
						Case "Dark Elixir"
							If Number($cost) + 10000 <= $iCurrentDE Then $bSafeToForge = True
					EndSwitch
					SetLog("Forge Cost:" & $cost & ", gain Capital Gold:" & $gain, $COLOR_ACTION)
					If Not $bSafeToForge Then
						SetLog("Not safe to forge with" & $aResource[$i][0] & ", not enough resource to save", $COLOR_INFO)
						ContinueLoop
					EndIf

					If Not $bTest Then
						Click(430, 450)
						SetLog("Succes Forge with " & $aResource[$i][0] & ", will gain " & $gain & " Capital Gold", $COLOR_SUCCESS)
						If _Sleep(1000) Then Return
						ExitLoop
					Else
						SetLog("Only Test, should click on [430,450]", $COLOR_INFO)
						ClickAway("Right")
					EndIf
				EndIf
				If _Sleep(1000) Then Return
				If Not $g_bRunState Then Return
			Next
		Next
	EndIf
	If _Sleep(1000) Then Return
	ClickAway("Right")
EndFunc

Func SwitchToClanCapital($bTest = False)
	Local $bRet = False
	If QuickMIS("BC1", $g_sImgAirShip, 200, 520, 400, 660) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		SetLog("Click AirShip at " & $g_iQuickMISX & "," & $g_iQuickMISY, $COLOR_ACTION)
		For $i = 1 To 10
			SetDebugLog("Waiting for Travel to Clan Capital Map #" & $i, $COLOR_ACTION)
			If IsProfileWindowOpen("SwitchToClanCapital") Then ;Next Raid Window
				SetLog("Found Next Raid Window covering map, close it!", $COLOR_INFO)
				Click(806, 98) ;Close Button
				If _Sleep(5000) Then Return
				SwitchToCapitalMain()
			EndIf
			If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then
				$bRet = True
				SetLog("Success Travel to Clan Capital Map", $COLOR_INFO)
				ExitLoop
			EndIf
			If _Sleep(2000) Then Return
		Next
	Else
		SetLog("Cannot Find AirShip", $COLOR_DEBUG2)
	EndIf
	
	If Not $bRet Then
		ClickAway("Right")
		SwitchToMainVillage("SwitchToClanCapital Failed")
	EndIf
	If $bRet Then ClanCapitalReport()
	Return $bRet
EndFunc

Func SwitchToCapitalMain()
	Local $bRet = False
	SetDebugLog("Going to Clan Capital", $COLOR_ACTION)
	For $i = 1 To 5
		If QuickMIS("BC1", $g_sImgCCMap, 15, 610, 115, 670) Then
			If $g_iQuickMISName = "MapButton" Then
				Click(60, 610) ;Click Map
				If _Sleep(3000) Then Return
			EndIf
		EndIf
		If QuickMIS("BC1", $g_sImgCCMap, 15, 610, 115, 670) Then
			If $g_iQuickMISName = "ReturnHome" Then
				SetDebugLog("We are on Clan Capital", $COLOR_ACTION)
				$bRet = True
				ExitLoop
			EndIf
		EndIf
		If _Sleep(500) Then Return
	Next
	Return $bRet
EndFunc

Func SwitchToMainVillage($caller = "Default")
	Local $bRet = False
	SetDebugLog("[" & $caller & "] Going To MainVillage", $COLOR_ACTION)
	For $i = 1 To 10
		If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then
			Click(60, 610) ;Click ReturnHome/Map
			If _Sleep(2000) Then Return
		EndIf
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 700, 120, 750, 160) Then ; check if we have window covering map, close it!
			Click($g_iQuickMISX, $g_iQuickMISY)
			SetLog("Found a window covering map, close it!", $COLOR_INFO)
			If _Sleep(2000) Then Return
			SwitchToCapitalMain()
		EndIf
		If _Sleep(800) Then Return
		If isOnMainVillage() Then
			$bRet = True
			ExitLoop
		EndIf
	Next
	ZoomOut(True)
	Return $bRet
EndFunc

Func WaitForMap($sMapName = "Capital Peak")
	Local $bRet
	For $i = 1 To 10
		SetDebugLog("Waiting for " & $sMapName & "#" & $i, $COLOR_ACTION)
		If _Sleep(2000) Then Return
		If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then ExitLoop
	Next
	Local $aMapName = StringSplit($sMapName, " ", $STR_NOCOUNT)
	Local $Text = getOcrAndCapture("coc-mapname", $g_iQuickMISX, $g_iQuickMISY - 12, 230, 35)
	SetDebugLog("$Text: " & $Text)
	For $i In $aMapName
		If StringInStr($Text, $i) Then
			SetDebugLog("Match with: " & $i)
			$bRet = True
			SetLog("We are on " & $sMapName, $COLOR_INFO)
			ExitLoop
		EndIf
	Next
	If Not $bRet Then
		SetDebugLog("checking with image")
		Local $ccMap = QuickMIS("CNX", $g_sImgCCMapName, $g_iQuickMISX, $g_iQuickMISY - 10, $g_iQuickMISX + 200, $g_iQuickMISY + 50)
		If IsArray($ccMap) And UBound($ccMap) > 0 Then
			Local $mapName = "dummyName"
			For $z = 0 To UBound($ccMap) - 1
				$mapName = String($ccMap[$z][0])
				For $i In $aMapName
					If StringInStr($mapName, $i) Then
						SetDebugLog("Match with: " & $i)
						$bRet = True
						SetLog("We are on " & $sMapName, $COLOR_INFO)
						ExitLoop
					EndIf
				Next
			Next
		EndIf
	EndIf
	Return $bRet
EndFunc

Func IsCCBuilderMenuOpen()
	Local $bRet = False
	Local $aBorder0[4] = [400, 73, 0x8C9CB6, 20]
	Local $aBorder1[4] = [400, 73, 0xC0C9D3, 20]
	Local $aBorder2[4] = [400, 73, 0xBEBFBC, 20]
	Local $aBorder3[4] = [400, 73, 0xFFFFFF, 20]

	Local $sTriangle
	If _CheckPixel($aBorder0, True) Or _CheckPixel($aBorder1, True) Or _CheckPixel($aBorder2, True) Or _CheckPixel($aBorder3, True) Then
		;SetDebugLog("Found Border Color: " & _GetPixelColor($aBorder0[0], $aBorder0[1], True), $COLOR_ACTION)
		$bRet = True ;got correct color for border
	Else
		SetDebugLog("Border Color Not Matched: " & _GetPixelColor($aBorder0[0], $aBorder0[1], True), $COLOR_ACTION)
	EndIf

	If Not $bRet Then ;lets re check if border color check not success
		$sTriangle = getOcrAndCapture("coc-buildermenu-cc", 350, 55, 200, 25)
		SetDebugLog("$sTriangle: " & $sTriangle)
		If $sTriangle = "^" Or $sTriangle = "~" Or $sTriangle = "@" Or $sTriangle = "#" Or $sTriangle = "%" Or $sTriangle = "$" Or $sTriangle = "&" Then $bRet = True
	EndIf
	SetDebugLog("IsCCBuilderMenuOpen : " & String($bRet))
	Return $bRet
EndFunc

Func ClickCCBuilder()
	Local $bRet = False
	If IsCCBuilderMenuOpen() Then $bRet = True
	If Not $bRet Then
		If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(1000) Then Return
			If IsCCBuilderMenuOpen() Then $bRet = True
		EndIf
	EndIf
	Return $bRet
EndFunc

Func FindCCExistingUpgrade()
	Local $aResult[0][3], $name[2] = ["", 0]
	Local $aUpgrade = QuickMIS("CNX", $g_sImgResourceCC, 400, 100, 550, 360)
	If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
		_ArraySort($aUpgrade, 0, 0, 0, 2) ;sort by Y coord
		For $i = 0 To UBound($aUpgrade) - 1
			$name = getCCBuildingName($aUpgrade[$i][1] - 250, $aUpgrade[$i][2] - 8)
			If $g_bChkAutoUpgradeCCWallIgnore Then ; Filter for wall
				If StringInStr($name[0], "Wall") Then
						SetLog("Upgrade for Wall Ignored, Skip!!", $COLOR_ACTION)
						ContinueLoop ;skip this upgrade, looking next
				EndIf
			EndIf
			If $g_bChkAutoUpgradeCCIgnore Then ; Filter for decoration
				For $y In $aCCBuildingIgnore
					If StringInStr($name[0], $y) Then
						SetLog("Upgrade for " & $name[0] & " Ignored, Skip!!", $COLOR_ACTION)
						ContinueLoop 2 ;skip this upgrade, looking next
					EndIf
				Next
			EndIf
			_ArrayAdd($aResult, $name[0] & "|" & $aUpgrade[$i][1] & "|" &  $aUpgrade[$i][2])
		Next
	EndIf
	Return $aResult
EndFunc

Func FindCCSuggestedUpgrade()
	Local $aResult[0][3], $name[2] = ["", 0]
	Local $aUpgrade = QuickMIS("CNX", $g_sImgResourceCC, 400, 100, 560, 360)
	If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
		_ArraySort($aUpgrade, 0, 0, 0, 2) ;sort by Y coord
		For $i = 0 To UBound($aUpgrade) - 1
			SetDebugLog("Pixel on " & $aUpgrade[$i][1] - 61 & "," & $aUpgrade[$i][2] + 3 & ": " & _GetPixelColor($aUpgrade[$i][1] - 61, $aUpgrade[$i][2] + 3, True), $COLOR_INFO)
			If _ColorCheck(_GetPixelColor($aUpgrade[$i][1] - 61, $aUpgrade[$i][2] + 3, True), Hex(0xC9F659, 6), 20) Then ;check if we have progressbar
				$name = getCCBuildingName($aUpgrade[$i][1] - 250, $aUpgrade[$i][2] - 11)
			Else
				$name = getCCBuildingNameBlue($aUpgrade[$i][1] - 200, $aUpgrade[$i][2] - 12)
			EndIf

			If $g_bChkAutoUpgradeCCIgnore Then
				If QuickMIS("BC1", $g_sImgDecoration, $aUpgrade[$i][1] - 250, $aUpgrade[$i][2] - 10, $aUpgrade[$i][1], $aUpgrade[$i][2] + 13) Then
					SetLog("Decoration detected, Skip!!", $COLOR_ACTION)
					ContinueLoop ;skip this upgrade, looking next
				EndIf
			EndIf

			If $g_bChkAutoUpgradeCCWallIgnore Then ; Filter for wall
				If StringInStr($name[0], "Wall") Then
					SetLog("Upgrade for Wall Ignored, Skip!!", $COLOR_ACTION)
					ContinueLoop ;skip this upgrade, looking next
				EndIf
			EndIf
			If $g_bChkAutoUpgradeCCIgnore Then
				For $y In $aCCBuildingIgnore
					If StringInStr($name[0], $y) Then
						SetLog("Upgrade for " & $name[0] & " Ignored, Skip!!", $COLOR_ACTION)
						ContinueLoop 2 ;skip this upgrade, looking next
					EndIf
				Next
			EndIf
			_ArrayAdd($aResult, $name[0] & "|" & $aUpgrade[$i][1] & "|" &  $aUpgrade[$i][2])
		Next
	EndIf
	Return $aResult
EndFunc

Func SkipChat($WaitFor = "UpgradeButton")
	For $y = 1 To 10
		If Not $g_bRunState Then Return
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then
			Switch $WaitFor
				Case "UpgradeButton"
					If QuickMIS("BC1", $g_sImgCCUpgradeButton, 300, 520, 600, 660) Then
						SetLog($WaitFor & " OK", $COLOR_ACTION)
						Return
					EndIf
				Case "UpgradeWindow"
					If QuickMis("BC1", $g_sImgGeneralCloseButton, 680, 99, 730, 140) Then
						SetLog($WaitFor & " OK", $COLOR_ACTION)
						Return
					EndIf
			EndSwitch
			Click($g_iQuickMISX + 100, $g_iQuickMISY)
			SetLog("Skip chat #" & $y, $COLOR_INFO)
			If _Sleep(5000) Then Return
		Else
			If _GetPixelColor(340, 484, 1) = "FFFFFF" Then
				Click(340, 484) ;check if we have white chat balloon tips, click it
				SetLog("Skip chat #" & $y, $COLOR_INFO)
				If _Sleep(5000) Then Return
			EndIf
			If $y > 5 Then
				SetLog("Seem's there is no tutorial chat, continue", $COLOR_INFO)
				ExitLoop
			EndIf
		EndIf
		If _Sleep(1000) Then Return
	Next
EndFunc

Func WaitUpgradeButtonCC()
	Local $aRet[3] = [False, 0, 0]
	For $i = 1 To 10
		If Not $g_bRunState Then Return $aRet
		SetLog("Waiting for Upgrade Button #" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgCCUpgradeButton, 300, 520, 600, 660) Then ;check for upgrade button (Hammer)
			$aRet[0] = True
			$aRet[1] = $g_iQuickMISX
			$aRet[2] = $g_iQuickMISY
			Return $aRet ;immediately return as we found upgrade button
		EndIf
		If _Sleep(1000) Then Return
		If $i > 3 Then SkipChat("UpgradeButton")
	Next
	Return $aRet
EndFunc

Func WaitUpgradeWindowCC()
	Local $bRet = False
	For $i = 1 To 10
		SetLog("Waiting for Upgrade Window #" & $i, $COLOR_ACTION)
		If _Sleep(1000) Then Return
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 755, 44, 800, 90) Then ;check if upgrade window opened
			If Not QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then	;also check if there is no tutorial
				$bRet = True
				Return $bRet
			EndIf
		EndIf
		SkipChat("UpgradeWindow")
	Next
	If Not $bRet Then SetLog("Upgrade Window doesn't open", $COLOR_ERROR)
	Return $bRet
EndFunc

Func AutoUpgradeCC($bTest = False)
	If Not $g_bChkEnableAutoUpgradeCC Then Return
	
	SetLog("Checking Clan Capital AutoUpgrade", $COLOR_INFO)
	If $g_bChkEnableMinGoldAUCC And $g_iLootCCGold < $g_iMinCCGoldToUpgrade And $g_iLootCCGold > 0 Then
		SetLog("CCGold = " & $g_iLootCCGold & ", < Minimum:" & $g_iMinCCGoldToUpgrade & ", skip autoupgradeCC", $COLOR_DEBUG2)
		Return
	EndIf
	Local $aRet[3] = [False, 0, 0]
	
	ZoomOutHelper("CollectLootCart")
	If _Sleep(1000) Then Return
	If Not SwitchToClanCapital($bTest) Then Return
	
	If Number($g_iLootCCGold) = 0 And Not $bTest Then
		SetLog("No Capital Gold to spend to Contribute", $COLOR_DEBUG2)
		SwitchToMainVillage("Cannot Contribute")
		Return
	EndIf

	If $g_bChkEnableMinGoldAUCC And $g_iLootCCGold < $g_iMinCCGoldToUpgrade And $g_iLootCCGold > 0 Then
		SetLog("CCGold = " & $g_iLootCCGold & ", < Minimum:" & $g_iMinCCGoldToUpgrade & ", skip autoupgradeCC", $COLOR_DEBUG2)
		SwitchToMainVillage("MinCCGoldToUpgrade")
		Return
	EndIf

	If Not $g_bRunState Then Return
	Local $bUpgradeFound = True ;lets assume there is upgrade in progress exists
	If ClickCCBuilder() Then
		If _Sleep(1000) Then Return
		Local $Text = getOcrAndCapture("coc-buildermenu-capital", 345, 81, 100, 25)
		If StringInStr($Text, "No") Then
			SetLog("No Upgrades in progress", $COLOR_INFO)
			$bUpgradeFound = False ;builder menu opened but no upgrades on progress exists
		EndIf
	Else
		SetLog("Fail to open Builder Menu", $COLOR_DEBUG2)
		SwitchToMainVillage("Failed Open Builder Menu")
		Return
	EndIf
	If _Sleep(500) Then Return
	If $bUpgradeFound Then
		SetLog("Checking Upgrade From Capital Map", $COLOR_INFO)
		Local $aUpgrade = FindCCExistingUpgrade() ;Find on Capital Map, should only find currently on progress building
		If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
			For $i = 0 To UBound($aUpgrade) - 1
				SetDebugLog("CCExistingUpgrade: " & $aUpgrade[$i][0])
				Click($aUpgrade[$i][1], $aUpgrade[$i][2]) ;click building on builder menu list
				If _Sleep(2000) Then Return
				$aRet = WaitUpgradeButtonCC()
				If Not $aRet[0] Then
					SetLog("Upgrade Button Not Found", $COLOR_DEBUG2)
					SwitchToMainVillage("No Upgrade Button")
					Return
				Else
					If IsUpgradeCCIgnore() Then
						SetLog("Upgrade Ignored, Looking Next Upgrade", $COLOR_INFO)
						ClickCCBuilder() ;upgrade should be ignored, so open builder menu again for next upgrade
						ContinueLoop
					EndIf
					Local $BuildingName = getOcrAndCapture("coc-build", 200, 515, 400, 30)
					Click($aRet[1], $aRet[2]) ;click upgrade Button
					If _Sleep(1000) Then Return
					If Not WaitUpgradeWindowCC() Then
						SwitchToMainVillage("No Upgrade Window")
						Return
					EndIf
					If _Sleep(1000) Then Return
					Local $cost = getOcrAndCapture("coc-ccgold", 630, 574, 120, 25, True)
					If Not $bTest Then
						Click(700, 585) ;Click Contribute
						AutoUpgradeCCLog($BuildingName, $cost)
						ClickAway("Right")
					Else
						SetLog("Only Test, should click Contibute on [640, 520]", $COLOR_INFO)
						AutoUpgradeCCLog($BuildingName, $cost)
						ClickAway("Right")
						SwitchToMainVillage("Only Test")
						Return
					EndIf
					If _Sleep(500) Then Return
				EndIf
				ExitLoop ;just do 1 upgrade, next upgrade will do on next attempt (cycle)
			Next
			SwitchToCapitalMain()
		EndIf
	EndIf

	ClickAway("Right") ;close builder menu
	ClanCapitalReport(False)
	;Upgrade through district map
	Local $aMapCoord[7][3] = [["Golem Quarry", 185, 590], ["Dragon Cliffs", 630, 465], ["Builder's Workshop", 490, 525], ["Balloon Lagoon", 300, 490], _
									["Wizard Valley", 410, 400], ["Barbarian Camp", 530, 340], ["Capital Peak", 400, 225]]
	While $g_iLootCCGold > 0
		If Number($g_iLootCCGold) > 0 Then
			SetLog("Checking Upgrade From District Map", $COLOR_INFO)
			For $i = 0 To UBound($aMapCoord) - 1
				SetLog("[" & $i & "] Checking " & $aMapCoord[$i][0], $COLOR_ACTION)
				If QuickMIS("BC1", $g_sImgLock, $aMapCoord[$i][1], $aMapCoord[$i][2] - 120, $aMapCoord[$i][1] + 100, $aMapCoord[$i][2]) Then
					SetLog($aMapCoord[$i][0] & " is Locked", $COLOR_INFO)
					ContinueLoop
				Else
					SetLog($aMapCoord[$i][0] & " is UnLocked", $COLOR_INFO)
				EndIf
				SetLog("Go to " & $aMapCoord[$i][0] & " to Check Upgrades", $COLOR_ACTION)
				Click($aMapCoord[$i][1], $aMapCoord[$i][2])
				If Not WaitForMap($aMapCoord[$i][0]) Then
					SetLog("Going to " & $aMapCoord[$i][0] & " Failed", $COLOR_ERROR)
					SwitchToMainVillage("WaitforMap Failed")
					Return
				EndIf
				If Not ClickCCBuilder() Then ExitLoop
				Local $aUpgrade = FindCCSuggestedUpgrade() ;Find on Distric Map, Will Read White and Blue Font
				If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
					For $j = 0 To UBound($aUpgrade) - 1
						SetLog("CCSuggestedUpgrade: " & $aUpgrade[$j][0])
						Click($aUpgrade[$j][1], $aUpgrade[$j][2]) ;click building on builder menu list
						$aRet = WaitUpgradeButtonCC()
						If Not $aRet[0] Then
							SetLog("Upgrade Button Not Found", $COLOR_ERROR)
							SwitchToMainVillage()
							Return
						Else
							If IsUpgradeCCIgnore() Then
								SetLog("Upgrade Ignored, Looking Next Upgrade", $COLOR_INFO)
								ClickCCBuilder() ;upgrade should be ignored, so open builder menu again for next upgrade
								ContinueLoop
							EndIf
							Local $BuildingName = StringReplace(getOcrAndCapture("coc-build", 200, 515, 400, 30, True), "-", "")
							Click($aRet[1], $aRet[2]) ;click upgrade Button
							If _Sleep(1000) Then Return
							If Not WaitUpgradeWindowCC() Then
								SwitchToMainVillage("No Upgrade Window")
								Return
							EndIf
							Local $cost = StringReplace(getOcrAndCapture("coc-ms", 590, 527, 160, 25, True), "-", "")
							If Not $bTest Then
								Click(700, 585) ;Click Contribute
								AutoUpgradeCCLog($BuildingName, $cost)
								ClickAway("Right")
							Else
								SetLog("Only Test, should click Contibute on [640, 520]", $COLOR_INFO)
								AutoUpgradeCCLog($BuildingName, $cost)
								ClickAway("Right")
							EndIf
							If _Sleep(500) Then Return
							ClickAway("Right")
							If _Sleep(1000) Then Return
						EndIf
						ClanCapitalReport(False)
						If Number($g_iLootCCGold) = 0 Then
							SwitchToMainVillage("CapitalGold=0")
							Return
						EndIf
						ClickCCBuilder()
					Next
				Else ;clan capital gold with blue text not found on builder menu, check if all possible upgrades done?
					Local $Text = getOcrAndCapture("coc-buildermenu", 300, 81, 230, 25)
					Local $aDone[2] = ["All possible", "done"]
					Local $bAllDone = False
					For $z In $aDone
						If StringInStr($Text, $z) Then
							SetDebugLog("Match with: " & $z)
							SetLog("All Possible Upgrades Done", $COLOR_INFO)
						EndIf
					Next
				EndIf
				SwitchToCapitalMain() ;back to capital main
			Next
		EndIf
		ClanCapitalReport(False)
	WEnd
	SwitchToMainVillage("Back to Main") ;last call, we should go back to main screen
EndFunc

Func IsUpgradeCCIgnore()
	Local $bRet = False
	Local $UpgradeName = getOcrAndCapture("coc-build", 200, 494, 400, 30)
	If $g_bChkAutoUpgradeCCWallIgnore Then ; Filter for wall
		If StringInStr($UpgradeName, "Wall") Then
				SetDebugLog($UpgradeName & " Match with: Wall")
				SetLog("Upgrade for wall Ignored, Skip!!", $COLOR_ACTION)
				$bRet = True
		EndIf
	EndIf
	If $g_bChkAutoUpgradeCCIgnore And Not $bRet Then
		For $y In $aCCBuildingIgnore
			If StringInStr($UpgradeName, $y) Then
				SetDebugLog($UpgradeName & " Match with: " & $y)
				SetLog("Upgrade for " & $y & " Ignored, Skip!!", $COLOR_ACTION)
				$bRet = True
				ExitLoop
			Else
				SetDebugLog("OCR: " & $UpgradeName & " compare with: " & $y)
			EndIf
		Next
	EndIf
	Return $bRet
EndFunc

Func AutoUpgradeCCLog($BuildingName = "", $cost = "")
	SetLog("Successfully upgrade " & $BuildingName & ", Contribute " & $cost & " CapitalGold", $COLOR_SUCCESS)
	GUICtrlSetData($g_hTxtAutoUpgradeCCLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - Upgrade " & $BuildingName & ", contribute " & $cost & " CapitalGold", 1)
EndFunc