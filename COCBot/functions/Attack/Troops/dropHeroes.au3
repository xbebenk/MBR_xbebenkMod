; #FUNCTION# ====================================================================================================================
; Name ..........: dropHeroes
; Description ...: Will drop heroes in a specific coordinates, only if slot is not -1,Only drops when option is clicked.
; Syntax ........: dropHeroes($x, $y, $iKingSlot = -1, $iQueenSlot = -1, $iWardenSlot = -1, $iChampionSlot = -1)
; Parameters ....: $x                   - an unknown value.
;                  $y                   - an unknown value.
;                  $KingSlot            - [optional] an unknown value. Default is -1.
;                  $QueenSlot           - [optional] an unknown value. Default is -1.
;                  $WardenSlot          - [optional] an unknown value. Default is -1.
; Return values .: None
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func dropHeroes($iX, $iY, $iKingSlotNumber = -1, $iQueenSlotNumber = -1, $iWardenSlotNumber = -1, $iChampionSlotNumber = -1, $iMinionPSlotNumber = -1, $iDukeSlotNumber = -1) ;Drops for All Heroes
	SetDebugLog("dropHeroes $iKingSlotNumber " & $iKingSlotNumber & " $iQueenSlotNumber " & $iQueenSlotNumber & " $iWardenSlotNumber " & $iWardenSlotNumber & _
				" $iChampionSlotNumber " & $iChampionSlotNumber & " $iMinionPSlotNumber " & $iMinionPSlotNumber & " $iDukeSlotNumber " & $iDukeSlotNumber & _
				" matchmode " & $g_iMatchMode, $COLOR_DEBUG)
				
	Local $bDropKing = False, $bDropQueen = False, $bDropWarden = False, $bDropChampion = False, $bDropMinionP = False, $bDropDuke = False

	If $iKingSlotNumber <> -1 Then $bDropKing = True
	If $iQueenSlotNumber <> -1 Then $bDropQueen = True
	If $iWardenSlotNumber <> -1 Then $bDropWarden = True
	If $iChampionSlotNumber <> -1 Then $bDropChampion = True
	If $iMinionPSlotNumber <> -1 Then $bDropMinionP = True
	If $iDukeSlotNumber <> -1 Then $bDropDuke = True

	SetDebugLog("drop KING = " & $bDropKing & ", Slot:" & $iKingSlotNumber, $COLOR_DEBUG)
	SetDebugLog("drop QUEEN = " & $bDropQueen & ", Slot:" & $iQueenSlotNumber, $COLOR_DEBUG)
	SetDebugLog("drop WARDEN = " & $bDropWarden & ", Slot:" & $iWardenSlotNumber, $COLOR_DEBUG)
	SetDebugLog("drop CHAMPION = " & $bDropChampion & ", Slot:" & $iChampionSlotNumber, $COLOR_DEBUG)
	SetDebugLog("drop MINION PRINCE = " & $bDropMinionP & ", Slot:" & $iMinionPSlotNumber, $COLOR_DEBUG)
	SetDebugLog("drop DRAGON DUKE = " & $bDropDuke & ", Slot:" & $iDukeSlotNumber, $COLOR_DEBUG)

	If $bDropKing Then
		SetLog("Dropping King at [" & $iX & ", " & $iY & "]", $COLOR_INFO)
		SelectDropTroop($iKingSlotNumber, 1, Default, False)
		If _Sleep($DELAYDROPHEROES2) Then Return
		AttackClick($iX, $iY, 1, 0, 0, "#0093")
		If Not $g_bDropKing Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
			$g_bCheckKingPower = True
		Else
			SetDebugLog("King dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
		EndIf
		$g_bDropKing = True ; Set global flag hero dropped
		$g_aHeroesTimerActivation[$eHeroBarbarianKing] = __TimerInit() ; initialize fixed activation timer
		If _Sleep($DELAYDROPHEROES1) Then Return
	EndIf

	If _Sleep($DELAYDROPHEROES1) Then Return

	If $bDropQueen Then
		SetLog("Dropping Queen at " & $iX & ", " & $iY, $COLOR_INFO)
		SelectDropTroop($iQueenSlotNumber, 1, Default, False)
		If _Sleep($DELAYDROPHEROES2) Then Return
		AttackClick($iX, $iY, 1, 0, 0, "#0095")
		If Not $g_bDropQueen Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
			$g_bCheckQueenPower = True
		Else
			SetDebugLog("Queen dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
		EndIf
		$g_bDropQueen = True ; Set global flag hero dropped
		$g_aHeroesTimerActivation[$eHeroArcherQueen] = __TimerInit() ; initialize fixed activation timer
		If _Sleep($DELAYDROPHEROES1) Then Return
	EndIf

	If _Sleep($DELAYDROPHEROES1) Then Return

	If $bDropWarden Then
		SetLog("Dropping Grand Warden at " & $iX & ", " & $iY, $COLOR_INFO)
		SelectDropTroop($iWardenSlotNumber, 1, Default, False)
		If _Sleep($DELAYDROPHEROES2) Then Return
		AttackClick($iX, $iY, 1, 0, 0, "#x999")
		If Not $g_bDropWarden Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
			$g_bCheckWardenPower = True
		Else
			SetDebugLog("Warden dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
		EndIf
		$g_bDropWarden = True ; Set global flag hero dropped
		$g_aHeroesTimerActivation[$eHeroGrandWarden] = __TimerInit() ; initialize fixed activation timer
		If _Sleep($DELAYDROPHEROES1) Then Return
	EndIf

	If _Sleep($DELAYDROPHEROES1) Then Return

	If $bDropChampion Then
		SetLog("Dropping Royal Champion at " & $iX & ", " & $iY, $COLOR_INFO)
		SelectDropTroop($iChampionSlotNumber, 1, Default, False)
		If _Sleep($DELAYDROPHEROES2) Then Return
		AttackClick($iX, $iY, 1, 0, 0, "#x999")
		If Not $g_bDropChampion Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
			$g_bCheckChampionPower = True
		Else
			SetDebugLog("Royal Champion dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
		EndIf
		$g_bDropChampion = True ; Set global flag hero dropped
		$g_aHeroesTimerActivation[$eHeroRoyalChampion] = __TimerInit() ; initialize fixed activation timer
		If _Sleep($DELAYDROPHEROES1) Then Return
	EndIf
	
	If $bDropMinionP Then
		SetLog("Dropping Minion Prince at " & $iX & ", " & $iY, $COLOR_INFO)
		SelectDropTroop($iMinionPSlotNumber, 1, Default, False)
		If _Sleep($DELAYDROPHEROES2) Then Return
		AttackClick($iX, $iY, 1, 0, 0, "#x999")
		If Not $g_bDropMinionP Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
			$g_bCheckMinionPPower = True
		Else
			SetDebugLog("Minion Prince dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
		EndIf
		$g_bDropMinionP = True ; Set global flag hero dropped
		$g_aHeroesTimerActivation[$eHeroMinionPrince] = __TimerInit() ; initialize fixed activation timer
		If _Sleep($DELAYDROPHEROES1) Then Return
	EndIf
	
	If $bDropDuke Then
		SetLog("Dropping Dragon Duke at " & $iX & ", " & $iY, $COLOR_INFO)
		SelectDropTroop($iDukeSlotNumber, 1, Default, False)
		If _Sleep($DELAYDROPHEROES2) Then Return
		AttackClick($iX, $iY, 1, 0, 0, "#x999")
		If Not $g_bDropDuke Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
			$g_bCheckDukePower = True
		Else
			SetDebugLog("Dragon Duke dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
		EndIf
		$g_bDropDuke = True ; Set global flag hero dropped
		$g_aHeroesTimerActivation[$eHeroDuke] = __TimerInit() ; initialize fixed activation timer
		If _Sleep($DELAYDROPHEROES1) Then Return
	EndIf

EndFunc   ;==>dropHeroes



