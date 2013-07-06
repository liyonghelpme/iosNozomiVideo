Bomb = class(Soldier)

function Bomb:ctor()
	local scale = getParam("soldierScale" .. self.info.sid, 100)/100
	self.viewInfo = {scale=scale, x=0, y=20*scale}
end

-- to override
function Bomb:resetOtherState()
	if self.stateInfo.action == "pose" then
		self.displayState.duration = getParam("soldierPoseTime" .. self.info.sid, 500)/1000
		self.displayState.isRepeat = false
		self.displayState.num = 5
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_p"
	elseif self.stateInfo.action == "attack"  then
		self.displayState.duration = 0.9
		self.displayState.isRepeat = false
		self.displayState.num = 9
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_a"
	end
end

-- to override
function Bomb:prepareAttack()
	self.stateInfo = {actionTime=self.info.attackSpeed}
	self.stateInfo.attackValue = self:getAttackValue()
	self.stateInfo.attackTime = self.info.attackSpeed
	self.stateInfo.action = "attack"
end

-- to override
-- 爆炸人打普通建筑物的攻击力
function Bomb:executeAttack()
--wtf
    local attackValue = self.data.dps*self.info.attackSpeed
	local grid = self.scene.mapGrid:convertToGrid(self.view:getPositionX(), self.view:getPositionY())
    for _, enemy in pairs(self.scene.builds) do
		local tgrid = enemy.buildView.state.grid
		local fsize = tgrid.gridSize/2
		local gsize = (tgrid.gridSize-enemy.buildData.soldierSpace)/2
		local dx, dy = math.abs(tgrid.gridPosX + fsize - (grid.gridPosX + grid.gridFloatX))-gsize, math.abs(tgrid.gridPosY + fsize - (grid.gridPosY + grid.gridFloatY))-gsize
		local inDis = false
		--print("wtf", dx, dy)
		if dx<=0 then
			if dy<=self.info.damageRange then
				inDis = true
			end
		elseif dy<=0 then
			if dx<=self.info.damageRange then
				inDis = true
			end
		elseif dx*dx+dy*dy<=self.info.damageRange*self.info.damageRange then
			inDis = true
		end
		if inDis then
		    local k = 1
		    if enemy.buildData.bid==3006 then k=self.info.favoriteRate end
			enemy.buildView:damage(k*attackValue)
		end
	end
	--self.attackTarget:damage(self.stateInfo.attackValue)
	
	local x, y = self.view:getPosition()
	y = self.viewInfo.y + y
	
	local t=0.9
	local bomb = UI.createAnimateWithSpritesheet(t, "robotAttack_", 8, {plist="animate/effects/robotAttack.plist"})
	screen.autoSuitable(bomb, {nodeAnchor=General.anchorCenter, x=x, y=y})
	self.scene.ground:addChild(bomb, self.scene.SIZEY-y+1)
	delayRemove(t, bomb)
	
	t=1.4
	bomb = UI.createAnimateWithSpritesheet(t, "bombNormal_", 13, {plist="animate/effects/normalEffect.plist"})
	screen.autoSuitable(bomb, {nodeAnchor=General.anchorCenter, x=x, y=y})
	self.scene.effectBatch:addChild(bomb, self.scene.SIZEY-y)
	delayRemove(t, bomb)
	
	self:damage(self.hitpoints)
end
--[[
function Bomb:searchAttack()
    local target
    local w = self.scene.mapWorld
    local newWorld = self.scene.newWorld
    local truePath
    if not newWorld.searchYet then
        local fx, fy = self.view:getPosition()
        local grid = self.scene.mapGrid:convertToGrid(fx, fy, 1, 2)
        local startPoint = {grid.gridPosX, grid.gridPosY}

        self:clearAllPath()
        newWorld.startPoint = ccp(startPoint[1], startPoint[2])
        newWorld.attackRange = self.info.range*2;
        newWorld.favorite = -1;
        newWorld.unitType = self.info.unitType

        local result = newWorld:searchWall()
        print("result ", result, result.path, result.bid)
        local path = {}
        local targetId
        local target
        local lastPoint
        local len = result.path:getLength() 
        print("pathlength", len)
        for i=0, len-1 do
            local p = result.path:objectAt(i)
            table.insert(path, {p.x, p.y})
        end
        targetId = result.bid;
        lastPoint = {path[#path][1], path[#path][2]}
        lastPoint[1] = lastPoint[1]+math.random()*0.6-0.3
        lastPoint[2] = lastPoint[2]+math.random()*0.6-0.3
        result:delete()
        target = self.scene.bidToBuildView[targetId]

        if lastPoint then
            local position = self.scene.mapGrid:convertToPosition(lastPoint[1]/2, lastPoint[2]/2)
            local tx, ty = position[1] , position[2]
            truePath = self:getTruePath(path, w, self.scene.mapGrid, fx, fy, tx, ty)
            self.gridPath = path
            self.truePath = truePath
            --第一个顶点
            self.setFromToGrid({0, 0, 1}, self.truePath[1])
            self:setPathCount()
        end
        if target then
            self.attackTarget = target
            if truePath then
                local firstPoint = table.remove(truePath, 1)
                self.stateInfo = {movePath = truePath}
                if self.state ~= PersonState.STATE_MOVING then
                    self.stateTime = 0
                end
                --设定当前阶段的网格开始 结束编号 
                self:setFromToGrid({0, 0, 1}, firstPoint)
                self:moveDirect(firstPoint[1], firstPoint[2], true)
            else
                self:setAttack()
                return true
            end
        else
            self:setDeadView()
        end
        --target 可能是城墙 也可能不是 造成的伤害不同
        --if target.buildMould.buildData.bid == 3006 then
        --end
    end
end
--]]

function Bomb:updateState(diff)
    self:showDebugState()
	if self.isFighting then
		if BattleLogic.battleEnd then
			self:setDeadView()
		elseif not self.attackTarget then
            self:clearAttackState()
		    return self:searchAttack()
		elseif self.attackTarget and self.attackTarget.deleted then
            print("bomb searchPath")
            self:clearAttackState()
            self:searchAttack()
            return true
            --[[
			local target
			local truePath
			local min
			
			-- 获取起点，都相同
			local fx, fy = self.view:getPosition()
			local grid = self.scene.mapGrid:convertToGrid(fx, fy, 1)
			min = 80
			
			for gkey, build in pairs(self.scene.walls) do
				if not build.deleted then
					local gx, gy = math.floor(gkey/10000), gkey%10000
					local dis = math.abs(gx-grid.gridPosX)+math.abs(gy-grid.gridPosY)
					if dis < min then
						min = dis
						target = build.buildView
					end
				end
			end
			
			if target then
				local tx, ty = target.view:getPosition()
				ty = ty+target.view:getContentSize().height/2
				local ox, oy = fx-tx, fy-ty
				local angle = math.atan2(oy/self.scene.mapGrid.sizeY, ox/self.scene.mapGrid.sizeX)
				tx = tx+math.cos(angle)*self.scene.mapGrid.sizeX
				ty = ty+math.cos(angle)*self.scene.mapGrid.sizeY
				
				self.attackTarget = target
				self:setMoveTarget(tx, ty)
			else
				self:setDeadView()
			end
            --]]
		elseif self.state == PersonState.STATE_FREE then
			self:setAttack()
			return true
		elseif self.state == PersonState.STATE_OTHER then
		 	local action = self.stateInfo.action
		 	if not action then
		 		print("error")
		 	end
		 	local pb = string.find(action, "attack")
		 	if pb==1 then
			 	if self.stateInfo.attackTime and self.stateInfo.attackTime<self.stateTime then
			 		self.stateInfo.attackTime = nil
			 		self:executeAttack()
			 	end
		 		if not self.deleted and self.stateInfo.actionTime < self.stateTime then
			 		self:setAttack()
			 		return true
			 	end
			 end
		end
		if diff==0 then
			-- 入场后的掉落动画，先不实现
		end
	else
        self:searchBusiness(diff)
        --[[
		if self.state == PersonState.STATE_FREE then
			if self.stateTime > getParam("soldierFreeTime", 1500)/1000 then
				self.stateTime = 0
				if math.random()>0.5 then
					self:setMoveArround()
					return true
				end
			end
		elseif self.state == PersonState.STATE_OTHER and self.stateTime > self.stateInfo.actionTime then
			if self.stateInfo.action=="pose" then
				self.stateTime = 0
				self.state = PersonState.STATE_FREE
				self.stateInfo.action = "free"
				self.direction = 1
			end
			self:resetPersonView()
			return true
		end
        --]]
	end
end
