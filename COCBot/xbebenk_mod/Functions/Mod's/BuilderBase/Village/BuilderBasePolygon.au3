; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBasePolygon.au3
; Description ...: This file Includes function BuilderBasePolygon. Create the base constructor polygon and update the required values.
; Syntax ........:
; Parameters ....: None
; Return values .: -
; Author ........: Boldina (2021)
; Modified ......: 
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func PrintBBPoly($bOuterPolygon = True) ; Or Internal, but it always update globals.
	Local $aReturn[6] = [-1, -1, -1, -1, -1, -1]

	Local $iSize = ZoomBuilderBaseMecanics(False)
	If $iSize < 1 Then
		SetLog("Bad PrintBBPoly village size.", $COLOR_ERROR)
		Return SetError(1, 0, $aReturn)
	EndIf
	
	; Polygon Points
	Local $iTop[2], $iRight[2], $iBottom[2], $iBottomR[2], $iBottomL[2], $iLeft[2]
	
	$iSize = Floor(Pixel_Distance($g_aVillageSize[4], $g_aVillageSize[5], $g_aVillageSize[7], $g_aVillageSize[8]))
	
	; Fix ship coord
	Local $x = $g_aVillageSize[7] + Floor((590 * 14) / $iSize)
	Local $y = $g_aVillageSize[8]

	; ZoomFactor
	Local $iCorrectSizeLR = Floor(($iSize - 590) / 2)
	Local $iCorrectSizeT = Floor(($iSize - 590) / 4)
	Local $iCorrectSizeB = ($iSize - 590)
	
	Local $iFixA = Floor((590 * 6) / $iSize)
	Local $iFixE = Floor((590 * 25) / $iSize)
	
	; BuilderBaseAttackDiamond
	$iTop[0] = $x - (180 + $iCorrectSizeT)
	$iTop[1] = $y + $iFixA

	$iRight[0] = $x + (160 + $iCorrectSizeLR)
	$iRight[1] = $y + (260 + $iCorrectSizeLR)

	$iLeft[0] = $x - (515 + $iCorrectSizeB)
	$iLeft[1] = $y + (260 + $iCorrectSizeLR)

	$iBottom[0] = $x - (180 + $iCorrectSizeT)
	$iBottom[1] = $y + (515 + $iCorrectSizeB) - $iFixA

	If $bOuterPolygon = False Then
		$iBottomL[0] = $x - (225 + $iCorrectSizeB) - $iFixA
		$iBottomL[1] = 628
		
		$iBottomR[0] = $x - (110 - $iCorrectSizeB)
		$iBottomR[1] = 628

		$aReturn[0] = $iSize
		$aReturn[1] = $iTop
		$aReturn[2] = $iRight
		$aReturn[3] = $iBottomR
		$aReturn[4] = $iBottomL
		$aReturn[5] = $iLeft
	EndIf
	
	;This Format is for _IsPointInPoly function
	Local $aTmpBuilderBaseAttackPolygon[7][2] = [[5, -1], [$iTop[0], $iTop[1]], [$iRight[0], $iRight[1]], [$iBottom[0], $iBottom[1]], [$iBottom[0], $iBottom[1]], [$iLeft[0], $iLeft[1]], [$iTop[0], $iTop[1]]] ; Make Polygon From Points
	$g_aBuilderBaseAttackPolygon = $aTmpBuilderBaseAttackPolygon
	SetDebugLog("Builder Base Attack Polygon : " & _ArrayToString($aTmpBuilderBaseAttackPolygon))
	
	; BuilderBaseAttackOuterDiamond
	$iTop[0] = $x - (180 + $iCorrectSizeT)
	$iTop[1] = $y - $iFixE

	$iRight[0] = $x + (205 + $iCorrectSizeLR)
	$iRight[1] = $y + (260 + $iCorrectSizeLR)

	$iLeft[0] = $x - (560 + $iCorrectSizeB)
	$iLeft[1] = $y + (260 + $iCorrectSizeLR)

	$iBottom[0] = $x - (180 + $iCorrectSizeT)
	$iBottom[1] = $y + (515 + $iCorrectSizeB) + $iFixE

	
	If $bOuterPolygon = True Then
		$iBottomL[0] = $x - (275 + $iCorrectSizeB) - $iFixA
		$iBottomL[1] = 628

		$iBottomR[0] = $x - (70 - $iCorrectSizeB)
		$iBottomR[1] = 628
	
		$aReturn[0] = $iSize
		$aReturn[1] = $iTop
		$aReturn[2] = $iRight
		$aReturn[3] = $iBottomR
		$aReturn[4] = $iBottomL
		$aReturn[5] = $iLeft
	EndIf

	;This Format is for _IsPointInPoly function
	Local $aTmpBuilderBaseOuterPolygon[7][2] = [[5, -1], [$iTop[0], $iTop[1]], [$iRight[0], $iRight[1]], [$iBottom[0], $iBottom[1]], [$iBottom[0], $iBottom[1]], [$iLeft[0], $iLeft[1]], [$iTop[0], $iTop[1]]] ; Make Polygon From Points
	$g_aBuilderBaseOuterPolygon = $aTmpBuilderBaseOuterPolygon
	SetDebugLog("Builder Base Outer Polygon : " & _ArrayToString($aTmpBuilderBaseOuterPolygon))
	
	Return $aReturn
EndFunc   ;==>PrintBBPoly

Func InDiamondBB($iX, $iY, $aBigArray, $bAttack = True)
    If IsUnsafeDP($iX, $iY, $bAttack) = False And UBound($aBigArray) > 1 And not @error Then 
		; _ArrayDisplay($aBigArray)
        Return _IsPointInPoly($iX, $iY, $aBigArray)
    EndIf
    
    Return False
EndFunc   ;==>InDiamondBB

Func IsUnsafeDP($iX, $iY, $bAttack = True)
    If ($bAttack = True And $iY > 630) Or ($iX < 453 And $iY > 572) Then 
        Return True
    EndIf
    Return False
EndFunc   ;==>IsUnsafeDP

Func TestGetBuilderBaseSize()
	Setlog("** TestGetBuilderBaseSize START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	GetBuilderBaseSize(True, True)
	$g_bRunState = $Status
	Setlog("** TestGetBuilderBaseSize END**", $COLOR_DEBUG)
EndFunc   ;==>TestGetBuilderBaseSize

Func TestBuilderBaseZoomOut()
	Setlog("** TestBuilderBaseZoomOutOnAttack START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	BuilderBaseZoomOut(True)
	$g_bRunState = $Status
	Setlog("** TestBuilderBaseZoomOutOnAttack END**", $COLOR_DEBUG)
EndFunc   ;==>TestBuilderBaseZoomOut

Func BuilderBaseZoomOut($bForceZoom = False, $bVersusMode = True)
	If ZoomBuilderBaseMecanics($bForceZoom, $bVersusMode) > 0 Then
		Return True
	EndIf
	
	Return False
EndFunc   ;==>BuilderBaseZoomOut

Func BuilderBaseSendZoomOut($i = 0)
	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut IN]")
	If Not $g_bRunState Then Return
	AndroidZoomOut(0, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
	If @error <> 0 Then Return False
	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut OUT]")
	Return True
EndFunc   ;==>BuilderBaseSendZoomOut

Func ZoomBuilderBaseMecanics($bForceZoom = Default, $bVersusMode = Default, $bDebugLog = False)
	If $bForceZoom = Default Then $bForceZoom = True
	If $bVersusMode = Default Then $bVersusMode = True

	Local $iSize = ($bForceZoom = True) ? (0) : (GetBuilderBaseSize())

	If $iSize = 0 Then
		BuilderBaseSendZoomOut(0)
		If _Sleep(1000) Then Return
		
		$iSize = GetBuilderBaseSize(False, $bVersusMode, $bDebugLog)
	EndIf

	If Not $g_bRunState Then Return

	Local $i = 0
	Do
		SetDebugLog("Builder base force Zoomout ? " & $bForceZoom)

		If Not $g_bRunState Then Return

		If Not ($iSize > 520 And $iSize < 620) Then

			; Update shield status
			AndroidShield("AndroidOnlyZoomOut")
			
			; Send zoom-out.
			If BuilderBaseSendZoomOut($i) Then
				If _Sleep(1000) Then Return
				
				If Not $g_bRunState Then Return
				$iSize = GetBuilderBaseSize(($i = 3), $bVersusMode, $bDebugLog) ; WihtoutClicks
			EndIf
		EndIf

		If $i > 5 Then ExitLoop
		$i += 1
	Until ($iSize > 520 And $iSize < 620)

	SetDebugLog("Builder Base Diamond: " & $iSize, $COLOR_INFO)
	
	If $iSize = 0 Then
		SetDebugLog("[BBzoomout] ZoomOut Builder Base - FAIL", $COLOR_ERROR)
	Else
		SetDebugLog("[BBzoomout] ZoomOut Builder Base - OK", $COLOR_SUCCESS)
	EndIf

	Return $iSize
EndFunc   ;==>ZoomBuilderBaseMecanics

Func GetBuilderBaseSize($bWithClick = False, $bVersusMode = Default, $bDebugLog = False)
	If $bVersusMode = Default Then $bVersusMode = True
	Local $iResult = 0, $aVillage = 0

	If Not $g_bRunState Then Return

	Local $sFiles = ["", "2"]

	
	If $bWithClick = True Then
		ClickDrag(100, 130, 230, 30)
		If _Sleep(500) Then Return 
	EndIf
	
	_CaptureRegion2()
	If $bVersusMode = False Then
		If Not IsOnBuilderBase(False) Then
			SetDebugLog("You not are in builder base!")
			CheckObstacles(True)
		EndIf
	EndIf
	
	For $sMode In $sFiles
	
		If Not $g_bRunState Then Return
	
		$aVillage = GetVillageSize($bDebugLog, $sMode & "stone", $sMode & "tree", Default, True, False)
		
		If UBound($aVillage) > 8 And not @error Then
			If StringLen($aVillage[9]) > 5 And StringIsSpace($aVillage[9]) = 0 Then
				$iResult = Floor(Pixel_Distance($aVillage[4], $aVillage[5], $aVillage[7], $aVillage[8]))
				Return $iResult
			ElseIf StringIsSpace($aVillage[9]) = 1 Then
				Return 0
			EndIf
		EndIf
	
		If _Sleep($DELAYSLEEP * 10) Then Return
	
	Next
	
	Return 0
EndFunc   ;==>GetBuilderBaseSize

; Cartesian axis, by percentage, instead convert village pos, ready to implement in the constructor base. (Boldina, "the true dev").
; No reference village is based and no external DLL calls are made, just take the x and y endpoints, 
; then subtract the endpoints and generate the percentages they represent on the axes.

Func VillageToPercent($x, $y, $xv1, $xv2, $ya1, $ya2)
    Local $aArray[2] = [-1, -1]
    Local $ixAncho = $xv2 - $xv1
    Local $iyAlto = $ya2 - $ya1
    $aArray[0] = ($x / $ixAncho) * 100
    $aArray[1] = ($y / $iyAlto) * 100
    Return $aArray
EndFunc   ;==>VillageToPercent

; From the current village and the percentages represented by the axes, the Cartesian point is generated.
; Then add the external to fit.
; Taking as input the percentage in which the construction is located at the Cartesian point, the position is returned.
; The code is simple to implement and has precision.

Func PercentToVillage($xPer, $yPer, $xv1, $xv2, $ya1, $ya2)
    Local $aArray[2] = [-1, -1]
    Local $ixAncho = $xv2 - $xv1
    Local $iyAlto = $ya2 - $ya1
    $aArray[0] = $xv1 + (($ixAncho * $xPer) / 100)
    $aArray[1] = $ya1 + (($iyAlto * $yPer) / 100)
    Return $aArray
EndFunc   ;==>PercentToVillage