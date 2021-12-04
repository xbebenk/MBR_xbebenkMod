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
		$g_iChkBBSuggestedUpgradesOTTO = 1
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreGold, $GUI_DISABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreElixir, $GUI_DISABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreHall, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreWall, BitOR($GUI_CHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkPlacingNewBuildings, BitOR($GUI_CHECKED, $GUI_DISABLE))
		$g_iChkPlacingNewBuildings = True
		$g_iChkBBSuggestedUpgradesIgnoreWall = True
	Else
		$g_iChkBBSuggestedUpgradesOTTO = 0
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
Local $BuildingUpgraded = False

; MAIN CODE
Func AutoUpgradeBB($bTest = False)
	If $g_bRestart Then Return
	; If is not selected return
	If $g_iChkBBSuggestedUpgrades = 0 Then Return
	Local $bDebug = $g_bDebugImageSave
	Local $bScreencap = True
	
	If Not AutoUpgradeBBCheckBuilder($bTest) Then Return
	BuilderBaseReport(True)
	
	If isOnBuilderBase(True) Then
		If ClickOnBuilder($bTest) Then
			SetLog(" - Upg Window Opened successfully", $COLOR_INFO)
			If $g_iChkPlacingNewBuildings Then
				If SearchNewBuilding($bTest) Then
					ClickOnBuilder($bTest)
					ClickDrag(400, 100, 400, 800, 1000);do scroll down
					If _Sleep(5000) Then Return
					If $g_bRestart Then Return
				Else
					ZoomOut()
					ClickAway()
					ClickOnBuilder($bTest)
					ClickDrag(400, 100, 400, 800, 1000);do scroll down
					If _Sleep(5000) Then Return
					If $g_bRestart Then Return
				EndIf
			EndIf

			If Not AutoUpgradeBBCheckBuilder($bTest) Then Return
			Local $NeedDrag = True
			For $z = 0 To 4 ;for do scroll 5 times
				If _Sleep(50) Then Return
				If $g_bRestart Then Return
				SetLog("[" & $z & "] Search Upgrade for Existing Building", $COLOR_DEBUG)
				Local $x = 270, $y = 73, $x1 = 540, $y1 = 103, $step = 28
				For $i = 0 To 9
					If _Sleep(20) Then Return
					If $g_bRestart Then Return
					Local $bSkipGoldCheck = False
					Local $BuildingFound = False
					If $g_iChkBBSuggestedUpgradesIgnoreElixir = 0 And $g_aiCurrentLootBB[$eLootElixirBB] > 250 Then
						; Proceeds with Elixir icon detection
						Local $aResult = GetIconPosition($x, $y, $x1, $y1, $g_sImgAutoUpgradeElixir, "Elixir", $bScreencap, $bDebug)
						Switch $aResult[2]
							Case "Elixir"
								$bSkipGoldCheck = True
								If $g_iChkBBSuggestedUpgradesOTTO Then
									If QuickMIS("BC1", $g_sImgAUpgradeOttoBB, 260, $y, 450, $y1, $bScreencap, $bDebug) Then
										SetLog("[" & $i & "] Optimize OTTO Building Found!", $COLOR_SUCCESS)
										Click($g_iQuickMISX + 260, $g_iQuickMISY + $y)
										$BuildingFound = True
									Else
										SetLog("[" & $i & "] Not Optimize OTTO Building", $COLOR_INFO)
										$BuildingFound = False
									EndIf
								Else
									SetLog("[" & $i & "] Upgrade Found!", $COLOR_SUCCESS)
									Click($aResult[0], $aResult[1])
									$BuildingFound = True
								EndIf
								If $BuildingFound Then
									If _Sleep(2000) Then Return
									If GetUpgradeButton($aResult[2], $bDebug, $bTest) Then
										$BuildingFound = False ;reset
										$z = 0 ;reset
										Return True
									EndIf
								EndIf
							Case "NoResources"
								SetLog("[" & $i + 1 & "]" & " Not enough Elixir, continuing...", $COLOR_INFO)
								If $z > 2 And $i = 9 Then $NeedDrag = False ; sudah 3 kali scroll tapi yang paling bawah nol nya nggak putih
								$bSkipGoldCheck = True
							Case Else
								SetDebugLog("[" & $i & "]" & " Unsupport Elixir icon '" & $aResult[2] & "', continuing...", $COLOR_INFO)
						EndSwitch
					EndIf
					If $g_iChkBBSuggestedUpgradesIgnoreGold = 0 And $g_aiCurrentLootBB[$eLootGoldBB] > 250 And Not $bSkipGoldCheck Then
						; Proceeds with Gold coin detection
						Local $aResult = GetIconPosition($x, $y, $x1, $y1, $g_sImgAutoUpgradeGold, "Gold", $bScreencap, $bDebug)
						Switch $aResult[2]
							Case "Gold"
								If $g_iChkBBSuggestedUpgradesOTTO Then
									If QuickMIS("BC1", $g_sImgAUpgradeOttoBB, 260, $y, 450, $y1, $bScreencap, $bDebug) Then
										SetLog("[" & $i & "] Optimize OTTO Building Found!", $COLOR_SUCCESS)
										Click($g_iQuickMISX + 260, $g_iQuickMISY + $y)
										$BuildingFound = True
									Else
										SetLog("[" & $i & "] Not Optimize OTTO Building", $COLOR_INFO)
										$BuildingFound = False
									EndIf
								Else
									SetLog("[" & $i & "] Upgrade Found!", $COLOR_SUCCESS)
									Click($aResult[0], $aResult[1])
									$BuildingFound = True
								EndIf
								If $BuildingFound Then
									If _Sleep(2000) Then Return
									If GetUpgradeButton($aResult[2], $bDebug, $bTest) Then
										$BuildingFound = False ;reset
										$z = 0 ;reset
										Return True
									Else
										ClickOnBuilder($bTest)
									EndIf
								EndIf
							Case "NoResources"
								SetLog("[" & $i & "]" & " Not enough Gold, continuing...", $COLOR_INFO)
								If $z > 2 And $i = 9 Then $NeedDrag = False ; sudah 3 kali scroll tapi yang paling bawah nol nya nggak putih
							Case Else
								SetDebugLog("[" & $i & "]" & " Unsupport Gold icon '" & $aResult[2] & "', continuing...", $COLOR_INFO)
						EndSwitch
					EndIf
					$y += $step
					$y1 += $step
				Next
				
				If Not AutoUpgradeBBCheckBuilder($bTest) Then Return
				If Not $NeedDrag Then
					SetLog("[" & $z & "] Scroll Not Needed! Most Bottom Upgrade Need More resource", $COLOR_DEBUG)
					ExitLoop
				EndIf
				SetLog("[" & $z & "] Scroll Up", $COLOR_DEBUG)
				ClickDragAutoUpgradeBB("up", $y)
			Next
		EndIf
	EndIf
	$BuildingUpgraded = False
	Zoomout()
	ClickAway("Left")
EndFunc   ;==>MainSuggestedUpgradeCode

Func ClickOnBuilder($bTest = False, $Counter = 1)
	Local $b_WindowOpened = False
	; open the builders menu
	If Not _ColorCheck(_GetPixelColor(500, 73, True), "FFFFFF", 20) Then
		Click(360, 11)
		If _Sleep(1000) Then Return
	EndIf
	If _ColorCheck(_GetPixelColor(500, 73, True), "FFFFFF", 20) Then
		SetLog("Open Upgrade Window, Success", $COLOR_SUCCESS)
		$b_WindowOpened = True
	Else
		If ($Counter < 4) Then
			SetLog("Upgrade Window didn't opened, trying again!", $COLOR_DEBUG)
			If IsFullScreenWindow() Then 
				Click(825,45)
				If _Sleep(1000) Then Return
			EndIf
			ClickOnBuilder(False, $Counter)
			$Counter += 1
		Else
			SetLog("Something is wrong with upgrade window, already tried 3 times!", $COLOR_DEBUG)
			$b_WindowOpened = False
		EndIf
	EndIf
	Return $b_WindowOpened
EndFunc   ;==>ClickOnBuilder

Func GetIconPosition($x, $y, $x1, $y1, $directory, $Name = "Elixir", $Screencap = True, $Debug = False)
	; [0] = x position , [1] y postion , [2] Gold, Elixir or New
	Local $aResult[3] = [-1, -1, ""]

	If QuickMIS("BC1", $directory, $x, $y, $x1, $y1, $Screencap, $Debug) Then
		; Correct positions to Check Green 'New' Building word
		; Store the values
		$aResult[0] = $g_iQuickMISX + $x
		$aResult[1] = $g_iQuickMISY + $y
		$aResult[2] = $Name
		; The pink/salmon color on zeros
		If QuickMIS("BC1", $g_sImgAutoUpgradeNoRes, $x, $y, $x1, $y1, True, $Debug) Then
			; Store new values
			$aResult[2] = "NoResources"
			Return $aResult
		EndIf
		; Proceeds with 'New' detection
		If QuickMIS("BC1", $g_sImgAutoUpgradeNew, $x, $y, $x1, $y1, True, $Debug) Then
			; Store new values
			$aResult[0] = $g_iQuickMISX + $x + 35
			$aResult[1] = $g_iQuickMISY + $y
			$aResult[2] = "New"
		EndIf
	EndIf
	Return $aResult
EndFunc   ;==>GetIconPosition

Func GetUpgradeButton($sUpgButtom = "", $Debug = False, $bTest = False)
	Local $OptimizeOTTO[12] = ["Tower", "Mortar", "Mega Tesla", "Battle Machine", "Storage", "Gold Mine", "Collector", "Laboratory", "Hall", "Double", "Barracks", "Wall"]
	Local $bCheck = False
	Local $aBuildingName = BuildingInfo(245, 494)
	
	If $sUpgButtom = "" Then Return
	If $sUpgButtom = "OptimizeOTTO" Then
		SetLog("Checking OptimizeOTTO Priority Building", $COLOR_INFO)
		Switch $aBuildingName[1]
			Case "Builder Hall"
				$sUpgButtom = $g_sImgAutoUpgradeBtnGold
			Case "Elixir Storage"
				$sUpgButtom = $g_sImgAutoUpgradeBtnGold
			Case "Gold Storage"
				$sUpgButtom = $g_sImgAutoUpgradeBtnElixir
			Case "Star Laboratory"
				$sUpgButtom = $g_sImgAutoUpgradeBtnElixir
		EndSwitch
	EndIf
	
	If $sUpgButtom = "Elixir" Then $sUpgButtom = $g_sImgAutoUpgradeBtnElixir
	If $sUpgButtom = "Gold" Then $sUpgButtom = $g_sImgAutoUpgradeBtnGold

	If QuickMIS("BC1", $g_sImgAutoUpgradeBtnDir, 218, 514, 662, 653, True, $Debug) Then
		If $aBuildingName[0] = 2 Then
			If $aBuildingName[1] = "D uble Cannon" Then $aBuildingName[1] = "Double Cannon"
			SetLog("Building: " & $aBuildingName[1], $COLOR_INFO)
			; Verify if is Builder Hall and If is to Upgrade
			If StringInStr($aBuildingName[1], "Hall") And $g_iChkBBSuggestedUpgradesIgnoreHall Then
				SetLog("Ups! Builder Hall is not to Upgrade!", $COLOR_ERROR)
				Return False
			EndIf

			Local $FoundOTTOBuilding = False
			If $g_iChkBBSuggestedUpgradesOTTO Then
				;check the upgrade until reach spesific level
				For $i = 0 To UBound($OptimizeOTTO) - 1
					If StringInStr($aBuildingName[1], $OptimizeOTTO[$i]) Then
						;SetLog("Trying to upgrade : " & $aBuildingName[1] & " Level: " & $aBuildingName[2], $COLOR_SUCCESS)
						If $aBuildingName[1] = "Archer Tower" And $aBuildingName[2] >= 6 And Not $g_bisMegaTeslaMaxed Then
							SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
						ElseIf $aBuildingName[1] = "Double Cannon" And $aBuildingName[2] >= 4 And Not $g_bisMegaTeslaMaxed Then
							SetLog("Upgrade for Double Cannon Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
						ElseIf $aBuildingName[1] = "Multi Mortar" And $aBuildingName[2] >= 8 And Not $g_bisMegaTeslaMaxed Then
							SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
						ElseIf $aBuildingName[1] = "Builder Barracks" And $aBuildingName[2] >= 7 Then
							SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
						;only upgrade wall if BuilderHall is Max level And If Gold Storage is Nearly Full and Mega Tesla Already Maxed
						ElseIf $aBuildingName[1] = "Wall" And $g_bisBHMaxed And $g_bGoldStorage50BB And $g_bisMegaTeslaMaxed Then
							SetLog("BuilderHall is Maxed, Mega Tesla is Maxed, Gold Storage Near Full", $COLOR_INFO)
							SetLog("Will Upgrade " & $aBuildingName[1] & " Level: " & $aBuildingName[2], $COLOR_SUCCESS)
							$sUpgButtom = $g_sImgAutoUpgradeBtnGold ;force to use Gold for upgrading wall on BB
							$g_iChkBBSuggestedUpgradesIgnoreWall = 0
							$FoundOTTOBuilding = True
							ExitLoop
						Else
							$FoundOTTOBuilding = True
							ExitLoop
						EndIf
					EndIf
				Next
				If Not $FoundOTTOBuilding Then
					;SetLog("Building skipped due to OptimizeOTTO", $COLOR_DEBUG)
					Return False
				EndIf
			EndIf

			If StringInStr($aBuildingName[1], "Wall") And $g_iChkBBSuggestedUpgradesIgnoreWall Then
				SetLog("Ups! Wall is not to Upgrade!", $COLOR_ERROR)
				Return False
			EndIf

			Click($g_iQuickMISX + 218, $g_iQuickMISY + 514, 1)
			If _Sleep(1500) Then Return

			If QuickMIS("BC1", $sUpgButtom, 300, 410, 760, 620, True, $Debug) Then
				If Not $bTest Then
					Click($g_iQuickMISX + 300, $g_iQuickMISY + 410, 1)
					BBAutoUpgradeLog($aBuildingName)
				Else
					SetLog("Only for Test!", $COLOR_ERROR)
					ClickAway("Left")
					Return False
				EndIf
				If _Sleep(1500) Then Return
				;ClickAway("Left")
				If isGemOpen(True) Then
					SetLog("Upgrade stopped due to insufficient loot", $COLOR_ERROR)
					ClickAway("Left")
					If _Sleep(500) Then Return
					ClickAway("Left")
					Return False
				Else
					SetLog($aBuildingName[1] & " Upgrading!", $COLOR_INFO)
					$BuildingUpgraded = True
					ClickAway("Left")
					Return True
				EndIf
			Else
				ClickAway("Left")
				$BuildingUpgraded = True
				SetLog("Not enough Resources to Upgrade " & $aBuildingName[1] & " !", $COLOR_ERROR)
			EndIf
		EndIf
	EndIf

	Return False
EndFunc   ;==>GetUpgradeButton

Func SearchNewBuilding($bTest = False)
	Local $bDebug = $g_bDebugImageSave
	Local $bScreencap = True
	Local $NeedDrag = True, $ZoomedIn = False, $FoundMostBottomRed = 0
	
	For $z = 0 To 6 ;for do scroll 3 times
		If _Sleep(50) Then Return
		If Not $g_bRunState Then Return
		Local $New, $NewCoord, $aCoord[0][2], $ZeroCoord
		Local $x = 180, $y = 80, $x1 = 480, $y1 = 103, $step = 28
		$NewCoord = QuickMIS("CX", $g_sImgAUpgradeObstNew, 280, 73, 430, 370, True) ;find New Building
		If IsArray($NewCoord) And UBound($NewCoord) > 0 Then 
			If Not $g_bRunState Then Return
			SetLog("Found " & UBound($NewCoord) & " New Building", $COLOR_INFO)
			For $j = 0 To UBound($NewCoord)-1
				$New = StringSplit($NewCoord[$j], ",", $STR_NOCOUNT)
				_ArrayAdd($aCoord, $New[0]+280 & "|" & $New[1]+73)
			Next
			_ArraySort($aCoord, 0, 0, 0, 1)
			For $j = 0 To UBound($aCoord) - 1
				If Not $g_bRunState Then Return
				If $g_bSkipWallPlacingOnBB Then
					If QuickMIS("N1", $g_sImgAUpgradeWall, $aCoord[$j][0] - 50, $aCoord[$j][1] - 10, $aCoord[$j][0] + 100, $aCoord[$j][1] + 10, True) = "Wall" Then
						SetLog("[" & $j & "] New Building: " & $aCoord[$j][0] & "," & $aCoord[$j][1] & ", Is Wall, skip!", $COLOR_INFO)
						ContinueLoop
					EndIf
				EndIf
				If QuickMIS("BC1", $g_sImgAUpgradeZero & "\", $aCoord[$j][0] + 100, $aCoord[$j][1] - 8, $aCoord[$j][0] + 250, $aCoord[$j][1] + 8, True) Then
					SetLog("[" & $j & "] New Building: " & $aCoord[$j][0] & "," & $aCoord[$j][1], $COLOR_INFO)
					ClickAway()
					If _Sleep(1000) Then Return
					If Not $ZoomedIn Then
						If SearchGreenZoneBB() Then 
							$ZoomedIn = True
						Else
							ExitLoop 2 ;zoomin failed, cancel placing newbuilding
						EndIf
					EndIf
					ClickOnBuilder($bTest)
					If NewBuildings($aCoord[$j][0], $aCoord[$j][1], $bTest) Then
						ClickOnBuilder($bTest)
						ExitLoop
					Else
						ExitLoop 2 ;Place NewBuilding failed, cancel placing newbuilding
					EndIf
				Else
					SetLog("[" & $j & "] New Building: " & $aCoord[$j][0] & "," & $aCoord[$j][1] & " Not Enough Resource", $COLOR_ERROR)
				EndIf
			Next
			
		EndIf
		If Not $g_bRunState Then Return
		If $g_iChkBBSuggestedUpgradesOTTO Then ;add add BuiderHall and Storage for priority upgrade on optimize OTTO
			If QuickMIS("BC1", $g_sImgAUpgradeOttoBBPriority, 270, 80, 540, 370, True) Then
				SetLog("Found OptimizeOTTO Priority Building", $COLOR_INFO)
				Local $tmpX = $g_iQuickMISX + 270, $tmpY = $g_iQuickMISY + 80
				If QuickMIS("BC1", $g_sImgAUpgradeZero & "\", $tmpX, $tmpY - 10, $tmpX + 200, $tmpY + 10) Then
					Click($g_iQuickMISX + $tmpX, $g_iQuickMISY + $tmpY - 10)
					GetUpgradeButton("OptimizeOTTO", False, $bTest)
				Else
					SetLog("But No resource", $COLOR_SUCCESS)
					If QuickMIS("N1", $g_sImgAUpgradeOttoBBPriority & "\", $tmpX - 100, $tmpY - 10, $tmpX + 50, $tmpY + 10, True) = "BuilderHall" Then
						SetLog("Found BuiderHall for Upgrade = No NewBuilding", $COLOR_INFO)
						ExitLoop
					EndIf
				EndIf 
			EndIf
		EndIf
		If Not $g_bRunState Then Return
		Local $aZeroWhiteMostBottom = _PixelSearch(523, 348, 527, 363, Hex(0xFFFFFF, 6), 10)
		If $aZeroWhiteMostBottom = 0 Then
			$FoundMostBottomRed += 1
			SetLog("No WhiteZero at most bottom list", $COLOR_DEBUG)
		ElseIf $FoundMostBottomRed > 0 Then
			$FoundMostBottomRed -= 1
			SetLog("Found WhiteZero at most bottom list", $COLOR_DEBUG)
		EndIf
		If $z > 1 And $FoundMostBottomRed > 1 Then $NeedDrag = False
		
		If Not $NeedDrag Then
			SetLog("[" & $z & "] Scroll Not Needed!", $COLOR_DEBUG)
			ExitLoop
		EndIf
		ClickDragAutoUpgradeBB("up")
		SetLog("[" & $z & "] Scroll Up", $COLOR_DEBUG)
		If Not AutoUpgradeBBCheckBuilder($bTest) Then Return
	Next
	SetLog("Exit Find NewBuilding", $COLOR_DEBUG)
	ZoomOut()
	Return True
EndFunc

Func ClickDragAutoUpgradeBB($Direction = "up", $YY = Default, $DragCount = 1)
	Local $x = 450, $yUp = 125, $yDown = 800, $Delay = 500
	If $YY = Default Then $YY = 330
	For $checkCount = 0 To 2
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(500, 73, True), "FFFFFF", 20) Then ;check upgrade window border
			Switch $Direction
				Case "Up"
					If $YY < 100 Then $YY = 150
					If $DragCount > 1 Then
						For $i = 1 To $DragCount
							ClickDrag($x, $YY, $x, $yUp, $Delay) ;drag up
						Next
					Else
						ClickDrag($x, $YY, $x, $yUp, $Delay) ;drag up
					EndIf
					If _Sleep(1000) Then Return
				Case "Down"
					ClickDrag($x, $yUp, $x, $yDown, $Delay) ;drag to bottom
					If _Sleep(5000) Then Return
			EndSwitch
		EndIf
		If _ColorCheck(_GetPixelColor(500, 73, True), "FFFFFF", 20) Then ;check upgrade window border
			SetLog("Upgrade Window Exist", $COLOR_INFO)
			Return True
		Else
			SetLog("Upgrade Window Gone!", $COLOR_DEBUG)
			ClickOnBuilder()
			If _Sleep(1000) Then Return
		EndIf
	Next
	Return False
EndFunc

Func NewBuildings($x, $y, $bTest = False)
	Local $Screencap = True, $Debug = False

	Click($x, $y)
	If _Sleep(5000) Then Return

	;Search the arrow
	Local $ArrowCoordinates = decodeSingleCoord(findImage("BBNewBuildingArrow", $g_sImgArrowNewBuilding, GetDiamondFromRect("40,200,860,600"), 1, True, Default))
	If UBound($ArrowCoordinates) > 1 Then
		;Check if its wall or not (wall should skip)
		If $g_bSkipWallPlacingOnBB Then
			If QuickMIS("BC1", $g_sImgisWall, $ArrowCoordinates[0] - 150, $ArrowCoordinates[1] - 50, $ArrowCoordinates[0], $ArrowCoordinates[1], $Screencap, $Debug) Then
				SetLog("New Building is Wall!, Cancelling...", $COLOR_INFO)
				Click(820, 38, 1) ; exit from Shop
				If _Sleep(2000) Then Return
				ClickOnBuilder($bTest)
				Return False
			EndIf
		EndIf

		Click($ArrowCoordinates[0] - 50, $ArrowCoordinates[1] + 50)
		If _Sleep(2500) Then Return
		; Lets search for the Correct Symbol on field
		Local $GreenCheckCoord = decodeSingleCoord(findImage("GreenCheck", $g_sImgAutoUpgradeGreenCheck & "\GreenCheck*", "FV", 1, True))
		If IsArray($GreenCheckCoord) And UBound($GreenCheckCoord) = 2 Then
			SetLog("Placed a new Building on Builder Island! [" & $GreenCheckCoord[0] & "," & $GreenCheckCoord[1] & "]", $COLOR_SUCCESS)
			If Not $bTest Then
				Click($GreenCheckCoord[0], $GreenCheckCoord[1])
			EndIf
			If _Sleep(1000) Then Return
			Click($GreenCheckCoord[0], $GreenCheckCoord[1]) ;click GreenCheck in case it exist
			Click($GreenCheckCoord[0] - 75, $GreenCheckCoord[1]) ;click redX in case it exist
			BBAutoUpgradeLog()
			Return True
		Else
			Local $RedXCoord = decodeSingleCoord(findImage("RedX", $g_sImgAutoUpgradeRedX & "\RedX*", "FV", 1, True))
			If IsArray($RedXCoord) And UBound($RedXCoord) = 2 Then
				SetLog("Sorry! Wrong place to deploy a new building on BB! [" & $RedXCoord[0] & "," & $RedXCoord[1] & "]", $COLOR_ERROR)
				Click($RedXCoord[0], $RedXCoord[1])
			Else
				SetLog("Error on Undo symbol!", $COLOR_ERROR)
				;todo do attack bb
				GoAttackBBAndReturn()
				Return False
			EndIf
			Return True
		EndIf
	Else
		SetLog("Cannot find Orange Arrow", $COLOR_ERROR)
		Click(820, 38, 1) ; exit from Shop
	EndIf
	Return False
EndFunc   ;==>NewBuildings

Func SearchGreenZoneBB()
	SetLog("Search GreenZone on BB for Placing new Building", $COLOR_INFO)
	Local $aTop = QuickMIS("CX", $g_sImgAUpgradeGreenZoneBB, 360, 160, 500, 230) ;top
	Local $aLeft = QuickMIS("CX", $g_sImgAUpgradeGreenZoneBB, 200, 280, 290, 410) ;left
	Local $aBottom = QuickMIS("CX", $g_sImgAUpgradeGreenZoneBB, 375, 440, 520, 525) ;bottom
	Local $aRight = QuickMIS("CX", $g_sImgAUpgradeGreenZoneBB, 550, 300, 650, 400) ;right

	Local $aAll[4][2] = [["Top", UBound($aTop)], ["Left", UBound($aLeft)], ["Bottom", UBound($aBottom)], ["Right", UBound($aRight)]]
	If $g_bDebugClick Then SetLog("Top:" & UBound($aTop) & " Left:" & UBound($aLeft) & " Bottom:" & UBound($aBottom) & " Right:" & UBound($aRight))
	_ArraySort($aAll,1,0,0,1)
	If $g_bDebugClick Then SetLog($aAll[0][0] & ":" & $aAll[0][1] & "|" & $aAll[1][0] & ":" & $aAll[1][1] & "|" & $aAll[2][0] & ":" & $aAll[2][1] & "|" & $aAll[3][0] & ":" & $aAll[3][1] & "|", $COLOR_DEBUG)

	If $aAll[0][1] > 0 Then
		SetLog("Found GreenZone, On " & $aAll[0][0] & " Region", $COLOR_SUCCESS)
		If ZoomInBB($aAll[0][0]) Then
			SetLog("Succeed ZoomIn", $COLOR_DEBUG)
			Return True
		Else
			SetLog("Failed ZoomIn", $COLOR_ERROR)
		EndIf
	Else
		SetLog("GreenZone for Placing new Building Not Found", $COLOR_DEBUG)
	EndIf
	Return False
EndFunc

Func GoAttackBBAndReturn()
	ZoomOut()
	SetLog("Going attack, to clear field", $COLOR_DEBUG)
	Click(60,600) ;click attack button
	_AttackBB()
	ZoomOut()
	SetLog("Field should be clear now", $COLOR_DEBUG)
EndFunc

Func BBAutoUpgradeLog($aUpgradeNameLevel = Default)
	Local $txtAcc = $g_iCurAccount
	Local $txtAccName = $g_asProfileName[$g_iCurAccount]

	If $aUpgradeNameLevel = Default Then
		$aUpgradeNameLevel = BuildingInfo(242, 494)
		If $aUpgradeNameLevel[0] = "" Then
			SetLog("Error when trying to get upgrade name and level", $COLOR_ERROR)
			$aUpgradeNameLevel[1] = "Traps"
		EndIf
		_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, _
				@CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - BB Placing New Building: " & $aUpgradeNameLevel[1])

		_FileWriteLog($g_sProfileLogsPath & "\AutoUpgradeHistory.log", " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - BB Placing New Building: " & $aUpgradeNameLevel[1])
	Else
		_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, _
				@CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - BB Upgrading " & $aUpgradeNameLevel[1] & _
				" to level " & $aUpgradeNameLevel[2] + 1)

		_FileWriteLog($g_sProfileLogsPath & "\AutoUpgradeHistory.log", " [" & $txtAcc + 1 & "] " & $txtAccName & _
				" - Upgrading " & $aUpgradeNameLevel[1] & _
				" to level " & $aUpgradeNameLevel[2] + 1)
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
