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
	Local Static $iLastTimeChecked[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	If $iLastTimeChecked[$g_iCurAccount] = @MDAY And Not $bTest Then Return
	SetLog("Collecting Free Magic Items", $COLOR_INFO)
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
		If $aResults[$i][0] = "FREE" Then
			If Not $bTest Then
				Click($aResults[$i][1], $aResults[$i][2]) ;Click The Item
				If _Sleep(3000) Then Return ;delay wait SoldOut Stamp
				If _GetPixelColor($aResults[$i][1], 297, True) Then ;Check The SoldOut Stamp
					$Collected = True
					SetLog("Free Item: " & $aResults[$i][4] & " Collected", $COLOR_INFO)
					$iLastTimeChecked[$g_iCurAccount] = @MDAY
					ExitLoop
				Else
					If _ColorCheck(_GetPixelColor($aResults[$i][1] - 10, $aResults[$i][2], True), Hex(0x8DC529, 6), 10) Then ;Check if we still have Green Color
						SetLog("Free Magic Item detected", $COLOR_INFO)
						SetLog("But Storage on TownHall is Full", $COLOR_INFO)
						Local $Amount = StringLeft($aResults[$i][3], 1)
						$g_aRemoveFreeMagicItems[0] = True ;set Remove True
						$g_aRemoveFreeMagicItems[1] = $aResults[$i][4] ;MagicItem Name
						$g_aRemoveFreeMagicItems[2] = $Amount ;Amount To Sell (amount of Free Quiantity)
					EndIf
				EndIf
			Else
				SetLog("Should click on [" & $aResults[$i][1] & "," & $aResults[$i][2] & "]", $COLOR_ERROR)
			EndIf
		EndIf
	Next

	If Not $Collected Then
		SetLog("Nothing free to collect!", $COLOR_INFO)
	EndIf

	If $g_aRemoveFreeMagicItems[0] Then
		ClickAway()
		If _Sleep(1000) Then Return
		SaleFullMagicItem($g_aRemoveFreeMagicItems[1], $g_aRemoveFreeMagicItems[2]) ;SaleFullMagicItem(Name,Amount) Try Selling Magic Item from TH Storage
	EndIf

	ClickAway()
	Return $Collected
EndFunc   ;==>CollectFreeMagicItems

Func GetFreeMagic()
	Local $aOcrPositions[3][2] = [[285, 322], [465, 322], [635, 322]]
	Local $aResults[0][5]
	For $i = 0 To UBound($aOcrPositions) - 1
		Local $Read = getOcrAndCapture("coc-freemagicitems", $aOcrPositions[$i][0], $aOcrPositions[$i][1], 200, 25, True)
		Local $Capa = getOcrAndCapture("coc-buildermenu-name", $aOcrPositions[$i][0], 209, 100, 25, True)
		SetDebugLog("Magic Item Capacity: " & $Capa)
		If $Read = "FREE" And StringLeft($Capa, 1) = "0" Then $Read = "Claimed"
		If $Read = "" Then $Read = "N/A"
		If Number($Read) > 10 Then
			$Read = $Read & " Gems"
		EndIf
		Local $MagicItemName = ""
		If QuickMIS("BC1", $g_sImgTraderWindow, $aOcrPositions[$i][0] - 50, $aOcrPositions[$i][1] - 110, $aOcrPositions[$i][0] + 100, $aOcrPositions[$i][1] - 20) Then
			$MagicItemName = $g_iQuickMISName
		EndIf
		_ArrayAdd($aResults, $Read & "|" & $aOcrPositions[$i][0] & "|" & $aOcrPositions[$i][1] & "|" & $Capa & "|" & $MagicItemName)
	Next
	Return $aResults
EndFunc

Func OpenTraderWindow()
	Local $bRet = False
	If Not IsMainPage() Then Return
	; Check Trader Icon on Main Village
	If QuickMIS("BC1", $g_sImgTrader, 120,130,230,220) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
	Else
		SetLog("Trader Icon Not Found", $COLOR_INFO)
		Return False
	EndIf
	If Not IsFreeMagicWindowOpen() Then 
		SetLog("Free Magic Items Windows not Opened", $COLOR_ERROR)
		ClickAway()
	Else
		$bRet = True
	EndIf
	Return $bRet
EndFunc

Func IsFreeMagicWindowOpen()
	Local $bRet = False
	For $i = 1 To 8
		If Not $g_bRunState Then Return
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 730, 110, 780, 150) Then
			$bRet = True
			ExitLoop
		Else
			SetDebugLog("Waiting for FreeMagicWindowOpen #" & $i, $COLOR_ACTION)
		EndIf
		_Sleep(500)
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

Func SaleFullMagicItem($MagicItem = "", $Amount = 0)
	If Not $g_bRunState Then Return
	SetLog("Checking for Sale Magic Items", $COLOR_INFO)
	If Not OpenMagicItemWindow() Then Return
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
				SetLog("Unable to Open Sell Window for item " & $MagicItem, $COLOR_ERROR)
				ClickAway()
				ExitLoop
			EndIf
			If _Sleep(1500) Then Return
		Next
	Else
		SetLog("Unable to find " & $MagicItem, $COLOR_ERROR)
	EndIf
	ClickAway()
EndFunc

Func SaleMagicItem($bTest = False)
	ClickAway()
	If _Sleep(500) Then Return
	If Not $g_bChkEnableSaleMagicItem Then Return
	SetLog("Checking for Sale Magic Items", $COLOR_INFO)
	If Not OpenMagicItemWindow() Then Return
	Local $sReadItemCount, $asReadItemCount, $Count, $MaxCount
	
	For $i = 0 To UBound($g_aSaleMagicItem) - 1
		SetDebugLog($g_aMagicItemName[$i] & ":" &$g_aSaleMagicItem[$i])
		SetLog("Checking for sell " & $g_aMagicItemName[$i], $COLOR_INFO)
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
				If $g_aSaleMagicItem[$i] Then
					For $j = 1 To $Count
						Click($aSearch[0], $aSearch[1])
						If _Sleep(1000) Then Return
						If _ColorCheck(_GetPixelColor(550, 505, True), Hex(0xF51D21, 6), 20) Then ;Check Red Sell Button
							Click(550, 505) ;Click Sell Button
							If _Sleep(1000) Then Return
							If _ColorCheck(_GetPixelColor(510, 425, True), Hex(0x6DBC1F, 6), 20) Then
								If Not $bTest Then 
									Click(510, 425) ;Click Okay Button
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
				EndIf
			Else
				SetLog("Unable to read count of " & $g_aMagicItemName[$i], $COLOR_ERROR)
				ContinueLoop
			EndIf
		Else
			SetLog($g_aMagicItemName[$i] & " not Found", $COLOR_ERROR)
		EndIf
	Next
	ClickAway()
	;Return $aMagic
EndFunc

Func OpenMagicItemWindow()
	Local $bRet = False
	Local $bLocateTH = False
	Click($g_aiTownHallPos[0], $g_aiTownHallPos[1])
	If _Sleep(1000) Then Return
	
	If Not $g_bRunState Then Return
	Local $BuildingInfo = BuildingInfo(245, 494)
	If $BuildingInfo[1] = "Town Hall" Then
		SetDebugLog("Opening Magic Item Window")
		If ClickB("MagicItem") Then
			$bRet = True
		EndIf
	Else
		$bLocateTH = True
	EndIf
	
	If Not $g_bRunState Then Return
	If $bLocateTH Then
		If imglocTHSearch(False, True, True) Then ClickP($g_aiTownHallPos)
		If _Sleep(1000) Then Return
		If ClickB("MagicItem") Then
			$bRet = True
		EndIf
	EndIf
	If Not IsMagicItemWindowOpen() Then $bRet = False
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
		_Sleep(500)
	Next
	_Sleep(1000)
	Return $bRet
EndFunc

Func TestMagicItemImage()
	For $i = 0 To UBound($g_aSaleMagicItem) - 1
		Local $Count = 0, $MaxCount = 0
		SetDebugLog($g_aMagicItemName[$i] & " sale enabled: " &$g_aSaleMagicItem[$i])
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