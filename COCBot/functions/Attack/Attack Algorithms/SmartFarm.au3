; #FUNCTION# ====================================================================================================================
; Name ..........: Smart Farm
; Description ...: This file Includes several files in the current script.
; Syntax ........: #include
; Parameters ....: None
; Return values .: None
; Author ........: ProMac Jan 2017
; Modified ......: ProMac Jul 2018
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func TestSmartFarm()

	$g_iDetectedImageType = 0

	; Getting the Run state
	Local $RuntimeA = $g_bRunState
	$g_bRunState = True

	SetLog("Starting the SmartFarm Attack Test()", $COLOR_INFO)

	CheckMainScreen(False, $g_bStayOnBuilderBase, "TestSmartFarm")
	;CheckIfArmyIsReady()
	ClickAway()
	If _Sleep(100) Then Return FuncReturn()
	If _Sleep(100) Then Return
	PrepareSearch()
	If _Sleep(1000) Then Return FuncReturn()
	VillageSearch()
	If _Sleep(100) Then Return FuncReturn()

	PrepareAttack($g_iMatchMode)

	$g_bAttackActive = True
	; Variable to return : $Return[3]  [0] = To attack InSide  [1] = Quant. Sides  [2] = Name Sides
	Local $Nside = ChkSmartFarm()
	
	AttackSmartFarm($Nside[1], $Nside[2])
	$g_bAttackActive = False

	ReturnHome($g_bTakeLootSnapShot)

	SetLog("Finish the SmartFarm Attack()", $COLOR_INFO)

	$g_bRunState = $RuntimeA

EndFunc   ;==>TestSmartFarm

; Collectors | Mines | Drills | All (Default)
Func ChkSmartFarm($bTest = False, $iMode = $REDLINE_REAL)

	; Initial Timer
	Local $hTimer = TimerInit()
	
	If $bTest Then CheckZoomOut()
	
	_CaptureRegion2() ; ensure full screen is captured (not ideal for debugging as clean image was already saved, but...)
	If $g_bChkForceEdgeSmartfarm Then 
		$iMode = $REDLINE_EDGE
	Else
		$iMode = $REDLINE_REAL
	EndIf
	
	_GetRedArea($iMode)
	
	; TL , TR , BL , BR
	Local $aMainSide[4] = [0, 0, 0, 0]
	Local $aReturn[3] = [True, 1, "TR"]
	SetDebugLog(" - INI|SmartFarm detection.", $COLOR_INFO)
	
	$hTimer = TimerInit()
	If $g_bDebugSmartFarm Then
		If $g_iSearchTH = "-" Then FindTownHall()
		; [0] = Level , [1] = Xaxis , [2] = Yaxis , [3] = Distances to redlines
		Local $THdetails[3] = [$g_iSearchTH, $g_iTHx, $g_iTHy]
		SetLog("TH Details: " & _ArrayToString($THdetails, "|"))
	EndIf
	
	; [0] = x , [1] = y , [2] = Distance to Redline ,[3] = In/Out, [4] = Side,  [5]= Is array Dim[2] with 5 coordinates to deploy
	Local $aAll = SmartFarmDetection()
	SetDebugLog(" TOTAL detection Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	
	If Ubound($aAll) = 0 Then 
		SetLog("Strange ERR: no identified resource building found", $COLOR_DEBUG2)
		$aAll = SmartFarmDetection()
	EndIf
	
	If Ubound($aAll) = 0 Then 
		SetLog("Still got 0 building", $COLOR_DEBUG2)
		Return $aReturn
	EndIf
	
	; [0] = x , [1] = y , [2] = Side , [3] = In/out , [4] = Side,  [5]= Is string with 5 coordinates to deploy
	Local $aResourcesOUT[0][6]
	Local $aResourcesIN[0][6]
	
	For $x = 0 To UBound($aAll) - 1
		; Only proceeds when the x exist , not -1
		If $aAll[$x][0] <> -1 Then
			If $aAll[$x][2] = "In" Then
				ReDim $aResourcesIN[UBound($aResourcesIN) + 1][6]
				For $t = 0 To 5 ; Fill the variables
					$aResourcesIN[UBound($aResourcesIN) - 1][$t] = $aAll[$x][$t]
				Next
			Else ; Out
				ReDim $aResourcesOUT[UBound($aResourcesOUT) + 1][6]
				For $t = 0 To 5 ; Fill the variables
					$aResourcesOUT[UBound($aResourcesOUT) - 1][$t] = $aAll[$x][$t]
				Next
			EndIf
		EndIf		
	Next
	
	; Total of Resources and %
	Local $TotalOfResources = UBound($aResourcesIN) + UBound($aResourcesOUT)
	SetLog("Total of Resources: " & $TotalOfResources, $COLOR_INFO)
	SetLog(" - Inside the Village: " & UBound($aResourcesIN), $COLOR_INFO)
	SetLog(" - Outside the village: " & UBound($aResourcesOUT), $COLOR_INFO)

	$g_sResourcesIN = UBound($aResourcesIN)
	$g_sResourcesOUT = UBound($aResourcesOUT)
	
	Local $aTL = _ArrayFindAll($aAll, "TL", 0, 0, 0, 0, 3)
	Local $aTR = _ArrayFindAll($aAll, "TR", 0, 0, 0, 0, 3)
	Local $aBL = _ArrayFindAll($aAll, "BL", 0, 0, 0, 0, 3)
	Local $aBR = _ArrayFindAll($aAll, "BR", 0, 0, 0, 0, 3)
	$aMainSide[0] = UBound($aTL)
	$aMainSide[1] = UBound($aTR)
	$aMainSide[2] = UBound($aBL)
	$aMainSide[3] = UBound($aBR)
	
	$g_sResBySide = _ArrayToString($aMainSide)
	
	; Inside , Outside
	Local $bAttackInside = False
	Local $Percentage_In = Int((UBound($aResourcesIN) / $TotalOfResources) * 100), $Percentage_Out = Int((UBound($aResourcesOUT) / $TotalOfResources) * 100)

	; FROM GUI
	Local $PercentageInSide = Int($g_iTxtInsidePercentage) ; Percentage to force ONE SIDE ATTACK
	Local $PercentageOutSide = Int($g_iTxtOutsidePercentage) ; Percentage to force to attack all sides with at least with one Resource

	If $Percentage_In > $PercentageInSide Then $bAttackInside = True

	Local $TxtLog = ($bAttackInside = True) ? ("Inside with " & $Percentage_In & "%") : ("Outside with " & $Percentage_Out & "%")
	SetLog(" - Best Attack will be " & $TxtLog)
	If Not $g_bRunState Then Return

	Local $OneSide = Floor($TotalOfResources / 4)
	Local $aHowManySides[0]
	
	SetLog("Resource Count TL: " & $aMainSide[0], $COLOR_SUCCESS)
	SetLog("Resource Count TR: " & $aMainSide[1], $COLOR_SUCCESS)
	SetLog("Resource Count BL: " & $aMainSide[2], $COLOR_SUCCESS)
	SetLog("Resource Count BR: " & $aMainSide[3], $COLOR_SUCCESS)
	
	Local $sSideiSide[4][2] = [ _
			["TL", $aMainSide[0]], _
			["TR", $aMainSide[1]], _
			["BL", $aMainSide[2]], _
			["BR", $aMainSide[3]]]
	_ArraySort($sSideiSide, 1, 0, 0, 1)
	SetDebugLog("side sorted : " & _ArrayToString($sSideiSide))
	
	; Determinate the higher value if $bAttackInside is True
	Local $aBestSideToAttack[0]
	
	If $bAttackInside Then
		Local $iIndexSide = _ArrayMaxIndex($sSideiSide, 1, 0, 1)
		_ArrayAdd($aBestSideToAttack, $sSideiSide[$iIndexSide][0])
		SetDebugLog("SideToAttack [" & Ubound($aBestSideToAttack) & "] : " & $aBestSideToAttack[0])
		SetLog("Best Side To Attack Inside: " & $aBestSideToAttack[0])
	Else
		For $i = 0 To $g_iCmbMaxAttackSide - 1
			_ArrayAdd($aBestSideToAttack, $sSideiSide[$i][0])
		Next
		SetDebugLog("SideToAttack [" & Ubound($aBestSideToAttack) & "] : " & _ArrayToString($aBestSideToAttack))
	EndIf
	
	SetLog("Attack at " & UBound($aBestSideToAttack) & " Side(s) - " & _ArrayToString($aBestSideToAttack), $COLOR_INFO)
	SetLog("SmartFarm Check Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	If Not $g_bRunState Then Return

	; DEBUG , image with all information
	If $g_bDebugSmartFarm Then
		SetLog("DebugSmartFarm enabled", $COLOR_DEBUG)
		DebugImageSmartFarm($THdetails, $aResourcesIN, $aResourcesOUT, Round(TimerDiff($hTimer) / 1000, 2) & "'s", _ArrayToString($aBestSideToAttack))
	EndIf

	; Variable to return : $Return[3]  [0] = To attack InSide  [1] = Quant. Sides  [2] = Name Sides
	$aReturn[0] = $bAttackInside
	$aReturn[1] = UBound($aBestSideToAttack)
	$aReturn[2] = _ArrayToString($aBestSideToAttack)
	
	Return $aReturn
EndFunc   ;==>ChkSmartFarm

Func SmartFarmDetection()
	
	; This Function will fill an Array with several informations after Mines, Collectores or Drills detection with Imgloc
	; [0] = x , [1] = y , [2] = Distance to Redline ,[3] = In/Out, [4] = Side,  [5]= Is array Dim[2] with 5 coordinates to deploy
	If Not $g_bRunState Then Return
	
	; Initial Timer
	Local $hTimer = TimerInit()
	Local $aXY[2], $sInOut, $aPoint, $sPoint, $sSide, $iSide, $aRet[0][6], $bInOut = False
	
	Local $aAll = QuickMIS("CNX", $g_sImgSearchAll, $g_OuterDiamondLeft, $g_OuterDiamondTop, $g_OuterDiamondRight, $g_OuterDiamondBottom)
	If IsArray($aAll) And UBound($aAll) > 0 Then
		RemoveDupCNX($aAll, 1, 5) ;remove duplicate/same spot detection
		For $i = 0 To UBound($aAll) - 1
			$sPoint = ""
			$aXY[0] = $aAll[$i][1]
			$aXY[1] = $aAll[$i][2]
			If Not IsInsideDiamond($aXY) Then ContinueLoop ;skip building out of diamond
			$sSide = Side($aXY) ;sSide = "TL", "BL", "TR", "BR"
			Switch $sSide
				Case "TL"
					$iSide = $eVectorLeftTop
				Case "BL"
					$iSide = $eVectorRightBottom
				Case "TR"
					$iSide = $eVectorRightTop
				Case "BR"
					$iSide = $eVectorLeftBottom
			EndSwitch
			
			$bInOut = isInsideSmallDiamond($aXY) ;check from center diamond
			If $bInOut Then 
				$sInOut = "In"
			Else
				$sInOut = "Out"
			EndIf
			
			$aPoint = _FindPixelCloser(_GetVectorOutZone($iSide), $aXY, 4)
			For $p = 0 To UBound($aPoint) - 1
				$sPoint &= _ArrayToString($aPoint[$p]) & ","
			Next
			If StringRight($sPoint, 1) = "," Then $sPoint = StringTrimRight($sPoint, 1)
			;SetDebugLog("$sPoint : " & $sPoint)
			
			Local $tmparray[1][6] = [[$aXY[0], $aXY[1], $sInOut, $sSide, $sPoint, $aAll[$i][0] & "_" & $aAll[$i][3]]]
			_ArrayAdd($aRet, $tmparray)
		Next
		;succeed
		SetDebugLog("Found " & Ubound($aRet) & " Building on SmartFarmDetection")
		SetLog("SmartFarmDetection Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	Else
		SetLog("SmartFarmDetection : ERROR|NONE Building Detected", $COLOR_INFO)
	EndIf
	Return $aRet
EndFunc   ;==>SmartFarmDetection

Func Side($Pixel)
	Local $sReturn = ""
	; Using to determinate the Side position on Screen |Bottom Right|Bottom Left|Top Left|Top Right|
	If IsArray($Pixel) And UBound($Pixel) = 2 Then
		If $Pixel[0] < $g_DiamondMiddleX And $Pixel[1] <= $g_DiamondMiddleY Then $sReturn = "TL"
		If $Pixel[0] >= $g_DiamondMiddleX And $Pixel[1] < $g_DiamondMiddleY Then $sReturn = "TR"
		If $Pixel[0] < $g_DiamondMiddleX And $Pixel[1] > $g_DiamondMiddleY Then $sReturn = "BL"
		If $Pixel[0] >= $g_DiamondMiddleX And $Pixel[1] >= $g_DiamondMiddleY Then $sReturn = "BR"
		If $sReturn = "" Then
			SetLog("Error on SIDE...: " & _ArrayToString($Pixel), $COLOR_ERROR)
			$sReturn = "ERROR"
		EndIf
		Return $sReturn
	Else
		SetLog("ERROR SIDE|SmartFarm!!", $COLOR_ERROR)
	EndIf
EndFunc   ;==>Side

Func IsInsideSmallDiamondXY($x, $y)
	Local $aXY[2] = [$x, $y]
	Return isInsideSmallDiamond($aXY)
EndFunc

Func IsInsideSmallDiamond($aCoords)
	Local $x = $aCoords[0], $y = $aCoords[1]
	Local $Left, $Right, $Top, $Bottom, $bRet = False
	Local $iOffsetX = Round((Floor(130 * $g_iZoomFactor))), $iOffsetY = Round((Floor(100 * $g_iZoomFactor)))
	$Left = $g_InnerDiamondLeft + $iOffsetX
	$Right = $g_InnerDiamondRight - $iOffsetX
	$Top = $g_InnerDiamondTop + $iOffsetY
	$Bottom = $g_InnerDiamondBottom - $iOffsetY
	
	Local $aDiamond[2][2] = [[$Left, $Top], [$Right, $Bottom]]
	Local $aMiddle = [($aDiamond[0][0] + $aDiamond[1][0]) / 2, ($aDiamond[0][1] + $aDiamond[1][1]) / 2]
	Local $aSize = [$aMiddle[0] - $aDiamond[0][0], $aMiddle[1] - $aDiamond[0][1]]

	Local $DX = Abs($x - $aMiddle[0])
	Local $DY = Abs($y - $aMiddle[1])

	If ($DX / $aSize[0] + $DY / $aSize[1] <= 1) Then
		;If $g_bDebugSetLog Then SetDebugLog("isInsideSmallDiamond: " & "[" & $x & "," & $y & "] Coord Inside SmallDiamond", $COLOR_DEBUG1)
		$bRet = True
	Else
		;If $g_bDebugSetLog Then SetDebugLog("isInsideSmallDiamond: " & "[" & $x & "," & $y & "] Coord Outside SmallDiamond", $COLOR_DEBUG1)
		$bRet = False
	EndIf
	Return $bRet
EndFunc   ;==>isInsideSmallDiamond

Func SetSlotSpecialTroops()
	$g_iKingSlot = -1
	$g_iQueenSlot = -1
	$g_iWardenSlot = -1
	$g_iChampionSlot = -1
	$g_iClanCastleSlot = -1
	$g_iMinionPSlot = -1
	$g_iDukeSlot = -1
	
	For $i = 0 To UBound($g_avAttackTroops) - 1
		Switch $g_avAttackTroops[$i][0]
			Case $eCastle, $eWallW, $eBattleB, $eStoneS, $eSiegeB, $eLogL, $eFlameF, $eBattleD, $eTroopL, $eSkyW
				$g_iClanCastleSlot = $i
			Case $eKing
				$g_iKingSlot = $i
			Case $eQueen
				$g_iQueenSlot = $i
			Case $eWarden
				$g_iWardenSlot = $i
			Case $eChampion
				$g_iChampionSlot = $i
			Case $eMinionP
				$g_iMinionPSlot = $i
			Case $eDuke
				$g_iDukeSlot = $i
		EndSwitch
	Next

	SetDebugLog("SetSlotSpecialTroops() King Slot: " & $g_iKingSlot)
	SetDebugLog("SetSlotSpecialTroops() Queen Slot: " & $g_iQueenSlot)
	SetDebugLog("SetSlotSpecialTroops() Warden Slot: " & $g_iWardenSlot)
	SetDebugLog("SetSlotSpecialTroops() Champion Slot: " & $g_iChampionSlot)
	SetDebugLog("SetSlotSpecialTroops() Minion Prince Slot: " & $g_iMinionPSlot)
	SetDebugLog("SetSlotSpecialTroops() Dargon Duke Slot: " & $g_iDukeSlot)
	SetDebugLog("SetSlotSpecialTroops() Clan Castle Slot: " & $g_iClanCastleSlot)

EndFunc ;==>SetSlotSpecialTroops

Func UpdateSpecialTroops($iTroopIndex = $eCastle, $bDeployed = False)
	
	For $i = 0 To UBound($g_avAttackTroops) - 1
		Switch $g_avAttackTroops[$i][0]
			Case $eCastle, $eWallW, $eBattleB, $eStoneS, $eSiegeB, $eLogL, $eFlameF, $eBattleD, $eTroopL, $eSkyW
				SetDebugLog("UpdateSpecialTroops() CC/Siege Dropped: " & String($bDeployed))
			Case $eKing
				$g_bDropKing = $bDeployed
				SetDebugLog("UpdateSpecialTroops() King Dropped: " & String($g_bDropKing))
			Case $eQueen
				$g_bDropQueen = $bDeployed
				SetDebugLog("UpdateSpecialTroops() Queen Dropped: " & String($g_bDropQueen))
			Case $eWarden
				$g_bDropWarden = $bDeployed
				SetDebugLog("UpdateSpecialTroops() Warden Dropped: " & String($g_bDropWarden))
			Case $eChampion
				$g_bDropChampion = $bDeployed
				SetDebugLog("UpdateSpecialTroops() Champion Dropped: " & String($g_bDropChampion))
			Case $eMinionP
				$g_bDropMinionP = $bDeployed
				SetDebugLog("UpdateSpecialTroops() Minion Prince Dropped: " & String($g_bDropMinionP))
			Case $eDuke
				$g_bDropDuke = $bDeployed
				SetDebugLog("UpdateSpecialTroops() Dargon Duke Dropped: " & String($g_bDropDuke))
		EndSwitch
	Next	
EndFunc ;==>UpdateSpecialTroops

Func DebugImageSmartFarm($THdetails, $aIn, $aOut, $sTime, $aBestSideToAttack)

	_CaptureRegion()

	; Store a copy of the image handle
	Local $editedImage = $g_hBitmap
	;Local $subDirectory = @ScriptDir & "\SmartFarm\"
	Local $subDirectory = $g_sProfileTempDebugPath & "\SmartFarm\"
	DirCreate($subDirectory)

	; Create the timestamp and filename
	Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
	Local $Time = @HOUR & "." & @MIN & "." & @SEC
	Local $fileName = "SmartFarm" & "_" & $Date & "_" & $Time & ".png"

	; Needed for editing the picture
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($editedImage)
	Local $hPenRed = _GDIPlus_PenCreate(0xFFFF0000, 2) ; Create a pencil Color FF0000/RED
	Local $hPenBlack = _GDIPlus_PenCreate(0xFF00FF00, 2) ; Create a pencil Color FFFFFF/BLACK
	Local $hPenCyan = _GDIPlus_PenCreate(0xFF00FFFF, 2) ; Create a pencil Color BLUE

	; TH
	addInfoToDebugImage($hGraphic, $hPenRed, "TH_" & $THdetails[0] & "|" & $THdetails[1] & "|" & $THdetails[2], $THdetails[1], $THdetails[2])	

	Local $tempObbj, $tempObbjs
	For $i = 0 To UBound($aIn) - 1
		; Objects Detected Inside the village
		addInfoToDebugImage($hGraphic, $hPenBlack, $aIn[$i][3] & "|" & $aIn[$i][4] & "|" & $aIn[$i][2] & "|" & $aIn[$i][5], $aIn[$i][0], $aIn[$i][1])
		
		; Deploy points near Red Line
		Local $aPoints = StringSplit($aIn[$i][4], ",", $STR_NOCOUNT)
		;SetDebugLog("aPoints: " & _ArrayToString($aPoints))
		If IsArray($aPoints) And UBound($aPoints) > 0 Then
			For $p = 0 To UBound($aPoints) - 1
				Local $aPoint = StringSplit($aPoints[$p], "|", $STR_NOCOUNT)
				If IsArray($aPoint) And UBound($aPoint) = 2 Then
					;SetDebugLog("aPoint: " & _ArrayToString($aPoint))
					_GDIPlus_GraphicsDrawRect($hGraphic, $aPoint[0], $aPoint[1], 3, 3, $hPenRed)
				EndIf
			Next
		EndIf
	Next

	For $i = 0 To UBound($aOut) - 1
		; Objects Detected Outside the village
		addInfoToDebugImage($hGraphic, $hPenBlack, $aOut[$i][3] & "|" & $aOut[$i][4] & "|" & $aOut[$i][2] & "|" & $aOut[$i][5], $aOut[$i][0], $aOut[$i][1])

		; Deploy points near Red Line
		Local $aPoints = StringSplit($aOut[$i][4], ",", $STR_NOCOUNT)
		;SetDebugLog("aPoints: " & _ArrayToString($aPoints))
		If IsArray($aPoints) And UBound($aPoints) > 0 Then
			For $p = 0 To UBound($aPoints) - 1
				Local $aPoint = StringSplit($aPoints[$p], "|", $STR_NOCOUNT)
				If IsArray($aPoint) And UBound($aPoint) = 2 Then
					;SetDebugLog("aPoint: " & _ArrayToString($aPoint))
					_GDIPlus_GraphicsDrawRect($hGraphic, $aPoint[0], $aPoint[1], 3, 3, $hPenCyan)
				EndIf
			Next
		EndIf
	Next

	_GDIPlus_GraphicsDrawString($hGraphic, $sTime & " - " & $aBestSideToAttack, 370, 70, "ARIAL", 20)
	; Save the image and release any memory
	_GDIPlus_ImageSaveToFile($editedImage, $subDirectory & $fileName)
	_GDIPlus_PenDispose($hPenRed)
	_GDIPlus_PenDispose($hPenBlack)
	_GDIPlus_PenDispose($hPenCyan)
	_GDIPlus_GraphicsDispose($hGraphic)
	SetLog("Debug Image saved!", $COLOR_SUCCESS)

EndFunc   ;==>DebugImageSmartFarm

Func AttackSmartFarm($Nside, $SIDESNAMES)

	SetLog(" ====== Start Smart Farm Attack ====== ", $COLOR_INFO)

	SetSlotSpecialTroops()

	Local $nbSides = Null
	Local $GiantComp = 0

	Switch $Nside
		Case 1 ;Single sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on a single side", $COLOR_INFO)
			$nbSides = $Nside
		Case 2 ;Two sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on two sides", $COLOR_INFO)
			$nbSides = $Nside
		Case 3 ;Three sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on three sides", $COLOR_INFO)
			$nbSides = $Nside
		Case 4 ;All sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on all sides", $COLOR_INFO)
			$nbSides = $Nside
	EndSwitch

	If Not $g_bRunState Then Return

	$g_iSidesAttack = $nbSides

	; Reset the deploy Giants points , spread along red line
	$g_iSlotsGiants = 0
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

	SetDebugLog("Giants : " & $GiantComp & "  , per side: " & ($GiantComp / $nbSides) & " / deploy points per side: " & $g_iSlotsGiants)
	
	;$listInfoDeploy: troopKind, Number of Sides, waves, Max waves, deploy Points per Edge
	Local $listInfoDeploy[48][5] = [[$eGole, $nbSides, 1, 1, 2] _
				, [$eLava, $nbSides, 1, 1, 2] _
				, [$eIceH, $nbSides, 1, 1, 2] _
				, [$eIceG, $nbSides, 1, 1, 2] _
				, [$eYeti, $nbSides, 1, 1, 2] _
				, [$eGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
				, [$eSGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
				, [$eGSkel, $nbSides, 1, 1, 0] _
				, [$eRootR, $nbSides, 1, 1, 0] _
				, [$eRGhost, $nbSides, 1, 1, 0] _
				, [$eDrag, $nbSides, 1, 1, 0] _
				, [$eSDrag, $nbSides, 1, 1, 0] _
				, [$eBall, $nbSides, 1, 1, 0] _
				, [$eRBall, $nbSides, 1, 1, 0] _
				, [$eBabyD, $nbSides, 1, 1, 0] _
				, [$eInfernoD, $nbSides, 1, 1, 0] _
				, [$eHogs, $nbSides, 1, 1, 0] _
				, [$eSHogs, $nbSides, 1, 1, 0] _
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
				, [$eAppWard, $nbSides, 1, 1, 0] _
				, ["CC", 1, 1, 1, 1] _
				, ["HEROES", 1, 2, 1, 1]]
	If $g_bCustomDropOrderEnable Then
		Local $aTmpListInfoDeploy = $listInfoDeploy
		For $i = 0 To UBound($g_ahCmbDropOrder) - 1
			Local $iValue = $g_aiCmbCustomDropOrder[$i]
			If $g_bDebugSmartFarm Then SetDebugLog("iValue : " & $iValue & " [" & GetTroopName($iValue) & "]")
			If $iValue <> -1 And $iValue < $eKing Then
				Local $iDelete = _ArraySearch($aTmpListInfoDeploy, $iValue, 0, 0, 0, 0, 1, 0)
				If $iDelete <> -1 Then
					If $g_bDebugSmartFarm Then SetDebugLog("iDelete : " & $iDelete)
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
			EndIf
		Next
		$listInfoDeploy = $aTmpListInfoDeploy
	EndIf
	;_ArrayDisplay($listInfoDeploy, "listInfoDeploy")
	
	$g_bIsCCDropped = False
	$g_aiDeployCCPosition[0] = -1
	$g_aiDeployCCPosition[1] = -1
	$g_bIsHeroesDropped = False
	$g_aiDeployHeroesPosition[0] = -1
	$g_aiDeployHeroesPosition[1] = -1
	
	If $g_bDebugSmartFarm Then AttackCSVDEBUGIMAGE()
	
	If StringInStr($SIDESNAMES, "BL") Then
		SetLog("Attack Side = " & $SIDESNAMES & ", prevent click boost button", $COLOR_INFO)
		For $i = 1 To 15
			If QuickMIS("BFI", $g_sImgImgLocButtons & "\BoostButton*.xml", 300,520,390,550) Then
				If _Sleep(2000) Then Return
				SetLog("Wait Battle Start #" & $i, $COLOR_ACTION)
			Else
				ExitLoop ; no boost button, launch attack
			EndIf
		Next
	EndIf
	
	LaunchTroopSmartFarm($listInfoDeploy, $g_iClanCastleSlot, $g_iKingSlot, $g_iQueenSlot, $g_iWardenSlot, $g_iChampionSlot, $g_iMinionPSlot, $g_iDukeSlot, $SIDESNAMES)
	
	If Not $g_bRunState Then Return
	If IsProblemAffect() Then Return
	CheckHeroesHealth()
	If _Sleep($DELAYALGORITHM_ALLTROOPS4) Then Return
	SetLog("Dropping left over troops", $COLOR_INFO)
	PrepareAttack($g_iMatchMode, True) ;re-check left army
	Local $aRandomCoord = GetRandomCoord($SIDESNAMES)
	For $i = 0 To UBound($g_avAttackTroops) - 1
		If $g_avAttackTroops[$i][0] >= $eBarb And $g_avAttackTroops[$i][0] <= $eIWiza And $g_avAttackTroops[$i][1] > 0 Then
			; launch remaining troops
			SelectDropTroop($i)
			SetLog("Dropping left : x" & $g_avAttackTroops[$i][1] & " " & GetTroopName($g_avAttackTroops[$i][0], $g_avAttackTroops[$i][1]) & " on [" & $aRandomCoord[0] & "," & $aRandomCoord[1] & "]", $COLOR_DEBUG1)
			Click($aRandomCoord[0], $aRandomCoord[1], $g_avAttackTroops[$i][1], 150) ;Drop troop
			If _Sleep(500) Then Return
		EndIf
	Next

	CheckHeroesHealth()
	SetLog("SmartFarm Attack Finished", $COLOR_DEBUG1)
EndFunc   ;==>AttackSmartFarm

Func LaunchTroopSmartFarm($listInfoDeploy, $iCC, $iKing, $iQueen, $iWarden, $iChampion, $iMinion, $iDuke, $SIDESNAMES = "TR|TL|BR|BL")
	; Initial Timer
	Local $hTimer = TimerInit()
	
	SetDebugLog("LaunchTroopSmartFarm with CC " & $iCC & ", K " & $iKing & ", Q " & $iQueen & ", W " & $iWarden & ", C " & $iChampion & ", M " & $iMinion & ", D " & $iDuke, $COLOR_DEBUG)
	; $ListInfoDeploy = [Troop, No. of Sides, $WaveNb, $MaxWaveNb, $slotsPerEdge]
	Local $listListInfoDeployTroopPixel[0]
	Local $pixelRandomDrop[2]
	Local $pixelRandomDropcc[2]
	Local $troop, $troopNb, $name
	
	If IsProblemAffect() Then Return
	For $i = 0 To UBound($listInfoDeploy) - 1
		; Reset the variables
		Local $troop = -1
		Local $troopNb = 0
		Local $name = ""
		; Fill the variables from List
		Local $troopKind = $listInfoDeploy[$i][0] ; Type
		Local $nbSides = $listInfoDeploy[$i][1] ; Number of Sides
		Local $waveNb = $listInfoDeploy[$i][2] ; waves
		Local $maxWaveNb = $listInfoDeploy[$i][3] ; Max waves
		Local $slotsPerEdge = $listInfoDeploy[$i][4] ; deploy Points per Edge
		Local $iSkip = _ArraySearch($g_avAttackTroops, $troopKind, 0, 0, 0, 0, 1, 0)
		If $iSkip = -1 And IsNumber($troopKind) Then ContinueLoop
		If $g_bDebugSmartFarm Then SetDebugLog("**ListInfoDeploy row " & $i & ": USE " & "[" & $troopKind & "] " & GetTroopName($troopKind, 0) & " SIDES " & $nbSides & " WAVE " & $waveNb & " XWAVE " & $maxWaveNb & " SLOTXEDGE " & $slotsPerEdge, $COLOR_DEBUG)
		
		; Regular Troops , not Heroes or Castle
		If (IsNumber($troopKind)) Then
			For $j = 0 To UBound($g_avAttackTroops) - 1 ; identify the position of this kind of troop
				If $g_avAttackTroops[$j][0] = $troopKind Then
					$troop = $j
					$troopNb = Ceiling($g_avAttackTroops[$j][1] / $maxWaveNb)
					$name = GetTroopName($troopKind, $troopNb)
				EndIf
			Next
		EndIf
		
		;here drop cc/heroes
		If ($troop <> -1 And $troopNb > 0) Or IsString($troopKind) Then 
			Local $listInfoDeployTroopPixel
			If (UBound($listListInfoDeployTroopPixel) < $waveNb) Then
				ReDim $listListInfoDeployTroopPixel[$waveNb]
				Local $newListInfoDeployTroopPixel[0]
				$listListInfoDeployTroopPixel[$waveNb - 1] = $newListInfoDeployTroopPixel
			EndIf
			$listInfoDeployTroopPixel = $listListInfoDeployTroopPixel[$waveNb - 1]

			ReDim $listInfoDeployTroopPixel[UBound($listInfoDeployTroopPixel) + 1]
			If (IsString($troopKind)) Then ; Heroes or Castle
				Local $arrCCorHeroes[1] = [$troopKind]
				$listInfoDeployTroopPixel[UBound($listInfoDeployTroopPixel) - 1] = $arrCCorHeroes
			Else
				; $infoDropTroop = [$troop, $listInfoPixelDropTroop, $nbTroopsPerEdge, $slotsPerEdge, $number, $name]
				Local $infoDropTroop = DropTroopSmartFarm($troop, $nbSides, $troopNb, $slotsPerEdge, $name, $SIDESNAMES)
				$listInfoDeployTroopPixel[UBound($listInfoDeployTroopPixel) - 1] = $infoDropTroop
			EndIf
			$listListInfoDeployTroopPixel[$waveNb - 1] = $listInfoDeployTroopPixel
		EndIf
	Next
	
	; End of assign infoDropTroop
	SetLog("infoDropTroop Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	Local $numberSidesDropTroop = 1
	Local $aRandomCoord = GetRandomCoord($SIDESNAMES)
	; Drop a full wave of all troops (e.g. giants, barbs and archers) on each side Then switch sides.
	For $numWave = 0 To UBound($listListInfoDeployTroopPixel) - 1
		If IsProblemAffect() Then Return
		Local $listInfoDeployTroopPixel = $listListInfoDeployTroopPixel[$numWave]
		If (UBound($listInfoDeployTroopPixel) > 0) Then
			Local $infoTroopListArrPixel = $listInfoDeployTroopPixel[0]

			For $i = 0 To UBound($listInfoDeployTroopPixel) - 1
				$infoTroopListArrPixel = $listInfoDeployTroopPixel[$i]
				If (UBound($infoTroopListArrPixel) > 1) Then
					Local $infoListArrPixel = $infoTroopListArrPixel[1]
					$numberSidesDropTroop = UBound($infoListArrPixel)
					ExitLoop
				EndIf
			Next

			If ($numberSidesDropTroop > 0) Then
				For $i = 0 To $numberSidesDropTroop - 1
					For $j = 0 To UBound($listInfoDeployTroopPixel) - 1
						$infoTroopListArrPixel = $listInfoDeployTroopPixel[$j]
						If (IsString($infoTroopListArrPixel[0]) And ($infoTroopListArrPixel[0] = "CC" Or $infoTroopListArrPixel[0] = "HEROES")) Then
							
							If ($g_bIsCCDropped = False And $infoTroopListArrPixel[0] = "CC" And $i = $numberSidesDropTroop - 1) Then
								dropCC($aRandomCoord[0], $aRandomCoord[1], $iCC)
								$g_bIsCCDropped = True
							ElseIf ($g_bIsHeroesDropped = False And $infoTroopListArrPixel[0] = "HEROES" And $i = $numberSidesDropTroop - 1) Then
								dropHeroes($aRandomCoord[0], $aRandomCoord[1], $iKing, $iQueen, $iWarden, $iChampion, $iMinion, $iDuke)
								$g_bIsHeroesDropped = True
							EndIf
						Else
							
							$infoListArrPixel = $infoTroopListArrPixel[1] ; $listInfoPixelDropTroop
							Local $listPixel = $infoListArrPixel[$i]
							;infoPixelDropTroop : First element in array contains troop and list of array to drop troop
							If _Sleep($DELAYLAUNCHTROOP21) Then Return
							SelectDropTroop($infoTroopListArrPixel[0]) ;Select Troop - $troop
							If _Sleep($DELAYLAUNCHTROOP23) Then Return
							SetLog("Dropping " & $infoTroopListArrPixel[2] & "  of " & $infoTroopListArrPixel[5] & " Points Per Side: " & $infoTroopListArrPixel[3] & " (side " & $i + 1 & ")", $COLOR_SUCCESS)
							Local $pixelDropTroop[1] = [$listPixel]
							DropOnPixel($infoTroopListArrPixel[0], $pixelDropTroop, $infoTroopListArrPixel[2], $infoTroopListArrPixel[3])
						EndIf
						If ($g_bIsHeroesDropped) Then
							If _sleep(1000) Then Return ; delay Queen Image  has to be at maximum size : CheckHeroesHealth checks the y = 573
							CheckHeroesHealth()
						EndIf
					Next
					If IsProblemAffect() Then Return
					If _Sleep(SetSleep(1)) Then Return
				Next
			EndIf
		EndIf
		If _Sleep(SetSleep(1)) Then Return
		If IsProblemAffect() Then Return
	Next
	
EndFunc   ;==>LaunchTroopSmartFarm

Func DropTroopSmartFarm($troop, $nbSides, $number, $slotsPerEdge = 0, $name = "", $SIDESNAMES = "TR|TL|BR|BL")

	Local $listInfoPixelDropTroop[0]

	If $slotsPerEdge = 0 Or $number < $slotsPerEdge Then $slotsPerEdge = Ceiling($number / $nbSides)

	If $nbSides < 1 Then Return
	Local $nbTroopsLeft = $number
	Local $nbTroopsPerEdge = Round($nbTroopsLeft / $nbSides)

	If ($number > 0 And $nbTroopsPerEdge = 0) Then $nbTroopsPerEdge = 1

	If $g_bDebugSmartFarm Then SetLog(" - " & GetSlotTroopName($troop) & " Number: " & $number & " Sides: " & $nbSides & " SlotsPerEdge: " & $slotsPerEdge)

	If $nbSides = 4 Then
		; $listInfoPixelDropTroop = [$newPixelBottomRight, $newPixelTopLeft, $newPixelBottomLeft, $newPixelTopRight]
		ReDim $listInfoPixelDropTroop[4]
		$listInfoPixelDropTroop = GetPixelDropTroop($troop, $number, $slotsPerEdge)
	Else
		;;;;;;;; HERE WILL BE THE SIDE CHOISE ;;;;;;;;;
		; $TEMPlistInfoPixelDropTroop = [$newPixelBottomRight, $newPixelTopLeft, $newPixelBottomLeft, $newPixelTopRight]
		Local $TEMPlistInfoPixelDropTroop = GetPixelDropTroop($troop, $nbTroopsPerEdge, $slotsPerEdge)

		If StringInStr($SIDESNAMES, "|") <> 0 Then

			Local $iTempSides = StringSplit($SIDESNAMES, "|", $STR_NOCOUNT)
			ReDim $listInfoPixelDropTroop[UBound($iTempSides)]
			For $i = 0 To UBound($iTempSides) - 1
				Switch $iTempSides[$i]
					Case "BR"
						$listInfoPixelDropTroop[$i] = $TEMPlistInfoPixelDropTroop[0]
					Case "TL"
						$listInfoPixelDropTroop[$i] = $TEMPlistInfoPixelDropTroop[1]
					Case "BL"
						$listInfoPixelDropTroop[$i] = $TEMPlistInfoPixelDropTroop[2]
					Case "TR"
						$listInfoPixelDropTroop[$i] = $TEMPlistInfoPixelDropTroop[3]
				EndSwitch
			Next
		Else
			ReDim $listInfoPixelDropTroop[1]
			Switch $SIDESNAMES
				Case "BR"
					$listInfoPixelDropTroop[0] = $TEMPlistInfoPixelDropTroop[0]
				Case "TL"
					$listInfoPixelDropTroop[0] = $TEMPlistInfoPixelDropTroop[1]
				Case "BL"
					$listInfoPixelDropTroop[0] = $TEMPlistInfoPixelDropTroop[2]
				Case "TR"
					$listInfoPixelDropTroop[0] = $TEMPlistInfoPixelDropTroop[3]
			EndSwitch
		EndIf

	EndIf

	Local $infoDropTroop[6] = [$troop, $listInfoPixelDropTroop, $nbTroopsPerEdge, $slotsPerEdge, $number, $name]
	Return $infoDropTroop

EndFunc   ;==>DropTroopSmartFarm

Func GetPixelDropTroop($troop, $number, $slotsPerEdge)
	Local $newPixelTopLeft
	Local $newPixelBottomLeft
	Local $newPixelTopRight
	Local $newPixelBottomRight

	;If ($troop = $eArch Or $troop = $eSArch Or $troop = $eWiza Or $troop = $eSWiza Or $troop = $eMini Or $troop = $eSMini Or $troop = $eBarb Or $troop = $eSBarb) Then
	;	If UBound($g_aiPixelTopLeftFurther) > 0 Then
	;		$newPixelTopLeft = $g_aiPixelTopLeftFurther
	;	Else
	;		$newPixelTopLeft = $g_aiPixelTopLeft
	;	EndIf
	;	If UBound($g_aiPixelBottomLeftFurther) > 0 Then
	;		$newPixelBottomLeft = $g_aiPixelBottomLeftFurther
	;	Else
	;		$newPixelBottomLeft = $g_aiPixelBottomLeft
	;	EndIf
	;	If UBound($g_aiPixelTopRightFurther) > 0 Then
	;		$newPixelTopRight = $g_aiPixelTopRightFurther
	;	Else
	;		$newPixelTopRight = $g_aiPixelTopRight
	;	EndIf
	;	If UBound($g_aiPixelBottomRightFurther) Then
	;		$newPixelBottomRight = $g_aiPixelBottomRightFurther
	;	Else
	;		$newPixelBottomRight = $g_aiPixelBottomRight
	;	EndIf
	;Else
		$newPixelTopLeft = $g_aiPixelTopLeft
		$newPixelBottomLeft = $g_aiPixelBottomLeft
		$newPixelTopRight = $g_aiPixelTopRight
		$newPixelBottomRight = $g_aiPixelBottomRight
	;EndIf

	$newPixelTopLeft = GetVectorPixelOnEachSide2($newPixelTopLeft, 0, $slotsPerEdge)
	$newPixelBottomLeft = GetVectorPixelOnEachSide2($newPixelBottomLeft, 1, $slotsPerEdge)
	$newPixelTopRight = GetVectorPixelOnEachSide2($newPixelTopRight, 1, $slotsPerEdge)
	$newPixelBottomRight = GetVectorPixelOnEachSide2($newPixelBottomRight, 0, $slotsPerEdge)

	Local $g_aaiEdgeDropPointsPixelToDrop[4] = [$newPixelBottomRight, $newPixelTopLeft, $newPixelBottomLeft, $newPixelTopRight]
	Return $g_aaiEdgeDropPointsPixelToDrop
EndFunc   ;==>GetPixelDropTroop

Func GetRandomCoord($SIDESNAMES)
	Local $aTempSides, $sLastSide, $iRandomXY, $aLastDropPoint
	Local $aDefault[2] = [430, 40], $aRet
	$sLastSide = StringRight($SIDESNAMES, 2)
	
	Local $iSide = $eVectorLeftTop
	Switch $sLastSide
		Case "TL"
			$iSide = $eVectorLeftTop
		Case "TR" 
			$iSide = $eVectorRightTop
		Case "BL"
			$iSide = $eVectorLeftBottom
		Case "BR"
			$iSide = $eVectorRightBottom
	EndSwitch
	
	$aRet = $aDefault
	$aLastDropPoint = _GetVectorOutZone($iSide)
	If IsArray($aLastDropPoint) And UBound($aLastDropPoint) > 0 Then
		;_ArraySort($aLastDropPoint, 0, 0, 0, 0)
		Local $iMiddle = Floor(UBound($aLastDropPoint)/2)
		$aRet = $aLastDropPoint[$iMiddle]
		SetDebugLog("sLastSide = " & $sLastSide & ", count DropPoint = " & UBound($aLastDropPoint) & " iRandomXY = " & _ArrayToString($aRet))
	EndIf
	
	Return $aRet
EndFunc

Func GetPixelSide($listPixel, $index)
	If UBound($listPixel) > $index Then
		SetDebugLog("GetPixelSide " & $index & " = " & StringReplace($listPixel[$index], "-", ","))
		Return GetListPixel($listPixel[$index])
	EndIf
	Return -1
EndFunc   ;==>GetPixelSide

Func _FindPixelCloser($arrPixel, $pixel, $nb = 1)

	If IsArray($arrPixel) = False Then Return ; Prevent error

	Local $arrPixelCloser[0]
	For $j = 0 To $nb
		Local $PixelCloser = $arrPixel[0]
		For $i = 0 To UBound($arrPixel) - 1
			Local $alreadyExist = False
			Local $arrTemp = $arrPixel[$i]
			Local $found = False
			;search closer only on y
			If ($pixel[0] = -1) Then
				If (Abs($arrTemp[1] - $pixel[1]) < Abs($PixelCloser[1] - $pixel[1])) Then
					$found = True
				EndIf
				;search closer only on x
			ElseIf ($pixel[1] = -1) Then
				If (Abs($arrTemp[0] - $pixel[0]) < Abs($PixelCloser[0] - $pixel[0])) Then
					$found = True
				EndIf
				;search closer on x/y
			Else
				If ((Abs($arrTemp[0] - $pixel[0]) + Abs($arrTemp[1] - $pixel[1])) < (Abs($PixelCloser[0] - $pixel[0]) + Abs($PixelCloser[1] - $pixel[1]))) Then
					$found = True
				EndIf
			EndIf
			If ($found) Then
				For $k = 0 To UBound($arrPixelCloser) - 1
					Local $arrTemp2 = $arrPixelCloser[$k]
					If ($arrTemp[0] = $arrTemp2[0] And $arrTemp[1] = $arrTemp2[1]) Then
						$alreadyExist = True
						ExitLoop
					EndIf
				Next
				If ($alreadyExist = False) Then
					$PixelCloser = $arrTemp
				EndIf
			EndIf
		Next
		ReDim $arrPixelCloser[UBound($arrPixelCloser) + 1]
		$arrPixelCloser[UBound($arrPixelCloser) - 1] = $PixelCloser

	Next
	Return $arrPixelCloser
EndFunc   ;==>_FindPixelCloser

Func _GetVectorOutZone($eVectorType)
	debugRedArea("_GetVectorOutZone IN")
	Local $vectorOutZone[0]
	Local $iSteps = 100
	Local $xMin, $yMin, $xMax, $yMax

	If ($eVectorType = $eVectorLeftTop) Then
		$xMin = $ExternalArea[0][0] + 2
		$yMin = $ExternalArea[0][1]
		$xMax = $ExternalArea[2][0]
		$yMax = $ExternalArea[2][1] + 2
	ElseIf ($eVectorType = $eVectorRightTop) Then
		$xMin = $ExternalArea[2][0]
		$yMin = $ExternalArea[2][1] + 2
		$xMax = $ExternalArea[1][0] - 2
		$yMax = $ExternalArea[1][1]
	ElseIf ($eVectorType = $eVectorLeftBottom) Then
		$xMin = $ExternalArea[0][0] + 2
		$yMin = $ExternalArea[0][1]
		$xMax = $ExternalArea[3][0]
		$yMax = $ExternalArea[3][1] - 2
	Else ; bottom right
		$xMin = $ExternalArea[3][0]
		$yMin = $ExternalArea[3][1] - 2
		$xMax = $ExternalArea[1][0] - 2
		$yMax = $ExternalArea[1][1]
	EndIf

	For $i = 0 To $iSteps
		Local $pixel = [Round($xMin + (($xMax - $xMin) * $i) / $iSteps), Round($yMin + (($yMax - $yMin) * $i) / $iSteps)]
		;If $pixel[1] > 565 Then
		;	;If $g_bDebugSetLog Then SetDebugLog("Skip vector out of zone [" & $pixel[0] & "," & $pixel[1] & "]")
		;	ContinueLoop
		;	;$pixel[1] = 555
		;EndIf
		ReDim $vectorOutZone[UBound($vectorOutZone) + 1]
		$vectorOutZone[UBound($vectorOutZone) - 1] = $pixel
	Next

	Return $vectorOutZone
EndFunc   ;==>_GetVectorOutZone

; #FUNCTION# ====================================================================================================================
; Name ..........: GetVectorPixelOnEachSide
; Description ...:
; Syntax ........: GetVectorPixelOnEachSide($arrPixel, $vectorDirection)
; Parameters ....: $arrPixel            - an array of unknowns.
;                  $vectorDirection     - a variant value.
; Return values .: None
; Author ........:
; Modified ......: ProMac (07-2018)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func GetVectorPixelOnEachSide2($arrPixel, $vectorDirection, $slotsPerEdge)
	; $vectorDirection = 0 than is Xaxis , $vectorDirection = 1 than is Yaxis	
	Local $minAdd = Random(0, Ceiling(($slotsPerEdge / 100) * 20), 1)
	$slotsPerEdge += $minAdd
	
	Local $vectorPixelEachSide[$slotsPerEdge]
	If (UBound($arrPixel) > 1) Then
		Local $pixelSearch[2] = [-1, -1]
		Local $minPixel = $arrPixel[0]
		Local $maxPixel = $arrPixel[UBound($arrPixel) - 1]
		Local $min = $minPixel[$vectorDirection]
		Local $max = $maxPixel[$vectorDirection]
		;If $g_bDebugSmartFarm Then SetDebuglog("Min pixel coord: " & $min & ", Max Pixel coord: " & $max)
		Local $posSide = Floor(($max - $min) / $slotsPerEdge)

		For $i = 0 To $slotsPerEdge - 1
			$pixelSearch[$vectorDirection] = $min + Floor(($posSide * ($i + 1)) - ($posSide / 2))
			;Local $coordinate = ($vectorDirection = 0) ? "X" : "Y"
			;If $g_bDebugSmartFarm Then SetDebuglog("Deploy point number[" & $i + 1 & "] at " &  $coordinate & ": " & $min + Floor(($posSide * ($i + 1)) - ($posSide / 2)))
			Local $arrPixelCloser = _FindPixelCloser($arrPixel, $pixelSearch, 1)
			;If $g_bDebugSmartFarm Then SetDebuglog("Deploy point Closer[" & $i + 1 & "] at: " & _ArrayToString($arrPixelCloser[0]))
			$vectorPixelEachSide[$i] = $arrPixelCloser[0]
		Next
	EndIf
	
	If IsArray($vectorPixelEachSide) Then
		_ArrayShuffle($vectorPixelEachSide)
	EndIf
	Return $vectorPixelEachSide
EndFunc   ;==>GetVectorPixelOnEachSide2


Func TestSF()
	CheckZoomOut()
	PrepareAttack($DB)
	Local $Nside = ChkSmartFarm()
	AttackSmartFarm($Nside[1], $Nside[2])
	ReturnHome()
EndFunc

Func SFLoop($iCountLoop = 1, $bStopWhenResourceFull = False)
	If isGoldFull() And isElixirFull() And $bStopWhenResourceFull Then Return
	For $i = 1 To $iCountLoop
		ZoomOut(True)
		PrepareSearch()
		If Not $g_bRunState Then Return
		VillageSearch()
		If Not IsAttackPage() Then ContinueLoop
		If Not $g_bRunState Then Return
		CheckZoomOut()
		PrepareAttack($DB)
		If IsProblemAffect() Then ContinueLoop
		If Not $g_bRunState Then Return
		Local $Nside = ChkSmartFarm()
		AttackSmartFarm($Nside[1], $Nside[2])
		If Not $g_bRunState Then Return
		ReturnHome()
		If Not $g_bRunState Then Return
		VillageReport()
		If Not $g_bRunState Then Return
		RequestCC()
		SetLog("SF Loop [" & $i & "/" & $iCountLoop & "]", $COLOR_ACTION) 
		If isGoldFull() And isElixirFull() And $bStopWhenResourceFull Then Return
	Next
EndFunc
