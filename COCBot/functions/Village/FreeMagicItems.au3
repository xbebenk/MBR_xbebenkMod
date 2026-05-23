; #FUNCTION# ====================================================================================================================
; Name ..........: Collect Free Magic Items from trader
; Description ...:
; Syntax ........: CollectFreeMagicItems()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func CollectFreeMagicItems($bTest = False)
	If Not $g_bChkCollectFreeMagicItems Then Return
	$g_aRemoveFreeMagicItems[0] = False ;reset first
	SetLog("Check for collect Free Magic Items", $COLOR_INFO)
	If Not $g_bRunState Then Return
	ClickAway()

	If Not OpenTraderWindow() Then Return
	Local $Collected = False
	Local $aResults = GetFreeMagic()
	Local $aGem[3]
	For $i = 0 To UBound($aResults) - 1
		$aGem[$i] = $aResults[$i][0]
	Next
	SetLog("Magic Items: " & $aGem[0] & " | " & $aGem[1] & " | " & $aGem[2])
	
	For $i = 0 To UBound($aResults) - 1
		If $aResults[$i][0] = "FullStorage" Then 
			ClickAway()
			If _Sleep(1000) Then Return
			SellFullMagicItem()
			$aResults[$i][0] = "FREE"
			If Not OpenTraderWindow() Then Return
		EndIf
		
		If $aResults[$i][0] = "FREE" Then
			If Not $bTest Then
				Click($aResults[$i][1], $aResults[$i][2]) ;Click The Item
				If _Sleep(3000) Then Return ;delay wait SoldOut Stamp
				
				If _ColorCheck(_GetPixelColor($aResults[$i][1], 297, True), Hex(0xAD5B0D, 6), 20) Then ;Check The SoldOut Stamp
					$Collected = True
					SetLog("Free Item: " & $aResults[$i][4] & " Collected", $COLOR_INFO)
					ExitLoop
				Else
					If _ColorCheck(_GetPixelColor($aResults[$i][1] - 10, $aResults[$i][2], True), Hex(0x8DC529, 6), 10) Then ;Check if we still have Green Color
						SetLog("Free Magic Item detected", $COLOR_DEBUG)
						SetLog("But Storage on TownHall is Full", $COLOR_INFO)
						Local $Amount = StringLeft($aResults[$i][3], 1)
						$g_aRemoveFreeMagicItems[0] = True ;set Remove True
						$g_aRemoveFreeMagicItems[1] = $aResults[$i][4] ;MagicItem Name
						$g_aRemoveFreeMagicItems[2] = $Amount ;Amount To Sell (amount of Free Quiantity)
					EndIf
				EndIf
			Else
				SetLog("Should click on [" & $aResults[$i][1] & "," & $aResults[$i][2] & "]", $COLOR_DEBUG2)
			EndIf
		EndIf
	Next

	If Not $Collected Then
		SetLog("Nothing free to collect!", $COLOR_INFO)
	EndIf
	
	TradeMedal()

	If $g_aRemoveFreeMagicItems[0] Then
		ClickAway()
		If _Sleep(1000) Then Return
		SellFullMagicItem($g_aRemoveFreeMagicItems[1], $g_aRemoveFreeMagicItems[2]) ;SellFullMagicItem(Name,Amount) Try Selling Magic Item from TH Storage
	EndIf

	ClickAway()
	Return $Collected
EndFunc   ;==>CollectFreeMagicItems

Func TradeMedal()
	If Not $g_bChkEnableTradeMedal Then Return
	If $g_iLootCCMedal > 1000 Then 
		For $i = 1 To 8
			If Not $g_bRunState Then Return
			SetLog("Waiting for Raid Medal Tab #" & $i, $COLOR_ACTION)
			If QuickMis("BC1", $g_sImgTraderRaidMedal, 50, 173, 120, 320) Then
				Click($g_iQuickMISX, $g_iQuickMISY)
				SetLog("Found Raid Medal Tab", $COLOR_DEBUG)
				If _Sleep(500) Then Return
				ExitLoop
			EndIf
			If _Sleep(250) Then Return
		Next
		
		Local $bItemFound = False, $aItem
		
		For $i = 1 To 3
			ClickDrag(410, 400, 410, 180)
			If _Sleep(1000) Then Return
			SetDebugLog("[" & $i & "] Searching Item")
			$aItem = QuickMis("CNX", $g_sImgTraderRaidMedal, 215, 145, 800, 570)
			If IsArray($aItem) And UBound($aItem) > 0 Then
				SetDebugLog("Found: " & _ArrayToString($aItem))
				For $k = 0 To UBound($aItem) - 1
					Switch $aItem[$k][0]
						Case "ShinyOre"
							If $g_bChkTradeShiny Then 
								Click($aItem[$k][1], $aItem[$k][1], 1, 0, $aItem[$k][0])
								SetLog("Found Shiny Ore", $COLOR_INFO)
								$bItemFound = True
							EndIf
						Case "GlowyOre"
							If $g_bChkTradeGlowy Then 
								Click($aItem[$k][1], $aItem[$k][1], 1, 0, $aItem[$k][0])
								SetLog("Found Glowy Ore", $COLOR_INFO)
								$bItemFound = True
							EndIf
						Case "StarryOre"
							If $g_bChkTradeStarry Then 
								Click($aItem[$k][1], $aItem[$k][1], 1, 0, $aItem[$k][0])
								SetLog("Found Starry Ore", $COLOR_INFO)
								$bItemFound = True
							EndIf
						Case "BuilderGold"
							If $g_bChkTradeBuilderGold Then 
								Click($aItem[$k][1], $aItem[$k][1], 1, 0, $aItem[$k][0])
								SetLog("Found Builder Gold", $COLOR_INFO)
								$bItemFound = True
							EndIf
						Case "BuilderElixir"
							If $g_bChkTradeBuilderElix Then 
								Click($aItem[$k][1], $aItem[$k][1], 1, 0, $aItem[$k][0])
								SetLog("Found Builder Elixir", $COLOR_INFO)
								$bItemFound = True
							EndIf
						Case "ClockTowerPot"
							If $g_bChkTradeClockTowerPot Then 
								Click($aItem[$k][1], $aItem[$k][1], 1, 0, $aItem[$k][0])
								SetLog("Found ClockTower Potion", $COLOR_INFO)
								$bItemFound = True
							EndIf
						Case "ResearchPot"
							If $g_bChkTradeResearchPot Then 
								Click($aItem[$k][1], $aItem[$k][1], 1, 0, $aItem[$k][0])
								SetLog("Found Research Potion", $COLOR_INFO)
								$bItemFound = True
							EndIf
					EndSwitch
					
					If $bItemFound Then
						If IsBuyDealPage() Then 
							Click(500, 440)
							SetLog("Trade Medal with Magic Item", $COLOR_SUCCESS)
							If _Sleep(1000) Then Return
						EndIf
					EndIf
					
					$bItemFound = False
				Next
			EndIf
		Next
	Else
		SetLog("Skip TradeMedal, Capital Medal: " & $g_iLootCCMedal, $COLOR_DEBUG2)
	EndIf
EndFunc

Func IsBuyDealPage()
	Local $bRet = False
	For $i = 1 To 3 
		If WaitforPixel(500, 440, 501, 440, Hex(0x82CC2C, 6), 10, 1, "IsBuyDealPage") Then
			$bRet = True
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	Return $bRet
EndFunc

Func GetFreeMagic()
	Local $aOcrPositions[3][2] = [[270, 329], [470, 329], [660, 329]]
	Local $aResults[0][5]
	Local $bClaimed = False, $bFullStorage = False
	For $i = 0 To UBound($aOcrPositions) - 1
		Local $Read = getOcrAndCapture("coc-freemagicitems", $aOcrPositions[$i][0], $aOcrPositions[$i][1], 120, 25, True)
		Local $Capa = getOcrAndCapture("coc-buildermenu-name", $aOcrPositions[$i][0], 197, 70, 25, True)
		SetDebugLog("Magic Item Capacity: " & $Capa)
		$bClaimed = _ColorCheck(_GetPixelColor($aOcrPositions[$i][0], 297, True), Hex(0xAD5B0D, 6), 20)
		$bFullStorage = _ColorCheck(_GetPixelColor($aOcrPositions[$i][0], $aOcrPositions[$i][1], True), Hex(0xA3A3A3, 6), 20)
		;If $Read = "FREE" And StringLeft($Capa, 1) = "0" Then $Read = "Claimed"
		If $Read = "FREE" And $bClaimed Then $Read = "Claimed"
		If $Read = "FREE" And $bFullStorage Then $Read = "FullStorage"
		If $Read = "" Then $Read = "N/A"
		If Number($Read) > 10 Then
			$Read = $Read & " Gems"
		EndIf
		Local $MagicItemName = ""
		If QuickMIS("BC1", $g_sImgTraderWindow, $aOcrPositions[$i][0] - 50, $aOcrPositions[$i][1] - 110, $aOcrPositions[$i][0] + 100, $aOcrPositions[$i][1] - 20) Then
			$MagicItemName = $g_sQuickMISName
		EndIf
		_ArrayAdd($aResults, $Read & "|" & $aOcrPositions[$i][0] & "|" & $aOcrPositions[$i][1] & "|" & $Capa & "|" & $MagicItemName)
	Next
	Return $aResults
EndFunc

Func OpenTraderWindow()
	Local $bRet = False, $bTraderIconFound = False
	ZoomOut()
	; Check Trader Icon on Main Village
	For $i = 1 To 10
		If Not $g_bRunState Then Return
		SetDebugLog("Waiting Trader Icon #" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgTrader, 80, 60, 230, 220) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(500) Then Return
			$bTraderIconFound = True
			ExitLoop
		EndIf
		If _Sleep(500) Then Return
	Next
	
	If Not $bTraderIconFound Then 
		SetLog("Cannot find Trader Icon", $COLOR_DEBUG2)
		Return $bRet
	EndIf
	
	If Not IsTraderWindowOpen() Then 
		SetLog("Free Magic Items Windows not Opened", $COLOR_DEBUG2)
		ClickAway()
	Else
		$bRet = True
	EndIf
	Return $bRet
EndFunc

Func IsTraderWindowOpen()
	Local $bRet = False
	For $i = 1 To 8
		If Not $g_bRunState Then Return
		SetLog("Waiting for TraderWindowOpen #" & $i, $COLOR_ACTION)
		If _ColorCheck(_GetPixelColor(808, 107, True), Hex(0xFFFFFF, 6), 10, Default, "IsTraderWindowOpen") Then
			$bRet = True
			ExitLoop
		EndIf
		If _Sleep(250) Then Return
	Next
	
	For $i = 1 To 8
		If Not $g_bRunState Then Return
		SetLog("Waiting for Gems Tab #" & $i, $COLOR_ACTION)
		If QuickMis("BC1", $g_sImgTraderGems, 50, 173, 100, 300) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			SetLog("Found Gems Tab", $COLOR_DEBUG)
			If _Sleep(500) Then Return
			$bRet = True
			ExitLoop
		EndIf
		If _Sleep(250) Then Return
	Next
	
	Return $bRet
EndFunc

Func MagicItemCount($x = 210, $y = 250)
	Local $Row1 = 300
	Local $aMagicPosX[5] = [198, 302, 406, 510, 610]
	Local $aMagicPosY[2] = [279, 379]
	Local $sRead = ""
	Local $Col = 0
	For $i = 0 To UBound($aMagicPosX) - 1
		If $x > $aMagicPosX[$i] Then $Col = $i
		If $x < $aMagicPosX[$i] Then ExitLoop
	Next
	
	If $y < $Row1 Then 
		$sRead = getOcrAndCapture("coc-Builders", $aMagicPosX[$Col], $aMagicPosY[0], 60, 20, True)
	Else
		$sRead = getOcrAndCapture("coc-Builders", $aMagicPosX[$Col], $aMagicPosY[1], 60, 20, True)
	EndIf
	If $g_bDebugSetlog Then SetDebugLog("sRead : " & $sRead)
	Return $sRead
EndFunc

Func SellFullMagicItem($MagicItem = "", $Amount = 0)
	If Not $g_bRunState Then Return
	SetLog("Checking for Full Magic Items", $COLOR_INFO)
	If Not OpenMagicItemWindow() Then Return
	
	If $MagicItem = "" And $Amount = 0 Then 
		Local $Items = QuickMIS("CNX", $g_sImgTraderWindow, 160, 200, 700, 300)
		Local $sReadItemCount = 0
		If IsArray($Items) And UBound($Items) > 0 Then 
			For $i = 0 To UBound($Items) - 1
				
				$sReadItemCount = MagicItemCount($Items[$i][1], $Items[$i][2])
				If $sReadItemCount = 5 Then 
					Click($Items[$i][1], $Items[$i][2])
					If _Sleep(2000) Then Return
					If _ColorCheck(_GetPixelColor(550, 505, True), Hex(0xF51D21, 6), 20) Then ;Check Red Sell Button
						Click(550, 505) ;Click Sell Button
						If _Sleep(1500) Then Return
						If IsOKCancelPage() Then
							Click(510, 425) ;Click Okay Button
						EndIf
					EndIf
					If _Sleep(1500) Then Return
				EndIf
			Next
		EndIf
		ClickAway()
		Return
	EndIf
	
	Local $aSearch = decodeSingleCoord(findImage($MagicItem, $g_sImgTraderWindow & $MagicItem & "*", GetDiamondFromRect("160, 200, 700, 400")))
	If IsArray($aSearch) And UBound($aSearch) = 2 Then
		For $i = 1 To $Amount
			Click($aSearch[0], $aSearch[1])
			If _Sleep(2000) Then Return
			If _ColorCheck(_GetPixelColor(550, 505, True), Hex(0xF51D21, 6), 20) Then ;Check Red Sell Button
				Click(550, 505) ;Click Sell Button
				If _Sleep(1500) Then Return
				If _ColorCheck(_GetPixelColor(510, 425, True), Hex(0x6DBC1F, 6), 20) Then
					Click(510, 425) ;Click Okay Button
				EndIf
			Else
				SetLog("Unable to Open Sell Window for item " & $MagicItem, $COLOR_DEBUG2)
				ClickAway()
				ExitLoop
			EndIf
			If _Sleep(1500) Then Return
		Next
	Else
		SetLog("Unable to find " & $MagicItem, $COLOR_DEBUG2)
	EndIf
	ClickAway()
EndFunc

Func SellMagicItem($bTest = False)
	ClickAway()
	If _Sleep(500) Then Return
	If Not $g_bChkEnableSellMagicItem Then Return
	SetLog("Checking for Sell Magic Items", $COLOR_INFO)
	If Not OpenMagicItemWindow() Then Return
	Local $sReadItemCount, $asReadItemCount, $Count, $MaxCount
	
	For $i = 0 To UBound($g_aSellMagicItem) - 1
		SetDebugLog($g_aMagicItemName[$i] & " : " & $g_aSellMagicItem[$i])
		SetLog("Checking for sell " & $g_aMagicItemName[$i], $COLOR_INFO)
		If $g_aSellMagicItem[$i] Then
			Local $aSearch = decodeSingleCoord(findImage($g_aMagicItemName[$i], $g_sImgTraderWindow & $g_aMagicItemName[$i] & "*", GetDiamondFromRect("160, 200, 700, 400")))
			If IsArray($aSearch) And UBound($aSearch) = 2 Then 
				$Count = 0
				$MaxCount = 0
				$sReadItemCount = MagicItemCount($aSearch[0], $aSearch[1])
				Local $asReadItemCount = StringSplit($sReadItemCount, "#", $STR_NOCOUNT)
				If IsArray($asReadItemCount) And UBound($asReadItemCount) = 2 Then
					$Count = $asReadItemCount[0]
					$MaxCount = $asReadItemCount[1]
				EndIf
				SetLog($g_aMagicItemName[$i] & " Count: " & $Count, $COLOR_INFO) 
				If $Count > 0 Then 
					For $j = 1 To $Count
						Click($aSearch[0], $aSearch[1])
						If _Sleep(1000) Then Return
						If _ColorCheck(_GetPixelColor(260, 530, True), Hex(0xF71E22, 6), 20) Then ;Check Red Sell Button
							Click(260, 500) ;Click Sell Button
							If _Sleep(1000) Then Return
							If IsOKCancelPage() Then
								If Not $bTest Then 
									Click(530, 425) ;Click Okay Button
								Else
									ClickAway()
								EndIf
								SetLog("[" & $j & "] Selling " & $g_aMagicItemName[$i], $COLOR_SUCCESS)
							EndIf
						Else
							SetLog("Unable to Open Sell Window for item " & $g_aMagicItemName[$i], $COLOR_ERROR)
							ClickAway()
							ExitLoop
						EndIf
						If _Sleep(1000) Then Return
					Next
				Else
					SetLog("Unable to read count of " & $g_aMagicItemName[$i], $COLOR_DEBUG2)
					ContinueLoop
				EndIf
			Else
				SetLog($g_aMagicItemName[$i] & " not Found", $COLOR_DEBUG2)
			EndIf
		Else
			SetLog($g_aMagicItemName[$i] & " Sell is not enabled", $COLOR_DEBUG2)
		EndIf
	Next
	ClickAway()
	;Return $aMagic
EndFunc

Func OpenMagicItemWindow()
	Local $bRet = False
	Local $bLocateTH = False
	Click($g_aiTownHallPos[0], $g_aiTownHallPos[1])
	If _Sleep(500) Then Return
	
	If Not $g_bRunState Then Return
	Local $BuildingInfo = BuildingInfo(242, 477)
	If $BuildingInfo[1] = "Town Hall" Then
		SetLog("Opening Magic Item Window", $COLOR_ACTION)
		If ClickB("MagicItem") Then
			$bRet = True
		EndIf
	Else
		$bLocateTH = True
		ClickAway()
		If _Sleep(500) Then Return
	EndIf
	
	If Not $g_bRunState Then Return
	If $bLocateTH Then
		If SearchTH(True, False) Then 
			If _Sleep(500) Then Return
			If ClickB("MagicItem") Then
				$bRet = True
			Else 
				$bRet = False
			EndIf
		EndIf
	EndIf
	If Not IsMagicItemWindowOpen() Then 
		$bRet = False
		SetLog("Open Magic Item Window failed", $COLOR_DEBUG2)
	EndIf
	Return $bRet
EndFunc

Func IsMagicItemWindowOpen()
	Local $bRet = False
	For $i = 1 To 10
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 650, 125, 750, 210) Then
			$bRet = True
			ExitLoop
		Else
			SetDebugLog("Waiting for FreeMagicWindowOpen #" & $i, $COLOR_ACTION)
		EndIf
		If _Sleep(250) Then Return
	Next
	If _Sleep(200) Then Return
	Return $bRet
EndFunc

Func TestMagicItemImage()
	For $i = 0 To UBound($g_aSellMagicItem) - 1
		Local $Count = 0, $MaxCount = 0
		SetDebugLog($g_aMagicItemName[$i] & " Sell enabled: " &$g_aSellMagicItem[$i])
		SetLog("Checking " & $g_aMagicItemName[$i], $COLOR_INFO)
		Local $aSearch = decodeSingleCoord(findImage($g_aMagicItemName[$i], $g_sImgTraderWindow & $g_aMagicItemName[$i] & "*", GetDiamondFromRect("160, 200, 700, 400")))
		If IsArray($aSearch) And UBound($aSearch) = 2 Then 
			$Count = 0
			$MaxCount = 0
			Local $sReadItemCount = MagicItemCount($aSearch[0], $aSearch[1])
			Local $asReadItemCount = StringSplit($sReadItemCount, "#", $STR_NOCOUNT)
			If IsArray($asReadItemCount) And UBound($asReadItemCount) = 2 Then
				$Count = $asReadItemCount[0]
				$MaxCount = $asReadItemCount[1]
			EndIf
			SetLog($g_aMagicItemName[$i] & " Count: " & $Count & "/" & $MaxCount, $COLOR_INFO) 
		EndIf
	Next
EndFunc

Func UseFreeMagicItem()
	If Not $g_bRunState Then Return
	Local $x, $y
	checkMainScreen()
	SetLog("Checking for Magic Item on Box", $COLOR_INFO)
	If QuickMIS("BC1", $g_sImgMagicItemBox, 525, 610, 675, 650) Then
		SetLog("Magic Box Found, checking items", $COLOR_ACTION)
		$x = $g_iQuickMISX
		$y = $g_iQuickMISY
		If _PixelSearch($x + 23, $y - 11, $x + 24, $y - 10, Hex(0xE41528, 6), 20, 1, "Check Red Item Count") Or _PixelSearch($x + 23, $y - 9, $x + 24, $y - 8, Hex(0xCB1429, 6), 20, 1, "Check Red Item Count") Then
			Click($x, $y)
			If _Sleep(500) Then Return
			SetLog("Free Magic Item Found, Try to Use", $COLOR_ACTION)
			If QuickMIS("BC1", $g_sImgMagicItemBox, 300, 560, 650, 580) Then
				$x = $g_iQuickMISX + 15
				$y = $g_iQuickMISY + 40
				Click($x, $y)
				If _Sleep(500) Then Return
				If $g_sQuickMISName = "Full" And $g_bChkSellItemFromMagicBox Then
					If WaitforPixel(345, 520, 346, 520, Hex(0xF71E22, 6), 10, 1, "FreeMagicItem Full") Then 
						Click(260, 510, 1, 0, "Sell magic Item")
						If _Sleep(500) Then Return
						If IsOKCancelPage() Then Click(530, 425)
						SetLog("Succesfully, Sell Magic item", $COLOR_SUCCESS)
					EndIf
				EndIf
				
				If WaitforPixel(600, 525, 601, 526, Hex(0x8BD43A, 6), 10, 1, "UseFreeMagicItem") Then 
					Click(600, 520)
					If _Sleep(500) Then Return
					If IsOKCancelPage() Then Click(530, 425)
					SetLog("Succesfully, use Magic item", $COLOR_SUCCESS)
				EndIf
			EndIf
		Else
			SetLog("No Item detected", $COLOR_DEBUG2)
		EndIf
	Else
		SetLog("No Magic Box Detected", $COLOR_DEBUG2)
	EndIf
EndFunc