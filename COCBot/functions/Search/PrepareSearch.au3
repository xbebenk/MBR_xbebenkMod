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
Func PrepareSearch($bTest = False) ;Click attack button and find match button, will break shield

	SetLog("Going to Attack", $COLOR_INFO)
	$g_bRestart = False ;reset
	If Not $g_bRunState Then Return

	ChkAttackCSVConfig()
	
	checkChatTabPixel()
	If ClickB("AttackButton") Then
		If $g_bDebugSetLog Then SetLog("Opening Multiplayer Tab!", $COLOR_ACTION)
		If _Sleep(1000) Then Return
	Else
		SetLog("AttackButton Not Found!", $COLOR_DEBUG2)
		$g_bRestart = True
		Return
	EndIf	
	
	For $i = 1 To 5
		If IsMultiplayerTabOpen() Then 
			SetLog("Multiplayer Tab is Opened", $COLOR_DEBUG)
			If QuickMIS("BC1", $g_sImgRevengeTutor, 370, 85, 460, 160) Then ;check for arrow on ranked battle layout and Reinforcement
				If Not CheckRevengeTutor() Then ContinueLoop
			EndIf
			ExitLoop
		Else
			SetLog("Couldn't Multiplayer Window after click attack button!", $COLOR_DEBUG2)
			If _Sleep(5000) Then Return
			If CheckRevengeTutor() Then ExitLoop
			$g_bRestart = True
			Return
		EndIf
		If _Sleep(1000) Then Return
	Next
	
	Local $aButton, $bTournament = False, $aMatch
	
	If $g_bEnableTournament Then 
		For $i = 1 To 20 
			If Not $g_bRunState Then Return
			If _Sleep(50) Then Return
			SetDebugLog("Search for FindMatch Button #" & $i, $COLOR_ACTION)
			$aButton = QuickMIS("CNX", $g_sImgTournamentSearch, 325, 435, 540, 500)
			If IsArray($aButton) And UBound($aButton) > 0 Then
				For $z = 0 To UBound($aButton) - 1
					If $aButton[$z][0] = "SignUp" Then
						SetLog("Found SignUp Button", $COLOR_DEBUG)
						Click($aButton[$z][1], $aButton[$z][2], 1, 0, "SignUp Tournament")
						If _Sleep(1500) Then Return
						If QuickMIS("BC1", $g_sImgTournamentSearch, 500, 460, 710, 530) Then
							Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "SignUp Tournament [2]")
							SetLog("SignIn/Join Tournament, lets wait", $COLOR_ACTION)
							ContinueLoop 2
						EndIf
					EndIf
					If $aButton[$z][0] = "SignedUp" Then
						SetLog("Found SignedUp Button", $COLOR_DEBUG)
						SetLog("SignedUp, Preparing Tournament", $COLOR_INFO)
						If _Sleep(500) Then Return
						ExitLoop 2
					EndIf
					If $aButton[$z][0] = "Completed" Then
						SetLog("All Tournament Attack done", $COLOR_DEBUG2)
						If _Sleep(500) Then Return
						ExitLoop 2
					EndIf
					If $aButton[$z][0] = "Match" Then
						SetLog("Found Tournament Match Button", $COLOR_DEBUG)
						$aMatch = getMatchRemain()
						If UBound($aMatch) > 0 Then
							SetLog("Tournament match: " & $aMatch[0] & "/" & $aMatch[1], $COLOR_INFO)
							SetLog("Match remain: " & $aMatch[1] - $aMatch[0], $COLOR_INFO)
							If $aMatch[1] - $aMatch[0] = 0 Then 
								SetLog("All Tournament Attack used", $COLOR_DEBUG2)
								ExitLoop 2
							EndIf
						EndIf
						Click($aButton[$z][1], $aButton[$z][2], 1, 0, "Find a Match Tournament")
						$g_bLeagueAttack = True
						$bTournament = True
						If _Sleep(1000) Then Return
						If Not PrepareSearchCheckArmy($g_bLeagueAttack, $bTest) Then ExitLoop 2
						ExitLoop 2
					EndIf
				Next
			EndIf
		Next
	EndIf
	
	Local $bAttackButtonFound = False
	If Not $bTournament Then 
		$bAttackButtonFound = _ColorCheck(_GetPixelColor(255, 488, True), Hex(0xF1A522, 6), 10, Default, "FindMatch")
		If $bAttackButtonFound Then
			Click(160, 460, 1, 0, "FindMatch")
			$g_bLeagueAttack = False
			If _Sleep(1000) Then Return
			If Not PrepareSearchCheckArmy($bTournament, $bTest) Then Return
		Else
			SetLog("FindMatch Not Found!", $COLOR_DEBUG2)
			$g_bRestart = True
			Return
		EndIf
	EndIf
	
	If Not $bAttackButtonFound And Not $bTournament Then
		SetLog("Cannot Find Match Button on Multiplayer Window", $COLOR_ERROR)
		$g_bRestart = True
		Return
	EndIf
	
	$g_bCloudsActive = True ; early set of clouds to ensure no android suspend occurs that might cause infinite waits
	
	If $g_iTownHallLevel <> "" And $g_iTownHallLevel > 0 Then
		$g_iSearchCost += $g_aiSearchCost[$g_iTownHallLevel - 1]
		$g_iStatsTotalGain[$eLootGold] -= $g_aiSearchCost[$g_iTownHallLevel - 1]
	EndIf
	UpdateStats()

	If $g_bRestart Then ; If we have one or both errors, Then Return
		$g_bIsClientSyncError = False ; reset fast restart flag to stop OOS mode, collecting resources etc.
		Return
	EndIf
	
EndFunc   ;==>PrepareSearch

Func PrepareSearchCheckArmy($bTournament = False, $bTest = False)
	Local $bRet = False
	For $i = 1 To 3
		SetLog("Checking ArmyOverview Window", $COLOR_DEBUG)
		If WaitforPixel(695, 500, 696, 501, "C2ED91", 20, 1) Then
			SetArmyCompo($bTournament)
			If _Sleep(500) Then Return
			FillArmyCamp()
			If _Sleep(500) Then Return
			If $bTest Then Return $bRet
			Click(695, 500, 1, 0, "ArmyOverview Attack Button")
			If _Sleep(1000) Then Return
			If IsOKCancelPage(True) Then 
				Click(535, 410, 1, 0, "Confirm Attack OK")
			EndIf
			$bRet = True
			If _Sleep(2000) Then Return
		EndIf
		If _Sleep(500) Then Return
		If IsAttackPage(False, 1) Then ExitLoop
	Next
	
	Return $bRet
EndFunc

Func SetArmyCompo($bTournament = False)
	Local $x = 510, $Color = Hex(0xB69881, 6)
	Local $yArmy1 = 200, $yArmy2 = 254, $yArmy3 = 308, $yArmy4 = 361
	Local $yCheck = 0, $iUseArmy = $g_iCmbDBUseArmy
	
	If $bTournament Then $iUseArmy = $g_iTournamentUseArmy 
	Switch $iUseArmy
		Case 0
			$yCheck = $yArmy1
		Case 1
			$yCheck = $yArmy2
		Case 2
			$yCheck = $yArmy3
		Case 3
			$yCheck = $yArmy4
	EndSwitch
	
	If $bTournament Then
		SetLog("SetArmyCompo for Tournament", $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgSetArmyCompo, 490, 140, 530, 180) Then ;check selector button
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Click Selector")
			If WaitforPixel(510, 185, 510, 186, "73615A", 20, 1) Then ;wait selector popup
				If _ColorCheck(_GetPixelColor($x, $yCheck, True), $Color, 20, Default, "SetArmyCompo: " & $g_iTournamentUseArmy + 1) Then
					Click($x, $yCheck + 20, 1, 0, "Click Army " & $g_iTournamentUseArmy + 1)
					SetLog("Selecting Army Compo " & $g_iTournamentUseArmy + 1, $COLOR_SUCCESS)
					If _Sleep(1000) Then Return
					If IsOKCancelPage(True) Then 
						Click(535, 410, 1, 0, "Click Confirm")
					EndIf
				Else
					SetLog("Fail to verify Army Compo " & $g_iTournamentUseArmy + 1, $COLOR_DEBUG2)
				EndIf
			EndIf
		Else
			SetLog("No Set Army Compo Button Found", $COLOR_DEBUG2)
			Return
		EndIf
	Else
		SetLog("SetArmyCompo for Normal Attack", $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgSetArmyCompo, 490, 140, 530, 180) Then ;check selector button
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Click Selector")
			If WaitforPixel(510, 185, 510, 186, "73615A", 20, 1) Then ;wait selector popup
				If _ColorCheck(_GetPixelColor($x, $yCheck, True), $Color, 20, Default, "SetArmyCompo: " & $g_iCmbDBUseArmy + 1) Then
					Click($x, $yCheck + 20, 1, 0, "Click Army " & $g_iCmbDBUseArmy + 1)
					SetLog("Selecting Army Compo " & $g_iCmbDBUseArmy + 1, $COLOR_SUCCESS)
					If _Sleep(1000) Then Return
					If IsOKCancelPage(True) Then 
						Click(535, 410, 1, 0, "Click Confirm")
					EndIf
				Else
					SetLog("Fail to verify Army Compo " & $g_iCmbDBUseArmy + 1, $COLOR_DEBUG2)
				EndIf
			EndIf
		Else
			SetLog("No Set Army Compo Button Found", $COLOR_DEBUG2)
			Return
		EndIf
	EndIf
EndFunc

Func CloseMultiPlayerWindow()
	If IsMultiplayerTabOpen() Then 
		SetLog("Close Multiplayer Window", $COLOR_ACTION)
		ClickAway("Right")
		Return True
	EndIf
EndFunc

Func CheckRevengeTutor()
	Local $bRet = False
	
	If _ColorCheck(_GetPixelColor(299, 410, True), Hex(0xFFFFFF, 6), 20, Default, "CheckRevengeTutor") Or QuickMIS("BC1", $g_sImgRevengeTutor, 370, 85, 460, 160) Then
		SetLog("Found Multiplayer Tutorial", $COLOR_DEBUG)
		Click(300, 420, 1, 0, "Tutor Chat")
		
		For $i = 1 To 6
			SetLog("Waiting for Arrow #" & $i, $COLOR_ACTION)
			If QuickMIS("BC1", $g_sImgRevengeTutor, 370, 85, 460, 160) Then
				SetLog("Found Arrow Set Defense", $COLOR_DEBUG)
				Click(412, 182, 1, 0, "Button Setup Defense")
				If _Sleep(1000) Then Return
				ExitLoop
			EndIf
			
			If _ColorCheck(_GetPixelColor(299, 410, True), Hex(0xFFFFFF, 6), 20, Default, "WaitArrow") Then 
				Click(300, 420, 1, 0, "Tutor Chat")
				If _Sleep(3000) Then Return
			EndIf
			If _Sleep(1000) Then Return
		Next
		
		If _Sleep(2000) Then Return
		If QuickMIS("BC1", $g_sImgRevengeTutor, 30, 160, 100, 190) Then ;search Layout text
			SetLog("Set Default Defense Layout", $COLOR_ACTION)
			Local $aLayout = QuickMIS("CNX", $g_sImgRevengeTutor, 40, 320, 860, 370)
			Local $x, $y
			_ArraySort($aLayout, 0, 0, 0, 1)
			For $i = 0 To UBound($alayout) - 1
				$x = $aLayout[$i][1]
				$y = $aLayout[$i][2]
				If $i = 0 Then ;home base
					SetLog("Set Home Base Defense Layout", $COLOR_ACTION)
					Click($x + 40, $y - 30, 1, 0, "Defense Layout (Home Base)")
				Else
					If Not QuickMIS("BC1", $g_sImgRevengeTutor, $x + 160, 340, $x + 190, 360) Then
						SetLog("Set War Base Defense Layout", $COLOR_ACTION)
						If _Sleep(500) Then Return
						Click($x + 40, $y - 30, 1, 0, "Defense Layout (War Base)")
						ExitLoop
					Else
						SetLog("Not Set War Base (Layout need Update)", $COLOR_DEBUG2)
					EndIf
				EndIf
			Next
		EndIf
		
		If _ColorCheck(_GetPixelColor(299, 410, True), Hex(0xFFFFFF, 6), 20, Default, "WaitArrow") Then 
			Click(300, 420, 1, 0, "Tutor Chat")
			If _Sleep(3000) Then Return
		EndIf
		
		If QuickMIS("BC1", $g_sImgRevengeTutor, 765, 425, 800, 460) Then
			SetLog("Set Default Defense Troops", $COLOR_ACTION)
			Click(400, 500, 1, 0, "Defending Reinforcement")
			
			If _Sleep(1000) Then Return
			
			For $iTry = 1 To 2
				Local $aTroops = QuickMIS("CNX", $g_sImgTrainTroops, 22, 485, 460, 655) ;read all troops image 
				If IsArray($aTroops) And UBound($aTroops) > 0 Then
					_ArraySort($aTroops, 0, 0, 0, 1)
					
					For $i = 0 To UBound($aTroops) - 1
						Local $iTroopIndex = TroopIndexLookup($aTroops[$i][0])
						Local $sTroopName = GetTroopName($iTroopIndex)
						
						Switch $aTroops[$i][0]
							Case "Drag"
								TrainIt($iTroopIndex, 2, $g_iTrainClickDelay)
							Case "Ball"
								TrainIt($iTroopIndex, 7, $g_iTrainClickDelay)
						EndSwitch
						
						If Not QuickMIS("BC1", $g_sImgRevengeTutor, 765, 330, 800, 360) Then 
							Click(824, 26, 1, 0, "Close Train Troops")
							If _Sleep(1500) Then Return
							Click(825, 125, 1, 0, "Close Window")
							If _Sleep(1000) Then Return
							$bRet = True
							ExitLoop
						EndIf
					Next
				EndIf
			Next
		EndIf
	EndIf
	
	If _Sleep(1000) Then Return
	ClickAway("Right")
	Return $bRet
EndFunc ;==>CheckRevengeTutor