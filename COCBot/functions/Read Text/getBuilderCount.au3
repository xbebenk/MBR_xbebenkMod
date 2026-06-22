
Func getBuilderCount($bSuppressLog = False, $bBuilderBase = False)
	Local $bRet = False, $sBuilderInfo, $aGetBuilders
	
	SetDebugLog("getBuilderCount for " & ($bBuilderBase ? "BuilderBase" : "NormalBase"))
	
	If $bBuilderBase Then
		$sBuilderInfo = getBuilders($aBuildersDigitsBuilderBase[0], $aBuildersDigitsBuilderBase[1]) ; get BB builder string with OCR
	Else
		$sBuilderInfo = getBuilders($aBuildersDigits[0], $aBuildersDigits[1]) ; get builder string with OCR
	EndIf
	
	If StringInStr($sBuilderInfo, "#") > 0 Then ; check for valid OCR read
		$aGetBuilders = StringSplit($sBuilderInfo, "#", $STR_NOCOUNT) ; Split into free and total builder strings
		If $bBuilderBase Then
			$g_iFreeBuilderCountBB = Int($aGetBuilders[0]) ; update global values
			$g_iTotalBuilderCountBB = Int($aGetBuilders[1])
		Else
			$g_iFreeBuilderCount = Int($aGetBuilders[0]) ; update global values
			$g_iTotalBuilderCount = Int($aGetBuilders[1])
		EndIf
		$g_iGfxErrorCount = 0
		$bRet = True
	Else
		SetLog("Bad OCR read Free/Total Builders", $COLOR_ERROR) ; OCR returned unusable value?
		$g_iGfxErrorCount += 1
		If $g_iGfxErrorCount > $g_iGfxErrorMax Then 
			SetLog("gfxError occured, set to Reboot Android Instance", $COLOR_INFO)
			$g_bGfxError = True
			CheckAndroidReboot()
		EndIf
	EndIf
	
	If $bRet Then
		If $bBuilderBase Then SetDebugLog("No. of Free/Total Builders: " & $g_iFreeBuilderCountBB & "/" & $g_iTotalBuilderCountBB)
		If Not $bBuilderBase Then SetDebugLog("No. of Free/Total Builders: " & $g_iFreeBuilderCount & "/" & $g_iTotalBuilderCount)
	EndIf
	
	Return $bRet
EndFunc   ;==>getBuilderCount
