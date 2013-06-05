ZombieResultDialog = class()

function ZombieResultDialog:enterReplayScene()
    -- doNothing
    ReplayLogic.isZombie = true
	display.runScene(ReplayScene.new(), PreBattleScene)
end

function ZombieResultDialog:ctor(result)
    music.playBackgroundMusic(nil)
    music.playEffect("music/afterBattle.mp3")
    
	self.view = CCNode:create()
	self.view:setContentSize(General.winSize)
	screen.autoSuitable(self.view, {screenAnchor=General.anchorCenter})
	local temp
	local array
	
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_A8)
	temp = UI.createSpriteWithFile("images/dialogItemBattleResultBgB.png",CCSizeMake(1024, 478))
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	screen.autoSuitable(temp, {screenAnchor=General.anchorLeftBottom, x=0, y=0, scaleType=screen.SCALE_WIDTH_FIRST})
	self.view:addChild(temp)
	temp = UI.createButton(CCSizeMake(62, 42), self.enterReplayScene, {callbackParam=self, image="images/battleEndVideo.png"})
	screen.autoSuitable(temp, {screenAnchor=General.anchorRightBottom, nodeAnchor=General.anchorCenter, x=-80, y=58, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelBattleEndVideo"), General.font1, 15, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {screenAnchor=General.anchorRightBottom, x=-10, y=21, nodeAnchor=General.anchorRight, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(temp)

	local bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(1024, 768))
	screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType=screen.SCALE_CUT_EDGE})
	self.view:addChild(bg)
	
	local s = bg:getScale()
	
	bg:setScale(0.5*s)
	bg:runAction(CCEaseBackOut:create(CCScaleTo:create(0.1, s, s)))
	
	local numberToTime = getParam("actionTimeNumberTo", 1000)/1000
	
	temp = UI.createButton(CCSizeMake(169, 65), display.popScene, {callbackParam=PreBattleScene, image="images/buttonGreen.png", text=StringManager.getString("buttonReturnHome"), fontSize=RETURN_BUTTON_SIZE, fontName=General.font3, lineOffset=-12})
	screen.autoSuitable(temp, {x=512, y=133, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	if ZombieLogic.isGuide then
        temp = UI.createGuidePointer(90)
        temp:setPosition(600, 133)
        bg:addChild(temp)
        
	    ZombieLogic.isGuide = nil
	end
	temp = UI.createLabel(StringManager.getString("labelZombieGot"), General.font1, 15, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=512, y=439, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelZombieLost"), General.font1, 15, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=512, y=260, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	temp = UI.createLabel("0", General.font4, 30, {colorR = 250, colorG = 61, colorB = 4})
    screen.autoSuitable(temp, {x=524, y=404, nodeAnchor=General.anchorRight})
    bg:addChild(temp)
	temp:runAction(CCNumberTo:create(numberToTime, 0, -result.losePerson, "", ""))
    temp = UI.createSpriteWithFile("images/person.png",CCSizeMake(47, 36))
    screen.autoSuitable(temp, {x=529, y=385})
    bg:addChild(temp)
    for i=1, 3 do
    	temp = UI.createSpriteWithFile("images/dialogItemBattleResultSeperator.png",CCSizeMake(665, 2))
    	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=512, y=433-53*i})
    	bg:addChild(temp)
    end
	ResourceLogic.changeResource("person", -result.losePerson)
	local crystal = (result.stars==3 and 1) or 0
	temp = UI.createLabel(tostring(crystal), General.font4, 30, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=524, y=352, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	--temp:runAction(CCNumberTo:create(numberToTime, 0, , "", ""))
	temp = UI.createScaleSprite("images/crystal.png",CCSizeMake(60, 36))
	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=554, y=337})
	bg:addChild(temp)
	CrystalLogic.changeCrystal(crystal)
	local sspace = 0
	
	local items = {}
	local zombieNum = 0
	for i=1, 8 do
	    local znum = result.killZombies[i]
	    if znum>0 then
	        zombieNum = zombieNum + znum
	        table.insert(items, {id=i, num=znum})
	    end
	end
	
	if result.stars>0 then
	    local tempPercent = {0.5, 0.8, 1}
	    local zspace = math.floor(getParam("zombieWinSpace" .. UserData.level, 10) * tempPercent[result.stars])
	    local zombies = {}
	    for i=#items, 1, -1 do
	        local item = items[i]
	        local sinfo = StaticData.getSoldierInfo(item.id+10)
	        local num = squeeze(math.floor((0.8+math.random()*0.4)*zspace/sinfo.space/i),0,item.num)
	        if i==1 then num=squeeze(zspace,0,item.num) end
	        while num*sinfo.space > zspace do
	            num = math.floor(num/2)
	        end
	        if num>0 then
	            table.insert(zombies, {id=item.id+10, num=num})
	            zspace = zspace-num*sinfo.space
	            sspace = sspace+num*sinfo.space
	        end
	    end
	    print(json.encode(zombies))
	    SoldierLogic.incZombies(zombies)
	end
	
	temp = UI.createSpriteWithFile("images/zombie.png",CCSizeMake(32, 40))
    screen.autoSuitable(temp, {x=545, y=281})
    bg:addChild(temp)
	
	temp = UI.createLabel("0", General.font4, 30, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=524, y=300, nodeAnchor=General.anchorRight})
    bg:addChild(temp)
	temp:runAction(CCNumberTo:create(numberToTime, 0, sspace, "", ""))
	
	for i=1, 12 do
		local cell = CCNode:create()
		cell:setContentSize(CCSizeMake(48, 63))
		screen.autoSuitable(cell, {x=142+52*i, y=179})
		bg:addChild(cell)
		if items[i] then
			temp = UI.createSpriteWithFile("images/dialogItemBattleResultItemB.png",CCSizeMake(48, 63))
			screen.autoSuitable(temp, {x=0, y=0})
			cell:addChild(temp)
			temp = UI.createScaleSprite("images/zombieHead" .. items[i].id .. ".png", CCSizeMake(50, 80))
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=24, y=32})
			cell:addChild(temp)
		else
			temp = UI.createSpriteWithFile("images/dialogItemBattleResultItemB.png",CCSizeMake(48, 63))
			screen.autoSuitable(temp, {x=0, y=0})
			cell:addChild(temp)
		end
	end

	temp = UI.createSpriteWithFile("images/battleEndLight.png")
	temp:setScale(7.5)
	temp:setOpacity(128)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=512, y=545})
	bg:addChild(temp)
	temp:runAction(CCRepeatForever:create(CCRotateBy:create(1, 20)))
	temp = UI.createSpriteWithFile("images/battleEndRibbon.png",CCSizeMake(605, 197))
	screen.autoSuitable(temp, {x=207, y=410})
	bg:addChild(temp)
	if result.stars>0 then
		temp = UI.createLabel(StringManager.getString("labelVictory"), General.font3, 35, {colorR = 97, colorG = 255, colorB = 49})
		screen.autoSuitable(temp, {x=512, y=516, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
	else
		temp = UI.createLabel(StringManager.getString("labelDefeat"), General.font3, 35, {colorR = 255, colorG = 97, colorB = 49})
		screen.autoSuitable(temp, {x=512, y=516, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
	end
	temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(139, 131))
	screen.autoSuitable(temp, {x=317, y=515})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(193, 183))
	screen.autoSuitable(temp, {x=413, y=534})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(139, 131))
	screen.autoSuitable(temp, {x=566, y=517})
	bg:addChild(temp)
	if result.stars>=1 then
		temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(142, 133))
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=388, y=581})
		bg:addChild(temp)
		local sx, sy = temp:getScaleX(), temp:getScaleY()
		temp:setScale(0)
		array=CCArray:create()
		array:addObject(CCDelayTime:create(0.1))
		array:addObject(CCEaseBackOut:create(CCScaleTo:create(0.3, sx, sy)))
		temp:runAction(CCSequence:create(array))
		if result.stars>=2 then
			temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(196, 185))
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=512, y=625})
			bg:addChild(temp,1)
			temp:setScale(0)
			array=CCArray:create()
			array:addObject(CCDelayTime:create(0.4))
			array:addObject(CCEaseBackOut:create(CCScaleTo:create(0.3, 1, 1)))
			temp:runAction(CCSequence:create(array))
			if result.stars==3 then
				temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(142, 133))
				screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=637, y=581})
				bg:addChild(temp)
				temp:setScale(0)
				array=CCArray:create()
				array:addObject(CCDelayTime:create(0.7))
				array:addObject(CCEaseBackOut:create(CCScaleTo:create(0.3, sx, sy)))
				temp:runAction(CCSequence:create(array))
			end
		end
	end
	temp = UI.createLabel(StringManager.getString("damagePercent2"), General.font2, 17, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=512, y=630, nodeAnchor=General.anchorCenter})
	bg:addChild(temp, 2)
	temp = UI.createLabel("0%", General.font4, 25, {colorR = 111, colorG = 164, colorB = 74})
	screen.autoSuitable(temp, {x=512, y=600, nodeAnchor=General.anchorCenter})
	bg:addChild(temp, 2)
	temp:runAction(CCNumberTo:create(numberToTime, 0, result.percent, "", "%"))

    if result.stars > 0 then
	    EventManager.sendMessage("EVENT_OTHER_OPERATION", {key="defend", type="Add"})
	end
	if zombieNum>0 then
    	EventManager.sendMessage("EVENT_OTHER_OPERATION", {key="zombie", type="Add", value=zombieNum})
    end
    local sc = display.getCurrentScene(1)
    for _, id in ipairs(BattleLogic.costTraps) do
        sc.builds[id].deleted = true
    end
end