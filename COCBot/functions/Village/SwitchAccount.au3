; #FUNCTION# ====================================================================================================================
; Name ..........: Switch Account
; Description ...: This file contains the Sequence that runs all MBR Bot
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: chalicucu (6/2016), demen (4/2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
; Return True or False if Switch Account is enabled and current profile in configured list
Func ProfileSwitchAccountEnabled()
	If Not $g_bChkSwitchAcc Or Not aquireSwitchAccountMutex() Then Return False
	Return SetError(0, 0, _ArraySearch($g_asProfileName, $g_sProfileCurrentName) >= 0)
EndFunc   ;==>ProfileSwitchAccountEnabled

; Return True or False if specified Profile is enabled for Switch Account and controlled by this bot instance
Func SwitchAccountEnabled($IdxOrProfilename = $g_sProfileCurrentName)
	Local $sProfile
	Local $iIdx
	If IsInt($IdxOrProfilename) Then
		$iIdx = $IdxOrProfilename
		$sProfile = $g_asProfileName[$iIdx]
	Else
		$sProfile = $IdxOrProfilename
		$iIdx = _ArraySearch($g_asProfileName, $sProfile)
	EndIf

	If Not $sProfile Or $iIdx < 0 Or Not $g_abAccountNo[$iIdx] Then
		; not in list or not enabled
		Return False
	EndIf

	; check if mutex is or can be aquired
	Return aquireProfileMutex($sProfile) <> 0
EndFunc   ;==>SwitchAccountEnabled

; retuns copy of $g_abAccountNo validated with SwitchAccountEnabled
Func AccountNoActive()
	Local $a[UBound($g_abAccountNo)]

	For $i = 0 To UBound($g_abAccountNo) - 1
		$a[$i] = SwitchAccountEnabled($i)
	Next

	Return $a
EndFunc   ;==>AccountNoActive

Func InitiateSwitchAcc() ; Checking profiles setup in Mybot, First matching CoC Acc with current profile, Reset all Timers relating to Switch Acc Mode.
	If Not ProfileSwitchAccountEnabled() Or Not $g_bInitiateSwitchAcc Then Return
	UpdateMultiStats()
	$g_iNextAccount = -1
	SetLog("Switch Account enable for " & $g_iTotalAcc + 1 & " accounts")
	SetSwitchAccLog("Initiating: " & $g_iTotalAcc + 1 & " acc", $COLOR_SUCCESS)

	If Not $g_bRunState Then Return
	;Local $iCurProfile = _GUICtrlComboBox_GetCurSel($g_hCmbProfile)
	For $i = 0 To $g_iTotalAcc
		; listing all accounts
		Local $sBotType = "Idle"
		If $g_abAccountNo[$i] Then
			If SwitchAccountEnabled($i) Then
				$sBotType = "Active"
				If $g_abDonateOnly[$i] Then $sBotType = "Donate"
				If $g_iNextAccount = -1 Then $g_iNextAccount = $i
				If $g_asProfileName[$i] = $g_sProfileCurrentName Then $g_iNextAccount = $i
			Else
				$sBotType = "Other bot"
			EndIf
		EndIf
		SetLog("  - Account [" & $i + 1 & "]: " & $g_asProfileName[$i] & " - " & $sBotType)
		SetSwitchAccLog("  - Acc. " & $i + 1 & ": " & $sBotType)

		$g_abPBActive[$i] = False
	Next
	$g_iCurAccount = $g_iNextAccount ; make sure no crash
	SwitchAccountVariablesReload("Reset")
	SetLog("Let's start with Account [" & $g_iNextAccount + 1 & "]")
	SwitchCOCAcc($g_iNextAccount)
EndFunc   ;==>InitiateSwitchAcc

Func CheckSwitchAcc()
	Local $abAccountNo = AccountNoActive()
	If Not $g_bRunState Then Return
	Local $aActiveAccount = _ArrayFindAll($abAccountNo, True)
	If UBound($aActiveAccount) <= 1 Then Return

	Local $aDonateAccount = _ArrayFindAll($g_abDonateOnly, True)
	Local $bReachAttackLimit = ($g_aiAttackedCountSwitch[$g_iCurAccount] <= $g_aiAttackedCount - 2)
	Local $bForceSwitch = $g_bForceSwitch
	Local $nMinRemainTrain, $iWaitTime
	Local $aActibePBTaccounts = _ArrayFindAll($g_abPBActive, True)

	SetLog("Start Switch Account!", $COLOR_INFO)
	; Force switch if no clangames event active
	If $g_bForceSwitchifNoCGEvent Then 
		$bForceSwitch = True
		$g_bForceSwitchifNoCGEvent = False ;reset on switch
	EndIf
	
	; Force Switch when PBT detected
	If $g_abPBActive[$g_iCurAccount] Then $bForceSwitch = True

	If $g_iCommandStop = 0 Or $g_iCommandStop = 3 Then ; Forced to switch when in halt attack mode
		SetLog("This account is in halt attack mode, switching to another account", $COLOR_ACTION)
		SetSwitchAccLog(" - Halt Attack, Force switch")
		$bForceSwitch = True
	ElseIf $g_iCommandStop = 1 Then
		SetLog("This account is turned off, switching to another account", $COLOR_ACTION)
		SetSwitchAccLog(" - Turn idle, Force switch")
		$bForceSwitch = True
	ElseIf $g_iCommandStop = 2 Then
		SetLog("This account is out of Attack Schedule, switching to another account", $COLOR_ACTION)
		SetSwitchAccLog(" - Off Schedule, Force switch")
		$bForceSwitch = True
	ElseIf $g_bWaitForCCTroopSpell Then
		SetLog("Still waiting for CC Troops/Spells, switching to another Account", $COLOR_ACTION)
		SetSwitchAccLog(" - Waiting for CC")
		$bForceSwitch = True
	Else
		ClickAway()

		$iWaitTime = _ArrayMax($g_aiTimeTrain, 1, 0, 2) ; Not check Siege Machine time: $g_aiTimeTrain[3]
		If $bReachAttackLimit And $iWaitTime <= 0 Then
			SetLog("This account has attacked twice in a row, switching to another account", $COLOR_INFO)
			SetSwitchAccLog(" - Reach attack limit: " & $g_aiAttackedCount - $g_aiAttackedCountSwitch[$g_iCurAccount])
			$bForceSwitch = True
		EndIf
	EndIf

	SetDebugLog("-Normal Switch-")
	$g_iNextAccount = $g_iCurAccount + 1
	If $g_iNextAccount > $g_iTotalAcc Then $g_iNextAccount = 0
	While $abAccountNo[$g_iNextAccount] = False
		$g_iNextAccount += 1
		If $g_iNextAccount > $g_iTotalAcc Then $g_iNextAccount = 0 ; avoid idle Account
		SetDebugLog("- While Account: " & $g_asProfileName[$g_iNextAccount] & " number: " & $g_iNextAccount + 1)
	WEnd
	
	If Not $g_bRunState Then Return

	SetDebugLog("- Current Account: " & $g_asProfileName[$g_iCurAccount] & " number: " & $g_iCurAccount + 1)
	SetDebugLog("- Next Account: " & $g_asProfileName[$g_iNextAccount] & " number: " & $g_iNextAccount + 1)

	If $g_iNextAccount <> $g_iCurAccount Then
		CheckMainScreen(True, $g_bStayOnBuilderBase, "CheckSwitchAcc")
		PullSharedPrefs()
		SwitchCOCAcc($g_iNextAccount)
	Else
		SetLog("Staying in this account")
		SetSwitchAccLog("Stay at [" & $g_iCurAccount + 1 & "]", $COLOR_SUCCESS)
	EndIf
	
	$g_bForceSwitch = false ; reset the need to switch
EndFunc   ;==>CheckSwitchAcc

Func SwitchCOCAcc($NextAccount = 0, $bTest = False)
	Local $abAccountNo = AccountNoActive()
	If $NextAccount < 0 And $NextAccount > $g_iTotalAcc Then $NextAccount = _ArraySearch(True, $abAccountNo)
	Static $iRetry = 0
	Local $bResult
	If Not $g_bRunState Then Return

	SetLog("Switching to Account [" & $NextAccount + 1 & "] " & $g_asProfileName[$NextAccount])
	checkMainScreen(True, $g_bStayOnBuilderBase, "SwitchCOCAcc")
	Local $bSharedPrefs = $g_bChkSharedPrefs And HaveSharedPrefs($g_asProfileName[$g_iNextAccount])
	If $bSharedPrefs And $g_PushedSharedPrefsProfile = $g_asProfileName[$g_iNextAccount] Then
		; shared prefs already pushed
		$bResult = True
		$bSharedPrefs = False ; don't push again
		SetLog("Profile shared_prefs already pushed")
		If Not $g_bRunState Then Return
	ElseIf $bSharedPrefs Then 
		$bResult = True
	Else
		
		If IsMainPage() Then Click($aButtonSetting[0], $aButtonSetting[1], 1, 0, "Click Setting")
		If _Sleep(1000) Then Return
			
		If Not IsSettingPage() Then 
			SetLog("Cannot verify Setting page!", $COLOR_ERROR)
			$bResult = False
		EndIf
		
		For $i = 1 To 5 
			SetLog("Verifying SCID Windows #" & $i, $COLOR_ACTION)
			If ClickSCIDReload() Then ExitLoop
			If _Sleep(500) Then Return
		Next
		
		If ClickAccountSCID($NextAccount + 1) Then
			$bResult = True
			SetLog("Successfully Switch to Account " & $NextAccount + 1, $COLOR_SUCCESS)
		EndIf
	EndIf
	
	If $bTest Then Return
	
	If Not $g_bRunState Then Return
	If $bResult Then
		$iRetry = 0
		$g_bReMatchAcc = False
		If Not $g_bRunState Then Return
		If Not $g_bInitiateSwitchAcc Then SwitchAccountVariablesReload("Save")
		If $g_ahTimerSinceSwitched[$g_iCurAccount] <> 0 Then
			If Not $g_bReMatchAcc Then SetSwitchAccLog(" - Acc " & $g_iCurAccount + 1 & ", online: " & Int(__TimerDiff($g_ahTimerSinceSwitched[$g_iCurAccount]) / 1000 / 60) & "m")
			SetTime(True)
			$g_aiRunTime[$g_iCurAccount] += __TimerDiff($g_ahTimerSinceSwitched[$g_iCurAccount])
			$g_ahTimerSinceSwitched[$g_iCurAccount] = 0
		EndIf

		$g_iCurAccount = $NextAccount
		SwitchAccountVariablesReload()

		$g_ahTimerSinceSwitched[$g_iCurAccount] = __TimerInit()
		$g_bInitiateSwitchAcc = False
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
			;PushSharedPrefs()
			OpenCoC()
			;waitMainScreen()
		EndIf

		SetSwitchAccLog("Switched to Acc [" & $NextAccount + 1 & "]", $COLOR_SUCCESS)
		CreateLogFile() ; Cause use of the right log file after switch
		If Not $g_bRunState Then Return
	Else
		$iRetry += 1
		$g_bReMatchAcc = True
		SetLog("Switching account failed!", $COLOR_ERROR)
		SetSwitchAccLog("Switching to Acc " & $NextAccount + 1 & " Failed!", $COLOR_ERROR)
		If $iRetry <= 3 Then
			Click(1, 1, 2, 500)
			CheckMainScreen(True, $g_bStayOnBuilderBase, "SwitchCOCAcc")
		Else
			$iRetry = 0
			UniversalCloseWaitOpenCoC()
		EndIf
		If Not $g_bRunState Then Return
	EndIf
	
	waitMainScreen()
	If Not $g_bRunState Then Return

	If $g_bForceSinglePBLogoff Then $g_bGForcePBTUpdate = True
	
	If $g_bDeleteLogs Then DeleteFiles($g_sProfileLogsPath, "*.*", $g_iDeleteLogsDays, 0)
	If $g_bDeleteLoots Then DeleteFiles($g_sProfileLootsPath, "*.*", $g_iDeleteLootsDays, 0)
	If $g_bDeleteTemp Then
		DeleteFiles($g_sProfileTempPath, "*.*", $g_iDeleteTempDays, 0)
		DeleteFiles($g_sProfileTempDebugPath, "*.*", $g_iDeleteTempDays, 0, $FLTAR_RECUR)
	EndIf
	
	
	checkversion()
	runBot()

EndFunc   ;==>SwitchCOCAcc

Func ClickSCIDReload()
	Local $bRet = False
	If Not $g_bRunState Then Return
	
	If QuickMIS("BFI", $g_sImgSupercellIDReload, 550, 110, 630, 200) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(1000) Then Return
		$bRet = True
	EndIf
	Return $bRet
EndFunc   ;==>ClickSCIDSwitchID

Func ClickAccountSCID($iAccount = 2)
	Local $bRet = False
	Local $aAccount, $x, $y, $aDel[1] = [0]
	If Not $g_bRunState Then Return

	For $i = 1 To 5
		If QuickMIS("BFI", $g_sImgSupercellIDWindows, 550, 60, 760, 160) Then
			SetLog("Supercell ID Switch Window verified", $COLOR_SUCCESS)
			ExitLoop
		EndIf
		If _Sleep(500) Then Return
	Next
	
	If Not $g_bRunState Then Return
	For $i = 1 To 5
		If _ColorCheck(_GetPixelColor(666, 330, True), Hex(0xF2F2F2, 6), 10, Default, "Verify SCID First Account") Then
			SetLog("First Account is on top is verified", $COLOR_SUCCESS)
			ExitLoop
		Else
			ClickDrag(666, 330, 666, 630)
		EndIf
		If _Sleep(500) Then Return
	Next
	
	If Not $g_bRunState Then Return
	If $iAccount > 3 And $iAccount < 7 Then ClickDragSCID(1) ;Account 4,5,6
	If $iAccount > 6 And $iAccount < 10 Then ClickDragSCID(2) ;Account 7,8,9
	If $iAccount > 9 And $iAccount < 13 Then ClickDragSCID(3) ;Account 10,11,12
	If $iAccount > 12 And $iAccount < 16 Then ClickDragSCID(4) ;Account 13,14,15
	If $iAccount > 15 Then ClickDragSCID(5) ;Account 16
	
	If _Sleep(500) Then Return
	If Not $g_bRunState Then Return
	
	Local $bBottomPage = False
	If QuickMIS("BC1", $g_sImgSupercellIDBottomPage, 500, 580, 560, 630) Then $bBottomPage = True
	
	;lets check TownHall Text
	$aAccount = QuickMIS("CNX", $g_sImgSupercellIDTown, 560, 400, 577, 650)
	If IsArray($aAccount) And UBound($aAccount) > 0 Then
		_ArraySort($aAccount, 0, 0, 0, 2)
		SetLog("Detected account : " & UBound($aAccount), $COLOR_INFO)
		
		Local $iTmpY = 0, $iDistance = 50
		For $i = 0 To UBound($aAccount) - 1
			If $aAccount[$i][2] - $iTmpY > $iDistance Then
				$iTmpY = $aAccount[$i][2]
			Else
				_ArrayAdd($aDel, $i)
			EndIf
		Next
		
		$aDel[0] = UBound($aDel) - 1
		_ArrayDelete($aAccount, $aDel) 
		_ArraySort($aAccount, 0, 0, 0, 2) 
		
		For $i = 0 To UBound($aAccount) - 1
			SetLog("Bottom Splitter on : " & $aAccount[$i][1] & "," & $aAccount[$i][2], $COLOR_DEBUG)
		Next
		
		If Not $g_bRunState Then Return
		Switch $iAccount
			Case 1, 4, 7, 10, 13, 16
				$x = $aAccount[0][1] + 100
				$y = $aAccount[0][2] - 35				
				;we should click most top account among 3 choice, but we only have 2 account. so select the most bottom
				If UBound($aAccount) = 2 And $bBottomPage And $iAccount = $g_iTotalAcc + 1 Then 
					SetLog("attention : we need to select account " & $iAccount, $COLOR_DEBUG2)
					SetLog("normally account " & $iAccount & " is on first position", $COLOR_DEBUG2)
					SetLog("but we have 2 choice and reach bottom page on scid screen", $COLOR_DEBUG2)
					SetLog("bot will select the most bottom account", $COLOR_DEBUG2)
					$x = $aAccount[1][1] + 100
					$y = $aAccount[1][2] - 35
				EndIf
			Case 2, 5, 8, 11, 14
				$x = $aAccount[1][1] + 100
				$y = $aAccount[1][2] - 35
			Case 3, 6, 9, 12, 15
				$x = $aAccount[2][1] + 100
				$y = $aAccount[2][2] - 35
		EndSwitch
		
		If Not $g_bRunState Then Return
		SetLog("Click Account : [" & $iAccount & "] " & $g_asProfileName[$iAccount-1] & " on " & $x & "," & $y, $COLOR_ACTION)
		Click($x, $y)
		$bRet = True
		SetLog("Please Wait", $COLOR_INFO)
		If _SleepStatus(10000) Then Return
	EndIf
	
	Return $bRet
EndFunc ;ClickAccountSCID

Func ClickDragSCID($iCount = 1)
	For $i = 1 To $iCount 
		ClickDrag(666, 634, 666, 330)
		If _Sleep(500) Then Return
	Next
EndFunc ;ClickDragSCID

Func aquireSwitchAccountMutex($iSwitchAccountGroup = $g_iCmbSwitchAcc, $bReturnOnlyMutex = False, $bShowMsgBox = False)
	Local $sMsg = GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Msg_SwitchAccounts_InUse", "My Bot with Switch Accounts Group %s is already in use or active.", $iSwitchAccountGroup)
	If $iSwitchAccountGroup Then
		Local $hMutex_Profile = 0
		If $g_ahMutex_SwitchAccountsGroup[0] = $iSwitchAccountGroup And $g_ahMutex_SwitchAccountsGroup[1] Then
			$hMutex_Profile = $g_ahMutex_SwitchAccountsGroup[1]
		Else
			$hMutex_Profile = CreateMutex(StringReplace($g_sProfilePath & "\SwitchAccount.0" & $iSwitchAccountGroup, "\", "-"))
			$g_ahMutex_SwitchAccountsGroup[0] = $iSwitchAccountGroup
			$g_ahMutex_SwitchAccountsGroup[1] = $hMutex_Profile
		EndIf
		;SetDebugLog("Aquire Switch Accounts Group " & $iSwitchAccountGroup & " Mutex: " & $hMutex_Profile)
		If $bReturnOnlyMutex Then
			Return $hMutex_Profile
		EndIf

		If $hMutex_Profile = 0 Then
			; mutex already in use
			SetLog($sMsg, $COLOR_ERROR)
			;SetLog($sMsg, "Cannot switch to profile " & $sProfile, $COLOR_ERROR)
			If $bShowMsgBox Then
				MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION, $MB_TOPMOST), $g_sBotTitle, $sMsg)
			EndIf
		EndIf
		Return $hMutex_Profile <> 0
	EndIf
	Return False
EndFunc   ;==>aquireSwitchAccountMutex

Func releaseSwitchAccountMutex()
	If $g_ahMutex_SwitchAccountsGroup[1] Then
		;SetDebugLog("Release Switch Accounts Group " & $g_ahMutex_SwitchAccountsGroup[0] & " Mutex: " & $g_ahMutex_SwitchAccountsGroup[1])
		ReleaseMutex($g_ahMutex_SwitchAccountsGroup[1])
		$g_ahMutex_SwitchAccountsGroup[0] = 0
		$g_ahMutex_SwitchAccountsGroup[1] = 0
		Return True
	EndIf
	Return False
EndFunc   ;==>releaseSwitchAccountMutex

Func SwitchAccountCheckProfileInUse($sNewProfile)
	; now check if profile is used in another group
	Local $sInGroups = ""
	For $g = 1 To 8
		If $g = $g_iCmbSwitchAcc Then ContinueLoop
		; find group this profile belongs to: no switch profile config is saved in config.ini on purpose!
		Local $sSwitchAccFile = $g_sProfilePath & "\SwitchAccount.0" & $g & ".ini"
		If FileExists($sSwitchAccFile) = 0 Then ContinueLoop
		Local $sProfile
		Local $bEnabled
		For $i = 1 To Int(IniRead($sSwitchAccFile, "SwitchAccount", "TotalCocAccount", 0)) + 1
			$bEnabled = IniRead($sSwitchAccFile, "SwitchAccount", "Enable", "") = "1"
			If $bEnabled Then
				$bEnabled = IniRead($sSwitchAccFile, "SwitchAccount", "AccountNo." & $i, "") = "1"
				If $bEnabled Then
					$sProfile = IniRead($sSwitchAccFile, "SwitchAccount", "ProfileName." & $i, "")
					If $sProfile = $sNewProfile Then
						; found profile
						If $sInGroups <> "" Then $sInGroups &= ", "
						$sInGroups &= $g
					EndIf
				EndIf
			EndIf
		Next
	Next

	If $sInGroups Then
		If StringLen($sInGroups) > 2 Then
			$sInGroups = "used in groups " & $sInGroups
		Else
			$sInGroups = "used in group " & $sInGroups
		EndIf
	EndIf

	; test if profile can be aquired
	Local $iAquired = aquireProfileMutex($sNewProfile)
	If $iAquired Then
		If $iAquired = 1 Then
			; ok, release again
			releaseProfileMutex($sNewProfile)
		EndIf

		If $sInGroups Then
			; write to log
			SetLog("Profile " & $sNewProfile & " not active, but " & $sInGroups & "!", $COLOR_ERROR)
			SetSwitchAccLog($sNewProfile & " " & $sInGroups & "!", $COLOR_ERROR)
			Return False
		EndIf

		Return True
	Else
		; write to log
		If $sInGroups Then
			SetLog("Profile " & $sNewProfile & " active and " & $sInGroups & "!", $COLOR_ERROR)
			SetSwitchAccLog($sNewProfile & " active & " & $sInGroups & "!", $COLOR_ERROR)
		Else
			SetLog("Profile " & $sNewProfile & " active in another bot instance!", $COLOR_ERROR)
			SetSwitchAccLog($sNewProfile & " active!", $COLOR_ERROR)
		EndIf
		Return False
	EndIf
EndFunc   ;==>SwitchAccountCheckProfileInUse
