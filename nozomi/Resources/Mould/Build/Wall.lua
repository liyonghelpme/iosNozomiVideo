Wall = class(BuildMould)

--城墙建筑调整view 坐标的时候 也需要调整build坐标
function Wall:ctor()
	self.dirWall = {0, 0}
	self.buildContinue = true
    self.needAdjustBuild = true
end


function Wall:getBuildView(state)
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local wallIndex = 1
	if state and state.backGrid then
		wallIndex = 1 + self.dirWall[1] + self.dirWall[2]*2
	end
	
	local blevel = level
	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/wall" .. blevel .. "_" .. wallIndex .. ".png")

    --[[
	local build = UI.createSpriteWithFrame("wall" .. blevel .. "_" .. wallIndex .. ".png")
	if be then
		local temp = UI.createSpriteWithFrame("wall" .. be .. ".png")
	end
    ]]--
	return build
end

function Wall:touchTest(x, y)
	return isTouchInNode(self.buildView.build, x, y)
end

function Wall:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
	    if level==8 or level==9 then
	        local light = UI.createSpriteWithFile("images/build/" .. bid .. "/wallLight" .. level .. ".png")
	        screen.autoSuitable(light, {nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2, y=0})
	        build:addChild(light, 10, TAG_LIGHT)
	    end
	else
	    local light = build:getChildByTag(TAG_LIGHT)
	    if light then
	        light:removeFromParentAndCleanup(true)
	    end
	end
end
--城墙调整方向 相应调整vertexz
function Wall:setDirWall(dir, value)
	self.dirWall[dir] = value
	self:resetBuildView()

end

--城墙不同于其它建筑物
--城墙的build 都贴到wallLayer 图层上面CCSpriteBatchNode
--普通建筑build 添加到self.view 上面
--城墙建筑移动之后 需要resetBuildView
--城墙初始化需要 resetBuildView
function Wall:setBuild()
	local buildView = self.buildView
	if buildView.isOperationDestroy then return end
    --local wallLayer = buildView.build:getParent()
    local wallLayer = self.buildView.scene.wallLayer

	buildView.build:removeFromParentAndCleanup(true)
	buildView.build = self:getBuildView(buildView.state)
	buildView:setViewState(buildView.build)
    wallLayer:addChild(buildView.build)

    local vx, vy = buildView.view:getPosition()
    buildView.build:setPosition(ccp(vx, vy))
end

function Wall:resetBuildView()
	local buildView = self.buildView
	buildView.build:removeFromParentAndCleanup(true)
    buildView.build = self:getBuildView(buildView.state)
	buildView:setViewState(buildView.build)
	buildView.view:addChild(buildView.build)

    --self:setBuild()

	if buildView.state.nightMode then
	    recurSetColor(buildView.build, General.nightColor)
	    if self.state==BuildStates.STATE_FREE then
	        self:changeNightMode(true)
	    end
	end

    self.buildView:setVertexZ()
end

function Wall:onGridReset(oldGrid, newGrid)
	local scene = self.buildView.scene
	if oldGrid then
		scene.walls[scene.mapGrid:getGridKey(oldGrid.gridPosX, oldGrid.gridPosY)] = nil
		local lw = scene.walls[scene.mapGrid:getGridKey(oldGrid.gridPosX, oldGrid.gridPosY-1)]
		if lw then
			lw:setDirWall(1, 0)
		end
		local rw = scene.walls[scene.mapGrid:getGridKey(oldGrid.gridPosX-1, oldGrid.gridPosY)]
		if rw then
			rw:setDirWall(2, 0)
		end
	end
	if newGrid then
		self.dirWall = {0, 0}
		scene.walls[scene.mapGrid:getGridKey(newGrid.gridPosX, newGrid.gridPosY)] = self
		if scene.walls[scene.mapGrid:getGridKey(newGrid.gridPosX+1, newGrid.gridPosY)] then
			self.dirWall[2] = 1
		end
		if scene.walls[scene.mapGrid:getGridKey(newGrid.gridPosX, newGrid.gridPosY+1)] then
			self.dirWall[1] = 1
		end
		self:resetBuildView()
		
		local lw = scene.walls[scene.mapGrid:getGridKey(newGrid.gridPosX, newGrid.gridPosY-1)]
		if lw then
			lw:setDirWall(1, 1)
		end
		local rw = scene.walls[scene.mapGrid:getGridKey(newGrid.gridPosX-1, newGrid.gridPosY)]
		if rw then
			rw:setDirWall(2, 1)
		end
	end
end

function Wall:getBuildBottom()
end
