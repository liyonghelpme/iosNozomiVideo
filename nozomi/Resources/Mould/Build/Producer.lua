Producer = class(BuildMould)

function Producer:ctor(bid, setting, param)
	self.resourceType = param
	self.resource = setting.resource or 0
	self.collectTime = timer.getTime(setting.collectTime)
end

function Producer:getExtendInfo()
	return {resource=self.resource, collectTime=timer.getServerTime(self.collectTime)}
end

function Producer:getBattleResource()
	--if self.resourceType=="special" then
	--	return {[self.resourceType]=math.floor(self:getResource()*0.75)}
	if self.resourceType=="food" or self.resourceType=="oil" then
	    local resource = math.floor(self:getResource()*0.5)
	    self.resourceMax = self.buildData.extendValue2
		return {[self.resourceType]=resource}
	end
end

function Producer:getResource()
    if self.buildState==BuildStates.STATE_BUILDING then return 0 end
	local bdata = self.buildData
	local gain = self.resource
	gain = gain + math.floor((math.floor(timer.getTime())-self.collectTime)*bdata.extendValue1/3600)
	if gain>bdata.extendValue2 then
		gain = bdata.extendValue2
	end
	return gain
end

function Producer:collect(isClear)
	local gain = self:getResource()
	if gain==0 then return false end
	local incNum = ResourceLogic.changeResource(self.resourceType, gain)
	if gain>incNum then
		display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeStorageFull", {name=StringManager.getString("dataBuildName" .. RESOURCE_BUILD_BIDS[self.resourceType])})))
		if incNum == 0 and not isClear then return false end
	end
	if isClear then incNum = gain end
	self.resource = gain - incNum
	if self.buildView.flyNode then
		self.buildView.flyNode:removeFromParentAndCleanup(true)
		self.buildView.flyNode = nil
	end
	self:showCollectAnimation(incNum)
	self.collectTime = math.floor(timer.getTime())
	self:updateOperationLogic(0)
	music.playEffect("music/" .. self.resourceType .. "Collect.mp3")
	EventManager.sendMessage("EVENT_OTHER_OPERATION", {type="Add", key="collect"})
	return true
end

function Producer:addBuildInfo(bg, addInfoItem)
	local maxData = StaticData.getMaxLevelData(self.buildData.bid)
	addInfoItem(bg, 1, self.getResource, nil, self.buildData.extendValue2, "Storage", STORAGE_IMG_SETTING[self.resourceType], self)
	addInfoItem(bg, 2, self.buildData.extendValue1, nil, maxData.extendValue1, "Producer", "images/" .. self.resourceType .. ".png")
	return 2
end

function Producer:addBuildUpgrade(bg, addUpgradeItem)
	local bdata = self.buildData
	local maxData = StaticData.getMaxLevelData(bdata.bid)
	local nextLevel = StaticData.getBuildData(bdata.bid, bdata.level+1)
	
	addUpgradeItem(bg, 1, bdata.extendValue2, nextLevel.extendValue2, maxData.extendValue2, "Storage", STORAGE_IMG_SETTING[self.resourceType])
	addUpgradeItem(bg, 2, bdata.extendValue1, nextLevel.extendValue1, maxData.extendValue1, "Producer", "images/" .. self.resourceType .. ".png")
	return 2
end

function Producer:addChildMenuButs(buts)
	table.insert(buts, {image="images/" .. self.resourceType .. ".png", text=StringManager.getString("buttonCollect"), callback=self.collect, callbackParam=self})
end

function Producer:updateOperationLogic(diff)
    if self.buildView.scene.sceneType==SceneTypes.Operation then
    	local full = (ResourceLogic.getResource(self.resourceType)>=ResourceLogic.getResourceMax(self.resourceType))
    	if not self.buildView.flyNode or full~=self.isFull then
    		if self.buildView.flyNode then
    			self.buildView.flyNode:removeFromParentAndCleanup(true)
    		end
    		self.isFull = full
    		local r = self:getResource()
    		if r>10 then
    			local img = "images/buildItemCollectBg.png"
    			if full then
    				img = "images/buildItemCollectBgB.png"
    			end
    			local flyNode = UI.createSpriteWithFile(img, CCSizeMake(77, 84))
    			screen.autoSuitable(flyNode, {nodeAnchor=General.anchorBottom, x=self.buildView.view:getContentSize().width/2, y=self:getBuildY()})
    			self.buildView.uiview:addChild(flyNode)
    			
    			--local temp = UI.createSpriteWithFile(img, CCSizeMake(77, 84))
    			--screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=39, y=0})
    			--flyNode:addChild(temp)
    			
    			local temp = UI.createScaleSprite("images/" .. self.resourceType .. ".png", CCSizeMake(56, 56))
    			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=39, y=22})
    			flyNode:addChild(temp)
    			
    			self.buildView.flyNode = flyNode
    		end
    	end
    end
	
    local percent = 100*self:getResource()/self.buildData.extendValue2
    local state = squeeze(math.floor(percent/24),0,4)
    if state~=self.resourceState then
        self.resourceState = state
        if self.setResourceState then
            if self.buildView and not self.buildView.isOperationDestroy then
                self:setResourceState(state)
            else
                self.resourceState = nil
            end
        end
    end
end

function Producer:flyNodeTouched()
	return self:collect()
end

function Producer:onFocus(focus)
	if self.buildView.flyNode then
		self.buildView.flyNode:setVisible(not focus)
	end
end

function Producer:showCollectText(color, incNum)
	local label = UI.createLabel(tostring(incNum), General.font2, 40)
	label:setColor(color)
	screen.autoSuitable(label, {nodeAnchor=General.anchorCenter, x=self.buildView.view:getContentSize().width/2, y=self:getBuildY()+100})
	self.buildView.view:addChild(label, 100)
	
	local t = getParam("collectActionTime", 1500)/1000
	local array = CCArray:create()
	
	array:addObject(CCMoveBy:create(t*2/3, CCPointMake(0, 250)))
	array:addObject(CCFadeOut:create(t*1/3))
	label:runAction(CCSequence:create(array))
	delayRemove(t, label)
end

function Producer:beforeUpgrade()
    self:collect(true)
end

function Producer:afterUpgrade(endTime)
    self.resource = 0
    self.collectTime = endTime
    self.resourceState = nil
    self:updateOperationLogic(0)
end