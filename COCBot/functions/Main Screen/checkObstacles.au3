; #FUNCTION# ====================================================================================================================
; Name ..........: checkObstacles
; Description ...: Checks whether something is blocking the pixel for mainscreen and tries to unblock
; Syntax ........: checkObstacles()
; Parameters ....:
; Return values .: Returns True when there is something blocking
; Author ........: Hungle (2014)
; Modified ......: KnowJack (2015), Sardo (08-2015), TheMaster1st(10-2015), MonkeyHunter (08-2016), MMHK (12-2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
;
Func checkObstacles($bBuilderBase = False) ;Checks if something is in the way for mainscreen
	If Not $bBuilderBase Then $bBuilderBase = $g_bStayOnBuilderBase
	If Not $g_bRunState Then Return
	FuncEnter(checkObstacles)
	Local $Result = _checkObstacles($bBuilderBase)
	Return FuncReturn($Result)
EndFunc   ;==>checkObstacles

Func _checkObstacles($bBuilderBase = False) ;Checks if something is in the way for mainscreen
	Local $msg, $Result
	
	If CheckSCLOGO() Then 
		If _Sleep(1000) Then Return
		Return False
	EndIf
	
	_CaptureRegions()
	If isProblemAffect() Then
		;;;;;;;##### 1- Another device #####;;;;;;;
		If UBound(decodeSingleCoord(FindImageInPlace("Device", $g_sImgAnotherDevice, "220,300(130,60)", False))) > 1 Then
			If ProfileSwitchAccountEnabled() And $g_bChkSwitchOnAnotherDevice And Not $g_bChkSmartSwitch And $g_bChkSharedPrefs Then
				SetLog("---- Forced Switch, Another device connected ----")
				SwitchForceAnotherDevice()
				checkObstacles_ResetSearch()
				Return True
			EndIf

			If $g_iAnotherDeviceWaitTime > 3600 Then
				SetLog("Another Device has connected, waiting " & Floor(Floor($g_iAnotherDeviceWaitTime / 60) / 60) & " hours " & Floor(Mod(Floor($g_iAnotherDeviceWaitTime / 60), 60)) & " minutes " & Floor(Mod($g_iAnotherDeviceWaitTime, 60)) & " seconds", $COLOR_ERROR)
				PushMsg("AnotherDevice3600")
			ElseIf $g_iAnotherDeviceWaitTime > 60 Then
				SetLog("Another Device has connected, waiting " & Floor(Mod(Floor($g_iAnotherDeviceWaitTime / 60), 60)) & " minutes " & Floor(Mod($g_iAnotherDeviceWaitTime, 60)) & " seconds", $COLOR_ERROR)
				PushMsg("AnotherDevice60")
			Else
				SetLog("Another Device has connected, waiting " & Floor(Mod($g_iAnotherDeviceWaitTime, 60)) & " seconds", $COLOR_ERROR)
				PushMsg("AnotherDevice")
			EndIf

			If _SleepStatus($g_iAnotherDeviceWaitTime * 1000) Then Return ; Wait as long as user setting in GUI, default 120 seconds
			checkObstacles_ReloadCoC($aReloadButton, "#0127")
			If $g_bForceSinglePBLogoff Then $g_bGForcePBTUpdate = True
			checkObstacles_ResetSearch()
			Return True
		EndIf

		;;;;;;;##### 2- Take a break #####;;;;;;;
		If UBound(decodeSingleCoord(FindImageInPlace("Break", $g_sImgPersonalBreak, "165,257,335,315", False))) > 1 Then ; used for all 3 different break messages
			SetLog("Village must take a break, wait", $COLOR_ERROR)
			If TestCapture() Then Return "Village must take a break"
			PushMsg("TakeBreak")
			If ProfileSwitchAccountEnabled() Then
				$g_iNextAccount = $g_iCurAccount + 1
				If $g_iNextAccount > $g_iTotalAcc Then $g_iNextAccount = 0
				$g_bRestart = True
				SwitchForceAnotherDevice()
				Return True
			Else
				If _SleepStatus($DELAYCHECKOBSTACLES4) Then Return ; 2 Minutes
			EndIf
			checkObstacles_ReloadCoC($aReloadButton, "#0128") ;Click on reload button
			If $g_bForceSinglePBLogoff Then $g_bGForcePBTUpdate = True
			checkObstacles_ResetSearch()
			Return True
		EndIf
		
		;;;;;;;##### Connection Lost & OoS & Inactive & Maintenance #####;;;;;;;
		Select
			Case UBound(decodeSingleCoord(FindImageInPlace("AnyoneThere", $g_sImgAnyoneThere, "440,310,580,360", False))) > 1 ; Inactive only
				SetLog("Village was Inactive, Reloading CoC", $COLOR_ERROR)
				If $g_bForceSinglePBLogoff Then $g_bGForcePBTUpdate = True
			Case UBound(decodeSingleCoord(FindImageInPlace("ConnectionLost", $g_sImgConnectionLost, "160,270,700,420", False))) > 1 ; Connection Lost
				SetLog("Connection lost, Reloading CoC", $COLOR_ERROR)
			Case UBound(decodeSingleCoord(FindImageInPlace("OOS", $g_sImgOutOfSync, "355,300,435,365", False, $g_iAndroidLollipop))) > 1 ; Check OoS
				SetLog("Out of Sync Error, Reloading CoC", $COLOR_ERROR)
			Case (UBound(decodeSingleCoord(FindImageInPlace("ImportantNotice", $G_sImgImportantNotice, "150,220,430,290", False))) > 1)
				SetLog("Found the 'Important Notice' window, closing it", $COLOR_INFO)
			Case Else
				;  Add check for game update and Rate CoC error messages
				If $g_bDebugImageSave Then SaveDebugImage("ChkObstaclesReloadMsg_", False) ; debug only
				;$Result = getOcrRateCoc(228, 390, "Check Obstacles getOCRRateCoC= ")
				Local $sRegion = "220,380(60,25)"
				If $g_iAndroidVersionAPI >= $g_iAndroidLollipop Then
					$sRegion = "550,370(70,35)"
				EndIf
				$Result = decodeSingleCoord(FindImageInPlace("RateNever", $g_sImgAppRateNever, $sRegion, False, True))
				If UBound($Result) > 1 Then
					SetLog("Clash feedback window found, permanently closed!", $COLOR_ERROR)
					PureClick($Result[0] + 5, $Result[1] + 5, 1, 0, "#9999") ; Click on never to close window and stop reappear. Never=248,408 & Later=429,408
					PullSharedPrefs()
					Return True
				EndIf
				
				;  Add check for banned account :(
				$Result = getOcrReloadMessage(171, 358, "Check Obstacles OCR 'policy at super'=") ; OCR text for "policy at super"
				If StringInStr($Result, "policy", $STR_NOCASESENSEBASIC) Then
					$msg = "Sorry but account has been banned, Bot must stop!"
					BanMsgBox()
					Return checkObstacles_StopBot($msg) ; stop bot
				EndIf
				$Result = getOcrReloadMessage(171, 337, "Check Obstacles OCR 'prohibited 3rd'= ") ; OCR text for "prohibited 3rd party"
				If StringInStr($Result, "3rd", $STR_NOCASESENSEBASIC) Then
					$msg = "Sorry but account has been banned, Bot must stop!"
					BanMsgBox()
					Return checkObstacles_StopBot($msg) ; stop bot
				EndIf
				SetLog("Warning: Cannot find type of Reload error message", $COLOR_ERROR)
		EndSelect
		
		If QuickMIS("BFI", $g_sImgUpdateCoC, 250, 280, 300, 305) Then 
			SetLog("Good News, Updates available!", $COLOR_INFO)
			$msg = "Game Update is required, Bot must stop!"
			Return checkObstacles_StopBot($msg) ; stop bot
		EndIf
		
		Return checkObstacles_ReloadCoC() ;Last chance -> Reload CoC
	EndIf
	
	If WelcomeBackCheck() Then 
		SetLog("checkObstacles: Found WelcomeBack Chief Window to close", $COLOR_ACTION)
		Click(440, 526)
		Return False
	EndIf

	If _ColorCheck(_GetPixelColor(384, 564, True), Hex(0x6CBB1F, 6), 10, Default, "checkObstacles") And _ColorCheck(_GetPixelColor(480, 564, True), Hex(0x6CBB1F, 6), 10, Default, "checkObstacles") And _ColorCheck(_GetPixelColor(430, 600, True), Hex(0x000000, 6), 10, Default, "checkObstacles")  Then
		SetLog("checkObstacles: Found Return Home Button", $COLOR_ACTION)
		Click(425, 550)
		If _Sleep(3000) Then Return
		Return False
	EndIf
	
	If BBBarbarianHead("checkObstacles") Then 
		SetLog("checkObstacles: Found Return Home Button", $COLOR_ACTION)
		Click(430, 540)
		If _Sleep(3000) Then Return
		Return False
	EndIf
	
	If _ColorCheck(_GetPixelColor(792, 39, True), Hex(0xDC0408, 6), 20, Default, "checkObstacles") Then
		SetLog("checkObstacles: Found Window with Close Button to close", $COLOR_ACTION)
		PureClick(792, 39, 1, 0, "#0134") ;Clicks X
		If _Sleep($DELAYCHECKOBSTACLES1) Then Return
		Return False
	EndIf
	
	If _ColorCheck(_GetPixelColor(415, 260, True), Hex(0xFFFFFF, 6), 20, Default, "checkObstacles") And _ColorCheck(_GetPixelColor(430, 455, True), Hex(0xBDE98D, 6), 20, Default, "checkObstacles") Then
		SetLog("checkObstacles: Found BuilderBase Star Bonus", $COLOR_ACTION)
		PureClick(430, 465) ;Clicks X
		If _Sleep($DELAYCHECKOBSTACLES1) Then Return
		Return False
	EndIf

	If _CheckPixel($aChatTab, True) Then
		SetLog("checkObstacles: Found Chat Tab to close", $COLOR_ACTION)
		PureClickP($aChatTab, 1, 0, "#0136") ;Clicks chat tab
		If _Sleep($DELAYCHECKOBSTACLES1) Then Return
		Return False
	EndIf

	If _CheckPixel($aIsTrainPgChk1, True) Then
		SetLog("checkObstacles: Found Army Window to close", $COLOR_ACTION)
		ClickAway(Default, True)
		If _Sleep($DELAYCHECKOBSTACLES1) Then Return
		Return False
	EndIf

	If QuickMIS("BC1", $g_sImgGeneralCloseButton, 660, 80, 820, 200) Then ;ads event popup window (usually covering 80% of coc screen)
		SetLog("checkObstacles: Found Event Ads", $COLOR_ACTION)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep($DELAYCHECKOBSTACLES2) Then Return
		Return False
	EndIf

	If QuickMIS("BC1", $g_sImgGeneralCloseButton, 660, 300, 720, 400) Then
		SetLog("checkObstacles: Found TownHall Upgraded Page", $COLOR_ACTION)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep($DELAYCHECKOBSTACLES2) Then Return
		Return False
	EndIf

	If IsPostDefenseSummaryPage() Then ;post defense (when bot start coc and find account are under attack, will click return home)
		SetLog("checkObstacles: Found Post Defense Summary to close", $COLOR_ACTION)
		PureClick(67, 602, 1, 0, "#0138") ;Check if Return Home button available
		If _Sleep($DELAYCHECKOBSTACLES2) Then Return
		Return False
	EndIf

	If QuickMIS("BC1", $g_sImgGeneralCloseButton, 730, 66, 790, 120) Then ;attack log page, usually because bot start and user left this page open
		SetLog("checkObstacles: Found Attack/Defense Log Page", $COLOR_ACTION)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep($DELAYCHECKOBSTACLES2) Then Return
		Return False
	EndIf

	If IsFullScreenWindow() Then ; all pages that covering coc screen and have red close button on right upper corner
		SetLog("checkObstacles: Found FullScreenWindow to close", $COLOR_ACTION)
		Click(825,45)
		If _Sleep($DELAYCHECKOBSTACLES2) Then Return
		Return False
	EndIf

	If $bBuilderBase Then CheckBB20Tutor()
	If Not $bBuilderBase Then
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then ;handle for clan capital tutorial
			SetLog("checkObstacles: Found Clan Capital Tutorial, Doing Tutorial", $COLOR_ACTION)
			CCTutorial()
			Return False
		EndIf
	EndIf

	If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then ; if bot started or situated on clan capital map, and need to go back to main village
		SetLog("checkObstacles: Found Clan Capital Map, Returning Home", $COLOR_ACTION)
		SwitchToMainVillage("CheckObstacle")
		Return False
	EndIf

	If SearchUnplacedBuilding() Then ;check for unplaced building button, after several achievement/season account may rewarded special building and need to be placed on map
		SetLog("checkObstacles: Found Unplaced Building Button, Try Place it on Map", $COLOR_ACTION)
		PlaceUnplacedBuilding()
		Return False
	EndIf

	Local $sUpdateAvail = getOcrAndCapture("coc-UpdateAvail", 320, 235, 220, 30)
	If $sUpdateAvail = "Update Available" Then
		SetLog("Chief, we have minor coc Update!", $COLOR_INFO)
		ClickAway()
		If _Sleep(500) Then Return
		Return
	EndIf
	
	Local $bIsOnBuilderIsland = isOnBuilderBase()
	If Not $bBuilderBase And $bIsOnBuilderIsland Then ;Check for MainVillage, but coc is on BB -> go to mainVillage
		ZoomOut(True)
		If SwitchBetweenBases("Main") Then
			If _Sleep($DELAYCHECKOBSTACLES1) Then Return
			Return False
		EndIf
	EndIf
	
	Local $bIsOnMainVillage = isOnMainVillage()
	If $bBuilderBase And $bIsOnMainVillage Then ;Check for BB, but in MainVillage -> go to BB
		If SwitchBetweenBases("BB") Then
			If _Sleep($DELAYCHECKOBSTACLES1) Then Return
			Return False
		EndIf
	EndIf
	
	If QuickMIS("BFI", $g_sImgMaintenance, 360, 70, 420, 110) Then 
		$Result = getOcrMaintenanceTime(300, 550, "Check Obstacles OCR Maintenance Break=")         ; OCR text to find wait time
		Local $iMaintenanceWaitTime = 0
		Local $avTime = StringRegExp($Result, "([\d]+)[Mm]|(soon)|([\d]+[Hh])", $STR_REGEXPARRAYMATCH)
		If UBound($avTime, 1) = 1 And Not @error Then
			If UBound($avTime, 1) = 3 Then
				$iMaintenanceWaitTime = $DELAYCHECKOBSTACLES10
			Else
				$iMaintenanceWaitTime = Int($avTime[0]) * 60000
				If $iMaintenanceWaitTime > $DELAYCHECKOBSTACLES10 Then $iMaintenanceWaitTime = $DELAYCHECKOBSTACLES10
			EndIf
		Else
			$iMaintenanceWaitTime = $DELAYCHECKOBSTACLES4         ; Wait 2 min
			If @error Then SetLog("Error reading Maintenance Break time?", $COLOR_ERROR)
		EndIf
		SetLog("Maintenance Break, waiting: " & $iMaintenanceWaitTime / 60000 & " minutes", $COLOR_ERROR)
		If $g_bNotifyTGEnable And $g_bNotifyAlertMaintenance = True Then NotifyPushToTelegram("Maintenance Break, waiting: " & $iMaintenanceWaitTime / 60000 & " minutes....")
		If $g_bForceSinglePBLogoff Then $g_bGForcePBTUpdate = True
		If _SleepStatus($iMaintenanceWaitTime) Then Return
		If ClickB("ReloadButton") Then SetLog("Trying to reload game after maintenance break", $COLOR_INFO)
		checkObstacles_ResetSearch()
	EndIf

	;xbebenk: I need this click away to be logged
	ClickAway("Left", True)
	Return False
EndFunc   ;==>_checkObstacles

Func WelcomeBackCheck()
	Local $bGreenButton = False, $bWhiteW = False, $bWhiteB = False, $bWhiteC = False
	If _ColorCheck(_GetPixelColor(440, 497, True), Hex(0xCEE67C, 6), 10, Default, "checkObstacles") Then $bGreenButton = True
	If _ColorCheck(_GetPixelColor(288, 150, True), Hex(0xEFEFEF, 6), 10, Default, "checkObstacles") Then $bWhiteW = True
	If _ColorCheck(_GetPixelColor(425, 146, True), Hex(0xFFFFFF, 6), 10, Default, "checkObstacles") Then $bWhiteB = True
	If _ColorCheck(_GetPixelColor(504, 146, True), Hex(0xFFFFFF, 6), 10, Default, "checkObstacles") Then $bWhiteC = True
	
	If $bGreenButton And $bWhiteW And $bWhiteB And $bWhiteC Then Return True
EndFunc

Func CheckSCLOGO()
	Local $aCheckPixelSCLOGO[4][2] = [[100,100], [700,100], [333,268], [524,268]]
	Local $aColorCheckSCLOGO[4] = ["000000", "000000", "FEFEFE", "FEFEFE"]
	Local $bPixelFoundSCLOGO = False
	For $i = 0 To UBound($aCheckPixelSCLOGO) - 1
		Local $sColor = _GetPixelColor($aCheckPixelSCLOGO[$i][0], $aCheckPixelSCLOGO[$i][1], True)
		$bPixelFoundSCLOGO = _ColorCheck($sColor, $aColorCheckSCLOGO[$i], 10, Default, "CheckSCLOGO")
		If $g_bDebugSetlog Then SetLog("[" & $i & "] CheckSCLOGO, " & String($bPixelFoundSCLOGO) & ": exp=" & $aColorCheckSCLOGO[$i] & ", got=" & $sColor, $COLOR_DEBUG1)
		If Not $bPixelFoundSCLOGO Then ExitLoop
	Next
	If $bPixelFoundSCLOGO Then SetDebugLog("SC Logo...", $COLOR_ACTION)
	Return $bPixelFoundSCLOGO
EndFunc

Func CheckBB20Tutor()
	Local $bRet = False
	For $i = 1 To 30
		If $g_bDebugSetlog Then Setlog("Dealing with Tutorial #" & $i, $COLOR_ACTION)
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(430, 362, True), Hex(0xFFFFFF, 6), 20) And _ColorCheck(_GetPixelColor(588, 362, True), Hex(0xFFFFFF, 6), 20) Then ;right balloon tips chat
			If $g_bDebugSetlog Then Setlog("Found Right Chat Tutorial", $COLOR_DEBUG2)
			ClickAway()
			If _Sleep(5000) Then Return
			$bRet = True
			ContinueLoop
		EndIf
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(270, 402, True), Hex(0xFFFFFF, 6), 20) Or _ColorCheck(_GetPixelColor(435, 402, True), Hex(0xFFFFFF, 6), 20) Then ;left balloon tips chat
			Setlog("Found Left Chat Tutorial", $COLOR_DEBUG2)
			ClickAway()
			If _Sleep(5000) Then Return
			$bRet = True
			ContinueLoop
		EndIf
		If Not $g_bRunState Then Return
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 200, 100, 680, 440) Then ;check arrow
			If QuickMIS("BC1", $g_sImgBB20 & "OttoOutpost\", $g_iQuickMISX - 50, $g_iQuickMISY, $g_iQuickMISX + 50, $g_iQuickMISY + 150) Then ;check OttoOutpost Image
				Setlog("Found Otto OutPost", $COLOR_DEBUG2)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(4000) Then Return
				ContinueLoop
			EndIf
		EndIf
		If Not $g_bRunState Then Return
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 200, 100, 680, 440) Then ;check arrow
			If QuickMIS("BC1", $g_sImgBB20 & "ReinforcementCamp\", $g_iQuickMISX - 50, $g_iQuickMISY, $g_iQuickMISX + 50, $g_iQuickMISY + 150) Then ;check ReinforcementCamp Image
				Setlog("Found Reinforcement Camp", $COLOR_DEBUG2)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(4000) Then Return
				ContinueLoop
			EndIf
		EndIf
		If Not $g_bRunState Then Return
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 200, 100, 680, 440) Then ;check arrow
			If QuickMIS("BC1", $g_sImgBB20 & "ElixCart\", $g_iQuickMISX - 50, $g_iQuickMISY - 150, $g_iQuickMISX + 50, $g_iQuickMISY) Then ;check ElixCart Image
				Setlog("Found Elix Cart", $COLOR_DEBUG2)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(4000) Then Return
				ContinueLoop
			EndIf
		EndIf
		If Not $g_bRunState Then Return
		If QuickMIS("BC1", $g_sImgBB20 & "ElixCart\", 640, 515, 720, 560) Then ;check ElixCart Image
			Setlog("Found Collect Cart", $COLOR_DEBUG2)
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(4000) Then Return
			ContinueLoop
		EndIf
		If Not $g_bRunState Then Return
		If QuickMIS("BC1", $g_sImgBB20 & "UpTunnel\", 600, 400, 760, 560) Then ;Up Tunnel
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(2000) Then Return
			If QuickMIS("BC1", $g_sImgBB20 & "DownTunnel\", 130, 60, 290, 300) Then ;Down Tunnel
				Setlog("Found DownSide of BuilderBase, exit CheckBB20Tutor", $COLOR_DEBUG2)
				ExitLoop
			EndIf
		EndIf

		If Not $g_bRunState Then Return
		If _CheckPixel($aIsOnBuilderBase, True, Default, "CheckBB20Tutor") Then
			If $g_bDebugSetlog Then Setlog("Found MainScreen of BuilderBase, exit CheckBB20Tutor", $COLOR_DEBUG2)
			ExitLoop
		EndIf

		If _CheckPixel($aIsMain, True, Default, "CheckBB20Tutor") Then
			If $g_bDebugSetlog Then Setlog("Found MainScreen of MainVillage, exit CheckBB20Tutor", $COLOR_DEBUG2)
			ExitLoop
		EndIf

		If Not $g_bRunState Then Return
	Next
	If $i = 30 Then checkObstacles_ReloadCoC()
	Return $bRet
EndFunc

Func SwitchForceAnotherDevice()
	Local $bResult = True
	Local $abAccountNo = AccountNoActive()
	$g_bReMatchAcc = False

	Local $NextAccount = _ArraySearch($abAccountNo, True, $g_iCurAccount + 1)
	If $NextAccount < 0 Then
		$NextAccount = _ArraySearch($abAccountNo, True)
	EndIf
	$g_iNextAccount = $NextAccount
	If Not $g_bRunState Then Return
	SetLog("Current Account = [" & $g_iCurAccount + 1 & "]")
	SetLog("Switching to Account [" & $g_iNextAccount + 1 & "]")
	Local $bSharedPrefs = $g_bChkSharedPrefs And HaveSharedPrefs($g_asProfileName[$g_iNextAccount])
	SwitchAccountVariablesReload("Save")
	If $g_ahTimerSinceSwitched[$g_iCurAccount] <> 0 Then
		If Not $g_bReMatchAcc Then SetSwitchAccLog(" - Acc " & $g_iCurAccount + 1 & ", online: " & Int(__TimerDiff($g_ahTimerSinceSwitched[$g_iCurAccount]) / 1000 / 60) & "m")
		SetTime(True)
		$g_aiRunTime[$g_iCurAccount] += __TimerDiff($g_ahTimerSinceSwitched[$g_iNextAccount])
		$g_ahTimerSinceSwitched[$g_iCurAccount] = 0
	EndIf

	$g_iCurAccount = $NextAccount
	SwitchAccountVariablesReload()

	$g_ahTimerSinceSwitched[$g_iCurAccount] = __TimerInit()
	If $g_sProfileCurrentName <> $g_asProfileName[$g_iNextAccount] Then
		If $g_iGuiMode = 1 Then
			; normal GUI Mode
			_GUICtrlComboBox_SetCurSel($g_hCmbProfile, _GUICtrlComboBox_FindStringExact($g_hCmbProfile, $g_asProfileName[$g_iNextAccount]))
			cmbProfile()
			DisableGUI_AfterLoadNewProfile()
		Else
			; mini or headless GUI Mode
			saveConfig()
			$g_sProfileCurrentName = $g_asProfileName[$g_iNextAccount]
			LoadProfile(False)
		EndIf
	EndIf

	If $bSharedPrefs Then
		SetLog("Please wait for loading CoC")
		PushSharedPrefs()
		OpenCoC()
		waitMainScreen()
	EndIf

	SetSwitchAccLog("Switched to Acc [" & $NextAccount + 1 & "]", $COLOR_SUCCESS)
	CreateLogFile() ; Cause use of the right log file after switch
	If Not $g_bRunState Then Return
EndFunc

Func checkObstacles_ReloadCoC($point = Default, $debugtxt = "")
	If $point = Default Then
		CloseCoC(True) ;restart coc
	Else
		PureClickP($point, 1, 0, $debugtxt)
		_SleepStatus(15000)
	EndIf
	Return True
EndFunc   ;==>checkObstacles_ReloadCoC

Func checkObstacles_StopBot($msg)
	SetLog($msg, $COLOR_ERROR)
	If TestCapture() Then Return $msg
	If $g_bNotifyTGEnable And $g_bNotifyAlertMaintenance Then NotifyPushToTelegram($msg)
	OcrForceCaptureRegion(True)
	Btnstop() ; stop bot
	Return True
EndFunc   ;==>checkObstacles_StopBot

Func checkObstacles_ResetSearch()
	; reset fast restart flags to ensure base is rearmed after error event that has base offline for long duration, like PB or Maintenance
	$g_bIsClientSyncError = False
	$g_bIsSearchLimit = False
	$g_abNotNeedAllTime[0] = True
	$g_abNotNeedAllTime[1] = True
	$g_bRestart = True ; signal all calling functions to return to runbot
EndFunc   ;==>checkObstacles_ResetSearch

Func BanMsgBox()
	Local $MsgBox
	Local $stext = "Sorry, your account is banned!!" & @CRLF & "Bot will stop now..."
	If TestCapture() Then Return $stext
	While 1
		PushMsg("BAN")
		_ExtMsgBoxSet(4, 1, 0x004080, 0xFFFF00, 20, "Comic Sans MS", 600)
		$MsgBox = _ExtMsgBox(48, "Ok", "Banned", $stext, 1)
		If $MsgBox = 1 Then Return
		_ExtMsgBoxSet(4, 1, 0xFFFF00, 0x004080, 20, "Comic Sans MS", 600)
		$MsgBox = _ExtMsgBox(48, "Ok", "Banned", $stext, 1)
		If $MsgBox = 1 Then Return
	WEnd
EndFunc   ;==>BanMsgBox

Func checkObstacles_Network($bForceCapture = False, $bReloadCoC = True)
	Static $hCocReconnectingTimer = 0 ; TimerHandle of first CoC reconnecting animation

	If QuickMIS("BC1", $g_sImgCocReconnecting, 420,325,440,345) Then
		If $hCocReconnectingTimer = 0 Then
			SetLog("Network Connection lost...", $COLOR_ERROR)
			$hCocReconnectingTimer = __TimerInit()
		ElseIf __TimerDiff($hCocReconnectingTimer) > $g_iCoCReconnectingTimeout Then
			SetLog("Network Connection really lost, Reloading CoC...", $COLOR_ERROR)
			$hCocReconnectingTimer = 0
			If $bReloadCoC Then CloseCoC(True)
			Return True
		Else
			SetLog("Network Connection lost, waiting...", $COLOR_ERROR)
		EndIf
	Else
		$hCocReconnectingTimer = 0
	EndIf
	Return False
EndFunc   ;==>checkObstacles_Network

Func CheckObstacles_SCIDPopup()
	Local $ascidConnectButton = decodeSingleCoord(findImage("SCID", $g_sImgSupercellIDConnect, GetDiamondFromRect("100,20,700,100"), 1, True))
	If IsArray($ascidConnectButton) And UBound($ascidConnectButton, 1) >= 2 Then
		SetDebugLog("checkObstacles: Found SCID popup connect suggestion", $COLOR_ACTION)
		Click($ascidConnectButton[0], $ascidConnectButton[1])
		If _Sleep(1000) Then Return
		Local $aSuperCellIDWindowsUI, $bSCIDWindowOpened = False
		For $i = 0 To 30 ; Checking "New SuperCellID UI" continuously in 30sec
			If Mod($i, 2) = 0 Then
				$aSuperCellIDWindowsUI = decodeSingleCoord(findImage("SupercellID Windows", $g_sImgSupercellIDWindows, GetDiamondFromRect("550,60,760,160"), 1, True, Default))
			Else
				$aSuperCellIDWindowsUI = decodeSingleCoord(findImage("SupercellID Windows", $g_sImgSupercellIDBlack, GetDiamondFromRect("550,450,760,550"), 1, True, Default))
			EndIf
			If IsArray($aSuperCellIDWindowsUI) And UBound($aSuperCellIDWindowsUI, 1) >= 2 Then
				SetLog("SupercellID Window Opened", $COLOR_DEBUG)
				$bSCIDWindowOpened = True
				ExitLoop
			EndIf
			If Not $g_bRunState Then Return
			If _Sleep(900) Then Return
		Next
		If $bSCIDWindowOpened Then
			AndroidBackButton() ;Send back button to android
			If _Sleep(1000) Then Return
			If IsOKCancelPage() Then
				AndroidBackButton()
			EndIf
		EndIf
	Else
		Return False
	EndIf
	Return True
EndFunc

Func SearchUnplacedBuilding()
	Local $atmpInfo = getNameBuilding(330, 474)
	If $atmpInfo = "" Then
		SetDebugLog("Search: Unplaced Building Not Found!")
		Return False
	Else
		If StringInStr($atmpInfo, "place") Or StringInStr($atmpInfo, "Items") Then
			SetDebugLog("Search: Unplaced Building Found!", $COLOR_SUCCESS)
			Return True
		EndIf
	EndIf
EndFunc

