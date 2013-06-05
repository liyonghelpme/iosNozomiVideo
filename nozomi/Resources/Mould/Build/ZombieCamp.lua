ZombieCamp = class(Camp)

function ZombieCamp:initWithSetting(setting)
    self.soldierDatas = setting.soldiers
    self.curSpace = 0
    self.soldiers = {}
end

function ZombieCamp:getExtendInfo()
    local soldiers = {}
    for i=1, 8 do
        soldiers[i] = 0
    end
    for _, soldier in pairs(self.soldiers) do
        local sid = soldier.info.sid-10
        soldiers[sid] = soldiers[sid]+1
    end
    return {soldiers=soldiers}
end

function ZombieCamp:enterOperation()
    SoldierLogic.setZombieCampMax(self.buildIndex, self.buildData.extendValue1)
    SoldierLogic.setZombieCamp(self.buildIndex, self)
    
    if self.soldierDatas then
        self.soldiers={}
        local curSpace = 0
        for i=1, 8 do
            if (self.soldierDatas[i] or 0)>0 then
                for j=1, self.soldierDatas[i] do
                    SoldierLogic.addSoldierToCamp(i+10, nil, self)
                end
                curSpace = curSpace + self.soldierDatas[i] * StaticData.getSoldierInfo(i).space
            end
        end
        self.curSpace = curSpace
        self.soldierDatas = nil
    end
end

function ZombieCamp:addBuildInfo(bg, addInfoItem)
    addInfoItem(bg, 1, SoldierLogic.getCurZombieSpace, nil, SoldierLogic.getZombieSpaceMax(), "Camp")
    local temp = UI.createLabel(StringManager.getString("alltroops"), General.font1, 15, {colorR = 0, colorG = 0, colorB = 0})
    screen.autoSuitable(temp, {x=360, y=272, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    -- TODO
    infos = {}
    local off=10
    for i=11, 18 do
        infos[i-10] = {}
        if SoldierLogic.getSoldierNumber(i) then
            infos[i-off].bid = i
            infos[i-off].num = SoldierLogic.getSoldierNumber(i)
        else
            off = off+1
        end
    end
    local scrollView = UI.createScrollViewAuto(CCSizeMake(630, 98), true, {offx=1, offy=2, disx=5, size=CCSizeMake(74,94), infos=infos, cellUpdate=UI.updateScrollItemStyle1})
    screen.autoSuitable(scrollView.view, {nodeAnchor=General.anchorTop, x=360, y=246})
    bg:addChild(scrollView.view)
    return 1, 134
end

function ZombieCamp:addBuildUpgrade(bg, addUpgradeItem)
    local bdata = self.buildData
    local maxData = StaticData.getMaxLevelData(bdata.bid)
    local nextLevel = StaticData.getBuildData(bdata.bid, bdata.level+1)
    
    addUpgradeItem(bg, 1, bdata.extendValue1, nextLevel.extendValue1, maxData.extendValue1, "ZombieCamp")
    return 1
end

function ZombieCamp:getCurSpace()
    return self.curSpace
end

function ZombieCamp:onFocus(focus)
    if focus then
    --[[
        for i = 1, #(self.soldiers) do
            self.soldiers[i]:setPose()
        end
        --]]
    end
end

function ZombieCamp:onGridReset(backGrid, newGrid)
    if backGrid and newGrid then
        for i = 1, #(self.soldiers) do
            self.soldiers[i]:setMoveArround()
        end
    end
end

function ZombieCamp:getBuildView(state)
    local bid = self.buildData.bid
    local level = self.buildData.level
    local build = UI.createSpriteWithFile("images/build/" .. bid .. "/build" .. level .. ".png")
    return build
end

function ZombieCamp:updateOperationLogic()
    if SoldierLogic.getCurZombieSpace()==SoldierLogic.getZombieSpaceMax() then
        if not self.buildView.notice then
            self.buildView:showNotice(StringManager.getString("labelCampFullNotice"), 0.7)
        end
    else
        if self.buildView.notice then
            self.buildView.notice:removeFromParentAndCleanup(true)
            self.buildView.notice = nil
        end
    end
end

ZombieTomb = class(BuildMould)

function ZombieTomb:ctor(bid, setting)
    self.zombies = {}
    for i=1, 8 do
        self.zombies[i] = SoldierLogic.getSoldierNumber(10+i) or 0
    end
    self.buildData = {bid=bid, level=self.buildLevel, hitPoints=0, gridSize=2, soldierSpace=1}
end

function ZombieTomb:getBuildView()
	local build = UI.createSpriteWithFile("images/build/" .. self.buildData.bid .. "/build" .. self.buildData.level .. ".png")
	return build
end

function ZombieTomb:updateBattle(diff)
    if self.buildView.scene.isReplay then return end
    for i=1, 8 do
        if self.zombies[i]>0 then
            local zid = i+10
            self.zombies[i] = self.zombies[i]-1
            local zombie = Zombie.new(zid, {isFighting=true})
    		local x, y = zombie:getMoveArroundPosition(self)
    		x, y = math.floor(x), math.floor(y)
    		zombie:addToScene(self.buildView.scene, {x, y})
    		table.insert(self.buildView.scene.soldiers, zombie)
    		zombie:playAppearSound()
    		table.insert(ReplayLogic.cmdList, {math.floor((timer.getTime()-ReplayLogic.beginTime)*1000)/1000, "z", i, x, y})
    		break
        end
    end
end

--²»Òªµ×²¿Í¼Æ¬
function ZombieTomb:getBuildBottom()
end