
; #FUNCTION# ====================================================================================================================
; Name ..........: BreakPersonalShield
; Description ...: Function to break shield and personal guard
; Syntax ........: BreakPersonalShield()
; Parameters ....: none
; Return values .: none
; ...............: Sets @error if buttons not found properly and sets @extended with string error message
; Author ........: MonkeyHunter (2016-01)(2017-06)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BreakPersonalShield()

	SetLog("Checking if Shield available", $COLOR_INFO)
	
	For $i = 1 To 3
		If QuickMIS("BC1", $g_sImgShield, 430, 5, 460, 35) Then
			If $g_iQuickMISName = "NoShield" Then 
				SetLog("No shield available", $COLOR_SUCCESS)
				ExitLoop
			EndIf
			PureClickP($aShieldInfoButton)
			If _Sleep(1000) Then Return
			Switch $g_iQuickMISName
				Case "Shield"
					If QuickMIS("BC1", $g_sImgShield & "Remove\", 518, 230, 545, 245) Then
						Click($g_iQuickMISX, $g_iQuickMISY)
						If _Sleep(1000) Then Return
						If ClickOkay("Shield") Then SetLog("Shield removed", $COLOR_SUCCESS)
					EndIf
				Case "Guard"
					If QuickMIS("BC1", $g_sImgShield & "Remove\", 518, 230, 545, 245) Then
						Click($g_iQuickMISX, $g_iQuickMISY)
						If _Sleep(1000) Then Return
						If ClickOkay("Shield") Then SetLog("Guard removed", $COLOR_SUCCESS)
					EndIf
			EndSwitch
		EndIf
	Next
EndFunc   ;==>BreakPersonalShield
