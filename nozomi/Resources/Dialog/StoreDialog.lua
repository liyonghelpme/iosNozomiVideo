StoreDialog = {}

do
    local function buyShield(info)
        if CrystalLogic.changeCrystal(info.costValue) then
            local t = timer.getTime()
            if t < UserData.shieldTime then
                t = UserData.shieldTime
            end
            UserData.shieldTime = t + info.time
    		UserStat.addCrystalLog(CrystalStatType.BUY_SHIELD, timer.getTime(), info.costValue, info.time)
            --display.closeDialog()
        end
    end
    
	local function buyBuild(info)
		if info.bid then
			EventManager.sendMessage("EVENT_BUY_BUILD", info.bid)
		else
		    display.showDialog(AlertDialog.new(StringManager.getString("alertTitleBuyShield"), StringManager.getFormatString("alertTextBuyShield", {time=info.name}), {crystal=info.costValue, callback=buyShield, param=info}))
		    
			--display.closeDialog()
			--UserData.shieldTime = timer.getTime() + info.time
		end
	end
	
	local showMainTab, updateFlipCell, updateFlip = nil
	
	local function updateStoreCell(cell, scrollView, info)
		local bg, temp = cell
		bg:removeAllChildrenWithCleanup(true)
		
		temp = UI.createSpriteWithFile("images/dialogItemButtonStore.png",CCSizeMake(286, 236), true)
		screen.autoSuitable(temp, {x=0, y=0})
		bg:addChild(temp)
		local tp1 = temp
		temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png")
		screen.autoSuitable(temp, {x=143, y=118, nodeAnchor=General.anchorCenter})
		cell:addChild(temp)
		local bview = nil
		if info.bid then
			if not GuideLogic.complete then
				if info.bid==GuideLogic.guideBid then
					local pt = UI.createGuidePointer(-45)
					pt:setPosition(75, 160)
					pt:setScale(0.6)
					pt:setHueOffset(200, true)
					cell:addChild(pt, 10)
				end
			end
			
			local b = Build.create(info.bid, nil, {level=1})
			temp = b:getBuildView()
			bview = temp
			local sc = squeeze(2/b.buildData.gridSize, 0, 1)
			temp:setScale(sc)
			if b.buildData.gridSize==1 then
    			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=143, y=75+getParam("buildViewOffy" .. info.bid, 0)})
			else
			    local yoff = 65
			    if b.buildData.gridSize==2 then
			        sc=sc*0.75
			        temp:setScale(sc)
			        if b.buildData.bid==3005 then
			            yoff = 30
			        elseif b.buildData.bid==2004 or b.buildData.bid==0 then
			            yoff = 45
			        end
			    end
			    if b.buildData.gridSize>=3 or b.isFlag then
			        yoff = 40
			    end
    			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=143, y=yoff+getParam("buildViewOffy" .. info.bid, 0)*sc})
    		end
			bg:addChild(temp)
			if info.levelLimit==0 then
				temp = UI.createLabel(StringManager.getFormatString("needLevel", {level=info.nextLevel, name=StringManager.getString("dataBuildName" .. TOWN_BID)}), General.font1, 20, {colorR = 255, colorG = 255, colorB = 255})
				screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=143, y=79})
				bg:addChild(temp)
			else
				temp = UI.createSpriteWithFile("images/dialogItemTime.png",CCSizeMake(26, 37))
				screen.autoSuitable(temp, {x=14, y=58})
				bg:addChild(temp)
				temp = UI.createLabel(StringManager.getTimeString(info.time), General.font4, 20, {colorR = 255, colorG = 255, colorB = 204})
				screen.autoSuitable(temp, {x=45, y=75, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
				temp = UI.createLabel(StringManager.getString("labelBuilt"), General.font1, 13, {colorR = 255, colorG = 255, colorB = 255})
				screen.autoSuitable(temp, {x=264, y=92, nodeAnchor=General.anchorRight})
				bg:addChild(temp)
				temp = UI.createLabel(info.buildsNum .. "/" .. info.levelLimit, General.font4, 20, {colorR = 179, colorG = 248, colorB = 255})
				screen.autoSuitable(temp, {x=262, y=74, nodeAnchor=General.anchorRight})
				bg:addChild(temp)
			end
		else
			temp = UI.createSpriteWithFile("images/storeItemShield" .. info.id .. ".png")
			screen.autoSuitable(temp, {x=142, y=64, nodeAnchor=General.anchorBottom})
			bg:addChild(temp)
			temp = UI.createLabel(StringManager.getString("labelColddown"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=14, y=93, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
			temp = UI.createLabel(StringManager.getTimeString(info.time), General.font4, 21, {colorR = 255, colorG = 204, colorB = 0})
			screen.autoSuitable(temp, {x=16, y=72, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
		end
		temp = UI.createLabel(info.name, General.font3, 20, {colorR = 255, colorG = 255, colorB = 204})
		screen.autoSuitable(temp, {x=142, y=209, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemBgCost.png",CCSizeMake(264, 46))
		screen.autoSuitable(temp, {x=10, y=10})
		bg:addChild(temp)
		local colorSetting = {colorR=255, colorG=255, colorB=255}
		if ResourceLogic.getResource(info.costType)<info.costValue then
		    colorSetting.colorG=0
		    colorSetting.colorB=0
		end
		temp = UI.createLabel(tostring(info.costValue), General.font4, 20, colorSetting)
		screen.autoSuitable(temp, {x=142, y=33, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		local w = temp:getContentSize().width/2 * temp:getScaleX()
		temp = UI.createScaleSprite("images/" .. info.costType .. ".png",CCSizeMake(34, 34))
		screen.autoSuitable(temp, {x=145+w, y=16})
		bg:addChild(temp)
		scrollView:addChildTouchNode(bg, buyBuild, info)
		if info.info then
		    temp = CCNode:create()
		    temp:setContentSize(CCSizeMake(36, 36))
            screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=253, y=206})
            bg:addChild(temp)
			local temp1 = UI.createSpriteWithFile("images/dialogItemButtonInfo.png",CCSizeMake(36, 36))
			screen.autoSuitable(temp1)
			temp:addChild(temp1)
			scrollView:addChildTouchNode(temp, updateFlip, {bg=bg, scrollView=scrollView, info=info, cellUpdate=updateFlipCell})
		end
		if info.buildsNum and info.buildsNum >= info.levelLimit then
			bg:setSatOffset(-100)
			CCExtendSprite:recurSetGray(bview)
		end
	end
	
	updateFlipCell = function (cell, scrollView, info)
		local bg, temp = cell
		bg:removeAllChildrenWithCleanup(true)
		
		temp = UI.createSpriteWithFile("images/dialogItemButtonStore.png",CCSizeMake(286, 236))
		screen.autoSuitable(temp, {x=0, y=0})
		bg:addChild(temp)
		
		temp = UI.createLabel(info.name, General.font3, 20, {colorR = 255, colorG = 255, colorB = 204})
		screen.autoSuitable(temp, {x=142, y=209, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		
		temp = UI.createLabel(info.info, General.font3, 18, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(270, 170), valign=kCCVerticalTextAlignmentTop})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorTop, x=142, y=178})
		bg:addChild(temp)
		
		scrollView:addChildTouchNode(bg, updateFlip, {bg=bg, scrollView=scrollView, info=info, cellUpdate=updateStoreCell})
	end
	
	local function flipCallback(param)
		param.cellUpdate(param.bg, param.scrollView, param.info)
	end
	
	updateFlip = function(param)
		local bg, scrollView, info = param.bg, param.scrollView, param.info
		local flips = CCArray:create()
		local flipTime = getParam("flipTime", 100)/1000
		flips:addObject(CCScaleTo:create(flipTime, 0, 1))
		flips:addObject(CCScaleTo:create(flipTime, 1, 1))
		bg:runAction(CCSequence:create(flips))
		delayCallback(flipTime, flipCallback, param)
	end
	
	local function showStoreTab(param)
		local bg, temp = param.bg
		bg:removeAllChildrenWithCleanup(true)
		
		local infos = param.infos
		local scrollView = UI.createScrollViewAuto(CCSizeMake(General.winSize.width/(General.winSize.height/768), 512), true, {size=CCSizeMake(286, 236), offx=55, offy=11, disx=28, disy=18, rowmax=2, infos=infos, cellUpdate=param.updateStoreCell or updateStoreCell})
		screen.autoSuitable(scrollView.view, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorLeft})
		bg:addChild(scrollView.view)
		
		if param.needBack then
			temp = UI.createButton(CCSizeMake(107, 51), showMainTab, {callbackParam=bg, image="images/buttonBack.png"})
			screen.autoSuitable(temp, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorLeftTop, x=79, y=-47, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
		end
        temp = UI.createLabel(param.title, General.font3, 40, {colorR = 255, colorG = 255, colorB = 255})
        screen.autoSuitable(temp, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorTop, x=0, y=-48, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
	end
	
	local function updateTreasureCell(cell, scrollView, info)
		local bg, temp = cell
		bg:removeAllChildrenWithCleanup(true)
		
		temp = UI.createSpriteWithFile("images/dialogItemButtonStore.png", CCSizeMake(283, 235))
		screen.autoSuitable(temp, {x=0, y=0})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png")
		screen.autoSuitable(temp, {x=142, y=118, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		
		if info.img then
			temp = UI.createSpriteWithFile(info.img)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=142, y=118})
			bg:addChild(temp)
		end
		
		temp = UI.createSpriteWithFile("images/dialogItemBgCost.png",CCSizeMake(264, 46))
		screen.autoSuitable(temp, {x=10, y=10})
		bg:addChild(temp)
		
		if info.resource=="crystal" then
			temp = UI.createLabel(tostring(info.cost), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=142, y=31, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			temp = UI.createLabel(info.text, General.font3, 20, {colorR = 252, colorG = 186, colorB = 255})
			screen.autoSuitable(temp, {x=142, y=213, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			
			temp = UI.createLabel(tostring(info.get), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=134, y=186, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
			temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(34, 33))
			screen.autoSuitable(temp, {x=100, y=171})
			bg:addChild(temp)
			
			scrollView:addChildTouchNode(bg, CrystalLogic.buyCrystal, info)
		else
		    local colorSetting = {colorR = 255, colorG = 255, colorB = 255}
		    if info.cost>UserData.crystal then
		        colorSetting.colorG=0
		        colorSetting.colorB=0
		    end
			temp = UI.createLabel(tostring(info.cost), General.font4, 20, colorSetting)
			screen.autoSuitable(temp, {x=142, y=31, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			local w = temp:getContentSize().width/2 * temp:getScaleX()
			temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(34, 33))
			screen.autoSuitable(temp, {x=145+w, y=16})
			bg:addChild(temp)
			
			temp = UI.createLabel(info.text, General.font3, 20, {colorR = 255, colorG = 255, colorB = 204})
			screen.autoSuitable(temp, {x=142, y=213, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			temp = UI.createLabel(info.get .. " " .. StringManager.getString(info.resource), General.font3, 20, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=142, y=186, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			scrollView:addChildTouchNode(bg, CrystalLogic.buyResource, info)
		end
	end
	
	local function showTreasureTab(param)
		local infos = {}
		local crystals = {500, 1200, 2500, 6500, 14000}
		local TEST_INFO = {4.99, 9.99, 19.99, 49.99, 99.99}
		for i=1, 5 do
			-- in app pay
			local info = {resource="crystal", cost=TEST_INFO[i], get=crystals[i], text=StringManager.getString("storeItemCrystal" .. i), img="images/storeItemCrystal" .. i .. ".png"}
			table.insert(infos, info)
		end
		
		local types = {"food", "oil", "person"}
		local tmap = {food="Food", oil="Oil", person="Person"}
		for i=1, #types do	
			local resourceType = types[i]
			local num = ResourceLogic.getResource(resourceType)
			local max = ResourceLogic.getResourceMax(resourceType)
			
			local prefix = "images/storeItem" .. tmap[resourceType]
			if num*10/9<max then
				local info = {resource=resourceType, get=math.ceil(max/10), text=StringManager.getString("storeItemResource1"), img=prefix .. "1.png"}
				info.cost = CrystalLogic.computeCostByResource(resourceType, info.get)
				table.insert(infos, info)
			end
			if num*2<max then
				local info = {resource=resourceType, get=math.ceil(max/2), text=StringManager.getString("storeItemResource2"), img=prefix .. "2.png"}
				info.cost = CrystalLogic.computeCostByResource(resourceType, info.get)
				table.insert(infos, info)
			end
			if num<max then
				local info = {resource=resourceType, get=max-num, text=StringManager.getFormatString("storeItemResource3", {name=StringManager.getString("dataBuildName" .. RESOURCE_BUILD_BIDS[resourceType])}), img=prefix .. "3.png"}
				info.cost = CrystalLogic.computeCostByResource(resourceType, info.get)
				table.insert(infos, info)
			end
		end
		
		param.infos = infos
		param.updateStoreCell=updateTreasureCell
		showStoreTab(param)
	end
	
	local function showBuildTab(param)
		param.infos = Build.getBuildStoreInfo(param.bids)
		showStoreTab(param)
	end
	
	local function showShieldTab(param)
		param.infos = {{id=1,time=86400,costType="crystal",costValue=100}, {id=2,time=172800,costType="crystal", costValue=150}, {id=3, time=604800, costType="crystal", costValue=250}}
		for i=1, 3 do
		    param.infos[i].name = StringManager.getString("storeItemShieldName" .. i)
		    param.infos[i].info = StringManager.getString("storeItemShieldInfo" .. i)
		end
		showStoreTab(param)
	end
	
	-- 注意：1-6的ID实际对应1\4\2\5\3\6
	local function updateMainTabCell(cell, scrollView, info)
		cell:removeAllChildrenWithCleanup(true)
		local temp
		temp = UI.createSpriteWithFile("images/dialogItemButtonStore.png", CCSizeMake(283, 235))
		screen.autoSuitable(temp, {x=0, y=0})
		cell:addChild(temp)
		
		local tid = math.ceil(info.id/2)+(info.id-1)%2*3
		info.tid = tid
		
		if UserData.canBuild and info.id>=2 and info.id<=4 and UserData.canBuild[info.id-1]>0 then
            temp = UI.createSpriteWithFile("images/newNumIcon.png",CCSizeMake(47, 36))
            screen.autoSuitable(temp, {x=9, y=192})
            cell:addChild(temp)
            temp = UI.createLabel(tostring(UserData.canBuild[info.id-1]), General.font1, 22, {colorR = 255, colorG = 255, colorB = 255})
            screen.autoSuitable(temp, {x=33, y=210, nodeAnchor=General.anchorCenter})
            cell:addChild(temp)
        end
		if not GuideLogic.complete and GuideLogic.guideBid then
		    local type = math.floor(GuideLogic.guideBid/1000)+1
		    if type==1 then type=3 end
			if type==info.id then
				local pt = UI.createGuidePointer(-45)
				pt:setPosition(75, 160)
				pt:setScale(0.6)
				pt:setHueOffset(200, true)
				cell:addChild(pt,10)
			end
		end
		
		temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png")
		screen.autoSuitable(temp, {x=142, y=118, nodeAnchor=General.anchorCenter})
		cell:addChild(temp)
		
		local cellImg = "images/storeItem" .. tid .. ".png"
		if tid==6 then
			cellImg = "images/storeItemShield1.png"
		end
		temp = UI.createSpriteWithFile(cellImg)
		screen.autoSuitable(temp, {x=142, y=128, nodeAnchor=General.anchorCenter})
		cell:addChild(temp)
		
		temp = UI.createSpriteWithFile("images/dialogItemStoreRibbon.png",CCSizeMake(297, 93))
		screen.autoSuitable(temp, {x=-5, y=-4})
		cell:addChild(temp)
		
		info.title = StringManager.getString("titleStoreItem" .. tid)
		temp = UI.createLabel(info.title, General.font3, 25, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=142, y=47, nodeAnchor=General.anchorCenter})
		cell:addChild(temp)
		
		callback = nil
		
		if info.tid==6 then
			callback = showShieldTab
		elseif info.tid==1 then
			callback = showTreasureTab
		else
			if info.tid==2 then
				info.bids = {2000, 2001, 2002, 2003, 0, 2004, 2005}
			elseif info.tid==4 then
				info.bids = {1000, 1001, 1002}
			elseif info.tid==5 then
				info.bids = {3000, 3001, 3006, 5000, 3002, 3004, 5001, 3003, 5002, 3005, 3007}
			else
				info.bids = {6000, 6001, 6002, 6003}
			end
			callback = showBuildTab
		end
		scrollView:addChildTouchNode(cell, callback, info)
	end
	
	showMainTab = function (tabView)
		local bg, temp = tabView, nil
		bg:removeAllChildrenWithCleanup(true)
		
		local infos = {}
		for i = 1, 6 do
			infos[i] = {id=i, bg=bg, needBack=true}
		end
		local scrollView = UI.createScrollViewAuto(CCSizeMake(1024, 518), true, {size=CCSizeMake(283, 235), offx=56, offy=5, disx=32, disy=30, rowmax=2, infos=infos, cellUpdate=updateMainTabCell})

		screen.autoSuitable(scrollView.view, {scaleType=screen.SCALE_CUT_EDGE, screenAnchor=General.anchorCenter})
		bg:addChild(scrollView.view)
		
		temp = UI.createLabel(StringManager.getString("titleStore"), General.font3, 40, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorTop, x=0, y=-48, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		return bg
	end
	
	function StoreDialog.getBottomView()
		local bg, temp
		bg = CCNode:create()
		bg:setContentSize(CCSizeMake(1024,64))
		screen.autoSuitable(bg, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorBottom})
		
        temp = UI.createSpriteWithFile("images/dialogItemBgResource2.png",CCSizeMake(167, 36))
        screen.autoSuitable(temp, {x=713, y=30})
        bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(55, 54))
        screen.autoSuitable(temp, {x=838, y=19})
        bg:addChild(temp)
        temp = UI.createLabel(tostring(UserData.crystal), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
        screen.autoSuitable(temp, {x=834, y=46, nodeAnchor=General.anchorRight})
        bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/dialogItemBgResource1.png",CCSizeMake(167, 36))
        screen.autoSuitable(temp, {x=515, y=30})
        bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/person.png",CCSizeMake(67, 52))
        screen.autoSuitable(temp, {x=634, y=22})
        bg:addChild(temp)
        temp = UI.createLabel(tostring(ResourceLogic.getResource("person")), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
        screen.autoSuitable(temp, {x=642, y=46, nodeAnchor=General.anchorRight})
        bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/dialogItemBgResource1.png",CCSizeMake(167, 36))
        screen.autoSuitable(temp, {x=323, y=30})
        bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/oil.png",CCSizeMake(46, 52))
        screen.autoSuitable(temp, {x=456, y=23})
        bg:addChild(temp)
        temp = UI.createLabel(tostring(ResourceLogic.getResource("oil")), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
        screen.autoSuitable(temp, {x=451, y=46, nodeAnchor=General.anchorRight})
        bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/dialogItemBgResource1.png",CCSizeMake(167, 36))
        screen.autoSuitable(temp, {x=134, y=30})
        bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/food.png",CCSizeMake(43, 58))
        screen.autoSuitable(temp, {x=265, y=21})
        bg:addChild(temp)
        temp = UI.createLabel(tostring(ResourceLogic.getResource("food")), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
        screen.autoSuitable(temp, {x=255, y=46, nodeAnchor=General.anchorRight})
        bg:addChild(temp)
		return bg
	end
	
	function StoreDialog.show(param)
	    if param=="builders" and ResourceLogic.getResourceMax("builder")==5 then
	        display.pushNotice(UI.createNotice(StringManager.getString("noticeBuilderMax")))
	        return false
	    end
		local temp, bg = nil
		bg = UI.createButton(General.winSize, doNothing, {image="images/dialogBgStore.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})

        temp = UI.createButton(CCSizeMake(57, 56), display.closeDialog, {image="images/buttonClose.png"})
        screen.autoSuitable(temp, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorRightTop, x=-47, y=-45, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
		bg:addChild(StoreDialog.getBottomView())
		
		local tabView = CCNode:create()
		tabView:setContentSize(General.winSize)
		
		if not param then
			showMainTab(tabView)
            EventManager.sendMessage("EVENT_NOTICE_BUTTON", {name="shop", isShow=false})
		elseif param=="builders" then
			local tabParam = {bg=tabView, title=StringManager.getString("titleBuilders"), bids={2004}}
			showBuildTab(tabParam)
		elseif param=="shield" then
			local tabParam = {bg=tabView, title=StringManager.getString("titleStoreItem6")}
			showShieldTab(tabParam)
		elseif param=="treasure" then
			local tabParam = {bg=tabView, title=StringManager.getString("titleStoreItem1")}
			showTreasureTab(tabParam)
		end
		bg:addChild(tabView)
		display.showDialog({view=bg},false)
	end
end