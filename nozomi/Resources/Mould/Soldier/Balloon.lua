Balloon = class(Soldier)

function Balloon:ctor()
	local scale = getParam("soldierScale" .. self.info.sid, 100)/100
	self.viewInfo = {scale=scale, x=0, y=120*scale}
end

function Balloon:resetFreeState()
	self.displayState.duration = 1.5
	self.displayState.isRepeat = false
	self.displayState.num = 1
	self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_m"
end

function Balloon:getFrameEspecially(i)
	return nil
end

-- to override
function Balloon:resetOtherState()
	self.displayState.duration = getParam("soldierPoseTime" .. self.info.sid, 500)/1000
	self.displayState.isRepeat = false
	self.displayState.num = 1
	self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_m"
end

-- to override
function Balloon:prepareAttack()
	self.stateInfo = {actionTime=self.info.attackSpeed}
	self.stateInfo.attackValue = self:getAttackValue()
	self.stateInfo.attackTime = 0.2
	self.stateInfo.action = "attack"
end

-- to override
function Balloon:executeAttack()
	local p = {self.view:getPosition()}
	p[3] = self.scene.SIZEY - p[2]
	p[1] = p[1] + self.viewInfo.x
	--(attackValue, speed, x, y, targetX, targetY, damageRange, group, unitType, level, direction)
	local shot = BalloonSplash.new(self.stateInfo.attackValue, 25, p[1], p[2]+self.viewInfo.y, p[1], p[2], self.info.damageRange, GroupTypes.Attack, 1, self.data.level, self.direction)
	shot:addToScene(self.scene)
	music.playCleverEffect("music/attack" .. self.info.sid .. ".mp3")
end

local FLAME_ACTION = {[1]={{-32, 37, -120, -1}},
	[2]={{-65, -1, -180, -1}},
	[3]={{-35, -47, 120, 1}},
	[4]={{35, -47, 60, 1}},
	[5]={{65, -1, 0, -1}},
	[6]={{32, 37, -60, -1}}}
	
function Balloon:onChange(dir, i)
	local setting = FLAME_ACTION[dir][1]
	if not self.flame then
		self.flame = UI.createAnimateWithSpritesheet(getParam("flameActionTime", 1000)/1000, "flame_", 19, {plist="animate/builder/flame.plist", useExtend=true})
		screen.autoSuitable(self.flame, {nodeAnchor=General.anchorTop})
		self.flame:setScaleX(0.8)
		self.flame:setScaleY(0.4)
		self.flame:setHueOffset(170, false)
		self.view:addChild(self.flame, setting[4])
	else
		self.flame:retain()
		self.flame:removeFromParentAndCleanup(false)
		self.view:addChild(self.flame, setting[4])
		self.flame:release()
	end
	local setting = FLAME_ACTION[dir][1]
	self.flame:setPosition(setting[1]+self.viewInfo.x, setting[2]+self.viewInfo.y)
	self.flame:setRotation(setting[3]-90)
end
