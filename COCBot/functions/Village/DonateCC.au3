; #FUNCTION# ====================================================================================================================
; Name ..........: DonateCC
; Description ...: This file includes functions to Donate troops
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Zax (2015)
; Modified ......: Safar46 (2015), Hervidero (2015-04), HungLe (2015-04), Sardo (2015-08), Promac (2015-12), Hervidero (2016-01), MonkeyHunter (2016-07),
;				   CodeSlinger69 (2017), xbebenk (2024-03)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $g_aiPrepDon[6] = [0, 0, 0, 0, 0, 0]
Global $g_iTotalDonateTroopCapacity, $g_iTotalDonateSpellCapacity, $g_iTotalDonateSiegeMachineCapacity
Global $g_iDonTroopsLimit = 8, $iDonSpellsLimit = 1, $g_iDonTroopsAv = 0, $g_iDonSpellsAv = 0
Global $g_iDonTroopsQuantityAv = 0, $g_iDonTroopsQuantity = 0, $g_iDonSpellsQuantityAv = 0, $g_iDonSpellsQuantity = 0
Global $g_bSkipDonTroops = False, $g_bSkipDonSpells = False, $g_bSkipDonSiege = False, $g_bNewSystemToDonate = False
Global $g_bDonateAllRespectBlk = False ; is turned on off durning donate all section, must be false all other times
Global $g_aiAvailQueuedTroop[$eTroopCount], $g_aiAvailQueuedSpell[$eSpellCount]
Global $g_aiDonQuant
Global $g_aiZero52[5][2] = [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]

Func IsDonateQueueOnly(ByRef $abDonateQueueOnly)
	If Not $abDonateQueueOnly[0] And Not $abDonateQueueOnly[1] Then Return

	For $i = 0 To $eTroopCount - 1
		$g_aiAvailQueuedTroop[$i] = 0
		If $i < $eSpellCount Then $g_aiAvailQueuedSpell[$i] = 0
	Next

	If Not OpenArmyOverview("IsDonateQueueOnly()") Then Return

	getArmyTroopCapacity()

	For $i = 0 To 1
		If Not $g_aiPrepDon[$i * 2] And Not $g_aiPrepDon[$i * 2 + 1] Then $abDonateQueueOnly[$i] = False
		If $abDonateQueueOnly[$i] Then
			SetLog("Checking queued " & ($i = 0 ? "troops" : "spells") & " for donation", $COLOR_ACTION)

			If IsQueueEmpty($i = 0 ? "Troops" : "Spells") Then
				SetLog("Queue " & ($i = 0 ? "Troops" : "Spells") & " is not prepared, proceed donate")
				$abDonateQueueOnly[$i] = False
				ContinueLoop
			EndIf

			If Not OpenTrainTab($i = 0 ? "Train Troops Tab" : "Brew Spells Tab", True, "IsDonateQueueOnly()") Then ContinueLoop

			Local $xQueue = FindxQueueStart()
			If $i = 0 Then
				Local $aSearchResult = CheckQueueTroops(True, False, $xQueue + 10, True) ; $aResult[$Slots][2]: [0] = Name, [1] = Qty
			Else
				Local $aSearchResult = CheckQueueSpells(True, False, $xQueue + 6, True)
			EndIf
			If Not IsArray($aSearchResult) Then ContinueLoop

			$xQueue -= 11 ; offset for checking green check mark
			For $j = 0 To (UBound($aSearchResult) - 1)
				Local $TroopIndex = TroopIndexLookup($aSearchResult[$j][0], "IsDonateQueueOnly()")
				If $TroopIndex < 0 Then ContinueLoop
				If _ColorCheck(_GetPixelColor($xQueue - $j * 61, 235, True), Hex(0x98A826, 6), 20) Then ; the green check symbol [185, 183, 71]
					If $i = 0 Then
						If _ArrayIndexValid($g_aiAvailQueuedTroop, $TroopIndex) Then
							$g_aiAvailQueuedTroop[$TroopIndex] += $aSearchResult[$j][1]
							SetLog("  - " & $g_asTroopNames[$TroopIndex] & " x" & $aSearchResult[$j][1])
						EndIf
					Else
						If _ArrayIndexValid($g_aiAvailQueuedSpell, $TroopIndex - $eLSpell) Then
							$g_aiAvailQueuedSpell[$TroopIndex - $eLSpell] += $aSearchResult[$j][1]
							SetLog("  - " & $g_asSpellNames[$TroopIndex - $eLSpell] & " x" & $aSearchResult[$j][1])
						EndIf
					EndIf
				ElseIf $j = 0 Or ($j = 1 And $aSearchResult[1][0] = $aSearchResult[0][0]) Then
					If $i = 0 Then
						If _ArrayIndexValid($g_aiAvailQueuedTroop, $TroopIndex) Then
							;$g_aiAvailQueuedTroop[$TroopIndex] += $aSearchResult[$j][1]
							SetLog("  - " & $g_asTroopNames[$TroopIndex] & " x" & $aSearchResult[$j][1] & " (training)")
						EndIf
					Else
						If _ArrayIndexValid($g_aiAvailQueuedSpell, $TroopIndex - $eLSpell) Then
							;$g_aiAvailQueuedSpell[$TroopIndex - $eLSpell] += $aSearchResult[$j][1]
							SetLog("  - " & $g_asSpellNames[$TroopIndex - $eLSpell] & " x" & $aSearchResult[$j][1] & " (training)")
						EndIf
					EndIf
				EndIf
			Next
			If _Sleep(250) Then ContinueLoop
		EndIf
	Next

	ClickAway()
	If _Sleep($DELAYDONATECC2) Then Return

EndFunc   ;==>IsDonateQueueOnly

Func PrepareDonateCC()
	;Troops
	$g_aiPrepDon[0] = 0
	$g_aiPrepDon[1] = 0
	For $i = 0 To UBound($g_abChkDonateTroop) - 1
		$g_aiPrepDon[0] = BitOR($g_aiPrepDon[0], ($g_abChkDonateTroop[$i] ? 1 : 0))
	Next

	; Spells
	$g_aiPrepDon[2] = 0
	$g_aiPrepDon[3] = 0
	For $i = 0 To UBound($g_abChkDonateSpell) - 1
		$g_aiPrepDon[2] = BitOR($g_aiPrepDon[2], ($g_abChkDonateSpell[$i] ? 1 : 0))
	Next

	; Siege
	$g_aiPrepDon[4] = 0
	$g_aiPrepDon[5] = 0
	For $i = $eSiegeWallWrecker To $eSiegeMachineCount - 1
		$g_aiPrepDon[4] = BitOR($g_aiPrepDon[4], ($g_abChkDonateTroop[$eTroopCount + $i] ? 1 : 0))
	Next

	$g_iActiveDonate = BitOR($g_aiPrepDon[0], $g_aiPrepDon[1], $g_aiPrepDon[2], $g_aiPrepDon[3], $g_aiPrepDon[4], $g_aiPrepDon[5])
EndFunc   ;==>PrepareDonateCC

Func CheckIUnderstand()
	; check for "I Understand" button
	If QuickMIS("BC1", $g_sImgChatIUnderstand, 50, 400, 320, 550) Then
		SetLog('Clicking "I Understand" button', $COLOR_ACTION)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(1000) Then Return
	EndIf
EndFunc

Func DonateCC($bTest = False, $bSwitch = False, $bClanChatOpened = False)
	Local $bDonateTroop = True
	Local $bDonateSpell = True
	Local $bDonateSiege = True
	Local $bDonate = $g_bDonationEnabled
	Local $bOpen = True, $bClose = False
	Local $ClanString = "", $sNewClanString = ""

	PrepareDonateCC()
	$g_bDonated = False

	If Not $g_bChkDonate Then
		SetDebugLog("Donate Clan Castle troops skip", $COLOR_DEBUG)
		Return ; exit func if no donate checkmarks
	EndIf

	If Not $bDonate Then Return

	;Opens clan tab
	If $bClanChatOpened Then 
		SetLog("DonateCC while RequestCC", $COLOR_INFO)
	Else
		If checkChatTabPixel() Then
			Click($aChatTabClosed[0], $aChatTabClosed[1]) ;Click ClanChatOpen
		EndIf
	EndIf

	If _Sleep(1000) Then Return

	CheckIUnderstand()

	If Not $g_bRunState Then Return

	;Scroll Up
	While WaitforPixel(344, 77, 345, 78, "60A618", 6, 1, "DonateCC-ScrollUp")
		Click(345, 77, 1, 0, "Click Green Scroll Button")
		If _Sleep(1000) Then Return
		$bDonate = True
	Wend

	If Not $g_bRunState Then Return
	If $g_iCommandStop <> 0 And $g_iCommandStop <> 3 Then SetLog("Checking for Donate Requests in Clan Chat", $COLOR_INFO)

	Local $aiSearchArray[4] = [250, 130, 340, 600], $aSearchArea = $aiSearchArray
	Local $aiDonateButton[2] = [0, 0], $ClanString = "", $sNewClanString = ""
	Local $aDonateButton, $bLastCheck = True

	While $bDonate
		If Not $g_bRunState Then Return
		If $g_bDebugSetLog Then SetLog("aSearchArea : " & _ArrayToString($aSearchArea), $COLOR_DEBUG1)
		$aDonateButton = QuickMIS("CNX", $g_sImgDonateButton, $aSearchArea[0], $aSearchArea[1], $aSearchArea[2], $aSearchArea[3])
		If $g_bDebugSetLog Then SetLog("Donate Buttons: " & _ArrayToString($aDonateButton), $COLOR_DEBUG1)
		If IsArray($aDonateButton) And UBound($aDonateButton) > 0 Then
			_ArraySort($aDonateButton, 0, 0, 0, 2)
			$aiDonateButton[0] = $aDonateButton[0][1]
			$aiDonateButton[1] = $aDonateButton[0][2]
		Else
			$aiDonateButton[0] = 0
			$aiDonateButton[1] = 0
			SetLog("No Donation Requests in Clan Chat", $COLOR_DEBUG2)
			$bDonate = False
		EndIf

		If $aiDonateButton[1] > 1 And $bDonate Then
			$g_bSkipDonTroops = False
			$g_bSkipDonSpells = False
			$g_bSkipDonSiege = False

			If $bDonateTroop Or $bDonateSpell Or $bDonateSiege Then
				$ClanString = ReadRequestString($aiDonateButton)
			EndIf

			getRemainingCCcapacity($aiDonateButton) ;Get remaining CC capacity of requested troops from your ClanMates

			;;; Donate Filter
			Select
				Case $g_iTotalDonateTroopCapacity <= 0
					SetLog("Clan Castle troops are full, skip troop donation", $COLOR_ACTION)
					$g_bSkipDonTroops = True
				Case $g_iCurrentSpells = 0 And $g_iCurrentSpells <> ""
					SetLog("No spells available, skip spell donation...", $COLOR_ACTION)
					$g_bSkipDonSpells = True
				Case $g_iTotalDonateSpellCapacity = 0
					SetLog("Clan Castle spells are full, skip spell donation...", $COLOR_ACTION)
					$g_bSkipDonSpells = True
				Case $g_iTotalDonateSpellCapacity = -1
					SetDebugLog("This CC cannot accept spells, skip spell donation", $COLOR_DEBUG)
					$g_bSkipDonSpells = True
				Case Not $bDonateSiege
					SetLog("Siege donation is not enabled, skip siege donation", $COLOR_ACTION)
					$g_bSkipDonSiege = True
				Case $g_iTotalDonateSiegeMachineCapacity = -1
					SetLog("This CC cannot accept Siege, skip Siege donation", $COLOR_ACTION)
					$g_bSkipDonSiege = True
				Case $g_iTotalDonateSiegeMachineCapacity = 0
					SetLog("Clan Castle Siege is full, skip Siege donation", $COLOR_ACTION)
					$g_bSkipDonSiege = True
			EndSelect

			;;; Flagged to Skip Check
			If $g_bSkipDonTroops And $g_bSkipDonSpells And $g_bSkipDonSiege Then
				$aSearchArea[1] = $aiDonateButton[1] + 20
				ContinueLoop ; go to next button
			EndIf

			;;; Open Donate Window
			If _Sleep($DELAYDONATECC2) Then Return
			If Not DonateWindow($aiDonateButton, $bOpen) Then
				SetLog("Donate Window did not open - check next", $COLOR_ERROR)
				Click(10, 10, 1, 0, "Close Donate Window")
				If _Sleep(1000) Then Return
				ContinueLoop ; Leave donate to prevent a bot hang condition
			EndIf

			;;; Typical Donation
			If $bDonateTroop Or $bDonateSpell Or $bDonateSiege Then
				SetDebugLog("Troop/Spell/Siege checkpoint.", $COLOR_DEBUG)

				; read available donate cap, and ByRef set the $g_bSkipDonTroops and $g_bSkipDonSpells flags
				DonateWindowCap($g_bSkipDonTroops, $g_bSkipDonSpells)
				If $g_bSkipDonTroops And $g_bSkipDonSpells And $g_bSkipDonSiege Then
					DonateWindow($aiDonateButton, $bClose)
					$bDonate = True
					$aSearchArea[1] = $aiDonateButton[1] + 20
					If _Sleep($DELAYDONATECC2) Then ExitLoop
					ContinueLoop ; go to next button if already donated, maybe this is an impossible case..
				EndIf

				;;;  DONATION TROOPS
				If $bDonateTroop And Not $g_bSkipDonTroops Then
					SetDebugLog("Troop checkpoint.", $COLOR_DEBUG)

					;;;  Typical Donate troops
					If Not $g_bSkipDonTroops Then
						For $i = 0 To UBound($g_aiDonateTroopPriority) - 1
							Local $iTroopIndex = $g_aiDonateTroopPriority[$i]
							If $g_abChkDonateTroop[$iTroopIndex] Then
								If CheckDonateTroop($iTroopIndex, $g_asTxtDonateTroop[$iTroopIndex], $ClanString, $g_bNewSystemToDonate) Then
									Local $iQuant = -1, $Quant = 0
									$iQuant = _ArraySearch($g_aiDonQuant, $iTroopIndex, 0, 0, 0, 0, 1, 0)
									If $iQuant <> -1 Then $Quant = $g_aiDonQuant[$iQuant][1]
									DonateTroopType($iTroopIndex, $Quant)
									If _Sleep($DELAYDONATECC3) Then ExitLoop
								EndIf
							EndIf
						Next
					EndIf
				EndIf

				;;; DONATE SIEGE
				If Not $g_bSkipDonSiege And $bDonateSiege Then
					SetDebugLog("Siege checkpoint.", $COLOR_DEBUG)
					For $SiegeIndex = $eSiegeWallWrecker To $eSiegeMachineCount - 1
						Local $index = $eTroopCount + $SiegeIndex
						If $g_abChkDonateTroop[$index] Then
							If CheckDonateSiege($SiegeIndex, $g_asTxtDonateTroop[$index], $ClanString, $g_bNewSystemToDonate) Then
								DonateSiegeType($SiegeIndex)
							EndIf
						EndIf
					Next

				EndIf

				;;; DONATION SPELLS
				If $bDonateSpell And Not $g_bSkipDonSpells Then
					SetDebugLog("Spell checkpoint.", $COLOR_DEBUG)
					For $i = 0 To UBound($g_aiDonateSpellPriority) - 1
						Local $iSpellIndex = $g_aiDonateSpellPriority[$i]
						If $g_abChkDonateSpell[$iSpellIndex] Then
							If CheckDonateSpell($iSpellIndex, $g_asTxtDonateSpell[$iSpellIndex], $ClanString, $g_bNewSystemToDonate) Then
								DonateSpellType($iSpellIndex)
								If _Sleep($DELAYDONATECC3) Then ExitLoop
							EndIf
						EndIf
					Next
				EndIf
			EndIf

			DonateWindow($aiDonateButton, $bClose)
			If _Sleep(1000) Then Return
			$aSearchArea[1] = $aiDonateButton[1] + 20
			ContinueLoop
		EndIf

		$bDonate = False ;reset after a page
		For $i = 1 To 3
			If WaitforPixel(339, 592, 340, 593, Hex(0xFFFFFF, 6), 10, 1, "DonateCC-ScrollDown") Then
				SetLog("Scroll chat Request #" & $i, $COLOR_ACTION)
				Click(335, 595, 1, 0, "Click Green Scroll Button")
				If _Sleep(1000) Then Return
				$bDonate = True
			Else
				;exit from donate loop, already check most bottom request
				If $i = 1 Then ExitLoop 2
			EndIf
		Next

		;check chat still open, if accidentally closed -> exit
		If _ColorCheck(_GetPixelColor(20, 300, True), Hex(0xF3AA28, 6), 20, Default, "DonateCC") Then
			SetLog("DonateCC: Chat closed, exit", $COLOR_ACTION)
			ExitLoop
		EndIf

		If $bDonate Then
			$aSearchArea = $aiSearchArray
			SetLog("Checking Donate after Scroll Down", $COLOR_DEBUG1)
			ContinueLoop
		EndIf
	Wend

	checkChatTabPixel()
	UpdateStats()
	If _Sleep(1000) Then Return

	If $g_bDonated And $g_iCommandStop = 3 Then
		$g_iCommandStop = 0
		$g_bFullArmy = False
	EndIf
	Return $g_bDonated
EndFunc   ;==>DonateCC

Func CheckDonateTroop(Const $iTroopIndex, Const $sDonateTroopString, Const $sClanString, $bNewSystemDonate = False)
	Local $sName = ($iTroopIndex = 99 ? "Custom" : $g_asTroopNames[$iTroopIndex])
	Return CheckDonate($sName, $bNewSystemDonate = True ? $sName : $sDonateTroopString, $sClanString)
EndFunc   ;==>CheckDonateTroop

Func CheckDonateSpell(Const $iSpellIndex, Const $sDonateSpellString, Const $sClanString, $bNewSystemDonate = False)
	Local $sName = $g_asSpellNames[$iSpellIndex]
	Return CheckDonate($sName, $bNewSystemDonate = True ? $sName : $sDonateSpellString, $sClanString)
EndFunc   ;==>CheckDonateSpell

Func CheckDonateSiege(Const $iSiegeIndex, Const $sDonateSpellString, Const $sClanString, $bNewSystemDonate = False)
	Local $sName = $g_asSiegeMachineNames[$iSiegeIndex]
	Return CheckDonate($sName, $bNewSystemDonate = True ? $sName : $sDonateSpellString, $sClanString)
EndFunc   ;==>CheckDonateSiege

Func CheckDonate(Const $sName, Const $sDonateString, Const $sClanString)
	Local $asSplitDonate = StringSplit($sDonateString, @CRLF, $STR_ENTIRESPLIT)

	For $i = 1 To UBound($asSplitDonate) - 1
		If CheckDonateString($asSplitDonate[$i], $sClanString) Then
			SetLog($sName & " Keyword found: " & $asSplitDonate[$i], $COLOR_SUCCESS)
			Return True
		EndIf
	Next

	SetDebugLog("Bad call of CheckDonateTroop: " & $sName, $COLOR_DEBUG)
	Return False
EndFunc   ;==>CheckDonate

Func CheckDonateString($String, $ClanString) ;Checks if exact
	Local $Contains = StringMid($String, 1, 1) & StringMid($String, StringLen($String), 1)

	If $Contains = "[]" Then
		If $ClanString = StringMid($String, 2, StringLen($String) - 2) Then
			Return True
		Else
			Return False
		EndIf
	Else
		If StringInStr($ClanString, $String, 2) Then
			Return True
		Else
			Return False
		EndIf
	EndIf
EndFunc   ;==>CheckDonateString

Func DonateTroopType($iTroopIndex, $Quant = 0, $bDonateQueueOnly = False)
	Local $aSlot = -1
	Local $sTextToAll = ""

	If $g_iTotalDonateTroopCapacity = 0 Then Return
	If $g_bDebugSetLog Then SetLog("DonateTroopType : " & $g_asTroopNames[$iTroopIndex], $COLOR_DEBUG)

	; Space to donate troop?
	$g_iDonTroopsQuantityAv = Floor($g_iTotalDonateTroopCapacity / $g_aiTroopSpace[$iTroopIndex])
	If $g_iDonTroopsQuantityAv < 1 Then
		SetLog("Sorry Chief! " & $g_asTroopNamesPlural[$iTroopIndex] & " don't fit in the remaining space!")
		Return
	EndIf

	If $Quant = 0 Or $Quant > _Min(Number($g_iDonTroopsQuantityAv), Number($g_iDonTroopsLimit)) Then $Quant = _Min(Number($g_iDonTroopsQuantityAv), Number($g_iDonTroopsLimit))

	$aSlot = DetectSlotTroop($iTroopIndex)
	If $aSlot = -1 Then Return

	; Verify if the type of troop to donate exists
	SetLog("Troops Condition Matched", $COLOR_ACTION)
	SetLog("Donating " & $Quant & " " & ($Quant > 1 ? $g_asTroopNamesPlural[$iTroopIndex] : $g_asTroopNames[$iTroopIndex]) & $sTextToAll, $COLOR_SUCCESS)
	If $g_bDebugSetLog Then SetLog("donate : " & $g_asTroopNames[$iTroopIndex], $COLOR_ERROR)
	If $g_bDebugSetLog Then SetLog("coordinate : " & _ArrayToString($aSLot), $COLOR_ERROR)

	ClickP($aSlot, $Quant, 200, "Donate " & $g_asTroopNames[$iTroopIndex])

	$g_aiDonateStatsTroops[$iTroopIndex][0] += $Quant

	; Adjust Values for donated troops to prevent a Double ghost donate to stats and train
	If $iTroopIndex >= $eTroopBarbarian And $iTroopIndex < $eTroopCount Then
		;Reduce iTotalDonateCapacity by troops donated
		$g_iTotalDonateTroopCapacity -= ($Quant * $g_aiTroopSpace[$iTroopIndex])
		;If donated max allowed troop qty set $g_bSkipDonTroops = True
		If $g_iDonTroopsLimit = $Quant Then
			$g_bSkipDonTroops = True
		EndIf
	EndIf

	; Assign the donated quantity troops to train : $Don $g_asTroopName
	$g_aiDonateTroops[$iTroopIndex] += $Quant
	If $bDonateQueueOnly Then $g_aiAvailQueuedTroop[$iTroopIndex] -= $Quant
	$g_bDonated = True
EndFunc   ;==>DonateTroopType

Func DonateSpellType($iSpellIndex, $Quant = 0, $bDonateQueueOnly = False)
	Local $aSlot = -1

	If $g_iTotalDonateSpellCapacity = 0 Then Return
	If $g_bDebugSetLog Then SetLog("DonateSpellType : " & $g_asSpellNames[$iSpellIndex], $COLOR_DEBUG)

	; Space to donate spell?
	$g_iDonSpellsQuantityAv = Floor($g_iTotalDonateSpellCapacity / $g_aiSpellSpace[$iSpellIndex])
	If $g_iDonSpellsQuantityAv < 1 Then
		SetLog("Sorry Chief! " & $g_asSpellNames[$iSpellIndex] & " spells don't fit in the remaining space!")
		Return
	EndIf
	
	If $Quant = 0 Or $Quant > _Min(Number($g_iDonSpellsQuantityAv), Number($iDonSpellsLimit)) Then $Quant = _Min(Number($g_iDonSpellsQuantityAv), Number($iDonSpellsLimit))

	$aSlot = DetectSlotSpell($iSpellIndex)
	If $aSlot = -1 Then Return

	SetLog("Spells Condition Matched", $COLOR_ACTION)
	If $g_bDebugSetLog Then SetLog("donate : " & $g_asSpellNames[$iSpellIndex], $COLOR_ERROR)
	If $g_bDebugSetLog Then SetLog("coordinate : " & _ArrayToString($aSLot), $COLOR_ERROR)


	ClickP($aSlot, $Quant, 200, "Donate " & $g_asSpellNames[$iSpellIndex])
	$g_aiDonateSpells[$iSpellIndex] += 1
	$g_aiDonateStatsSpells[$iSpellIndex][0] += $Quant

	SetLog("Donating " & $Quant & " " & $g_asSpellNames[$iSpellIndex] & " Spell.", $COLOR_SUCCESS)
	$g_bDonated = True
EndFunc   ;==>DonateSpellType

Func DonateSiegeType($iSiegeIndex)
	Local $aSlot = -1

	If $g_iTotalDonateSiegeMachineCapacity < 1 Then Return
	If $g_bDebugSetLog Then SetLog("DonateSiegeType : " & $g_asSiegeMachineNames[$iSiegeIndex], $COLOR_DEBUG)

	$aSlot = DetectSlotSiege($iSiegeIndex)
	If $aSlot = -1 Then Return

	SetLog("Siege Condition Matched", $COLOR_ACTION)
	If $g_bDebugSetLog Then SetLog("donate : " & $g_asSiegeMachineNames[$iSiegeIndex], $COLOR_ERROR)
	If $g_bDebugSetLog Then SetLog("coordinate : " & _ArrayToString($aSLot), $COLOR_ERROR)

	ClickP($aSlot, 1, 200, "Donate " & $g_asSiegeMachineNames[$iSiegeIndex])
	$g_aiDonateSiegeMachines[$iSiegeIndex] += 1
	$g_aiDonateStatsSieges[$iSiegeIndex][0] += 1

	SetLog("Donating 1 " & ($g_asSiegeMachineNames[$iSiegeIndex]), $COLOR_SUCCESS)
	$g_bDonated = True
EndFunc   ;==>DonateSiegeType

;DonateWindow(StringSplit("284|561", "|", $STR_NOCOUNT))
Func DonateWindow($DonateButton = -1, $bOpen = True)

	If $g_bDebugSetLog Then SetLog(($bOpen = True ? "Opening" : "Closing") & " DonateWindow", $COLOR_DEBUG)

	If Not $bOpen Then ; close window and exit
		Click(10, 10, 1, 0, "Close Donate Window")
		If _Sleep($DELAYDONATEWINDOW1) Then Return
		If $g_bDebugSetLog Then SetLog("DonateWindow Closed", $COLOR_DEBUG)
		Return
	EndIf

	Local $aiDonateButton[2] = [0, 0]
	If $DonateButton = -1 Then
		If QuickMIS("BC1", $g_sImgDonateButton, 230, 140, 350, 600) Then
			$aiDonateButton[0] = $g_iQuickMISX
			$aiDonateButton[1] = $g_iQuickMISY
		EndIf
	Else
		$aiDonateButton = $DonateButton
	EndIf

	ClickP($aiDonateButton)
	If _Sleep(500) Then Return
	$g_iDonationWindowX = 0
	$g_iDonationWindowY = 0

	For $i = 1 To 5
		If $g_bDebugSetLog Then SetLog("Waiting DonateWindow open #" & $i, $COLOR_ACTION)
		If _Sleep(200) Then Return
		Local $aDonate = QuickMIS("CNX", $g_sImgDonateWindow, 325, 0, 380, 400)
		If IsArray($aDonate) And UBound($aDonate) > 0 Then
			_ArraySort($aDonate, 0, 0, 0, 2) ;sort by y asc
			If $g_bDebugSetLog Then SetLog("DonateWindow Opened", $COLOR_DEBUG)
			$g_iDonationWindowX = $aDonate[0][1]
			$g_iDonationWindowY = $aDonate[0][2] - 22
			If $g_bDebugSetLog Then SetLog("DonationWindowX:" & $g_iDonationWindowX & ", DonationWindowY:" & $g_iDonationWindowY, $COLOR_DEBUG)
			ExitLoop
		EndIf
	Next
	Return True
EndFunc   ;==>DonateWindow

;DonateWindowCap(False, False)
Func DonateWindowCap(ByRef $g_bSkipDonTroops, ByRef $g_bSkipDonSpells)
	SetDebugLog("DonateCapWindow Start", $COLOR_DEBUG)
	Local $xTroop = $g_iDonationWindowX + 85, $xSpell = $g_iDonationWindowX + 78
	;read troops capacity
	If Not $g_bSkipDonTroops Then
		Local $sReadCCTroopsCap = getCastleDonateCap($xTroop, $g_iDonationWindowY + 15) ; use OCR to get donated/total capacity
		SetDebugLog("$sReadCCTroopsCap: " & $sReadCCTroopsCap, $COLOR_DEBUG)

		Local $aTempReadCCTroopsCap = StringSplit($sReadCCTroopsCap, "#")
		If $aTempReadCCTroopsCap[0] >= 2 Then
			;  Note - stringsplit always returns an array even if no values split!
			SetDebugLog("$aTempReadCCTroopsCap splitted :" & $aTempReadCCTroopsCap[1] & "/" & $aTempReadCCTroopsCap[2], $COLOR_DEBUG)
			If $aTempReadCCTroopsCap[2] > 0 Then
				$g_iDonTroopsAv = $aTempReadCCTroopsCap[1]
				$g_iDonTroopsLimit = $aTempReadCCTroopsCap[2]
				;SetLog("Donate Troops: " & $g_iDonTroopsAv & "/" & $g_iDonTroopsLimit)
				If $g_iDonTroopsAv = $g_iDonTroopsLimit Then $g_bSkipDonTroops = True
			EndIf
		Else
			SetLog("Error reading the Castle Troop Capacity", $COLOR_ERROR) ; log if there is read error
			$g_iDonTroopsAv = 0
			$g_iDonTroopsLimit = 0
		EndIf
	EndIf

	If Not $g_bSkipDonSpells Then
		Local $sReadCCSpellsCap = getCastleDonateCap($xSpell, $g_iDonationWindowY + 222) ; use OCR to get donated/total capacity
		SetDebugLog("$sReadCCSpellsCap: " & $sReadCCSpellsCap, $COLOR_DEBUG)
		Local $aTempReadCCSpellsCap = StringSplit($sReadCCSpellsCap, "#")
		If $aTempReadCCSpellsCap[0] >= 2 Then
			;  Note - stringsplit always returns an array even if no values split!
			SetDebugLog("$aTempReadCCSpellsCap splitted :" & $aTempReadCCSpellsCap[1] & "/" & $aTempReadCCSpellsCap[2], $COLOR_DEBUG)
			If $aTempReadCCSpellsCap[2] > 0 Then
				$g_iDonSpellsAv = $aTempReadCCSpellsCap[1]
				$iDonSpellsLimit = $aTempReadCCSpellsCap[2]
				If $g_iDonSpellsAv = $iDonSpellsLimit Then $g_bSkipDonSpells = True
			EndIf
		Else
			SetLog("Are you able to donate Spells? ", $COLOR_ERROR) ; log if there is read error
			$g_iDonSpellsAv = 0
			$iDonSpellsLimit = 0
		EndIf
	EndIf
EndFunc   ;==>DonateWindowCap

Func DetectSlotTroop($iTroopIndex = 0)
	Local $aSlot[2] = [0, 0]
	Local $sShort = "", $sName = ""
	Local $x = $g_iDonationWindowX - 12, $x1 = $x + 480
	Local $y = $g_iDonationWindowY + 35, $y1 = $y + 165
	
	If _Sleep(200) Then Return
	If $iTroopIndex > UBound($g_asTroopShortNames) Then Return -1
	$sShort = $g_asTroopShortNames[$iTroopIndex]
	$sName = $g_asTroopNames[$iTroopIndex]

	If $g_bDebugSetLog Then SetLog("DetectSlotTroop : [" & $iTroopIndex & "] " & $sName, $COLOR_DEBUG1)
	If QuickMIS("BFI", $g_sImgDonateTroops & $sShort & "*", $x, $y, $x1, $y1) Then
		$aSlot[0] = $g_iQuickMISX
		$aSlot[1] = $g_iQuickMISY
		If $g_bDebugSetLog Then SetLog($sName & " detected on [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_DEBUG)
		Return $aSlot
	Else
		SetLog("Troop Detection Failed: [" & $iTroopIndex & "] " & $sName, $COLOR_ERROR)
		If $g_bDebugSetLog Then SetLog("QuickMIS('BFI', '" & $g_sImgDonateTroops & $sShort & "*" & "'," & $x & "," & $y & "," & $x1 & "," & $y1 & ")", $COLOR_ERROR)
		Return -1
	EndIf

	Return -1

EndFunc   ;==>DetectSlotTroop

Func DetectSlotSpell($iSpellIndex = 0)
	Local $aSlot[2] = [0, 0]
	Local $sShort = "", $sName = ""
	Local $x = $g_iDonationWindowX - 12, $x1 = $x + 480
	Local $y = $g_iDonationWindowY + 245, $y1 = $y + 65

	If $iSpellIndex > UBound($g_asSpellShortNames) Then Return -1
	$sShort = $g_asSpellShortNames[$iSpellIndex]
	$sName = $g_asSpellNames[$iSpellIndex]

	If $g_bDebugSetLog Then SetLog("DetectSlotSpell : [" & $iSpellIndex & "] " & $sName, $COLOR_DEBUG1)
	If QuickMIS("BFI", $g_sImgDonateSpells & $sShort & "*", $x, $y, $x1, $y1) Then
		$aSlot[0] = $g_iQuickMISX
		$aSlot[1] = $g_iQuickMISY
		If $g_bDebugSetLog Then SetLog($sName & " Spell detected on [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_DEBUG)
		Return $aSlot
	Else
		SetLog("Spell Detection Failed: [" & $iSpellIndex & "] " & $sName, $COLOR_ERROR)
		If $g_bDebugSetLog Then SetLog("QuickMIS('BFI', '" & $g_sImgDonateSpells & $sShort & "*" & "'," & $x & "," & $y & "," & $x1 & "," & $y1 & ")", $COLOR_ERROR)
		Return -1
	EndIf

	Return -1

EndFunc   ;==>DetectSlotSpell

Func DetectSlotSiege($iSiegeIndex = 0)
	Local $aSlot[2] = [0, 0]
	Local $sShort = "", $sName = ""
	Local $x = $g_iDonationWindowX - 12, $x1 = $x + 480
	Local $y = $g_iDonationWindowY + 35, $y1 = $y + 185

	If $iSiegeIndex > UBound($g_asSiegeMachineShortNames) Then Return -1
	$sShort = $g_asSiegeMachineShortNames[$iSiegeIndex]
	$sName = $g_asSiegeMachineNames[$iSiegeIndex]

	If $g_bDebugSetLog Then SetLog("DetectSlotSiege : [" & $iSiegeIndex & "] " & $sName, $COLOR_DEBUG1)
	If QuickMIS("BFI", $g_sImgDonateSiege & $sShort & "*", $x, $y, $x1, $y1) Then
		$aSlot[0] = $g_iQuickMISX
		$aSlot[1] = $g_iQuickMISY
		If $g_bDebugSetLog Then SetLog($sName & " detected on [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_DEBUG)
		Return $aSlot
	Else
		SetLog("Siege Detection Failed: [" & $iSiegeIndex & "] " & $sName, $COLOR_ERROR)
		If $g_bDebugSetLog Then SetLog("QuickMIS('BFI', '" & $g_sImgDonateSiege & $sShort & "*" & "'," & $x & "," & $y & "," & $x1 & "," & $y1 & ")", $COLOR_ERROR)
		Return -1
	EndIf

	Return -1
EndFunc   ;==>DetectSlotSiege

Func SearchImgloc($directory = "", $x = 0, $y = 0, $x1 = 0, $y1 = 0)

	; Setup arrays, including default return values for $return
	Local $aResult[1], $aCoordArray[1][2], $aCoords, $aCoordsSplit, $aValue
	Local $Redlines = "FV"
	; Capture the screen for comparison
	_CaptureRegion2($x, $y, $x1, $y1)
	Local $res = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $directory, "str", "FV", "Int", 0, "str", $Redlines, "Int", 0, "Int", 1000)

	If $res[0] <> "" Then
		; Get the keys for the dictionary item.
		Local $aKeys = StringSplit($res[0], "|", $STR_NOCOUNT)

		; Redimension the result array to allow for the new entries
		ReDim $aResult[UBound($aKeys)]

		; Loop through the array
		For $i = 0 To UBound($aKeys) - 1
			; Get the property values
			$aResult[$i] = RetrieveImglocProperty($aKeys[$i], "objectname")
		Next
		Return $aResult
	EndIf
	Return $aResult
EndFunc   ;==>SearchImgloc

;getRemainingCCcapacity(StringSplit("284|333", "|", $STR_NOCOUNT))
Func getRemainingCCcapacity($DonateButton = -1)
	; Remaining CC capacity of requested troops from your ClanMates
	; Will return the $g_iTotalDonateTroopCapacity with that capacity for use in donation logic.

	Local $aiDonateButton[2] = [0, 0]
	If $DonateButton = -1 Then
		Local $aDonateButton = QuickMIS("CNX", $g_sImgDonateButton, 250, 130, 340, 600)
		If IsArray($aDonateButton) And UBound($aDonateButton) > 0 Then
			_ArraySort($aDonateButton, 0, 0, 0, 2)
			If $g_bDebugSetLog Then SetLog("aDonateButton : " & _ArrayToString($aDonateButton), $COLOR_DEBUG1)
			$aiDonateButton[0] = $aDonateButton[0][1]
			$aiDonateButton[1] = $aDonateButton[0][2]
		Else
			Return
		EndIf
	Else
		$aiDonateButton = $DonateButton
	EndIf

	Local $sCapTroops = "", $aTempCapTroops, $sCapSpells = -1, $aTempCapSpells, $sCapSiegeMachine = -1, $aTempCapSiegeMachine
	Local $iDonatedTroops = 0, $iDonatedSpells = 0, $iDonatedSiegeMachine = 0
	Local $iCapTroopsTotal = 0, $iCapSpellsTotal = 0, $iCapSiegeMachineTotal = 0

	$g_iTotalDonateTroopCapacity = -1
	$g_iTotalDonateSpellCapacity = -1
	$g_iTotalDonateSiegeMachineCapacity = -1

	; Skip reading unnecessary items
	Local $bDonateSpell = ($g_aiPrepDon[2] = 1 Or $g_aiPrepDon[3] = 1) And ($g_iCurrentSpells > 0 Or $g_iCurrentSpells = "")
	SetDebugLog("$g_aiPrepDon[2]: " & $g_aiPrepDon[2] & ", $g_aiPrepDon[3]: " & $g_aiPrepDon[3] & ", $g_iCurrentSpells: " & $g_iCurrentSpells & ", $bDonateSpell: " & $bDonateSpell)
	SetDebugLog("$g_aiPrepDon[4]: " & $g_aiPrepDon[4] & ", $g_aiPrepDon[5]: " & $g_aiPrepDon[5])

	SetDebugLog("getRemainingCCcapacity(" & _ArrayToString($aiDonateButton), $COLOR_DEBUG)
	Local $xTroop = 6

	Local $aDonateType = QuickMIS("CNX", $g_sImgDonateType, 25, $aiDonateButton[1] - 20, $aiDonateButton[0] - 50, $aiDonateButton[1] + 20)
	If IsArray($aDonateType) And UBound($aDonateType) > 0 Then
		If UBound($aDonateType) < 3 Then $xTroop = 30 ;cc cannot accept sieges
		If UBound($aDonateType) < 2 Then $xTroop = 35 ;cc cannot accept spell and sieges
		For $i = 0 To UBound($aDonateType) - 1
			If $aDonateType[$i][0] = "Troop" Then
				$sCapTroops = getOcrSpaceCastleDonate($aDonateType[$i][1] + $xTroop, $aiDonateButton[1] - 7)
			ElseIf $aDonateType[$i][0] = "Spell" Then
				$sCapSpells = getOcrSpaceCastleDonate($aDonateType[$i][1] + 10, $aiDonateButton[1] - 7)
			ElseIf $aDonateType[$i][0] = "Siege" Then
				$sCapSiegeMachine = getOcrSpaceCastleDonate($aDonateType[$i][1], $aiDonateButton[1] - 7)
			EndIf
		Next
	EndIf

	If $g_bDebugSetLog Then
		SetDebugLog("$sCapTroops :" & $sCapTroops, $COLOR_DEBUG)
		SetDebugLog("$sCapSpells :" & $sCapSpells, $COLOR_DEBUG)
		SetDebugLog("$sCapSiegeMachine :" & $sCapSiegeMachine, $COLOR_DEBUG)
	EndIf

	If $sCapTroops <> "" And StringInStr($sCapTroops, "#") Then
		; Splitting the XX/XX
		$aTempCapTroops = StringSplit($sCapTroops, "#")

		; Local Variables to use
		If $aTempCapTroops[0] >= 2 Then
			;  Note - stringsplit always returns an array even if no values split!
			SetDebugLog("$aTempCapTroops splitted :" & $aTempCapTroops[1] & "/" & $aTempCapTroops[2], $COLOR_DEBUG)
			If $aTempCapTroops[2] > 0 Then
				$iDonatedTroops = $aTempCapTroops[1]
				$iCapTroopsTotal = $aTempCapTroops[2]
				If $iCapTroopsTotal = 0 Then
					$iCapTroopsTotal = 30
				EndIf
				If $iCapTroopsTotal = 5 Then
					$iCapTroopsTotal = 35
				EndIf
			EndIf
		Else
			SetLog("Error reading the Castle Troop Capacity (1)", $COLOR_ERROR) ; log if there is read error
			$iDonatedTroops = 0
			$iCapTroopsTotal = 0
		EndIf
	Else
		SetLog("Error reading the Castle Troop Capacity (2)", $COLOR_ERROR) ; log if there is read error
		$iDonatedTroops = 0
		$iCapTroopsTotal = 0
	EndIf

	If $sCapSpells <> -1 Then
		If $sCapSpells <> "" Then
			; Splitting the XX/XX
			$aTempCapSpells = StringSplit($sCapSpells, "#")

			; Local Variables to use
			If $aTempCapSpells[0] >= 2 Then
				; Note - stringsplit always returns an array even if no values split!
				SetDebugLog("$aTempCapSpells splitted :" & $aTempCapSpells[1] & "/" & $aTempCapSpells[2], $COLOR_DEBUG)
				If $aTempCapSpells[2] > 0 Then
					$iDonatedSpells = $aTempCapSpells[1]
					$iCapSpellsTotal = $aTempCapSpells[2]
				EndIf
			Else
				SetLog("Error reading the Castle Spell Capacity (1)", $COLOR_ERROR) ; log if there is read error
				$iDonatedSpells = 0
				$iCapSpellsTotal = 0
			EndIf
		Else
			SetLog("Error reading the Castle Spell Capacity (2)", $COLOR_ERROR) ; log if there is read error
			$iDonatedSpells = 0
			$iCapSpellsTotal = 0
		EndIf
	EndIf


	If $sCapSiegeMachine <> -1 Then
		If $sCapSiegeMachine <> "" Then
			; Splitting the XX/XX
			$aTempCapSiegeMachine = StringSplit($sCapSiegeMachine, "#")

			; Local Variables to use
			If $aTempCapSiegeMachine[0] >= 2 Then
				; Note - stringsplit always returns an array even if no values split!
				SetDebugLog("$aTempCapSiegeMachine splitted :" & $aTempCapSiegeMachine[1] & "/" & $aTempCapSiegeMachine[2], $COLOR_DEBUG)
				If $aTempCapSiegeMachine[2] > 0 Then
					$iDonatedSiegeMachine = $aTempCapSiegeMachine[1]
					$iCapSiegeMachineTotal = $aTempCapSiegeMachine[2]
				EndIf
			Else
				SetLog("Error reading the Castle Siege Machine Capacity (1)", $COLOR_ERROR) ; log if there is read error
				$iDonatedSiegeMachine = 0
				$iCapSiegeMachineTotal = 0
			EndIf
		Else
			SetLog("Error reading the Castle Siege Machine Capacity (2)", $COLOR_ERROR) ; log if there is read error
			$iDonatedSiegeMachine = 0
			$iCapSiegeMachineTotal = 0
		EndIf
	EndIf

	; $g_iTotalDonateTroopCapacity it will be use to determinate the quantity of kind troop to donate
	$g_iTotalDonateTroopCapacity = ($iCapTroopsTotal - $iDonatedTroops)
	If $sCapSpells <> -1 Then $g_iTotalDonateSpellCapacity = ($iCapSpellsTotal - $iDonatedSpells)
	If $sCapSiegeMachine <> -1 Then $g_iTotalDonateSiegeMachineCapacity = ($iCapSiegeMachineTotal - $iDonatedSiegeMachine)

	If $g_iTotalDonateTroopCapacity < 0 Then
		SetLog("Unable to read Clan Castle Capacity!", $COLOR_ERROR)
	Else
		Local $sSpellText = $sCapSpells <> -1 ? ", Spells: " & $iDonatedSpells & "/" & $iCapSpellsTotal : ""
		Local $sSiegeMachineText = $sCapSiegeMachine <> -1 ? ", Siege Machine: " & $iDonatedSiegeMachine & "/" & $iCapSiegeMachineTotal : ""

		SetLog("Chat Troops: " & $iDonatedTroops & "/" & $iCapTroopsTotal & $sSpellText & $sSiegeMachineText)
	EndIf

EndFunc   ;==>RemainingCCcapacity

;getArmyRequest(StringSplit("284|561", "|", $STR_NOCOUNT))
Func getArmyRequest($DonateButton = -1)
	Local $aTempRequestArray, $iArmyIndex = -1, $sClanText = "", $sDebugText = ""
	$g_aiDonQuant = $g_aiZero52 ;reset array
	Local $aiDonateCoords[2] = [0, 0]
	If $DonateButton = -1 Then
		Local $aDonateButton = QuickMIS("CNX", $g_sImgDonateButton, 250, 130, 340, 600)
		If IsArray($aDonateButton) And UBound($aDonateButton) > 0 Then
			_ArraySort($aDonateButton, 0, 0, 0, 2)
			If $g_bDebugSetLog Then SetLog("aDonateButton : " & _ArrayToString($aDonateButton), $COLOR_DEBUG1)
			$aiDonateCoords[0] = $aDonateButton[0][1]
			$aiDonateCoords[1] = $aDonateButton[0][2]
		Else
			Return
		EndIf
	Else
		$aiDonateCoords = $DonateButton
	EndIf

	If $g_bDebugSetLog Then SetLog("QuickMIS('CNX', $g_sImgDonateImageRequest, 28, " & $aiDonateCoords[1] - 92 & ", " & 343 & ", " & $aiDonateCoords[1] - 40 & ")", $COLOR_DEBUG1)
	Local $aQuick = QuickMIS("CNX", $g_sImgDonateImageRequest, 28, $aiDonateCoords[1] - 92, 343, $aiDonateCoords[1] - 40)
	_ArraySort($aQuick, 0, 0, 0, 1)
	;_ArrayDisplay($aQuick)
	Local $axCoord[5] = [46, 98, 152, 205, 258]
	If Ubound($aQuick) > 0 Then
		For $i = 0 To UBound($aQuick) - 1
			If $i > 4 Then ExitLoop
			Local $iPos = 0
			For $j = 0 To Ubound($axCoord) - 1
				If Number($aQuick[$i][1]) > $axCoord[$j] Then
					$iPos = $j
					ContinueLoop
				EndIf
				If Number($aQuick[$i][1]) < $axCoord[$j] Then ExitLoop
			Next

			Local $sQuant = getOcrAndCapture("coc-singlereq", $axCoord[$iPos], $aiDonateCoords[1] - 88, 15, 15, True)
			$iArmyIndex = TroopIndexLookup($aQuick[$i][0])
			; Troops
			If $iArmyIndex >= $eBarb And $iArmyIndex <= $eAppWard Then
				$sClanText &= ", " & $g_asTroopNames[$iArmyIndex]
				$sDebugText &= ", " & $g_asTroopNames[$iArmyIndex] & ":" & (Number($sQuant) > 0 ? $sQuant : 1)
			; Spells
			ElseIf $iArmyIndex >= $eLSpell And $iArmyIndex <= $eOgSpell Then
				$sClanText &= ", " & $g_asSpellNames[$iArmyIndex - $eLSpell]
			    $sDebugText &= ", " & $g_asSpellNames[$iArmyIndex - $eLSpell] & ":" & (Number($sQuant) > 0 ? $sQuant : 1)
			; Sieges
			ElseIf $iArmyIndex >= $eWallW And $iArmyIndex <= $eBattleD Then
				$sClanText &= ", " & $g_asSiegeMachineNames[$iArmyIndex - $eWallW]
				$sDebugText &= ", " & $g_asSiegeMachineNames[$iArmyIndex - $eWallW] & ":" & (Number($sQuant) > 0 ? $sQuant : 1)
			ElseIf $iArmyIndex = -1 Then
				ContinueLoop
			EndIf
			$g_aiDonQuant[$i][0] = $iArmyIndex
			$g_aiDonQuant[$i][1] = (Number($sQuant) > 0 ? $sQuant : 1)
		Next
		SetLog("[Request] " & StringTrimLeft($sDebugText, 2), $COLOR_ACTION)
	Else
		DebugQuickMISCNX()
	EndIf
	Return StringTrimLeft($sClanText, 2)
EndFunc   ;==>getArmyRequest

;ReadRequestString(StringSplit("284|237", "|", $STR_NOCOUNT))
Func ReadRequestString($DonateButton = -1)
	Local $aiDonateButton[2] = [0, 0]
	If $DonateButton = -1 Then
		Local $aDonateButton = QuickMIS("CNX", $g_sImgDonateButton, 250, 130, 340, 600)
		If IsArray($aDonateButton) And UBound($aDonateButton) > 0 Then
			_ArraySort($aDonateButton, 0, 0, 0, 2)
			If $g_bDebugSetLog Then SetLog("aDonateButton : " & _ArrayToString($aDonateButton), $COLOR_DEBUG1)
			$aiDonateButton[0] = $aDonateButton[0][1]
			$aiDonateButton[1] = $aDonateButton[0][2]
		Else
			Return
		EndIf
	Else
		$aiDonateButton = $DonateButton
	EndIf

	Local $sString = ""
	$g_bNewSystemToDonate = False
	$sString = getArmyRequest($aiDonateButton)

	If $sString <> "" Then
		SetLog("Request: " & $sString, $COLOR_INFO)
		$g_bNewSystemToDonate = True
		Return $sString
	Else
		Local $Alphabets[4] = [$g_bChkExtraAlphabets, $g_bChkExtraChinese, $g_bChkExtraKorean, $g_bChkExtraPersian]
		Local $TextAlphabetsNames[4] = ["Cyrillic and Latin", "Chinese", "Korean", "Persian"]
		Local $AlphabetFunctions[4] = ["getChatString", "getChatStringChinese", "getChatStringKorean", "getChatStringPersian"]
		Local $BlankSpaces = ""
		For $i = 0 To UBound($Alphabets) - 1
			If $i = 0 Then
				; Line 3 to 1
				Local $aCoordinates[3] = [82, 65, 48] ; Extra coordinates for Latin (3 Lines)
				Local $OcrName = ($Alphabets[$i] = True) ? ("coc-latin-cyr") : ("coc-latinA")
				Local $log = "Latin"
				If $Alphabets[$i] Then $log = $TextAlphabetsNames[$i]
				$sString = ""
				SetLog("Using OCR to read " & $log & " derived alphabets.", $COLOR_ACTION)
				For $j = 0 To 2 ;only read 2 line
					$sString &= $BlankSpaces & getChatString(24, $aiDonateButton[1] - $aCoordinates[$j], $OcrName)
					SetDebugLog("$OcrName: " & $OcrName)
					SetDebugLog("$YCoordinates: " & $aiDonateButton[1] - $aCoordinates[$j])
					SetDebugLog("$sString: " & $sString)
					If $sString <> "" Then $BlankSpaces = " "
				Next
			Else
				Local $Yaxis[3] = [82, 65, 48] ; "Chinese", "Korean", "Persian"
				If $Alphabets[$i] Then
					If $sString = "" Or $sString = " " Then
						SetLog("Using OCR to read " & $TextAlphabetsNames[$i] & " alphabets.", $COLOR_ACTION)
						; Ensure used functions are references in "MBR References.au3"
						#Au3Stripper_Off
						$sString &= $BlankSpaces & Call($AlphabetFunctions[$i], 24, $aiDonateButton[1] - $Yaxis[$i - 1])
						#Au3Stripper_On
						If @error = 0xDEAD And @extended = 0xBEEF Then SetLog("[DonatCC] Function " & $AlphabetFunctions[$i] & "() had a problem.")
						SetDebugLog("$OcrName: " & $OcrName)
						SetDebugLog("$Yaxis: " & $Yaxis[$i - 1])
						SetDebugLog("$sString: " & $sString)
						If $sString <> "" And $sString <> " " Then ExitLoop
					EndIf
				EndIf
			EndIf
		Next
		;SetDebugLog("Get Request OCR in " & StringFormat("%.2f", TimerDiff($iTimer)) & "'ms", $COLOR_DEBUG)
		SetLog("Request: " & $sString, $COLOR_INFO)
		Return $sString
	EndIf
EndFunc
