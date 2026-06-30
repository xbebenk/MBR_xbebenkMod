
Func LocateTownHall()

	Local $sMsgBoxText, $MsgBox
	Local $iAttempts = 0, $iMaxAttempts = 3, $sErrorText = ""

	WinGetAndroidHandle()
	ZoomOut(True)
	
	While $iAttempts < $iMaxAttempts
		$sMsgBoxText = $sErrorText & "Click OK, then click exactly on your Town Hall."
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), "Locate Town Hall", $sMsgBoxText, 30)
		
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway()
			
			Local $aPos = FindPos()
			$g_aiTownHallPos[0] = $aPos[0]
			$g_aiTownHallPos[1] = $aPos[1]
			
			If _Sleep(1000) Then Return
			
			If Not isInsideDiamond($g_aiTownHallPos) Then
				$iAttempts += 1
				$sErrorText = "Invalid location. Please click inside the village layout area." & @CRLF & @CRLF
				SetLog("Invalid location selected. Attempt " & $iAttempts & " of " & $iMaxAttempts, $COLOR_ERROR)
				ContinueLoop
			EndIf
			SetLog("Town Hall coordinates: " & "(" & $g_aiTownHallPos[0] & "," & $g_aiTownHallPos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate Town Hall cancelled by user.", $COLOR_INFO)
			Return False
		EndIf
		
		; Validasi 2: Memastikan bangunan yang di-klik benar-benar Town Hall
		SetLog("Verify TH Level", $COLOR_ACTION)
		Local $aInfo = BuildingInfo()
		If $aInfo[1] = "Town Hall" Then
			SetLog("Town Hall level successfully identified!", $COLOR_SUCCESS)
		Else
			$iAttempts += 1
			$sErrorText = "Detected: " & $aInfo[1] & "." & @CRLF & "Please ensure you click exactly on the Town Hall." & @CRLF & @CRLF
			SetLog("Building not recognized as Town Hall (" & $aInfo[1] & "). Attempt " & $iAttempts & " of " & $iMaxAttempts, $COLOR_ERROR)
			ContinueLoop
		EndIf
		
		; success locating town hall
		ClickAway()
		Return True
	WEnd

	; Jika pengguna gagal menemukan Town Hall setelah batas maksimal percobaan
	SetLog("Failed to locate Town Hall after " & $iMaxAttempts & " attempts. Process aborted.", $COLOR_ERROR)
	$g_aiTownHallPos[0] = -1
	$g_aiTownHallPos[1] = -1
	ClickAway()
	Return False
EndFunc   ;==>LocateTownHall
