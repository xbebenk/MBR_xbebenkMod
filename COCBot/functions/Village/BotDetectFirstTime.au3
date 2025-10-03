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

	ZoomOut(True)
	If _Sleep(50) Then Return

	SetLog("Detecting your Buildings", $COLOR_INFO)
	If Not isInsideDiamond($g_aiTownHallPos) Then
	  checkMainScreen(True, $g_bStayOnBuilderBase, "BotDetectFirstTime")
	  Collect(True)
	  SearchTH(False) ; search th on myvillage
	  SetLog("Townhall: (" & $g_aiTownHallPos[0] & "," & $g_aiTownHallPos[1] & ")", $COLOR_DEBUG)
	EndIf

	If Number($g_iTownHallLevel) < 2 Then
		Local $aTownHallLevel = GetTownHallLevel(True) ; Get the Users TH level
		If IsArray($aTownHallLevel) Then $g_iTownHallLevel = 0 ; Check for error finding TH level, and reset to zero if yes
	EndIf

	If $g_iTownHallLevel > 2 Then
		saveConfig()
	EndIf

	If _Sleep(50) Then Return

	If $g_aiClanCastlePos[0] = -1 Then
		If AutoLocateCC() Then
			applyConfig()
			saveConfig()
		EndIf
	EndIf

	If _Sleep(50) Then Return
	If $g_aiLaboratoryPos[0] = "" Or $g_aiLaboratoryPos[0] = -1 Then
		If AutoLocateLab() Then
			applyConfig()
			saveConfig()
		EndIf
	EndIf

	;Display Level TH in Stats
	GUICtrlSetData($g_hLblTHLevels, "")
	GUICtrlSetData($g_hLblTHLevels, $g_iTownHallLevel)
	_GUICtrlSetImage($g_hPicTHLevels, $g_sLibIconPath, $g_aIcnTHLevel[$g_iTownHallLevel])
	
EndFunc   ;==>BotDetectFirstTime
