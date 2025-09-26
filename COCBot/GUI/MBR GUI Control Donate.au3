; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control Donate
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: MyBot.run team
; Modified ......: MonkeyHunter (07-2016), CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_aiDonIcons[$eTroopCount + 1] = [$eIcnDonBarbarian, $eIcnSuperBarbarian, $eIcnDonArcher, $eIcnSuperArcher, $eIcnDonGiant, $eIcnSuperGiant, $eIcnDonGoblin, $eIcnSneakyGoblin, _
							$eIcnDonWallBreaker, $eIcnSuperWallBreaker, $eIcnDonBalloon, $eIcnRocketBalloon, $eIcnDonWizard, $eIcnSuperWizard, _
							$eIcnDonHealer, $eIcnDonDragon, $eIcnSuperDragon, $eIcnDonPekka, $eIcnDonBabyDragon, _
							$eIcnInfernoDragon, $eIcnDonMiner, $eIcnElectroDragon, $eIcnYeti, $eIcnDragonRider, $eIcnElectroTitan, _
							$eIcnDonMinion, $eIcnSuperMinion, $eIcnDonHogRider, $eIcnDonValkyrie, $eIcnSuperValkyrie, $eIcnDonGolem, _
							$eIcnDonWitch, $eIcnSuperWitch, $eIcnDonLavaHound, $eIcnIceHound, $eIcnDonBowler, $eIcnSuperBowler, $eIcnIceGolem, $eIcnHeadhunter, $eIcnDonBlank]

Func chkRequestCC()
	If GUICtrlRead($g_hChkRequestTroopsEnable) = $GUI_CHECKED Then
		$g_bRequestTroopsEnable = True
		GUICtrlSetState($g_hTxtRequestCC, $GUI_ENABLE)
	Else
		$g_bRequestTroopsEnable = False
		GUICtrlSetState($g_hTxtRequestCC, $GUI_DISABLE)
	EndIf
EndFunc

Func btnDonateTroop()
	For $i = 0 To $eTroopCount - 1 + $eSiegeMachineCount
		If @GUI_CtrlId = $g_ahBtnDonateTroop[$i] Then
			If GUICtrlGetState($g_ahGrpDonateTroop[$i]) = BitOR($GUI_HIDE, $GUI_ENABLE) Then
				_DonateBtn($g_ahGrpDonateTroop[$i], $g_ahTxtDonateTroop[$i]) ;Hide/Show controls on Donate tab
			EndIf
			ExitLoop
		EndIf
	Next
EndFunc   ;==>btnDonateTroop

Func btnDonateSpell()
	For $i = 0 To $eSpellCount - 1
		If @GUI_CtrlId = $g_ahBtnDonateSpell[$i] Then
			If GUICtrlGetState($g_ahGrpDonateSpell[$i]) = BitOR($GUI_HIDE, $GUI_ENABLE) Then
				_DonateBtn($g_ahGrpDonateSpell[$i], $g_ahTxtDonateSpell[$i])
			EndIf
			ExitLoop
		EndIf
	Next
EndFunc   ;==>btnDonateSpell

Func chkDonateTroop()
	For $i = 0 To $eTroopCount - 1 + $eSiegeMachineCount
		If @GUI_CtrlId = $g_ahChkDonateTroop[$i] Then
			If GUICtrlRead($g_ahChkDonateTroop[$i]) = $GUI_CHECKED Then
				_DonateControls($i)
			Else
				GUICtrlSetBkColor($g_ahLblDonateTroop[$i], $GUI_BKCOLOR_TRANSPARENT)
			EndIf
		EndIf
	Next
EndFunc   ;==>chkDonateTroop

Func chkDonateSpell()
	For $i = 0 To $eSpellCount - 1
		If @GUI_CtrlId = $g_ahChkDonateSpell[$i] Then
			If GUICtrlRead($g_ahChkDonateSpell[$i]) = $GUI_CHECKED Then
				_DonateControlsSpell($i)
			Else
				GUICtrlSetBkColor($g_ahLblDonateSpell[$i], $GUI_BKCOLOR_TRANSPARENT)
			EndIf
		EndIf
	Next
EndFunc   ;==>chkDonateSpell

Func _DonateBtn($hFirstControl, $hLastControl)
    Static $hLastDonateBtn1 = -1, $hLastDonateBtn2 = -1

	; Hide Controls
	If $hLastDonateBtn1 = -1 Then
		For $i = $g_ahGrpDonateTroop[$eTroopBarbarian] To $g_ahTxtDonateTroop[$eTroopBarbarian] ; 1st time use: Hide Barbarian controls
			GUICtrlSetState($i, $GUI_HIDE)
		Next
	Else
		For $i = $hLastDonateBtn1 To $hLastDonateBtn2 ; Hide last used controls on Donate Tab
			GUICtrlSetState($i, $GUI_HIDE)
		Next
	EndIf

	$hLastDonateBtn1 = $hFirstControl
	$hLastDonateBtn2 = $hLastControl

	;Show Controls
	For $i = $hFirstControl To $hLastControl ; Show these controls on Donate Tab
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc   ;==>_DonateBtn

Func _DonateControls($iTroopIndex)
	Local $iFirstTroop = 0, $iLastTroop = $eTroopCount - 1 + $eSiegeMachineCount
	If $iTroopIndex <= $eTroopCount - 1 Then
		$iLastTroop = $eTroopCount - 1
	Else
		$iFirstTroop = $eTroopCount
	EndIf

	For $i = $iFirstTroop To $iLastTroop
		If $i = $iTroopIndex Then
			GUICtrlSetBkColor($g_ahLblDonateTroop[$i], $COLOR_ORANGE)
		Else
			If GUICtrlGetBkColor($g_ahLblDonateTroop[$i]) = $COLOR_NAVY Then GUICtrlSetBkColor($g_ahLblDonateTroop[$i], $GUI_BKCOLOR_TRANSPARENT)
		EndIf
		
		If BitAND(GUICtrlGetState($g_ahTxtDonateTroop[$i]), $GUI_DISABLE) = $GUI_DISABLE Then GUICtrlSetState($g_ahTxtDonateTroop[$i], $GUI_ENABLE)
	Next
EndFunc   ;==>_DonateControls

Func _DonateControlsSpell($iSpellIndex)
	For $i = 0 To $eSpellCount - 1
		If $i = $iSpellIndex Then
			GUICtrlSetBkColor($g_ahLblDonateSpell[$i], $COLOR_ORANGE)
		Else
			If GUICtrlGetBkColor($g_ahLblDonateSpell[$i]) = $COLOR_NAVY Then GUICtrlSetBkColor($g_ahLblDonateSpell[$i], $GUI_BKCOLOR_TRANSPARENT)
	    EndIf
		
		If BitAND(GUICtrlGetState($g_ahTxtDonateSpell[$i]), $GUI_DISABLE) = $GUI_DISABLE Then GUICtrlSetState($g_ahTxtDonateSpell[$i], $GUI_ENABLE)
	Next
 EndFunc   ;==>_DonateControlsSpell

Func Doncheck()
	tabDONATE() ; just call tabDONATE()
EndFunc   ;==>Doncheck

