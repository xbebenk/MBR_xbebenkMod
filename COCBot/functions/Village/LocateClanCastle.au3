
; #FUNCTION# ====================================================================================================================
; Name ..........: LocateClanCastle
; Description ...: Locates Clan Castle manually (Temporary)
; Syntax ........: LocateClanCastle()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......: KnowJack (06/2015) Sardo (08/2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func LocateClanCastle($bCollect = True)
	Local $stext, $MsgBox, $sErrorText = "", $sInfo ; $iSilly & $iStupid removed

	SetLog("Locating Clan Castle", $COLOR_INFO)

	WinGetAndroidHandle()
	checkMainScreen(False, $g_bStayOnBuilderBase, "LocateClanCastle")
	If $bCollect Then Collect(True)

	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Comic Sans MS", 500)
		$stext = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_Clan_Castle_01", "Click OK then click on your Clan Castle") & @CRLF & @CRLF & _
				GetTranslatedFileIni("MBR Popups", "Locate_building_01", "Do not move mouse quickly after clicking location") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", "Make sure the building name is visible for me!") & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_Clan_Castle_02", "Locate Clan Castle"), $stext, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway()
			Local $aPos = FindPos()
			$g_aiClanCastlePos[0] = Int($aPos[0])
			$g_aiClanCastlePos[1] = Int($aPos[1])
			If Not isInsideDiamond($g_aiClanCastlePos) Then
				$sErrorText = "Clan Castle Location Not Valid! Please try again." & @CRLF
				SetLog("Location not valid, try again", $COLOR_ERROR)
				ContinueLoop ; Langsung ulang loop tanpa pesan aneh
			EndIf
			SetLog("Clan Castle: " & "(" & $g_aiClanCastlePos[0] & "," & $g_aiClanCastlePos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate Clan Castle Cancelled", $COLOR_INFO)
			ClickAway()
			Return
		EndIf
		$sInfo = BuildingInfo() ; 860x780
		If IsArray($sInfo) and ($sInfo[0] > 1 Or $sInfo[0] = "") Then
			If StringInStr($sInfo[1], "clan") = 0 Then
				$sErrorText = "That is not the Clan Castle, it was " & $sInfo[1] & ". Please try again!" & @CRLF
				SetLog("Selected wrong building (" & $sInfo[1] & "), try again", $COLOR_ERROR)
				ContinueLoop
			EndIf
			If $sInfo[2] = "Broken" Then
				SetLog("You did not rebuild your Clan Castle yet", $COLOR_ACTION)
			Else
				SetLog("Your Clan Castle is at level: " & $sInfo[2], $COLOR_SUCCESS)
			EndIf
		Else
			SetLog(" Operator Error - Bad Clan Castle Location: " & "(" & $g_aiClanCastlePos[0] & "," & $g_aiClanCastlePos[1] & ")", $COLOR_ERROR)
			$g_aiClanCastlePos[0] = -1
			$g_aiClanCastlePos[1] = -1
			ClickAway()
			Return False
		EndIf
		ExitLoop
	WEnd

	ClickAway()
EndFunc   ;==>LocateClanCastle
