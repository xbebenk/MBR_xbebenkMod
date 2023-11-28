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
Func _ClanGames($test = False, $OnlyPurge = False)
	$g_bIsBBevent = False ;just to be sure, reset to false
	$g_bIsCGEventRunning = False ;just to be sure, reset to false
	$g_bForceSwitchifNoCGEvent = False ;just to be sure, reset to false
	$g_bIsCGPointAlmostMax = False ;just to be sure, reset to false
	$g_bisCGPointMaxed = False ;just to be sure, reset to false
	$g_sCGCurrentEventName = ""

	Local $PurgeDayMinute = ($g_iCmbClanGamesPurgeDay + 1) * 1440
	; Check If this Feature is Enable on GUI.
	If Not $g_bChkClanGamesEnabled Then Return
	If $g_iTownHallLevel <= 5 Then
		SetLog("TownHall Level : " & $g_iTownHallLevel & ", Skip Clan Games", $COLOR_INFO)
		Return
	Endif

	;Prevent checking clangames before date 22 (clangames should start on 22 and end on 28 or 29) depends on how many tiers/maxpoint
	Local $currentDate = Number(@MDAY)
	If $currentDate > 4 And $currentDate < 21 Then
		SetLog("Current date : " & $currentDate & ", Skip Clan Games", $COLOR_INFO)
		Return
	EndIf

	If CloseClangamesWindow() Then _Sleep(1000)
	If CheckMainScreen(False, $g_bStayOnBuilderBase, "ClanGames") Then ZoomOut()
	If _Sleep(500) Then Return
	SetLog("Entering Clan Games", $COLOR_INFO)
	If Not $g_bRunState Then Return
	; Local and Static Variables
	Local $sTimeRemain = "", $sEventName = "", $getCapture = True
	Local Static $YourAccScore[16][2] = [[-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], _
										[-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True]]

	Local $iWaitPurgeScore = 150

	; Enter on Clan Games window
	If IsClanGamesWindow() Then
		Local $sTempPath = @TempDir & "\" & $g_sProfileCurrentName & "\Challenges\"

		;now we need to copy selected challenge before checking current running event is not wrong event selected

		; Let's get some information , like Remain Timer, Score and limit
		If Not _ColorCheck(_GetPixelColor(300, 284, True), Hex(0x53E052, 6), 10) Then ;no greenbar = there is active event or completed event
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
							StartsEvent($EventName[2], True, False)
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
			StartsEvent($EventName[2], True, True)
		EndIf
		If _Sleep(1500) Then Return
		CloseClangamesWindow()
		Return False
	EndIf

	Local $aAllEvent = FindEvent()

	If UBound($aAllEvent) > 0 Then
		If $g_bSortClanGames Then
			Switch $g_iSortClanGames
				Case 0 ;sort by Difficulty
					_ArraySort($aAllEvent, 0, 0, 0, 3) ;sort ascending, lower difficulty = easiest
				Case 1 ;sort by Time
					_ArraySort($aAllEvent, 1, 0, 0, 4) ;sort descending, longest time first
				Case 2 ;sort by Score
					_ArraySort($aAllEvent, 1, 0, 0, 6) ;sort descending, Higher score first
			EndSwitch
		EndIf
		If $g_bChkClanGamesStopBeforeReachAndPurge And Number($aiScoreLimit[0]) > Number($aiScoreLimit[1]) - 1000 Then _ArraySort($aAllEvent, 1, 0, 0, 6) ;sort descending, Force Higher score first
		For $i = 0 To UBound($aAllEvent) - 1
			If Not $g_bRunState Then Return
			If $g_bChkClanGamesDebug Then SetLog("$aAllEvent: " & @CRLF & _ArrayToString($aAllEvent), $COLOR_DEBUG2)
			Setlog("Next Event will be " & $aAllEvent[$i][0] & " to make in " & $aAllEvent[$i][4] & " min.")
			; if enabled stop and purge, more than 1 day CG time, and event score will make clangames maxpoint, and there is another event on array
			If $g_bChkClanGamesStopBeforeReachAndPurge And $sTimeCG > $PurgeDayMinute And (Number($aiScoreLimit[0]) + Number($aAllEvent[$i][6])) >= Number($aiScoreLimit[1]) Then
				If $i < UBound($aAllEvent) - 1 Then
					SetLog($aAllEvent[$i][0] & ", score:" & $aAllEvent[$i][6], $COLOR_INFO)
					SetLog("Doing this challenge will maxing score, looking next", $COLOR_INFO)
					ContinueLoop
				Else
					SetLog($aAllEvent[$i][0] & ", score:" & $aAllEvent[$i][6], $COLOR_INFO)
					SetLog("Doing this challenge will maxing score", $COLOR_INFO)
					SetLog("Now lets just purge", $COLOR_INFO)
					ExitLoop ; there is no next event, so exit and just purge
				EndIf
			EndIf
			
			; Select and Start EVENT
			$sEventName = $aAllEvent[$i][0]
			If Not QuickMIS("BC1", $sTempPath & "Selected\", $aAllEvent[$i][1] - 60, $aAllEvent[$i][2] - 60, $aAllEvent[$i][1] + 60, $aAllEvent[$i][2] + 60, True) Then
				SetLog($sEventName & " not found on previous location detected", $COLOR_ERROR)
				SetLog("Maybe event tile changed, Looking Next Event...", $COLOR_INFO)
				ContinueLoop
			EndIf

			Click($aAllEvent[$i][1], $aAllEvent[$i][2])
			If _Sleep(1750) Then Return
			;_ArrayDisplay($aAllEvent)
			Return ClickOnEvent($YourAccScore, $aiScoreLimit, $sEventName, $getCapture)
		Next
	EndIf

	If $g_bChkClanGamesPurgeAny Then ; still have to purge, because no enabled event on setting found
		SetLog("Still have to purge, because no enabled event on setting found", $COLOR_WARNING)
		Local $aEvent = FindEventToPurge($sTempPath)
		If IsArray($aEvent) And UBound($aEvent) > 0 Then
			Local $EventName = StringSplit($aEvent[0][0], "-")
			SetLog("Detected Event to Purge: " & $EventName[2])
			Click($aEvent[0][1], $aEvent[0][2])
			If _Sleep(1500) Then Return
			StartsEvent($EventName[2], True, False)
		Else
			SetLog("No Event found, lets purge 1 most top event", $COLOR_WARNING)
			If $g_bChkClanGamesDebug Then SaveDebugImage("ClanGames_Challenges", True)
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
			Local $CGMainLoot = ClanGamesChallenges("L")
			For $i = 0 To UBound($g_abCGMainLootItem) - 1
				If $g_abCGMainLootItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "LootChallenges: " & $CGMainLoot[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainLoot[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainLoot[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "B"
			Local $CGMainBattle = ClanGamesChallenges("B")
			For $i = 0 To UBound($g_abCGMainBattleItem) - 1
				If $g_abCGMainBattleItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "BattleChallenges: " & $CGMainBattle[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainBattle[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainBattle[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "D"
			Local $CGMainDestruction = ClanGamesChallenges("D")
			For $i = 0 To UBound($g_abCGMainDestructionItem) - 1
				If $g_abCGMainDestructionItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "DestructionChallenges: " & $CGMainDestruction[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainDestruction[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainDestruction[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "A"
			Local $CGMainAir = ClanGamesChallenges("A")
			For $i = 0 To UBound($g_abCGMainAirItem) - 1
				If $g_abCGMainAirItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "AirTroopChallenges: " & $CGMainAir[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainAir[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainAir[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "G"
			Local $CGMainGround = ClanGamesChallenges("G")
			For $i = 0 To UBound($g_abCGMainGroundItem) - 1
				If $g_abCGMainGroundItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "GroundTroopChallenges: " & $CGMainGround[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainGround[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainGround[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "M"
			Local $CGMainMisc = ClanGamesChallenges("M")
			For $i = 0 To UBound($g_abCGMainMiscItem) - 1
				If $g_abCGMainMiscItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "MiscChallenges: " & $CGMainMisc[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainMisc[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainMisc[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "S"
			Local $CGMainSpell = ClanGamesChallenges("S")
			For $i = 0 To UBound($g_abCGMainSpellItem) - 1
				If $g_abCGMainSpellItem[$i] > 0 And Not $g_bChkCGBBAttackOnly Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "SpellChallenges: " & $CGMainSpell[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainSpell[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGMainSpell[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "BBB"
			Local $CGBBBattle = ClanGamesChallenges("BBB")
			For $i = 0 To UBound($g_abCGBBBattleItem) - 1
				If $g_abCGBBBattleItem[$i] > 0 Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "BBBattleChallenges: " & $CGBBBattle[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGBBBattle[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGBBBattle[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "BBD"
			Local $CGBBDestruction = ClanGamesChallenges("BBD")
			For $i = 0 To UBound($g_abCGBBDestructionItem) - 1
				If $g_abCGBBDestructionItem[$i] > 0 Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "BBDestructionChallenges: " & $CGBBDestruction[$i][1], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGBBDestruction[$i][0] & "_*", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				Else
					FileCopy($sImagePath & "\" & $sImageType & "-" & $CGBBDestruction[$i][0] & "_*", $sTempPath & "\Purge\", $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "BBT"
			Local $CGBBTroops = ClanGamesChallenges("BBT")
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

Func GetCGDiff($sEventName)
	If $sEventName = "" Then Return 0
	Local $aEvent = StringSplit($sEventName, "-", $STR_NOCOUNT)
	If UBound($aEvent) = 2 Then 
		Local $aChallenges = ClanGamesChallenges($aEvent[0])
		Local $iIndex = _ArraySearch($aChallenges, $aEvent[1], 0, 0, 0, 0, 1, 0)
		If $iIndex <> -1 Then
			Return $aChallenges[$iIndex][4]
		EndIf
	EndIf
EndFunc

Func FindEvent($bTestAllImage = False, $useBC1 = False)
	; Initial Timer
	Local $hTimer = TimerInit()

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

	Local $HowManyImages = _FileListToArray($bTestAllImage ? $sImagePath : $sTempPath, "*", $FLTA_FILES)
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
	
	If Not $g_bRunState Then Return
	Local $sImagePath = @ScriptDir & "\imgxml\Resources\ClanGamesImages\Challenges"
	Local $sTempPath = @TempDir & "\" & $g_sProfileCurrentName & "\Challenges\"
	Local $aEvent, $aReturn[0][7]
	Local $aX[4] = [295, 427, 561, 696]
	Local $aY[2] = [167, 336]

	If Not $useBC1 Then
		For $y = 0 To Ubound($aY) - 1
			For $x = 0 To Ubound($aX) - 1
				If Not $g_bRunState Then Return
				Local $hITimer = TimerInit()
				$aEvent = QuickMIS("CNX", $bTestAllImage ? $sImagePath : $sTempPath, $aX[$x], $aY[$y], $aX[$x] + 90, $aY[$y] + 80)
				If IsArray($aEvent) And UBound($aEvent) > 0 Then
					If $g_bChkClanGamesDebug Then Setlog("Benchmark Search on Slot: (in " & Round(TimerDiff($hITimer) / 1000, 2) & " seconds)", $COLOR_DEBUG)
					Local $IsBBEvent = (IsBBChallenge($aEvent[0][1], $aEvent[0][2]) ? "CGBB" : "CGMain")
					If checkEventWithShareImage($IsBBEvent, $aEvent[0][0]) Then ContinueLoop
					ClanGameImageCopy($sImagePath, $sTempPath, "Selected", $aEvent[0][0])
					Local $iDiff = GetCGDiff($aEvent[0][0])
					_ArrayAdd($aReturn, $aEvent[0][0] & "|" & $aEvent[0][1] & "|" & $aEvent[0][2] & "|" & $iDiff & "|" & 0 & "|" & $IsBBEvent)
				EndIf
			Next
		Next
	Else
		For $y = 0 To Ubound($aY) - 1
			For $x = 0 To Ubound($aX) - 1
				If Not $g_bRunState Then Return
				Local $hITimer = TimerInit()
				If QuickMIS("BC1", $bTestAllImage ? $sImagePath : $sTempPath, $aX[$x], $aY[$y], $aX[$x] + 90, $aY[$y] + 80) Then
					If $g_bChkClanGamesDebug Then Setlog("Benchmark Search on Slot: (in " & Round(TimerDiff($hITimer) / 1000, 2) & " seconds)", $COLOR_DEBUG)
					Local $BC1x = $g_iQuickMISX, $BC1y = $g_iQuickMISY
					Local $ChallengeEvent = $g_iQuickMISName
					Local $IsBBEvent = (IsBBChallenge($g_iQuickMISX, $g_iQuickMISY) ? "CGBB" : "CGMain")
					If checkEventWithShareImage($IsBBEvent, $ChallengeEvent) Then ContinueLoop
					ClanGameImageCopy($sImagePath, $sTempPath, "Selected", $ChallengeEvent)
					Local $iDiff = GetCGDiff($ChallengeEvent)
					_ArrayAdd($aReturn, $ChallengeEvent & "|" & $BC1x & "|" & $BC1y & "|" & $iDiff & "|" & 0 & "|" & $IsBBEvent)
				EndIf
			Next
		Next
	EndIf
	If $g_bChkClanGamesDebug Then Setlog("AllEvents: " & @CRLF & _ArrayToString($aReturn), $COLOR_DEBUG2)
	If $g_bChkClanGamesDebug Then Setlog("Benchmark Search Event: (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_DEBUG)
	
	SelectEvent($aReturn)
	Return $aReturn
EndFunc

Func checkEventWithShareImage($sEventType = "CGMain", $sEventName = "")
	Local $bRet = False
	If $g_bChkClanGamesDebug Then Setlog("bBBEvent:" & $sEventType & ", sEventName:" & $sEventName, $COLOR_DEBUG2)
	If $sEventType = "CGMain" Then
		If $g_abCGMainDestructionItem[23] < 1 And (StringInStr($sEventName, "BuildingDes") Or StringInStr($sEventName, "BBreakdown")) Then 
			SetLog("Building Desctruction Challenge not Enabled, Should skip!", $COLOR_ACTION)
			$bRet = True ;BBreakdown
		EndIf
		If $g_abCGMainDestructionItem[22] < 1 And (StringInStr($sEventName, "WallDes") Or StringInStr($sEventName, "WallWhacker")) Then 
			SetLog("Wall Desctruction Challenge not Enabled, Should skip!", $COLOR_ACTION)
			$bRet = True ;WallWhacker
		EndIf
	EndIf
	Return $bRet
EndFunc

Func SelectEvent(ByRef $aSelectChallenges)
	; Initial Timer
	Local $hTimer = TimerInit()
	Local $aTmp = $aSelectChallenges

	For $i = 0 To UBound($aTmp) - 1
		If Not $g_bRunState Then Return
		Local $aEventInfo = GetEventInfo($aTmp[$i][1], $aTmp[$i][2])
		If IsArray($aEventInfo) Then
			Setlog("Detected " & $aTmp[$i][0] & " difficulty of " & $aTmp[$i][3] & " [score:" & $aEventInfo[0] & ", " & $aEventInfo[1] & " min]", $COLOR_INFO)
			If $g_bChkClanGames3H And Number($aEventInfo[1]) >= 180 Then ;Filter under 3 Hour event
				_ArrayDelete($aSelectChallenges, $i)
				ContinueLoop 
			EndIf
			$aTmp[$i][4] = Number($aEventInfo[1])
			$aTmp[$i][6] = Number($aEventInfo[0])
		Else
			Click(210, 55)
			Setlog("Fail get event info", $COLOR_ERROR) ; fail get event info, mostly because lag
			_ArrayDelete($aSelectChallenges, $i)
			ContinueLoop 
		EndIf
		Click($aTmp[$i][1], $aTmp[$i][2])
		If _Sleep(250) Then Return
	Next
	
	$aSelectChallenges = $aTmp
	
	If $g_bChkClanGamesDebug Then Setlog("Benchmark SelectEvent: (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_DEBUG)
	; Drop to top again , because coordinates Xaxis and Yaxis
	Click(450, 55)
	If _Sleep(1000) Then Return
	Click(300, 55)
	If _Sleep(1000) Then Return
EndFunc

Func IsClanGamesWindow()
	Local $sState, $bRet = False

	If QuickMIS("BC1", $g_sImgCaravan, 200, 55, 330, 155) Then
		SetLog("Caravan available! Entering Clan Games", $COLOR_SUCCESS)
		Click($g_iQuickMISX, $g_iQuickMISY)
		; Just wait for window open
		For $i = 1 To 10
			If _Sleep(500) Then Return
			If IsFullScreenWindow() Then ExitLoop
		Next
		If _Sleep(1000) Then Return
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

Func IsClanGamesRunning() ;to check whether clangames current state, return string of the state "prepare" "running" "end"
	Local $aGameTime[4] = [384, 388, 0xFFFFFF, 10]
	Local $sState = "Running"
	If QuickMIS("BC1", $g_sImgWindow, 50, 50, 150, 200) Then
		SetLog("Window Opened", $COLOR_DEBUG)
		If QuickMIS("BC1", $g_sImgRewardText, 600, 445, 830, 495) Then
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
	$sTimeRemain = StringReplace(getOcrTimeGameTime(55, 496), " ", "") ; read Clan Games waiting time

	;Check if OCR returned a valid timer format
	If Not StringRegExp($sTimeRemain, "([0-2]?[0-9]?[DdHhSs]+)", $STR_REGEXPMATCH, 1) Then
		SetLog("getOcrTimeGameTime(): no valid return value (" & $sTimeRemain & ")", $COLOR_ERROR)
	EndIf

	SetLog("Clan Games time remaining: " & $sTimeRemain, $COLOR_INFO)

	; This Loop is just to check if the Score is changing , when you complete a previous events is necessary to take some time
	For $i = 0 To 10
		$sYourGameScore = getOcrYourScore(48, 560) ;  Read your Score
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
	Local $aEventFailed[4] = [300, 300, 0xEA2B26, 20]
	Local $aEventPurged[4] = [542, 222, 0x4F85C5, 10]

	If $bOpenWindow Then
		CloseClangamesWindow()
		SetLog("Entering Clan Games", $COLOR_INFO)
		If Not IsClanGamesWindow() Then Return
	EndIf
	; Check if any event is running or not
	If Not _ColorCheck(_GetPixelColor(300, 285, True), Hex(0x53E052, 6), 10) Then ; Green Bar from First Position
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
			Local $aActiveEvent = QuickMIS("CNX", @TempDir & "\" & $g_sProfileCurrentName & "\Challenges\", 294, 166, 386, 257)
			If IsArray($aActiveEvent) And UBound($aActiveEvent) > 0 Then
				SetLog("Active Challenge " & $aActiveEvent[0][0] & " is Enabled on Setting, OK!!", $COLOR_DEBUG)
				;check if Challenge is BB Challenge, enabling force BB attack
				If $g_bChkForceBBAttackOnClanGames Then
					Click(340, 215) ; click first slot
					
					For $i = 1 To 10
						If QuickMIS("BC1", $g_sImgTrashPurge, 100, 100, 700, 550, True) Then
							ExitLoop
						Else
							SetDebugLog("waiting for trash #" & $i)
						EndIf
						_Sleep(500)
					Next
					
					SetLog("Re-Check If Running Challenge is BB Event or No?", $COLOR_DEBUG)
					If QuickMIS("BC1", $g_sImgVersus, 425, 190, 730, 250) Then
						$g_bIsBBevent = True
						$g_sCGCurrentEventName = $aActiveEvent[0][0]
						$g_bIsCGEventRunning = True
						Setlog("Running Challenge is BB Challenge : " & $g_sCGCurrentEventName, $COLOR_INFO)
					Else
						Setlog("Running Challenge is MainVillage Challenge", $COLOR_INFO)
						If $aActiveEvent[0][0] = "BBD-WallDes" Or $aActiveEvent[0][0] = "BBD-BuildingDes" Then
							SetLog("Event with shared Image: " & $aActiveEvent[0][0])
							If $g_abCGMainDestructionItem[23] < 1 Then $bNeedPurge = True ;BBreakdown
							If $g_abCGMainDestructionItem[22] < 1 Then $bNeedPurge = True ;WallWhacker
						EndIf
						If $g_bChkCGBBAttackOnly Or $bNeedPurge Then ;Purge main village event because we using BBCGOnly Mode
							Setlog("We are running only BB events. Event started by mistake?", $COLOR_ERROR)
							Click(340, 215) ;unclick so ForcePurgeEvent can work
							ForcePurgeEvent(False, False)
						EndIf
						$g_bIsBBevent = False
					EndIf
				EndIf
			Else
				Setlog("Active Challenge Not Enabled on Setting! started by mistake?", $COLOR_ERROR)
				_CaptureRegion2(294, 166, 386, 257)
				SaveDebugImage("CG-FailVerifyChallenge", False)
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
			$Text = "You got " & $ScoreLimits[0] - $YourAccScore[$g_iCurAccount][0] & " points on the last event."
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
	If Not StartsEvent($sEventName, False) Then Return False
	CloseClangamesWindow()
	Return True
EndFunc   ;==>ClickOnEvent

Func StartsEvent($sEventName, $g_bPurgeJob = False, $OnlyPurge = False)
	If Not $g_bRunState Then Return

	If QuickMIS("BC1", $g_sImgStart, 220, 150, 830, 580) Then
		Local $aTimer = GetEventTimeScore($g_iQuickMISX, $g_iQuickMISY)
		SetLog("Starting Event " & $sEventName & " [score:" & $aTimer[0] & ", " & $aTimer[1] & " min]", $COLOR_SUCCESS)
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
					Click(530, 420)
					SetLog("StartsEvent and Purge job!", $COLOR_SUCCESS)
					GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - Purging : " & $sEventName & ($OnlyPurge ? ", PurgeBeforeSwitch" : ", NoEventFound"), 1)
					_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - Purging : " & $sEventName & ($OnlyPurge ? ", PurgeBeforeSwitch" : ", NoEventFound"))
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
			Click(450, 99) ;Click Clan Tab
			If _Sleep(3000) Then Return
			Click(310, 99) ;Click Challenge Tab
			If _Sleep(500) Then Return
			Click(340, 215) ;Click Active Challenge
			
			For $i = 1 To 10
				If QuickMIS("BC1", $g_sImgTrashPurge, 100, 100, 700, 550, True) Then
					ExitLoop
				Else
					SetDebugLog("waiting for trash #" & $i)
				EndIf
				_Sleep(500)
			Next

			SetLog("Re-Check If Running Challenge is BB Event or No?", $COLOR_DEBUG)
			If QuickMIS("BC1", $g_sImgVersus, 425, 190, 700, 250) Then
				$g_bIsBBevent = True
				$g_sCGCurrentEventName = $sEventName
				Setlog("Running Challenge is BB Challenge : " & $g_sCGCurrentEventName, $COLOR_INFO)
			Else
				Setlog("Running Challenge is MainVillage Challenge", $COLOR_INFO)
				$g_bIsBBevent = False
			EndIf
		EndIf
		Return True
	Else
		SetLog("Didn't Get the Green Start Button Event", $COLOR_WARNING)
		CloseClangamesWindow()
		Return False
	EndIf

EndFunc   ;==>StartsEvent

Func ForcePurgeEvent($bTest = False, $startFirst = True)
	Local $count1 = 0, $count2 = 0

	Click(340, 215) ;Most Top Challenge

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
		While Not WaitforPixel(580, 323, 582, 324, "F71E22", 10, 1)
			SetDebugLog("Waiting for trash Button", $COLOR_DEBUG)
			$count1 += 1
			If _Sleep(500) Then Return
			If $count1 > 10 Then ExitLoop
		Wend
		If QuickMIS("BC1", $g_sImgTrashPurge, 400, 200, 700, 350) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			SetLog("Click Trash", $COLOR_INFO)
			While Not IsOKCancelPage()
				SetDebugLog("Waiting for trash Confirm OK", $COLOR_DEBUG)
				$count2 += 1
				If _Sleep(500) Then Return
				If $count2 > 10 Then ExitLoop
			Wend
			If IsOKCancelPage() Then
				SetLog("Click OK", $COLOR_INFO)
				If $bTest Then Return
				Click(530, 420)
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
			If _Sleep(500) Then Return
			If $count1 > 10 Then ExitLoop
		Wend

		If QuickMIS("BC1", $g_sImgTrashPurge, 400, 200, 700, 350) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			SetLog("Click Trash", $COLOR_INFO)
			While Not IsOKCancelPage()
				SetDebugLog("Waiting for trash Confirm OK", $COLOR_DEBUG)
				$count2 += 1
				If _Sleep(500) Then Return
				If $count2 > 10 Then ExitLoop
			Wend
			If IsOKCancelPage() Then
				SetLog("Click OK", $COLOR_INFO)
				If $bTest Then Return
				Click(530, 420)
				SetLog("StartAndPurgeEvent!", $COLOR_SUCCESS)
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
	Local $aX[4] = [295, 427, 561, 696]
	Local $aY[2] = [167, 336]

	For $y = 0 To Ubound($aY) - 1
		For $x = 0 To Ubound($aX) - 1
			$aEvent = QuickMIS("CNX", $sTempPath & "Purge\", $aX[$x], $aY[$y], $aX[$x] + 100, $aY[$y] + 100)
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
	Local $YAxis = $iYStartBtn + 7 ; Related to Start Button

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

Func GetEventInfo($x, $y)
	Local $xRegion = 0, $yRegion = 300
	
	If $y > 270 Then $yRegion = 410
	;If $y > 430 Then $yRegion = 440
	
	If $x < 405 Then $xRegion = 600
	If $x > 405 Then $xRegion = 274
	If $x > 530 Then $xRegion = 400
	If $x > 660 Then $xRegion = 540
	
	Click($x, $y)
	If _Sleep(1000) Then Return
	
	If QuickMIS("BC1", $g_sImgStart, $xRegion, $yRegion, $xRegion + 60, $yRegion + 40) Then
		Return GetEventTimeScore($g_iQuickMISX, $g_iQuickMISY)
	EndIf
	
EndFunc   ;==>GetEventInfo

Func IsBBChallenge($i = Default, $j = Default)

	Local $BorderX[4] = [288, 422, 557, 690]
	Local $BorderY[2] = [216, 385]
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
		Case Else
			$iRow = 2
	EndSwitch
	
	If $g_bChkClanGamesDebug Then SetLog("Row: " & $iRow & ", Column : " & $iColumn, $COLOR_DEBUG)
	For $y = 0 To 2
		For $x = 0 To 3
			If $iRow = ($y+1) And $iColumn = ($x+1) Then
				;Search image border, our image is MainVillage event border, so If found return False
				If QuickMIS("BC1", $g_sImgBorder, $BorderX[$x] - 15, $BorderY[$y] - 20, $BorderX[$x] + 15, $BorderY[$y] + 10, True, False) Then
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
		Click(820, 45) ;close window
		For $i = 1 To 5
			If isOnMainVillage() Then Return True
			If _Sleep(1000) Then Return
		Next
		Return False
	EndIf
	Return False
EndFunc

Func CollectCGReward($bTest = False)
	SetLog("Checking to Collect ClanGames Reward")
	Local $aiScoreLimit, $sYourGameScore

	$sYourGameScore = getOcrYourScore(48, 560) ;  Read your Score
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
	If QuickMIS("BC1", $g_sImgRewardText, 600, 445, 830, 495) Then
		If $g_iQuickMISName = "Claim" Then
			$OnlyClaimMax = True
			$g_bIsCGPointMaxed = True
			SetLog("OnlyClaimMax = " & String($OnlyClaimMax))
			SetLog("CGPoint Considered Maxed = " & String($g_bIsCGPointMaxed))
		EndIf
	EndIf

	Local $aRewardButton[4] = [810, 480, 0x8BD43A, 10] ;green reward button
	Local $aCGSummary[4] = [825, 490, 0xD8BA30, 10] ;yellow summary Window
	Local $Drag = True
	For $i = 0 To 7
		If $OnlyClaimMax Then ExitLoop
		If Not $g_bRunState Then Return
		SetDebugLog("CHECK #" & $i+1, $COLOR_ACTION)
		If _CheckPixel($aRewardButton, True) Then ExitLoop

		If $i < 3 Then
			Local $aTile = GetCGRewardList()
			If IsArray($aTile) And UBound($aTile) > 0 Then
				For $j = 0 To UBound($aTile) -1
					SetDebugLog("Items: " & $aTile[$j][0] & " Value: " & $aTile[$j][3])
				Next
				Click($aTile[0][1], $aTile[0][2]+10)
				SetLog("Selecting Magic Items:" & $aTile[0][0], $COLOR_INFO)
				If _Sleep(1000) Then Return
				If IsOKCancelPage() Then ;check if we found gems popup, accept
					SetLog("Magic Item storage is Full (Take gems)", $COLOR_INFO)
					Click(510, 420)
					If _Sleep(1000) Then Return
				EndIf
				ContinueLoop
			EndIf
			If _Sleep(500) Then Return
			If _CheckPixel($aRewardButton, True) Then ExitLoop ;check if Reward Button already turns green
		EndIf

		If $Drag Then
			ClickDrag(660, 168, 510, 168, 500)
			If _Sleep(3000) Then Return
			$Drag = False
		EndIf

		Local $aTile = GetCGRewardList()
		If IsArray($aTile) And UBound($aTile) > 0 Then
			For $j = 0 To UBound($aTile) -1
				SetDebugLog("Items: " & $aTile[$j][0] & " Value: " & $aTile[$j][3])
			Next
			Click($aTile[0][1], $aTile[0][2]+10)
			SetLog("Selecting Magic Items:" & $aTile[0][0], $COLOR_INFO)
			If _Sleep(1000) Then Return
			If IsOKCancelPage() Then ;check if we found gems popup, accept
				SetLog("Magic Item storage is Full (Take gems)", $COLOR_INFO)
				Click(510, 420)
				If _Sleep(1000) Then Return
			EndIf
			If _CheckPixel($aRewardButton, True) Then ExitLoop ;check if Reward Button already turns green
		EndIf

	Next

	If $OnlyClaimMax Then
		ClickDrag(660, 168, 500, 168, 500)
		If _Sleep(3000) Then Return
		Local $aTile = GetCGRewardList(500, $OnlyClaimMax)
		If IsArray($aTile) And UBound($aTile) > 0 Then
			For $item = 0 To UBound($aTile) - 1
				Click($aTile[$item][1], $aTile[$item][2]+10)
				SetLog("Selecting Magic Items:" & $aTile[$item][0], $COLOR_INFO)
				If _Sleep(1000) Then Return
				If IsOKCancelPage() Then ;check if we found gems popup, decline
					SetLog("Magic Item storage is Full (Decline)", $COLOR_INFO)
					Click(350, 420) ;Click No
					If _Sleep(1000) Then Return
				Else
					ExitLoop
				EndIf
			Next
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
		If _Sleep(3000) Then Return
		For $i = 1 To 10
			If Not $g_bRunState Then Return
			SetLog("Waiting Max Point Reward #" & $i, $COLOR_ACTION)
			If WaitforPixel(780, 490, 781,491, "D1D1D1", 10, 1) Then ExitLoop
			If _Sleep(500) Then Return
		Next

		Local $aTile = GetCGRewardList(635)
		If IsArray($aTile) And UBound($aTile) > 0 Then
			For $item = 0 To UBound($aTile) - 1
				Click($aTile[$item][1], $aTile[$item][2]+10)
				SetLog("Selecting Magic Items:" & $aTile[$item][0], $COLOR_INFO)
				If _Sleep(1000) Then Return
				If IsOKCancelPage() Then ;check if we found gems popup, decline
					SetLog("Magic Item storage is Full (Decline)", $COLOR_INFO)
					Click(350, 420) ;Click No
					If _Sleep(1000) Then Return
				Else
					ExitLoop
				EndIf
			Next
		Else
			; Image Magic Items Not found, maybe image not exist yet
			Click(770, 393) ;100 Gems
		EndIf

		For $i = 1 To 5
			If Not $g_bRunState Then Return
			SetLog("Waiting Reward Button #" & $i, $COLOR_ACTION)
			If _CheckPixel($aRewardButton, True) Then ExitLoop
			If _Sleep(1000) Then Return
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

Func GetCGRewardList($X = 270, $OnlyClaimMax = False)
	Local $aResult[0][4]
	Local $aTier = QuickMIS("CNX", $g_sImgRewardTier, $X, 170, 820, 210) ;search green check on top of Tier
	_ArraySort($aTier, 0, 0, 0, 1) ;Sort by x coord
	;_ArrayDisplay($aTier)
	If IsArray($aTier) And UBound($aTier) > 0 Then
		For $i = 0 To UBound($aTier) - 1
			If Not $g_bRunState Then Return
			If $g_bDebugSetlog Then SetLog("Checking Tier #" & $i + 1, $COLOR_ACTION)
			If QuickMIS("BC1", $g_sImgRewardTileSelected, $aTier[$i][1] - 50, $aTier[$i][2], $aTier[$i][1] + 50, 430) Then ;Check if Reward already selected
				If $g_bDebugSetlog Then SetLog("Already select Reward on this Tier, Looking next", $COLOR_ERROR)
				ContinueLoop
			EndIf

			Local $aTmp = QuickMIS("CNX", $g_sImgRewardItems, $aTier[$i][1] - 50, $aTier[$i][2], $aTier[$i][1] + 50, 430)
			If IsArray($aTmp) And Ubound($aTmp) > 0 Then
				Local $Value = 0
				For $j = 0 To UBound($aTmp) - 1
					If QuickMIS("BC1", $g_sImgRewardItemStorageFull, $aTmp[$j][1] - 50, $aTmp[$j][2] - 50, $aTmp[$j][1] + 50, $aTmp[$j][2] + 50) Then 
						If $g_bDebugSetlog Then SetLog("Storage Full for " & $aTmp[$j][0], $COLOR_ERROR)
						ContinueLoop
					EndIf
					
					Switch $aTmp[$j][0]
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
					_ArrayAdd($aResult, $aTmp[$j][0] & "|" & $aTmp[$j][1] & "|" & $aTmp[$j][2] & "|" & $Value)
				Next
			EndIf
			_ArraySort($aResult, 1, 0, 0, 3)
			If Not $OnlyClaimMax Then Return $aResult
		Next
		If $OnlyClaimMax Then Return $aResult
	EndIf
EndFunc

Func ClanGamesChallenges($sReturnArray)
	;[0]=ImageName 	 					[1]=Challenge Name		[3]=THlevel 	[4]=Priority/TroopsNeeded 	[5]=Extra/to use in future	[6]=Description
	Global $LootChallenges[6][6] = [ _
			["GoldChallenge", 			"Gold Challenge", 				 7,  5, 8, "Loot certain amount of Gold from a single Multiplayer Battle"								], _ ;|8h 	|50
			["ElixirChallenge", 		"Elixir Challenge", 			 7,  5, 8, "Loot certain amount of Elixir from a single Multiplayer Battle"								], _ ;|8h 	|50
			["DarkEChallenge", 			"Dark Elixir Challenge", 		 8,  5, 8, "Loot certain amount of Dark elixir from a single Multiplayer Battle"						], _ ;|8h 	|50
			["GoldGrab", 				"Gold Grab", 					 6,  3, 1, "Loot a total amount of Gold (accumulated from many attacks) from Multiplayer Battle"		], _ ;|1h-2d 	|100-600
			["ElixirEmbezz", 			"Elixir Embezzlement", 			 6,  3, 1, "Loot a total amount of Elixir (accumulated from many attacks) from Multiplayer Battle"		], _ ;|1h-2d 	|100-600
			["DarkEHeist", 				"Dark Elixir Heist", 			 9,  3, 1, "Loot a total amount of Dark Elixir (accumulated from many attacks) from Multiplayer Battle"	]]   ;|1h-2d 	|100-600

	Global $AirTroopChallenges[14][6] = [ _
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

	Global $GroundTroopChallenges[27][6] = [ _
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

	Global $BattleChallenges[21][6] = [ _
			["StarC", 					"Star Collector", 				 6,  1, 1, "Collect a total amount of Stars (accumulated from many attacks) from Multiplayer Battle"					], _ ;	|8h-2d	|100-600
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

	Global $DestructionChallenges[34][6] = [ _
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


	Global $MiscChallenges[3][6] = [ _
			["Gard", 					"Gardening Exercise", 			 6,  6, 8, "Clear 5 obstacles from your Home Village or Builder Base"		], _ ; |8h	|50
			["DonateSpell", 			"Donate Spells", 				 9,  6, 8, "Donate a total of 3 spells"				], _ ; |8h	|50
			["DonateTroop", 			"Helping Hand", 				 6,  6, 8, "Donate a total of 45 housing space worth of troops"			]]   ; 	|8h	|50


	Global $SpellChallenges[12][6] = [ _
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
			["BtSpell",					"Bat", 					 		10,  1, 1, "Use certain amount of Bat Spell to Win a Stars in Multiplayer Battles"			], _
			["InSpell",					"Invisibility", 					 		10,  1, 1, "Use certain amount of Bat Spell to Win a Stars in Multiplayer Battles"			]]   ;

	Global $BBBattleChallenges[4][6] = [ _
			["StarM",					"BB Star Master",				6,  1, 1, "Collect certain amount of stars in Builder Battle"						], _ ; Earn 6 - 24 stars on the BB
			["Victories",				"BB Victories",					6,  5, 3, "Get certain count of Victories in Builder Battle"						], _ ; Earn 3 - 6 victories on the BB
			["StarTimed",				"BB Star Timed",				6,  2, 2, "Earn stars in Builder Battle, but only stars gained below a minute counted"	], _
			["Destruction",				"BB Destruction",				6,  1, 1, "Earn certain amount of destruction percentage (%) in Builder Battle"			]] ; Earn 225% - 900% on BB attacks

	Global $BBDestructionChallenges[21][6] = [ _
			["Airbomb",					"Air Bomb",                 	6,  1, 4, "Destroy certain number of Air Bomb in Builder Battle"		], _
			["BuildingDes",             "BB Building",					6,  1, 4, "Destroy certain number of Building in Builder Battle"		], _
			["BuilderHall",             "BuilderHall",					6,  1, 2, "Destroy certain number of Builder Hall in Builder Battle"	], _
			["Cannon",                 	"BB Cannon",                  	6,  1, 1, "Destroy certain number of Cannon in Builder Battle"			], _
			["ClockTower",             	"Clock Tower",                 	6,  1, 1, "Destroy certain number of Clock Tower in Builder Battle"		], _
			["DoubleCannon",         	"Double Cannon",             	6,  1, 1, "Destroy certain number of Double Cannon in Builder Battle"	], _
			["FireCrackers",         	"Fire Crackers",              	6,  1, 2, "Destroy certain number of Fire Crackers in Builder Battle"	], _
			["GemMine",                 "Gem Mine",                  	6,  1, 1, "Destroy certain number of Gem Mine in Builder Battle"		], _
			["GiantCannon",             "Giant Cannon",               	6,  1, 4, "Destroy certain number of Giant Cannon in Builder Battle"	], _
			["GuardPost",               "Guard Post",                 	6,  1, 5, "Destroy certain number of Guard Post in Builder Battle"		], _
			["MegaTesla",               "Mega Tesla",               	6,  1, 5, "Destroy certain number of Mega Tesla in Builder Battle"		], _
			["MultiMortar",             "Multi Mortar",               	6,  1, 2, "Destroy certain number of Multi Mortar in Builder Battle"	], _
			["Roaster",                 "Roaster",			            6,  1, 4, "Destroy certain number of Roaster in Builder Battle"			], _
			["StarLab",                 "Star Laboratory",              6,  1, 1, "Destroy certain number of Star Laboratory in Builder Battle"	], _
			["WallDes",             	"Wall Whacker",              	6,  1, 2, "Destroy certain number of Wall in Builder Battle"			], _
			["Crusher",             	"Crusher",                 		6,  1, 2, "Destroy certain number of Crusher in Builder Battle"			], _
			["ArcherTower",             "Archer Tower",            		6,  1, 5, "Destroy certain number of Archer Tower in Builder Battle"	], _
			["LavaLauncher",            "Lava Launcher",           		6,  1, 5, "Destroy certain number of Lava Launcher in Builder Battle"	], _
			["OttoOutpost",             "Otto OutPost",            		6,  1, 7, "Destroy certain number of Otto OutPost in Builder Battle"	], _
			["Xbow",               		"Xbow Explosion",            	6,  1, 7, "Destroy certain number of X-Bows in Builder Battle"	], _
			["HealingHut",              "Healing Hut",            		6,  1, 7, "Destroy certain number of Healing Hut in Builder Battle"	]]

	Global $BBTroopsChallenges[12][6] = [ _
			["RBarb",					"Raged Barbarian",              6,  1, 1, "Win 1-5 Attacks using Raged Barbarians in Builder Battle"	], _ ;BB Troops
			["SArch",                 	"Sneaky Archer",                6,  1, 1, "Win 1-5 Attacks using Sneaky Archer in Builder Battle"	], _
			["BGiant",         			"Boxer Giant",             		6,  1, 1, "Win 1-5 Attacks using Boxer Giant in Builder Battle"		], _
			["BMini",         			"Beta Minion",              	6,  1, 1, "Win 1-5 Attacks using Beta Minion in Builder Battle"		], _
			["Bomber",                 	"Bomber",                  		6,  1, 1, "Win 1-5 Attacks using Bomber in Builder Battle"			], _
			["BabyD",               	"Baby Dragon",                 	6,  1, 1, "Win 1-5 Attacks using Baby Dragon in Builder Battle"		], _
			["CannCart",             	"Cannon Cart",               	6,  1, 1, "Win 1-5 Attacks using Cannon Cart in Builder Battle"		], _
			["NWitch",                 	"Night Witch",                 	6,  1, 1, "Win 1-5 Attacks using Night Witch in Builder Battle"		], _
			["DShip",                 	"Drop Ship",                  	6,  1, 1, "Win 1-5 Attacks using Drop Ship in Builder Battle"		], _
			["SPekka",                 	"Super Pekka",                  6,  1, 1, "Win 1-5 Attacks using Super Pekka in Builder Battle"		], _
			["HGlider",                 "Hog Glider",                  	6,  1, 1, "Win 1-5 Attacks using Hog Glider in Builder Battle"		], _
			["EFWiza",                  "Electro Fire Wizard",          6,  1, 1, "Win 1-5 Attacks using Electro Fire Wizard in Builder Battle"		]]
	
	Switch $sReturnArray
		Case "A"
			Return $AirTroopChallenges
		Case "G"
			Return $GroundTroopChallenges
		Case "S"
			Return $SpellChallenges
		Case "BBB"
			Return $BBBattleChallenges
		Case "BBD"
			Return $BBDestructionChallenges
		Case "BBT"
			Return $BBTroopsChallenges
		Case "L"
			Return $LootChallenges
		Case "B"
			Return $BattleChallenges
		Case "D"
			Return $DestructionChallenges
		Case "M"
			Return $MiscChallenges
	EndSwitch
EndFunc   ;==>ClanGamesChallenges