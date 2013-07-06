SoldierLogic = {}
do
	local maxs={}
	local zmaxs={}
	local camps={}
	local zcamps={}
	local barracks = {}
	local zbarracks = {}
	local spaceMax = 0
	local zspaceMax = 0
	
	local snumber = {}
	
	function SoldierLogic.setCampMax(buildIndex, max)
		maxs[buildIndex] = max
		local num=0
		for i, mnum in pairs(maxs) do
			num = num + mnum
		end
		spaceMax = num
	end
	
	function SoldierLogic.setZombieCampMax(buildIndex, max)
		zmaxs[buildIndex] = max
		local num=0
		for i, mnum in pairs(zmaxs) do
			num = num + mnum
		end
		zspaceMax = num
	end
	
	function SoldierLogic.setCamp(buildIndex, camp)
		camps[buildIndex] = camp
	end
	
	function SoldierLogic.setZombieCamp(buildIndex, camp)
		zcamps[buildIndex] = camp
	end
	
	function SoldierLogic.setBarrack(buildIndex, barrack)
		barracks[buildIndex] = barrack
	end
	
	function SoldierLogic.setZBarrack(buildIndex, barrack)
	    zbarracks[buildIndex] = barrack
	end
	
	function SoldierLogic.getSpaceMax()
		return spaceMax
	end
	
	function SoldierLogic.getZombieSpaceMax()
		return zspaceMax
	end
	
	function SoldierLogic.getSoldierNumber(sid)
		return snumber[sid]
	end
	
	function SoldierLogic.decSoldier(sid)
	    snumber[sid] = snumber[sid]-1
	    
	    for i=1, #camps do
	        local camp = camps[i]
	        local slist = camp.soldiers
	        local delIndex = 0
	        for i, soldier in pairs(slist) do
	            if soldier.info.sid==sid then
	                delIndex = i
	                break
	            end
	        end
	        if delIndex>0 then
	            local s = table.remove(slist, delIndex)
	            s.view:removeFromParentAndCleanup(true)
	            s.view = nil
	        end
	    end
	end
	
	function SoldierLogic.getCurSpace()
		local ret = 0
		for i=1, #camps do
			ret = ret + camps[i]:getCurSpace()
		end
		return ret
	end
	
	function SoldierLogic.getCurZombieSpace()
		local ret = 0
		for i=1, #zcamps do
			ret = ret + zcamps[i]:getCurSpace()
		end
		return ret
	end
	
	function SoldierLogic.getMaxZombieCampLevel()
	    local ret=0
	    for i=1, #zcamps do
	        if zcamps[i].buildLevel>ret then
	            ret = zcamps[i].buildLevel
	        end
	    end
	    return ret
	end
	
	function SoldierLogic.getTrainingSpace()
		local ret = 0
		for i=1, #barracks do
			ret = ret + barracks[i].totalSpace
		end
		for i=1, #zbarracks do
			ret = ret + zbarracks[i].totalSpace
		end
		return ret
	end
	
	function SoldierLogic.addSoldierToCamp(sid, barrack, camp)
		snumber[sid] = (snumber[sid] or 0) + 1
		if SoldierLogic.isInit then
		    barrack = nil
		end
		EventManager.sendMessage("EVENT_BUY_SOLDIER", {sid=sid, from=barrack, to=camp})
	end
	
	function SoldierLogic.deploySoldier(costTroops)
	    for i=1, #camps do
	        local camp = camps[i]
	        local slist = camp.initSetting.soldiers
	        for j=1, 10 do
                local minusNum = squeeze(slist[j], 0, costTroops[j])
                if minusNum>0 then
                    costTroops[j] = costTroops[j]-minusNum
                    slist[j] = slist[j]-minusNum
                    snumber[j] = snumber[j] - minusNum
                end
            end
	    end
	end
	
	function SoldierLogic.deployZombies()
	    for i=1, #zcamps do
	        local camp = zcamps[i]
	        local slist = camp.initSetting.soldiers
	        for j=1, 8 do
                slist[j] = 0
                snumber[j+10] = 0
            end
	    end
	end
	
	function SoldierLogic.incZombies(zombies)
	    for i=1, #zombies do
	        local z=zombies[i]
	        local zinfo = StaticData.getSoldierInfo(z.id)
	        for j=1, z.num do
	            if SoldierLogic.getCurZombieSpace()+zinfo.space<=SoldierLogic.getZombieSpaceMax() then
	                local camp = zcamps[1]
					for i=2, #zcamps do
						if zcamps[i]:getCurSpace() < camp:getCurSpace() then
							camp = zcamps[i]
						end
					end
					camp.curSpace = camp.curSpace + zinfo.space
					camp.initSetting.soldiers[z.id-10]=camp.initSetting.soldiers[z.id-10]+1
	            else
	                break
	            end
	        end
	    end
	end
	
	function SoldierLogic.getTrainEndTime()
	    local trainList = {}
	    for i=1, #barracks do
	        local callList = barracks[i].callList
	        if not barracks[i].pause and barracks[i].buildState~=BuildStates.STATE_BUILDING and #callList>0 then
    	        local endTime = barracks[i].beginTime
    	        for j=1, #callList do
    	            local item = callList[j]
    	            for k=1, item.num do
    	                endTime = endTime + item.perTime
    	                table.insert(trainList, {endTime, item.space})
    	            end
    	        end
    	    end
	    end
	    --[[
	    for i=1, #zbarracks do
	        local callList = zbarracks[i].callList
	        if not zbarracks[i].pause and zbarracks[i].buildState~=BuildStates.STATE_BUILDING and #callList>0 then
    	        local endTime = zbarracks[i].beginTime
    	        for j=1, #callList do
    	            local item = callList[j]
    	            for k=1, item.num do
    	                endTime = endTime + item.perTime
    	                table.insert(trainList, {endTime, item.space})
    	            end
    	        end
    	    end
	    end
	    --]]
	    table.sort(trainList, getSortFunction(1))
	    local curSpace = SoldierLogic.getCurSpace()
	    local maxSpace = SoldierLogic.getSpaceMax()
	    local endTime = 0
	    for i=1, #trainList do
	        curSpace = curSpace + trainList[i][2]
	        endTime = trainList[i][1]
	        if curSpace >= maxSpace then
	            break
	        end
	    end
		return endTime - timer.getTime()
	end
	
	function SoldierLogic.updateSoldierList()
		local updateList = {}
		for i=1, #barracks do
		    if barracks[i].buildState~=BuildStates.STATE_BUILDING and #(barracks[i].callList)>0 then
			    table.insert(updateList,barracks[i])
			end
		end
		--[[
		for i=1, #zbarracks do
		    if zbarracks[i].buildState~=BuildStates.STATE_BUILDING and #(zbarracks[i].callList)>0 then
			    table.insert(updateList,zbarracks[i])
			end
		end
		--]]
		local curTime = timer.getTime()
		local callSoldier = false
		while #updateList>0 do
			table.sort(updateList, getSortFunction("beginTime"))
			local barrack = updateList[1]
			local over = true
			local callList, isFull = barrack.callList, false
			if #callList>0 then
				isFull = SoldierLogic.getSpaceMax() < SoldierLogic.getCurSpace()+callList[1].space
			end
			if barrack.pause and not isFull then
				barrack.pause = false
			end
			if #callList > 0 and curTime - barrack.beginTime >= callList[1].perTime then
				if isFull then
					barrack.pause = true
					barrack.beginTime = curTime-callList[1].perTime
				else
					over = false
					callList[1].num = callList[1].num-1
					local sid = callList[1].sid
					local camp = camps[1]
					for i=1, #camps do
						if camps[i]:getCurSpace() < camp:getCurSpace() then
							camp = camps[i]
						end
					end
					barrack.beginTime = barrack.beginTime+callList[1].perTime
					--if SoldierLogic.lastUpdateTime and barrack.beginTime<SoldierLogic.lastUpdateTime
					barrack.totalSpace = barrack.totalSpace - callList[1].space
					camp.curSpace = camp.curSpace + callList[1].space
					if callList[1].num == 0 then
						table.remove(callList,1)
					end
					SoldierLogic.addSoldierToCamp(sid, barrack, camp)
					callSoldier = true
				end
			end
			if over then
				table.remove(updateList, 1)
			end
		end
		if not SoldierLogic.isInit then
		    if callSoldier then
    		    music.playCleverEffect("music/soldierFinish.mp3")
    		end
		else
    		SoldierLogic.isInit = false
    	end
	end
	
	function SoldierLogic.init(isVisit)
		maxs={}
		camps={}
		barracks = {}
		spaceMax = 0
		snumber = {}
	    zmaxs={}
	    zcamps={}
	    zbarracks = {}
	    zspaceMax = 0
	end
	--CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(SoldierLogic.updateSoldierList, 0.1, false)
end