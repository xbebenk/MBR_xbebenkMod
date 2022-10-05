; #FUNCTION# ====================================================================================================================
; Name ..........: CheckVersion
; Description ...: Check if we have last version of program
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Sardo (2015-06)
; Modified ......: CodeSlinger69 (2017)
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
	
	$sUrlFetchMod = BinaryToString(InetRead("https://github.com/xbebenk/MBR_xbebenkMod/releases/latest"))
	Local $aTmp = StringSplit($sUrlFetchMod, @CRLF, $STR_NOCOUNT)
	;_ArrayDisplay($aTmp)
	For $i = 0 To UBound($aTmp) - 1
		If StringInStr($aTmp[$i], "<title>") Then
			$aResult = StringRegExp($aTmp[$i], '\[#(\d+)\]', $STR_REGEXPARRAYMATCH)
			If IsArray($aResult) And Ubound($aResult) > 0 Then $sModVersion = $aResult[0]
		EndIf
	Next
	
	; Get the last Version from API
	Local $g_sBotGitVersion = ""
	Local $sCorrectStdOut = InetRead("https://api.github.com/repos/MyBotRun/MyBot/releases/latest")
	If @error Or $sCorrectStdOut = "" Then Return
	Local $Temp = BinaryToString($sCorrectStdOut)

	If $Temp <> "" And Not @error Then
		Local $g_aBotVersionN = StringSplit($g_sBotVersion, " ", 2)
		If @error Then
			Local $g_iBotVersionN = StringReplace($g_sBotVersion, "v", "")
		Else
			Local $g_iBotVersionN = StringReplace($g_aBotVersionN[0], "v", "")
		EndIf
		Local $version = GetLastVersion($Temp)
		$g_sBotGitVersion = StringReplace($version[0], "MBR_v", "")
		SetDebugLog("Last GitHub version is " & $g_sBotGitVersion )
		SetDebugLog("Your version is " & $g_iBotVersionN )

		If _VersionCompare($g_iBotVersionN, $g_sBotGitVersion) = -1 Then
			SetLog("WARNING, YOUR VERSION (" & $g_iBotVersionN & ") IS OUT OF DATE.", $COLOR_INFO)
			Local $ChangelogTXT = GetLastChangeLog($Temp)
			Local $Changelog = StringSplit($ChangelogTXT[0], '\r\n', $STR_ENTIRESPLIT + $STR_NOCOUNT)
			For $i = 0 To UBound($Changelog) - 1
				SetLog($Changelog[$i] )
			Next
			PushMsg("Update")
		ElseIf _VersionCompare($g_iBotVersionN, $g_sBotGitVersion) = 0 Then
			SetLog("YOU HAVE THE LATEST MYBOT VERSION", $COLOR_SUCCESS)
		Else
			SetLog("YOU ARE USING A FUTURE VERSION CHIEF!", $COLOR_ACTION)
		EndIf
		
		If StringRegExp($g_sXModversion, "v.+b", $STR_REGEXPMATCH) Then
			SetLog("##############################################", $COLOR_SUCCESS)
			SetLog("You are using dev Mod version (" & $g_sXModversion & ")", $COLOR_INFO)
			SetLog("Dev version is actively updated", $COLOR_INFO)
			SetLog("Check github for newest commit with fix/new feature", $COLOR_INFO)
			SetLog("##############################################", $COLOR_SUCCESS)
			Return
		EndIf
		
		If Number($sModVersion) > Number($sCurrentVersion) Then 
			SetLog("##############################################", $COLOR_INFO)
			SetLog("WARNING, YOUR MOD VERSION (#" & $sCurrentVersion & ") IS OUT OF DATE.", $COLOR_ERROR)
			SetLog("PLEASE UPDATE TO LATEST MOD VERSION (#" & $sModVersion & ")", $COLOR_ERROR)
			SetLog($g_sXModSupportUrl, $COLOR_INFO)
			SetLog("##############################################", $COLOR_INFO)
		EndIf
		
		If Number($sModVersion) = Number($sCurrentVersion) Then 
			SetLog("##############################################", $COLOR_INFO)
			SetLog("YOUR MOD VERSION (#" & $sCurrentVersion & ") IS LATEST VERSION.", $COLOR_SUCCESS)
			SetLog($g_sXModSupportUrl, $COLOR_INFO)
			SetLog("##############################################", $COLOR_INFO)
		EndIf
	Else
		SetDebugLog($Temp)
	EndIf
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
