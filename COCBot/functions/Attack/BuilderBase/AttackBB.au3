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
	If Not $g_bChkEnableBBAttack Then Return
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
	
	If $g_BBBCSVAttack = True Then
		If IsArray($aBBAttackBar) Then
	
			; Zoomout the Opponent Village.
			BuilderBaseZoomOut(False, True)
	
			; Correct script.
			BuilderBaseSelectCorrectScript($aBBAttackBar)
	
			Local $FurtherFrom = 5 ; 5 pixels before the deploy point.
			BuilderBaseGetDeployPoints($FurtherFrom, True)
	
			; Parse CSV , Deploy Troops and Get Machine Status [attack algorithm] , waiting for Battle ends window.
			BuilderBaseParseAttackCSV($aBBAttackBar, $g_aDeployPoints, $g_aDeployBestPoints, True)
	
		EndIf
	Else
		AttackBB($aBBAttackBar)
	Endif
	
	; wait for end of battle
	SetLog("Waiting for end of battle.", $COLOR_BLUE)
	If Not $g_bRunState Then Return ; Stop Button
	If Not Okay() Then
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

Func AttackBB($aBBAttackBar = GetAttackBarBB(), $bRemainCSV = False)

	local $bTroopsDropped = False, $bBMDeployed = False
	;Function uses this list of local variables...
	$aBMPos = GetMachinePos() ;Need this initialized before it starts flashing
	If $g_bChkBBDropBMFirst = True Then
		SetLog("Dropping BM First")
		$bBMDeployed = DeployBM($bBMDeployed, $aBMPos, $iSide, $iAndroidSuspendModeFlagsLast)
		If IsArray($aBMPos) Then
			_Sleep(500) ;brief pause for sanity
			SetLog("Clicking BM Early") ;Help carry BM through troop drop period
			PureClickP($aBMPos)
		Endif
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

	;If not dropping Builder Machine first, drop it now
	If $g_bChkBBDropBMFirst = False Then
		SetLog("Dropping BM Last")
		$bBMDeployed = DeployBM($bBMDeployed, $aBMPos, $iSide, $iAndroidSuspendModeFlagsLast)
		;Have to sleep here to while TimerDiff loop works first time, below.
		;If $bBMDeployed = True Then Sleep($g_iBBMachAbilityTime)
	EndIf

	If Not $g_bRunState Then Return ; Stop Button

	; Continue with abilities until death
	local $bMachineAlive = True
	while $bMachineAlive And $bBMDeployed
		SetDebugLog("Top of Battle Machine Loop")
		local $timer = __TimerInit() ; give a bit of time to check if hero is dead because of the random lightning strikes through graphic
		$aBMPos = GetMachinePos()
		While __TimerDiff($timer) < ($g_iBBMachAbilityTime + 1000) And Not IsArray($aBMPos) ; give time to find, longer than ability time.
			SetDebugLog("Checking BM Pos again")
			$aBMPos = GetMachinePos()
		WEnd

		If Not IsArray($aBMPos) Then ; if machine wasn't found then it is dead, if not we hit ability
			$bMachineAlive = False
			SetDebugLog("BM not found...is dead")
		Else
			SetDebugLog("Clicking BM")
			PureClickP($aBMPos)
		EndIf

		;Sleep at the end with BM
		If $bMachineAlive Then ;Only wait if still alive
			If _Sleep($g_iBBMachAbilityTime) Then ; wait for machine to be available
				$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
				If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
				Return
			EndIf
		EndIf
	WEnd
	If $bBMDeployed And Not $bMachineAlive Then SetLog("Battle Machine Dead")
#cs
	Local $iSide = Random(0, 1, 1) ; randomly choose top left or top right
	Local $aBMPos = 0

	; If ZoomBuilderBaseMecanics(True) < 1 Then Return False
	
	$g_aBuilderBaseDiamond = PrintBBPoly(False) ;BuilderBaseAttackDiamond()
	If @error Then 
		Return -1
	EndIf
	
	If IsArray($g_aBuilderBaseDiamond) <> True Or Not (UBound($g_aBuilderBaseDiamond) > 0) Then Return False

	$g_aExternalEdges = BuilderBaseGetEdges($g_aBuilderBaseDiamond, "External Edges")

	Local $sSideNames[4] = ["TopLeft", "TopRight", "BottomRight", "BottomLeft"]
	
	Local $aBuilderHallPos
	For $i = 0 To 3
		$aBuilderHallPos = findMultipleQuick($g_sBundleBuilderHall, 1)
		If IsArray($aBuilderHallPos) Then ExitLoop
		If _Sleep(250) Then Return
	Next
	
	If IsArray($aBuilderHallPos) And UBound($aBuilderHallPos) > 0 Then
		$g_aBuilderHallPos = $aBuilderHallPos
	Else
		SaveDebugImage("BuilderHall")
		Setlog("Builder Hall detection Error!", $Color_Error)
		Local $aBuilderHall[1][4] = [["BuilderHall", 450, 425, 92]]
		$g_aBuilderHallPos = $aBuilderHall
	EndIf

	Local $iSide = _ArraySearch($sSideNames, BuilderBaseAttackMainSide(), 0, 0, 0, 0, 0, 0)

	If $iSide < 0 Then
		SetLog("Fail AttackBB 0x2")
		Return False
	EndIf
	
	If $bRemainCSV = False Then
		BuilderBaseGetDeployPoints(15)
	EndIf
	
	Local $aVar
	If UBound($g_aDeployPoints) > 0 Then
		$aVar = $g_aDeployPoints[$iSide]
	EndIf
	
	If UBound($aVar) < 1 Then 
		$aVar = $g_aExternalEdges[$iSide]
	EndIf
	
    If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Disabled")

	; Get troops on attack bar and their quantities
	Local $aBBAttackBar = $aAvailableTroops

	If UBound($aBBAttackBar) < 1 Or @error Or _Sleep($DELAYRESPOND) Then Return

	; Deploy all troops
	Local $iLoopControl = 0, $iUBound1 = UBound($aBBAttackBar)
	SetLog($g_bBBDropOrderSet = True ? "Deploying Troops in Custom Order." : "Deploying Troops in Order of Attack Bar.", $COLOR_BLUE)
	; Loop until nothing has left in Attack Bar
	Do
		Local $iNumSlots = UBound($aBBAttackBar, 1)
		If $g_bBBDropOrderSet = True Then
			; Dropping using Customer Order!
			; Loop through each name in the drop order
			For $i = 0 To UBound($g_aiCmbBBDropOrder) - 1
				; There might be several slots containing same Troop, so even here we should make another loop
				For $j = 0 To $iNumSlots - 1
					; If The Troop name in Slot were the same as Troop name in Current Drop Order index
					If $aBBAttackBar[$j][0] = $g_asAttackBarBB2[Number($g_aiCmbBBDropOrder[$i])] Then ; Custom BB Army - Team AIO Mod++
						; Increase Total Dropped so at the end we can see if it hasn't dropped any, exit the For loop
						If Not ($aBBAttackBar[$j][0] == "Machine") Then
							; The Slot is not Battle Machine, is just a simple troop
							SetLog("Deploying " & $aBBAttackBar[$j][0] & " x" & String($aBBAttackBar[$j][4]), $COLOR_ACTION)
							 ; select troop
							PureClick($aBBAttackBar[$j][1] - Random(0, 5, 1), $aBBAttackBar[$j][2] - Random(0, 5, 1))
							; If the Quantity of the Slot is more than Zero, Start Dropping the Slot
							If $aBBAttackBar[$j][4] > 0 Then
								For $iAmount = 1 To $aBBAttackBar[$j][4]
									Local $vDP = Random(0, UBound($aVar) - 1)
									; Drop
									PureClick($aVar[$vDP][0], $aVar[$vDP][1])
									; Check for Battle Machine Ability
									If TriggerMachineAbility() Then
										; Battle Machine Ability Trigged, Then we have to reselect the Slot we were in.
										PureClick($aBBAttackBar[$j][1] - Random(0, 5, 1), $aBBAttackBar[$j][2] - Random(0, 5, 1))
									EndIf
									; Sleep as much as the user wants for Same Troop Delay
									If _Sleep($g_iBBSameTroopDelay) Then Return
								Next
							EndIf
						ElseIf IsArray($g_aMachineBB) And (UBound($g_aMachineBB) > 2) And (Not $g_aMachineBB[2]) Then
							; The Slot is a Battle Machine and we have not Deployed Battle Machine yet!
							; Select the Battle Machine
							Click($aBBAttackBar[$j][1], $aBBAttackBar[$j][2])
							If _Sleep($g_iBBSameTroopDelay) Then Return
							; Pick a random point in the Edge
							Local $vDP = Random(0, UBound($aVar) - 1)
							; Drop the Battle Machine
							PureClick($aVar[$vDP][0], $aVar[$vDP][1])
							; Set The Battle Machine Slot Coordinates in Attack Bar. Set the Boolean To True to Say Yeah! It's Deployed!
							$g_aMachineBB[0] = $aBBAttackBar[$j][1]
							$g_aMachineBB[1] = $aBBAttackBar[$j][2]
							$g_aMachineBB[2] = True
						EndIf

						;---------------------------
						; If the Attack Bar Array has one more index that can be checked, Then Check if the Current Slot troop is the same as the next slot
						; If not the same, Add a Random Delay according to Next Troop delay in settings
						If UBound($aBBAttackBar) > $j + 1 Then
							If $aBBAttackBar[$j][0] <> $aBBAttackBar[$j + 1][0] Then
								; The next Slot has a different troop, Here we Sleep as set in Next Troop delay settings
								If _Sleep($g_iBBNextTroopDelay) Then ; wait before next troop
									If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
									Return
								EndIf
								; Now we exit the Slot Loop for the Troop Order, as the next slot has a different troop
								ExitLoop
							EndIf
						EndIf
					EndIf
				Next ; Slot Loop
			Next ; Custom Drop Order Loop
		Else
			; No Custom Drop Order has been set!
			For $i = 0 To $iNumSlots - 1
				If Not ($aBBAttackBar[$i][0] == "Machine") Then
					SetLog("Deploying " & $aBBAttackBar[$i][0] & " x" & String($aBBAttackBar[$i][4]), $COLOR_ACTION)
					PureClick($aBBAttackBar[$i][1] - Random(0, 5, 1), $aBBAttackBar[$i][2] - Random(0, 5, 1))     ; select troop
					If $aBBAttackBar[$i][4] <> 0 Then
						For $iAmount = 0 To $aBBAttackBar[$i][4]
							Local $vDP = Random(0, UBound($aVar) - 1)
							PureClick($aVar[$vDP][0], $aVar[$vDP][1])
							If TriggerMachineAbility() Then
								; Battle Machine Ability Trigged, Then we have to reselect the Slot we were in.
								PureClick($aBBAttackBar[$i][1] - Random(0, 5, 1), $aBBAttackBar[$i][2] - Random(0, 5, 1))
							EndIf
							; Sleep as much as the user wants for Same Troop Delay
							If _Sleep($g_iBBSameTroopDelay) Then Return
						Next
					EndIf
				ElseIf IsArray($g_aMachineBB) And (UBound($g_aMachineBB) > 2) And (Not $g_aMachineBB[2]) Then
					; The Slot is a Battle Machine and we have not Deployed Battle Machine yet!
					; Select the Battle Machine
					Click($aBBAttackBar[$i][1], $aBBAttackBar[$i][2])
					If _Sleep($g_iBBSameTroopDelay) Then Return
					; Pick a random point in the Edge
					Local $vDP = Random(0, UBound($aVar) - 1)
					; Drop the Battle Machine
					PureClick($aVar[$vDP][0], $aVar[$vDP][1])
					; Set The Battle Machine Slot Coordinates in Attack Bar. Set the Boolean To True to Say Yeah! It's Deployed!
					$g_aMachineBB[0] = $aBBAttackBar[$i][1]
					$g_aMachineBB[1] = $aBBAttackBar[$i][2]
					$g_aMachineBB[2] = True
				EndIf

				;---------------------------
				If $i = $iNumSlots - 1 Or $aBBAttackBar[$i][0] <> $aBBAttackBar[$i + 1][0] Then
					If _Sleep($g_iBBNextTroopDelay) Then ; wait before next troop
						If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
						Return
					EndIf
				Else
					If _Sleep($DELAYRESPOND) Then ; we are still on same troop so lets drop them all down a bit faster
						If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
						Return
					EndIf
				EndIf
			Next
		EndIf

		; Attack bar loop control.
		$aBBAttackBar = GetAttackBarBB(True)

		If UBound($aBBAttackBar) = $iUBound1 Then $iLoopControl += 1
		If ($iLoopControl > 3) Then ExitLoop
		$iUBound1 = UBound($aBBAttackBar)
		
	Until UBound($aBBAttackBar) < 1 Or @error
	SetLog("All Troops Deployed", $COLOR_SUCCESS)

	If $g_bDebugSetlog Then SetDebugLog("Android Suspend Mode Enabled")
	#ce
EndFunc   ;==>AttackBB

Func Okay()
	local $timer = __TimerInit()

	While Not isOnBuilderBase(True)
		local $aCoords = decodeSingleCoord(findImage("OkayButton", $g_sImgOkButton, "FV", 1, True))
		If IsArray($aCoords) And UBound($aCoords) = 2 Then
			PureClickP($aCoords)
			Return True
		EndIf

		If __TimerDiff($timer) >= 180000 Then
			SetLog("Could not find button 'Okay'", $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("BBFindOkay")
			Return False
		EndIf

		If Mod(__TimerDiff($timer), 3000) Then
			If _Sleep($DELAYRESPOND) Then Return
		EndIf

	WEnd

	Return True
EndFunc
#EndRegion - Custom BB - Team AIO Mod++ ; Thx Chilly-Chill by you hard work.

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
    If Not $g_bBBMachineReady Then Return
    local $sSearchDiamond = GetDiamondFromRect("0,580,860,670")
    local $aCoords = decodeSingleCoord(findImage("BBBattleMachinePos", $g_sImgBBBattleMachine, $sSearchDiamond, 1, True))
    If IsArray($aCoords) And UBound($aCoords) = 2 Then
        Return $aCoords
    Else
        If $g_bDebugImageSave Then SaveDebugImage("BBBattleMachinePos")
    EndIf
    Return
EndFunc