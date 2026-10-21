; #FUNCTION# ====================================================================================================================
; Name ..........: collectAchievements
; Description ...: Collect Achievement rewards
; Syntax ........: collectAchievements()
; Parameters ....:
; Return values .: None
; Author ........: Nytol (2020)
; Modified ......: xbebenk (09-2021)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $g_iCollectAchievementsLoopCount = 0
Global $g_iCollectAchievementsRunOn = 0
Global $g_iFoundScrollEnd = 0

Func CollectAchievements($bTestMode = False) ;Run with True parameter if testing to run regardless of checkbox setting, randomization skips and runstate check
	Local $RewardCollected = False
	If Not $g_bChkCollectAchievements Then Return
	CheckMainScreen()
	
	SetLog("Checking achievement rewards", $COLOR_INFO)
	
	If Not OpenProfilePage() Then Return
	If CollectAchievementsClaimReward() Then 
		$RewardCollected = True
	Else 
		SetLog("There are no achievement rewards to collect", $COLOR_DEBUG2)
		Click(585, 100, 1, 0, "Click Inbox Tab") ; Inbox Tab
		If _Sleep(1000) Then Return
	EndIf
	
	If IsSettingPage(True, 1) Then
		Click(775, 120, 1, 0, "Click Close Page")
	EndIf
	
	If $RewardCollected Then SetLog("Achievement Collected", $COLOR_SUCCESS)
	
	Return $RewardCollected
EndFunc   ;==>CollectAchievements

Func CollectAchievementsClaimReward()
	;Check Profile for Achievements and collect
	If Not $g_bRunState Then Return

	Local $sSearchArea = GetDiamondFromRect("660, 160, 845, 675")
	Local $aClaimButtons = findMultiple($g_sImgAchievementsClaimReward, $sSearchArea, $sSearchArea, 0, 1000, 0, "objectname,objectpoints", True)
	If IsArray($aClaimButtons) And UBound($aClaimButtons) > 0 Then
		For $i = 0 To UBound($aClaimButtons) - 1
			Local $aTemp = $aClaimButtons[$i]
			Local $aClaimButtonXY = decodeMultipleCoords($aTemp[1])
			For $i = 0 To UBound($aClaimButtonXY) - 1
				Local $aTemp = $aClaimButtonXY[$i]
				Click($aTemp[0], $aTemp[1])
				SetLog("Achievement reward collected", $COLOR_SUCCESS)
				If _Sleep(1500) Then Return
			Next
		Next
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CollectAchievementsClaimReward

Func OpenProfilePage($bVerifyCounter = True)
	Local $bRet = False
		
	If _Sleep(1000) Then Return
	If _ColorCheck(_GetPixelColor(26, 17, True), Hex(0x20DBFF, 6), 30, Default, "Blue Asterisk on Profile") Then 
		If $bVerifyCounter Then 
			If _ColorCheck(_GetPixelColor(85, 27, True), Hex(0xF42946, 6), 20, Default, "Red Icon Achievement counter") Then 
				Click(50, 50, 1, 0, "Click Profile")
			Else
				Return False
			EndIf
		Else
			Click(50, 50, 1, 0, "Click Profile")
		EndIf
	EndIf
		
	For $i = 1 To 5 
		If _Sleep(1000) Then Return
		If IsSettingPage(True, 1) Then 
			SetDebugLog("[" & $i & "] Verify Profile page")
			If _ColorCheck(_GetPixelColor(75, 140, True), Hex(0xE7E8E1, 6), 20, Default, "Profile Tab Active") Then
				$bRet = True
				ExitLoop
			EndIf
			If _ColorCheck(_GetPixelColor(75, 140, True), Hex(0x797165, 6), 20, Default, "Profile Tab Inactive") Then 
				Click(125, 130, 1, 0, "Click Profile Tab")
				If _Sleep(1000) Then Return
				ContinueLoop
			EndIf
		Else
			SetLog("[" & $i & "] Cannot verify Setting page!", $COLOR_DEBUG2)
		EndIf
	Next
	Return $bRet
EndFunc
