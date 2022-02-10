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
	If Not $g_bChkCollectFreeMagicItems Or Not $g_bRunState Then Return
	$g_bRemoveFreeMagicItems = False ;reset first
	Local Static $iLastTimeChecked[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] 
	If $iLastTimeChecked[$g_iCurAccount] = @MDAY And Not $bTest Then Return
	SetLog("Collecting Free Magic Items", $COLOR_INFO)
	If Not $g_bRunState Then Return
	ClickAway()
	
	If Not OpenTraderWindow() Then Return 
	$iLastTimeChecked[$g_iCurAccount] = @MDAY
	Local $Collected = False
	Local $aResults = GetFreeMagic()
	Local $aGem[3]
	For $i = 0 To UBound($aResults) - 1
		$aGem[$i] = $aResults[$i][0]
	Next
	For $i = 0 To UBound($aResults) - 1
		If $aResults[$i][0] = "FREE" Then
			If Not $bTest Then
				Click($aResults[$i][1], $aResults[$i][2])
			Else
				SetLog("Should click on [" & $aResults[$i][1] & "," & $aResults[$i][2] & "]", $COLOR_ERROR)
			EndIf
			SetLog("Free Magic Item detected", $COLOR_INFO)
			If _Sleep(1000) Then Return
			$Collected = True
			ExitLoop
		EndIf
	Next
	
	If Not $Collected Then 
		If QuickMIS("BC1", $g_sImgFree, 160, 400, 320, 450, True, False) Then
			If Not $bTest Then
				Click($g_iQuickMISX, $g_iQuickMISY)
				SetLog("Try Collect Special Offer By Image, Success", $COLOR_SUCCESS)
				If _Sleep(1000) Then Return
				$Collected = True
			Else
				SetLog("Try Collect Special Offer By Image, ONLY TEST!", $COLOR_ERROR)
			EndIf
		EndIf
	EndIf
	
	If Not $Collected Then 
		SetLog("Nothing free to collect!", $COLOR_INFO)
		SetLog("Daily Discounts: " & $aGem[0] & " | " & $aGem[1] & " | " & $aGem[2])
	EndIf
	
	ClickAway()
	Return $Collected
EndFunc   ;==>CollectFreeMagicItems

Func GetFreeMagic()
	Local $aOcrPositions[3][2] = [[203, 411], [400, 411], [590, 411]]
	Local $aResults[0][3]
	For $i = 0 To 2
		Local $Read = getOcrAndCapture("coc-freemagicitems", $aOcrPositions[$i][0], $aOcrPositions[$i][1], 200, 25, True)
		If $Read = "FREE" Then 
			If WaitforPixel($aOcrPositions[$i][0] - 10, $aOcrPositions[$i][1], $aOcrPositions[$i][0] - 9, $aOcrPositions[$i][1] + 1, "7A7A7A", 10, 1) Then
				$g_bRemoveFreeMagicItems = True
			EndIf
		EndIf
		If $Read = "" Then $Read = "N/A"
		If Number($Read) > 10 Then 
			$Read = $Read & " Gems"
		EndIf
		_ArrayAdd($aResults, $Read & "|" & $aOcrPositions[$i][0] & "|" & $aOcrPositions[$i][1])
	Next
	If $g_bRemoveFreeMagicItems Then
		Redim $aResults[0][3]
		SetLog("Free Magic Item detected", $COLOR_INFO)
		SetLog("But Storage on TownHall is Full", $COLOR_INFO)
		ClickAway()
		SaleFreeMagics()
		OpenTraderWindow()
		For $i = 0 To 2
			Local $Read = getOcrAndCapture("coc-freemagicitems", $aOcrPositions[$i][0], $aOcrPositions[$i][1], 200, 25, True)
			If $Read = "FREE" Then 
				If WaitforPixel($aOcrPositions[$i][0] - 10, $aOcrPositions[$i][1], $aOcrPositions[$i][0] - 9, $aOcrPositions[$i][1] + 1, "7A7A7A", 10, 1) Then
					$g_bRemoveFreeMagicItems = True
				EndIf
			EndIf
			If $Read = "" Then $Read = "N/A"
			If Number($Read) > 10 Then 
				$Read = $Read & " Gems"
			EndIf
			_ArrayAdd($aResults, $Read & "|" & $aOcrPositions[$i][0] & "|" & $aOcrPositions[$i][1])
		Next
	Else
		Return $aResults
	EndIf
EndFunc

Func OpenTraderWindow()
	Local $bRet = False
	If Not IsMainPage() Then Return	
	; Check Trader Icon on Main Village
	If QuickMIS("BC1", $g_sImgTrader, 120,130,230,220) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
	Else
		SetLog("Trader Icon Not Found", $COLOR_INFO)
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
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 650, 125, 750, 210) Then
			$bRet = True
			ExitLoop
		Else
			SetDebugLog("Waiting for FreeMagicWindowOpen #" & $i, $COLOR_ACTION)
		EndIf
		_Sleep(500)
	Next
	Return $bRet
EndFunc

Func SaleFreeMagics()
	Local $aMagicPosX[5] = [198, 302, 406, 510, 614]
	Local $aMagicPosY = 280
	If Not OpenMagicItemWindow() Then Return
	For $i = 0 To UBound($aMagicPosX) - 1
		Local $MagicItemCount = getBuilders($aMagicPosX[$i], $aMagicPosY)
		Local $ItemCount = StringSplit($MagicItemCount, "#", $STR_NOCOUNT)
		If $ItemCount[0] > 4 Then 
			Click($aMagicPosX[$i], $aMagicPosY)
			If _Sleep(1000) Then Return
			Click(600, 500)
			If _Sleep(1000) Then Return
			Click(500, 400)
		Else
			SetLog("MagicItem[" & $i & "] Count: " & $ItemCount[0] & "/" & $ItemCount[1]) 
		EndIf
		If _Sleep(1000) Then Return
	Next
	ClickAway()
EndFunc

Func OpenMagicItemWindow()
	Local $bRet = False
	Local $bLocateTH = False
	Click($g_aiTownHallPos[0], $g_aiTownHallPos[1])
	If _Sleep(1000) Then Return
	
	Local $BuildingInfo = BuildingInfo(245, 494)
	If $BuildingInfo[1] = "Town Hall" Then
		SetDebugLog("Opening Magic Item Window")
		If ClickB("MagicItem") Then 
			$bRet = True
		EndIf
	Else
		$bLocateTH = True
	EndIf
	
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
	Return $bRet
EndFunc

Func SaleHeroTroopPot()
	Local $aMagicPosY = 280
	ClickAway()
	If _Sleep(1000) Then Return
	If Not OpenMagicItemWindow() Then Return
	Local $Sell = False
	Local $Pot = QuickMIS("CNX", $g_sImgHeroPotion, 160, 200, 700, 300)
	If IsArray($Pot) And UBound($Pot) > 0 Then
		For $i = 0 To UBound($Pot) - 1
			Local $MagicItemCount = getBuilders($Pot[$i][1]-30, $aMagicPosY) 
			Local $ItemCount = StringSplit($MagicItemCount, "#", $STR_NOCOUNT)
			SetLog("MagicItem: " & $Pot[$i][0] & " Count: " & $ItemCount[0] & "/" & $ItemCount[1])
			Switch $Pot[$i][0]
				Case "HeroPot", "PowerPot"
					For $y = 1 To $ItemCount[0]
						SetLog("Selling " & $Pot[$i][0])
						Click($Pot[$i][1], $aMagicPosY)
						If _Sleep(1000) Then Return
						Click(600, 500)
						If _Sleep(1000) Then Return
						Click(500, 400)
						If _Sleep(1000) Then Return
						$Sell = True
					Next
			EndSwitch
			If _Sleep(1000) Then Return
			If $Sell Then ExitLoop
		Next
	Else
		SetDebugLog("MagicItem No Array")
	EndIf
	ClickAway()
EndFunc