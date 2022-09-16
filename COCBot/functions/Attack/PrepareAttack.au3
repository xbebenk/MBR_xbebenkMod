; #FUNCTION# ====================================================================================================================
; Name ..........: PrepareAttack
; Description ...: Checks the troops when in battle, checks for type, slot, and quantity.  Saved in $g_avAttackTroops[SLOT][TYPE/QUANTITY] variable
; Syntax ........: PrepareAttack($pMatchMode[, $Remaining = False])
; Parameters ....: $pMatchMode          - a pointer value.
;                  $Remaining           - [optional] Flag for when checking remaining troops. Default is False.
; Return values .: None
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func PrepareAttack($pMatchMode = 0, $bRemaining = False) ;Assigns troops
	
	If ($pMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($pMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1) Then
		If $g_bDebugMakeIMGCSV And $bRemaining = False And TestCapture() = 0 Then
			If $g_iSearchTH = "-" Then ; If TH is unknown, try again to find as it is needed for filename
				imglocTHSearch(True, False, False)
			EndIf
			SaveDebugImage("clean", False, Default, "TH" & $g_iSearchTH & "-") ; make clean snapshot as well
		EndIf
	EndIf

	If Not $bRemaining Then ; reset Hero variables before attack if not checking remaining troops
		$g_bDropKing = False ; reset hero dropped flags
		$g_bDropQueen = False
		$g_bDropWarden = False
		$g_bDropChampion = False
		If $g_iActivateKing = 1 Or $g_iActivateKing = 2 Then $g_aHeroesTimerActivation[$eHeroBarbarianKing] = 0
		If $g_iActivateQueen = 1 Or $g_iActivateQueen = 2 Then $g_aHeroesTimerActivation[$eHeroArcherQueen] = 0
		If $g_iActivateWarden = 1 Or $g_iActivateWarden = 2 Then $g_aHeroesTimerActivation[$eHeroGrandWarden] = 0
		If $g_iActivateChampion = 1 Or $g_iActivateChampion = 2 Then $g_aHeroesTimerActivation[$eHeroRoyalChampion] = 0

		$g_iTotalAttackSlot = 10 ; reset flag - Slot11+
		$g_bDraggedAttackBar = False
	EndIf

	SetDebugLog("PrepareAttack for " & $pMatchMode & " " & $g_asModeText[$pMatchMode], $COLOR_DEBUG)
	If $bRemaining Then
		SetLog("Checking remaining unused troops for: " & $g_asModeText[$pMatchMode], $COLOR_INFO)
	Else
		SetLog("Initiating attack for: " & $g_asModeText[$pMatchMode], $COLOR_ERROR)
	EndIf

	If _Sleep($DELAYPREPAREATTACK1) Then Return

	Local $iTroopNumber = 0

	Local $avAttackBar = GetAttackBar($bRemaining, $pMatchMode)
	For $i = 0 To UBound($g_avAttackTroops, 1) - 1
		Local $bClearSlot = True ; by default clear the slot, if no corresponding slot is found in attackbar detection
		If $bRemaining Then
			; keep initial heroes to avoid possibly "losing" them when not dropped yet
			;Local $bSlotDetectedAgain = UBound($avAttackBar, 1) > $i And $g_avAttackTroops[$i][0] = Number($avAttackBar[$i][0]) ; wrong, as attackbar array on remain is shorter
			Local $bDropped = Default
			Local $iTroopIndex = $g_avAttackTroops[$i][0]
			Switch $iTroopIndex
				Case $eKing
					$bDropped = $g_bDropKing
				Case $eQueen
					$bDropped = $g_bDropQueen
				Case $eWarden
					$bDropped = $g_bDropWarden
				Case $eChampion
					$bDropped = $g_bDropChampion
			EndSwitch
			If $bDropped = False Then
				SetDebugLog("Discard updating hero " & GetTroopName($g_avAttackTroops[$i][0]) & " because not dropped yet")
				$iTroopNumber += $g_avAttackTroops[$i][2]
				ContinueLoop
			EndIf
			If $bDropped = True Then
				;If $bSlotDetectedAgain Then
					; ok, hero was dropped, really? don't know yet... TODO add check if hero was really dropped...
				;EndIf
				SetDebugLog("Discard updating hero " & GetTroopName($g_avAttackTroops[$i][0]) & " because already dropped")
				$iTroopNumber += $g_avAttackTroops[$i][2]
				ContinueLoop
			EndIf
		EndIf

		If UBound($avAttackBar, 1) > 0 Then
			For $j = 0 To UBound($avAttackBar, 1) - 1
				If $avAttackBar[$j][1] = $i Then
					; troop slot found
					If IsUnitUsed($pMatchMode, $avAttackBar[$j][0]) Then
						$bClearSlot = False
						Local $sLogExtension = ""
						If Not $bRemaining Then
							; Select castle, siege machine and warden mode
							If $pMatchMode = $DB Or $pMatchMode = $LB Then
								Switch $avAttackBar[$j][0]
									Case $eCastle, $eWallW, $eBattleB, $eStoneS, $eSiegeB, $eLogL, $eFlameF
										Local $tmpSiege = $avAttackBar[$j][0]
										If $g_aiAttackUseSiege[$pMatchMode] <= $eSiegeMachineCount + 1 Then
											SelectCastleOrSiege($avAttackBar[$j][0], Number($avAttackBar[$j][5]), $g_aiAttackUseSiege[$pMatchMode])
											SetDebugLog("$avAttackBar[$j][0]=" & $avAttackBar[$j][0])
											If $avAttackBar[$j][0] = -1 Then ; no cc troops available, do not drop a siege
												SetLog("Discard use of Siege/CC", $COLOR_ERROR)
												$avAttackBar[$j][2] = 0
											EndIf
											If $g_bDropEmptySiege[$pMatchMode] = True And $avAttackBar[$j][0] = -1 Then
												$avAttackBar[$j][0] = $tmpSiege
												$avAttackBar[$j][2] = 1
											EndIf
											If $avAttackBar[$j][0] <> $eCastle Then $sLogExtension = " (level " & $g_iSiegeLevel & ")"
										EndIf
									Case $eWarden
										If $g_aiAttackUseWardenMode[$pMatchMode] <= 1 Then $sLogExtension = SelectWardenMode($g_aiAttackUseWardenMode[$pMatchMode], Number($avAttackBar[$j][5]))
								EndSwitch
							EndIf

							; populate the i-th slot
							$g_avAttackTroops[$i][0] = Number($avAttackBar[$j][0]) ; Troop Index
							$g_avAttackTroops[$i][1] = Number($avAttackBar[$j][2]) ; Amount
							$g_avAttackTroops[$i][2] = Number($avAttackBar[$j][3]) ; X-Coord
							$g_avAttackTroops[$i][3] = Number($avAttackBar[$j][4]) ; Y-Coord
							$g_avAttackTroops[$i][4] = Number($avAttackBar[$j][5]) ; OCR X-Coord
							$g_avAttackTroops[$i][5] = Number($avAttackBar[$j][6]) ; OCR Y-Coord
						Else
							; only update amount of i-th slot
							$g_avAttackTroops[$i][1] = Number($avAttackBar[$j][2]) ; Amount
						EndIf
						$iTroopNumber += $avAttackBar[$j][2]

						Local $sDebugText = $g_bDebugSetlog ? " (X:" & $avAttackBar[$j][3] & "|Y:" & $avAttackBar[$j][4] & "|OCR-X:" & $avAttackBar[$j][5] & "|OCR-Y:" & $avAttackBar[$j][6] & ")" : ""
						SetLog($avAttackBar[$j][1] & ": " & $avAttackBar[$j][2] & " " & GetTroopName($avAttackBar[$j][0], $avAttackBar[$j][2]) & $sLogExtension & $sDebugText, $COLOR_SUCCESS)
					Else
						SetDebugLog("Discard use of " & GetTroopName($avAttackBar[$j][0]) & " (" & $avAttackBar[$j][0] & ")", $COLOR_ERROR)
					EndIf
					ExitLoop
				EndIf
			Next
		EndIf

		If $bClearSlot Then
			; slot not identified
			$g_avAttackTroops[$i][0] = -1
			$g_avAttackTroops[$i][1] = 0
			$g_avAttackTroops[$i][2] = 0
			$g_avAttackTroops[$i][3] = 0
			$g_avAttackTroops[$i][4] = 0
			$g_avAttackTroops[$i][5] = 0
		EndIf
	Next
	If Not $bRemaining Then SetSlotSpecialTroops()

	Return $iTroopNumber
EndFunc   ;==>PrepareAttack

Func SelectCastleOrSiege(ByRef $iTroopIndex, $iX, $iCmbSiege)

	;Local $hStarttime = _Timer_Init()
	Local $aSiegeTypes[8] = [$eCastle, $eWallW, $eBattleB, $eStoneS, $eSiegeB, $eLogL, $eFlameF, "Any"]

	Local $ToUse = $aSiegeTypes[$iCmbSiege]
	Local $bNeedSwitch = False, $bAnySiege = False, $NeedHigherLevel = False
	Local $sLog = GetTroopName($iTroopIndex)

	Switch $ToUse
		Case $iTroopIndex ; the same as current castle/siege
			If $iTroopIndex <> $eCastle Then
				$bNeedSwitch = True
				$NeedHigherLevel = True
				SetLog(GetTroopName($iTroopIndex) & " level " & $g_iSiegeLevel & " detected. Looking for higher level or Donated Siege.")
			EndIf

		Case $eCastle, $eWallW, $eBattleB, $eStoneS, $eSiegeB, $eLogL, $eFlameF ; NOT the same as current castle/siege
			$bNeedSwitch = True
			$NeedHigherLevel = True
			SetLog(GetTroopName($iTroopIndex) & ($ToUse <> $eCastle ? " level " & $g_iSiegeLevel & " detected. Try looking for " : " detected. Switching to ") & GetTroopName($ToUse))

		Case "Any" ; use any siege
			If $iTroopIndex = $eCastle Or ($iTroopIndex <> $eCastle And $g_iSiegeLevel < 4) Then ; found Castle or a low level Siege
				$bNeedSwitch = True
				$bAnySiege = True
				SetLog(GetTroopName($iTroopIndex) & ($iTroopIndex = $eCastle ? " detected. Try looking for any siege machine" : " level " & $g_iSiegeLevel & " detected. Try looking for any higher siege machine"))
			EndIf
	EndSwitch

	If $bNeedSwitch Then
		Local $sSearchArea = GetDiamondFromRect($iX - 30 & ",630," & $iX + 35 & ",660")
		Local $aiSwitchBtn = decodeSingleCoord(findImage("SwitchSiegeButton", $g_sImgSwitchSiegeMachine & "SiegeAtt*", $sSearchArea, 1, True, Default))
		If IsArray($aiSwitchBtn) And UBound($aiSwitchBtn, 1) = 2 Then
			ClickP($aiSwitchBtn)
			; wait to appears the new small window
			Local $iLastX = $aiSwitchBtn[0] - 30, $iLastY = $aiSwitchBtn[1]
			If _Sleep(2000) Then Return

			; Lets detect the CC & Sieges and click - search window is - X, 530, X + 390, 530 + 30
			Local $aSearchResult = GetListSiege($iX - 50, 470, $iX + 350, 550)
			If IsProblemAffect(True) Then Return
			If Not $g_bRunState Then Return
			If IsArray($aSearchResult) And Ubound($aSearchResult) > 0 Then
				Local $FinalCoordX = $iLastX, $FinalCoordY = $iLastY, $iFinalLevel = 1, $HigherLevelFound = False, $AnySiegeFound = False
				Local $TmpIndex = 0
				$TmpIndex = _ArraySearch($aSearchResult, $eCastle, 0, 0, 0, 0, 1, 5)
				If $TmpIndex = -1 Then
					$iTroopIndex = -1 ;set ByRef
					SetLog("No " & GetTroopName($eCastle) & " Detected, discard Siege use", $COLOR_INFO)
					Click($iLastX, $iLastY, 1)
					Return
				EndIf

				If $ToUse = $eCastle Then
					SetDebugLog("ToUse : Castle")

					$TmpIndex = _ArraySearch($aSearchResult, $eCastle, 0, 0, 0, 0, 1, 5)
					If $aSearchResult[$TmpIndex][5] = $eCastle Then
						$iTroopIndex = $eCastle ;set ByRef
						SetDebugLog("Castle found on : [" & $aSearchResult[$TmpIndex][1] & "," & $aSearchResult[$TmpIndex][2] & "]")
						Click($aSearchResult[$TmpIndex][1], $aSearchResult[$TmpIndex][2])
						If _Sleep(750) Then Return
						Return
					Else
						SetLog("No " & GetTroopName($ToUse) & " found")
						Click($iLastX, $iLastY, 1)
					EndIf
				EndIf

				_ArraySort($aSearchResult, 0, 0, 0, 1) ;sort asc by x coord
				If $NeedHigherLevel Or $bAnySiege Then
					If $bAnySiege Then
						SetDebugLog("AnySiege")
						Local $iSiegeIndex
						For $i = 0 To UBound($aSearchResult) - 1
							$iSiegeIndex = $aSearchResult[$i][5]
							If $iSiegeIndex >= $eWallW And $iSiegeIndex <= $eFlameF Then
								Local $SiegeLevel = $aSearchResult[$i][3]
								Local $OwnSiege = $aSearchResult[$i][4]
								Local $SiegeName = $aSearchResult[$i][0]
								SetDebugLog($i & ". SiegeName: " & $SiegeName & ", OwnSiege: " & $OwnSiege & ", Level: " & $SiegeLevel & ", Coords: " & $aSearchResult[$i][1] & "," & $aSearchResult[$i][2])
								If $iFinalLevel < $SiegeLevel Then
									$iTroopIndex = $iSiegeIndex ;set ByRef
									$iFinalLevel = $SiegeLevel
									$SiegeName = $aSearchResult[$i][0]
									$FinalCoordX = $aSearchResult[$i][1]
									$FinalCoordY = $aSearchResult[$i][2]
									$AnySiegeFound = True
									SetDebugLog("Selected SiegeName:" & $SiegeName & " Level:" & $iFinalLevel & " Coord:[" & $FinalCoordX & "," & $FinalCoordY & "]")
								EndIf
								;If $iFinalLevel = 4 Then ExitLoop
								If $OwnSiege = "False" Then ExitLoop
							EndIf
						Next

						If $AnySiegeFound Then
							Click($FinalCoordX, $FinalCoordY)
							$g_iSiegeLevel = $iFinalLevel
						Else
							SetLog("AnySiege : Not found any", $COLOR_ERROR)
							Click($iLastX, $iLastY, 1)
						EndIf
					Else
						Local $TmpIndex = _ArraySearch($aSearchResult, $ToUse, 0, 0, 0, 0, 1, 5)
						SetDebugLog("To Use = [" & $ToUse & "] " & GetTroopName($ToUse) & ", Got:" & $TmpIndex)
						If $TmpIndex < 0 Then
							SetDebugLog(GetTroopName($ToUse) & " ===== Not Found, lets pick any siege", $COLOR_INFO)
							For $i = 0 To UBound($aSearchResult) - 1
								Local $iSiegeIndex = $aSearchResult[$i][5]
								SetDebugLog(GetTroopName($iSiegeIndex))
								If $iSiegeIndex >= $eWallW And $iSiegeIndex <= $eFlameF Then
									Local $OwnSiege = $aSearchResult[$i][4]
									Local $SiegeLevel = $aSearchResult[$i][3]
									SetDebugLog($i & ". Name: " & $aSearchResult[$i][0] & ", OwnSiege: " & $OwnSiege & ", Level: " & $SiegeLevel & ", Coords: " & $aSearchResult[$i][1] & "," & $aSearchResult[$i][2])
									If $iFinalLevel < $SiegeLevel Then
										$iFinalLevel = $SiegeLevel
										$FinalCoordX = $aSearchResult[$i][1]
										$FinalCoordY = $aSearchResult[$i][2]
										$iTroopIndex = $iSiegeIndex
										$HigherLevelFound = True
										SetDebugLog("Got HigherLevel :" & "[" & GetTroopName($iSiegeIndex) & "] Level:" & $iFinalLevel & " Coord:[" & $FinalCoordX & "," & $FinalCoordY & "]")
									EndIf
									If $iFinalLevel = 4 Then ExitLoop
								EndIf
							Next

							If $HigherLevelFound Then
								Click($FinalCoordX, $FinalCoordY)
								$g_iSiegeLevel = $iFinalLevel
							Else
								SetLog("No " & GetTroopName($ToUse) & " found")
								Click($iLastX, $iLastY, 1)
							EndIf
						Else
							$iTroopIndex = $ToUse ;set ByRef
							SetDebugLog("ToUse=" & $ToUse)
							$g_iSiegeLevel = $aSearchResult[$TmpIndex][3]
							Click($aSearchResult[$TmpIndex][1], $aSearchResult[$TmpIndex][2])
							If _Sleep(750) Then Return
							Return
						EndIf
					EndIf
				EndIf
			Else
				If $g_bDebugImageSave Then SaveDebugImage("PrepareAttack_SwitchSiege")
				If IsProblemAffect(True) Then Return
				If Not $g_bRunState Then Return
				; If was not detectable lets click again on green icon to hide the window!
				Setlog("Undetected " & ($bAnySiege ? "any siege machine " : GetTroopName($ToUse)) & " after click on switch btn!", $COLOR_DEBUG)
				Click($iLastX, $iLastY, 1)
				$iTroopIndex = $eCastle
				If _Sleep(750) Then Return
				Return
			EndIf
			If _Sleep(750) Then Return
		Else
			If $iTroopIndex <> $eCastle Then $iTroopIndex = -1 ;setting other than castle only (spesific siege or anysiege) but no switch button, will discard use of siege
			If $ToUse = $eCastle And $iTroopIndex = $eCastle Then $iTroopIndex = $eCastle ;setting castle only, there is castle on attackbar, but no switch button, will use cc
			If $ToUse = $eCastle And $iTroopIndex <> $eCastle Then $iTroopIndex = -1 ;setting castle only, there is siege on attackbar, but no switch button, will discard use siege
			SetDebugLog("ToUse=" & $ToUse & " |iTroopIndex=" & $iTroopIndex)
			SetLog("No switch button = No CC Detected, discard Siege use", $COLOR_INFO)
		EndIf
	EndIf
EndFunc   ;==>SelectCastleOrSiege

Func GetListSiege($x = 135, $y = 470, $x1 = 700, $y1 = 540)
	Local $aResult[0][6], $CheckLvlY = 524
	Local $aSiege[0][3]
	$x += 22
	For $i = 1 To 5
		If QuickMIS("BC1", $g_sImgSwitchSiegeMachine, $x, $y, $x+70, $y1) Then
			_ArrayAdd($aSiege, $g_iQuickMISName & "|" & $g_iQuickMISX & "|" & $g_iQuickMISY)
		EndIf
		$x += 72
	Next

	If IsArray($aSiege) And UBound($aSiege) > 0 Then
		For $i = 0 To UBound($aSiege) - 1
			SetDebugLog("[" & $i & "] Siege: " & $aSiege[$i][0] & ", Coord[" & $aSiege[$i][1] & "," & $aSiege[$i][2] & "]")
			SetDebugLog("getTroopsSpellsLevel(" & $aSiege[$i][1] - 30 & "," & $CheckLvlY & ")", $COLOR_ACTION)
			Local $SiegeLevel = getOcrAndCapture("coc-spellslevel", $aSiege[$i][1] - 30, $CheckLvlY, 20, 20, True); getTroopsSpellsLevel($aTmp[$i][1] - 30, $CheckLvlY)
			SetDebugLog("SiegeLevel=" & $SiegeLevel)
			If $SiegeLevel = "" Then $SiegeLevel = 1
			Local $TroopIndex = TroopIndexLookup($aSiege[$i][0])
			Local $OwnSiege = False
			If IsProblemAffect(True) Then Return
			If Not $g_bRunState Then Return
			If _ColorCheck(_GetPixelColor($aSiege[$i][1] - 30, 466, True), Hex(0x559CDD, 6), 10) Then $OwnSiege = String(True)
			_ArrayAdd($aResult, $aSiege[$i][0] & "|" & $aSiege[$i][1] & "|" & $aSiege[$i][2] & "|" & $SiegeLevel & "|" & $OwnSiege & "|" & $TroopIndex)
		Next
	Else
		SetDebugLog("GetListSiege: ERR", $COLOR_ERROR)
	EndIf
	_ArraySort($aResult, 1, 0, 0, 3)
	Return $aResult
EndFunc

Func SelectWardenMode($iMode, $XCoord)
	; check current G.Warden's mode. Switch to preferred $iMode if needed. Return log text as "(Ground)"  or "(Air)"

	Local $hStarttime = _Timer_Init()
	Local $aSelectMode[2] = ["Ground", "Air"], $aSelectSymbol[2] = ["Foot", "Wing"]
	Local $sLogText = ""

	Local $sArrow = GetDiamondFromRect($XCoord - 20 & ",630(68,30)")
	Local $aCurrentMode = findMultiple($g_sImgSwitchWardenMode, $sArrow, $sArrow, 0, 1000, 1, "objectname,objectpoints", True)

	If $aCurrentMode <> "" And IsArray($aCurrentMode) Then
		Local $aCurrentModeArray = $aCurrentMode[0]
		If Not IsArray($aCurrentModeArray) Or UBound($aCurrentModeArray) < 2 Then Return $sLogText

		SetDebugLog("SelectWardenMode() $aCurrentMode[0]: " & _ArrayToString($aCurrentModeArray))
		If $g_bDebugSetlog Then SetLog("Benchmark G. Warden mode detection: " & StringFormat("%.2f", _Timer_Diff($hStarttime)) & "'ms", $COLOR_DEBUG)

		If $aCurrentModeArray[0] = $aSelectMode[$iMode] Then
			$sLogText = " (" & $aCurrentModeArray[0] & " mode)"
		Else
			Local $aArrowCoords = StringSplit($aCurrentModeArray[1], ",", $STR_NOCOUNT)
			ClickP($aArrowCoords, 1, 0)
			If _Sleep(1200) Then Return

			Local $sSymbol = GetDiamondFromRect(_Min($XCoord - 30, 696) & ",500(162,50)") ; x = 696 when Grand Warden is at slot 10
			Local $aAvailableMode = findMultiple($g_sImgSwitchWardenMode, $sSymbol, $sSymbol, 0, 1000, 2, "objectname,objectpoints", True)
			If $aAvailableMode <> "" And IsArray($aAvailableMode) Then
				For $i = 0 To UBound($aAvailableMode, $UBOUND_ROWS) - 1
					Local $aAvailableModeArray = $aAvailableMode[$i]
					SetDebugLog("SelectWardenMode() $aAvailableMode[" & $i & "]: " & _ArrayToString($aAvailableModeArray))
					If $aAvailableModeArray[0] = $aSelectSymbol[$iMode] Then
						Local $aSymbolCoords = StringSplit($aAvailableModeArray[1], ",", $STR_NOCOUNT)
						ClickP($aSymbolCoords, 1, 0)
						$sLogText =  " (" & $aSelectMode[$iMode] & " mode)"
						ExitLoop
					EndIf
				Next
				If $sLogText = "" Then ClickP($aArrowCoords, 1, 0)
				If $g_bDebugSetlog Then SetLog("Benchmark G. Warden mode selection: " & StringFormat("%.2f", _Timer_Diff($hStarttime)) & "'ms", $COLOR_DEBUG)
			EndIf
		EndIf
	EndIf
	Return $sLogText

EndFunc   ;==>SelectWardenMode

Func IsUnitUsed($iMatchMode, $iTroopIndex)
	If $iTroopIndex < $eKing Then ;Index is a Troop
		If $iMatchMode = $DT Or $iMatchMode = $TB Then Return True
		Local $aTempArray = $g_aaiTroopsToBeUsed[$g_aiAttackTroopSelection[$iMatchMode]]
		Local $iFoundAt = _ArraySearch($aTempArray, $iTroopIndex)
		If $iFoundAt <> -1 Then	Return True
		Return False
	Else ; Index is a Hero/Siege/Castle/Spell
		If $iMatchMode <> $DB And $iMatchMode <> $LB Then
			Return True
		Else
			Switch $iTroopIndex
				Case $eKing
					If (BitAND($g_aiAttackUseHeroes[$iMatchMode], $eHeroKing) = $eHeroKing) Then Return True
				Case $eQueen
					If (BitAND($g_aiAttackUseHeroes[$iMatchMode], $eHeroQueen) = $eHeroQueen) Then Return True
				Case $eWarden
					If (BitAND($g_aiAttackUseHeroes[$iMatchMode], $eHeroWarden) = $eHeroWarden) Then Return True
				Case $eChampion
					If (BitAND($g_aiAttackUseHeroes[$iMatchMode], $eHeroChampion) = $eHeroChampion) Then Return True
				Case $eCastle, $eWallW, $eBattleB, $eStoneS, $eSiegeB, $eLogL, $eFlameF
					If $g_abAttackDropCC[$iMatchMode] Then Return True
				Case $eLSpell
					If $g_abAttackUseLightSpell[$iMatchMode] Or $g_bSmartZapEnable Then Return True
				Case $eHSpell
					If $g_abAttackUseHealSpell[$iMatchMode] Then Return True
				Case $eRSpell
					If $g_abAttackUseRageSpell[$iMatchMode] Then Return True
				Case $eJSpell
					If $g_abAttackUseJumpSpell[$iMatchMode] Then Return True
				Case $eFSpell
					If $g_abAttackUseFreezeSpell[$iMatchMode] Then Return True
				Case $ePSpell
					If $g_abAttackUsePoisonSpell[$iMatchMode] Then Return True
				Case $eESpell
					If $g_abAttackUseEarthquakeSpell[$iMatchMode] = 1 Or $g_bSmartZapEnable Then Return True
				Case $eHaSpell
					If $g_abAttackUseHasteSpell[$iMatchMode] Then Return True
				Case $eCSpell
					If $g_abAttackUseCloneSpell[$iMatchMode] Then Return True
				Case $eISpell
					If $g_abAttackUseInvisibilitySpell[$iMatchMode] Then Return True
				Case $eSkSpell
					If $g_abAttackUseSkeletonSpell[$iMatchMode] Then Return True
				Case $eBtSpell
					If $g_abAttackUseBatSpell[$iMatchMode] Then Return True
				Case Else
					Return False
			EndSwitch
			Return False
		EndIf

		Return False
	EndIf
	Return False
EndFunc   ;==>IsUnitUsed

Func AttackRemainingTime($bInitialze = Default)
	If $bInitialze Then
		$g_hAttackTimer = __TimerInit()
		$g_iAttackTimerOffset = Default
		SuspendAndroidTime(True) ; Reset suspend Android time for compensation when Android is suspended
		Return
	EndIf

	Local $iPrepareTime = 29 * 1000

	If $g_iAttackTimerOffset = Default Then

		; now attack is really starting (or it has already after 30 Seconds)

		; set offset
		$g_iAttackTimerOffset = __TimerDiff($g_hAttackTimer) - SuspendAndroidTime()

		If $g_iAttackTimerOffset > $iPrepareTime Then
			; adjust offset by remove "lost" attack time
			$g_iAttackTimerOffset = $iPrepareTime - $g_iAttackTimerOffset
		EndIf

	EndIf

;~ 	If Not $bInitialze Then Return

	; Return remaining attack time
	Local $iAttackTime = 3 * 60 * 1000
	Local $iRemaining = $iAttackTime - (__TimerDiff($g_hAttackTimer) - SuspendAndroidTime() - $g_iAttackTimerOffset)
	If $iRemaining < 0 Then Return 0
	Return $iRemaining

EndFunc   ;==>AttackRemainingTime