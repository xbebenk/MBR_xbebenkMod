#include-once
Func CollectCCGold()
	If Not $g_bChkEnableCollectCCGold Then Return
	SetLog("Start Collecting Clan Capital Gold", $COLOR_INFO)
	ClickAway()
	If QuickMIS("BC1", $g_sImgCCGold, 280, 550, 480, 630) Then
		Click($g_iQuickMISX, $g_iQuickMISY + 20)
		For $i = 1 To 5
			SetDebugLog("Waiting for Forge Window #" & $i, $COLOR_ACTION)
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 710, 150, 760, 190) Then
				ExitLoop
			EndIf
			_Sleep(500)
		Next
		Click(180, 366) ;Click Collect
		_Sleep(500)
		Click($g_iQuickMISX, $g_iQuickMISY) ;Click close button
		SetLog("Clan Capital Gold collected successfully!", $COLOR_SUCCESS)
	Else
		SetLog("No available Clan Capital Gold to be collected!", $COLOR_INFO)
		Return
	EndIf
	If _Sleep($DELAYCOLLECT3) Then Return
EndFunc