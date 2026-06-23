; #FUNCTION# ====================================================================================================================
; Name ..........: imglocTHSearch
; Description ...: Searches for the TH in base, and returns; X&Y location, Bldg Level
; Syntax ........: imglocTHSearch([$bReTest = False])
; Parameters ....: $bReTest - [optional] a boolean value. Default is False.
; Return values .: None , sets several global variables
; Author ........: Trlopes (10-2016)
; Modified ......: CodeSlinger69 (01-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func ResetTHsearch()
	;reset redlines and other globals
	$g_sImglocRedline = "" ; Redline data obtained from FindMultiple
	$g_iImglocTHLevel = 0
	
	;compatibility
	$g_iTHx = 0 ; backwards compatibility
	$g_iTHy = 0 ; backwards compatibility
	$g_iSearchTH = "-" ; means not found
	; empty TH data from dictionary
	Local $string
	Local $iKeys = $g_oBldgAttackInfo.Keys
	For $string In $iKeys
		If StringInStr($string, $eBldgTownHall & "_", $STR_NOCASESENSEBASIC) > 0 Then $g_oBldgAttackInfo.Remove($string)
	Next
	; SetDebugLog("TH search data cleared", $COLOR_DEBUG)

EndFunc   ;==>ResetTHsearch

Func SearchTH($bVerify = True, $bClickAway = True)
	If Not $g_bRunState Then Return
	Local $aTH, $aiTHPos[2], $iTHLevel
	Local $x, $y, $aInfo, $bRet = False
	
	For $try = 1 To 2
		SetLog("[" & $try & "] SearchTH #" & $try, $COLOR_ACTION)
		$aTH = QuickMIS("CNX", $g_sImgTownHall)
		If IsArray($aTH) And UBound($aTH) > 0 Then
			_ArraySort($aTH, 1, 0, 0, 3)
			For $i = 0 To UBound($aTH) - 1
				If Not IsInsideDiamondXY($aTH[$i][1], $aTH[$i][2]) Then ContinueLoop
				SetLog("Found TH Level " & $aTH[$i][3] & " on " & $aTH[$i][1] & "," & $aTH[$i][2], $COLOR_INFO)
				$x = $aTH[$i][1]
				$y = $aTH[$i][2]
				If $bVerify Then
					SetLog("Verify TH Level", $COLOR_ACTION)
					Click($x, $y)
					If _Sleep(500) Then Return
					$aInfo = BuildingInfo(242, 477)
					If $aInfo[1] = "Town Hall" Then
						$iTHLevel =  $aInfo[2]
						$aiTHPos[0] = $x
						$aiTHPos[1] = $y
						$bRet = True
						If $bClickAway Then ClickAway()
						ExitLoop 2
					EndIf
				Else
					$iTHLevel = $aTH[$i][3]
					$aiTHPos[0] = $x
					$aiTHPos[1] = $y
					$bRet = True
					If $bClickAway Then ClickAway()
					ExitLoop 2
				EndIf
				ClickAway()
			Next
		EndIf
		If _Sleep(1500) Then Return
	Next
	
	If $bRet Then
		$g_aiTownHallPos = $aiTHPos
		$g_iTownHallLevel = $iTHLevel
		SetLog("Set THLevel: " & $g_iTownHallLevel & ", THPos [" & $g_aiTownHallPos[0] & "," & $g_aiTownHallPos[1] & "]", $COLOR_DEBUG1)
	EndIf
	
	Return $bRet
EndFunc