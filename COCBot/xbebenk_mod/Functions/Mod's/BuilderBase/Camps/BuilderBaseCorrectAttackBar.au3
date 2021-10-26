;=========================================================================================================
; Name ..........: BuilderBaseAttack
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseAttack()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018)
; Modified ......: Boludoz (12/2018 - 31/12/2019, 25/08/2020), Dissociable (07-2020)
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2020
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
	For $iName = 0 To UBound($g_iCmbCampsBB) - 1
		$sName &= ArmyCampSelectedNames($g_iCmbCampsBB[$iName]) <> "" ? ArmyCampSelectedNames($g_iCmbCampsBB[$iName]) : ("Barb")
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
	
	Local $sLastObj = "Barbarian", $sTmp
	Local $aFakeCsv[1]
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
					_CaptureRegion2()
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
				For $i = 0 To UBound($g_iCmbCampsBB) - 1
					$sTmp = $g_asAttackBarBB2[$g_iCmbCampsBB[$i]]
					If Not StringIsSpace($sTmp) Then $sLastObj = $sTmp
					$sName &= $sLastObj
					If $i <> UBound($g_iCmbCampsBB) - 1 Then $sName &= "|"
					$aFakeCsv[0] = $sName
					_ArrayAdd($aLines, $aFakeCsv)
				Next
				
				ExitLoop
		EndSwitch
	Until True

	; _ArrayDisplay($aLines)
	
	If UBound($aLines) = 0 Then
		SetLog("BuilderBaseSelectCorrectScript 0x12 error.", $COLOR_ERROR)
		Return
	EndIf
	
	; Move backwards through the array deleting the blanks
	For $i = UBound($aAvailableTroops) - 1 To 0 Step -1
		If StringIsSpace($aAvailableTroops[$i][0]) Then
			_ArrayDelete($aAvailableTroops, $i)
		EndIf
	Next
	
	_ArraySort($aAvailableTroops, 0, 0, 0, 1)

	; Let's get the correct number of Army camps
	Local $aSwicthBtn = findMultipleQuick($g_sImgCustomArmyBB, 20, "0,695,858,722", Default, "ChangeTroops", Default, 30, False)
	If Not IsArray($aSwicthBtn) Then
		Return
	EndIf
	_ArraySort($aSwicthBtn, 0, 0, 0, 1)
	
	Local $iCampsQuantities = UBound($aSwicthBtn)
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
		$aCamps[$i] = __ArraySearch($g_asAttackBarBB2, $aCamps[$i]) < 0 ? ("Barb") : __ArraySearch($g_asAttackBarBB2, $aCamps[$i])
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
		If $aNewAvailableTroops[$aWrongCamps[0]][1] >= $eBBTroopMachine Then
			; Slot is Builder machine or things like that.
			SetDebugLog("Read to Builder Machine Slot or even the next ones, Exiting switch troops loop.", $COLOR_INFO)
			$bDone = True
			ExitLoop
		EndIf
		$bWaschanged = True
		SetLog("Incorrect troop On Camp " & $aWrongCamps[0] + 1 & " - " & $aNewAvailableTroops[$aWrongCamps[0]][0] & " -> " & $sMissingCamp)
		SetDebugLog("Click Switch Button " & $aWrongCamps[0], $COLOR_INFO)
		Click($aSwicthBtn[$aWrongCamps[0]][1] + Random(2, 10, 1), $aSwicthBtn[$aWrongCamps[0]][2] + Random(2, 10, 1))
		If Not $g_bRunState Then Return
		If RandomSleep(250) Then Return

		If Not _WaitForCheckImg($g_sImgCustomArmyBB, "0,681,860,728", "ChangeTDis") Then
			Setlog("_WaitForCheckImg Error at Camps!", $COLOR_ERROR)
			$iAvoidInfLoop += 1
			If Not $g_bRunState Then ExitLoop
			ContinueLoop
		EndIf

		; Result [X][0] = NAME , [x][1] = Xaxis , [x][2] = Yaxis , [x][3] = Level
		$aAttackBar = _ImageSearchXML($g_sImgDirBBTroops, 20, "0,523,861,615", True, False)
		If $aAttackBar = -1 Then
			Return False
		EndIf

		For $j = 0 To UBound($aAttackBar) - 1
			If Not $g_bRunState Then ExitLoop
			; If The item is The Troop that We Missing
			If $aAttackBar[$j][0] = $sMissingCamp Then
				If RandomSleep(250) Then Return
				; Select The New Troop
				PureClick($aAttackBar[$j][1] + Random(1, 5, 1), $aAttackBar[$j][2] + Random(1, 5, 1), 1, 0)
				If RandomSleep(250) Then Return
				SetDebugLog("Selected " & FullNametroops($sMissingCamp) & " X:| " & $aAttackBar[$j][1] & " Y:| " & $aAttackBar[$j][2], $COLOR_SUCCESS)
				$aNewAvailableTroops[$aWrongCamps[0]][0] = $sMissingCamp
				; Set the Priority Again
				For $i2 = 0 To UBound($g_asAttackBarBB2) - 1
					If (StringInStr($aNewAvailableTroops[$aWrongCamps[0]][0], $g_asAttackBarBB2[$i2]) > 0) Then
						$aNewAvailableTroops[$aWrongCamps[0]][1] = $i2
					EndIf
				Next
				_ArraySort($aNewAvailableTroops, 0, 0, 0, 1)
				If $g_bDebugSetlog Then SetDebugLog("New Army is " & _ArrayToString($aNewAvailableTroops, "-", -1, -1, "|", -1, -1), $COLOR_INFO)
			EndIf
		Next
	WEnd
	
	If $bWaschanged Then
		For $w = 0 To 5
			If QuickMIS("N1", $g_sImgCustomArmyBB, 2, 681, 860, 728) = "ChangeTDis" Then
				Click(8, 720, 1)
				ExitLoop
			EndIf
			If RandomSleep(500) Then Return
		Next
	Else
		If RandomSleep(500) Then Return
		Return
	EndIf

	; populate the correct array with correct Troops
	For $i = 0 To UBound($aNewAvailableTroops) - 1
		$aAvailableTroops[$i][0] = $aNewAvailableTroops[$i][0]
	Next
	
	Local $iTroopBanners = 640 ; y location of where to find troop quantities

	For $i = 0 To UBound($aAvailableTroops) - 1
		If Not $g_bRunState Then Return
		If $aAvailableTroops[$i][0] <> "" Then ;We Just Need To redo the ocr for mentioned troop only
			Local $iCount = Number(_getTroopCountSmall($aAvailableTroops[$i][1], $iTroopBanners))
			If $iCount == 0 Then $iCount = Number(_getTroopCountBig($aAvailableTroops[$i][1], $iTroopBanners - 7))
			If $iCount == 0 And Not String($aAvailableTroops[$i][0]) = "Machine" Then
				SetLog("Could not get count for " & $aAvailableTroops[$i][0] & " in slot " & String($aAvailableTroops[$i][3]), $COLOR_ERROR)
				ContinueLoop
			ElseIf (StringInStr($aAvailableTroops[$i][0], "Machine") > 0) Then
				$iCount = 1
			EndIf
		EndIf
		$aAvailableTroops[$i][4] = $iCount
	Next


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
