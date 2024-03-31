; #FUNCTION# ====================================================================================================================
; Name ..........: CheckVersion
; Description ...: Check if we have last version of program
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Sardo (2015-06)
; Modified ......: CodeSlinger69 (2017), xbebenk(03-2024)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func CheckVersion()

	;If Not $g_bCheckVersion Then Return
	Local $sModVersion = "", $sUrlFetchMod = "", $aResult, $sCurrentVersion = ""
	
	$aResult = StringRegExp($g_sXModversion, '\[#(\d+)\]', $STR_REGEXPARRAYMATCH)
	If IsArray($aResult) And Ubound($aResult) > 0 Then $sCurrentVersion = $aResult[0]
	
	$sUrlFetchMod = BinaryToString(InetRead("https://raw.githubusercontent.com/xbebenk/MBR_xbebenkMod/dev_1.2.5/MyBot.run.version.au3"))
	Local $aTmp = StringSplit($sUrlFetchMod, @CRLF, $STR_NOCOUNT)
	;_ArrayDisplay($aTmp)
	For $i = 0 To UBound($aTmp) - 1
		If StringInStr($aTmp[$i], "sXModversion") Then
			$aResult = StringRegExp($aTmp[$i], '\[#(\d+)\]', $STR_REGEXPARRAYMATCH)
			If IsArray($aResult) And Ubound($aResult) > 0 Then $sModVersion = $aResult[0]
		EndIf
	Next
	
	If Number($sModVersion) > Number($sCurrentVersion) Then 
		SetLogCentered(" WARNING ", "#", $COLOR_ACTION)
		SetLog("YOUR MOD VERSION (#" & $sCurrentVersion & ") IS OUT OF DATE.", $COLOR_ERROR)
		SetLog("PLEASE UPDATE TO LATEST MOD VERSION (#" & $sModVersion & ")", $COLOR_ERROR)
		SetLog($g_sXModSupportUrl, $COLOR_INFO)
		SetLogCentered("#", "~", $COLOR_ACTION)
		PushMsg("Update")
	EndIf
	
	If Number($sModVersion) = Number($sCurrentVersion) Then 
		SetLogCentered(" OK ", "#", $COLOR_SUCCESS)
		SetLog("YOUR MOD VERSION (#" & $sCurrentVersion & ") IS LATEST VERSION.", $COLOR_SUCCESS)
		SetLog($g_sXModSupportUrl, $COLOR_INFO)
		SetLogCentered("#", "#", $COLOR_SUCCESS)
	EndIf	
	
	$sUrlFetchMod = BinaryToString(InetRead("https://raw.githubusercontent.com/xbebenk/MBR_xbebenkMod/dev_1.2.5/CHANGELOG"))
	Local $aTmp = StringSplit($sUrlFetchMod, @CRLF, $STR_NOCOUNT)
	Local $iCount = 0, $bHeader = False
	For $i = 0 To UBound($aTmp) - 1
		If StringLeft($aTmp[$i], 1) = "*" Then
			$bHeader = StringLeft($aTmp[$i], 4) = "* **"
			SetLog($aTmp[$i], ($bHeader ? $COLOR_INFO : $COLOR_SUCCESS))
		Else
			SetLog(" ")
			$iCount += 1
			If $iCount = 3 Then ExitLoop
		EndIf
	Next
	
EndFunc   ;==>CheckVersion

Func GetLastVersion($txt)
	Return _StringBetween($txt, '"tag_name":"', '","')
EndFunc   ;==>GetLastVersion

Func GetLastChangeLog($txt)
	Local $sChangeLog = _StringBetween($txt, '"body":"', '"}')
	If @error Then $sChangeLog = _StringBetween($txt, '"body":"', '","')
	Return $sChangeLog
EndFunc   ;==>GetLastChangeLog

Func GetVersionNormalized($VersionString, $Chars = 5)
	If StringLeft($VersionString, 1) = "v" Then $VersionString = StringMid($VersionString, 2)
	Local $a = StringSplit($VersionString, ".", 2)
	Local $i
	For $i = 0 To UBound($a) - 1
		If StringLen($a[$i]) < $Chars Then $a[$i] = _StringRepeat("0", $Chars - StringLen($a[$i])) & $a[$i]
	Next
	Return _ArrayToString($a, ".")
EndFunc   ;==>GetVersionNormalized
