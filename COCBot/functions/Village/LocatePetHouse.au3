; #FUNCTION# ====================================================================================================================
; Name ..........: LocatePetHouse
; Description ...:
; Syntax ........: LocatePetHouse()
; Parameters ....:
; Return values .: None
; Author ........: KnowJack (June 2015)
; Modified ......: Sardo 2015-08 GrumpyHog 2021-04
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func LocatePetHouse($bCollect = True)
	; reset position
	$g_aiPetHousePos[0] = -1
	$g_aiPetHousePos[0] = -1

	If $g_iTownHallLevel < 14 Then
		SetLog("Townhall Lvl " & $g_iTownHallLevel & " has no Pet House, so skip locating.", $COLOR_DEBUG)
		Return
	EndIf

	; auto locate 
	Local $bAutoLocated = autoLocatePetHouse()
	
	SetLog("PetHouse: (" & $g_aiPetHousePos[0] & "," & $g_aiPetHousePos[1] & ")", $COLOR_DEBUG)
	If $bAutoLocated And $g_aiPetHousePos[0] > 0 And $g_aiPetHousePos[1] > 0 Then Return True
EndFunc

Func autoLocatePetHouse()
	Local $bRet = False, $BuildingName = ""
	Local $aPetHouse = QuickMIS("CNX", $g_sImgPetHouse, $g_OuterDiamondLeft, $g_OuterDiamondTop, $g_OuterDiamondRight, $g_OuterDiamondBottom)
	If IsArray($aPetHouse) And Ubound($aPetHouse) > 0 Then 
		RemoveDupCNX($aPetHouse)
		For $i = 0 To UBound($aPetHouse) - 1
			If StringInStr($aPetHouse[$i][0], "PetHouse") Then 
				SetLog("PetHouse Search find : " & _ArrayToString($aPetHouse), $COLOR_DEBUG)
				Click($aPetHouse[$i][1], $aPetHouse[$i][2])
				$BuildingName = BuildingInfo(242, 479)
				If StringInStr($BuildingName[1], "Pet") Then
					$g_aiPetHousePos[0] = $aPetHouse[$i][1]
					$g_aiPetHousePos[1] = $aPetHouse[$i][2]
					$g_iPetHouseLevel = Number($BuildingName[2])
					$bRet = True
					ExitLoop
				EndIf
			EndIf
		Next
	Else
		SetLog("Couldn't find Pet House on main village", $COLOR_ERROR)
		If $g_bDebugImageSave Then SaveDebugImage("PetHouse", True)
		Return $bRet
	EndIf
	Return $bRet
EndFunc

Func _LocatePetHouse()
	Local $stext, $MsgBox, $sErrorText = "" ; Menghapus variabel $iStupid dan $iSilly

	SetLog("Locating Pet House", $COLOR_INFO)

	WinGetAndroidHandle()
	checkMainScreen()

	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, Default, Default, 12, Default, 600)
		$stext = $sErrorText & @CRLF & "Click OK then click on your Pet House" & @CRLF & @CRLF & _
				"Please make sure your village is completely visible." & @CRLF & @CRLF & _
				"Do not click on anything else while locating!" & @CRLF
				
		$MsgBox = _ExtMsgBox(0, "Ok|Cancel", "Locate PetHouse", $stext, 15)
		
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway()
			Local $aPos = FindPos()
			$g_aiPetHousePos[0] = Int($aPos[0])
			$g_aiPetHousePos[1] = Int($aPos[1])
			
			; --- Cek apakah klik berada di luar area ---
			If isInsideDiamond($g_aiPetHousePos) = False Then
				$sErrorText = "Pet House Location Not Valid! Please try again." & @CRLF
				SetLog("Location not valid, try again", $COLOR_ERROR)
				ContinueLoop ; Langsung ulang loop tanpa pesan aneh
			EndIf
		Else
			SetLog("Locate Pet House Cancelled", $COLOR_INFO)
			ClickAway()
			Return
		EndIf
		
		Local $sPetHouseInfo = BuildingInfo(242, 479) ; 860x780
		If $sPetHouseInfo[0] > 1 Or $sPetHouseInfo[0] = "" Then
			
			; --- Cek apakah bangunan yang diklik salah ---
			If StringInStr($sPetHouseInfo[1], "House") = 0 Then
				Local $sLocMsg = ($sPetHouseInfo[0] = "" ? "Nothing" : $sPetHouseInfo[1])
				
				; Set pesan error standar dan minta user coba lagi
				$sErrorText = "That is not the Pet House, it was a " & $sLocMsg & ". Please try again!" & @CRLF
				SetLog("Selected wrong building (" & $sLocMsg & "), try again", $COLOR_ERROR)
				ContinueLoop 
			EndIf
		Else
			SetLog(" Operator Error - Bad Pet House Location: " & "(" & $g_aiPetHousePos[0] & "," & $g_aiPetHousePos[1] & ")", $COLOR_ERROR)
			$g_aiPetHousePos[0] = -1
			$g_aiPetHousePos[1] = -1
			ClickAway()
			Return False
		EndIf
		
		SetLog("Locate Pet House Success: " & "(" & $g_aiPetHousePos[0] & "," & $g_aiPetHousePos[1] & ")", $COLOR_SUCCESS)
		ExitLoop
	WEnd
	ClickAway()
EndFunc   ;==>LocatePetHouse
