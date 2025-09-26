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

	Setlog("Starting the SmartFarm Attack Test()", $COLOR_INFO)

	CheckMainScreen(False, $g_bStayOnBuilderBase, "TestSmartFarm")
	CheckIfArmyIsReady()
	ClickAway()
	If _Sleep(100) Then Return FuncReturn()
	If (IsSearchModeActive($DB) And checkCollectors(True, False)) Or IsSearchModeActive($LB) Then
		If _Sleep(100) Then Return FuncReturn()
		PrepareSearch()
		If _Sleep(1000) Then Return FuncReturn()
		VillageSearch()
		If $g_bOutOfGold Then Return ; Check flag for enough gold to search
		If _Sleep(100) Then Return FuncReturn()
	Else
		SetLog("Your Army is not prepared, check the Attack/train options")
	EndIf

	PrepareAttack($g_iMatchMode)

	$g_bAttackActive = True
	; Variable to return : $Return[3]  [0] = To attack InSide  [1] = Quant. Sides  [2] = Name Sides
	Local $Nside = ChkSmartFarm()
	
	AttackSmartFarm($Nside[1], $Nside[2])
	$g_bAttackActive = False

	ReturnHome($g_bTakeLootSnapShot)

	Setlog("Finish the SmartFarm Attack()", $COLOR_INFO)

	$g_bRunState = $RuntimeA

EndFunc   ;==>TestSmartFarm

; Collectors | Mines | Drills | All (Default)
Func ChkSmartFarm($TypeResources = "All")

	; Initial Timer
	Local $hTimer = TimerInit()

	; [0] = x , [1] = y , [2] = Side , [3] = In/out , [4] = Side,  [5]= Is string with 5 coordinates to deploy
	Local $aResourcesOUT[0][6]
	Local $aResourcesIN[0][6]

	; TL , TR , BL , BR
	Local $aMainSide[4] = [0, 0, 0, 0]

	SetDebugLog(" - INI|SmartFarm detection.", $COLOR_INFO)
	; Local $aCollectores = SmartFarmDetection("Collectors")
	; Local $aMines = SmartFarmDetection("Mines")
	; Local $aDrills = SmartFarmDetection("Drills")

	$hTimer = TimerInit()

	If $g_iSearchTH = "-" Then FindTownHall(True, True)
	; [0] = Level , [1] = Xaxis , [2] = Yaxis , [3] = Distances to redlines
	Local $THdetails[4] = [$g_iSearchTH, $g_iTHx, $g_iTHy, _ObjGetValue($g_oBldgAttackInfo, $eBldgTownHall & "_REDLINEDISTANCE")]
	setlog("TH Details: " & _ArrayToString($THdetails, "|"))

	; [0] = x , [1] = y , [2] = Distance to Redline ,[3] = In/Out, [4] = Side,  [5]= Is array Dim[2] with 5 coordinates to deploy
	Local $aAll = SmartFarmDetection($TypeResources)
	SetDebugLog(" TOTAL detection Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)

	; Let's determinate what resource is out or in side the village
	; Collectors

	For $x = 0 To UBound($aAll) - 1
		; Only proceeds when the x exist , not -1
		If $aAll[$x][0] <> -1 Then
			If $aAll[$x][3] = "In" Then
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
			
			Switch $aAll[$x][4]
				Case "TL"
					$aMainSide[0] += 1
				Case "TR"
					$aMainSide[1] += 1
				Case "BL"
					$aMainSide[2] += 1
				Case "BR"
					$aMainSide[3] += 1
			EndSwitch
			
		EndIf
		If _Sleep(50) Then Return ; just in case on PAUSE
		If Not $g_bRunState Then Return ; Stop Button
	Next
	
	If $g_bDebugSmartFarm Then
		For $i = 0 To UBound($aResourcesIN) - 1
			For $x = 0 To 4
				SetDebugLog("$aResourcesIN[" & $i & "][" & $x & "]: " & $aResourcesIN[$i][$x], $COLOR_INFO)
			Next
		Next
		For $i = 0 To UBound($aResourcesOUT) - 1
			For $x = 0 To 4
				SetDebugLog("$aResourcesOUT[" & $i & "][" & $x & "]: " & $aResourcesOUT[$i][$x], $COLOR_INFO)
			Next
		Next
	EndIf

	; Total of Resources and %
	Local $TotalOfResources = UBound($aResourcesIN) + UBound($aResourcesOUT)
	Setlog("Total of Resources: " & $TotalOfResources, $COLOR_INFO)
	Setlog(" - Inside the Village: " & UBound($aResourcesIN), $COLOR_INFO)
	Setlog(" - Outside the village: " & UBound($aResourcesOUT), $COLOR_INFO)
	SetDebugLog("MainSide array: " & _ArrayToString($aMainSide))

	$g_sResourcesIN = UBound($aResourcesIN)
	$g_sResourcesOUT = UBound($aResourcesOUT)
	$g_sResBySide = _ArrayToString($aMainSide)

	; Inside , Outside
	Local $AttackInside = False

	Local $Percentage_In = Int((UBound($aResourcesIN) / $TotalOfResources) * 100), $Percentage_Out = Int((UBound($aResourcesOUT) / $TotalOfResources) * 100)

	; FROM GUI
	Local $PercentageInSide = Int($g_iTxtInsidePercentage) ; Percentage to force ONE SIDE ATTACK
	Local $PercentageOutSide = Int($g_iTxtOutsidePercentage) ; Percentage to force to attack all sides with at least with one Resource

	If $Percentage_In > $PercentageInSide Then $AttackInside = True

	Local $TxtLog = ($AttackInside = True) ? ("Inside with " & $Percentage_In & "%") : ("Outside with " & $Percentage_Out & "%")
	Setlog(" - Best Attack will be " & $TxtLog)
	If Not $g_bRunState Then Return

	Local $OneSide = Floor($TotalOfResources / 4)
	Local $Sides[4] = ["TL", "TR", "BL", "BR"]
	Local $SidesExt[4] = ["Top-Left", "Top-Right", "Bottom-Left", "Bottom-Right"]
	Local $aHowManySides[0]
	
	SetLog("aMainSideTL: " & $aMainSide[0], $COLOR_SUCCESS)
	SetLog("aMainSideTR: " & $aMainSide[1], $COLOR_SUCCESS)
	SetLog("aMainSideBL: " & $aMainSide[2], $COLOR_SUCCESS)
	SetLog("aMainSideBR: " & $aMainSide[3], $COLOR_SUCCESS)
	Local $iTL = $aMainSide[0], $iTR = $aMainSide[1], $iBL = $aMainSide[2], $iBR = $aMainSide[3]
	Local $sSideiSide[4][2] = [ _
			["TL", $aMainSide[0]], _
			["TR", $aMainSide[1]], _
			["BL", $aMainSide[2]], _
			["BR", $aMainSide[3]]]
	_ArraySort($sSideiSide, 1, 0, 0, 1)
		
	For $i = 0 To $g_iCmbMaxAttackSide - 1
		If $sSideiSide[$i][1] >= $OneSide Or ($Percentage_Out > $PercentageOutSide And $sSideiSide[$i][1] <> 0) Then
			ReDim $aHowManySides[UBound($aHowManySides) + 1]
			$aHowManySides[UBound($aHowManySides) - 1] = $sSideiSide[$i][0]
		EndIf
	Next
	
	; Determinate the higher value if $AttackInside is True
	Local $BestSideToAttack[1] = ["TR"]
	Local $number = 0

	If $AttackInside Then
		For $i = 0 To UBound($aMainSide) - 1
			If $aMainSide[$i] > $number Then
				$number = $aMainSide[$i]
				$BestSideToAttack[0] = $Sides[$i]
			EndIf
		Next
		For $i = 0 To UBound($aMainSide) - 1
			If $BestSideToAttack[0] = $Sides[$i] Then Setlog("Best Side To Attack Inside: " & $SidesExt[$i])
			Setlog(" - Side " & $SidesExt[$i] & " with " & $aMainSide[$i] & " Resources.", $COLOR_INFO)
		Next
	Else
		$BestSideToAttack = $aHowManySides
	EndIf

	Setlog("Attack at " & UBound($BestSideToAttack) & " Side(s) - " & _ArrayToString($BestSideToAttack), $COLOR_INFO)
	Setlog(" Check Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	If Not $g_bRunState Then Return

	; DEBUG , image with all information
	Local $redline[UBound($BestSideToAttack)]
	If $g_bDebugSmartFarm Then
		For $i = 0 To UBound($BestSideToAttack) - 1
			$redline[$i] = GetOffsetRedline($BestSideToAttack[$i], 5)
		Next
		DebugImageSmartFarm($THdetails, $aResourcesIN, $aResourcesOUT, Round(TimerDiff($hTimer) / 1000, 2) & "'s", _ArrayToString($BestSideToAttack), $redline)
		;TestDropLine()
	EndIf

	; Variable to return : $Return[3]  [0] = To attack InSide  [1] = Quant. Sides  [2] = Name Sides
	Local $Return[3] = [$AttackInside, UBound($BestSideToAttack), _ArrayToString($BestSideToAttack)]
	Return $Return

EndFunc   ;==>ChkSmartFarm

Func SmartFarmDetection($txtBuildings = "All")

	; This Function will fill an Array with several informations after Mines, Collectores or Drills detection with Imgloc
	; [0] = x , [1] = y , [2] = Distance to Redline ,[3] = In/Out, [4] = Side,  [5]= Is array Dim[2] with 5 coordinates to deploy
	Local $aReturn[0][6]
	Local $sdirectory, $iMaxReturnPoints, $iMaxLevel, $offsetx, $offsety
	If Not $g_bRunState Then Return


	; Initial Timer
	Local $hTimer = TimerInit()

	; Prepared for Winter Theme
	Switch $txtBuildings
		Case "Mines"
			If $g_iDetectedImageType = 1 Then
				$sdirectory = @ScriptDir & "\imgxml\Storages\Mines_Snow"
			Else
				$sdirectory = @ScriptDir & "\imgxml\Storages\GoldMines"
			EndIf
			$iMaxReturnPoints = 7
			$iMaxLevel = 14
		Case "Collectors"
			If $g_iDetectedImageType = 1 Then
				$sdirectory = @ScriptDir & "\imgxml\Storages\Collectors_Snow"
			Else
				$sdirectory = @ScriptDir & "\imgxml\Storages\Collectors"
			EndIf
			$iMaxReturnPoints = 7
			$iMaxLevel = 14
		Case "Drills"
			$sdirectory = @ScriptDir & "\imgxml\Storages\Drills"
			$iMaxReturnPoints = 3
			$iMaxLevel = 8
		Case "All"
			If $g_iDetectedImageType = 1 Then
				;$sdirectory = @ScriptDir & "\imgxml\Storages\All_Snow"
				$sdirectory = @ScriptDir & "\imgxml\Storages\All"
			Else
				$sdirectory = @ScriptDir & "\imgxml\Storages\All"
			EndIf
			$iMaxReturnPoints = 21
			$iMaxLevel = 15
	EndSwitch

	; Necessary Variables
	Local $sCocDiamond = "ECD"
	Local $sRedLines = ""
	Local $iMinLevel = 1
	Local $sReturnProps = "objectname,objectpoints,nearpoints,redlinedistance"
	Local $bForceCapture = True

	; DETECTION IMGLOC
	Local $aResult = findMultiple($sdirectory, $sCocDiamond, $sRedLines, $iMinLevel, $iMaxLevel, $iMaxReturnPoints, $sReturnProps, $bForceCapture)
	Local $aTEMP, $sObjectname, $aObjectpoints, $sNear, $sRedLineDistance
	Local $tempObbj, $sNearTemp, $Distance, $tempObbjs, $sString
	Local $distance2RedLine = 40

	; Get properties from detection
	If IsArray($aResult) And UBound($aResult) > 0 Then
		For $buildings = 0 To UBound($aResult) - 1
			If _Sleep(50) Then Return ; just in case on PAUSE
			If Not $g_bRunState Then Return ; Stop Button
			SetDebugLog(_ArrayToString($aResult[$buildings]))
			$aTEMP = $aResult[$buildings]
			$sObjectname = String($aTEMP[0])
			SetDebugLog("Building name: " & String($aTEMP[0]), $COLOR_INFO)
			$aObjectpoints = $aTEMP[1] ; number of  objects returned
			SetDebugLog("Object points: " & String($aTEMP[1]), $COLOR_INFO)
			$sNear = $aTEMP[2] ;
			SetDebugLog("Near points: " & String($aTEMP[2]), $COLOR_INFO)
			$sRedLineDistance = $aTEMP[3] ;
			SetDebugLog("Distance points: " & String($aTEMP[3]), $COLOR_INFO)

			Switch String($aTEMP[0])
				Case "Mines"
					$offsetx = 3
					$offsety = 12
				Case "Collector"
					$offsetx = -9
					$offsety = 9
				Case "Drill"
					$offsetx = 2
					$offsety = 14
			EndSwitch

			If StringInStr($aObjectpoints, "|") Then
				$aObjectpoints = StringReplace($aObjectpoints, "||", "|")
				$sString = StringRight($aObjectpoints, 1)
				If $sString = "|" Then $aObjectpoints = StringTrimRight($aObjectpoints, 1)
				$tempObbj = StringSplit($aObjectpoints, "|", $STR_NOCOUNT) ; several detected points
				$sNearTemp = StringSplit($sNear, "#", $STR_NOCOUNT) ; several detected 5 near points
				$Distance = StringSplit($sRedLineDistance, "#", $STR_NOCOUNT) ; several detected distances points
				For $i = 0 To UBound($tempObbj) - 1
					; Test the coordinates
					$tempObbjs = StringSplit($tempObbj[$i], ",", $STR_NOCOUNT) ;  will be a string : 708,360
					If UBound($tempObbjs) <> 2 Then ContinueLoop
					; Check double detections
					Local $DetectedPoint[2] = [Number($tempObbjs[0] + $offsetx), Number($tempObbjs[1] + $offsety)]
					If DoublePoint($aTEMP[0], $aReturn, $DetectedPoint) Then ContinueLoop
					; Include one more dimension
					ReDim $aReturn[UBound($aReturn) + 1][6]
					$aReturn[UBound($aReturn) - 1][0] = $DetectedPoint[0] ; X
					$aReturn[UBound($aReturn) - 1][1] = $DetectedPoint[1] ; Y
					$aReturn[UBound($aReturn) - 1][4] = Side($tempObbjs)
					$distance2RedLine = $aReturn[UBound($aReturn) - 1][4] = "BL" ? 50 : 45
					If UBound($sNearTemp) - 1 >= $i Then 
						$aReturn[UBound($aReturn) - 1][5] = $sNearTemp[$i] ; will be a string inside : 708,360|705,358|720,370|705,353|722,371
					Else
						$aReturn[UBound($aReturn) - 1][5] = "0,0"
					EndIf
					If UBound($Distance) - 1 >= $i Then 
						$aReturn[UBound($aReturn) - 1][2] = Number($Distance[$i]) > 0 ? Number($Distance[$i]) : 200
					Else
						$aReturn[UBound($aReturn) - 1][2] = 200
					EndIf
					$aReturn[UBound($aReturn) - 1][3] = ($aReturn[UBound($aReturn) - 1][2] > $distance2RedLine) ? ("In") : ("Out") ; > 40 pixels the resource is far away from redline
				Next
			Else
				; Test the coordinate
				$tempObbj = StringSplit($aObjectpoints, ",", $STR_NOCOUNT) ;  will be a string : 708,360
				If UBound($tempObbj) <> 2 Then ContinueLoop
				; Check double detections
				Local $DetectedPoint[2] = [Number($tempObbj[0] + $offsetx), Number($tempObbj[1] + $offsety)]
				If DoublePoint($aTEMP[0], $aReturn, $DetectedPoint) Then ContinueLoop
				; Include one more dimension
				ReDim $aReturn[UBound($aReturn) + 1][6]
				$aReturn[UBound($aReturn) - 1][0] = $DetectedPoint[0] ; X
				$aReturn[UBound($aReturn) - 1][1] = $DetectedPoint[1] ; Y
				$aReturn[UBound($aReturn) - 1][4] = Side($tempObbj)
				$distance2RedLine = $aReturn[UBound($aReturn) - 1][4] = "BL" ? 50 : 45
				$aReturn[UBound($aReturn) - 1][5] = $sNear ; will be a string inside : 708,360|705,358|720,370|705,353|722,371
				$aReturn[UBound($aReturn) - 1][2] = Number($sRedLineDistance)
				$aReturn[UBound($aReturn) - 1][3] = ($aReturn[UBound($aReturn) - 1][2] > $distance2RedLine) ? ("In") : ("Out") ; > 40 pixels the resource is far away from redline
			EndIf
			; Reset
			$aTEMP = Null
			$sObjectname = Null
			$aObjectpoints = Null
			$sNear = Null
			$sRedLineDistance = Null
			$tempObbj = Null
			$sNearTemp = Null
			$Distance = Null
			$tempObbjs = Null
		Next
		; End of building loop
		SetLog("SmartFarmDetection " & $txtBuildings & " Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
		Return $aReturn
	Else
		SetLog("ERROR|NONE Building - Detection: " & $txtBuildings, $COLOR_INFO)
	EndIf

EndFunc   ;==>SmartFarmDetection

Func DoublePoint($sName, $aReturn, $aPoint, $iDistance = 18)
	Local $x, $y
	Local $x1 = Number($aPoint[0])
	Local $y1 = Number($aPoint[1])

	For $i = 0 To UBound($aReturn) - 1
		If Not $g_bRunState Then Return
		$x = Number($aReturn[$i][0])
		$y = Number($aReturn[$i][1])
		If Pixel_Distance($x, $y, $x1, $y1) < $iDistance Then
			SetDebugLog("Detected a " & $sName & " double detection at (" & $x & "," & $y & ")")
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>DoublePoint

Func Pixel_Distance($x, $y, $x1, $y1)
	;Pythagoras theorem for 2D
	Local $a, $b, $c
	If $x1 = $x And $y1 = $y Then
		Return 0
	Else
		$a = $y1 - $y
		$b = $x1 - $x
		$c = Sqrt($a * $a + $b * $b)
		Return $c
	EndIf
EndFunc   ;==>Pixel_Distance

Func Side($Pixel)
	Local $sReturn = ""
	; Using to determinate the Side position on Screen |Bottom Right|Bottom Left|Top Left|Top Right|
	If IsArray($Pixel) And UBound($Pixel) = 2 Then
		If $Pixel[0] < 430 And $Pixel[1] <= 330 Then $sReturn = "TL"
		If $Pixel[0] >= 430 And $Pixel[1] < 330 Then $sReturn = "TR"
		If $Pixel[0] < 430 And $Pixel[1] > 330 Then $sReturn = "BL"
		If $Pixel[0] >= 430 And $Pixel[1] >= 330 Then $sReturn = "BR"
		If $sReturn = "" Then
			Setlog("Error on SIDE...: " & _ArrayToString($Pixel), $COLOR_RED)
			$sReturn = "ERROR"
		EndIf
		Return $sReturn
	Else
		Setlog("ERROR SIDE|SmartFarm!!", $COLOR_RED)
	EndIf
EndFunc   ;==>Side

Func DebugImageSmartFarm($THdetails, $aIn, $aOut, $sTime, $BestSideToAttack, $redline)

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
	Local $hPenRed = _GDIPlus_PenCreate(0xFFFFD800, 2) ; Create a pencil Color FF0000/RED
	Local $hPenBlack = _GDIPlus_PenCreate(0xFF000000, 2) ; Create a pencil Color FFFFFF/BLACK


	; TH
	addInfoToDebugImage($hGraphic, $hPenRed, "TH_" & $THdetails[0] & "|" & $THdetails[3], $THdetails[1], $THdetails[2])
	_GDIPlus_GraphicsDrawRect($hGraphic, $THdetails[1] - 5, $THdetails[2] - 5, 10, 10, $hPenBlack)

	Local $tempObbj, $tempObbjs
	For $i = 0 To UBound($aIn) - 1
		; Objects Detected Inside the village
		addInfoToDebugImage($hGraphic, $hPenRed, $aIn[$i][3] & "|" & $aIn[$i][4] & "|" & $aIn[$i][2], $aIn[$i][0], $aIn[$i][1])

		; Deploy points near Red Line
		If StringInStr($aIn[$i][5], "|") Then

			$tempObbj = StringSplit($aIn[$i][5], "|", $STR_NOCOUNT) ; several detected points
			For $t = 0 To UBound($tempObbj) - 1
				$tempObbjs = StringSplit($tempObbj[$t], ",", $STR_NOCOUNT)
				If UBound($tempObbjs) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $tempObbjs[0], $tempObbjs[1], 5, 5, $hPenBlack)
			Next
		Else
			If $aOut[$i][5] <> "" Then 
				$tempObbj = StringSplit($aOut[$i][5], ",", $STR_NOCOUNT)
				If UBound($tempObbj) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $tempObbj[0], $tempObbj[1], 5, 5, $hPenBlack)
			EndIf
		EndIf
		$tempObbj = Null
		$tempObbjs = Null
	Next

	For $i = 0 To UBound($aOut) - 1
		; Objects Detected Outside the village
		addInfoToDebugImage($hGraphic, $hPenRed, $aOut[$i][3] & "|" & $aOut[$i][4] & "|" & $aOut[$i][2], $aOut[$i][0], $aOut[$i][1])

		; Deploy points near Red Line
		If StringInStr($aOut[$i][5], "|") Then
			$tempObbj = StringSplit($aOut[$i][5], "|", $STR_NOCOUNT) ; several detected points
			For $t = 0 To UBound($tempObbj) - 1
				$tempObbjs = StringSplit($tempObbj[$t], ",", $STR_NOCOUNT)
				If UBound($tempObbjs) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $tempObbjs[0], $tempObbjs[1], 5, 5, $hPenBlack)
			Next
		Else
			$tempObbj = StringSplit($aOut[$i][5], ",", $STR_NOCOUNT)
			If UBound($tempObbj) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $tempObbj[0], $tempObbj[1], 5, 5, $hPenBlack)
		EndIf
		$tempObbj = Null
		$tempObbjs = Null
	Next

	; ############################# Best Side to attack INSIDE ###################################
	Local $hPenCyan = _GDIPlus_PenCreate(0xFF00FFFF, 2) ; Create a pencil Color BLUE
	Local $aTEMP, $DecodeEachPoint
	SetDebugLog("$redline: " & _ArrayToString($redline))
	For $l = 0 To UBound($redline) - 1
		$aTEMP = StringSplit($redline[$l], "|", 2)
		For $i = 0 To UBound($aTEMP) - 1
			$DecodeEachPoint = StringSplit($aTEMP[$i], ",", 2)
			If UBound($DecodeEachPoint) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $DecodeEachPoint[0], $DecodeEachPoint[1], 5, 5, $hPenCyan)
		Next
	Next

	;############################################################################################
	_GDIPlus_GraphicsDrawString($hGraphic, $sTime & " - " & $BestSideToAttack, 370, 70, "ARIAL", 20)

	; Save the image and release any memory
	_GDIPlus_ImageSaveToFile($editedImage, $subDirectory & $fileName)
	_GDIPlus_PenDispose($hPenRed)
	_GDIPlus_PenDispose($hPenBlack)
	_GDIPlus_PenDispose($hPenCyan)
	_GDIPlus_GraphicsDispose($hGraphic)
	Setlog("Debug Image saved!")

EndFunc   ;==>DebugImageSmartFarm

Func AttackSmartFarm($Nside, $SIDESNAMES)

	Setlog(" ====== Start Smart Farm Attack ====== ", $COLOR_INFO)

	SetSlotSpecialTroops()

	Local $nbSides = Null
	Local $GiantComp = 0

	_CaptureRegion2() ; ensure full screen is captured (not ideal for debugging as clean image was already saved, but...)
	If $g_bChkForceEdgeSmartfarm Then 
		$g_aiPixelTopLeft = _GetVectorOutZone($eVectorLeftTop)
		$g_aiPixelBottomLeft = _GetVectorOutZone($eVectorLeftBottom)
		$g_aiPixelBottomRight = _GetVectorOutZone($eVectorRightBottom)
		$g_aiPixelTopRight = _GetVectorOutZone($eVectorRightTop)
	Else
		_GetRedArea()
	EndIf

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
				, [$eHogs, $nbSides, 1, 1, 1] _
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
			If $g_bDebugSmartFarm Then SetLog("iValue : " & $iValue & " [" & GetTroopName($iValue) & "]")
			If $iValue <> -1 And $iValue < $eKing Then
				Local $iDelete = _ArraySearch($aTmpListInfoDeploy, $iValue, 0, 0, 0, 0, 1, 0)
				If $iDelete <> -1 Then
					If $g_bDebugSmartFarm Then SetLog("iDelete : " & $iDelete)
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

	LaunchTroopSmartFarm($listInfoDeploy, $g_iClanCastleSlot, $g_iKingSlot, $g_iQueenSlot, $g_iWardenSlot, $g_iChampionSlot, $g_iMinionPSlot, $SIDESNAMES)
	
	If Not $g_bRunState Then Return
	If IsProblemAffect() Then Return
	CheckHeroesHealth()
	If IsProblemAffect() Then Return
	If _Sleep($DELAYALGORITHM_ALLTROOPS4) Then Return
	SetLog("Dropping left over troops", $COLOR_INFO)
	
	Local $aTempSides, $sLastSide
	If StringInStr($SIDESNAMES, "|") Then
		$aTempSides = StringSplit($SIDESNAMES, "|")
		$sLastSide = $aTempSides[$aTempSides[0]]
	Else
		$sLastSide = $SIDESNAMES
	EndIf
	;Global Enum $eVectorLeftTop, $eVectorRightTop, $eVectorLeftBottom, $eVectorRightBottom
	Local $iSide = $eVectorLeftTop
	Switch $sLastSide
		Case "TL"
			$iSide = $eVectorLeftTop
		Case "TR" 
			$iSide = $eVectorLeftTop
		Case "BL"
			$iSide = $eVectorLeftBottom
		Case "BR"
			$iSide = $eVectorRightBottom
	EndSwitch
	Local $aLastDropPoint = _GetVectorOutZone($iSide)
	
	For $x = 1 To 2
		SetLog("[" & $x & "] Checking left troops", $COLOR_DEBUG1) 
		If PrepareAttack($g_iMatchMode, True) = 0 Then
			SetDebugLog("No Wast time... exit, no troops usable left", $COLOR_DEBUG)
			ExitLoop ;Check remaining quantities
		EndIf
		Local $iRandomXY = Round(Random(1, UBound($aLastDropPoint) - 1))
		SetDebugLog("sLastSide = " & $sLastSide & ", count DropPoint = " & UBound($aLastDropPoint) & " iRandomXY = " & $iRandomXY, $COLOR_DEBUG1)
		
		For $i = 0 To UBound($g_avAttackTroops) - 1
			Local $aRandomCoord = $aLastDropPoint[$iRandomXY]
			;SetLog("aCoord = " & _ArrayToString($aRandomCoord, ","), $COLOR_DEBUG1)
			If $g_avAttackTroops[$i][0] >= $eBarb And $g_avAttackTroops[$i][0] <= $eIWiza And $g_avAttackTroops[$i][1] > 0 Then
				; launch remaining troops
				SelectDropTroop($i)
				SetLog("Dropping left : x" & $g_avAttackTroops[$i][1] & " " & GetTroopName($g_avAttackTroops[$i][0], $g_avAttackTroops[$i][1]) & " on " & $sLastSide & " [" & $aRandomCoord[0] & "," & $aRandomCoord[1] & "]", $COLOR_DEBUG1)
				Click($aRandomCoord[0], $aRandomCoord[1], $g_avAttackTroops[$i][1], 150) ;Drop troop
				If _Sleep(500) Then Return
			EndIf
		Next
	Next
	CheckHeroesHealth()
	SetLog("Finished Attacking, waiting for the battle to end")
EndFunc   ;==>AttackSmartFarm

Func LaunchTroopSmartFarm($listInfoDeploy, $iCC, $iKing, $iQueen, $iWarden, $iChampion, $iMinion, $SIDESNAMES = "TR|TL|BR|BL")

	SetDebugLog("LaunchTroopSmartFarm with CC " & $iCC & ", K " & $iKing & ", Q " & $iQueen & ", W " & $iWarden & ", C " & $iChampion & ", M " & $iMinion, $COLOR_DEBUG)
	; $ListInfoDeploy = [Troop, No. of Sides, $WaveNb, $MaxWaveNb, $slotsPerEdge]
	Local $listListInfoDeployTroopPixel[0]
	Local $pixelRandomDrop[2]
	Local $pixelRandomDropcc[2]
	Local $troop, $troopNb, $name

	For $i = 0 To UBound($listInfoDeploy) - 1
		If IsProblemAffect() Then Return
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
		SetDebugLog("**ListInfoDeploy row " & $i & ": USE " & "[" & $troopKind & "] " & GetTroopName($troopKind, 0) & " SIDES " & $nbSides & " WAVE " & $waveNb & " XWAVE " & $maxWaveNb & " SLOTXEDGE " & $slotsPerEdge, $COLOR_DEBUG)

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

	Local $numberSidesDropTroop = 1

	; Drop a full wave of all troops (e.g. giants, barbs and archers) on each side then switch sides.
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

							If $g_aiDeployHeroesPosition[0] <> -1 Then
								$pixelRandomDrop[0] = $g_aiDeployHeroesPosition[0]
								$pixelRandomDrop[1] = $g_aiDeployHeroesPosition[1]
								SetDebugLog("Deploy Heroes $g_aiDeployHeroesPosition")
							Else
								$pixelRandomDrop[0] = $g_aaiBottomRightDropPoints[2][0]
								$pixelRandomDrop[1] = $g_aaiBottomRightDropPoints[2][1] ;
								SetDebugLog("Deploy Heroes $g_aaiBottomRightDropPoints")
							EndIf
							If $g_aiDeployCCPosition[0] <> -1 Then
								$pixelRandomDropcc[0] = $g_aiDeployCCPosition[0]
								$pixelRandomDropcc[1] = $g_aiDeployCCPosition[1]
								SetDebugLog("Deploy CC $g_aiDeployHeroesPosition")
							Else
								$pixelRandomDropcc[0] = $g_aaiBottomRightDropPoints[2][0]
								$pixelRandomDropcc[1] = $g_aaiBottomRightDropPoints[2][1] ;
								SetDebugLog("Deploy CC $g_aaiBottomRightDropPoints")
							EndIf

							If ($g_bIsCCDropped = False And $infoTroopListArrPixel[0] = "CC" And $i = $numberSidesDropTroop - 1) Then
								dropCC($pixelRandomDropcc[0], $pixelRandomDropcc[1], $iCC)
								$g_bIsCCDropped = True
							ElseIf ($g_bIsHeroesDropped = False And $infoTroopListArrPixel[0] = "HEROES" And $i = $numberSidesDropTroop - 1) Then
								dropHeroes($pixelRandomDrop[0], $pixelRandomDrop[1], $iKing, $iQueen, $iWarden, $iChampion, $iMinion)
								$g_bIsHeroesDropped = True
							EndIf
						Else
							;
							; $infoTroopListArrPixel[  $troop, $listInfoPixelDropTroop, $nbTroopsPerEdge, $slotsPerEdge, $number, $name ]
							;
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
					If _Sleep(SetSleep(0)) Then Return
				Next
			EndIf
		EndIf
		If _Sleep(SetSleep(1)) Then Return
	Next

	For $numWave = 0 To UBound($listListInfoDeployTroopPixel) - 1
		If IsProblemAffect() Then Return
		Local $listInfoDeployTroopPixel = $listListInfoDeployTroopPixel[$numWave]
		For $i = 0 To UBound($listInfoDeployTroopPixel) - 1
			Local $infoPixelDropTroop = $listInfoDeployTroopPixel[$i]
			If Not (IsString($infoPixelDropTroop[0]) And ($infoPixelDropTroop[0] = "CC" Or $infoPixelDropTroop[0] = "HEROES")) Then
				Local $numberLeft = ReadTroopQuantity($infoPixelDropTroop[0])
				If $g_bDebugSetlog Then
					Local $aiSlotPos = GetSlotPosition($infoPixelDropTroop[0])
					SetDebugLog("Slot Nun= " & $infoPixelDropTroop[0])
					SetDebugLog("Slot Xaxis= " & $aiSlotPos[0])
				    SetDebugLog($infoPixelDropTroop[5] & " - NumberLeft : " & $numberLeft)
				EndIf
				If ($numberLeft > 0) Then
					If _Sleep($DELAYLAUNCHTROOP21) Then Return
					SelectDropTroop($infoPixelDropTroop[0]) ;Select Troop
					If _Sleep($DELAYLAUNCHTROOP23) Then Return
					SetLog("Dropping last " & $numberLeft & "  of " & $infoPixelDropTroop[5], $COLOR_SUCCESS)
					;                     $troop,             $listArrPixel,       $number,      $slotsPerEdge = 0
					DropOnPixel($infoPixelDropTroop[0], $infoPixelDropTroop[1], Ceiling($numberLeft), $infoPixelDropTroop[3])
				EndIf
			EndIf
			If _Sleep(SetSleep(0)) Then Return
		Next
		If _Sleep(SetSleep(1)) Then Return
	Next
EndFunc   ;==>LaunchTroopSmartFarm

Func DropTroopSmartFarm($troop, $nbSides, $number, $slotsPerEdge = 0, $name = "", $SIDESNAMES = "TR|TL|BR|BL")

	Local $listInfoPixelDropTroop[0]

	If $slotsPerEdge = 0 Or $number < $slotsPerEdge Then $slotsPerEdge = Ceiling($number / $nbSides)

	If $nbSides < 1 Then Return
	Local $nbTroopsLeft = $number
	Local $nbTroopsPerEdge = Round($nbTroopsLeft / $nbSides)

	If ($number > 0 And $nbTroopsPerEdge = 0) Then $nbTroopsPerEdge = 1

	If $g_bDebugSmartFarm Then Setlog(" - " & GetSlotTroopName($troop) & " Number: " & $number & " Sides: " & $nbSides & " SlotsPerEdge: " & $slotsPerEdge)

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

Func TestSF()
	CheckZoomOut("VillageSearch")
	PrepareAttack($DB)
	Local $Nside = ChkSmartFarm()
	AttackSmartFarm($Nside[1], $Nside[2])
	ReturnHome()
EndFunc

Func SFLoop($iCountLoop = 1, $bStopWhenResourceFull = False)
	If isGoldFull() And isElixirFull() And $bStopWhenResourceFull Then Return
	For $i = 1 To $iCountLoop
		ZoomOut()
		PrepareSearch()
		If Not $g_bRunState Then Return
		VillageSearch()
		If Not $g_bRunState Then Return
		CheckZoomOut("VillageSearch")
		PrepareAttack($DB)
		If Not $g_bRunState Then Return
		Local $Nside = ChkSmartFarm()
		AttackSmartFarm($Nside[1], $Nside[2])
		If Not $g_bRunState Then Return
		ReturnHome()
		If Not $g_bRunState Then Return
		VillageReport()
		If Not $g_bRunState Then Return
		RequestCC()
		Setlog("SF Loop [" & $i & "/" & $iCountLoop & "]", $COLOR_ACTION) 
		If isGoldFull() And isElixirFull() And $bStopWhenResourceFull Then Return
	Next
EndFunc
