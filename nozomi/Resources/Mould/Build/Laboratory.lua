Laboratory = class(BuildMould)

function Laboratory:ctor(bid, setting)
    if setting.rid then
        UserData.researchItem = {rid=setting.rid, endTime=timer.getTime(setting.rtime)}
    end
end

function Laboratory:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("lab1.png")
	if not frame then
	    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("images/build/build" .. bid .. ".plist")
	end
	local build = CCSpriteBatchNode:create("images/build/build" .. bid .. ".png", 10)
	local temp = UI.createSpriteWithFrame("lab1.png")
	local ssize = temp:getContentSize()
	build:setContentSize(ssize)
	local w = ssize.width/2
	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
	build:addChild(temp)
	if level>1 then
		for i=2, level do
			local temp = UI.createSpriteWithFrame("lab" .. i .. ".png")
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=ssize.width/2})
			build:addChild(temp)
		end
	end
	
    temp = build
    build = CCNode:create()
    build:setContentSize(ssize)
    screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=temp:getContentSize().width/2, y=0})
    build:addChild(temp, 0, TAG_SPECIAL)
    	
	if level>=3 then
		local animate = 3
		if level==6 then
			animate = 6
		end
		local prefix = "build" .. bid .. "Action" .. animate .. "_"
    	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(prefix .. "0.png")
    	if not frame then
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("animate/build/build" .. bid .. "Action" .. animate .. ".plist")
        end
		local asprite = UI.createSpriteWithFrame(prefix .. "0.png")
		local a1, a2 = CCAnimation:create(), CCAnimation:create()
		for i=0, 4 do
			a1:addSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(prefix .. i .. ".png"))
			a2:addSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(prefix .. (4-i) .. ".png"))
		end
		a1:setDelayPerUnit(getParam("actionTimeBuild" .. bid, 150)/1000)
		a2:setDelayPerUnit(getParam("actionTimeBuild" .. bid, 150)/1000)
		a1:setRestoreOriginalFrame(false)
		a2:setRestoreOriginalFrame(false)
		
		local sactions = CCArray:create()
		sactions:addObject(CCAnimate:create(a1))
		sactions:addObject(CCDelayTime:create(getParam("actionIntevalBuild" .. bid, 1500)/1000))
		sactions:addObject(CCAnimate:create(a2))
		sactions:addObject(CCDelayTime:create(getParam("actionIntevalBuild" .. bid, 1500)/1000))
		asprite:runAction(CCRepeatForever:create(CCSequence:create(sactions)))
		
		screen.autoSuitable(asprite, {nodeAnchor=General.anchorCenter, x=ssize.width/2-91, y=199})
		build:addChild(asprite)
	end
	return build
end

function Laboratory:addChildMenuButs(buts)
	table.insert(buts, {image="images/menuItemResearch.png", text=StringManager.getString("buttonResearch"), callback=display.showDialog, callbackParam=ResearchDialog})
end

function Laboratory:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	build = build:getChildByTag(TAG_SPECIAL)
	if not build then return end
	if isNight then
		local ox = build:getContentSize().width/2


		local light = UI.createSpriteWithFrame("labLight1.png")
		screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=ox, y=0})
		build:addChild(light, 10, TAG_LIGHT)

		if level>=2 then

			light = UI.createSpriteWithFrame("labLight2.png")
			screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=ox, y=0})
			build:addChild(light, 10, TAG_LIGHT+1)
		end
		if level>=5 then

			light = UI.createSpriteWithFrame("labLight5.png")
			screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=ox, y=0})
			build:addChild(light, 10, TAG_LIGHT+2)
		end
	else
		for i=0, 2 do
			local light = build:getChildByTag(TAG_LIGHT+i)
			if light then
				light:removeFromParentAndCleanup(true)
			else
				break
			end
		end
	end
end

function Laboratory:updateOperationLogic()
	if UserData.researchItem then
	    if self.buildView.notice then
	        self.buildView.notice:removeFromParentAndCleanup(true)
	        self.buildView.notice = nil
	    end
	    if UserData.researchItem.endTime < timer.getTime() then
	        local rid = UserData.researchItem.rid
	        UserData.researchLevel[rid] = squeeze(UserData.researchLevel[rid]+1, 1, MAX_LAB_LEVEL)
	        UserData.researchItem = nil
	        if self.buildView.timeProcess then
	            self.buildView.timeProcess.view:removeFromParentAndCleanup(true)
	            self.buildView.timeProcess = nil
	        end
	    elseif not self.buildView.timeProcess then
	        local rinfo = StaticData.getResearchInfo(UserData.researchItem.rid, UserData.researchLevel[UserData.researchItem.rid]+1)
	        self.buildView:createTimeProcess("images/buildItemTrainFiller.png", UserData.researchItem.endTime, rinfo.time)
	        
	        local temp = UI.createSpriteWithFile("images/dialogItemTrainButtonB.png", CCSizeMake(79, 75))
			SoldierHelper.addSoldierHead(temp, UserData.researchItem.rid, 0.66)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorRight, x=-15, y=self.buildView.timeProcess.view:getContentSize().height/2})
			self.buildView.timeProcess.view:addChild(temp)
	    end
	else
		if not self.buildView.notice then
			self.buildView:showNotice(StringManager.getString("buttonResearch"), 1)
		end
	end
end

function Laboratory:getBuildShadow()
    if self.buildLevel==1 then
        return self:getShadow("images/shadowSpecial4.png", -129, 56, 187, 175)
    elseif self.buildLevel<=4 then
        return self:getShadow("images/shadowSpecial4.png", -127, 47, 187, 175)
    else
        return self:getShadow("images/shadowSpecial4.png", -144, 47, 187, 175)
    end
end

function Laboratory:getExtendInfo()
    local item = UserData.researchItem
    if item then
    	return {rid=item.rid, rtime=timer.getServerTime(item.endTime)}
    end
end
