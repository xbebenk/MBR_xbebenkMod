; #FUNCTION# ====================================================================================================================
; Name ..........: Collect
; Description ...:
; Syntax ........: CollectBuilderBase()
; Parameters ....:
; Return values .: None
; Author ........: Fliegerfaust (05-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func CollectBuilderBase($bSwitchToBB = False, $bSwitchToNV = False)

	If Not $g_bChkCollectBuilderBase Then Return
	If Not $g_bRunState Then Return

	If $bSwitchToBB Then
		ClickAway()
		If Not SwitchBetweenBases("BB") Then Return ; Switching to Builders Base
	EndIf

	SetLog("Collecting Resources on Builders Base", $COLOR_INFO)
	If _Sleep($DELAYCOLLECT2) Then Return
	
	ZoomOut()
	Local $aResult = QuickMIS("CNX", $g_sImgCollectResourcesBB, 131,120,777, 584)
	If IsArray($aResult) And UBound($aResult) > 0 Then
		For $i = 0 To UBound($aResult) - 1
			If isInsideDiamondXY($aResult[$i][1], $aResult[$i][2]) Then 
				Click($aResult[$i][1], $aResult[$i][2])
				If $g_bDebugSetLog Then SetLog("Found random pick [" & $aResult[$i][1] & "," & $aResult[$i][2] & "]", $COLOR_SUCCESS)
			EndIf
		Next
	Else
		SetLog("No Tombs Found!", $COLOR_DEBUG1)
	EndIf
	
	CollectBBCart()
	If _Sleep($DELAYCOLLECT3) Then Return
	If $bSwitchToNV Then SwitchBetweenBases("Main") ; Switching back to the normal Village
EndFunc

Func CollectBBCart()
	If QuickMIS("BC1", $g_sImgBB20 & "ElixCart\", 540, 80, 630, 150) Then ;check ElixCart Image
		Setlog("Found Elix Cart", $COLOR_DEBUG2)
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(1000) Then Return
		For $i = 1 To 5
			SetLog("Waiting Cart Window #" & $i, $COLOR_ACTION)
			If QuickMIS("BC1", $g_sImgBB20 & "ElixCart\", 636, 515, 730, 560) Then
				Setlog("Collecting Elixir from BuilderBase Cart", $COLOR_ACTION)
				Click($g_iQuickMISX, $g_iQuickMISY)
				ClickAway()
				If _Sleep(1000) Then Return
				ExitLoop
			EndIf
			If _Sleep(1000) Then Return
		Next
	EndIf
EndFunc