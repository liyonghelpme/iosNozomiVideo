Cannon = class(Defense)

function Cannon:ctor()
	self:setRotateEnable(true)
end

function Cannon:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local blevel = level
	if level==9 then
		blevel = 8
	end
	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/bottom" .. blevel .. ".png")
	local actionNode = UI.createSpriteWithFrame(self:getRotatePrefix() .. "3.png")
	actionNode:setScale(getParam("cannonScale" .. level, 100)/100)
	local offy = 68+level*2
	if level<3 then offy=69 end
	screen.autoSuitable(actionNode, {nodeAnchor=General.anchorCenter, x=build:getContentSize().width/2, y=offy})
	build:addChild(actionNode, 20, TAG_ACTION)
	return build
end

function Cannon:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
		local light
		if level==9 then
			light = UI.createSpriteWithFile("images/build/" .. bid .. "/light8.png")
		elseif level>=6 then
			light = UI.createSpriteWithFile("images/build/" .. bid .. "/light" .. level .. ".png")
		end
		if light then
			screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
			build:addChild(light, 10, TAG_LIGHT)
		end
	else
		if level>=6 then
			local light = build:getChildByTag(TAG_LIGHT)
			if light then
				light:removeFromParentAndCleanup(true)
			end
		end
	end
end

function Cannon:getRotatePrefix()
	local bid = self.buildData.bid
	local level = self.buildData.level
	local alevel = level
	if level<5 then
		alevel=1
	elseif level==7 then
		alevel=6
	elseif level==11 then
		alevel=10
	end
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("build" .. bid .. "_" .. alevel .. "_3.png")
	if not frame then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("animate/build/build" .. bid .. "_" .. alevel .. ".plist")
    end
    return "build" .. bid .. "_" .. alevel .. "_"
end

CANNON_SHOT_SETTING={{30, 0.2}, {33, 0.2}, {42, 0.235}, {44, 0.267}, {46, 0.305}, {48, 0.339}, {50, 0.339}, 
					{52, 0.364}, {54, 0.381}, {56, 0.4}, {56, 0.4}}
function Cannon:attack(target)
	local build = self.buildView
	local setting = CANNON_SHOT_SETTING[self.buildLevel]
	local p = self:getAttackPosition(0, setting[1], setting[2], self.direction or 6)
	local shot = CannonShot.new(self.buildData.extendValue1*self.defenseData.attackSpeed, 80, p[1], p[2], p[3], target, self.buildLevel)
	shot:addToScene(build.scene)
	self.coldTime = self.defenseData.attackSpeed
end

local CANNON_SHADOW_SETTING = {{106,81,45,31},{106,81,45,31},{98,72,61,43},{92,67,73,50},{90,64,77,53},{87,60,83,57},
                                {84,59,83,57},{81,55,89,61},{81,55,89,61},{78,54,95,65},{72,48,111,77}}

function Cannon:getBuildShadow()
    local setting = CANNON_SHADOW_SETTING[self.buildLevel]
    return self:getShadow("images/shadowCircle.png", setting[1]-134, setting[2], setting[3], setting[4])
end