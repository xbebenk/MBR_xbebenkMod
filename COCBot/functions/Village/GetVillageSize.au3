; #FUNCTION# ====================================================================================================================
; Name ..........: GetVillageSize
; Description ...: Measures the size of village. After CoC October 2016 update, max'ed zoomed out village is 440 (reference!)
;                  But usually sizes around 470 - 490 pixels are measured due to lock on max zoom out.
; Syntax ........: GetVillageSize()
; Parameters ....:
; Return values .: 0 if not identified or Array with index
;                      0 = Size of village (float)
;                      1 = Zoom factor based on 440 village size (float)
;                      2 = X offset of village center (int)
;                      3 = Y offset of village center (int)
;                      4 = X coordinate of stone
;                      5 = Y coordinate of stone
;                      6 = stone image file name
;                      7 = X coordinate of tree
;                      8 = Y coordinate of tree
;                      9 = tree image file name
; Author ........: Cosote (Oct 17th 2016)
; Modified ......: xbebenk (June 2022)
; Removed Fix village measurement if using shared_prefs as I dont know how it works :(
; Change the logic for measure village size, zoomlevel now measured from tree to stone
; And then compare it with Reference size
; All scenery (as this code modified: 01 June 2022) is supported
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
;GetVillageSize(True, "stone", "tree", False)
Func GetVillageSize($bOnBuilderBase = $g_bStayOnBuilderBase, $sStonePrefix = "stone", $sTreePrefix = "tree")
	FuncEnter(GetVillageSize)
	Local $stone = [0, 0, 0, 0, 0, ""], $tree = [0, 0, 0, 0, 0, ""]
	Local $sDirectory = $g_sImgZoomOutDir
	Local $aResult = 0, $stone, $tree, $x, $y
	
	$stone = FindStone($sDirectory)
	If Not $g_bRunState Then Return 0
	SetDebugLog("stone: " & _ArrayToString($stone))
	If $stone[0] = 0 Then
		SetDebugLog("GetVillageSize cannot find stone")
		Return FuncReturn($aResult)
	EndIf
	
	$tree = FindTree($sDirectory, $sTreePrefix, $stone[4])
	If Not $g_bRunState Then Return 0
	SetDebugLog("tree: " & _ArrayToString($tree))
	If $tree[0] = 0 Then
		SetDebugLog("GetVillageSize cannot find tree", $COLOR_ACTION)
		If $bOnBuilderBase Then ZoomOutHelperBB("GetVillageSize")
		Return FuncReturn($aResult)
	Else
		; calculate village size, see https://en.wikipedia.org/wiki/Pythagorean_theorem
		Local $a = $tree[0] - $stone[0]
		Local $b = $stone[1] - $tree[1]
		Local $c = Sqrt($a * $a + $b * $b) ;measure distance from stone to tree
		Local $ZoomOffset = 30, $checkZoomOffset = 0
			
		Local $iRefSize = 600
		Local $iIndex = _ArraySearch($g_aVillageRefSize, $stone[4])
		If $iIndex <> -1 Then 
			$iRefSize = $g_aVillageRefSize[$iIndex][2]
			$g_sSceneryCode = $g_aVillageRefSize[$iIndex][0]
			$g_sCurrentScenery = $g_aVillageRefSize[$iIndex][1]
			$g_InnerDiamondLeft = $g_aVillageRefSize[$iIndex][3]
			$g_InnerDiamondRight = $g_aVillageRefSize[$iIndex][4]
			$g_InnerDiamondTop = $g_aVillageRefSize[$iIndex][5]
			$g_InnerDiamondBottom = $g_aVillageRefSize[$iIndex][6]
			If $g_bDebugSetLog Then SetDebugLog("LRTB: " & $g_InnerDiamondLeft & "," & $g_InnerDiamondRight & "," & $g_InnerDiamondTop & "," & $g_InnerDiamondBottom)
		Else
			SetLog("Reference Size no match", $COLOR_ERROR)
			SetLog("Stone2tree = " & $c, $COLOR_INFO)
			Return FuncReturn($aResult)
		EndIf
		
		Local $z = $c / $iRefSize
		SetDebugLog("GetVillageSize, Scenery : " & $g_sSceneryCode & " : " & $g_sCurrentScenery & ", Zoom:" & $z, $COLOR_DEBUG1)
		SetDebugLog("Stone2tree = " & $c)
		SetDebugLog("Reference = " & $iRefSize)
		SetDebugLog("ZoomLevel = " & $z)
		
		$checkZoomOffset = Round(($c - $iRefSize), 2)
		If $checkZoomOffset > $ZoomOffset Then 
			SetDebugLog("Stone2tree:" & Round($c, 2) & " - Reference:" & Round($iRefSize, 2) & " = " & $checkZoomOffset & " > " & $ZoomOffset, $COLOR_DEBUG2)
			;Return FuncReturn($aResult)
		Else
			SetDebugLog("Stone2tree:" & Round($c, 2) & " Reference:" & Round($iRefSize, 2) & " checkZoomOffset: " & $checkZoomOffset, $COLOR_DEBUG2)
		EndIf
		
		Local $stone_x_exp = $stone[2]
		Local $stone_y_exp = $stone[3]
		ConvertVillagePos($stone_x_exp, $stone_y_exp, $z) ; expected x, y position of stone
		$x = $stone[0] - $stone_x_exp
		$y = $stone[1] - $stone_y_exp
		
		;set global var
		$g_iZoomFactor = $z
		$g_ixOffset = $x
		$g_iyOffset = $y
		setVillageOffset($x, $y, $z) ; update DLL with village offset for ConvertToVillagePos
		
		SetDebugLog("GetVillageSize measured: " & $c & ", Zoom factor: " & $z & ", Offset: " & $x & ", " & $y, $COLOR_INFO)

		Dim $aResult[11]
		$aResult[0] = $c
		$aResult[1] = $z
		$aResult[2] = $x
		$aResult[3] = $y
		$aResult[4] = $stone[0]
		$aResult[5] = $stone[1]
		$aResult[6] = $stone[5]
		$aResult[7] = $tree[0]
		$aResult[8] = $tree[1]
		$aResult[9] = $tree[5]
		$aResult[10] = $g_sCurrentScenery

		$g_aVillageSize = $aResult
		ConvertInternalExternArea()
		Return FuncReturn($aResult)
	EndIf
	FuncReturn()
EndFunc   ;==>GetVillageSize

Func FindStone($sDirectory = $g_sImgZoomOutDir, $sStonePrefix = "stone")
	Local $stone = [0, 0, 0, 0, 0, ""]
	Local $a
	
	For $check = 1 To 2
		SetDebugLog("FindStone check : " & $check)
		If $check = 1 Then 
			If Not QuickMIS("BFI", $sDirectory & $sStonePrefix & "\stone" & $g_sSceneryCode & "*", 0, 350, 350, 580) Then
				SetDebugLog("Cannot Find stone file: " & $sStonePrefix & $g_sSceneryCode)
				ContinueLoop
			Else
				$a = StringRegExp($g_sQuickMISName,"stone([0-9A-Z]+)-(\d+)-(\d+)(_.*[.](?:xml|png|bmp))$", $STR_REGEXPARRAYMATCH)
				If UBound($a) = 4 Then
					$stone[0] = $g_iQuickMISX ; x center of stone found
					$stone[1] = $g_iQuickMISY ; y center of stone found
					$stone[2] = $a[1] ; x center of reference stone
					$stone[3] = $a[2] ; y center of reference stone
					$stone[4] = $a[0] ; distance from stone to tree in pixel
					$stone[5] = "stone" & $a[0] & "-" & $a[1] & "-" & $a[2] & $a[3]
					SetDebugLog("Found stone image: " & $stone[5])
					SetDebugLog("Set $g_sSceneryCode = " & $g_sSceneryCode)
					Return $stone
				EndIf					
			EndIf
		Else
			If QuickMIS("BC1", $sDirectory & $sStonePrefix, 0, 350, 350, 580) Then
				$a = StringRegExp($g_sQuickMISName,"stone([0-9A-Z]+)-(\d+)-(\d+)", $STR_REGEXPARRAYMATCH)
				If UBound($a) = 3 Then
					$stone[0] = $g_iQuickMISX ; x center of stone found
					$stone[1] = $g_iQuickMISY ; y center of stone found
					$stone[2] = $a[1] ; x center of reference stone
					$stone[3] = $a[2] ; y center of reference stone
					$stone[4] = $a[0] ; distance from stone to tree in pixel
					$stone[5] = "stone" & $a[0] & "-" & $a[1] & "-" & $a[2]
					$g_sSceneryCode = $a[0]
					SetDebugLog("Found stone image: " & $stone[5])
					SetDebugLog("Set $g_sSceneryCode = " & $g_sSceneryCode)
					Return $stone
				EndIf
			EndIf
		EndIf
		If Not $g_bRunState Then Return
	Next
	Return $stone
EndFunc

Func FindTree($sDirectory = $g_sImgZoomOutDir, $sTreePrefix = "tree", $sSceneryCode = $g_sSceneryCode)
	Local $tree = [0, 0, 0, 0, 0, ""]
	Local $a
	
	SetDebugLog("FindTree")
	If QuickMIS("BFI", $sDirectory & $sTreePrefix & "\tree" & $sSceneryCode & "*", 430, 0, 860, 220) Then
		$a = StringRegExp($g_sQuickMISName,"tree([0-9A-Z]+)-(\d+)-(\d+)(_.*[.](?:xml|png|bmp))$", $STR_REGEXPARRAYMATCH)
		If UBound($a) = 4 Then
			$tree[0] = $g_iQuickMISX ; x center of tree found
			$tree[1] = $g_iQuickMISY ; y center of tree found
			$tree[2] = $a[1] ; x center of reference tree
			$tree[3] = $a[2] ; y center of reference tree
			$tree[4] = $a[0] ; distance from tree to tree in pixel
			$tree[5] = "tree" & $a[0] & "-" & $a[1] & "-" & $a[2] & $a[3]
			SetDebugLog("Found tree image: " & $tree[5])
			Return $tree
		EndIf	
	Else
		SetDebugLog("Cannot Find tree file: " & $sTreePrefix & $sSceneryCode)
	EndIf

	Return $tree
EndFunc

Func UpdateGlobalVillageOffset($x, $y)

	Local $updated = False

	If $g_sImglocRedline <> "" Then

		Local $newReadLine = ""
		Local $aPoints = StringSplit($g_sImglocRedline, "|", $STR_NOCOUNT)

		For $sPoint In $aPoints

			Local $aPoint = GetPixel($sPoint, ",")
			$aPoint[0] += $x
			$aPoint[1] += $y

			If StringLen($newReadLine) > 0 Then $newReadLine &= "|"
			$newReadLine &= ($aPoint[0] & "," & $aPoint[1])

		Next

		; set updated red line
		$g_sImglocRedline = $newReadLine

		$updated = True
	EndIf

	If $g_iTHx <> 0 And $g_iTHy <> 0 Then
		$g_iTHx += $x
		$g_iTHy += $y
		$updated = True
	EndIf

	ConvertInternalExternArea()

	Return $updated

EndFunc   ;==>UpdateGlobalVillageOffset

Func DetectScenery($stone = "None")
	Local $sScenery = ""
	Local $iIndex = 0
	Local $a = StringRegExp($stone, "stone([0-9A-Z]+)", $STR_REGEXPARRAYMATCH)
	If IsArray($a) Then 
		$iIndex = _ArraySearch($g_aVillageRefSize, $a[0])
		$sScenery = $g_aVillageRefSize[$iIndex][1]
	Else
		$sScenery = "Failed scenery detection"
	EndIf

	Return $sScenery
EndFunc

Func getVillageCenteringCoord()
	Local $aValue[2] = [0, 0]
	Local $iRan = Random(0, Ubound($aVillageCenteringCoord) - 1, 1)

	$aValue[0] = $aVillageCenteringCoord[$iRan][0]
	$aValue[1] = $aVillageCenteringCoord[$iRan][1]
	
	If $g_bDebugSetLog Then SetLog("Village Centering Coord : [" & $aValue[0] & "," & $aValue[1] & "]")
	Return $aValue
EndFunc
