; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "Profiles" tab under the "Bot" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hCmbProfile = 0, $g_hTxtVillageName = 0, $g_hBtnAddProfile = 0, $g_hBtnConfirmAddProfile = 0, $g_hBtnConfirmRenameProfile = 0, $g_hChkOnlySCIDAccounts = 0, $g_hCmbWhatSCIDAccount2Use = 0 , _
	   $g_hBtnDeleteProfile = 0, $g_hBtnCancelProfileChange = 0, $g_hBtnRenameProfile = 0, $g_hBtnPullSharedPrefs = 0, $g_hBtnPushSharedPrefs = 0 , $g_hBtnSaveprofile = 0

Global $g_hChkSwitchAcc = 0, $g_hCmbSwitchAcc = 0, $g_hChkSharedPrefs = 0, $g_hCmbTotalAccount = 0, _
	   $g_ahChkAccount[16], $g_ahCmbProfile[16], $g_ahChkDonate[16], $g_hBtnSaveToAll = 0, _
	   $g_hRadSwitchSuperCellID = 0, $g_hRadSwitchSharedPrefs = 0

Func CreateBotProfiles()

	Local $x = 25, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Group_01", "Switch Profiles"), $x - 20, $y - 20, $g_iSizeWGrpTab2, 47)
	$x -= 5
	$y -= 3
		$g_hCmbProfile = GUICtrlCreateCombo("", $x - 3, $y, 115, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "CmbProfile_Info_01", "Use this to switch to a different profile")& @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "CmbProfile_Info_02", "Your profiles can be found in") & ": " & @CRLF & $g_sProfilePath)
			setupProfileComboBox()
			PopulatePresetComboBox()
			GUICtrlSetState(-1, $GUI_SHOW)
			GUICtrlSetOnEvent(-1, "cmbProfile")
		$g_hTxtVillageName = GUICtrlCreateInput(GetTranslatedFileIni("MBR Popups", "MyVillage", "MyVillage"), $x - 3, $y, 115, 22, $ES_AUTOHSCROLL)
			GUICtrlSetLimit (-1, 100, 0)
			GUICtrlSetFont(-1, 9, 400, 1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "TxtVillageName_Info_01", "Your village/profile's name"))
			GUICtrlSetState(-1, $GUI_HIDE)
			; GUICtrlSetOnEvent(-1, "txtVillageName") - No longer needed
	$y -= 2
		; Local static to avoid GDI Handle leak
		Static $bIconAdd = 0
		If $bIconAdd = 0 Then
			$bIconAdd = _GUIImageList_Create(24, 24, 4)
			_GUIImageList_AddBitmap($bIconAdd, @ScriptDir & "\images\Button\iconAdd.bmp")
		EndIf
		Static $bIconConfirm = 0
		If $bIconConfirm = 0 Then
			$bIconConfirm = _GUIImageList_Create(24, 24, 4)
			_GUIImageList_AddBitmap($bIconConfirm, @ScriptDir & "\images\Button\iconConfirm.bmp")
		EndIf
		Static $bIconDelete = 0
		If $bIconDelete = 0 Then
			$bIconDelete = _GUIImageList_Create(24, 24, 4)
			_GUIImageList_AddBitmap($bIconDelete, @ScriptDir & "\images\Button\iconDelete.bmp")
		EndIf
		Static $bIconCancel = 0
		If $bIconCancel = 0 Then
			$bIconCancel = _GUIImageList_Create(24, 24, 4)
			_GUIImageList_AddBitmap($bIconCancel, @ScriptDir & "\images\Button\iconCancel.bmp")
		EndIf
		Static $bIconEdit = 0
		If $bIconEdit = 0 Then
			$bIconEdit = _GUIImageList_Create(24, 24, 4)
			_GUIImageList_AddBitmap($bIconEdit, @ScriptDir & "\images\Button\iconEdit.bmp")
		EndIf
		Static $bIconPush = 0
		If $bIconPush = 0 Then
			$bIconPush = _GUIImageList_Create(24, 24, 4)
			_GUIImageList_AddBitmap($bIconPush, @ScriptDir & "\images\Button\iconPush.bmp")
		EndIf
		Static $bIconPull = 0
		If $bIconPull = 0 Then
			$bIconPull = _GUIImageList_Create(24, 24, 4)
			_GUIImageList_AddBitmap($bIconPull, @ScriptDir & "\images\Button\iconPull.bmp")
		EndIf

		Static $bIconSave = _GUIImageList_Create(24, 24, 4)
		_GUIImageList_AddBitmap($bIconSave, @ScriptDir & "\images\Button\iconConfirm.bmp")

		$x -= 15
		$g_hBtnAddProfile = GUICtrlCreateButton("", $x + 135, $y, 24, 24)
			_GUICtrlButton_SetImageList($g_hBtnAddProfile, $bIconAdd, 4)
			GUICtrlSetOnEvent(-1, "btnAddConfirm")
			GUICtrlSetState(-1, $GUI_SHOW)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnAddProfile_Info_01", "Add New Profile"))
		$g_hBtnConfirmAddProfile = GUICtrlCreateButton("", $x + 135, $y, 24, 24)
			_GUICtrlButton_SetImageList($g_hBtnConfirmAddProfile, $bIconConfirm, 4)
			GUICtrlSetOnEvent(-1, "btnAddConfirm")
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnConfirmAddProfile_Info_01", "Confirm"))
		$g_hBtnConfirmRenameProfile = GUICtrlCreateButton("", $x + 135, $y, 24, 24)
			_GUICtrlButton_SetImageList($g_hBtnConfirmRenameProfile, $bIconConfirm, 4)
			GUICtrlSetOnEvent(-1, "btnRenameConfirm")
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnConfirmAddProfile_Info_01", -1))
		$g_hBtnDeleteProfile = GUICtrlCreateButton("", $x + 164, $y, 24, 24)
			_GUICtrlButton_SetImageList($g_hBtnDeleteProfile, $bIconDelete, 4)
			GUICtrlSetOnEvent(-1, "btnDeleteCancel")
			GUICtrlSetState(-1, $GUI_SHOW)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnDeleteProfile_Info_01", "Delete Profile"))
		$g_hBtnCancelProfileChange = GUICtrlCreateButton("", $x + 164, $y, 24, 24)
			_GUICtrlButton_SetImageList($g_hBtnCancelProfileChange, $bIconCancel, 4)
			GUICtrlSetOnEvent(-1, "btnDeleteCancel")
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnCancelProfileChange_Info_01", "Cancel"))
		$g_hBtnRenameProfile = GUICtrlCreateButton("", $x + 194, $y, 24, 24)
			_GUICtrlButton_SetImageList($g_hBtnRenameProfile, $bIconEdit, 4)
			GUICtrlSetOnEvent(-1, "btnRenameConfirm")
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnRenameProfile_Info_01", "Rename Profile"))
		$g_hBtnPullSharedPrefs = GUICtrlCreateButton("", $x + 224, $y, 24, 24)
			_GUICtrlButton_SetImageList($g_hBtnPullSharedPrefs, $bIconPull, 4)
			GUICtrlSetOnEvent(-1, "btnPullSharedPrefs")
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnPullSharedPrefs_Info_01", "Pull CoC shared_prefs folder"))
		$g_hBtnPushSharedPrefs = GUICtrlCreateButton("", $x + 254, $y, 24, 24)
			_GUICtrlButton_SetImageList($g_hBtnPushSharedPrefs, $bIconPush, 4)
			GUICtrlSetOnEvent(-1, "btnPushSharedPrefs")
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnPushSharedPrefs_Info_01", "Push CoC shared_prefs folder"))
		$g_hBtnSaveprofile = GUICtrlCreateButton("", $x + 284, $y, 24, 24)
			_GUICtrlButton_SetImageList($g_hBtnSaveprofile, $bIconSave, 4)
			GUICtrlSetOnEvent(-1, "BtnSaveprofile")
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnSaveprofile_Info_01", "Save your current setting."))
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	Local $x = 25, $y = 95
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Group_02", "Switch Accounts"), $x - 20, $y - 20, $g_iSizeWGrpTab2, 360)
	$x -= 10
		$g_hCmbSwitchAcc = GUICtrlCreateCombo("", $x, $y-3, 175, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		Local $s = "No Switch Accounts Group"
		For $i = 1 To UBound($g_ahChkAccount)
			$s &= "|Switch Accounts Group " & $i
		Next
		GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "CmbSwitchAcc", $s), "No Switch Accounts Group")
		GUICtrlSetOnEvent(-1, "cmbSwitchAcc")
		

	$y += 20
		$g_hChkSwitchAcc = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "ChkSwitchAcc", "Enable Switch"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkSwitchAcc")
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "ChkSwitchAcc_Info_01", "Enable or disable current selected Switch Accounts Group"))
		
		$g_hBtnSaveToAll = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnSaveToAll", "Apply To"), $x + 105, $y, 70, 22)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnSaveToAll", "Apply Current Profile Setting To Other Profile"))
			GUICtrlSetOnEvent(-1, "btnSaveToAllOpen")

		$g_hCmbTotalAccount = GUICtrlCreateCombo("", $x + 350, $y - 1, 77, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		GUICtrlSetData(-1, "2 accounts|3 accounts|4 accounts|5 accounts|6 accounts|7 accounts|8 accounts|9 accounts|10 accounts|11 accounts|12 accounts|13 accounts|14 accounts|15 accounts|16 accounts", "2 accounts")
		GUICtrlSetOnEvent(-1, "cmbTotalAcc")
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "CmbTotalAccount", "Total CoC Accounts") & ": ", $x + 245, $y + 4, -1, -1)

		$g_hRadSwitchSharedPrefs = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadSwitchSharedPrefs", "Shared_prefs"), $x + 260, $y - 30, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadSwitchSharedPrefs_Info_01", "Support for Google Play and SuperCell ID accounts"))
		GUICtrlSetState(-1, $GUI_CHECKED)
		$g_hRadSwitchSuperCellID = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadSwitchSuperCellID", "SuperCell ID"), $x + 347, $y - 30, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadSwitchSuperCellID_Info_01", "Only support for all SuperCell ID accounts"))

	$y += 45
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_01", "Accounts"), $x - 5, $y, 60, -1, $SS_CENTER)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_02", "Profile name"), $x + 62, $y, 70, -1, $SS_CENTER)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_03", "Donate only"), $x + 145, $y, 60, -1, $SS_CENTER)
		$x = 230
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_01", "Accounts"), $x - 5, $y, 60, -1, $SS_CENTER)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_02", "Profile name"), $x + 72, $y, 70, -1, $SS_CENTER)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_03", "Donate only"), $x + 150, $y, 60, -1, $SS_CENTER)

	$x = 15
	$y += 14
		GUICtrlCreateGraphic($x, $y, 422, 1, $SS_GRAYRECT)

	$y += 7
		For $i = 0 To UBound($g_ahChkAccount) - 1
			If $i < 10 Then
				$g_ahChkAccount[$i] = GUICtrlCreateCheckbox($i + 1 & ".", $x, $y + ($i) * 25, -1, -1)
				GUICtrlSetOnEvent(-1, "chkAccountX")
				$g_ahCmbProfile[$i] = GUICtrlCreateCombo("", $x + 40, $y + ($i) * 25, 130, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
				GUICtrlSetOnEvent(-1, "cmbSwitchAccProfileX")
				GUICtrlSetData(-1, _GUICtrlComboBox_GetList($g_hCmbProfile))
				$g_ahChkDonate[$i] = GUICtrlCreateCheckbox("", $x + 180, $y + ($i) * 25 - 3, -1, 25)
			Else
				$x = 230
				$y = 180
				$g_ahChkAccount[$i] = GUICtrlCreateCheckbox($i + 1 & ".", $x, $y + ($i - 10) * 25, -1, -1)
				GUICtrlSetOnEvent(-1, "chkAccountX")
				$g_ahCmbProfile[$i] = GUICtrlCreateCombo("", $x + 40, $y + ($i - 10) * 25, 130, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
				GUICtrlSetOnEvent(-1, "cmbSwitchAccProfileX")
				GUICtrlSetData(-1, _GUICtrlComboBox_GetList($g_hCmbProfile))
				$g_ahChkDonate[$i] = GUICtrlCreateCheckbox("", $x + 180, $y + ($i - 10) * 25 - 3, -1, 25)
			EndIf
		Next
	GUICtrlCreateGroup("", -99, -99, 1, 1)

EndFunc   ;==>CreateBotProfiles

Global $g_hGUI_SaveToProfiles = 0, $g_ahChkCopyAccount[16], $g_ahTxtCopyAccount[16], $g_hChkEnableSaveAll = 0, $g_hBtnSaveToAllClose = 0, $g_hBtnSaveToAllApply = 0
Func CreateSaveToProfiles()
	Local $aActiveProfile = AccountNoActive()
	$g_hGUI_SaveToProfiles = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - SaveTo", "GUI_SaveToProfiles", "Save Current Profile Settings to Others"), 430, 380, $g_iFrmBotPosX, $g_iFrmBotPosY + 200, $WS_DLGFRAME, -1, $g_hFrmBot)
	
	Local $x = 25, $y = 25
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - SaveTo", "SaveTo", "Save Current Profile settings to :"), $x - 20, $y - 20, 420, 280)
		For $i = 0 To UBound($aActiveProfile) - 1
			If $i < 10 Then
				$g_ahChkCopyAccount[$i] = GUICtrlCreateCheckbox($i + 1 & ".", $x, $y + ($i) * 25, -1, -1)
				$g_ahTxtCopyAccount[$i] = GUICtrlCreateInput($g_asProfileName[$i], $x + 40, $y + ($i) * 25, 130, 22)
				GUICtrlSetState(-1, $GUI_DISABLE)
				If Not $aActiveProfile[$i] Then 
					GUICtrlSetState($g_ahChkCopyAccount[$i], $GUI_UNCHECKED)
					GUICtrlSetState($g_ahChkCopyAccount[$i], $GUI_DISABLE)
					GUICtrlSetData($g_ahTxtCopyAccount[$i], "")
				EndIf
			Else
				$x = 230
				$y = 25 
				$g_ahChkCopyAccount[$i] = GUICtrlCreateCheckbox($i + 1 & ".", $x, $y + ($i - 10) * 25, -1, -1)
				$g_ahTxtCopyAccount[$i] = GUICtrlCreateInput($g_asProfileName[$i], $x + 40, $y + ($i - 10) * 25, 130, 22)
				GUICtrlSetState(-1, $GUI_DISABLE)
				If Not $aActiveProfile[$i] Then 
					GUICtrlSetState($g_ahChkCopyAccount[$i], $GUI_UNCHECKED)
					GUICtrlSetState($g_ahChkCopyAccount[$i], $GUI_DISABLE)
					GUICtrlSetData($g_ahTxtCopyAccount[$i], "")
				EndIf
			EndIf
		Next
		
		$g_hBtnSaveToAllApply = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnSaveToAllApply", "Apply"), 290, $y + 160, 85, 25)
			GUICtrlSetOnEvent(-1, "btnSaveToAllApply")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$y = 290
	$g_hChkEnableSaveAll = GUICtrlCreateCheckbox("Check All", 30, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkCheckAllSaveProfile")
	$g_hBtnSaveToAllClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnSaveToAllClose", "Close"), 200, $y, 85, 25)
		GUICtrlSetOnEvent(-1, "btnSaveToAllClose")
	
EndFunc
