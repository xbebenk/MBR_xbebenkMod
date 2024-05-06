; #FUNCTION# ====================================================================================================================
; Name ..........: getArmyTroopCapacity
; Description ...: Obtains current and total capacity of troops from Training - Army Overview window
; Syntax ........: getArmyTroopCapacity([$bOpenArmyWindow = False[, $bCloseArmyWindow = False]])
; Parameters ....: $bOpenArmyWindow     - [optional] a boolean value. Default is False.
;                  $bCloseArmyWindow    - [optional] a boolean value. Default is False.
; Return values .: None
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func getArmyTroopCapacity($bOpenArmyWindow = False, $bCloseArmyWindow = False, $bCheckWindow = True, $bSetLog = True, $bNeedCapture = True)

	If $g_bDebugSetlogTrain Then SetLog("getArmyTroopsCapacity():", $COLOR_DEBUG1)

	If $bCheckWindow Then
		If Not $bOpenArmyWindow And Not IsTrainPage() Then ; check for train page
			SetError(1)
			Return ; not open, not requested to be open - error.
		ElseIf $bOpenArmyWindow Then
			If Not OpenArmyOverview("getArmyTroopCapacity()") Then
				SetError(2)
				Return ; not open, requested to be open - error.
			EndIf
			If _Sleep($DELAYCHECKARMYCAMP5) Then Return
		EndIf
	EndIf

	Local $aGetArmyCap[3] = ["", "", ""]
	Local $sArmyInfo = ""
	Local $iCount = 0
	Local $sInputbox, $iHoldCamp
	Local $tmpTotalCamp = 0
	Local $tmpCurCamp = 0

	While $iCount < 50 ;25-30 sec
		$iCount += 1
		$sArmyInfo = getArmyCampCap(155, 170) ; OCR read army trained and total
		If $g_bDebugSetlog Then SetLog("OCR $sArmyInfo = " & $sArmyInfo, $COLOR_DEBUG)
		If StringInStr($sArmyInfo, "#", 0, 1) < 2 Then ContinueLoop ; In case the CC donations recieved msg are blocking, need to keep checking numbers till valid

		$aGetArmyCap = StringSplit($sArmyInfo, "#") ; split the trained troop number from the total troop number
		If IsArray($aGetArmyCap) Then
			If $aGetArmyCap[0] > 1 Then ; check if the OCR was valid and returned both values
				If Number($aGetArmyCap[2]) < 10 Or Mod(Number($aGetArmyCap[2]), 5) <> 0 Then ; check to see if camp size is multiple of 5, or try to read again
					If $g_bDebugSetlog Then SetLog(" OCR value is not valid camp size", $COLOR_DEBUG)
					ContinueLoop
				EndIf
				$tmpCurCamp = Number($aGetArmyCap[1])
				If $g_bDebugSetlog Then SetLog("$tmpCurCamp = " & $tmpCurCamp, $COLOR_DEBUG)
				$tmpTotalCamp = Number($aGetArmyCap[2])
				If $g_bDebugSetlog Then SetLog("$g_iTotalCampSpace = " & $g_iTotalCampSpace & ", Camp OCR = " & $tmpTotalCamp, $COLOR_DEBUG)
				If $iHoldCamp = $tmpTotalCamp Then ExitLoop ; check to make sure the OCR read value is same in 2 reads before exit
				$iHoldCamp = $tmpTotalCamp ; Store last OCR read value
			EndIf
		EndIf
		If _Sleep(500) Then Return ; Wait 500ms before reading again
	WEnd

	If $iCount <= 50 Then
		$g_CurrentCampUtilization = $tmpCurCamp
		If $g_iTotalCampSpace <> $tmpTotalCamp Then $g_iTotalCampSpace = $tmpTotalCamp
		
		If $g_bDebugSetlog Then SetLog("$g_CurrentCampUtilization = " & $g_CurrentCampUtilization & ", $g_iTotalCampSpace = " & $g_iTotalCampSpace, $COLOR_DEBUG)
	Else
		SetLog("Army size read error, Troop numbers may not train correctly", $COLOR_ERROR) ; log if there is read error
		$g_CurrentCampUtilization = 0
		CheckOverviewFullArmy()
	EndIf
	
	Local $iTrainCount1 = 0, $iTrainCount2 = 0
	For $i = 0 To UBound($g_aiArmyCustomTroops) - 1
		$iTrainCount1 += $g_aiArmyCustomTroops[$i]
		$iTrainCount2 += $g_aiArmyCompTroops[$i]
	Next
	
	If $iTrainCount1 = 0 Or $iTrainCount2 = 0 Then 
		SetLog("Impossible!! Your train settings got reset!", $COLOR_ERROR)
		$g_bRunState = False
		If _Sleep(50) Then Return
		Btnstop()
	EndIf

	If $g_iTotalCampForcedValue < $g_iTotalCampSpace Then ; if Total camp size is still not set or value not same as read use forced value
		Local $iTmpIndex = 0, $iTroopSpace = 0, $iTrainBefore = 0
		SetLog("ArmyCamp Size Setting = " & $g_iTotalCampForcedValue & ", CurrentCamp = " & $g_iTotalCampSpace, $COLOR_DEBUG)
		SetLog("Searching enabled train Troop with trainspace = 1 or 5", $COLOR_ACTION)
		
		For $i = 0 To UBound($g_aiArmyCustomTroops) - 1
			If $g_aiArmyCustomTroops[$i] > 0 Then 
				If $g_aiTroopSpace[$i] = 1 Or $g_aiTroopSpace[$i] = 5 Then
					$iTmpIndex = $i
					$iTroopSpace = $g_aiTroopSpace[$i]
					$iTrainBefore = $g_aiArmyCustomTroops[$i]
					ExitLoop
				EndIf
			EndIf
		Next
		
		If $g_bIgnoreIncorrectTroopCombo Then 
			$iTmpIndex = TroopIndexLookup($g_sCmbFICTroops[$g_iCmbFillIncorrectTroopCombo][0])
			$iTroopSpace = $g_sCmbFICTroops[$g_iCmbFillIncorrectTroopCombo][2]
			$iTrainBefore = $g_aiArmyCustomTroops[$iTmpIndex]
			SetLog("IgnoreIncorrectTroopCombo Enabled")
			SetLog("Forced Fill with [" & GetTroopName($iTmpIndex) & "] space = " & $iTroopSpace, $COLOR_DEBUG1)
		Else
			SetLog("Set Troop Train Setting Fill with " & GetTroopName($iTmpIndex), $COLOR_DEBUG1)
			SetLog("[" & GetTroopName($iTmpIndex) & "] space = " & $iTroopSpace, $COLOR_INFO)
		EndIf
		
		If $iTroopSpace = 1 Then 
			For $i = $g_iTotalCampForcedValue To $g_iTotalCampSpace - 1
				$g_aiArmyCustomTroops[$iTmpIndex] += 1
			Next
		EndIf
		
		If $iTroopSpace = 5 Then 
			Local $iloop = ($g_iTotalCampSpace - $g_iTotalCampForcedValue) / 5
			For $i = 1 To $iloop
				$g_aiArmyCustomTroops[$iTmpIndex] += 1
			Next
		EndIf
		
		SetLog("[" & GetTroopName($iTmpIndex) & "] Train = " & $iTrainBefore & ", Change To = " & $g_aiArmyCustomTroops[$iTmpIndex], $COLOR_SUCCESS)
		SetLog("Set ArmyCamp Size, Before : " & $g_iTotalCampForcedValue & ", Change To : " & $g_iTotalCampSpace, $COLOR_SUCCESS)
		
		$g_iTotalCampForcedValue = Number($g_iTotalCampSpace) ;set new value
		GUICtrlSetData($g_hTxtTotalCampForced, $g_iTotalCampForcedValue) ;update new value to gui
		$g_aiArmyCompTroops = $g_aiArmyCustomTroops ;copy new train value
		
		ApplyConfig_600_52_2("Read")
		SetComboTroopComp() ; GUI refresh
		SetLog("ArmyTroop settings Change applied", $COLOR_SUCCESS)
		ApplyConfig_600_52_2("Save")
	EndIf
	
	If $g_iTotalCampSpace > 0 Then
		If $bSetLog Then SetLog("Total Army Camp Capacity: " & $g_CurrentCampUtilization & "/" & $g_iTotalCampSpace & " (" & Int($g_CurrentCampUtilization / $g_iTotalCampSpace * 100) & "%)")
		$g_iArmyCapacity = Int($g_CurrentCampUtilization / $g_iTotalCampSpace * 100)
	Else
		If $bSetLog Then SetLog("Total Army Camp Capacity: " & $g_CurrentCampUtilization & "/" & $g_iTotalCampSpace)
		$g_iArmyCapacity = 0
	EndIf

	If ($g_CurrentCampUtilization >= ($g_iTotalCampSpace * $g_iTrainArmyFullTroopPct / 100)) Then
		$g_bFullArmy = True
	Else
		$g_bFullArmy = False
		$g_bIsFullArmywithHeroesAndSpells = False
	EndIf

	If $g_CurrentCampUtilization >= $g_iTotalCampSpace * $g_aiSearchCampsPct[$DB] / 100 And $g_abSearchCampsEnable[$DB] And IsSearchModeActive($DB) Then $g_bFullArmy = True
	If $g_CurrentCampUtilization >= $g_iTotalCampSpace * $g_aiSearchCampsPct[$LB] / 100 And $g_abSearchCampsEnable[$LB] And IsSearchModeActive($LB) Then $g_bFullArmy = True

	If $bCloseArmyWindow Then
		ClickAway()
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf

EndFunc   ;==>getArmyTroopCapacity
