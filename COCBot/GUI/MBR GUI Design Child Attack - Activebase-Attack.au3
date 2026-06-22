; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "Attack" tab under the "ActiveBase" tab under the "Search & Attack" tab under the "Attack Plan" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

; Attack with
Global $g_hCmbABAlgorithm = 0, $g_hCmbABSelectTroop = 0, $g_hChkABKingAttack = 0, $g_hChkABQueenAttack = 0, $g_hChkABWardenAttack = 0
Global $g_hGrpABAttack = 0, $g_hPicABKingAttack = 0, $g_hPicABQueenAttack = 0, $g_hPicABWardenAttack = 0, $g_hPicABDropCC = 0

Global $g_hCmbABSiege = 0, $g_hCmbABWardenMode = 0, $g_hChkABChampionAttack = 0, $g_hPicABChampionAttack = 0, $g_hChkABDropEmptySiege = 0

Func CreateAttackSearchActiveBaseAttack()
	Local $sTxtTip = ""
	Local $x = 25, $y = 40
		$g_hGrpABAttack = GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Group_01", "Attack with"), $x - 20, $y - 15, 145, 290)
		$x -= 15
		$y += 2
			$g_hCmbABAlgorithm = GUICtrlCreateCombo("", $x, $y, 135, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				_GUICtrlSetTip(-1, "")
				GUICtrlSetData(-1, "Standard Attack|Scripted Attack", "Standard Attack")
				GUICtrlSetOnEvent(-1, "cmbABAlgorithm")

		$y += 27
			$g_hCmbABSelectTroop = GUICtrlCreateCombo("", $x, $y, 135, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_01", "Use All Troops") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_02", "Use Troops in Barracks") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_03", "Barb Only") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_04", "Arch Only") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_05", "B+A") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_06", "B+Gob") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_07", "A+Gob") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_08", "B+A+Gi") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_09", "B+A+Gob+Gi") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_10", "B+A+Hog Rider") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_11", "B+A+Minion"), GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Item_01", -1))
				_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-SelectTroop_Info_01", "Select the troops to use in attacks"))
		
		$y += 27
		$x = 10
			$g_hPicABWardenAttack = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnWarden, $x, $y, 24, 24)
				$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Chk-Use-Warden_Info_01", "Use your Warden when Attacking...") & @CRLF & _
						   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Chk-Use-Warden_Info_02", "Enabled with Townhall 11")
				_GUICtrlSetTip(-1, $sTxtTip)

		$x += 32
			$g_hCmbABWardenMode = GUICtrlCreateCombo("", $x, $y, 90, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-WardenMode_Item_01", "Ground mode") & "|" & _
                                       GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-WardenMode_Item_02", "Air mode") & "|" & _
                                       GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-WardenMode_Item_03", "Default mode"), GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-WardenMode_Item_03", -1))
				$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-WardenMode_Tip", "Select Grand Warden's mode 'Ground' or 'Air'" & @CRLF & _
												"The Bot will always check Grand Warden's mode before every attack" & @CRLF & _
												"Choose 'Default mode' to bypass Grand Warden check")
				_GUICtrlSetTip(-1, $sTxtTip)

		$y += 27
		$x = 10
			$g_hPicABDropCC = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnCC, $x, $y, 24, 24)
				$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Chk-Use-Clan Castle_Info_01", -1)
				_GUICtrlSetTip(-1, $sTxtTip)
			;$g_hChkABDropCC = GUICtrlCreateCheckbox("", $x + 27, $y, 17, 17)
			;	_GUICtrlSetTip(-1, $sTxtTip)
            ;    GUICtrlSetOnEvent(-1, "chkABDropCC")

		$x += 32
			$g_hCmbABSiege = GUICtrlCreateCombo("", $x, $y, 90, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
				GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_01", "Castle only") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_02", "Wall Wrecker") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_03", "Battle Blimp") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_04", "Stone Slammer") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_05", "Siege Barracks") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_06", "Log Launcher") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_07", "Flame Flinger") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_08", "Battle Drill") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_09", "Troop Launcher") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_09", "Sky Wagon") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_10", "Any Siege") & "|" & _
								   GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_11", "Default"), GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Item_11", -1))
				$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "Cmb-Siege_Tip", "Select Castle or Siege to be used." & @CRLF & _
												"The Bot will always check Castle/Siege type before every attack." & @CRLF & _
												"Choose 'Default' to bypass Castle/Siege check")
				_GUICtrlSetTip(-1, $sTxtTip)
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		
		$y += 27
		$x = 10
		$g_hChkABDropEmptySiege = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "ChkDropEmptySiege", "Drop Empty Siege"), $x, $y, -1, -1)
		
EndFunc   ;==>CreateAttackSearchActiveBaseAttack
