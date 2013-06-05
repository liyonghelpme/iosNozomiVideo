require "Util.ReuseNodeCache"

MapGridView = class(RhombGrid)

function MapGridView:ctor()
	self.buildings = {}
	self.blocks = {}
	self.lines = {}
	self.color = ccc3(255, 255, 255)
	self.view = CCNode:create()
	self.blockBatch = CCSpriteBatchNode:create("block.png", 2000)
	self.view:addChild(self.blockBatch)
	self.linesBatch = CCSpriteBatchNode:create("line.png", 2000)
	self.view:addChild(self.linesBatch)
end

function MapGridView:setColor(color)
    self.color = color
    for _, line in pairs(self.lines) do
        line:setColor(color)
    end
    for _, block in pairs(self.blocks) do
        block:setColor(color)
    end
end

function MapGridView:getLineKey(x, y, edgeId)
	if edgeId<2 then
		return self:getGridKey(x, y)*10 + edgeId
	elseif edgeId==2 then
		return self:getGridKey(x-1, y)*10
	else
		return self:getGridKey(x, y-1)*10+1
	end
end

function MapGridView:removeLine(edgeId)
	if self.lines[edgeId] then
		self.lines[edgeId]:removeFromParentAndCleanup(true)
		self.lines[edgeId] = nil
	end
end

function MapGridView:addLine(edgeId)
    local line = UI.createSpriteWithFile("line.png", CCSizeMake(self.sizeX/2+10, self.sizeY/2+7))
    local blockId, edge = math.floor(edgeId/10), edgeId%10
    local x, y = math.floor(blockId/10000), blockId%10000
    local aposition = self:convertToPosition(x+1, y+1)
    local position = self:convertToPosition(x+1-edge, y+edge)
	line:setColor(self.color)
	screen.autoSuitable(line, {nodeAnchor=General.anchorCenter, x=(aposition[1]+position[1])/2, y=(aposition[2]+position[2])/2})
	line:setFlipX(edge==1)
	self.linesBatch:addChild(line)
	line:setOpacity(0)
	self.lines[edgeId] = line
end

function MapGridView:resetBlockEdge(x, y)
	for i=0, 3 do 
		local k=self:getLineKey(x, y, i)
		if self.lines[k] then
			self:removeLine(k)
		else
			self:addLine(k)
		end
	end
end

function MapGridView:addBlock(x, y)
	local blockKey = self:getGridKey(x, y)
	local sprite = UI.createSpriteWithFile("block.png", CCSizeMake(self.sizeX+2, self.sizeY+2))
	sprite:setColor(self.color)
	local position = self:convertToPosition(x, y)
	screen.autoSuitable(sprite, {nodeAnchor=General.anchorBottom, x=position[1], y=position[2]-1})
	self.blockBatch:addChild(sprite)
	self.blocks[blockKey] = sprite
	sprite:setOpacity(0)
	self:resetBlockEdge(x, y)
end

function MapGridView:removeBlock(x, y)
	local blockKey = self:getGridKey(x, y)
	if self.blocks[blockKey] then
	    self.blocks[blockKey]:removeFromParentAndCleanup(true)
		self.blocks[blockKey] = nil
	end
	self:resetBlockEdge(x, y)
end

function MapGridView:setGridUse(key, gx, gy, gsizex, gsizey)
    gsizey = gsizey or gsizex
	for i=1, gsizex do
		for j=1, gsizey do
			local x, y = gx+i-1, gy+j-1
			local grid = self:getGrid(key, x, y)
			if grid then
				grid.value = grid.value + 1
			else
				grid = self:setGrid(key, x, y)
			end
			if grid.value==1 then
				self:addBlock(x, y)
			end
		end
	end
end

function MapGridView:clearGridUse(key, gx, gy, gsizex, gsizey)
    gsizey = gsizey or gsizex
	for i=1, gsizex do
		for j=1, gsizey do
			local x, y = gx+i-1, gy+j-1
			local grid = self:getGrid(key, x, y)
			grid.value = grid.value - 1
			if grid.value==0 then
				self:removeBlock(x, y)
			end
		end
	end
end