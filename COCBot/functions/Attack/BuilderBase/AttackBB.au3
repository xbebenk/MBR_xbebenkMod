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

Func DoAttackBB($g_iBBAttackCount = $g_iBBAttackCount)
	If Not $g_bChkEnableBBAttack Then Return
	If $g_iBBAttackCount = 0 Then
		Local $count = 1
		While PrepareAttackBB()
			If Not $g_bRunState Then Return
			If IsProblemAffect(True) Then Return
			SetDebugLog("PrepareAttackBB(): Success.", $COLOR_SUCCESS)
			SetLog("Attack #" & $count & "/~", $COLOR_INFO)
			_AttackBB()
			If Not $g_bRunState Then Return
			If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
				SetLog("Check if ClanGames Challenge is Completed", $COLOR_DEBUG)
				For $x = 0 To 4
					_Sleep(2000)
					If QuickMIS("BC1", $g_sImgGameComplete, 760, 450, 820, 520, True, $g_bDebugImageSave) Then
						SetLog("Nice, Game Completed", $COLOR_INFO)
						ExitLoop 2
					EndIf
				Next
			Else
				_Sleep(2000)
			EndIf
			$g_iBBAttacked = True
			$count += 1
			If $count > 10 Then
				SetLog("Something maybe wrong", $COLOR_INFO)
				SetLog("Force stop, attacked 10 times!", $COLOR_INFO)
				ExitLoop
			EndIf
		Wend

		SetLog("Skip Attack this time..", $COLOR_DEBUG)
		ClickAway("Left")
		_Sleep(1000)
	Else
		For $i = 1 To $g_iBBAttackCount
			If Not $g_bRunState Then Return
			If IsProblemAffect(True) Then Return
			If PrepareAttackBB() Then
				SetDebugLog("PrepareAttackBB(): Success.", $COLOR_SUCCESS)
				SetLog("Attack #" & $i & "/" & $g_iBBAttackCount, $COLOR_INFO)
				_AttackBB()
				If Not $g_bRunState Then Return
				If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
					SetLog("Check if ClanGames Challenge is Completed", $COLOR_DEBUG)
					For $x = 0 To 4
						_Sleep(2000)
						If QuickMIS("BC1", $g_sImgGameComplete, 760, 450, 820, 520, True, $g_bDebugImageSave) Then
							SetLog("Nice, Game Completed", $COLOR_INFO)
							ExitLoop 2
						EndIf
					Next
				Else
					_Sleep(2000)
				EndIf
			Else
				ExitLoop
			EndIf
		Next
		SetLog("Skip Attack this time..", $COLOR_DEBUG)
		ClickAway("Left")
	EndIf
	If Not $g_bRunState Then Return
	If checkMainScreen(True, $g_bStayOnBuilderBase, "DoAttackBB") Then ZoomOut() 
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
	; wait for the clouds to clear
	SetLog("Searching for Opponent.", $COLOR_BLUE)
	local $timer = __TimerInit()
	local $iPrevTime = 0

	While Not WaitforPixel(88, 586, 89, 588, "5095D8", 10, 1) 
		local $iTime = Int(__TimerDiff($timer)/ 60000)
		If $iTime > $iPrevTime Then ; if we have increased by a minute
			SetLog("Clouds: " & $iTime & "-Minute(s)")
			If $iTime > 2 Then 
				CloseCoC(True)
				Return ;xbebenk, prevent bot to long on cloud?, in fact BB attack should only takes seconds to search
			EndIf
			$iPrevTime = $iTime
		EndIf
		If _Sleep(2000) Then Return
		If isProblemAffect(True) Then Return
		If Not $g_bRunState Then Return ; Stop Button
	WEnd

	; Get troops on attack bar and their quantities
	local $aBBAttackBar = GetAttackBarBB()
	If $g_bChkBBCustomArmyEnable Then 
		CorrectAttackBarBB($aBBAttackBar)
		$aBBAttackBar = GetAttackBarBB()
	EndIf
	AttackBB($aBBAttackBar)
	
	; wait for end of battle
	SetLog("Waiting for end of battle.", $COLOR_BLUE)
	If Not $g_bRunState Then Return ; Stop Button
	If Not OkayBBEnd() Then Return
	SetLog("Battle ended")
	If _Sleep(3000) Then Return

	; wait for ok after both attacks are finished
	If Not $g_bRunState Then Return ; Stop Button
	SetLog("Waiting for opponent", $COLOR_BLUE)
	Okay()
	ClickAway("Left")
	SetLog("Done", $COLOR_SUCCESS)
EndFunc

Func AttackBB($aBBAttackBar = Default)
	; Get troops on attack bar and their quantities
	If $aBBAttackBar = Default Then $aBBAttackBar = GetAttackBarBB()
	;local $iSide = Random(0, 1, 1) ; randomly choose top left or top right
	local $iSide = True
	Local $aBMPos = GetMachinePos()
	local $bTroopsDropped = False, $bBMDeployed = False
	
	$g_BBDP = GetBBDropPoint()
	
	;Function uses this list of local variables...
	If $g_bChkBBDropBMFirst And IsArray($aBMPos) Then
		SetLog("Dropping BM First")
		$bBMDeployed = DeployBM($aBMPos, $iSide)
	EndIf

	If Not $g_bRunState Then Return ; Stop Button

	; Deploy all troops
	;local $bTroopsDropped = False, $bBMDeployed = False
	SetLog( $g_bBBDropOrderSet = True ? "Deploying Troops in Custom Order." : "Deploying Troops in Order of Attack Bar.", $COLOR_BLUE)
	While Not $bTroopsDropped
		If Not $g_bRunState Then Return
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
							_Sleep($g_iBBNextTroopDelay) ; wait before next troop
						EndIf
					EndIf
					$j+=1
				WEnd
			Next
		Else
			For $i=0 To $iNumSlots - 1
				DeployBBTroop($aBBAttackBar[$i][0], $aBBAttackBar[$i][1], $aBBAttackBar[$i][2], $aBBAttackBar[$i][4], $iSide)
				If $i = $iNumSlots-1 Or $aBBAttackBar[$i][0] <> $aBBAttackBar[$i+1][0] Then
					_Sleep($g_iBBNextTroopDelay) ; wait before next troop
				Else
					_Sleep($DELAYRESPOND) ; we are still on same troop so lets drop them all down a bit faster
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
	If Not $g_bChkBBDropBMFirst And IsArray($aBMPos) Then
		SetLog("Dropping BM Last")
		$bBMDeployed = DeployBM($aBMPos, $iSide)
	EndIf

	If Not $g_bRunState Then Return ; Stop Button

	If $bBMDeployed Then CheckBMLoop($aBMPos) ;check if BM is Still alive and activate ability
	Local $waitcount = 0
	While IsAttackPage()
		If BBBarbarianHead() Then
			ExitLoop
		EndIf
		$waitcount += 1
		SetDebugLog("Waiting Battle End #" & $waitcount, $COLOR_ACTION)
		_Sleep(2000)
		If IsProblemAffect(True) Then Return
		If Not $g_bRunState Then Return
		If $waitcount > 30 Then ExitLoop
	Wend
	Return
EndFunc   ;==>AttackBB

Func OkayBBEnd() ; Find if battle has ended and click okay
	local $timer = __TimerInit()
	While 1
		If BBBarbarianHead() Then
			ClickP($aOkayButton)
			Return True
		EndIf

		If __TimerDiff($timer) >= 180000 Then
			SetLog("Could not find finish battle screen", $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("BBFindOkay")
			Return False
		EndIf
		If IsProblemAffect(True) Then Return
		If Not $g_bRunState Then Return
		If _Sleep(3000) Then Return
	WEnd
	Return True
EndFunc

Func Okay()
	local $timer = __TimerInit()

	While 1 
		If QuickMIS("BC1", $g_sImgOkButton, 600, 425, 730, 470) Then 
			Click($g_iQuickMISX, $g_iQuickMISY)
			Return True
		EndIf

		If __TimerDiff($timer) >= 180000 Then ;	 Force quit if more than 3 minutes
			SetLog("Could not find button 'Okay', forcing to quit", $COLOR_ERROR)
			ClickAway()
			Return True
		EndIf
		If IsProblemAffect(True) Then Return
		If Not $g_bRunState Then Return
		If _Sleep(2000) Then Return
	WEnd

	Return True
EndFunc

Func DeployBBTroop($sName, $x, $y, $iAmount, $iSide)
    SetLog("Deploying " & $sName & " x" & String($iAmount), $COLOR_ACTION)
    PureClick($x, $y) ; select troop
    If _Sleep($g_iBBSameTroopDelay) Then Return ; slow down selecting then dropping troops
	
	Local $DP[0][3]
	Local $AltSide = ($g_BBDPSide > 1 ? $g_BBDPSide - 1 : 4)
	For $i = 0 To Ubound($g_BBDP) - 1
		If $g_BBDP[$i][0] = $g_BBDPSide Or $g_BBDP[$i][0] = $AltSide Then
			_ArrayAdd($DP, $g_BBDP[$i][0] & "|" & $g_BBDP[$i][1] & "|" & $g_BBDP[$i][2])
		EndIf
	Next
	SetDebugLog(_ArrayToString($g_BBDP))
	SetDebugLog("DPSide = " & $g_BBDPSide, $COLOR_INFO)
	SetDebugLog("AltSide = " & $AltSide, $COLOR_INFO)

	Local $iPoint = 0
    For $j = 0 To $iAmount - 1
		$iPoint = Random(0, Ubound($DP) - 1, 1)
		PureClick($DP[$iPoint][1], $DP[$iPoint][2])	
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

Func DeployBM($aBMPos, $iSide = False)
	Local $bBMDeployed = False
	Local $TmpBMPosX = $aBMPos[0] - 17
	Local $BMPosY = 578
	
	If $g_bBBMachineReady And IsArray($aBMPos) Then
		SetLog("Deploying Battle Machine.", $COLOR_BLUE)
		Local $DP[0][3]
		Local $AltSide = ($g_BBDPSide > 1 ? $g_BBDPSide - 1 : 4)
		For $i = 0 To Ubound($g_BBDP) - 1
			If $g_BBDP[$i][0] = $g_BBDPSide Or $g_BBDP[$i][0] = $AltSide Then
				_ArrayAdd($DP, $g_BBDP[$i][0] & "|" & $g_BBDP[$i][1] & "|" & $g_BBDP[$i][2], Default, Default, Default, $ARRAYFILL_FORCE_NUMBER)
			EndIf
		Next
		
		For $i = 0 To 2
			If $g_bDebugClick Then SetLog("[" & $i & "] Try DeployBM", $COLOR_ACTION)
			PureClickP($aBMPos)
			If $i > 1 Then 
				PureClick(40, 280)
				PureClick(410, 26)
				PureClick(780, 470)
				ExitLoop; desperate ...just leave it
			EndIf
			
			Local $iPoint = Random(0, UBound($DP) - 1, 1)
			PureClick($DP[$iPoint][1], $DP[$iPoint][2])
			_Sleep(500)
			If WaitforPixel($TmpBMPosX - 1, $BMPosY - 1, $TmpBMPosX + 1, $BMPosY + 1, "240571", 10, 1) Then ExitLoop
		Next
		$bBMDeployed = True ;we dont know BM is deployed or no, just set it true as already try 3 time to deployBM
	EndIf

	If $bBMDeployed Then SetLog("Battle Machine Deployed", $COLOR_SUCCESS)
	If $bBMDeployed Then PureClickP($aBMPos)
	Return $bBMDeployed
EndFunc ; DeployBM

Func CheckBMLoop($aBMPos)
	Local $count = 0, $loopcount = 0
	Local $TmpBMPosX = $aBMPos[0] - 17
	Local $BMPosY = 578
	
	While IsAttackPage()
		If IsProblemAffect(True) Then Return
		If Not $g_bRunState Then Return
		
		If BBBarbarianHead() Then
			SetLog("Battle Ended, Exiting BMLoop", $COLOR_DEBUG2)
			ExitLoop
		EndIf
		
		If WaitforPixel($TmpBMPosX - 1, $BMPosY - 1, $TmpBMPosX + 1, $BMPosY + 1, "8C8C8C", 10, 1) Then
			_Sleep(500)
			SetDebugLog("Waiting Battle Machine Ability", $COLOR_DEBUG2)
			ContinueLoop
		Else
			Local $color = _getpixelcolor($TmpBMPosX, $BMPosY, True)
			SetDebugLog("Expected: 8C8C8C, Got: " & $color)
			If $color = "000000" Then ExitLoop
		EndIf
		
		If WaitforPixel($TmpBMPosX - 1, $BMPosY - 1, $TmpBMPosX + 1, $BMPosY + 1, "240571", 10, 1) Then
			PureClickP($aBMPos)
			SetLog("Activate Battle Machine Ability", $COLOR_SUCCESS)
			_SleepStatus(5000)
		Else
			Local $color = _getpixelcolor($TmpBMPosX, $BMPosY, True)
			SetDebugLog("Expected: 240571, Got: " & $color)
			If $color = "000000" Then ExitLoop
		EndIf
		
		If WaitforPixel($TmpBMPosX - 1, $BMPosY - 1, $TmpBMPosX + 1, $BMPosY + 1, "0E0E0E", 6, 1) Then
			$count += 1
			If $count > 3 Then
				SetLog("Battle Machine is Dead", $COLOR_INFO)
				ExitLoop
			EndIf
		EndIf
		If _Sleep(250) Then Return
		SetDebugLog("Battle Machine LoopCheck", $COLOR_ACTION)
		If $loopcount > 60 Then Return ;1 minute
		$loopcount += 1
	Wend
EndFunc

Func GetBBDPPixelSection($XMiddle, $YMiddle, $x, $y)
	Local $isLeft = ($x <= $XMiddle)
	Local $isTop = ($y <= $YMiddle )
	If $isLeft Then
		If $isTop Then Return 1 ; Top Left
		Return 2 ; Bottom Left
	EndIf
	If $isTop Then Return 4 ; Top Right
	Return 3 ; Bottom Right
EndFunc 

Func SetVersusBHToMid()
	Local $xMiddle = 430, $yMiddle = 275, $Delay = 500 
	Local $aRet[3] = [False, $xMiddle, $yMiddle]
	Local $aResult = decodeSingleCoord(findImage("VersusBuilderHall", $g_sImgVersusBH, GetDiamondFromRect("100,150,760,570"), 1, True))
	If IsArray($aResult) And UBound($aResult) > 1 Then
		ClickDrag($aResult[0], $aResult[1], $xMiddle, $yMiddle, $Delay) ;drag up
		_Sleep(1500)
		Local $Ret = decodeSingleCoord(findImage("VersusBuilderHall", $g_sImgVersusBH, GetDiamondFromRect("300,200,500,400"), 1, True))
		If IsArray($Ret) And UBound($Ret) > 1 Then
			$aRet[0] = True
			$aRet[1] = $Ret[0]
			$aRet[2] = $Ret[1]
		Endif
	Else
		ClickDrag(430, 500, 430, 200)	;If we cannot find BH on first search, try to scroll down. Maybe BH is at the bottom of the base.
		_Sleep(1500)
		Local $aResult = decodeSingleCoord(findImage("VersusBuilderHall", $g_sImgVersusBH, GetDiamondFromRect("100,150,760,570"), 1, True))
		If IsArray($aResult) And UBound($aResult) > 1 Then
			ClickDrag($aResult[0], $aResult[1], $xMiddle, $yMiddle, $Delay) ;drag up
			_Sleep(1500)
			Local $Ret = decodeSingleCoord(findImage("VersusBuilderHall", $g_sImgVersusBH, GetDiamondFromRect("300,200,500,400"), 1, True))
			If IsArray($Ret) And UBound($Ret) > 1 Then
				$aRet[0] = True
				$aRet[1] = $Ret[0]
				$aRet[2] = $Ret[1]
			Endif
		Else
			SetDebugLog("SetVersusBHToMid(): Versus BH Not Found", $COLOR_INFO)
		Endif
	EndIf
	Return $aRet
EndFunc

Func GetBBDropPoint($bSetBHToMid = True)
	Local $XMiddle = 430, $YMiddle = 275
	
	If $bSetBHToMid Then 
		Local $BHCoord = SetVersusBHToMid()
		Local $BHFound = False
		If IsArray($BHCoord) And UBound($BHCoord) > 1 Then
			$BHFound = $BHCoord[0]
			$XMiddle = $BHCoord[1]
			$YMiddle = $BHCoord[2]	
			_Sleep(2000) ;add more delay after drag
		EndIf
	EndIf
	
	Local $hTimer = TimerInit()
	$g_bAttackActive = True
	SuspendAndroid()
	
	Local $THhOffset = 150, $aResult[0][3]
	Local $xstart[2] = [70, 430], $ystart = 30, $xend[2] = [430, 800], $yend = 600
	For $i = 0 To 1
		Local $aTmp = QuickMIS("CNX", $g_sBundleDeployPointsBB, $xstart[$i], $ystart, $xend[$i], $yend, True)
		SetDebugLog("aTmp" & $i & ": " & UBound($aTmp) & " Coords", $COLOR_INFO)
		For $j = 0 To UBound($aTmp) - 1
			_ArrayAdd($aResult, $aTmp[$j][1] & "|" & $aTmp[$j][2] & "|" & $aTmp[$j][0])
		Next
		;_ArrayDisplay($aTmp)
	Next
	SetLog("Search BBDropPoint result : " & UBound($aResult) & " Coords", $COLOR_INFO)
	;_ArrayDisplay($aResult)
	Local $aaCoords[0][4], $iSide
	For $i = 0 To UBound($aResult) - 1
		$iSide = GetBBDPPixelSection($XMiddle, $YMiddle, $aResult[$i][0], $aResult[$i][1])
		If $aResult[$i][0] < $XMiddle And $aResult[$i][1] < $YMiddle And $aResult[$i][0] > ($XMiddle - $THhOffset) And $aResult[$i][1] > ($YMiddle - $THhOffset) Then ContinueLoop ;TL
		If $aResult[$i][0] > $XMiddle And $aResult[$i][1] < $YMiddle And $aResult[$i][0] < ($XMiddle + $THhOffset) And $aResult[$i][1] > ($YMiddle - $THhOffset) Then ContinueLoop ;BL
		If $aResult[$i][0] < $XMiddle And $aResult[$i][1] > $YMiddle And $aResult[$i][0] > ($XMiddle - $THhOffset) And $aResult[$i][1] < ($YMiddle + $THhOffset) Then ContinueLoop ;BR
		If $aResult[$i][0] > $XMiddle And $aResult[$i][1] > $YMiddle And $aResult[$i][0] < ($XMiddle + $THhOffset) And $aResult[$i][1] < ($YMiddle + $THhOffset) Then ContinueLoop ;TR
		_ArrayAdd($aaCoords, $iSide & "|" & $aResult[$i][0] & "|" & $aResult[$i][1] & "|" & $aResult[$i][2])
	Next	
	SetLog("Cleared BBDropPoint result : " & UBound($aaCoords) & " Coords", $COLOR_INFO)
	
	Local $aDPResult = SortBBDP($aaCoords)
	SetLog("BBDropPoint after sort : " & UBound($aDPResult) & " Coords", $COLOR_INFO)
	;_ArrayDisplay($aDPResult)
	
	ResumeAndroid()
	$g_bAttackActive = False
	SetLog("BBDropPoint Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	
	FindLavaLauncher($aDPResult)
	SetDebugLog("FindLavaLauncher MainSide = " & $g_BBDPSide)
	If $g_bDebugImageSave Then DebugAttackBBImage($aDPResult, $g_BBDPSide)
	
	Return $aDPResult
EndFunc

Func SortBBDP($aDropPoints)
	Local $aResult[0][4]
	Local $TmpYL = 0, $TmpXR = 0, $DPChange = 5, $DpDistance = 8
	Local $TmpYMaxTLFound = False, $TmpYMinBLFound = False, $TmpYMinBRLFound = False, $TmpYMaxTRFound = False
	Local $TmpXMinTL = 0, $TmpYMaxTL = 0
	Local $TmpXMinBL = 0, $TmpYMinBL = 0
	Local $TmpXMinBR = 0, $TmpYMinBR = 0
	Local $TmpXMinTR = 0, $TmpYMinTR = 0
	Local $iTL = 0, $iBL = 0, $iBR = 0, $iTR = 0
	
	_ArraySort($aDropPoints, 0, 0, 0, 1) ;sort x axis
	For $i = 0 To UBound($aDropPoints) - 1
		If $aDropPoints[$i][0] = 1 Then ;Top Left
			If $aDropPoints[$i][1] < $TmpXMinTL + $DpDistance Then ContinueLoop
			If $aDropPoints[$i][1] > $TmpXMinTL And $aDropPoints[$i][2] > $TmpYMaxTL And $TmpYMaxTLFound Then ContinueLoop
			$TmpXMinTL = $aDropPoints[$i][1]
			$TmpYMaxTL = $aDropPoints[$i][2]
			
			If Not $TmpYMaxTLFound Then
				$TmpXMinTL = $aDropPoints[$i][1]
				$TmpYMaxTL = $aDropPoints[$i][2]
				$TmpYMaxTLFound = True
			EndIf
			SetDebugLog("Side:" & $aDropPoints[$i][0] & " $TmpXMinTL:" & $TmpXMinTL & " TmpYMaxTL:" & $TmpYMaxTL)
			_ArrayAdd($aResult, $aDropPoints[$i][0] & "|" & $aDropPoints[$i][1] - $DPChange & "|" & $aDropPoints[$i][2] - $DPChange & "|" & $aDropPoints[$i][3])
			$iTL += 1
		EndIf
	Next

	_ArraySort($aDropPoints, 0, 0, 0, 1) ;sort x axis
	For $i = 0 To UBound($aDropPoints) - 1
		If $aDropPoints[$i][0] = 2 Then ;Bottom Left
			If $aDropPoints[$i][2] < $TmpYMinBL + $DpDistance Then ContinueLoop
			If $aDropPoints[$i][2] > $TmpYMinBL And $aDropPoints[$i][1] < $TmpXMinBL + $DpDistance And $TmpYMinBLFound Then ContinueLoop
			If $aDropPoints[$i][1] > 250 And $aDropPoints[$i][2] > 500 Then ContinueLoop
			$TmpXMinBL = $aDropPoints[$i][1]
			$TmpYMinBL = $aDropPoints[$i][2]
			
			If Not $TmpYMinBLFound Then
				$TmpXMinBL = $aDropPoints[$i][1]
				$TmpYMinBL = $aDropPoints[$i][2]
				$TmpYMinBLFound = True
			EndIf
			
			SetDebugLog("Side:" & $aDropPoints[$i][0] & " $TmpXMinBL:" & $TmpXMinBL & " TmpYMinBL:" & $TmpYMinBL)
			_ArrayAdd($aResult, $aDropPoints[$i][0] & "|" & $aDropPoints[$i][1] - $DPChange & "|" & $aDropPoints[$i][2] + $DPChange & "|" & $aDropPoints[$i][3])
			$iBL += 1
		EndIf
	Next
	_ArraySort($aDropPoints, 1, 0, 0, 2) ;sort y axis desc
	For $i = 0 To UBound($aDropPoints) - 1
		If $aDropPoints[$i][0] = 3 Then ;Bottom Right
			If $aDropPoints[$i][1] < $TmpXMinBR + $DpDistance Then ContinueLoop
			If $aDropPoints[$i][1] > $TmpXMinBR And $aDropPoints[$i][2] > $TmpYMinBR + $DpDistance And $TmpYMinBRLFound Then ContinueLoop
			$TmpXMinBR = $aDropPoints[$i][1]
			$TmpYMinBR = $aDropPoints[$i][2]
			
			If Not $TmpYMinBRLFound Then
				$TmpXMinBR = $aDropPoints[$i][1]
				$TmpYMinBR = $aDropPoints[$i][2]
				$TmpYMinBRLFound = True
			EndIf
			
			SetDebugLog("Side:" & $aDropPoints[$i][0] & " $TmpXMinBR:" & $TmpXMinBR & " TmpYMinBR:" & $TmpYMinBR)
			_ArrayAdd($aResult, $aDropPoints[$i][0] & "|" & $aDropPoints[$i][1] + $DPChange & "|" & $aDropPoints[$i][2] + $DPChange & "|" & $aDropPoints[$i][3])
			$iBR += 1
		EndIf
	Next
	
	_ArraySort($aDropPoints, 0, 0, 0, 2) ;sort y axis
	For $i = 0 To UBound($aDropPoints) - 1
		If $aDropPoints[$i][0] = 4 Then ;Top Right
			If $aDropPoints[$i][2] < $TmpYMinTR + $DpDistance Then ContinueLoop
			If $aDropPoints[$i][2] > $TmpYMinTR And $aDropPoints[$i][1] < $TmpXMinTR And $TmpYMaxTRFound Then ContinueLoop
			$TmpXMinTR = $aDropPoints[$i][1]
			$TmpYMinTR = $aDropPoints[$i][2]
			
			If Not $TmpYMaxTRFound Then
				$TmpXMinTR = $aDropPoints[$i][1]
				$TmpYMinTR = $aDropPoints[$i][2]
				$TmpYMaxTRFound = True
			EndIf
			SetDebugLog("Side:" & $aDropPoints[$i][0] & " $TmpXMinTR:" & $TmpXMinTR & " TmpYMinTR:" & $TmpYMinTR)
			_ArrayAdd($aResult, $aDropPoints[$i][0] & "|" & $aDropPoints[$i][1] + $DPChange & "|" & $aDropPoints[$i][2] - $DPChange & "|" & $aDropPoints[$i][3])
			$iTR += 1
		EndIf
	Next
	Local $aCount[4][2] = [[1, $iTL], [2, $iBL], [3, $iBR], [4, $iTR]]
	_ArraySort($aCount, 1, 0, 0, 1)
	$g_BBDPSide = $aCount[0][0]
	SetDebugLog("Original MainSide = " & $g_BBDPSide)
	Return $aResult
EndFunc

Func FindLavaLauncher($DP)
	Local $LavaSide = 0
	Local $aRet = decodeSingleCoord(findImage("LavaLauncher", $g_sImgOpponentBuildingsBB & "LavaLauncher\*", GetDiamondFromRect("100,150,760,570"), 1, True))
	If IsArray($aRet) And UBound($aRet) > 1 Then
		SetDebugLog("Found LavaLauncher at " & $aRet[0] & "," & $aRet[1], $COLOR_INFO)
		$LavaSide = GetBBDPPixelSection(430, 275, $aRet[0], $aRet[1])
		SetDebugLog("LavaSide: " & $LavaSide, $COLOR_INFO)
		$g_BBDPSide = $LavaSide
	EndIf
EndFunc

Func DebugAttackBBImage($aCoords, $g_BBDPSide = 1)
	_CaptureRegion2()
	Local $EditedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($EditedImage)
	Local $hPenYellow = _GDIPlus_PenCreate(0xFFFFD800, 2)
	Local $hPenWhite = _GDIPlus_PenCreate(0xFFFFFFFF, 2)
	Local $hPenRed = _GDIPlus_PenCreate(0xFFFF0000, 2)
	Local $hPenCyan = _GDIPlus_PenCreate(0xFF00FFFF, 2)
	
	If IsArray($aCoords) Then 
		For $i = 0 To UBound($aCoords) - 1
			Local $color = $hPenYellow
			Switch $aCoords[$i][0]
				Case 1
					$color = $hPenYellow
				Case 2
					$color = $hPenWhite
				Case 3
					$color = $hPenRed
				Case 4
					$color = $hPenCyan
			EndSwitch
			_GDIPlus_GraphicsDrawRect($hGraphic, $aCoords[$i][1] - 3, $aCoords[$i][2] - 3, 6, 6, $color)
			If UBound($aCoords) < 200 Then
				Switch $aCoords[$i][0]
					Case 1
						_GDIPlus_GraphicsDrawString($hGraphic, $aCoords[$i][3], $aCoords[$i][1] - 20, $aCoords[$i][2] - 20, "ARIAL", 10)
					Case 2
						_GDIPlus_GraphicsDrawString($hGraphic, $aCoords[$i][3], $aCoords[$i][1] - 20, $aCoords[$i][2] + 20, "ARIAL", 10)
					Case 3
						_GDIPlus_GraphicsDrawString($hGraphic, $aCoords[$i][3], $aCoords[$i][1] + 20, $aCoords[$i][2] + 20, "ARIAL", 10)
					Case 4
						_GDIPlus_GraphicsDrawString($hGraphic, $aCoords[$i][3], $aCoords[$i][1] + 20, $aCoords[$i][2] - 20, "ARIAL", 10)
				EndSwitch
			EndIf
		Next
	Else
		SetDebugLog("DebugAttackBBImage: No Array")
	EndIf
	
	Switch $g_BBDPSide
		Case 1
			_GDIPlus_GraphicsDrawRect($hGraphic, 140, 185, 20, 20, $hPenRed)
		Case 2
			_GDIPlus_GraphicsDrawRect($hGraphic, 190, 470, 20, 20, $hPenRed)
		Case 3
			_GDIPlus_GraphicsDrawRect($hGraphic, 690, 430, 20, 20, $hPenRed)
		Case 4
			_GDIPlus_GraphicsDrawRect($hGraphic, 650, 185, 20, 20, $hPenRed)
	EndSwitch
	
	Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
	Local $Time = @HOUR & "." & @MIN & "." & @SEC & "." & @MSEC 
	Local $filename = $g_sProfileTempDebugPath & String("AttackBBDebug_" & $Date & "_" & $Time) & ".png"
	_GDIPlus_ImageSaveToFile($EditedImage, $filename)
	If @error Then SetLog("Debug Image save error: " & @extended, $COLOR_ERROR)
	SetDebugLog("DebugAttackBBImage: " & $filename)

	_GDIPlus_PenDispose($hPenYellow)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_BitmapDispose($EditedImage)

EndFunc   ;==>DebugAttackBBImage

Func BBBarbarianHead()
	If _CheckPixel($aBlackHead, True) Then
		SetDebugLog("Battle Ended, Black Barbarian Head Found", $COLOR_DEBUG2)
		Return True
	Else
		Return False
	EndIf
EndFunc