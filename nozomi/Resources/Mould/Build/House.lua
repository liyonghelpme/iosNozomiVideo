House = class(Storage)

function House:initWithSetting(setting)
	self.npcs = {1,1,1,1}
	self.npcNum = 4
end

function House:updateOperationLogic(diff)
	self.npcTime = (self.npcTime or 0)+diff
	if self.npcTime > 15 then
		self.npcTime = 0
		if not UserData.noPerson and self.npcNum>0 then
			local ni = math.random(4)
			for i=1, 4 do
				if self.npcs[(i+ni)%4+1]>0 then
					ni = (i+ni)%4+1
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

function House:npcReturnHome(nid)
	self.npcNum = self.npcNum+1
	self.npcs[nid] = self.npcs[nid]+1
end

function House:getDoorPosition()
	if self.buildLevel<=4 then
		return {-76, 66}
	else
		return {-65, 55}
	end
end

function House:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local build = UI.createSpriteWithFile("images/build/" .. bid .. "/house" .. level .. ".png", nil, true)
	return build
end

function House:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
		local ox = build:getContentSize().width/2
		local llevel = level
		if level==2 then llevel=1 end
		local light = UI.createSpriteWithFile("images/build/" .. bid .. "/houseLight" .. llevel .. ".png")
		screen.autoSuitable(light,{nodeAnchor=General.anchorBottom, x=ox, y=0})
		build:addChild(light, 10, TAG_LIGHT)
	else
		local light = build:getChildByTag(TAG_LIGHT)
		if light then
			light:removeFromParentAndCleanup(true)
		end
	end
end

function House:getBuildShadow()
	local slevel = self.buildData.level
	if slevel<3 then
	    return self:getShadow("images/shadowGrid.png", -89, 38, 173, 134)
	elseif slevel==3 then
	    return self:getShadow("images/shadowGrid.png", -107, 34, 210, 162)
	elseif slevel==4 then
	    return self:getShadow("images/shadowSpecial3.png", -97, 50, 174, 130)
	elseif slevel==5 then
	    return self:getShadow("images/shadowGrid.png", -86, 32, 168, 129)
	else
	    return self:getShadow("images/shadowGrid.png", -103, 27, 204, 157)
	end
end

function House:enterBattle()
    local npcs = {}
    for i=1, 4 do
        local npc = NPC.new(i, self)
		table.insert(npcs, npc)
		table.insert(self.buildView.scene.asynSoldiers, npc)
    end
    self.npcViews = npcs
end