Mortar = class(Defense)

function Mortar:canAttack(dis)
	if dis <= self.defenseData.range and dis>=self.defenseData.extendRange then
		return true
	end
end

function Mortar:getRangeCircle(mapGrid)

	local tr = self.defenseData.range * 1.414
	local size = CCSizeMake(tr * mapGrid.sizeX, tr * mapGrid.sizeY)
	local circle = CCNode:create()
	circle:setContentSize(size)
	local temp = UI.createSpriteWithFile("images/circleBig.png", size)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=size.width/2, y=size.height/2})
	circle:addChild(temp)
	
	tr = self.defenseData.extendRange * 1.414
	temp = UI.createSpriteWithFile("images/circleBig.png", CCSizeMake(tr * mapGrid.sizeX, tr * mapGrid.sizeY))
	temp:setColor(ccc3(255, 0, 0))
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=size.width/2, y=size.height/2})
	circle:addChild(temp)
	
	return circle
end

function Mortar:ctor()
	self:setRotateEnable(true)
end

function Mortar:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local blevel = level
	local plugin = nil
	if level==3 or level==4 then
		blevel = 2
		if level==4 then
			plugin = UI.createSpriteWithFile("images/build/" .. bid .. "/bottom" .. level .. ".png")
		end
	elseif level>5 then
		blevel = 5
		plugin = UI.createSpriteWithFile("images/build/" .. bid .. "/bottom" .. level .. ".png")
	end
	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/bottom" .. blevel .. ".png")
	if plugin then
		screen.autoSuitable(plugin, {nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
		build:addChild(plugin)
	end
	local actionNode = UI.createSpriteWithFrame(self:getRotatePrefix() .. "3.png")
	screen.autoSuitable(actionNode, {nodeAnchor=General.anchorCenter, x=build:getContentSize().width/2, y=158-getParam("buildViewOffy" .. bid, 0)})
	build:addChild(actionNode, 20, TAG_ACTION)
	return build
end

function Mortar:changeNightMode(isNight)
end

function Mortar:getRotatePrefix()
	local bid = self.buildData.bid
	local level = self.buildData.level
	local alevel = level
	if level==2 then
		alevel=1
	elseif level==6 then
		alevel=5
	end
	local prefix = "animate/build/build" .. bid .. "_" .. alevel
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("build" .. bid .. "_" .. alevel .. "_3.png")
	if not frame then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(prefix .. ".plist")
    end
    return "build" .. bid .. "_" .. alevel .. "_"
end

function Mortar:attack(target)
	local build = self.buildView
	if target.deleted then return end
	local p = self:getAttackPosition(0, 86, 0.44, self.direction or 6)
	local tx, ty = target.view:getPosition() 
	--(, ,  , p[3], target, , , 70)
	local shot = MortarSplash.new(self.buildData.extendValue1*self.defenseData.attackSpeed, 60, p[1], p[2], tx, ty, self.defenseData.damageRange, GroupTypes.Defense, 1, self.buildLevel, 70)
	shot:addToScene(build.scene)
	self.coldTime = self.defenseData.attackSpeed
	
	local t = 0.9
	local temp = UI.createAnimateWithSpritesheet(t, "bombSmoke_", 8, {plist="animate/effects/normalEffect.plist", isRepeat=false})
	temp:setScale(2)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=p[1], y=p[2]})
	self.buildView.scene.effectBatch:addChild(temp, self.buildView.scene.SIZEY)
	delayRemove(t, temp)
end

function Mortar:getBuildShadow()
    return self:getShadow("images/shadowCircle.png", -73, 52, 129, 89)
end