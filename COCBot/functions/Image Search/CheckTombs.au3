; #FUNCTION# ====================================================================================================================
; Name ..........: CheckTombs.au3
; Description ...: This file Includes function to perform defense farming.
; Syntax ........:
; Parameters ....: None
; Return values .: False if regular farming is needed to refill storage
; Author ........: barracoda/KnowJack (2015)
; Modified ......: sardo (05-2015/06-2015) , ProMac (04-2016), MonkeyHuner (06-2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func CheckTombs()
	If Not $g_bRunState Then Return
	SetLog("Checking Tombs", $COLOR_ACTION)
	Collect(True)
	If _Sleep(1000) Then Return
	
	Local $aTombs = QuickMIS("CNX", $g_sImgClearTombs, $InnerDiamondLeft, $InnerDiamondTop, $InnerDiamondRight, $InnerDiamondBottom)
	If IsArray($aTombs) And UBound($aTombs) > 0 Then
		For $i = 0 To UBound($aTombs) - 1
			If isInsideDiamondXY($aTombs[$i][1], $aTombs[$i][2]) Then 
				Click($aTombs[$i][1], $aTombs[$i][2])
				SetLog("Tombs removed! [" & $aTombs[$i][1] & "," & $aTombs[$i][2] & "]", $COLOR_SUCCESS)
				ExitLoop
			EndIf
		Next
	Else
		SetLog("No Tombs Found!", $COLOR_DEBUG1)
	EndIf
EndFunc   ;==>CheckTombs

Func CleanYardCheckBuilder($bTest = False)
	Local $bRet = False
	getBuilderCount(True) ;check if we have available builder
	If $bTest Then $g_iFreeBuilderCount = 1
	If $g_iFreeBuilderCount > 0 Then 
		$bRet = True
		If $g_iFreeBuilderCount = 1 Then 
			If _ColorCheck(_GetPixelColor(413, 43, True), Hex(0xFFAD62, 6), 20, Default, "CleanYardCheckBuilder") Then 
				SetLog("CleanYardCheckBuilder, Free Builder = 1, Goblin Builder!, Return False", $COLOR_DEBUG1)
				$bRet = False
			EndIf
		EndIf
	Else
		SetDebugLog("No More Builders available")
	EndIf
	SetDebugLog("Free Builder : " & $g_iFreeBuilderCount, $COLOR_DEBUG)
	Return $bRet
EndFunc

Func CleanYard($bTest = False)
	Local $bRet = False
	If Not $g_bChkCleanYard And Not $g_bChkGemsBox Then Return
	VillageReport(True, True)
	ZoomOut()
	SetLog("CleanYard: Try removing obstacles", $COLOR_DEBUG)
	checkMainScreen(True, $g_bStayOnBuilderBase, "CleanYard")
	
	If $g_aiCurrentLoot[$eLootElixir] < 30000 Then 
		SetLog("Elixir < 30000, try again later", $COLOR_DEBUG)
		Return
	EndIf
	
	RemoveGembox()
	
	; Setup arrays, including default return values for $return
	Local $Filename = ""
	Local $x, $y, $Locate = 0
	
	If $g_bChkCleanYard Then
		Local $aResult = QuickMIS("CNX", $g_sImgCleanYard, $OuterDiamondLeft, $OuterDiamondTop, $OuterDiamondRight, $OuterDiamondBottom)
		If IsArray($aResult) And UBound($aResult) > 0 Then
			For $i = 0 To UBound($aResult) - 1
				$Filename = $aResult[$i][0]
				$x = $aResult[$i][1]
				$y = $aResult[$i][2]
				If Not $g_bRunState Then Return
				If Not isInsideDiamondXY($x, $y, True) Then ContinueLoop
				SetLog($Filename & " found [" & $x & "," & $y & "]", $COLOR_SUCCESS)
				Click($x, $y, 1, 0, "CleanYard") ;click CleanYard
				If _Sleep(1000) Then Return
				If Not ClickRemoveObstacle($bTest) Then ExitLoop
				ClickAway()
				$Locate += 1
			Next
		EndIf
	EndIf
	
	If $Locate = 0 Then 
		SetLog("No Obstacles found, Yard is clean!", $COLOR_SUCCESS)
	Else
		$bRet = True
		SetLog("CleanYard Found and Clearing " & $Locate & " Obstacles!", $COLOR_SUCCESS)
	EndIf
	UpdateStats()
	ClickAway()
	
	Return $bRet
EndFunc   ;==>CleanYard

Func ClickRemoveObstacle($bTest = False, $BuilderBase = False)
	If Not $bTest Then 
		If ClickB("RemoveObstacle") Then 
			If _Sleep(1000) Then Return
			If IsGemOpen(True) Then
				Return False
			Else
				Return True
			EndIf
		Else
			If $BuilderBase Then
				ClickAway("Left")
			Else
				ClickAway()
			EndIf
		EndIf
	Else
		SetLog("Only for Testing", $COLOR_ERROR)
	EndIf
	Return False
EndFunc

Func RemoveGembox()
	If Not $g_bChkGemsBox Then Return 
	If Not IsMainPage() Then Return
	
	If QuickMIS("BC1", $g_sImgGemBox, $OuterDiamondLeft, $OuterDiamondTop, $OuterDiamondRight, $OuterDiamondBottom) Then
		If Not isInsideDiamondXY($g_iQuickMISX, $g_iQuickMISY, True) Then 
			SetLog("Cannot Remove GemBox!", $COLOR_INFO)
			Return False
		EndIf
		Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Remove GemBox!")
		If _Sleep(1000) Then Return
		ClickRemoveObstacle()
		ClickAway()
		SetLog("Removing GemBox", $COLOR_SUCCESS)
		Return True
	Else
		SetLog("No GemBox Found!", $COLOR_DEBUG)
	EndIf
	Return False
EndFunc