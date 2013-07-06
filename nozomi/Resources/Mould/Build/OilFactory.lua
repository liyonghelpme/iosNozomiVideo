OilFactory = class(Producer)

local OIL_SETTING = {[1]={0.85, 0, 104}, [5]={0.88, 8, 107}, [8]={1, 8, 107}}

function OilFactory:getBuildShadow()
	local level = self.buildData.level
	if level<8 then
	    return self:getShadow("images/shadowCircle.png", -71, 53, 122, 85)
	else
	    return self:getShadow("images/shadowCircle.png", -77, 43, 133, 92)
	end
end


function OilFactory:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level

	local blevel
	if level<5 then
		blevel=1
	elseif level<8 then
		blevel=5
	else
		blevel=8
	end

	local setting = OIL_SETTING[blevel]
	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/bottom" .. blevel .. ".png")
	local w = build:getContentSize().width/2
	blevel = level
	if level>9 then blevel=9 end

	if blevel>=6 then
		temp = UI.createSpriteWithFile("images/build/" .. bid .. "/behind" .. blevel .. ".png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
		build:addChild(temp, -1)
	end
	if level>=10 then
		temp = UI.createSpriteWithFile("images/build/" .. bid .. "/behind10.png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
		build:addChild(temp)
	end

	temp = UI.createSpriteWithFile("images/build/" .. bid .."/oil" .. (self.resourceState or 0) .. ".png")
	temp:setScale(setting[1])
	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w+setting[2], y=setting[3]})
	build:addChild(temp, 0, TAG_ACTION)

	
	temp = UI.createSpriteWithFile("images/build/" .. bid .. "/front" .. blevel .. ".png")
	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
	build:addChild(temp, 1)
	
	if level==11 then

		temp = UI.createSpriteWithFile("images/build/" .. bid .. "/front11.png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
		build:addChild(temp, 1)
	end
	return build
end


function OilFactory:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
		if level>=4 then
			local ox = build:getContentSize().width/2
			local llevel = level
			if level>9 then llevel=9 end

			local light = UI.createSpriteWithFile("images/build/" .. bid .. "/light" .. llevel .. ".png")
			screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=ox, y=0})
			build:addChild(light, 10, TAG_LIGHT)
		end
	else
		local light = build:getChildByTag(TAG_LIGHT)
		if light then
			light:removeFromParentAndCleanup(true)
		end
	end
end

function OilFactory:setResourceState(p)
	local build = self.buildView.build
	local storage = convertToSprite(build:getChildByTag(TAG_ACTION))
	storage:setTexture(CCTextureCache:sharedTextureCache():addImage("images/build/" .. self.buildData.bid .."/oil" .. p .. ".png"))
end

function OilFactory:showCollectAnimation(incNum)
	local blevel = self.buildLevel
	if blevel < 5 then
		blevel=1
	elseif blevel<8 then
		blevel=5
	else
		blevel=8
	end
	local x, y = self.buildView.view:getPosition()
	local i = math.floor(incNum*20/self.buildData.extendValue2)
	local temp = UI.createWaterSplashEffect(i)
	screen.autoSuitable(temp.view, {x=x, y=y + OIL_SETTING[blevel][3]})
	self.buildView.scene.ground:addChild(temp.view, self.buildView.scene.SIZEY-y)
	delayRemove(1.5, temp.view)
	
	self:showCollectText(ccc3(15, 124 ,255), incNum)
end

-- VIEW逻辑， 获取建筑的Y高度
function OilFactory:getSpecialY(build)
	local temp = build:getChildByTag(TAG_ACTION)
	return build:getPositionY() + temp:getPositionY() + 118*temp:getScaleY()
end
