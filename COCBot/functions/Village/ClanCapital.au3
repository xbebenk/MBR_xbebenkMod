#include-once
Func CollectCCGold()
	If Not $g_bChkEnableCollectCCGold Then Return
	SetLog("Start Collecting Clan Capital Gold", $COLOR_INFO)
	ClickAway()
	If QuickMIS("BC1", $g_sImgCCGold, 280, 550, 480, 630) Then
		Click($g_iQuickMISX, $g_iQuickMISY + 20)
		For $i = 1 To 5
			SetDebugLog("Waiting for Forge Window #" & $i, $COLOR_ACTION)
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 710, 150, 760, 190) Then
				ExitLoop
			EndIf
			_Sleep(500)
		Next
		Click(180, 366) ;Click Collect
		_Sleep(500)
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
	If QuickMIS("BC1", $g_sImgForgeHouse, 270, 580, 340, 660) Then 
		Click($g_iQuickMISX + 10, $g_iQuickMISY + 10)
		For $i = 1 To 5
			SetDebugLog("Waiting for Forge Window #" & $i, $COLOR_ACTION)
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 710, 150, 760, 190) Then
				$bRet = True
				ExitLoop
			EndIf
			_Sleep(500)
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
		_Sleep(500)
	Next
	SetLog("StartCraftWindow does not open", $COLOR_ERROR)
	Return $bRet
EndFunc

Func ForgeClanCapitalGold($bTest = False)
	Local $aForgeType[5] = [$g_bChkEnableForgeGold, $g_bChkEnableForgeElix, $g_bChkEnableForgeDE, $g_bChkEnableForgeBBGold, $g_bChkEnableForgeBBElix]
	Local $bForgeEnabled = False
	For $i In $aForgeType ;check for every option enabled
		If $i = True Then 
			$bForgeEnabled = True
			ExitLoop
		EndIf
	Next
	If Not $bForgeEnabled Then Return
	
	SetLog("Checking for Forge ClanCapital Gold", $COLOR_INFO)
	
	getBuilderCount(True) ;check if we have available builder
	Local $iWallReserve = $g_bUpgradeWallSaveBuilder ? 1 : 0
	If $g_iFreeBuilderCount - $iWallReserve - ReservedBuildersForHeroes() < 1 Then ;check builder reserve on wall and hero upgrade
		SetLog("FreeBuilder=" & $g_iFreeBuilderCount & ", Reserved (ForHero=" & $g_iHeroReservedBuilder & " ForWall=" & $iWallReserve & ")", $COLOR_INFO)
		SetLog("Not Have builder, exiting", $COLOR_INFO)
		Return
	EndIf
	
	If Not OpenForgeWindow() Then 
		SetLog("Forge Window not Opened, exiting", $COLOR_ACTION)
		Return
	EndIf
	
	If $g_iTxtForgeBuilder > 3 Then ClickDrag(720, 315, 600, 315)
	Local $iActiveForge = QuickMIS("CNX", $g_sImgCCGold, 120, 230, 740, 410)
	If IsArray($iActiveForge) And UBound($iActiveForge) > 0 Then
		If UBound($iActiveForge) >= $g_iTxtForgeBuilder Then
			SetLog("We have All Builder Active for Forge", $COLOR_INFO)
			ClickAway()
			Return
		EndIf
		
		Local $iBuilder = UBound($iActiveForge)
		For $i = $iBuilder To $g_iTxtForgeBuilder
			Local $aCraft = QuickMIS("CNX", $g_sImgCCGold & "Craft\", 120, 230, 740, 410)
			_ArraySort($aCraft)
			If IsArray($aCraft) And UBound($aCraft) > 0 Then
				Click($aCraft[$i][1], $aCraft[$i][2])
				_Sleep(500)
				If Not WaitStartCraftWindow() Then Return
				If Not $bTest Then 
					SetLog("Not completed yet, will continue later", $COLOR_INFO)
					ClickAway()
				EndIf
			EndIf
			ClickAway()
		Next
	EndIf
	
	
EndFunc
