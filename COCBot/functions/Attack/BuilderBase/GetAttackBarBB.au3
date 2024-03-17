; #FUNCTION# ====================================================================================================================
; Name ..........: GetAttackBarBB
; Description ...: Gets the troops and there quantities for the current attack
; Syntax ........:
; Parameters ....: None
; Return values .: array attackBar
; Author ........: xbebenk
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================


#comments-start
	$aAttackBar[n][8]
	[n][0] = Name of the found Troop/Spell/Hero/Siege
	[n][1] = The X Coordinate of the Troop
	[n][2] = The Y Coordinate of the Troop/Spell/Hero/Siege
	[n][3] = The Slot Number (Starts with 0)
	[n][4] = The Amount
#comments-end	
	
Func GetAttackBarBB($bRemaining = False, $bSecondAttack = False)
	Local $iTroopBanners = 582 ; y location of where to find troop quantities
	Local $iTroopAreaY = 600 ; y location of where to find troop quantities
	Local $iSelectTroopY = 620 ; y location to select troop on attackbar
	Local $aBBAttackBar[0][5]
	Local $aEmpty[0][2]
	If Not $bRemaining Then 
		$g_bWBOnAttackBar = False
		$g_aWBOnAttackBar = $aEmpty
	EndIf
	
	Local $iMaxSlot = 9, $iSlotOffset = 75, $bMachineFound = False
	Local $aSlotX[$iMaxSlot], $iStartSlot = 100
	
	If $g_bChkDebugAttackBB Then SetLog("GetAttackBarBB Remaining=" & String($bRemaining) & ", SecondAttack=" & String($bSecondAttack), $COLOR_DEBUG)
	
	If GetMachinePos() = 0 Then
		$iStartSlot = 23
		For $i = 0 To UBound($aSlotX) - 1
			$aSlotX[$i] = $iStartSlot + ($i * $iSlotOffset)
		Next
	Else
		$bMachineFound = True
		For $i = 0 To UBound($aSlotX) - 1
			$aSlotX[$i] = $iStartSlot + ($i * $iSlotOffset)
		Next
	EndIf
	
	If $g_bChkDebugAttackBB Then SetLog("Machine Found = " & String($bMachineFound) & " SlotX: " & _ArrayToString($aSlotX), $COLOR_DEBUG2)
	
	If Not $g_bRunState Then Return ; Stop Button
	
	Local $iCount = 1, $isBlueBanner = False, $isDarkGreyBanner = False, $isGreyBanner = False, $isVioletBanner = False
	Local $aBBAttackBarResult, $Troop = "", $Troopx = 0, $Troopy = 0, $ColorPickBannerX = 0
	Local $bReadTroop = False
	
	For $k = 0 To UBound($aSlotX) - 1
		If Not $g_bRunState Then Return
		
		$Troopx = $aSlotX[$k]
		$ColorPickBannerX = $aSlotX[$k] + 35 ; location to pick color from TroopSlot banner
			
		If $bRemaining Then 
			If QuickMIS("BC1", $g_sImgDirBBTroops, $Troopx, $iTroopAreaY, $Troopx + $iSlotOffset, 670) Then 
				If $g_bDebugSetLog Then SetLog("Slot [" & $k & "]: TroopBanner ColorpickX=" & $ColorPickBannerX, $COLOR_DEBUG2)
				$isDarkGreyBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0x282828, 6), 20, Default, "isDarkGreyBanner") ; DartkGrey Banner on TroopSlot = Troop Already Deployed
				$isGreyBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0x707070, 6), 10, Default, "isGreyBanner") ;Grey Banner on TroopSlot = Troop Die
				If $isDarkGreyBanner Or $isGreyBanner Then ContinueLoop ;skip read troop as they detected deployed or die
				If $g_bDebugSetLog Then SetLog("Slot [" & $k & "]: isBlueBanner=" & String($isBlueBanner) & " isVioletBanner=" & String($isVioletBanner), $COLOR_DEBUG2)
				
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
			If QuickMIS("BC1", $g_sImgDirBBTroops, $Troopx, $iTroopAreaY, $Troopx + $iSlotOffset, 670) Then 
				If $g_bDebugSetLog Then SetLog("Slot [" & $k & "]: TroopBanner ColorpickX=" & $ColorPickBannerX, $COLOR_DEBUG2)
				$isVioletBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0xC434FC, 6), 30, Default, "isVioletBanner") ; Violet Banner on TroopSlot = TroopSlot Quantity = 1 
				$isBlueBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0x3874FF, 6), 30, Default, "isBlueBanner") ; Blue Banner on TroopSlot = TroopSlot Quantity > 1 
				If Not $isVioletBanner And $bSecondAttack Then $isVioletBanner = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iTroopBanners, True), Hex(0x10224B, 6), 30, Default, "isVioletBanner") ; Violet Banner on TroopSlot = TroopSlot Quantity = 1 
				If $g_bDebugSetLog Then SetLog("Slot [" & $k & "]: isBlueBanner=" & String($isBlueBanner) & " isVioletBanner=" & String($isVioletBanner), $COLOR_DEBUG2)
				
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
		SetLog("Slot[" & $aBBAttackBar[$i][3] & "] " & $aBBAttackBar[$i][0] & ", (" & $aBBAttackBar[$i][1] & "," & $aBBAttackBar[$i][2] & "), Count: " & $aBBAttackBar[$i][4], $COLOR_SUCCESS)
		If Not $bRemaining And $aBBAttackBar[$i][0] = "WallBreaker" Then
			$g_bWBOnAttackBar = True
			_ArrayAdd($g_aWBOnAttackBar, $aBBAttackBar[$i][1] & "|" & $aBBAttackBar[$i][2])
		EndIf
	Next
	If $g_bChkDebugAttackBB And UBound($g_aWBOnAttackBar) > 0 Then SetLog("WBOnAttackBar=" & String($g_bWBOnAttackBar) & " : " & _ArrayToString($g_aWBOnAttackBar, ",", Default, Default, "|"), $COLOR_DEBUG2)
	Return $aBBAttackBar
EndFunc

Global Const $g_asAttackBarBB2[$g_iBBTroopCount + 1] = ["Barbarian", "Archer", "BoxerGiant", "Minion", "WallBreaker", "BabyDrag", "CannonCart", "Witch", "DropShip", "SuperPekka", "HogGlider", "ElectroWizard", "Machine"]
Global Const $g_asBBTroopShortNames[$g_iBBTroopCount + 1] = ["Barb", "Arch", "Giant", "Minion", "Breaker", "BabyD", "Cannon", "Witch", "Drop", "Pekka", "HogG", "EWiza", "Machine"]
Global Const $g_sTroopsBBAtk[$g_iBBTroopCount + 1] = ["Raged Barbarian", "Sneaky Archer", "Boxer Giant", "Beta Minion", "Bomber Breaker", "Baby Dragon", "Cannon Cart", "Night Witch", "Drop Ship", "Super Pekka", "Hog Glider", "Electro Wizard", "Battle Machine"]

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

Func CorrectAttackBarBB(ByRef $aBBAttackBar, $bSecondAttack = False)
	If Not $g_bRunState Then Return
	
	For $i = 0 To UBound($aBBAttackBar) - 1
		SetLog("Detected Troop [" & $aBBAttackBar[$i][3] & "] : " &  $aBBAttackBar[$i][0], $COLOR_ACTION)
	Next
	
	Local $aTmpAttackBar = $aBBAttackBar
	
	Local $sTroopName = "", $sChangeTo = "", $iSlot = 0, $x = 0
	For $i = 0 To UBound($aTmpAttackBar) - 1
		$iSlot = $aBBAttackBar[$i][3]
		$x = $aBBAttackBar[$i][1]
		$sTroopName = $aTmpAttackBar[$i][0]
		$sChangeTo = $g_asAttackBarBB2[$g_iCmbTroopBB[$iSlot]]
		If $sTroopName = $sChangeTo Then 
			SetLog("Slot[" & $iSlot & "] Troop: " & $sTroopName & " is Correct", $COLOR_INFO)
			ContinueLoop
		Else
			SetLog("Slot[" & $iSlot & "] Troop: " & $sTroopName & ", Change to " & $sChangeTo, $COLOR_ACTION)
			If ChangeBBTroopTo($sTroopName, $x, $sChangeTo) Then 
				$aBBAttackBar[$i][0] = $sChangeTo
				ContinueLoop
			Else
				SetLog("Slot[" & $iSlot & "] Fail to Change Troop", $COLOR_ERROR)
				ContinueLoop
			EndIf
		EndIf
	Next
EndFunc

Func ChangeBBTroopTo($sTroopName, $x, $sChangeTo)
	Local $bRet = False
	
	Local $TmpX = 0, $TmpY = 0
	If QuickMIS("BC1", $g_sImgChangeTroops, $x, 635, $x + 70, 665) Then
		Click($g_iQuickMISX + 2, $g_iQuickMISY)
		$TmpX = $g_iQuickMISX
		$TmpY = $g_iQuickMISY
		If _Sleep(1000) Then Return
		If QuickMIS("BFI", $g_sImgDirBBTroops & $sChangeTo & "*", 0, 470, 860, 536) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(1000) Then Return
			$bRet = True
		Else
			SetLog("Troop " & $sChangeTo & " not found", $COLOR_ERROR)
			If $g_bChkDebugAttackBB Then SaveDebugImage("ChangeBBTroopTo", False)
			Click($TmpX, $TmpY)
			If _Sleep(1000) Then Return
		EndIf
	Else
		SetLog("Switch Button not found", $COLOR_ERROR)
		If $g_bChkDebugAttackBB Then SaveDebugImage("ChangeBBTroopTo", False)
	EndIf
	Return $bRet
EndFunc
#endRegion - xbebenk