
; #FUNCTION# ====================================================================================================================
; Name ..........: chkShieldStatus
; Description ...: Reads Shield & Personal Break time to update global values for user management of Personal Break
; Syntax ........: chkShieldStatus([$bForceChkShield = False[, $bForceChkPBT = False]])
; Parameters ....: $bForceChkShield     - [optional] a boolean value. Default is False.
; ...............; $bForceChkPBT        - [optional] a boolean value. Default is False.
; Return values .: None
; Author ........: MonkeyHunter (2016-02)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func chkShieldStatus($bChkShield = True, $bForceChkPBT = False)

	; skip shield data collection if force single PB, wait for shield, or close while training not enabled, or window is not on main base
	Local $bHaltModeWithShield = $g_bChkBotStop And $g_iCmbBotCond >= 19 And $g_iCmbBotCond <= 21
	If (Not $g_bForceSinglePBLogoff And Not $bHaltModeWithShield) And Not $g_bCloseWhileTrainingEnable Or Not (IsMainPage()) Then Return

	Local $Result, $iTimeTillPBTstartSec, $ichkTime = 0, $ichkSTime = 0, $ichkPBTime = 0

	If $bChkShield Or $g_asShieldStatus[0] = "" Or $g_asShieldStatus[1] = "" Or $g_asShieldStatus[2] = "" Or $g_sPBStartTime = "" Or $g_bGForcePBTUpdate = True Then ; almost always get shield information

		$Result = getShieldInfo() ; get expire time of shield

		If @error Then SetLog("chkShieldStatus Shield OCR error= " & @error & "Extended= " & @extended, $COLOR_ERROR)
		If _Sleep($DELAYRESPOND) Then Return

		If IsArray($Result) Then
			Local $iShieldExp = _DateDiff('n', $Result[2], _NowCalc())
			If Abs($iShieldExp) > 0 Then
				Local $sFormattedDiff = _Date_Difference(_NowCalc(), $Result[2], 4)
				SetLog("Shield expires in: " & $sFormattedDiff)
			Else
				SetLog("Shield has expired")
			EndIf

			If _DateIsValid($g_asShieldStatus[2]) Then ; if existing global shield time is valid
				$ichkTime = Abs(Int(_DateDiff('s', $g_asShieldStatus[2], $Result[2]))) ; compare old and new time
				If $ichkTime > 60 Then ; test if more than 60 seconds different in case of attack while shield has reduced time
					$bForceChkPBT = True ; update PB time
					SetDebugLog("Shield time changed: " & $ichkTime & " Sec, Force PBT OCR: " & $bForceChkPBT, $COLOR_WARNING)
				EndIf
			EndIf

			$g_asShieldStatus = $Result ; update ShieldStatus global values

			If $bHaltModeWithShield Then ; is Halt mode enabled and With Shield selected?
				If $g_asShieldStatus[0] = "shield" Then ; verify shield
					SetLog("Shield found, Halt Attack Now!", $COLOR_INFO)
					$g_bWaitShield = True
					$g_bIsClientSyncError = False ; cancel OOS restart to enable BotCommand to process Halt mode
					$g_bIsSearchLimit = False ; reset search limit flag to enable BotCommand to process Halt mode
				Else
					$g_bWaitShield = False
					If $g_bMeetCondStop = True Then
						SetLog("Shield expired, resume attacking", $COLOR_INFO)
						$g_bTrainEnabled = True
						$g_bDonationEnabled = True
						$g_bMeetCondStop = False
					Else
						SetDebugLog("Halt With Shield: Shield not found...", $COLOR_DEBUG)
					EndIf
				EndIf
			EndIf
		Else
			SetDebugLog("Bad getShieldInfo() return value: " & $Result, $COLOR_ERROR)
			If _Sleep($DELAYRESPOND) Then Return

			For $i = 0 To UBound($g_asShieldStatus) - 1 ; clear global shieldstatus if no shield data returned
				$g_asShieldStatus[$i] = ""
			Next

		EndIf
	EndIf

	If $g_bForceSinglePBLogoff = False Then Return ; return if force single PB feature not enabled.

	If _DateIsValid($g_sPBStartTime) Then
		$ichkPBTime = Int(_DateDiff('s', $g_sPBStartTime, _NowCalc())) ; compare existing shield date/time to now.
		If $ichkPBTime >= 295 Then
			$bForceChkPBT = True ; test if PBT date/time in more than 5 minutes past, force update
			SetDebugLog("Found old PB time= " & $ichkPBTime & " Seconds, Force update:" & $bForceChkPBT, $COLOR_WARNING)
		EndIf
	EndIf

	If $bForceChkPBT Or $g_bGForcePBTUpdate Or $g_sPBStartTime = "" Then

		$g_bGForcePBTUpdate = False ; Reset global flag to force PB update

		$Result = getPBTime() ; Get time in future that PBT starts

		If @error Then SetLog("chkShieldStatus getPBTime OCR error= " & @error & ", Extended= " & @extended, $COLOR_ERROR)
		;SetDebugLog("getPBTime() returned: " & $Result, $COLOR_DEBUG)
		If _Sleep($DELAYRESPOND) Then Return

		If _DateIsValid($Result) Then
			Local $iTimeTillPBTstartMin = Int(_DateDiff('n', $Result, _NowCalc())) ; time in minutes

			If Abs($iTimeTillPBTstartMin) > 0 Then
				Local $sFormattedDiff = _Date_Difference(_DateAdd("n", -1, _NowCalc()), $Result, 4)
				SetLog("Personal Break starts in: " & $sFormattedDiff)
				Local $CorrectstringPB_GUI = StringReplace($sFormattedDiff, StringInStr($sFormattedDiff, " hours ") >= 1 ? " hours " : " hour ", "h")
				$CorrectstringPB_GUI = StringReplace($CorrectstringPB_GUI, StringInStr($CorrectstringPB_GUI, " minutes ") >= 1 ? " minutes " : " minute ", "'")
			EndIf

			If $iTimeTillPBTstartMin < -(Int($g_iSinglePBForcedEarlyExitTime)) Then
				$g_sPBStartTime = _DateAdd('n', -(Int($g_iSinglePBForcedEarlyExitTime)), $Result) ; subtract GUI time setting from PB start time to set early forced break time
			ElseIf $iTimeTillPBTstartMin < 0 Then ; Might have missed it if less 15 min, but try anyway
				$g_sPBStartTime = $Result
			Else
				$g_sPBStartTime = "" ; clear value, can not log off ealy.
			EndIf
			SetDebugLog("Early Log Off time=" & $g_sPBStartTime & ", In " & _DateDiff('n', $g_sPBStartTime, _NowCalc()) & " Minutes", $COLOR_DEBUG)
		Else
			If $Result = "Legend" Then 
				SetLog("No PBT on Legend League", $COLOR_INFO)
				Return 
			Else
				SetLog("Bad getPBTtime() return value: " & $Result, $COLOR_ERROR)
				$g_sPBStartTime = "" ; reset to force update next pass
			EndIf
		EndIf
	EndIf

EndFunc   ;==>chkShieldStatus

; Returns formatted difference between two dates
; $iGrain from 0 To 5, to control level of detail that is returned
Func _Date_Difference($sStartDate, Const $sEndDate, Const $iGrain)
	Local $aUnit[6] = ["Y", "M", "D", "h", "n", "s"]
	Local $aType[6] = ["year", "month", "day", "hour", "minute", "second"]
	Local $sReturn = "", $iUnit

	For $i = 0 To $iGrain
		$iUnit = _DateDiff($aUnit[$i], $sStartDate, $sEndDate)
		If $iUnit <> 0 Then
			$sReturn &= $iUnit & " " & $aType[$i] & ($iUnit > 1 ? "s" : "") & " "
		EndIf
		$sStartDate = _DateAdd($aUnit[$i], Int($iUnit), $sStartDate)
	Next

	Return $sReturn
EndFunc   ;==>_Date_Difference


; #FUNCTION# ====================================================================================================================
; Name ..........: getShieldInfo
; Description ...: Determines if personal shield exists and returns type/time data
; Syntax ........: getShieldInfo()
; Parameters ....: none
; Return values .: Returns Array =  $aPBReturnResult
; ...............: [0]=String shield type, [1]=String Shield remaining format = "00:00:00", [2]=String Shield expire date/time
; ...............: Sets @error if buttons not found properly or problem with OCR of shield time, and sets @extended with string error message
; Author ........: MonkeyHunter (01-2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
;
Func getShieldInfo()

	Local $sTimeResult = ""
	Local $aString[3]
	Local $iShieldSeconds
	Local $iDay = 0, $iHour = 0, $iMin = 0, $iSec = 0
	Local $aPBReturnResult[3] = ["", "", ""] ; reset return values
	; $aPBReturnResult[3] = [0] = string type of shield, [1] = string shield time remaining,  [2] = string Shield expire date/time used by _DateDiff()
	$aPBReturnResult[1] = StringFormat("%02s", ($iDay * 24) + $iHour) & ":" & StringFormat("%02s", $iMin) & ":" & StringFormat("%02s", $iSec)

	If IsMainPage() = False Then ; check for main page or do not try
		SetLog("unable to read shield information", $COLOR_ERROR)
		Return
	EndIf
	
	SetLog("Checking Shield", $COLOR_ACTION)
	If QuickMIS("BC1", $g_sImgShield, 506, 5, 530, 35) Then 
		Select
			Case $g_iQuickMISName = "NoShield"
				$aPBReturnResult[0] = "none"
				SetLog("No shield active", $COLOR_DEBUG)
			Case $g_iQuickMISName = "Shield"
				$aPBReturnResult[0] = "shield"
				SetLog("Shield Active", $COLOR_DEBUG)
		EndSelect
	Else
		SetLog("Cannot determine shield Type", $COLOR_DEBUG2) 
		Return
	EndIf
	
	$sTimeResult = getOcrGuardShield(538, 21) ; read Shield time
	SetDebugLog("OCR Shield Time= " & $sTimeResult, $COLOR_DEBUG)
	If $sTimeResult = "" Then ; try a 2nd time after a short delay if slow PC and null read
		If _Sleep($DELAYPERSONALSHIELD2) Then Return $aPBReturnResult ; pause for slow PC
		$sTimeResult = getOcrGuardShield(538, 21) ; read Shield time
		SetDebugLog("OCR2 Shield Time= " & $sTimeResult, $COLOR_DEBUG)
		If $sTimeResult = "" Then ; error if no read value
			$aPBReturnResult[1] = '00:00:00'
			Return $aPBReturnResult ; return zero value
		EndIf
	EndIf

	If _Sleep($DELAYPERSONALSHIELD3) Then Return $aPBReturnResult ; improve pause/stop button response

	$aString = StringSplit($sTimeResult, " ") ; split hours/minutes or minutes/seconds
	Switch $aString[0]
		Case 1
			If StringInStr($aString[1], "s", $STR_NOCASESENSEBASIC) Then $iSec = Number($aString[1])
		Case 2
			Select
				Case StringInStr($aString[1], "d", $STR_NOCASESENSEBASIC)
					$iDay = Number($aString[1])
					If StringInStr($aString[2], "h", $STR_NOCASESENSEBASIC) Then
						$iHour = Number($aString[2])
					EndIf
				Case StringInStr($aString[1], "h", $STR_NOCASESENSEBASIC)
					$iHour = Number($aString[1])
					If StringInStr($aString[2], "m", $STR_NOCASESENSEBASIC) Then
						$iMin = Number($aString[2])
					EndIf
				Case StringInStr($aString[1], "m", $STR_NOCASESENSEBASIC)
					$iMin = Number($aString[1])
					If StringInStr($aString[2], "s", $STR_NOCASESENSEBASIC) Then
						$iSec = Number($aString[2])
					EndIf
				Case Else
					SetLog("strange error, unexpected shield value?", $COLOR_ERROR)
					SetError(3, "Error processing time string")
					Return $aPBReturnResult ; return zero value
			EndSelect
		Case Else
			SetLog("Error processing time string: " & $sTimeResult, $COLOR_ERROR)
			SetError(4, "Error processing time string")
			Return $aPBReturnResult ; return zero value
	EndSwitch

	$aPBReturnResult[1] = StringFormat("%02s", ($iDay * 24) + $iHour) & ":" & StringFormat("%02s", $iMin) & ":" & StringFormat("%02s", $iSec)
	SetDebugLog("Shield Time String = " & $aPBReturnResult[1], $COLOR_DEBUG)

	$iShieldSeconds = ($iDay * 86400) + ($iHour * 3600) + ($iMin * 60) + $iSec ; add time into total seconds
	SetDebugLog("Computed Shield Seconds = " & $iShieldSeconds, $COLOR_DEBUG)

	$aPBReturnResult[2] = _DateAdd('s', Int($iShieldSeconds), _NowCalc()) ; Find actual expire time from NOW.
	If @error Then SetLog("_DateAdd error= " & @error, $COLOR_ERROR)
	SetDebugLog("Shield expires at: " & $aPBReturnResult[2], $COLOR_INFO)

	Return $aPBReturnResult

EndFunc   ;==>getShieldInfo
