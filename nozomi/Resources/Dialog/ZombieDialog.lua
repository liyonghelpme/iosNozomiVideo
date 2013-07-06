ZombieDialog = {}

local function onDefense()
	local mainScene = display.getCurrentScene()
	mainScene:updateLogic(30)
	local scene = ZombieScene.new()
	scene.initInfo = mainScene.initInfo
	display.pushScene(scene, PreBattleScene)
	ZombieLogic.delayNext()
	UserStat.stat(UserStatType.ZOMBIE)
    UserStat.stat(UserStatType.ZOMBIE_DEFEND)
end

local function onSkip()
    local num = math.floor(ResourceLogic.getResource("person")*LOST_PERCENT/100)
    if num>0 then
    	ResourceLogic.changeResource("person", -num)
    	display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeSkipZombie", {num=num})))
    end
	ZombieLogic.delayNext()
	display.closeDialog()
	UserStat.stat(UserStatType.ZOMBIE)
	UserStat.stat(UserStatType.ZOMBIE_SKIP)
end

function ZombieDialog.create()
	local temp, bg = nil
    bg = UI.createButton(CCSizeMake(630, 461), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
    screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_DIALOG_CLEVER})
	UI.setShowAnimate(bg)
    temp = UI.createSpriteWithFile("images/dialogItemBlood.png",CCSizeMake(256, 194))
    screen.autoSuitable(temp, {x=350, y=45})
    bg:addChild(temp)
    
    local zombies = ZombieLogic.getAttackZombies()
    local offi = 0
    local batchSprite = CCSpriteBatchNode:create("images/dialogItemBattleResultItemA.png")
    bg:addChild(batchSprite)
    for i=1, 8 do
        temp = UI.createSpriteWithFile("images/dialogItemBattleResultItemA.png",CCSizeMake(65, 85))
        screen.autoSuitable(temp, {x=i*75-53, y=171})
        batchSprite:addChild(temp)
        local num = zombies[i] or 0
        if num>0 then
			temp = UI.createScaleSprite("images/zombieHead" .. i .. ".png", CCSizeMake(60, 80))
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=(i-offi)*75-20, y=214})
			bg:addChild(temp)
            temp = UI.createLabel(StringManager.getString("x" .. num), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
            screen.autoSuitable(temp, {x=(i-offi)*75+5, y=187, nodeAnchor=General.anchorRight})
            bg:addChild(temp)
        else
            offi = offi+1
        end
    end
    
    temp = UI.createButton(CCSizeMake(135, 61), onDefense, {image="images/buttonGreen.png", text=StringManager.getString("buttonDefense"), fontSize=25, fontName=General.font3})
    screen.autoSuitable(temp, {x=315, y=70, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    if ZombieLogic.isGuide then
        temp = UI.createGuidePointer(90)
        temp:setPosition(385, 70)
        bg:addChild(temp)
    end
    temp = UI.createLabel(StringManager.getString("labelZombieDefense"), General.font1, 25, {colorR = 75, colorG = 66, colorB = 46})
    screen.autoSuitable(temp, {x=315, y=318, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("titleWarning"), General.font3, 28, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=315, y=429, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
	return {view=bg}
end