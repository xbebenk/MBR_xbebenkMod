Func CleanBBYard($bTest = False)
	If Not $g_bChkCleanBBYard Then Return
	$g_bStayOnBuilderBase = True
	BuilderBaseReport(True)
	GotoLowerZone()
	ZoomOut()
	
	Local $hObstaclesTimer = __TimerInit()
	SetLog("CleanBBYard: Try removing obstacles", $COLOR_INFO)
	If $g_aiCurrentLootBB[$eLootElixirBB] < 30000 And Not $bTest Then 
		SetLog("Current BB Elixir Below 30000, skip CleanBBYard", $COLOR_DEBUG2)
		Return
	EndIf
	
	Local $Locate = 0
	Local $Result = QuickMIS("CNX", $g_sImgCleanBBLower, $g_OuterDiamondLeft, $g_OuterDiamondTop, $g_OuterDiamondRight, $g_OuterDiamondBottom)
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
					SetLog("Current BB Elixir Below 20000", $COLOR_DEBUG2)
					ExitLoop
				EndIf
			Else 
				SetDebugLog("[" & $Result[$i][0] & "] Coord Outside Village [" & $Result[$i][1] & ", " & $Result[$i][2] & "]", $COLOR_DEBUG2)
			EndIf
		Next
	Else
		SetLog("No Obstacles found on LowerZone", $COLOR_DEBUG2)
	EndIf
	
	If GotoHigherZone() Then
		GetVillageSize()
		$Result = QuickMIS("CNX", $g_sImgCleanBBHigher, $g_OuterDiamondLeft, $g_OuterDiamondTop, $g_OuterDiamondRight, $g_OuterDiamondBottom)
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
					If $g_aiCurrentLootBB[$eLootElixirBB] < 100000 Then
						SetLog("Current BB Elixir Below 100000", $COLOR_DEBUG2)
						ExitLoop
					EndIf
				Else 
					SetDebugLog("[" & $Result[$i][0] & "] Coord Outside Village [" & $Result[$i][1] & ", " & $Result[$i][2] & "]", $COLOR_DEBUG2)
				EndIf
			Next
		Else
			SetLog("No Obstacles found on HigherZone", $COLOR_DEBUG2)
		EndIf
	Else
		SetLog("Fail to switch to HigherZone", $COLOR_DEBUG2)
	EndIf
	
	If $Locate = 0 Then 
		SetLog("No Obstacles found, Yard is clean!", $COLOR_DEBUG2)
	Else
		SetLog("Clean BB Yard Found and Clearing " & $Locate & " Obstacles!", $COLOR_SUCCESS)
		SetLog("CleanBBYard used Time: " & Round(__TimerDiff($hObstaclesTimer) / 1000, 2) & "'s", $COLOR_DEBUG)
	EndIf
	UpdateStats()
EndFunc   ;==>CleanBBYard

Func ClickRemoveObstacleBB($bTest = False)
	If Not $bTest Then 
		If QuickMIS("BC1", $g_sImgCleanBBRemoveButton, 292, 533, 575, 633) Then
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

Func GotoHigherZone()
	If QuickMIS("BC1", $g_sImgCleanBBDownTunnel, 150, 50, 350, 250) Then
		SetLog("Switch to HigherZone", $COLOR_DEBUG1)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(3000) Then Return
		Return True
	EndIf
	Return False
EndFunc

Func GotoLowerZone()	
	If QuickMIS("BC1", $g_sImgCleanBBUpTunnel, 300, 400, 660, 676) Then
		SetLog("Switch to LowerZone", $COLOR_DEBUG1)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(3000) Then Return
		Return True
	EndIf
	Return False
EndFunc
