; #FUNCTION# ====================================================================================================================
; Name ..........: Train Revamp Oct 2016
; Description ...:
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Mr.Viper(10-2016), ProMac(10-2016), CodeSlinger69 (01-2018)
; Modified ......: ProMac (11-2016), Boju (11-2016), MR.ViPER (12-2016), CodeSlinger69 (01-2018)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once
#include <Array.au3>
#include <MsgBoxConstants.au3>

Func TrainSystem($bSkipCheckArmy = False)
	If Not $g_bTrainEnabled Then ; check for training disabled in halt mode
		If $g_bDebugSetlogTrain Then SetLog("Halt mode - training disabled", $COLOR_DEBUG)
		Return
	EndIf
	
	If Not $g_bRunState Then Return
	$g_sTimeBeforeTrain = _NowCalc()
	StartGainCost()
	SetLog("====== TrainSystem =====", $COLOR_ACTION)
	If Not $g_bRunState Then Return
	BoostSuperTroop()
	;Add small delay after boost
	If _Sleep(1000) Then Return
	If Not $g_bRunState Then Return
	
	OpenArmyOverview("TrainSystem")
	If Not IsTrainPage(False) Then 
		SetLog("Cannot verify Army Window, exit train!", $COLOR_ERROR)
		Return
	EndIf
	
	If Not $bSkipCheckArmy Then 
		CheckIfArmyIsReady()
	Else
		RequestCC(False, "IsFullClanCastle")
	EndIf
	
	If Not $g_bRunState Then Return
	TrainCustomArmy()
	If Not $g_bRunState Then Return
	TrainSiege()

	If $g_bDonationEnabled And $g_bChkDonate Then ResetVariables("donated")

	ClickAway()
	If _Sleep(1000) Then Return ; Delay AFTER the click Away Prevents lots of coc restarts

	EndGainCost("Train")

	;checkAttackDisable($g_iTaBChkIdle) ; Check for Take-A-Break after opening train page
EndFunc   ;==>TrainSystem

Func TrainPreviousArmy($bCloseWindow = False, $bOnlyBoost = False)
	If Not OpenQuickTrainTab(False, "TrainPreviousArmy()") Then Return
	If _Sleep(750) Then Return
	For $i = 1 To 2
		If _ColorCheck(_GetPixelColor(730, 232, True), Hex(0x8BD43A, 6), 10) Then ;check Train Previous Button
			PureClick(730, 232)
			SetLog("Training Previous Army", $COLOR_SUCCESS)
			If _Sleep(1000) Then Return
			If IsOKCancelPage() Then
				If _ColorCheck(_GetPixelColor(642, 232, True), Hex(0xFFFFFF, 6), 1) Then ;check popup window (boost or not enough room)
					SetLog("[" & $i & "] SuperTroop Boost Needed", $COLOR_INFO)
					Click(530, 420, 1, "Click Okay, Confirm Boost")
					If _Sleep(1000) Then Return
					If WaitforPixel(582, 555, 640, 556, "FF887F", 10, 1) Then ;red color on DE cost
						Click(465, 545, 1, "Click Boost with SuperTroop potion")
						If _Sleep(1000) Then Return
						If QuickMIS("BC1", $g_sImgBoostTroopsPotion, 450, 444, 485, 480) Then
							Click($g_iQuickMISX, $g_iQuickMISY)
							SetLog("Successfully boost with potion", $COLOR_SUCCESS)
							If _Sleep(1000) Then Return
							If $bOnlyBoost Then ExitLoop
							If Not OpenArmyOverview("TrainPreviousArmy") Then Return
							If Not OpenQuickTrainTab(True, "TrainPreviousArmy") Then Return
						Else
							SetLog("Cannot find potion boost button", $COLOR_ERROR)
							ClickAway()
							ClickAway()
							Return
						EndIf
					Else
						Click(630, 545, 1, "Click Boost with Dark Elixer")
						If _Sleep(1000) Then Return
						If QuickMis("BC1", $g_sImgGeneralCloseButton, 624, 139, 678, 187) Then 
							Click($g_iQuickMISX - 230, $g_iQuickMISY + 300)
							SetLog("Successfully boost with Dark Elixer", $COLOR_SUCCESS)
							If _Sleep(1000) Then Return
							If $bOnlyBoost Then ExitLoop
							If Not OpenArmyOverview("TrainPreviousArmy") Then Return
							If Not OpenQuickTrainTab(True, "TrainPreviousArmy") Then Return
						EndIf
					EndIf					
				Else ;not a boost window
					SetLog("[" & $i & "] Not Enough room to train", $COLOR_INFO)
					Click(530, 420, 1, "Click Okay, Confirm Training")
					If _Sleep(500) Then Return
					ExitLoop
				EndIf
			EndIf
			If _ColorCheck(_GetPixelColor(730, 232, True), Hex(0xADADAD, 6), 10) Then ExitLoop ;check Greyed Train Previous Button
		Else
			SetLog("Button Train Not Found, Skip Train Previous Army", $COLOR_DEBUG)
		EndIf
	Next
	
	If $bOnlyBoost Then 
		If Not OpenArmyOverview("OnlyBoost") Then Return
		If Not OpenTroopsTab(True, "OnlyBoost") Then Return
		If _Sleep(500) Then Return
	EndIf
	
	If $bCloseWindow Then ClickAway()
EndFunc ;==>TrainPreviousArmy

Func TrainCustomArmy()
	If Not $g_bRunState Then Return
	If IsProblemAffect() Then Return
	SetLog(" ====== CustomTrain ====== ", $COLOR_ACTION)

	If $g_iActiveDonate = -1 Then PrepareDonateCC()
	
	If $g_bTrainPreviousArmy Then TrainPreviousArmy()
	
	If $g_bDoubleTrain Then
		DoubleTrain()
		Return
	EndIf

	If Not $g_bRunState Then Return

	If Not $g_bFullArmy Then
		Local $rWhatToTrain = WhatToTrain(True) ; r in First means Result! Result of What To Train Function
		RemoveExtraTroops($rWhatToTrain)
	EndIf

	If _Sleep($DELAYRESPOND) Then Return ; add 5ms delay to catch TrainIt errors, and force return to back to main loop

	Local $bEmptyTroopQueue = IsQueueEmpty("Troops")
	Local $bEmptySpellQueue = IsQueueEmpty("Spells")

	If $bEmptyTroopQueue Or $bEmptySpellQueue Then
		If Not $g_bRunState Then Return
		If Not OpenArmyTab(False, "TrainCustomArmy()") Then Return
		Local $rWhatToTrain = WhatToTrain()
		If IsProblemAffect() Then Return
		If $bEmptyTroopQueue And DoWhatToTrainContainTroop($rWhatToTrain) Then TrainUsingWhatToTrain($rWhatToTrain)
		If $bEmptySpellQueue And DoWhatToTrainContainSpell($rWhatToTrain) Then BrewUsingWhatToTrain($rWhatToTrain)
	EndIf

	If _Sleep(250) Then Return
	If Not $g_bRunState Then Return
EndFunc   ;==>TrainCustomArmy

Func CheckIfArmyIsReady($bCloseWindow = False)

	If Not $g_bRunState Then Return

	Local $bFullArmyCC = False
	Local $iTotalSpellsToBrew = 0
	Local $bFullArmyHero = False
	Local $bFullSiege = False
	$g_bWaitForCCTroopSpell = False ; reset for waiting CC in SwitchAcc
	
	If Not OpenArmyOverview("CheckIfArmyIsReady()") Then Return
	
	CheckArmyCamp(True, False, True, True)
	CheckCCArmy()
	RequestCC(False, "IsFullClanCastle")

	If $g_bDebugSetlogTrain Then
		SetLog(" - $g_CurrentCampUtilization : " & $g_CurrentCampUtilization)
		SetLog(" - $g_iTotalCampSpace : " & $g_iTotalCampSpace)
		SetLog(" - $g_bFullArmy : " & $g_bFullArmy)
		SetLog(" - $g_bPreciseArmy : " & $g_bPreciseArmy)
	EndIf

	$g_bFullArmySpells = False
	; Local Variable to check the occupied space by the Spells to Brew ... can be different of the Spells Factory Capacity ( $g_iTotalSpellValue )
	For $i = 0 To $eSpellCount - 1
		$iTotalSpellsToBrew += $g_aiArmyCompSpells[$i] * $g_aiSpellSpace[$i]
	Next

	If Number($g_iCurrentSpells) >= Number($g_iTotalSpellValue) Or Number($g_iCurrentSpells) >= Number($iTotalSpellsToBrew) Then $g_bFullArmySpells = True

	If (Not $g_bFullArmy And Not $g_bFullArmySpells) Or $g_bPreciseArmy Then
		Local $avWrongTroops = WhatToTrain(True)
		Local $rRemoveExtraTroops = RemoveExtraTroops($avWrongTroops)
		If $rRemoveExtraTroops = 1 Or $rRemoveExtraTroops = 2 Then
			CheckArmyCamp(False, False, False, False)
			$g_bFullArmySpells = Number($g_iCurrentSpells) >= Number($g_iTotalSpellValue) Or Number($g_iCurrentSpells) >= Number($iTotalSpellsToBrew)
		EndIf
	EndIf

	$g_bCheckSpells = CheckSpells()

	; add to the hereos available, the ones upgrading so that it ignores them... we need this logic or the bitwise math does not work out correctly
	$g_iHeroAvailable = BitOR($g_iHeroAvailable, $g_iHeroUpgradingBit)
	$bFullArmyHero = (BitAND($g_aiSearchHeroWaitEnable[$DB], $g_iHeroAvailable) = $g_aiSearchHeroWaitEnable[$DB] And $g_abAttackTypeEnable[$DB]) Or _
			(BitAND($g_aiSearchHeroWaitEnable[$LB], $g_iHeroAvailable) = $g_aiSearchHeroWaitEnable[$LB] And $g_abAttackTypeEnable[$LB]) Or _
			($g_aiSearchHeroWaitEnable[$DB] = $eHeroNone And $g_aiSearchHeroWaitEnable[$LB] = $eHeroNone)

	If $g_bDebugSetlogTrain Then
		Setlog("Heroes are Ready: " & String($bFullArmyHero))
		Setlog("Heroes Available Num: " & $g_iHeroAvailable) ;  	$eHeroNone = 0, $eHeroKing = 1, $eHeroQueen = 2, $eHeroWarden = 4, $eHeroChampion = 8
		Setlog("Search Hero Wait Enable [$DB] Num: " & $g_aiSearchHeroWaitEnable[$DB]) ; 	what you are waiting for : 1 is King , 3 is King + Queen , etc etc
		Setlog("Search Hero Wait Enable [$LB] Num: " & $g_aiSearchHeroWaitEnable[$LB])
		Setlog("Dead Base BitAND: " & BitAND($g_aiSearchHeroWaitEnable[$DB], $g_iHeroAvailable))
		Setlog("Live Base BitAND: " & BitAND($g_aiSearchHeroWaitEnable[$LB], $g_iHeroAvailable))
		Setlog("Are you 'not' waiting for Heroes: " & String($g_aiSearchHeroWaitEnable[$DB] = $eHeroNone And $g_aiSearchHeroWaitEnable[$LB] = $eHeroNone))
		Setlog("Is Wait for Heroes Active : " & IsWaitforHeroesActive())
	EndIf

	$bFullArmyCC = IsFullClanCastle()
	$bFullSiege = CheckSiegeMachine()

	; If Drop Trophy with Heroes is checked and a Hero is Available or under the trophies range, then set $g_bFullArmyHero to True
	If Not IsWaitforHeroesActive() And $g_bDropTrophyUseHeroes Then $bFullArmyHero = True
	If Not IsWaitforHeroesActive() And Not $g_bDropTrophyUseHeroes And Not $bFullArmyHero Then
		If $g_iHeroAvailable > 0 Or Number($g_aiCurrentLoot[$eLootTrophy]) <= Number($g_iDropTrophyMax) Then
			$bFullArmyHero = True
		Else
			SetLog("Waiting for Heroes to drop trophies!", $COLOR_ACTION)
		EndIf
	EndIf

	If $g_bFullArmy And $g_bCheckSpells And $bFullArmyHero And $bFullArmyCC And $bFullSiege Then
		$g_bIsFullArmywithHeroesAndSpells = True
	Else
		If $g_bDebugSetlog Then
			SetDebugLog(" $g_bFullArmy: " & String($g_bFullArmy), $COLOR_DEBUG)
			SetDebugLog(" $g_bCheckSpells: " & String($g_bCheckSpells), $COLOR_DEBUG)
			SetDebugLog(" $bFullArmyHero: " & String($bFullArmyHero), $COLOR_DEBUG)
			SetDebugLog(" $bFullSiege: " & String($bFullSiege), $COLOR_DEBUG)
			SetDebugLog(" $bFullArmyCC: " & String($bFullArmyCC), $COLOR_DEBUG)
		EndIf
		$g_bIsFullArmywithHeroesAndSpells = False
	EndIf
	If $g_bFullArmy And $g_bCheckSpells And $bFullArmyHero Then ; Force Switch while waiting for CC in SwitchAcc
		If Not $bFullArmyCC Then $g_bWaitForCCTroopSpell = True
	EndIf

	Local $sLogText = ""
	If Not $g_bFullArmy Then $sLogText &= " Troops,"
	If Not $g_bCheckSpells Then $sLogText &= " Spells,"
	If Not $bFullArmyHero Then $sLogText &= " Heroes,"
	If Not $bFullSiege Then $sLogText &= " Siege Machine,"
	If Not $bFullArmyCC Then $sLogText &= " Clan Castle,"
	If StringRight($sLogText, 1) = "," Then $sLogText = StringTrimRight($sLogText, 1) ; Remove last "," as it is not needed

	If $g_bIsFullArmywithHeroesAndSpells Then
		If $g_bNotifyTGEnable And $g_bNotifyAlertCampFull Then PushMsg("CampFull")
		SetLog("Chief, is your Army ready? Yes, it is!", $COLOR_SUCCESS)
	Else
		SetLog("Chief, is your Army ready? No, not yet!", $COLOR_ACTION)
		If $sLogText <> "" Then SetLog(@TAB & "Waiting for " & $sLogText, $COLOR_ACTION)
	EndIf

	; Force to Request CC troops or Spells
	If Not $bFullArmyCC Then $g_bCanRequestCC = True
	If $g_bDebugSetlog Then
		SetDebugLog(" $g_bFullArmy: " & String($g_bFullArmy), $COLOR_DEBUG)
		SetDebugLog(" $bCheckCC: " & String($bFullArmyCC), $COLOR_DEBUG)
		SetDebugLog(" $g_bIsFullArmywithHeroesAndSpells: " & String($g_bIsFullArmywithHeroesAndSpells), $COLOR_DEBUG)
		SetDebugLog(" $g_iTownHallLevel: " & Number($g_iTownHallLevel), $COLOR_DEBUG)
	EndIf
	
	If $bCloseWindow Then 
		ClickAway()
		If _Sleep(1000) Then Return
	EndIf
EndFunc   ;==>CheckIfArmyIsReady

Func CheckSpells()
	If Not $g_bRunState Then Return

	Local $bToReturn = False

	If (Not $g_abSearchSpellsWaitEnable[$DB] And Not $g_abSearchSpellsWaitEnable[$LB]) Or ($g_bFullArmySpells And ($g_abSearchSpellsWaitEnable[$DB] Or $g_abSearchSpellsWaitEnable[$LB])) Then
		Return True
	EndIf

	If (($g_abAttackTypeEnable[$DB] And $g_abSearchSpellsWaitEnable[$DB]) Or ($g_abAttackTypeEnable[$LB] And $g_abSearchSpellsWaitEnable[$LB])) And $g_iTownHallLevel >= 5 Then
		$bToReturn = $g_bFullArmySpells
	Else
		$bToReturn = True
	EndIf

	Return $bToReturn
EndFunc   ;==>CheckSpells

Func CheckSiegeMachine()

	If Not $g_bRunState Then Return

	Local $bToReturn = True

	If IsWaitforSiegeMachine() Then
		For $i = $eSiegeWallWrecker To $eSiegeMachineCount - 1
			If $g_aiCurrentSiegeMachines[$i] < $g_aiArmyCompSiegeMachines[$i] Then $bToReturn = False
			If $g_bDebugSetlogTrain Then
				SetLog("$g_aiCurrentSiegeMachines[" & $g_asSiegeMachineNames[$i] & "]: " & $g_aiCurrentSiegeMachines[$i])
				SetLog("$g_aiArmyCompSiegeMachine[" & $g_asSiegeMachineNames[$i] & "]: " & $g_aiArmyCompSiegeMachines[$i])
			EndIf
		Next
	Else
		$bToReturn = True
	EndIf

	Return $bToReturn
EndFunc   ;==>CheckSiegeMachine

Func TrainUsingWhatToTrain($rWTT, $bQueue = $g_bIsFullArmywithHeroesAndSpells)
	If Not $g_bRunState Then Return

	If UBound($rWTT) = 1 And $rWTT[0][0] = "Arch" And $rWTT[0][1] = 0 Then Return True ; If was default Result of WhatToTrain

	If Not OpenTroopsTab(False, "TrainUsingWhatToTrain()") Then Return
	
	; Loop through needed troops to Train
	For $i = 0 To (UBound($rWTT) - 1)
		If Not $g_bRunState Then Return
		If $rWTT[$i][1] > 0 Then ; If Count to Train Was Higher Than ZERO
			If IsProblemAffect() Then Return
			If IsSpellToBrew($rWTT[$i][0]) Then ContinueLoop
			Local $iTroopIndex = TroopIndexLookup($rWTT[$i][0], "TrainUsingWhatToTrain()")

			If $iTroopIndex >= $eBarb And $iTroopIndex <= $eIWiza Then
				Local $NeededSpace = $g_aiTroopSpace[$iTroopIndex] * $rWTT[$i][1]
			EndIf

			Local $aLeftSpace = GetOCRCurrent(95, 163)
			Local $LeftSpace = $bQueue ? ($aLeftSpace[1] * 2) - $aLeftSpace[0] : $aLeftSpace[2]
			If $g_bIgnoreIncorrectTroopCombo And $g_bDoubleTrain And $bQueue Then
				$LeftSpace = $aLeftSpace[0]
			EndIf

			If $NeededSpace > $LeftSpace Then
				If $iTroopIndex >= $eBarb And $iTroopIndex <= $eIWiza Then
					$rWTT[$i][1] = Int($LeftSpace / $g_aiTroopSpace[$iTroopIndex])
				EndIf
			EndIf

			If $rWTT[$i][1] > 0 Then
				If Not DragIfNeeded($rWTT[$i][0]) Then Return False

				If $iTroopIndex >= $eBarb And $iTroopIndex <= $eIWiza Then
					Local $sTroopName = ($rWTT[$i][1] > 1 ? $g_asTroopNamesPlural[$iTroopIndex] : $g_asTroopNames[$iTroopIndex])
				EndIf

				SetLog("Training " & $rWTT[$i][1] & "x " & $sTroopName, $COLOR_SUCCESS)
				TrainIt($iTroopIndex, $rWTT[$i][1], $g_iTrainClickDelay)
				If _Sleep(500) Then Return
			EndIf
		EndIf
		If _Sleep($DELAYRESPOND) Then Return ; add 5ms delay to catch TrainIt errors, and force return to back to main loop
	Next

	Return True
EndFunc   ;==>TrainUsingWhatToTrain

;BrewUsingWhatToTrain(WhatToTrain())
Func BrewUsingWhatToTrain($rWTT, $bQueue = $g_bIsFullArmywithHeroesAndSpells)
	If Not $g_bRunState Then Return

	If UBound($rWTT) = 1 And $rWTT[0][0] = "Arch" And $rWTT[0][1] = 0 Then Return True ; If was default Result of WhatToTrain

	If Not OpenSpellsTab(True, "BrewUsingWhatToTrain()") Then Return

	; Loop through needed troops to Train
	For $i = 0 To (UBound($rWTT) - 1)
		If Not $g_bRunState Then Return
		If $rWTT[$i][1] > 0 Then ; If Count to Train Was Higher Than ZERO
			If IsProblemAffect() Then Return
			If Not IsSpellToBrew($rWTT[$i][0]) Then ContinueLoop
			Local $iSpellIndex = TroopIndexLookup($rWTT[$i][0], "BrewUsingWhatToTrain")
			Local $NeededSpace = $g_aiSpellSpace[$iSpellIndex - $eLSpell] * $rWTT[$i][1]

			Local $aLeftSpace = GetCurrentSpell(95, 163)
			Local $LeftSpace = $bQueue ? ($aLeftSpace[1] * 2) - $aLeftSpace[0] : $aLeftSpace[2]

			If $NeededSpace > $LeftSpace Then $rWTT[$i][1] = Int($LeftSpace / $g_aiSpellSpace[$iSpellIndex - $eLSpell])
			If $rWTT[$i][1] > 0 Then
				Local $sSpellName = $g_asSpellNames[$iSpellIndex - $eLSpell]
				SetLog("Brewing " & $rWTT[$i][1] & "x " & $sSpellName & ($rWTT[$i][1] > 1 ? " Spells" : " Spell"), $COLOR_SUCCESS)
				TrainIt($iSpellIndex, $rWTT[$i][1], $g_iTrainClickDelay)
			EndIf
		EndIf
		If _Sleep($DELAYRESPOND) Then Return ; add 5ms delay to catch TrainIt errors, and force return to back to main loop
	Next
EndFunc   ;==>BrewUsingWhatToTrain

Func TotalSpellsToBrewInGUI()
	Local $iTotalSpellsInGUI = 0
	If $g_iTotalSpellValue = 0 Then Return $iTotalSpellsInGUI
	If Not $g_bRunState Then Return
	For $i = 0 To $eSpellCount - 1
		$iTotalSpellsInGUI += $g_aiArmyCompSpells[$i] * $g_aiSpellSpace[$i]
	Next
	Return $iTotalSpellsInGUI
EndFunc   ;==>TotalSpellsToBrewInGUI

Func DragIfNeeded($Troop)

	If Not $g_bRunState Then Return
	Local $bCheckPixel = False
	Local $iIndex = TroopIndexLookup($Troop, "DragIfNeeded")
	Local $bDragLeft = False, $bDragRight = False
	
	If QuickMIS("BFI", $g_sImgTrainTroops & $Troop & "*", 70, 350, 780, 500) Then Return True ; Troop image found in current page (no need to drag)
	
	If _PixelSearch(777, 354, 778, 355, Hex(0xD3D3CB, 6), 10, True, "DragIfNeeded") Then
		For $i = 1 To 2
			SetLog("[" & $i & "] DragIfNeeded [" & $iIndex & "] " & $g_asTroopNames[$iIndex] & " : Scroll Left", $COLOR_ACTION)
			ClickDrag(100, 435, 850, 435)
			$bDragLeft = True
			If _Sleep(1500) Then Return
			If QuickMIS("BFI", $g_sImgTrainTroops & $Troop & "*", 70, 350, 780, 500) Then Return True
		Next
	EndIf
	
	If _PixelSearch(75, 354, 76, 355, Hex(0xD3D3CB, 6), 10, True, "DragIfNeeded") Then
		For $i = 1 To 2
			SetLog("[" & $i & "] DragIfNeeded [" & $iIndex & "] " & $g_asTroopNames[$iIndex] & " : Scroll Right", $COLOR_ACTION)
			ClickDrag(750, 435, 50, 435)
			$bDragRight = True
			If _Sleep(1500) Then Return
			If QuickMIS("BFI", $g_sImgTrainTroops & $Troop & "*", 70, 350, 780, 500) Then Return True
		Next
	EndIf
	
	If Not $bDragLeft And Not $bDragRight Then
		For $i = 1 To 4
			If $i < 3 Then 
				SetLog("[" & $i & "] DragIfNeeded [" & $iIndex & "] " & $g_asTroopNames[$iIndex] & " : Scroll Left", $COLOR_ACTION)
				ClickDrag(100, 435, 850, 435)
			Else
				SetLog("[" & $i & "] DragIfNeeded [" & $iIndex & "] " & $g_asTroopNames[$iIndex] & " : Scroll Right", $COLOR_ACTION)
				ClickDrag(750, 435, 50, 435)
			EndIf
			If _Sleep(1500) Then Return
			If QuickMIS("BFI", $g_sImgTrainTroops & $Troop & "*", 70, 350, 780, 500) Then Return True
		Next
	EndIf
	
	SetLog("Failed to Verify Troop " & $g_asTroopNames[TroopIndexLookup($Troop, "DragIfNeeded")] & " Position or Failed to Drag Successfully", $COLOR_ERROR)
	Return False
EndFunc   ;==>DragIfNeeded

Func DoWhatToTrainContainTroop($rWTT)
	If UBound($rWTT) = 1 And $rWTT[0][0] = "Arch" And $rWTT[0][1] = 0 Then Return False ; If was default Result of WhatToTrain
	For $i = 0 To (UBound($rWTT) - 1)
		If (IsElixirTroop($rWTT[$i][0]) Or IsDarkTroop($rWTT[$i][0])) And $rWTT[$i][1] > 0 Then Return True
	Next
	Return False
EndFunc   ;==>DoWhatToTrainContainTroop

Func DoWhatToTrainContainSpell($rWTT)
	For $i = 0 To (UBound($rWTT) - 1)
		If Not $g_bRunState Then Return
		If IsSpellToBrew($rWTT[$i][0]) Then
			If $rWTT[$i][1] > 0 Then Return True
		EndIf
	Next
	Return False
EndFunc   ;==>DoWhatToTrainContainSpell

Func IsElixirTroop($Troop)
	Local $iIndex = TroopIndexLookup($Troop, "IsElixirTroop")
	If $iIndex >= $eBarb And $iIndex <= $eRDrag Then Return True
	Return False
EndFunc   ;==>IsElixirTroop

Func IsDarkTroop($Troop)
	Local $iIndex = TroopIndexLookup($Troop, "IsDarkTroop")
	If $iIndex >= $eMini And $iIndex <= $eAppWard Then Return True
	Return False
EndFunc   ;==>IsDarkTroop

Func IsElixirSpell($Spell)
	Local $iIndex = TroopIndexLookup($Spell, "IsElixirSpell")
	If $iIndex >= $eLSpell And $iIndex <= $eReSpell Then Return True
	Return False
EndFunc   ;==>IsElixirSpell

Func IsDarkSpell($Spell)
	Local $iIndex = TroopIndexLookup($Spell, "IsDarkSpell")
	If $iIndex >= $ePSpell And $iIndex <= $eOgSpell Then Return True
	Return False
EndFunc   ;==>IsDarkSpell

Func IsSpellToBrew($sName)
	Local $iIndex = TroopIndexLookup($sName, "IsSpellToBrew")
	If $iIndex >= $eLSpell And $iIndex <= $eOgSpell Then Return True
	Return False
EndFunc   ;==>IsSpellToBrew

;RemoveExtraTroops(WhatToTrain(True))
Func RemoveExtraTroops($toRemove)
	Local $CounterToRemove = 0, $iResult = 0, $iIndex, $aRemovePos[2], $bIsSpell = False
	; Army Window should be open and should be in Tab 'Army tab'
	; 1 Means Removed Troops without Deleting Troops Queued
	; 2 Means Removed Troops And Also Deleted Troops Queued
	; 3 Means Didn't removed troop... Everything was well
	
	If UBound($toRemove) = 1 And $toRemove[0][0] = "Arch" And $toRemove[0][1] = 0 Then Return 3

	If ($g_iCommandStop = 3 Or $g_iCommandStop = 0) And Not $g_iActiveDonate Then Return 3
	
	If ($g_bIgnoreIncorrectTroopCombo Or $g_bIgnoreIncorrectSpellCombo) And Not $g_bPreciseArmy Then Return 3
	
	If UBound($toRemove) > 0 Then ; If needed to remove troops
		
		; Check if Troops to remove are already in Train Tab Queue!! If was, Will Delete All Troops Queued Then Check Everything Again...
		If DoWhatToTrainContainTroop($toRemove) And Not IsQueueEmpty("Troops") Then
			SetLog("Clear troop queue before removing unexpected troops in army", $COLOR_INFO)
			If Not OpenTroopsTab(True, "RemoveExtraTroops") Then Return
			RemoveTrainTroop()
		EndIf
		
		If DoWhatToTrainContainSpell($toRemove) And Not IsQueueEmpty("Spells") Then
			SetLog("Clear spell queue before removing unexpected spells in army", $COLOR_INFO)
			If Not OpenSpellsTab(True, "RemoveExtraTroops") Then Return
			RemoveTrainSpell()
		EndIf

		$toRemove = WhatToTrain(True) ; Check Everything Again...
		If UBound($toRemove) = 1 And $toRemove[0][0] = "Arch" And $toRemove[0][1] = 0 Then Return 2
		
		;SetLog("Troops To Remove: ", $COLOR_INFO)
		;$CounterToRemove = 0
		;; Loop through Troops needed to get removed Just to write some Logs
		;For $i = 0 To (UBound($toRemove) - 1)
		;	If IsSpellToBrew($toRemove[$i][0]) Then ExitLoop
		;	$CounterToRemove += 1
		;	SetLog(" - " & $g_asTroopNames[TroopIndexLookup($toRemove[$i][0])] & ": " & $toRemove[$i][1] & "x", $COLOR_SUCCESS)
		;Next
		;
		;If $CounterToRemove <= UBound($toRemove) Then
		;	SetLog("Spells To Remove: ", $COLOR_INFO)
		;	For $i = $CounterToRemove To (UBound($toRemove) - 1)
		;		SetLog(" - " & $g_asSpellNames[TroopIndexLookup($toRemove[$i][0]) - $eLSpell] & ": " & $toRemove[$i][1] & "x", $COLOR_SUCCESS)
		;	Next
		;EndIf

		If Not _CheckPixel($aButtonEditArmy, True) Then ; If no 'Edit Army' Button found in army tab to edit troops
			SetLog("Cannot find/verify 'Edit Army' Button in Army tab", $COLOR_WARNING)
			Return False ; Exit function
		EndIf

		ClickP($aButtonEditArmy) ; Click Edit Army Button
		If _Sleep(500) Then Return
		
		SetLog("To Remove:", $COLOR_INFO)
		For $i = 0 To (UBound($toRemove) - 1)
			$iIndex = TroopIndexLookup($toRemove[$i][0])
			$bIsSpell = False ;reset
			If $iIndex >= $eLSpell Then 
				$iIndex -= $eLSpell 
				$bIsSpell = True 
				SetLog(" - " & $g_asSpellNames[$iIndex] & ": " & $toRemove[$i][1] & "x", $COLOR_SUCCESS)
			Else
				SetLog(" - " & $g_asTroopNames[$iIndex] & ": " & $toRemove[$i][1] & "x", $COLOR_SUCCESS)
			EndIf
			
			If QuickMIS("BFI", ($bIsSpell ? $g_sImgArmyOverviewSpells : $g_sImgArmyOverviewTroops) & $toRemove[$i][0] & "*", 77, ($bIsSpell ? 337 : 211), 520, ($bIsSpell ? 294 : 270)) Then
				$aRemovePos[0] = $g_iQuickMISX
				$aRemovePos[1] = $g_iQuickMISY
				ClickRemoveTroop($aRemovePos, $toRemove[$i][1], $g_iTrainClickDelay)
			EndIf
		Next
		
		;Local $rGetSlotNumber = GetSlotNumber() ; Get all available Slot numbers with troops assigned on them
		;Local $rGetSlotNumberSpells = GetSlotNumber(True)
		;
		;; Loop through troops needed to get removed
		;$CounterToRemove = 0
		;For $j = 0 To (UBound($toRemove) - 1)
		;	If IsSpellToBrew($toRemove[$j][0]) Then ExitLoop
		;	$CounterToRemove += 1
		;	For $i = 0 To (UBound($rGetSlotNumber) - 1) ; Loop through All available slots
		;		; $toRemove[$j][0] = Troop name, E.g: Barb, $toRemove[$j][1] = Quantity to remove
		;		If $toRemove[$j][0] = $rGetSlotNumber[$i] Then ; If $toRemove Troop Was the same as The Slot Troop
		;			Local $pos = GetSlotRemoveBtnPosition($i) ; Get positions of - Button to remove troop
		;			ClickRemoveTroop($pos, $toRemove[$j][1], $g_iTrainClickDelay) ; Click on Remove button as much as needed
		;		EndIf
		;	Next
		;Next
		;
		;For $j = $CounterToRemove To (UBound($toRemove) - 1)
		;	For $i = 0 To (UBound($rGetSlotNumberSpells) - 1) ; Loop through All available slots
		;		; $toRemove[$j][0] = Troop name, E.g: Barb, $toRemove[$j][1] = Quantity to remove
		;		If $toRemove[$j][0] = $rGetSlotNumberSpells[$i] Then ; If $toRemove Troop Was the same as The Slot Troop
		;			Local $pos = GetSlotRemoveBtnPosition($i, True) ; Get positions of - Button to remove troop
		;			ClickRemoveTroop($pos, $toRemove[$j][1], $g_iTrainClickDelay) ; Click on Remove button as much as needed
		;		EndIf
		;	Next
		;Next

		If _Sleep(1000) Then Return
		If Not _CheckPixel($aButtonRemoveTroopsOK1, True) Then ; If no 'Okay' button found in army tab to save changes
			SetLog("Cannot find/verify 'Okay' Button in Army tab", $COLOR_WARNING)
			ClickAway() ; Click Away, Necessary! due to possible errors/changes
			If _Sleep(1000) Then Return
			OpenArmyOverview("RemoveExtraTroops()") ; Open Army Window AGAIN
			Return False ; Exit Function
		EndIf

		If Not $g_bRunState Then Return
		ClickP($aButtonRemoveTroopsOK1, 1) ; Click on 'Okay' button to save changes
		If _Sleep(1200) Then Return
		If Not _CheckPixel($aButtonRemoveTroopsOK2, True) Then ; If no 'Okay' button found to verify that we accept the changes
			SetLog("Cannot find/verify 'Okay #2' Button in Army tab", $COLOR_WARNING)
			ClickAway()
			Return False ; Exit function
		EndIf

		ClickP($aButtonRemoveTroopsOK2, 1) ; Click on 'Okay' button to Save changes... Last button

		SetLog("All Extra troops removed", $COLOR_SUCCESS)
		If _Sleep(200) Then Return
		If $iResult = 0 Then $iResult = 1
	Else ; If No extra troop found
		SetLog("No extra troop to remove, great", $COLOR_SUCCESS)
		$iResult = 3
	EndIf

	Return $iResult
EndFunc   ;==>RemoveExtraTroops

Func DeleteInvalidTroopInArray(ByRef $aTroopArray)
	Local $iCounter = 0

	Switch (UBound($aTroopArray, 2) > 0) ; If Array Is 2D Array
		Case True
			Local $bIsValid = True, $i2DBound = UBound($aTroopArray, 2)
			For $i = 0 To (UBound($aTroopArray) - 1)
				If $aTroopArray[$i][0] Then
					If TroopIndexLookup($aTroopArray[$i][0], "DeleteInvalidTroopInArray#1") = -1 Or $aTroopArray[$i][0] = "" Then $bIsValid = False

					If $bIsValid Then
						For $j = 0 To (UBound($aTroopArray, 2) - 1)
							$aTroopArray[$iCounter][$j] = $aTroopArray[$i][$j]
						Next
						$iCounter += 1
					EndIf
				EndIf
			Next
			ReDim $aTroopArray[$iCounter][$i2DBound]
		Case Else
			For $i = 0 To (UBound($aTroopArray) - 1)
				If TroopIndexLookup($aTroopArray[$i], "DeleteInvalidTroopInArray#2") = -1 Or $aTroopArray[$i] = "" Then
					$aTroopArray[$iCounter] = $aTroopArray[$i]
					$iCounter += 1
				EndIf
			Next
			ReDim $aTroopArray[$iCounter]
	EndSwitch
EndFunc   ;==>DeleteInvalidTroopInArray

Func RemoveExtraTroopsQueue()
	For $i = 1 To 50
		If QuickMIS("BC1", $g_sImgDelQueue, 805, 150, 840, 200) Then
			If Not $g_bRunState Then Return
			SetLog("Remove All Queued Troops #" & $i, $COLOR_ACTION)
			Click($g_iQuickMISX, $g_iQuickMISY, 10, 50, "Remove Troops")
			If Not $g_bRunState Then Return
			If _Sleep(1000) Then Return
		Else
			ExitLoop
		EndIf
	Next
EndFunc   ;==>RemoveExtraTroopsQueue

Func IsQueueEmpty($sType = "Troops")
	Local $iArrowX, $iArrowY = 127
	If Not $g_bRunState Then Return
	
	If $sType = "Troops" Then
		$iArrowX = 327
	ElseIf $sType = "Spells" Then
		$iArrowX = 463
	EndIf
	
	If WaitforPixel($iArrowX - 1, $iArrowY - 1, $iArrowX, $iArrowY, Hex(0x797362, 6), 20, 1, "IsQueueEmpty") Then ;check if we have grey tab
		SetLog("IsQueueEmpty " & $sType & ": No queue arrow", $COLOR_ACTION)
		Return True
	ElseIf WaitforPixel($iArrowX - 1, $iArrowY - 1, $iArrowX, $iArrowY, Hex(0x83BF44, 6), 20, 1, "IsQueueEmpty") Then ;check if we have green arrow
		SetLog("IsQueueEmpty " & $sType & ": Found queue arrow", $COLOR_ACTION) 
		Return False
	EndIf
	
	Return False
EndFunc   ;==>IsQueueEmpty

Func ClickRemoveTroop($pos, $iTimes, $iSpeed)
	$pos[0] = Random($pos[0] - 10, $pos[0] + 10, 1)
	$pos[1] = Random($pos[1] - 10, $pos[1] + 10, 1)
	If Not $g_bRunState Then Return
	If _Sleep(400) Then Return
	If $iTimes <> 1 Then
		If FastCaptureRegion() Then
			For $i = 0 To ($iTimes - 1)
				PureClick($pos[0], $pos[1], 1, $iSpeed) ;Click once.
				If _Sleep($iSpeed, False) Then ExitLoop
			Next
		Else
			PureClick($pos[0], $pos[1], $iTimes, $iSpeed) ;Click $iTimes.
			If _Sleep($iSpeed, False) Then Return
		EndIf
	Else
		PureClick($pos[0], $pos[1], 1, $iSpeed)

		If _Sleep($iSpeed, False) Then Return
	EndIf
EndFunc   ;==>ClickRemoveTroop

Func GetSlotRemoveBtnPosition($iSlot, $bSpells = False)
	Local $iRemoveY = Not $bSpells ? 260 : 385
	Local $iRemoveX = 125 + Number(64 * $iSlot)

	Local Const $aResult[2] = [$iRemoveX, $iRemoveY]
	Return $aResult
EndFunc   ;==>GetSlotRemoveBtnPosition

Func GetSlotNumber($bSpells = False)
	Select
		Case $bSpells = False
			Local Const $Orders = [$eBarb, $eSBarb, $eArch, $eSArch, $eGiant, $eSGiant, $eGobl, $eSGobl, $eWall, $eSWall, $eBall, _ 
			$eRBall, $eWiza, $eSWiza, $eHeal, $eDrag, $eSDrag, $ePekk, $eBabyD, $eInfernoD, $eMine, $eSMine, _ 
			$eEDrag, $eYeti, $eRDrag, $eETitan, $eRootR, $eMini, $eSMini, $eHogs, $eSHogs, $eValk, $eSValk, $eGole, _ 
			$eWitc, $eSWitc, $eLava, $eIceH, $eBowl, $eSBowl, $eIceG, $eHunt, $eAppWard, $eGSkel, $eRGhost, _ 
			$ePWiza, $eIWiza] ; Set Order of troop display in Army Tab

			Local $allCurTroops[UBound($Orders)]

			; Code for Elixir Troops to Put Current Troops into an array by Order
			For $i = 0 To $eTroopCount - 1
				If Not $g_bRunState Then Return
				If $g_aiCurrentTroops[$i] > 0 Then
					For $j = 0 To (UBound($Orders) - 1)
						If TroopIndexLookup($g_asTroopShortNames[$i], "GetSlotNumber#1") = $Orders[$j] Then
							$allCurTroops[$j] = $g_asTroopShortNames[$i]
						EndIf
					Next
				EndIf
			Next

			;_ArrayDisplay($allCurTroops, "$allCurTroops")

			_ArryRemoveBlanks($allCurTroops)

			Return $allCurTroops
		Case $bSpells = True

			; Set Order of Spells display in Army Tab
			Local Const $SpellsOrders = [$eLSpell, $eHSpell, $eRSpell, _ 
			$eJSpell, $eFSpell, $eCSpell, $eISpell, $eReSpell, $ePSpell, $eESpell, $eHaSpell, $eSkSpell, $eBtSpell, $eOgSpell]

			Local $allCurSpells[UBound($SpellsOrders)]

			; Code for Spells to Put Current Spells into an array by Order
			For $i = 0 To $eSpellCount - 1
				If Not $g_bRunState Then Return
				If $g_aiCurrentSpells[$i] > 0 Then
					For $j = 0 To (UBound($SpellsOrders) - 1)
						If TroopIndexLookup($g_asSpellShortNames[$i], "GetSlotNumber#2") = $SpellsOrders[$j] Then
							$allCurSpells[$j] = $g_asSpellShortNames[$i]
						EndIf
					Next
				EndIf
			Next

			_ArryRemoveBlanks($allCurSpells)

			Return $allCurSpells
	EndSelect
EndFunc   ;==>GetSlotNumber

Func WhatToTrain($ReturnExtraTroopsOnly = False, $bFullArmy = $g_bIsFullArmywithHeroesAndSpells)
	OpenArmyTab(False, "WhatToTrain()")
	Local $ToReturn[1][2] = [["Arch", 0]] ; 2 element dynamic list [troop, quantity]

	If $bFullArmy And Not $ReturnExtraTroopsOnly Then
		If Not $g_bFullArmySpells Then getArmySpells(False, False, False, False) ; in case $g_bIsFullArmywithHeroesAndSpells but not $g_bFullArmySpells

		Local $bHaltAttack = $g_iCommandStop = 3 Or $g_iCommandStop = 0 Or ($g_abDonateOnly[$g_iCurAccount] And ProfileSwitchAccountEnabled())
		If Not $bHaltAttack Then
			SetLog(" - Your Army is Full, let's make troops before Attack!", $COLOR_INFO)
			; Elixir Troops
			For $i = 0 To $eTroopCount - 1
				Local $troopIndex = $g_aiTrainOrder[$i]
				If $g_aiArmyCompTroops[$troopIndex] > 0 Then
					$ToReturn[UBound($ToReturn) - 1][0] = $g_asTroopShortNames[$troopIndex]
					$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompTroops[$troopIndex]
					ReDim $ToReturn[UBound($ToReturn) + 1][2]
				EndIf
			Next

			; Spells
			For $i = 0 To $eSpellCount - 1
				Local $BrewIndex = $g_aiBrewOrder[$i]
				If $g_aiArmyCompSpells[$BrewIndex] > 0 Then
					$ToReturn[UBound($ToReturn) - 1][0] = $g_asSpellShortNames[$BrewIndex]
					$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompSpells[$BrewIndex] - ($g_bFullArmySpells ? 0 : $g_aiCurrentSpells[$BrewIndex])
					ReDim $ToReturn[UBound($ToReturn) + 1][2]
				EndIf
			Next
		Else
			If $g_iCommandStop = 3 Or $g_iCommandStop = 0 Then
				SetLog("You are in halt attack mode and your Army is prepared!", $COLOR_INFO)
			Else
				SetLog("Donate Only mode and your Army is prepared!", $COLOR_INFO)
			EndIf
			If Not $g_bFullArmySpells Then
				For $i = 0 To $eSpellCount - 1
					Local $BrewIndex = $g_aiBrewOrder[$i]
					If $g_aiArmyCompSpells[$BrewIndex] > 0 Then
						$ToReturn[UBound($ToReturn) - 1][0] = $g_asSpellShortNames[$BrewIndex]
						$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompSpells[$BrewIndex] - $g_aiCurrentSpells[$BrewIndex]
						ReDim $ToReturn[UBound($ToReturn) + 1][2]
					EndIf
				Next
			EndIf
		EndIf
		Return $ToReturn
	EndIf

	; Get Current available troops
	getArmyTroops(False, False, False, False)
	getArmySpells(False, False, False, False)

	Switch $ReturnExtraTroopsOnly
		Case False
			; Check Elixir Troops needed quantity to Train
			For $ii = 0 To $eTroopCount - 1
				Local $troopIndex = $g_aiTrainOrder[$ii]
				If $g_aiArmyCompTroops[$troopIndex] > 0 Then
					$ToReturn[UBound($ToReturn) - 1][0] = $g_asTroopShortNames[$troopIndex]
					$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompTroops[$troopIndex] - $g_aiCurrentTroops[$troopIndex]
					ReDim $ToReturn[UBound($ToReturn) + 1][2]
				EndIf
			Next

			; Check Spells needed quantity to Brew
			For $i = 0 To $eSpellCount - 1
				Local $BrewIndex = $g_aiBrewOrder[$i]
				If $g_aiArmyCompSpells[$BrewIndex] > 0 Then
					$ToReturn[UBound($ToReturn) - 1][0] = $g_asSpellShortNames[$BrewIndex]
					$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompSpells[$BrewIndex] - $g_aiCurrentSpells[$BrewIndex]
					ReDim $ToReturn[UBound($ToReturn) + 1][2]
				EndIf
			Next
		Case Else
			; Check Elixir Troops Extra Quantity
			For $ii = 0 To $eTroopCount - 1
				Local $troopIndex = $g_aiTrainOrder[$ii]
				If $g_aiCurrentTroops[$troopIndex] > 0 Then
					If $g_aiArmyCompTroops[$troopIndex] - $g_aiCurrentTroops[$troopIndex] < 0 Then
						$ToReturn[UBound($ToReturn) - 1][0] = $g_asTroopShortNames[$troopIndex]
						$ToReturn[UBound($ToReturn) - 1][1] = Abs($g_aiArmyCompTroops[$troopIndex] - $g_aiCurrentTroops[$troopIndex])
						ReDim $ToReturn[UBound($ToReturn) + 1][2]
					EndIf
				EndIf
			Next

			; Check Spells Extra Quantity
			For $i = 0 To $eSpellCount - 1
				Local $BrewIndex = $g_aiBrewOrder[$i]
				If $g_aiCurrentSpells[$BrewIndex] > 0 Then
					If $g_aiArmyCompSpells[$BrewIndex] - $g_aiCurrentSpells[$BrewIndex] < 0 Then
						$ToReturn[UBound($ToReturn) - 1][0] = $g_asSpellShortNames[$BrewIndex]
						$ToReturn[UBound($ToReturn) - 1][1] = Abs($g_aiArmyCompSpells[$BrewIndex] - $g_aiCurrentSpells[$BrewIndex])
						ReDim $ToReturn[UBound($ToReturn) + 1][2]
					EndIf
				EndIf
			Next
	EndSwitch
	DeleteInvalidTroopInArray($ToReturn)
	Return $ToReturn
EndFunc   ;==>WhatToTrain

Func CheckQueueTroops($bGetQuantity = True, $bSetLog = True, $x = 777, $bQtyWSlot = False)
	Local $aResult[1] = [""]
	If $bSetLog Then SetLog("Checking Troops Queue", $COLOR_INFO)

	Local $aSearchResult = SearchArmy($g_sImgArmyOverviewTroopsQueued, 73, 205, $x, 243, $bGetQuantity ? "Queue" : "")
	;SearchArmy($g_sImgArmyOverviewTroopsQueued, 73, 205, 777, 243, "Queue")
	ReDim $aResult[UBound($aSearchResult)]


	If $aSearchResult[0][0] = "" Then
		Setlog("CheckQueueTroops : No Queued Troops detected!", $COLOR_INFO)
		Return
	EndIf

	For $i = 0 To (UBound($aSearchResult) - 1)
		If Not $g_bRunState Then Return
		$aResult[$i] = $aSearchResult[$i][0]
	Next

	If $bGetQuantity Then
		Local $aQuantities[UBound($aResult)][3]
		Local $aQueueTroop[$eTroopCount]
		For $i = 0 To (UBound($aQuantities) - 1)
			$aQuantities[$i][0] = $aSearchResult[$i][0]
			$aQuantities[$i][1] = $aSearchResult[$i][3]
			$aQuantities[$i][2] = $aSearchResult[$i][1] ;x coord
			Local $iTroopIndex = TroopIndexLookup($aQuantities[$i][0])
			If $iTroopIndex >= 0 And $iTroopIndex < $eTroopCount Then
				If $bSetLog Then SetLog("  - " & $g_asTroopNames[TroopIndexLookup($aQuantities[$i][0], "CheckQueueTroops")] & ": " & $aQuantities[$i][1] & "x", $COLOR_SUCCESS)
				$aQueueTroop[$iTroopIndex] += $aQuantities[$i][1]
			Else
				; TODO check what to do with others
				SetDebugLog("Unsupport troop index: " & $iTroopIndex & " image: " & $aSearchResult[$i][0])
			EndIf
		Next
		If $bQtyWSlot Then Return $aQuantities
		Return $aQueueTroop
	EndIf

	_ArrayReverse($aResult)
	Return $aResult
EndFunc   ;==>CheckQueueTroops

;CheckQueueSpells(True, True, 777, True)
Func CheckQueueSpells($bGetQuantity = True, $bSetLog = True, $x = 777, $bQtyWSlot = False)
	Local $avResult[$eSpellCount]
	
	If $bSetLog Then SetLog("Checking Spells Queue", $COLOR_INFO)
	Local $avSearchResult = SearchArmy($g_sImgArmyOverviewSpellsQueued, 73, 205, $x, 243, $bGetQuantity ? "Queue" : "")
	;SearchArmy($g_sImgArmyOverviewSpellsQueued, 73, 205, 477, 243, "Queue")
	;QuickMIS("CNX", $g_sImgArmyOverviewSpellsQueued, 73, 205, 477, 243)
	If $avSearchResult[0][0] = "" Then
		Setlog("CheckQueueTroops : No Queued Spells detected!", $COLOR_INFO)
		Return
	EndIf

	For $i = 0 To (UBound($avSearchResult) - 1)
		If Not $g_bRunState Then Return
		$avResult[$i] = $avSearchResult[$i][0]
	Next

	;Trim length to number of returned values
	ReDim $avResult[UBound($avSearchResult)][1]

	If $bGetQuantity Then
		Local $aiQuantities[UBound($avResult)][3]
		Local $aQueueSpell[$eSpellCount]
		For $i = 0 To (UBound($aiQuantities) - 1)
			If Not $g_bRunState Then Return
			$aiQuantities[$i][0] = $avSearchResult[$i][0] ;imageName
			$aiQuantities[$i][1] = $avSearchResult[$i][3] ;Quantity
			$aiQuantities[$i][2] = $avSearchResult[$i][1] ;x coord
			
			Local $iSpellIndex = TroopIndexLookup($aiQuantities[$i][0]) - $eLSpell
			If $iSpellIndex >= 0 And $iSpellIndex < $eSpellCount Then
				If $bSetLog Then SetLog("  - " & GetTroopName(TroopIndexLookup($aiQuantities[$i][0], "CheckQueueSpells"), $aiQuantities[$i][1] )& ": " & $aiQuantities[$i][1] & "x", $COLOR_SUCCESS)
				$aQueueSpell[$iSpellIndex] += $aiQuantities[$i][1]
			Else
				; TODO check what to do with others
				SetDebugLog("Unsupport Spell index: " & $iSpellIndex & " image: " & $avSearchResult[$i][0])
			EndIf
		Next
		If $bQtyWSlot Then Return $aiQuantities
		Return $aQueueSpell
	EndIf

	_ArrayReverse($avResult)
	Return $avResult
EndFunc   ;==>CheckQueueSpells

Func SearchArmy($sImageDir = "", $x = 0, $y = 0, $x1 = 0, $y1 = 0, $sArmyType = "")
	; Setup arrays, including default return values for $return
	Local $aResult[1][4], $aCoordArray[1][2], $aCoords, $aCoordsSplit, $aValue
		
	If Not $g_bRunState Then Return $aResult
	
	
	; Perform the search
	_CaptureRegion2($x, $y, $x1, $y1)
	Local $res = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $sImageDir, "str", "FV", "Int", 0, "str", "FV", "Int", 0, "Int", 1000)

	If $res[0] <> "" Then
		; Get the keys for the dictionary item.
		Local $aKeys = StringSplit($res[0], "|", $STR_NOCOUNT)

		; Redimension the result array to allow for the new entries
		ReDim $aResult[UBound($aKeys)][4]
		Local $iResultAddDup = 0

		; Loop through the array
		For $i = 0 To UBound($aKeys) - 1
			; Get the property values
			$aResult[$i + $iResultAddDup][0] = RetrieveImglocProperty($aKeys[$i], "objectname")
			; Get the coords property
			$aValue = RetrieveImglocProperty($aKeys[$i], "objectpoints")
			$aCoords = decodeMultipleCoords($aValue, 50) ; dedup coords by x on 50 pixel
			$aCoordsSplit = $aCoords[0]
			If UBound($aCoordsSplit) = 2 Then
				; Store the coords into a two dimensional array
				$aCoordArray[0][0] = $aCoordsSplit[0] + $x ; X coord.
				$aCoordArray[0][1] = $aCoordsSplit[1] + $y ; Y coord.
			Else
				$aCoordArray[0][0] = -1
				$aCoordArray[0][1] = -1
			EndIf
			; Store the coords array as a sub-array
			$aResult[$i + $iResultAddDup][1] = Number($aCoordArray[0][0])
			$aResult[$i + $iResultAddDup][2] = Number($aCoordArray[0][1])
			SetDebugLog($aResult[$i + $iResultAddDup][0] & " | $aCoordArray: " & $aCoordArray[0][0] & "-" & $aCoordArray[0][1])
			; If 1 troop type appears at more than 1 slot
			Local $iMultipleCoords = UBound($aCoords)
			If $iMultipleCoords > 1 Then
				SetDebugLog($aResult[$i + $iResultAddDup][0] & " detected " & $iMultipleCoords & " times!")
				For $j = 1 To $iMultipleCoords - 1
					Local $aCoordsSplit2 = $aCoords[$j]
					If UBound($aCoordsSplit2) = 2 Then
						; add slot
						$iResultAddDup += 1
						ReDim $aResult[UBound($aKeys) + $iResultAddDup][4]
						$aResult[$i + $iResultAddDup][0] = $aResult[$i + $iResultAddDup - 1][0] ; same objectname
						$aResult[$i + $iResultAddDup][1] = $aCoordsSplit2[0] + $x
						$aResult[$i + $iResultAddDup][2] = $aCoordsSplit2[1]
						SetDebugLog($aResult[$i + $iResultAddDup][0] & " | $aCoordArray: " & $aResult[$i + $iResultAddDup][1] & "-" & $aResult[$i + $iResultAddDup][2])
					EndIf
				Next
			EndIf
		Next
	EndIf
	
	_ArraySort($aResult, 0, 0, 0, 1) ; Sort By X position , will be the Slot 0 to $i

	While 1
		If UBound($aResult) < 2 Then ExitLoop
		For $i = 1 To UBound($aResult) - 1
			If $aResult[$i][0] = $aResult[$i - 1][0] And Abs($aResult[$i][1] - $aResult[$i - 1][1]) <= 50 Then
				SetDebugLog("Double detection " & $aResult[$i][0] & " at " & $i - 1 & ": " & $aResult[$i][1] & " & " & $aResult[$i - 1][1])
				_ArrayDelete($aResult, $i)
				ContinueLoop 2
			EndIf
		Next
		ExitLoop
	WEnd

	If $sArmyType = "Troops" Then
		For $i = 0 To UBound($aResult) - 1
			$aResult[$i][3] = Number(getBarracksNewTroopQuantity(Slot($aResult[$i][1], "troop"), 1)) ; coc-newarmy
		Next
	EndIf
	If $sArmyType = "Spells" Then
		For $i = 0 To UBound($aResult) - 1
			$aResult[$i][3] = Number(getBarracksNewTroopQuantity(Slot($aResult[$i][1], "spells"), 312)) ; coc-newarmy
			;SetLog("$aResult: " & $aResult[$i][0] & "|" & $aResult[$i][1] & "|" & $aResult[$i][2] & "|" & $aResult[$i][3])
		Next
	EndIf
	If $sArmyType = "CCSpells" Then
		For $i = 0 To UBound($aResult) - 1
			$aResult[$i][3] = Number(getBarracksNewTroopQuantity(Slot($aResult[$i][1], "troop"), 469)) ; coc-newarmy
		Next
	EndIf
	If $sArmyType = "Heroes" Then ; CheckThis
		For $i = 0 To UBound($aResult) - 1
			If StringInStr($aResult[$i][0], "Kingqueued") Then
				$aResult[$i][3] = getRemainTHero(545, 414)
			ElseIf StringInStr($aResult[$i][0], "Queenqueued") Then
				$aResult[$i][3] = getRemainTHero(618, 414)
			ElseIf StringInStr($aResult[$i][0], "Wardenqueued") Then
				$aResult[$i][3] = getRemainTHero(698, 414)
			ElseIf StringInStr($aResult[$i][0], "Championqueued") Then
				$aResult[$i][3] = getRemainTHero(0, 0)
			Else
				$aResult[$i][3] = 0
			EndIf
		Next
	EndIf

	If $sArmyType = "Queue" Then
		_ArraySort($aResult, 1, 0, 0, 1) ; reverse the queued slots from right to left
		Local $xSlot
		For $i = 0 To UBound($aResult) - 1
			$xSlot = Int(Number($aResult[$i][1]) / 61) * 61 - 8
			$aResult[$i][3] = Number(getQueueTroopsQuantity($xSlot, 190))
			SetDebugLog($aResult[$i][0] & " (" & $xSlot & ") x" & $aResult[$i][3])
		Next
	EndIf

	Return $aResult
EndFunc   ;==>SearchArmy

Func ResetVariables($sArmyType = "")

	If $sArmyType = "troops" Or $sArmyType = "all" Then
		For $i = 0 To $eTroopCount - 1
			If Not $g_bRunState Then Return
			$g_aiCurrentTroops[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return ; '20' just to Pause action
		Next
	EndIf
	If $sArmyType = "Spells" Or $sArmyType = "all" Then
		For $i = 0 To $eSpellCount - 1
			If Not $g_bRunState Then Return
			$g_aiCurrentSpells[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return ; '20' just to Pause action
		Next
	EndIf
	If $sArmyType = "SiegeMachines" Or $sArmyType = "all" Then
		For $i = 0 To $eSiegeMachineCount - 1
			If Not $g_bRunState Then Return
			$g_aiCurrentSiegeMachines[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return ; '20' just to Pause action
		Next
	EndIf
	If $sArmyType = "donated" Or $sArmyType = "all" Then
		For $i = 0 To $eTroopCount - 1
			If Not $g_bRunState Then Return
			$g_aiDonateTroops[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return ; '20' just to Pause action
		Next
		For $i = 0 To $eSpellCount - 1 ; fixed making wrong donated spells
			If Not $g_bRunState Then Return
			$g_aiDonateSpells[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return
		Next
		For $i = 0 To $eSiegeMachineCount - 1
			If Not $g_bRunState Then Return
			$g_aiDonateSiegeMachines[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return
		Next
	EndIf

EndFunc   ;==>ResetVariables

Func DeleteQueued($sArmyTypeQueued, $iOffsetQueued = 802)

	If $sArmyTypeQueued = "Troops" Then
		If Not OpenTroopsTab(True, "DeleteQueued()") Then Return
	ElseIf $sArmyTypeQueued = "Spells" Then
		If Not OpenSpellsTab(True, "DeleteQueued()") Then Return
	ElseIf $sArmyTypeQueued = "SiegeMachines" Then
		If Not OpenSiegeMachinesTab(True, "DeletQueued()") Then Return
	Else
		Return
	EndIf
	If _Sleep(500) Then Return
	
	For $i = 1 To 50
		If QuickMIS("BC1", $g_sImgDelQueue, 755, 190, 780, 210) Then
			If Not $g_bRunState Then Return
			SetLog("Remove All Queued " & $sArmyTypeQueued & " #" & $i, $COLOR_ACTION)
			Click($g_iQuickMISX, $g_iQuickMISY, 10, 50, "Remove Troops")
			If Not $g_bRunState Then Return
			If _Sleep(1000) Then Return
		Else
			ExitLoop
		EndIf
	Next
EndFunc   ;==>DeleteQueued

Func MakingDonatedTroops($sType = "All")
	Local $avDefaultTroopGroup[$eTroopCount][6]
	For $i = 0 To $eTroopCount - 1
		$avDefaultTroopGroup[$i][0] = $g_asTroopShortNames[$i]
		$avDefaultTroopGroup[$i][1] = $i
		$avDefaultTroopGroup[$i][2] = $g_aiTroopSpace[$i]
		$avDefaultTroopGroup[$i][3] = $g_aiTroopTrainTime[$i]
		$avDefaultTroopGroup[$i][4] = 0
		$avDefaultTroopGroup[$i][5] = $i >= $eMini ? "d" : "e"
	Next

	; notes $avDefaultTroopGroup[19][5]
	; notes $avDefaultTroopGroup[19][0] = TroopName | [1] = TroopNamePosition | [2] = TroopHeight | [3] = Times | [4] = qty | [5] = marker for DarkTroop or ElixerTroop]
	; notes ClickDrag(616, 445, 400, 445, 2000) ; Click drag for dark Troops
	; notes	ClickDrag(400, 445, 616, 445, 2000) ; Click drag for Elixer Troops
	; notes $RemainTrainSpace[0] = Current Army  | [1] = Total Army Capacity  | [2] = Remain Space for the current Army

	Local $RemainTrainSpace
	Local $Plural = 0
	Local $areThereDonTroop = 0
	Local $areThereDonSpell = 0
	Local $areThereDonSiegeMachine = 0

	For $j = 0 To $eTroopCount - 1
		If $sType <> "Troops" And $sType <> "All" Then ExitLoop
		If Not $g_bRunState Then Return
		$areThereDonTroop += $g_aiDonateTroops[$j]
	Next

	For $j = 0 To $eSpellCount - 1
		If $sType <> "Spells" And $sType <> "All" Then ExitLoop
		If Not $g_bRunState Then Return
		$areThereDonSpell += $g_aiDonateSpells[$j]
	Next

	For $j = 0 To $eSiegeMachineCount - 1
		If $sType <> "Siege" And $sType <> "All" Then ExitLoop
		If Not $g_bRunState Then Return
		$areThereDonSiegeMachine += $g_aiDonateSiegeMachines[$j]
	Next
	If $areThereDonSpell = 0 And $areThereDonTroop = 0 And $areThereDonSiegeMachine = 0 Then Return

	SetLog("  making donated troops", $COLOR_ACTION1)
	If $areThereDonTroop > 0 Then
		; Load $g_aiDonateTroops[$i] Values into $avDefaultTroopGroup[19][5]
		For $i = 0 To UBound($avDefaultTroopGroup) - 1
			For $j = 0 To $eTroopCount - 1
				If $g_asTroopShortNames[$j] = $avDefaultTroopGroup[$i][0] Then
					$avDefaultTroopGroup[$i][4] = $g_aiDonateTroops[$j]
					$g_aiDonateTroops[$j] = 0
				EndIf
			Next
		Next

		If Not OpenTroopsTab(True, "MakingDonatedTroops()") Then Return

		For $i = 0 To UBound($avDefaultTroopGroup, 1) - 1
			If Not $g_bRunState Then Return
			$Plural = 0
			If $avDefaultTroopGroup[$i][4] > 0 Then
				$RemainTrainSpace = GetOCRCurrent(95, 163)
				If $RemainTrainSpace[2] < 0 Then $RemainTrainSpace[2] = $RemainTrainSpace[1] * 2 - $RemainTrainSpace[0] ; remain train space to full double army
				If $RemainTrainSpace[2] = 0 Then ExitLoop ; army camps full

				Local $iTroopIndex = TroopIndexLookup($avDefaultTroopGroup[$i][0], "MakingDonatedTroops")

				If $avDefaultTroopGroup[$i][2] * $avDefaultTroopGroup[$i][4] <= $RemainTrainSpace[2] Then ; Troopheight x donate troop qty <= avaible train space
					;Local $pos = GetImageToUse(TroopIndexLookup($avDefaultTroopGroup[$i][0]))
					Local $howMuch = $avDefaultTroopGroup[$i][4]
					If $avDefaultTroopGroup[$i][5] = "e" Then
						TrainIt($iTroopIndex, $howMuch, $g_iTrainClickDelay)
						;PureClick($pos[0], $pos[1], $howMuch, 500)
					Else
						ClickDrag(715, 445, 220, 445, 2000) ; Click drag for dark Troops
						TrainIt($iTroopIndex, $howMuch, $g_iTrainClickDelay)
						;PureClick($pos[0], $pos[1], $howMuch, 500)
						ClickDrag(220, 445, 725, 445, 2000) ; Click drag for Elixer Troops
					EndIf
					If _Sleep($DELAYRESPOND) Then Return ; add 5ms delay to catch TrainIt errors, and force return to back to main loop
					Local $sTroopName = ($avDefaultTroopGroup[$i][4] > 1 ? $g_asTroopNamesPlural[$iTroopIndex] : $g_asTroopNames[$iTroopIndex])
					SetLog(" - Trained " & $avDefaultTroopGroup[$i][4] & " " & $sTroopName, $COLOR_ACTION)
					$avDefaultTroopGroup[$i][4] = 0
					If _Sleep(500) Then Return ; Needed Delay, OCR was not picking up Troop Changes
				Else
					For $z = 0 To $RemainTrainSpace[2] - 1
						$RemainTrainSpace = GetOCRCurrent(95, 163)
						If $RemainTrainSpace[0] = $RemainTrainSpace[1] Then ; army camps full
							;Camps Full All Donate Counters should be zero!!!!
							For $j = 0 To UBound($avDefaultTroopGroup, 1) - 1
								$avDefaultTroopGroup[$j][4] = 0
							Next
							ExitLoop (2) ;
						EndIf
						If $avDefaultTroopGroup[$i][2] <= $RemainTrainSpace[2] And $avDefaultTroopGroup[$i][4] > 0 Then
							;TrainIt(TroopIndexLookup($g_asTroopShortNames[$i]), 1, $g_iTrainClickDelay)
							;Local $pos = GetImageToUse(TroopIndexLookup($avDefaultTroopGroup[$i][0]))
							Local $howMuch = 1
							If $iTroopIndex >= $eBarb And $iTroopIndex <= $eMine Then ; elixir troop
								TrainIt($iTroopIndex, $howMuch, $g_iTrainClickDelay)
								;PureClick($pos[0], $pos[1], $howMuch, 500)
							Else ; dark elixir troop
								ClickDrag(715, 445, 220, 445, 2000) ; Click drag for dark Troops
								TrainIt($iTroopIndex, $howMuch, $g_iTrainClickDelay)
								;PureClick($pos[0], $pos[1], $howMuch, 500)
								ClickDrag(220, 445, 725, 445, 2000) ; Click drag for Elixer Troops
							EndIf
							If _Sleep($DELAYRESPOND) Then Return ; add 5ms delay to catch TrainIt errors, and force return to back to main loop
							Local $sTroopName = ($avDefaultTroopGroup[$i][4] > 1 ? $g_asTroopNamesPlural[$iTroopIndex] : $g_asTroopNames[$iTroopIndex])
							SetLog(" - Trained " & $avDefaultTroopGroup[$i][4] & " " & $sTroopName, $COLOR_ACTION)
							$avDefaultTroopGroup[$i][4] -= 1
							If _Sleep(1000) Then Return ; Needed Delay, OCR was not picking up Troop Changes
						Else
							ExitLoop
						EndIf
					Next
				EndIf
			EndIf
		Next
		;Top Off any remianing space with archers
		If $sType = "All" Then
			$RemainTrainSpace = GetOCRCurrent(95, 163)
			If $RemainTrainSpace[0] < $RemainTrainSpace[1] Then ; army camps full
				Local $howMuch = $RemainTrainSpace[2]
				TrainIt($eTroopArcher, $howMuch, $g_iTrainClickDelay)
				;PureClick($TrainArch[0], $TrainArch[1], $howMuch, 500)
				If $RemainTrainSpace[2] > 0 Then $Plural = 1
				SetLog(" - Trained " & $howMuch & " archer(s)!", $COLOR_ACTION)
				If _Sleep(1000) Then Return ; Needed Delay, OCR was not picking up Troop Changes
			EndIf
		EndIf
	EndIf

	If $areThereDonSpell > 0 Then
		;Train Donated Spells
		If Not OpenSpellsTab(True, "MakingDonatedTroops()") Then Return

		For $i = 0 To $eSpellCount - 1
			If Not $g_bRunState Then Return
			If $g_aiDonateSpells[$i] > 0 Then
				Local $pos = GetImageToUse($i + $eLSpell)
				Local $howMuch = $g_aiDonateSpells[$i]
				TrainIt($eLSpell + $i, $howMuch, $g_iTrainClickDelay)
				;PureClick($pos[0], $pos[1], $howMuch, 500)
				If _Sleep($DELAYRESPOND) Then Return ; add 5ms delay to catch TrainIt errors, and force return to back to main loop
				SetLog(" - Brewed " & $howMuch & " " & $g_asSpellNames[$i] & ($howMuch > 1 ? " Spells" : " Spell"), $COLOR_ACTION)
				$g_aiDonateSpells[$i] -= $howMuch

				If _Sleep(1000) Then Return
				$RemainTrainSpace = GetOCRCurrent(95, 163)
				SetLog(" - Current Capacity: " & $RemainTrainSpace[0] & "/" & ($RemainTrainSpace[1]))
			EndIf
		Next
	EndIf

	If $areThereDonSiegeMachine > 0 Then
		;Train Donated Sieges
		If Not OpenSiegeMachinesTab(True, "MakingDonatedTroops()") Then Return

		For $iSiegeIndex = $eSiegeWallWrecker To $eSiegeMachineCount - 1
			If Not $g_bRunState Then Return
			If $g_aiDonateSiegeMachines[$iSiegeIndex] > 0 Then
				Local $aCheckIsAvailableSiege[4] = [58, 556, 0x47717E, 10]
				Local $aCheckIsAvailableSiege1[4] = [229, 556, 0x47717E, 10]
				Local $aCheckIsAvailableSiege2[4] = [400, 556, 0x47717E, 10]
				Local $aCheckIsAvailableSiege3[4] = [576, 556, 0x47717E, 10]
				Local $aCheckIsAvailableSiege4[4] = [750, 556, 0x47717E, 10]
				Local $checkPixel
				If $iSiegeIndex = $eSiegeWallWrecker Then $checkPixel = $aCheckIsAvailableSiege
				If $iSiegeIndex = $eSiegeBattleBlimp Then $checkPixel = $aCheckIsAvailableSiege1
				If $iSiegeIndex = $eSiegeStoneSlammer Then $checkPixel = $aCheckIsAvailableSiege2
				If $iSiegeIndex = $eSiegeBarracks Then $checkPixel = $aCheckIsAvailableSiege3
				If $iSiegeIndex = $eSiegeLogLauncher Then $checkPixel = $aCheckIsAvailableSiege4
				Local $HowMany = $g_aiDonateSiegeMachines[$iSiegeIndex]
				If _CheckPixel($checkPixel, True, Default, $g_asSiegeMachineNames[$iSiegeIndex]) Then
					;PureClick($pos[0], $pos[1], $howMuch, 500)
					If _Sleep($DELAYRESPOND) Then Return ; add 5ms delay to catch TrainIt errors, and force return to back to main loop
					PureClick($checkPixel[0], $checkPixel[1], $HowMany, $g_iTrainClickDelay)
					Local $sSiegeName = $HowMany >= 2 ? $g_asSiegeMachineNames[$iSiegeIndex] & "s" : $g_asSiegeMachineNames[$iSiegeIndex] & ""
					SetLog(" - Trained " & $HowMany & " " & $g_asSiegeMachineNames[$iSiegeIndex] & ($HowMany > 1 ? " SiegeMachines" : " SiegeMachine"), $COLOR_ACTION)
					$g_aiDonateSiegeMachines[$iSiegeIndex] -= $HowMany
				EndIf
			EndIf
		Next
		; Get Siege Capacities
		Local $sSiegeInfo = getArmyCapacityOnTrainTroops(60, 140) ; OCR read Siege built and total
		If $g_bDebugSetlogTrain Then SetLog("OCR $sSiegeInfo = " & $sSiegeInfo, $COLOR_DEBUG)
		Local $aGetSiegeCap = StringSplit($sSiegeInfo, "#", $STR_NOCOUNT) ; split the built Siege number from the total Siege number
		SetLog("Total Siege Workshop Capacity: " & $aGetSiegeCap[0] & "/" & $aGetSiegeCap[1])
		If Number($aGetSiegeCap[0]) = 0 Then Return
	EndIf

	Return True

EndFunc   ;==>MakingDonatedTroops

Func GetOCRCurrent($x_start, $y_start)

	Local $aResult[3] = [0, 0, 0]
	If Not $g_bRunState Then Return $aResult

	; [0] = Current Army  | [1] = Total Army Capacity  | [2] = Remain Space for the current Army
	Local $iOCRResult = getArmyCapacityOnTrainTroops($x_start, $y_start)

	If StringInStr($iOCRResult, "#") Then
		Local $aTempResult = StringSplit($iOCRResult, "#", $STR_NOCOUNT)
		$aResult[0] = Number($aTempResult[0])
		$aResult[1] = Number($aTempResult[1])
		; Case to use this function os Spells will be <= 22 , 11*2
		If $aResult[1] <= 22 Then
			If $g_bDebugSetlogTrain Then SetLog("$g_iTotalSpellValue: " & $g_iTotalSpellValue, $COLOR_DEBUG)
			$aResult[1] = $g_iTotalSpellValue
			$aResult[2] = $g_iTotalSpellValue - $aResult[0]
			; May 2018 Update the Army Camp Value on Train page is DOUBLE Value
		ElseIf $aResult[1] <> $g_iTotalCampSpace Then
			If $g_bDebugSetlogTrain Then SetLog("$g_iTotalCampSpace: " & $g_iTotalCampSpace, $COLOR_DEBUG)
			$aResult[1] = $g_iTotalCampSpace
			$aResult[2] = $g_iTotalCampSpace - $aResult[0]
		EndIf
		$aResult[2] = $aResult[1] - $aResult[0]
	Else
		SetLog("DEBUG | ERROR on GetOCRCurrent", $COLOR_ERROR)
	EndIf

	Return $aResult

EndFunc   ;==>GetOCRCurrent

Func _ArryRemoveBlanks(ByRef $aArray)
	Local $iCounter = 0
	For $i = 0 To UBound($aArray) - 1
		If $aArray[$i] <> "" Then
			$aArray[$iCounter] = $aArray[$i]
			$iCounter += 1
		EndIf
	Next
	ReDim $aArray[$iCounter]
EndFunc   ;==>_ArryRemoveBlanks

Func ValidateSearchArmyResult($aSearchResult, $iIndex = 0)
	If IsArray($aSearchResult) Then
		If UBound($aSearchResult) > 0 Then
			If StringLen($aSearchResult[$iIndex][0]) > 0 Then Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>ValidateSearchArmyResult

