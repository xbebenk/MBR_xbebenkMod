; #FUNCTION# ====================================================================================================================
; Name ..........: SuggestedUpgrades()
; Description ...: Goes to Builders Island and Upgrades buildings with 'suggested upgrades window'.
; Syntax ........: SuggestedUpgrades()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (05-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; coc-armycamp ---> OCR the values on Builder suggested updates
; coc-build ----> building names and levels [ needs some work on 'u' and 'e' ]  BuildingInfo

; Zoomout
; If Suggested Upgrade window is open [IMAGE] -> C:\Users\user\Documents\MDOCOCPROJECT\imgxml\Resources\PicoBuildersBase\SuggestedUpdates\IsSuggestedWindowOpened_0_92.png
; Image folder [GOLD] -> C:\Users\user\Documents\MDOCOCPROJECT\imgxml\Resources\PicoBuildersBase\SuggestedUpdates\Gold_0_89.png
; Image folder [GOLD] -> C:\Users\user\Documents\MDOCOCPROJECT\imgxml\Resources\PicoBuildersBase\SuggestedUpdates\Elixir_0_89.png

; Buider Icon position Blue[i] [Check color] [360, 11, 0x7cbdde, 10]
; Suggested Upgrade window position [Imgloc] [380, 59, 100, 20]
; Zone to search for Gold / Elixir icons and values [445, 100, 90, 85 ]
; Gold offset for OCR [Point] [x,y, length]  ,x = x , y = - 10  , length = 535 - x , Height = y + 7   [17]
; Elixir offset for OCR [Point] [x,y, length]  ,x = x , y = - 10  , length = 535 - x , Height = y + 7 [17]
; Buider Name OCR ::::: BuildingInfo(242, 580)
; Button Upgrade position [275, 670, 300, 30]  -> UpgradeButton_0_89.png
; Button OK position Check Pixel [430, 540, 0x6dbd1d, 10] and CLICK

; Draft
; 01 - Verify if we are on Builder island [Boolean]
; 01.1 - Verify available builder [ OCR - coc-Builders ] [410 , 23 , 40 ]
; 02 - Click on Builder [i] icon [Check color]
; 03 - Verify if the window opened [Boolean]
; 04 - Detect Gold and Exlir icons [Point] by a dynamic Y [ignore list]
; 05 - With the previous positiosn and a offset , proceeds with OCR : [WHITE] OK , [salmon] Not enough resources will return "" [strings] convert to [integer]
; 06 - Make maths , IF the Gold is selected on GUI , if Elixir is Selected on GUI , and the resources values and min to safe [Boolean]
; 07 - Click on he correct ICon on Suggested Upgrades window [Point]
; 08 - Verify buttons to upgrade [Point] - Detect the Builder name [OCR]
; 09 - Verify the button to upgrade window [point]  -> [Boolean] ->[check pixel][imgloc]
; 10 - Builder Base report
; 11 - DONE

; GUI
; Check Box to enable the function
; Ignore Gold , Ignore Elixir
; Ignore building names
; Setlog

Func chkActivateBBSuggestedUpgrades()
	; CheckBox Enable Suggested Upgrades [Update values][Update GUI State]
	If GUICtrlRead($g_hChkBBSuggestedUpgrades) = $GUI_CHECKED Then
		$g_iChkBBSuggestedUpgrades = 1
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreGold, $GUI_ENABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreElixir, $GUI_ENABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreHall, $GUI_ENABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreWall, $GUI_ENABLE)
		GUICtrlSetState($g_hChkPlacingNewBuildings, $GUI_ENABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesOTTO, $GUI_ENABLE)

	Else
		$g_iChkBBSuggestedUpgrades = 0
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreGold, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreElixir, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreHall, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreWall, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkPlacingNewBuildings, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkBBSuggestedUpgradesOTTO, $GUI_DISABLE)
	EndIf

EndFunc   ;==>chkActivateBBSuggestedUpgrades

Func chkActivateOptimizeOTTO()
	If GUICtrlRead($g_hChkBBSuggestedUpgradesOTTO) = $GUI_CHECKED Then
		$g_bOptimizeOTTO = 1
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreGold, $GUI_DISABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreElixir, $GUI_DISABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreHall, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreWall, BitOR($GUI_CHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkPlacingNewBuildings, BitOR($GUI_CHECKED, $GUI_DISABLE))
		$g_iChkPlacingNewBuildings = True
		$g_iChkBBSuggestedUpgradesIgnoreWall = True
	Else
		$g_bOptimizeOTTO = 0
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreGold, $GUI_ENABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreElixir, $GUI_ENABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreHall, $GUI_ENABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreWall, $GUI_ENABLE)
		GUICtrlSetState($g_hChkPlacingNewBuildings, $GUI_ENABLE)
	Endif
EndFunc   ;==>chkActivateOptimizeOTTO

Func chkActivateBBSuggestedUpgradesGold()
	; if disabled, why continue?
	If $g_iChkBBSuggestedUpgrades = 0 Then Return
	; Ignore Upgrade Building with Gold [Update values]
	$g_iChkBBSuggestedUpgradesIgnoreGold = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreGold) = $GUI_CHECKED) ? 1 : 0
	; If Gold is Selected Than we can disable the Builder Hall [is gold] and Wall almost [is Gold]
	If $g_iChkBBSuggestedUpgradesIgnoreGold = 0 Then
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreElixir, $GUI_ENABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreHall, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreElixir, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreHall, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
	EndIf
	chkActivateOptimizeOTTO()
	; Ignore Upgrade Builder Hall [Update values]
	$g_iChkBBSuggestedUpgradesIgnoreHall = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreHall) = $GUI_CHECKED) ? 1 : 0
	; Update Elixir value
	$g_iChkBBSuggestedUpgradesIgnoreElixir = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreElixir) = $GUI_CHECKED) ? 1 : 0
	; Ignore Wall
	$g_iChkBBSuggestedUpgradesIgnoreWall = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreWall) = $GUI_CHECKED) ? 1 : 0
EndFunc   ;==>chkActivateBBSuggestedUpgradesGold

Func chkActivateBBSuggestedUpgradesElixir()
	; if disabled, why continue?
	If $g_iChkBBSuggestedUpgrades = 0 Then Return
	; Ignore Upgrade Building with Elixir [Update values]
	$g_iChkBBSuggestedUpgradesIgnoreElixir = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreElixir) = $GUI_CHECKED) ? 1 : 0
	If $g_iChkBBSuggestedUpgradesIgnoreElixir = 0 Then
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreGold, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreGold, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
	EndIf
	chkActivateOptimizeOTTO()
	; Update Gold value
	$g_iChkBBSuggestedUpgradesIgnoreGold = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreGold) = $GUI_CHECKED) ? 1 : 0
EndFunc   ;==>chkActivateBBSuggestedUpgradesElixir

Func chkPlacingNewBuildings()
	$g_iChkPlacingNewBuildings = (GUICtrlRead($g_hChkPlacingNewBuildings) = $GUI_CHECKED) ? 1 : 0
EndFunc   ;==>chkPlacingNewBuildings

; MAIN CODE
Func AutoUpgradeBB($bTest = False)
	If $g_iChkBBSuggestedUpgrades = 0 Then Return
	If Not isOnBuilderBase(True) Then Return
	If Not AutoUpgradeBBCheckBuilder($bTest) Then Return ;check if we have masterBuilder
	ZoomOut()
	BuilderBaseReport(True)
	If Not ClickBBBuilder() Then Return

	If $g_iChkPlacingNewBuildings And $g_bIsMegaTeslaMaxed <> 1 Then
		SearchNewBuilding($bTest)
	EndIf

	If Not AutoUpgradeBBCheckBuilder($bTest) Then
		ZoomOut()
		Return ;check if we have masterBuilder
	EndIf
	SearchExistingBuilding($bTest)
	ZoomOut()
	ClickAway("Left")
EndFunc   ;==>MainSuggestedUpgradeCode

Func SearchNewBuilding($bTest = False)
	Local $NeedDrag = True, $ZoomedIn = False, $TmpUpgradeCost, $UpgradeCost, $sameCost
	ClickBBBuilder()
	$g_bReserveElixirBB = False
	$g_bReserveGoldBB = False

	If FindBHInUpgradeProgress() Then
		SetLog("BuilderHall Upgrade in progress, skip search new building!", $COLOR_SUCCESS)
		Return False
	EndIf

	For $z = 1 To 5 ;do scroll 5 times
		If _Sleep(50) Then Return
		If Not $g_bRunState Then Return
		Local $New = FindBBNewBuilding()
		If IsArray($New) And UBound($New) > 0 Then
			_ArraySort($New, 0, 0, 0, 6) ;sort by cost
			For $i = 0 To UBound($New) - 1
				SetLog("New: " & $New[$i][4] & " cost: " & $New[$i][6] & " " & $New[$i][0])
			Next
			For $i = 0 To UBound($New) - 1
				If $g_bSkipWallPlacingOnBB And $New[$i][4] = "Wall" Then
					SetLog("Building is New Wall, Skip!", $COLOR_INFO)
					NotifyPushToTelegram($g_sProfileCurrentName & ": There is a new wall in BB.")
					ContinueLoop ;skip wall
				EndIf
				If Not $g_bRunState Then Return
				If Not CheckResourceForDoUpgradeBB($New[$i][4], $New[$i][6], $New[$i][0]) Then ;name, cost, costtype
					SetLog("Not Enough " & $New[$i][0] & " to place New " & $New[$i][4], $COLOR_INFO)
					If $New[$i][4] = "Army Camp" Then
						SetLog("Building is New Army Camp, Set Reserve Cost for Elixir!", $COLOR_INFO)
						$g_bReserveElixirBB = True
					EndIf
					ContinueLoop ;check for resource
				EndIf
				SetLog("Try Placing " & $New[$i][4])
				Local $Region = Default
				If $New[$i][4] = "Wall" Then $Region = 1
				If Not $ZoomedIn Then
					ClickAway("Left") ;close builder menu
					_Sleep(1000)
					If SearchGreenZoneBB($Region) Then
						$ZoomedIn = True
					Else
						ExitLoop 2 ;zoomin failed, exit
					EndIf
				EndIf
				ClickBBBuilder($bTest)
				Local $aBuildingName[3] = [2, $New[$i][4], "New"]
				If NewBuildings($New[$i][1], $New[$i][2], $aBuildingName, $bTest) Then
					ClickBBBuilder($bTest)
					If Not AutoUpgradeBBCheckBuilder($bTest) Then Return
				Else
					ExitLoop 2 ;Place NewBuilding failed, exit
				EndIf
			Next
		EndIf
		If Not $g_bRunState Then Return
		If $g_bOptimizeOTTO Then
			Local $OTTO = FindBBExistingBuilding()
			If IsArray($OTTO) And UBound($OTTO) > 0 Then
				For $i = 0 To UBound($OTTO) - 1
					SetLog("OptimizeOTTO: " & $OTTO[$i][3] & " cost: " & $OTTO[$i][5] & " " & $OTTO[$i][0])
				Next
				If Not $g_bRunState Then Return

				For $i = 0 To UBound($OTTO) - 1
					If Not $g_bRunState Then Return
					Local $bOTTOPrioFound = False
					Local $aOTTOPriority[5] = ["Army Camp", "Builder Hall", "Gold Storage", "Elixir Storage", "Star Laboratory"]
					For $OTTOPriority In $aOTTOPriority
						If $OTTO[$i][3] = $OTTOPriority Then
							SetLog("Building: " & $OTTO[$i][3] & ", OTTO Priority Building", $COLOR_ACTION)
							$bOTTOPrioFound = True
							ExitLoop
						EndIf
					Next
					If Not $bOTTOPrioFound Then ContinueLoop
					If Not CheckResourceForDoUpgradeBB($OTTO[$i][3], $OTTO[$i][5], $OTTO[$i][0]) Then ;name, cost, costtype
						SetLog("Not Enough " & $OTTO[$i][0] & " to Upgrade " & $OTTO[$i][3], $COLOR_INFO)
						If $OTTO[$i][3] = "Builder Hall" Or $OTTO[$i][3] = "Elixir Storage" Then
							SetLog("OTTO Priority, Set Reserve Cost for Gold!", $COLOR_INFO)
							$g_bReserveGoldBB = True
						EndIf
						If $OTTO[$i][3] = "Army Camp" Or $OTTO[$i][3] = "Gold Storage" Then
							SetLog("OTTO Priority, Set Reserve Cost for Elixir!", $COLOR_INFO)
							$g_bReserveElixirBB = True
						EndIf
						ContinueLoop ;check for resource
					EndIf
					SetLog("Try Upgrade: " & $OTTO[$i][3], $COLOR_INFO)
					Click($OTTO[$i][1], $OTTO[$i][2])
					If _Sleep(1000) Then Return
					If DoUpgradeBB($OTTO[$i][0], $bTest) Then
						Return True ;upgrade success
					Else
						ClickBBBuilder()
						ContinueLoop ;upgrade not success
					EndIf
				Next
			EndIf
		EndIf

		If Not $g_bRunState Then Return
		$TmpUpgradeCost = getMostBottomCostBB() ;check most bottom upgrade cost
		SetDebugLog("TmpUpgradeCost = " & $TmpUpgradeCost & " UpgradeCost = " & $UpgradeCost, $COLOR_INFO)
		If $UpgradeCost = $TmpUpgradeCost Then $sameCost += 1
		If Not ($UpgradeCost = $TmpUpgradeCost) Then $sameCost = 0
		If $sameCost > 1 Then $NeedDrag = False
		$UpgradeCost = $TmpUpgradeCost
		If Not $NeedDrag Then
			SetLog("[" & $z & "] Scroll Not Needed!", $COLOR_DEBUG)
			ExitLoop
		EndIf

		If Not ClickDragAutoUpgradeBB("up") Then Return
		SetLog("[" & $z & "] Scroll Up", $COLOR_DEBUG)
		If Not AutoUpgradeBBCheckBuilder($bTest) Then ExitLoop
	Next

	SetLog("Exit BB FindNewBuilding", $COLOR_DEBUG)
	ClickDragAutoUpgradeBB("down")
	ZoomOut()
	Return True
EndFunc

Func SearchExistingBuilding($bTest = False)
	Local $NeedDrag = True, $TmpUpgradeCost, $UpgradeCost, $sameCost
	ClickBBBuilder()
	For $z = 1 To 8 ;do scroll 8 times
		If _Sleep(50) Then Return
		If Not $g_bRunState Then Return
		Local $Building = FindBBExistingBuilding()
		If IsArray($Building) And UBound($Building) > 0 Then
			SetLog("Building List:", $COLOR_INFO)
			For $i = 0 To UBound($Building) - 1
				SetLog($Building[$i][3] & ", Cost:" & $Building[$i][5] & "|" & $Building[$i][0] & ", Score[" & $Building[$i][6] & "], " & $Building[$i][7], $COLOR_INFO)
			Next
			If Not $g_bRunState Then Return
			For $i = 0 To UBound($Building) - 1
				If Not CheckResourceForDoUpgradeBB($Building[$i][3], $Building[$i][5], $Building[$i][0]) Then ;name, cost, costtype
					SetLog("Not Enough " & $Building[$i][0] & " to Upgrade " & $Building[$i][3], $COLOR_INFO)
					ContinueLoop
				EndIf
				Local $bOptimizeOTTOFound = False
				Local $IsWall = False
				If $g_bOptimizeOTTO And $Building[$i][7] = "OptimizeOTTO" Then
					$bOptimizeOTTOFound = True
				EndIf
				If $g_bOptimizeOTTO And StringInStr($Building[$i][3], "Wall") And $g_bGoldStorageFullBB Then
					SetLog("Found Wall to spend Gold", $COLOR_INFO)
					$bOptimizeOTTOFound = True
					$IsWall = True
				EndIf
				If Not $g_bRunState Then Return
				If $g_bOptimizeOTTO And Not $bOptimizeOTTOFound Then
					SetLog("Building: " & $Building[$i][3] & ", skip due to optimizeOTTO", $COLOR_ACTION)
					ContinueLoop
				EndIf

				If $IsWall Then
					Click($Building[$i][1], $Building[$i][2])
					While $g_bGoldStorageFullBB
						SetLog("Upgrading Wall to spend Gold", $COLOR_INFO)
						DoUpgradeBB($Building[$i][0], $bTest)
						If _Sleep(1000) Then Return
						isGoldFullBB()
					Wend
					Return True ;As wall recursively upgraded to spend Gold we stop here
				EndIf

				SetLog("Try Upgrade: " & $Building[$i][3], $COLOR_INFO)
				Click($Building[$i][1], $Building[$i][2])
				If _Sleep(1000) Then Return
				If DoUpgradeBB($Building[$i][0], $bTest) Then
					Return True ;upgrade success
				Else
					ClickBBBuilder()
					ContinueLoop ;upgrade not success
				EndIf
			Next
		EndIf
		If Not $g_bRunState Then Return
		$TmpUpgradeCost = getMostBottomCostBB() ;check most bottom upgrade cost
		SetDebugLog("TmpUpgradeCost = " & $TmpUpgradeCost & " UpgradeCost = " & $UpgradeCost, $COLOR_INFO)
		If $UpgradeCost = $TmpUpgradeCost Then $sameCost += 1
		If Not ($UpgradeCost = $TmpUpgradeCost) Then $sameCost = 0
		If $sameCost > 1 Then $NeedDrag = False
		$UpgradeCost = $TmpUpgradeCost
		If Not $NeedDrag Then
			SetLog("[" & $z & "] Scroll Not Needed!", $COLOR_DEBUG)
			ExitLoop
		EndIf

		ClickDragAutoUpgradeBB("up")
		SetLog("[" & $z & "] Scroll Up", $COLOR_DEBUG)
		If Not AutoUpgradeBBCheckBuilder($bTest) Then ExitLoop
	Next

	SetLog("Exit BB FindExistingBuilding", $COLOR_DEBUG)
	ZoomOut()
	Return True
EndFunc

Func DoUpgradeBB($CostType = "Gold", $bTest = False)
	Local $aBuildingName = BuildingInfo(242, 494)
	If $aBuildingName[0] = "" Then
		SetLog("Error when trying to get upgrade name and level...", $COLOR_ERROR)
		Return False
	EndIf
	If Not $g_bRunState Then Return
	If $g_bOptimizeOTTO And $g_bIsMegaTeslaMaxed <> 1 Then ;set upgrade only to certain level when mega tesla is not maxed
		Select
			Case $aBuildingName[1] = "Archer Tower" And $aBuildingName[2] >= 6
				SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
				Return False
			Case $aBuildingName[1] = "Double Cannon" And $aBuildingName[2] >= 4
				SetLog("Upgrade for Double Cannon Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
				Return False
			Case $aBuildingName[1] = "Multi Mortar" And $aBuildingName[2] >= 8
				SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
				Return False
		EndSelect
	EndIf

	If $g_bOptimizeOTTO And Not $g_bisBHMaxed Then
		If $aBuildingName[1] = "Builder Barracks" And $aBuildingName[2] >= 7 Then
			SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
			Return False
		EndIf
	EndIf

	If Not $g_bOptimizeOTTO Then
		If StringInStr($aBuildingName[1], "Hall") And $g_iChkBBSuggestedUpgradesIgnoreHall Then
			SetLog("Ups! Builder Hall is not to Upgrade!", $COLOR_ERROR)
			Return False
		EndIf

		If StringInStr($aBuildingName[1], "Wall") And $g_iChkBBSuggestedUpgradesIgnoreWall Then
			SetLog("Ups! Wall is not to Upgrade!", $COLOR_ERROR)
			Return False
		EndIf
	EndIf

	If Not $g_bRunState Then Return
	Local $Dir = $g_sImgAutoUpgradeBtnDir
	If StringInStr($aBuildingName[1], "Wall") Then $Dir = $g_sImgBBGoldButton
	If QuickMIS("BC1", $Dir, 260, 520, 650, 620) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		If Not $bTest Then
			If _Sleep(500) Then Return
			If WaitBBUpgradeWindow() Then
				If QuickMIS("BC1", $g_sImgBBUpgradeWindowButton, 300, 400, 770, 570) Then
					Click($g_iQuickMISX - 50, $g_iQuickMISY + 20)
					If _Sleep(1000) Then Return
					If isGemOpen(True) Then
						SetLog("Upgrade stopped due to insufficient loot", $COLOR_ERROR)
						ClickAway("Left")
						If _Sleep(500) Then Return
						ClickAway("Left")
						Return False
					Else
						SetLog($aBuildingName[1] & " Upgrading!", $COLOR_INFO)
						BBAutoUpgradeLog($aBuildingName)
						Return True
					EndIf
				EndIf
			EndIf
		Else
			SetLog("Only for Test!", $COLOR_ERROR)
			ClickAway("Left")
			ClickBBBuilder()
			Return True
		EndIf
	EndIf

	Return False
EndFunc   ;==>DoUpgradeBB

Func ClickDragAutoUpgradeBB($Direction = "up", $YY = Default, $DragCount = 1)
	Local $x = 450, $yUp = 125, $yDown = 800, $Delay = 500
	ClickBBBuilder()
	If $YY = Default And $Direction = "up" Then
		Local $Tmp = QuickMIS("CNX", $g_sImgBBResourceIcon, 400, 73, 500, 370)
		If IsArray($Tmp) And UBound($Tmp) > 0 Then
			$YY = _ArrayMax($Tmp, 1, 0, -1, 2)
			SetDebugLog("DragUpY = " & $YY)
			If Number($YY) < 300 Then
				SetLog("No need to dragUp!", $COLOR_INFO)
				Return False
			EndIf
		Else
			$YY = 150
		EndIf
	EndIf
	If Not $g_bRunState Then Return
	For $z = 1 To 2
		If Not $g_bRunState Then Return
		If IsBBBuilderMenuOpen() Then ;check upgrade window border
			Switch $Direction
				Case "Up"
					If $DragCount > 1 Then
						For $i = 1 To $DragCount
							ClickDrag($x, $YY, $x, $yUp, $Delay) ;drag up
						Next
					Else
						ClickDrag($x, $YY, $x, $yUp, $Delay) ;drag up
					EndIf
					If _Sleep(3000) Then Return
				Case "Down"
					ClickDrag($x, $yUp, $x, $yDown, $Delay) ;drag to bottom
					If WaitforPixel(510, 90, 515, 95, "FFFFFF", 10, 2) Then
						ClickDrag($x, $yUp, $x, $yDown, $Delay) ;drag to bottom
					EndIf
					If _Sleep(3000) Then Return
			EndSwitch
		EndIf
		If IsBBBuilderMenuOpen() Then ;check upgrade window border
			SetLog("Upgrade Window Exist", $COLOR_INFO)
			Return True
		Else
			SetLog("Upgrade Window Gone!", $COLOR_DEBUG)
			ClickBBBuilder()
			If _Sleep(1000) Then Return
		EndIf
	Next
	Return False
EndFunc

Func NewBuildings($x, $y, $aBuildingName, $bTest = False)
	Local $Screencap = True, $Debug = False

	Click($x, $y)
	Local $bShopOpened = False
	If Not $g_bRunState Then Return
	For $i = 1 To 6
		If _Sleep(1000) Then Return
		If Not $g_bRunState Then Return
		SetLog("Waiting for Shop window #" & $i, $COLOR_ACTION)
		If IsFullScreenWindow() Then
			If _Sleep(1000) Then Return
			$bShopOpened = True
			ExitLoop
		EndIf
	Next
	If Not $g_bRunState Then Return
	If Not $bShopOpened Then
		SetLog("Cannot find Orange Arrow", $COLOR_ERROR)
		Click(820, 40)
		If _Sleep(5000) Then Return
		Return
	EndIf

	;Search the arrow
	If QuickMIS("BC1", $g_sImgArrowNewBuilding, 10, 130, 840, 560) Then
		Click($g_iQuickMISX - 50, $g_iQuickMISY + 50)
		If Not $g_bRunState Then Return
		If _Sleep(2500) Then Return

		If $aBuildingName[1] = "Wall" Then
			TPW() ;Try Placing Wall (no guarantee) Sucks SC's AI
			Return True
		EndIf
		; Lets search for the Correct Symbol on field
		If QuickMIS("BC1", $g_sImgAutoUpgradeGreenCheck, 100, 80, 740, 560) Then
			SetLog("Placed a new Building on Builder Island! [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_SUCCESS)
			If Not $bTest Then
				Click($g_iQuickMISX, $g_iQuickMISY)
			EndIf
			If Not $g_bRunState Then Return
			If _Sleep(2000) Then Return
			Click($g_iQuickMISX, $g_iQuickMISY) ;click GreenCheck in case it exist
			Click($g_iQuickMISX - 75, $g_iQuickMISY) ;click redX in case it exist
			BBAutoUpgradeLog($aBuildingName)
			Return True
		Else
			SaveDebugImage("BBPlaceNewBuilding")
			NotifyPushToTelegram($g_sProfileCurrentName & ": Failed to place new building in BB.")
			If QuickMIS("BC1", $g_sImgAutoUpgradeRedX, 100, 80, 740, 560) Then
				SetLog("Sorry! Wrong place to deploy a new building on BB! [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_ERROR)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If Not $g_bRunState Then Return
			Else
				If Not $g_bRunState Then Return
				SetLog("Error on Undo symbol!", $COLOR_ERROR)
				;todo do attack bb
				GoAttackBBAndReturn()
				Return False
			EndIf
			Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>NewBuildings

Global $greenZoneBB = "Top"
Func SearchGreenZoneBB($Region = 0, $ZoomIn = True)
	SetLog("Search GreenZone on BB for Placing new Building", $COLOR_INFO)
	Local $sAreaTop = GetDiamondFromRect("257,97,622,359")
	Local $sAreaLeft = GetDiamondFromRect("72,229,442,490")
	Local $sAreaBottom = GetDiamondFromRect("260,360,623,633")
	Local $sAreaRight = GetDiamondFromRect("442,229,790,490")
	Local $aTop = StringSplit(findImage("GreenZoneBBTop", $g_sImgAUpgradeGreenZoneBB & "GreenZoneBB_0_95.xml", $sAreaTop, 1000, True), "|")
	Local $aLeft = StringSplit(findImage("GreenZoneBBLeft", $g_sImgAUpgradeGreenZoneBB & "GreenZoneBB_0_95.xml", $sAreaLeft, 1000, True), "|")
	Local $aBottom = StringSplit(findImage("GreenZoneBBBottom", $g_sImgAUpgradeGreenZoneBB & "GreenZoneBB_0_95.xml", $sAreaBottom, 1000, True), "|")
	Local $aRight = StringSplit(findImage("GreenZoneBBRight", $g_sImgAUpgradeGreenZoneBB & "GreenZoneBB_0_95.xml", $sAreaRight, 1000, True), "|")
	
	Local $aAll[4][2] = [["Top", $aTop[0]], ["Left", $aLeft[0]], ["Bottom", $aBottom[0]], ["Right", $aRight[0]]]
	_ArraySort($aAll,1,0,0,1)
	SetDebugLog($aAll[0][0] & ":" & $aAll[0][1] & "|" & $aAll[1][0] & ":" & $aAll[1][1] & "|" & $aAll[2][0] & ":" & $aAll[2][1] & "|" & $aAll[3][0] & ":" & $aAll[3][1] & "|", $COLOR_DEBUG)
	
	If $aAll[0][1] > 0 Then
		SetLog("Found GreenZone, On " & $aAll[0][0] & " Region", $COLOR_SUCCESS)
		If Not $ZoomIn Then Return $aAll[0][0]
		Local $tmpRegion = $aAll[0][0]
		If $Region = 1 Then 
			$greenZoneBB = $tmpRegion
			$tmpRegion = "Middle" ;only use for wall placing, zoomin on center of village
		EndIf
		If ZoomInBB($tmpRegion) Then
			SetLog("Succeed ZoomIn", $COLOR_DEBUG)
			Return True
		Else
			SetLog("Failed ZoomIn", $COLOR_ERROR)
		EndIf
	Else
		SetLog("GreenZone for Placing new Building Not Found", $COLOR_DEBUG)
	EndIf
	NotifyPushToTelegram($g_sProfileCurrentName & ": Failed to place new building in BB.")
	Return False
EndFunc

Func GoAttackBBAndReturn()
	If Not $g_bRunState Then Return
	SetLog("Going attack, to clear field", $COLOR_DEBUG)
	PrepareAttackBB("CleanYard")
	_AttackBB()
	If Not $g_bRunState Then Return
	ClickAway("Left")
	ZoomOut()
	SetLog("Field should be clear now", $COLOR_DEBUG)
EndFunc

Func BBAutoUpgradeLog($aBuilding)
	Local $txtAcc = $g_iCurAccount
	Local $txtAccName = $g_asProfileName[$g_iCurAccount]
	Local $BuildingName = $aBuilding[1], $BuildingLevel = $aBuilding[2]
	If $BuildingLevel = "New" Then
		_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, _
				@CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - BB Placing New Building: " & $BuildingName)

		_FileWriteLog($g_sProfileLogsPath & "\AutoUpgradeHistory.log", " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - BB Placing New Building: " & $BuildingName)
	Else
		_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, _
				@CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - BB Upgrading " & $BuildingName & " to level " & $BuildingLevel + 1)

		_FileWriteLog($g_sProfileLogsPath & "\AutoUpgradeHistory.log", " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - BB Upgrading " & $BuildingName & " to level " & $BuildingLevel + 1)
	EndIf
	Return True
EndFunc

Func AutoUpgradeBBCheckBuilder($bTest = False)
	Local $bRet = False
	getBuilderCount(False, True) ;check masterBuilder
	If $bTest Then
		$g_iFreeBuilderCountBB = 1
		$bRet = True
	EndIf
	;Check if there is a free builder for Auto Upgrade
	If $g_iFreeBuilderCountBB > 0 Then
		$bRet = True
	Else
		SetLog("Master Builder Not Available", $COLOR_DEBUG)
		$bRet = False
	EndIf
	SetLog("Free Master Builder : " & $g_iFreeBuilderCountBB, $COLOR_DEBUG)
	Return $bRet
EndFunc

Func FindBBNewBuilding()
	Local $aTmpCoord, $aBuilding[0][7], $UpgradeCost, $aUpgradeName, $UpgradeType = ""
	$aTmpCoord = QuickMIS("CNX", $g_sImgAUpgradeObstNew, 250, 73, 400, 370)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			If QuickMIS("BC1", $g_sImgBBResourceIcon, $aTmpCoord[$i][1] + 100 , $aTmpCoord[$i][2] - 12, $aTmpCoord[$i][1] + 250, $aTmpCoord[$i][2] + 12) Then
				$UpgradeType =  $g_iQuickMISName
				_ArrayAdd($aBuilding, $UpgradeType & "|" & $g_iQuickMISX & "|" & $g_iQuickMISY & "|" & $aTmpCoord[$i][1])
			EndIf
		Next

		For $j = 0 To UBound($aBuilding) -1
			$aUpgradeName = getBuildingName($aBuilding[$j][1] - 180, $aBuilding[$j][2] - 12) ;get upgrade name and amount
			$UpgradeCost = getOcrAndCapture("coc-buildermenu-cost", $aBuilding[$j][1], $aBuilding[$j][2] - 12, 120, 25, True)
			$aBuilding[$j][4] = $aUpgradeName[0]
			$aBuilding[$j][5] = $aUpgradeName[1]
			$aBuilding[$j][6] = Number($UpgradeCost)
			SetDebugLog("[" & $j & "] Building: " & $aBuilding[$j][4] & ", Cost=" & $aBuilding[$j][6] & " Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG)
		Next
	EndIf
	Return $aBuilding
EndFunc

Global $g_aOptimizeOTTO[14][2] = [["Double Cannon", 10], ["Archer Tower", 10], ["Multi Mortar", 10], ["Mega Tesla", 11], ["Battle Machine", 11], ["Storage", 12], _
									["Gold Mine", 8], ["Collector", 8], ["Laboratory", 12], ["Builder Hall", 12], ["Clock Tower", 5], ["Barracks", 12], _
									["Army Camp", 12], ["Wall", 5]]

Func FindBBExistingBuilding($bTest = False)
	Local $ElixMultiply = 1, $GoldMultiply = 1 ;used for multiply score
	Local $Gold = getResourcesMainScreen(695, 23)
	Local $Elix = getResourcesMainScreen(695, 74)
	If $Gold > $Elix Then $GoldMultiply += 1
	If $Elix > $Gold Then $ElixMultiply += 1

	Local $aTmpCoord, $aBuilding[0][8], $UpgradeCost, $UpgradeName, $bFoundOptimizeOTTO = False
	$aTmpCoord = QuickMIS("CNX", $g_sImgBBResourceIcon, 400, 73, 500, 370)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		For $i = 0 To UBound($aTmpCoord) - 1
			$bFoundOptimizeOTTO = False ;reset
			If QuickMIS("BC1",$g_sImgAUpgradeObstGear, $aTmpCoord[$i][1] - 200, $aTmpCoord[$i][2] - 10, $aTmpCoord[$i][1], $aTmpCoord[$i][2] + 10) Then ContinueLoop ;skip geared and new
			$UpgradeName = getBuildingName(300, $aTmpCoord[$i][2] - 12) ;get upgrade name and amount
			If $g_bOptimizeOTTO Then ;if OptimizeOTTO enabled, filter only OptimizeOTTO buildings
				For $x = 0 To UBound($g_aOptimizeOTTO) - 1
					If StringInStr($UpgradeName[0], $g_aOptimizeOTTO[$x][0], 1) Then
						$bFoundOptimizeOTTO = True ;used for add array
						ExitLoop
					EndIf
				Next

				If $UpgradeName[0] = "Wall" Then ;include wall to upgrade only after mega tesla is maxed
					If ($g_bIsMegaTeslaMaxed = 1 And $g_bGoldStorageFullBB) Or ($g_bGoldStorageFullBB And $g_bReserveElixirBB) Then
						Local $tmpcost = getOcrAndCapture("coc-buildermenu-cost", $aTmpCoord[$i][1], $aTmpCoord[$i][2] - 10, 120, 30, True)
						If Number($tmpcost) = 0 Then ContinueLoop ;skip wall cost read error
						If Number($tmpcost) > 1000000 Then ContinueLoop ;only upgrade wall cost below 1000000
					Else
						ContinueLoop ;just skip if above condition not met
					EndIf
				EndIf

				If $g_bOptimizeOTTO And $g_bReserveElixirBB And $aTmpCoord[$i][0] = "Elix" And $UpgradeName[0] <> "Army Camp" And $UpgradeName[0] <> "Gold Storage" Then
					SetLog("Reserve Elixir BB for OptimizeOTTO, Building " & $UpgradeName[0] & " skip!!", $COLOR_ACTION)
					ContinueLoop
				EndIf

				If $g_bOptimizeOTTO And $g_bReserveGoldBB And $aTmpCoord[$i][0] = "Gold" And $UpgradeName[0] <> "Builder Hall" And $UpgradeName[0] <> "Elixir Storage" Then
					SetLog("Reserve Gold BB for OptimizeOTTO, Building " & $UpgradeName[0] & " skip!!", $COLOR_ACTION)
					ContinueLoop
				EndIf

				If Not $bFoundOptimizeOTTO Then
					SetDebugLog("Building:" & $UpgradeName[0] & ", not OptimizeOTTO building")
					ContinueLoop
				EndIf
			EndIf
			_ArrayAdd($aBuilding, String($aTmpCoord[$i][0]) & "|" & $aTmpCoord[$i][1] & "|" & Number($aTmpCoord[$i][2]) & "|" & String($UpgradeName[0]) & "|" & Number($UpgradeName[1])) ;compose the array
		Next

		For $j = 0 To UBound($aBuilding) -1
			$UpgradeCost = getOcrAndCapture("coc-buildermenu-cost", $aBuilding[$j][1], $aBuilding[$j][2] - 10, 120, 30, True)
			$aBuilding[$j][5] = Number($UpgradeCost)
			Local $BuildingName = $aBuilding[$j][3]
			If $g_bOptimizeOTTO Then ;set score for OptimizeOTTO Building
				For $k = 0 To UBound($g_aOptimizeOTTO) - 1
					If StringInStr($BuildingName, $g_aOptimizeOTTO[$k][0]) Then
						Switch $aBuilding[$j][0]
							Case "Gold"
								$aBuilding[$j][6] = $g_aOptimizeOTTO[$k][1] * $GoldMultiply
							Case "Elix"
								$aBuilding[$j][6] = $g_aOptimizeOTTO[$k][1] * $ElixMultiply
						EndSwitch
						$aBuilding[$j][7] = "OptimizeOTTO"
					EndIf
				Next
			EndIf
			SetDebugLog("[" & $j & "] Building: " & $BuildingName & ", Cost=" & $UpgradeCost & " Coord [" &  $aBuilding[$j][1] & "," & $aBuilding[$j][2] & "]", $COLOR_DEBUG)
		Next
	EndIf

	If $g_bOptimizeOTTO Then
		_ArraySort($aBuilding, 1, 0, 0, 6) ;sort by score
	Else
		_ArraySort($aBuilding, 0, 0, 0, 5) ;sort by cost
	EndIf

	Return $aBuilding
EndFunc

Func ClickBBBuilder($Counter = 3)
	Local $b_WindowOpened = False
	If Not $g_bRunState Then Return
	; open the builders menu
	If Not _ColorCheck(_GetPixelColor(380,73, True), "F4F4F4", 40) Then
		Click(380, 30)
		If _Sleep(1000) Then Return
	EndIf

	If IsBBBuilderMenuOpen() Then
		SetDebugLog("Open BB BuilderMenu, Success", $COLOR_SUCCESS)
		$b_WindowOpened = True
	Else
		For $i = 1 To $Counter
			SetLog("BB BuilderMenu didn't open, trying again!", $COLOR_DEBUG)
			If Not $g_bRunState Then Return
			If IsFullScreenWindow() Then
				Click(825,45)
				If _Sleep(1000) Then Return
			EndIf
			Click(380, 30)
			If _Sleep(1000) Then Return
			If IsBBBuilderMenuOpen() Then
				$b_WindowOpened = True
				ExitLoop
			EndIf
		Next
		If Not $b_WindowOpened Then
			SetLog("Something is wrong with BB BuilderMenu, already tried 3 times!", $COLOR_DEBUG)
		EndIf
	EndIf
	Return $b_WindowOpened
EndFunc ;==>ClickBBBuilder

Func IsBBBuilderMenuOpen()
	Local $bRet = False
	Local $aBorder[4] = [380, 73, 0xF4F4F4, 40]
	Local $sTriangle
	If _CheckPixel($aBorder, True) Then
		SetDebugLog("Found Border Color: " & _GetPixelColor($aBorder[0], $aBorder[1], True), $COLOR_ACTION)
		$bRet = True ;got correct color for border
	EndIf

	If Not $bRet Then ;lets re check if border color check not success
		$sTriangle = getOcrAndCapture("coc-buildermenu-main", 380, 60, 420, 30)
		SetDebugLog("$sTriangle: " & $sTriangle)
		If $sTriangle = "^" Or $sTriangle = "~" Then $bRet = True
	EndIf

	Return $bRet
EndFunc ;IsBBBuilderMenuOpen

Func getMostBottomCostBB()
	Local $TmpUpgradeCost, $TmpName, $ret
	Local $Icon = QuickMIS("CNX", $g_sImgBBResourceIcon, 400, 100, 500, 360)
	If IsArray($Icon) And UBound($Icon) > 0 Then
		_ArraySort($Icon, 1, 0, 0, 2) ;sort by y coord
		$TmpUpgradeCost = getOcrAndCapture("coc-buildermenu-cost", $Icon[0][1], $Icon[0][2] - 12, 120, 20, True) ;check most bottom upgrade cost
		$TmpName = getBuildingName($Icon[0][1] - 190, $Icon[0][2] - 8)
		$ret = $TmpName[0] & "|" & $TmpUpgradeCost
	EndIf
	Return $ret
EndFunc

Func CheckResourceForDoUpgradeBB($BuildingName, $Cost, $CostType)
	If Not $g_bRunState Then Return

	Local $Gold = getResourcesMainScreen(695, 23)
	Local $Elix = getResourcesMainScreen(695, 72)
	SetDebugLog("Gold:" & $Gold & " Elix:" & $Elix)

	; initiate a False boolean, that firstly says that there is no sufficent resource to launch upgrade
	Local $bSafeToUpgrade = False
	Switch $CostType
		Case "Gold"
			If $Gold >= $Cost Then $bSafeToUpgrade = True
		Case "Elix"
			If $Elix >= $Cost Then $bSafeToUpgrade = True
	EndSwitch
	SetLog("Checking: " & $BuildingName & ", Cost: " & $Cost & " " & $CostType, $COLOR_INFO)
	SetLog("Is Enough " & $CostType & " ? " & String($bSafeToUpgrade), $bSafeToUpgrade ? $COLOR_SUCCESS : $COLOR_ERROR)
	Return $bSafeToUpgrade
EndFunc

Func FindBHInUpgradeProgress()
	Local $bRet = False
	Local $Progress = QuickMIS("CNX", $g_sImgAUpgradeHour, 450, 100, 525, 130)
	If IsArray($Progress) And UBound($Progress) > 0 Then
		For $i = 0 To UBound($Progress) - 1
			Local $UpgradeName = getBuildingName(260, $Progress[$i][2] - 5) ;get upgrade name and amount
			If StringInStr($UpgradeName[0], "Hall", 1) Then
				$bRet = True
				ExitLoop
			EndIf
		Next
	EndIf
	Return $bRet
EndFunc

Func WaitBBUpgradeWindow()
	Local $bRet = False
	For $i = 1 To 5
		SetLog("Waiting for Upgrade Window #" & $i, $COLOR_ACTION)
		If _Sleep(1000) Then Return
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 600, 85, 770, 250) Then
			$bRet = True
			SetLog("Upgrade Window OK", $COLOR_ACTION)
			ExitLoop
		EndIf
	Next
	If Not $bRet Then SetLog("Upgrade Window Opened", $COLOR_ERROR)
	Return $bRet
EndFunc

Func TPW($region = $greenZoneBB)
	Local $bGreenCheckFound = False
	Local $xstart, $ystart
	
	For $i = 1 To 8
		SetLog("Try to Place New Wall #" & $i, $COLOR_INFO)
		If IsGreenCheck() Then
			$bGreenCheckFound = True
			For $j = 1 To 4
				SetLog("Try Placing Wall #" & $j, $COLOR_INFO)
				Click($g_iQuickMISX, $g_iQuickMISY)
				_Sleep(1000)
				If IsGemOpen(True) Then
					SetLog("Need Gem!", $COLOR_ERROR)
					If QuickMIS("BC1", $g_sImgAutoUpgradeRedX, 80, 80, 780, 600) Then Click($g_iQuickMISX, $g_iQuickMISY)
					Return False
				EndIf
			Next
		EndIf

		If Not $g_bRunState Then Return
		Local $RandomDrag = Random(-100, -80, 1)
		Local $DragX = 0, $DragY = 0
		Switch $region
			Case "Left"
				$DragX += $RandomDrag
			Case "Right"
				$DragX += Abs($RandomDrag)
			Case "Top"
				$DragY += $RandomDrag
			Case "Bottom"
				$DragY += Abs($RandomDrag)
		EndSwitch
		SetLog("Random Value [x,y] : [" & $DragX & "," & $DragY & "]", $COLOR_INFO)
		
		If Not $bGreenCheckFound Then
			SaveDebugImage("BBTryPlaceWall")
			If QuickMIS("BC1", $g_sImgAutoUpgradeRedX, 80, 80, 780, 600) Then
				$bGreenCheckFound = False
				$xstart = $g_iQuickMISX + 30
				$ystart = $g_iQuickMISY + 50
				ClickDrag($xstart, $ystart, $xstart + $DragX, $ystart + $DragY)
				_Sleep(1500)
				Switch $region
					Case "Left"
						$xstart += 120
					Case "Right"
						$xstart -= 120
					Case "Top"
						$ystart += 120
					Case "Bottom"
						$ystart -= 120
				EndSwitch
				ClickDrag($xstart + $DragX, $ystart + $DragY, $xstart, $ystart, 500)
			EndIf
		EndIf
		$bGreenCheckFound = False
	Next
EndFunc

Func IsGreenCheck()
	Local $bRet = False
	For $i = 1 To 2
		If QuickMIS("BC1", $g_sImgAutoUpgradeGreenCheck, 80, 80, 780, 600) Then
			$bRet = True ;quickmis found a check mark, lets check the color
			Local $color = _GetPixelColor($g_iQuickMISX, $g_iQuickMISY, 1)
			SetDebugLog("GreenCheck Color: " & $color)
			If _ColorCheck($color, Hex(0xF2F2F2, 6), 16) Or _ColorCheck($color, Hex(0xFDFDFD, 6), 10) Or _
				_ColorCheck($color, Hex(0xC3C3C8, 6), 10) Or _ColorCheck($color, Hex(0xA3A3AE, 6), 10) Then
				$bRet = True
				ExitLoop
			Else
				$bRet = False
			EndIf
		EndIf
		If Not $bRet Then
			If QuickMIS("BC1", $g_sImgBBWallRotate, 360, 530, 500, 610) Then 
				Click(430, 580)
				_Sleep(1000)
			Else
				Return $bRet
			EndIf
		EndIf
	Next
	Return $bRet
EndFunc