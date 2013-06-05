require "Dialog.TipDialog"
Castle={}
do
	Castle.addBuildFunctions = function(retBuild)
		retBuild.getRightButtons = function()
			return {{button="tip", callback=display.showDialog, callbackParam = TipDialog}}
		end
		
		retBuild.createInfoMenu = function()
			local temp, bg = nil
			bg = UI.createSpriteWithFile("images/buildMenu1.png",CCSizeMake(960, 73))
			temp = UI.createTTFLabel(StringManager.getString("castleInfoStr"), General.defaultFont, 24, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=38, y=33, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
			local width = temp:getContentSize().width
			temp = UI.createTTFLabel(UserData.defence .. "", General.defaultFont, 24, {colorR = 224, colorG = 194, colorB = 45})
			screen.autoSuitable(temp, {x=38 + width, y=33, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
			width = width + temp:getContentSize().width
			temp = UI.createButton(CCSizeMake(33, 32), StoreDialog.showDialog, {image="images/buildDefense.png", priority=display.MENU_BUTTON_PRI, callbackParam=StoreDialog.TAB_DECOR})
			screen.autoSuitable(temp, {x=58 + width, y=32, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			return bg
		end
	end
end