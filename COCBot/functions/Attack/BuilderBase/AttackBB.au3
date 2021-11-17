; #FUNCTION# ====================================================================================================================
; Name ..........: PrepareAttackBB
; Description ...: This file controls attacking preperation of the builders base
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Chilly-Chill (04-2019)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func DoAttackBB()
	If Not $g_bChkEnableBBAttack Then Return
	If $g_iBBAttackCount = 0 Then
		Local $count = 1
		While PrepareAttackBB()
			If Not $g_bRunState Then Return
			SetDebugLog("PrepareAttackBB(): Success.", $COLOR_SUCCESS)
			SetLog("Attack #" & $count & "/~", $COLOR_INFO)
			_AttackBB()
			If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
				SetLog("Check if ClanGames Challenge is Completed", $COLOR_DEBUG)
				For $x = 0 To 4
					_Sleep(1000)
					If QuickMIS("BC1", $g_sImgGameComplete, 760, 480, 820, 520, True, $g_bDebugImageSave) Then
						SetLog("Nice, Game Completed", $COLOR_INFO)
						ExitLoop 2
					EndIf
				Next
			EndIf
			If _Sleep($DELAYRUNBOT3) Then Return
			If checkObstacles(True) Then Return
			$count += 1
			If $count > 10 Then
				SetLog("Something May Wrong", $COLOR_INFO)
				SetLog("Already Attack 10 times", $COLOR_INFO)
				ExitLoop
			EndIf
		Wend

		SetLog("Skip Attack this time..", $COLOR_DEBUG)
		ClickAway("Left")
	Else
		For $i = 1 To $g_iBBAttackCount
			If Not $g_bRunState Then Return
			If PrepareAttackBB() Then
				SetDebugLog("PrepareAttackBB(): Success.", $COLOR_SUCCESS)
				SetLog("Attack #" & $i & "/" & $g_iBBAttackCount, $COLOR_INFO)
				_AttackBB()
				If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
					SetLog("Check if ClanGames Challenge is Completed", $COLOR_DEBUG)
					For $x = 0 To 4
						_Sleep(1000)
						If QuickMIS("BC1", $g_sImgGameComplete, 760, 480, 820, 520, True, $g_bDebugImageSave) Then
							SetLog("Nice, Game Completed", $COLOR_INFO)
							ExitLoop 2
						EndIf
					Next
				EndIf
				If _Sleep($DELAYRUNBOT3) Then Return
				If checkObstacles(True) Then Return
			Else
				ExitLoop
			EndIf
		Next
		SetLog("Skip Attack this time..", $COLOR_DEBUG)
		ClickAway()
	EndIf
	ZoomOut()
	SetLog("BB Attack Cycle Done", $COLOR_DEBUG)
EndFunc

Func _AttackBB()
	If Not $g_bRunState Then Return
	local $iSide = Random(0, 1, 1) ; randomly choose top left or top right
	local $aBMPos = 0

	SetLog("Going to attack.", $COLOR_BLUE)

	; search for a match
	If _Sleep(2000) Then Return
	local $aBBFindNow = [521, 278, 0xffc246, 30] ; search button
	If _CheckPixel($aBBFindNow, True) Then
		PureClick($aBBFindNow[0], $aBBFindNow[1])
	Else
		SetLog("Could not locate search button to go find an attack.", $COLOR_ERROR)
		Return False
	EndIf

	If _Sleep(1500) Then Return ; give time for find now button to go away

	If Not $g_bRunState Then Return ; Stop Button

	local $iAndroidSuspendModeFlagsLast = $g_iAndroidSuspendModeFlags
	$g_iAndroidSuspendModeFlags = 0 ; disable suspend and resume
	SetDebugLog("Android Suspend Mode Disabled")

	; wait for the clouds to clear
	SetLog("Searching for Opponent.", $COLOR_BLUE)
	local $timer = __TimerInit()
	local $iPrevTime = 0
	
	Static $aAttackerVersusBattle[2][3] = [[0xFFFF99, 0, 1], [0xFFFF99, 0, 2]]
	While _MultiPixelSearch(711, 2, 856, 55 + $g_iMidOffsetYNew, 1, 1, Hex(0xFFFF99, 6), $aAttackerVersusBattle, 15) = 0
		local $iTime = Int(__TimerDiff($timer)/ 60000)
		If $iTime > $iPrevTime Then ; if we have increased by a minute
			SetLog("Clouds: " & $iTime & "-Minute(s)")
			If $iTime > 2 Then Return ;xbebenk, prevent bot to long on cloud?, in fact BB attack should only takes seconds to search, if more there must be something no right
			$iPrevTime = $iTime
		EndIf
		If _Sleep($DELAYRESPOND) Then
			$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
			If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
			Return
		EndIf
		If _Sleep(2000) Then Return
		If Not $g_bRunState Then Return ; Stop Button
	WEnd

	; Get troops on attack bar and their quantities
	local $aBBAttackBar = GetAttackBarBB()
	If $g_bChkBBCustomArmyEnable Then BuilderBaseSelectCorrectScript($aBBAttackBar) ; xbebenk
	If _Sleep($DELAYRESPOND) Then
		$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
		If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
		Return
	EndIf
	
	If $g_BBBCSVAttack Then
		; Zoomout the Opponent Village.
		BuilderBaseZoomOut(False, True)
	
		; Correct script.
		BuilderBaseSelectCorrectScript($aBBAttackBar)
	
		Local $FurtherFrom = 5 ; 5 pixels before the deploy point.
		BuilderBaseGetDeployPoints($FurtherFrom, True)
	
		; Parse CSV , Deploy Troops and Get Machine Status [attack algorithm] , waiting for Battle ends window.
		BuilderBaseParseAttackCSV($aBBAttackBar, $g_aDeployPoints, $g_aDeployBestPoints, True)
	Else
		AttackBB($aBBAttackBar)
	Endif
	
	; wait for end of battle
	SetLog("Waiting for end of battle.", $COLOR_BLUE)
	If Not $g_bRunState Then Return ; Stop Button
	If Not OkayBBEnd() Then
		$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
		If $g_bDebugSetlog Then SetDebugLog("Android Suspend Mode Enabled")
		Return
	EndIf
	SetLog("Battle ended")
	If _Sleep(3000) Then
		$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
		If $g_bDebugSetlog Then SetDebugLog("Android Suspend Mode Enabled")
		Return
	EndIf

	; wait for ok after both attacks are finished
	If Not $g_bRunState Then Return ; Stop Button
	SetLog("Waiting for opponent", $COLOR_BLUE)
	Okay()
	ClickAway("Left")
	SetLog("Done", $COLOR_SUCCESS)

	$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast ; reset android suspend and resume stuff
	If $g_bDebugSetlog Then SetDebugLog("Android Suspend Mode Enabled")
EndFunc

Func AttackBB($aBBAttackBar = Default)
	; Get troops on attack bar and their quantities
	If $aBBAttackBar = Default Then $aBBAttackBar = GetAttackBarBB()
	local $iSide = Random(0, 1, 1) ; randomly choose top left or top right
	local $aBMPos = 0
	local $iAndroidSuspendModeFlagsLast = $g_iAndroidSuspendModeFlags
	local $bTroopsDropped = False, $bBMDeployed = False
	
	;Function uses this list of local variables...
	If $g_bChkBBDropBMFirst Then
		SetLog("Dropping BM First")
		$bBMDeployed = DeployBM($iSide)
	EndIf

	If Not $g_bRunState Then Return ; Stop Button
	
	; Deploy all troops
	;local $bTroopsDropped = False, $bBMDeployed = False
	SetLog( $g_bBBDropOrderSet = True ? "Deploying Troops in Custom Order." : "Deploying Troops in Order of Attack Bar.", $COLOR_BLUE)
	While Not $bTroopsDropped
		local $iNumSlots = UBound($aBBAttackBar, 1)
		If $g_bBBDropOrderSet = True Then
			local $asBBDropOrder = StringSplit($g_sBBDropOrder, "|")
			For $i=0 To $g_iBBTroopCount - 1 ; loop through each name in the drop order
				local $j=0, $bDone = 0
				While $j < $iNumSlots And Not $bDone
					If $aBBAttackBar[$j][0] = $asBBDropOrder[$i+1] Then
						DeployBBTroop($aBBAttackBar[$j][0], $aBBAttackBar[$j][1], $aBBAttackBar[$j][2], $aBBAttackBar[$j][4], $iSide)
						If $j = $iNumSlots-1 Or $aBBAttackBar[$j][0] <> $aBBAttackBar[$j+1][0] Then
							$bDone = True
							If _Sleep($g_iBBNextTroopDelay) Then ; wait before next troop
								$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
								If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
								Return
							EndIf
						EndIf
					EndIf
					$j+=1
				WEnd
			Next
		Else
			For $i=0 To $iNumSlots - 1
				DeployBBTroop($aBBAttackBar[$i][0], $aBBAttackBar[$i][1], $aBBAttackBar[$i][2], $aBBAttackBar[$i][4], $iSide)
				If $i = $iNumSlots-1 Or $aBBAttackBar[$i][0] <> $aBBAttackBar[$i+1][0] Then
					If _Sleep($g_iBBNextTroopDelay) Then ; wait before next troop
						$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
						If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
						Return
					EndIf
				Else
					If _Sleep($DELAYRESPOND) Then ; we are still on same troop so lets drop them all down a bit faster
						$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
						If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
						Return
					EndIf
				EndIf
			Next
		EndIf
		$aBBAttackBar = GetAttackBarBB(True)
		If $aBBAttackBar = "" Then $bTroopsDropped = True
	WEnd
	SetLog("All Troops Deployed", $COLOR_SUCCESS)
	If Not $g_bRunState Then Return ; Stop Button
	If IsProblemAffect(True) Then Return
	;If not dropping Builder Machine first, drop it now
	If Not $g_bChkBBDropBMFirst Then
		SetLog("Dropping BM Last")
		$bBMDeployed = DeployBM($iSide)
		If _Sleep($g_iBBMachAbilityTime) Then Return
	EndIf

	If Not $g_bRunState Then Return ; Stop Button
	
	If $bBMDeployed Then CheckBMLoop() ;check if BM is Still alive and activate ability
	
	While IsAttackPage()
		_Sleep(2000)
	Wend
	Return
EndFunc   ;==>AttackBB

Func OkayBBEnd() ; Find if battle has ended and click okay
	local $timer = __TimerInit()
	While 1
		If _CheckPixel($aBlackHead, True) Then
			ClickP($aOkayButton)
			Return True
		EndIf

		If __TimerDiff($timer) >= 180000 Then
			SetLog("Could not find finish battle screen", $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("BBFindOkay")
			Return False
		EndIf
		If IsProblemAffect(True) Then Return
		If _Sleep(3000) Then Return
	WEnd
	Return True
EndFunc

Func Okay()
	local $timer = __TimerInit()

	While 1
		local $aCoords = decodeSingleCoord(findImage("OkayButton", $g_sImgOkButton, GetDiamondFromRect("590,420,740,480"), 1, True))
		If IsArray($aCoords) And UBound($aCoords) = 2 Then
			PureClickP($aCoords)
			Return True
		EndIf

		If __TimerDiff($timer) >= 180000 Then ;	 Force quit if more than 3 minutes
			SetLog("Could not find button 'Okay', forcing to quit", $COLOR_ERROR)
			ClickAway()
			Return True
		EndIf
		If IsProblemAffect(True) Then Return
		If _Sleep(2000) Then Return
	WEnd

	Return True
EndFunc

Func DeployBBTroop($sName, $x, $y, $iAmount, $iSide)
    SetLog("Deploying " & $sName & "x" & String($iAmount), $COLOR_ACTION)
    PureClick($x, $y) ; select troop
    If _Sleep($g_iBBSameTroopDelay) Then Return ; slow down selecting then dropping troops
    For $j=0 To $iAmount - 1
        local $iPoint = Random(0, 9, 1)
        If $iSide Then ; pick random point on random side
            PureClick($g_apTR[$iPoint][0], $g_apTR[$iPoint][1])
        Else
            PureClick($g_apTL[$iPoint][0], $g_apTL[$iPoint][1])
        EndIf
        If _Sleep($g_iBBSameTroopDelay) Then Return ; slow down dropping of troops
    Next
EndFunc

Func GetMachinePos()
    local $sSearchDiamond = GetDiamondFromRect("0,580,860,670")
    local $aCoords = decodeSingleCoord(findImage("BBBattleMachinePos", $g_sImgBBBattleMachine, $sSearchDiamond, 1, True))
    If IsArray($aCoords) And UBound($aCoords) = 2 Then
        $g_bBBMachineReady = True
		Return $aCoords
    Else
        If $g_bDebugImageSave Then SaveDebugImage("BBBattleMachinePos")
    EndIf
    Return
EndFunc

Func DeployBM($iSide = False)
	Local $aBMPos = GetMachinePos()
	Local $bBMDeployed = False
	
	If $g_bBBMachineReady And IsArray($aBMPos) Then 
		SetLog("Deploying Battle Machine.", $COLOR_BLUE)
		For $i = 1 To 3
			;SetLog("$aBMPos = " & $aBMPos[0] & "," & $aBMPos[1], $COLOR_INFO)
			If $g_bDebugClick Then SetLog("[" & $i & "] Try DeployBM", $COLOR_ACTION)
			PureClickP($aBMPos)
			local $iPoint = Random(0, 9, 1)
			If $iSide Then
				PureClick($g_apTR[$iPoint][0], $g_apTR[$iPoint][1])
			Else
				PureClick($g_apTL[$iPoint][0], $g_apTL[$iPoint][1])
			EndIf
			If _Sleep(250) Then Return
			If WaitforPixel($aBMPos[0] - 10, 572, $aBMPos[0] - 9, 573, "4BD505", 10, 1) Then
				$bBMDeployed = True ;we know BM is deployed, because we see green BM health bar
				PureClickP($aBMPos) ;activate BM Ability
				ExitLoop
			EndIf
		Next
		$bBMDeployed = True ;we dont know BM is deployed or no, just set it true as already try 3 time to deployBM
	EndIf
	
	If $bBMDeployed Then SetLog("Battle Machine Deployed", $COLOR_SUCCESS)
	Return $bBMDeployed
EndFunc ; DeployBM

Func CheckBMLoop()
	Local $aBMPos = GetMachinePos(), $count = 0
	Local $TmpBMPosX = 522
	
	While IsAttackPage()
		$aBMPos = GetMachinePos()
		If IsArray($aBMPos) Then
			$TmpBMPosX = $aBMPos[0]
			PureClickP($aBMPos)
			SetLog("Activate Battle Machine Ability", $COLOR_SUCCESS)
			If _Sleep(5000) Then Return
		Else
			If WaitforPixel($TmpBMPosX - 10, 572, $TmpBMPosX - 9, 573, "121212", 10, 1) Then 
				$count += 1
				If $count > 6 Then 
					SetLog("Battle Machine Dead", $COLOR_INFO)
					ExitLoop
				EndIf
			EndIf
			If _Sleep(1000) Then Return
		EndIf
		SetDebugLog("Battle Machine LoopCheck", $COLOR_ACTION)
	Wend
EndFunc



