; #FUNCTION# ====================================================================================================================
; Name ..........: isOnBuilderBase.au3
; Description ...: Check if Bot is currently on Normal Village or on Builder Base
; Syntax ........: isOnBuilderBase($bNeedCaptureRegion = False)
; Parameters ....: $bNeedCaptureRegion
; Return values .: True if is on Builder Base
; Author ........: Fliegerfaust (05-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: Click
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func isOnBuilderBase()
	Local $sColor = _GetPixelColor(356, 12, True)
	Local $sColorGold = _GetPixelColor(837, 13, True)
	If _ColorCheck($sColor, Hex(0x9DD2EE, 6), 20) Or _ColorCheck($sColorGold, Hex(0xF8FA7A, 6), 10) Then
		SetDebugLog("Builder Base detected, sColor:" & $sColor & " sColorGold:" & $sColorGold)
		Return True
	Else
		;SetDebugLog("Not In BuilderBase, BuilderInfoIconColor:" & $sColor, $COLOR_DEBUG1)
		;SetDebugLog("Not In BuilderBase, GoldColor:" & $sColorGold, $COLOR_DEBUG1)
		Return False
	EndIf
EndFunc
