Storage = class(BuildMould)

function Storage:ctor(bid, setting, param)
	self.resourceType = param
	self.resource = setting.resource or 0
end

function Storage:getExtendInfo()
	return {resource=self.resource}
end

function Storage:getBattleResource()
	--if self.resourceType=="special" then
	--	return {[self.resourceType]=math.floor(self.resource*0.05)}
	if self.resourceType=="food" or self.resourceType=="oil" then
	    local resource = math.floor(self.resource*0.25)
	    self.resourceMax = self.buildData.extendValue1
		return {[self.resourceType]=resource}
	--elseif self.resourceType=="person" then
	--	return {person=self.resource}
	end
end

function Storage:enterOperation()
	ResourceLogic.setResourceStorage(self.resourceType, self.buildIndex, self)
	ResourceLogic.setResourceMax(self.resourceType, self.buildIndex, self.buildData.extendValue1)
end

function Storage:addBuildInfo(bg, addInfoItem)
	local img = STORAGE_IMG_SETTING[self.resourceType]
	addInfoItem(bg, 1, self.resource, nil, self.buildData.extendValue1, "Storage", img)
	
	return 1
end

function Storage:addBuildUpgrade(bg, addUpgradeItem)
	local bdata = self.buildData
	local maxData = StaticData.getMaxLevelData(bdata.bid)
	local nextLevel = StaticData.getBuildData(bdata.bid, bdata.level+1)
	
	addUpgradeItem(bg, 1, bdata.extendValue1, nextLevel.extendValue1, maxData.extendValue1, "Storage", STORAGE_IMG_SETTING[self.resourceType])
	return 1
end

function Storage:updateOperationLogic(diff)
    local percent = 100*self.resource/self.buildData.extendValue1
    local state = squeeze(math.floor(percent/24),0,4)
    if state~=self.resourceState then
        self.resourceState = state
        if self.setResourceState then
            if self.buildView and not self.buildView.isOperationDestroy then
                self:setResourceState(state)
            else
                self.resourceState = nil
            end
        end
    end
end

function Storage:afterUpgrade(endTime)
    self.resourceState = nil
    self:updateOperationLogic(0)
end