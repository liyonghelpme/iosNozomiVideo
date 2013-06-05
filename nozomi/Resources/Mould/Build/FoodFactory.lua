FoodFactory = class(Producer)

local Y=135

function FoodFactory:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/build" .. bid .. "_" .. level .. ".png", nil, true)
	
	local bbottom
	if level>=10 then
		bbottom = UI.createSpriteWithFile("images/build/" .. bid .. "/bottom" .. bid .. "_10.png")
	else
		bbottom = UI.createSpriteWithFile("images/build/" .. bid .. "/bottom" .. bid .. "_1.png")
	end
	
	local animate = UI.createAnimateWithSpritesheet(getParam("actionTimeBuild" .. bid, 300)/1000, "build" .. bid .. "Action_", 2, {plist="animate/build/build" .. bid .. "Action.plist"})
	screen.autoSuitable(animate, {nodeAnchor=General.anchorCenter, x=bbottom:getContentSize().width/2-1, y=Y})
	bbottom:addChild(animate)
	
	screen.autoSuitable(bbottom, {nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2})
	build:addChild(bbottom,-1)
	
	return build
end

function FoodFactory:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
		local ox = build:getContentSize().width/2
        local light

		local light = UI.createSpriteWithFile("images/build/" .. bid .. "/light" .. bid .. "_1.png")
		screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=ox, y=0})
		build:addChild(light, 10, TAG_LIGHT)
        
		if level>=8 then

			light = UI.createSpriteWithFile("images/build/" .. bid .. "/light" .. bid .. "_" .. level .. ".png")
			screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=ox, y=0})
			build:addChild(light, 10, TAG_LIGHT+1)
		end
	else
		for i=0, 1 do
			local light = build:getChildByTag(TAG_LIGHT+i)
			if light then
				light:removeFromParentAndCleanup(true)
			end
		end
	end
end

function FoodFactory:showCollectAnimation(incNum)
	local x, y = self.buildView.view:getPosition()
	local i = squeeze(math.floor(incNum*20/self.buildData.extendValue2),1,20)
	local temp = UI.createFoodSplashEffect(i)
	screen.autoSuitable(temp.view, {x=x, y=y + 174})
	self.buildView.scene.ground:addChild(temp.view, self.buildView.scene.SIZEY-y)
	delayRemove(1.5, temp.view)
	
	self:showCollectText(ccc3(199, 160 ,0), incNum)
end

local NUM_SETTING={1,2,4,6,8}

local function addFoodAction(foodNode)
    local t = getParam("actionTimeFoodItem", 9000)/1000
    local sarray = CCArray:create()
    local array = CCArray:create()
    array:addObject(CCMoveBy:create(t/6, CCPointMake(-55, -33)))
    local config = ccBezierConfig:new_local()
	config.controlPoint_1 = CCPointMake(-36, -22)
	config.controlPoint_2 = CCPointMake(5, -70)
	config.endPosition = CCPointMake(55, -70)
	array:addObject(CCBezierBy:create(t*3/9, config))
	config = ccBezierConfig:new_local()
	config.controlPoint_1 = CCPointMake(50, 0)
	config.controlPoint_2 = CCPointMake(91, 48)
	config.endPosition = CCPointMake(55, 70)
	array:addObject(CCBezierBy:create(t*3/9, config))
    array:addObject(CCMoveBy:create(t/6, CCPointMake(-55, 33)))
    sarray:addObject(CCSequence:create(array))
        
    array=CCArray:create()
    array:addObject(CCScaleTo:create(t/2, 1, 1))
    array:addObject(CCScaleTo:create(t/2, 0.9, 0.9))
    sarray:addObject(CCSequence:create(array))
        
    foodNode:runAction(CCRepeatForever:create(CCSpawn:create(sarray)))
end

function FoodFactory:setResourceState(p)
    local batch=self.buildView.build:getChildByTag(TAG_ACTION)
    if batch then
        batch:removeAllChildrenWithCleanup(true)
    else
        batch = CCSpriteBatchNode:create("images/foodItem.png", 12)
        screen.autoSuitable(batch, {x=self.buildView.build:getContentSize().width/2, y=Y})
        self.buildView.build:addChild(batch, -1, TAG_ACTION)
    end
    
    local t = getParam("actionTimeFoodItem", 9000)/1000
    local num = NUM_SETTING[p+1]
    for i=1, num do
        local temp = CCSprite:create("images/foodItem.png")
        temp:setScale(0.9)
        screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=0, y=37})
        batch:addChild(temp)
        
        local array = CCArray:create()
        array:addObject(CCDelayTime:create((i-1)*t/num))
        array:addObject(CCCallFuncN:create(addFoodAction))
        temp:runAction(CCSequence:create(array))
    end
end

function FoodFactory:getBuildShadow()
    return self:getShadow("images/shadowSpecial1.png", -119, 21, 197, 249)
end
