
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

	If QuickMIS("BC1", $g_sImgShield, 430, 5, 460, 35) Then 
		Select
			Case $g_iQuickMISName = "NoShield"
				$aPBReturnResult[0] = "none"
				SetLog("No shield active", $COLOR_DEBUG)
			Case $g_iQuickMISName = "Shield"
				$aPBReturnResult[0] = "shield"
				SetLog("Shield Active", $COLOR_DEBUG)
			Case $g_iQuickMISName = "Guard"
				$aPBReturnResult[0] = "guard"
				SetLog("Guard Active", $COLOR_DEBUG)
		EndSelect
	Else
		SetLog("Sorry, Your monkey not code anymore", $COLOR_ERROR) 
		SetError(1, "Monkey read Shield")
		Return
	EndIf
	
	$sTimeResult = getOcrGuardShield(484, 21) ; read Shield time
	SetDebugLog("OCR Shield Time= " & $sTimeResult, $COLOR_DEBUG)
	If $sTimeResult = "" Then ; try a 2nd time after a short delay if slow PC and null read
		If _Sleep($DELAYPERSONALSHIELD2) Then Return $aPBReturnResult ; pause for slow PC
		$sTimeResult = getOcrGuardShield(484, 21) ; read Shield time
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
