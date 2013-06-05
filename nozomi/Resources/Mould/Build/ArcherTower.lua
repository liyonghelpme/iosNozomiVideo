ArcherTower = class(Defense)

function ArcherTower:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
    local tlevel = level
    local et = nil
    local blevel = level
    local mlevel = level
    local em = nil
    if level==2 then
    	tlevel = 1
    elseif level==5 then
    	tlevel = 4
    	et=5
    elseif level>6 and level<10 then
    	tlevel = 6
    	if level>=8 then et=8 end
    elseif level==11 then
        tlevel = 10
    end
    if level>2 and level<9 then
    	blevel = 2
    elseif level>9 then
    	blevel = 9
    end
    if level<6 then
    	mlevel = 1
    	if level>=2 then em={2} end
    elseif level>6 then
    	mlevel = 6
    	em = {}
    	for i=7, 11, 2 do
    		if level>=i then
    			table.insert(em, i)
    		else
    			break
    		end
    	end
    end
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("laserTop" .. tlevel .. ".png")
	if not frame then
	    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("images/build/build" .. bid .. ".plist")
	end
	local build = CCSpriteBatchNode:create("images/build/build" .. bid .. ".png", 10)
	local temp = UI.createSpriteWithFrame("laserTop" .. tlevel .. ".png")
	build:setContentSize(temp:getContentSize())
	local w = build:getContentSize().width/2
	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w})
	build:addChild(temp)
    if et then
    	temp = UI.createSpriteWithFrame("laserTop" .. et .. ".png")
    	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w, y=0})
    	build:addChild(temp)
    end
    temp = UI.createSpriteWithFrame("laserBottom" .. blevel .. ".png")
    screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w, y=0})
    build:addChild(temp, -2)
    temp = UI.createSpriteWithFrame("laserBuild" .. mlevel .. ".png")
    screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w, y=0})
    build:addChild(temp, -1)
    if em then
    	for i=1, #em do
    		temp = UI.createSpriteWithFrame("laserBuild" .. em[i] .. ".png")
    		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=w, y=0})
    		build:addChild(temp, -1)
    	end
    end
	return build
end

function ArcherTower:touchTest(x, y)
	local build = self.buildView.build
	return isTouchInNode(build, x, y)
end

function ArcherTower:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
		local llevel = level
		if (level<=4 and level%2==0) or (level>6 and level%2==1) then
			llevel = level-1
		end
		local light = UI.createSpriteWithFrame("laserLight" .. llevel .. ".png")
		if light then
			screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
			build:addChild(light, 10, TAG_LIGHT)
		end
	else
		local light = build:getChildByTag(TAG_LIGHT)
		if light then
			light:removeFromParentAndCleanup(true)
		end
	end
end

function ArcherTower:attack(target)
	local build = self.buildView
	local p = {build.view:getPosition()}
	p[1] = p[1] + 3
	p[2] = p[2] + 245
	p[3] = build.scene.SIZEY - p[2]
	local al = 1
	if self.buildLevel>7 then al=math.ceil((self.buildLevel-7)/2)+1 end
	local shot = LaserShot.new(self.buildData.extendValue1*self.defenseData.attackSpeed, 180, p[1], p[2], p[3], target, al, 1)
	shot:addToScene(build.scene)
	self.coldTime = self.defenseData.attackSpeed
end

function ArcherTower:getBuildShadow()
    return self:getShadow("images/shadowCircle.png", -61, 64, 106, 73)
end