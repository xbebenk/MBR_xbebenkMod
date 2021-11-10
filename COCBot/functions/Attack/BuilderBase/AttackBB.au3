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
			AttackBB()
			If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
				SetLog("Check if ClanGames Challenge is Completed", $COLOR_DEBUG)
				For $x = 0 To 4
					_Sleep(1000)
					If QuickMIS("BC1", $g_sImgGameComplete, 760, 510, 820, 550, True, $g_bDebugImageSave) Then
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
				AttackBB()
				If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
					SetLog("Check if ClanGames Challenge is Completed", $COLOR_DEBUG)
					For $x = 0 To 4
						_Sleep(1000)
						If QuickMIS("BC1", $g_sImgGameComplete, 760, 510, 820, 550, True, $g_bDebugImageSave) Then
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

Func AttackBB()
	If Not $g_bChkEnableBBAttack Then Return
	If Not $g_bRunState Then Return
	local $iSide = Random(0, 1, 1) ; randomly choose top left or top right
	local $aBMPos = 0
	;ClickAway()

	SetLog("Going to attack.", $COLOR_BLUE)

	; check for troops, loot and Batlle Machine
	;;;If Not PrepareAttackBB() Then Return
	;;;SetDebugLog("PrepareAttackBB(): Success.")

	; search for a match
	If _Sleep(2000) Then Return
	local $aBBFindNow = [521, 308, 0xffc246, 30] ; search button
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
	While Not CheckBattleStarted()
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

Func DeployBM($bBMDeployed, $aBMPos, $iSide, $iAndroidSuspendModeFlagsLast)
	; place hero first and activate ability
	If $g_bBBMachineReady And Not $bBMDeployed Then SetLog("Deploying Battle Machine.", $COLOR_BLUE)
	While Not $bBMDeployed And $g_bBBMachineReady
		$aBMPos = GetMachinePos()
		If IsArray($aBMPos) Then
			PureClickP($aBMPos)
			local $iPoint = Random(0, 9, 1)
			If $iSide Then
				PureClick($g_apTR[$iPoint][0], $g_apTR[$iPoint][1])
			Else
				PureClick($g_apTL[$iPoint][0], $g_apTL[$iPoint][1])
			EndIf
			If $g_bChkBBDropBMFirst = True Then
				$bBMDeployed = True
				ExitLoop ;no need to activate BM ability if deployed first
			EndIf
			If _Sleep(1000) Then ; wait before clicking ability
				$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
				If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
				Return
			EndIf
			PureClickP($aBMPos) ; potentially add sleep here later, but not needed at the moment
			Sleep(2000) ;Delay after starting BM
		Else
			$bBMDeployed = True ; true if we dont find the image... this logic is because sometimes clicks can be funky so id rather keep looping till image is gone rather than until we think we have deployed
		EndIf
	WEnd
	If $bBMDeployed Then SetLog("Battle Machine Deployed", $COLOR_SUCCESS)
	Return($bBMDeployed)
EndFunc ; DeployBM

Func CheckBattleStarted()
	local $sSearchDiamond = GetDiamondFromRect("376,11,420,26")

	local $aCoords = decodeSingleCoord(findImage("BBBattleStarted", $g_sImgBBBattleStarted, $sSearchDiamond, 1, True))
	If IsArray($aCoords) And UBound($aCoords) = 2 Then
		SetLog("Battle Started", $COLOR_SUCCESS)
		Return True
	EndIf

	Return False ; If battle not started
EndFunc

Func GetMachinePos()
	If Not $g_bBBMachineReady Then Return

	local $sSearchDiamond = GetDiamondFromRect("0,630,860,732")
	local $aCoords = decodeSingleCoord(findImage("BBBattleMachinePos", $g_sImgBBBattleMachine, $sSearchDiamond, 1, True))

	If IsArray($aCoords) And UBound($aCoords) = 2 Then
		Return $aCoords
	Else
		If $g_bDebugImageSave Then SaveDebugImage("BBBattleMachinePos")
	EndIf

	Return
EndFunc

Func Okay()
	local $timer = __TimerInit()

	While 1
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

		If _Sleep(3000) Then Return
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

#region - xbebenk
Global $g_sImgCustomArmyBB = @ScriptDir & "\imgxml\Resources\BuildersBase\ChangeTroops\"

; Global $g_sIcnBBOrder[$g_iBBTroopCount]
Global Const $g_asAttackBarBB2[$g_iBBTroopCount + 1] = ["Barbarian", "Archer", "BoxerGiant", "Minion", "WallBreaker", "BabyDrag", "CannonCart", "Witch", "DropShip", "SuperPekka", "HogGlider", "Machine"]
Global Const $g_asBBTroopShortNames[$g_iBBTroopCount + 1] = ["Barb", "Arch", "Giant", "Minion", "Breaker", "BabyD", "Cannon", "Witch", "Drop", "Pekka", "HogG", "Machine"]
Global Const $g_sTroopsBBAtk[$g_iBBTroopCount + 1] = ["Raged Barbarian", "Sneaky Archer", "Boxer Giant", "Beta Minion", "Bomber Breaker", "Baby Dragon", "Cannon Cart", "Night Witch", "Drop Ship", "Super Pekka", "Hog Glider", "Battle Machine"]

;=========================================================================================================
; Name ..........: BuilderBaseAttack
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseAttack()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018), Team AIO Mod++ (1/11/2021) (redo.)
; Modified ......: Boludoz (12/2018 - 31/12/2019, 25/08/2020), Dissociable (07-2020)
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func TestGetAttackBarBB()
	Setlog("** TestGetAttackBarBB START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	Local $TempDebug = $g_bDebugOcr
	$g_bDebugOcr = True
	GetAttackBarBB()
	$g_bRunState = $Status
	$g_bDebugOcr = $TempDebug
	Setlog("** TestGetAttackBarBB END**", $COLOR_DEBUG)
EndFunc   ;==>TestGetAttackBarBB

Func ArmyCampSelectedNames($g_iCmbBBArmy)
	Local $aNames = $g_asAttackBarBB2
	;$aNames[0] = "EmptyCamp"
	Return $aNames[$g_iCmbBBArmy]
EndFunc   ;==>ArmyCampSelectedNames

Func BuilderBaseSelectCorrectCampDebug()
	Local $aLines[0]
	Local $sName = "CAMP" & "|"
	For $iName = 0 To UBound($g_iCmbTroopBB) - 1
		$sName &= ArmyCampSelectedNames($g_iCmbTroopBB[$iName]) <> "" ? ArmyCampSelectedNames($g_iCmbTroopBB[$iName]) : ("Barb")
		$sName &= "|"
		If $iName = 0 Then ContinueLoop
		Local $aFakeCsv[1] = [$sName]
		_ArrayAdd($aLines, $aFakeCsv)
	Next

	_ArrayDisplay($aLines)
EndFunc   ;==>BuilderBaseSelectCorrectCampDebug

Func FullNametroops($aResults)
	For $i = 0 To UBound($g_asAttackBarBB2) - 1
		If $aResults = $g_asAttackBarBB2[$i] Then
			If UBound($g_avStarLabTroops) - 1 < $i + 1 Then ExitLoop
			Return $g_avStarLabTroops[$i + 1][3]
		EndIf
	Next
	Return $aResults
EndFunc   ;==>FullNametroops

Func TestBuilderBaseSelectCorrectScript()
	Local $aAvailableTroops = GetAttackBarBB()
	BuilderBaseSelectCorrectScript($aAvailableTroops)
	Return $aAvailableTroops
EndFunc   ;==>TestBuilderBaseSelectCorrectScript

Func BuilderBaseSelectCorrectScript(ByRef $aAvailableTroops)

	If Not $g_bRunState Then Return
	Local $bIsCampCSV = False
	Local $aLines[0]
	Local $iModeAttack = 0


	_CaptureRegions()

	Local $sLastObj = "Barbarian", $sTmp
	Local $aFakeCsv[1]

	#CS
	If ($g_iCmbBBAttack = $g_eBBAttackCSV) Then
		$iModeAttack = 0
		If ($g_bChkBBGetFromArmy = True) Then
			$iModeAttack = 1
		EndIf
	ElseIf ($g_iCmbBBAttack = $g_eBBAttackSmart) Then
		$iModeAttack = 1
		If ($g_bChkBBGetFromCSV = True) Then
			$iModeAttack = 0
		EndIf
	EndIf

	Do
		Switch $iModeAttack

			; CSV
			Case 0
				If Not $g_bChkBBCustomAttack Or ($g_iCmbBBAttack = $g_eBBAttackSmart) Then
					$g_iBuilderBaseScript = 0
				Else
					Local $aMode[2] = [0, 0]    ; Ground - Air
					Local $aBuildings[4] = ["AirDefenses", "Crusher", "GuardPost", "Cannon"]
					Local $a, $i3
					For $i = 0 To UBound($aBuildings) - 1
						$a = BuilderBaseBuildingsDetection($i, False)
						If Not IsArray($a) Then ContinueLoop
						$i3 = ($i = 0) ? (1) : (0)
						For $i2 = 0 To UBound($a) - 1
							If $aMode[$i3] < $a[$i2][3] Then $aMode[$i3] = $a[$i2][3]
						Next
					Next

					Switch True
						; Air mode.
						Case ($aMode[1] < $aMode[0])
							$g_iBuilderBaseScript = 2
							; Ground mode.
						Case ($aMode[1] > $aMode[0])
							$g_iBuilderBaseScript = 1
							; Standard mode.
						Case Else
							$g_iBuilderBaseScript = 0
					EndSwitch

					SetLog("Script mode : " & $g_iBuilderBaseScript & " / " & " Ground calc : " & $aMode[0] & " Air calc : " & $aMode[1], $COLOR_INFO)
					Setlog("Attack using the " & $g_sAttackScrScriptNameBB[$g_iBuilderBaseScript] & " script.", $COLOR_INFO)
				EndIf

				; Let load the Command [Troop] from CSV
				Local $aLArray[0]
				Local $FileNamePath = @ScriptDir & "\CSV\BuilderBase\" & $g_sAttackScrScriptNameBB[$g_iBuilderBaseScript] & ".csv"
				If FileExists($FileNamePath) Then $aLArray = FileReadToArray($FileNamePath)

				; Special case if CSV dont have camps.
				$iModeAttack = 1 ; CSV Mode
				Local $iLast = 0, $aSplitLine, $sName
				For $iLine = 0 To UBound($aLArray) - 1
					If Not $g_bRunState Then Return
					$aSplitLine = StringSplit(StringStripWS($aLArray[$iLine], $STR_STRIPALL), "|", $STR_NOCOUNT)

					If ($aSplitLine[0] = "CAMP") Then
						$iModeAttack = 0 ; CSV Mode
						$sName = "CAMP" & "|"
						For $i = 1 To UBound($aSplitLine) - 1
							$iLast = _ArraySearchCSV($g_sTroopsBBAtk, $aSplitLine[$i])
							If $iLast > -1 Then
								$sTmp = $g_asAttackBarBB2[$iLast]
								If Not StringIsSpace($sTmp) Then $sLastObj = $sTmp
								$sName &= $sLastObj
								If $i <> UBound($aSplitLine) - 1 Then $sName &= "|"
							EndIf
						Next
						$aFakeCsv[0] = $sName
						_ArrayAdd($aLines, $aFakeCsv)

						; ExitLoop 2
					EndIf
				Next

				If $iModeAttack <> 0 Then
					SetLog("You are bad at CSV writing, but we can correct that.", $COLOR_ERROR)
					ContinueLoop
				EndIf

				ExitLoop
				; Smart
			Case Else
				Local $sName = "CAMP" & "|"
				For $i = 0 To UBound($g_iCmbTroopBB) - 1
					$sTmp = $g_asAttackBarBB2[$g_iCmbTroopBB[$i]]
					If Not StringIsSpace($sTmp) Then $sLastObj = $sTmp
					$sName &= $sLastObj
					If $i <> UBound($g_iCmbTroopBB) - 1 Then $sName &= "|"
					$aFakeCsv[0] = $sName
					_ArrayAdd($aLines, $aFakeCsv)
				Next

				ExitLoop
		EndSwitch
	Until True
	#CE

	Local $sName = "CAMP" & "|"
	For $i = 0 To UBound($g_iCmbTroopBB) - 1
		$sTmp = $g_asAttackBarBB2[$g_iCmbTroopBB[$i]]
		If Not StringIsSpace($sTmp) Then $sLastObj = $sTmp
		$sName &= $sLastObj
		If $i <> UBound($g_iCmbTroopBB) - 1 Then $sName &= "|"
		$aFakeCsv[0] = $sName
		_ArrayAdd($aLines, $aFakeCsv)
	Next

	;_ArrayDisplay($aLines)

	If UBound($aLines) = 0 Then
		SetLog("BuilderBaseSelectCorrectScript 0x12 error.", $COLOR_ERROR)
		Return
	EndIf

	_ArraySort($aAvailableTroops, 0, 0, 0, 1)
	;_ArrayDisplay($aAvailableTroops)
	
	Local $iSlotWidth = 72
	Local $iDefaultY = 708
	Local $iCampsQuantities = 0
	Local $aSwicthBtn[0]
	Local $aSlotSwitch[4] = [103, 706, 0xB5DF85, 25]
	While _ColorCheck(_GetPixelColor($aSlotSwitch[0] + Int($iCampsQuantities * $iSlotWidth), $aSlotSwitch[1], False), Hex($aSlotSwitch[2], 6), $aSlotSwitch[3])
		ReDim $aSwicthBtn[$iCampsQuantities + 1]
		$aSwicthBtn[$iCampsQuantities] = $aSlotSwitch[0] + Int($iCampsQuantities * $iSlotWidth)
		$iCampsQuantities += 1
	WEnd

	;_ArrayDisplay($aSwicthBtn)

	Setlog("Available " & $iCampsQuantities & " Camps.", $COLOR_INFO)

	Local $aCamps[0], $aCampsFake[0], $iLast = -1, $bOkCamps = False

	; $iModeAttack
	; Loop for every line on CSV
	; Local $sLastObj = "Barbarian", $sTmp
	For $iLine = 0 To UBound($aLines) - 1
		If Not $g_bRunState Then Return
		Local $aSplitLine = StringSplit(StringStripWS($aLines[$iLine], $STR_STRIPALL), "|", $STR_NOCOUNT)

		If UBound($aSplitLine) > 1 And Not @error And StringInStr($aSplitLine[0], "CAMP") > 0 Then
			$aCamps = $aCampsFake ; Reset
			For $i = 1 To UBound($aSplitLine) - 1
				If StringIsSpace($aSplitLine[$i]) Then ContinueLoop
				_ArrayAdd($aCamps, String($aSplitLine[$i]), $ARRAYFILL_FORCE_STRING)
			Next

			; Select the correct CAMP [cmd line] to use according with the first attack bar detection = how many camps do you have
			$bOkCamps = ($iCampsQuantities = UBound($aCamps))
			If $g_bDebugSetlog Then Setlog(_ArrayToString($aCamps, "-", -1, -1, "|", -1, -1))
			If $bOkCamps Then
				ExitLoop
			EndIf
		EndIf
	Next

	; _ArrayDisplay($aCamps, $bOkCamps)

	Local $sLastObj = "Barbarian", $sTmp
	If $bOkCamps = False Then
		For $i = 0 To UBound($aCamps) - 1
			If Not StringIsSpace($aCamps[$i]) And StringInStr($aCamps[$i], "WallBreaker") = 0 Then
				$sLastObj = $aCamps[$i]
			EndIf
		Next

		ReDim $aCamps[$iCampsQuantities]
		For $i = 0 To UBound($aCamps) - 1
			$sTmp = $aCamps[$i]
			If StringIsSpace($sTmp) Then
				$aCamps[$i] = $sLastObj
			EndIf
		Next
	EndIf

	If UBound($aCamps) = 0 Then
		SetLog("BuilderBaseSelectCorrectScript 0x09 error.", $COLOR_ERROR)
		Return
	EndIf

	;First Find The Correct Index Of Camps In Attack Bar
	For $i = 0 To UBound($aCamps) - 1
		;Just In Case Someone Mentioned Wrong Troop Name Select Default Barbarian Troop
		$aCamps[$i] = _ArraySearch($g_asAttackBarBB2, $aCamps[$i]) < 0 ? ("Barbarian") : _ArraySearch($g_asAttackBarBB2, $aCamps[$i])
	Next
	;After populate with the new priority position let's sort ascending column 1
	_ArraySort($aCamps, 0, 0, 0, 1)
	;Just Assign The Short Names According to new priority positions
	For $i = 0 To UBound($aCamps) - 1
		$aCamps[$i] = $g_asAttackBarBB2[$aCamps[$i]]
	Next

	; [0] = Troops Name , [1] - Priority position
	Local $aNewAvailableTroops[UBound($aAvailableTroops)][2]

	For $i = 0 To UBound($aAvailableTroops) - 1
		$aNewAvailableTroops[$i][0] = $aAvailableTroops[$i][0]
		$aNewAvailableTroops[$i][1] = 0

		For $i2 = 0 To UBound($g_asAttackBarBB2) - 1
			If (StringInStr($aAvailableTroops[$i][0], $g_asAttackBarBB2[$i2]) > 0) Then
				$aNewAvailableTroops[$i][1] = $i2
				ContinueLoop 2
			EndIf
		Next
	Next

	If $g_bDebugSetlog Then SetLog(_ArrayToString($aNewAvailableTroops, "-", -1, -1, "|", -1, -1))

	Local $bWaschanged = False
	Local $iAvoidInfLoop = 0

	Local $aAttackBar = -1
	Local $bDone = False
	While ($bDone = False And $iAvoidInfLoop < 4)
		Local $aWrongCamps = GetWrongCamps($aNewAvailableTroops, $aCamps)
		$bDone = UBound($aWrongCamps) < 1
		If $bDone = True Then
			ExitLoop
		EndIf
		Local $aNewAvailableTroopsOneD[UBound($aNewAvailableTroops)]
		For $i = 0 To UBound($aNewAvailableTroops) - 1
			$aNewAvailableTroopsOneD[$i] = $aNewAvailableTroops[$i][0]
		Next
		; No More Switch Buttons Available, Slot is Machine
		If $aWrongCamps[0] >= UBound($aSwicthBtn) Then
			SetDebugLog("Exiting the Switch Troop Loop, Wrong Camp: " & $aWrongCamps[0] + 1 & ", Available Switch Buttons: " & UBound($aSwicthBtn), $COLOR_INFO)
			$bDone = True
			ExitLoop
		EndIf
		Local $sMissingCamp = GetAMissingCamp($aNewAvailableTroopsOneD, $aCamps)
		If $sMissingCamp = "-" Then
			; No Camps are missing
			SetDebugLog("All camps are fixed and nothing is missing, Exiting Switch Troops loop.", $COLOR_INFO)
			$bDone = True
			ExitLoop
		EndIf
		; Check if Troop index is Equal or Higher than the Builder Machine, it's not a switchable Slot!
		If $aNewAvailableTroops[$aWrongCamps[0]][0] = "Machine" Then
			; Slot is Builder machine or things like that.
			SetDebugLog("Read to Builder Machine Slot or even the next ones, Exiting switch troops loop.", $COLOR_INFO)
			$bDone = True
			ExitLoop
		EndIf
		$bWaschanged = True
		SetLog("Incorrect troop On Camp " & $aWrongCamps[0] + 1 & " - " & $aNewAvailableTroops[$aWrongCamps[0]][0] & " -> " & $sMissingCamp)
		SetDebugLog("Click Switch Button " & $aWrongCamps[0], $COLOR_INFO)
		Click($aSwicthBtn[$aWrongCamps[0]] + Random(2, 10, 1), $iDefaultY + Random(2, 10, 1))
		
		For $iSleepWait = 0 To 4
			If Not $g_bRunState Then Return
			If _Sleep(1000) Then Return
			If QuickMIS("N1", $g_sImgCustomArmyBB, 2, 681, 860, 728) = "ChangeTDis" Then ExitLoop
			If $iSleepWait <> 4 Then ContinueLoop
			Setlog("Error at Camps!", $COLOR_ERROR)
			$iAvoidInfLoop += 1
			If Not $g_bRunState Then Return
			ContinueLoop 2
		Next
		
		; Open eyes and learn.
		$aAttackBar = decodeSingleCoord(findImageInPlace($sMissingCamp, $g_sImgDirBBTroops & "\" & $sMissingCamp & "*", "0,523(861,615)", True))
		If UBound($aAttackBar) >= 2 Then
			; If The item is The Troop that We Missing
			If _Sleep(250) Then Return
			; Select The New Troop
			PureClick($aAttackBar[0] + Random(1, 5, 1), $aAttackBar[1] + Random(1, 5, 1), 1, 0)
			If _Sleep(250) Then Return
			SetDebugLog("Selected " & FullNametroops($sMissingCamp) & " X:| " & $aAttackBar[0] & " Y:| " & $aAttackBar[1], $COLOR_SUCCESS)
			$aNewAvailableTroops[$aWrongCamps[0]][0] = $sMissingCamp
			; Set the Priority Again
			For $i2 = 0 To UBound($g_asAttackBarBB2) - 1
				If (StringInStr($aNewAvailableTroops[$aWrongCamps[0]][0], $g_asAttackBarBB2[$i2]) > 0) Then
					$aNewAvailableTroops[$aWrongCamps[0]][1] = $i2
				EndIf
			Next
			_ArraySort($aNewAvailableTroops, 0, 0, 0, 1)
			If $g_bDebugSetlog Then SetDebugLog("New Army is " & _ArrayToString($aNewAvailableTroops, "-", -1, -1, "|", -1, -1), $COLOR_INFO)
		Else
			Click(8, 720, 1)
			Return False
		EndIf
	WEnd
	If _Sleep(500) Then Return

	If $bWaschanged Then
		If QuickMIS("N1", $g_sImgCustomArmyBB, 2, 681, 860, 728) = "ChangeTDis" Then
			Click(8, 720, 1)
		EndIf
	Else
		Return
	EndIf

	; populate the correct array with correct Troops
	For $i = 0 To UBound($aNewAvailableTroops) - 1
		$aAvailableTroops[$i][0] = $aNewAvailableTroops[$i][0]
	Next
	#Cs
	Local $iTroopBanners = 640 ; y location of where to find troop quantities

	For $i = 0 To UBound($aAvailableTroops) - 1
		If Not $g_bRunState Then Return
		If $aAvailableTroops[$i][0] <> "" Then ;We Just Need To redo the ocr for mentioned troop only
			Local $iCount = Number(getTroopCountSmall($aAvailableTroops[$i][1], $iTroopBanners))
			If $iCount == 0 Then $iCount = Number(getTroopCountBig($aAvailableTroops[$i][1], $iTroopBanners - 7))
			If $iCount == 0 And Not String($aAvailableTroops[$i][0]) = "Machine" Then
				SetLog("Could not get count for " & $aAvailableTroops[$i][0] & " in slot " & String($aAvailableTroops[$i][3]), $COLOR_ERROR)
				ContinueLoop
			ElseIf (StringInStr($aAvailableTroops[$i][0], "Machine") > 0) Then
				$iCount = 1
			EndIf
		EndIf
		$aAvailableTroops[$i][4] = $iCount
	Next
	#ce
	For $i = 0 To UBound($aAvailableTroops) - 1
		If Not $g_bRunState Then Return
		If $aAvailableTroops[$i][0] <> "" Then SetLog("[" & $i + 1 & "] - " & $aAvailableTroops[$i][4] & "x " & FullNametroops($aAvailableTroops[$i][0]), $COLOR_SUCCESS)
	Next
EndFunc   ;==>BuilderBaseSelectCorrectScript

Func GetAMissingCamp($aCurCamps, $aCorrectCamps)
	; Loop Through Correct Camps
	For $i = 0 To UBound($aCorrectCamps) - 1
		Local $iCurrentlyAvailable = GetTroopCampCounts($aCorrectCamps[$i], $aCurCamps)
		Local $iNeeded = GetTroopCampCounts($aCorrectCamps[$i], $aCorrectCamps)
		If $iNeeded > $iCurrentlyAvailable Then Return $aCorrectCamps[$i]
	Next
	Return "-"
EndFunc   ;==>GetAMissingCamp

Func GetWrongCamps($aCurCamps, $aCorrectCamps)
	Local $aWrongCampsIndexes[0] = []
	Local $oDicTroopCampsNeeded = ObjCreate("Scripting.Dictionary")
	If @error Then
		MsgBox(0, '', 'Error creating the dictionary object')
		Return $aWrongCampsIndexes
	EndIf
	Local $iCurTroopCamps = 0
	; Loop Through Current Camps
	For $i = 0 To UBound($aCurCamps) - 1
		; Check if We're now on a Different Troop than the previous one
		If $i > 0 And ($aCurCamps[$i - 1][0] <> $aCurCamps[$i][0]) Then
			$iCurTroopCamps = 0
		EndIf
		; Check if Current Troop has been checked the go to the Next Camp if Exists
		If $oDicTroopCampsNeeded.Exists($aCurCamps[$i][0]) Then
			; If Current Troop Camp is Already Enough or Higher than The Needed Camps of the Troop
			If $iCurTroopCamps >= $oDicTroopCampsNeeded.Item($aCurCamps[$i][0]) Then
				_ArrayAdd($aWrongCampsIndexes, $i)
				; Continue The For Loop to Check the Next Camp if Exists
				ContinueLoop
			EndIf
		EndIf

		; Check how many camps must be filled with this Current Camp Troop
		Local $iNeededCamps = GetTroopCampCounts($aCurCamps[$i][0], $aCorrectCamps)
		; Check if Current Camp Troop is not totally used
		If $iNeededCamps = 0 Then
			_ArrayAdd($aWrongCampsIndexes, $i)
			; Continue The For Loop to Check the Next Camp if Exists
			ContinueLoop
		EndIf

		; At least One camp must be filled with the Troop
		If $oDicTroopCampsNeeded.Exists($aCurCamps[$i][0]) = False Then
			$oDicTroopCampsNeeded.Add($aCurCamps[$i][0], $iNeededCamps)
		EndIf
		$iCurTroopCamps += 1
	Next
	Return $aWrongCampsIndexes
EndFunc   ;==>GetWrongCamps

Func GetTroopCampCounts($sTroopName, $aCamp)
	Local $iFoundInCamps = 0
	For $i = 0 To UBound($aCamp) - 1
		If $sTroopName = $aCamp[$i] Then $iFoundInCamps += 1
	Next
	Return $iFoundInCamps
EndFunc   ;==>GetTroopCampCounts

; Custom BB - Team AIO Mod++
Func _ArraySearchCSV($aArray, $sTroop)
	For $i = 0 To UBound($aArray) - 1
		If _CompareTexts($aArray[$i], $sTroop, 80, True) Then
			Return $i
		EndIf
	Next
	Return -1
EndFunc   ;==>_ArraySearchCSV

Func _LevDis($s, $t)
	Local $m, $n, $iMaxM, $iMaxN

	$n = StringLen($s)
	$m = StringLen($t)
	$iMaxN = $n + 1
	$iMaxM = $m + 1
	Local $d[$iMaxN + 1][$iMaxM + 1]
	$d[0][0] = 0

	If $n = 0 Then
		Return $m
	ElseIf $m = 0 Then
		Return $n
	EndIf

	For $i = 1 To $n
		$d[$i][0] = $d[$i - 1][0] + 1
	Next
	For $j = 1 To $m
		$d[0][$j] = $d[0][$j - 1] + 1
	Next

	Local $jj, $ii, $iCost

	For $i = 1 To $n
		For $j = 1 To $m
			$jj = $j - 1
			$ii = $i - 1
			If (StringMid($s, $i, 1) = StringMid($t, $j, 1)) Then
				$iCost = 0
			Else
				$iCost = 1
			EndIf
			$d[$i][$j] = _Min(_Min($d[$ii][$j] + 1, $d[$i][$jj] + 1), $d[$ii][$jj] + $iCost)
		Next
	Next
	Return $d[$n][$m]
EndFunc   ;==>_LevDis

Func _CompareTexts($sTextIn = "", $sText2in = "", $iPerc = 80, $bStrip = False)

	Local $sText2 = "", $sTexta = ""
	If StringLen($sText2in) > StringLen($sTextIn) Then
		$sText2 = ($bSTRIP = False) ? ($sTextIn) : (StringStripWS($sTextIn, $STR_STRIPALL))
		$sTexta = ($bSTRIP = False) ? ($sText2in) : (StringStripWS($sText2in, $STR_STRIPALL))
	Else
		$sTexta = ($bSTRIP = False) ? ($sTextIn) : (StringStripWS($sTextIn, $STR_STRIPALL))
		$sText2 = ($bSTRIP = False) ? ($sText2in) : (StringStripWS($sText2in, $STR_STRIPALL))
	EndIf

	Local $aSeparate = StringSplit($sTexta, "", $STR_ENTIRESPLIT + $STR_NOCOUNT)
	If Not @error Then

		Local $iOf2 = StringLen($sText2) - 1
		If $iOf2 < 1 Then Return False

		Local $iC = 0, $iC2 = 0, $iText = 0, $iText2 = 0, $iLev = 0
		Local $sText = ""

		Local $iMax = 0
		For $i = 0 To UBound($aSeparate) - 1
			$sText = ""
			For $iTrin = 0 To $iOf2
				$iMax = $i + $iTrin
				If UBound($aSeparate) = $iMax Then ExitLoop
				$sText &= $aSeparate[$iMax]
			Next

			$iC = 0
			$iC2 = 0
			$iText = StringLen($sText)
			$iText2 = StringLen($sText2)
			$iLev = _LevDis($sText, $sText2)

			$iC = ((_Max($iText, $iText2) - $iLev) * 100)
			$iC2 = ((_Max($iText, $iText2)) * 100)
			$iC = (_Min($iC, $iC2) / _Max($iC, $iC2)) * 100

			If $iLev = 0 Or ($iC >= $iPerc) Then
				Return True
			EndIf
		Next
	EndIf
	Return False
EndFunc   ;==>_CompareTexts
#endRegion - xbebenk