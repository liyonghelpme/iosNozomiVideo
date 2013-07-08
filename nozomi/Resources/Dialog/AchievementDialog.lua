AchievementDialog = {}

local function onGetRewards(info)
    display.closeDialog()
    Achievements.completeAchievement(info.id)
    CrystalLogic.changeCrystal(info.crystal)
    --UserData.changeValue("exp", info.exp)
    display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeGetReward", {num=info.crystal}), 255))
    
	EventManager.sendMessage("EVENT_NOTICE_BUTTON", {name="achieve"})
end

local function updateAchievementCell(bg, scrollView, info)
    -- 31 327
    local temp
    temp = UI.createSpriteWithFile("images/dialogItemAchieveCell.png",CCSizeMake(671, 116))
    screen.autoSuitable(temp, {x=0, y=0})
    bg:addChild(temp)
    
    temp = UI.createLabel(info.desc, General.font1, 15, {colorR = 0, colorG = 0, colorB = 0, size=CCSizeMake(245, 0)})
    screen.autoSuitable(temp, {x=207, y=85, nodeAnchor=General.anchorLeftTop})
    bg:addChild(temp)
    temp = UI.createLabel(info.title, General.font3, 18, {colorR = 255, colorG = 255, colorB = 222})
    screen.autoSuitable(temp, {x=209, y=101, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    
    if info.level<=3 then
        local num = info.num
        if num>=info.max then
            temp = UI.createButton(CCSizeMake(146, 43), onGetRewards, {callbackParam=info, image="images/buttonGreenB.png", text=StringManager.getString("buttonReward"), fontSize=18, fontName=General.font3})
            screen.autoSuitable(temp, {x=326, y=33, nodeAnchor=General.anchorCenter})
            bg:addChild(temp)
        else
            temp = UI.createSpriteWithFile("images/dialogItemInfoProcessBack.png",CCSizeMake(242, 24))
            screen.autoSuitable(temp, {x=205, y=14})
            bg:addChild(temp)
            temp = UI.createSpriteWithFile("images/dialogItemInfoProcessFiller.png",CCSizeMake(240, 20))
            screen.autoSuitable(temp, {x=206, y=16})
            bg:addChild(temp)
            local ttable = {}
            UI.registerAsProcess(temp, ttable)
            UI.setProcess(temp, ttable, num/info.max)
            temp = UI.createLabel(num .. "/" .. info.max, General.font4, 15, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
            screen.autoSuitable(temp, {x=326, y=26, nodeAnchor=General.anchorCenter})
            bg:addChild(temp)
        end
        temp = UI.createLabel(StringManager.getString("labelReward"), General.font1, 13, {colorR = 87, colorG = 83, colorB = 83})
        screen.autoSuitable(temp, {x=650, y=62, nodeAnchor=General.anchorRight})
        bg:addChild(temp)
        --temp = UI.createLabel(info.exp .. "x", General.font4, 22, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
        --screen.autoSuitable(temp, {x=514, y=34, nodeAnchor=General.anchorRight})
        --bg:addChild(temp)
        --temp = UI.createSpriteWithFile("images/exp.png",CCSizeMake(43, 41))
        --screen.autoSuitable(temp, {x=517, y=12})
        --bg:addChild(temp)
        temp = UI.createLabel(info.crystal .. "x", General.font4, 22, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
        screen.autoSuitable(temp, {x=615, y=34, nodeAnchor=General.anchorRight})
        bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(38, 37))
        screen.autoSuitable(temp, {x=620, y=12})
        bg:addChild(temp)
    else
        temp = UI.createLabel(StringManager.getString("labelAchieveComplete"), General.font2, 15, {colorR = 157, colorG = 226, colorB = 76})
        screen.autoSuitable(temp, {x=326, y=40, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
    end
    
    --temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png",CCSizeMake(160, 180))
    --screen.autoSuitable(temp, {x=15, y=-19})
    --bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/battleEndRibbon.png",CCSizeMake(169, 55))
    screen.autoSuitable(temp, {x=17, y=17})
    bg:addChild(temp)

    temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(59, 57))
    screen.autoSuitable(temp, {x=67, y=46})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(43, 40))
    screen.autoSuitable(temp, {x=37, y=41})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(43, 41))
    screen.autoSuitable(temp, {x=114, y=41})
    bg:addChild(temp)
    if info.level>1 then
        temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(44, 41))
        screen.autoSuitable(temp, {x=37, y=41})
        bg:addChild(temp)
        if info.level>2 then
            temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(61, 57))
            screen.autoSuitable(temp, {x=67, y=46})
            bg:addChild(temp)
            if info.level>3 then
                temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(44, 41))
                screen.autoSuitable(temp, {x=114, y=41})
                bg:addChild(temp)
            end
        end
    end
end

local function showGameCenterAchievements()
	display.closeDialog()
	CCNative:showAchievements()
end

function AchievementDialog.show()
    local temp, bg = nil
    bg = UI.createButton(CCSizeMake(720, 526), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
    screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_DIALOG_CLEVER})
    UI.setShowAnimate(bg)
    temp = UI.createSpriteWithFile("images/dialogItemBlood.png",CCSizeMake(292, 222))
    screen.autoSuitable(temp, {x=422, y=134})
    bg:addChild(temp)
    
    local stars, starMax=0, 51
    local items = Achievements.getAchievementsAllData()
    starMax = 3* (#items)
    for i=1, #items do
        stars = stars + (items[i].level-1)
    end
    local scrollView = UI.createScrollViewAuto(CCSizeMake(720, 340), false, {offx=23, offy=1, disy=9, size=CCSizeMake(671, 116), infos=items, cellUpdate=updateAchievementCell})
    screen.autoSuitable(scrollView.view, {nodeAnchor=General.anchorLeftTop, x=0, y=445})
    bg:addChild(scrollView.view)
    
    temp = UI.createSpriteWithFile("images/dialogItemAchieveBg.png",CCSizeMake(661, 60))
    screen.autoSuitable(temp, {x=29, y=28})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelComplete"), General.font1, 13, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=161, y=70, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createLabel(stars .. "/" .. starMax, General.font4, 21, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
    screen.autoSuitable(temp, {x=192, y=46, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/achieveNpcFeature.png",CCSizeMake(97, 125))
    screen.autoSuitable(temp, {x=33, y=18})
    bg:addChild(temp)
    
    temp = UI.createLabel(StringManager.getString("titleAchievement"), General.font3, 30, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
    screen.autoSuitable(temp, {x=360, y=489, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createButton(CCSizeMake(47, 46), display.closeDialog, {image="images/buttonClose.png"})
    screen.autoSuitable(temp, {x=680, y=488, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    
    if General.useGameCenter then
        temp = UI.createSpriteWithFile("images/gamecenterIcon.png",CCSizeMake(42, 43))
        screen.autoSuitable(temp, {x=628, y=36})
        bg:addChild(temp)
        temp = UI.createLabel(StringManager.getString("labelGameCenterAchieve"), General.font1, 13, {colorR = 0, colorG = 0, colorB = 0})
        screen.autoSuitable(temp, {x=614, y=55, nodeAnchor=General.anchorRight})
        bg:addChild(temp)
        local buttonW = 120
        local w = temp:getContentSize().width * temp:getScaleX() + buttonW/2
        temp = UI.createButton(CCSizeMake(buttonW, 42), showGameCenterAchievements, {image="images/buttonGreen.png", fontSize=16, fontName=General.font3, text=StringManager.getString("buttonAchievementsMore")})
        screen.autoSuitable(temp, {x=610-w, y=55, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
    end
    
    display.showDialog({view=bg}, true)
    
    if GuideLogic.step==13 and GuideLogic.pointer then
		GuideLogic.clearPointer()
		GuideLogic.step = 14
		GuideLogic.complete = true
		display.getCurrentScene():checkCanBuild()
		ChatRoom.showNotice()
	end
end
