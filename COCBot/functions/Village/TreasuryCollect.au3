; #FUNCTION# ====================================================================================================================
; Name ..........: TreasuryCollect
; Description ...:
; Syntax ........: TreasuryCollect()
; Parameters ....:
; Return values .: None
; Author ........: MonkeyHunter (09-2016)
; Modified ......: Boju (02-2017), Fliegerfaust(11-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func TreasuryCollect()
	SetLog("Begin CollectTreasury:", $COLOR_DEBUG) ; function trace
	If Not $g_bRunState Then Return ; ensure bot is running
	ClickAway()
	checkMainScreen(False)
	
	Local $TryCCAutoLocate = False
	If Int($g_aiClanCastlePos[0]) < 1 Or Int($g_aiClanCastlePos[1]) < 1 Then
		$TryCCAutoLocate = True
	Else
		Click($g_aiClanCastlePos[0], $g_aiClanCastlePos[1])
		If _Sleep(1000) Then Return
		Local $BuildingInfo = BuildingInfo(290, 494)
		If $BuildingInfo[1] = "Clan Castle" Then 
			$TryCCAutoLocate = False
		Else
			$TryCCAutoLocate = True
		EndIf
	EndIf
	
	If $TryCCAutoLocate Then 
		SetLog("Try to Auto Locate Clan Castle", $COLOR_INFO)
		ClickAway()
		Local $TreasuryCoord = decodeSingleCoord(findImage("TreasuryFull", $g_sImgTreasuryFull & "\Treasury*", GetDiamondFromRect("77,70(700,510)"), 1, True))
		If IsArray($TreasuryCoord) And UBound($TreasuryCoord) = 2 Then
			Click($TreasuryCoord[0], $TreasuryCoord[1] + 50)
			If _Sleep(500) Then Return
			Local $BuildingInfo = BuildingInfo(290, 494)
			If $BuildingInfo[1] = "Clan Castle" Then 
				$g_aiClanCastlePos[0] = $TreasuryCoord[0]
				$g_aiClanCastlePos[1] = $TreasuryCoord[1] + 50
				SetLog("Found Treasury Full, save as CC Coords : " & $g_aiClanCastlePos[0] & "," & $g_aiClanCastlePos[1], $COLOR_INFO)
			EndIf
		EndIf
		
		Local $ClanCastleCoord = decodeSingleCoord(findImage("ClanCastle", $g_sImgClanCastle & "\ClanCastle*", GetDiamondFromRect("77,70(700,510)"), 1, True))
		If IsArray($ClanCastleCoord) And UBound($ClanCastleCoord) = 2 Then
			Click($ClanCastleCoord[0] + 10, $ClanCastleCoord[1] + 10)
			If _Sleep(500) Then Return
			Local $BuildingInfo = BuildingInfo(290, 494)
			If $BuildingInfo[1] = "Clan Castle" Then 
				$g_aiClanCastlePos[0] = $ClanCastleCoord[0] + 10
				$g_aiClanCastlePos[1] = $ClanCastleCoord[1] + 10
				SetLog("Found Clan Castle, save as CC Coords : " & $g_aiClanCastlePos[0] & "," & $g_aiClanCastlePos[1], $COLOR_INFO)
			EndIf
		EndIf
	EndIf
	
	If Not ClickB("Treasury") Then SetLog("Treasury Button not found!", $COLOR_ERROR)
	If _Sleep(500) Then Return
	
	If Not _WaitForCheckPixel($aTreasuryWindow, $g_bCapturePixel, Default, "Wait treasury window:") Then
		SetLog("Treasury window not found!", $COLOR_ERROR)
		Return
	EndIf

	Local $bForceCollect = False
	Local $aResult = _PixelSearch(689, 220, 691, 300, Hex(0x50BD10, 6), 20) ; search for green pixels showing treasury bars are full
	If IsArray($aResult) Then
		SetLog("Found full Treasury, collecting loot...", $COLOR_SUCCESS)
		$bForceCollect = True
	Else
		SetLog("Treasury not full yet", $COLOR_INFO)
	EndIf

	; Treasury window open, user msg logged, time to collect loot!
	; check for collect treasury full GUI condition enabled and low resources
	If $bForceCollect Or ($g_bChkTreasuryCollect And ((Number($g_aiCurrentLoot[$eLootGold]) <= $g_iTxtTreasuryGold) Or (Number($g_aiCurrentLoot[$eLootElixir]) <= $g_iTxtTreasuryElixir) Or (Number($g_aiCurrentLoot[$eLootDarkElixir]) <= $g_iTxtTreasuryDark))) Then
		Local $aCollectButton = findButton("Collect", Default, 1, True)
		If IsArray($aCollectButton) And UBound($aCollectButton, 1) = 2 Then
			ClickP($aCollectButton, 1, 0, "#0330")
			If _Sleep($DELAYTREASURY2) Then Return
			If ClickOkay("ConfirmCollectTreasury") Then ; Click Okay to confirm collect treasury loot
				SetLog("Treasury collected successfully.", $COLOR_SUCCESS)
			Else
				SetLog("Cannot Click Okay Button on Treasury Collect screen", $COLOR_ERROR)
			EndIf
		Else
			SetDebugLog("Error in TreasuryCollect(): Cannot find the Collect Button", $COLOR_ERROR)
		EndIf
	Else
		ClickAway()
		If _Sleep($DELAYTREASURY4) Then Return
	EndIf

	ClickAway()
	If _Sleep($DELAYTREASURY4) Then Return
EndFunc   ;==>TreasuryCollect
