BattleLogic = {resources = {}}

function BattleLogic.init()
	BattleLogic.percent = 0
	BattleLogic.stars = 0
	BattleLogic.buildMax = 0
	BattleLogic.buildDestroyed = 0
	BattleLogic.builds = {}
	BattleLogic.destroys = {}
	BattleLogic.costTraps = {}
	BattleLogic.soldiers = {0,0,0,0,0,0,0,0,0,0}
	BattleLogic.battleEnd = false
	BattleLogic.zombieDeployed = false
	BattleLogic.clanDeployed = false
	BattleLogic.k = 1
	
	local resourceTypes = {"oil", "food"}
	for i=1, 2 do
		local resourceType = resourceTypes[i]
		BattleLogic.resources[resourceType] = {left=0, stolen=0, base=ResourceLogic.getResource(resourceType), max=ResourceLogic.getResourceMax(resourceType)}
	end
	BattleLogic.shieldHour = 0
end

function BattleLogic.incSoldier(sid)
    BattleLogic.soldiers[sid] = BattleLogic.soldiers[sid]+1
end

local BATTLE_K = {0.05, 0.25, 0.5, 1, 1, 1, 1.25, 1.5}

function BattleLogic.addBuild(id, buildData)
	BattleLogic.buildMax = BattleLogic.buildMax + 1
	local resources = buildData.resources
	if resources then
    	if resources.enemyLevel then
    	    local dis = resources.enemyLevel - UserData.level
    	    BattleLogic.k = BATTLE_K[squeeze(dis+5, 1, 8)]
    	    resources = {oil=1000/BattleLogic.k, food=1000/BattleLogic.k}
    	    buildData.resources = resources
    	end
		for type, resource in pairs(resources) do
			if BattleLogic.resources[type] then
				BattleLogic.resources[type].left = BattleLogic.resources[type].left + resource
			end
		end
	end
	BattleLogic.builds[id] = buildData
end

function BattleLogic.setBuildHitpoints(id, hitpoints)
	local buildData = BattleLogic.builds[id]
	if not buildData then return end
	local resources = buildData.resources
	if resources then
		for type, resource in pairs(resources) do
			local stoleValue = resource*(buildData.hitpoints-hitpoints)/buildData.max
			if BattleLogic.resources[type] then 
				BattleLogic.resources[type].left = BattleLogic.resources[type].left - stoleValue
				BattleLogic.resources[type].stolen = BattleLogic.resources[type].stolen + stoleValue
			    EventManager.sendMessage("EVENT_RESOURCE_STOLEN", {buildId=id, type=type, num=stoleValue, leftResource=BattleLogic.k*resource*hitpoints/buildData.max})
			end
		end
	end
	buildData.hitpoints = hitpoints
end

function BattleLogic.costTrap(id)
    table.insert(BattleLogic.costTraps, id)
end

function BattleLogic.deployZombie()
    BattleLogic.zombieDeployed = true
end

function BattleLogic.destroyBuild(bid, id)
	BattleLogic.destroys[bid] = (BattleLogic.destroys[bid] or 0) + 1
    if not BattleLogic.builds[id] then return end
	if bid==TOWN_BID then
		BattleLogic.stars = BattleLogic.stars + 1
	end
	BattleLogic.buildDestroyed = BattleLogic.buildDestroyed + 1
	local percent = math.floor(BattleLogic.buildDestroyed*100/BattleLogic.buildMax)
	
	if percent>=40 and BattleLogic.percent<40 then
		BattleLogic.shieldHour = 12
	end
	if percent>=50 and BattleLogic.percent<50 then
		BattleLogic.stars = BattleLogic.stars+1
	end
	if percent>=90 and BattleLogic.percent<90 then
		BattleLogic.shieldHour = 16
	end
	if percent==100 then
		BattleLogic.stars = BattleLogic.stars+1
		BattleLogic.battleEnd = true
	end
	BattleLogic.percent = percent
end

function BattleLogic.getResource(resourceType)
	local resource = BattleLogic.resources[resourceType].base + BattleLogic.resources[resourceType].stolen * BattleLogic.k
	if resource > BattleLogic.resources[resourceType].max then
		resource = BattleLogic.resources[resourceType].max
	end
	return math.floor(0.5+resource)
end

function BattleLogic.getLeftResource(resourceType)
	return math.floor(0.5+BattleLogic.resources[resourceType].left* BattleLogic.k)
end

function BattleLogic.computeScore(enemyScore)
    UserData.enemyScore = enemyScore
	local dis = enemyScore - UserData.userScore
	local isHigher = true
	if dis<0 then
		dis = -dis
		isHigher = false
	end
	local scores = nil
	if dis>=400 then
		scores = {60, 1}
	elseif dis>=250 then
		scores = {math.floor(50 + (dis-250)/(400-250)*(60-50)), math.floor(5+(dis-250)/(400-250)*(1-5))}
	elseif dis>=130 then
		scores = {math.floor(40 + (dis-130)/(250-130)*(50-40)), math.floor(10+(dis-130)/(250-130)*(5-10))}
	elseif dis>=10 then
		scores = {math.floor(30 + (dis-10)/(130-10)*(40-30)), math.floor(20+(dis-10)/(130-10)*(10-20))}
	else
		scores = {math.floor(25 + (dis-0)/(10-0)*(30-25)), math.floor(25+(dis-0)/(10-0)*(20-25))}
	end
	if isHigher then
		BattleLogic.scores = {scores[1], -scores[2]}
	else
		BattleLogic.scores = {scores[2], -scores[1]}
	end
end

function BattleLogic.getBattleResult()
	local result = {destroys = BattleLogic.destroys}
	local resourceTypes = {"oil", "food"}
	for i=1, 2 do
		local resourceType = resourceTypes[i]
		result[resourceType] = math.floor(0.5+BattleLogic.resources[resourceType].stolen* BattleLogic.k)
	end
	result.stars = BattleLogic.stars
	result.percent = BattleLogic.percent
	if not BattleLogic.isLeagueBattle then
    	if BattleLogic.stars==0 then
    		result.score = BattleLogic.scores[2]
    	else
    		result.score = math.ceil(BattleLogic.scores[1]*BattleLogic.stars/3)
    	end
    else
        result.score = 0
    end
	result.costTroops = BattleLogic.soldiers
	result.zombieDeployed = BattleLogic.zombieDeployed
	result.clanDeployed = BattleLogic.clanDeployed
	result.costTraps = BattleLogic.costTraps
	result.resourceBuilds = BattleLogic.builds
	result.shieldTime = timer.getTime() + BattleLogic.shieldHour*3600
	BattleLogic.init()
	return result
end

function BattleLogic.checkBattleEnable(scene, callback, callbackParam)
    if SoldierLogic.getCurSpace()==0 then
        display.pushNotice(UI.createNotice(StringManager.getString("noticeErrorNoSoldier")))
        for _, build in pairs(scene.builds) do
            if build.buildData.bid == 1001 then
                local bview = build.buildView.uiview
                if not bview:getChildByTag(1010) then
                    local pt = UI.createGuidePointer(0)
                    pt:setPosition(bview:getContentSize().width/2, build:getBuildY())
                    bview:addChild(pt, 100, 1010)
                    delayRemove(getParam("actionTimePointer", 3000)/1000, pt)
                end
                scene:runScaleAndMoveToCenterAction(scene.ground:getScale(), bview:getPositionX(), bview:getPositionY()+build.buildView.view:getContentSize().height/2)
                break
            end
        end
        display.closeDialog()
        return false
    elseif UserData.shieldTime>timer.getTime() then
        local function forceEnterBattle()
            UserData.shieldTime = 0
            callback(callbackParam)
        end
        display.showDialog(AlertDialog.new(StringManager.getString("alertTitleShield"), StringManager.getString("alertTextShield"), {callback=forceEnterBattle}))
        return false
    end
    return true
end