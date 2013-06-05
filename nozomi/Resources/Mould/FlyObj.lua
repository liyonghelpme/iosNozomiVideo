FlyObj = {}

do
	local targets = {silver=ccp(357, 28), gold=ccp(660, 29), crystal=ccp(300, 29), exp=ccp(162, 70)}
	-- 一开始只放置数据，需要显示的时候才显示；
	FlyObj.create = function(type, num, spx, spy)
		local fly = {type=type, num=num}
		
		fly.addViewTo = function(parent)
			local view = UI.createSpriteWithFile("images/" .. type .. ".png", CCSizeMake(36, 36))
			local word = UI.createTTFLabel(num, General.defaultFont, 28, {colorR=getParam("FlyObjR"), colorG=getParam("FlyObjG"), colorB=getParam("FlyObjB")})
			local vsize = view:getContentSize()
			screen.autoSuitable(word, {nodeAnchor=General.anchorLeft, x=vsize.width, y=vsize.height/2})
			view:addChild(word)
			screen.autoSuitable(view, {nodeAnchor=General.anchorCenter, x=spx, y=spy})
			parent:addChild(view)
			music.playEffect("music/pick.mp3")
			
			local difx1 = math.random(getParam("fallX1"))+getParam("baseX1");
            local dify1 = math.random(getParam("fallY1"))+getParam("baseY1");
            local difx2 = math.random(getParam("fallX2"))+getParam("baseX2");
            local dify2 = math.random(getParam("fallY2"))+getParam("baseY2");
            if math.random()>0.5 then
            	difx1, difx2 = -difx1, -difx2
            end
			
			local config = ccBezierConfig:new()
			config.controlPoint_1 = CCPointMake(spx+difx1, spy+dify1)
			config.controlPoint_2 = CCPointMake(spx+difx2, spy-dify2)
			config.endPosition = targets[type]
			
			view:runAction(CCBezierTo:create(getParam("FlyTime")/1000, config))
			view:retain()
			local function remove()
				view:removeFromParentAndCleanup(true)
				view:release()
			end
			delayCallback(getParam("FlyTime")/1000, remove)
			fly.view = view
		end
		
		return fly
	end
	
	FlyObj.createList = function(values, back, spx, spy)
		local list = {}
		for type, value in pairs(values) do
			local cut = 1
			local cutV = value
			if value>100 then
				cut = 5
			elseif value>10 then
				cut = 3
			end
			for i=1, cut do
				local v = math.floor(cutV/(cut - i + 1))
				table.insert(list, {type, v})
				cutV = cutV - v
			end
		end
		local index=0
		for _, v in pairs(list) do
			local flyObj = FlyObj.create(v[1], v[2], spx, spy)
			delayCallback(index*getParam("FlyInteval")/1000, flyObj.addViewTo, back)
			index = index+1
		end
	end
end