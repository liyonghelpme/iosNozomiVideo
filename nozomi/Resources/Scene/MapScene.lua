do
	local scMin, scMax = 1, 2
	local speedScale = 2
	-- 创建浮在空中的卷轴
	local function createMapLabel()
		local bg = CCNode:create()
		bg:setContentSize(CCSizeMake(960, 640))
		screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
		local temp = UI.createSpriteWithFile("images/map_label_small.png",CCSizeMake(136, 42))
		screen.autoSuitable(temp, {x=390, y=46})
		bg:addChild(temp)
		temp = UI.createTTFLabel(StringManager.getString("mapIsland2"), General.specialFont, 21, {colorR = 0, colorG = 0, colorB = 0})
		screen.autoSuitable(temp, {x=459, y=66, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/map_label_small.png",CCSizeMake(136, 42))
		screen.autoSuitable(temp, {x=738, y=159})
		bg:addChild(temp)
		temp = UI.createTTFLabel(StringManager.getString("mapIsland3"), General.specialFont, 21, {colorR = 0, colorG = 0, colorB = 0})
		screen.autoSuitable(temp, {x=807, y=179, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/map_label_small.png",CCSizeMake(136, 42))
		screen.autoSuitable(temp, {x=307, y=280})
		bg:addChild(temp)
		temp = UI.createTTFLabel(StringManager.getString("mapIsland0"), General.specialFont, 21, {colorR = 0, colorG = 0, colorB = 0})
		screen.autoSuitable(temp, {x=375, y=300, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/map_label_small.png",CCSizeMake(136, 42))
		screen.autoSuitable(temp, {x=44, y=439})
		bg:addChild(temp)
		temp = UI.createTTFLabel(StringManager.getString("mapIsland1"), General.specialFont, 21, {colorR = 0, colorG = 0, colorB = 0})
		screen.autoSuitable(temp, {x=116, y=459, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/map_label_small.png",CCSizeMake(136, 42))
		screen.autoSuitable(temp, {x=216, y=560})
		bg:addChild(temp)
		temp = UI.createTTFLabel(StringManager.getString("mapIsland5"), General.specialFont, 21, {colorR = 0, colorG = 0, colorB = 0})
		screen.autoSuitable(temp, {x=287, y=580, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/map_label_small.png",CCSizeMake(136, 42))
		screen.autoSuitable(temp, {x=804, y=447})
		bg:addChild(temp)
		temp = UI.createTTFLabel(StringManager.getString("mapIsland4"), General.specialFont, 21, {colorR = 0, colorG = 0, colorB = 0})
		screen.autoSuitable(temp, {x=875, y=467, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		return bg
	end
	
	-- 创建返回经营页面的控制层
	local function createControlLayer()
		local bg = CCNode:create()
		bg:setContentSize(General.winSize)
		
		local temp = UI.createButton(CCSizeMake(103, 69), display.popScene, {image = "images/returnHome.png", priority = display.MENU_BUTTON_PRI})
		screen.autoSuitable(temp, {x=64, y=54, scaleType = screen.SCALE_NORMAL, nodeAnchor = General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/map_label_big.png",CCSizeMake(208, 64))
		screen.autoSuitable(temp, {x=-240, y=-96, scaleType = screen.SCALE_NORMAL, screenAnchor = General.anchorRightTop, nodeAnchor = General.anchorLeftBottom})
		bg:addChild(temp)
		temp = UI.createTTFLabel(StringManager.getString("mapAll"), General.specialFont, 33, {colorR = 0, colorG = 0, colorB = 0})
		screen.autoSuitable(temp, {x=-132, y=-66, scaleType = screen.SCALE_NORMAL, screenAnchor = General.anchorRightTop, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		return bg
	end
	
	local function updateChooseStageCell(bg, data)
		bg:removeAllChildrenWithCleanup(true)
		local temp
		if data.isLock then
			temp = UI.createSpriteWithFile("images/unlockPanel.png",CCSizeMake(195, 214))
			screen.autoSuitable(temp, {x=102, y=113, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			temp = UI.createSpriteWithFile("images/lock0.png",CCSizeMake(49, 60))
			screen.autoSuitable(temp, {x=103, y=84, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
		else
			temp = UI.createSpriteWithFile("images/bluePanel0.png",CCSizeMake(204, 226))
			screen.autoSuitable(temp, {x=102, y=113, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			if data.star == 0 then
				temp = UI.createScaleSprite("images/soldiers/soldier" .. data.sid .. ".png",CCSizeMake(155, 135))
				screen.autoSuitable(temp, {x=99, y=87, nodeAnchor=General.anchorCenter})
				bg:addChild(temp)
				local swidth = temp:getContentSize().width
				local shadow = UI.createSpriteWithFile("images/roleShadow.png",CCSizeMake(swidth, swidth/2))
				screen.autoSuitable(shadow, {x=swidth/2, y=0, nodeAnchor=General.anchorCenter})
				temp:addChild(shadow, -1)
			else
				temp = UI.createSpriteWithFile("images/bluePanel0.png",CCSizeMake(204, 226))
				screen.autoSuitable(temp, {x=121, y=288})
				bg:addChild(temp)
				if data.star < 3 then
					temp = UI.createSpriteWithFile("images/starNot.png",CCSizeMake(178, 66))
					screen.autoSuitable(temp, {x=100, y=48, nodeAnchor=General.anchorCenter})
					bg:addChild(temp)
				else
					temp = UI.createSpriteWithFile("images/starFull.png",CCSizeMake(176, 68))
					screen.autoSuitable(temp, {x=100, y=48, nodeAnchor=General.anchorCenter})
					bg:addChild(temp)
				end
				for i=1, 3 do
					if data.star >=i then
						temp = UI.createSpriteWithFile("images/star.png",CCSizeMake(49, 47))
					else
						temp = UI.createSpriteWithFile("images/star2.png",CCSizeMake(49, 47))
					end
					screen.autoSuitable(temp, {x=57*i - 38, y=23})
					bg:addChild(temp)
				end
				temp = UI.createScaleSprite("images/soldiers/soldier" .. data.sid .. ".png", CCSizeMake(155, 70))
				screen.autoSuitable(temp, {x=99, y=124, nodeAnchor=General.anchorCenter})
				bg:addChild(temp)
				local swidth = temp:getContentSize().width
				local shadow = UI.createSpriteWithFile("images/roleShadow.png",CCSizeMake(swidth, swidth/2))
				screen.autoSuitable(shadow, {x=swidth/2, y=0, nodeAnchor=General.anchorCenter})
				temp:addChild(shadow, -1)
			end
		end
		temp = UI.createTTFLabel("" .. data.id, General.specialFont, 56)
		screen.autoSuitable(temp, {x=98, y=185, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
	end
	
	-- 创建选关的控制层
	local function createChooseStageLayer(islandId, callback)
		local totalStars, curStars = 24, 6
		local stages = {{isLock=false, id=1, sid=0, star=1}, {isLock=false, id=2, sid=30, star=3}, {isLock=false, id=3, sid=60, star=2}, {isLock=false, id=4, sid=130, star=0},
		{isLock=true, id=5, sid=60, star=0}, {isLock=true, id=6, sid=60, star=0}, {isLock=true, id=7, sid=60, star=0}, {isLock=true, id=8, sid=60, star=0}}
		local temp = nil
		local bg = UI.createButton(CCSizeMake(960, 640), doNothing, {priority = display.MENU_PRI, nodeChangeHandler = doNothing})
		screen.autoSuitable(bg, {scaleType = screen.SCALE_CUT_EDGE, screenAnchor = General.anchorCenter})
		local scrollView = UI.createScrollView(CCSizeMake(960, 520), true)
		for i=1, #stages do
			local page = math.ceil(i/8)
			local pindex = (i-1)%8
			local findex = (pindex%4)*2 + math.floor(pindex/4) + 1
			local cell = CCNode:create()
			cell:setContentSize(CCSizeMake(204, 226))
			updateChooseStageCell(cell, stages[i])
			scrollView.addItem(cell, {index = findex, rowmax=2, offx = 23, offy = 6, disx = 26, disy = 12, touchCallback=doNothing})
		end
		scrollView.prepare()
		screen.autoSuitable(scrollView.view, {nodeAnchor=General.anchorLeftBottom, x=0, y=0})
		bg:addChild(scrollView.view)
		temp = UI.createSpriteWithFile("images/totalStar.png",CCSizeMake(163, 52))
		screen.autoSuitable(temp, {x=290, y=552})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/star.png",CCSizeMake(40, 37))
		screen.autoSuitable(temp, {x=309, y=561})
		bg:addChild(temp)
		temp = UI.createTTFLabel(curStars .. "/" .. totalStars, General.defaultFont, 30, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=357, y=577, nodeAnchor=General.anchorLeft})
		bg:addChild(temp)
		temp = UI.createButton(CCSizeMake(103, 75), callback, {image = "images/map_back0.png", priority = display.MENU_BUTTON_PRI})
		screen.autoSuitable(temp, {x=863, y=576, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/title" .. (islandId-1) .. ".png",CCSizeMake(238, 73))
		screen.autoSuitable(temp, {x=38, y=533})
		bg:addChild(temp)
		return bg
	end
	
	-- 岛屿的数据
	local islands = {
		{id=0, width=114, height=95, x=262, y=273, clickRect={{width=85, height=86, x=287, y=283}}},
		{id=1, width=279, height=255, x=9, y=183, clickRect={{width=259, height=211, x=0, y=222}}},
		{id=2, width=314, height=230, x=162, y=2, lx=278, ly=92, clickRect={{width=299, height=156, x=159, y=24}, {width=124, height=51, x=263, y=175}}},
		{id=3, width=357, height=284, x=436, y=53, lx=593, ly=180, clickRect={{width=289, height=184, x=462, y=129}}},
		{id=4, width=338, height=279, x=619, y=200, lx=801, ly=322, clickRect={{width=312, height=115, x=646, y=336}, {width=168, height=98, x=790, y=241}}},
		{id=5, width=341, height=284, x=294, y=347, lx=407, ly=433, clickRect={{width=298, height=199, x=300, y=387}}}
	}
	
	-- 设置点击浮岛的音乐效果
	local function playIslandMusic(boolValue)
		if boolValue then
			music.playEffect("music/but.mp3")
		end
	end
	
	-- 创建岛屿以及锁的方法，需要传一个选中岛屿时的回调函数
	local function updateIslandLayer(clayer, islandChooseCallback)
		-- TODO 需要获取当前解锁到哪一个岛了
		local mapLevel = 4
		
		local ISLAND_TAG = 1
		local CLOUD_TAG = 2
		
		local offx, offy = 0, 0
		local oldIsland = clayer:getChildByTag(ISLAND_TAG)
		if oldIsland then
			offx, offy = oldIsland:getPosition()
			offx, offy = offx - General.winSize.width/2, offy - General.winSize.height/2
			oldIsland:removeFromParentAndCleanup(true)
		end
		local bg = CCNode:create()
		bg:setContentSize(CCSizeMake(960, 640))
		screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE, x=offx, y=offy})
		local dx, dy = math.random(getParam("mapIslandRandomFloor", 5),getParam("mapIslandRandomCeil", 15)), math.random(getParam("mapIslandRandomFloor", 5),getParam("mapIslandRandomCeil", 15))
		if offx > 0 then
			dx=-dx
		elseif offx ==0 then
			local r = math.random()-0.5
			if r < 0 then dx = -dx end
		end
		if offy > 0 then
			dy=-dy
		elseif offy ==0 then
			local r = math.random()-0.5
			if r < 0 then dy = -dy end
		end
		bg:runAction(Action.createVibration(getParam("mapIslandTime", 5000)/1000, dx, dy))
		clayer:addChild(bg, 0, ISLAND_TAG)
		
		local temp = nil
		for i=1, 6 do
			local islandData = islands[i]
			temp = UI.createSpriteWithFile("images/map_island" .. islandData.id .. ".png", CCSizeMake(islandData.width, islandData.height))
			screen.autoSuitable(temp, {x=islandData.x, y=islandData.y})
			bg:addChild(temp)
			if mapLevel < i then
				temp:setColor(ccc3(102, 102, 102))
				
				local temp1 = UI.createSpriteWithFile("images/map_island_lock.png",CCSizeMake(73, 100))
				screen.autoSuitable(temp1, {x=islandData.lx, y=islandData.ly})
				bg:addChild(temp1, 1)
			else
				local rects = islandData.clickRect
				local centerPoint = clayer:convertToNodeSpace(temp:convertToWorldSpace(CCPointMake(islandData.width/2, islandData.height/2)))
				for j=1, #rects do
					local rect = rects[j]
					local temp1 = UI.createButton(CCSizeMake(rect.width, rect.height), islandChooseCallback, {priority = display.SCENE_PRI, callbackParam={id=islandData.id, cx=centerPoint.x, cy=centerPoint.y, scale=2}, nodeChangeHandler=playIslandMusic})
					screen.autoSuitable(temp1, {x=rect.x, y=rect.y})
					bg:addChild(temp1, 2)
				end
			end
		end
		
		local cloudLayer = clayer:getChildByTag(CLOUD_TAG)
		if not cloudLayer then
			cloudLayer = CCNode:create()
			cloudLayer:setContentSize(CCSizeMake(1136, 640))
			screen.autoSuitable(cloudLayer, {width = 1136, height = 640, screenAnchor=General.anchorCenter, scaleType = screen.SCALE_NORMAL})
			clayer:addChild(cloudLayer, 1, CLOUD_TAG)
			-- clouds properties and functions
			local cloudsTime = 0
			local cloudsNum = 0
			local clouds = {}
			local function createCloud(rx)
				local cloudType = math.random(7)-1
				local cloud = UI.createSpriteWithFile("images/cloud" .. cloudType .. ".png")
				local cloudY = 640 - math.random(480)
				screen.autoSuitable(cloud, {nodeAnchor=General.anchorLeftTop, x=(rx or 0)-700, y=cloudY})
				local cloudTime = getParam("mapBigCloudTime", 70000)/1000
				if cloudType==2 or cloudType==5 then
					cloudTime = getParam("mapSmallCloudTime", 50000)/1000
				end
				cloudTime = cloudTime + getParam("mapCloudRandomTime", 5000)/1000
				cloudTime = cloudTime / 1820 * (1820 - (rx or 0))
				cloudsNum = cloudsNum+1
				cloud:setScale(0.6)
				cloud:runAction(CCMoveTo:create(cloudTime, CCPointMake(1120, cloudY)))
				table.insert(clouds, {time = cloudTime, view = cloud})
				cloudLayer:addChild(cloud)
			end
			
			local function updateCloud(diff)
				cloudsTime = cloudsTime + diff
				if cloudsTime >= getParam("mapCloudInterval", 9000)/1000 then
					for i, v in pairs(clouds) do
						v.time = v.time - cloudsTime
						if v.time < 0 then
							v.view:removeFromParentAndCleanup(true)
							cloudsNum = cloudsNum - 1
							clouds[i] = nil
						end
					end
					cloudsTime = 0
					if cloudsNum< getParam("mapCloudMax", 8) then
						createCloud()
					end
				end
			end
			
			for i=1, getParam("mapInitCloudNum", 4) do
				createCloud(math.random(1120))
			end
			
			simpleRegisterEvent(cloudLayer, {update = {callback = updateCloud, inteval = getParam("mapCloudInterval", 9000)/1000}})
		end
		
		return clayer
	end
	
	local function create()
		-- some setting
		local bg = CCNode:create()
		bg:setContentSize(General.winSize)
		
		local bgSky = UI.createSpriteWithFile("images/map_background0.png",CCSizeMake(1136, 640))
		screen.autoSuitable(bgSky, {width = 1136, height = 640, screenAnchor=General.anchorCenter, scaleType = screen.SCALE_NORMAL})
		bg:addChild(bgSky, -1)
		
		local labelLayer = createMapLabel()
		bg:addChild(labelLayer, 2)
		
		local controlLayer = createControlLayer()
		bg:addChild(controlLayer, 3)
		
		local islandLayer = CCNode:create()
		islandLayer:setContentSize(General.winSize)
		screen.autoSuitable(islandLayer)
		bg:addChild(islandLayer, 0)
		
		local state = {}
		local function resetAction()
			if not state.target then return false end
			local posx, posy = islandLayer:getPosition()
			local curScale = islandLayer:getScale()
			local targetPos = CCPointMake(General.winSize.width/2 - state.target.x * state.target.scale, General.winSize.height/2 - state.target.y * state.target.scale)

			state.movAction = {baseX = posx, baseY = posy, baseScale = curScale, deltaX = targetPos.x - posx, deltaY = targetPos.y - posy, deltaScale = state.target.scale - curScale}
			state.target = nil
			return true
		end
		
		local function chooseIsland(islandData)
			if islandData.id == 0 then
				display.popScene()
			end
			if islandData.id ~= state.islandId then
				state.islandId = islandData.id
				state.target = {x=islandData.cx, y=islandData.cy, scale=islandData.scale}
				state.totalTime = getParam("mapScaleTime", 700)/1000
				state.time = 0
				resetAction()
				state.moving = true
				labelLayer:setVisible(false)
				if controlLayer then
					controlLayer:removeFromParentAndCleanup(true)
					controlLayer = nil
				end
			end
		end
		
		local function gobackToMap()
			state.islandId = nil
			state.target = {x=General.winSize.width/2, y=General.winSize.height/2, scale=1}
			state.totalTime = getParam("mapScaleTime", 700)/1000
			state.time = 0
			resetAction()
			state.moving = true
			if controlLayer then
				controlLayer:removeFromParentAndCleanup(true)
				controlLayer = nil
			end
		end
		
		updateIslandLayer(islandLayer, chooseIsland)
		
		local function update(diff)
			if state.moving then
				state.time = state.time + diff
				
				local action = state.movAction
				local delta = Action.sineout(state.time/state.totalTime)
				if action.deltaScale < 0 then
					delta = Action.sinein(state.time/state.totalTime)
				end
				islandLayer:setScale(action.baseScale + action.deltaScale * delta)
				islandLayer:setPosition(action.baseX + action.deltaX * delta, action.baseY + action.deltaY * delta)
				
				if state.time >= state.totalTime then
					state.moving = false
					if state.islandId then
						controlLayer = createChooseStageLayer(state.islandId, gobackToMap)
						bg:addChild(controlLayer, 3)
					else
						controlLayer = createControlLayer()
						bg:addChild(controlLayer, 3)
						labelLayer:setVisible(true)
					end
				end
			end
		end
		simpleRegisterEvent(bg, {update = {callback = update, inteval = 0}})
		
		return {view = bg}
	end
	
	MapScene = {create = create}
end