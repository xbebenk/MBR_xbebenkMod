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

Func isOnBuilderBase($bNeedCaptureRegion = True)
	Local $sColor = _GetPixelColor(356, 12, $bNeedCaptureRegion)
	If _ColorCheck($sColor, Hex(0x9CD2EE, 6), 10) Then
		SetDebugLog("Builder Base detected")
		Return True
	Else
		SetDebugLog("Not In BuilderBase, Colorcheck:" & $sColor)
		Return False
	EndIf
EndFunc
