OilStorage = class(Storage)

local LEVEL_SETTING = {[1]={{0, 24}}, [2]={{-20, 20}, {20, 20}}, 
			[3]={{6, 38}, {17, 11}, {-23, 18}}, [4]={{8, 42}, {-27, 28}, {28, 18}, {-8, 4}}, 
			[5]={{0, 13}}, [6]={{0, 6}}, [7]={{0, 8}}, [8]={{0, 5}}, [9]={{0, 3}}, [10]={{0, 0}}, [11]={{0, 0}}}
			
local LEVEL_OFFY = {[1]=8, [5]=10, [7]=10, [9]=14, [11]=34}
local LEVEL_SCALE = {[1]=1, [5]=0.73, [7]=0.83, [9]=0.97, [11]=1}

function OilStorage:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	if level<5 then
	    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("oilStorage1.png")
	    if not frame then
	        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("images/build/" .. bid .. "/oilStorage1.plist")
	    end
	    local bg = CCSpriteBatchNode:create("images/build/" .. bid .. "/oilStorage1.png", 10)
    	for i=1, level do
    		local item = LEVEL_SETTING[level][i]
    		local bottom = UI.createSpriteWithFrame("oilStorage1.png")
    		screen.autoSuitable(bottom, {nodeAnchor=General.anchorBottom, x=item[1], y=item[2]})
    		bg:addChild(bottom, 0, i)
    		
    		local oil = UI.createSpriteWithFrame("oilStorage1_" .. (self.resourceState or 0) .. ".png")
    		screen.autoSuitable(oil, {nodeAnchor=General.anchorBottom, x=bottom:getContentSize().width/2, y=LEVEL_OFFY[1]})
    		bottom:addChild(oil, 0, TAG_ACTION)
    	end
    	return bg
	else
    	local blevel = level
    	local bscale = 1
		if level%2==1 then
			bscale = 0.95
		else
			blevel = blevel-1
		end
		
	    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("oilStorage5_0.png")
	    if not frame then
	        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("images/build/" .. bid .. "/oilStorage5.plist")
    	end
    	local bg = UI.createSpriteWithFile("images/build/" .. bid .. "/bottom" .. blevel .. ".png")
    	bg:setScale(bscale)
    	local oil = UI.createSpriteWithFrame("oilStorage5_" .. (self.resourceState or 0) .. ".png")
    	oil:setScale(LEVEL_SCALE[blevel])
    	screen.autoSuitable(oil, {nodeAnchor=General.anchorBottom, x=bg:getContentSize().width/2, y=LEVEL_OFFY[blevel]})
    	bg:addChild(oil, 0, TAG_ACTION)
    	local temp = bg
    	bg=CCNode:create()
    	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, y=LEVEL_SETTING[level][1][2]})
    	bg:addChild(temp, 0, 1)
    	return bg
	end
end

function OilStorage:setResourceState(p)
	local build = self.buildView.build
	local slevel = 1
	if self.buildLevel>=5 then slevel = 5 end
	for i=1, #(LEVEL_SETTING[self.buildLevel]) do
		local parent = build:getChildByTag(i)
		local storage = convertToSprite(parent:getChildByTag(TAG_ACTION))
		storage:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("oilStorage" .. slevel .. "_" .. p .. ".png"))
	end
end

function OilStorage:getBuildShadow()
	local level = self.buildLevel
	local s = 1
	if level%2==1 and level<11 then s=0.95 end
	if level>8 then
	    return self:getShadow("images/shadowCircle.png", -73*s, LEVEL_SETTING[level][1][2]+52, 129*s, 89*s)
	elseif level>6 then
	    return self:getShadow("images/shadowCircle.png", -65*s, LEVEL_SETTING[level][1][2]+53, 114*s, 79*s)
	elseif level>4 then
	    return self:getShadow("images/shadowCircle.png", -61*s, LEVEL_SETTING[level][1][2]+55, 105*s, 73*s)
	else
		local shadow = self:getShadow("images/shadowCircle.png", LEVEL_SETTING[level][1][1]-31, LEVEL_SETTING[level][1][2]+56, 54, 42)
		local sx,sy = shadow:getScaleX(), shadow:getScaleY()
		local w = self.buildView.view:getContentSize().width/2
		for i=2, level do
			local temp = self:getShadow("images/shadowCircle.png", (LEVEL_SETTING[level][i][1]-LEVEL_SETTING[level][1][1])/sx-w, (LEVEL_SETTING[level][i][2]-LEVEL_SETTING[level][1][2])/sy, 54/sx, 42/sy)
			shadow:addChild(temp)
		end
		return shadow
	end
end

-- VIEW逻辑， 获取建筑的Y高度
function OilStorage:getSpecialY(build)
    local tag = #(LEVEL_SETTING[self.buildLevel])
    local temp = build:getChildByTag(tag)
    local temp2 = temp:getChildByTag(TAG_ACTION)
    return build:getPositionY() + temp:getPositionY() +temp2:getPositionY() + temp2:getContentSize().height*0.9 * temp:getScaleY() * temp2:getScaleY()
end