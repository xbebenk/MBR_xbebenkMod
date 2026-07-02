; #FUNCTION# ====================================================================================================================
; Name ..........: LocateLab
; Description ...:
; Syntax ........: LocateLab()
; Parameters ....:
; Return values .: None
; Author ........: KnowJack (June 2015)
; Modified ......: Sardo 2015-08
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func LocateLab($bCollect = True)
	; reset position
	$g_aiLaboratoryPos[0] = -1
	$g_aiLaboratoryPos[1] = -1

	; auto locate 
	AutoLocateLab()
	
	SetLog("Laboratory: (" & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1] & ")", $COLOR_DEBUG)
 
	If $g_aiLaboratoryPos[1] = "" Or $g_aiLaboratoryPos[1] = -1 Then _LocateLab($bCollect) ; manual locate
EndFunc

Func _LocateLab($bCollect = True)
	Local $stext, $MsgBox, $sErrorText = "" ; $iStupid & $iSilly removed
	
	If $g_iTownHallLevel < 3 Then
		SetLog("Townhall Lvl " & $g_iTownHallLevel & " has no Lab, so skip locating.", $COLOR_ACTION)
		Return
	EndIf

	SetLog("Locating Laboratory", $COLOR_INFO)

	WinGetAndroidHandle()
	checkMainScreen()
	If $bCollect Then Collect(True)

	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, Default, Default, 12, Default, 600)
		$stext = $sErrorText & @CRLF & "Click OK then click on your Laboratory building" & @CRLF & @CRLF & _
				"Please make sure your village is completely visible." & @CRLF & @CRLF & _
				"Do not click on anything else while locating!" & @CRLF
		$MsgBox = _ExtMsgBox(0, "Ok|Cancel", "Locate PetHouse", $stext, 15)
		
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway()
			Local $aPos = FindPos()
			$g_aiLaboratoryPos[0] = Int($aPos[0])
			$g_aiLaboratoryPos[1] = Int($aPos[1])
			If isInsideDiamond($g_aiLaboratoryPos) = False Then
				$sErrorText = "Laboratory Location Not Valid! Please try again." & @CRLF
				SetLog("Location not valid, try again", $COLOR_ERROR)
				ContinueLoop ; Langsung ulang loop tanpa pesan aneh
			EndIf
		Else
			SetLog("Locate Laboratory Cancelled", $COLOR_INFO)
			ClickAway()
			Return
		EndIf
		Local $sLabInfo = BuildingInfo(); 860x780
		If $sLabInfo[0] > 1 Or $sLabInfo[0] = "" Then
			If StringInStr($sLabInfo[1], "Lab") = 0 Then
				$sErrorText = "That is not the Laboratory, it was " & $sLabInfo[1] & ". Please try again!" & @CRLF
				SetLog("Selected wrong building (" & $sLabInfo[1] & "), try again", $COLOR_ERROR)
				ContinueLoop
			EndIf
		Else
			SetLog(" Operator Error - Bad Laboratory Location: " & "(" & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1] & ")", $COLOR_ERROR)
			$g_aiLaboratoryPos[0] = -1
			$g_aiLaboratoryPos[1] = -1
			ClickAway()
			Return False
		EndIf
		SetLog("Locate Laboratory Success: " & "(" & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1] & ")", $COLOR_SUCCESS)
		ExitLoop
	WEnd
	ClickAway()

EndFunc   ;==>LocateLab
