require "Dialog.AllSoldierDialog"
require "Dialog.SoldierEquipDialog"
Statue={}
do
	Statue.addBuildFunctions = function(retBuild)
		retBuild.getRightButtons = function()
			return {{button="soldier", callback=display.showDialog, callbackParam = AllSoldierDialog}}
		end
		
		retBuild.createInfoMenu = function()
			local temp, bg = nil
			bg = UI.createSpriteWithFile("images/buildMenu1.png",CCSizeMake(960, 73))
			temp = UI.createTTFLabel(StringManager.getString("statueInfoStr"), General.defaultFont, 24, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=38, y=33, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
			local width = temp:getContentSize().width
			temp = UI.createTTFLabel(UserData.soldierNum .. "", General.defaultFont, 24, {colorR = 224, colorG = 194, colorB = 45})
			screen.autoSuitable(temp, {x=38 + width, y=33, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
			return bg
		end
	end
end