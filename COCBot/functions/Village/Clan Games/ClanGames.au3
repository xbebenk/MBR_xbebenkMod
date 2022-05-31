; #FUNCTION# ====================================================================================================================
; Name ..........: Clan Games
; Description ...: This file contains the Clan Games algorithm
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: ViperZ And Uncle Xbenk 01-2018
; Modified ......: ProMac 02/2018 [v2 and v3] , ProMac 08/2018 v4 , GrumpyHog 08/2020
; Remarks .......: This file is part of MyBotRun. Copyright 2018
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================
Func _ClanGames($test = False, $bSearchBBEventFirst = $g_bChkForceBBAttackOnClanGames, $OnlyPurge = False)
	$g_bIsBBevent = False ;just to be sure, reset to false
	$g_bIsCGEventRunning = False ;just to be sure, reset to false
	$g_bForceSwitchifNoCGEvent = False ;just to be sure, reset to false
	$g_bIsCGPointAlmostMax = False ;just to be sure, reset to false
	$g_bisCGPointMaxed = False ;just to be sure, reset to false
	Local $PurgeDayMinute = ($g_iCmbClanGamesPurgeDay + 1) * 1440
	; Check If this Feature is Enable on GUI.
	If Not $g_bChkClanGamesEnabled Then Return
	If $g_iTownHallLevel <= 5 Then
		SetLog("TownHall Level : " & $g_iTownHallLevel & ", Skip Clan Games", $COLOR_INFO)
		Return
	Endif
	
	;Prevent checking clangames before date 22 (clangames should start on 22 and end on 28 or 29) depends on how many tiers/maxpoint
	Local $currentDate = Number(@MDAY)
	If $currentDate < 22 And $currentDate < 5 Then
		SetLog("Current date : " & $currentDate & ", Skip Clan Games", $COLOR_INFO)
		Return
	EndIf
	
	Local $sINIPath = StringReplace($g_sProfileConfigPath, "config.ini", "ClanGames_config.ini")
	If Not FileExists($sINIPath) Then ClanGamesChallenges("", True, $sINIPath, $g_bChkClanGamesDebug)

	If CloseClangamesWindow() Then _Sleep(1000)
	If CheckMainScreen(False, $g_bStayOnBuilderBase, "ClanGames") Then ZoomOut()
	If _Sleep(500) Then Return
	SetLog("Entering Clan Games", $COLOR_INFO)
	If Not $g_bRunState Then Return
	; Local and Static Variables
	Local $TabChallengesPosition[2] = [820, 130]
	Local $sTimeRemain = "", $sEventName = "", $getCapture = True
	Local Static $YourAccScore[16][2] = [[-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], _
										[-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True]]

	; Initial Timer
	Local $hTimer = TimerInit()
	Local $iWaitPurgeScore = 150
	
	; Enter on Clan Games window
	If IsClanGamesWindow() Then
		; Let's selected only the necessary images
		Local $sImagePath = @ScriptDir & "\imgxml\Resources\ClanGamesImages\Challenges"
		Local $sTempPath = @TempDir & "\" & $g_sProfileCurrentName & "\Challenges\"

		;Remove All previous file (in case setting changed)
		DirRemove($sTempPath, $DIR_REMOVE)

		If $g_bChkClanGamesLoot Then ClanGameImageCopy($sImagePath, $sTempPath, "L") ;L for Loot
		If $g_bChkClanGamesBattle Then ClanGameImageCopy($sImagePath, $sTempPath, "B") ;B for Battle
		If $g_bChkClanGamesDes Then ClanGameImageCopy($sImagePath, $sTempPath, "D") ;D for Destruction
		If $g_bChkClanGamesAirTroop Then ClanGameImageCopy($sImagePath, $sTempPath, "A") ;A for AirTroops
		If $g_bChkClanGamesGroundTroop Then ClanGameImageCopy($sImagePath, $sTempPath, "G") ;G for GroundTroops

		If $g_bChkClanGamesMiscellaneous Then ClanGameImageCopy($sImagePath, $sTempPath, "M") ;M for Misc
		If $g_bChkClanGamesSpell Then ClanGameImageCopy($sImagePath, $sTempPath, "S") ;S for GroundTroops
		If $g_bChkClanGamesBBBattle Then ClanGameImageCopy($sImagePath, $sTempPath, "BBB") ;BBB for BB Battle
		If $g_bChkClanGamesBBDes Then ClanGameImageCopy($sImagePath, $sTempPath, "BBD") ;BBD for BB Destruction
		If $g_bChkClanGamesBBTroops Then ClanGameImageCopy($sImagePath, $sTempPath, "BBT") ;BBT for BB Troops

		;now we need to copy selected challenge before checking current running event is not wrong event selected

		; Let's get some information , like Remain Timer, Score and limit
		If Not _ColorCheck(_GetPixelColor(300, 236, True), Hex(0x52DF50, 6), 5) Then ;no greenbar = there is active event or completed event
			_Sleep(3000) ; just wait few second, as completed event will need sometime to animate on score
		EndIf

		Local $aiScoreLimit = GetTimesAndScores()
		Local $sTimeCG
		If $aiScoreLimit = -1 Or UBound($aiScoreLimit) <> 2 Then
			CloseClangamesWindow() ;need clickaway, as we are leaving
			Return False
		Else
			SetLog("Your Score is: " & $aiScoreLimit[0], $COLOR_INFO)
			If _Sleep(500) Then Return
			$sTimeCG = ConvertOCRTime("ClanGames()", StringLower($g_sClanGamesTimeRemaining), True)
			Setlog("Clan Games Minute Remain: " & $sTimeCG)
			
			If $aiScoreLimit[0] = $aiScoreLimit[1] Then
				SetLog("Your score limit is reached! Congrats")
				$g_bIsCGPointMaxed = True
				CloseClangamesWindow()
				Return False
			ElseIf $aiScoreLimit[0] + $iWaitPurgeScore > $aiScoreLimit[1] Then
				SetLog("You almost reached max point")
				$g_bIsCGPointAlmostMax = True
				If $g_bChkClanGamesStopBeforeReachAndPurge And $sTimeCG > $PurgeDayMinute Then ; purge, but not purge on last day of clangames
					If IsEventRunning() Then Return True
					If $g_bChkClanGamesPurgeAny Then
						SetLog("Clangames remain time: " & $sTimeCG & " > " & $PurgeDayMinute, $COLOR_INFO)
						SetLog("Stop before completing and only Purge", $COLOR_INFO)
						Local $aEvent = FindEventToPurge($sTempPath)
						If IsArray($aEvent) And UBound($aEvent) > 0 Then
							Local $EventName = StringSplit($aEvent[0][0], "-")
							SetLog("Detected Event to Purge: " & $EventName[2])
							Click($aEvent[0][1], $aEvent[0][2])
							If _Sleep(1500) Then Return
							StartsEvent($EventName[2], True)
						Else
							ForcePurgeEvent(False, True) ; maybe will never hit here, but..
						EndIf
						CloseClangamesWindow()
						Return False
					EndIf
				EndIf
			EndIf
			If $YourAccScore[$g_iCurAccount][0] = -1 Then $YourAccScore[$g_iCurAccount][0] = $aiScoreLimit[0]
		EndIf
	Else
		CloseClangamesWindow()
		Return False
	EndIf

	;check cooldown purge
	If CooldownTime() Then Return False
	If Not $g_bRunState Then Return ;trap pause or stop bot
	If IsEventRunning() Then Return True
	If Not $g_bRunState Then Return ;trap pause or stop bot
	UpdateStats()

	If $OnlyPurge Then
		SetLog("OnlyPurge before switch Account", $COLOR_INFO)
		Local $aEvent = FindEventToPurge($sTempPath)
		If IsArray($aEvent) And UBound($aEvent) > 0 Then
			Local $EventName = StringSplit($aEvent[0][0], "-")
			SetLog("Detected Event to Purge: " & $EventName[2])
			Click($aEvent[0][1], $aEvent[0][2])
			If _Sleep(1500) Then Return
			StartsEvent($EventName[2], True, $getCapture, $g_bChkClanGamesDebug, True)
		EndIf
		If _Sleep(1500) Then Return
		CloseClangamesWindow()
		Return False
	EndIf

	Local $HowManyImages = _FileListToArray($sTempPath, "*", $FLTA_FILES)
	If IsArray($HowManyImages) Then
		Setlog($HowManyImages[0] & " Events to search")
	Else
		Setlog("ClanGames-Error on $HowManyImages: " & @error)
		CloseClangamesWindow()
		Setlog("Please check your clangames settings!", $COLOR_ERROR)
		Setlog("Expand the Challenge!", $COLOR_ERROR)
		SetLog("Enable any event that your account can do!", $COLOR_ERROR)
		Return False
	EndIf

	Local $aAllDetectionsOnScreen = FindEvent()

	Local $aSelectChallenges[0][5]

	If UBound($aAllDetectionsOnScreen) > 0 Then
		For $i = 0 To UBound($aAllDetectionsOnScreen) - 1
            ;If IsBBChallenge($aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3]) and $g_bChkClanGamesBBBattle == 0 and $g_bChkClanGamesBBDes == 0 Then ContinueLoop ; only skip if it is a BB challenge not supported

			Switch $aAllDetectionsOnScreen[$i][0]
				Case "L"
					If Not $g_bChkClanGamesLoot Then ContinueLoop
					;[0] = Path Directory , [1] = Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					Local $LootChallenges = ClanGamesChallenges("$LootChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($LootChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $LootChallenges[$j][0] Then
							; Verify your TH level and Challenge kind
							If $g_iTownHallLevel < $LootChallenges[$j][2] Then ExitLoop
							; Disable this event from INI File
							If $LootChallenges[$j][3] = 0 Then ExitLoop
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[5] = [$LootChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $LootChallenges[$j][4], $aAllDetectionsOnScreen[$i][4]]
						EndIf
					Next
				Case "A"
					If Not $g_bChkClanGamesAirTroop Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Event Quantities
					Local $AirTroopChallenges = ClanGamesChallenges("$AirTroopChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($AirTroopChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $AirTroopChallenges[$j][0] Then
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[5] = [$AirTroopChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $AirTroopChallenges[$j][4], $aAllDetectionsOnScreen[$i][4]]
						EndIf
					Next

				Case "S" ; - grumpy
					If Not $g_bChkClanGamesSpell Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Event Quantities
					Local $SpellChallenges = ClanGamesChallenges("$SpellChallenges", False, $sINIPath, $g_bChkClanGamesDebug) ; load all spell challenges
					For $j = 0 To UBound($SpellChallenges) - 1 ; loop through all challenges
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $SpellChallenges[$j][0] Then
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[5] = [$SpellChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $SpellChallenges[$j][4], $aAllDetectionsOnScreen[$i][4]]
						EndIf
					Next

			   Case "G"
					If Not $g_bChkClanGamesGroundTroop Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Event Quantities
					Local $GroundTroopChallenges = ClanGamesChallenges("$GroundTroopChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($GroundTroopChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $GroundTroopChallenges[$j][0] Then
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[5] = [$GroundTroopChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $GroundTroopChallenges[$j][4], $aAllDetectionsOnScreen[$i][4]]
						EndIf
					 Next

				Case "B"
					If Not $g_bChkClanGamesBattle Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					Local $BattleChallenges = ClanGamesChallenges("$BattleChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($BattleChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $BattleChallenges[$j][0] Then
							; Verify the TH level and a few Challenge to destroy TH specific level
							If $BattleChallenges[$j][1] = "Scrappy 6s" And ($g_iTownHallLevel < 5 Or $g_iTownHallLevel > 7) Then ExitLoop        ; TH level 5-6-7
							If $BattleChallenges[$j][1] = "Super 7s" And ($g_iTownHallLevel < 6 Or $g_iTownHallLevel > 8) Then ExitLoop            ; TH level 6-7-8
							If $BattleChallenges[$j][1] = "Exciting 8s" And ($g_iTownHallLevel < 7 Or $g_iTownHallLevel > 9) Then ExitLoop        ; TH level 7-8-9
							If $BattleChallenges[$j][1] = "Noble 9s" And ($g_iTownHallLevel < 8 Or $g_iTownHallLevel > 10) Then ExitLoop        ; TH level 8-9-10
							If $BattleChallenges[$j][1] = "Terrific 10s" And ($g_iTownHallLevel < 9 Or $g_iTownHallLevel > 11) Then ExitLoop    ; TH level 9-10-11
							If $BattleChallenges[$j][1] = "Exotic 11s" And ($g_iTownHallLevel < 10 Or $g_iTownHallLevel > 12) Then ExitLoop     ; TH level 10-11-12
							If $BattleChallenges[$j][1] = "Triumphant 12s" And $g_iTownHallLevel < 11 Then ExitLoop  ; TH level 11-12-13
						    If $BattleChallenges[$j][1] = "Tremendous 13s" And $g_iTownHallLevel < 12 Then ExitLoop  ; TH level 12-13

							; Verify your TH level and Challenge
							If $g_iTownHallLevel < $BattleChallenges[$j][2] Then ExitLoop
							; Disable this event from INI File
							If $BattleChallenges[$j][3] = 0 Then ExitLoop
							; If you are a TH13 , doesn't exist the TH14 yet
							If $BattleChallenges[$j][1] = "Attack Up" And $g_iTownHallLevel = 14 Then ExitLoop
							; Check your Trophy Range
							If $BattleChallenges[$j][1] = "Slaying The Titans" And (Int($g_aiCurrentLoot[$eLootTrophy]) < 4100 or Int($g_aiCurrentLoot[$eLootTrophy]) > 5000) Then ExitLoop

						    If $BattleChallenges[$j][1] = "Clash of Legends" And Int($g_aiCurrentLoot[$eLootTrophy]) < 5000 Then ExitLoop

							; Check if exist a probability to use any Spell
							; If $BattleChallenges[$j][1] = "No-Magic Zone" And ($g_bSmartZapEnable = True Or ($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1)) Then ExitLoop
							; same as above, but SmartZap as condition removed, cause SZ does not necessary triggers every attack
							If $BattleChallenges[$j][1] = "No-Magic Zone" And (($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1)) Then ExitLoop
							; Check if you are using Heroes
							If $BattleChallenges[$j][1] = "No Heroics Allowed" And ((Int($g_aiAttackUseHeroes[$DB]) > $eHeroNone And $g_iMatchMode = $DB) Or (Int($g_aiAttackUseHeroes[$LB]) > $eHeroNone And $g_iMatchMode = $LB)) Then ExitLoop
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[5] = [$BattleChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $BattleChallenges[$j][4], $aAllDetectionsOnScreen[$i][4]]
						EndIf
					Next
				Case "D"
					If Not $g_bChkClanGamesDes Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					Local $DestructionChallenges = ClanGamesChallenges("$DestructionChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($DestructionChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $DestructionChallenges[$j][0] Then
							; Verify your TH level and Challenge kind
							If $g_iTownHallLevel < $DestructionChallenges[$j][2] Then ExitLoop

							; Disable this event from INI File
							If $DestructionChallenges[$j][3] = 0 Then ExitLoop

							; Check if you are using Heroes
							If $DestructionChallenges[$j][1] = "Hero Level Hunter" Or _
									$DestructionChallenges[$j][1] = "King Level Hunter" Or _
									$DestructionChallenges[$j][1] = "Queen Level Hunter" Or _
									$DestructionChallenges[$j][1] = "Warden Level Hunter" And ((Int($g_aiAttackUseHeroes[$DB]) = $eHeroNone And $g_iMatchMode = $DB) Or (Int($g_aiAttackUseHeroes[$LB]) = $eHeroNone And $g_iMatchMode = $LB)) Then ExitLoop
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							If $aAllDetectionsOnScreen[$i][1] = "BBreakdown" And $aAllDetectionsOnScreen[$i][4] = "CGBB" Then ContinueLoop
							If $aAllDetectionsOnScreen[$i][1] = "WallWhacker" And $aAllDetectionsOnScreen[$i][4] = "CGBB" Then ContinueLoop
							Local $aArray[5] = [$DestructionChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $DestructionChallenges[$j][4], $aAllDetectionsOnScreen[$i][4]]
						EndIf
					Next
				Case "M"
					If Not $g_bChkClanGamesMiscellaneous Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					Local $MiscChallenges = ClanGamesChallenges("$MiscChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($MiscChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $MiscChallenges[$j][0] Then
							; Disable this event from INI File
							If $MiscChallenges[$j][3] = 0 Then ExitLoop

							; Exceptions :
							; 1 - "Gardening Exercise" needs at least a Free Builder and "Remove Obstacles" enabled
							If $MiscChallenges[$j][1] = "Gardening Exercise" And ($g_iFreeBuilderCount < 1 Or Not $g_bChkCleanYard) Then ExitLoop

							; 2 - Verify your TH level and Challenge kind
							If $g_iTownHallLevel < $MiscChallenges[$j][2] Then ExitLoop

							; 3 - If you don't Donate Troops
							If $MiscChallenges[$j][1] = "Helping Hand" And Not $g_iActiveDonate Then ExitLoop

							; 4 - If you don't Donate Spells , $g_aiPrepDon[2] = Donate Spells , $g_aiPrepDon[3] = Donate All Spells [PrepareDonateCC()]
							If $MiscChallenges[$j][1] = "Donate Spells" And ($g_aiPrepDon[2] = 0 And $g_aiPrepDon[3] = 0) Then ExitLoop

							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[5] = [$MiscChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $MiscChallenges[$j][4], $aAllDetectionsOnScreen[$i][4]]
						EndIf
					Next
                Case "BBB" ; BB Battle challenges
                    If Not $g_bChkClanGamesBBBattle Then ContinueLoop

                    ;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
                    Local $BBBattleChallenges = ClanGamesChallenges("$BBBattleChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
                    For $j = 0 To UBound($BBBattleChallenges) - 1
                        ; Match the names
                        If $aAllDetectionsOnScreen[$i][1] = $BBBattleChallenges[$j][0] Then
                            Local $aArray[5] = [$BBBattleChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $BBBattleChallenges[$j][4], $aAllDetectionsOnScreen[$i][4]]
                        EndIf
                    Next
                Case "BBD" ; BB Destruction challenges
					If Not $g_bChkClanGamesBBDes Then ContinueLoop

                    ;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
                    Local $BBDestructionChallenges = ClanGamesChallenges("$BBDestructionChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
                    For $j = 0 To UBound($BBDestructionChallenges) - 1
						; Match the names
                        If $aAllDetectionsOnScreen[$i][1] = $BBDestructionChallenges[$j][0] Then
							If $aAllDetectionsOnScreen[$i][1] = "BuildingDes" And $aAllDetectionsOnScreen[$i][4] = "CGMain" Then ContinueLoop
							If $aAllDetectionsOnScreen[$i][1] = "WallDes" And $aAllDetectionsOnScreen[$i][4] = "CGMain" Then ContinueLoop
							Local $aArray[5] = [$BBDestructionChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $BBDestructionChallenges[$j][4], $aAllDetectionsOnScreen[$i][4]]
                        EndIf
                    Next
				Case "BBT" ; BB Troop challenges
					If Not $g_bChkClanGamesBBTroops Then ContinueLoop

                    ;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
                    Local $BBTroopsChallenges = ClanGamesChallenges("$BBTroopsChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
                    For $j = 0 To UBound($BBTroopsChallenges) - 1
                        ; Match the names
                        If $aAllDetectionsOnScreen[$i][1] = $BBTroopsChallenges[$j][0] Then
							Local $aArray[5] = [$BBTroopsChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $BBTroopsChallenges[$j][4], $aAllDetectionsOnScreen[$i][4]]
                        EndIf
                    Next
			EndSwitch
			If IsDeclared("aArray") And $aArray[0] <> "" Then
				ReDim $aSelectChallenges[UBound($aSelectChallenges) + 1][7]
				$aSelectChallenges[UBound($aSelectChallenges) - 1][0] = $aArray[0] ; Event Name Full Name
				$aSelectChallenges[UBound($aSelectChallenges) - 1][1] = $aArray[1] ; Xaxis
				$aSelectChallenges[UBound($aSelectChallenges) - 1][2] = $aArray[2] ; Yaxis
				$aSelectChallenges[UBound($aSelectChallenges) - 1][3] = $aArray[3] ; difficulty
				$aSelectChallenges[UBound($aSelectChallenges) - 1][4] = 0 		   ; timer minutes
				$aSelectChallenges[UBound($aSelectChallenges) - 1][5] = $aArray[4] ; EventType: MainVillage/BuilderBase
				$aSelectChallenges[UBound($aSelectChallenges) - 1][6] = 0		   ; Event Score
				$aArray[0] = ""
			EndIf
		Next
	EndIf

	If $g_bChkClanGamesDebug Then Setlog("_ClanGames aAllDetectionsOnScreen (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	$hTimer = TimerInit()

	; Sort by Yaxis , TOP to Bottom
	_ArraySort($aSelectChallenges, 0, 0, 0, 2)

	If UBound($aSelectChallenges) > 0 Then
		; let's get the Event timing
		For $i = 0 To UBound($aSelectChallenges) - 1
			Click($aSelectChallenges[$i][1], $aSelectChallenges[$i][2])
			If _Sleep(1500) Then Return
			Local $aEventInfo = GetEventInfo()
			If IsArray($aEventInfo) Then 
				Setlog("Detected " & $aSelectChallenges[$i][0] & " difficulty of " & $aSelectChallenges[$i][3] & " [score:" & $aEventInfo[0] & ", " & $aEventInfo[1] & " min]", $COLOR_INFO)
				$aSelectChallenges[$i][4] = Number($aEventInfo[1])
				$aSelectChallenges[$i][6] = Number($aEventInfo[0])
			Else
				ContinueLoop ; fail get event info, mostly because lag
			EndIf
			Click($aSelectChallenges[$i][1], $aSelectChallenges[$i][2])
			If _Sleep(250) Then Return
		Next

		; let's get the 60 minutes events and remove from array
		Local $aTempSelectChallenges[0][7]
		For $i = 0 To UBound($aSelectChallenges) - 1
			If $aSelectChallenges[$i][4] = 60 And $g_bChkClanGames60 Then
				Setlog($aSelectChallenges[$i][0] & " unselected, is a 60min event!", $COLOR_INFO)
				ContinueLoop
			EndIf
			ReDim $aTempSelectChallenges[UBound($aTempSelectChallenges) + 1][7]
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][0] = $aSelectChallenges[$i][0] ; Event Name Full Name
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][1] = $aSelectChallenges[$i][1] ; Xaxis
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][2] = $aSelectChallenges[$i][2] ; Yaxis
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][3] = Number($aSelectChallenges[$i][3]) ; difficulty
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][4] = Number($aSelectChallenges[$i][4]) ; timer minutes
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][5] = $aSelectChallenges[$i][5] ; EventType: Battle Loot BB and so on
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][6] = $aSelectChallenges[$i][6] ; Event Score
		Next

		Local $aTmpBBChallenges[0][7]
		If $g_bChkForceBBAttackOnClanGames And $bSearchBBEventFirst Then
			SetDebugLog("ForceBBAttack on ClanGames enabled", $COLOR_INFO)
			SetDebugLog("Try Only do BB event First", $COLOR_INFO)
			For $i = 0 To UBound($aTempSelectChallenges) - 1
				If $aTempSelectChallenges[$i][5] = "CGMain" Then
					ContinueLoop
				EndIf
				ReDim $aTmpBBChallenges[UBound($aTmpBBChallenges) + 1][7]
				$aTmpBBChallenges[UBound($aTmpBBChallenges) - 1][0] = $aTempSelectChallenges[$i][0] ; Event Name Full Name
				$aTmpBBChallenges[UBound($aTmpBBChallenges) - 1][1] = $aTempSelectChallenges[$i][1] ; Xaxis
				$aTmpBBChallenges[UBound($aTmpBBChallenges) - 1][2] = $aTempSelectChallenges[$i][2] ; Yaxis
				$aTmpBBChallenges[UBound($aTmpBBChallenges) - 1][3] = Number($aTempSelectChallenges[$i][3]) ; difficulty
				$aTmpBBChallenges[UBound($aTmpBBChallenges) - 1][4] = Number($aTempSelectChallenges[$i][4]) ; timer minutes
				$aTmpBBChallenges[UBound($aTmpBBChallenges) - 1][5] = $aTempSelectChallenges[$i][5] ; EventType: Battle Loot BB and so on
				$aTmpBBChallenges[UBound($aTmpBBChallenges) - 1][6] = $aTempSelectChallenges[$i][6] ; Event Score
			Next

			If Ubound($aTmpBBChallenges) > 0 Then
				SetDebugLog("Found " & Ubound($aTmpBBChallenges) & " BB Event", $COLOR_SUCCESS)
				$aTempSelectChallenges = $aTmpBBChallenges ;replace All Challenge array with BB Only Event Array
			Else
				SetDebugLog("No BB Event Found, using current detected event", $COLOR_INFO)
			EndIf
		EndIf

		; Drop to top again , because coordinates Xaxis and Yaxis
		ClickP($TabChallengesPosition, 2, 0, "#Tab")
		If _sleep(1000) Then Return
		ClickDrag(807, 210, 807, 385, 500)
		If _Sleep(2000) Then Return
	EndIf
	
	Local $bPurgePreventMax = False
	; After removing is necessary check Ubound
	If IsDeclared("aTempSelectChallenges") Then
		If UBound($aTempSelectChallenges) > 0 Then
			If $g_bSortClanGames Then
				Switch $g_iSortClanGames
					Case 0 ;sort by Difficulty
						_ArraySort($aTempSelectChallenges, 0, 0, 0, 3) ;sort ascending, lower difficulty = easiest
					Case 1 ;sort by Time
						_ArraySort($aTempSelectChallenges, 1, 0, 0, 4) ;sort descending, longest time first
					Case 2 ;sort by Score
						_ArraySort($aTempSelectChallenges, 1, 0, 0, 6) ;sort descending, Higher score first
				EndSwitch
			EndIf
			If $g_bChkClanGamesStopBeforeReachAndPurge And Number($aiScoreLimit[0]) > Number($aiScoreLimit[1]) - 1000 Then _ArraySort($aTempSelectChallenges, 1, 0, 0, 6) ;sort descending, Force Higher score first
			For $i = 0 To UBound($aTempSelectChallenges) - 1
				If Not $g_bRunState Then Return
				SetDebugLog("$aTempSelectChallenges: " & _ArrayToString($aTempSelectChallenges))
				Setlog("Next Event will be " & $aTempSelectChallenges[$i][0] & " to make in " & $aTempSelectChallenges[$i][4] & " min.")
				; if enabled stop and purge, more than 1 day CG time, and event score will make clangames maxpoint, and there is another event on array
				If $g_bChkClanGamesStopBeforeReachAndPurge And $sTimeCG > 1440 And (Number($aiScoreLimit[0]) + Number($aTempSelectChallenges[$i][6])) >= Number($aiScoreLimit[1]) Then 
					If $i < UBound($aTempSelectChallenges) - 1 Then 
						SetLog($aTempSelectChallenges[$i][0] & ", score:" & $aTempSelectChallenges[$i][6], $COLOR_INFO)
						SetLog("Doing this challenge will maxing score, looking next", $COLOR_INFO)
						ContinueLoop
					Else
						SetLog($aTempSelectChallenges[$i][0] & ", score:" & $aTempSelectChallenges[$i][6], $COLOR_INFO)
						SetLog("Doing this challenge will maxing score", $COLOR_INFO)
						SetLog("Now lets just purge", $COLOR_INFO)
						$bPurgePreventMax = True
						ExitLoop ; there is no next event, so exit and just purge
					EndIf
				EndIf
				; Select and Start EVENT
				$sEventName = $aTempSelectChallenges[$i][0]
				;SetLog("QuickMIS(BC1, " & $sTempPath & "Selected\" & "," & $aTempSelectChallenges[$i][1] - 60 & "," & $aTempSelectChallenges[$i][2] - 60 & "," & $aTempSelectChallenges[$i][1] + 60 & "," & $aTempSelectChallenges[$i][2] + 60 & ", True)" )
				If Not QuickMIS("BC1", $sTempPath & "Selected\", $aTempSelectChallenges[$i][1] - 60, $aTempSelectChallenges[$i][2] - 60, $aTempSelectChallenges[$i][1] + 60, $aTempSelectChallenges[$i][2] + 60, True) Then
					SetLog($sEventName & " not found on previous location detected", $COLOR_ERROR)
					SetLog("Maybe event tile changed, Looking Next Event...", $COLOR_INFO)
					ContinueLoop
				EndIf

				Click($aTempSelectChallenges[$i][1], $aTempSelectChallenges[$i][2])
				If _Sleep(1750) Then Return
				Return ClickOnEvent($YourAccScore, $aiScoreLimit, $sEventName, $getCapture)
			Next
		EndIf
	EndIf

	If $g_bChkClanGamesPurgeAny Then ; still have to purge, because no enabled event on setting found
		If $bPurgePreventMax Then
			Local $aEvent = FindEventToPurge($sTempPath)
			If IsArray($aEvent) And UBound($aEvent) > 0 Then
				Local $EventName = StringSplit($aEvent[0][0], "-")
				SetLog("Detected Event to Purge: " & $EventName[2])
				Click($aEvent[0][1], $aEvent[0][2])
				If _Sleep(1500) Then Return
				StartsEvent($EventName[2], True)
			Else
				ForcePurgeEvent(False, True) ; maybe will never hit here, but..
			EndIf
		Else
			SetLog("Still have to purge, because no enabled event on setting found", $COLOR_WARNING)
			SetLog("No Event found, lets purge 1 most top event", $COLOR_WARNING)
			If $g_bDebugClick Or $g_bDebugSetlog Or $g_bChkClanGamesDebug Then SaveDebugImage("ClanGames_Challenges", True)
			ForcePurgeEvent(False, True)
			CloseClangamesWindow()
			_Sleep(1000)
			Return False
		EndIf
	Else
		SetLog("No Event found, Check your settings", $COLOR_WARNING)
		CloseClangamesWindow()
		_Sleep(1000)
		Return False
	EndIf
EndFunc ;==>_ClanGames

Func ClanGameImageCopy($sImagePath, $sTempPath, $sImageType = Default, $ImageName = Default)
	If $sImageType = Default Then Return
	Switch $sImageType
		Case "L"
			Local $CGMainLoot = ClanGamesChallenges("$LootChallenges")
			For $i = 0 To UBound($g_abCGMainLootItem) - 1
				If $g_abCGMainLootItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "LootChallenges: " & $CGMainLoot[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainLoot[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainLoot[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "B"
			Local $CGMainBattle = ClanGamesChallenges("$BattleChallenges")
			For $i = 0 To UBound($g_abCGMainBattleItem) - 1
				If $g_abCGMainBattleItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "BattleChallenges: " & $CGMainBattle[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainBattle[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainBattle[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "D"
			Local $CGMainDestruction = ClanGamesChallenges("$DestructionChallenges")
			For $i = 0 To UBound($g_abCGMainDestructionItem) - 1
				If $g_abCGMainDestructionItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "DestructionChallenges: " & $CGMainDestruction[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainDestruction[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainDestruction[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "A"
			Local $CGMainAir = ClanGamesChallenges("$AirTroopChallenges")
			For $i = 0 To UBound($g_abCGMainAirItem) - 1
				If $g_abCGMainAirItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "AirTroopChallenges: " & $CGMainAir[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainAir[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainAir[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "G"
			Local $CGMainGround = ClanGamesChallenges("$GroundTroopChallenges")
			For $i = 0 To UBound($g_abCGMainGroundItem) - 1
				If $g_abCGMainGroundItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "GroundTroopChallenges: " & $CGMainGround[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainGround[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainGround[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "M"
			Local $CGMainMisc = ClanGamesChallenges("$MiscChallenges")
			For $i = 0 To UBound($g_abCGMainMiscItem) - 1
				If $g_abCGMainMiscItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "MiscChallenges: " & $CGMainMisc[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainMisc[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainMisc[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "S"
			Local $CGMainSpell = ClanGamesChallenges("$SpellChallenges")
			For $i = 0 To UBound($g_abCGMainSpellItem) - 1
				If $g_abCGMainSpellItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "SpellChallenges: " & $CGMainSpell[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainSpell[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainSpell[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "BBB"
			Local $CGBBBattle = ClanGamesChallenges("$BBBattleChallenges")
			For $i = 0 To UBound($g_abCGBBBattleItem) - 1
				If $g_abCGBBBattleItem[$i] > 0 Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "BBBattleChallenges: " & $CGBBBattle[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGBBBattle[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGBBBattle[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "BBD"
			Local $CGBBDestruction = ClanGamesChallenges("$BBDestructionChallenges")
			For $i = 0 To UBound($g_abCGBBDestructionItem) - 1
				If $g_abCGBBDestructionItem[$i] > 0 Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "BBDestructionChallenges: " & $CGBBDestruction[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGBBDestruction[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGBBDestruction[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "BBT"
			Local $CGBBTroops = ClanGamesChallenges("$BBTroopsChallenges")
			For $i = 0 To UBound($g_abCGBBTroopsItem) - 1
				If $g_abCGBBTroopsItem[$i] > 0 Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "BBTroopsChallenges: " & $CGBBTroops[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGBBTroops[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGBBTroops[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
	EndSwitch
	If $sImageType = "Selected" Then
		If $g_bChkClanGamesDebug Then SetLog("[" & $ImageName & "] Selected", $COLOR_DEBUG)
		FileCopy($sImagePath & "\" & $ImageName & "_*", $sTempPath & "\Selected\", $FC_OVERWRITE + $FC_CREATEPATH)
	EndIf
EndFunc ;==>ClanGameImageCopy

Func FindEvent()
	Local $hStarttime = _Timer_Init()
	Local $sImagePath = @ScriptDir & "\imgxml\Resources\ClanGamesImages\Challenges"
	Local $sTempPath = @TempDir & "\" & $g_sProfileCurrentName & "\Challenges\"
	Local $aEvent, $aReturn[0][6], $toBottom = False
	Local $aX[4] = [290, 410, 540, 660]
	Local $aY[3] = [120, 280, 445]

	For $y = 0 To Ubound($aY) - 1
		For $x = 0 To Ubound($aX) - 1
			$aEvent = QuickMIS("CNX", $sTempPath, $aX[$x], $aY[$y], $aX[$x] + 100, $aY[$y] + 110)
			If IsArray($aEvent) And UBound($aEvent) > 0 Then
				Local $IsBBEvent = IsBBChallenge($aEvent[0][1], $aEvent[0][2])
				If $IsBBEvent Then $IsBBEvent = "CGBB"
				If Not $IsBBEvent Then $IsBBEvent = "CGMain"
				Local $ChallengeEvent = StringSplit($aEvent[0][0], "-", $STR_NOCOUNT)
				ClanGameImageCopy($sImagePath, $sTempPath, "Selected", $aEvent[0][0])
				_ArrayAdd($aReturn, $ChallengeEvent[0] & "|" & $ChallengeEvent[1] & "|" & $aEvent[0][1] & "|" & $aEvent[0][2] & "|" & $IsBBEvent & "|" & $aEvent[0][0] )
			EndIf
		Next
	Next
	SetDebugLog("Benchmark FindEvent selection: " & StringFormat("%.2f", _Timer_Diff($hStarttime)) & "'ms", $COLOR_DEBUG)
	Return $aReturn
EndFunc

Func IsClanGamesWindow($getCapture = True)
	Local $sState, $bRet = False

	If QuickMIS("BC1", $g_sImgCaravan, 200, 55, 330, 155, $getCapture, False) Then
		SetLog("Caravan available! Entering Clan Games", $COLOR_SUCCESS)
		Click($g_iQuickMISX, $g_iQuickMISY)
		; Just wait for window open
		For $i = 1 To 10
			If IsFullScreenWindow() Then ExitLoop
			_Sleep(250)
		Next
		$sState = IsClanGamesRunning()
		Switch $sState
			Case "Prepare"
				$bRet = False
			Case "Running"
				$bRet = True
			Case "Ended"
				$bRet = False
				If $g_bCollectCGReward Then CollectCGReward()
		EndSwitch
	Else
		SetLog("Caravan not available", $COLOR_WARNING)
		$sState = "Not Running"
		$bRet = False
	EndIf

	SetLog("Clan Games State is : " & $sState, $COLOR_INFO)
	Return $bRet
EndFunc   ;==>IsClanGamesWindow

Func IsClanGamesRunning($getCapture = True) ;to check whether clangames current state, return string of the state "prepare" "running" "end"
	Local $aGameTime[4] = [384, 388, 0xFFFFFF, 10]
	Local $sState = "Running"
	If QuickMIS("BC1", $g_sImgWindow, 50, 50, 150, 200, $getCapture, False) Then
		SetLog("Window Opened", $COLOR_DEBUG)
		If QuickMIS("BC1", $g_sImgRewardText, 580, 450, 830, 570, $getCapture, False) Then
			SetLog("Your Reward is Ready", $COLOR_INFO)
			$sState = "Ended"
		EndIf
	Else
		If _CheckPixel($aGameTime, True) Then
			Local $sTimeRemain = getOcrTimeGameTime(380, 461) ; read Clan Games waiting time
			SetLog("Clan Games will start in " & $sTimeRemain, $COLOR_INFO)
			$g_sClanGamesTimeRemaining = $sTimeRemain
			$sState = "Prepare"
		EndIf
		SetLog("Clan Games Window Not Opened", $COLOR_DEBUG)
		$sState = "Cannot open ClanGames"
	EndIf
	Return $sState
EndFunc ;==>IsClanGamesRunning

Func GetTimesAndScores()
	Local $iRestScore = -1, $sYourGameScore = "", $aiScoreLimit, $sTimeRemain = 0

	;Ocr for game time remaining
	$sTimeRemain = StringReplace(getOcrTimeGameTime(55, 448), " ", "") ; read Clan Games waiting time

	;Check if OCR returned a valid timer format
	If Not StringRegExp($sTimeRemain, "([0-2]?[0-9]?[DdHhSs]+)", $STR_REGEXPMATCH, 1) Then
		SetLog("getOcrTimeGameTime(): no valid return value (" & $sTimeRemain & ")", $COLOR_ERROR)
	EndIf

	SetLog("Clan Games time remaining: " & $sTimeRemain, $COLOR_INFO)

	; This Loop is just to check if the Score is changing , when you complete a previous events is necessary to take some time
	For $i = 0 To 10
		$sYourGameScore = getOcrYourScore(45, 500) ;  Read your Score
		If $g_bChkClanGamesDebug Then SetLog("Your OCR score: " & $sYourGameScore)
		$sYourGameScore = StringReplace($sYourGameScore, "#", "/")
		$aiScoreLimit = StringSplit($sYourGameScore, "/", $STR_NOCOUNT)
		If UBound($aiScoreLimit, 1) > 1 Then
			If $iRestScore = Int($aiScoreLimit[0]) Then ExitLoop
			$iRestScore = Int($aiScoreLimit[0])
		Else
			Return -1
		EndIf
		If _Sleep(800) Then Return
		If $i = 10 Then Return -1
	Next

	;Update Values
	$g_sClanGamesScore = $sYourGameScore
	$g_sClanGamesTimeRemaining = $sTimeRemain

	$aiScoreLimit[0] = Int($aiScoreLimit[0])
	$aiScoreLimit[1] = Int($aiScoreLimit[1])
	Return $aiScoreLimit
EndFunc   ;==>GetTimesAndScores

Func CooldownTime($getCapture = True)
	;check cooldown purge
	Local $aiCoolDown = decodeSingleCoord(findImage("Cooldown", $g_sImgCoolPurge & "\*.xml", GetDiamondFromRect("480,370,570,410"), 1, True, Default))
	If IsArray($aiCoolDown) And UBound($aiCoolDown, 1) >= 2 Then
		SetLog("Cooldown Purge Detected", $COLOR_INFO)
		If $g_bChkForceSwitchifNoCGEvent And Not $g_bIsCGPointAlmostMax Then $g_bForceSwitchifNoCGEvent = True
		CloseClangamesWindow()
		Return True
	EndIf
	Return False
EndFunc   ;==>CooldownTime

Func IsEventRunning($bOpenWindow = False)
	Local $aEventFailed[4] = [300, 222, 0xEA2B24, 20]
	Local $aEventPurged[4] = [300, 235, 0x57C78F, 20]

	If $bOpenWindow Then
		CloseClangamesWindow()
		SetLog("Entering Clan Games", $COLOR_INFO)
		If Not IsClanGamesWindow() Then Return
	EndIf
	; Check if any event is running or not
	If Not _ColorCheck(_GetPixelColor(300, 236, True), Hex(0x52DF50, 6), 5) Then ; Green Bar from First Position
		;Check if Event failed
		If _CheckPixel($aEventFailed, True) Then
			SetLog("Couldn't finish last event! Lets trash it and look for a new one", $COLOR_INFO)
			If TrashFailedEvent() Then
				If _Sleep(3000) Then Return ;Add sleep here, to wait ClanGames Challenge Tile ordered again as 1 has been deleted
				Return False
			Else
				SetLog("Error happend while trashing failed event", $COLOR_ERROR)
				CloseClangamesWindow()
				Return True
			EndIf
		ElseIf _CheckPixel($aEventPurged, True) Then
				SetLog("An event purge cooldown in progress!", $COLOR_WARNING)
				If $g_bChkForceSwitchifNoCGEvent And Not $g_bIsCGPointAlmostMax Then $g_bForceSwitchifNoCGEvent = True
				CloseClangamesWindow()
				Return True
		Else
			SetLog("An event is already in progress!", $COLOR_SUCCESS)
			;check if its Enabled Challenge, if not = purge
			Local $bNeedPurge = False
			Local $aActiveEvent = QuickMIS("CNX", @TempDir & "\" & $g_sProfileCurrentName & "\Challenges\", 300, 130, 380, 210, True)
			If IsArray($aActiveEvent) And UBound($aActiveEvent) > 0 Then
				SetLog("Active Challenge " & $aActiveEvent[0][0] & " is Enabled on Setting, OK!!", $COLOR_DEBUG)
				;check if Challenge is BB Challenge, enabling force BB attack
				If $g_bChkForceBBAttackOnClanGames Then
					Click(340,180) ; click first slot
					If _Sleep(1000) Then Return
					SetLog("Re-Check If Running Challenge is BB Event or No?", $COLOR_DEBUG)
					If QuickMIS("BC1", $g_sImgVersus, 425, 150, 700, 215, True, False) Then
						Setlog("Running Challenge is BB Challenge", $COLOR_INFO)
						$g_bIsBBevent = True
						$g_bIsCGEventRunning = True
					Else
						Setlog("Running Challenge is MainVillage Challenge", $COLOR_INFO)
						If $aActiveEvent[0][0] = "BBD-WallDes" Or $aActiveEvent[0][0] = "BBD-BuildingDes" Then
							SetLog("Event with shared Image: " & $aActiveEvent[0][0])
							If $g_abCGMainDestructionItem[23] < 1 Then $bNeedPurge = True ;BBreakdown
							If $g_abCGMainDestructionItem[22] < 1 Then $bNeedPurge = True ;WallWhacker
						EndIf
						If $g_bChkCGBBAttackOnly Or $bNeedPurge Then ;Purge main village event because we using BBCGOnly Mode
							Setlog("We are running only BB events. Event started by mistake?", $COLOR_ERROR)
							Click(340,180) ;unclick so ForcePurgeEvent can work
							ForcePurgeEvent(False, False)
						EndIf
						$g_bIsBBevent = False
					EndIf
				EndIf
			Else
				Setlog("Active Challenge Not Enabled on Setting! started by mistake?", $COLOR_ERROR)
				ForcePurgeEvent(False, False)
			EndIf
			CloseClangamesWindow()
			Return True
		EndIf
	Else
		SetLog("No event under progress", $COLOR_INFO)
		Return False
	EndIf
	Return False
EndFunc   ;==>IsEventRunning

Func ClickOnEvent(ByRef $YourAccScore, $ScoreLimits, $sEventName, $getCapture)
	If Not $YourAccScore[$g_iCurAccount][1] Then
		Local $Text = "", $color = $COLOR_SUCCESS
		If $YourAccScore[$g_iCurAccount][0] <> $ScoreLimits[0] Then
			$Text = "You got " & $ScoreLimits[0] - $YourAccScore[$g_iCurAccount][0] & "points on the last event."
		Else
			$Text = "You could not complete the last event!"
			$color = $COLOR_WARNING
		EndIf
		SetLog($Text, $color)
		GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - " & $Text, 1)
		_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - " & $Text)
	EndIf
	$YourAccScore[$g_iCurAccount][1] = False
	$YourAccScore[$g_iCurAccount][0] = $ScoreLimits[0]
	If Not StartsEvent($sEventName, False, $getCapture, $g_bChkClanGamesDebug) Then Return False
	CloseClangamesWindow()
	Return True
EndFunc   ;==>ClickOnEvent

Func StartsEvent($sEventName, $g_bPurgeJob = False, $getCapture = True, $g_bChkClanGamesDebug = False, $OnlyPurge = False)
	If Not $g_bRunState Then Return

	If QuickMIS("BC1", $g_sImgStart, 220, 150, 830, 580, $getCapture, False) Then
		Local $aTimer = GetEventTimeScore($g_iQuickMISX, $g_iQuickMISY)
		SetLog("Starting Event" & " [score:" & $aTimer[0] & ", " & $aTimer[1] & " min]", $COLOR_SUCCESS)
		Click($g_iQuickMISX, $g_iQuickMISY)
		GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - Starting : " & $sEventName & " [score:" & $aTimer[0] & ", " & $aTimer[1] & " min]", 1)
		_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - Starting : " & $sEventName & " [score:" & $aTimer[0] & ", " & $aTimer[1] & " min]")

		If $g_bPurgeJob Then
			For $i = 1 To 5
				If QuickMIS("BC1", $g_sImgTrashPurge, 100, 100, 700, 550, True) Then
					Click($g_iQuickMISX, $g_iQuickMISY)
					SetLog("Click Trash", $COLOR_INFO)
					ExitLoop
				Else
					SetDebugLog("waiting for trash #" & $i)
				EndIf
				_Sleep(1000)
			Next

			For $i = 1 To 5
				If IsOKCancelPage() Then
					SetLog("Click OK", $COLOR_INFO)
					Click(500, 400)
					SetLog("StartsEvent and Purge job!", $COLOR_SUCCESS)
					GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - Purging : " & $sEventName & ($OnlyPurge ? ", PurgeBeforeSwitch" : ", NearMaxPoint"), 1)
					_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - Purging : " & $sEventName & ($OnlyPurge ? ", PurgeBeforeSwitch" : ", NearMaxPoint"))
					CloseClangamesWindow()
					Return True
				Else
					SetDebugLog("waiting for OK #" & $i)
				EndIf
				_Sleep(1000)
			Next
			Return False
		EndIf

		;check if Challenge is BB Challenge, enabling force BB attack
		If $g_bChkForceBBAttackOnClanGames Then
			Click(450,50) ;Click Clan Tab
			If _Sleep(3000) Then Return
			Click(300,50) ;Click Challenge Tab
			If _Sleep(500) Then Return
			Click(340,180) ;Click Active Challenge
			If _Sleep(1000) Then Return

			SetLog("Re-Check If Running Challenge is BB Event or No?", $COLOR_DEBUG)
			If QuickMIS("BC1", $g_sImgVersus, 425, 150, 700, 215, True, False) Then
				Setlog("Running Challenge is BB Challenge", $COLOR_INFO)
				$g_bIsBBevent = True
			Else
				Setlog("Running Challenge is MainVillage Challenge", $COLOR_INFO)
				$g_bIsBBevent = False
			EndIf
		EndIf
		Return True
	Else
		SetLog("Didn't Get the Green Start Button Event", $COLOR_WARNING)
		If $g_bChkClanGamesDebug Then SetLog("[X: " & 220 & " Y:" & 150 & " X1: " & 830 & " Y1: " & 580 & "]", $COLOR_WARNING)
		CloseClangamesWindow()
		Return False
	EndIf

EndFunc   ;==>StartsEvent

Func ForcePurgeEvent($bTest = False, $startFirst = True)
	Local $count1 = 0, $count2 = 0

	Click(340,180) ;Most Top Challenge

	If _Sleep(1000) Then Return
	If $startFirst Then
		SetLog("ForcePurgeEvent: No event Found, Start and Purge a Challenge", $COLOR_INFO)
		If StartAndPurgeEvent($bTest) Then
			If $g_bChkForceSwitchifNoCGEvent And Not $g_bIsCGPointAlmostMax Then $g_bForceSwitchifNoCGEvent = True
			CloseClangamesWindow()
			Return True
		EndIf
	Else
		SetLog("ForcePurgeEvent: Purge a Wrong Challenge", $COLOR_INFO)
		While Not WaitforPixel(570, 285, 571, 286, "F51D20", 10, 1)
			SetDebugLog("Waiting for trash Button", $COLOR_DEBUG)
			$count1 += 1
			If $count1 > 10 Then ExitLoop
		Wend
		If QuickMIS("BC1", $g_sImgTrashPurge, 400, 200, 700, 350, True, False) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			SetLog("Click Trash", $COLOR_INFO)
			While Not IsOKCancelPage()
				SetDebugLog("Waiting for trash Confirm OK", $COLOR_DEBUG)
				$count2 += 1
				If $count2 > 10 Then ExitLoop
			Wend
			If IsOKCancelPage() Then
				SetLog("Click OK", $COLOR_INFO)
				If $bTest Then Return
				Click(500, 400)
				If _Sleep(1500) Then Return
				CloseClangamesWindow()
				GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - ForcePurgeEvent: Purge a Wrong Challenge ", 1)
				_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - ForcePurgeEvent: Purge a Wrong Challenge ")
				If $g_bChkForceSwitchifNoCGEvent And Not $g_bIsCGPointAlmostMax Then $g_bForceSwitchifNoCGEvent = True
			Else
				SetLog("$g_sImgOkayPurge Issue", $COLOR_ERROR)
				Return False
			EndIf
		Else
			SetLog("$g_sImgTrashPurge Issue", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
	Return True
EndFunc   ;==>ForcePurgeEvent

Func StartAndPurgeEvent($bTest = False)
	Local $count1 = 0, $count2 = 0

	If QuickMIS("BC1", $g_sImgStart, 220, 150, 830, 580, True, False) Then
		Local $aTimer = GetEventTimeScore($g_iQuickMISX, $g_iQuickMISY)
		SetLog("Starting Event" & " [score:" & $aTimer[0] & ", " & $aTimer[1] & " min]", $COLOR_SUCCESS)
		Click($g_iQuickMISX, $g_iQuickMISY)
		GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - Starting Purge [score:" & $aTimer[0] & ", " & $aTimer[1] & " min]", 1)
		_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - Starting Purge [score:" & $aTimer[0] & ", " & $aTimer[1] & " min]")

		While Not WaitforPixel(570, 285, 571, 286, "F51D20", 10, 1)
			SetDebugLog("Waiting for trash Button", $COLOR_DEBUG)
			$count1 += 1
			If $count1 > 10 Then ExitLoop
		Wend

		If QuickMIS("BC1", $g_sImgTrashPurge, 400, 200, 700, 350, True, False) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			SetLog("Click Trash", $COLOR_INFO)
			While Not IsOKCancelPage()
				SetDebugLog("Waiting for trash Confirm OK", $COLOR_DEBUG)
				$count2 += 1
				If $count2 > 10 Then ExitLoop
			Wend
			If IsOKCancelPage() Then
				SetLog("Click OK", $COLOR_INFO)
				If $bTest Then Return
				Click(500, 400)
				SetLog("StartAndPurgeEvent event!", $COLOR_SUCCESS)
				GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - StartAndPurgeEvent: No event Found ", 1)
				_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - StartAndPurgeEvent: No event Found ")
				CloseClangamesWindow()
			Else
				SetLog("$g_sImgOkayPurge Issue", $COLOR_ERROR)
				Return False
			EndIf
		Else
			SetLog("$g_sImgTrashPurge Issue", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
	CloseClangamesWindow()
	Return True
EndFunc

Func FindEventToPurge($sTempPath)
	Local $aEvent
	Local $aX[4] = [290, 410, 540, 660]
	Local $aY[3] = [120, 280, 430]

	For $y = 0 To Ubound($aY) - 1
		For $x = 0 To Ubound($aX) - 1
			$aEvent = QuickMIS("CNX", $sTempPath & "Purge\", $aX[$x], $aY[$y], $aX[$x] + 100, $aY[$y] + 110)
			If IsArray($aEvent) And UBound($aEvent) > 0 Then ExitLoop 2
		Next
	Next
	Return $aEvent
EndFunc

Func TrashFailedEvent()
	;Look for the red cross on failed event
	If Not ClickB("EventFailed") Then
		SetLog("Could not find the failed event icon!", $COLOR_ERROR)
		Return False
	EndIf

	If _Sleep(1000) Then Return

	;Look for the red trash event Button and press it
	If Not ClickB("TrashEvent") Then
		SetLog("Could not find the trash event button!", $COLOR_ERROR)
		Return False
	EndIf

	If _Sleep(500) Then Return
	Return True
EndFunc   ;==>TrashFailedEvent

Func GetEventTimeScore($iXStartBtn, $iYStartBtn, $bIsStartBtn = True)
	Local $aEventInfo[2]
	Local $XAxis = $iXStartBtn - 164 ; Related to Start Button
	Local $YAxis = $iYStartBtn + 9 ; Related to Start Button

	If Not $bIsStartBtn Then
		$XAxis = $iXStartBtn - 164 ; Related to Trash Button
		$YAxis = $iYStartBtn + 9 ; Related to Trash Button
	EndIf

	Local $Ocr = getOcrEventTime($XAxis, $YAxis)
	If $Ocr = "1" Then $Ocr = "1d"
	If $Ocr = "2" Then $Ocr = "2d"
	$aEventInfo[1] = ConvertOCRTime("ClanGames()", StringLower($Ocr), False)
    $aEventInfo[0] = getOcrEventTime($XAxis, $YAxis - 38)
	
	Return $aEventInfo
EndFunc   ;==>GetEventTimeScore

Func GetEventInfo()
	If QuickMIS("BC1", $g_sImgStart, 220, 150, 830, 580) Then
		Return GetEventTimeScore($g_iQuickMISX, $g_iQuickMISY)
	EndIf
EndFunc   ;==>GetEventInfo

Func IsBBChallenge($i = Default, $j = Default)

	Local $BorderX[4] = [292, 418, 546, 669]
	Local $BorderY[3] = [205, 363, 520]
	Local $iColumn, $iRow, $bReturn

	Switch $i
		Case $BorderX[0] To $BorderX[1]
			$iColumn = 1
		Case $BorderX[1] To $BorderX[2]
			$iColumn = 2
		Case $BorderX[1] To $BorderX[3]
			$iColumn = 3
		Case Else
			$iColumn = 4
	EndSwitch

	Switch $j
		Case $BorderY[0]-50 To $BorderY[1]-50
			$iRow = 1
		Case $BorderY[1]-50 To $BorderY[2]-50
			$iRow = 2
		Case Else
			$iRow = 3
	EndSwitch
	If $g_bChkClanGamesDebug Then SetLog("Row: " & $iRow & ", Column : " & $iColumn, $COLOR_DEBUG)
	For $y = 0 To 2
		For $x = 0 To 3
			If $iRow = ($y+1) And $iColumn = ($x+1) Then
				;Search image border, our image is MainVillage event border, so If found return False
				If QuickMIS("BC1", $g_sImgBorder, $BorderX[$x] - 50, $BorderY[$y] - 50, $BorderX[$x] + 50, $BorderY[$y] + 50, True, False) Then
					If $g_bChkClanGamesDebug Then SetLog("IsBBChallenge = False", $COLOR_ERROR)
					Return False
				Else
					If $g_bChkClanGamesDebug Then SetLog("IsBBChallenge = True", $COLOR_INFO)
					Return True
				EndIf
			EndIf
		Next
	Next

EndFunc ;==>IsBBChallenge

; Just for any button test
Func ClanGames($bTest = False)
	Local $bWasRunState = $g_bRunState
	$g_bRunState = True
	Local $temp = $g_bChkClanGamesDebug
	Local $debug = $g_bDebugSetlog
	$g_bDebugSetlog = True
	$g_bChkClanGamesDebug = True
	Local $tempCurrentTroops = $g_aiCurrentTroops
	For $i = 0 To UBound($g_aiCurrentTroops) - 1
		$g_aiCurrentTroops[$i] = 50
	Next
	Local $Result = _ClanGames(True)
	$g_aiCurrentTroops = $tempCurrentTroops
	$g_bRunState = $bWasRunState
	$g_bChkClanGamesDebug = $temp
	$g_bDebugSetlog = $debug
	Return $Result
EndFunc   ;==>ClanGames

Func CloseClangamesWindow()
	If IsFullScreenWindow() Then
		Click(820, 40) ;close window
		Return True
	EndIf
	Return False
EndFunc

Func CollectCGReward($bTest = False)
	SetLog("Checking to Collect ClanGames Reward")
	Local $aiScoreLimit, $sYourGameScore

	$sYourGameScore = getOcrYourScore(45, 500) ;  Read your Score
	$aiScoreLimit = StringSplit($sYourGameScore, "#", $STR_NOCOUNT)
	SetDebugLog(_ArrayToString($aiScoreLimit))
	If UBound($aiScoreLimit) < 2 Then  ;error read score, leave
		SetLog("Fail reading Score", $COLOR_ERROR)
		Return
	EndIf

	SetLog("Your Score is: " & $aiScoreLimit[0], $COLOR_INFO)
	If $aiScoreLimit[0] = $aiScoreLimit[1] Then
		SetLog("You reach Max Point! Congrats")
		$g_bIsCGPointMaxed = True
	EndIf
	Local $OnlyClaimMax = False
	If QuickMIS("BC1", $g_sImgRewardText, 620, 490, 700, 530) Then
		If $g_iQuickMISName = "Claim" Then $OnlyClaimMax = True
	EndIf

	Local $aRewardButton[4] = [800, 490, 0xBDE98A, 10] ;green reward button
	Local $aCGSummary[4] = [825, 490, 0xD8BA30, 10] ;yellow summary Window
	Local $aLowerX[3] = [290, 400, 500]
	Local $Drag = True
	For $i = 0 To 7
		If $OnlyClaimMax Then ExitLoop
		If Not $g_bRunState Then Return
		SetDebugLog("CHECK #" & $i+1, $COLOR_ACTION)
		If _CheckPixel($aRewardButton, True) Then ExitLoop
		
		If $i < 3 Then
			;If QuickMIS("BC1", $g_sImgRewardTileSelected, $aLowerX[$i] - 50, 195, $aLowerX[$i] + 50, 470) Then ;Check if Reward already selected
			;	SetLog("Already select Reward on this Tier, Looking next", $COLOR_ERROR)
			;	ContinueLoop
			;EndIf
			
			Local $aTile = GetCGRewardList()
			If IsArray($aTile) And UBound($aTile) > 0 Then
				For $j = 0 To UBound($aTile) -1
					SetDebugLog("Items: " & $aTile[$j][0] & " Value: " & $aTile[$j][3])
				Next
				Click($aTile[0][1], $aTile[0][2]+10)
				SetLog("Selecting Magic Items:" & $aTile[0][0], $COLOR_INFO)
				_Sleep(1000)
				If IsOKCancelPage() Then ;check if we found gems popup, accept
					SetLog("Magic Item storage is Full (Take gems)", $COLOR_INFO)
					Click(510, 400)
					_Sleep(1000)
				EndIf
				ContinueLoop
			EndIf
			_Sleep(500)
			;SetLog("Selecting Low Reward (gems)", $COLOR_INFO)
			;Click($aLowerX[$i], 420)
			;_Sleep(1000)
			;If IsOKCancelPage() Then ;check if we found gems popup, accept
			;	SetLog("Magic Item storage is Full (Take gems)", $COLOR_INFO)
			;	Click(510, 400)
			;	_Sleep(1000)
			;EndIf
			If _CheckPixel($aRewardButton, True) Then ExitLoop ;check if Reward Button already turns green
		EndIf

		If $Drag Then
			ClickDrag(660, 168, 550, 168, 500)
			_Sleep(3000)
			$Drag = False
		EndIf

		Local $aTile = GetCGRewardList()
		If IsArray($aTile) And UBound($aTile) > 0 Then
			For $j = 0 To UBound($aTile) -1
				SetDebugLog("Items: " & $aTile[$j][0] & " Value: " & $aTile[$j][3])
			Next
			Click($aTile[0][1], $aTile[0][2]+10)
			SetLog("Selecting Magic Items:" & $aTile[0][0], $COLOR_INFO)
			_Sleep(1000)
			If IsOKCancelPage() Then ;check if we found gems popup, accept
				SetLog("Magic Item storage is Full (Take gems)", $COLOR_INFO)
				Click(510, 400)
				_Sleep(1000)
			EndIf
			If _CheckPixel($aRewardButton, True) Then ExitLoop ;check if Reward Button already turns green
		EndIf

	Next

	If $OnlyClaimMax Then
		ClickDrag(660, 168, 550, 168, 500)
		_Sleep(3000)
		Local $aTile = GetCGRewardList(730)
		If IsArray($aTile) And UBound($aTile) > 0 Then
			Click($aTile[0][1], $aTile[0][2]+10)
			SetLog("Selecting Magic Items:" & $aTile[0][0], $COLOR_INFO)
			_Sleep(1000)
			If IsOKCancelPage() Then ;check if we found gems popup, decline
				SetLog("Magic Item storage is Full (Decline)", $COLOR_INFO)
				Click(350, 400) ;Click No
				_Sleep(1000)
				Click(770, 420) ;100 Gems
				_Sleep(1000)
			EndIf
		EndIf
	EndIf

	If _CheckPixel($aRewardButton, True) Then ; Last check, if we found green Reward Button click it
		If Not $bTest Then Click($aRewardButton[0], $aRewardButton[1])
		SetLog("Collecting Reward", $COLOR_SUCCESS)
		If $OnlyClaimMax Then
			CloseClangamesWindow()
			Return
		EndIf
	EndIf

	If $g_bIsCGPointMaxed Then
		_Sleep(3000)
		For $i = 1 To 10
			If Not $g_bRunState Then Return
			SetLog("Waiting Max Point Reward #" & $i, $COLOR_ACTION)
			If WaitforPixel(780, 490, 781,491, "D1D1D1", 10, 1) Then ExitLoop
			_Sleep(500)
		Next
		
		Local $aTile = GetCGRewardList(730)
		If IsArray($aTile) And UBound($aTile) > 0 Then
			Click($aTile[0][1], $aTile[0][2]+10)
			SetLog("Selecting Magic Items:" & $aTile[0][0], $COLOR_INFO)
			_Sleep(1000)
			If IsOKCancelPage() Then ;check if we found gems popup, decline
				SetLog("Magic Item storage is Full (Decline)", $COLOR_INFO)
				Click(350, 400) ;Click No
				_Sleep(1000)
				Click(770, 420) ;100 Gems
				_Sleep(1000)
			EndIf
		Else
			; Image Magic Items Not found, maybe image not exist yet
			Click(770, 420) ;100 Gems
		EndIf
		
		For $i = 1 To 5
			If Not $g_bRunState Then Return
			SetLog("Waiting Reward Button #" & $i, $COLOR_ACTION)
			If _CheckPixel($aRewardButton, True) Then ExitLoop
			_Sleep(1000)
		Next

		If _CheckPixel($aRewardButton, True) Then
			Click($aRewardButton[0], $aRewardButton[1])
			SetLog("Collecting Max Point Reward", $COLOR_SUCCESS)
		EndIf

		CloseClangamesWindow()
		Return
	Else
		If _CheckPixel($aCGSummary, True) Then Click(820, 55)
	EndIf
	CloseClangamesWindow()
EndFunc

Func GetCGRewardList($X = 280)
	Local $aResult[0][4]
	Local $aTier = QuickMIS("CNX", $g_sImgRewardTier, $X, 150, 820, 190) ;search green check on top of Tier
	_ArraySort($aTier, 0, 0, 0, 1) ;Sort by x coord
	;_ArrayDisplay($aTier)
	If IsArray($aTier) And UBound($aTier) > 0 Then
		For $i = 0 To UBound($aTier) - 1
			If Not $g_bRunState Then Return
			SetDebugLog("Checking Tier #" & $i + 1, $COLOR_ACTION)
			If QuickMIS("BC1", $g_sImgRewardTileSelected, $aTier[$i][1] - 50, $aTier[$i][2], $aTier[$i][1] + 50, 470) Then ;Check if Reward already selected
				;SetDebugLog("Already select Reward on this Tier, Looking next", $COLOR_ERROR)
				ContinueLoop
			EndIf

			Local $aTmp = QuickMIS("CNX", $g_sImgRewardItems, $aTier[$i][1] - 50, $aTier[$i][2], $aTier[$i][1] + 50, 470)
			If IsArray($aTmp) And Ubound($aTmp) > 0 Then
				Local $Value = 0
				For $i = 0 To UBound($aTmp) - 1
					Switch $aTmp[$i][0]
						Case "Books"
							$Value = 5
						Case "BBGoldRune", "DERune", "ElixRune", "Shovel", "SuperPot"
							$Value = 4
						Case "BuilderPot", "ClockTowerPot", "PowerPot", "ResearchPot", "TrainingPot", "HeroPot"
							$Value = 3
						Case "DarkElix", "Elix", "Gold", "WallRing"
							$Value = 2
						Case "Gem"
							$Value = 1
					EndSwitch
					_ArrayAdd($aResult, $aTmp[$i][0] & "|" & $aTmp[$i][1] & "|" & $aTmp[$i][2] & "|" & $Value)
				Next
			EndIf
			_ArraySort($aResult, 1, 0, 0, 3)
			Return $aResult
		Next
	EndIf
EndFunc

#Tidy_Off
Func ClanGamesChallenges($sReturnArray, $makeIni = False, $sINIPath = "", $bDebug = False)

	;[0]=ImageName 	 					[1]=Challenge Name		[3]=THlevel 	[4]=Priority/TroopsNeeded 	[5]=Extra/to use in future	[6]=Description
	Local $LootChallenges[6][6] = [ _
			["GoldChallenge", 			"Gold Challenge", 				 7,  5, 8, "Loot certain amount of Gold from a single Multiplayer Battle"								], _ ;|8h 	|50
			["ElixirChallenge", 		"Elixir Challenge", 			 7,  5, 8, "Loot certain amount of Elixir from a single Multiplayer Battle"								], _ ;|8h 	|50
			["DarkEChallenge", 			"Dark Elixir Challenge", 		 8,  5, 8, "Loot certain amount of Dark elixir from a single Multiplayer Battle"						], _ ;|8h 	|50
			["GoldGrab", 				"Gold Grab", 					 6,  3, 1, "Loot a total amount of Gold (accumulated from many attacks) from Multiplayer Battle"		], _ ;|1h-2d 	|100-600
			["ElixirEmbezz", 			"Elixir Embezzlement", 			 6,  3, 1, "Loot a total amount of Elixir (accumulated from many attacks) from Multiplayer Battle"		], _ ;|1h-2d 	|100-600
			["DarkEHeist", 				"Dark Elixir Heist", 			 9,  3, 1, "Loot a total amount of Dark Elixir (accumulated from many attacks) from Multiplayer Battle"	]]   ;|1h-2d 	|100-600

	Local $AirTroopChallenges[14][6] = [ _
			["Ball", 					"Balloon", 						 4, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using certain count of Balloons"		], _ ;|3h-8h	|40-100
			["Heal", 					"Healer", 						 4, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using a Healer"							], _ ;|3h-8h	|40-100
			["Drag", 					"Dragon", 						 7, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using certain count of Dragons"			], _ ;	|3h-8h	|40-100
			["BabyD", 					"Baby Dragon", 					 9, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using certain count of Baby Dragons"	], _ ;|3h-8h	|40-100
			["Edrag", 					"Electro Dragon", 				10, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using certain count of Electro Dragon"	], _ ;	|3h-8h	|40-300
			["RDrag", 					"Dragon Rider", 				10, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using certain count of Dragon Rider"	], _ ;	|3h-8h	|40-300
			["Mini", 					"Minion", 						 7, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using certain count of Minions"			], _ ;|3h-8h	|40-100
			["Lava", 					"Lavahound", 					 9, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using certain count of Lava Hounds"		], _ ;	|3h-8h	|40-100
			["RBall", 					"Rocket Balloon", 				12, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using certain count of Rocket Balloon"], _ ;
			["Smini", 					"Super Minion", 				12, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using certain count of Super Minion"], _ ;
			["InfernoD",				"Inferno Dragon", 				12, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using certain count of Inferno Dragon"], _ ;
			["IceH", 					"Ice Hound", 					13, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using certain count of Ice Hound"], _ ;
			["BattleB", 				"Battle Blimp", 				10, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using a of Battle Blimp"], _ ;
			["StoneS",	 				"Stone Slammer", 				10, 1, 1, "Earn 1-5 Stars (accumulated from many attacks) from Multiplayer Battles using a of Stone Slammer"]]   ;

	Local $GroundTroopChallenges[27][6] = [ _
			["Arch", 					"Archer", 						  6, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Archers"		], _ ;	|3h-8h	|40-100
			["Barb", 					"Barbarian", 					  6, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Barbarians"			], _ ;|3h-8h	|40-100
			["Giant", 					"Giant", 						  6, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Giants"			], _ ;	|3h-8h	|40-100
			["Gobl", 					"Goblin", 						  2, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Goblins"			], _ ;|3h-8h	|40-100
			["Wall", 					"WallBreaker", 					  6, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Wall Breakers"	], _ ;|3h-8h	|40-100
			["Wiza", 					"Wizard", 						  5, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Wizards"			], _ ;|3h-8h	|40-100
			["Hogs", 					"HogRider", 					  7, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Hog Riders"		], _ ;	|3h-8h	|40-100
			["Mine", 					"Miner", 						 10, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Miners"			], _ ;	|3h-8h	|40-100
			["Pekk", 					"Pekka", 						  8, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Pekka"       	], _ ;
			["Witc", 					"Witch", 						  9, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Witches"			], _ ;	|3h-8h	|40-100
			["Bowl", 					"Bowler", 						 10, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Bowlers"			], _ ;	|3h-8h	|40-100
			["Valk", 					"Valkyrie", 					  8, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Valkyries"		], _ ;|3h-8h	|40-100
			["Gole", 					"Golem", 						  8, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Golems"			], _ ;	|3h-8h	|40-100
			["Yeti", 					"Yeti", 						 12, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Yeti" 			], _ ;
			["IceG", 					"IceGolem", 					 11, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Ice Golem" 		], _ ;
			["Hunt", 					"HeadHunters", 					 12, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Head Hunters" 	], _ ;
			["Sbarb", 					"SuperBarbarian", 				 11, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Super Barbarian" ], _ ;
			["Sarch", 					"SuperArcher", 					 11, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Super Archer" 	], _ ;
			["Sgiant", 					"SuperGiant", 					 12, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Super Giant" 	], _ ;
			["Sgobl", 					"SneakyGoblin", 				 11, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Super Goblin" 	], _ ;
			["Swall", 					"SuperWallBreaker", 			 11, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Super Wall Breaker" ], _ ;
			["Swiza", 					"SuperWizard",					 12, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Super Wizard" 	], _ ;
			["Svalk", 					"SuperValkyrie",				 12, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Super Valkyrie"	], _ ;
			["Switc", 					"SuperWitch", 					 12, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using certain count of Super Witch" 	], _ ;
			["WallW", 					"Wall Wrecker", 				 10, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using a Wall Wrecker" 					], _ ;
			["SiegeB", 					"Siege Barrack", 				 10, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using a Siege Barracks" 				], _ ;
			["LogL", 					"Log Launcher", 				 10, 1, 1, "Earn 1-5 Stars from Multiplayer Battles using a Log Launcher"					]]   ;

	Local $BattleChallenges[21][6] = [ _
			["Start", 					"Star Collector", 				 6,  1, 1, "Collect a total amount of Stars (accumulated from many attacks) from Multiplayer Battle"					], _ ;	|8h-2d	|100-600
			["Destruction", 			"Lord of Destruction", 			 6,  1, 1, "Collect a total amount of percentage Destruction % (accumulated from many attacks) from Multiplayer Battle"	], _ ;	|8h-2d	|100-600
			["PileOfVictores", 			"Pile Of Victories", 			 6,  1, 2, "Win 1-5 Multiplayer Battles"																				], _ ;	|8h-2d	|100-600
			["StarThree", 				"Hunt for Three Stars", 		10,  5, 8, "Score a Perfect 3 Stars in Multiplayer Battles"																], _ ;	|8h 	|200
			["WinningStreak", 			"Winning Streak", 				 9,  5, 8, "Win 1-5 Multiplayer Battles in a row"																		], _ ;|8h-2d	|100-600
			["SlayingTitans", 			"Slaying The Titans", 			11,  2, 1, "Win a Multiplayer Battles In Titan League"																	], _ ;|5h		|300
			["NoHero", 					"No Heroics Allowed", 			 3,  5, 5, "Win a stars without using Heroes"																			], _ ;	|8h		|100
			["NoMagic", 				"No-Magic Zone", 				 6,  5, 5, "Win a stars without using Spells"																			], _ ;	|8h		|100
			["Scrappy6s", 				"Scrappy 6s", 					 6,  1, 4, "Gain 3 Stars Against Town Hall level 6"																		], _ ;	|8h		|200
			["Super7s", 				"Super 7s", 					 7,  1, 4, "Gain 3 Stars Against Town Hall level 7"																		], _ ;	|8h		|200
			["Exciting8s", 				"Exciting 8s", 					 8,  1, 4, "Gain 3 Stars Against Town Hall level 8"																		], _ ;	|8h		|200
			["Noble9s", 				"Noble 9s", 					 9,  1, 4, "Gain 3 Stars Against Town Hall level 9"																		], _ ;	|8h		|200
			["Terrific10s", 			"Terrific 10s", 				10,  1, 4, "Gain 3 Stars Against Town Hall level 10"																	], _ ;	|8h		|200
			["Exotic11s", 			    "Exotic 11s", 					11,  1, 4, "Gain 3 Stars Against Town Hall level 11"																	], _ ;	|8h		|200
			["Triumphant12s", 			"Triumphant 12s", 				12,  1, 4, "Gain 3 Stars Against Town Hall level 12"																	], _ ;	|8h		|200
			["AttackUp", 				"Attack Up", 					 6,  1, 8, "Gain 3 Stars Against Town Hall a level higher"																], _ ;|8h		|200
			["ClashOfLegends", 			"Clash of Legends", 			11,  2, 1, "Win a Multiplayer Battles In Legend League"                                                             	], _ ;
			["GainStarsFromClanWars",	"3 Stars From Clan War",		 6,  0, 99, "Gain 3 Stars on Clan War"                                                             						], _ ;
			["SpeedyStars", 			"3 Stars in 60 seconds",		 6,  2, 2, "Gain 3 Stars (accumulated from many attacks) from Multiplayer Battle but only stars gained below a minute counted"], _ ;
			["SuperCharge", 			"Deploy SuperTroops",			 6,  2, 0, "Deploy certain housing space of Any Super Troops"                                                           ], _ ;
			["Tremendous13s", 			"Tremendous 13s", 				13,  1, 4, "Gain 3 Stars Against Town Hall level 13"                                                             		]]   ;

	Local $DestructionChallenges[34][6] = [ _
			["Cannon", 					"Cannon", 				 6,  1, 1,"Destroy 5-25 Cannons in Multiplayer Battles"					], _ ;	|1h-8h	|75-350
			["ArcherT", 				"Archer Tower", 		 6,  1, 1,"Destroy 5-20 Archer Towers in Multiplayer Battles"			], _ ;	|1h-8h	|75-350
			["BuilderHut", 				"Builder Hut", 		     6,  1, 1,"Destroy 4-12 BuilderHut in Multiplayer Battles"				], _ ;	|1h-8h	|40-350
			["Mortar", 					"Mortar", 				 6,  1, 2,"Destroy 4-12 Mortars in Multiplayer Battles"					], _ ;	|1h-8h	|40-350
			["AirD", 					"Air Defenses", 		 7,  2, 3,"Destroy 3-12 Air Defenses in Multiplayer Battles"			], _ ;|1h-8h	|40-350
			["WizardT", 				"Wizard Tower", 		 6,  1, 3,"Destroy 4-12 Wizard Towers in Multiplayer Battles"			], _ ;	|1h-8h	|40-350
			["AirSweepers", 			"Air Sweepers", 		 8,  4, 3,"Destroy 2-6 Air Sweepers in Multiplayer Battles"				], _ ;	|1h-8h	|40-350
			["Tesla", 					"Tesla Towers", 		 7,  5, 3,"Destroy 4-12 Hidden Teslas in Multiplayer Battles"			], _ ;	|1h-8h	|50-350
			["BombT", 					"Bomb Towers", 			 8,  2, 3,"Destroy 2 Bomb Towers in Multiplayer Battles"				], _ ;|1h-8h	|50-350
			["Xbow", 					"X-Bows", 				 9,  5, 4,"Destroy 3-12 X-Bows in Multiplayer Battles"					], _ ;	|1h-8h	|50-350
			["Inferno", 				"Inferno Towers", 		11,  5, 4,"Destroy 2 Inferno Towers in Multiplayer Battles"				], _ ;	|1h-2d	|50-600
			["EagleA", 					"Eagle Artillery", 	    11,  5, 5,"Destroy 1-7 Eagle Artillery in Multiplayer Battles"			], _ ;	|1h-2d	|50-600
			["ClanC", 					"Clan Castle", 			 5,  2, 3,"Destroy 1-4 Clan Castle in Multiplayer Battles"				], _ ;	|1h-8h	|40-350
			["GoldSRaid", 				"Gold Storage", 		 6,  2, 3,"Destroy 3-15 Gold Storages in Multiplayer Battles"			], _ ;	|1h-8h	|40-350
			["ElixirSRaid", 			"Elixir Storage", 		 6,  1, 3,"Destroy 3-15 Elixir Storages in Multiplayer Battles"			], _ ;	|1h-8h	|40-350
			["DarkEStorageRaid", 		"Dark Elixir Storage", 	 8,  3, 3,"Destroy 1-4 Dark Elixir Storage in Multiplayer Battles"		], _ ;	|1h-8h	|40-350
			["GoldM", 					"Gold Mine", 			 6,  1, 1,"Destroy 6-20 Gold Mines in Multiplayer Battles"				], _ ;	|1h-8h	|40-350
			["ElixirPump", 				"Elixir Pump", 		 	 6,  1, 1,"Destroy 6-20 Elixir Collectors in Multiplayer Battles"		], _ ;	|1h-8h	|40-350
			["DarkEPlumbers", 			"Dark Elixir Drill", 	 6,  1, 1,"Destroy 2-8 Dark Elixir Drills in Multiplayer Battles"		], _ ;	|1h-8h	|40-350
			["Laboratory", 				"Laboratory", 			 6,  1, 1,"Destroy 2-6 Laboratories in Multiplayer Battles"				], _ ;	|1h-8h	|40-200
			["SFacto", 					"Spell Factory", 		 6,  1, 1,"Destroy 2-6 Spell Factories in Multiplayer Battles"			], _ ;	|1h-8h	|40-200
			["DESpell", 				"Dark Spell Factory", 	 8,  1, 1,"Destroy 2-6 Dark Spell Factories in Multiplayer Battles"		], _ ;	|1h-8h	|40-200
			["WallWhacker", 			"Wall Whacker", 		 10, 1, 8,"Destroy 50-250 Walls in Multiplayer Battles"					], _ ;	|
			["BBreakdown",	 			"Building Breakdown", 	 6,  1, 1,"Destroy 50-250 Buildings in Multiplayer Battles"				], _ ;		|
			["BKaltar", 				"Barbarian King Altars", 9,  4, 4,"Destroy 2-5 Barbarian King Altars in Multiplayer Battles"	], _ ;|1h-8h	|50-150
			["AQaltar", 				"Archer Queen Altars", 	10,  5, 4,"Destroy 2-5 Archer Queen Altars in Multiplayer Battles"		], _ ;	|1h-8h	|50-150
			["GWaltar", 				"Grand Warden Altars", 	11,  5, 4,"Destroy 2-5 Grand Warden Altars in Multiplayer Battles"		], _ ;	|1h-8h	|50-150
			["HeroLevelHunter", 		"Hero Level Hunter", 	 9,  5, 5,"Knockout 125 Level Heroes on Multiplayer Battles"			], _ ;|8h		|100
			["KingLevelHunter", 		"King Level Hunter", 	 9,  5, 5,"Knockout 50 Level King on Multiplayer Battles"				], _ ;	|8h		|100
			["QueenLevelHunt", 			"Queen Level Hunter", 	10,  5, 5,"Knockout 50 Level Queen on Multiplayer Battles"				], _ ;	|8h		|100
			["WardenLevelHunter", 		"Warden Level Hunter", 	11,  5, 5,"Knockout 20 Level Warden on Multiplayer Battles"				], _ ;	|8h		|100
			["ArmyCamp", 				"Destroy ArmyCamp", 	6,   5, 1,"Destroy 3-16 Army Camp in Multiplayer Battles"				], _ ;	|8h		|100
			["ScatterShotSabotage",		"ScatterShot",			13,  5, 5,"Destroy 1-4 ScatterShot in Multiplayer Battles"				], _ ;
			["ChampionLevelHunt",		"Champion Level Hunter",13,  5, 5,"Knockout 20 Level Champion on Multiplayer Battles"			]]   ;


	Local $MiscChallenges[3][6] = [ _
			["Gard", 					"Gardening Exercise", 			 6,  6, 8, "Clear 5 obstacles from your Home Village or Builder Base"		], _ ; |8h	|50
			["DonateSpell", 			"Donate Spells", 				 9,  6, 8, "Donate a total of 3 spells"				], _ ; |8h	|50
			["DonateTroop", 			"Helping Hand", 				 6,  6, 8, "Donate a total of 45 housing space worth of troops"			]]   ; 	|8h	|50


	Local $SpellChallenges[11][6] = [ _
			["LSpell", 					"Lightning", 					 6,  1, 1, "Use certain amount of Lightning Spell to Win a Stars in Multiplayer Battles"	], _ ;
			["HSpell", 					"Heal",							 6,  2, 1, "Use certain amount of Heal Spell to Win a Stars in Multiplayer Battles"			], _ ; updated 25/01/2021
			["RSpell", 					"Rage", 					 	 6,  2, 1, "Use certain amount of Rage Spell to Win a Stars in Multiplayer Battles"			], _ ;
			["JSpell", 					"Jump", 					 	 6,  2, 1, "Use certain amount of Jump Spell to Win a Stars in Multiplayer Battles"			], _ ;
			["FSpell", 					"Freeze", 					 	 9,  1, 1, "Use certain amount of Freeze Spell to Win a Stars in Multiplayer Battles"		], _ ;
			["CSpell", 					"Clone", 					 	11,  3, 1, "Use certain amount of Clone Spell to Win a Stars in Multiplayer Battles"		], _ ;
			["PSpell", 					"Poison", 					 	 6,  1, 1, "Use certain amount of Poison Spell to Win a Stars in Multiplayer Battles"		], _ ;
			["ESpell", 					"Earthquake", 					 6,  1, 1, "Use certain amount of Earthquake Spell to Win a Stars in Multiplayer Battles"	], _ ;
			["HaSpell", 				"Haste",	 					 6,  1, 1, "Use certain amount of Haste Spell to Win a Stars in Multiplayer Battles"		], _ ; updated 25/01/2021
			["SkSpell",					"Skeleton", 					11,  1, 1, "Use certain amount of Skeleton Spell to Win a Stars in Multiplayer Battles"		], _ ;
			["BtSpell",					"Bat", 					 		10,  1, 1, "Use certain amount of Bat Spell to Win a Stars in Multiplayer Battles"			]]   ;

    Local $BBBattleChallenges[4][6] = [ _
            ["StarM",					"BB Star Master",				6,  1, 1, "Collect certain amount of stars in Versus Battles"						], _ ; Earn 6 - 24 stars on the BB
            ["Victories",				"BB Victories",					6,  5, 3, "Get certain count of Victories in Versus Battles"						], _ ; Earn 3 - 6 victories on the BB
			["StarTimed",				"BB Star Timed",				6,  2, 2, "Earn stars in Versus Battles, but only stars gained below a minute counted"	], _
            ["Destruction",				"BB Destruction",				6,  1, 1, "Earn certain amount of destruction percentage (%) in Versus Battles"			]] ; Earn 225% - 900% on BB attacks

	Local $BBDestructionChallenges[18][6] = [ _
            ["Airbomb",					"Air Bomb",                 	6,  1, 4, "Destroy certain number of Air Bomb in Versus Battles"		], _
			["BuildingDes",             "BB Building",					6,  1, 4, "Destroy certain number of Building in Versus Battles"		], _
			["BuilderHall",             "BuilderHall",					6,  1, 2, "Destroy certain number of Builder Hall in Versus Battles"	], _
            ["Cannon",                 	"BB Cannon",                  	6,  1, 1, "Destroy certain number of Cannon in Versus Battles"			], _
			["ClockTower",             	"Clock Tower",                 	6,  1, 1, "Destroy certain number of Clock Tower in Versus Battles"		], _
            ["DoubleCannon",         	"Double Cannon",             	6,  1, 1, "Destroy certain number of Double Cannon in Versus Battles"	], _
			["FireCrackers",         	"Fire Crackers",              	6,  1, 2, "Destroy certain number of Fire Crackers in Versus Battles"	], _
			["GemMine",                 "Gem Mine",                  	6,  1, 1, "Destroy certain number of Gem Mine in Versus Battles"		], _
			["GiantCannon",             "Giant Cannon",               	6,  1, 4, "Destroy certain number of Giant Cannon in Versus Battles"	], _
			["GuardPost",               "Guard Post",                 	6,  1, 4, "Destroy certain number of Guard Post in Versus Battles"		], _
			["MegaTesla",               "Mega Tesla",               	6,  1, 5, "Destroy certain number of Mega Tesla in Versus Battles"		], _
			["MultiMortar",             "Multi Mortar",               	6,  1, 2, "Destroy certain number of Multi Mortar in Versus Battles"	], _
			["Roaster",                 "Roaster",			            6,  1, 4, "Destroy certain number of Roaster in Versus Battles"			], _
			["StarLab",                 "Star Laboratory",              6,  1, 1, "Destroy certain number of Star Laboratory in Versus Battles"	], _
			["WallDes",             	"Wall Whacker",              	6,  1, 2, "Destroy certain number of Wall in Versus Battles"			], _
			["Crusher",             	"Crusher",                 		6,  1, 2, "Destroy certain number of Crusher in Versus Battles"			], _
			["ArcherTower",             "Archer Tower",            		6,  1, 1, "Destroy certain number of Archer Tower in Versus Battles"	], _
			["LavaLauncher",            "Lava Launcher",           		6,  1, 5, "Destroy certain number of Lava Launcher in Versus Battles"	]]

	Local $BBTroopsChallenges[11][6] = [ _
            ["RBarb",					"Raged Barbarian",              6,  1, 1, "Win 1-5 Attacks using Raged Barbarians in Versus Battle"	], _ ;BB Troops
            ["SArch",                 	"Sneaky Archer",                6,  1, 1, "Win 1-5 Attacks using Sneaky Archer in Versus Battle"	], _
            ["BGiant",         			"Boxer Giant",             		6,  1, 1, "Win 1-5 Attacks using Boxer Giant in Versus Battle"		], _
			["BMini",         			"Beta Minion",              	6,  1, 1, "Win 1-5 Attacks using Beta Minion in Versus Battle"		], _
			["Bomber",                 	"Bomber",                  		6,  1, 1, "Win 1-5 Attacks using Bomber in Versus Battle"			], _
			["BabyD",               	"Baby Dragon",                 	6,  1, 1, "Win 1-5 Attacks using Baby Dragon in Versus Battle"		], _
			["CannCart",             	"Cannon Cart",               	6,  1, 1, "Win 1-5 Attacks using Cannon Cart in Versus Battle"		], _
			["NWitch",                 	"Night Witch",                 	6,  1, 1, "Win 1-5 Attacks using Night Witch in Versus Battle"		], _
			["DShip",                 	"Drop Ship",                  	6,  1, 1, "Win 1-5 Attacks using Drop Ship in Versus Battle"		], _
			["SPekka",                 	"Super Pekka",                  6,  1, 1, "Win 1-5 Attacks using Super Pekka in Versus Battle"		], _
			["HGlider",                 "Hog Glider",                  	6,  1, 1, "Win 1-5 Attacks using Hog Glider in Versus Battle"		]]


	; Just in Case
	Local $LocalINI = $sINIPath
	If $LocalINI = "" Then $LocalINI = StringReplace($g_sProfileConfigPath, "config.ini", "ClanGames_config.ini")

	If $bDebug Then Setlog(" - Ini Path: " & $LocalINI)

	; Variables to use
	Local $section[4] = ["Loot Challenges", "Battle Challenges", "Destruction Challenges", "Misc Challenges"]
	Local $array[4] = [$LootChallenges, $BattleChallenges, $DestructionChallenges, $MiscChallenges]
	Local $ResultIni = "", $TempChallenge, $tempXSector

	; Store variables
	If Not $makeIni Then

		Switch $sReturnArray
			Case "$AirTroopChallenges"
				Return $AirTroopChallenges
			Case "$GroundTroopChallenges"
				Return $GroundTroopChallenges
			Case "$SpellChallenges"
				Return $SpellChallenges
            Case "$BBBattleChallenges"
                Return $BBBattleChallenges
			Case "$BBDestructionChallenges"
				Return $BBDestructionChallenges
			Case "$BBTroopsChallenges"
				Return $BBTroopsChallenges
			Case "$LootChallenges"
				$TempChallenge = $array[0]
				$tempXSector = $section[0]
			Case "$BattleChallenges"
				$TempChallenge = $array[1]
				$tempXSector = $section[1]
			Case "$DestructionChallenges"
				$TempChallenge = $array[2]
				$tempXSector = $section[2]
			Case "$MiscChallenges"
				$TempChallenge = $array[3]
				$tempXSector = $section[3]
		EndSwitch
		; Read INI File
		If $bDebug Then SetLog("[" & $tempXSector & "]")
		For $j = 0 To UBound($TempChallenge) - 1
			$ResultIni = Int(IniRead($LocalINI, $tempXSector, $TempChallenge[$j][1], $TempChallenge[$j][3]))
			$TempChallenge[$j][3] = IsNumber($ResultIni) = 1 ? Int($ResultIni) : 0
			If $TempChallenge[$j][3] > 5 Then $TempChallenge[$j][3] = 5
			If $TempChallenge[$j][3] < 0 Then $TempChallenge[$j][3] = 0
			If $bDebug Then SetLog(" - " & $TempChallenge[$j][1] & ": " & $TempChallenge[$j][3])
			$ResultIni = ""
		Next
		Return $TempChallenge
	Else

		; Write INI File
		Local $File = FileOpen($LocalINI, $FO_APPEND)
		Local $HelpText = "; - MyBotRun 2020 - " & @CRLF & _
				"; - 'Event name' = 'Priority' [1~5][easiest to the hardest] , '0' to disable the event" & @CRLF & _
				"; - Remember on GUI you can enable/disable an entire Section" & @CRLF & _
				"; - Do not change any event name" & @CRLF & _
				"; - Deleting this file will restore the defaults values." & @CRLF & @CRLF
		FileWrite($File, $HelpText)
		FileClose($File)
		For $i = 0 To UBound($array) - 1
			$TempChallenge = $array[$i]
			If $bDebug Then Setlog("[" & $section[$i] & "]")
			For $j = 0 To UBound($TempChallenge) - 1
				If IniWrite($LocalINI, $section[$i], $TempChallenge[$j][1], $TempChallenge[$j][3]) <> 1 Then SetLog("Error on :" & $section[$i] & "|" & $TempChallenge[$j][1], $COLOR_WARNING)
				If $bDebug Then SetLog(" - " & $TempChallenge[$j][1] & ": " & $TempChallenge[$j][3])
				If _sleep(100) Then Return
			Next
			$TempChallenge = Null
		Next
	EndIf
EndFunc   ;==>ClanGamesChallenges
#Tidy_Off
