#include-once

Func StartClockTowerBoost()

	If Not $g_bChkStartClockTowerBoost Then Return
	If Not $g_bRunState Then Return

	ZoomOutHelperBB() ;go to BH LowerZone

	SetLog("Boosting Clock Tower", $COLOR_INFO)
	If QuickMIS("BC1", $g_sImgStartCTBoost, $g_InnerDiamondLeft, $g_InnerDiamondTop, $g_InnerDiamondRight, $g_InnerDiamondBottom) Then
		Click($g_iQuickMISX, $g_iQuickMISY + 20, 1, 0, "Click Clock Tower")
		If _Sleep(1000) Then Return
		If QuickMIS("BC1", $g_sImgStartCTBoost, 300, 500, 560, 590) Then
			Click($g_iQuickMISX, $g_iQuickMISY + 10, 1, 0, "Click Clock Tower Button")
			If _Sleep(1000) Then Return
			If QuickMIS("BC1", $g_sImgStartCTBoost, 380, 400, 490, 460) Then
				Click($g_iQuickMISX, $g_iQuickMISY + 10, 1, 0, "Click Boost Button")
			EndIf
		EndIf
	Else
		SetLog("Clock Tower boost is not available!")
	EndIf
		
	If _Sleep(1000) Then Return
	If QuickMIS("BC1", $g_sImgStartCTBoost, 300, 500, 560, 590) Then
		Click($g_iQuickMISX, $g_iQuickMISY + 10, 1, 0, "Click Potion Button")
		If QuickMIS("BC1", $g_sImgStartCTBoost, 460, 380, 520, 430) Then
			SetLog("Successfully Boost Builderbase with potion", $COLOR_SUCCESS)
		EndIf
	Else
		SetLog("Boost Builder Base Potion Not Found", $COLOR_DEBUG)
	EndIf

EndFunc   ;==>StartClockTowerBoost
