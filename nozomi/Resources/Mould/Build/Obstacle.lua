Obstacle = class(BuildMould)

function Obstacle:ctor(bid, setting)
	self.hiddenSupport = true
	self.buildInfo = {bid=bid, btype=5, levelMax=1, totalMax=200, name=StringManager.getString("dataBuildName" .. bid)}
	self.disMovable = true
	self.disBuildingView = true
	self.rewardType = setting.type
	if not self.rewardType then
		self.rewardType = math.random(4)
	end
end

function Obstacle:getExtendInfo()
	return {type=self.rewardType}
end


function Obstacle:getBuildBottom()
	return UI.createSpriteWithFrame("lampstand" .. self.buildData.gridSize .. "b.png")
end

function Obstacle:getBuildView()
	local bid = self.buildData.bid
	
	local build = UI.createSpriteWithFrame("build" .. bid .. ".png")
	return build
end

function Obstacle:getBuildShadow()
    if self.buildData.gridSize>2 then
        return self:getShadow("images/shadowCircle.png", -77, 49, 142, 99)
    end
end

function Obstacle:getChildMenuButs()
	local buts = {}
	local bdata = self.buildData
	if self.buildState~=BuildStates.STATE_BUILDING then
		if self.buildView.scene.sceneType==SceneTypes.Operation then
			table.insert(buts, {image="images/" .. bdata.costType .. ".png", text=StringManager.getString("buttonRemove"), callback=self.removeObstacle, callbackParam=self, extend={cost={costType=bdata.costType, costValue=bdata.costValue, costMid=true}, imgScale=0.6}})
		end
	else
		table.insert(buts, {image="images/menuItemCancel.png", text=StringManager.getString("buttonCancel"), callback=self.cancelRemove, callbackParam=self})
	end
	return buts
end

function Obstacle:removeObstacle()
	local bdata = self.buildData
	if ResourceLogic.getResource("builder")==0 then
		display.pushNotice(UI.createNotice(StringManager.getString("noBuilder")))
	elseif ResourceLogic.checkAndCost(bdata, self.removeObstacle, self) then
		self.buildEndTime = timer.getTime() + bdata.time
		self.buildTotalTime = bdata.time
		self.buildState = BuildStates.STATE_BUILDING
		self:callBuilder()
		if self.buildView then
			self.buildView:resetBuildView()
		end
	end
end

function Obstacle:upgradeOver()
	self.buildState = BuildStates.STATE_FREE
	self.buildEndTime = nil
	self.buildTotalTime = nil
	if self.rewardType<4 then
		ResourceLogic.changeResource("crystal", self.rewardType)
        display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeRemoveObstacle", {num=self.rewardType}), 255))
	end
	--UserData.changeValue("exp", math.floor(math.sqrt(self.buildData.time)))
	self:deleteBuild()
	self:removeFromScene()
end

function Obstacle:cancelRemove(force)
    if self.buildState~=BuildStates.STATE_BUILDING then return end
    if force then
    	self.buildState = BuildStates.STATE_FREE
    	self.buildEndTime = nil
    	self.buildTotalTime = nil
    	local bdata = self.buildData
    	ResourceLogic.changeResource(bdata.costType, math.floor(bdata.costValue/2))
    	self:releaseBuilder()
    	if self.buildView then
    		self.buildView:resetBuildView()
    	end
    else
        local name = StringManager.getString("dataBuildName" .. self.buildData.bid)
        display.showDialog(AlertDialog.new(StringManager.getString("alertTitleCancelRemove"), StringManager.getFormatString("alertTextCancelRemove", {name=name}), {callback=self.cancelRemove, param=true}, self))
    end
end