PreBattleScene = class(NormalChangeDelegate)

function PreBattleScene:ctor(fromScene, toScene)
    --如果是战斗场景且没有数据，则请求服务器
    if toScene.sceneType==SceneTypes.Battle and not toScene.initInfo then
    	network.httpRequest("findEnemy", self.findOver, {params={baseScore=UserData.userScore, uid=UserData.userId, eid=UserData.enemyId, isGuide=BattleLogic.isGuide}}, self)
    	UserData.enemyId = nil
    end
end

function PreBattleScene:exitAnimate()
    if self.showPrepareView then
        self.showPrepareView:removeFromParentAndCleanup(true)
        self.showPrepareView = nil
    end
	local pz = {{0, 256}, {342, 0}, {0, 0}, {0, 512}, {684, 0}}
	local epz = {{530, 704}, {900, 386}, {800, 600}, {285, 840}, {1140, 280}}
	
	local a1, a2, b, c = 0, 0.18, 1.08, 0.16 
	--0.98, 0.14
	
	local batch = CCSpriteBatchNode:create("images/fog.png")
	batch:setContentSize(CCSizeMake(1024, 768))
	local t = getParam("actionTimeChangeScene", 600)/1000
	--[[
	if not isIn then
		pz, epz = epz, pz
		a1, a2 = 0.16, 0.04
		t = t*2.5
	end
	--]]
	local fogs = {}
	for i=1, 5 do
		local temp, array
		
		temp = CCSprite:create("images/fog.png")
		temp:setScale(4)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorRightTop, x=pz[i][1], y=pz[i][2]})
		batch:addChild(temp, i*2)
		array = CCArray:create()
		array:addObject(CCDelayTime:create(t*(a1+a2*(i-1))))
		array:addObject(CCMoveTo:create(t*(b-c*i), CCPointMake(epz[i][1], epz[i][2])))
		temp:runAction(CCSequence:create(array))
		fogs[i*2-1] = temp
		
		temp = CCSprite:create("images/fog.png")
		temp:setScale(4)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, x=1024-pz[i][1], y=768-pz[i][2]})
		batch:addChild(temp, i*2+1)
		array = CCArray:create()
		array:addObject(CCDelayTime:create(t*(a1+a2*(i-1))))
		array:addObject(CCMoveTo:create(t*(b-c*i), CCPointMake(1024-epz[i][1], 768-epz[i][2])))
		temp:runAction(CCSequence:create(array))
		fogs[i*2] = temp
	end
	self.fogs = fogs
	screen.autoSuitable(batch, {screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(batch)
	self.animateTime = timer.getTime() + 10
	local function animateOver()
	    self.animateTime = 0
	end
	self.view:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(t), CCCallFunc:create(animateOver)))
end

function PreBattleScene:enterAnimate()
	local epz = {{0, 256}, {342, 0}, {0, 0}, {0, 512}, {684, 0}}
	local pz = {{530, 704}, {900, 386}, {800, 600}, {285, 840}, {1140, 280}}
	
	local a1, a2, b, c = 0.16, 0.04, 1.08, 0.16 
	--0.98, 0.14
	local t = getParam("actionTimeChangeScene", 600)/1000 *2.5
	for i=1, 5 do
		local temp, array
		
		temp = self.fogs[i*2-1]
		array = CCArray:create()
		array:addObject(CCDelayTime:create(t*(a1+a2*(i-1))))
		array:addObject(CCMoveTo:create(t*(b-c*i), CCPointMake(epz[i][1], epz[i][2])))
		temp:runAction(CCSequence:create(array))
		
		temp = self.fogs[i*2]
		array = CCArray:create()
		array:addObject(CCDelayTime:create(t*(a1+a2*(i-1))))
		array:addObject(CCMoveTo:create(t*(b-c*i), CCPointMake(1024-epz[i][1], 768-epz[i][2])))
		temp:runAction(CCSequence:create(array))
	end
	self.animateTime = timer.getTime() + 10
	local function animateOver()
	    self.animateTime = 0
	end
	self.view:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(t), CCCallFunc:create(animateOver)))
	
	if self.toScene.sceneType==SceneTypes.Battle then
        for i, build in pairs(self.toScene.builds) do
            if build.setResourceState and build.resourceMax then
                local state = squeeze(math.floor(BattleLogic.builds[build.id].resources[build.resourceType]*BattleLogic.k/build.resourceMax*100/24), 0, 4)
                if state~=build.resourceState then
                    build.resourceState = state
                    build:setResourceState(state)
                end
            end
        end
        local areaAlpha = getParam("buildingAreaAlpha", 38)
        local lineAlpha = getParam("buildingLineAlpha", 100)
        self.toScene.mapGridView.blockBatch:runAction(CCAlphaTo:create(0.1, areaAlpha, areaAlpha))
        self.toScene.mapGridView.linesBatch:runAction(CCAlphaTo:create(0.1, lineAlpha, lineAlpha))
    elseif self.toScene.addZombieTomb then
        self.toScene:addZombieTomb()
	end
end

function PreBattleScene:updateOthers(diff)
    if self.loadState>=7 and self.loadState<10 and self.toScene.sceneType==SceneTypes.Battle and not self.toScene.isReplay and not self.showPrepareView then
        self.showPrepareView = CCNode:create()
        self.view:addChild(self.showPrepareView)
        showPrepareView = self.showPrepareView
        local temp
        local tempPri = display.MENU_BUTTON_PRI
        display.MENU_BUTTON_PRI = display.DIALOG_BUTTON_PRI
    	temp = UI.createMenuButton(CCSizeMake(111, 109), "images/buttonChildMenu.png", self.returnHome, self, "images/menuItemAchieve.png", StringManager.getString("buttonReturnHome"), 18+NORMAL_SIZE_OFF)
    	display.MENU_BUTTON_PRI = tempPri
    	screen.autoSuitable(temp, {x=72, y=70, screenAnchor=General.anchorLeftBottom, nodeAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
    	showPrepareView:addChild(temp)
    	
    	temp = UI.createSpriteWithFile("images/findEnemyIcon.png",CCSizeMake(163, 116))
    	screen.autoSuitable(temp, {screenAnchor=General.anchorCenter, x=-30, y=0, scaleType=screen.SCALE_NORMAL})
    	showPrepareView:addChild(temp)
    	
    	local array = CCArray:create()
    	array:addObject(CCEaseSineIn:create(CCMoveBy:create(1, CCPointMake(30, 0))))
    	array:addObject(CCEaseSineOut:create(CCMoveBy:create(1, CCPointMake(30, 0))))
    	array:addObject(CCEaseSineIn:create(CCMoveBy:create(1, CCPointMake(-30, 0))))
    	array:addObject(CCEaseSineOut:create(CCMoveBy:create(1, CCPointMake(-30, 0))))
    	temp:runAction(CCRepeatForever:create(CCSequence:create(array)))
    	
    	array = CCArray:create()
    	array:addObject(CCEaseSineOut:create(CCMoveBy:create(1, CCPointMake(0, 20))))
    	array:addObject(CCEaseSineIn:create(CCMoveBy:create(1, CCPointMake(0, -20))))
    	array:addObject(CCEaseSineOut:create(CCMoveBy:create(1, CCPointMake(0, -20))))
    	array:addObject(CCEaseSineIn:create(CCMoveBy:create(1, CCPointMake(0, 20))))
    	temp:runAction(CCRepeatForever:create(CCSequence:create(array)))
    	
    	temp = UI.createLabel(StringManager.getString("labelFindEnemy"), General.font3, 25, {colorR = 255, colorG = 255, colorB = 181})
    	screen.autoSuitable(temp, {screenAnchor=General.anchorCenter, x=0, y=0, scaleType=screen.SCALE_NORMAL})
    	showPrepareView:addChild(temp)
    elseif self.showPrepareView and self.loadState>=10 then
        self.returnOver = true
    	self.showPrepareView:runAction(CCSequence:createWithTwoActions(CCAlphaTo:create(0.5, 255, 0), CCCallFuncN:create(removeSelf)))
    	self.showPrepareView = nil
    end
end

function PreBattleScene:returnHome()
    if self.returnOver then return end
	self.returnOver = true
	self.loadState = 2
	self.stepOver = true
	display.isSceneChange = false
	display.popScene(self)
	
	self.showPrepareView:runAction(CCSequence:createWithTwoActions(CCAlphaTo:create(1, 255, 0), CCCallFuncN:create(removeSelf)))
	self.showPrepareView = nil
end

function PreBattleScene:findOver(suc, result)
	if suc and not self.returnOver then
	    BattleLogic.isReverge = nil
		local data = json.decode(result)
		UserData.enemyId = data.userId
		self.toScene.initInfo = data
	end
end