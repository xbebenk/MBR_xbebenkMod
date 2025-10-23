; #FUNCTION# ====================================================================================================================
; Name ..........: isGoldFull
; Description ...: Checks if your Gold Storages are maxed out
; Syntax ........: isGoldFull()
; Parameters ....:
; Return values .: True or False
; Author ........: Code Monkey #57 (send more bananas please!)
; Modified ......: Hervidero (2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func isGoldFull($bSetLog = True)
	If _CheckPixel($aIsGoldFull, $g_bCapturePixel) Then ;Hex if color of gold (orange)
		If $bSetLog Then SetLog("Gold Storages are full!", $COLOR_SUCCESS)
		$g_abFullStorage[$eLootGold] = True
	Else
		$g_abFullStorage[$eLootGold] = False
	EndIf
	If Not _CheckPixel($aIsGoldlow, $g_bCapturePixel) Then ;Hex if color of gold (orange)
		If $bSetLog Then SetLog("Gold Storages are Low!", $COLOR_DEBUG)
		$g_abLowStorage[$eLootGold] = True
	Else
		$g_abLowStorage[$eLootGold] = False
	EndIf
	Return $g_abFullStorage[$eLootGold]
EndFunc   ;==>isGoldFull
