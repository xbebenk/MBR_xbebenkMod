; #FUNCTION# ====================================================================================================================
; Name ..........: LocateBlacksmith
; Description ...:
; Syntax ........: LocateBlacksmith()
; Parameters ....:
; Return values .: None
; Author ........: Moebius14 (Dec 2023)
; Modified ......: xbebenk (Feb 2024)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2024
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func LocateBlacksmith()
	; reset position
	$g_aiBlacksmithPos[0] = -1
	$g_aiBlacksmithPos[1] = -1

	If $g_iTownHallLevel < 8 Then
		SetLog("Townhall Lvl " & $g_iTownHallLevel & " has no Blacksmith, so skip locating.", $COLOR_DEBUG)
		Return
	EndIf

	; auto locate
	Local $bLocated = ImgLocateBlacksmith()

	If $bLocated Then 
		SetLog("Blacksmith: (Level " & $g_iBlacksmithLevel & ") ["  & $g_aiBlacksmithPos[0] & "," & $g_aiBlacksmithPos[1] & "]", $COLOR_SUCCESS)
		Return
	Else
		_LocateBlacksmith() ; manual locate
	EndIf
	
EndFunc   ;==>LocateBlacksmith

; Image Search for Blacksmith
Func ImgLocateBlacksmith($bLeaveButton = False)
	
	If Not $g_bRunState Then Return
	Local $bRet = False
	SetLog("Auto Locating Blacksmith", $COLOR_ACTION)
	
	Collect(True)
	If _Sleep(1000) Then Return
	
	Local $aBuilding
	Local $aRet = QuickMIS("CNX", $g_sImgBlackSmith, $g_OuterDiamondLeft, $g_OuterDiamondTop, $g_OuterDiamondRight, $g_OuterDiamondBottom)
	If IsArray($aRet) And UBound($aRet) > 0 Then
		For $i = 0 To UBound($aRet) - 1
			SetLog("[" & $i & "] Blacksmith Search found : " & $aRet[$i][0], $COLOR_SUCCESS)
			Click($aRet[$i][1], $aRet[$i][2] + 5)
			If _Sleep(1000) Then Return
			
			$aBuilding = BuildingInfo()
			If StringInStr($aBuilding[1], "smith") Then 
				$g_aiBlacksmithPos[0] = $aRet[$i][1]
				$g_aiBlacksmithPos[1] = $aRet[$i][2]
				$g_iBlacksmithLevel = $aBuilding[2]
				If Not $bLeaveButton Then ClickAway()
				$bRet = True
				ExitLoop
			EndIf
			
			If _CheckPixel($aIsMainGrayed, $g_bCapturePixel, Default, "ImgLocateBlacksmith") Then
				For $j = 1 To 10
					If checkChatTabPixel() Then 
						Click($aRet[$i][1], $aRet[$i][2] + 5)
						If _Sleep(1000) Then Return
						$aBuilding = BuildingInfo()
						If StringInStr($aBuilding[1], "smith") Then ExitLoop
					EndIf
					If _CheckPixel($aIsMainGrayed, $g_bCapturePixel, Default, "ImgLocateBlacksmith") Then 
						SetLog("LocateBlacksmith found unlocked equipment info #" & $j, $COLOR_ACTION)
						ClickAway()
						If _Sleep(2000) Then Return
					EndIf
				Next
			EndIf
			
		Next
	Else
		SetLog("Couldn't find Blacksmith on main village", $COLOR_ERROR)
		If $g_bDebugImageSave Then SaveDebugImage("Blacksmith", False)
		$bRet = False
	EndIf
	
	Return $bRet
EndFunc   ;==>ImgLocateBlacksmith

Func _LocateBlacksmith()
	Local $stext, $MsgBox, $sErrorText = "" ; $iStupid & $iSilly removed

	SetLog("Locating Blacksmith", $COLOR_INFO)

	WinGetAndroidHandle()
	checkMainScreen()
	Collect(True)

	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, Default, Default, 12, Default, 600)
		$stext = $sErrorText & @CRLF & "Click OK then click on your Blacksmith building" & @CRLF & @CRLF & _
				"Please make sure your village is completely visible." & @CRLF & @CRLF & 
				"Do not click on anything else while locating!" & @CRLF
		$MsgBox = _ExtMsgBox(0, "Ok|Cancel", "Locate Blacksmith", $stext, 15)
		
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway()
			Local $aPos = FindPos()
			$g_aiBlacksmithPos[0] = Int($aPos[0])
			$g_aiBlacksmithPos[1] = Int($aPos[1])
			If isInsideDiamond($g_aiBlacksmithPos) = False Then
				$sErrorText = "Blacksmith Location Not Valid! Please try again." & @CRLF
				SetLog("Location not valid, try again", $COLOR_ERROR)
				ContinueLoop ; Langsung ulang loop tanpa pesan aneh
			EndIf
		Else
			SetLog("Locate Blacksmith Cancelled", $COLOR_INFO)
			ClickAway()
			Return
		EndIf
		Local $sBlacksmithInfo = BuildingInfo()
		If $sBlacksmithInfo[0] > 1 Or $sBlacksmithInfo[0] = "" Then
			If StringInStr($sBlacksmithInfo[1], "smith") = 0 Then
				$sErrorText = "That is not the Blacksmith, it was " & $sBlacksmithInfo[1] & ". Please try again!" & @CRLF
				SetLog("Selected wrong building (" & $sBlacksmithInfo[1] & "), try again", $COLOR_ERROR)
				ContinueLoop
			EndIf
		Else
			SetLog(" Operator Error - Bad Blacksmith Location: " & "(" & $g_aiBlacksmithPos[0] & "," & $g_aiBlacksmithPos[1] & ")", $COLOR_ERROR)
			$g_aiBlacksmithPos[0] = -1
			$g_aiBlacksmithPos[1] = -1
			ClickAway()
			Return False
		EndIf
		SetLog("autoLocateBlackSmith, Success", $COLOR_SUCCESS)
		ExitLoop
	WEnd
	ClickAway()
EndFunc   ;==>_LocateBlacksmith

