require "Mould.Person"

NPC = class(Person)

function NPC:ctor(sid, home)
	local sinfo = {moveSpeed=getParam("npcSpeed" .. sid, 60)/10, unitType=1, sid=sid, moveNum=12}
	self.home = home
	if sid==2 then
		sinfo.moveNum = 11
	elseif sid==3 or sid==4 then
		sinfo.moveNum = 15
	end
	self:initWithInfo(sinfo)
	
	local scale = getParam("npcScale" .. sid, 100)/100
	self.viewInfo = {scale=scale, x=0, y=16*scale}
	self.moveTimes = 0
	self.plistFile = "animate/npc/npc" .. sid .. ".plist"
	
	if self.info.sid<2 or self.info.sid==4 then
    	self.shadowScale = 0.5
    else
    	self.shadowScale = 0.55
    end
end
	
function NPC:resetFreeState()
	self.displayState.duration = 1
	self.displayState.isRepeat = false
	self.displayState.num = 1
	self.displayState.prefix = "npc" .. self.info.sid .. "_p"
end
	
function NPC:resetMoveState()
	self.displayState.duration = getParam("npcMovingTime" .. self.info.sid, 1000)/1000
	self.displayState.isRepeat = true
	self.displayState.num = self.info.moveNum
	self.displayState.prefix = "npc" .. self.info.sid .. "_m"
end
	
function NPC:resetOtherState()
	if self.stateInfo.action == "pose" then
		self.displayState.duration = getParam("soldierPoseTime", 600)/1000
		self.displayState.isRepeat = false
		self.displayState.num = 6
		self.displayState.prefix = "npc" .. self.info.sid .. "_p"
	end
end

function NPC:getFrameEspecially(i)
	if self.state ~= PersonState.STATE_OTHER or self.stateInfo.action ~= "pose" then
		return nil
	end
	if i>=6 then
		if i<12 then
			i = 5
		elseif i<18 then
			i = i-6
		elseif i<24 then
			i = 11
		elseif i<27 then
			i = i-12
		else
			i = 0
		end
	end
	return i
end
		
function NPC:setPose()
	if self.state == PersonState.STATE_FREE then
		self.state = PersonState.STATE_OTHER
		self.direction = math.ceil((self.direction or 1)/3)*5-4
		self.stateInfo = {action="pose", actionTime=getParam("npcPoseTime", 3000)/1000}
		self.stateTime = 0
		self:resetPersonView()
	end
end
	
function NPC:getInitPos()
	local targetBuild
	local ri = math.random(#(self.scene.builds))
	for i, build in pairs(self.scene.builds) do
		if i==ri then
			targetBuild = build
			break
		end
	end
	if not targetBuild then
		targetBuild = self.home
	end
	self.target = targetBuild
	self:setPose()
	local x, y = targetBuild.buildView.view:getPosition()
    local off = targetBuild:getDoorPosition()
	return {x + off[1], y + off[2]}
end

function NPC:randomMove()
	local randPercent = 0.7
	if self.moveTimes == 0 then
		randPercent = 1
	end
	local targetBuild
	if math.random()<=randPercent then
		local ri = math.random(#(self.scene.builds))
		for i, build in pairs(self.scene.builds) do
			if i==ri then
				targetBuild = build
				break
			end
		end
	else
		targetBuild = self.home
		self.isOver = true
	end
	if targetBuild == self.target or not targetBuild or targetBuild.deleted or targetBuild.buildData.bid==3006 then
		self:setPose()
	else
		self.target = targetBuild
		local grid = targetBuild.buildView.state.backGrid
		local p = self.scene.mapGrid:convertToPosition(grid.gridPosX, grid.gridPosY)
		local off = targetBuild:getDoorPosition()
		self:setMoveTarget(p[1] + off[1], p[2] + off[2])
		self.moveTimes = self.moveTimes+1
	end
end

function NPC:runBackHome()
    local x, y = self.home.buildView.view:getPosition()
	local off = self.home:getDoorPosition()
	self:setMoveScale(1+24/self.info.moveSpeed)
	self.isOver = true
	self:setMoveTarget(x + off[1], y+off[2])
end
	
function NPC:updateState(diff)
    if self.scene.battleBegin and not self.running then
        self.running = true
        self:runBackHome()
    end
	if self.state == PersonState.STATE_FREE then
		if self.isOver then
			self.view:removeFromParentAndCleanup(true)
			self.deleted = true
			self.home:npcReturnHome(self.info.sid)
			return true
			--TODO 
		else
			self:setPose()
		end
	elseif self.state == PersonState.STATE_OTHER and self.stateTime > self.stateInfo.actionTime then
		if self.stateInfo.action=="pose" then
			self.stateTime = 0
			self:randomMove()
		end
		self:resetPersonView()
		return true
	end
end