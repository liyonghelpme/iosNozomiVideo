GuideLogic = {step=0, num=0}

function GuideLogic.init(guideStep, num, scene)
	GuideLogic.step = guideStep
	GuideLogic.num = num
	if scene then
	    GuideLogic.scene = scene
	    GuideLogic.pointer = nil
	    if guideStep<10 then
	        UserSetting.setValue("nozomiNewspaper", 1)
	        UserSetting.setValue("nozomiVideo", 0)
	    end
	end
	if (num and num>0 or guideStep>13) then
		GuideLogic.checkGuide()
	else
	    GuideLogic.animateStep = 0
	    if guideStep==1 then
	        GuideLogic.showStory()
	    else
    		GuideLogic.nextAnimate()
    	end
	end
end

function GuideLogic.releaseAll()
    GuideLogic.step = nil
    GuideLogic.num = nil
	GuideLogic.scene = nil
	GuideLogic.pointer = nil
	GuideLogic.animateStep = nil
	GuideLogic.guideBid = nil
	GuideLogic.backupBid = nil
	GuideLogic.menuType = nil
	GuideLogic.view = nil
	GuideLogic.bnode = nil
	if GuideLogic.monitorId then
		EventManager.removeEventMonitor(GuideLogic.monitorId)
		GuideLogic.monitorId = nil
	end
end

local GuideInfo = 
{{"BuildNum", 3000, 2}, {"zombie", 1}, {"BuildNum", 2004, 2}, {"BuildLevel", 2003, 1}, {"collect", 1}, {"BuildLevel", 2000, 1}, {"BuildLevel", 2001, 1}, {"BuildLevel", 0, 1}, {"BuildLevel", 1001, 1}, {"Soldier", 1}, {"battle", 1}, {"BuildLevel", 1, 2}}

local GuideShowTypes = {{{2, 1}, {3,2}, {1,3}}, {}, {{2,4},{2,5}}, {{2,6}}, {{2,7}}, {{2,8}}, {{2,9}}, {{2,10}}, {{2,11}}, {}, {}, {{2,12}}, {{2,13}}}

function GuideLogic.checkBuild(bid, level)
    local info = GuideInfo[GuideLogic.step]
	if bid==info[2] then
	    if info[1]=="BuildLevel" and level>=info[3] then
    		GuideLogic.num = 1
    		GuideLogic.completeStep()
    		return true
    	elseif info[1]=="BuildNum" then
    	    GuideLogic.num = GuideLogic.num+1
    	    if GuideLogic.num>=info[3] then
        		GuideLogic.completeStep()
        		return true
    	    end
    	end
	end
end

function GuideLogic.completeStep()
    GuideLogic.clearPointer()
    GuideLogic.guideBid = nil
    GuideLogic.backupBid = nil
    GuideLogic.menuType = nil
	if GuideLogic.monitorId then
		EventManager.removeEventMonitor(GuideLogic.monitorId)
		GuideLogic.monitorId = nil
	end
	if GuideLogic.scene.menu then
    	GuideLogic.scene.menu.guideBid=nil
    end
	GuideLogic.init(GuideLogic.step+1)
end

function GuideLogic.checkGuide()
	local info = GuideInfo[GuideLogic.step]
	if not info then
		GuideLogic.complete = (GuideLogic.step>=14)
    	if GuideLogic.view then
    	    GuideLogic.bnode:removeFromParentAndCleanup(true)
    	    GuideLogic.bnode = nil
    	    GuideLogic.view:removeFromParentAndCleanup(true)
    	    GuideLogic.view = nil
    	end
		return true
	end
	if not GuideLogic.num then
		GuideLogic.num = 0
	end
	if info[1]=="BuildLevel" or info[1]=="BuildNum" then
		local scene = GuideLogic.scene
		GuideLogic.num = 0
		if scene.builds then
    		for _, build in pairs(scene.builds) do
    			local bid = build.buildData.bid
    			local level = build.buildLevel
    			if GuideLogic.checkBuild(bid, level) then
    				return true
    			end
    		end
        end
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_BUILD_UPDATE"}, GuideLogic.eventHandler)
		GuideLogic.guideBid = info[2]
		if info[3]==1 or info[1]=="BuildNum" then
    		EventManager.sendMessage("EVENT_GUIDE_STEP", {"menu", "shop", info[2]})
		    GuideLogic.menuType = "shop"
		else
		    EventManager.sendMessage("EVENT_GUIDE_STEP", {"build", info[2]})
    	end
	elseif GuideLogic.num>=info[2] then
		GuideLogic.completeStep()
		return true
	end
	if info[1]=="Soldier" then
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_BUY_SOLDIER"}, GuideLogic.eventHandler)
		EventManager.sendMessage("EVENT_GUIDE_STEP", {"build", 1001})
		GuideLogic.isTrainGuide = true
	elseif info[1]=="battle" then
	    BattleLogic.isGuide = 1
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_BATTLE_END"}, GuideLogic.eventHandler)
		EventManager.sendMessage("EVENT_GUIDE_STEP", {"menu", "attack"})
		GuideLogic.menuType = "attack"
	elseif info[1]=="zombie" then
	    ZombieLogic.isGuide = true
	    display.showDialog(ZombieDialog, false)
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_OTHER_OPERATION"}, GuideLogic.eventHandler)
	elseif info[1]=="collect" then
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_OTHER_OPERATION"}, GuideLogic.eventHandler)
		EventManager.sendMessage("EVENT_GUIDE_STEP", {"build", 2002})
	end
	if GuideLogic.view then
	    GuideLogic.bnode:removeFromParentAndCleanup(true)
	    GuideLogic.bnode = nil
	    GuideLogic.view:removeFromParentAndCleanup(true)
	    GuideLogic.view = nil
	end
end

function GuideLogic.eventHandler(eventType, param)
	if eventType == EventManager.eventType.EVENT_BUILD_UPDATE then
		local bid=param.bid 
		local level = param.level
		GuideLogic.checkBuild(bid, level)
	elseif eventType == EventManager.eventType.EVENT_OTHER_OPERATION then
		local key = param.key
		if key==GuideInfo[GuideLogic.step][1] then
			GuideLogic.completeStep()
		end
	elseif eventType == EventManager.eventType.EVENT_BUY_SOLDIER then
		GuideLogic.num = GuideLogic.num + 1
		if GuideLogic.num>=GuideInfo[GuideLogic.step][2] then
			GuideLogic.completeStep()
			GuideLogic.isTrainGuide = false
		end
	elseif eventType == EventManager.eventType.EVENT_BATTLE_END then
		UserData.shieldTime = timer.getTime()+3*86400
		BattleLogic.isGuide = nil
		
		GuideLogic.completeStep()
	end
end

local SHOW_SETTING={[1]=1, [2]=3}

function GuideLogic.showStory()
    local bg = CCTouchLayer:create(display.DIALOG_PRI, true)
    bg:setContentSize(General.winSize)
    bg:registerScriptTouchHandler(GuideLogic.touch)
    local temp = CCLayerColor:create(ccc4(0, 0, 0, General.darkAlpha), General.winSize.width, General.winSize.height)
    bg:addChild(temp)
	local action = UI.createSpriteWithFile("images/newspaper.png")
	temp = UI.createSpriteWithFile("images/newspaperGuide2.png",CCSizeMake(389, 241))
    screen.autoSuitable(temp, {x=191, y=30})
    action:addChild(temp)
    temp = UI.createSpriteWithFile("images/newspaperGuide1.png",CCSizeMake(284, 224))
    screen.autoSuitable(temp, {x=52, y=320})
    action:addChild(temp)
    temp = UI.createLabel(StringManager.getString("guideTextNewspaper1"), General.font1, NEWSPAPER_TITLE_SIZE-3, {colorR = 0, colorG = 0, colorB = 0})
    screen.autoSuitable(temp, {x=57, y=287, nodeAnchor=General.anchorLeft})
    action:addChild(temp)
    temp = UI.createLabel(StringManager.getString("guideTextNewspaper2"), General.font1, NEWSPAPER_TITLE_SIZE, {colorR = 0, colorG = 0, colorB = 0})
    screen.autoSuitable(temp, {x=56, y=572, nodeAnchor=General.anchorLeft})
    action:addChild(temp)
	GuideLogic.bnode = action
	action:setScale(0)
	local scale = screen.getScalePolicy()[screen.SCALE_HEIGHT_FIRST]
	local t=getParam("actionTimeNewspaper", 800)/1000
	delayCallback(1, music.playEffect, "music/newspaper.mp3")
	action:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCSpawn:createWithTwoActions(CCScaleTo:create(t, scale, scale), CCRotateBy:create(t, getParam("actionTimeRotation", 1080)))))
	screen.autoSuitable(action, {screenAnchor=General.anchorCenter})
	bg:addChild(action)
	--simpleRegisterEvent(bg, {touch={callback=GuideLogic.touch, multi=false, priority=display.DIALOG_BUTTON_PRI, swallow=true}})
	GuideLogic.view = bg
	GuideLogic.touchTime = timer.getTime()+t+3
    
	GuideLogic.scene.view:addChild(bg, 10)
	
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/newspaper.png")
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/newspaperGuide2.png")
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/newspaperGuide1.png")
end

function GuideLogic.nextAnimate(isDelay)
	local scene = display.getCurrentScene()
	if display.isSceneChange or display.isDialogShow() or (scene~=GuideLogic.scene) then
		delayCallback(1, GuideLogic.nextAnimate, true)
		return
	else
	    if GuideLogic.scene.focusBuild then
	        GuideLogic.scene.focusBuild:releaseFocus()
	    end
	    if isDelay then
	        GuideLogic.clearPointer()
	    end
	end
	
    local aniStep = (GuideLogic.animateStep or 0)+1
    local showType = GuideShowTypes[GuideLogic.step]
    if showType then showType=showType[aniStep] end
    if not showType then
        return GuideLogic.checkGuide()
    end
    GuideLogic.animateStep = aniStep
    if not GuideLogic.view then
	    local bg = CCTouchLayer:create(display.DIALOG_PRI, true)
        bg:setContentSize(General.winSize)
        bg:registerScriptTouchHandler(GuideLogic.touch)
        local temp = CCLayerColor:create(ccc4(0, 0, 0, General.darkAlpha), General.winSize.width, General.winSize.height)
        bg:addChild(temp)
	    GuideLogic.scene.view:addChild(bg, 10)
        GuideLogic.view = bg
        GuideLogic.showType = nil
    end
    if GuideLogic.showType~=showType[1] then
        if GuideLogic.bnode then
            GuideLogic.bnode:removeFromParentAndCleanup(true)
        end
        local bnode = CCNode:create()
        local temp, label
        GuideLogic.view:addChild(bnode)
        GuideLogic.showType=showType[1]
        if showType[1]<3 then
    		screen.autoSuitable(bnode, {scaleType=screen.SCALE_NORMAL})
    		
    		temp = UI.createSpriteWithFile("images/guideNpcBack.png",CCSizeMake(557, 151))
    		screen.autoSuitable(temp, {x=-3, y=-8})
    		bnode:addChild(temp)
    		
    		if showType[1]==1 then
    			temp = UI.createSpriteWithFile("images/guideNpc1.png",CCSizeMake(249, 371))
    			screen.autoSuitable(temp, {x=1024, y=35})
    			bnode:addChild(temp)
    			temp:runAction(CCEaseBackOut:create(CCMoveTo:create(0.5, CCPointMake(68, 35))))
    			
	            music.playEffect("music/npc1.mp3")
    		else
    			temp = UI.createSpriteWithFile("images/guideNpc2.png",CCSizeMake(229, 393))
    			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=203, y=22})
    			bnode:addChild(temp)
    			temp:setScaleY(0)
    			temp:runAction(CCEaseBackOut:create(CCScaleTo:create(0.5, 1, 1)))
	            music.playEffect("music/npc2.mp3")
    		end
    		
    		temp = UI.createSpriteWithFile("images/guideChatBackA.png",CCSizeMake(336, 114))
    		screen.autoSuitable(temp, {x=274, y=235, nodeAnchor=General.anchorLeft})
    		bnode:addChild(temp)
    		label = UI.createLabel("", General.font1, 18, {colorR = 0, colorG = 0, colorB = 0, size=CCSizeMake(260, 114)})
    		screen.autoSuitable(label, {x=58, y=53, nodeAnchor=General.anchorLeft})
    		temp:addChild(label)
    		temp:setScaleX(0)
    		local array = CCArray:create()
    		array:addObject(CCDelayTime:create(0.5))
    		array:addObject(CCScaleTo:create(0.25, 1, 1))
    		temp:runAction(CCSequence:create(array))
    	else
    		screen.autoSuitable(bnode, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorRightBottom})
    		
    		temp = UI.createSpriteWithFile("images/guideZombieBack.png",CCSizeMake(565, 379))
    		screen.autoSuitable(temp, {x=-538, y=-15})
    		bnode:addChild(temp)
    		temp = UI.createSpriteWithFile("images/zombieFeature.png",CCSizeMake(346, 403))
    		screen.autoSuitable(temp, {x=0, y=19})
    		bnode:addChild(temp)
    		temp:runAction(CCEaseBackOut:create(CCMoveTo:create(0.5, CCPointMake(-481, 19))))
    		temp = UI.createSpriteWithFile("images/guideChatBackA.png",CCSizeMake(336, 114))
    		screen.autoSuitable(temp, {x=-407, y=171, nodeAnchor=General.anchorRight})
    		bnode:addChild(temp)
    		temp:setFlipX(true)
	        music.playEffect("music/appear11.mp3")
    		label = UI.createLabel("", General.font1, 18, {colorR = 0, colorG = 0, colorB = 0, size=CCSizeMake(260, 114)})
    		screen.autoSuitable(label, {x=18, y=51, nodeAnchor=General.anchorLeft})
    		temp:addChild(label)
    		temp:setScaleX(0)
    		local array = CCArray:create()
    		array:addObject(CCDelayTime:create(0.5))
    		array:addObject(CCScaleTo:create(0.25, 1, 1))
    		temp:runAction(CCSequence:create(array))
    	end
    	GuideLogic.bnode = bnode
    	GuideLogic.label = label
    	delayCallback(0.5, music.playEffect, "music/guideLabel.mp3")
    end
    --local text = string.gsub(StringManager.getString("guideText" .. showType[2]), "'", "’")
    local text = StringManager.getString("guideText" .. showType[2])
    GuideLogic.label:setString(text)
	GuideLogic.touchTime = timer.getTime()+1
	
    if GuideLogic.step==#GuideShowTypes then
        EventManager.sendMessage("EVENT_GUIDE_STEP", {"menu", "achieve"})
    end
	return true
end

function GuideLogic.touch(eventType, id, x, y)
	-- TEST
	if eventType==CCTOUCHBEGAN then
    	if GuideLogic.touchTime and GuideLogic.touchTime>timer.getTime() then
    	    return true
    	end
    	if GuideLogic.view then
    	    return GuideLogic.nextAnimate()
    	end
    	return true
	end
end

function GuideLogic.addPointer(angle)
	GuideLogic.clearPointer()
	GuideLogic.pointer = UI.createGuidePointer(angle)
	GuideLogic.pointer:retain()
	return GuideLogic.pointer
end

function GuideLogic.clearPointer()
    if display.getCurrentScene()~= GuideLogic.scene then
		GuideLogic.pointer = nil
        return
    end
	if GuideLogic.pointer then
		GuideLogic.pointer:removeFromParentAndCleanup(true)
	    GuideLogic.pointer:release()
		GuideLogic.pointer = nil
	end
end