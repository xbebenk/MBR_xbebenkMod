; #FUNCTION# ====================================================================================================================
; Name ..........: PrepareSearch
; Description ...: Goes into searching for a match, breaks shield if it has to
; Syntax ........: PrepareSearch()
; Parameters ....:
; Return values .: None
; Author ........: Code Monkey #4
; Modified ......: KnowJack (Aug 2015), MonkeyHunter(2015-12), xbebenk(03-2024)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func PrepareSearch($Mode = $DB) ;Click attack button and find match button, will break shield

	SetLog("Going to Attack", $COLOR_INFO)
	$g_bRestart = False ;reset
	If Not $g_bRunState Then Return

	ChkAttackCSVConfig()
	If $Mode = $DT Then $g_bRestart = False
	
	checkChatTabPixel()
	For $i = 1 To 5
		
		If ClickB("AttackButton") Then
			If $g_bDebugSetLog Then SetLog("Opening Multiplayer Tab!", $COLOR_ACTION)
		Else
			SetLog("AttackButton Not Found!", $COLOR_ERROR)
			$g_bRestart = True
			Return
		EndIf
		
		If _Sleep(1000) Then Return
		If IsMultiplayerTabOpen() Then 
			SetDebugLog("Multiplayer Tab is Opened", $COLOR_DEBUG)
			ExitLoop
		Else
			If $i = 5 Then 
				SetLog("Couldn't Multiplayer Window after click attack button!", $COLOR_ERROR)
				AndroidPageError("IsMultiplayerTab")
				$g_bRestart = True
				Return
			EndIf
		EndIf
	Next
		

	Local $aButton, $bAttackButtonFound
	
	For $s = 1 To 20
		If Not $g_bRunState Then ExitLoop
		If _Sleep(1500) Then Return
		SetDebugLog("Search for attack Button #" & $s, $COLOR_ACTION)
		$aButton = QuickMIS("CNX", $g_sImgPrepareLegendLeagueSearch, 275,190,835,545)
		If IsArray($aButton) And UBound($aButton) > 0 Then
			$bAttackButtonFound = True
			For $i = 0 To UBound($aButton) - 1
				SetDebugLog("Found Attack Button: " & $aButton[$i][0], $COLOR_DEBUG)
				If StringInStr($aButton[$i][0], "Normal") Then
					$g_bLeagueAttack = False
					SetDebugLog("Click " & $aButton[$i][0] & " Attack Button", $COLOR_ACTION)
					Click($aButton[$i][1], $aButton[$i][2])
					For $k = 1 To 10 
						If _Sleep(1000) Then Return
						If QuickMIS("BC1", $g_sImgPrepareLegendLeagueSearch, $aButton[$i][1] - 50, $aButton[$i][2] - 50, $aButton[$i][1] + 50, $aButton[$i][2] + 50) Then 
							SetLog("Still see " & $aButton[$i][0], $COLOR_DEBUG)
							If $k > 5 Then ContinueLoop 2
						Else
							SetDebugLog("Attack Button" & $aButton[$i][0] & " is Gone", $COLOR_DEBUG)
							ExitLoop
						EndIf
					Next
					ExitLoop 2
				ElseIf StringInStr($aButton[$i][0], "Ended") Then
					SetLog("League Day ended already! Trying again later", $COLOR_INFO)
					$g_bRestart = True
					$g_bForceSwitch = True     ; set this switch accounts next check
					CloseMultiPlayerWindow()
					If _Sleep(1000) Then Return
					Return False
				ElseIf StringInStr($aButton[$i][0], "Made") Then
					SetLog("All Attacks already made! Returning home", $COLOR_INFO)
					$g_bRestart = True
					$g_bForceSwitch = True     ; set this switch accounts next check
					CloseMultiPlayerWindow()
					If _Sleep(1000) Then Return
					Return
				ElseIf StringInStr($aButton[$i][0], "Legend") Then
					Click($aButton[$i][1], $aButton[$i][2])
					$g_bLeagueAttack = True
					For $j = 0 To 10
						If _Sleep(500) Then Return
						If ClickB("ConfirmAttack") Then 
							ExitLoop 3
						Else
							If $j = 10 Then 
								SetLog("Couldn't find the confirm attack button!", $COLOR_ERROR)
								Return False
							EndIf
						EndIf
					Next
				ElseIf StringInStr($aButton[$i][0], "SignUp") Then
					SetLog("Sign-up to Legend League", $COLOR_INFO)
					Click($aButton[$i][1], $aButton[$i][2])
					If _Sleep(1000) Then Return
					For $i = 1 To 3
						If IsOKCancelPage() Then
							ClickP($aConfirmSurrender)
							SetLog("Sign-up to Legend League done", $COLOR_INFO)
							If _Sleep(1000) Then Return
							ExitLoop 2
						Else
							SetLog("Wait for OK Button to SignUp Legend League #" & $i, $COLOR_ACTION)
							If $i = 3 Then SetLog("Problem SignUp to Legend League", $COLOR_ERROR)
						EndIf
						If _Sleep(500) Then Return
					Next
					
				ElseIf StringInStr($aButton[$i][0], "Oppo", 0) Then
					SetLog("Finding opponents! Waiting 2 minutes and then try again to find a match", $COLOR_INFO)
					If ProfileSwitchAccountEnabled() Then 
						$g_bForceSwitch = True
						CloseMultiPlayerWindow()
						If _Sleep(1000) Then Return
						Return
					EndIf
					_SleepStatus(120000) ; Wait 2 mins before searching again
				EndIf
			Next
		EndIf
	Next
	
	If Not $bAttackButtonFound Then
		SetLog("Cannot Find Attack Button on Multiplayer Window", $COLOR_ERROR)
		SaveDebugImage("AttackButtonNotFound")
		$g_bRestart = True
		Return
	EndIf
	
	$g_bCloudsActive = True ; early set of clouds to ensure no android suspend occurs that might cause infinite waits
	
	If $g_iTownHallLevel <> "" And $g_iTownHallLevel > 0 Then
		$g_iSearchCost += $g_aiSearchCost[$g_iTownHallLevel - 1]
		$g_iStatsTotalGain[$eLootGold] -= $g_aiSearchCost[$g_iTownHallLevel - 1]
	EndIf
	UpdateStats()

	If _Sleep($DELAYPREPARESEARCH2) Then Return
	
	If IsAttackWhileShieldPage(False) Then ; check for shield window and then button to lose time due attack and click okay
		If WaitforPixel(435, 480, 438, 484, "6DBC1F", 10, 1, "PrepareSearch-Shield") Then
			Click(436, 482)
		EndIf
	EndIf

	Local $Result = getAttackDisable(346, 182) ; Grab Ocr for TakeABreak check

	If isGemOpen(True) Then ; Check for gem window open)
		If Not IsAttackPage() Then 
			SetLog(" Not enough gold to start searching!", $COLOR_ERROR)
			Click(623, 231, 1, 0, "#0151") ; Click close gem window "X"
			If _Sleep($DELAYPREPARESEARCH1) Then Return
			Click(789, 117, 1, 0, "#0152") ; Click close attack window "X"
			If _Sleep($DELAYPREPARESEARCH1) Then Return
			$g_bOutOfGold = True ; Set flag for out of gold to search for attack
		EndIf
	EndIf

	SetDebugLog("PrepareSearch exit check $g_bRestart= " & $g_bRestart & ", $g_bOutOfGold= " & $g_bOutOfGold, $COLOR_DEBUG)

	If $g_bRestart Or $g_bOutOfGold Then ; If we have one or both errors, then return
		$g_bIsClientSyncError = False ; reset fast restart flag to stop OOS mode, collecting resources etc.
		Return
	EndIf
	
EndFunc   ;==>PrepareSearch

Func CloseMultiPlayerWindow()
	If IsMultiplayerTabOpen() Then 
		SetLog("Close Multiplayer Window", $COLOR_ACTION)
		Click(790, 114)
		Return True
	EndIf
EndFunc