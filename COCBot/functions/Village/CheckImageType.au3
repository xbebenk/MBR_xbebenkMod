; #FUNCTION# ====================================================================================================================
; Name ..........: CheckImageType()
; Description ...: Detects what Image Type (Normal/Snow)Theme is on your village and sets the $g_iDetectedImageType used for deadbase and Townhall detection.
; Author ........: Hervidero (2015-12)
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: Assign the Village Theme detected to $g_iDetectedImageType
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: CheckImageType ()
; ===============================================================================================================================
#include-once

Func CheckImageType()
	SetLog("Detecting your Village Theme", $COLOR_INFO)

	ClickAway()

	If _Sleep($DELAYCHECKIMAGETYPE1) Then Return
	If Not IsMainPage() Then ClickAway()

	Local $aTmp = QuickMIS("CNX", $sImgSnowTheme, 20,20,840,630)
	Local $count = 0
	For $i = 0 To UBound($aTmp) - 1
		If Not isInsideDiamondXY($aTmp[$i][1], $aTmp[$i][2]) Then $count += 1
	Next
;	Local $aResult = decodeMultipleCoords(findImage("Snow", $sImgSnowTheme, "DCD", 0, True))

	If $count >= 5 Then
		$g_iDetectedImageType = 1 ;Snow Theme
		SetDebugLog("Found Snow Images " & $count)
		SetLog("Snow Theme detected", $COLOR_INFO)
	Else
		$g_iDetectedImageType = 0 ; Normal Theme
		SetLog("Normal Theme detected", $COLOR_INFO)
	EndIf
EndFunc   ;==>CheckImageType
