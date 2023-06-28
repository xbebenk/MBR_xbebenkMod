; #FUNCTION# ====================================================================================================================
; Name ..........: PrepareAttackBB
; Description ...: This file controls attacking preperation of the builders base
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: xbebenk
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func CheckCGCompleted()
	Local $bRet = False
	For $x = 1 To 8
		If Not $g_bRunState Then Return
		SetLog("Check challenges progress #" &$x, $COLOR_ACTION)
		If _Sleep(1000) Then Return
		If QuickMIS("BC1", $g_sImgGameComplete, 760, 450, 820, 520) Then
			SetLog("Nice, Game Completed", $COLOR_INFO)
			$bRet = True
			ExitLoop
		EndIf
	Next
	Return $bRet
EndFunc

Func DoAttackBB($g_iBBAttackCount = $g_iBBAttackCount)
	If Not $g_bChkEnableBBAttack Then Return
	If Not $g_bStayOnBuilderBase Then $g_bStayOnBuilderBase = True
	
	If $g_iBBAttackCount = 0 Then
		Local $count = 1
		While PrepareAttackBB()
			If Not $g_bRunState Then Return
			If IsProblemAffect(True) Then Return
			SetDebugLog("PrepareAttackBB(): Success.", $COLOR_SUCCESS)
			SetLog("Attack #" & $count & "/~", $COLOR_INFO)
			_AttackBB()
			If Not $g_bRunState Then Return
			If $g_bIsBBevent Then
				If CheckCGCompleted() Then ExitLoop
				If $count > 4 Then
					SetLog("IsBBevent = " & String($g_bIsBBevent), $COLOR_INFO)
					SetLog("Force stop, attacked 5 times!", $COLOR_INFO)
					ExitLoop
				EndIf
			Else
				If _Sleep(2000) Then Return
			EndIf
			$g_bBBAttacked = True
			$count += 1
			If $count > 10 Then
				SetLog("Something maybe wrong", $COLOR_INFO)
				SetLog("Force stop, attacked 10 times!", $COLOR_INFO)
				ExitLoop
			EndIf
		Wend
		SetLog("Skip Attack this time..", $COLOR_DEBUG)
		ClickAway("Left")
		If _Sleep(1000) Then Return
	Else
		For $i = 1 To $g_iBBAttackCount
			If Not $g_bRunState Then Return
			If IsProblemAffect(True) Then Return
			If PrepareAttackBB() Then
				SetDebugLog("PrepareAttackBB(): Success.", $COLOR_SUCCESS)
				SetLog("Attack #" & $i & "/" & $g_iBBAttackCount, $COLOR_INFO)
				_AttackBB()
				If Not $g_bRunState Then Return
				If $g_bIsBBevent Then
					If CheckCGCompleted() Then ExitLoop
				Else
					If _Sleep(2000) Then Return
				EndIf
			Else
				ExitLoop
			EndIf
		Next
		If Not $g_bRunState Then Return
		SetLog("Skip Attack this time..", $COLOR_DEBUG)
		ClickAway("Left")
	EndIf
	If Not $g_bRunState Then Return
	SetLog("BB Attack Cycle Done", $COLOR_DEBUG)
EndFunc

Func ClickFindNowButton()
	Local $bRet = False
	For $i = 1 To 10
		If _ColorCheck(_GetPixelColor(655, 440, True), Hex(0x89D239, 6), 20) Then
			Click(655, 440, 1, "Click Find Now Button")
			$bRet = True
			ExitLoop
		EndIf
		If _Sleep(500) Then Return
	Next

	If _Sleep(8000) Then Return ; give time for find now button to go away
	If Not $bRet Then
		SetLog("Could not locate Find Now Button to go find an attack.", $COLOR_ERROR)
		ClickAway("Left")
		Return False
	EndIf

	Return $bRet
EndFunc

Func WaitCloudsBB()
	Local $bRet = True
	
	Local $count = 1
	While Not QuickMIS("BC1", $g_sImgBBAttackStart, 400, 22, 460, 60)
		If $g_bChkDebugAttackBB Then SetLog("Waiting Attack Page #" & $count, $COLOR_ACTION)
		If Not $g_bRunState Then Return
		If $count = 10 Then 
			SetLog("Too long waiting Clouds", $COLOR_ERROR)
			If $g_bChkDebugAttackBB Then SaveDebugImage("WaitCloudsBB", True)
		EndIf
		
		If $count > 20 Then
			CloseCoC(True)
			$bRet = False
			ExitLoop
		EndIf
		If isProblemAffect(True) Then Return
		$count += 1
		If _Sleep(1000) Then Return
	WEnd
	Return $bRet
EndFunc

Func _AttackBB()
	If Not $g_bRunState Then Return
	Local $iSide = Random(0, 1, 1) ; randomly choose top left or top right
	
	SetLog("Going to attack.", $COLOR_INFO)
	If Not ClickFindNowButton() Then
		ClickAway("Left")
		Return False
	EndIf

	If Not $g_bRunState Then Return
	
	SetLog("Searching for Opponent.", $COLOR_BLUE)
	If Not WaitCloudsBB() Then Return
	If Not $g_bRunState Then Return
	AndroidZoomOut() ;zoomout first before any action
	
	; Get troops on attack bar and their quantities
	Local $aBBAttackBar
	$g_aMachinePos = GetMachinePos()
	If $g_bChkBBCustomArmyEnable Then
		$aBBAttackBar = GetAttackBarBB()
		If CorrectAttackBarBB($aBBAttackBar) Then
			AttackBB()
		Else
			$aBBAttackBar = GetAttackBarBB()
			AttackBB($aBBAttackBar)
		EndIf
	Else
		$aBBAttackBar = GetAttackBarBB()
		AttackBB($aBBAttackBar)
	EndIf
	If Not $g_bRunState Then Return
	
	SetLog("Waiting for end of battle.", $COLOR_INFO)
	If EndBattleBB() Then SetLog("Battle ended", $COLOR_INFO)
	
	If checkMainScreen(True, $g_bStayOnBuilderBase, "AttackBB") Then
		If Not $g_bIsBBevent Then  ;disable collect cart if doing CG Challenges, too much time waste, bot need to check If CG Challenges is Completed
			CollectBBCart()
		EndIf
	Else
		checkObstacles($g_bStayOnBuilderBase)
	EndIf
	SetLog("Done", $COLOR_SUCCESS)
	BuilderBaseReport(True, False)
EndFunc

Func EndBattleBB() ; Find if battle has ended and click okay
	Local $bRet = False, $bBattleMachine = True, $bWallBreaker = True
	Local $sDamage = 0, $sTmpDamage = 0, $bCountSameDamage = 1
	
	For $i = 1 To 200
		;SetLog("Waiting EndBattle Screen #" & $i, $COLOR_ACTION)
		If Not $g_bRunState Then ExitLoop
		If $bBattleMachine Then $bBattleMachine = CheckBMLoop()
		If $bWallBreaker Then $bWallBreaker = CheckWBLoop()
		$sDamage = getOcrOverAllDamage(776, 529)
		SetLog("[" & $i & "] EndBattleBB LoopCheck, [" & $bCountSameDamage & "] Overall Damage : " & $sDamage & "%", $COLOR_DEBUG2)
		If Number($sDamage) = Number($sTmpDamage) Then
			$bCountSameDamage += 1
		Else
			$bCountSameDamage = 1
		EndIf
		$sTmpDamage = Number($sDamage)
		If $sTmpDamage = 100 Then
			_SleepStatus(15000)
			
			If ShouldStopAttackonCG() Then 
				ReturnHomeDropTrophyBB(True)
				ExitLoop
			EndIf
			
			Local $aBBAttackBar = GetAttackBarBB(False, True)
			If $g_bChkBBCustomArmyEnable Then 
				CorrectAttackBarBB($aBBAttackBar) 
				$aBBAttackBar = GetAttackBarBB(False, True) ;correct army troop doesnt have new quantities (if troop changes) so read again the attackbar
				AttackBB($aBBAttackBar, True)
			Else
				AttackBB($aBBAttackBar, True)
			EndIf
			If _Sleep(5000) Then Return ; Add some delay for troops making some damage
			$sTmpDamage = 0
			$bBattleMachine = True
			$bWallBreaker = True
		EndIf

		If $bCountSameDamage > 20 Then
			If $g_bChkDebugAttackBB Then SetLog("EndBattleBB LoopCheck: No Change on Overall Damage, Exit!", $COLOR_ERROR)
			If ReturnHomeDropTrophyBB(True) Then $bRet = True
			ExitLoop
		EndIf

		If BBBarbarianHead("EndBattleBB") Then
			$bRet = True
			If $g_bChkBBAttackReport Then
				If _SleepStatus(5000) Then Return
				BBAttackReport()
			EndIf
			ExitLoop
		EndIf

		If IsProblemAffect(True) Then Return
		If Not $g_bRunState Then Return
		If _Sleep(1000) Then Return
	Next
	
	For $i = 1 To 3
		Select
			Case QuickMIS("BC1", $g_sImgBBReturnHome, 390, 520, 470, 560) = True
				Click($g_iQuickMISX, $g_iQuickMISY)
				If $g_bChkDebugAttackBB Then SetLog("Click Return Home", $COLOR_ACTION)
				If _Sleep(3000) Then Return
			Case QuickMIS("BC1", $g_sImgBBAttackBonus, 410, 464, 454, 490) = True
				SetLog("Congrats Chief, Stars Bonus Awarded", $COLOR_INFO)
				Click($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(2000) Then Return
				$bRet = True
			Case isOnBuilderBase() = True
				$bRet = True
		EndSelect
		If _Sleep(1000) Then Return
	Next

	If Not $bRet Then SetLog("Could not find finish battle screen", $COLOR_ERROR)
	Return $bRet
EndFunc

Func AttackBB($aBBAttackBar = Default, $bSecondAttack = False)
	$g_BBDP = GetBBDropPoint($bSecondAttack)

	; Get troops on attack bar and their quantities
	If $aBBAttackBar = Default Then $aBBAttackBar = GetAttackBarBB()
	Local $iSide = $g_BBDPSide
	Local $AltSide = 0, $countTL = 0, $countBL = 0, $countBR = 0, $countTR = 0
	For $i = 0 To Ubound($g_BBDP) - 1
		If $g_BBDP[$i][0] = 1 Then $countTL += 1
		If $g_BBDP[$i][0] = 2 Then $countBL += 1
		If $g_BBDP[$i][0] = 3 Then $countBR += 1
		If $g_BBDP[$i][0] = 4 Then $countTR += 1
	Next

	Local $acountDP[4][2] = [[1, $countTL], [2, $countBL], [3, $countBR], [3, $countTR]]
	_ArraySort($acountDP, 1, 0, 0, 1) ;sort desc by count Drop-points, index 0 will have more DP

	If $acountDP[1][1] > 0 Then $AltSide = $acountDP[1][0]
	If $g_bChkDebugAttackBB Then SetLog("DPSide = " & $iSide)
	If $g_bChkDebugAttackBB Then SetLog("AltSide = " & $AltSide)

	If $acountDP[$iSide-1][1] < 1 Then
		SetDebugLog("Side " & $iSide & " have no DP found, fallback to most reliable DP Side")
		$iSide = $acountDP[0][0]
		SetDebugLog("Side Change to " & $iSide)
	EndIf

	Local $DP[0][3]
	For $i = 0 To Ubound($g_BBDP) - 1
		If $g_bAllSideBBAttack Then
			_ArrayAdd($DP, $g_BBDP[$i][0] & "|" & $g_BBDP[$i][1] & "|" & $g_BBDP[$i][2])
		Else
			If $g_BBDP[$i][0] = $iSide Then
				_ArrayAdd($DP, $g_BBDP[$i][0] & "|" & $g_BBDP[$i][1] & "|" & $g_BBDP[$i][2])
			EndIf
			If $g_b2SideBBAttack And $AltSide > 0 Then
				If $g_BBDP[$i][0] = $AltSide Then
					_ArrayAdd($DP, $g_BBDP[$i][0] & "|" & $g_BBDP[$i][1] & "|" & $g_BBDP[$i][2])
				EndIf
			EndIf
		EndIf
	Next

	If UBound($DP) = 0 Then
		SetLog("Sorry, we cannot continue attack, waiting for surrender", $COLOR_ERROR)
		If $g_bChkDebugAttackBB Then SaveDebugImage("CheckBBDropPoint", True)
		_SleepStatus(30000)
		If ReturnHomeDropTrophyBB() Then Return
	EndIf

	If IsProblemAffect(True) Then Return
	
	Local $bTroopsDropped = False, $bBMDeployed = False
	If $g_bChkBBDropBMFirst Then
		If IsArray($g_aMachinePos) And StringInStr($g_aMachinePos[2], "Dead") = 0 Then 
			SetLog("Dropping BM First")
			$bBMDeployed = DeployBM($g_aMachinePos, $iSide, $AltSide, $DP)
		EndIf
	EndIf

	If Not $g_bRunState Then Return
	If IsProblemAffect(True) Then Return
	
	; Deploy all troops
	SetLog( $g_bBBDropOrderSet = True ? "Deploying Troops in Custom Order." : "Deploying Troops in Order of Attack Bar.", $COLOR_BLUE)
	While Not $bTroopsDropped
		If Not $g_bRunState Then Return
		Local $iNumSlots = UBound($aBBAttackBar)
		If $g_bBBDropOrderSet = True Then
			Local $asBBDropOrder = StringSplit($g_sBBDropOrder, "|")
			For $i = 0 To $g_iBBTroopCount - 1 ; loop through each name in the drop order
				Local $j = 0, $bDone = False
				While $j < $iNumSlots And Not $bDone
					If $aBBAttackBar[$j][0] = $asBBDropOrder[$i+1] Then
						DeployBBTroop($aBBAttackBar[$j][0], $aBBAttackBar[$j][1] + 35, $aBBAttackBar[$j][2], $aBBAttackBar[$j][4], $iSide, $AltSide, $DP)
						If $j = $iNumSlots-1 Or $aBBAttackBar[$j][0] <> $aBBAttackBar[$j+1][0] Then
							$bDone = True
							_Sleep($g_iBBNextTroopDelay) ; wait before next troop
						EndIf
					EndIf
					$j+=1
				WEnd
			Next
		Else
			Local $sTroopName = ""
			For $i = 0 To $iNumSlots - 1
				If $aBBAttackBar[$i][4] > 0 Then
					DeployBBTroop($aBBAttackBar[$i][0], $aBBAttackBar[$i][1] + 35, $aBBAttackBar[$i][2], $aBBAttackBar[$i][4], $iSide, $AltSide, $DP)
				EndIf

				If $sTroopName <> $aBBAttackBar[$i][0] Then
					_Sleep($g_iBBNextTroopDelay) ; wait before next troop
				Else
					_Sleep($DELAYRESPOND) ; we are still on same troop so lets drop them all down a bit faster
				EndIf
				$sTroopName = $aBBAttackBar[$i][0]
			Next
		EndIf
		$aBBAttackBar = GetAttackBarBB(True)
		If $aBBAttackBar = "" Then
			SetLog("All Troops Deployed", $COLOR_SUCCESS)
			$bTroopsDropped = True
		EndIf
	WEnd

	If Not $g_bRunState Then Return 
	If IsProblemAffect(True) Then Return

	;If not dropping Builder Machine first, drop it now
	If Not $g_bChkBBDropBMFirst Then
		If IsArray($g_aMachinePos) And StringInStr($g_aMachinePos[2], "Dead") = 0 Then 
			SetLog("Dropping BM Last")
			$bBMDeployed = DeployBM($g_aMachinePos, $iSide, $AltSide, $DP)
		EndIf
	EndIf
	
	If Not $g_bRunState Then Return 
	Return
EndFunc   ;==>AttackBB

Func DeployBBTroop($sName, $x, $y, $iAmount, $iSide, $AltSide, $aDP)
	If isProblemAffect(True) Then Return
    SetLog("Deploying " & $sName & " x" & String($iAmount), $COLOR_ACTION)
	SetDebugLog("countDP = " & UBound($aDP))
	If _Sleep($g_iBBSameTroopDelay) Then Return ; slow down dropping of troops
    PureClick($x, $y) ; select troop
	Local $iPoint = 0
	If UBound($aDP) > 0 Then
		For $j = 0 To $iAmount - 1
			$iPoint = Random(0, Ubound($aDP) - 1, 1)
			PureClick($aDP[$iPoint][1], $aDP[$iPoint][2])
			If _Sleep($g_iBBSameTroopDelay) Then Return ; slow down dropping of troops
		Next
	EndIf
	If $sName = "WallBreaker" Then PureClick($x, $y)
EndFunc

Func GetMachinePos()
	Local $aBMPos = QuickMIS("CNX", $g_sImgBBBattleMachine, 28, 560, 100, 650)
	Local $aCoords[3]
	If $aBMPos = -1 Then Return 0
	
    If IsArray($aBMPos) Then
		$aCoords[0] = $aBMPos[0][1] ;x
		$aCoords[1] = $aBMPos[0][2] ;y
		$aCoords[2] = $aBMPos[0][0] ;Name
		If $g_bChkDebugAttackBB Then SetLog("Machine Found: " & $aCoords[2], $COLOR_SUCCESS)
		Return $aCoords
	Else
		If $g_bChkDebugAttackBB Then SaveDebugImage("GetMachinePos", False)
    EndIf
	Return 0
EndFunc

Func DeployBM($aBMPos, $iSide, $AltSide, $aDP)
	If $aBMPos = 0 Then Return
	Local $bBMDeployed = False
	Local $BBDP[4][3] = [[1, 430, 130], [2, 128, 330], [3, 744, 330], [1, 596, 458]] ;dummy deploy point, 4 corner
	
	If IsArray($aBMPos) Then
		Local $MachineName = $aBMPos[2]
		SetLog("Deploying " & $MachineName, $COLOR_BLUE)
		PureClickP($aBMPos)
		If _Sleep(500) Then Return

		For $i = 1 To 3
			If isProblemAffect(True) Then Return
			If $g_bChkDebugAttackBB Then SetLog("[" & $i & "] Try Deploy " & $MachineName, $COLOR_ACTION)
			If $i = 1 Then
				Local $iPoint = Random(0, UBound($aDP) - 1, 1)
				PureClick($aDP[$iPoint][1], $aDP[$iPoint][2])
				If _Sleep(2000) Then Return
				If _PixelSearch(41, 556, 42, 557, Hex(0xC224F8, 6), 0, True, True, "DeployBM") Then
					$bBMDeployed = True
					If $g_bChkDebugAttackBB Then SetLog($MachineName & " Deployed", $COLOR_SUCCESS)
					PureClickP($aBMPos)
					ExitLoop
				Else
					If $g_bChkDebugAttackBB Then SaveDebugImage("DeployBM", True)
				EndIf
			Else
				For $dummyPoint = 0 To UBound($BBDP) - 1
					PureClick($BBDP[$dummyPoint][1], $BBDP[$dummyPoint][2])
				Next
			EndIf
		Next
		$bBMDeployed = True ;we dont know BM is deployed or no, just set it true as already try 3 time to deployBM
	EndIf
	
	Return $bBMDeployed
EndFunc ; DeployBM

Func CheckBMLoop($aBMPos = $g_aMachinePos)
	Local $count = 0, $loopcount = 0
	Local $BMPosX = 66, $BMDeadX = 93, $BMDeadColor
	Local $BMPosY = 562, $BMDeadY = 666
	Local $MachineName = ""
	
	If $aBMPos = 0 Then Return False
	If Not IsArray($aBMPos) Then Return False

	If StringInStr($aBMPos[2], "Copter") Then
		$MachineName = "Battle Copter"
		$BMPosX = 66
		$BMPosY = 562
	Else
		$MachineName = "Battle Machine"
	EndIf

	Local $bCountSameDamage = 1, $sTmpDamage = ""
	For $i = 1 To 5
		If IsProblemAffect(True) Then Return
		If Not $g_bRunState Then Return

		If QuickMIS("BC1", $g_sImgDirMachineAbility, $aBMPos[0] - 35, $aBMPos[1] - 40, $aBMPos[0] + 35, $aBMPos[1] + 40) Then
			If StringInStr($g_iQuickMISName, "Wait") Then
				If $g_bChkDebugAttackBB Then SetLog("Waiting " & $MachineName & " Ability", $COLOR_ACTION)
				ExitLoop
			ElseIf StringInStr($g_iQuickMISName, "Ability") Then
				PureClickP($aBMPos)
				SetLog("Activate " & $MachineName & " Ability", $COLOR_SUCCESS)
				ExitLoop
			EndIf
		EndIf

		$BMDeadColor = _GetPixelColor($BMDeadX, $BMDeadY, True)
		If _ColorCheck($BMDeadColor, Hex(0x484848, 6), 20, Default, $MachineName) Then
			SetLog($MachineName & " is Dead", $COLOR_INFO)
			Return False
		EndIf

		If $BMDeadColor = "000000" Then
			If $g_bChkDebugAttackBB Then SetLog($MachineName & " loopcheck : Battle Ended", $COLOR_DEBUG2)
			ExitLoop
		EndIf

		If _Sleep(500) Then Return
		If $g_bChkDebugAttackBB Then SetLog("[" & $i & "]" & $MachineName & " LoopCheck", $COLOR_ACTION)
		If $loopcount > 60 Then Return ;1 minute
		$loopcount += 1
	Next
	Return True
EndFunc

Func CheckWBLoop()
	Local $bRet
	If Not $g_bWBOnAttackBar Then Return
	Local $isGreyBanner = False, $ColorPickBannerX = 0, $iTroopBanners = 584, $bIsWBDead = True
	
	For $i = 0 To UBound($g_aWBOnAttackBar) - 1
		If Not $g_bRunState Then Return
		$ColorPickBannerX = $g_aWBOnAttackBar[$i][0] + 37
		$isGreyBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0x707070, 6), 10, Default, "isGreyBanner") ;Grey Banner on TroopSlot = Troop Die
		If $isGreyBanner Then 
			SetLog("WallBreaker Dead", $COLOR_INFO)
			ContinueLoop
		EndIf
		If QuickMIS("BC1", $g_sImgDirWallBreakerAbility, $g_aWBOnAttackBar[$i][0], $g_aWBOnAttackBar[$i][1] - 30, $g_aWBOnAttackBar[$i][0] + 70, $g_aWBOnAttackBar[$i][1] + 30) Then
			If StringInStr($g_iQuickMISName, "Wait") Then
				If $g_bChkDebugAttackBB Then SetLog("Waiting WallBreaker Ability", $COLOR_ACTION)
				$bIsWBDead = False
			ElseIf StringInStr($g_iQuickMISName, "Ability") Then
				Click($g_iQuickMISX, $g_iQuickMISY)
				SetLog("Activate WallBreaker Ability", $COLOR_SUCCESS)
				$bIsWBDead = False
			EndIf
			$bRet = True
		Else
			If $g_bChkDebugAttackBB Then SaveDebugImage("CheckWBLoop", False)
		EndIf
	Next
	If $bIsWBDead Then $bRet = False
	Return $bRet
EndFunc

Func IsBBAttackPage()
	Local $bRet = False
	If _ColorCheck(_GetPixelColor(22, 522, True), Hex(0xCD0D0D, 6), 20) Then ;check red color on surrender button
		$bRet = True
	EndIf
	Return $bRet
EndFunc

Func GetBBDPPixelSection($XMiddle, $YMiddle, $x, $y)
	Local $isLeft = ($x <= $XMiddle)
	Local $isTop = ($y <= $YMiddle )
	If $y > 565 Then Return 0 ;coord y overlap attackbar
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

	If QuickMIS("BC1", $g_sImgVersusBH, 50,50,800,570) Then
		ClickDrag($g_iQuickMISX, $g_iQuickMISY, $xMiddle, $yMiddle, $Delay) ;drag to center
		$aRet[0] = True
	Else
		SaveDebugImage("SetVersusBHToMid")
		ClickDrag(430, 500, 430, 300)	;If we cannot find BH on first search, try to scroll down. Maybe BH is at the bottom of the base.
		If _Sleep(1500) Then Return
		If QuickMIS("BC1", $g_sImgVersusBH, 50,50,800,570) Then
			ClickDrag($g_iQuickMISX, $g_iQuickMISY, $xMiddle, $yMiddle, $Delay) ;drag to center
			If _Sleep(1500) Then Return
			$aRet[0] = True
		Else
			SetDebugLog("SetVersusBHToMid(): Versus BH Not Found", $COLOR_INFO)
		EndIf
	EndIf
	Return $aRet
EndFunc

Func isInsideDiamondAttackBB($aCoords, $aaDiamond)
	Local $x = $aCoords[0], $y = $aCoords[1], $xD, $yD
	Local $aDiamond[2][2] = [[$aaDiamond[0], $aaDiamond[2]], [$aaDiamond[1], $aaDiamond[3]]]
	Local $aMiddle = [($aDiamond[0][0] + $aDiamond[1][0]) / 2, ($aDiamond[0][1] + $aDiamond[1][1]) / 2]
	Local $aSize = [$aMiddle[0] - $aDiamond[0][0], $aMiddle[1] - $aDiamond[0][1]]

	Local $DX = Abs($x - $aMiddle[0])
	Local $DY = Abs($y - $aMiddle[1])

	If ($DX / $aSize[0] + $DY / $aSize[1] <= 1) Then
		;If $g_bChkDebugAttackBB Then SetDebugLog("isInsideDiamondAttackBB: " & "[" & $x & "," & $y & "] Coord Inside Village", $COLOR_INFO)
		Return True ; Inside Village
	Else
		If $g_bChkDebugAttackBB Then SetDebugLog("isInsideDiamondAttackBB: " & "[" & $x & "," & $y & "] Coord Outside Village", $COLOR_DEBUG)
		Return False ; Outside Village
	EndIf

EndFunc   ;==>isInsideDiamondAttackBB

Func SearchRedLinesBB($bSecondAttack = False)
	Local $sDir = ""
	Local $aResult[0][3]
	Local $xstart[2] = [70, 430], $ystart = 30, $xend[2] = [430, 800], $yend = 600
	Local $aDiamond[4] = [110, 740, 100, 565] ;Left, Right, Top, Bottom
	Local $SearchRedLinesBBMultipleTime = 3
	
	If $bSecondAttack Then
		$sDir = $g_sImgDirBBRedlinesHZ
		$SearchRedLinesBBMultipleTime = 1
	Else
		$sDir = $g_sImgDirBBRedlinesLZ
	EndIf
	
	For $i = 1 To $SearchRedLinesBBMultipleTime
		Local $aTmp = QuickMIS("CNX", $sDir, $aDiamond[0], $aDiamond[2], $aDiamond[1], $aDiamond[3])
		SetDebugLog("aTmp" & $i & ": " & UBound($aTmp) & " Coords", $COLOR_INFO)
		For $j = 0 To UBound($aTmp) - 1
			Local $aCoord[2] = [$aTmp[$j][1], $aTmp[$j][2]]
			If Not isInsideDiamondAttackBB($aCoord, $aDiamond) Then ContinueLoop
			_ArrayAdd($aResult, $aTmp[$j][1] & "|" & $aTmp[$j][2] & "|" & $aTmp[$j][0])
		Next
		If _Sleep(50) Then Return
	Next
	
	If isProblemAffect(True) Then Return
	SetLog("Search BBDropPoint result : " & UBound($aResult) & " Coords", $COLOR_INFO)
	;_ArrayDisplay($aResult)

	Local $XMiddle = 445, $YMiddle = 340
	Local $aaCoords[0][4], $iSide
	Local $THhOffset = 100

	For $i = 0 To UBound($aResult) - 1
		$iSide = GetBBDPPixelSection($XMiddle, $YMiddle, $aResult[$i][0], $aResult[$i][1])
		If $aResult[$i][0] < $XMiddle And $aResult[$i][1] < $YMiddle And $aResult[$i][0] > ($XMiddle - $THhOffset) And $aResult[$i][1] > ($YMiddle - $THhOffset) Then ContinueLoop ;TL
		If $aResult[$i][0] > $XMiddle And $aResult[$i][1] < $YMiddle And $aResult[$i][0] < ($XMiddle + $THhOffset) And $aResult[$i][1] > ($YMiddle - $THhOffset) Then ContinueLoop ;BL
		If $aResult[$i][0] < $XMiddle And $aResult[$i][1] > $YMiddle And $aResult[$i][0] > ($XMiddle - $THhOffset) And $aResult[$i][1] < ($YMiddle + $THhOffset) Then ContinueLoop ;BR
		If $aResult[$i][0] > $XMiddle And $aResult[$i][1] > $YMiddle And $aResult[$i][0] < ($XMiddle + $THhOffset) And $aResult[$i][1] < ($YMiddle + $THhOffset) Then ContinueLoop ;TR
		_ArrayAdd($aaCoords, $iSide & "|" & $aResult[$i][0] & "|" & $aResult[$i][1] & "|" & $aResult[$i][2])
	Next
	SetLog("Cleared BBDropPoint result : " & UBound($aaCoords) & " Coords", $COLOR_INFO)
	;If $g_bChkDebugAttackBB Then DebugAttackBBImage($aaCoords)
	Return $aaCoords
EndFunc

Func GetBBDropPoint($bSecondAttack = False)

	;SetVersusBHToMid()
	Local $hTimer = TimerInit()
	SetLog("GetBBDropPoint start", $COLOR_ACTION)
	$g_bAttackActive = True
	SuspendAndroid()

	Local $aaCoords = SearchRedLinesBB($bSecondAttack)

	Local $aDPResult = SortBBDP($aaCoords)
	SetLog("BBDropPoint after sort : " & UBound($aDPResult) & " Coords", $COLOR_INFO)
	;_ArrayDisplay($aDPResult)

	If isProblemAffect(True) Then Return
	ResumeAndroid()
	$g_bAttackActive = False
	SetLog("BBDropPoint Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_ACTION)
	If $g_b1SideBBAttack Then
		Switch $g_i1SideBBAttack
			Case 0 ;Lava launcher
				FindLavaLauncher()
			Case 1 ;Air Bomb
				FindAirBomb()
			Case 2 ;Mega Telsa
				FindMegaTelsa()
			Case 3 ;Guard Post
				FindGuardPost()
		EndSwitch
	EndIf

	If $g_bChkDebugAttackBB Then SetLog("MainSide = " & $g_BBDPSide)
	If $g_bChkDebugAttackBB Then DebugAttackBBImage($aDPResult, $g_BBDPSide)

	Return $aDPResult
EndFunc

Func SortBBDP($aDropPoints)
	Local $aResult[0][4]
	Local $TmpYL = 0, $TmpXR = 0, $DPChange = 0, $DpDistance = 5
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

Func FindLavaLauncher()
	Local $LavaSide = 0
	If QuickMIS("BC1", $g_sImgOpponentBuildingsBB & "LavaLauncher\", 50,50,800,570) Then
		If $g_bChkDebugAttackBB Then SetLog("Found Lava Launcher at " & $g_iQuickMISX & "," & $g_iQuickMISY, $COLOR_INFO)
		$LavaSide = GetBBDPPixelSection(430, 275, $g_iQuickMISX, $g_iQuickMISY)
		If $g_bChkDebugAttackBB Then SetLog("LavaSide: " & $LavaSide, $COLOR_INFO)
		$g_BBDPSide = $LavaSide
	EndIf
EndFunc

Func FindAirBomb()
	Local $AirBombSide = 0
	If QuickMIS("BC1", $g_sImgOpponentBuildingsBB & "AirBomb\", 50,50,800,570) Then
		If $g_bChkDebugAttackBB Then SetLog("Found Air Bomb at " & $g_iQuickMISX & "," & $g_iQuickMISY, $COLOR_INFO)
		$AirBombSide = GetBBDPPixelSection(430, 275, $g_iQuickMISX, $g_iQuickMISY)
		If $g_bChkDebugAttackBB Then SetLog("AirBombSide: " & $AirBombSide, $COLOR_INFO)
		$g_BBDPSide = $AirBombSide
	EndIf
EndFunc

Func FindMegaTelsa()
	Local $MegaTelsaSide = 0
	If QuickMIS("BC1", $g_sImgOpponentBuildingsBB & "MegaTelsa\", 50,50,800,570) Then
		If $g_bChkDebugAttackBB Then SetLog("Found Mega Telsa at " & $g_iQuickMISX & "," & $g_iQuickMISY, $COLOR_INFO)
		$MegaTelsaSide = GetBBDPPixelSection(430, 275, $g_iQuickMISX, $g_iQuickMISY)
		If $g_bChkDebugAttackBB Then SetLog("MegaTelsaSide: " & $MegaTelsaSide, $COLOR_INFO)
		$g_BBDPSide = $MegaTelsaSide
	EndIf
EndFunc

Func FindGuardPost()
	Local $GuardPostSide = 0
	If QuickMIS("BC1", $g_sImgOpponentBuildingsBB & "GuardPost\", 50,50,800,570) Then
		If $g_bChkDebugAttackBB Then SetLog("Found GuardPostSide at " & $g_iQuickMISX & "," & $g_iQuickMISY, $COLOR_INFO)
		$GuardPostSide = GetBBDPPixelSection(430, 275, $g_iQuickMISX, $g_iQuickMISY)
		If $g_bChkDebugAttackBB Then SetLog("GuardPostSide: " & $GuardPostSide, $COLOR_INFO)
		$g_BBDPSide = $GuardPostSide
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
			_GDIPlus_GraphicsDrawRect($hGraphic, $aCoords[$i][1] - 2, $aCoords[$i][2] - 2, 4, 4, $color)
			If UBound($aCoords) < 100 Then
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

Func BBBarbarianHead($sLogText = "BBBarbarianHead")
	If _CheckPixel($aBlackHead, True, Default, $sLogText) Then
		SetLog("Battle Ended, Gold Icon Found", $COLOR_DEBUG2)
		Return True
	Else
		Return False
	EndIf
EndFunc

Func BBAttackReport()

	Local $sCurrentTrophy = $g_aiCurrentLootBB[$eLootTrophyBB]
	Local $sSearch = 1, $sTH = "--", $sType = "BB", $sDamage = 0
	Local $sGold = 0, $sElix = 0, $sDE = 0, $sTrophy = 0, $sStars = 0
	Local $AtkLogTxt = ""
	
	$sGold = getOcrAndCapture("coc-Builders", 525, 400, 86, 18, True)
	$sTrophy = getOcrAndCapture("coc-Builders", 550, 437, 38, 18, True)
	$sDamage = getOcrBBDamageReport(365, 280)
	
	If Number($sDamage) = 200 Then 
		$sStars = 6
	ElseIf Number($sDamage) > 100 Then 
		If $g_bChkDebugAttackBB Then SetLog("Damage % more than 100, Adding delay for animation", $COLOR_ACTION)
		If _Sleep(3000) Then Return
		$sStars = 3
		If _ColorCheck(_GetPixelColor(324, 214, True), Hex(0xB5DCF0, 6), 20, Default, "BBAttackReport") Then $sStars = 4 ; 1 silver
		If _ColorCheck(_GetPixelColor(430, 180, True), Hex(0xBCDFF3, 6), 20, Default, "BBAttackReport") Then $sStars = 5 ; 2 silver
		;If _ColorCheck(_GetPixelColor(550, 220, True), Hex(0xB8DCF0, 6), 20, Default, "BBAttackReport") Then $sStars = 6 ; 3 silver
	Else
		If _ColorCheck(_GetPixelColor(324, 214, True), Hex(0xEA9E2C, 6), 20, Default, "BBAttackReport") Then $sStars = 1 ; 1 bronze
		If _ColorCheck(_GetPixelColor(430, 180, True), Hex(0xECA030, 6), 20, Default, "BBAttackReport") Then $sStars = 2 ; 2 bronze
		If _ColorCheck(_GetPixelColor(550, 220, True), Hex(0xE99D2C, 6), 20, Default, "BBAttackReport") Then $sStars = 3 ; 3 bronze
	EndIf
	
	SetLog("Attack Result :", $COLOR_INFO)
	SetLog("Gain Stars: [" & $sStars & "], Trophy: [" & $sTrophy & "], Gold: [" & $sGold & "], Destruction: [" & $sDamage & "%]", $COLOR_SUCCESS)
	
	$AtkLogTxt =  StringFormat("%2s", $g_iCurAccount + 1) & "|" & _NowTime(4) & "|"
	$AtkLogTxt &= StringFormat("%4d", $sCurrentTrophy) & "|"
	$AtkLogTxt &= StringFormat("%3d", $sSearch) & "|"
	$AtkLogTxt &= StringFormat("%2s", $sTH) & "|"
	$AtkLogTxt &= StringFormat("%2s", $sType) & "|"
	$AtkLogTxt &= StringFormat("%5d", $sGold) & "|"
	$AtkLogTxt &= StringFormat("%5d", $sElix) & "|"
	$AtkLogTxt &= StringFormat("%5d", $sDE) & "|"
	$AtkLogTxt &= StringFormat("%3d", $sTrophy) & "|"
	$AtkLogTxt &= StringFormat("%1d", $sStars) & "|"
	$AtkLogTxt &= StringFormat("%3d", $sDamage) & "|"
	If $g_bIsBBevent Then $AtkLogTxt &= $g_sCGCurrentEventName
	
	If Int($sTrophy) >= 0 Then
		SetAtkLog($AtkLogTxt, "", $COLOR_DEBUG)
	Else
		SetAtkLog($AtkLogTxt, "", $COLOR_ACTION)
	EndIf
	
	If $g_bChkDebugAttackBB Then SaveDebugImage("BBAttackReport", True)
EndFunc

Func ShouldStopAttackonCG()
	Local $bRet = False
	Local $aCGEventLowerZone[4] = ["StarLab", "Clock", "Hall", "Gem"]
	
	If Not $g_bIsBBevent Then Return
	For $i In $aCGEventLowerZone 
		If StringInStr($g_sCGCurrentEventName, $i) Then
			SetLog("Current Event:" & $g_sCGCurrentEventName & ", Should stop attack as it only avail on Lower Zone", $COLOR_ACTION)
			$bRet = True
			ExitLoop
		EndIf
	Next
	Return $bRet
EndFunc