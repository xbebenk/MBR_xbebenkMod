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
Func PrepareSearch($bTest = False, $bDoClanGames = False) ;Click attack button and find match button, will break shield

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
	
	If $g_bEnableTournament And Not $g_bNoTournament And Not $bDoClanGames Then 
		For $i = 1 To 10 
			If Not $g_bRunState Then Return
			If _Sleep(50) Then Return
			SetDebugLog("Search for FindMatch Button #" & $i, $COLOR_ACTION)
			$aButton = QuickMIS("CNX", $g_sImgTournamentSearch, 325, 435, 540, 500)
			If IsArray($aButton) And UBound($aButton) > 0 Then
				RemoveDupCNX($aButton) ;remove duplicate button
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
	ElseIf $g_bNoTournament Then 
		SetLog("Enabled Tournament but no Attack", $COLOR_DEBUG2)		
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
			If _Sleep(200) Then Return
			SetArmyCompo($bTournament)
			If _Sleep(500) Then Return
			If FillArmyCamp() Then SaveArmyCompo($bTournament)
			If _Sleep(500) Then Return
			If $bTest Then Return $bRet
			Click(695, 500, 1, 0, "ArmyOverview Attack Button")
			If _Sleep(500) Then Return
			
			SetLog("Going Attack for: " & ($bTournament = True ? "League Attack" : "Normal Attack"), $COLOR_INFO)
			For $wait = 1 To 8
				SetDebugLog("Waiting attack page #" & $wait, $COLOR_DEBUG1)
				If IsOKCancelPage(True) Then 
					Click(535, 410, 1, 0, "Confirm Attack OK")
					If _Sleep(1000) Then Return
					ContinueLoop
				EndIf
				If IsAttackPage(False, 1) Then 
					$bRet = True
					ExitLoop 2
				EndIf
				If _Sleep(500) Then Return
			Next
		EndIf
		If _Sleep(500) Then Return
	Next
	
	Return $bRet
EndFunc

Func SaveArmyCompo($bTournament = False)
	Local $iUseArmy = $g_iCmbDBUseArmy
	Local $aClick[2][2] = [[760, 270], [760, 420]]
	
	If $bTournament Then $iUseArmy = $g_iTournamentUseArmy 
	If $iUseArmy > 1 Then ;can only click to save compo 1 or 2
		SetLog("Your Saved army compo need to be update", $COLOR_DEBUG2)
		SetLog("But we only can save compo to Army 1 or Army 2", $COLOR_DEBUG2)
		Return
	EndIf
	
	SetLog("Trying to save army compo for " & ($bTournament = True ? "Tournament" : "Normal Attack"), $COLOR_INFO)
	If QuickMIS("BC1", $g_sImgSaveArmyCompo, 280, 155, 300, 170) Then 
		Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Click Save Selector")
		If _Sleep(1000) Then Return
		If $iUseArmy = 0 Then
			Click($aClick[0][0], $aClick[0][1], 1, 0, "Save Army 1")
		Else
			Click($aClick[1][0], $aClick[1][1], 1, 0, "Save Army 2")
		EndIf
		If _Sleep(1000) Then Return
		SetLog("Saving Army to ArmyCompo : " & $iUseArmy + 1, $COLOR_DEBUG1)
		Click(190, 160, 1, 0, "Click My Army Tab")
	EndIf
EndFunc

Func FillArmyCamp()
	Local $bRet = False
	If $g_bIgnoreIncorrectTroopCombo Or $g_bIgnoreIncorrectSpellCombo Then ;check army or spell to fill
		If QuickMIS("BC1", $g_sImgArmyOverviewExclam, 300, 210, 480, 230) Then ;check on troops
			If QuickMIS("BC1", $g_sImgArmyOverviewExclam, 320, 270, 680, 295) Then ;check on acivate supertroop
				SetLog("SuperTroop Need to activate", $COLOR_DEBUG)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(500) Then Return
				If WaitforPixel(590, 490, 591, 490, "84CD2C", 20, 1) Then 
					SetLog("Activate Boost SuperTroop", $COLOR_DEBUG)
					Click(490, 450)
				EndIf				
			Else
				SetLog("Your troop need to fill", $COLOR_DEBUG)
				FillIncorrectTroopCombo()
				$bRet = True
				If _Sleep(500) Then Return
			EndIf
		EndIf
		
		If QuickMIS("BC1", $g_sImgArmyOverviewExclam, 300, 320, 480, 345) Then ;check on spells
			SetLog("Your spell need to fill", $COLOR_DEBUG)
			FillIncorrectSpellCombo()
			$bRet = True
			If _Sleep(500) Then Return
		EndIf
		
		If _Sleep(500) Then Return
		If Not $bRet Then ;need to check again for hero switch, but only set if Fill Troop/Spell not used before
			$bRet = CheckHeroOnUpgrade()
		Else
			CheckHeroOnUpgrade()
		EndIf
	EndIf
	Return $bRet
EndFunc

Func CheckHeroOnUpgrade()
	Local $bRet = False
	Local $aHammer, $x, $y, $aHero
	Local $bCheck = False, $bWardenFound = False
	Local $iWardenMode = $g_aiAttackUseWardenMode[$DB]
	If QuickMIS("BC1", $g_sImgArmyOverviewExclam, 86, 200, 120, 230) Then $bCheck = True
	If Not $bCheck Then Return
	
	$aHammer = QuickMIS("CNX", $g_sImgArmyOverviewHeroesHammer, 90, 233, 380, 260)
	If IsArray($aHammer) And UBound($aHammer) > 0 Then
		_ArraySort($aHammer, 0, 0, 0, 1) ;sort left to right
		RemoveDupCNX($aHammer, 1, 20)
		For $i = 0 To UBound($aHammer) - 1
			$x = $aHammer[$i][1]
			$y = $aHammer[$i][2]
			SetLog("Found Hammer on " & $x & "," & $y, $COLOR_DEBUG)
			Click($x, $y, 1, 0, "Hammer")
			If _Sleep(1000) Then Return
			$aHero = QuickMIS("CNX", $g_sImgArmyOverviewHeroChange, 86, 200, $x + 350, $y + 85)
			If IsArray($aHero) And UBound($aHero) > 0 Then
				For $i = 0 To UBound($aHero) - 1
					SetLog("Hero " & $aHero[$i][0] & " is Available", $COLOR_INFO)
					If StringInStr($aHero[$i][0], "Warden") Then
						$bWardenFound = True
						If $iWardenMode = 0 Or $iWardenMode = 2 Then ;0 or 2 = ground or default = pick ground
							If $aHero[$i][0] = "WardenGround" Then 
								Click($aHero[$i][1], $aHero[$i][2], 1, 0, "Click " & $aHero[$i][0])
								If _Sleep(1000) Then Return
								Click($x, $y, 1, 0, "Hammer")
								SetLog("Switch upgraded hero to " & $aHero[$i][0], $COLOR_SUCCESS)
								ExitLoop
							Else
								ContinueLoop
							EndIf
						Else ;iWardenMode = 1
							If $aHero[$i][0] = "WardenAir" Then 
								Click($aHero[$i][1], $aHero[$i][2], 1, 0, "Click " & $aHero[$i][0])
								If _Sleep(1000) Then Return
								Click($x, $y, 1, 0, "Hammer")
								SetLog("Switch upgraded hero to " & $aHero[$i][0], $COLOR_SUCCESS)
								ExitLoop
							EndIf
						EndIf
					Else
						Click($aHero[$i][1], $aHero[$i][2], 1, 0, "Click " & $aHero[$i][0])
						If _Sleep(1000) Then Return
						Click($x, $y, 1, 0, "Hammer")
						SetLog("Switch upgraded hero to " & $aHero[$i][0], $COLOR_SUCCESS)
						ExitLoop
					EndIf
				Next
				$bRet = True
				If Ubound($aHero) = 1 Then ExitLoop ;if only found 1 image then exit
				If $bWardenFound And Ubound($aHero) = 2 Then ExitLoop ;warden always found 2 image, so if 2 images then only warden, exit
			Else
				Click($x, $y, 1, 0, "Hammer Close")
				SetLog("No availabe Hero to switch", $COLOR_DEBUG2)
				ExitLoop
			EndIf
		Next
		If _Sleep(500) Then Return
		Return $bRet
	EndIf
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
			If WaitforPixel(510, 185, 510, 185, "73615A", 20, 2) Then ;wait selector popup
				If _ColorCheck(_GetPixelColor($x, $yCheck, True), $Color, 20, Default, "SetArmyCompo" & $g_iTournamentUseArmy + 1) Then
					Click($x, $yCheck + 20, 1, 0, "Click Army " & $g_iTournamentUseArmy + 1)
					SetLog("Selecting Army Compo " & $g_iTournamentUseArmy + 1, $COLOR_SUCCESS)
					If _Sleep(500) Then Return
					ConfirmOK()
				Else
					SetLog("Fail to verify Army Compo " & $g_iTournamentUseArmy + 1, $COLOR_DEBUG2)
					SetLog("Your Setting for Tournament Attack: Army" & $g_iTournamentUseArmy + 1, $COLOR_ERROR)
					SetLog("Cannot Find Army Compo " & $g_iTournamentUseArmy + 1 & " on your Saved Army", $COLOR_ERROR)
					SetLog("Cancel Selecting Saved Army", $COLOR_ERROR)
					Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Click Selector")
				EndIf
			Else
				SetLog("Fail to verify Selector is Open", $COLOR_DEBUG2)
				SetLog("Cancel Selecting Army Compo", $COLOR_DEBUG2)
				ClickAway()
			EndIf
		Else
			SetLog("No Set Army Compo Button Found", $COLOR_DEBUG2)
			Return
		EndIf
	Else
		SetLog("SetArmyCompo for Normal Attack", $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgSetArmyCompo, 490, 140, 530, 180) Then ;check selector button
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Click Selector")
			If WaitforPixel(510, 185, 510, 185, "73615A", 20, 2) Then ;wait selector popup
				If _ColorCheck(_GetPixelColor($x, $yCheck, True), $Color, 20, Default, "SetArmyCompo" & $g_iCmbDBUseArmy + 1) Then
					Click($x, $yCheck + 20, 1, 0, "Click Army " & $g_iCmbDBUseArmy + 1)
					SetLog("Selecting Army Compo " & $g_iCmbDBUseArmy + 1, $COLOR_SUCCESS)
					If _Sleep(500) Then Return
					ConfirmOK()
				Else
					SetLog("Fail to verify Army Compo " & $g_iCmbDBUseArmy + 1, $COLOR_DEBUG2)
					SetLog("Your Setting for Normal Attack: Army" & $g_iCmbDBUseArmy + 1, $COLOR_ERROR)
					SetLog("Cannot Find Army Compo " & $g_iCmbDBUseArmy + 1 & " on your Saved Army", $COLOR_ERROR)
					SetLog("Cancel Selecting Saved Army", $COLOR_ERROR)
					Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Click Selector")
				EndIf
			Else
				SetLog("Fail to verify Selector is Open", $COLOR_DEBUG2)
				SetLog("Cancel Selecting Army Compo", $COLOR_DEBUG2)
				ClickAway()
			EndIf
		Else
			SetLog("No Set Army Compo Button Found", $COLOR_DEBUG2)
			Return
		EndIf
	EndIf
EndFunc

Func ConfirmOK()
	For $i = 1 To 5
		SetLog("Waiting Confirm Message #" & $i, $COLOR_ACTION)
		If IsOKCancelPage(True) Then 
			Click(535, 410, 1, 0, "Click Confirm")
			SetLog("Confirm OK", $COLOR_DEBUG1)
			If _Sleep(500) Then Return
		EndIf
		If _ColorCheck(_GetPixelColor(785, 513, True), Hex(0xA2EB51, 6), 20, Default, "ConfirmOK: Attack Button") Then ExitLoop
		If _Sleep(500) Then Return
	Next
EndFunc

Func CloseMultiPlayerWindow()
	If IsMultiplayerTabOpen() Then 
		SetLog("Close Multiplayer Window", $COLOR_ACTION)
		ClickAway("Right")
		Return True
	EndIf
EndFunc

Func CheckRevengeTutor($bTest = False)
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
			SetLog("Set Default Defense Layout", $COLOR_INFO)
			Local $aLayout = QuickMIS("CNX", $g_sImgRevengeTutor, 40, 320, 860, 370)
			Local $x, $y
			RemoveDupCNX($aLayout, 1, 5)
			_ArraySort($aLayout, 0, 0, 0, 1)
			If $bTest Then _ArrayDisplay($aLayout, "Layout")
			For $i = 0 To UBound($aLayout) - 1
				$x = $aLayout[$i][1]
				$y = $aLayout[$i][2]
				If $i = 0 Then ;home base
					If QuickMIS("BC1", $g_sImgRevengeTutor, $x + 140, 320, $x + 200, 360) Then ;find image base need to re-layout (red home icon)
						SetLog("[" & $i + 1 & "] Base need layout Update, skip", $COLOR_DEBUG1)
						ContinueLoop
					EndIf
					SetLog("[" & $i + 1 & "] Set as Base Defense Layout", $COLOR_DEBUG1)
					Click($x + 40, $y - 30, 1, 0, "[" & $i + 1 & "] Defense Layout")
				Else
					If QuickMIS("BC1", $g_sImgRevengeTutor, $x + 140, 320, $x + 200, 360) Then ;find image base need to re-layout (red home icon)
						SetLog("[" & $i + 1 & "] Base need layout Update, skip", $COLOR_DEBUG1)
						ContinueLoop
					Else
						SetLog("[" & $i + 1 & "] Set as Base Defense Layout", $COLOR_DEBUG1)
						Click($x + 40, $y - 30, 1, 0, "[" & $i + 1 & "] Defense Layout")
						If _Sleep(500) Then Return
						ExitLoop
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