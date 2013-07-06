BuilderRoom = class(Storage)

function BuilderRoom:ctor(bid, setting, type)
	self.resource = setting.resource or 1
	if setting and setting.isBuying then
		local bid = self.buildData.bid 
		self.buildData.costValue = StaticData.getBuildData(bid, Build.getBuildNum(bid)+1).costValue
	end
end

function BuilderRoom:enterOperation()
	ResourceLogic.setResourceStorage(self.resourceType, self.buildIndex, self)
	ResourceLogic.setResourceMax(self.resourceType, self.buildIndex, 1)
	if self.resource==1 then
		self.builder = Builder.new()
		self.builder.home = self
		local x, y = self.buildView.view:getPosition()
		y = y + getParam("builderOffy", 70)
		self.builder:addToScene(self.buildView.scene, {x, y})
    else
        self.builder = nil
	end
end

function BuilderRoom:enterZombie()
	ZombieLogic.changeBuilderMax(1)
	ZombieLogic.changeBuilder(1)
	self.builder = Builder.new()
	self.builder.home = self
	local x, y = self.buildView.view:getPosition()
	y = y + getParam("builderOffy", 70)
	self.builder:addToScene(self.buildView.scene, {x, y})
end

function BuilderRoom:onZombieDamage()
	ZombieLogic.destroyBuild(self.buildData.bid)
	ZombieLogic.changeBuilderMax(-1)
	if self.builder then
		ZombieLogic.changeBuilder(-1)
		self.builder.home = nil
		self.builder:returnHome()
	end
end


function BuilderRoom:onGridReset(oldGrid, newGrid)
	if self.builder and oldGrid and newGrid then
		self.builder:returnHome()
	end
end

function BuilderRoom:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local build = UI.createSpriteWithFrame("build" .. bid .. ".png")
	return build
end

function BuilderRoom:touchTest(x, y)
	return isTouchInNode(self.buildView.build, x, y, true)
end

function BuilderRoom:addBuildInfo()
end

function BuilderRoom:updateOperationLogic(diff)
    -- 我觉得可以加个动画
end

-- VIEW逻辑 获取建筑阴影
function BuilderRoom:getBuildShadow()
	return self:getShadow("images/shadowSpecial2.png", -65, 20, 128, 104)
end