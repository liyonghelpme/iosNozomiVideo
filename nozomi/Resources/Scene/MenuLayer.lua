require "Dialog.AboutDialog"
require "Dialog.SNSDialog"
require "Dialog.SettingDialog"
require "Dialog.StoreDialog"
require "Dialog.InfoDialog"
require "Dialog.UpgradeDialog"
require "Dialog.TrainDialog"
require "Dialog.ResearchDialog"
require "Dialog.ClanDialog"
require "Dialog.HistoryDialog"
require "Dialog.AchievementDialog"
require "Dialog.ZombieDialog"
require "Dialog.RankDialog"
require "Dialog.ZombieResultDialog"
require "Dialog.VideoDialog"
require "Dialog.RenameDialog"

MenuLayer = class()

local function createChildMenuButton(buttonImage, buttonText, callback, callbackParam, setting)
	local params = setting or {}
	local buttonBg = params.background or "images/buttonChildMenu.png"
	local but = UI.createButton(CCSizeMake(93, 91), callback, {callbackParam=callbackParam, image=buttonBg, priority=display.MENU_BUTTON_PRI})
	local temp
	
	if buttonImage then
		temp = UI.createSpriteWithFile(buttonImage)
		if params.imgScale then
			temp:setScale(params.imgScale)
		end
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=47+getParam("xoff" .. buttonText, 0), y=46+getParam("yoff" .. buttonText, 0)})
		but:addChild(temp)
	end
	
	temp = UI.createLabel(buttonText, General.font3, 15, {size=CCSizeMake(85, 40), lineOffset=-12})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=47, y=16})
	but:addChild(temp)
	
	if params.cost then
		local cost = params.cost
		local colors = {colorR=255,colorG=255,colorB=255}
		if cost.costValue>ResourceLogic.getResource(cost.costType) then
		    colors.colorG=0
		    colors.colorB=0
		end
		if cost.costMid then
			temp = UI.createLabel(tostring(cost.costValue), General.font4, 20, colors)
			screen.autoSuitable(temp, {x=47, y=72, nodeAnchor=General.anchorCenter})
			but:addChild(temp)
		else
			temp = UI.createResourceNode(cost.costType, cost.costValue, 21, colors)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorRightTop, x=89, y=87})
			but:addChild(temp)
		end
	end
	return but
end

function MenuLayer:ctor(scene)
    local layer = CCTouchLayer:create(display.MENU_PRI, false)
    layer:setContentSize(General.winSize)
		
	self.view=layer
	self.scene = scene
	
	self:initRightTop()
	self:initTop()
	self:initLeftTop()
	self:initRightBottom()
	
	simpleRegisterEvent(layer, {enterOrExit = {callback = self.enterOrExit}, update={inteval=0.2, callback=self.update}}, self)
end

function MenuLayer:enterBattleScene()
    if BattleLogic.checkBattleEnable(self.scene, self.enterBattleScene, self) then
		self.scene:updateLogic(300)
		UserStat.stat(UserStatType.ATTACK)
		display.pushScene(BattleScene.new(), PreBattleScene)
	end
end

function MenuLayer:initRightBottom()
	local bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 256))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorRightBottom})
	self.view:addChild(bg)
	
	self.buts = {}
	self.butNotices = {}
	local temp = UI.createButton(CCSizeMake(115, 111), self.enterBattleScene, {callbackParam=self, image="images/buttonMenu.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=192, y=64})
	bg:addChild(temp)
	self.buts["attack"] = temp
	print("ckguide", GuideLogic.complete)
	if not GuideLogic.complete and GuideLogic.step<11 then
		temp:setVisible(false)
	end
	local img = UI.createScaleSprite("images/menuItemAttack.png", CCSizeMake(111, 108))
	screen.autoSuitable(img, {nodeAnchor=General.anchorCenter, x=58, y=56})
	temp:addChild(img)
	local label = UI.createLabel(StringManager.getString("buttonAttack"), General.font3, ATTACK_BUTTON_SIZE, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(label, {x=58, y=22, nodeAnchor=General.anchorCenter})
	temp:addChild(label)
	
	temp = UI.createButton(CCSizeMake(73, 72), StoreDialog.show, {image="images/buttonMenu.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=88, y=49})
	bg:addChild(temp)
	self.buts["shop"] = temp
	if not GuideLogic.complete and GuideLogic.step<1 then
		temp:setVisible(false)
	end
	img = UI.createScaleSprite("images/menuItemStore.png", CCSizeMake(73, 72))
	screen.autoSuitable(img, {nodeAnchor=General.anchorCenter, x=37, y=36})
	temp:addChild(img)
	
	temp = UI.createButton(CCSizeMake(73, 72), AchievementDialog.show, {image="images/buttonMenu.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=5, y=49})
	bg:addChild(temp)
	self.buts["achieve"] = temp
	if not GuideLogic.complete then
		temp:setVisible(false)
	end
	img = UI.createScaleSprite("images/menuItemAchieve.png", CCSizeMake(59, 59))
	screen.autoSuitable(img, {nodeAnchor=General.anchorCenter, x=37, y=36})
	temp:addChild(img)
	
	temp = UI.createButton(CCSizeMake(73, 72), display.showDialog, {callbackParam=SettingDialog, image="images/buttonMenu.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=206, y=164})
	bg:addChild(temp)
	self.buts["setting"] = temp
	if not GuideLogic.complete then
		temp:setVisible(false)
	end
	img = UI.createScaleSprite("images/menuItemSetting.png", CCSizeMake(73, 72))
	screen.autoSuitable(img, {nodeAnchor=General.anchorCenter, x=37, y=36})
	temp:addChild(img)
	
	temp = UI.createButton(CCSizeMake(73, 72), HistoryDialog.show, {image="images/buttonMenu.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=206, y=245})
	bg:addChild(temp)
	self.buts["mail"] = temp
	if not GuideLogic.complete or UserData.historys==nil or #(UserData.historys)==0 then
		temp:setVisible(false)
	end
	img = UI.createScaleSprite("images/menuItemMail.png", CCSizeMake(73, 72))
	screen.autoSuitable(img, {nodeAnchor=General.anchorCenter, x=37, y=36})
	temp:addChild(img)
    
	if GuideLogic.menuType then
	    local pname = GuideLogic.menuType
		self.buts[pname]:setVisible(true)
		local pt = GuideLogic.addPointer(0)
		local parent = self.buts[pname]:getParent()
		local x, y = self.buts[pname]:getPosition()
		pt:setPosition(x, y+60)
		parent:addChild(pt)
		if pname=="shop" then
		    self.guideBid = GuideLogic.guideBid
		end
	end
end

function MenuLayer:initRightTop()
	local temp, bg = nil
	bg = CCNode:create()
	local batchBg = CCSpriteBatchNode:create("images/normalUI.png", 11)
	bg:addChild(batchBg)
	bg:setContentSize(CCSizeMake(256, 256))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorRightTop})
	self.view:addChild(bg)
	
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=81, y=28})
	batchBg:addChild(temp)
	if self.scene.sceneType==SceneTypes.Operation then
    	temp = UI.createButton(CCSizeMake(33, 37), StoreDialog.show, {priority=display.MENU_BUTTON_PRI, callbackParam="treasure", image="images/buttonAdd.png"})
    	screen.autoSuitable(temp, {x=96, y=42, nodeAnchor=General.anchorCenter})
    	bg:addChild(temp)
    end
	temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(55, 54))
	screen.autoSuitable(temp, {x=186, y=11})
	batchBg:addChild(temp)
	temp = UI.createLabel(tostring(UserData.crystal), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=182, y=41, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	self.crystal = {valueLabel=temp, value=UserData.crystal}
	
	local items = {{"person", 160, 30, 163, 172, 74}, {"oil", 219, 29, 225, 188, 134}, {"food", 219, 29, 225, 193, 191}}
	for i=1, 3 do
		local resourceType = items[i][1]
		local item = {}
		
		--local filler = resourceType
		--if resourceType=="person" then filler="special" end
		
		temp = UI.createSpriteWithFile("images/normalFiller.png",CCSizeMake(items[i][2], items[i][3]))
		local dis = (items[i][4]-items[i][2])/2
		screen.autoSuitable(temp, {x=237-dis, y=24+i*59+dis, nodeAnchor=General.anchorRightBottom})
		batchBg:addChild(temp)
		item.filler = temp
		temp:setColor(RESOURCE_COLOR[resourceType])
		UI.registerAsProcess(temp, item)
		temp = UI.createSpriteWithFile("images/fillerBottom.png",CCSizeMake(items[i][4], 34))
		screen.autoSuitable(temp, {x=237-items[i][4], y=24+i*59})
		batchBg:addChild(temp)
		temp = UI.createSpriteWithFile("images/" .. resourceType .. ".png")
		screen.autoSuitable(temp, {x=items[i][5], y=items[i][6]})
		batchBg:addChild(temp)
		item.value = ResourceLogic.getResource(resourceType)
		item.max = ResourceLogic.getResourceMax(resourceType)
		temp = UI.createLabel(tostring(item.value), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=182, y=39 + 59*i, nodeAnchor=General.anchorRight})
		bg:addChild(temp)
		item.valueLabel = temp
		temp = UI.createLabel(StringManager.getFormatString("resourceMax", {max=item.max}), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=243-items[i][4], y=67 + 59*i, nodeAnchor=General.anchorLeft})
		bg:addChild(temp)
		item.maxLabel = temp
		local lmax = item.max
		if lmax==0 then lmax=1 end
		UI.setProcess(item.filler, item, item.value/lmax, true)
		self[resourceType] = item
	end
end

function MenuLayer:initTop()
	local temp, bg = nil
	bg = CCNode:create()
	local batchBg = CCSpriteBatchNode:create("images/normalUI.png", 4)
	bg:addChild(batchBg)
	bg:setContentSize(CCSizeMake(384, 128))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorTop})
	self.view:addChild(bg)
	
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=202, y=75})
	batchBg:addChild(temp)
	temp = UI.createLabel(StringManager.getTimeString(0), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=301, y=88, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.shieldLabel = temp
	
	if self.scene.sceneType==SceneTypes.Operation then
    	temp = UI.createButton(CCSizeMake(33, 37), StoreDialog.show, {priority=display.MENU_BUTTON_PRI, image="images/buttonAdd.png", callbackParam="shield"})
    	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=366, y=90})
    	bg:addChild(temp)
    end
	temp = UI.createSpriteWithFile("images/shield.png",CCSizeMake(51, 59))
	screen.autoSuitable(temp, {x=202, y=61})
	batchBg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelShieldTime"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=297, y=116, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=-3, y=75})
	batchBg:addChild(temp)
	temp = UI.createLabel(StringManager.getTimeString(0), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=95, y=88, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.zombieShieldLabel = temp
	if self.scene.sceneType==SceneTypes.Operation then
    	temp = UI.createButton(CCSizeMake(33, 37), self.dalayZombieAttack, {priority=display.MENU_BUTTON_PRI, callbackParam=self, image="images/buttonAdd.png"})
    	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=160, y=90})
    	bg:addChild(temp)
    end
	temp = UI.createSpriteWithFile("images/zombie.png",CCSizeMake(46, 58))
	screen.autoSuitable(temp, {x=1, y=62})
	batchBg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelZombieShield"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=94, y=115, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
end

function MenuLayer:initLeftTop()
	local temp, bg = nil
	bg = CCNode:create()
	local batchBg = CCSpriteBatchNode:create("images/normalUI.png", 7)
	bg:addChild(batchBg)
	bg:setContentSize(CCSizeMake(256, 256))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorLeftTop})
	self.view:addChild(bg)
	
	local item = {value=(UserData.level or 1)-1, max=9-1}

	temp = UI.createSpriteWithFile("images/normalFiller.png",CCSizeMake(219, 28))
	temp:setColor(RESOURCE_COLOR.exp)
	screen.autoSuitable(temp, {x=13, y=205})
	batchBg:addChild(temp)
	item.filler = temp
	
	UI.registerAsProcess(temp, item)
		
	temp = UI.createSpriteWithFile("images/fillerBottom.png",CCSizeMake(225, 34))
	screen.autoSuitable(temp, {x=10, y=202})
	batchBg:addChild(temp)
	temp = UI.createSpriteWithFile("images/nozomiIcon.png",CCSizeMake(69, 65))
    screen.autoSuitable(temp, {x=-7, y=185})
    batchBg:addChild(temp)
	temp = UI.createLabel(math.floor(item.value/item.max*100) .. "%", General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=76, y=218, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	item.valueLabel = temp
	self.nozomiLevel = item
	UI.setProcess(item.filler, item, item.value/item.max)
	
	--[[
	item = {value=UserData.ulevel}
	temp = UI.createLabel(tostring(item.value), General.font4, 22, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=40, y=218, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	item.valueLabel = temp
	self.level = item
	--]]
	
	temp = UI.createLabel(StringManager.getString("labelNozomiProcess"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=69, y=246, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=13, y=142})
	batchBg:addChild(temp)
	temp = UI.createLabel("0/0", General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=76, y=156, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	self.builder = {max=0, value=0, valueLabel = temp}
	if self.scene.sceneType==SceneTypes.Operation then
    	temp = UI.createButton(CCSizeMake(33, 37), StoreDialog.show, {callbackParam="builders", image="images/buttonAdd.png", priority=display.MENU_BUTTON_PRI})
    	screen.autoSuitable(temp, {x=153, y=156, nodeAnchor=General.anchorCenter})
    	bg:addChild(temp)
    end
	temp = UI.createSpriteWithFile("images/builder.png",CCSizeMake(54, 59))
	screen.autoSuitable(temp, {x=14, y=128})
	batchBg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelBuilderNum"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=69, y=183, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=13, y=83})
	batchBg:addChild(temp)
	
	item = {value=UserData.userScore}
	temp = UI.createLabel(tostring(item.value), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=75, y=96, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	item.valueLabel = temp
	self.score = item
	temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(46, 54))
	screen.autoSuitable(temp, {x=14, y=68})
	batchBg:addChild(temp)
	if self.scene.sceneType==SceneTypes.Operation then
    	temp = UI.createButton(CCSizeMake(33, 37), display.showDialog, {callbackParam=RankDialog, image="images/rankIcon.png", priority=display.MENU_BUTTON_PRI})
    	screen.autoSuitable(temp, {x=153, y=96, nodeAnchor=General.anchorCenter})
    	bg:addChild(temp)
    end
end

function MenuLayer:closeChildMenu()
	local n = self.childMenu
	if n then
		local ttime = getParam("actionTimeChildMenu", 200)/1000
		for i, temp in pairs(self.childNodes) do
			temp:runAction(CCAlphaTo:create(ttime, 255, 0))
			if i>0 then
				temp:runAction(CCEaseBackIn:create(CCMoveBy:create(ttime, CCPointMake(0, -120))))
			end
		end
		delayRemove(ttime, self.childMenu)
		self.childMenu = nil
	end
end

function MenuLayer:showChildMenu(buildView)
	self:closeChildMenu()
	local build = buildView.buildMould
	local binfo = build.buildInfo
	local bdata = build.buildData
	
	local bg = CCNode:create()
	bg:setContentSize(CCSizeMake(512,256))
	screen.autoSuitable(bg, {screenAnchor=General.anchorLeftBottom, scaleType=screen.SCALE_NORMAL})
		
	local buts = build:getChildMenuButs()
	local childNodes = {}
	buttonNum = #buts
	local xoff = 183-(buttonNum-1)/2*105
	for i=1, buttonNum do
		temp = createChildMenuButton(buts[i].image, buts[i].text, buts[i].callback, buts[i].callbackParam, buts[i].extend)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=i*105+xoff, y=-60})
		bg:addChild(temp)
		childNodes[i] = temp
		temp:runAction(CCAlphaTo:create(getParam("actionTimeChildMenu", 200)/1000, 0, 255))
		temp:runAction(CCEaseBackOut:create(CCMoveBy:create(getParam("actionTimeChildMenu", 200)/1000, CCPointMake(0, 120))))
		if i==buttonNum and self.guideBid and self.guideBid==build.buildData.bid then
		    GuideLogic.clearPointer()
		    local pt = UI.createGuidePointer(90)
		    pt:setPosition(i*105+xoff+50, 60)
		    bg:addChild(pt)
		end
	end
	-- etc
	local titleKey = "titleInfo"
	if binfo.levelMax==1 then
		titleKey = "titleInfoNoLevel"
	end
	if build.buildLevel==0 and build.buildState~=BuildStates.STATE_BUILDING then
	    titleKey = "titleInfoLevel0"
	end
	temp = UI.createLabel(StringManager.getFormatString(titleKey, {name=binfo.name, level=bdata.level}), General.font3, 33, {colorR = 255, colorG = 255, colorB = 181})
	screen.autoSuitable(temp, {x=288, y=132, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp:setOpacity(0)
	temp:runAction(CCAlphaTo:create(getParam("actionTimeChildMenu", 200)/1000, 0, 255))
	childNodes[0] = temp
		
	self.view:addChild(bg, 1)
	self.childMenu = bg
	self.childNodes = childNodes
end

function MenuLayer:eventHandler(eventType, param)
	if eventType == EventManager.eventType.EVENT_DIALOG_OPEN then
		self.dialogShow = true
		self:closeChildMenu()
	elseif eventType == EventManager.eventType.EVENT_DIALOG_CLOSE then
		self.dialogShow = false
		if self.childMenuBuild then
			self:showChildMenu(self.childMenuBuild)
		end
		if GuideLogic.isTrainGuide then
		    EventManager.sendMessage("EVENT_GUIDE_STEP", {"build", 1001})
		end
	elseif eventType == EventManager.eventType.EVENT_BUILD_FOCUS then
		self.childMenuBuild = param
		if not self.dialogShow then
			self:showChildMenu(param)
		end
	elseif eventType == EventManager.eventType.EVENT_BUILD_UNFOCUS then
		self:closeChildMenu()
		self.childMenuBuild = nil
	elseif eventType == EventManager.eventType.EVENT_GUIDE_STEP then
		if param[1] == "menu" then
			local pname = param[2]
			self.buts[pname]:setVisible(true)
			local pt = GuideLogic.addPointer(0)
			local parent = self.buts[pname]:getParent()
			local x, y = self.buts[pname]:getPosition()
			pt:setPosition(x, y+60)
			parent:addChild(pt)
			if pname=="achieve" then
				self.buts["setting"]:setVisible(true)
				--self.buts["mail"]:setVisible(true)
				--UserData.historys = {}
			end
			if pname=="shop" then
			    self.guideBid = param[3]
			end
		elseif param[1]=="build" then
		    self.guideBid = param[2]
		end
	elseif eventType == EventManager.eventType.EVENT_NOTICE_BUTTON then
	    local temp = self.butNotices[param.name]
	    if param.isShow then
	        if temp then
    	        temp:setVisible(true)
    	    else
                temp = UI.createSpriteWithFile("images/numIcon.png",CCSizeMake(29, 29))
                screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=6, y=66})
                self.buts[param.name]:addChild(temp, 0, TAG_ACTION)
                self.butNotices[param.name] = temp
    	    end
	        local t = getParam("actionTimeButtonNotice", 400)/1000
	        local s = getParam("actionScaleButtonNotice", 120)/100
	        local n = getParam("actionNumButtonNotice", 1)
	        local array = CCArray:create()
	        array:addObject(CCEaseSineOut:create(CCScaleTo:create(t/2, s, s)))
	        array:addObject(CCEaseSineIn:create(CCScaleTo:create(t/2, 1, 1)))
	        temp:runAction(CCRepeat:create(CCSequence:create(array), n))
	    else
	        if temp then
    	        temp:setVisible(false)
    	    end
	    end
	    if GuideLogic.complete then
    	    self.buts[param.name]:setVisible(true)
    	end
	elseif eventType == EventManager.eventType.EVENT_NOZOMI_UPDATE then
        if self.nozomiLevel.value ~= param-1 then
            self.nozomiLevel.value = param-1
    	    self.nozomiLevel.valueLabel:setString(math.floor(self.nozomiLevel.value/self.nozomiLevel.max*100) .. "%")
    	    UI.setProcess(self.nozomiLevel.filler, self.nozomiLevel, self.nozomiLevel.value/self.nozomiLevel.max)
        end
        if not self.newspaperIcon and UserSetting.getValue("nozomiNewspaper")<param and param>=2 then
            local temp = UI.createButton(CCSizeMake(54, 70), self.openNozomiNewspaper, {image="images/newspaperIcon.png", callbackParam=self, priority=display.MENU_BUTTON_PRI})
            screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, screenAnchor=General.anchorRight, x=-51, y=19, scaleType=screen.SCALE_NORMAL})
            self.view:addChild(temp)
            self.newspaperIcon = temp
            CCTextureCache:sharedTextureCache():removeTextureForKey("images/newspaperIcon.png")
            
            if not display.isSceneChange then
                display.showDialog(SNSDialog.new(), false)
            end
            
            local sc = self.newspaperIcon:getScale()
            self.newspaperIcon:setScale(0)
            self.newspaperIcon:runAction(CCEaseBackOut:create(CCScaleTo:create(0.5, sc, sc)))
        end
        if not self.newspaperIcon and UserSetting.getValue("nozomiVideo")==0 and param>=2 then
            self.videoIcon = UI.createButton(CCSizeMake(60, 40), self.openNozomiVideo, {image="images/battleEndVideo.png", callbackParam=self, priority=display.MENU_BUTTON_PRI})
            screen.autoSuitable(self.videoIcon, {nodeAnchor=General.anchorCenter, screenAnchor=General.anchorRight, x=-51, y=19, scaleType=screen.SCALE_NORMAL})
            self.view:addChild(self.videoIcon)
            
            local sc = self.videoIcon:getScale()
            self.videoIcon:setScale(0)
            self.videoIcon:runAction(CCEaseBackOut:create(CCScaleTo:create(0.5, sc, sc)))
        end
        self.scene:checkCanBuild()
	end
end

local DIS_NUM={100,100,95,90,80,60,30,15,7}

function MenuLayer:openNozomiNewspaper()
    if self.newspaperIcon then
    	local action = UI.createSpriteWithFile("images/newspaper.png")
        temp = UI.createLabel(StringManager.getString("nozomiTextNewspaper1_" .. UserData.level), General.font1, 23, {colorR = 0, colorG = 0, colorB = 0})
        screen.autoSuitable(temp, {x=57, y=287, nodeAnchor=General.anchorLeft})
        action:addChild(temp)
        temp = UI.createLabel(StringManager.getFormatString("nozomiTextNewspaper2", {num=DIS_NUM[UserData.level]}), General.font1, 26, {colorR = 0, colorG = 0, colorB = 0})
        screen.autoSuitable(temp, {x=56, y=572, nodeAnchor=General.anchorLeft})
        action:addChild(temp)
    	action:setScale(0)
    	local scale = screen.getScalePolicy()[screen.SCALE_HEIGHT_FIRST]
    	local t=getParam("actionTimeNewspaper", 800)/1000
    	action:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(t, scale, scale), CCRotateBy:create(t, getParam("actionTimeRotation", 1080))))
    	screen.autoSuitable(action, {screenAnchor=General.anchorCenter})
        CCTextureCache:sharedTextureCache():removeTextureForKey("images/newspaper.png")
        
        display.showDialog({view=action}, true)
        self.newspaperIcon:removeFromParentAndCleanup(true)
        self.newspaperIcon = nil
        
        UserSetting.setValue("nozomiNewspaper", UserData.level)
	    music.playEffect("music/newspaper.mp3")
	    
	    --add replay icon here
	    
        if UserSetting.getValue("nozomiVideo")==0 then
            self.videoIcon = UI.createButton(CCSizeMake(60, 40), self.openNozomiVideo, {image="images/battleEndVideo.png", callbackParam=self, priority=display.MENU_BUTTON_PRI})
            screen.autoSuitable(self.videoIcon, {nodeAnchor=General.anchorCenter, screenAnchor=General.anchorRight, x=-51, y=19, scaleType=screen.SCALE_NORMAL})
            self.view:addChild(self.videoIcon)
            
            local sc = self.videoIcon:getScale()
            self.videoIcon:setScale(0)
            self.videoIcon:runAction(CCEaseBackOut:create(CCScaleTo:create(0.5, sc, sc)))
        end
    end
end

function MenuLayer:openNozomiVideo()
    if self.videoIcon then
        self.videoIcon:removeFromParentAndCleanup(true)
        self.videoIcon = nil
        UserSetting.setValue("nozomiVideo", 1)
        
        display.showDialog(VideoDialog.new())
    end
end
		 
function MenuLayer:enterOrExit(isEnter)
	if isEnter then
		self.monitorId = EventManager.registerEventMonitor({"EVENT_DIALOG_CLOSE", "EVENT_DIALOG_OPEN", "EVENT_BUILD_FOCUS", "EVENT_BUILD_UNFOCUS", "EVENT_GUIDE_STEP", "EVENT_NOTICE_BUTTON", "EVENT_NOZOMI_UPDATE"}, self.eventHandler, self)
	else
		EventManager.removeEventMonitor(self.monitorId)
	end
end

function MenuLayer:update(diff)
    if display.isSceneChange then return end
	local resourceTypes = {"oil", "food", "person"}
	for i=1, 3 do
		local resourceType = resourceTypes[i]
		local item = self[resourceType]
		local fillerUpdate = false
		if ResourceLogic.getResource(resourceType) ~= item.value then
			fillerUpdate = true
			local fromValue = item.value
			item.value = ResourceLogic.getResource(resourceType)
			item.valueLabel:runAction(CCNumberTo:create(1, fromValue, item.value, "", ""))
			--item.valueLabel:setString(tostring(item.value))
		end
		if ResourceLogic.getResourceMax(resourceType) ~= item.max then
			fillerUpdate = true
			item.max = ResourceLogic.getResourceMax(resourceType)
			item.maxLabel:setString(StringManager.getFormatString("resourceMax", {max=item.max}))
		end
		if fillerUpdate then
			local lmax = item.max
			if lmax==0 then lmax=1 end
			UI.setProcess(item.filler, item, item.value/lmax, true)
		end
	end
	
	local item = self.builder
	if ResourceLogic.getResourceMax("builder") ~= item.max or ResourceLogic.getResource("builder") ~= item.value then
		item.max = ResourceLogic.getResourceMax("builder") 
		item.value = ResourceLogic.getResource("builder")
		item.valueLabel:setString(item.value .. "/" .. item.max)
	end
	
	if UserData.crystal~=self.crystal.value then
		self.crystal.value = UserData.crystal
		self.crystal.valueLabel:setString(tostring(self.crystal.value))
	end
	
	local tstr = StringManager.getTimeString(math.floor((UserData.shieldTime or 0) - timer.getTime()))
	if tstr~=self.shieldString then
		self.shieldString = tstr
		self.shieldLabel:setString(tstr)
	end
	
	local zombieShield = (UserData.zombieShieldTime or 60)-timer.getTime()
	tstr = StringManager.getTimeString(zombieShield)
	if tstr ~= self.zombieShieldString then
		self.zombieShieldString = tstr
		self.zombieShieldLabel:setString(tstr)
	end
	if zombieShield<0 and not display.isDialogShow() and GuideLogic.complete then
		display.showDialog(ZombieDialog, false)
		UserStat.stat(UserStatType.ZOMBIE)
	end
	
	if UserData.userName=="" and GuideLogic.step>=14 and not display.isDialogShow() then
	    display.showDialog(RenameDialog.new(), false)
	end
	
	if self.score.value ~= UserData.userScore then
		self.score.value = UserData.userScore
		self.score.valueLabel:setString(tostring(self.score.value))
	end
	
		--[[
	if self.level.value ~= UserData.ulevel then
		self.level.value = UserData.ulevel
        local target = self.level.valueLabel
		target:setString(tostring(self.level.value))
		
	    local temp = UI.createSpriteWithFile("images/expUpgrade.png")
	    
        local temp1 = UI.createLabel(tostring(UserData.ulevel), General.font4, 40, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
        screen.autoSuitable(temp1, {x=104, y=94, nodeAnchor=General.anchorCenter})
        temp:addChild(temp1)
        temp1 = UI.createLabel(StringManager.getString("labelLevelUp"), General.font3, 28, {colorR = 255, colorG = 255, colorB = 255})
        screen.autoSuitable(temp1, {x=104, y=131, nodeAnchor=General.anchorCenter})
        temp:addChild(temp1)
        
        local bg = target:getParent()
        local p = bg:convertToNodeSpace(CCPointMake(General.winSize.width/2, General.winSize.height/2))
        print("test1")
        screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=p.x, y=p.y})
        bg:addChild(temp)
        temp:setScale(0)
        local array = CCArray:create()
        array:addObject(CCEaseBackOut:create(CCScaleTo:create(0.4, 1, 1)))
        array:addObject(CCDelayTime:create(1.5))
        
        local sarray = CCArray:create()
        local x, y = target:getPosition()
        sarray:addObject(CCMoveTo:create(0.5, CCPointMake(x, y)))
        sarray:addObject(CCScaleTo:create(0.5, 0.25, 0.25))
        array:addObject(CCSpawn:create(sarray))
        array:addObject(CCCallFuncN:create(removeSelf))
        
        temp:runAction(CCSequence:create(array))
	end
	
	if self.exp.value ~= UserData.exp or self.exp.max ~= UserData.nextExp then
	    self.exp.value = UserData.exp
	    self.exp.max = UserData.nextExp
	    self.exp.valueLabel:setString(tostring(self.exp.value))
	    UI.setProcess(self.exp.filler, self.exp, self.exp.value/self.exp.max)
	end
        --]]
end

function MenuLayer:dalayZombieAttack(force)
    if force then
        if CrystalLogic.changeCrystal(-100) then
            local t = UserData.zombieShieldTime
            if (t or 0)<=timer.getTime() then
                UserData.zombieShieldTime = timer.getTime() + 86400
            else
                UserData.zombieShieldTime = UserData.zombieShieldTime + 86400
            end
    		UserStat.addCrystalLog(CrystalStatType.BUY_ZOMBIE_SHIELD, timer.getTime(), 100)
        end
    else
        display.showDialog(AlertDialog.new(StringManager.getString("titleBuyZombieShield"), StringManager.getString("textBuyZombieShield"), {callback=self.dalayZombieAttack, param=true, crystal=100}, self))
    end
end

ZombieMenuLayer = class(MenuLayer)

function ZombieMenuLayer:ctor(scene)
    self.count=3
    self.time=5
    
	ReplayLogic.beginTime = timer.getTime()+3
	local seed = os.time()
	math.randomseed(seed)
	ReplayLogic.initWriteReplay(seed)
	ReplayLogic.buildData = scene.initInfo
end

function ZombieMenuLayer:initRightTop()
end
function ZombieMenuLayer:initTop()
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 128))
	screen.autoSuitable(bg, {screenAnchor=General.anchorTop, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(bg)
	temp = UI.createButton(CCSizeMake(133, 48), self.endBattle, {callbackParam=self, image="images/buttonEnd.png", text=StringManager.getString("buttonEndBattle"), fontSize=20, fontName=General.font3, priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {x=128, y=79, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
    self.topView = bg
    self.topView:setVisible(false)
end
function ZombieMenuLayer:initLeftTop()
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 192))
	local batchBg = CCSpriteBatchNode:create("images/normalUI.png")
	bg:addChild(batchBg)
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorLeftTop})
	self.view:addChild(bg)
	
	temp = UI.createSpriteWithFile("images/normalFiller.png",CCSizeMake(219, 28))
	temp:setColor(RESOURCE_COLOR.exp)
    screen.autoSuitable(temp, {x=21, y=133})
    batchBg:addChild(temp)
    local filler = temp
    temp = UI.createSpriteWithFile("images/fillerBottom.png",CCSizeMake(225, 34))
    screen.autoSuitable(temp, {x=18, y=129})
    batchBg:addChild(temp)
    temp = UI.createLabel("0", General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=85, y=146, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
	self.zombie = {value=0, valueLabel=temp, max=ZombieLogic.zombieMax, filler=filler}
	UI.registerAsProcess(filler, self.zombie)
    temp = UI.createSpriteWithFile("images/zombie.png",CCSizeMake(46, 58))
    screen.autoSuitable(temp, {x=23, y=119})
    batchBg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelZombies"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=81, y=173, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    
    temp = UI.createLabel(StringManager.getString("labelBuilderNum"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=82, y=52, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
    screen.autoSuitable(temp, {x=21, y=11})
    batchBg:addChild(temp)
    temp = UI.createSpriteWithFile("images/builder.png",CCSizeMake(54, 59))
    screen.autoSuitable(temp, {x=22, y=-3})
    batchBg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("0/0"), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
    screen.autoSuitable(temp, {x=85, y=27, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    self.builder = {max=0, value=0, valueLabel=temp}
    
    temp = UI.createLabel(StringManager.getString("labelOutsidePopulation"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=81, y=111, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/normalFiller.png",CCSizeMake(153, 30))
    temp:setColor(RESOURCE_COLOR.person)
    screen.autoSuitable(temp, {x=22, y=70})
    batchBg:addChild(temp)
    filler = temp
    temp = UI.createSpriteWithFile("images/fillerBottom.png",CCSizeMake(157, 34))
    screen.autoSuitable(temp, {x=20, y=68})
    batchBg:addChild(temp)
    temp = UI.createLabel("0", General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=85, y=83, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
	self.person = {value=0, valueLabel=temp, max=ZombieLogic.personMax, filler=filler}
	UI.registerAsProcess(filler, self.person)
    temp = UI.createSpriteWithFile("images/person.png",CCSizeMake(67, 52))
    screen.autoSuitable(temp, {x=5, y=58})
    batchBg:addChild(temp)
end

function ZombieMenuLayer:initRightBottom()
    local temp, bg = nil
    bg = CCNode:create()
    bg:setContentSize(General.winSize)
    self.bottomView = bg
    self.view:addChild(bg)
    
    temp = UI.createLabel(StringManager.getString("tipsZombieDefense2"), General.font3, 28, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {screenAnchor=General.anchorBottom, x=0, y=135, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
end

function ZombieMenuLayer:changeTimeScale()
	self.timeScale.value = self.timeScale.value%3+1
	local tvalue = TIME_SCALE[self.timeScale.value]
	self.timeScale.valueLabel:setString("x" .. tvalue)
	CCDirector:sharedDirector():getScheduler():setTimeScale(tvalue)
end
local zombieArea = {{640, 936}, {764, 2400}, {3240, 2366}, {2880, 220}, {3272, 468}, {3784, 860}}

function ZombieMenuLayer:beginDefend()
    if not ZombieLogic.isGuide then
        self.topView:setVisible(true)
    end
    local bg = self.bottomView
    bg:removeAllChildrenWithCleanup(true)
    
	local temp = UI.createButton(CCSizeMake(169, 76), self.changeTimeScale, {callbackParam=self, image="images/buttonGreen.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {x=-117, y=64, nodeAnchor=General.anchorCenter, screenAnchor=General.anchorRightBottom, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
	
	local label = UI.createLabel("x1", General.font4, 30)
	screen.autoSuitable(label, {nodeAnchor=General.anchorCenter, x=85, y=38})
	temp:addChild(label)
	self.timeScale = {valueLabel=label, value=1}
	CCDirector:sharedDirector():getScheduler():setTimeScale(1)

    local cnode = CCNode:create()
    cnode:setContentSize(CCSizeMake(220,132))
    screen.autoSuitable(cnode, {screenAnchor=General.anchorRightTop, scaleType=screen.SCALE_NORMAL})
    bg:addChild(cnode)
    temp = UI.createSpriteWithFile("images/battleStarBg.png",CCSizeMake(183, 94))
    screen.autoSuitable(temp, {x=19, y=23})
    cnode:addChild(temp)
    self.stars = {}
    for i=1, 3 do
        temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(29, 27))
        screen.autoSuitable(temp, {x=36 + i*30, y=64})
        cnode:addChild(temp)
        temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(29, 28))
        screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=51 + i*30, y=78})
        cnode:addChild(temp)
        self.stars[i] = temp
    end
    self.starsNum = 3
    temp = UI.createLabel("100%", General.font4, 30, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=111, y=47, nodeAnchor=General.anchorCenter})
    cnode:addChild(temp)
	self.percent = 100
	self.percentLabel = temp
    temp = UI.createLabel(StringManager.getString("damagePercent2"), General.font1, 16, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=113, y=100, nodeAnchor=General.anchorCenter})
    cnode:addChild(temp)
    self.scene.battleBegin = true
end

function ZombieMenuLayer:update(diff)
    if display.isSceneChange then return end
	if self.battleEnd then return end
	if ZombieLogic.getPerson()~=self.person.value then
		self.person.value = ZombieLogic.getPerson()
		self.person.valueLabel:setString(tostring(self.person.value))
		
		UI.setProcess(self.person.filler, self.person)
	end
	if ZombieLogic.getBuilderMax()~=self.builder.max or ZombieLogic.getBuilder()~=self.builder.value then
	    self.builder.max = ZombieLogic.getBuilderMax()
	    self.builder.value = ZombieLogic.getBuilder()
	    self.builder.valueLabel:setString(self.builder.value .. "/" .. self.builder.max)
	end
	if self.time then
	    self.time = self.time - diff
		if self.count and self.count>0 and self.time < self.count+1 then
			local temp = UI.createSpriteWithFile("images/count" .. self.count .. ".png")
			temp:setScale(0.01)
			screen.autoSuitable(temp, {screenAnchor=General.anchorCenter})
			self.view:addChild(temp, 10)
			temp:runAction(CCScaleTo:create(0.25, 1, 1))
			delayRemove(1, temp)
			self.count = self.count - 1
		end
		if self.time<0 then
		    self.time = nil
		    self.count = nil
		    self.stateZombie = true
		    self:beginDefend()
		end
		return
	end
	if ZombieLogic.getZombie()>0 and self.stateZombie then
		local cd = 1
		local zid = ZombieLogic.getOneZombie()
		local soldier = Zombie.new(zid+10, {isFighting=true})
		
		local areaId = ZombieLogic.getOneZombieArea()
		if ZombieLogic.isGuide then
		    areaId = 3
		end
		local p = zombieArea[areaId]
		local x, y = p[1] + math.random(220)-110, p[2] + math.random(165)
		soldier:addToScene(self.scene, {x, y})
		soldier:playAppearSound()
		table.insert(self.scene.soldiers, soldier)
		
		table.insert(ReplayLogic.cmdList, {timer.getTime()-ReplayLogic.beginTime, "z", zid, x, y})
	end
	self.coldTime = (self.coldTime or 0) - diff
	if self.coldTime<0 then
	    self.coldTime = 0.5
	    local zombieNum = self.scene:countSoldier()
        if zombieNum~=self.zombie.value then
        	self.zombie.value = zombieNum+ZombieLogic.getZombie()
        	self.zombie.valueLabel:setString(tostring(self.zombie.value))
	    
		    UI.setProcess(self.zombie.filler, self.zombie)
        end
		if zombieNum > getParam("zombieMax", 60) and self.stateZombie then
		    self.stateZombie = false
		elseif zombieNum < getParam("zombieMin", 20) and not self.stateZombie then
		    self.stateZombie = true
		    local text = StringManager.getString("labelZombieDefense")
		    local label = UI.createLabel(text, General.font3, 40, {colorR=253, colorG=8, colorB=8})
    		screen.autoSuitable(label, {screenAnchor=General.anchorCenter})
    	    self.bottomView:addChild(label)
    		    
    		label:setScale(0)
    		label:runAction(CCScaleTo:create(0.25, 1, 1))
    		delayRemove(2, label)
		end
		if zombieNum==0 and ZombieLogic.getZombie()==0 then
		    self:endBattle(false)
    	end
	end
	if ZombieLogic.percent~=self.percent then
	    self.percent = ZombieLogic.percent
	    self.percentLabel:setString(ZombieLogic.percent .. "%")
	end
	if ZombieLogic.stars < self.starsNum then
	    local star = self.stars[self.starsNum]
	    local array = CCArray:create()
	    array:addObject(CCEaseBackIn:create(CCScaleTo:create(0.5, 0, 0)))
	    array:addObject(CCCallFuncN:create(removeSelf))
	    star:runAction(CCSequence:create(array))
	    self.starsNum = self.starsNum-1
	end
	if ZombieLogic.battleEnd then
    	CCDirector:sharedDirector():getScheduler():setTimeScale(1)
    	
	    self.battleEnd = true
		table.insert(ReplayLogic.cmdList, {timer.getTime() - ReplayLogic.beginTime, "e"})
		ReplayLogic.makeReplayResult("zombie.txt")
		self.view:removeFromParentAndCleanup(true)
		display.showDialog(ZombieResultDialog.new(ZombieLogic.getBattleResult()), false)
	end
end

function ZombieMenuLayer:endBattle(force)
    if force~=nil then
        if force then
            local losePerson = math.floor(ResourceLogic.getResource("person")*LOST_PERCENT/100)
            if losePerson>-ZombieLogic.losePerson then
                ZombieLogic.losePerson = -losePerson
            end
            ZombieLogic.stars=0
        end
    	ZombieLogic.battleEnd = true
    else
        display.showDialog(AlertDialog.new(StringManager.getString("alertTitleEndBattle"), StringManager.getFormatString("alertTextEndZombie", {percent=LOST_PERCENT}), {callback=self.endBattle, param=true}, self))
    end
end

VisitMenuLayer=class(MenuLayer)

function VisitMenuLayer:update()
end

function VisitMenuLayer:initRightBottom()
    local bg = CCNode:create()
    screen.autoSuitable(bg, {screenAnchor=General.anchorLeftBottom, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(bg)
	
	local temp = UI.createMenuButton(CCSizeMake(111, 109), "images/buttonChildMenu.png", display.popScene, PreBattleScene, "images/menuItemAchieve.png", StringManager.getString("buttonReturnHome"), MENU_BUTTON_SIZE)
	screen.autoSuitable(temp, {x=72, y=70, screenAnchor=General.anchorLeftBottom, nodeAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
end

function VisitMenuLayer:initLeftTop()

	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 256))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorLeftTop})
	self.view:addChild(bg)
	
	temp = UI.createLabel(self.scene.initInfo.name, General.font3, 22, {colorR = 255, colorG = 255, colorB = 231, lineOffset=-12})
    screen.autoSuitable(temp, {x=39, y=221, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
end

function VisitMenuLayer:initTop()
end