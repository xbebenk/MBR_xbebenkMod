; #FUNCTION# ====================================================================================================================
; Name ..........: ReturnHome
; Description ...: Returns home when in battle, will take screenshot and check for gold/elixir change unless specified not to.
; Syntax ........: ReturnHome([$bTakeSS = 1[, $GoldChangeCheck = True]])
; Parameters ....: $bTakeSS              - [optional] flag for saving a snapshot of the winning loot. Default is 1.
;                  $GoldChangeCheck     - [optional] an unknown value. Default is True.
; Return values .: None
; Author ........:
; Modified ......: KnowJack (07-2015), MonkeyHunter (01-2016), CodeSlinger69 (01-2017), MonkeyHunter (03-2017), xbebenk(03-2024)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func ReturnHome($bTakeSS = True, $GoldChangeCheck = True) ;Return main screen
	SetDebugLog("ReturnHome function... (from matchmode=" & $g_iMatchMode & " - " & $g_asModeText[$g_iMatchMode] & ")", $COLOR_DEBUG)
	Local $counter = 0
	Local $hBitmap_Scaled
	Local $i, $j
	Local $aiSurrenderButton

	If $g_bDESideDisableOther And $g_iMatchMode = $LB And $g_aiAttackStdDropSides[$LB] = 4 And $g_bDESideEndEnable And ($g_bDropQueen Or $g_bDropKing) Then
		SaveandDisableEBO()
		SetLog("Disabling Normal End Battle Options", $COLOR_SUCCESS)
	EndIf

	If $GoldChangeCheck Then
		SetLog("Checking if the battle has finished", $COLOR_INFO)
		$g_Zapped = False ;xbebenk mod - Reset var Early Zap, zap early will called on EBO
		While GoldElixirChangeEBO()
			If _Sleep(1000) Then Return
		WEnd
		If $g_bRestart Then Return
		If $g_Zapped Then ;Skip Zap if EarlyZap is successful
			SetLog("Zapped Early, Skipping SmartZap")
		Else
			If IsAttackPage() Then smartZap() ; Check to see if we should zap the DE Drills
		EndIf
	EndIf

	If $g_bDESideDisableOther And $g_iMatchMode = $LB And $g_aiAttackStdDropSides[$LB] = 4 And $g_bDESideEndEnable And ($g_bDropQueen Or $g_bDropKing) Then
		RevertEBO()
	EndIf

	; Reset hero variables
	$g_bCheckKingPower = False
	$g_bCheckQueenPower = False
	$g_bCheckWardenPower = False
	$g_bCheckChampionPower = False
	$g_bDropKing = False
	$g_bDropQueen = False
	$g_bDropWarden = False
	$g_bDropChampion = False
	$g_aHeroesTimerActivation[$eHeroBarbarianKing] = 0
	$g_aHeroesTimerActivation[$eHeroArcherQueen] = 0
	$g_aHeroesTimerActivation[$eHeroGrandWarden] = 0
	$g_aHeroesTimerActivation[$eHeroRoyalChampion] = 0

	; Reset building info used to attack base
	_ObjDeleteKey($g_oBldgAttackInfo, "") ; Remove all Keys from dictionary

	SetLog("Returning Home", $COLOR_INFO)
	If Not $g_bRunState Then Return


	Local $BattleEnded = False
	For $i = 1 To 5
		SetLog("Wait For EndBattle #" & $i, $COLOR_ACTION)
		If $g_bRestart Then Return
		If IsReturnHomeBattlePage(True) Or IsReturnHomeChestPage(False) Then
			$BattleEnded = True
			SetLog("Battle already over", $COLOR_SUCCESS)
			ExitLoop ;exit Battle already ended
		EndIf

		If WaitforPixel(18, 548, 19, 549, "CF0D0E", 10, 1, "ReturnHome-EndBattle") Then
			Click(65, 540, 1, 0, "#0099")
			If _Sleep(500) Then Return
			Local $j = 0
			Local $OKCancel = False
			While 1 ; dynamic wait for Okay button
				SetDebugLog("Wait for OK button to appear #" & $j)
				If IsOKCancelPage(True) Then
					Click(510, 400, 2, 1000); Click Okay to Confirm surrender
					If _Sleep(1000) Then Return
					$OKCancel = True
					ExitLoop
				EndIf
				
				$j += 1
				If $j > 5 Then ExitLoop ; if Okay button not found in 10*(200)ms or 2 seconds, then give up.
				If _Sleep(500) Then Return
			WEnd
			
			If Not $OKCancel Then
				If _Sleep(1000) Then Return
				If WaitMainScreen() Then
					SetLog("Success Return Home", $COLOR_INFO)
					Return
				EndIf
			EndIf
		Else
			If IsProblemAffect() Then Return
			SetLog("Cannot Find Surrender Button", $COLOR_ERROR)
		EndIf
		
		If _Sleep(500) Then Return ;set sleep for wait page changes
	Next

	TrayTip($g_sBotTitle, "", BitOR($TIP_ICONASTERISK, $TIP_NOSOUND)) ; clear village search match found message

	If CheckAndroidReboot() Then Return

	If $GoldChangeCheck Then
		;If _Sleep(2000) Then Return ;add more delay to wait all resource appear
		_CaptureRegion()
		AttackReport()
	EndIf

	If $g_bRestart Then Return
	If $bTakeSS And $GoldChangeCheck Then
		SetLog("Taking snapshot of your loot", $COLOR_SUCCESS)
		Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
		Local $Time = @HOUR & "." & @MIN
		_CaptureRegion()
		$hBitmap_Scaled = _GDIPlus_ImageResize($g_hBitmap, _GDIPlus_ImageGetWidth($g_hBitmap) / 2, _GDIPlus_ImageGetHeight($g_hBitmap) / 2) ;resize image
		; screenshot filename according with new options around filenames
		If $g_bScreenshotLootInfo Then
			$g_sLootFileName = $Date & "_" & $Time & " G" & $g_iStatsLastAttack[$eLootGold] & " E" & $g_iStatsLastAttack[$eLootElixir] & " DE" & _
					$g_iStatsLastAttack[$eLootDarkElixir] & " T" & $g_iStatsLastAttack[$eLootTrophy] & " S" & StringFormat("%3s", $g_iSearchCount) & ".jpg"
		Else
			$g_sLootFileName = $Date & "_" & $Time & ".jpg"
		EndIf
		_GDIPlus_ImageSaveToFile($hBitmap_Scaled, $g_sProfileLootsPath & $g_sLootFileName)
		_GDIPlus_ImageDispose($hBitmap_Scaled)
	EndIf

	;push images if requested..
	If $GoldChangeCheck Then PushMsg("LastRaid")

	For $i = 1 To 5
		SetDebugLog("Wait for End Fight Scene to appear #" & $i)
		If IsReturnHomeBattlePage(True) Or IsReturnHomeChestPage(False) Then
			ClickP($aReturnHomeButton, 1, 0, "#0101") ;Click Return Home Button
			IsReturnHomeChestPage()
		ElseIf ReturnHomeMainPage() Then 
			Return ;clear bot log
		ElseIf StarBonus() Then 
			SetLog("Star Bonus window closed chief!", $COLOR_INFO)
		EndIf
		If _Sleep(250) Then Return
	Next

	If IsProblemAffect() Then
		SetLog("Cannot return home.", $COLOR_ERROR)
		CheckMainScreen()
		Return
	EndIf
EndFunc   ;==>ReturnHome

Func ReturnHomeMainPage()
	If CheckMainScreen(False, $g_bStayOnBuilderBase,"ReturnHome-1") Then
		SetLogCentered(" BOT LOG ", Default, Default, True)
		Return True
	EndIf
	Return False
EndFunc   ;==>ReturnHomeMainPage

Func StarBonus()
	SetLog("Begin Star Bonus window check", $COLOR_DEBUG1)
	
	Local $aStarBonus1[4] = [135, 92, 0x254963, 20] ; Black Balloon
	Local $aStarBonus2[4] = [676, 87, 0x1995F8, 20] ; Blue header covering elixir bar
	
	If _Sleep(500) Then Return

	; Verify actual star bonus window open
	If _CheckPixel($aStarBonus1, $g_bCapturePixel, Default, "Starbonus1") And _CheckPixel($aStarBonus2, $g_bCapturePixel, Default, "Starbonus2") Then
		; Find and Click Okay button
		Click(425, 535, 1, 100, "StarBonus: Click Okay Button") ; Click Okay Button
		If _Sleep(500) Then Return
		Return True
	EndIf
	Return False
EndFunc   ;==>StarBonus

Func ReturnfromDropTrophies($AttackLog = False)
	Local $aiSurrenderButton
	SetDebugLog(" -- ReturnfromDropTrophies -- ")
	
	For $i = 1 To 10 
		SetDebugLog("Waiting Surrender button #" & $i, $COLOR_ACTION)
		If IsAttackPage() Then
			Click(65, 540) ;click surrender
			If _Sleep(1000) Then Return
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	Local $OKCancel = False
	For $i = 1 To 10
		SetDebugLog("Wait for OK button to appear #" & $i)
		If IsOKCancelPage(True) Then
			Click(510, 400); Click Okay to Confirm surrender
			If _Sleep(1000) Then Return
			$OKCancel = True
			ExitLoop
		EndIf
		If _Sleep(500) Then Return
	Next
	
	If Not $OKCancel Then 
		SetLog("Cannot Find Surrender Button", $COLOR_ERROR)
		Return
	EndIf

	For $i = 1 To 5
		SetDebugLog("Wait for End Fight Scene to appear #" & $i)
		If IsReturnHomeBattlePage(True) Then
			If $AttackLog Then
				$g_iMatchMode = $DT
				_CaptureRegion()
				AttackReport()
				$AttackLog = False ;set false here, prevent hit again if loop continue
			EndIf
			ClickP($aReturnHomeButton, 1, 0, "#0101") ;Click Return Home Button
			; sometimes 1st click is not closing, so try again
			If _Sleep(2000) Then Return
		Else 
			ExitLoop
		EndIf
	Next
	If ReturnHomeMainPage() Then Return
EndFunc   ;==>ReturnfromDropTrophies

