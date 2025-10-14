; #FUNCTION# ====================================================================================================================
; Name ..........: MBR Bot
; Description ...: Uses the ColorCheck until the screen is clear from Clouds to Get Resources values.
; Author ........: HungLe (2015)
; Modified ......: ProMac (2015), Hervidero (2015), MonkeyHunter (08-2016)(05-2017), xbebenk(03-2024)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func GetResources($bLog = True) ;Reads resources
	Static $iStuck = 0, $iSearchGold2 = 0, $iSearchElixir2 = 0
	Local $xRead = 48, $yGold = 0, $yElix = 0, $yDE = 0, $yTrophy = 0
	$g_iSearchGold = ""
	$g_iSearchElixir = ""
	$g_iSearchDark = ""
	$g_iSearchTrophy = ""
	
	If _Sleep($DELAYRESPOND) Then Return
	SuspendAndroid()
	
	Local $aResource = QuickMIS("CNX", $g_sImgResourceAttack, 20, 70, 50, 185)
	If UBound($aResource) < 3 Then 
		If _Sleep(1000) Then Return
		$aResource = QuickMIS("CNX", $g_sImgResourceAttack, 20, 70, 50, 185)		
	EndIf
	
	If IsArray($aResource) And UBound($aResource) > 0 Then
		_ArraySort($aResource, 0, 0, 0, 2)
		SetDebugLog("Found Resource Image count : " & UBound($aResource))
		For $i = 0 To UBound($aResource) - 1
			Switch $aResource[$i][0]
				Case "Gold"
					$yGold = $aResource[$i][2] - 3
					SetDebugLog("[" & $i & "] Found Gold Image")
				Case "Elix"
					$yElix = $aResource[$i][2] - 3
					SetDebugLog("[" & $i & "] Found Elix Image")
				Case "DE"
					$yDE = $aResource[$i][2] - 3
					SetDebugLog("[" & $i & "] Found DE Image")
				Case "Trophy"
					$yTrophy = $aResource[$i][2]
					SetDebugLog("[" & $i & "] Found Trophy Image")
			EndSwitch
		Next
	Else
		SaveDebugImage("GetResources")
		$yGold = 76
		$yElix = 103
		$yDE = 132
		SetDebugLog("GetResources got problem reading Icon")
	EndIf
	
	$g_iSearchGold = getGoldVillageSearch($xRead, $yGold)
	SetDebugLog("getGoldVillageSearch(" & $xRead & "," & $yGold & ")")
	$g_iSearchElixir = getElixirVillageSearch($xRead, $yElix)
	SetDebugLog("getElixirVillageSearch(" & $xRead & "," & $yElix & ")")
	$g_iSearchDark = getDarkElixirVillageSearch($xRead, $yDE)
	SetDebugLog("getDarkElixirVillageSearch(" & $xRead & "," & $yDE & ")")
	$g_iSearchTrophy = getTrophyVillageSearch($xRead, $yTrophy)
	SetDebugLog("getTrophyVillageSearch(" & $xRead & "," & $yTrophy & ")")
	
	SetDebugLog("Gold: " & $g_iSearchGold & ", Elix: " & $g_iSearchElixir & ", DE: " & $g_iSearchDark & ", TR: " & $g_iSearchTrophy)

	If $g_iSearchGold = $iSearchGold2 And $g_iSearchElixir = $iSearchElixir2 Then $iStuck += 1
	If $g_iSearchGold <> $iSearchGold2 Or $g_iSearchElixir <> $iSearchElixir2 Then $iStuck = 0

	$iSearchGold2 = $g_iSearchGold
	$iSearchElixir2 = $g_iSearchElixir

	If $iStuck >= 5 Or IsProblemAffect() Then
		$iStuck = 0
		resetAttackSearch(True)
		Return
	EndIf

	$g_iSearchCount += 1 ; Counter for number of searches

	ResumeAndroid()

EndFunc   ;==>GetResources

Func resetAttackSearch($bStuck = False)
	; function to check main screen and restart search and display why as needed
	$g_bIsClientSyncError = True
	checkMainScreen(True, $g_bStayOnBuilderBase, "resetAttackSearch")
	If $g_bRestart Then
		$g_iNbrOfOoS += 1
		UpdateStats()
		If $bStuck Then
			SetLog("Connection Lost While Searching", $COLOR_ERROR)
		Else
			SetLog("Disconnected At Search Clouds", $COLOR_ERROR)
		EndIf
		PushMsg("OoSResources")
	Else
		If $bStuck Then
			SetLog("Attack Is Disabled Or Slow connection issues, Restarting CoC and Bot...", $COLOR_ERROR)
		Else
			SetLog("Stuck At Search Clouds, Restarting CoC and Bot...", $COLOR_ERROR)
		EndIf
		$g_bIsClientSyncError = False ; disable fast OOS restart if not simple error and restarting CoC
		CloseCoC(True)
	EndIf
	Return
EndFunc   ;==>resetAttackSearch
