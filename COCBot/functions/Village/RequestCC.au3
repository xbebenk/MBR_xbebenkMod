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
			_makerequest($bTest, $aRequestButton[0][1], $aRequestButton[0][2])
		Case "FullOrUnavail"
			SetLog("Clan Castle is full or not available", $COLOR_DEBUG2)
	EndSwitch
	
	DonateCC(False, False, True)
	checkChatTabPixel()

	;exit from army overview
	If _Sleep($DELAYREQUESTCC1) Then Return

EndFunc   ;==>RequestCC

Func _makerequest($bTest = False, $x = 323, $y = 645) 
	
	Local $iCount = 0, $TmpX = 0, $TmpY = 0
	
	Click($x, $y, 1, 0, "Request Button") ;click button request troops	
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
		
		If $g_bUseCake Then 
			UpdateRequest()
			If QuickMis("BC1", $g_sImgSendRequestButton, 590, 540, 640, 600) Then
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(1000) Then Return
				If QuickMis("BC1", $g_sImgSendRequestButton, 450, 400, 520, 470) Then
					Click($g_iQuickMISX, $g_iQuickMISY)
				EndIf
				Return
			EndIf
		EndIf
		
		If QuickMis("BC1", $g_sImgSendRequestButton, 500, 400, 580, 560) Then ;lets check again the send button position with taller height
			If Not $bTest Then 
				Click($g_iQuickMISX, $g_iQuickMISY)
			Else
				SetLog("Emulate Click : [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_INFO)
			EndIf
		EndIf
		Return
	Else
		SetDebugLog("Request window not verified", $COLOR_DEBUG)
	EndIf
EndFunc   ;==>_makerequest

Func UpdateRequest()
	If Not $g_bChkUpdateRequest Then Return
	
	Local $aArmyReqCap, $sArmyReqCap
	Local $aSpellReqCap, $sSpellReqCap
	Local $aSiegeReqCap, $sSiegeReqCap
	Local $bNeedUpdate = False
	
	Local $sTroop1, $sSpell1, $sSiege1
	Local $sTroop2, $sSpell2, $sSiege2
	Local $aTroop, $aSpell, $aSiege
	$sTroop1 = $g_aCmbRequestTroop[$g_iCmbRequestTroop1][0]
	$sSpell1 = $g_aCmbRequestSpell[$g_iCmbRequestSpell1][0]
	$sSiege1 = $g_aCmbRequestSiege[$g_iCmbRequestSiege1][0]
	$sTroop2 = $g_aCmbRequestTroop[$g_iCmbRequestTroop2][0]
	$sSpell2 = $g_aCmbRequestSpell[$g_iCmbRequestSpell2][0]
	$sSiege2 = $g_aCmbRequestSiege[$g_iCmbRequestSiege2][0]
	
	$sArmyReqCap = getRequestCCCapacity()
	If $sArmyReqCap <> "" Then
		$aArmyReqCap = StringSplit($sArmyReqCap, "#", $STR_NOCOUNT) 
		If UBound($aArmyReqCap) = 2 Then
			SetLog("Army Request :" & $aArmyReqCap[0] & "/" & $aArmyReqCap[1], $COLOR_DEBUG)
			If $aArmyReqCap[0] <> $aArmyReqCap[1] Then
				SetLog("Request Troop <> Castle Troop Capacity", $COLOR_DEBUG)
				$bNeedUpdate = True
			EndIf
		EndIf
	EndIf
	
	$sSpellReqCap = getRequestCCCapacity(385, 148, 45, 22)
	If $sSpellReqCap <> "" Then
		$aSpellReqCap = StringSplit($sSpellReqCap, "#", $STR_NOCOUNT) 
		If UBound($aSpellReqCap) = 2 Then
			SetLog("Spell Request :" & $aSpellReqCap[0] & "/" & $aSpellReqCap[1], $COLOR_DEBUG)
			If $aSpellReqCap[0] <> $aSpellReqCap[1] Then
				SetLog("Request Spell <> Castle Spell Capacity", $COLOR_DEBUG)
				$bNeedUpdate = True
			EndIf
		EndIf
	EndIf
	
	$sSiegeReqCap = getRequestCCCapacity(385, 148, 45, 22)
	If $sSiegeReqCap <> "" Then
		$aSiegeReqCap = StringSplit($sSiegeReqCap, "#", $STR_NOCOUNT) 
		If UBound($aSiegeReqCap) = 2 Then
			SetLog("Siege Request :" & $aSiegeReqCap[0] & "/" & $aSiegeReqCap[1], $COLOR_DEBUG)
			If $aSiegeReqCap[0] <> $aSiegeReqCap[1] Then
				SetLog("Request Siege <> Castle Siege Capacity", $COLOR_DEBUG)
				$bNeedUpdate = True
			EndIf
		EndIf
	EndIf
	
	If $bNeedUpdate Then
		Click(250, 220, 1, 0, "Edit Request")
		If _Sleep(1000) Then Return
		;Remove First
		For $i = 1 To 10
			If _ColorCheck(_GetPixelColor(182, 232, True), Hex(0xE51012, 6), 20) Then
				Click(180, 225, 5, 0, "Remove Troop")
				SetLog("Removing Request Troop #" & $i, $COLOR_ACTION)
				If _Sleep(1000) Then Return
			Else
				SetLog("All Request Removed", $COLOR_ERROR)
				ExitLoop
			EndIf
		Next
		
		For $iDrag = 1 To 2
			SetLog("Check Request Troop #" & $iDrag, $COLOR_DEBUG)
			If QuickMIS("BFI", $g_sImgTrainTroops & $sTroop1 & "*", 120, 260, 740, 460) Then
				SetLog("Requesting " & $g_aCmbRequestTroop[$g_iCmbRequestTroop1][1], $COLOR_DEBUG1)
				Click($g_iQuickMISX, $g_iQuickMISY, $g_iRequestTroopQuantity1, 0, "Click " & $sTroop1)
			EndIf
			If QuickMIS("BFI", $g_sImgTrainTroops & $sTroop2 & "*", 120, 260, 740, 460) Then
				SetLog("Requesting " & $g_aCmbRequestTroop[$g_iCmbRequestTroop2][1], $COLOR_DEBUG1)
				Click($g_iQuickMISX, $g_iQuickMISY, $g_iRequestTroopQuantity2, 0, "Click " & $sTroop2)
			EndIf
			If _Sleep(500) Then Return
			ClickDrag(680, 365, 190, 365)
		Next
		
		If _Sleep(500) Then Return
		SetLog("Check Request Spell", $COLOR_DEBUG)
		$aSpell = QuickMIS("CNX", $g_sImgTrainSpells, 120, 260, 740, 460)
		If IsArray($aSpell) And Ubound($aSpell) > 0 Then
			RemoveDupCNX($aSpell, 1, 3)
			_ArraySort($aSpell, 0, 0, 0, 1) 
			For $i = 0 To Ubound($aSpell) - 1
				If $aSpell[$i][0] = $sSpell1 And $g_iRequestSpellQuantity1 > 0 Then 
					SetLog("Requesting " & $g_aCmbRequestSpell[$g_iCmbRequestSpell1][1], $COLOR_DEBUG1)
					Click($aSpell[$i][1], $aSpell[$i][2], $g_iRequestSpellQuantity1, 0, "Click " & $sSpell1)
				EndIf
				If $aSpell[$i][0] = $sSpell2 And $g_iRequestSpellQuantity2 > 0 Then
					SetLog("Requesting " & $g_aCmbRequestSpell[$g_iCmbRequestSpell2][1], $COLOR_DEBUG1)
					Click($aSpell[$i][1], $aSpell[$i][2], $g_iRequestSpellQuantity2, 0, "Click " & $sSpell2)
				EndIf
			Next
		EndIf
		
		
		ClickDrag(680, 365, 190, 365) ;clickdrag for Siege
		If _Sleep(500) Then Return
		
		SetLog("Check Request Siege", $COLOR_DEBUG)
		If QuickMIS("BFI", $g_sImgTrainSieges & $sSiege1 & "*", 120, 260, 740, 460) Then
			SetLog("Requesting " & $g_aCmbRequestSiege[$g_iCmbRequestSiege1][1], $COLOR_DEBUG1)
			Click($g_iQuickMISX, $g_iQuickMISY, $g_iRequestSiegeQuantity1, 0, "Click " & $sSiege1)
		EndIf
		If QuickMIS("BFI", $g_sImgTrainSieges & $sSiege2 & "*", 120, 260, 740, 460) Then
			SetLog("Requesting " & $g_aCmbRequestSiege[$g_iCmbRequestSiege2][1], $COLOR_DEBUG1)
			Click($g_iQuickMISX, $g_iQuickMISY, $g_iRequestSiegeQuantity2, 0, "Click " & $sSiege2)
		EndIf
		If _Sleep(500) Then Return
	EndIf
	
	Click(645, 535, 1, 0, "Click Confirm") ;Click Confirm
	If _Sleep(1000) Then Return
EndFunc
