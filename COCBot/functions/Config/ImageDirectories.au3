; #Variables# ====================================================================================================================
; Name ..........: Image Search Directories
; Description ...: Gobal Strings holding Path to Images used for Image Search
; Syntax ........: $g_sImgxxx = @ScriptDir & "\imgxml\xxx\"
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $g_sImgImgLocButtons = @ScriptDir & "\imgxml\imglocbuttons"

#Region Windows
Global Const $g_sImgGeneralCloseButton = @ScriptDir & "\imgxml\Windows\CloseButton\"
#EndRegion

#Region Obstacles
Global Const $g_sImgChatTabPixel = @ScriptDir & "\imgxml\other\ChatTabPixel*"
Global Const $g_sImgAnyoneThere = @ScriptDir & "\imgxml\other\AnyoneThere[[Android]]*"
Global Const $g_sImgPersonalBreak = @ScriptDir & "\imgxml\other\break*"
Global Const $g_sImgAnotherDevice = @ScriptDir & "\imgxml\other\Device[[Android]]*"
Global Const $g_sImgCocStopped = @ScriptDir & "\imgxml\other\CocStopped*"
Global Const $g_sImgCocReconnecting = @ScriptDir & "\imgxml\other\CocReconnecting\"
Global Const $g_sImgAppRateNever = @ScriptDir & "\imgxml\other\RateNever[[Android]]*"
Global Const $g_sImgGfxError = @ScriptDir & "\imgxml\other\GfxError*"
Global Const $g_sImgError = @ScriptDir & "\imgxml\other\Error[[Android]]*"
Global Const $g_sImgOutOfSync = @ScriptDir & "\imgxml\other\Oos[[Android]]*"
Global Const $g_sImgConnectionLost = @ScriptDir & "\imgxml\other\ConnectionLost[[Android]]*"
Global Const $g_sImgMaintenance = @ScriptDir & "\imgxml\other\Maintenance*"
Global Const $G_sImgImportantNotice = @ScriptDir & "\imgxml\other\ImportantNotice[[Android]]*"
Global Const $g_sImgOptUpdateCoC = @ScriptDir & "\imgxml\other\OptUpdateCoC*"
#EndRegion

#Region Main Village
Global $g_sImgCollectResources = @ScriptDir & "\imgxml\Resources\Collect"
Global $g_sImgCollectLootCart = @ScriptDir & "\imgxml\Resources\LootCart*"
Global $g_sImgTreasuryFull = @ScriptDir & "\imgxml\Resources\Treasury"
Global $g_sImgClanCastle = @ScriptDir & "\imgxml\Buildings\ClanCastle"
Global $g_sImgLaboratory = @ScriptDir & "\imgxml\Buildings\Laboratory\"
Global $g_sImgBoat = @ScriptDir & "\imgxml\Boat\Main\"
Global $g_sImgZoomOutDir = @ScriptDir & "\imgxml\village\NormalVillage\"
Global $g_sImgZoomOutHelper = @ScriptDir & "\imgxml\village\NormalVillage\ZoomOutHelper\"
Global $g_sImgCheckWallDir = @ScriptDir & "\imgxml\Walls"
Global $g_sImgClearTombs = @ScriptDir & "\imgxml\Resources\Tombs"
Global $g_sImgCleanYard = @ScriptDir & "\imgxml\Resources\Obstacles"
Global $g_sImgCleanYardSnow = @ScriptDir & "\imgxml\Obstacles_Snow"
Global $sImgSnowTheme = @ScriptDir & "\imgxml\SnowTheme\"
Global $g_sImgGemBox = @ScriptDir & "\imgxml\Resources\GemBox"
Global $g_sImgAchievementsMainScreen = @ScriptDir & "\imgxml\AchievementRewards\MainScreen*"
Global $g_sImgAchievementsMyProfile = @ScriptDir & "\imgxml\AchievementRewards\MyProfile*"
Global $g_sImgAchievementsClaimReward = @ScriptDir & "\imgxml\AchievementRewards\ClaimButton"
Global $g_sImgAchievementsScrollEnd = @ScriptDir & "\imgxml\AchievementRewards\ScrollEnd*"
Global $g_sImgCollectReward = @ScriptDir & "\imgxml\Resources\ClaimReward"
Global $g_sImgTrader = @ScriptDir & "\imgxml\FreeMagicItems\TraderIcon"
Global $g_sImgHeroPotion = @ScriptDir & "\imgxml\FreeMagicItems\HeroPotion"
Global $g_sImgUpgradeWhiteZero = @ScriptDir & "\imgxml\Main Village\Upgrade\WhiteZero*"
Global $g_sImgDonateCC = @ScriptDir & "\imgxml\DonateCC\"
Global $g_sImgLabResearch = @ScriptDir & "\imgxml\Research\Laboratory\"
Global $g_sImgAnySpell = @ScriptDir & "\imgxml\Research\Laboratory\AllSpell\"
Global $g_sImgAnySiege = @ScriptDir & "\imgxml\Research\Laboratory\AllSiege\"
Global $g_sImgResIcon = @ScriptDir & "\imgxml\Research\ResIcon\"
Global $g_sImgUpgradeWallElix = @ScriptDir & "\imgxml\imglocbuttons\WallElix*.xml"
Global $g_sImgUpgradeWallGold = @ScriptDir & "\imgxml\imglocbuttons\WallGold*.xml"
#EndRegion

#Region Clan Capital
Global $g_sImgClanCapitalTutorial = @ScriptDir & "\imgxml\Resources\ClanCapital\Tutorial\"
Global $g_sImgCCMap = @ScriptDir & "\imgxml\Resources\ClanCapital\CCMap\"
Global $g_sImgCCRaid = @ScriptDir & "\imgxml\Resources\ClanCapital\CCMap\Raid\"
Global $g_sImgCCMapName = @ScriptDir & "\imgxml\Resources\ClanCapital\CapitalMap\"
Global $g_sImgCCMenuTriangle = @ScriptDir & "\imgxml\Resources\ClanCapital\CCMap\MenuTriangle\"
Global $g_sImgAirShip = @ScriptDir & "\imgxml\Resources\ClanCapital\CCMap\AirShip\"
Global $g_sImgLock = @ScriptDir & "\imgxml\Resources\ClanCapital\CCMap\Lock\"
Global $g_sImgCCGoldCollect = @ScriptDir & "\imgxml\Resources\ClanCapital\CCMap\CCGold\Collect\"
Global $g_sImgCCGoldCraft = @ScriptDir & "\imgxml\Resources\ClanCapital\CCMap\CCGold\Craft\"
Global $g_sImgActiveForge = @ScriptDir & "\imgxml\Resources\ClanCapital\CCMap\CCGold\ActiveForge\"
Global $g_sImgForgeHouse = @ScriptDir & "\imgxml\Resources\ClanCapital\ForgeHouse\"
Global $g_sImgResourceCC = @ScriptDir & "\imgxml\Resources\ClanCapital\CCMap\BuilderMenu\"
Global $g_sImgDecoration = @ScriptDir & "\imgxml\Resources\ClanCapital\CCMap\BuilderMenu\Decoration\"
Global $g_sImgCCUpgradeButton = @ScriptDir & "\imgxml\Resources\ClanCapital\CCMap\UpgradeButton\"
#EndRegion

#Region Boost Super Troops
Global $g_sImgBoostTroopsBarrel = @ScriptDir & "\imgxml\SuperTroops\Barrel\"
Global $g_sImgBoostTroopsIcons = @ScriptDir & "\imgxml\SuperTroops\Troops\"
Global $g_sImgBoostTroopsButtons = @ScriptDir & "\imgxml\SuperTroops\Buttons\"
Global $g_sImgBoostTroopsPotion = @ScriptDir & "\imgxml\SuperTroops\Potions\"
Global $g_sImgBoostTroopsClock = @ScriptDir & "\imgxml\SuperTroops\Clock\"
#EndRegion

#Region Builder Base
Global $g_sImgCollectResourcesBB = @ScriptDir & "\imgxml\Resources\BuildersBase\Collect"
Global $g_sImgBBZoomOutHelper = @ScriptDir & "\imgxml\village\BuilderBase\ZoomOutHelper\"
Global $g_sImgBoatBB = @ScriptDir & "\imgxml\Boat\BB\"
Global $g_sImgZoomOutDirBB = @ScriptDir & "\imgxml\village\BuilderBase\"
Global $g_sImgStartCTBoost = @ScriptDir & "\imgxml\Resources\BuildersBase\ClockTower\ClockTowerAvailable*.xml"
Global $g_sImgCleanBBYard = @ScriptDir & "\imgxml\Resources\ObstaclesBB"
Global $g_sImgBuilderHall = @ScriptDir & "\imgxml\Resources\BuildersBase\BuilderHall\"
Global $g_sImgVersusBH = @ScriptDir & "\imgxml\Resources\BuildersBase\BuilderHall\"
Global $g_sImgMegaTesla = @ScriptDir & "\imgxml\Resources\BuildersBase\MegaTesla\"
Global $g_sImgBattleMachine = @ScriptDir & "\imgxml\Resources\BuildersBase\BattleMachine\"
Global $g_sImgStarLaboratory = @ScriptDir & "\imgxml\Resources\BuildersBase\StarLaboratory"
Global $g_sImgStarLabTroops = @ScriptDir & "\imgxml\Resources\BuildersBase\StarLaboratory\Troops\"
Global $g_sImgStarLabNeedUp = @ScriptDir & "\imgxml\Resources\BuildersBase\StarLaboratory\NeedUpgrade\"
Global $g_sImgStarLabElex = @ScriptDir & "\imgxml\Resources\BuildersBase\StarLabElex\StarLabElex*"
Global $g_sImgisWall = @ScriptDir & "\imgxml\Resources\BuildersBase\AutoUpgrade\isWall\"

Global $g_sImgBBMachReady = @ScriptDir & "\imgxml\Attack\BuilderBase\BattleMachine\BBMachReady_0_90.xml"
Global $g_sImgBBBattleMachine = @ScriptDir & "\imgxml\Attack\BuilderBase\BattleMachine\BBBattleMachine_0_90.xml"
Global $g_sImgOkButton = @ScriptDir & "\imgxml\Attack\BuilderBase\OkayButton"
Global $g_sImgWatchButton = @ScriptDir & "\imgxml\Attack\BuilderBase\WatchButton"
Global $g_sImgFillTrain = @ScriptDir & "\imgxml\Attack\BuilderBase\TrainTroop\"
Global $g_sImgFillCamp = @ScriptDir & "\imgxml\Attack\BuilderBase\TrainTroop\Camp\"
Global $g_sImgArmyNeedTrain = @ScriptDir & "\imgxml\Attack\BuilderBase\ArmyNeedTrain"
Global $g_sImgDirBBTroops = @ScriptDir & "\imgxml\Attack\BuilderBase\BBTroops"
Global $g_sImgBBLootAvail = @ScriptDir & "\imgxml\Attack\BuilderBase\LootAvail\LootAvail_0_90.xml"
Global $g_sImgBBLoot = @ScriptDir & "\imgxml\Attack\BuilderBase\LootAvail\"

; Builder Base Attack
Global $g_sImgCustomArmyBB = @ScriptDir & "\imgxml\Attack\BuilderBase\ChangeTroops"
Global Const $g_sBundleBuilderHall = @ScriptDir & "\imgxml\Attack\BuilderBase\Bundles\AttackBuildings\BuilderHall"
Global Const $g_sBundleDeployPointsBB = @ScriptDir & "\imgxml\Attack\BuilderBase\Bundles\AttackBuildings\DeployPoints\"
Global Const $g_sImgOpponentBuildingsBB = @ScriptDir & "\imgxml\Attack\BuilderBase\Bundles\AttackBuildings\"
; Global Const $g_sImgAttackBtnBB = @ScriptDir & "\imgxml\Attack\BuilderBase\Attack\AttackBtn\"
; Global Const $g_sImgVersusWindow = @ScriptDir & "\imgxml\Attack\BuilderBase\Attack\VersusBattle\Window\"
; Global Const $g_sImgCloudSearch = @ScriptDir & "\imgxml\Attack\BuilderBase\Attack\VersusBattle\Clouds\"

#EndRegion

#Region DonateCC
Global $g_sImgDonateTroops = @ScriptDir & "\imgxml\DonateCC\Troops\"
Global $g_sImgDonateSpells = @ScriptDir & "\imgxml\DonateCC\Spells\"
Global $g_sImgDonateSiege = @ScriptDir & "\imgxml\DonateCC\SiegeMachines\"
Global $g_sImgChatDivider = @ScriptDir & "\imgxml\DonateCC\donateccwbl\chatdivider_0_98.xml"
Global $g_sImgChatDividerHidden = @ScriptDir & "\imgxml\DonateCC\donateccwbl\chatdividerhidden_0_98.xml"
Global $g_sImgChatIUnterstand = @ScriptDir & "\imgxml\DonateCC\donateccwbl\iunderstand_0_95.xml"
#EndRegion

#Region Auto Upgrade Normal Village
Global $g_sImgAUpgradeObstNew = @ScriptDir & "\imgxml\Resources\Auto Upgrade\Obstacles\New"
Global $g_sImgAUpgradeObstGear = @ScriptDir & "\imgxml\Resources\Auto Upgrade\Obstacles\Gear"
Global $g_sImgAUpgradeZero = @ScriptDir & "\imgxml\Resources\Auto Upgrade\Zero"
Global $g_sImgAUpgradeUpgradeBtn = @ScriptDir & "\imgxml\Resources\Auto Upgrade\UpgradeButton"
Global $g_sImgAUpgradeRes = @ScriptDir & "\imgxml\Resources\Auto Upgrade\Resources"
Global $g_sImgAUpgradeEndBoost = @ScriptDir & "\imgxml\Resources\Auto Upgrade\EndBoost\EndBoost*"
Global $g_sImgAUpgradeEndBoostOKBtn = @ScriptDir & "\imgxml\Resources\Auto Upgrade\EndBoost\EndBoostOKBtn*"
Global $g_sImgAUpgradeGreenZone = @ScriptDir & "\imgxml\Resources\Auto Upgrade\GreenZone\"
Global $g_sImgAUpgradeWall = @ScriptDir & "\imgxml\Resources\Auto Upgrade\Wall\"
Global $g_sImgWallUpgradeGold = @ScriptDir & "\imgxml\Resources\Auto Upgrade\WallUpgradeGold\"
Global $g_sImgWallUpgradeElix = @ScriptDir & "\imgxml\Resources\Auto Upgrade\WallUpgradeElix\"
Global $g_sImgAUpgradeWallOK = @ScriptDir & "\imgxml\Resources\Auto Upgrade\WallOK\"
Global $g_sImgGreenCheck = @ScriptDir & "\imgxml\Resources\Auto Upgrade\GreenCheck\"
Global $g_sImgGoblin = @ScriptDir & "\imgxml\Resources\Auto Upgrade\Goblin\"
Global $g_sImgRedX = @ScriptDir & "\imgxml\Resources\Auto Upgrade\RedX\"
Global $g_sImgAUpgradeRushTH = @ScriptDir & "\imgxml\Resources\Auto Upgrade\RushTH\"
Global $g_sImgAUpgradeHour = @ScriptDir & "\imgxml\Resources\Auto Upgrade\Hour\"
Global $g_sImgResourceIcon = @ScriptDir & "\imgxml\Resources\Auto Upgrade\ResourceIcon\"
#EndRegion

#Region Auto Upgrade Builder Base
Global $g_sImgAutoUpgradeBtnDir = @ScriptDir & "\imgxml\Resources\BuildersBase\AutoUpgrade\Upgrade"
Global $g_sImgAutoUpgradeGreenCheck = @ScriptDir & "\imgxml\Resources\BuildersBase\AutoUpgrade\NewBuildings\GreenCheck\"
Global $g_sImgAutoUpgradeRedX = @ScriptDir & "\imgxml\Resources\BuildersBase\AutoUpgrade\NewBuildings\RedX\"
Global $g_sImgArrowNewBuilding = @ScriptDir & "\imgxml\Resources\BuildersBase\AutoUpgrade\NewBuildings\Arrow\"
Global $g_sImgAUpgradeGreenZoneBB = @ScriptDir & "\imgxml\Resources\BuildersBase\AutoUpgrade\GreenZoneBB\"
Global $g_sImgBBResourceIcon = @ScriptDir & "\imgxml\Resources\BuildersBase\AutoUpgrade\BBResourceIcon\"
Global $g_sImgBBUpgradeWindowButton = @ScriptDir & "\imgxml\Resources\BuildersBase\AutoUpgrade\Upgrade\UpgradeWindowButton\"
Global $g_sImgBBGoldButton = @ScriptDir & "\imgxml\Resources\BuildersBase\AutoUpgrade\Upgrade\Gold\"
Global $g_sImgBBWallRotate = @ScriptDir & "\imgxml\Resources\BuildersBase\AutoUpgrade\WallRotate\"
#EndRegion

#Region Train
Global $g_sImgTrainTroops = @ScriptDir & "\imgxml\Train\Train_Train\"
Global $g_sImgTrainSpells = @ScriptDir & "\imgxml\Train\Spell_Train\"
Global $g_sImgArmyOverviewSpells = @ScriptDir & "\imgxml\ArmyOverview\Spells" ; @ScriptDir & "\imgxml\ArmySpells"
Global $g_sImgRequestCCButton = @ScriptDir & "\imgxml\ArmyOverview\RequestCC"
Global $g_sImgSendRequestButton = @ScriptDir & "\imgxml\ArmyOverview\RequestCC\SendRequest"
Global $g_sImgArmyOverviewHeroes = @ScriptDir & "\imgxml\ArmyOverview\Heroes"
Global $g_sImgQuickTrain = @ScriptDir & "\imgxml\Train\Quick_Train\*"
Global $g_sImgEditQuickTrain = @ScriptDir & "\imgxml\Train\EditQuickTrain\"
Global $g_sImgDelQueue = @ScriptDir & "\imgxml\Train\Delete\"
#EndRegion

#Region Attack
Global $g_sImgAttackBarDir = @ScriptDir & "\imgxml\AttackBar"
Global $g_sImgSwitchSiegeMachine = @ScriptDir & "\imgxml\SwitchSiegeMachines\"
Global $g_sImgSwitchWardenMode = @ScriptDir & "\imgxml\SwitchWardenMode"
Global $g_sImgIsMultiplayerTab = @ScriptDir & "\imgxml\Attack\Search"
#EndRegion

#Region Search
Global $g_sImgElixirStorage = @ScriptDir & "\imgxml\deadbase\elix\storage\"
Global $g_sImgElixirCollectorFill = @ScriptDir & "\imgxml\deadbase\elix\fill\"
Global $g_sImgElixirCollectorLvl = @ScriptDir & "\imgxml\deadbase\elix\lvl\"
Global $g_sImgWeakBaseBuildingsDir = @ScriptDir & "\imgxml\Buildings"
Global $g_sImgWeakBaseBuildingsEagleDir = @ScriptDir & "\imgxml\Buildings\Eagle"
Global $g_sImgWeakBaseBuildingsScatterDir = @ScriptDir & "\imgxml\Buildings\ScatterShot"
Global $g_sImgWeakBaseBuildingsInfernoDir = @ScriptDir & "\imgxml\Buildings\Infernos"
Global $g_sImgWeakBaseBuildingsXbowDir = @ScriptDir & "\imgxml\Buildings\Xbow"
Global $g_sImgWeakBaseBuildingsWizTowerSnowDir = @ScriptDir & "\imgxml\Buildings\WTower_Snow"
Global $g_sImgWeakBaseBuildingsWizTowerDir = @ScriptDir & "\imgxml\Buildings\WTower"
Global $g_sImgWeakBaseBuildingsMortarsDir = @ScriptDir & "\imgxml\Buildings\Mortars"
Global $g_sImgWeakBaseBuildingsAirDefenseDir = @ScriptDir & "\imgxml\Buildings\ADefense"
Global $g_sImgSearchDrill = @ScriptDir & "\imgxml\Storages\Drills"
Global $g_sImgSearchDrillLevel = @ScriptDir & "\imgxml\Storages\Drills\Level"
Global $g_sImgEasyBuildings = @ScriptDir & "\imgxml\easybuildings"
Global $g_sImgPrepareLegendLeagueSearch = @ScriptDir & "\imgxml\Attack\Search\LegendLeague"
Global $g_sImgRetrySearchButton = @ScriptDir & "\imgxml\Resources\Clouds\RetryButton*"
#EndRegion

#Region SwitchAcc
Global Const $g_sImgGoogleButtonState = @ScriptDir & "\imgxml\SwitchAccounts\GooglePlay\Button State\"
Global Const $g_sImgLoginWithSupercellID = @ScriptDir & "\imgxml\other\LoginWithSupercellID*"
Global Const $g_sImgGoogleSelectAccount = @ScriptDir & "\imgxml\other\GoogleSelectAccount*"
Global Const $g_sImgGoogleSelectEmail = @ScriptDir & "\imgxml\other\GoogleSelectEmail*"
Global Const $g_sImgGoogleAccounts = @ScriptDir & "\imgxml\SwitchAccounts\GooglePlay\GooglePlay*"
Global Const $g_sImgSupercellIDConnected = @ScriptDir & "\imgxml\SwitchAccounts\SupercellID\Connected\SCIDConnected*"
Global Const $g_sImgSupercellIDReload = @ScriptDir & "\imgxml\SwitchAccounts\SupercellID\Reload\SCIDReload*"
Global Const $g_sImgSupercellIDWindows = @ScriptDir & "\imgxml\SwitchAccounts\SupercellID\SCIDWindows*"
Global Const $g_sImgSupercellIDSlots = @ScriptDir & "\imgxml\SwitchAccounts\SupercellID\Slots\"
Global Const $g_sImgSupercellIDConnect = @ScriptDir & "\imgxml\SwitchAccounts\SupercellID\scidconnect*"
Global Const $g_sImgSupercellIDBlack = @ScriptDir & "\imgxml\SwitchAccounts\SupercellID\scidblack*"
#EndRegion

#Region ClanGames
Global Const $g_sImgCaravan =		@ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Caravan"
Global Const $g_sImgStart = 		@ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Start"
Global Const $g_sImgPurge = 		@ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Purge"
Global Const $g_sImgCoolPurge = 	@ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Gem"
Global Const $g_sImgTrashPurge = 	@ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Trash"
Global Const $g_sImgOkayPurge = 	@ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Okay"
Global Const $g_sImgWindow = 		@ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Window"
Global Const $g_sImgBorder = 		@ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Border"
Global Const $g_sImgGameComplete = 	@ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\GameComplete"
Global Const $g_sImgVersus  = 		@ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Versus"
Global Const $g_sImgRewardText = 		@ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Reward\Text"
Global Const $g_sImgRewardTier  = @ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Reward\Tier"
Global Const $g_sImgRewardTile  = @ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Reward\Tile"
Global Const $g_sImgRewardTileSelected  = @ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Reward\TileSelected"
Global Const $g_sImgRewardItems  = @ScriptDir & "\imgxml\Resources\ClanGamesImages\MainLoop\Reward\Items"
#EndRegion