; #FUNCTION# ====================================================================================================================
; Name ..........: isInsideDiamondXY, isInsideDiamond
; Description ...: This function can test if a given coordinate is inside (True) or outside (False) the village grass borders (a diamond shape).
;                  It will also exclude some special area's like the CHAT tab, BUILDER button and GEM shop button.
; Syntax ........: isInsideDiamondXY($Coordx, $Coordy), isInsideDiamond($aCoords)
; Parameters ....: ($Coordx, $CoordY) as coordinates or ($aCoords), an array of (x,y) to test
; Return values .: True or False
; Author ........: Hervidero (2015-may-21)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================


Func isInsideDiamondXY($Coordx, $Coordy, $bOuter = False)
	If $Coordx < 73 Then Return False
	If $Coordy < 73 Then Return False
	Local $aCoords[2] = [$Coordx, $Coordy]
	Return isInsideDiamond($aCoords, $bOuter)
EndFunc   ;==>isInsideDiamondXY

Func isInsideDiamond($aCoords, $bOuter = False)
	Local $x = $aCoords[0], $y = $aCoords[1], $xD, $yD
	Local $Left, $Right, $Top, $Bottom
    If $bOuter Then 
        $Left = $OuterDiamondLeft
        $Right = $OuterDiamondRight
        $Top = $OuterDiamondTop
        $Bottom = $OuterDiamondBottom
    Else
		$Left = $InnerDiamondLeft
        $Right = $InnerDiamondRight
        $Top = $InnerDiamondTop
        $Bottom = $InnerDiamondBottom
    EndIf
	
	Local $aDiamond[2][2] = [[$Left, $Top], [$Right, $Bottom]]
	Local $aMiddle = [($aDiamond[0][0] + $aDiamond[1][0]) / 2, ($aDiamond[0][1] + $aDiamond[1][1]) / 2]

	;; convert to real diamond compensating zoom and offset
	;; top diamond point
	;$xD = $aMiddle[0]
	;$yD = $Top
	;ConvertToVillagePos($xD, $yD)
	;$Top = $yD
	;; bottom diamond point
	;$xD = $aMiddle[0]
	;$yD = $Bottom
	;ConvertToVillagePos($xD, $yD)
	;$Bottom = $yD
	;; left diamond point
	;$xD = $Left
	;$yD = $aMiddle[1]
	;ConvertToVillagePos($xD, $yD)
	;$Left = $xD
	;; right diamond point
	;$xD = $Right
	;$yD = $aMiddle[1]
	;ConvertToVillagePos($xD, $yD)
	;$Right = $xD

	;If $g_bDebugSetLog Then SetDebugLog("isInsideDiamond coordinates updated by offset: " & $Left & ", " & $Right & ", " & $Top & ", " & $Bottom, $COLOR_DEBUG)

	Local $aDiamond[2][2] = [[$Left, $Top], [$Right, $Bottom]]
	Local $aMiddle = [($aDiamond[0][0] + $aDiamond[1][0]) / 2, ($aDiamond[0][1] + $aDiamond[1][1]) / 2]
	Local $aSize = [$aMiddle[0] - $aDiamond[0][0], $aMiddle[1] - $aDiamond[0][1]]

	Local $DX = Abs($x - $aMiddle[0])
	Local $DY = Abs($y - $aMiddle[1])

	If ($DX / $aSize[0] + $DY / $aSize[1] <= 1) Then
		If $x < 85 And $y > 270 Then ; coordinates where the game will click on the CHAT tab (safe margin)
			If $g_bDebugSetLog Then SetLog("Coordinate Inside Village, but Exclude CHAT")
			Return False
		ElseIf $x > 690 And $y > 165 And $y < 215 Then ; coordinates where the game will click on the GEMS button (safe margin)
			If $g_bDebugSetLog Then SetLog("Coordinate Inside Village, but Exclude GEMS")
			Return False
		EndIf
		If $g_bDebugSetLog Then SetLog("isInsideDiamond: " & "[" & $x & "," & $y & "] Coord Inside Village", $COLOR_DEBUG1)
		Return True ; Inside Village
	Else
		If $g_bDebugSetLog Then SetLog("isInsideDiamond: " & "[" & $x & "," & $y & "] Coord Outside Village", $COLOR_DEBUG1)
		Return False ; Outside Village
	EndIf

EndFunc   ;==>isInsideDiamond
