; #FUNCTION# ====================================================================================================================
; Name ..........: isInsideDiamondRedArea
; Description ...:
; Syntax ........: isInsideDiamondRedArea($aCoords)
; Parameters ....: $aCoords             - an array
; Return values .: None
; Author ........: Sardo (2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func isInsideDiamondRedArea($aCoords)
	Local $Left = $g_OuterDiamondLeft
	Local $Right = $g_OuterDiamondRight
	Local $Top = $g_OuterDiamondTop
	Local $Bottom = $g_OuterDiamondBottom
	Local $aDiamond[2][2] = [[$Left, $Top], [$Right, $Bottom]]
	Local $aMiddle = [($aDiamond[0][0] + $aDiamond[1][0]) / 2, ($aDiamond[0][1] + $aDiamond[1][1]) / 2]
	Local $aSize = [$aMiddle[0] - $aDiamond[0][0], $aMiddle[1] - $aDiamond[0][1]]
	
	Local $DX = Abs($aCoords[0] - $aMiddle[0])
	Local $DY = Abs($aCoords[1] - $aMiddle[1])

	; allow additional 3 pixels
	If $DX >= 3 Then $DX -= 3
	If $DY >= 3 Then $DY -= 3

	If ($DX / $aSize[0] + $DY / $aSize[1] <= 1) And $aCoords[0] > $DeployableLRTB[0] And $aCoords[0] <= $DeployableLRTB[1] And $aCoords[1] >= $DeployableLRTB[2] And $aCoords[1] <= $DeployableLRTB[3] Then
		Return True ; Inside Village
	Else
		;debugAttackCSV("isInsideDiamondRedArea outside: " & $aCoords[0] & "," & $aCoords[1])
		Return False ; Outside Village
	EndIf
EndFunc   ;==>isInsideDiamondRedArea
