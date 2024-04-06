; #FUNCTION# ====================================================================================================================
; Name ..........: IsTrainPage & IsAttackPage & IsMainPage & IsMainChatOpenPage & IsClanInfoPage & IsLaunchAttackPage &
;                  IsOKCancelPage & IsReturnHomeBattlePage
; Description ...: Verify if you are in the correct window...
; Author ........: Sardo (2015)
; Modified ......: ProMac (2015), MonkeyHunter (12-2015), xbebenk(03-2024)
; Remarks .......: This file is part of MyBot Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: Returns True or False
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......:
; ===============================================================================================================================

Func IsPageLoop($aCheckPixel, $iLoop = 30, $bCapturePixel = $g_bCapturePixel)
	$bCapturePixel = $bCapturePixel Or $iLoop > 1
	Local $IsPage = False
	Local $i = 0

	While $i < $iLoop
		ForceCaptureRegion()
		If $g_bRestart Then Return True
		If _CheckPixel($aCheckPixel, $bCapturePixel) Then
			$IsPage = True
			ExitLoop
		EndIf
		If _Sleep($DELAYISTRAINPAGE2) Then ExitLoop ; 1s Delay
		$i += 1
	WEnd

	Return $IsPage
EndFunc   ;==>IsPageLoop

Func IsSettingPage($bSetLog = True, $iLoop = 5)

	If IsPageLoop($aIsSettingPage, $iLoop) Then
		If ($g_bDebugSetlog Or $g_bDebugClick) And $bSetLog Then SetLog("**Setting Window OK**", $COLOR_ACTION)
		Return True
	EndIf
	
	If $g_bDebugSetlog Or $g_bDebugClick Then
		Local $colorRead = _GetPixelColor($aIsSettingPage[0], $aIsSettingPage[1], True)
		SetLog("**IsSettingPage Window FAIL**", $COLOR_ACTION)
		SetLog("expected in (" & $aIsSettingPage[0] & "," & $aIsSettingPage[1] & ")  = " & Hex($aIsSettingPage[2], 6) & " - Found " & $colorRead, $COLOR_ACTION)
	EndIf

	If $bSetLog Then SetLog("Cannot find Setting Window...", $COLOR_ERROR) ; in case of $i = 29 in while loop
	If $g_bDebugImageSave Then SaveDebugImage("IsSettingPage")
	If $iLoop > 1 Then AndroidPageError("IsSettingPage")
	Return False
EndFunc   ;==>IsSettingPage

Func IsTrainPage($bSetLog = False, $iLoop = 5)
	If Not $g_bRunState Then Return
	If _PixelSearch($aIsTrainPage[0], $aIsTrainPage[1], $aIsTrainPage[0] + 1, $aIsTrainPage[1] + 1, Hex($aIsTrainPage[2], 6), $aIsTrainPage[3], True, "IsTrainPage") Then
		If $g_bDebugSetlog Or $g_bDebugClick Or $bSetLog Then SetLog("**Army Window OK**", $COLOR_ACTION)
		Return True
	EndIf
	
	If $g_bDebugSetlog Or $g_bDebugClick Or $bSetLog Then
		Local $colorRead = _GetPixelColor($aIsTrainPage[0], $aIsTrainPage[1], True)
		SetLog("**Army Window FAIL**", $COLOR_ACTION)
		SetLog("expected in (" & $aIsTrainPage[0] & "," & $aIsTrainPage[1] & ")  = " & Hex($aIsTrainPage[2], 6) & " - Found " & $colorRead, $COLOR_ACTION)
	EndIf
	
	If $bSetLog Then SetLog("Cannot find Army Window...", $COLOR_ERROR) ; in case of $i = 29 in while loop
	If $g_bDebugImageSave Then SaveDebugImage("IsTrainPage")
	If $iLoop > 1 Then AndroidPageError("IsTrainPage")
	Return False
EndFunc   ;==>IsTrainPage

Func IsAttackPage($bSetLog = False, $iLoop = 5)
	
	If IsPageLoop($aIsAttackPage, $iLoop) Then
		If $g_bDebugSetlog Or $g_bDebugClick Or $bSetLog Then SetLog("**Attack Window OK**", $COLOR_ACTION)
		Return True
	EndIf

	If $g_bDebugSetlog Or $g_bDebugClick Or $bSetLog Then
		Local $colorRead = _GetPixelColor($aIsAttackPage[0], $aIsAttackPage[1], True)
		SetLog("**Attack Window FAIL**", $COLOR_ACTION)
		SetLog("expected in (" & $aIsAttackPage[0] & "," & $aIsAttackPage[1] & ")  = " & Hex($aIsAttackPage[2], 6) & " - Found " & $colorRead, $COLOR_ACTION)
	EndIf
	If $g_bDebugImageSave Then SaveDebugImage("IsAttackPage")
	Return False

EndFunc   ;==>IsAttackPage

Func IsAttackWhileShieldPage($bSaveDebugImage = True)

	If IsPageLoop($aIsAttackShield, 1) Then
		If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Attack Shield Window Open**", $COLOR_ACTION)
		Return True
	EndIf

	If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Attack Shield Window not open**", $COLOR_ACTION)
	If $g_bDebugImageSave And $bSaveDebugImage Then SaveDebugImage("IsAttackWhileShieldPage_")
	Return False

EndFunc   ;==>IsAttackWhileShieldPage

Func IsMainPage($iLoop = 10)
	Local $aPixel = $aIsMain
	If $g_iAndroidBackgroundMode = 2 Then $aPixel[0] += 1
	
	If IsPageLoop($aPixel, $iLoop) Then
		$g_bMainWindowOk = True
		If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Main Window OK**", $COLOR_ACTION)
		Return True
	EndIf

	$g_bMainWindowOk = False
	If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Main Window FAIL**", $COLOR_ACTION)
	If $g_bDebugImageSave Then SaveDebugImage("IsMainPage")
	If $iLoop > 1 Then AndroidPageError("IsMainPage")
	Return False

EndFunc   ;==>IsMainPage

Func IsMainPageBuilderBase($iLoop = 10)

	If IsPageLoop($aIsOnBuilderBase, $iLoop) Then
		$g_bMainWindowOk = True
		If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Main Window Builder Base OK**", $COLOR_ACTION)
		Return True
	EndIf

	$g_bMainWindowOk = False
	If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Main Window Builder Base FAIL**", $COLOR_ACTION)
	If $g_bDebugImageSave Then SaveDebugImage("IsMainPageBuilderBase")
	If $iLoop > 1 Then AndroidPageError("IsMainPageBase")
	Return False

EndFunc   ;==>IsMainPage

Func IsMainChatOpenPage() ;main page open chat

	If IsPageLoop($aChatTab, 1) Then
		If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Chat Open Window OK**", $COLOR_ACTION)
		Return True
	EndIf

	If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Chat Open Window FAIL** " & $aChatTab[0] & "," & $aChatTab[1] & " " & _GetPixelColor($aChatTab[0], $aChatTab[1], True), $COLOR_ACTION)
	If $g_bDebugImageSave Then SaveDebugImage("IsMainChatOpenPage")
	Return False

EndFunc   ;==>IsMainChatOpenPage

Func IsClanInfoPage()

	If IsPageLoop($aPerkBtn, 1) Then
		If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Clan Info Window OK**", $COLOR_ACTION)
		Return True
	EndIf

	Local $result = _ColorCheck(_GetPixelColor(214, 106, True), Hex(0xFFFFFF, 6), 1) And _ColorCheck(_GetPixelColor(815, 58, True), Hex(0xD80402, 6), 5) ; if are not in a clan
	If $result Then
		If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Clan Info Window OK**", $COLOR_ACTION)
		SetLog("Join a Clan to donate and receive troops!", $COLOR_ACTION)
		Return True
	Else
		If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Clan Info Window FAIL**", $COLOR_ACTION)
		If $g_bDebugImageSave Then SaveDebugImage("IsClanInfoPage")
		Return False
	EndIf

EndFunc   ;==>IsClanInfoPage

Func IsLaunchAttackPage()

	If IsPageLoop($aFindMatchButton, 1) Then
		If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Launch Attack Window OK**", $COLOR_ACTION)
		Return True
	EndIf

	If $g_bDebugSetlog Or $g_bDebugClick Then
		Local $colorReadnoshield = _GetPixelColor($aFindMatchButton[0], $aFindMatchButton[1], True)
		SetLog("**Launch Attack Window FAIL**", $COLOR_ACTION)
		SetLog("expected in (" & $aFindMatchButton[0] & "," & $aFindMatchButton[1] & ") Found " & $colorReadnoshield, $COLOR_ACTION)
	EndIf

	If $g_bDebugImageSave Then SaveDebugImage("IsLaunchAttackPage")
	Return False

EndFunc   ;==>IsLaunchAttackPage

Func IsOKCancelPage($bWriteLog = True)

	If IsPageLoop($aConfirmSurrender, 1) Then
		If ($g_bDebugSetlog Or $g_bDebugClick) And $bWriteLog Then SetLog("**OKCancel Window OK**", $COLOR_ACTION)
		Return True
	Else
		If ($g_bDebugSetlog Or $g_bDebugClick) And $bWriteLog Then
			Local $colorRead = _GetPixelColor($aConfirmSurrender[0], $aConfirmSurrender[1], True)
			SetLog("**OKCancel Window FAIL**", $COLOR_ACTION)
			SetLog("expected in (" & $aConfirmSurrender[0] & "," & $aConfirmSurrender[1] & ")  = " & Hex($aConfirmSurrender[2], 6) & " - Found " & $colorRead, $COLOR_ACTION)
		EndIf
		If $g_bDebugImageSave And $bWriteLog Then SaveDebugImage("OKCancel")
		Return False
	EndIf

EndFunc   ;==>IsOKCancelPage

Func IsReturnHomeBattlePage($useReturnValue = False, $makeDebugImageScreenshot = True)
	If IsAttackPage(False, 1) Then Return False
	If IsPageLoop($aReturnHomeButton, 1) Then
		If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Return Home Battle Window OK**", $COLOR_ACTION)
		Return True
	EndIf

	If ($g_bDebugSetlog Or $g_bDebugClick) And ($makeDebugImageScreenshot = True) Then SetLog("**Return Home Battle Window FAIL**", $COLOR_ACTION)
	If $g_bDebugImageSave And $makeDebugImageScreenshot Then SaveDebugImage("IsReturnHomeBattlePage")
	If $useReturnValue Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>IsReturnHomeBattlePage

Func IsPostDefenseSummaryPage($bCapture = True)
	;check for loot lost summary screen after base defense when log on and base is being attacked.
	Local $result
	Local $GoldSpot = _GetPixelColor(330, 201, $bCapture) ; Gold Emblem
	Local $ElixirSpot = _GetPixelColor(334, 233, $bCapture) ; Elixir Emblem

	$result = _ColorCheck($GoldSpot, Hex(0xF0E852, 6), 20) And _ColorCheck($ElixirSpot, Hex(0xE833EE, 6), 20)

	If $result Then
		If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Post Defense Page visible**", $COLOR_ACTION)
		Return True
	Else
		If $g_bDebugSetlog Or $g_bDebugClick Then SetLog("**Post Defense Page not visible**", $COLOR_ACTION)
		If $g_bDebugImageSave Then SaveDebugImage("IsPostDefenseSummaryPage")
		Return False
	EndIf

EndFunc   ;==>IsPostDefenseSummaryPage

Func IsMultiplayerTabOpen()
	Local $result = False
	
	$result = WaitforPixel(790, 114, 791, 115, "FFFFFF", 10, 2, "IsMultiplayerTabOpen")
	If Not $result Then 
		If QuickMIS("BC1", $g_sImgGeneralCloseButton, 770, 97, 812, 136) Then $result = True
	EndIf
	
	If $result Then
		If $g_bDebugSetlog Then SetLog("Found Multiplayer Window", $COLOR_ACTION)
		Return True
	EndIf
	Return False
EndFunc ; IsMultiplayerTabOpen

Func IsFullScreenWindow($sSource = "IsFullScreenWindow")
	Local $result = False
	$result = WaitforPixel(820, 37, 821, 38, "FFFFFF", 10, 2, $sSource)
	
	If Not $result Then 
		If QuickMIS("BC1", $g_sImgGeneralCloseButton, 770, 20, 860, 100) Then $result = True
	EndIf
	
	If $result Then
		If $g_bDebugSetlog Then SetLog("Found FullScreen Window", $COLOR_ACTION)
		Return True
	EndIf
	Return False
EndFunc

Func IsProfileWindowOpen($sSource = "IsProfileWindowOpen")
	Local $result = False
	$result = WaitforPixel(806, 98, 807, 99, "FFFFFF", 10, 2, $sSource)
	
	If Not $result Then 
		If QuickMIS("BC1", $g_sImgGeneralCloseButton, 788, 83, 825, 117) Then $result = True
	EndIf
	
	If $result Then
		If $g_bDebugSetlog Then SetLog("Found Profile Window", $COLOR_ACTION)
		Return True
	EndIf
	Return False
EndFunc

Func IsChallengeWindowOpen($sSource = "IsChallengeWindowOpen")
	Local $result = False
	$result = WaitforPixel(824, 85, 825, 86, "FFFFFF", 10, 2, $sSource)
	
	If Not $result Then 
		If QuickMIS("BC1", $g_sImgGeneralCloseButton, 800, 64, 850, 112) Then $result = True
	EndIf
	
	If $result Then
		If $g_bDebugSetlog Then SetLog("Found Challenge Window", $COLOR_ACTION)
		Return True
	EndIf
	Return False
EndFunc

Func IsPetHousePage($sSource = "IsPetHousePage")
	Local $result
	$result = WaitforPixel(415, 95, 416, 96, "006F5F", 10, 2, $sSource) ;green pixel under title 'Pet House'
	
	If $result Then
		If $g_bDebugSetlog Then SetLog("Found PetHousePage Window", $COLOR_ACTION)
		Return True
	EndIf
	Return False
EndFunc   ;==>IsPetHousePage

Func IsBlacksmithPage($bSetLog = True, $iLoop = 5)
	Local $aIsBlacksmithPage[4] = [811, 69, 0xD51217, 20] ; Pink red top of close button

	If IsPageLoop($aIsBlacksmithPage, $iLoop) Then
		If ($g_bDebugSetlog Or $g_bDebugClick) And $bSetLog Then SetLog("**Blacksmith Window OK**", $COLOR_ACTION)
		SetDebugLog("**Blacksmith Window OK**", $COLOR_ACTION)
		Return True
	EndIf

	If $bSetLog Then SetLog("Cannot find Blacksmith Window...", $COLOR_ERROR) ; in case of $i = 29 in while loop
	If $g_bDebugImageSave Then SaveDebugImage("IsBlacksmithPage")
	If $iLoop > 1 Then AndroidPageError("IsBlacksmithPage")
	Return False
EndFunc   ;==>IsBlacksmithPage

