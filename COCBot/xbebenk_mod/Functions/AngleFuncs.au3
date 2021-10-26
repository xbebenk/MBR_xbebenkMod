; #FUNCTION# ====================================================================================================================
; Name ..........: AngleFuncs
; Description ...: This file Includes several files in the current script.
; Syntax ........: #include
; Parameters ....: Coordinates plus the distance you want to give it, this generates the angle and multiplies it by angle.
; Return values .: Returns an array with an artificially generated coordinate not rounded.
; Author ........: Boldina (05 - 2021)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Global Const $PI = 4 * ATan(1)

Func Linecutter($cx = 0, $cy = 0, $ex = 1, $ey = 1, $iMult = 20, $iRmin = -1, $iRmax = 1)
	Local $iAngle = angle($cx, $cy, $ex, $ey)
	Local $iRandom = Random($iRmin, $iRmax)
	Local $aReturn[2] = [$cx + Cos(_Radian($iAngle)) * $iMult + $iRandom, $cy + Sin(_Radian($iAngle)) * $iMult + $iRandom]
	; SetDebugLog("[Linecutter] " &  $aReturn[0] & " " & $aReturn[1] & " " & $iAngle)
	Return $aReturn
EndFunc   ;==>Linecutter

Func angle($cx, $cy, $ex, $ey)
	Local $dy = $ey - $cy
	Local $dx = $ex - $cx
	Local $iTheta = atan2($dy, $dx) ; // range (-PI, PI]
	$iTheta *= 180 / $PI ; // rads to degs, range (-180, 180]
	Return $iTheta
EndFunc   ;==>angle

Func atan2($y, $x)
	Return (2 * ATan($y / ($x + Sqrt($x * $x + $y * $y))))
EndFunc   ;==>atan2

