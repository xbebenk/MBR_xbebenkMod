; #FUNCTION# ====================================================================================================================
; Name ..........: GetAttackBarBB
; Description ...: Gets the troops and there quantities for the current attack
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Chilly-Chill (04-2019)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func GetAttackBarBB($bRemaining = False)
	Local $iTroopBanners = 584 ; y location of where to find troop quantities
	Local $iSelectTroopY = 620 ; y location to select troop on attackbar
	Local $aBBAttackBar[0][5]
	
	Local $iMaxSlot = 9, $iSlotOffset = 70, $bMachineFound = False
	Local $aSlotX[$iMaxSlot], $iStartSlot = 120
	
	If QuickMIS("BC1", $g_sImgBBBattleMachine, 28, 560, 100, 650) Then
		$bMachineFound = True
		For $i = 0 To UBound($aSlotX) - 1
			$aSlotX[$i] = $iStartSlot + ($i * $iSlotOffset)
		Next
	Else
		$iStartSlot = 40
		For $i = 0 To UBound($aSlotX) - 1
			$aSlotX[$i] = $iStartSlot + ($i * $iSlotOffset)
		Next
	EndIf
	If $g_bDebugSetlog Then SetLog("Machine Found = " & String($bMachineFound) & " SlotX: " & _ArrayToString($aSlotX), $COLOR_DEBUG2)
	
	#comments-start
		$aAttackBar[n][8]
		[n][0] = Name of the found Troop/Spell/Hero/Siege
		[n][1] = The X Coordinate of the Troop
		[n][2] = The Y Coordinate of the Troop/Spell/Hero/Siege
		[n][3] = The Slot Number (Starts with 0)
		[n][4] = The Amount
	#comments-end

	If Not $g_bRunState Then Return ; Stop Button
	
	Local $iCount = 1, $isBlueBanner = False, $isDarkGreyBanner = False, $isGreyBanner = False, $isVioletBanner = False
	Local $aBBAttackBarResult, $Troop = "", $Troopx = 0, $Troopy = 0, $ColorPickBannerX = 0
	Local $bReadTroop = False
	
	For $k = 0 To UBound($aSlotX) - 1
		If Not $g_bRunState Then Return
		
		$Troopx = $aSlotX[$k]
		$ColorPickBannerX = $aSlotX[$k] + 37 ; location to pick color from TroopSlot banner
			
		If $bRemaining Then 
			If $g_bDebugSetlog Then SetLog("Slot [" & $k & "]: isBlueBanner=" & String($isBlueBanner) & " isVioletBanner=" & String($isVioletBanner), $COLOR_DEBUG2)
			If QuickMIS("BC1", $g_sImgDirBBTroops, $Troopx, $iTroopBanners, $Troopx + 73, 670) Then 
				If $g_bDebugSetlog Then SetLog("Slot [" & $k & "]: TroopBanner ColorpickX=" & $ColorPickBannerX, $COLOR_DEBUG2)
				$isDarkGreyBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0x282828, 6), 10, Default, "isDarkGreyBanner") ; DartkGrey Banner on TroopSlot = Troop Already Deployed
				$isGreyBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0x707070, 6), 10, Default, "isGreyBanner") ;Grey Banner on TroopSlot = Troop Die
				If $isDarkGreyBanner Or $isGreyBanner Then ContinueLoop ;skip read troop as they detected deployed or die
				
				$isVioletBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0xC434FC, 6), 30, Default, "isVioletBanner") ; Violet Banner on TroopSlot = TroopSlot Quantity = 1 
				$isBlueBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0x3874FF, 6), 30, Default, "isBlueBanner") ; Blue Banner on TroopSlot = TroopSlot Quantity > 1 
				
				If $isBlueBanner Or $isVioletBanner Then
					$Troop =  $g_iQuickMISName
					$Troopy = $iSelectTroopY
					If $isBlueBanner Then $iCount = Number(getOcrAndCapture("coc-tbb", $ColorPickBannerX, $iTroopBanners - 12, 35, 28, True))
					If $isVioletBanner Then $iCount = 1
					
					Local $aTempElement[1][5] = [[$Troop, $Troopx, $Troopy, $k, $iCount]] ; element to add to attack bar list
					_ArrayAdd($aBBAttackBar, $aTempElement)
				EndIf
			EndIf
		Else
			If $g_bDebugSetlog Then SetLog("Slot [" & $k & "]: isBlueBanner=" & String($isBlueBanner) & " isVioletBanner=" & String($isVioletBanner), $COLOR_DEBUG2)
			If QuickMIS("BC1", $g_sImgDirBBTroops, $Troopx, $iTroopBanners, $Troopx + 73, 670) Then 
				If $g_bDebugSetlog Then SetLog("Slot [" & $k & "]: TroopBanner ColorpickX=" & $ColorPickBannerX, $COLOR_DEBUG2)
				$isVioletBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0xC434FC, 6), 30, Default, "isVioletBanner") ; Violet Banner on TroopSlot = TroopSlot Quantity = 1 
				$isBlueBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0x3874FF, 6), 30, Default, "isBlueBanner") ; Blue Banner on TroopSlot = TroopSlot Quantity > 1 
				
				$bReadTroop = $isBlueBanner Or $isVioletBanner
				If $bReadTroop Then
					$Troop =  $g_iQuickMISName
					$Troopy = $iSelectTroopY
					If $isBlueBanner Then $iCount = Number(getOcrAndCapture("coc-tbb", $ColorPickBannerX, $iTroopBanners - 12, 35, 28, True))
					If $isVioletBanner Then $iCount = 1
					
					Local $aTempElement[1][5] = [[$Troop, $Troopx, $Troopy, $k, $iCount]] ; element to add to attack bar list
					_ArrayAdd($aBBAttackBar, $aTempElement)
				EndIf
			EndIf
		EndIf
	Next
	
	If UBound($aBBAttackBar) = 0 Then Return ""
	
	_ArraySort($aBBAttackBar, 0, 0, 0, 3)
	For $i = 0 To UBound($aBBAttackBar) - 1
		SetLog($aBBAttackBar[$i][0] & ", (" & String($aBBAttackBar[$i][1]) & "," & String($aBBAttackBar[$i][2]) & "), Slot: " & String($aBBAttackBar[$i][3]) & ", Count: " & String($aBBAttackBar[$i][4]), $COLOR_SUCCESS)
	Next
	Return $aBBAttackBar
EndFunc

Global Const $g_asAttackBarBB2[$g_iBBTroopCount + 1] = ["Barbarian", "Archer", "BoxerGiant", "Minion", "WallBreaker", "BabyDrag", "CannonCart", "Witch", "DropShip", "SuperPekka", "HogGlider", "Machine"]
Global Const $g_asBBTroopShortNames[$g_iBBTroopCount + 1] = ["Barb", "Arch", "Giant", "Minion", "Breaker", "BabyD", "Cannon", "Witch", "Drop", "Pekka", "HogG", "Machine"]
Global Const $g_sTroopsBBAtk[$g_iBBTroopCount + 1] = ["Raged Barbarian", "Sneaky Archer", "Boxer Giant", "Beta Minion", "Bomber Breaker", "Baby Dragon", "Cannon Cart", "Night Witch", "Drop Ship", "Super Pekka", "Hog Glider", "Battle Machine"]

Func TestCorrectAttackBarBB()
	Local $aAvailableTroops = GetAttackBarBB()
	CorrectAttackBarBB($aAvailableTroops)
	Return $aAvailableTroops
EndFunc   ;==>TestCorrectAttackBarBB

#comments-start
		$aAttackBar[n][8]
		[n][0] = Name of the found Troop/Spell/Hero/Siege
		[n][1] = The X Coordinate of the Troop
		[n][2] = The Y Coordinate of the Troop/Spell/Hero/Siege
		[n][3] = The Slot Number (Starts with 0)
		[n][4] = The Amount
#comments-end

Func CorrectAttackBarBB(ByRef $aBBAttackBar)
	If Not $g_bRunState Then Return
	;Local $aSlotX[9] = [120, 190, 260, 330, 400, 470, 545, 620, 690] ; location of slot
	
	For $i = 0 To UBound($aBBAttackBar) - 1
		SetLog("Detected Troop [" & $aBBAttackBar[$i][3] & "] : " &  $aBBAttackBar[$i][0], $COLOR_ACTION)
	Next
	
	Local $aTmpAttackBar = $aBBAttackBar
	
	Local $sTroopName = "", $sChangeTo = "", $iSlot = 0, $x = 0
	For $i = 0 To UBound($aTmpAttackBar) - 1
		$iSlot = $aBBAttackBar[$i][3]
		$x = $aBBAttackBar[$i][1]
		$sTroopName = $aTmpAttackBar[$i][0]
		$sChangeTo = $g_asAttackBarBB2[$g_iCmbTroopBB[$i]]
		If $sTroopName = $sChangeTo Then 
			SetLog("Slot[" & $iSlot & "] Troop: " & $sTroopName & " is Correct", $COLOR_INFO)
			ContinueLoop
		Else
			SetLog("Slot[" & $iSlot & "] Troop: " & $sTroopName & ", Change to " & $sChangeTo, $COLOR_ACTION)
			If ChangeBBTroopTo($sTroopName, $x, $sChangeTo) Then 
				$aBBAttackBar[$i][0] = $sChangeTo
				ContinueLoop
			Else
				SetLog("Fail to Change Troop on Slot " & $aBBAttackBar[$i][3], $COLOR_ERROR)
				ContinueLoop
			EndIf
		EndIf
	Next
EndFunc

Func ChangeBBTroopTo($sTroopName, $x, $sChangeTo)
	Local $bRet = False
	
	Local $TmpX = 0, $TmpY = 0
	If QuickMIS("BC1", $g_sImgChangeTroops, $x, 580, $x + 70, 676) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		$TmpX = $g_iQuickMISX
		$TmpY = $g_iQuickMISY
		If _Sleep(800) Then Return
		If QuickMIS("BFI", $g_sImgDirBBTroops & $sChangeTo & "*", 0, 480, 860, 546) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(1000) Then Return
			$bRet = True
		Else
			SetLog("Troop " & $sChangeTo & " not found", $COLOR_ERROR)
			Click($TmpX, $TmpY)
			If _Sleep(1000) Then Return
		EndIf
	Else
		SetLog("Switch Button not found", $COLOR_ERROR)
	EndIf
	Return $bRet
EndFunc
#endRegion - xbebenk