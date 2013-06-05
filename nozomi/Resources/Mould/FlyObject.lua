
FlyObject = class()

function FlyObject:ctor(attack, speed, x, y)
	self.attackValue = attack
	self.speed = speed
	self.initPos = {x, y}
end

function FlyObject:addToScene(scene)
	self.scene = scene
	if self.targetPos then
		self:initView()
		self.stateTime = 0
	end
end

SingleShot = class(FlyObject)

function SingleShot:ctor(attack, speed, x, y, z, target)
	self.target = target
	self.initZorder = z
	self:resetTargetPos()
end

function SingleShot:resetTargetPos()
	if self.target.deleted then
		return
	end
	self.targetPos = {self.target.view:getPositionX(), self.target.view:getPositionY() + self.target.view:getContentSize().height/2}
	if self.target.viewInfo then
		self.targetPos[2] = self.targetPos[2] + self.target.viewInfo.y
	end
end

function SingleShot:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		if state==2 then
			self.target:damage(self.attackValue)
		end
		self.view:removeFromParentAndCleanup(true)
		self:resetView()
	end
	if self.state==2 then
		local delta = stateTime/self.time[2]
		self.view:setPosition(self.initPos[1] + (self.targetPos[1]-self.initPos[1])*delta, self.initPos[2] + (self.targetPos[2]-self.initPos[2])*delta)
	end
	self.stateTime = stateTime
end

function SingleShot:initView()
	local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2])
	self.time = {0.5, distance*10/self.speed, 0.5}
	self.state = 1
	self:resetView()
end

function SingleShot:resetView()
	if self.target.deleted then
		return
	end
		local ox, oy = self.targetPos[1] - self.initPos[1], self.targetPos[2] - self.initPos[2]
		local dir = 0
		local temp = math.deg(math.atan2(oy, ox))
		dir = temp+180
	if self.state==1 then
		self.view = Effect.createGatherEffect(dir, self.time[1])
		screen.autoSuitable(self.view, {nodeAnchor=General.center, x=self.initPos[1], y=self.initPos[2]})
		simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
		self.scene.ground:addChild(self.view, self.initZorder)
	elseif self.state==2 then
		self.view = UI.createAnimateSprite(0.5, "animate/build/3000/attack_", 24)
		screen.autoSuitable(self.view, {nodeAnchor=General.center, x=self.initPos[1], y=self.initPos[2]})
		simpleRegisterEvent(self.view, {update={inteval=0, callback=self.update}}, self)
		self.scene.ground:addChild(self.view, self.scene.SIZEY)
	elseif self.state==3 then
		self.view = Effect.createBombEffect(self.time[3])
		screen.autoSuitable(self.view, {nodeAnchor=General.center, x=self.targetPos[1], y=self.targetPos[2]})
		simpleRegisterEvent(self.view, {update={inteval=self.time[3], callback=self.update}}, self)
		self.scene.ground:addChild(self.view, self.scene.SIZEY)
	end
end

CannonShot = class(SingleShot)

function CannonShot:ctor(attack, speed, x, y, z, target, level)
	self.level = level
end

function CannonShot:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		if state==2 then
			self.target:damage(self.attackValue)
		end
		self.view:removeFromParentAndCleanup(true)
		self:resetView()
	end
	if self.state==2 then
		--local delta = stateTime/self.time[2]
		--if not self.target.deleted then
		--    local x, y = self.target.view:getPosition()
		--    self.targetPos = {x, y+self.target.viewInfo.y}
		--end
		--self.view:setPosition(self.initPos[1] + (self.targetPos[1]-self.initPos[1])*delta, self.initPos[2] + (self.targetPos[2]-self.initPos[2])*delta)
	end
	self.stateTime = stateTime
end

function CannonShot:initView()
	local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2])
	self.time = {0.2, distance*10/self.speed, 0.5}
	self.state = 1
	self:resetView()
end

local CANNON_SCALE = {0.43, 0.43, 0.46, 0.57, 0.6, 0.63, 0.71, 0.74, 0.74, 0.74, 0.74}
local CANNON_OFFSET={180, 40, 280}
local CANNON_COLOR ={ccc4f(0.21, 0.88, 0.99, 1), ccc4f(1, 0.85, 0.23, 1), ccc4f(0.8, 0.15, 0.97, 1)}

function CannonShot:resetView()
	local ox, oy = self.targetPos[1] - self.initPos[1], self.targetPos[2] - self.initPos[2]
	local dir = 0
	local temp = math.deg(math.atan2(oy, ox))
	dir = temp+180
	if self.state==1 then
		if self.target.deleted then
			return
		end
		self.view = Effect.createGatherEffect(dir, self.time[1], CANNON_COLOR[math.ceil(self.level/4)])
		self.view:setScale(CANNON_SCALE[self.level]/CANNON_SCALE[1])
		screen.autoSuitable(self.view, {nodeAnchor=General.anchorCenter, x=self.initPos[1], y=self.initPos[2]})
		simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
		self.scene.ground:addChild(self.view, self.initZorder)
	elseif self.state==2 then
		if self.target.deleted then
			return
		end
		
    	if self.target.viewInfo then
    		-- is soldier
    		local x, y = self.target.view:getPosition()
    		self.targetPos = {x, y+self.target.viewInfo.y}
    		local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2])
    		local t2 = distance*10/self.speed
    		self.time[2] = t2
    		if self.target.state == PersonState.STATE_MOVING then
    			local stateInfo = self.target.stateInfo
    			if stateInfo.toPoint then
    				local delta = (self.target.stateTime-stateInfo.beginTime+t2)/stateInfo.moveTime
    				if delta<0 or delta>=1 then
    					self.targetPos = {stateInfo.toPoint[1], stateInfo.toPoint[2]+self.target.viewInfo.y}
    				else
    					self.targetPos = {stateInfo.fromPoint[1] + delta*(stateInfo.toPoint[1]-stateInfo.fromPoint[1]), stateInfo.fromPoint[2] + delta*(stateInfo.toPoint[2]-stateInfo.fromPoint[2])+self.target.viewInfo.y}
    				end
    			end
    		end
    	end
    	
	    music.playEffect("music/cannonShot.mp3")
		self.view = UI.createAnimateWithSpritesheet(0.5, "cannonAttack_", 6, {useExtend=true, plist="animate/effects/cannonAttack.plist"})
		self.view:setScale(CANNON_SCALE[self.level])
		self.view:setHueOffset(CANNON_OFFSET[math.ceil(self.level/4)], false)
		screen.autoSuitable(self.view, {nodeAnchor=General.anchorCenter, x=self.initPos[1], y=self.initPos[2]})
		self.view:runAction(CCMoveTo:create(self.time[2], CCPointMake(self.targetPos[1], self.targetPos[2])))
		
		if self.level==11 then
		    local ssize = self.view:getContentSize()
		    local temp = UI.createAnimateWithSpritesheet(0.5, "cannonThunder_", 24, {plist="animate/effects/cannonThunder.plist"})
		    screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=ssize.width/2, y=ssize.height/2})
		    self.view:addChild(temp, -1)
		end
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[2], callback=self.update}}, self)
		self.scene.ground:addChild(self.view, self.scene.SIZEY)
	elseif self.state==3 then
		self.view = Effect.createBombEffect(self.time[3], CANNON_COLOR[math.ceil(self.level/4)])
		self.view:setScale(CANNON_SCALE[self.level]/CANNON_SCALE[1])
		screen.autoSuitable(self.view, {nodeAnchor=General.anchorCenter, x=self.targetPos[1], y=self.targetPos[2]})
		simpleRegisterEvent(self.view, {update={inteval=self.time[3], callback=self.update}}, self)
		self.scene.ground:addChild(self.view, self.scene.SIZEY)
	    music.playCleverEffect("music/laserBomb.mp3")
	end
end

ThunderShot = class(SingleShot)

function ThunderShot:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		if state==1 then
		    if self.target.info.sid==10 then
		        self.target:damage(self.attackValue*2)
		    else
		        self.target:damage(self.attackValue)
		    end
			local temp = UI.createAnimateWithSpritesheet(self.time[2], "thunderAttacked_", 14, {plist="animate/effects/thunderAttack.plist"})
			--temp:setRotation(math.random(360))
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=self.targetPos[1], y=self.targetPos[2]})
			self.view2 = temp
			self.scene.ground:addChild(self.view2, self.scene.SIZEY-1)
		elseif state==2 then
			self.view:removeFromParentAndCleanup(true)
			self.view2:removeFromParentAndCleanup(true)
		end
	end
	self.stateTime = stateTime
end

function ThunderShot:initView()
	local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2])
	self.time = {0.1, 0.2}
	self.state = 1
	if self.target.deleted then
		return
	end
	local ox, oy = self.targetPos[1] - self.initPos[1], self.targetPos[2] - self.initPos[2]
	local dis = math.sqrt(ox*ox+oy*oy)
	local dir = 0
	local temp = math.deg(math.atan2(oy, ox))
	dir = -temp
	
	self.view = UI.createAnimateWithSpritesheet(self.time[1]+self.time[2], "thunderAttack_", 14, {isRepeat=false, plist="animate/effects/thunderAttack.plist"})
	self.view:setScaleX(dis/325)
	self.view:setAnchorPoint(CCPointMake(0.07, 0.5))
	self.view:setPosition(self.initPos[1], self.initPos[2])
	self.view:setRotation(dir)
	simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
	self.scene.ground:addChild(self.view, self.scene.SIZEY)
	
    music.playCleverEffect("music/thunder.mp3")
end

GunShot = class(SingleShot)

function GunShot:ctor(attack, speed, x, y, z, target, type, angle)
	self.type = type
	self.angle = angle
end

function GunShot:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		if state==1 then
			self.target:damage(self.attackValue)
			local temp = UI.createAnimateWithSpritesheet(self.time[2], "gunAttacked_", 3, {plist="animate/effects/normalEffect.plist"})
			temp:setRotation(math.random(360))
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=self.targetPos[1]+math.random(40)-20, y=self.targetPos[2]+math.random(30)-15})
			self.view2 = temp
			self.scene.effectBatch:addChild(self.view2, self.scene.SIZEY-1)
			self.view:setVisible(false)
		elseif state==2 then
			self.view:removeFromParentAndCleanup(true)
			self.view2:removeFromParentAndCleanup(true)
		end
	end
	self.stateTime = stateTime
end

function GunShot:initView()
	self.time = {0.064, 0.064}
	self.state = 1
	if self.target.deleted then
		return
	end
	local dir = 0
	local temp = self.angle
	dir = 90-temp
	
	self.view = UI.createSpriteWithFrame("gunAttack_" .. self.type .. ".png")
	self.view:setScaleX(0.5)
	self.view:setScaleY(0.5*(0.75+0.25*math.abs(math.sin(math.rad(self.angle)))))
	self.view:setAnchorPoint(CCPointMake(0.5, 0.2))
	self.view:setPosition(self.initPos[1], self.initPos[2])
	--screen.autoSuitable(self.view, {nodeAnchor=General.anchorBottom, x=self.initPos[1], y=self.initPos[2]})
	self.view:setRotation(dir)
	simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
	self.scene.effectBatch:addChild(self.view, self.initZorder)
	
    music.playCleverEffect("music/gunShot.mp3")
end

LaserShot = class(SingleShot)

function LaserShot:ctor(attack, speed, x, y, z, target, level, scale)
	self.level = level
	self.scale = scale
end

function LaserShot:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		if state==1 then
			self.target:damage(self.attackValue)
			
	        music.playCleverEffect("music/laserBomb.mp3")
		end
		self.view:removeFromParentAndCleanup(true)
	end
	self.stateTime = stateTime
end

function LaserShot:initView()
	local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2])
	self.time = {distance*10/self.speed}
	self.state = 1
	if self.target.viewInfo then
		-- is soldier
		if self.target.state == PersonState.STATE_MOVING then
			local stateInfo = self.target.stateInfo
			if stateInfo.toPoint then
				local delta = (self.target.stateTime-stateInfo.beginTime+self.time[1])/stateInfo.moveTime
				if delta<0 or delta>=1 then
					self.targetPos = {stateInfo.toPoint[1], stateInfo.toPoint[2]+self.target.viewInfo.y}
				else
					self.targetPos = {stateInfo.fromPoint[1] + delta*(stateInfo.toPoint[1]-stateInfo.fromPoint[1]), stateInfo.fromPoint[2] + delta*(stateInfo.toPoint[2]-stateInfo.fromPoint[2])+self.target.viewInfo.y}
				end
			end
		end
	end
	self:resetView()
end

function LaserShot:resetView()
	if self.state==1 then
		if self.target.deleted then
			return
		end
		local ox, oy = self.targetPos[1] - self.initPos[1], self.targetPos[2] - self.initPos[2]
		local dir = 0
		local temp = math.deg(math.atan2(oy, ox))
		dir = -temp
		
		self.view = UI.createSpriteWithFile("images/effects/laser.png", nil, self.level>1)
		if self.level==2 then
			self.view:setHueOffset(220, false)
		elseif self.level==3 then
			self.view:setHueOffset(118, false)
		end
		self.view:setAnchorPoint(CCPointMake(0.92, 0.5))
		self.view:setScaleX(0)
		self.view:setScaleY(self.scale)
		self.view:setPosition(self.initPos[1], self.initPos[2])
		self.view:setRotation(dir)
		
		self.view:runAction(CCMoveBy:create(self.time[1], CCPointMake(ox, oy)))
		
		local dis = math.sqrt(ox*ox+oy*oy)
		self.view:runAction(CCScaleTo:create(100*self.scale*self.time[1]/dis, self.scale, self.scale))
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
		self.scene.ground:addChild(self.view, self.scene.SIZEY)
		
		if self.target.viewInfo then
    	    music.playCleverEffect("music/laserShot.mp3")
    	else
    	    music.playCleverEffect("music/attack2.mp3")
    	end
	end
end

LaserShot2 = class(SingleShot)

function LaserShot2:ctor(attack, speed, x, y, z, target, level)
	self.level = level
end

function LaserShot2:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		if state==1 then
			self.target:damage(self.attackValue)
			music.playCleverEffect("music/laserBomb.mp3")
		end
		self.view:removeFromParentAndCleanup(true)
	end
	self.stateTime = stateTime
end

function LaserShot2:initView()
	local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2])
	self.time = {distance*10/self.speed}
	self.state = 1
	self:resetView()
end

function LaserShot2:resetView()
	if self.state==1 then
		if self.target.deleted then
			return
		end
		local ox, oy = self.targetPos[1] - self.initPos[1], self.targetPos[2] - self.initPos[2]
		local dir = 0
		local temp = math.deg(math.atan2(oy, ox))
		dir = -temp
		
		local dis = math.sqrt(ox*ox+oy*oy)
		
		self.view = UI.createSpriteWithFile("images/effects/laser2.png", nil, self.level>1)
		if self.level==2 then
			self.view:setHueOffset(220, false)
		elseif self.level==3 then
			self.view:setHueOffset(118, false)
		end
		self.view:setAnchorPoint(CCPointMake(0.5, 0.5))
		self.view:setScaleX(0)
		self.view:setPosition(self.initPos[1], self.initPos[2])
		self.view:setRotation(dir)
		
		self.view:runAction(CCMoveBy:create(self.time[1], CCPointMake(ox, oy)))
		local array = CCArray:create()
		array:addObject(CCScaleTo:create(self.time[1]/2, dis/271, 1))
		array:addObject(CCScaleTo:create(self.time[1]/2, 0, 1))
		self.view:runAction(CCSequence:create(array))
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
		self.scene.ground:addChild(self.view, self.scene.SIZEY)
		
	    music.playCleverEffect("music/laserShot.mp3")
	end
end

PoisonShot = class(SingleShot)

function PoisonShot:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		if state==1 then
			self.target:damage(self.attackValue)
		end
		self.view:removeFromParentAndCleanup(true)
	end
	self.stateTime = stateTime
end

function PoisonShot:initView()
	local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2])
	self.time = {distance*10/self.speed}
	self.state = 1
	self:resetView()
end

function PoisonShot:resetView()
	if self.state==1 then
		if self.target.deleted then
			return
		end
		local ox, oy = self.targetPos[1] - self.initPos[1], self.targetPos[2] - self.initPos[2]
		local dir = 0
		local temp = math.deg(math.atan2(oy, ox))
		dir = -temp
		
		self.view = UI.createAnimateWithSpritesheet(0.4, "poison_", 3, {plist="animate/effects/normalEffect.plist"})
		self.view:setAnchorPoint(CCPointMake(0.5, 0.5))
		self.view:setScaleX(0.3)
		self.view:setPosition(self.initPos[1], self.initPos[2])
		self.view:setRotation(dir)
		
		self.view:runAction(CCEaseSineIn:create(CCMoveBy:create(self.time[1], CCPointMake(ox, oy))))
		self.view:runAction(CCScaleTo:create(0.1, 0.75, 1))
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
		self.scene.effectBatch:addChild(self.view, self.scene.SIZEY)
	end
end

MissileShot = class(SingleShot)

function MissileShot:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		self.view:removeFromParentAndCleanup(true)
		if state==1 then
			self.target:damage(self.attackValue)
			self:resetView()
		end
	end
	self.stateTime = stateTime
end

function MissileShot:initView()
	local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2])
	self.time = {distance*10/self.speed, 1}
	self.state = 1
	self:resetView()
end

function MissileShot:resetView()
	if self.state==1 then
		local ox, oy = self.targetPos[1] - self.initPos[1], self.targetPos[2] - self.initPos[2]
		local dir = 0
		local temp = math.deg(math.atan2(oy, ox))
		dir = 180-temp
		
		self.view = UI.createAnimateWithSpritesheet(0.3, "missile_", 2, {plist="animate/effects/normalEffect.plist"})
		self.view:setAnchorPoint(CCPointMake(0.5, 0.5))
		self.view:setPosition(self.initPos[1], self.initPos[2])
		self.view:setRotation(dir)
		
		self.view:runAction(CCMoveBy:create(self.time[1], CCPointMake(ox, oy)))
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
		self.scene.effectBatch:addChild(self.view, self.scene.SIZEY)
	elseif self.state==2 then
		self.view = UI.createAnimateWithSpritesheet(self.time[2], "missileBomb_", 9, {plist="animate/effects/normalEffect.plist"})
		screen.autoSuitable(self.view, {nodeAnchor=General.anchorCenter, x=self.targetPos[1], y=self.targetPos[2]})
		simpleRegisterEvent(self.view, {update={inteval=self.time[2], callback=self.update}}, self)
		self.scene.effectBatch:addChild(self.view, self.scene.SIZEY-self.targetPos[2]+10)
	end
end

AirShot = class(SingleShot)

function AirShot:ctor(attackValue, speed, x, y, z, target, height)
    self.height = height
end

function AirShot:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		self.view:removeFromParentAndCleanup(true)
		if state==1 then
			self.target:damage(self.attackValue)
			self:resetView()
		end
	end
	self.stateTime = stateTime
end

function AirShot:initView()
	local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2])
	self.time = {distance*10/self.speed, 1.4}
	self.state = 1
	if self.target.viewInfo then
		-- is soldier
		if self.target.state == PersonState.STATE_MOVING then
			local stateInfo = self.target.stateInfo
			if stateInfo.toPoint then
				local delta = (self.target.stateTime-stateInfo.beginTime+self.time[1])/stateInfo.moveTime
				if delta<0 or delta>=1 then
					self.targetPos = {stateInfo.toPoint[1], stateInfo.toPoint[2]+self.target.viewInfo.y}
				else
					self.targetPos = {stateInfo.fromPoint[1] + delta*(stateInfo.toPoint[1]-stateInfo.fromPoint[1]), stateInfo.fromPoint[2] + delta*(stateInfo.toPoint[2]-stateInfo.fromPoint[2])+self.target.viewInfo.y}
				end
			end
		end
	end
	self:resetView()
end

function AirShot:resetView()
	if self.state==1 then
		if self.target.deleted then
			return
		end
		
		self.view = UI.createSpriteWithFrame("airShot.png")
		self.view:setAnchorPoint(CCPointMake(0.5, 0.5))
		self.view:setPosition(self.initPos[1], self.initPos[2])
		self.view:setRotation(-180)
		
		self.flame = UI.createAnimateWithSpritesheet(getParam("flameActionTime", 1000)/1000, "flame_", 19, {plist="animate/builder/flame.plist"})
		screen.autoSuitable(self.flame, {nodeAnchor=General.anchorTop, x=59, y=11})
		self.flame:setScaleX(0.5)
		self.flame:setScaleY(0.4)
		self.flame:setRotation(-90)
		self.view:addChild(self.flame, -1)
		
		--self.view:runAction(CCEaseIn:create(CCMoveBy:create(self.time[1], CCPointMake(ox, oy)), 2))
		Action.runGravityMove(self.view, self.time[1], self.initPos[1], self.initPos[2], self.targetPos[1], self.targetPos[2], self.height, self.target.viewInfo.y)
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
		self.scene.sky:addChild(self.view, self.scene.SIZEY+20000)
		
	    music.playEffect("music/airShot.mp3")
	elseif self.state==2 then
	
		self.view = UI.createAnimateWithSpritesheet(self.time[2], "bombNormal_", 13, {plist="animate/effects/normalEffect.plist"})
		screen.autoSuitable(self.view, {nodeAnchor=General.anchorCenter, x=self.targetPos[1], y=self.targetPos[2]})
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[2], callback=self.update}}, self)
		self.scene.sky:addChild(self.view, self.scene.SIZEY+20000)
		
	    music.playEffect("music/airBomb.mp3")
	end
end

GroupTypes = {Attack=1, Defense=2}

AreaSplash = class(FlyObject)

function AreaSplash:ctor(attackValue, speed, x, y, targetX, targetY, damageRange, group, unitType)
	self.targetPos = {targetX, targetY}
	self.unitType = unitType
	self.group = group
	self.damageRange = damageRange
end

function AreaSplash:executeDamage()
	--local num = 0
	if self.group==GroupTypes.Attack then
		local grid = self.scene.mapGrid:convertToGrid(self.targetPos[1], self.targetPos[2])
		local gx, gy = grid.gridPosX + grid.gridFloatX, grid.gridPosY + grid.gridFloatY
		if self.unitType~=2 then
			for _, enemy in pairs(self.scene.builds) do
				local tgrid = enemy.buildView.state.grid
				local fsize = tgrid.gridSize/2
				local gsize = (tgrid.gridSize-enemy.buildData.soldierSpace)/2
				local dx, dy = math.abs(tgrid.gridPosX + fsize - (grid.gridPosX + grid.gridFloatX))-gsize, math.abs(tgrid.gridPosY + fsize - (grid.gridPosY + grid.gridFloatY))-gsize
				local inDis = false
				if dx<=0 then
					if dy<=self.damageRange then
						inDis = true
					end
				elseif dy<=0 then
					if dx<=self.damageRange then
						inDis = true
					end
				elseif dx*dx+dy*dy<=self.damageRange*self.damageRange then
					inDis = true
				end
				if inDis then
					enemy.buildView:damage(self.attackValue)
					--num=num+1
				end
			end
		end
	else
		if self.unitType==1 or self.unitType==3 then
			for _, enemy in pairs(self.scene.soldiers) do
				if not enemy.deleted and enemy.info.unitType<=self.unitType then
					local x, y = enemy.view:getPosition()
					local dis = self.scene.mapGrid:getGridDistance(self.targetPos[1]-x, self.targetPos[2]-y)
					--print(dis, self.damageRange)
					if dis < self.damageRange then
						enemy:damage(self.attackValue)
					    --num=num+1
					end
				end
			end
		else
			for _, enemy in pairs(self.scene.soldiers) do
				if not enemy.deleted and enemy.info.unitType==2 then
					local x, y = enemy.view:getPosition()
					y = y + enemy.viewInfo.y
					local dis = self.scene.mapGrid:getGridDistance(self.targetPos[1]-x, self.targetPos[2]-y)
					if dis < self.damageRange then
						enemy:damage(self.attackValue)
					    --num=num+1
					end
				end
			end
		end
	end
	--print("splashAttackNum", num)
end

MagicSplash = class(AreaSplash)

--(attackValue, speed, x, y, targetX, targetY, damageRange, group, unitType)
function MagicSplash:ctor(attack, speed, x, y, targetX, targetY, damageRange, group, unitType, level, target)
    self.level = level
	if target then
		-- is single shot
		self.target = target
		self.targetPos = {self.target.view:getPositionX(), self.target.view:getPositionY() + self.target.view:getContentSize().height/2}
	end
end

function MagicSplash:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		self.view:removeFromParentAndCleanup(true)
		if state==1 then
			if self.target then
				self.target:damage(self.attackValue)
			else
				self:executeDamage()
			end
			self:resetView()
		end
	end
	self.stateTime = stateTime
end

function MagicSplash:initView()
	local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2])
	self.time = {distance*10/self.speed, 0.5}
	self.state = 1
	self:resetView()
end

function MagicSplash:resetView()
	if self.state==1 then
		if self.target and self.target.deleted then
			return
		end
		local ox, oy = self.targetPos[1] - self.initPos[1], self.targetPos[2] - self.initPos[2]
		local dir = 0
		local temp = math.deg(math.atan2(oy, ox))
		dir = 180-temp
		
		--self.view = UI.createSpriteWithFile("images/effects/magicBall.png")
		--self.view:setAnchorPoint(CCPointMake(0.41, 0.47))
		--self.view:setPosition(self.initPos[1], self.initPos[2])
		--self.view:setScale(0.5)
		--self.view:setRotation(dir)
		
		--temp = UI.createSpriteWithFile("images/effects/magicWave.png")
		--temp:setAnchorPoint(CCPointMake(0.02, 0.47))
		--temp:setPosition(52, 51)
		--temp:setScaleX(0)
		--temp:runAction(CCScaleTo:create(self.time[1], 2*math.sqrt(ox*ox+oy*oy)/365, 1))
		--self.view:addChild(temp, -1)
		
		self.view = UI.createSpriteWithFile("images/effects/magicWave.png", nil, true)
		if self.level==1 then
		    self.view:setHueOffset(280, false)
		elseif self.level==2 then
		    self.view:setHueOffset(118, false)
		end
		self.view:setAnchorPoint(CCPointMake(0.06, 0.47))
		self.view:setPosition(self.initPos[1], self.initPos[2])
		self.view:setScaleY(0.5)
		self.view:setScaleX(0)
		self.view:setRotation(dir)
		self.view:runAction(CCScaleTo:create(self.time[1], math.sqrt(ox*ox+oy*oy)/365, 0.5))
		
		self.view:runAction(CCMoveBy:create(self.time[1], CCPointMake(ox, oy)))
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
		self.scene.ground:addChild(self.view, self.scene.SIZEY)
	    music.playEffect("music/magicShot.mp3")
	elseif self.state==2 then
	    self.view = UI.createAnimateWithSpritesheet(self.time[2], "magicBomb_", 7, {plist="animate/effects/magicBomb.plist", useExtend=true})
	    screen.autoSuitable(self.view, {nodeAnchor=General.anchorCenter, x=self.targetPos[1], y=self.targetPos[2]})
		simpleRegisterEvent(self.view, {update={inteval=self.time[2], callback=self.update}}, self)
	    
		self.scene.ground:addChild(self.view, self.scene.SIZEY)
	    music.playEffect("music/magicBomb.mp3")
	end
	
	if self.level==1 then
	    self.view:setHueOffset(280, false)
	elseif self.level==2 then
	    self.view:setHueOffset(118, false)
	end
end

BalloonSplash = class(AreaSplash)

function BalloonSplash:ctor(attackValue, speed, x, y, targetX, targetY, damageRange, group, unitType, level, direction)
	self.level = level
	self.direction = direction
	
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("balloon1_1.png")
	if not frame then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("animate/effects/balloonAttack.plist")
    end
end

function BalloonSplash:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		self.view:removeFromParentAndCleanup(true)
		if state==1 then
			self:executeDamage()
			self:resetView()
		end
	end
	self.stateTime = stateTime
end

function BalloonSplash:initView()
	local distance = self.scene.mapGrid:getGridDistance(0, self.targetPos[2]-self.initPos[2])
	self.time = {distance*10/self.speed, 1.4}
	self.state = 1
	self:resetView()
end

function BalloonSplash:resetView()
	if self.state==1 then
		local oy = self.targetPos[2] - self.initPos[2]
		
		local flip, dir = false, self.direction
		if dir>3 then
			dir = 7-dir
			flip = true
		end
		self.view = UI.createSpriteWithFrame("balloon" .. self.level .. "_" .. dir .. ".png")
		if flip then
			self.view:setFlipX(true)
		end
		self.view:setScale(0.66)
		screen.autoSuitable(self.view, {nodeAnchor=General.anchorCenter, x=self.initPos[1], y=self.initPos[2]})
		
		self.view:runAction(CCEaseIn:create(CCMoveBy:create(self.time[1], CCPointMake(0, oy)), 2))
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
		self.scene.sky:addChild(self.view)
	elseif self.state==2 then
		local temp = UI.createAnimateWithSpritesheet(self.time[2], "bombNormal_", 13, {plist="animate/effects/normalEffect.plist", isRepeat=false})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=self.targetPos[1], y=self.targetPos[2]})
		self.scene.effectBatch:addChild(temp)
		delayRemove(self.time[2], temp)
		
		local t = 1
		self.view = UI.createAnimateWithSpritesheet(1, "balloonAttacked_", 9, {plist="animate/effects/balloonAttack.plist"})
		screen.autoSuitable(self.view, {nodeAnchor=General.anchorCenter, x=self.targetPos[1], y=self.targetPos[2]})
		
		local array = CCArray:create()
		array:addObject(CCEaseSineOut:create(CCMoveBy:create(t/3, CCPointMake(0, 40))))
		array:addObject(CCEaseIn:create(CCMoveBy:create(t/3, CCPointMake(0, -40)), 2))
		self.view:runAction(CCSequence:create(array))
		self.view:runAction(CCFadeOut:create(t*2/3))
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[2], callback=self.update}}, self)
		self.scene.sky:addChild(self.view)
		
	end
end

MortarSplash = class(AreaSplash)

--(attackValue, speed, x, y, targetX, targetY, damageRange, group, unitType)
function MortarSplash:ctor(attackValue, speed, x, y, targetX, targetY, damageRange, group, unitType, level, height)
	self.level = level
	self.height = height
end

function MortarSplash:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		self.view:removeFromParentAndCleanup(true)
		if state==1 then
			self:executeDamage()
			self:resetView()
		end
	end
	self.stateTime = stateTime
end

function MortarSplash:initView()
	local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2]+self.height)
	self.time = {distance*10/self.speed, 1.4}
	self.state = 1
	self:resetView()
end

function MortarSplash:resetView()
	if self.state==1 then
		local ballLevel = 1
		if self.level>=4 then ballLevel=2 end
		self.view = UI.createAnimateWithSpritesheet(1, "mortarBall" .. ballLevel .. "_", 6, {plist="animate/effects/mortarBall" .. ballLevel .. ".plist"})
		
		screen.autoSuitable(self.view, {nodeAnchor=General.anchorCenter, x=self.initPos[1], y=self.initPos[2]})
		self.view:setScale(0.85)
		temp = CCParticleSystemQuad:create("images/effects/mortarFog.plist")
    	temp:setPositionType(kCCPositionTypeGrouped)
		screen.autoSuitable(temp, {x=self.view:getContentSize().width/2, y=self.view:getContentSize().height/2})
		temp:setScale(2)
		self.view:setRotation(-90)
		self.view:addChild(temp, -1)
		
		Action.runGravityMove(self.view, self.time[1], self.initPos[1], self.initPos[2], self.targetPos[1], self.targetPos[2], self.height, 0)
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
		
		local initZorder = self.initPos[2]-self.height
		if self.targetPos[2]<self.initPos[2] then
		    initZorder = 0
		end
		self.scene.ground:addChild(self.view, self.scene.SIZEY-initZorder)
		
	    music.playEffect("music/mortarShot.mp3")
	elseif self.state==2 then
		self.view = UI.createAnimateWithSpritesheet(self.time[2], "mortarFire_", 14, {plist="animate/effects/mortarFire.plist", isRepeat=false})
		screen.autoSuitable(self.view, {nodeAnchor=General.anchorCenter, x=self.targetPos[1], y=self.targetPos[2]})
		delayRemove(self.time[2], self.view)
		
		local ssize = self.view:getContentSize()
		
		temp = UI.createAnimateWithSpritesheet(self.time[2]/3, "mortarBomb_", 6, {plist="animate/effects/mortarBomb.plist", isRepeat=false})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=ssize.width/2+1, y=ssize.height/2-30})
		temp:setScale(0.75)
		self.view:addChild(temp)
		delayRemove(self.time[2]/3, temp)
		
		self.scene.ground:addChild(self.view, self.scene.SIZEY - self.targetPos[2])
		self.scene.ground:runAction(CCShake:create(self.time[2], 10*self.scene.ground:getScale()))
		
	    music.playEffect("music/mortarBomb.mp3")
	end
end

HealthSplash = class(AreaSplash)

function HealthSplash:update(diff)
	diff = diff * (self.scene.speed or 1)
	local stateTime = self.stateTime + diff
	local state = self.state
	if stateTime >= self.time[state] then
		self.state = state+1
		stateTime = stateTime - self.time[state]
		if state==1 then
			self:executeDamage()
		end
		self.view:removeFromParentAndCleanup(true)
	end
	self.stateTime = stateTime
end

function HealthSplash:initView()
	local distance = self.scene.mapGrid:getGridDistance(self.targetPos[1]-self.initPos[1], self.targetPos[2]-self.initPos[2])
	self.time = {0.28+distance*10/self.speed}
	self.state = 1
	self:resetView()
end

function HealthSplash:resetView()
	if self.state==1 then
		if self.target and self.target.deleted then
			return
		end
		local ox, oy = self.targetPos[1] - self.initPos[1], self.targetPos[2] - self.initPos[2]
		local dir = 0
		local temp = math.deg(math.atan2(oy, ox))
		local scale = 0.4 * math.abs((temp+450)%180-90)/90+0.2
		dir = -temp-90
		
		self.view = CCSpriteBatchNode:create("images/effects/healthCircle.png", 10)
		self.view:setScaleX(0.25)
		self.view:setScaleY(0.25 * scale)
		self.view:setRotation(dir)
		screen.autoSuitable(self.view, {nodeAnchor=General.anchorCenter, x=self.initPos[1], y=self.initPos[2]})
		
		local array = CCArray:create()
		array:addObject(CCScaleTo:create(0.28, 0.6, 0.6*scale))
		array:addObject(CCScaleTo:create(self.time[1]-0.28, 1, scale))
		self.view:runAction(CCSequence:create(array))
		array = CCArray:create()
		array:addObject(CCDelayTime:create(0.28))
		array:addObject(CCMoveBy:create(self.time[1]-0.28, CCPointMake(ox, oy)))
		self.view:runAction(CCSequence:create(array))
		
		for i=0, 9 do
			temp = UI.createSpriteWithFile("images/effects/healthCircle.png")
			temp:setScale(1-i/20)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter})
			self.view:addChild(temp, -i)
			
			array = CCArray:create()
			array:addObject(CCDelayTime:create(0.28))
			array:addObject(CCMoveBy:create(0.1, CCPointMake(0, 2*i*5/scale)))
			temp:runAction(CCSequence:create(array))
		end
		
		simpleRegisterEvent(self.view, {update={inteval=self.time[1], callback=self.update}}, self)
		
		local z = 0
		if oy<=0 then z = self.scene.SIZEY+20000 end
		self.scene.sky:addChild(self.view, z)
	end
end