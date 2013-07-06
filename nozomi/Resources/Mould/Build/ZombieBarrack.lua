ZombieBarrack = class(Barrack)

function ZombieBarrack:ctor()
    self.level0shadow = true
end

function ZombieBarrack:enterOperation()
    if self.buildLevel>0 then
    	SoldierLogic.setZBarrack(self.buildIndex, self)
    	self.waitList = {}
    end
end

function ZombieBarrack:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local build  = UI.createSpriteWithFile("images/build/" .. bid .. "/zbarrack" .. level .. ".png")
	return build
end

function ZombieBarrack:changeNightMode(isNight)
	local bid = self.buildData.bid
	local build = self.buildView.build
	if self.buildLevel<3 or not build then return end
	if isNight then
	else
	end
end

function ZombieBarrack:getLevel0Build()
	local gsize = self.buildData.gridSize
	local temp = UI.createSpriteWithFile("images/build/1003/zbarrack0.png")
	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=182, y=getParam("buildViewOffy1003", 0)})
	return temp
end

function ZombieBarrack:rebuilt()
    local data = StaticData.getBuildData(1003, 1)
    if ResourceLogic.getResourceMax(data.costType)<data.costValue then
        display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeErrorResourceMax", {name=StringManager.getString("dataBuildName" .. RESOURCE_BUILD_BIDS[data.costType])})))    
    else
        display.pushNotice(UI.createNotice(StringManager.getString("noticeUnlockFunction")))
		--self.buildView.state.movable = true
    end
end

function ZombieBarrack:getBuildShadow()
    return self:getShadow("images/shadowGrid3.png", -152, 17, 281, 209)
end