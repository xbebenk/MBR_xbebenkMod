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

	; If is not selected return
	If $g_iChkBBSuggestedUpgrades = 0 Then Return
	Local $bDebug = $g_bDebugSetlog
	Local $bScreencap = True

	BuilderBaseReport(True)
	If $g_iFreeBuilderCountBB = 0 Then 
		SetLog("Master Builder Not Available", $COLOR_DEBUG)
		Return
	EndIf
	
	If isOnBuilderBase(True) Then
		If Not SearchGreenZoneBB() Then Return
		If ClickOnBuilder($bTest) Then
			SetLog(" - Upg Window Opened successfully", $COLOR_INFO)
			If SearchNewBuilding($bTest) Then 
				getBuilderCount(False, True)
				ClickOnBuilder($bTest)
				ClickDrag(400, 100, 400, 800, 1000);do scroll down
				If _Sleep(2000) Then Return
			Else
				ZoomOut()
				ClickAway()
				getBuilderCount(False, True)
				ClickOnBuilder($bTest)
				ClickDrag(400, 100, 400, 800, 1000);do scroll down
				If _Sleep(2000) Then Return
			EndIf
			
			If $g_iFreeBuilderCountBB = 0 Then 
				SetLog("Master Builder Not Available", $COLOR_DEBUG)
				Return True
			EndIf
			;upgrade wall first if to prevent Gold Storage become Full when BH is already Maxed
			If $g_bisBHMaxed And $g_bGoldStorageFullBB And $g_bisMegaTeslaMaxed Then
				; scroll down to bottom as wall will be on below
				ClickDrag(333, 320, 333, 0, 1000);do scroll down
				If _Sleep(2000) Then Return
			EndIf
			Local $NeedDrag = True
			For $z = 0 To 5 ;for do scroll 3 times
				If $g_bRestart Then Exitloop
				SetLog("[" & $z + 1 & "] Search Upgrade for Existing Building", $COLOR_INFO)
				Local $x = 400, $y = 100, $x1 = 540, $y1 = 130, $step = 28
				For $i = 0 To 9
					Local $bSkipGoldCheck = False
					If $g_iChkBBSuggestedUpgradesIgnoreElixir = 0 And $g_aiCurrentLootBB[$eLootElixirBB] > 250 Then
						; Proceeds with Elixir icon detection
						Local $aResult = GetIconPosition($x, $y, $x1, $y1, $g_sImgAutoUpgradeElixir, "Elixir", $bScreencap, $bDebug)
						Switch $aResult[2]
							Case "Elixir"
								Click($aResult[0], $aResult[1], 1)
								If _Sleep(2000) Then Return
								If GetUpgradeButton($aResult[2], $bDebug, $bTest) Then
									Return True
								EndIf
								$bSkipGoldCheck = True
							Case "NoResources"
								SetLog("[" & $i + 1 & "]" & " Not enough Elixir, continuing...", $COLOR_INFO)
								If $z > 2 And $i = 9 Then $NeedDrag = False ; sudah 3 kali scroll tapi yang paling bawah nol nya nggak putih
								$bSkipGoldCheck = True
							Case Else
								SetDebugLog("[" & $i + 1 & "]" & " Unsupport Elixir icon '" & $aResult[2] & "', continuing...", $COLOR_INFO)
						EndSwitch
					EndIf
					If $g_iChkBBSuggestedUpgradesIgnoreGold = 0 And $g_aiCurrentLootBB[$eLootGoldBB] > 250 And Not $bSkipGoldCheck Then
						; Proceeds with Gold coin detection
						Local $aResult = GetIconPosition($x, $y, $x1, $y1, $g_sImgAutoUpgradeGold, "Gold", $bScreencap, $bDebug)
						Switch $aResult[2]
							Case "Gold"
								Click($aResult[0], $aResult[1], 1)
								If _Sleep(2000) Then Return
								If GetUpgradeButton($aResult[2], $bDebug, $bTest) Then
									Return True
								EndIf
							Case "NoResources"
								SetLog("[" & $i + 1 & "]" & " Not enough Gold, continuing...", $COLOR_INFO)
								If $z > 2 And $i = 9 Then $NeedDrag = False ; sudah 3 kali scroll tapi yang paling bawah nol nya nggak putih
							Case Else
								SetDebugLog("[" & $i + 1 & "]" & " Unsupport Gold icon '" & $aResult[2] & "', continuing...", $COLOR_INFO)
						EndSwitch
					EndIf
					$y += $step
					$y1 += $step
				Next
				If Not $NeedDrag Then
					SetLog("[" & $z & "] Scroll Not Needed! Most Bottom Upgrade Need More resource", $COLOR_DEBUG)
					ExitLoop
				EndIf
				SetLog("[" & $z & "] Scroll Up", $COLOR_DEBUG)
				ClickDragAutoUpgradeBB($y)
			Next
		EndIf
	EndIf
	$BuildingUpgraded = False
	Zoomout()
	ClickAway("Left")
EndFunc   ;==>MainSuggestedUpgradeCode

Func ClickOnBuilder($bTest = False)
	Local $b_WindowOpened = False
	; open the builders menu
	Click(360, 11)
	If _Sleep(1000) Then Return

	If (_ColorCheck(_GetPixelColor(500, 73, True), "FFFFFF", 20) = True) Then
		SetLog("Open Upgrade Window, Success", $COLOR_SUCCESS)
		$b_WindowOpened = True
	Else
		SetLog("Upgrade Window didn't opened", $COLOR_DEBUG)
		$b_WindowOpened = False
	EndIf
	Return $b_WindowOpened
EndFunc   ;==>ClickOnBuilder

Func GetIconPosition($x, $y, $x1, $y1, $directory, $Name = "Elixir", $Screencap = True, $Debug = False)
	; [0] = x position , [1] y postion , [2] Gold, Elixir or New
	Local $aResult[3] = [-1, -1, ""]

	If QuickMIS("BC1", $directory, $x, $y, $x1, $y1, $Screencap, $Debug) Then
		; Correct positions to Check Green 'New' Building word
		Local $iYoffset = $y + $g_iQuickMISY - 15, $iY1offset = $y + $g_iQuickMISY + 7
		Local $iX = 300, $iX1 = $g_iQuickMISX + $x
		; Store the values
		$aResult[0] = $g_iQuickMISX + $x
		$aResult[1] = $g_iQuickMISY + $y
		$aResult[2] = $Name
		; The pink/salmon color on zeros
		If QuickMIS("BC1", $g_sImgAutoUpgradeNoRes, $aResult[0], $iYoffset, $aResult[0] + 100, $iY1offset, True, $Debug) Then
			; Store new values
			$aResult[2] = "NoResources"
			Return $aResult
		EndIf
		; Proceeds with 'New' detection
		If QuickMIS("BC1", $g_sImgAutoUpgradeNew, $iX, $iYoffset, $iX1, $iY1offset, True, $Debug) Then
			; Store new values
			$aResult[0] = $g_iQuickMISX + $iX + 35
			$aResult[1] = $g_iQuickMISY + $iYoffset
			$aResult[2] = "New"
		EndIf
	EndIf
	Return $aResult
EndFunc   ;==>GetIconPosition

Func GetUpgradeButton($sUpgButtom = "", $Debug = False, $bTest = False)
	Local $OptimizeOTTO[13] = ["Tower", "Mortar", "Mega Tesla", "Battle Machine", "Storage", "Gold Mine", "Collector", "Laboratory", "Hall", "D uble Cannon", "Post", "Barracks", "Wall"]
	;Local $aBtnPos = [360, 500, 180, 50] ; x, y, w, h
	Local $aBtnPos = [360, 460, 380, 120] ; x, y, w, h ; support Battke Machine, broken and upgrade
	Local $buttonUpgradeType = $sUpgButtom
	
	If $sUpgButtom = "" Then Return

	If $sUpgButtom = "Elixir" Then $sUpgButtom = $g_sImgAutoUpgradeBtnElixir
	If $sUpgButtom = "Gold" Then $sUpgButtom = $g_sImgAutoUpgradeBtnGold

	If QuickMIS("BC1", $g_sImgAutoUpgradeBtnDir, 218, 544, 662, 683, True, $Debug) Then
		Local $aBuildingName = BuildingInfo(245, 490 + $g_iBottomOffsetY)
		If $aBuildingName[0] = 2 Then
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
						If $aBuildingName[1] = "Archer Tower" And $aBuildingName[2] >= 6 Then
							SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
						ElseIf $aBuildingName[1] = "D uble Cannon" And $aBuildingName[2] >= 4 Then
							SetLog("Upgrade for Double Cannon Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
						ElseIf $aBuildingName[1] = "Multi Mortar" And $aBuildingName[2] >= 8 Then
							SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
						ElseIf $aBuildingName[1] = "Builder Barracks" And $aBuildingName[2] >= 7 Then
							SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to OptimizeOTTO", $COLOR_SUCCESS)
						;only upgrade wall if BuilderHall is Max level And If Gold Storage is Nearly Full and Mega Tesla Already Maxed
						ElseIf $aBuildingName[1] = "Wall" And $g_bisBHMaxed And $g_bGoldStorageFullBB And $g_bisMegaTeslaMaxed Then 
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
			
			Click($g_iQuickMISX + 218, $g_iQuickMISY + 544, 1)
			If _Sleep(1500) Then Return

			If QuickMIS("BC1", $sUpgButtom, 300, 480, 750, 600, True, $Debug) Then
				If Not $bTest Then 
					Click($g_iQuickMISX + 300, $g_iQuickMISY + 480, 1)
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
	Local $bDebug = $g_bDebugSetlog
	Local $bScreencap = True
	Local $NeedDrag = True
	For $z = 0 To 5 ;for do scroll 3 times
		If $g_bRestart Then Return
		Local $b_BuildingFound = False
		Local $NewCoord, $ZeroCoord
		
		Local $x = 270, $y = 73, $x1 = 540, $y1 = 103, $step = 28
		SetLog("[" & $z + 1 & "] Search for Placing New Building", $COLOR_INFO)
		For $i = 0 To 9
			$NewCoord = decodeSingleCoord(findImage("New", $g_sImgAUpgradeObst & "\New*", GetDiamondFromRect($x & "," & $y-5 & "," & $x1 & "," & $y1+5), 1, True))
			If IsArray($NewCoord) And UBound($NewCoord) = 2 Then 
				$b_BuildingFound = True ;we find New Building
				$ZeroCoord = decodeSingleCoord(findImage("Zero", $g_sImgAUpgradeZero & "\Zero*", GetDiamondFromRect($x & "," & $y-5 & "," & $x1 & "," & $y1+5), 1, True))
				If IsArray($ZeroCoord) And UBound($ZeroCoord) = 2 Then 
					SetLog("[" & $i & "] New Building found!", $COLOR_SUCCESS)
				Else
					$b_BuildingFound = False
					SetLog("[" & $i & "] Not Enough Resource!", $COLOR_SUCCESS)
					If $z > 3 And $i = 9 Then $NeedDrag = False ; sudah 4 kali scroll tapi yang paling bawah bukan new building
				EndIf
			Else
				SetLog("[" & $i & "] Not New Building", $COLOR_INFO)
				If $z > 3 And $i = 9 Then $NeedDrag = False ; sudah 4 kali scroll tapi yang paling bawah bukan new building
			EndIf
			
			If $b_BuildingFound Then 
				If NewBuildings($ZeroCoord[0], $ZeroCoord[1], $bTest) Then
					ClickMainBuilder($bTest)
					$b_BuildingFound = False ;reset
					ContinueLoop
				Else
					Return False
				EndIf
			EndIf
			$y += $step
			$y1 += $step
		Next
		If Not $NeedDrag Then
			SetLog("[" & $z & "] Scroll Not Needed! Most Bottom Upgrade Need More resource", $COLOR_DEBUG)
			ExitLoop
		EndIf
		ClickDragAutoUpgradeBB($y)
		SetLog("[" & $z & "] Scroll Up", $COLOR_DEBUG)
	Next
	SetLog("Exit Find NewBuilding", $COLOR_DEBUG)
	ZoomOut()
	ClickAway()
	Return True
EndFunc

Func ClickDragAutoUpgradeBB($y = 400)
	
	If (_ColorCheck(_GetPixelColor(500, 73, True), "FFFFFF", 20) = True) Then
		ClickDrag(333, $y - 30, 333, 93, 800);do scroll down
		If _Sleep(2500) Then Return
	Else
		SetLog("Upgrade Window didn't open, try to open it", $COLOR_DEBUG)
		If ClickOnBuilder() Then 
			ClickDrag(333, $y - 30, 333, 93, 800);do scroll down
			If _Sleep(2500) Then Return
		EndIf
	EndIf
EndFunc

Func NewBuildings($x, $y, $bTest = False)
	Local $Screencap = True, $Debug = False
	
	Click($x, $y)
	If _Sleep(3500) Then Return

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
			Click($GreenCheckCoord[0] - 75, $GreenCheckCoord[1]) ;click redX in case it exist
			Return True
		Else
			Local $RedXCoord = decodeSingleCoord(findImage("RedX", $g_sImgAutoUpgradeRedX & "\RedX*", "FV", 1, True))
			If IsArray($RedXCoord) And UBound($RedXCoord) = 2 Then 
				SetLog("Sorry! Wrong place to deploy a new building on BB! [" & $RedXCoord[0] & "," & $RedXCoord[1] & "]", $COLOR_ERROR)
				Click($RedXCoord[0], $RedXCoord[1])
			Else
				SetLog("Error on Undo symbol!", $COLOR_ERROR)
				;todo do attack bb
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
	Local $aTop = QuickMIS("CX", $g_sImgAUpgradeGreenZoneBB, 365, 200, 530, 270) ;top
	Local $aLeft = QuickMIS("CX", $g_sImgAUpgradeGreenZoneBB, 175, 360, 300, 450) ;left
	Local $aBottom = QuickMIS("CX", $g_sImgAUpgradeGreenZoneBB, 350, 530, 550, 600) ;bottom
	Local $aRight = QuickMIS("CX", $g_sImgAUpgradeGreenZoneBB, 600, 355, 760, 470) ;right
	
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

