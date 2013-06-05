BuildMould = class()

function BuildMould:ctor(bid, setting)
	self.initSetting = setting
    self.buildIndex = setting.buildIndex or 1
    if self.initWithSetting then
    	self:initWithSetting(setting)
    end
	self.buildInfo = StaticData.getBuildInfo(bid)
	self.buildLevel = (setting.level or 1)
	
	if (setting.time or 0) > 0 then
		self.buildState = BuildStates.STATE_BUILDING
		self.buildEndTime = timer.getTime(setting.time)
		local tdata = StaticData.getBuildData(bid, self.buildLevel+1)
		if tdata then
    		self.buildTotalTime = tdata.time
        else
            self.buildTotalTime = self.buildData.time
        end
	else
		self.buildState = BuildStates.STATE_FREE
	end
	if self.buildLevel == 0 then
	    if self.buildState == BuildStates.STATE_FREE then
    	    local tempBuildData = StaticData.getBuildData(bid, 1)
	        self.buildData = {bid=bid, level=0, hitPoints=0, gridSize=tempBuildData.gridSize, soldierSpace=tempBuildData.soldierSpace}
	    else
	        self.buildData = StaticData.getBuildData(bid, 1)
	    end
	else
	    self.buildData = StaticData.getBuildData(bid, self.buildLevel)
	end
end

function BuildMould:enterOperation()

end

function BuildMould:onFocus()

end

function BuildMould:onGridReset()

end

function BuildMould:onEnterScene()
	local scene = self.buildView.scene
	if scene.sceneType==SceneTypes.Operation or (self.supportVisit and scene.sceneType==SceneTypes.Visit) then
		self:enterOperation()
	elseif scene.sceneType==SceneTypes.Battle then
		if not self.buildContinue and self.buildData.hitPoints>0 then
			local battleData = {max=self.buildData.hitPoints, hitpoints=self.buildData.hitPoints}
			--0级是不会有资源的
			if self.buildLevel>0 and self.getBattleResource then
				battleData.resources = self:getBattleResource()
			end
			BattleLogic.addBuild(self.id, battleData)
		end
		--BattleLogic.id = (BattleLogic.id or 0)+1
		--self.buildView.id = BattleLogic.id
		if self.enterBattle then
			self:enterBattle()
		end
	elseif scene.sceneType==SceneTypes.Zombie then
		if not self.buildContinue and self.buildData.hitPoints>0 then
		    local bid = self.buildData.bid
		    self.destroyPercent = true
		    ZombieLogic.buildNum = ZombieLogic.buildNum + 1
    		local percent = getParam("populationPercent" .. bid, 0)
    		if self.enterZombie then
    			self:enterZombie()
    		end
    		self.personNum = percent
		    ZombieLogic.changePerson(percent)
		end
		if self.enterBattle then
			self:enterBattle()
		end
	end
end

function BuildMould:addToScene(scene, setting)
    setting = setting or self.initSetting
	BuildView.new(self, scene, setting)

	if not setting.isBuying then
		self:onEnterScene()
	end
end

function BuildMould:onZombieDamage()
	if self.builder then
		self:releaseBuilder()
	end
	if self.destroyPercent then
    	ZombieLogic.changePerson(-self.personNum)
    	ZombieLogic.destroyBuild(self.buildData.bid)
    end
end

function BuildMould:repair()
	if ZombieLogic.getBuilder()==0 then
		display.pushNotice(UI.createNotice(StringManager.getString("noBuilder")))
	elseif self.buildView.hitpoints==self.buildData.hitPoints then
		display.pushNotice(UI.createNotice(StringManager.getString("maxHitpoints")))
	elseif not self.deleted then
		self:callBuilder()
		if self.buildView.state.isFocus then
			self.buildView:setFocus(false)
			self.buildView:setFocus(true)
		end
		
		table.insert(ReplayLogic.cmdList, {timer.getTime()-ReplayLogic.beginTime, "r", self.id})
	end
end

function BuildMould:cancelRepair()
	if self.builder then
		self:releaseBuilder()
		table.insert(ReplayLogic.cmdList, {timer.getTime()-ReplayLogic.beginTime, "c", self.id})
		if self.buildView.state.isFocus then
			self.buildView:setFocus(false)
			self.buildView:setFocus(true)
		end
	end
end

function BuildMould:removeFromScene()
	if self.buildView then
		local grid = self.buildView.state.backGrid
		self.initSetting = {initGridX=grid.gridPosX, initGridY=grid.gridPosY}
		if self.buildView.scene.sceneType==SceneTypes.Operation then
    		if self.getExtendInfo then
    		    local info = self:getExtendInfo()
    		    if info then
        		    for k, v in pairs(info) do
        		        self.initSetting[k] = v
        		    end
        		end
    		end
    		if self.builder then
    		    --self.builder.view:removeFromParentAndCleanup(true)
    		    self.builder = nil
    		end
		end
		self.buildView:removeView()
		self.buildView = nil
	end
end

function BuildMould:getBaseInfo()
	local baseInfo = {bid=self.buildData.bid, level=self.buildLevel, hitpoints=self.buildData.hitPoints}
	if self.buildView then
		baseInfo.grid=self.buildView.state.backGrid.gridPosX*10000+self.buildView.state.backGrid.gridPosY
	else
		baseInfo.grid=self.initSetting.initGridX *10000 + self.initSetting.initGridY
	end
	if self.getExtendInfo then
		baseInfo.extend = self:getExtendInfo()
	end
	if self.buildState == BuildStates.STATE_BUILDING then
		baseInfo.time = timer.getServerTime(self.buildEndTime)
	else
		baseInfo.time = 0
	end
	return baseInfo
end

function BuildMould:beginUpgrade()
    if self.buildState==BuildStates.STATE_BUILDING then return end
	local bdata = StaticData.getBuildData(self.buildData.bid, self.buildLevel+1)
	if bdata.needLevel > UserData.level then
		display.pushNotice(UI.createNotice(StringManager.getFormatString("needLevel", {level=bdata.needLevel, name=StringManager.getString("dataBuildName" .. TOWN_BID)})))
	elseif bdata.time>0 and ResourceLogic.getResource("builder")==0 then
		display.pushNotice(UI.createNotice(StringManager.getString("noBuilder")))
	elseif self.needPerson and ResourceLogic.getResource("person")<bdata.extendValue2 then
	    if bdata.extendValue2 > ResourceLogic.getResourceMax("person") then
    		display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeErrorResourceMax", {name=StringManager.getString("dataBuildName" .. RESOURCE_BUILD_BIDS["person"])})))
        else
    		local num = bdata.extendValue2 - ResourceLogic.getResource("person")
    		local resource = StringManager.getString("person")
    		local cost = CrystalLogic.computeCostByResource("person", num)
    		display.showDialog(AlertDialog.new(StringManager.getFormatString("alertTitleNoResource", {resource=resource}), StringManager.getFormatString("alertTextNoResource", {resource=resource, num=num}),
    		    {callback=ResourceLogic.buyResourceAndCallback, param={resource="person", get=num, cost=cost, callback=self.beginUpgrade, callbackParam=self}, crystal=cost}))
    	end
	elseif ResourceLogic.checkAndCost(bdata, self.beginUpgrade, self) then
		if bdata.time>0 then
			if self.beforeUpgrade then
    		    self:beforeUpgrade()
    		    print("Test suc")
    		end
			self.buildEndTime = timer.getTime() + bdata.time
			self.buildTotalTime = bdata.time
			self.buildState = BuildStates.STATE_BUILDING
			if self.buildView then
				self.buildView:resetBuildView()
			end
			self:callBuilder()
		else
			self:upgradeOver()
		end
		display.closeDialog()
	end
end

function BuildMould:upgradeOver()
	music.playEffect("music/buildFinish.mp3")
	self.buildState = BuildStates.STATE_FREE
	local endTime = self.buildEndTime
	self.buildEndTime = nil
	self.buildTotalTime = nil
	self.buildLevel = self.buildLevel + 1
	local buildData = StaticData.getBuildData(self.buildData.bid, self.buildLevel)
	self.buildData = buildData
	self:enterOperation()
	if self.buildView then
		self.buildView:resetBuildView()
		self.buildView.state.nightMode = false
	end
	local t = getParam("buildFinishTime", 1000)/1000
	local item = UI.createAnimateWithSpritesheet(t, "buildFinish_", 10, {plist="animate/build/buildFinish.plist", isRepeat=false})
	item:setScale(self.buildData.gridSize*4/5)
	screen.autoSuitable(item, {nodeAnchor=General.anchorBottom, x=self.buildView.view:getContentSize().width/2, y=0})
	self.buildView.view:addChild(item, 100)
	self.buildView.hitpoints = buildData.hitPoints
	if self.blood then
		self.blood.max = buildData.hitPoints
		self.blood:changeValue(buildData.hitPoints)
	end
	delayRemove(t, item)
	
	--UserData.changeValue("exp", math.floor(math.sqrt(buildData.time)))
	if self.afterUpgrade then
	    self:afterUpgrade(endTime)
	end
	EventManager.sendMessage("EVENT_BUILD_UPDATE", {bid = self.buildData.bid, level=self.buildLevel})
end
	
function BuildMould:accBuild(force)
    if self.buildState~=BuildStates.STATE_BUILDING then return end
    local leftTime = self.buildEndTime - timer.getTime()
    local accCost = CrystalLogic.computeCostByTime(math.ceil(leftTime))
    if force then
        if CrystalLogic.changeCrystal(-accCost) then
            self.buildEndTime = timer.getTime()
            self:releaseBuilder()
            self:upgradeOver()
            UserStat.addCrystalLog(CrystalStatType.ACC_BUILD, timer.getTime(), accCost, self.buildData.bid)
        end
    else
        local name = StringManager.getString("dataBuildName" .. self.buildData.bid)
        local textKey
        if self.buildLevel==0 then
            textKey="alertTextFinishBuilding"
        else
            textKey="alertTextFinishUpgrade"
        end
        display.showDialog(AlertDialog.new(StringManager.getString("alertTitleFinish"), StringManager.getFormatString(textKey, {num=accCost, name=name}), {callback=self.accBuild, param=true, crystal=accCost}, self))
    end
end

function BuildMould:deleteBuild()
	self.deleted = true
	Build.decBuild(self.buildData.bid)
end

function BuildMould:sell(force)
	local bdata = self.buildData
	if force then
    	ResourceLogic.changeResource(bdata.costType, math.floor(bdata.costValue/5))
    	if self.builder then
    		self:releaseBuilder()
    	end
    	self:deleteBuild()
    	self:removeFromScene()
    else
        local name = StringManager.getString("dataBuildName" .. self.buildData.bid)
        local resource = StringManager.getString(bdata.costType)
        display.showDialog(AlertDialog.new(StringManager.getString("alertTitleSell"), StringManager.getFormatString("alertTextSell", {name=name, num=math.floor(bdata.costValue/5), resource=resource}), {callback=self.sell, param=true}, self))
    end
end

function BuildMould:cancelBuild(force)
    if self.buildState~=BuildStates.STATE_BUILDING then return end
    if force then
    	self.buildState = BuildStates.STATE_FREE
    	self.buildEndTime = nil
    	self.buildTotalTime = nil
    	local bdata = StaticData.getBuildData(self.buildData.bid, self.buildLevel+1)
    	ResourceLogic.changeResource(bdata.costType, math.floor(bdata.costValue/2))
    	self:releaseBuilder()
    	if self.buildLevel==0 then
    		self:deleteBuild()
    		self:removeFromScene()
    	elseif self.buildView then
    		self.buildView:resetBuildView()
    	end
    else
        local keys
        if self.buildLevel==0 then
            keys = {"alertTitleCancelBuilding", "alertTextCancelBuilding"}
        else
            keys = {"alertTitleCancelUpgrade", "alertTextCancelUpgrade"}
        end
        local name = StringManager.getString("dataBuildName" .. self.buildData.bid)
        display.showDialog(AlertDialog.new(StringManager.getString(keys[1]), StringManager.getFormatString(keys[2], {name=name}), {callback=self.cancelBuild, param=true}, self))
    end
end

function BuildMould:buyAtOnce()
    if ResourceLogic.checkAndCost(self.buildData, self.buyAtOnce, self) then
        self.deleted = nil
        if self.buildData.time>0 then
        	self.buildLevel = 0
        	self.buildState = BuildStates.STATE_BUILDING
        	self.buildEndTime = timer.getTime() + self.buildData.time
        	self.buildTotalTime = self.buildData.time
            self:addToScene(self.scene)
            self.scene = nil
        	self:callBuilder()
        else
            self:addToScene(self.scene)
        	self:enterOperation()
        	if self.buildData.bid==2004 then
		        UserStat.addCrystalLog(CrystalStatType.BUY_BUILDER, timer.getTime(), self.buildData.costValue)
        	end
        	EventManager.sendMessage("EVENT_BUILD_UPDATE", {bid = self.buildData.bid, level=1})
        end
        		
        Build.incBuild(self.buildData.bid)
        table.insert(self.buildView.scene.builds, self)
        return true
    end
end

function BuildMould:beginBuy()
	if self.buildData.time>0 and ResourceLogic.getResource("builder")==0 then
		display.pushNotice(UI.createNotice(StringManager.getString("noBuilder")))
	else
	    --add someinfo to buy again
	    local grid = self.buildView.state.grid
	    self.scene = self.buildView.scene
    	self.initSetting.isBuying = nil
    	self.initSetting.initGridX = grid.gridPosX
    	self.initSetting.initGridY = grid.gridPosY
    	if ResourceLogic.checkAndCost(self.buildData, self.buyAtOnce, self) then
    	    --self.initSetting.isBuying = nil
    		if self.buildData.time>0 then
    			self.buildLevel = 0
    			self.buildState = BuildStates.STATE_BUILDING
    			self.buildEndTime = timer.getTime() + self.buildData.time
    			self.buildTotalTime = self.buildData.time
    			self:callBuilder()
    		else
    			self:enterOperation()
            	if self.buildData.bid==2004 then
    		        UserStat.addCrystalLog(CrystalStatType.BUY_BUILDER, timer.getTime(), self.buildData.costValue)
            	end
    			EventManager.sendMessage("EVENT_BUILD_UPDATE", {bid = self.buildData.bid, level=1})
    		end
    		
    		Build.incBuild(self.buildData.bid)
    		table.insert(self.buildView.scene.builds, self)
    		return true
    	end
    end
end

function BuildMould:callBuilder()
	if self.buildView.scene.sceneType==SceneTypes.Operation then
		ResourceLogic.changeResource("builder", -1)
	elseif self.buildView.scene.sceneType ==SceneTypes.Zombie then
		ZombieLogic.changeBuilder(-1)
	end
	for i, build in pairs(self.buildView.scene.builds) do
		if not build.deleted and build.buildData.bid==2004 and build.builder then
			local builder = build.builder
			build.builder = nil
			builder.home = nil
			builder.target = self
			self.builder = builder
			builder:randomBuild()
			break
		end
	end
end

function BuildMould:releaseBuilder()
	for i, build in pairs(self.buildView.scene.builds) do
		if not build.deleted and build.buildData.bid==2004 and not build.builder then
			local builder = self.builder
			self.builder = nil
			builder.home = build
			builder.target = nil
			build.builder = builder
			builder:returnHome()
			print("return hone")
			break
		end
	end
	if self.buildView.scene.sceneType==SceneTypes.Operation then
		ResourceLogic.changeResource("builder", 1)
	elseif self.buildView.scene.sceneType ==SceneTypes.Zombie then
	    --当上面找不到回去的充电站时，执行这里，使建造者爆炸
		if self.builder then
			local builder = self.builder
			self.builder = nil
			builder:returnHome()
		else
			ZombieLogic.changeBuilder(1)
		end
	end
end

function BuildMould:continueBuild()
	if self.buildContinue then
		EventManager.sendMessage("EVENT_BUY_BUILD", self)
	end
end

function BuildMould:updateOperation(diff)
	if self.buildState == BuildStates.STATE_BUILDING then
		if not self.builder then
			self.builder = Builder.new()
			self.builder:addToScene(self.buildView.scene, {self.buildView.view:getPosition()})
			self.builder.target = self
		end
		if self.buildEndTime <= timer.getTime() then
			self:releaseBuilder()
			self:upgradeOver()
		end
	elseif self.updateOperationLogic and self.buildState==BuildStates.STATE_FREE and self.buildLevel>0 and not self.buildView.isOperationDestroy then
		self:updateOperationLogic(diff)
	end
end

function BuildMould:updateVisit(diff)
	if self.buildState == BuildStates.STATE_BUILDING then
		if not self.builder then
			self.builder = Builder.new()
			self.builder:addToScene(self.buildView.scene, {self.buildView.view:getPosition()})
			self.builder.target = self
		end
	elseif self.updateOperationLogic and self.buildLevel>0 and not self.buildView.isOperationDestroy then
	    local b=math.floor(self.buildData.bid/1000)
	    if b>=2 and b<=3 then
    		self:updateOperationLogic(diff)
    	end
	end
end

function BuildMould:addChildMenuButs(buts)

end

function BuildMould:getHitPoints()
    return self.buildView.hitpoints
end

function BuildMould:getChildMenuButs()
	local buts = {}
	if self.buildView.scene.sceneType==SceneTypes.Zombie then
		if self.buildData.bid~=2004 and not self.buildView.deleted then
			if not self.builder then
				table.insert(buts, {image="images/menuItemUpgrade.png", text=StringManager.getString("buttonRepair"), callback=self.repair, callbackParam=self})
			else
				table.insert(buts, {image="images/menuItemCancel.png", text=StringManager.getString("buttonCancel"), callback=self.cancelRepair, callbackParam=self})
			end
		end
	else
		if not self.noInfo then
			table.insert(buts, {image="images/menuItemInfo.png", text=StringManager.getString("buttonInfo"), callback=InfoDialog.show, callbackParam=self})
		end
		if self.buildView.scene.sceneType==SceneTypes.Operation then
    		if self.buildState == BuildStates.STATE_FREE then
    			local nextLevel = StaticData.getBuildData(self.buildData.bid, self.buildLevel+1)
    			if self.buildData.bid==2004 then nextLevel = nil end
    			if nextLevel then
    			    if nextLevel.level==1 then
    			        table.insert(buts, {image="images/menuItemUpgrade.png", text=StringManager.getString("buttonRebuilt"), callback=self.rebuilt, callbackParam=self, extend={cost=nextLevel}})
    			    else
    			        table.insert(buts, {image="images/menuItemUpgrade.png", text=StringManager.getString("buttonUpgrade"), callback=UpgradeDialog.show, callbackParam=self, extend={cost=nextLevel}})
    			    end
    			end
    			if self.buildLevel>0 then
        			self:addChildMenuButs(buts)
        	    end
    		else
    			table.insert(buts, {image="images/menuItemCancel.png", text=StringManager.getString("buttonCancel"), callback=self.cancelBuild, callbackParam=self})
    			table.insert(buts, {image="images/crystal.png", text=StringManager.getString("buttonFinish"), callback=self.accBuild, callbackParam=self, extend={background="images/buttonChildMenuB.png", cost={costType="crystal", costValue=CrystalLogic.computeCostByTime(self.buildEndTime-timer.getTime()), costMid=true}}})
    		end
		end
	end
	return buts
end

-- VIEW逻辑 用于支持不同建筑的展示
function BuildMould:getBuildView()
	local build = UI.createSpriteWithFile("images/build/" .. self.buildData.bid .. "/build" .. self.buildData.level .. ".png")
	return build
end

-- VIEW逻辑 用于显示初始建筑位置
function BuildMould:getLevel0Build()
	local gsize = self.buildData.gridSize
	local temp
	if gsize==2 then
		temp = UI.createSpriteWithFile("images/buildItemBuying2.png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=92, y=0})
	elseif gsize==3 then
		temp = UI.createSpriteWithFile("images/buildItemBuying4.png")
		temp:setScale(0.8)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=138, y=-4})
	elseif gsize==4 then
		temp = UI.createSpriteWithFile("images/buildItemBuying4.png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=184, y=0})
	elseif gsize==5 then
		temp = UI.createSpriteWithFile("images/buildItemBuying2.png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=230, y=121})
	end
	return temp
end

-- VIEW逻辑 用于测试点击是否在建筑上,目前统一优先按底座进行。
function BuildMould:touchTest(x, y)
	--return isTouchInNode(self.buildView.build, x, y, self.buildView.build.isAlphaTouched~=nil) 
end

-- VIEW逻辑 添加建筑的夜晚灯光效果
function BuildMould:changeNightMode(isNight)
end

-- VIEW逻辑 设置建筑的底部图片
function BuildMould:getBuildBottom()
    return UI.createSpriteWithFrame("lampstand" .. self.buildData.gridSize .. ".png")
end

function BuildMould:getShadow(img, x, y, w, h)
    local shadow = UI.createSpriteWithFrame(string.sub(img, 8), CCSizeMake(w, h))
    screen.autoSuitable(shadow, {x=self.buildView.view:getContentSize().width/2+x, y=y})
    return shadow
end

-- VIEW逻辑 获取建筑门口所在位置，相对于锚点坐标的偏移量
function BuildMould:getDoorPosition()
	return {0, 0}
end

-- VIEW逻辑， 获取建筑的Y高度
function BuildMould:getBuildY()
	local build = self.buildView
	if build.build then
	    if self.buildLevel==0 or not self.getSpecialY or build.isOperationDestroy or build.deleted then
	        return build.build:getContentSize().height*build.build:getScaleY() + build.build:getPositionY()
	    else
	        return self:getSpecialY(build.build)
	    end
	else
		return build.view:getContentSize().height
	end
end
