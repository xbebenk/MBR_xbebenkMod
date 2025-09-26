; #FUNCTION# ====================================================================================================================
; Name ..........: dropCC
; Description ...: Drops Clan Castle troops, given the slot and x, y coordinates.
; Syntax ........: dropCC($x, $y, $slot)
; Parameters ....: $x                   - X location.
;                  $y                   - Y location.
;                  $slot                - CC location in troop menu
; Return values .: None
; Author ........:
; Modified ......: Sardo (12-2015) KnowJack (06-2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func dropCC($iX, $iY, $iCCSlot) ;Drop clan castle

	Local $test = ($g_iMatchMode <> $DB And $g_iMatchMode <> $LB) Or $g_abAttackDropCC[$g_iMatchMode]

	If $iCCSlot <> -1 And $test Then
		;standard attack
		SetLog("Dropping Siege/Clan Castle [" & $iX & "," & $iY & "]", $COLOR_INFO)
		SelectDropTroop($iCCSlot)
		If _Sleep($DELAYDROPCC1) Then Return
		AttackClick($iX, $iY, 1, 0, 0, "#0091")
	EndIf

EndFunc   ;==>dropCC
