; #FUNCTION# ====================================================================================================================
; Name ..........: algorith_AllTroops
; Description ...: This file contens all functions to attack algorithm will all Troops , using Barbarians, Archers, Goblins, Giants and Wallbreakers as they are available
; Syntax ........: algorithm_AllTroops()
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: Didipe (05-2015), ProMac(2016), MonkeyHunter(03-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func algorithm_AllTroops() ;Attack Algorithm for all existing troops
	SetDebugLog("algorithm_AllTroops()", $COLOR_DEBUG)
	SetSlotSpecialTroops()

	If _Sleep($DELAYALGORITHM_ALLTROOPS1) Then Return

	SmartAttackStrategy($g_iMatchMode) ; detect redarea first to drop any troops

	Local $nbSides = 0
	Switch $g_aiAttackStdDropSides[$g_iMatchMode]
		Case 0 ;Single sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on a single side", $COLOR_INFO)
			$nbSides = 1
		Case 1 ;Two sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on two sides", $COLOR_INFO)
			$nbSides = 2
		Case 2 ;Three sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on three sides", $COLOR_INFO)
			$nbSides = 3
		Case 3 ;All sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on all sides", $COLOR_INFO)
			$nbSides = 4
		Case 4 ;DE Side - Live Base only ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on Dark Elixir Side.", $COLOR_INFO)
			$nbSides = 1
			If Not ($g_abAttackStdSmartAttack[$g_iMatchMode]) Then GetBuildingEdge($eSideBuildingDES) ; Get DE Storage side when Redline is not used.
		Case 5 ;TH Side - Live Base only ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on Town Hall Side.", $COLOR_INFO)
			$nbSides = 1
			If Not ($g_abAttackStdSmartAttack[$g_iMatchMode]) Then GetBuildingEdge($eSideBuildingTH) ; Get Townhall side when Redline is not used.
	EndSwitch
	If ($nbSides = 0) Then Return
	If _Sleep($DELAYALGORITHM_ALLTROOPS2) Then Return

	$g_iSidesAttack = $nbSides

	; Reset the deploy Giants points , spread along red line
	$g_iSlotsGiants = 0
	Local $GiantComp = 0
	; Giants quantities
	For $i = 0 To UBound($g_avAttackTroops) - 1
		If $g_avAttackTroops[$i][0] = $eGiant Then
			$GiantComp = $g_avAttackTroops[$i][1]
		EndIf
	Next

	; Lets select the deploy points according by Giants qunatities & sides
	; Deploy points : 0 - spreads along the red line , 1 - one deploy point .... X - X deploy points
	Switch $GiantComp
		Case 0 To 10
			$g_iSlotsGiants = 2
		Case Else
			Switch $nbSides
				Case 1 To 2
					$g_iSlotsGiants = 4
				Case Else
					$g_iSlotsGiants = 0
			EndSwitch
	EndSwitch

	; $ListInfoDeploy = [Troop, No. of Sides, $WaveNb, $MaxWaveNb, $slotsPerEdge]
	If $g_iMatchMode = $LB And $g_aiAttackStdDropSides[$LB] = 4 Then ; Customise DE side wave deployment here
		Switch $g_aiAttackStdDropOrder[$g_iMatchMode]
			Case 0
				Local $listInfoDeploy[45][5] = [[$eGole, $nbSides, 1, 1, 2] _
							, [$eLava, $nbSides, 1, 1, 2] _
							, [$eIceH, $nbSides, 1, 1, 2] _
							, [$eIceG, $nbSides, 1, 1, 2] _
							, [$eYeti, $nbSides, 1, 1, 2] _
							, [$eGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
							, [$eSGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
							, [$eGSkel, $nbSides, 1, 1, 0] _
							, [$eRGhost, $nbSides, 1, 1, 0] _
							, [$eDrag, $nbSides, 1, 1, 0] _
							, [$eSDrag, $nbSides, 1, 1, 0] _
							, [$eBall, $nbSides, 1, 1, 0] _
							, [$eRBall, $nbSides, 1, 1, 0] _
							, [$eBabyD, $nbSides, 1, 1, 0] _
							, [$eInfernoD, $nbSides, 1, 1, 0] _
							, [$eHogs, $nbSides, 1, 1, 1] _
							, [$eValk, $nbSides, 1, 1, 0] _
							, [$eSValk, $nbSides, 1, 1, 0] _
							, [$eBowl, $nbSides, 1, 1, 0] _
							, [$eSBowl, $nbSides, 1, 1, 0] _
							, [$eMine, $nbSides, 1, 1, 0] _
							, [$eEDrag, $nbSides, 1, 1, 0] _
							, [$eRDrag, $nbSides, 1, 1, 0] _
							, [$eETitan, $nbSides, 1, 1, 0] _
							, [$eWall, $nbSides, 1, 1, 1] _
							, [$eSWall, $nbSides, 1, 1, 1] _
							, [$eBarb, $nbSides, 1, 1, 0] _
							, [$eSBarb, $nbSides, 1, 1, 0] _
							, [$eArch, $nbSides, 1, 1, 0] _
							, [$eSArch, $nbSides, 1, 1, 0] _
							, [$eWiza, $nbSides, 1, 1, 0] _
							, [$eSWiza, $nbSides, 1, 1, 0] _
							, [$ePWiza, $nbSides, 1, 1, 0] _
							, [$eIWiza, $nbSides, 1, 1, 0] _
							, [$eMini, $nbSides, 1, 1, 0] _
							, [$eSMini, $nbSides, 1, 1, 0] _
							, [$eWitc, $nbSides, 1, 1, 1] _
							, [$eSWitc, $nbSides, 1, 1, 1] _
							, [$eGobl, $nbSides, 1, 1, 0] _
							, [$eSGobl, $nbSides, 1, 1, 0] _
							, [$eHeal, $nbSides, 1, 1, 1] _
							, [$ePekk, $nbSides, 1, 1, 1] _
							, [$eHunt, $nbSides, 1, 1, 0] _
							, ["CC", 1, 1, 1, 1] _
							, ["HEROES", 1, 2, 1, 1]]
				If $g_bCustomDropOrderEnable Then
					Local $aTmpDelete
					Local $aTmpListInfoDeploy = $listInfoDeploy
					;AttackSmartFarm(4, "TL|BR|BL|TR")
					;_ArrayDisplay($aTmpListInfoDeploy, "aTmpListInfoDeploy1")
					For $i = 0 To UBound($g_ahCmbDropOrder) - 1
						Local $iValue = $g_aiCmbCustomDropOrder[$i]
						SetLog("iValue : " & $iValue)
						If $iValue <> -1 Then
							Local $iDelete = _ArraySearch($aTmpListInfoDeploy, $iValue, 0, 0, 0, 0, 1, 0)
							SetLog("iDelete : " & $iDelete)
							Local $troop = $aTmpListInfoDeploy[$i][0]
							Local $nside1 = $aTmpListInfoDeploy[$i][1]
							Local $wave = $aTmpListInfoDeploy[$i][2]
							Local $x = $aTmpListInfoDeploy[$i][3]
							Local $slotedge = $aTmpListInfoDeploy[$i][4]
							
							$aTmpListInfoDeploy[$i][0] = $aTmpListInfoDeploy[$iDelete][0]
							$aTmpListInfoDeploy[$i][1] = $aTmpListInfoDeploy[$iDelete][1]
							$aTmpListInfoDeploy[$i][2] = $aTmpListInfoDeploy[$iDelete][2]
							$aTmpListInfoDeploy[$i][3] = $aTmpListInfoDeploy[$iDelete][3]
							$aTmpListInfoDeploy[$i][4] = $aTmpListInfoDeploy[$iDelete][4]
							
							$aTmpListInfoDeploy[$iDelete][0] = $troop
							$aTmpListInfoDeploy[$iDelete][1] = $nside1
							$aTmpListInfoDeploy[$iDelete][2] = $wave
							$aTmpListInfoDeploy[$iDelete][3] = $x
							$aTmpListInfoDeploy[$iDelete][4] = $slotedge
						EndIf
					Next
					$listInfoDeploy = $aTmpListInfoDeploy
				EndIf
			Case 1
				Local $listInfoDeploy[10][5] = [[$eBarb, $nbSides, 1, 1, 0] _
						, [$eSBarb, $nbSides, 1, 1, 0] _
						, [$eArch, $nbSides, 1, 1, 0] _
						, [$eSArch, $nbSides, 1, 1, 0] _
						, [$eGobl, $nbSides, 1, 1, 0] _
						, [$eSGobl, $nbSides, 1, 1, 0] _
						, [$eMini, $nbSides, 1, 1, 0] _
						, [$eSMini, $nbSides, 1, 1, 0] _
						, ["CC", 1, 1, 1, 1] _
						, ["HEROES", 1, 2, 1, 1]]
			Case 2
				Local $listInfoDeploy[23][5] = [[$eGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
						, [$eSGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
						, ["CC", 1, 1, 1, 1] _
						, [$eWall, $nbSides, 1, 1, 2] _
						, [$eSWall, $nbSides, 1, 1, 2] _
						, [$eBarb, $nbSides, 1, 2, 2] _
						, [$eSBarb, $nbSides, 1, 2, 2] _
						, [$eArch, $nbSides, 1, 3, 3] _
						, [$eSArch, $nbSides, 1, 3, 3] _
						, [$eBarb, $nbSides, 2, 2, 2] _
						, [$eSBarb, $nbSides, 2, 2, 2] _
						, [$eArch, $nbSides, 2, 3, 3] _
						, [$eSArch, $nbSides, 2, 3, 3] _
						, ["HEROES", 1, 2, 1, 0] _
						, [$eHogs, $nbSides, 1, 1, 1] _
						, [$eWiza, $nbSides, 1, 1, 0] _
						, [$eSWiza, $nbSides, 1, 1, 0] _
						, [$eMini, $nbSides, 1, 1, 0] _
						, [$eSMini, $nbSides, 1, 1, 0] _
						, [$eArch, $nbSides, 3, 3, 2] _
						, [$eSArch, $nbSides, 3, 3, 2] _
						, [$eGobl, $nbSides, 1, 1, 1] _
						, [$eSGobl, $nbSides, 1, 1, 1]]
		EndSwitch
	Else
		If $g_bDebugSetlog Then SetDebugLog("listdeploy standard for attack", $COLOR_DEBUG)
		Switch $g_aiAttackStdDropOrder[$g_iMatchMode]
			Case 0
				Local $listInfoDeploy[45][5] = [[$eGole, $nbSides, 1, 1, 2] _
							, [$eLava, $nbSides, 1, 1, 2] _
							, [$eIceH, $nbSides, 1, 1, 2] _
							, [$eIceG, $nbSides, 1, 1, 2] _
							, [$eYeti, $nbSides, 1, 1, 2] _
							, [$eGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
							, [$eSGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
							, [$eGSkel, $nbSides, 1, 1, 0] _
							, [$eRGhost, $nbSides, 1, 1, 0] _
							, [$eDrag, $nbSides, 1, 1, 0] _
							, [$eSDrag, $nbSides, 1, 1, 0] _
							, [$eBall, $nbSides, 1, 1, 0] _
							, [$eRBall, $nbSides, 1, 1, 0] _
							, [$eBabyD, $nbSides, 1, 1, 0] _
							, [$eInfernoD, $nbSides, 1, 1, 0] _
							, [$eHogs, $nbSides, 1, 1, 1] _
							, [$eValk, $nbSides, 1, 1, 0] _
							, [$eSValk, $nbSides, 1, 1, 0] _
							, [$eBowl, $nbSides, 1, 1, 0] _
							, [$eSBowl, $nbSides, 1, 1, 0] _
							, [$eMine, $nbSides, 1, 1, 0] _
							, [$eEDrag, $nbSides, 1, 1, 0] _
							, [$eRDrag, $nbSides, 1, 1, 0] _
							, [$eETitan, $nbSides, 1, 1, 0] _
							, [$eWall, $nbSides, 1, 1, 1] _
							, [$eSWall, $nbSides, 1, 1, 1] _
							, [$eBarb, $nbSides, 1, 1, 0] _
							, [$eSBarb, $nbSides, 1, 1, 0] _
							, [$eArch, $nbSides, 1, 1, 0] _
							, [$eSArch, $nbSides, 1, 1, 0] _
							, [$eWiza, $nbSides, 1, 1, 0] _
							, [$eSWiza, $nbSides, 1, 1, 0] _
							, [$ePWiza, $nbSides, 1, 1, 0] _
							, [$eIWiza, $nbSides, 1, 1, 0] _
							, [$eMini, $nbSides, 1, 1, 0] _
							, [$eSMini, $nbSides, 1, 1, 0] _
							, [$eWitc, $nbSides, 1, 1, 1] _
							, [$eSWitc, $nbSides, 1, 1, 1] _
							, [$eGobl, $nbSides, 1, 1, 0] _
							, [$eSGobl, $nbSides, 1, 1, 0] _
							, [$eHeal, $nbSides, 1, 1, 1] _
							, [$ePekk, $nbSides, 1, 1, 1] _
							, [$eHunt, $nbSides, 1, 1, 0] _
							, ["CC", 1, 1, 1, 1] _
							, ["HEROES", 1, 2, 1, 1]]
				If $g_bCustomDropOrderEnable Then
					Local $aTmpDelete
					Local $aTmpListInfoDeploy = $listInfoDeploy
					;AttackSmartFarm(4, "TL|BR|BL|TR")
					;_ArrayDisplay($aTmpListInfoDeploy, "aTmpListInfoDeploy1")
					For $i = 0 To UBound($g_ahCmbDropOrder) - 1
						Local $iValue = $g_aiCmbCustomDropOrder[$i]
						SetLog("iValue : " & $iValue)
						If $iValue <> -1 Then
							Local $iDelete = _ArraySearch($aTmpListInfoDeploy, $iValue, 0, 0, 0, 0, 1, 0)
							SetLog("iDelete : " & $iDelete)
							Local $troop = $aTmpListInfoDeploy[$i][0]
							Local $nside1 = $aTmpListInfoDeploy[$i][1]
							Local $wave = $aTmpListInfoDeploy[$i][2]
							Local $x = $aTmpListInfoDeploy[$i][3]
							Local $slotedge = $aTmpListInfoDeploy[$i][4]
							
							$aTmpListInfoDeploy[$i][0] = $aTmpListInfoDeploy[$iDelete][0]
							$aTmpListInfoDeploy[$i][1] = $aTmpListInfoDeploy[$iDelete][1]
							$aTmpListInfoDeploy[$i][2] = $aTmpListInfoDeploy[$iDelete][2]
							$aTmpListInfoDeploy[$i][3] = $aTmpListInfoDeploy[$iDelete][3]
							$aTmpListInfoDeploy[$i][4] = $aTmpListInfoDeploy[$iDelete][4]
							
							$aTmpListInfoDeploy[$iDelete][0] = $troop
							$aTmpListInfoDeploy[$iDelete][1] = $nside1
							$aTmpListInfoDeploy[$iDelete][2] = $wave
							$aTmpListInfoDeploy[$iDelete][3] = $x
							$aTmpListInfoDeploy[$iDelete][4] = $slotedge
						EndIf
					Next
					$listInfoDeploy = $aTmpListInfoDeploy
				EndIf
			Case 1
				Local $listInfoDeploy[10][5] = [[$eBarb, $nbSides, 1, 1, 0] _
						, [$eSBarb, $nbSides, 1, 1, 0] _
						, [$eArch, $nbSides, 1, 1, 0] _
						, [$eSArch, $nbSides, 1, 1, 0] _
						, [$eGobl, $nbSides, 1, 1, 0] _
						, [$eSGobl, $nbSides, 1, 1, 0] _
						, [$eMini, $nbSides, 1, 1, 0] _
						, [$eSMini, $nbSides, 1, 1, 0] _
						, ["CC", 1, 1, 1, 1] _
						, ["HEROES", 1, 2, 1, 1]]
			Case 2
				Local $listInfoDeploy[23][5] = [[$eGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
						, [$eSGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
						, ["CC", 1, 1, 1, 1] _
						, [$eBarb, $nbSides, 1, 2, 0] _
						, [$eSBarb, $nbSides, 1, 2, 0] _
						, [$eWall, $nbSides, 1, 1, 1] _
						, [$eSWall, $nbSides, 1, 1, 1] _
						, [$eArch, $nbSides, 1, 2, 0] _
						, [$eSArch, $nbSides, 1, 2, 0] _
						, [$eBarb, $nbSides, 2, 2, 0] _
						, [$eSBarb, $nbSides, 2, 2, 0] _
						, [$eGobl, $nbSides, 1, 2, 0] _
						, [$eSGobl, $nbSides, 1, 2, 0] _
						, [$eHogs, $nbSides, 1, 1, 1] _
						, [$eWiza, $nbSides, 1, 1, 0] _
						, [$eSWiza, $nbSides, 1, 1, 0] _
						, [$eMini, $nbSides, 1, 1, 0] _
						, [$eSMini, $nbSides, 1, 1, 0] _
						, [$eArch, $nbSides, 2, 2, 0] _
						, [$eSArch, $nbSides, 2, 2, 0] _
						, [$eGobl, $nbSides, 2, 2, 0] _
						, [$eSGobl, $nbSides, 2, 2, 0] _
						, ["HEROES", 1, 2, 1, 1]]
			Case Else
				SetLog("Algorithm type unavailable, defaulting to regular", $COLOR_ERROR)
				Local $listInfoDeploy[23][5] = [[$eGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
						, [$eSGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
						, ["CC", 1, 1, 1, 1] _
						, [$eBarb, $nbSides, 1, 2, 0] _
						, [$eSBarb, $nbSides, 1, 2, 0] _
						, [$eWall, $nbSides, 1, 1, 1] _
						, [$eSWall, $nbSides, 1, 1, 1] _
						, [$eArch, $nbSides, 1, 2, 0] _
						, [$eSArch, $nbSides, 1, 2, 0] _
						, [$eBarb, $nbSides, 2, 2, 0] _
						, [$eSBarb, $nbSides, 2, 2, 0] _
						, [$eGobl, $nbSides, 1, 2, 0] _
						, [$eSGobl, $nbSides, 1, 2, 0] _
						, [$eHogs, $nbSides, 1, 1, 1] _
						, [$eWiza, $nbSides, 1, 1, 0] _
						, [$eSWiza, $nbSides, 1, 1, 0] _
						, [$eMini, $nbSides, 1, 1, 0] _
						, [$eSMini, $nbSides, 1, 1, 0] _
						, [$eArch, $nbSides, 2, 2, 0] _
						, [$eSArch, $nbSides, 2, 2, 0] _
						, [$eGobl, $nbSides, 2, 2, 0] _
						, [$eSGobl, $nbSides, 2, 2, 0] _
						, ["HEROES", 1, 2, 1, 1]]
		EndSwitch
	EndIf

	$g_bIsCCDropped = False
	$g_aiDeployCCPosition[0] = -1
	$g_aiDeployCCPosition[1] = -1
	$g_bIsHeroesDropped = False
	$g_aiDeployHeroesPosition[0] = -1
	$g_aiDeployHeroesPosition[1] = -1

	LaunchTroop2($listInfoDeploy, $g_iClanCastleSlot, $g_iKingSlot, $g_iQueenSlot, $g_iWardenSlot, $g_iChampionSlot)

	CheckHeroesHealth()

	If _Sleep($DELAYALGORITHM_ALLTROOPS4) Then Return
	SetLog("Dropping left over troops", $COLOR_INFO)
	For $x = 0 To 1
		If PrepareAttack($g_iMatchMode, True) = 0 Then
			SetDebugLog("No Wast time... exit, no troops usable left", $COLOR_DEBUG)
			ExitLoop ;Check remaining quantities
		EndIf
		For $i = $eBarb To $eHunt ; launch all remaining troops
			If LaunchTroop($i, $nbSides, 1, 1, 1) Then
				CheckHeroesHealth()
				If _Sleep($DELAYALGORITHM_ALLTROOPS5) Then Return
			EndIf
		Next
	Next

	CheckHeroesHealth()
	SetLog("Finished Attacking, waiting for the battle to end")
EndFunc   ;==>algorithm_AllTroops

Func SetSlotSpecialTroops()
	$g_iKingSlot = -1
	$g_iQueenSlot = -1
	$g_iWardenSlot = -1
	$g_iChampionSlot = -1
	$g_iClanCastleSlot = -1

	For $i = 0 To UBound($g_avAttackTroops) - 1
		If $g_avAttackTroops[$i][0] = $eCastle Or $g_avAttackTroops[$i][0] = $eWallW Or $g_avAttackTroops[$i][0] = $eBattleB Or $g_avAttackTroops[$i][0] = $eStoneS _ 
								Or $g_avAttackTroops[$i][0] = $eSiegeB Or $g_avAttackTroops[$i][0] = $eLogL Or $g_avAttackTroops[$i][0] = $eFlameF Or $g_avAttackTroops[$i][0] = $eBattleD Then
			$g_iClanCastleSlot = $i
		ElseIf $g_avAttackTroops[$i][0] = $eKing Then
			$g_iKingSlot = $i
		ElseIf $g_avAttackTroops[$i][0] = $eQueen Then
			$g_iQueenSlot = $i
		ElseIf $g_avAttackTroops[$i][0] = $eWarden Then
			$g_iWardenSlot = $i
		ElseIf $g_avAttackTroops[$i][0] = $eChampion Then
			$g_iChampionSlot = $i
		EndIf
	Next

	If $g_bDebugSetlog Then
		SetDebugLog("SetSlotSpecialTroops() King Slot: " & $g_iKingSlot, $COLOR_DEBUG)
		SetDebugLog("SetSlotSpecialTroops() Queen Slot: " & $g_iQueenSlot, $COLOR_DEBUG)
		SetDebugLog("SetSlotSpecialTroops() Warden Slot: " & $g_iWardenSlot, $COLOR_DEBUG)
		SetDebugLog("SetSlotSpecialTroops() Champion Slot: " & $g_iChampionSlot, $COLOR_DEBUG)
		SetDebugLog("SetSlotSpecialTroops() Clan Castle Slot: " & $g_iClanCastleSlot, $COLOR_DEBUG)
	EndIf

EndFunc   ;==>SetSlotSpecialTroops

Func CloseBattle()
	If IsAttackPage() Then
		For $i = 1 To 30
			;_CaptureRegion()
			If _ColorCheck(_GetPixelColor($aWonOneStar[0], $aWonOneStar[1], True), Hex($aWonOneStar[2], 6), $aWonOneStar[3]) = True Then ExitLoop ;exit if not 'no star'
			If _Sleep($DELAYALGORITHM_ALLTROOPS2) Then Return
		Next
	EndIf

	If IsAttackPage() Then ClickP($aSurrenderButton, 1, 0, "#0030") ;Click Surrender
	If _Sleep($DELAYALGORITHM_ALLTROOPS3) Then Return
	If IsOKCancelPage() Then
		ClickP($aConfirmSurrender, 1, 0, "#0031") ;Click Confirm
		If _Sleep($DELAYALGORITHM_ALLTROOPS1) Then Return
	EndIf

EndFunc   ;==>CloseBattle


Func SmartAttackStrategy($imode)
		If ($g_abAttackStdSmartAttack[$imode]) Then
			SetLog("Calculating Smart Attack Strategy", $COLOR_INFO)
			Local $hTimer = __TimerInit()
			_CaptureRegion2()
			_GetRedArea()

			SetLog("Calculated  (in " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds) :")

			If ($g_abAttackStdSmartNearCollectors[$imode][0] Or $g_abAttackStdSmartNearCollectors[$imode][1] Or $g_abAttackStdSmartNearCollectors[$imode][2]) Then
				SetLog("Locating Mines, Collectors & Drills", $COLOR_INFO)
				$hTimer = __TimerInit()
				Global $g_aiPixelMine[0]
				Global $g_aiPixelElixir[0]
				Global $g_aiPixelDarkElixir[0]
				Global $g_aiPixelNearCollector[0]
				; If drop troop near gold mine
				If $g_abAttackStdSmartNearCollectors[$imode][0] Then
					$g_aiPixelMine = GetLocationMine()
					If (IsArray($g_aiPixelMine)) Then
						_ArrayAdd($g_aiPixelNearCollector, $g_aiPixelMine, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
					EndIf
				EndIf
				; If drop troop near elixir collector
				If $g_abAttackStdSmartNearCollectors[$imode][1] Then
					$g_aiPixelElixir = GetLocationElixir()
					If (IsArray($g_aiPixelElixir)) Then
						_ArrayAdd($g_aiPixelNearCollector, $g_aiPixelElixir, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
					EndIf
				EndIf
				; If drop troop near dark elixir drill
				If $g_abAttackStdSmartNearCollectors[$imode][2] Then
					$g_aiPixelDarkElixir = GetLocationDarkElixir()
					If (IsArray($g_aiPixelDarkElixir)) Then
						_ArrayAdd($g_aiPixelNearCollector, $g_aiPixelDarkElixir, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
					EndIf
				EndIf
				SetLog("Located  (in " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds) :")
				SetLog("[" & UBound($g_aiPixelMine) & "] Gold Mines")
				SetLog("[" & UBound($g_aiPixelElixir) & "] Elixir Collectors")
				SetLog("[" & UBound($g_aiPixelDarkElixir) & "] Dark Elixir Drill/s")
				$g_aiNbrOfDetectedMines[$imode] += UBound($g_aiPixelMine)
				$g_aiNbrOfDetectedCollectors[$imode] += UBound($g_aiPixelElixir)
				$g_aiNbrOfDetectedDrills[$imode] += UBound($g_aiPixelDarkElixir)
				UpdateStats()
			EndIf

		EndIf
EndFunc   ;==>SmartAttackStrategy
