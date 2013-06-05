require "Dialog.BattleResultDialog"

BattleMenuLayer = class()

local resourceTypes = {"oil", "food"}

local function cellSelect(item)
	item.delegate:selectItem(item)
end

local function updateBattleCell(bg, scrollView, item)
	bg:removeAllChildrenWithCleanup(true)
	if item.id>0 then
		simpleRegisterButton(bg, {callback=cellSelect, callbackParam=item, priority=display.MENU_BUTTON_PRI})
		item.view = bg
		local temp = UI.createSpriteWithFile("images/battleItemBg.png",CCSizeMake(81, 104))
		screen.autoSuitable(temp, {x=0, y=0})
		bg:addChild(temp)
		if item.type=="soldier" then
    		SoldierHelper.addSoldierHead(bg, item.id, 0.7)
			temp = UI.createStar(UserData.researchLevel[item.id], 17, 14)
			screen.autoSuitable(temp, {x=3, y=6})
			bg:addChild(temp)
		elseif item.type=="zombie" then
		    temp = UI.createSpriteWithFile("images/zombieTombIcon.png",CCSizeMake(41, 79))
            screen.autoSuitable(temp, {x=20, y=6})
            bg:addChild(temp)
		end
		temp = UI.createLabel("x" .. item.num, General.font4, 18, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
		screen.autoSuitable(temp, {x=40, y=90, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		item.numLabel = temp
	else
		local temp = UI.createSpriteWithFile("images/battleItemNone.png",CCSizeMake(81, 104))
		screen.autoSuitable(temp, {x=0, y=0})
		bg:addChild(temp)
	end
end

function BattleMenuLayer:ctor(scene, logic)
	self.scene = scene
	self.logic = logic
    local layer = CCTouchLayer:create(display.MENU_PRI, false)
    layer:setContentSize(General.winSize)
	self.view = layer
	
	self:initBottom()
	self:initLeftTop()
	self:initRightTop()
	self:initTop()
	
	simpleRegisterEvent(self.view, {update={inteval=0.2, callback=self.update}}, self)
end

function BattleMenuLayer:initTips()
    if BattleLogic.isGuide then
        local f = UI.createSpriteWithFile("images/guideFinger.png")
        local p = CCPointMake(2415, 1949)
        p = self.scene.ground:convertToWorldSpace(p)
        p = self.view:convertToNodeSpace(p)
        screen.autoSuitable(f, {nodeAnchor=General.anchorTop, x=p.x, y=p.y})
        self.view:addChild(f, 20000)
    	self.tipsNode = f
    else
    	local temp, bg = nil
    	bg = CCNode:create()
    	
        if not BattleLogic.isReverge then
    	    local nextCost = NEXT_COST[UserData.level]
        	temp = UI.createButton(CCSizeMake(187, 84), self.nextBattleScene, {callbackParam=self, image="images/buttonOrangeB.png", priority=display.MENU_BUTTON_PRI})
        	screen.autoSuitable(temp, {x=903, y=205, nodeAnchor=General.anchorCenter})
        	bg:addChild(temp)
        	
        	local temp1 = UI.createLabel(StringManager.getString("buttonNext"), General.font3, 25, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
        	screen.autoSuitable(temp1, {x=132, y=52, nodeAnchor=General.anchorCenter})
        	temp:addChild(temp1)
        	temp1 = UI.createSpriteWithFile("images/oil.png",CCSizeMake(20, 24))
        	screen.autoSuitable(temp1, {x=143, y=8})
        	temp:addChild(temp1)
        	temp1 = UI.createLabel(tostring(nextCost), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
        	screen.autoSuitable(temp1, {x=137, y=19, nodeAnchor=General.anchorRight})
        	temp:addChild(temp1)
        	temp1 = UI.createSpriteWithFile("images/findEnemyIcon.png",CCSizeMake(76, 53))
        	screen.autoSuitable(temp1, {x=8, y=12})
        	temp:addChild(temp1)
        end
    	
    	temp = UI.createLabel(StringManager.getString("battleTips"), General.font3, 28, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(458, 0), lineOffset=-12})
    	screen.autoSuitable(temp, {x=536, y=210, nodeAnchor=General.anchorCenter})
    	bg:addChild(temp)
    	self.time = 30
    	self.count = 3
    	self.tipsNode = bg
    end
end

function BattleMenuLayer:initRightTop()
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 256))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorRightTop})
	self.view:addChild(bg)
	
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=81, y=28})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(55, 54))
	screen.autoSuitable(temp, {x=186, y=11})
	bg:addChild(temp)
	temp = UI.createLabel(tostring(UserData.crystal), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=182, y=41, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	self.crystal = {valueLabel=temp, value=UserData.crystal}
	
	local items = {{"person", 160, 30, 163, 172, 74}, {"oil", 219, 29, 225, 188, 134}, {"food", 219, 29, 225, 193, 191}}
	for i=1, 3 do
		local resourceType = items[i][1]
		local item = {}
		--local filler = resourceType
		--if resourceType=="person" then filler="special" end
		
		temp = UI.createSpriteWithFile("images/normalFiller.png",CCSizeMake(items[i][2], items[i][3]))
		temp:setColor(RESOURCE_COLOR[resourceType])
		local dis = (items[i][4]-items[i][2])/2
		screen.autoSuitable(temp, {x=237-dis, y=24+i*59+dis, nodeAnchor=General.anchorRightBottom})
		bg:addChild(temp)
		item.filler = temp
		UI.registerAsProcess(temp, item)
		temp = UI.createSpriteWithFile("images/fillerBottom.png",CCSizeMake(items[i][4], 34))
		screen.autoSuitable(temp, {x=237-items[i][4], y=24+i*59})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/" .. resourceType .. ".png")
		screen.autoSuitable(temp, {x=items[i][5], y=items[i][6]})
		bg:addChild(temp)
		item.value = ResourceLogic.getResource(resourceType)
		item.max = ResourceLogic.getResourceMax(resourceType)
		temp = UI.createLabel(tostring(item.value), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=182, y=39 + 59*i, nodeAnchor=General.anchorRight})
		bg:addChild(temp)
		item.valueLabel = temp
		temp = UI.createLabel(StringManager.getFormatString("resourceMax", {max=item.max}), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=243-items[i][4], y=67 + 59*i, nodeAnchor=General.anchorLeft})
		bg:addChild(temp)
		item.maxLabel = temp
		local lmax = item.max
		if lmax==0 then lmax=1 end
		UI.setProcess(item.filler, item, item.value/lmax, true)
		self[resourceType] = item
	end
end

function BattleMenuLayer:initLeftTop()

	local enemyName = self.scene.initInfo.name

	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 256))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorLeftTop})
	self.view:addChild(bg)
	
	self.stolenResources = {}
	temp = UI.createLabel("0", General.font4, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=70, y=133, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	self.stolenResources["oil"] = {resource=0, label=temp}
	temp = UI.createSpriteWithFile("images/oil.png",CCSizeMake(27, 31))
	screen.autoSuitable(temp, {x=35, y=117})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/food.png",CCSizeMake(26, 34))
	screen.autoSuitable(temp, {x=38, y=148})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(29, 35))
	screen.autoSuitable(temp, {x=35, y=80})
	bg:addChild(temp)
	temp = UI.createLabel(tostring(BattleLogic.scores[1]), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=71, y=98, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelAvaliable"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=71, y=191, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelDefeat"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=71, y=64, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel("0", General.font4, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=71, y=166, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	self.stolenResources["food"] = {resource=0, label=temp}
	temp = UI.createLabel(tostring(BattleLogic.scores[2]), General.font4, 20, {colorR = 255, colorG = 190, colorB = 189, lineOffset=-12})
	screen.autoSuitable(temp, {x=71, y=42, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(29, 35))
	screen.autoSuitable(temp, {x=36, y=24})
	bg:addChild(temp)
	temp = UI.createLabel(enemyName, General.font3, 22, {colorR = 255, colorG = 255, colorB = 231, lineOffset=-12})
    screen.autoSuitable(temp, {x=39, y=221, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
end

function BattleMenuLayer:initBottom()
	local temp, bg = nil
	bg = CCNode:create()
	screen.autoSuitable(bg, {screenAnchor=General.anchorLeftBottom, scaleType=screen.SCALE_WIDTH_FIRST})
	self.view:addChild(bg)
	
	self:initTips()
	if not self.tipsNode:getParent() then
    	bg:addChild(self.tipsNode)
    end
	
	temp = UI.createSpriteWithFile("images/battleStarBg.png",CCSizeMake(183, 94))
	screen.autoSuitable(temp, {x=14, y=157})
	bg:addChild(temp)
	local stars = {}
	for i=1, 3 do
		temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(29, 27))
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=46+i*30, y=212})
		bg:addChild(temp)
		stars[i] = temp
	end
	self.stars = stars
	self.starsNum = 0
	
	temp = UI.createLabel("0%", General.font4, 30, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=106, y=181, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.percent = 0
	self.percentLabel = temp
	self.shieldHour = 0
	
	temp = UI.createLabel(StringManager.getString("damagePercent"), General.font1, 16, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=108, y=234, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	temp = UI.createSpriteWithFile("images/battleListBg.png",CCSizeMake(995, 135))
	screen.autoSuitable(temp, {x=14, y=14})
	bg:addChild(temp)
	
	local items = {}
    for i=1, 10 do
        local num = SoldierLogic.getSoldierNumber(i) or 0
        --local num = 200
        if num>0 then
            --SoldierLogic.getSoldierNumber(i)
			table.insert(items, {id=i, num=num, level=UserData.researchLevel[i], type="soldier", delegate=self})
        end
    end
    if BattleLogic.isGuide then
        table.insert(items, {id=9, num=3, level=1, type="soldier", delegate=self})
    end
    if SoldierLogic.getCurZombieSpace()>0 then
        local item = {type="zombie", id=1, num=1, level=SoldierLogic.getMaxZombieCampLevel(), delegate=self}
        --for
        table.insert(items, item)
    end
	local length = #items
	local movable = false
	if length<11 then
		for i=length+1, 11 do
			table.insert(items, {id=0})
		end
	elseif length>10 then
		movable = true
	end
	self.items = items
	local scrollView = UI.createScrollViewAuto(CCSizeMake(995, 135), true, {priority=display.MENU_PRI, size=CCSizeMake(81, 104), infos=items, offx=28, offy=17, disx=6, dismovable=not movable, cellUpdate=updateBattleCell})
	screen.autoSuitable(scrollView.view)
	temp:addChild(scrollView.view)
	if length>0 then
		self:selectItem(items[1])
	end
end

function BattleMenuLayer:initTop()
	local temp, bg = nil
	if BattleLogic.isGuide then return end
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 128))
	screen.autoSuitable(bg, {screenAnchor=General.anchorTop, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(bg)
	
	temp = UI.createLabel(StringManager.getTimeString(30), General.font4, 30, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=128, y=16, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.timeLabel = temp
	temp = UI.createLabel(StringManager.getString("labelBattleStartIn"), General.font2, 16, {colorR = 255, colorG = 215, colorB = 214})
	screen.autoSuitable(temp, {x=128, y=44, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.timeTypeLabel = temp
	temp = UI.createButton(CCSizeMake(133, 48), self.endBattle, {callbackParam=self, image="images/buttonEnd.png", text=StringManager.getString("buttonEndBattle"), fontSize=22, fontName=General.font3, priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {x=128, y=82, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
end

function BattleMenuLayer:nextBattleScene()
	-- TODO
	local cost = NEXT_COST[UserData.level]
	if ResourceLogic.checkAndCost({costType="oil", costValue=cost}, self.nextBattleScene, self) then
	    local scene = BattleScene.new()
    	display.runScene(scene, PreBattleScene)
    end
end

function BattleMenuLayer:endBattle(forceEnd)
	if self.troopsCost then
		if forceEnd then
			BattleLogic.battleEnd = true
	        self.time = nil
		else
			display.showDialog(AlertDialog.new(StringManager.getString("alertTitleEndBattle"), StringManager.getString("alertTextEndBattle"), {callback=self.endBattle, param=true}, self))
		end
	else
	    self.time = nil
		display.popScene(PreBattleScene)
	end
end

function BattleMenuLayer:beginBattle()
	self.battleBegin = true
	if self.tipsNode then
		self.tipsNode:removeFromParentAndCleanup(true)
		self.tipsNode = nil
        self.scene.battleBegin = true
        local areaAlpha = getParam("buildingAreaAlpha", 38)
        local lineAlpha = getParam("buildingLineAlpha", 100)
        self.scene.mapGridView.blockBatch:runAction(CCAlphaTo:create(0.5, areaAlpha, 0))
        self.scene.mapGridView.linesBatch:runAction(CCAlphaTo:create(0.5, lineAlpha, 0))
        
		music.playBackgroundMusic("music/inBattle.mp3")
	end
	
	ReplayLogic.beginTime = timer.getTime()-1
	local seed = os.time()
	math.randomseed(seed)
		
	ReplayLogic.initWriteReplay(seed)
	ReplayLogic.buildData = self.scene.initInfo	
	
	if not BattleLogic.isGuide then
    	self.timeTypeLabel:setString(StringManager.getString("labelBattleEndIn"))
    	self.time = 180
    	self.count = nil
    end
end

function BattleMenuLayer:executeSelectItem(touchPoint)
	local item = self.selectedItem
	if not BattleLogic.battleEnd and item then
		if item.num==0 then
			display.pushNotice(UI.createNotice(StringManager.getString("noticeSelectItemEmpty")))
			return false
		end
		if item.type=="soldier" then
			local p = self.scene.ground:convertToNodeSpace(CCPointMake(touchPoint[1], touchPoint[2]))
			local grid = self.scene.mapGridView:convertToGrid(p.x, p.y)
			
			local inBigArea = (grid.gridPosX>=-1 and grid.gridPosX<=42 and grid.gridPosY>=-1 and grid.gridPosY<=42)
			if inBigArea and self.scene.mapGridView:checkGridEmpty(GridKeys.Build, grid.gridPosX, grid.gridPosY, 1) and not self.scene.mapGrid:getGrid(GridKeys.Build, grid.gridPosX, grid.gridPosY) then
    			local soldier = SoldierHelper.create(item.id, {isFighting=true, level=item.level})
    			BattleLogic.id = (BattleLogic.id or 0)+1
    			soldier.id = BattleLogic.id
    			local x, y = math.floor(p.x), math.floor(p.y)
    			soldier:addToScene(self.scene, {x, y})
    			soldier:playAppearSound()
    			table.insert(self.scene.soldiers, soldier)
    			if not self.battleBegin then
    				self:beginBattle()
    			end
    			self.troopsCost = true
    			table.insert(ReplayLogic.cmdList, {math.floor((timer.getTime()-ReplayLogic.beginTime)*1000)/1000, "s", item.id, x, y, item.level})
    			BattleLogic.incSoldier(item.id)
    		else
			    display.pushNotice(UI.createNotice(StringManager.getString("noticeAreaError")))
			    if self.battleBegin then
        		    self.scene:showBuildingArea()
        		end
    		    return false
    		end
    	elseif item.type=="zombie" then
    	
			local p = self.scene.ground:convertToNodeSpace(CCPointMake(touchPoint[1], touchPoint[2]))
			local grid = self.scene.mapGridView:convertToGrid(p.x, p.y)
			
			if self.scene.mapGridView:checkGridEmpty(GridKeys.Build, grid.gridPosX, grid.gridPosY, 2) and self.scene.mapGrid:checkGridEmpty(GridKeys.Build, grid.gridPosX, grid.gridPosY, 2) then
			    local zombieTomb = ZombieTomb.new(1004, {level=item.level})
			    zombieTomb:addToScene(self.scene, {initGridX=grid.gridPosX, initGridY=grid.gridPosY})
			    --add action here
			    local b = zombieTomb.buildView.build
			    local height=getParam("actionTombHeight", 104)
			    b:setPositionY(height+28)
			    b:runAction(CCEaseBackIn:create(CCMoveBy:create(0.4, CCPointMake(0, -height))))
    			if not self.battleBegin then
    				self:beginBattle()
    			end
    			self.troopsCost = true
    			table.insert(ReplayLogic.cmdList, {timer.getTime()-ReplayLogic.beginTime, "zb", grid.gridPosX, grid.gridPosY, item.level})
    			BattleLogic.deployZombie()
    		else
			    display.pushNotice(UI.createNotice(StringManager.getString("noticeAreaError")))
			    if self.battleBegin then
        		    self.scene:showBuildingArea()
        		end
    		    return false
    		end
		end
		item.num = item.num-1
    	item.numLabel:setString("x" .. item.num)
		if item.num==0 then
			item.view:setSatOffset(-100)
			self:checkSoldierEmpty()
		end
		return true
	end
end

function BattleMenuLayer:checkSoldierEmpty()
    local items = self.items
    local isEmpty = true
    for i=1, #items do
        if items[i].id~=0 and items[i].num>0 then
            isEmpty = false
            break
        end
    end
    if isEmpty then
        self.soldierEmpty = true
    end
end

function BattleMenuLayer:selectItem(item)
	if self.selectedItem ~= item then
		if self.selectedItem then
			local r = self.selectedItem.view:getChildByTag(10)
			if r then
				r:removeFromParentAndCleanup(true)
			end
		end
		self.selectedItem = item
		local temp = UI.createSpriteWithFile("images/battleItemSelected.png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, x=-3, y=-3})
		item.view:addChild(temp, 1, 10)
	end
end

function BattleMenuLayer:update(diff)
    if display.isSceneChange then return end
	if self.percent ~= BattleLogic.percent then
		self.percent = BattleLogic.percent
		self.percentLabel:setString(self.percent .. "%")
	end
	if self.shieldHour ~= BattleLogic.shieldHour then
	    print("test")
	    self.shieldHour = BattleLogic.shieldHour
	    display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeBattleShieldTime", {hour=self.shieldHour}), 255))
	end
	if self.time then
		self.time = self.time - diff
		self.timeLabel:setString(StringManager.getTimeString(self.time))
		if self.time < 0 then
			if self.battleBegin then
				self:endBattle(true)
			else
				self:beginBattle()
			end
		end
		if self.count and self.count>0 and self.time <= self.count+1 then
			local temp = UI.createSpriteWithFile("images/count" .. self.count .. ".png")
			temp:setScale(0.01)
			screen.autoSuitable(temp, {screenAnchor=General.anchorCenter})
			self.view:addChild(temp, 10)
			temp:runAction(CCScaleTo:create(0.25, 1, 1))
			delayRemove(1, temp)
			self.count = self.count - 1
		end
	end
	if self.starDelay then
		self.starDelay = self.starDelay-diff
		if self.starDelay<=0 then
			self.starDelay = nil
		end
	else
		if self.starsNum < BattleLogic.stars then
			self.starsNum = self.starsNum + 1
			local star = UI.createSpriteWithFile("images/battleStar0.png")
			local oldStar = self.stars[self.starsNum]
			local starBack = oldStar:getParent()
			local p = starBack:convertToNodeSpace(CCPointMake(General.winSize.width/2, General.winSize.height*435/768))
			screen.autoSuitable(star, {nodeAnchor=General.anchorCenter, x=p.x, y=p.y})
			starBack:addChild(star)
			star:setScale(0)
			
			local array = CCArray:create()
			array:addObject(CCEaseBackOut:create(CCScaleTo:create(0.5, 1, 1)))
			array:addObject(CCDelayTime:create(0.5))
			
			local sarray = CCArray:create()
			local x, y = oldStar:getPosition()
			sarray:addObject(CCMoveTo:create(0.5, CCPointMake(x, y)))
			local sx, sy = oldStar:getScaleX(), oldStar:getScaleY()
			sarray:addObject(CCScaleTo:create(0.5, sx, sy))
			
			array:addObject(CCSpawn:create(sarray))
			array:addObject(CCScaleTo:create(0.1, 1.1*sx, 1.1*sy))
			array:addObject(CCScaleTo:create(0.1, sx, sy))
			
			star:runAction(CCSequence:create(array))
			
			local label = UI.createLabel(StringManager.getString("labelStar" .. self.starsNum), General.font3, 33)
			screen.autoSuitable(label, {nodeAnchor=General.anchorTop, x=p.x, y=p.y-123})
			starBack:addChild(label)
			array = CCArray:create()
			array:addObject(CCDelayTime:create(1))
			array:addObject(CCFadeOut:create(0.5))
			label:runAction(CCSequence:create(array))
			delayRemove(1.5, label)
		end
	end
	self:updateOthers()
end

function BattleMenuLayer:updateOthers()
	for i=1, 2 do
		local resourceType = resourceTypes[i]
		local item = self[resourceType]
		local fillerUpdate = false
		if BattleLogic.getResource(resourceType) ~= item.value then
			fillerUpdate = true
			item.value = BattleLogic.getResource(resourceType)
			item.valueLabel:setString(tostring(item.value))
		end
		if fillerUpdate then
			local lmax = item.max
			if lmax==0 then lmax=1 end
		    UI.setProcess(item.filler, item, item.value/lmax, true)
		end
		
		if BattleLogic.getLeftResource(resourceType) ~= self.stolenResources[resourceType].resource then
			self.stolenResources[resourceType].resource = BattleLogic.getLeftResource(resourceType)
			self.stolenResources[resourceType].label:setString(tostring(self.stolenResources[resourceType].resource))
		end
	end
	
	if self.soldierEmpty then
	    if not self.emptyCD or self.emptyCD<timer.getTime() then
	        self.emptyCD = timer.getTime()+1
	        local soldierNum = self.scene:countSoldier()
	        if soldierNum==0 then
	            self:endBattle(true)
	        end
	    end
	end
	
	if BattleLogic.battleEnd and not self.battleEnd then
		self.battleEnd = true
		table.insert(ReplayLogic.cmdList, {timer.getTime() - ReplayLogic.beginTime, "e"})
		-- 不立即显示结束对话框，给一定的缓冲
		delayCallback(2, self.showEndBattleDialog, self)
	end
end

function BattleMenuLayer:showEndBattleDialog()
    --ReplayLogic.makeReplayResult("battle.txt")
	self.view:removeFromParentAndCleanup(true)
	display.showDialog(BattleResultDialog.new(BattleLogic.getBattleResult()), false)
end

