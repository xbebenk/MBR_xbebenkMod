; #FUNCTION# ====================================================================================================================
; Name ..........: isElixirFull
; Description ...: Checks if your Elixir Storages are maxed out
; Syntax ........: isElixirFull()
; Parameters ....:
; Return values .: True or False
; Author ........: Code Monkey #34 (yes, the good looking one!)
; Modified ......: Hervidero (2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func isElixirFull()
	If _CheckPixel($aIsElixirFull, $g_bCapturePixel) Then ;Hex if color of elixir (purple)
		SetLog("Elixir Storages are full!", $COLOR_SUCCESS)
		$g_abFullStorage[$eLootElixir] = True
	Else
		$g_abFullStorage[$eLootElixir] = False
	EndIf
	If Not _CheckPixel($aIsElixirLow, $g_bCapturePixel) Then ;Hex if color of elixir (purple)
		SetLog("Elixir Storages are Low!", $COLOR_DEBUG)
		$g_abLowStorage[$eLootElixir] = True
	Else
		$g_abLowStorage[$eLootElixir] = False
	EndIf
	Return $g_abFullStorage[$eLootElixir]
EndFunc   ;==>isElixirFull
