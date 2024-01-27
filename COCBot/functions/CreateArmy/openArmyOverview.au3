; #FUNCTION# ====================================================================================================================
; Name ..........: OpenArmyOverview
; Description ...: Opens and waits for Army Overiew window and verifes success
; Syntax ........: OpenArmyOverview()
; Parameters ....:
; Return values .: None
; Author ........: MonkeyHunter (01-2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func OpenArmyOverview($sWhereFrom = "Undefined")
	If IsProblemAffect(True) Then Return
	If IsTrainPage(False, 1) Then Return True
	If Not checkChatTabPixel() Then checkObstacles()
	
	If $g_bDebugSetlogTrain Then SetLog("OpenArmyOverview" & " (Called from " & $sWhereFrom & ")", $COLOR_SUCCESS)
	If Not $g_bRunState Then Return
	For $i = 1 To 5
		If Not $g_bRunState Then Return
		SetLog("Try open ArmyWindow #" & $i, $COLOR_ACTION)
		If WaitforPixel(30, 522, 31, 523, "FFFFE3", 20, 1) Then
			ClickP($aArmyTrainButton) ; Button Army Overview
			If _Sleep(3000) Then Return
		ElseIf $i = 5 Then 
			SetLog("Cannot Verify Army Button", $COLOR_ERROR)
			SetError(1)
			Return
		EndIf
		
		If IsTrainPage(False, 1) Then 
			SetLog("ArmyWindow OK", $COLOR_ACTION)
			Return True
		EndIf
		
		If _Sleep(500) Then Return
	Next
	Return False
EndFunc   ;==>OpenArmyOverview

Func OpenArmyTab($bSetLog = True, $sWhereFrom = "Undefined")
	Return OpenTrainTab("Army Tab", $bSetLog, $sWhereFrom)
EndFunc   ;==>OpenArmyTab

Func OpenTroopsTab($bSetLog = True, $sWhereFrom = "Undefined")
	Return OpenTrainTab("Train Troops Tab", $bSetLog, $sWhereFrom)
EndFunc   ;==>OpenTroopsTab

Func OpenSpellsTab($bSetLog = True, $sWhereFrom = "Undefined")
	Return OpenTrainTab("Brew Spells Tab", $bSetLog, $sWhereFrom)
EndFunc   ;==>OpenSpellsTab

Func OpenSiegeMachinesTab($bSetLog = True, $sWhereFrom = "Undefined")
	Return OpenTrainTab("Build Siege Machines Tab", $bSetLog, $sWhereFrom)
EndFunc   ;==>OpenSiegeMachinesTab

Func OpenQuickTrainTab($bSetLog = True, $sWhereFrom = "Undefined")
	Return OpenTrainTab("Quick Train Tab", $bSetLog, $sWhereFrom)
EndFunc   ;==>OpenQuickTrainTab

Func OpenTrainTab($sTab, $bSetLog = True, $sWhereFrom = "Undefined")
	
	CheckReceivedTroops()
	If Not IsTrainPage() Then
		SetDebugLog("Error in OpenTrainTab: Cannot find the Army Overview Window", $COLOR_ERROR)
		SetError(1)
		Return False
	EndIf

	Local $aTabButton = findButton(StringStripWS($sTab, 8), Default, 1, True)
	If IsArray($aTabButton) And UBound($aTabButton, 1) = 2 Then
		$aIsTabOpen[0] = $aTabButton[0]
		If Not _CheckPixel($aIsTabOpen, True) Then
			If $bSetLog Or $g_bDebugSetlogTrain Then SetLog("Open " & $sTab & ($g_bDebugSetlogTrain ? " (Called from " & $sWhereFrom & ")" : ""), $COLOR_INFO)
			ClickP($aTabButton)
			
			If Not _WaitForCheckPixel($aIsTabOpen, True) Then
				Local $color = _GetPixelColor($aIsTabOpen[0], $aIsTabOpen[1], True)
				SetLog("Error in OpenTrainTab: Cannot open " & $sTab & ". Pixel to check did not appear : " & $color, $COLOR_ERROR)
				SetError(1)
				Return False
			EndIf
		EndIf
	Else
		SetDebugLog("Error in OpenTrainTab: $aTabButton is no valid Array", $COLOR_ERROR)
		SetError(1)
		Return False
	EndIf

	If _Sleep(200) Then Return
	Return True
EndFunc   ;==>OpenTrainTab

Func CheckReceivedTroops()
	If _CheckPixel($aRecievedTroops, True) Then ; Found the "You have recieved" Message on Screen, wait till its gone.
		SetLog("Clan Castle Message Blocking, Waiting until it's gone", $COLOR_INFO)
		While _CheckPixel($aRecievedTroops, True)
			If _Sleep(500) Then Return
		WEnd
	EndIf
EndFunc
