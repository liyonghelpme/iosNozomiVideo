Farm = {}
do
	Farm.addBuildFunctions = function(retBuild, scene)
		
		retBuild.createInfoMenu = function()
			local temp, bg = nil
			bg = UI.createSpriteWithFile("images/buildMenu1.png",CCSizeMake(960, 73))
			temp = UI.createTTFLabel(StringManager.getFormatString("farmInfoStr", retBuild.getGoods()), General.defaultFont, 24, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=38, y=33, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
			local width = temp:getContentSize().width
			local timeLabel = UI.createTTFLabel(StringManager.getTimeString(retBuild.leftTime), General.defaultFont, 24, {colorR = 224, colorG = 194, colorB = 45})
			screen.autoSuitable(timeLabel, {x=38 + width, y=33, nodeAnchor=General.anchorLeft})
			bg:addChild(timeLabel)
			local function update()
				if retBuild.leftTime then
					timeLabel:setString(StringManager.getTimeString(retBuild.leftTime))
				else
					timeLabel:setString("---")
				end
			end
			simpleRegisterEvent(bg, {update = {callback = update, inteval = 0.5}})
			return bg
		end
		
		retBuild.beginplant = function(isTouch, node, param)
			if not isTouch then return end
			local info = param.info
			retBuild.leftTime = info.time
			retBuild.allTime = info.time
			retBuild.state = Build.STATE_WORKING
			retBuild.plantInfo = info
			retBuild.plantstage = 0
			local plant = UI.createSpriteWithFile("images/plants/p0.png")
			screen.autoSuitable(plant, {x=0, y=0})
			retBuild.view:addChild(plant)
			retBuild.plant = plant
			param.close()
		end
		
		local function completeGetPlant()
			retBuild.state = Build.STATE_FREE
			local info = retBuild.plantInfo
			retBuild.plantInfo = nil
			retBuild.leftTime = nil
			retBuild.allTime = nil
			retBuild.plantstage = nil
			retBuild.plant:removeFromParentAndCleanup(true)
			retBuild.plant = nil
			
			EventManager.sendMessage("EVENT_PICKFLY", {gain={silver=info.silver, exp=info.exp}, obj=retBuild.flyNode})
			if retBuild.flyNode then
				retBuild.flyNode:removeFromParentAndCleanup(true)
				retBuild.flyNode = nil
			end
			retBuild.flyNodeTouched = nil
			UserData.changeValue("silver", info.silver)
			UserData.changeValue("exp", info.exp)
		end
		
		local function update(diff)
			if retBuild.state == Build.STATE_WORKING then
				if retBuild.leftTime>0 then
					retBuild.leftTime = retBuild.leftTime - diff
					local pstage = math.floor(2*(retBuild.allTime-retBuild.leftTime)/retBuild.allTime)
					if pstage~=retBuild.plantstage then
						retBuild.plantstage = pstage
						retBuild.plant:removeFromParentAndCleanup(true)
						local plant = nil
						if pstage == 1 then
							plant = UI.createSpriteWithFile("images/plants/p" .. retBuild.plantInfo.id .. "_2.png")
						elseif pstate==2 then
							plant = UI.createSpriteWithFile("images/plants/p" .. retBuild.plantInfo.id .. "_3.png")
						end
						screen.autoSuitable(plant, {x=0, y=0})
						retBuild.plant = plant
						retBuild.view:addChild(plant)
					end
				elseif not retBuild.flyNode then
					
					local flyNode = UI.createSpriteWithFile("images/flowBanner.png")
					local size = retBuild.view:getContentSize()
					screen.autoSuitable(flyNode, {x=size.width/2, y=size.height - 10, nodeAnchor=General.anchorBottom})
					retBuild.view:addChild(flyNode, 3)
					flyNode:runAction(Action.createVibration(getParam("flyNodeTime")/1000, 0, getParam("flyMove")))
					retBuild.flyNodeTouched = completeGetPlant
					
					local temp = UI.createSpriteWithFile("images/plants/Wplant" .. retBuild.plantInfo.id .. ".png", CCSizeMake(43, 40))
					screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=34, y=34})
					flyNode:addChild(temp)
					retBuild.flyNode = flyNode
				end
			end
		end
		local function onAcc()
			if UserData.checkAndCost({costType="gold", gold=10, noticeType=UserConst.COST_ACC}) then
				retBuild.leftTime = 0
				update(0)
				scene.releaseFocus()
			end
		end
		
		local function readyToAcc()
			if retBuild.leftTime > 0 then
				local cost = 10
				display.pushNotice(UI.createNoticeType2(StringManager.getFormatString("accNotice", {gold=cost}), StringManager.getString("ok"), onAcc), true)
			end
		end
		
		retBuild.getRightButtons = function()
			return {{button="sell", callback=retBuild.sell}, {button="acc", callback=readyToAcc}}
		end
		
	end
	local function updatePlantsCell(bg, info)
		bg:removeAllChildrenWithCleanup(true)
		local temp = nil
		temp = UI.createSpriteWithFile("images/plantPanel.png",CCSizeMake(218, 100))
		screen.autoSuitable(temp, {x=0, y=0})
		bg:addChild(temp)
		temp = UI.createScaleSprite("images/plants/Wplant" .. info.id .. ".png", CCSizeMake(85, 78))
		screen.autoSuitable(temp, {x=170, y=50, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/exp.png",CCSizeMake(30, 30))
		screen.autoSuitable(temp, {x=10, y=63})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/silver.png",CCSizeMake(30, 30))
		screen.autoSuitable(temp, {x=11, y=32})
		bg:addChild(temp)
		temp = UI.createTTFLabel(StringManager.getTimeString(info.time), General.defaultFont, 24, {colorR=0, colorG=0, colorB=0})
		screen.autoSuitable(temp, {x=60, y=15, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createTTFLabel("" .. info.exp, General.defaultFont, 24, {colorR=0, colorG=0, colorB=0})
		screen.autoSuitable(temp, {x=48, y=79, nodeAnchor=General.anchorLeft})
		bg:addChild(temp)
		temp = UI.createTTFLabel("" .. info.silver, General.defaultFont, 24, {colorR=0, colorG=0, colorB=0})
		screen.autoSuitable(temp, {x=48, y=45, nodeAnchor=General.anchorLeft})
		bg:addChild(temp)
		if UserData.level < info.needLevel then
			temp = UI.createSpriteWithFile("images/dialogFriendShadow.png",CCSizeMake(230, 106))
			screen.autoSuitable(temp, {x=-6, y=-3})
			bg:addChild(temp)
			temp = UI.createTTFLabel(StringManager.getFormatString("needLevel", {level = info.needLevel}), General.defaultFont, 28, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=46, y=51, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
		end
	end
	local function createPlantsDialog(farmBuild)
		local infos = {{id=1, needLevel=1, silver=100, exp=100, time=100},{id=2, needLevel=1, silver=200, exp=200, time=1000},
		{id=3, needLevel=1, silver=300, exp=300, time=2000},{id=4, needLevel=1, silver=400, exp=400, time=3000},{id=5, needLevel=5, silver=500, exp=500, time=4000},
		{id=6, needLevel=6, silver=600, exp=600, time=5000},{id=7, needLevel=7, silver=700, exp=700, time=6000}
		}
		
		local layer = UI.createButton(General.winSize, doNothing, {priority = display.DARK_PRI, nodeChangeHandler=doNothing})

		local temp, bg = nil
		bg = UI.createSpriteWithFile("images/plantChoice.png",CCSizeMake(399, 595))
		screen.autoSuitable(bg, {screenAnchor=General.anchorRightTop, x=0, y=595})
		bg:runAction(CCEaseExponentialOut:create(CCMoveBy:create(0.5, CCPointMake(0, -576))))
		local function closePlantsDialog()
			bg:runAction(CCEaseExponentialOut:create(CCMoveBy:create(0.6, CCPointMake(0, 634))))
			delayRemove(0.6, layer)
		end
		layer:addChild(bg)
		
		temp = UI.createButton(CCSizeMake(72, 74), closePlantsDialog, {image = "images/plantBack.png", priority=display.DIALOG_BUTTON_PRI, nodeChangeHandler = doNothing})
		screen.autoSuitable(temp, {x=2, y=391})
		bg:addChild(temp)
		local scrollView = UI.createScrollView(CCSizeMake(219, 437), false, 112)
		for i=1, #infos do
			local cell = CCNode:create()
			cell:setContentSize(CCSizeMake(218, 100))
			updatePlantsCell(cell, infos[i])
			scrollView.addItem(cell, {offx=1, offy=0, disy = 12, index = i, touchCallback=farmBuild.beginplant, touchParam={info=infos[i], close=closePlantsDialog}})
		end
		scrollView.prepare()
		screen.autoSuitable(scrollView.view, {x=106, y=29})
		bg:addChild(scrollView.view)
		temp = UI.createSpriteWithFile("images/plantShadow.png",CCSizeMake(219, 437))
		screen.autoSuitable(temp, {x=106, y=29})
		bg:addChild(temp)
		return layer
	end
	Farm.createPlantsDialog = createPlantsDialog
end