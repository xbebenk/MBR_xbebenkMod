Func CleanBBYard($bTest = False)
	; Early exist if noting to do
	If Not $g_bChkCleanBBYard Then Return	
	
	; Timer
	Local $hObstaclesTimer = __TimerInit()
	getBuilderCount(False, True)
	SetLog("CleanBBYard: Try removing obstacles", $COLOR_DEBUG)
	; Obstacles function to Parallel Search , will run all pictures inside the directory
	If $g_iFreeBuilderCountBB = 0 Then 
		SetLog("Master Builder Not Available", $COLOR_DEBUG)
		Return
	EndIf
	If $g_aiCurrentLootBB[$eLootElixirBB] < 30000 Then 
		SetLog("Current BB Elixir Below 30000, skip CleanBBYard", $COLOR_DEBUG)
		Return
	EndIf
	; Setup arrays, including default return values for $return
	Local $Filename = ""
	Local $Locate = 0
	Local $CleanBBYardXY
	Local $sCocDiamond = "ECD"
	Local $redLines = "ECD"
	Local $bBuilderBase = True
	Local $bNoBuilders = $g_iFreeBuilderCountBB < 1

	If $g_iFreeBuilderCountBB > 0 Then
		Local $aResult = findMultiple($g_sImgCleanBBYard, $sCocDiamond, $redLines, 0, 1000, 10, "objectname,objectlevel,objectpoints", True)
		If IsArray($aResult) Then
			For $matchedValues In $aResult
				Local $aPoints = decodeMultipleCoords($matchedValues[2])
				$Filename = $matchedValues[0] ; Filename
				For $i = 0 To UBound($aPoints) - 1
					$CleanBBYardXY = $aPoints[$i] ; Coords
					If UBound($CleanBBYardXY) > 1 And isSafeCleanYardXY($CleanBBYardXY[0], $CleanBBYardXY[1]) Then ; secure x because of clan chat tab
						SetDebugLog($Filename & " found (" & $CleanBBYardXY[0] & "," & $CleanBBYardXY[1] & ")", $COLOR_SUCCESS)
						getBuilderCount(False, True)
						If $g_iFreeBuilderCountBB = 0 Then ExitLoop 2
						If IsMainPageBuilderBase() Then Click($CleanBBYardXY[0], $CleanBBYardXY[1], 1, 0, "#0430")
						If _Sleep($DELAYCOLLECT3) Then Return
						_Sleep(1000)
						If Not ClickRemoveObstacle($bTest, True) Then ContinueLoop
						$g_aiCurrentLootBB[$eLootElixirBB] = getResourcesMainScreen(705, 72)
						If $g_aiCurrentLootBB[$eLootElixirBB] < 20000 Then ExitLoop 2
						If $Filename = "Groove" or $Filename = "Groove1" Then
							_SleepStatus(72000)
						Else
							_SleepStatus(12000)
						EndIf
						ClickAway("Left")
						$Locate += 1
					EndIf
				Next
			Next
		EndIf
	EndIf

	If $Locate = 0 Then 
		SetLog("No Obstacles found, Yard is clean!", $COLOR_SUCCESS)
	Else
		SetLog("Clean BB Yard Found and Clearing " & $Locate & " Obstacles!", $COLOR_SUCCESS)
	EndIf
	SetDebugLog("Time: " & Round(__TimerDiff($hObstaclesTimer) / 1000, 2) & "'s", $COLOR_SUCCESS)
	
	UpdateStats()
	ClickAway("Left")

EndFunc   ;==>CleanBBYard

Func isSafeCleanYardXY($x, $y)
	If $x < 68 And $y > 316 Then ; coordinates where the game will click on the CHAT tab (safe margin)
		SetDebugLog("Coordinate Inside Village, but Exclude CHAT")
		Return False
	ElseIf $y < 73 Then ; coordinates where the game will click on the BUILDER button or SHIELD button (safe margin)
		SetDebugLog("Coordinate Inside Village, but Exclude BUILDER")
		Return False
	ElseIf $x > 690 And $y > 165 And $y < 215 Then ; coordinates where the game will click on the GEMS button (safe margin)
		SetDebugLog("Coordinate Inside Village, but Exclude GEMS")
		Return False
	EndIf
	Return True
EndFunc   ;==>isSafeCleanYardXY
