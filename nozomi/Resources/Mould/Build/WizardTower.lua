WizardTower = class(Defense)

function WizardTower:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("wizardTower1.png")
	if not frame then
	    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("images/build/build" .. bid .. ".plist")
	end
	local build = CCSpriteBatchNode:create("images/build/build" .. bid .. ".png", 20)
	local temp = UI.createSpriteWithFrame("wizardTower1.png")
	build:setContentSize(temp:getContentSize())
	local w = build:getContentSize().width/2
	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
	build:addChild(temp)
	if level>1 then
		for i=2, level do
			local temp = UI.createSpriteWithFrame("wizardTower" .. i .. ".png")
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
			build:addChild(temp)
		end
	end
	local temp = UI.createSpriteWithFrame("wizardTowerTop" .. (math.ceil(level/3)*3-2) .. ".png")
	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
	build:addChild(temp, 1)
	return build
end

function WizardTower:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
		local llevel = math.ceil(level/3)*3-2
		local light = UI.createSpriteWithFrame("wizardTowerLight" .. llevel .. ".png")
		light:setScale(2)
		screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
		build:addChild(light, 10, TAG_LIGHT)
		light = UI.createSpriteWithFrame("wizardTowerTlight" .. llevel .. ".png")
		screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
		build:addChild(light, 10, TAG_LIGHT+1)
	else
		local light = build:getChildByTag(TAG_LIGHT)
		if light then
			light:removeFromParentAndCleanup(true)
		end
		light = build:getChildByTag(TAG_LIGHT+1)
		if light then
			light:removeFromParentAndCleanup(true)
		end
	end
end

function WizardTower:attack(target)
	local build = self.buildView
	local p = {build.view:getPosition()}
	p[1] = p[1] + 2
	p[2] = p[2] + 256
	p[3] = build.scene.SIZEY - p[2]
	--(attack, speed, x, y, targetX, targetY, damageRange, group, unitType, target)
	local shot
	local tx, ty = target.view:getPosition()
	if target.info.unitType==1 then
		shot = MagicSplash.new(self.buildData.extendValue1*self.defenseData.attackSpeed, 180, p[1], p[2], tx, ty, self.defenseData.damageRange, GroupTypes.Defense, 1, math.ceil(self.buildLevel/3))
	else
		shot = MagicSplash.new(self.buildData.extendValue1*self.defenseData.attackSpeed, 180, p[1], p[2], tx, ty+target.viewInfo.y, self.defenseData.damageRange, GroupTypes.Defense, 2, math.ceil(self.buildLevel/3))
	end
	shot:addToScene(build.scene)
	self.coldTime = self.defenseData.attackSpeed
end

function WizardTower:getBuildShadow()
    return self:getShadow("images/shadowCircle.png", -64, 56, 111, 77)
end