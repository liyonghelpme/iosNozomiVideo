require "Util.MySpriteSheet"
Nozomi = class(BuildMould)

local baseStorageMax = 1000

function Nozomi:ctor(bid, setting)
	self.oil = {resource=setting.oil or baseStorageMax}
	self.food = {resource=setting.food or baseStorageMax}
	self.needPerson = true
end

function Nozomi:initWithSetting(setting)
	self.npcs = {[0]=1, [5]=1}
	self.npcNum = 2
end

function Nozomi:enterOperation()
	ResourceLogic.setResourceMax("oil", 0, baseStorageMax)
	ResourceLogic.setResourceStorage("oil", 0, self.oil)
	ResourceLogic.setResourceMax("food", 0, baseStorageMax)
	ResourceLogic.setResourceStorage("food", 0, self.food)
	UserData.level = self.buildLevel
	
	UserSetting.setValue("userLevel", self.buildLevel)
	EventManager.sendMessage("EVENT_NOZOMI_UPDATE", UserData.level)
end

function Nozomi:addBuildInfo(bg, addInfoItem)
	addInfoItem(bg, 1, self.oil.resource, nil, baseStorageMax, "Storage", STORAGE_IMG_SETTING.oil)
	addInfoItem(bg, 2, self.food.resource, nil, baseStorageMax, "Storage", STORAGE_IMG_SETTING.food)
	return 2
end

function UI.updateScrollItemStyle2(bg, scrollView, info)
    local size = bg:getContentSize()
    local temp = UI.createSpriteWithFile("images/dialogItemButtonStore.png",size)
    screen.autoSuitable(temp, {x=0, y=0})
    bg:addChild(temp)
    if info.bid then
        local b = Build.create(info.bid, nil, {level=1})
        local gsize = b.buildData.gridSize
        temp = b:getBuildView()
		local bid = info.bid
		local x, y = getParam("buildViewOffx" .. bid, 0), getParam("buildViewOffy" .. bid, 0)
        
        if gsize==1 then
            screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=size.width/2+x, y=size.height/10-20+y})
            bg:addChild(temp)
        else
            local h
            if b.getSpecialY then
                h = b:getSpecialY(temp)
            else
                h = temp:getContentSize().height
            end
            --if y~=0 or not h then
            local s = size.height/h
            local yoff=0
            if bid==2000 or bid==3000 then
                yoff = -10
            elseif bid>2000 and bid<2004 then
                yoff = -5
            end
            temp:setScale(0.8*s)
            screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=size.width/2, y=0.1*size.height+yoff})
            
            bg:addChild(temp)
        end
    end
    if info.num then
        local text
        if info.isNew then
            text = "New"
        else
            text = "x" .. info.num
        end
        temp = UI.createLabel(text, General.font4, 18, {colorR = 255, colorG = 255, colorB = 255})
        screen.autoSuitable(temp, {x=7, y=60, nodeAnchor=General.anchorLeft})
        bg:addChild(temp)
    end
end

function Nozomi:addBuildUpgrade(bg, addUpgradeItem)
    local bids = {1000, 1001, 1002, 2000, 2001, 2002, 2003, 0, 2005, 3000, 3001, 3002, 3003, 3004, 3005, 3006, 3007, 5000, 5001, 5002}
    local updateBuilds = {}
    local level = UserData.level
    local nextLevel = level + 1
    for i, bid in ipairs(bids) do
        local limits = StaticData.getBuildInfo(bid).levelLimits
        if limits[nextLevel]>limits[level] then
            local item = {bid=bid, num=limits[nextLevel]-limits[level]}
            if limits[level]==0 then
                item.isNew = true
            end
            table.insert(updateBuilds, item)
        end
    end
    local scrollView = UI.createScrollViewAuto(CCSizeMake(652, 95), true, {offx=1, offy=6, disx=7, size=CCSizeMake(88,74), infos=updateBuilds, cellUpdate=UI.updateScrollItemStyle2})
    screen.autoSuitable(scrollView.view, {nodeAnchor=General.anchorTop, x=360, y=247})
    bg:addChild(scrollView.view)
    
	addUpgradeItem(bg, 1, baseStorageMax, baseStorageMax, baseStorageMax, "Storage", STORAGE_IMG_SETTING.oil)
	addUpgradeItem(bg, 2, baseStorageMax, baseStorageMax, baseStorageMax, "Storage", STORAGE_IMG_SETTING.food)
	return 2
end

function Nozomi:getExtendInfo()
	return {oil=self.oil.resource, food=self.food.resource}
end

function Nozomi:getBattleResource()
	return {enemyLevel=self.buildLevel}
end

function Nozomi:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	if not PauseLogic.renderTextures[level] then
	    local maxRect = {0, 0, 0, 0}
    	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/build1.png")
	    checkMaxRect(maxRect, build)
        CCTextureCache:sharedTextureCache():removeTextureForKey("images/build/" .. bid .. "/build1.png")
	    local sp = {nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0}
    	
    	local temp
    	
    	local e = (level>4 and (level+1)) or 5
    	for i=9, e, -2 do
    		temp =  UI.createSpriteWithFile("images/build/" .. bid .. "/remove" .. i .. ".png")
    		screen.autoSuitable(temp, sp)
    		build:addChild(temp)
    		
	        checkMaxRect(maxRect, temp)
            CCTextureCache:sharedTextureCache():removeTextureForKey("images/build/" .. bid .. "/remove" .. i .. ".png")
    	end
    	e = (level<=8 and level) or 8
    	for i=6, e, 2 do
    		temp =  UI.createSpriteWithFile("images/build/" .. bid .. "/plugin" .. i .. ".png")
    		screen.autoSuitable(temp, sp)
    		build:addChild(temp)
    		
	        checkMaxRect(maxRect, temp)
            CCTextureCache:sharedTextureCache():removeTextureForKey("images/build/" .. bid .. "/plugin" .. i .. ".png")
    	end
    	if level<=3 then
    		temp = UI.createSpriteWithFile("images/build/" .. bid .. "/stone" .. level .. ".png")
    		screen.autoSuitable(temp, sp)
    		build:addChild(temp, -1)
    		
	        checkMaxRect(maxRect, temp)
            CCTextureCache:sharedTextureCache():removeTextureForKey("images/build/" .. bid .. "/stone" .. level .. ".png")
            
    		temp = UI.createSpriteWithFile("images/build/" .. bid .. "/leaf" .. level .. ".png")
    		screen.autoSuitable(temp, sp)
    		build:addChild(temp, 1)
    		
	        checkMaxRect(maxRect, temp)
            CCTextureCache:sharedTextureCache():removeTextureForKey("images/build/" .. bid .. "/leaf" .. level .. ".png")
    	end
    	local render = CCRenderTexture:create(maxRect[3], maxRect[4], kTexture2DPixelFormat_RGBA8888)
		render:begin()
		build:setScaleY(-1)
		screen.autoSuitable(build, {nodeAnchor=General.anchorLeftBottom, x=-maxRect[1], y=maxRect[4]+maxRect[2]})
		build:visit()
		render:endToLua()
    	PauseLogic.renderTextures[level] = render:getSprite():getTexture()
    	PauseLogic.renderTextures[level]:retain()
    	PauseLogic.renderTextures[level]:setAntiAliasTexParameters()
    	--return build
    end
	local build = CCSprite:createWithTexture(PauseLogic.renderTextures[level])
	return build
end

function Nozomi:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
		local sp = {nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0}
		for i=4, level do
			local light = UI.createSpriteWithFile("images/build/" .. bid .. "/light" .. i .. ".png")
			screen.autoSuitable(light,sp)
			build:addChild(light, 10, TAG_LIGHT+i)
		end
	else
		for i=4, level do
			local light = build:getChildByTag(TAG_LIGHT+i)
			if light then
				light:removeFromParentAndCleanup(true)
			end
		end
	end
end

function Nozomi:getBuildShadow()
	--return self:getShadow("images/shadowGrid.png", -204, 63, 369, 285)
end

function Nozomi:updateOperationLogic(diff)
	self.npcTime = (self.npcTime or 0)+diff
	if self.npcTime > 10 then
		self.npcTime = 0
		if not UserData.noPerson and self.npcNum>0 then
			local ni = math.random(2)
			for i=1, 2 do
				if self.npcs[((ni+i)%2) * 5]>0 then
					ni = ((ni+i)%2) * 5
					break
				end
			end
			self.npcNum = self.npcNum-1
			self.npcs[ni] = self.npcs[ni]-1
			local npc = NPC.new(ni, self)
			local x, y = self.buildView.view:getPosition()
			local off = self:getDoorPosition()
			npc:addToScene(self.buildView.scene, {x+off[1], y+off[2]})
		end
	end
end

function Nozomi:npcReturnHome(nid)
	self.npcNum = self.npcNum+1
	self.npcs[nid] = self.npcs[nid]+1
end

function Nozomi:getDoorPosition()
	return {-123, 105}
end