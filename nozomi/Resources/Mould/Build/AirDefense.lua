AirDefense = class(Defense)

function AirDefense:ctor()
	self:setRotateEnable(true)
end

function AirDefense:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local build
	if level == 1 then
	    build = UI.createSpriteWithFile("images/build/" .. bid .. "/airDefense1.png")
	else
    	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("airDefense2.png")
    	if not frame then
    	    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("images/build/build" .. bid .. ".plist")
    	end
    	build = CCSpriteBatchNode:create("images/build/build" .. bid .. ".png", 10)
    	local temp = UI.createSpriteWithFrame("airDefense2.png")
	    --build:setContentSize(temp:getContentSize())
    	--local w = build:getContentSize().width/2
    	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom})
    	build:addChild(temp)
    	local ls = {4,5,7}
    	for i=1,3 do
    		local l=ls[i]
    		if level>=l then
    			local temp = UI.createSpriteWithFrame("airDefense" .. l .. ".png")
    			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom})
    			build:addChild(temp)
    		else
    			break
    		end
    	end
    	temp = build
    	build = CCNode:create()
    	build:setContentSize(temp:getContentSize())
    	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=temp:getContentSize().width/2, y=0})
    	build:addChild(temp, 0, TAG_SPECIAL)
    end
	local actionNode = UI.createSpriteWithFrame(self:getRotatePrefix() .. "3.png")
	screen.autoSuitable(actionNode, {nodeAnchor=General.anchorCenter, x=build:getContentSize().width/2, y=150-getParam("buildViewOffy" .. bid, 0)})
	build:addChild(actionNode, 20, TAG_ACTION)
	return build
end

function AirDefense:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	if level<7 then return end
	local build = self.buildView.build:getChildByTag(TAG_SPECIAL)
	if not build then return end
	if isNight then
		local light = UI.createSpriteWithFrame("aireDefenseLight7.png")
		screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
		build:addChild(light, 10, TAG_LIGHT)
	else
		local light = build:getChildByTag(TAG_LIGHT)
		if light then
			light:removeFromParentAndCleanup(true)
		end
	end
end

function AirDefense:getRotatePrefix()
	local bid = self.buildData.bid
	local level = self.buildData.level
	local prefix = "animate/build/build" .. bid .. "_" .. level
	
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("build" .. bid .. "_" .. level .. "_3.png")
	if not frame then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(prefix .. ".plist")
    end
    return "build" .. bid .. "_" .. level .. "_"
end

function AirDefense:attack(target)
	local build = self.buildView
	local p = self:getAttackPosition(0, 60, 0.7, self.direction or 6)
	local shot = AirShot.new(self.buildData.extendValue1*self.defenseData.attackSpeed, 80, p[1], p[2], p[3], target, 60)
	shot:addToScene(build.scene)
	self.coldTime = self.defenseData.attackSpeed
	
	local t = 0.9
	local temp = UI.createAnimateWithSpritesheet(t, "bombSmoke_", 8, {plist="animate/effects/normalEffect.plist", isRepeat=false})
	temp:setScale(2)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=p[1], y=p[2]})
	self.buildView.scene.effectBatch:addChild(temp, self.buildView.scene.SIZEY)
	delayRemove(t, temp)
end

function AirDefense:getBuildShadow()
    return self:getShadow("images/shadowCircle.png", -77, 44, 133, 93)
end