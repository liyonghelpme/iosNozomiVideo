Town = class(Producer)


function Town:showCollectAnimation(incNum)
	--local x, y = self.buildView.view:getPosition()
	--local i = math.floor(incNum*20/self.buildData.extendValue2)
	--if i<3 then i=20 end
	--local temp = UI.createFoodSplashEffect(i)
	--screen.autoSuitable(temp.view, {x=x, y=y + 174})
	--self.buildView.scene.ground:addChild(temp.view, self.buildView.scene.SIZEY-y)
	--delayRemove(1.5, temp.view)
	
	self:showCollectText(ccc3(199, 160 ,0), incNum)
end

--function Town:getDoorPosition()
	--return {31, 56}
--end

function Town:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/build" .. bid .. "_" .. level .. ".png", nil, true)
	return build
end

function Town:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
	else
	end
end

function Town:showCollectAnimation(incNum)
	--local x, y = self.buildView.view:getPosition()
	self:showCollectText(ccc3(255, 255 ,255), incNum)
end

function Town:getBuildShadow()
    return self:getShadow("images/shadowGrid.png", -59, 27, 121, 93)
end

function Town:touchTest(x, y)
	local build = self.buildView.build
	return isTouchInNode(build, x, y)
end