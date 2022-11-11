; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Kychera (5-2017)
; Modified ......: NguyenAnhHD [12-2017]
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func CustomDropOrder()
	; prevent user to open a second window impossible to close...
	GUICtrlSetState($g_hBtnCustomDropOrderDB, $GUI_DISABLE)
	GUICtrlSetState($g_hBtnCustomDropOrderAB, $GUI_DISABLE)
	GUISetState(@SW_SHOW, $g_hGUI_DropOrder)
EndFunc   ;==>CustomDropOrder

Func CloseCustomDropOrder()
	; Delete the previous GUI and all controls.
	GUISetState(@SW_HIDE, $g_hGUI_DropOrder)
	GUICtrlSetState($g_hBtnCustomDropOrderDB, $GUI_ENABLE)
	GUICtrlSetState($g_hBtnCustomDropOrderAB, $GUI_ENABLE)
EndFunc   ;==>CloseCustomDropOrder

Func chkDropOrder()
	If GUICtrlRead($g_hChkCustomDropOrderEnable) = $GUI_CHECKED Then
		$g_bCustomDropOrderEnable = True
		GUICtrlSetBkColor($g_hBtnCustomDropOrderDB, $COLOR_GREEN)
		GUICtrlSetBkColor($g_hBtnCustomDropOrderAB, $COLOR_GREEN)
		GUICtrlSetState($g_hBtnDropOrderSet, $GUI_ENABLE)
		GUICtrlSetState($g_hBtnRemoveDropOrder, $GUI_ENABLE)
		For $i = 0 To UBound($g_ahCmbDropOrder) - 1
			GUICtrlSetState($g_ahCmbDropOrder[$i], $GUI_ENABLE)
		Next
		If IsUseCustomDropOrder() = True Then _GUICtrlSetImage($g_ahImgDropOrderSet, $g_sLibIconPath, $eIcnRedLight)
	Else
		$g_bCustomDropOrderEnable = False
		GUICtrlSetBkColor($g_hBtnCustomDropOrderDB, $COLOR_RED)
		GUICtrlSetBkColor($g_hBtnCustomDropOrderAB, $COLOR_RED)
		GUICtrlSetState($g_hBtnDropOrderSet, $GUI_DISABLE) ; disable button
		GUICtrlSetState($g_hBtnRemoveDropOrder, $GUI_DISABLE)
		For $i = 0 To UBound($g_ahCmbDropOrder) - 1
			GUICtrlSetState($g_ahCmbDropOrder[$i], $GUI_DISABLE) ; disable combo boxes
		Next
		SetDefaultDropOrderGroup(False)
	EndIf
EndFunc   ;==>chkDropOrder

Func GUIDropOrder()
	Local $bDuplicate = False
	Local $iGUI_CtrlId = @GUI_CtrlId
	Local $iCtrlIdImage = $iGUI_CtrlId + 1 ; record control ID for $g_ahImgTroopOrder[$z] based on control of combobox that called this function
	Local $iDropIndex = _GUICtrlComboBox_GetCurSel($iGUI_CtrlId) + 1 ; find zero based index number of troop selected in combo box, add one for enum of proper icon

	_GUICtrlSetImage($iCtrlIdImage, $g_sLibIconPath, $g_aiDropOrderIcon[$iDropIndex]) ; set proper troop icon

	For $i = 0 To UBound($g_ahCmbDropOrder) - 1 ; check for duplicate combobox index and flag problem
		If $iGUI_CtrlId = $g_ahCmbDropOrder[$i] Then ContinueLoop
		If _GUICtrlComboBox_GetCurSel($iGUI_CtrlId) = _GUICtrlComboBox_GetCurSel($g_ahCmbDropOrder[$i]) Then
			_GUICtrlSetImage($g_ahImgDropOrder[$i], $g_sLibIconPath, $eIcnOptions)
			_GUICtrlComboBox_SetCurSel($g_ahCmbDropOrder[$i], -1)
			GUISetState()
			$bDuplicate = True
		EndIf
	Next
	If $bDuplicate Then
		GUICtrlSetState($g_hBtnDropOrderSet, $GUI_ENABLE) ; enable button to apply new order
		Return
	Else
		GUICtrlSetState($g_hBtnDropOrderSet, $GUI_ENABLE) ; enable button to apply new order
		_GUICtrlSetImage($g_ahImgDropOrderSet, $g_sLibIconPath, $eIcnRedLight) ; set status indicator to show need to apply new order
	EndIf
EndFunc   ;==>GUIDropOrder

Func BtnRemoveDropOrder()
	Local $sComboData = ""
	For $j = 0 To UBound($g_asDropOrderList) - 1
		$sComboData &= $g_asDropOrderList[$j] & "|"
	Next
	For $i = 0 To Ubound($g_ahCmbDropOrder) - 1
		$g_aiCmbCustomDropOrder[$i] = -1
		_GUICtrlComboBox_ResetContent($g_aiCmbCustomDropOrder[$i])
		GUICtrlSetData($g_ahCmbDropOrder[$i], $sComboData, "")
		_GUICtrlSetImage($g_ahImgDropOrder[$i], $g_sLibIconPath, $eIcnOptions)
	Next
	_GUICtrlSetImage($g_ahImgDropOrderSet, $g_sLibIconPath, $eIcnSilverStar)
	SetDefaultDropOrderGroup(False)
EndFunc   ;==>BtnRemoveDropOrder

Func BtnDropOrderSet()
	Local $bReady = True ; Initialize ready to record troop order flag
	Local $sNewDropList = ""

	Local $bMissingDrop = False ; flag for when troops are not assigned by user
	Local $aiDropOrder = $g_aiDropOrder
	Local $aTmpDropOrder[0], $iStartShuffle = 0
	
	For $i = 0 To UBound($g_ahCmbDropOrder) - 1
		Local $iValue = _GUICtrlComboBox_GetCurSel($g_ahCmbDropOrder[$i])
		If $iValue <> -1 Then
			_ArrayAdd($aTmpDropOrder, $iValue)
			Local $iEmpty = _ArraySearch($aiDropOrder, $iValue)
			If $iEmpty > -1 Then $aiDropOrder[$iEmpty] = -1
		EndIf
	Next
	
	$iStartShuffle = Ubound($aTmpDropOrder)
	
	_ArraySort($aiDropOrder)
	;_ArrayDisplay($aiUsedTroop, "aiUsedTroop")
	
	For $i = 0 To UBound($aTmpDropOrder) - 1
		If $aiDropOrder[$i] = -1 Then $aiDropOrder[$i] = $aTmpDropOrder[$i]
	Next
	
	_ArrayShuffle($aiDropOrder, $iStartShuffle)
	For $i = 0 To UBound($g_ahCmbDropOrder) - 1
		_GUICtrlComboBox_SetCurSel($g_ahCmbDropOrder[$i], $aiDropOrder[$i])
		_GUICtrlSetImage($g_ahImgDropOrder[$i], $g_sLibIconPath, $g_aiDropOrderIcon[$aiDropOrder[$i] + 1])
	Next
	$g_aiCmbCustomDropOrder = $aiDropOrder
	
	If $bReady Then
		ChangeDropOrder() ; code function to record new training order

		If @error Then
			Switch @error
				Case 1
					SetLog("Code problem, can not continue till fixed!", $COLOR_ERROR)
				Case 2
					SetLog("Bad Combobox selections, please fix!", $COLOR_ERROR)
				Case 3
					SetLog("Unable to Change Troop Drop Order due bad change count!", $COLOR_ERROR)
				Case Else
					SetLog("Monkey ate bad banana, something wrong with ChangeTroopDropOrder() code!", $COLOR_ERROR)
			EndSwitch
			_GUICtrlSetImage($g_ahImgDropOrderSet, $g_sLibIconPath, $eIcnRedLight)
		Else
			SetLog("Troop droping order changed successfully!", $COLOR_SUCCESS)
			For $i = 0 To $eDropOrderCount - 1
				$sNewDropList &= $g_asDropOrderNames[$g_aiCmbCustomDropOrder[$i]] & ", "
			Next
			$sNewDropList = StringTrimRight($sNewDropList, 2)
			SetLog("Troops Dropping Order= " & $sNewDropList, $COLOR_INFO)

		EndIf
	Else
		SetLog("Must use all troops and No duplicate troop names!", $COLOR_ERROR)
		_GUICtrlSetImage($g_ahImgDropOrderSet, $g_sLibIconPath, $eIcnRedLight)
	EndIf
EndFunc   ;==>BtnDropOrderSet

Func IsUseCustomDropOrder()
	For $i = 0 To UBound($g_ahCmbDropOrder) - 1 ; Check if custom train order has been used, to select log message
		If _GUICtrlComboBox_GetCurSel($g_ahCmbDropOrder[$i]) = -1 Then
			Return False
		EndIf
	Next
	Return True
EndFunc   ;==>IsUseCustomDropOrder

Func ChangeDropOrder()
	SetDebugLog("Begin Func ChangeDropOrder()", $COLOR_DEBUG) ;Debug
	Local $iUpdateCount = 0, $aUnique

	If Not IsUseCustomDropOrder() Then ; check if no custom troop values saved yet.
		SetError(2, 0, False)
		Return
	EndIf
	
	$aUnique = _ArrayUnique($g_aiCmbCustomDropOrder, 0, 0, 0, 0)
	$iUpdateCount = UBound($aUnique)
	
	If $iUpdateCount = $eDropOrderCount Then ; safety check that all troops properly assigned to new array.
		$g_aiDropOrder = $aUnique
		For $i = 0 To $eDropOrderCount - 1
			$g_aiCmbCustomDropOrder[$i] = $g_aiDropOrder[$i]
		Next
		_GUICtrlSetImage($g_ahImgDropOrderSet, $g_sLibIconPath, $eIcnGreenLight)
	Else
		SetLog($iUpdateCount & "|" & $eDropOrderCount & " - Error - Bad troop assignment in ChangeTroopTrainOrder()", $COLOR_ERROR)
		SetError(3, 0, False)
		Return
	EndIf
	Return True
EndFunc   ;==>ChangeDropOrder

Func SetDefaultDropOrderGroup($bSetLog = True)
	For $i = 0 To $eDropOrderCount - 1
		$g_aiDropOrder[$i] = $i
	Next
	If $bSetLog And $g_bCustomDropOrderEnable Then SetLog("Default drop order set", $COLOR_SUCCESS)
EndFunc   ;==>SetDefaultDropOrderGroup
