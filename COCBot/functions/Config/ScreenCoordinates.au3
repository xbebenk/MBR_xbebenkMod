; #Variables# ====================================================================================================================
; Name ..........: Screen Position Variables
; Description ...: Global variables for commonly used X|Y positions, screen check color, and tolerance
; Syntax ........: $aXXXXX[Y]  : XXXX is name of point or item being checked, Y = 2 for position only, or 4 when color/tolerance value included
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
; 	   $aiSomeVar = [StartX, StartY, EndX, EndY]
;Global $aiClickAwayRegionLeft = [225, 10, 255, 30]
;Global $aiClickAwayRegionRight = [605, 10, 645, 30]
;Let's tighten these up to avoid clicking on shields.
Global $aiClickAwayRegionLeft = [235, 10, 245, 20]
Global $aiClickAwayRegionRight = [625, 10, 635, 20]

Global $aCenterEnemyVillageClickDrag = [65, 545] ; Scroll village using this location in the water
Global $aCenterHomeVillageClickDrag = [750, 370] ; Scroll village using this location : upper from setting button
Global $aIsReloadError[4] = [457, 301, 0x33B5E5, 10] ; Pixel Search Check point For All Reload Button errors, except break ending
Global $aIsMain[4] = [279, 9, 0x7ABDE0, 20] ; Main Screen, Builder Info Icon
Global $aIsMainGrayed[4] = [278, 9, 0x3C5F70, 15] ; Main Screen, Builder Info Icon grayed
Global $aIsOnBuilderBase[4] = [356, 12, 0x9CD2EE, 20] ; BuilderBase, Builder Info Icon

Global $aIsConnectLost[4] = [255, 271, 0x33B5E5, 20] ; COC message : 'Connection Lost' network error or annother device
Global $aIsCheckOOS[4] = [223, 272, 0x33B5E5, 20] ; COC message : 'Connection Lost' network error or annother device
Global $aReloadButton[4] = [210, 385, 0x282828, 10] ; Reload Coc Button after Out of Sync, 860x780
Global $aAttackButton[2] = [60, 650] ; Attack Button, Main Screen, 860x676
Global $aFindMatchButton[4] = [470, 20, 0xD8A420, 10] ; Find Multiplayer Match Button, Attack Screen 860x780 without shield
Global $aIsAttackShield[4] = [250, 415, 0xE8E8E0, 10] ; Attack window, white shield verification window
Global $aAway[2] = [240, 20] ; Away click, moved from 1,1 to prevent scroll window from top, moved from 0,10 to 175,32 to prevent structure click or 175,10 to just fix MEmu 2.x opening and closing toolbar
Global $aAway2[2] = [235, 10] ; Second Away Position for Windows like Donate Window where at $aAway is a button
Global $aNoShield[4] = [448, 20, 0x43484B, 15] ; Main Screen, charcoal pixel center of shield when no shield is present
Global $aHaveShield[4] = [455, 19, 0xF0F8FB, 15] ; Main Screen, Silver pixel top center of shield
Global $aHavePerGuard[4] = [455, 19, 0x10100D, 15] ; Main Screen, black pixel in sword outline top center of shield
Global $aShieldInfoButton[4] = [431, 10, 0x75BDE4, 15] ; Main Screen, Blue pixel upper part of "i"
Global $aIsShieldInfo[4] = [645, 165, 0xEA1115, 20] ; Main Screen, Shield Info window, red pixel right of X
Global $aSurrenderButton[4] = [18, 548, 0xCD0D0D, 40] ; Surrender Button, Attack Screen
Global $aConfirmSurrender[4] = [515, 415, 0x6DBC1F, 30] ; Confirm Surrender Button, Attack Screen, green color on button?
Global $aEndFightSceneBtn[4] = [429, 519, 0xCDF271, 20] ; Victory or defeat scene buton = green edge
Global $aEndFightSceneAvl[4] = [241, 196, 0xFFF090, 20] ; Victory or defeat scene left side ribbon = light gold
Global $aEndFightSceneReportGold = $aEndFightSceneAvl ; Missing... TripleM ???
Global $aReturnHomeButton[4] = [376, 567, 0x60AC10, 20] ; Return Home Button, End Battle Screen
Global $aChatTab[4] = [331, 380, 0xC55115, 20] ; Chat Window Open, Main Screen
Global $aArmyCampSize[2] = [111, 137] ; Training Window, Overview screen, Current Size/Total Size
Global $aSiegeMachineSize[2] = [755, 136] ; Training Window, Overview screen, Current Number/Total Number
Global $aArmySpellSize[2] = [99, 284] ; Training Window Overviewscreen, current number/total capacity
Global $g_aArmyCCSpellSize[2] = [473, 438] ; Training Window, Overview Screen, Current CC Spell number/total cc spell capacity
Global $aArmyCCRemainTime[2] = [782, 552] ; Training Window Overviewscreen, Minutes & Seconds remaining till can request again
Global $aIsCampFull[4] = [128, 151, 0xFFFFFF, 10] ; Training Window, Overview screen White pixel in check mark with camp IS full (can not test for Green, as it has trees under it!)
Global $aBuildersDigits[2] = [324, 21] ; Main Screen, Free/Total Builders
Global $aBuildersDigitsBuilderBase[2] = [414, 21] ; Main Screen on Builders Base Free/Total Builders
Global $aTrophies[2] = [69, 84] ; Main Screen, Trophies
Global $aNoCloudsAttack[4] = [25, 606, 0xCD0D0D, 15] ; Attack Screen: No More Clouds
Global $aArmyTrainButton[2] = [40, 525] ; Main Screen, Army Train Button
Global $aWonOneStar[4] = [714, 540, 0xC0C8C0, 20] ; Center of 1st Star for winning attack on enemy
Global $aWonTwoStar[4] = [739, 540, 0xC0C8C0, 20] ; Center of 2nd Star for winning attack on enemy
Global $aWonThreeStar[4] = [763, 540, 0xC0C8C0, 20] ; Center of 3rd Star for winning attack on enemy
Global $aIsAtkDarkElixirFull[4] = [743, 95, 0x270D33, 10] ; Attack Screen DE Resource bar is full
Global $aIsDarkElixirFull[4] = [709, 136, 0x270D33, 10] ; Main Screen DE Resource bar is full
Global $aIsGoldFull[4] = [666, 37, 0xE7C00D, 10] ; Main Screen Gold Resource bar is Full
Global $aIsGoldLow[4] = [775, 41, 0xE7C00D, 10] ; Main Screen Gold Resource bar is Full
Global $aIsElixirFull[4] = [666, 86, 0xC027C0, 10] ; Main Screen Elixir Resource bar is Full
Global $aIsElixirLow[4] = [775, 92, 0xC027C0, 10] ; Main Screen Elixir Resource bar is Low
Global $aPerkBtn[4] = [95, 243, 0x7cd8e8, 10] ; Clan Info Page, Perk Button (blue); 800x780
Global $aIsGemWindow1[4] = [573, 239, 0xFF8D95, 20] ; Main Screen, pixel left of Red X to close gem window
Global $aIsGemWindow2[4] = [577, 266, 0xCD151D, 20] ; Main Screen, pixel below Red X to close gem window
Global $aIsGemWindow3[4] = [586, 266, 0xCD151D, 20] ; Main Screen, pixel below Red X to close gem window
Global $aIsGemWindow4[4] = [595, 266, 0xCD151D, 20] ; Main Screen, pixel below Red X to close gem window
Global $aIsTrainPgChk1[4] = [822, 92, 0xFFFFFF, 20] ; Main Screen, Train page open - left upper corner of x button
Global $aIsTrainPgChk2[4] = [762, 328, 0xF18439, 10] ; Main Screen, Train page open - Dark Orange in left arrow
Global $aRtnHomeCloud1[4] = [56, 592, 0x0A223F, 15] ; Cloud Screen, during search, blue pixel in left eye
Global $aRtnHomeCloud2[4] = [72, 592, 0x103F7E, 15] ; Cloud Screen, during search, blue pixel in right eye
Global $aDetectLang[2] = [20, 636] ; Detect Language, bottom left Attack button must read "Attack"
Global $aGreenArrowTrainTroops[2] = [308, 98]
Global $aGreenArrowBrewSpells[2] = [467, 98]
Global $aGreenArrowTrainSiegeMachines[2] = [622, 98]
Global $g_aShopWindowOpen[4] = [804, 54, 0xC00508, 15] ; Red pixel in lower right corner of RED X to close shop window
Global $aTreasuryWindow[4] = [688, 165, 0xD51115, 20] ; Redish pixel above X to close treasury window
Global $aAttackForTreasury[4] = [88, 619, 0xF0EBE8, 5] ; Red pixel below X to close treasury window
Global $aAtkHasDarkElixir[4]  = [ 31, 144, 0x282020, 10] ; Attack Page, Check for DE icon
Global $aVillageHasDarkElixir[4] = [843, 143, 0x0D0D0D, 10] ; Main Page, Base has dark elixir storage

Global $aCheckTopProfile[4] = [200, 166, 0x868CAC, 5]
Global $aCheckTopProfile2[4] = [220, 355, 0x4E4D79, 5]

Global $aIsTabOpen[4] = [0, 80, 0xF4F4F0, 25];Check if specific Tab is opened, X Coordinate is a dummy

Global $aRecievedTroops[4] = [200 ,215 ,0xFFFFFF, 20] ; Y of You have recieved blabla from xx!

; King Health Bar, check at the middle of the bar, index 4 is x-offset added to middle of health bar
Global $aKingHealth = [-1, 569, 0x00D500, 15, 13]
; Queen Health Bar, check at the middle of the bar, index 4 is x-offset added to middle of health bar
Global $aQueenHealth = [-1, 569, 0x00D500, 15, 8]
; Warden Health Bar, check at the middle of the bar, index 4 is x-offset added to middle of health bar
Global $aWardenHealth = [-1, 569, 0x00D500, 15, 3]
; Champion Health Bar, check at the middle of the bar, index 4 is x-offset added to middle of health bar
Global $aChampionHealth = [-1, 569, 0x00D500, 15, 5]

; attack report... stars won
Global $aWonOneStarAtkRprt[4] = [325, 180, 0xC8CaC4, 30] ; Center of 1st Star reached attacked village
Global $aWonTwoStarAtkRprt[4] = [398, 180, 0xD0D6D0, 30] ; Center of 2nd Star reached attacked village
Global $aWonThreeStarAtkRprt[4] = [534, 180, 0xC8CAC7, 30] ; Center of 3rd Star reached attacked village
; pixel color: location information								BS 850MB (Reg GFX), BS 500MB (Med GFX) : location

Global $NextBtn[4] = [720, 534, 0xE5590D, 20] ;  Next Button
Global $a12OrMoreSlots[4] = [16, 648, 0x4583B9, 25] ; Attackbar Check if 12+ Slots exist
Global $aDoubRowAttackBar[4] = [68, 486, 0xFC5D64, 20]
Global $aTroopIsDeployed[4] = [0, 0, 0x404040, 20] ; Attackbar Remain Check X and Y are Dummies
Global Const $aIsAttackPage[4] = [18, 548, 0xCD0D0D, 20] ; red button "end battle" but left portion

; 1 - Dark Gray : Castle filled/No Castle | 2 - Light Green : Available or Already made | 3 - White : Available or Castle filled/No Castle
Global $aRequestTroopsAO[6] = [761, 592, 0x565656, 0x71BA2F, 0xFFFFFE, 25] ; Button Request Troops in Army Overview  (x,y, Gray - Full/No Castle, Green - Available or Already, White - Available or Full)

;attackreport
Global Const $aAtkRprtDECheck[4] = [459, 372, 0x2F2038, 20]
Global Const $aAtkRprtTrophyCheck[4] = [327, 189, 0x3B321C, 30]
Global Const $aAtkRprtDECheck2[4] = [678, 418, 0x030000, 30]

;returnhome
Global Const $aRtnHomeCheck1[4] = [363, 548, 0x78C11C, 20]
Global Const $aRtnHomeCheck2[4] = [497, 548, 0x79C326, 20]
;Global Const $aRtnHomeCheck3[4]      = [ 284,  28, 0x41B1CD, 20]

Global Const $aProfileReport[4] = [619, 344, 0x4E4D79, 20] ; Dark Purple of Profile Page when no Attacks were made

Global $aArmyTrainButtonRND[4] = [20, 500, 55, 550] ; Main Screen, Army Train Button, RND  Screen 860x732
Global $aAttackButtonRND[4] = [20, 625, 100, 655] ; Attack Button, Main Screen, RND  Screen 860x676
Global $aFindMatchButtonRND[4] = [200, 510, 300, 530] ; Find Multiplayer Match Button, Both Shield or without shield Screen 860x732
Global $NextBtnRND[4] = [710, 530, 830, 570] ;  Next Button

;Switch Account
Global $aLoginWithSupercellID[4] = [280, 630, 0xDCF684, 20] ; Upper green button section "Log in with Supercell ID" 0xB1E25A
Global $aLoginWithSupercellID2[4] = [266, 653, 0xFFFFFF , 10] ; White Font "Log in with Supercell ID"
Global $aButtonSetting[4] = [820, 530, 0xFFFFFF, 10] ; Setting button, Main Screen
Global $aIsSettingPage[4] = [764, 95, 0xFFFFFF, 10] ; Main Screen, Setting page open - left upper corner of x button

;Google Play
Global $aListAccount[4] = [635, 230, 0xFFFFFF, 20] ; Accounts list google, White
Global $aButtonVillageLoad[4] = [515, 411, 0x6EBD1F, 20] ; Load button, Green
Global $aTextBox[4] = [320, 160, 0xFFFFFF, 10] ; Text box, White
Global $aButtonVillageOkay[4] = [500, 170, 0x81CA2D, 20] ; Okay button, Green

;SuperCell ID
Global $aButtonConnectedSCID[4] = [640, 160, 0x2D89FD, 20] ; Setting screen, Supercell ID Connected button (Blue Part)
Global $aCloseTabSCID[4] = [831, 57] ; Button Close Supercell ID tab

;Train
Global $aButtonEditArmy[4] = [750, 530, 0x82CC2C, 25] ; 860x676
Global $aButtonRemoveTroopsOK1[4] = [745, 551, 0x83CC2C, 20] ; 860x676
Global $aButtonRemoveTroopsOK2[4] = [515, 415, 0x6DBC1F, 20] ; 860x676

;Change Language To English
Global $aButtonLanguage[4] = [620, 275, 0xDDF685, 20]
Global $aListLanguage[4] = [110, 100, 0xFFFFFF, 10]
Global $aEnglishLanguage[4] = [420, 145, 0xD7D5C7, 20]
Global $aLanguageOkay[4] = [510, 420, 0x6FBD1F, 20]


;Personal Challenges
Global Const $aPersonalChallengeOpenButton1[4] = [130, 618, 0xEDAF44, 20] ; Personal Challenge Button
Global Const $aPersonalChallengeOpenButton2[4] = [130, 618, 0xFDE575, 20] ; Personal Challenge Button with Gold Pass
Global Const $aPersonalChallengeOpenButton3[4] = [176, 615, 0xF5151D, 20] ; Personal Challenge Button with red symbol
Global Const $aPersonalChallengeCloseButton[4] = [825, 42, 0xFFFFFF, 20] ; Personal Challenge Window Close Button
Global Const $aPersonalChallengeRewardsAvail[4] = [542, 20, 0xFF6462, 20] ; Personal Challenge - Red symbol showing available rewards
Global Const $aPersonalChallengeRewardsCheckMark[4] = [50, 365, 0xEDEDED, 20] ; Personal Challenge - CheckMark available reward to drag more
Global Const $aPersonalChallengeRewardsTab[4] = [450, 44, 0x988510, 20] ; Personal Challenge - Rewards tab unchecked with Gold Pass
Global Const $aPersonalChallengePerksTab[4] = [660, 44, 0xEFE079, 20] ; Personal Challenge - Perks tab Checked
Global Const $aPersonalChallengeLeftEdge[4] = [30, 385, 0x28221E, 20] ; Personal Challenge Window - Rewards tab - Black left edge
Global Const $aPersonalChallengeCancelBtn[4] = [345, 400, 0xFDC875, 20] ; Personal Challenge Window - Cancel button at Storage Full msg
Global Const $aPersonalChallengeOkBtn[4] = [510, 400, 0xDFF887, 20] ; Personal Challenge Window - Okay button at Storage Full msg

;xbebenkmod
Global $aBlackHead[4] = [804, 316, 0x000000, 0] ; Black Barbarian Head
Global $aOkayButton[2] = [430, 560]	; Okay button after BB attack, Screen 860x676
Global $aOkayButtonRND[4] = [372, 530, 484, 565]	; Okay button after BB attack, RND Screen 860x676