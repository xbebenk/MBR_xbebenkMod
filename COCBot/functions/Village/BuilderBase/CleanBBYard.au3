Func CleanBBYard($bTest = False)
	If Not $g_bChkCleanBBYard Then Return
	$g_bStayOnBuilderBase = True
	BuilderBaseReport(True)
	ZoomOut()
	If $g_sSceneryCode <> "BL" Then 
		SetLog("Builder Base Lower Zone Not detected, exit!", $COLOR_ERROR)
		Return
	EndIf
	; Timer
	Local $hObstaclesTimer = __TimerInit()
	SetLog("CleanBBYard: Try removing obstacles", $COLOR_DEBUG)
	If $g_aiCurrentLootBB[$eLootElixirBB] < 30000 And Not $bTest Then 
		SetLog("Current BB Elixir Below 30000, skip CleanBBYard", $COLOR_DEBUG)
		Return
	EndIf
	
	Local $Locate = 0
	
	Local $Result = QuickMIS("CNX", $g_sImgCleanBBYard, $OuterDiamondLeft, $OuterDiamondTop, $OuterDiamondRight, $OuterDiamondBottom)
	If IsArray($Result) And UBound($Result) > 0 Then
		For $i = 0 To UBound($Result) - 1
			If isInsideDiamondXY($Result[$i][1], $Result[$i][2], True) Then
				Click($Result[$i][1], $Result[$i][2])
				If _Sleep(1000) Then Return
				If ClickRemoveObstacleBB($bTest) Then
					$Locate += 1
					SetLog($Result[$i][0] & " found (" & $Result[$i][1] & "," & $Result[$i][2] & ")", $COLOR_SUCCESS)
					Click(800, 300) ;clickaway
					If _Sleep(500) Then Return
				Else
					If _Sleep(500) Then Return
					ContinueLoop
				EndIf
				
				BuilderBaseReport(True, False)
				If $g_aiCurrentLootBB[$eLootElixirBB] < 20000 Then
					SetLog("Current BB Elixir Below 20000, skip CleanBBYard", $COLOR_DEBUG)
					ExitLoop
				EndIf
			Else 
				SetLog("[" & $Result[$i][0] & "] Coord Outside Village [" & $Result[$i][1] & ", " & $Result[$i][2] & "]", $COLOR_DEBUG)
			EndIf
		Next
	EndIf
	
	If $Locate = 0 Then 
		SetLog("No Obstacles found, Yard is clean!", $COLOR_SUCCESS)
	Else
		SetLog("Clean BB Yard Found and Clearing " & $Locate & " Obstacles!", $COLOR_SUCCESS)
	EndIf
	SetLog("CleanBBYard used Time: " & Round(__TimerDiff($hObstaclesTimer) / 1000, 2) & "'s", $COLOR_DEBUG)
	UpdateStats()
EndFunc   ;==>CleanBBYard

Func ClickRemoveObstacleBB($bTest = False)
	If Not $bTest Then 
		If QuickMIS("BC1", $g_sImgCleanBBYard & "RemoveObstacle\", 292, 533, 575, 633) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(500) Then Return
			If IsGemOpen(True) Then
				Return False
			Else
				Return True
			EndIf
		EndIf
	Else
		SetLog("Only for Testing", $COLOR_ERROR)
	EndIf
	Return False
EndFunc

