; #FUNCTION# ====================================================================================================================
; Name ..........: Clash of Cards
; Description ...: Seasonal event (August only). Card packs are earned during attacks and, like the existing Chest
;                   Event (IsReturnHomeChestPage() in Other/IsPage.au3), the reward is forced open right on the
;                   end-battle screen before the bot can return to the main village: a "Tap!" card banner that
;                   needs several taps to break open, followed by a Continue or Claim Reward button.
; Remarks .......: Gated entirely behind IsClashOfCardsEventActive() (calendar month check) so this is a safe
;                   no-op outside August, per the event being time-limited.
; ===============================================================================================================================

Func IsClashOfCardsEventActive()
	Return @MON = 8
EndFunc   ;==>IsClashOfCardsEventActive

; Bounding regions confirmed live at 860x676 (Tap icon matched at [441,321], Continue at [448,517]), with margin.
; An unbounded QuickMIS scans the whole screen at every scale and took 20-90s per call in testing - since this
; now runs on every checkObstacles() call during waitMainScreen()'s retry loop, bounding it matters for speed,
; not just correctness.
Global Const $aClashOfCardsTapRegion[4] = [280, 170, 600, 470]
Global Const $aClashOfCardsButtonRegion[4] = [370, 480, 550, 555]

; Detects and opens a pending Clash of Cards pack, if any. Safe no-op if the event isn't active this month or no
; pack is currently shown. Mirrors IsReturnHomeChestPage()'s tap-then-continue pattern (Other/IsPage.au3:236).
; Also handles being caught mid-flow (e.g. CoC was force-restarted while the pack was already tapped open, so
; only Continue/Claim Reward is visible, never the Tap icon) - important since checkObstacles() calls this on
; every waitMainScreen() retry, and a restart mid-pack is exactly the state that used to loop forever.
Func CheckClashOfCards($bSetLog = True)
	If Not IsClashOfCardsEventActive() Then Return False
	If Not $g_bRunState Then Return False

	Local $bTapIconFound = QuickMIS("BC1", $g_sImgCardTapIcon, $aClashOfCardsTapRegion[0], $aClashOfCardsTapRegion[1], $aClashOfCardsTapRegion[2], $aClashOfCardsTapRegion[3])
	If Not $bTapIconFound And Not QuickMIS("BC1", $g_sImgContinueButton, $aClashOfCardsButtonRegion[0], $aClashOfCardsButtonRegion[1], $aClashOfCardsButtonRegion[2], $aClashOfCardsButtonRegion[3]) And Not QuickMIS("BC1", $g_sImgClaimRewardButton, $aClashOfCardsButtonRegion[0], $aClashOfCardsButtonRegion[1], $aClashOfCardsButtonRegion[2], $aClashOfCardsButtonRegion[3]) Then
		Return False ; nothing pending, cheap no-op
	EndIf

	If $bTapIconFound Then
		If $bSetLog Then SetLog("Clash of Cards: pack found, tapping to open", $COLOR_ACTION)
		For $i = 1 To 10 ; the pack needs a handful of taps to break open (observed: 3), pad out to be safe
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Tap Card Pack")
			If _Sleep(700) Then Return
		Next
	Else
		If $bSetLog Then SetLog("Clash of Cards: caught already open (Continue/Claim Reward visible), skipping tap", $COLOR_ACTION)
	EndIf

	Local $bClosed = False
	For $i = 1 To 10
		If QuickMIS("BC1", $g_sImgContinueButton, $aClashOfCardsButtonRegion[0], $aClashOfCardsButtonRegion[1], $aClashOfCardsButtonRegion[2], $aClashOfCardsButtonRegion[3]) Then
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Click Continue")
			$bClosed = True
			ExitLoop
		EndIf
		If QuickMIS("BC1", $g_sImgClaimRewardButton, $aClashOfCardsButtonRegion[0], $aClashOfCardsButtonRegion[1], $aClashOfCardsButtonRegion[2], $aClashOfCardsButtonRegion[3]) Then
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Click Claim Reward")
			$bClosed = True
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next

	If $bSetLog Then
		If $bClosed Then
			SetLog("Clash of Cards: pack opened and claimed", $COLOR_SUCCESS)
		Else
			SetLog("Clash of Cards: opened pack but Continue/Claim Reward button not found", $COLOR_ERROR)
		EndIf
	EndIf
	Return $bClosed
EndFunc   ;==>CheckClashOfCards

; Detect-only smoke test - call via Test420 to confirm the template actually matches live before relying on
; CheckClashOfCards() for real. Does not tap/claim anything.
Func ClashOfCards_Test()
	If Not IsClashOfCardsEventActive() Then
		SetLog("ClashOfCards_Test: event not active this month (August only)", $COLOR_INFO)
		Return False
	EndIf

	; checks all three templates independently - whichever screen you're actually on (tap card, or the
	; reward/Continue screen after it's already opened) will report a match, the others just won't
	If QuickMIS("BC1", $g_sImgCardTapIcon, $aClashOfCardsTapRegion[0], $aClashOfCardsTapRegion[1], $aClashOfCardsTapRegion[2], $aClashOfCardsTapRegion[3]) Then
		SetLog("ClashOfCards_Test: Tap card icon FOUND at [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_SUCCESS)
	Else
		SetLog("ClashOfCards_Test: Tap card icon NOT found (not on that screen, or template needs tuning)", $COLOR_INFO)
	EndIf

	If QuickMIS("BC1", $g_sImgContinueButton, $aClashOfCardsButtonRegion[0], $aClashOfCardsButtonRegion[1], $aClashOfCardsButtonRegion[2], $aClashOfCardsButtonRegion[3]) Then
		SetLog("ClashOfCards_Test: Continue button FOUND at [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_SUCCESS)
	Else
		SetLog("ClashOfCards_Test: Continue button NOT found (not on that screen, or template needs tuning)", $COLOR_INFO)
	EndIf

	If QuickMIS("BC1", $g_sImgClaimRewardButton, $aClashOfCardsButtonRegion[0], $aClashOfCardsButtonRegion[1], $aClashOfCardsButtonRegion[2], $aClashOfCardsButtonRegion[3]) Then
		SetLog("ClashOfCards_Test: Claim Reward button FOUND at [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]", $COLOR_SUCCESS)
	Else
		SetLog("ClashOfCards_Test: Claim Reward button NOT found (not on that screen, or template needs tuning)", $COLOR_INFO)
	EndIf

	Return True
EndFunc   ;==>ClashOfCards_Test
