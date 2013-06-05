InfoDialog = {}

do
	function InfoDialog.create(build)
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
		
		local bdata = build.buildData
		local binfo = StaticData.getBuildInfo(bdata.bid)
		local titleKey = "titleInfo"
		if binfo.levelMax==1 then
			titleKey = "titleInfoNoLevel"
		end
    	if build.buildLevel==0 and build.buildState~=BuildStates.STATE_BUILDING then
    	    titleKey = "titleInfoLevel0"
    	end
		temp = UI.createLabel(StringManager.getFormatString(titleKey, {name=binfo.name, level=build.buildLevel}), General.font3, 30, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=360, y=489, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
	
		temp = build:getBuildView()
		local bid = build.buildData.bid
		local x, y = getParam("buildViewOffx" .. bid, 0), getParam("buildViewOffy" .. bid, 0)
		if bid==3006 then
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=152+x, y=324+y})
			bg:addChild(temp)
		elseif bid==3005 or bid==0 then
		    local s = 1.5/build.buildData.gridSize
			temp:setScale(s)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=152+x*s, y=277+y*s})
			bg:addChild(temp)
		elseif bid==1004 then
		    --local s=2/build.buildData.gridSize
			--temp:setScale(s)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=152+x, y=173+y})
			bg:addChild(temp)
		else
		    local s=2/build.buildData.gridSize
			temp:setScale(s)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=152+x*s, y=277+y*s})
			bg:addChild(temp)
		end
		
		local infoOffset, itemIndex = 238, 1
		if build.addBuildInfo then
			local itemNum, offset
			itemNum, offset = build:addBuildInfo(bg, UI.addInfoItem2)
			if offset and offset>0 then
				infoOffset = offset
			end
			if itemNum then
				itemIndex = itemIndex + itemNum
			end
		end
		UI.addInfoItem2(bg, itemIndex, build.getHitPoints or bdata.hitPoints, nil, bdata.hitPoints, "Hitpoints", nil, build)
		if binfo.info then
			--238
			temp = UI.createLabel(binfo.info, General.font1, 17, {colorR = 33, colorG = 93, colorB = 165, size=CCSizeMake(650, 0)})
			screen.autoSuitable(temp, {x=360, y=infoOffset, nodeAnchor=General.anchorTop})
			bg:addChild(temp)
		end
		return bg
	end
	
	function InfoDialog.show(build)
		display.showDialog(InfoDialog.create(build))
	end
end