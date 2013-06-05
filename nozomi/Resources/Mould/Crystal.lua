Crystal={LEVEL_HUE_OFF={0, -50, 50, 100}, LEVEL_CRYSTAL_GAIN={1000,1500,2000,2500}; COST_TIME=3600; MAX_LEVEL=4}
require "Dialog.CrystalUpdateDialog"
do
	Crystal.addBuildFunctions = function(retBuild, params)
		retBuild.build:setScale(1.2)
		retBuild.buildLevel = params.buildLevel or 1
		retBuild.build:setHueOffset(Crystal.LEVEL_HUE_OFF[retBuild.buildLevel])
		retBuild.leftTime = Crystal.COST_TIME
		
		retBuild.createInfoMenu = function()
			local temp, bg = nil
			bg = UI.createSpriteWithFile("images/buildMenu1.png",CCSizeMake(960, 73))
			local function update()
				bg:removeAllChildrenWithCleanup(true)
				temp = UI.createTTFLabel(StringManager.getFormatString("crystalInfoStr", {level = retBuild.buildLevel}), General.defaultFont, 24, {colorR = 255, colorG = 255, colorB = 255})
				screen.autoSuitable(temp, {x=38, y=33, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
				local width = temp:getContentSize().width
				temp = UI.createTTFLabel(StringManager.getTimeString(retBuild.leftTime), General.defaultFont, 24, {colorR = 224, colorG = 194, colorB = 45})
				screen.autoSuitable(temp, {x=38 + width, y=33, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
			end
			update()
			simpleRegisterEvent(bg, {update = {callback = update, inteval = 0.5}})
			return bg
		end
		
		local function completeGetCrystal()
			EventManager.sendMessage("EVENT_PICKFLY", {gain={crystal=Crystal.LEVEL_CRYSTAL_GAIN[retBuild.buildLevel]}, obj=retBuild.flyNode})
			if retBuild.flyNode then
				retBuild.flyNode:removeFromParentAndCleanup(true)
				retBuild.flyNode = nil
			end
			retBuild.flyNodeTouched = nil
			UserData.changeValue("crystal", Crystal.LEVEL_CRYSTAL_GAIN[retBuild.buildLevel])
			retBuild.leftTime = Crystal.COST_TIME
		end
		
		local function upgradeBuild()
			retBuild.buildLevel = retBuild.buildLevel + 1
			retBuild.build:setHueOffset(Crystal.LEVEL_HUE_OFF[retBuild.buildLevel])
		end
		retBuild.upgradeBuild = upgradeBuild
		
		local function update(diff)
			if retBuild.leftTime>0 then
				retBuild.leftTime = retBuild.leftTime - diff
			elseif not retBuild.flyNode then
				local flyNode = UI.createSpriteWithFile("images/flowBanner.png")
				local size = retBuild.view:getContentSize()
				screen.autoSuitable(flyNode, {x=size.width/2, y=size.height - 10, nodeAnchor=General.anchorBottom})
				retBuild.view:addChild(flyNode, 3)
				flyNode:runAction(Action.createVibration(getParam("flyNodeTime")/1000, 0, getParam("flyMove")))
				retBuild.flyNodeTouched = completeGetCrystal
				
				local temp = UI.createSpriteWithFile("images/crystal.png", CCSizeMake(38, 36))
				screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=34, y=34})
				flyNode:addChild(temp)
				retBuild.flyNode = flyNode
			end
		end
		
		local function accCrystal()
			if UserData.checkAndCost({costType="gold", gold=10, noticeType=UserConst.COST_ACC}) then
				retBuild.leftTime = 0
				update(0)
			end
		end
		
		local function readyToAcc()
			if retBuild.leftTime > 0 then
				local cost = math.ceil(10)
				display.pushNotice(UI.createNoticeType2(StringManager.getFormatString("accNotice", {gold=cost}), StringManager.getString("ok"), accCrystal), true)
			end
		end
		retBuild.getRightButtons = function()
			local function showUpdateDialog()
				if retBuild.buildLevel < Crystal.MAX_LEVEL then
					display.showDialog(CrystalUpdateDialog.create(retBuild))
				end
			end
			return {{button="upgrade", callback=showUpdateDialog}, {button="acc", callback=readyToAcc}}
		end
		simpleRegisterEvent(retBuild.view, {update={callback=update, inteval=0.5}})
		
	end
end