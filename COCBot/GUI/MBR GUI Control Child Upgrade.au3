; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control Upgrade
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: MyBot.run team
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func InitTranslatedTextUpgradeTab()
	GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "MsgBox_Warning_Title", "Warning about your settings...")
	GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "MsgBox_Warning_Text", "Warning ! You selected 2 resources to ignore... That can be a problem,\r\n" & _
		"and Auto Upgrade can be ineffective, by not launching any upgrade...\r\n" & _
		"I recommend you to select only one resource, not more...")
	GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "MsgBox_Invalid_Title", "Invalid settings...")
	GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "MsgBox_Invalid_Text", "Warning ! You selected 3 resources to ignore... And you can't...\r\n" & _
		"With your settings, Auto Upgrade will be completely ineffective\r\n" & _
		"and will not launch any upgrade... You must deselect one or more\r\n" & _
		"ignored resource.")
EndFunc   ;==>InitTranslatedTextUpgradeTab

Func btnLocateUpgrades()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	LocateUpgrades()
	$g_bRunState = $wasRunState
EndFunc   ;==>btnLocateUpgrades

Func btnchkbxUpgrade()
	For $i = 0 To UBound($g_avBuildingUpgrades, 1) - 1
		If GUICtrlRead($g_hChkUpgrade[$i]) = $GUI_CHECKED Then
			$g_abBuildingUpgradeEnable[$i] = True
		Else
			$g_abBuildingUpgradeEnable[$i] = False
		EndIf
	Next
EndFunc   ;==>btnchkbxUpgrade

Func btnchkbxRepeat()
	For $i = 0 To UBound($g_avBuildingUpgrades, 1) - 1
		If GUICtrlRead($g_hChkUpgradeRepeat[$i]) = $GUI_CHECKED Then
			$g_abUpgradeRepeatEnable[$i] = True
		Else
			$g_abUpgradeRepeatEnable[$i] = False
		EndIf
	Next
EndFunc   ;==>btnchkbxRepeat

Func picUpgradeTypeLocation()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ClickAway() ; Clear screen
	Sleep(500)
	Zoomout()
	Local $inum
	For $inum = 0 To UBound($g_avBuildingUpgrades, 1) - 1
		If @GUI_CtrlId = $g_hPicUpgradeType[$inum] Then
			Local $x = $g_avBuildingUpgrades[$inum][0]
			Local $y = $g_avBuildingUpgrades[$inum][1]
			Local $n = $g_avBuildingUpgrades[$inum][4]
			SetDebugLog("Selecting #" & $inum + 1 & ": " & $n & ", (" & $x & "," & $y & ")")
			If isInsideDiamondXY($x, $y) Then ; check for valid location
				SetDebugLog("Building Location : " & $x & "," & $y)
				BuildingClick($g_avBuildingUpgrades[$inum][0], $g_avBuildingUpgrades[$inum][1], "Select", $g_avBuildingUpgrades[$inum][8])
				Sleep(100)
				If StringInStr($n, "collect", $STR_NOCASESENSEBASIC) Or _
						StringInStr($n, "gold mine", $STR_NOCASESENSEBASIC) Or _
						StringInStr($n, "drill", $STR_NOCASESENSEBASIC) Then
						SetLog("Building is " & $n & ", need second click", $COLOR_DEBUG)
					ClickAway() ;Click away to deselect collector if was not full, and collected with previous click
					Sleep(100)
					BuildingClick($g_avBuildingUpgrades[$inum][0], $g_avBuildingUpgrades[$inum][1], "Select", $g_avBuildingUpgrades[$inum][8]) ;Select collector
				EndIf
			EndIf
			ExitLoop
		EndIf
	Next
	$g_bRunState = $wasRunState
EndFunc   ;==>picUpgradeTypeLocation

Func btnResetUpgrade()
	Local $iEmptyRow=-1 ;-1 means no empty row found yet.
	Local $j=0 ;temp upgrade type or status
	;Sleep(5000)
	;SetDebugLog("Reset Upgarde *******************************************")
	For $i = 0 To UBound($g_avBuildingUpgrades, 1) - 1
		If GUICtrlRead($g_hChkUpgradeRepeat[$i]) = $GUI_CHECKED Then
		;SetDebugLog("Row to keep " & $i)
		  If $iEmptyRow<>-1 Then  ;Is there an empty row to fill?
		    ;SetDebugLog("Moving from " & $i)
			;SetDebugLog("Moving to " & $iEmptyRow)
		    ;Move this row up...
			$g_aiPicUpgradeStatus[$iEmptyRow] = $g_aiPicUpgradeStatus[$i] ; Upgrade status
		    $g_avBuildingUpgrades[$iEmptyRow][0] = $g_avBuildingUpgrades[$i][0] ;Upgrade Location X
		    $g_avBuildingUpgrades[$iEmptyRow][1] = $g_avBuildingUpgrades[$i][1] ;Upgrade Location Y
		    $g_avBuildingUpgrades[$iEmptyRow][2] = $g_avBuildingUpgrades[$i][2] ;Upgrade Value
			;SetDebugLog("Type setting to " & $g_avBuildingUpgrades[$i][3])
		    $g_avBuildingUpgrades[$iEmptyRow][3] = $g_avBuildingUpgrades[$i][3] ;Upgrade Type
			;SetDebugLog("Name in global setting to " & $g_avBuildingUpgrades[$i][4])
		    $g_avBuildingUpgrades[$iEmptyRow][4] = $g_avBuildingUpgrades[$i][4] ;Upgrade Unit Name
			;SetDebugLog("Level in global setting to " & $g_avBuildingUpgrades[$i][5])
		    $g_avBuildingUpgrades[$iEmptyRow][5] = $g_avBuildingUpgrades[$i][5] ;Upgrade Level
		    $g_avBuildingUpgrades[$iEmptyRow][6] = $g_avBuildingUpgrades[$i][6] ;Upgrade Duration
		    $g_avBuildingUpgrades[$iEmptyRow][7] = $g_avBuildingUpgrades[$i][7] ;Upgrade Finish Time
			$g_avBuildingUpgrades[$iEmptyRow][8] = $g_avBuildingUpgrades[$i][8] ;Upgrade Finish Time

			;Set the GUI data for new row and clear the GUI data for the cleared row.
			;GUI Unit Name
			;SetDebugLog("Setting name " & $g_avBuildingUpgrades[$iEmptyRow][4])
			GUICtrlSetData($g_hTxtUpgradeName[$iEmptyRow], $g_avBuildingUpgrades[$iEmptyRow][4])
			GUICtrlSetData($g_hTxtUpgradeName[$i], "")
			;GUI Unit Level
			;SetDebugLog("Setting level " & $g_avBuildingUpgrades[$iEmptyRow][5])
			GUICtrlSetData($g_hTxtUpgradeLevel[$iEmptyRow], $g_avBuildingUpgrades[$iEmptyRow][5])
		    GUICtrlSetData($g_hTxtUpgradeLevel[$i], "")
			;Upgrade value in GUI
			GUICtrlSetData($g_hTxtUpgradeValue[$iEmptyRow], $g_avBuildingUpgrades[$iEmptyRow][2])
		    GUICtrlSetData($g_hTxtUpgradeValue[$i], "")
		    ;Upgrade duration in GUI
			GUICtrlSetData($g_hTxtUpgradeTime[$iEmptyRow], $g_avBuildingUpgrades[$iEmptyRow][6])
			GUICtrlSetData($g_hTxtUpgradeTime[$i], "")

			;GUI upgrade type image
			$j = $eIcnElixir
			If $g_avBuildingUpgrades[$iEmptyRow][3] = "GOLD" Then $j = $eIcnGold
			;SetDebugLog("Setting GUI type to " & $j)
			_GUICtrlSetImage($g_hPicUpgradeType[$iEmptyRow], $g_sLibIconPath, $j)
		    _GUICtrlSetImage($g_hPicUpgradeType[$i], $g_sLibIconPath, $eIcnBlank)

			;GUI Status icon : Still not working right!
			;$eIcnTroops=43, $eIcnGreenLight=69, $eIcnRedLight=71 or $eIcnYellowLight=73
			;SetDebugLog("Setting status to " & $g_aiPicUpgradeStatus[$i])
			;$j=$g_aiPicUpgradeStatus[$i]
			;No idea why this crap is needed, but I can't pass a variable to _GUICtrlSetImage
			$j=$eIcnGreenLight
			If $g_aiPicUpgradeStatus[$i] = $eIcnYellowLight Then $j=$eIcnYellowLight
			$g_aiPicUpgradeStatus[$iEmptyRow] = $j
			_GUICtrlSetImage($g_hPicUpgradeStatus[$iEmptyRow], $g_sLibIconPath, $j)
		    ;SetDebugLog("Clearing old status to red light " & $eIcnRedLight)
			$g_aiPicUpgradeStatus[$i] = $eIcnRedLight ;blank row goes red
			_GUICtrlSetImage($g_hPicUpgradeStatus[$i], $g_sLibIconPath, $eIcnRedLight)

			;Upgrade selection box
			GUICtrlSetState($g_hChkUpgrade[$iEmptyRow], $GUI_CHECKED)
			GUICtrlSetState($g_hChkUpgrade[$i], $GUI_UNCHECKED)
			;Upgrade finish time in GUI
			GUICtrlSetData($g_hTxtUpgradeEndTime[$iEmptyRow], $g_avBuildingUpgrades[$iEmptyRow][7])
		    GUICtrlSetData($g_hTxtUpgradeEndTime[$i], "")
			;Repeat box
			GUICtrlSetState($g_hChkUpgradeRepeat[$iEmptyRow], $GUI_CHECKED)
		    GUICtrlSetState($g_hChkUpgradeRepeat[$i], $GUI_UNCHECKED)

			;Now clear the row we just moved from.
			$g_avBuildingUpgrades[$i][0] = -1 ;Upgrade Location X
		    $g_avBuildingUpgrades[$i][1] = -1 ;Upgrade Location Y
		    $g_avBuildingUpgrades[$i][2] = -1 ;Upgrade Value
		    $g_avBuildingUpgrades[$i][3] = "" ;Upgrade Type
		    $g_avBuildingUpgrades[$i][4] = "" ;Upgrade Unit Name
		    $g_avBuildingUpgrades[$i][5] = "" ;Upgrade Level
		    $g_avBuildingUpgrades[$i][6] = "" ;Upgrade Duration
		    $g_avBuildingUpgrades[$i][7] = "" ;Upgrade Finish Time
			$g_avBuildingUpgrades[$i][8] = -1 ;ZoomFactor
			
			$i = $iEmptyRow ;Reset counter to this row so we continue forward from here.
			$iEmptyRow = -1 ;This should be the first empty row now.

		  Else
			;set these to clear up old status icon issues on rows not moved
		    ;SetDebugLog("Not moving row " & $i)
			$j=$g_aiPicUpgradeStatus[$i]
			;SetDebugLog("Setting GUI status to " & $j) ;
			;Following works if a constant is used, but not an variable?
			if $j=69 then _GUICtrlSetImage($g_hPicUpgradeStatus[$i], $g_sLibIconPath, 69)
			if $j=73 then _GUICtrlSetImage($g_hPicUpgradeStatus[$i], $g_sLibIconPath, 73)
			ContinueLoop
		  Endif
		Else ;Row not checked.  Clear it.
		  ;SetDebugLog("Row not checked, clearing row " & $i)
		  $g_avBuildingUpgrades[$i][0] = -1 ;Upgrade position x
		  $g_avBuildingUpgrades[$i][1] = -1 ;Upgrade position y
		  $g_avBuildingUpgrades[$i][2] = -1 ;Upgrade value
		  $g_avBuildingUpgrades[$i][3] = "" ;Upgrade Type
		  $g_avBuildingUpgrades[$i][4] = "" ;Upgrade Unit Name
		  $g_avBuildingUpgrades[$i][5] = "" ;Upgrade Level
		  $g_avBuildingUpgrades[$i][6] = "" ;Upgrade Duration
		  $g_avBuildingUpgrades[$i][7] = "" ;Upgrade Finish Time
		  $g_avBuildingUpgrades[$i][8] = -1 ;ZoomFactor
		  GUICtrlSetData($g_hTxtUpgradeName[$i], "")  ;GUI Unit Name
		  GUICtrlSetData($g_hTxtUpgradeLevel[$i], "") ;GUI Unit Level
		  GUICtrlSetData($g_hTxtUpgradeValue[$i], "") ;Upgrade value in GUI
		  GUICtrlSetData($g_hTxtUpgradeTime[$i], "")  ;Upgrade duration in GUI
		  _GUICtrlSetImage($g_hPicUpgradeType[$i], $g_sLibIconPath, $eIcnBlank) ;Upgrade type blank
		  $g_aiPicUpgradeStatus[$i] = $eIcnRedLight
		  _GUICtrlSetImage($g_hPicUpgradeStatus[$i], $g_sLibIconPath, $eIcnRedLight) ;Upgrade status to not ready
		  GUICtrlSetState($g_hChkUpgrade[$i], $GUI_UNCHECKED) ;Change upgrade selection box to unchecked
		  GUICtrlSetData($g_hTxtUpgradeEndTime[$i], "") ;Clear Upgrade time in GUI
		  GUICtrlSetState($g_hChkUpgradeRepeat[$i], $GUI_UNCHECKED) ;Change repeat box to unchecked
		  If $iEmptyRow = -1 Then $iEmptyRow=$i ;This row is now empty.
		Endif
	Next
EndFunc   ;==>btnResetUpgrade

Func chkLab()
	If GUICtrlRead($g_hChkAutoLabUpgrades) = $GUI_CHECKED Then
		$g_bAutoLabUpgradeEnable = True
		For $i = $g_hLblNextUpgrade To $g_hUpgradeAnyTroops
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
		GUICtrlSetState($g_hPicLabUpgrade, $GUI_SHOW)
		GUICtrlSetState($g_hLblNextUpgrade, $GUI_ENABLE)
		GUICtrlSetState($g_hCmbLaboratory, $GUI_ENABLE)
		_GUICtrlSetImage($g_hPicLabUpgrade, $g_sLibIconPath, $g_avLabTroops[$g_iCmbLaboratory][1])
	Else
		$g_bAutoLabUpgradeEnable = False
		For $i = $g_hLblNextUpgrade To $g_hUpgradeAnyTroops
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
		GUICtrlSetState($g_hPicLabUpgrade, $GUI_HIDE)
		GUICtrlSetState($g_hLblNextUpgrade, $GUI_DISABLE)
		GUICtrlSetState($g_hCmbLaboratory, $GUI_DISABLE)
		_GUICtrlSetImage($g_hPicLabUpgrade, $g_sLibIconPath, $g_avLabTroops[0][1])
	EndIf
	If $g_iCmbLaboratory = 0 Then
		GUICtrlSetState($g_hChkLabUpgradeOrder, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkLabUpgradeOrder, $GUI_DISABLE)
	EndIf
	LabStatusGUIUpdate()
EndFunc   ;==>chkLab

Func chkLabUpgradeOrder()
	If GUICtrlRead($g_hChkLabUpgradeOrder) = $GUI_CHECKED Then
		$g_bLabUpgradeOrderEnable = True
		GUICtrlSetState($g_hCmbLaboratory, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnRemoveLabUpgradeOrder, $GUI_ENABLE)
		GUICtrlSetState($g_hBtnSetLabUpgradeOrder, $GUI_ENABLE)
		GUICtrlSetState($g_hUpgradeAnyTroops, $GUI_ENABLE)
		For $i = 0 To UBound($g_ahCmbLabUpgradeOrder) - 1
			GUICtrlSetState($g_ahCmbLabUpgradeOrder[$i], $GUI_ENABLE)
		Next
	Else
		$g_bLabUpgradeOrderEnable = False
		GUICtrlSetState($g_hCmbLaboratory, $GUI_ENABLE)
		GUICtrlSetState($g_hBtnRemoveLabUpgradeOrder, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnSetLabUpgradeOrder, $GUI_DISABLE)
		GUICtrlSetState($g_hUpgradeAnyTroops, $GUI_DISABLE)
		For $i = 0 To UBound($g_ahCmbLabUpgradeOrder) - 1
			GUICtrlSetState($g_ahCmbLabUpgradeOrder[$i], $GUI_DISABLE)
		Next
	EndIf
EndFunc ;==>chkLabUpgradeOrder

Func cmbLabUpgradeOrder()
	Local $iGUI_CtrlId = @GUI_CtrlId
	For $i = 0 To UBound($g_ahCmbLabUpgradeOrder) - 1 ; check for duplicate combobox index and flag problem
		If $iGUI_CtrlId = $g_ahCmbLabUpgradeOrder[$i] Then ContinueLoop
		If _GUICtrlComboBox_GetCurSel($iGUI_CtrlId) = _GUICtrlComboBox_GetCurSel($g_ahCmbLabUpgradeOrder[$i]) Then
			_GUICtrlComboBox_SetCurSel($g_ahCmbLabUpgradeOrder[$i], -1)
			GUISetState()
		EndIf
	Next
EndFunc   ;==>cmbLabUpgradeOrder

Func cmbSLabUpgradeOrder()
	Local $iGUI_CtrlId = @GUI_CtrlId
	For $i = 0 To UBound($g_ahCmbSLabUpgradeOrder) - 1 ; check for duplicate combobox index and flag problem
		If $iGUI_CtrlId = $g_ahCmbSLabUpgradeOrder[$i] Then ContinueLoop
		If _GUICtrlComboBox_GetCurSel($iGUI_CtrlId) = _GUICtrlComboBox_GetCurSel($g_ahCmbSLabUpgradeOrder[$i]) Then
			_GUICtrlComboBox_SetCurSel($g_ahCmbSLabUpgradeOrder[$i], -1)
			GUISetState()
		EndIf
	Next
EndFunc   ;==>cmbSLabUpgradeOrder

Func btnRemoveLabUpgradeOrder()
	For $i = 0 To UBound($g_ahCmbLabUpgradeOrder) - 1
		_GUICtrlComboBox_SetCurSel($g_ahCmbLabUpgradeOrder[$i], -1)
	Next
EndFunc

Func btnRemoveSLabUpgradeOrder()
	For $i = 0 To UBound($g_ahCmbSLabUpgradeOrder) - 1
		_GUICtrlComboBox_SetCurSel($g_ahCmbSLabUpgradeOrder[$i], -1)
	Next
EndFunc

Func btnSetLabUpgradeOrder()
	Local $d
	SetLog("Set Laboratory ugrade Order",$COLOR_SUCCESS)
	For $i = 0 To UBound($g_ahCmbLabUpgradeOrder) - 1
		$g_aCmbLabUpgradeOrder[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmbLabUpgradeOrder[$i])
		$d = $g_aCmbLabUpgradeOrder[$i]
		SetLog($i+1 & " : [" & $d+1 & "] " & $g_avLabTroops[$d+1][0], $COLOR_SUCCESS)
	Next
EndFunc

Func btnSetSLabUpgradeOrder()
	Local $d
	SetLog("Set Star Laboratory ugrade Order",$COLOR_SUCCESS)
	For $i = 0 To UBound($g_ahCmbSLabUpgradeOrder) - 1
		$g_aCmbSLabUpgradeOrder[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmbSLabUpgradeOrder[$i])
		$d = $g_aCmbSLabUpgradeOrder[$i]
		SetLog($i+1 & " : " & $g_avStarLabTroops[$d+1][3], $COLOR_SUCCESS)
	Next
EndFunc

Func chkStarLab()
	If GUICtrlRead($g_hChkAutoStarLabUpgrades) = $GUI_CHECKED Then
		$g_bAutoStarLabUpgradeEnable = True
		If GUICtrlRead($g_hChkSLabUpgradeOrder) = $GUI_CHECKED Then GUICtrlSetState($g_hCmbStarLaboratory, $GUI_ENABLE)
	Else
		$g_bAutoStarLabUpgradeEnable = False
		GUICtrlSetState($g_hCmbStarLaboratory, $GUI_DISABLE)
	EndIf
	If $g_iCmbStarLaboratory = 0 And $g_bAutoStarLabUpgradeEnable Then
		GUICtrlSetState($g_hChkSLabUpgradeOrder, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkSLabUpgradeOrder, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkStarLab

Func chkSLabUpgradeOrder()
	If GUICtrlRead($g_hChkSLabUpgradeOrder) = $GUI_CHECKED Then
		$g_bSLabUpgradeOrderEnable = True
		GUICtrlSetState($g_hCmbStarLaboratory, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnRemoveSLabUpgradeOrder, $GUI_ENABLE)
		GUICtrlSetState($g_hBtnSetSLabUpgradeOrder, $GUI_ENABLE)
		For $i = 0 To UBound($g_ahCmbSLabUpgradeOrder) - 1
			GUICtrlSetState($g_ahCmbSLabUpgradeOrder[$i], $GUI_ENABLE)
		Next
		GUICtrlSetState($g_hChkUpgradeAnyIfAllOrderMaxed, $GUI_ENABLE)
	Else
		$g_bSLabUpgradeOrderEnable = False
		GUICtrlSetState($g_hCmbStarLaboratory, $GUI_ENABLE)
		GUICtrlSetState($g_hBtnRemoveSLabUpgradeOrder, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnSetSLabUpgradeOrder, $GUI_DISABLE)
		For $i = 0 To UBound($g_ahCmbSLabUpgradeOrder) - 1
			GUICtrlSetState($g_ahCmbSLabUpgradeOrder[$i], $GUI_DISABLE)
		Next
		GUICtrlSetState($g_hChkUpgradeAnyIfAllOrderMaxed, $GUI_DISABLE)
	EndIf
	If GUICtrlRead($g_hChkUpgradeAnyIfAllOrderMaxed) = $GUI_CHECKED Then
		$g_bChkUpgradeAnyIfAllOrderMaxed = True
	Else
		$g_bChkUpgradeAnyIfAllOrderMaxed = False
	EndIf
EndFunc ;==>chkSLabUpgradeOrder

Func cmbStarLab()
	$g_iCmbStarLaboratory = _GUICtrlComboBox_GetCurSel($g_hCmbStarLaboratory)
	If $g_iCmbStarLaboratory = 0 Then
		GUICtrlSetState($g_hChkSLabUpgradeOrder, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkSLabUpgradeOrder, $GUI_DISABLE)
	Endif
EndFunc   ;==>cmbStarLab

Func LabStatusGUIUpdate()
	If _DateIsValid($g_sLabUpgradeTime) Then
		_GUICtrlSetTip($g_hBtnResetLabUpgradeTime, GetTranslatedFileIni("MBR Func_Village_Upgrade", "BtnResetLabUpgradeTime_Info_01", "Visible Red button means that laboratory upgrade in process") & @CRLF & _
				GetTranslatedFileIni("MBR Func_Village_Upgrade", "BtnResetLabUpgradeTime_Info_02", "This will automatically disappear when near time for upgrade to be completed.") & @CRLF & _
				GetTranslatedFileIni("MBR Func_Village_Upgrade", "BtnResetLabUpgradeTime_Info_03", "If upgrade has been manually finished with gems before normal end time,") & @CRLF & _
				GetTranslatedFileIni("MBR Func_Village_Upgrade", "BtnResetLabUpgradeTime_Info_04", "Click red button to reset internal upgrade timer BEFORE STARTING NEW UPGRADE") & @CRLF & _
				GetTranslatedFileIni("MBR Func_Village_Upgrade", "BtnResetLabUpgradeTime_Info_05", "Caution - Unnecessary timer reset will force constant checks for lab status") & @CRLF & @CRLF & _
				GetTranslatedFileIni("MBR Func_Village_Upgrade", "BtnResetLabUpgradeTime_Info_06", "Troop Upgrade started") & ", " & _
				GetTranslatedFileIni("MBR Func_Village_Upgrade", "BtnResetLabUpgradeTime_Info_07", "Will begin to check completion at:") & " " & $g_sLabUpgradeTime & @CRLF & " ")
		GUICtrlSetState($g_hBtnResetLabUpgradeTime, $GUI_SHOW)
		GUICtrlSetState($g_hBtnResetLabUpgradeTime, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hBtnResetLabUpgradeTime, $GUI_HIDE) ; comment this line out to edit GUI
		GUICtrlSetState($g_hBtnResetLabUpgradeTime, $GUI_DISABLE)
	EndIf
EndFunc   ;==>LabStatusGUIUpdate

Func cmbLab()
	$g_iCmbLaboratory = _GUICtrlComboBox_GetCurSel($g_hCmbLaboratory)
	_GUICtrlSetImage($g_hPicLabUpgrade, $g_sLibIconPath, $g_avLabTroops[$g_iCmbLaboratory][1])
	SetLog("Set Laboratory Upgrade [" & $g_iCmbLaboratory & "] " & $g_avLabTroops[$g_iCmbLaboratory][0])
	If $g_iCmbLaboratory = 0 Then
		GUICtrlSetState($g_hChkLabUpgradeOrder, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkLabUpgradeOrder, $GUI_DISABLE)
	EndIf
	chkLabUpgradeOrder()
EndFunc   ;==>cmbLab

Func chkUpgradeKing()
	If $g_iTownHallLevel > 6 Then ; Must be TH7 or above to have King
		If GUICtrlRead($g_hCmbBoostBarbarianKing) > 0 Then
			GUICtrlSetState($g_hChkUpgradeKing, $GUI_DISABLE)
			GUICtrlSetState($g_hChkUpgradeKing, $GUI_UNCHECKED)
			$g_bUpgradeKingEnable = False
		Else
			GUICtrlSetState($g_hChkUpgradeKing, $GUI_ENABLE)
		EndIf

		Local $ahGroupKingWait[4] = [$g_hChkDBKingWait, $g_hChkABKingWait, $g_hPicDBKingWait, $g_hPicABKingWait]
		Local $TxtTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtKingWait_Info_01", -1) & @CRLF & _
						GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtKingWait_Info_02", -1)
		Local $TxtWarningTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtKingWait_Info_03", "ATTENTION: King auto upgrade is currently enable.")
		If GUICtrlRead($g_hChkUpgradeKing) = $GUI_CHECKED Then
			$g_bUpgradeKingEnable = True
			_GUI_Value_STATE("SHOW", $groupKingSleeping)
			For $i In $ahGroupKingWait
				_GUICtrlSetTip($i, $TxtTip & @CRLF & $TxtWarningTip)
			Next
		Else
			$g_bUpgradeKingEnable = False
			_GUI_Value_STATE("HIDE", $groupKingSleeping)
			For $i In $ahGroupKingWait
				_GUICtrlSetTip($i, $TxtTip)
			Next
		EndIf

	Else
		GUICtrlSetState($g_hChkUpgradeKing, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
	EndIf
EndFunc   ;==>chkUpgradeKing

Func chkUpgradeQueen()
	If $g_iTownHallLevel > 8 Then ; Must be TH9 or above to have Queen
		If GUICtrlRead($g_hCmbBoostArcherQueen) > 0 Then
			GUICtrlSetState($g_hChkUpgradeQueen, $GUI_DISABLE)
			GUICtrlSetState($g_hChkUpgradeQueen, $GUI_UNCHECKED)
			$g_bUpgradeQueenEnable = False
		Else
			GUICtrlSetState($g_hChkUpgradeQueen, $GUI_ENABLE)
		EndIf

		Local $ahGroupQueenWait[4] = [$g_hChkDBQueenWait, $g_hChkABQueenWait, $g_hPicDBQueenWait, $g_hPicABQueenWait]
		Local $TxtTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtQueenWait_Info_01", -1) & @CRLF & _
						GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtQueenWait_Info_02", -1)
		Local $TxtWarningTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtQueenWait_Info_03", "ATTENTION: Queen auto upgrade is currently enable.")
		If GUICtrlRead($g_hChkUpgradeQueen) = $GUI_CHECKED Then
			$g_bUpgradeQueenEnable = True
			_GUI_Value_STATE("SHOW", $groupQueenSleeping)
			For $i In $ahGroupQueenWait
				_GUICtrlSetTip($i, $TxtTip & @CRLF & $TxtWarningTip)
			Next
		Else
			$g_bUpgradeQueenEnable = False
			_GUI_Value_STATE("HIDE", $groupQueenSleeping)
			For $i In $ahGroupQueenWait
				_GUICtrlSetTip($i, $TxtTip)
			Next
		EndIf
	Else
		GUICtrlSetState($g_hChkUpgradeQueen, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
	EndIf
EndFunc   ;==>chkUpgradeQueen

Func chkUpgradeWarden()
	If $g_iTownHallLevel > 10 Then ; Must be TH11 to have warden
		If GUICtrlRead($g_hCmbBoostWarden) > 0 Then
			GUICtrlSetState($g_hChkUpgradeWarden, $GUI_DISABLE)
			GUICtrlSetState($g_hChkUpgradeWarden, $GUI_UNCHECKED)
			$g_bUpgradeWardenEnable = False
		Else
			GUICtrlSetState($g_hChkUpgradeWarden, $GUI_ENABLE)
		EndIf

		Local $ahGroupWardenWait[4] = [$g_hChkDBWardenWait, $g_hChkABWardenWait, $g_hPicDBWardenWait, $g_hPicABWardenWait]
		Local $TxtTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtWardenWait_Info_01", -1) & @CRLF & _
						GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtWardenWait_Info_02", -1)
		Local $TxtWarningTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtWardenWait_Info_03", "ATTENTION: Warden auto upgrade is currently enable.")
		If GUICtrlRead($g_hChkUpgradeWarden) = $GUI_CHECKED Then
			$g_bUpgradeWardenEnable = True
			_GUI_Value_STATE("SHOW", $groupWardenSleeping)
			For $i In $ahGroupWardenWait
				_GUICtrlSetTip($i, $TxtTip & @CRLF & $TxtWarningTip)
			Next
		Else
			$g_bUpgradeWardenEnable = False
			_GUI_Value_STATE("HIDE", $groupWardenSleeping)
			For $i In $ahGroupWardenWait
				_GUICtrlSetTip($i, $TxtTip)
			Next
		EndIf
	Else
		GUICtrlSetState($g_hChkUpgradeWarden, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
	EndIf
EndFunc   ;==>chkUpgradeWarden

Func chkUpgradeChampion()
	If $g_iTownHallLevel > 12 Then ; Must be TH13 to have Champion
		If GUICtrlRead($g_hCmbBoostChampion) > 0 Then
			GUICtrlSetState($g_hChkUpgradeChampion, $GUI_DISABLE)
			GUICtrlSetState($g_hChkUpgradeChampion, $GUI_UNCHECKED)
			$g_bUpgradeChampionEnable = False
		Else
			GUICtrlSetState($g_hChkUpgradeChampion, $GUI_ENABLE)
		EndIf

		Local $ahGroupChampionWait[4] = [$g_hChkDBChampionWait, $g_hChkABChampionWait, $g_hPicDBChampionWait, $g_hPicABChampionWait]
		Local $TxtTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtChampionWait_Info_01", -1) & @CRLF & _
						GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtChampionWait_Info_02", -1)
		Local $TxtWarningTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtChampionWait_Info_03", "ATTENTION: Champion auto upgrade is currently enable.")
		If GUICtrlRead($g_hChkUpgradeChampion) = $GUI_CHECKED Then
			$g_bUpgradeChampionEnable = True
			_GUI_Value_STATE("SHOW", $groupChampionSleeping)
			For $i In $ahGroupChampionWait
				_GUICtrlSetTip($i, $TxtTip & @CRLF & $TxtWarningTip)
			Next
		Else
			$g_bUpgradeChampionEnable = False
			_GUI_Value_STATE("HIDE", $groupChampionSleeping)
			For $i In $ahGroupChampionWait
				_GUICtrlSetTip($i, $TxtTip)
			Next
		EndIf
	Else
		GUICtrlSetState($g_hChkUpgradeChampion, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
	EndIf
EndFunc   ;==>chkUpgradeChampion

Func cmbHeroReservedBuilder()
	$g_iHeroReservedBuilder = _GUICtrlComboBox_GetCurSel($g_hCmbHeroReservedBuilder)
	If $g_iTownHallLevel > 6 Then ; Must be TH7 or above to have Heroes
		If $g_iTownHallLevel > 12 Then ; For TH13 enable up to 4 reserved builders
			GUICtrlSetData($g_hCmbHeroReservedBuilder, "|0|1|2|3|4", "0")
		ElseIf $g_iTownHallLevel > 10 Then ; For TH11 enable up to 3 reserved builders
			GUICtrlSetData($g_hCmbHeroReservedBuilder, "|0|1|2|3", "0")
		ElseIf $g_iTownHallLevel > 8 Then ; For TH9 enable up to 2 reserved builders
			GUICtrlSetData($g_hCmbHeroReservedBuilder, "|0|1|2", "0")
		Else ; For TH7 enable up to 1 reserved builder
			GUICtrlSetData($g_hCmbHeroReservedBuilder, "|0|1", "0")
		EndIf
		GUICtrlSetState($g_hCmbHeroReservedBuilder, $GUI_ENABLE)
		GUICtrlSetState($g_hLblHeroReservedBuilderTop, $GUI_ENABLE)
		GUICtrlSetState($g_hLblHeroReservedBuilderBottom, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hCmbHeroReservedBuilder, $GUI_DISABLE)
		GUICtrlSetState($g_hLblHeroReservedBuilderTop, $GUI_DISABLE)
		GUICtrlSetState($g_hLblHeroReservedBuilderBottom, $GUI_DISABLE)
	EndIf
	_GUICtrlComboBox_SetCurSel($g_hCmbHeroReservedBuilder, $g_iHeroReservedBuilder)
EndFunc   ;==>cmbHeroReservedBuilder

Func EnableUpgradeEquipment()
	If $g_iTownHallLevel < 8 Then
		GUICtrlSetState($g_hBtnHeroEquipment, $GUI_DISABLE)
		GUICtrlSetState($g_hChkCustomEquipmentOrderEnable, $GUI_UNCHECKED)
		btnRemoveEquipment()
	Else
		GUICtrlSetState($g_hBtnHeroEquipment, $GUI_ENABLE)
	EndIf
EndFunc   ;==>chkUpgradePets

Func BtnHeroEquipment()
	GUISetState(@SW_SHOW, $g_hGUI_HeroEquipment)
EndFunc   ;==>BtnHeroEquipment

Func CloseHeroEquipment()
	GUISetState(@SW_HIDE, $g_hGUI_HeroEquipment)
EndFunc   ;==>CloseHeroEquipment

Func chkEquipmentOrder()
	If GUICtrlRead($g_hChkCustomEquipmentOrderEnable) = $GUI_CHECKED Then
		For $i = $g_EquipmentOrderLabel[0] To $g_ahImgEquipmentOrderSet
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
	Else
		For $i = $g_EquipmentOrderLabel[0] To $g_ahImgEquipmentOrderSet
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
	EndIf
EndFunc

Func GUIRoyalEquipmentOrder()
	Local $bDuplicate = False
	Local $iGUI_CtrlId = @GUI_CtrlId
	Local $iCtrlIdImage = $iGUI_CtrlId + 1
	Local $iCtrlIdImage2 = $iGUI_CtrlId + 2
	Local $iEquipmentIndex = _GUICtrlComboBox_GetCurSel($iGUI_CtrlId) + 1

	If $iEquipmentIndex < UBound($g_ahCmbEquipmentOrder) - 1 Then
		_GUICtrlSetImage($iCtrlIdImage, $g_sLibIconPath, $g_aiEquipmentOrderIcon[$iEquipmentIndex]) ; set proper equipment icon
		_GUICtrlSetImage($iCtrlIdImage2, $g_sLibIconPath, $g_aiEquipmentOrderIcon2[$iEquipmentIndex]) ; set proper hero icon
	EndIf

	For $i = 0 To UBound($g_ahCmbEquipmentOrder) - 1 ; check for duplicate combobox index and flag problem
		If $iGUI_CtrlId = $g_ahCmbEquipmentOrder[$i] Then ContinueLoop
		If _GUICtrlComboBox_GetCurSel($iGUI_CtrlId) = _GUICtrlComboBox_GetCurSel($g_ahCmbEquipmentOrder[$i]) Then
			GUICtrlSetState($g_hChkCustomEquipmentOrder[$i], $GUI_UNCHECKED)
			_GUICtrlSetImage($g_ahImgEquipmentOrder[$i], $g_sLibIconPath, $eIcnOptions)
			_GUICtrlSetImage($g_ahImgEquipmentOrder2[$i], $g_sLibIconPath, $eIcnOptions)
			_GUICtrlComboBox_SetCurSel($g_ahCmbEquipmentOrder[$i], -1)
			GUISetState()
			$bDuplicate = True
		EndIf
	Next
	If $bDuplicate Then
		GUICtrlSetState($g_hBtnEquipmentOrderSet, $GUI_ENABLE) ; enable button to apply new order
		_GUICtrlSetImage($g_ahImgEquipmentOrderSet, $g_sLibIconPath, $eIcnRedLight) ; set status indicator to show need to apply new order
		Return
	Else
		GUICtrlSetState($g_hBtnEquipmentOrderSet, $GUI_ENABLE) ; enable button to apply new order
	EndIf
EndFunc   ;==>GUIRoyalEquipmentOrder

Func btnRegularOrder()
	btnRemoveEquipment()
	For $i = 0 To UBound($g_ahCmbEquipmentOrder) - 1
		GUICtrlSetState($g_ahCmbEquipmentOrder[$i], $GUI_ENABLE)
		_GUICtrlComboBox_SetCurSel($g_ahCmbEquipmentOrder[$i], $i)
		_GUICtrlSetImage($g_ahImgEquipmentOrder[$i], $g_sLibIconPath, $i + 1)
		_GUICtrlSetImage($g_ahImgEquipmentOrder2[$i], $g_sLibIconPath, $i + 1)
	Next
	btnEquipmentOrderSet()
	GUICtrlSetState($g_hBtnEquipmentOrderSet, $GUI_ENABLE) ; Re-enabling it.
EndFunc

Func btnRemoveEquipment()
	Local $sComboData = ""
	For $j = 0 To UBound($g_asEquipmentOrderList) - 1
		$sComboData &= $g_asEquipmentOrderList[$j][0] & "|"
	Next
	For $i = 0 To UBound($g_ahCmbEquipmentOrder) - 1
		$g_aiCmbCustomEquipmentOrder[$i] = -1
		$g_bChkCustomEquipmentOrder[$i] = 0
		_GUICtrlComboBox_ResetContent($g_ahCmbEquipmentOrder[$i])
		GUICtrlSetState($g_hChkCustomEquipmentOrder[$i], $GUI_UNCHECKED)
		GUICtrlSetData($g_ahCmbEquipmentOrder[$i], $sComboData, "")
		GUICtrlSetState($g_ahCmbEquipmentOrder[$i], $GUI_ENABLE)
		_GUICtrlSetImage($g_ahImgEquipmentOrder[$i], $g_sLibIconPath, $eIcnOptions)
		_GUICtrlSetImage($g_ahImgEquipmentOrder2[$i], $g_sLibIconPath, $eIcnOptions)
	Next
	GUICtrlSetState($g_hBtnEquipmentOrderSet, $GUI_DISABLE)
	_GUICtrlSetImage($g_ahImgEquipmentOrderSet, $g_sLibIconPath, $eIcnSilverStar)
	SetDefaultEquipmentGroup(False)
EndFunc   ;==>btnRemoveEquipment

Func SetDefaultEquipmentGroup($bSetLog = True)
	For $i = 0 To $eEquipmentCount - 1
		$g_aiEquipmentOrder[$i] = $i
	Next
EndFunc   ;==>SetDefaultEquipmentGroup

Func btnEquipmentOrderSet()
	Local $bReady = True ; Initialize ready to record troop order flag
	Local $sNewEquipmentList = ""

	Local $aiUsedEquipment = $g_aiEquipmentOrder
	Local $aTmpEquipmentOrder[0], $iStartShuffle = 0

	For $i = 0 To UBound($g_ahCmbEquipmentOrder) - 1
		Local $iValue = _GUICtrlComboBox_GetCurSel($g_ahCmbEquipmentOrder[$i])
		If $iValue <> -1 Then
			_ArrayAdd($aTmpEquipmentOrder, $iValue)
			Local $iEmpty = _ArraySearch($aiUsedEquipment, $iValue)
			If $iEmpty > -1 Then $aiUsedEquipment[$iEmpty] = -1
		EndIf
	Next

	$iStartShuffle = UBound($aTmpEquipmentOrder)

	_ArraySort($aiUsedEquipment)

	For $i = 0 To UBound($aTmpEquipmentOrder) - 1
		If $aiUsedEquipment[$i] = -1 Then $aiUsedEquipment[$i] = $aTmpEquipmentOrder[$i]
	Next

	_ArrayShuffle($aiUsedEquipment, $iStartShuffle)

	For $i = 0 To UBound($g_ahCmbEquipmentOrder) - 1
		GUICtrlSetState($g_ahCmbEquipmentOrder[$i], $GUI_ENABLE)
		_GUICtrlComboBox_SetCurSel($g_ahCmbEquipmentOrder[$i], $aiUsedEquipment[$i])
		_GUICtrlSetImage($g_ahImgEquipmentOrder[$i], $g_sLibIconPath, $g_aiEquipmentOrderIcon[$aiUsedEquipment[$i] + 1])
		_GUICtrlSetImage($g_ahImgEquipmentOrder2[$i], $g_sLibIconPath, $g_aiEquipmentOrderIcon2[$aiUsedEquipment[$i] + 1])
	Next

	$g_aiCmbCustomEquipmentOrder = $aiUsedEquipment
	If $bReady Then
		ChangeEquipmentOrder() ; code function to record new order
		If @error Then
			Switch @error
				Case 1
					SetLog("Code problem, can not continue till fixed!", $COLOR_ERROR)
				Case 2
					SetLog("Bad Combobox selections, please fix!", $COLOR_ERROR)
				Case 3
					SetLog("Unable to Change Equipment Upgrade Order due bad change count!", $COLOR_ERROR)
				Case Else
					SetLog("Monkey ate bad banana, something wrong with ChangeEquipmentOrder() code!", $COLOR_ERROR)
			EndSwitch
			_GUICtrlSetImage($g_ahImgEquipmentOrderSet, $g_sLibIconPath, $eIcnRedLight)
		Else
			SetLog("Equipment upgrade order changed successfully!", $COLOR_SUCCESS)
			For $i = 0 To $eEquipmentCount - 1
				$sNewEquipmentList &= $g_asEquipmenthortNames[$aiUsedEquipment[$i]] & ", "
			Next
			$sNewEquipmentList = StringTrimRight($sNewEquipmentList, 2)
			SetLog("Equipment order= " & $sNewEquipmentList, $COLOR_INFO)
		EndIf
	Else
		SetLog("Must use all Equipment and No duplicate equipment names!", $COLOR_ERROR)
		_GUICtrlSetImage($g_ahImgEquipmentOrderSet, $g_sLibIconPath, $eIcnRedLight)
	EndIf
EndFunc   ;==>btnEquipmentOrderSet

Func ChangeEquipmentOrder()
	Local $iUpdateCount = 0, $aUnique

	If Not IsUseCustomEquipmentOrder() Then ; check if no custom values saved yet.
		SetError(2, 0, False)
		Return
	EndIf

	$aUnique = _ArrayUnique($g_aiCmbCustomEquipmentOrder, 0, 0, 0, 0)
	$iUpdateCount = UBound($aUnique)

	If $iUpdateCount = $eEquipmentCount Then ; safety check that all troops properly assigned to new array.
		$g_aiEquipmentOrder = $aUnique
		_GUICtrlSetImage($g_ahImgEquipmentOrderSet, $g_sLibIconPath, $eIcnGreenLight)
	Else
		SetLog($iUpdateCount & "|" & $eEquipmentCount & " - Error - Bad equipment assignment in ChangeEquipmentOrder()", $COLOR_ERROR)
		SetError(3, 0, False)
		Return
	EndIf

	Return True
EndFunc   ;==>ChangeEquipmentOrder

Func IsUseCustomEquipmentOrder()
	For $i = 0 To UBound($g_aiCmbCustomEquipmentOrder) - 1 ; Check if custom order has been used, to select log message
		If $g_aiCmbCustomEquipmentOrder[$i] = -1 Then Return False
	Next
	Return True
EndFunc   ;==>IsUseCustomTroopOrder

Func chkWalls()
	If GUICtrlRead($g_hChkWalls) = $GUI_CHECKED Then
		$g_bAutoUpgradeWallsEnable = True
		For $i = $g_hChkWalls To $g_hBtnFindWalls
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
		;GUICtrlSetState($g_hChkUseGold, $GUI_ENABLE)
		;GUICtrlSetState($g_hChkUseElixir, $GUI_ENABLE)
		;GUICtrlSetState($g_hChkUseElixirGold, $GUI_ENABLE)
		;GUICtrlSetState($g_hTxtWallMinGold, $GUI_ENABLE)
		;GUICtrlSetState($g_hTxtWallMinElixir, $GUI_ENABLE)		
	Else
		$g_bAutoUpgradeWallsEnable = False
		For $i = $g_hChkWalls To $g_hBtnFindWalls
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
		;GUICtrlSetState($g_hChkUseGold, $GUI_DISABLE)
		;GUICtrlSetState($g_hChkUseElixir, $GUI_DISABLE)
		;GUICtrlSetState($g_hChkUseElixirGold, $GUI_DISABLE)
		;GUICtrlSetState($g_hTxtWallMinGold, $GUI_DISABLE)
		;GUICtrlSetState($g_hTxtWallMinElixir, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkWalls

Func chkSaveWallBldr()
	$g_bUpgradeWallSaveBuilder = (GUICtrlRead($g_hChkSaveWallBldr) = $GUI_CHECKED)
EndFunc   ;==>chkSaveWallBldr

Func chkWallOnly1Builder()
	$g_bChkOnly1Builder = (GUICtrlRead($g_hChkOnly1Builder) = $GUI_CHECKED)
EndFunc   ;==>chkWallOnly1Builder

Func btnWalls()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	UpgradeWall()
EndFunc   ;==>btnWalls

Func chkAutoUpgrade()
	If GUICtrlRead($g_hChkAutoUpgrade) = $GUI_CHECKED Then
		$g_bAutoUpgradeEnabled = True
		For $i = $g_hLblAutoUpgrade To $g_hTxtAutoUpgradeLog
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
		chkRushTH()
	Else
		$g_bAutoUpgradeEnabled = False
		For $i = $g_hLblAutoUpgrade To $g_hTxtAutoUpgradeLog
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
	EndIf
EndFunc   ;==>chkAutoUpgrade

Func chkResourcesToIgnore()
	For $i = 0 To 2
		$g_iChkResourcesToIgnore[$i] = GUICtrlRead($g_hChkResourcesToIgnore[$i]) = $GUI_CHECKED ? 1 : 0
	Next

	Local $iIgnoredResources = 0
	For $i = 0 To 2
		If $g_iChkResourcesToIgnore[$i] = 1 Then $iIgnoredResources += 1
	Next
	Switch $iIgnoredResources
		Case 2
			MsgBox(0 + 16, GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "MsgBox_Warning_Title", "-1"), _
					GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "MsgBox_Warning_Text", "-1"))
		Case 3
			MsgBox(0 + 16, GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "MsgBox_Invalid_Title", "-1"), _
					GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "MsgBox_Invalid_Text", "-1"))
	EndSwitch
EndFunc   ;==>chkResourcesToIgnore

Func chkUpgradesToIgnore()
	For $i = 0 To UBound($g_iChkUpgradesToIgnore) - 1
		$g_iChkUpgradesToIgnore[$i] = GUICtrlRead($g_hChkUpgradesToIgnore[$i]) = $GUI_CHECKED ? 1 : 0
	Next
EndFunc   ;==>chkUpgradesToIgnore

Func chkRushTH()
	;Ignore All Defense, Only Upgrade for Rush
	If GUICtrlRead($g_hChkRushTH) = $GUI_CHECKED Then
		$g_bChkRushTH = True
		For $i = $g_hChkUpgradesToIgnore[5] To $g_hChkUpgradesToIgnore[11]
			GUICtrlSetState($i, $GUI_UNCHECKED)
		Next
		GUICtrlSetState($g_hChkUpgradesToIgnore[7], $GUI_CHECKED) ;ignore wall
		For $i = $g_hChkUpgradesToIgnore[12] To $g_hChkUpgradesToIgnore[14]
			GUICtrlSetState($i, $GUI_CHECKED)
		Next
		For $i = $g_hChkUpgradesToIgnore[15] To $g_hChkUpgradesToIgnore[27]
			GUICtrlSetState($i, $GUI_CHECKED)
		Next
		For $i = $g_hChkUpgradesToIgnore[28] To $g_hChkUpgradesToIgnore[31]
			GUICtrlSetState($i, $GUI_UNCHECKED)
		Next
		For $i = $g_hChkUpgradesToIgnore[33] To $g_hChkUpgradesToIgnore[35]
			GUICtrlSetState($i, $GUI_UNCHECKED)
		Next
	Else
		$g_bChkRushTH = False
	EndIf
	If GUICtrlRead($g_hChkRushTH) = $GUI_CHECKED Then
		For $i = $g_hChkUpgradesToIgnore[5] To $g_hChkUpgradesToIgnore[35]
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
		GUICtrlSetState($g_hChkUpgradesToIgnore[32], $GUI_ENABLE)
	Else
		For $i = $g_hChkUpgradesToIgnore[5] To $g_hChkUpgradesToIgnore[35]
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
	EndIf
EndFunc   ;==>chkRushTH

Func chkUseWallReserveBuilder()
	If GUICtrlRead($g_hUseWallReserveBuilder) = $GUI_CHECKED Then
		$g_bUseWallReserveBuilder = True
	Else
		$g_bUseWallReserveBuilder = False
	EndIf
EndFunc

Func BtnRushTHOption()
	GUISetState(@SW_SHOW, $g_hGUI_RushTHOption)
EndFunc

Func CloseRushTHOption()
	chkEssentialUpgrade()
	GUISetState(@SW_HIDE, $g_hGUI_RushTHOption)
EndFunc

Func chkUpgradePets()
	For $i = 0 to $ePetCount - 1
		If GUICtrlRead($g_hChkUpgradePets[$i]) = $GUI_CHECKED Then
			$g_bUpgradePetsEnable[$i] = True
			SetDebugLog("Upgrade: " & $g_asPetNames[$i] & " enabled")
		Else
			$g_bUpgradePetsEnable[$i] = False
			SetDebugLog("Upgrade: " & $g_asPetNames[$i] & " disabled")
		EndIf
	Next
EndFunc

Func SortPetUpgrade()
	If GUICtrlRead($g_hChkSortPetUpgrade) = $GUI_CHECKED Then
		$g_bChkSortPetUpgrade = True
		GUICtrlSetState($g_hCmbSortPetUpgrade, $GUI_ENABLE)
	Else
		$g_bChkSortPetUpgrade = False
		GUICtrlSetState($g_hCmbSortPetUpgrade, $GUI_DISABLE)
	EndIf
	$g_iCmbSortPetUpgrade = _GUICtrlComboBox_GetCurSel($g_hCmbSortPetUpgrade)
EndFunc

Func chkEssentialUpgrade()
	For $i = 0 To UBound($g_aichkEssentialUpgrade) - 1
		$g_aichkEssentialUpgrade[$i] = GUICtrlRead($g_hchkEssentialUpgrade[$i]) = $GUI_CHECKED ? 1 : 0
	Next
EndFunc   ;==>chkEssentialUpgrade
