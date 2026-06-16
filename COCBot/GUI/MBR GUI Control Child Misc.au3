; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control Misc
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: MyBot.run team
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func cmbProfile()
	If LoadProfile() Then
		Return True
	EndIf
	; restore combo to current profile
	_GUICtrlComboBox_SelectString($g_hCmbProfile, $g_sProfileCurrentName)
	Return False
EndFunc   ;==>cmbProfile

Func LoadProfile($bSaveCurrentProfile = True)
	If $bSaveCurrentProfile Then
		saveConfig()
	EndIf

	; Setup the profile in case it doesn't exist.
	If setupProfile() Then
		readConfig()
		applyConfig()
		saveConfig()
		SetLog("Profile " & $g_sProfileCurrentName & " loaded from " & $g_sProfileConfigPath, $COLOR_SUCCESS)
		Return True
	EndIf
	Return False
EndFunc   ;==>LoadProfile

Func btnAddConfirm()
	Switch @GUI_CtrlId
		Case $g_hBtnAddProfile
			GUICtrlSetState($g_hCmbProfile, $GUI_HIDE)
			GUICtrlSetState($g_hTxtVillageName, $GUI_SHOW)
			GUICtrlSetState($g_hBtnAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnConfirmAddProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnDeleteProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnCancelProfileChange, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnPullSharedPrefs, $GUI_HIDE)
			GUICtrlSetState($g_hBtnPushSharedPrefs, $GUI_HIDE)
			GUICtrlSetState($g_hBtnSaveprofile, $GUI_HIDE)
		Case $g_hBtnConfirmAddProfile
			Local $newProfileName = StringRegExpReplace(GUICtrlRead($g_hTxtVillageName), '[/:*?"<>|]', '_')
			If FileExists($g_sProfilePath & "\" & $newProfileName) Then
				MsgBox($MB_ICONWARNING, GetTranslatedFileIni("MBR Popups", "Profile_Already_Exists_01", "Profile Already Exists"), GetTranslatedFileIni("MBR Popups", "Profile_Already_Exists_02", "%s already exists.\r\nPlease choose another name for your profile.", $newProfileName))
				Return
			EndIf

			saveConfig() ; save current config so we don't miss anything recently changed
			readConfig() ; read it back in to reset all of the .ini file global variables

			$g_sProfileCurrentName = $newProfileName
			; Setup the profile if it doesn't exist.
			createProfile()
			setupProfileComboBox()
			selectProfile()
			GUICtrlSetState($g_hTxtVillageName, $GUI_HIDE)
			GUICtrlSetState($g_hCmbProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnAddProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnDeleteProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnCancelProfileChange, $GUI_HIDE)
			GUICtrlSetState($g_hBtnConfirmRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnRenameProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPullSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPushSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnSaveprofile, $GUI_SHOW)

			If GUICtrlGetState($g_hBtnDeleteProfile) <> $GUI_ENABLE Then GUICtrlSetState($g_hBtnDeleteProfile, $GUI_ENABLE)
			If GUICtrlGetState($g_hBtnRenameProfile) <> $GUI_ENABLE Then GUICtrlSetState($g_hBtnRenameProfile, $GUI_ENABLE)
		Case Else
			SetLog("If you are seeing this log message there is something wrong.", $COLOR_ERROR)
	EndSwitch
EndFunc   ;==>btnAddConfirm

Func btnDeleteCancel()
	Switch @GUI_CtrlId
		Case $g_hBtnDeleteProfile
			Local $msgboxAnswer = MsgBox($MB_ICONWARNING + $MB_OKCANCEL, GetTranslatedFileIni("MBR Popups", "Delete_Profile_01", "Delete Profile"), GetTranslatedFileIni("MBR Popups", "Delete_Profile_02", "Are you sure you really want to delete the profile?\r\nThis action can not be undone."))
			If $msgboxAnswer = $IDOK Then
				; Confirmed profile deletion so delete it.
				If deleteProfile() Then
					; reset inputtext
					GUICtrlSetData($g_hTxtVillageName, GetTranslatedFileIni("MBR Popups", "MyVillage", "MyVillage"))
					If _GUICtrlComboBox_GetCount($g_hCmbProfile) > 1 Then
						; select existing profile
						setupProfileComboBox()
						selectProfile()
					Else
						; create new default profile
						createProfile(True)
					EndIf
				EndIf
			EndIf
		Case $g_hBtnCancelProfileChange
			GUICtrlSetState($g_hTxtVillageName, $GUI_HIDE)
			GUICtrlSetState($g_hCmbProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnAddProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnCancelProfileChange, $GUI_HIDE)
			GUICtrlSetState($g_hBtnDeleteProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnRenameProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPullSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPushSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnSaveprofile, $GUI_SHOW)
		Case Else
			SetLog("If you are seeing this log message there is something wrong.", $COLOR_ERROR)
	EndSwitch

	If GUICtrlRead($g_hCmbProfile) = "<No Profiles>" Then
		GUICtrlSetState($g_hBtnDeleteProfile, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnRenameProfile, $GUI_DISABLE)
	EndIf
EndFunc   ;==>btnDeleteCancel

Func btnRenameConfirm()
	Switch @GUI_CtrlId
		Case $g_hBtnRenameProfile
			Local $sProfile = GUICtrlRead($g_hCmbProfile)
			If aquireProfileMutex($sProfile, False, True) = 0 Then
				Return
			EndIf
			GUICtrlSetData($g_hTxtVillageName, $sProfile)
			GUICtrlSetState($g_hCmbProfile, $GUI_HIDE)
			GUICtrlSetState($g_hTxtVillageName, $GUI_SHOW)
			GUICtrlSetState($g_hBtnAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnConfirmAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnDeleteProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnCancelProfileChange, $GUI_SHOW)
			GUICtrlSetState($g_hBtnRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnConfirmRenameProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPullSharedPrefs, $GUI_HIDE)
			GUICtrlSetState($g_hBtnPushSharedPrefs, $GUI_HIDE)
			GUICtrlSetState($g_hBtnSaveprofile, $GUI_HIDE)
		Case $g_hBtnConfirmRenameProfile
			Local $newProfileName = StringRegExpReplace(GUICtrlRead($g_hTxtVillageName), '[/:*?"<>|]', '_')
			If FileExists($g_sProfilePath & "\" & $newProfileName) Then
				MsgBox($MB_ICONWARNING, GetTranslatedFileIni("MBR Popups", "Profile_Already_Exists_01", "Profile Already Exists"), $newProfileName & " " & GetTranslatedFileIni("MBR Popups", "Profile_Already_Exists_03", "already exists.") & @CRLF & GetTranslatedFileIni("MBR Popups", "Profile_Already_Exists_04", "Please choose another name for your profile"))
				Return
			EndIf

			$g_sProfileCurrentName = $newProfileName
			; Rename the profile.
			renameProfile()
			setupProfileComboBox()
			selectProfile()

			GUICtrlSetState($g_hTxtVillageName, $GUI_HIDE)
			GUICtrlSetState($g_hCmbProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnAddProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnCancelProfileChange, $GUI_HIDE)
			GUICtrlSetState($g_hBtnDeleteProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnRenameProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPullSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPushSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnSaveprofile, $GUI_SHOW)
		Case Else
			SetLog("If you are seeing this log message there is something wrong.", $COLOR_ERROR)
	EndSwitch
EndFunc   ;==>btnRenameConfirm

Func btnPullSharedPrefs()
	PullSharedPrefs()
EndFunc   ;==>btnPullSharedPrefs

Func btnPushSharedPrefs()
	PushSharedPrefs()
EndFunc   ;==>btnPushSharedPrefs

Func BtnSaveprofile()
	Setlog("Saving your setting...", $COLOR_INFO)
	SaveConfig()
	readConfig()
	applyConfig()
	Setlog("Done!", $COLOR_SUCCESS)
EndFunc   ;==>BtnSaveprofile

Func cmbBotCond()
	Local $iCond = _GUICtrlComboBox_GetCurSel($g_hCmbBotCond)
	If $iCond = 15 Then
		If _GUICtrlComboBox_GetCurSel($g_hCmbHoursStop) = 0 Then _GUICtrlComboBox_SetCurSel($g_hCmbHoursStop, 1)
		GUICtrlSetState($g_hCmbHoursStop, $GUI_ENABLE)
	Else
		_GUICtrlComboBox_SetCurSel($g_hCmbHoursStop, 0)
		GUICtrlSetState($g_hCmbHoursStop, $GUI_DISABLE)
	EndIf
	If $iCond = 22 Then
		GUICtrlSetState($g_hCmbHoursStop, $GUI_HIDE)
		For $i = $g_ahTxtResumeAttackLoot[$eLootTrophy] To $g_ahTxtResumeAttackLoot[$eLootDarkElixir]
			GUICtrlSetState($i, $GUI_HIDE)
		Next
		_GUI_Value_STATE("SHOW", $g_hCmbTimeStop & "#" & $g_hCmbResumeTime)
		_GUI_Value_STATE("ENABLE", $g_hCmbTimeStop & "#" & $g_hCmbResumeTime)
	Else
		_GUI_Value_STATE("HIDE", $g_hCmbTimeStop & "#" & $g_hCmbResumeTime)
		GUICtrlSetState($g_hCmbHoursStop, $GUI_SHOW)
		For $i = $g_ahTxtResumeAttackLoot[$eLootTrophy] To $g_ahTxtResumeAttackLoot[$eLootDarkElixir]
			GUICtrlSetState($i, $GUI_SHOW)
		Next
	EndIf

	For $i = $g_LblResumeAttack To $g_ahTxtResumeAttackLoot[$eLootDarkElixir]
		GUICtrlSetState($i, $GUI_DISABLE)
	Next
	If _GUICtrlComboBox_GetCurSel($g_hCmbBotCommand) <> 0 Then Return
	If $iCond <= 14 Or $iCond = 22 Then GUICtrlSetState($g_LblResumeAttack, $GUI_ENABLE)
	If $iCond <= 14 Then GUICtrlSetState($g_hChkCollectStarBonus, $GUI_ENABLE)
	If $iCond <= 6 Or $iCond = 8 Or $iCond = 10 Or $iCond = 14 Then GUICtrlSetState($g_ahTxtResumeAttackLoot[$eLootGold], $GUI_ENABLE)
	If $iCond <= 5 Or $iCond = 7 Or $iCond = 9 Or $iCond = 11 Or $iCond = 14 Then GUICtrlSetState($g_ahTxtResumeAttackLoot[$eLootElixir], $GUI_ENABLE)
	If $iCond = 13 Or $iCond = 14 Then GUICtrlSetState($g_ahTxtResumeAttackLoot[$eLootDarkElixir], $GUI_ENABLE)
	If $iCond <= 3 Or ($iCond >= 6 And $iCond <= 9) Or $iCond = 12 Then GUICtrlSetState($g_ahTxtResumeAttackLoot[$eLootTrophy], $GUI_ENABLE)
	If $iCond = 22 Then GUICtrlSetState($g_hCmbResumeTime, $GUI_ENABLE)
EndFunc   ;==>cmbBotCond

Func chkBotStop()
	If GUICtrlRead($g_hChkBotStop) = $GUI_CHECKED Then
		For $i = $g_hCmbBotCommand To $g_hCmbBotCond
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
		cmbBotCond()
	Else
		For $i = $g_hCmbBotCommand To $g_ahTxtResumeAttackLoot[$eLootDarkElixir]
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
	EndIf
EndFunc   ;==>chkBotStop

Func btnLocateClanCastle()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ZoomOut()
	If AutoLocateCC() Then 
		$g_bRunState = $wasRunState
		ClickAway()
		Return
	Else
		LocateClanCastle()
		$g_bRunState = $wasRunState
	EndIf
	
	AndroidShield("btnLocateClanCastle") ; Update shield status due to manual $g_bRunState
EndFunc   ;==>btnLocateClanCastle

;~ Func btnLocateSpellfactory()
;~ 	Local $wasRunState = $g_bRunState
;~ 	$g_bRunState = True
;~ 	ZoomOut()
;~ 	LocateSpellFactory()
;~ 	$g_bRunState = $wasRunState
;~ 	AndroidShield("btnLocateSpellfactory") ; Update shield status due to manual $g_bRunState
;~ EndFunc   ;==>btnLocateSpellfactory

;~ Func btnLocateDarkSpellfactory()
;~ 	Local $wasRunState = $g_bRunState
;~ 	$g_bRunState = True
;~ 	ZoomOut()
;~ 	LocateDarkSpellFactory()
;~ 	$g_bRunState = $wasRunState
;~ 	AndroidShield("btnLocateDarkSpellfactory") ; Update shield status due to manual $g_bRunState
;~ EndFunc   ;==>btnLocateDarkSpellfactory

Func btnLocateKingAltar()
	$g_bRunState = True
	ZoomOut()
	If AutoLocateAltar("King") Then
		ClickP($g_aiKingAltarPos)
		If _Sleep(800) Then Return
		Local $BuildingInfo = BuildingInfo(242, 477)
		If StringInStr($BuildingInfo[1], "King") Then
			applyConfig()
			saveConfig()
			$g_bRunState = False
			ClickAway()
			SetLog("Successfully Locate Barbarian King Altar [" & _ArrayToString($g_aiKingAltarPos) & "]", $COLOR_SUCCESS)
			Return True
		EndIf
	EndIf
	LocateKingAltar()
EndFunc   ;==>btnLocateKingAltar


Func btnLocateQueenAltar()
	$g_bRunState = True
	ZoomOut()
	If AutoLocateAltar("Queen") Then
		ClickP($g_aiQueenAltarPos)
		If _Sleep(800) Then Return
		Local $BuildingInfo = BuildingInfo(242, 477)
		If StringInStr($BuildingInfo[1], "Queen") Then
			applyConfig()
			saveConfig()
			$g_bRunState = False
			ClickAway()
			SetLog("Successfully Locate Acher Queen Altar [" & _ArrayToString($g_aiQueenAltarPos) & "]", $COLOR_SUCCESS)
			Return True
		EndIf
	EndIf
	LocateQueenAltar()
EndFunc   ;==>btnLocateQueenAltar

Func btnLocateWardenAltar()
	$g_bRunState = True
	ZoomOut()
	If AutoLocateAltar("Warden") Then
		ClickP($g_aiWardenAltarPos)
		If _Sleep(800) Then Return
		Local $BuildingInfo = BuildingInfo(242, 477)
		If StringInStr($BuildingInfo[1], "Warden") Then
			applyConfig()
			saveConfig()
			$g_bRunState = False
			ClickAway()
			SetLog("Successfully Locate Grand Warden Altar [" & _ArrayToString($g_aiWardenAltarPos) & "]", $COLOR_SUCCESS)
			Return True
		EndIf
	EndIf
	LocateWardenAltar()
EndFunc   ;==>btnLocateWardenAltar

Func btnLocateChampionAltar()
	$g_bRunState = True
	ZoomOut()
	If AutoLocateAltar("Champ") Then
		ClickP($g_aiChampionAltarPos)
		If _Sleep(800) Then Return
		Local $BuildingInfo = BuildingInfo(242, 477)
		If StringInStr($BuildingInfo[1], "Champ") Then
			applyConfig()
			saveConfig()
			$g_bRunState = False
			ClickAway()
			SetLog("Successfully Locate Champion Altar [" & _ArrayToString($g_aiChampionAltarPos) & "]", $COLOR_SUCCESS)
			Return True
		EndIf
	EndIf
	LocateChampionAltar()
EndFunc   ;==>btnLocateChampionAltar

Func btnLocateTownHall()
	Local $wasRunState = $g_bRunState
	Local $g_iOldTownHallLevel = $g_iTownHallLevel
	$g_bRunState = True
	
	ZoomOut()
	Local $iTownHallLevel = $g_iTownHallLevel
	Local $bLocateTH = False, $bTHFound = False
	SetLog("Locating Town Hall", $COLOR_ACTION)
	Collect(True) ;only collect from mine and collector
	For $i = 1 To 2
		SetLog("Searching TH #" & $i, $COLOR_ACTION)
		If $g_aiTownHallPos[0] > -1 Then
			ClickP($g_aiTownHallPos)
			If _Sleep(800) Then Return
			Local $BuildingInfo = BuildingInfo(242, 477)
			If $BuildingInfo[1] = "Town Hall" Then
				$g_iTownHallLevel = Number($BuildingInfo[2])
				$bTHFound = True
				applyConfig()
				saveConfig()
				ExitLoop
			Else
				$bLocateTH = True
			EndIf
		EndIf

		If $g_iTownHallLevel = 0 Or $bLocateTH Then
			$bTHFound = SearchTH() ;Sets $g_iTownHallLevel
		EndIf
	Next
	
	ClickAway()
	
	SetLog("Town Hall level is " &  $g_iTownHallLevel, $COLOR_INFO)
	SetLog("Coord : " &  _ArrayToString($g_aiTownHallPos), $COLOR_INFO)
	
	If $bTHFound Then Return
	
	LocateTownHall()
	If Not $g_iOldTownHallLevel = $g_iTownHallLevel Then
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Comic Sans MS", 600)
		Local $stext = @CRLF & GetTranslatedFileIni("MBR Popups", "Locating_your_TH", "If you locating your TH because you upgraded,") & @CRLF & _
				GetTranslatedFileIni("MBR Popups", "Must_restart_bot", "then you must restart bot!!!") & @CRLF & @CRLF & _
				GetTranslatedFileIni("MBR Popups", "OK_to_restart_bot", "Click OK to restart bot,") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Cancel_to_exit", "Or Click Cancel to exit") & @CRLF
		Local $MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Close_Bot", "Close Bot Please!"), $stext, 120)
		SetDebugLog("$MsgBox= " & $MsgBox, $COLOR_DEBUG)
		If $MsgBox = 1 Then
			#cs
				Local $stext = @CRLF & GetTranslatedFileIni("MBR Popups", "Sure_Close Bot", "Are you 100% sure you want to restart bot ?") & @CRLF & @CRLF & _
				GetTranslatedFileIni("MBR Popups", "Restart_bot", "Click OK to close bot and then restart the bot (manually)") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Cancel_to_exit", -1) & @CRLF
				Local $MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", -1), GetTranslatedFileIni("MBR Popups", "Close_Bot", -1), $stext, 120)
				SetDebugLog("$MsgBox= " & $MsgBox, $COLOR_DEBUG)
				If $MsgBox = 1 Then BotClose(False)
			#ce
			RestartBot(False, $wasRunState)
		EndIf
	EndIf
	$g_bRunState = $wasRunState
	AndroidShield("btnLocateTownHall") ; Update shield status due to manual $g_bRunState
EndFunc   ;==>btnLocateTownHall



Func btnResetBuilding()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	While 1
		If _Sleep(500) Then Return ; add small delay before display message window
		If FileExists($g_sProfileBuildingPath) Then ; Check for building.ini file first
			_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Comic Sans MS", 600)
			Local $stext = @CRLF & GetTranslatedFileIni("MBR Popups", "Delete_and_Reset_Building_info", "Click OK to Delete and Reset all Building info,") & @CRLF & @CRLF & _
					GetTranslatedFileIni("MBR Popups", "Bot_will_exit", "NOTE =>> Bot will exit and need to be restarted when complete") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Cancel_to_exit", "Or Click Cancel to exit") & @CRLF
			Local $MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Delete_Building_Info", "Delete Building Infomation ?"), $stext, 120)
			SetDebugLog("$MsgBox= " & $MsgBox, $COLOR_DEBUG)
			If $MsgBox = 1 Then
				Local $stext = @CRLF & GetTranslatedFileIni("MBR Popups", "Sure_Delete_Building_Info", "Are you 100% sure you want to delete Building information ?") & @CRLF & @CRLF & _
						GetTranslatedFileIni("MBR Popups", "Delete_then_restart_bot", "Click OK to Delete and then restart the bot (manually)") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Cancel_to_exit", -1) & @CRLF
				Local $MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", -1), GetTranslatedFileIni("MBR Popups", "Delete_Building_Info", -1), $stext, 120)
				SetDebugLog("$MsgBox= " & $MsgBox, $COLOR_DEBUG)
				If $MsgBox = 1 Then
					Local $Result = FileDelete($g_sProfileBuildingPath)
					If $Result = 0 Then
						SetLog("Unable to remove building.ini file, please use manual method", $COLOR_ERROR)
					Else
						BotClose(False)
					EndIf
				EndIf
			EndIf
		Else
			SetLog("Building.ini file does not exist", $COLOR_INFO)
		EndIf
		ExitLoop
	WEnd
	$g_bRunState = $wasRunState
	AndroidShield("btnResetBuilding") ; Update shield status due to manual $g_bRunState
EndFunc   ;==>btnResetBuilding

Func btnLab()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ZoomOut()
	LocateLab()
	$g_bRunState = $wasRunState
	AndroidShield("btnLab") ; Update shield status due to manual $g_bRunState
EndFunc   ;==>btnLab

Func btnPet()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ZoomOut()
	_LocatePetHouse()
	$g_bRunState = $wasRunState
	AndroidShield("btnPet") ; Update shield status due to manual $g_bRunState
EndFunc   ;==>btnPet

Func btnBsmith()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ZoomOut()
	LocateBlacksmith()
	$g_bRunState = $wasRunState
	AndroidShield("btnBsmith") ; Update shield status due to manual $g_bRunState
EndFunc   ;==>btnBsmith

Func ChkCollect()
	If GUICtrlRead($g_hChkCollect) = $GUI_CHECKED Then
		$g_bChkCollect = True
	Else
		$g_bChkCollect = False
	EndIf
EndFunc   ;==>ChkCollect

Func ChkCollectLootCart()
	If GUICtrlRead($g_hChkCollectLootCart) = $GUI_CHECKED Then
		$g_bChkCollectLootCart = True
	Else
		$g_bChkCollectLootCart = False
	EndIf
EndFunc

Func ChkTreasuryCollect()
	If GUICtrlRead($g_hChkTreasuryCollect) = $GUI_CHECKED Then
		$g_bChkTreasuryCollect = True
	Else
		$g_bChkTreasuryCollect = False
	EndIf
EndFunc   ;==>ChkTreasuryCollect

Func ChkCollectCookie()
	If GUICtrlRead($g_hChkCollectCookie) = $GUI_CHECKED Then
		$g_bChkCollectCookie = True
	Else
		$g_bChkCollectCookie = False
	EndIf
EndFunc

Func ChkFreeMagicItems()
	If GUICtrlRead($g_hChkCollectFreeMagicItems) = $GUI_CHECKED Then
		$g_bChkCollectFreeMagicItems = True
	Else
		$g_bChkCollectFreeMagicItems = False
	EndIf
EndFunc   ;==>ChkFreeMagicItems

Func btnOpenSellPotion()
	GUISetState(@SW_SHOW, $g_hGUI_SellMagicItems)
EndFunc

Func btnCloseSellPotion()
	GUISetState(@SW_HIDE, $g_hGUI_SellMagicItems)
EndFunc

Func chkEnableSellMagicItem()
	If GUICtrlRead($g_hChkEnableSellMagicItem) = $GUI_CHECKED Then
		$g_bChkEnableSellMagicItem = True
		Local $iCtrl = 0
		For $i = $g_hChkSellBOF To $g_hChkSellROBE
			GUICtrlSetState($i, $GUI_ENABLE)
			$g_aSellMagicItem[$iCtrl] = (GUICtrlRead($i) = $GUI_CHECKED ? True : False)
			$iCtrl += 1
		Next
	Else
		$g_bChkEnableSellMagicItem = False
		Local $iCtrl = 0
		For $i = $g_hChkSellBOF To $g_hChkSellROBE
			GUICtrlSetState($i, $GUI_DISABLE)
			$g_aSellMagicItem[$iCtrl] = (GUICtrlRead($i) = $GUI_CHECKED ? True : False)
			$iCtrl += 1
		Next
	EndIf
EndFunc

Func ChkEnableTradeMedal()
	If GUICtrlRead($g_hChkEnableTradeMedal) = $GUI_CHECKED Then
		$g_bChkEnableTradeMedal = True
		Local $iCtrl = 0
		For $i = $g_hChkTradeShiny To $g_hChkTradeResearchPot
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
	Else
		$g_bChkEnableTradeMedal = False
		Local $iCtrl = 0
		For $i = $g_hChkTradeShiny To $g_hChkTradeResearchPot
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
	EndIf
EndFunc

Func chkActivateClangames()
	If GUICtrlRead($g_hChkClanGamesEnabled) = $GUI_CHECKED Then
		GUICtrlSetState($g_hBtnCGSettingsOpen, $GUI_ENABLE)
		GUICtrlSetState($g_hChkClanGames3H, $GUI_ENABLE)
		GUICtrlSetState($g_hChkClanGamesDebug, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hBtnCGSettingsOpen, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGames3H, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGamesDebug, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkActivateClangames

Func chkClanGamesBB()
	If GUICtrlRead($g_hChkClanGamesEnabled) = $GUI_CHECKED And _ 
		GUICtrlRead($g_hChkForceBBAttackOnClanGames) = $GUI_CHECKED Then
		$g_bChkForceBBAttackOnClanGames = True
	Else
		$g_bChkForceBBAttackOnClanGames = False
	EndIf
EndFunc

Func chkCollectCGReward()
	If GUICtrlRead($g_hChkCollectCGReward) = $GUI_CHECKED Then
		$g_bCollectCGReward = True
	Else
		$g_bCollectCGReward = False
	EndIf
EndFunc

Func btnCGSettings()
	GUISetState(@SW_SHOW, $g_hGUI_CGSettings)
EndFunc

Func CloseCGSettings()
	GUISetState(@SW_HIDE, $g_hGUI_CGSettings)
EndFunc

Func CGLootTVRoot()	
	If BitAND(GUICtrlRead($g_hChkCGMainLoot), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Loot
		For $i = 0 To UBound($g_ahCGMainLootItem) - 1
			GUICtrlSetState($g_ahCGMainLootItem[$i], $GUI_CHECKED)
		Next
	EndIf
	If Not BitAND(GUICtrlRead($g_hChkCGMainLoot), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Loot
		For $i = 0 To UBound($g_ahCGMainLootItem) - 1
			GUICtrlSetState($g_ahCGMainLootItem[$i], $GUI_UNCHECKED)
		Next
	EndIf
	GUICtrlSetData($g_hLabelClangamesDesc, "Enable/Disable Main Village Loot Challenges")
EndFunc

Func CGLootTVItem()	
	Local $tmpChallenges = ClanGamesChallenges("L")
	For $i = 0 To UBound($g_ahCGMainLootItem) - 1
		If GUICtrlRead($g_hClanGamesTV) = $g_ahCGMainLootItem[$i] Then
			GUICtrlSetData($g_hLabelClangamesDesc, $tmpChallenges[$i][5] & @CRLF & "Required TH Level : " & $tmpChallenges[$i][2] _
				& @CRLF & "Difficulty : " & $tmpChallenges[$i][4])
			ExitLoop
		Else
			GUICtrlSetData($g_hLabelClangamesDesc, "")
		EndIf
	Next
EndFunc

Func CGMainBattleTVRoot()	
	If BitAND(GUICtrlRead($g_hChkCGMainBattle), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Battle 
		For $i = 0 To UBound($g_ahCGMainBattleItem) - 1
			GUICtrlSetState($g_ahCGMainBattleItem[$i], $GUI_CHECKED)
		Next
	EndIf
	If Not BitAND(GUICtrlRead($g_hChkCGMainBattle), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Battle 
		For $i = 0 To UBound($g_ahCGMainBattleItem) - 1
			GUICtrlSetState($g_ahCGMainBattleItem[$i], $GUI_UNCHECKED)
		Next
	EndIf
	GUICtrlSetData($g_hLabelClangamesDesc, "Enable/Disable Main Village Battle Challenges")
EndFunc

Func CGMainBattleTVItem()	
	Local $tmpChallenges = ClanGamesChallenges("B")
	For $i = 0 To UBound($g_ahCGMainBattleItem) - 1
		If GUICtrlRead($g_hClanGamesTV) = $g_ahCGMainBattleItem[$i] Then
			GUICtrlSetData($g_hLabelClangamesDesc, $tmpChallenges[$i][5] & @CRLF & "Required TH Level : " & $tmpChallenges[$i][2] _
				& @CRLF & "Difficulty : " & $tmpChallenges[$i][4])
			ExitLoop
		Else
			GUICtrlSetData($g_hLabelClangamesDesc, "")
		EndIf
	Next
EndFunc

Func CGMainDestructionTVRoot()	
	If BitAND(GUICtrlRead($g_hChkCGMainDestruction), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage DestructionChallenges 
		For $i = 0 To UBound($g_ahCGMainDestructionItem) - 1
			GUICtrlSetState($g_ahCGMainDestructionItem[$i], $GUI_CHECKED)
		Next
	EndIf
	If Not BitAND(GUICtrlRead($g_hChkCGMainDestruction), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage DestructionChallenges 
		For $i = 0 To UBound($g_ahCGMainDestructionItem) - 1
			GUICtrlSetState($g_ahCGMainDestructionItem[$i], $GUI_UNCHECKED)
		Next
	EndIf
	GUICtrlSetData($g_hLabelClangamesDesc, "Enable/Disable Main Village Destruction Challenges")
EndFunc

Func CGMainDestructionTVItem()	
	Local $tmpChallenges = ClanGamesChallenges("D")
	For $i = 0 To UBound($g_ahCGMainDestructionItem) - 1
		If GUICtrlRead($g_hClanGamesTV) = $g_ahCGMainDestructionItem[$i] Then
			GUICtrlSetData($g_hLabelClangamesDesc, $tmpChallenges[$i][5] & @CRLF & "Required TH Level : " & $tmpChallenges[$i][2] _
				& @CRLF & "Difficulty : " & $tmpChallenges[$i][4])
			ExitLoop
		Else
			GUICtrlSetData($g_hLabelClangamesDesc, "")
		EndIf
	Next
EndFunc

Func CGMainAirTVRoot()	
	If BitAND(GUICtrlRead($g_hChkCGMainAir), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Air Troops Challenges 
		For $i = 0 To UBound($g_ahCGMainAirItem) - 1
			GUICtrlSetState($g_ahCGMainAirItem[$i], $GUI_CHECKED)
		Next
	EndIf
	If Not BitAND(GUICtrlRead($g_hChkCGMainAir), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Air Troops Challenges 
		For $i = 0 To UBound($g_ahCGMainAirItem) - 1
			GUICtrlSetState($g_ahCGMainAirItem[$i], $GUI_UNCHECKED)
		Next
	EndIf
	GUICtrlSetData($g_hLabelClangamesDesc, "Enable/Disable Main Village Air Troops Challenges")
EndFunc

Func CGMainAirTVItem()	
	Local $tmpChallenges = ClanGamesChallenges("A")
	For $i = 0 To UBound($g_ahCGMainAirItem) - 1
		If GUICtrlRead($g_hClanGamesTV) = $g_ahCGMainAirItem[$i] Then
			GUICtrlSetData($g_hLabelClangamesDesc, $tmpChallenges[$i][5] & @CRLF & "Required TH Level : " & $tmpChallenges[$i][2] _
				& @CRLF & "Difficulty : " & $tmpChallenges[$i][4])
			ExitLoop
		Else
			GUICtrlSetData($g_hLabelClangamesDesc, "")
		EndIf
	Next
EndFunc

Func CGMainGroundTVRoot()	
	If BitAND(GUICtrlRead($g_hChkCGMainGround), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Ground Troops Challenges 
		For $i = 0 To UBound($g_ahCGMainGroundItem) - 1
			GUICtrlSetState($g_ahCGMainGroundItem[$i], $GUI_CHECKED)
		Next
	EndIf
	If Not BitAND(GUICtrlRead($g_hChkCGMainGround), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Ground Troops Challenges 
		For $i = 0 To UBound($g_ahCGMainGroundItem) - 1
			GUICtrlSetState($g_ahCGMainGroundItem[$i], $GUI_UNCHECKED)
		Next
	EndIf
	GUICtrlSetData($g_hLabelClangamesDesc, "Enable/Disable Main Village Ground Troops Challenges")
EndFunc

Func CGMainGroundTVItem()	
	Local $tmpChallenges = ClanGamesChallenges("G")
	For $i = 0 To UBound($g_ahCGMainGroundItem) - 1
		If GUICtrlRead($g_hClanGamesTV) = $g_ahCGMainGroundItem[$i] Then
			GUICtrlSetData($g_hLabelClangamesDesc, $tmpChallenges[$i][5] & @CRLF & "Required TH Level : " & $tmpChallenges[$i][2] _
				& @CRLF & "Difficulty : " & $tmpChallenges[$i][4])
			ExitLoop
		Else
			GUICtrlSetData($g_hLabelClangamesDesc, "")
		EndIf
	Next
EndFunc

Func CGMainMiscTVRoot()	
	If BitAND(GUICtrlRead($g_hChkCGMainMisc), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Miscellaneous Challenges 
		For $i = 0 To UBound($g_ahCGMainMiscItem) - 1
			GUICtrlSetState($g_ahCGMainMiscItem[$i], $GUI_CHECKED)
		Next
	EndIf
	If Not BitAND(GUICtrlRead($g_hChkCGMainMisc), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Miscellaneous Challenges 
		For $i = 0 To UBound($g_ahCGMainMiscItem) - 1
			GUICtrlSetState($g_ahCGMainMiscItem[$i], $GUI_UNCHECKED)
		Next
	EndIf
	GUICtrlSetData($g_hLabelClangamesDesc, "Enable/Disable Main Village Miscellaneous Challenges")
EndFunc

Func CGMainMiscTVItem()	
	Local $tmpChallenges = ClanGamesChallenges("M")
	For $i = 0 To UBound($g_ahCGMainMiscItem) - 1
		If GUICtrlRead($g_hClanGamesTV) = $g_ahCGMainMiscItem[$i] Then
			GUICtrlSetData($g_hLabelClangamesDesc, $tmpChallenges[$i][5] & @CRLF & "Required TH Level : " & $tmpChallenges[$i][2] _
				& @CRLF & "Difficulty : " & $tmpChallenges[$i][4])
			ExitLoop
		Else
			GUICtrlSetData($g_hLabelClangamesDesc, "")
		EndIf
	Next
EndFunc

Func CGMainSpellTVRoot()	
	If BitAND(GUICtrlRead($g_hChkCGMainSpell), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Spell Challenges 
		For $i = 0 To UBound($g_ahCGMainSpellItem) - 1
			GUICtrlSetState($g_ahCGMainSpellItem[$i], $GUI_CHECKED)
		Next
	EndIf
	If Not BitAND(GUICtrlRead($g_hChkCGMainSpell), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames MainVillage Spell Challenges 
		For $i = 0 To UBound($g_ahCGMainSpellItem) - 1
			GUICtrlSetState($g_ahCGMainSpellItem[$i], $GUI_UNCHECKED)
		Next
	EndIf
	GUICtrlSetData($g_hLabelClangamesDesc, "Enable/Disable Main Village Spell Challenges")
EndFunc

Func CGMainSpellTVItem()	
	Local $tmpChallenges = ClanGamesChallenges("S")
	For $i = 0 To UBound($g_ahCGMainSpellItem) - 1
		If GUICtrlRead($g_hClanGamesTV) = $g_ahCGMainSpellItem[$i] Then
			GUICtrlSetData($g_hLabelClangamesDesc, $tmpChallenges[$i][5] & @CRLF & "Required TH Level : " & $tmpChallenges[$i][2] _
				& @CRLF & "Difficulty : " & $tmpChallenges[$i][4])
			ExitLoop
		Else
			GUICtrlSetData($g_hLabelClangamesDesc, "")
		EndIf
	Next
EndFunc

Func CGBBBattleTVRoot()	
	If BitAND(GUICtrlRead($g_hChkCGBBBattle), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames Builder Base Battle Challenges 
		For $i = 0 To UBound($g_ahCGBBBattleItem) - 1
			GUICtrlSetState($g_ahCGBBBattleItem[$i], $GUI_CHECKED)
		Next
	EndIf
	If Not BitAND(GUICtrlRead($g_hChkCGBBBattle), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames Builder Base Battle Challenges 
		For $i = 0 To UBound($g_ahCGBBBattleItem) - 1
			GUICtrlSetState($g_ahCGBBBattleItem[$i], $GUI_UNCHECKED)
		Next
	EndIf
	GUICtrlSetData($g_hLabelClangamesDesc, "Enable/Disable Builder Base Battle Challenges")
EndFunc

Func CGBBBattleTVItem()	
	Local $tmpChallenges = ClanGamesChallenges("BBB")
	For $i = 0 To UBound($g_ahCGBBBattleItem) - 1
		If GUICtrlRead($g_hClanGamesTV) = $g_ahCGBBBattleItem[$i] Then
			GUICtrlSetData($g_hLabelClangamesDesc, $tmpChallenges[$i][5] & @CRLF & "Required TH Level : " & $tmpChallenges[$i][2] _
				& @CRLF & "Difficulty : " & $tmpChallenges[$i][4])
			ExitLoop
		Else
			GUICtrlSetData($g_hLabelClangamesDesc, "")
		EndIf
	Next
EndFunc

Func CGBBDestructionTVRoot()	
	If BitAND(GUICtrlRead($g_hChkCGBBDestruction), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames Builder Base Destruction Challenges 
		For $i = 0 To UBound($g_ahCGBBDestructionItem) - 1
			GUICtrlSetState($g_ahCGBBDestructionItem[$i], $GUI_CHECKED)
		Next
	EndIf
	If Not BitAND(GUICtrlRead($g_hChkCGBBDestruction), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames Builder Base Destruction Challenges 
		For $i = 0 To UBound($g_ahCGBBDestructionItem) - 1
			GUICtrlSetState($g_ahCGBBDestructionItem[$i], $GUI_UNCHECKED)
		Next
	EndIf
	GUICtrlSetData($g_hLabelClangamesDesc, "Enable/Disable Builder Base Destruction Challenges")
EndFunc

Func CGBBDestructionTVItem()	
	Local $tmpChallenges = ClanGamesChallenges("BBD")
	For $i = 0 To UBound($g_ahCGBBDestructionItem) - 1
		If GUICtrlRead($g_hClanGamesTV) = $g_ahCGBBDestructionItem[$i] Then
			GUICtrlSetData($g_hLabelClangamesDesc, $tmpChallenges[$i][5] & @CRLF & "Required TH Level : " & $tmpChallenges[$i][2] _
				& @CRLF & "Difficulty : " & $tmpChallenges[$i][4])
			ExitLoop
		Else
			GUICtrlSetData($g_hLabelClangamesDesc, "")
		EndIf
	Next
EndFunc

Func CGBBTroopsTVRoot()	
	If BitAND(GUICtrlRead($g_hChkCGBBTroops), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames Builder Base Troops Challenges 
		For $i = 0 To UBound($g_ahCGBBTroopsItem) - 1
			GUICtrlSetState($g_ahCGBBTroopsItem[$i], $GUI_CHECKED)
		Next
	EndIf
	If Not BitAND(GUICtrlRead($g_hChkCGBBTroops), $GUI_CHECKED) And GUICtrlRead($g_hChkCGRootEnabledAll) = $GUI_CHECKED Then ;root Clangames Builder Base Troops Challenges 
		For $i = 0 To UBound($g_ahCGBBTroopsItem) - 1
			GUICtrlSetState($g_ahCGBBTroopsItem[$i], $GUI_UNCHECKED)
		Next
	EndIf
	GUICtrlSetData($g_hLabelClangamesDesc, "Enable/Disable Builder Base Troops Challenges")
EndFunc

Func CGBBTroopsTVItem()	
	Local $tmpChallenges = ClanGamesChallenges("BBT")
	For $i = 0 To UBound($g_ahCGBBTroopsItem) - 1
		If GUICtrlRead($g_hClanGamesTV) = $g_ahCGBBTroopsItem[$i] Then
			GUICtrlSetData($g_hLabelClangamesDesc, $tmpChallenges[$i][5] & @CRLF & "Required TH Level : " & $tmpChallenges[$i][2] _
				& @CRLF & "Difficulty : " & $tmpChallenges[$i][4])
			ExitLoop
		Else
			GUICtrlSetData($g_hLabelClangamesDesc, "")
		EndIf
	Next
EndFunc

Func chkSortClanGames()
	If GUICtrlRead($g_hChkClanGamesSort) = $GUI_CHECKED Then
		$g_bSortClanGames = True
	Else
		$g_bSortClanGames = False
	EndIf
EndFunc

Func chkForcedOnlyBBEvent()
	If GUICtrlRead($g_hChkCGBBAttackOnly) = $GUI_CHECKED Then
		$g_bChkCGBBAttackOnly = True
	Else
		$g_bChkCGBBAttackOnly = False
	EndIf
EndFunc

Func chkOnHaltAttack()
	If GUICtrlRead($g_hChkMMSkipFirstCheckRoutine) = $GUI_CHECKED Then
		$g_bSkipFirstCheckRoutine = True
	Else
		$g_bSkipFirstCheckRoutine = False
	EndIf
	If GUICtrlRead($g_hChkMMSkipBB) = $GUI_CHECKED Then
		$g_bSkipBB = True
	Else
		$g_bSkipBB = False
	EndIf
EndFunc ;==> chkOnHaltAttack

Func chkOnDoubleTrain()
	If GUICtrlRead($g_hChkMMIgnoreIncorrectTroopCombo) = $GUI_CHECKED Then
		$g_bIgnoreIncorrectTroopCombo = True
		GUICtrlSetState($g_hLblFillIncorrectTroopCombo, $GUI_ENABLE)
		GUICtrlSetState($g_hCmbFillIncorrectTroopCombo, $GUI_ENABLE)
	Else
		$g_bIgnoreIncorrectTroopCombo = False
		GUICtrlSetState($g_hLblFillIncorrectTroopCombo, $GUI_DISABLE)
		GUICtrlSetState($g_hCmbFillIncorrectTroopCombo, $GUI_DISABLE)
	EndIf
	If GUICtrlRead($g_hChkMMIgnoreIncorrectSpellCombo) = $GUI_CHECKED Then
		$g_bIgnoreIncorrectSpellCombo = True
		GUICtrlSetState($g_hLblFillIncorrectSpellCombo, $GUI_ENABLE)
		GUICtrlSetState($g_hCmbFillIncorrectSpellCombo, $GUI_ENABLE)
	Else
		$g_bIgnoreIncorrectSpellCombo = False
		GUICtrlSetState($g_hLblFillIncorrectSpellCombo, $GUI_DISABLE)
		GUICtrlSetState($g_hCmbFillIncorrectSpellCombo, $GUI_DISABLE)
	EndIf
EndFunc ;==> chkOnDoubleTrain

Func chkSkipWallPlacingOnBB()
	If GUICtrlRead($g_hChkMMSkipWallPlacingOnBB) = $GUI_CHECKED Then
		$g_bSkipWallPlacingOnBB = True
	Else
		$g_bSkipWallPlacingOnBB = False
	EndIf
EndFunc ;==> chkSkipWallPlacingOnBB

Func chkCheckDonateEarly()
	If GUICtrlRead($g_hDonateEarly) = $GUI_CHECKED Then
		$g_bDonateEarly = True
	Else
		$g_bDonateEarly = False
	EndIf
EndFunc ;==> chkCheckDonateEarly

Func chkCheckAutoUpgradeEarly()
	If GUICtrlRead($g_hAutoUpgradeEarly) = $GUI_CHECKED Then
		$g_bAutoUpgradeEarly = True
	Else
		$g_bAutoUpgradeEarly = False
	EndIf
EndFunc ;==> chkCheckAutoUpgradeEarly

Func chkForcedSwitchIfNoCG()
	If GUICtrlRead($g_hChkForceSwitchifNoCGEvent) = $GUI_CHECKED Then
		$g_bChkForceSwitchifNoCGEvent = True
	Else
		$g_bChkForceSwitchifNoCGEvent = False
	EndIf
EndFunc ;==> chkForcedSwitchIfNoCG

Func chkSkipDropTrophyOnFirstStart()
	If GUICtrlRead($g_hChkSkipDT) = $GUI_CHECKED Then
		$g_bSkipDT = True
	Else
		$g_bSkipDT = False
	EndIf
EndFunc ;==> chkSkipDropTrophyOnFirstStart

Func ChkAttackOnce()
	If GUICtrlRead($g_hChkAttackOnce) = $GUI_CHECKED Then
		$g_bChkAttackOnce = True
	Else
		$g_bChkAttackOnce = False
	EndIf
EndFunc ;==> ChkAttackOnce


Func chkSetCCSleep()
	If GUICtrlRead($g_hChkEnableCCSleep) = $GUI_CHECKED Then
		$g_bEnableCCSleep = True
	Else
		$g_bEnableCCSleep = False
	EndIf
EndFunc ;==> chkSetCCSleep

Func chkTournament()
	If GUICtrlRead($g_hChkTournament) = $GUI_CHECKED Then
		$g_bEnableTournament = True
	Else
		$g_bEnableTournament = False
	EndIf
	If GUICtrlRead($g_hChkNoTournament) = $GUI_CHECKED Then
		$g_bNoTournament = True
	Else
		$g_bNoTournament = False
	EndIf
	$g_iTournamentAttackType = _GUICtrlComboBox_GetCurSel($g_hCmbTournamentAttackType)
	SetLog("Set Tournament Attack Type : " & ($g_iTournamentAttackType = 0 ? "Dead Base" : "Active Base"), $COLOR_DEBUG)
	
	$g_iTournamentUseArmy = _GUICtrlComboBox_GetCurSel($g_hCmbUseSavedArmy)
	SetLog("Set Tournament Use Saved Army : Army " & $g_iTournamentUseArmy + 1, $COLOR_DEBUG)
	
	If $g_iTournamentAttackType = 1 Then 
		GUICtrlSetState($g_hCmbUseSavedArmy, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hCmbUseSavedArmy, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkTournament
