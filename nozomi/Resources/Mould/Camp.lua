require "Dialog.CampDialog"
Camp={}
do
	Camp.addBuildFunctions = function(retBuild, scene)
		retBuild.getRightButtons = function()
			--if SoldierLogic.isEmpty() then
			--	return {{button="call", callback=display.showDialog, callbackParam = CampDialog}}
			--end
			return {{button="call", callback=display.showDialog, callbackParam = CampDialog}, {button="acc", callback=SoldierLogic.readyToAcc}}
		end
		
		retBuild.createInfoMenu = function()
			local temp, bg = nil
			bg = UI.createSpriteWithFile("images/buildMenu1.png",CCSizeMake(960, 73))
			temp = UI.createTTFLabel(StringManager.getString("campInfoStr"), General.defaultFont, 24, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=38, y=33, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
			return bg
		end
		
		local function completeCallSoldier()
			if retBuild.flyNode then
				retBuild.flyNode:removeFromParentAndCleanup(true)
				retBuild.flyNode = nil
			end
			retBuild.flyNodeTouched = nil
			local soldiers = SoldierLogic.completeCallSoldier()
			-- TODO
		end
		
		local function update(diff)
			SoldierLogic.updateSoldierList()
			local isCallOver = SoldierLogic.isCallOver()
			if isCallOver and not retBuild.flyNode then
				local flyNode = UI.createSpriteWithFile("images/flowBanner.png")
				local size = retBuild.view:getContentSize()
				screen.autoSuitable(flyNode, {x=size.width/2, y=size.height - 10, nodeAnchor=General.anchorBottom})
				retBuild.view:addChild(flyNode, 3)
				flyNode:runAction(Action.createVibration(getParam("flyNodeTime")/1000, 0, getParam("flyMove")))
				retBuild.flyNodeTouched = completeCallSoldier
				
				local temp = UI.createSpriteWithFile("images/soldierCall.png", CCSizeMake(38, 40))
				screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=34, y=34})
				flyNode:addChild(temp)
				retBuild.flyNode = flyNode
			end
		end
		simpleRegisterEvent(retBuild.view, {update={callback=update, inteval=1}})
		
	end
end