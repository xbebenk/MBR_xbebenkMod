; #FUNCTION# ====================================================================================================================
; Name ..........: CheckOverviewFullArmy
; Description ...: Checks if the army is full on the training overview screen
; Syntax ........: CheckOverviewFullArmy([$bOpenArmyWindow = False])
; Parameters ....: $bOpenArmyWindow  = Bool value true if train overview window needs to be opened
;				 : $bCloseArmyWindow = Bool value, true if train overview window needs to be closed
; Return values .: None
; Author ........: KnowJack (07-2015)
; Modified ......: MonkeyHunter (03-2016), xbebenk(04-2024)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func CheckOverviewFullArmy($bOpenArmyWindow = False, $bCloseArmyWindow = False)

	;;;;;; Checks for full army using the green sign in army overview window ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;; Will only get full army when the maximum capacity of your camps are reached regardless of the full army percentage you input in GUI ;;;;;;;;;
	;;;;;; Use this only in halt attack mode and if an error happened in reading army current number Or Max capacity ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	If $bOpenArmyWindow Then
		If Not OpenArmyOverview("_checkArmyCamp()") Then
			SetError(2)
			Return; not open, requested to be open - error.
		EndIf
	EndIf
	
	If WaitForPixel(82, 181, 83, 182, Hex(0x44770E, 6), 20, 1, "CheckOverviewFullArmy") Then $g_bFullArmy = True
	SetLog("Checking Overview for full army [!] = " & String($g_bFullArmy), $COLOR_DEBUG)
	
	If $bCloseArmyWindow Then
		ClickAway()
		If _Sleep($DELAYCHECKFULLARMY3) Then Return
	EndIf
	Return $g_bFullArmy
EndFunc   ;==>CheckOverviewFullArmy