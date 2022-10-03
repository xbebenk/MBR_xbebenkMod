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
	If Not TestCapture() Then
		If Not $g_bChkTombstones Then Return False
		If Not $g_abNotNeedAllTime[1] Then Return
	EndIf
	; Timer
	Local $hTimer = __TimerInit()

	; Setup arrays, including default return values for $return
	Local $return[7] = ["None", "None", 0, 0, 0, "", ""]
	Local $TombsXY[2] = [0, 0]

	; Perform a parallel search with all images inside the directory
	Local $aResult = returnSingleMatchOwnVillage($g_sImgClearTombs)

	If UBound($aResult) > 1 Then
		; Now loop through the array to modify values, select the highest entry to return
		For $i = 1 To UBound($aResult) - 1
			; Check to see if its a higher level then currently stored
			If Number($aResult[$i][2]) > Number($return[2]) Then
				; Store the data because its higher
				$return[0] = $aResult[$i][0] ; Filename
				$return[1] = $aResult[$i][1] ; Type
				$return[4] = $aResult[$i][4] ; Total Objects
				$return[5] = $aResult[$i][5] ; Coords
			EndIf
		Next
		$TombsXY = $return[5]

		SetDebugLog("Filename :" & $return[0])
		SetDebugLog("Type :" & $return[1])
		SetDebugLog("Total Objects :" & $return[4])

		Local $bRemoved = False
		If IsArray($TombsXY) Then
			; Loop through all found points for the item and click them to clear them, there should only be one
			For $j = 0 To UBound($TombsXY) - 1
				If isSafeCleanYardXY($TombsXY[$j][0], $TombsXY[$j][1]) Then
					SetDebugLog("Coords :" & $TombsXY[$j][0] & "," & $TombsXY[$j][1])
					If IsMainPage() Then
						Click($TombsXY[$j][0], $TombsXY[$j][1], 1, 0, "#0430")
						If Not $bRemoved Then $bRemoved = IsMainPage()
					EndIf
				EndIf
			Next
		EndIf
		If $bRemoved Then
			SetLog("Tombs removed!", $COLOR_DEBUG1)
			$g_abNotNeedAllTime[1] = False
		Else
			SetLog("Tombs not removed, please do manually!", $COLOR_WARNING)
		EndIf
	Else
		SetLog("No Tombs Found!", $COLOR_SUCCESS)
		$g_abNotNeedAllTime[1] = False
	EndIf
EndFunc   ;==>CheckTombs

Func CleanYardCheckBuilder($bTest = False)
	Local $bRet = False
	getBuilderCount(True) ;check if we have available builder
	If $bTest Then $g_iFreeBuilderCount = 1
	If $g_iFreeBuilderCount > 0 Then 
		$bRet = True
	Else
		SetDebugLog("No More Builders available")
	EndIf
	SetDebugLog("Free Builder : " & $g_iFreeBuilderCount, $COLOR_DEBUG)
	Return $bRet
EndFunc

Func CleanYard($bTest = False)
	If Not $g_bChkCleanYard And Not $g_bChkGemsBox Then Return
	checkMainScreen(True, $g_bStayOnBuilderBase, "CleanYard")
	VillageReport(True, True)
	If Not CleanYardCheckBuilder($bTest) Then Return
	SetLog("CleanYard: Try removing obstacles", $COLOR_DEBUG)
	If Not $g_bSkipSnowDetection Then CheckImageType()

	If $g_aiCurrentLoot[$eLootElixir] < 30000 Then 
		SetLog("Elixir < 30000, try again later", $COLOR_DEBUG)
		Return
	EndIf
	
	If RemoveGembox() Then _SleepStatus(35000) ;Remove gembox first, and wait till gembox removed
	
	; Setup arrays, including default return values for $return
	Local $Filename = ""
	Local $x, $y, $Locate = 0
	
	If $g_iFreeBuilderCount > 0 And $g_bChkCleanYard Then
		Local $aResult = QuickMIS("CNX", $g_iDetectedImageType = 1 ? $g_sImgCleanYardSnow  : $g_sImgCleanYard, 20,20,840,630)
		If IsArray($aResult) And UBound($aResult) > 0 Then
			For $i = 0 To UBound($aResult) - 1
				$Filename = $aResult[$i][0]
				$x = $aResult[$i][1]
				$y = $aResult[$i][2]
				If Not $g_bRunState Then Return
				If Not isSafeCleanYardXY($x, $y) Then ContinueLoop
				SetLog($Filename & " found [" & $x & "," & $y & "]", $COLOR_SUCCESS)
				Click($x, $y, 1, 0, "#0430") ;click CleanYard
				_Sleep(1000)
				If Not ClickRemoveObstacle($bTest) Then ContinueLoop
				CleanYardCheckBuilder($bTest)
				If $g_iFreeBuilderCount = 0 Then _SleepStatus(12000)
				ClickAway()
				$Locate += 1
			Next
		EndIf
	EndIf
	
	If $Locate = 0 Then 
		SetLog("No Obstacles found, Yard is clean!", $COLOR_SUCCESS)
	Else
		SetLog("CleanYard Found and Clearing " & $Locate & " Obstacles!", $COLOR_SUCCESS)
	EndIf
	UpdateStats()
	ClickAway()
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
	
	If QuickMIS("BC1", $g_sImgGemBox, 70,70,830,620) Then
		If Not isSafeCleanYardXY($g_iQuickMISX, $g_iQuickMISY) Then 
			SetLog("Cannot Remove GemBox!", $COLOR_INFO)
			Return False
		EndIf
		Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "#0430")
		_Sleep(1000)
		ClickRemoveObstacle()
		ClickAway()
		SetLog("GemBox removed!", $COLOR_SUCCESS)
		Return True
	Else
		SetLog("No GemBox Found!", $COLOR_DEBUG)
	EndIf
	Return False
EndFunc