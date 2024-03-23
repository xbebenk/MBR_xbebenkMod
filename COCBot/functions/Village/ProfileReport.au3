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

	Local $iAttacksWon = 0, $iDefensesWon = 0, $bProfileWinOpen = False

	Local $iCount = 0
	ClickAway()
	If _Sleep($DELAYPROFILEREPORT1) Then Return

	SetLog("Profile Report", $COLOR_INFO)
	SetLog("Opening Profile page to read Attacks, Defenses, Donations and Recieved Troops", $COLOR_INFO)
	Click(49, 30, 1, 0, "#0222") ; Click Info Profile Button
	If _Sleep($DELAYPROFILEREPORT2) Then Return

	For $i = 1 To 12 ; wait for Info Profile to open
		If $g_bDebugSetlog Then SetLog("[" & $iCount & "] Waiting Profile window open", $COLOR_ACTION)
		If _Sleep(250) Then Return
		If IsProfileWindowOpen() Then 
			$bProfileWinOpen = True
			ExitLoop
		EndIf
	Next
	
	If Not $bProfileWinOpen Then 
		SetLog("Profile window doesnt exist, exiting...", $COLOR_ERROR)
		ClickAway()
		Return
	EndIf
	
	Click(180, 100) ;click Profile Tab (in case opening profile page on social tab) so just do it
	If _Sleep(1000) Then Return
	
	$iAttacksWon = ""
	Local $aProfileReport[4] = [590, 458, 0x4E4D79, 10] ; Dark Purple of Profile Page when no Attacks were made

	If _ColorCheck(_GetPixelColor($aProfileReport[0], $aProfileReport[1], True), Hex($aProfileReport[2], 6), $aProfileReport[3]) Then
		SetDebugLog("Profile seems to be currently unranked", $COLOR_DEBUG)
		$iAttacksWon = 0
		$iDefensesWon = 0
	Else
		$iAttacksWon = getProfile(548, 453)
		SetDebugLog("$iAttacksWon: " & $iAttacksWon, $COLOR_DEBUG)
		$iCount = 0
		While $iAttacksWon = "" ; Wait for $attacksWon to be readable in case of slow PC
			If _Sleep($DELAYPROFILEREPORT1) Then Return
			$iAttacksWon = getProfile(548, 453)
			SetDebugLog("Read Loop $iAttacksWon: " & $iAttacksWon & ", Count: " & $iCount, $COLOR_DEBUG)
			$iCount += 1
			If $iCount >= 20 Then ExitLoop
		WEnd
		If $g_bDebugSetlog And $iCount >= 20 Then SetLog("Excess wait time for reading $AttacksWon: " & getProfile(548, 453), $COLOR_DEBUG)
		$iDefensesWon = getProfile(762, 453)
	EndIf
	$g_iTroopsDonated = getProfile(180, 453)
	$g_iTroopsReceived = getProfile(366, 453)

	SetLog(" [ATKW]: " & _NumberFormat($iAttacksWon) & " [DEFW]: " & _NumberFormat($iDefensesWon) & " [TDON]: " & _NumberFormat($g_iTroopsDonated) & " [TREC]: " & _NumberFormat($g_iTroopsReceived), $COLOR_SUCCESS)
	
	$iCount = 0
	While IsProfileWindowOpen()
		$iCount += 1
		Click(805, 100) ; Close Profile page
		If _Sleep(1000) Then Return
		If IsMainPage() Then ExitLoop
		If $iCount > 5 Then ExitLoop
	Wend

EndFunc   ;==>ProfileReport
