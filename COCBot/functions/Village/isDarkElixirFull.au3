; #FUNCTION# ====================================================================================================================
; Name ..........: isDarkElixirFull
; Description ...: Checks if your Gold Storages are maxed out
; Syntax ........: isDarkElixirFull()
; Parameters ....:
; Return values .: True or False
; Author ........: Code Monkey #57 (send more bananas please!)
; Modified ......: MonkeyHunter (2015-12)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func isDarkElixirFull()

	If Not _CheckPixel($aVillageHasDarkElixir, $g_bCapturePixel) Then Return ; check if the village have a Dark Elixir Storage

	If _CheckPixel($aIsDarkElixirFull, $g_bCapturePixel) Then ;Check for black/purple pixel in full bar
 		SetLog("Dark Elixir Storages is full!", $COLOR_SUCCESS)
		$g_abFullStorage[$eLootDarkElixir] = True
	Else
		$g_abFullStorage[$eLootDarkElixir] = False
	EndIf
	Return $g_abFullStorage[$eLootDarkElixir]
EndFunc   ;==>isDarkElixirFull
