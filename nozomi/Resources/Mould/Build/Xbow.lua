Xbow = class(Defense)

function Xbow:ctor()
	self:setRotateEnable(true)
end

function Xbow:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/bottom1.png")
	local actionNode = UI.createSpriteWithFrame(self:getRotatePrefix() .. "3.png")
	screen.autoSuitable(actionNode, {nodeAnchor=General.anchorCenter, x=build:getContentSize().width/2, y=127-getParam("buildViewOffy" .. bid, 0)})
	build:addChild(actionNode, 20, TAG_ACTION)
	return build
end

function Xbow:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
	else
	end
end

function Xbow:getRotatePrefix()
	local bid = self.buildData.bid
	local level = self.buildData.level
	local prefix = "animate/build/build" .. bid .. "_" .. 1
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("build" .. bid .. "_" .. 1 .. "_3.png")
	if not frame then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(prefix .. ".plist")
    end
    return "build" .. bid .. "_" .. 1 .. "_"
end

function Xbow:attack(target)
	local build = self.buildView
	local p = self:getAttackPosition(0, 33, 1, self.direction or 6)
	self.atype = (self.atype or 1)%2+1
	local shot = GunShot.new(self.buildData.extendValue1*self.defenseData.attackSpeed, 60, p[1], p[2], p[3], target, self.atype, p[4])
	shot:addToScene(build.scene)
	self.coldTime = self.defenseData.attackSpeed
end

function Xbow:getBuildShadow()
    return self:getShadow("images/shadowCircle.png", -55, 61, 98, 68)
end