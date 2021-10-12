Func CleanBBYard()
	; Early exist if noting to do
	If Not $g_bChkCleanBBYard Then Return

	; Timer
	Local $hObstaclesTimer = __TimerInit()
	BuilderBaseReport(True, False)
	
	; Obstacles function to Parallel Search , will run all pictures inside the directory

	; Setup arrays, including default return values for $return
	Local $Filename = ""
	Local $Locate = 0
	Local $CleanBBYardXY
	Local $sCocDiamond = "ECD"
	Local $redLines = "ECD"
	Local $bBuilderBase = True
	Local $bNoBuilders = $g_iFreeBuilderCountBB < 1

	If $g_iFreeBuilderCountBB > 0 And Number($g_aiCurrentLootBB[$eLootElixirBB]) > 50000 Then
		Local $aResult = findMultiple($g_sImgCleanBBYard, $sCocDiamond, $redLines, 0, 1000, 10, "objectname,objectlevel,objectpoints", True)
		If IsArray($aResult) Then
			For $matchedValues In $aResult
				Local $aPoints = decodeMultipleCoords($matchedValues[2])
				$Filename = $matchedValues[0] ; Filename
				For $i = 0 To UBound($aPoints) - 1
					$CleanBBYardXY = $aPoints[$i] ; Coords
					If UBound($CleanBBYardXY) > 1 And isInsideDiamondXY($CleanBBYardXY[0], $CleanBBYardXY[1]) Then ; secure x because of clan chat tab
						If $g_bDebugSetlog Then SetDebugLog($Filename & " found (" & $CleanBBYardXY[0] & "," & $CleanBBYardXY[1] & ")", $COLOR_SUCCESS)
						getBuilderCount(False, True)
						If $g_iFreeBuilderCountBB = 0 Then ExitLoop 2
						If IsMainPageBuilderBase() Then Click($CleanBBYardXY[0], $CleanBBYardXY[1], 1, 0, "#0430")
						If _Sleep($DELAYCOLLECT3) Then Return
						_Sleep(1000)
						If Not ClickRemoveObstacle() Then ContinueLoop
						_SleepStatus(11000)
						ClickAway()
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
	If $g_bDebugSetlog Then SetDebugLog("Time: " & Round(__TimerDiff($hObstaclesTimer) / 1000, 2) & "'s", $COLOR_SUCCESS)
	
	UpdateStats()
	ClickAway()

EndFunc   ;==>CleanBBYard