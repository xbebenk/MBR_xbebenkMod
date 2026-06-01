#include-once

Func FindTownHall($bCheck = True)
	If Not $g_bRunState Then Return
	Local $sTHString = "-"
	Local $aTH, $aiTHPos[2], $aTHLoc
	
	;reset
	$g_iSearchTH = "-"
	$g_sTHLoc = ""
	$g_iTHx = 0
	$g_iTHy = 0 
	
	For $try = 1 To 2
		SetDebugLog("[" & $try & "] FindTownHall #" & $try, $COLOR_ACTION)
		$aTH = QuickMIS("CNX", $g_sImgTownHall, $OuterDiamondLeft, $OuterDiamondTop, $OuterDiamondRight, $OuterDiamondBottom)
		If IsArray($aTH) And UBound($aTH) > 0 Then
			_ArraySort($aTH, 1, 0, 0, 3)
			For $i = 0 To UBound($aTH) - 1
				If Not IsInsideDiamondXY($aTH[$i][1], $aTH[$i][2]) Then ContinueLoop
				SetDebugLog("FindTownHall Found TH Level " & $aTH[$i][3] & " on " & $aTH[$i][1] & "," & $aTH[$i][2], $COLOR_INFO)
				$g_iTHx = $aTH[$i][1]
				$g_iTHy = $aTH[$i][2]
				$aiTHPos[0] = $g_iTHx
				$aiTHPos[1] = $g_iTHy
				$g_iSearchTH = $aTH[$i][3]
				$aTHLoc = isInsideSmallDiamond($aiTHPos) 
				$g_sTHLoc = $aTHLoc[1]
				$sTHString = " [TH]:" & StringFormat("%2s", $g_iSearchTH) & ", " & $g_sTHLoc
				If $bCheck Then Return $sTHString
			Next
		EndIf
		If _Sleep(500) Then Return
		If $sTHString <> "-" And Not $bCheck Then Return $sTHString
	Next

	Return $sTHString
EndFunc
