UpgradeDialog = {}

do	
	function UpgradeDialog.create(build)
		local temp, bg = nil
		bg = UI.createButton(CCSizeMake(720, 526), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
		screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_DIALOG_CLEVER})
		UI.setShowAnimate(bg)
		temp = UI.createSpriteWithFile("images/dialogBgB.png",CCSizeMake(670, 234))
		screen.autoSuitable(temp, {x=25, y=25})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemBlood.png",CCSizeMake(292, 222))
		screen.autoSuitable(temp, {x=39, y=25})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png",CCSizeMake(335, 368))
		screen.autoSuitable(temp, {x=-4, y=169})
		bg:addChild(temp)
		temp = UI.createButton(CCSizeMake(47, 46), display.closeDialog, {image="images/buttonClose.png"})
		screen.autoSuitable(temp, {x=683, y=492, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createLabel(StringManager.getFormatString("titleUpgrade", {level=build.buildLevel+1}), General.font3, 30)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=360, y=489})
		bg:addChild(temp)
		
		local bdata = build.buildData
		local maxData = StaticData.getMaxLevelData(bdata.bid)
		local nextLevel = StaticData.getBuildData(bdata.bid, bdata.level+1)
		
		local bd = Build.create(nextLevel.bid, nil, {level=nextLevel.level})
		temp = bd:getBuildView()
		local bid = bd.buildData.bid
		local x, y = getParam("buildViewOffx" .. bid, 0), getParam("buildViewOffy" .. bid, 0)
		if bid==3006 then
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=152+x, y=324+y})
			bg:addChild(temp)
		elseif bid==3005 or bid==0 then
		    local s = 1.5/build.buildData.gridSize
			temp:setScale(s)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=152+x*s, y=277+y*s})
			bg:addChild(temp)
		else
		    local s=2/build.buildData.gridSize
			temp:setScale(s)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=152+x*s, y=277+y*s})
			bg:addChild(temp)
		end
		
		temp = UI.createSpriteWithFile("images/dialogItemUpgradeTimeBg.png",CCSizeMake(112, 50))
        screen.autoSuitable(temp, {x=25, y=266})
        bg:addChild(temp)
        temp = UI.createLabel(StringManager.getTimeString(nextLevel.time), General.font4, 18, {colorR = 255, colorG = 255, colorB = 255})
        screen.autoSuitable(temp, {x=81, y=281, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
        temp = UI.createLabel(StringManager.getString("labelUpgradeTime"), General.font1, 11, {colorR = 77, colorG = 66, colorB = 27})
        screen.autoSuitable(temp, {x=81, y=302, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
		
		local itemIndex=1
		if build.addBuildUpgrade then
			local itemNum
			itemNum = build:addBuildUpgrade(bg, UI.addInfoItem2)
			if itemNum then
				itemIndex = itemIndex + itemNum
			end
		end
		UI.addInfoItem2(bg, itemIndex, bdata.hitPoints, nextLevel.hitPoints, maxData.hitPoints, "Hitpoints", nil)
		
		if build.needPerson then
            temp = UI.createLabel(StringManager.getFormatString("labelNeedPerson", {name=StringManager.getString("dataBuildName" .. bid), num=nextLevel.extendValue2}), General.font1, 17, {colorR = 33, colorG = 93, colorB = 165})
            screen.autoSuitable(temp, {x=36, y=147, nodeAnchor=General.anchorLeft})
            bg:addChild(temp)
		end
		
		temp = UI.createButton(CCSizeMake(169, 76), build.beginUpgrade, {image="images/buttonGreen.png", callbackParam=build, useExtendNode=true})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=360, y=79})
		bg:addChild(temp, 1)
		local colorSetting = {colorR=255, colorG=255, colorB=255, lineOffset=-12}
		if ResourceLogic.getResource(nextLevel.costType)<nextLevel.costValue then
		    colorSetting.colorG=0
		    colorSetting.colorB=0
		end
		local temp1 = UI.createScaleSprite("images/" .. nextLevel.costType .. ".png",CCSizeMake(50, 38))
        screen.autoSuitable(temp1, {nodeAnchor=General.anchorCenter, x=143, y=38})
        temp:addChild(temp1)
		temp1 = UI.createLabel(tostring(nextLevel.costValue), General.font4, 22, colorSetting)
		screen.autoSuitable(temp1, {nodeAnchor=General.anchorRight, x=118, y=38})
		temp:addChild(temp1)
		
		if nextLevel.needLevel>UserData.level then
		    temp:setSatOffset(-100)
    		temp = UI.createSpriteWithFile("images/dialogItemTipsBgB.png",CCSizeMake(647, 81))
            screen.autoSuitable(temp, {x=37, y=39})
            bg:addChild(temp)
            temp = UI.createLabel(StringManager.getString("labelNote"), General.font3, 22, {colorR = 255, colorG = 255, colorB = 255})
            screen.autoSuitable(temp, {x=577, y=119, nodeAnchor=General.anchorCenter})
            bg:addChild(temp)
            temp = UI.createLabel(StringManager.getFormatString("needLevel2", {level=nextLevel.needLevel, name=StringManager.getString("dataBuildName" .. TOWN_BID)}), General.font1, 16, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(192, 40)})
            screen.autoSuitable(temp, {x=577, y=78, nodeAnchor=General.anchorCenter})
            bg:addChild(temp)
		end
		
		if GuideLogic.guideBid==bid then
            temp = UI.createGuidePointer(90)
            temp:setPosition(448, 79)
            bg:addChild(temp)
		end
		return bg
	end

	function UpgradeDialog.show(build)
		display.showDialog(UpgradeDialog.create(build))
	end
end