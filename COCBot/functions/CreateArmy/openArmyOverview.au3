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
Func OpenArmyOverview($bCheckMain = True, $sWhereFrom = "Undefined")
	If $bCheckMain Then
		For $i = 1 To 2
			If $g_bDebugSetlogTrain Then SetLog("Waiting MainScreen #" & $i, $COLOR_ACTION)
			If isOnMainVillage() Then ; check for main page
				If $g_bDebugSetlogTrain Then SetLog("MainScreen located", $COLOR_ACTION)
				ExitLoop
			Else
				SetLog("Cannot open Army Overview window ", $COLOR_ERROR)
				checkObstacles()
			EndIf
		Next
	EndIf
	
	ClickP($aArmyTrainButton, 1, 0, "#0293") ; Button Army Overview
	If _Sleep(1000) Then Return
	If $g_bDebugSetlogTrain Then SetLog("Click $aArmyTrainButton" & " (Called from " & $sWhereFrom & ")", $COLOR_SUCCESS)
	
	For $i = 1 To 5
		If Not $g_bRunState Then Return
		If IsTrainPage(True) Then Return True
		If $i = 5 Then SetLog("[" & $i & "] Check Opening ArmyWindow", $COLOR_ERROR)
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
