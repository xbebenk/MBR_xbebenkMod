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
	Local $aRet = QuickMIS("CNX", $g_sImgBlackSmith)
	If IsArray($aRet) And UBound($aRet) > 0 Then
		For $i = 0 To UBound($aRet) - 1
			SetLog("[" & $i & "] Blacksmith Search found : " & $aRet[$i][0], $COLOR_SUCCESS)
			Click($aRet[$i][1], $aRet[$i][2])
			If _Sleep(1000) Then Return
			
			$aBuilding = BuildingInfo(242, 477)
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
						Click($aRet[$i][1], $aRet[$i][2])
						If _Sleep(1000) Then Return
						$aBuilding = BuildingInfo(242, 477)
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
	Local $stext, $MsgBox, $iStupid = 0, $iSilly = 0, $sErrorText = ""

	SetLog("Locating Blacksmith", $COLOR_INFO)

	WinGetAndroidHandle()
	checkMainScreen()
	Collect(True)

	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Comic Sans MS", 600)
		$stext = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_Blacksmith_01", "Click OK then click on your Blacksmith") & @CRLF & @CRLF & _
				GetTranslatedFileIni("MBR Popups", "Locate_building_01", -1) & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", -1) & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_Blacksmith_02", "Locate Blacksmith"), $stext, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway()
			Local $aPos = FindPos()
			$g_aiBlacksmithPos[0] = Int($aPos[0])
			$g_aiBlacksmithPos[1] = Int($aPos[1])
			If isInsideDiamond($g_aiBlacksmithPos) = False Then
				$iStupid += 1
				Select
					Case $iStupid = 1
						$sErrorText = "Blacksmith Location Not Valid!" & @CRLF
						SetLog("Location not valid, try again", $COLOR_ERROR)
						ContinueLoop
					Case $iStupid = 2
						$sErrorText = "Please try to click inside the grass field!" & @CRLF
						ContinueLoop
					Case $iStupid = 3
						$sErrorText = "This is not funny, Please stop!" & @CRLF & @CRLF
						ContinueLoop
					Case $iStupid = 4
						$sErrorText = "Last Chance, DO NOT MAKE ME ANGRY, or" & @CRLF & "I will give ALL of your gold to Barbarian King," & @CRLF & "And ALL of your Gems to the Archer Queen!" & @CRLF
						ContinueLoop
					Case $iStupid > 4
						SetLog(" Operator Error - Bad Blacksmith Location.", $COLOR_ERROR)
						ClickAway()
						Return False
				EndSelect
			EndIf
		Else
			SetLog("Locate Blacksmith Cancelled", $COLOR_INFO)
			ClickAway()
			Return
		EndIf
		Local $sBlacksmithInfo = BuildingInfo(242, 477)
		If $sBlacksmithInfo[0] > 1 Or $sBlacksmithInfo[0] = "" Then
			If StringInStr($sBlacksmithInfo[1], "smith") = 0 Then
				Local $sLocMsg = ($sBlacksmithInfo[0] = "" ? "Nothing" : $sBlacksmithInfo[1])

				$iSilly += 1
				Select
					Case $iSilly = 1
						$sErrorText = "Wait, That is not the Blacksmith?, It was a " & $sLocMsg & @CRLF
						ContinueLoop
					Case $iSilly = 2
						$sErrorText = "Quit joking, That was " & $sLocMsg & @CRLF
						ContinueLoop
					Case $iSilly = 3
						$sErrorText = "This is not funny, why did you click " & $sLocMsg & "? Please stop!" & @CRLF
						ContinueLoop
					Case $iSilly = 4
						$sErrorText = $sLocMsg & " ?!?!?!" & @CRLF & @CRLF & "Last Chance, DO NOT MAKE ME ANGRY, or" & @CRLF & "I will give ALL of your gold to Barbarian King," & @CRLF & "And ALL of your Gems to the Archer Queen!" & @CRLF
						ContinueLoop
					Case $iSilly > 4
						SetLog("Ok, you really think that's a Blacksmith?" & @CRLF & "I don't care anymore, go ahead with it!", $COLOR_ERROR)
						ClickAway()
						ExitLoop
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad Blacksmith Location: " & "(" & $g_aiBlacksmithPos[0] & "," & $g_aiBlacksmithPos[1] & ")", $COLOR_ERROR)
			$g_aiBlacksmithPos[0] = -1
			$g_aiBlacksmithPos[1] = -1
			ClickAway()
			Return False
		EndIf
		SetLog("Locate Blacksmith Success: " & "(" & $g_aiBlacksmithPos[0] & "," & $g_aiBlacksmithPos[1] & ")", $COLOR_SUCCESS)
		ExitLoop
	WEnd
	ClickAway()

EndFunc   ;==>_LocateBlacksmith

