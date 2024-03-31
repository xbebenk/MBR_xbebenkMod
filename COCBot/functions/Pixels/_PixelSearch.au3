
; #FUNCTION# ====================================================================================================================
; Name ..........: _PixelSearch
; Description ...: PixelSearch a certain region, works for memory BMP
; Syntax ........: _PixelSearch($iLeft, $iTop, $iRight, $iBottom, $sColor, $iColorVariation)
; Parameters ....: $iLeft               - an integer value.
;                  $iTop                - an integer value.
;                  $iRight              - an integer value.
;                  $iBottom             - an integer value.
;                  $sColor              - an string value with hex color to search
;                  $iColorVariation     - an integer value.
;                  $bNeedCapture        - [optional] a boolean flag to get new screen capture, when False full screen must have been captured wuth _CaptureRegion() !!!
; Return values .: None
; Author ........: Your Name
; Modified ......: xbebenk(03-2024)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func _PixelSearch($iLeft, $iTop, $iRight, $iBottom, $sColor, $iColorVariation, $bReturnBool = False, $sMessage = "_PixelSearch")
	Local $x1, $y1, $x2, $y2, $retColor
	_CaptureRegion($iLeft, $iTop, $iRight, $iBottom)
	$x2 = $iRight - $iLeft
	$y2 = $iBottom - $iTop
	$x1 = 0
	$y1 = 0
	
	For $x = $x1 To $x2
		For $y = $y1 To $y2
			$retColor = _GetPixelColor($x, $y)
			If _ColorCheck($retColor, $sColor, $iColorVariation) Then
				Local $Pos[4] = [$x + $iLeft, $y + $iTop, $sColor, $retColor]
				If $bReturnBool Then 
					If $g_bDebugSetLog Then SetLog("[" & $sMessage & "] exp:" & $sColor & ", got:" & $retColor & " on [" & $x + $iLeft & "," & $y + $iTop & "] found!", $COLOR_DEBUG2)
					Return True
				Else
					If $g_bDebugSetLog Then SetLog("[" & $sMessage & "] exp:" & $sColor & ", got:" & $retColor & " on [" & $x + $iLeft & "," & $y + $iTop & "]", $COLOR_DEBUG2)
					Return $Pos
				EndIf
			Else
				If $g_bDebugSetLog Then SetLog("[" & $sMessage & "] exp:" & $sColor & ", got:" & $retColor & " on [" & $x + $iLeft & "," & $y + $iTop & "]", $COLOR_DEBUG2)
			EndIf
		Next
	Next
	
	If $bReturnBool Then 
		Return False
	Else
		Return 0
	EndIf
EndFunc   ;==>_PixelSearch
