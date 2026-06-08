; #FUNCTION# ====================================================================================================================
; Name ..........: RequestCC
; Description ...:
; Syntax ........: RequestCC()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......: Sardo(06-2015), KnowJack(10-2015), Sardo (08-2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func RequestCC($sText = "", $bTest = False)

	If Not $g_bRequestTroopsEnable Then Return
	If Not $g_bRunState Then Return
	
	If checkChatTabPixel() Then
		Click($aChatTabClosed[0], $aChatTabClosed[1]) ;Click ClanChatOpen
	EndIf
	
	If _Sleep(1000) Then Return
	CheckIUnderstand()
	
	SetLog("Requesting Clan Castle reinforcements", $COLOR_INFO)
	
	If Not $g_bRunState Then Return
	Local $aRequestButton = QuickMIS("CNX", $g_sImgRequestCCButton, 280, 600, 360, 670)
	If UBound($aRequestButton) < 1 Then
		SetLog("RequestCC: Request button not detected", $COLOR_DEBUG2)
		checkChatTabPixel()
		Return
	EndIf

	If Not $g_bRunState Then Return
	
	Switch $aRequestButton[0][0]
		Case "AlreadyMade"
			SetLog("Clan Castle Request has already been made", $COLOR_DEBUG2)
		Case "Available"
			If _GetPixelColor(333, 654, True) = "ADADAD" Then ContinueCase 
			_makerequest($aRequestButton[0][1], $aRequestButton[0][2], $bTest)
		Case "FullOrUnavail"
			SetLog("Clan Castle is full or not available", $COLOR_DEBUG2)
	EndSwitch
	
	DonateCC(False, False, True)
	checkChatTabPixel()

	;exit from army overview
	If _Sleep($DELAYREQUESTCC1) Then Return

EndFunc   ;==>RequestCC

Func _makerequest($x = 315, $y = 645, $bTest = False)
	
	Local $iCount = 0, $TmpX = 0, $TmpY = 0
	Click($x, $y, 1, 0, "0336") ;click button request troops	
	Local $RequestWindowOpen = False
	If _Sleep(500) Then Return
	For $i = 1 To 10
		SetDebugLog("Wait for Send Request Window #" & $i, $COLOR_ACTION)
		If QuickMis("BC1", $g_sImgSendRequestButton, 500, 400, 580, 560) Then 
			$TmpX = $g_iQuickMISX
			$TmpY = $g_iQuickMISY
			SetDebugLog("_makerequest: Request window open", $COLOR_ACTION)
			$RequestWindowOpen = True
			ExitLoop
		EndIf
		If _Sleep(250) Then Return
	Next
	
	If $RequestWindowOpen Then 
		If $g_sRequestTroopsText <> "" Then
			Click($TmpX - 50, $TmpY - 60) ;click text box 
			If _Sleep(500) Then Return
			If SendText($g_sRequestTroopsText) = 0 Then ;type the request
				ClickAway()
			EndIf
		EndIf
		
		If QuickMis("BC1", $g_sImgSendRequestButton, 500, 400, 580, 560) Then ;lets check again the send button position with taller height
			If Not $bTest Then 
				Click($g_iQuickMISX, $g_iQuickMISY)
			Else
				SetLog("Emulate Click : [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_INFO)
			EndIf
		EndIf
		If _Sleep(500) Then Return
		$g_bCanRequestCC = False
		Return
	Else
		SetDebugLog("Send request button not found", $COLOR_DEBUG)
	EndIf
EndFunc   ;==>_makerequest

Func RemoveCastleArmy($aToRemove)

	If _ArrayMax($aToRemove, 0, -1, -1, 1) = 0 Then Return

	; Click 'Edit Army'
	If Not _CheckPixel($aBtnEditArmy, True) Then ; If no 'Edit Army' Button found in army tab to edit troops
		SetLog("Cannot find/verify 'Edit Army' Button in Army tab", $COLOR_WARNING)
		Return False ; Exit function
	EndIf

	ClickP($aBtnEditArmy, 1) ; Click Edit Army Button
	If Not $g_bRunState Then Return

	If _Sleep(500) Then Return

	; Click remove Troops & Spells
	Local $aPos[2] = [35, 520]
	For $i = 0 To UBound($aToRemove) - 1
		If $aToRemove[$i][1] > 0 Then
			$aPos[0] = $aToRemove[$i][0] + 35
			If $i = 7 Then $aPos[0] = 650 ; x-coordinate of Siege machine slot
			SetDebugLog(" - Click at slot " & $i & ". (" & $aPos[0] & ") x " & $aToRemove[$i][1])
			ClickRemoveTroop($aPos, $aToRemove[$i][1], $g_iTrainClickDelay) ; Click on Remove button as much as needed
		EndIf
	Next

	If _Sleep(400) Then Return

	; Click Okay & confirm
	Local $counter = 0
	While Not _CheckPixel($aBtnRemOK1, True) ; If no 'Okay' button found in army tab to save changes
		If _Sleep(200) Then Return
		$counter += 1
		If $counter <= 5 Then ContinueLoop
		SetLog("Cannot find/verify 'Okay' Button in Army tab", $COLOR_WARNING)
		ClickAway()
		If _Sleep(400) Then OpenArmyOverview("RemoveCastleSpell()") ; Open Army Window AGAIN
		Return False ; Exit Function
	WEnd

	ClickP($aBtnRemOK1, 1) ; Click on 'Okay' button to save changes

	If _Sleep(400) Then Return

	$counter = 0
	While Not _CheckPixel($aBtnRemOK2, True) ; If no 'Okay' button found to verify that we accept the changes
		If _Sleep(200) Then Return
		$counter += 1
		If $counter <= 5 Then ContinueLoop
		SetLog("Cannot find/verify 'Okay #2' Button in Army tab", $COLOR_WARNING)
		ClickAway()
		Return False ; Exit function
	WEnd

	ClickP($aBtnRemOK2, 1) ; Click on 'Okay' button to Save changes... Last button

	SetLog("Clan Castle army removed", $COLOR_SUCCESS)
	If _Sleep(200) Then Return
	Return True
EndFunc   ;==>RemoveCastleArmy
