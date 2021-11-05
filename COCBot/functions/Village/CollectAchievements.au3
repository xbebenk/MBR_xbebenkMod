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
	If Not $g_bChkCollectAchievements Then Return
	
	ClickAway()
	If Not IsMainPage() Then Return

	SetLog("Begin collecting achievement rewards", $COLOR_INFO)
	If _Sleep($DELAYCOLLECT2) Then Return
	Local $Collecting = True, $RewardCollected = False
	While $Collecting
		If Not $g_bRunState Then Return
		;Check if possible rewards available from main screen
		Local $aImgAchievementsMainScreen = decodeSingleCoord(findImage("AchievementsMainScreen", $g_sImgAchievementsMainScreen, GetDiamondFromRect("5, 60, 70, 2"), 1, True))
		If UBound($aImgAchievementsMainScreen) > 1 Then
			SetDebugLog("Achievement counter found on main screen", $COLOR_SUCCESS)
			Click($aImgAchievementsMainScreen[0] - 10, $aImgAchievementsMainScreen[1] + 20)
			If _Sleep(1500) Then Return
		Else
			If $RewardCollected Then
				SetLog("All achievement rewards collected", $COLOR_INFO)
			Else
				SetLog("No achievement rewards to collect", $COLOR_INFO)
				SetDebugLog("Achievement counter not found on main screen", $COLOR_ERROR)
			EndIf
			ExitLoop
		EndIf
		
		;Check if MyProfile window Opened correctly
		Local $aImgAchievementsMyProfile = decodeSingleCoord(findImage("MyProfile", $g_sImgAchievementsMyProfile, GetDiamondFromRect("100, 110, 275, 55"), 1, True))
		If UBound($aImgAchievementsMainScreen) > 1 Then
			SetDebugLog("My Profile window opened successfully", $COLOR_SUCCESS)
			If _Sleep(2500) Then Return
		Else
			SetDebugLog("My Profile window failed to open", $COLOR_ERROR)
			ClickAway()
			ExitLoop
		EndIf

		If Not CollectAchievementsClaimReward() Then
			SetLog("There are no achievement rewards to collect", $COLOR_INFO)
			Click(700,80) ;Friend Request Tab
			If _Sleep(1000) Then Return
			ExitLoop
		Else
			$RewardCollected = True
		EndIf
		Click(822,46)
		If _Sleep(1500) Then Return
		If Not IsMainPage() Then ExitLoop
	WEnd
	
	Click(822,46)
	Return
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

