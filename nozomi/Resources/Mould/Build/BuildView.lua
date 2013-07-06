require "Util.ReuseNodeCache"
require "data.UserData"

BuildView = class()
	
function BuildView:setMoveBottom(grid)

	local state = self.state
	local scene = self.scene
	local fx, fy = nil
	if state.backGrid then
		fx, fy = state.backGrid.gridPosX, state.backGrid.gridPosY
	end
	local isOk = scene.mapGrid:checkGridEmpty(GridKeys.Build, grid.gridPosX, grid.gridPosY, grid.gridSize, fx, fy)
	if state.moveState == isOk then
		return isOk
	end
	state.moveState = isOk
		
	local bottomImage = "images/buildItemGridRed.png"
	if isOk then
		bottomImage = "images/buildItemGridGreen.png"
	end
	if self.bottom then
		self.bottom:removeFromParentAndCleanup(true)
	end
    self.bottom = CCSpriteBatchNode:create(bottomImage, grid.gridSize*grid.gridSize)
	local sizeX, sizeY = self.scene.mapGrid.sizeX, self.scene.mapGrid.sizeY
	local baseX, baseY = sizeX * (grid.gridSize/2), -sizeY
	self.bottom:setContentSize(CCSizeMake(sizeX*grid.gridSize, sizeY*grid.gridSize))
	for i=1, grid.gridSize do
		for j=1, grid.gridSize do
			local temp = UI.createSpriteWithFile(bottomImage, CCSizeMake(sizeX, sizeY))
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=(j-i)*sizeX/2 + baseX, y=(i+j)*sizeY/2 + baseY})
			self.bottom:addChild(temp)
		end
	end
	screen.autoSuitable(self.bottom, {x=self.view:getContentSize().width/2, y=0, nodeAnchor=General.anchorBottom})
	self.view:addChild(self.bottom, -2)
	return isOk
end
	
function BuildView:setBuildBottom(position)
	if self.state.moveState==nil and self.bottom then return end
	self.state.moveState = nil
	
	local buildData = self.buildMould.buildData
		
	if self.bottom then
		self.bottom:removeFromParentAndCleanup(true)
	end
	
	self.bottom = self.buildMould:getBuildBottom()
	if self.bottom then
		screen.autoSuitable(self.bottom, {nodeAnchor=General.anchorBottom, x=position[1], y=position[2]})
		self.scene.bottomSprite:addChild(self.bottom, 0)
		if not shadow and not self.isOperationDestroy and (self.buildMould.buildLevel > 0 or self.buildMould.level0shadow) then
			self:addShadow()
		end
	end
end

function BuildView:showNotice(text, type)
	if self.notice then
		self.notice:removeFromParentAndCleanup(true)
	end
	self.noticeType = "text"
	self.noticeText = text
	
	if text=="" then
	    self.notice = nil
	    return
	end
	self.notice = CCNode:create()
	screen.autoSuitable(self.notice, {nodeAnchor=General.anchorBottom, x=self.view:getContentSize().width/2, y=self.buildMould:getBuildY()})
	self.view:addChild(self.notice)
	
	local img = "images/buildItemNotice.png"
	if type==1 then
		img = "images/buildItemNoticeB.png"
	end
	local temp = UI.createSpriteWithFile(img)
	temp:setScale(1.2)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=0, y=0})
	self.notice:addChild(temp)
	temp = UI.createLabel(text, General.font3, 30)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=0, y=59})
	self.notice:addChild(temp)
end

function BuildView:movePosition(position)
	self.view:retain()
	self.uiview:retain()
	local parent = self.view:getParent()
	if parent then
		parent:removeChild(self.view, false)
		self.uiview:removeFromParentAndCleanup(false)
	end
	self.view:setPosition(position[1], position[2])
	--if self.isOperationDestroy then
	--    if 
	--end
	self.uiview:setPosition(position[1], position[2])
    
	local zOrder 
	if not self.state.moveOk then 
		zOrder = self.scene.SIZEY+1
	else
		zOrder = self.scene.SIZEY - position[2] - self.scene.mapGrid.sizeY*self.buildMould.buildData.gridSize/2
	end

	simpleRegisterEvent(self.layer, self.eventEntries, self)
	self.scene.soldierBuildingLayer:addChild(self.view, zOrder)
    self.scene.uiground:addChild(self.uiview, zOrder)

	self.view:release()
	self.uiview:release()
	if self.circle then
		self.circle:setPosition(position[1], position[2]+self.view:getContentSize().height/2)
	end
end
	
function BuildView:moveGrid(newGrid)
	local state = self.state
	local scene = self.scene
	
	self.state.grid = newGrid
		
	local isOk = self:setMoveBottom(newGrid)
	state.moveOk = isOk
		
	local position = scene.mapGrid:convertToPosition(newGrid.gridPosX, newGrid.gridPosY)
	self:movePosition(position)
		
	if state.isBuying then
		self:resetBuyingView()
	end
end

function BuildView:resetBuyingView(isClear)
	local bg = self.view
	if self.buyingView and isClear then
		self.buyingView[1]:removeFromParentAndCleanup(true)
		self.buyingView[2]:removeFromParentAndCleanup(true)
		self.buyingView = nil
	elseif not self.buyingView and not isClear then
		local ssize = bg:getContentSize()
		local temp = UI.createButton(CCSizeMake(70, 70), self.readyToBuy, {useExtendNode=true, callbackParam=self, image="images/buildOk.png"})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=ssize.width/2+60, y=ssize.height+40})
		bg:addChild(temp, 2)
		self.buyingView = {temp}
		temp = UI.createButton(CCSizeMake(70, 70), self.cancelBuy, {useExtendNode=true, callbackParam=self, image="images/buttonClose.png"})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=ssize.width/2-60, y=ssize.height+40})
		bg:addChild(temp, 2)
		self.buyingView[2] = temp
	end
	if self.buyingView then
		if self.state.moveOk then
			self.buyingView[1]:setSatOffset(0)
		else
			self.buyingView[1]:setSatOffset(-100)
		end
	end
end
function BuildView:clearGrids(backGrid)
	local mapWorld = self.scene.mapWorld
	local buildData = self.buildMould.buildData
    local newWorld = self.scene.newWorld
    --mapWorld:clearGrids(backGrid.gridPosX*2+buildData.soldierSpace, backGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2)
    if newWorld then
        newWorld:clearGrids(backGrid.gridPosX*2+buildData.soldierSpace, backGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2, self.tempBuildId)
    end
end
function BuildView:clearObstacle(backGrid)
	local mapWorld = self.scene.mapWorld
	local buildData = self.buildMould.buildData
    local newWorld = self.scene.newWorld
    --mapWorld:clearObstacle(backGrid.gridPosX*2+buildData.soldierSpace, backGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2)
    if newWorld then
        newWorld:clearObstacle(backGrid.gridPosX*2+buildData.soldierSpace, backGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2)
    end
end
function BuildView:clearBuild(backGrid)
	local mapWorld = self.scene.mapWorld
	local buildData = self.buildMould.buildData
    local newWorld = self.scene.newWorld

    --mapWorld:clearBuild(backGrid.gridPosX*2+buildData.soldierSpace, backGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2, StaticData.getBuildInfo(buildData.bid).btype, self)
    if newWorld then
        newWorld:clearBuild(backGrid.gridPosX*2+buildData.soldierSpace, backGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2, StaticData.getBuildInfo(buildData.bid).btype, self.tempBuildId)
    end
end

function BuildView:setGrids(newGrid)
	local mapWorld = self.scene.mapWorld
	local buildData = self.buildMould.buildData
    local newWorld = self.scene.newWorld
    --if mapWorld then
    --mapWorld:setGrids(newGrid.gridPosX*2+buildData.soldierSpace, newGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2, self)
    --else
    if newWorld then
        newWorld:setGrids(newGrid.gridPosX*2+buildData.soldierSpace, newGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2, self.tempBuildId)
    end
end

function BuildView:setObstacle(newGrid)
    self.scene.bidToBuildView[self.tempBuildId] = nil
    self.tempBuildId = self.scene:getTempBuildId()
    self.scene.bidToBuildView[self.tempBuildId] = self

    local mapWorld = self.scene.mapWorld
	local buildData = self.buildMould.buildData
    local newWorld = self.scene.newWorld
    --if mapWorld then
    --mapWorld:setObstacle(newGrid.gridPosX*2+buildData.soldierSpace, newGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2, self)
    --else
    if newWorld then
        newWorld:setObstacle(newGrid.gridPosX*2+buildData.soldierSpace, newGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2, self.tempBuildId)
    end
end

function BuildView:setBuild(newGrid)
	local mapWorld = self.scene.mapWorld
	local buildData = self.buildMould.buildData
    local newWorld = self.scene.newWorld
    --if mapWorld then
    --mapWorld:setBuild(newGrid.gridPosX*2+buildData.soldierSpace, newGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2, StaticData.getBuildInfo(buildData.bid).btype, self)
    --else
    if newWorld then
        newWorld:setBuild(newGrid.gridPosX*2+buildData.soldierSpace, newGrid.gridPosY*2+buildData.soldierSpace, (buildData.gridSize-buildData.soldierSpace)*2, StaticData.getBuildInfo(buildData.bid).btype, self.tempBuildId)
    end
end


function BuildView:resetGridUse(backGrid, newGrid)
	local mapGrid = self.scene.mapGrid
	local mapGridView = self.scene.mapGridView
	local mapWorld = self.scene.mapWorld
	local buildData = self.buildMould.buildData
    local newWorld = self.scene.newWorld
	
	self.buildMould:onGridReset(backGrid, newGrid)
	if backGrid then
		if not self.buildMould.hiddenSupport and self.buildMould.buildData.hitPoints>0 then
			mapGridView:clearGridUse(GridKeys.Build, backGrid.gridPosX-1, backGrid.gridPosY-1, backGrid.gridSize+2)
		end
		mapGrid:clearGridUse(GridKeys.Build, backGrid.gridPosX, backGrid.gridPosY, backGrid.gridSize)
		if self.buildMould.buildContinue or self.buildMould.buildData.hitPoints==0 then
            if self.buildMould.buildData.bid == 3006 then
                self:clearGrids(backGrid)
            else
                self:clearObstacle(backGrid)
            end
		else
            --if mapWorld then
            --business
		    if self.scene.sceneType==SceneTypes.Operation or self.scene.sceneType==SceneTypes.Visit then
                self:clearObstacle(backGrid)
		    else
		        self:clearBuild(backGrid)
			end
		end
	end
	if newGrid then
		if not self.buildMould.hiddenSupport and self.buildMould.buildData.hitPoints>0 then
			mapGridView:setGridUse(GridKeys.Build, newGrid.gridPosX-1, newGrid.gridPosY-1, newGrid.gridSize+2)
		end
		mapGrid:setGridUse(GridKeys.Build, newGrid.gridPosX, newGrid.gridPosY, newGrid.gridSize, newGrid.gridSize, self)
		if self.buildMould.buildContinue or self.buildMould.buildData.hitPoints==0 then
            if self.buildMould.buildData.bid == 3006 then
                self:setGrids(newGrid)
            else
			    self:setObstacle(newGrid)
            end
		else
		    if self.scene.sceneType==SceneTypes.Operation or self.scene.sceneType==SceneTypes.Visit then
			    self:setObstacle(newGrid)
    	    else
                self:setBuild(newGrid)
    	    end
		end
	end
end
	
function BuildView:damageGridUse(backGrid)
	local mapWorld = self.scene.mapWorld
	local buildData = self.buildMould.buildData
    local newWorld = self.scene.newWorld
	if backGrid then
		if self.buildMould.buildContinue or self.buildMould.buildData.hitPoints==0 then
            self:clearGrids(backGrid)
		else
            self:clearBuild(backGrid)
		end
	end
end

function BuildView:resetGrid()
	local state = self.state
	local scene = self.scene
	
	if state.isFocus and not state.moveOk and state.backGrid then
		state.grid = state.backGrid
	end
	local grid = state.grid
	local position = scene.mapGrid:convertToPosition(grid.gridPosX, grid.gridPosY)
	self:setBuildBottom(position)
	if not state.moveOk then
		state.moveOk = true
		self:movePosition(position)
	end
	if not state.backGrid or state.backGrid.gridPosX ~= state.grid.gridPosX or state.backGrid.gridPosY ~= state.grid.gridPosY then
		local backGrid = state.backGrid
		state.backGrid = state.grid
		self:resetGridUse(backGrid, state.grid)
	end
end
	
function BuildView:releaseFocus()
	self:resetGrid()
	self:setFocus(false)
end
	
function BuildView:setFocus(focus)
	local state = self.state
	local scene = self.scene
	local build = self.build
	if focus then
	    music.playEffect("music/buildClicked.mp3")
		state.touchTime = nil
		state.isFocus = true
		if state.touchPoint then
			self:readyToMove()
			state.moveOk = true
		end
		if scene.focusBuild then
			scene.focusBuild:releaseFocus()
		end
		scene.focusBuild = self
		if build then
		
			self.backViewState = {self.build:getPositionX(), self.build:getPositionY(), self.build:getScaleX(), self.build:getScaleY()}
			
			local sactions = CCArray:create()
			local scale = build:getScale()
			local ascale = getParam("buildScale", 120)/100
			local moveOff = getParam("buildScale", 10)
			sactions:addObject(CCScaleTo:create(getParam("buildScaleTime", 100)/1000, scale*ascale, scale*ascale))
			sactions:addObject(CCScaleTo:create(getParam("buildScaleTime", 100)/1000, scale, scale))
			
			build:runAction(CCEaseSineInOut:create(CCSequence:create(sactions)))
			
			
		end
		if self.buildMould.getRangeCircle then
			self.circle = self.buildMould:getRangeCircle(self.scene.mapGrid)
			self.circle:setScale(0.01)
			screen.autoSuitable(self.circle, {nodeAnchor=General.anchorCenter, x=self.view:getPositionX(), y=self.view:getPositionY()+self.view:getContentSize().height/2})
			self.scene.ground:addChild(self.circle, 2)	
			local sactions = CCArray:create()
			sactions:addObject(CCScaleTo:create(0.15, 1.1, 1.1))
			sactions:addObject(CCScaleTo:create(0.15, 1, 1))
			self.circle:runAction(CCSequence:create(sactions))
			self.circle:runAction(CCAlphaTo:create(0.1, 0, 255))
		end
		
		if state.movable then
			local ssize = self.view:getContentSize()
			self.pt = CCNode:create()
			local gSize = self.buildMould.buildData.gridSize
			local ptScale = 0.7
			for i=1, 4 do
				local xk, yk = 3-math.ceil(i/2)*2, 1-(i%2)*2
				local temp 
				if yk<0 then 
				    temp = UI.createSpriteWithFile("images/buildItemDirection.png")
				    temp:setScaleX(xk*ptScale)
				else
				    temp = UI.createSpriteWithFile("images/buildItemDirectionB.png")
				    temp:setScaleX(-xk*ptScale)
				end
				temp:setScaleY(ptScale)
				screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=ssize.width*(1+gSize)/4/gSize*xk, y=ssize.height*(1+gSize)/4/gSize *yk})
				self.pt:addChild(temp)
			end
			screen.autoSuitable(self.pt, {nodeAnchor=General.anchorCenter, x=ssize.width/2, y=ssize.height/2})
			self.view:addChild(self.pt, -1)
		end
		if not state.isBuying then
			EventManager.sendMessage("EVENT_BUILD_FOCUS", self)
			self.buildMould:onFocus(true)
		end
	else
		if build then
			build:stopAllActions()
			--if state.nightMode then
			--	build:setColor(General.nightColor)
			--else
			--	build:setColor(General.normalColor)
			--end
			if self.backViewState then
				build:setPositionY(self.backViewState[2])
				build:setScaleX(self.backViewState[3])
				build:setScaleY(self.backViewState[4])
			else
				self:setViewState(build)
			end
		end
		state.isFocus = false
		scene.focusBuild = nil
		if self.circle then
			local sactions = CCArray:create()
			sactions:addObject(CCScaleTo:create(0.15, 1.1, 1.1))
			sactions:addObject(CCScaleTo:create(0.15, 0.01, 0.01))
			self.circle:stopAllActions()
			self.circle:runAction(CCSequence:create(sactions))
			self.circle:runAction(CCAlphaTo:create(0.3, 255, 0))
			delayRemove(0.3, self.circle)
			self.circle = nil
		end
		if self.pt then
			self.pt:removeFromParentAndCleanup(true)
			self.pt = nil
		end
		EventManager.sendMessage("EVENT_BUILD_UNFOCUS", self)
		self.buildMould:onFocus(false)
	end
end

function BuildView:readyToMove()
	local state = self.state
	local scene = self.scene
	state.planTouchPoint = scene.ground:convertToNodeSpace(CCPointMake(state.touchPoint.x, state.touchPoint.y))
	state.basePosX = self.view:getPositionX()
	state.basePosY = self.view:getPositionY() + self.buildMould.buildData.gridSize*scene.mapGrid.sizeY/2
end

function BuildView:checkTouch(x, y)
    if not self.buildMould then return false end
    if self.buildMould.buildLevel>0 and self.build and self.buildMould:touchTest(x, y) then
		return true
	elseif self.flyNode and isTouchInNode(self.flyNode, x, y) then
		return true
	else
	    local scene = self.scene
		local groundPoint = scene.ground:convertToNodeSpace(CCPointMake(x, y))
		local grid = self.state.grid
		if scene.mapGrid:isTouchInGrid(groundPoint.x, groundPoint.y, grid.gridPosX, grid.gridPosY, grid.gridSize) then
			return true
		end
	end
end
	
function BuildView:onTouchBegan(x, y)
	local state = self.state
	state.touchPoint = {x = x, y = y}
	if state.movable then
		if state.isFocus then
			self:readyToMove()
		end
		return true
	end
	return false
end

function BuildView:onTouchMoved(ox, oy)
	local state = self.state
	local scene = self.scene
	
	local grid = self.state.grid
	if state.isFocus and state.movable then
	    local x, y = state.touchPoint.x+ox, state.touchPoint.y+oy
		local planTouchPoint = scene.ground:convertToNodeSpace(CCPointMake(x, y))
		local newGrid = scene.mapGrid:convertToGrid(planTouchPoint.x - state.planTouchPoint.x + state.basePosX,
			planTouchPoint.y - state.planTouchPoint.y + state.basePosY, grid.gridSize)
		if newGrid.gridPosX ~= grid.gridPosX or newGrid.gridPosY ~= grid.gridPosY then
			self:moveGrid(newGrid)
	           music.playEffect("music/buildMove.mp3")
		end
		return true
	end
end

function BuildView:onTouchEnded(x, y)
	local state = self.state
	local scene = self.scene
	if state.isFocus then
		if state.moveState==nil  then
			self:setFocus(false)
		elseif state.moveOk and state.movable and not state.isBuying then
			self:resetGrid()
			
	        music.playEffect("music/buildSet.mp3")
			self.scene:showBuildingArea()
		end
	else
		if not self.flyNode or not self.buildMould:flyNodeTouched() then
			self:setFocus(true)
		end
	end
	state.touchPoint = nil
end
	
function BuildView:onTouchCanceled(x, y)
	self.state.touchPoint = nil
end

function BuildView:setDamageView()
    if self.viewDeleted then return end
	local bid = self.buildMould.buildData.bid
	local gridSize = self.buildMould.buildData.gridSize
	local x, y = self.view:getPosition()
	y = y + self.view:getContentSize().height/2
	local z = self.scene.SIZEY-y+1
	local t = getParam("actionTimeBuildBomb", 1100)/1000
	local bomb 
	if bid==3006 then
		bomb = UI.createAnimateWithSpritesheet(t, "wallFire_", 10, {isRepeat=false, plist="animate/build/wallFire.plist"})
		y=y+15
	else
		bomb = UI.createAnimateWithSpritesheet(t, "bombFire_", 9, {isRepeat=false, plist="animate/build/bombFire.plist"})
		if gridSize==2 or gridSize==5 then
			bomb:setScale(0.8)
		elseif gridSize==4 then
			bomb:setScale(1.2)
		elseif gridSize==6 then
		    bomb:setScale(1.44)
		end
	end
	music.playEffect("music/buildBomb.mp3")
	screen.autoSuitable(bomb, {nodeAnchor=General.anchorCenter, x=x, y=y})
	self.scene.ground:addChild(bomb, z)
	delayRemove(t, bomb)
	delayCallback(t*2/11, self.setDamageView2, self)
end

function BuildView:setDamageView2()
    if self.viewDeleted then return end
	local bid = self.buildMould.buildData.bid
	local gridSize = self.buildMould.buildData.gridSize
	local t = getParam("actionTimeBuildChip", 1100)/1000
	local x, y = self.view:getPosition()
	y = y + self.view:getContentSize().height/2
	local z = self.scene.SIZEY-y
	
	local bomb 
	if bid==3006 then
		bomb = UI.createAnimateWithSpritesheet(t, "wallChip_", 7, {isRepeat=false, plist="animate/build/wallChip.plist"})
		--bomb:setScale(10)
		y=y+51
	else
		bomb = UI.createAnimateWithSpritesheet(t, "bombChip_", 11, {isRepeat=false, plist="animate/build/bombChip.plist"})
		local sc = 1
		if gridSize==2 or gridSize==5 then
		    sc = 0.6
		elseif gridSize==6 then
		    sc = 1.2
		elseif gridSize==3 then
		    sc = 0.8
		end
	    bomb:setScale(sc)
		y=y+sc*165
	end
	screen.autoSuitable(bomb, {nodeAnchor=General.anchorTop, x=x, y=y})
	self.scene.ground:addChild(bomb, z)
	delayRemove(t, bomb)
	self:resetBuildView()
end

function BuildView:damage(value)
	if self.deleted or self.buildMould.buildData.hitPoints==0 then return end
	self.hitpoints = self.hitpoints - value
	if self.blood then
		self.blood:changeValue(self.hitpoints)
	end
	if self.scene.sceneType == SceneTypes.Zombie then
	    local bid = self.buildMould.buildData.bid
	    if (bid==0 or bid==2005) and (not self.helpTime or self.helpTime <= timer.getTime()) then
	        self.helpTime = timer.getTime() + getParam("actionIntevalHelp", 2700)/1000
	        local temp = UI.createAnimateWithSpritesheet(0.3, "help", 2, {isRepeat=false, plist="animate/effects/normalEffect.plist"})
	        screen.autoSuitable(temp, {x=self.view:getPositionX()+20, y=self.view:getPositionY()+158})
	        self.scene.effectBatch:addChild(temp)
	        delayRemove(1, temp)
	    end
	end
	if self.hitpoints <= 0 then
		self.hitpoints = 0
		self.deleted = true
		
        if self.buildMould.buildState~=BuildStates.STATE_DESTROY then
			self.buildMould.buildState = BuildStates.STATE_DESTROY
			self:damageGridUse(self.state.grid)
			-- TODO
			self:setDamageView()

			self.buildMould.deleted = true
			if self.scene.sceneType == SceneTypes.Battle then
				BattleLogic.destroyBuild(self.buildMould.buildData.bid, self.buildMould.id)
			elseif self.scene.sceneType == SceneTypes.Zombie then
				if self.state.isFocus then
					self:setFocus(false)
				end
				self.buildMould:onZombieDamage()
			end
		end
		if self.blood then
			self.blood.view:removeFromParentAndCleanup(true)
			self.blood = nil
		end
	else
		local t = getParam("attackEffectTime", 400)/1000
		local item = UI.createAnimateWithSpritesheet(t, "attackEffect" .. math.random(2) .. "_", 3, {isRepeat=false, plist="animate/effects/normalEffect.plist"})
		screen.autoSuitable(item, {nodeAnchor=General.anchorCenter, x=self.view:getPositionX()+math.random(40)-20, y=self.view:getPositionY()+self.view:getContentSize().height/2+math.random(30)-15})
		item:setRotation(math.random(360))
		self.scene.effectBatch:addChild(item, 100)
		delayRemove(t, item)
	end
	if self.scene.sceneType == SceneTypes.Battle then
		BattleLogic.setBuildHitpoints(self.buildMould.id, self.hitpoints)
	end
end

function BuildView:setViewState(build)
	build:setScale(getParam("buildViewScale" .. self.buildMould.buildData.bid, 100)/100)
	local ssize = self.view:getContentSize()
	screen.autoSuitable(build, {x=getParam("buildViewOffx" .. self.buildMould.buildData.bid, 0)+ssize.width/2, y=getParam("buildViewOffy" .. self.buildMould.buildData.bid, 0), nodeAnchor=General.anchorBottom})
end

function BuildView:addShadow()
    if self.bottom and self.buildMould.getBuildShadow then
        local shadow = self.buildMould:getBuildShadow()
    	if shadow then
        	local x, y = shadow:getPosition()
        	local size = self.bottom:getContentSize()
            local tsize = self.view:getContentSize()
            shadow:setPosition(x+size.width/2-tsize.width/2, y)
            self.bottom:addChild(shadow, 1, 1)
    	end
    	self.shadow = shadow
    end
end

function BuildView:resetBuildView()
	local isFocus = self.state.isFocus
	if isFocus then
		self:setFocus(false)
	end
	if not self.displayState or self.displayState.level~=self.buildMould.buildLevel or self.displayState.state ~= self.buildMould.buildState then
		if self.build then
		    self.build:removeFromParentAndCleanup(true)
			self.build = nil
		end
		if self.shadow then
			self.shadow:removeFromParentAndCleanup(true)
			self.shadow = nil
		end
		self.displayState = {level = self.buildMould.buildLevel, state=self.buildMould.buildState}
		if self.displayState.state == BuildStates.STATE_FREE or self.displayState.state == BuildStates.STATE_BUILDING then
			if self.isOperationDestroy then
			    self:addDestroyView()
			elseif self.displayState.level>0 then
				local buildData = self.buildMould.buildData
				self.build = self.buildMould:getBuildView(self.state)
				self:setViewState(self.build)
				self.view:addChild(self.build)
				
				if self.bottom then
					self:addShadow()
				end
			else
				self.build = self.buildMould:getLevel0Build()
				self.view:addChild(self.build)
				if self.buildMould.level0shadow and self.bottom then
				    self:addShadow()
				end
			end
			self.backViewState = {self.build:getPositionX(), self.build:getPositionY(), self.build:getScaleX(), self.build:getScaleY()}
			if self.displayState.state == BuildStates.STATE_FREE then
				if self.buildingView then
					self.buildingView:removeFromParentAndCleanup(true)
					self.buildingView = nil
				end
				if self.timeProcess then
					self.timeProcess.view:removeFromParentAndCleanup(true)
					self.timeProcess = nil
				end
			elseif self.displayState.state == BuildStates.STATE_BUILDING then
				if self.notice then
					self.notice:removeFromParentAndCleanup(true)
					self.notice = nil
				end
				if not self.buildingView and not self.buildMould.disBuildingView then
					self.buildingView = self:getBuildingView()
					self.view:addChild(self.buildingView, 1)
				end
				if not self.timeProcess and self.scene.sceneType==SceneTypes.Operation then
					self:createTimeProcess("images/buildItemBuildingFiller.png", self.buildMould.buildEndTime, self.buildMould.buildTotalTime)
				end
			end
			if self.blood then
				local y = self.buildMould:getBuildY()
				self.blood.view:setPositionY(y+35)
			end
		else
			if self.buildingView then
				self.buildingView:removeFromParentAndCleanup(true)
				self.buildingView = nil
			end
			self:addDestroyView()
		end
	end
	if self.state.nightMode~=UserData.isNight then
	    self.state.nightMode = UserData.isNight
	end
	if self.state.nightMode then
	    recurSetColor(self.build, General.nightColor)
	    if self.buildingView then
	        self.buildingView:setColor(General.nightColor)
	    end
	    if self.buildMould.buildLevel>0 and self.buildMould.buildState==BuildStates.STATE_FREE then
			self.buildMould:changeNightMode(self.state.nightMode)
	    end
	end
	if isFocus then
		self:setFocus(true)
	end
end

function BuildView:addDestroyView()
    local bid = self.buildMould.buildData.bid
	local gridSize = self.buildMould.buildData.gridSize
	if gridSize==5 then
		self.build = UI.createSpriteWithFrame("buildDestroy2.png")
		screen.autoSuitable(self.build, {nodeAnchor=General.anchorBottom, x=self.scene.mapGrid.sizeX*gridSize/2, y=self.scene.mapGrid.sizeY*3/2})
	else
		if bid>=3000 and bid<=3007 and gridSize==3 then
		    self.build = UI.createSpriteWithFrame("buildDestroy3b.png")
		else
			self.build = UI.createSpriteWithFrame("buildDestroy" .. gridSize .. ".png")
		end
		screen.autoSuitable(self.build, {nodeAnchor=General.anchorBottom, x=self.scene.mapGrid.sizeX*gridSize/2, y=0})
	end
	if self.isOperationDestroy then
	    self.view:addChild(self.build)
	else
    	local x, y = self.view:getPosition()
    	local x1, y1 = self.build:getPosition()
    	self.build:setPosition(x, y+y1)
    	self.scene.bottomSprite:addChild(self.build, 10)
    end
end

function BuildView:getBuildingView()
	local temp
	local gsize = self.buildMould.buildData.gridSize
	if gsize==2 then
		temp = UI.createSpriteWithFile("images/buildItemUpgrade2.png")
		screen.autoSuitable(temp, {x=92, y=0, nodeAnchor=General.anchorBottom})
	elseif gsize==3 then
		temp = UI.createSpriteWithFile("images/buildItemUpgrade4.png")
		temp:setScale(0.8)
		screen.autoSuitable(temp, {x=136, y=5, nodeAnchor=General.anchorBottom})
	elseif gsize==4 then
		temp = UI.createSpriteWithFile("images/buildItemUpgrade4.png")
		screen.autoSuitable(temp, {x=184, y=0, nodeAnchor=General.anchorBottom})
	elseif gsize==5 then
		temp = UI.createSpriteWithFile("images/buildItemUpgrade2.png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=230, y=98})
	elseif gsize==6 then
		temp = UI.createSpriteWithFile("images/buildItemUpgrade6.png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=276, y=0})
	end
	return temp
end

function BuildView:createTimeProcess(processImg, endTime, totalTime)
	local timeProcess = {endTime = endTime, totalTime=totalTime}
	
	timeProcess.view = UI.createSpriteWithFile("images/buildItemBuildingBack.png", CCSizeMake(221, 36))
						
	local temp = UI.createSpriteWithFile(processImg, CCSizeMake(215, 28))
	screen.autoSuitable(temp, {x=3, y=4})
	timeProcess.view:addChild(temp)
	UI.registerAsProcess(temp, timeProcess)
	timeProcess.process = temp
	
	temp = UI.createLabel(StringManager.getTimeString(totalTime), General.font4, 33)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=110, y=36})
	timeProcess.view:addChild(temp)
	timeProcess.timeLabel = temp
	
	local ssize = self.view:getContentSize()
	screen.autoSuitable(timeProcess.view, {nodeAnchor=General.anchorCenter, x=ssize.width/2, y=self.buildMould:getBuildY()+30})
	self.view:addChild(timeProcess.view, 2)
	
	self.timeProcess = timeProcess
	self:updateTimeProcess()
	
	local function callfuncUpdate()
		self:updateTimeProcess()
	end
	timeProcess:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(callfuncUpdate))))
end

function BuildView:updateTimeProcess()
	local leftTime = squeeze(self.timeProcess.endTime - timer.getTime(), 0, self.timeProcess.totalTime)
	local labelText = StringManager.getTimeString(leftTime)
	if labelText~=self.timeProcess.labelText then
		self.timeProcess.labelText = labelText
		self.timeProcess.timeLabel:setString(labelText)
	end
	UI.setProcess(self.timeProcess.process, self.timeProcess, (self.timeProcess.totalTime-leftTime)/self.timeProcess.totalTime)
end

function BuildView:readyToBuy()
	if self.state.moveOk then
		self:buyOver(true)
	end
end

function BuildView:cancelBuy()
	self:buyOver(false)
end

function BuildView:buyOver(suc)
	self:setFocus(false)
	self.scene.buyingBuild = nil
	if not suc or not self.buildMould:beginBuy() then
		self.view:removeFromParentAndCleanup(true)
		if self.buildMould.buildData.bid == GuideLogic.backupBid then
		    GuideLogic.guideBid = GuideLogic.backupBid
    		EventManager.sendMessage("EVENT_GUIDE_STEP", {"menu", "shop", GuideLogic.backupBid})
    		GuideLogic.backupBid = nil
		end
	else
		self:resetBuyingView(true)
		self:resetGrid()
		self.state.isBuying = false
		self:resetBuildView()
		self.buildMould:continueBuild()
		if self.buildMould.buildData.bid==GuideLogic.guideBid then
		    GuideLogic.guideBid = nil
		    local pt = GuideLogic.addPointer(0)
            pt:setPosition(self.view:getContentSize().width/2, self.buildMould:getBuildY())
            self.view:addChild(pt, 100)
		end
	end
end

function BuildView:removeView()
	if self.state.isFocus then
		self:releaseFocus(false)
	end
	if self.moveState==nil and self.bottom then
		self.bottom:removeFromParentAndCleanup(true)
	end
	
	self.view:removeFromParentAndCleanup(true)
	
	self:resetGridUse(self.state.backGrid, nil)

	self.buildMould = nil
	self.deleted = true
end

function BuildView:update(diff)
	if display.isSceneChange then return end
	
	local state = self.state
	local sceneType = self.scene.sceneType
	if sceneType==SceneTypes.Operation and not state.isBuying then
		self.buildMould:updateOperation(diff)
		if self.buildMould then
    		
    	end
	elseif sceneType==SceneTypes.Zombie then
		local bdata = self.buildMould.buildData
		if self.buildMould.builder and bdata.bid~=2004 then
			self.hitpoints = self.hitpoints + bdata.hitPoints*diff/(getParam("zombieRepairTime", 20000)/1000)
			if self.hitpoints>=bdata.hitPoints then
				self.buildMould:cancelRepair()
				self.hitpoints = bdata.hitPoints
			end
			if not self.deleted and self.blood then
				self.blood:changeValue(self.hitpoints)
			end
		end
		if self.buildMould.updateBattle then
			self.buildMould:updateBattle(diff)
		end
	elseif sceneType==SceneTypes.Battle and self.buildMould.updateBattle then
		self.buildMould:updateBattle(diff)
    elseif sceneType==SceneTypes.Visit then
        self.buildMould:updateVisit(diff)
	end
end

function BuildView:changeUpdateState(isOpen)
	local mould = self.buildMould
	local scene = self.scene
	local opened = mould.updateOpened
	if not opened and isOpen then
		if (scene.sceneType==SceneTypes.Operation or scene.sceneType==SceneTypes.Visit) and (mould.buildState==BuildStates.STATE_BUILDING or (mould.updateOperationLogic and mould.buildState==BuildStates.STATE_FREE and mould.buildLevel>0 and not self.isOperationDestroy)) then
			if scene.sceneType==SceneTypes.Operation then
				UpdateLogic.addUpdate(mould, mould.updateOperation)
			else
				UpdateLogic.addUpdate(mould, mould.updateVisit)
			end
		end
	elseif opened and isOpen then
		self.updateDeleted = nil
	elseif opened then
		if (scene.sceneType==SceneTypes.Operation or scene.sceneType==SceneTypes.Visit) and mould.buildState~=BuildStates.STATE_BUILDING and not mould.updateOperationLogic then
			self.updateDeleted = true
		end
	end
end

function BuildView:enterOrExit(enter)
    if enter then
        self.viewDeleted = nil
        self.updateDeleted = nil
        self:changeUpdateState(true)
    else
        self.viewDeleted = true
        self.updateDeleted = true
    end
end

function BuildView:ctor(buildMould, scene, setting)
    self.tempBuildId = scene:getTempBuildId() 
    scene.bidToBuildView[self.tempBuildId] = self
    
    self.depthInfo = nil
    self.debug = true

	self.buildMould = buildMould
	buildMould.buildView = self
	
	local state = {nightMode=false}
	state.movable = (scene.sceneType == SceneTypes.Operation and not buildMould.disMovable and (buildMould.buildLevel>0 or buildMould.buildState==BuildStates.STATE_BUILDING))
	
	local params = setting or {}
	local buildData = buildMould.buildData
	local level = buildMould.buildLevel
	local gridSize = buildData.gridSize
	
	local initGridX, initGridY = params.initGridX, params.initGridY
	local grid
	if not initGridX or not initGridY then
		local centerPoint = scene.ground:convertToNodeSpace(CCPointMake(General.winSize.width/2, General.winSize.height/2))
		grid = scene.mapGrid:convertToGrid(centerPoint.x, centerPoint.y, gridSize)
	else
		grid = {gridPosX=initGridX, gridPosY=initGridY, gridSize=gridSize}
	end
	
	state.grid = grid
	
	local bg = CCExtendNode:create(CCSizeMake(scene.mapGrid.sizeX*gridSize, scene.mapGrid.sizeY*gridSize), false)
	screen.autoSuitable(bg, {nodeAnchor=General.anchorBottom})
	
	local layer = CCLayer:create()
	bg:addChild(layer)
	
	self.view = bg
	self.uiview = UI.createSpriteWithFile("images/normalFiller.png")
	self.uiview:setTextureRect(CCRectMake(0,0,scene.mapGrid.sizeX*gridSize,0))
	screen.autoSuitable(self.uiview, {nodeAnchor=General.anchorBottom})
	
	self.layer = layer
	self.state=state
	self.scene=scene
	self.hitpoints = buildData.hitPoints
	if (scene.sceneType==SceneTypes.Operation or scene.sceneType==SceneTypes.Visit) and params.hitpoints then
	    self.hitpoints = squeeze(params.hitpoints, 0, buildData.hitPoints)
	    if self.hitpoints < buildData.hitPoints/5 then
	        self.isOperationDestroy = true
	    end
	end
	
	if buildData.hitPoints>0 then
		self.blood = UI.createBloodProcess(buildData.hitPoints, scene.sceneType==SceneTypes.Battle)
		self.blood:changeValue(self.hitpoints, scene.sceneType == SceneTypes.Operation)
		screen.autoSuitable(self.blood.view, {nodeAnchor=General.anchorBottom, x=scene.mapGrid.sizeX*gridSize/2, y=scene.mapGrid.sizeY*gridSize+20})
		self.uiview:addChild(self.blood.view, 100)
		
		if scene.sceneType == SceneTypes.Operation and self.hitpoints < buildData.hitPoints then
			local itime = 0.1
			local hspeed = getParam("buildHitpointsSpeed", 50)*itime
			
			local haction = nil
			local function updateBlood()
				if display.isSceneChange then return end
		    	if self.hitpoints<buildData.hitPoints then
	    		    self.hitpoints = squeeze(self.hitpoints+hspeed, self.hitpoints, buildData.hitPoints)
	    		    self.blood:changeValue(self.hitpoints, self.hitpoints<buildData.hitPoints)
	    		    if self.isOperationDestroy and self.hitpoints > buildData.hitPoints/5 then
	    		        self.isOperationDestroy = nil
	    		        self.displayState = nil
	    		        self:resetBuildView()
	    		    end
	    		else
	    			self.blood.view:stopAction(haction)
	    		end
			end
			self.blood.view:setVisible(true)
			self.blood.view:setOpacity(255)
			self.blood.process:setOpacity(255)
			haction = CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(updateBlood)))
			self.blood.view:runAction(haction)
		end
	end
	
	self:resetBuildView()
	
	local inteval = 0.5
	if buildData.bid>=3000 and buildData.bid<4000 and buildData.bid~=3006 then inteval=0.05 end
	self.eventEntries = {enterOrExit={callback=self.enterOrExit}}
		
	state.isBuying = params.isBuying
	if not state.isBuying then
		self:resetGrid()
	else
		self:setFocus(true)
		self:moveGrid(grid)
	end
end
