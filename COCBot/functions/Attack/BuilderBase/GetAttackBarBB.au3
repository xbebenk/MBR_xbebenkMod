; #FUNCTION# ====================================================================================================================
; Name ..........: GetAttackBarBB
; Description ...: Gets the troops and there quantities for the current attack
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

Func GetAttackBarBB($bRemaining = False)
	local $iTroopBanners = 577 ; y location of where to find troop quantities
	local $aSlotX[6] = [108, 180, 252, 325, 397, 468] ; location of x Amount on slot
	local $iSlotOffset = 72 ; slots are 73 pixels apart
	local $iBarOffset = 66 ; 66 pixels from side to attack bar

	local $aBBAttackBar[0][5]
	#comments-start
		$aAttackBar[n][8]
		[n][0] = Name of the found Troop/Spell/Hero/Siege
		[n][1] = The X Coordinate of the Troop
		[n][2] = The Y Coordinate of the Troop/Spell/Hero/Siege
		[n][3] = The Slot Number (Starts with 0)
		[n][4] = The Amount
	#comments-end

	If Not $g_bRunState Then Return ; Stop Button

	local $sSearchDiamond = GetDiamondFromRect("0,580,860,670")
	local $aBBAttackBarResult = findMultiple($g_sImgDirBBTroops, $sSearchDiamond, $sSearchDiamond, 0, 1000, 0, "objectname,objectpoints", True)

	If UBound($aBBAttackBarResult) = 0 Then
		If Not $bRemaining Then
			SetLog("Error in BBAttackBarCheck(): Search did not return any results!", $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("ErrorBBAttackBarCheck", False, Default, Default)
		EndIf
		Return ""
	EndIf

	If Not $g_bRunState Then Return ; Stop Button

	; parse data into attackbar array... not done
	For $i = 0 To UBound($aBBAttackBarResult, 1) - 1
		local $aTroop = $aBBAttackBarResult[$i]

		local $aTempMultiCoords = decodeMultipleCoords($aTroop[1])
		For $j=0 To UBound($aTempMultiCoords, 1) - 1
			Local $aTempCoords = $aTempMultiCoords[$j]
			If UBound($aTempCoords) < 2 Then ContinueLoop
			Local $iSlot = Int(($aTempCoords[0] - $iBarOffset) / $iSlotOffset)
			Local $iCount = Number(getOcrAndCapture("coc-t-s", $aSlotX[$iSlot], $iTroopBanners, 57, 24))
			If $iCount < 1 Then $iCount = 2 ;just assume there are 2 avail troop on this slot for now
			
			local $aTempElement[1][5] = [[$aTroop[0], $aTempCoords[0], $iTroopBanners + 25, $iSlot, $iCount]] ; element to add to attack bar list
			_ArrayAdd($aBBAttackBar, $aTempElement)
		Next

	If Not $g_bRunState Then Return ; Stop Button
	Next
	_ArraySort($aBBAttackBar, 0, 0, 0, 3)
	For $i=0 To UBound($aBBAttackBar, 1) - 1
		SetLog($aBBAttackBar[$i][0] & ", (" & String($aBBAttackBar[$i][1]) & "," & String($aBBAttackBar[$i][2]) & "), Slot: " & String($aBBAttackBar[$i][3]) & ", Count: " & String($aBBAttackBar[$i][4]), $COLOR_SUCCESS)
	Next
	Return $aBBAttackBar
EndFunc


#region - xbebenk
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

;Func BuilderBaseSelectCorrectCampDebug()
;	Local $aLines[0]
;	Local $sName = "CAMP" & "|"
;	For $iName = 0 To UBound($g_iCmbTroopBB) - 1
;		$sName &= ArmyCampSelectedNames($g_iCmbTroopBB[$iName]) <> "" ? ArmyCampSelectedNames($g_iCmbTroopBB[$iName]) : ("Barb")
;		$sName &= "|"
;		If $iName = 0 Then ContinueLoop
;		Local $aFakeCsv[1] = [$sName]
;		_ArrayAdd($aLines, $aFakeCsv)
;	Next
;
;	_ArrayDisplay($aLines)
;EndFunc   ;==>BuilderBaseSelectCorrectCampDebug

Func FullNametroops($aResults)
	For $i = 0 To UBound($g_asAttackBarBB2) - 1
		If $aResults = $g_asAttackBarBB2[$i] Then
			If UBound($g_avStarLabTroops) - 1 < $i + 1 Then ExitLoop
			Return $g_avStarLabTroops[$i + 1][3]
		EndIf
	Next
	Return $aResults
EndFunc   ;==>FullNametroops

Func TestCorrectAttackBarBB()
	Local $aAvailableTroops = GetAttackBarBB()
	CorrectAttackBarBB($aAvailableTroops)
EndFunc   ;==>TestCorrectAttackBarBB

Func CorrectAttackBarBB(ByRef $aAvailableTroops)

	If Not $g_bRunState Then Return
	Local $aLines[0]
	Local $sModeAttack = "SMART"

	
	Local $sLastObj = "Barbarian", $sTmp
	Local $aFakeCsv[1]

	

	Local $bCanGetFromCSV = False

	; Smart attack or badly CSV or Force Army
	If $bCanGetFromCSV = False And $g_bChkBBCustomArmyEnable = True Then
		Local $sName = "CAMP|"
		For $i = 0 To UBound($g_iCmbTroopBB) - 1
			$sTmp = $g_asAttackBarBB2[$g_iCmbTroopBB[$i]]
			If Not StringIsSpace($sTmp) Then $sLastObj = $sTmp
			$sName &= $sLastObj
			If $i <> UBound($g_iCmbTroopBB) - 1 Then
				$sName &= "|"
			EndIf
			$aFakeCsv[0] = $sName
			_ArrayAdd($aLines, $aFakeCsv)
		Next
	EndIf

	If UBound($aLines) = 0 Then
		SetLog("CorrectAttackBarBB 0x12 error.", $COLOR_ERROR)
		Return
	EndIf

	_ArraySort($aAvailableTroops, 0, 0, 0, 1)
	Local $iSlotWidth = 72
	Local $iDefaultY = 655
	Local $iCampsQuantities = Ubound($aAvailableTroops)
	Local $aSwicthBtn[0]
	For $z = 0 To Ubound($aAvailableTroops) - 1
		ReDim $aSwicthBtn[$z+1]
		$aSwicthBtn[$z] = $aAvailableTroops[$z][1] + 5
	Next
	Setlog("Available " & $iCampsQuantities & " Camps.", $COLOR_INFO)

	Local $aCamps[0], $aCampsFake[0], $iLast = -1, $bOkCamps = False

	; Loop for every line on "CSV".
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
		SetLog("CorrectAttackBarBB 0x09 error.", $COLOR_ERROR)
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
			If QuickMIS("N1", $g_sImgCustomArmyBB, 60, 632, 800, 666) = "ChangeTDis" Then ExitLoop
			If $iSleepWait <> 4 Then ContinueLoop
			Setlog("Error at Camps!", $COLOR_ERROR)
			$iAvoidInfLoop += 1
			If Not $g_bRunState Then Return
			ContinueLoop 2
		Next

		; Open eyes and learn.
		$aAttackBar = decodeSingleCoord(findImageInPlace($sMissingCamp, $g_sImgDirBBTroops & "\" & $sMissingCamp & "*", "40,462(861,550)", True))
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
			SetDebugLog("New Army is " & _ArrayToString($aNewAvailableTroops, "-", -1, -1, "|", -1, -1), $COLOR_INFO)
		Else
			Click(8, 720, 1)
			Return False
		EndIf
	WEnd
	If _Sleep(500) Then Return

	If $bWaschanged Then
		If QuickMIS("N1", $g_sImgCustomArmyBB, 60, 632, 800, 666) = "ChangeTDis" Then
			Click(8, 720, 1)
		EndIf
	Else
		Return False
	EndIf

	; populate the correct array with correct Troops
	For $i = 0 To UBound($aNewAvailableTroops) - 1
		$aAvailableTroops[$i][0] = $aNewAvailableTroops[$i][0]
	Next

	For $i = 0 To UBound($aAvailableTroops) - 1
		If Not $g_bRunState Then Return
		If $aAvailableTroops[$i][0] <> "" Then SetLog("[" & $i + 1 & "] - " & $aAvailableTroops[$i][4] & "x " & FullNametroops($aAvailableTroops[$i][0]), $COLOR_SUCCESS)
	Next
	Return True
EndFunc   ;==>CorrectAttackBarBB

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