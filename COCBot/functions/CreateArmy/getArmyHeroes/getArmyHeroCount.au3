; #FUNCTION# ====================================================================================================================
; Name ..........: getArmyHeroCount
; Description ...: Obtains count of heroes available from Training - Army Overview window
; Syntax ........: getArmyHeroCount()
; Parameters ....: $bOpenArmyWindow  = Bool value true if train overview window needs to be opened
;				 : $bCloseArmyWindow = Bool value, true if train overview window needs to be closed
; Return values .: None
; Author ........:
; Modified ......: MonkeyHunter (06-2016), MR.ViPER (10-2016), Fliegerfaust (03-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func getArmyHeroCount($bOpenArmyWindow = False, $bCloseArmyWindow = False, $CheckWindow = True, $bSetLog = True)

	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Begin getArmyHeroCount:", $COLOR_DEBUG)

	If $CheckWindow Then
		If Not $bOpenArmyWindow And Not IsTrainPage() Then ; check for train page
			SetError(1)
			Return ; not open, not requested to be open - error.
		ElseIf $bOpenArmyWindow Then
			If Not OpenArmyOverview(True, "getArmyHeroCount()") Then
				SetError(2)
				Return ; not open, requested to be open - error.
			EndIf
			If _Sleep($DELAYCHECKARMYCAMP5) Then Return
		EndIf
	EndIf

	$g_iHeroAvailable = $eHeroNone ; Reset hero available data
	Local $iDebugArmyHeroCount = 0 ; local debug flag

	; Detection by OCR
	Local $sResult
	Local $sMessage = ""

	For $i = 0 To $eHeroCount - 1
		$sResult = ArmyHeroStatus($i)
		If $sResult <> "" Then ; we found something, figure out what?
			Select
				Case StringInStr($sResult, "king", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog(" - Barbarian King Available", $COLOR_SUCCESS)
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroKing)
					; unset King upgrading
					$g_iHeroUpgrading[0] = 0
					$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroQueen,$eHeroWarden,$eHeroChampion))
				Case StringInStr($sResult, "queen", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog(" - Archer Queen Available", $COLOR_SUCCESS)
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroQueen)
					; unset Queen upgrading
					$g_iHeroUpgrading[1] = 0
					$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroWarden,$eHeroChampion))
				Case StringInStr($sResult, "warden", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog(" - Grand Warden Available", $COLOR_SUCCESS)
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroWarden)
					; unset Warden upgrading
					$g_iHeroUpgrading[2] = 0
					$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroQueen,$eHeroChampion))
				Case StringInStr($sResult, "champion", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog(" - Royal Champion Available", $COLOR_SUCCESS)
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroChampion)
					; unset Champion upgrading
					$g_iHeroUpgrading[3] = 0
					$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroQueen,$eHeroWarden))
				Case StringInStr($sResult, "heal", $STR_NOCASESENSEBASIC)
					If $g_bDebugSetlogTrain Or $iDebugArmyHeroCount = 1 Then
						Switch $i
							Case 0
								$sMessage = "-Barbarian King"
								; unset King upgrading
								$g_iHeroUpgrading[0] = 0
								$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroQueen,$eHeroWarden,$eHeroChampion))
							Case 1
								$sMessage = "-Archer Queen"
								; unset Queen upgrading
								$g_iHeroUpgrading[1] = 0
								$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroWarden,$eHeroChampion))
							Case 2
								$sMessage = "-Grand Warden"
								; unset Warden upgrading
								$g_iHeroUpgrading[2] = 0
								$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroQueen,$eHeroChampion))
							Case 3
								$sMessage = "-Royal Champion"
								; unset Champion upgrading
								$g_iHeroUpgrading[3] = 0
								$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroQueen,$eHeroWarden))
							Case Else
								$sMessage = "-Very Bad Monkey Needs"
						EndSwitch
						SetLog("Hero slot#" & $i + 1 & $sMessage & " Healing", $COLOR_DEBUG)
					EndIf
				Case StringInStr($sResult, "upgrade", $STR_NOCASESENSEBASIC)
					Switch $i
						Case 0
							$sMessage = "-Barbarian King"
							; set King upgrading
							$g_iHeroUpgrading[0] = 1
							$g_iHeroUpgradingBit = BitOR($g_iHeroUpgradingBit, $eHeroKing)
							; safety code to warn user when wait for hero found while being upgraded to reduce stupid user posts for not attacking
							If ($g_abAttackTypeEnable[$DB] And BitAND($g_aiAttackUseHeroes[$DB], $g_aiSearchHeroWaitEnable[$DB], $eHeroKing) = $eHeroKing) Or _
									($g_abAttackTypeEnable[$LB] And BitAND($g_aiAttackUseHeroes[$LB], $g_aiSearchHeroWaitEnable[$LB], $eHeroKing) = $eHeroKing) Then ; check wait for hero status
								If $g_iSearchNotWaitHeroesEnable Then
									$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroKing)
								EndIf
								_GUI_Value_STATE("SHOW", $groupKingSleeping) ; Show king sleeping icon
							EndIf
						Case 1
							$sMessage = "-Archer Queen"
							; set Queen upgrading
							$g_iHeroUpgrading[1] = 1
							$g_iHeroUpgradingBit = BitOR($g_iHeroUpgradingBit, $eHeroQueen)
							; safety code
							If ($g_abAttackTypeEnable[$DB] And BitAND($g_aiAttackUseHeroes[$DB], $g_aiSearchHeroWaitEnable[$DB], $eHeroQueen) = $eHeroQueen) Or _
									($g_abAttackTypeEnable[$LB] And BitAND($g_aiAttackUseHeroes[$LB], $g_aiSearchHeroWaitEnable[$LB], $eHeroQueen) = $eHeroQueen) Then
								If $g_iSearchNotWaitHeroesEnable Then
									$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroQueen)
								EndIf
								_GUI_Value_STATE("SHOW", $groupQueenSleeping) ; Show Queen sleeping icon
							EndIf
						Case 2
							$sMessage = "-Grand Warden"
							; set Warden upgrading
							$g_iHeroUpgrading[2] = 1
							$g_iHeroUpgradingBit = BitOR($g_iHeroUpgradingBit, $eHeroWarden)
							; safety code
							If ($g_abAttackTypeEnable[$DB] And BitAND($g_aiAttackUseHeroes[$DB], $g_aiSearchHeroWaitEnable[$DB], $eHeroWarden) = $eHeroWarden) Or _
									($g_abAttackTypeEnable[$LB] And BitAND($g_aiAttackUseHeroes[$LB], $g_aiSearchHeroWaitEnable[$LB], $eHeroWarden) = $eHeroWarden) Then
								If $g_iSearchNotWaitHeroesEnable Then
									$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroWarden)
								EndIf
								_GUI_Value_STATE("SHOW", $groupWardenSleeping) ; Show Warden sleeping icon
							EndIf
						Case 3
							$sMessage = "-Royal Champion"
							; set Champion upgrading
							$g_iHeroUpgrading[3] = 1
							$g_iHeroUpgradingBit = BitOR($g_iHeroUpgradingBit, $eHeroChampion)
							; safety code
							If ($g_abAttackTypeEnable[$DB] And BitAND($g_aiAttackUseHeroes[$DB], $g_aiSearchHeroWaitEnable[$DB], $eHeroChampion) = $eHeroChampion) Or _
									($g_abAttackTypeEnable[$LB] And BitAND($g_aiAttackUseHeroes[$LB], $g_aiSearchHeroWaitEnable[$LB], $eHeroChampion) = $eHeroChampion) Then
								If $g_iSearchNotWaitHeroesEnable Then
									$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroChampion)
								EndIf
								_GUI_Value_STATE("SHOW", $groupChampionSleeping) ; Show Champion sleeping icon
							EndIf
						Case Else
							$sMessage = "-Need to Feed Code Monkey some bananas"
					EndSwitch
					If $g_bDebugSetlogTrain Or $iDebugArmyHeroCount = 1 Then SetLog("Hero slot#" & $i + 1 & $sMessage & " Upgrade in Process", $COLOR_DEBUG)
				Case StringInStr($sResult, "none", $STR_NOCASESENSEBASIC)
					If $g_bDebugSetlogTrain Or $iDebugArmyHeroCount = 1 Then SetLog("Hero slot#" & $i + 1 & " Empty, stop count", $COLOR_DEBUG)
						SetDebugLog("$g_iHeroAvailable = " & $g_iHeroAvailable, $COLOR_DEBUG)
						Switch $i
							Case 0
								$sMessage = "-Barbarian King"
								$g_iHeroAvailable += $eHeroKing
							Case 1
								$sMessage = "-Archer Queen"
								$g_iHeroAvailable += $eHeroQueen
							Case 2
								$sMessage = "-Grand Warden"
								$g_iHeroAvailable += $eHeroWarden
							Case 3
								$sMessage = "-Royal Champion"
								$g_iHeroAvailable += $eHeroChampion
							Case Else
								$sMessage = "-Very Bad Monkey Needs"
						EndSwitch
						SetDebugLog("Adding value to $g_iHeroAvailable, Now = " & $g_iHeroAvailable, $COLOR_DEBUG) ;we add available hero because its not unlocked yet
					ExitLoop ; when we find empty slots, done looking for heroes
				Case Else
					If $bSetLog Then SetLog("Hero slot#" & $i + 1 & " bad OCR string returned!", $COLOR_ERROR)
			EndSelect
		Else
			If $bSetLog Then SetLog("Hero slot#" & $i + 1 & " status read problem!", $COLOR_ERROR)
		EndIf
	Next

	If $g_bDebugSetlogTrain Or $iDebugArmyHeroCount = 1 Then SetLog("Hero Status  K|Q|W|C : " & BitAND($g_iHeroAvailable, $eHeroKing) & "|" & BitAND($g_iHeroAvailable, $eHeroQueen) & "|" & BitAND($g_iHeroAvailable, $eHeroWarden) & "|" & BitAND($g_iHeroAvailable, $eHeroChampion), $COLOR_DEBUG)
	If $g_bDebugSetlogTrain Or $iDebugArmyHeroCount = 1 Then SetLog("Hero Upgrade K|Q|W|C : " & BitAND($g_iHeroUpgradingBit, $eHeroKing) & "|" & BitAND($g_iHeroUpgradingBit, $eHeroQueen) & "|" & BitAND($g_iHeroUpgradingBit, $eHeroWarden) & "|" & BitAND($g_iHeroUpgradingBit, $eHeroChampion), $COLOR_DEBUG)

	If $bCloseArmyWindow Then
		ClickAway()
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf

EndFunc   ;==>getArmyHeroCount

Func ArmyHeroStatus($i)
	Local $sResult = ""
	Local Const $aHeroesRect[$eHeroCount][4] = [[540, 310, 615, 380], [618, 310, 690, 380], [695, 310, 763, 380], [765, 310, 840, 380]] ; Review

	; Perform the search
	If QuickMIS("BC1", $g_sImgArmyOverviewHeroes, $aHeroesRect[$i][0], $aHeroesRect[$i][1], $aHeroesRect[$i][2], $aHeroesRect[$i][3]) Then
		$sResult = $g_iQuickMISName
		SetDebugLog($sResult)
		Select
			Case $i = 0
				Switch $sResult
					Case "heal" ; Blue
						GUICtrlSetState($g_hPicKingGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingBlue, $GUI_SHOW)
					Case "upgrade" ; Red
						GUICtrlSetState($g_hPicKingGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingRed, $GUI_SHOW)
					Case "king" ; Green
						GUICtrlSetState($g_hPicKingGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingGreen, $GUI_SHOW)
				EndSwitch

			Case $i = 1
				Switch $sResult
					Case "heal" ; Blue
						GUICtrlSetState($g_hPicQueenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenBlue, $GUI_SHOW)
					Case "upgrade" ; Red
						GUICtrlSetState($g_hPicQueenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenRed, $GUI_SHOW)
					Case "queen" ; Green
						GUICtrlSetState($g_hPicQueenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenGreen, $GUI_SHOW)
				EndSwitch

			Case $i = 2
				Switch $sResult
					Case "heal" ; Blue
						GUICtrlSetState($g_hPicWardenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenBlue, $GUI_SHOW)
					Case "upgrade" ; Red
						GUICtrlSetState($g_hPicWardenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenRed, $GUI_SHOW)
					Case "warden" ; Green
						GUICtrlSetState($g_hPicWardenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenGreen, $GUI_SHOW)
				EndSwitch

			Case $i = 3
				Switch $sResult
					Case "heal" ; Blue
						GUICtrlSetState($g_hPicChampionGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionBlue, $GUI_SHOW)
					Case "upgrade" ; Red
						GUICtrlSetState($g_hPicChampionGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionRed, $GUI_SHOW)
					Case "Champion" ; Green
						GUICtrlSetState($g_hPicChampionGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionGreen, $GUI_SHOW)
				EndSwitch
		EndSelect
		Return $sResult
	EndIf
	
	;return 'none' if there was a problem with the search ; or no Hero slot
	Switch $i
		Case 0
			GUICtrlSetState($g_hPicKingGreen, $GUI_HIDE)
			GUICtrlSetState($g_hPicKingRed, $GUI_HIDE)
			GUICtrlSetState($g_hPicKingBlue, $GUI_HIDE)
			GUICtrlSetState($g_hPicKingGray, $GUI_SHOW)
			Return "none"
		Case 1
			GUICtrlSetState($g_hPicQueenGreen, $GUI_HIDE)
			GUICtrlSetState($g_hPicQueenRed, $GUI_HIDE)
			GUICtrlSetState($g_hPicQueenBlue, $GUI_HIDE)
			GUICtrlSetState($g_hPicQueenGray, $GUI_SHOW)
			Return "none"
		Case 2
			GUICtrlSetState($g_hPicWardenGreen, $GUI_HIDE)
			GUICtrlSetState($g_hPicWardenRed, $GUI_HIDE)
			GUICtrlSetState($g_hPicWardenBlue, $GUI_HIDE)
			GUICtrlSetState($g_hPicWardenGray, $GUI_SHOW)
			Return "none"
		Case 3
			GUICtrlSetState($g_hPicChampionGreen, $GUI_HIDE)
			GUICtrlSetState($g_hPicChampionRed, $GUI_HIDE)
			GUICtrlSetState($g_hPicChampionBlue, $GUI_HIDE)
			GUICtrlSetState($g_hPicChampionGray, $GUI_SHOW)
			Return "none"
	EndSwitch

EndFunc   ;==>ArmyHeroStatus

Func HideShields($bHide = False)
	If $bHide = True Then
		For $i = $g_hPicKingGray To $g_hLbLPetTime
			GUICtrlSetState($i, $GUI_HIDE)
		Next
	Else
		For $i = $g_hPicKingGray To $g_hLbLPetTime
			GUICtrlSetState($i, $GUI_SHOW )
		Next
	EndIf
EndFunc
