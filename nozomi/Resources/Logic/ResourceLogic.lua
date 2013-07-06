ResourceLogic = {}

do
	local resourceTypes = {"oil", "food", "person", "builder"}
	local resourceItems = {}
	for _, resouceType in pairs(resourceTypes) do
		resourceItems[resouceType] = {num=0, max=0, maxs={}, storages={}} 
	end
	
	function ResourceLogic.setResourceMax(resourceType, buildIndex, max)
		resourceItems[resourceType].maxs[buildIndex] = max
		local num=0
		for i, mnum in pairs(resourceItems[resourceType].maxs) do
			num = num + mnum
		end
		resourceItems[resourceType].max = num
	end
	
	function ResourceLogic.setResourceStorage(resourceType, buildIndex, storage)
		resourceItems[resourceType].storages[buildIndex] = storage
		local num=0
		for i, storage in pairs(resourceItems[resourceType].storages) do
			num = num + storage.resource
		end
		resourceItems[resourceType].num = num
	end
	
	function ResourceLogic.getResource(resourceType)
	    if resourceItems[resourceType] then
    		return resourceItems[resourceType].num
    	else
    	    return UserData[resourceType]
    	end
	end
	
	function ResourceLogic.getResourceMax(resourceType)
		return resourceItems[resourceType].max
	end
	
	function ResourceLogic.changeResource(resourceType, value)
		local item = resourceItems[resourceType]
		if not item then
		    if resourceType=="crystal" then
		        return CrystalLogic.changeCrystal(value)
		    end
			return UserData.changeValue(resourceType, value)
		end
		local p = {}
		local k=1
		if value>0 then
			if item.max-item.num<value then
				value = item.max - item.num
			end
		else
			k = -1
			value = -value
		end
		local retValue = value
		item.num = item.num + k*value
		for i, max in pairs(item.maxs) do
			local storage = item.storages[i]
			table.insert(p, {max=(k+1)/2*max-k*storage.resource, resource=k*storage.resource, storage=storage, toAdd=0})
		end
			
		local idx, tnum=1, #p
		table.sort(p, getSortFunction("resource"))
		for i=1, tnum do
			if p[i].max > value then
				p[i].storage.resource = p[i].storage.resource + value*k
				if p[i].storage.setResourceState then
				    p[i].storage:updateOperationLogic(0)
				end
				break
			else
				value = value - p[i].max
				p[i].storage.resource = p[i].storage.resource + p[i].max*k
				if p[i].storage.setResourceState then
				    p[i].storage:updateOperationLogic(0)
				end
			end
		end
		return retValue
	end
	
	function ResourceLogic.buyResourceAndCallback(param)
	    if CrystalLogic.buyResource({force=true, cost=param.cost, resource=param.resource, get=param.get}) then
    	    if param.callback then
                param.callback(param.callbackParam)
            end
        end
	end
	
	function ResourceLogic.checkAndCost(goods, callback, param)
		local costType = goods.costType
		if costType == "crystal" then
			return CrystalLogic.changeCrystal(-goods.costValue)
		else
    		if goods.costValue > ResourceLogic.getResource(costType) then
    		    if goods.costValue > ResourceLogic.getResourceMax(costType) then
    		        display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeErrorResourceMax", {name=StringManager.getString("dataBuildName" .. RESOURCE_BUILD_BIDS[costType])})))
    		    else
    				local num = goods.costValue - ResourceLogic.getResource(costType)
    				local resource = StringManager.getString(costType)
    				local cost = CrystalLogic.computeCostByResource(costType, num)
    				display.showDialog(AlertDialog.new(StringManager.getFormatString("alertTitleNoResource", {resource=resource}), StringManager.getFormatString("alertTextNoResource", {resource=resource, num=num}),
    				    {callback=ResourceLogic.buyResourceAndCallback, param={resource=costType, get=num, cost=cost, callback=callback, callbackParam=param}, crystal=cost}))
    			end
    			return false
    		else
    			ResourceLogic.changeResource(costType, -goods.costValue)
    			return true
    		end
    	end
	end
end