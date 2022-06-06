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

;Village Reference size, add info here for every scenery:
;[stoneName, SceneryName, stone2tree distance, DiamondInnerXleft, DiamondInnerXRight, DiamondInnerYTop, DiamondInnerYBottom]
Global $g_aVillageRefSize[15][7] = [["DS", "Default", 612.8, 45, 815, 60, 636], _ ;ok
									["JS", "Jungle", 566.60, 69, 796, 64, 609], _ ;ok
									["BB", "BuilderBase", 523, 117, 748, 128, 595], _
									["CC", "Clashy Construction", 642.40, 50, 811, 60, 636], _ ;ok
									["PC", "Pirate", 598.68, 50, 812, 63, 634], _ ;ok
									["EW", "Winter", 576.41, 68, 794, 61, 607], _ ;ok
									["HM", "Hog Mountain", 637.4, 52, 810, 62, 636], _ ;ok
									["EP", "Epic Jungle", 636.8, 45, 815, 60, 636], _ ;ok
									["9C", "9th Clashivery", 617.21, 76, 803, 64, 611], _ ;ok
									["PG", "Pumpkin Graveyard", 567.01, 94, 784, 58, 581], _
									["SD", "Snow Day", 569.2, 84, 789, 58, 584], _ ;ok
									["TM", "Tiger Mountain", 616, 74, 805, 45, 594], _ ;ok
									["PR", "Primal", 580.41, 74, 803, 64, 613], _ ;ok
									["SH", "Shadow", 598.40, 81, 790, 61, 592], _ ;ok
									["RY", "Royal", 610.20, 57, 799, 48, 603]] ;ok
Global $g_sCurrentScenery = "", $g_sSceneryCode = ""

Global $g_aDebugVillage[4]

Func GetVillageSize($DebugLog = Default, $sStonePrefix = Default, $sTreePrefix = Default, $sFixedPrefix = Default, $bOnBuilderBase = Default, $bCaptureRegion = Default, $bDebugWithImage = False) ; Capture region spam disabled - Team AIO Mod++
	FuncEnter(GetVillageSize)

	; Capture region spam disabled - Team AIO Mod++	
	If $bCaptureRegion = Default Then $bCaptureRegion = True
	If $bCaptureRegion = True Then _CaptureRegion2()
	
	If $bDebugWithImage Then
		Local $subdirectory = $g_sprofiletempdebugpath & "ZoomOut"
		DirCreate($subdirectory)
		Local $date = @YEAR & "-" & @MON & "-" & @MDAY
		Local $time = @HOUR & "." & @MIN & "." & @SEC
		Local $editedimage = _gdiplus_bitmapcreatefromhbitmap($g_hhbitmap2)
		Local $hgraphic = _gdiplus_imagegetgraphicscontext($editedimage)
		Local $hpenred = _gdiplus_pencreate(0xe90f0f, 3)
		Local $hpenwhite = _gdiplus_pencreate(0xffffff, 3)
		Local $hpenyellow = _gdiplus_pencreate(0xe2e90f, 1)
		Local $hpenblue = _gdiplus_pencreate(0x0fbae9, 3)
		Local $hbrush = _gdiplus_brushcreatesolid(-1)
		Local $hformat = _gdiplus_stringformatcreate()
		Local $hfamily = _gdiplus_fontfamilycreate("Arial")
		Local $hfont = _gdiplus_fontcreate($hfamily, 8)
		Local $filename = String($date & "_" & $time & "_ZoomOut_.png")
	EndIf

	Local $stone = [0, 0, 0, 0, 0, ""], $tree = [0, 0, 0, 0, 0, ""]
	If $DebugLog = Default Then $DebugLog = False
	If $sStonePrefix = Default Then $sStonePrefix = "stone"
	If $sTreePrefix = Default Then $sTreePrefix = "tree"
	If $bOnBuilderBase = Default Then
		$bOnBuilderBase = isOnBuilderBase(False)
	EndIf
	
	Local $sDirectory
	If $bOnBuilderBase Then
		$sDirectory = $g_sImgZoomOutDirBB
	Else
		$sDirectory = $g_sImgZoomOutDir
	EndIf
	
	Local $iAdditionalX = 100
	Local $iAdditionalY = 100
	Local $aResult = 0, $stone, $tree, $x, $y
	Local $bStoneSameScenery = False
		
	If Not $bOnBuilderBase Then
		$stone = FindStone($sDirectory, "stone" & $g_sSceneryCode, $iAdditionalX, $iAdditionalY)
		If IsArray($stone) And String($stone[4]) = $g_sSceneryCode Then 
			$bStoneSameScenery = True
			SetDebugLog(String($bStoneSameScenery) & "," & String($stone[4]) & "," & $g_sSceneryCode)
		EndIf
	EndIf
	
	If Not $bStoneSameScenery Then $stone = FindStone($sDirectory, $sStonePrefix, $iAdditionalX, $iAdditionalY)
	If IsArray($stone) And $stone[0] = 0 Or not IsArray($stone) Then
		SetDebugLog("GetVillageSize cannot find stone", $COLOR_WARNING)
		If $bDebugWithImage Then
			_gdiplus_imagesavetofile($editedimage, $subdirectory & "\" & $filename)
			_gdiplus_fontdispose($hfont)
			_gdiplus_fontfamilydispose($hfamily)
			_gdiplus_stringformatdispose($hformat)
			_gdiplus_brushdispose($hbrush)
			_gdiplus_pendispose($hpenred)
			_gdiplus_pendispose($hpenwhite)
			_gdiplus_pendispose($hpenyellow)
			_gdiplus_pendispose($hpenblue)
			_gdiplus_graphicsdispose($hgraphic)
			_gdiplus_bitmapdispose($editedimage)
		EndIf
		Return FuncReturn($aResult)
	Else
		If $bDebugWithImage Then
			_gdiplus_graphicsdrawrect($hgraphic, $g_aDebugVillage[0], $g_aDebugVillage[1], $g_aDebugVillage[2] - $g_aDebugVillage[0], $g_aDebugVillage[3] - $g_aDebugVillage[1], $hpenyellow)
			_gdiplus_graphicsdrawrect($hgraphic, $stone[0] - 5, $stone[1] - 5, 10, 10, $hpenblue)
			_gdiplus_graphicsdrawrect($hgraphic, $stone[2] - 5, $stone[3] - 5, 10, 10, $hpenwhite)
			Local $tlayout = _gdiplus_rectfcreate(Abs($stone[0] - $stone[2]) + $stone[0], Abs($stone[1] - $stone[3]) + $stone[1], 0, 0)
			Local $ainfo = _gdiplus_graphicsmeasurestring($hgraphic, $stone[5] & "_" & $stone[4], $hfont, $tlayout, $hformat)
			_gdiplus_graphicsdrawstringex($hgraphic, $stone[5] & "_" & $stone[4], $hfont, $ainfo[0], $hformat, $hbrush)
		EndIf
		
		If $stone[0] Then
			$tree = FindTree($sDirectory, $sTreePrefix, $iAdditionalX, $iAdditionalY, $stone[4])
			If IsArray($tree) And $tree[0] = 0 Or not IsArray($stone) Then
				SetDebugLog("GetVillageSize cannot find tree", $COLOR_ACTION)
				If $bDebugWithImage Then
					_gdiplus_imagesavetofile($editedimage, $subdirectory & "\" & $filename)
					_gdiplus_fontdispose($hfont)
					_gdiplus_fontfamilydispose($hfamily)
					_gdiplus_stringformatdispose($hformat)
					_gdiplus_brushdispose($hbrush)
					_gdiplus_pendispose($hpenred)
					_gdiplus_pendispose($hpenwhite)
					_gdiplus_pendispose($hpenyellow)
					_gdiplus_pendispose($hpenblue)
					_gdiplus_graphicsdispose($hgraphic)
					_gdiplus_bitmapdispose($editedimage)
				EndIf
				Return FuncReturn($aResult)
			EndIf
		EndIf
			
		If $bDebugWithImage Then
			;-- DRAW EXTERNAL PERIMETER LINES
			_GDIPlus_GraphicsDrawLine($hGraphic, $ExternalArea[0][0], $ExternalArea[0][1], $ExternalArea[2][0], $ExternalArea[2][1], $hpenyellow)
			_GDIPlus_GraphicsDrawLine($hGraphic, $ExternalArea[0][0], $ExternalArea[0][1], $ExternalArea[3][0], $ExternalArea[3][1], $hpenyellow)
			_GDIPlus_GraphicsDrawLine($hGraphic, $ExternalArea[1][0], $ExternalArea[1][1], $ExternalArea[2][0], $ExternalArea[2][1], $hpenyellow)
			_GDIPlus_GraphicsDrawLine($hGraphic, $ExternalArea[1][0], $ExternalArea[1][1], $ExternalArea[3][0], $ExternalArea[3][1], $hpenyellow)

			;-- DRAW INTERNAL PERIMETER LINES
			_GDIPlus_GraphicsDrawLine($hGraphic, $InternalArea[0][0], $InternalArea[0][1], $InternalArea[2][0], $InternalArea[2][1], $hpenred)
			_GDIPlus_GraphicsDrawLine($hGraphic, $InternalArea[0][0], $InternalArea[0][1], $InternalArea[3][0], $InternalArea[3][1], $hpenred)
			_GDIPlus_GraphicsDrawLine($hGraphic, $InternalArea[1][0], $InternalArea[1][1], $InternalArea[2][0], $InternalArea[2][1], $hpenred)
			_GDIPlus_GraphicsDrawLine($hGraphic, $InternalArea[1][0], $InternalArea[1][1], $InternalArea[3][0], $InternalArea[3][1], $hpenred)
			
			_gdiplus_graphicsdrawrect($hgraphic, $g_aDebugVillage[0], $g_aDebugVillage[1], $g_aDebugVillage[2] - $g_aDebugVillage[0], $g_aDebugVillage[3] - $g_aDebugVillage[1], $hpenyellow)
			_gdiplus_graphicsdrawrect($hgraphic, $tree[0] - 5, $tree[1] - 5, 10, 10, $hpenblue)
			_gdiplus_graphicsdrawrect($hgraphic, $tree[2] - 5, $tree[3] - 5, 10, 10, $hpenwhite)
			Local $tlayout = _gdiplus_rectfcreate(Abs($tree[0] - $tree[2]) + $tree[0] - 150, Abs($tree[1] - $tree[3]) + $tree[1] + 10, 0, 0)
			Local $ainfo = _gdiplus_graphicsmeasurestring($hgraphic, $tree[5] & "_" & $tree[4], $hfont, $tlayout, $hformat)
			_gdiplus_graphicsdrawstringex($hgraphic, $tree[5] & "_" & $tree[4], $hfont, $ainfo[0], $hformat, $hbrush)
		EndIf
	EndIf
	
	; calculate village size, see https://en.wikipedia.org/wiki/Pythagorean_theorem
	Local $a = $tree[0] - $stone[0]
	Local $b = $stone[1] - $tree[1]
	Local $c = Sqrt($a * $a + $b * $b) ;measure distance from stone to tree
		
	Local $iRefSize = 600
	Local $iIndex = _ArraySearch($g_aVillageRefSize, $stone[4])
	If $iIndex <> -1 Then 
		$iRefSize = $g_aVillageRefSize[$iIndex][2]
		If Not $bOnBuilderBase Then 
			$g_sSceneryCode = $g_aVillageRefSize[$iIndex][0]
			$g_sCurrentScenery = $g_aVillageRefSize[$iIndex][1]
		EndIf
		$InnerDiamondLeft = $g_aVillageRefSize[$iIndex][3]
		$InnerDiamondRight = $g_aVillageRefSize[$iIndex][4]
		$InnerDiamondTop = $g_aVillageRefSize[$iIndex][5]
		$InnerDiamondBottom = $g_aVillageRefSize[$iIndex][6]
		SetDebugLog("LRTB: " & $InnerDiamondLeft & "," & $InnerDiamondRight & "," & $InnerDiamondTop & "," & $InnerDiamondBottom)
	Else
		SetLog("Reference Size no match", $COLOR_ACTION)
	EndIf
	;Local $iRefSize = Int($stone[4]) ;reference size based on village manual measure
	Local $z = $c / $iRefSize

	Local $txtdebug = "White square : Expected position" & @CRLF & _
					  "Blue square : Detected position" & @CRLF & _
					  "$tree[0]: " & $tree[0] & " - $stone[0]: " & $stone[0] & " = " & $a & @CRLF & _
					  "$stone[1]: " & $stone[1] & " - $tree[1]: " & $tree[1] & " = " & _
					  $b & @CRLF & "Distance is : " & Sqrt($a * $a + $b * $b) & @CRLF & _
					  "Dist Stone to village map: " & $stone[4] & @CRLF & _
					  "Dist Tree to village map: " & $tree[4] & @CRLF &  _
					  "Final: " & $c

	If $bDebugWithImage Then
		SetLog("Village scenery :" & $g_sCurrentScenery)
		SetLog("Reference size :" & $iRefSize)
		SetLog("Distance from tree to stone is : " & Sqrt($a * $a + $b * $b) - $stone[4] - $tree[4])
		SetLog("Village distance is: " & $c)
		SetLog("Dist tree to village map: " & $tree[4])
		SetLog("Dist stone to village map: " & $stone[4])
		SetLog("Village factor is: " & $z)
		Local $tlayout = _gdiplus_rectfcreate(430, 630 + $g_ibottomoffsetyfixed, 0, 0)
		Local $ainfo = _gdiplus_graphicsmeasurestring($hgraphic, $txtdebug, $hfont, $tlayout, $hformat)
		_gdiplus_graphicsdrawstringex($hgraphic, $txtdebug, $hfont, $ainfo[0], $hformat, $hbrush)
		_gdiplus_imagesavetofile($editedimage, $subdirectory & "\" & $filename)
		_gdiplus_fontdispose($hfont)
		_gdiplus_fontfamilydispose($hfamily)
		_gdiplus_stringformatdispose($hformat)
		_gdiplus_brushdispose($hbrush)
		_gdiplus_pendispose($hpenred)
		_gdiplus_pendispose($hpenwhite)
		_gdiplus_pendispose($hpenyellow)
		_gdiplus_pendispose($hpenblue)
		_gdiplus_graphicsdispose($hgraphic)
		_gdiplus_bitmapdispose($editedimage)
	EndIf

	Local $stone_x_exp = $stone[2]
	Local $stone_y_exp = $stone[3]
	ConvertVillagePos($stone_x_exp, $stone_y_exp, $z) ; expected x, y position of stone
	$x = $stone[0] - $stone_x_exp
	$y = $stone[1] - $stone_y_exp
	
	If $DebugLog Then SetDebugLog("GetVillageSize measured: " & $c & ", Zoom factor: " & $z & ", Offset: " & $x & ", " & $y, $COLOR_INFO)

	Dim $aResult[10]
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

	$g_aVillageSize = $aResult
	
	Return FuncReturn($aResult)
	FuncReturn()

EndFunc   ;==>GetVillageSize

Func FindStone($sDirectory = $g_sImgZoomOutDir, $sStonePrefix = "stone", $iAdditionalX = 100, $iAdditionalY = 100)
	Local $aTmpDebugVillage[4]
	$g_aDebugVillage = $aTmpDebugVillage

	Local $stone = [0, 0, 0, 0, 0, ""]
	Local $x0, $y0, $d0, $x, $y, $x1, $y1, $right, $bottom, $a, $b
	Local $aStoneFiles = _FileListToArray($sDirectory & "stone\", $sStonePrefix & "*.*", $FLTA_FILES)
	If @error Then
		SetLog("Error: Missing stone files (" & @error & ")", $COLOR_ERROR)
		Return
	EndIf
	Local $i, $findImage, $sArea, $StoneName
	For $i = 1 To $aStoneFiles[0]
		$findImage = $aStoneFiles[$i]
		$a = StringRegExp($findImage, "stone([0-9A-Z]+)-(\d+)-(\d+)_.*[.](xml|png|bmp)$", $STR_REGEXPARRAYMATCH)
		If UBound($a) = 4 Then
			$StoneName = $a[0]
			$d0 = $StoneName
			$x0 = $a[1]
			$y0 = $a[2]
			$x1 = $x0 - $iAdditionalX
			$y1 = $y0 - $iAdditionalY
			$right = $x0 + $iAdditionalX
			$bottom = $y0 + $iAdditionalY
			$sArea = Int($x1) & "," & Int($y1) & "|" & Int($right) & "," & Int($y1) & "|" & Int($right) & "," & Int($bottom) & "|" & Int($x1) & "," & Int($bottom)
			
			$g_aDebugVillage[0] = $x1
			$g_aDebugVillage[1] = $y1
			$g_aDebugVillage[2] = $right
			$g_aDebugVillage[3] = $bottom
			
			SetDebugLog("GetVillageSize check for image " & $findImage)
			$b = decodeSingleCoord(findImage("stone" & $StoneName, $sDirectory & "stone\" & $findImage, $sArea, 1, False))
			If UBound($b) = 2 Then
				$x = Int($b[0])
				$y = Int($b[1])
				SetDebugLog("Found stone image at " & $x & ", " & $y & ": " & $findImage, $COLOR_INFO)
				$stone[0] = $x ; x center of stone found
				$stone[1] = $y ; y center of stone found
				$stone[2] = $x0 ; x center of reference stone
				$stone[3] = $y0 ; y center of reference stone
				$stone[4] = $d0 ; distance from stone to tree in pixel
				$stone[5] = $findImage
				ExitLoop
			EndIf

		Else
			SetDebugLog("GetVillageSize ignore image " & $findImage & ", reason: " & UBound($a), $COLOR_WARNING)
		EndIf
	Next
	Return $stone
EndFunc

Func FindTree($sDirectory = $g_sImgZoomOutDir, $sTreePrefix = "tree", $iAdditionalX = 100, $iAdditionalY = 100, $sStoneName = "DS")
	Local $aTmpDebugVillage[4]
	$g_aDebugVillage = $aTmpDebugVillage

	Local $tree = [0, 0, 0, 0, 0, ""]
	Local $x0, $y0, $d0, $x, $y, $x1, $y1, $right, $bottom, $a, $b, $i, $findImage, $sArea
	Local $aTreeFiles = _FileListToArray($sDirectory & "tree\", $sTreePrefix & "*.*", $FLTA_FILES)
	If @error Then
		SetLog("Error: Missing tree (" & @error & ")", $COLOR_ERROR)
		Return
	EndIf
	
	Local $scenerycode = "tree" & $sStoneName
	For $i = 1 To $aTreeFiles[0]
		$findImage = $aTreeFiles[$i]
		If StringRegExp($findImage, $scenerycode, $STR_REGEXPMATCH) <> 1 Then ; if stone found is DS, filter only DS tree
			;SetDebugLog("Image skipped: " & $findImage)
			ContinueLoop
		EndIf
		$a = StringRegExp($findImage, "(tree[0-9A-Z]+)-(\d+)-(\d+)_.*[.](xml|png|bmp)$", $STR_REGEXPARRAYMATCH)
		If UBound($a) = 4 Then
			$x0 = $a[1]
			$y0 = $a[2]
			$d0 = "notused"
			
			$x1 = $x0 - $iAdditionalX
			$y1 = $y0 - $iAdditionalY
			$right = $x0 + $iAdditionalX
			$bottom = $y0 + $iAdditionalY
			$sArea = Int($x1) & "," & Int($y1) & "|" & Int($right) & "," & Int($y1) & "|" & Int($right) & "," & Int($bottom) & "|" & Int($x1) & "," & Int($bottom)
			
			$g_aDebugVillage[0] = $x1
			$g_aDebugVillage[1] = $y1
			$g_aDebugVillage[2] = $right
			$g_aDebugVillage[3] = $bottom
			
			SetDebugLog("GetVillageSize check for image " & $findImage)
			$b = decodeSingleCoord(findImage($scenerycode, $sDirectory & "tree\" & $findImage, $sArea, 1, False))
			; sort by x because there can be a 2nd at the right that should not be used
			If UBound($b) = 2 Then
				$x = Int($b[0])
				$y = Int($b[1])
				SetDebugLog("Found tree image at " & $x & ", " & $y & ": " & $findImage, $COLOR_INFO)
				$tree[0] = $x ; x center of tree found
				$tree[1] = $y ; y center of tree found
				$tree[2] = $x0 ; x ref. center of tree
				$tree[3] = $y0 ; y ref. center of tree
				$tree[4] = $d0 ; distance from stone to tree in pixel
				$tree[5] = $findImage
				ExitLoop
			EndIf

		Else
			SetDebugLog("GetVillageSize ignore image " & $findImage & ", reason: " & UBound($a), $COLOR_WARNING)
		EndIf
	Next
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

	If $g_aiTownHallDetails[0] <> 0 And $g_aiTownHallDetails[1] <> 0 Then
		$g_aiTownHallDetails[0] += $x
		$g_aiTownHallDetails[1] += $y
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
