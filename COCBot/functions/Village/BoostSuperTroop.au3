; #FUNCTION# ====================================================================================================================
; Name ..........: Boost a troop to super troop
; Description ...:
; Syntax ........: BoostSuperTroop()
; Parameters ....:
; Return values .:
; Author ........: xbebenk (08/2021)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BoostSuperTroop($bTest = False)

	If Not $g_bSuperTroopsEnable Then
		Return False
	EndIf
	
	If $g_iCommandStop = 0 Or $g_iCommandStop = 3 Then ;halt attack.. do not boost now
		If $g_bSkipBoostSuperTroopOnHalt Then 
			SetLog("BoostSuperTroop() skipped, account on halt attack mode", $COLOR_DEBUG)
			Return False
		EndIf
	EndIf
	
	For $i = 0 To 1 
		Local $iPicsPerRow = 4, $picswidth = 125, $picspad = 18
		local $curRow = 1, $iXMidPoint = 430, $columnStart = 150, $iColumnY1 = 310, $iColumnY2 = 470
		
		If $g_iCmbSuperTroops[$i] > 0 Then
			If OpenBarrel() Then
				If _Sleep(1000) Then Return
				Local $sTroopName = GetSTroopName($g_iCmbSuperTroops[$i] - 1)
				SetLog("Trying to boost " & "[" & $g_iCmbSuperTroops[$i] & "] " & $sTroopName, $COLOR_INFO)
				;ClickDrag($iXMidPoint, 280, $iXMidPoint, 600, 1000) ; return to top row 
				;If _Sleep(1000) Then Return
				
				Local $iColumnX = $columnStart
				Select 
					Case $g_iCmbSuperTroops[$i] = 2 Or $g_iCmbSuperTroops[$i] = 6 Or $g_iCmbSuperTroops[$i] = 10
						$iColumnX = $columnStart + (1 * ($picswidth + $picspad))
					Case $g_iCmbSuperTroops[$i] = 3 Or $g_iCmbSuperTroops[$i] = 7 Or $g_iCmbSuperTroops[$i] = 11
						$iColumnX = $columnStart + (2 * ($picswidth + $picspad))
					Case $g_iCmbSuperTroops[$i] = 4 Or $g_iCmbSuperTroops[$i] = 8 Or $g_iCmbSuperTroops[$i] = 12
						$iColumnX = $columnStart + (3 * ($picswidth + $picspad))
				EndSelect
				
				Local $iRow = Ceiling($g_iCmbSuperTroops[$i] / $iPicsPerRow); get row Stroop
				While($curRow < $iRow) ; go directly to the needed Row
					StroopNextPage($curRow, $iRow, $iXMidPoint) ; go to next row
					$curRow += 1 ; Next Row
					If $curRow = 3 Then
						$iColumnY1 = 385
						$iColumnY2 = 545
					EndIf
					If _Sleep(1000) Then Return
				WEnd
				;Setlog("columnRect = " & $iColumnX & "," & $iColumnY1 &"," & $iColumnX + $picswidth & "," & $iColumnY2, $COLOR_DEBUG)
				
				
				;SetLog("QuickMIS(" & "BC1" & ", " & $g_sImgBoostTroopsClock & "," & $iColumnX & "," & $iColumnY1 & "," & $iColumnX + $picswidth & "," & $iColumnY2 & ")", $COLOR_DEBUG );
				If QuickMIS("BC1", $g_sImgBoostTroopsClock, $iColumnX, $iColumnY1, $iColumnX + $picswidth, $iColumnY2, True, False) Then ;find pics Clock on spesific row / column (if clock found = troops already boosted)
					SetLog($sTroopName & ", Troops Already boosted", $COLOR_INFO)
					ClickAway()
				Else
					If _Sleep(1500) Then Return
					SetLog($sTroopName & ", Currently is not boosted", $COLOR_INFO)
					;SetLog("QuickMIS(" & "BC1" & ", " & $g_sImgBoostTroopsIcons & "," & $iColumnX & "," & $iColumnY1 & "," & $iColumnX + $picswidth & "," & $iColumnY2 & ")", $COLOR_DEBUG );
					If QuickMIS("BC1", $g_sImgBoostTroopsIcons, $iColumnX, $iColumnY1, $iColumnX + $picswidth, $iColumnY2, True, False) Then ;find pics of Stroop on spesific row / column
						Click($g_iQuickMISX + $iColumnX,$g_iQuickMISY + $iColumnY1,1) 
						If _Sleep(500) Then Return
						If QuickMIS("BC1", $g_sImgBoostTroopsButtons, 0, 0, $g_iGAME_WIDTH, $g_iGAME_HEIGHT, True, False) Then ;find image of dark elixir button
							Click($g_iQuickMISX,$g_iQuickMISY,1) 
							If _Sleep(500) Then Return
							If QuickMIS("BC1", $g_sImgBoostTroopsButtons, 0, 0, $g_iGAME_WIDTH, $g_iGAME_HEIGHT, True, False) Then ;find image of dark elixir button again (confirm upgrade)
								;do click boost
								If $bTest Then
									SetLog("Test = True, Click(" & $g_iQuickMISX & "," & $g_iQuickMISY & ",1)",$COLOR_DEBUG) 
									ClickAway()
									ClickAway()
									ExitLoop
								EndIf
								Click($g_iQuickMISX,$g_iQuickMISY,1) 
								;SetLog("Click(" & $g_iQuickMISX & "," & $g_iQuickMISY & ",1) ", $COLOR_INFO)
								Setlog("Successfully Boost " & $sTroopName, $COLOR_INFO)
								ClickAway()
							Else
								Setlog("Could not find dark elixir button for final upgrade " & $sTroopName, $COLOR_ERROR)
								ClickAway()
								ClickAway()
							Endif
						Else
							Setlog("Could not find dark elixir button for upgrade " & $sTroopName, $COLOR_ERROR)
							ClickAway()
						EndIf
					Else
						Setlog("Cannot find " & $sTroopName & ", Troop Not Unlocked yet?", $COLOR_ERROR)
						ClickAway()
					EndIf
				EndIf
			EndIf ;open barrel
		EndIf
		If _Sleep(1000) Then Return
		$curRow = 1
	Next
	ClickAway()
	Return False
 EndFunc   ;==>BoostSuperTroop

Func OpenBarrel()
	ClickAway()
	If QuickMIS("BC1", $g_sImgBoostTroopsBarrel, 0, 0, 220, 225, True, False) Then
		SetLog("Found Barrel at " & $g_iQuickMISX & "," & $g_iQuickMISY, $COLOR_DEBUG)
		Click($g_iQuickMISX,$g_iQuickMISY,1)
		Return True
	Else
		SetLog("Couldn't find super troop barrel", $COLOR_ERROR)
		ClickAway()
	EndIf
	Return False
	
EndFunc

Func StroopNextPage($curRow, $iRow, $iXMidPoint)
	If $curRow >= $iRow Then Return ; nothing left to scroll
	ClickDrag($iXMidPoint, 280, $iXMidPoint, 95,1000) 
EndFunc

Func GetSTroopName(Const $iIndex)
	Return $g_asSuperTroopNames[$iIndex]
EndFunc   ;==>GetTroopName

