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

	If Not $g_bSuperTroopsEnable Then Return False
	If Not $g_bRunState Then Return
	If $g_iCommandStop = 0 Or $g_iCommandStop = 3 Then ;halt attack.. do not boost now
		If $g_bSkipBoostSuperTroopOnHalt Then
			SetLog("BoostSuperTroop() skipped, account on halt attack mode", $COLOR_DEBUG)
			Return False
		EndIf
	EndIf
	ZoomOut()
	CheckMainScreen(False, $g_bStayOnBuilderBase, "BoostSuperTroop")
	VillageReport(True, True) ;update village resource
	If OpenBarrel() Then
		For $i = 0 To 1
			If Not $g_bRunState Then Return
			Local $iPicsPerRow = 4, $picswidth = 125, $picspad = 18
			Local $curRow = 1, $columnStart = 150, $iColumnY1 = 280, $iColumnY2 = 440
			Local $BoostCost = 0, $BoostDuration = 0, $TroopBoosted = False
			If $g_iCmbSuperTroops[$i] > 0 Then

					Local $sTroopName = GetSTroopName($g_iCmbSuperTroops[$i] - 1)
					SetLog("Trying to boost " & "[" & $g_iCmbSuperTroops[$i] & "] " & $sTroopName, $COLOR_INFO)

					Local $iColumnX = $columnStart
					Select
						Case $g_iCmbSuperTroops[$i] = 2 Or $g_iCmbSuperTroops[$i] = 6 Or $g_iCmbSuperTroops[$i] = 10 Or $g_iCmbSuperTroops[$i] = 14 ;second column
							$iColumnX = $columnStart + (1 * ($picswidth + $picspad))
						Case $g_iCmbSuperTroops[$i] = 3 Or $g_iCmbSuperTroops[$i] = 7 Or $g_iCmbSuperTroops[$i] = 11 ;third column
							$iColumnX = $columnStart + (2 * ($picswidth + $picspad))
						Case $g_iCmbSuperTroops[$i] = 4 Or $g_iCmbSuperTroops[$i] = 8 Or $g_iCmbSuperTroops[$i] = 12 ;fourth column
							$iColumnX = $columnStart + (3 * ($picswidth + $picspad))
					EndSelect

					Local $iRow = Ceiling($g_iCmbSuperTroops[$i] / $iPicsPerRow) ; get row Stroop
					SetDebugLog("$iRow = " & $iRow, $COLOR_DEBUG)
					StroopNextPage($iRow) ; go directly to the needed Row

					If $iRow = 4 Then ; for last row, we cannot scroll it to middle page
						$iColumnY1 = 360
						$iColumnY2 = 520
					EndIf

					If _Sleep(1500) Then Return
					If QuickMIS("BC1", $g_sImgBoostTroopsClock, $iColumnX, $iColumnY1, $iColumnX + $picswidth, $iColumnY2, True, False) Then ;find pics Clock on spesific row / column (if clock found = troops already boosted)
						SetLog($sTroopName & ", Troops Already boosted", $COLOR_INFO)
						SetDebugLog("Found Clock Image", $COLOR_DEBUG)
						ContinueLoop
					Else
						If _Sleep(1500) Then Return
						SetDebugLog("Clock Image Not Found", $COLOR_DEBUG)
						SetLog($sTroopName & ", Currently is not boosted", $COLOR_INFO)
						If FindStroopIcons($g_iCmbSuperTroops[$i], $iColumnX, $iColumnY1, $iColumnX + $picswidth, $iColumnY2) Then
							;SetLog("QuickMIS(" & "BC1" & ", " & $g_sImgBoostTroopsIcons & "," & $iColumnX & "," & $iColumnY1 & "," & $iColumnX + $picswidth & "," & $iColumnY2 & ")", $COLOR_DEBUG );
							If QuickMIS("BC1", $g_sImgBoostTroopsIcons, $iColumnX, $iColumnY1, $iColumnX + $picswidth, $iColumnY2, True, False) Then ;find pics of Stroop on spesific row / column
								Click($g_iQuickMISX, $g_iQuickMISY)
								If _Sleep(1000) Then Return
								If $g_bForceUseSuperTroopPotion Then
									SetLog("SuperTroop Potion on TH Storage is Full", $COLOR_INFO)
									SetLog("Forcing use SuperTroop Potion", $COLOR_INFO)
									Setlog("Let's try boosting " & $sTroopName & " with potion", $COLOR_INFO)
									If QuickMIS("BC1", $g_sImgBoostTroopsPotion, 400, 500, 580, 570) Then ;find image of Super Potion
										Click($g_iQuickMISX, $g_iQuickMISY)
										If _Sleep(1500) Then Return
										If QuickMIS("BC1", $g_sImgBoostTroopsPotion, 330, 400, 520, 480) Then ;find image of Super Potion again (confirm upgrade)
											;do click boost
											If $bTest Then
												CancelBoost("Using Potion")
												$TroopBoosted = True
											Else
												Click($g_iQuickMISX, $g_iQuickMISY)
												Setlog("Using Potion, Successfully Boost " & $sTroopName, $COLOR_SUCCESS)
												ClickAway()
											EndIf
										Else
											Setlog("Could not find Potion button for final upgrade " & $sTroopName, $COLOR_ERROR)
											NotifyPushToTelegram($g_sProfileCurrentName & ": Failed to boost SuperTroop using potion.")
											ClickAway()
											ClickAway()
											ContinueLoop
										EndIf
									EndIf
								EndIf
								Setlog("Using Dark Elixir...", $COLOR_INFO)
								If QuickMIS("BC1", $g_sImgBoostTroopsButtons, 600, 500, 750, 570) Then ;find image of dark elixir button
									$BoostCost = getResourcesBonus(628, 524) ; get cost
									$BoostDuration = getHeroUpgradeTime(575, 464) ; get duration
									If Not $BoostCost = "" Then
										Click($g_iQuickMISX, $g_iQuickMISY)
										If _Sleep(1500) Then Return
										If QuickMis("BC1", $g_sImgGeneralCloseButton, 570, 160, 640, 230) Then ;find image of Close Button
											Setlog("Using Dark Elixir, Boosting " & $sTroopName, $COLOR_SUCCESS)
											Setlog("BoostCost = " & $BoostCost & " Dark Elixir, Duration = " & $BoostDuration, $COLOR_SUCCESS)
											;do click boost
											If $bTest Then
												CancelBoost("Using Dark Elixir")
												$TroopBoosted = True
											Else
												Click($g_iQuickMISX - 189, $g_iQuickMISY + 256) ;relative from close button image to boost button
												ClickAway()
											EndIf
										Else
											Setlog("Could not find dark elixir button for final upgrade " & $sTroopName, $COLOR_ERROR)
											ClickAway()
											ClickAway()
											ContinueLoop
										EndIf
									Else
										Setlog("Cannot get Boost Cost for " & $sTroopName, $COLOR_ERROR)
										NotifyPushToTelegram($g_sProfileCurrentName & ": Failed to boost SuperTroop using DE.")
										;Let's try using potion
										If $g_bSuperTroopsBoostUsePotion Then
											Setlog("Let's try boosting " & $sTroopName & " with potion", $COLOR_INFO)
											If QuickMIS("BC1", $g_sImgBoostTroopsPotion, 400, 500, 580, 570) Then ;find image of Super Potion
												Click($g_iQuickMISX, $g_iQuickMISY)
												If _Sleep(1500) Then Return
												If QuickMIS("BC1", $g_sImgBoostTroopsPotion, 330, 400, 520, 480) Then ;find image of Super Potion again (confirm upgrade)
													;do click boost
													If $bTest Then
														CancelBoost("Using Potion")
														$TroopBoosted = True
													Else
														Click($g_iQuickMISX, $g_iQuickMISY)
														Setlog("Using Potion, Successfully Boost " & $sTroopName, $COLOR_SUCCESS)
														ClickAway()
													EndIf
												Else
													Setlog("Could not find Potion button for final upgrade " & $sTroopName, $COLOR_ERROR)
													NotifyPushToTelegram($g_sProfileCurrentName & ": Failed to boost SuperTroop using potion.")
													ClickAway()
													ClickAway()
													ContinueLoop
												EndIf
											EndIf
										EndIf
										ClickAway()
										ContinueLoop
									EndIf
								Else
									If Not $bTest Then Setlog("Could not find dark elixir button for upgrade " & $sTroopName, $COLOR_ERROR)
									ClickAway()
									ContinueLoop
								EndIf
							Else
								Setlog("Cannot find " & $sTroopName & ", Troop Not Unlocked yet?", $COLOR_ERROR)
								ClickAway()
								ContinueLoop
							EndIf
						Else
							SetLog("Double Check Image for Icon " & $sTroopName & " Not Found", $COLOR_ERROR)
							SetLog("Troop Not Unlocked yet?", $COLOR_ERROR)
							ContinueLoop
						EndIf
					EndIf
			EndIf
			If _Sleep(1000) Then Return
			$curRow = 1
			If $TroopBoosted = True And $g_iCmbSuperTroops[UBound($g_iCmbSuperTroops) - 1] > 0 And $i = 0 Then OpenBarrel()
		Next
	EndIf ;open barrel
	ClickAway()
	Return False
EndFunc   ;==>BoostSuperTroop

Func OpenBarrel()
	$g_bForceUseSuperTroopPotion = False
	Local $bOpenBarrel = True
	Local $xBarrel = 0, $yBarrel = 0
	If QuickMIS("BC1", $g_sImgBoostTroopsBarrel, 60, 120, 220, 225) Then
		$xBarrel = $g_iQuickMISX
		$yBarrel = $g_iQuickMISY
		; Check if is already boosted.
		Local $EnabledStroop = 0
		For $i = 0 To Ubound($g_iCmbSuperTroops) - 1
			If $g_iCmbSuperTroops[$i] > 0 Then
				$EnabledStroop += 1
			EndIf
		Next
		SetDebugLog("Enabled boost count: " & $EnabledStroop)
		If $EnabledStroop = 1 Then
			Local $Color = _GetPixelColor($g_iQuickMISX - 9, $g_iQuickMISY - 18, True)
			SetDebugLog("[" & $g_iQuickMISX - 9 &","& $g_iQuickMISY - 18 & "] Color:" & $Color)
			If _ColorCheck($Color, Hex(0xEB7100, 6), 50) Or _ColorCheck($Color, Hex(0xF3C127, 6), 50) Or _ColorCheck($Color, Hex(0xC26B00, 6), 10) Then
				SetLog("1 Boost Detected, troops already boosted", $COLOR_SUCCESS)
				$bOpenBarrel = False
			Else
				SetDebugLog("Pixel Color on [" & $g_iQuickMISX - 9 & "," & $g_iQuickMISY - 18 & "] are : " & _GetPixelColor($g_iQuickMISX - 9, $g_iQuickMISY - 18, True))
			EndIf
		EndIf

		If $EnabledStroop = 2 Then
			Local $Color = _GetPixelColor($g_iQuickMISX - 9, $g_iQuickMISY - 18, True)
			Local $Color1 = _GetPixelColor($g_iQuickMISX - 9, $g_iQuickMISY - 18 - 11, True)
			SetDebugLog("Color:" &$Color & ", Color1:" & $Color1)
			If _ColorCheck($Color, Hex(0xF3C427, 6), 50) And _ColorCheck($Color1, Hex(0xF2C227, 6), 50) Then
				SetLog("2 Boost Detected, troops already boosted", $COLOR_SUCCESS)
				$bOpenBarrel = False
			Else
				SetDebugLog("Pixel Color on [" & $g_iQuickMISX - 9 & "," & $g_iQuickMISY - 18 & "] are : " & _GetPixelColor($g_iQuickMISX - 9, $g_iQuickMISY - 18, True))
				SetDebugLog("Pixel Color on [" & $g_iQuickMISX - 9 & "," & $g_iQuickMISY - 18 - 11 & "] are : " & _GetPixelColor($g_iQuickMISX - 9, $g_iQuickMISY - 18 - 11, True))
			EndIf
		EndIf

		If $bOpenBarrel Then
			CheckSuperTroopPotion()
			SetDebugLog("Found Barrel at " & $xBarrel & "," & $yBarrel)
			Click($xBarrel, $yBarrel)
			If IsBoostWindowOpened() Then
				Return True
			Else
				SetLog("Couldn't find super troop window", $COLOR_ERROR)
				ClickAway()
			EndIf
		EndIf
	Else
		SetLog("Couldn't find super troop barrel", $COLOR_ERROR)
		ClickAway()
	EndIf
	Return False
EndFunc   ;==>OpenBarrel

Func CheckSuperTroopPotion()
	If Not OpenMagicItemWindow() Then Return
	Local $Count = 0, $MaxCount = 0
	SetLog("Checking Super Troop Potion", $COLOR_INFO)
	Local $aSearch = decodeSingleCoord(findImage("Super Troop Potion", $g_sImgTraderWindow & "SuperPot*", GetDiamondFromRect("160, 200, 700, 400")))
	If IsArray($aSearch) And UBound($aSearch) = 2 Then
		Local $sReadItemCount = MagicItemCount($aSearch[0], $aSearch[1])
		Local $asReadItemCount = StringSplit($sReadItemCount, "#", $STR_NOCOUNT)
		If IsArray($asReadItemCount) And UBound($asReadItemCount) = 2 Then
			$Count = $asReadItemCount[0]
			$MaxCount = $asReadItemCount[1]
		EndIf
		If Number($Count) = Number($MaxCount) Then $g_bForceUseSuperTroopPotion = True
		SetLog("Super Troop Potion Count: " & $Count & "/" & $MaxCount, $COLOR_INFO)
	EndIf
	ClickAway()
	If _Sleep(1000) Then Return
EndFunc

Func IsBoostWindowOpened()
	Local $aResult
	For $i = 0 To 12 ;wait for about 3 seconds
		$aResult = _PixelSearch(699,160, 700, 161, Hex(0xFFFFFF, 6) , 6, True) ;check red button x
		If IsArray($aResult) And UBound($aResult) > 1 Then
			Return True
		EndIf
		If _Sleep(250) Then Return
	Next
	Return False
EndFunc

Func StroopNextPage($iRow)
	Local $iXMidPoint = 425
	SetDebugLog("Goto Row: " & $iRow, $COLOR_DEBUG)
	For $i = 1 To $iRow - 1
		ClickDrag($iXMidPoint, 250, $iXMidPoint, 65, 500)
		If _Sleep(1000) Then Return
	Next
EndFunc   ;==>StroopNextPage

Func GetSTroopName(Const $iIndex)
	Return $g_asSuperTroopNames[$iIndex]
EndFunc   ;==>GetSTroopName

Func FindStroopIcons($iIndex, $iColumnX, $iColumnY1, $iColumnX1, $iColumnY2)

	Local $FullTemp
	$FullTemp = SearchImgloc($g_sImgBoostTroopsIcons, $iColumnX, $iColumnY1, $iColumnX1, $iColumnY2)
	SetDebugLog("Troop SearchImgloc returned:" & $FullTemp[0] & ".", $COLOR_DEBUG)
	SetLog("Trying to find" & "[" & $iIndex & "] " & GetSTroopName($iIndex - 1), $COLOR_DEBUG)
	If StringInStr($FullTemp[0] & " ", "empty") > 0 Then Return

	If $FullTemp[0] <> "" Then
		Local $iFoundTroopIndex = TroopIndexLookup($FullTemp[0])
		For $i = $eTroopBarbarian To $eTroopCount - 1
			If $iFoundTroopIndex = $i Then
				SetDebugLog("Detected " & "[" & $iFoundTroopIndex & "] " & $g_asTroopNames[$i], $COLOR_DEBUG)
				If $g_asTroopNames[$i] = GetSTroopName($iIndex - 1) Then Return True
				ExitLoop
			EndIf
			If $i = $eTroopCount - 1 Then ; detection failed
				SetDebugLog("Troop Troop Detection Failed", $COLOR_DEBUG)
			EndIf
		Next
	EndIf
	Return False
EndFunc   ;==>FindStroopIcons

Func CancelBoost($aMessage = "")
	SetLog($aMessage & ", Only Testing", $COLOR_ERROR)
	SetLog(" -- Cancelling", $COLOR_DEBUG)
	ClickAway()
	If _Sleep(500) Then Return
	ClickAway()
	If _Sleep(500) Then Return
	ClickAway()
	If _Sleep(1000) Then Return
EndFunc   ;==>CancelBoost








