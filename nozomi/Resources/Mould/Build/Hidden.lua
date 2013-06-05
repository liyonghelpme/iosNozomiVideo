Hidden = class(Defense)

function Hidden:ctor()
	self.hiddenSupport = true
end

function Hidden:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("tesla1.png")
	if not frame then
	    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("images/build/build" .. bid .. ".plist")
	end
	local build = CCSpriteBatchNode:create("images/build/build" .. bid .. ".png", 10)
	local temp = UI.createSpriteWithFrame("tesla1.png")
	build:setContentSize(temp:getContentSize())
	local w = build:getContentSize().width/2
	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
	build:addChild(temp)
	if level>1 then
		for i=2, level do
			temp = UI.createSpriteWithFrame("tesla" .. i .. ".png")
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
			build:addChild(temp)
			if i==6 then
    			temp = UI.createSpriteWithFrame("tesla" .. i .. "b.png")
    			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
    			build:addChild(temp)
			end
		end
	end
	return build
end

function Hidden:touchTest(x, y)
	local build = self.buildView.build
	return isTouchInNode(build, x, y)
end

function Hidden:getBuildBottom()
end


function Hidden:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
		local llevel = 1
		if level==6 then llevel=6 end
		local light = UI.createSpriteWithFrame("teslalight" .. llevel .. ".png")
		screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
		build:addChild(light, 10, TAG_LIGHT)
	else
		local light = build:getChildByTag(TAG_LIGHT)
		if light then
			light:removeFromParentAndCleanup(true)
		end
	end
end

function Hidden:enterBattle()
	self.hidden = true
	self.buildView.view:setVisible(false)
end

function Hidden:canAttack(dis)
	if dis<=self.defenseData.extendRange or (not self.hidden and dis <= self.defenseData.range) then
		return true
	end
end

function Hidden:attack(target)
	self.hidden = false
	self.buildView.view:setVisible(true)
	local build = self.buildView
	local p = {build.view:getPosition()}
	p[2] = p[2] + 210
	p[3] = build.scene.SIZEY - p[2]
	local shot = ThunderShot.new(self.buildData.extendValue1*self.defenseData.attackSpeed, 60, p[1], p[2], p[3], target)
	shot:addToScene(build.scene)
	self.coldTime = self.defenseData.attackSpeed
end