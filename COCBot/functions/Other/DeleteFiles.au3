; #FUNCTION# ====================================================================================================================
; Name ..........: DeleteFiles
; Description ...: Delete files from a folder
; Syntax ........:
; Parameters ....: Folder with last caracther "\"  |   filter files   |  type of delete:0 delete file, 1: put into recycle bin
; Return values .: None
; Author ........: Sardo (2015-06), MonkeyHunter (05-2017)
; Modified ......:
; Needs..........: include <Date.au3> <File.au3> <FileConstants.au3> <MsgBoxConstants.au3>
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: Deletefiles("C:\Users\administrator\AppData\Local\Temp\", "*.*", 2,1) delete temp file >=2 days from now and put into recycle bin
; ===============================================================================================================================
Func Deletefiles($Folder, $Filter, $daydiff = 120, $type = 0, $Recursion = $FLTAR_NORECUR)
	Local $x
	Local $File = _FileListToArrayRec($Folder, $Filter, $FLTA_FILES, $Recursion) ; list files to an array
	
	If $File = "" Then Return
	If isArray($File) Then
		For $i = 1 To $File[0]
			Local $FileDate = FileGetTime($Folder & $File[$i])
			If IsArray($FileDate) Then
				Local $Date = $FileDate[0] & '/' & $FileDate[1] & '/' & $FileDate[2] & ' ' & $FileDate[3] & ':' & $FileDate[4] & ':' & $FileDate[5]
				Local $sDayDiff = _DateDiff('D', $Date, _NowCalc())
				If Number($sDayDiff) < $daydiff Then ContinueLoop
				SetLog("Daydiff [" & $sDayDiff & "] days", $COLOR_DEBUG)
				SetLog("Deleting file : " & $File[$i], $COLOR_DEBUG)
				FileDelete($Folder & $File[$i])
			Else
				ContinueLoop
			EndIf
		Next
	Else
		Return False
	EndIf
	
	If $Folder = $g_sProfileTempDebugPath Then ; remove empty folders in DEBUG directory
		$File = _FileListToArray($Folder, "*", $FLTA_FOLDERS)
		If IsArray($File) Then
			For $x = 1 To $File[0]
				If DirGetSize($Folder & $File[$x]) = 0 Then DirRemove($Folder & $File[$x])
			Next
		EndIf
	EndIf
	Return True
EndFunc   ;==>Deletefiles




















