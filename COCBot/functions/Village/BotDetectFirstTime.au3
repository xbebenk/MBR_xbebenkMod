; #FUNCTION# ====================================================================================================================
; Name ..........: BotDetectFirstTime
; Description ...: This script detects your builings on the first run
; Author ........: HungLe (04/2015)
; Modified ......: Hervidero (05/2015), HungLe (05/2015), KnowJack(07/2015), Sardo (08/2015), CodeSlinger69 (01/2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func BotDetectFirstTime()
	If $g_bIsClientSyncError Then Return ; if restart after OOS, and User stop/start bot, skip this.

	If _Sleep(50) Then Return
	checkMainScreen(True, $g_bStayOnBuilderBase, "BotDetectFirstTime")
	
	;Display Level TH in Stats
	GUICtrlSetData($g_hLblTHLevels, "")
	GUICtrlSetData($g_hLblTHLevels, $g_iTownHallLevel)
	_GUICtrlSetImage($g_hPicTHLevels, $g_sLibIconPath, $g_aIcnTHLevel[$g_iTownHallLevel])
	
EndFunc   ;==>BotDetectFirstTime
