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
	
	checkObstacles_Network()
	CheckAndroidReboot()
	If Not $g_bRunState Then Return
	If IsProblemAffect() Then
		;1- Another device
		If QuickMIS("BC1", $g_sImgAnotherDevice, 255, 315, 345, 335) Then 
			If ProfileSwitchAccountEnabled() And $g_bChkSwitchOnAnotherDevice And $g_bChkSharedPrefs Then
				SetLog("---- Forced Switch, Another device connected ----", $COLOR_ACTION)
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
			checkObstacles_ReloadCoC()
			If $g_bForceSinglePBLogoff Then $g_bGForcePBTUpdate = True
			checkObstacles_ResetSearch()
			Return True
		EndIf

		;2- Take a break
		If QuickMIS("BC1", $g_sImgPersonalBreak, 220, 270, 440, 380) Then 
			If ProfileSwitchAccountEnabled() And $g_bChkSwitchOnAnotherDevice And $g_bChkSharedPrefs Then
				SetLog("---- Forced Switch, Village must take a break ----", $COLOR_ACTION)
				SwitchForceAnotherDevice()
				checkObstacles_ResetSearch()
				Return True
			Else
				PushMsg("TakeBreak")
				SetLog("Village must take a break, wait", $COLOR_ERROR)
				If _SleepStatus(120000) Then Return ; 2 Minutes
			EndIf
			checkObstacles_ReloadCoC()
			If $g_bForceSinglePBLogoff Then $g_bGForcePBTUpdate = True
			checkObstacles_ResetSearch()
			Return True
		EndIf
		
		;3- AnyoneThere, Connection Lost, OoS, RateNever
		Select
			Case QuickMIS("BC1", $g_sImgAnyoneThere, 220, 270, 440, 340) ;AnyoneThere
				SetLog("Village was Inactive, Reloading CoC", $COLOR_ERROR)
				If $g_bForceSinglePBLogoff Then $g_bGForcePBTUpdate = True
			Case QuickMIS("BC1", $g_sImgConnectionLost, 220, 270, 500, 340) ; Connection Lost
				SetLog("Connection lost, Reloading CoC", $COLOR_ERROR)
			Case QuickMIS("BC1", $g_sImgOutOfSync, 220, 270, 500, 340) ; Out of Sync
				SetLog("Out of Sync Error, Reloading CoC", $COLOR_ERROR)
			Case QuickMIS("BC1", $g_sImgAppRateNever, 220, 270, 500, 340) ; RateNever
				SetLog("Clash feedback window found, permanently closed!", $COLOR_INFO)
				PureClick(580, 390)
				If _Sleep(2000) Then Return
				PullSharedPrefs()
				Return True
			Case QuickMIS("BC1", $g_sImgImportantNotice, 220, 270, 440, 340) ; ImportantNotice
				SetLog("Found the 'Important Notice' window, closing it", $COLOR_INFO)
				PureClick(200, 400)
				If _Sleep(2000) Then Return
				Return True
			Case QuickMIS("BC1", $g_sImgUpdateCoC, 250, 280, 300, 305) ; UpdateCoC
				SetLog("Good News, Updates available!", $COLOR_INFO)
				$msg = "Game Update is required, Bot must stop!"
				Return checkObstacles_StopBot($msg) ; stop bot
			Case Else
				;  Add check for game update and Rate CoC error messages
				If $g_bDebugImageSave Then SaveDebugImage("ChkObstaclesReloadMsg_", False) ; debug only
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
		
		Return checkObstacles_ReloadCoC() ;Last chance -> Reload CoC
	EndIf
	
	If _ColorCheck(_GetPixelColor(770, 138, True), Hex(0xD1151A, 6), 10, Default, "checkObstacles") And _ColorCheck(_GetPixelColor(770, 118, True), Hex(0xFFFFFF, 6), 10, Default, "checkObstacles") Then
		SetLog("checkObstacles: Found Boost Supertroop Window", $COLOR_ACTION)
		Click(770, 120)
		If _Sleep(1000) Then Return
		Return False
	EndIf
	If Not $g_bRunState Then Return
	If _ColorCheck(_GetPixelColor(395, 535, True), Hex(0x6DBC1F, 6), 10, Default, "checkObstacles") And _ColorCheck(_GetPixelColor(464, 535, True), Hex(0x6DBC1F, 6), 10, Default, "checkObstacles") Then
		SetLog("checkObstacles: Found Cookie Rumble Confirm Window", $COLOR_ACTION)
		Click(430, 515)
		If _Sleep(1000) Then Return
		Return False
	EndIf
	
	If WelcomeBackCheck() Then 
		SetLog("checkObstacles: Found WelcomeBack Chief Window to close", $COLOR_ACTION)
		Click(440, 515)
		Return False
	EndIf
	If Not $g_bRunState Then Return
	If QuickMIS("BC1", $g_sImgWelcomeBackReward, 396, 135, 500, 165) Then 
		Local $aClaim = QuickMIS("CNX", $g_sImgWelcomeBackReward, 80, 260, 725, 480)
		If IsArray($aClaim) And UBound($aClaim) > 0 Then
			For $i = 0 To UBound($aClaim) - 1
				Click($aClaim[$i][1], $aClaim[$i][2])
				SetLog("Click Claim Button", $COLOR_ACTION)
			Next
		EndIf
		If QuickMIS("BC1", $g_sImgGeneralCloseButton, 735, 120, 780, 165) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
		EndIf
		SetLog("checkObstacles: Found WelcomeBack Reward Window to close", $COLOR_ACTION)
		Return False
	EndIf

	If _ColorCheck(_GetPixelColor(384, 564, True), Hex(0x6CBB1F, 6), 10, Default, "checkObstacles") And _ColorCheck(_GetPixelColor(480, 564, True), Hex(0x6CBB1F, 6), 10, Default, "checkObstacles") And _ColorCheck(_GetPixelColor(430, 600, True), Hex(0x000000, 6), 10, Default, "checkObstacles")  Then
		SetLog("checkObstacles: Found Return Home Button", $COLOR_ACTION)
		Click(425, 550)
		If _Sleep(3000) Then Return
		Return False
	EndIf
	If Not $g_bRunState Then Return
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
	If Not $g_bRunState Then Return
	If _CheckPixel($aChatTab, True) Then
		SetLog("checkObstacles: Found Chat Tab to close", $COLOR_ACTION)
		PureClickP($aChatTab, 1, 0, "#0136") ;Clicks chat tab
		If _Sleep($DELAYCHECKOBSTACLES1) Then Return
		Return False
	EndIf

	If _PixelSearch($aIsTrainPage[0], $aIsTrainPage[1], $aIsTrainPage[0] + 1, $aIsTrainPage[1] + 1, Hex($aIsTrainPage[2], 6), $aIsTrainPage[3], True, "checkObstacles") Then
		SetLog("checkObstacles: Found Army Window to close", $COLOR_ACTION)
		ClickAway(Default, True)
		If _Sleep($DELAYCHECKOBSTACLES1) Then Return
		Return False
	EndIf
	
	If Not $g_bRunState Then Return
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
	If Not $g_bRunState Then Return
	If QuickMIS("BC1", $g_sImgGeneralCloseButton, 730, 66, 790, 120) Then ;attack log page, usually because bot start and user left this page open
		SetLog("checkObstacles: Found Attack/Defense Log Page", $COLOR_ACTION)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep($DELAYCHECKOBSTACLES2) Then Return
		Return False
	EndIf

	If IsFullScreenWindow("checkObstacles") Then ; all pages that covering coc screen and have red close button on right upper corner
		SetLog("checkObstacles: Found FullScreenWindow to close", $COLOR_ACTION)
		Click(825,45)
		If _Sleep($DELAYCHECKOBSTACLES2) Then Return
		Return False
	EndIf
	If Not $g_bRunState Then Return
	;If $bBuilderBase Then CheckBB20Tutor()
	If $bBuilderBase Then CheckBB20LootCartTutor()
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
	If Not $g_bRunState Then Return
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
	If Not $g_bRunState Then Return
	Local $bIsOnBuilderIsland = isOnBuilderBase()
	If Not $bBuilderBase And $bIsOnBuilderIsland Then ;Check for MainVillage, but coc is on BB -> go to mainVillage
		ZoomOut(True)
		If SwitchBetweenBases("Main") Then
			If _Sleep($DELAYCHECKOBSTACLES1) Then Return
			Return False
		EndIf
	EndIf
	If Not $g_bRunState Then Return
	Local $bIsOnMainVillage = isOnMainVillage()
	If $bBuilderBase And $bIsOnMainVillage Then ;Check for BB, but in MainVillage -> go to BB
		If SwitchBetweenBases("BB") Then
			If _Sleep($DELAYCHECKOBSTACLES1) Then Return
			Return False
		EndIf
	EndIf
	
	If QuickMIS("BC1", $g_sImgEventConfirm, 310, 410, 560, 650) Then 
		SetLog("checkObstacles: Found Event Confirm Button", $COLOR_ACTION)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep($DELAYCHECKOBSTACLES2) Then Return
		Return False
	EndIf
	
	If Not $g_bRunState Then Return
	;CheckPetHouseTutorial()
	CheckBuilderHutTutorial()
	
	If Not $g_bRunState Then Return
	If QuickMIS("BC1", $g_sImgMaintenance, 300, 38, 566, 75) Then 
		$Result = getOcrMaintenanceTime(285, 583, "Check Obstacles OCR Maintenance Break=")         ; OCR text to find wait time
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
	If _ColorCheck(_GetPixelColor(440, 497, True), Hex(0xDCF584, 6), 20, Default, "WelcomeBackCheck") Then $bGreenButton = True
	If _ColorCheck(_GetPixelColor(288, 150, True), Hex(0xFFFFFF, 6), 20, Default, "WelcomeBackCheck") Then $bWhiteW = True
	If _ColorCheck(_GetPixelColor(425, 146, True), Hex(0xFFFFFF, 6), 20, Default, "WelcomeBackCheck") Then $bWhiteB = True
	If _ColorCheck(_GetPixelColor(504, 146, True), Hex(0xFFFFFF, 6), 20, Default, "WelcomeBackCheck") Then $bWhiteC = True
	
	If $bGreenButton And $bWhiteW And $bWhiteB And $bWhiteC Then Return True
	
	If _ColorCheck(_GetPixelColor(155, 230, True), Hex(0xE8E8E0, 6), 20, Default, "THUpgradedCheck") And _
		_ColorCheck(_GetPixelColor(700, 248, True), Hex(0xFFFFFF, 6), 20, Default, "THUpgradedCheck") Then 
			Click(700, 248, 1, 50, "THUpgradedCheck")
			If _Sleep(500) Then Return
			Click(422, 543, 1, 50, "THUpgradedCheck")
			If _Sleep(500) Then Return
			Click(422, 543, 1, 50, "THUpgradedCheck")
			Return True
	EndIf
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

Func CheckBB20LootCartTutor()
	Local $bRet = False
	For $i = 1 To 30
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 370, 385, 480, 475) Then ;check arrow
			If QuickMIS("BC1", $g_sImgBB20 & "ElixCart\", $g_iQuickMISX - 60, $g_iQuickMISY - 150, $g_iQuickMISX + 60, $g_iQuickMISY) Then ;check ElixCart Image
				Setlog("Found Elix Cart", $COLOR_DEBUG2)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(4000) Then Return
				ContinueLoop
			EndIf
		EndIf
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
		If QuickMIS("BC1", $g_sImgBB20 & "ElixCart\", 625, 510, 710, 550) Then
			Setlog("Collecting Elixir from BuilderBase Cart", $COLOR_ACTION)
			Click($g_iQuickMISX, $g_iQuickMISY)
			ClickAway()
			If _Sleep(5000) Then Return
			$bRet = True
			ContinueLoop
		EndIf
		If Not $g_bRunState Then Return
		If isOnBuilderBase() Then
			If $g_bDebugSetlog Then Setlog("Found MainScreen of BuilderBase, exit CheckBB20LootCartTutor", $COLOR_DEBUG2)
			$bRet = False
			ExitLoop
		EndIf
		If _Sleep(500) Then Return
	Next
	If $i = 30 Then checkObstacles_ReloadCoC()
	Return $bRet
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
		If isOnBuilderBase() Then
			If $g_bDebugSetlog Then Setlog("Found MainScreen of BuilderBase, exit CheckBB20Tutor", $COLOR_DEBUG2)
			$bRet = False
			ExitLoop
		EndIf

		If isOnMainVillage() Then
			If $g_bDebugSetlog Then Setlog("Found MainScreen of MainVillage, exit CheckBB20Tutor", $COLOR_DEBUG2)
			$bRet = False
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
		Return False
	Else
		If StringInStr($atmpInfo, "place") Or StringInStr($atmpInfo, "Items") Then
			SetLog("Search: Unplaced Building Found!", $COLOR_SUCCESS)
			Return True
		EndIf
	EndIf
EndFunc

Func CheckPetHouseTutorial()
	Local $TmpX = 0, $TmpY = 0, $aPetHouse
	If $g_iTownHallLevel < 14 Then Return
	
	If QuickMIS("BC1", $g_sImgOrangeBuilding, 60, 60, 800, 530) Then
		$TmpX = $g_iQuickMISX
		$TmpY = $g_iQuickMISY
		If $TmpX < 70 Or $TmpY < 70 Or $TmpX > 770 Or $TmpY > 500 Then Return
		If QuickMIS("BC1", $g_sImgPetHouse, $TmpX - 40, $TmpY, $TmpX + 40, $TmpY + 60) Then
			SetLog("Found PetHouse Tutorial Arrow", $COLOR_SUCCESS)
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(3000) Then Return
			If WaitforPixel(115, 540, 116, 541, "326C52", 20, 2) Then Click(115, 540)
			
			For $i = 1 To 10
				SetLog("Handling Tutorial chat1 : #" & $i, $COLOR_ACTION)
				If WaitforPixel(115, 540, 116, 541, "326C52", 20, 2) Then
					SetLog("Found Tutorial chat", $COLOR_SUCCESS)
					Click(115, 540)
					If _Sleep(3000) Then Return
				EndIf
				If IsPetHousePage() Then 
					SetLog("Found PetHouse Window", $COLOR_SUCCESS)
					ExitLoop
				EndIf
				FindPetsButton()
				If _Sleep(1000) Then Return
			Next
			
			For $i = 1 To 10
				SetLog("Handling Tutorial chat2 : #" & $i, $COLOR_ACTION)
				If QuickMIS("BC1", $g_sImgOrangeBuilding, 30, 330, 150, 450) Then
					If QuickMIS("BFI", $g_sImgPetHouse & "PlusSign*", 50, 410, 110, 470) Then
						SetLog("Found Lassi assign button", $COLOR_SUCCESS)
						Click($g_iQuickMISX, $g_iQuickMISY)
						If _Sleep(1000) Then Return
					EndIf
				EndIf
				
				If QuickMIS("BFI", $g_sImgPetHouse & "Hero*", 30, 260, 360, 350) Then 
					Click($g_iQuickMISX, $g_iQuickMISY)
					If _Sleep(3000) Then Return
				EndIf
				
				If WaitforPixel(115, 540, 116, 541, "326C52", 20, 2) Then
					SetLog("Found Tutorial chat", $COLOR_SUCCESS)
					Click(115, 540)
					If _Sleep(3000) Then Return
				EndIf

				If IsPetHousePage() Then 
					SetLog("Found PetHouse Window", $COLOR_SUCCESS)
					If _Sleep(1000) Then Return
					ClickAway()
					ExitLoop
				EndIf
				If _Sleep(1000) Then Return
			Next
			
		EndIf
	EndIf
EndFunc

Func CheckBuilderHutTutorial()
	Local $TmpX = 0, $TmpY = 0, $aUpgradeButton
	If $g_iTownHallLevel < 14 Then Return
	
	If QuickMIS("BC1", $g_sImgOrangeBuilding, 70, 100, 780, 570) Then
		$TmpX = $g_iQuickMISX
		$TmpY = $g_iQuickMISY
		If QuickMIS("BC1", $g_sImgBuilderHut, $TmpX - 80, $TmpY - 80, $TmpX + 80, $TmpY + 80) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(1000) Then Return
			For $i = 1 To 10
				SetLog("Handling Tutorial chat1 : #" & $i, $COLOR_ACTION)
				If WaitforPixel(115, 540, 116, 541, "326C52", 20, 2) Then
					SetLog("Found Tutorial chat", $COLOR_SUCCESS)
					Click(115, 540)
					If _Sleep(3000) Then Return
				EndIf
				$aUpgradeButton = findButton("Upgrade")
				If IsArray($aUpgradeButton) And UBound($aUpgradeButton) = 2 Then
					SetLog("Found BuilderHut UpgradeButton", $COLOR_SUCCESS)
					ExitLoop
				EndIf
				If _Sleep(1000) Then Return
			Next
		EndIf
	EndIf
EndFunc

Func CCTutorial()
	If Not $g_bRunState Then Return
	For $i = 1 To 6
		SetLog("Wait for Arrow For Travel to Clan Capital #" & $i, $COLOR_INFO)
		ClickAway("Right")
		If _Sleep(3000) Then Return
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 330, 320, 450, 400) Then
			Click(400, 450)
			SetLog("Going to Clan Capital", $COLOR_SUCCESS)
			If _Sleep(5000) Then Return
			ExitLoop ;arrow clicked now go to next step
		EndIf
		If $i > 1 And Not QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then Return
	Next
	
	If Not $g_bRunState Then Return
	If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then ;tutorial page, with strange person, click until arrow
		For $i = 1 To 5
			SetLog("Wait for Arrow on CC Peak #" & $i, $COLOR_INFO)
			ClickAway("Right")
			If _Sleep(3000) Then Return
			If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 330, 100, 450, 200) Then ;check clan capital map
				Click($g_iQuickMISX, $g_iQuickMISY) ;click capital peak arrow
				SetLog("Going to Capital Peak", $COLOR_SUCCESS)
				If _Sleep(10000) Then Return
				ExitLoop ;arrow clicked now go to next step
			EndIf
		Next
	EndIf
	
	If Not $g_bRunState Then Return
	If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then ;tutorial page, with strange person, click until map button
		For $i = 1 To 5
			SetLog("Wait for Map Button #" & $i, $COLOR_INFO)
			ClickAway("Right")
			If _Sleep(3000) Then Return
			If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 20, 620, 90, 660) Then
				Click($g_iQuickMISX, $g_iQuickMISY) ;click map
				SetLog("Going back to Clan Capital", $COLOR_SUCCESS)
				If _Sleep(5000) Then Return
				Click($g_iQuickMISX, $g_iQuickMISY) ;click return home
				SetLog("Return Home", $COLOR_SUCCESS)
				If _Sleep(5000) Then Return
				ExitLoop ;map button clicked now go to next step
			EndIf
		Next
	EndIf
	
	If Not $g_bRunState Then Return
	For $i = 1 To 8
		SetLog("Wait for Arrow on CC Forge #" & $i, $COLOR_INFO)
		ClickAway("Right")
		If _Sleep(3000) Then Return
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 370, 350, 480, 450) Then ;check arrow on Clan Capital forge
			Click(420, 490) ;click CC Forge
			If _Sleep(3000) Then Return
			ExitLoop
		EndIf
	Next

	If Not $g_bRunState Then Return
	For $i = 1 To 12
		SetLog("Wait for Arrow on CC Forge Window #" & $i, $COLOR_INFO)
		ClickAway("Right")
		If _Sleep(3000) Then Return
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 370, 350, 480, 450) Then
			Click(420, 490) ;click CC Forge
			If _Sleep(3000) Then Return
		EndIf
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial & "Arrow\", 125, 270, 225, 360) Then
			Click(180, 375) ;click collect
			If _Sleep(3000) Then Return
			ExitLoop
		EndIf
	Next
	
	If Not $g_bRunState Then Return
	For $i = 1 To 10
		SetLog("Wait for MainScreen #" & $i, $COLOR_INFO)
		ClickAway("Right")
		If isOnMainVillage() Then ExitLoop
		If _Sleep(3000) Then Return
	Next
	ClickDrag(800, 420, 500, 420, 500)
	ZoomOut()
EndFunc

Func BBTutorial($x = 170, $y = 560)
	If _Sleep(1000) Then Return
	If QuickMIS("BC1", $g_sImgOrangeBuilding, 145, 420, 240, 540) Then 
		Click($x, $y)
		If _Sleep(2000) Then Return
	Else
		SetLog("No Arrow Detected", $COLOR_INFO)
		SetLog("Skip BB Tutorial", $COLOR_INFO)
		Return False
	EndIf
	
	getBuilderCount(True) ;check if we have available builder
	If $g_iFreeBuilderCount < 1 Then
		SetLog("Wait for a free builder first", $COLOR_INFO)
		SetLog("Skip BB Tutorial", $COLOR_INFO)
		ClickAway()
		Return False
	EndIf
	
	Local $RebuildButton
	$RebuildButton = findButton("Upgrade", Default, 1, True)
	If IsArray($RebuildButton) And UBound($RebuildButton) = 2 Then
		SetLog("Rebuilding Boat", $COLOR_SUCCESS)
		Click($RebuildButton[0], $RebuildButton[1])
	Else
		SetLog("No Rebuild Button!", $COLOR_ERROR)
		Return False
	EndIf
	
	Local $RebuildWindowOK = False
	For $i = 1 To 5
		SetDebugLog("Waiting for Rebuild Boat Window #" & $i, $COLOR_ACTION)
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 575, 100, 630, 155) Then
			SetLog("Rebuild Boat Window Opened", $COLOR_INFO)
			Click(430, 505) ;Click Rebuild Button
			If _Sleep(1000) Then Return
			$RebuildWindowOK = True
			ExitLoop
		EndIf
		If _Sleep(600) Then Return
	Next
	If Not $RebuildWindowOK Then Return False
	
	SetLog("Waiting Boat Rebuild", $COLOR_INFO)
	_SleepStatus(12000)
	
	If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		SetLog("Waiting Next Tutorial to Travel", $COLOR_INFO)
		_SleepStatus(20000)
	EndIf
	
	If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then
		SetLog("Click Travel Button", $COLOR_INFO)
		Click(475, 575) ;Click Travel
		If _Sleep(2000) Then Return
		_SleepStatus(30000)
	EndIf
	
	For $i = 1 To 10
		SetLog("Waiting Next Tutorial on BuilderBase #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(3000) Then Return
			ExitLoop
		EndIf
		If _Sleep(5000) Then Return
	Next
	
	For $i = 1 To 5
		If QuickMIS("BC1", $g_sImgOrangeBuilding, 475, 110, 665, 250) Then 
			Click(595, 250) ;Click Broken Builder Hall
			If _Sleep(2000) Then Return
			Local $RebuildButton = findButton("Upgrade", Default, 1, True)
			If IsArray($RebuildButton) And UBound($RebuildButton) = 2 Then
				SetLog("Upgrading Builder Hall", $COLOR_SUCCESS)
				Click($RebuildButton[0], $RebuildButton[1])
				If _Sleep(2000) Then Return
			EndIf
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 700, 70, 800, 130) Then
				SetLog("Upgrade Builder Hall Window Opened", $COLOR_INFO)
				If _Sleep(1000) Then Return
				Click(430, 540) ;Click Gold Button
				If _Sleep(2000) Then Return
				ExitLoop
			EndIf
		EndIf
		If _Sleep(2000) Then Return
	Next
	
	SetLog("Waiting Builder Hall Upgrading", $COLOR_INFO)
	_SleepStatus(12000)
	
	SetLog("Waiting Next Tutorial on BuilderBase", $COLOR_INFO)
	For $i = 1 To 10
		ClickAway()
		SetLog("Wait Next Tutorial Chat #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 460, 200, 600) Then
			SetLog("Found Tutorial Chat", $COLOR_ACTION)
			ClickAway()
			_SleepStatus(10000)
		EndIf
		If WaitforPixel(115, 540, 116, 541, "326C52", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(115, 540) 
			_SleepStatus(10000)
		EndIf
		If WaitforPixel(674, 535, 675, 536, "B35727", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(674, 535) 
			_SleepStatus(10000)
		EndIf
		If WaitforPixel(150, 534, 151, 535, "FFA980", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(150, 534) 
			_SleepStatus(10000)
		EndIf
		If WaitforPixel(710, 560, 711, 561, "885843", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(150, 534) 
			_SleepStatus(10000)
		EndIf
		
		If QuickMIS("BC1", $g_sImgOrangeBuilding, 430, 100, 550, 230) Then 
			Click(430, 240) ;Click Star Laboratory
			If _Sleep(2000) Then Return
			ExitLoop
		EndIf
		If _Sleep(3000) Then Return
	Next
		
	For $i = 1 To 5
		SetLog("Wait Research Button Tutorial on Star Laboratory #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgOrangeBuilding, 480, 460, 570, 570) Then 
			Click(470, 570) ;Click Research Button
			If _Sleep(2000) Then Return
			ExitLoop
		EndIf
		If _Sleep(2000) Then Return
	Next
	
	For $i = 1 To 5
		SetLog("Wait Arrow Tutorial on Raged Barbarian #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgOrangeBuilding, 160, 250, 270, 380) Then 
			Click(110, 390) ;Click Raged Barbarian
			If _Sleep(2000) Then Return
			ExitLoop
		EndIf
		If _Sleep(2000) Then Return
	Next
	
	For $i = 1 To 5
		SetLog("Wait Arrow Tutorial on Upgrade Button #" & $i, $COLOR_INFO)
		If IsFullScreenWindow() Then 
			Click(645, 570) ;Click Upgrade Button
			If _Sleep(2000) Then Return
			ExitLoop
		EndIf
		If _Sleep(2000) Then Return
	Next
	
	SetLog("Waiting Raged Barbarian upgrade, 30s", $COLOR_INFO)
	_SleepStatus(35000)
	ClickAway()
	_SleepStatus(10000)
	ClickAway()
	_SleepStatus(10000)
	
	SetLog("Going Attack For Tutorial", $COLOR_INFO)
	For $i = 1 To 10
		SetLog("Wait Arrow Tutorial on Attack Button #" & $i, $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgOrangeBuilding, 6, 460, 110, 590) Then 
			Click(60, 610) ;Click Attack Button
			If _Sleep(2000) Then Return
			ExitLoop
		EndIf
		If _Sleep(2000) Then Return
	Next
	
	For $i = 1 To 10
		SetLog("Wait For Find Now Button #" & $i, $COLOR_ACTION)
		If WaitforPixel(650, 437, 651, 438, "8BD33A", 20, 2) Then
			SetDebugLog("Found FindNow Button", $COLOR_ACTION)
			Click(650, 437)
			_SleepStatus(15000) ;wait for clouds and other animations
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	
	For $i = 1 To 10
		SetLog("Wait For AttackBar #" & $i, $COLOR_ACTION)
		Local $AttackBarBB = GetAttackBarBB()
		If IsArray($AttackBarBB) And UBound($AttackBarBB) > 0 And $AttackBarBB[0][0] = "Barbarian" Then
			Click($AttackBarBB[0][1], $AttackBarBB[0][2]) ;Click Raged Barbarian on AttackBar
			_SleepStatus(1000)
			Click(450, 530, 5) ;Deploy Raged Barbarian
			ExitLoop
		EndIf
		_SleepStatus(5000)
	Next
	
	If _Sleep(10000) Then Return
	
	For $i = 1 To 10
		SetLog("Waiting Next Tutorial After Attack #" & $i, $COLOR_INFO)
		ClickAway()
		If WaitforPixel(115, 540, 116, 541, "326C52", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(115, 540) 
			_SleepStatus(5000)
		EndIf
		If WaitforPixel(674, 535, 675, 536, "B35727", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(674, 535) 
			_SleepStatus(5000)
		EndIf
		If WaitforPixel(150, 534, 151, 535, "FFA980", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(150, 534) 
			_SleepStatus(5000)
		EndIf
		If QuickMIS("BC1", $g_sImgOrangeBuilding, 75, 480, 200, 600) Then 
			Click(65, 620) ;Click Return Home
			_SleepStatus(3000)
			ExitLoop
		EndIf
		If BBBarbarianHead() Then 
			Click(430, 540)
			_SleepStatus(3000)
			ExitLoop
		EndIf
		If _Sleep(3000) Then Return
	Next
	
	For $i = 1 To 10
		SetLog("Wait Arrow Tutorial on Builder Menu #" & $i, $COLOR_INFO)
		ClickAway()
		If QuickMIS("BC1", $g_sImgOrangeBuilding, 360, 30, 480, 150) Then 
			Click(470, 30) ;Click Builder Menu
			_SleepStatus(5000)
			ExitLoop
		EndIf
		If _Sleep(3000) Then Return
	Next
	
	SetLog("Wait Next Tutorial for Builder Menu", $COLOR_INFO)
	For $i = 1 To 10
		If WaitforPixel(674, 535, 675, 536, "B35727", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(674, 535) 
			_SleepStatus(5000)
		EndIf
		If WaitforPixel(115, 540, 116, 541, "326C52", 20, 2) Then
			SetLog("Found Tutorial Chat", $COLOR_INFO)
			Click(115, 540) 
			_SleepStatus(5000)
		EndIf
		ClickAway()
		getBuilderCount(False, True) ;check masterBuilder
		If Number($g_iFreeBuilderCountBB) = 1 Then ExitLoop
		If _Sleep(3000) Then Return
	Next
	
	BuilderBaseReport()
	If Number($g_iFreeBuilderCountBB) = 1 Then 
		ClickAway()
		If _Sleep(2000) Then Return
		SetLog("CONGRATULATIONS!, Successfully Open BuilderBase", $COLOR_SUCCESS)
		ZoomOut()
		Return True
	EndIf
EndFunc
