Camp = class(BuildMould)

function UI.updateScrollItemStyle1(bg, scrollView, info)
    bg:removeAllChildrenWithCleanup(true)
    local temp = UI.createSpriteWithFile("images/battleItemBg.png",CCSizeMake(74, 94))
    screen.autoSuitable(temp, {x=0, y=0})
    bg:addChild(temp)
    if info.bid then
        if info.bid<=10 then
            SoldierHelper.addSoldierHead(bg, info.bid, 0.64)
        else
            temp = UI.createScaleSprite("images/zombieHead" .. (info.bid-10) .. ".png", CCSizeMake(67,87))
            screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=37, y=46})
            bg:addChild(temp)
        end
        if info.num then
            if info.level then
                temp = UI.createStar(info.level, 15, 13)
                screen.autoSuitable(temp, {x=3, y=6})
                bg:addChild(temp)
            end
            temp = UI.createLabel("x" .. info.num, General.font4, 18, {colorR = 255, colorG = 255, colorB = 255})
            screen.autoSuitable(temp, {x=37, y=81, nodeAnchor=General.anchorCenter})
            bg:addChild(temp)
        end
    end
end

function Camp:ctor()
    self.supportVisit = true
end

function Camp:initWithSetting(setting)
    self.soldierDatas = setting.soldiers
    self.curSpace = 0
    self.soldiers = {}
end

function Camp:getExtendInfo()
    local soldiers = {}
    for i=1, 10 do
        soldiers[i] = 0
    end
    for _, soldier in pairs(self.soldiers) do
        local sid = soldier.info.sid
        soldiers[sid] = soldiers[sid]+1
    end
    return {soldiers=soldiers}
end

function Camp:enterOperation()
    SoldierLogic.setCampMax(self.buildIndex, self.buildData.extendValue1)
    SoldierLogic.setCamp(self.buildIndex, self)
    
    if self.soldierDatas then
        self.soldiers={}
        local curSpace = 0
        for i=1, 10 do
            if (self.soldierDatas[i] or 0)>0 then
                for j=1, self.soldierDatas[i] do
                    SoldierLogic.addSoldierToCamp(i, nil, self)
                end
                curSpace = curSpace + self.soldierDatas[i] * StaticData.getSoldierInfo(i).space
            end
        end
        self.curSpace = curSpace
        self.soldierDatas = nil
    end
end

function Camp:addBuildInfo(bg, addInfoItem)
    addInfoItem(bg, 1, SoldierLogic.getCurSpace, nil, SoldierLogic.getSpaceMax(), "Camp")
    local temp = UI.createLabel(StringManager.getString("alltroops"), General.font1, 15, {colorR = 0, colorG = 0, colorB = 0})
    screen.autoSuitable(temp, {x=360, y=272, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    -- TODO
    infos = {}
    local off=0
    for i=1, 10 do
        infos[i] = {}
        if SoldierLogic.getSoldierNumber(i) then
            infos[i-off].bid = i
            infos[i-off].num = SoldierLogic.getSoldierNumber(i)
            infos[i-off].level = UserData.researchLevel[i]
        else
            off = off+1
        end
    end
    local scrollView = UI.createScrollViewAuto(CCSizeMake(630, 98), true, {offx=1, offy=2, disx=5, size=CCSizeMake(74,94), infos=infos, cellUpdate=UI.updateScrollItemStyle1})
    screen.autoSuitable(scrollView.view, {nodeAnchor=General.anchorTop, x=360, y=246})
    bg:addChild(scrollView.view)
    return 1, 134
end

function Camp:addBuildUpgrade(bg, addUpgradeItem)
    local bdata = self.buildData
    local maxData = StaticData.getMaxLevelData(bdata.bid)
    local nextLevel = StaticData.getBuildData(bdata.bid, bdata.level+1)
    
    addUpgradeItem(bg, 1, bdata.extendValue1, nextLevel.extendValue1, maxData.extendValue1, "Camp")
    return 1
end

function Camp:getCurSpace()
    return self.curSpace
end

function Camp:onFocus(focus)
    if focus then
        for i = 1, #(self.soldiers) do
            self.soldiers[i]:setPose()
        end
    end
end

function Camp:onGridReset(backGrid, newGrid)
    if backGrid and newGrid then
        for i = 1, #(self.soldiers) do
            self.soldiers[i]:setMoveArround()
        end
    end
end

--[[
function Camp:getBuildBottom()
    local level = self.buildData.level
    if level<=2 then 
        return UI.createSpriteWithFrame("lampstand5.png")
    end
    local bid = self.buildData.bid
    return UI.createSpriteWithFrame("campBottom" .. level .. ".png")
end
--]]

function Camp:getBuildView(state)
    local bid = self.buildData.bid
    local level = self.buildData.level
    
    local build = UI.createSpriteWithFile("images/build/" .. bid .. "/flag" .. level .. ".png")
    
    local aid = level
    if level==2 then
        aid=1
    elseif level==4 then
        aid=3
    elseif level>5 then
        aid=5
    end
    local temp = UI.createAnimateWithSpritesheet(getParam("actionTimeBuild" .. bid, 600)/1000, "build" .. bid .. "Action" .. aid .. "_", 5, {plist="animate/build/build" .. bid .. "Action" .. aid .. ".plist"})
    screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=build:getContentSize().width/2+32, y=122})
    build:addChild(temp)
    return build
end

function Camp:updateOperationLogic()
    if SoldierLogic.getCurSpace()==SoldierLogic.getSpaceMax() then
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

function Camp:getBuildShadow()
end
