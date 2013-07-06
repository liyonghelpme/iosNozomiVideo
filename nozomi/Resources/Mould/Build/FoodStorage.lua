FoodStorage = class(Storage)

local TAG_11 = 1
local TAG_FOOD = 2

local LEVEL_OFFY = {108, 108, 118, 124, [5]=129, [9]=132}
local LEVEL_SCALE = {0.77, 0.85, 0.85, 0.91}

function FoodStorage:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local blevel = level
	local plugin = nil
	if level==8 then
		blevel = 7
		plugin = UI.createSpriteWithFile("images/build/" .. bid .. "/build" .. bid .. "_8.png")
	elseif level>=10 then
		blevel = 9
		plugin = UI.createSpriteWithFile("images/build/" .. bid .. "/build" .. bid .. "_10.png")
	end
	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/build" .. bid .. "_" .. blevel .. ".png", nil, true)
	if plugin then
		screen.autoSuitable(plugin, {nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
		build:addChild(plugin)
	end
	
    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("storageFood" .. (self.resourceState or 0) .. ".png")
    if not frame then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("images/build/" .. bid .. "/storageFood.plist")
    end
	local food = UI.createSpriteWithFrame("storageFood" .. (self.resourceState or 0) .. ".png")
	if level<5 then
    	food:setScale(LEVEL_SCALE[level])
    end
    local slevel = level
    if level>=9 then
        slevel = 9
    elseif level>=5 then
        slevel = 5
    end
	screen.autoSuitable(food, {nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=LEVEL_OFFY[slevel]-37})
	build:addChild(food, 0, TAG_ACTION)
		
	if level==11 then
		build:runAction(Action.createVibration(getParam("actionTimeBuild2003_11", 2000)/1000, 0, getParam("actionOffyBuild2003_11", 10)))
		local temp = build
		build = UI.createSpriteWithFile("images/build/" .. bid .. "/build" .. bid .. "_11.png")
		
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=20})
		build:addChild(temp, 1, TAG_11)
	end
	return build
end

function FoodStorage:setResourceState(p)
	local build = self.buildView.build
	if self.buildData.level==11 then
		build = build:getChildByTag(TAG_11)
	end
	local storage = convertToSprite(build:getChildByTag(TAG_ACTION))
	
    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("storageFood" .. p .. ".png")
	storage:setDisplayFrame(frame)
end

function FoodStorage:changeNightMode(isNight)
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
			light = UI.createSpriteWithFile("images/build/" .. bid .. "/build" .. bid .. "_light9.png")
		elseif level>=7 then
			light = UI.createSpriteWithFile("images/build/" .. bid .. "/build" .. bid .. "_light7.png")
		end
		if light then
			screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
			build:addChild(light, 10, TAG_LIGHT)
		end
	else
		if level>=7 then
			local light = build:getChildByTag(TAG_LIGHT)
			if light then
				light:removeFromParentAndCleanup(true)
			end
		end
	end
end

-- VIEW逻辑， 获取建筑的Y高度
function FoodStorage:getSpecialY(build)
    local b = build
	if self.buildData.level==11 then
		b = b:getChildByTag(TAG_11)
	end
	return b:getContentSize().height*b:getScaleY() + build:getPositionY()
end

function FoodStorage:getBuildShadow()
    local level = self.buildLevel
    if level>=5 then
        return self:getShadow("images/shadowGrid.png", -115, 18, 200, 154)
    elseif level==4 then
        return self:getShadow("images/shadowGrid.png", -100, 28, 177, 137)
    elseif level>=2 then
        return self:getShadow("images/shadowGrid.png", -95, 33, 169, 130)
    else
        return self:getShadow("images/shadowGrid.png", -89, 36, 164, 126)
    end
end