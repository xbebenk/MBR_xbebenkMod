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

; 3x3 grid color check (x-2..x+2, y-1..y+1). Single-pixel _ColorCheck misses
; banners during phase-2 screen shake; grid sampling absorbs ±2px drift.
Func _BannerColorCheckGrid($iX, $iY, $sExpected, $iTol, $sLog = Default)
	For $dy = -1 To 1
		For $dx = -2 To 2 Step 2
			If _ColorCheck(_GetPixelColor($iX + $dx, $iY + $dy, True), $sExpected, $iTol, Default, $sLog) Then Return True
		Next
	Next
	Return False
EndFunc

Func GetAttackBarBB($bRemaining = False, $bSecondAttack = False)
	Local $iTroopBanners = 582 ; y location of where to find troop quantities
	Local $iTroopAreaY = 600 ; y location of where to find troop quantities
	Local $iSelectTroopY = 610 ; y location to select troop on attackbar (reference forks use 610; 620 misses the icon)
	Local $aBBAttackBar[0][5]
	Local $aEmpty[0][2]
	If Not $bRemaining Then
		$g_bWBOnAttackBar = False
		$g_aWBOnAttackBar = $aEmpty
	EndIf

	Local $iMaxSlot = 9, $iSlotOffset = 75.5, $bMachineFound = False ; 75.5 matches reference forks; 75 drifts the rightmost slot ~3.5px
	Local $aSlotX[$iMaxSlot], $iStartSlot = 100

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

	Local $iCount = 1, $isBlueBanner = False, $isGreyBanner = False, $isVioletBanner = False
	Local $Troop = "", $Troopx = 0, $Troopy = 0, $ColorPickBannerX = 0
	Local $bReadTroop = False

	For $k = 0 To UBound($aSlotX) - 1
		If Not $g_bRunState Then Return

		$Troopx = $aSlotX[$k]
		$ColorPickBannerX = $aSlotX[$k] + 35 ; location to pick color from TroopSlot banner

		If $bRemaining Then
			Local $bQMIS = QuickMIS("BC1", $g_sImgDirBBTroops, $Troopx, $iTroopBanners, $Troopx + $iSlotOffset, 670)
			Local $sQMISName = $g_sQuickMISName
			Local $iAboveY = $iTroopBanners - 15
			Local $sColAtBannerR = _GetPixelColor($ColorPickBannerX, $iTroopBanners, True)
			Local $sBlueIndColR = _GetPixelColor($ColorPickBannerX, $iTroopBanners + 20, True)
			If $bQMIS Then
				; Skip conditions: deployed/dead/empty slots.
				;   isGreenDeployedBar  y-15 ~ 0x84FF18 (health bar of deployed troop)
				;   isGreyBanner        y    ~ 0x565667 (banner of dead/dimmed troop)
				;   isEmptySlot         y    ~ 0x292929 (uniform dark, no banner)
				Local $isGreenDeployedBar = _ColorCheck(_GetPixelColor($ColorPickBannerX, $iAboveY, True), Hex(0x84FF18, 6), 35, Default, "isGreenDeployedBar")
				Local $sBannerCol = _GetPixelColor($ColorPickBannerX, $iTroopBanners, True)
				Local $isGreyBannerLocal = _ColorCheck($sBannerCol, Hex(0x565667, 6), 20, Default, "isGreyBanner")
				Local $isEmptySlot = _ColorCheck($sBannerCol, Hex(0x292929, 6), 15, Default, "isEmptySlot")
				Local $iOcrCount = Number(getOcrAndCapture("coc-tbb", $ColorPickBannerX, $iTroopBanners - 8, 31, 16, True))
				If $isGreyBannerLocal And $iOcrCount > 0 Then $isGreyBannerLocal = False
				If $isGreyBannerLocal Or $isGreenDeployedBar Or $isEmptySlot Then ContinueLoop

				; Live-state palette. In current CoC BB UI the healed/respawn and the
				; deployed-with-ability-ready states share banner colors with no reliable
				; per-pixel discriminator, so we accept everything that could be live.
				; Trade-off: occasional ability-trigger on already-deployed troops in
				; retry passes; benefit: never miss a deployable troop.
				;   isVioletBanner       0xC535FD - bright violet, fresh qty=1
				;   isVioletBanner2      0x12244B - dark blue giant-slot, qty=1
				;   isVioletBannerSel    0xD77AFF - light violet, selected qty=1
				;   isVioletBanner2Sel   0x15274A - dark blue selected, qty=1
				;   isVioletBannerHeal   0xDF9BFF - pink-violet healed/respawn qty=1
				;   isBlueBanner         0x518FFE - blue qty-indicator at y+20 (qty>1)
				Local $isVioletBannerLocal = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners, Hex(0xC535FD, 6), 30, "isVioletBanner")
				Local $isVioletBanner2 = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners, Hex(0x12244B, 6), 30, "isVioletBanner2")
				Local $isVioletBannerSel = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners, Hex(0xD77AFF, 6), 30, "isVioletBannerSel")
				Local $isVioletBanner2Sel = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners, Hex(0x15274A, 6), 30, "isVioletBanner2Sel")
				Local $isVioletBannerHeal = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners, Hex(0xDF9BFF, 6), 40, "isVioletBannerHeal")
				$isBlueBanner = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners + 20, Hex(0x518FFE, 6), 30, "isBlueBanner")
				Local $bIsLive = $isBlueBanner Or $isVioletBannerLocal Or $isVioletBanner2 Or $isVioletBannerSel Or $isVioletBanner2Sel Or $isVioletBannerHeal
				If Not $bIsLive Then ContinueLoop

				$Troop = $sQMISName
				$Troopy = $iSelectTroopY
				If $isBlueBanner Then
					$iCount = $iOcrCount
					If $iCount = 0 Then $iCount = Number(getOcrAndCapture("coc-tbb", $ColorPickBannerX, $iTroopBanners - 14, 31, 16, True))
					If $iCount < 1 Then $iCount = 1
				Else
					$iCount = 1
				EndIf

				Local $aTempElement[1][5] = [[$Troop, $Troopx, $Troopy, $k, $iCount]]
				_ArrayAdd($aBBAttackBar, $aTempElement)
			ElseIf $bSecondAttack Then
				; Phase-2 remaining-sweep fallback: BattleCopter wait dialog can still hide
				; the icon during retry passes. Same banner-only detection as initial scan
				; for surviving troops.
				Local $isVB2_pr2 = _ColorCheck($sColAtBannerR, Hex(0x11234B, 6), 30, Default, "isVB2_pr2") _
					Or _ColorCheck($sColAtBannerR, Hex(0x12244B, 6), 30, Default, "isVB2b_pr2") _
					Or _ColorCheck($sColAtBannerR, Hex(0x15274A, 6), 30, Default, "isVB2Sel_pr2")
				Local $isBlueInd_pr2 = _ColorCheck($sBlueIndColR, Hex(0x518FFE, 6), 35, Default, "isBlueInd_pr2")
				If $isVB2_pr2 And $isBlueInd_pr2 Then
					Local $aTempElement[1][5] = [["BabyDrag", $Troopx, $iSelectTroopY, $k, 1]]
					_ArrayAdd($aBBAttackBar, $aTempElement)
				EndIf
			EndIf
		Else
			Local $bQMIS2 = QuickMIS("BC1", $g_sImgDirBBTroops, $Troopx, $iTroopBanners, $Troopx + $iSlotOffset, 670)
			Local $sQMISName2 = $g_sQuickMISName
			Local $sColAtBanner2 = _GetPixelColor($ColorPickBannerX, $iTroopBanners, True)
			Local $sBlueIndCol = _GetPixelColor($ColorPickBannerX, $iTroopBanners + 20, True)
			If $bQMIS2 Then
				; Same permissive palette as $bRemaining branch.
				$isVioletBanner = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners, Hex(0xC535FD, 6), 30, "isVioletBanner")
				Local $isVioletBanner2_I = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners, Hex(0x12244B, 6), 30, "isVioletBanner2")
				Local $isVioletBannerSel = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners, Hex(0xD77AFF, 6), 30, "isVioletBannerSel")
				Local $isVioletBanner2Sel_I = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners, Hex(0x15274A, 6), 30, "isVioletBanner2Sel")
				Local $isVioletBannerHeal_I = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners, Hex(0xDF9BFF, 6), 40, "isVioletBannerHeal")
				$isBlueBanner = _BannerColorCheckGrid($ColorPickBannerX, $iTroopBanners + 20, Hex(0x518FFE, 6), 30, "isBlueBanner")

				$bReadTroop = $isBlueBanner Or $isVioletBanner Or $isVioletBanner2_I Or $isVioletBannerSel Or $isVioletBanner2Sel_I Or $isVioletBannerHeal_I
				If $bReadTroop Then
					$Troop = $sQMISName2
					$Troopy = $iSelectTroopY
					If $isBlueBanner Then $iCount = Number(getOcrAndCapture("coc-tbb", $ColorPickBannerX, $iTroopBanners - 8, 31, 16, True))
					If Not $isBlueBanner Then $iCount = 1
					If $iCount < 1 Then $iCount = 1

					Local $aTempElement[1][5] = [[$Troop, $Troopx, $Troopy, $k, $iCount]]
					_ArrayAdd($aBBAttackBar, $aTempElement)
				EndIf
			ElseIf $bSecondAttack Then
				; Phase-2 QMIS-fail fallback: the BattleCopter "Wait" dialog overlays the
				; troop icon and breaks template matching, but the surviving phase-1 troops
				; are still live and need to be deployed. Detect by banner alone — dark-blue
				; giant-slot family at y582 plus the blue count indicator at y602. Dead
				; slots show grey #717171 so they won't false-positive here.
				Local $isVB2_p2 = _ColorCheck($sColAtBanner2, Hex(0x11234B, 6), 30, Default, "isVB2_p2") _
					Or _ColorCheck($sColAtBanner2, Hex(0x12244B, 6), 30, Default, "isVB2b_p2") _
					Or _ColorCheck($sColAtBanner2, Hex(0x15274A, 6), 30, Default, "isVB2Sel_p2")
				Local $isBlueInd_p2 = _ColorCheck($sBlueIndCol, Hex(0x518FFE, 6), 35, Default, "isBlueInd_p2")
				If $isVB2_p2 And $isBlueInd_p2 Then
					Local $aTempElement[1][5] = [["BabyDrag", $Troopx, $iSelectTroopY, $k, 1]]
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
		[n][1] = The X Coordinate of the Troop/Spell/Hero/Siege
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
		If _Sleep(1500) Then Return
		If QuickMIS("BFI", $g_sImgDirBBTroops & $sChangeTo & "*", 0, 470, 860, 540) Then
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
