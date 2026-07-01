; #FUNCTION# ====================================================================================================================
; Name ..........: LocateHeroHall
; Description ...: Locates Hero Hall manually
; Syntax ........: LocateHeroHall()
; Parameters ....:
; Return values .: None
; Author ........: xbebenk
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2024
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func LocateHeroHall($bCollect = True)
	; reset position
	$g_aiHeroHallPos[0] = -1
	$g_aiHeroHallPos[1] = -1

	; auto locate (when images exist)
	Local $bLocated = AutoLocateHeroHall()

	SetLog("Hero Hall: (" & $g_aiHeroHallPos[0] & "," & $g_aiHeroHallPos[1] & ")", $COLOR_DEBUG)
	If Not $bLocated Then 
		$g_aiHeroHallPos[0] = -1 
		$g_aiHeroHallPos[1] = -1 
		$bLocated = _LocateHeroHall() ; manual locate
	EndIf
	
EndFunc

Func _LocateHeroHall()
	Local $stext, $MsgBox, $sErrorText = "" ; $iStupid & $iSilly removed

	SetLog("Locating Hero Hall", $COLOR_INFO)

	WinGetAndroidHandle()
	checkMainScreen()

	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, Default, Default, 12, Default, 600)
		$stext = $sErrorText & @CRLF & "Click OK then click on your Hero Hall" & @CRLF & @CRLF & _
				"Please make sure your village is completely visible." & @CRLF & @CRLF & _
				"Do not click on anything else while locating!" & @CRLF

		$MsgBox = _ExtMsgBox(0, "Ok|Cancel", "Locate Hero Hall", $stext, 15)

		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway()
			Local $aPos = FindPos()
			$g_aiHeroHallPos[0] = Int($aPos[0])
			$g_aiHeroHallPos[1] = Int($aPos[1])

			; --- Cek apakah klik berada di luar area ---
			If isInsideDiamond($g_aiHeroHallPos) = False Then
				$sErrorText = "Hero Hall Location Not Valid! Please try again." & @CRLF
				SetLog("Location not valid, try again", $COLOR_ERROR)
				ContinueLoop ; Langsung ulang loop tanpa pesan aneh
			EndIf
		Else
			SetLog("Locate Hero Hall Cancelled", $COLOR_INFO)
			ClickAway()
			Return
		EndIf

		Local $sHeroHallInfo = BuildingInfo() ; 860x780
		If $sHeroHallInfo[0] > 1 Or $sHeroHallInfo[0] = "" Then

			; --- Cek apakah bangunan yang diklik salah ---
			If StringInStr($sHeroHallInfo[1], "Hero") = 0 Then
				Local $sLocMsg = ($sHeroHallInfo[0] = "" ? "Nothing" : $sHeroHallInfo[1])

				; Set pesan error standar dan minta user coba lagi
				$sErrorText = "That is not the Hero Hall, it was a " & $sLocMsg & ". Please try again!" & @CRLF
				SetLog("Selected wrong building (" & $sLocMsg & "), try again", $COLOR_ERROR)
				ContinueLoop
			EndIf
		Else
			SetLog(" Operator Error - Bad Hero Hall Location: " & "(" & $g_aiHeroHallPos[0] & "," & $g_aiHeroHallPos[1] & ")", $COLOR_ERROR)
			$g_aiHeroHallPos[0] = -1
			$g_aiHeroHallPos[1] = -1
			ClickAway()
			Return False
		EndIf

		SetLog("Locate Hero Hall Success: " & "(" & $g_aiHeroHallPos[0] & "," & $g_aiHeroHallPos[1] & ")", $COLOR_SUCCESS)
		ExitLoop
	WEnd
	ClickAway()
EndFunc   ;==>LocateHeroHall

Func AutoLocateHeroHall()
	
EndFunc