require "Logic.ResourceLogic"
require "Logic.SoldierLogic"
require "Logic.BattleLogic"
require "Logic.ZombieLogic"
require "Logic.CrystalLogic"
require "Logic.GuideLogic"
require "Logic.ReplayLogic"
require "Logic.PauseLogic"
require "Mould.FlyObject"
require "Mould.Tomb"
require "Mould.Build"
require "Mould.Soldier"
require "Mould.NPC"
require "Mould.Zombie"
require "Mould.Builder"
require "Dialog.AlertDialog"
require "Dialog.ErrorDialog"
require "Scene.MenuLayer"
require "Scene.BattleMenuLayer"
require "Scene.ReplayMenuLayer"
require "Scene.ChatRoom"
require "Scene.MapGridView"

-- 为做到场景切换，做以下处理：
-- ctor里不初始化VIEW，全移动到initView里
-- 场景新增 prepare方法做预加载， isPrepared属性做预加载完成判断
-- 新增方法 initPreparedView 完成对预加载完成之后的对象初始化 

CastleScene = class()

local SIZEX, SIZEY = 4090, 3068
local GRIDSIZEX, GRIDSIZEY = 92, 69
local GRIDOFFX, GRIDOFFY = 2080, 195

function CastleScene:ctor()
    self.speed=1
    self.touchType="none"
    self.SIZEX=SIZEX
    self.SIZEY=SIZEY
    self.stateInfo={}
    self.inertia = {enable = false, touchlist = queue.create(2), speedX=0, speedY=0}
    
    local sceneScaleMin = screen.getScalePolicy(SIZEX, SIZEY)[screen.SCALE_NORMAL]
    self.scMin = sceneScaleMin
    self.scMax = getParam("mapScaleMax", 400)/100*sceneScaleMin
    sceneScaleMin = nil
    
    self.builds = {}
    self.soldiers = {}
    
    self.mapGrid = RhombGrid.new(GRIDSIZEX, GRIDSIZEY, GRIDOFFX, GRIDOFFY)
    self.mapGrid:setLimit(GridKeys.Build, 1, 40)

    self.mapWorld = nil
    self.updateEntry = nil
    
    self.initScale = 4
    self.battleBegin = false
    UserData.isNight=false
    
    self.bidToBuildView = {}
    self.newWorld = nil
    self.isFighting = nil
    
    self.stateInfo.touchIds = {}
    self.stateInfo.touchPoints = {}
    self.backPoints = {}
    self.isPrepared = false

    self.maxBuildId = 0
end
function CastleScene:getTempBuildId()
    self.maxBuildId = self.maxBuildId+1
    return self.maxBuildId
end

--图层
--land  地面背景 0
--MapGrid 建筑物显示块和线 1
--bottom 建筑物底座 2
--color filter  颜色贴图 20
--地面士兵 建筑物 zorder 21
--天空图片sky 10000 飞行单位
--ui图层   20000

function CastleScene:initView()
    self.view = CCTouchLayer:create(display.SCENE_PRI, true)
    self.view:setContentSize(General.winSize)
    local function onTouch(event, id, x, y)
        return self:onTouch(event, id, x, y)
    end
    self.view:registerScriptTouchHandler(onTouch)
    
    local ground = CCNode:create()
    screen.autoSuitable(ground, {screenAnchor=General.anchorCenter, nodeAnchor=General.anchorLeftBottom, x=-SIZEX/2, y=-SIZEY/2, scaleType=screen.SCALE_NORMAL, scale=self.scMin*self.initScale})
    self.view:addChild(ground, 0, 1024)
    self.ground = ground
    
    --if self.isFighting then
    print("world begin", os.clock())
        self.newWorld = NewWorld:create(84)
        self.view:addChild(self.newWorld)
        --self.mapWorld = self.newWorld
     --经营页面使用旧的world
    --end
        local w = World.new(84, 1000)
        w:initCell()
        self.mapWorld = w
        self.mapWorld:setScene(self)
    print("world clock", os.clock())
    --end

    self.soldierBuildingLayer = CCNode:create()
    self.ground:addChild(self.soldierBuildingLayer, 21)

    local sky = CCNode:create()
    self.ground:addChild(sky, 10000)
    self.sky = sky
    
    -- 覆盖层贴图，让整体变色
    local colorFilter = CCLayerColor:create(ccc4(255,255,255,255), SIZEX, SIZEY)
    screen.autoSuitable(colorFilter)
    self.ground:addChild(colorFilter, 20)
    local blend = ccBlendFunc:new_local()
    --blend.src = 0x0306
    --blend.dst = 1
    blend.src = 0
    blend.dst = 0x0300
    colorFilter:setBlendFunc(blend)
    self.colorFilter = colorFilter
    
    self.mapGridView = MapGridView.new(GRIDSIZEX, GRIDSIZEY, GRIDOFFX, GRIDOFFY)
    self.ground:addChild(self.mapGridView.view, 1)
    
    simpleRegisterEvent(self.view, {update={callback = self.update, inteval = 0}, enterOrExit ={callback = self.enterOrExit}}, self)
    print("other clock", os.clock())
end

function CastleScene:removeScene()
    local c1 = 0
    for _, build in pairs(self.builds) do
        if not build.deleted then
            local c = os.clock()
            build:removeFromScene()
            c1 = c1 + (os.clock()-c)
        end
    end
    self.view:removeFromParentAndCleanup(true)
    self.view = nil
    self.removed = true
end

function CastleScene:reloadScene()
    self.asynBuilds = {}
    UserData.isNight = false
    
    if not self.monitorId then
        self.monitorId = EventManager.registerEventMonitor(self.monitorEvents, self.eventHandler, self)
    end
    SoldierLogic.init()
    for _, build in pairs(self.builds) do
        if not build.deleted then
            if build.initWithSetting then
                build:initWithSetting(build.initSetting)
                local bid = build.buildData.bid
                if (bid>=1000 and bid<=1004) and self.sceneType==SceneTypes.Operation then
                    build:enterOperation()
                end
            end
            table.insert(self.asynBuilds, build) 
        end
    end
    if self.sceneType==SceneTypes.Visit or self.sceneType==SceneTypes.Operation then
        SoldierLogic.isInit = true
        SoldierLogic.updateSoldierList()
    end
    self:initMenu()
end

function CastleScene:initGround()
    -- land
    --CCTexture2D:setDefaultAlphaPixelFormat(kTexture2DPixelFormat_A8)
    for i = 0, 3 do
        local land = UI.createSpriteWithFile("images/background/background" .. i .. ".pvr.ccz")
        screen.autoSuitable(land, {nodeAnchor=General.anchorLeftTop, x=(i%2)*2044, y=SIZEY - 2044*math.floor(i/2)})
        land:setScale(2)
        self.ground:addChild(land, 0)
    end
    --CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB8888)
    local temp = UI.createSpriteWithFrame("sceneLight1.png",CCSizeMake(63, 63))
    screen.autoSuitable(temp, {x=998, y=2468})
    self.uiground:addChild(temp)
    --temp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCBlink:create(1,6), CCDelayTime:create(2))))
    Action.runBlinkAction(temp)
    temp = UI.createSpriteWithFrame("sceneLight1.png",CCSizeMake(63, 63))
    screen.autoSuitable(temp, {x=667, y=2700})
    self.uiground:addChild(temp)
    --temp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCBlink:create(1,6), CCDelayTime:create(2))))
    Action.runBlinkAction(temp)
    self:initFogs()
end

function CastleScene:prepare()
    local function prepareOver(eventType)
        if eventType.name=="exit" then
            self.isPrepared = true
        end
    end
    
    --改为在经营场景加载所有图片
    if self.sceneType==SceneTypes.Operation then
        local loader = CCImageLoader:create()
        loader:addImage("images/bottoms.pvr.ccz", "images/bottoms.plist", kCCTexture2DPixelFormat_RGBA4444)
        loader:addImage("images/normalUI.png", "images/normalUI.plist", kCCTexture2DPixelFormat_RGBA8888)
        for i=1, 4 do
            loader:addImage("images/background/background1.pvr.ccz", nil, kCCTexture2DPixelFormat_RGB565)
        end
        loader:addImage("images/build/otherBuilds.png", "images/build/otherBuilds.plist", kCCTexture2DPixelFormat_RGBA8888)
    --else
        local addList = {"animate/effects/normalEffect", "animate/effects/balloonAttack", "animate/effects/cannonAttack", "animate/effects/cannonThunder",
            "animate/effects/magicBomb", "animate/effects/mortarBall1", "animate/effects/mortarBall2", "animate/effects/mortarBomb",
            "animate/effects/mortarFire", "animate/effects/robotAttack", "animate/effects/thunderAttack",
            "animate/build/bombChip", "animate/build/wallFire", "animate/build/bombFire", "animate/build/wallChip", "animate/soldiers/dead"}
        for i, str in ipairs(addList) do
            loader:addImage(str .. ".png", str .. ".plist", kCCTexture2DPixelFormat_RGBA8888)
        end
        loader:registerScriptHandler(prepareOver)
        self.view:addChild(loader)
    else
        self.isPrepared = true
    end
end

function CastleScene:initPreparedView()
    local uiground = CCSpriteBatchNode:create("images/normalUI.png", 1000)
    self.ground:addChild(uiground, 20000)
    self.uiground = uiground
    local bottomSprite = CCSpriteBatchNode:create("images/bottoms.pvr.ccz", 400)
    self.ground:addChild(bottomSprite, 2)
    self.bottomSprite = bottomSprite
    if self.sceneType~=SceneTypes.Operation or self.sceneType~=SceneTypes.Visit then
        local effectBatch = CCSpriteBatchNode:create("animate/effects/normalEffect.png", 400)
        self.ground:addChild(effectBatch, 9999)
        self.effectBatch = effectBatch
    end
end

function CastleScene:unloadResource()
--不移除
--[[
    if self.sceneType~=SceneTypes.Operation or self.sceneType~=SceneTypes.Visit then
        local addList = {"animate/effects/normalEffect", "animate/effects/balloonAttack", "animate/effects/cannonAttack", "animate/effects/cannonThunder",
            "animate/effects/magicBomb", "animate/effects/mortarBall1", "animate/effects/mortarBall2", "animate/effects/mortarBomb",
            "animate/effects/mortarFire", "animate/effects/robotAttack", "animate/effects/thunderAttack",
            "animate/build/bombChip", "animate/build/wallFire", "animate/build/bombFire", "animate/build/wallChip", "animate/soldiers/dead"}
        for i, str in ipairs(addList) do
            CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(str .. ".plist")
            CCTextureCache:sharedTextureCache():removeTextureForKey(str .. ".png")
        end
    end
    --]]
end

function CastleScene:initFogs()
    local bg = self.sky
    
    local gsize = getParam("fogMoveSize", 60)/10
    local t = getParam("fogMoveTime", 10000)/1000
    
    local x, y = gsize * GRIDSIZEX, gsize * GRIDSIZEY
    
    temp = UI.createSpriteWithFile("images/sceneFog.png")
    screen.autoSuitable(temp, {x=0, y=0})
    temp:setScale(16)
    bg:addChild(temp, 30000)
    
    temp = UI.createSpriteWithFile("images/sceneCloudUp.png")
    screen.autoSuitable(temp, {x=-1042, y=1664})
    temp:setScale(16)
    bg:addChild(temp, 30000)
    temp:runAction(Action.createVibration(t, x, y))
    
    temp = UI.createSpriteWithFile("images/sceneCloudDown.png")
    screen.autoSuitable(temp, {x=2464, y=-352})
    temp:setScale(16)
    bg:addChild(temp, 30000)
    temp:runAction(Action.createVibration(t, x, y))
    
    if self.sceneType==SceneTypes.Operation then
        local zombieView = RhombGrid.new(GRIDSIZEX, GRIDSIZEY, 930, 2212)
        zombieView:setGridUse(GridKeys.Build, 1, 1, 22, 2)
        zombieView:setGridUse(GridKeys.Build, 10, 0, 12, 1)
        zombieView:setGridUse(GridKeys.Build, 6, 5, 7, 3)
        zombieView:clearGridUse(GridKeys.Build, 9, 5, 2, 1)
        zombieView:setGridUse(GridKeys.Build, 9, 3, 12, 1)
        zombieView:setGridUse(GridKeys.Build, 11, 4, 3, 1)
        zombieView:setGridUse(GridKeys.Build, 17, 4, 4, 1)
        --zombieView:setGridUse(GridKeys.Build, 8, 1, 7)
        --zombieView.view:runAction(CCAlphaTo:create(0.1, 120, 120))
        --self.ground:addChild(zombieView.view, 10)
        -- 9
        
        local zombieView3 = RhombGrid.new(GRIDSIZEX, GRIDSIZEY, 0, 246)
        zombieView3:setGridUse(GridKeys.Build, 1, 1, 6, 20)
        --zombieView3.view:runAction(CCAlphaTo:create(0.1, 120, 120))
        --self.ground:addChild(zombieView3.view, 10)
        -- 6
        
        local zombieView4 = RhombGrid.new(GRIDSIZEX, GRIDSIZEY, 3220, 2225)
        zombieView4:setGridUse(GridKeys.Build, 1, 1, 3, 20)
        --zombieView4.view:runAction(CCAlphaTo:create(0.1, 120, 120))
        --self.ground:addChild(zombieView4.view, 10)
        -- 5
        
        local zombieView5 = RhombGrid.new(GRIDSIZEX, GRIDSIZEY, 2320, 60)
        zombieView5:setGridUse(GridKeys.Build, 1, 1, 2, 30)
        --zombieView5.view:runAction(CCAlphaTo:create(0.1, 120, 120))
        --self.ground:addChild(zombieView5.view, 10)
        -- 4
        
        local zombieView2 = RhombGrid.new(GRIDSIZEX/2, GRIDSIZEY/2, 690, -160)
        zombieView2:setGridUse(GridKeys.Build, 1, 1, 6)
        zombieView2:setGridUse(GridKeys.Build, 1, 7, 4)
        zombieView2:setGridUse(GridKeys.Build, 0, 10, 5)
        zombieView2:setGridUse(GridKeys.Build, 0, 15, 4)
        zombieView2:setGridUse(GridKeys.Build, 1, 18, 4)
        zombieView2:setGridUse(GridKeys.Build, 4, 19, 7)
        zombieView2:clearGridUse(GridKeys.Build, 5, 20, 6)
        zombieView2:setGridUse(GridKeys.Build, 11, 19, 2)
        zombieView2:setGridUse(GridKeys.Build, 7, 1, 5)
        zombieView2:setGridUse(GridKeys.Build, 12, 1, 3)
        zombieView2:setGridUse(GridKeys.Build, 12, 2, 4)
        zombieView2:setGridUse(GridKeys.Build, 16, 2, 5)
        zombieView2:setGridUse(GridKeys.Build, 21, 3, 3)
        zombieView2:setGridUse(GridKeys.Build, 21, 4, 3)
        zombieView2:setGridUse(GridKeys.Build, 13, 13, 11)
        zombieView2:setGridUse(GridKeys.Build, 13, 24, 2)
        zombieView2:setGridUse(GridKeys.Build, 15, 24, 2)
        zombieView2:setGridUse(GridKeys.Build, 17, 24, 2)
        zombieView2:setGridUse(GridKeys.Build, 19, 24, 2)
        zombieView2:setGridUse(GridKeys.Build, 21, 24, 2)
        zombieView2:clearGridUse(GridKeys.Build, 16, 13, 8)
        zombieView2:clearGridUse(GridKeys.Build, 23, 13, 1)
        zombieView2:clearGridUse(GridKeys.Build, 13, 22, 1)
        zombieView2:clearGridUse(GridKeys.Build, 13, 23, 1)
        
        self.asynSoldiers = {}
        local zombies = self.asynSoldiers
        for i=1, 9 do
            local z=Zombie.new(math.random(2)+10, {mapGrid=zombieView}, 0.8)
            table.insert(zombies, z)
        end
        for i=1, 7 do
            local z=Zombie.new(math.random(2)+10, {mapGrid=zombieView2}, 1.05)
            table.insert(zombies, z)
        end
        for i=1, 6 do
            local z=Zombie.new(math.random(2)+10, {mapGrid=zombieView3}, 1.05)
            table.insert(zombies, z)
        end
        for i=1, 5 do
            local z=Zombie.new(math.random(2)+10, {mapGrid=zombieView4}, 0.8)
            table.insert(zombies, z)
        end
        for i=1, 4 do
            local z=Zombie.new(math.random(2)+10, {mapGrid=zombieView5}, 1)
            table.insert(zombies, z)
        end
    end
end

function CastleScene:initData()
    self:initBuilds()
end

-- 不在初始化建筑的时候即时完成对建筑VIEW的初始化，避免内存加载高峰
function CastleScene:initBuilds()
    local initInfo = self.initInfo
    self.builds = {}
    self.walls = {}
    if not self.asynSoldiers then
        self.asynSoldiers = {}
    end
    local bnum = #(initInfo.builds)
    local bcache = {}
    self.asynBuilds = {}
    --按道理讲是不会有这个问题的
    for i=1, bnum do
        local build = initInfo.builds[i]
        local bid = build.bid
        bcache[bid] = (bcache[bid] or 0)+1
        local setting = {id=build.buildIndex, buildIndex=bcache[bid], initGridX=math.floor(build.grid/10000), initGridY=build.grid%10000, level=build.level, time=build.time}
        if build.extend then
            for k, v in pairs(build.extend) do
                setting[k] = v
            end
        end
        --只有经营状态才能看到初始化为残血的建筑
        if self.sceneType==SceneTypes.Operation or self.sceneType==SceneTypes.Visit then
            setting.hitpoints = build.hitpoints
        end
        self.builds[build.buildIndex] = Build.create(build.bid, nil, setting)
        table.insert(self.asynBuilds, self.builds[build.buildIndex]) 
        if (bid>=1000 and bid<=1004) and self.sceneType==SceneTypes.Operation then
            self.builds[build.buildIndex]:enterOperation()
        end
    end
end

function CastleScene:moveTo(dx, dy)
    local scale = self.ground:getScaleX()
    dx = squeeze(dx, General.winSize.width-self.SIZEX * scale, 0)
    dy = squeeze(dy, General.winSize.height-self.SIZEY * scale, 0)
    self.ground:setPosition(dx, dy)
end

function CastleScene:moveBy(x, y)
    local cx, cy = self.ground:getPosition()
    self:moveTo(cx + x, cy + y)
end

function CastleScene:batchAddToScene()
    local ct = os.clock()
    local rr = 1
    while #(self.asynBuilds)>0 do
        local build = table.remove(self.asynBuilds)
        build:addToScene(self)
        if os.clock()-ct>rr then
            return false
        end
    end
    while #(self.asynSoldiers)>0 do
        local soldier = table.remove(self.asynSoldiers)
        soldier:addToScene(self)
        if os.clock()-ct>rr then
            return false
        end
    end
    return true
end

function CastleScene:scaleTo(scale, centerX, centerY, isTouch)
    local max = self.scMax
    if isTouch then max = max*1.2 end
    scale = squeeze(scale, self.scMin, max)
    if not (centerX and centerY) then
        centerX, centerY = General.winSize.width/2, General.winSize.height/2
    end

    local oldWorldCenter = CCPointMake(centerX, centerY)
    local nodeCenter = self.ground:convertToNodeSpace(oldWorldCenter)

    self.ground:setScale(scale)
    local newWorldCenter = self.ground:convertToWorldSpace(nodeCenter)
    self:moveBy(oldWorldCenter.x - newWorldCenter.x, oldWorldCenter.y - newWorldCenter.y)
end
        
-- 选定地图上某点移到中心的ACTION
function CastleScene:runScaleAndMoveToCenterAction(scale, nodeX, nodeY)
    scale = squeeze(scale, self.scMin, self.scMax)
    if not (nodeX and nodeY) then
        nodeX, nodeY = self.SIZEX/2, self.SIZEY/2
    end
            
    local posx, posy = self.ground:getPosition()
    local curScale = self.ground:getScale()
    local targetPos = CCPointMake(General.winSize.width/2 - nodeX * scale, General.winSize.height/2 - nodeY * scale)

    self.stateInfo.movAction = {baseX = posx, baseY = posy, baseScale = curScale, deltaX = targetPos.x - posx, deltaY = targetPos.y - posy, deltaScale = scale - curScale}
    self.stateInfo.moving = true
    self.stateInfo.totalTime = getParam("menuInTime", 200)/1000
    self.stateInfo.time = 0
end

function CastleScene:onTouchBegan(id, x, y)
    local touchNum = (self.stateInfo.touchNum or 0)+1
    local state = self.stateInfo
    state.touchNum = touchNum
    if self.touchType=="build" then
        self.backPoints[id] = {x, y}
        return false
    end
    local stouchNum = #(state.touchIds)
    -- 如果是第一个点，那么需要做一个智慧的判断
    local isTouch = false
    if stouchNum==0 then
        state.touchPoints[id] = {x, y}
        state.touchIds[1] = id
        state.touchPoint = {x, y}
        --state.touchStart = {x, y}
        state.touchTime = timer.getTime() + 0.5
        self.touchBuild = nil
        if not self.isReplay and (self.sceneType == SceneTypes.Operation or self.sceneType==SceneTypes.Zombie) then
            local firstBuild = self.focusBuild or self.buyingBuild
            if firstBuild and firstBuild:checkTouch(x, y) then
                isTouch = true
                self.touchBuild = firstBuild
            end
            if not isTouch and not self.buyingBuild then
                local cpoint = self.ground:convertToNodeSpace(CCPointMake(x,y))
                local grid = self.mapGrid:convertToGrid(cpoint.x, cpoint.y)
                for i=0, 3 do
                    local gx, gy = grid.gridPosX-1+(i%2), grid.gridPosY-1+math.floor(i/2)
                    local g = self.mapGrid:getGrid(GridKeys.Build, gx, gy)
                    local build = g and g.obj
                    if build and build~=firstBuild and build:checkTouch(x, y) then
                        isTouch = true
                        self.touchBuild = build
                        break
                    end
                end
            end
            if self.touchBuild then
                self.buildMovable = self.touchBuild:onTouchBegan(x, y)
            end
        end
    elseif stouchNum==1 then
        state.touchTime = nil
        self.touchBuild = nil
        self.touchType="scene"
        state.touchIds[2] = id
        state.touchPoints[id] = {x, y}
        local id1 = state.touchIds[1]
        state.touchPoint = {(state.touchPoints[id1][1] + x)/2, (state.touchPoints[id1][2] + y)/2}
        state.length = math.sqrt((state.touchPoints[id1][1] - x)^2 + (state.touchPoints[id1][2] - y)^2)
    else
        self.backPoints[id] = {x, y}
    end
    self.stateInfo.moving = false
    self.inertia.enable = false
    self.inertia.touchlist.clear()
    return true
end

function CastleScene:onTouchMoved(id, x, y)
    local state = self.stateInfo
    if not state.touchPoints[id] then
        self.backPoints[id] = {x, y}
        return
    end
    local stouchNum = #(state.touchIds)
    if stouchNum==1 then
        if state.touchPoint then
            local ox, oy = x - state.touchPoint[1], y - state.touchPoint[2]
            if self.touchType == "scene" then
                self:moveBy(ox, oy)
                state.touchPoint = {x, y}
                self.touchBuild = nil
                state.touchTime = nil
                self.inertia.touchlist.push({time=timer.getTime(), point = state.touchPoint})
            else
                self:singleTouchMove(ox, oy)
            end
        end
        state.touchPoints[id] = {x, y}
    else
        state.touchPoints[id] = {x, y}
        local id1, id2 = state.touchIds[1], state.touchIds[2]
        local newPoint = {(state.touchPoints[id1][1] + state.touchPoints[id2][1])/2, (state.touchPoints[id1][2] + state.touchPoints[id2][2])/2}
        local newLength = math.sqrt((state.touchPoints[id1][1] - state.touchPoints[id2][1])^2 + (state.touchPoints[id1][2] - state.touchPoints[id2][2])^2)
        if state.touchPoint and state.length then
            self:moveBy(newPoint[1] - state.touchPoint[1], newPoint[2] - state.touchPoint[2])
            self:scaleTo(self.ground:getScale()*newLength/state.length, newPoint[1], newPoint[2], true)
        end
        --self.touchType = "scene"
        --state.moving = false
        state.touchPoint = newPoint
        state.length = newLength
    end
end

function CastleScene:singleTouchMove(ox, oy)
    if self.touchType=="none" then
        local mov = math.abs(ox)+math.abs(oy)
        if self.touchBuild and self.buildMovable then
            if self.touchBuild:onTouchMoved(ox, oy) then
                self.touchType="build"
                mov = 0
                self.stateInfo.touchTime = nil
            end
        end
        if mov>20 then
            if self.touchBuild then
                self.touchBuild = nil
            end
            -- move half to make the touch smooth
            self:moveBy(ox/2, oy/2)
            self.touchType = "scene"
            self.stateInfo.touchTime = nil
        end
    elseif self.touchType=="build" then
        self.touchBuild:onTouchMoved(ox, oy)
    end
end

function CastleScene:onTouchEnded(id, x, y)
    local touchNum = self.stateInfo.touchNum-1
    local state = self.stateInfo
    state.touchNum = touchNum
    if not state.touchPoints[id] then
        self.backPoints[id] = nil
        return
    end
    local stouchNum = #(state.touchIds)
    if stouchNum == 2 then
        state.touchPoints[id] = nil
        if state.touchIds[2]==id then
            state.touchIds[2] = nil
        else
            state.touchIds = {state.touchIds[2]}
        end
        state.touchPoint = state.touchPoints[state.touchIds[1]]
    elseif stouchNum == 1 then
        state.touchIds = {}
        state.touchPoints = {}
        if self.ground:getScale()>self.scMax then
            local p = CCPointMake(General.winSize.width/2, General.winSize.height/2)
            p = self.ground:convertToNodeSpace(p)
            self:runScaleAndMoveToCenterAction(self.scMax, p.x, p.y)
        end
        if self.touchBuild then
            self.touchBuild:onTouchEnded()
        elseif self.touchType=="none" and self.singleTouchEnd then
            self:singleTouchEnd()
        elseif self.touchType=="scene" then
            if self.inertia.touchlist.size() == 2 then
                local t1, t2 = self.inertia.touchlist.get(1), self.inertia.touchlist.get(2)
                local stime = t1.time - t2.time
                if stime < 0.3 then
                    if stime < 0.015 then stime=0.015 end
                    self.inertia.touchlist.clear()
                    self.inertia.speedX, self.inertia.speedY = (t1.point[1] - t2.point[1])/stime, (t1.point[2] - t2.point[2])/stime
                    self.inertia.enable = true
                end
            end
        end
        self.touchType = "none"
    end
    state.touchNum = touchNum
    local addBackPointId = nil
    for id, point in pairs(self.backPoints) do
        self:onTouchBegan(id, point[1], point[2])
        addBackPointId = id
        break
    end
    state.touchTime = nil
    self.touchBuild = nil
    if addBackPointId then
        self.backPoints[addBackPointId] = nil
    elseif stouchNum==0 then
        state.touchPoint = nil
        state.length = nil
    end
end

function CastleScene:onTouchHold()
    if self.touchBuild and self.buildMovable then
        local state = self.touchBuild.state
		if state.touchPoint and not state.isFocus then
			self.touchBuild:setFocus(true)
		end
    end
    self.stateInfo.touchTime = nil
end

function CastleScene:onTouch(eventType, id, x, y)
    if eventType == CCTOUCHBEGAN then
        return self:onTouchBegan(id, x, y)
    elseif eventType == CCTOUCHMOVED then
        return self:onTouchMoved(id, x, y)
    else
        return self:onTouchEnded(id, x, y)
    end
end

function CastleScene:updateNightMode()
    --if true then return end
    if UserSetting.nightMode or UserData.isNight then
        local dtime = timer.getDayTime()
        local isTimeNight = UserSetting.nightMode --and (dtime<21600 or dtime>=64800)
        if isTimeNight ~= UserData.isNight then
            UserData.isNight = isTimeNight
            if isTimeNight then
		        UserStat.stat(UserStatType.NIGHT)
                self.colorFilter:setColor(General.nightColor)
            else
                self.colorFilter:setColor(General.normalColor)
            end
        end
    end
end

function CastleScene:update(diff)
    self.logicDiff = (self.logicDiff or 0) + diff
    if self.logicDiff > 1 or self.isReplay then
        self:updateLogic(self.logicDiff)
        self:updateNightMode()
        self.logicDiff = 0
    end
    
    --[[
    self.debugDiff = (self.debugDiff or 0) + diff
    if self.debugDiff > 20 then
        CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
        self.debugDiff = nil
    end
    --]]
    local state = self.stateInfo
    if state.moving then
        state.touchTime = nil
        local baseDelta = state.time/state.totalTime
        state.time = state.time + diff
        local action = state.movAction
        local delta = state.time/state.totalTime
        if action.deltaScale < 0 then
            baseDelta = Action.sinein(baseDelta)
            delta = Action.sinein(delta)
        else
            baseDelta = Action.sineout(baseDelta)
            delta = Action.sineout(delta)
        end
        self.ground:setScale(action.baseScale + action.deltaScale * delta)
        self:moveBy(action.deltaX * (delta-baseDelta),  action.deltaY * (delta-baseDelta))
                
        if state.time >= state.totalTime then
            state.moving = false
        end
    end
    if self.inertia.enable then
        state.touchTime = nil
        local mov = diff*(math.abs(self.inertia.speedX) + math.abs(self.inertia.speedY))
        if mov>1 then
            self:moveBy(self.inertia.speedX * diff, self.inertia.speedY * diff)
            self.inertia.speedX, self.inertia.speedY = self.inertia.speedX*0.9, self.inertia.speedY*0.9
        else
            self.inertia.enable = false
        end
    end
    if state.touchTime and state.touchTime<timer.getTime() then
        self:onTouchHold()
    end
end

function CastleScene:enterOrExit(isEnter)
    if isEnter then
        self.isShow = true
        if not self.monitorId then
            self.monitorId = EventManager.registerEventMonitor(self.monitorEvents, self.eventHandler, self)
        end

         local updateWorld = function(diff) 
             self.mapWorld:update(diff)
             if self.newWorld then
                self.newWorld:clearSearchYet()
             end
         end
         self.updateEntry = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateWorld, 0, false)
    else
        self.isShow = false
        EventManager.removeEventMonitor(self.monitorId)
        self.monitorId = nil

         CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateEntry)
    end
end

function CastleScene:showBuildingArea()
    
    local areaAlpha = getParam("buildingAreaAlpha", 38)
    local lineAlpha = getParam("buildingLineAlpha", 100)
    
    local sactions = CCArray:create()
    sactions:addObject(CCShow:create())
    sactions:addObject(CCAlphaTo:create(0.5, 0, areaAlpha))
    sactions:addObject(CCDelayTime:create(2))
    sactions:addObject(CCAlphaTo:create(0.5, areaAlpha, 0))
    sactions:addObject(CCHide:create())
    
    self.mapGridView.blockBatch:stopAllActions()
    self.mapGridView.blockBatch:runAction(CCSequence:create(sactions))
    
    sactions = CCArray:create()
    sactions:addObject(CCShow:create())
    sactions:addObject(CCAlphaTo:create(0.5, 0, lineAlpha))
    sactions:addObject(CCDelayTime:create(2))
    sactions:addObject(CCAlphaTo:create(0.5, lineAlpha, 0))
    sactions:addObject(CCHide:create())
    
    self.mapGridView.linesBatch:stopAllActions()
    self.mapGridView.linesBatch:runAction(CCSequence:create(sactions))
end

function CastleScene:getMaxLevel(bid)
    local maxLevel = 0
    for i, build in pairs(self.builds) do
        if build.buildData.bid==bid and build.buildLevel>maxLevel then
            maxLevel = build.buildLevel
        end
    end
    return maxLevel
end

function CastleScene:countSoldier()
    local num = 0
    local toDel = {}
	for i, soldier in pairs(self.soldiers) do
	    if soldier.deleted then
			table.insert(toDel, i)
		else
			num = num+1
		end
	end
	for i=1, #toDel do
		self.soldiers[toDel[i]] = nil
	end
	return num
end

OperationScene = class(CastleScene)

function OperationScene:ctor()
    self.sceneType = SceneTypes.Operation
    self.monitorEvents = {"EVENT_BUY_BUILD", "EVENT_BUY_SOLDIER", "EVENT_GUIDE_STEP", "EVENT_VISIT_USER"}
    self.synOver = true
    self.synTime = 0
    self.music = "music/operation.mp3"
end

function OperationScene:initMenu()
    local menu = MenuLayer.new(self)
    self.view:addChild(menu.view)
    self.menu = menu
    
    local chatRoom = ChatRoom.create()
    self.view:addChild(chatRoom)
end

local function loadBattleHistory(isSuc, result)
    if isSuc then
        local data = json.decode(result)
        local battles = {}
        local newBattles = {}
        for i=1, #data do
        --{id=1, score=21, stars=0, percent=40, time=1362642124, uscore=1460, food=2635, oil=8890, special=0, clan="Flesh", name="Boice", items={{id=2,num=53,level=5}, {id=5,num=10,level=3}, {id=3, num=54, level=4}, {id=1, num=53, level=4}}},
		    
		    local base = data[i]
		    local item = base[1]
		    local historyItem = {id=base[2], time=timer.getTime(base[3]), videoId=base[4], revenged=(base[5]==1), score=item[1], stars=item[2], percent=item[3], uscore=item[4], food=item[5], oil=item[6], name=item[7], items=item[8]} 
		    
            table.insert(battles,historyItem)
            if historyItem.time > UserData.lastSynTime then
                table.insert(newBattles, historyItem)
            end
        end
        UserData.historys = battles
        if #battles>0 then
            table.sort(battles, getSortFunction("time"))
            print("has?")
            EventManager.sendMessage("EVENT_NOTICE_BUTTON", {name="mail", isShow=(#newBattles>0)})
        end
    end
end

function OperationScene:initData()
    local initInfo = self.initInfo
    if not self.monitorId then
        self.monitorId = EventManager.registerEventMonitor(self.monitorEvents, self.eventHandler, self)
    end
    SoldierLogic.init()
    Achievements.init(initInfo.achieves)
    Build.init()
    local obsNum = 0
    for i, build in pairs(initInfo.builds) do
        local bid = build.bid
        Build.incBuild(bid)
        if bid>=4000 and bid<5000 then
            obsNum = obsNum+1
        end
        EventManager.sendMessage("EVENT_BUILD_UPDATE", {bid=build.bid, level=build.level})
    end
    
    self.researchLevel = initInfo.researches
    
    if initInfo.serverTime then
        timer.setServerTime(initInfo.serverTime)
        UserData.userScore = initInfo.score
        UserData.lastSynTime = timer.getTime(initInfo.lastSynTime)
        UserData.shieldTime = timer.getTime(initInfo.shieldTime)
        UserData.userName = initInfo.name
        UserData.clan = initInfo.clan
        if getParam("switchZombieOpen", 0)~=0 then
            initInfo.zombieTime = 0
        end
        UserData.zombieShieldTime = timer.getTime(initInfo.zombieTime)
        UserData.crystal = initInfo.crystal
        UserData.obstacleTime = timer.getTime(initInfo.obstacleTime)
        --ZombieLogic.zombieDefends = initInfo.zombieDefends
        if getParam("switchGuideOpen", 0)~=0 then
            initInfo.guide = 0
        end
        UserData.researchLevel = copyData(self.researchLevel)
        
        if initInfo.guide>=1300 then
            network.httpRequest("getBattleHistory", loadBattleHistory, {params={uid=UserData.userId}})
        end
    end

    self:initBuilds(initInfo)
    
    if initInfo.guide then
        local guideValue = initInfo.guide
        if guideValue==0 then
            GuideLogic.init(1, nil, self)
        else
            GuideLogic.init(math.floor(guideValue/100), guideValue%100, self)
        end
    end
    self.obsNum = obsNum
    
    SoldierLogic.isInit = true
    SoldierLogic.updateSoldierList()
end

function OperationScene:singleTouchEnd()
    if self.focusBuild and not self.buyingBuild then
        self.focusBuild:releaseFocus()
    end
end

function OperationScene:updateLogic(diff)
    if self.sceneType~=SceneTypes.Operation then return end
    local function synDataOver(suc, result)
        if suc then
            self.synOver = true
        else
        end
    end
    if display.isSceneChange then return end
    SoldierLogic.updateSoldierList()
    
    local t1 = timer.getTime()
    if UserData.obstacleTime<t1 then
        if self.obsNum<40 then
            self.obsNum = self.obsNum+1
            UserData.obstacleTime = UserData.obstacleTime + 28800
            local bid
            while true do
                bid = 3999+math.random(18)
                if bid<4015 and bid~=4010 and bid~=4011 and bid~=4005 then break end
            end
            local b = Build.create(bid, nil, {})
            local gx, gy 
            while true do
                gx, gy = math.random(40), math.random(40)
                if self.mapGrid:checkGridEmpty(GridKeys.Build, gx, gy, b.buildData.gridSize) then
                    break
                end
            end
            b:addToScene(self, {initGridX=gx, initGridY=gy})
            table.insert(self.builds, b)
        else
            UserData.obstacleTime = math.ceil((t1-UserData.obstacleTime)/28800)*28800 + UserData.obstacleTime
        end
    end
    self.synTime = self.synTime+diff
    if self.synTime>30 then
        if self.synOver then
            local deleteIndex = {}
            local buildMap = {}
            for i, binfo in pairs(self.initInfo.builds) do
                buildMap[binfo.buildIndex] = {index=i, info=binfo}
            end
            local delete, update={}, {}
            for i, build in pairs(self.builds) do
                if build.deleted then
                    table.insert(deleteIndex, i)
                else
                    local binfo = build:getBaseInfo()
                    binfo.buildIndex = i
                    if not buildMap[i] then
                        build.id = i
                        table.insert(update, binfo)
                        table.insert(self.initInfo.builds, binfo)
                    else
                        if not cmpData(binfo, buildMap[i].info) then
                            table.insert(update, binfo)
                            self.initInfo.builds[buildMap[i].index] = binfo
                        end
                        buildMap[i] = nil
                    end
                end
            end
            for i, todel in pairs(buildMap) do
                table.insert(delete, i)
                self.initInfo.builds[todel.index] = nil
            end
            for _, i in pairs(deleteIndex) do
                self.builds[i] = nil
            end
                
            local params, needSyn = {uid=UserData.userId}, false
            
            if #delete > 0 then
                params.delete = json.encode(delete)
                needSyn = true
            end
            if #update > 0 then
                params.update = json.encode(update)
                needSyn = true
            end
            
            local updateInfo = false
            local infos = {}
            --UserData.clan = initInfo.clan
            if UserData.crystal ~= self.initInfo.crystal then
                self.initInfo.crystal = UserData.crystal
                infos.crystal = UserData.crystal
                updateInfo = true
            end
            --[[
            if UserData.ulevel ~= self.initInfo.ulevel then
                self.initInfo.ulevel = UserData.ulevel
                infos.level = UserData.ulevel
                updateInfo = true
            end
            if UserData.exp ~= self.initInfo.exp then
                self.initInfo.exp = UserData.exp
                infos.exp = UserData.exp
                updateInfo = true
            end
            --]]
            if UserData.userScore~=self.initInfo.score then
                self.initInfo.score = UserData.userScore
                infos.exp = UserData.userScore
                updateInfo = true
            end
            local shieldTime = timer.getServerTime(UserData.shieldTime)
            if shieldTime ~= self.initInfo.shieldTime then
                self.initInfo.shieldTime = shieldTime
                infos.shieldTime = shieldTime
                updateInfo = true
            end
            local zombieTime = timer.getServerTime(UserData.zombieShieldTime)
            if zombieTime ~= self.initInfo.zombieTime then
                self.initInfo.zombieTime = zombieTime
                infos.zombieTime = zombieTime
                updateInfo = true
            end
            local obstacleTime = timer.getServerTime(UserData.obstacleTime)
            if obstacleTime ~= self.initInfo.obstacleTime then
                self.initInfo.obstacleTime = obstacleTime
                infos.obstacleTime = obstacleTime
                updateInfo = true
            end
            local guideValue = (GuideLogic.step or 0)* 100 + (GuideLogic.num or 0)
            if guideValue~=self.initInfo.guide then
                self.initInfo.guide = guideValue
                infos.guideValue = guideValue
                updateInfo = true
            end
            --[[
            if ZombieLogic.zombieDefends ~= self.initInfo.zombieDefends then
                self.initInfo.zombieDefends = ZombieLogic.zombieDefends
                infos.zombieDefends = ZombieLogic.zombieDefends
                updateInfo = true
            end
            --]]
            if UserData.userName ~= self.initInfo.name then
                self.initInfo.name = UserData.userName
                infos.name = UserData.userName
                updateInfo = true
            end
            if updateInfo then
                needSyn = true
                params.userInfo = json.encode(infos)
            end
            
            local oldAchieves = self.initInfo.achieves
            local newAchieves = Achievements.getAchievements()
            local tempMap = {}
            local updateAchieves = {}
            for i=1, #newAchieves do
                local a = newAchieves[i]
                tempMap[a[1]] = a
            end
            for i=1, #oldAchieves do
                local a = oldAchieves[i]
                local b = tempMap[a[1]]
                if b and (b[2]~=a[2] or b[3]~=a[3]) then
                    a[2] = b[2]
                    a[3] = b[3]
                    table.insert(updateAchieves, a)
                end
            end
            if #updateAchieves > 0 then
                needSyn = true
                params.achieves = json.encode(updateAchieves)
            end
            local statData = UserStat.dump()
            if statData then
                needSyn = true
                params.stat = json.encode(statData)
            end
            statData = UserStat.dumpCrystal()
            if statData then
                needSyn = true
                params.crystal = json.encode(statData)
            end
            if not cmpData(UserData.researchLevel, self.initInfo.researches) then
                needSyn = true
                params.research = json.encode(UserData.researchLevel)
                self.initInfo.researches = copyData(UserData.researchLevel)
            end
            if needSyn then
                self.synOver = false
                print(json.encode(params))
                if UserData.enemyId then
                    params.eid = UserData.enemyID
                    UserData.enemyId = nil
                end
                if not UserData.noPerson then
                    network.httpRequest("synData", synDataOver, {isPost=true, params=params})
                else
                    self.synOver = true
                end
            end
        end
        self.synTime = 0
    end
end

function OperationScene:eventHandler(eventType, params)
    if eventType == EventManager.eventType.EVENT_BUY_BUILD then
        local bid = params
        local isContinue = false
        if type(params)=="table" then
            bid = params.buildData.bid
            isContinue = true
        end
        local info = Build.getBuildStoreInfo(bid)
        if info.buildsNum == info.totalMax then
            display.pushNotice(UI.createNotice(StringManager.getString("noticeBuildErrorTotal")))
            return
        elseif info.buildsNum == info.levelLimit then
            if info.buildsNum==0 then
                display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeBuildErrorUnlock", {name=StringManager.getString("dataBuildName" .. TOWN_BID), level=info.nextLevel})))
            else
                display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeBuildErrorMore", {name=StringManager.getString("dataBuildName" .. TOWN_BID), level=info.nextLevel})))
            end
            return
        else
            display.closeDialog()
        end
            
        if self.buyingBuild then
            self.buyingBuild.buildView:buyOver(false)
            self.buyingBuild = nil
        end
        local setting = {isBuying=true, buildIndex=info.buildsNum+1}
        if isContinue then
            local dir = {-1, 0}
            local g2 = params.buildView.state.grid
            if params.lastBuild then
                local g1 = params.lastBuild.buildView.state.grid
                local ox, oy =g2.gridPosX-g1.gridPosX, g2.gridPosY-g1.gridPosY
                local mx, my = math.abs(ox), math.abs(oy)
                if mx>my then
                    dir = {ox/mx, 0}
                else
                    dir = {0, oy/my}
                end
            end
            local gsize = params.buildView.state.grid.gridSize
            dir = {dir[1]*gsize, dir[2]*gsize}
            while g2.gridPosX+dir[1]<1 or g2.gridPosX+dir[1]>41-gsize or g2.gridPosY+dir[2]<1 or g2.gridPosY+dir[2]>41-gsize do
                dir = {-dir[2], dir[1]}
            end
            setting.initGridX = g2.gridPosX+dir[1]
            setting.initGridY = g2.gridPosY+dir[2]
        end
        self.buyingBuild = Build.create(bid, self, setting)
        if isContinue then
            self.buyingBuild.lastBuild = params
        end
        if bid==GuideLogic.guideBid then
            GuideLogic.backupBid = bid
            GuideLogic.clearPointer()
        end
    elseif eventType == EventManager.eventType.EVENT_BUY_SOLDIER then
        local soldier
        if UserData.noPerson then return end
        local level
        if self.sceneType==SceneTypes.Operation then
            level = UserData.researchLevel[params.sid]
        else
            level = self.researchLevel[params.sid]
        end
            if params.sid<=10 then
                soldier = SoldierHelper.create(params.sid, {arround=params.to, level=level})
            else
                soldier = Zombie.new(params.sid, {arround=params.to})
            end
        if params.from then
        --[[
            if params.sid<=10 then
                soldier = SoldierHelper.create(params.sid, {level=level})
            else
                soldier = Zombie.new(params.sid, {})
            end
            soldier.moveArround = params.to
            --]]
            --soldier:addToScene(self, {params.from.buildView.view:getPosition()})
            table.insert(params.from.waitList, soldier)
        else
            table.insert(self.asynSoldiers, soldier)
            --soldier:addToScene(self)
        end
        table.insert(params.to.soldiers,soldier)
    elseif eventType == EventManager.eventType.EVENT_GUIDE_STEP then
        if params[1]=="build" then
            local bid = params[2]
            for _, build in pairs(self.builds) do
                if build.buildData.bid == bid then
                    local pt = GuideLogic.addPointer(0)
                    local bview = build.buildView.view
                    pt:setPosition(bview:getContentSize().width/2, build:getBuildY())
                    build.buildView.uiview:addChild(pt, 100)
                    
                    self:runScaleAndMoveToCenterAction(0.5, bview:getPositionX(), bview:getPositionY()+bview:getContentSize().height/2)
                    break
                end
            end
        end
    elseif eventType==EventManager.eventType.EVENT_VISIT_USER then
        if not self.visitUid then
            self.visitUid = params
            network.httpRequest("getData", self.visitUser, {params={uid=params}}, self)
        end
    end
end

function OperationScene:visitUser(isSuc, result)
    if isSuc then
        local data = json.decode(result)
        self:updateLogic(30)
        local scene = VisitScene.new()
        scene.initInfo = data
        display.pushScene(scene, PreBattleScene)
    end
    self.visitUid = nil
end

function OperationScene:checkCanBuild()
    if not GuideLogic.complete then return end
    local checkList = {{1000, 1001, 1002}, {2000, 2001, 2002, 2003, 2005, 0}, {3000, 3001, 3002, 3003, 3004, 3005, 3006, 3007}}
    local num = {0, 0, 0}
    for i=1, 3 do
        local bids = checkList[i]
        for j=1, #bids do
            local bid = bids[j]
            local canBuild = StaticData.getBuildInfo(bid).levelLimits[UserData.level]-Build.getBuildNum(bid)
            if canBuild>0 then
                num[i] = num[i]+canBuild
            end
        end
    end
    UserData.canBuild = num
    if num[1]+num[2]+num[3]>0 then
        EventManager.sendMessage("EVENT_NOTICE_BUTTON", {name="shop", isShow=true})
    end
end

VisitScene = class(OperationScene)

function VisitScene:ctor()
    self.sceneType = SceneTypes.Visit
    self.monitorEvents = {}
    self.music = "music/operation.mp3"
end

function VisitScene:initMenu()
    local menu = VisitMenuLayer.new(self)
    self.view:addChild(menu.view)
    self.menu = menu
end

function VisitScene:initData()
    local initInfo = self.initInfo
    self.researchLevel = initInfo.researches
    
    SoldierLogic.init()
    SoldierLogic.isInit = true
    --SoldierLogic.updateSoldierList()
    self:initBuilds(initInfo)
end

function VisitScene:updateLogic()
end

BattleScene = class(CastleScene)

function BattleScene:ctor()
    self.sceneType = SceneTypes.Battle
    self.monitorEvents = {"EVENT_RESOURCE_STOLEN"}
    self.music = "music/beforeBattle.mp3"
    self.initScale = 2
    self.buffer = {}
    self.isFighting = true
end

function BattleScene:initMenu()
    local menu 
    menu = BattleMenuLayer.new(self)
    self.view:addChild(menu.view)
    self.menu = menu
end

function BattleScene:initData()
    local initInfo = self.initInfo
    BattleLogic.init()
    BattleLogic.computeScore(initInfo.score)
    self:initBuilds(initInfo)

    self.mapGridView:setColor(ccc3(255, 0, 0))

    --初始化战斗路径
    --self.mapWorld:initPath()
end

function BattleScene:singleTouchEnd()
    if self.stateInfo.touchPoint then
        self.menu:executeSelectItem(self.stateInfo.touchPoint)
    end
end

function BattleScene:updateLogic(diff)
end

function BattleScene:onTouchHold()
    local state = self.stateInfo
    if (self.touchType=="none" or self.touchType=="soldier") and state.touchPoint then
        if self.menu:executeSelectItem(state.touchPoints[state.touchIds[1]]) then
            state.touchTime = timer.getTime()+0.15
            self.touchType = "soldier"
        else
            self.touchType = "scene"
        end
    end
end

function BattleScene:eventHandler(eventType, params)
    if eventType==EventManager.eventType.EVENT_RESOURCE_STOLEN then
        local type = params.type
        local num = squeeze(params.num/100, 1, 20)
	    local bitem = self.buffer[params.buildId]
        if bitem and bitem[type] then
            if bitem[type][1]>timer.getTime() then
                bitem[type][2] = bitem[type][2]+params.num
                return
            else
                num = squeeze(bitem[type][2]/50, 1, 20)
            end
        end
        local build = self.builds[params.buildId]
        local x, y = build.buildView.view:getPosition()
        y = y + build.buildView.view:getContentSize().height*3/4
	    music.playCleverEffect("music/" .. type .. "Collect.mp3")
	    local bv = {timer.getTime()+1, params.num}
	    if not bitem then
	        self.buffer[params.buildId] = {[type]=bv}
	    else
	        bitem[type] = bv
	    end
        if type=="oil" then
            local temp = UI.createWaterSplashEffect(num)
        	screen.autoSuitable(temp.view, {x=x, y=y})
        	self.ground:addChild(temp.view, self.SIZEY)
        	delayRemove(1.5, temp.view)
        elseif type=="food" then
        	local temp = UI.createFoodSplashEffect(num)
        	screen.autoSuitable(temp.view, {x=x, y=y})
        	self.ground:addChild(temp.view, self.SIZEY)
        	delayRemove(1.5, temp.view)
        end
        if build.setResourceState and not build.deleted then
            local state = squeeze(math.floor(params.leftResource/build.resourceMax*100/24), 0, 4)
            if state~=build.resourceState then
                build.resourceState = state
                build:setResourceState(state)
            end
        end
    end
end

ZombieScene = class(CastleScene)

function ZombieScene:ctor()
    self.isFighting = true
    self.monitorEvents = {}
    self.sceneType=SceneTypes.Zombie
    self.initScale = 1
    ZombieLogic.init()
    self.music = "music/zombie.mp3"
end

function ZombieScene:initFogs()
    local temp, bg = nil
    bg = self.sky
    temp = UI.createSpriteWithFile("images/zombieFog.png")
    temp:setScale(16)
    screen.autoSuitable(temp, {x=0, y=0})
    bg:addChild(temp)
end

function ZombieScene:initMenu()
    local menu = ZombieMenuLayer.new(self)
    self.view:addChild(menu.view)
    self.menu = menu
end

function ZombieScene:singleTouchEnd()
    if self.focusBuild and not self.buyingBuild then
        self.focusBuild:releaseFocus()
    end
end

function ZombieScene:updateLogic(diff)
end

function ZombieScene:eventHandler(eventType, params)
end

ReplayScene = class(CastleScene)

function ReplayScene:ctor(menuParam)
    self.monitorEvents = {}
    self.isReplay = true
    if ReplayLogic.isZombie then
        self.sceneType = SceneTypes.Zombie
        ZombieLogic.init()
        ZombieLogic.battleEnd = nil
        
        ReplayLogic.loadReplayResult("zombie.txt")
    else
    	BattleLogic.init()
        self.sceneType = SceneTypes.Battle
        BattleLogic.battleEnd = nil
        ReplayLogic.battleTime = ReplayLogic.cmdList[#(ReplayLogic.cmdList)][1]
    end
    self.initInfo = ReplayLogic.buildData
    self.pause = true
    self.menuParam = menuParam
    self.time = 0
    self.cmdTime = nil
    self.battleTime = ReplayLogic.battleTime
    self.cmdList = ReplayLogic.cmdList
    self.cmdNum = #(self.cmdList)
    self.cmdIndex = 0
    self.battleBegin = false
    self.isFighting = true
    math.randomseed(ReplayLogic.randomSeed) 
end

function ReplayScene:reloadScene(menuParam)
    display.runScene(ReplayScene.new(menuParam), PreBattleScene)
end

function ReplayScene:eventHandler()

    --记录所有bid 到buildView 的映射关系
    self.bidToBuildView = {}
    self.newWorld = nil
    self.isFighting = nil
end

function ReplayScene:initMenu()
    local menu = ReplayMenuLayer.new(self, self.menuParam)
    self.view:addChild(menu.view)
    self.menu = menu
    self.mapGridView.view:setVisible(false)
end

function ReplayScene:updateLogic(diff)
    if not self.pause then
        self.time = (self.time or 0)+ diff
        while not self.cmdTime or self.time>self.cmdTime do
            if self.cmdTime then
                if not self.battleBegin then
                    self.battleBegin = true
                end
                if self.cmd[2]=="s" then
                    local soldier = SoldierHelper.create(self.cmd[3], {isFighting=true, level=self.cmd[6]})
                    soldier:addToScene(self, {self.cmd[4], self.cmd[5]})
                    table.insert(self.soldiers, soldier)
                elseif self.cmd[2]=="z" then
                    local zombie = Zombie.new(self.cmd[3]+10, {isFighting=true})
                    zombie:addToScene(self, {self.cmd[4], self.cmd[5]})
                    table.insert(self.soldiers, zombie)
                elseif self.cmd[2]=="zb" then
                    local zombieTomb = ZombieTomb.new(1004, {level=self.cmd[5]})
    			    zombieTomb:addToScene(self, {initGridX=self.cmd[3], initGridY=self.cmd[4]})
    			    --add action here
    			    local b = zombieTomb.buildView.build
    			    local height=getParam("actionTombHeight", 104)
    			    b:setPositionY(height+28)
    			    b:runAction(CCEaseBackIn:create(CCMoveBy:create(0.4, CCPointMake(0, -height))))
                elseif self.cmd[2]=="r" then
                    self.builds[self.cmd[3]]:repair()
                elseif self.cmd[2]=="c" then
                    self.builds[self.cmd[3]]:cancelRepair()
                elseif self.cmd[2]=="e" then
                    if self.sceneType==SceneTypes.Zombie then
                        ZombieLogic.battleEnd = true
                    else
                        BattleLogic.battleEnd = true
                    end
                    self.pause = true
                    self.menu:endReplay()
                    break
                end
                self.cmdTime = nil
            end
            self.cmdIndex = self.cmdIndex + 1
            self.cmd = self.cmdList[self.cmdIndex]
            self.cmdTime = self.cmd[1]
        end
    end
end