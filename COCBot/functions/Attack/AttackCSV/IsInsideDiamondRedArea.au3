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

	Local $Left = $ExternalArea[0][0], $Right = $ExternalArea[1][0], $Top = $ExternalArea[2][1], $Bottom = $ExternalArea[3][1] ; set the diamond shape 860x780
	Local $aDiamond[2][2] = [[$Left, $Top], [$Right, $Bottom]]
	Local $aMiddle = [($aDiamond[0][0] + $aDiamond[1][0]) / 2, ($aDiamond[0][1] + $aDiamond[1][1]) / 2]
	Local $aSize = [$aMiddle[0] - $aDiamond[0][0], $aMiddle[1] - $aDiamond[0][1]]

	Local $DX = Abs($aCoords[0] - $aMiddle[0])
	Local $DY = Abs($aCoords[1] - $aMiddle[1])

	; allow additional 5 pixels
	If $DX >= 5 Then $DX -= 5
	If $DY >= 5 Then $DY -= 5

	If ($DX / $aSize[0] + $DY / $aSize[1] <= 1) And $aCoords[0] > $DeployableLRTB[0] And $aCoords[0] <= $DeployableLRTB[1] And $aCoords[1] >= $DeployableLRTB[2] And $aCoords[1] <= $DeployableLRTB[3] Then
		Return True ; Inside Village
	Else
		;debugAttackCSV("isInsideDiamondRedArea outside: " & $aCoords[0] & "," & $aCoords[1])
		Return False ; Outside Village
	EndIf
EndFunc   ;==>isInsideDiamondRedArea

;Func isStorageLocationOnEdge()
;	If $g_bCSVLocateStorageElixir Then
;		$aResult = GetLocationBuilding($eBldgElixirS, $g_iSearchTH, False)
;		If @error And $g_bDebugSetlog Then _logErrorGetBuilding(@error)
;		If $aResult <> -1 Then ; check if Monkey ate bad banana
;			If $aResult = 1 Then
;				SetLog("> " & $g_sBldgNames[$eBldgElixirS] & " Not found", $COLOR_WARNING)
;			Else
;				$aResult = _ObjGetValue($g_oBldgAttackInfo, $eBldgElixirS & "_LOCATION")
;				If @error Then
;					_ObjErrMsg("_ObjGetValue " & $g_sBldgNames[$eBldgElixirS] & " _LOCATION", @error) ; Log errors
;					SetLog("> " & $g_sBldgNames[$eBldgElixirS] & " location not in dictionary", $COLOR_WARNING)
;				Else
;					If IsArray($aResult) Then $g_aiCSVElixirStoragePos = $aResult
;				EndIf
;			EndIf
;		Else
;			SetLog("Monkey ate bad banana: " & "GetLocationBuilding " & $g_sBldgNames[$eBldgElixirS], $COLOR_ERROR)
;		EndIf
;	EndIf
;
;	If $g_bCSVLocateStorageDarkElixir = True Then
;		$hTimer = __timerinit()
;		SuspendAndroid()
;		; USES OLD OPENCV DETECTION
;		Local $g_aiPixelDarkElixirStorage = GetLocationDarkElixirStorageWithLevel()
;		ResumeAndroid()
;		If _Sleep($DELAYRESPOND) Then Return
;		CleanRedArea($g_aiPixelDarkElixirStorage)
;		Local $pixel = StringSplit($g_aiPixelDarkElixirStorage, "#", 2)
;		If UBound($pixel) >= 2 Then
;			Local $pixellevel = $pixel[0]
;			Local $pixelpos = StringSplit($pixel[1], "-", 2)
;			If UBound($pixelpos) >= 2 Then
;				Local $temp = [Int($pixelpos[0]), Int($pixelpos[1])]
;				$g_aiCSVDarkElixirStoragePos = $temp
;			EndIf
;		EndIf
;		SetLog("> Dark Elixir Storage located in " & Round(__timerdiff($hTimer) / 1000, 2) & " seconds", $COLOR_INFO)
;	Else
;		SetLog("> Dark Elixir Storage detection not needed, skip", $COLOR_INFO)
;	EndIf
;EndFunc ;==>isElixirStorageLoconEdge

Func isInsideDiamondInternalArea($x, $y) ;we make smaller diamond which exclude 5 to 6 tiles from edge of village
	Local $xMidPoint = 435
	Local $yMidPoint = 330

	Local $Left = 150, $Right = 720, $Top = 130, $Bottom = 540
	Local $Offset = 0
	Local $coordLRTB = "", $coordInner = "UNKNOWN"

	Setlog("x = " & $x, $COLOR_DEBUG)
	Setlog("y = " & $y , $COLOR_DEBUG)

	Setlog("$Left = " & $Left, $COLOR_DEBUG)
	Setlog("$Right = " & $Right, $COLOR_DEBUG)
	Setlog("$Top = " & $Top, $COLOR_DEBUG)
	Setlog("$Bottom = " & $Bottom, $COLOR_DEBUG)

	Setlog("xMidPoint = " & $xMidPoint, $COLOR_DEBUG)
	Setlog("yMidPoint = " & $yMidPoint, $COLOR_DEBUG)

	If $x < $xMidPoint Then
		If $y < $yMidPoint Then
			$coordLRTB = "TOP-LEFT"
		Else
			$coordLRTB = "BOTTOM-LEFT"
		Endif
	Else
		If $y < $yMidPoint Then
			$coordLRTB = "TOP-RIGHT"
		Else
			$coordLRTB = "BOTTOM-RIGHT"
		Endif
	EndIf
	Setlog($coordLRTB, $COLOR_DEBUG)

	Switch $coordLRTB
		Case "TOP-LEFT"
			If $x > $Left And $x < $xMidPoint Then
				$Offset = ($x - $Left) * 0.7
				If $y > $Top And $y < $yMidPoint Then
					If $y < $yMidPoint - $Offset Then
						$coordInner = "OUTSIDE"
					Else
						$coordInner = "INSIDE"
					EndIf
				Else
					$coordInner = "OUTSIDE"
				EndIf
			Else
				$coordInner = "OUTSIDE"
			EndIf
		Case "BOTTOM-LEFT"
			If $x > $Left And $x < $xMidPoint Then
				$Offset = ($x - $Left) * 0.7
				If $y > $yMidPoint And $y < $Bottom Then
					If $y > $yMidPoint + $Offset Then
						$coordInner = "OUTSIDE"
					Else
						$coordInner = "INSIDE"
					EndIf
				Else
					$coordInner = "OUTSIDE"
				EndIf
			Else
				$coordInner = "OUTSIDE"
			EndIf
		Case "TOP-RIGHT"
			If $x > $xMidPoint And $x < $Right Then
				$Offset = ($Right - $x) * 0.7
				If $y > $Top And $y < $yMidPoint Then
					If $y < $yMidPoint - $Offset Then
						$coordInner = "OUTSIDE"
					Else
						$coordInner = "INSIDE"
					EndIf
				Else
					$coordInner = "OUTSIDE"
				EndIf
			Else
				$coordInner = "OUTSIDE"
			EndIf
		Case "BOTTOM-RIGHT"
			If $x > $xMidPoint And $x < $Right Then
				$Offset = ($Right - $x) * 0.7
				If $y > $yMidPoint And $y < $Bottom Then
					If $y > $yMidPoint + $Offset Then
						$coordInner = "OUTSIDE"
					Else
						$coordInner = "INSIDE"
					EndIf
				Else
					$coordInner = "OUTSIDE"
				EndIf
			Else
				$coordInner = "OUTSIDE"
			EndIf
	EndSwitch
	Return $coordInner
EndFunc   ;==>isInsideDiamondInternalArea




