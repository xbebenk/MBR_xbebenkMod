; #FUNCTION# ====================================================================================================================
; Name ..........: ZoomOut
; Description ...: Tries to zoom out of the screen until the borders, located at the top of the game (usually black), is located.
; Syntax ........: ZoomOut()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......: KnowJack (07-2015), CodeSlinger69 (01-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func ZoomOut($bZoomOutFirst = False) ;Zooms out
	Local $bRet
	If Not $g_bRunState Then Return
	If $bZoomOutFirst Then AndroidZoomOut()
	$bRet = _ZoomOut()
	
	Return $bRet
EndFunc   ;==>ZoomOut

Func _ZoomOut() ;Zooms out
	
	If Not checkChatTabPixel() Then checkMainScreen()
    ResumeAndroid()
    WinGetAndroidHandle()
	getBSPos() ; Update $g_hAndroidWindow and Android Window Positions
	If Not $g_bRunState Then Return
	
	Local $Result
	If ($g_iAndroidZoomoutMode = 0 Or $g_iAndroidZoomoutMode = 3) And ($g_bAndroidEmbedded = False Or $g_iAndroidEmbedMode = 1) Then
		; default zoomout
		$Result = Execute("ZoomOut" & $g_sAndroidEmulator & "()")
		If $Result = "" And @error <> 0 Then
			; Not implemented or other error
			$Result = AndroidOnlyZoomOut()
		EndIf
		$g_bSkipFirstZoomout = True
		Return $Result
	EndIf

	; Android embedded, only use Android zoomout
	$Result = AndroidOnlyZoomOut()
	$g_bSkipFirstZoomout = True
	Return $Result
EndFunc   ;==>_ZoomOut

Func ZoomOutBlueStacks() ;Zooms out
	SetDebugLog("ZoomOutBlueStacks()")
	; ctrl click is best and most stable for BlueStacks
	Return ZoomOutCtrlClick(False, False, False, 250)
   ;Return DefaultZoomOut("{DOWN}", 0)
   ; ZoomOutCtrlClick doesn't cause moving buildings, but uses global Ctrl-Key and has taking focus problems
   ;Return ZoomOutCtrlClick(False, False, False)
EndFunc

Func ZoomOutBlueStacks2()
	SetDebugLog("ZoomOutBlueStacks2()")
	If $__BlueStacks2Version_2_5_or_later = False Then
		; ctrl click is best and most stable for BlueStacks, but not working after 2.5.55.6279 version
		Return ZoomOutCtrlClick(False, False, False, 250)
	Else
		; newer BlueStacks versions don't work with Ctrl-Click, so fall back to original arrow key
		Return DefaultZoomOut("{DOWN}", 0, ($g_iAndroidZoomoutMode <> 3))
	EndIf
   ;Return DefaultZoomOut("{DOWN}", 0)
   ; ZoomOutCtrlClick doesn't cause moving buildings, but uses global Ctrl-Key and has taking focus problems
   ;Return ZoomOutCtrlClick(False, False, False)
EndFunc

Func ZoomOutBlueStacks5()
	SetDebugLog("ZoomOutBlueStacks5()")
	; newer BlueStacks versions don't work with Ctrl-Click, so fall back to original arrow key
	Return DefaultZoomOut("{DOWN}", 0, ($g_iAndroidZoomoutMode <> 3))
EndFunc

Func ZoomOutMEmu()
	SetDebugLog("ZoomOutMEmu()")
	Return DefaultZoomOut("{F3}", 0, ($g_iAndroidZoomoutMode <> 3))
EndFunc

Func ZoomOutNox()
	SetDebugLog("ZoomOutNox()")
	Return ZoomOutCtrlWheelScroll(True, True, True, ($g_iAndroidZoomoutMode <> 3), Default, -5, 250)
	;Return DefaultZoomOut("{CTRLDOWN}{DOWN}{CTRLUP}", 0)
EndFunc

Func ZoomOutHelper($caller = "Default")
	Local $x = 0, $y = 0
	Local $bIsMain = False
	Local $Dir = "", $aOffset, $bRet = False
	If Not $g_bRunState Then Return
	
	If $caller = "VillageSearch" Then 
		$bIsMain = True
	Else
		$bIsMain = isOnMainVillage()
	EndIf
	
	If Not $bIsMain Then Return ;leave if not in mainvillage
	
	;$g_bDebugClick = True
	If _Sleep(50) Then Return
	If QuickMIS("BC1", $g_sImgZoomOutDir & "tree\", 430, 20, 750, 200) Then 
		$aOffset = StringRegExp($g_iQuickMISName, "tree([0-9A-Z]+)-(\d+)-(\d+)", $STR_REGEXPARRAYMATCH)
		If IsArray($aOffset) Then 
			$x = $g_iQuickMISX - $aOffset[1]
			$y = $g_iQuickMISY - $aOffset[2]
			If $caller = "CollectLootCart" Then 
				$x -= 20
				$y += 20
			EndIf
			If $g_bDebugClick Then SetLog("[" & $caller & "] ZoomOutHelper: Found " & $g_iQuickMISName & " on [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_DEBUG2)
			If $g_bDebugClick Then SetLog("Centering village by " & $x & "," & $y, $COLOR_DEBUG2)
			ClickAway()
			ClickDrag(800, 350, 800 - $x, 350 - $y)
			$bRet = True
		Else
			If $g_bDebugClick Then SetLog("[" & $caller & "] Bad Tree ImageName!")
		EndIf
	EndIf
	
	If _Sleep(50) Then Return
	If Not $bRet Then
		If QuickMIS("BC1", $g_sImgZoomOutDir & "stone\", 60, 330, 430, 560) Then 
			$aOffset = StringRegExp($g_iQuickMISName, "stone([0-9A-Z]+)-(\d+)-(\d+)", $STR_REGEXPARRAYMATCH)
			If IsArray($aOffset) Then 
				$x = $g_iQuickMISX - $aOffset[1]
				$y = $g_iQuickMISY - $aOffset[2]
				If $g_bDebugClick Then SetLog("[" & $caller & "] ZoomOutHelper: Found " & $g_iQuickMISName & " on [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_DEBUG2)
				If $g_bDebugClick Then SetLog("Centering village by " & $x & "," & $y, $COLOR_DEBUG2)
				ClickAway()
				ClickDrag(800, 350, 800 - $x, 350 - $y)
				$bRet = True
			Else
				If $g_bDebugClick Then SetLog("[" & $caller & "] Bad Stone ImageName!")
			EndIf
		EndIf
	EndIf
	
	If _Sleep(50) Then Return
	If Not $bRet Then
		If QuickMIS("BC1", $g_sImgZoomOutHelper, 320, 100, 500, 250) Then 
			$aOffset = StringRegExp($g_iQuickMISName, "CGHelper-(\d+)-(\d+)", $STR_REGEXPARRAYMATCH)
			If IsArray($aOffset) Then 
				$x = $g_iQuickMISX - $aOffset[0]
				$y = $g_iQuickMISY - $aOffset[1]
				If $g_bDebugClick Then SetLog("[" & $caller & "] ZoomOutHelper: Found " & $g_iQuickMISName & " on [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_DEBUG2)
				If $g_bDebugClick Then SetLog("Centering village by " & $x & "," & $y, $COLOR_DEBUG2)
				ClickAway()
				ClickDrag(800, 350, 800 - $x, 350 - $y)
				$bRet = True
			Else
				If $g_bDebugClick Then SetLog("[" & $caller & "] Bad CGHelper ImageName!")
			EndIf
		EndIf
	EndIf
	
	If _Sleep(50) Then Return
	If Not $bRet Then
		ClickDrag(800, 350, 800, 400) ;just drag
	EndIf
	
	;$g_bDebugClick = False
	Return $bRet
EndFunc

Func ZoomOutHelperBB($caller = "Default")
	Local $x = 0, $y = 0, $sImage = ""
	Local $bIsOnBuilderBase = isOnBuilderBase()
	Local $Dir = "", $aOffset, $bRet = False
	Local $xyOffsetSwitchBases = 0
	If $caller = "SwitchBetweenBases" Then $xyOffsetSwitchBases = -60
	
	If Not $bIsOnBuilderBase Then Return ;leave if not in mainvillage
	;$g_bDebugClick = True
	
	If _Sleep(50) Then Return
	If QuickMIS("BC1", $g_sImgZoomOutDirBB & "ZoomOutHelper\", 100, 20, 800, 676) Then 
		$aOffset = StringRegExp($g_iQuickMISName, "Tree([0-9A-Z]+)-(\d+)-(\d+)", $STR_REGEXPARRAYMATCH)
		If IsArray($aOffset) Then 
			$x = $g_iQuickMISX - $aOffset[1]
			$y = $g_iQuickMISY - $aOffset[2]
			$sImage = $aOffset[0]
			
			If $sImage = "BH" Then 
				If QuickMIS("BC1", $g_sImgBB20 & "UpTunnel\", 300, 400, 660, 676) Then
					SetLog("Detected on BuilderBase HighZone, switch to LowerZone", $COLOR_DEBUG2)
					Click($g_iQuickMISX, $g_iQuickMISY)
					If _Sleep(3000) Then Return
					;$g_bDebugClick = False
					Return True
				EndIf
			EndIf
			If $sImage = "BL" Then $g_sSceneryCode = "BL"
			If $g_bDebugClick Then SetLog("[" & $caller & "] ZoomOutHelperBB: Found " & $g_iQuickMISName & " on [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_DEBUG2)
			If $g_bDebugClick Then SetLog("ZoomOutHelperBB: Centering village by " & $x & "," & $y, $COLOR_DEBUG2)
			ClickDrag(730, 250, 730 - $x + $xyOffsetSwitchBases, 250 - $y - $xyOffsetSwitchBases, 50, True) ; more delay for clickdrag here
			$bRet = True
		Else
			If $g_bDebugClick Then SetLog("[" & $caller & "] Bad TreeBL ImageName!")
		EndIf
	EndIf
	
	If _Sleep(50) Then Return
	If Not $bRet Then
		If QuickMIS("BC1", $g_sImgZoomOutDirBB & "stone\", 0, 330, 430, 560) Then 
			$aOffset = StringRegExp($g_iQuickMISName, "stone([0-9A-Z]+)-(\d+)-(\d+)", $STR_REGEXPARRAYMATCH)
			If IsArray($aOffset) Then 
				$x = $g_iQuickMISX - $aOffset[1]
				$y = $g_iQuickMISY - $aOffset[2]
				If $g_bDebugClick Then SetLog("[" & $caller & "] ZoomOutHelperBB: Found " & $g_iQuickMISName & " on [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_DEBUG2)
				If $g_bDebugClick Then SetLog("ZoomOutHelperBB: Centering village by " & $x & "," & $y, $COLOR_DEBUG2)
				ClickDrag(730, 250, 730 - $x + $xyOffsetSwitchBases, 250 - $y - $xyOffsetSwitchBases)
				$bRet = True
			Else
				If $g_bDebugClick Then SetLog("[" & $caller & "] Bad Stone ImageName!")
			EndIf
		EndIf
	EndIf
	;$g_bDebugClick = False
	Return $bRet
EndFunc

Func DefaultZoomOut($ZoomOutKey = "{DOWN}", $tryCtrlWheelScrollAfterCycles = 40, $bAndroidZoomOut = True) ;Zooms out
	
	Local $sFunc = "DefaultZoomOut"
	Local $result0, $result1, $i = 0
	Local $exitCount = 80
	Local $delayCount = 20
	Local $aPicture = ["", 0, 0, 0, 0]
	If Not $g_bRunState Then Return
	
	If _Sleep(50) Then Return
	ForceCaptureRegion()
	$aPicture = SearchZoomOut(True, True, $sFunc, True)
	
	If $aPicture[0] = "" And $aPicture[1] = "0" Then 
		AndroidZoomOut()
		SetLog("ZoomOut() : " & $sFunc, $COLOR_DEBUG2)
		If ZoomOutHelper($sFunc) Then Return True
		If ZoomOutHelperBB($sFunc) Then Return True
		$aPicture = SearchZoomOut(True, True, $sFunc, True)
	EndIf
	
	If _Sleep(50) Then Return
	If Not $g_bRunState Then Return $aPicture
	
	If StringInStr($aPicture[0], "zoomou") = 0 Then
		If $g_bDebugSetlog Then
			SetDebugLog("Zooming Out (" & $sFunc & ")", $COLOR_INFO)
		Else
			SetLog("Zooming Out", $COLOR_INFO)
		EndIf
		If _Sleep($DELAYZOOMOUT1) Then Return True
		If $bAndroidZoomOut Then
			AndroidZoomOut(0, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
			ForceCaptureRegion()
			$aPicture = SearchZoomOut(True, True, $sFunc, True)
		EndIf
	    Local $tryCtrlWheelScroll = False
		
		If IsArray($aPicture) Then
			While IsArray($aPicture) And StringInStr($aPicture[0], "zoomout") = 0 and Not $tryCtrlWheelScroll
				AndroidShield("DefaultZoomOut") ; Update shield status
				If $bAndroidZoomOut Then
				   AndroidZoomOut($i, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
				   If @error <> 0 Then $bAndroidZoomOut = False
				EndIf
				
				If _Sleep(50) Then Return
				If Not $bAndroidZoomOut Then
				   ; original windows based zoom-out
				   SetDebugLog("Index = "&$i, $COLOR_DEBUG) ; Index=2X loop count if success, will be increment by 1 if controlsend fail
				   If _Sleep($DELAYZOOMOUT2) Then Return True
				   If $g_bChkBackgroundMode = False And $g_bNoFocusTampering = False Then
					  $Result0 = ControlFocus($g_hAndroidWindow, "", "")
				   Else
					  $Result0 = 1
				   EndIf
				   $Result1 = ControlSend($g_hAndroidWindow, "", "", $ZoomOutKey)
				   SetDebugLog("ControlFocus Result = "&$Result0 & ", ControlSend Result = "&$Result1& "|" & "@error= " & @error, $COLOR_DEBUG)
				   If $Result1 = 1 Then
					   $i += 1
				   Else
					   SetLog("Warning ControlSend $Result = "&$Result1, $COLOR_DEBUG)
				   EndIf
				EndIF

				If $i > $delayCount Then
					If _Sleep($DELAYZOOMOUT3) Then Return True
				EndIf
				If $tryCtrlWheelScrollAfterCycles > 0 And $i > $tryCtrlWheelScrollAfterCycles Then $tryCtrlWheelScroll = True
				If $i > $exitCount Then Return
				If Not $g_bRunState Then Return $aPicture
				If IsProblemAffect() Then  ; added to catch errors during Zoomout
					SetLog($g_sAndroidEmulator & " Error window detected", $COLOR_ERROR)
					If checkObstacles() = True Then SetLog("Error window cleared, continue Zoom out", $COLOR_INFO)  ; call to clear normal errors
				EndIf
				$i += 1  ; add one to index value to prevent endless loop if controlsend fails
				ForceCaptureRegion()
				$aPicture = SearchZoomOut(True, True, $sFunc, True)
				If IsArray($aPicture) And $aPicture[0] = "" And $aPicture[1] = "0" Then 
					ZoomOutHelper($sFunc)
					$aPicture = SearchZoomOut(True, True, $sFunc, True)
				EndIf
				If Not $g_bRunState Then Return $aPicture
			WEnd
		EndIf
			
		If $tryCtrlWheelScroll Then
		    SetLog($g_sAndroidEmulator & " zoom-out with key " & $ZoomOutKey & " didn't work, try now Ctrl+MouseWheel...", $COLOR_INFO)
			Return ZoomOutCtrlWheelScroll(False, False, False, False)
	    EndIf
		Return True
	EndIf
	Return False
EndFunc   ;==>ZoomOut

;Func ZoomOutCtrlWheelScroll($CenterMouseWhileZooming = True, $GlobalMouseWheel = True, $AlwaysControlFocus = False, $AndroidZoomOut = True, $WheelRotation = -5, $WheelRotationCount = 1)
Func ZoomOutCtrlWheelScroll($CenterMouseWhileZooming = True, $GlobalMouseWheel = True, $AlwaysControlFocus = False, $AndroidZoomOut = True, $hWin = Default, $ScrollSteps = -5, $ClickDelay = 250)
	Local $sFunc = "ZoomOutCtrlWheelScroll"
    Local $exitCount = 80
	Local $delayCount = 20
	Local $result[4], $i = 0, $j
	Local $ZoomActions[4] = ["ControlFocus", "Ctrl Down", "Mouse Wheel Scroll Down", "Ctrl Up"]
	Local $aPicture = ["", 0, 0, 0, 0]
	If $hWin = Default Then $hWin = ($g_bAndroidEmbedded = False ? $g_hAndroidWindow : $g_aiAndroidEmbeddedCtrlTarget[1])
	ForceCaptureRegion()
	
	$aPicture = SearchZoomOut(True, True, $sFunc, True)
	
	If $aPicture[0] = "" And $aPicture[1] = "0" Then 
		AndroidZoomOut()
		SetLog("ZoomOut() : " & $sFunc, $COLOR_DEBUG2)
		If ZoomOutHelper($sFunc) Then Return True
		If ZoomOutHelperBB($sFunc) Then Return True
		$aPicture = SearchZoomOut(True, True, $sFunc, True)
	EndIf

	If StringInStr($aPicture[0], "zoomou") = 0 Then

		If $g_bDebugSetlog Then
			SetDebugLog("Zooming Out (" & $sFunc & ")", $COLOR_INFO)
		Else
			SetLog("Zooming Out ", $COLOR_INFO)
		EndIf

		AndroidShield("ZoomOutCtrlWheelScroll") ; Update shield status
		If _Sleep($DELAYZOOMOUT1) Then Return True
		If $AndroidZoomOut Then
			AndroidZoomOut(0, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
			ForceCaptureRegion()
			$aPicture = SearchZoomOut(True, True, $sFunc, True)
		EndIf
		Local $aMousePos = MouseGetPos()

		While StringInStr($aPicture[0], "zoomou") = 0

			If $AndroidZoomOut Then
			   AndroidZoomOut($i, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
			   If @error <> 0 Then $AndroidZoomOut = False
			EndIf
			If Not $AndroidZoomOut Then
			   ; original windows based zoom-out
			   SetDebugLog("Index = " & $i, $COLOR_DEBUG) ; Index=2X loop count if success, will be increment by 1 if controlsend fail
			   If _Sleep($DELAYZOOMOUT2) Then ExitLoop
			   If ($g_bChkBackgroundMode = False And $g_bNoFocusTampering = False) Or $AlwaysControlFocus Then
				  $Result[0] = ControlFocus($hWin, "", "")
			   Else
				  $Result[0] = 1
			   EndIf

			   $Result[1] = ControlSend($hWin, "", "", "{CTRLDOWN}")
			   If $CenterMouseWhileZooming Then MouseMove($g_aiBSpos[0] + Int($g_iDEFAULT_WIDTH / 2), $g_aiBSpos[1] + Int($g_iDEFAULT_HEIGHT / 2), 0)
			   If $GlobalMouseWheel Then
                  $Result[2] = MouseWheel(($ScrollSteps < 0 ? "down" : "up"), Abs($ScrollSteps)) ; can't find $MOUSE_WHEEL_DOWN constant, couldn't include AutoItConstants.au3 either
			   Else
				  Local $WM_WHEELMOUSE = 0x020A, $MK_CONTROL = 0x0008
				  ;Local $wParam = BitOR(BitShift($WheelRotation, -16), BitAND($MK_CONTROL, 0xFFFF)) ; HiWord = -120 WheelScrollDown, LoWord = $MK_CONTROL
				  Local $wParam = BitOR($ScrollSteps * 0x10000, BitAND($MK_CONTROL, 0xFFFF)) ; HiWord = -120 WheelScrollDown, LoWord = $MK_CONTROL
				  Local $lParam =  BitOR(($g_aiBSpos[1] + Int($g_iDEFAULT_HEIGHT / 2)) * 0x10000, BitAND(($g_aiBSpos[0] + Int($g_iDEFAULT_WIDTH / 2)), 0xFFFF)) ; ; HiWord = y-coordinate, LoWord = x-coordinate
				  ;For $k = 1 To $WheelRotationCount
					 _WinAPI_PostMessage($hWin, $WM_WHEELMOUSE, $wParam, $lParam)
				  ;Next
				  $Result[2] = (@error = 0 ? 1 : 0)
			   EndIf
			   If _Sleep($ClickDelay) Then ExitLoop
			   $Result[3] = ControlSend($hWin, "", "", "{CTRLUP}{SPACE}")

			   SetDebugLog("ControlFocus Result = " & $Result[0] & _
					  ", " & $ZoomActions[1] & " = " & $Result[1] & _
					  ", " & $ZoomActions[2] & " = " & $Result[2] & _
					  ", " & $ZoomActions[3] & " = " & $Result[3] & _
					  " | " & "@error= " & @error, $COLOR_DEBUG)
			   For $j = 1 To 3
				  If $Result[$j] = 1 Then
					  $i += 1
					  ExitLoop
				  EndIf
			   Next
			   For $j = 1 To 3
				  If $Result[$j] = 0 Then
					  SetLog("Warning " & $ZoomActions[$j] & " = " & $Result[1], $COLOR_DEBUG)
				  EndIf
			   Next
			EndIf

			If $i > $delayCount Then
				If _Sleep($DELAYZOOMOUT3) Then ExitLoop
			EndIf
			If $i > $exitCount Then ExitLoop
			If Not $g_bRunState Then Return $aPicture
			If IsProblemAffect() Then  ; added to catch errors during Zoomout
				SetLog($g_sAndroidEmulator & " Error window detected", $COLOR_ERROR)
				If checkObstacles() = True Then SetLog("Error window cleared, continue Zoom out", $COLOR_INFO)  ; call to clear normal errors
			EndIf
			$i += 1  ; add one to index value to prevent endless loop if controlsend fails
			ForceCaptureRegion()
			$aPicture = SearchZoomOut(True, True, $sFunc, True)
			If $aPicture[0] = "" And $aPicture[1] = "0" Then 
				ZoomOutHelper("DefaultZoomOut")
				$aPicture = SearchZoomOut(True, True, $sFunc, True)
			EndIf
			If Not $g_bRunState Then Return $aPicture
		WEnd

		 If $CenterMouseWhileZooming And $AndroidZoomOut = False Then MouseMove($aMousePos[0], $aMousePos[1], 0)
		Return True

	EndIf
	Return False
 EndFunc

Func ZoomOutCtrlClick($CenterMouseWhileZooming = False, $AlwaysControlFocus = False, $AndroidZoomOut = True, $ClickDelay = 250)
	SetDebugLog("ZoomOutCtrlClick()")
	Local $sFunc = "ZoomOutCtrlClick"
   ;AutoItSetOption ( "SendKeyDownDelay", 3000)
	Local $exitCount = 80
	Local $delayCount = 20
	Local $result[4], $i, $j
	Local $SendCtrlUp = False
	Local $ZoomActions[4] = ["ControlFocus", "Ctrl Down", "Click", "Ctrl Up"]
	ForceCaptureRegion()
	Local $aPicture = SearchZoomOut(True, True, $sFunc, True)

	If StringInStr($aPicture[0], "zoomou") = 0 Then

		If $g_bDebugSetlog Then
			SetDebugLog("Zooming Out (" & $sFunc & ")", $COLOR_INFO)
		Else
			SetLog("Zooming Out", $COLOR_INFO)
		EndIf

		AndroidShield("ZoomOutCtrlClick") ; Update shield status

		If _Sleep($DELAYZOOMOUT1) Then Return True
		Local $aMousePos = MouseGetPos()

		$i = 0
		While StringInStr($aPicture[0], "zoomou") = 0

			If $AndroidZoomOut Then
			   AndroidZoomOut($i, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
			   If @error <> 0 Then $AndroidZoomOut = False
			EndIf
			If Not $AndroidZoomOut Then
			   ; original windows based zoom-out
			   SetDebugLog("Index = " & $i, $COLOR_DEBUG) ; Index=2X loop count if success, will be increment by 1 if controlsend fail
			   If _Sleep($DELAYZOOMOUT2) Then ExitLoop
			   If ($g_bChkBackgroundMode = False And $g_bNoFocusTampering = False) Or $AlwaysControlFocus Then
				  $Result[0] = ControlFocus($g_hAndroidWindow, "", "")
			   Else
				  $Result[0] = 1
			   EndIf

			   $Result[1] = ControlSend($g_hAndroidWindow, "", "", "{CTRLDOWN}")
			   $SendCtrlUp = True
			   If $CenterMouseWhileZooming Then MouseMove($g_aiBSpos[0] + Int($g_iDEFAULT_WIDTH / 2), $g_aiBSpos[1] + Int($g_iDEFAULT_HEIGHT / 2), 0)
			   $Result[2] = _ControlClick(Int($g_iDEFAULT_WIDTH / 2), 600)
			   If _Sleep($ClickDelay) Then ExitLoop
			   $Result[3] = ControlSend($g_hAndroidWindow, "", "", "{CTRLUP}{SPACE}")
			   $SendCtrlUp = False

			   SetDebugLog("ControlFocus Result = " & $Result[0] & _
					  ", " & $ZoomActions[1] & " = " & $Result[1] & _
					  ", " & $ZoomActions[2] & " = " & $Result[2] & _
					  ", " & $ZoomActions[3] & " = " & $Result[3] & _
					  " | " & "@error= " & @error, $COLOR_DEBUG)
			   For $j = 1 To 3
				  If $Result[$j] = 1 Then
					  ExitLoop
				  EndIf
			   Next
			   For $j = 1 To 3
				  If $Result[$j] = 0 Then
					  SetLog("Warning " & $ZoomActions[$j] & " = " & $Result[1], $COLOR_DEBUG)
				  EndIf
			   Next
			EndIf

			If $i > $delayCount Then
				If _Sleep($DELAYZOOMOUT3) Then ExitLoop
			EndIf
			If $i > $exitCount Then ExitLoop
			If $g_bRunState = False Then ExitLoop
			If IsProblemAffect() Then  ; added to catch errors during Zoomout
				SetLog($g_sAndroidEmulator & " Error window detected", $COLOR_RED)
				If checkObstacles() = True Then SetLog("Error window cleared, continue Zoom out", $COLOR_BLUE)  ; call to clear normal errors
			EndIf
			$i += 1  ; add one to index value to prevent endless loop if controlsend fails
			ForceCaptureRegion()
			$aPicture = SearchZoomOut(True, True, $sFunc, True)
		 WEnd

		 If $SendCtrlUp Then ControlSend($g_hAndroidWindow, "", "", "{CTRLUP}{SPACE}")

		 If $CenterMouseWhileZooming Then MouseMove($aMousePos[0], $aMousePos[1], 0)

		Return True
	EndIf
	Return False
 EndFunc

Func AndroidOnlyZoomOut() ;Zooms out
	SetDebugLog("AnroidOnlyZoomOut()")
	Local $sFunc = "AndroidOnlyZoomOut"
	Local $i = 0
	Local $exitCount = 80
	ForceCaptureRegion()
	Local $aPicture = SearchZoomOut(True, True, $sFunc, True)

	If StringInStr($aPicture[0], "zoomout") = 0 Then

		If $g_bDebugSetlog Then
			SetDebugLog("Zooming Out (" & $sFunc & ")", $COLOR_INFO)
		Else
			SetLog("Zooming Out", $COLOR_INFO)
		EndIf
		AndroidZoomOut(0, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
		ForceCaptureRegion()
		$aPicture = SearchZoomOut(True, True, $sFunc, True)
		If IsArray($aPicture) Then
			While StringInStr($aPicture[0], "zoomout") = 0
				AndroidShield("AndroidOnlyZoomOut") ; Update shield status
				AndroidZoomOut($i, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
				If $i > $exitCount Then Return
				If Not $g_bRunState Then ExitLoop
				If IsProblemAffect() Then  ; added to catch errors during Zoomout
					SetLog($g_sAndroidEmulator & " Error window detected", $COLOR_ERROR)
					If checkObstacles() Then SetLog("Error window cleared, continue Zoom out", $COLOR_INFO)  ; call to clear normal errors
				EndIf
				$i += 1  ; add one to index value to prevent endless loop if controlsend fails
				ForceCaptureRegion()
				$aPicture = SearchZoomOut(True, True, "", True)
			WEnd
			Return True
		Else 
			Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>AndroidOnlyZoomOut

; SearchZoomOut Returns always an Array.
; If village can be measured and villages size < 500 pixel then it Returns in idx 0 a String starting with "zoomout:" and tries to center base
; Return Array:
; 0 = Empty string if village cannot be measured (e.g. window blocks village or not zoomed out)
; 1 = Current Village X Offset (after centering village)
; 2 = Current Village Y Offset (after centering village)
; 3 = Difference of previous Village X Offset and current (after centering village)
; 4 = Difference of previous Village Y Offset and current (after centering village)
;SearchZoomOut(True, True, "", True)
Func SearchZoomOut($bCenterVillage = True, $UpdateMyVillage = True, $sSource = "Default", $CaptureRegion = True, $DebugLog = $g_bDebugSetlog)
	FuncEnter(SearchZoomOut)
	
	; Setup arrays, including default Return values for $Return
	Local $aVillage, $aScrollPos, $iVillageSize = 0
	Local $x, $y, $z, $stone[2]
	Local $bOnBuilderBase = False
	
	If $CaptureRegion Then _CaptureRegion2()
	$bOnBuilderBase = isOnBuilderBase()
	$aScrollPos = getVillageCenteringCoord()

	Local $aResult[5] = ["", 0, 0, 0, 0] ; expected dummy value
	Local $aResult2[4] = [0, 0, 0, 0]
	If Not $g_bRunState Then Return FuncReturn($aResult)
	
	$aVillage = GetVillageSize($DebugLog, "stone", "tree", $bOnBuilderBase)
	If IsArray($aVillage) = 1 Then
		$iVillageSize = $aVillage[0]
		If $iVillageSize < 750 Then
			$z = $aVillage[1]
			$x = $aVillage[2]
			$y = $aVillage[3]
			$stone[0] = $aVillage[4]
			$stone[1] = $aVillage[5]
			$aResult[0] = "zoomout:" & $aVillage[6]
			$aResult[1] = $x
			$aResult[2] = $y
			
			SetDebugLog("SearchZoomOut CenteringVillage = " & String($bCenterVillage), $COLOR_DEBUG1)
			
			If $bCenterVillage And (Abs($x) > 10 Or Abs($y) > 10) Then ;And ($UpdateMyVillage = False Or $x <> $g_iVILLAGE_OFFSET[0] Or $y <> $g_iVILLAGE_OFFSET[1]) Then
				SetLog("[" & $sSource & "] Centering Village by: x=" & $x & ", y=" & $y, $COLOR_DEBUG1)
				
				ClickAway()
				ClickDrag($aScrollPos[0], $aScrollPos[1], $aScrollPos[0] - $x, $aScrollPos[1] - $y)
				If _Sleep(250) Then Return FuncReturn($aResult)
				
				
				$aResult2 = SearchZoomOut(False, $UpdateMyVillage, "SearchZoomOut(1):" & $sSource, True, $DebugLog)
				; update difference in offset
				$aResult2[3] = $aResult2[1] - $aResult[1]
				$aResult2[4] = $aResult2[2] - $aResult[2]
				SetDebugLog("Centered Village Offset" & $sSource & ": " & $aResult2[1] & ", " & $aResult2[2] & ", change: " & $aResult2[3] & ", " & $aResult2[4], $COLOR_DEBUG1)
				Return FuncReturn($aResult2)
			EndIf

			If $UpdateMyVillage Then
				If $x <> $g_iVILLAGE_OFFSET[0] Or $y <> $g_iVILLAGE_OFFSET[1] Or $z <> $g_iVILLAGE_OFFSET[2] Then
					SetDebugLog("Village Offset [" & $sSource & "] updated to " & $x & ", " & $y & ", " & $z, $COLOR_DEBUG1)
				EndIf
				setVillageOffset($x, $y, $z)
				ConvertInternalExternArea() ; generate correct internal/external diamond measures
			EndIf
		EndIf
	EndIf

	Return FuncReturn($aResult)
EndFunc   ;==>SearchZoomOut

Func ZoomIn($Region = "Top")
	Local $bSuccessZoomIn = False
	Local $sScript = "ZoomIn"
	Switch $Region
		Case "Top"
			$sScript &= ".Top"
		Case "Left"
			$sScript &= ".Left"
		Case "Bottom"
			$sScript &= ".Bottom"
		Case "Right"
			$sScript &= ".Right"
	EndSwitch
	
	Switch $g_sAndroidEmulator
		Case "BlueStacks5"
			$sScript &= ".BlueStacks5"
	EndSwitch
	
	SetLog("minitouch script = " & $sScript, $COLOR_DEBUG)
	
	For $i = 1 To 3
		SetLog("[" & $i & "] Try ZoomIn", $COLOR_DEBUG)
		If Not AndroidAdbScript($sScript) Then Return False
		If _Sleep(1500) Then Return
		Local $sSceneryCode[3] = ["DS", "JS", "MS"]
		For $sCode In $sSceneryCode
			Local $iRes = GetVillageSize(False, "stone" & $sCode, "tree" & $sCode, False)
			If IsArray($iRes) Then ContinueLoop
			If $iRes = 0 Then ExitLoop
			SetLog("[" & $i & "] ZoomIn Not Succeed", $COLOR_DEBUG)
		Next
		SetLog("[" & $i & "] ZoomIn Succeed", $COLOR_SUCCESS)
		$bSuccessZoomIn = True
		ExitLoop
	Next
	If Not $bSuccessZoomIn Then Return False
	Return True
EndFunc

Func ZoomInBB($Region = "Top")
	Local $bSuccessZoomIn = False
	Local $sScript = "ZoomIn"
	Switch $Region
		Case "Top"
			$sScript &= ".Top"
		Case "Left"
			$sScript &= ".Left"
		Case "Bottom"
			$sScript &= ".Bottom"
		Case "Right"
			$sScript &= ".Right"
	EndSwitch
	
	Switch $g_sAndroidEmulator
		Case "BlueStacks5"
			$sScript &= ".BlueStacks5"
	EndSwitch
	
	SetLog("minitouch script = " & $sScript, $COLOR_DEBUG)
	
	For $i = 1 To 3
		SetLog("[" & $i & "] Try ZoomInBB", $COLOR_DEBUG)
		If Not AndroidAdbScript($sScript) Then Return False
		If _Sleep(1500) Then Return
		
		Local $sSceneryCode[2] = ["BL", "BH"]
		For $sCode In $sSceneryCode
			;GetVillageSize(False, "stoneBL", "treeBL", True)
			Local $iRes = GetVillageSize(False, "stone" & $sCode, "tree" & $sCode, True)
			If IsArray($iRes) Then ContinueLoop
			If $iRes = 0 Then ExitLoop
			SetLog("[" & $i & "] ZoomInBB Not Succeed", $COLOR_DEBUG)			
		Next
		
		SetLog("[" & $i & "] ZoomInBB Succeed", $COLOR_SUCCESS)
		$bSuccessZoomIn = True
		ExitLoop
	Next
	If Not $bSuccessZoomIn Then Return False
	Return True
EndFunc

Func ZoomInBBMEmu($Region = "Top")
	Local $bSuccessZoomIn = False
	For $i = 0 To 2
		SetLog("[" & $i & "] Try ZoomInBB", $COLOR_DEBUG)
		Switch $g_sAndroidEmulator
			Case "MEmu", "Nox"
				If Not AndroidAdbScript("ZoomInBB") Then Return False
			Case "BlueStacks2", "BlueStacks5"
				If Not AndroidAdbScript("ZoomInBB.BlueStacks") Then Return False
		EndSwitch
		If _Sleep(1500) Then Return
		Local $ZoomInResult = SearchZoomOut(False, True, "", True)
		If IsArray($ZoomInResult) Then
			If $ZoomInResult[0] = "" Then
				SetLog("[" & $i & "] ZoomInBB Succeed", $COLOR_SUCCESS)
				$bSuccessZoomIn = True
				ExitLoop
			Else
				SetLog("[" & $i & "] ZoomInBB Not Succeed", $COLOR_DEBUG)
			EndIf
		EndIf
	Next
	If Not $bSuccessZoomIn Then Return False
	Switch $Region
		Case "Top"
			ClickDrag(400, 150, 400, 400, 200)
			If _Sleep(500) Then Return
			ClickDrag(400, 150, 400, 400, 200)
		Case "Left"
			ClickDrag(200, 400, 700, 400, 200)
			If _Sleep(500) Then Return
			ClickDrag(400, 150, 400, 300, 200)
		Case "Bottom"
			ClickDrag(400, 450, 400, 50, 200)
			If _Sleep(500) Then Return
		Case "Right"
			ClickDrag(700, 400, 200, 400, 200)
			If _Sleep(500) Then Return
			ClickDrag(400, 150, 400, 400, 200)
	EndSwitch
	Return True
EndFunc

