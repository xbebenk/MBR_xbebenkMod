; #FUNCTION# ====================================================================================================================
; Name ..........: TrainIt
; Description ...: validates and sends click in barrack window to actually train troops
; Syntax ........: TrainIt($iIndex[, $howMuch = 1[, $iSleep = 400]])
; Parameters ....: $iIndex           - index of troop/spell to train from the Global Enum $eBarb, $eArch, ..., $eHaSpell, $eSkSpell
;                  $howMuch          - [optional] how many to train Default is 1.
;                  $iSleep           - [optional] delay value after click. Default is 400.
; Return values .: None
; Author ........:
; Modified ......: KnowJack(07-2015), MonkeyHunter (05-2016), ProMac (01-2018), CodeSlinger69 (01-2018), xbebenk (2026)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: GetTrainPos, GetFullName, GetGemName
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func TrainIt($iIndex, $iQuantity = 1, $iSleep = 400)
	If $g_bDebugSetlogTrain Then SetLog("Func TrainIt $iIndex=" & $iIndex & " $howMuch=" & $iQuantity & " $iSleep=" & $iSleep, $COLOR_DEBUG)

	If Not $g_bRunState Then Return
	Local $aTrainPos = GetCoordToUse($iIndex)
	If IsArray($aTrainPos) And $aTrainPos[0] > 0 Then
		TrainClickP($aTrainPos, $iQuantity, GetTroopName($iIndex))
		If _Sleep($iSleep) Then Return
		Return True
	Else
		SetLog("Impossible happened? TrainIt troop position " & GetTroopName($iIndex) & " did not return array", $COLOR_DEBUG2)
	EndIf
EndFunc   ;==>TrainIt

Func CorrectYCoord(ByRef $aTrainPos)
	If $aTrainPos[1] > 565 Then $aTrainPos[1] = 630
	If $aTrainPos[1] < 565 Then $aTrainPos[1] = 530
EndFunc

Func GetCoordToUse(Const $iIndex)
	SetDebugLog("GetCoordToUse(" & $iIndex & ")")
	Local $sFilter = "", $sDir = "", $bSiege = False, $aRet[0]
	Select
		Case $iIndex >= $eBarb And $iIndex <= $eIWiza ;Troop
			$sFilter = $g_asTroopShortNames[$iIndex]
			$sDir = $g_sImgTrainTroops
		Case $iIndex >= $eLSpell And $iIndex <= $eOgSpell ;Spell
			$sFilter = $g_asSpellShortNames[$iIndex - $eLSpell]
			$sDir = $g_sImgTrainSpells
		Case $iIndex >= $eWallW And $iIndex <= $eSkyW ;Siege Machine
			$sFilter = $g_asSiegeMachineShortNames[$iIndex - $eWallW]
			$sDir = $g_sImgTrainSieges
			$bSiege = True
	EndSelect
	
	If $sFilter = "" Then 
		SetLog("Don't know coord to use for index : " & $iIndex, $COLOR_DEBUG2)
		Return -1
	Else
		If $g_bDebugSetlogTrain Then SetDebugLog("ImageDir: " & $sDir & "\" & $sFilter & "*")
		If QuickMIS("BFI", $sDir & "\" & $sFilter & "*", 20, 480, 850, 650) Then
			Local $aTmp[2] = [Number($g_iQuickMISX), Number($g_iQuickMISY)]
			_ArrayAdd($aRet, $aTmp)
			If Not $bSiege Then CorrectYCoord($aRet)
			;_ArrayDisplay($aRet)
		Else
			SetLog("Cannot find Image " & $sFilter, $COLOR_DEBUG2)
			Return -1
		EndIf
	EndIf
	Return $aRet
EndFunc   ;==>GetCoordToUse
