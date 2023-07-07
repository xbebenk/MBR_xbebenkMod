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
	Local $sBuilderInfoColor = _GetPixelColor(356, 12, True)
	Local $sColorGold = _GetPixelColor(837, 13, True)
	Local $bBuilderInfoDetected = False, $bGoldDetected = False
	
	If _ColorCheck($sBuilderInfoColor, Hex(0x9DD2EE, 6), 20) Then $bBuilderInfoDetected = True 
	If _ColorCheck($sColorGold, Hex(0xF9FB7B, 6), 10) Then $bGoldDetected = True
	If $bBuilderInfoDetected And $bGoldDetected Then
		SetDebugLog("Builder Base detected, sColor:" & $sBuilderInfoColor & " sColorGold:" & $sColorGold)
		Return True
	Else
		Return False
	EndIf
EndFunc
