
Global $aiClickAwayRegionLeft = [229, 5, 242, 20]
Global $aiClickAwayRegionRight = [635, 5, 650, 20]

Global $aVillageCenteringCoord = [[750, 370], [636, 500], [777, 235]] ; Scroll village using this location : upper from setting button
Global $aIsMain[4] = [824, 12, 0xDBDB4D, 20] ; Main Screen, Yellow Gold Resource Icon
Global $aIsOnBuilderBase[4] = [824, 12, 0x0D0D0D, 20] ; BuilderBase, Yellow Gold Resource Icon
Global $aIsMainGrayed[4] = [824, 14, 0x80802D, 15] ; Main Screen, Yellow Grayed Gold Resource Icon

Global $aFindMatchButton[4] = [470, 20, 0xD8A420, 10] ; Find Multiplayer Match Button, Attack Screen 860x780 without shield
Global $aIsAttackShield[4] = [250, 415, 0xE8E8E0, 10] ; Attack window, white shield verification window
Global $aShieldInfoButton[4] = [431, 10, 0x75BDE4, 15] ; Main Screen, Blue pixel upper part of "i"
Global $aIsShieldInfo[4] = [645, 165, 0xEA1115, 20] ; Main Screen, Shield Info window, red pixel right of X
Global $aSurrenderButton[4] = [18, 548, 0xCD0D0D, 40] ; Surrender Button, Attack Screen
Global $aConfirmSurrender[4] = [531, 438, 0x6DBC1F, 30] ; Confirm Surrender Button, Attack Screen, green color on button?
Global $aEndFightSceneBtn[4] = [429, 519, 0xCDF271, 20] ; Victory or defeat scene buton = green edge
Global $aEndFightSceneAvl[4] = [241, 196, 0xFFF090, 20] ; Victory or defeat scene left side ribbon = light gold
Global $aEndFightSceneReportGold = $aEndFightSceneAvl ; Missing... TripleM ???
Global $aReturnHomeButton[4] = [425, 567, 0x6CBB1F, 20] ; Return Home Button, End Battle Screen
Global $aReturnHomeChest[4] = [525, 550, 0x84CD2C, 20] ; Return Home Button, End Battle Screen
Global $aChatTab[4] = [400, 330, 0xEA8A3B, 20] ; Chat Window Open, Main Screen
Global $aChatTabClosed[4] = [40, 330, 0xEA8A3B, 20] ; Chat Window Closed
Global $aSiegeMachineSize[2] = [710, 168] ; Training Window, Overview screen, Current Number/Total Number
Global $aArmySpellSize[2] = [145, 295] ; Training Window Overviewscreen, current number/total capacity
Global $g_aArmyCCSpellSize[2] = [463, 429] ; Training Window, Overview Screen, Current CC Spell number/total cc spell capacity
Global $aArmyCCRemainTime[2] = [782, 552] ; Training Window Overviewscreen, Minutes & Seconds remaining till can request again
Global $aIsCampFull[4] = [42, 154, 0xFFFFFF, 10] ; Training Window, Overview screen White pixel in check mark with camp IS full (can not test for Green, as it has trees under it!)
Global $aBuildersDigits[2] = [426, 22] ; Main Screen, Free/Total Builders
Global $aBuildersDigitsBuilderBase[2] = [492, 22] ; Main Screen on Builders Base Free/Total Builders
Global $aTrophies[2] = [68, 84] ; Main Screen, Trophies
Global $aArmyTrainButton[2] = [40, 525] ; Main Screen, Army Train Button
Global $aWonOneStar[4] = [714, 540, 0xC0C8C0, 20] ; Center of 1st Star for winning attack on enemy
Global $aWonTwoStar[4] = [739, 540, 0xC0C8C0, 20] ; Center of 2nd Star for winning attack on enemy
Global $aWonThreeStar[4] = [763, 540, 0xC0C8C0, 20] ; Center of 3rd Star for winning attack on enemy
Global $aIsAtkDarkElixirFull[4] = [743, 95, 0x270D33, 10] ; Attack Screen DE Resource bar is full
Global $aIsDarkElixirFull[4] = [709, 136, 0x270D33, 10] ; Main Screen DE Resource bar is full
Global $aIsGoldFull[4] = [670, 37, 0xE7C00D, 10] ; Main Screen Gold Resource bar is Full
Global $aIsGoldLow[4] = [775, 41, 0xE7C00D, 10] ; Main Screen Gold Resource bar is Full
Global $aIsElixirFull[4] = [670, 86, 0xC027C0, 10] ; Main Screen Elixir Resource bar is Full
Global $aIsElixirLow[4] = [775, 92, 0xC027C0, 10] ; Main Screen Elixir Resource bar is Low
Global $aIsGemWindow1[4] = [610, 236, 0xEC1115, 20] ; Main Screen, pixel left of Red X to close gem window
Global $aIsGemWindow2[4] = [624, 214, 0xFF8D95, 20] ; Main Screen, pixel above Red X to close gem window
Global $aIsGemWindow3[4] = [616, 249, 0xCE181E, 20] ; Main Screen, pixel below left Red X to close gem window
Global $aIsGemWindow4[4] = [632, 249, 0xCE181E, 20] ; Main Screen, pixel below right Red X to close gem window
Global $aIsTrainPage[4] = [793, 168, 0xCE191F, 20] ; Main Screen, Train page open - below red x button
Global $aIsTrainItPage[4] = [8, 472, 0x73695F, 20] ; Main Screen, TrainIt page open
Global $aRtnHomeCloud1[4] = [56, 592, 0x0A223F, 15] ; Cloud Screen, during search, blue pixel in left eye
Global $aRtnHomeCloud2[4] = [72, 592, 0x103F7E, 15] ; Cloud Screen, during search, blue pixel in right eye
Global $aDetectLang[2] = [20, 636] ; Detect Language, bottom left Attack button must read "Attack"
Global $aTreasuryWindow[4] = [700, 170, 0xCE333B, 20] ; Redish pixel below X to close treasury window
Global $aAttackForTreasury[4] = [88, 619, 0xF0EBE8, 5] ; Red pixel below X to close treasury window
Global $aAtkHasDarkElixir[4]  = [ 30, 150, 0x2A2124, 10] ; Attack Page, Check for DE icon
Global $aVillageHasDarkElixir[4] = [826, 138, 0x3E313C, 10] ; Main Page, Base has dark elixir storage
Global $aCheckTopProfile[4] = [200, 166, 0x868CAC, 5]
Global $aCheckTopProfile2[4] = [220, 355, 0x4E4D79, 5]
Global $aIsTabOpen[4] = [0, 152, 0xEAEAE3, 10];Check if specific Tab is opened, X Coordinate is a dummy
Global $aRecievedTroops[4] = [585, 179, 0xFFFFFF, 20] ; Y of You have recieved blabla from xx!
Global $aLabMenuOpened[4] = [320, 63, 0xE8E9DF, 40]

; Hero Health Bar, check at the middle of the bar, index 4 is x-offset added to middle of health bar
Global $aKingHealth = [-1, 569, 0x00D500, 15, 13]
Global $aQueenHealth = [-1, 569, 0x00D500, 15, 8]
Global $aWardenHealth = [-1, 569, 0x00D500, 15, 3]
Global $aChampionHealth = [-1, 569, 0x00D500, 15, 5]
Global $aMinionPHealth = [-1, 569, 0x00D500, 15, 5]
; attack report... stars won
Global $aWonOneStarAtkRprt[4] = [325, 180, 0xC8CaC4, 30] ; Center of 1st Star reached attacked village
Global $aWonTwoStarAtkRprt[4] = [398, 180, 0xD0D6D0, 30] ; Center of 2nd Star reached attacked village
Global $aWonThreeStarAtkRprt[4] = [534, 180, 0xC8CAC7, 30] ; Center of 3rd Star reached attacked village
; pixel color: location information								BS 850MB (Reg GFX), BS 500MB (Med GFX) : location

Global $a12OrMoreSlots[4] = [16, 608, 0x5B95C9, 25] ; Attackbar Check if 12+ Slots exist
Global $aDoubRowAttackBar[4] = [68, 486, 0xFC5D64, 20]
Global $aTroopIsDeployed[4] = [0, 0, 0x404040, 20] ; Attackbar Remain Check X and Y are Dummies
Global $aIsAttackPage[4] = [18, 548, 0xCD0D0D, 20] ; red button "end battle" but left portion

; 1 - Dark Gray : Castle filled/No Castle | 2 - Light Green : Available or Already made | 3 - White : Available or Castle filled/No Castle
Global $aRequestTroopsAO[6] = [761, 592, 0x565656, 0x71BA2F, 0xFFFFFE, 25] ; Button Request Troops in Army Overview  (x,y, Gray - Full/No Castle, Green - Available or Already, White - Available or Full)

;attackreport
Global $aAtkRprtDECheck[4] = [468, 371, 0x2F1D37, 20]
Global $aAtkRprtTrophyCheck[4] = [423, 223, 0xFF6133, 30]
Global $aAtkRprtDECheck2[4] = [678, 418, 0x030000, 30]

;returnhome
Global $aRtnHomeCheck1[4] = [363, 548, 0x78C11C, 20]
Global $aRtnHomeCheck2[4] = [497, 548, 0x79C326, 20]
;Global Const $aRtnHomeCheck3[4]      = [ 284,  28, 0x41B1CD, 20]

Global $aArmyTrainButtonRND[4] = [20, 500, 55, 550] ; Main Screen, Army Train Button, RND  Screen 860x732
Global $aFindMatchButtonRND[4] = [200, 510, 300, 530] ; Find Multiplayer Match Button, Both Shield or without shield Screen 860x732

;Switch Account
Global $aLoginWithSupercellID[4] = [280, 630, 0xDCF684, 20] ; Upper green button section "Log in with Supercell ID" 0xB1E25A
Global $aLoginWithSupercellID2[4] = [266, 653, 0xFFFFFF , 10] ; White Font "Log in with Supercell ID"
Global $aButtonSetting[4] = [820, 530, 0xFFFFFF, 10] ; Setting button, Main Screen
Global $aIsSettingPage[4] = [786, 97, 0xDA1013, 20] ; Main Screen, Setting page open - red bottom lower of x button

;SuperCell ID
Global $aButtonConnectedSCID[4] = [640, 160, 0x2D89FD, 20] ; Setting screen, Supercell ID Connected button (Blue Part)
Global $aCloseTabSCID[4] = [831, 57] ; Button Close Supercell ID tab

;Train
Global $aBtnEditArmy[4] = [725, 492, 0xDDF685, 20] ; 860x676
Global $aBtnRemOK1[4] = [724, 527, 0x7AC32E, 20] ; 860x676
Global $aBtnRemOK2[4] = [531, 431, 0x6FBE20, 20] ; 860x676

;Change Language To English
Global $aButtonLanguage[4] = [620, 275, 0xDDF685, 20]
Global $aListLanguage[4] = [110, 100, 0xFFFFFF, 10]
Global $aEnglishLanguage[4] = [420, 145, 0xD7D5C7, 20]
Global $aLanguageOkay[4] = [510, 420, 0x6FBD1F, 20]


;Personal Challenges
Global $aPersonalChallengeOpenButton1[4] = [130, 618, 0xEDAF44, 20] ; Personal Challenge Button
Global $aPersonalChallengeOpenButton2[4] = [130, 618, 0xFDE575, 20] ; Personal Challenge Button with Gold Pass
Global $aPersonalChallengeOpenButton3[4] = [176, 615, 0xF5151D, 20] ; Personal Challenge Button with red symbol
Global $aPersonalChallengeRewardsAvail[4] = [451, 62, 0xFF0B0B, 20] ; Personal Challenge - Red symbol showing available rewards
Global $aPersonalChallengeRewardsCheckMark[4] = [80, 400, 0xFFFFFF, 20] ; Personal Challenge - CheckMark available reward to drag more
Global $aPersonalChallengeRewardsTab[4] = [380, 90, 0x988510, 20] ; Personal Challenge - Rewards tab unchecked with Gold Pass

;xbebenkmod
Global $aBlackHead[4] = [629, 405, 0xFFEE49, 20] ; Black Barbarian Head
Global $aHeroHall[4] = [810, 190, 0x4D311D, 20]
