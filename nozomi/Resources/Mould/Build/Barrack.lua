Barrack = class(BuildMould)

function Barrack:initWithSetting(setting)
	local dataCallList = setting.callList or {}
	local callList = {}
	local totalSpace = 0
	for i=1, #dataCallList do
		local sinfo = StaticData.getSoldierInfo(dataCallList[i][1])
		callList[i] = {sid=sinfo.sid, num=dataCallList[i][2], perTime = sinfo.time, space = sinfo.space}
		totalSpace = totalSpace + callList[i].num*sinfo.space
	end
	self.callList = callList
	self.totalSpace = totalSpace
	
	local pause = setting.pause
	if pause then
		self.beginTime = UserData.lastSynTime - self.callList[1].perTime
		self.pause = true
	else
		self.beginTime = timer.getTime(setting.beginTime)
	end
end

function Barrack:getExtendInfo()
	local callList = self.callList
	if #callList == 0 then
		return nil
	end
	local data = {}
	for i=1, #callList do
		data[i] = {callList[i].sid, callList[i].num}
	end
	local ret = {callList=data}
	if self.pause then
		ret.pause = true
	else
		ret.beginTime = timer.getServerTime(self.beginTime)
	end
	return ret
end

function Barrack:enterOperation()
	SoldierLogic.setBarrack(self.buildIndex, self)
	self.waitList = {}
end

function Barrack:addBuildUpgrade(bg, addUpgradeItem)

	local temp = UI.createLabel(StringManager.getString("unlocktroop"), General.font1, 15, {colorR = 0, colorG = 0, colorB = 0})
    screen.autoSuitable(temp, {x=360, y=272, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
	
    temp = CCNode:create()
    temp:setContentSize(CCSizeMake(74, 94))
    UI.updateScrollItemStyle1(temp, nil, {bid=self.buildLevel+1})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorTop, x=360, y=247})
	bg:addChild(temp)
	return 0
end

function Barrack:callSoldier(sid)
	local sinfo = StaticData.getSoldierInfo(sid)
	if sinfo.space + self.totalSpace > self.buildData.extendValue1 then
		return false
	end
	local callList = self.callList
	local queueLength = #callList
	local isNew = true
	if queueLength > 0 then
		for i = 1, queueLength do
			if callList[i].sid == sid then
				callList[i].num = callList[i].num+1
				isNew = false
				break
			end
		end
	else
		self.beginTime = timer.getTime()
	end
	if isNew then
		callList[queueLength+1] = {sid=sid, num=1, perTime = sinfo.time, space = sinfo.space}
	end
	self.totalSpace = self.totalSpace + sinfo.space
	return true
end

function Barrack:cancelCallSoldier(sid)
	local callList = self.callList
	for i = 1, #callList do
		if callList[i].sid == sid then
			callList[i].num = callList[i].num-1
			self.totalSpace = self.totalSpace - callList[i].space
			if callList[i].num == 0 then
				table.remove(callList,i)
				if i==1 then
					self.pause = false
					self.beginTime = timer.getTime()
				end
			end
			return true
		end
	end
	return false
end

function Barrack:accCall()
	if self.totalSpace <= SoldierLogic.getSpaceMax()-SoldierLogic.getCurSpace() then
	    local t = math.ceil(self:getTotalTime())
	    local cost = CrystalLogic.computeCostByTime(t)
	    if CrystalLogic.changeCrystal(-cost) then
	        self.beginTime = self.beginTime - t
		    UserStat.addCrystalLog(CrystalStatType.ACC_SOLDIER, timer.getTime(), cost)
		    display.closeDialog()
		    --SoldierLogic.updateSoldierList()
		    --self:updateOperationLogic()
		    return true
		end
	else
		display.pushNotice(UI.createNotice(StringManager.getString("trainErrorCampFull")))
	end
	return false
end

function Barrack:getSingleTime()
	local callList = self.callList
	if #callList > 0 then
		local ret = callList[1].perTime-(timer.getTime()-self.beginTime)
		if ret<0 then ret=0 end
		return ret
	else
		return 0
	end
end
	
function Barrack:getTotalTime()
	local callList = self.callList
	if #callList > 0 then
		local ttime = 0
		for i = 1, #callList do
			local c = callList[i]
			ttime = ttime + c.num * c.perTime
		end
		ttime = ttime - (callList[1].perTime - self:getSingleTime())
		return ttime
	else
		return 0
	end
end

function Barrack:addChildMenuButs(buts)
	table.insert(buts, {image="images/menuItemTrain.png", text=StringManager.getString("buttonTrain"), callback=TrainDialog.show, callbackParam=self})
end

function Barrack:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	local blevel = level
	if level==2 then
		blevel=1
	elseif level>=7 then
		blevel=7
	end
	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/barrack" .. blevel .. ".png", nil, true)
	local ssize = build:getContentSize()
	if level~=blevel then
		for i=blevel+1, level do
			local temp = UI.createSpriteWithFile("images/build/" .. bid .. "/barrack" .. i .. ".png")
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=ssize.width/2})
			build:addChild(temp)
		end
	end
	if level>=6 then
	    
    	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("build1001Action_0.png")
    	if not frame then
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("animate/build/build1001Action.plist")
        end
		local temp = UI.createSpriteWithFrame("build1001Action_0.png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=ssize.width/2-19, y=143})
		build:addChild(temp, 11, TAG_ACTION)
	end
	return build
end

function Barrack:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
		local ox = build:getContentSize().width/2
		for i=9, level do
			light = UI.createSpriteWithFile("images/build/" .. bid .. "/barrackLight" .. i .. ".png")
			screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=ox, y=0})
			build:addChild(light, 10, TAG_LIGHT+i-8)

		end
		local trainLight = self.buildView.build:getChildByTag(TAG_LIGHT)
		if trainLight then
		    trainLight:setColor(ccc3(255, 255, 255))
		end
	else
		for i=1, 2 do
			local light = build:getChildByTag(TAG_LIGHT+i)
			if light then
				light:removeFromParentAndCleanup(true)
			else
				break
			end
		end
	end
end

function Barrack:getDoorPosition()
    return {81, 38}
end

function Barrack:updateOperationLogic()
    local temp
    if self.waitList[1] and not self.isWait then
        local s = table.remove(self.waitList, 1)
        if s.info.unitType==1 then
            local position = self:getDoorPosition()
    		local grid = self.buildView.state.backGrid
    		local p = self.buildView.scene.mapGrid:convertToPosition(grid.gridPosX, grid.gridPosY)
            s:addToScene(self.buildView.scene, {position[1]+p[1], position[2]+p[2]})
            s:setMoveArround()
        else
            local function delayAddSoldier()
        		local grid = self.buildView.state.backGrid
        		local p = self.buildView.scene.mapGrid:convertToPosition(grid.gridPosX, grid.gridPosY)
                s:addToScene(self.buildView.scene, {-19+p[1], 143+p[2]})
                s:setMoveArround()
            end
            local function waitOver()
                self.isWait = false
            end
            self.isWait =  true
            local action = self.buildView.build:getChildByTag(TAG_ACTION)
            action:runAction(Action.createFrameAnimate(1, "build1001Action_", 4, {rollback=true, rollnum=3}))
            local array = CCArray:create()
            array:addObject(CCDelayTime:create(0.5))
            array:addObject(CCCallFunc:create(delayAddSoldier))
            array:addObject(CCDelayTime:create(0.5))
            array:addObject(CCCallFunc:create(waitOver))
            self.buildView.view:runAction(CCSequence:create(array))
        end
    end
	local trainLight = self.buildView.build:getChildByTag(TAG_LIGHT)
	if #(self.callList)>0 then
	    if not trainLight then

    		trainLight = UI.createSpriteWithFile("images/build/" .. self.buildData.bid .. "/barrackLight1.png")
    		screen.autoSuitable(trainLight,{nodeAnchor=General.anchorLeftBottom, x=self.buildView.build:getContentSize().width/2+23, y=13})
    		self.buildView.build:addChild(trainLight, 10, TAG_LIGHT)
    		
    		local array = CCArray:create()
    		array:addObject(CCFadeOut:create(1))
    		array:addObject(CCFadeIn:create(1))
    		trainLight:runAction(CCRepeatForever:create(CCSequence:create(array)))
	    end
		if not self.pause then
			local perTime = self.callList[1].perTime
			local sid = self.callList[1].sid
			if self.buildView.timeProcess then
				self.buildView.timeProcess.totalTime = perTime
				self.buildView.timeProcess.endTime = self.beginTime + perTime
			else
				self.buildView:createTimeProcess("images/buildItemTrainFiller.png", self.beginTime+perTime, perTime)
				
				self.noticeSid = sid
			    local tag = 101
			    temp = UI.createSpriteWithFile("images/dialogItemTrainButtonB.png", CCSizeMake(79, 75))
			    SoldierHelper.addSoldierHead(temp, sid, 0.66)
			    screen.autoSuitable(temp, {nodeAnchor=General.anchorRight, x=-15, y=self.buildView.timeProcess.view:getContentSize().height/2})
			    self.buildView.timeProcess.view:addChild(temp, 0, tag)
			end
			if self.noticeSid ~= sid then
			    self.noticeSid = sid
			    local tag = 101
			    temp = self.buildView.timeProcess.view:getChildByTag(tag)
			    if temp then
			        temp:removeFromParentAndCleanup(true)
			    end
			    temp = UI.createSpriteWithFile("images/dialogItemTrainButtonB.png", CCSizeMake(79, 75))
			    SoldierHelper.addSoldierHead(temp, sid, 0.66)
			    screen.autoSuitable(temp, {nodeAnchor=General.anchorRight, x=-15, y=self.buildView.timeProcess.view:getContentSize().height/2})
			    self.buildView.timeProcess.view:addChild(temp, 0, tag)
			end
			if self.buildView.notice then
				self.buildView.notice:removeFromParentAndCleanup(true)
				self.buildView.notice = nil
			end
		else
			if self.buildView.timeProcess then
			    self.noticeSid = nil
				self.buildView.timeProcess.view:removeFromParentAndCleanup(true)
				self.buildView.timeProcess = nil
			end
			local text = StringManager.getString("labelBarrackPause")
			if not self.buildView.notice or self.buildView.noticeText~=text then
				self.buildView:showNotice(text, 0.7)
			end
		end
	else
	    if trainLight then
	        trainLight:removeFromParentAndCleanup(true)
	    end
		if self.buildView.timeProcess then
		    self.noticeSid = nil
			self.buildView.timeProcess.view:removeFromParentAndCleanup(true)
			self.buildView.timeProcess = nil
		end
		if SoldierLogic.getCurSpace()>=SoldierLogic.getSpaceMax() then
		    if self.buildView.notice then
		        self.buildView:showNotice("", 0.7)
		    end
		else
		    local text = StringManager.getString("labelBarrackTrain")
    		if not self.buildView.notice or self.buildView.noticeText~=text then
    			self.buildView:showNotice(text, 0.7)
    		end
		end
	end
end

function Barrack:getBuildShadow()
    return self:getShadow("images/shadowGrid.png", -134, 33, 266, 211)
end
