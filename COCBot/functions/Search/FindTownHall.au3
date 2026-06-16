#include-once

Func FindTownHall()
	If Not $g_bRunState Then Return
	Local $sTHString = "-"
	Local $aTH, $aiTHPos[2], $aaTHPos[1], $aTHLocation
	
	;reset
	$g_iSearchTH = "-"
	$g_sTHLoc = ""
	$g_iTHx = 0
	$g_iTHy = 0 
	
	For $try = 1 To 2
		SetDebugLog("[" & $try & "] FindTownHall #" & $try, $COLOR_ACTION)
		$aTH = QuickMIS("CNX", $g_sImgTownHall, $g_InnerDiamondLeft, $g_InnerDiamondTop, $g_InnerDiamondRight, $g_InnerDiamondBottom)
		If IsArray($aTH) And UBound($aTH) > 0 Then
			_ArraySort($aTH, 1, 0, 0, 3) ;sort TH Level descending
			For $i = 0 To UBound($aTH) - 1
				If Not IsInsideDiamondXY($aTH[$i][1], $aTH[$i][2]) Then ContinueLoop ;not inside diamond
				SetDebugLog("Found TH Level " & $aTH[$i][3] & " on " & $aTH[$i][1] & "," & $aTH[$i][2], $COLOR_INFO)
				$g_iTHx = $aTH[$i][1]
				$g_iTHy = $aTH[$i][2]
				$aiTHPos[0] = $aTH[$i][1]
				$aiTHPos[1] = $aTH[$i][2]
				$aaTHPos[0] = $aiTHPos
				$g_iSearchTH = $aTH[$i][3]
				$aTHLocation = isInsideSmallDiamondXY($g_iTHx, $g_iTHy) 
				$g_sTHLoc = $aTHLocation[1]
				$sTHString = " [TH]:" & StringFormat("%2s", $g_iSearchTH) & ", " & $g_sTHLoc
				_ObjPutValue($g_oBldgAttackInfo, $eBldgTownHall & "_LOCATION", $aaTHPos)
				If $g_sTHLoc <> "-" Then ExitLoop 2 ; exit, we found Townhall location
			Next
		EndIf
		If _Sleep(500) Then Return
	Next

	Return $sTHString
EndFunc
