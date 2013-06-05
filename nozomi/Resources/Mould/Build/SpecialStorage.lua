SpecialStorage = class(Storage)

local TAG_11 = 1
local TAG_FOOD = 2

function SpecialStorage:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local blevel = level
	local plugin = nil
	if level>5 and level<=8 then
		blevel = 5
		plugin = UI.createSpriteWithFile("images/build/" .. bid .. "/build" .. level .. ".png")
	elseif level>10 then
		blevel = 10
	end
	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/build" .. blevel .. ".png", nil, true)
	if plugin then
		screen.autoSuitable(plugin, {nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
		build:addChild(plugin)
	end
	if level==11 then
		build:runAction(Action.createVibration(getParam("actionTimeBuild2003_11", 2000)/1000, 0, getParam("actionOffyBuild2003_11", 10)))
		local temp = build
		build = UI.createSpriteWithFile("images/build/" .. bid .. "/build11.png")
		
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
		build:addChild(temp, 1, TAG_11)
	end
	return build
end

function SpecialStorage:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if level==11 then
		build = build:getChildByTag(TAG_11)
	end
	if isNight then
		local light
		if level>=9 then
			light = UI.createSpriteWithFile("images/build/" .. bid .. "/light9.png")
		end
		if light then
			screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
			build:addChild(light, 10, TAG_LIGHT)
		end
	else
		if level>=9 then
			local light = build:getChildByTag(TAG_LIGHT)
			if light then
				light:removeFromParentAndCleanup(true)
			end
		end
	end
end

-- VIEW逻辑， 获取建筑的Y高度
function SpecialStorage:getSpecialY(build)
    local b = build
	if self.buildData.level==11 then
		b = b:getChildByTag(TAG_11)
	end
	return b:getContentSize().height*b:getScaleY() + build:getPositionY()
end