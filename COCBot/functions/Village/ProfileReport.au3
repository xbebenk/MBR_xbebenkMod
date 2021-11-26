; #FUNCTION# ====================================================================================================================
; Name ..........: ProfileReport
; Description ...: This function will report Attacks Won, Defenses Won, Troops Donated and Troops Received from Profile info page
; Syntax ........: ProfileReport()
; Parameters ....:
; Return values .: None
; Author ........: Sardo
; Modified ......: KnowJack (07-2015), Sardo (08-2015), CodeSlinger69 (01-2017), Fliegerfaust (09-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once
Func ProfileReport()

	Local $iAttacksWon = 0, $iDefensesWon = 0

	Local $iCount = 0
	ClickAway()
	If _Sleep($DELAYPROFILEREPORT1) Then Return

	SetLog("Profile Report", $COLOR_INFO)
	SetLog("Opening Profile page to read Attacks, Defenses, Donations and Recieved Troops", $COLOR_INFO)
	Click(49, 30, 1, 0, "#0222") ; Click Info Profile Button
	If _Sleep($DELAYPROFILEREPORT2) Then Return

	While Not IsFullScreenWindow() ; wait for Info Profile to open
		$iCount += 1
		If _Sleep(250) Then Return
		SetDebugLog("[" & $iCount & "] Waiting Profile window open", $COLOR_ACTION)
		If $iCount >= 20 Then 
			SetLog("Profile window doesnt exist, exiting...", $COLOR_ERROR)
			ClickAway()
			Return
		EndIF
	WEnd
	
	If _Sleep(1000) Then Return
	$iCount = 0
	While Not WaitforPixel(825, 382, 826, 383, "2E2C62", 6, 1)
		$iCount += 1
		ClickDrag(431, 185, 431, 610)
		_Sleep(1500)
		If Not IsFullScreenWindow() Then ExitLoop
		If $iCount > 15 Then ExitLoop
	Wend
	
	If Not IsFullScreenWindow() Then
		SetLog("Profile window doesnt exist, exiting...", $COLOR_ERROR)
		ClickAway()
		Return
	EndIf
	
	If $iCount = 15 Then
		SetLog("Cannot verify if Profile window exist, exiting...", $COLOR_ERROR)
		ClickAway()
		Return
	EndIf
	
	If _Sleep(1000) Then Return
	$iAttacksWon = ""

	If _ColorCheck(_GetPixelColor($aProfileReport[0], $aProfileReport[1], True), Hex($aProfileReport[2], 6), $aProfileReport[3]) Then
		SetDebugLog("Profile seems to be currently unranked", $COLOR_DEBUG)
		$iAttacksWon = 0
		$iDefensesWon = 0
	Else
		$iAttacksWon = getProfile(562, 377)
		SetDebugLog("$iAttacksWon: " & $iAttacksWon, $COLOR_DEBUG)
		$iCount = 0
		While $iAttacksWon = "" ; Wait for $attacksWon to be readable in case of slow PC
			If _Sleep($DELAYPROFILEREPORT1) Then Return
			$iAttacksWon = getProfile(562, 377)
			SetDebugLog("Read Loop $iAttacksWon: " & $iAttacksWon & ", Count: " & $iCount, $COLOR_DEBUG)
			$iCount += 1
			If $iCount >= 20 Then ExitLoop
		WEnd
		If $g_bDebugSetlog And $iCount >= 20 Then SetLog("Excess wait time for reading $AttacksWon: " & getProfile(564, 403), $COLOR_DEBUG)
		$iDefensesWon = getProfile(795, 377)
	EndIf
	$g_iTroopsDonated = getProfile(155, 377)
	$g_iTroopsReceived = getProfile(358, 377)

	SetLog(" [ATKW]: " & _NumberFormat($iAttacksWon) & " [DEFW]: " & _NumberFormat($iDefensesWon) & " [TDON]: " & _NumberFormat($g_iTroopsDonated) & " [TREC]: " & _NumberFormat($g_iTroopsReceived), $COLOR_SUCCESS)
	
	$iCount = 0
	While IsFullScreenWindow()
		$iCount += 1
		Click(825, 45, 1, 0, "#0223") ; Close Profile page
		_Sleep(1000)
		If IsMainPage() Then ExitLoop
		If $iCount > 5 Then ExitLoop
	Wend

EndFunc   ;==>ProfileReport
