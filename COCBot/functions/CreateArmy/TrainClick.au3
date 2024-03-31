; #FUNCTION# ====================================================================================================================
; Name ..........: TrainClick
; Description ...: Clicks in troop training window with special checks for Barracks Full, and If not enough elxir to train troops or to close the gem window if opened.
; Syntax ........: TrainClick($x, $y, $iTimes, $iSpeed, $aWatchSpot, $aLootSpot, $debugtxt = "")
; Parameters ....: $x                   - X location to click
;                  $y                   - Y location to click
;                  $iTimes              - Number fo times to cliok
;                  $iSpeed              - Wait time after click
;                  $aWatchSpot          - [in/out] an array of [X location, Y location, Hex Color, Tolerance] to check after click if full
;                  $aLootSpot           - [in/out] an array of [X location, Y location, Hex Color, Tolerance] to check after click, color used to see if out of Elixir for more troops
;						 $sdebugtxt				 - String with click debug text
; Return values .: None
; Author ........: KnowJack (07-2015)
; Modified ......: Sardo (08-2015), Boju (06-2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func TrainClick($iX, $iY, $iTimes, $TypeTroops)
	If Not $g_bRunState Then Return
	If IsTrainPage() Then
		If $g_bDebugSetLog Then
			SetLog("TrainClick(" & $iX & "," & $iX & "," & $iTimes & ", " & "Train " & $TypeTroops & ")", $COLOR_DEBUG)
		EndIf

		If $iTimes <> 1 Then
			For $i = 1 To $iTimes
				If IsProblemAffect() Then checkMainScreen()
				PureClick($iX, $iY, 1, $g_iTrainClickDelay, "Train " & $TypeTroops) ;Click $iTimes.
			Next
		Else
			If IsProblemAffect() Then checkMainScreen()
			PureClick($iX, $iY, 1, $g_iTrainClickDelay, "Train " & $TypeTroops)
		EndIf
		Return True
	EndIf
EndFunc   ;==>TrainClick

Func TrainClickP($aPoint, $iHowOften, $TypeTroops)
	Return TrainClick($aPoint[0], $aPoint[1], $iHowOften, $TypeTroops)
EndFunc   ;==>TrainClickP
